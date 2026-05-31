#!/bin/bash

# Verification script for Module 2 API
BASE_URL="http://localhost:3000/api/explore"

echo "Checking Explore Overview..."
curl -s -X GET "$BASE_URL/overview" | jq .

echo -e "\nChecking Locations..."
curl -s -X GET "$BASE_URL/locations" | jq .

echo -e "\nChecking Tours with Filter (Featured)..."
curl -s -X GET "$BASE_URL/tours?is_featured=true" | jq .

echo -e "\nChecking Guides..."
curl -s -X GET "$BASE_URL/guides" | jq .

echo -e "\nTesting Wishlist (Requires Login - This will fail without token)..."
curl -s -X POST "$BASE_URL/wishlist" -H "Content-Type: application/json" -d '{"tour_id": 1}' | jq .
