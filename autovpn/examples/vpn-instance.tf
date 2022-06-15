# Example for running the VPN service with Terraform

  instance_type = "a1.medium"     # ARM type of EC2 instance
  key_name               = "keypair"
  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  subnet_id              = "${module.vpc.public_subnets[0]}"  
  count = 2

  associate_public_ip_address = true
  source_dest_check           = false
  monitoring                  = true

  connection {
      user     = "ubuntu"
      host = self.public_ip
  }

  provisioner "file" {
    source      = "../scripts/vpn-config.vars"
    destination = "/tmp/vpn-config.vars"
 }

   provisioner "file" {
    source      = "../scripts/vpn-config.sh"
    destination = "/tmp/vpn-config.sh"
 }

  user_data = <<-EOF
                #!/bin/bash
                # Wrapper for running configuration script 
                COUNTER=0
                while [ ! -n /tmp/vpn-config.sh ] && [ ! -n /tmp/vpn-config.vars ] || [  $COUNTER -lt 10 ];
                do
                    let COUNTER=COUNTER+1
                    sleep 5
                done
                if [ ! -n /tmp/vpn-config.sh ] || [ ! -n /tmp/vpn-config.vars ]
                then
                    echo "Error: Files vpn-config.sh or /tmp/vpn-config.vars doesn't exist"
                    exit -1
                fi           
                echo "Debug: Running VPN configuration script: /tmp/vpn-config.sh"
                sudo bash /tmp/vpn-config.sh > /tmp/vpn-config.log 2>&1 && echo "Debug: script VPN config finished normally"
                EOF

  tags = {
    Name = "vpn-service-${count.index}",
    Service = "vpn",
    Type = "core",
    Env = "Prod"
  }
}
