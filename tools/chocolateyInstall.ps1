$ErrorActionPreference = 'Stop'

$packageArgs = @{
  softwareName   = 'Paper Software Contract Tools'
  packageName    = $Env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = "https://papersoftware.s3.amazonaws.com/PaperSoftwareContractTools-$Env:ChocolateyPackageVersion.msi"
  checksum       = '8f7de3bad182a4ac1267bea9bb331025f312cd9ba5afa0fd2c15506c67d146ab'
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
