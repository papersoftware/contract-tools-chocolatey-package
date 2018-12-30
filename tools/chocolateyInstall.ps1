$ErrorActionPreference = 'Stop'

$packageArgs = @{
  softwareName   = 'Paper Software Contract Tools'
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = "https://papersoftware.s3.amazonaws.com/PaperSoftwareContractTools-$env:ChocolateyPackageVersion.msi"
  checksum       = '7b6dd6258a7a2b6b4ee47c25f4cd5ca1637422182795dc32b005ab2ceb97b269'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /noRestart'
  validExitCodes = 0, 1641, 3010 # https://docs.microsoft.com/en-us/windows/desktop/Msi/error-codes
}

# On systems with Word 2007, Contract Tools requires .NET Framework 3.5 and must
# be installed per-user.
$keyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\winword.exe'
$needsDotNet3_5 = $false
if ((Test-Path $keyPath) -and (Get-ItemProperty $keyPath Path).Path -match '(\d+)\\$' -and $Matches[1] -eq 12) {
  $needsDotNet3_5 = !(Test-Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5')
  $packageArgs.silentArgs += ' ALLUSERS=""'
}

Install-ChocolateyPackage @packageArgs

if ($needsDotNet3_5) {
  Write-Warning 'Contract Tools requires .NET Framework 3.5 on systems with Word 2007.'
  Write-Warning 'To install .NET Framework 3.5, run:'
  Write-Warning '  choco install dotnet3.5'
}
