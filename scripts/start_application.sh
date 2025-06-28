#!/bin/bash
# This script starts or restarts the application

# Determine instance role based on the Name tag
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)

if [[ "$INSTANCE_NAME" == "Demo-FrontendInstance" ]]; then
    echo "Starting frontend services"
    # If using nginx to serve frontend
    if systemctl is-active --quiet nginx; then
        echo "Restarting Nginx"
        sudo systemctl restart nginx
    else
        echo "Starting Nginx"
        sudo systemctl start nginx
    fi
    
elif [[ "$INSTANCE_NAME" == "Demo-BackendInstance" ]]; then
    echo "Starting backend services"
    cd /var/www/api
    
    # If using PM2 for Node.js process management
    if command -v pm2 &> /dev/null; then
        # Check if app is already registered with PM2
        if pm2 list | grep -q "api-server"; then
            echo "Restarting backend application with PM2"
            pm2 restart api-server
        else
            echo "Starting backend application with PM2"
            pm2 start app.js --name "api-server"
            # Save PM2 configuration to survive system restarts
            pm2 save
        fi
    else
        # Fallback if PM2 is not available
        echo "Starting backend application with Node"
        nohup node app.js > app.log 2>&1 &
    fi
fi

echo "Application started successfully"
