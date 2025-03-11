ALTER SESSION SET CONTAINER=FREEPDB1;

-- Drop existing ACL if it exists
BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl (
    acl => 'openiddict_acl.xml'
  );
EXCEPTION
  WHEN OTHERS THEN
    NULL; -- Ignore if the ACL doesn't exist
END;
/

-- Create ACL for OpenIddict API with both SYS and OAUTH_DEMO_USER permissions
BEGIN
  -- Create the ACL
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'openiddict_acl.xml',
    description  => 'ACL for OpenIddict API',
    principal    => 'SYS',
    is_grant     => TRUE,
    privilege    => 'connect'
  );

  -- Add resolve privilege for SYS
  DBMS_NETWORK_ACL_ADMIN.add_privilege(
    acl         => 'openiddict_acl.xml',
    principal   => 'SYS',
    is_grant    => TRUE,
    privilege   => 'resolve'
  );

  -- Add OAUTH_DEMO_USER to the ACL
  DBMS_NETWORK_ACL_ADMIN.add_privilege(
    acl         => 'openiddict_acl.xml',
    principal   => 'OAUTH_DEMO_USER',
    is_grant    => TRUE,
    privilege   => 'connect'
  );

  -- Add resolve privilege for OAUTH_DEMO_USER
  DBMS_NETWORK_ACL_ADMIN.add_privilege(
    acl         => 'openiddict_acl.xml',
    principal   => 'OAUTH_DEMO_USER',
    is_grant    => TRUE,
    privilege   => 'resolve'
  );

  -- Assign the ACL to the OpenIddict API host
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'openiddict_acl.xml',
    host        => 'openiddict-api'
  );
END;
/

-- Grant necessary UTL privileges to OAUTH_DEMO_USER
GRANT EXECUTE ON UTL_HTTP TO OAUTH_DEMO_USER;
GRANT EXECUTE ON UTL_URL TO OAUTH_DEMO_USER;

-- Create the oauth_request function under OAUTH_DEMO_USER schema
-- This function only handles the HTTP request
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.oauth_request RETURN VARCHAR2 AS
  http_req   UTL_HTTP.req;
  http_resp  UTL_HTTP.resp;
  url        VARCHAR2(200) := 'http://openiddict-api:80/connect/token';
  client_id  VARCHAR2(200) := 'test-client';
  client_secret VARCHAR2(200) := 'test-secret';
  params     VARCHAR2(400);
  buffer     VARCHAR2(2000);
BEGIN
  -- Prepare request parameters
  params := 'client_id='     || UTL_URL.escape(client_id, TRUE)      || '&' ||
            'client_secret=' || UTL_URL.escape(client_secret, TRUE)  || '&' ||
            'grant_type=client_credentials';
  -- Open HTTP request
  http_req := UTL_HTTP.begin_request(url, 'POST', UTL_HTTP.http_version_1_1);

  -- Set headers
  UTL_HTTP.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(http_req, 'Content-Length', LENGTH(params));

  -- Write parameters directly in the HTTP request body
  UTL_HTTP.write_text(http_req, params);

  -- Get the response
  http_resp := UTL_HTTP.get_response(http_req);
  UTL_HTTP.read_text(http_resp, buffer);

  -- Close HTTP response
  UTL_HTTP.end_response(http_resp);

  RETURN buffer; -- Return the full JSON response
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    RETURN 'Error occurred: ' || SQLERRM;
END;
/

-- Create a simpler function to extract the access token from the JSON response
-- Based on the actual JSON format seen in the response
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.extract_access_token(json_response VARCHAR2) RETURN VARCHAR2 AS
  start_marker VARCHAR2(50) := '"access_token": "';
  token_start NUMBER;
  token_end NUMBER;
  access_token VARCHAR2(4000);
BEGIN
  -- Find the access_token marker in the JSON
  token_start := INSTR(json_response, start_marker);
  
  -- If found, extract the token
  IF token_start > 0 THEN
    -- Position after the marker
    token_start := token_start + LENGTH(start_marker);
    
    -- Find the closing quote
    token_end := INSTR(json_response, '"', token_start);
    
    IF token_end > 0 THEN
      -- Extract just the token
      access_token := SUBSTR(json_response, token_start, token_end - token_start);
      RETURN access_token; -- Return only the raw token value
    END IF;
  END IF;
  
  -- If we couldn't parse it with the expected format, try a more general approach
  DBMS_OUTPUT.PUT_LINE('Could not parse token using primary method, trying alternate method');
  
  -- Look for access_token in any format
  token_start := INSTR(LOWER(json_response), '"access_token"');
  IF token_start > 0 THEN
    -- Find the next colon
    token_start := INSTR(json_response, ':', token_start);
    IF token_start > 0 THEN
      -- Find the next quote
      token_start := INSTR(json_response, '"', token_start);
      IF token_start > 0 THEN
        -- Move past the opening quote
        token_start := token_start + 1;
        -- Find the closing quote
        token_end := INSTR(json_response, '"', token_start);
        IF token_end > 0 THEN
          access_token := SUBSTR(json_response, token_start, token_end - token_start);
          RETURN access_token; -- Return only the raw token value
        END IF;
      END IF;
    END IF;
  END IF;
  
  -- If all parsing attempts failed, return an error message without the prefix
  DBMS_OUTPUT.PUT_LINE('Failed to parse token from response');
  RETURN 'ERROR: ' || SUBSTR(json_response, 1, 300);
END;
/

-- Create a convenience function that combines both steps
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.get_access_token RETURN VARCHAR2 AS
  json_response VARCHAR2(4000);
BEGIN
  -- Get the OAuth response
  json_response := OAUTH_DEMO_USER.oauth_request();
  
  -- Extract and return just the access token without any prefix
  RETURN OAUTH_DEMO_USER.extract_access_token(json_response);
END;
/