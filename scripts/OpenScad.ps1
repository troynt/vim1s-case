#Requires -Version 7.0

function Resolve-OpenScad {
    param([string]$Path)

    if ($Path) {
        return (Get-Command -Name $Path -CommandType Application -ErrorAction Stop).Source
    }

    foreach ($name in @('openscad.com', 'openscad', 'openscad.exe')) {
        $command = Get-Command -Name $name -CommandType Application -ErrorAction SilentlyContinue
        if ($command) {
            return $command.Source
        }
    }

    if ($env:ProgramFiles) {
        $windowsPath = Join-Path $env:ProgramFiles 'OpenSCAD\openscad.com'
        if (Test-Path -LiteralPath $windowsPath -PathType Leaf) {
            return $windowsPath
        }
    }
    if ($IsMacOS) {
        $macPath = Join-Path '/Applications' 'OpenSCAD.app/Contents/MacOS/OpenSCAD'
        if (Test-Path -LiteralPath $macPath -PathType Leaf) {
            return $macPath
        }
    }

    throw 'OpenSCAD was not found. Install it or pass -OpenScadPath with its executable path.'
}

function Invoke-OpenScad {
    param(
        [Parameter(Mandatory)][string]$Executable,
        [Parameter(Mandatory)][string]$OutputPath,
        [Parameter(Mandatory)][string[]]$Arguments
    )

    $directory = Split-Path -Parent $OutputPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $temporary = Join-Path $directory (
        '.openscad-' + [guid]::NewGuid().ToString('N') + [IO.Path]::GetExtension($OutputPath)
    )
    try {
        & $Executable '-o' $temporary @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "OpenSCAD failed with exit code $LASTEXITCODE while generating $OutputPath."
        }
        if (-not (Test-Path -LiteralPath $temporary -PathType Leaf)) {
            throw "OpenSCAD did not create an output file for $OutputPath."
        }
        if ((Get-Item -LiteralPath $temporary).Length -eq 0) {
            throw "OpenSCAD produced an empty output file for $OutputPath."
        }
        Move-Item -LiteralPath $temporary -Destination $OutputPath -Force
        Write-Host "Generated $OutputPath"
    }
    finally {
        if (Test-Path -LiteralPath $temporary) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}
