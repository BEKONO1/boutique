#!/bin/bash
set -e

echo "=== Railway Deployment Start ==="

# ============================================
# CONFIGURATION BASE DE DONNÉES
# ============================================
DB_HOST_VAL=${DB_HOST:-${MYSQLHOST:-mysql.railway.internal}}
DB_PORT_VAL=${DB_PORT:-${MYSQLPORT:-3306}}
DB_DATABASE_VAL=${DB_DATABASE:-${MYSQLDATABASE:-railway}}
DB_USERNAME_VAL=${DB_USERNAME:-${MYSQLUSER:-root}}
DB_PASSWORD_VAL=${DB_PASSWORD:-${MYSQLPASSWORD:-}}

# ============================================
# CONFIGURATION APP URL
# ============================================
APP_URL_VAL=${APP_URL:-https://votre-app.up.railway.app}

# ============================================
# CONFIGURATION REDIS (optionnel)
# ============================================
if [ -n "$REDISHOST" ]; then
    REDIS_HOST_VAL="$REDISHOST"
    REDIS_PORT_VAL="${REDISPORT:-6379}"
    REDIS_PASSWORD_VAL="${REDISPASSWORD:-}"
    CACHE_DRIVER_VAL="redis"
    SESSION_DRIVER_VAL="redis"
    echo "Redis detected at ${REDIS_HOST_VAL}:${REDIS_PORT_VAL}"
else
    CACHE_DRIVER_VAL="file"
    SESSION_DRIVER_VAL="file"
    echo "No Redis - using file cache"
fi

# ============================================
# CRÉATION/MISE À JOUR DU FICHIER .env
# ============================================
if [ -f ".env" ]; then
    echo "Updating existing .env file..."

    sed -i "s|^APP_URL=.*|APP_URL=${APP_URL_VAL}|g" .env
    sed -i "s|^ASSET_URL=.*|ASSET_URL=${APP_URL_VAL}|g" .env

    if ! grep -q "^ASSET_URL=" .env; then
        echo "ASSET_URL=${APP_URL_VAL}" >> .env
    fi

    sed -i "s|^DB_HOST=.*|DB_HOST=${DB_HOST_VAL}|g" .env
    sed -i "s|^DB_PORT=.*|DB_PORT=${DB_PORT_VAL}|g" .env
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE_VAL}|g" .env
    sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME_VAL}|g" .env
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD_VAL}|g" .env

    sed -i "s|^CACHE_DRIVER=.*|CACHE_DRIVER=${CACHE_DRIVER_VAL}|g" .env
    sed -i "s|^SESSION_DRIVER=.*|SESSION_DRIVER=${SESSION_DRIVER_VAL}|g" .env
    sed -i "s|^FILESYSTEM_DRIVER=.*|FILESYSTEM_DRIVER=public|g" .env

    sed -i "/^REDIS_HOST=/d" .env
    sed -i "/^REDIS_PORT=/d" .env
    sed -i "/^REDIS_PASSWORD=/d" .env

    if [ "$CACHE_DRIVER_VAL" = "redis" ]; then
        echo "REDIS_HOST=${REDIS_HOST_VAL}" >> .env
        echo "REDIS_PORT=${REDIS_PORT_VAL}" >> .env
        [ -n "$REDIS_PASSWORD_VAL" ] && echo "REDIS_PASSWORD=${REDIS_PASSWORD_VAL}" >> .env
    fi
else
    echo "Creating new .env file..."

    cat > .env << EOF
APP_NAME="6Valley"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=${APP_URL_VAL}
ASSET_URL=${APP_URL_VAL}
LOG_CHANNEL=stderr
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=${DB_HOST_VAL}
DB_PORT=${DB_PORT_VAL}
DB_DATABASE=${DB_DATABASE_VAL}
DB_USERNAME=${DB_USERNAME_VAL}
DB_PASSWORD=${DB_PASSWORD_VAL}

CACHE_DRIVER=${CACHE_DRIVER_VAL}
QUEUE_CONNECTION=sync
SESSION_DRIVER=${SESSION_DRIVER_VAL}
FILESYSTEM_DRIVER=public
EOF

    if [ "$CACHE_DRIVER_VAL" = "redis" ]; then
        cat >> .env << EOF

REDIS_HOST=${REDIS_HOST_VAL}
REDIS_PORT=${REDIS_PORT_VAL}
EOF
        [ -n "$REDIS_PASSWORD_VAL" ] && echo "REDIS_PASSWORD=${REDIS_PASSWORD_VAL}" >> .env
    fi
fi

# ============================================
# COMMANDES ARTISAN
# ============================================
echo "Generating app key..."
php artisan key:generate --force

echo "Discovering packages..."
php artisan package:discover --ansi || true

echo "Creating storage link..."
php artisan storage:link --force 2>/dev/null || true

# ============================================
# ATTENTE BASE DE DONNÉES
# ============================================
echo "Waiting for database..."
sleep 15

echo "Testing database connection..."
DB_READY=false
for i in {1..30}; do
    if php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; then
        DB_READY=true
        break
    fi
    echo "Waiting for database connection... ($i/30)"
    sleep 2
done

if [ "$DB_READY" = true ]; then
    echo "Database connected!"
    # ============================================
    # MIGRATIONS
    # ============================================
    echo "Running migrations..."
    php artisan migrate --force --no-interaction || true
else
    echo "Database not available - skipping migrations"
fi

# ============================================
# CACHE & ASSETS
# ============================================
echo "Clearing cache..."
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true
php artisan view:clear 2>/dev/null || true

echo "Caching config..."
php artisan config:cache --no-interaction || true
php artisan route:cache --no-interaction || true
php artisan view:cache --no-interaction || true

# ============================================
# PERMISSIONS
# ============================================
echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# ============================================
# DÉMARRAGE APACHE
# ============================================
echo "=== Starting Apache on port 8080 ==="
apache2-foreground
