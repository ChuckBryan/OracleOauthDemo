ALTER SESSION SET CONTAINER=FREEPDB1;

-- Verify OpenIddict ACL configuration
SELECT 'OpenIddict ACL Configuration' as check_type, host, lower_port, upper_port, acl
FROM dba_network_acls
WHERE acl = '/sys/acls/openiddict_acl.xml';

-- Verify SYS ACL privileges
SELECT 'SYS ACL Privileges' as check_type, 
       acl, principal, privilege, is_grant, invert
FROM dba_network_acl_privileges
WHERE acl = '/sys/acls/openiddict_acl.xml'
AND principal = 'SYS';

-- Verify OAUTH_DEMO_USER ACL privileges
SELECT 'OAUTH_DEMO_USER ACL Privileges' as check_type, 
       acl, principal, privilege, is_grant, invert
FROM dba_network_acl_privileges
WHERE acl = '/sys/acls/openiddict_acl.xml'
AND principal = 'OAUTH_DEMO_USER';

-- Verify UTL privileges
SELECT 'OAUTH_DEMO_USER UTL Privileges' as check_type,
       table_name, privilege
FROM dba_tab_privs
WHERE grantee = 'OAUTH_DEMO_USER'
AND table_name IN ('UTL_HTTP', 'UTL_URL');

-- Verify oauth_request function exists and is valid
SELECT 'OAuth Request Function Status' as check_type, 
       owner, object_name, status
FROM dba_objects
WHERE object_name = 'OAUTH_REQUEST'
AND owner = 'OAUTH_DEMO_USER'
AND object_type = 'FUNCTION';

-- Log startup verification
BEGIN
  dbms_output.put_line('OpenIddict ACL, SYS and OAUTH_DEMO_USER permissions, and oauth_request function verified at: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END;
/