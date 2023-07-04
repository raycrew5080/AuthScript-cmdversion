@echo off

REM Version 2.8

set _LOG_DIR=.\authlogs

IF EXIST %_LOG_DIR%\started.txt goto :elevationcheck

echo.
echo ===== Microsoft CSS Authentication Scripts started tracing =====
echo.
echo We have detected that tracing has not been started.
echo Please run start-auth.bat to start the tracing
echo.
goto :end-script

:elevationcheck

echo.
echo Checking token for Elevation  - please wait....
echo.

whoami /groups | find "S-1-16-12288" > NUL && goto :stopauth

echo.
echo ============= Microsoft CSS Authentication Scripts =============
echo.
echo The script must be run from an elevated command prompt.
echo The script has detected that it is not being run from an elevated command prompt.
echo.
echo Please run the script from an elevated command prompt.
echo.
goto :end-script

:stopauth

echo.
echo ============= Microsoft CSS Authentication Scripts =============
echo.
echo This Data collection is for Authentication, smart card and Credential provider scenarios.
echo.
echo This script will stop the tracing that was previously activated with the start-auth.bat script.
echo Data is collected into a subdirectory of the directory from where this script is launched, called "authlogs".
echo.
echo.
echo Please wait whilst the tracing stops and data is collected....
echo.

set _SCCM_LOG_DIR=%_LOG_DIR%\SCCM-enrollment
md %_SCCM_LOG_DIR%
set _MDM_LOG_DIR=%_LOG_DIR%\DeviceManagement_and_MDM
md %_MDM_LOG_DIR%
set _CERT_LOG_DIR=%_LOG_DIR%\Certinfo_and_Certenroll
md %_CERT_LOG_DIR%

tasklist /svc > %_LOG_DIR%\Tasklist.txt
klist > %_LOG_DIR%\Tickets.txt
klist -li 0x3e7 > %_LOG_DIR%\Tickets-localsystem.txt


REM *** Stop tracing
logman.exe stop Ngc -ets
logman.exe stop Bio -ets
logman.exe stop Lsa -ets
logman.exe stop NtlmCredssp -ets
logman.exe stop Kerberos -ets

for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ LanmanNT logman.exe stop KDC -ets
)

logman.exe stop SSL -ets
logman.exe stop WebAuth -ets
logman.exe stop Scard -ets
logman.exe stop CredprovAuthui -ets

for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ WinNT logman.exe stop CryptNCryptDpapi -ets
REM if %%i equ ServerNT logman.exe stop CryptNCryptDpapi -ets
REM if %%i equ LanmanNT logman.exe stop CryptNCryptDpapi -ets
)

logman.exe stop Sam -ets


REM *** Clean up additional logging
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v SPMInfoLevel /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LogToFile /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v NegEventMask /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA\NegoExtender\Parameters /v InfoLevel /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA\Pku2u\Parameters /v InfoLevel /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LspDbgInfoLevel /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LspDbgTraceOptions /f > NUL 2>&1
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters /v LogLevel /f > NUL 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" /v GPSvcDebugLevel /f > NUL 2>&1
nltest /dbflag:0x0 > NUL 2>&1

REM reg add HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL /v EventLogging /t REG_DWORD /d 1 /f > NUL 2>&1


REM *** Event/Operational logs

wevtutil.exe set-log "Microsoft-Windows-CAPI2/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-CAPI2/Operational" %_LOG_DIR%\Capi2_Oper.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Kerberos/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Kerberos/Operational" %_LOG_DIR%\Kerb_Oper.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Kerberos-key-Distribution-Center/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Kerberos-key-Distribution-Center/Operational" %_LOG_DIR%\Kdc_Oper.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Kerberos-KdcProxy/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Kerberos-KdcProxy/Operational" %_LOG_DIR%\KdcProxy_Oper.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-WebAuth/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-WebAuth/Operational" %_LOG_DIR%\WebAuth_Oper.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-WebAuthN/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-WebAuthN/Operational" %_LOG_DIR%\WebAuthn_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-WebAuthN/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-CertPoleEng/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-CertPoleEng/Operational" %_LOG_DIR%\Certpoleng_Oper.evtx /overwrite:true > NUL 2>&1

wevtutil query-events Application "/q:*[System[Provider[@Name='Microsoft-Windows-CertificateServicesClient-CertEnroll']]]" > %_CERT_LOG_DIR%\CertificateServicesClientLog.xml
certutil -policycache %_CERT_LOG_DIR%\CertificateServicesClientLog.xml > %_CERT_LOG_DIR%\ReadableClientLog.txt

wevtutil.exe set-log "Microsoft-Windows-IdCtrls/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-IdCtrls/Operational" %_LOG_DIR%\Idctrls_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-IdCtrls/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-User Control Panel/Operational"  /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-User Control Panel/Operational" %_LOG_DIR%\UserControlPanel_Oper.evtx /overwrite:true > NUL 2>&1
REM wevtutil.exe set-log "Microsoft-Windows-User Control Panel/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController" %_LOG_DIR%\Auth_Policy_Fail_DC.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUser-Client" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Authentication/ProtectedUser-Client" %_LOG_DIR%\Auth_ProtectedUser_Client.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController" %_LOG_DIR%\Auth_ProtectedUser_Fail_DC.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController" %_LOG_DIR%\Auth_ProtectedUser_Success_DC.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Biometrics/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Biometrics/Operational" %_LOG_DIR%\WinBio_oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-Biometrics/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-LiveId/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-LiveId/Operational" %_LOG_DIR%\LiveId_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-LiveId/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-AAD/Analytic" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-AAD/Analytic" %_LOG_DIR%\Aad_Analytic.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-AAD/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-AAD/Operational" %_LOG_DIR%\Aad_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-AAD/Operational"  /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Debug" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-User Device Registration/Debug" %_LOG_DIR%\UsrDeviceReg_Dbg.evtx /overwrite:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Admin" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-User Device Registration/Admin" %_LOG_DIR%\UsrDeviceReg_Adm.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Admin" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-HelloForBusiness/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-HelloForBusiness/Operational" %_LOG_DIR%\Hfb_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-HelloForBusiness/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe export-log SYSTEM %_LOG_DIR%\System.evtx /overwrite:true > NUL 2>&1
wevtutil.exe export-log APPLICATION %_LOG_DIR%\Application.evtx /overwrite:true > NUL 2>&1

REM COPY /Y %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-WinRM*.evtx %_LOG_DIR%\WMIOperational.evtx > NUL 2>&1
REM COPY /Y %windir%\system32\winevt\Logs\Microsoft-Windows-Shell-Core%4Operational.evtx %_LOG_DIR%\ShellCoreOperational.evtx > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Shell-Core/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Shell-Core/Operational" %_LOG_DIR%\ShellCore_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-Shell-Core/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-WMI-Activity/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-WMI-Activity/Operational" %_LOG_DIR%\WMI-Activity_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-WMI-Activity/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe export-log "Microsoft-Windows-GroupPolicy/Operational" %_LOG_DIR%\GroupPolicy.evtx /overwrite:true > NUL 2>&1


REM *** NGC
dsregcmd /status > %_LOG_DIR%\Dsregcmd.txt
dsregcmd /status /debug /all > %_LOG_DIR%\Dsregcmddebug.txt
certutil -delreg Enroll\Debug > NUL 2>&1
certutil -delreg ngc\Debug > NUL 2>&1
certutil -delreg Enroll\LogLevel > NUL 2>&1
copy /Y %WINDIR%\Ngc*.log %_LOG_DIR%\PregenLog.log > NUL 2>&1


REM *** netsh wfp capture stop
echo.
echo Stopping Network Trace and merging
echo This may take some time depending on the size of the network capture , please wait....
echo.

netsh trace stop > NUL 2>&1
ipconfig /all > %_LOG_DIR%\Ipconfig-info.txt
ipconfig /displaydns > %_LOG_DIR%\DisplayDns.txt
netstat -ano > %_LOG_DIR%\netstat.txt
REM netsh wfp capture stop


REM *** Netlogon, LSASS, LSP, Netsetup and Gpsvc log
copy /y %windir%\debug\Netlogon.* %_LOG_DIR% > NUL 2>&1
copy /y %windir%\system32\Lsass.log %_LOG_DIR% > NUL 2>&1
copy /y %windir%\debug\Lsp.* %_LOG_DIR% > NUL 2>&1
copy /y %windir%\debug\Netsetup.log %_LOG_DIR% > NUL 2>&1
copy /y %windir%\debug\usermode\gpsvc.* %_LOG_DIR% > NUL 2>&1

REM *** Credman
cmdkey.exe /list > %_LOG_DIR%\Credman.txt

REM *** Build info 

for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "ProductName=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion') do set "CurrentVersion=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ReleaseId') do set "ReleaseId=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v BuildLabEx') do set " BuildLabEx=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set "CurrentBuildHex=%%~b"
for /f "tokens=2*" %%a in ('Reg Query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v UBR') do set "UBRHEX=%%~b"
set /a CurrentBuildDec=%CurrentBuildHex%
set /a UBRDEC=%UBRHEX%
echo %computername% %ProductName% %ReleaseId% Version: %CurrentVersion%, Build: %CurrentBuildDec%.%UBRDEC% > %_LOG_DIR%\Build.txt
echo "BuildLabEx: " %BuildLabEx% >> %_LOG_DIR%\Build.txt


REM *** Reg exports

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /s > %_LOG_DIR%\Lsa-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" /s > %_LOG_DIR%\Policies-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /s > %_LOG_DIR%\SystemGP-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer" /s > %_LOG_DIR%\Lanmanserver-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /s > %_LOG_DIR%\Lanmanworkstation-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon" /s > %_LOG_DIR%\Netlogon-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" /s > %_LOG_DIR%\Schannel-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography" /s > %_LOG_DIR%\Cryptography-HKLMControl-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" /s > %_LOG_DIR%\Cryptography-HKLMSoftware-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography" /s > %_LOG_DIR%\Cryptography-HKLMSoftware-Policies-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SmartCardCredentialProvider" /s > %_LOG_DIR%\SCardCredentialProviderGP-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication" /s > %_LOG_DIR%\Authentication-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Authentication" /s > %_LOG_DIR%\Authentication-key-Wow64.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /s > %_LOG_DIR%\Winlogon-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Winlogon" /s > %_LOG_DIR%\Winlogon-CCS-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IdentityStore" /s > %_LOG_DIR%\Idstore-Config-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IdentityCRL" /s >> %_LOG_DIR%\Idstore-Config-key.txt 2>&1
reg query "HKEY_USERS\.Default\Software\Microsoft\IdentityCRL" /s >> %_LOG_DIR%\Idstore-Config-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Kdc" /s > %_LOG_DIR%\KDC-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\KPSSVC" /s > %_LOG_DIR%\KDCProxy-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin" /s > %_LOG_DIR%\RegCDJ-key.txt 2>&1
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin" /s > %_LOG_DIR%\RegWPJ-key.txt 2>&1
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin\AADNGC" /s > %_LOG_DIR%\RegAADNGC-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Winbio" /s > %_LOG_DIR%\Winbio-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WbioSrvc" /s > %_LOG_DIR%\Wbiosrvc-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Biometrics" /s > %_LOG_DIR%\Winbio-Policy-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\EAS\Policies" /s > %_LOG_DIR%\Eas-key.txt 2>&1

reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\SCEP" /s > %_LOG_DIR%\Scep-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SQMClient" /s > %_LOG_DIR%\MachineId.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\PassportForWork" /s > %_LOG_DIR%\NgcPolicyIntune-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PassportForWork" /s > %_LOG_DIR%\NgcPolicyGp-key.txt 2>&1
reg query "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\PassportForWork" /s > %_LOG_DIR%\NgcPolicyGpUser-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography\Ngc" /s > %_LOG_DIR%\NgcCryptoConfig-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\DeviceLock" /s > %_LOG_DIR%\DeviceLockPolicy-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\PassportForWork\SecurityKey " /s > %_LOG_DIR%\FIDOPolicyIntune-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FIDO" /s > %_LOG_DIR%\FIDOGp-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" /s > %_LOG_DIR%\RpcGP-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" /s > %_LOG_DIR%\NTDS-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LDAP" /s > %_LOG_DIR%\LdapClient-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard" /s > %_LOG_DIR%\DeviceGuard-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCMSetup" /s > %_SCCM_LOG_DIR%\CCMSetup-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM" /s > %_SCCM_LOG_DIR%\CCM-key.txt 2>&1

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework" /s > %_LOG_DIR%\DotNET-WOW-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework" /s > %_LOG_DIR%\DotNET-key.txt 2>&1

netsh http show sslcert > %_LOG_DIR%\http-show-sslcert.txt 2>&1
netsh http show urlacl > %_LOG_DIR%\http-show-urlacl.txt 2>&1

nltest /DOMAIN_TRUSTS /ALL_TRUSTS /V > %_LOG_DIR%\trustinfo.txt 2>&1
for /f "tokens=1-3 delims= " %%d in ('net config workstation ^| findstr /c:"Workstation domain"') do set machinedomain=%%f


for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ WinNT nltest /sc_query:%machinedomain% > %_LOG_DIR%\SecureChannel.txt
if %%i equ ServerNT nltest /sc_query:%machinedomain% > %_LOG_DIR%\SecureChannel.txt
REM if %%i equ LanmanNT nltest /sc_query:%machinedomain% > %_LOG_DIR%\SecureChannel.txt
)


REM *** Cert info
echo.
echo Collecting Cert info, please wait....

certutil -v -silent -store my > %_CERT_LOG_DIR%\Machine-Store.txt
certutil -v -silent -user -store my > %_CERT_LOG_DIR%\User-Store.txt
Certutil -v -silent -scinfo > %_CERT_LOG_DIR%\Scinfo.txt
certutil -tpminfo > %_CERT_LOG_DIR%\Tpm-Cert-Info.txt
certutil -v -silent -user -store my "Microsoft Smart Card Key Storage Provider" > %_CERT_LOG_DIR%\CertMY_SmartCard.txt
Certutil -v -silent -user -key -csp "Microsoft Passport Key Storage Provider" > %_CERT_LOG_DIR%\Cert_MPassportKey.txt
certutil -v -silent -store "Homegroup Machine Certificates" > %_CERT_LOG_DIR%\Homegroup-Machine-Store.txt
certutil -v -enterprise -store NTAuth > %_CERT_LOG_DIR%\NTAuth-store.txt
certutil -v -store -enterprise root > %_CERT_LOG_DIR%\Machine-Root-AD-store.txt
certutil -v -store root > %_CERT_LOG_DIR%\Machine-Root-Registry-store.txt
certutil -v -silent -store -grouppolicy root > %_CERT_LOG_DIR%\Machine-Root-GP-Store.txt
certutil -v -store authroot > %_CERT_LOG_DIR%\Machine-Root-ThirdParty-Store.txt
certutil -v -store -enterprise ca > %_CERT_LOG_DIR%\Machine-CA-AD-store.txt
certutil -v -store ca > %_CERT_LOG_DIR%\Machine-CA-Registry-store.txt
certutil -v -silent -store -grouppolicy ca > %_CERT_LOG_DIR%\Machine-CA-GP-Store.txt


REM *** Cert enrolment info
copy /Y %WINDIR%\CertEnroll.log %_CERT_LOG_DIR%\CertEnroll-fromWindir.log > NUL 2>&1
copy /Y %USERPROFILE%\CertEnroll.log %_CERT_LOG_DIR%\CertEnroll-fromUserProfile.log > NUL 2>&1
copy /Y %LocalAppData%\CertEnroll.log %_CERT_LOG_DIR%\CertEnroll-fromLocalAppData.log > NUL 2>&1

schtasks.exe /query /v > %_LOG_DIR%\Schtasks.query.v.txt
schtasks.exe /query /xml > %_LOG_DIR%\Schtasks.query.xml.txt


echo.
echo Collecting Device enrolment information, please wait....

REM **SCCM**
Set _SCCM_DIR=%SystemRoot%\CCM\Logs
if EXIST %_SCCM_DIR% ( xcopy /Y %_SCCM_DIR%\CertEnrollAgent*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\StateMessage*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\DCMAgent*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\ClientLocation*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\CcmEval*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\CcmRepair*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\PolicyAgent.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\CIDownloader.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\PolicyEvaluator.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\DcmWmiProvider*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\CIAgent*.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\CcmMessaging.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\ClientIDManagerStartup.log %_SCCM_LOG_DIR%\ > NUL 2>&1 && xcopy /Y %_SCCM_DIR%\LocationServices.log %_SCCM_LOG_DIR%\ > NUL 2>&1 )
Set _SCCM_DIR=%SystemRoot%\CCMSetup\Logs
if EXIST %_SCCM_DIR% ( xcopy /Y %_SCCM_DIR%\ccmsetup.log  %_SCCM_LOG_DIR%\ > NUL 2>&1)
Set _SCCM_DIR=""

REM **MDM**
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Enrollments" /s > %_MDM_LOG_DIR%\MDMEnrollments-key.txt 2>&1
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\EnterpriseResourceManager" /s > %_MDM_LOG_DIR%\MDMEnterpriseResourceManager-key.txt 2>&1
reg query "HKEY_CURRENT_USER\Software\Microsoft\SCEP" /s > %_MDM_LOG_DIR%\MDMSCEP-User-key.txt 2>&1
reg query "HKEY_CURRENT_USER\S-1-5-18\Software\Microsoft\SCEP" /s > %_MDM_LOG_DIR%\MDMSCEP-SystemUser-key.txt 2>&1

wevtutil query-events Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin /format:text >%_MDM_LOG_DIR%\DmEventLog.txt
for /F %%i IN ('wevtutil el') DO (
	for /F "tokens=1,2 delims=/" %%j IN ("%%i") DO (
	   IF "%%j" EQU "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider" (
	     wevtutil qe %%i /f:text /l:en-us > %_MDM_LOG_DIR%\%%j-%%k.txt
	   )
	)
)

echo.
echo Collecting Device configuration information, please wait....

sc query > %_LOG_DIR%\Services-config.txt
net start > %_LOG_DIR%\Services-started.txt

fltmc > %_LOG_DIR%\FilterManager.txt
REM Systeminfo > %_LOG_DIR%\SystemInfo.txt

gpresult /h "%_LOG_DIR%\GPOresult.html" > NUL 2>&1

set > %_LOG_DIR%\Env.txt
wmic datafile where "name='%SystemDrive%\\Windows\\System32\\kerberos.dll' or name='%SystemDrive%\\Windows\\System32\\lsasrv.dll' or name='%SystemDrive%\\Windows\\System32\\netlogon.dll' or name='%SystemDrive%\\Windows\\System32\\kdcsvc.dll' or name='%SystemDrive%\\Windows\\System32\\msv1_0.dll' or name='%SystemDrive%\\Windows\\System32\\schannel.dll' or name='%SystemDrive%\\Windows\\System32\\dpapisrv.dll' or name='%SystemDrive%\\Windows\\System32\\basecsp.dll' or name='%SystemDrive%\\Windows\\System32\\scksp.dll' or name='%SystemDrive%\\Windows\\System32\\bcrypt.dll' or name='%SystemDrive%\\Windows\\System32\\bcryptprimitives.dll' or name='%SystemDrive%\\Windows\\System32\\ncrypt.dll' or name='%SystemDrive%\\Windows\\System32\\ncryptprov.dll' or name='%SystemDrive%\\Windows\\System32\\cryptsp.dll' or name='%SystemDrive%\\Windows\\System32\\rsaenh.dll'  or name='%SystemDrive%\\Windows\\System32\\Cryptdll.dll'" get Filename, Version | more >> %_LOG_DIR%\Build.txt
wmic qfe list > %_LOG_DIR%\Qfes_installed.txt

echo Data collection stopped on %date% at %time% >> %_LOG_DIR%\script-info.txt

del %_LOG_DIR%\started.txt

set c=""

echo.
echo ===== Microsoft CSS Authentication Scripts tracing stopped =====
echo.
echo The tracing has now stopped and data has been saved to the "Authlogs" sub-directory.
echo The "Authlogs" directory contents (including subdirectories) can be supplied to Microsoft CSS engineers for analysis. 
echo.
echo.
echo ======================= IMPORTANT NOTICE =======================
echo.
echo The authentication script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Windows.
echo The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses, Device names, and User names.
echo.
echo Once the tracing and data collection has completed, the script will save the data in a subdirectory from where this script is launched called "Authlogs".
echo The "Authlogs" directory and subdirectories will contain data collected by the Microsoft CSS Authentication scripts.
echo This folder and its contents are not automatically sent to Microsoft.
echo You can send this folder and its contents to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have.
echo.

:end-script