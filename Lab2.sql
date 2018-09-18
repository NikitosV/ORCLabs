ALTER SESSION SET "_ORACLE_SCRIPT" = true; -- без этой команды не работает
select * from V$SERVICES;
-- task1(табличное пространство для постоянных данных)---------------------------------------------------
CREATE TABLESPACE TS_VNA -- создаем 
 DATAFILE 'TS_VNA_TEMP' 
    SIZE 7M
    REUSE
    AUTOEXTEND ON NEXT 5M MAXSIZE 20M;
    
DROP TABLESPACE TS_VNA; -- удаляем

-- task2(табличное пространство для временных данных)----------------------------------------------------
CREATE TEMPORARY TABLESPACE TS_VNA_TEMP -- создаем
    TEMPFILE 'C:\APP\ORA_INSTALL_USER2\ORADATA\EC11\TS_VNA_TEMP.dbf'
    SIZE 5M
    AUTOEXTEND ON NEXT 3M
    MAXSIZE 30M;
    
DROP TABLESPACE TS_VNA_TEMP INCLUDING CONTENTS AND DATAFILES; -- удаляем(alter database default temporary tablespace TS_VNA_TEMP; - новое временная таблица по умолчанию)

SELECT username,temporary_tablespace FROM dba_users; -- смотрим временное пространство юзеров

-- task3(список всех табличных пространств, списки всех файлов)------------------------------------------------
SELECT TABLESPACE_NAME FROM dba_tablespaces; -- все
SELECT file_name, tablespace_name FROM DBA_DATA_FILES; -- постоянные
SELECT file_name, tablespace_name FROM DBA_TEMP_FILES; -- временные

-- task4(роль с именем RL_XXXCORE с системными привелегиями:-----------------------------------------------------------
--                                                           * разрешение на соединение с сервером
--                                                           * разрешение создавать и удалять таблицы, представления, процедуры и функции.)
CREATE ROLE RL_VNACORE; -- создание
GRANT CREATE SESSION, CREATE ANY TABLE, DROP ANY TABLE, -- передача привелегий
CREATE ANY PROCEDURE, DROP ANY PROCEDURE,
CREATE VIEW, DROP ANY VIEW, DROP ANY ROLE
TO RL_VNACORE;

SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'RL_VNACORE'; -- просмотр разрешенных соединений
GRANT CREATE SESSION TO RL_VNACORE;
REVOKE CREATE SESSION FROM RL_VNACORE;

REVOKE CREATE SESSION, CREATE ANY TABLE, DROP ANY TABLE, -- отключение привелегий
CREATE ANY PROCEDURE, DROP ANY PROCEDURE,
CREATE VIEW, DROP ANY VIEW, DROP ANY ROLE FROM RL_VNACORE;

DROP ROLE RL_VNACORE; --удаление

-- task 5(найти роль в словаре, все системные привилегии, назначенные роли)------------------------------------------------------
SELECT * FROM USER_ROLE_PRIVS; --where USERNAME='SAMPLE'; Предоставленные роли
SELECT * FROM USER_TAB_PRIVS; --where Grantee = 'SAMPLE'; Привилегии, предоставляемые непосредственно пользователю
SELECT * FROM USER_SYS_PRIVS; --where USERNAME = 'SAMPLE'; Предоставленные привилегии системы

-- task6(профиль безопасности)---------------------------------------------------------------------------------------------------
CREATE PROFILE PF_VNACORE LIMIT
  PASSWORD_LIFE_TIME 180 -- кол дней жизни пароля
  SESSIONS_PER_USER 3 -- кол сессий для пользователей
  FAILED_LOGIN_ATTEMPTS 7 -- кол попыток входа
  PASSWORD_LOCK_TIME 1 -- кол дней после блокировки
  PASSWORD_REUSE_TIME 10 -- через сколько дней можно повторить пароль
  PASSWORD_GRACE_TIME DEFAULT -- кол дней предупре-й О сменЕ ПАРОЛЯ
  CONNECT_TIME 180 -- время соед-я минут
  IDLE_TIME 30; -- кол минут простоя
  
  DROP PROFILE PF_VNACORE;
  
-- task 7(Получите список всех профилей БД. Получите значения всех параметров профиля PF_XXXCORE. Получите значения всех параметров профиля DEFAULT.)-------------
SELECT username from dba_users;
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'PF_VNACORE';
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'DEFAULT';

--task 8(Создайте пользователя с именем XXXCORE со следующими параметрами:-------------------------------------------------------------------------------------------
-- табличное пространство по умолчанию: TS_XXX;
-- табличное пространство для временных данных: TS_XXX_TEMP;
-- профиль безопасности PF_XXXCORE;
-- учетная запись разблокирована;
-- срок действия пароля истек.
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
  
  ALTER USER VNACORE PROFILE PF_VNACORE; -- подключаем профиль PF_VNACORE
  
  ALTER USER VNACORE ACCOUNT LOCK; -- заблокировать
  ALTER USER VNACORE ACCOUNT UNLOCK; -- разблокировать
  ALTER PROFILE PF_VNACORE LIMIT PASSWORD_LIFE_TIME UNLIMITED; -- бесконечное действие жизни пароля
  SELECT * FROM dba_users; -- проверка статуса аккаунта
  
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
  ALTER PROFILE PF_VNACORE LIMIT PASSWORD_LIFE_TIME UNLIMITED; -- бесконечное действие жизни пароля
