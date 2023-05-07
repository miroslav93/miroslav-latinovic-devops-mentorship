# DevOps Mentorship Program task 8 summary

- Launched a new EC2 instance using existing AMI with NodeJS App and NGINX preconfigured
- Using provided access tokens, created a new Route 53 DNS entry - miroslav-latinovic.awsbosnia.com
- Pointed new DNS entry to newly created task 8 EC2 instance IP
- Configured SSL using certbot
- Enabled SSL auto-renewal using certbot and crontab
- Imported this SSL cert to Acm
- Created an ALB and targeted the existing task 8 EC2 with it. Added the existing cert I imported to ACM to this ALB\
- Updated Route 53 DNS records to match this.
- This caused a redirect loop between NGINX and ALB. Adjusted NGINX config to default values so that it listens to HTTP traffic. This resolved the loop.
- Requested a new SSL cert via ACM.
- Used this new SSL cert with ALB and confirmed it works.
- Stopped the task 8 EC2, created an AMI out of it and removed the task 8 resources I created.

# Commands used during task:
aws route53 change-resource-record-sets \
    --hosted-zone-id Z3LHP8UIUC8CDK \
    --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"miroslav-latinovic.awsbosnia.com.","Type":"A","TTL":300,"ResourceRecords":[{"Value":"52.57.203.241"}]}}]}'

yum install python3-pip
sudo pip3 install certbot certbot-nginx
certbot to generate ssl cert
opened port 443 inb

crontab was missing, had to install it:
yum install cronie cronie-anacron

crontab 
0 0 1 */2 * certbot renew --force-renewal

cert
openssl x509 -in /etc/letsencrypt/live/miroslav-latinovic.awsbosnia.com/fullchain.pem -noout -enddate

ALB created via console, created redirect from 80 to 443

aws route53 change-resource-record-sets \
    --hosted-zone-id Z3LHP8UIUC8CDK \
    --change-batch '{"Changes":[{"Action":"UPDATE","ResourceRecordSet":{"Name":"miroslav-latinovic.awsbosnia.com.","Type":"CNAME","TTL":300,"ResourceRecords":[{"Value":"miroslav-latinovic-task-8-alb-2036405489.eu-central-1.elb.amazonaws.com"}]}}]}'



get certs 
openssl s_client -connect miroslav-latinovic.awsbosnia.com:443 -servername miroslav-latinovic.awsbosnia.com -showcerts

get exp date

openssl s_client -connect miroslav-latinovic.awsbosnia.com:443 -servername miroslav-latinovic.awsbosnia.com 2>/dev/null | openssl x509 -noout -enddate | awk -F= '{print $2}' | xargs -I{} date -d {} '+%Y-%m-%d %H:%M:%S %Z' | jq -R '{expiration_date: .}'



new cert

aws route53 change-resource-record-sets \
    --hosted-zone-id Z3LHP8UIUC8CDK \
    --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"_85f66e001bf41e3d290a2f293e1ad574.miroslav-latinovic.awsbosnia.com.","Type":"CNAME","TTL":300,"ResourceRecords":[{"Value":"_17da8b77543bfbc415b6652a6d2b38fd.wmqxbylrnj.acm-validations.aws."}]}}]}'