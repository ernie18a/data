# Clean MA Overlay PRO

- url: https://www.tradingview.com/script/hGdZiYti/
- type: indicator
- pine_id: PUB;3a4d3b46675c40268e663d0a7965f2a8
- version: 1.0

## Description

Clean MA Overlay PRO is a professional trend-following moving average system designed to combine clean market structure, volatility visualization, and real-time momentum strength analysis into a single lightweight overlay indicator.

Unlike traditional moving averages that only show direction, this indicator measures the true angle of the moving average using ATR-normalized slope calculations.
This creates a much more realistic representation of trend strength across all market conditions and timeframes.

The result is a highly responsive MA system optimized for fast trend recognition, momentum continuation, pullback filtering, and intraday trading — especially effective on indices like NASDAQ, US100, and high-volatility assets.

FEATURES
Adaptive Moving Average Engine

Choose between multiple MA types:

EMA
SMA
WMA
VWMA
RMA
HMA

The moving average can be applied to any source input and fully customized to match different trading styles.

True MA Angle Detection

The indicator calculates the actual MA angle using:

ATR-normalized slope
Configurable lookback distance
Real geometric angle conversion in degrees

This avoids the common problem of fake visual steepness caused by chart scaling.

The angle system classifies trend strength into:

WEAK
IDEAL LONG / SHORT
STRONG LONG / SHORT
EXTREME LONG / SHORT

This allows traders to instantly recognize:

trend acceleration
trend exhaustion
momentum shifts
weak ranging environments
Dynamic Momentum Coloring

The MA line changes color automatically depending on trend strength and direction.

Bullish Momentum
Soft Green → Ideal Long
Bright Green → Strong Long
Neon Green → Extreme Long
Bearish Momentum
Pink/Red → Ideal Short
Bright Red → Strong Short
Neon Red → Extreme Short
Neutral Conditions
Yellow → Weak or ranging market

This creates an instant visual momentum map directly on the chart.

Volatility Expansion Bands

The indicator includes dynamic standard deviation bands around the MA.

These bands help visualize:

volatility expansion
momentum compression
trend continuation zones
pullback areas

Two adaptive band layers are calculated:

Inner deviation band
Outer deviation band

The fill colors automatically adapt to market direction.

Clean Professional Design

The script was built with a minimalistic and distraction-free layout:

clean overlays
smooth fills
no unnecessary signals
lightweight performance
highly readable during fast market movement

Perfect for scalping, day trading, and momentum trading.

IDEAL USE CASES
NASDAQ / US100 scalping
Momentum trading
Trend continuation entries
Pullback filtering
Trend strength confirmation
Intraday trading
Volatility expansion analysis
HOW TO USE
Bullish Environment
MA turns green
Angle increases positively
Bands expand upward

The stronger the angle, the stronger the bullish momentum.

Bearish Environment
MA turns red
Angle becomes negative
Bands expand downward

Extreme angles often indicate strong directional momentum or possible exhaustion phases.

Weak / Sideways Market
MA turns yellow
Low angle values
Narrow volatility bands

Useful for avoiding low-quality entries during consolidation.

ANGLE SYSTEM EXPLANATION

The angle calculation is based on:

Moving average slope
ATR normalization
Mathematical arctangent conversion

This creates consistent angle readings regardless of zoom level or chart scaling.

Example:

5° → weak trend
10° → healthy trend
20°+ → aggressive momentum
25°+ → extreme trend conditions
OPTIMIZED FOR
NASDAQ M1 / M5
US Indices
Crypto
Volatile assets
Momentum environments
KEY ADVANTAGE

Most moving averages only show direction.

Clean MA Overlay PRO shows:

direction
momentum quality
trend intensity
volatility behavior
real trend angle

all in one clean overlay system.

## Source Code

````pine
//@version=6
indicator("Clean MA Overlay PRO", overlay=true)

//━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━
maType = input.string(
     "EMA",
     "MA Type",
     options = ["SMA", "EMA", "WMA", "VWMA", "RMA", "HMA"])

maLength = input.int(20, "MA Length")
src      = input.source(close, "Source")

showMA    = input.bool(true, "Show MA")
showBands = input.bool(true, "Show MA Fill")

//━━━━━━━━━━━━━━━━━━
// ANGLE SETTINGS
//━━━━━━━━━━━━━━━━━━
showAngleLabel = input.bool(true, "Show Angle Label")

idealAngle     = input.float(8.0, "Ideal Angle")
strongAngle    = input.float(15.0, "Strong Angle")
extremeAngle   = input.float(25.0, "Extreme Angle")

angleAtrLen    = input.int(14, "Angle ATR Length")
angleLookback  = input.int(8, "Angle Lookback")

labelXOffset   = input.int(3, "Label X Offset")
labelYOffset   = input.float(0.3, "Label Y Offset ATR")

//━━━━━━━━━━━━━━━━━━
// FILL COLORS
//━━━━━━━━━━━━━━━━━━
bullUpperFill = input.color(
     color.new(color.rgb(0,255,70), 82),
     "Bull Upper Fill")

bullLowerFill = input.color(
     color.new(color.rgb(0,180,50), 82),
     "Bull Lower Fill")

bearUpperFill = input.color(
     color.new(color.rgb(255,45,85), 82),
     "Bear Upper Fill")

bearLowerFill = input.color(
     color.new(color.rgb(180,40,70), 82),
     "Bear Lower Fill")

//━━━━━━━━━━━━━━━━━━
// MA FUNCTION
//━━━━━━━━━━━━━━━━━━
maFunc(_src, _len) =>
    float result = na

    if maType == "SMA"
        result := ta.sma(_src, _len)
    else if maType == "EMA"
        result := ta.ema(_src, _len)
    else if maType == "WMA"
        result := ta.wma(_src, _len)
    else if maType == "VWMA"
        result := ta.vwma(_src, _len)
    else if maType == "RMA"
        result := ta.rma(_src, _len)
    else
        result := ta.hma(_src, _len)

    result

//━━━━━━━━━━━━━━━━━━
// MA
//━━━━━━━━━━━━━━━━━━
ma = maFunc(src, maLength)

//━━━━━━━━━━━━━━━━━━
// TRUE ANGLE
//━━━━━━━━━━━━━━━━━━
atrValue = ta.atr(angleAtrLen)

slope =
     (ma - ma[angleLookback]) /
     atrValue

angle =
     math.atan(slope) *
     180 / math.pi

absAngle = math.abs(angle)

//━━━━━━━━━━━━━━━━━━
// STATES
//━━━━━━━━━━━━━━━━━━
isBull = angle > 0
isBear = angle < 0

weakTrend =
     absAngle < idealAngle

idealTrend =
     absAngle >= idealAngle and
     absAngle < strongAngle

strongTrend =
     absAngle >= strongAngle and
     absAngle < extremeAngle

extremeTrend =
     absAngle >= extremeAngle

//━━━━━━━━━━━━━━━━━━
// EMA COLORS ONLY
//━━━━━━━━━━━━━━━━━━
maColor =
     weakTrend
     ? color.yellow
     : idealTrend and isBull
     ? color.rgb(0,255,70)
     : idealTrend and isBear
     ? color.rgb(255,45,85)
     : strongTrend and isBull
     ? color.rgb(0,255,120)
     : strongTrend and isBear
     ? color.rgb(255,80,120)
     : extremeTrend and isBull
     ? color.rgb(57,255,20)
     : extremeTrend and isBear
     ? color.rgb(255,0,60)
     : color.yellow

//━━━━━━━━━━━━━━━━━━
// VOLATILITY BANDS
//━━━━━━━━━━━━━━━━━━
dev = ta.stdev(src, maLength)

upper1 = ma + dev * 0.5
upper2 = ma + dev

lower1 = ma - dev * 0.5
lower2 = ma - dev

//━━━━━━━━━━━━━━━━━━
// FILL TREND COLORS
//━━━━━━━━━━━━━━━━━━
bull = ma > ma[1]

bandColor1 =
     bull ?
     color.rgb(0,200,50) :
     color.rgb(180,40,70)

bandColor2 =
     bull ?
     color.rgb(0,255,120) :
     color.rgb(255,80,120)

//━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━
plot(
     showMA ? ma : na,
     "Clean MA",
     color = maColor,
     linewidth = 2)

// Unsichtbare Linien für Fill
u1 = plot(
     showBands ? upper1 : na,
     "Upper 1",
     color = color.new(bandColor1, 100),
     linewidth = 1)

u2 = plot(
     showBands ? upper2 : na,
     "Upper 2",
     color = color.new(bandColor2, 100),
     linewidth = 1)

l1 = plot(
     showBands ? lower1 : na,
     "Lower 1",
     color = color.new(bandColor1, 100),
     linewidth = 1)

l2 = plot(
     showBands ? lower2 : na,
     "Lower 2",
     color = color.new(bandColor2, 100),
     linewidth = 1)

//━━━━━━━━━━━━━━━━━━
// FILLS
//━━━━━━━━━━━━━━━━━━
fill(
     u1,
     u2,
     bull ? bullUpperFill : bearUpperFill)

fill(
     l1,
     l2,
     bull ? bullLowerFill : bearLowerFill)

//━━━━━━━━━━━━━━━━━━
// LABEL
//━━━━━━━━━━━━━━━━━━
var label angleLabel = na

if showAngleLabel
    label.delete(angleLabel)

    status =
         weakTrend
         ? "WEAK"
         : idealTrend and isBull
         ? "IDEAL LONG"
         : idealTrend and isBear
         ? "IDEAL SHORT"
         : strongTrend and isBull
         ? "STRONG LONG"
         : strongTrend and isBear
         ? "STRONG SHORT"
         : extremeTrend and isBull
         ? "EXTREME LONG"
         : extremeTrend and isBear
         ? "EXTREME SHORT"
         : "NEUTRAL"

    labelText =
         str.tostring(angle, "#.0") +
         "°  " +
         status

    angleLabel := label.new(
         bar_index + labelXOffset,
         ma + (atrValue * labelYOffset),
         labelText,
         style = label.style_label_left,
         color = maColor,
         textcolor = color.black,
         size = size.small)
````
