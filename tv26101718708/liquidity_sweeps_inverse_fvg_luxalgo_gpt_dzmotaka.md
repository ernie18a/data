# Liquidity Sweeps & Inverse FVG [LuxAlgo] - GPT

- url: https://www.tradingview.com/script/DZMoTaka/
- type: indicator
- pine_id: PUB;77ad49e206154194b7c6af1257310f08
- version: 1.0

## Description

Inversed fair value gap for patient traders, use that to found where the price could go!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © LuxAlgo (fixed version)

//@version=6
indicator("Liquidity Sweeps & Inverse FVG [LuxAlgo] - GPT", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Constants ---
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645

// --- Inputs ---
sweepGroup = "Liquidity Sweeps"
sweepLen   = input.int(5, "Sweep Pivot Length", minval = 1, group = sweepGroup)
showSweeps = input.bool(true, "Show Liquidity Sweeps", group = sweepGroup)

fvgGroup  = "Inverse FVG"
volFilter = input.float(0.5, "FVG Volatility Threshold", minval = 0, step = 0.1, group = fvgGroup)
atrLen    = input.int(14, "ATR Length", minval = 1, group = fvgGroup)
maxFvgAge = input.int(200, "Max FVG Age (Bars)", minval = 10, group = fvgGroup)
showIfvg  = input.bool(true, "Show Inverse FVGs", group = fvgGroup)

// --- Types ---
type Sweep
    float price
    int barIndex
    bool isHigh

type FVG
    float top
    float bottom
    int startIndex
    bool isBullish
    bool isInverted
    box displayBox

// --- Arrays ---
var Sweep[] pivotHighs = array.new<Sweep>()
var Sweep[] pivotLows  = array.new<Sweep>()
var FVG[] activeFVGs   = array.new<FVG>()

float atr = ta.atr(atrLen)

// --- Pivots ---
ph = ta.pivothigh(sweepLen, sweepLen)
pl = ta.pivotlow(sweepLen, sweepLen)

if not na(ph)
    array.unshift(pivotHighs, Sweep.new(ph, bar_index - sweepLen, true))

if not na(pl)
    array.unshift(pivotLows, Sweep.new(pl, bar_index - sweepLen, false))

// ======================================================
// LIQUIDITY SWEEPS (FIXED LOOPS)
// ======================================================

if showSweeps

    // --- Pivot Highs ---
    int hiIdx = array.size(pivotHighs) - 1
    while hiIdx >= 0
        p = array.get(pivotHighs, hiIdx)

        if high > p.price and close < p.price
            label.new(bar_index, high, "Sweep",
                 color = color.new(BEAR_COLOR, 80),
                 textcolor = BEAR_COLOR,
                 style = label.style_label_down,
                 size = size.tiny)

            line.new(p.barIndex, p.price, bar_index, p.price,
                 color = color.new(BEAR_COLOR, 50),
                 style = line.style_dashed)

            array.remove(pivotHighs, hiIdx)

        else if close > p.price
            array.remove(pivotHighs, hiIdx)

        else if bar_index - p.barIndex > 200
            array.remove(pivotHighs, hiIdx)

        hiIdx -= 1

    // --- Pivot Lows ---
    int loIdx = array.size(pivotLows) - 1
    while loIdx >= 0
        p = array.get(pivotLows, loIdx)

        if low < p.price and close > p.price
            label.new(bar_index, low, "Sweep",
                 color = color.new(BULL_COLOR, 80),
                 textcolor = BULL_COLOR,
                 style = label.style_label_up,
                 size = size.tiny)

            line.new(p.barIndex, p.price, bar_index, p.price,
                 color = color.new(BULL_COLOR, 50),
                 style = line.style_dashed)

            array.remove(pivotLows, loIdx)

        else if close < p.price
            array.remove(pivotLows, loIdx)

        else if bar_index - p.barIndex > 200
            array.remove(pivotLows, loIdx)

        loIdx -= 1

// ======================================================
// FVG DETECTION (SAFE INDEXING)
// ======================================================

bullFvgGap = bar_index >= 2 ? low - high[2] : na
bearFvgGap = bar_index >= 2 ? low[2] - high : na

if not na(bullFvgGap) and bullFvgGap > atr * volFilter
    array.push(activeFVGs, FVG.new(low, high[2], bar_index - 1, true, false, na))

if not na(bearFvgGap) and bearFvgGap > atr * volFilter
    array.push(activeFVGs, FVG.new(low[2], high, bar_index - 1, false, false, na))

// ======================================================
// FVG PROCESSING (FIXED LOOP)
// ======================================================

if showIfvg
    int fvgIdx = array.size(activeFVGs) - 1

    while fvgIdx >= 0
        f = array.get(activeFVGs, fvgIdx)

        if not f.isInverted

            if f.isBullish and close < f.bottom
                f.isInverted := true
                f.displayBox := box.new(f.startIndex, f.top, bar_index, f.bottom,
                     bgcolor = color.new(BEAR_COLOR, 85),
                     border_color = color.new(BEAR_COLOR, 60),
                     text = "IFVG",
                     text_size = size.tiny,
                     text_color = BEAR_COLOR)

            else if not f.isBullish and close > f.top
                f.isInverted := true
                f.displayBox := box.new(f.startIndex, f.top, bar_index, f.bottom,
                     bgcolor = color.new(BULL_COLOR, 85),
                     border_color = color.new(BULL_COLOR, 60),
                     text = "IFVG",
                     text_size = size.tiny,
                     text_color = BULL_COLOR)

        else
            if not na(f.displayBox)
                f.displayBox.set_right(bar_index)

            if (f.isBullish and close > f.top) or (not f.isBullish and close < f.bottom)
                array.remove(activeFVGs, fvgIdx)
                fvgIdx -= 1
                continue

        if bar_index - f.startIndex > maxFvgAge
            array.remove(activeFVGs, fvgIdx)

        fvgIdx -= 1
````
