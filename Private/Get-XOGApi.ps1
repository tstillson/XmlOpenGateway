function Get-XOGApi {
	
    <#
		.Synopsis
			Get basic details for XOG endpoints 
		
		.DESCRIPTION
			Retrieve a list of all endpoints for a given XOG API (Object, Query, InvokeAction).

		.EXAMPLE
			Get-XogApi -Service Object -Domain clarity-sample-domain.com
		
		.NOTES
			Does not require any authentication

        .LINK
            https://techdocs.broadcom.com/us/en/ca-enterprise-software/business-management/clarity-project-and-portfolio-management-ppm-on-premise/16-1-3/reference/xml-open-gateway-xog-development.html
	#>

	[CmdletBinding()]
	Param(
		
		[Parameter(Mandatory)]
		[ValidateSet("InvokeAction","Object","Query")]
		[string] $Service,
		
		[Parameter(Mandatory)]
		[string] $Domain
	
	)
	
	Begin { 
		
        $Uri = ( "https://$Domain/niku/wsdl/$Service" + '?tenantId=clarity' )	
	
    }
	
	Process {
		
        $WsdlService = Invoke-WebRequest -Uri $Uri -UseBasicParsing
		
		$Results = $WsdlService.Links.href.Replace("/niku/wsdl/$Service/",'').Replace('?tenantId=clarity','') | 
			Where-Object({$_ -notlike "*&Download=true"})
		
		$Results = $Results.Where({$_ -notlike "AllObjects?download=true"})

		Write-Output ($Results | Sort-Object)
	
    }
	
	End 
	{
		
	}
	
}
