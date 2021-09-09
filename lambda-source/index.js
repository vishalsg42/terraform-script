const pg = require('pg')
const pool = new pg.Pool({
  user: process.env.PG_USER,
  host: process.env.PG_HOST,
  database: process.env.PG_DATABASE,
  password: process.env.PG_PASSWORD,
  port: process.env.PG_PORT,
})

async function query (q) {
  const client = await pool.connect()
  let res
  try {
    await client.query('BEGIN')
    try {
      res = await client.query(q)
      await client.query('COMMIT')
    } catch (err) {
      await client.query('ROLLBACK')
      throw err
    }
  } finally {
    client.release()
  }
  return res
}

module.exports.handler = async function (event, context, callback) {
  try {
    console.log('event', JSON.stringify(event, null, 2));
    const { rows } = await query("select * from pg_tables")
    console.log(JSON.stringify(rows[0]))
    var response = {
        "statusCode": 200,
        "headers": {
            "Content-Type" : "application/json"
        },
        "body": JSON.stringify(rows),
        "isBase64Encoded": false
    };
    callback(null, response);
  } catch (err) {
    console.log('Database ' + err)
    callback(null, 'Database ' + err);
  }
};