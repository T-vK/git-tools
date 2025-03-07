# PowerShell script to install git hooks

# Get the git-tools directory (parent of the bin directory)
$gitToolsDir = Split-Path -Parent $PSScriptRoot

# Get the git repository directory
$gitRepoDir = git rev-parse --show-toplevel

# Copy the git hooks to the repository's .git/hooks directory
Copy-Item -Path "$gitToolsDir\git-hooks\*" -Destination "$gitRepoDir\.git\hooks\" -Force

Write-Host "Git hooks installed successfully!" 