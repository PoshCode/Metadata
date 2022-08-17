#requires -Module @{ModuleName = "ModuleBuilder"; ModuleVersion = "2.0.0"}, Configuration
[CmdletBinding()]
param(
    # A specific folder to build into
    $OutputDirectory,

    # The version of the output module
    [Alias("ModuleVersion")]
    [string]$SemVer
)

# Sanitize parameters to pass to Build-Module
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot -StackName BuildTestStack

if (-not $Semver -and (Get-Command gitversion -ErrorAction Ignore)) {
    if ($semver = gitversion -showvariable NuGetVersion) {
        $null = $PSBoundParameters.Add("SemVer", $SemVer)
    }
}

try {
    Build-Module @PSBoundParameters -Target CleanBuild -Passthru
} finally {
    Pop-Location -StackName BuildTestStack
}