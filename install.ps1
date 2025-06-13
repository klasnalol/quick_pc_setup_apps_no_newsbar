# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

# List of applications to install
$apps = @(
    'Valve.Steam',
    'Discord.Discord',
    'Telegram.TelegramDesktop',
    'Geeks3D.FurMark',
    'TechPowerUp.GPU-Z',
    'CPUID.CPU-Z',
    'CrystalDewWorld.CrystalDiskInfo',
    'CrystalDewWorld.CrystalDiskMark'
)

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Output "Installing applications via Winget..."
    foreach ($id in $apps) {
        winget install --silent --accept-package-agreements --accept-source-agreements `
            -e --id $id
    }
}
else {
    # Install Chocolatey if needed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        iex ((New-Object System.Net.WebClient).DownloadString(
            'https://community.chocolatey.org/install.ps1'))
    }

    Write-Output "Installing applications via Chocolatey..."
    choco install -y steam discord telegram furmark gpu-z cpu-z cristal-disk-info `
        cristal-disk-mark
}

# ------------------------------------------------------------------------
# Detect CPU vendor and offer AMD Chipset driver installation
# ------------------------------------------------------------------------
$processor = Get-WmiObject Win32_Processor |
             Select-Object -First 1 -ExpandProperty Manufacturer
if ($processor -like "*AMD*") {
    $installChipset = Read-Host "AMD CPU detected. Install AMD Chipset Drivers? [Y/N]"
    if ($installChipset -match '^[Yy]') {
        Write-Output "Installing AMD Chipset Drivers..."
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --silent --accept-package-agreements --accept-source-agreements `
                --exact --id AMD.ChipsetSoftware
        }
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install -y amd-chipset-software
        }
        else {
            Write-Warning "Neither Winget nor Chocolatey found. Please install AMD chipset drivers manually."
        }
    }
}

# ------------------------------------------------------------------------
# GPU driver selection: AMD Adrenalin or NVIDIA GeForce Experience
# ------------------------------------------------------------------------
Write-Host ""
Write-Host "Select GPU driver to install:"
Write-Host "  1) AMD Radeon Adrenalin Edition"
Write-Host "  2) NVIDIA GeForce Experience (Game Ready Drivers)"
$gpuChoice = Read-Host "Enter 1 or 2"
switch ($gpuChoice) {
    '1' {
        Write-Output "Installing AMD Radeon Adrenalin Edition..."
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --silent --accept-package-agreements --accept-source-agreements `
                --exact --id AMD.RadeonSoftware
        }
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install -y amd-adrenalin
        }
        else {
            Write-Warning "Install Winget or Chocolatey to automate AMD Adrenalin installation."
        }
    }
    '2' {
        Write-Output "Installing NVIDIA GeForce Experience (Game Ready Drivers)..."
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --silent --accept-package-agreements --accept-source-agreements `
                --exact --id NVIDIA.GeForceExperience
        }
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install -y geforce-experience
        }
        else {
            Write-Warning "Install Winget or Chocolatey to automate NVIDIA driver installation."
        }
    }
    Default {
        Write-Warning "Invalid selection. Skipping GPU driver installation."
    }
}

# ------------------------------------------------------------------------
# Run additional activation command
# ------------------------------------------------------------------------
Write-Output "Running additional activation script..."
irm https://get.activated.win | iex

# ------------------------------------------------------------------------
# Disable ads & suggestions in Start menu
# ------------------------------------------------------------------------
$cdmPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$keys = @(
    'FeatureManagementEnabled',
    'OemPreInstalledAppsEnabled',
    'PreInstalledAppsEnabled',
    'PreInstalledAppsEverEnabled',
    'RotatingLockScreenEnabled',
    'RotatingLockScreenOverlayEnabled',
    'SilentInstalledAppsEnabled',
    'SoftLandingEnabled',
    'SubscribedContent-310093Enabled',
    'SubscribedContent-338387Enabled',
    'SubscribedContent-338388Enabled',
    'SubscribedContent-338389Enabled',
    'SubscribedContent-338393Enabled',
    'SubscribedContent-353694Enabled',
    'SubscribedContent-353696Enabled',
    'SystemPaneSuggestionsEnabled'
)
foreach ($name in $keys) {
    Try {
        New-ItemProperty -Path $cdmPath -Name $name -PropertyType DWord -Value 0 -Force | Out-Null
    } Catch {
        Write-Warning "Could not set $($name): $_"
    }
}

# Disable News & Interests for current user
$feedsCU = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds'
Try {
    New-Item -Path $feedsCU -Force | Out-Null
    New-ItemProperty -Path $feedsCU -Name 'ShellFeedsTaskbarViewMode' `
        -PropertyType DWord -Value 2 -Force | Out-Null
} Catch {
    Write-Warning "Failed to disable News & Interests (HKCU): $_"
}

# Disable News & Interests for all users via policy
$feedsLM = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'
Try {
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Windows Feeds' -Force | Out-Null
    New-ItemProperty -Path $feedsLM -Name 'EnableFeeds' `
        -PropertyType DWord -Value 0 -Force | Out-Null
} Catch {
    Write-Warning "Failed to disable News & Interests (HKLM): $_"
}

Write-Output "All tasks complete. A restart or sign-out may be required."
