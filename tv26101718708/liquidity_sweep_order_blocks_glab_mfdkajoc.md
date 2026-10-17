# Liquidity Sweep + Order Blocks [GLAB]

- url: https://www.tradingview.com/script/mfdKAjOC/
- type: indicator
- pine_id: PUB;9b07d2b48c2b4201addefaf14ca86a4c
- version: 1.0

## Description

Liquidez fakeout e ob stoploss 2pip e tp 1:2 marcado

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep + Order Blocks [GLAB]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================
// GRUPOS DE INPUTS
// ============================================================

// ---------- Liquidity Sweep + Fakeout ----------
g_sweep = "Liquidity Sweep + Fakeout"
showSweep      = input.bool(true, "Ativar Liquidity Sweep", group=g_sweep)
showSweepZones = input.bool(true, "Mostrar zonas (EQH/EQL + Sessões)", group=g_sweep)
showSweepSignals = input.bool(true, "Mostrar sinais de entrada", group=g_sweep)
eqTolPct       = input.float(0.05, "Tolerância Equal High/Low (%)", step=0.01, group=g_sweep) / 100
swingLen       = input.int(5, "Lookback para Swing High/Low", minval=2, group=g_sweep)
showAsia       = input.bool(true, "Mostrar sessão Ásia", group=g_sweep)
showLondon     = input.bool(true, "Mostrar sessão Londres", group=g_sweep)
showNY         = input.bool(true, "Mostrar sessão Nova Iorque", group=g_sweep)

// ---------- Order Blocks ----------
g_ob = "Order Blocks (com Inducement)"
showOB         = input.bool(true, "Ativar Order Blocks", group=g_ob)
showOBZones    = input.bool(true, "Mostrar zonas de OB", group=g_ob)
showOBSignals  = input.bool(true, "Mostrar sinais de entrada", group=g_ob)
showInducement = input.bool(true, "Mostrar Inducement", group=g_ob)
requireInducement = input.bool(false, "Ignorar OB sem Inducement", group=g_ob)
inducementMaxLookback = input.int(20, "Janela máxima p/ Inducement (barras)", minval=3, group=g_ob)
obSwingLen     = input.int(12, "Lookback para BOS (Order Block)", minval=2, group=g_ob)
maxOBAge       = input.int(200, "Idade máxima do OB (barras)", minval=20, group=g_ob)
minOBBoxWidth  = input.int(5, "Largura mínima visível do OB (barras)", minval=1, group=g_ob)
requireStrongBOS = input.bool(true, "Exigir BOS com impulso forte", group=g_ob)
bosImpulseMultiplier = input.float(2.0, "Múltiplo do corpo médio exigido", step=0.1, minval=1.0, group=g_ob)
bosAvgLookback = input.int(20, "Período da média de corpo (barras)", minval=5, group=g_ob)
consolidationLenInput = input.int(5, "Nº de velas p/ range de consolidação (Inducement)", minval=3, group=g_ob)
consolidationRangeMultInput = input.float(1.2, "Amplitude máx. do range (x ATR)", step=0.1, minval=0.3, group=g_ob)

// ---------- Gestão de Risco (comum) ----------
g_risk = "Gestão de Risco"
slBufferPips = input.float(2.0, "Buffer do SL (pips)", step=0.5, group=g_risk)
rrRatio      = input.float(2.0, "Risk/Reward (TP)", step=0.5, group=g_risk)

// ---------- Alertas ----------
g_alert = "Alertas"
enableAlerts     = input.bool(true, "Ativar Alertas", group=g_alert)
alertSweepToggle = input.bool(true, "Alertas - Liquidity Sweep", group=g_alert)
alertOBToggle    = input.bool(true, "Alertas - Order Blocks", group=g_alert)

// ============================================================
// CORES
// ============================================================
colSweep      = color.new(color.blue, 0)
colSweepZone  = color.new(color.blue, 85)
colBuy        = color.new(color.teal, 0)
colSell       = color.new(color.red, 0)
colOBBull     = color.new(color.gray, 30)
colOBBear     = color.new(color.gray, 30)
colOBBorder   = color.new(color.silver, 0)
colInducement = color.new(color.orange, 70)
colAsia       = color.new(color.aqua, 88)
colLondon     = color.new(color.purple, 88)
colNY         = color.new(color.yellow, 88)

// ============================================================
// FUNÇÕES AUXILIARES
// ============================================================
pipSize() =>
    syminfo.mintick * (syminfo.type == "forex" ? (syminfo.pointvalue >= 100 ? 1 : 10) : 1)

// Pip simplificado: usar mintick * 10 para a maioria dos pares forex (5 dígitos), ajustável visualmente
pip = syminfo.mintick * 10

// Padrões de candle ------------------------------------------------
isBullishEngulfing() =>
    close[1] < open[1] and close > open and close > open[1] and open < close[1]

isBearishEngulfing() =>
    close[1] > open[1] and close < open and close < open[1] and open > close[1]

isMorningStar() =>
    bear1 = close[2] < open[2]
    smallBody2 = math.abs(close[1] - open[1]) <= math.abs(close[2] - open[2]) * 0.5
    bull0 = close > open
    closesAboveMid = close > (open[2] + close[2]) / 2
    bear1 and smallBody2 and bull0 and closesAboveMid

isEveningStar() =>
    bull1 = close[2] > open[2]
    smallBody2 = math.abs(close[1] - open[1]) <= math.abs(close[2] - open[2]) * 0.5
    bear0 = close < open
    closesBelowMid = close < (open[2] + close[2]) / 2
    bull1 and smallBody2 and bear0 and closesBelowMid

bullishReversalPattern() => isBullishEngulfing() or isMorningStar()
bearishReversalPattern() => isBearishEngulfing() or isEveningStar()

// ============================================================
// ESTRATÉGIA 1: LIQUIDITY SWEEP + FAKEOUT
// ============================================================

// --- Swing highs/lows ---
swH = ta.pivothigh(high, swingLen, swingLen)
swL = ta.pivotlow(low, swingLen, swingLen)

var float[] swingHighs = array.new<float>()
var int[]   swingHighBars = array.new<int>()
var float[] swingLows  = array.new<float>()
var int[]   swingLowBars = array.new<int>()

if not na(swH)
    array.push(swingHighs, swH)
    array.push(swingHighBars, bar_index - swingLen)
    if array.size(swingHighs) > 50
        array.shift(swingHighs)
        array.shift(swingHighBars)

if not na(swL)
    array.push(swingLows, swL)
    array.push(swingLowBars, bar_index - swingLen)
    if array.size(swingLows) > 50
        array.shift(swingLows)
        array.shift(swingLowBars)

// --- Detetar Equal Highs / Equal Lows (par mais recente) ---
float eqhLevel = na
int eqhBar1 = na
int eqhBar2 = na
float eqlLevel = na
int eqlBar1 = na
int eqlBar2 = na

if array.size(swingHighs) >= 2
    float h1 = array.get(swingHighs, array.size(swingHighs) - 1)
    float h2 = array.get(swingHighs, array.size(swingHighs) - 2)
    if math.abs(h1 - h2) <= h1 * eqTolPct
        eqhLevel := math.max(h1, h2)
        eqhBar1 := array.get(swingHighBars, array.size(swingHighs) - 2)
        eqhBar2 := array.get(swingHighBars, array.size(swingHighs) - 1)

if array.size(swingLows) >= 2
    float l1 = array.get(swingLows, array.size(swingLows) - 1)
    float l2 = array.get(swingLows, array.size(swingLows) - 2)
    if math.abs(l1 - l2) <= l1 * eqTolPct
        eqlLevel := math.min(l1, l2)
        eqlBar1 := array.get(swingLowBars, array.size(swingLows) - 2)
        eqlBar2 := array.get(swingLowBars, array.size(swingLows) - 1)

// Desenhar EQH/EQL
var line eqhLine = na
var line eqlLine = na

if showSweep and showSweepZones and not na(eqhLevel)
    line.delete(eqhLine)
    eqhLine := line.new(eqhBar1, eqhLevel, bar_index + 10, eqhLevel, color=colSweep, style=line.style_dashed, width=1)

if showSweep and showSweepZones and not na(eqlLevel)
    line.delete(eqlLine)
    eqlLine := line.new(eqlBar1, eqlLevel, bar_index + 10, eqlLevel, color=colSweep, style=line.style_dashed, width=1)

// --- Sessões (Ásia / Londres / NY) - horário aproximado UTC ---
asiaTime   = time(timeframe.period, "0000-0900", "UTC")
londonTime = time(timeframe.period, "0700-1600", "UTC")
nyTime     = time(timeframe.period, "1200-2100", "UTC")

var float asiaHigh = na
var float asiaLow = na
var float londonHigh = na
var float londonLow = na
var float nyHigh = na
var float nyLow = na

inAsia   = not na(asiaTime)
inLondon = not na(londonTime)
inNY     = not na(nyTime)

if inAsia
    asiaHigh := na(asiaHigh) or high > asiaHigh ? high : asiaHigh
    asiaLow  := na(asiaLow) or low < asiaLow ? low : asiaLow
if not inAsia and inAsia[1]
    asiaHigh := na
    asiaLow := na

if inLondon
    londonHigh := na(londonHigh) or high > londonHigh ? high : londonHigh
    londonLow  := na(londonLow) or low < londonLow ? low : londonLow
if not inLondon and inLondon[1]
    londonHigh := na
    londonLow := na

if inNY
    nyHigh := na(nyHigh) or high > nyHigh ? high : nyHigh
    nyLow  := na(nyLow) or low < nyLow ? low : nyLow
if not inNY and inNY[1]
    nyHigh := na
    nyLow := na

bgcolor(showSweep and showSweepZones and showAsia and inAsia ? colAsia : na, title="Sessão Ásia")
bgcolor(showSweep and showSweepZones and showLondon and inLondon ? colLondon : na, title="Sessão Londres")
bgcolor(showSweep and showSweepZones and showNY and inNY ? colNY : na, title="Sessão Nova Iorque")

// --- Deteção de Sweep (mecha rompe EQH/EQL) ---
sweptHigh = not na(eqhLevel) and high > eqhLevel and close < eqhLevel
sweptLow  = not na(eqlLevel) and low < eqlLevel and close > eqlLevel

var bool waitingSellConfirm = false
var bool waitingBuyConfirm  = false
var float sweepExtremeHigh = na
var float sweepExtremeLow  = na

if sweptHigh
    waitingSellConfirm := true
    sweepExtremeHigh := high
if sweptLow
    waitingBuyConfirm := true
    sweepExtremeLow := low

// Atualizar extremo enquanto espera confirmação
if waitingSellConfirm and high > sweepExtremeHigh
    sweepExtremeHigh := high
if waitingBuyConfirm and low < sweepExtremeLow
    sweepExtremeLow := low

// Estado de trade ativo (Sweep) - evita sinais sobrepostos enquanto trade anterior não fechou
var bool sweepBuyTradeActive = false
var float sweepBuyActiveSL = na
var float sweepBuyActiveTP = na
var bool sweepSellTradeActive = false
var float sweepSellActiveSL = na
var float sweepSellActiveTP = na

if sweepBuyTradeActive
    if low <= sweepBuyActiveSL or high >= sweepBuyActiveTP
        sweepBuyTradeActive := false

if sweepSellTradeActive
    if high >= sweepSellActiveSL or low <= sweepSellActiveTP
        sweepSellTradeActive := false

// Confirmação de fakeout (só sinaliza se não houver trade ativo na mesma direção)
sweepSellSignal = waitingSellConfirm and bearishReversalPattern() and not sweepSellTradeActive
sweepBuySignal  = waitingBuyConfirm and bullishReversalPattern() and not sweepBuyTradeActive

if sweepSellSignal
    waitingSellConfirm := false
if sweepBuySignal
    waitingBuyConfirm := false

// Expirar espera de confirmação após muitas barras (evitar sinais antigos)
var int sweepSellAge = 0
var int sweepBuyAge = 0
sweepSellAge := waitingSellConfirm ? sweepSellAge + 1 : 0
sweepBuyAge  := waitingBuyConfirm ? sweepBuyAge + 1 : 0
if sweepSellAge > 10
    waitingSellConfirm := false
if sweepBuyAge > 10
    waitingBuyConfirm := false

// --- Cálculo SL/TP Sweep ---
sweepSellSL = sweepExtremeHigh + slBufferPips * pip
sweepSellTP = close - (sweepSellSL - close) * rrRatio
sweepBuySL  = sweepExtremeLow - slBufferPips * pip
sweepBuyTP  = close + (close - sweepBuySL) * rrRatio

if sweepSellSignal
    sweepSellTradeActive := true
    sweepSellActiveSL := sweepSellSL
    sweepSellActiveTP := sweepSellTP

if sweepBuySignal
    sweepBuyTradeActive := true
    sweepBuyActiveSL := sweepBuySL
    sweepBuyActiveTP := sweepBuyTP

// Deslocamento das labels de sinal, baseado em ATR, para não cobrir velas/mechas
labelOffset = ta.atr(14) * 1.5

// --- Plot sinais Sweep ---
if showSweep and showSweepSignals and sweepSellSignal
    label.new(bar_index, high + labelOffset, "SWEEP SELL\nSL: " + str.tostring(sweepSellSL, format.mintick) + "\nTP: " + str.tostring(sweepSellTP, format.mintick),
         style=label.style_label_down, color=colSell, textcolor=color.white, size=size.small)

if showSweep and showSweepSignals and sweepBuySignal
    label.new(bar_index, low - labelOffset, "SWEEP BUY\nSL: " + str.tostring(sweepBuySL, format.mintick) + "\nTP: " + str.tostring(sweepBuyTP, format.mintick),
         style=label.style_label_up, color=colBuy, textcolor=color.white, size=size.small)

// ============================================================
// ESTRATÉGIA 2: ORDER BLOCKS (com Inducement)
// ============================================================

obSwH = ta.pivothigh(high, obSwingLen, obSwingLen)
obSwL = ta.pivotlow(low, obSwingLen, obSwingLen)

var float lastSwingHighOB = na
var float lastSwingLowOB  = na

if not na(obSwH)
    lastSwingHighOB := obSwH
if not na(obSwL)
    lastSwingLowOB := obSwL

// BOS para cima / para baixo
bosUpRaw   = not na(lastSwingHighOB) and ta.crossover(close, lastSwingHighOB)
bosDownRaw = not na(lastSwingLowOB) and ta.crossunder(close, lastSwingLowOB)

// Filtro de impulso forte: o candle que confirma o BOS precisa de ter corpo maior que X vezes a média
candleBody = math.abs(close - open)
avgBody = ta.sma(math.abs(close - open), bosAvgLookback)
hasStrongImpulse = candleBody >= avgBody * bosImpulseMultiplier

bosUp   = bosUpRaw and (not requireStrongBOS or hasStrongImpulse)
bosDown = bosDownRaw and (not requireStrongBOS or hasStrongImpulse)

// Pivots de curto prazo, usados para identificar inducement (equal highs/lows formados por 2+ candles próximos)
inducementPivotLen = 2
minorPivH = ta.pivothigh(high, inducementPivotLen, inducementPivotLen)
minorPivL = ta.pivotlow(low, inducementPivotLen, inducementPivotLen)

var float[] minorHighs = array.new<float>()
var int[]   minorHighBars = array.new<int>()
var float[] minorLows  = array.new<float>()
var int[]   minorLowBars = array.new<int>()

if not na(minorPivH)
    array.push(minorHighs, minorPivH)
    array.push(minorHighBars, bar_index - inducementPivotLen)
    if array.size(minorHighs) > 30
        array.shift(minorHighs)
        array.shift(minorHighBars)

if not na(minorPivL)
    array.push(minorLows, minorPivL)
    array.push(minorLowBars, bar_index - inducementPivotLen)
    if array.size(minorLows) > 30
        array.shift(minorLows)
        array.shift(minorLowBars)

// Deteta se um nível faz parte de um par de equal highs/lows (2+ pivots próximos dentro da tolerância)
// Retorna o índice da barra do pivot mais recente desse par, ou na se não houver par válido
f_findEqualPairLow(maxBar) =>
    float foundLevel = na
    int foundBar = na
    if array.size(minorLows) >= 2
        for a = array.size(minorLows) - 1 to 0
            int barA = array.get(minorLowBars, a)
            if barA <= maxBar
                float levelA = array.get(minorLows, a)
                for b = a - 1 to 0
                    int barB = array.get(minorLowBars, b)
                    float levelB = array.get(minorLows, b)
                    if math.abs(levelA - levelB) <= levelA * eqTolPct
                        foundLevel := math.min(levelA, levelB)
                        foundBar := barA
                        break
                if not na(foundLevel)
                    break
    [foundLevel, foundBar]

f_findEqualPairHigh(maxBar) =>
    float foundLevel = na
    int foundBar = na
    if array.size(minorHighs) >= 2
        for a = array.size(minorHighs) - 1 to 0
            int barA = array.get(minorHighBars, a)
            if barA <= maxBar
                float levelA = array.get(minorHighs, a)
                for b = a - 1 to 0
                    int barB = array.get(minorHighBars, b)
                    float levelB = array.get(minorHighs, b)
                    if math.abs(levelA - levelB) <= levelA * eqTolPct
                        foundLevel := math.max(levelA, levelB)
                        foundBar := barA
                        break
                if not na(foundLevel)
                    break
    [foundLevel, foundBar]

// Deteta um pequeno range de consolidação (N candles consecutivos com amplitude estreita) antes de maxBar
// Serve como forma alternativa de inducement: não exige 2 fundos/topos idênticos, só uma "pausa" no mercado
consolidationLen = consolidationLenInput
consolidationMaxRangeATRMult = consolidationRangeMultInput
f_findConsolidationLow(maxBar) =>
    float foundLevel = na
    int foundBar = na
    int startSearch = maxBar - inducementMaxLookback
    if startSearch < 0
        startSearch := 0
    float atrRef = ta.atr(14)
    for endBar = maxBar to startSearch + consolidationLen
        int beginBar = endBar - consolidationLen + 1
        if beginBar >= 0
            int offsetEnd = bar_index - endBar
            float rangeHigh = high[offsetEnd]
            float rangeLow  = low[offsetEnd]
            for k = beginBar to endBar
                int offsetK = bar_index - k
                rangeHigh := math.max(rangeHigh, high[offsetK])
                rangeLow := math.min(rangeLow, low[offsetK])
            if (rangeHigh - rangeLow) <= atrRef * consolidationMaxRangeATRMult
                foundLevel := rangeLow
                foundBar := endBar
                break
    [foundLevel, foundBar]

f_findConsolidationHigh(maxBar) =>
    float foundLevel = na
    int foundBar = na
    int startSearch = maxBar - inducementMaxLookback
    if startSearch < 0
        startSearch := 0
    float atrRef = ta.atr(14)
    for endBar = maxBar to startSearch + consolidationLen
        int beginBar = endBar - consolidationLen + 1
        if beginBar >= 0
            int offsetEnd = bar_index - endBar
            float rangeHigh = high[offsetEnd]
            float rangeLow  = low[offsetEnd]
            for k = beginBar to endBar
                int offsetK = bar_index - k
                rangeHigh := math.max(rangeHigh, high[offsetK])
                rangeLow := math.min(rangeLow, low[offsetK])
            if (rangeHigh - rangeLow) <= atrRef * consolidationMaxRangeATRMult
                foundLevel := rangeHigh
                foundBar := endBar
                break
    [foundLevel, foundBar]

// Estruturas para guardar Order Blocks ativos
var box[] obBoxes   = array.new<box>()
var line[] obKeyLines = array.new<line>()
var int[] obBarIdx   = array.new<int>()
var float[] obTop    = array.new<float>()
var float[] obBottom = array.new<float>()
var bool[] obIsBullOrigin = array.new<bool>() // true = OB de origem bullish (procura compra), false = bearish origin (procura venda)
var bool[] obMitigated = array.new<bool>()
var float[] obMinorLiquidity = array.new<float>() // nível de inducement associado (minor high/low entre o início do movimento e o OB)
var bool[] obInducementSwept = array.new<bool>()
var bool[] obHasInducement = array.new<bool>() // se foi encontrado um inducement válido na origem do OB

// Quando há BOS para cima -> procurar última vela bearish antes do impulso (OB bullish-origin, procura-se compra na mitigação)
if bosUp
    int idx = na
    float obHigh = na
    float obLow = na
    for i = 1 to 15
        if close[i] < open[i]
            idx := bar_index - i
            obHigh := high[i]
            obLow := low[i]
            break
    if not na(idx)
        // Inducement para OB bullish-origin: procurar primeiro um EQUAL LOW (2+ pivots próximos)
        // Se não encontrar, tentar um range de consolidação (4-5 candles numa banda estreita)
        [eqLowLevel, eqLowBar] = f_findEqualPairLow(idx - 1)
        float inducementLevel = na
        int inducementBar = na
        if not na(eqLowLevel) and eqLowBar >= idx - inducementMaxLookback
            inducementLevel := eqLowLevel
            inducementBar := eqLowBar
        else
            [consLowLevel, consLowBar] = f_findConsolidationLow(idx - 1)
            if not na(consLowLevel)
                inducementLevel := consLowLevel
                inducementBar := consLowBar
        bool obHasInducementBull = not na(inducementLevel)
        bool drawThisOB = not requireInducement or obHasInducementBull
        box newBox = drawThisOB ? box.new(idx, obHigh, bar_index, obLow, border_color=colOBBorder, border_width=2, bgcolor=colOBBull, extend=extend.right) : box.new(idx, obHigh, bar_index, obLow, border_color=color.new(color.gray,100), bgcolor=color.new(color.gray,100), extend=extend.none)
        line newLine = drawThisOB ? line.new(idx, obHigh, bar_index + 10, obHigh, color=colOBBorder, style=line.style_dashed, width=1) : line.new(idx, obHigh, bar_index, obHigh, color=color.new(color.gray,100))
        array.push(obBoxes, newBox)
        array.push(obKeyLines, newLine)
        array.push(obBarIdx, idx)
        array.push(obTop, obHigh)
        array.push(obBottom, obLow)
        array.push(obIsBullOrigin, true)
        array.push(obMitigated, false)
        array.push(obMinorLiquidity, na(inducementLevel) ? obLow : inducementLevel)
        array.push(obInducementSwept, false)
        array.push(obHasInducement, obHasInducementBull)
        if showOB and showInducement and not na(inducementLevel)
            label.new(inducementBar, inducementLevel, "Inducement", style=label.style_label_up, color=colInducement, textcolor=color.black, size=size.tiny)

// Quando há BOS para baixo -> procurar última vela bullish antes do impulso (OB bearish-origin, procura-se venda na mitigação)
if bosDown
    int idx = na
    float obHigh = na
    float obLow = na
    for i = 1 to 15
        if close[i] > open[i]
            idx := bar_index - i
            obHigh := high[i]
            obLow := low[i]
            break
    if not na(idx)
        // Inducement para OB bearish-origin: procurar primeiro um EQUAL HIGH (2+ pivots próximos)
        // Se não encontrar, tentar um range de consolidação (4-5 candles numa banda estreita)
        [eqHighLevel, eqHighBar] = f_findEqualPairHigh(idx - 1)
        float inducementLevel = na
        int inducementBar = na
        if not na(eqHighLevel) and eqHighBar >= idx - inducementMaxLookback
            inducementLevel := eqHighLevel
            inducementBar := eqHighBar
        else
            [consHighLevel, consHighBar] = f_findConsolidationHigh(idx - 1)
            if not na(consHighLevel)
                inducementLevel := consHighLevel
                inducementBar := consHighBar
        bool obHasInducementBear = not na(inducementLevel)
        bool drawThisOBBear = not requireInducement or obHasInducementBear
        box newBoxBear = drawThisOBBear ? box.new(idx, obHigh, bar_index, obLow, border_color=colOBBorder, border_width=2, bgcolor=colOBBear, extend=extend.right) : box.new(idx, obHigh, bar_index, obLow, border_color=color.new(color.gray,100), bgcolor=color.new(color.gray,100), extend=extend.none)
        line newLineBear = drawThisOBBear ? line.new(idx, obLow, bar_index + 10, obLow, color=colOBBorder, style=line.style_dashed, width=1) : line.new(idx, obLow, bar_index, obLow, color=color.new(color.gray,100))
        array.push(obBoxes, newBoxBear)
        array.push(obKeyLines, newLineBear)
        array.push(obBarIdx, idx)
        array.push(obTop, obHigh)
        array.push(obBottom, obLow)
        array.push(obIsBullOrigin, false)
        array.push(obMitigated, false)
        array.push(obMinorLiquidity, na(inducementLevel) ? obHigh : inducementLevel)
        array.push(obInducementSwept, false)
        array.push(obHasInducement, obHasInducementBear)
        if showOB and showInducement and not na(inducementLevel)
            label.new(inducementBar, inducementLevel, "Inducement", style=label.style_label_down, color=colInducement, textcolor=color.black, size=size.tiny)

// Gerir OBs: detetar inducement varrido, mitigação, sinais e expiração
obBuySignal = false
obSellSignal = false
float obBuySL = na
float obBuyTP = na
float obSellSL = na
float obSellTP = na

obBuySignalPremium = false
obSellSignalPremium = false

// Estado de trade ativo (evita sinais sobrepostos enquanto um trade anterior ainda não fechou)
var bool obBuyTradeActive = false
var float obBuyActiveSL = na
var float obBuyActiveTP = na
var bool obSellTradeActive = false
var float obSellActiveSL = na
var float obSellActiveTP = na

// Verificar se o trade de compra ativo já atingiu SL ou TP
if obBuyTradeActive
    if low <= obBuyActiveSL or high >= obBuyActiveTP
        obBuyTradeActive := false

// Verificar se o trade de venda ativo já atingiu SL ou TP
if obSellTradeActive
    if high >= obSellActiveSL or low <= obSellActiveTP
        obSellTradeActive := false

if array.size(obBoxes) > 0
    for i = array.size(obBoxes) - 1 to 0
        b   = array.get(obBoxes, i)
        kl  = array.get(obKeyLines, i)
        top = array.get(obTop, i)
        bot = array.get(obBottom, i)
        isBullOrigin = array.get(obIsBullOrigin, i)
        mitigated = array.get(obMitigated, i)
        startBar = array.get(obBarIdx, i)
        minorLiq = array.get(obMinorLiquidity, i)
        inducementSwept = array.get(obInducementSwept, i)
        hasInducement = array.get(obHasInducement, i)

        // Remover OBs muito antigos
        if (bar_index - startBar) > maxOBAge
            box.delete(b)
            line.delete(kl)
            array.remove(obBoxes, i)
            array.remove(obKeyLines, i)
            array.remove(obBarIdx, i)
            array.remove(obTop, i)
            array.remove(obBottom, i)
            array.remove(obIsBullOrigin, i)
            array.remove(obMitigated, i)
            array.remove(obMinorLiquidity, i)
            array.remove(obInducementSwept, i)
            array.remove(obHasInducement, i)
            continue

        if not mitigated
            // Verificar inducement varrido (liquidez menor entre o início do movimento e o OB)
            if hasInducement and not inducementSwept
                if isBullOrigin and low <= minorLiq
                    array.set(obInducementSwept, i, true)
                if not isBullOrigin and high >= minorLiq
                    array.set(obInducementSwept, i, true)

            // Mitigação: preço toca na zona do OB
            touchedOB = low <= top and high >= bot

            // Só gera sinal se NÃO houver já um trade ativo na mesma direção
            // E (se exigido) o OB tiver inducement válido e já varrido
            bool meetsInducementRule = not requireInducement or (hasInducement and inducementSwept)
            bool canSignal = ((isBullOrigin and not obBuyTradeActive) or (not isBullOrigin and not obSellTradeActive)) and meetsInducementRule

            if touchedOB and canSignal
                array.set(obMitigated, i, true)
                bool wasPremium = hasInducement and array.get(obInducementSwept, i)
                if isBullOrigin
                    obBuySignal := true
                    obBuySL := bot - slBufferPips * pip
                    obBuyTP := close + (close - obBuySL) * rrRatio
                    obBuySignalPremium := wasPremium
                    obBuyTradeActive := true
                    obBuyActiveSL := obBuySL
                    obBuyActiveTP := obBuyTP
                else
                    obSellSignal := true
                    obSellSL := top + slBufferPips * pip
                    obSellTP := close - (obSellSL - close) * rrRatio
                    obSellSignalPremium := wasPremium
                    obSellTradeActive := true
                    obSellActiveSL := obSellSL
                    obSellActiveTP := obSellTP

                if showOB and showOBZones
                    int rightEdge = math.max(bar_index, startBar + minOBBoxWidth)
                    box.set_right(b, rightEdge)
                    box.set_extend(b, extend.none)
                    line.set_x2(kl, rightEdge)
                    line.set_extend(kl, extend.none)
            else if touchedOB and not canSignal
                // Marca como mitigado mesmo sem gerar sinal, para não voltar a testar esta zona repetidamente
                array.set(obMitigated, i, true)
                if showOB and showOBZones
                    int rightEdge2 = math.max(bar_index, startBar + minOBBoxWidth)
                    box.set_right(b, rightEdge2)
                    box.set_extend(b, extend.none)
                    line.set_x2(kl, rightEdge2)
                    line.set_extend(kl, extend.none)

// --- Plot sinais OB ---
if showOB and showOBSignals and obBuySignal
    label.new(bar_index, low - labelOffset, (obBuySignalPremium ? "OB BUY ⭐ PREMIUM\n" : "OB BUY\n") + "SL: " + str.tostring(obBuySL, format.mintick) + "\nTP: " + str.tostring(obBuyTP, format.mintick),
         style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

if showOB and showOBSignals and obSellSignal
    label.new(bar_index, high + labelOffset, (obSellSignalPremium ? "OB SELL ⭐ PREMIUM\n" : "OB SELL\n") + "SL: " + str.tostring(obSellSL, format.mintick) + "\nTP: " + str.tostring(obSellTP, format.mintick),
         style=label.style_label_down, color=color.new(color.maroon, 0), textcolor=color.white, size=size.small)

// Ocultar zonas OB se utilizador desativar
if not showOB or not showOBZones
    if array.size(obBoxes) > 0
        for i = 0 to array.size(obBoxes) - 1
            box.set_border_color(array.get(obBoxes, i), color.new(color.gray, 100))
            box.set_bgcolor(array.get(obBoxes, i), color.new(color.gray, 100))
            line.set_color(array.get(obKeyLines, i), color.new(color.gray, 100))

// ============================================================
// ALERTAS
// ============================================================
alertcondition(enableAlerts and alertSweepToggle and sweepBuySignal, title="Sweep BUY", message="LIQUIDITY SWEEP - Sinal de COMPRA em {{ticker}} ({{interval}}).")
alertcondition(enableAlerts and alertSweepToggle and sweepSellSignal, title="Sweep SELL", message="LIQUIDITY SWEEP - Sinal de VENDA em {{ticker}} ({{interval}}).")
alertcondition(enableAlerts and alertOBToggle and obBuySignal, title="OB BUY", message="ORDER BLOCK - Sinal de COMPRA em {{ticker}} ({{interval}}).")
alertcondition(enableAlerts and alertOBToggle and obSellSignal, title="OB SELL", message="ORDER BLOCK - Sinal de VENDA em {{ticker}} ({{interval}}).")
````
