# Sweep Retest Reversal

- url: https://www.tradingview.com/script/E3OvVaeg/
- type: indicator
- pine_id: PUB;8bcf38020c9949e688e52ecb1ae9579c
- version: 1.0

## Description

Title: Sweep Retest Reversal

Description:

This indicator detects a two-candle liquidity sweep reversal pattern and tracks the resulting retest level until it is either confirmed with a bounce or invalidated.

BULLISH SETUP:
A bearish candle (body >= X% of its range, configurable) is followed by a bullish candle (same body filter) whose low sweeps below the bearish candle's low, and whose close finishes above the bearish candle's open. When this occurs, a horizontal line is drawn at the swept low. That level remains active and is monitored on every subsequent bar:
- If a future candle's low touches the line and that same candle closes above it, the bounce is confirmed (green "Bounce" label) and the line is removed.
- If a future candle's low touches the line but closes at or below it, the setup is invalidated on that same bar and the line is removed without a label.

BEARISH SETUP (mirror logic):
A bullish candle is followed by a bearish candle whose high sweeps above the bullish candle's high, and whose close finishes below the bullish candle's open. A horizontal line is drawn at the swept high and monitored the same way:
- A future candle's high touching the line with a close below it confirms the bounce (red "Bounce" label).
- A touch with a close at or above the line invalidates the setup silently.

HOW TO INTERPRET IT:
The two-candle sequence represents a liquidity sweep: the first candle establishes a level, and the second candle pierces through it with its wick while closing back on the opposite side of the first candle's open. This signals that stops resting beyond that level were likely triggered and absorbed, leaving the swept point as a level worth watching again. The line marks that exact point. Price is expected to return to it at some later time. What happens on that return matters more than the touch itself: a wick that pokes through but a close that snaps back in the sweep's original direction supports the reversal thesis (confirmed bounce). A close that pushes through and stays there suggests the level failed to hold and the setup should be discarded (invalidation).

HOW TO USE IT:
1. Wait for the pattern to print: an orange triangle (bullish) or purple triangle (bearish) marks the bar where the sweep candle closed.
2. Once a line appears, treat it as an active level to watch — do not act on it yet, since it has not been retested.
3. When price returns to the line, watch how that specific candle closes:
   - Bullish line + candle closes above it -> bounce confirmed, label appears. This is the point of interest for a potential long reaction.
   - Bearish line + candle closes below it -> bounce confirmed, label appears. This is the point of interest for a potential short reaction.
   - Any touch that closes on the wrong side invalidates the line immediately and it disappears with no label — that level is no longer relevant.
4. The indicator only flags the level and its resolution; it does not place entries, stops, or targets. Combine the confirmed bounce with your own entry, stop, and target rules (e.g. your existing Fibonacci stop-liquidity zone and 1:2 management) for actual trade execution.
5. Adjust the Min Body/Range Ratio input to control how strict the "big body" filter is — lower values surface more setups (including weaker ones), higher values restrict it to cleaner, more decisive sweep candles.

INPUTS:
- Min Body/Range Ratio (%): minimum body-to-range percentage required for both candles in the pattern (default 50%).
- Bullish/Bearish Retest Line Color: line color for each setup type.
- Bullish/Bearish Bounce Label Color: label color for each confirmed bounce.
- Show Bullish Pattern / Show Bearish Pattern: toggle each setup independently.

VISUAL MARKERS:
- Orange upward triangle below the bar: bullish pattern detected.
- Purple downward triangle above the bar: bearish pattern detected.
- Green "Bounce" label: confirmed bullish bounce.
- Red "Bounce" label: confirmed bearish bounce.

NOTES:
Each retest line resolves on the first touch - either confirming or invalidating immediately on that bar, never lingering across multiple touches. This keeps the chart clean and ensures every line on the chart represents a level that is still actively awaited.

## Source Code

````pine
//@version=6
indicator("Sweep Retest Reversal", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ----------------- Inputs -----------------
bodyRatioInput   = input.float(50.0, title = "Min Body/Range Ratio (%)", minval = 1, maxval = 100, step = 1)
bullLineColor    = input.color(color.blue, title = "Bullish Retest Line Color")
bearLineColor    = input.color(color.red, title = "Bearish Retest Line Color")
bullBounceColor  = input.color(color.lime, title = "Bullish Bounce Label Color")
bearBounceColor  = input.color(color.red, title = "Bearish Bounce Label Color")
showBullish      = input.bool(true, title = "Show Bullish Pattern")
showBearish      = input.bool(true, title = "Show Bearish Pattern")

// ----------------- Helpers -----------------
candleRange = high - low
bodySize = math.abs(close - open)
bodyRatio = candleRange != 0 ? (bodySize / candleRange) * 100 : 0.0

isBigBody = bodyRatio >= bodyRatioInput
isRed = close < open
isGreen = close > open

// ----------------- Bullish pattern: red (big body) -> green (big body) sweeps red's low, closes above red's open -----------------
prevIsRed_b      = isRed[1]
prevIsBigBody_b  = isBigBody[1]
prevLow_b        = low[1]
prevOpen_b       = open[1]

bullPatternDetected = showBullish and prevIsRed_b and prevIsBigBody_b and isGreen and isBigBody and (low < prevLow_b) and (close > prevOpen_b)

// ----------------- Bearish pattern: green (big body) -> red (big body) sweeps green's high, closes below green's open -----------------
prevIsGreen_s     = isGreen[1]
prevIsBigBody_s   = isBigBody[1]
prevHigh_s        = high[1]
prevOpen_s        = open[1]

bearPatternDetected = showBearish and prevIsGreen_s and prevIsBigBody_s and isRed and isBigBody and (high > prevHigh_s) and (close < prevOpen_s)

// ----------------- State arrays: bullish lines -----------------
var array<line> bullLines   = array.new<line>()
var array<float> bullLevels = array.new<float>()
var array<int> bullBarIdx   = array.new<int>()

// ----------------- State arrays: bearish lines -----------------
var array<line> bearLines   = array.new<line>()
var array<float> bearLevels = array.new<float>()
var array<int> bearBarIdx   = array.new<int>()

// ----------------- Create new bullish line -----------------
if bullPatternDetected
    float lvl = prevLow_b
    line newLine = line.new(bar_index[1], lvl, bar_index + 20, lvl, extend = extend.right, color = bullLineColor, width = 2)
    array.push(bullLines, newLine)
    array.push(bullLevels, lvl)
    array.push(bullBarIdx, bar_index)

// ----------------- Create new bearish line -----------------
if bearPatternDetected
    float lvl = prevHigh_s
    line newLine = line.new(bar_index[1], lvl, bar_index + 20, lvl, extend = extend.right, color = bearLineColor, width = 2)
    array.push(bearLines, newLine)
    array.push(bearLevels, lvl)
    array.push(bearBarIdx, bar_index)

// ----------------- Manage bullish lines: wick touch decides confirm/invalidate on the same bar -----------------
if array.size(bullLines) > 0
    int i = array.size(bullLines) - 1
    while i >= 0
        line ln = array.get(bullLines, i)
        float lvl = array.get(bullLevels, i)
        int originBar = array.get(bullBarIdx, i)

        if bar_index > originBar
            bool wickTouched = low <= lvl

            if wickTouched
                bool confirmed = close > lvl
                if confirmed
                    label.new(bar_index, lvl, text = "Bounce", style = label.style_label_up,
                         color = bullBounceColor, textcolor = color.black, size = size.small, yloc = yloc.belowbar)
                line.delete(ln)
                array.remove(bullLines, i)
                array.remove(bullLevels, i)
                array.remove(bullBarIdx, i)

        i := i - 1

// ----------------- Manage bearish lines: wick touch decides confirm/invalidate on the same bar -----------------
if array.size(bearLines) > 0
    int j = array.size(bearLines) - 1
    while j >= 0
        line ln2 = array.get(bearLines, j)
        float lvl2 = array.get(bearLevels, j)
        int originBar2 = array.get(bearBarIdx, j)

        if bar_index > originBar2
            bool wickTouched2 = high >= lvl2

            if wickTouched2
                bool confirmed2 = close < lvl2
                if confirmed2
                    label.new(bar_index, lvl2, text = "Bounce", style = label.style_label_down,
                         color = bearBounceColor, textcolor = color.black, size = size.small, yloc = yloc.abovebar)
                line.delete(ln2)
                array.remove(bearLines, j)
                array.remove(bearLevels, j)
                array.remove(bearBarIdx, j)

        j := j - 1

// ----------------- Mark detected patterns -----------------
plotshape(bullPatternDetected, title = "Bullish Pattern Detected", style = shape.triangleup, location = location.belowbar,
     color = color.new(color.orange, 0), size = size.tiny)
plotshape(bearPatternDetected, title = "Bearish Pattern Detected", style = shape.triangledown, location = location.abovebar,
     color = color.new(color.purple, 0), size = size.tiny)
````
