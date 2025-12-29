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
    database: dbcreds.DB_DATABASE
});

function addTransaction(amount,desc){
    var query = `INSERT INTO \`transactions\` (\`amount\`, \`description\`) VALUES ('${amount}','${desc}')`;
    pool.query(query, function(err,result){
        if (err) throw err;
        console.log("Adding to the table should have worked");
    }) 
    return 200;
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







