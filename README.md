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

- Docker and Docker Compose
- Oracle Database container support
- .NET SDK (for local development)

## Getting Started

1. Clone the repository
2. Run `docker-compose up`
3. Wait for initialization scripts to complete
4. Access the OpenIddict API at http://localhost:5112

## Contributing

Feel free to submit issues and enhancement requests.
