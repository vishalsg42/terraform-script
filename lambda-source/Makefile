upload_zip_code: lambda_zip_code
	aws lambda update-function-code  --function-name sample-services-sean --zip-file fileb://source_code.zip --profile $(AWS_PROFILE)  --region $(AWS_REGION)

lambda_zip_code: 
	zip -FSr source_code.zip  . -x source_code.zip


.PHONY: clean

clean:
	rm  -r source_code.zip