ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create a simpler function to extract the access token from the JSON response
-- Based on the actual JSON format seen in the response
CREATE OR REPLACE FUNCTION OAUTH_DEMO_USER.extract_access_token(json_response VARCHAR2) RETURN VARCHAR2 AS
  start_marker VARCHAR2(50) := '"access_token": "';
  token_start NUMBER;
  token_end NUMBER;
  access_token VARCHAR2(4000);
BEGIN
  -- Find the access_token marker in the JSON
  token_start := INSTR(json_response, start_marker);
  
  -- If found, extract the token
  IF token_start > 0 THEN
    -- Position after the marker
    token_start := token_start + LENGTH(start_marker);
    
    -- Find the closing quote
    token_end := INSTR(json_response, '"', token_start);
    
    IF token_end > 0 THEN
      -- Extract just the token
      access_token := SUBSTR(json_response, token_start, token_end - token_start);
      RETURN access_token; -- Return only the raw token value
    END IF;
  END IF;
  
  -- If we couldn't parse it with the expected format, try a more general approach
  DBMS_OUTPUT.PUT_LINE('Could not parse token using primary method, trying alternate method');
  
  -- Look for access_token in any format
  token_start := INSTR(LOWER(json_response), '"access_token"');
  IF token_start > 0 THEN
    -- Find the next colon
    token_start := INSTR(json_response, ':', token_start);
    IF token_start > 0 THEN
      -- Find the next quote
      token_start := INSTR(json_response, '"', token_start);
      IF token_start > 0 THEN
        -- Move past the opening quote
        token_start := token_start + 1;
        -- Find the closing quote
        token_end := INSTR(json_response, '"', token_start);
        IF token_end > 0 THEN
          access_token := SUBSTR(json_response, token_start, token_end - token_start);
          RETURN access_token; -- Return only the raw token value
        END IF;
      END IF;
    END IF;
  END IF;
  
  -- If all parsing attempts failed, return an error message without the prefix
  DBMS_OUTPUT.PUT_LINE('Failed to parse token from response');
  RETURN 'ERROR: ' || SUBSTR(json_response, 1, 300);
END;
/
