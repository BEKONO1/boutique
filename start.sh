#!/bin/bash
set -e

echo "=== Railway Deployment Start ==="

# Enable error reporting
export APP_DEBUG=true
export LOG_CHANNEL=stderr
export DEVELOPMENT_ENVIRONMENT=true

# ============================================
# CONFIGURATION BASE DE DONNÉES (simplifiée)
# ============================================
DB_HOST_VAL=${MYSQLHOST:-${DB_HOST:-mysql.railway.internal}}
DB_PORT_VAL=${MYSQLPORT:-${DB_PORT:-3306}}
DB_DATABASE_VAL=${MYSQLDATABASE:-${DB_DATABASE:-railway}}
DB_USERNAME_VAL=${MYSQLUSER:-${DB_USERNAME:-root}}
DB_PASSWORD_VAL=${MYSQLPASSWORD:-${DB_PASSWORD:-}}

echo "DB Host: $DB_HOST_VAL"

# ============================================
# CRÉATION .env
# ============================================
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# Update .env - always set APP_URL and ASSET_URL
APP_URL_VAL=${APP_URL:-https://boutique-production-4ebe.up.railway.app}
sed -i "s|APP_URL=.*|APP_URL=$APP_URL_VAL|" .env

# Ensure ASSET_URL is set to same as APP_URL
if grep -q "ASSET_URL=" .env; then
    sed -i "s|ASSET_URL=.*|ASSET_URL=$APP_URL_VAL|" .env
else
    echo "ASSET_URL=$APP_URL_VAL" >> .env
fi

sed -i "s|APP_DEBUG=.*|APP_DEBUG=true|" .env
sed -i "s|LOG_CHANNEL=.*|LOG_CHANNEL=stderr|" .env
sed -i "s|DB_HOST=.*|DB_HOST=$DB_HOST_VAL|" .env
sed -i "s|DB_PORT=.*|DB_PORT=$DB_PORT_VAL|" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=$DB_DATABASE_VAL|" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME_VAL|" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD_VAL|" .env
sed -i "s|DEVELOPMENT_ENVIRONMENT=.*|DEVELOPMENT_ENVIRONMENT=true|" .env

# Ensure SESSION_DRIVER is set to file
if grep -q "SESSION_DRIVER=" .env; then
    sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=file|" .env
else
    echo "SESSION_DRIVER=file" >> .env
fi

# Ensure CACHE_DRIVER is set to file
if grep -q "CACHE_DRIVER=" .env; then
    sed -i "s|CACHE_DRIVER=.*|CACHE_DRIVER=file|" .env
else
    echo "CACHE_DRIVER=file" >> .env
fi

echo "=== Generating app key ==="
php artisan key:generate --force

echo "=== Creating storage link ==="
php artisan storage:link --force 2>/dev/null || true

echo "=== Clearing cache ==="
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

echo "=== Copying theme assets ==="
mkdir -p public/themes
cp -rf resources/themes/* public/themes/ 2>/dev/null || true

echo "=== Setting permissions ==="
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

echo "=== Starting PHP server on port 8080 ==="
echo "APP_URL is: $APP_URL"

cd /var/www/html/public
exec php -S 0.0.0.0:8080 -t /var/www/html/public
