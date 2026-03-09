#!/bin/bash
set -e

echo "🔧 Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y \
  mariadb-client mariadb-server \
  libpng-dev libjpeg-dev libwebp-dev \
  unzip git

echo "🐘 Configuring PHP extensions..."
sudo docker-php-ext-install pdo pdo_mysql gd

echo "🎵 Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "📦 Installing Drupal 11 via Composer..."
composer create-project drupal/recommended-project:^11 /workspace/drupal --no-interaction

echo "🗄️ Setting up MariaDB..."
sudo service mariadb start
sudo mysql -e "CREATE DATABASE drupal11; CREATE USER 'drupal'@'localhost' IDENTIFIED BY 'drupal'; GRANT ALL ON drupal11.* TO 'drupal'@'localhost'; FLUSH PRIVILEGES;"

echo "⚙️ Installing Drush..."
cd /workspace/drupal && composer require drush/drush

echo "🌐 Installing Drupal..."
cd /workspace/drupal && vendor/bin/drush site:install standard \
  --db-url=mysql://drupal:drupal@localhost/drupal11 \
  --site-name="Theme Testing" \
  --account-name=admin \
  --account-pass=admin \
  --yes

echo "✅ Drupal 11 ready!"