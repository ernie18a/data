# Mani_Legit Script (Like and follow if it helps you)

- url: https://www.tradingview.com/script/Qe36iJo8-Mani-Legit-Script-Like-and-follow-if-it-helps-you/
- type: indicator
- pine_id: PUB;5a37845d3ba749c7b762880a73bafcc9
- version: 1.0

## Description

Mani_Legit is an advanced all-in-one trading indicator built for traders looking for cleaner market structure, trend confirmation, liquidity concepts, and AI-style confluence in one system. It includes multiple customizable tools and visual options that can be turned on or off depending on your trading style.

This script was designed to help simplify chart analysis while giving traders more flexibility and control over their setups. Explore the settings, test what works best for you, and make it your own.

If this indicator helps you, consider leaving a like and following my account for future updates. Thank you and trade safe.

## Source Code

````pine
//@version=5
indicator("Mani_Legit", overlay=true, max_labels_count=500, max_lines_count=300, max_boxes_count=100)

//━━━━━━━━ INPUTS
fastLen = input.int(21, "Fast EMA")
slowLen = input.int(50, "Slow EMA")
trendLen = input.int(100, "Main Trend EMA")
rsiLen = input.int(14, "RSI Length")
atrLen = input.int(14, "ATR Length")
pivotLen = input.int(6, "Pivot Strength")
maxLevels = input.int(5, "Max Past S/R Levels", minval=2, maxval=10)

showCloud = input.bool(true, "Show Trend Cloud")
showCandleColors = input.bool(true, "Show Smart Candle Colors")
showBOS = input.bool(true, "Show BOS / CHoCH")
showSignals = input.bool(true, "Show AI Buy/Sell Signals")
showHistSR = input.bool(true, "Show Past Support/Resistance")
showTrendline = input.bool(true, "Show Auto Trendlines")
showSweeps = input.bool(true, "Show Liquidity Sweeps")
showFVG = input.bool(true, "Show Fair Value Gaps")
showKillzones = input.bool(true, "Show Killzones")
showRejections = input.bool(true, "Show Rejection Wicks")
showPremiumDisc = input.bool(true, "Show Premium/Discount")
showDashboard = input.bool(true, "Show Dashboard")
showRiskLevels = input.bool(true, "Show Auto SL / TP")
showEMAs = input.bool(false, "Show EMAs")

showSupertrend = input.bool(true, "Show SuperTrend Extension")
showOrderBlocks = input.bool(true, "Show SMC Order Blocks")
showVolZones = input.bool(true, "Show Volume Supply/Demand Zones")
showLiqSwings = input.bool(true, "Show Liquidity Swing Clusters")
showWaveEngine = input.bool(true, "Show Wave Engine Labels")
showHeatmap = input.bool(true, "Show Heatmap Candles")

stAtrLen = input.int(10, "SuperTrend ATR Length")
stFactor = input.float(3.0, "SuperTrend Factor")
maxZones = input.int(4, "Max OB / Volume Zones", minval=1, maxval=10)
liqToleranceAtr = input.float(0.25, "Liquidity Equal High/Low ATR Tolerance")

useNewsFilter = input.bool(true, "Use News Blackout Filter")
newsSession = input.session("0830-0900", "News Blackout Time NY")
riskAtrMult = input.float(1.5, "Stop Loss ATR Multiplier")
tp1RR = input.float(1.0, "TP1 RR")
tp2RR = input.float(2.0, "TP2 RR")
tp3RR = input.float(3.0, "TP3 RR")
htfTf = input.timeframe("240", "Higher Timeframe Bias")

//━━━━━━━━ CORE
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
emaTrend = ta.ema(close, trendLen)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
vwapVal = ta.vwap(close)

bullTrend = emaFast > emaSlow and close > emaTrend
bearTrend = emaFast < emaSlow and close < emaTrend
neutralTrend = not bullTrend and not bearTrend

//━━━━━━━━ CANDLE METRICS
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
candleRange = high - low
bodyPercent = candleRange > 0 ? body / candleRange : 0.0
strongCandle = bodyPercent > 0.65 and candleRange > atr

//━━━━━━━━ ADX / MOMENTUM / PRESSURE
[plusDI, minusDI, adx] = ta.dmi(14, 14)
strongTrend = adx > 25
weakTrend = adx < 20
momentum = ta.ema(close - close[5], 5)
volSma = ta.sma(volume, 20)
volExpansion = atr > ta.sma(atr, 20)
bullPressure = close > open and volume > volSma
bearPressure = close < open and volume > volSma

//━━━━━━━━ SUPER TREND EXTENSION
[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
stBull = close > stLine
stBear = close < stLine
plot(showSupertrend ? stLine : na, "SuperTrend Extension", color=stBull ? color.lime : color.red, linewidth=2)

//━━━━━━━━ SMART CANDLES / HEATMAP
heatBull = momentum > 0 and bullPressure and volExpansion
heatBear = momentum < 0 and bearPressure and volExpansion
candleColor = showHeatmap and heatBull ? color.aqua : showHeatmap and heatBear ? color.fuchsia : bullTrend and close > open ? color.lime : bearTrend and close < open ? color.red : neutralTrend ? color.white : bullTrend ? color.green : bearTrend ? color.maroon : color.gray
barcolor(showCandleColors ? candleColor : na)

//━━━━━━━━ CLOUD / EMAS
cloudColor = bullTrend ? color.new(color.green, 82) : bearTrend ? color.new(color.red, 82) : color.new(color.white, 88)
p1 = plot(showCloud ? emaFast : na, display=display.none)
p2 = plot(showCloud ? emaSlow : na, display=display.none)
fill(p1, p2, color=cloudColor)
plot(showEMAs ? emaFast : na, "Fast EMA", color=color.green, linewidth=2)
plot(showEMAs ? emaSlow : na, "Slow EMA", color=color.red, linewidth=2)
plot(showEMAs ? emaTrend : na, "Trend EMA", color=color.white, linewidth=2)

//━━━━━━━━ HTF BIAS
htfFast = request.security(syminfo.tickerid, htfTf, ta.ema(close, fastLen))
htfSlow = request.security(syminfo.tickerid, htfTf, ta.ema(close, slowLen))
htfBull = htfFast > htfSlow
htfBear = htfFast < htfSlow
m15Fast = request.security(syminfo.tickerid, "15", ta.ema(close, fastLen))
m15Slow = request.security(syminfo.tickerid, "15", ta.ema(close, slowLen))
h1Fast = request.security(syminfo.tickerid, "60", ta.ema(close, fastLen))
h1Slow = request.security(syminfo.tickerid, "60", ta.ema(close, slowLen))
h4Fast = request.security(syminfo.tickerid, "240", ta.ema(close, fastLen))
h4Slow = request.security(syminfo.tickerid, "240", ta.ema(close, slowLen))
m15Bull = m15Fast > m15Slow
h1Bull = h1Fast > h1Slow
h4Bull = h4Fast > h4Slow

//━━━━━━━━ KILLZONES / NEWS
london = not na(time(timeframe.period, "0000-0900", "America/New_York"))
ny = not na(time(timeframe.period, "0700-1600", "America/New_York"))
overlap = london and ny
bgcolor(showKillzones and overlap ? color.new(color.yellow, 88) : na)
bgcolor(showKillzones and london and not overlap ? color.new(color.blue, 93) : na)
bgcolor(showKillzones and ny and not overlap ? color.new(color.green, 93) : na)
inNewsBlackout = not na(time(timeframe.period, newsSession, "America/New_York"))
newsAllowed = not useNewsFilter or not inNewsBlackout

//━━━━━━━━ PIVOTS
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
pivotHighBar = bar_index - pivotLen
pivotLowBar = bar_index - pivotLen

//━━━━━━━━ HISTORICAL S/R
var line[] resLines = array.new_line()
var line[] supLines = array.new_line()
if showHistSR and not na(ph)
    newRes = line.new(pivotHighBar, ph, bar_index, ph, extend=extend.right, color=color.new(color.red, 20), width=2)
    array.push(resLines, newRes)
    if array.size(resLines) > maxLevels
        line.delete(array.shift(resLines))
if showHistSR and not na(pl)
    newSup = line.new(pivotLowBar, pl, bar_index, pl, extend=extend.right, color=color.new(color.green, 20), width=2)
    array.push(supLines, newSup)
    if array.size(supLines) > maxLevels
        line.delete(array.shift(supLines))

//━━━━━━━━ TRENDLINES
var float high1 = na
var float high2 = na
var int highBar1 = na
var int highBar2 = na
var float low1 = na
var float low2 = na
var int lowBar1 = na
var int lowBar2 = na
var line downTrend = na
var line upTrend = na
if not na(ph)
    high2 := high1
    highBar2 := highBar1
    high1 := ph
    highBar1 := pivotHighBar
    if showTrendline and not na(high2)
        if not na(downTrend)
            line.delete(downTrend)
        downTrend := line.new(highBar2, high2, highBar1, high1, extend=extend.right, color=color.red, width=2)
if not na(pl)
    low2 := low1
    lowBar2 := lowBar1
    low1 := pl
    lowBar1 := pivotLowBar
    if showTrendline and not na(low2)
        if not na(upTrend)
            line.delete(upTrend)
        upTrend := line.new(lowBar2, low2, lowBar1, low1, extend=extend.right, color=color.green, width=2)

//━━━━━━━━ BOS / CHOCH
var float lastHigh = na
var float lastLow = na
var int marketState = 0
if not na(ph)
    lastHigh := ph
if not na(pl)
    lastLow := pl
bullBreak = not na(lastHigh) and ta.crossover(close, lastHigh)
bearBreak = not na(lastLow) and ta.crossunder(close, lastLow)
bullCHoCH = bullBreak and marketState == -1
bearCHoCH = bearBreak and marketState == 1
bullBOS = bullBreak and marketState != -1
bearBOS = bearBreak and marketState != 1
if bullBreak
    marketState := 1
if bearBreak
    marketState := -1
if showBOS and bullBOS
    label.new(bar_index, high, "BOS ↑", style=label.style_label_down, color=color.green, textcolor=color.white)
if showBOS and bearBOS
    label.new(bar_index, low, "BOS ↓", style=label.style_label_up, color=color.red, textcolor=color.white)
if showBOS and bullCHoCH
    label.new(bar_index, high, "CHoCH ↑", style=label.style_label_down, color=color.lime, textcolor=color.black)
if showBOS and bearCHoCH
    label.new(bar_index, low, "CHoCH ↓", style=label.style_label_up, color=color.orange, textcolor=color.black)

//━━━━━━━━ SWEEPS
sweepHigh = not na(lastHigh) and high > lastHigh and close < lastHigh
sweepLow = not na(lastLow) and low < lastLow and close > lastLow
if showSweeps and sweepHigh
    label.new(bar_index, high, "Sweep ↓", style=label.style_label_down, color=color.red, textcolor=color.white)
if showSweeps and sweepLow
    label.new(bar_index, low, "Sweep ↑", style=label.style_label_up, color=color.green, textcolor=color.white)

//━━━━━━━━ LIQUIDITY SWING CLUSTERS / EQUAL HIGHS LOWS
var float prevSwingHigh = na
var float prevSwingLow = na
var line eqHighLine = na
var line eqLowLine = na
eqHigh = false
eqLow = false
if showLiqSwings and not na(ph)
    eqHigh := not na(prevSwingHigh) and math.abs(ph - prevSwingHigh) <= atr * liqToleranceAtr
    if eqHigh
        if not na(eqHighLine)
            line.delete(eqHighLine)
        eqHighLine := line.new(pivotHighBar, ph, bar_index + 80, ph, extend=extend.right, color=color.new(color.red, 0), width=2, style=line.style_dotted)
        label.new(pivotHighBar, ph, "EQH / Buy-side Liq", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)
    prevSwingHigh := ph
if showLiqSwings and not na(pl)
    eqLow := not na(prevSwingLow) and math.abs(pl - prevSwingLow) <= atr * liqToleranceAtr
    if eqLow
        if not na(eqLowLine)
            line.delete(eqLowLine)
        eqLowLine := line.new(pivotLowBar, pl, bar_index + 80, pl, extend=extend.right, color=color.new(color.green, 0), width=2, style=line.style_dotted)
        label.new(pivotLowBar, pl, "EQL / Sell-side Liq", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)
    prevSwingLow := pl

//━━━━━━━━ FVG
bullFVG = low > high[2]
bearFVG = high < low[2]
if showFVG and bullFVG
    box.new(bar_index - 2, high[2], bar_index + 20, low, bgcolor=color.new(color.green, 88), border_color=color.new(color.green, 50))
if showFVG and bearFVG
    box.new(bar_index - 2, low[2], bar_index + 20, high, bgcolor=color.new(color.red, 88), border_color=color.new(color.red, 50))

//━━━━━━━━ SMC ORDER BLOCKS
var box[] bullOBs = array.new_box()
var box[] bearOBs = array.new_box()
bullOBSignal = showOrderBlocks and bullBreak and close[1] < open[1]
bearOBSignal = showOrderBlocks and bearBreak and close[1] > open[1]
if bullOBSignal
    ob = box.new(bar_index - 1, open[1], bar_index + 60, low[1], bgcolor=color.new(color.green, 86), border_color=color.new(color.green, 35))
    array.push(bullOBs, ob)
    if array.size(bullOBs) > maxZones
        box.delete(array.shift(bullOBs))
if bearOBSignal
    ob = box.new(bar_index - 1, high[1], bar_index + 60, open[1], bgcolor=color.new(color.red, 86), border_color=color.new(color.red, 35))
    array.push(bearOBs, ob)
    if array.size(bearOBs) > maxZones
        box.delete(array.shift(bearOBs))

//━━━━━━━━ VOLUME SUPPLY / DEMAND ZONES
var box[] demandZones = array.new_box()
var box[] supplyZones = array.new_box()
highVol = volume > volSma * 1.8
demandZoneSignal = showVolZones and highVol and close > open and lowerWick > body * 0.75
supplyZoneSignal = showVolZones and highVol and close < open and upperWick > body * 0.75
if demandZoneSignal
    dz = box.new(bar_index, math.min(open, close), bar_index + 80, low, bgcolor=color.new(color.aqua, 88), border_color=color.new(color.aqua, 45))
    array.push(demandZones, dz)
    if array.size(demandZones) > maxZones
        box.delete(array.shift(demandZones))
if supplyZoneSignal
    sz = box.new(bar_index, high, bar_index + 80, math.max(open, close), bgcolor=color.new(color.fuchsia, 88), border_color=color.new(color.fuchsia, 45))
    array.push(supplyZones, sz)
    if array.size(supplyZones) > maxZones
        box.delete(array.shift(supplyZones))

//━━━━━━━━ REJECTIONS
bullReject = showRejections and lowerWick > body * 2 and close > open
bearReject = showRejections and upperWick > body * 2 and close < open
plotshape(bullReject, title="Bullish Rejection", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny, text="RJ")
plotshape(bearReject, title="Bearish Rejection", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, text="RJ")

//━━━━━━━━ PREMIUM / DISCOUNT
rangeHigh = ta.highest(high, 100)
rangeLow = ta.lowest(low, 100)
eqLevel = (rangeHigh + rangeLow) / 2
plot(showPremiumDisc ? eqLevel : na, "Equilibrium 50%", color=color.new(color.white, 40), linewidth=1)
premium = close > eqLevel
discount = close < eqLevel

//━━━━━━━━ WAVE ENGINE
waveFast = ta.ema(close, 8) - ta.ema(close, 21)
waveSlow = ta.ema(waveFast, 9)
waveBull = waveFast > waveSlow and waveFast > 0
waveBear = waveFast < waveSlow and waveFast < 0
waveFlipBull = ta.crossover(waveFast, waveSlow)
waveFlipBear = ta.crossunder(waveFast, waveSlow)
if showWaveEngine and waveFlipBull
    label.new(bar_index, low - atr * 0.8, "Wave ↑", style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.tiny)
if showWaveEngine and waveFlipBear
    label.new(bar_index, high + atr * 0.8, "Wave ↓", style=label.style_label_down, color=color.fuchsia, textcolor=color.white, size=size.tiny)

//━━━━━━━━ AI SCORE
aiScore = ((bullTrend or bearTrend) ? 10 : 0) + (strongTrend ? 12 : 0) + (((htfBull and bullTrend) or (htfBear and bearTrend)) ? 12 : 0) + (volExpansion ? 8 : 0) + ((bullPressure or bearPressure) ? 8 : 0) + (overlap ? 8 : 0) + ((bullBreak or bearBreak) ? 10 : 0) + ((sweepHigh or sweepLow) ? 8 : 0) + ((bullFVG or bearFVG) ? 6 : 0) + ((bullOBSignal or bearOBSignal) ? 7 : 0) + ((demandZoneSignal or supplyZoneSignal) ? 6 : 0) + ((eqHigh or eqLow) ? 5 : 0) + (((waveBull and bullTrend) or (waveBear and bearTrend)) ? 6 : 0) + (((stBull and bullTrend) or (stBear and bearTrend)) ? 6 : 0) + (strongCandle ? 5 : 0) + (newsAllowed ? 8 : -25)
aiProbability = aiScore >= 85 ? "VERY HIGH" : aiScore >= 70 ? "HIGH" : aiScore >= 55 ? "MEDIUM" : aiScore >= 40 ? "LOW" : "NO TRADE"
aiColor = aiScore >= 85 ? color.green : aiScore >= 70 ? color.lime : aiScore >= 55 ? color.orange : color.red

//━━━━━━━━ SIGNALS
baseBuySignal = bullTrend and rsi > 50 and close > vwapVal and htfBull and strongTrend and discount and stBull and waveBull
baseSellSignal = bearTrend and rsi < 50 and close < vwapVal and htfBear and strongTrend and premium and stBear and waveBear
entryTriggerBuy = bullBreak or sweepLow or bullReject or demandZoneSignal
entryTriggerSell = bearBreak or sweepHigh or bearReject or supplyZoneSignal
finalBuySignal = showSignals and baseBuySignal and entryTriggerBuy and newsAllowed and aiScore >= 70
finalSellSignal = showSignals and baseSellSignal and entryTriggerSell and newsAllowed and aiScore >= 70
if finalBuySignal
    label.new(bar_index, low - atr * 1.5, "AI BUY\n" + aiProbability + "\n" + str.tostring(aiScore) + "%", style=label.style_label_up, color=color.green, textcolor=color.white)
if finalSellSignal
    label.new(bar_index, high + atr * 1.5, "AI SELL\n" + aiProbability + "\n" + str.tostring(aiScore) + "%", style=label.style_label_down, color=color.red, textcolor=color.white)

//━━━━━━━━ AUTO SL / TP
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
if showRiskLevels and (finalBuySignal or finalSellSignal)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)
    if not na(tp3Label)
        label.delete(tp3Label)
    entryPrice = close
    riskAmount = atr * riskAtrMult
    stopPrice = finalBuySignal ? entryPrice - riskAmount : entryPrice + riskAmount
    take1 = finalBuySignal ? entryPrice + riskAmount * tp1RR : entryPrice - riskAmount * tp1RR
    take2 = finalBuySignal ? entryPrice + riskAmount * tp2RR : entryPrice - riskAmount * tp2RR
    take3 = finalBuySignal ? entryPrice + riskAmount * tp3RR : entryPrice - riskAmount * tp3RR
    slLine := line.new(bar_index, stopPrice, bar_index + 50, stopPrice, extend=extend.right, color=color.red, width=2)
    tp1Line := line.new(bar_index, take1, bar_index + 50, take1, extend=extend.right, color=color.green, width=1)
    tp2Line := line.new(bar_index, take2, bar_index + 50, take2, extend=extend.right, color=color.green, width=2)
    tp3Line := line.new(bar_index, take3, bar_index + 50, take3, extend=extend.right, color=color.lime, width=2)
    slLabel := label.new(bar_index + 5, stopPrice, "SL", style=label.style_label_left, color=color.red, textcolor=color.white)
    tp1Label := label.new(bar_index + 5, take1, "TP1", style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Label := label.new(bar_index + 5, take2, "TP2", style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Label := label.new(bar_index + 5, take3, "TP3", style=label.style_label_left, color=color.lime, textcolor=color.black)

//━━━━━━━━ DASHBOARD
var table dash = table.new(position.top_right, 2, 12)
trendText = bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "NEUTRAL"
trendTableColor = bullTrend ? color.green : bearTrend ? color.red : color.gray
adxText = strongTrend ? "STRONG" : weakTrend ? "WEAK" : "MEDIUM"
adxColor = strongTrend ? color.green : weakTrend ? color.red : color.orange
momText = momentum > 0 ? "BULL MOMENTUM" : momentum < 0 ? "BEAR MOMENTUM" : "FLAT"
momColor = momentum > 0 ? color.green : momentum < 0 ? color.red : color.gray
pressureText = bullPressure ? "BUY PRESSURE" : bearPressure ? "SELL PRESSURE" : "NORMAL"
pressureColor = bullPressure ? color.green : bearPressure ? color.red : color.gray
volText = volExpansion ? "EXPANDING" : "NORMAL"
volColor = volExpansion ? color.orange : color.gray
zoneText = premium ? "PREMIUM" : discount ? "DISCOUNT" : "EQ"
zoneColor = premium ? color.red : discount ? color.green : color.gray
mtfText = "15M " + (m15Bull ? "UP" : "DOWN") + " | 1H " + (h1Bull ? "UP" : "DOWN") + " | 4H " + (h4Bull ? "UP" : "DOWN")
killText = inNewsBlackout ? "NEWS BLOCK" : overlap ? "OVERLAP" : london ? "LONDON" : ny ? "NY" : "OFF"
killColor = inNewsBlackout ? color.red : overlap ? color.orange : london ? color.blue : ny ? color.green : color.gray
waveText = waveBull ? "BULL WAVE" : waveBear ? "BEAR WAVE" : "NEUTRAL"
waveColor = waveBull ? color.aqua : waveBear ? color.fuchsia : color.gray
stText = stBull ? "ST BULL" : stBear ? "ST BEAR" : "ST NEUTRAL"
stColor = stBull ? color.green : stBear ? color.red : color.gray
smcText = bullOBSignal ? "BULL OB" : bearOBSignal ? "BEAR OB" : eqHigh ? "EQH LIQ" : eqLow ? "EQL LIQ" : "WAIT"
smcColor = bullOBSignal or eqLow ? color.green : bearOBSignal or eqHigh ? color.red : color.gray
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Trend", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, trendText, bgcolor=trendTableColor, text_color=color.white)
    table.cell(dash, 0, 1, "ADX", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 1, adxText, bgcolor=adxColor, text_color=color.white)
    table.cell(dash, 0, 2, "Momentum", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 2, momText, bgcolor=momColor, text_color=color.white)
    table.cell(dash, 0, 3, "Pressure", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 3, pressureText, bgcolor=pressureColor, text_color=color.white)
    table.cell(dash, 0, 4, "Volatility", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 4, volText, bgcolor=volColor, text_color=color.white)
    table.cell(dash, 0, 5, "Zone", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 5, zoneText, bgcolor=zoneColor, text_color=color.white)
    table.cell(dash, 0, 6, "MTF", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 6, mtfText, bgcolor=color.black, text_color=color.white)
    table.cell(dash, 0, 7, "Wave", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 7, waveText, bgcolor=waveColor, text_color=color.white)
    table.cell(dash, 0, 8, "SuperTrend", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 8, stText, bgcolor=stColor, text_color=color.white)
    table.cell(dash, 0, 9, "SMC", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 9, smcText, bgcolor=smcColor, text_color=color.white)
    table.cell(dash, 0, 10, "AI Prob", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 10, aiProbability + " " + str.tostring(aiScore) + "/100", bgcolor=aiColor, text_color=color.white)
    table.cell(dash, 0, 11, "Session", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 11, killText, bgcolor=killColor, text_color=color.white)

//━━━━━━━━ ALERTS
alertcondition(finalBuySignal, "Mani Algo AI Buy", "AI BUY signal on {{ticker}}")
alertcondition(finalSellSignal, "Mani Algo AI Sell", "AI SELL signal on {{ticker}}")
alertcondition(bullBOS, "Bullish BOS", "Bullish BOS on {{ticker}}")
alertcondition(bearBOS, "Bearish BOS", "Bearish BOS on {{ticker}}")
alertcondition(bullCHoCH, "Bullish CHoCH", "Bullish CHoCH on {{ticker}}")
alertcondition(bearCHoCH, "Bearish CHoCH", "Bearish CHoCH on {{ticker}}")
alertcondition(sweepHigh, "Bearish Sweep", "High liquidity sweep on {{ticker}}")
alertcondition(sweepLow, "Bullish Sweep", "Low liquidity sweep on {{ticker}}")
alertcondition(eqHigh, "Equal High Liquidity", "Equal high / buy-side liquidity on {{ticker}}")
alertcondition(eqLow, "Equal Low Liquidity", "Equal low / sell-side liquidity on {{ticker}}")
alertcondition(bullOBSignal, "Bullish Order Block", "Bullish order block on {{ticker}}")
alertcondition(bearOBSignal, "Bearish Order Block", "Bearish order block on {{ticker}}")
````
