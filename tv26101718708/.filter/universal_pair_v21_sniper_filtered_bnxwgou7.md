# Universal Pair v2.1 - Sniper Filtered

- url: https://www.tradingview.com/script/BnxWgoU7-Universal-Pair-v2-1-Sniper-Filtered/
- type: indicator
- pine_id: PUB;04c681c64d0444ababd96b09edfb25b2
- version: 1.0

## Description

pairs w/ v2.1
briang790
QQQ-TQQQ-SQQQ
trade with above

## Source Code

````pine
//@version=6
indicator("Universal Pair v2.1 - Sniper Filtered", overlay=true, max_labels_count=100)

// =========================
// Inputs
// =========================
pair = input.string("QQQ / SQQQ", "Pair", options=[
     "MSTR / MSTZ",
     "QQQ / SQQQ",
     "TSLA / TSLZ",
     "NVDA / NVDS",
     "SPY / SPXU",
     "Custom"
])

customBase = input.symbol("NASDAQ:QQQ", "Custom Base Symbol")
customInv  = input.symbol("NASDAQ:SQQQ", "Custom Inverse Symbol")

orbMinutes      = input.int(15, "Opening Range Minutes", minval=1)
useORB          = input.bool(true, "Use Opening Range Filter")
useOneSignal    = input.bool(true, "One Signal Per Direction")
useVolumeFilter = input.bool(true, "Use Volume Filter")
useInvConfirm   = input.bool(true, "Use Inverse Confirmation")
showVWAP        = input.bool(true, "Show VWAP")
showORB         = input.bool(true, "Show ORB High/Low")
showBackground  = input.bool(true, "Show Background")
showBiasDots    = input.bool(true, "Show Bias Dots")
showSignals     = input.bool(true, "Show Signals")
showTable       = input.bool(true, "Show Status Table")

rsiLen          = input.int(14, "RSI Length", minval=2)
macdFast        = input.int(12, "MACD Fast", minval=1)
macdSlow        = input.int(26, "MACD Slow", minval=1)
macdSignalLen   = input.int(9, "MACD Signal", minval=1)
volLen          = input.int(20, "Volume SMA Length", minval=1)
volMult         = input.float(0.90, "Volume Threshold", minval=0.1, step=0.05)
trendPct        = input.float(0.15, "Min Distance From VWAP %", minval=0.01, step=0.01)

// =========================
// Symbol Mapping
// =========================
string base = switch pair
    "MSTR / MSTZ" => "NASDAQ:MSTR"
    "QQQ / SQQQ"  => "NASDAQ:QQQ"
    "TSLA / TSLZ" => "NASDAQ:TSLA"
    "NVDA / NVDS" => "NASDAQ:NVDA"
    "SPY / SPXU"  => "AMEX:SPY"
    => customBase

string inv = switch pair
    "MSTR / MSTZ" => "CBOE:MSTZ"
    "QQQ / SQQQ"  => "NASDAQ:SQQQ"
    "TSLA / TSLZ" => "CBOE:TSLZ"
    "NVDA / NVDS" => "NASDAQ:NVDS"
    "SPY / SPXU"  => "AMEX:SPXU"
    => customInv

pairLabel = pair == "Custom" ? "CUSTOM" : pair

// =========================
// Pull Data
// =========================
bOpen  = request.security(base, timeframe.period, open)
bHigh  = request.security(base, timeframe.period, high)
bLow   = request.security(base, timeframe.period, low)
bClose = request.security(base, timeframe.period, close)
bVol   = request.security(base, timeframe.period, volume)

iOpen  = request.security(inv, timeframe.period, open)
iClose = request.security(inv, timeframe.period, close)

// =========================
// Indicators
// =========================
[bMacd, bMacdSignal, _] = ta.macd(bClose, macdFast, macdSlow, macdSignalLen)
bRsi = ta.rsi(bClose, rsiLen)
bVolAvg = ta.sma(bVol, volLen)

// =========================
// Session Reset VWAP
// =========================
newDay = ta.change(time("D")) != 0
typical = (bHigh + bLow + bClose) / 3.0

var float cumTPV = na
var float cumVol = na

if newDay
    cumTPV := typical * bVol
    cumVol := bVol
else
    cumTPV := nz(cumTPV) + typical * bVol
    cumVol := nz(cumVol) + bVol

vwap = cumTPV / cumVol

// =========================
// Opening Range
// =========================
var float orbHigh = na
var float orbLow = na
var int dayStartBar = na

if newDay or na(dayStartBar)
    orbHigh := na
    orbLow := na
    dayStartBar := bar_index

barsFromOpen = bar_index - dayStartBar
orbBars = math.max(1, math.ceil(orbMinutes / timeframe.multiplier))
inORB = barsFromOpen < orbBars

if inORB
    orbHigh := na(orbHigh) ? bHigh : math.max(orbHigh, bHigh)
    orbLow  := na(orbLow)  ? bLow  : math.min(orbLow, bLow)

// =========================
// State
// =========================
aboveVWAP = bClose > vwap
belowVWAP = bClose < vwap
macdBull  = bMacd > bMacdSignal
macdBear  = bMacd < bMacdSignal
bullCandle = bClose > bOpen
bearCandle = bClose < bOpen
momUp = bClose > bClose[1]
momDn = bClose < bClose[1]

volOkay = useVolumeFilter ? (bVol > bVolAvg * volMult) : true

invWeak = iClose < iOpen or iClose < iClose[1]
invStrong = iClose > iOpen or iClose > iClose[1]

callConf = useInvConfirm ? invWeak : true
putConf  = useInvConfirm ? invStrong : true

// =========================
// Sniper Trend Filter
// =========================
trendStrength = math.abs(bClose - vwap)
minMove = bClose * (trendPct / 100.0)
validTrend = trendStrength > minMove

// =========================
// Strict Directional Setup
// =========================
callSetup =
     aboveVWAP and
     macdBull and
     callConf and
     validTrend

putSetup =
     belowVWAP and
     macdBear and
     putConf and
     validTrend

// =========================
// ORB Filter
// =========================
orbBreakUp = not na(orbHigh) and bClose > orbHigh
orbBreakDown = not na(orbLow) and bClose < orbLow

callReady = callSetup and bullCandle and momUp and volOkay and (not useORB or orbBreakUp)
putReady  = putSetup and bearCandle and momDn and volOkay and (not useORB or orbBreakDown)

// =========================
// One Signal Per Direction Per Day
// =========================
var bool tookCall = false
var bool tookPut = false

if newDay
    tookCall := false
    tookPut := false

callSignal = callReady and not callReady[1] and (not useOneSignal or not tookCall)
putSignal  = putReady and not putReady[1] and (not useOneSignal or not tookPut)

if callSignal
    tookCall := true

if putSignal
    tookPut := true

// =========================
// No Trade Zone
// =========================
noTradeZone = not validTrend or (aboveVWAP and macdBear) or (belowVWAP and macdBull)

// =========================
// Bias
// =========================
callBias = callSetup and not noTradeZone
putBias  = putSetup and not noTradeZone

biasText = callBias ? "CALL" : putBias ? "PUT" : "NEUTRAL"
signalText = callSignal ? "CALL" : putSignal ? "PUT" : "WAIT"

// =========================
// Plotting
// =========================
plot(showVWAP ? vwap : na, title="VWAP", color=color.yellow, linewidth=2)
plot(showORB ? orbHigh : na, title="ORB High", color=color.green, linewidth=1, style=plot.style_line)
plot(showORB ? orbLow : na, title="ORB Low", color=color.red, linewidth=1, style=plot.style_line)

bgcolor(
     showBackground
     ? noTradeZone ? color.new(color.gray, 88)
     : callBias ? color.new(color.green, 90)
     : putBias ? color.new(color.red, 90)
     : na
     : na
)

plotshape(showBiasDots and callBias, title="Call Bias Dot", style=shape.circle, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny)
plotshape(showBiasDots and putBias, title="Put Bias Dot", style=shape.circle, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)

plotshape(showSignals and callSignal, title="CALL", text="CALL", style=shape.arrowup, location=location.belowbar, color=color.lime, size=size.large, textcolor=color.white)
plotshape(showSignals and putSignal, title="PUT", text="PUT", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.large, textcolor=color.white)

// =========================
// Status Table
// =========================
var table t = table.new(position.top_right, 2, 10, border_width=1)

if barstate.islast and showTable
    table.cell(t, 0, 0, "PAIR", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, pairLabel, text_color=color.white, bgcolor=color.gray)

    table.cell(t, 0, 1, "BIAS", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 1, biasText, text_color=color.white, bgcolor=callBias ? color.green : putBias ? color.red : color.gray)

    table.cell(t, 0, 2, "VWAP", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 2, aboveVWAP ? "ABOVE" : "BELOW", text_color=color.white, bgcolor=aboveVWAP ? color.green : color.red)

    table.cell(t, 0, 3, "MACD", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 3, macdBull ? "BULL" : "BEAR", text_color=color.white, bgcolor=macdBull ? color.green : color.red)

    table.cell(t, 0, 4, "RSI", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 4, str.tostring(math.round(bRsi)), text_color=color.white, bgcolor=color.gray)

    table.cell(t, 0, 5, "INVERSE", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 5, invWeak ? "WEAK" : invStrong ? "STRONG" : "MIXED", text_color=color.white, bgcolor=invWeak ? color.green : invStrong ? color.red : color.gray)

    table.cell(t, 0, 6, "VOLUME", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 6, volOkay ? "OK" : "LOW", text_color=color.white, bgcolor=volOkay ? color.green : color.gray)

    table.cell(t, 0, 7, "TREND", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 7, validTrend ? "VALID" : "WEAK", text_color=color.white, bgcolor=validTrend ? color.green : color.gray)

    table.cell(t, 0, 8, "ZONE", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 8, noTradeZone ? "NO TRADE" : "ACTIVE", text_color=color.white, bgcolor=noTradeZone ? color.gray : color.green)

    table.cell(t, 0, 9, "SIGNAL", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 9, signalText, text_color=color.white, bgcolor=callSignal ? color.green : putSignal ? color.red : color.gray)

// =========================
// Alerts
// =========================
alertcondition(callSignal, title="Universal Pair v2.1 CALL", message="Universal Pair v2.1 CALL signal")
alertcondition(putSignal, title="Universal Pair v2.1 PUT", message="Universal Pair v2.1 PUT signal")
````
