# GC Overlay Pro v3.2

- url: https://www.tradingview.com/script/6TJ61M1a-GC-Overlay-Pro-v3-2/
- type: indicator
- pine_id: PUB;bcf69d3fdad74bdfa34c2c5a3997d6a5
- version: 1.0

## Description

GC Overlay Pro
Ghost Candle Volume Visualization

GC Overlay Pro is a volume visualization indicator that integrates statistical volume analysis directly into price candles. Instead of relying solely on a separate volume histogram, this indicator adjusts candle transparency based on the relative significance of each bar's volume.

The goal is to make important volume events immediately visible on the chart while reducing the need to constantly reference a separate volume indicator.

Features
Statistical Volume Analysis

Uses Z-Score calculations to identify statistically significant volume events rather than simple volume comparisons.

This allows volume to be normalized across:

Futures
Equities
ETFs
Forex
Crypto

and across different market conditions.

Ghost Candle Visualization

Price candles remain bullish or bearish according to their normal direction.

Only the transparency changes.

Higher volume candles become more visible while lower volume candles fade into the background.

This creates an immediate visual representation of market participation.

Volume Classification

Each candle is classified into one of four categories:

Classification	Default Z-Score
Extra High Volume	> 2.0
High Volume	> 1.25
Normal Volume	> 0.50
Low Volume	≤ 0.50
Hybrid Rendering

The indicator uses separate rendering for:

Candle body
Candle border
Candle wick

This creates a more natural ghost-candle appearance that closely mimics native TradingView candle rendering.

Alert Conditions

Built-in alerts are included for:

Bullish High Volume
Bullish Extra High Volume
Bearish High Volume
Bearish Extra High Volume
Typical Uses
Breakout Confirmation

Strong breakouts often occur on High or Extra High Volume.

The most visible candles on the chart frequently correspond to institutional participation.

Pullback Analysis

Low-volume pullbacks often appear as heavily faded candles.

These can indicate a lack of conviction against the prevailing trend.

Support and Resistance Validation

Volume reactions at:

Weekly levels
TPO references
Camarilla pivots
Prior session highs and lows

become easier to identify.

Volume Price Analysis (VPA)

Useful for traders applying:

Volume Spread Analysis
Volume Price Analysis
Auction Market Theory
Market Profile
TPO
Default Settings
Lookback Length: 7
Standard Deviation Length: 20

Extra High Threshold: 2.0
High Threshold: 1.25
Normal Threshold: 0.50

Transparency:
Extra High: 0
High: 35
Normal: 70
Low: 95
Notes

This indicator does not generate trading signals.

It is intended to provide additional context for price action and volume interpretation.

Volume should always be analyzed alongside market structure, support and resistance, trend context, and other tools.

## Source Code

````pine
//@version=6
indicator("GC Overlay Pro v3.2", shorttitle="GC Pro", overlay=true, max_bars_back=500)

//====================================================
// BEHAVIOUR OPTIONS
//====================================================

lookbackLength = input.int(7, "Lookback Length", minval=1)
stdevLength = input.int(20, "Standard Deviation Length", minval=2)

extraHighThreshold = input.float(2.0, "Extra High Std Dev Threshold", step=0.05)
highThreshold = input.float(1.25, "High Volume Std Dev Threshold", step=0.05)
normalThreshold = input.float(0.50, "Normal Volume Std Dev Threshold", step=0.05)

//====================================================
// DISPLAY OPTIONS
//====================================================

ghostPriceCandles = input.bool(true, "Ghosted Price Candles")
ghostWicks = input.bool(true, "Ghosted Wicks")
ghostBorders = input.bool(true, "Ghosted Borders")
showLabels = input.bool(false, "Volume Classification Labels")

//====================================================
// COLOURS
//====================================================

upColour = input.color(color.rgb(76, 175, 80), "Up Colour")
downColour = input.color(color.rgb(255, 51, 74), "Down Colour")

//====================================================
// TRANSPARENCY SETTINGS
//====================================================

extraHighTrans = input.int(0, "Above Extra High Volume Transparency", minval=0, maxval=100)
highTrans = input.int(35, "High To Extra High Volume Transparency", minval=0, maxval=100)
normalTrans = input.int(70, "Normal To High Volume Transparency", minval=0, maxval=100)
lowTrans = input.int(95, "Below Normal Volume Transparency", minval=0, maxval=100)

//====================================================
// VOLUME ENGINE
//====================================================

volMA = ta.sma(volume, lookbackLength)
volSTD = ta.stdev(volume, stdevLength)

zScore = volSTD > 0 ? (volume - volMA) / volSTD : 0.0

//====================================================
// CLASSIFICATION
//====================================================

isExtraHigh = zScore > extraHighThreshold
isHigh = zScore > highThreshold and zScore <= extraHighThreshold
isNormal = zScore > normalThreshold and zScore <= highThreshold
isLow = zScore <= normalThreshold

//====================================================
// TRANSPARENCY
//====================================================

bodyTrans = isExtraHigh ? extraHighTrans : isHigh ? highTrans : isNormal ? normalTrans : lowTrans

wickTrans = isExtraHigh ? 5 : isHigh ? math.min(bodyTrans + 10, 100) : isNormal ? math.min(bodyTrans + 15, 100) : math.min(bodyTrans + 5, 100)

borderTrans = isExtraHigh ? 10 : isHigh ? math.min(bodyTrans + 15, 100) : isNormal ? math.min(bodyTrans + 20, 100) : math.min(bodyTrans + 10, 100)

//====================================================
// DOJI LOGIC
//====================================================

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bullDoji = close == open and lowerWick > upperWick
bearDoji = close == open and upperWick >= lowerWick

isBull = close > open or bullDoji

//====================================================
// COLOURS
//====================================================

baseColour = isBull ? upColour : downColour

bodyColour = color.new(baseColour, bodyTrans)
wickColour = color.new(baseColour, ghostWicks ? wickTrans : 0)
borderColour = color.new(baseColour, ghostBorders ? borderTrans : 0)

//====================================================
// HYBRID GHOST RENDERING
//====================================================

barcolor(
     ghostPriceCandles ?
     color.new(baseColour, math.min(bodyTrans + 10, 100))
     : na)

plotcandle(
     ghostPriceCandles ? open : na,
     ghostPriceCandles ? high : na,
     ghostPriceCandles ? low : na,
     ghostPriceCandles ? close : na,
     title="Ghost Overlay",
     color=bodyColour,
     wickcolor=wickColour,
     bordercolor=borderColour)

//====================================================
// LABELS
//====================================================

volClass = isExtraHigh ? "EHV" : isHigh ? "HV" : isNormal ? "NV" : "LV"

if showLabels and barstate.isconfirmed
    label.new(
         bar_index,
         high,
         volClass,
         style=label.style_none,
         textcolor=baseColour,
         size=size.tiny)

//====================================================
// ALERTS
//====================================================

alertcondition(
     isBull and isHigh,
     title="Bullish High Volume",
     message="Bullish candle on High Volume")

alertcondition(
     isBull and isExtraHigh,
     title="Bullish Extra High Volume",
     message="Bullish candle on Extra High Volume")

alertcondition(
     not isBull and isHigh,
     title="Bearish High Volume",
     message="Bearish candle on High Volume")

alertcondition(
     not isBull and isExtraHigh,
     title="Bearish Extra High Volume",
     message="Bearish candle on Extra High Volume")
````
