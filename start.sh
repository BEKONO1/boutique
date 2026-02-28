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
echo "Database: $DB_DATABASE_VAL"

# ============================================
# CRÉATION .env
# ============================================
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# Get APP_URL from Railway or use default
APP_URL_VAL=${APP_URL:-https://boutique-production-4ebe.up.railway.app}

# Set all required environment variables
echo "=== Setting environment variables ==="

# APP_URL
sed -i "s|^APP_URL=.*|APP_URL=$APP_URL_VAL|" .env

# ASSET_URL - CRITICAL for CSS
if grep -q "^ASSET_URL=" .env; then
    sed -i "s|^ASSET_URL=.*|ASSET_URL=$APP_URL_VAL|" .env
else
    echo "ASSET_URL=$APP_URL_VAL" >> .env
fi

# WEB_THEME - Set default theme
if grep -q "^WEB_THEME=" .env; then
    sed -i "s|^WEB_THEME=.*|WEB_THEME=theme_aster|" .env
else
    echo "WEB_THEME=theme_aster" >> .env
fi

# Other settings
sed -i "s|^APP_DEBUG=.*|APP_DEBUG=true|" .env
sed -i "s|^LOG_CHANNEL=.*|LOG_CHANNEL=stderr|" .env
sed -i "s|^SESSION_DRIVER=.*|SESSION_DRIVER=file|" .env
sed -i "s|^CACHE_DRIVER=.*|CACHE_DRIVER=file|" .env
sed -i "s|^DEVELOPMENT_ENVIRONMENT=.*|DEVELOPMENT_ENVIRONMENT=true|" .env
sed -i "s|^APP_ENV=.*|APP_ENV=production|" .env
sed -i "s|^APP_MODE=.*|APP_MODE=live|" .env

# Database settings
sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
sed -i "s|^DB_HOST=.*|DB_HOST=$DB_HOST_VAL|" .env
sed -i "s|^DB_PORT=.*|DB_PORT=$DB_PORT_VAL|" .env
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$DB_DATABASE_VAL|" .env
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME_VAL|" .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD_VAL|" .env

echo "=== APP_URL: $APP_URL_VAL"
echo "=== ASSET_URL: $APP_URL_VAL"
echo "=== WEB_THEME: theme_aster"

echo "=== Generating app key ==="
php artisan key:generate --force

echo "=== Configuring theme in database ==="
php artisan tinker --execute="
try {
    // Set theme configuration
    \App\Models\BusinessSetting::updateOrInsert(
        ['type' => 'web_theme'],
        ['value' => 'theme_aster']
    );
    \App\Models\BusinessSetting::updateOrInsert(
        ['type' => 'system_default_theme'],
        ['value' => 'theme_aster']
    );
    echo 'Theme configuration set successfully';
} catch (\Exception \$e) {
    echo 'Error: ' . \$e->getMessage();
}
" 2>/dev/null || true

echo "=== Creating storage link ==="
php artisan storage:link --force 2>/dev/null || true

echo "=== Copying theme assets ==="
mkdir -p public/themes
cp -rf resources/themes/* public/themes/ 2>/dev/null || true
cd public && ln -sf ../resources/themes themes 2>/dev/null || true
cd ..

echo "=== Clearing cache ==="
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

echo "=== Setting permissions ==="
chmod -R 777 storage bootstrap/cache 2>/dev/null || true

echo "=== Starting PHP server on port 8080 ==="
echo "=== Final APP_URL: $(grep APP_URL .env | head -1) ==="
echo "=== Final ASSET_URL: $(grep ASSET_URL .env | head -1) ==="

cd /var/www/html/public
exec php -S 0.0.0.0:8080 -t /var/www/html/public
