CREATE DATABASE webappdb;
\c webappdb
CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));    
INSERT INTO transactions (id, amount,description) VALUES ('0', '400','groceries');   
SELECT * FROM transactions;
