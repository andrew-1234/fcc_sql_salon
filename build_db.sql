-- Create three tables named customers, appointments and services
-- Each table has primary key following <table_name>_id convention
-- The appointments table should have a customer_id foreign key that references
-- the customer_id column in customers table
-- The appointments table should have a service_id foreign key that references
-- the service_id column in services table
-- The customers table should have phone that is VARCHAR and unique 
-- The customers and services tables should have a name column
-- appointments table should have a time column VARCHAR
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name VARCHAR,
  phone VARCHAR UNIQUE
);
CREATE TABLE services (
  service_id SERIAL PRIMARY KEY,
  name VARCHAR
);
CREATE TABLE appointments (
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customers(customer_id),
  service_id INT REFERENCES services(service_id),
  time VARCHAR
);
-- To create the tables I can run
-- psql --username=freecodecamp --dbname=salon -a -f build_db.sql

-- Add three rows to the services table for the different salon services, one
-- with a service_id of 1
INSERT INTO services (name)
VALUES ('Color and Cut');
INSERT INTO services (name)
VALUES ('Standard Cut');
INSERT INTO services (name)
VALUES ('Wash and Style');
