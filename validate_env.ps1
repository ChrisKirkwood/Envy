# Load the configuration file
$config = Get-Content -Raw -Path "C:\EnviSetUp\config.json" | ConvertFrom-Json

# Function to validate environment variable
function Validate-EnvVariable($name, $expectedValue) {
    $actualValue = [System.Environment]::GetEnvironmentVariable($name, [System.EnvironmentVariableTarget]::Machine)
    if ($actualValue -ne $expectedValue) {
        Write-Output "Warning: Environment variable $name is set to $actualValue but expected $expectedValue"
    } else {
        Write-Output "Environment variable $name is correctly set to $expectedValue"
    }
}

# Validate paths
Validate-EnvVariable "NODEJS_HOME" $config.paths.nodePath
Validate-EnvVariable "PYTHON_HOME" $config.paths.pythonPath
Validate-EnvVariable "GIT_HOME" $config.paths.gitPath
Validate-EnvVariable "DOCKER_HOME" $config.paths.dockerPath
Validate-EnvVariable "GRADLE_HOME" "$($config.paths.gradlePath)\gradle-$($config.gradleVersion)"

Write-Output "Environment validation complete."
