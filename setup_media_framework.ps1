Get-ChildItem "$Env:SystemRoot\Servicing\Packages\*Media*.mum" | ForEach-Object { (Get-Content $_) -replace 'required','no' | Set-Content $_}
install-windowsfeature server-media-foundation