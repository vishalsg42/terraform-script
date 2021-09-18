# Terraform Sample Script


## Local Setup
```sh
cp terraform.tfvars.example terraform.tfvars
```

Add the relevant values in the terraform.tfvars

Checklist:
1. Check the aws_profile & aws_region in the terraform.tfvars
2. ```lambda_source_bucket``` bucket name should be unique, otherwise, the script will fail. It's for uploading the source code of the lambda
3. ```upload_bucket_name```bucketname should be unique, otherwise, the script will fail. It's for uploading the CSV file from the lambda.
4. Add the working email in the terraform.tfvars as ```email_list = [<email-id>] ```, if the working email is not added then the lambda will fail since it's the email is not verified.
5. Always re-upload the lambda code once you have executed the terraform script.

## To deploy
```sh
terraform apply --auto-approve
```

**After deploying the terraform script, scripts present the outputs of the provisioned resources. Please make a note of it since it would be required further.**

## Post Deployment
1. Connect the psql DB:
```sh
psql -h <hostname or ip address> -p <port number of remote machine> -d <database name which you want to connect> -U <username of the database server>
```
Options.
- -h => present in the output of the terraform script
- -p => present in the terraform variables(terraform.tfvars)
- -d => present in the terraform variables(terraform.tfvars)
- -U => present in the terraform variables(terraform.tfvars)

Note: for connecting psql db, make sure [psql](https://blog.timescale.com/blog/how-to-install-psql-on-mac-ubuntu-debian-windows/) is installed on the local machine.

Once the database is connected, copy the content of `pg.sql` and paste into the psql CLI and execute it.

3. Clone the github [tf-sample-lambda-node](https://github.com/vishalsg42/tf-sample-lambda-node) repository.

4. Deploy the lambda code from the [tf-sample-lambda-node](https://github.com/vishalsg42/tf-sample-lambda-node) repository  by executing the below command:
```
make upload_zip_code AWS_PROFILE=<aws_profile> AWS_REGION=<aws_region>
```

2. Verify the SES email from the inbox that is mention in terraform variables(terraform.tfvars).

3. Get the App Client & Secret id.
    - Once the email is verified, navigate to Cognito user pools from the [AWS Console](https://ap-south-1.console.aws.amazon.com/cognito/users/).
    - Select the created user pool which is **user_pool**.
    - Click on the App clients & Select the show details.
    - Now copy the client id & secret id at some other place.

4. Generate the access token.
```sh
curl --location --request POST '<cognito_token_url>' --header 'Content-Type: application/x-www-form-urlencoded'  --header "Accept: application/json" --data-urlencode 'grant_type=client_credentials' --data-urlencode 'scopes=messages/write messages/read' --user <cognito_client>:<cognito_secret>
```
Options:
- cognito_client    => From step 3.
- cognito_secret    => From step 3.
- cognito_token_url => cognito token url from the teraform output.
Replace all the fields with the respected values.

5. Hit the api gateway url:
```sh
curl --location --request POST '<api_gateway_url>' \
--header 'Authorization: Bearer <access_token>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "test",
    "email": "<verified_ses_email_id>",
    "message": "1234Test message",
    "body": "dssfsdf asdasd asdasd",
    "subject": "my test email"
}'
```
Options:
- api_gateway_url: present in terraform output variable
- verified_ses_email_id: terraform variables(terrafrorm.tfvars)
- access_token: From Step 4.

## Results:
Once the API is executed, the following activities should be
1. Email should be received on the configured SES email
2. Logs should be generated in the Cloudwatch
3. An entry should be made in AWS DynamoDB
4. Also an entry should be made in AWS RDS PostgreSQL.

## To destroy
1. Delete S3 objects
```
aws s3 rm s3://<upload_bucket_name> --recursive
```

Options:
- upload_bucket_name: present in the terraform output variables.

```sh
terraform destroy --auto-approve
```
Note: terraform destroy won't be able to cleanly destroy the resources if the file exists in the S3 bucket.

psql -h demo.ccdapxxdewwy.ap-south-1.rds.amazonaws.com -p 5432 -d lambda_analytics -U lambda_analytics_admin