function Get-XOGResource {
	#region		Parameters
	
	[CmdletBinding(DefaultParameterSetName = 'ByResource')]
	param(
	
		[Parameter(ParameterSetName = 'ByResource')]
		[string] $ResourceID,

        [Parameter()]
		[ValidateSet('include_all', 'include_contact', 'include_custom', 'include_financial', 
					'include_management', 'nls_language', 'no_dependencies' )]
        [string[]] $Arguments,
		
		[Parameter(ParameterSetName = 'Switch')]
		[switch] $IsActive
		
		)
		
		#endregion
	
	Begin {		
        #region 	Create Session Variables
		[System.Net.ServicePointManager]::DefaultConnectionLimit = 100
		
		$Endpoint	= 'Resources'
		$ObjectType = 'resource'
		$XmlPath	= "$ENV:LOCALAPPDATA\XOG\temp\$ObjectType.xml"
		
		Write-Verbose ("Object Type:`t" + $ObjectType)
		
		$XOGSessionExists = $Global:XOGSession.IsActive

		if ($Null -eq $XOGSessionExists -or $XOGSessionExists -eq '') {
			
            Write-Host "No XOG Session ID Exists"
			Break;
		
        }
		
        else {

            Continue;

        }

		#endregion	Create Session Variables	
    }
	
	Process {
        #region		XML File Creation
		
        Write-Verbose "Creating xml file..."
		
		# Check for Arguments
		switch ($arguments) {				
			include_all			{ [bool] $include_all			= $true }
			include_contact 	{ [bool] $include_contact 		= $true }
			include_custom 		{ [bool] $include_custom 		= $true }
			include_financial 	{ [bool] $include_financial 	= $true }
			include_management 	{ [bool] $include_management	= $true }
			nls_language 		{ [bool] $nls_language 			= $true }
			no_dependencies 	{ [bool] $no_dependencies 		= $true }
		}
		
		# Create XML object
		$xmlWriter = New-Object `
			-TypeName System.Xml.XmlTextWriter($xmlPath, $null) `
			-InformationAction SilentlyContinue

		# Format the xml to be more reader-friendly by adding indents for each node
		$xmlWriter.Formatting = 'Indented'
		$xmlWriter.Indentation = 1
		$xmlWriter.IndentChar = "`t"

		# Write the document declaration with version 1.0
		$xmlWriter.WriteStartDocument()

		# Create the root element
		$xmlWriter.WriteStartElement('NikuDataBus')

		# Set the xmlns attributes
		$xmlWriter.WriteAttributeString('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
		$xmlWriter.WriteAttributeString('xsi:noNamespaceSchemaLocation', '../xsd/nikuxog_read.xsd')

		# Create the Header element & its attributes
		$xmlWriter.WriteStartElement('Header')
		$xmlWriter.WriteAttributeString('version', '6.0.13')
		$xmlWriter.WriteAttributeString('action', 'read')
		$xmlWriter.WriteAttributeString('objectType', $ObjectType)
		$xmlWriter.WriteAttributeString('externalSource', 'NIKU')
		
		# Create the Args elements, if applicable
		if ($include_contact -or $include_all) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'include_contact')
			$xmlWriter.WriteAttributeString('value',"true")
			$xmlWriter.WriteEndElement()
		}
		if ($include_custom -or $include_all) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'include_custom')
			$xmlWriter.WriteAttributeString('value',"true")
			$xmlWriter.WriteEndElement()
		}
		if ($include_financial -or $include_all) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'include_financial')
			$xmlWriter.WriteAttributeString('value',"true")
			$xmlWriter.WriteEndElement()
		}
		if ($include_management -or $include_all) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'include_management')
			$xmlWriter.WriteAttributeString('value',"true")
			$xmlWriter.WriteEndElement()
		}
		if ($nls_language -or $include_all) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'nls_language')
			$xmlWriter.WriteAttributeString('value',"en")
			$xmlWriter.WriteEndElement()
		}
		if ($no_dependencies -or $include_all) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'no_dependencies')
			$xmlWriter.WriteAttributeString('value',"true")
			$xmlWriter.WriteEndElement()
		}
		
		# Close the Header element
		$xmlWriter.WriteEndElement()
			
		# Create the Filter elements, if applicable
		$xmlWriter.WriteStartElement('Query')
		
		if ($ResourceID) {
		# Create the Filter element & its attributes
			$xmlWriter.WriteStartElement('Filter')
			$xmlWriter.WriteAttributeString('name', 'resourceID')
			$xmlWriter.WriteAttributeString('criteria', 'EQUALS')
			$xmlWriter.WriteRaw($ResourceID)		
		}
		
		if ($IsActive -eq $true) {					
			# Create the Filter element & its attributes
			$xmlWriter.WriteStartElement('Filter')
			$xmlWriter.WriteAttributeString('name', 'isActive')
			$xmlWriter.WriteAttributeString('criteria', 'EQUALS')
			$xmlWriter.WriteRaw("true")				
		}
			
		# Close the Query element
		$xmlWriter.WriteFullEndElement()
		
		# Close the xml document 
		$xmlWriter.WriteEndDocument()
		$xmlWriter.Flush()
		$xmlWriter.Close()				
		
		#endregion	XML File Creation
		
        #region		XOG API Request
	
    	[xml] $XmlData = Get-Content $XmlPath
		
        Write-Verbose ("Xml file content:`n`n" + $XmlData.OuterXml + "`n`n")
		Write-Verbose "Initiating XOG API request..."
		
        $Results = [XOGResourcesService]::ReadResource($XmlData)
				
		#endregion	XOG API Request	

		#region		Output
		
        Write-Output $Results
		
		#endregion
    }
	
	End {	
        #region		Garbage Cleanup
		
        Write-Verbose "Performing garbage collection..."
		
		if ((Get-Content $xmlPath) -ne $null) {	
			
            Remove-Item -Path $xmlPath
		
        }
		
		#endregion	Garbage Cleanup
    }

}