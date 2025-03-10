-- Simple script that gets an OAuth token and then calls httpbin.org/bearer with it
-- No procedures, just one anonymous PL/SQL block
-- Run this directly in SQL*Plus or SQL Developer

SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
  -- Variables for OAuth token request
  oauth_req       UTL_HTTP.req;
  oauth_resp      UTL_HTTP.resp;
  oauth_url       VARCHAR2(256) := 'https://localhost:7104/connect/token';
  request_body    VARCHAR2(500) := 'grant_type=client_credentials&client_id=test-client&client_secret=test-secret&scope=api';
  response_text   VARCHAR2(32767);
  line            VARCHAR2(32767);
  
  -- Variables for token extraction
  access_token    VARCHAR2(4000);
  token_start     NUMBER;
  token_end       NUMBER;
  
  -- Variables for httpbin request
  httpbin_req     UTL_HTTP.req;
  httpbin_resp    UTL_HTTP.resp;
  httpbin_url     VARCHAR2(256) := 'https://httpbin.org/bearer';
  
BEGIN
  -- STEP 1: Get OAuth token
  DBMS_OUTPUT.PUT_LINE('Step 1: Getting OAuth token from ' || oauth_url);
  
  -- Turn off error checking for HTTP errors
  UTL_HTTP.set_response_error_check(FALSE);
  
  -- Make the OAuth token request
  oauth_req := UTL_HTTP.begin_request(oauth_url, 'POST', 'HTTP/1.1');
  UTL_HTTP.set_header(oauth_req, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(oauth_req, 'Content-Length', LENGTH(request_body));
  UTL_HTTP.write_text(oauth_req, request_body);
  
  -- Get the response
  oauth_resp := UTL_HTTP.get_response(oauth_req);
  DBMS_OUTPUT.PUT_LINE('OAuth response status: ' || oauth_resp.status_code);
  
  -- Read the response
  response_text := '';
  BEGIN
    LOOP
      UTL_HTTP.read_line(oauth_resp, line, TRUE);
      response_text := response_text || line;
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      NULL; -- Expected exception
  END;
  
  -- Close the OAuth response
  UTL_HTTP.end_response(oauth_resp);
  
  -- Output the token response
  DBMS_OUTPUT.PUT_LINE('OAuth response: ' || response_text);
  
  -- Extract the access token from the JSON response
  IF oauth_resp.status_code = 200 THEN
    -- Simple JSON parsing to extract token
    token_start := INSTR(response_text, '"access_token":"') + 16;
    token_end := INSTR(SUBSTR(response_text, token_start), '"') + token_start - 1;
    access_token := SUBSTR(response_text, token_start, token_end - token_start);
    
    DBMS_OUTPUT.PUT_LINE('Access token: ' || access_token);
    
    -- STEP 2: Call httpbin.org with the token
    DBMS_OUTPUT.PUT_LINE('Step 2: Calling ' || httpbin_url || ' with the token');
    
    -- Make the httpbin request
    httpbin_req := UTL_HTTP.begin_request(httpbin_url, 'GET', 'HTTP/1.1');
    UTL_HTTP.set_header(httpbin_req, 'Authorization', 'Bearer ' || access_token);
    
    -- Get the response
    httpbin_resp := UTL_HTTP.get_response(httpbin_req);
    DBMS_OUTPUT.PUT_LINE('httpbin response status: ' || httpbin_resp.status_code);
    
    -- Read and display the response
    DBMS_OUTPUT.PUT_LINE('httpbin response:');
    BEGIN
      LOOP
        UTL_HTTP.read_line(httpbin_resp, line, TRUE);
        DBMS_OUTPUT.PUT_LINE(line);
      END LOOP;
    EXCEPTION
      WHEN UTL_HTTP.end_of_body THEN
        NULL; -- Expected exception
    END;
    
    -- Close the httpbin response
    UTL_HTTP.end_response(httpbin_resp);
    
  ELSE
    DBMS_OUTPUT.PUT_LINE('Failed to get OAuth token. Status: ' || oauth_resp.status_code);
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    
    -- Clean up if needed
    BEGIN
      IF UTL_HTTP.is_response_open(oauth_resp) THEN
        UTL_HTTP.end_response(oauth_resp);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
      IF UTL_HTTP.is_response_open(httpbin_resp) THEN
        UTL_HTTP.end_response(httpbin_resp);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
END;
/