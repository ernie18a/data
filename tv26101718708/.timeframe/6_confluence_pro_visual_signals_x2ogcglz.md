# 6 Confluence PRO++ Visual Signals

- url: https://www.tradingview.com/script/X2oGCgLz-6-Confluence-PRO-Visual-Signals/
- type: indicator
- pine_id: PUB;bb775935b72e46d5b233298a4266b4f6
- version: 1.0

## Description

6 Confluence PRO; trade like a pro and grow $500 account into $50,000 in less than a year

## Source Code

````pine
//@version=6
indicator("6 Confluence PRO++ Visual Signals", overlay=true, max_labels_count=500, max_lines_count=500)

// === Inputs ===
minConfirm  = input.int(5, "Minimum Confluences for Entry", minval=3, maxval=6)
exitConfirm = input.int(3, "Exit When Score Drops To", minval=1, maxval=5)
waitClose   = input.bool(true, "Confirm Signals on Candle Close")

emaFastLen = input.int(21, "Fast EMA")
emaSlowLen = input.int(50, "Slow EMA")

rsiLen    = input.int(14, "RSI Length")
adxLen    = input.int(14, "ADX Length")
adxSmooth = input.int(14, "ADX Smoothing")
adxMin    = input.float(20, "Minimum ADX")

volLen  = input.int(20, "Volume SMA Length")
volMult = input.float(1.2, "Volume Multiplier")

htf       = input.timeframe("60", "Higher Timeframe")
htfEmaLen = input.int(50, "HTF EMA Length")

atrLen    = input.int(14, "ATR Length")
slMult    = input.float(1.5, "ATR Stop Loss Multiplier")
tpMult    = input.float(2.5, "ATR Target Multiplier")
trailMult = input.float(1.2, "ATR Trailing Stop Multiplier")

useVwapFilter      = input.bool(true, "Use VWAP Filter")
useSessionFilter   = input.bool(false, "Use Session Filter")
tradeSession       = input.session("0930-1600", "Trading Session")
cooldownBars       = input.int(3, "Cooldown Bars After Exit", minval=0, maxval=50)
neutralGap         = input.int(1, "No-Trade Gap Between Bull/Bear Scores", minval=0, maxval=5)

useStructureFilter = input.bool(false, "Use Market Structure Filter")
structureLen       = input.int(5, "Market Structure Pivot Length", minval=2, maxval=20)

useLiquiditySweep  = input.bool(false, "Use Liquidity Sweep Filter")
sweepLookback      = input.int(10, "Liquidity Sweep Lookback", minval=3, maxval=50)

useCandleConfirm   = input.bool(false, "Use Candle Confirmation")
bodyMinPct         = input.float(50, "Minimum Candle Body %", minval=10, maxval=90)

useChopFilter      = input.bool(true, "Use EMA Chop Filter")
emaGapAtrMin       = input.float(0.20, "Minimum EMA Gap vs ATR", minval=0.05, maxval=2.0)

useHtfScore        = input.bool(false, "Use HTF Score Alignment")

showVolLevels      = input.bool(true, "Show Key Volume Price Levels")
volLevelCount      = input.int(5, "Number of Volume Levels", minval=1, maxval=10)
volSpikeMult       = input.float(2.0, "Volume Spike Multiplier")
rightOffset        = input.int(15, "Right Side Label Offset")

// === Indicators ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
rsi = ta.rsi(close, rsiLen)
vwap = ta.vwap(close)

[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)
[plusDI, minusDI, adx] = ta.dmi(adxLen, adxSmooth)

volSma = ta.sma(volume, volLen)
atr = ta.atr(atrLen)

htfClose = request.security(syminfo.tickerid, htf, close)
htfEma   = request.security(syminfo.tickerid, htf, ta.ema(close, htfEmaLen))
htfFast  = request.security(syminfo.tickerid, htf, ta.ema(close, emaFastLen))
htfSlow  = request.security(syminfo.tickerid, htf, ta.ema(close, emaSlowLen))
htfRsi   = request.security(syminfo.tickerid, htf, ta.rsi(close, rsiLen))

// === Filters ===
confirmed = waitClose ? barstate.isconfirmed : true
inSession = useSessionFilter ? not na(time(timeframe.period, tradeSession)) : true

vwapLongOk  = useVwapFilter ? close > vwap : true
vwapShortOk = useVwapFilter ? close < vwap : true

emaGap = math.abs(emaFast - emaSlow)
notChoppy = useChopFilter ? emaGap > atr * emaGapAtrMin : true

// === Bullish Score ===
bullTrend = emaFast > emaSlow and close > emaSlow
bullMacd  = macdLine > macdSignal
bullRsi   = rsi > 50 and rsi < 75
bullAdx   = adx > adxMin and plusDI > minusDI
bullVol   = volume > volSma * volMult
bullHtf   = htfClose > htfEma

bullScore =
     (bullTrend ? 1 : 0) +
     (bullMacd ? 1 : 0) +
     (bullRsi ? 1 : 0) +
     (bullAdx ? 1 : 0) +
     (bullVol ? 1 : 0) +
     (bullHtf ? 1 : 0)

// === Bearish Score ===
bearTrend = emaFast < emaSlow and close < emaSlow
bearMacd  = macdLine < macdSignal
bearRsi   = rsi < 50 and rsi > 25
bearAdx   = adx > adxMin and minusDI > plusDI
bearVol   = volume > volSma * volMult
bearHtf   = htfClose < htfEma

bearScore =
     (bearTrend ? 1 : 0) +
     (bearMacd ? 1 : 0) +
     (bearRsi ? 1 : 0) +
     (bearAdx ? 1 : 0) +
     (bearVol ? 1 : 0) +
     (bearHtf ? 1 : 0)

// === HTF Alignment ===
htfBullScore =
     (htfFast > htfSlow ? 1 : 0) +
     (htfClose > htfEma ? 1 : 0) +
     (htfRsi > 50 ? 1 : 0)

htfBearScore =
     (htfFast < htfSlow ? 1 : 0) +
     (htfClose < htfEma ? 1 : 0) +
     (htfRsi < 50 ? 1 : 0)

htfLongOk  = useHtfScore ? htfBullScore >= 2 : true
htfShortOk = useHtfScore ? htfBearScore >= 2 : true

// === Market Structure ===
pivotHigh = ta.pivothigh(high, structureLen, structureLen)
pivotLow  = ta.pivotlow(low, structureLen, structureLen)

var float lastHigh = na
var float prevHigh = na
var float lastLow = na
var float prevLow = na

if not na(pivotHigh)
    prevHigh := lastHigh
    lastHigh := pivotHigh

if not na(pivotLow)
    prevLow := lastLow
    lastLow := pivotLow

higherHigh = not na(lastHigh) and not na(prevHigh) and lastHigh > prevHigh
higherLow  = not na(lastLow) and not na(prevLow) and lastLow > prevLow
lowerHigh  = not na(lastHigh) and not na(prevHigh) and lastHigh < prevHigh
lowerLow   = not na(lastLow) and not na(prevLow) and lastLow < prevLow

bullStructure = useStructureFilter ? higherHigh and higherLow : true
bearStructure = useStructureFilter ? lowerHigh and lowerLow : true

// === Liquidity Sweep ===
priorLow  = ta.lowest(low[1], sweepLookback)
priorHigh = ta.highest(high[1], sweepLookback)

bullSweep = low < priorLow and close > priorLow
bearSweep = high > priorHigh and close < priorHigh

bullSweepOk = useLiquiditySweep ? bullSweep or close > priorHigh : true
bearSweepOk = useLiquiditySweep ? bearSweep or close < priorLow : true

// === Candle Confirmation ===
candleRange = high - low
bodySize = math.abs(close - open)
bodyPct = candleRange > 0 ? bodySize / candleRange * 100 : 0

bullCandle = close > open and bodyPct >= bodyMinPct and close >= high - candleRange * 0.30
bearCandle = close < open and bodyPct >= bodyMinPct and close <= low + candleRange * 0.30

bullCandleOk = useCandleConfirm ? bullCandle : true
bearCandleOk = useCandleConfirm ? bearCandle : true

// === Cooldown / Neutral ===
scoreGap = math.abs(bullScore - bearScore)
neutralZone = scoreGap < neutralGap

var int lastExitBar = na
cooldownOk = na(lastExitBar) ? true : bar_index - lastExitBar > cooldownBars

// === Entry Phase Logic ===
greenPhase =
     bullScore >= minConfirm and
     bullScore > bearScore and
     not neutralZone and
     vwapLongOk and
     inSession and
     cooldownOk and
     notChoppy and
     htfLongOk and
     bullStructure and
     bullSweepOk and
     bullCandleOk

redPhase =
     bearScore >= minConfirm and
     bearScore > bullScore and
     not neutralZone and
     vwapShortOk and
     inSession and
     cooldownOk and
     notChoppy and
     htfShortOk and
     bearStructure and
     bearSweepOk and
     bearCandleOk

var int phase = 0

longEntry  = confirmed and greenPhase and phase != 1
shortEntry = confirmed and redPhase and phase != -1

exitLong  = confirmed and phase == 1 and (redPhase or bullScore <= exitConfirm or close < vwap)
exitShort = confirmed and phase == -1 and (greenPhase or bearScore <= exitConfirm or close > vwap)

if exitLong or exitShort
    phase := 0
    lastExitBar := bar_index

if longEntry
    phase := 1

if shortEntry
    phase := -1

// === Stops / Targets ===
var float longStop = na
var float longTarget = na
var float shortStop = na
var float shortTarget = na
var float trailStop = na

if longEntry
    longStop := close - atr * slMult
    longTarget := close + atr * tpMult
    shortStop := na
    shortTarget := na
    trailStop := close - atr * trailMult

if shortEntry
    shortStop := close + atr * slMult
    shortTarget := close - atr * tpMult
    longStop := na
    longTarget := na
    trailStop := close + atr * trailMult

if phase == 1 and not na(trailStop)
    trailStop := math.max(trailStop, close - atr * trailMult)

if phase == -1 and not na(trailStop)
    trailStop := math.min(trailStop, close + atr * trailMult)

trailExitLong  = confirmed and phase == 1 and not na(trailStop) and close < trailStop
trailExitShort = confirmed and phase == -1 and not na(trailStop) and close > trailStop

if trailExitLong or trailExitShort
    phase := 0
    lastExitBar := bar_index

if exitLong or trailExitLong
    longStop := na
    longTarget := na
    trailStop := na

if exitShort or trailExitShort
    shortStop := na
    shortTarget := na
    trailStop := na

// === Trade Quality ===
activeScore = math.max(bullScore, bearScore)

qualityScore =
     activeScore +
     (adx >= 30 ? 1 : 0) +
     (volume > volSma * volMult ? 1 : 0) +
     (notChoppy ? 1 : 0) +
     ((close > vwap and bullScore > bearScore) or (close < vwap and bearScore > bullScore) ? 1 : 0)

qualityGrade = qualityScore >= 9 ? "A+" : qualityScore >= 8 ? "A" : qualityScore >= 7 ? "B" : "C"

// === BUY / SELL Labels ===
if longEntry
    rr = (longTarget - close) / (close - longStop)
    label.new(bar_index, low, "BUY\n" + qualityGrade + "\nRR " + str.tostring(rr, "#.##"), style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if shortEntry
    rr = (close - shortTarget) / (shortStop - close)
    label.new(bar_index, high, "SELL\n" + qualityGrade + "\nRR " + str.tostring(rr, "#.##"), style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

// === Visuals ===
plot(emaFast, "Fast EMA", color=color.green, linewidth=2)
plot(emaSlow, "Slow EMA", color=color.red, linewidth=2)
plot(vwap, "VWAP", color=color.orange, linewidth=1)

bgcolor(phase == 1 ? color.new(color.green, 82) : phase == -1 ? color.new(color.red, 82) : na)

plotshape(longEntry, title="BUY Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(shortEntry, title="SELL Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

plotshape(exitLong or trailExitLong, title="EXIT LONG", text="EXIT", style=shape.xcross, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(exitShort or trailExitShort, title="EXIT SHORT", text="EXIT", style=shape.xcross, location=location.belowbar, color=color.orange, size=size.tiny)

plot(longStop, "Long Stop", color=color.red, style=plot.style_linebr, linewidth=1)
plot(longTarget, "Long Target", color=color.green, style=plot.style_linebr, linewidth=1)
plot(shortStop, "Short Stop", color=color.red, style=plot.style_linebr, linewidth=1)
plot(shortTarget, "Short Target", color=color.green, style=plot.style_linebr, linewidth=1)
plot(trailStop, "ATR Trailing Stop", color=color.yellow, style=plot.style_linebr, linewidth=1)

// === Volume Price Levels ===
var line[] volLines = array.new_line()
var label[] volLabels = array.new_label()

isVolumeSpike = volume > volSma * volSpikeMult

if showVolLevels and isVolumeSpike and barstate.isconfirmed
    levelPrice = hlc3
    levelVol = volume
    volColor = close >= emaSlow ? color.new(color.green, 15) : color.new(color.red, 15)

    newLine = line.new(bar_index, levelPrice, bar_index + rightOffset, levelPrice, extend=extend.right, color=volColor, width=1)

    newLabel = label.new(
         bar_index + rightOffset,
         levelPrice,
         "VOL " + str.tostring(levelVol, format.volume) + " @ " + str.tostring(levelPrice, format.mintick),
         style=label.style_label_left,
         color=volColor,
         textcolor=color.white,
         size=size.tiny)

    array.push(volLines, newLine)
    array.push(volLabels, newLabel)

    if array.size(volLines) > volLevelCount
        line.delete(array.shift(volLines))
        label.delete(array.shift(volLabels))

if showVolLevels and barstate.islast
    for i = 0 to array.size(volLabels) - 1
        label.set_x(array.get(volLabels, i), bar_index + rightOffset)

// === Alerts ===
alertcondition(longEntry, "BUY Signal", "PRO++ BUY Signal")
alertcondition(shortEntry, "SELL Signal", "PRO++ SELL Signal")
alertcondition(exitLong or trailExitLong, "Exit Long", "PRO++ Exit Long")
alertcondition(exitShort or trailExitShort, "Exit Short", "PRO++ Exit Short")

// === Dashboard ===
var table dash = table.new(position.top_right, 2, 10, border_width=1, frame_width=1)

phaseText = phase == 1 ? "LONG" : phase == -1 ? "SHORT" : "NEUTRAL"
phaseColor = phase == 1 ? color.green : phase == -1 ? color.red : color.gray

trendText = bullScore > bearScore ? "BULLISH" : bearScore > bullScore ? "BEARISH" : "MIXED"
trendColor = bullScore > bearScore ? color.green : bearScore > bullScore ? color.red : color.gray

adxText = adx < 20 ? "WEAK" : adx < 30 ? "OK" : "STRONG"
volumeText = volume > volSma * volMult ? "STRONG" : "WEAK"
vwapText = close > vwap ? "ABOVE" : "BELOW"
chopText = notChoppy ? "CLEAN" : "CHOP"

if barstate.islast
    table.cell(dash, 0, 0, "TREND", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 0, trendText, text_color=color.white, bgcolor=trendColor, text_size=size.small)

    table.cell(dash, 0, 1, "BULL", text_color=color.white, bgcolor=color.new(color.green, 15), text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(bullScore) + "/6", text_color=color.white, bgcolor=color.new(color.green, 15), text_size=size.small)

    table.cell(dash, 0, 2, "BEAR", text_color=color.white, bgcolor=color.new(color.red, 15), text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(bearScore) + "/6", text_color=color.white, bgcolor=color.new(color.red, 15), text_size=size.small)

    table.cell(dash, 0, 3, "ADX", text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)
    table.cell(dash, 1, 3, adxText + " " + str.tostring(adx, "#.0"), text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)

    table.cell(dash, 0, 4, "VOL", text_color=color.white, bgcolor=color.new(color.purple, 15), text_size=size.small)
    table.cell(dash, 1, 4, volumeText, text_color=color.white, bgcolor=volumeText == "STRONG" ? color.green : color.gray, text_size=size.small)

    table.cell(dash, 0, 5, "VWAP", text_color=color.white, bgcolor=color.new(color.orange, 15), text_size=size.small)
    table.cell(dash, 1, 5, vwapText, text_color=color.white, bgcolor=close > vwap ? color.green : color.red, text_size=size.small)

    table.cell(dash, 0, 6, "MARKET", text_color=color.white, bgcolor=color.new(color.gray, 15), text_size=size.small)
    table.cell(dash, 1, 6, chopText, text_color=color.white, bgcolor=notChoppy ? color.green : color.red, text_size=size.small)

    table.cell(dash, 0, 7, "GRADE", text_color=color.white, bgcolor=color.new(color.gray, 15), text_size=size.small)
    table.cell(dash, 1, 7, qualityGrade, text_color=color.white, bgcolor=qualityGrade == "A+" or qualityGrade == "A" ? color.green : qualityGrade == "B" ? color.orange : color.red, text_size=size.small)

    table.cell(dash, 0, 8, "PHASE", text_color=color.white, bgcolor=phaseColor, text_size=size.small)
    table.cell(dash, 1, 8, phaseText, text_color=color.white, bgcolor=phaseColor, text_size=size.small)

    table.cell(dash, 0, 9, "FILTERS", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 9, notChoppy and inSession ? "OK" : "BLOCK", text_color=color.white, bgcolor=notChoppy and inSession ? color.green : color.red, text_size=size.small)
````
