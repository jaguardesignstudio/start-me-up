# Start Me Up

![](http://i.imgur.com/ubdJQL7.jpg)

Because bootstrapping a new development machine can make a grown man (or woman) cry.

More than a little bit inspired by Thoughtbot's [Laptop](https://github.com/thoughtbot/laptop/) scripts, but opinionated for our use.

## Notes

This script works with Mac OS 10.9+ and Windows 10+.

Ubuntu support has not been tested in forever and needs to be checked and updated.

## Instructions

Run the following command from the command line for MacOS/Ubuntu:

```bash
bash <(curl -s https://raw.githubusercontent.com/jaguardesign/start-me-up/master/start.sh)
```

For the Windows version, open a PowerShell window as Administrator, and run:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jaguardesignstudio/start-me-up/master/install-windows.ps1'))
```

## What It Installs

See the [Brewfile](https://github.com/jaguardesignstudio/start-me-up/blob/master/Brewfile) for the list of applications installed.
