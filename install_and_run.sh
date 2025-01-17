#!/bin/bash

if ! [ -x "$(command -v terraform)" ]; then
  echo "Error: Terraform is not installed. Please install Terraform first." >&2
  exit 1
fi

echo "Initializing Terraform..."
terraform -chdir=terraform init

echo "Applying Terraform configuration..."
terraform -chdir=terraform apply -auto-approve

read -p "Do you want to destroy the Terraform resources? (yes/no): " confirm
if [ "$confirm" == "yes" ]; then
  echo "Destroying Terraform resources..."
  terraform -chdir=terraform destroy -auto-approve
else
  echo "Skipping destruction of Terraform resources."
fi
