function Disconnect-XogSession {
	
	<#
		.Synopsis
			Disconnects from an existing XOG Session
		
		.DESCRIPTION
            Calls the '/Object/Logout' XOG API endpoint to terminate the current session ID 

		.EXAMPLE
            Disconnect-XogSession
		
        .LINK
            https://techdocs.broadcom.com/us/en/ca-enterprise-software/business-management/clarity-project-and-portfolio-management-ppm-on-premise/16-1-3/reference/xml-open-gateway-xog-development.html
    #>

	[CmdletBinding()]
	Param()

	Begin {
		#region		Session Variables
		
		# Verify a SessionID exists
		$XOGSessionIdExists = ($Global:XOGSession.SessionId -ne '' -and $Null -ne $Global:XOGSession.SessionId)
		
		if (!($XOGSessionIdExists)) {	
			
			Write-Host "Could not disconnect from XOG: no session exists." -ForegroundColor Yellow
			break;
		
		}
		
		#endregion	Session Variables
	}
	
	Process {
		#region		Terminate XOG Session
		
		$Global:XOGSession.StopXOGSession()
		
		#endregion	Terminate XOG Session
	}

	End {
		#region		Garbage Collection
		
		Remove-Variable XOGApiDetails -Scope Global -ErrorAction SilentlyContinue
		Remove-Variable XOGSession -Scope Global -ErrorAction SilentlyContinue
		
		#endregion	Garbage Collection
	}

}