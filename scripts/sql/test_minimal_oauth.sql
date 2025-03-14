ALTER SESSION SET CONTAINER=FREEPDB1;

CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.test_oauth RETURN VARCHAR2 IS
  req   UTL_HTTP.req;
  resp  UTL_HTTP.resp;
  url   VARCHAR2(200) := 'https://openiddict-api:443/connect/token';
  body  VARCHAR2(400) := 'grant_type=client_credentials&client_id=test-client&client_secret=test-secret&scope=api';
  buf   VARCHAR2(32767);
  res   VARCHAR2(32767) := '';
BEGIN
  UTL_HTTP.set_wallet('file:/etc/ora_wallet', NULL);
  req := UTL_HTTP.begin_request(url, 'POST');
  UTL_HTTP.set_header(req, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(req, 'Content-Length', LENGTH(body));
  UTL_HTTP.write_text(req, body);
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
END test_oauth;
/

-- Test the function
SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE(OAUTH_DEMO_USER.test_oauth());
END;
/