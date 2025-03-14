ALTER SESSION SET CONTAINER=FREEPDB1;

CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.test_api RETURN VARCHAR2 IS
  req   UTL_HTTP.req;
  resp  UTL_HTTP.resp;
  url   VARCHAR2(200) := 'https://openiddict-api:443/api/testapi';
  token VARCHAR2(4000);
  buf   VARCHAR2(32767);
  res   VARCHAR2(32767) := '';
BEGIN
  -- Get token using our minimal test function
  token := OAUTH_DEMO_USER.GET_ACCESS_TOKEN();
  
  -- Log the token
  DBMS_OUTPUT.PUT_LINE('Token received: ' || token);
  
  UTL_HTTP.set_wallet('file:/etc/ora_wallet', NULL);
  req := UTL_HTTP.begin_request(url, 'GET');
  UTL_HTTP.set_header(req, 'Authorization', 'Bearer ' || token);
  UTL_HTTP.set_header(req, 'Content-Type', 'application/json');
  resp := UTL_HTTP.get_response(req);
  
  BEGIN
    LOOP
      UTL_HTTP.read_text(resp, buf, 32767);
      res := res || buf;
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN NULL;
  END;
  
  UTL_HTTP.end_response(resp);
  RETURN res;
END test_api;
/

-- Simple test script with SERVEROUTPUT enabled
SET SERVEROUTPUT ON;
SELECT OAUTH_DEMO_USER.test_api() FROM DUAL;