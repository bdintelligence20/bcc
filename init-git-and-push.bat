@echo off
REM Script to initialize Git repository and push to GitHub for Windows

echo Checking if Git is installed...
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Git is not installed. Please install Git and try again.
    exit /b 1
)

REM Initialize Git repository if not already initialized
if not exist ".git" (
    echo Initializing Git repository...
    git init
) else (
    echo Git repository already initialized.
)

REM Add all files to Git
echo Adding files to Git...
git add .

REM Commit the changes
echo Committing changes...
set /p commit_message=Enter commit message (default: 'Initial commit'): 
if "%commit_message%"=="" set commit_message=Initial commit
git commit -m "%commit_message%"

REM Add GitHub remote
echo Adding GitHub remote...
set /p github_url=Enter GitHub repository URL (e.g., https://github.com/username/repo.git): 

if "%github_url%"=="" (
    echo GitHub URL is required. Exiting.
    exit /b 1
)

REM Check if remote already exists
git remote | findstr "origin" >nul
if %ERRORLEVEL% equ 0 (
    echo Remote 'origin' already exists. Updating URL...
    git remote set-url origin "%github_url%"
) else (
    echo Adding remote 'origin'...
    git remote add origin "%github_url%"
)

REM Push to GitHub
echo Pushing to GitHub...
set /p branch_name=Enter branch name (default: 'main'): 
if "%branch_name%"=="" set branch_name=main

REM Check if the branch exists
git show-ref --verify --quiet refs/heads/%branch_name%
if %ERRORLEVEL% neq 0 (
    echo Branch '%branch_name%' does not exist. Creating it...
    git checkout -b %branch_name%
)

git push -u origin %branch_name%

echo Repository successfully pushed to GitHub!
echo Next steps:
echo 1. Create a Cloud Build trigger in the GCP Console
echo 2. Set the trigger to use the 'cloudbuild-vm-backend.yaml' configuration file
echo 3. Run the trigger to deploy the application

pause
