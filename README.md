# MFIsolatedTest
https://docs.microsoft.com/en-us/windows/desktop/medfound/tutorial--encoding-an-mp4-file-

Visual studio project incorporating the sample code copied and pasted from MS example site.

## Build

In visual studio, build the solution in release x86 mode.

or: `msbuild MFIsolatedTest.sln /p:Configuration=Release /p:Platform=x86 `

(x86 because that reproduces the build configuration of the real project this is an isolated test for)

## Make the docker image

docker build --tag sira/mfisolatedtest:latest .

## Run the image

docker run -it -p 4022:4022 -p 4023:4023  <imagename>

Note: the port mappings are for the Visual Studio Remote Debugger

## Confirm that Media Foundation is installed

```
C:\>powershell
Windows PowerShell
Copyright (C) 2016 Microsoft Corporation. All rights reserved.

PS C:\> get-windowsfeature -Name *Media*

Display Name                                            Name                       Install State
------------                                            ----                       -------------
[X] Media Foundation                                    Server-Media-Foundation        Installed


PS C:\>

```

## Validate Media Foundation

In the docker command line environment run:

```
c:\> cd MFIsolatedTest
c:\MFIsolatedTest\>mftenum.exe 
```

Observe, amongst other things:

```
-- Video encoders ({F79EAC7D-E545-4387-BDEE-D647D7BDE42A}) --
H264 Encoder MFT ({6CA50344-051A-4DED-9779-A43305165E35})
```


## Demonstrate the problem

In the docker command line environment run:

```
c:\> cd MFIsolatedTest
c:\MFIsolatedTest\>mfisolatedtest.exe 
```

Notice that it crashes, without displaying the usage text.

Use WinDbg or VS debugger, following the instructions below.

### Use WinDbg

In the docker container environment do:

```
C:\mfisolatedtest>"c:\Program Files (x86)\Windows Kits\10\Debuggers\x86\cdb.exe" -o mfisolatedtest.exe
```

The debugger will output lots of info. Embedded somewhere will be a line like:

```
06ac:066c @ 00092281 - LdrpProcessWork - ERROR: Unable to load DLL: "ksuser.dll", Parent Module: "C:\Windows\SYSTEM32\MFCORE.DLL", Status: 0xc0000135
```

### Connect the VS debugger

In the docker container environment do:

```
cd C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64

msvsmon.exe /noauth /anyuser /silent /nostatus /noclrwarn /nosecuritywarn /nofirewallwarn /nowowwarn /timeout:36000
```

In visual studio, set debugging to Remote Windows Debugger with the following settings:

Remote Command: c:\mfisolatedtest\mfisolatedtext.exe 
Remote Command Arguments: c:\test_data\h264.mp4 out.mp4
Working Directory: c:\mfisolatedtest
Remote Server Name: localhost:4022
Connection: Remote with no Authentication

Hit F5 to launch the debugger.

You should see the debugger start, then immediately exit.

Look at the Output tab and you'll see something like:

```
'mfisolatedtest.exe' (Win32): Loaded 'C:\mfisolatedtest\mfisolatedtest.exe'. Symbols loaded.
'mfisolatedtest.exe' (Win32): Loaded '\Device\vmsmb\VSMB-{dcc079ae-60ba-4d07-847c-3493609c0870}\os\Windows\SysWOW64\ntdll.dll'. Cannot find or open the PDB file.
06d8:0700 @ 00370515 - LdrpInitializeProcess - INFO: Beginning execution of MFIsolatedTest.exe (C:\MFIsolatedTest\MFIsolatedTest.exe)
	Current directory: C:\Windows
	Package directories: (null)

	[SNIP]

06d8:0218 @ 00371484 - LdrpResolveDllName - ENTER: DLL name: C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps\ksuser.dll
06d8:0218 @ 00371500 - LdrpResolveDllName - RETURN: Status: 0xc0000135
06d8:0218 @ 00371500 - LdrpSearchPath - RETURN: Status: 0xc0000135
06d8:0218 @ 00371500 - LdrpProcessWork - ERROR: Unable to load DLL: "ksuser.dll", Parent Module: "C:\Windows\SYSTEM32\MFCORE.DLL", Status: 0xc0000135

06d8:0700 @ 00371500 - LdrpInitializeProcess - ERROR: Walking the import tables of the executable and its static imports failed with status 0xc0000135
06d8:0700 @ 00371500 - _LdrpInitialize - ERROR: Process initialization failed with status 0xc0000135
06d8:0700 @ 00371500 - LdrpInitializationFailure - ERROR: Process initialization failed with status 0xc0000135
The thread 0x700 has exited with code -1073741515 (0xc0000135).
The thread 0x224 has exited with code -1073741515 (0xc0000135).
The program '[1752] MFIsolatedTest.exe' has exited with code -1073741515 (0xc0000135) 'A dependent dll was not found'.
```

The key line is:

`06d8:0218 @ 00371500 - LdrpProcessWork - ERROR: Unable to load DLL: "ksuser.dll", Parent Module: "C:\Windows\SYSTEM32\MFCORE.DLL", Status: 0xc0000135`
