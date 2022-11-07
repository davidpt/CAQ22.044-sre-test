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

## A caveat
- While the Makefile functions as requested, if you run it twice in a row some errors are bound to happen  
  - From the start, Packer will not create the AMI since the name selected is the same)
  - Another consequent error relates to the SSH key, the second time the scrit is run the key already exists and you have no permissions to write (due to the chmod 400 required for ssh connection)
  - Another consequent error occurs if the user changes the name of the AMI to advance to a new execution of the Makefile. This will add the build info to the packer-manifest.json file. However, the script reads the instance 0 - the one that was added first to the file