ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create a function to call a protected API using the OAuth token
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.call_protected_api(
  api_url VARCHAR2 DEFAULT 'http://openiddict-api:80/api/testapi'
) RETURN VARCHAR2 AS
  http_req   UTL_HTTP.req;
  http_resp  UTL_HTTP.resp;
  token      VARCHAR2(4000);
  buffer     VARCHAR2(32767);
  response   VARCHAR2(32767) := '';
BEGIN
  -- Get the access token
  token := OAUTH_DEMO_USER.get_access_token();
  
  -- Check if token retrieval was successful
  IF SUBSTR(token, 1, 6) = 'ERROR:' THEN
    RETURN token; -- Return the error message
  END IF;
  
  -- Debug output
  DBMS_OUTPUT.PUT_LINE('Using token: ' || SUBSTR(token, 1, 30) || '...');
  
  -- Open HTTP request to the protected API
  http_req := UTL_HTTP.begin_request(api_url, 'GET', UTL_HTTP.http_version_1_1);

  -- Set Authorization header with bearer token
  UTL_HTTP.set_header(http_req, 'Authorization', 'Bearer ' || token);
  UTL_HTTP.set_header(http_req, 'Content-Type', 'application/json');

  -- Get the response
  http_resp := UTL_HTTP.get_response(http_req);
  
  -- Debug output
  DBMS_OUTPUT.PUT_LINE('Response status: ' || http_resp.status_code || ' ' || http_resp.reason_phrase);
  
  -- Read the response body
  BEGIN
    LOOP
      UTL_HTTP.read_text(http_resp, buffer, 32767);
      response := response || buffer;
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      NULL; -- Expected exception when reaching end of response body
  END;
  
  -- Close HTTP response
  UTL_HTTP.end_response(http_resp);

  RETURN response;
EXCEPTION
  WHEN OTHERS THEN
    -- Make sure to close the HTTP response if an error occurs
    IF http_resp.private_hndl IS NOT NULL THEN
      UTL_HTTP.end_response(http_resp);
    END IF;
    RETURN 'Error in API call: ' || SQLERRM;
END;
/

-- Create a convenience procedure to display the protected API response with DBMS_OUTPUT
-- Useful for interactive testing in SQL*Plus or similar tools
CREATE OR REPLACE PROCEDURE OAUTH_DEMO_USER.show_protected_api_response(
  api_url VARCHAR2 DEFAULT 'http://openiddict-api:80/api/testapi'
) AS
  response VARCHAR2(32767);
BEGIN
  -- Call the protected API
  response := OAUTH_DEMO_USER.call_protected_api(api_url);
  
  -- Print the response
  DBMS_OUTPUT.PUT_LINE('API Response:');
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE(response);
  DBMS_OUTPUT.PUT_LINE('------------');
END;
/

-- Grant execute privileges to public for demonstration purposes
-- In production, you would restrict this to specific users/roles
GRANT EXECUTE ON OAUTH_DEMO_USER.call_protected_api TO PUBLIC;
GRANT EXECUTE ON OAUTH_DEMO_USER.show_protected_api_response TO PUBLIC;

-- Example usage (commented out):
/*
-- To get the response as a string:
SELECT OAUTH_DEMO_USER.call_protected_api() FROM DUAL;

-- To display the response using DBMS_OUTPUT:
SET SERVEROUTPUT ON
EXEC OAUTH_DEMO_USER.show_protected_api_response();

-- To call a different protected API endpoint:
SELECT OAUTH_DEMO_USER.call_protected_api('http://openiddict-api:80/api/testapi/identity') FROM DUAL;
*/