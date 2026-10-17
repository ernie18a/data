# Initial Balance Levels - MannyLeeTrades

- url: https://www.tradingview.com/script/qCJdj2jO-Initial-Balance-Levels-MannyLeeTrades/
- type: indicator
- pine_id: PUB;5baf325c5ce04e6f8df74da985dca12f
- version: 1.0

## Description

Initial Balance Range — Multi-Session IB Indicator
This indicator automatically plots the Initial Balance (IB) range for any session you define, drawing the high, low, and key internal levels directly on your chart. Works on any ticker and any timeframe — futures, stocks, forex, crypto.
What it draws:

IB High and IB Low with exact price labels
75%, 50% (EQ / midpoint), and 25% internal levels
Shaded box covering the full IB range
IB size displayed in brackets on the high label (e.g. [87.50])

All lines extend forward automatically so you can track how price interacts with the levels throughout the session.
Fully customizable settings:

Set any start and end time using 24-hour hour and minute inputs
Choose from 10 timezone options including New York, Chicago, London, Tokyo, Sydney, and UTC
Control how far lines extend to the right
Customize all colors individually — high line, low line, EQ, 75%, 25%, and box fill
Adjust line width and label size
Toggle the IB size label on or off

Common use cases:

New York session IB: 9:30–10:30 AM ET
Asia session IB: 8:00–9:00 PM ET (Tokyo open)
London open IB: 3:00–4:00 AM ET
Any custom range you want to study

Lines update in real time while the IB window is still forming, then lock in when the window closes. Compatible with all assets and all chart timeframes.

## Source Code

````pine
//@version=6
indicator("Initial Balance Levels", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ============================================================================
// TIME RANGE
// ============================================================================
string tGroup = "IB TIME RANGE"
string i_session    = input.session("0930-1030", "IB Time Range", group=tGroup, tooltip="The window during which the Initial Balance forms. Format HHMM-HHMM. Examples: 0930-1030, 2000-2100.")
string i_tz         = input.string("America/New_York", "Timezone", group=tGroup)
int    i_extendBars = input.int(60, "Extend Levels Right (bars)", group=tGroup, minval=1, maxval=500, tooltip="How far right the locked levels extend after the IB window closes. Raise on lower timeframes.")
bool   i_showLive   = input.bool(false, "Show Live Preview While Forming", group=tGroup, tooltip="OFF = each IB only appears (locked) once its window closes. ON = also shows the level lines building in real time.")

// ============================================================================
// IB FORMATION ZONE (shaded over the formation window)
// ============================================================================
string zGroup = "IB FORMATION ZONE"
bool   i_showZone  = input.bool(true, "Highlight IB Formation Zone", group=zGroup, tooltip="Shades the area between IB High and Low over the formation window. It does NOT extend right with the levels.")
color  i_zoneColor = input.color(color.new(#2962ff, 80), "Zone Highlight Color", group=zGroup)

// ============================================================================
// IB HIGH (100%)
// ============================================================================
string hGroup = "IB HIGH (100%)"
bool   i_showH = input.bool(true, "Show IB High", group=hGroup)
color  i_colH  = input.color(color.new(#e53935, 0), "Color", group=hGroup)
string i_styH  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=hGroup)
int    i_wH    = input.int(2, "Line Width", group=hGroup, minval=1, maxval=5)

// ============================================================================
// IB 75%
// ============================================================================
string g75 = "IB 75%"
bool   i_show75 = input.bool(true, "Show 75%", group=g75)
color  i_col75  = input.color(color.new(#7e57c2, 0), "Color", group=g75)
string i_sty75  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=g75)
int    i_w75    = input.int(1, "Line Width", group=g75, minval=1, maxval=5)

// ============================================================================
// IB 50%
// ============================================================================
string g50 = "IB 50% (Midpoint)"
bool   i_show50 = input.bool(true, "Show 50%", group=g50)
color  i_col50  = input.color(color.new(#787b86, 0), "Color", group=g50)
string i_sty50  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=g50)
int    i_w50    = input.int(1, "Line Width", group=g50, minval=1, maxval=5)

// ============================================================================
// IB 25%
// ============================================================================
string g25 = "IB 25%"
bool   i_show25 = input.bool(true, "Show 25%", group=g25)
color  i_col25  = input.color(color.new(#7e57c2, 0), "Color", group=g25)
string i_sty25  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=g25)
int    i_w25    = input.int(1, "Line Width", group=g25, minval=1, maxval=5)

// ============================================================================
// IB LOW (0%)
// ============================================================================
string lGroup = "IB LOW (0%)"
bool   i_showL = input.bool(true, "Show IB Low", group=lGroup)
color  i_colL  = input.color(color.new(#43a047, 0), "Color", group=lGroup)
string i_styL  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=lGroup)
int    i_wL    = input.int(2, "Line Width", group=lGroup, minval=1, maxval=5)

// ============================================================================
// LABELS
// ============================================================================
string labGroup = "LABELS"
bool   i_showLabels = input.bool(true,  "Show Level Labels", group=labGroup)
bool   i_showPrices = input.bool(true,  "Show Price Values", group=labGroup)
string i_lblSize    = input.string("Normal", "Label Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=labGroup)
bool   i_showRange  = input.bool(true,  "Show IB Range (size)", group=labGroup)
bool   i_rangeTicks = input.bool(false, "Show Range in Ticks (else points)", group=labGroup)

// ============================================================================
// HELPERS
// ============================================================================
f_style(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

f_txt(string name, float price) =>
    i_showPrices ? name + ": " + str.tostring(price, format.mintick) : name

f_lockLevel(bool show, int x1, int x2, float y, color c, string sty, int w, string name) =>
    if show
        line.new(x1, y, x2, y, xloc=xloc.bar_index, color=c, style=f_style(sty), width=w, force_overlay=true)
        if i_showLabels
            label.new(x2, y, f_txt(name, y), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=c, size=f_size(i_lblSize), force_overlay=true)

// ============================================================================
// SESSION DETECTION
// ============================================================================
bool isIntraday   = timeframe.isintraday
bool inSession    = isIntraday and not na(time(timeframe.period, i_session, i_tz))
bool sessionStart = inSession and not inSession[1]
bool sessionEnd   = isIntraday and not inSession and inSession[1]

// ============================================================================
// TRACK IB HIGH / LOW
// ============================================================================
var float ibHigh = na
var float ibLow  = na
var int   ibStartIdx = na
var int   ibEndIdx   = na

if sessionStart
    ibHigh := high
    ibLow  := low
    ibStartIdx := bar_index
    ibEndIdx   := bar_index
else if inSession
    ibHigh := math.max(ibHigh, high)
    ibLow  := math.min(ibLow, low)
    ibEndIdx := bar_index

// ============================================================================
// FORMATION ZONE HIGHLIGHT
// New box per IB; grows during the window, then locks over the formation
// window (does NOT extend right). Old boxes persist on historical IBs.
// ============================================================================
var box zoneBox = na

if i_showZone
    if sessionStart
        zoneBox := box.new(ibStartIdx, ibHigh, bar_index, ibLow, border_width=0, bgcolor=i_zoneColor, force_overlay=true)
    else if inSession and not na(zoneBox)
        box.set_top(zoneBox, ibHigh)
        box.set_bottom(zoneBox, ibLow)
        box.set_right(zoneBox, bar_index)
    // At/after session end: leave the box locked over the formation window.

// ============================================================================
// LIVE PREVIEW (optional line preview)
// ============================================================================
var line  pv_h  = na
var line  pv_75 = na
var line  pv_50 = na
var line  pv_25 = na
var line  pv_l  = na

if i_showLive
    if sessionStart
        pv_h  := i_showH  ? line.new(bar_index, ibHigh, bar_index, ibHigh, color=i_colH,  style=f_style(i_styH),  width=i_wH,  force_overlay=true) : na
        pv_75 := i_show75 ? line.new(bar_index, ibHigh, bar_index, ibHigh, color=i_col75, style=f_style(i_sty75), width=i_w75, force_overlay=true) : na
        pv_50 := i_show50 ? line.new(bar_index, ibHigh, bar_index, ibHigh, color=i_col50, style=f_style(i_sty50), width=i_w50, force_overlay=true) : na
        pv_25 := i_show25 ? line.new(bar_index, ibHigh, bar_index, ibHigh, color=i_col25, style=f_style(i_sty25), width=i_w25, force_overlay=true) : na
        pv_l  := i_showL  ? line.new(bar_index, ibLow,  bar_index, ibLow,  color=i_colL,  style=f_style(i_styL),  width=i_wL,  force_overlay=true) : na
    if inSession and not na(ibStartIdx)
        float rng = ibHigh - ibLow
        float v75 = ibLow + rng * 0.75
        float v50 = ibLow + rng * 0.50
        float v25 = ibLow + rng * 0.25
        if not na(pv_h)
            line.set_xy1(pv_h, ibStartIdx, ibHigh), line.set_xy2(pv_h, bar_index, ibHigh)
        if not na(pv_75)
            line.set_xy1(pv_75, ibStartIdx, v75), line.set_xy2(pv_75, bar_index, v75)
        if not na(pv_50)
            line.set_xy1(pv_50, ibStartIdx, v50), line.set_xy2(pv_50, bar_index, v50)
        if not na(pv_25)
            line.set_xy1(pv_25, ibStartIdx, v25), line.set_xy2(pv_25, bar_index, v25)
        if not na(pv_l)
            line.set_xy1(pv_l, ibStartIdx, ibLow), line.set_xy2(pv_l, bar_index, ibLow)
    if sessionEnd
        if not na(pv_h)
            line.delete(pv_h)
        if not na(pv_75)
            line.delete(pv_75)
        if not na(pv_50)
            line.delete(pv_50)
        if not na(pv_25)
            line.delete(pv_25)
        if not na(pv_l)
            line.delete(pv_l)

// ============================================================================
// LOCK THE IB — draw permanent static levels ONCE when the window closes
// ============================================================================
if sessionEnd and not na(ibStartIdx)
    float rng = ibHigh - ibLow
    float v75 = ibLow + rng * 0.75
    float v50 = ibLow + rng * 0.50
    float v25 = ibLow + rng * 0.25
    int   x1  = ibStartIdx
    int   x2  = ibEndIdx + i_extendBars

    f_lockLevel(i_showH,  x1, x2, ibHigh, i_colH,  i_styH,  i_wH, "IB High 100%")
    f_lockLevel(i_show75, x1, x2, v75,    i_col75, i_sty75, i_w75, "IB 75%")
    f_lockLevel(i_show50, x1, x2, v50,    i_col50, i_sty50, i_w50, "IB 50%")
    f_lockLevel(i_show25, x1, x2, v25,    i_col25, i_sty25, i_w25, "IB 25%")
    f_lockLevel(i_showL,  x1, x2, ibLow,  i_colL,  i_styL,  i_wL, "IB Low 0%")

    if i_showLabels and i_showRange
        float  rngVal  = i_rangeTicks ? rng / syminfo.mintick : rng
        string rngUnit = i_rangeTicks ? " ticks" : " pts"
        int    midX    = int(math.round((x1 + ibEndIdx) / 2))
        label.new(midX, ibHigh, "IB Range: " + str.tostring(rngVal, i_rangeTicks ? "#" : format.mintick) + rngUnit, xloc=xloc.bar_index, style=label.style_label_down, color=color.new(color.black, 100), textcolor=chart.fg_color, size=f_size(i_lblSize), force_overlay=true)

// ============================================================================
// NON-INTRADAY WARNING
// ============================================================================
if not isIntraday and barstate.islast
    label.new(bar_index, close, "Initial Balance requires an intraday timeframe\n(switch to 1m / 5m / 15m / etc.)", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal, force_overlay=true)
````
