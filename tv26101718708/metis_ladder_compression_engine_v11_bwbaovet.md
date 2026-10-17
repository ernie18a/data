# Metis Ladder Compression Engine v1.1

- url: https://www.tradingview.com/script/BWBAoVET-Metis-Ladder-Compression-Engine-v1-1/
- type: indicator
- pine_id: PUB;fb65b2b08190422a98217cdff769ab8a
- version: 2.0

## Description

Metis Ladder Compression Engine v1.1 is a structured capital deployment framework designed to systematically build positions during price compression phases using a predefined, rules-based allocation model.

The engine automatically identifies four staged accumulation zones based on percentage drawdowns from the 52-week high (or allows manual override), enabling disciplined, emotion-free capital deployment across declining price environments.

Key features include:
	•	Dynamic or manual ladder zone calculation (Zone 1–Zone 4)
	•	Visual price mapping of structured entry levels
	•	First-touch zone entry signals to prevent overtrading
	•	Configurable capital allocation guidance per zone
	•	Optional zone shading for intuitive market context

This tool is not intended to predict bottoms or generate short-term signals. Instead, it provides a systematic framework for scaling into positions during periods of valuation compression, aligning with long-term accumulation strategies.

The Ladder Compression Engine is designed to work in conjunction with complementary systems (such as pullback or trend-based add-on models), forming a complete capital deployment architecture across both drawdown and recovery phases.

## Source Code

````pine
//@version=6
indicator("Métis Ladder Compression Engine v1.2 Clean", overlay=true, max_labels_count=50)

// =========================
// Mode Selection
// =========================
zoneMode = input.string("Auto", "Zone Mode", options=["Auto", "Manual"])
tickerLabel = syminfo.ticker

// =========================
// Auto Mode Inputs
// =========================
lookbackHigh = input.int(252, "52-Week High Lookback", minval=50)

z1Pct = input.float(20.0, "Zone 1 % Below 52W High", minval=0.0, step=1.0)
z2Pct = input.float(30.0, "Zone 2 % Below 52W High", minval=0.0, step=1.0)
z3Pct = input.float(40.0, "Zone 3 % Below 52W High", minval=0.0, step=1.0)
z4Pct = input.float(50.0, "Zone 4 % Below 52W High", minval=0.0, step=1.0)

// =========================
// Manual Mode Inputs
// =========================
manualZone1 = input.float(450.0, "Manual Zone 1 Price")
manualZone2 = input.float(420.0, "Manual Zone 2 Price")
manualZone3 = input.float(390.0, "Manual Zone 3 Price")
manualZone4 = input.float(360.0, "Manual Zone 4 Price")

// =========================
// Display Controls
// =========================
showAllocations = input.bool(true, "Show Allocation Labels")
z1Alloc = input.string("15%", "Zone 1 Allocation")
z2Alloc = input.string("35%", "Zone 2 Allocation")
z3Alloc = input.string("35%", "Zone 3 Allocation")
z4Alloc = input.string("15%", "Zone 4 Allocation")

showActiveZoneShade = input.bool(true, "Shade Active Zone Only")
showDashboard = input.bool(true, "Show Compact Dashboard")
showSignalLabels = input.bool(true, "Show Signal Labels")
keepHistoricalLabels = input.bool(false, "Keep Historical Labels")
showStatusLinePrices = input.bool(true, "Show Zone Prices in Status Line")

// =========================
// Core Calculations
// =========================
highest52 = ta.highest(high, lookbackHigh)

autoZone1 = highest52 * (1 - z1Pct / 100.0)
autoZone2 = highest52 * (1 - z2Pct / 100.0)
autoZone3 = highest52 * (1 - z3Pct / 100.0)
autoZone4 = highest52 * (1 - z4Pct / 100.0)

zone1 = zoneMode == "Auto" ? autoZone1 : manualZone1
zone2 = zoneMode == "Auto" ? autoZone2 : manualZone2
zone3 = zoneMode == "Auto" ? autoZone3 : manualZone3
zone4 = zoneMode == "Auto" ? autoZone4 : manualZone4

// =========================
// Zone State Logic
// =========================
aboveZ1 = close > zone1
inZ1 = close <= zone1 and close > zone2
inZ2 = close <= zone2 and close > zone3
inZ3 = close <= zone3 and close > zone4
inZ4 = close <= zone4

newZ1 = inZ1 and not inZ1[1]
newZ2 = inZ2 and not inZ2[1]
newZ3 = inZ3 and not inZ3[1]
newZ4 = inZ4 and not inZ4[1]

currentZone =
     aboveZ1 ? "ABOVE Z1" :
     inZ1 ? "IN Z1" :
     inZ2 ? "IN Z2" :
     inZ3 ? "IN Z3" :
     "IN Z4"

nextAction =
     inZ1 ? (showAllocations ? "Buy " + z1Alloc : "Zone 1") :
     inZ2 ? (showAllocations ? "Buy " + z2Alloc : "Zone 2") :
     inZ3 ? (showAllocations ? "Buy " + z3Alloc : "Zone 3") :
     inZ4 ? (showAllocations ? "Buy " + z4Alloc : "Zone 4") :
     "Wait"

// =========================
// Plot Zone Lines
// =========================
zoneDisplay = showStatusLinePrices ? (display.all - display.price_scale) : (display.all - display.price_scale - display.status_line)

plot(zone1, "Z1", color=color.yellow, linewidth=2, display=zoneDisplay)
plot(zone2, "Z2", color=color.orange, linewidth=2, display=zoneDisplay)
plot(zone3, "Z3", color=color.red, linewidth=2, display=zoneDisplay)
plot(zone4, "Z4", color=color.fuchsia, linewidth=2, display=zoneDisplay)

// =========================
// Shade Active Zone Only
// =========================
bgcolor(showActiveZoneShade and inZ1 ? color.new(color.yellow, 90) : na)
bgcolor(showActiveZoneShade and inZ2 ? color.new(color.orange, 90) : na)
bgcolor(showActiveZoneShade and inZ3 ? color.new(color.red, 90) : na)
bgcolor(showActiveZoneShade and inZ4 ? color.new(color.fuchsia, 90) : na)

// =========================
// Hidden Signal Markers
// =========================
plotshape(newZ1, title="Entered Zone 1", style=shape.triangleup, location=location.belowbar, color=color.yellow, size=size.tiny, text="Z1", display=display.none)
plotshape(newZ2, title="Entered Zone 2", style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.tiny, text="Z2", display=display.none)
plotshape(newZ3, title="Entered Zone 3", style=shape.triangleup, location=location.belowbar, color=color.red, size=size.tiny, text="Z3", display=display.none)
plotshape(newZ4, title="Entered Zone 4", style=shape.triangleup, location=location.belowbar, color=color.fuchsia, size=size.tiny, text="Z4", display=display.none)

// =========================
// Signal Labels
// =========================
var label lastSignalLabel = na

if showSignalLabels and newZ1
    if not keepHistoricalLabels and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    lastSignalLabel := label.new(
         bar_index,
         low,
         tickerLabel + "\nZ1" + (showAllocations ? " • Buy " + z1Alloc : ""),
         style=label.style_label_up,
         color=color.yellow,
         textcolor=color.black,
         size=size.small)

if showSignalLabels and newZ2
    if not keepHistoricalLabels and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    lastSignalLabel := label.new(
         bar_index,
         low,
         tickerLabel + "\nZ2" + (showAllocations ? " • Buy " + z2Alloc : ""),
         style=label.style_label_up,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

if showSignalLabels and newZ3
    if not keepHistoricalLabels and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    lastSignalLabel := label.new(
         bar_index,
         low,
         tickerLabel + "\nZ3" + (showAllocations ? " • Buy " + z3Alloc : ""),
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.small)

if showSignalLabels and newZ4
    if not keepHistoricalLabels and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    lastSignalLabel := label.new(
         bar_index,
         low,
         tickerLabel + "\nZ4" + (showAllocations ? " • Buy " + z4Alloc : ""),
         style=label.style_label_up,
         color=color.fuchsia,
         textcolor=color.white,
         size=size.small)

// =========================
// Compact Dashboard
// =========================
var table dash = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, tickerLabel, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, currentZone, text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "Z1", text_color=color.black, bgcolor=color.yellow)
    table.cell(dash, 1, 1, str.tostring(zone1, "#.##"), text_color=color.black, bgcolor=color.yellow)

    table.cell(dash, 0, 2, "Z2", text_color=color.white, bgcolor=color.orange)
    table.cell(dash, 1, 2, str.tostring(zone2, "#.##"), text_color=color.white, bgcolor=color.orange)

    table.cell(dash, 0, 3, "Z3", text_color=color.white, bgcolor=color.red)
    table.cell(dash, 1, 3, str.tostring(zone3, "#.##"), text_color=color.white, bgcolor=color.red)

    table.cell(dash, 0, 4, "Z4", text_color=color.white, bgcolor=color.fuchsia)
    table.cell(dash, 1, 4, str.tostring(zone4, "#.##"), text_color=color.white, bgcolor=color.fuchsia)

    table.cell(dash, 0, 5, "Action", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 5, nextAction, text_color=color.white, bgcolor=color.new(color.black, 0))

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 5)

// =========================
// Alerts
// =========================
alertcondition(newZ1, title="Métis Ladder Compression Engine v1.2 Clean - Zone 1 Entry", message="Métis Ladder Compression Engine v1.2 Clean: {{ticker}} entered Zone 1.")
alertcondition(newZ2, title="Métis Ladder Compression Engine v1.2 Clean - Zone 2 Entry", message="Métis Ladder Compression Engine v1.2 Clean: {{ticker}} entered Zone 2.")
alertcondition(newZ3, title="Métis Ladder Compression Engine v1.2 Clean - Zone 3 Entry", message="Métis Ladder Compression Engine v1.2 Clean: {{ticker}} entered Zone 3.")
alertcondition(newZ4, title="Métis Ladder Compression Engine v1.2 Clean - Zone 4 Entry", message="Métis Ladder Compression Engine v1.2 Clean: {{ticker}} entered Zone 4.")
````
