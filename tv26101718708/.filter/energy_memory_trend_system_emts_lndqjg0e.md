#  Energy Memory Trend System (EMTS)

- url: https://www.tradingview.com/script/lNdQjG0E/
- type: indicator
- pine_id: PUB;2a2074f8616e4a43ba8f0f81cb983383
- version: 1.0

## Description

# Energy Memory Trend System (EMTS)

Energy Memory Trend System (EMTS) is a trend-following engine designed to detect changes in market behavior through the combination of volatility, volume, and momentum.

Unlike traditional trend indicators that rely primarily on moving average crossovers, EMTS attempts to identify when market energy expands beyond its normal range and enters a new directional phase.

The core of the system is built around a proprietary Directional Memory Engine (DME), which combines:

• ATR (Volatility Expansion)
• Volume Participation
• Rate of Change (Directional Momentum)

These three components are merged into a single energy stream that represents the market's underlying directional pressure.

EMTS then constructs Bollinger Bands directly on the DME itself rather than on price. This allows the system to measure when bullish or bearish energy exceeds its historical memory range.

When the DME breaks above its upper memory band, bullish pressure is considered dominant and a bullish trend rail is activated.

When the DME breaks below its lower memory band, bearish pressure becomes dominant and a bearish trend rail is activated.

The result is a dynamic trend model that reacts to shifts in market energy rather than simple price fluctuations.

### Key Features

• Volatility, Volume, and Momentum Integration
• Proprietary Directional Memory Engine (DME)
• Self-Adaptive Energy Bands
• Dynamic Bull and Bear Trend Rails
• Reduced Sensitivity to Market Noise
• Trend Continuation and Regime Shift Detection
• Designed for Medium and Long-Term Trend Analysis

### Interpretation

🟢 Bull Rail Active

The market is showing bullish energy expansion beyond its normal memory range. This suggests increasing upward pressure and potential trend continuation.

🔴 Bear Rail Active

The market is showing bearish energy expansion beyond its normal memory range. This suggests increasing downward pressure and potential trend continuation.

### Important Note

EMTS is not designed to predict exact tops or bottoms. Its objective is to identify when market energy shifts strongly enough to justify a trend state change.

As with all technical tools, EMTS should be used alongside proper risk management and additional market analysis.

## Source Code

````pine
//@version=6
indicator("Grand Trend Engine • DME Own BB Rails", overlay=true)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
atrLen       = input.int(14, "GTE ATR Length", minval=1)
trendLen     = input.int(34, "GTE Base Length", minval=1)
atrMult      = input.float(2.4, "GTE ATR Multiplier", step=0.1)

dmeRocLen    = input.int(9, "DME ROC Length", minval=1)
dmeSmoothLen = input.int(5, "DME Smooth", minval=1)
dmeBbLen     = input.int(34, "DME Own BB Length", minval=2)
dmeBbMult    = input.float(2.0, "DME Own BB Multiplier", step=0.1)

showBase     = input.bool(true, "Show GTE Base")
showBars     = input.bool(true, "Color Candles")

bullC = input.color(color.lime, "Bull Color")
bearC = input.color(color.red, "Bear Color")
midC  = input.color(color.gray, "Neutral Color")

//━━━━━━━━━━━━━━━━━━━
// GTE PRICE RAILS
//━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
gteBase = ta.ema(close, trendLen)

bullBase = gteBase - atr * atrMult
bearBase = gteBase + atr * atrMult

//━━━━━━━━━━━━━━━━━━━
// DIRECTIONAL MEMORY ENGINE
// DME = sqrt(ATR) × ln(Volume + 1) × ROC
//━━━━━━━━━━━━━━━━━━━
dmeVol = math.log(volume + 1)
dmeRoc = ta.roc(close, dmeRocLen)

rawDME = math.sqrt(atr) * dmeVol * dmeRoc
dme    = ta.ema(rawDME, dmeSmoothLen)

//━━━━━━━━━━━━━━━━━━━
// DME OWN BOLLINGER BAND
//━━━━━━━━━━━━━━━━━━━
dmeBasis = ta.sma(dme, dmeBbLen)
dmeDev   = ta.stdev(dme, dmeBbLen)

dmeUpper = dmeBasis + dmeDev * dmeBbMult
dmeLower = dmeBasis - dmeDev * dmeBbMult

bullMemory = dme > dmeUpper
bearMemory = dme < dmeLower

//━━━━━━━━━━━━━━━━━━━
// TREND STATE
//━━━━━━━━━━━━━━━━━━━
var int trendDir = 0
var float trendLine = na

if bullMemory and trendDir != 1
    trendDir := 1
    trendLine := bullBase

else if bearMemory and trendDir != -1
    trendDir := -1
    trendLine := bearBase
 
else
    if trendDir == 1
        trendLine := math.max(nz(trendLine[1], bullBase), bullBase)
    else if trendDir == -1
        trendLine := math.min(nz(trendLine[1], bearBase), bearBase)
    else
        trendLine := na

//━━━━━━━━━━━━━━━━━━━
// ACTIVE RAILS
//━━━━━━━━━━━━━━━━━━━
bullRail = trendDir == 1 ? trendLine : na
bearRail = trendDir == -1 ? trendLine : na

//━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━
plot(showBase ? gteBase : na, "GTE Base", color=color.new(color.white, 70), linewidth=1)

plot(bullRail, "Bull DME BB Rail", color=bullC, linewidth=3, style=plot.style_linebr)
plot(bearRail, "Bear DME BB Rail", color=bearC, linewidth=3, style=plot.style_linebr)

barcolor(showBars ? trendDir == 1 ? color.new(bullC, 55) : trendDir == -1 ? color.new(bearC, 55) : na : na)

//━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━
bullTurn = bullMemory and trendDir[1] != 1
bearTurn = bearMemory and trendDir[1] != -1

plotshape(bullTurn, title="Bull Memory BB Break", style=shape.circle, location=location.belowbar, color=bullC, size=size.tiny, text="BB+")
plotshape(bearTurn, title="Bear Memory BB Break", style=shape.circle, location=location.abovebar, color=bearC, size=size.tiny, text="BB-")

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(bullTurn, "Bull DME BB Break", "DME broke above its own BB and activated bull GTE rail.")
alertcondition(bearTurn, "Bear DME BB Break", "DME broke below its own BB and activated bear GTE rail.")
````
