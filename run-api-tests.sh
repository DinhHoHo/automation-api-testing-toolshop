#!/bin/bash

echo "Starting API Login Tests..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Start Docker services
echo "Starting Docker containers..."
docker compose -f docker-compose.yml up -d --force-recreate

# Wait for services
echo "Waiting for services to be ready..."
sleep 30

# Setup database
echo "Setting up database..."
docker compose exec laravel-api php artisan migrate --force
docker compose exec laravel-api php artisan db:seed --force

# Install Newman if not exists
if ! command -v newman &> /dev/null; then
    echo "Installing Newman..."
    npm install -g newman newman-reporter-htmlextra
fi

# Run tests by Newman
echo "Running API tests..."

# Test 1: Add New Category API
echo "Running Add New Category API tests..."
newman run tests/add_new_category_api/"API 1.postman_collection.json" -e tests/add_new_category_api/environment.json --iteration-data tests/add_new_category_api/add_new_category_data_driven.csv --reporters cli,htmlextra --reporter-htmlextra-export tests/add_new_category_api/newman-report-add.html

# Test 2: Get Specific Category API
echo "Running Get Specific Category API tests..."
newman run tests/get_specific_category_api/"API 2.postman_collection.json" -e tests/get_specific_category_api/environment.json --iteration-data tests/get_specific_category_api/get_specific_category_data_driven.csv --reporters cli,htmlextra --reporter-htmlextra-export tests/get_specific_category_api/newman-report-get.html

# Test 3: Update Specific Category API
echo "Running Update Specific Category API tests..."
newman run tests/update_specific_category_api/"API 3.postman_collection.json" -e tests/update_specific_category_api/environment.json --iteration-data tests/update_specific_category_api/update_specific_category_data_driven.csv --reporters cli,htmlextra --reporter-htmlextra-export tests/update_specific_category_api/newman-report-update.html

# Tổng hợp báo cáo
echo "All API tests completed! Reports generated:"
echo "- Add Category Report: tests/add_new_category_api/newman-report-add.html"
echo "- Get Category Report: tests/get_specific_category_api/newman-report-get.html"
echo "- Update Category Report: tests/update_specific_category_api/newman-report-update.html"

# Cleanup
docker compose down