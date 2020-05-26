
#$ErrorActionPreference = "Stop"
$currentScriptDirectory = Get-Location
[System.IO.Directory]::SetCurrentDirectory($currentScriptDirectory.Path)
       
#####################################################################################################################
# Includes.
#####################################################################################################################
[Reflection.Assembly]::LoadFile("$currentScriptDirectory\Maxgaming.Cougar.Message.dll") > $nul
[Reflection.Assembly]::LoadFile("$currentScriptDirectory\Maxgaming.Cougar.Interface.dll") > $nul

 

################################################################
#    Function to send a stop/start cougar message.
################################################################ 


function SendStartComponentMessage ($component)
{

  $message = New-Object Maxgaming.Cougar.Message.StartComponent
  Write-Host ($message)
  $message.SiteID = 10002
  $message.SCSerialNumber = 23032307
  $message.Component = $component

  # Get type.
  $type = [Maxgaming.Cougar.Message.StartComponent]::PostOfficeFunction
 
  # Publish.
  $pomClient.Publish($type, $message.GetBytes(), 7) > $nul

  # Disconnect.
  $pomClient.Disconnect($true)
} 


################################################################# 
#    Connection to POM 
#################################################################

Write-Host "Connecting to POM" -ForegroundColor Yellow
$addresses = New-Object System.Collections.Generic.List`[string]

#Site
$addresses.Add("10.238.157.130")                     # Ip address of the site.
$pomClient = New-Object Maxgaming.Cougar.Interface.Connection.POMConnection                                              #creating a new POM connection

if ($pomClient.Connect("Restart", $addresses, 808, [Maxgaming.Cougar.Interface.Connection.ConnectionFlags].POMCF_VOLATILE) -eq $true)      # create a volatile queue  
{
    Write-Host "Connected to POM...`n" -ForegroundColor Green
    Write-Host "Sending a Restart Message" -ForegroundColor Yellow 
    SendStartComponentMessage("CSS")
    Write-Host ("The component has been restarted") -ForegroundColor Green
}

else
{
    Write-Host "Failed to connect to POM." -ForegroundColor Red
    return

}
# Cleanup.
$pomClient.Dispose()