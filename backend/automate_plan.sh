#!/bin/bash

TF_VARS=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -var=*) 
            TF_VARS="${TF_VARS} -var ${1#*=}"
            ;;
        *)
            echo "unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

echo "Running Terraform with the following variables: $TF_VARS"

cd ./api/ || exit
terraform init -backend-config=dev.tfbackend
terraform plan -var-file=dev.tfvars $TF_VARS
terraform output -json > ../outputs.json
export PATH_OUTPUT=../outputs.json

cd ./../cloudfront/

cat <<EOF > terraform.tfvars.json
{
  "api_endpoints": $(jq .api_endpoints.value $PATH_OUTPUT),
  "custom_domain_names": $(jq .custom_domain_names.value $PATH_OUTPUT),
  "certificate_arn_us_east_1": "arn:aws:acm:us-east-1:",
  "route53_zone_id": ""
}
EOF

terraform init -backend-config=dev.tfbackend
terraform plan
rm -f terraform.tfvars.json
rm -f ./../outputs.json
