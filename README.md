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
- PL/SQL function for OAuth token requests
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
- oauth_request function for token requests

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
- Create the oauth_request function

### Startup Scripts (/startup_scripts)

- Run on every container startup
- Verify ACL configurations
- Check user permissions
- Validate function availability

## Usage

### Making OAuth Requests

The oauth_request function can be called from PL/SQL to obtain OAuth tokens:

```sql
SELECT oauth_request() FROM DUAL;
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
