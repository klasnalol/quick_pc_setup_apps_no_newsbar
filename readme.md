# README.md

## Overview

This repository contains a PowerShell script (`install.ps1`) and a wrapper batch file (`run-install.bat`) to automate the installation and configuration of common system utilities and drivers on Windows systems. The script uses [Winget](https://learn.microsoft.com/windows/package-manager/) or [Chocolatey](https://chocolatey.org/) to install applications, configures AMD chipset and GPU drivers, applies registry tweaks to disable ads and News & Interests, and runs an external activation script.

## Features

- Installs the following applications:
  - Steam
  - Discord
  - Telegram Desktop
  - FurMark
  - GPU-Z
  - CPU-Z
  - CrystalDiskInfo
  - CrystalDiskMark
- Detects AMD CPUs and offers to install AMD Chipset Drivers
- Provides a choice between AMD Radeon Adrenalin Edition or NVIDIA GeForce Experience GPU drivers
- Runs an external activation command (`irm https://get.activated.win | iex`)
- Disables Start menu ads and suggestions
- Disables Windows News & Interests for current and all users

## Prerequisites

- Windows 10/11
- Administrator privileges
- Internet access
- Optional: Winget or Chocolatey installed (the script will install Chocolatey if Winget is not available)

## Files

- **install.ps1**: Main PowerShell script performing all installations and configurations.
- **run-install.bat**: Batch wrapper to launch `install.ps1` with `-ExecutionPolicy Bypass` and `-NoProfile`.

## Usage

1. **Download the files**

   ```powershell
   C:\Users\<YourUser>\Downloads\install.ps1
   C:\Users\<YourUser>\Downloads\run-install.bat
   ```

2. **Unblock the script** (optional, if you wish to set a permanent policy):

   ```powershell
   Unblock-File -Path .\install.ps1
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```

3. **Run via batch file**

   - Right-click `run-install.bat` and select **Run as administrator**. The batch file will:
     - Switch to its own directory
     - Launch PowerShell with `-NoProfile -ExecutionPolicy Bypass`
     - Execute `install.ps1`
     - Pause for review of output

4. **Manual PowerShell launch** (alternative):

   ```bat
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\<YourUser>\Downloads\install.ps1"
   ```

## Script Flow

1. **Privilege check**: Ensures an Administrator session.
2. **Application installation**:
   - Uses Winget if available, else installs Chocolatey and uses it.
3. **AMD chipset driver detection**:
   - Prompts for installation if an AMD CPU is detected.
4. **GPU driver choice**:
   - Prompts to install either AMD Adrenalin or NVIDIA GeForce Experience.
5. **Activation script**:
   - Runs `irm https://get.activated.win | iex`.
6. **Registry tweaks**:
   - Disables various Start menu ads and suggestions.
   - Disables News & Interests for the current user and all users via policy.

## Customization

- **App list**: Edit the `$apps` array at the top of `install.ps1` to add or remove packages.
- **Registry keys**: Modify the `$keys` array under `ContentDeliveryManager` to change which suggestions are disabled.
- **Activation URL**: Change the `irm` URL if a different activation endpoint is required.

## Troubleshooting

- If the script fails to run, ensure you have Administrator rights and that execution policy bypass is applied.
- Check your internet connection and proxy settings if downloads hang.
- Review the console output for any `Write-Warning` or `Write-Error` messages.

## License

This script is provided "as-is" without warranty. Use at your own risk.

