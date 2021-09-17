const csvjson = require("csvjson");
const TransformerBiz = require("./biz/helpers/transformer.biz")
const QueryBuilderBiz = require("./biz/helpers/query-builder.biz");
const DynamoDBBiz = require("./biz/dynamoBiz");
const TEMPLATE = require("./template");
const psSQL = require('./db/pssql');
const SesBiz = require("./biz/ses.biz");
const S3biz = require("./biz/helpers/s3.biz");
const SnsBiz = require("./biz/helpers/sns.biz");

module.exports.handler = async function (event, context, callback) {
  try {
    console.log('event', JSON.stringify(event, null, 2));
    let response;
    // console.log(JSON.stringify(rows[0]))
    if (!event.Records) {
      response = {
        "statusCode": 500,
        "headers": {
          "Content-Type": "application/json"
        },
        "message": "Internal Server Error",
        "isBase64Encoded": false
      }
      callback(null, response);
    }
    const record = event.Records[0];
    console.log('record', record);
    console.log('event', event);

    const transform = new TransformerBiz();
    const payload = await transform.transform(event, TEMPLATE.event_parse);

    // Insert in dynamo
    const dynamoTablePayload = await transform.transform({ ...payload, ...event, ...record }, TEMPLATE.dynamo_table.aws_infra_table);
    console.log('ddd', dynamoTablePayload);
    const insertInDynamo = new DynamoDBBiz();
    await insertInDynamo.insert(dynamoTablePayload);

    // Insert in ps
    const psSql = await transform.transform(payload, TEMPLATE.postgresql);
    const queryBuilder = new QueryBuilderBiz('aws_infra_db');
    const query = await queryBuilder.insert(psSql);
    console.log('query', query);
    await psSQL.execute(query, []);

    // // sending email using ses
    const emailConfig = await transform.transform({ ...payload, ...event, ...record, ...psSql }, TEMPLATE.emailConfig);
    const sesBiz = new SesBiz();
    await sesBiz.sendMail({ ...emailConfig });

    // saving message in the s3 bucket
    const csvData = csvjson.toCSV({ message: payload.message }, { headers: 'key' });
    const s3biz = new S3biz(process.env.BUCKET_NAME);
    let key = `${new Date().getTime()}-uploaded.csv`
    await s3biz.putObject(key, csvData);


    // trigger sns
    const snsBiz = new SnsBiz(process.env.SNS_TYPICODE_ARN);
    await snsBiz.publish(psSql);

    response = {
      "statusCode": 200,
      "headers": {
        "Content-Type": "application/json"
      },
      "body": JSON.stringify(event),
      "isBase64Encoded": false
    };
    callback(null, response);
  } catch (err) {
    console.error('errorr of lambda ', err)
    callback(null, err);
  }
};