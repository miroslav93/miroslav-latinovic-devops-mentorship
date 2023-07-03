# Task notes
TASK-12 Packer - > Ansible -> CloudFormation / Terrafrom

IAM User 1 ce svoje resurse da kreira unutar eu-central-1 regiona.
IAM User 2 ce svoje resurse da kreira unutar us-east-1 regiona.
IAM User 3 ce svoje resurse da kreira unutar eu-west-1 regiona

For task 12 you need to do following:

 [PACKER] - Create Custom AMI image from Amazon Linux 3 AMI image where you will have needed yum repos installed and enabled to install nginx web server and mysql database.
 [IaC - CloudFormation] Using an AMI image from step 1 create 2 new EC2 instances called task-12-web-server-cf and task-12-db-server-cf. For those instances create appropriate security groups and open needed ports. Please try to follow best practices for security groups. You can put your resources inside default VPC and public subnets.
 [IaC - Terraform] Using an AMI image from step 1 create 2 new EC2 instances called task-12-web-server-tf and task-12-db-server-tf. For those instances create appropriate security groups and open needed ports. Please try to follow best practices for security groups. You can put your resources inside default VPC and public subnets.
 [Ansible] By using ansible provisioner install nginx web server on task-12-web-server-cf and task-12-web-server-tf instances. By using ansilbe provisioner install mysql database on task-12-db-server-cf and task-12-db-server-tf instances.
You need to ensure that once when nginx is instaled that it is enabled and started. Same goes for mysql database. Also your nginx web server instances needs to have index.html file with content Hello from nginx web server created using CloudFormation and Ansible Hello from nginx web server created using Terrafrom and Ansible. Mysql database needs to have database called task-12-db and user task-12-user with password task-12-password and all privileges on task-12-db database. For the instance task-12-web-server-tf

 [Ansible] By using Ansible task verify connection via default mysql database port from task-12-web-server-cf and task-12-web-server-tf instances to task-12-db-server-cf and task-12-db-server-tf instances. For the connection verification you can use telnet tool.
Goal of this task is to create to paralel infrastructures one using CloudFormation and one using Terrafrom. With 2 EC2 instances as Web and Database servers.

Please pay attention to tagging strategy and naming convention. For example your web server instance should have following tags:
Name: task-12-web-server-cf
CreatedBy: IAM User name
Project: task-12
IaC: CloudFormation

All files that you create for this task please put inside task-12 folder. You can use any folder structure inside task-12 folder.

Due date for this task is Saturday June 17th when we will review it together durring office hours session.

# Task reproduction

## Packer
1. Created new directory for Packer-related work
2. Downloaded and installed Packer
3. Created Packer template - defined AMI parameters
4. Initiated Packer - confirmed AMI with base OS (no additional config) has been created
5. Removed newly created AMI
6. Added shell file for NGINX installation
7. Reinitiated Packer - confirmed AMI has been created

## CloudFormation
1. Created new directory for CF-related work
2. Created JSON template for creating EC2 instance using existing AMI
3. Added all the info to template (instance type, SG, subnet etc.)
4. Uploaded JSON template to AWS console to create stack
5. Confirmed stack created the requested resources and that NGINX is available on HTTP EC2's IP address
6. Removed the stack
7. Updated template to create two EC2 instances in the same manner
8. Uploaded stack again and added all the tags
9. Confirmed stack has created two EC2 instances
10. Confirmed NGINX welcome page is available on both instances

## Terraform
1. Downloaded and installed TF
2. Created new directory for TF-related work
3. Created main.tf file
4. Added all info to template (two ec2, type, subnet, sg, name,)
5. Initiated TF
6. Ran tf apply
7. Confirmed two new EC2 instances are created and NGINX welcome page is available

## Ansible
1. Downloaded and installed Ansible
2. Created new directory for Ansible-related work
3. Created inventory.ini file and wrote down CF and TF server IPs
4. Created ansible.conf and setup Ansible configuration
5. Created ansible playbook and defined tasks to install and setup NGINX
6. Ran ansible playbook
7. Play summary shows all is OK