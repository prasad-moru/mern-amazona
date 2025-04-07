// modules/openvpn/main.tf
resource "aws_security_group" "openvpn" {
  name        = "${var.name_prefix}-openvpn-sg"
  description = "Security group for OpenVPN server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  ingress {
    description = "OpenVPN from anywhere"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for admin interface"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_admin_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-openvpn-sg"
    }
  )
}

resource "aws_eip" "openvpn" {
  domain = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-openvpn-eip"
    }
  )
}

resource "aws_instance" "openvpn" {
  ami                         = var.openvpn_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.openvpn.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
  }

  user_data = <<-EOF
              #!/bin/bash
              export DEBIAN_FRONTEND=noninteractive
              apt-get update
              apt-get upgrade -y
              
              # Install OpenVPN
              apt-get install -y openvpn easy-rsa
              
              # Setup OpenVPN
              mkdir -p /etc/openvpn/easy-rsa
              cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
              
              # Initialize PKI
              cd /etc/openvpn/easy-rsa
              ./easyrsa init-pki
              ./easyrsa build-ca nopass
              ./easyrsa gen-dh
              openvpn --genkey --secret /etc/openvpn/ta.key
              
              # Generate server certificate and key
              ./easyrsa build-server-full server nopass
              
              # Generate client certificates
              for client in user1 user2; do
                ./easyrsa build-client-full $client nopass
              done
              
              # Generate server.conf
              cat > /etc/openvpn/server.conf <<EOT
              port 1194
              proto udp
              dev tun
              ca /etc/openvpn/easy-rsa/pki/ca.crt
              cert /etc/openvpn/easy-rsa/pki/issued/server.crt
              key /etc/openvpn/easy-rsa/pki/private/server.key
              dh /etc/openvpn/easy-rsa/pki/dh.pem
              topology subnet
              ifconfig-pool-persist ipp.txt
              push "redirect-gateway def1 bypass-dhcp"
              push "dhcp-option DNS 8.8.8.8"
              push "dhcp-option DNS 8.8.4.4"
              keepalive 10 120
              tls-auth /etc/openvpn/ta.key 0
              cipher AES-256-CBC
              user nobody
              group nogroup
              persist-key
              persist-tun
              status openvpn-status.log
              verb 3
              EOT
              
              # Enable IP forwarding
              echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-openvpn.conf
              sysctl -p /etc/sysctl.d/99-openvpn.conf
              
              # Setup NAT
              iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
              
              # Create script to generate client configs
              cat > /etc/openvpn/gen_client_config.sh <<EOT
              #!/bin/bash
              CLIENT=\$1
              
              cat > /etc/openvpn/client-configs/\$CLIENT.ovpn <<EOF
              client
              dev tun
              proto udp
              remote $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) 1194
              resolv-retry infinite
              nobind
              persist-key
              persist-tun
              remote-cert-tls server
              cipher AES-256-CBC
              verb 3
              <ca>
              \$(cat /etc/openvpn/easy-rsa/pki/ca.crt)
              </ca>
              <cert>
              \$(cat /etc/openvpn/easy-rsa/pki/issued/\$CLIENT.crt)
              </cert>
              <key>
              \$(cat /etc/openvpn/easy-rsa/pki/private/\$CLIENT.key)
              </key>
              <tls-auth>
              \$(cat /etc/openvpn/ta.key)
              </tls-auth>
              key-direction 1
              EOF
              EOT
              chmod +x /etc/openvpn/gen_client_config.sh
              
              # Generate client configs
              mkdir -p /etc/openvpn/client-configs
              /etc/openvpn/gen_client_config.sh user1
              /etc/openvpn/gen_client_config.sh user2
              
              # Enable and start OpenVPN
              systemctl enable openvpn@server
              systemctl start openvpn@server
              EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-openvpn"
    }
  )
}

resource "aws_eip_association" "openvpn" {
  instance_id   = aws_instance.openvpn.id
  allocation_id = aws_eip.openvpn.id
}