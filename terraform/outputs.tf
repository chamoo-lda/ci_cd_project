output "public_ip" {
  description = "Public IP of the EC2 web server"
  value       = aws_instance.server.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.server.id
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/ansible-user ubuntu@${aws_instance.server.public_ip}"
}
