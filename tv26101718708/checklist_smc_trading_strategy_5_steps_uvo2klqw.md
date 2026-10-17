# Checklist - SMC Trading Strategy - 5 Steps

- url: https://www.tradingview.com/script/Uvo2KlQw-Checklist-SMC-Trading-Strategy-5-Steps/
- type: indicator
- pine_id: PUB;6bcb7e9c3414401aba2600ade620545b
- version: 1.0

## Description

Just a simple checklist for SMC Strategy to make sure that you stick to your plan!

## Source Code

````pine
//@version=6
indicator("SMC Trading Strategy - 5 Step Checklist", overlay=true)

tablePosition = input.string("Top Right", "Checklist Position", options=[
     "Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"
])

textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"])

headerColour = input.color(color.black, "Header Colour")
completeColour = input.color(color.new(color.green, 20), "Completed Step Colour")
incompleteColour = input.color(color.new(color.red, 40), "Incomplete Step Colour")
readyColour = input.color(color.green, "All Confirmed Colour")
waitColour = input.color(color.orange, "Waiting Colour")
textColour = input.color(color.white, "Text Colour")

step1 = input.bool(false, "Step 1: Directional Bias 4H confirmed")
step2 = input.bool(false, "Step 2: Kill Zone Sweep 15M confirmed")
step3 = input.bool(false, "Step 3: Reversal Confirmation 1M confirmed")
step4 = input.bool(false, "Step 4: Entry on POI 5M confirmed")
step5 = input.bool(false, "Step 5: Risk Management confirmed")

allConfirmed = step1 and step2 and step3 and step4 and step5

pos = switch tablePosition
    "Top Right" => position.top_right
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left" => position.middle_left

txtSize = switch textSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large

var table checklist = table.new(pos, 1, 7, border_width=1)

f_row(_row, _txt, _done) =>
    table.cell(
         checklist,
         0,
         _row,
         (_done ? "✅ " : "☐ ") + _txt,
         text_color=textColour,
         bgcolor=_done ? completeColour : incompleteColour,
         text_size=txtSize
     )

if barstate.islast
    table.clear(checklist, 0, 0)

    table.cell(checklist, 0, 0, "🎯 SMC 5 Step Checklist", text_color=textColour, bgcolor=headerColour, text_size=txtSize)
    f_row(1, "1. Directional Bias 4H", step1)
    f_row(2, "2. Kill Zone Sweep 15M", step2)
    f_row(3, "3. Reversal Confirmation 1M", step3)
    f_row(4, "4. Entry on POI 5M", step4)
    f_row(5, "5. Risk Management", step5)

    table.cell(
         checklist,
         0,
         6,
         allConfirmed ? "✅ ALL CONFIRMED - TRADE ALLOWED" : "WAIT - Checklist incomplete",
         text_color=textColour,
         bgcolor=allConfirmed ? readyColour : waitColour,
         text_size=txtSize
     )
````
