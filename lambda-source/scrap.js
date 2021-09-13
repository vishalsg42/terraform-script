const { TRANSFORM } = require("stjs");
const TransformerBiz = require("./biz/helpers/transformer.biz")

let data = {
    "Records": [
        {
            "messageId": "3e851939-f3a8-4ba3-a1f7-bf20ab2a3fbd",
            "receiptHandle": "",
            "body": "{\n    \"name\": \"demo\",\n    \"email\": \"demo@gmail.com\",\n    \"message\": \"Test message\",\n    \"body\": \"asdasd asdasd\",\n \"subject\": \"Test subject\"\n}",
            "attributes": {
                "ApproximateReceiveCount": "1",
                "AWSTraceHeader": "Root=1-613ea999-2c1b2ec1173484b217940b35",
                "SentTimestamp": "1631496601472",
                "SenderId": "AROA5VKUWP3Q4FQ3HUTND:BackplaneAssumeRoleSession",
                "ApproximateFirstReceiveTimestamp": "1631496601478"
            },
            "messageAttributes": {},
            "md5OfBody": "4442e94f0cfc4bd7eb34860aac2e4b95",
            "eventSource": "aws:sqs",
            "eventSourceARN": "arn:aws:sqs:ap-south-1:939164860129:sqs-sample-service",
            "awsRegion": "ap-south-1"
        }
    ]
}

let template = `{
"Item": {
    "message_id": {
        "S": "{{#? clean($root, 'messageId')}}"
    },
    "subject": {
        "S": "{{#? clean($root, 'subject')}}"
    },
    "email": {
        "S": "{{#? clean($root, 'email')}}"
    },
    "name": {
        "S": "{{#? clean($root, 'name')}}"
    },
    "body": {
        "S": "{{#? clean($root, 'body')}}"
    }
}
}`

// let template = `{
//     "name": {
//         "S": ""
//     },
//     "subject": {
//         "S": ""
//     },
//     "email": {
//         "S": ""
//     },
//     "name": {
//         "S": ""
//     },
//     "body": {
//         "S": ""
//     }
// }`

async function main() {
    const transform  = new TransformerBiz();
    let py = JSON.parse(data.Records[0].body)
    const result = await transform.transform({ ...py, ...data.Records[0] }, template);
    console.log('result', result);
}
main();