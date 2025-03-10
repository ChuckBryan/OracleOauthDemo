-- Simple anonymous PL/SQL block to get OAuth token
-- Just run this script directly in SQL*Plus or SQL Developer

SET SERVEROUTPUT ON;

DECLARE
  req             UTL_HTTP.req;
  resp            UTL_HTTP.resp;
  url             VARCHAR2(256) := 'http://openiddict-api/connect/token';  -- Using container hostname
  request_body    VARCHAR2(500) := 'grant_type=client_credentials&client_id=test-client&client_secret=test-secret&scope=api';
  response_text   VARCHAR2(32767);
  line            VARCHAR2(32767);
BEGIN
  -- Turn off error checking to handle HTTP errors
  UTL_HTTP.set_response_error_check(FALSE);
  
  -- Make the HTTP request
  req := UTL_HTTP.begin_request(url, 'POST', 'HTTP/1.1');
  UTL_HTTP.set_header(req, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(req, 'Content-Length', LENGTH(request_body));
  UTL_HTTP.write_text(req, request_body);
  
  -- Get the response
  resp := UTL_HTTP.get_response(req);
  
  DBMS_OUTPUT.PUT_LINE('Response status: ' || resp.status_code);
  
  -- Read the response
  response_text := '';
  BEGIN
    LOOP
      UTL_HTTP.read_line(resp, line, TRUE);
      response_text := response_text || line;
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      NULL;
  END;
  
  -- Close the response
  UTL_HTTP.end_response(resp);
  
  -- Output the token response
  DBMS_OUTPUT.PUT_LINE('Response: ' || response_text);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF UTL_HTTP.is_response_open(resp) THEN
      UTL_HTTP.end_response(resp);
    END IF;
END;
/
