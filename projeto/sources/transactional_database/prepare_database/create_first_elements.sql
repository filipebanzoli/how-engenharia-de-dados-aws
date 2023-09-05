DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = '{{ user }}') THEN

      RAISE NOTICE 'Role "{{ user }}" already exists. Skipping.';
   ELSE
      BEGIN   -- nested block
         CREATE ROLE {{ user }} LOGIN PASSWORD '{{ password }}';
      EXCEPTION
         WHEN duplicate_object THEN
            RAISE NOTICE 'Role "{{ user }}" was just created by a concurrent transaction. Skipping.';
      END;
   END IF;
END
$do$;

ALTER DATABASE transactional OWNER TO {{ user }};