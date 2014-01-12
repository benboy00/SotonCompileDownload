@echo off
set "libraries="
set "temp="
set "sourcefiles="

SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)


where avrdude >nul 2>nul
if NOT "%ErrorLevel%"=="0" goto pathfix
where avr-gcc >nul 2>nul
if NOT "%ErrorLevel%"=="0" goto pathfix
goto pathfine

:pathfix
path c:\WinAVR-20100110\bin;C:\WinAVR-20100110\utils\bin;c:\msys\1.0\bin;%path%
path c:\mingw\bin;%path%
where avrdude >nul 2>nul
if NOT "%ErrorLevel%"=="0" goto pathproblem
where avr-gcc >nul 2>nul
if NOT "%ErrorLevel%"=="0" goto pathproblem
echo This window is now setup for AVRDUDE and WINAVR


:pathfine
echo Dont forget, install usb filter with "filter wizard" (usb123)

IF "%~1"=="" GOTO input



set output=%~1
if "%output:~-2%" neq ".c" (
   goto trunc1
)
set "output=%output:~0,-2%"

:trunc1




:parse
IF "%~1"=="" GOTO endparse

set "temp=%~1"
IF "%temp:~-2%"==".a"  goto afile
IF "%temp:~-2%"==".c"  goto cfile


IF defined sourcefiles (
set "sourcefiles=%sourcefiles% %temp:~0,-2%.c"
goto commonparse
)
set "sourcefiles=%temp:~0,-2%.c"
goto commonparse
:afile
IF defined libraries (
set "libraries=%libraries% %temp:~0,-2%.a"
goto commonparse 
)
set "libraries=%temp:~0,-2%.a"
goto commonparse
:cfile 
IF defined sourcefiles (
set "sourcefiles=%sourcefiles% %temp:~0,-2%.c"
goto commonparse
)
set "sourcefiles=%temp:~0,-2%.c"
goto commonparse


:commonparse
SHIFT
GOTO parse
:endparse
goto :truncated





:input
SET /P sourcefiles=Enter the filename:
if "%sourcefiles:~-2%" neq ".c" (
   set "output=%sourcefiles%"
   goto truncated
)
set "sourcefiles=%sourcefiles:~0,-2%"
set "output=%sourcefiles%"


:truncated
echo source files are %sourcefiles%
if defined libraries (
echo libraries are %libraries% 
set "libraries=%libraries%"
goto libskip
)
set "libraries="
:libskip
echo.
avr-gcc -mmcu=atmega644p -DF_CPU=12000000 -Wall -Os %sourcefiles% -o %output%.elf %libraries%
if NOT "%ErrorLevel%"=="0" (
	call :ColorText 4e "Compiler Error"
	goto end
)
call :ColorText 0a "Compiled"
echo.

avr-objcopy -O ihex %output%.elf %output%.hex 
if NOT "%ErrorLevel%"=="0" (
	call :ColorText 4e "Translation Error"
	goto end
)
call :ColorText 0a "Translated"
echo.

avrdude -c usbasp -p m644p -U flash:w:%output%.hex 
if NOT "%ErrorLevel%"=="0" (
	call :ColorText 4e "AVRDUDE Error"
	goto end
)
call :ColorText 0a "Downloaded"
echo  :)
goto end

:ColorText

<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof
:pathproblem
call :ColorText 4e "Fatal Error - AVR tools not found"
echo.
call :ColorText 4e "Are you sure this is an ECS Computer "
echo ?
echo.

:end