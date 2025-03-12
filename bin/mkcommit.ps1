# PowerShell script to create a commit following a convention

# Import prefix utilities
Import-Module (Join-Path $PSScriptRoot "prefix-utils.psm1")

$ticketType = ""
$ticketId = ""
$commitDescription = ""
$prefixHistoryFile = Join-Path $PSScriptRoot "prefix_history.json"

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

# Load prefix history if exists
function Get-PrefixHistory {
    if (Test-Path $prefixHistoryFile) {
        try {
            $prefixHistory = Get-Content $prefixHistoryFile -Raw | ConvertFrom-Json
            # Ensure we have an array even if there's only one item
            if ($prefixHistory -is [string]) {
                $prefixHistory = @($prefixHistory)
            }
            return $prefixHistory
        } catch {
            Write-Host "Warning: Could not read prefix history file. Creating a new one."
            return @()
        }
    } else {
        return @()
    }
}

# Save prefix to history
function Save-PrefixToHistory {
    param (
        [string]$Prefix
    )
    
    $prefixHistory = Get-PrefixHistory
    
    # Check if prefix already exists in history
    if ($prefixHistory -notcontains $Prefix) {
        # Create a new array to ensure we don't concatenate strings
        $newPrefixHistory = @()
        
        # Add existing prefixes
        foreach ($existingPrefix in $prefixHistory) {
            if ($existingPrefix -ne "") {
                $newPrefixHistory += $existingPrefix
            }
        }
        
        # Add the new prefix
        $newPrefixHistory += $Prefix
        
        # Save as JSON array by wrapping in @()
        @($newPrefixHistory) | ConvertTo-Json | Set-Content $prefixHistoryFile
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

# Get Jira Ticket Prefix and ID
$prefixHistory = Get-PrefixHistory
$ticketPrefix = ""

if ($prefixHistory.Count -gt 0) {
    # Create a new array with all prefixes and "New prefix" as the last option
    $prefixOptions = @()
    foreach ($prefix in $prefixHistory) {
        if ($prefix -ne "") {
            $prefixOptions += $prefix
        }
    }
    $prefixOptions += "New prefix"
    
    $prefixChoice = Show-Menu -Title "Commit Helper" -Message "Choose a project prefix or create a new one:" -Options $prefixOptions
    
    if ([int]$prefixChoice -le $prefixOptions.Count - 1) {
        $ticketPrefix = $prefixOptions[[int]$prefixChoice - 1]
    } else {
        $ticketPrefix = Read-Host "Enter the Jira Ticket Prefix (e.g. CCS, ABC, XYZ)"
        if ($ticketPrefix -notmatch "^[A-Z]+$") {
            Write-Host "ERROR: Invalid Ticket Prefix. Prefixes must contain only uppercase letters."
            exit 1
        }
        # Save the new prefix to history
        Save-PrefixToHistory -Prefix $ticketPrefix
    }
} else {
    $ticketPrefix = Read-Host "Enter the Jira Ticket Prefix (e.g. CCS, ABC, XYZ)"
    if ($ticketPrefix -notmatch "^[A-Z]+$") {
        Write-Host "ERROR: Invalid Ticket Prefix. Prefixes must contain only uppercase letters."
        exit 1
    }
    # Save the new prefix to history
    Save-PrefixToHistory -Prefix $ticketPrefix
}

# Debug output to verify the prefix
Write-Host "Using prefix: $ticketPrefix"

$ticketIdInput = Read-Host "Enter the Jira Ticket ID (numbers only)"
$ticketId = "$ticketPrefix-$ticketIdInput"

if ($ticketId -notmatch "^[A-Z]+-[0-9]+$") {
    Write-Host "ERROR: Invalid Ticket ID. Ticket IDs must match with this regex format /^[A-Z]+-\d+$/"
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