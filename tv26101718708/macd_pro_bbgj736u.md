# MACD PRO

- url: https://www.tradingview.com/script/bBgj736U-MACD-PRO/
- type: indicator
- pine_id: PUB;2dccc0d6fcd7431cb68e0b38e503581d
- version: 1.0

## Description

Moving Average Convergence Divergence PRO (MACD Pro) — with Crosses & Divergence
A classic MACD indicator enhanced with two practical additions: visual cross markers and automatic divergence detection.
What it shows
The standard MACD setup — fast and slow moving averages of price, their difference plotted as the MACD line, a signal line smoothing of that difference, and a histogram showing the gap between them. Histogram bars use a four-tone color scheme that shows both the side of zero and whether momentum is accelerating or decelerating.
Cross markers
Whenever the MACD line crosses the signal line, a small X is plotted at the bottom of the pane (bullish cross) or the top (bearish cross). Colors are configurable. This makes it easy to spot every cross at a glance without staring at where the two lines meet, which can be hard to read on busy charts or smaller timeframes.
Divergence detection
Optional pivot-based divergence detection between price and the MACD line, with four divergence types you can toggle independently:

Regular bullish — price makes a lower low while MACD makes a higher low (potential reversal up)
Regular bearish — price makes a higher high while MACD makes a lower high (potential reversal down)
Hidden bullish — price makes a higher low while MACD makes a lower low (trend continuation in an uptrend)
Hidden bearish — price makes a lower high while MACD makes a higher high (trend continuation in a downtrend)

When a divergence is confirmed, the indicator draws a line connecting the two MACD pivots and prints a labeled marker. Pivot sensitivity, plus the minimum and maximum bar distance between pivots, are all configurable so you can tune the signal frequency to your timeframe and instrument.
Inputs
Standard MACD parameters (source, fast/slow/signal lengths, EMA or SMA for each), plus separate groups for cross marker visibility and divergence settings.
Alerts
Built-in alert conditions for histogram state changes, MACD/signal crosses in either direction, and each divergence type — eight in total.
Notes
Divergence is inherently lagging by the right-side pivot lookback, since a pivot can only be confirmed once the required number of bars to its right have printed. This is true of all pivot-based divergence indicators and is unavoidable; a signal that appears on the chart will be drawn back at the actual pivot bar but won't be detectable in real time until that confirmation completes. Treat divergence as context, not a trigger.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EDAllan

//@version=6
indicator("MACD PRO", "MACD pro")

// --- Inputs ---
float  sourceInput  = input.source(close, "Source")
int    fastLenInput = input.int(12, "Fast length",   1)
int    slowLenInput = input.int(26, "Slow length",   1)
int    sigLenInput  = input.int(9,  "Signal length", 1)
string oscTypeInput = input.string("EMA", "Oscillator MA type", ["EMA", "SMA"], display = display.none)
string sigTypeInput = input.string("EMA", "Signal MA type",     ["EMA", "SMA"], display = display.none)

// Crossover marker inputs
bool  showCrossesInput = input.bool(true, "Show MACD/Signal crosses", group = "Crosses")
color bullCrossColor   = input.color(color.new(#26a69a, 0), "Bullish cross color", group = "Crosses")
color bearCrossColor   = input.color(color.new(#ff5252, 0), "Bearish cross color", group = "Crosses")

// Divergence inputs
bool showDivInput    = input.bool(false, "Show divergence",         group = "Divergence")
bool showRegBull     = input.bool(true,  "Regular bullish",         group = "Divergence", inline = "reg")
bool showRegBear     = input.bool(true,  "Regular bearish",         group = "Divergence", inline = "reg")
bool showHidBull     = input.bool(false, "Hidden bullish",          group = "Divergence", inline = "hid")
bool showHidBear     = input.bool(false, "Hidden bearish",          group = "Divergence", inline = "hid")
int  pivotLeftInput  = input.int(5,  "Pivot lookback left",      1, group = "Divergence")
int  pivotRightInput = input.int(5,  "Pivot lookback right",     1, group = "Divergence")
int  divRangeMaxInp  = input.int(60, "Max bars between pivots",  5, group = "Divergence")
int  divRangeMinInp  = input.int(5,  "Min bars between pivots",  1, group = "Divergence")

// --- MACD calculation ---
ma(float source, int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)

float maFast = ma(sourceInput, fastLenInput, oscTypeInput)
float maSlow = ma(sourceInput, slowLenInput, oscTypeInput)
float macd   = maFast - maSlow
float signal = ma(macd, sigLenInput, sigTypeInput)
float hist   = macd - signal
color hColor = hist >= 0 ? hist > hist[1] ? #26a69a : #b2dfdb : hist > hist[1] ? #ffcdd2 : #ff5252

hline(0, "Zero", #787b8680)
plot(hist,   "Histogram",   hColor, style = plot.style_columns)
plot(macd,   "MACD")
plot(signal, "Signal line", #ff6d00)

// --- Crossover markers ---
bool bullCross = ta.crossover(macd,  signal)
bool bearCross = ta.crossunder(macd, signal)

plotshape(showCrossesInput and bullCross, "Bullish cross", shape.xcross, location.bottom, bullCrossColor, size = size.tiny)
plotshape(showCrossesInput and bearCross, "Bearish cross", shape.xcross, location.top,    bearCrossColor, size = size.tiny)

// --- Divergence detection ---
float plPrice = ta.pivotlow(macd,  pivotLeftInput, pivotRightInput)
float phPrice = ta.pivothigh(macd, pivotLeftInput, pivotRightInput)
bool  plFound = not na(plPrice)
bool  phFound = not na(phPrice)

var float prevPlMacd  = na
var float prevPlPrice = na
var int   prevPlBar   = na
var float prevPhMacd  = na
var float prevPhPrice = na
var int   prevPhBar   = na

int   curPivotBar   = bar_index - pivotRightInput
float curPivotPrice = sourceInput[pivotRightInput]
float curPivotMacd  = macd[pivotRightInput]

bool bullDiv = false
bool hidBull = false
bool bearDiv = false
bool hidBear = false

if plFound
    if not na(prevPlMacd)
        int gap = curPivotBar - prevPlBar
        if gap >= divRangeMinInp and gap <= divRangeMaxInp
            if showDivInput and showRegBull and curPivotPrice < prevPlPrice and curPivotMacd > prevPlMacd
                bullDiv := true
                line.new(prevPlBar, prevPlMacd, curPivotBar, curPivotMacd, color = color.new(#26a69a, 0), width = 2)
                label.new(curPivotBar, curPivotMacd, "Bull", style = label.style_label_up, color = color.new(#26a69a, 0), textcolor = color.white, size = size.small)
            if showDivInput and showHidBull and curPivotPrice > prevPlPrice and curPivotMacd < prevPlMacd
                hidBull := true
                line.new(prevPlBar, prevPlMacd, curPivotBar, curPivotMacd, color = color.new(#26a69a, 40), width = 2, style = line.style_dashed)
                label.new(curPivotBar, curPivotMacd, "H Bull", style = label.style_label_up, color = color.new(#26a69a, 40), textcolor = color.white, size = size.small)
    prevPlMacd  := curPivotMacd
    prevPlPrice := curPivotPrice
    prevPlBar   := curPivotBar

if phFound
    if not na(prevPhMacd)
        int gap = curPivotBar - prevPhBar
        if gap >= divRangeMinInp and gap <= divRangeMaxInp
            if showDivInput and showRegBear and curPivotPrice > prevPhPrice and curPivotMacd < prevPhMacd
                bearDiv := true
                line.new(prevPhBar, prevPhMacd, curPivotBar, curPivotMacd, color = color.new(#ff5252, 0), width = 2)
                label.new(curPivotBar, curPivotMacd, "Bear", style = label.style_label_down, color = color.new(#ff5252, 0), textcolor = color.white, size = size.small)
            if showDivInput and showHidBear and curPivotPrice < prevPhPrice and curPivotMacd > prevPhMacd
                hidBear := true
                line.new(prevPhBar, prevPhMacd, curPivotBar, curPivotMacd, color = color.new(#ff5252, 40), width = 2, style = line.style_dashed)
                label.new(curPivotBar, curPivotMacd, "H Bear", style = label.style_label_down, color = color.new(#ff5252, 40), textcolor = color.white, size = size.small)
    prevPhMacd  := curPivotMacd
    prevPhPrice := curPivotPrice
    prevPhBar   := curPivotBar

// --- Alerts ---
alertcondition(hist[1] >= 0 and hist < 0, "Rising to falling", "MACD histogram switched from a rising to falling state")
alertcondition(hist[1] <= 0 and hist > 0, "Falling to rising", "MACD histogram switched from a falling to rising state")
alertcondition(bullCross, "MACD bullish cross", "MACD crossed above the signal line")
alertcondition(bearCross, "MACD bearish cross", "MACD crossed below the signal line")
alertcondition(bullDiv,   "Regular bullish divergence", "Regular bullish divergence detected on MACD")
alertcondition(bearDiv,   "Regular bearish divergence", "Regular bearish divergence detected on MACD")
alertcondition(hidBull,   "Hidden bullish divergence",  "Hidden bullish divergence detected on MACD")
alertcondition(hidBear,   "Hidden bearish divergence",  "Hidden bearish divergence detected on MACD")
````
