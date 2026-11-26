# RSI Ultimate Terminal [Institutional Edition]

- url: https://www.tradingview.com/script/rvnbAzVP/
- type: indicator
- pine_id: PUB;287e4d8d22554c8ab812f058e060b572
- version: 1.0

## Description

RSI ULTIMATE TERMINAL is an advanced Relative Strength Index based analysis tool designed for traders who want more context than a standard RSI oscillator.

The script expands traditional RSI interpretation by combining momentum state, zone behavior, and structured dashboard-style visualization into one interface.

Rather than using RSI only for overbought and oversold readings, this tool helps users observe momentum shifts, possible continuation phases, and reaction conditions in a more organized format.

Built for multi-market usage, it can be applied across different timeframes depending on the user’s trading style.

The focus of the script is clarity, structure, and efficient RSI-based chart analysis.

This tool may help users with:

Reading RSI momentum shifts
Monitoring overbought / oversold zones
Spotting possible pullback conditions
Supporting trend continuation analysis
Organizing RSI data through dashboard view
Improving chart workflow efficiency

Suitable for:

Momentum traders
Swing traders
Intraday traders
RSI strategy users
Multi-indicator traders
Users seeking clean dashboard tools

If structured momentum tools and dashboard-style indicators are part of your workflow, you may also find other research tools published on this profile valuable.

## Source Code

````pine
//@version=6
indicator("RSI ULTIMATE TERMINAL PRO", shorttitle="RSI UTP", overlay=false, max_labels_count=500, max_lines_count=500)

//=====================================================
// INPUTS
//=====================================================
group_core   = "Core Settings"
group_signal = "Signal Engine"
group_filter = "Filters"
group_style  = "Style / Dashboard"

src             = input.source(close, "RSI Source", group=group_core)
rsiLen          = input.int(14, "RSI Length", minval=2, group=group_core)
rsiEmaLen       = input.int(9, "RSI EMA Length", minval=1, group=group_core)
slopeLen        = input.int(5, "RSI Slope Length", minval=1, group=group_core)
volLookback     = input.int(20, "Volume Avg Length", minval=1, group=group_core)

baseUpper       = input.int(70, "Base Upper Zone", minval=50, maxval=95, group=group_signal)
baseLower       = input.int(30, "Base Lower Zone", minval=5, maxval=50, group=group_signal)
extremeUpper    = input.int(80, "Extreme Upper Zone", minval=55, maxval=99, group=group_signal)
extremeLower    = input.int(20, "Extreme Lower Zone", minval=1, maxval=45, group=group_signal)
midLevel        = input.int(50, "Mid Level", minval=1, maxval=99, group=group_signal)

useTrendFilter  = input.bool(true, "Use Trend Filter", group=group_filter)
trendEmaLen     = input.int(200, "Trend EMA Length", minval=2, group=group_filter)
useVolumeFilter = input.bool(true, "Use Volume Filter", group=group_filter)
volMultiplier   = input.float(1.0, "Volume Threshold Multiplier", minval=0.1, step=0.1, group=group_filter)
useContinuation = input.bool(true, "Enable Continuation Signals", group=group_filter)
useReversal     = input.bool(true, "Enable Reversal Signals", group=group_filter)

showDashboard   = input.bool(true, "Show Dashboard", group=group_style)
showBarColor    = input.bool(true, "Color RSI Plot", group=group_style)
showSignalMarks = input.bool(true, "Show Signal Marks", group=group_style)
showBgZones     = input.bool(true, "Show Background Zones", group=group_style)

//=====================================================
// CORE CALCULATIONS
//=====================================================
rsiValue   = ta.rsi(src, rsiLen)
rsiEma     = ta.ema(rsiValue, rsiEmaLen)
rsiSlope   = rsiValue - rsiValue[slopeLen]
rsiMom     = rsiValue - rsiValue[1]
rsiSpread  = rsiValue - rsiEma

priceTrendEma = ta.ema(close, trendEmaLen)
bullTrend     = close > priceTrendEma
bearTrend     = close < priceTrendEma

volAvg        = ta.sma(volume, volLookback)
highVolume    = volume > volAvg * volMultiplier

rsiStdev      = ta.stdev(rsiValue, rsiLen)
adaptiveBoost = math.min(8.0, rsiStdev * 0.35)

dynUpper      = math.min(90.0, baseUpper + adaptiveBoost)
dynLower      = math.max(10.0, baseLower - adaptiveBoost)
dynExtremeUp  = math.min(95.0, extremeUpper + adaptiveBoost * 0.5)
dynExtremeDn  = math.max(5.0, extremeLower - adaptiveBoost * 0.5)

//=====================================================
// STATE ENGINE
//=====================================================
inUpperZone    = rsiValue >= dynUpper
inLowerZone    = rsiValue <= dynLower
inExtremeUpper = rsiValue >= dynExtremeUp
inExtremeLower = rsiValue <= dynExtremeDn
aboveMid       = rsiValue > midLevel
belowMid       = rsiValue < midLevel

risingRsi      = rsiValue > rsiValue[1]
fallingRsi     = rsiValue < rsiValue[1]
bullCross      = ta.crossover(rsiValue, rsiEma)
bearCross      = ta.crossunder(rsiValue, rsiEma)

//=====================================================
// SIGNAL LOGIC
//=====================================================
revLongBase  = (inLowerZone or inExtremeLower) and bullCross and rsiSlope > 0 and risingRsi
revShortBase = (inUpperZone or inExtremeUpper) and bearCross and rsiSlope < 0 and fallingRsi

contLongBase  = useContinuation and aboveMid and bullCross and rsiSlope > 0 and rsiSpread > 0
contShortBase = useContinuation and belowMid and bearCross and rsiSlope < 0 and rsiSpread < 0

trendLongOk   = not useTrendFilter or bullTrend
trendShortOk  = not useTrendFilter or bearTrend
volOk         = not useVolumeFilter or highVolume

reversalLong  = useReversal and revLongBase and trendLongOk and volOk
reversalShort = useReversal and revShortBase and trendShortOk and volOk
contLong      = contLongBase and trendLongOk and volOk
contShort     = contShortBase and trendShortOk and volOk

exitLongWarn  = aboveMid and bearCross and rsiSlope < 0
exitShortWarn = belowMid and bullCross and rsiSlope > 0

//=====================================================
// QUALITY SCORE ENGINE
//=====================================================
scoreLong = 0.0
scoreLong += reversalLong ? 25 : 0
scoreLong += contLong ? 18 : 0
scoreLong += bullTrend ? 12 : 0
scoreLong += highVolume ? 10 : 0
scoreLong += rsiSlope > 0 ? math.min(15.0, math.abs(rsiSlope) * 2.0) : 0
scoreLong += rsiSpread > 0 ? math.min(10.0, math.abs(rsiSpread) * 1.3) : 0
scoreLong += rsiValue < 35 ? 10 : 0
scoreLong += rsiValue > midLevel ? 8 : 0

scoreShort = 0.0
scoreShort += reversalShort ? 25 : 0
scoreShort += contShort ? 18 : 0
scoreShort += bearTrend ? 12 : 0
scoreShort += highVolume ? 10 : 0
scoreShort += rsiSlope < 0 ? math.min(15.0, math.abs(rsiSlope) * 2.0) : 0
scoreShort += rsiSpread < 0 ? math.min(10.0, math.abs(rsiSpread) * 1.3) : 0
scoreShort += rsiValue > 65 ? 10 : 0
scoreShort += rsiValue < midLevel ? 8 : 0

finalLongScore  = math.min(100.0, scoreLong)
finalShortScore = math.min(100.0, scoreShort)

longQuality = finalLongScore >= 80 ? "ELITE" : finalLongScore >= 60 ? "STRONG" : finalLongScore >= 40 ? "MODERATE" : "WEAK"
shortQuality = finalShortScore >= 80 ? "ELITE" : finalShortScore >= 60 ? "STRONG" : finalShortScore >= 40 ? "MODERATE" : "WEAK"

//=====================================================
// LAST SIGNAL / BIAS
//=====================================================
var string lastSignal = "NONE"
var string activeBias = "NEUTRAL"

if reversalLong
    lastSignal := "REVERSAL LONG"
if reversalShort
    lastSignal := "REVERSAL SHORT"
if contLong
    lastSignal := "CONTINUATION LONG"
if contShort
    lastSignal := "CONTINUATION SHORT"

if aboveMid and rsiEma > midLevel
    activeBias := "BULLISH"
else if belowMid and rsiEma < midLevel
    activeBias := "BEARISH"
else
    activeBias := "NEUTRAL"

//=====================================================
// VISUAL STATES
//=====================================================
string zoneState = "NEUTRAL"
if inExtremeUpper
    zoneState := "EXTREME OVERBOUGHT"
else if inUpperZone
    zoneState := "OVERBOUGHT"
else if inExtremeLower
    zoneState := "EXTREME OVERSOLD"
else if inLowerZone
    zoneState := "OVERSOLD"
else if aboveMid
    zoneState := "BULLISH RANGE"
else
    zoneState := "BEARISH RANGE"

string volumeState = highVolume ? "HIGH" : "NORMAL"

string momentumState = "FLAT"
if rsiSlope > 5
    momentumState := "EXPLOSIVE UP"
else if rsiSlope > 1
    momentumState := "RISING"
else if rsiSlope < -5
    momentumState := "EXPLOSIVE DOWN"
else if rsiSlope < -1
    momentumState := "FALLING"

string signalState = "NO SIGNAL"
if reversalLong
    signalState := "REV LONG"
else if reversalShort
    signalState := "REV SHORT"
else if contLong
    signalState := "CONT LONG"
else if contShort
    signalState := "CONT SHORT"
else if exitLongWarn
    signalState := "EXIT LONG WARN"
else if exitShortWarn
    signalState := "EXIT SHORT WARN"

//=====================================================
// PLOT COLOR
//=====================================================
color plotColor = color.white
if showBarColor
    if rsiValue >= dynExtremeUp
        plotColor := color.red
    else if rsiValue >= dynUpper
        plotColor := color.orange
    else if rsiValue <= dynExtremeDn
        plotColor := color.lime
    else if rsiValue <= dynLower
        plotColor := color.aqua
    else if rsiValue >= rsiEma
        plotColor := color.green
    else
        plotColor := color.fuchsia

//=====================================================
// PLOTS
//=====================================================
plot(rsiValue, "RSI", color=plotColor, linewidth=2)
plot(rsiEma, "RSI EMA", color=color.yellow, linewidth=2)

hline(midLevel, "Mid", color=color.new(color.gray, 20), linestyle=hline.style_dashed)
hline(baseUpper, "Base Upper", color=color.new(color.orange, 55))
hline(baseLower, "Base Lower", color=color.new(color.aqua, 55))
hline(extremeUpper, "Extreme Upper", color=color.new(color.red, 65))
hline(extremeLower, "Extreme Lower", color=color.new(color.lime, 65))

plot(dynUpper, "Dynamic Upper", color=color.orange, linewidth=1, style=plot.style_linebr)
plot(dynLower, "Dynamic Lower", color=color.aqua, linewidth=1, style=plot.style_linebr)
plot(dynExtremeUp, "Dynamic Extreme Upper", color=color.red, linewidth=1, style=plot.style_linebr)
plot(dynExtremeDn, "Dynamic Extreme Lower", color=color.lime, linewidth=1, style=plot.style_linebr)

bgcolor(showBgZones and inExtremeUpper ? color.new(color.red, 88) : na)
bgcolor(showBgZones and inExtremeLower ? color.new(color.lime, 88) : na)
bgcolor(showBgZones and not inExtremeUpper and not inExtremeLower and inUpperZone ? color.new(color.orange, 92) : na)
bgcolor(showBgZones and not inExtremeUpper and not inExtremeLower and inLowerZone ? color.new(color.aqua, 92) : na)

//=====================================================
// SIGNAL MARKERS
//=====================================================
plotshape(showSignalMarks and reversalLong,  title="Reversal Long",      style=shape.triangleup,   location=location.bottom, color=color.lime,   size=size.small, text="REV L")
plotshape(showSignalMarks and reversalShort, title="Reversal Short",     style=shape.triangledown, location=location.top,    color=color.red,    size=size.small, text="REV S")
plotshape(showSignalMarks and contLong,      title="Continuation Long",  style=shape.circle,       location=location.bottom, color=color.green,  size=size.tiny,  text="C L")
plotshape(showSignalMarks and contShort,     title="Continuation Short", style=shape.circle,       location=location.top,    color=color.maroon, size=size.tiny,  text="C S")
plotshape(showSignalMarks and exitLongWarn,  title="Exit Long Warning",  style=shape.xcross,       location=location.top,    color=color.yellow, size=size.tiny,  text="XL")
plotshape(showSignalMarks and exitShortWarn, title="Exit Short Warning", style=shape.xcross,       location=location.bottom, color=color.yellow, size=size.tiny,  text="XS")

//=====================================================
// DASHBOARD HELPERS
//=====================================================
f_score_color(_score) =>
    _score >= 80 ? color.lime : _score >= 60 ? color.green : _score >= 40 ? color.orange : color.red

f_bias_color(_bias) =>
    _bias == "BULLISH" ? color.lime : _bias == "BEARISH" ? color.red : color.gray

f_zone_color(_zone) =>
    _zone == "EXTREME OVERBOUGHT" ? color.red :
     _zone == "OVERBOUGHT" ? color.orange :
     _zone == "EXTREME OVERSOLD" ? color.lime :
     _zone == "OVERSOLD" ? color.aqua :
     _zone == "BULLISH RANGE" ? color.green : color.fuchsia

//=====================================================
// DASHBOARD
//=====================================================
var table dash = table.new(position.top_right, 2, 10, border_width=1)

dominantScore   = math.max(finalLongScore, finalShortScore)
dominantQuality = finalLongScore >= finalShortScore ? longQuality : shortQuality

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "RSI TERMINAL", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "PRO", text_color=color.yellow, bgcolor=color.black)

    table.cell(dash, 0, 1, "RSI", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, str.tostring(rsiValue, "#.00"), text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 2, "RSI EMA", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, str.tostring(rsiEma, "#.00"), text_color=color.yellow, bgcolor=color.black)

    table.cell(dash, 0, 3, "Momentum", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, momentumState, text_color=rsiSlope >= 0 ? color.lime : color.red, bgcolor=color.black)

    table.cell(dash, 0, 4, "Bias", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, activeBias, text_color=f_bias_color(activeBias), bgcolor=color.black)

    table.cell(dash, 0, 5, "Zone", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, zoneState, text_color=f_zone_color(zoneState), bgcolor=color.black)

    table.cell(dash, 0, 6, "Volume", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, volumeState, text_color=highVolume ? color.lime : color.silver, bgcolor=color.black)

    table.cell(dash, 0, 7, "Signal", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, signalState, text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 8, "Quality", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 8, dominantQuality + " | " + str.tostring(dominantScore, "#"), text_color=f_score_color(dominantScore), bgcolor=color.black)

    table.cell(dash, 0, 9, "Last Signal", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 9, lastSignal, text_color=color.aqua, bgcolor=color.black)

//=====================================================
// ALERTS
//=====================================================
alertcondition(reversalLong,  title="RSI UTP Reversal Long",      message="RSI ULTIMATE TERMINAL PRO: Reversal Long signal detected.")
alertcondition(reversalShort, title="RSI UTP Reversal Short",     message="RSI ULTIMATE TERMINAL PRO: Reversal Short signal detected.")
alertcondition(contLong,      title="RSI UTP Continuation Long",  message="RSI ULTIMATE TERMINAL PRO: Continuation Long signal detected.")
alertcondition(contShort,     title="RSI UTP Continuation Short", message="RSI ULTIMATE TERMINAL PRO: Continuation Short signal detected.")
alertcondition(exitLongWarn,  title="RSI UTP Exit Long Warning",  message="RSI ULTIMATE TERMINAL PRO: Exit Long warning detected.")
alertcondition(exitShortWarn, title="RSI UTP Exit Short Warning", message="RSI ULTIMATE TERMINAL PRO: Exit Short warning detected.")
````
