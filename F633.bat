@shift /0
@echo off
setlocal enabledelayedexpansion
setlocal enableextensions

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

powershell -Command "& {Get-AppxPackage -AllUsers xbox | Remove-AppxPackage}" >nul 2>&1
sc stop XblAuthManager >nul 2>&1
sc stop XblGameSave >nul 2>&1
sc stop XboxNetApiSvc >nul 2>&1
sc stop XboxGipSvc >nul 2>&1
sc delete XblAuthManager >nul 2>&1
sc delete XblGameSave >nul 2>&1
sc delete XboxNetApiSvc >nul 2>&1
sc delete XboxGipSvc >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\CitizenFX" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\FiveM" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\Rockstar Games" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Internet Explorer\LowRegistry\Audio\PolicyConfig\PropertyStore" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\Software\WinRAR\ArcHistory" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Restrictions" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Restrictions" /v HideMachine /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\MSLicensing\HardwareID" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\MSLicensing\Store" /f >nul 2>&1
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /disable >nul 2>&1
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /disable >nul 2>&1
rd /s /q c:\windows\temp
rd /s /q c:\windows\tmp
rd /s /q c:\windows\prefetch
del /s /q /f "%LocalAppData%\FiveM\FiveM.app\*.dll" >nul 2>&1
del /s /q /f "%LocalAppData%\FiveM\FiveM.app\*.bin" >nul 2>&1
rd /s /q "%LocalAppData%\FiveM\FiveM.app\cache"
rd /s /q "%LocalAppData%\FiveM\FiveM.app\logs"
rd /s /q "%LocalAppData%\FiveM\FiveM.app\crashes"
taskkill /F /IM WmiPrvSE.exe >nul 2>&1
netsh int ip reset >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1
powershell.exe -ExecutionPolicy Bypass -Command "Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart" >nul 2>&1

set GEN=ABCDEF0123456789
set GEN2=26AE
set MAC=
for /l %%i in (1,1,12) do (
    set /a RND=!random! %% 16
    set CHAR=!GEN:~%RND%,1!
    if %%i==2 (
        set /a RND2=!random! %% 4
        set CHAR=!GEN2:~%RND2%,1!
    )
    set MAC=!MAC!!CHAR!
)

for /f "tokens=1" %%a in ('wmic nic where physicaladapter^=true get deviceid ^| findstr [0-9]') do (
    for %%b in (0 00 000) do (
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a" /v NetworkAddress /t REG_SZ /d !MAC! /f >nul 2>&1
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a" /v PnPCapabilities /t REG_DWORD /d 24 /f >nul 2>&1
    )
)

for /f "tokens=2 delims=," %%a in ('"wmic nic where (netconnectionid like '%%') get netconnectionid,netconnectionstatus /format:csv"') do (
    netsh interface set interface name="%%a" disable >nul 2>&1
    netsh interface set interface name="%%a" enable >nul 2>&1
)

 GOTO :EOF
 :MAC
 ::Generates semi-random value of a length according to the "if !COUNT!"  line, minus one, and from the characters in the GEN variable
 SET COUNT=0
 SET GEN=ABCDEF0123456789
 SET GEN2=26AE
 SET MAC=
 :MACLOOP
 SET /a COUNT+=1
 SET RND=%random%
 ::%%n, where the value of n is the number of characters in the GEN variable minus one.  So if you have 15 characters in GEN, set the number as 14
 SET /A RND=RND%%16
 SET RNDGEN=!GEN:~%RND%,1!
 SET /A RND2=RND%%4
 SET RNDGEN2=!GEN2:~%RND2%,1!
 IF "!COUNT!"  EQU "2" (SET MAC=!MAC!!RNDGEN2!) ELSE (SET MAC=!MAC!!RNDGEN!)
 IF !COUNT!  LEQ 11 GOTO MACLOOP 