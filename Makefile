apply:
	terraform init
# terraform plan
	echo "creating all infrastructure"
	terraform apply -auto-approve
	echo "saving the private key"
	terraform output SSH_key_Content > ~/.ssh/golden-ticket.pem
	chmod 400 ~/.ssh/golden-ticket.pem
	ssh-agent bash
	ssh-agent -k ~/.ssh/golden-ticket.pem
	echo "Connect to the bastion host with: ssh -A ubuntu@BASTION_HOST_IP"
destroy:
	echo "destroying all infrastructure"
	terraform destroy
