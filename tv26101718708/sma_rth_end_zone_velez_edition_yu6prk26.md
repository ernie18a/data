# SMA & RTH End Zone - Velez Edition

- url: https://www.tradingview.com/script/YU6pRk26-SMA-RTH-End-Zone-Velez-Edition/
- type: indicator
- pine_id: PUB;aaf0d4e3814d46c5b2f7f278df07e09b
- version: 1.0

## Description

Fab 4 Zone - 20SMA, 200SMA, prior day closing price, high and low range of last 45 minutes of prior day's session.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("SMA & RTH End Zone - Velez Edition", overlay = true)

// --- Constants ---
var string GP1 = "Moving Averages"
var string GP2 = "Zone Settings"
var string GP3 = "Oliver Velez Concepts"
var color BULL_COLOR = #089981
var color BEAR_COLOR = #f23645
var color NEUTRAL_COLOR = #5b9cf6

// --- Inputs ---
sma20Length  = input.int(20, "SMA 20 (The Mighty 20)", minval = 1, group = GP1)
sma200Length = input.int(200, "SMA 200 (Institutional)", minval = 1, group = GP1)

lookbackMins = input.int(45, "Window Duration (Minutes)", minval = 1, group = GP2)
zoneColor    = input.color(color.new(NEUTRAL_COLOR, 85), "Zone Color", group = GP2)
zoneBorder   = input.color(color.new(NEUTRAL_COLOR, 50), "Zone Border", group = GP2)

// Velez Specific Inputs
showElephant = input.bool(true, "Show Elephant Bars", group = GP3, tooltip = "Large bars that represent institutional igniting or exhausting moves.")
ebMult       = input.float(2.0, "Elephant Bar Multiplier", minval = 1.0, step = 0.1, group = GP3, tooltip = "How many times larger than the average body size a bar must be to be an Elephant.")
showSnapback = input.bool(true, "Highlight Overextension (Snapback)", group = GP3, tooltip = "Highlights when price is 'stretched' too far from the 20 SMA.")

// --- Calculations ---
sma20  = ta.sma(close, sma20Length)
sma200 = ta.sma(close, sma200Length)

// 1. Color-coded 20 SMA (Trend Direction)
sma20Color = ta.change(sma20) > 0 ? BULL_COLOR : BEAR_COLOR

// 2. Elephant Bars (Igniting/Exhausting)
bodySize = math.abs(close - open)
avgBody  = ta.sma(bodySize, 20)
isElephant = bodySize >= avgBody * ebMult
isBullElephant = isElephant and close > open
isBearElephant = isElephant and close < open

// 3. Overextension (Rubber Band Effect)
// Velez often looks for 3-5 bars away from the 20 SMA or a specific distance
distFrom20 = math.abs(close - sma20)
avgDist    = ta.sma(distFrom20, 20)
isOverextended = distFrom20 > avgDist * 2.5

// 4. Session/Zone Logic
sessionCloseTime = time_close("D")
windowStartTime  = sessionCloseTime - (lookbackMins * 60 * 1000)
isInWindow = time >= windowStartTime and time < sessionCloseTime
isNewDay   = ta.change(time("D")) != 0

var float currentMax = na
var float currentMin = na
var float prevDayMax = na
var float prevDayMin = na

if isInWindow
    if not isInWindow[1]
        currentMax := math.max(high, sma20, sma200)
        currentMin := math.min(low, sma20, sma200)
    else
        currentMax := math.max(currentMax, high, sma20, sma200)
        currentMin := math.min(currentMin, low, sma20, sma200)

if isNewDay
    prevDayMax := currentMax
    prevDayMin := currentMin

// --- Visuals ---
// Plot SMAs
plot(sma20, "Mighty 20 SMA", color = sma20Color, linewidth = 3)
plot(sma200, "Institutional 200 SMA", color = BEAR_COLOR, linewidth = 2)

// Elephant Bar Markers
plotshape(showElephant and isBullElephant, "Bull Elephant", shape.triangleup, location.belowbar, BULL_COLOR, size = size.small)
plotshape(showElephant and isBearElephant, "Bear Elephant", shape.triangledown, location.abovebar, BEAR_COLOR, size = size.small)

// Snapback / Overextension Background
bgcolor(showSnapback and isOverextended ? color.new(NEUTRAL_COLOR, 90) : na, title = "Overextension Highlight")

// Draw the Zone
var box zoneBox = na
if isNewDay and not na(prevDayMax) and not na(prevDayMin)
    zoneBox := box.new(bar_index, prevDayMax, bar_index, prevDayMin, bgcolor = zoneColor, border_color = zoneBorder, border_style = line.style_dotted)

if not na(zoneBox)
    box.set_right(zoneBox, bar_index)
````
