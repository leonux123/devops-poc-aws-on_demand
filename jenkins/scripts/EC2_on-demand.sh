#!/bin/bash

# Script parameters

imageid="ami-a0cfeed8" # Amazon Linux AMI 2018.03.0 (HVM)
instance_type="t2.micro"
key_name="MyKeyPair"
sec_group_TCP="sg-09238c50b5c5aa1c6"
sec_group_9000="sg-092e3f4bf89df868b"
wait_seconds="15" # seconds between polls for the public IP to populate (keeps it from hammering their API)
key_location="/home/leonux/aws/MyKeyPair.pem" # SSH settings
user="ec2-user" # SSH settings


# private
connect ()
{
	ssh -oStrictHostKeyChecking=no -i $key_location $user@$AWS_IP pwd
}

# private
add_tag ()
{	
	aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=production
}

# private
getip ()
{	
	AWS_IP=$(aws ec2 describe-instances --instance-ids $AWS_instance_ID --query 'Reservations[0].Instances[0].PublicIpAddress' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
}

# public
start ()
{
	echo "Starting instance..."	
	
	id=$(aws ec2 run-instances --image-id $imageid --count 1 --instance-type $instance_type --key-name $key_name --security-group-ids $sec_group_TCP $sec_group_9000 --query 'Instances[0].InstanceId' | grep -E -o "i\-[0-9A-Za-z]+")
	
	INSTANCE_ID=$id
	
	# wait for a public ip
	while true; do

		echo "Waiting $wait_seconds seconds for IP..."
		sleep $wait_seconds
		getip
		if [ ! -z "$AWS_IP" ]; then
			break
		else
			echo "Not found yet. Waiting for $wait_seconds more seconds."
			sleep $wait_seconds
		fi

	done

	echo "Found IP $AWS_IP - Instance $INSTANCE_ID"
	
	echo "Adding TAG..."
	
	add_tag
	
	echo "Trying to connect... $user@$AWS_IP"
	
	connect 
}

# public
instruct ()
{
	echo "Please provide an argument: start, terminate"
}

#-------------------------------------------------------

# "main"
case "$1" in
	start)
		start
		;;
	terminate)
		terminate
		;;
	help|*)
		instruct
		;;
esac