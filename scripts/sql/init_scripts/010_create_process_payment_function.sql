ALTER SESSION SET CONTAINER=FREEPDB1;

CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.process_payment(p_payload IN CLOB) RETURN VARCHAR2 IS
  req   UTL_HTTP.req;
  resp  UTL_HTTP.resp;
  url   VARCHAR2(200) := 'https://openiddict-api:443/api/Payment';
  token VARCHAR2(4000);
  buf   VARCHAR2(32767);
  res   VARCHAR2(32767) := '';
  content_length NUMBER;
BEGIN
  -- Get token using our existing function
  token := OAUTH_DEMO_USER.GET_ACCESS_TOKEN();
  
  -- Log the token
  DBMS_OUTPUT.PUT_LINE('Token received: ' || token);
  
  -- Get content length of payload
  content_length := DBMS_LOB.GETLENGTH(p_payload);
  
  UTL_HTTP.set_wallet('file:/etc/ora_wallet', NULL);
  req := UTL_HTTP.begin_request(url, 'POST');
  UTL_HTTP.set_header(req, 'Authorization', 'Bearer ' || token);
  UTL_HTTP.set_header(req, 'Content-Type', 'application/json');
  UTL_HTTP.set_header(req, 'Content-Length', content_length);
  
  -- Write the payload
  UTL_HTTP.write_text(req, p_payload);
  
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
END process_payment;
/

-- Grant execute privilege
GRANT EXECUTE ON OAUTH_DEMO_USER.process_payment TO PUBLIC;
