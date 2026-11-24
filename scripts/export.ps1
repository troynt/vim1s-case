#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$OpenScadPath,
    [string]$OutputDirectory = 'stl',
    [ValidateSet('base', 'lid')][string[]]$Part = @('base', 'lid')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'OpenScad.ps1')
$root = Split-Path -Parent $PSScriptRoot
$executable = Resolve-OpenScad -Path $OpenScadPath
if (-not [IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $root $OutputDirectory
}
foreach ($item in $Part) {
    $arguments = @(
        '-D', ('part="{0}"' -f $item),
        '-D', 'show_pcb=false',
        '-D', 'show_heatsink=false',
        (Join-Path $root 'vim1s-case.scad')
    )
    Invoke-OpenScad -Executable $executable `
        -OutputPath (Join-Path $OutputDirectory ("vim1s-$item.stl")) `
        -Arguments $arguments
}
