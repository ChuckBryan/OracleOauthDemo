ALTER SESSION SET CONTAINER=FREEPDB1;

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
