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

## Contributing

Feel free to submit issues and enhancement requests.
