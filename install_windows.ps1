param(
    [Parameter(Position = 0)]
    [string]$GameRoot
)

$ErrorActionPreference = "Stop"
$PackageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PayloadRoot = Join-Path $PackageRoot "payload"
$FileList = Join-Path $PackageRoot "FILES.txt"
$HashList = Join-Path $PackageRoot "SHA256SUMS.txt"

function Test-GameRoot([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return (Test-Path -LiteralPath (Join-Path $Path "Binaries\Win64\UDK.exe") -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $Path "UDKGame\CookedPC") -PathType Container)
}

function Normalize-GameRoot([string]$Path) {
    $value = [Environment]::ExpandEnvironmentVariables($Path.Trim().Trim('"'))
    $value = [IO.Path]::GetFullPath($value)
    if ((Split-Path -Leaf $value) -ieq "UDKGame") {
        $value = Split-Path -Parent $value
    }
    return $value
}

try {
    if ([string]::IsNullOrWhiteSpace($GameRoot) -and (Test-GameRoot (Get-Location).Path)) {
        $GameRoot = (Get-Location).Path
    }

    if ([string]::IsNullOrWhiteSpace($GameRoot)) {
        $candidates = @(
            (Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common\Renegade X"),
            (Join-Path $env:ProgramFiles "Steam\steamapps\common\Renegade X")
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        $GameRoot = $candidates | Where-Object { Test-GameRoot $_ } | Select-Object -First 1
    }

    if ([string]::IsNullOrWhiteSpace($GameRoot)) {
        $GameRoot = Read-Host "Enter the Renegade X game folder (the folder containing Binaries and UDKGame)"
    }
    $GameRoot = Normalize-GameRoot $GameRoot
    if (-not (Test-GameRoot $GameRoot)) {
        throw "Not a Renegade X game folder: $GameRoot"
    }

    $expectedHashes = @{}
    foreach ($line in Get-Content -LiteralPath $HashList -Encoding UTF8) {
        if ($line -match '^([0-9a-fA-F]{64})  payload/(.+)$') {
            $expectedHashes[$Matches[2]] = $Matches[1].ToLowerInvariant()
        }
    }

    $files = Get-Content -LiteralPath $FileList -Encoding UTF8 | Where-Object { $_.Trim() -ne "" }
    foreach ($rel in $files) {
        $packagePath = Join-Path $PayloadRoot ($rel.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) {
            throw "Package file is missing: $rel"
        }
        $actual = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if (-not $expectedHashes.ContainsKey($rel) -or $actual -ne $expectedHashes[$rel]) {
            throw "Package checksum failed: $rel"
        }
    }

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupRoot = Join-Path $GameRoot "Chinese_Localization_Backup_$stamp"
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

    foreach ($rel in $files) {
        $nativeRel = $rel.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $source = Join-Path $PayloadRoot $nativeRel
        $destination = Join-Path $GameRoot $nativeRel
        $backup = Join-Path $backupRoot $nativeRel
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            Copy-Item -LiteralPath $destination -Destination $backup -Force
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    Write-Host ""
    Write-Host "Installation complete."
    Write-Host "Game folder: $GameRoot"
    Write-Host "Original-file backup: $backupRoot"
    Write-Host "Add this launch option: -language=chn"
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
