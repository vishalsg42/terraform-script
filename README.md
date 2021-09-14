# Terraform Sample Script


## Local Setup
```sh
cp terraform.tfvars.example terraform.tfvars
```

Add the relevant values in the terraform.tfvars
## To deploy
```sh
terraform apply --auto-approve
```
## Post Deployment
```sh
psql -h <hostname or ip address> -p <port number of remote machine> -d <database name which you want to connect> -U <username of the database server>
```

Once the database is connected, copy the content of `pg.sql` and paste in the psql cli.

## To destroy
```sh
terraform destroy --auto-approve
```
Note: terraform destroy won't be able cleanly able to destroy the resources if the file exist in the S3 bucket.