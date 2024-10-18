@echo off
mode con cols=66 lines=25
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
cd %cd%
net session >nul 2>&1
if %errorlevel% equ 0 (
goto iskatel
) else (
title Start iskatel in administrator mode
mode con lines=1
call :ColorText 0C "Start iskatel in administrator mode"
echo.
pause
exit
)
:iskatel
cls
title iskatel - %USERNAME%
echo           ___         
echo         .'   '.       
echo        /  .-.  \      
echo       (  (   )  )      
echo        \  '-'  /      
echo         '.___.'       
echo              \ \     
echo               \ \     
echo                \ \    
echo                 \_\
echo   _          __              _          __   
echo  (_)        [  :  _         / :_       [  :  
echo  __   .--.   : : / ]  ,--. `: :-'.---.  : :  
echo [  : ( (`\]  : '' {  `'_\ : : : / /__\\ : :  
echo  : :  `'.'.  : :`\ \ // : :,: :,: \__., : :  
echo [___][\__) )[__:  \_]\'-;__/\__/ '.__.'[___]
if exist %USERNAME% del /Q "%cd%\%USERNAME%" && rmdir /S /Q "%cd%\%USERNAME%"
mkdir %cd%\%USERNAME%
attrib +h "%USERNAME%"
cd %USERNAME%
call :ColorText 0C "Collecting information..."
echo.
echo Whoami: > "unimportant_info.txt"
whoami >> "unimportant_info.txt"
echo Current Users: >> "unimportant_info.txt"
net user >> "unimportant_info.txt"
echo PC Name: >> "unimportant_info.txt"
hostname >> "unimportant_info.txt"
echo OS Version: >> "unimportant_info.txt"
ver >> "unimportant_info.txt"
setlocal enabledelayedexpansion
systeminfo > %TEMP%\temp_code.txt
set /a line_number=0
for /f "delims=" %%a in (%TEMP%\temp_code.txt) do (
    set /a line_number+=1
    if !line_number! equ 9 (
        set line9=%%a
    )
)
echo Code of product: >> "unimportant_info.txt"
echo %line9% >> "unimportant_info.txt"
del %TEMP%\temp_code.txt
endlocal
echo Language: >> "unimportant_info.txt"
systeminfo | findstr ; >> "unimportant_info.txt"
echo System time zone: >> "unimportant_info.txt"
systeminfo | findstr (UTC+* >> "unimportant_info.txt"
echo %time% - %date% >> "unimportant_info.txt"
echo BIOS version: >> "unimportant_info.txt"
systeminfo | findstr BIOS >> "unimportant_info.txt"
echo PowerShell information: >> "unimportant_info.txt"
powershell -Command "$PSVersionTable" >> "unimportant_info.txt"
echo Knowledge Bases: >> "unimportant_info.txt"
systeminfo | findstr KB* >> "unimportant_info.txt"
echo Recent User Activities: >> "unimportant_info.txt"
powershell -Command "Get-EventLog -LogName Security -Newest 10 | Select-Object -Property TimeGenerated, EntryType, Message" >> "unimportant_info.txt"
call :ColorText 02 "Unimportant information is ready"
echo.
echo Unimportant information is ready - %time% > "retrieval_time.txt"
echo Processes: >> "processes.txt"
powershell -Command "Get-Process | Select-Object -Property Id, ProcessName, CPU, WorkingSet, Path" >> "processes.txt"
echo Autostart: >> "processes.txt"
powershell -Command "Get-WmiObject Win32_StartupCommand" >> "processes.txt"
call :ColorText 02 "Processes is ready"
echo.
echo Processes is ready - %time% >> "retrieval_time.txt"
echo Processor information: > "components.csv"
wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessors >> "components.csv"
echo. >> "components.csv"
echo RAM: >> "components.csv"
wmic memorychip get Capacity >> "components.csv"
echo. >> "components.csv"
echo Information about hard disks: >> "components.csv"
wmic diskdrive get Model, Size >> "components.csv"
echo. >> "components.csv"
echo Video card information: >> "components.csv"
wmic path win32_videocontroller get Name >> "components.csv"
call :ColorText 02 "Components is ready"
echo.
echo Components is ready - %time% >> "retrieval_time.txt"
echo Installed Programs: > "programs.txt"
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "DisplayName" ^| find "REG_SZ"') do (
    echo %%b >> programs.txt
)

for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "DisplayName" ^| find "REG_SZ"') do (
    echo %%b >> programs.txt
)
powershell -Command "Get-AppxPackage -AllUsers | Select-Object -Property Name, Version, PackageFullName" >> "programs.txt"
echo Programs Elements: >> "programs.txt"
powershell -Command "Get-WmiObject Win32_SoftwareElement" >> "programs.txt"
call :ColorText 02 "Programs is ready"
echo.
echo Programs is ready - %time% >> "retrieval_time.txt"
echo USB Devices: > "usb_devices.csv"
wmic logicaldisk where drivetype=2 get deviceid, volumename, description >> "usb_devices.csv"
powershell -Command "Get-PnpDevice | Where-Object { $_.InstanceId -match '^USB' } | Select-Object -Property FriendlyName, InstanceId, Status" >> "usb_devices.csv"
echo Screen Settings: >> "usb_devices.csv"
powershell -Command "Get-WmiObject Win32_VideoController" >> "usb_devices.csv"
echo Disks that are attached to the system: >> "usb_devices.csv"
wmic logicaldisk get DeviceID, VolumeName, FileSystem, Size, FreeSpace >> "usb_devices.csv"
echo Storage Devices: >> "usb_devices.csv"
wmic path win32_pnpentity where "PNPClass='DiskDrive'" get Name, DeviceID, PNPClass >> "usb_devices.csv"
echo Drivers: >> "usb_devices.csv"
driverquery >> "usb_devices.csv"
call :ColorText 02 "USB Devices is ready"
echo.
echo USB Devices is ready - %time% >> "retrieval_time.txt"
echo Antivirus information: > "antivirus.csv"
wmic /namespace:\\root\securitycenter2 path antivirusproduct get displayname, productstate >> "antivirus.csv"
echo ADVFirewall information: >> "Antivirus.csv"
netsh advfirewall show allprofiles >> "antivirus.csv"
call :ColorText 02 "Antivirus information is ready"
echo.
echo Antivirus information is ready - %time% >> "retrieval_time.txt"
echo Internet connections: > "internet.csv"
netstat -b >> "internet.csv"
echo IP-Address: >> "internet.csv"
setlocal enabledelayedexpansion
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    echo !ip! >> "internet.csv"
)
for /f "delims=" %%a in ('powershell -Command "(Invoke-WebRequest -Uri 'https://ifconfig.me/ip').Content"') do (
    set "address=%%a"
)
endlocal
echo Public IP-Address: %address% >> "internet.csv"
echo Information about IP-Address: >> "internet.csv"
powershell -Command "(Invoke-WebRequest -Uri 'https://api.techniknews.net/ipgeo/%address%').Content" >> "internet.csv"
echo Wi-Fi Networks: >> "internet.csv"
netsh interface show interface >> "internet.csv"
echo DHCP-Address >> "internet.csv"
systeminfo | findstr DHCP- >> "internet.csv"
echo Network routes: >> "internet.csv"
route print >> "internet.csv"
echo Network Adapters: >> "internet.csv"
powershell -Command "Get-WmiObject Win32_NetworkAdapterConfiguration" >> "internet.csv"
echo Network Shares: >> "internet.csv"
net share >> "internet.csv"
echo Network Printers: >> "internet.csv"
wmic printer get name, portname, shared >> "internet.csv"
call :ColorText 02 "Internet is ready"
echo.
echo Internet is ready - %time% >> "retrieval_time.txt"
mkdir files
echo Desktop > %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Desktop" >> %cd%\dir.txt
echo Downloads >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Downloads" >> %cd%\dir.txt
echo TEMP >> %cd%\dir.txt
tree /f "%TEMP%" >> %cd%\dir.txt
echo Recent >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent" >> %cd%\dir.txt
echo Favorites >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Favorites" >> %cd%\dir.txt
echo Documents >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Documents" >> %cd%\dir.txt
echo Pictures >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Pictures" >> %cd%\dir.txt
echo Contacts >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Contacts" >> %cd%\dir.txt
echo Music >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Music" >> %cd%\dir.txt
echo Videos >> %cd%\dir.txt
tree /f "C:\Users\%USERNAME%\Videos" >> %cd%\dir.txt
call :ColorText 02 "Dir journal is ready"
echo.
echo Dir journal is ready - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Desktop
xcopy "C:\Users\%USERNAME%\Desktop\*" "%cd%\files\Desktop" /s /e
call :ColorText 02 "Desktop is ready"
echo.
echo Desktop created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Downloads
xcopy "C:\Users\%USERNAME%\Downloads\*" "%cd%\files\Downloads" /s /e
call :ColorText 02 "Downloads is ready"
echo.
echo Downloads created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\TEMP
xcopy "%TEMP%\*" "%cd%\files\TEMP" /s /e
call :ColorText 02 "TEMP is ready"
echo.
echo TEMP created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Recent
xcopy "C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Recent\*" "%cd%\files\Recent" /s /e
call :ColorText 02 "Recent is ready"
echo.
echo Recent created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Favorites
xcopy "C:\Users\%USERNAME%\Favorites\*" "%cd%\files\Favorites" /s /e
call :ColorText 02 "Favorites is ready"
echo.
echo Favorites created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Documents
xcopy "C:\Users\%USERNAME%\Documents\*" "%cd%\files\Documents" /s /e
call :ColorText 02 "Documents is ready"
echo.
echo Documents created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Pictures
xcopy "C:\Users\%USERNAME%\Pictures\*" "%cd%\files\Pictures" /s /e
call :ColorText 02 "Pictures is ready"
echo.
echo Pictures created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Contacts
xcopy "C:\Users\%USERNAME%\Contacts\*" "%cd%\files\Contacts" /s /e
call :ColorText 02 "Contacts is ready"
echo.
echo Contacts created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Music
xcopy "C:\Users\%USERNAME%\Music\*" "%cd%\files\Music" /s /e
call :ColorText 02 "Music is ready"
echo.
echo Music created - %time% >> "retrieval_time.txt"
mkdir %cd%\files\Videos
xcopy "C:\Users\%USERNAME%\Videos\*" "%cd%\files\Videos" /s /e
call :ColorText 02 "Videos is ready"
echo.
echo Videos created - %time% >> "retrieval_time.txt"
exit
:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
