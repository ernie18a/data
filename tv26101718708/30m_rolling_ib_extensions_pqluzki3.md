# 30m Rolling IB & Extensions

- url: https://www.tradingview.com/script/pqluzKI3-30m-Rolling-IB-Extensions/
- type: indicator
- pine_id: PUB;181f1f0330d044de86ced36c9cba6697
- version: 7.0

## Description

Overview
The 30m Rolling IB & Extensions indicator is designed for day traders and scalpers who monitor short-term price action and structure on intraday timeframes. Instead of using a traditional daily or session-long Initial Balance, this script continuously tracks and projects a rolling 30-minute Initial Balance. It measures the High and Low of a 30-minute interval and projects those levels—along with precision extensions—onto the following 30-minute period.

How It Works

Time-Restricted Tracking: The indicator actively monitors price action during a specific, user-defined intraday session (defaulting to 19:00 - 16:00 EST). During this time, it tracks the Highest High and Lowest Low of every 30-minute block.
Rolling Projections: Once a 30-minute block closes, its High and Low are established as the new "Initial Balance" (IB). These levels are then plotted forward over the current 30-minute candle(s) to act as immediate support and resistance references.
Fibonacci-Style Extensions: Beyond the core IB High and Low, the indicator calculates the range of that previous 30-minute block and plots micro-extensions (0.1, 0.2, 0.3, 0.4, and 0.5) above the High and below the Low.
Trading Application

Range Breakouts & Fades: The plotted IB High and Low serve as immediate, short-term battlegrounds. A strong break beyond the IB can signal a short-term trend continuation into the extension levels, while failures at the IB edges can offer quick mean-reversion (fade) opportunities.
Targeting & Stop Placement: The 0.1 through 0.5 extensions act as dynamic, volatility-adjusted price targets or areas to scale out of positions.
Market Context: Because it resets every 30 minutes, this indicator adapts incredibly fast to intraday volatility compared to static daily levels, keeping you focused strictly on the most recent short-term market structure.
Features

Dynamic labels that display exactly on the current price scale for quick reference.
Customizable active tracking session (Input your own preferred start/stop times and timezone).
Clean, non-intrusive linebr plots that only show up during active periods and don't muddy up your chart with connecting lines during the inactive hours.

## Source Code

````pine
//@version=6
indicator("30m Rolling IB & Extensions", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Inputs ---
var string sessionTime = input.session("1900-1600", title="Active Session Time (EST/EDT)", tooltip="Session where 30m IBs are tracked")
string tz = input.string("America/New_York", title="Timezone")

// Colors
color ibColor = input.color(color.blue, "IB H/L Color", group="Visuals")
color extColor = input.color(color.gray, "Extension Color", group="Visuals")
color slColor = input.color(color.red, "SL Lines (25%/50%/75%) Color", group="Visuals")

// --- Logic ---
// Check if we are in the active session
bool inSession = not na(time(timeframe.period, sessionTime, tz))

// Detect a new 30-minute period
bool new30m = ta.change(time("30", "1900-1600", tz)) != 0

var float current30mHigh = na
var float current30mLow = na

var float prev30mHigh = na
var float prev30mLow = na

var int startBarIndex = na

if inSession
    if new30m
        prev30mHigh := current30mHigh
        prev30mLow := current30mLow
        current30mHigh := high
        current30mLow := low
        startBarIndex := bar_index
    else
        current30mHigh := math.max(current30mHigh, high)
        current30mLow := math.min(current30mLow, low)
else
    current30mHigh := na
    current30mLow := na
    prev30mHigh := na
    prev30mLow := na
    startBarIndex := na

// We plot the previous 30m high/low and its extensions during the current 30m period
float range_1 = prev30mHigh - prev30mLow

// Levels
float ibHigh = prev30mHigh
float ibLow = prev30mLow

float ib75 = ibLow + range_1 * 0.75
float ib50 = ibLow + range_1 * 0.50
float ib25 = ibLow + range_1 * 0.25

float ext01_high = ibHigh + range_1 * 0.1
float ext02_high = ibHigh + range_1 * 0.2
float ext03_high = ibHigh + range_1 * 0.3
float ext04_high = ibHigh + range_1 * 0.4
float ext05_high = ibHigh + range_1 * 0.5

float ext01_low = ibLow - range_1 * 0.1
float ext02_low = ibLow - range_1 * 0.2
float ext03_low = ibLow - range_1 * 0.3
float ext04_low = ibLow - range_1 * 0.4
float ext05_low = ibLow - range_1 * 0.5

bool showPlots = inSession and not na(prev30mHigh)

// --- Lines for the current active segment ---
var line line_ibHigh = line.new(na, na, na, na, color=ibColor, width=2)
var line line_ibLow = line.new(na, na, na, na, color=ibColor, width=2)

var line line_ib75 = line.new(na, na, na, na, color=slColor, style=line.style_dashed)
var line line_ib50 = line.new(na, na, na, na, color=slColor, style=line.style_dotted)
var line line_ib25 = line.new(na, na, na, na, color=slColor, style=line.style_dashed)

var line line_e1h = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e2h = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e3h = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e4h = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e5h = line.new(na, na, na, na, color=extColor, style=line.style_solid)

var line line_e1l = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e2l = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e3l = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e4l = line.new(na, na, na, na, color=extColor, style=line.style_solid)
var line line_e5l = line.new(na, na, na, na, color=extColor, style=line.style_solid)

// Update lines
if showPlots
    int endBarIndex = bar_index + 10
    
    line.set_xy1(line_ibHigh, startBarIndex, ibHigh)
    line.set_xy2(line_ibHigh, endBarIndex, ibHigh)
    
    line.set_xy1(line_ibLow, startBarIndex, ibLow)
    line.set_xy2(line_ibLow, endBarIndex, ibLow)

    line.set_xy1(line_ib75, startBarIndex, ib75)
    line.set_xy2(line_ib75, endBarIndex, ib75)
    
    line.set_xy1(line_ib50, startBarIndex, ib50)
    line.set_xy2(line_ib50, endBarIndex, ib50)

    line.set_xy1(line_ib25, startBarIndex, ib25)
    line.set_xy2(line_ib25, endBarIndex, ib25)
    
    line.set_xy1(line_e1h, startBarIndex, ext01_high)
    line.set_xy2(line_e1h, endBarIndex, ext01_high)
    line.set_xy1(line_e2h, startBarIndex, ext02_high)
    line.set_xy2(line_e2h, endBarIndex, ext02_high)
    line.set_xy1(line_e3h, startBarIndex, ext03_high)
    line.set_xy2(line_e3h, endBarIndex, ext03_high)
    line.set_xy1(line_e4h, startBarIndex, ext04_high)
    line.set_xy2(line_e4h, endBarIndex, ext04_high)
    line.set_xy1(line_e5h, startBarIndex, ext05_high)
    line.set_xy2(line_e5h, endBarIndex, ext05_high)
    
    line.set_xy1(line_e1l, startBarIndex, ext01_low)
    line.set_xy2(line_e1l, endBarIndex, ext01_low)
    line.set_xy1(line_e2l, startBarIndex, ext02_low)
    line.set_xy2(line_e2l, endBarIndex, ext02_low)
    line.set_xy1(line_e3l, startBarIndex, ext03_low)
    line.set_xy2(line_e3l, endBarIndex, ext03_low)
    line.set_xy1(line_e4l, startBarIndex, ext04_low)
    line.set_xy2(line_e4l, endBarIndex, ext04_low)
    line.set_xy1(line_e5l, startBarIndex, ext05_low)
    line.set_xy2(line_e5l, endBarIndex, ext05_low)
else
    line.set_xy1(line_ibHigh, na, na)
    line.set_xy1(line_ibLow, na, na)
    line.set_xy1(line_ib75, na, na)
    line.set_xy1(line_ib50, na, na)
    line.set_xy1(line_ib25, na, na)
    line.set_xy1(line_e1h, na, na)
    line.set_xy1(line_e2h, na, na)
    line.set_xy1(line_e3h, na, na)
    line.set_xy1(line_e4h, na, na)
    line.set_xy1(line_e5h, na, na)
    line.set_xy1(line_e1l, na, na)
    line.set_xy1(line_e2l, na, na)
    line.set_xy1(line_e3l, na, na)
    line.set_xy1(line_e4l, na, na)
    line.set_xy1(line_e5l, na, na)

// --- Labels for the current active segment ---
var label lbl_ibHigh = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ibColor, size=size.small)
var label lbl_ibLow = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ibColor, size=size.small)

var label lbl_ib75 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=slColor, size=size.small)
var label lbl_ib50 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=slColor, size=size.small)
var label lbl_ib25 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=slColor, size=size.small)

var label lbl_e1h = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e2h = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e3h = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e4h = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e5h = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)

var label lbl_e1l = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e2l = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e3l = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e4l = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)
var label lbl_e5l = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=extColor, size=size.small)

if showPlots
    int labelBarIndex = bar_index + 11
    
    label.set_xy(lbl_ibHigh, labelBarIndex, ibHigh)
    label.set_text(lbl_ibHigh, "IB High: " + str.tostring(ibHigh, format.mintick))
    
    label.set_xy(lbl_ibLow, labelBarIndex, ibLow)
    label.set_text(lbl_ibLow, "IB Low: " + str.tostring(ibLow, format.mintick))

    label.set_xy(lbl_ib75, labelBarIndex, ib75)
    label.set_text(lbl_ib75, "75%: " + str.tostring(ib75, format.mintick))

    label.set_xy(lbl_ib50, labelBarIndex, ib50)
    label.set_text(lbl_ib50, "50%: " + str.tostring(ib50, format.mintick))

    label.set_xy(lbl_ib25, labelBarIndex, ib25)
    label.set_text(lbl_ib25, "25%: " + str.tostring(ib25, format.mintick))
    
    label.set_xy(lbl_e1h, labelBarIndex, ext01_high)
    label.set_text(lbl_e1h, "0.1: " + str.tostring(ext01_high, format.mintick))
    label.set_xy(lbl_e2h, labelBarIndex, ext02_high)
    label.set_text(lbl_e2h, "0.2: " + str.tostring(ext02_high, format.mintick))
    label.set_xy(lbl_e3h, labelBarIndex, ext03_high)
    label.set_text(lbl_e3h, "0.3: " + str.tostring(ext03_high, format.mintick))
    label.set_xy(lbl_e4h, labelBarIndex, ext04_high)
    label.set_text(lbl_e4h, "0.4: " + str.tostring(ext04_high, format.mintick))
    label.set_xy(lbl_e5h, labelBarIndex, ext05_high)
    label.set_text(lbl_e5h, "0.5: " + str.tostring(ext05_high, format.mintick))
    
    label.set_xy(lbl_e1l, labelBarIndex, ext01_low)
    label.set_text(lbl_e1l, "-0.1: " + str.tostring(ext01_low, format.mintick))
    label.set_xy(lbl_e2l, labelBarIndex, ext02_low)
    label.set_text(lbl_e2l, "-0.2: " + str.tostring(ext02_low, format.mintick))
    label.set_xy(lbl_e3l, labelBarIndex, ext03_low)
    label.set_text(lbl_e3l, "-0.3: " + str.tostring(ext03_low, format.mintick))
    label.set_xy(lbl_e4l, labelBarIndex, ext04_low)
    label.set_text(lbl_e4l, "-0.4: " + str.tostring(ext04_low, format.mintick))
    label.set_xy(lbl_e5l, labelBarIndex, ext05_low)
    label.set_text(lbl_e5l, "-0.5: " + str.tostring(ext05_low, format.mintick))
else
    label.set_xy(lbl_ibHigh, na, na)
    label.set_xy(lbl_ibLow, na, na)
    label.set_xy(lbl_ib75, na, na)
    label.set_xy(lbl_ib50, na, na)
    label.set_xy(lbl_ib25, na, na)
    label.set_xy(lbl_e1h, na, na)
    label.set_xy(lbl_e2h, na, na)
    label.set_xy(lbl_e3h, na, na)
    label.set_xy(lbl_e4h, na, na)
    label.set_xy(lbl_e5h, na, na)
    label.set_xy(lbl_e1l, na, na)
    label.set_xy(lbl_e2l, na, na)
    label.set_xy(lbl_e3l, na, na)
    label.set_xy(lbl_e4l, na, na)
    label.set_xy(lbl_e5l, na, na)

// --- Alerts ---
var float ibHighCurrent = na
var float ibLowCurrent = na

if showPlots
    ibHighCurrent := ibHigh
    ibLowCurrent := ibLow

bool crossHigh = ta.crossover(close, ibHighCurrent)
bool crossLow = ta.crossunder(close, ibLowCurrent)

bool breakHigh = showPlots and crossHigh
bool breakLow = showPlots and crossLow

if breakHigh
    alert("Price broke above the 30m IB High at " + str.tostring(close), alert.freq_once_per_bar_close)

if breakLow
    alert("Price broke below the 30m IB Low at " + str.tostring(close), alert.freq_once_per_bar_close)

alertcondition(breakHigh or breakLow, title="IB Breakout", message="Price broke out of the 30m Initial Balance")
````
