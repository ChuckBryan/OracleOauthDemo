# Oracle OAuth Demo with OpenIddict

## Project Overview

This project demonstrates integration between Oracle Database and OpenIddict for OAuth 2.0 client credentials flow. It showcases how to make authenticated API calls from Oracle PL/SQL to an OpenIddict-based OAuth endpoint.

## Key Features

- Oracle Database PL/SQL integration with OAuth 2.0
- OpenIddict OAuth 2.0 server implementation
- Client Credentials flow demonstration
- Docker containerization for both Oracle and OpenIddict services
- Automated database initialization and configuration

## Technical Components

### Oracle Database Setup

- Automated initialization scripts for database configuration
- Network ACL setup for secure API communication
- PL/SQL functions for OAuth token requests and parsing
- Automated user creation and permission management

### OpenIddict API

- .NET-based OAuth 2.0 authorization server
- Client credentials flow implementation
- Dockerized deployment
- Test API endpoints for validation

## Configuration

### Database Initialization

The project uses Docker initialization scripts to automatically configure:

- Database user creation (OAUTH_DEMO_USER)
- Network ACL permissions for API access
- UTL_HTTP and UTL_URL grants
- PL/SQL functions for OAuth operations

### Environment Setup

```yaml
services:
  oracle:
    environment:
      - ORACLE_RANDOM_PASSWORD=yes # Generates random SYS/SYSTEM passwords
      - APP_USER=OAUTH_DEMO_USER # Creates demo user
      - APP_USER_PASSWORD=DemoPassword123
```

### Security Note

⚠️ **Important:** The credentials used in this demo are for demonstration purposes only. In a production environment:

- Use secure credential management
- Don't store passwords in code or configuration files
- Implement proper security measures

## Initialization and Startup Scripts

The project includes two types of scripts:

### Initialization Scripts (/init_scripts)

- Run once during first-time database setup
- Configure ACLs, users, and permissions
- Create PL/SQL functions in the OAUTH_DEMO_USER schema
- Set up token request and parsing capabilities

### Startup Scripts (/startup_scripts)

- Run on every container startup
- Verify ACL configurations
- Check user permissions
- Validate function availability

## Usage

### PL/SQL Functions Overview

All the following functions are created in the **OAUTH_DEMO_USER schema** (not as SYS):

1. **oauth_request** - Makes the HTTP request to the OAuth server

   ```sql
   SELECT OAUTH_DEMO_USER.oauth_request() FROM DUAL;
   ```

   Returns the raw JSON response from the OAuth server.

2. **extract_access_token** - Parses the JSON response to extract just the access token
   ```sql
   SELECT OAUTH_DEMO_USER.extract_access_token(json_response) FROM DUAL;
   ```
3. **get_access_token** - Convenience function that combines the above two functions
   ```sql
   SELECT OAUTH_DEMO_USER.get_access_token() FROM DUAL;
   ```
   Returns only the access token value, ready for use in API calls.

### Making OAuth Requests

To get an access token for API calls:

```sql
-- Get the raw JSON response
SELECT OAUTH_DEMO_USER.oauth_request() FROM DUAL;

-- Parse a JSON response to extract the token
SELECT OAUTH_DEMO_USER.extract_access_token('{"access_token":"token-value"}') FROM DUAL;

-- Get just the access token directly
SELECT OAUTH_DEMO_USER.get_access_token() FROM DUAL;
```

### Using the Access Token with APIs

Once you have the access token, you can use it in subsequent API calls:

```sql
DECLARE
  token VARCHAR2(4000);
BEGIN
  -- Get the token
  token := OAUTH_DEMO_USER.get_access_token();

  -- Use the token in an API call
  -- Implementation depends on your specific API requirements
END;
```

## Prerequisites

### Required Software

- Docker Desktop
  - Must be installed and running
  - Windows or Linux containers supported
  - Minimum 4GB of memory allocated to Docker
- .NET SDK (for local development)
- Oracle Database container support
- SQL client (DBeaver, SQL Developer, or VS Code with Oracle extension)

### System Requirements

- Minimum 8GB RAM
- 10GB free disk space
- Internet connection for pulling Docker images

## Docker Commands

### Starting the Environment

```bash
# Start all services
docker-compose up

# Start in detached mode (run in background)
docker-compose up -d
```

### Stopping the Environment

```bash
# Stop and remove containers
docker-compose down

# Stop, remove containers, and remove volumes
docker-compose down -v
```

### Managing Oracle Data Volume

```bash
# Remove Oracle data volume (required for database initialization changes)
docker volume rm oracleoauthdemo_oracle-data
```

⚠️ **Important Note**: If you need to modify any database initialization scripts or change how the database is configured, you must:

1. Stop all containers (`docker-compose down`)
2. Remove the Oracle data volume (`docker volume rm oracleoauthdemo_oracle-data`)
3. Start the environment again (`docker-compose up`)

## SQL Implementation Details

### Network ACL Setup

```sql
-- Creates network access control for OpenIddict API connections
DBMS_NETWORK_ACL_ADMIN.create_acl (
  acl          => 'openiddict_acl.xml',
  description  => 'ACL for OpenIddict API',
  principal    => 'OAUTH_DEMO_USER',
  is_grant     => TRUE,
  privilege    => 'connect'
);
```

This ACL configuration allows the OAUTH_DEMO_USER to make HTTP connections to the OpenIddict API.

### OAuth Request Function

```sql
-- Function to obtain OAuth token
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.oauth_request RETURN VARCHAR2 AS
  -- Function variables
  http_req   UTL_HTTP.req;
  http_resp  UTL_HTTP.resp;

  -- OAuth endpoint configuration
  url        VARCHAR2(200) := 'http://openiddict-api:80/connect/token';
  client_id  VARCHAR2(200) := 'test-client';
  client_secret VARCHAR2(200) := 'test-secret';

  -- Function implementation
  // ...implementation details...
END;
```

This function handles the HTTP POST request to obtain an OAuth token using client credentials flow.

### Token Extraction Function

```sql
-- Function to parse JSON and extract access token
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.extract_access_token(
  json_response VARCHAR2
) RETURN VARCHAR2 AS
  -- Implementation parses JSON response to extract token
  // ...implementation details...
END;
```

Extracts the access token from the OAuth server's JSON response.

### Convenience Function

```sql
-- Combined function for easy token retrieval
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.get_access_token RETURN VARCHAR2 AS
  -- Combines oauth_request and extract_access_token
  json_response VARCHAR2(4000);
BEGIN
  json_response := OAUTH_DEMO_USER.oauth_request();
  RETURN OAUTH_DEMO_USER.extract_access_token(json_response);
END;
```

Provides a simplified interface for obtaining an access token in a single function call.

### Protected API Access Function

```sql
-- Function to call protected APIs using OAuth token
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.call_protected_api(
  api_url VARCHAR2 DEFAULT 'http://openiddict-api:80/api/testapi'
) RETURN VARCHAR2 AS
  -- Makes authenticated API calls using the OAuth token
  // ...implementation details...
END;
```

Demonstrates how to use the obtained OAuth token to make authenticated API calls.

## Getting Started

1. Clone the repository
2. Run `docker-compose up`
3. Wait for initialization scripts to complete
4. Access the OpenIddict API at http://localhost:5112

## Setting Up HTTPS in Docker

### Overview

This project supports HTTPS in Docker containers, which is essential for secure API communication. Below are the steps taken to enable HTTPS support.

### Steps to Enable HTTPS

1. **Generate a Development Certificate**

   ```powershell
   dotnet dev-certs https -ep "$env:USERPROFILE\.aspnet\https\OpenIddictDemo.pfx" -p pa55w0rd!
   dotnet dev-certs https --trust
   ```

   This creates a self-signed certificate specifically named after the project's entry point assembly.

2. **Add UserSecretsId to the Project File**

   ```xml
   <UserSecretsId>open-iddict-demo-027313c3-0f57-44de-bbec-66690428a034</UserSecretsId>
   ```

   This enables secure storage of sensitive configuration values.

3. **Store Certificate Password in User Secrets**

   ```powershell
   dotnet user-secrets set "Kestrel:Certificates:Default:Password" "pa55w0rd!"
   ```

   This securely stores the certificate password without hardcoding it in configuration files.

4. **Configure Docker Compose for HTTPS**
   The `docker-compose.yml` file includes:

   ```yaml
   openiddict-api:
     // ...other settings...
     ports:
       - "5112:80"
       - "7104:443"
     environment:
       - USER_SECRETS_ID=open-iddict-demo-027313c3-0f57-44de-bbec-66690428a034
       - ASPNETCORE_ENVIRONMENT=Development
       - ASPNETCORE_URLS=https://+:443;http://+:80
       - ASPNETCORE_Kestrel__Certificates__Default__Path=/https/OpenIddictDemo.pfx
     volumes:
       - ~/.aspnet/https:/https:ro
       - ~/APPDATA/Roaming/microsoft/UserSecrets:/root/.microsoft/usersecrets:ro
   ```

   This configuration:

   - Maps both HTTP and HTTPS ports
   - Sets the certificate path in the container
   - Mounts certificate and user secrets volumes

5. **Build and Run the Container**
   ```powershell
   docker build -f OpenIddictDemo/Dockerfile -t openiddictdemo .
   docker-compose up -d openiddict-api
   ```

### Accessing the API

- HTTP: http://localhost:5112
- HTTPS: https://localhost:7104

### References

- [Official Microsoft Documentation: Hosting ASP.NET Core images with Docker Compose over HTTPS](https://learn.microsoft.com/en-us/aspnet/core/security/docker-compose-https?view=aspnetcore-9.0)
- [YouTube Tutorial: How to add HTTPS to a .NET Docker Container](https://www.youtube.com/watch?v=lcaDDxJv260)

## Oracle Wallet Configuration for HTTPS

### Overview

The project uses Oracle Wallet to securely store certificates and enable HTTPS communication between the Oracle database and the OpenIddict API. This section explains how the wallet is configured and how to troubleshoot common issues.

### Wallet Directory Structure

The wallet is stored in the `/etc/ora_wallet` directory inside the Oracle container and is mounted from the host's `./wallet` directory. The structure is as follows:

```
wallet/
├── cwallet.sso          # Auto-login wallet file (required for UTL_HTTP with HTTPS)
├── ewallet.p12          # Password-protected wallet file
├── certs/               # Contains certificates
│   ├── openiddict-api.crt  # Certificate file
│   ├── openiddict-api.pem  # Private key file
│   └── openiddict-api.pfx  # Combined certificate and key (PKCS#12)
└── scripts/             # Scripts for wallet management
    ├── create_wallet.sh
    ├── add-cert-to-wallet.sh
    ├── verify_wallet.sh
    └── check_wallet_files.sh
```

### Key Scripts

1. **create_wallet.sh**: Creates the Oracle Wallet with auto-login enabled

   ```bash
   # Main operations performed:
   orapki wallet create -wallet /etc/ora_wallet -pwd <password> -auto_login
   ```

2. **add-cert-to-wallet.sh**: Adds the OpenIddict API certificate to the wallet

   ```bash
   # Main operations performed:
   orapki wallet add -wallet /etc/ora_wallet -trusted_cert -cert /etc/ora_wallet/certs/openiddict-api.crt -pwd <password>
   ```

3. **check_wallet_files.sh**: Diagnostics script to verify wallet configuration
   ```bash
   # Checks for:
   # - Wallet directory and file existence
   # - Certificate presence
   # - Permissions
   # - Trusted certificates
   ```

### Important Notes

1. **Auto-login SSO Wallet File**: The `cwallet.sso` file is critical for UTL_HTTP to work with HTTPS. Without this file, you'll get the error `ORA-28759: failure to open file`.

2. **Certificate Requirements**: The certificate's Common Name (CN) must match the hostname used in the connection URL (in this case, 'openiddict-api').

3. **Permissions**: When running in Docker, file permissions are important. The Oracle user must have read access to the wallet files.

### PL/SQL Function Configuration

The `oauth_request` function is configured to use the wallet:

```sql
-- Setting up the wallet in PL/SQL
UTL_HTTP.set_wallet('file:/etc/ora_wallet', NULL);
```

### Troubleshooting Wallet Issues

1. **ORA-28759: failure to open file**

   - Ensure `cwallet.sso` exists in the wallet directory
   - Verify the wallet path is correct: `file:/etc/ora_wallet`
   - Check file permissions

2. **ORA-29024: Certificate validation failure**

   - Certificate may not be properly imported as a trusted certificate
   - Run `add-cert-to-wallet.sh` to properly add the certificate

3. **ORA-29273: HTTP request failed**
   - Certificate CN may not match hostname
   - Network connectivity issues
   - SSL/TLS version incompatibility

### Creating a New Certificate

If you need to create a new certificate with a specific CN:

```bash
# Example of creating a self-signed certificate with OpenSSL
openssl req -x509 -newkey rsa:4096 -keyout openiddict-api.pem -out openiddict-api.crt -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=openiddict-api"
```

### Docker Compose Configuration

The `docker-compose.yml` mounts the required directories:

```yaml
volumes:
  - ./wallet:/etc/ora_wallet
  - ./certs:/etc/ora_wallet/certs
  - ./scripts:/etc/ora_wallet/scripts
```

### Running the Wallet Setup

To initialize or update the wallet:

1. Create the wallet structure on the host
2. Place certificates in the `certs` directory
3. Run the setup scripts in the Oracle container:

   ```bash
   docker exec -it oracle bash -c "cd /etc/ora_wallet/scripts && ./create_wallet.sh && ./add-cert-to-wallet.sh && ./check_wallet_files.sh"
   ```

## Certificates and Scripts

### Certificates Directory

The `certs` directory contains the following files:

- `openiddict-api.crt`: The public certificate file.
- `openiddict-api.pem`: The private key file.
- `openiddict-api.pfx`: The combined certificate and private key file in PKCS#12 format.

These certificates are used to secure the OpenIddict API with HTTPS. The certificates were created using OpenSSL to specify the Common Name (CN).

### Scripts Directory

The `scripts` directory contains the following files:

- `add-cert-to-wallet.sh`: Script to add the certificate to the Oracle wallet.
- `create_wallet.sh`: Script to create a new Oracle wallet.
- `verify_wallet.sh`: Script to verify the contents of the Oracle wallet.

These scripts are used to create the Oracle wallet and import the certificate that was exported from the API.

### Note on Certificate Creation

The certificates were created using OpenSSL instead of the .NET dev-certs tool to allow specifying the Common Name (CN).

## Contributing

Feel free to submit issues and enhancement requests.
