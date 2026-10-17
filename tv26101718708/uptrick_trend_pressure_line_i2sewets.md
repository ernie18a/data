# Uptrick: Trend Pressure Line

- url: https://www.tradingview.com/script/I2sEWetS-Uptrick-Trend-Pressure-Line/
- type: indicator
- pine_id: PUB;63519f238f474cf6822e024b1e5e8a27
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Uptrick: Trend Pressure Line is a trend-following overlay that measures directional pressure by combining price displacement from a moving average, candle body strength, and short-term momentum into a single weighted composite. The composite is smoothed and converted into both a dynamic trend line and a bar coloring system, giving traders a continuous read on how strong buying or selling pressure is, rather than a simple binary trend flag.

[b][i]Originality[/i][/b]
While the script uses common building blocks such as an EMA baseline and ATR normalization, its originality lies in how these components are combined. Instead of relying on a single trend filter, the script blends three independently weighted pressure sources, price position relative to trend, candle body direction, and bar-to-bar momentum, into one normalized pressure value using user-adjustable weights. This composite pressure value is then used simultaneously to plot a smoothed adaptive trend line, generate a three-color gradient reflecting pressure intensity, calculate a reversal probability score based on how stretched pressure is relative to its recent range, and drive bar coloring through three separate selectable modes. No single one of these elements is novel on its own, but the integration of weighted multi-factor pressure scoring with a dedicated reversal exhaustion metric and multi-mode visual feedback is not a standard combination found in common trend or ATR-band indicators.

[b][i]Features[/i][/b]
[list]
[*]Weighted trend pressure engine combining price position, candle body, and momentum into one composite score
[*]Adjustable weighting for each of the three pressure components
[*]Smoothed adaptive trend line plotted directly on the chart
[*]Three-color gradient (bearish, neutral, bullish) that reflects live pressure intensity
[*]Up and down trend signals with optional cooldown to reduce repeated signals
[*]Four selectable signal anchor points (Default, High/Low, Close, Trend Line)
[*]Optional take profit signals based on an ATR multiple from entry
[*]Reversal probability calculation based on pressure stretch and distance from the trend line
[*]Adjustable reversal lookback and sensitivity settings
[*]Three selectable bar coloring modes (Reversal Probability, Latest Signal, Current Default)
[*]Strong and extreme pressure level alerts for both bullish and bearish conditions
[*]Dashboard table showing trend state, signal state, bars since last signal, pressure value, reversal percentage, bar mode, take profit status, ATR value, and trend line value
[*]Four selectable table positions
[*]19 distinct alert conditions covering signals, flips, pressure levels, and price/line crosses
[/list]
[b][i]Inputs[/i][/b]
[list]
[*]Source, Trend Length, ATR Length, Pressure Smoothness, and Line Smoothness control the core trend engine
[*]Price Position Weight, Candle Body Weight, and Momentum Weight control how the three pressure components are blended
[*]Show Up/Down Signals, Trend Threshold, Signal Cooldown, and Signal Anchor control signal generation and placement
[*]Show TP Signals and TP ATR Multiplier control the optional take profit logic
[*]Line Width, Gradient Sensitivity, Gradient Smoothness, and Bar Coloring Mode control the visual presentation
[*]Reversal Lookback, Reversal Sensitivity, and High Reversal Alert Level control the reversal probability calculation
[*]Strong Pressure Level and Extreme Pressure Level set the thresholds for pressure strength alerts
[*]Show Table and Table Position control the on-chart dashboard
[/list]
[b][i]How It Works[/i][/b]
The script builds a baseline using an EMA of price, then measures three separate pressures relative to ATR: how far price sits from that baseline, the strength of the current candle's body, and short-term momentum. These three values are combined using the user's weight settings and smoothed to produce a single pressure reading. This pressure reading is added to the baseline to draw the adaptive trend line, and it is also compared against a threshold to classify the market as bullish, bearish, or neutral, which drives the up and down signals. Separately, the script tracks how far current pressure is from its recent extreme and how far price has drifted from the trend line, combining both into a reversal probability percentage that increases as a trend becomes stretched.

[b][i]How to Use[/i][/b]
[list]
[*]Watch the trend line color and the dashboard Trend row together to identify the current directional bias at a glance
[*]Use the Up and Down labels as potential entry cues, and adjust Signal Cooldown if signals print too frequently on your chart's timeframe
[*]Adjust the three weight inputs (Price Position, Candle Body, Momentum) if you want the pressure reading to favor trend positioning, candle strength, or short-term speed, depending on your trading style
[*]Monitor the Reversal row on the dashboard as a trend matures; a rising percentage suggests the current move is becoming stretched and may be due for a pause or reversal
[*]Switch Bar Coloring Mode to Reversal Probability if you want the candles themselves to visually flag exhaustion, or to Latest Signal if you prefer bars colored by the most recent up/down call
[*]Enable Show TP Signals and set a TP ATR Multiplier if you want a visual marker for a fixed ATR-based profit target after each signal, then adjust the multiplier to match your own target distance
[*]Use Signal Anchor to reposition labels relative to price action, high/low, or the trend line itself depending on chart clutter or personal preference
[*]Set alerts on any of the nineteen available conditions to be notified of trend flips, pressure extremes, or price crossing the trend line without needing to watch the chart continuously
[/list]

[b][i]Conclusion[/i][/b]
Uptrick: Trend Pressure Line gives traders a single adaptive line and pressure reading that reflects the combined influence of price positioning, candle strength, and momentum, along with a built-in gauge for how exhausted the current trend may be. It is intended as a trend and exhaustion visualization tool rather than a standalone signal generator.

[quote]Disclaimer
This script is provided for informational and educational purposes only and does not constitute financial advice. Past performance, including any signals or visual patterns shown on the chart, is not indicative of future results. Trading involves substantial risk, and users should perform their own analysis and risk management before making trading decisions based on this or any other indicator.[/quote]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick
//@version=6

//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝ 
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗ 
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝

indicator("Uptrick: Trend Pressure Line", shorttitle="TPL", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpEngine = "01. Core Trend Engine"

src             = input.source(close, "Source", group=grpEngine)
trendLen        = input.int(34, "Trend Length", minval=1, group=grpEngine)
atrLen          = input.int(14, "ATR Length", minval=1, group=grpEngine)
pressureSmooth  = input.int(8, "Pressure Smoothness", minval=1, group=grpEngine)
lineSmoothLen   = input.int(7, "Line Smoothness", minval=1, group=grpEngine)

grpMix = "02. Pressure Formula"

priceWeight     = input.float(0.50, "Price Position Weight", step=0.05, group=grpMix)
bodyWeight      = input.float(0.30, "Candle Body Weight", step=0.05, group=grpMix)
momentumWeight  = input.float(0.20, "Momentum Weight", step=0.05, group=grpMix)

grpSignals = "03. Up / Down Signals"

enableSignals = input.bool(true, "Show Up / Down Signals", group=grpSignals)
threshold     = input.float(0.15, "Trend Threshold", step=0.01, group=grpSignals)
cooldownBars  = input.int(0, "Signal Cooldown", minval=0, group=grpSignals)

signalAnchor = input.string("Default", "Signal Anchor", options=[
     "Default",
     "High/Low",
     "Close",
     "Trend Line"
 ], group=grpSignals)

grpTp = "04. Take Profit Signals"

showTpSignals = input.bool(false, "Show TP Signals", group=grpTp)
tpAtrMult     = input.float(2.0, "TP ATR Multiplier", minval=0.1, step=0.1, group=grpTp)

grpVisual = "05. Visuals"

lineWidth = input.int(5, "Line Width", minval=1, maxval=8, group=grpVisual)

gradientSensitivity = input.float(1.20, "Gradient Sensitivity", minval=0.1, step=0.05, group=grpVisual)
gradientSmoothLen   = input.int(5, "Gradient Smoothness", minval=1, group=grpVisual)

barColorMode = input.string("Current Default", "Bar Coloring Mode", options=[
     "Reversal Probability",
     "Latest Signal",
     "Current Default"
 ], group=grpVisual)

grpReversal = "06. Reversal Probability"

reversalLookback    = input.int(50, "Reversal Lookback", minval=10, group=grpReversal)
reversalSensitivity = input.float(1.30, "Reversal Sensitivity", minval=0.1, step=0.05, group=grpReversal)
highReversalLevel   = input.float(70.0, "High Reversal Alert Level %", minval=1, maxval=100, step=1, group=grpReversal)

grpAlerts = "07. Extra Alert Levels"

strongPressureLevel  = input.float(0.75, "Strong Pressure Level", minval=0.1, step=0.05, group=grpAlerts)
extremePressureLevel = input.float(1.25, "Extreme Pressure Level", minval=0.1, step=0.05, group=grpAlerts)

grpTable = "08. Dashboard Table"

showTable = input.bool(true, "Show Table", group=grpTable)

tablePos = input.string("Top Right", "Table Position", options=[
     "Top Right",
     "Top Left",
     "Bottom Right",
     "Bottom Left"
 ], group=grpTable)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullMain    = color.new(#5CF0D7, 0)
bearMain    = color.new(#B32AC3, 0)
neutralMain = color.new(#FFD84D, 0)

darkBg      = color.new(#000104, 12)
headBg      = color.new(#111827, 0)
subHeadBg   = color.new(#1F2937, 0)
softBorder  = color.new(color.white, 55)

blackText   = color.new(#000000, 0)
whiteText   = color.white

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clamp(_x, _min, _max) =>
    math.max(_min, math.min(_x, _max))

f_colorGradient(_ratio, _colA, _colB) =>
    rA = color.r(_colA)
    gA = color.g(_colA)
    bA = color.b(_colA)
    rB = color.r(_colB)
    gB = color.g(_colB)
    bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

f_threeColorGradient(_ratio, _bear, _neutral, _bull) =>
    _ratio <= 0.5 ? f_colorGradient(_ratio * 2.0, _bear, _neutral) : f_colorGradient((_ratio - 0.5) * 2.0, _neutral, _bull)

f_tablePosition(_pos) =>
    _pos == "Top Left" ? position.top_left : _pos == "Bottom Right" ? position.bottom_right : _pos == "Bottom Left" ? position.bottom_left : position.top_right

f_stateText(_bull, _bear) =>
    _bull ? "𝓑𝓾𝓵𝓵𝓲𝓼𝓱" : _bear ? "𝓑𝓮𝓪𝓻𝓲𝓼𝓱" : "𝓝𝓮𝓾𝓽𝓻𝓪𝓵"

f_signalText(_sig) =>
    _sig == "bull" ? "𝓤𝓹" : _sig == "bear" ? "𝓓𝓸𝔀𝓷" : "𝓝𝓸𝓷𝓮"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend Pressure Engine
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

basis = ta.ema(src, trendLen)

atrValue = ta.atr(atrLen)
safeAtr = atrValue != 0.0 ? atrValue : syminfo.mintick

body = close - open
momentum = src - src[1]

pricePressure = (src - basis) / safeAtr
bodyPressure = body / safeAtr
momentumPressure = momentum / safeAtr

totalWeight = priceWeight + bodyWeight + momentumWeight
safeWeight = totalWeight != 0.0 ? totalWeight : 1.0

rawPressure = (pricePressure * priceWeight + bodyPressure * bodyWeight + momentumPressure * momentumWeight) / safeWeight
pressure = ta.ema(rawPressure, pressureSmooth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullTrend = pressure > threshold
bearTrend = pressure < -threshold
neutralTrend = not bullTrend and not bearTrend

trendFlipBull = bullTrend and bearTrend[1]
trendFlipBear = bearTrend and bullTrend[1]

neutralToBull = bullTrend and neutralTrend[1]
neutralToBear = bearTrend and neutralTrend[1]

bullToNeutral = neutralTrend and bullTrend[1]
bearToNeutral = neutralTrend and bearTrend[1]

var string lastSignal = ""
var int lastSignalBar = na

barsOk = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars

rawLong = bullTrend and not bullTrend[1]
rawShort = bearTrend and not bearTrend[1]

canLong = lastSignal != "bull"
canShort = lastSignal != "bear"

finalLong = enableSignals and rawLong and barsOk and canLong
finalShort = enableSignals and rawShort and barsOk and canShort

if finalLong
    lastSignalBar := bar_index
    lastSignal := "bull"

if finalShort
    lastSignalBar := bar_index
    lastSignal := "bear"

barsSinceSignal = na(lastSignalBar) ? na : bar_index - lastSignalBar

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Smooth Gradient Line
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rawTrendLine = basis + pressure * safeAtr
trendLine = ta.ema(rawTrendLine, lineSmoothLen)

smoothGradientPressure = ta.ema(pressure, gradientSmoothLen)

gradientRaw = 0.5 + smoothGradientPressure / (2.0 * gradientSensitivity)
gradientRatio = f_clamp(gradientRaw, 0.0, 1.0)

lineColor = f_threeColorGradient(gradientRatio, bearMain, neutralMain, bullMain)

a= plot(trendLine, "Trend Pressure Line", color=lineColor, linewidth=lineWidth)
fill(a, plot(close, color = color.new(color.black,100)), trendLine, close, color.new(lineColor,50), color.new(color.black,100))


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Reversal Probability
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pressureAbs = math.abs(pressure)

pressureExtreme = ta.highest(pressureAbs, reversalLookback)
pressureExtremeSafe = pressureExtreme != 0.0 ? pressureExtreme : 1.0

distanceFromLine = math.abs(close - trendLine) / safeAtr
pressureStretch = pressureAbs / pressureExtremeSafe

trendExhaustion = pressureStretch * 0.65 + distanceFromLine * 0.35

reversalProbabilityRaw = trendExhaustion / reversalSensitivity
reversalProbability = f_clamp(reversalProbabilityRaw, 0.0, 1.0)

reversalPercent = reversalProbability * 100.0

oppositeColor = bullTrend ? bearMain : bearTrend ? bullMain : neutralMain
reversalColor = f_colorGradient(reversalProbability, lineColor, oppositeColor)

highReversal = reversalPercent >= highReversalLevel
newHighReversal = highReversal and not highReversal[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bar Coloring
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

latestSignalColor = lastSignal == "bull" ? bullMain : lastSignal == "bear" ? bearMain : neutralMain
currentDefaultColor = lineColor

barColor = barColorMode == "Reversal Probability" ? reversalColor : barColorMode == "Latest Signal" ? latestSignalColor : currentDefaultColor

plotcandle(
     open,
     high,
     low,
     close,
     title="Trend Pressure Candles",
     color=barColor,
     wickcolor=barColor,
     bordercolor=barColor
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Take Profit Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float entryPrice = na
var bool tpHit = false

if finalLong
    entryPrice := close
    tpHit := false

if finalShort
    entryPrice := close
    tpHit := false

longTpLevel = entryPrice + safeAtr * tpAtrMult
shortTpLevel = entryPrice - safeAtr * tpAtrMult

longTpSignal = showTpSignals and lastSignal == "bull" and not tpHit and not na(entryPrice) and high >= longTpLevel
shortTpSignal = showTpSignals and lastSignal == "bear" and not tpHit and not na(entryPrice) and low <= shortTpLevel

if longTpSignal or shortTpSignal
    tpHit := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Anchors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longAnchorY = signalAnchor == "Close" ? close : signalAnchor == "Trend Line" ? trendLine : signalAnchor == "High/Low" ? low : na
shortAnchorY = signalAnchor == "Close" ? close : signalAnchor == "Trend Line" ? trendLine : signalAnchor == "High/Low" ? high : na

tpLongAnchorY = signalAnchor == "Close" ? close : signalAnchor == "Trend Line" ? trendLine : signalAnchor == "High/Low" ? high : na
tpShortAnchorY = signalAnchor == "Close" ? close : signalAnchor == "Trend Line" ? trendLine : signalAnchor == "High/Low" ? low : na

useAbsoluteAnchor = signalAnchor == "Close" or signalAnchor == "Trend Line" or signalAnchor == "High/Low"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(finalLong and not useAbsoluteAnchor, title="Long Default", location=location.belowbar, style=shape.labelup, text="𝓤𝓹", color=bullMain, textcolor=blackText, size=size.normal)
plotshape(finalShort and not useAbsoluteAnchor, title="Short Default", location=location.abovebar, style=shape.labeldown, text="𝓓𝓸𝔀𝓷", color=bearMain, textcolor=whiteText, size=size.normal)

plotshape(finalLong and useAbsoluteAnchor ? longAnchorY : na, title="Long Anchored", location=location.absolute, style=shape.labelup, text="𝓤𝓹", color=bullMain, textcolor=blackText, size=size.normal)
plotshape(finalShort and useAbsoluteAnchor ? shortAnchorY : na, title="Short Anchored", location=location.absolute, style=shape.labeldown, text="𝓓𝓸𝔀𝓷", color=bearMain, textcolor=whiteText, size=size.normal)

plotshape(longTpSignal and not useAbsoluteAnchor, title="Long TP Default", location=location.abovebar, style=shape.labeldown, text="𝓣𝓟", color=bullMain, textcolor=blackText, size=size.tiny)
plotshape(shortTpSignal and not useAbsoluteAnchor, title="Short TP Default", location=location.belowbar, style=shape.labelup, text="𝓣𝓟", color=bearMain, textcolor=whiteText, size=size.tiny)

plotshape(longTpSignal and useAbsoluteAnchor ? tpLongAnchorY : na, title="Long TP Anchored", location=location.absolute, style=shape.labeldown, text="𝓣𝓟", color=bullMain, textcolor=blackText, size=size.tiny)
plotshape(shortTpSignal and useAbsoluteAnchor ? tpShortAnchorY : na, title="Short TP Anchored", location=location.absolute, style=shape.labelup, text="𝓣𝓟", color=bearMain, textcolor=whiteText, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pressure Strength Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

strongBullPressure = pressure >= strongPressureLevel
strongBearPressure = pressure <= -strongPressureLevel

extremeBullPressure = pressure >= extremePressureLevel
extremeBearPressure = pressure <= -extremePressureLevel

newStrongBullPressure = strongBullPressure and not strongBullPressure[1]
newStrongBearPressure = strongBearPressure and not strongBearPressure[1]

newExtremeBullPressure = extremeBullPressure and not extremeBullPressure[1]
newExtremeBearPressure = extremeBearPressure and not extremeBearPressure[1]

lineCrossUp = ta.crossover(close, trendLine)
lineCrossDown = ta.crossunder(close, trendLine)

pressureCrossZeroUp = ta.crossover(pressure, 0)
pressureCrossZeroDown = ta.crossunder(pressure, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendText = f_stateText(bullTrend, bearTrend)
signalText = f_signalText(lastSignal)
barsText = na(barsSinceSignal) ? "𝓝/𝓐" : str.tostring(barsSinceSignal)
pressureText = str.tostring(pressure, "#.##")
atrText = str.tostring(atrValue, "#.####")
reversalText = str.tostring(reversalPercent, "#") + "%"
lineText = str.tostring(trendLine, format.mintick)
tpText = tpHit ? "𝓗𝓲𝓽" : showTpSignals ? "𝓐𝓬𝓽𝓲𝓿𝓮" : "𝓞𝓯𝓯"
barModeText = barColorMode == "Reversal Probability" ? "𝓡𝓮𝓿𝓮𝓻𝓼𝓪𝓵" : barColorMode == "Latest Signal" ? "𝓢𝓲𝓰𝓷𝓪𝓵" : "𝓓𝓮𝓯𝓪𝓾𝓵𝓽"

var table infoTable = table.new(
     f_tablePosition(tablePos),
     2,
     11,
     frame_color=color.new(color.white, 35),
     frame_width=1,
     border_color=softBorder,
     border_width=1
)

if barstate.isfirst
    table.merge_cells(infoTable, 0, 0, 1, 0)

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "𝓣𝓟𝓛", text_color=whiteText, bgcolor=headBg, text_halign=text.align_center)

    table.cell(infoTable, 0, 1, "𝓜𝓮𝓽𝓻𝓲𝓬", text_color=whiteText, bgcolor=subHeadBg)
    table.cell(infoTable, 1, 1, "𝓥𝓪𝓵𝓾𝓮", text_color=whiteText, bgcolor=subHeadBg)

    table.cell(infoTable, 0, 2, "𝓣𝓻𝓮𝓷𝓭", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 2, trendText, text_color=whiteText, bgcolor=lineColor)

    table.cell(infoTable, 0, 3, "𝓢𝓲𝓰𝓷𝓪𝓵", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 3, signalText, text_color=whiteText, bgcolor=latestSignalColor)

    table.cell(infoTable, 0, 4, "𝓑𝓪𝓻𝓼", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 4, barsText, text_color=whiteText, bgcolor=darkBg)

    table.cell(infoTable, 0, 5, "𝓟𝓻𝓮𝓼𝓼𝓾𝓻𝓮", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 5, pressureText, text_color=whiteText, bgcolor=lineColor)

    table.cell(infoTable, 0, 6, "𝓡𝓮𝓿𝓮𝓻𝓼𝓪𝓵", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 6, reversalText, text_color=whiteText, bgcolor=reversalColor)

    table.cell(infoTable, 0, 7, "𝓑𝓪𝓻 𝓜𝓸𝓭𝓮", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 7, barModeText, text_color=whiteText, bgcolor=barColor)

    table.cell(infoTable, 0, 8, "𝓣𝓟", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 8, tpText, text_color=whiteText, bgcolor=tpHit ? neutralMain : darkBg)

    table.cell(infoTable, 0, 9, "𝓐𝓣𝓡", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 9, atrText, text_color=whiteText, bgcolor=darkBg)

    table.cell(infoTable, 0, 10, "𝓛𝓲𝓷𝓮", text_color=whiteText, bgcolor=darkBg)
    table.cell(infoTable, 1, 10, lineText, text_color=whiteText, bgcolor=darkBg)

if not showTable and barstate.islast
    table.clear(infoTable, 0, 0, 1, 10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(finalLong, title="Up Signal", message="Uptrick TPL: Up signal printed")
alertcondition(finalShort, title="Down Signal", message="Uptrick TPL: Down signal printed")

alertcondition(longTpSignal, title="Long TP Signal", message="Uptrick TPL: Long TP reached")
alertcondition(shortTpSignal, title="Short TP Signal", message="Uptrick TPL: Short TP reached")

alertcondition(trendFlipBull, title="Bearish To Bullish Flip", message="Uptrick TPL: Trend flipped from bearish to bullish")
alertcondition(trendFlipBear, title="Bullish To Bearish Flip", message="Uptrick TPL: Trend flipped from bullish to bearish")

alertcondition(neutralToBull, title="Neutral To Bullish", message="Uptrick TPL: Trend moved from neutral to bullish")
alertcondition(neutralToBear, title="Neutral To Bearish", message="Uptrick TPL: Trend moved from neutral to bearish")

alertcondition(bullToNeutral, title="Bullish To Neutral", message="Uptrick TPL: Bullish trend cooled into neutral")
alertcondition(bearToNeutral, title="Bearish To Neutral", message="Uptrick TPL: Bearish trend cooled into neutral")

alertcondition(newHighReversal, title="High Reversal Probability", message="Uptrick TPL: Reversal probability reached alert level")

alertcondition(newStrongBullPressure, title="Strong Bull Pressure", message="Uptrick TPL: Strong bullish pressure detected")
alertcondition(newStrongBearPressure, title="Strong Bear Pressure", message="Uptrick TPL: Strong bearish pressure detected")

alertcondition(newExtremeBullPressure, title="Extreme Bull Pressure", message="Uptrick TPL: Extreme bullish pressure detected")
alertcondition(newExtremeBearPressure, title="Extreme Bear Pressure", message="Uptrick TPL: Extreme bearish pressure detected")

alertcondition(lineCrossUp, title="Price Crossed Above TPL", message="Uptrick TPL: Price crossed above the trend pressure line")
alertcondition(lineCrossDown, title="Price Crossed Below TPL", message="Uptrick TPL: Price crossed below the trend pressure line")

alertcondition(pressureCrossZeroUp, title="Pressure Crossed Above Zero", message="Uptrick TPL: Pressure crossed above zero")
alertcondition(pressureCrossZeroDown, title="Pressure Crossed Below Zero", message="Uptrick TPL: Pressure crossed below zero")
````
