ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create a convenience function that combines both steps
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.get_access_token RETURN VARCHAR2 AS
  json_response VARCHAR2(4000);
BEGIN
  -- Get the OAuth response
  json_response := OAUTH_DEMO_USER.oauth_request();
  
  -- Extract and return just the access token without any prefix
  RETURN OAUTH_DEMO_USER.extract_access_token(json_response);
END;
/
