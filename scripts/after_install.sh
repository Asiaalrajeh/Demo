#!/bin/bash
# This script runs after the application files are copied

# Determine instance role based on the Name tag
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

if [[ "$INSTANCE_NAME" == "Demo-FrontendInstance" ]]; then
    echo "Setting up frontend application"
    # Copy frontend files from temporary location to web root
    sudo cp -r /tmp/deployment/frontend/* /var/www/html/
    
    # Navigate to frontend directory
    cd /var/www/html
    
    # Install dependencies
    echo "Installing frontend dependencies"
    npm install
    
    # Build the frontend application (if using a framework like React)
    echo "Building frontend application"
    npm run build
    
    # Set proper permissions
    sudo chmod -R 755 /var/www/html
    
elif [[ "$INSTANCE_NAME" == "Demo-BackendInstance" ]]; then
    echo "Setting up backend application"
    # Copy backend files from temporary location to api directory
    sudo cp -r /tmp/deployment/backend/* /var/www/api/
    
    # Navigate to backend directory
    cd /var/www/api
    
    # Install dependencies
    echo "Installing backend dependencies"
    npm install
    
    # Set proper permissions
    sudo chmod -R 755 /var/www/api
    
    # Create or update environment file if needed
    echo "Setting up environment configuration"
    # Example: Copy from a template
    # cp .env.template .env
fi

echo "After install completed successfully"
