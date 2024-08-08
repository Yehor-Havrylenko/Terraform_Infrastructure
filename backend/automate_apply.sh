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
terraform apply -auto-approve -var-file=dev.tfvars $TF_VARS
terraform output -json > ../outputs.json
export PATH_OUTPUT=../outputs.json

cd ./../cloudfront/

cat <<EOF > terraform.tfvars.json
{
  "api_endpoints": $(jq .api_endpoints.value $PATH_OUTPUT),
  "custom_domain_names": $(jq .custom_domain_names.value $PATH_OUTPUT),
  "certificate_arn_us_east_1": "arn:aws:acm:us-east-1:000706442555:certificate/2aa1d229-e1c9-40d6-933f-f0babcad6879",
  "route53_zone_id": "Z0778729350JC42N306XN"
}
EOF

terraform init -backend-config=dev.tfbackend
terraform apply -auto-approve
rm -f terraform.tfvars.json
rm -f ./../outputs.json
