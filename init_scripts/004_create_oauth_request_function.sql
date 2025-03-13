ALTER SESSION SET CONTAINER=FREEPDB1;

CREATE OR REPLACE FUNCTION oauth_request RETURN VARCHAR2 AS
  http_req   UTL_HTTP.req;
  http_resp  UTL_HTTP.resp;
  url        VARCHAR2(200) := 'https://openiddict-api:443/connect/token';
  client_id  VARCHAR2(200) := 'test-client';
  client_secret VARCHAR2(200) := 'test-secret';
  params     VARCHAR2(400);
  buffer     VARCHAR2(32767);
  response   VARCHAR2(32767) := '';
  wallet_path VARCHAR2(200) := 'file:/etc/ora_wallet';
  err_code   NUMBER;
  err_msg    VARCHAR2(4000);
BEGIN
  -- Debug output for initial setup
  DBMS_OUTPUT.PUT_LINE('Starting oauth_request function...');

  -- Set wallet for HTTPS connection
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Setting wallet: ' || wallet_path);
    UTL_HTTP.set_wallet(wallet_path, NULL);
    DBMS_OUTPUT.PUT_LINE('Wallet set successfully');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error setting wallet: ' || SQLERRM);
      RAISE;
  END;

  -- Set detailed exception support and timeout
  UTL_HTTP.set_detailed_excp_support(TRUE);
  UTL_HTTP.set_transfer_timeout(60);
  
  -- Prepare request parameters
  params := 'client_id='     || UTL_URL.escape(client_id, TRUE)      || '&' ||
           'client_secret=' || UTL_URL.escape(client_secret, TRUE)  || '&' ||
           'grant_type=client_credentials'                          || '&' ||
           'scope=api';
            
  -- Debug output for request details
  DBMS_OUTPUT.PUT_LINE('Request URL: ' || url);
  DBMS_OUTPUT.PUT_LINE('Request parameters: ' || params);
  DBMS_OUTPUT.PUT_LINE('Content-Length: ' || LENGTH(params));
            
  -- Make the request
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Initializing HTTP request...');
    http_req := UTL_HTTP.begin_request(url, 'POST', UTL_HTTP.http_version_1_1);
    DBMS_OUTPUT.PUT_LINE('Request initialized successfully');
    
    -- Set headers
    UTL_HTTP.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
    UTL_HTTP.set_header(http_req, 'Content-Length', LENGTH(params));
    UTL_HTTP.set_header(http_req, 'Host', 'openiddict-api:443');
    UTL_HTTP.set_header(http_req, 'Accept', '*/*');
    UTL_HTTP.set_header(http_req, 'User-Agent', 'Oracle UTL_HTTP');
    DBMS_OUTPUT.PUT_LINE('Headers set successfully');

    -- Write request body
    DBMS_OUTPUT.PUT_LINE('Writing request body...');
    UTL_HTTP.write_text(http_req, params);
    DBMS_OUTPUT.PUT_LINE('Request body written successfully');

    -- Get response
    DBMS_OUTPUT.PUT_LINE('Getting response...');
    http_resp := UTL_HTTP.get_response(http_req);
    DBMS_OUTPUT.PUT_LINE('Response received. Status: ' || http_resp.status_code || ' ' || http_resp.reason_phrase);

    -- Read response headers
    FOR i IN 1..UTL_HTTP.get_header_count(http_resp) LOOP
      UTL_HTTP.get_header(http_resp, i, err_msg, buffer);
      DBMS_OUTPUT.PUT_LINE('Response header ' || i || ': ' || err_msg || ': ' || buffer);
    END LOOP;

    -- Read response body
    DBMS_OUTPUT.PUT_LINE('Reading response body...');
    BEGIN
      LOOP
        UTL_HTTP.read_text(http_resp, buffer, 32767);
        response := response || buffer;
        DBMS_OUTPUT.PUT_LINE('Read chunk: ' || SUBSTR(buffer, 1, 255));
      END LOOP;
    EXCEPTION
      WHEN UTL_HTTP.end_of_body THEN
        DBMS_OUTPUT.PUT_LINE('Finished reading response body');
        NULL;
    END;

    -- Close response
    UTL_HTTP.end_response(http_resp);
    DBMS_OUTPUT.PUT_LINE('Response closed successfully');
    
    -- Debug final response
    DBMS_OUTPUT.PUT_LINE('Final response length: ' || LENGTH(response));
    DBMS_OUTPUT.PUT_LINE('Final response (first 255 chars): ' || SUBSTR(response, 1, 255));
    
    RETURN response;
    
  EXCEPTION
    WHEN OTHERS THEN
      err_code := SQLCODE;
      err_msg := SQLERRM;
      DBMS_OUTPUT.PUT_LINE('Error in request: ' || err_code || ': ' || err_msg);
      RAISE;
  END;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Clean up if needed
    IF http_resp.private_hndl IS NOT NULL THEN
      UTL_HTTP.end_response(http_resp);
    END IF;
    -- Log and return error
    err_msg := SQLERRM;
    DBMS_OUTPUT.PUT_LINE('Final error: ' || err_msg);
    RETURN '{"error":"' || REPLACE(err_msg, '"', '\"') || '"}';
END;
/
