# HOD/LOD - Market Structure Reversal

- url: https://www.tradingview.com/script/iJH2ou59-HOD-LOD-Market-Structure-Reversal/
- type: indicator
- pine_id: PUB;3799af08c68c4436bcea5d8f57a185fd
- version: 9.0

## Description

Overview
This indicator is built around one of the simplest but most effective intraday concepts: expansion from the High of Day (HOD) or Low of Day (LOD), followed by the first pullback.

It tracks daily highs and lows in real time and reacts only when price creates a new extreme. From that moment, it waits for a single, clean counter-move (fast swing), giving you a focused view of the first opportunity after expansion.

No clutter. No repeated signals. Just one reaction per move.

Core Components

1. High of Day (HOD) / Low of Day (LOD)
The indicator continuously tracks the current session’s high and low.

HOD (High of Day): The highest price reached during the session
LOD (Low of Day): The lowest price reached during the session

At the start of each new trading day:

HOD resets to the current high
LOD resets to the current low

As price evolves:

HOD updates when a higher high is made
LOD updates when a lower low is made

Both are plotted as continuous lines on the chart.

2. New Extremes (Trigger Events)
A trigger occurs when price sets a new daily extreme:

New HOD: Current high exceeds the previous HOD
New LOD: Current low drops below the previous LOD

These events represent expansion — price pushing into new territory.

Once a trigger happens:

The system locks direction
Begins waiting for a fast swing
Fires a one-time alert for the event

3. Directional Logic

New HOD → Market expanding upward → Look for a fast low (pullback)
New LOD → Market expanding downward → Look for a fast high (bounce)

This creates a clean cause-and-effect sequence:
Expansion → First Reaction

4. Fast Swings (First Pullback Only)
Fast swings are detected using pivot logic with a smaller sensitivity (fastLen).

Rules:

Must form after the trigger bar
Must be a valid pivot (confirmed structure)
Only the first qualifying fast swing is used

Once found:

A horizontal line is drawn at that level
The system immediately stops looking for additional swings

This ensures you only see the initial reaction, which is typically the most actionable.

5. Fast Line Behavior (Timed + Price-Based Stop)

Each fast swing level has a controlled lifespan:

The line extends forward for a fixed number of bars (stopBars)
The line will stop early if price touches it

This gives you:

A clearly defined reaction zone
A built-in expiration to prevent outdated levels

6. State Control (One Cycle at a Time)

The indicator enforces a strict flow:

Wait for new HOD or LOD
Lock direction
Capture one fast swing
Stop

No additional swings are allowed until a new HOD or LOD forms.

This prevents signal stacking and keeps the chart clean and intentional.

7. Alerts

Four alert conditions are included:

New HOD
Triggered when price creates a new High of Day
New LOD
Triggered when price creates a new Low of Day
Fast High Formed
Triggered after a new LOD when the first fast swing high appears
Fast Low Formed
Triggered after a new HOD when the first fast swing low appears

All alerts are single-event and tied to confirmed structure.

Inputs

Fast Swing Strength
Controls how sensitive the pullback detection is
Stop Fast Line After X Bars
Defines how long fast levels remain valid
Color Settings
Customize HOD, LOD, and fast swing lines

Key Concepts

Expansion-Based Trading – Only reacts when price makes new extremes
First Pullback Focus – Captures the highest-probability reaction
Strict Filtering – One signal per expansion move
Time + Interaction Expiry – Prevents stale levels

Use Case

This indicator is ideal for:

Trading breakout continuation with pullback entries
Identifying intraday exhaustion points
Structuring trades around new highs/lows and first reactions
Eliminating noise from repeated swing signals

Summary

This tool enforces a disciplined process:

Wait for a new High or Low of Day
Let price expand
Capture the first pullback only
Ignore everything else

That constraint is what keeps it sharp, consistent, and tradable.

## Source Code

````pine
//@version=5
indicator("HOD/LOD → Structure Break", overlay=true)

// === Inputs ===
fastLen        = input.int(3, "Fast Swing Strength", minval=1)
stopBars       = input.int(20, "Stop Fast Line After X Bars", minval=1)
atrLen         = input.int(2, "ATR Length", minval=1)

fastHighColor  = input.color(#eb52ff, "Fast High Color")
fastLowColor   = input.color(#eb52ff, "Fast Low Color")
slowHODColor   = input.color(color.rgb(255, 3, 3), "HOD Color")
slowLODColor   = input.color(color.rgb(5, 161, 0), "LOD Color")
signalColor    = input.color(color.new(#ff00ea, 70), "Break Highlight")
failColor      = input.color(color.new(#ff5252, 0), "Failed Follow Through Highlight")
stopLineColor  = input.color(color.yellow, "Stop Line Color")

// === FILTER INPUTS ===
closePerc      = input.float(70.0, "Close % Toward Extreme", minval=0, maxval=100)

// === Volume Filter ===
validVolume = volume > volume[1]

// === ATR ===
atr = ta.atr(atrLen)

// === Tick Requirement ===
tickSize = syminfo.mintick
tickRequirement = tickSize * 2

// === Candle Close Position ===
candleRange = high - low
closePos = candleRange > 0 ? (close - low) / candleRange : 0.5

bullCloseValid = closePos >= (closePerc / 100)
bearCloseValid = closePos <= (1 - closePerc / 100)

// === Session High/Low ===
isNewSession = ta.change(time("D"))

var float hod = na
var float lod = na

if isNewSession
    hod := high
    lod := low
else
    hod := math.max(nz(hod, high), high)
    lod := math.min(nz(lod, low), low)

// === Plot HOD / LOD ===
plot(hod, "HOD", color=slowHODColor, linewidth=2)
plot(lod, "LOD", color=slowLODColor, linewidth=2)

// === Detect NEW HOD / LOD ===
newHOD = not isNewSession and high > hod[1]
newLOD = not isNewSession and low < lod[1]

// === Fast Swings ===
fastHigh = ta.pivothigh(high, fastLen, fastLen)
fastLow  = ta.pivotlow(low, fastLen, fastLen)

// === Storage ===
var line fastHighLine = na
var bool fastHighActive = false
var int fastHighEndBar = na

var line fastLowLine = na
var bool fastLowActive = false
var int fastLowEndBar = na

var line[] stopLines = array.new_line()

// === State ===
var bool waitingBullSwing = false
var bool waitingBearSwing = false

var int bullTriggerBar = na
var int bearTriggerBar = na

// === Failed Follow Through Tracking ===
var int lastSignalDir = 0
var int lastSignalBar = na

// === Alerts ===
var bool alertSlowTest = false
var bool alertFastForm = false
var bool alertSignal = false

alertSlowTest := false
alertFastForm := false
alertSignal := false

// === NEW SESSION RESET ===
if isNewSession
    waitingBullSwing := false
    waitingBearSwing := false

// === NEW LOW OF SESSION ===
if newLOD

    waitingBullSwing := true
    bullTriggerBar := bar_index

    if fastHighActive
        line.set_x2(fastHighLine, bar_index)

    fastHighActive := false

    alertSlowTest := true

// === NEW HIGH OF SESSION ===
if newHOD

    waitingBearSwing := true
    bearTriggerBar := bar_index

    if fastLowActive
        line.set_x2(fastLowLine, bar_index)

    fastLowActive := false

    alertSlowTest := true

// === FIRST FAST SWING HIGH AFTER NEW LOD ===
if waitingBullSwing and not na(fastHigh)

    pivotBar = bar_index - fastLen

    if pivotBar > bullTriggerBar

        endBar = pivotBar + stopBars

        fastHighLine := line.new(
             pivotBar,
             fastHigh,
             endBar,
             fastHigh,
             extend=extend.none,
             color=fastHighColor,
             width=2
         )

        fastHighActive := true
        fastHighEndBar := endBar

        waitingBullSwing := false

        alertFastForm := true

// === FIRST FAST SWING LOW AFTER NEW HOD ===
if waitingBearSwing and not na(fastLow)

    pivotBar = bar_index - fastLen

    if pivotBar > bearTriggerBar

        endBar = pivotBar + stopBars

        fastLowLine := line.new(
             pivotBar,
             fastLow,
             endBar,
             fastLow,
             extend=extend.none,
             color=fastLowColor,
             width=2
         )

        fastLowActive := true
        fastLowEndBar := endBar

        waitingBearSwing := false

        alertFastForm := true

// === Break Detection ===
bool breakHighSignal = false
bool breakLowSignal = false

if fastHighActive

    level = line.get_y1(fastHighLine)

    if close > level + tickRequirement and bar_index <= fastHighEndBar and validVolume and bullCloseValid

        breakHighSignal := true
        alertSignal := true

        lastSignalDir := 1
        lastSignalBar := bar_index

        stopPrice = close - atr

        sl = line.new(
             bar_index,
             stopPrice,
             bar_index + 2,
             stopPrice,
             extend=extend.none,
             color=stopLineColor,
             width=2
         )

        array.push(stopLines, sl)

    if high > level or bar_index >= fastHighEndBar
        line.set_x2(fastHighLine, bar_index)
        fastHighActive := false

if fastLowActive

    level = line.get_y1(fastLowLine)

    if close < level - tickRequirement and bar_index <= fastLowEndBar and validVolume and bearCloseValid

        breakLowSignal := true
        alertSignal := true

        lastSignalDir := -1
        lastSignalBar := bar_index

        stopPrice = close + atr

        sl = line.new(
             bar_index,
             stopPrice,
             bar_index + 2,
             stopPrice,
             extend=extend.none,
             color=stopLineColor,
             width=2
         )

        array.push(stopLines, sl)

    if low < level or bar_index >= fastLowEndBar
        line.set_x2(fastLowLine, bar_index)
        fastLowActive := false

// === FAILED FOLLOW THROUGH ===
failedBull = lastSignalDir == 1 and bar_index == lastSignalBar + 1 and close < open
failedBear = lastSignalDir == -1 and bar_index == lastSignalBar + 1 and close > open

// === Highlight ===
bgcolor((breakHighSignal or breakLowSignal) ? signalColor : na)
bgcolor((failedBull or failedBear) ? failColor : na)

// === Alerts ===
alertcondition(alertSlowTest, "Slow Swing Tested", "HOD or LOD taken")
alertcondition(alertFastForm, "Fast Swing Formed", "First fast swing formed after slow sweep")
alertcondition(alertSignal, "Signal Forming", "Valid signal candle beyond fast swing")
````
