FROM php:7.2.24-apache

WORKDIR /var/www/html

ARG WWWGROUP

RUN apt-get update && \
    apt-get install -y \
    git \
    libzip-dev \
    libpng-dev \
    libicu-dev \
    libpq-dev \
    libmagickwand-dev \
    unzip \
    curl

# Install PHP extensions including mysqli
RUN docker-php-ext-install pdo_mysql mysqli zip exif pcntl bcmath gd calendar intl
RUN a2enmod rewrite

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the entire project to /var/www/html
COPY . /var/www/html

RUN ls -la /var/www/html

# Install Composer dependencies
RUN composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

# Set permissions for Apache
RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Enable custom Virtual Host
COPY my-app.conf /etc/apache2/sites-available/
RUN a2ensite my-app.conf && a2dissite 000-default.conf
RUN apache2ctl configtest
# Debug Apache status and logs
RUN service apache2 status || true
# RUN cat /var/log/apache2/error.log || true
# Reload Apache to apply changes
#RUN service apache2 reload

EXPOSE 80
CMD ["apache2-foreground"]