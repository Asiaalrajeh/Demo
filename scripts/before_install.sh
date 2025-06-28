#!/bin/bash
# This script runs before the application is installed

# Determine instance role based on the Name tag
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

echo "Starting deployment on instance: $INSTANCE_NAME"

# Clean up the destination directory based on instance name
if [[ "$INSTANCE_NAME" == "Demo-FrontendInstance" ]]; then
    echo "Preparing frontend deployment"
    # Clean frontend directory
    sudo rm -rf /var/www/html/*
    # Install frontend dependencies if needed
    sudo yum install -y nodejs npm
elif [[ "$INSTANCE_NAME" == "Demo-BackendInstance" ]]; then
    echo "Preparing backend deployment"
    # Clean backend directory
    sudo rm -rf /var/www/api/*
    # Install backend dependencies if needed
    sudo yum install -y nodejs npm
    # Install PM2 globally if using it
    sudo npm install -g pm2
else
    echo "Unknown instance name: $INSTANCE_NAME"
    exit 1
fi

echo "Before install completed successfully"
