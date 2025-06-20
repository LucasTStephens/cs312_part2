## Background
---
This guide covers setting up an instance running Minecraft on AWS. It does this through terraform scripts that create a VPC and security group then apply them to a new instance. Once the instance is created it downloads ``docker-compose.yml`` and runs it.

## Requirements
---
*setup was done on windows

This resource is useful as a guide if you run into issues https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code

- Terraform 1.2.0
- AWS CLI 6.16
- AWS credentials
	- Copy from AWS Learner Lab
	- Paste into ~/.aws/credentials

## Pipeline Diagram
---
![pipeline.png](https://github.com/LucasTStephens/cs312_part2/blob/main/pipeline.png)
## Run Minecraft Server
---
Simply run ``terraform apply`` and wait for a few minutes

## Connect to  Minecraft Server
--- 
When the script finishes it will give the public ip of the server, input that into this command to verify that Minecraft is running.
```
nmap -sV -Pn -p T:25565 <instance_public_ip>
```

## Resources
1. https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code
2. A healthy dose of chatgpt troubleshooting