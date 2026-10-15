#!/bin/bash
API_KEY="AIzaSyAoMJTOPNtDB1qw8HOoUU0TY1fBCYxp6jI"

echo "Attempting to create test user 1 (testuser1@xchange.lk)..."
curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser1@xchange.lk","password":"Pass1234!","returnSecureToken":true}'

echo ""
echo "Attempting to create test user 2 (testuser2@xchange.lk)..."
curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser2@xchange.lk","password":"Pass1234!","returnSecureToken":true}'

echo ""
