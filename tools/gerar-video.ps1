# Gera o MP4 de 24h do cronometro para tocar via pendrive.
#
#   powershell -ExecutionPolicy Bypass -File tools\gerar-video.ps1 -Teste
#   powershell -ExecutionPolicy Bypass -File tools\gerar-video.ps1
#
# -Teste renderiza so os 120 primeiros segundos, para conferir o layout antes
# de encarar o encode completo.
#
# O video comeca em 00:00:00 e dura exatamente 24h, entao em repeat ele volta
# ao inicio no mesmo instante em que vira o dia — desde que tenha sido iniciado
# a meia-noite.

param(
    [switch]$Teste
)

$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$dir = Join-Path $root 'video'
$fundo = Join-Path $dir 'fundo.png'
$saida = if ($Teste) { Join-Path $dir 'teste.mp4' } else { Join-Path $dir 'cronometro-24h.mp4' }
$duracao = if ($Teste) { 120 } else { 86400 }

$ffmpeg = (Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages') `
        -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (-not $ffmpeg) { $ffmpeg = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source }
if (-not $ffmpeg) { throw 'ffmpeg nao encontrado. Instale com: winget install Gyan.FFmpeg' }

# O parser de filtergraph do ffmpeg nao aceita quebra de linha; os arquivos sao
# multilinha so para ficarem legiveis, entao viram uma linha so aqui.
function Get-Filtro([string]$arquivo) {
    # -Encoding UTF8 e obrigatorio: o Get-Content do PS 5.1 assume ANSI e
    # destroi os acentos dos textos.
    $linhas = Get-Content (Join-Path $dir $arquivo) -Encoding UTF8 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    return ($linhas -join '')
}

Write-Output "ffmpeg: $ffmpeg"
Write-Output ''
Write-Output '[1/2] fundo estatico'

& $ffmpeg -hide_banner -loglevel error -y `
    -f lavfi -i "color=c=0x020308:s=1920x1080" `
    -vf (Get-Filtro 'fundo-filtro.txt') `
    -frames:v 1 $fundo
if ($LASTEXITCODE -ne 0) { throw "falha ao gerar o fundo (exit $LASTEXITCODE)" }
Write-Output "      $fundo"

Write-Output ''
Write-Output "[2/2] video ($duracao s)"

# Um quadro por segundo: e a taxa em que o conteudo realmente muda, e subir
# para 30 fps multiplicaria o encode por ~15x sem ganho visual nenhum.
#
# A ordem do filtro importa muito:
#   format=yuv420p  antes do loop -> a conversao de cor roda 1 vez, nao 86400
#   loop            repete o quadro ja decodificado, sem reabrir o PNG
# So isso corta o tempo total pela metade.
$filtro = 'format=yuv420p,loop=loop=-1:size=1:start=0,' + (Get-Filtro 'numeros-filtro.txt')

& $ffmpeg -hide_banner -loglevel error -stats -y `
    -framerate 1 -i $fundo `
    -t $duracao `
    -vf $filtro `
    -r 1 `
    -c:v libx264 -preset veryfast -crf 25 `
    -profile:v high -level:v 4.0 -g 60 -movflags +faststart `
    $saida
if ($LASTEXITCODE -ne 0) { throw "falha ao gerar o video (exit $LASTEXITCODE)" }

$mb = [math]::Round((Get-Item $saida).Length / 1MB, 1)
Write-Output ''
Write-Output "gerado: $saida  ($mb MB)"
