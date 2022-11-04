# CAQ 22.044 | Site Reliability Engineer
Site Reliability Engineering Test

Notes: 
- Execute make apply and make destroy on a linux environment
- Before executing make sure that you have your credentials set correctly as environment variables

Dependencies:
- make
- packer
- terraform

## By executing make apply the project will:
- Create the infrastructure requested in the exercise. A total of 17 resources are created
- As output you will get:
  - the IP of the bastion host
  - IP addresses of the private instances
  - contents of the private key (sensitive)
  - usernames
- The contents of the private key will be saved to ~/.ssh/golden-ticket.pem
- The permissions of the private key will be changed to 400 (user read only)
- The private key will be added to ssh-agent to allow ssh forwarding
- In the end, it should all be set so that the user can connect to the bastion host with: ssh -A username@bastion_host_ip
- From the bastion host, the user can access the private instances and verify that the private instances have access to the internet through the NAT gateway

## By executing make destroy the project will:
- Destroy the infrastructure created previously
