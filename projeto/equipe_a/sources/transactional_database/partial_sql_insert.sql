
BEGIN;

WITH x AS (
   INSERT INTO transactional.orders ("updated_at", "status") VALUES (now(), '{{ order_status }}')
   RETURNING id
)

INSERT INTO transactional.orders_status_history (updated_at, orders_id, orders_status)
SELECT now(), id, '{{ order_status }}'
FROM x;




WITH x AS (
   INSERT INTO transactional.address ("updated_at",
                                      "street",
                                      "number",
                                      "postcode",
                                      "city",
                                      "state") VALUES (
                                        now(),
                                        '{{ address_street }}',
                                        '{{ address_number }}',
                                        '{{ address_postcode }}',
                                        '{{ address_city }}',
                                        '{{ address_state }}')
   RETURNING id
)

INSERT INTO transactional.supplier ("updated_at", "name", "address_id")
SELECT now(), '{{ supplier_name }}', id
FROM x;

COMMIT;
