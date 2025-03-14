-- Active: 1741962351500@@127.0.0.1@1521@FREEPDB1@OAUTH_DEMO_USER
ALTER SESSION SET CONTAINER=FREEPDB1;

-- Drop existing ACL if it exists
BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl (
    acl => 'openiddict_acl.xml'
  );
EXCEPTION
  WHEN OTHERS THEN
    NULL; -- Ignore if the ACL doesn't exist
END;
/
