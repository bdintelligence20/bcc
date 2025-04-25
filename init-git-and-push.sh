#!/bin/bash

# Initialize Git and push to GitHub
# Usage: ./init-git-and-push.sh <github-username> <repository-name>

# Check if arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <github-username> <repository-name>"
    exit 1
fi

GITHUB_USERNAME=$1
REPO_NAME=$2

echo "Initializing Git repository..."
git init

echo "Adding files to Git..."
git add .

echo "Committing files..."
git commit -m "Initial commit"

echo "Adding GitHub remote..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

echo "Pushing to GitHub..."
git push -u origin master

echo "Done! Your code is now on GitHub at https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "You can now proceed with the GCP deployment as described in the deployment-guide.md file."
