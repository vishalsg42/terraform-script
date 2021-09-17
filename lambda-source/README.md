# Nodejs Sample Code: AWS Services
Note: This is repo contains simple implmentations of the following the AW services
1. AWS DynamoDB
2. AWS S3 bucket
3. AWS SES
4. AWS Lambda
5. AWS PostgreSQL
6. AWS SNS

## Prerequisite
**Go to [terraform-script](https://github.com/vishalsg42/terraform-script) repository & follow the instructions from the README file.**

## Installation
```sh
npm i
```

## To deploy lambda function

```sh
make AWS_PROFILE=<aws-profile-name> AWS_REGION=<aws-region>
```

Notes:
1. Always re upload the lambda code once you have executed the terraform script. 