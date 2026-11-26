# Really Relative Volume (RVol) [BruzX]

- url: https://www.tradingview.com/script/xJus2Qd4-Really-Relative-Volume-RVol-BruzX/
- type: indicator
- pine_id: PUB;954a5eff02e140379319e680aeb9a151
- version: 3.0

## Description

█ OVERVIEW

This indicator simply shows an estimate of intraday relative volume (RVol). By default, this is displayed as a small label at a configurable location on the pane. Optionally, the indicator can be moved to its own pane, where a plot of the historic values is shown as RVol develops throughout the session, as shown in the image below.
https://www.tradingview.com/x/nXc9cGpK/
█ FEATURES
[list]
[*] Shows RVol either as a small label in a configurable location or as a plot
[*] Optionally can exclude pre- and post-market volume from the calculation for stocks
[*] Allows choosing between exponential moving average (EMA) and relative moving average (RMA) for the averaging method of cumulative volume per session
[/list]
█ CONCEPTS

Relative volume (RVol) is the cumulative volume up to the current bar in the current session compared to the average cumulative volume up to the same bar over previous sessions. It is expressed as a percentage and is useful for assessing how actively a symbol is traded during the current day compared to what has been recently normal for that symbol.

It is intended for intraday use only. The exact value may vary slightly across timeframes due to how RVol is calculated. Generally, the lower the chart timeframe, the more accurate it is.

Between candle opens and closes, RVol is estimated using linear interpolation, based on the exact time of each tick, creating an estimate proportional to the amount of time elapsed within each bar.

RVol will differ during market hours depending on whether premarket data is included or excluded; this is expected and correct behaviour.

This indicator handles the average cumulative volume per bar correctly by storing the average for each bar in an array, making it more accurate than some similar indicators.

█ LIMITATIONS

A simple average is not available as an averaging method due to the complexity involved in storing a large matrix of each session’s volume values for each bar. Speed and efficiency are prioritised, and EMA and RMA can both be calculated recursively and efficiently. The difference is usually not significant.

█ DISCLAIMER

This indicator is provided for informational purposes only and should not be used in isolation without a good understanding of what it does and without considering other factors. You should not take trades using real money based solely on what this indicator indicates. Any trades you take are entirely at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BruzX
 
//@version=6
indicator("Really Relative Volume (RVol) [BruzX]", shorttitle = "RRV", overlay = true)

// ╔───────────────────────────────────────────────────────────────────────────────────╗
// │                                                                                   │
// │ __/\\\\\\\\\\\\\______/\\\\\\\\\______/\\\________/\\\__/\\\\\\\\\\\\\\\_         │
// │  _\/\\\/////////\\\__/\\\///////\\\___\/\\\_______\/\\\_\////////////\\\__        │
// │   _\/\\\_______\/\\\_\/\\\_____\/\\\___\/\\\_______\/\\\___________/\\\/___       │
// │    _\/\\\\\\\\\\\\\\__\/\\\\\\\\\\\/____\/\\\_______\/\\\_________/\\\/_____      │
// │     _\/\\\/////////\\\_\/\\\//////\\\____\/\\\_______\/\\\_______/\\\/_______     │
// │      _\/\\\_______\/\\\_\/\\\____\//\\\___\/\\\_______\/\\\_____/\\\/_________    │
// │       _\/\\\_______\/\\\_\/\\\_____\//\\\__\//\\\______/\\\____/\\\/___________   │
// │        _\/\\\\\\\\\\\\\/__\/\\\______\//\\\__\///\\\\\\\\\/____/\\\\\\\\\\\\\\\_  │
// │         _\/////////////____\///________\///_____\/////////_____\///////////////__ │
// │                                                                                   │
// ╚───────────────────────────────────────────────────────────────────────────────────╝

// ---- Enums

enum TableLocation
    no = "None"
    tl = "Top Left"
    tc = "Top Centre"
    tr = "Top Right"
    ml = "Middle Left"
    mc = "Middle Centre"
    mr = "Middle Right"
    bl = "Bottom Left"
    bc = "Bottom Centre"
    br = "Bottom Right"

// ---- UDTs

// ---- Constants

const bool DEV_MODE = false

// ---- Inputs

string avgMethod = input.string("RMA", "Averaging method", ["EMA", "RMA"], tooltip = "The method to average day by day the cumulative volume to the current bar within each session. This is used for the comparison of the cumulative volume of the current bar to determine the relative volume")
int avgLength = input.int(14, "Averaging length (days)", tooltip = "Parameter controlling the decay rate of the averaging method")
TableLocation tableLocation = input.enum(TableLocation.br, "Label location", tooltip = "Specify a location for the info label or disable it", display = display.all - display.status_line)
bool excludePremarket = input.bool(false, "Exclude pre/post-market", tooltip = "When viewing a ETH chart, this option ignores any volume in the pre- and post-market for stocks")
bool showPlot = input.bool(false, "Show plot", tooltip = "Shows a plot of the historical relative volume. When using this option, the indicator should be moved to its own pane")


// ---- Functions

debug(bool logPredicate, string message) =>
    if DEV_MODE and logPredicate
        log.info(message)

// ---- Logic

var int barInSession = na
var int sessionStartTime = na
var float cumulVolume = na

var array<float> volumeRmaArr = array.new<float>()
var float prevUsualVolumeRma = na

bool sessionStartBar = excludePremarket ? session.isfirstbar_regular : session.isfirstbar

if session.isfirstbar
    cumulVolume := 0

if sessionStartBar
    int barTime = time

    // Extract components in chart timezone and snap back to previous 30-min boundary
    int snappedMinute = minute(barTime) >= 30 ? 30 : 0    

    sessionStartTime := timestamp(year(barTime), month(barTime), dayofmonth(barTime), hour(barTime), snappedMinute)

    prevUsualVolumeRma := 0

barInSession := int((time - sessionStartTime) / (timeframe.in_seconds() * 1000))

while barInSession >= array.size(volumeRmaArr)
    array.push(volumeRmaArr, 100.0)
    
float usualVolumeRma = array.get(volumeRmaArr, barInSession)

if not excludePremarket or session.ismarket
    cumulVolume += volume

float rvolPercent = if barstate.isrealtime 
    100 * cumulVolume / (prevUsualVolumeRma + (usualVolumeRma - prevUsualVolumeRma) * (timenow - time) / (timeframe.in_seconds() * 1000))
else
    100 * cumulVolume / usualVolumeRma

float updatedVolumeRma = switch avgMethod 
    "RMA" => (usualVolumeRma * (avgLength - 1) + cumulVolume) / avgLength
    "EMA" => 2 / (avgLength + 1) * cumulVolume  + (1 - 2 / (avgLength + 1)) * usualVolumeRma
    => na

if not na(updatedVolumeRma)
    array.set(volumeRmaArr, barInSession, updatedVolumeRma)
    prevUsualVolumeRma := usualVolumeRma

// ---- Visuals

plot(rvolPercent, color = color.blue, display = showPlot ? display.all : display.data_window + display.status_line)

if barstate.islast and tableLocation != TableLocation.no
    string tableLocationString = switch tableLocation        
        TableLocation.tl => position.top_left
        TableLocation.tc => position.top_center
        TableLocation.tr => position.top_right        
        TableLocation.ml => position.middle_left
        TableLocation.mc => position.middle_center
        TableLocation.mr => position.middle_right
        TableLocation.bl => position.bottom_left
        TableLocation.bc => position.bottom_center        
        TableLocation.br => position.bottom_right

    table infoTable = table.new(tableLocationString, 1, 1, color.black, color.white, 1, color.white, 1)
    table.cell(infoTable, 0, 0, "RVol: " + str.tostring(rvolPercent, "#") + "%", text_color = color.white)


// ---- Alerts
````
