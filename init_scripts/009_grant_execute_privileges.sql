ALTER SESSION SET CONTAINER=FREEPDB1;

-- Grant execute privileges to public for demonstration purposes
-- In production, you would restrict this to specific users/roles
GRANT EXECUTE ON OAUTH_DEMO_USER.call_protected_api TO PUBLIC;
GRANT EXECUTE ON OAUTH_DEMO_USER.show_protected_api_response TO PUBLIC;
