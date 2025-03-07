# PowerShell script for commit-msg hook

param (
    [string]$MsgFile
)

# Read the commit message from the file
$fileContent = Get-Content $MsgFile -Raw

# Define the regex pattern for commit messages
$regex = "^(build|ci|docs|feat|fix|perf|refactor|style|test)\(CCS-[0-9]+\): .*"
$errorMsg = "Commit message format must match regex `"$regex`""

# Check if the commit message matches the pattern
if ($fileContent -match $regex) {
    Write-Host "Nice commit!"
    exit 0
} else {
    Write-Host "Bad commit `"$fileContent`", check format."
    Write-Host $errorMsg
    exit 1
} 