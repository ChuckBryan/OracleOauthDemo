ALTER SESSION SET CONTAINER=FREEPDB1;

-- Create ACL for OpenIddict API with both SYS and OAUTH_DEMO_USER permissions
BEGIN
  -- Create the ACL
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'openiddict_acl.xml',
    description  => 'ACL for OpenIddict API',
    principal    => 'SYS',
    is_grant     => TRUE,
    privilege    => 'connect'
  );

  -- Add resolve privilege for SYS
  DBMS_NETWORK_ACL_ADMIN.add_privilege(
    acl         => 'openiddict_acl.xml',
    principal   => 'SYS',
    is_grant    => TRUE,
    privilege   => 'resolve'
  );

  -- Add OAUTH_DEMO_USER to the ACL
  DBMS_NETWORK_ACL_ADMIN.add_privilege(
    acl         => 'openiddict_acl.xml',
    principal   => 'OAUTH_DEMO_USER',
    is_grant    => TRUE,
    privilege   => 'connect'
  );

  -- Add resolve privilege for OAUTH_DEMO_USER
  DBMS_NETWORK_ACL_ADMIN.add_privilege(
    acl         => 'openiddict_acl.xml',
    principal   => 'OAUTH_DEMO_USER',
    is_grant    => TRUE,
    privilege   => 'resolve'
  );

  -- Assign the ACL to the OpenIddict API host
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'openiddict_acl.xml',
    host        => 'openiddict-api'
  );
END;
/
