output "instance_public_ip" {
  value       = module.ec2.instance_public_ip
  description = "Public IP of the GPT4All EC2 instance"
}
