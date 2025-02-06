#!/bin/bash

# Display help message
show_help() {
    echo "Usage: $0 <service-name>"
    echo
    echo "Parameters:"
    echo "  service-name    Name of the service to deploy (required)"
    echo
    echo "Example:"
    echo "  $0 frontend"
    exit 1
}

# Validate parameters
if [ $# -ne 1 ]; then
    echo "Error: Missing required parameter."
    show_help
fi

# Initial configurations
REPO_DIR="/home/ubuntu/app/$1"   # Path to the local repository
DEPLOY_BRANCH="main"            # Main production branch
TEMP_BRANCH="deploy"
DOCKER_COMPOSE_FILE="docker-compose.yml"
SERVICE_NAME="$1"     # Docker service name

# Validate repository directory
if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Repository directory '$REPO_DIR' does not exist."
    exit 1
fi

if [ ! -f "$REPO_DIR/$DOCKER_COMPOSE_FILE" ]; then
    echo "Error: Docker Compose file not found at '$REPO_DIR/$DOCKER_COMPOSE_FILE'"
    exit 1
fi

# Rollback function
rollback() {
  echo ">> Error detected. Reverting to branch $DEPLOY_BRANCH..."
  git checkout $TEMP_BRANCH
  git checkout -b rollback
  docker compose down
  docker compose up -d --build --force-recreate
  echo ">> Rollback completed!"
  exit 1
}

# Step 1: Enter the repository
cd $REPO_DIR || { echo "Error: Could not access the repository."; exit 1; }

# Step 2: Create a temporary branch
git checkout -b $TEMP_BRANCH || { echo "Error: Could not create the branch $TEMP_BRANCH."; exit 1; }

# Step 3: Update the main branch
git checkout $DEPLOY_BRANCH || { echo "Error: Could not switch to branch $DEPLOY_BRANCH."; exit 1; }
git pull || { echo "Error: Could not update branch $DEPLOY_BRANCH."; exit 1; }

# Step 4: Build and start Docker containers
echo ">> Building and starting containers..."
if ! docker compose up -d --build --force-recreate; then
  rollback
fi

# Step 5: Check if the service is running
if ! docker ps | grep -q "$SERVICE_NAME"; then
  rollback
fi

# Step 6: Merge changes and clean up the temporary branch
git branch -D $TEMP_BRANCH 2>/dev/null

echo ">> Deployment completed successfully!"
exit 0