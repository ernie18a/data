<!-- tradingview-pine-id: PUB;cdf368c5b38d4641ba5a34fe3abbb07f -->
<!-- tradingviewscripts-format: 1 -->
# Andrew Malek Trading - Clean ORB

Source: https://www.tradingview.com/script/L47B6Gqn-Andrew-Malek-Trading-Clean-ORB/

## Description

This is just a clean ORB indicator with some extra additions to make it useful at any time range! 

Inputs tab:

ORB range time: Select the time range you want
Display Until: Set the time frame you want this indicator to show during the trading day
Session Time zone: Select which time zone you want based on global sessions

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © andrewmalek55

//@version=6
indicator("Andrew Malek Trading - Clean ORB", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// USER SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string orbSession = input.session("0930-0945", "ORB Range Time")
string displaySession = input.session("0930-1600", "Display Until")

string sessionTimezone = input.string(
     "America/New_York",
     "Session Timezone",
     options=[
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "UTC"
     ])

bool showHigh = input.bool(true, "Show ORB High")
bool showLow = input.bool(true, "Show ORB Low")
bool showMidline = input.bool(true, "Show ORB Midline")
bool showLabels = input.bool(false, "Show Labels")
bool showFill = input.bool(false, "Fill ORB Range")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool inORB = not na(
     time(timeframe.period, orbSession, sessionTimezone))

bool inDisplaySession = not na(
     time(timeframe.period, displaySession, sessionTimezone))

// Detect first bar of the ORB
bool orbStart = inORB and not inORB[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORB HIGH / LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float orbHigh = na
var float orbLow = na

// Start a new ORB
if orbStart
    orbHigh := high
    orbLow := low

// Continue building the ORB
else if inORB
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORB MIDLINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float orbMid = (
     not na(orbHigh) and not na(orbLow)
     ? (orbHigh + orbLow) / 2.0
     : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float displayHigh = inDisplaySession ? orbHigh : na
float displayLow = inDisplaySession ? orbLow : na
float displayMid = inDisplaySession ? orbMid : na

pHigh = plot(
     showHigh ? displayHigh : na,
     title="ORB High",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr)

pLow = plot(
     showLow ? displayLow : na,
     title="ORB Low",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr)

plot(
     showMidline ? displayMid : na,
     title="ORB Midline",
     color=color.gray,
     linewidth=1,
     style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL RANGE FILL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fill(
     pHigh,
     pLow,
     color=showFill ? color.new(color.gray, 90) : na,
     title="ORB Range")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL LABEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showLabels and orbStart
    label.new(
         bar_index,
         high,
         "ORB",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.gray,
         size=size.small)
````
