# Use a base image with Apache and PHP installed
FROM wordpress:5.7.2

# Install Nginx and Supervisor
RUN apt-get update && \
    apt-get install -y nginx supervisor && \
    apt-get clean

# Copy application files
COPY ./src/.htaccess /var/www/html/.htaccess
COPY ./src/wp-content/themes /var/www/html/wp-content/themes
COPY ./src/wp-content/plugins /var/www/html/wp-content/plugins

# Copy environment files and healthcheck script
COPY ./.env /src/.env
COPY ./healthcheck-pipeline.sh /src/healthcheck-pipeline.sh

# Set permissions
RUN usermod -u 1000 www-data && \
    chown -R www-data:www-data /var/www/html && \
    chmod +x /src/healthcheck-pipeline.sh

# Copy Nginx configuration
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Copy Supervisor configuration
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

# Expose port 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s CMD curl --fail http://localhost || exit 1

# Start Supervisor to manage both Apache and Nginx
CMD ["/usr/bin/supervisord"]
