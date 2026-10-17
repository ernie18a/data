# Pure Price Action Checklist

- url: https://www.tradingview.com/script/262cYFi0-Pure-Price-Action-Checklist/
- type: indicator
- pine_id: PUB;4a60ec5fbcfa443fa9a854728e337518
- version: 1.0

## Description

# Pure Price Action Checklist

The Pure Price Action Checklist is a simple yet powerful on-chart reminder designed to help traders stay disciplined and avoid impulsive decisions.

Instead of generating signals or predicting market direction, this tool acts as a trading companion by displaying a fixed checklist of core price action rules directly on your chart. Before entering any trade, you can quickly verify that your setup meets all predefined conditions.

### Checklist Items

• 1Hr Bias
• Fib Retracement
• Buy/Sell Zones
• Candle Confirmation
• Minimum 1:1 Risk-to-Reward

### Features

✔ Clean top-right checklist panel
✔ Fully customizable colors
✔ Adjustable text and title sizes
✔ Custom motivational quote input
✔ Lightweight and non-intrusive design
✔ Works on any market and timeframe

### Purpose

The goal of this indicator is not to tell you when to trade, but to remind you how to trade. Consistency comes from following a process, and this checklist helps reinforce that process before every execution.

**NO CHECKLIST = NO TRADE**

*"If you can stay calm while everyone else panics, you're already ahead."*

## Source Code

````pine
//@version=6
indicator("Pure Price Action Checklist", overlay=true)

//=========================
// COLORS
//=========================
titleColor     = input.color(color.yellow, "Title Color")
checklistColor = input.color(color.white,  "Checklist Color")
warningColor   = input.color(color.red,    "Warning Color")
quoteColor     = input.color(color.aqua,   "Quote Color")
bgColor        = input.color(color.black,  "Background Color")
borderColor    = input.color(color.yellow, "Border Color")

//=========================
// TEXT SIZE
//=========================
textSizeInput = input.string(
     "Normal",
     "Checklist Text Size",
     options = ["Tiny", "Small", "Normal", "Large"])

textSize = switch textSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    => size.normal

//=========================
// TITLE SIZE
//=========================
titleSizeInput = input.string(
     "Large",
     "Title Size",
     options = ["Small", "Normal", "Large"])

titleSize = switch titleSizeInput
    "Small"  => size.small
    "Normal" => size.normal
    => size.large

//=========================
// CUSTOM QUOTE
//=========================
quote = input.string(
     "IF YOU CAN STAY CALM WHILE EVERYONE ELSE PANICS, YOU'RE ALREADY AHEAD.",
     "Custom Quote")

//=========================
// TABLE
//=========================
var table panel = table.new(
     position.top_right,
     1,
     10,
     bgcolor = bgColor,
     frame_color = borderColor,
     frame_width = 2)

//=========================
// DRAW PANEL
//=========================
if barstate.islast

    table.cell(panel, 0, 0,
         "PURE PRICE ACTION",
         text_color = titleColor,
         text_size = titleSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 1,
         "□ 1Hr Bias",
         text_color = checklistColor,
         text_size = textSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 2,
         "□ Fib Retracement",
         text_color = checklistColor,
         text_size = textSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 3,
         "□ Buy/Sell Zones",
         text_color = checklistColor,
         text_size = textSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 4,
         "□ Candle Confirmation",
         text_color = checklistColor,
         text_size = textSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 5,
         "□ 1:1 RR",
         text_color = checklistColor,
         text_size = textSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 6,
         "",
         bgcolor = bgColor)

    table.cell(panel, 0, 7,
         "NO CHECKLIST = NO TRADE",
         text_color = warningColor,
         text_size = textSize,
         bgcolor = bgColor)

    table.cell(panel, 0, 8,
         "",
         bgcolor = bgColor)

    table.cell(panel, 0, 9,
         quote,
         text_color = quoteColor,
         text_size = textSize,
         bgcolor = bgColor)
````
