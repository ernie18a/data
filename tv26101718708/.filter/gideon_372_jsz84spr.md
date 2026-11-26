# Gideon 372

- url: https://www.tradingview.com/script/JsZ84Spr-Gideon-372/
- type: indicator
- pine_id: PUB;e109a91921d341d8a10ee033bc8bdc72
- version: 1.0

## Description

ichinoku estrategia basado en 3 temporalidades y la nube es un sistema en backtesting

## Source Code

````pine
//@version=6
indicator("Ichimoku Pullback System", overlay=true)

TENKAN_LEN = 9
KIJUN_LEN = 26
SENKOU_LEN = 52
DISPLACEMENT = 26
USAR_NUBE_CLASICA = true
UMBRAL_NUBE_DELGADA = 0.3
VENTANA_PULLBACK = 3
VELAS_CAMBIO_RECIENTE = 5

mostrarHUD = input.bool(true, "Mostrar HUD")

donchian(len) => math.avg(ta.highest(len), ta.lowest(len))
tocaNivel(nivel) => low <= nivel and high >= nivel

calcularSesgoDiario() =>
    t = donchian(TENKAN_LEN)
    k = donchian(KIJUN_LEN)
    sA_actual = math.avg(t, k)
    sB_actual = donchian(SENKOU_LEN)
    sA_clasico = sA_actual[DISPLACEMENT]
    sB_clasico = sB_actual[DISPLACEMENT]
    sA = USAR_NUBE_CLASICA ? sA_clasico : sA_actual
    sB = USAR_NUBE_CLASICA ? sB_clasico : sB_actual
    tope = math.max(sA, sB)
    fondo = math.min(sA, sB)
    verde = sA > sB
    roja = sA < sB
    sobreNube = close > tope
    bajoNube = close < fondo
    enNube = close <= tope and close >= fondo
    grosor = math.abs(sA - sB)
    grosorProm = ta.sma(grosor, 20)
    delgada = grosor < grosorProm * UMBRAL_NUBE_DELGADA
    cambio = ta.barssince(verde != verde[1]) < VELAS_CAMBIO_RECIENTE
    esBuy = sobreNube and verde and not delgada and not cambio
    esSell = bajoNube and roja and not delgada and not cambio
    cambioABuy = esBuy and not esBuy[1]
    cambioASell = esSell and not esSell[1]
    categoria = esBuy ? 1 : esSell ? 2 : enNube ? 3 : delgada ? 4 : cambio ? 5 : 0
    [esBuy, esSell, categoria, cambioABuy, cambioASell]

[sesgoBuy, sesgoSell, categoriaSesgo, alertaSesgoBuy, alertaSesgoSell] = request.security(syminfo.tickerid, "D", calcularSesgoDiario(), lookahead=barmerge.lookahead_off)

calcularPullback4H() =>
    t4 = donchian(TENKAN_LEN)
    k4 = donchian(KIJUN_LEN)
    sA4_actual = math.avg(t4, k4)
    sB4_actual = donchian(SENKOU_LEN)
    sA4_clasico = sA4_actual[DISPLACEMENT]
    sB4_clasico = sB4_actual[DISPLACEMENT]
    sA4 = USAR_NUBE_CLASICA ? sA4_clasico : sA4_actual
    sB4 = USAR_NUBE_CLASICA ? sB4_clasico : sB4_actual
    bordeSuperior = math.max(sA4, sB4)
    bordeInferior = math.min(sA4, sB4)
    toqueTenkan = tocaNivel(t4)
    toqueBordeSup = tocaNivel(bordeSuperior)
    toqueBordeInf = tocaNivel(bordeInferior)
    toqueParaBuy = toqueTenkan or toqueBordeSup
    toqueParaSell = toqueTenkan or toqueBordeInf
    velasDesdeBuy = ta.barssince(toqueParaBuy)
    velasDesdeSell = ta.barssince(toqueParaSell)
    pullbackBuy = not na(velasDesdeBuy) and velasDesdeBuy <= VENTANA_PULLBACK - 1
    pullbackSell = not na(velasDesdeSell) and velasDesdeSell <= VENTANA_PULLBACK - 1
    [pullbackBuy, pullbackSell]

[pullbackBuyActivo, pullbackSellActivo] = request.security(syminfo.tickerid, "240", calcularPullback4H(), lookahead=barmerge.lookahead_off)

setupBuyArmado = sesgoBuy and pullbackBuyActivo
setupSellArmado = sesgoSell and pullbackSellActivo
setupActivo = setupBuyArmado or setupSellArmado

tenkanD = request.security(syminfo.tickerid, "D", donchian(TENKAN_LEN), lookahead=barmerge.lookahead_off)
kijunD = request.security(syminfo.tickerid, "D", donchian(KIJUN_LEN), lookahead=barmerge.lookahead_off)
senkouAD = request.security(syminfo.tickerid, "D", math.avg(donchian(TENKAN_LEN), donchian(KIJUN_LEN)), lookahead=barmerge.lookahead_off)
senkouBD = request.security(syminfo.tickerid, "D", donchian(SENKOU_LEN), lookahead=barmerge.lookahead_off)
tenkanH4 = request.security(syminfo.tickerid, "240", donchian(TENKAN_LEN), lookahead=barmerge.lookahead_off)
kijunH4 = request.security(syminfo.tickerid, "240", donchian(KIJUN_LEN), lookahead=barmerge.lookahead_off)
senkouAH4 = request.security(syminfo.tickerid, "240", math.avg(donchian(TENKAN_LEN), donchian(KIJUN_LEN)), lookahead=barmerge.lookahead_off)
senkouBH4 = request.security(syminfo.tickerid, "240", donchian(SENKOU_LEN), lookahead=barmerge.lookahead_off)

enDiario = timeframe.isdaily
en4H = timeframe.period == "240"

p1 = plot(enDiario ? senkouAD : na, "Senkou A 1D", color=color.new(color.green, 0), offset=DISPLACEMENT)
p2 = plot(enDiario ? senkouBD : na, "Senkou B 1D", color=color.new(color.red, 0), offset=DISPLACEMENT)
fill(p1, p2, color=senkouAD > senkouBD ? color.new(color.green, 85) : color.new(color.red, 85), title="Nube 1D")
plot(enDiario ? tenkanD : na, "Tenkan 1D", color=color.red, linewidth=1)
plot(enDiario ? kijunD : na, "Kijun 1D", color=color.blue, linewidth=1)

p3 = plot(en4H ? senkouAH4 : na, "Senkou A 4H", color=color.new(color.green, 0), offset=DISPLACEMENT)
p4 = plot(en4H ? senkouBH4 : na, "Senkou B 4H", color=color.new(color.red, 0), offset=DISPLACEMENT)
fill(p3, p4, color=senkouAH4 > senkouBH4 ? color.new(color.green, 85) : color.new(color.red, 85), title="Nube 4H")
plot(en4H ? tenkanH4 : na, "Tenkan 4H", color=color.red, linewidth=1)
plot(en4H ? kijunH4 : na, "Kijun 4H", color=color.blue, linewidth=1)

var table hud = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if mostrarHUD and barstate.islast
    textoSesgo = sesgoBuy ? "BUY" : sesgoSell ? "SELL" : "NO TRADE"
    colorSesgo = sesgoBuy ? color.green : sesgoSell ? color.red : color.gray
    razon = categoriaSesgo == 3 ? "precio en nube" : categoriaSesgo == 4 ? "nube delgada" : categoriaSesgo == 5 ? "nube cambio" : ""
    pullbackCoord = (sesgoBuy and pullbackBuyActivo) or (sesgoSell and pullbackSellActivo)
    textoPullback = pullbackCoord ? "ACTIVO" : "ESPERANDO"
    colorPullback = pullbackCoord ? color.green : color.gray
    textoSetup = setupActivo ? "ARMADO - bajar a 15M" : "---"
    colorSetup = setupActivo ? color.yellow : color.gray
    table.cell(hud, 0, 0, "PASO 1 (1D)", text_color=color.white, bgcolor=color.new(color.blue, 50), text_size=size.small)
    table.cell(hud, 1, 0, textoSesgo + (razon != "" ? " - " + razon : ""), text_color=color.white, bgcolor=color.new(colorSesgo, 30), text_size=size.small)
    table.cell(hud, 0, 1, "PASO 2 (4H)", text_color=color.white, bgcolor=color.new(color.blue, 50), text_size=size.small)
    table.cell(hud, 1, 1, textoPullback, text_color=color.white, bgcolor=color.new(colorPullback, 30), text_size=size.small)
    table.cell(hud, 0, 2, "SETUP", text_color=color.white, bgcolor=color.new(color.blue, 50), text_size=size.small)
    table.cell(hud, 1, 2, textoSetup, text_color=color.white, bgcolor=color.new(colorSetup, 30), text_size=size.small)
    table.cell(hud, 0, 3, "TF", text_color=color.gray, bgcolor=color.new(color.black, 80), text_size=size.tiny)
    table.cell(hud, 1, 3, timeframe.period, text_color=color.gray, bgcolor=color.new(color.black, 80), text_size=size.tiny)

plotshape(setupBuyArmado and not setupBuyArmado[1], "Setup BUY", shape.triangleup, location.belowbar, color.lime, size=size.small)
plotshape(setupSellArmado and not setupSellArmado[1], "Setup SELL", shape.triangledown, location.abovebar, color.red, size=size.small)
bgcolor(setupBuyArmado ? color.new(color.green, 92) : setupSellArmado ? color.new(color.red, 92) : na)

alertcondition(alertaSesgoBuy, "Sesgo BUY", "XAUUSD: Sesgo Daily cambio a BUY")
alertcondition(alertaSesgoSell, "Sesgo SELL", "XAUUSD: Sesgo Daily cambio a SELL")
alertcondition(setupBuyArmado and not setupBuyArmado[1], "Setup BUY", "XAUUSD: PASO 2 cumplido - bajar a 15M")
alertcondition(setupSellArmado and not setupSellArmado[1], "Setup SELL", "XAUUSD: PASO 2 cumplido - bajar a 15M")
````
