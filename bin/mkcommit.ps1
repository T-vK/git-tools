# PowerShell script to create a commit following a convention

$ticketType = ""
$ticketId = ""
$commitDescription = ""

function Show-Menu {
    param (
        [string]$Title,
        [string]$Message,
        [array]$Options
    )
    
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host $Message
    Write-Host ""
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "$($i+1). $($Options[$i])"
    }
    
    Write-Host ""
    $selection = Read-Host "Please make a selection"
    return $selection
}

# Ticket type selection
$ticketOptions = @(
    "fix: A bug fix",
    "feat: A new feature",
    "refactor: A code change that neither fixes a bug nor adds a feature",
    "test: Adding missing tests or correcting existing tests",
    "build: Changes that affect the build system or external dependencies",
    "docs: Documentation only changes",
    "ci: Changes to our CI configuration files and scripts",
    "style: Changes that do not affect the meaning of the code",
    "perf: A code change that improves performance"
)

$ticketChoice = Show-Menu -Title "Commit Helper" -Message "Choose the ticket type:" -Options $ticketOptions

switch ($ticketChoice) {
    1 { $ticketType = "fix" }
    2 { $ticketType = "feat" }
    3 { $ticketType = "refactor" }
    4 { $ticketType = "test" }
    5 { $ticketType = "build" }
    6 { $ticketType = "docs" }
    7 { $ticketType = "ci" }
    8 { $ticketType = "style" }
    9 { $ticketType = "perf" }
    default { 
        Write-Host "Invalid selection"
        exit 1
    }
}

# Get Jira Ticket ID
$ticketIdInput = Read-Host "Enter the Jira Ticket ID: CCS-"
$ticketId = "CCS-$ticketIdInput"

if ($ticketId -notmatch "^CCS-[0-9]+$") {
    Write-Host "ERROR: Invalid Ticket ID. Ticket IDs must match with this regex format /^CCS-\d+$/"
    exit 1
}

# Get commit description
$commitDescription = Read-Host "Enter a commit description"

# Create commit message
$commitMessage = "$ticketType($ticketId): $commitDescription"

$response = Read-Host "Your commit message is '$commitMessage', would you like to make the commit now? (Y/n)"
if ($response -ne "n" -and $response -ne "N") {
    git commit -m $commitMessage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed make commit"
        exit 1
    }
} else {
    exit 1
}

$response = Read-Host "Would you like to push now? (y/N)"
if ($response -eq "y" -or $response -eq "Y") {
    git push
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to push"
        exit 1
    }
} 