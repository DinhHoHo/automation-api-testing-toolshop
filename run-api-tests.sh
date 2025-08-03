#!/bin/bash

echo "🚀 Starting API Login Tests..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Start Docker services
echo "📦 Starting Docker containers..."
# docker-compose up -d
docker compose -f docker-compose.yml up -d --force-recreate

# Wait for services
echo "⏳ Waiting for services to be ready..."
sleep 30

# Setup database
echo "🗄️ Setting up database..."
docker compose exec laravel-api php artisan migrate --force
docker compose exec laravel-api php artisan db:seed --force

# Install Newman if not exists
if ! command -v newman &> /dev/null; then
    echo "📥 Installing Newman..."
    npm install -g newman newman-reporter-htmlextra
fi

# Run tests by Newman
echo "🧪 Running API tests..."
newman run tests/api-store-new-category/categories-API-Testing.postman_collection.json -e tests/api-store-new-category/environment.json --iteration-data tests/api-store-new-category/categories_data_driven.csv --reporters cli,htmlextra --reporter-htmlextra-export tests/api-store-new-category/newman-report.html

# Cleanup (optional)
docker compose down