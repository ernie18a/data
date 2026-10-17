# Bitcoin Halving Cycle Phases

- url: https://www.tradingview.com/script/wVsnNlZM-Bitcoin-Halving-Cycle-Phases/
- type: indicator
- pine_id: PUB;98bbde00f8ac42f09382e4353aa2d582
- version: 1.0

## Description

Bitcoin Halving Cycle Phases is a calendar-based visual indicator that highlights approximate Bitcoin halving cycle phase zones directly on the chart.

The indicator uses historical Bitcoin halving dates and predefined calendar phase boundaries to display different cycle regions, including Halving, Bullish, Bearish, Recovery, and Pre-halving phases. Future zones are projected using an approximate cycle length and are intended only as visual calendar references.

This script does not calculate price targets, buy or sell signals, trading entries, exits, stop losses, take profits, backtest results, or financial advice. The displayed future zones are approximate calendar projections only and should not be interpreted as forecasts or guaranteed market outcomes.

[i]The indicator is designed for educational cycle visualization and long-term market context.[/i]

## Source Code

````pine
//@version=6
// This source code is licensed under the Mozilla Public License 2.0.
// You can obtain a copy of the license at https://mozilla.org/MPL/2.0/
// This indicator visualizes calendar-based Bitcoin halving cycle phase zones.
// It does not calculate price targets, trading signals, entries, exits, or financial advice.
// Future zones are approximate calendar projections only.

indicator("Bitcoin Halving Cycle Phases", overlay=true, scale=scale.none, max_boxes_count=500, max_labels_count=500)

// Inputs
showBackground = input.bool(true, "Show Background", group="Display")
showText = input.bool(true, "Show Phase Text", group="Display")
halvingWindowDays = input.int(45, "Halving Zone Width In Days", minval=1, maxval=180, group="Cycle")
textSizeInput = input.string("Large", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Text")

// Colors
bullishColor = input.color(color.new(color.rgb(0, 170, 150), 84), "Bullish", group="Colors")
bearishColor = input.color(color.new(color.rgb(220, 45, 75), 86), "Bearish", group="Colors")
recoveryColor = input.color(color.new(color.rgb(0, 145, 190), 84), "Recovery", group="Colors")
preHalvingColor = input.color(color.new(color.rgb(245, 165, 35), 83), "Pre-halving", group="Colors")
halvingColor = input.color(color.new(color.rgb(125, 85, 255), 81), "Halving", group="Colors")
textColor = input.color(color.new(color.white, 0), "Phase Text", group="Colors")
halvingTextColor = input.color(color.new(color.rgb(220, 205, 255), 0), "Halving Text", group="Colors")

// Calendar model
const int DAY_MS = 86400000
const int CYCLE_DAYS = 1458
const int BULLISH_END_DAYS = 560
const int BEARISH_END_DAYS = 954
const int RECOVERY_END_DAYS = 1095
const int FUTURE_CYCLES = 12
const int CYCLE_MS = CYCLE_DAYS * DAY_MS

int halfWindowMs = int(math.round(halvingWindowDays * DAY_MS * 0.5))

// Halving dates
int h2012 = timestamp("UTC", 2012, 11, 28, 0, 0)
int h2016 = timestamp("UTC", 2016, 7, 9, 0, 0)
int h2020 = timestamp("UTC", 2020, 5, 11, 0, 0)
int h2024 = timestamp("UTC", 2024, 4, 20, 0, 0)

// Historical phase anchors
int top2013 = timestamp("UTC", 2013, 12, 4, 0, 0)
int low2015 = timestamp("UTC", 2015, 1, 14, 0, 0)
int pre2016 = h2016 - 365 * DAY_MS
int top2017 = timestamp("UTC", 2017, 12, 17, 0, 0)
int low2018 = timestamp("UTC", 2018, 12, 15, 0, 0)
int pre2020 = h2020 - 365 * DAY_MS
int top2021 = timestamp("UTC", 2021, 11, 10, 0, 0)
int low2022 = timestamp("UTC", 2022, 11, 21, 0, 0)
int pre2024 = h2024 - 365 * DAY_MS

// Runtime storage
var array<int> halvings = array.new_int()
var box[] futureBoxes = array.new_box()
var label[] phaseLabels = array.new_label()

// Initialization
if barstate.isfirst
    array.push(halvings, h2012)
    array.push(halvings, h2016)
    array.push(halvings, h2020)
    array.push(halvings, h2024)
    for i = 1 to FUTURE_CYCLES
        array.push(halvings, h2024 + CYCLE_MS * i)

// Text settings
textSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Normal" ? size.normal : size.large

// Chart range
var float chartHigh = na
var float chartLow = na

chartHigh := na(chartHigh) ? high : math.max(chartHigh, high)
chartLow := na(chartLow) ? low : math.min(chartLow, low)

float chartRange = math.max(chartHigh - chartLow, syminfo.mintick)
float futureBoxTop = chartHigh + chartRange * 100.0
float futureBoxBottom = math.max(chartLow - chartRange * 100.0, syminfo.mintick)
float labelY = futureBoxTop - chartRange * 5.0

// Helpers
f_mid(int startTime, int endTime) =>
    startTime + int(math.round((endTime - startTime) * 0.5))

f_phase_dates(int cycleStart, int cycleEnd) =>
    int bullishEnd = na
    int bearishEnd = na
    int recoveryEnd = na
    int preHalvingEnd = cycleEnd - halfWindowMs
    if cycleStart == h2012
        bullishEnd := top2013
        bearishEnd := low2015
        recoveryEnd := pre2016
    else if cycleStart == h2016
        bullishEnd := top2017
        bearishEnd := low2018
        recoveryEnd := pre2020
    else if cycleStart == h2020
        bullishEnd := top2021
        bearishEnd := low2022
        recoveryEnd := pre2024
    else
        bullishEnd := math.min(cycleStart + BULLISH_END_DAYS * DAY_MS, preHalvingEnd)
        bearishEnd := math.min(cycleStart + BEARISH_END_DAYS * DAY_MS, preHalvingEnd)
        recoveryEnd := math.min(cycleStart + RECOVERY_END_DAYS * DAY_MS, preHalvingEnd)
    [bullishEnd, bearishEnd, recoveryEnd, preHalvingEnd]

f_phase_color(int barTime) =>
    color activeColor = na
    int count = array.size(halvings)
    if count >= 2
        for i = 0 to count - 2
            int cycleStart = array.get(halvings, i)
            int cycleEnd = array.get(halvings, i + 1)
            int bullishStart = cycleStart + halfWindowMs
            [bullishEnd, bearishEnd, recoveryEnd, preHalvingEnd] = f_phase_dates(cycleStart, cycleEnd)
            if barTime >= cycleStart - halfWindowMs and barTime < cycleStart + halfWindowMs
                activeColor := halvingColor
            else if barTime >= bullishStart and barTime < bullishEnd
                activeColor := bullishColor
            else if barTime >= bullishEnd and barTime < bearishEnd
                activeColor := bearishColor
            else if barTime >= bearishEnd and barTime < recoveryEnd
                activeColor := recoveryColor
            else if barTime >= recoveryEnd and barTime < preHalvingEnd
                activeColor := preHalvingColor
    activeColor

f_clear_boxes() =>
    int count = array.size(futureBoxes)
    if count > 0
        for i = 0 to count - 1
            box.delete(array.get(futureBoxes, i))
    array.clear(futureBoxes)

f_clear_labels() =>
    int count = array.size(phaseLabels)
    if count > 0
        for i = 0 to count - 1
            label.delete(array.get(phaseLabels, i))
    array.clear(phaseLabels)

f_add_zone(int startTime, int endTime, string txt, color bg, color txtCol, int lastBarTime) =>
    if endTime > startTime
        if showBackground and endTime > lastBarTime
            int boxStart = math.max(startTime, lastBarTime)
            box bx = box.new(left=boxStart, top=futureBoxTop, right=endTime, bottom=futureBoxBottom, xloc=xloc.bar_time, border_color=color.new(bg, 100), bgcolor=bg)
            array.push(futureBoxes, bx)
        if showText
            label lb = label.new(x=f_mid(startTime, endTime), y=labelY, xloc=xloc.bar_time, yloc=yloc.price, text=txt, style=label.style_none, textcolor=txtCol, size=textSize)
            array.push(phaseLabels, lb)

// Background
bgcolor(showBackground ? f_phase_color(time) : na, title="Cycle Phase Background")

// Drawing
if barstate.islast
    f_clear_boxes()
    f_clear_labels()

    int lastBarTime = time
    int count = array.size(halvings)

    for i = 0 to count - 2
        int cycleStart = array.get(halvings, i)
        int cycleEnd = array.get(halvings, i + 1)
        int bullishStart = cycleStart + halfWindowMs
        [bullishEnd, bearishEnd, recoveryEnd, preHalvingEnd] = f_phase_dates(cycleStart, cycleEnd)

        f_add_zone(cycleStart - halfWindowMs, cycleStart + halfWindowMs, "HALVING", halvingColor, halvingTextColor, lastBarTime)
        f_add_zone(bullishStart, bullishEnd, "BULLISH", bullishColor, textColor, lastBarTime)
        f_add_zone(bullishEnd, bearishEnd, "BEARISH", bearishColor, textColor, lastBarTime)
        f_add_zone(bearishEnd, recoveryEnd, "RECOVERY", recoveryColor, textColor, lastBarTime)
        f_add_zone(recoveryEnd, preHalvingEnd, "PRE-HALVING", preHalvingColor, textColor, lastBarTime)

    int lastHalving = array.get(halvings, count - 1)
    f_add_zone(lastHalving - halfWindowMs, lastHalving + halfWindowMs, "HALVING", halvingColor, halvingTextColor, lastBarTime)
````
