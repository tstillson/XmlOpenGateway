Class XOGQueryService {
	#region		Properties
	
	#endregion
	#region		Methods
	[System.Object] static Query([string] $QueryCode){
		$Uri = ('https://' + $Global:XOGSession.Domain + "/niku/wsdl/Query/$QueryCode")
		$WebServiceProxy = New-WebServiceProxy -Uri $Uri -UseDefaultCredential -Namespace Query -Class $QueryCode
		$WebServiceTypes = @{}
		
		foreach ($Type in $WebServiceProxy.GetType().Assembly.GetExportedTypes()) {
			$WebServiceTypes.Add($Type.Name, $Type.FullName);
		}
		
		$WebService = New-Object $WebServiceProxy
		$Query		= New-Object ($WebServiceTypes.($QueryCode + 'Query'))
		$Auth		= New-Object -TypeName $WebServiceTypes.Auth
		
		$Auth.SessionID = $Global:XogSession.SessionID
		$Auth.TenantID = 'clarity'
		$Query.Code = $QueryCode
		$WebService.AuthValue = $Auth
		
		$Response = $WebService.Query($Query)
		
		return $Response
		
	}
	
	#endregion
	#region		Constructors
	XogQueryService(){}
		
}
