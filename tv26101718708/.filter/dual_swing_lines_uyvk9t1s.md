# Dual Swing Lines

- url: https://www.tradingview.com/script/UYVk9t1S-Dual-Swing-Lines/
- type: indicator
- pine_id: PUB;daecea1c59144933a295ee28eb3d42e1
- version: 7.0

## Description

Overview
This indicator maps market structure using two layers of swing points: slow swings (major structure) and fast swings (micro structure). It is designed to identify key liquidity levels, track when those levels are taken, and then isolate the first valid reaction after a confirmed break.

The core idea is simple:

Mark important structure (slow swings)
Wait for price to break that structure
Capture only the first meaningful pullback (fast swing) after the break
Ignore all noise afterward

This creates a clean, repeatable framework for structure-based trading.

Core Components

1. Slow Swings (Market Structure)
Slow swings are calculated using pivot logic with a higher strength (slowLen). These represent significant highs and lows in the market.

A slow high forms when price creates a confirmed pivot high.
A slow low forms when price creates a confirmed pivot low.
Each slow level is drawn as a horizontal line that extends forward until price interacts with it.

These levels act as liquidity targets and structure boundaries.

2. First Test Logic (Liquidity Interaction)
Each slow level tracks whether it has been tested.

The first time price touches a slow level, an alert is triggered.
After that first interaction:
The level is considered “used”
The line stops extending
No further alerts are triggered for that level

This ensures you only get clean, first-touch reactions, which are typically the most meaningful.

3. Break Detection (Structure Shift)
A break occurs when price closes beyond a slow level:

Break of slow high → bullish structure shift
Break of slow low → bearish structure shift

Conditions are strict:

Must be a true close beyond the level
Previous candle must be on the opposite side
Only one break cycle can be active at a time

Once a break is confirmed:

The indicator enters a “waiting for fast swing” state
Direction is locked (bullish or bearish)

4. Fast Swings (Post-Break Reaction)
After a break, the indicator looks for exactly one fast swing.

Fast swings use a smaller pivot strength (fastLen)
They represent the first pullback or reaction after the break

Rules:

Only swings that occur after the break candle are valid
Only one fast swing is allowed per break
Once found, the system locks and ignores all future swings until reset

This eliminates over-signaling and keeps focus on the highest-probability setup

5. Fast Line Behavior
When a valid fast swing forms:

A horizontal line is drawn at that level
The line extends for a fixed number of bars (extendBars)
The line stops early if price touches it

This gives you a defined reaction zone with a built-in expiration.

6. Reset Logic (New Structure Forms)
The system resets only when a new slow swing forms.

This means:

A new structural high/low must be created
Only then is the system allowed to detect a new break + fast swing cycle

This prevents repeated signals within the same structure.

7. Alerts

The indicator includes four alert conditions:

Slow High Tested
Triggered on the first touch of a slow high
Slow Low Tested
Triggered on the first touch of a slow low
Fast High Formed
Triggered when the first fast swing high forms after a bearish break
Fast Low Formed
Triggered when the first fast swing low forms after a bullish break

All alerts are single-event, not repetitive.

Key Concepts

Structure First – Only reacts after meaningful levels are broken
First Reaction Only – Ignores all secondary moves
Noise Reduction – Hard locks prevent overtrading signals
Time + Price Validation – Levels expire by touch or time

Inputs

Fast Swing Strength – Sensitivity of micro swings
Slow Swing Strength – Sensitivity of major structure
Fast Line Extend Bars – How long fast levels remain valid
Color Settings – Custom colors for each level type

Use Case

This indicator is best used for:

Identifying break-and-retest setups
Tracking liquidity sweeps and reactions
Structuring trades around first pullbacks after expansion
Eliminating low-quality repeated signals

Summary

This tool enforces a strict market logic:

Identify structure
Wait for a clean break
Capture the first reaction only
Ignore everything else

That constraint is what makes it powerful.

## Source Code

````pine
//@version=5
indicator("Dual Swing Lines (Slow and Fast)", overlay=true)

// === Inputs ===
fastLen     = input.int(3, "Fast Swing Strength", minval=1)
slowLen     = input.int(20, "Slow Swing Strength", minval=1)
extendBars  = input.int(20, "Fast Line Extend Bars", minval=1)

slowHighColor = input.color(color.rgb(255, 255, 255), "Slow High Color")
slowLowColor  = input.color(color.rgb(255, 255, 255), "Slow Low Color")
fastHighColor = input.color(color.orange, "Fast High Color")
fastLowColor  = input.color(color.orange, "Fast Low Color")
signalColor   = input.color(color.new(color.yellow, 70), "Break Highlight")
failColor     = input.color(color.new(#ff5252, 0), "Failed Signal Highlight")

// === FILTER INPUTS ===
volMultiplier = input.float(250.0, "Max Volume % vs Previous Candle", minval=0)
closePctReq   = input.float(70.0, "Min Close % of Candle Range", minval=0, maxval=100)

// === ATR STOP INPUTS ===
atrLen   = input.int(14, "ATR Length", minval=1)
atrMult  = input.float(1.0, "ATR Multiplier", minval=0.1)

// === Volume Filter ===
validVolume = volume <= volume[1] * (volMultiplier / 100)

// === Close % Filter ===
candleRange = high - low
bullClosePct = candleRange > 0 ? ((close - low) / candleRange) * 100 : 0
bearClosePct = candleRange > 0 ? ((high - close) / candleRange) * 100 : 0

validBullClose = bullClosePct >= closePctReq
validBearClose = bearClosePct >= closePctReq

// === ATR ===
atrValue = ta.atr(atrLen)

// === Swings ===
slowHigh = ta.pivothigh(high, slowLen, slowLen)
slowLow  = ta.pivotlow(low,  slowLen, slowLen)

fastHigh = ta.pivothigh(high, fastLen, fastLen)
fastLow  = ta.pivotlow(low,  fastLen, fastLen)

// === Storage ===
var float lastSlowHigh = na
var float lastSlowLow  = na

var line[] slowHighLines   = array.new_line()
var bool[] slowHighActive  = array.new_bool()
var bool[] slowHighTested  = array.new_bool()

var line[] slowLowLines    = array.new_line()
var bool[] slowLowActive   = array.new_bool()
var bool[] slowLowTested   = array.new_bool()

var line[] fastHighLines = array.new_line()
var bool[] fastHighActive = array.new_bool()
var int[]  fastHighEndBar = array.new_int()

var line[] fastLowLines = array.new_line()
var bool[] fastLowActive = array.new_bool()
var int[]  fastLowEndBar = array.new_int()

// === ATR Stop Storage ===
var line[] stopLines = array.new_line()

// === State ===
var bool waitingFast = false
var int  direction   = 0
var int  breakBar    = na
var bool fastTakenForBreak = false

// === Failed Signal Tracking ===
var int lastSignalDir = 0
var int lastSignalBar = na

// === Alerts ===
var bool alertSlowTest   = false
var bool alertFastForm   = false
var bool alertSignalForm = false

alertSlowTest   := false
alertFastForm   := false
alertSignalForm := false

// === Create Slow Levels ===
if not na(slowHigh)
    lastSlowHigh := slowHigh
    l = line.new(bar_index - slowLen, slowHigh, bar_index, slowHigh, extend=extend.right, color=slowHighColor, width=2)
    array.push(slowHighLines, l)
    array.push(slowHighActive, true)
    array.push(slowHighTested, false)

if not na(slowLow)
    lastSlowLow := slowLow
    l = line.new(bar_index - slowLen, slowLow, bar_index, slowLow, extend=extend.right, color=slowLowColor, width=2)
    array.push(slowLowLines, l)
    array.push(slowLowActive, true)
    array.push(slowLowTested, false)

// === First Test Detection ===
if array.size(slowHighLines) > 0
    for i = 0 to array.size(slowHighLines) - 1
        if array.get(slowHighActive, i)
            l = array.get(slowHighLines, i)
            tested = array.get(slowHighTested, i)
            level = line.get_y1(l)

            if not tested and high >= level
                array.set(slowHighTested, i, true)
                alertSlowTest := true

            if high > level
                line.set_x2(l, bar_index)
                line.set_extend(l, extend.none)
                array.set(slowHighActive, i, false)

if array.size(slowLowLines) > 0
    for i = 0 to array.size(slowLowLines) - 1
        if array.get(slowLowActive, i)
            l = array.get(slowLowLines, i)
            tested = array.get(slowLowTested, i)
            level = line.get_y1(l)

            if not tested and low <= level
                array.set(slowLowTested, i, true)
                alertSlowTest := true

            if low < level
                line.set_x2(l, bar_index)
                line.set_extend(l, extend.none)
                array.set(slowLowActive, i, false)

// === Break Detection ===
breakHigh = not waitingFast and not fastTakenForBreak and not na(lastSlowHigh) and close > lastSlowHigh and close[1] <= lastSlowHigh

breakLow = not waitingFast and not fastTakenForBreak and not na(lastSlowLow) and close < lastSlowLow and close[1] >= lastSlowLow

if breakHigh
    direction := 1
    waitingFast := true
    breakBar := bar_index
    fastTakenForBreak := false

if breakLow
    direction := -1
    waitingFast := true
    breakBar := bar_index
    fastTakenForBreak := false

// === Fast Swing AFTER Break ===
if waitingFast and not fastTakenForBreak

    if direction == 1 and not na(fastLow)

        pivotBar = bar_index - fastLen

        if pivotBar > breakBar

            endBar = pivotBar + extendBars

            l = line.new(pivotBar, fastLow, endBar, fastLow, extend=extend.none, color=fastLowColor, width=2)

            array.push(fastLowLines, l)
            array.push(fastLowActive, true)
            array.push(fastLowEndBar, endBar)

            waitingFast := false
            fastTakenForBreak := true
            alertFastForm := true

    if direction == -1 and not na(fastHigh)

        pivotBar = bar_index - fastLen

        if pivotBar > breakBar

            endBar = pivotBar + extendBars

            l = line.new(pivotBar, fastHigh, endBar, fastHigh, extend=extend.none, color=fastHighColor, width=2)

            array.push(fastHighLines, l)
            array.push(fastHighActive, true)
            array.push(fastHighEndBar, endBar)

            waitingFast := false
            fastTakenForBreak := true
            alertFastForm := true

// === Reset ===
if not na(slowHigh) or not na(slowLow)
    fastTakenForBreak := false

// === Signal FORMING ===
if array.size(fastHighLines) > 0
    for i = 0 to array.size(fastHighLines) - 1
        if array.get(fastHighActive, i)
            l = array.get(fastHighLines, i)
            level = line.get_y1(l)

            if high > level
                alertSignalForm := true

if array.size(fastLowLines) > 0
    for i = 0 to array.size(fastLowLines) - 1
        if array.get(fastLowActive, i)
            l = array.get(fastLowLines, i)
            level = line.get_y1(l)

            if low < level
                alertSignalForm := true

// === Confirmed Break Logic ===
bool breakHighSignal = false
bool breakLowSignal  = false

if array.size(fastHighLines) > 0
    for i = 0 to array.size(fastHighLines) - 1

        if array.get(fastHighActive, i)

            l = array.get(fastHighLines, i)
            endBar = array.get(fastHighEndBar, i)
            level = line.get_y1(l)

            if close > level and bar_index <= endBar and validVolume and validBullClose

                breakHighSignal := true

                lastSignalDir := 1
                lastSignalBar := bar_index

                entry = close
                stop = entry - (atrValue * atrMult)

                sl = line.new(bar_index, stop, bar_index + 2, stop, color=color.yellow, width=2)

                array.push(stopLines, sl)

                line.set_x2(l, bar_index)
                array.set(fastHighActive, i, false)

            else if high > level or bar_index >= endBar

                line.set_x2(l, bar_index)
                array.set(fastHighActive, i, false)

if array.size(fastLowLines) > 0
    for i = 0 to array.size(fastLowLines) - 1

        if array.get(fastLowActive, i)

            l = array.get(fastLowLines, i)
            endBar = array.get(fastLowEndBar, i)
            level = line.get_y1(l)

            if close < level and bar_index <= endBar and validVolume and validBearClose

                breakLowSignal := true

                lastSignalDir := -1
                lastSignalBar := bar_index

                entry = close
                stop = entry + (atrValue * atrMult)

                sl = line.new(bar_index, stop, bar_index + 2, stop, color=color.yellow, width=2)

                array.push(stopLines, sl)

                line.set_x2(l, bar_index)
                array.set(fastLowActive, i, false)

            else if low < level or bar_index >= endBar

                line.set_x2(l, bar_index)
                array.set(fastLowActive, i, false)

// === Failed Follow Through Highlight ===
failedBull = lastSignalDir == 1 and bar_index == lastSignalBar + 1 and close < open
failedBear = lastSignalDir == -1 and bar_index == lastSignalBar + 1 and close > open

bgcolor((breakHighSignal or breakLowSignal) ? signalColor : na)
bgcolor((failedBull or failedBear) ? failColor : na)

// === Alerts ===
alertcondition(alertSlowTest, "Slow Swing Tested", "Price tested a slow swing (high or low)")
alertcondition(alertFastForm, "Fast Swing Formed", "A fast swing formed after break")
alertcondition(alertSignalForm, "Signal Forming", "Price moved beyond fast swing (forming signal)")
````
