sub init()
    ' a Scene vem com um fundo cinza padrao; zera para o preto da marca
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x020308FF"

    m.cltNums = [m.top.findNode("cltH"), m.top.findNode("cltM"), m.top.findNode("cltS")]
    m.loucosNums = [m.top.findNode("loucosH"), m.top.findNode("loucosM"), m.top.findNode("loucosS")]
    m.loucosSub = m.top.findNode("loucosSub")

    ' textos com quebra de linha nao cabem no atributo XML
    m.top.findNode("cltMsg").text = "CONTINUE FOCADO." + Chr(10) + "O MELHOR RESULTADO VEM DA DISCIPLINA."
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

    setCountdown(m.cltNums, secsUntil(nowSec, 18 * 3600))
    setCountdown(m.loucosNums, secsUntil(nowSec, 24 * 3600))

    tomorrow = CreateObject("roDateTime")
    tomorrow.FromSeconds(dt.AsSeconds() + 86400)
    m.loucosSub.text = "SAÍDA DOS LOUCOS — DIA " + pad(tomorrow.GetDayOfMonth())
end sub

' Sempre aponta para a proxima ocorrencia do horario: se ja passou hoje,
' conta para amanha. Mesma regra do getNextTarget() da versao web.
function secsUntil(nowSec as Integer, targetSec as Integer) as Integer
    diff = targetSec - nowSec
    if diff <= 0 then diff = diff + 86400
    return diff
end function

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
