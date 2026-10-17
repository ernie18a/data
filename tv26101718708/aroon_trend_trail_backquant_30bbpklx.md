# Aroon Trend Trail [BackQuant]

- url: https://www.tradingview.com/script/30BBpKLx-Aroon-Trend-Trail-BackQuant/
- type: indicator
- pine_id: PUB;ec73e5e06ab44b899eebfd00cf3896c5
- version: 1.0

## Description

[b]Aroon Trend Trail [BackQuant][/b]

[b]Overview[/b]
Aroon Trend Trail is a trend overlay that uses the relative recency of recent highs and lows to determine direction, then plots an ATR-based trailing rail whose width changes with the strength of the Aroon bias.

The indicator has two separate parts:

[list]
[*][b]Aroon state:[/b] determines whether the trend is bullish or bearish.
[*][b]Trend rail:[/b] provides a ratcheting lower or upper boundary based on ATR.
[/list]

The rail itself does not determine trend changes. Bullish and bearish flips come from the Aroon bias crossing the selected Bias Threshold.

[b]Aroon Calculation[/b]
The script measures how many bars have passed since the highest high and lowest low inside the selected Aroon Length.

It then calculates:

[list]
[*]Aroon Up = 100 × (Length - Bars Since Highest High) / Length
[*]Aroon Down = 100 × (Length - Bars Since Lowest Low) / Length
[/list]

A recent high produces a high Aroon Up value.

A recent low produces a high Aroon Down value.

Because the script searches the current bar plus the previous Length - 1 bars, the calculated values approach the usual 0–100 Aroon scale but do not reach exactly zero within a complete window.

[b]Aroon Bias[/b]
The two values are combined into:

[list]
[*]Aroon Bias = (Aroon Up - Aroon Down) / 100
[/list]

Positive values mean the recent-high component is stronger.

Negative values mean the recent-low component is stronger.

The absolute value of the bias is used as Aroon Strength:

[list]
[*]Aroon Strength = |Aroon Bias|
[/list]

This measures the separation between Aroon Up and Aroon Down, not trend direction.

[b]Trend State[/b]
The trend state is persistent rather than changing every time the bias crosses zero.

On initialization:

[list]
[*]Bias >= 0 = bullish.
[*]Bias < 0 = bearish.
[/list]

After that, a bullish trend requires:

[list]
[*]Aroon Bias > Bias Threshold
[/list]

and a bearish trend requires:

[list]
[*]Aroon Bias < -Bias Threshold
[/list]

This creates a neutral zone between the two thresholds.

For example, with a Bias Threshold of 0.15:

[list]
[*]Above +0.15 can establish bullish state.
[*]Below -0.15 can establish bearish state.
[*]Between those values, the previous trend state is retained.
[/list]

This reduces repeated trend changes when Aroon Up and Aroon Down are close together.

[b]Bias Threshold[/b]
Lower values make the trend state easier to reverse.

Higher values require a larger difference between Aroon Up and Aroon Down before the opposite trend can be established.

This setting affects only the trend-state logic.

[b]ATR Trend Rail[/b]
Once the trend state is known, the indicator creates an upper and lower raw rail around HL2.

The base width is:

[list]
[*]ATR × Base Width × Width Scale
[/list]

ATR controls the current market-range component.

The Width Scale is determined by Aroon Strength.

[b]Adaptive Rail Width[/b]
The scale is interpolated between the Weak Trend Width and Strong Trend Width:

[list]
[*]Width Scale = Weak Width + (Strong Width - Weak Width) × Aroon Strength
[/list]

With the default settings:

[list]
[*]Weak Aroon separation uses a wider rail.
[*]Strong Aroon separation uses a narrower rail.
[/list]

This happens because the default Strong Trend Width is smaller than the Weak Trend Width.

The inputs are fully configurable, so changing their relationship can change that behaviour.

[b]Raw Rail Levels[/b]
The raw boundaries are:

[list]
[*]Lower Rail = HL2 - Rail Width
[*]Upper Rail = HL2 + Rail Width
[/list]

These raw levels are then converted into one-sided trailing rails.

[b]Ratcheting Behaviour[/b]
During a bullish trend, the Lower Rail becomes active.

It can:

[list]
[*]Move upward.
[*]Remain unchanged.
[/list]

but it does not move downward while the bullish state remains active.

The calculation uses:

[list]
[*]max(Previous Lower Rail, Current Raw Lower Rail)
[/list]

During a bearish trend, the Upper Rail becomes active.

It can:

[list]
[*]Move downward.
[*]Remain unchanged.
[/list]

but it does not move upward while the bearish state remains active.

The calculation uses:

[list]
[*]min(Previous Upper Rail, Current Raw Upper Rail)
[/list]

When the trend flips, the newly active rail is reset to the current raw level.

[b]Important: Rail Crosses Do Not Flip the Trend[/b]
Price crossing the rail does not directly change the bullish or bearish state.

The trend changes only when the Aroon Bias passes the opposite Bias Threshold.

The rail should therefore be interpreted as a trailing visual boundary associated with the current Aroon regime, not as the trigger used to create that regime.

[b]Break Rail On Flips[/b]
When enabled, the plotted rail is hidden on the exact trend-flip bar.

This prevents TradingView from drawing a connecting segment between the old rail on one side of price and the newly reset rail on the other.

This is visual only and does not affect the calculation.

[b]Visual Strength[/b]
The script calculates a separate strength value used for the gradient and glow.

It combines:

[list]
[*]75% Aroon Strength.
[*]25% distance between Close and the active rail, normalized by Rail Width.
[/list]

This Visual Strength does not change:
[list]
[*]Trend direction.
[*]Aroon Bias.
[*]Rail position.
[*]Signals.
[/list]

It only changes the intensity of the visual effects.

[b]Gradient Fill[/b]
The optional gradient fills the space between the active rail and Close using several transparency layers.

Stronger visual conditions make the area closest to the rail more visible.

The gradient is cosmetic and contains no separate signal logic.

[b]Rail Glow[/b]
The optional glow is scaled using ATR and Visual Strength.

Stronger conditions produce a slightly wider and more visible glow around the active rail.

This does not alter the actual rail level.

[b]Trend Candles[/b]
Candles can be coloured according to the stored Aroon trend state:

[list]
[*]Bullish = selected Bullish colour.
[*]Bearish = selected Bearish colour.
[/list]

The colour represents the indicator regime, not the direction of each individual candle.

[b]Data Window[/b]
The indicator exposes:

[list]
[*][b]Aroon Up:[/b] recency score for the highest high.
[*][b]Aroon Down:[/b] recency score for the lowest low.
[*][b]Aroon Bias:[/b] normalized difference between Up and Down.
[*][b]Aroon Strength:[/b] absolute Aroon Bias expressed as a percentage.
[*][b]Active Rail Width:[/b] current ATR- and Aroon-adjusted distance used for the raw rail.
[/list]

[b]Input Guide[/b]
[b]Aroon Length[/b]
Controls the window used to locate the most recent highest high and lowest low.

[b]Bias Threshold[/b]
Controls how much Aroon separation is required before establishing the opposite trend.

[b]ATR Length[/b]
ATR period used to calculate rail width.

[b]Base Width[/b]
Base ATR multiplier applied to the rail.

[b]Strong Trend Width[/b]
Width multiplier used as Aroon Strength approaches its maximum.

[b]Weak Trend Width[/b]
Width multiplier used when Aroon Up and Down are close together.

[b]How to Use It[/b]
The indicator can be used as:

[list]
[*]An Aroon-based bullish/bearish regime filter.
[*]A trailing visual reference during an established trend.
[*]A way to inspect the separation between Aroon Up and Aroon Down alongside an ATR-scaled rail.
[*]A trend-change alert when the Aroon bias clears the opposite threshold.
[/list]

[b]Limitations[/b]
[list]
[*]The indicator is reactive and uses current and historical price data.
[*]Aroon measures the recency of highs and lows; it does not forecast future price direction.
[*]The rail is derived from the current trend state and does not independently confirm or invalidate that state.
[*]Higher Bias Threshold settings create more persistent regimes but can delay reversals.
[*]Lower thresholds can produce more frequent changes in sideways conditions.
[*]ATR and the Width settings materially affect the distance of the rail from price.
[/list]

[b]Alerts[/b]
The script includes:

[list]
[*][b]Aroon Rail Bullish:[/b] trend state changes from bearish to bullish.
[*][b]Aroon Rail Bearish:[/b] trend state changes from bullish to bearish.
[*][b]Aroon Rail Flip:[/b] either transition occurs.
[/list]

[b]Summary[/b]
Aroon Trend Trail uses Aroon Up and Aroon Down to form a normalized directional bias.

A configurable threshold creates persistence around zero, so the existing trend remains active until the Aroon bias becomes strong enough in the opposite direction.

That trend state is then paired with an ATR-based trailing rail. The rail width changes with the absolute Aroon bias, and the active boundary ratchets upward during bullish regimes or downward during bearish regimes.

The result is a simple combination of an Aroon trend state and an adaptive trailing visual reference, with the two parts kept separate: Aroon determines the trend, while the ATR rail follows it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator("Aroon Trend Trail [BackQuant]", shorttitle="Aroon Trail [BackQuant]", overlay=true)

// Constants
const string calc = "Aroon Calculation"
const string rail = "Trend Rail Settings"
const string ui = "Plotting and Coloring"
const color GREEN = #00ff00
const color RED = #ff0000

// Inputs
int aroonLen = input.int(25, "Aroon Length", minval=2, group=calc)
float flipThreshold = input.float(0.15, "Bias Threshold", minval=0.0, maxval=1.0, step=0.01, group=calc, tooltip="Minimum Aroon bias required to establish the opposite trend.")

int atrLen = input.int(14, "ATR Length", minval=1, group=rail, inline="ATR")
float atrFactor = input.float(1.8, "Base Width", minval=0.1, step=0.05, group=rail, inline="ATR")
float strongWidth = input.float(0.65, "Strong Trend Width", minval=0.1, maxval=3.0, step=0.05, group=rail, inline="WIDTH")
float weakWidth = input.float(1.25, "Weak Trend Width", minval=0.1, maxval=3.0, step=0.05, group=rail, inline="WIDTH")
bool breakOnFlip = input.bool(true, "Break Rail On Flips", group=rail)

color longCol = input.color(GREEN, "Bullish", group=ui, inline="COL")
color shortCol = input.color(RED, "Bearish", group=ui, inline="COL")
int lineW = input.int(3, "Line Width", minval=1, maxval=6, group=ui)
bool showFill = input.bool(true, "Gradient Fill", group=ui)
bool showGlow = input.bool(true, "Rail Glow", group=ui)
bool showAroon = input.bool(false, "Show Aroon Values", group=ui)
bool paintCandles = input.bool(true, "Color Candles", group=ui)

// Aroon
int sinceHigh = math.abs(ta.highestbars(high, aroonLen))
int sinceLow = math.abs(ta.lowestbars(low, aroonLen))

float aroonUp = 100.0 * (aroonLen - sinceHigh) / aroonLen
float aroonDown = 100.0 * (aroonLen - sinceLow) / aroonLen

float aroonBias = (aroonUp - aroonDown) / 100.0
float aroonStrength = math.min(math.abs(aroonBias), 1.0)

// Trend State
var int trend = 0

if trend == 0
    trend := aroonBias >= 0.0 ? 1 : -1
else if trend != 1 and aroonBias > flipThreshold
    trend := 1
else if trend != -1 and aroonBias < -flipThreshold
    trend := -1

bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1
bool trendFlip = bullFlip or bearFlip

color trendCol = trend == 1 ? longCol : shortCol

// Adaptive Rail Width
float atr = ta.atr(atrLen)
float widthScale = weakWidth + (strongWidth - weakWidth) * aroonStrength
float railWidth = atr * atrFactor * widthScale

float rawLower = hl2 - railWidth
float rawUpper = hl2 + railWidth

// Ratcheting Rail
var float lowerRail = na
var float upperRail = na

if na(lowerRail)
    lowerRail := rawLower
    upperRail := rawUpper
else
    if trend == 1
        lowerRail := bullFlip ? rawLower : math.max(lowerRail[1], rawLower)
    else
        lowerRail := rawLower

    if trend == -1
        upperRail := bearFlip ? rawUpper : math.min(upperRail[1], rawUpper)
    else
        upperRail := rawUpper

float activeRail = trend == 1 ? lowerRail : upperRail
float plottedRail = breakOnFlip and trendFlip ? na : activeRail

// Visual Strength
float railDistance = math.abs(close - activeRail)
float distanceStrength = railWidth > 0.0 ? math.min(railDistance / railWidth, 1.0) : 0.0
float trendStrength = math.min(aroonStrength * 0.75 + distanceStrength * 0.25, 1.0)

int strengthBoost = int(math.round(trendStrength * 14.0))

// Gradient
bool fillReady = showFill and not na(plottedRail)
bool priceAbove = close >= activeRail

float grad1 = activeRail + (close - activeRail) * 0.15
float grad2 = activeRail + (close - activeRail) * 0.35
float grad3 = activeRail + (close - activeRail) * 0.60
float grad4 = activeRail + (close - activeRail) * 0.82

pRail = plot(plottedRail, "Aroon Trend Rail", trendCol, lineW, plot.style_linebr)
pPrice = plot(fillReady ? close : na, "Price Ref", display=display.none, editable=false)
pGrad1 = plot(fillReady ? grad1 : na, "Gradient Ref 1", display=display.none, editable=false)
pGrad2 = plot(fillReady ? grad2 : na, "Gradient Ref 2", display=display.none, editable=false)
pGrad3 = plot(fillReady ? grad3 : na, "Gradient Ref 3", display=display.none, editable=false)
pGrad4 = plot(fillReady ? grad4 : na, "Gradient Ref 4", display=display.none, editable=false)

fill(pRail, pGrad1, priceAbove ? grad1 : activeRail, priceAbove ? activeRail : grad1, fillReady ? color.new(trendCol, 82) : na, fillReady ? color.new(trendCol, math.max(28, 55 - strengthBoost)) : na, title="Gradient Layer 1")
fill(pGrad1, pGrad2, priceAbove ? grad2 : grad1, priceAbove ? grad1 : grad2, fillReady ? color.new(trendCol, 90) : na, fillReady ? color.new(trendCol, 68) : na, title="Gradient Layer 2")
fill(pGrad2, pGrad3, priceAbove ? grad3 : grad2, priceAbove ? grad2 : grad3, fillReady ? color.new(trendCol, 94) : na, fillReady ? color.new(trendCol, 79) : na, title="Gradient Layer 3")
fill(pGrad3, pGrad4, priceAbove ? grad4 : grad3, priceAbove ? grad3 : grad4, fillReady ? color.new(trendCol, 97) : na, fillReady ? color.new(trendCol, 88) : na, title="Gradient Layer 4")
fill(pGrad4, pPrice, priceAbove ? close : grad4, priceAbove ? grad4 : close, fillReady ? color.new(trendCol, 99) : na, fillReady ? color.new(trendCol, 95) : na, title="Gradient Layer 5")

// Glow
float glow = atr * (0.045 + trendStrength * 0.025)
float outerGlow = glow * 2.3

pGlowOuterLower = plot(showGlow ? activeRail - outerGlow : na, "Outer Glow Lower", display=display.none, editable=false)
pGlowOuterUpper = plot(showGlow ? activeRail + outerGlow : na, "Outer Glow Upper", display=display.none, editable=false)
pGlowLower = plot(showGlow ? activeRail - glow : na, "Glow Lower", display=display.none, editable=false)
pGlowUpper = plot(showGlow ? activeRail + glow : na, "Glow Upper", display=display.none, editable=false)

fill(pGlowOuterLower, pGlowOuterUpper, showGlow ? color.new(trendCol, 95) : na, title="Outer Rail Glow")
fill(pGlowLower, pGlowUpper, showGlow ? color.new(trendCol, math.max(60, 84 - strengthBoost)) : na, title="Inner Rail Glow")

// Candles
plotcandle(open, high, low, close, "Trend Candles", trendCol, trendCol, true, bordercolor=trendCol, display=paintCandles ? display.all : display.none)

// Data Window
plot(aroonUp, "Aroon Up", display=display.data_window)
plot(aroonDown, "Aroon Down", display=display.data_window)
plot(aroonBias, "Aroon Bias", display=display.data_window)
plot(aroonStrength * 100.0, "Aroon Strength", display=display.data_window)
plot(railWidth, "Active Rail Width", display=display.data_window)

plot(showAroon ? aroonUp : na, "Aroon Up Diagnostic", display=display.data_window)
plot(showAroon ? aroonDown : na, "Aroon Down Diagnostic", display=display.data_window)

// Alerts
alertcondition(bullFlip, "Aroon Rail Bullish", "Aroon Trend Rail turned bullish on {{ticker}}")
alertcondition(bearFlip, "Aroon Rail Bearish", "Aroon Trend Rail turned bearish on {{ticker}}")
alertcondition(trendFlip, "Aroon Rail Flip", "Aroon Trend Rail changed direction on {{ticker}}")
````
