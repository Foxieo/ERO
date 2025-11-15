@echo off
title ERO - ELDEN RING Optimized
color 0A
mode con: cols=80 lines=25

echo ========================================
echo      ELDEN RING OPTIMIZED LAUNCHER
echo ========================================
echo.

echo Starting ELDEN RING...
timeout /t 1 /nobreak >nul

set launched=0
set count=0

if exist "ersc_launcher.exe" (
    echo [INFO] Launching via ersc_launcher.exe...
    start "" "ersc_launcher.exe"
    set launched=1
    goto wait_for_process
) else (
    echo [INFO] Attempting to launch via Steam...
    start "" "steam://run/1245620"
    echo [INFO] Waiting for Steam to launch the game...
    
    :check_steam
    timeout /t 3 /nobreak >nul
    tasklist | findstr /i "eldenring.exe" >nul
    if not errorlevel 1 (
        echo [SUCCESS] ELDEN RING launched via Steam!
        set launched=1
        goto wait_for_process
    )
    
    rem If the game doesn't start after 15 seconds, try directly
    set /a count+=1
    if %count% lss 5 (
        echo Waiting for Steam... [%count%/5]
        goto check_steam
    )
    
    echo [WARNING] Steam launch timed out, trying direct launch...
    if exist "eldenring.exe" (
        echo [INFO] Launching via eldenring.exe...
        start "" "eldenring.exe"
        set launched=1
        goto wait_for_process
    ) else (
        echo [ERROR] Neither ersc_launcher.exe nor eldenring.exe found!
        echo [ERROR] Please make sure ELDEN RING is installed.
        echo.
        pause
        exit
    )
)

:wait_for_process
if %launched% equ 1 (
    echo [INFO] Waiting for ELDEN RING to start...
    :check_process
    timeout /t 1 /nobreak >nul
    tasklist | findstr /i "eldenring.exe" >nul
    if errorlevel 1 (
        echo Waiting for process... 
        goto check_process
    )
)

echo [SUCCESS] ELDEN RING process detected!
echo [INFO] Applying optimizations in 30 seconds...
timeout /t 30 /nobreak >nul

echo ========================================
echo        APPLYING OPTIMIZATIONS
echo ========================================
echo.

:optimize
powershell -Command "$process = Get-Process eldenring -ErrorAction SilentlyContinue; if($process) { $cpuCount = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors; $affinity = (1 -shl $cpuCount) - 2; $process.ProcessorAffinity = $affinity; $process.PriorityClass = 'High'; Write-Host '[INFO] Optimized for' $cpuCount 'CPUs, disabled CPU 0'; Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class DPI { [DllImport(\"user32.dll\")] public static extern bool SetProcessDPIAware(); }'; [DPI]::SetProcessDPIAware(); Write-Host '[INFO] DPI scaling disabled'; $registryPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'; $exePath = (Get-Process eldenring).Path; Set-ItemProperty -Path $registryPath -Name $exePath -Value '~ DISABLEDXMAXIMIZEDWINDOWEDMODE' -ErrorAction SilentlyContinue; Write-Host '[INFO] Fullscreen optimizations disabled'; [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect(); Write-Host '[SUCCESS] Memory optimized' }"

echo.
echo ========================================
echo      OPTIMIZATION COMPLETE!
echo ========================================
echo.
exit
