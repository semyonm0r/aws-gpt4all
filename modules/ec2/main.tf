resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_private_key.public_key_openssh

  tags = {
  Name = "${var.tag_prefix}-gpt4all-sshkey"
}
}

resource "aws_instance" "gpt4all_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [var.security_group_id]

  user_data = <<-EOF
            #!/bin/bash
            # Update and install dependencies
            sudo yum update -y
            sudo yum install -y python3 git
            sudo yum install -y python3-pip

            # Install GPT4All dependencies
            pip3 install gpt4all
            # Create a directory for GPT4All
            sudo mkdir -p /home/ec2-user/gpt4all
            # Change ownership of the directory to ec2-user
            sudo chown -R ec2-user:ec2-user /home/ec2-user/gpt4all
            # Format the volume as XFS (adjust if needed based on your volume type)
            sudo mkfs.xfs /dev/xvdh
            sleep 10
            # Mount the volume to the directory
            sudo mount /dev/xvdh /home/ec2-user/gpt4all
            # Clone the GPT4All repository into the mounted directory
            git clone https://github.com/nomic-ai/gpt4all.git /home/ec2-user/gpt4all
            # Adjust ownership again to ensure everything belongs to ec2-user
            sudo chown -R ec2-user:ec2-user /home/ec2-user/gpt4all
            echo "Setup complete."
            EOF

  tags = {
    Name = "${var.tag_prefix}-gpt4all-instance"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_private_key.private_key_pem}' > private_key.pem"
  }

  depends_on = [ aws_ebs_volume.gpt4all_ebs ]
}

resource "aws_ebs_volume" "gpt4all_ebs" {
  availability_zone = "${var.aws_azs}"
  size              = "${var.ebs_size}"
  tags = {
    Name = "${var.tag_prefix}-gpt4all-ebs"
  }
}

resource "aws_volume_attachment" "attach_ebs" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.gpt4all_ebs.id
  instance_id = aws_instance.gpt4all_instance.id
}
