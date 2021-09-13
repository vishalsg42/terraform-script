const nodemailer = require("nodemailer");
const AWS = require("@aws-sdk/client-ses");
const Handlebars = require("handlebars");

class SesBiz {
    constructor() {
        this.ses = new AWS.SES({
            region: process.env.AWS_REGION,
            accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretKeyId: process.env.AWS_SECRET_ACCESS_KEY
        })
        this.transporter = nodemailer.createTransport({
            SES: { ses: this.ses, aws: AWS },
        });
    }

    sendMail(emailConfig, context = {}) {
        return new Promise(async (resolve, reject) => {
            try {
                let template = Handlebars.compile(emailConfig.html || '<span>This is the test email</span>');
                let html = template(context);

                this.transporter.sendMail(
                    {
                        from: emailConfig.senderEmail,
                        to: emailConfig.recipientEmail,
                        subject: emailConfig.subject,
                        html,
                    },
                    (err, info) => {
                        if (err) {
                            reject(err);
                        }
                        resolve(info);
                    }
                );
            } catch (error) {
                console.error('error Mailer', error);
                reject('error', error);
            }
        })
    }
}

module.exports = SesBiz;