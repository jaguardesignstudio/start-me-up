function Output {
  param (
    $Text
  )
  
  Write-Host " [start-me-up] " -ForegroundColor Yellow -BackgroundColor DarkBlue -NoNewline
  Write-Host "$Text " -ForegroundColor Green -BackgroundColor DarkBlue 
}

# Install Chocolatey
Output "Installing Chocolatey package manager"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install 7zip
Output "Installing 7zip"
choco install 7zip.install -y

# Slack
Output "Installing Slack"
choco install slack

# Chrome
Output "Installing Google Chrome"
choco install googlechrome

# Firefox
Output "Installing Firefox"
choco install firefox

# Zoom
Output "Installing Zoom"
choco install zoom

# Webex
Output "Installing Webex and Webex Meetings"
choco install webex
choco install webex-meetings

# Adobe Reader
Output "Installing Adobe Reader"
choco install adobereader

# Office 365 Business
Output "Installing Office 365 Business"
choco install office365business

# Install Adobe Creative Cloud
Output "Installing Adobe Creative Cloud"
Output "This process will fetch and install the Adobe Creative Cloud client. You will then need to login as an Adobe CC user and install Adobe apps via the client."
# fetch Windows alternative downloader:
mkdir adobeccinstaller
cd adobeccinstaller
Output "Fetching Adobe Creative Cloud install ZIP (this will take some time, please wait)"
Invoke-Webrequest -Uri https://ccmdl.adobe.com/AdobeProducts/KCCC/CCD/6_1_0_587_7/win64/ACCCx6_1_0_587_7.zip -OutFile adobecc.zip
Output "Unzipping Adobe Creative Cloud install ZIP with 7zip"
"C:\Program Files\7-Zip\7z.exe" e ./adobecc.zip
Output "Launching Adobe Creative Cloud installer"
.\Set-up.exe

# return to original directory
cd ..

Output "start-me-up script complete!"
