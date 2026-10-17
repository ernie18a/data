# GC Volume Pro

- url: https://www.tradingview.com/script/Sur1EOEx-GC-Volume-Pro/
- type: indicator
- pine_id: PUB;1be8860dc7914b86a715a44d9b0f5cd8
- version: 1.0

## Description

GC Volume Pro
Statistical Volume Histogram Companion

GC Volume Pro is designed as the companion indicator to GC Overlay Pro.

It reproduces the same statistical volume classification engine in a dedicated volume pane while maintaining visual synchronization with the ghost candle overlay.

Features
Shared Classification Engine

Uses the exact same calculations as GC Overlay Pro:

Volume Moving Average
Standard Deviation
Z-Score Analysis
Volume Classification

This ensures candle opacity and histogram opacity remain synchronized.

Ghost Volume Histogram

Volume bars dynamically adjust transparency according to their statistical significance.

Higher volume bars become more visible.

Lower volume bars become increasingly transparent.

Volume Moving Average

Displays a configurable volume moving average to provide additional context for current volume activity.

The moving average is calculated using the same lookback period as the volume classification engine.

Asset Agnostic

Designed to work consistently across:

Futures
Stocks
ETFs
Crypto
Forex

No market-specific settings are required.

Optional Extreme Volume Suppression

Large outlier volume bars can optionally be hidden for visual clarity.

This can be useful when:

Reviewing historical sessions
Comparing intraday volume distributions
Preventing isolated spikes from compressing the entire pane
Volume Categories
Category	Default Z-Score
Extra High Volume	> 2.0
High Volume	> 1.25
Normal Volume	> 0.50
Low Volume	≤ 0.50
Typical Uses
Session Participation Analysis

Quickly identify periods of:

Institutional participation
Market acceptance
Market rejection

through changes in relative volume.

Trend Confirmation

Strong trends often maintain:

High Volume
Extra High Volume

while weakening trends may transition into:

Normal Volume
Low Volume
Auction Market Analysis

Useful alongside:

Market Profile
TPO
Volume Profile
Camarilla Pivots
VPA

for evaluating participation at key price levels.

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

## Source Code

````pine
//@version=6
indicator("GC Volume Pro", shorttitle="GC Vol", overlay=false)

//====================================================
// INPUTS
//====================================================

lookbackLength = input.int(
     7,
     "Lookback Length",
     minval=1)

stdevLength = input.int(
     20,
     "Standard Deviation Length",
     minval=2)

extraHighThreshold = input.float(
     2.0,
     "Extra High Std Dev Threshold",
     step=0.05)

highThreshold = input.float(
     1.25,
     "High Volume Std Dev Threshold",
     step=0.05)

normalThreshold = input.float(
     0.50,
     "Normal Volume Std Dev Threshold",
     step=0.05)

//====================================================
// DISPLAY OPTIONS
//====================================================

showMA = input.bool(
     true,
     "Show Volume MA")

ghostVolumeBars = input.bool(
     true,
     "Ghost Volume Bars")

suppressExtremeBars = input.bool(
     false,
     "Suppress Extreme Volume Bars")

//====================================================
// COLOURS
//====================================================

maColour = input.color(
     color.rgb(41,98,255),
     "Moving Average Colour")

upColour = input.color(
     color.rgb(76,175,80),
     "Up Colour")

downColour = input.color(
     color.rgb(255,51,74),
     "Down Colour")

//====================================================
// TRANSPARENCY SETTINGS
//====================================================

extraHighTrans = input.int(
     0,
     "Above Extra High Volume Transparency",
     minval=0,
     maxval=100)

highTrans = input.int(
     30,
     "High To Extra High Volume Transparency",
     minval=0,
     maxval=100)

normalTrans = input.int(
     60,
     "Normal To High Volume Transparency",
     minval=0,
     maxval=100)

lowTrans = input.int(
     90,
     "Below Normal Volume Transparency",
     minval=0,
     maxval=100)

//====================================================
// VOLUME ENGINE
//====================================================

volMA = ta.sma(volume, lookbackLength)

volSTD = ta.stdev(volume, stdevLength)

zScore =
     volSTD > 0
     ? (volume - volMA) / volSTD
     : 0

//====================================================
// CLASSIFICATION
//====================================================

isExtraHigh =
     zScore > extraHighThreshold

isHigh =
     zScore > highThreshold and
     zScore <= extraHighThreshold

isNormal =
     zScore > normalThreshold and
     zScore <= highThreshold

isLow =
     zScore <= normalThreshold

//====================================================
// TRANSPARENCY
//====================================================

transparency =
     isExtraHigh ? extraHighTrans :
     isHigh      ? highTrans :
     isNormal    ? normalTrans :
                   lowTrans

//====================================================
// VOLUME COLOURING
//====================================================

isBull =
     close >= open

volColour =
     color.new(
         isBull
         ? upColour
         : downColour,
         ghostVolumeBars
         ? transparency
         : 0)

//====================================================
// OPTIONAL EXTREME BAR SUPPRESSION
//====================================================

displayVolume =
     suppressExtremeBars and volume > (volMA * 8)
     ? na
     : volume

//====================================================
// HISTOGRAM
//====================================================

plot(
     displayVolume,
     title="Volume",
     style=plot.style_columns,
     color=volColour)

//====================================================
// MOVING AVERAGE
//====================================================

plot(
     showMA ? volMA : na,
     title="Volume MA",
     color=maColour,
     linewidth=2,
     trackprice=false)

//====================================================
// DATA WINDOW VALUES
//====================================================

plotchar(
     zScore,
     title="Volume Z-Score",
     char="",
     location=location.top,
     editable=false)

plotchar(
     volMA,
     title="Volume Moving Average",
     char="",
     location=location.top,
     editable=false)
````
