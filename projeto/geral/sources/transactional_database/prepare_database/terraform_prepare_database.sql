CREATE ROLE :user LOGIN PASSWORD :'password';

CREATE SCHEMA IF NOT EXISTS transactional;

ALTER SCHEMA transactional OWNER TO :user;

CREATE TABLE IF NOT EXISTS transactional.orders (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "status" varchar
);

ALTER TABLE transactional.orders OWNER TO :user;

CREATE TABLE IF NOT EXISTS transactional.orders_status_history (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "orders_id" integer REFERENCES transactional.orders (id),
  "orders_status" varchar
);

ALTER TABLE transactional.orders_status_history OWNER TO :user;


CREATE TABLE IF NOT EXISTS transactional.address (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "street" varchar,
  "number" varchar,
  "complement" varchar,
  "postcode" varchar,
  "city" varchar,
  "state" varchar
);

ALTER TABLE transactional.address OWNER TO :user;


CREATE TABLE IF NOT EXISTS transactional.supplier (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "name" varchar,
  "address_id" integer REFERENCES transactional.address (id)
);

ALTER TABLE transactional.supplier OWNER TO :user;
