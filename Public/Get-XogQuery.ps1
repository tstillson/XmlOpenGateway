function Get-XogQuery {
	
	#region		Parameters
	
	[CmdletBinding()]
	param(
		
		[Parameter()]
		[string[]] $QueryFilter,
		
		[Parameter()]
		[string[]] $QueryFilterValue
	
	)
	
	#endregion
	
	DynamicParam {
		#region		Create Dynamic Parameter: QueryCode
		
		# Define the parameter attributes
		$paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
		$paramAttributes.Mandatory = $true
		
		# Create collection of the attributes & add parameter attributes to the collection
		$paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
		$paramAttributesCollect.Add($paramAttributes)
		$paramAttributesCollect.Add((`
			New-Object System.Management.Automation.ValidateSetAttribute($Global:XogApiDetails.Query)))
		
		# Create parameter with name, type, and attributes
		$dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter(`
			'QueryCode', [string], $paramAttributesCollect)
		
		#endregion	Create Dynamic Parameter: QueryCode
		
		#region		Create Parameter Dictionary
		
		$paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
		$paramDictionary.Add('QueryCode', $dynParam)
		
		return $paramDictionary

		#endregion	Create Parameter Dictionary
	}
	
	Begin {
		#region		Create Dynamic Variables
		
		$QueryCode = $PSBoundParameters['QueryCode']	
		
		#endregion	Create Dynamic Variables		
		
		#region		Create Session Variables
		[System.Net.ServicePointManager]::DefaultConnectionLimit = 100
		
		# Set $Environment based on $Global:XogEnvironment value
		$XogSessionExists = (Test-String ($Global:XogSession.SessionID).Test)

		if ($XogSessionExists -eq $False)
		{

			Write-Host "No Xog connection established; run 'Connect-XogSession' and try again"
			Break;

		}

		$Uri		= ('https://' + $Global:XogSession.Domain + "/niku/wsdl/Query/$QueryCode")
		$ObjectType = 'query'
		$ObjectID	= $QueryCode
		$XmlPath 	= "$ENV:LOCALAPPDATA\Xog\temp\$QueryCode.xml"
		
		Write-Verbose ("Object Type:`t" + $ObjectType)
		
		#endregion
	}
	
	Process {		
		#region 	XML File Creation
		
		Write-Verbose "Creating xml file..."
		
		# Create xml object
		$xmlWriter = New-Object `
		-TypeName System.Xml.XmlTextWriter($XmlPath, $null) `
		-InformationAction SilentlyContinue

		 # Format the xml to be more reader-friendly by adding indents for each node
		$xmlWriter.Formatting = 'Indented'
		$xmlWriter.Indentation = 1
		$xmlWriter.IndentChar = "`t"

		# Write the document declaration with version 1.0
		$xmlWriter.WriteStartDocument()

		# Create the root element
		$xmlWriter.WriteStartElement('Query')

		# Set the xmlns attributes   
		$xmlWriter.WriteAttributeString('xmlns', 'http://www.niku.com/xog/Query')

		# Create the 'Code' node and set the value
		$xmlWriter.WriteElementString('Code', $QueryCode)
		
		if ($QueryFilter) {
			
			$count = 0
						
			foreach ($Filter in $QueryFilter) {
				
				$xmlWriter.WriteStartElement('Filter')
				$xmlWriter.WriteElementString($Filter, $QueryFilterValue[$count])
				$xmlWriter.WriteEndElement()
				$count++

			}
			
		}
		
		# End/close the 'Code' element
		$xmlWriter.WriteFullEndElement()

		# Flush the internal buffer & close the document
		$xmlWriter.WriteEndDocument()
		$xmlWriter.Flush()
		$xmlWriter.Close()
			
		#endregion	XML File Creation
		
		#region		Xog API Request
		
		# Create new WebServiceProxy object for Resources object
		$QueryWebService = New-WebServiceProxy `
			-Uri "$uri" `
			-UseDefaultCredential
		
		# Generate some short names to use, though not a complete list
		$QueryWebServiceTypes = @{}
		
		foreach ($Type in $QueryWebService.GetType().Assembly.GetExportedTypes()) {
			
			$QueryWebServiceTypes.Add($Type.Name, $Type.FullName);
		
		}
		
		# Instantiate WebService object created above
		$WebService = New-Object $QueryWebService
		
		# Import XML File 
		[xml] $xmlData = Get-Content $XmlPath
		Write-Verbose ("Xml file content:`n`n" + $XmlData.OuterXml + "`n`n")
		
		# Create Query web service object 
		$Query = New-Object ($QueryWebServiceTypes.($QueryCode + 'Query'))
		$Query.Code = $xmlData.Query.Code
		
		if ($QueryFilter) {
			
			$FilterObject = New-Object ($QueryWebServiceTypes.($QueryCode + 'Filter'))
			
			$count = 0
			
			foreach ($Filter in $QueryFilter) {
				
				$FilterObject."$Filter" = $QueryFilterValue[$count]
				$count++
			
			}
			
			$Query.Filter = $FilterObject
		
		}			
		
		# Create Auth object with session ID & tenant ID
		$Auth = New-Object $QueryWebServiceTypes.Auth
		$Auth.SessionID = $Global:XogSession.SessionID
		$Auth.TenantID = 'clarity'
		$WebService.AuthValue = $Auth

		# Invoke the ReadResource operation
		Write-Verbose "Initiating Xog API request..."
		
		$Results = $WebService.Query($Query)
		
		#endregion	Xog API Request
		
		#region		Output
	
		Write-Output $Results
		
		#endregion	Output
	}
	
	End {
		#region 	Garbage Collection
		
		Write-Verbose "Performing garbage collection..."
		
		if ((Get-Content $xmlPath) -ne $null) {
			
			Remove-Item -Path $xmlPath
		
		}
		
		Clear-Variable XmlData
		Remove-Variable Query
		Remove-Variable Results
		Remove-Variable WebService
		Remove-Variable QueryWebService
		Remove-Variable QueryWebServiceTypes
		
		#endregion	Garbage Collection
	}

}
