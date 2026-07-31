# relogio

Cronômetro CROSBY — página estática com dois contadores regressivos:

- **Horário do CLT** — conta até as 18:00
- **Horário dos Loucos** — conta até a meia-noite

## Páginas

| Arquivo | Uso |
|---|---|
| `index.html` | Vertical (540×1040) — celular, totem |
| `horizontal.html` | Horizontal (1920×1080) — TV, monitor |

## TV Roku

TVs Roku não têm navegador. Duas saídas:

| Caminho | Onde | Contagem |
|---|---|---|
| [roku/](roku/README.md) — canal nativo, sideload do `cronometro-roku.zip` | modo desenvolvedor | lê o relógio da TV, sempre certa |
| [video/](video/README.md) — MP4 de 24h no pendrive | Roku Media Player | só se o play for à meia-noite |

O canal é a opção correta; o vídeo é o plano B para quando o modo
desenvolvedor não estiver disponível.

## Deploy

Site estático, sem build. O `index.html` na raiz é servido direto pela Vercel.

```bash
vercel --prod
```
