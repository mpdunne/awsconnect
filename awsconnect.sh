#!/bin/bash

function awsstart {
    region=$1
    instance_id=$2

    echo "Starting instance: $region $instance_id"
    aws ec2 start-instances --region "$region" --instance-ids "$instance_id" > /dev/null

    while true; do
        state=$(aws ec2 describe-instances \
            --region "$region" \
            --instance-ids "$instance_id" \
            --query "Reservations[0].Instances[0].State.Name" \
            --output text)

        echo "Current state: $state"
	if [ "$state" = "running" ]; then
            echo "Instance successfully started"
            sleep 2
            break
        fi

        echo "Waiting 10 seconds..."
        sleep 10
    done
}

function awsconnect {
        key_file=$1
	remote_user=$2
        public_dns=$3
        shift 3
        echo "Connecting to ${public_dns}"
        ssh -i $key_file "$@" "$remote_user@${public_dns}"
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
	remote_user=$2
        region=$3
        instance_id=$4
        shift 4

        echo "Getting the ip address..."
        public_dns=$(awsgetdns $region $instance_id)

        if [[ "$public_dns" == "" ]]; then
                awsstart $region $instance_id
                public_dns=$(awsgetdns $region $instance_id)
        fi

        if [[ "$public_dns" == "" ]]; then
                echo "Could not get the ip address of ${instance_id}, it is not reachable."
        else
                awsconnect $key_file $remote_user $public_dns "$@"
        fi
}
