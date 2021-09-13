const psSQL = require('pg');

/**
 * Create mysql connection pool in a Singleton pattern 
 */
const getPool = () => {
    const pool = new psSQL.Pool({
        user: process.env.PG_USER,
        host: process.env.PG_HOST,
        database: process.env.PG_DATABASE,
        password: process.env.PG_PASSWORD,
        port: process.env.PG_PORT,
    });
    return pool;
};
let pool;

module.exports = {
    /**
     * @param {string} query
     * @param {array} params
     */
    execute: (query, params) => new Promise((resolve, reject) => {
        try {
            if (!pool) {
                pool = getPool();
            }
            pool.connect((connError, connection, releaseConnection) => {
                if (connError) return reject(connError);
                connection.query(query, params, (error, data) => {
                    try {
                        releaseConnection();
                        if (error) {
                            return reject(error);
                        }
                        return resolve(data);
                    } catch (e) {
                        return reject(e);
                    }
                });
            });
        } catch (error) {
            reject(error);
        }
    })
}