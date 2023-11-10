function Get-XogUser {
	
	#region		Parameters
	
	[CmdletBinding()]
	param(
		
		[Parameter(ParameterSetName = 'ByUser')]
		[string] $Username,
		
        [Parameter()]
        [ValidateSet('nls_language')]
        [string[]] $Arguments
		
		)
		
	#endregion
		
	Begin	{
		#region 	Create Session Variables
		
		[System.Net.ServicePointManager]::DefaultConnectionLimit = 500
		
		$Endpoint	= 'Users'
		$ObjectType = 'user'
		$XmlPath	= "$ENV:LOCALAPPDATA\XOG\temp\$Endpoint.xml"
		
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
		#region 	XML File Creation
		
  		Write-Verbose "Creating xml file..."
		
		# Check for Arguments
		switch ($arguments) {
			nls_language { [bool] $nls_language = $true }
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
		$xmlWriter.WriteAttributeString('version', '6.0.11')
		$xmlWriter.WriteAttributeString('action', 'read')
		$xmlWriter.WriteAttributeString('objectType', 'user')
		$xmlWriter.WriteAttributeString('externalSource', 'NIKU')

		# Create the Args elements, if applicable
		if ($nls_language) {
			$xmlWriter.WriteStartElement('args')
			$xmlWriter.WriteAttributeString('name', 'nls_language')
			$xmlWriter.WriteAttributeString('value',"en")
			$xmlWriter.WriteEndElement()
		}
		
		# Close the Header element
		$xmlWriter.WriteEndElement()
		
		# Create the Query & Filter elements, if applicable
		# Create the Query element
		$xmlWriter.WriteStartElement('Query')

		# Create the Filter element & its attributes
		$xmlWriter.WriteStartElement('Filter')
				
		$xmlWriter.WriteAttributeString('name', 'userName')
		$xmlWriter.WriteAttributeString('criteria', 'EQUALS')
		$xmlWriter.WriteRaw("$Username")
		
		# Close the Query element
		$xmlWriter.WriteFullEndElement()
		
		# Close the xml document 
		$xmlWriter.WriteEndDocument()
		$xmlWriter.Flush()
		$xmlWriter.Close()
		
		#endregion	XML File Creation
		
  		#region		XOG API Request

		# Import XML File 
		[xml] $XmlData = Get-Content $XmlPath
		Write-Verbose ("Xml file content:`n`n" + $XmlData.OuterXml + "`n`n")
		
		Write-Verbose "Initiating XOG API request..."
		$Results = [XogUsersService]::ReadUser($XmlData)
		
		#endregion	XOG API Request
  
		#region		Output
		
  		Write-Output $Results
		
		#endregion
	}
	
	End		{	
		#region		Garbage Cleanup
		Write-Verbose "Performing garbage collection..."
		
		if ($Null -ne (Get-Content $xmlPath)) {
			
			Remove-Item	-Path $xmlPath
			Clear-Variable -Name Endpoint	
			Clear-Variable -Name ObjectType 
			Clear-Variable -Name Results
			Clear-Variable -Name XmlData
			
		}
		
		#endregion	Garbage Cleanup
	}

}
