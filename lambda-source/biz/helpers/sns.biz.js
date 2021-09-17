const AWS = require('aws-sdk');

class SnsBiz {
	/**
     * This is the default constructor of this class.
     */
	constructor(topicArn) {
		AWS.config.update({
            accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretKeyId: process.env.AWS_SECRET_ACCESS_KEY,
            region: process.env.AWS_REGION,
        });
		this.sns = new AWS.SNS();
		this.topicArn = topicArn;
	}
	/**
	 * Dumps the message on topic channel
	 * @param {string} message
	 */

	publish(message) {
		return new Promise(async (resolve, reject) => {	
			try {
				const params = {
					Message: JSON.stringify({ ...message }),
					// MessageStructure: 'json',
					TopicArn: this.topicArn
				};
				const result = await this.sns.publish(params).promise();
				resolve(result);
			} catch (error) {
				reject(error);
			}
		});
	}
}

module.exports = SnsBiz;
