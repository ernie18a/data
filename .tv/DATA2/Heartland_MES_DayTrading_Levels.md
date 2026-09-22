<!-- tradingview-pine-id: PUB;efc4b769db9548c384f7f4aa85e39c1b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Heartland MES Day-Trading Levels

Source: https://www.tradingview.com/script/wB2ZrOUZ-Heartland-MES-Day-Trading-Levels/

## Description

The Heartland MES Day-Trading Levels indicator places several important intraday reference levels together on one chart. It was designed for Micro E-mini S&P 500 futures traders who want a clear view of potential support, resistance and market direction.

The indicator includes:

• Previous-Day High and Low

• Overnight High and Low

• 15-Minute Opening-Range High and Low

• Regular-Session VWAP

The green line identifies the previous-day high, while the red line identifies the previous-day low.

The orange lines track the overnight high and low from 5:00 p.m. until 8:30 a.m. Central Time. These levels update throughout the overnight session and lock when the regular market session begins.

The purple lines calculate the opening range from 8:30 to 8:45 a.m. Central Time. They update during those first 15 minutes and remain fixed for the rest of the trading day.

The white VWAP line resets at 8:30 a.m. Central Time and tracks the regular session’s volume-weighted average price.

Each current level is identified with a label and exact price on the right side of the chart.

How I use it:

• Previous-day and overnight levels help identify possible support, resistance, breakout and profit-target areas.

• The opening range helps measure the market’s early direction.

• Price above VWAP can suggest that buyers have the advantage.

• Price below VWAP can suggest that sellers have the advantage.

This indicator is intended primarily for MES intraday charts using timeframes of 15 minutes or less. It does not provide automatic buy or sell signals. Traders should combine these levels with price action, volume, confirmation and proper risk management.

---

## Source Code

````pine
//@version=6
indicator("Heartland MES Day-Trading Levels", overlay=true, max_labels_count=20)

// Central Time sessions
string timeZone = "America/Chicago"
string overnightSession = "1700-0830:1234567"
string openingRangeSession = "0830-0845:23456"
string regularSession = "0830-1500:23456"

// ─────────────────────────────────────
// PREVIOUS-DAY HIGH AND LOW
// ─────────────────────────────────────
[previousHigh, previousLow] = request.security(
     syminfo.tickerid,
     "D",
     [high[1], low[1]],
     lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────
// OVERNIGHT HIGH AND LOW
// 5:00 p.m. to 8:30 a.m. Central
// ─────────────────────────────────────
bool inOvernight = not na(time(
     timeframe.period,
     overnightSession,
     timeZone))

bool newOvernight = inOvernight and not inOvernight[1]

var float overnightHigh = na
var float overnightLow = na

if newOvernight
    overnightHigh := high
    overnightLow := low
else if inOvernight
    overnightHigh := math.max(
         nz(overnightHigh, high), high)
    overnightLow := math.min(
         nz(overnightLow, low), low)

// ─────────────────────────────────────
// 15-MINUTE OPENING RANGE
// 8:30 a.m. to 8:45 a.m. Central
// ─────────────────────────────────────
bool inOpeningRange = not na(time(
     timeframe.period,
     openingRangeSession,
     timeZone))

bool newOpeningRange =
     inOpeningRange and not inOpeningRange[1]

var float openingHigh = na
var float openingLow = na

if newOpeningRange
    openingHigh := high
    openingLow := low
else if inOpeningRange
    openingHigh := math.max(
         nz(openingHigh, high), high)
    openingLow := math.min(
         nz(openingLow, low), low)

// ─────────────────────────────────────
// REGULAR-SESSION VWAP
// Resets at 8:30 a.m. Central
// ─────────────────────────────────────
bool inRegularSession = not na(time(
     timeframe.period,
     regularSession,
     timeZone))

bool newRegularSession =
     inRegularSession and not inRegularSession[1]

var float cumulativePriceVolume = na
var float cumulativeVolume = na

if newRegularSession
    cumulativePriceVolume := hlc3 * volume
    cumulativeVolume := volume
else if inRegularSession
    cumulativePriceVolume += hlc3 * volume
    cumulativeVolume += volume

float regularVWAP =
     cumulativePriceVolume / cumulativeVolume

// ─────────────────────────────────────
// PLOT THE LEVELS
// ─────────────────────────────────────
plot(
     previousHigh,
     "Previous-Day High",
     color=color.lime,
     linewidth=2,
     style=plot.style_stepline)

plot(
     previousLow,
     "Previous-Day Low",
     color=color.red,
     linewidth=2,
     style=plot.style_stepline)

plot(
     overnightHigh,
     "Overnight High",
     color=color.orange,
     linewidth=2,
     style=plot.style_stepline)

plot(
     overnightLow,
     "Overnight Low",
     color=color.orange,
     linewidth=2,
     style=plot.style_stepline)

plot(
     openingHigh,
     "15-Minute Opening High",
     color=color.fuchsia,
     linewidth=2,
     style=plot.style_stepline)

plot(
     openingLow,
     "15-Minute Opening Low",
     color=color.fuchsia,
     linewidth=2,
     style=plot.style_stepline)

plot(
     inRegularSession ? regularVWAP : na,
     "Regular-Session VWAP",
     color=color.white,
     linewidth=3)

// ─────────────────────────────────────
// IDENTIFY EACH CURRENT LEVEL
// ─────────────────────────────────────
var label pdhLabel = na
var label pdlLabel = na
var label onhLabel = na
var label onlLabel = na
var label orhLabel = na
var label orlLabel = na
var label vwapLabel = na

if barstate.islast
    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(onhLabel)
    label.delete(onlLabel)
    label.delete(orhLabel)
    label.delete(orlLabel)
    label.delete(vwapLabel)

    pdhLabel := label.new(
         bar_index + 3,
         previousHigh,
         "PD HIGH: " +
         str.tostring(previousHigh, format.mintick),
         style=label.style_label_left,
         color=color.lime,
         textcolor=color.black)

    pdlLabel := label.new(
         bar_index + 3,
         previousLow,
         "PD LOW: " +
         str.tostring(previousLow, format.mintick),
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    onhLabel := label.new(
         bar_index + 3,
         overnightHigh,
         "ON HIGH: " +
         str.tostring(overnightHigh, format.mintick),
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.black)

    onlLabel := label.new(
         bar_index + 3,
         overnightLow,
         "ON LOW: " +
         str.tostring(overnightLow, format.mintick),
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.black)

    orhLabel := label.new(
         bar_index + 3,
         openingHigh,
         "OR HIGH: " +
         str.tostring(openingHigh, format.mintick),
         style=label.style_label_left,
         color=color.fuchsia,
         textcolor=color.white)

    orlLabel := label.new(
         bar_index + 3,
         openingLow,
         "OR LOW: " +
         str.tostring(openingLow, format.mintick),
         style=label.style_label_left,
         color=color.fuchsia,
         textcolor=color.white)

    if inRegularSession
        vwapLabel := label.new(
             bar_index + 3,
             regularVWAP,
             "RTH VWAP: " +
             str.tostring(regularVWAP, format.mintick),
             style=label.style_label_left,
             color=color.white,
             textcolor=color.black)
````
