#!/bin/bash
# Set wallet directory and password
WALLET_DIR="/etc/ora_wallet"
WALLET_PASSWORD="pa55w0rd!"
CERT_PATH="/etc/ora_wallet/certs/openiddict-api.crt"

echo "Adding certificate to the Oracle Wallet"

# Check if certificate file exists
if [ ! -f "$CERT_PATH" ]; then
  echo "Certificate file not found: $CERT_PATH"
  echo "Looking for alternative certificate files..."
  
  # List available certificate files
  find /etc/ora_wallet/certs -type f -name "*.crt" -o -name "*.pem"
  
  exit 1
fi

# Remove any existing certificate (ignoring errors if it doesn't exist)
echo "Removing any previous certificates..."
orapki wallet remove -wallet "$WALLET_DIR" -pwd "$WALLET_PASSWORD" -trusted_cert -cert "$CERT_PATH" > /dev/null 2>&1 || true

# Add the certificate to the Oracle Wallet as trusted
echo "Adding certificate as trusted certificate..."
orapki wallet add -wallet "$WALLET_DIR" -trusted_cert -cert "$CERT_PATH" -pwd "$WALLET_PASSWORD"

# Check status
if [ $? -eq 0 ]; then
  echo "✓ Certificate added successfully"
else
  echo "✗ Failed to add certificate"
  exit 1
fi

# Display the wallet contents to verify
echo -e "\nWallet contents after adding certificate:"
orapki wallet display -wallet "$WALLET_DIR" -pwd "$WALLET_PASSWORD"

# List all wallet files
echo -e "\nWallet directory contents:"
ls -la "$WALLET_DIR"
