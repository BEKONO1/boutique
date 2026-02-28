#!/bin/bash
set -e

echo "=== Railway Deployment Start ==="

# Enable error reporting
export APP_DEBUG=true
export LOG_CHANNEL=stderr
export DEVELOPMENT_ENVIRONMENT=true
export SESSION_DRIVER=file
export CACHE_DRIVER=file

# ============================================
# CONFIGURATION BASE DE DONNÉES - Railway variables
# ============================================
DB_HOST_VAL=${MYSQLHOST:-mysql.railway.internal}
DB_PORT_VAL=${MYSQLPORT:-3306}
DB_DATABASE_VAL=${DB_DATABASE:-railway}
DB_USERNAME_VAL=${DB_USERNAME:-root}
DB_PASSWORD_VAL=${DB_PASSWORD:-${MYSQL_ROOT_PASSWORD:-}}

echo "=== Database Configuration ==="
echo "Host: $DB_HOST_VAL"
echo "Port: $DB_PORT_VAL"
echo "Database: $DB_DATABASE_VAL"
echo "User: $DB_USERNAME_VAL"

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
sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=file|" .env
sed -i "s|CACHE_DRIVER=.*|CACHE_DRIVER=file|" .env

echo "=== Generating app key ==="
php artisan key:generate --force

echo "=== Creating storage link ==="
php artisan storage:link --force 2>/dev/null || true

echo "=== Clearing cache ==="
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

echo "=== Setting permissions ==="
chmod -R 777 storage bootstrap/cache 2>/dev/null || true

echo "=== Starting PHP built-in server on port 8080 ==="
echo "APP_URL is: $APP_URL_VAL"

cd /var/www/html/public
exec php -S 0.0.0.0:8080 -t /var/www/html/public
