# Adaptive Trend Structure Engine v2

- url: https://www.tradingview.com/script/KDuja6JS/
- type: indicator
- pine_id: PUB;4fc376936e4447b882addd572e93cca2
- version: 2.0

## Description

Adaptive Market Structure Engine (ATSE) is a technical analysis tool designed to help visualize and interpret evolving market structure in real time. It focuses on detecting shifts in price behavior by constructing a synthetic structure model that reacts dynamically to volatility and directional movement.

Unlike traditional indicators that rely solely on fixed moving averages or standard oscillators, this script builds a behavior-based price structure that adapts to changing market conditions. It does this by generating dynamic upper and lower structure thresholds, which act as reference boundaries for price movement.

📊 How It Works

The core of the indicator is a synthetic price model that simulates structural movement based on a configurable sensitivity parameter. Price action is continuously evaluated against adaptive upper and lower levels, which are recalculated according to selected structure logic (ATR-based, fixed sensitivity, or price fraction methods).

When price breaks beyond these adaptive boundaries, the system interprets this as a potential structural shift in market direction. These shifts are then classified as trend transitions.

🔄 Trend Detection Logic

The indicator tracks directional changes in the synthetic structure and identifies when a transition occurs from upward to downward structure (or vice versa). These transitions are visually marked on the chart to highlight potential changes in market behavior.

To improve readability, only the first bar of each structural shift is marked, reducing noise and repetitive signals.

📐 Fibonacci Structure Visualization

After each confirmed trend shift, the indicator generates a set of Fibonacci-based dynamic zones starting from the current reference price. These levels are not predictive targets but are instead used as visual framework zones, helping to understand possible areas of price interaction during a trend phase.

Each zone is spaced proportionally based on user-defined sensitivity settings, allowing the structure to expand or contract depending on volatility conditions.

📉 Momentum Context (Optional)

The script also includes an internal momentum calculation based on deviation from a dynamic center line. This helps provide additional context to structural movements without acting as a standalone signal generator.

A normalization option is available to smooth momentum behavior across extended trend phases.

⚙️ Customization Options

Users can adjust:

Structure sensitivity (brick size behavior)
Calculation method (ATR / price-based / classic)
Price source model (close-based or OHLC hybrid)
Fibonacci spacing intensity
Momentum normalization and oscillation behavior

This allows the indicator to be adapted across different assets and timeframes.

🎯 Purpose

The main goal of this tool is to:

Visualize market structure transitions
Provide a clearer view of trend shifts
Offer adaptive structural zones for context
Reduce noise from traditional indicator-based signals

It is intended for educational and analytical use to assist in understanding price behavior rather than to generate direct trading signals.

⚠️ Disclaimer

This script does not provide financial advice. All signals and visual elements are based on mathematical transformations of price data and should be used as part of a broader analysis framework.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator(title = 'Adaptive Trend Structure Engine v2', shorttitle = 'ATSE v2', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 500)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
baseTF = input.int(60, 'Base Timeframe Factor')

structureMethod = input.string('Price Fraction', options = ['ATR', 'Classic', 'Price Fraction'], title = 'Structure Calculation Method')

brickInput = input.float(100.0, minval = 0.1, title = 'Structure Sensitivity')

priceMode = input.string('Open / Close', options = ['Close', 'Open / Close', 'High / Low'], title = 'Price Source Mode')

oscMode = input.bool(true, 'Enable Oscillation Mode')
useNormalization = input.bool(false, 'Enable Normalization')
fibSpacing = input.float(3.0, 'Fib Spacing', minval = 0.1, maxval = 5.0, step = 0.1)

//────────────────────────────────────────────
// SAFE LENGTH (FIX)
//────────────────────────────────────────────
lenRaw = timeframe.isintraday and timeframe.multiplier >= 1 ? baseTF / timeframe.multiplier * 7 : timeframe.isintraday and timeframe.multiplier < 60 ? 60 / timeframe.multiplier * 24 * 7 : 7

scaledLen = math.max(5, int(math.round(lenRaw)))

//────────────────────────────────────────────
// PRICE MODE (FIXED)
//────────────────────────────────────────────
useClose = priceMode == 'Close'
useOC = priceMode == 'Open / Close'
useHL = priceMode == 'High / Low'

srcOpen = useClose ? close : open
srcHigh = useClose ? close : useOC ? math.max(open, close) : high
srcLow = useClose ? close : useOC ? math.min(open, close) : low

//────────────────────────────────────────────
// CORE ENGINE
//────────────────────────────────────────────
upperBand(len, mult) =>
    ta.sma(close, len) + mult * ta.stdev(close, len)

volatilityBand(len, mult) =>
    ta.ema(close, len) + mult * ta.ema(ta.tr, len)

centerLine = (ta.highest(high, scaledLen) + ta.lowest(low, scaledLen)) / 2

momentumOsc = ta.linreg(close - centerLine, scaledLen, 0)

//────────────────────────────────────────────
// BRICK SIZE (FIXED)
//────────────────────────────────────────────
brickSize = structureMethod == 'ATR' ? ta.atr(math.max(2, int(brickInput))) : structureMethod == 'Price Fraction' ? close / math.max(1, brickInput) : brickInput

//────────────────────────────────────────────
// SYNTHETIC STRUCTURE
//────────────────────────────────────────────
var float syntheticClose = na
prevSynthetic = nz(syntheticClose[1], close)

upperLevel = prevSynthetic + brickSize
lowerLevel = prevSynthetic - brickSize

syntheticClose := srcHigh > upperLevel ? upperLevel : srcLow < lowerLevel ? lowerLevel : prevSynthetic

//────────────────────────────────────────────
// TREND ENGINE
//────────────────────────────────────────────
var int trendDir = 0

trendDir := syntheticClose > prevSynthetic ? 1 : syntheticClose < prevSynthetic ? -1 : trendDir

trendFlip = trendDir != trendDir[1]
trendUp = trendDir == 1
trendDown = trendDir == -1

//────────────────────────────────────────────
// MOMENTUM
//────────────────────────────────────────────
var float momentumCount = 1.0

momentumCount := useNormalization ? not trendFlip ? nz(momentumCount[1]) + 1 : 1 : 1

rawMomentum = not trendFlip ? nz(momentumOsc[1]) + momentumOsc : momentumOsc

normalizedMomentum = momentumCount > 0 ? rawMomentum / momentumCount : rawMomentum

finalMomentum = oscMode and trendDown ? -normalizedMomentum : normalizedMomentum

//────────────────────────────────────────────
// SIGNALS
//────────────────────────────────────────────
buySignal = trendUp and trendFlip
sellSignal = trendDown and trendFlip

plotshape(buySignal, title = 'Bullish Structure Shift', style = shape.triangleup, location = location.belowbar, color = color.new(color.blue, 0), text = '🔼', size = size.tiny)

plotshape(sellSignal, title = 'Bearish Structure Shift', style = shape.triangledown, location = location.abovebar, color = color.new(color.blue, 0), text = '🔽', size = size.tiny)


//────────────────────────────────────────────
// CLEAN TREND LABEL SYSTEM
//────────────────────────────────────────────
var label trendLabel = na

if trendFlip
    // eski label sil
    if not na(trendLabel)
        label.delete(trendLabel)

    // yeni label text
    txt = trendUp ? 'TREND UP' : 'TREND DOWN'

    trendLabel := label.new(x = bar_index, y = close, text = txt, style = label.style_label_right, color = trendUp ? color.new(color.green, 0) : color.new(color.red, 0), textcolor = color.white, size = size.small)
    trendLabel

//────────────────────────────────────────────
// FIBONACCI MODULE
//────────────────────────────────────────────

// INPUT

// STORAGE
var array<line> fibLines = array.new_line()
var array<label> fibLabels = array.new_label()
var array<box> fibBoxes = array.new_box()

// LEVELS
fibLevels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)

//────────────────────────────────────────────
// CLEANUP FUNCTION
//────────────────────────────────────────────
deleteFibs() =>
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1 by 1
            line.delete(array.get(fibLines, i))
        array.clear(fibLines)

    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1 by 1
            label.delete(array.get(fibLabels, i))
        array.clear(fibLabels)

    if array.size(fibBoxes) > 0
        for i = 0 to array.size(fibBoxes) - 1 by 1
            box.delete(array.get(fibBoxes, i))
        array.clear(fibBoxes)


//────────────────────────────────────────────
// DRAW FUNCTION
//────────────────────────────────────────────
drawFibs(_base, _range, _dir) =>
    adjustedRange = _range * fibSpacing

    // ─────────────────────────────
    // ZONES (BACKGROUND BOXES)
    // ─────────────────────────────
    for i = 0 to array.size(fibLevels) - 2 by 1
        lvl1 = array.get(fibLevels, i)
        lvl2 = array.get(fibLevels, i + 1)

        p1 = _base + _dir * adjustedRange * lvl1
        p2 = _base + _dir * adjustedRange * lvl2

        top = math.max(p1, p2)
        bottom = math.min(p1, p2)

        bx = box.new(left = bar_index, right = bar_index + 1, top = top, bottom = bottom, bgcolor = color.new(color.gray, 95), border_color = color.new(color.gray, 90), extend = extend.right)

        array.push(fibBoxes, bx)


    // ─────────────────────────────
    // LINES + LABELS
    // ─────────────────────────────
    for i = 0 to array.size(fibLevels) - 1 by 1
        lvl = array.get(fibLevels, i)

        priceLevel = _base + _dir * adjustedRange * lvl

        // GRADIENT COLOR
        gradColor = color.from_gradient(lvl, 0, 1, color.new(color.blue, 80), color.new(#fb0606, 0))

        // LINE
        ln = line.new(x1 = bar_index, y1 = priceLevel, x2 = bar_index + 1, y2 = priceLevel, extend = extend.right, color = gradColor, style = line.style_dashed)

        array.push(fibLines, ln)

        // LABEL COLOR
        labelColor = color.from_gradient(lvl, 0, 1, color.new(color.blue, 45), color.new(#f20505, 20))

        txt = str.tostring(lvl * 100, '#.##') + '%  |  ' + str.tostring(priceLevel, format.mintick)

        lb = label.new(x = bar_index, y = priceLevel, text = txt, style = label.style_label_right, textcolor = color.white, color = labelColor, size = size.small)

        array.push(fibLabels, lb)


//────────────────────────────────────────────
// TRIGGERS
//────────────────────────────────────────────

if buySignal
    deleteFibs()
    basePrice = open
    drawFibs(basePrice, brickSize * 5, 1)

if sellSignal
    deleteFibs()
    basePrice = open
    drawFibs(basePrice, brickSize * 5, -1)
````
