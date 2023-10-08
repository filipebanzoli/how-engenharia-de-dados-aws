
CREATE ROLE :user LOGIN PASSWORD :'password';

grant rds_superuser to :user;

grant rds_replication to :user;

create schema dms_replication;

alter schema dms_replication owner to :user;

create table dms_replication.awsdms_ddl_audit
(
c_key    bigserial primary key,
c_time   timestamp,    -- Informational
c_user   varchar(64),  -- Informational: current_user
c_txn    varchar(16),  -- Informational: current transaction
c_tag    varchar(24),  -- Either 'CREATE TABLE' or 'ALTER TABLE' or 'DROP TABLE'
c_oid    integer,      -- For future use - TG_OBJECTID
c_name   varchar(64),  -- For future use - TG_OBJECTNAME
c_schema varchar(64),  -- For future use - TG_SCHEMANAME. For now - holds current_schema
c_ddlqry  text         -- The DDL query associated with the current DDL event
);

ALTER TABLE dms_replication.awsdms_ddl_audit OWNER TO :user;

CREATE OR REPLACE FUNCTION dms_replication.awsdms_intercept_ddl()
RETURNS event_trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
declare _qry text;
BEGIN
if (tg_tag='CREATE TABLE' or tg_tag='ALTER TABLE' or tg_tag='DROP TABLE') then
        SELECT current_query() into _qry;
        insert into dms_replication.awsdms_ddl_audit
        values
        (
        default,current_timestamp,current_user,cast(TXID_CURRENT()as varchar(16)),tg_tag,0,'',current_schema,_qry
        );
        delete from dms_replication.awsdms_ddl_audit;
end if;
END;
$$;

GRANT EXECUTE ON FUNCTION dms_replication.awsdms_intercept_ddl() TO :user;

CREATE EVENT TRIGGER awsdms_intercept_ddl ON ddl_command_end
EXECUTE PROCEDURE dms_replication.awsdms_intercept_ddl();

CREATE extension pglogical;
