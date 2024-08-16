# AWS-Connect
Quick bash/awscli functions for connecting to AWS instances by instance IDs.

## Requirements
- AWS CLI installed and configured.
- SSH key file for connecting to your instances.
- Instance ID and region as listed in AWS console.

## Easy usage

To connect to an instance (and start it if it's turned off):
`awsgo <key_file> <region> <instance_id>`

## Advanced usage

To start an EC2 instance:
`awsstart <region> <instance_id>`

To get the DNS of an instance by its ID:
`awsgetdns <region> <instance_id>`

To get the public DNS of an instance by its Name tag:
`awsgetdnsbyname <region> <name>`

To connect to an EC2 instance using the public DNS:
`awsconnect <key_file> <public_dns>`