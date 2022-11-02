apply:
	terraform init
	terraform plan
# terraform apply -auto-approve
	@echo "create all infrastructure"
	
destroy:
	@echo "destroy all infrastructure"
