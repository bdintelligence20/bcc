#!/bin/bash
# Script to initialize Git repository and push to GitHub

# Exit on any error
set -e

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
else
    echo "Git repository already initialized."
fi

# Add all files to Git
echo "Adding files to Git..."
git add .

# Commit the changes
echo "Committing changes..."
read -p "Enter commit message (default: 'Initial commit'): " commit_message
commit_message=${commit_message:-"Initial commit"}
git commit -m "$commit_message"

# Add GitHub remote
echo "Adding GitHub remote..."
read -p "Enter GitHub repository URL (e.g., https://github.com/username/repo.git): " github_url

if [ -z "$github_url" ]; then
    echo "GitHub URL is required. Exiting."
    exit 1
fi

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo "Remote 'origin' already exists. Updating URL..."
    git remote set-url origin "$github_url"
else
    echo "Adding remote 'origin'..."
    git remote add origin "$github_url"
fi

# Push to GitHub
echo "Pushing to GitHub..."
read -p "Enter branch name (default: 'main'): " branch_name
branch_name=${branch_name:-"main"}

# Check if the branch exists
if ! git show-ref --verify --quiet refs/heads/$branch_name; then
    echo "Branch '$branch_name' does not exist. Creating it..."
    git checkout -b $branch_name
fi

git push -u origin $branch_name

echo "Repository successfully pushed to GitHub!"
echo "Next steps:"
echo "1. Create a Cloud Build trigger in the GCP Console"
echo "2. Set the trigger to use the 'cloudbuild-vm-backend.yaml' configuration file"
echo "3. Run the trigger to deploy the application"
