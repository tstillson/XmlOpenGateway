Class XogUsersService {
	#region		Properties
	
	#endregion
	#region		Methods
	[System.Xml.XmlElement] static ReadUser([System.Xml.XmlDocument] $UserXml){
		$Uri = ('https://' + $Global:XogSession.Domain + '/niku/wsdl/Object/Users')
		$WebServiceProxy = New-WebServiceProxy -Uri $Uri -UseDefaultCredential
		$WebServiceTypes = @{}
		
		foreach ($Type in $WebServiceProxy.GetType().Assembly.GetExportedTypes()) {
			$WebServiceTypes.Add($Type.Name, $Type.FullName);
		}
		
		$WebService = New-Object $WebServiceProxy
		$Auth		= New-Object -TypeName $WebServiceTypes.Auth
		
		$Auth.SessionID = $Global:XogSession.SessionID
		$Auth.TenantID = 'clarity'
		$WebService.AuthValue = $Auth
		
		$Response = $WebService.ReadUser($UserXml.NikuDataBus)
		
		return $Response
		
	}
	
	[System.Xml.XmlElement] static WriteUser([System.Xml.XmlDocument] $UserXml){
		$Uri = ('https://' + $Global:XogSession.Domain + '/niku/wsdl/Object/Users')
		$WebServiceProxy = New-WebServiceProxy -Uri $Uri -UseDefaultCredential
		$WebServiceTypes = @{}
		
		foreach ($Type in $WebServiceProxy.GetType().Assembly.GetExportedTypes()) {
			$WebServiceTypes.Add($Type.Name, $Type.FullName);
		}
		
		$WebService = New-Object $WebServiceProxy
		$Auth 		= New-Object -TypeName $WebServiceTypes.Auth
		
		$Auth.SessionID = $Global:XogSession.SessionID
		$Auth.TenantID = 'clarity'
		$WebService.AuthValue = $Auth
		
		$Response = $WebService.WriteUser($UserXml.NikuDataBus)
		
		return $Response
	}
	
	#endregion
	#region		Constructors
	XogUsersService(){}
	
	#endregion
}

