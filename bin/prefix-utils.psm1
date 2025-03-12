# Common prefix history functions
$script:prefixHistoryFile = Join-Path $PSScriptRoot "prefix_history.json"

function Get-PrefixHistory {
    if (Test-Path $script:prefixHistoryFile) {
        try {
            $prefixHistory = Get-Content $script:prefixHistoryFile -Raw | ConvertFrom-Json
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
        @($newPrefixHistory) | ConvertTo-Json | Set-Content $script:prefixHistoryFile
    }
}

# Export functions to make them available when importing the module
Export-ModuleMember -Function Get-PrefixHistory, Save-PrefixToHistory 