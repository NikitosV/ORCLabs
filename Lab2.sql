ALTER SESSION SET "_ORACLE_SCRIPT" = true; -- ��� ���� ������� �� ��������
select * from V$SERVICES;
-- task1(��������� ������������ ��� ���������� ������)---------------------------------------------------
CREATE TABLESPACE TS_VNA -- ������� 
 DATAFILE 'TS_VNA_TEMP' 
    SIZE 7M
    REUSE
    AUTOEXTEND ON NEXT 5M MAXSIZE 20M;
    
DROP TABLESPACE TS_VNA; -- �������

-- task2(��������� ������������ ��� ��������� ������)----------------------------------------------------
CREATE TEMPORARY TABLESPACE TS_VNA_TEMP -- �������
    TEMPFILE 'C:\APP\ORA_INSTALL_USER2\ORADATA\EC11\TS_VNA_TEMP.dbf'
    SIZE 5M
    AUTOEXTEND ON NEXT 3M
    MAXSIZE 30M;
    
DROP TABLESPACE TS_VNA_TEMP INCLUDING CONTENTS AND DATAFILES; -- �������(alter database default temporary tablespace TS_VNA_TEMP; - ����� ��������� ������� �� ���������)

SELECT username,temporary_tablespace FROM dba_users; -- ������� ��������� ������������ ������

-- task3(������ ���� ��������� �����������, ������ ���� ������)------------------------------------------------
SELECT TABLESPACE_NAME FROM dba_tablespaces; -- ���
SELECT file_name, tablespace_name FROM DBA_DATA_FILES; -- ����������
SELECT file_name, tablespace_name FROM DBA_TEMP_FILES; -- ���������

-- task4(���� � ������ RL_XXXCORE � ���������� ������������:-----------------------------------------------------------
--                                                           * ���������� �� ���������� � ��������
--                                                           * ���������� ��������� � ������� �������, �������������, ��������� � �������.)
CREATE ROLE RL_VNACORE; -- ��������
GRANT CREATE SESSION, CREATE ANY TABLE, DROP ANY TABLE, -- �������� ����������
CREATE ANY PROCEDURE, DROP ANY PROCEDURE,
CREATE VIEW, DROP ANY VIEW, DROP ANY ROLE
TO RL_VNACORE;

SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'RL_VNACORE'; -- �������� ����������� ����������
GRANT CREATE SESSION TO RL_VNACORE;
REVOKE CREATE SESSION FROM RL_VNACORE;

REVOKE CREATE SESSION, CREATE ANY TABLE, DROP ANY TABLE, -- ���������� ����������
CREATE ANY PROCEDURE, DROP ANY PROCEDURE,
CREATE VIEW, DROP ANY VIEW, DROP ANY ROLE FROM RL_VNACORE;

DROP ROLE RL_VNACORE; --��������

-- task 5(����� ���� � �������, ��� ��������� ����������, ����������� ����)------------------------------------------------------
SELECT * FROM USER_ROLE_PRIVS; --where USERNAME='SAMPLE'; ��������������� ����
SELECT * FROM USER_TAB_PRIVS; --where Grantee = 'SAMPLE'; ����������, ��������������� ��������������� ������������
SELECT * FROM USER_SYS_PRIVS; --where USERNAME = 'SAMPLE'; ��������������� ���������� �������

-- task6(������� ������������)---------------------------------------------------------------------------------------------------
CREATE PROFILE PF_VNACORE LIMIT
  PASSWORD_LIFE_TIME 180 -- ��� ���� ����� ������
  SESSIONS_PER_USER 3 -- ��� ������ ��� �������������
  FAILED_LOGIN_ATTEMPTS 7 -- ��� ������� �����
  PASSWORD_LOCK_TIME 1 -- ��� ���� ����� ����������
  PASSWORD_REUSE_TIME 10 -- ����� ������� ���� ����� ��������� ������
  PASSWORD_GRACE_TIME DEFAULT -- ��� ���� ��������-� � ����� ������
  CONNECT_TIME 180 -- ����� ����-� �����
  IDLE_TIME 30; -- ��� ����� �������
  
  DROP PROFILE PF_VNACORE;
  
-- task 7(�������� ������ ���� �������� ��. �������� �������� ���� ���������� ������� PF_XXXCORE. �������� �������� ���� ���������� ������� DEFAULT.)-------------
SELECT username from dba_users;
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'PF_VNACORE';
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'DEFAULT';

--task 8(�������� ������������ � ������ XXXCORE �� ���������� �����������:-------------------------------------------------------------------------------------------
-- ��������� ������������ �� ���������: TS_XXX;
-- ��������� ������������ ��� ��������� ������: TS_XXX_TEMP;
-- ������� ������������ PF_XXXCORE;
-- ������� ������ ��������������;
-- ���� �������� ������ �����.
CREATE USER VNACORE
  IDENTIFIED BY PASS0303
  DEFAULT TABLESPACE TS_VNA
  QUOTA UNLIMITED ON TS_VNA
  TEMPORARY TABLESPACE TS_VNA_TEMP
  PROFILE PF_VNACORE
  ACCOUNT UNLOCK
  PASSWORD EXPIRE;
  
  DROP USER VNACORE;
  
  GRANT RL_VNACORE TO VNACORE;
  GRANT CONNECT TO VNACORE;
  GRANT CREATE ANY TABLE TO VNACORE;
  GRANT CREATE VIEW TO VNACORE;
  
  ALTER USER VNACORE PROFILE PF_VNACORE; -- ���������� ������� PF_VNACORE
  
  ALTER USER VNACORE ACCOUNT LOCK; -- �������������
  ALTER USER VNACORE ACCOUNT UNLOCK; -- ��������������
  ALTER PROFILE PF_VNACORE LIMIT PASSWORD_LIFE_TIME UNLIMITED; -- ����������� �������� ����� ������
  SELECT * FROM dba_users; -- �������� ������� ��������
  
----------------------()

SELECT USERNAME, USER_ID, PASSWORD, ACCOUNT_STATUS, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, PROFILE FROM DBA_USERS WHERE USERNAME = 'VNACORE';

SELECT username, password FROM dba_users;

-- task 11

CREATE TABLESPACE VNA_QDATA
  DATAFILE 'VNA_QDATA.dbf'
  SIZE 10 m
  AUTOEXTEND ON NEXT 1M MAXSIZE 100M
  OFFLINE;
  
ALTER TABLESPACE VNA_QDATA ONLINE;
ALTER TABLESPACE VNA_QDATA OFFLINE;

CREATE USER VNA
  IDENTIFIED BY NIKI321
  DEFAULT TABLESPACE VNA_QDATA
  QUOTA 2M ON TS_VNA
  PROFILE PF_VNACORE
  ACCOUNT UNLOCK
  PASSWORD EXPIRE;
DROP USER VNA;
  
  GRANT RL_VNACORE TO VNA;
  GRANT CONNECT TO VNA;
  GRANT CREATE ANY TABLE TO VNA;
  GRANT CREATE VIEW TO VNA;
  ALTER PROFILE PF_VNACORE LIMIT PASSWORD_LIFE_TIME UNLIMITED; -- ����������� �������� ����� ������
