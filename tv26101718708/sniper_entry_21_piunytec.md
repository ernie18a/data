# Sniper Entry 2.1

- url: https://www.tradingview.com/script/piuNyteC-Sniper-Entry-2-1/
- type: indicator
- pine_id: PUB;42c3c71442a441a5847ce0ae21756f93
- version: 1.0

## Description

📌 Overview
This script is designed to calculate precise entry levels for long and short trades based on a combination of percentage offsets from the open price and ATR-based volatility filters. It dynamically adjusts stop-loss width and snaps levels to logical increments, then plots them on the chart with labels and dotted lines.

⚙️ Key Components
Inputs

Offset % from Open: Defines how far above/below the open price to set levels.
Label Offset: Controls how many bars forward labels/lines are drawn.
ATR Multiplier & ATR Length: Used to calculate volatility-adjusted stop-loss width.

Base Calculations

Computes upper and lower bounds around the open price using both percentage offset and ATR.
Chooses the larger of the two (percent vs ATR) to ensure realistic stop-loss sizing.
Builds symmetric levels around the open.

Dynamic Step Size

Adjusts snapping increments based on the raw stop-loss width.
Example: Small ranges snap to 0.01 or 0.05, larger ranges snap to 1, 5, 10, etc.
This prevents clutter and ensures levels align with meaningful price ticks.

Snapped Levels

longEntry: Rounded up to the nearest step above the open.
shortEntry: Rounded down to the nearest step below the open.
finalSL: The effective stop-loss width between these two levels.

Chart Drawing

Deletes old labels/lines to keep the chart clean.
Plots dotted horizontal lines for long and short entries.
Labels them with price values (green for long, red for short).

🎯 Purpose
This script helps traders quickly identify balanced entry levels that adapt to volatility. By combining percentage offsets with ATR, it avoids overly tight or unrealistic stops. The snapping logic ensures levels are practical for execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © TheDefensiveTrader

//@version=6
indicator("Sniper Entry 2.1", overlay = true, max_labels_count = 2, max_lines_count = 2)

// =========================
// INPUTS
// =========================
offsetPercentage = input.float(0.03, "Offset % from Open", step = 0.001)
labelOffset      = input.int(2, "Label Offset (Bars)", minval = 1, maxval = 20)
atrMultplier = input.float(0.8, "ATR Multplier", step = 0.001)
atrLength        = input.int(14, "ATR Length", minval = 1)

// =========================
// BASE VALUES
// =========================
openPrice = open

percentUpper = openPrice * (1 + offsetPercentage / 100)
percentLower = openPrice * (1 - offsetPercentage / 100)

percentSL = percentUpper - percentLower

atrValue = ta.atr(atrLength)
atrHalf = atrValue * atrMultplier

// Effective SL width
rawSL = math.max(percentSL, atrHalf)

// Rebuild symmetric levels around open
rawUpper = openPrice + (rawSL / 2)
rawLower = openPrice - (rawSL / 2)

// =========================
// DYNAMIC MEMORY-FRIENDLY STEP
// =========================
step =
     rawSL < 0.1    ? 0.01 :
     rawSL < 0.5    ? 0.05 :
     rawSL < 2      ? 0.1 :
     rawSL < 10     ? 0.5 :
     rawSL < 50     ? 1 :
     rawSL < 200    ? 5 :
     rawSL < 1000   ? 10 :
     rawSL < 5000   ? 50 : 100

// =========================
// SNAPPED LEVELS
// =========================
longEntry  = math.ceil(rawUpper / step) * step
shortEntry = math.floor(rawLower / step) * step

finalSL = longEntry - shortEntry

log.info("Open: {0}", openPrice)
log.info("Percent SL: {0}", percentSL)
log.info("ATR: {0}", atrValue)
log.info("ATR Half: {0}", atrHalf)
log.info("Effective Raw SL: {0}", rawSL)
log.info("Raw Upper: {0}", rawUpper)
log.info("Raw Lower: {0}", rawLower)
log.info("Step: {0}", step)
log.info("Final Upper: {0}", longEntry)
log.info("Final Lower: {0}", shortEntry)
log.info("Final SL: {0}", finalSL)

// =========================
// DRAW ONLY LAST BAR
// =========================
if barstate.islast
    allLabels = label.all
    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))

    allLines = line.all
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))

    line.new(
         bar_index + 1,
         longEntry,
         bar_index + labelOffset,
         longEntry,
         color = color.white,
         style = line.style_dotted,
         width = 1
     )

    line.new(
         bar_index + 1,
         shortEntry,
         bar_index + labelOffset,
         shortEntry,
         color = color.white,
         style = line.style_dotted,
         width = 1
     )

    label.new(
         bar_index + labelOffset,
         longEntry,
         str.tostring(longEntry, format.mintick),
         style = label.style_label_lower_left,
         color = color.green,
         textcolor = color.white,
         size = size.normal
     )

    label.new(
         bar_index + labelOffset,
         shortEntry,
         str.tostring(shortEntry, format.mintick),
         style = label.style_label_upper_left,
         color = color.red,
         textcolor = color.white,
         size = size.normal
     )
````
