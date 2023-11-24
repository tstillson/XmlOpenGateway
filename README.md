# XmlOpenGateway
PowerShell wrapper module for the Broadcom Clarity XML Open Gateway (XOG) Web Service APIs

# REQUIREMENTS
Must be granted the following access rights in Clarity:
  
  - API Admin
  - XOG Admin (for each endpoint required)

# USAGE
There are 2 functions used for managing XOG sessions:

  - Connect-XogSession
  - Disconnect-XogSession

## Create a new XOG session
Connect-XogSession -Credential $Credential -Domain your-clarity-domain.com

## End the current XOG session
Disconnect-XogSession
