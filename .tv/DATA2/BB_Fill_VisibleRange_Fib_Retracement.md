<!-- tradingview-pine-id: PUB;7ab6cfe110154db6889aa61fbf6909d6 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# BB Fill + Visible-Range Fib Retracement

Source: https://www.tradingview.com/script/uIJngt4h-BB-Fill-Visible-Range-Fib-Retracement/

## Description

# BB Fill + Visible-Range Fib Retracement

A 2-in-1 Pine Script indicator that bundles a **Bollinger Bands volatility fill** and a **visible-range Fibonacci retracement** into a single script. If your TradingView plan limits the number of indicators you can have on a chart at once, this lets you get both tools for the price of one indicator slot.

## Bollinger Bands (grey fill)

Standard Bollinger Bands math is used under the hood:

- **Basis** = Simple Moving Average (SMA) of the source over the chosen length.
- **Upper band** = Basis + (StdDev of source over the length × multiplier).
- **Lower band** = Basis − (StdDev of source over the length × multiplier).

Unlike a typical BB indicator, the basis, upper, and lower lines are **not drawn**. Only the shaded area between the upper and lower bands is visible, giving a quick, uncluttered read on volatility/price range without adding extra lines to your chart.

**Inputs:**

- **BB Length** (default `20`) — number of bars used for the moving average and standard deviation.
- **BB Source** (default `close`) — price series the calculation is based on.
- **BB StdDev Multiplier** (default `2.0`) — how many standard deviations the bands extend from the basis.
- **BB Fill Color** (default grey) — color of the shaded band.
- **BB Fill Transparency %** (default `85`) — how transparent the shading is (higher = more transparent/subtle).

## Visible-Range Fibonacci Retracement

This tool automatically scans the bars **currently visible on your screen** to find the highest high and the lowest low, then draws the standard Fibonacci retracement levels between them:

`0, 0.236, 0.382, 0.5, 0.618, 0.786, 1`

The retracement direction is auto-detected: if the low occurred before the high in the visible range, it's treated as an uptrend (levels retrace down from the high); otherwise it's treated as a downtrend (levels retrace up from the low). Each level is drawn as a horizontal line spanning the visible range, with an optional price label at the right edge showing the level ratio and its price.

**Inputs:**

- **Show Fib Retracement** — toggles the fib lines on/off.
- **Show Fib Price Labels** — toggles the price labels next to each fib line on/off.

**Important behavior to understand:** the lines update to reflect the highest high/lowest low of whatever range you're viewing when you scroll or zoom the chart, but Pine Script only allows a script to redraw on the arrival of new bar/tick data or when the chart is reloaded — not on every scroll/zoom gesture by itself. In practice this means the levels catch up shortly after you stop interacting with the chart (or on the next price update), rather than tracking your viewport in real time. Because of this, the tool is a **discretionary visual aid** meant for manual chart reading, not a deterministic signal — it should not be used as input to automated strategies or backtests, since its output depends on your current viewport rather than a fixed, reproducible calculation.

## How to use

- Use the grey BB fill as quick visual context for current volatility — a wide band suggests an expansive/volatile market, a narrow band suggests consolidation.
- Use the fib levels as an on-the-fly support/resistance reference for whatever swing high/low is currently in view — zoom or scroll to the price range you care about, let the chart refresh, and read the levels as potential reaction zones.
- Combine both: watch for price reacting near a fib level while inside or near the BB shaded zone for added confluence.

## Settings summary

| Input | Default | Description |
|---|---|---|
| BB Length | 20 | Number of bars for the SMA basis and standard deviation. |
| BB Source | close | Price series used for the Bollinger Bands calculation. |
| BB StdDev Multiplier | 2.0 | Multiplier applied to standard deviation to set band width. |
| BB Fill Color | grey | Color of the shaded area between the bands. |
| BB Fill Transparency (%) | 85 | Transparency of the BB shading. |
| Show Fib Retracement | true | Toggles drawing of the fib retracement lines. |
| Show Fib Price Labels | true | Toggles price labels next to each fib line. |

## Limitations

- The fib retracement only redraws when new bar/tick data arrives or the chart reloads — it does not update live as you scroll or zoom, due to a Pine Script platform limitation.
- Not intended for automated strategy logic or backtesting: the visible-range calculation is viewport-dependent and not deterministic across runs.
- The script keeps an internal history array of bar times/highs/lows that grows as the chart's loaded history grows, which can add a small amount of memory/processing overhead on very long chart histories.

---
Last updated (UTC): 2026-09-13 08:41:01 UTC

---

## Source Code

````pine
//@version=6
// Last updated (UTC): 2026-09-19 06:48:12 UTC
indicator("BB Fill + Visible-Range Fib Retracement", overlay = true, max_lines_count = 20, max_labels_count = 20)

// =========================================================================
// SECTION 1 — Bollinger Bands (fill-only, no basis/upper/lower lines drawn)
// =========================================================================
bbLength      = input.int(20, "BB Length", minval = 1, group = "Bollinger Bands")
bbSource      = input.source(close, "BB Source", group = "Bollinger Bands")
bbMult        = input.float(2.0, "BB StdDev Multiplier", minval = 0.001, step = 0.1, group = "Bollinger Bands")
bbFillColor   = input.color(color.gray, "BB Fill Color", group = "Bollinger Bands")
bbFillTransp  = input.int(85, "BB Fill Transparency (%)", minval = 0, maxval = 100, group = "Bollinger Bands")

bbBasis = ta.sma(bbSource, bbLength)
bbDev   = bbMult * ta.stdev(bbSource, bbLength)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

// plots are fully transparent so only the fill region between them is visible
bbUpperPlot = plot(bbUpper, color = color.new(color.gray, 100), title = "BB Upper (hidden)")
bbLowerPlot = plot(bbLower, color = color.new(color.gray, 100), title = "BB Lower (hidden)")
fill(bbUpperPlot, bbLowerPlot, color = color.new(bbFillColor, bbFillTransp), title = "BB Fill")

// =========================================================================
// SECTION 2 — Fibonacci retracement over the currently visible chart range
// =========================================================================
showFib       = input.bool(true, "Show Fib Retracement", group = "Fibonacci")
showFibLabels = input.bool(true, "Show Fib Price Labels", group = "Fibonacci")

var float[] fibLevels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)

// history buffers used to find the highest high / lowest low inside the visible range
var int[]   histTime = array.new<int>()
var float[] histHigh = array.new<float>()
var float[] histLow  = array.new<float>()

array.push(histTime, time)
array.push(histHigh, high)
array.push(histLow, low)

// reusable drawing objects (created once, then repositioned in place)
var line[]  fibLines  = array.new<line>(7, na)
var label[] fibLabels = array.new<label>(7, na)

updateFib() =>
    leftT  = chart.left_visible_bar_time
    rightT = chart.right_visible_bar_time

    hh = float(na)
    hhTime = int(na)
    ll = float(na)
    llTime = int(na)

    n = array.size(histTime)
    for i = n - 1 to 0
        t = array.get(histTime, i)
        if t < leftT
            break
        if t <= rightT
            h = array.get(histHigh, i)
            l = array.get(histLow, i)
            if na(hh) or h > hh
                hh := h
                hhTime := t
            if na(ll) or l < ll
                ll := l
                llTime := t

    if not na(hh) and not na(ll)
        uptrend = hhTime > llTime // low happened first -> retracing down from the high
        range_  = hh - ll

        for idx = 0 to array.size(fibLevels) - 1
            lvl = array.get(fibLevels, idx)
            price = uptrend ? hh - range_ * lvl : ll + range_ * lvl

            ln = array.get(fibLines, idx)
            if na(ln)
                ln := line.new(leftT, price, rightT, price, xloc = xloc.bar_time, color = color.new(color.orange, 40), width = 1)
                array.set(fibLines, idx, ln)
            else
                line.set_xy1(ln, leftT, price)
                line.set_xy2(ln, rightT, price)
                line.set_color(ln, color.new(color.orange, 40))

            lb = array.get(fibLabels, idx)
            labelText = str.tostring(lvl, "0.000") + " (" + str.tostring(price, format.mintick) + ")"
            if showFibLabels
                if na(lb)
                    lb := label.new(rightT, price, labelText, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.orange, 100), textcolor = color.orange, size = size.small)
                    array.set(fibLabels, idx, lb)
                else
                    label.set_xy(lb, rightT, price)
                    label.set_text(lb, labelText)
            else if not na(lb)
                label.set_text(lb, "")

if showFib and barstate.islast
    updateFib()
````
