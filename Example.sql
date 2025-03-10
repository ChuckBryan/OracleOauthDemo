BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl (
    acl => 'openiddict_acl.xml'
  );
EXCEPTION
  WHEN OTHERS THEN
    NULL; -- Ignore if the ACL doesn't exist
END;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'openiddict_acl.xml',
    description  => 'ACL for OpenIddict API',
    principal    => 'SYS',
    is_grant     => TRUE,
    privilege    => 'connect'
  );

  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'openiddict_acl.xml',
    host        => 'openiddict-api'
  );
END;
/

CREATE OR REPLACE FUNCTION oauth_request RETURN VARCHAR2 AS
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
  -- Open HTTP request THIS WORKS
  http_req := UTL_HTTP.begin_request(url, 'POST', UTL_HTTP.http_version_1_1);

  -- Set headers
  UTL_HTTP.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(http_req, 'Content-Length', LENGTH(params)); -- Length of 'client_id=test-client&client_secret=test-secret&grant_type=client_credentials'

  -- Write parameters directly in the HTTP request body
  UTL_HTTP.write_text(http_req, params);

  -- Get the response
  http_resp := UTL_HTTP.get_response(http_req);
  UTL_HTTP.read_text(http_resp, buffer);

  -- Close HTTP response
  UTL_HTTP.end_response(http_resp);

  RETURN buffer; -- Return response as a string
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    RETURN 'Error occurred';
END;
/
DECLARE
  l_token VARCHAR2(32767);
BEGIN
  l_token := oauth_request;
  DBMS_OUTPUT.put_line('Access Token: ' || l_token);
END;
/