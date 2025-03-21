#!/bin/bash

function awsstart {
        region=$1
        instance_id=$2
        echo "Starting instance: $region $instance_id"
        aws ec2 start-instances --region $region --instance-ids "$instance_id"
        echo "Waiting 10 seconds..."
        sleep 10
}

function awsconnect {
        key_file=$1
        public_dns=$2
        shift 2
        echo "Connecting to ${public_dns}"
        ssh -i $key_file "$@" "ubuntu@${public_dns}"
}

function awsgetdns {
        region=$1
        instance_id=$2
        echo $(aws ec2 describe-instances --region $region --filters "Name=instance-id,Values=${instance_id}" --query "Reservations[].Instances[].PublicDnsName" --output text)
}

function awsgetdnsbyname {
        region=$1
        name=$2
        echo $(aws ec2 describe-instances --region $region --filters "Name=tag:Name,Values=${name}" --query "Reservations[].Instances[].PublicDnsName" --output text)
}

function awsgo {
        key_file=$1
        region=$2
        instance_id=$3
        shift 3

        echo "Getting the ip address..."
        public_dns=$(awsgetdns $region $instance_id)

        if [[ "$public_dns" == "" ]]; then
                awsstart $region $instance_id
                public_dns=$(awsgetdns $region $instance_id)
        fi

        if [[ "$public_dns" == "" ]]; then
                echo "Could not get the ip address of ${instance_id}, it is not reachable."
        else
                awsconnect $key_file $public_dns "$@"
        fi
}
