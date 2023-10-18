

CREATE TABLE IF NOT EXISTS silver_transactional.address
  WITH (table_type = 'ICEBERG',
        format='PARQUET',
        write_compression='ZSTD',
        location='s3://data-lake-how-187671957427/silver/transactional/address/',
        is_external=false) AS
  SELECT
  id,
  created_at,
  updated_at,
  street,
  number,
  complement,
  postcode,
  city,
  state
  FROM
  (
  select
  op,
  id,
  created_at,
  updated_at,
  street,
  number,
  complement,
  postcode,
  city,
  state,
  row_number() over(partition by id order by updated_at desc) as rn
  from bronze_transactional.address
  )
  where rn = 1 and id not in (select id from bronze_transactional.address where op = 'D')
