# Define environment variables and paths
$flutterPath = "C:\FlutterSDKTools\flutter" # Update with your Flutter SDK path
$projectPath = "C:\Users\Eng.Rokaya\StudioProjects\proj_20p4322" # Update with the path to your project directory
$testFile = "C:\Users\Eng.Rokaya\StudioProjects\proj_20p4322\integration_test\scenario_test.dart" # Path to your integration test
$deviceName = "Pixel_8_Pro_API_27" # Update with the device ID (use 'adb devices' to check available devices)
$logFile = "test_logs.txt" # Log file where test output will be saved

# Set the working directory to the project path
Set-Location -Path $projectPath

# Ensure Flutter is properly set up
$flutterVersion = & "$flutterPath\bin\flutter" --version
Write-Host "Flutter version: $flutterVersion"

# Check if Android Emulator is running
$adbDevices = & "$flutterPath\bin\flutter" devices
if ($adbDevices -notmatch $deviceName) {
    Write-Host "Starting Android emulator..."
    Start-Process "C:\Users\Eng.Rokaya\AppData\Local\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd", "Pixel 8 Pro API 27" 
    Start-Sleep -Seconds 15 # Wait for the emulator to boot up
}

# Ensure Firebase dependencies are initialized and ready
Write-Host "Initializing Firebase..."
& "$flutterPath\bin\flutter" pub get

# Run the integration test using Flutter
Write-Host "Running integration test..."
$testCommand = "& `$flutterPath\bin\flutter` test C:\Users\Eng.Rokaya\StudioProjects\proj_20p4322\integration_test\scenario_test.dart"
$testResult = Invoke-Expression $testCommand

# Save test logs to a file
$testResult | Out-File -FilePath $logFile

# Check test results
$testOutput = Get-Content $logFile

# Analyze the test output for success or failure
if ($testOutput -match "All tests passed!") {
    Write-Host "Test passed successfully!"
} else {
    Write-Host "Test failed. Check the log file for details."
    Write-Host "Log file: $logFile"
}

# Optional: Disconnect or clean up if needed
Write-Host "Test run completed."
