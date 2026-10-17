# ATR Breakout Engine

- url: https://www.tradingview.com/script/LuuoZKtk-ATR-Breakout-Engine/
- type: indicator
- pine_id: PUB;b4f9236653e44352ad480bcbb01b045b
- version: 1.0

## Description

Same multi-timeframe idea as the ATR Bands, except this one's a signal tool, not just lines. It builds a session reference and an ATR for the 1m, 5m, and 15m, works out a breakout level for each, and fires an arrow when 1-minute price crosses one. When a few timeframes break together you've usually got something with legs. It doesn't place orders, so pair it with the strategy version if you want the backtest numbers. Set the session timezone to your cash open. It uses higher-timeframe requests, so confirm the live behavior matches the history.

## Source Code

````pine
//@version=6
// =============================================================================
//  ATR BREAKOUT ENGINE  —  INDICATOR (Nesnidal-style)
//  The same breakout logic as the strategy, but as a study: it draws the
//  trigger levels, shades the session and the high-volatility no-trade zones,
//  and fires an arrow + alert when a qualifying breakout actually triggers.
//  No orders are placed — use the strategy version for backtesting P&L.
//
//  TIMEZONE NOTE: Pine reads session times in the EXCHANGE timezone by default.
//  NQ/ES = CME = Chicago (CT), so "0930" would mean 9:30 CT = 10:30 ET.
//  Keep "Session timezone" on America/New_York for the 9:30 ET cash open.
// =============================================================================
indicator("ATR Breakout Engine — Indicator (Nesnidal-style)", overlay = true, max_labels_count = 500)

// -----------------------------------------------------------------------------
//  INPUTS  (mirror the strategy)
// -----------------------------------------------------------------------------
gDir       = "Direction"
allowLong  = input.bool(true, "Show Longs",  group = gDir)
allowShort = input.bool(true, "Show Shorts", group = gDir)

gPOI    = "1) Point of Initiation"
poiType = input.string("Today's Open", "Reference point",
     options = ["Today's Open", "Prior Day Close", "Prior Day High/Low"], group = gPOI,
     tooltip = "Where the breakout is measured from. Prior Day High/Low uses high for longs, low for shorts. Built from YOUR session below.")

gDist  = "2) Breakout Distance"
atrLen = input.int(14, "ATR length", minval = 2, group = gDist)
atrTf  = input.string("Chart timeframe", "ATR source", options = ["Chart timeframe", "Daily"], group = gDist)
kDist  = input.float(0.5, "Distance multiple (k)", minval = 0.0, step = 0.1, group = gDist)

gTime         = "3) Time Filter"
useTimeFilter = input.bool(true, "Only signal inside session window", group = gTime)
sess          = input.session("0930-1600", "Session window", group = gTime)
tzMode        = input.string("America/New_York (ET)", "Session timezone",
     options = ["America/New_York (ET)", "America/Chicago (CT)", "Exchange (symbol)", "UTC"], group = gTime,
     tooltip = "Keep on New York so 0930-1600 = 9:30-16:00 ET (the cash-index open). The shaded band shows the active session — confirm it starts where you expect.")
tz = tzMode == "Exchange (symbol)" ? syminfo.timezone : tzMode == "America/Chicago (CT)" ? "America/Chicago" : tzMode == "UTC" ? "UTC" : "America/New_York"

gFilt        = "4) False-Breakout Filters"
useTrend     = input.bool(true,  "Trend filter: price on correct side of today's open", group = gFilt)
useVolRegime = input.bool(true,  "Low-volatility regime only", group = gFilt)
volLookback  = input.int(50,  "  Vol regime lookback (bars)", minval = 5, group = gFilt)
volPctile    = input.float(50, "  Signal when ATR below this percentile", minval = 1, maxval = 99, group = gFilt)
useConfirm   = input.bool(true,  "Confirmation bar (prior bar agrees)", group = gFilt)
useVolume    = input.bool(false, "Volume filter (volume > its average)", group = gFilt)
volMaLen     = input.int(20, "  Volume MA length", minval = 2, group = gFilt)

// --- (5) Advanced filters (test ONE at a time; all OFF by default) ---
g5          = "5) Advanced Filters (test ONE at a time)"
useAtrRatio = input.bool(false, "Volatility regime: ATR fast vs slow", group = g5,
     tooltip = "Squeeze (fast<slow) = recent range BELOW baseline (coiled, pre-expansion = the breakout edge). Expansion (fast>slow) = vol already rising (momentum). NOTE: 'ATR(30) > ATR(20)' is the same thing as Squeeze. Test both modes.")
atrFastLen  = input.int(10, "  Fast ATR length", minval = 1, group = g5)
atrSlowLen  = input.int(30, "  Slow ATR length", minval = 2, group = g5)
atrRatioMode= input.string("Squeeze (fast < slow)", "  Mode", options = ["Squeeze (fast < slow)", "Expansion (fast > slow)"], group = g5)
useAdx      = input.bool(false, "ADX filter", group = g5,
     tooltip = "ADX LEVEL lags - high ADX usually means you're already late. Breakout-useful forms are 'Rising' or a band. Test, don't assume.")
adxLen      = input.int(14, "  DI length", minval = 1, group = g5)
adxSmooth   = input.int(14, "  ADX smoothing", minval = 1, group = g5)
adxMode     = input.string("Rising", "  ADX condition", options = ["Rising", "Above min", "Within band"], group = g5)
adxMin      = input.float(20, "  ADX min", minval = 0, group = g5)
adxMax      = input.float(50, "  ADX max", minval = 0, group = g5)
useCoil     = input.bool(false, "Coil filter (compression precursor)", group = g5,
     tooltip = "Require the setup bar to come from compression. NRn = narrowest range of last N bars; Inside = inside bar.")
coilMode    = input.string("Narrow range (NRn)", "  Coil type", options = ["Narrow range (NRn)", "Inside bar"], group = g5)
nrLen       = input.int(7, "  NR lookback", minval = 2, group = g5)
useRvol     = input.bool(false, "Relative volume (improved volume filter)", group = g5,
     tooltip = "volume / average-volume must exceed a multiple - stricter than the raw MA cross. NQ futures volume is distorted by rollover & RTH/ETH; keep expectations modest.")
rvolLen     = input.int(20, "  RVOL average length", minval = 2, group = g5)
rvolMult    = input.float(1.5, "  RVOL multiple", minval = 0.1, step = 0.1, group = g5)

gSig    = "Signals"
oneSig  = input.bool(true, "Max one signal per side per session", group = gSig)
showLvl = input.bool(true, "Plot trigger levels", group = gSig)
showStop= input.bool(false, "Project stop/target from trigger", group = gSig,
     tooltip = "Draws the implied ATR stop and R-target levels (for reference only).")
stopMult= input.float(1.5, "  Stop = ATR x", minval = 0.1, step = 0.1, group = gSig)
targetR = input.float(2.0, "  Target (R multiple)", minval = 0.1, step = 0.1, group = gSig)

// -----------------------------------------------------------------------------
//  CORE CALCULATIONS  (identical to the strategy)
// -----------------------------------------------------------------------------
atrChart = ta.atr(atrLen)
atrDaily = request.security(syminfo.tickerid, "D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_off)
atr      = atrTf == "Daily" ? atrDaily : atrChart

sessionActive = not na(time(timeframe.period, sess, tz))
newSession    = sessionActive and not sessionActive[1]
justLeftSess  = (not sessionActive) and sessionActive[1]

var float curOpen   = na
var float curHigh   = na
var float curLow    = na
var float prevClose = na
var float prevHigh  = na
var float prevLow   = na

if newSession
    curOpen := open
    curHigh := high
    curLow  := low
else if sessionActive
    curHigh := math.max(curHigh, high)
    curLow  := math.min(curLow, low)

if justLeftSess
    prevClose := close[1]
    prevHigh  := curHigh
    prevLow   := curLow

todayOpen = curOpen

poiLong  = poiType == "Prior Day Close" ? prevClose : poiType == "Prior Day High/Low" ? prevHigh : todayOpen
poiShort = poiType == "Prior Day Close" ? prevClose : poiType == "Prior Day High/Low" ? prevLow  : todayOpen

longLevel  = poiLong  + kDist * atr
shortLevel = poiShort - kDist * atr

// -----------------------------------------------------------------------------
//  FILTER GATES
// -----------------------------------------------------------------------------
timeOK       = not useTimeFilter or sessionActive
volThreshold = ta.percentile_nearest_rank(atr, volLookback, volPctile)
volRegimeOK  = not useVolRegime or atr <= volThreshold
volMa        = ta.sma(volume, volMaLen)
volumeOK     = not useVolume or volume > volMa

trendOKlong   = not useTrend or (not na(todayOpen) and close > todayOpen)
trendOKshort  = not useTrend or (not na(todayOpen) and close < todayOpen)
confirmOKlong = not useConfirm or close[1] > open[1]
confirmOKshort= not useConfirm or close[1] < open[1]

// (5) Advanced regime/structure filters (non-directional; computed every bar)
atrFast    = ta.atr(atrFastLen)
atrSlow    = ta.atr(atrSlowLen)
atrRatioOK = not useAtrRatio or (atrRatioMode == "Squeeze (fast < slow)" ? atrFast < atrSlow : atrFast > atrSlow)

[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxSmooth)
adxOK = not useAdx or (adxMode == "Rising" ? adxVal > adxVal[1] : adxMode == "Above min" ? adxVal >= adxMin : (adxVal >= adxMin and adxVal <= adxMax))

rng      = high - low
isNR     = rng <= ta.lowest(rng, nrLen)
isInside = high <= high[1] and low >= low[1]
coilOK   = not useCoil or (coilMode == "Inside bar" ? isInside : isNR)

rvol   = volume / ta.sma(volume, rvolLen)
rvolOK = not useRvol or rvol >= rvolMult

regimeOK = atrRatioOK and adxOK and coilOK and rvolOK

filtersLong  = allowLong  and timeOK and volRegimeOK and volumeOK and regimeOK and trendOKlong  and confirmOKlong  and not na(longLevel)
filtersShort = allowShort and timeOK and volRegimeOK and volumeOK and regimeOK and trendOKshort and confirmOKshort and not na(shortLevel)

// -----------------------------------------------------------------------------
//  SIGNALS  (breakout triggers)
// -----------------------------------------------------------------------------
longBreak  = filtersLong  and ta.crossover(high, longLevel)
shortBreak = filtersShort and ta.crossunder(low, shortLevel)

var bool firedLong  = false
var bool firedShort = false
if newSession
    firedLong  := false
    firedShort := false

longSignal  = longBreak  and (not oneSig or not firedLong)
shortSignal = shortBreak and (not oneSig or not firedShort)
if longSignal
    firedLong  := true
if shortSignal
    firedShort := true

// -----------------------------------------------------------------------------
//  PLOTS
// -----------------------------------------------------------------------------
plot(showLvl and timeOK and allowLong  ? longLevel  : na, "Long trigger",  color = color.new(color.teal, 0),   style = plot.style_linebr, linewidth = 2)
plot(showLvl and timeOK and allowShort ? shortLevel : na, "Short trigger", color = color.new(color.maroon, 0), style = plot.style_linebr, linewidth = 2)
plot(poiType == "Today's Open" ? todayOpen : na, "Today's open", color = color.new(color.gray, 40), style = plot.style_circles)

bgcolor(sessionActive ? color.new(color.blue, 92) : na, title = "Session window shading")
bgcolor(useVolRegime and not volRegimeOK ? color.new(color.orange, 90) : na, title = "High-vol (no-signal) shading")

plotshape(longSignal,  title = "Long breakout",  style = shape.triangleup,   location = location.belowbar, color = color.new(color.teal, 0),   size = size.small, text = "BREAK ▲")
plotshape(shortSignal, title = "Short breakout", style = shape.triangledown, location = location.abovebar, color = color.new(color.maroon, 0), size = size.small, text = "BREAK ▼")

// Optional stop / target projection from the trigger level (reference only)
plot(showStop and longSignal  ? longLevel  - stopMult * atr           : na, "Long stop",   color = color.new(color.red, 0),  style = plot.style_cross, linewidth = 1)
plot(showStop and longSignal  ? longLevel  + targetR * stopMult * atr  : na, "Long target", color = color.new(color.green, 0), style = plot.style_cross, linewidth = 1)
plot(showStop and shortSignal ? shortLevel + stopMult * atr           : na, "Short stop",  color = color.new(color.red, 0),  style = plot.style_cross, linewidth = 1)
plot(showStop and shortSignal ? shortLevel - targetR * stopMult * atr  : na, "Short target",color = color.new(color.green, 0), style = plot.style_cross, linewidth = 1)

// -----------------------------------------------------------------------------
//  ALERTS
// -----------------------------------------------------------------------------
alertcondition(longSignal,  title = "Long breakout",  message = "ATR Breakout: LONG trigger on {{ticker}} @ {{close}}")
alertcondition(shortSignal, title = "Short breakout", message = "ATR Breakout: SHORT trigger on {{ticker}} @ {{close}}")
````
