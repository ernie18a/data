# FlowScope Journal Capture Overlay

- url: https://www.tradingview.com/script/8SGYnyHo-FlowScope-Journal-Capture-Overlay/
- type: indicator
- pine_id: PUB;a8abb9a7ba3b4c069aa12f26cbd185ce
- version: 1.0

## Description

This indicator is designed to work with FlowScope

It adds a clean journal capture card directly onto your TradingView chart so screenshots are easier to review and import into FlowScope. The overlay displays key trade details such as symbol, timeframe, direction, entry, stop, target, setup, mistake, grade, and planned R.

How to use

1. Add the indicator to your chart.
2. Open the indicator settings.
3. Fill in your trade details:
    Direction
    Entry
    Stop
    Target
    Setup
    Mistake
    Grade
4. Take a screenshot of the chart.
5. Open FlowScope and use Trade Capture to attach the screenshot to your journal entry.
6. Review and save the trade.

Purpose

This tool does not generate signals, provide trade advice, or analyze the market. It simply helps create clean, structured chart screenshots for trade journaling and review.

FlowScope uses these screenshots as evidence so traders can better track setups, mistakes, planned R, and long-term performance patterns.

## Source Code

````pine
//@version=5
indicator("FlowScope Journal Capture Overlay", "FlowScope Capture", overlay=true, max_labels_count=50)
directionInput = input.string("Long", "Direction", options=["Long", "Short"])
setupInput = input.string("Open Range Breakout", "Setup")
mistakeInput = input.string("None / followed plan", "Mistake")
entryInput = input.float(0.0, "Entry", step=0.25)
stopInput = input.float(0.0, "Stop", step=0.25)
targetInput = input.float(0.0, "Target", step=0.25)
gradeInput = input.string("B", "Grade", options=["A+", "A", "B", "C", "Review"])
notesInput = input.string("", "Short Note")
showLevels = input.bool(true, "Show Entry / Stop / Target Lines")
showCard = input.bool(true, "Show FlowScope OCR Card")
risk = math.abs(entryInput - stopInput)
reward = math.abs(targetInput - entryInput)
plannedR = risk > 0 ? reward / risk : na
entryColor = color.rgb(57, 167, 255)
stopColor = color.rgb(255, 79, 95)
targetColor = color.rgb(78, 227, 125)
cardBg = color.rgb(7, 18, 30)
cardText = color.rgb(229, 239, 252)
plot(showLevels and entryInput > 0 ? entryInput : na, "FS ENTRY", entryColor, 2, plot.style_linebr, trackprice=true)
plot(showLevels and stopInput > 0 ? stopInput : na, "FS STOP", stopColor, 2, plot.style_linebr, trackprice=true)
plot(showLevels and targetInput > 0 ? targetInput : na, "FS TARGET", targetColor, 2, plot.style_linebr, trackprice=true)
var table captureTable = table.new(position.top_right, 2, 10, bgcolor=cardBg, frame_color=color.rgb(57, 167, 255), frame_width=1, border_color=color.rgb(34, 55, 78), border_width=1)
formatPrice(value) =>
    value > 0 ? str.tostring(value, format.mintick) : "-"
setRow(row, label, value) =>
    table.cell(captureTable, 0, row, label, text_color=color.rgb(145, 163, 186), text_size=size.small)
    table.cell(captureTable, 1, row, value, text_color=cardText, text_size=size.small)
if barstate.islast and showCard
    table.cell(captureTable, 0, 0, "FLOWSCOPE", text_color=color.rgb(57, 245, 212), text_size=size.normal)
    table.cell(captureTable, 1, 0, "JOURNAL", text_color=color.rgb(57, 245, 212), text_size=size.normal)
    setRow(1, "Symbol", syminfo.ticker)
    setRow(2, "Timeframe", timeframe.period)
    setRow(3, "Direction", directionInput)
    setRow(4, "Entry", formatPrice(entryInput))
    setRow(5, "Stop", formatPrice(stopInput))
    setRow(6, "Target", formatPrice(targetInput))
    setRow(7, "Setup", setupInput)
    setRow(8, "Mistake", mistakeInput)
    rText = na(plannedR) ? "-" : str.tostring(plannedR, "#.##") + "R"
    setRow(9, "Grade / R", gradeInput + " / " + rText)
if barstate.islast and showLevels and entryInput > 0
    label.new(bar_index, entryInput, "ENTRY " + formatPrice(entryInput), style=label.style_label_left, textcolor=color.white, color=entryColor)
if barstate.islast and showLevels and stopInput > 0
    label.new(bar_index, stopInput, "STOP " + formatPrice(stopInput), style=label.style_label_left, textcolor=color.white, color=stopColor)
if barstate.islast and showLevels and targetInput > 0
    label.new(bar_index, targetInput, "TARGET " + formatPrice(targetInput), style=label.style_label_left, textcolor=color.white, color=targetColor)
````
