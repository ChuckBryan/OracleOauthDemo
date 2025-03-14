SET SERVEROUTPUT ON;
SET LINESIZE 1000;
SET LONG 1000000;
SET PAGESIZE 0;
SET VERIFY OFF;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Starting OAuth request test...');
  DBMS_OUTPUT.PUT_LINE('--------------------------');
  DBMS_OUTPUT.PUT_LINE(OAUTH_DEMO_USER.oauth_request());
  DBMS_OUTPUT.PUT_LINE('--------------------------');
END;
/