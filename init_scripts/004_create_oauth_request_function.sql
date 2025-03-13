ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create the oauth_request function under OAUTH_DEMO_USER schema
-- This function only handles the HTTP request
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.oauth_request RETURN VARCHAR2 AS
  http_req   UTL_HTTP.req;
  http_resp  UTL_HTTP.resp;
  url        VARCHAR2(200) := 'https://openiddict-api:443/connect/token';
  client_id  VARCHAR2(200) := 'test-client';
  client_secret VARCHAR2(200) := 'test-secret';
  params     VARCHAR2(400);
  buffer     VARCHAR2(2000);
  wallet_path VARCHAR2(200) := 'file:/etc/ora_wallet';
  err_code   NUMBER;
  err_msg    VARCHAR2(4000);
BEGIN
  -- Set detailed debugging
  UTL_HTTP.set_detailed_excp_support(TRUE);
  
  -- Set wallet for HTTPS connection with auto-login (no password needed)
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Setting wallet: ' || wallet_path);
    UTL_HTTP.set_wallet(wallet_path, NULL);
    DBMS_OUTPUT.PUT_LINE('Wallet set successfully');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error setting wallet: ' || SQLERRM);
      RAISE;
  END;

  -- Prepare request parameters
  params := 'client_id='     || UTL_URL.escape(client_id, TRUE)      || '&' ||
            'client_secret=' || UTL_URL.escape(client_secret, TRUE)  || '&' ||
            'grant_type=client_credentials';
            
  -- Debug output
  DBMS_OUTPUT.PUT_LINE('Making request to: ' || url);
  DBMS_OUTPUT.PUT_LINE('With parameters: ' || SUBSTR(params, 1, 50) || '...');
  
  -- Open HTTP request
  http_req := UTL_HTTP.begin_request(url, 'POST', UTL_HTTP.http_version_1_1);

  -- Set headers
  UTL_HTTP.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
  UTL_HTTP.set_header(http_req, 'Content-Length', LENGTH(params));

  -- Write parameters directly in the HTTP request body
  UTL_HTTP.write_text(http_req, params);

  -- Get the response
  http_resp := UTL_HTTP.get_response(http_req);
  DBMS_OUTPUT.PUT_LINE('Response received: ' || http_resp.status_code || ' ' || http_resp.reason_phrase);
  
  UTL_HTTP.read_text(http_resp, buffer);

  -- Close HTTP response
  UTL_HTTP.end_response(http_resp);

  RETURN buffer; -- Return the full JSON response
EXCEPTION
  WHEN OTHERS THEN
    -- Make sure to close the HTTP response if opened
    BEGIN
      IF http_resp.private_hndl IS NOT NULL THEN
        UTL_HTTP.end_response(http_resp);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Ignore error in cleanup
    END;
    
    -- Get error details
    err_code := SQLCODE;
    err_msg := SQLERRM;
    
    -- Provide detailed error message
    DBMS_OUTPUT.PUT_LINE('Error ' || err_code || ': ' || err_msg);
    
    -- For ORA-28759: failure to open file
    IF err_code = -28759 THEN
      DBMS_OUTPUT.PUT_LINE('Wallet file access error. Check:');
      DBMS_OUTPUT.PUT_LINE('1. Wallet path: ' || wallet_path);
      DBMS_OUTPUT.PUT_LINE('2. File permissions');
      DBMS_OUTPUT.PUT_LINE('3. Whether cwallet.sso exists at this location');
    END IF;
    
    RETURN 'Error occurred: ' || err_msg;
END;
/
