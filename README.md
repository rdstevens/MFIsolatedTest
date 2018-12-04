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
powershell.exe
Get-WindowsFeature -Name *Media*

```

## Demonstrate the problem

In the docker command line environment run:

```
c:\> cd MFIsolatedTest
c:\MFIsolatedTest\>mfisolatedtest.exe input.mpg output.mp4
```

Notice that it crashes

### Connect the debugger

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
