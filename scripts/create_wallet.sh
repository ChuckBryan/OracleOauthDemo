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

# Create the Oracle Wallet using the orapki tool
echo "Creating Oracle Wallet at $WALLET_DIR"
orapki wallet create -wallet "$WALLET_DIR" -pwd "$WALLET_PASSWORD"

# Check if the wallet was created successfully
if [ -f "$WALLET_DIR/ewallet.p12" ]; then
  echo "Wallet created successfully!"
else
  echo "Failed to create the wallet."
  exit 1
fi
