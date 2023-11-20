CREATE SCHEMA IF NOT EXISTS transactional;

CREATE TABLE IF NOT EXISTS transactional.orders (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "status" varchar
);

CREATE TABLE IF NOT EXISTS transactional.orders_status_history (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "orders_id" integer REFERENCES transactional.orders (id),
  "orders_status" varchar
);

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

CREATE TABLE IF NOT EXISTS transactional.supplier (
  "id" integer primary key generated always as identity,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "name" varchar,
  "address_id" integer REFERENCES transactional.address (id)
);