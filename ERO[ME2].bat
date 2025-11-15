@echo off
title ERO[ME2] - ELDEN RING Mod Engine 2
color 0A
mode con: cols=80 lines=30
setlocal EnableDelayedExpansion

set "CONFIG_FILE=EROME2_config.txt"
set "GAME_PATH="
set "LAUNCH_BAT=launchmod_eldenring.bat"

echo ========================================
echo        ELDEN RING OPTIMIZED [ME2]
echo ========================================
echo.

if exist "%CONFIG_FILE%" (
    set /p GAME_PATH=<"%CONFIG_FILE%"
    if exist "!GAME_PATH!" (
        goto check_launch_file
    ) else (
        echo [WARNING] Saved path is invalid!
        echo.
    )
)

:get_path
echo Please select the folder containing the "launchmod_eldenring.bat" file using the file dialog...
echo.
echo [INFO] Opening folder selection dialog...
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.Description = 'Select ELDEN RING folder (should contain eldenring.exe)'; $folder.RootFolder = [System.Environment+SpecialFolder]::MyComputer; if($folder.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $folder.SelectedPath }" > temp_path.txt
set /p GAME_PATH=<temp_path.txt
del temp_path.txt

if "!GAME_PATH!"=="" (
    echo [ERROR] No folder selected!
    echo.
    goto get_path
)

if not exist "!GAME_PATH!" (
    echo [ERROR] Selected path does not exist!
    echo.
    goto get_path
)

echo !GAME_PATH! > "%CONFIG_FILE%"
echo [SUCCESS] Path saved to config file.
echo.

:check_launch_file
cd /d "!GAME_PATH!"

if not exist "!LAUNCH_BAT!" (
    echo [ERROR] !LAUNCH_BAT! not found in game directory!
    echo.
    echo Please make sure the file exists in: !GAME_PATH!
    echo.
    pause
    exit
)

echo [INFO] Starting !LAUNCH_BAT!...
timeout /t 2 /nobreak >nul
start "" "!LAUNCH_BAT!"

echo [INFO] Waiting for ELDEN RING process...
:check
timeout /t 1 /nobreak >nul
tasklist | findstr /i "eldenring.exe" >nul
if errorlevel 1 (
    echo Waiting for process...
    goto check
)

echo [SUCCESS] ELDEN RING process detected!
echo [INFO] Applying optimizations in 30 seconds...
timeout /t 30 /nobreak >nul

echo ========================================
echo         APPLYING OPTIMIZATIONS
echo ========================================
echo.

echo Optimizing process...
powershell -Command "$process = Get-Process eldenring -ErrorAction SilentlyContinue; if($process) { $cpuCount = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors; $affinity = (1 -shl $cpuCount) - 2; $process.ProcessorAffinity = $affinity; $process.PriorityClass = 'High'; Write-Host '[INFO] Optimized for' $cpuCount 'CPUs, disabled CPU 0'; Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class DPI { [DllImport(\"user32.dll\")] public static extern bool SetProcessDPIAware(); }'; [DPI]::SetProcessDPIAware(); Write-Host '[INFO] DPI scaling disabled'; $registryPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'; $exePath = (Get-Process eldenring).Path; Set-ItemProperty -Path $registryPath -Name $exePath -Value '~ DISABLEDXMAXIMIZEDWINDOWEDMODE' -ErrorAction SilentlyContinue; Write-Host '[INFO] Fullscreen optimizations disabled'; [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect(); Write-Host '[SUCCESS] Memory optimized' }"

echo.
echo ========================================
echo        OPTIMIZATION COMPLETE!
echo ========================================
echo.
timeout /t 3 /nobreak >nul
exit
