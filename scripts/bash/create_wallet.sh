#!/bin/bash
# Set wallet directory and password
WALLET_DIR="/etc/ora_wallet"
WALLET_PASSWORD="pa55w0rd!"

# Check if the wallet directory already exists
if [ -d "$WALLET_DIR" ]; then
  echo "Wallet directory exists: $WALLET_DIR"
else
  echo "Creating wallet directory: $WALLET_DIR"
  mkdir -p "$WALLET_DIR"
fi

# Create the Oracle Wallet
echo "Creating Oracle Wallet at $WALLET_DIR"
orapki wallet create -wallet "$WALLET_DIR" -pwd "$WALLET_PASSWORD" -auto_login

# Verify wallet creation
if [ -f "$WALLET_DIR/cwallet.sso" ] && [ -f "$WALLET_DIR/ewallet.p12" ]; then
  echo "✓ Wallet created successfully!"
  echo "Found wallet files:"
  ls -l "$WALLET_DIR"/cwallet.sso "$WALLET_DIR"/ewallet.p12
else
  echo "✗ Wallet creation may have failed. Checking wallet directory contents:"
  ls -la "$WALLET_DIR"
  exit 1
fi
