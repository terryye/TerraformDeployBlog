resource "aws_launch_template" "webapp_launch_template" {
  name_prefix   = "webapp-launch-template"
  image_id      = "ami-084568db4383264d4"
  instance_type = "t3.micro"
  key_name = "vockey"
  vpc_security_group_ids = [var.ec2_security_group_id]
  user_data = base64encode(<<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${"$"}{UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo mkdir /home/ubuntu/ghost
sudo touch /home/ubuntu/ghost/docker-compose.yml
cat > /home/ubuntu/ghost/docker-compose.yml<< EOC
services:
    ghost:
        image: ghost:5-alpine
        restart: always
        ports:
            - 8080:2368
        environment:
            # see https://ghost.org/docs/config/#configuration-options
            database__client: mysql
            database__connection__host: ${var.db_host}
            database__connection__port: ${var.db_port}
            database__connection__user: ${var.db_username}
            database__connection__password: ${var.db_password}
            database__connection__database: ${var.db_name}
            # this url value is just an example, and is likely wrong for your environment!
            url: http://ghost.terryye.com/
            # contrary to the default mentioned in the linked documentation, this image defaults to NODE_ENV=production (so development mode needs to be explicitly specified if desired)
            #NODE_ENV: development
        volumes:
            - ghost:/var/lib/ghost/content
volumes:
    ghost:
EOC
sudo chmod 600 /home/ubuntu/ghost/docker-compose.yml
cd /home/ubuntu/ghost
sudo docker compose -f /home/ubuntu/ghost/docker-compose.yml up -d
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance"
    }
  }  
}

variable "subnet_ids" {
  type = list(string)
}

variable "ec2_security_group_id" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_name" {
  type = string
}

output "launch_template_id" {
  value = aws_launch_template.webapp_launch_template.id
}