@echo off
echo Starting ELDEN RING...

if exist "ersc_launcher.exe" (
    start "" "ersc_launcher.exe"
) else (
    if exist "eldenring.exe" (
        start "" "eldenring.exe"
    ) else (
        echo Error: Neither ersc_launcher.exe nor eldenring.exe found!
        pause
        exit
    )
)

:check
timeout /t 1 /nobreak >nul
tasklist | findstr /i "eldenring.exe" >nul
if errorlevel 1 goto check

echo ELDEN RING Optimized process...
timeout /t 20 /nobreak >nul

powershell -Command "$process = Get-Process eldenring -ErrorAction SilentlyContinue; if($process) { $cpuCount = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors; $affinity = (1 -shl $cpuCount) - 2; $process.ProcessorAffinity = $affinity; $process.PriorityClass = 'High'; Write-Host 'Optimized for' $cpuCount 'CPUs, disabled CPU 0' }"
exit
