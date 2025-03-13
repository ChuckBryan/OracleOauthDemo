-- Test script to only retrieve the OAuth token
-- This can be executed in any SQL client (DBeaver, SQL Developer, VS Code, etc.)

-- Step 1: Test OAuth Token Functionality
-- =====================================

-- Test to get just the raw JSON response from the OAuth server
SELECT OAUTH_DEMO_USER.oauth_request() AS raw_oauth_response FROM DUAL;

-- Test to get just the access token using the convenience function
-- This makes the OAuth request and extracts the token in one step
SELECT OAUTH_DEMO_USER.get_access_token() AS access_token FROM DUAL;

-- Step 2: Test Protected API Call
-- ==============================
-- Now that we confirmed token retrieval works, let's test calling the protected API
-- Execute this after confirming the above token tests work

-- Test the call_protected_api function
SELECT OAUTH_DEMO_USER.call_protected_api() FROM DUAL;