# TrendShift

- url: https://www.tradingview.com/script/zIMSRViX-trendshift/
- type: indicator
- pine_id: PUB;dae43176800342939937b80821e7f6f2
- version: 2.0

## Description

TrendShift is a trend-following indicator built around an adaptive average and a dynamic channel.  
Its goal is to help traders visualize when the internal directional state of the market changes from bullish to bearish, or from bearish to bullish.

The script calculates a smoothed trend average, then builds upper and lower channel boundaries around it using ATR-based adaptive width.  
When the internal trend direction flips and the move is confirmed by distance and optional close filters, the indicator prints a Bullish or Bearish label.

This tool is designed to highlight trend state changes in a clean visual way.  
It is not a prediction engine and it does not guarantee future price direction.

How it works

1. Adaptive trend average  
The script maintains a moving internal average that reacts differently depending on market expansion and contraction.  
If price moves far enough away from the previous average, the indicator recalculates faster.  
If price remains closer, the average advances gradually using the previous directional state.

2. Directional state  
The raw trend direction is determined by whether the adaptive average is rising or falling.  
An upward slope produces a bullish raw state.  
A downward slope produces a bearish raw state.

3. Adaptive channel memory  
The script tracks a dynamic holding range derived from ATR and smooths it over time.  
This range is then used to build the upper and lower bands around the average.

4. Flip confirmation  
A trend change label is not printed on every internal shift automatically.  
The script can require:
- a minimum distance between price and the average, measured in ATR
- confirmation that the close is on the correct side of the average

These filters help reduce weak flips and improve chart readability.

Visual structure

- Trend Average: the core directional line
- Upper Band: dynamic upper channel boundary
- Lower Band: dynamic lower channel boundary
- Bullish label: appears below the lower channel area when a bullish trend flip is confirmed
- Bearish label: appears above the upper channel area when a bearish trend flip is confirmed

This label placement is intentional so the chart stays cleaner and the markers interfere less with candles.

Inputs

Multiplicative Factor  
Controls the ATR expansion factor used in the adaptive calculations.

Slope  
Controls how quickly the average and channel memory evolve.

ATR Length  
Defines the ATR lookback period used in volatility calculations.

Width %  
Sets the relative channel width around the average.

Confirm Flip With Close  
If enabled, bullish flips require the close to be above the average, and bearish flips require the close to be below it.

Min Flip Distance (ATR)  
Filters out weak flips by requiring price to be a minimum ATR-based distance away from the average.

Show Bands  
Shows or hides the upper and lower channel boundaries.

Show Fill  
Shows or hides the channel fill.

Show Trend Labels  
Shows or hides Bullish and Bearish flip labels.

How to use it

This indicator can be used as a trend state filter rather than a standalone entry system.

Examples:
- Bullish environment: price structure stabilizes and a confirmed Bullish label appears while the average turns upward
- Bearish environment: price weakens and a confirmed Bearish label appears while the average turns downward

Possible ways to use it:
- as a directional filter alongside market structure or support/resistance analysis
- to avoid trading against the current adaptive trend state
- to monitor transitions from expansion to directional movement

Limitations

Like all trend-following tools, this indicator may react late during sharp reversals and may produce alternating flips in choppy market conditions.  
It should be used together with price action, liquidity levels, structure, or higher timeframe context.

Notes

This script is an indicator, not a strategy.  
It does not provide backtest results, profit projections, or performance guarantees.  [url=https://www.tradingview.com/x/nXouUVjn/]https://www.tradingview.com/x/nXouUVjn/[/url][image]https://www.tradingview.com/x/nXouUVjn/[/image]

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// You may share and adapt this code for non-commercial purposes, with attribution.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// TrendShift — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.
//@version=6
indicator("TrendShift", shorttitle="TrendShift", overlay=true, max_labels_count=200)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
const string calcGroup   = "Calculation"
const string filterGroup = "Signal Filters"
const string visualGroup = "Visuals"

// Core
mult     = input.float(4.0,  "Multiplicative Factor", minval=0.1, step=0.1, group=calcGroup, tooltip="Volatility budget = ATR x this factor. Price must travel more than that distance past the line before the line re-anchors and the direction can turn. Higher = fewer and later state changes, wider channel.")
slope    = input.float(12.0, "Slope",                 minval=1.0, step=0.5, group=calcGroup, tooltip="Divides the ramp step and sets how fast the stored width relaxes toward ATR. Despite the name, higher values give a shallower line and a slower adapting channel. Minimum is 1: below that the step would exceed the budget itself and the line would re-anchor on almost every bar.")
atrLen   = input.int(150,    "ATR Length",            minval=1,              group=calcGroup, tooltip="ATR lookback. The default is long on purpose so the budget reflects the volatility regime rather than the last few bars. Nothing is drawn until this many bars of history have loaded.")
widthPct = input.float(75.0, "Width %",               minval=1, maxval=100,  group=calcGroup, tooltip="Fraction of the stored width used for the bands. At 100 the bands sit at the full stored width, which is also where the re-anchor threshold is. Drawing only, it does not affect the state.") / 100.0

// Filters
confirmFlipWithClose = input.bool(true,  "Confirm Flip With Close", group=filterGroup, tooltip="Require the close to be on the correct side of the line before a pending direction change is published.")
minFlipAtr           = input.float(0.15, "Min Flip Distance (x Factor ATR)", minval=0.0, step=0.05, group=filterGroup, tooltip="Minimum distance between close and line required to publish a state change. The unit is the volatility budget, that is Factor x ATR, not raw ATR. On a re-anchor bar the line lands halfway, so the distance is always above 0.5 there: values below 0.5 filter nothing.")

// Visuals
showBands  = input.bool(true,  "Show Bands",        group=visualGroup, tooltip="Show or hide the upper and lower bands.")
showFill   = input.bool(true,  "Show Fill",         group=visualGroup, tooltip="Show or hide the fill between the line and the bands. Has no effect while Show Bands is off.")
showLabels = input.bool(true,  "Show Trend Labels", group=visualGroup, tooltip="Show or hide the badges printed on the bar where the published state changes. Only the last 200 are kept.")
bullColor  = input.color(color.rgb(0, 184, 148), "Bullish Color", group=visualGroup, tooltip="Color of the line, bands, fill and badge while the published state is up.")
bearColor  = input.color(color.rgb(214, 48, 49), "Bearish Color", group=visualGroup, tooltip="Color of the line, bands, fill and badge while the published state is down.")
bandTransp = input.int(75, "Band Transparency", minval=0, maxval=100, group=visualGroup, tooltip="Transparency of the two band lines, 0 = solid, 100 = invisible.")
fillTransp = input.int(88, "Fill Transparency", minval=0, maxval=100, group=visualGroup, tooltip="Transparency of the fill between the line and the bands, 0 = solid, 100 = invisible.")

//------------------------------------------------------------------------------
// Calculations
//------------------------------------------------------------------------------
atr = ta.atr(atrLen) * mult

// One clamped slope used everywhere. Previously the clamp was applied only to the
// width relaxation while the ramp step divided by the raw input, so a slope below
// 1 produced a step larger than the budget itself.
slopeSafe = math.max(slope, 1.0)

var float avg        = close
var float upper      = na
var float lower      = na
var float hold       = na
var int   rawTrend   = 1
var int   trendState = 1

prevAvg      = nz(avg[1], close)
prevHold     = nz(hold[1], atr)
prevRawTrend = nz(rawTrend[1], 1)
prevTrend    = nz(trendState[1], 1)

// Core logic
avg := math.abs(close - prevAvg) > atr ?
     math.avg(close, prevAvg) :
     prevAvg + prevRawTrend * (prevHold / mult / slopeSafe)

rawTrend := avg > prevAvg ? 1 : avg < prevAvg ? -1 : prevRawTrend

// Adaptive channel memory
hold := rawTrend != prevRawTrend ?
     atr :
     prevHold + (atr - prevHold) / slopeSafe

upper := avg + widthPct * hold
lower := avg - widthPct * hold

//------------------------------------------------------------------------------
// Trend confirmation filters
//------------------------------------------------------------------------------
flipDistanceOk = math.abs(close - avg) >= atr * minFlipAtr

bullFlipRaw = rawTrend == 1 and prevTrend != 1
bearFlipRaw = rawTrend == -1 and prevTrend != -1

bullFlip = bullFlipRaw and flipDistanceOk and (not confirmFlipWithClose or close > avg)
bearFlip = bearFlipRaw and flipDistanceOk and (not confirmFlipWithClose or close < avg)

trendState := bullFlip ? 1 : bearFlip ? -1 : prevTrend

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
trendColor = trendState == 1 ? bullColor : bearColor
upperColor = color.new(trendColor, bandTransp)
lowerColor = color.new(trendColor, bandTransp)
fillColor  = color.new(trendColor, fillTransp)

pUpper = plot(showBands ? upper : na, "Upper Band", color=upperColor, linewidth=1)
pAvg   = plot(avg, "Trend Average", color=trendColor, linewidth=2)
pLower = plot(showBands ? lower : na, "Lower Band", color=lowerColor, linewidth=1)

fill(pUpper, pAvg, color=showFill and showBands ? fillColor : na, title="Upper Fill")
fill(pAvg, pLower, color=showFill and showBands ? fillColor : na, title="Lower Fill")

//------------------------------------------------------------------------------
// Trend Change Labels
//------------------------------------------------------------------------------
labelOffset = hold * 0.20

if showLabels and bullFlip
    label.new(
         bar_index, lower - labelOffset,
         "Bullish",
         style=label.style_label_up,
         textcolor=color.white,
         color=bullColor,
         size=size.small
     )

if showLabels and bearFlip
    label.new(
         bar_index, upper + labelOffset,
         "Bearish",
         style=label.style_label_down,
         textcolor=color.white,
         color=bearColor,
         size=size.small
     )
````
