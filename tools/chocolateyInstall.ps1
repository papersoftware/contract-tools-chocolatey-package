$ErrorActionPreference = 'Stop'

$packageArgs = @{
  softwareName   = 'Paper Software Contract Tools'
  packageName    = $Env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = 'https://papersoftware.s3.amazonaws.com/PaperSoftwareContractTools-1.37.5.0.msi'
  checksum       = 'b8ce39a33e8f074864189e6508c95bf8f3725912ca0f5daf4b66117f99ff1f4b'
  checksumType   = 'sha256'
  silentArgs     = '/quiet /noRestart'
  validExitCodes = 0, 1641, 3010 # https://learn.microsoft.com/en-us/windows/win32/msi/error-codes
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
