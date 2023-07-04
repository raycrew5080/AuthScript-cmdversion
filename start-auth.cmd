@echo off

set _Authscriptver=2.8
set _LOG_DIR=.\authlogs

IF NOT EXIST %_LOG_DIR%\started.txt goto :elevationcheck

echo.
echo ===== Microsoft CSS Authentication Scripts started tracing =====
echo.
echo We have detected that tracing has already been started.
echo Please run stop-auth.bat to stop the tracing
echo.
goto :end-script

:elevationcheck

echo.
echo Checking token for Elevation  - please wait....
echo.

whoami /groups | find "S-1-16-12288" > NUL && goto :startauth

echo.
echo ============= Microsoft CSS Authentication Scripts =============
echo.
echo The script must be run from an elevated command prompt.
echo The script has detected that it is not being run from an elevated command prompt.
echo.
echo Please run the script from an elevated command prompt.
echo.
goto :end-script

:startauth
set c="N"

echo.
echo ============= Microsoft CSS Authentication Scripts =============
echo.
echo This Data collection is for Authentication, smart card and Credential provider scenarios.
echo.
echo Once you have created the issue or reproduced the scenario, please run stop-auth.bat from the same location to stop the tracing and collect the required data.
echo Data is collected into a subdirectory of the directory from where this script is launched, called "Authlogs".
echo.
echo ======================= IMPORTANT NOTICE =======================
echo.
echo The authentication script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Windows.
echo The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses; PC names; and user names.
echo.
echo Once the tracing and data collection has completed, the script will save the data in a subdirectory from where this script is launched called "Authlogs".
echo The "Authlogs" directory and subdirectories will contain data collected by the Microsoft CSS Authentication scripts.
echo This folder and its contents are not automatically sent to Microsoft.
echo You can send this folder and its contents to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have.
echo.
set /P c=Are you sure you want to continue[Y/N]?
if /I "%c%" EQU "Y" goto :start-script
if /I "%c%" EQU "N" goto :end-script
goto :startauth

:start-script

echo.
echo Please Wait whilst the tracing starts.....
echo.

set _PRETRACE_LOG_DIR=%_LOG_DIR%\PreTraceLogs
set _NGC_TRACES_TMP=%_LOG_DIR%\NGC_trace.txt
set _BIO_TRACES_TMP=%_LOG_DIR%\bio_trace.txt
set _LSA_TRACES_TMP=%_LOG_DIR%\LSA_trace.txt
set _NTLM_TRACES_TMP=%_LOG_DIR%\NTLM_trace.txt
set _KERB_TRACES_TMP=%_LOG_DIR%\KERB_trace.txt
set _KDC_TRACES_TMP=%_LOG_DIR%\KDC_trace.txt
set _SAM_TRACES_TMP=%_LOG_DIR%\SAM_trace.txt
set _SSL_TRACES_TMP=%_LOG_DIR%\SSL_trace.txt
set _CRYPT_DPAPI_TRACES_TMP=%_LOG_DIR%\CryptoandDpapi_trace.txt
set _WEBAUTH_TRACES_TMP=%_LOG_DIR%\WebAuth_trace.txt
set _SCARD_TRACES_TMP=%_LOG_DIR%\scard_trace.txt
set _CREDPROV_TRACES_TMP=%_LOG_DIR%\Credprov_trace.txt

IF EXIST %_PRETRACE_LOG_DIR% ( rd /s /q %_PRETRACE_LOG_DIR% )
IF EXIST %_LOG_DIR% ( rd /s /q %_LOG_DIR% )
md %_LOG_DIR%
md %_PRETRACE_LOG_DIR%


echo Microsoft CSS Authentication Script version %_Authscriptver% > %_LOG_DIR%\script-info.txt

REM	*** DEFINE ETL PROVIDER GROUPINGS ***

REM  	** NGC TRACES **
(
	echo {B66B577F-AE49-5CCF-D2D7-8EB96BFD440C} 0x0 0xff
	echo {CAC8D861-7B16-5B6B-5FC0-85014776BDAC} 0x0 0xff
	echo {6D7051A0-9C83-5E52-CF8F-0ECAF5D5F6FD} 0x0 0xff
	echo {0ABA6892-455B-551D-7DA8-3A8F85225E1A} 0x0 0xff
	echo {9DF6A82D-5174-5EBF-842A-39947C48BF2A} 0x0 0xff
	echo {9B223F67-67A1-5B53-9126-4593FE81DF25} 0x0 0xff
	echo {89F392FF-EE7C-56A3-3F61-2D5B31A36935} 0x0 0xff
	echo {CDD94AC7-CD2F-5189-E126-2DEB1B2FACBF} 0x0 0xff
	echo {2056054C-97A6-5AE4-B181-38BC6B58007E} 0x0 0xff
	echo {1D6540CE-A81B-4E74-AD35-EEF8463F97F5} 0xffff 0xff
	echo {CDC6BEB9-6D78-5138-D232-D951916AB98F} 0x0 0xff
	echo {C0B2937D-E634-56A2-1451-7D678AA3BC53} 0x0 0xff
	echo {9D4CA978-8A14-545E-C047-A45991F0E92F} 0x0 0xff
	echo {3b9dbf69-e9f0-5389-d054-a94bc30e33f7} 0x0 0xff
	echo {34646397-1635-5d14-4d2c-2febdcccf5e9} 0x0 0xff
	echo {3A8D6942-B034-48e2-B314-F69C2B4655A3} 0xffffffff 0xff
	echo {5AA9A3A3-97D1-472B-966B-EFE700467603} 0xffffffff 0xff
	echo {D5A5B540-C580-4DEE-8BB4-185E34AA00C5} 0x0 0xff
	echo {7955d36a-450b-5e2a-a079-95876bca450a} 0x0 0xff
	echo {c3feb5bf-1a8d-53f3-aaa8-44496392bf69} 0x0 0xff
	echo {78983c7d-917f-58da-e8d4-f393decf4ec0} 0x0 0xff
	echo {36FF4C84-82A2-4B23-8BA5-A25CBDFF3410} 0x0 0xff
	echo {86D5FE65-0564-4618-B90B-E146049DEBF4} 0x0 0xff
	echo {23B8D46B-67DD-40A3-B636-D43E50552C6D} 0x0 0xff
	echo {73370BD6-85E5-430B-B60A-FEA1285808A7} 0x0 0xff
	echo {F0DB7EF8-B6F3-4005-9937-FEB77B9E1B43} 0x0 0xff
	echo {54164045-7C50-4905-963F-E5BC1EEF0CCA} 0x0 0xff
	echo {89A2278B-C662-4AFF-A06C-46AD3F220BCA} 0x0 0xff
	echo {BC0669E1-A10D-4A78-834E-1CA3C806C93B} 0x0 0xff
	echo {BEA18B89-126F-4155-9EE4-D36038B02680} 0x0 0xff
	echo {B2D1F576-2E85-4489-B504-1861C40544B3} 0x0 0xff
	echo {98BF1CD3-583E-4926-95EE-A61BF3F46470} 0x0 0xff
	echo {AF9CC194-E9A8-42BD-B0D1-834E9CFAB799} 0x0 0xff
	echo {d0034f5e-3686-5a74-dc48-5a22dd4f3d5b} 0xFFFFFFFF 0xff
	echo {99eb7b56-f3c6-558c-b9f6-09a33abb4c83} 0xFFFFFFFF 0xff
	echo {aa02d1a4-72d8-5f50-d425-7402ea09253a} 0x0 0xff
	echo {507C53AE-AF42-5938-AEDE-4A9D908640ED} 0x0 0xff
	echo {9FBF7B95-0697-4935-ADA2-887BE9DF12BC} 0x0 0xff
	echo {3DA494E4-0FE2-415C-B895-FB5265C5C83B} 0x0 0xff
) >%_NGC_TRACES_TMP%

REM  	** Bio Traces **
(
	echo {34BEC984-F11F-4F1F-BB9B-3BA33C8D0132} 0xffff 0xff
	echo {225b3fed-0356-59d1-1f82-eed163299fa8} 0x0 0xff
	echo {9dadd79b-d556-53f2-67c4-129fa62b7512} 0x0 0xff
	echo {1B5106B1-7622-4740-AD81-D9C6EE74F124} 0x0 0xff
	echo {1d480c11-3870-4b19-9144-47a53cd973bd} 0x0 0xff
	echo {e60019f0-b378-42b6-a185-515914d3228c} 0x0 0xff
	echo {48CAFA6C-73AA-499C-BDD8-C0D36F84813E} 0x0 0xff
	echo {add0de40-32b0-4b58-9d5e-938b2f5c1d1f} 0x0 0xff
	echo {e92355c0-41e4-4aed-8d67-df6b2058f090} 0x0 0xff
	echo {85be49ea-38f1-4547-a604-80060202fb27} 0x0 0xff
	echo {F4183A75-20D4-479B-967D-367DBF62A058} 0x0 0xff
	echo {0279b50e-52bd-4ed6-a7fd-b683d9cdf45d} 0x0 0xff
	echo {39A5AA08-031D-4777-A32D-ED386BF03470} 0x0 0xff
	echo {22eb0808-0b6c-5cd4-5511-6a77e6e73a93} 0x0 0xff
	echo {63221D5A-4D00-4BE3-9D38-DE9AAF5D0258} 0x0 0xff
	echo {9df19cfa-e122-5343-284b-f3945ccd65b2} 0x0 0xff
	echo {beb1a719-40d1-54e5-c207-232d48ac6dea} 0x0 0xff
	echo {8A89BB02-E559-57DC-A64B-C12234B7572F} 0x0 0xff
) >%_BIO_TRACES_TMP%

REM - 	Removed echo Biometrics.Face.PerformanceProvider from Bio traces due to overhead 
REM - 	echo {AF09B0F9-AE02-4926-8A0F-E90D803063A8} 0x0 0xff

REM  	** LSA **
(
	echo {D0B639E0-E650-4D1D-8F39-1580ADE72784} 0xC43EFF 0xff
	echo {169EC169-5B77-4A3E-9DB6-441799D5CACB} 0xffffff 0xff
	echo {DAA76F6A-2D11-4399-A646-1D62B7380F15} 0xffffff 0xff
	echo {366B218A-A5AA-4096-8131-0BDAFCC90E93} 0xfffffff 0xff
	echo {4D9DFB91-4337-465A-A8B5-05A27D930D48} 0xff 0xff
	echo {7FDD167C-79E5-4403-8C84-B7C0BB9923A1} 0xFFF 0xff
	echo {CA030134-54CD-4130-9177-DAE76A3C5791} 0xfffffff 0xff
) >%_LSA_TRACES_TMP%


REM  	** NTLM/CREDSSP **
(
	echo {5BBB6C18-AA45-49b1-A15F-085F7ED0AA90} 0x5ffDf 0xff
	echo {AC69AE5B-5B21-405F-8266-4424944A43E9} 0xffffffff 0xff
	echo {6165F3E2-AE38-45D4-9B23-6B4818758BD9} 0xffffffff 0xff
) >%_NTLM_TRACES_TMP%


REM  	** KERB **
(
	echo {6B510852-3583-4e2d-AFFE-A67F9F223438} 0x7ffffff 0xff
	echo {60A7AB7A-BC57-43E9-B78A-A1D516577AE3} 0xffffff 0xff
	echo {FACB33C4-4513-4C38-AD1E-57C1F6828FC0} 0xffffffff 0xff
	echo {97A38277-13C0-4394-A0B2-2A70B465D64F} 0xff 0xff
) >%_KERB_TRACES_TMP%

REM 	** KDC **
(
	echo {1BBA8B19-7F31-43c0-9643-6E911F79A06B} 0xfffff 0xff
) >%_KDC_TRACES_TMP%


REM  	** SAM **
(
	echo {8E598056-8993-11D2-819E-0000F875A064} 0xffffffffffffffff 0xff
	echo {0D4FDC09-8C27-494A-BDA0-505E4FD8ADAE} 0xffffffffffffffff 0xff
	echo {BD8FEA17-5549-4B49-AA03-1981D16396A9} 0xffffffffffffffff 0xff
	echo {F2969C49-B484-4485-B3B0-B908DA73CEBB} 0xffffffffffffffff 0xff
	echo {548854B9-DA55-403E-B2C7-C3FE8EA02C3C} 0xffffffffffffffff 0xff
) >%_SAM_TRACES_TMP%


REM  	** SSL **
(
	echo {37D2C3CD-C5D4-4587-8531-4696C44244C8} 0x4000ffff 0xff
) >%_SSL_TRACES_TMP%


REM  	** Crypto/Dpapi **
(
	echo {EA3F84FC-03BB-540e-B6AA-9664F81A31FB} 0xFFFFFFFF 0xff
	echo {A74EFE00-14BE-4ef9-9DA9-1484D5473302} 0xFFFFFFFF 0xff
	echo {A74EFE00-14BE-4ef9-9DA9-1484D5473301} 0xFFFFFFFF 0xff
	echo {A74EFE00-14BE-4ef9-9DA9-1484D5473305} 0xFFFFFFFF 0xff
	echo {786396CD-2FF3-53D3-D1CA-43E41D9FB73B} 0x0  0xff
) >%_CRYPT_DPAPI_TRACES_TMP%


REM  	** Web Auth **
(
	echo {2A3C6602-411E-4DC6-B138-EA19D64F5BBA} 0xFFFF 0xff
	echo {EF98103D-8D3A-4BEF-9DF2-2156563E64FA} 0xFFFF 0xff
	echo {FB6A424F-B5D6-4329-B9B5-A975B3A93EAD} 0x000003FF
	echo {D93FE84A-795E-4608-80EC-CE29A96C8658} 0x7FFFFFFF 0xff
	echo {3F8B9EF5-BBD2-4C81-B6C9-DA3CDB72D3C5} 0x7 0xff
	echo {B1108F75-3252-4b66-9239-80FD47E06494} 0x2FF 0xff
	echo {C10B942D-AE1B-4786-BC66-052E5B4BE40E} 0x3FF 0xff
	echo {82c7d3df-434d-44fc-a7cc-453a8075144e} 0x2FF 0xff
	echo {05f02597-fe85-4e67-8542-69567ab8fd4f} 0xFFFFFFFF 0xff
	echo {3C49678C-14AE-47FD-9D3A-4FEF5D796DB9} 0xFFFFFFFF 0xff
	echo {077b8c4a-e425-578d-f1ac-6fdf1220ff68} 0xFFFFFFFF 0xff
	echo {7acf487e-104b-533e-f68a-a7e9b0431edb} 0xFFFFFFFF 0xff
	echo {5836994d-a677-53e7-1389-588ad1420cc5} 0xFFFFFFFF 0xff
	echo {4DE9BC9C-B27A-43C9-8994-0915F1A5E24F} 0xFFFFFFFF 0xff
	echo {bfed9100-35d7-45d4-bfea-6c1d341d4c6b} 0xFFFFFFFF 0xff
	echo {9EBB3B15-B094-41B1-A3B8-0F141B06BADD} 0xFFF 0xff
	echo {6ae51639-98eb-4c04-9b88-9b313abe700f} 0xFFFFFFFF 0xff
	echo {7B79E9B1-DB01-465C-AC8E-97BA9714BDA2} 0xFFFFFFFF 0xff
	echo {86510A0A-FDF4-44FC-B42F-50DD7D77D10D} 0xFFFFFFFF 0xff
	echo {08B15CE7-C9FF-5E64-0D16-66589573C50F} 0xFFFFFF7F 0xff
	echo {63b6c2d2-0440-44de-a674-aa51a251b123} 0xFFFFFFFF 0xff
	echo {4180c4f7-e238-5519-338f-ec214f0b49aa} 0xFFFFFFFF 0xff
	echo {EB65A492-86C0-406A-BACE-9912D595BD69} 0xFFFFFFFF 0xff
	echo {d49918cf-9489-4bf1-9d7b-014d864cf71f} 0xFFFFFFFF 0xff
	echo {5AF52B0D-E633-4ead-828A-4B85B8DAAC2B} 0xFFFF 0xff
	echo {2A6FAF47-5449-4805-89A3-A504F3E221A6} 0xFFFF 0xff
 	echo {EC3CA551-21E9-47D0-9742-1195429831BB} 0xFFFFFFFF 0xff
	echo {bb8dd8e5-3650-5ca7-4fea-46f75f152414} 0xFFFFFFFF 0xff
	echo {7fad10b2-2f44-5bb2-1fd5-65d92f9c7290} 0xFFFFFFFF 0xff
	echo {74D91EC4-4680-40D2-A213-45E2D2B95F50} 0xFFFFFFFF 0xff
 	echo {556045FD-58C5-4A97-9881-B121F68B79C5} 0xFFFFFFFF 0xff
 	echo {5A9ED43F-5126-4596-9034-1DCFEF15CD11} 0xFFFFFFFF 0xff
	echo {F7C77B8D-3E3D-4AA5-A7C5-1DB8B20BD7F0} 0xFFFFFFFF 0xff
) >%_WEBAUTH_TRACES_TMP%


REM  	** Smart Card **
(
	echo {30EAE751-411F-414C-988B-A8BFA8913F49} 0xffffffffffffffff 0xff
	echo {13038E47-FFEC-425D-BC69-5707708075FE} 0xffffffffffffffff 0xff
	echo {3FCE7C5F-FB3B-4BCE-A9D8-55CC0CE1CF01} 0xffffffffffffffff 0xff
	echo {FB36CAF4-582B-4604-8841-9263574C4F2C} 0xffffffffffffffff 0xff
	echo {133A980D-035D-4E2D-B250-94577AD8FCED} 0xffffffffffffffff 0xff
	echo {EED7F3C9-62BA-400E-A001-658869DF9A91} 0xffffffffffffffff 0xff
	echo {27BDA07D-2CC7-4F82-BC7A-A2F448AB430F} 0xffffffffffffffff 0xff
	echo {15DE6EAF-EE08-4DE7-9A1C-BC7534AB8465} 0xffffffffffffffff 0xff
	echo {31332297-E093-4B25-A489-BC9194116265} 0xffffffffffffffff 0xff
	echo {4fcbf664-a33a-4652-b436-9d558983d955} 0xffffffffffffffff 0xff
	echo {DBA0E0E0-505A-4AB6-AA3F-22F6F743B480} 0xffffffffffffffff 0xff
	echo {125f2cf1-2768-4d33-976e-527137d080f8} 0xffffffffffffffff 0xff
	echo {beffb691-61cc-4879-9cd9-ede744f6d618} 0xffffffffffffffff 0xff
	echo {545c1f45-614a-4c72-93a0-9535ac05c554} 0xffffffffffffffff 0xff
	echo {AEDD909F-41C6-401A-9E41-DFC33006AF5D} 0xffffffffffffffff 0xff
	echo {09AC07B9-6AC9-43BC-A50F-58419A797C69} 0xffffffffffffffff 0xff
	echo {AAEAC398-3028-487C-9586-44EACAD03637} 0xffffffffffffffff 0xff
	echo {9F650C63-9409-453C-A652-83D7185A2E83} 0xffffffffffffffff 0xff
	echo {F5DBD783-410E-441C-BD12-7AFB63C22DA2} 0xffffffffffffffff 0xff
	echo {a3c09ba3-2f62-4be5-a50f-8278a646ac9d} 0xffffffffffffffff 0xff
) >%_SCARD_TRACES_TMP%



REM	*** SHELL/CREDPROVIDER FRAMEWORK AUTHUI ***
(
	echo {5e85651d-3ff2-4733-b0a2-e83dfa96d757} 0xffffffffffffffff 0xff
 	echo {D9F478BB-0F85-4E9B-AE0C-9343F302F9AD} 0xffffffffffffffff 0xff
	echo {462a094c-fc89-4378-b250-de552c6872fd} 0xffffffffffffffff 0xff
	echo {8db3086d-116f-5bed-cfd5-9afda80d28ea} 0xffffffffffffffff 0xff
	echo {a55d5a23-1a5b-580a-2be5-d7188f43fae1} 0xFFFF 0xff
	echo {4b8b1947-ae4d-54e2-826a-1aee78ef05b2} 0xFFFF 0xff
	echo {176CD9C5-C90C-5471-38BA-0EEB4F7E0BD0} 0xffffffffffffffff 0xff
	echo {3EC987DD-90E6-5877-CCB7-F27CDF6A976B} 0xffffffffffffffff 0xff
	echo {41AD72C3-469E-5FCF-CACF-E3D278856C08} 0xffffffffffffffff 0xff
	echo {4F7C073A-65BF-5045-7651-CC53BB272DB5} 0xffffffffffffffff 0xff
	echo {A6C5C84D-C025-5997-0D82-E608D1ABBBEE} 0xffffffffffffffff 0xff
	echo {C0AC3923-5CB1-5E37-EF8F-CE84D60F1C74} 0xffffffffffffffff 0xff
	echo {DF350158-0F8F-555D-7E4F-F1151ED14299} 0xffffffffffffffff 0xff
	echo {FB3CD94D-95EF-5A73-B35C-6C78451095EF} 0xffffffffffffffff 0xff
	echo {d451642c-63a6-11d7-9720-00b0d03e0347} 0xffffffffffffffff 0xff
	echo {b39b8cea-eaaa-5a74-5794-4948e222c663} 0xffffffffffffffff 0xff
	echo {dbe9b383-7cf3-4331-91cc-a3cb16a3b538} 0xffffffffffffffff 0xff
	echo {c2ba06e2-f7ce-44aa-9e7e-62652cdefe97} 0xffffffffffffffff 0xff
	echo {5B4F9E61-4334-409F-B8F8-73C94A2DBA41} 0xffffffffffffffff 0xff
	echo {a789efeb-fc8a-4c55-8301-c2d443b933c0} 0xffffffffffffffff 0xff
	echo {301779e2-227d-4faf-ad44-664501302d03} 0xffffffffffffffff 0xff
	echo {557D257B-180E-4AAE-8F06-86C4E46E9D00} 0xffffffffffffffff 0xff
	echo {D33E545F-59C3-423F-9051-6DC4983393A8} 0xffffffffffffffff 0xff
	echo {19D78D7D-476C-47B6-A484-285D1290A1F3} 0xffffffffffffffff 0xff
	echo {EB7428F5-AB1F-4322-A4CC-1F1A9B2C5E98} 0xffffffffffffffff 0xff
	echo {D9391D66-EE23-4568-B3FE-876580B31530} 0xffffffffffffffff 0xff
	echo {D138F9A7-0013-46A6-ADCC-A3CE6C46525F} 0xffffffffffffffff 0xff
	echo {2955E23C-4E0B-45CA-A181-6EE442CA1FC0} 0xffffffffffffffff 0xff
	echo {012616AB-FF6D-4503-A6F0-EFFD0523ACE6} 0xffffffffffffffff 0xff
	echo {5A24FCDB-1CF3-477B-B422-EF4909D51223} 0xffffffffffffffff 0xff
	echo {63D2BB1D-E39A-41B8-9A3D-52DD06677588} 0xffffffffffffffff 0xff
	echo {4B812E8E-9DFC-56FC-2DD2-68B683917260} 0xffffffffffffffff 0xff
	echo {169CC90F-317A-4CFB-AF1C-25DB0B0BBE35} 0xffffffffffffffff 0xff
	echo {041afd1b-de76-48e9-8b5c-fade631b0dd5} 0xffffffffffffffff 0xff
	echo {39568446-adc1-48ec-8008-86c11637fc74} 0xffffffffffffffff 0xff
) >%_CREDPROV_TRACES_TMP%

logman query * -ets > %_PRETRACE_LOG_DIR%\running-etl-providers.txt

REM *** ENABLE EVENT LOGGING ***

wevtutil.exe set-log "Microsoft-Windows-CAPI2/Operational" /enabled:true /rt:false /q:true > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-CAPI2/Operational" %_PRETRACE_LOG_DIR%\Capi2_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe clear-log "Microsoft-Windows-CAPI2/Operational" > NUL 2>&1
wevtutil.exe sl "Microsoft-Windows-CAPI2/Operational" /ms:102400000 > NUL 2>&1


wevtutil.exe set-log "Microsoft-Windows-Kerberos/Operational" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Kerberos/Operational" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Kerberos-KdcProxy/Operational" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Kerberos-KdcProxy/Operational" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-WebAuth/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-WebAuthN/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-WebAuthN/Operational" %_PRETRACE_LOG_DIR%\WebAuthn_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-WebAuthN/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-CertPoleEng/Operational" /enabled:true /rt:false /q:true > NUL 2>&1
wevtutil.exe clear-log "Microsoft-Windows-CertPoleEng/Operational" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-IdCtrls/Operational" /enabled:false
wevtutil.exe export-log "Microsoft-Windows-IdCtrls/Operational" %_PRETRACE_LOG_DIR%\Idctrls_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-IdCtrls/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-User Control Panel/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-User Control Panel/Operational" %_PRETRACE_LOG_DIR%\UserControlPanel_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-User Control Panel/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUser-Client" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Authentication/ProtectedUser-Client" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController" /enabled:true /rt:false /q:true > NUL 2>&1
REM wevtutil.exe clear-log "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController" > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Biometrics/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-Biometrics/Operational" %_PRETRACE_LOG_DIR%\WinBio_oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-Biometrics/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-LiveId/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-LiveId/Operational" %_PRETRACE_LOG_DIR%\LiveId_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-LiveId/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-AAD/Analytic" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-AAD/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-AAD/Operational" %_PRETRACE_LOG_DIR%\Aad_oper.evtx /ow:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-AAD/Operational"  /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Admin" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-User Device Registration/Admin" %_PRETRACE_LOG_DIR%\UsrDeviceReg_Adm.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Admin" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Debug" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-HelloForBusiness/Operational" /enabled:false > NUL 2>&1
wevtutil.exe export-log "Microsoft-Windows-HelloForBusiness/Operational" %_PRETRACE_LOG_DIR%\Hfb_Oper.evtx /overwrite:true > NUL 2>&1
wevtutil.exe set-log "Microsoft-Windows-HelloForBusiness/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-Shell-Core/Operational" /enabled:true /rt:false /q:true > NUL 2>&1

wevtutil.exe set-log "Microsoft-Windows-WMI-Activity/Operational" /enabled:true /rt:false /q:true > NUL 2>&1


REM *** ENABLE LOGGING VIA REGISTRY ***

REM **NEGOEXT**
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa\NegoExtender\Parameters /v InfoLevel /t REG_DWORD /d 0xFFFF /f > NUL 2>&1

REM **PKU2U**
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Pku2u\Parameters /v InfoLevel /t REG_DWORD /d 0xFFFF /f > NUL 2>&1

REM **LSA**
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /v SPMInfoLevel /t REG_DWORD /d 0xC43EFF /f > NUL 2>&1
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LogToFile /t REG_DWORD /d 1 /f > NUL 2>&1
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /v NegEventMask /t REG_DWORD /d 0xF /f > NUL 2>&1

REM **LSP Logging**
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LspDbgInfoLevel /t REG_DWORD /d 0x40400800 /f > NUL 2>&1
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LspDbgTraceOptions /t REG_DWORD /d 0x1 /f > NUL 2>&1

REM **KERBEROS Logging to SYSTEM event log**
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters /v LogLevel /t REG_DWORD /d 1 /f > NUL 2>&1

REM **SCHANNEL Logging to SYSTEM event log**
REM reg add HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL /v EventLogging /t REG_DWORD /d 7 /f > NUL 2>&1


REM *** START ETL PROVIDER GROUPS ***

REM **NGC**
logman create trace Ngc -pf %_NGC_TRACES_TMP% -ft 1:00 -rt -o %_LOG_DIR%\Ngc.etl -ets

REM **BIO**
logman create trace Bio -pf %_BIO_TRACES_TMP% -ft 1:00 -rt -o %_LOG_DIR%\Biometric.etl -ets

REM **LSA**
logman start Lsa -pf %_LSA_TRACES_TMP% -o %_LOG_DIR%\Lsa.etl -ets

REM **NTLM/CREDSSP**
logman start NtlmCredssp -pf %_NTLM_TRACES_TMP% -o %_LOG_DIR%\Ntlm_CredSSP.etl -ets

REM **KERB**
logman start Kerberos -pf %_KERB_TRACES_TMP% -o %_LOG_DIR%\Kerberos.etl -ets

REM **KDC**
for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ LanmanNT logman start KDC -pf %_KDC_TRACES_TMP% -o %_LOG_DIR%\KDC.etl -ets
)

REM **SSL**
logman start SSL -pf %_SSL_TRACES_TMP% -o %_LOG_DIR%\SSL.etl -ets -max 1024

REM **WEBAUTH**
logman start WebAuth -pf %_WEBAUTH_TRACES_TMP% -o %_LOG_DIR%\WebAuth.etl -ets

REM **SCARD**
logman start Scard -pf %_SCARD_TRACES_TMP% -o %_LOG_DIR%\Smartcard.etl -ets

REM **CREDPROV / AUTHUI / WINLOGON **
logman start CredprovAuthui -pf %_CREDPROV_TRACES_TMP% -o %_LOG_DIR%\CredprovAuthui.etl -ets

REM **Net Trace**
for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ WinNT netsh trace start InternetClient persistent=yes traceFile=%_LOG_DIR%\Netmon.etl capture=yes maxsize=1024 > NUL
if %%i equ ServerNT netsh trace start persistent=yes traceFile=%_LOG_DIR%\Netmon.etl capture=yes maxsize=1024 > NUL
if %%i equ LanmanNT netsh trace start persistent=yes traceFile=%_LOG_DIR%\Netmon.etl capture=yes maxsize=1024 > NUL
)

REM **CRYPT-DPAPI**
for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ WinNT logman start CryptNCryptDpapi -pf %_CRYPT_DPAPI_TRACES_TMP% -o %_LOG_DIR%\CryptNcryptDpapi.etl -ets
REM if %%i equ ServerNT logman start CryptNCryptDpapi -pf %_CRYPT_DPAPI_TRACES_TMP% -o %_LOG_DIR%\CryptNcryptDpapi.etl -ets
REM if %%i equ LanmanNT logman start CryptNCryptDpapi -pf %_CRYPT_DPAPI_TRACES_TMP% -o %_LOG_DIR%\CryptNcryptDpapi.etl -ets
)

REM **SAM**
logman start Sam -pf %_SAM_TRACES_TMP% -o %_LOG_DIR%\Sam.etl -ets


REM **WFP - disabled by default
REM netsh wfp capture start file=%_LOG_DIR%\wfpdiag.cab

REM **Netlogon logging**
nltest /dbflag:0x2EFFFFFF > NUL 2>&1

REM **Enabling Group Policy Loggging**
md %WINDIR%\debug\usermode > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" /f > NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" /v GPSvcDebugLevel /t REG_DWORD /d 0x30002 /f > NUL 2>&1


REM ** Turn on debug and verbose Cert Enroll event logging **
echo.
echo Enabling Certificate Enrolment debug logging...
echo.
echo Verbose Certificate Enrolment debug output may be written to this window
echo It is also written to a log file which will be collected when the stop-auth script is run.
echo.
timeout 7 > NUL
for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ProductOptions /v ProductType') do (
if %%i equ WinNT certutil -setreg -f Enroll\Debug 0xffffffe3 > NUL
REM if %%i equ ServerNT certutil -setreg -f Enroll\Debug 0xffffffe3 > NUL
REM if %%i equ LanmanNT certutil -setreg -f Enroll\Debug 0xffffffe3 > NUL
)

certutil -setreg ngc\Debug 1 > NUL
certutil -setreg Enroll\LogLevel 5 > NUL

dsregcmd /status /debug /all > %_PRETRACE_LOG_DIR%\Dsregcmddebug.txt
dsregcmd /status > %_PRETRACE_LOG_DIR%\DsRegCmdStatus.txt

tasklist /svc > %_PRETRACE_LOG_DIR%\Tasklist.txt
sc query > %_PRETRACE_LOG_DIR%\Services-config.txt
net start > %_PRETRACE_LOG_DIR%\Services-started.txt

netstat -ano > %_PRETRACE_LOG_DIR%\netstat.txt

klist > %_PRETRACE_LOG_DIR%\Tickets.txt
klist -li 0x3e7 > %_PRETRACE_LOG_DIR%\Tickets-localsystem.txt

ipconfig /displaydns > %_PRETRACE_LOG_DIR%\Displaydns.txt
ipconfig /flushdns > NUL

REM *** Cleanup
del %_NGC_TRACES_TMP%
del %_BIO_TRACES_TMP%
del %_LSA_TRACES_TMP%
del %_NTLM_TRACES_TMP%
del %_KERB_TRACES_TMP%
del %_KDC_TRACES_TMP%
del %_SAM_TRACES_TMP%
del %_SSL_TRACES_TMP%
del %_CRYPT_DPAPI_TRACES_TMP%
del %_WEBAUTH_TRACES_TMP%
del %_SCARD_TRACES_TMP%
del %_CREDPROV_TRACES_TMP%

echo Data collection started on %date% at %time% >> %_LOG_DIR%\script-info.txt

echo "started" > %_LOG_DIR%\started.txt

echo.
echo ===== Microsoft CSS Authentication Scripts started tracing =====
echo.
echo The tracing has now started
echo Once you have created the issue or reproduced the scenario, please run stop-auth.bat from this same directory to stop the tracing.
echo.
echo Data is collected into a subdirectory of the directory from where this script is launched, called "Authlogs".
echo The "Authlogs" directory will also contain a number of sub-directories.
echo.

:end-script
