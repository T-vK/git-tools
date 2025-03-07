# PowerShell script to create a branch following a convention

$ticketType = ""
$ticketId = ""
$branchDescription = ""
$branchSuffix = ""

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

# Branch type selection
$branchOptions = @(
    "Feature Branch",
    "Dev Branch",
    "Hotfix Branch"
)

$branchChoice = Show-Menu -Title "Branch Helper" -Message "Choose what kind of branch you want to create:" -Options $branchOptions

switch ($branchChoice) {
    1 { $branchSuffix = "main" }
    2 { 
        $branchSuffix = Read-Host "Enter your 3 letter lower-case username (e.g. tvk, mwm, ofi, kho, ...)"
        if ($branchSuffix -notmatch "^[a-z][a-z][a-z]$") {
            Write-Host "ERROR: Invalid 3-letter username!"
            exit 1
        }
    }
    3 { $branchSuffix = "hotfix" }
    default { 
        Write-Host "Invalid selection"
        exit 1
    }
}

if ($branchSuffix -eq "main" -or $branchSuffix -eq "hotfix") {
    $response = Read-Host "Would you like to checkout and pull the latest develop branch first? (Y/n)"
    if ($response -ne "n" -and $response -ne "N") {
        git checkout develop
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to checkout develop"
            exit 1
        }
        
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to pull develop"
            exit 1
        }
    }
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

$ticketChoice = Show-Menu -Title "Branch Helper" -Message "Choose the ticket type:" -Options $ticketOptions

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

# Get branch description
$branchDescription = Read-Host "Enter a description for your branch (only lower-case letters, numbers and dashes)"

if ($branchDescription -notmatch "^[a-z0-9-]+$") {
    Write-Host "ERROR: Invalid branch description. branch descriptions can only contain letters, numbers and dashes (-)."
    exit 1
}

# Create branch name
$branchName = "$ticketType/$ticketId/$branchDescription/$branchSuffix"

$response = Read-Host "Your branch name is '$branchName', would you like to create it now? (Y/n)"
if ($response -ne "n" -and $response -ne "N") {
    # Check if repository has commits
    $hasCommits = $false
    try {
        git rev-parse --verify HEAD | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $hasCommits = $true
        }
    } catch {
        $hasCommits = $false
    }
    
    if ($hasCommits) {
        # Get current branch as starting point
        $currentBranch = git rev-parse --abbrev-ref HEAD
        
        # Create branch from current branch
        git branch $branchName $currentBranch
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to create branch"
            exit 1
        }
    } else {
        Write-Host "Repository has no commits yet. Creating an initial commit first..."
        
        # Create an empty commit
        $response = Read-Host "Would you like to create an initial commit? (Y/n)"
        if ($response -ne "n" -and $response -ne "N") {
            git commit --allow-empty -m "Initial commit"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: Failed to create initial commit"
                exit 1
            }
            
            # Now create the branch
            git branch $branchName
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ERROR: Failed to create branch"
                exit 1
            }
        } else {
            Write-Host "Cannot create a branch without at least one commit in the repository."
            exit 1
        }
    }
} else {
    exit 1
}

$response = Read-Host "Would you like to check the branch out now? (Y/n)"
if ($response -ne "n" -and $response -ne "N") {
    git checkout $branchName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to checkout new branch"
        exit 1
    }
} else {
    exit 1
} 