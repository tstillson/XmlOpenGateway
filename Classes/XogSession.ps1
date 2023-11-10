Class XogSession{
	#region		Properties
	[string] $SessionID
	[bool] $IsActive
	[string] $Domain
	hidden [datetime] $StartTime
	hidden [datetime] $RefreshTime
	
	#endregion
	#region		Methods
	[void] StartXogSession([PSCredential] $Credential, [string] $Domain) {
		$Username		= $Credential.Username
		$Password		= $Credential.GetNetworkCredential().Password
        $URI            = "https://$Domain/niku/xog"
		
        $Body = @"
        <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
            <SOAP-ENV:Header />
            <SOAP-ENV:Body>
                <Login xmlns="http://www.niku.com/xog">
                    <Username>$Username</Username>
                    <Password>$Password</Password>
                </Login>
            </SOAP-ENV:Body>
        </SOAP-ENV:Envelope>
"@

		$Results = Invoke-RestMethod -UseBasicParsing -Uri $URI -Body $Body -ContentType text/xml -Method Post
		
		$this.Domain        = $Domain
        $this.SessionID		= $Results.Envelope.Body.SessionID.'#text'
		$this.StartTime 	= [datetime]::Now
		$this.RefreshTime	= $this.StartTime.AddHours(2)
		$this.IsActive 		= $True
	
	}
	
	[void] StopXogSession() {						
		$BaseUri = ('https://' + $this.Domain)
		$LogoutURI = ("$BaseUri/niku/wsdl/Object/AllObjects")
		
        Write-Verbose $LogoutURI

		$XogWebService = New-WebServiceProxy -Uri ($LogoutURI) -Namespace XogWebService -UseDefaultCredential	
		$WebService = New-Object $XogWebService
		$WebService.Logout($this.SessionID)
		
        $this.SessionID = ''
        $this.URI = ''
        $this.IsActive = $False
	}
		
	[string] CheckSessionStatus() {
		$CurrentTime = [DateTime]::Now
		
		if ($CurrentTime -lt $this.RefreshTime){
			$this.IsActive = $True
			return 'ACTIVE'
		}
		
		elseif ($CurrentTime -ge $this.RefreshTime) {
			$this.IsActive = $False
			return 'INACTIVE'
		}
		
		else {
			return 'ERROR: Could not determine session status'
		}
	}
		
	#endregion
	#region		Constructors
	XogSession(){}
	
	#endregion	
}