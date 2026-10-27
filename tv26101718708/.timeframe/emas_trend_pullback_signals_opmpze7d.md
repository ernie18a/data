# EMAs + Trend Pullback Signals

- url: https://www.tradingview.com/script/oPMPZE7d-EMAs-Trend-Pullback-Signals/
- type: indicator
- pine_id: PUB;c971c185a25b43d49d5f661aa1b6890d
- version: 7.0

## Description

Indicator based on double-MACD pullback and EMA trends.

## Source Code

````pine
//@version=6
indicator(title="EMAs Trend", shorttitle="EMAs", precision=8, overlay=true)

// ============================================================
// EMAs (degradê azul: clara → escura conforme aumenta o período)
// ============================================================
lineWidthShort = input.int(1, minval=1, title="Espessura EMAs curtas (13, 21, 34, 50)")
lineWidthLong  = input.int(2, minval=1, title="Espessura EMAs longas (100, 200)")
src            = input.source(close, title="Source")

ema13  = ta.ema(src, 13)
ema21  = ta.ema(src, 21)
ema34  = ta.ema(src, 34)
ema50  = ta.ema(src, 50)
ema100 = ta.ema(src, 100)
ema200 = ta.ema(src, 200)

plot(ema13,  color=#d2e1ff, title="EMA 13",  linewidth=lineWidthShort, display=display.pane)
plot(ema21,  color=#98bdff, title="EMA 21",  linewidth=lineWidthShort, display=display.pane)
plot(ema34,  color=#1b4aff, title="EMA 34",  linewidth=lineWidthShort, display=display.pane)
plot(ema50,  color=#1138cd, title="EMA 50",  linewidth=lineWidthShort, display=display.pane)
p100 = plot(ema100, color=#0D47A1, title="EMA 100", linewidth=lineWidthLong, display=display.pane)
p200 = plot(ema200, color=#0D47A1, title="EMA 200", linewidth=lineWidthLong, style=plot.style_stepline, display=display.pane)

// Nuvem entre EMA 100 e 200: verde quando 100 > 200 (alta), vermelha quando 100 < 200 (baixa)
cloudColor = ema100 > ema200 ? color.new(#26A69A, 80) : color.new(#EF5350, 80)
fill(p100, p200, color=cloudColor, title="Nuvem de Tendência")


// ============================================================
// ESTRATÉGIA: PULLBACK COM CONFIRMAÇÃO DO MACD
// ============================================================
grpStrat = "── Estratégia de Sinais ──"

showSignals  = input.bool(true, title="Mostrar setas de compra/venda", group=grpStrat)
windowBars   = input.int(10, minval=1, title="Janela do 2º sinal (barras)", group=grpStrat)
minSpacing   = input.int(3, minval=1, title="Distância mínima entre 1º e 2º sinal (barras)", group=grpStrat,
                         tooltip="Ex: 3 = o 2º sinal só conta a partir da 3ª barra após o 1º (elimina ruído de sinais colados)")
signalCooldown = input.int(10, minval=0, title="Cooldown entre setas da mesma direção (barras)", group=grpStrat,
                           tooltip="Após uma seta BUY, a próxima BUY só pode aparecer N barras depois. Mesmo pra SELL. 0 = sem cooldown.")

// Filtro adicional: estrutura das EMAs curtas
grpShort      = "── Filtro EMAs Curtas ──"
minZoneATR    = input.float(0, minval=0.0, step=0.05, title="Distância mínima da zona (em ATR)", group=grpShort,
                            tooltip="Altura da zona EMA13-EMA50 em múltiplos de ATR. Maior = exige EMAs mais espalhadas (rejeita lateralização). 0 = sem filtro.")
atrLen        = input.int(14, minval=1, title="Período ATR (filtro)", group=grpShort)
requirePosOk  = input.bool(true, title="Exigir EMAs curtas dentro/acima da nuvem (long) ou dentro/abaixo (short)", group=grpShort,
                           tooltip="Em LONG: a menor EMA curta (mín das 4) deve estar acima da EMA 200. Em SHORT: a maior EMA curta deve estar abaixo da EMA 200. Evita sinais com curtas separadas das longas.")

// Filtro adicional: distância das EMAs longas (mede força da tendência)
grpLong       = "── Filtro EMAs Longas ──"
minLongATR    = input.float(0.5, minval=0.0, step=0.05, title="Distância mínima EMA100-EMA200 (em ATR)", group=grpLong,
                            tooltip="|EMA100 - EMA200| em múltiplos de ATR. Maior = exige tendência mais forte (EMAs longas mais separadas). 0 = sem filtro.")

// Filtro adicional: tendência num timeframe maior (HTF)
grpHtf        = "── Filtro Tendência HTF ──"
useHtfTrend   = input.bool(false, title="Exigir tendência confirmada em timeframe maior", group=grpHtf,
                           tooltip="Quando ON: o sinal só dispara se EMA100 estiver acima/abaixo da EMA200 também no timeframe configurado. Útil pra evitar pullbacks 5min contra a tendência maior.")
htfTimeframe  = input.timeframe("15", title="Timeframe maior", group=grpHtf,
                                tooltip="Padrão 15min. Pode mudar pra 30, 60 (1h), 240 (4h), etc.")

// Calcula EMA100 e EMA200 no timeframe maior (request.security)
htfEma100 = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, 100), lookahead=barmerge.lookahead_off)
htfEma200 = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, 200), lookahead=barmerge.lookahead_off)

// Tendência HTF: simplesmente EMA100 acima/abaixo da EMA200
htfTrendUp   = htfEma100 > htfEma200
htfTrendDown = htfEma100 < htfEma200

htfOKLong  = not useHtfTrend or htfTrendUp
htfOKShort = not useHtfTrend or htfTrendDown

// Zona das EMAs curtas (13, 21, 34, 50)
emaShortMax = math.max(math.max(ema13, ema21), math.max(ema34, ema50))
emaShortMin = math.min(math.min(ema13, ema21), math.min(ema34, ema50))

// MACD (24, 52, 18) — config dobrada do padrão
macdFast        = input.int(24, title="MACD Fast",   group=grpStrat)
macdSlow        = input.int(52, title="MACD Slow",   group=grpStrat)
macdSignal      = input.int(18, title="MACD Signal", group=grpStrat)
requireMacdTurn = input.bool(true, title="MACD precisa estar virando?", group=grpStrat,
                             tooltip="SIM (padrão): histograma contra-tendência E barra encurtando rumo ao zero. NÃO: basta o histograma estar do lado contrário, sem exigir virada.")

[macdLine, signalLine, hist] = ta.macd(close, macdFast, macdSlow, macdSignal)

// Stoch RSI (filtro adicional)
grpStoch       = "── Filtro Stoch RSI ──"
useStochRsi    = input.bool(false, title="Ativar filtro Stoch RSI", group=grpStoch,
                            tooltip="Quando ON: o sinal só dispara se K cruzou D na direção do trade na barra atual.")
stochRsiLen    = input.int(14, minval=1, title="Stoch length", group=grpStoch)
stochRsiRsiLen = input.int(14, minval=1, title="RSI length", group=grpStoch)
stochRsiK      = input.int(3,  minval=1, title="K smoothing", group=grpStoch)
stochRsiD      = input.int(3,  minval=1, title="D smoothing", group=grpStoch)
stochRsiZone   = input.bool(false, title="Exigir cruzamento em zona extrema", group=grpStoch,
                            tooltip="ON: cruzamento de K só conta se K < OS p/ long ou K > OB p/ short. OFF: qualquer cruzamento vale.")
stochRsiOS     = input.int(20, minval=0, maxval=50, title="Zona oversold (long)", group=grpStoch)
stochRsiOB     = input.int(80, minval=50, maxval=100, title="Zona overbought (short)", group=grpStoch)
stochLookback  = input.int(10, minval=1, title="Cruzamento ocorreu nas últimas N barras", group=grpStoch,
                           tooltip="Conta o cruzamento se ele aconteceu em qualquer das últimas N barras (incluindo a atual). 1 = só conta na barra atual.")

// Cálculo do Stoch RSI
rsi1 = ta.rsi(close, stochRsiRsiLen)
stochRsiK_val = ta.sma(ta.stoch(rsi1, rsi1, rsi1, stochRsiLen), stochRsiK)
stochRsiD_val = ta.sma(stochRsiK_val, stochRsiD)

// Cruzamento de K e D — agora considerando lookback de N barras
stochCrossUpRecent   = ta.barssince(ta.crossover(stochRsiK_val,  stochRsiD_val)) < stochLookback
stochCrossDownRecent = ta.barssince(ta.crossunder(stochRsiK_val, stochRsiD_val)) < stochLookback

// Filtro final: se ativo, exige cruzamento recente; opcionalmente em zona extrema
stochOKLong  = not useStochRsi or (stochCrossUpRecent   and (not stochRsiZone or stochRsiK_val < stochRsiOS))
stochOKShort = not useStochRsi or (stochCrossDownRecent and (not stochRsiZone or stochRsiK_val > stochRsiOB))

// Filtro de tendência: EMA100 e EMA200 inclinando juntas + alinhamento
slopeUp100   = ema100 > ema100[1]
slopeUp200   = ema200 > ema200[1]
slopeDown100 = ema100 < ema100[1]
slopeDown200 = ema200 < ema200[1]

trendUp   = slopeUp100   and slopeUp200   and ema100 > ema200
trendDown = slopeDown100 and slopeDown200 and ema100 < ema200

// Bounce: pavio cruza a zona das EMAs curtas, corpo fecha na direção da trend
bounceLookback = input.int(1, minval=1, title="Bounce ocorreu nas últimas N barras", group=grpStrat,
                           tooltip="Conta o bounce se ele aconteceu em qualquer das últimas N barras (incluindo a atual). 1 = só conta na barra atual (clássico).")

requireEma50Touch = input.bool(false, title="Exigir toque na EMA 50 (pullback profundo)", group=grpStrat,
                               tooltip="Quando ON: além do bounce, exige que o pavio (low em long, high em short) tenha tocado/cruzado a EMA 50 em alguma das últimas N barras.")
ema50TouchBars    = input.int(10, minval=1, title="Toque na EMA 50 nas últimas N barras", group=grpStrat,
                              tooltip="Janela de barras (incluindo a atual) onde o pavio precisa ter tocado a EMA 50 para validar o pullback profundo.")

// Bounce: a vela atravessa a zona das EMAs curtas
// Long: abre abaixo da zona, fecha acima (vela atravessou as curtas pra cima)
// Short: abre acima da zona, fecha abaixo
bounceLongBar  = open < emaShortMax and close > emaShortMax and close > open
bounceShortBar = open > emaShortMin and close < emaShortMin and close < open

// Toque na EMA 50: pavio cruzou ou tocou a EMA 50
ema50TouchLongBar  = low  <= ema50
ema50TouchShortBar = high >= ema50

ema50TouchedLong  = not requireEma50Touch or ta.barssince(ema50TouchLongBar)  < ema50TouchBars
ema50TouchedShort = not requireEma50Touch or ta.barssince(ema50TouchShortBar) < ema50TouchBars

bounceLong  = ta.barssince(bounceLongBar)  < bounceLookback and ema50TouchedLong
bounceShort = ta.barssince(bounceShortBar) < bounceLookback and ema50TouchedShort

// MACD contra-tendência
// Se requireMacdTurn=true: exige histograma virando (encurtando rumo a 0)
// Se requireMacdTurn=false: basta estar contra-tendência (lado oposto à direção)
macdTriggerLong  = requireMacdTurn ? (hist < 0 and hist > hist[1]) : (hist < 0)
macdTriggerShort = requireMacdTurn ? (hist > 0 and hist < hist[1]) : (hist > 0)

// ────────────────────────────────────────────────────────────
// FILTROS DAS EMAs CURTAS
// ────────────────────────────────────────────────────────────
atrVal = ta.atr(atrLen)

// Filtro 1 — Distância: altura da zona em múltiplos de ATR (rejeita lateralização)
zoneHeight = emaShortMax - emaShortMin
zoneOK     = minZoneATR == 0 or zoneHeight >= atrVal * minZoneATR

// Filtro adicional — Distância entre as EMAs longas (mede força da tendência)
longSpread = math.abs(ema100 - ema200)
longOK     = minLongATR == 0 or longSpread >= atrVal * minLongATR

// Filtro 2 — Posição: curtas devem estar do lado correto da EMA 200
// Em LONG: a menor das curtas (emaShortMin) >= EMA 200 → estrutura curta acima da longa
// Em SHORT: a maior das curtas (emaShortMax) <= EMA 200
posOKLong  = not requirePosOk or emaShortMin >= ema200
posOKShort = not requirePosOk or emaShortMax <= ema200

// Sinais brutos (1º sinal — diamante)
rawBuy  = trendUp   and bounceLong  and macdTriggerLong  and zoneOK and posOKLong  and longOK and stochOKLong  and htfOKLong
rawSell = trendDown and bounceShort and macdTriggerShort and zoneOK and posOKShort and longOK and stochOKShort and htfOKShort

// ────────────────────────────────────────────────────────────
// PAINEL DE DIAGNÓSTICO: mostra qual filtro está OK / falhando
// Útil pra entender por que um setup que parece bom não disparou
// ────────────────────────────────────────────────────────────
grpDebug    = "── Diagnóstico ──"
showDebug   = input.bool(false, title="Mostrar painel de diagnóstico", group=grpDebug,
                         tooltip="Tabela com o estado de cada filtro na ÚLTIMA barra. Verde=OK, Vermelho=bloqueando.")
debugDir    = input.string("Auto (pela tendência)", title="Direção a diagnosticar", group=grpDebug,
                           options=["Auto (pela tendência)", "LONG", "SHORT"])

if showDebug and barstate.islast
    // Decide qual direção mostrar
    isLong = debugDir == "LONG" or (debugDir == "Auto (pela tendência)" and trendUp)
    isShort = debugDir == "SHORT" or (debugDir == "Auto (pela tendência)" and trendDown)
    dirLabel = isLong ? "LONG" : isShort ? "SHORT" : "—"

    // Estado de cada filtro pra direção escolhida
    f1_trend  = isLong ? trendUp : isShort ? trendDown : false
    f2_bounce = isLong ? bounceLong : isShort ? bounceShort : false
    f3_macd   = isLong ? macdTriggerLong : isShort ? macdTriggerShort : false
    f4_zone   = zoneOK
    f5_pos    = isLong ? posOKLong : isShort ? posOKShort : false
    f6_long   = longOK
    f7_stoch  = isLong ? stochOKLong : isShort ? stochOKShort : false
    f8_htf    = isLong ? htfOKLong   : isShort ? htfOKShort   : false

    okColor = color.new(#26A69A, 20)
    noColor = color.new(#EF5350, 20)
    txtCol  = color.black
    headCol = color.new(color.silver, 50)

    var table dbgTbl = table.new(position.bottom_right, 2, 10, border_width=1, border_color=color.gray)

    table.cell(dbgTbl, 0, 0, "DIAGNÓSTICO " + dirLabel, bgcolor=headCol, text_color=color.black, text_size=size.small)
    table.cell(dbgTbl, 1, 0, "", bgcolor=headCol)

    table.cell(dbgTbl, 0, 1, "1. Tendência longa", text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 1, f1_trend ? "OK" : "✗", bgcolor=f1_trend ? okColor : noColor, text_color=txtCol, text_size=size.small)

    table.cell(dbgTbl, 0, 2, "2. Bounce nas curtas", text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 2, f2_bounce ? "OK" : "✗", bgcolor=f2_bounce ? okColor : noColor, text_color=txtCol, text_size=size.small)

    macdLabel = requireMacdTurn ? "3. MACD virando" : "3. MACD contra-tend."
    table.cell(dbgTbl, 0, 3, macdLabel, text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 3, f3_macd ? "OK" : "✗", bgcolor=f3_macd ? okColor : noColor, text_color=txtCol, text_size=size.small)

    table.cell(dbgTbl, 0, 4, "4. Zona curtas (ATR)", text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 4, f4_zone ? "OK" : "✗", bgcolor=f4_zone ? okColor : noColor, text_color=txtCol, text_size=size.small)

    table.cell(dbgTbl, 0, 5, "5. Posição curtas vs EMA200", text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 5, f5_pos ? "OK" : "✗", bgcolor=f5_pos ? okColor : noColor, text_color=txtCol, text_size=size.small)

    table.cell(dbgTbl, 0, 6, "6. Distância EMAs longas", text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 6, f6_long ? "OK" : "✗", bgcolor=f6_long ? okColor : noColor, text_color=txtCol, text_size=size.small)

    stochLabel = useStochRsi ? "7. Stoch RSI cruzou" : "7. Stoch RSI (off)"
    stochCellColor = useStochRsi ? (f7_stoch ? okColor : noColor) : color.new(color.gray, 70)
    table.cell(dbgTbl, 0, 7, stochLabel, text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 7, useStochRsi ? (f7_stoch ? "OK" : "✗") : "—", bgcolor=stochCellColor, text_color=txtCol, text_size=size.small)

    htfLabel = useHtfTrend ? "8. Trend " + htfTimeframe : "8. HTF trend (off)"
    htfCellColor = useHtfTrend ? (f8_htf ? okColor : noColor) : color.new(color.gray, 70)
    table.cell(dbgTbl, 0, 8, htfLabel, text_color=txtCol, text_size=size.small)
    table.cell(dbgTbl, 1, 8, useHtfTrend ? (f8_htf ? "OK" : "✗") : "—", bgcolor=htfCellColor, text_color=txtCol, text_size=size.small)

    // Resumo: 1º sinal e 2º sinal
    raw1 = isLong ? rawBuy : isShort ? rawSell : false
    seta = isLong ? rawBuy : isShort ? rawSell : false
    table.cell(dbgTbl, 0, 9, "→ 1º sinal | 2º sinal possível", text_color=color.black, text_size=size.small)
    table.cell(dbgTbl, 1, 9, (raw1 ? "●" : "—") + " | " + (seta ? "●" : "—"), bgcolor=headCol, text_color=color.black, text_size=size.small)

// ────────────────────────────────────────────────────────────
// FILTRO: só plota a partir do 2º sinal dentro de N barras
// Conta a partir do 1º sinal. Se virar tendência, reseta.
// ────────────────────────────────────────────────────────────
var int  firstBuyBar  = na  // barra do 1º rawBuy pendente
var int  firstSellBar = na  // barra do 1º rawSell pendente

// Reset por inversão de tendência (não por lateralização temporária)
// Antes: resetava quando "não é trendDown" — bug, lateralização zerava o firstSellBar
// Agora: só reseta quando a tendência DE FATO inverteu pro lado oposto
if trendDown
    firstBuyBar := na
if trendUp
    firstSellBar := na

// Reset por janela expirada
if not na(firstBuyBar) and (bar_index - firstBuyBar) > windowBars
    firstBuyBar := na
if not na(firstSellBar) and (bar_index - firstSellBar) > windowBars
    firstSellBar := na

// Decide se é o 1º (mostra diamante) ou 2º+ (mostra seta) e atualiza estado
// Usamos var bool pra persistir o estado entre barras
var bool isFirstBuy  = false
var bool isFirstSell = false
var bool buySignal   = false
var bool sellSignal  = false

// Tracking da última seta plotada (pro cooldown)
var int lastBuyBar  = na
var int lastSellBar = na

// Reseta tudo no início de cada barra
isFirstBuy  := false
isFirstSell := false
buySignal   := false
sellSignal  := false

// Cooldown: a próxima seta da mesma direção só pode aparecer N barras depois
buyCooldownOK  = signalCooldown == 0 or na(lastBuyBar)  or (bar_index - lastBuyBar)  >= signalCooldown
sellCooldownOK = signalCooldown == 0 or na(lastSellBar) or (bar_index - lastSellBar) >= signalCooldown

if rawBuy
    if na(firstBuyBar)
        firstBuyBar := bar_index
        isFirstBuy  := true          // 1º sinal — diamante
    else if (bar_index - firstBuyBar) >= minSpacing and buyCooldownOK
        buySignal   := true           // 2º+ sinal — espaçamento mínimo + cooldown OK
        lastBuyBar  := bar_index      // marca pra cooldown

if rawSell
    if na(firstSellBar)
        firstSellBar := bar_index
        isFirstSell  := true
    else if (bar_index - firstSellBar) >= minSpacing and sellCooldownOK
        sellSignal  := true
        lastSellBar := bar_index

plotshape(showSignals and buySignal,  title="Compra", style=shape.triangleup,   location=location.belowbar, color=color.new(#26a69a, 0), size=size.small, text="BUY",  textcolor=color.new(#26a69a, 0))
plotshape(showSignals and sellSignal, title="Venda",  style=shape.triangledown, location=location.abovebar, color=color.new(#ef5350, 0), size=size.small, text="SELL", textcolor=color.new(#ef5350, 0))

// 1º sinal: círculo apenas na barra exata em que o 1º foi capturado
// Mesma cor da seta verdadeira, mas com 25% de opacidade (transparência 75)
plotshape(isFirstBuy,  title="1º sinal BUY",  style=shape.circle, location=location.belowbar, color=color.new(#26a69a, 75), size=size.small)
plotshape(isFirstSell, title="1º sinal SELL", style=shape.circle, location=location.abovebar, color=color.new(#ef5350, 75), size=size.small)

// Alertas
alertcondition(buySignal,  title="Sinal de Compra", message="BUY: tendência de alta + bounce nas EMAs curtas + MACD virando")
alertcondition(sellSignal, title="Sinal de Venda",  message="SELL: tendência de baixa + bounce nas EMAs curtas + MACD virando")
````
