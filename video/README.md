# Vídeo para pendrive

MP4 de 24h com a contagem regressiva, para TVs que tocam USB mas não têm
navegador. É a alternativa ao canal em [../roku](../roku) quando o modo
desenvolvedor não é uma opção.

## Gerar

```bash
powershell -ExecutionPolicy Bypass -File tools\gerar-video.ps1
```

Leva cerca de 48 min e sai em `video/cronometro-24h.mp4` (~170 MB).
Para conferir o layout antes, `-Teste` renderiza só os 2 primeiros minutos:

```bash
powershell -ExecutionPolicy Bypass -File tools\gerar-video.ps1 -Teste
```

Precisa do ffmpeg (`winget install Gyan.FFmpeg`).

## Usar na TV

1. Copie o MP4 para um pendrive (FAT32 ou exFAT)
2. Espete na TV e abra o **Roku Media Player**
3. Ligue o **repeat**
4. Dê play **exatamente à meia-noite**

## O passo 4 não é frescura

O vídeo não tem relógio — ele só toca quadros em ordem. O primeiro quadro é
`00:00:00` e o último é o segundo antes da meia-noite seguinte. Ele mostra a
hora certa apenas se tiver começado no instante certo.

Como dura exatamente 24h, no repeat ele volta ao início junto com a virada do
dia e se mantém sozinho. Mas qualquer interrupção quebra isso:

- queda de energia
- alguém desligar a TV
- alguém apertar pause

Depois de qualquer uma dessas, ele volta a tocar do zero em horário errado — e
continua parecendo que está funcionando. Não há como o vídeo perceber ou se
corrigir. Se o painel precisa estar certo, o canal Roku em [../roku](../roku)
é a opção que lê o relógio de verdade.

## Diferenças em relação à versão web

Reconstruído em ffmpeg, então não é pixel a pixel igual:

- **Fonte** — Bahnschrift (do Windows) no lugar de Oswald/Bebas Neue
- **Sem os ícones** SVG e sem os degradês dos números
- **Sem o "DIA XX"** no subtítulo dos Loucos — o número mudaria todo dia, e o
  vídeo é fixo

## Como é montado

Duas etapas, em `tools/gerar-video.ps1`:

1. `fundo-filtro.txt` desenha tudo que não muda num PNG único
2. `numeros-filtro.txt` escreve só os 6 grupos de dígitos por cima, calculados
   por expressão a partir do número do quadro — sem gerar 86.400 imagens

Os dígitos saem de expressões sobre `n` (número do quadro = segundo do dia).
Para o CLT, `((151200-n)-86400*floor((151200-n)/86400))` é o resto de
`64800-n` em 24h, ou seja: se as 18:00 já passaram, conta para o dia seguinte.
Está escrito sem `mod()` de propósito — vírgula dentro de expressão exigiria
mais uma camada de escape no filtergraph.
