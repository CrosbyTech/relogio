# Empacota roku/ em cronometro-roku.zip, pronto para o sideload.
#
#   powershell -ExecutionPolicy Bypass -File tools\gerar-zip.ps1
#
# Nao usa Compress-Archive de proposito: ele grava os caminhos internos com
# barra invertida, e o instalador do Roku so aceita barra normal.

Add-Type -AssemblyName System.IO.Compression | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$src = Join-Path $root 'roku'
$dest = Join-Path $root 'cronometro-roku.zip'

if (-not (Test-Path (Join-Path $src 'manifest'))) {
    throw "manifest nao encontrado em $src"
}
if (Test-Path $dest) { Remove-Item $dest -Force }

$zip = [System.IO.Compression.ZipFile]::Open($dest, 'Create')
try {
    Get-ChildItem -Path $src -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($src.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $rel) | Out-Null
        Write-Output "  + $rel"
    }
} finally {
    $zip.Dispose()
}

Write-Output ""
Write-Output "gerado: $dest"
