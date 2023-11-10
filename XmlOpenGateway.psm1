#region		Create main directory & PSDrive to store module data

# These will be used later on when incorporating config files, logging, creds, etc.
Try {
	
	$XOGDirExists = (Test-Path -Path "$ENV:LOCALAPPDATA\XOG")
	
	if ($XOGDirExists -eq $False) {
		
		$XOGDirParams = @{
			Path = "$ENV:LOCALAPPDATA\"
			Name = 'XOG'
			ItemType = 'Directory'
			ErrorAction = 'Stop'
		}
		
		New-Item @XOGDirParams
	}

	$XOGPSDriveExists = (Test-Path -Path "XOG:\")

	if ($XOGPSDriveExists -eq $False) {
		
		$XOGPSDriveParams = @{
			Name				= 'XOG'
			PSProvider			= 'FileSystem'
			Root				= "$ENV:LOCALAPPDATA\XOG"
			Scope				= 'Global'
			ErrorAction			= 'Stop'
			InformationAction	= 'SilentlyContinue'
		}
		
		New-PSDrive @XOGPSDriveParams | Out-Null
	}

}

Catch {
	
	Write-Host "Something went wrong creating the XOG directory or PSDrive" -ForegroundColor Yellow

}

Finally {
	
	Write-Verbose "Finished setup of XOG directory & PSDrive"

}

#endregion	Create main directory & PSDrive to store module data

#region		Create temp directory

Try {
	
	$TempDirExists = (Test-Path -Path "$ENV:LOCALAPPDATA\XOG\temp")
	
	if ($TempDirExists -eq $False) {
		
		$TempDirParams = @{
			Path = "$ENV:LOCALAPPDATA\XOG"
			Name = 'temp'
			ItemType = 'Directory'
			ErrorAction = 'Stop'
		}

		New-Item @TempDirParams
	}

}

Catch {
	
	Write-Host "Something went wrong creating the XOG:\temp directory" -ForegroundColor Yellow

}

Finally {

	Write-Verbose "Finished setup of XOG:\temp directory"

}

#endregion	Create temp directory

#region		Get public and private function definition files

$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Classes = @( Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue )

#endregion	Get public and private function definition files

#region		Dot source the files

Foreach ($import in @($Public + $Private + $Classes) ) {
	
	Try	{
		
		. $import.fullname
	
	}
	
	Catch {
		
		Write-Error -Message "Failed to import function $($import.fullname): $_" 
	
	}
	
	Finally {
		
	}

}

#endregion	Dot source the files

Export-ModuleMember -Function $Public.Basename