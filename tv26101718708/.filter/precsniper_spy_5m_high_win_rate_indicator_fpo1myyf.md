# PrecSniper SPY 5m - High Win Rate Indicator

- url: https://www.tradingview.com/script/fpO1MyYF-PrecSniper-SPY-5m-High-Win-Rate-Indicator/
- type: indicator
- pine_id: PUB;5c6d8824ba084442aacde0d4af097aca
- version: 1.0

## Description

Created with ai. just for fun backtesting. want to test and see if we can make valued back testing. designed to work on 5 m in time frame

## Source Code

````pine
//@version=6
indicator(title="Precision Sniper SPY 5m - High Win Rate", shorttitle="PSPYHR", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=5000)

GRP_MAIN   = "Main Settings"
GRP_ENTRY  = "Entry Engine"
GRP_RISK   = "Risk Management"
GRP_VISUAL = "Visual Settings"

sourceInput      = input.source(close, "Source", group=GRP_MAIN)
htfInput         = input.timeframe("15", "HTF Trend Filter", group=GRP_MAIN)
tradeSession     = input.session("0935-1555", "SPY Trade Session", group=GRP_MAIN)
useSessionFilter = input.bool(true, "Use Session Filter", group=GRP_MAIN)
useORBFilter     = input.bool(true, "Use Opening Range Filter", group=GRP_MAIN)
orbMinutes       = input.int(30, "Opening Range Minutes", minval=5, maxval=60, group=GRP_MAIN)
presetInput      = input.string("Custom", "Preset", options=["Custom", "SPY HR"], group=GRP_MAIN)

emaFastLenInput  = input.int(8, "EMA Fast Length", minval=3, maxval=50, group=GRP_ENTRY)
emaSlowLenInput  = input.int(21, "EMA Slow Length", minval=10, maxval=100, group=GRP_ENTRY)
emaTrendLenInput = input.int(55, "EMA Trend Length", minval=20, maxval=200, group=GRP_ENTRY)
rsiLenInput      = input.int(14, "RSI Length", minval=5, maxval=30, group=GRP_ENTRY)
adxLenInput      = input.int(14, "ADX Length", minval=5, maxval=50, group=GRP_ENTRY)
minScoreInput    = input.int(7, "Min Confluence Score", minval=1, maxval=10, group=GRP_ENTRY)

atrLenInput         = input.int(14, "ATR Length", minval=5, maxval=50, group=GRP_RISK)
slMultInput         = input.float(1.0, "SL ATR Multiplier", minval=0.5, maxval=5.0, step=0.1, group=GRP_RISK)
tp1MultInput        = input.float(0.8, "TP1 Risk:Reward", minval=0.5, maxval=5.0, step=0.1, group=GRP_RISK)
tp2MultInput        = input.float(1.5, "TP2 Risk:Reward", minval=1.0, maxval=8.0, step=0.1, group=GRP_RISK)
useVWAPInput        = input.bool(true, "Require VWAP Bias", group=GRP_RISK)
useTrailInput       = input.bool(true, "Enable Trailing Stop", group=GRP_RISK)
useStructureSLInput = input.bool(true, "Structure-Based SL", group=GRP_RISK)
swingLookbackInput  = input.int(8, "Swing Lookback", minval=3, maxval=30, group=GRP_RISK)

showSignalsInput = input.bool(true, "Show Signals", group=GRP_VISUAL)
showRibbonInput  = input.bool(true, "Show EMA Ribbon", group=GRP_VISUAL)
showTPSLInput    = input.bool(true, "Show TP/SL Lines", group=GRP_VISUAL)
showORBInput     = input.bool(true, "Show ORB Levels", group=GRP_VISUAL)

string resolvedPreset = presetInput
if presetInput == "SPY HR"
    resolvedPreset := "SPY HR"

int effectiveEmaFast  = resolvedPreset == "SPY HR" ? 8  : emaFastLenInput
int effectiveEmaSlow  = resolvedPreset == "SPY HR" ? 21 : emaSlowLenInput
int effectiveEmaTrend = resolvedPreset == "SPY HR" ? 55 : emaTrendLenInput
int effectiveRsiLen   = resolvedPreset == "SPY HR" ? 14 : rsiLenInput
int effectiveAdxLen   = resolvedPreset == "SPY HR" ? 14 : adxLenInput
int effectiveAtrLen   = resolvedPreset == "SPY HR" ? 14 : atrLenInput
int effectiveScore    = resolvedPreset == "SPY HR" ? 7  : minScoreInput
float effectiveSL    = resolvedPreset == "SPY HR" ? 1.0 : slMultInput

safeDiv(float num, float den, float fallback=0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

safeStr(float val, string fmt="#.##") =>
    na(val) ? "—" : str.tostring(val, fmt)

getGrade(float score) =>
    score >= 8.0 ? "A+" : score >= 6.5 ? "A" : score >= 5.0 ? "B" : "C"

passesGradeFilter(float score) =>
    score >= 5.0

getSwingLow(int lookback) =>
    float swLow = low
    for i = 1 to lookback
        if nz(low[i], low) < swLow
            swLow := nz(low[i], low)
    swLow

getSwingHigh(int lookback) =>
    float swHigh = high
    for i = 1 to lookback
        if nz(high[i], high) > swHigh
            swHigh := nz(high[i], high)
    swHigh

emaFast  = nz(ta.ema(sourceInput, effectiveEmaFast), close)
emaSlow  = nz(ta.ema(sourceInput, effectiveEmaSlow), close)
emaTrend = nz(ta.ema(sourceInput, effectiveEmaTrend), close)
rsiVal   = nz(ta.rsi(sourceInput, effectiveRsiLen), 50.0)
atrVal   = nz(ta.atr(effectiveAtrLen), high - low)
vwapVal  = nz(ta.vwap(hlc3), close)
[diPlus, diMinus, adxVal] = ta.dmi(effectiveAdxLen, effectiveAdxLen)

htfEmaFast = request.security(syminfo.tickerid, htfInput, ta.ema(sourceInput, effectiveEmaFast)[1], barmerge.gaps_off, barmerge.lookahead_off)
htfEmaSlow = request.security(syminfo.tickerid, htfInput, ta.ema(sourceInput, effectiveEmaSlow)[1], barmerge.gaps_off, barmerge.lookahead_off)
htfBull = htfEmaFast > htfEmaSlow
htfBear = htfEmaFast < htfEmaSlow

newDay = ta.change(time("D")) != 0

var int sessionStartBar = na

if newDay
    sessionStartBar := bar_index

barsFromOpen = na(sessionStartBar) ? 9999 : bar_index - sessionStartBar
orbBars = math.max(1, int(math.round(orbMinutes / 5.0)))
orbHigh = ta.highest(high, orbBars)
orbLow = ta.lowest(low, orbBars)
orbReady = barsFromOpen >= orbBars

inSession = not na(time(timeframe.period, tradeSession))
sessionOk = useSessionFilter ? inSession : true

bullScore = 0.0
bullScore += emaFast > emaSlow ? 1 : 0
bullScore += close > emaTrend ? 1 : 0
bullScore += rsiVal > 50 and rsiVal < 68 ? 1 : 0
bullScore += close > open ? 1 : 0
bullScore += close > vwapVal ? 1 : 0
bullScore += htfBull ? 2 : 0
bullScore += adxVal > 18 ? 1 : 0
bullScore += volume > ta.sma(volume, 20) ? 1 : 0

bearScore = 0.0
bearScore += emaFast < emaSlow ? 1 : 0
bearScore += close < emaTrend ? 1 : 0
bearScore += rsiVal < 50 and rsiVal > 32 ? 1 : 0
bearScore += close < open ? 1 : 0
bearScore += close < vwapVal ? 1 : 0
bearScore += htfBear ? 2 : 0
bearScore += adxVal > 18 ? 1 : 0
bearScore += volume > ta.sma(volume, 20) ? 1 : 0

recentSwingLow = getSwingLow(swingLookbackInput)
recentSwingHigh = getSwingHigh(swingLookbackInput)

bullMomentum = close > emaFast and close > emaSlow
bearMomentum = close < emaFast and close < emaSlow

longSetup =
     sessionOk and
     barstate.isconfirmed and
     not na(emaFast) and
     not na(emaSlow) and
     htfBull and
     emaFast > emaSlow and
     close > emaTrend and
     bullMomentum and
     rsiVal > 50 and rsiVal < 68 and
     bullScore >= effectiveScore and
     passesGradeFilter(bullScore) and
     (not useVWAPInput or close > vwapVal) and
     (not useORBFilter or (orbReady and close > orbHigh))

shortSetup =
     sessionOk and
     barstate.isconfirmed and
     not na(emaFast) and
     not na(emaSlow) and
     htfBear and
     emaFast < emaSlow and
     close < emaTrend and
     bearMomentum and
     rsiVal < 50 and rsiVal > 32 and
     bearScore >= effectiveScore and
     passesGradeFilter(bearScore) and
     (not useVWAPInput or close < vwapVal) and
     (not useORBFilter or (orbReady and close < orbLow))

calcSL(bool isLong, float entry, float atrSL) =>
    float atrStop = isLong ? entry - atrSL : entry + atrSL
    if useStructureSLInput
        float structStop = isLong ? recentSwingLow - atrVal * 0.2 : recentSwingHigh + atrVal * 0.2
        float finalStop = isLong ? math.max(atrStop, structStop) : math.min(atrStop, structStop)
        float minDist = atrVal * 0.5
        float dist = math.abs(entry - finalStop)
        finalStop := dist < minDist ? (isLong ? entry - minDist : entry + minDist) : finalStop
        finalStop
    else
        atrStop

var float entryPrice = na
var float slPrice = na
var float tp1Price = na
var float tp2Price = na
var float trailPrice = na
var int tradeDir = 0
var float tradeRisk = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool slHit = false

if longSetup
    entryPrice := close
    tradeDir := 1
    slPrice := calcSL(true, close, atrVal * effectiveSL)
    tradeRisk := math.abs(close - slPrice)
    tp1Price := close + tradeRisk * tp1MultInput
    tp2Price := close + tradeRisk * tp2MultInput
    trailPrice := slPrice
    tp1Hit := false
    tp2Hit := false
    slHit := false

if shortSetup
    entryPrice := close
    tradeDir := -1
    slPrice := calcSL(false, close, atrVal * effectiveSL)
    tradeRisk := math.abs(close - slPrice)
    tp1Price := close - tradeRisk * tp1MultInput
    tp2Price := close - tradeRisk * tp2MultInput
    trailPrice := slPrice
    tp1Hit := false
    tp2Hit := false
    slHit := false

canManage = tradeDir != 0 and not slHit and barstate.isconfirmed

if canManage and tradeDir == 1
    if high >= tp1Price and not tp1Hit
        tp1Hit := true
        if useTrailInput
            trailPrice := entryPrice
    if high >= tp2Price and not tp2Hit
        tp2Hit := true
        if useTrailInput
            trailPrice := tp1Price
    if low <= nz(trailPrice, slPrice)
        slHit := true

if canManage and tradeDir == -1
    if low <= tp1Price and not tp1Hit
        tp1Hit := true
        if useTrailInput
            trailPrice := entryPrice
    if low <= tp2Price and not tp2Hit
        tp2Hit := true
        if useTrailInput
            trailPrice := tp1Price
    if high >= nz(trailPrice, slPrice)
        slHit := true

plot(showRibbonInput ? emaFast : na, "EMA Fast", color=color.new(color.lime, 0), linewidth=2)
plot(showRibbonInput ? emaSlow : na, "EMA Slow", color=color.new(color.red, 0), linewidth=2)
plot(showRibbonInput ? emaTrend : na, "EMA Trend", color=color.new(color.gray, 0), linewidth=1)
plot(vwapVal, "VWAP", color=color.new(color.blue, 0), linewidth=1)

pFast = plot(showRibbonInput ? emaFast : na, display=display.none)
pSlow = plot(showRibbonInput ? emaSlow : na, display=display.none)
fill(pFast, pSlow, color=emaFast > emaSlow ? color.new(color.green, 88) : color.new(color.red, 88))

plot(showORBInput and orbReady ? orbHigh : na, "ORB High", color=color.new(color.green, 40), style=plot.style_linebr)
plot(showORBInput and orbReady ? orbLow : na, "ORB Low", color=color.new(color.red, 40), style=plot.style_linebr)

plotshape(showSignalsInput and longSetup, title="Long", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny, text="L")
plotshape(showSignalsInput and shortSetup, title="Short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, text="S")

alertcondition(longSetup, "Long Signal", "SPY 5m HR Long")
alertcondition(shortSetup, "Short Signal", "SPY 5m HR Short")
````
