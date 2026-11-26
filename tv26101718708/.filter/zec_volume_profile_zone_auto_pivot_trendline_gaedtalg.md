# ZEC Volume Profile Zone & Auto Pivot Trendline

- url: https://www.tradingview.com/script/GaEDTAlg-ZEC-Volume-Profile-Zone-Auto-Pivot-Trendline/
- type: indicator
- pine_id: PUB;15b904be74f04a2bbb865d1c0b9e785e
- version: 1.0

## Description

This is an indicator, not a strategy — it does not include backtested results, so the strategy-publishing rules on commissions, slippage, position sizing and sample size do not apply.
The script combines two original, algorithmically-derived components instead of manually drawn lines:

Volume profile zone. Over a user-set lookback window (default 90 bars), the script divides the traded price range into bins (default 24) and sums the volume that closed within each bin. The bin with the highest cumulative volume is plotted as a shaded zone. This identifies, on a rolling basis, the price area where the most trading activity has occurred — a high-liquidity zone that tends to act as dynamic support when price is above it and resistance when price is below it.
Auto-detected trendline. Using ta.pivotlow() with adjustable left/right bar sensitivity (default 5/5), the script tracks the two most recent confirmed swing lows and connects them with a line, projected forward. This removes the need to manually anchor a trendline to specific dates or prices, so the line updates as new pivots form and stays valid on any symbol or timeframe (the connection is skipped if the two pivots are more than the "max bars between pivots" setting apart, default 150, to avoid joining unrelated swings).

An optional, disabled-by-default pair of inputs lets a trader mark their own support/resistance levels from their own analysis if they want to combine that with the automatic zone and trendline.
Two alert conditions fire when price closes above the top of the auto-detected high-volume zone (potential bullish continuation) or below its bottom (potential bearish continuation).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © paul_endeo

//@version=6
//@version=5
indicator("ZEC Volume", overlay=true, max_bars_back=500)

// ============================================================
// Inputs
// ============================================================
volLookback   = input.int(90, "Volume profile lookback (bars)", minval=20, maxval=500)
volBins       = input.int(24, "Volume profile bins", minval=5, maxval=100)

pivotLeft     = input.int(5, "Pivot left bars", minval=1)
pivotRight    = input.int(5, "Pivot right bars", minval=1)
pivotMaxGap   = input.int(150, "Max bars between pivots used for trendline", minval=20)

showCustom        = input.bool(false, "Show my own support/resistance levels")
customSupport     = input.float(0.0, "Custom support level")
customResistance  = input.float(0.0, "Custom resistance level")

// ============================================================
// Volume profile: buckets volume by price over the lookback window
// and marks the price range with the highest traded volume as a
// high-liquidity zone (acts as dynamic support/resistance).
// ============================================================
var float zoneHigh = na
var float zoneLow  = na
var box   volBox   = na

if barstate.islast
    float hh = ta.highest(high, volLookback)
    float ll = ta.lowest(low, volLookback)
    float binSize = (hh - ll) / volBins
    var float[] binVol = array.new_float(volBins, 0.0)
    array.fill(binVol, 0.0)
    for i = 0 to volLookback - 1
        float c = close[i]
        float v = volume[i]
        float idxF = math.floor((c - ll) / binSize)
        idxF := math.max(0.0, math.min(float(volBins - 1), idxF))
        int bi = int(idxF)
        array.set(binVol, bi, array.get(binVol, bi) + v)
    int maxIdx = array.indexof(binVol, array.max(binVol))
    zoneLow  := ll + maxIdx * binSize
    zoneHigh := ll + (maxIdx + 1) * binSize
    box.delete(volBox)
    volBox := box.new(math.max(0, bar_index - volLookback), zoneHigh, bar_index + 20, zoneLow, border_color=color.new(color.green, 0), bgcolor=color.new(color.green, 85), extend=extend.right)

// ============================================================
// Auto trendline: connects the two most recent confirmed pivot
// lows so the prevailing support line is projected automatically,
// without manual anchor points tied to one chart/asset.
// ============================================================
float pl = ta.pivotlow(pivotLeft, pivotRight)

var int[]   plBars   = array.new_int(0)
var float[] plPrices = array.new_float(0)

if not na(pl)
    array.push(plBars, bar_index - pivotRight)
    array.push(plPrices, pl)
    if array.size(plBars) > 2
        array.shift(plBars)
        array.shift(plPrices)

var line trendLine = na

if barstate.islast and array.size(plBars) == 2
    int   b1 = array.get(plBars, 0)
    float p1 = array.get(plPrices, 0)
    int   b2 = array.get(plBars, 1)
    float p2 = array.get(plPrices, 1)
    if b2 - b1 <= pivotMaxGap
        line.delete(trendLine)
        trendLine := line.new(b1, p1, b2, p2, extend=extend.right, color=color.new(color.blue, 0), width=2)

// ============================================================
// Optional manual levels (off by default) for traders who want to
// mark their own support/resistance analysis on the chart.
// ============================================================
plot(showCustom and customSupport != 0.0 ? customSupport : na, "Custom support", color=color.new(color.orange, 0), style=plot.style_linebr, linewidth=1)
plot(showCustom and customResistance != 0.0 ? customResistance : na, "Custom resistance", color=color.new(color.red, 0), style=plot.style_linebr, linewidth=1)

// ============================================================
// Signals: price closing outside the auto-detected high-volume zone
// ============================================================
breakUp   = ta.crossover(close, zoneHigh)
breakDown = ta.crossunder(close, zoneLow)

plotshape(breakUp,   title="Zone breakout up",    location=location.belowbar, style=shape.triangleup,   color=color.green, size=size.small)
plotshape(breakDown, title="Zone breakdown down", location=location.abovebar, style=shape.triangledown, color=color.red,   size=size.small)

alertcondition(breakUp,   title="Breakout above high-volume zone",  message="Price closed above the high-volume zone high.")
alertcondition(breakDown, title="Breakdown below high-volume zone", message="Price closed below the high-volume zone low.")
````
