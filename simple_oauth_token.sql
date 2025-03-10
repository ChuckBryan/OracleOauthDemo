-- Simple script to get OAuth token
-- Run this as a complete script in SQL*Plus or other Oracle client

-- First, ensure the procedure doesn't exist already
BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE simple_oauth_token';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN  -- -4043 is "does not exist"
      RAISE;
    END IF;
END;
/

-- Create a simple procedure to get an OAuth token
CREATE OR REPLACE PROCEDURE simple_oauth_token IS
  l_request  UTL_HTTP.req;
  l_response UTL_HTTP.resp;
  l_text     VARCHAR2(32767);
BEGIN
  -- Set response error checking off to handle HTTP errors
  UTL_HTTP.set_response_error_check(FALSE);
  
  -- Uncomment and modify if you need a wallet for SSL
  -- UTL_HTTP.set_wallet('file:/path/to/wallet', 'password');
  
  DBMS_OUTPUT.PUT_LINE('Starting OAuth token request...');
  
  -- Begin HTTP request
  l_request := UTL_HTTP.begin_request(
    url => 'https://localhost:7104/connect/token',
    method => 'POST',
    http_version => 'HTTP/1.1'
  );
  
  -- Set headers
  UTL_HTTP.set_header(l_request, 'Content-Type', 'application/x-www-form-urlencoded');
  
  -- Set up the request body
  UTL_HTTP.set_header(l_request, 'Content-Length', '73');
  UTL_HTTP.write_text(l_request, 'grant_type=client_credentials&client_id=test-client&client_secret=test-secret&scope=api');
  
  DBMS_OUTPUT.PUT_LINE('Request sent, getting response...');
  
  -- Get response
  l_response := UTL_HTTP.get_response(l_request);
  
  DBMS_OUTPUT.PUT_LINE('Response status: ' || l_response.status_code);
  
  -- Read and display response
  BEGIN
    LOOP
      UTL_HTTP.read_line(l_response, l_text, TRUE);
      DBMS_OUTPUT.PUT_LINE(l_text);
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      NULL; -- Expected end of response
  END;
  
  -- Always close the response
  UTL_HTTP.end_response(l_response);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    -- Clean up if error occurs
    IF UTL_HTTP.is_response_open(l_response) THEN
      UTL_HTTP.end_response(l_response);
    END IF;
END simple_oauth_token;
/

-- Execute the procedure
BEGIN
  simple_oauth_token();
END;
/