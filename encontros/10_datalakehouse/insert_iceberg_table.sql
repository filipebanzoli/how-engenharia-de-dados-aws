
MERGE INTO silver_transactional.address as s
USING
(select * from (
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
  from bronze_transactional.address)
  where rn = 1) as b
ON (s.id = b.id)
WHEN MATCHED and b.op = 'D'
      THEN DELETE
WHEN NOT MATCHED
THEN INSERT (id, created_at, updated_at, street, number, complement, postcode, city, state)
      VALUES (b.id, b.created_at, b.updated_at, b.street, b.number, b.complement, b.postcode, b.city, b.state)
WHEN MATCHED and b.op != 'D' and b.updated_at > s.updated_at
THEN UPDATE
      SET updated_at = b.updated_at, street = b.street, number = b.number, complement = b.complement, postcode = b.postcode, city = b.city, state = b.state
