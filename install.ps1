# Windows Installation Script for Git Tools

# Get the current directory
$currentDir = $PSScriptRoot

# Create the path extension
$pathExtension = "$currentDir\bin"

# Add to PATH environment variable (for current session)
$env:Path += ";$pathExtension"

# Add to PATH environment variable (permanently)
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $currentPath.Contains($pathExtension)) {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$pathExtension", "User")
    Write-Host "Added git-tools to your PATH environment variable!"
}

# Create PowerShell profile if it doesn't exist
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    Write-Host "Created PowerShell profile at $PROFILE"
}

# Add bin path to PowerShell profile
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
$pathAddition = "`$env:Path += `";$pathExtension`""
if (-not ($profileContent -contains $pathAddition)) {
    Add-Content -Path $PROFILE -Value "`n# Git Tools Path" -ErrorAction SilentlyContinue
    Add-Content -Path $PROFILE -Value $pathAddition -ErrorAction SilentlyContinue
    Write-Host "Added git-tools path to your PowerShell profile!"
}

Write-Host "Installation complete! Please restart your PowerShell session to use the git-tools." 