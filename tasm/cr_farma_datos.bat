G:\APPS\tasm\tasm %1%
G:\APPS\tasm\tlink %1% ..\_fun\fun ..\_fun\bcd
REM C:\WINDOWS\system32\cmd.exe /c '%1% < G:\P\_datos.txt'
C:\WINDOWS\system32\cmd.exe /c type G:\P\_datos.txt | %1%