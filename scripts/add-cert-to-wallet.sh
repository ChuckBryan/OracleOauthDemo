#!/bin/bash

# Add the certificate to the Oracle Wallet
orapki wallet add -wallet /etc/ora_wallet -trusted_cert -cert /etc/ora_wallet/certs/openiddict-api.pem

# Optionally display the wallet contents to verify
orapki wallet display -wallet /etc/ora_wallet -pwd pa55w0rd!
