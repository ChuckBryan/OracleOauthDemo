#!/bin/bash
# Script to check wallet files and permissions

WALLET_DIR="/etc/ora_wallet"

echo "===== Oracle Wallet Files Check ====="
echo "Checking wallet directory: $WALLET_DIR"

if [ -d "$WALLET_DIR" ]; then
  echo "✓ Wallet directory exists"
  
  # Check ownership and permissions
  ls -la "$WALLET_DIR"
  
  # Check if wallet files exist
  if [ -f "$WALLET_DIR/ewallet.p12" ]; then
    echo "✓ ewallet.p12 exists"
  else
    echo "✗ ewallet.p12 does not exist!"
  fi
  
  if [ -f "$WALLET_DIR/cwallet.sso" ]; then
    echo "✓ cwallet.sso exists"
  else
    echo "✗ cwallet.sso does not exist! This will cause UTL_HTTP wallet access failures."
    echo "   Run 'orapki wallet create -wallet $WALLET_DIR -pwd <password> -auto_login' to create SSO wallet"
  fi
  
  # Check certificate files
  echo -e "\nChecking certificate files:"
  if [ -d "$WALLET_DIR/certs" ]; then
    echo "✓ Certs directory exists"
    ls -la "$WALLET_DIR/certs"
    
    if [ -f "$WALLET_DIR/certs/openiddict-api.crt" ]; then
      echo "✓ Certificate file exists"
    else
      echo "✗ Certificate file does not exist!"
    fi
  else
    echo "✗ Certs directory does not exist!"
  fi
  
  # Verify wallet contents with orapki
  echo -e "\nWallet contents:"
  orapki wallet display -wallet "$WALLET_DIR"
  
  # Check if certificate is trusted in the wallet
  echo -e "\nChecking for trusted certificates in wallet:"
  orapki wallet display -wallet "$WALLET_DIR" | grep -i "trusted certificate"
else
  echo "✗ Wallet directory does not exist!"
fi