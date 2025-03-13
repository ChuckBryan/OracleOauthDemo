ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create a convenience procedure to display the protected API response with DBMS_OUTPUT
-- Useful for interactive testing in SQL*Plus or similar tools
CREATE OR REPLACE PROCEDURE OAUTH_DEMO_USER.show_protected_api_response(
  api_url VARCHAR2 DEFAULT 'https://openiddict-api:443/api/testapi'
) AS
  response VARCHAR2(32767);
BEGIN
  -- Call the protected API
  response := OAUTH_DEMO_USER.call_protected_api(api_url);
  
  -- Print the response
  DBMS_OUTPUT.PUT_LINE('API Response:');
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE(response);
  DBMS_OUTPUT.PUT_LINE('------------');
END;
/