# Postgres DMS CDC Replication

Official documentation about it: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.PostgreSQL.html


1. Check if the postgres Database has support to stream data using CDC. It needs to be Aurora PostgreSQL version 2.2 with PostgreSQL 10.6 compatibility (or higher).
2. Change the DB Cluster parameter `rds.logical_replication` to 1. (In case the parameter group isn't exclusive to this DB Cluster, create a new DB Cluster Parameter and DB Parameter and assign to the cluster!)
3. Ensure the value of the `max_worker_processes` parameter in your DB Cluster Parameter Group is equal to, or higher than the total combined values of `max_logical_replication_workers`, `autovacuum_max_workers`, and `max_parallel_workers`. A high number of background worker processes might impact application workloads on small instances. So, monitor performance of your database if you set `max_worker_processes higher` than the default value.
4. If the master user isn't being used (which is recommended), do the following config:

    ```sql
    -- If the user was not created
    -- In test environment it was not created
    -- With rds_superuser

    create user app_datalake password 'samplepasswordUjmwXD8OeRd9j0x55bDG6yS';

    -- With rds_superuser

    grant rds_superuser to app_datalake;

    grant rds_replication to app_datalake;

    create schema dms_replication;

    alter schema dms_replication owner to app_datalake;

    -- Now with the app_datalake user;

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

    -- Now with rds_superuser again

    CREATE EVENT TRIGGER awsdms_intercept_ddl ON ddl_command_end
    EXECUTE PROCEDURE dms_replication.awsdms_intercept_ddl();
    ```

5. Include (does not specify, so I would change both) in the DB Cluster and DB parameter `shared_preload_libraries` the value `pglogical` (it is a list with comma separated values).
6. Restart your PostgreSQL source database.
7. On the PostgreSQL database, run the command, `create extension pglogical`; (using the app_datalake user)
8. Run the following command to verify that pglogical installed successfully: `select * FROM pg_catalog.pg_extension`

## DMS Configuration

9. Create the Set the extra connection attribute (ECA) following when you create your source endpoint.
    `PluginName=PGLOGICAL;`
