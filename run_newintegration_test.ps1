# Define paths
$logFolder = "logs"
$logFile = "$logFolder/integration_test.log"
$driverFile = "integration_test/driver.dart"
$targetFile = "integration_test/scenario_test.dart"
$recordedVideo = "scenario_test.mp4"
$localVideoPath = "$logFolder/$recordedVideo"
$emulatorName = "Pixel_8_Pro_API_27"

# Ensure the logs directory exists
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder
}

# Check if ADB is installed
Write-Host "Checking ADB installation..."
if (!(Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Host "ADB is not installed or not in PATH. Please install ADB and try again." -ForegroundColor Red
    exit 1
}

# Start emulator if not already running
Write-Host "Checking emulator..."
$emulators = & adb devices | Select-String -Pattern "device$" | ForEach-Object { $_.ToString().Split("`t")[0] }
if ($emulators -notcontains $emulatorName) {
    Write-Host "Starting emulator $emulatorName..."
    Start-Process -FilePath "emulator" -ArgumentList "-avd $emulatorName"
    Start-Sleep -Seconds 30
}

# Run Flutter integration test
Write-Host "Running Flutter integration test..."
flutter drive --driver=$driverFile --target=$targetFile --device-id=$emulatorName *> $logFile 2>&1

# Check if the test ran successfully
if ($LASTEXITCODE -eq 0) {
    Write-Host "Integration test completed successfully. Logs saved to $logFile."
} else {
    Write-Host "Integration test failed. Check the logs at $logFile for details." -ForegroundColor Red
}