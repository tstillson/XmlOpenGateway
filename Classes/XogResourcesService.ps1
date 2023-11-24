Class XogResourcesService {
	#region		Properties
	
	#endregion
	#region		Methods
	[System.Xml.XmlElement] static ReadResource([System.Xml.XmlDocument] $ResourceXml){
		$Uri = ('https://' + $Global:XogSession.Domain + '/niku/wsdl/Object/Resources')
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
		
		$Response = $WebService.ReadResource($ResourceXml.NikuDataBus)
		
		return $Response
		
	}
	
	[System.Xml.XmlElement] static WriteResource([System.Xml.XmlDocument] $ResourceXml){
		$Uri = ('https://' + $Global:XogSession.Uri + '/niku/wsdl/Object/Resources')
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
		
		$Response = $WebService.WriteResource($ResourceXml.NikuDataBus)
		
		return $Response
	}
	
	#endregion
	#region		Constructors
	XogResourcesService(){}
	
	#endregion
}

