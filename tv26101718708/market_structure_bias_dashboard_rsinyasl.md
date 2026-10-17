# Market Structure Bias Dashboard

- url: https://www.tradingview.com/script/RSiNyASl-Market-Structure-Bias-Dashboard/
- type: indicator
- pine_id: PUB;da855a5af70d4073b6ccc1d17775eb40
- version: 1.0

## Description

this is a mss indicator it tells u market structure bias

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

indicator("Market Structure Bias Dashboard", shorttitle="MS Bias", overlay=true)

// --- Inputs ---
int leftLen = input.int(10, "Pivot Left Length", group="Market Structure", tooltip="Number of bars to the left to confirm a pivot")
int rightLen = input.int(10, "Pivot Right Length", group="Market Structure", tooltip="Number of bars to the right to confirm a pivot")

string posInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Dashboard", tooltip="Position of the dashboard on the chart")

// --- Variables ---
var float lastPh = na
var float lastPl = na
var string bias = "Neutral"

// --- Logic ---
float ph = ta.pivothigh(high, leftLen, rightLen)
float pl = ta.pivotlow(low, leftLen, rightLen)

if not na(ph)
    lastPh := ph
if not na(pl)
    lastPl := pl

// Update bias on close
if not na(lastPh) and close > lastPh
    bias := "Bullish"
else if not na(lastPl) and close < lastPl
    bias := "Bearish"

// --- Visuals ---
// Plotting the last pivot levels for visual reference
plot(lastPh, "Last Pivot High", color=color.new(#f23645, 50), style=plot.style_linebr)
plot(lastPl, "Last Pivot Low", color=color.new(#089981, 50), style=plot.style_linebr)

// --- Dashboard ---
string tablePos = switch posInput
    "Top Right" => position.top_right
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left

var table dash = table.new(tablePos, 1, 2, border_width = 1, border_color = color.new(color.gray, 50))

if barstate.islast
    color biasColor = bias == "Bullish" ? #089981 : bias == "Bearish" ? #f23645 : #5b9cf6
    
    // Header Cell
    table.cell(dash, 0, 0, "MS Bias", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 20), text_size = size.normal)
    // Value Cell
    table.cell(dash, 0, 1, bias, text_color = color.white, bgcolor = biasColor, text_size = size.large)
````
