# Use PHP 8.3 as the base image
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpq-dev \
    libzip-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy application files
COPY . /app

# Copy .env.production file to /app/.env
COPY .env.production /app/.env

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Install Node.js dependencies
RUN npm install && npm run build

# Set permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# Run Laravel commands
RUN php artisan key:generate && \
    php artisan config:clear 

# Expose port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
