# MTF Mirror Candles + SMT

- url: https://www.tradingview.com/script/eLazFwQu/
- type: indicator
- pine_id: PUB;d66488c8819f40b1a455532a658a2cf3
- version: 15.0

## Description

MTF Mirror Candles + SMT displays higher-timeframe mirror candles directly on the chart, allowing traders to monitor broader market structure without changing timeframes.

The indicator includes customizable HTF mirror candles, candle countdown timer, adjustable spacing, candle colors, and automatic mapping between lower and higher timeframes.

It also includes an SMT divergence module designed to compare correlated markets such as MNQ/MES, EURUSD/GBPUSD, NAS100/US500, XAUUSD/XAGUSD, BTC/ETH, or custom pairs.

Main features:
• Higher-timeframe mirror candles
• HTF candle countdown timer
• Adjustable candle quantity, spacing, and visual style
• SMT bullish and bearish divergence detection
• Manual or automatic correlation mode
• Custom correlation pairs
• Clean SMT labels with monitored pair names
• Designed for multi-timeframe and correlation-based analysis

This indicator is intended as a visual analysis tool and does not provide financial advice or buy/sell signals.

## Source Code

````pine
//@version=6

indicator("MTF Mirror Candles + SMT", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// TIMEFRAME INPUTS

tfM1  = input.string("M5", "Se gráfico M1, mostrar", options=["M5","M15","H1","H4","D","S","M"], group="Timeframes")

tfM5  = input.string("M15", "Se gráfico M5, mostrar", options=["M15","H1","H4","D","S","M"], group="Timeframes")

tfM15 = input.string("H1", "Se gráfico M15, mostrar", options=["H1","H4","D","S","M"], group="Timeframes")

tfH1  = input.string("H4", "Se gráfico H1, mostrar", options=["H4","D","S","M"], group="Timeframes")

tfH4  = input.string("D", "Se gráfico H4, mostrar", options=["D","S","M"], group="Timeframes")

tfD   = input.string("S", "Se gráfico D, mostrar", options=["S","M"], group="Timeframes")

tfS   = input.string("M", "Se gráfico S, mostrar", options=["M"], group="Timeframes")

// VISUAL

qty           = input.int(5, "Quantidade de candles", minval=3, maxval=8, group="Visual")

offsetBars    = input.int(8, "Distância do candle atual", minval=1, maxval=100, group="Visual")

spacing       = input.int(3, "Espaçamento entre candles", minval=0, maxval=30, group="Visual")

bodyHalfWidth = input.int(1, "Meia largura do corpo", minval=0, maxval=5, group="Visual")

lineBodyWidth = input.int(1, "Largura do corpo em modo fino", minval=1, maxval=20, group="Visual")

wickWidth     = input.int(1, "Largura do pavio", minval=1, maxval=5, group="Visual")

bullColor = input.color(color.green, "Cor candle de alta", group="Cores")

bearColor = input.color(color.red, "Cor candle de baixa", group="Cores")

wickColor = input.color(color.gray, "Cor do pavio", group="Cores")

textColor = input.color(color.gray, "Cor do texto", group="Cores")

showTimer  = input.bool(true, "Mostrar timer", group="Extras")

showTFName = input.bool(true, "Mostrar nome do TF", group="Extras")

// TD/MD OPEN INPUTS

showTDOpen = input.bool(true, "Mostrar TD Open", group="TD/MD Open")

showMDOpen = input.bool(true, "Mostrar MD Open", group="TD/MD Open")

tdOpenColor = input.color(color.black, "Cor TD Open", group="TD/MD Open")

mdOpenColor = input.color(color.black, "Cor MD Open", group="TD/MD Open")

openLineWidth = input.int(1, "Largura das linhas", minval=1, maxval=5, group="TD/MD Open")

openRightBars = input.int(20, "Extensão à direita", minval=0, maxval=200, group="TD/MD Open")

openTextOffset = input.int(0, "Distância do texto", minval=0, maxval=20, group="TD/MD Open")

showOpenText = input.bool(true, "Mostrar texto TD/MD Open", group="TD/MD Open")

openDays = input.int(1, "Mostrar últimos X dias", minval=1, maxval=10, group="TD/MD Open")

// SMT INPUTS

showSMT      = input.bool(true, "Mostrar SMT", group="SMT Configurações")

smtPivot     = input.int(11, "Força do Pivot SMT", minval=2, maxval=20, group="SMT Configurações")

smtLabelOffsetATR = input.float(0.05, "Distância do texto SMT", minval=0.0, maxval=0.5, step=0.01, group="SMT Configurações")

showSMTBull  = input.bool(true, "Mostrar SMT Alta", group="SMT Configurações")

showSMTBear  = input.bool(true, "Mostrar SMT Baixa", group="SMT Configurações")

maxSMTs      = input.int(5, "Máximo SMTs", minval=1, maxval=50, group="SMT Configurações")

maxFormingSMTs = input.int(1, "SMTs em formação", minval=0, maxval=5, group="SMT Configurações")

formingMode = input.string("Tempo real", "Modo SMT em formação", options=["Tempo real", "Após fechamento"], tooltip="SMT em formação com espelhamento visual: linha verde = o ativo do gráfico rompeu o pivot de referência; linha vermelha = o outro ativo rompeu e este ativo não confirmou. A linha fica tracejada enquanto o candle causador está aberto e vira contínua após o fechamento.", group="SMT Configurações")


smtBearColor = input.color(color.black, "Cor SMT Bear", group="SMT Configurações")

smtBullColor = input.color(color.black, "Cor SMT Bull", group="SMT Configurações")

corrMode  = input.string("Manual", "Modo de Correlação", options=["Automático","Manual"], group="SMT Pares de Correlação")

corrGroup = input.string("Futuros", "Grupo de Correlação Monitorado", options=["Forex","Índices","Metais","Crypto","Futuros","Personalizado"], group="SMT Pares de Correlação")

forexA   = input.symbol("FX:EURUSD", "Forex A", group="SMT Pares de Correlação")

forexB   = input.symbol("FX:GBPUSD", "Forex B", group="SMT Pares de Correlação")

indexA   = input.symbol("FOREXCOM:NAS100", "Índices A", group="SMT Pares de Correlação")

indexB   = input.symbol("CAPITALCOM:US500", "Índices B", group="SMT Pares de Correlação")

metalsA  = input.symbol("OANDA:XAUUSD", "Metais A", group="SMT Pares de Correlação")

metalsB  = input.symbol("OANDA:XAGUSD", "Metais B", group="SMT Pares de Correlação")

cryptoA  = input.symbol("BITSTAMP:BTCUSD", "Crypto A", group="SMT Pares de Correlação")

cryptoB  = input.symbol("BINANCE:ETHUSD", "Crypto B", group="SMT Pares de Correlação")

futuresA = input.symbol("CME_MINI:MNQ1!", "Futuros A", group="SMT Pares de Correlação")

futuresB = input.symbol("CME_MINI:MES1!", "Futuros B", group="SMT Pares de Correlação")

customA  = input.symbol("CME_MINI:MNQ1!", "Personalizado A", group="SMT Pares de Correlação")

customB  = input.symbol("CME_MINI:MES1!", "Personalizado B", group="SMT Pares de Correlação")

// TIMEFRAME CONVERSION

f_toPineTF(tf) =>

    if tf == "M5"

        "5"

    else if tf == "M15"

        "15"

    else if tf == "H1"

        "60"

    else if tf == "H4"

        "240"

    else if tf == "D"

        "D"

    else if tf == "S"

        "W"

    else

        "M"

// CURRENT TF

chartSec = timeframe.in_seconds(timeframe.period)

chartTF = "OUTRO"

if timeframe.isweekly

    chartTF := "S"

else if timeframe.isdaily

    chartTF := "D"

else if chartSec < 5 * 60

    chartTF := "M1"

else if chartSec < 15 * 60

    chartTF := "M5"

else if chartSec < 60 * 60

    chartTF := "M15"

else if chartSec < 240 * 60

    chartTF := "H1"

else if chartSec < 24 * 60 * 60

    chartTF := "H4"

showMirror = not timeframe.ismonthly

// SELECT MIRROR TF

selectedMirror = "H1"

if chartTF == "M1"

    selectedMirror := tfM1

else if chartTF == "M5"

    selectedMirror := tfM5

else if chartTF == "M15"

    selectedMirror := tfM15

else if chartTF == "H1"

    selectedMirror := tfH1

else if chartTF == "H4"

    selectedMirror := tfH4

else if chartTF == "D"

    selectedMirror := tfD

else if chartTF == "S"

    selectedMirror := tfS

mirrorTF = f_toPineTF(selectedMirror)

// HTF DATA

[o0,h0,l0,c0,tc0] = request.security(syminfo.tickerid, mirrorTF, [open,high,low,close,time_close], barmerge.gaps_off, barmerge.lookahead_off)

[o1,h1,l1,c1] = request.security(syminfo.tickerid, mirrorTF, [open[1],high[1],low[1],close[1]], barmerge.gaps_off, barmerge.lookahead_off)

[o2,h2,l2,c2] = request.security(syminfo.tickerid, mirrorTF, [open[2],high[2],low[2],close[2]], barmerge.gaps_off, barmerge.lookahead_off)

[o3,h3,l3,c3] = request.security(syminfo.tickerid, mirrorTF, [open[3],high[3],low[3],close[3]], barmerge.gaps_off, barmerge.lookahead_off)

[o4,h4,l4,c4] = request.security(syminfo.tickerid, mirrorTF, [open[4],high[4],low[4],close[4]], barmerge.gaps_off, barmerge.lookahead_off)

[o5,h5,l5,c5] = request.security(syminfo.tickerid, mirrorTF, [open[5],high[5],low[5],close[5]], barmerge.gaps_off, barmerge.lookahead_off)

[o6,h6,l6,c6] = request.security(syminfo.tickerid, mirrorTF, [open[6],high[6],low[6],close[6]], barmerge.gaps_off, barmerge.lookahead_off)

[o7,h7,l7,c7] = request.security(syminfo.tickerid, mirrorTF, [open[7],high[7],low[7],close[7]], barmerge.gaps_off, barmerge.lookahead_off)

f_getO(i) => i == 0 ? o0 : i == 1 ? o1 : i == 2 ? o2 : i == 3 ? o3 : i == 4 ? o4 : i == 5 ? o5 : i == 6 ? o6 : o7

f_getH(i) => i == 0 ? h0 : i == 1 ? h1 : i == 2 ? h2 : i == 3 ? h3 : i == 4 ? h4 : i == 5 ? h5 : i == 6 ? h6 : h7

f_getL(i) => i == 0 ? l0 : i == 1 ? l1 : i == 2 ? l2 : i == 3 ? l3 : i == 4 ? l4 : i == 5 ? l5 : i == 6 ? l6 : l7

f_getC(i) => i == 0 ? c0 : i == 1 ? c1 : i == 2 ? c2 : i == 3 ? c3 : i == 4 ? c4 : i == 5 ? c5 : i == 6 ? c6 : c7

f_timer(ms) =>

    totalSec = math.max(0, math.floor(ms / 1000))

    hrs  = math.floor(totalSec / 3600)

    mins = math.floor((totalSec % 3600) / 60)

    secs = totalSec % 60

    if hrs > 0

        str.format("{0}:{1,number,00}:{2,number,00}", hrs, mins, secs)

    else

        str.format("{0}:{1,number,00}", mins, secs)

// MIRROR OBJECTS

var box[] bodies = array.new_box()

var line[] mirrorLines = array.new_line()

var label[] mirrorLabels = array.new_label()

if barstate.islast and showMirror

    for b in bodies

        box.delete(b)

    for ln in mirrorLines

        line.delete(ln)

    for lb in mirrorLabels

        label.delete(lb)

    array.clear(bodies)

    array.clear(mirrorLines)

    array.clear(mirrorLabels)

    highestPrice = h0

    timerX = bar_index + offsetBars + math.max(qty - 2, 0) * spacing

    for pos = 0 to qty - 1

        i = qty - 1 - pos

        o = f_getO(i)

        h = f_getH(i)

        l = f_getL(i)

        c = f_getC(i)

        x = bar_index + offsetBars + pos * spacing

        candleColor = c >= o ? bullColor : bearColor

        if h > highestPrice

            highestPrice := h

        bodyTop = math.max(o, c)

        bodyBot = math.min(o, c)

        wick = line.new(x1=x, y1=h, x2=x, y2=l, color=wickColor, width=wickWidth)

        array.push(mirrorLines, wick)

        isDoji = math.abs(o - c) < syminfo.mintick * 2

        if isDoji

            doji = line.new(x1=x - 1, y1=o, x2=x + 1, y2=o, color=candleColor, width=lineBodyWidth)

            array.push(mirrorLines, doji)

        else

            if bodyHalfWidth == 0

                bodyLine = line.new(x1=x, y1=bodyBot, x2=x, y2=bodyTop, color=candleColor, width=lineBodyWidth)

                array.push(mirrorLines, bodyLine)

            else

                body = box.new(

                     left=x - bodyHalfWidth,

                     top=bodyTop,

                     right=x + bodyHalfWidth,

                     bottom=bodyBot,

                     bgcolor=candleColor,

                     border_color=color.new(candleColor, 100)

                )

                array.push(bodies, body)

    if showTimer or showTFName

        txt = ""

        if showTFName

            txt += selectedMirror

        if showTimer

            if showTFName

                txt += "\n" + f_timer(tc0 - timenow)

            else

                txt += f_timer(tc0 - timenow)

        lbl = label.new(

             x=timerX,

             y=highestPrice,

             text=txt,

             style=label.style_label_down,

             textcolor=textColor,

             color=color.new(color.white,100)

        )

        array.push(mirrorLabels, lbl)

// TD/MD OPEN MODULE

// TD Open = 18:00 New York

// MD Open = 00:00 New York

// Ajuste seguro: TD/MD Open visíveis em timeframes intraday até H4.

// Em M1, usa o candle do próprio gráfico.

// Acima de M1 até H4, busca internamente o preço exato no 1 minuto.

// Não altera SMT, mirror candles ou pares de correlação.

// Em timeframes acima de M1, a linha começa no horário real do open usando xloc.bar_time.

openTZ = "America/New_York"

nyHour = hour(time, openTZ)

nyMinute = minute(time, openTZ)

openTFAllowed = timeframe.isintraday and chartSec <= 240 * 60

chartMs = chartSec * 1000

[ltfOpenArr, ltfTimeArr, ltfTDFlagArr, ltfMDFlagArr] = request.security_lower_tf(

     syminfo.tickerid,

     "1",

     [open, time, hour(time, openTZ) == 18 and minute(time, openTZ) == 0, hour(time, openTZ) == 0 and minute(time, openTZ) == 0],

     ignore_invalid_timeframe=true

)

var line[] tdOpenLines = array.new_line()

var line[] mdOpenLines = array.new_line()

var label[] tdOpenLabels = array.new_label()

var label[] mdOpenLabels = array.new_label()

var int lastTDOpenTime = na

var int lastMDOpenTime = na

bool tdFound = false

bool mdFound = false

float tdOpenPrice = na

float mdOpenPrice = na

int tdOpenTime = na

int mdOpenTime = na

int tdLineStartTime = na

int mdLineStartTime = na

// M1: mantém a leitura direta do candle do gráfico.

if openTFAllowed and chartSec <= 60

    if nyHour == 18 and nyMinute == 0

        tdFound := true

        tdOpenPrice := open

        tdOpenTime := time

        tdLineStartTime := time

    if nyHour == 0 and nyMinute == 0

        mdFound := true

        mdOpenPrice := open

        mdOpenTime := time

        mdLineStartTime := time

// Acima de M1 até H4: procura o candle de 1 minuto que abriu exatamente em 18:00 ou 00:00 NY.

if openTFAllowed and chartSec > 60

    ltfCount = array.size(ltfOpenArr)

    if ltfCount > 0

        for i = 0 to ltfCount - 1

            if array.get(ltfTDFlagArr, i)

                tdFound := true

                tdOpenPrice := array.get(ltfOpenArr, i)

                tdOpenTime := array.get(ltfTimeArr, i)

                tdLineStartTime := tdOpenTime

            if array.get(ltfMDFlagArr, i)

                mdFound := true

                mdOpenPrice := array.get(ltfOpenArr, i)

                mdOpenTime := array.get(ltfTimeArr, i)

                mdLineStartTime := mdOpenTime

if showTDOpen and tdFound and not na(tdOpenPrice) and not na(tdOpenTime) and not na(tdLineStartTime) and (na(lastTDOpenTime) or tdOpenTime != lastTDOpenTime)

    tdLn = line.new(

         x1=tdLineStartTime,

         y1=tdOpenPrice,

         x2=tdLineStartTime + openRightBars * chartMs,

         y2=tdOpenPrice,

         xloc=xloc.bar_time,

         color=tdOpenColor,

         width=openLineWidth,

         style=line.style_solid

    )

    array.push(tdOpenLines, tdLn)

    if showOpenText

        tdLb = label.new(x=tdLineStartTime + (openRightBars + openTextOffset) * chartMs, y=tdOpenPrice, text="TD Open", xloc=xloc.bar_time, style=label.style_label_left, textcolor=tdOpenColor, color=color.new(color.white, 100), size=size.small, textalign=text.align_left)

        array.push(tdOpenLabels, tdLb)

    lastTDOpenTime := tdOpenTime

    if array.size(tdOpenLines) > openDays

        oldTdLn = array.shift(tdOpenLines)

        line.delete(oldTdLn)

    if array.size(tdOpenLabels) > openDays

        oldTdLb = array.shift(tdOpenLabels)

        label.delete(oldTdLb)

if showMDOpen and mdFound and not na(mdOpenPrice) and not na(mdOpenTime) and not na(mdLineStartTime) and (na(lastMDOpenTime) or mdOpenTime != lastMDOpenTime)

    mdLn = line.new(

         x1=mdLineStartTime,

         y1=mdOpenPrice,

         x2=mdLineStartTime + openRightBars * chartMs,

         y2=mdOpenPrice,

         xloc=xloc.bar_time,

         color=mdOpenColor,

         width=openLineWidth,

         style=line.style_solid

    )

    array.push(mdOpenLines, mdLn)

    if showOpenText

        mdLb = label.new(x=mdLineStartTime + (openRightBars + openTextOffset) * chartMs, y=mdOpenPrice, text="MD Open", xloc=xloc.bar_time, style=label.style_label_left, textcolor=mdOpenColor, color=color.new(color.white, 100), size=size.small, textalign=text.align_left)

        array.push(mdOpenLabels, mdLb)

    lastMDOpenTime := mdOpenTime

    if array.size(mdOpenLines) > openDays

        oldMdLn = array.shift(mdOpenLines)

        line.delete(oldMdLn)

    if array.size(mdOpenLabels) > openDays

        oldMdLb = array.shift(mdOpenLabels)

        label.delete(oldMdLb)

if barstate.islast and openTFAllowed

    openEndTime = time + openRightBars * chartMs

    openLabelTime = time + (openRightBars + openTextOffset) * chartMs

    for tdLn in tdOpenLines

        line.set_x2(tdLn, openEndTime)

        line.set_color(tdLn, tdOpenColor)

        line.set_width(tdLn, openLineWidth)

    for mdLn in mdOpenLines

        line.set_x2(mdLn, openEndTime)

        line.set_color(mdLn, mdOpenColor)

        line.set_width(mdLn, openLineWidth)

    for tdLb in tdOpenLabels

        label.set_x(tdLb, openLabelTime)

        label.set_text(tdLb, showOpenText ? "TD Open" : "")

        label.set_textcolor(tdLb, tdOpenColor)

        label.set_style(tdLb, label.style_label_left)

        label.set_textalign(tdLb, text.align_left)

    for mdLb in mdOpenLabels

        label.set_x(mdLb, openLabelTime)

        label.set_text(mdLb, showOpenText ? "MD Open" : "")

        label.set_textcolor(mdLb, mdOpenColor)

        label.set_style(mdLb, label.style_label_left)

        label.set_textalign(mdLb, text.align_left)

// SMT AUTO / MANUAL PAIR SELECTION

chartID = str.upper(syminfo.tickerid)

chartTicker = str.upper(syminfo.ticker)

f_tickerOnly(sym) =>

    s = str.upper(sym)

    s := str.replace_all(s, "CME_MINI:", "")

    s := str.replace_all(s, "CME_MINI_DL:", "")

    s := str.replace_all(s, "FOREXCOM:", "")

    s := str.replace_all(s, "CAPITALCOM:", "")

    s := str.replace_all(s, "OANDA:", "")

    s := str.replace_all(s, "BINANCE:", "")

    s := str.replace_all(s, "BITSTAMP:", "")

    s := str.replace_all(s, "FX:", "")

    s

isForexA   = str.contains(chartID, "EURUSD")

isForexB   = str.contains(chartID, "GBPUSD")

isIndexA   = str.contains(chartID, "NAS100") or str.contains(chartID, "US100") or str.contains(chartID, "NDX")

isIndexB   = str.contains(chartID, "US500") or str.contains(chartID, "SPX") or str.contains(chartID, "SP500")

isMetalsA  = str.contains(chartID, "XAUUSD") or str.contains(chartID, "GOLD")

isMetalsB  = str.contains(chartID, "XAGUSD") or str.contains(chartID, "SILVER")

isCryptoA  = str.contains(chartID, "BTCUSD") or str.contains(chartID, "BTCUSDT")

isCryptoB  = str.contains(chartID, "ETHUSD") or str.contains(chartID, "ETHUSDT")

isFuturesA = str.contains(chartID, "MNQ") or str.contains(chartID, "NQ1")

isFuturesB = str.contains(chartID, "MES") or str.contains(chartID, "ES1")

autoPairA = futuresA

autoPairB = futuresB

autoChartIsA = false

autoChartIsB = false

autoValid = false

if isForexA or isForexB

    autoPairA := forexA

    autoPairB := forexB

    autoChartIsA := isForexA

    autoChartIsB := isForexB

    autoValid := true

else if isIndexA or isIndexB

    autoPairA := indexA

    autoPairB := indexB

    autoChartIsA := isIndexA

    autoChartIsB := isIndexB

    autoValid := true

else if isMetalsA or isMetalsB

    autoPairA := metalsA

    autoPairB := metalsB

    autoChartIsA := isMetalsA

    autoChartIsB := isMetalsB

    autoValid := true

else if isCryptoA or isCryptoB

    autoPairA := cryptoA

    autoPairB := cryptoB

    autoChartIsA := isCryptoA

    autoChartIsB := isCryptoB

    autoValid := true

else if isFuturesA or isFuturesB

    autoPairA := futuresA

    autoPairB := futuresB

    autoChartIsA := isFuturesA

    autoChartIsB := isFuturesB

    autoValid := true

manualPairA = futuresA

manualPairB = futuresB

if corrGroup == "Forex"

    manualPairA := forexA

    manualPairB := forexB

else if corrGroup == "Índices"

    manualPairA := indexA

    manualPairB := indexB

else if corrGroup == "Metais"

    manualPairA := metalsA

    manualPairB := metalsB

else if corrGroup == "Crypto"

    manualPairA := cryptoA

    manualPairB := cryptoB

else if corrGroup == "Futuros"

    manualPairA := futuresA

    manualPairB := futuresB

else

    manualPairA := customA

    manualPairB := customB

chartSymbol = str.upper(syminfo.ticker)

manualASymbol = f_tickerOnly(manualPairA)

manualBSymbol = f_tickerOnly(manualPairB)

manualChartIsA = chartSymbol == manualASymbol

manualChartIsB = chartSymbol == manualBSymbol

manualValid = manualChartIsA or manualChartIsB

pairA = autoPairA

pairB = autoPairB

pairValid = autoValid

chartIsA = autoChartIsA

if corrMode == "Manual"

    pairA := manualPairA

    pairB := manualPairB

    pairValid := manualValid

    chartIsA := manualChartIsA

compareSymbol = chartIsA ? pairB : pairA

f_shortSymbol(sym) =>

    s = str.upper(sym)

    s := str.replace_all(s, "CME_MINI:", "")

    s := str.replace_all(s, "FOREXCOM:", "")

    s := str.replace_all(s, "CAPITALCOM:", "")

    s := str.replace_all(s, "OANDA:", "")

    s := str.replace_all(s, "BINANCE:", "")

    s := str.replace_all(s, "BITSTAMP:", "")

    s := str.replace_all(s, "FX:", "")

    s

pairText = "SMT " + f_shortSymbol(compareSymbol)

// SMT MODULE - PIVOT FAST

mainPH = ta.pivothigh(high, smtPivot, smtPivot)

mainPL = ta.pivotlow(low, smtPivot, smtPivot)

corrHighSeries = request.security(compareSymbol, timeframe.period, high, barmerge.gaps_off, barmerge.lookahead_off)

corrLowSeries  = request.security(compareSymbol, timeframe.period, low, barmerge.gaps_off, barmerge.lookahead_off)

var float prevMainPH = na

var float prevCorrPH = na

var int   prevPHX = na

var float prevMainPL = na

var float prevCorrPL = na

var int   prevPLX = na

var line[] smtLines = array.new_line()

var label[] smtLabels = array.new_label()

f_addSMT(_x1, _y1, _x2, _y2, _txt, _col, _isBull) =>

    ln = line.new(

         x1=_x1,

         y1=_y1,

         x2=_x2,

         y2=_y2,

         color=_col,

         width=1

    )

    midX = math.round((_x1 + _x2) / 2)

    midBase = (_y1 + _y2) / 2

    atrSafe = nz(ta.atr(14), syminfo.mintick * 100)

    labelOffset = math.max(syminfo.mintick * 1, atrSafe * smtLabelOffsetATR)

    midY = _isBull ? midBase - labelOffset : midBase + labelOffset

    lb = label.new(

         x=midX,

         y=midY,

         text=_txt,

         style=label.style_none,

         textcolor=_col,

         color=color.new(color.white, 100),

         size=size.small

    )

    array.push(smtLines, ln)

    array.push(smtLabels, lb)

    if array.size(smtLines) > maxSMTs

        oldLn = array.shift(smtLines)

        line.delete(oldLn)

    if array.size(smtLabels) > maxSMTs

        oldLb = array.shift(smtLabels)

        label.delete(oldLb)

if showSMT and pairValid

    // BEARISH SMT - swing high

    if not na(mainPH)

        pivotX = bar_index - smtPivot

        currMainPH = high[smtPivot]

        currCorrPH = corrHighSeries[smtPivot]

        if not na(prevMainPH) and not na(prevCorrPH) and not na(currCorrPH)

            mainHH = currMainPH > prevMainPH

            corrHH = currCorrPH > prevCorrPH

            bearSMT = mainHH != corrHH

            if bearSMT and showSMTBear

                f_addSMT(prevPHX, prevMainPH, pivotX, currMainPH, pairText, smtBearColor, false)

        prevMainPH := currMainPH

        prevCorrPH := currCorrPH

        prevPHX := pivotX

    // BULLISH SMT - swing low

    if not na(mainPL)

        pivotX = bar_index - smtPivot

        currMainPL = low[smtPivot]

        currCorrPL = corrLowSeries[smtPivot]

        if not na(prevMainPL) and not na(prevCorrPL) and not na(currCorrPL)

            mainLL = currMainPL < prevMainPL

            corrLL = currCorrPL < prevCorrPL

            bullSMT = mainLL != corrLL

            if bullSMT and showSMTBull

                f_addSMT(prevPLX, prevMainPL, pivotX, currMainPL, pairText, smtBullColor, true)

        prevMainPL := currMainPL

        prevCorrPL := currCorrPL

        prevPLX := pivotX

// =======================================================
// SMT EM FORMAÇÃO - ESPELHO TEMPORAL CORRIGIDO
// Regra visual:
// - verde: ativo do gráfico rompeu o próprio pivot de referência.
// - vermelho: o outro ativo rompeu o próprio pivot; este ativo apenas recebe a cópia visual.
// - o ativo que recebe a cópia NÃO procura pivot próprio.
// - tracejada: candle causador ainda aberto.
// - contínua: candle causador fechado.
// Não altera o bloco original do SMT confirmado.
// =======================================================

var line formingBullLine = na
var line formingBearLine = na

formingSMTBreakColor = color.green
formingSMTMirrorColor = color.red

// Horários dos pivots do ativo do gráfico, usados só para desenhar a linha verde em xloc.bar_time.
var int prevMainPHT = na
var int prevMainPLT = na

// Pivots próprios do OUTRO ativo, usados somente para saber quando ele foi o causador.
// O ativo atual não precisa ter pivot nesses horários; ele só recebe a cópia visual vermelha.
corrOwnPH = ta.pivothigh(corrHighSeries, smtPivot, smtPivot)
corrOwnPL = ta.pivotlow(corrLowSeries, smtPivot, smtPivot)

var float prevOtherPH = na
var float prevThisAtOtherPH = na
var int   prevOtherPHT = na

var float prevOtherPL = na
var float prevThisAtOtherPL = na
var int   prevOtherPLT = na

if showSMT and pairValid
    if not na(mainPH)
        prevMainPHT := time[smtPivot]

    if not na(mainPL)
        prevMainPLT := time[smtPivot]

    if not na(corrOwnPH)
        prevOtherPH := corrOwnPH
        prevThisAtOtherPH := high[smtPivot]
        prevOtherPHT := time[smtPivot]

    if not na(corrOwnPL)
        prevOtherPL := corrOwnPL
        prevThisAtOtherPL := low[smtPivot]
        prevOtherPLT := time[smtPivot]

f_deleteLine(_ln) =>
    if not na(_ln)
        line.delete(_ln)

f_makeFormingSMT(_x1, _y1, _x2, _y2, _isLive, _col) =>
    line.new(
         x1=_x1,
         y1=_y1,
         x2=_x2,
         y2=_y2,
         xloc=xloc.bar_time,
         color=_col,
         width=1,
         style=_isLive ? line.style_dashed : line.style_solid
    )

if barstate.islast
    f_deleteLine(formingBullLine)
    f_deleteLine(formingBearLine)
    formingBullLine := na
    formingBearLine := na

    if showSMT and pairValid and maxFormingSMTs > 0

        useRealtime = formingMode == "Tempo real"

        bool bullForming = false
        bool bearForming = false
        bool bullLive = false
        bool bearLive = false

        int bullX1 = na
        int bullX2 = na
        float bullY1 = na
        float bullY2 = na
        color bullCol = formingSMTBreakColor

        int bearX1 = na
        int bearX2 = na
        float bearY1 = na
        float bearY2 = na
        color bearCol = formingSMTBreakColor

        // =======================================================
        // BULLISH SMT EM FORMAÇÃO
        // =======================================================
        if showSMTBull

            // 1) Linha verde: ativo do gráfico rompeu o próprio pivot.
            if not na(prevMainPL) and not na(prevCorrPL) and not na(prevMainPLT)
                float pendingMainLow = na
                float pendingCorrLowWindow = na
                int pendingLowT = na
                int pendingLowI = na

                for i = 0 to smtPivot
                    useThisCandle = useRealtime ? i <= smtPivot - 1 : i >= 1

                    if useThisCandle
                        if not na(low[i])
                            if na(pendingMainLow) or low[i] < pendingMainLow
                                pendingMainLow := low[i]
                                pendingLowT := time[i]
                                pendingLowI := i

                        if not na(corrLowSeries[i])
                            if na(pendingCorrLowWindow) or corrLowSeries[i] < pendingCorrLowWindow
                                pendingCorrLowWindow := corrLowSeries[i]

                if not na(pendingMainLow) and not na(pendingCorrLowWindow) and not na(pendingLowT)
                    mainLLForming = pendingMainLow < prevMainPL
                    corrLLForming = pendingCorrLowWindow < prevCorrPL
                    validPendingLow = pendingLowT > prevMainPLT

                    if validPendingLow and mainLLForming and not corrLLForming
                        bullForming := true
                        bullX1 := prevMainPLT
                        bullY1 := prevMainPL
                        bullX2 := pendingLowT
                        bullY2 := pendingMainLow
                        bullCol := formingSMTBreakColor
                        bullLive := useRealtime and pendingLowI == 0 and not barstate.isconfirmed

            // 2) Linha vermelha: o outro ativo rompeu o próprio pivot.
            // O ativo atual NÃO procura pivot. Ele só copia os horários do evento do outro ativo.
            if not na(prevOtherPL) and not na(prevThisAtOtherPL) and not na(prevOtherPLT)
                float pendingOtherLow = na
                float pendingThisLowWindow = na
                float pendingThisLowAtOtherBreak = na
                int pendingOtherLowT = na
                int pendingOtherLowI = na

                for i = 0 to smtPivot
                    useThisCandle = useRealtime ? i <= smtPivot - 1 : i >= 1

                    if useThisCandle
                        if not na(corrLowSeries[i])
                            if na(pendingOtherLow) or corrLowSeries[i] < pendingOtherLow
                                pendingOtherLow := corrLowSeries[i]
                                pendingOtherLowT := time[i]
                                pendingOtherLowI := i
                                pendingThisLowAtOtherBreak := low[i]

                        if not na(low[i])
                            if na(pendingThisLowWindow) or low[i] < pendingThisLowWindow
                                pendingThisLowWindow := low[i]

                if not na(pendingOtherLow) and not na(pendingThisLowWindow) and not na(pendingThisLowAtOtherBreak) and not na(pendingOtherLowT)
                    otherLLForming = pendingOtherLow < prevOtherPL
                    thisLLConfirmed = pendingThisLowWindow < prevThisAtOtherPL
                    validOtherLow = pendingOtherLowT > prevOtherPLT

                    if validOtherLow and otherLLForming and not thisLLConfirmed
                        replaceBull = not bullForming
                        if bullForming and pendingOtherLowT > bullX2
                            replaceBull := true

                        if replaceBull
                            bullForming := true
                            bullX1 := prevOtherPLT
                            bullY1 := prevThisAtOtherPL
                            bullX2 := pendingOtherLowT
                            bullY2 := pendingThisLowAtOtherBreak
                            bullCol := formingSMTMirrorColor
                            bullLive := useRealtime and pendingOtherLowI == 0 and not barstate.isconfirmed

        // =======================================================
        // BEARISH SMT EM FORMAÇÃO
        // =======================================================
        if showSMTBear

            // 1) Linha verde: ativo do gráfico rompeu o próprio pivot.
            if not na(prevMainPH) and not na(prevCorrPH) and not na(prevMainPHT)
                float pendingMainHigh = na
                float pendingCorrHighWindow = na
                int pendingHighT = na
                int pendingHighI = na

                for i = 0 to smtPivot
                    useThisCandle = useRealtime ? i <= smtPivot - 1 : i >= 1

                    if useThisCandle
                        if not na(high[i])
                            if na(pendingMainHigh) or high[i] > pendingMainHigh
                                pendingMainHigh := high[i]
                                pendingHighT := time[i]
                                pendingHighI := i

                        if not na(corrHighSeries[i])
                            if na(pendingCorrHighWindow) or corrHighSeries[i] > pendingCorrHighWindow
                                pendingCorrHighWindow := corrHighSeries[i]

                if not na(pendingMainHigh) and not na(pendingCorrHighWindow) and not na(pendingHighT)
                    mainHHForming = pendingMainHigh > prevMainPH
                    corrHHForming = pendingCorrHighWindow > prevCorrPH
                    validPendingHigh = pendingHighT > prevMainPHT

                    if validPendingHigh and mainHHForming and not corrHHForming
                        bearForming := true
                        bearX1 := prevMainPHT
                        bearY1 := prevMainPH
                        bearX2 := pendingHighT
                        bearY2 := pendingMainHigh
                        bearCol := formingSMTBreakColor
                        bearLive := useRealtime and pendingHighI == 0 and not barstate.isconfirmed

            // 2) Linha vermelha: o outro ativo rompeu o próprio pivot.
            // O ativo atual NÃO procura pivot. Ele só copia os horários do evento do outro ativo.
            if not na(prevOtherPH) and not na(prevThisAtOtherPH) and not na(prevOtherPHT)
                float pendingOtherHigh = na
                float pendingThisHighWindow = na
                float pendingThisHighAtOtherBreak = na
                int pendingOtherHighT = na
                int pendingOtherHighI = na

                for i = 0 to smtPivot
                    useThisCandle = useRealtime ? i <= smtPivot - 1 : i >= 1

                    if useThisCandle
                        if not na(corrHighSeries[i])
                            if na(pendingOtherHigh) or corrHighSeries[i] > pendingOtherHigh
                                pendingOtherHigh := corrHighSeries[i]
                                pendingOtherHighT := time[i]
                                pendingOtherHighI := i
                                pendingThisHighAtOtherBreak := high[i]

                        if not na(high[i])
                            if na(pendingThisHighWindow) or high[i] > pendingThisHighWindow
                                pendingThisHighWindow := high[i]

                if not na(pendingOtherHigh) and not na(pendingThisHighWindow) and not na(pendingThisHighAtOtherBreak) and not na(pendingOtherHighT)
                    otherHHForming = pendingOtherHigh > prevOtherPH
                    thisHHConfirmed = pendingThisHighWindow > prevThisAtOtherPH
                    validOtherHigh = pendingOtherHighT > prevOtherPHT

                    if validOtherHigh and otherHHForming and not thisHHConfirmed
                        replaceBear = not bearForming
                        if bearForming and pendingOtherHighT > bearX2
                            replaceBear := true

                        if replaceBear
                            bearForming := true
                            bearX1 := prevOtherPHT
                            bearY1 := prevThisAtOtherPH
                            bearX2 := pendingOtherHighT
                            bearY2 := pendingThisHighAtOtherBreak
                            bearCol := formingSMTMirrorColor
                            bearLive := useRealtime and pendingOtherHighI == 0 and not barstate.isconfirmed

        // DESENHO FINAL
        // maxFormingSMTs = 0: não mostra formação.
        // maxFormingSMTs = 1: mostra só a formação mais recente entre alta/baixa.
        // maxFormingSMTs >= 2: pode mostrar uma bullish e uma bearish ao mesmo tempo.
        if maxFormingSMTs == 1
            if bullForming and bearForming
                if bullX2 > bearX2
                    formingBullLine := f_makeFormingSMT(bullX1, bullY1, bullX2, bullY2, bullLive, bullCol)
                else
                    formingBearLine := f_makeFormingSMT(bearX1, bearY1, bearX2, bearY2, bearLive, bearCol)
            else if bullForming
                formingBullLine := f_makeFormingSMT(bullX1, bullY1, bullX2, bullY2, bullLive, bullCol)
            else if bearForming
                formingBearLine := f_makeFormingSMT(bearX1, bearY1, bearX2, bearY2, bearLive, bearCol)
        else
            if bullForming
                formingBullLine := f_makeFormingSMT(bullX1, bullY1, bullX2, bullY2, bullLive, bullCol)

            if bearForming
                formingBearLine := f_makeFormingSMT(bearX1, bearY1, bearX2, bearY2, bearLive, bearCol)
````
