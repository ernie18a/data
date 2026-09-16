<!-- tradingview-pine-id: PUB;bd56302823b447f9866abdd03668dbba -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI with Divergences - Optimized

Source: https://www.tradingview.com/script/hekLAfwK-davidev-RSI-with-Divergences/

## Description

**RSI with Divergences - Optimized**

An enhanced Relative Strength Index (RSI) indicator designed to combine classic momentum analysis, automatic divergence detection, and an EMA-based momentum filter in a single oscillator.

The script automatically detects both **regular** and **hidden RSI divergences** by comparing confirmed RSI pivot highs/lows with the corresponding price structure.

### Features

* Standard configurable **RSI**
* Configurable **EMA of RSI**
* Dynamic EMA coloring based on RSI momentum
* Optional **DMI directional filter** for EMA coloring
* Automatic **Regular Bullish Divergence**
* Automatic **Regular Bearish Divergence**
* Automatic **Hidden Bullish Divergence**
* Automatic **Hidden Bearish Divergence**
* Configurable pivot sensitivity
* Optional divergence labels
* Custom colors and divergence line width
* Strict or inclusive high/low comparisons
* Automatic management of historical divergence drawings
* Built-in TradingView alerts for individual and combined divergence signals

### Divergence Logic

**Regular Bullish Divergence**

* Price forms a **lower low**
* RSI forms a **higher low**

This can indicate weakening bearish momentum and a potential bullish reversal.

**Regular Bearish Divergence**

* Price forms a **higher high**
* RSI forms a **lower high**

This can indicate weakening bullish momentum and a potential bearish reversal.

**Hidden Bullish Divergence**

* Price forms a **higher low**
* RSI forms a **lower low**

Hidden bullish divergences are generally associated with potential **bullish trend continuation**.

**Hidden Bearish Divergence**

* Price forms a **lower high**
* RSI forms a **higher high**

Hidden bearish divergences are generally associated with potential **bearish trend continuation**.

### EMA of RSI Momentum

The indicator also plots an EMA of the RSI to provide a smoother view of momentum.

By default, its color combines:

* The direction of the RSI EMA
* The relationship between **+DI and -DI**

The EMA is considered bullish when it is rising and +DI is greater than or equal to -DI, while bearish momentum is highlighted when the EMA is falling and -DI is greater than +DI.

The DMI filter can be disabled from the settings, in which case EMA coloring is determined exclusively by whether the RSI EMA is rising or falling.

### Pivot Confirmation

Divergences are calculated using confirmed RSI pivots.

The **Pivot Left** and **Pivot Right** settings control how many surrounding bars are required to validate a pivot.

Because a pivot requires future bars for confirmation, a divergence is only confirmed after the number of bars specified by **Pivot Right** has elapsed. The divergence is visually connected to the actual historical pivot points, while alerts trigger on the bar where the divergence becomes confirmed.

This avoids treating an unconfirmed pivot as a completed divergence.

### Strict Comparison

When **Strict HH/LL Comparison** is enabled, equal price or RSI highs/lows are not considered valid higher-high, lower-high, higher-low, or lower-low conditions.

Disabling it allows equal values to satisfy the relevant comparison.

### Alerts

The script includes alert conditions for:

* Regular Bullish RSI Divergence
* Hidden Bullish RSI Divergence
* Regular Bearish RSI Divergence
* Hidden Bearish RSI Divergence
* Any Bullish RSI Divergence
* Any Bearish RSI Divergence
* Any RSI Divergence

Alerts are generated when the corresponding pivot and divergence are **confirmed**, rather than on the historical pivot bar itself.

### Usage

RSI divergences can help identify changes in momentum, possible trend exhaustion, reversals, and continuation setups. They should not be treated as standalone buy or sell signals.

For better results, consider combining them with market structure, support and resistance, trend direction, volume, volatility, or other forms of confirmation.

The indicator is designed to provide a clean visual representation of RSI momentum while keeping divergence detection systematic, configurable, and easy to interpret.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © davidepolano

//@version=6
indicator("RSI with Divergences - Optimized", overlay = false, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
groupRsi = "RSI"
src = input.source(close, "RSI Source", group = groupRsi)
rsiLen = input.int(14, "RSI Length", minval = 1, group = groupRsi)
emaRsiLen = input.int(9, "EMA of RSI Length", minval = 1, group = groupRsi)

groupDiv = "Divergences"
left = input.int(5, "Pivot Left", minval = 1, group = groupDiv)
right = input.int(5, "Pivot Right", minval = 1, group = groupDiv)
showRegular = input.bool(true, "Show Regular Divergences", group = groupDiv)
showHidden = input.bool(true, "Show Hidden Divergences", group = groupDiv)
showLabels = input.bool(true, "Show Labels", group = groupDiv)
strict = input.bool(true, "Strict HH/LL Comparison", tooltip = "When enabled, equal highs/lows are not considered valid divergence conditions.", group = groupDiv)

groupStyle = "Style"
bullColor = input.color(color.lime, "Regular Bullish", group = groupStyle)
bearColor = input.color(color.red, "Regular Bearish", group = groupStyle)
hiddenBullColor = input.color(color.teal, "Hidden Bullish", group = groupStyle)
hiddenBearColor = input.color(color.orange, "Hidden Bearish", group = groupStyle)
emaBullColor = input.color(color.lime, "EMA Bullish Color", group = groupStyle)
emaBearColor = input.color(color.rgb(178, 22, 240), "EMA Bearish Color", group = groupStyle)
lineWidth = input.int(2, "Divergence Line Width", minval = 1, maxval = 5, group = groupStyle)
maxDrawings = input.int(200, "Max Divergence Drawings To Keep", minval = 20, maxval = 500, group = groupStyle)

groupMomentum = "EMA Momentum Coloring"
dmiLen = input.int(14, "DMI Length", minval = 1, group = groupMomentum)
adxSmoothing = input.int(14, "ADX Smoothing", minval = 1, group = groupMomentum)
useDmiFilter = input.bool(true, "Use DMI Filter For EMA Color", group = groupMomentum)

// ─────────────────────────────────────────────────────────────
// RSI
// ─────────────────────────────────────────────────────────────
rsi = ta.rsi(src, rsiLen)
emaRsi = ta.ema(rsi, emaRsiLen)

plot(rsi, "RSI", color = color.new(color.blue, 0), linewidth = 1)
hline(70, "Overbought", color = color.new(color.gray, 60))
hline(50, "Midline", color = color.new(color.gray, 80))
hline(30, "Oversold", color = color.new(color.gray, 60))

// ─────────────────────────────────────────────────────────────
// EMA of RSI coloring
// ─────────────────────────────────────────────────────────────
[diPlus, diMinus, adx] = ta.dmi(dmiLen, adxSmoothing)

emaRising = emaRsi > emaRsi[1]
emaFalling = emaRsi < emaRsi[1]

dmiBullish = diPlus >= diMinus
dmiBearish = diMinus > diPlus

emaBullish = useDmiFilter ? emaRising and dmiBullish : emaRising
emaBearish = useDmiFilter ? emaFalling and dmiBearish : emaFalling

emaColor = emaBullish ? emaBullColor : emaBearColor

plot(emaRsi, "EMA of RSI", color = emaColor, linewidth = 2)

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
isHigher(float curr, float prev) =>
    strict ? curr > prev : curr >= prev

isLower(float curr, float prev) =>
    strict ? curr < prev : curr <= prev

var line[] divLines = array.new_line()
var label[] divLabels = array.new_label()

addLine(int x1, float y1, int x2, float y2, color lineColor) =>
    line newLine = line.new(
         x1 = x1,
         y1 = y1,
         x2 = x2,
         y2 = y2,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = lineColor,
         width = lineWidth
     )

    array.push(divLines, newLine)

    if array.size(divLines) > maxDrawings
        line oldLine = array.shift(divLines)
        line.delete(oldLine)

addLabel(int x, float y, string txt, color labelColor, string labelStyle) =>
    if showLabels
        label newLabel = label.new(
             x = x,
             y = y,
             text = txt,
             xloc = xloc.bar_index,
             style = labelStyle,
             textcolor = color.white,
             color = labelColor,
             size = size.small
         )

        array.push(divLabels, newLabel)

        if array.size(divLabels) > maxDrawings
            label oldLabel = array.shift(divLabels)
            label.delete(oldLabel)

// ─────────────────────────────────────────────────────────────
// RSI pivots
// Pivots are confirmed after `right` bars.
// The actual pivot bar is `bar_index - right`.
// ─────────────────────────────────────────────────────────────
rsiPivotHigh = ta.pivothigh(rsi, left, right)
rsiPivotLow = ta.pivotlow(rsi, left, right)

// Previous pivot highs
var float prevRsiHigh = na
var float prevPriceHigh = na
var int prevHighBar = na

// Previous pivot lows
var float prevRsiLow = na
var float prevPriceLow = na
var int prevLowBar = na

// Alert signals.
// These fire on the confirmation bar, not on the historical pivot bar.
bool regularBullSignal = false
bool hiddenBullSignal = false
bool regularBearSignal = false
bool hiddenBearSignal = false

// ─────────────────────────────────────────────────────────────
// Pivot High Logic
// Regular Bearish:
// Price higher high + RSI lower high.
//
// Hidden Bearish:
// Price lower high + RSI higher high.
// ─────────────────────────────────────────────────────────────
if not na(rsiPivotHigh)
    int currHighBar = bar_index - right
    float currRsiHigh = rsiPivotHigh
    float currPriceHigh = high[right]

    if not na(prevRsiHigh) and not na(prevPriceHigh)
        bool regularBear = isHigher(currPriceHigh, prevPriceHigh) and isLower(currRsiHigh, prevRsiHigh)
        bool hiddenBear = isLower(currPriceHigh, prevPriceHigh) and isHigher(currRsiHigh, prevRsiHigh)

        if showRegular and regularBear
            addLine(prevHighBar, prevRsiHigh, currHighBar, currRsiHigh, bearColor)
            addLabel(currHighBar, currRsiHigh, "Bear Div", bearColor, label.style_label_down)
            regularBearSignal := true

        if showHidden and hiddenBear
            addLine(prevHighBar, prevRsiHigh, currHighBar, currRsiHigh, hiddenBearColor)
            addLabel(currHighBar, currRsiHigh, "Hidden Bear", hiddenBearColor, label.style_label_down)
            hiddenBearSignal := true

    prevRsiHigh := currRsiHigh
    prevPriceHigh := currPriceHigh
    prevHighBar := currHighBar

// ─────────────────────────────────────────────────────────────
// Pivot Low Logic
// Regular Bullish:
// Price lower low + RSI higher low.
//
// Hidden Bullish:
// Price higher low + RSI lower low.
// ─────────────────────────────────────────────────────────────
if not na(rsiPivotLow)
    int currLowBar = bar_index - right
    float currRsiLow = rsiPivotLow
    float currPriceLow = low[right]

    if not na(prevRsiLow) and not na(prevPriceLow)
        bool regularBull = isLower(currPriceLow, prevPriceLow) and isHigher(currRsiLow, prevRsiLow)
        bool hiddenBull = isHigher(currPriceLow, prevPriceLow) and isLower(currRsiLow, prevRsiLow)

        if showRegular and regularBull
            addLine(prevLowBar, prevRsiLow, currLowBar, currRsiLow, bullColor)
            addLabel(currLowBar, currRsiLow, "Bull Div", bullColor, label.style_label_up)
            regularBullSignal := true

        if showHidden and hiddenBull
            addLine(prevLowBar, prevRsiLow, currLowBar, currRsiLow, hiddenBullColor)
            addLabel(currLowBar, currRsiLow, "Hidden Bull", hiddenBullColor, label.style_label_up)
            hiddenBullSignal := true

    prevRsiLow := currRsiLow
    prevPriceLow := currPriceLow
    prevLowBar := currLowBar

// ─────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────
alertcondition(regularBullSignal, title = "Regular Bullish RSI Divergence", message = "Regular bullish RSI divergence confirmed on {{ticker}} ({{interval}}).")
alertcondition(hiddenBullSignal, title = "Hidden Bullish RSI Divergence", message = "Hidden bullish RSI divergence confirmed on {{ticker}} ({{interval}}).")
alertcondition(regularBearSignal, title = "Regular Bearish RSI Divergence", message = "Regular bearish RSI divergence confirmed on {{ticker}} ({{interval}}).")
alertcondition(hiddenBearSignal, title = "Hidden Bearish RSI Divergence", message = "Hidden bearish RSI divergence confirmed on {{ticker}} ({{interval}}).")

alertcondition(regularBullSignal or hiddenBullSignal, title = "Any Bullish RSI Divergence", message = "Bullish RSI divergence confirmed on {{ticker}} ({{interval}}).")
alertcondition(regularBearSignal or hiddenBearSignal, title = "Any Bearish RSI Divergence", message = "Bearish RSI divergence confirmed on {{ticker}} ({{interval}}).")
alertcondition(regularBullSignal or hiddenBullSignal or regularBearSignal or hiddenBearSignal, title = "Any RSI Divergence", message = "RSI divergence confirmed on {{ticker}} ({{interval}}).")
````
