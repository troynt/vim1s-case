#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$OpenScadPath,
    [string]$OutputDirectory,
    [switch]$ShowPcb
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'OpenScad.ps1')
$root = Split-Path -Parent $PSScriptRoot
$executable = Resolve-OpenScad -Path $OpenScadPath
$source = Join-Path $root 'vim1s-case.scad'

if ($ShowPcb -and -not (Test-Path -LiteralPath (Join-Path $root 'pcb.stl') -PathType Leaf)) {
    throw 'PCB preview requires your own pcb.stl next to vim1s-case.scad; this model is not distributed.'
}
if (-not $OutputDirectory) {
    $OutputDirectory = if ($ShowPcb) { 'renders-local' } else { 'renders' }
}
if (-not [IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $root $OutputDirectory
}

$views = [ordered]@{
    'assembled' = @('assembled', '0,0,0,60,0,215,140')
    'front' = @('assembled', '0,0,0,90,0,180,140')
    'rear-buttons' = @('assembled', '0,0,0,60,0,30,140')
    'layout' = @('layout', '0,0,0,40,0,25,220')
    'exploded' = @('exploded', '0,0,0,60,0,215,170')
    'heatsink-open' = @('open', '0,0,0,60,0,215,140')
    'heatsink-exploded' = @('exploded', '0,0,0,60,0,215,170')
    'lid-inner-ring' = @('lid', '0,0,0,45,0,215,140')
}
$pcbValue = if ($ShowPcb) { 'true' } else { 'false' }
foreach ($view in $views.GetEnumerator()) {
    $heatsinkValue = if ($view.Key -in @('heatsink-open', 'heatsink-exploded')) { 'true' } else { 'false' }
    $arguments = @(
        '-D', ('part="{0}"' -f $view.Value[0]),
        '-D', "show_pcb=$pcbValue",
        '-D', "show_heatsink=$heatsinkValue",
        '--imgsize=1600,1200',
        '--viewall',
        '--autocenter',
        ('--camera=' + $view.Value[1]),
        '--colorscheme=Tomorrow',
        $source
    )
    Invoke-OpenScad -Executable $executable `
        -OutputPath (Join-Path $OutputDirectory ('vim1s-' + $view.Key + '.png')) `
        -Arguments $arguments
}
