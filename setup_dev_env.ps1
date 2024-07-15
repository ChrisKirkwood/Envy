# Load the configuration file
$config = Get-Content -Raw -Path "C:\EnviSetUp\config.json" | ConvertFrom-Json

# Logging function
function Log-Message($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
    Add-Content -Path "C:\EnviSetUp\setup_log.txt" -Value $logMessage
}

# Function to check if a command exists
function CommandExists($command) {
    $null = & cmd.exe /c $command --version 2>$null
    return $LASTEXITCODE -eq 0
}

# Function to set environment variables
function Set-EnvVariable($name, $value) {
    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
}

# Create directories if they don't exist
$paths = $config.paths.PSObject.Properties | ForEach-Object { $_.Value }
foreach ($path in $paths) {
    if (!(Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Directory -Force
    }
}

# Install Node.js
try {
    if (!(CommandExists node)) {
        Log-Message "Installing Node.js..."
        Invoke-WebRequest -Uri "https://nodejs.org/dist/v$config.nodeVersion/node-v$config.nodeVersion-x64.msi" -OutFile "$($config.paths.nodePath)\nodejs.msi"
        Start-Process msiexec.exe -ArgumentList "/i $($config.paths.nodePath)\nodejs.msi /quiet" -Wait
        Remove-Item "$($config.paths.nodePath)\nodejs.msi"
        Log-Message "Node.js installation complete."
    } else {
        Log-Message "Node.js is already installed."
    }
} catch {
    Log-Message "Failed to install Node.js: $_"
}

# Breakpoint
Log-Message "Breakpoint 1: Node.js installation step complete."

# Install Python
try {
    if (!(CommandExists python)) {
        Log-Message "Installing Python..."
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$($config.pythonVersion)/python-$($config.pythonVersion)-amd64.exe" -OutFile "$($config.paths.pythonPath)\python.exe"
        Start-Process "$($config.paths.pythonPath)\python.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item "$($config.paths.pythonPath)\python.exe"
        Log-Message "Python installation complete."
    } else {
        Log-Message "Python is already installed."
    }
} catch {
    Log-Message "Failed to install Python: $_"
}

# Breakpoint
Log-Message "Breakpoint 2: Python installation step complete."

# Install Git
try {
    if (!(CommandExists git)) {
        Log-Message "Installing Git..."
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v$config.gitVersion/Git-$($config.gitVersion)-64-bit.exe" -OutFile "$($config.paths.gitPath)\git.exe"
        Start-Process "$($config.paths.gitPath)\git.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
        Remove-Item "$($config.paths.gitPath)\git.exe"
        Log-Message "Git installation complete."
    } else {
        Log-Message "Git is already installed."
    }
} catch {
    Log-Message "Failed to install Git: $_"
}

# Breakpoint
Log-Message "Breakpoint 3: Git installation step complete."

# Install Docker
try {
    if (!(CommandExists docker)) {
        Log-Message "Installing Docker..."
        Invoke-WebRequest -Uri "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile "$($config.paths.dockerPath)\docker.exe"
        Start-Process "$($config.paths.dockerPath)\docker.exe" -ArgumentList "/quiet" -Wait
        Remove-Item "$($config.paths.dockerPath)\docker.exe"
        Log-Message "Docker installation complete."
    } else {
        Log-Message "Docker is already installed."
    }
} catch {
    Log-Message "Failed to install Docker: $_"
}

# Breakpoint
Log-Message "Breakpoint 4: Docker installation step complete."

# Install Gradle
try {
    if (!(CommandExists gradle)) {
        Log-Message "Installing Gradle..."
        Invoke-WebRequest -Uri "https://services.gradle.org/distributions/gradle-$($config.gradleVersion)-bin.zip" -OutFile "$($config.paths.gradlePath)\gradle.zip"
        Expand-Archive -Path "$($config.paths.gradlePath)\gradle.zip" -DestinationPath $config.paths.gradlePath
        Remove-Item "$($config.paths.gradlePath)\gradle.zip"
        Log-Message "Gradle installation complete."
    } else {
        Log-Message "Gradle is already installed."
    }
} catch {
    Log-Message "Failed to install Gradle: $_"
}

# Breakpoint
Log-Message "Breakpoint 5: Gradle installation step complete."

# Set environment variables
try {
    Set-EnvVariable "NODEJS_HOME" $config.paths.nodePath
    Set-EnvVariable "PYTHON_HOME" $config.paths.pythonPath
    Set-EnvVariable "GIT_HOME" $config.paths.gitPath
    Set-EnvVariable "DOCKER_HOME" $config.paths.dockerPath
    Set-EnvVariable "GRADLE_HOME" "$($config.paths.gradlePath)\gradle-$($config.gradleVersion)"

    foreach ($name in $config.additionalPaths.PSObject.Properties.Name) {
        Set-EnvVariable $name $config.additionalPaths.$name
    }

    Set-EnvVariable "Path" "$env:Path;$($config.paths.nodePath);$($config.paths.pythonPath);$($config.paths.gitPath);$($config.paths.dockerPath);$($config.paths.gradlePath)\gradle-$($config.gradleVersion)\bin;$($config.additionalPaths.JAVA_HOME)\bin;$($config.additionalPaths.MAVEN_HOME)\bin;$($config.additionalPaths.ANDROID_SDK_ROOT)\tools;$($config.additionalPaths.ANDROID_SDK_ROOT)\platform-tools"
    Log-Message "Environment variables set."
} catch {
    Log-Message "Failed to set environment variables: $_"
}

# Breakpoint
Log-Message "Breakpoint 6: Environment variables setup step complete."

Log-Message "Development environment setup complete."
