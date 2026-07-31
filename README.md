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

TVs Roku não têm navegador. Para elas existe um canal nativo em `roku/`,
empacotado em `cronometro-roku.zip`. Instruções em [roku/README.md](roku/README.md).

## Deploy

Site estático, sem build. O `index.html` na raiz é servido direto pela Vercel.

```bash
vercel --prod
```
