
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


function SendRefreshConfigMessage
{

  $message = New-Object Maxgaming.Cougar.Message.RefreshConfig
  Write-Host ($message)
  $message.SiteID = 10002

  # Get type.
  $type = [Maxgaming.Cougar.Message.RefreshConfig]::PostOfficeFunction
 
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
    Write-Host "Sending a RefreshConfig Message" -ForegroundColor Yellow 
    SendRefreshConfigMessage
    Write-Host ("The RefreshConfig Message has been sent") -ForegroundColor Green
}

else
{
    Write-Host "Failed to connect to POM." -ForegroundColor Red
    return

}
# Cleanup.
$pomClient.Dispose()