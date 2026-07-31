# Canal Roku — CROSBY Cronômetro

App nativo Roku (BrightScript/SceneGraph) com a mesma contagem da versão web.
Serve para TVs Roku, que não têm navegador nem permitem instalar um.

O arquivo pronto para instalar é o **`cronometro-roku.zip`** na raiz do projeto.

## Instalação na TV

### 1. Ligar o modo desenvolvedor

No controle da TV, aperte nesta ordem:

**Home ×3 · Cima ×2 · Direita · Esquerda · Direita · Esquerda · Direita**

Abre a tela *Developer Settings*. Escolha **Enable installer and restart**,
aceite a licença e defina uma senha (anote — vai usar no passo 3).
A TV reinicia e mostra o **IP** dela.

### 2. Confirmar o IP

Se não anotou: **Ajustes › Rede › Sobre**. A TV precisa estar na mesma rede
que o computador.

### 3. Enviar o zip

No navegador do computador, abra `http://IP-DA-TV`.

- Usuário: `rokudev`
- Senha: a que você definiu

Em **Upload**, escolha `cronometro-roku.zip` e clique em **Install**.
O cronômetro abre na hora, e o canal fica na tela inicial como
**CROSBY Cronometro**.

## Deixar ligado o dia todo

Dois ajustes da TV, senão ela apaga a tela sozinha:

| Onde | O quê |
|---|---|
| Ajustes › Proteção de tela | Desativar (ou tempo *Nunca*) |
| Ajustes › Sistema › Energia › Desligamento automático | Desativar |

## Rebuild

Depois de mexer no código:

```bash
powershell -ExecutionPolicy Bypass -File tools\gerar-zip.ps1
```

Os PNGs de ícone/splash já estão versionados; só precisa rodar
`node tools/gerar-icones.js` se quiser regerá-los.

## Diferenças em relação à versão web

O Roku não renderiza HTML/CSS, então o layout foi reconstruído em SceneGraph:

- **Fontes** — a fonte do sistema Roku, no lugar de Oswald/Bebas Neue
- **Ícones** — os SVGs (capacete, raio, maleta, troféu) foram omitidos, o
  SceneGraph não renderiza SVG
- **Gradientes** — os números são de cor sólida, sem o degradê branco→cinza

O resto — layout em duas colunas, cores, textos e a regra de contagem — é igual.

## Observações

- O canal fica instalado após reiniciar a TV. Some se você desligar o modo
  desenvolvedor ou resetar a TV de fábrica.
- O horário vem do relógio da TV. Se o fuso estiver errado nos ajustes, a
  contagem sai errada.
