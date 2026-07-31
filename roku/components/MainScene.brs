sub init()
    ' a Scene vem com um fundo cinza padrao; zera para o preto da marca
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x020308FF"

    m.cltNums = [m.top.findNode("cltH"), m.top.findNode("cltM"), m.top.findNode("cltS")]
    m.loucosNums = [m.top.findNode("loucosH"), m.top.findNode("loucosM"), m.top.findNode("loucosS")]
    m.loucosSub = m.top.findNode("loucosSub")
    m.cltMsg = m.top.findNode("cltMsg")
    m.cltBox = m.top.findNode("cltBox")

    ' -1 garante que a primeira chamada de setCltEstado sempre pinte a caixa
    m.cltEstado = -1

    ' texto com quebra de linha nao cabe no atributo XML
    m.top.findNode("loucosMsg").text = "FOCO ATÉ O ÚLTIMO SEGUNDO!"

    centerBrand()

    m.tick = m.top.findNode("tick")
    m.tick.observeField("fire", "onTick")
    m.tick.control = "start"
    onTick()
end sub

' A LayoutGroup se dimensiona pelos filhos, entao so da para centralizar
' depois de medir.
sub centerBrand()
    brand = m.top.findNode("brand")
    w = 0
    r = brand.boundingRect()
    if r <> invalid then w = r.width
    if w <= 0 then w = 200
    brand.translation = [(1280 - w) / 2, 26]
end sub

sub onTick()
    dt = CreateObject("roDateTime")
    dt.ToLocalTime()
    nowSec = dt.GetHours() * 3600 + dt.GetMinutes() * 60 + dt.GetSeconds()

    ' O CLT trava em zero das 18:00 ate a virada do dia, em vez de rolar para
    ' as 18:00 de amanha — senao o painel voltaria para 23:59:59 no instante
    ' em que a meta e batida.
    cltDiff = 64800 - nowSec
    if cltDiff < 0 then cltDiff = 0
    setCountdown(m.cltNums, cltDiff)
    setCltEstado(cltDiff)

    ' Os Loucos contam ate a meia-noite, que e a propria virada: chega a zero
    ' e recomeca em 24h no mesmo instante.
    setCountdown(m.loucosNums, 86400 - nowSec)

    tomorrow = CreateObject("roDateTime")
    tomorrow.FromSeconds(dt.AsSeconds() + 86400)
    m.loucosSub.text = "SAÍDA DOS LOUCOS — DIA " + pad(tomorrow.GetDayOfMonth())
end sub

sub setCltEstado(diff as Integer)
    estado = 0
    if diff <= 0 then estado = 1
    if m.cltEstado = estado then return
    m.cltEstado = estado

    if estado = 1
        m.cltMsg.text = "META BATIDA!" + Chr(10) + "TODOS EM CASA!"
        m.cltMsg.color = "0x7be8abFF"
        m.cltBox.color = "0x50dc8c1f"
    else
        m.cltMsg.text = "CONTINUE FOCADO." + Chr(10) + "O MELHOR RESULTADO VEM DA DISCIPLINA."
        m.cltMsg.color = "0x8fb8ffFF"
        m.cltBox.color = "0x4f9dff14"
    end if
end sub

sub setCountdown(labels as Object, diff as Integer)
    labels[0].text = pad(diff \ 3600)
    labels[1].text = pad((diff MOD 3600) \ 60)
    labels[2].text = pad(diff MOD 60)
end sub

function pad(n as Integer) as String
    s = n.ToStr()
    if Len(s) < 2 then s = "0" + s
    return s
end function
