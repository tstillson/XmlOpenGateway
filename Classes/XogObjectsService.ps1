Class XogObjectsService {
	#region		Properties
	
	#endregion
	#region		Methods
	[System.Xml.XmlElement] static ReadObject([System.Xml.XmlDocument] $ObjectXml){
		$Domain = $Global:XogSession.Domain
    $Uri = "https://${Domain}/niku/wsdl/Object/ContentPack"
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
		
		$Response = $WebService.ReadContentPack($ObjectXml.NikuDataBus)
		
		return $Response
		
	}
	
	[System.Xml.XmlElement] static WriteObject([System.Xml.XmlDocument] $ObjectXml){
		$Domain = $Global:XogSession.Domain
    $Uri = "https://${Domain}/niku/wsdl/Object/ContentPack"
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
		
		$Response = $WebService.WriteContentPack($ObjectXml.NikuDataBus)
		
		return $Response
	}
	
	#endregion
	#region		Constructors
	XogObjectsService(){}
	
	#endregion
}
