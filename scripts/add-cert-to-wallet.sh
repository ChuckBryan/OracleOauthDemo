#!/bin/bash
# Set wallet directory and password
WALLET_DIR="/etc/ora_wallet"
WALLET_PASSWORD="pa55w0rd!"
CERT_PATH="/etc/ora_wallet/certs/openiddict-api.crt"

echo "Adding certificate to the Oracle Wallet"

# Check if certificate file exists
if [ ! -f "$CERT_PATH" ]; then
  echo "Certificate file not found: $CERT_PATH"
  exit 1
fi

# Add the certificate to the Oracle Wallet
echo "Adding certificate as trusted certificate..."
orapki wallet add -wallet $WALLET_DIR -trusted_cert -cert $CERT_PATH -pwd $WALLET_PASSWORD

# Check status
if [ $? -eq 0 ]; then
  echo "✓ Certificate added successfully"
else
  echo "✗ Failed to add certificate"
  exit 1
fi

# Display the wallet contents to verify
echo -e "\nWallet contents after adding certificate:"
orapki wallet display -wallet $WALLET_DIR -pwd $WALLET_PASSWORD

# Count trusted certificates
TRUSTED_CERTS=$(orapki wallet display -wallet $WALLET_DIR -pwd $WALLET_PASSWORD | grep -c "trusted certificate")
echo -e "\nFound $TRUSTED_CERTS trusted certificate(s) in wallet"

# Create symlinks to make sure Oracle finds all wallet files
echo -e "\nEnsuring proper file access and permissions..."
chmod -R 755 $WALLET_DIR
ls -la $WALLET_DIR
