# OCX - RegistrationLess

This is a tough piece of cake, especially when you don't have any info about what to add to the manifest file.

## Before we start

Download & install windows developer kit.

https://developer.microsoft.com/pl-pl/windows/downloads/windows-10-sdk/

```sh
cd C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64\mt.exe
```

## MS article about ocx-free

#### Ocx-Free

https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/ms973913(v=msdn.10)?redirectedfrom=MSDN

#### How to use MT

https://docs.microsoft.com/en-us/cpp/build/how-to-embed-a-manifest-inside-a-c-cpp-application?view=msvc-160

#### About mt-exe

https://docs.microsoft.com/en-us/windows/win32/sbscs/mt-exe


### mt commands

extract
```sh
./mt.exe -inputresource:"YOUR-EXE.EXE" -out:YOUR.MANIFEST
```

apply

```sh
./mt.exe -nologo -manifest "YOUR.MANIFEST" -outputresource:"YOUR-EXE.EX"
```
## regsvr32

Before we start make sure that you full purge existing links to ocx/dll files.

unregister
```sh
regsvr32 /u YOUR-DLL-OCX-FILE
```

register
```sh
regsvr32 YOUR-DLL-OCX-FILE
```

## Example of usage

Firstly extract manifest from exe.

```sh
./mt.exe -inputresource:"YOUR-EXE.EXE" -out:YOUR.MANIFEST
```

Open and add information about your ocx file.

```sh
<file name="***.OCX">

		<comClass description="***"
				  clsid="***"
				  threadingModel="***"
				  tlbid="***"
				  progid="***"
				  miscStatus=""
				  miscStatusContent="***">
			
			<progid>***</progid>
			
		</comClass>
		                 
		<typelib tlbid="{00000000 0000 0000 0000 000000000000}"
				 version="***"
				 helpdir="***"
				 resourceid="***"
				 flags=""/>
         
         ***
</file>
```
 
Apply your manifest back into app.

```sh
./mt.exe -nologo -manifest "YOUR.MANIFEST" -outputresource:"YOUR-EXE.EXE"
```

## OCX manifest info

Where to find info what i need to add?
Follow this stack:

https://stackoverflow.com/questions/465882/generate-manifest-files-for-registration-free-com


<img src="https://github.com/igor-sadza/JakCo/blob/f48be9cec8ea6bcf8b25314d0b2a7b8d630322a0/windows/img/use_ocx_without_registration_0.png" align="center">
