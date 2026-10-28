# ORB Strength Box (SYC)

- url: https://www.tradingview.com/script/QVYiXiJe/
- type: indicator
- pine_id: PUB;e39af2b284af4abdac62394c405518cc
- version: 1.0

## Description

Displays the strength of any selected 15-min candle as a percentage (0-100%).

The indicator calculates how strong a candle is based on:
- Body size relative to the full range (big body = strong)
- Relative volume compared to average

Features:
• Clean floating box showing "ORB strength: XX%"
• Fully customizable box position, text color and background
• Customizable candle background highlight (color + transparency)
• Works on any 15-minute chart

Perfect for Opening Range Breakout (ORB) traders who want to quickly see whether the key candle has real power or is weak (many wicks / low volume).

## Source Code

````pine
//@version=5
indicator("ORB Strength Box [8am EST = 14:00 Zürich]", shorttitle="ORB Strength", overlay=true)

// === Settings ===
posInput      = input.string("Top Left", "Box Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
textColor     = input.color(color.white, "Text Color")
showBG        = input.bool(true, "Show Background")
bgColor       = input.color(color.black, "Background Color")
bgTransp      = input.int(80, "Background Transparency", minval=0, maxval=100)

// === Highlight Settings (Candle Background) ===
showHighlight = input.bool(true, "Candle Highlight anzeigen")
highlightColor = input.color(color.blue, "Candle Highlight Farbe")
highlightTransp = input.int(90, "Candle Highlight Transparenz", minval=0, maxval=100)

// === ORB Time (EST) ===
startHour     = input.int(8, "Start Hour EST", minval=0, maxval=23)
startMin      = input.int(0, "Start Minute", minval=0, maxval=59)
duration      = input.int(15, "Duration in minutes", minval=5, maxval=60)

// Target Candle (einfach & stabil für US-Symbole)
isTarget      = (hour == startHour and minute >= startMin and minute < startMin + duration)

// Strength Calculation
bodyPerc      = (high - low) > 0 ? math.abs(close - open) / (high - low) * 100 : 0
rvol          = ta.sma(volume, 20) > 0 ? volume / ta.sma(volume, 20) : 1
strength      = math.round(math.min(100, bodyPerc * 0.65 + math.min(rvol * 18, 35)))

// Position
var string chosenPos = position.top_left
if posInput == "Top Right"
    chosenPos := position.top_right
else if posInput == "Bottom Left"
    chosenPos := position.bottom_left
else if posInput == "Bottom Right"
    chosenPos := position.bottom_right

// Table
var table myTable = table.new(chosenPos, 1, 1, 
     bgcolor = showBG ? color.new(bgColor, bgTransp) : na,
     border_width = showBG ? 1 : 0)

// Update NUR bei der ORB-Candle
if isTarget and barstate.isconfirmed
    table.cell(myTable, 0, 0, 
               "ORB strength: " + str.tostring(strength) + "%", 
               text_color = textColor, 
               text_size = size.normal)

// Candle Highlight (jetzt einstellbar)
highlightFinal = showHighlight ? color.new(highlightColor, highlightTransp) : na
bgcolor(isTarget ? highlightFinal : na)
````
