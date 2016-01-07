@rem WLS Windows Service Utility 
@rem Copyright © 2012 DBMS Consulting, Inc.

@echo off
setlocal

@rem ******* set defaults here ************
set DOMAIN_NAME=PDR
set APP_NAME=PDR
set USER_DOMAIN_HOME=D:\Oracle\Middleware\user_projects\domains\PDR
set WL_HOME=D:\oracle\Middleware\wlserver_10.3
set WLS_USER=weblogic
set WLS_PW=*redacted*
set PRODUCTION_MODE=false
@rem these are not prompted since they don't normally change
set SERVER_NAME=AdminServer
set MEM_ARGS=-Xms512m –Xmx512m
@rem **************************************


@echo:
@echo:
@echo ***************************************************
@echo *                                                 * 
@echo *  WLS Windows Service Utility 1.0                *  
@echo *                                                 *  
@echo *  This utility will install NMAT as a Windows    *
@echo *  Service. Please provide the required           *
@echo *  parameters - defaults are displayed within     *
@echo *  brackets.                                      *
@echo *                                                 * 
@echo ***************************************************
@echo:
@echo:

set ACTION=I
CHOICE /C IU /M "Select I to install or U to uninstall."
If Errorlevel == 2 (
	goto removeService
) else (
	goto installService
)

:removeService
set /P APP_NAME=Windows Service name ^[%APP_NAME%^]: 
"%WL_HOME%\server\bin\beasvc" -remove -svcname:"%APP_NAME%"
goto done

:installService

@rem get params from user 
set /P DOMAIN_NAME=Weblogic domain name ^[%DOMAIN_NAME%^]: 
set /P APP_NAME=Windows Service name ^[%APP_NAME%^]: 
set /P USER_DOMAIN_HOME=Domain home directory ^[%USER_DOMAIN_HOME%^]: 
set /P WL_HOME=Weblogic home directory ^[%WL_HOME%^]: 
set /P WLS_USER=Weblogic admin account ^[%WLS_USER%^]: 
set /P WLS_PW=Weblogic admin password ^[%WLS_PW%^]: 
set /P PRODUCTION_MODE=Production mode ^{true^|false^} ^[%PRODUCTION_MODE%^]: 


@rem *** set the environment
call "%USER_DOMAIN_HOME%\bin\setDomainEnv.cmd"

@rem Check that the WebLogic classes are where we expect them to be
:checkWLS
if exist "%WL_HOME%\server\lib\weblogic.jar" goto checkJava
echo The WebLogic Server wasn't found in directory %WL_HOME%\server.
echo Please edit your script so that the WL_HOME variable points 
echo to the WebLogic installation directory.
goto finish

@rem Check that java is where we expect it to be
:checkJava
if exist "%JAVA_HOME%\bin\java.exe" goto runWebLogic
echo The JDK wasn't found in directory %JAVA_HOME%.
echo Please edit your script so that the JAVA_HOME variable 
echo points to the location of your JDK.
goto finish

:runWebLogic
if not "%JAVA_VM%" == "" goto noResetJavaVM
if "%JAVA_VENDOR%" == "BEA" set JAVA_VM=-jrocket
if "%JAVA_VENDOR%" == "HP"  set JAVA_VM=-server
if "%JAVA_VENDOR%" == "Sun" set JAVA_VM=-server

:noResetJavaVM

if not "%MEM_ARGS%" == "" goto noResetMemArgs
set MEM_ARGS=-Xms32m -Xmx200m
 
:noResetMemArgs

set CLASSPATH=%WEBLOGIC_CLASSPATH%;%CLASSPATH%


if "%ADMIN_URL%" == "" goto runAdmin
rem @echo on
set CMDLINE="%JAVA_VM% %MEM_ARGS% %JAVA_OPTIONS% -classpath \"%CLASSPATH%\" -Dweblogic.Name=%SERVER_NAME% -Dweblogic.management.username=%WLS_USER% -Dweblogic.management.server=\"%ADMIN_URL%\" -Dweblogic.ProductionModeEnabled=%PRODUCTION_MODE% -Djava.security.policy=\"%WL_HOME%\server\lib\weblogic.policy\" weblogic.Server"
goto finish

:runAdmin

set CMDLINE="%JAVA_VM% %MEM_ARGS% %JAVA_OPTIONS% -classpath \"%CLASSPATH%\" -Dweblogic.Name=%SERVER_NAME% -Dweblogic.management.username=%WLS_USER% -Dweblogic.ProductionModeEnabled=%PRODUCTION_MODE% -Djava.security.policy=\"%WL_HOME%\server\lib\weblogic.policy\" weblogic.Server"

:finish
rem *** Set up extrapath for win32 and win64 platform separately
if "%WL_USE_X86DLL%" == "true" set EXTRAPATH=%WL_HOME%\server\native\win\32;%WL_HOME%\server\bin;%JAVA_HOME%\jre\bin;%JAVA_HOME%\bin;%WL_HOME%\server\native\win\32\oci920_8

if "%WL_USE_IA64DLL%" == "true" set EXTRAPATH=%WL_HOME%\server\native\win\64\;%WL_HOME%\server\bin;%JAVA_HOME%\jre\bin;%JAVA_HOME%\bin;%WL_HOME%\server\native\win\64\oci920_8

if "%WL_USE_AMD64DLL%" == "true" set EXTRAPATH=%WL_HOME%\server\native\win\x64\;%WL_HOME%\server\bin;%JAVA_HOME%\jre\bin;%JAVA_HOME%\bin;%WL_HOME%\server\native\win\x64\oci920_8


@echo:
"%WL_HOME%\server\bin\beasvc" -install -svcname:"%APP_NAME%" -javahome:"%JAVA_HOME%" -execdir:"%USER_DOMAIN_HOME%" -maxconnectretries:"%MAX_CONNECT_RETRIES%" -host:"%HOST%" -port:"%PORT%" -extrapath:"%EXTRAPATH%" -password:"%WLS_PW%" -cmdline:%CMDLINE%
:done
@echo:
ENDLOCAL




