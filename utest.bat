@ECHO OFF
CLS
SET RUNT="D:\Development\Rust\untod\target\release\untod.exe"
SET RUNS=STACK exec UNTOD -- -a
ECHO ======================================================================================================
SET UNTOD_LZONE=0
SET UNTOD_AZONE=
SET PARM=-m 01200edf
%RUNS% %PARM% 
%RUNT% %PARM% 
%RUNS% -l %PARM% 
%RUNT% -l %PARM% 
%RUNS% -t %PARM% 
%RUNT% -t %PARM% 
ECHO ======================================================================================================
REM %RUNS% %PARM% 2
REM %RUNS% %PARM% 2020
REM %RUNS% %PARM% 2020-
REM %RUNS% %PARM% 2020-07
REM %RUNS% %PARM% 2020-07-11
REM %RUNS% %PARM% 2020-07-11@22
REM %RUNS% %PARM% 2020-07-11@22:15
REM %RUNS% %PARM% 2020-07-11@22:15:30
REM %RUNS% %PARM% 2020-07-11@22:15:30.25
REM SET PARM=-a D1E0D6A173CC0
REM STACK exec UNTOD -- --headers %PARM%%
REM STACK exec UNTOD -- -l %PARM%%
REM %RUNT% -l %PARM%
REM STACK exec UNTOD -- -t %PARM%%
REM %RUNT% -t %PARM%
REM SET UNTOD_LZONE=
REM SET UNTOD_AZONE=-8
REM SET PARM=D1E0D6A173CC0
REM STACK exec UNTOD -- --headers -a %PARM%%
REM %RUNT% -a %PARM%
REM STACK exec UNTOD -- -al %PARM%%
REM %RUNT% -al %PARM%
REM STACK exec UNTOD -- -at %PARM%%
REM %RUNT% -at %PARM%
