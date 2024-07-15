# Load the configuration file
$config = Get-Content -Raw -Path "C:\EnviSetUp\config.json" | ConvertFrom-Json

# Function to check if a command exists
function CommandExists($command) {
    $null = & cmd.exe /c $command --version 2>$null
    return $LASTEXITCODE -eq 0
}

# Function to update a tool
function Update-Tool($toolName, $version, $downloadUri, $installPath) {
    if (CommandExists $toolName) {
        Write-Output "$toolName is installed. Checking for updates..."
        # Assuming a method to check the installed version and compare with the config version
        # This part will vary based on the tool and how versions are managed
        $installedVersion = & $toolName --version
        if ($installedVersion -ne $version) {
            Write-Output "Updating $toolName to version $version..."
            Invoke-WebRequest -Uri $downloadUri -OutFile "$installPath\$toolName.exe"
            Start-Process "$installPath\$toolName.exe" -ArgumentList "/quiet" -Wait
            Remove-Item "$installPath\$toolName.exe"
        } else {
            Write-Output "$toolName is up-to-date."
        }
    } else {
        Write-Output "$toolName is not installed."
    }
}

# Update tools based on the configuration
Update-Tool "node" $config.nodeVersion "https://nodejs.org/dist/v$config.nodeVersion/node-v$config.nodeVersion-x64.msi" $config.paths.nodePath
Update-Tool "python" $config.pythonVersion "https://www.python.org/ftp/python/$($config.pythonVersion)/python-$($config.pythonVersion)-amd64.exe" $config.paths.pythonPath
Update-Tool "git" $config.gitVersion "https://github.com/git-for-windows/git/releases/download/v$config.gitVersion/Git-$($config.gitVersion)-64-bit.exe" $config.paths.gitPath
# Add more tools as needed

Write-Output "Tool update process complete."
