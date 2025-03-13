ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create a function to call a protected API using the OAuth token
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.call_protected_api(
  api_url VARCHAR2 DEFAULT 'https://openiddict-api:443/api/testapi'
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
  
  -- Set wallet for HTTPS connection with auto-login (no password needed)
  UTL_HTTP.set_wallet('file:/etc/ora_wallet', NULL);
  
  -- Open HTTP request to the protected API
  http_req := UTL_HTTP.begin_request(api_url, 'GET', UTL_HTTP.http_version_1_1);

  -- Set Authorization header with bearer token
  UTL_HTTP.set_header(http_req, 'Authorization', 'Bearer ' || token);
  UTL_HTTP.set_header(http_req, 'Content-Type', 'application/json');
  UTL_HTTP.set_header(http_req, 'Host', 'openiddict-api:443');  -- Added Host header with correct port

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
