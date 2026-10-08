CREATE DATABASE webappdb;
\c webappdb
CREATE TABLE IF NOT EXISTS transactions(id SERIAL PRIMARY KEY, amount DECIMAL(10,2), description VARCHAR(100));    
INSERT INTO transactions (id, amount,description) VALUES ('0', '400','groceries');   
SELECT * FROM transactions;
