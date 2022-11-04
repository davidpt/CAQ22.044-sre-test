apply:
	@echo "building AMI"
	cd packer/
	packer init .
	packer build --var Name="aws-linux-ami-test" .
	cd ..
	terraform init
# terraform plan
	@echo "creating all infrastructure"
	terraform apply -auto-approve
	@echo "saving the private key"
	terraform output SSH_key_content > ~/.ssh/golden-ticket.pem
	chmod 400 ~/.ssh/golden-ticket.pem
	eval "$(sh-agent)"
	ssh-add -k ~/.ssh/golden-ticket.pem
	@echo "Connect to the bastion host with: ssh -A ubuntu@BASTION_HOST_IP"
destroy:
	@echo "destroying all infrastructure"
	terraform destroy
