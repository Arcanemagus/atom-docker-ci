Param(
  [Parameter(Position=0, Mandatory=1,
    HelpMessage="Enter a valid version number vX.Y.Z[-betaN].")]
  [ValidatePattern('^v\d+\.\d+\.\d+(-beta\d+)?$')]
  [String]
  $version = ""
)

Function Exec
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=1)]
        [scriptblock]$Command,
        [Parameter(Position=1, Mandatory=0)]
        [string]$ErrorMessage = "Execution of command failed.`n$Command"
    )
    & $Command
    if ($LastExitCode -ne 0) {
        throw "Exec: $ErrorMessage"
    }
}

Function Get-IsBeta
{
  If ($version -match '^v\d+\.\d+.\d+$')
  {
    Return $FALSE
  }
  Return $TRUE
}

Function Get-ScriptName
{
  [CmdletBinding()]
  [OutputType([string])]
  Param
  (
    # Param1 Script name
    [Parameter(Mandatory=1, Position=0)]
    [string]$Script
  )
  If (Get-IsBeta)
  {
    Return "$Script-beta"
  }
  Return $Script
}

Filter NewVersion
{
  $_ -replace 'ENV ATOM_VERSION=.+ ATOM_SCRIPT_PATH=.+ APM_SCRIPT_PATH=.+',
    ("ENV ATOM_VERSION=$version " +
    "ATOM_SCRIPT_PATH=" + (Get-ScriptName('atom')) + " " +
    "APM_SCRIPT_PATH=" + (Get-ScriptName('apm')))
}

$currentDirectory = (Resolve-Path .\).Path
$dockerfilePath = Join-Path -Path $currentDirectory -ChildPath "Dockerfile"

$content = [System.IO.File]::ReadAllText($dockerfilePath)
$newContent = ($content | NewVersion)
[System.IO.File]::WriteAllText($dockerfilePath, $newContent)
Exec { git add "Dockerfile" }
Exec { git commit --message="Atom $version" }
Exec { git tag --sign --message="$version" "$version" }
Exec { git push --follow-tags }
