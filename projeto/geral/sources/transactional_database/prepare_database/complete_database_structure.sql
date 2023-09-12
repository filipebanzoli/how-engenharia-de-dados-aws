CREATE TABLE "order" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "client_id" integer,
  "status" varchar
);

CREATE TABLE "order_status_history" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "order_id" integer,
  "order_status" integer
);

CREATE TABLE "order_products" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "order_id" integer,
  "product_id" integer,
  "amount" float
);

CREATE TABLE "product" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "name" varchar,
  "description" varchar,
  "amount" float
);

CREATE TABLE "client" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "name" varchar,
  "address_id" integer
);

CREATE TABLE "address" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "street" varchar,
  "number" varchar,
  "complement" varchar,
  "postal_code" varchar,
  "city" varchar,
  "state" varchar
);

CREATE TABLE "supplier" (
  "id" serial PRIMARY KEY,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp,
  "name" varchar,
  "address_id" integer
);

ALTER TABLE "order" ADD FOREIGN KEY ("client_id") REFERENCES "client" ("id");

ALTER TABLE "order_status_history" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_products" ADD FOREIGN KEY ("product_id") REFERENCES "product" ("id");

ALTER TABLE "order_products" ADD FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "address" ADD FOREIGN KEY ("id") REFERENCES "client" ("address_id");

ALTER TABLE "address" ADD FOREIGN KEY ("id") REFERENCES "supplier" ("address_id");
