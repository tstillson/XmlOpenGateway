function Connect-XOGSession {
	
    <#
		.Synopsis
			Establishes a new XOG Session
		
		.DESCRIPTION
            Calls the '/Object/Login' XOG API endpoint to generate a new SessionID that can
            then be used in subsequent calls in lieu of username/password. 

		.EXAMPLE
            Connect-XogSession -Credential $Credential -Domain clarity-sample-domain.com
		
        .LINK
            https://techdocs.broadcom.com/us/en/ca-enterprise-software/business-management/clarity-project-and-portfolio-management-ppm-on-premise/16-1-3/reference/xml-open-gateway-xog-development.html
    #>
	
    [CmdletBinding()]
	Param(

		[Parameter(Mandatory)]
		[string] $Domain,
		
		[Parameter(Mandatory)]
		[PSCredential] $Credential
	)
	
	Begin {		
		#region		Session Variables
		
        $XOGSessionIdExists = ($null -ne $Global:XOGSession.SessionID -and $Global:XOGSession.SessionID -ne '')		
		
		#endregion	Session Variables
	}
	
	Process {	
		#region		Initiate XOG Session
		
		if ($XOGSessionIdExists) {		
			
            Write-Verbose "XOG Session ID already exists: $Global:XOGSession.SessionID"
			break;

		}
		
		elseif ($XOGSessionIdExists -eq $False) {	
			
            Write-Verbose "Generating Session ID..."
			
			$Session = [XOGSession]::New()
			$Session.StartXOGSession($Credential, $Domain)
			New-Variable -Name XOGSession -Scope Global -Value $Session -Force
			
		}
		
		#endregion	Initiate XOG Session
		
        #region		Create Global Variables
		
		# Create global variable to store list of endpoints for each XOG API
		Write-Verbose "Preparing to Create Global Variables..."
		
		$Global:XOGApiDetails = [PSCustomObject]@{
			Object			= (Get-XOGApi -Service Object -Domain $Domain)
			Query			= (Get-XOGApi -Service Query -Domain $Domain)
			InvokeAction 	= (Get-XOGApi -Service InvokeAction -Domain $Domain)
		}
		
		Write-Verbose ('XOG API Details: ' + $Global:XOGAPIDetails)

		#endregion	Create Global Variables
	}
	
	End {		
		
        #region		Garbarge Collection
		
        Write-Verbose "XOG Session has been established.`n"
		Remove-Variable -Name Session
		
		#endregion	Garbarge Collection
	}

}
