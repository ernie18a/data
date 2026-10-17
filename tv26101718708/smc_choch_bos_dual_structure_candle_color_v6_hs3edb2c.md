# SMC CHOCH BOS Dual Structure + Candle Color v6

- url: https://www.tradingview.com/script/hS3eDb2C/
- type: indicator
- pine_id: PUB;185390f5b0294dbc84461a233128264a
- version: 1.0

## Description

📊 SMC CHOCH & BOS Dual Structure Indicator — User Guide

This indicator is designed to map market structure using Smart Money Concepts (SMC), combining:

CHOCH (Change of Character)
BOS (Break of Structure)
Swing Structure (macro)
Internal Structure (micro)
Dynamic candle coloring based on structural shifts

It provides a complete framework to understand trend shifts, confirmations, and execution timing.

🧠 CORE CONCEPTS
🔹 CHOCH (Change of Character)

Represents a potential reversal in market direction.

Bullish CHOCH → Market shifts from bearish to bullish
Bearish CHOCH → Market shifts from bullish to bearish

👉 This is the early signal, but not always confirmed.

🔹 BOS (Break of Structure)

Represents trend continuation or confirmation.

Occurs when price breaks previous structure in the direction of the trend
The first BOS after a CHOCH is especially important

👉 This is the confirmation phase.

⚙️ SETTINGS EXPLAINED
🔸 Show Structure
Swing → Displays macro structure (clean, less noise)
Internal → Displays micro structure (faster, more signals)
Both → Combines both for full context

👉 Recommended: Both

🔸 Swing Structure Length

Controls the sensitivity of macro structure.

Higher value → smoother, fewer signals
Lower value → more reactive

👉 Recommended: 8–15

🔸 Internal Structure Length

Controls micro structure detection.

Lower value → faster signals
Higher value → more filtering

👉 Recommended: 2–5

🔸 Confirm Break By Candle Close
ON → Break only confirmed after candle closes (more reliable)
OFF → Break detected instantly (faster, more aggressive)

👉 Recommended: ON

🔸 Candle Color Based On

Defines which structure controls candle coloring:

Swing → slower, trend-based coloring
Internal → faster, execution-based coloring

👉 Recommended:

Swing → for bias
Internal → for entries
🔸 Change Candle Color On

Defines when the trend/color shifts:

CHOCH
Faster reaction
More signals
Higher risk
First BOS After CHOCH
More confirmation
Fewer signals
Higher probability

👉 Recommended: First BOS After CHOCH

🔸 Color Candles
ON → candles follow structural direction
OFF → structure only (lines + labels)
🔸 Colors

Customize:

Swing bullish/bearish
Internal bullish/bearish
Candle colors
🔸 Show BOS/CHOCH Text

Displays text labels directly on structure lines:

No background
Centered on the line
Clean visual style
📈 HOW TO USE (PROFESSIONAL APPROACH)
🔹 1. Define Direction (Swing Structure)
Use Swing CHOCH + BOS to identify overall bias
Only trade in the direction of Swing trend
🔹 2. Execute with Internal Structure
Wait for Internal CHOCH
Then confirm with Internal BOS

👉 This is your entry trigger

🔹 3. Best Setup (High Probability)

✔ Swing trend bullish
✔ Internal CHOCH (pullback ends)
✔ First BOS confirms continuation

👉 That’s your trade

⚠️ COMMON MISTAKES

❌ Trading CHOCH alone
❌ Ignoring higher timeframe structure
❌ Entering after extended moves
❌ Using Internal signals against Swing trend

🔥 SIMPLE RULE SET
CHOCH = potential shift
BOS = confirmation
Swing = direction
Internal = execution
🎯 FINAL THOUGHT

This indicator is not just for signals —
it’s a market structure framework.

If used correctly, it helps you:

Avoid late entries
Trade with structure, not emotion
Align with institutional flow

## Source Code

````pine
//@version=6
indicator("SMC CHOCH BOS Dual Structure + Candle Color v6", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================
// INPUTS
// =====================
showMode = input.string("Both", "Show Structure", options=["Swing", "Internal", "Both"])

swingLen    = input.int(10, "Swing Structure Length", minval=1)
internalLen = input.int(3, "Internal Structure Length", minval=1)

useCloseBreak = input.bool(true, "Confirm Break By Candle Close?")

colorSource = input.string("Internal", "Candle Color Based On", options=["Swing", "Internal"])

triggerMode = input.string("CHOCH", "Change Candle Color On", options=["CHOCH", "First BOS After CHOCH"])

paintCandles = input.bool(true, "Color Candles?")

swingBullColor    = input.color(color.aqua, "Swing Bullish Color")
swingBearColor    = input.color(color.red, "Swing Bearish Color")
internalBullColor = input.color(color.teal, "Internal Bullish Color")
internalBearColor = input.color(color.orange, "Internal Bearish Color")

candleBullColor = input.color(color.lime, "Bullish Candle Color")
candleBearColor = input.color(color.red, "Bearish Candle Color")

showText = input.bool(true, "Show BOS/CHOCH Text")

// =====================
// STRUCTURE FUNCTION
// =====================
f_structure(_len, _bullCol, _bearCol, _show) =>
    ph = ta.pivothigh(high, _len, _len)
    pl = ta.pivotlow(low, _len, _len)

    var float lastHigh = na
    var float lastLow  = na
    var int lastHighBar = na
    var int lastLowBar  = na
    var int trend = 0
    var int colorDir = 0
    var int waitingBos = 0

    bullCHOCH = false
    bearCHOCH = false
    bullBOS = false
    bearBOS = false
    firstBullBOS = false
    firstBearBOS = false

    if not na(ph)
        lastHigh := ph
        lastHighBar := bar_index - _len

    if not na(pl)
        lastLow := pl
        lastLowBar := bar_index - _len

    breakHigh = not na(lastHigh) and (useCloseBreak ? close > lastHigh : high > lastHigh)
    breakLow  = not na(lastLow)  and (useCloseBreak ? close < lastLow  : low < lastLow)

    if breakHigh
        isCHOCH = trend == -1

        if isCHOCH
            bullCHOCH := true
            waitingBos := 1
        else
            bullBOS := true

            if waitingBos == 1
                firstBullBOS := true
                waitingBos := 0

        trend := 1

        if triggerMode == "CHOCH" and bullCHOCH
            colorDir := 1

        if triggerMode == "First BOS After CHOCH" and firstBullBOS
            colorDir := 1

        if _show
            line.new(lastHighBar, lastHigh, bar_index, lastHigh, color=_bullCol, width=isCHOCH ? 2 : 1, style=isCHOCH ? line.style_solid : line.style_dashed)

            if showText
                midBar = math.round((lastHighBar + bar_index) / 2)
                label.new(midBar, lastHigh, isCHOCH ? "CHoCH" : "BOS", style=label.style_none, textcolor=_bullCol, size=size.tiny)

        lastHigh := na

    if breakLow
        isCHOCH = trend == 1

        if isCHOCH
            bearCHOCH := true
            waitingBos := -1
        else
            bearBOS := true

            if waitingBos == -1
                firstBearBOS := true
                waitingBos := 0

        trend := -1

        if triggerMode == "CHOCH" and bearCHOCH
            colorDir := -1

        if triggerMode == "First BOS After CHOCH" and firstBearBOS
            colorDir := -1

        if _show
            line.new(lastLowBar, lastLow, bar_index, lastLow, color=_bearCol, width=isCHOCH ? 2 : 1, style=isCHOCH ? line.style_solid : line.style_dashed)

            if showText
                midBar = math.round((lastLowBar + bar_index) / 2)
                label.new(midBar, lastLow, isCHOCH ? "CHoCH" : "BOS", style=label.style_none, textcolor=_bearCol, size=size.tiny)

        lastLow := na

    [colorDir, bullCHOCH, bearCHOCH, bullBOS, bearBOS, firstBullBOS, firstBearBOS]

// =====================
// EXECUTION
// =====================
showSwing = showMode == "Swing" or showMode == "Both"
showInternal = showMode == "Internal" or showMode == "Both"

[swingDir, swingBullCHOCH, swingBearCHOCH, swingBullBOS, swingBearBOS, swingFirstBullBOS, swingFirstBearBOS] =
     f_structure(swingLen, swingBullColor, swingBearColor, showSwing)

[internalDir, internalBullCHOCH, internalBearCHOCH, internalBullBOS, internalBearBOS, internalFirstBullBOS, internalFirstBearBOS] =
     f_structure(internalLen, internalBullColor, internalBearColor, showInternal)

// =====================
// CANDLE COLORING
// =====================
activeDir = colorSource == "Swing" ? swingDir : internalDir

barcolor(
     paintCandles ?
         activeDir == 1 ? candleBullColor :
         activeDir == -1 ? candleBearColor :
         na
     : na
)

// =====================
// ALERTS
// =====================
alertcondition(swingBullCHOCH, "Swing CHOCH Buy", "Swing CHOCH Buy")
alertcondition(swingBearCHOCH, "Swing CHOCH Sell", "Swing CHOCH Sell")
alertcondition(internalBullCHOCH, "Internal CHOCH Buy", "Internal CHOCH Buy")
alertcondition(internalBearCHOCH, "Internal CHOCH Sell", "Internal CHOCH Sell")
````
