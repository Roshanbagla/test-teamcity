#####################################################
# Variables defined for APS test site
#####################################################

param(
    [Parameter(Mandatory=$true)][int]$SiteID,
    [Parameter(Mandatory=$true)][int]$SiteControllerSerialNo,
    [Parameter(Mandatory=$true)][string]$component,
    [Parameter(Mandatory=$true)][string]$address
)

#$ErrorActionPreference = "Stop"

#################################################################
# Includes.
#################################################################


[Reflection.Assembly]::LoadFile("$PSScriptRoot\Maxgaming.Cougar.Message.dll")
[Reflection.Assembly]::LoadFile("$PSScriptRoot\Maxgaming.Cougar.Interface.dll")
Write-host ("The root directory: $PSScriptRoot")


################################################################
#   Sending ReConfig Message
################################################################


function SendRefreshConfigMessage ($VenueID) {
  $RefreshConfigmessage = New-Object Maxgaming.Cougar.Message.RefreshConfig
  $RefreshConfigmessage.SiteID = $VenueID

  # Get type.
  $type = [Maxgaming.Cougar.Message.RefreshConfig]::PostOfficeFunction

  # Publish.
  $pomClient.Publish($type, $RefreshConfigmessage.GetBytes(), 7) > $nul
}


################################################################
#    Function to send a stop/start cougar message.
################################################################


function RestartComponents ($VenueID, $SiteControllerSerialNo, $CougarComponent) {

  $StopMessage = New-Object Maxgaming.Cougar.Message.StopComponent
  $StopMessage.SiteID = $VenueID
  $StopMessage.SCSerialNumber = $SiteControllerSerialNo
  $StopMessage.Component = $CougarComponent
  $StopMessage.Flags = 1                        # if Flag = 1, it will start the component automatically.

  # Get type.
  $type = [Maxgaming.Cougar.Message.StopComponent]::PostOfficeFunction

  # Publish.
  $pomClient.Publish($type, $StopMessage.GetBytes(), 7) > $nul
  # Disconnect.
  $pomClient.Disconnect($true)
}


#################################################################
#   Creating POM Connection
#################################################################


function createPOMConnection ($address) {
  Write-Host "Connecting to POM" -ForegroundColor Yellow
  $pomClient = New-Object Maxgaming.Cougar.Interface.Connection.POMConnection

  if ($pomClient.Connect("Restart", $address, 808, [Maxgaming.Cougar.Interface.Connection.ConnectionFlags].POMCF_VOLATILE) -eq $true) {
    Write-Host "Connected to POM...`n" -ForegroundColor Green

    SendRefreshConfigMessage $SiteID

    RestartComponents $SiteID $SiteControllerSerialNo $component
  }
  else {
    Write-Host "Failed to connect to POM." -ForegroundColor Red
    return
  }
  # Cleanup.
  $pomClient.Dispose()
}

#################################################################
#                     Process Starts Here
#################################################################


$IpAddresses = New-Object System.Collections.Generic.List`[string]

# Add Ip addresses of the Site Contorllers into the list below:

$IpAddresses.Add($address)


# Pinging an IP address. {
if (test-connection $IpAddresses -count 1 -quiet) {
  write-host $IpAddresses "Ping succeeded." -foreground green
  createPOMConnection($IpAddresses)
}
else {
  Write-Host "Cannot Ping the Site Controller:" $IpAddresses  -ForegroundColor Red
  return
}
