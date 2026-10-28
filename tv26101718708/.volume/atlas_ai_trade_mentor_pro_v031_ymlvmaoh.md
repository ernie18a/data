# ATLAS AI Trade Mentor PRO v0.31

- url: https://www.tradingview.com/script/yMlvMaoH/
- type: indicator
- pine_id: PUB;15ba6e8f0d764cf9b58ddc7d4585abc5
- version: 1.0

## Description

ATLAS AI Trade Mentor PRO v0.31
ATLAS AI Trade Mentor PRO is an advanced Pine Script v6 indicator system designed to combine trend tracking, market structure analysis, momentum evaluation, and dynamic risk management into a unified AI-driven scoring engine.

It aims to filter out market noise, prevent false signals, and provide clean trade execution opportunities for both discretionary traders and algorithmic trading strategies.

🚀 Key Features
1. Trend & Momentum Scoring Engine
The indicator relies on a multi-dimensional logic rather than a single technical tool:

Trend Engine: Calculates a Trend Score (0 to 100) based on 20, 50, and 200 EMA slopes, moving average alignment, and ATR-based volatility channels.

Momentum & Volume: Integrates RSI and MACD confluence alongside volume spikes and volatility expansion to refine signal confidence.

Smart Score: Generates actionable BUY / SELL signals only when the threshold score (default: 65) is exceeded.

2. Market Structure Engine (BOS & CHOCH)
Pivot Swing Detection: Automatically identifies key swing highs and swing lows (HH, HL, LH, LL).

BOS (Break of Structure): Highlights trend continuation breaks directly on the chart.

CHOCH (Change of Character): Detects early structural trend shifts.

3. Automated Risk & Position Management
Dynamic Stop Loss / Take Profit: Calculates exact TP1, TP2, and Stop Loss levels dynamically upon trade entry.

ATR Trailing Stop: Protects accrued profits by trailing active trends.

Break-Even System: Moves the stop price to entry automatically once favorable price targets are hit.

4. Webhook & Automated Trading Ready
JSON Webhook Payload: Built-in JSON formatting makes it fully compatible with external brokerage APIs and automated execution bots.

Uses the modern alert() framework to send dynamic BUY, SELL, and EXIT payloads bar-by-bar.

5. On-Screen Live Dashboard
Includes a clean, transparent on-screen dashboard displaying:

Primary Trend Direction (BULL / BEAR / SIDE)

Long and Short Final Smart Scores

Confidence Level & Risk Assessment

AI Mentor: Real-time contextual trade advice (e.g., "SELL AFTER PULLBACK").

⚙️ How to Use
Recommended Timeframes: Best performance is achieved on 15m, 30m, and 1h timeframes.

Asset Compatibility: Compatible with equities, index futures, forex parities, and crypto assets.

Customization: Parameters like Minimum Signal Score, ATR Multipliers, and TP/SL percentages can be adjusted via the Inputs panel.

⚠️ Disclaimer:

This indicator is built strictly for educational and technical analysis purposes. It does not constitute financial or investment advice. Always backtest against your personal risk parameters before live execution.

## Source Code

````pine
//@version=6
indicator("ATLAS AI Trade Mentor PRO v0.31", overlay = true, max_lines_count = 500, max_labels_count = 500)

//==================================================
// INPUTS
//==================================================

groupTrend     = "Trend Engine"
groupStructure = "Structure Engine"
groupDashboard = "Dashboard"
groupMomentum  = "Momentum Engine"
groupVol       = "Volatility & Volume Engine"
groupSignal    = "Signal & Entry Engine"
groupRisk      = "Risk Management"

// Trend Inputs
ema20Len  = input.int(20, "EMA 20", minval = 1, group = groupTrend)
ema50Len  = input.int(50, "EMA 50", minval = 1, group = groupTrend)
ema200Len = input.int(200, "EMA 200", minval = 1, group = groupTrend)

atrLen   = input.int(14, "ATR Length", group = groupTrend)
slopeLen = input.int(5, "Slope Length", group = groupTrend)
adxLen   = input.int(14, "ADX Length", group = groupTrend)

// Structure Inputs
swingLen = input.int(5, "Swing Length", minval = 2, group = groupStructure)

// Dashboard & Visual Inputs
showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
showStructure = input.bool(true, "Show Structure", group = groupDashboard)
showSignals   = input.bool(true, "Show Signals", group = groupDashboard)

// Momentum Inputs
rsiLen     = input.int(14, "RSI Length", group = groupMomentum)
macdFast   = input.int(12, "MACD Fast", group = groupMomentum)
macdSlow   = input.int(26, "MACD Slow", group = groupMomentum)
macdSignal = input.int(9, "MACD Signal", group = groupMomentum)

// Signal Inputs
minScore   = input.int(65, "Minimum Signal Score", group = groupSignal)

// Risk Inputs
useTP     = input.bool(true, "TP Active", group = groupRisk)
useSL     = input.bool(true, "SL Active", group = groupRisk)
useTrail  = input.bool(true, "Trailing Stop Active", group = groupRisk)
useBE     = input.bool(true, "Break Even Active", group = groupRisk)

tp1Perc   = input.float(1.0, "TP1 %", step = 0.1, group = groupRisk)
tp2Perc   = input.float(2.0, "TP2 %", step = 0.1, group = groupRisk)
slPerc    = input.float(1.0, "Stop Loss %", step = 0.1, group = groupRisk)
trailATR  = input.float(2.0, "ATR Trailing Multiplier", step = 0.1, group = groupRisk)
beTrigger = input.float(1.0, "Break Even Trigger %", step = 0.1, group = groupRisk)

showRiskLines = input.bool(true, "Show TP SL Lines", group = groupRisk)

//==================================================
// EMA ENGINE
//==================================================

ema20  = ta.ema(close, ema20Len)
ema50  = ta.ema(close, ema50Len)
ema200 = ta.ema(close, ema200Len)

plot(ema20, color=color.aqua, linewidth=2)
plot(ema50, color=color.orange, linewidth=2)
plot(ema200, color=color.red, linewidth=2)

//==================================================
// ATR ENGINE
//==================================================

atr = ta.atr(atrLen)

//==================================================
// EMA SLOPE ENGINE
//==================================================

ema20Slope  = ema20 - ema20[slopeLen]
ema50Slope  = ema50 - ema50[slopeLen]
ema200Slope = ema200 - ema200[slopeLen]

//==================================================
// TREND SCORE ENGINE
//==================================================

fTrendScore() =>
    int score = 0

    if ema20 > ema50
        score += 15

    if ema50 > ema200
        score += 15

    if close > ema20
        score += 10

    if close > ema50
        score += 10

    if close > ema200
        score += 10

    if ema20Slope > 0
        score += 10

    if ema50Slope > 0
        score += 10

    if ema200Slope > 0
        score += 10

    fastMid = math.abs(ema20 - ema50)
    midSlow = math.abs(ema50 - ema200)

    if fastMid > atr * 0.30
        score += 5

    if midSlow > atr * 0.60
        score += 5

    math.min(score, 100)

trendScore = fTrendScore()

//==================================================
// MARKET STATE & QUALITY
//==================================================

marketState =
 trendScore >= 75 ? "UPTREND" :
 trendScore <= 25 ? "DOWNTREND" :
 "RANGE"

quality =
 trendScore >= 90 ? "A+" :
 trendScore >= 80 ? "A"  :
 trendScore >= 70 ? "B"  :
 trendScore >= 60 ? "C"  :
 "D"

//==================================================
// STRUCTURE ENGINE
//==================================================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float prevHigh = na

var float lastLow = na
var float prevLow = na

if not na(ph)
    prevHigh := lastHigh
    lastHigh := ph

if not na(pl)
    prevLow := lastLow
    lastLow := pl

higherHigh = not na(prevHigh) and lastHigh > prevHigh
lowerHigh  = not na(prevHigh) and lastHigh < prevHigh

higherLow = not na(prevLow) and lastLow > prevLow
lowerLow  = not na(prevLow) and lastLow < prevLow

structureText =
 higherHigh and higherLow ? "BULLISH" :
 lowerHigh and lowerLow   ? "BEARISH" :
 "TRANSITION"

//==================================================
// STRUCTURE SCORE
//==================================================

int structureScore = 0

structureScore += higherHigh ? 10 : 0
structureScore += higherLow  ? 10 : 0
structureScore -= lowerHigh  ? 10 : 0
structureScore -= lowerLow   ? 10 : 0

structureScore := math.max(-20, math.min(20, structureScore))

//==================================================
// BOS & CHOCH ENGINE
//==================================================

bullBOS = not na(lastHigh) and close > lastHigh
bearBOS = not na(lastLow) and close < lastLow

bosText =
 bullBOS ? "BULL BOS" :
 bearBOS ? "BEAR BOS" :
 "NONE"

bullCHOCH =
 lowerLow and
 close > ema20 and
 ema20Slope > 0

bearCHOCH =
 higherHigh and
 close < ema20 and
 ema20Slope < 0

chochText =
 bullCHOCH ? "BULL CHOCH" :
 bearCHOCH ? "BEAR CHOCH" :
 "NONE"

//==================================================
// DRAW STRUCTURE
//==================================================

plotshape(showStructure and bullBOS,
 title="Bull BOS",
 style=shape.triangleup,
 color=color.lime,
 size=size.tiny,
 location=location.belowbar)

plotshape(showStructure and bearBOS,
 title="Bear BOS",
 style=shape.triangledown,
 color=color.red,
 size=size.tiny,
 location=location.abovebar)

plotshape(showStructure and bullCHOCH,
 title="Bull CHOCH",
 style=shape.circle,
 color=color.aqua,
 size=size.tiny,
 location=location.belowbar)

plotshape(showStructure and bearCHOCH,
 title="Bear CHOCH",
 style=shape.circle,
 color=color.orange,
 size=size.tiny,
 location=location.abovebar)

//==================================================
// TREND BASE SCORES
//==================================================

int trendLongScore = 0

trendLongScore += trendScore >= 80 ? 25 :
                  trendScore >= 70 ? 20 :
                  trendScore >= 60 ? 15 :
                  trendScore >= 50 ? 10 : 0

trendLongScore += structureScore > 0 ? structureScore : 0

if bullBOS
    trendLongScore += 15

if bullCHOCH
    trendLongScore += 15

if close > ema20
    trendLongScore += 5

if close > ema50
    trendLongScore += 5

if close > ema200
    trendLongScore += 5

trendLongScore := math.min(trendLongScore, 100)

int trendShortScore = 0

trendShortScore += trendScore <= 20 ? 25 :
                   trendScore <= 30 ? 20 :
                   trendScore <= 40 ? 15 :
                   trendScore <= 50 ? 10 : 0

trendShortScore += structureScore < 0 ? math.abs(structureScore) : 0

if bearBOS
    trendShortScore += 15

if bearCHOCH
    trendShortScore += 15

if close < ema20
    trendShortScore += 5

if close < ema50
    trendShortScore += 5

if close < ema200
    trendShortScore += 5

trendShortScore := math.min(trendShortScore, 100)

//==================================================
// MOMENTUM ENGINE
//==================================================

rsi = ta.rsi(close, rsiLen)
rsiBull = rsi > 50
rsiBear = rsi < 50

[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)
macdBull = macdLine > signalLine and histLine > 0
macdBear = macdLine < signalLine and histLine < 0

//==================================================
// VOLATILITY & VOLUME ENGINE
//==================================================

atrValue = atr
atrMA    = ta.sma(atrValue, 50)

highVolatility = atrValue > atrMA
lowVolatility  = atrValue < atrMA

atrPercent = (atrValue / close) * 100

volatilityScore =
 atrPercent > 1.5 ? 20 :
 atrPercent > 0.8 ? 10 :
 5

volumeMA     = ta.sma(volume, 20)
volumeStrong = volume > volumeMA
volumeScore  = volumeStrong ? 10 : 0

//==================================================
// MOMENTUM SCORES
//==================================================

momentumLongScore =
 (rsiBull  ? 15 : 0) +
 (macdBull ? 15 : 0) +
 volatilityScore +
 volumeScore

momentumShortScore =
 (rsiBear  ? 15 : 0) +
 (macdBear ? 15 : 0) +
 volatilityScore +
 volumeScore

//==================================================
// FINAL SMART SCORES
//==================================================

longFinalScore  = trendLongScore + momentumLongScore
shortFinalScore = trendShortScore + momentumShortScore

longFinalScore  := math.min(longFinalScore, 100)
shortFinalScore := math.min(shortFinalScore, 100)

// Confidence Engine
confidence = math.max(longFinalScore, shortFinalScore)

confidenceText =
 confidence >= 80 ? "VERY STRONG" :
 confidence >= 60 ? "STRONG"      :
 confidence >= 40 ? "NORMAL"      :
 "WEAK"

//==================================================
// RISK ENGINE
//==================================================

emaCompression = math.abs(ema20 - ema50)

riskScore = 0

if atrValue > ta.sma(atrValue, 20)
    riskScore += 10

if emaCompression < atrValue * 0.25
    riskScore += 15

if marketState == "RANGE"
    riskScore += 15

riskText =
 riskScore <= 10 ? "LOW" :
 riskScore <= 20 ? "NORMAL" :
 "HIGH"

//==================================================
// ACTION & AI MENTOR ENGINE
//==================================================

string action = "WAIT"

if longFinalScore >= 85
    action := "STRONG BUY"
else if longFinalScore >= 70
    action := "BUY"
else if shortFinalScore >= 85
    action := "STRONG SELL"
else if shortFinalScore >= 70
    action := "SELL"
else
    action := "WAIT"

string mentor = "NO TRADE"

if action == "STRONG BUY"
    mentor := "TREND STRONG - BUY"

if action == "BUY"
    mentor := "BUY AFTER PULLBACK"

if action == "WAIT"
    mentor := "WAIT FOR BETTER SETUP"

if action == "SELL"
    mentor := "SELL AFTER PULLBACK"

if action == "STRONG SELL"
    mentor := "TREND STRONG - SELL"

// Bar Background
bgcolor(
 action == "STRONG BUY"  ? color.new(color.green, 92) :
 action == "STRONG SELL" ? color.new(color.red, 92)   :
 na)

//==================================================
// SMART ENTRY ENGINE
//==================================================

trendUp =
 close > ema20 and
 ema20 > ema50 and
 ema50 > ema200

trendDown =
 close < ema20 and
 ema20 < ema50 and
 ema50 < ema200

[plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxLen)

strongTrend = adxValue > 20
weakTrend   = adxValue < 15

longSetup =
 trendUp and
 rsiBull and
 macdBull and
 strongTrend

shortSetup =
 trendDown and
 rsiBear and
 macdBear and
 strongTrend

smartLong  = longSetup and longFinalScore >= minScore
smartShort = shortSetup and shortFinalScore >= minScore

var int signalState = 0

if smartLong
    signalState := 1

if smartShort
    signalState := -1

if showSignals and smartLong
    label.new(
     bar_index,
     low,
     "BUY\n" + str.tostring(longFinalScore),
     style=label.style_label_up,
     color=color.green,
     textcolor=color.white)

if showSignals and smartShort
    label.new(
     bar_index,
     high,
     "SELL\n" + str.tostring(shortFinalScore),
     style=label.style_label_down,
     color=color.red,
     textcolor=color.white)

signalText =
 smartLong  ? "LONG"  :
 smartShort ? "SHORT" :
 "WAIT"

//==================================================
// RISK MANAGEMENT ENGINE (TP / SL / TRAILING / BE)
//==================================================

var float entryPrice = na
var float stopPrice  = na
var float tp1Price   = na
var float tp2Price   = na
var float trailPrice = na

// LONG ENTRY
if smartLong
    entryPrice := close
    stopPrice  := close * (1 - slPerc / 100)
    tp1Price   := close * (1 + tp1Perc / 100)
    tp2Price   := close * (1 + tp2Perc / 100)
    trailPrice := na

// SHORT ENTRY
if smartShort
    entryPrice := close
    stopPrice  := close * (1 + slPerc / 100)
    tp1Price   := close * (1 - tp1Perc / 100)
    tp2Price   := close * (1 - tp2Perc / 100)
    trailPrice := na

// ATR TRAILING STOP
if useTrail and not na(entryPrice)
    if signalState == 1
        newTrail   = close - (atrValue * trailATR)
        trailPrice := na(trailPrice) ? newTrail : math.max(trailPrice, newTrail)

    if signalState == -1
        newTrail   = close + (atrValue * trailATR)
        trailPrice := na(trailPrice) ? newTrail : math.min(trailPrice, newTrail)

// BREAK EVEN
if useBE and not na(entryPrice)
    longBE  = close >= entryPrice * (1 + beTrigger / 100)
    shortBE = close <= entryPrice * (1 - beTrigger / 100)

    if signalState == 1 and longBE
        stopPrice := entryPrice

    if signalState == -1 and shortBE
        stopPrice := entryPrice

// ACTIVE STOP CALCULATION
activeStop = useTrail and not na(trailPrice) ? trailPrice : stopPrice

// CHART LEVELS
plot(showRiskLines ? entryPrice : na, "ENTRY", color=color.blue, style=plot.style_linebr)
plot(showRiskLines ? tp1Price : na,   "TP1",   color=color.green, style=plot.style_linebr)
plot(showRiskLines ? tp2Price : na,   "TP2",   color=color.lime, style=plot.style_linebr)
plot(showRiskLines ? activeStop : na, "STOP",  color=color.red, style=plot.style_linebr)

//==================================================
// EXIT CONDITIONS
//==================================================

longTP1  = signalState == 1 and close >= tp1Price
longTP2  = signalState == 1 and close >= tp2Price
longSL   = signalState == 1 and close <= activeStop

shortTP1 = signalState == -1 and close <= tp1Price
shortTP2 = signalState == -1 and close <= tp2Price
shortSL  = signalState == -1 and close >= activeStop

exitSignal = longTP1 or longTP2 or longSL or shortTP1 or shortTP2 or shortSL

//==================================================
// JSON WEBHOOK ENGINE
//==================================================

symbolName = syminfo.ticker

jsonMessage =
 smartLong ?
 '{"symbol":"' + symbolName +
 '","action":"BUY"' +
 '","price":"' + str.tostring(close) +
 '","score":"' + str.tostring(longFinalScore) +
 '","confidence":"' + confidenceText +
 '"}' :

 smartShort ?
 '{"symbol":"' + symbolName +
 '","action":"SELL"' +
 '","price":"' + str.tostring(close) +
 '","score":"' + str.tostring(shortFinalScore) +
 '","confidence":"' + confidenceText +
 '"}' :

 exitSignal ?
 '{"symbol":"' + symbolName +
 '","action":"EXIT"' +
 '","price":"' + str.tostring(close) +
 '"}' :

 ""

//==================================================
// ALERTS ENGINE
//==================================================

alertcondition(smartLong, title="AI LONG SIGNAL", message="LONG")
alertcondition(smartShort, title="AI SHORT SIGNAL", message="SHORT")
alertcondition(exitSignal, title="AI EXIT SIGNAL", message="EXIT")

// Dynamic JSON Webhook Alert Trigger
if smartLong or smartShort or exitSignal
    alert(jsonMessage, alert.freq_once_per_bar_close)

//==================================================
// DASHBOARD ENGINE (Transparent Background & Pure Black Text)
//==================================================

var table dash = table.new(position.top_right, 2, 8, bgcolor = color.new(color.white, 100), border_color = color.gray, border_width = 1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "AI TRADE ENGINE", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 0, "STATUS", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)

    table.cell(dash, 0, 1, "Trend", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 1, trendUp ? "BULL" : trendDown ? "BEAR" : "SIDE", text_color=trendUp ? color.green : trendDown ? color.red : color.black, text_size=size.small)

    table.cell(dash, 0, 2, "Long Score", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(longFinalScore), text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)

    table.cell(dash, 0, 3, "Short Score", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(shortFinalScore), text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)

    table.cell(dash, 0, 4, "Confidence", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 4, confidenceText, text_color=confidence >= 70 ? color.teal : color.orange, bgcolor=color.new(color.white, 100), text_size=size.small)

    table.cell(dash, 0, 5, "Signal", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 5, signalText, text_color=signalText == "LONG" ? color.green : signalText == "SHORT" ? color.red : color.black, bgcolor=color.new(color.white, 100), text_size=size.small)

    table.cell(dash, 0, 6, "Risk Level", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 6, riskText, text_color=riskText == "LOW" ? color.green : riskText == "NORMAL" ? color.orange : color.red, bgcolor=color.new(color.white, 100), text_size=size.small)

    table.cell(dash, 0, 7, "AI Mentor", text_color=color.black, bgcolor=color.new(color.white, 100), text_size=size.small)
    table.cell(dash, 1, 7, mentor, text_color=color.navy, bgcolor=color.new(color.white, 100), text_size=size.small)
````
