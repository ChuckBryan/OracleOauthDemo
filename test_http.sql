-- Simple test to check if Oracle can make HTTP requests
SET SERVEROUTPUT ON;

DECLARE
  req  UTL_HTTP.req;
  resp UTL_HTTP.resp;
  line VARCHAR2(32767);
BEGIN
  UTL_HTTP.set_response_error_check(FALSE);
  DBMS_OUTPUT.PUT_LINE('Starting HTTP test...');
  
  req := UTL_HTTP.begin_request('http://localhost:5112');
  resp := UTL_HTTP.get_response(req);
  
  DBMS_OUTPUT.PUT_LINE('Response status: ' || resp.status_code);
  
  -- Read response
  BEGIN
    LOOP
      UTL_HTTP.read_line(resp, line, TRUE);
      DBMS_OUTPUT.PUT_LINE(line);
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      NULL;
  END;
  
  UTL_HTTP.end_response(resp);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF UTL_HTTP.is_response_open(resp) THEN
      UTL_HTTP.end_response(resp);
    END IF;
END;
/