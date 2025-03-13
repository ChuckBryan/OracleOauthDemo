#!/bin/bash
# Set wallet directory and password
WALLET_DIR="/etc/ora_wallet"
WALLET_PASSWORD="pa55w0rd!"

# Check if the wallet directory already exists
if [ -d "$WALLET_DIR" ]; then
  echo "Wallet directory already exists: $WALLET_DIR"
else
  echo "Creating wallet directory: $WALLET_DIR"
  mkdir -p "$WALLET_DIR"
fi

# Create the Oracle Wallet using the orapki tool with auto_login option
echo "Creating Oracle Wallet at $WALLET_DIR"
orapki wallet create -wallet "$WALLET_DIR" -pwd "$WALLET_PASSWORD" -auto_login

# Check if the wallet was created successfully
if [ -f "$WALLET_DIR/cwallet.sso" ]; then
  echo "SSO Wallet created successfully!"
else
  echo "Failed to create the SSO wallet."
  
  # If only ewallet.p12 exists, enable auto-login
  if [ -f "$WALLET_DIR/ewallet.p12" ]; then
    echo "Found ewallet.p12, enabling auto-login..."
    orapki wallet enable_autologin -wallet "$WALLET_DIR" -pwd "$WALLET_PASSWORD"
    
    if [ -f "$WALLET_DIR/cwallet.sso" ]; then
      echo "SSO Wallet created successfully!"
    else
      echo "Failed to create the SSO wallet."
      exit 1
    fi
  else
    echo "No wallet files found."
    exit 1
  fi
fi

echo "Wallet files in $WALLET_DIR:"
ls -l $WALLET_DIR
