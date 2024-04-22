function Output {
  param (
    $Text
  )
  
  Write-Host " [start-me-up] " -ForegroundColor Yellow -BackgroundColor DarkBlue -NoNewline
  Write-Host "$Text " -ForegroundColor Green -BackgroundColor DarkBlue 
}

function BlankLine {
  Write-Host ""
}

function Install {
  param (
    $PackageName
  )

  choco install $PackageName -y
}

# Preamble
Output "START ME UP"
Output "Jaguar's system provisioning script"
Output "WINDOWS VERSION"
BlankLine

# Install Chocolatey
Output "Installing Chocolatey package manager"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install 7zip
Output "Installing 7zip"
Install 7zip.install

# Slack
Output "Installing Slack"
Install slack

# Chrome
Output "Installing Google Chrome"
Install googlechrome

# Firefox
Output "Installing Firefox"
Install firefox

# Zoom
Output "Installing Zoom"
Install zoom

# Webex
Output "Installing Webex and Webex Meetings"
Install webex
Install webex-meetings

# Adobe Reader
Output "Installing Adobe Reader"
Install adobereader

# Office 365 Business
Output "Installing Office 365 Business"
Install office365business

# Install Adobe Creative Cloud
Output "Installing Adobe Creative Cloud"
Output "This process will fetch and install the Adobe Creative Cloud client. You will then need to login as an Adobe CC user and install Adobe apps via the client."
# fetch Windows alternative downloader:
"mkdir adobeccinstaller"
"cd adobeccinstaller"
Output "Fetching Adobe Creative Cloud install ZIP (this will take some time, please wait)"
Invoke-Webrequest -Uri https://ccmdl.adobe.com/AdobeProducts/KCCC/CCD/6_1_0_587_7/win64/ACCCx6_1_0_587_7.zip -OutFile adobecc.zip
Output "Unzipping Adobe Creative Cloud install ZIP with 7zip"
"C:\Program Files\7-Zip\7z.exe e ./adobecc.zip"
Output "Launching Adobe Creative Cloud installer"
".\Set-up.exe"

# return to original directory
cd ..

BlankLine
Output "start-me-up script complete!"
BlankLine
