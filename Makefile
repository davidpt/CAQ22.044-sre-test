apply:
	@echo "building AMI"
	packer init .
	packer build --var Name="aws-linux-ami-priv-img" .
	terraform init
# terraform plan
	@echo "creating all infrastructure"
	terraform apply -auto-approve
	@echo "saving the private key"
	terraform output SSH_key_content > ~/.ssh/golden-ticket.pem
	chmod 400 ~/.ssh/golden-ticket.pem
	@echo "The infrastructure is created and the private key is saved in the following path: ~/.ssh/golden-ticket.pem"
## in theory this sounds good as it would leave ssh forwarding already configured for the user
## however the env variables from the ssh-agent would only be set in this child process from make
# eval "$$(ssh-agent)" && \
# ssh-add -k ~/.ssh/golden-ticket.pem
# @echo "Connect to the bastion host with: ssh -A ubuntu@BASTION_HOST_IP"
destroy:
	@echo "destroying all infrastructure"
	terraform destroy -auto-approve
	rm packer-manifest.json
	rm ~/.ssh/golden-ticket.pem
