SELECT * FROM USER_ERRORS 
WHERE NAME = 'TEST_OAUTH'
ORDER BY SEQUENCE;

-- Also check original function errors
SELECT * FROM USER_ERRORS 
WHERE NAME = 'OAUTH_REQUEST'
ORDER BY SEQUENCE;