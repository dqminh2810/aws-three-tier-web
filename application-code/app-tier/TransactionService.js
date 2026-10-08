const dbcreds = require('./DbConfig');
// const mysql = require('mysql');
const { Pool } = require('pg')

// const con = mysql.createConnection({
//     host: dbcreds.DB_HOST,
//     port: dbcreds.DB_PORT,
//     user: dbcreds.DB_USER,
//     password: dbcreds.DB_PWD,
//     database: dbcreds.DB_DATABASE
// });

const pool = new Pool({
    host: dbcreds.DB_HOST,
    port: dbcreds.DB_PORT,
    user: dbcreds.DB_USER,
    password: dbcreds.DB_PWD,
    database: dbcreds.DB_DATABASE,
    ssl: {
        rejectUnauthorized: false 
    }
});

function addTransaction(amount,desc,callback){
    var query = `INSERT INTO transactions (amount, description) VALUES ($1, $2) RETURNING *`;
    pool.query(query, [amount, desc], function(err,result){
        if (err) {
            console.error("Database error:", err);
            return callback(err, null); // Pass the error to the callback
        }
        console.log("Adding to the table worked");
        
        // Use result.rows for PostgreSQL, or just result for MySQL
        const data = result.rows ? result.rows : result; 
        return callback(null, data); 
    }) 
}

function getAllTransactions(callback){
    var query = "SELECT * FROM transactions";
    pool.query(query, function(err,result){
        if (err) throw err;
        console.log("Getting all transactions...");
        return(callback(result.rows));
    });
}

function findTransactionById(id,callback){
    var query = `SELECT * FROM transactions WHERE id = ${id}`;
    pool.query(query, function(err,result){
        if (err) throw err;
        console.log(`retrieving transactions with id ${id}`);
        return(callback(result.rows));
    }) 
}

function deleteAllTransactions(callback){
    var query = "DELETE FROM transactions";
    pool.query(query, function(err,result){
        if (err) throw err;
        console.log("Deleting all transactions...");
        return(callback(result.rows));
    }) 
}

function deleteTransactionById(id, callback){
    var query = `DELETE FROM transactions WHERE id = ${id}`;
    pool.query(query, function(err,result){
        if (err) throw err;
        console.log(`Deleting transactions with id ${id}`);
        return(callback(result.rows));
    }) 
}


module.exports = {addTransaction ,getAllTransactions, deleteAllTransactions, deleteAllTransactions, findTransactionById, deleteTransactionById};







