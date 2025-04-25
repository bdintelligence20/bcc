@echo off
REM Initialize Git and push to GitHub
REM Usage: init-git-and-push.bat <github-username> <repository-name>

REM Check if arguments are provided
if "%~1"=="" (
    echo Usage: %0 ^<bdintelligence20^> ^<bcc^>
    exit /b 1
)
if "%~2"=="" (
    echo Usage: %0 ^<bdintelligence20^> ^<bcc^>
    exit /b 1
)

set GITHUB_USERNAME=%~1
set REPO_NAME=%~2

echo Initializing Git repository...
git init

echo Adding files to Git...
git add .

echo Committing files...
git commit -m "Initial commit"

echo Adding GitHub remote...
git remote add origin https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git

echo Pushing to GitHub...
git push -u origin master

echo Done! Your code is now on GitHub at https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
echo You can now proceed with the GCP deployment as described in the deployment-guide.md file.
