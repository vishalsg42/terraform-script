# Terraform Sample Script


## Local Setup
```sh
cp terraform.tfvars.example terraform.tfvars
```

Add the relevant values in the terraform.tfvars

Checklist: 
1. Check the aws_profile & aws_region in the terraform.tfvars
2. ```lambda_source_bucket``` bucketname should be unqiue, otherwise script will fail. It's for uploading the source code of the lambda 
3. ```upload_bucket_name```bucketname should be unqiue, otherwise script will fail. It's for uploading the csv file from the lambda.
4. Add the working email in the terraform.tfvars as ```email_list = [<email-id>] ```, if the working the email is not added then the lambda will fail since it's the email is not verified.
5. Always re upload the lambda code once you have executed the terraform script. 

## To deploy
```sh
terraform apply --auto-approve
```
## Post Deployment
```sh
psql -h <hostname or ip address> -p <port number of remote machine> -d <database name which you want to connect> -U <username of the database server>
```

Once the database is connected, copy the content of `pg.sql` and paste in the psql cli.


## SES 
## To destroy
```sh
terraform destroy --auto-approve
```
Note: terraform destroy won't be able cleanly able to destroy the resources if the file exist in the S3 bucket.

psql -h demo.ccdapxxdewwy.ap-south-1.rds.amazonaws.com -p 5432 -d lambda_analytics -U lambda_analytics_admin