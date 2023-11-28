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
Connect-XogSession -Credential $Credential -Domain your-clarity-domain.com

## End the current XOG session
Disconnect-XogSession
