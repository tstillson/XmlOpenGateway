# XmlOpenGateway
PowerShell wrapper module for the Broadcom Clarity XML Open Gateway (XOG) Web Service APIs

# REQUIREMENTS
You must have a valid Classic PPM login name & password. 
You must also be granted the following access rights:
  
  - Administration - Access
  - Administration - XOG 

The above access rights simply grant the ability to make XOG requests; to import/export data for a 
particular object, you must also be assigned the corresponding XOG access right for that object.

For example, _Project - XOG Access_ grants the ability to import/export project objects to/from the database

# USAGE
There are 2 functions used for managing XOG sessions:

  - Connect-XogSession
  - Disconnect-XogSession

## Create a new XOG session
Call the _Login()_ web service to generate a sessionId & create/store session variables
```
[pscredential] $Credential = Get-Credential
Connect-XogSession -Credential $Credential -Domain your-clarity-domain.com
```

## End the current XOG session
Call the _Logout()_ web service and delete the sessionId
```
Disconnect-XogSession
```

# LINKS
- [Clarity Docs - Access Rights Reference](https://techdocs.broadcom.com/us/en/ca-enterprise-software/business-management/clarity-project-and-portfolio-management-ppm-on-premise/16-2-0/reference/clarity-ppm-access-rights-reference.html)
- [Clarity Docs - XML Open Gateway (XOG) Development](https://techdocs.broadcom.com/us/en/ca-enterprise-software/business-management/clarity-project-and-portfolio-management-ppm-on-premise/16-2-0/reference/xml-open-gateway-xog-development.html)
