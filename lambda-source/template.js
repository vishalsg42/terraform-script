module.exports = {
    "event_parse": `{
        "body": "{{Records[0].body}}",
        "parsedbody": "{{JSON.parse(Records[0].body)}}",
        "messageId": "{{Records[0].messageId}}",
        "message": "{{JSON.parse(Records[0].body).body}}",
        "name": "{{JSON.parse(Records[0].body).name}}",
        "email": "{{JSON.parse(Records[0].body).email}}",
        "subject": "{{JSON.parse(Records[0].body).subject}}"
    }`,
    "emailConfig": `{
        "senderEmail": "{{#? clean($root, 'email')}}",
        "recipientEmail": "{{#? clean($root, 'email')}}",
        "subject": "{{#? clean($root, 'subject')}}",
        "html": "{{#? clean($root, 'html')}}"
    }`,
    "postgresql": `{
        "message_id": "{{#? clean($root, 'messageId')}}",
        "email": "{{#? clean($root, 'email')}}",
        "subject": "{{#? clean($root, 'subject')}}",
        "message": "{{#? clean($root, 'message')}}",
        "name": "{{#? clean($root, 'name')}}",
        "body": "{{#? clean($root, 'body')}}"
    }`,
    "dynamo_table": {
        "aws_infra_table": `{
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
                "message": {
                    "S": "{{#? clean($root, 'message')}}"
                },
                "name": {
                    "S": "{{#? clean($root, 'name')}}"
                },
                "body": {
                    "S": "{{#? clean($root, 'body')}}"
                }
            },
            "TableName": "aws_infra_table"
        }`
    }
}

