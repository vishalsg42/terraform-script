const AWS = require("aws-sdk")

class AWSDynamoDB {
    constructor() {
        this.dynamodb = new AWS.DynamoDB({
            region: process.env.AWS_REGION,
            accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretKeyId: process.env.AWS_SECRET_ACCESS_KEY
        })
    }
    insert(params) {
        return new Promise((resolve, reject) => {
            this.dynamodb.putItem(params, function (err, data) {
                if (err) {
                    console.log(err, err.stack);
                    reject(err);
                }
                else {
                    resolve(data);
                }
            });
        })
    }
}

module.exports = AWSDynamoDB;