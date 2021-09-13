const AWS = require('aws-sdk');

class S3Biz {
	/**
     * This is the default constructor of this class.
     */
	constructor(bucket) {
		this.s3 = new AWS.S3({
			accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretKeyId: process.env.AWS_SECRET_ACCESS_KEY,
            bucket: bucket,
            region: process.env.AWS_REGION,
            apiVersion: "latest"
		});
		this.bucket = bucket;
		this.signedUrlExpireSeconds = 60 * 5;
	}
	/**
	 * Dumps the file object in S3 bucket
	 * @param {string} key 
	 * @param {buffer} content 
	 */
	async putObject(key, content) {
		return new Promise((resolve, reject) => {
			this.s3.putObject({
				Bucket: this.bucket,
				Key: key,
				Body: content
			}, (error, data) => {
				if (error) {
					return reject(error);
				}
				return resolve(data);
			});
		});
	}

	async putBase64Object(key, content,contentType='application/pdf') {
		return new Promise((resolve, reject) => {
			this.s3.putObject({
				Bucket: this.bucket,
				Key: key,
				Body: content,
				ContentEncoding: 'base64',
				ContentType: contentType
			}, (error, data) => {
				if (error) {
					return reject(error);
				}
				return resolve(data);
			});
		});
	}

	async putImageObject(key, content, type) {
		return new Promise((resolve, reject) => {
			this.s3.putObject({
				Bucket: this.bucket,
				Key: key,
				Body: content,
				ContentEncoding: 'base64',
				ContentType: `image/${type}`
			}, (error, data) => {
				if (error) {
					return reject(error);
				}
				return resolve(data);
			});
		});
	}
	 /**
    * Retrieves document from S3 for the the supplied bucket and key
    * @param {string} bucket
    * @param {string} key
    */
   async getObject(key) {
	return new Promise((resolve, reject) => {
		this.s3.getObject({
			"Bucket": this.bucket,
			"Key": key
		}, (error, data) => {
			if (error) {
				return reject(error);
			}
			return resolve(data);
		});
	});
}

/**
	 * gets the signed url for passed key
	 * @param {string} key 
	 */
	async getSignedUrl(key) {
		return new Promise((resolve, reject) => {
			this.s3.getSignedUrl('putObject',{
				Bucket: this.bucket,
				Key: key,
				Expires: this.signedUrlExpireSeconds,
				// ACL: 'bucket-owner-full-control',
				ContentType: 'application/pdf'
			}, (error, data) => {
				if (error) {
					return reject(error);
				}
				return resolve(data);
			});
		});
	}

}

module.exports = S3Biz;
