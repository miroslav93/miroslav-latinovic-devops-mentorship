sleep 30
sudo yum update -y
sudo yum install -y nginx
sudo echo nginx uspjesno instaliran
sudo systemctl start nginx
sudo systemctl enable nginx