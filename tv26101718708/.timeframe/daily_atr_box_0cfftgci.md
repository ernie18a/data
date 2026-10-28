# Daily ATR Box

- url: https://www.tradingview.com/script/0cFFtGci-Daily-ATR-Box/
- type: indicator
- pine_id: PUB;3d7992436e2f4e74b67bfee94b5f3054
- version: 1.0

## Description

Daily ATR Box
A volatility-based price box anchored to the key levels traders watch most — previous day high/low, premarket high/low, current day high/low, current close, or a manual price — sized automatically by the Daily ATR so the range always reflects current market conditions.
How It Works
The box height equals the Daily Average True Range multiplied by a user-defined multiplier. You select the anchor level and the indicator places the box either above or below it depending on the anchor type. High anchors (Previous Day High, Premarket High, Current Day High) place the box top at the level and extend downward, showing how far price may retrace after testing that high. Low anchors (Previous Day Low, Premarket Low, Current Day Low) place the box bottom at the level and extend upward, showing the potential bounce range from that support.
Anchor Modes

Previous Day High — Box top sits at PDH, extending down by one ATR. Useful for measuring retracement potential after reclaiming the prior session's high
Previous Day Low — Box bottom sits at PDL, extending up by one ATR. Identifies the bounce range off prior session support
Premarket High — Box top sits at the current session's premarket high, extending downward. Updates live during premarket and locks at the 9:30 AM ET open
Premarket Low — Box bottom sits at the current session's premarket low, extending upward. Same live tracking and lock behavior as premarket high
Current Day High — Box top sits at the highest point reached so far in the current session including premarket, extending downward. Updates in real time as new highs are made
Current Day Low — Box bottom sits at the lowest point reached so far in the current session including premarket, extending upward. Updates in real time as new lows are made
Current Close — Box floats with the current bar's close price. Useful for projecting the ATR range from wherever price currently sits
Manual Price — Set any custom price level as the anchor for full flexibility

Features

ATR length and multiplier fully adjustable
Drag Offset input shifts the entire box up or down freely without changing the anchor
Box width adjustable in bars
Optional right extension to project the zone forward on the chart
Fully customizable fill and border colors
Label displays the live ATR value, anchor mode, anchor price, and drag offset when applied
All key levels plotted to the Data Window for easy reference — ATR, Box Top, Box Bottom, PDH, PDL, Premarket High, Premarket Low, Current Day High, Current Day Low
Built in Pine Script v6

Recommended Usage
Designed for intraday charts from 1 minute to 15 minutes where the daily ATR provides meaningful context for expected range. Pair with volume or order flow tools to identify whether price is likely to accept or reject the ATR zone when it arrives at a key anchor level.

## Source Code

````pine
//@version=6
indicator("Daily ATR Box", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
atrLength   = input.int(14,    title="ATR Length",      minval=1)
atrMult     = input.float(1.0, title="ATR Multiplier",  minval=0.1, step=0.1)
boxWidth    = input.int(20,    title="Box Width (bars)", minval=1)

anchorMode  = input.string("Previous Day High", title="Box Anchor",
                 options=["Previous Day High", "Previous Day Low",
                          "Premarket High", "Premarket Low",
                          "Current Day High", "Current Day Low",
                          "Current Close", "Manual Price"])
manualPrice = input.float(0.0, title="Manual Price (if selected above)", step=0.01)
dragOffset  = input.float(0.0, title="Drag Offset (+ up / - down)", step=0.01)

boxColor    = input.color(color.new(color.blue, 80), title="Box Fill Color")
borderColor = input.color(color.new(color.blue, 20), title="Box Border Color")
showLabel   = input.bool(true,  title="Show Label")
extendRight = input.bool(false, title="Extend Box Right")

// ─── Time helpers (all in ET) ─────────────────────────────────────────────────
nyHour   = hour(time,   "America/New_York")
nyMinute = minute(time, "America/New_York")

isPremarket = (nyHour >= 4 and nyHour < 9) or (nyHour == 9 and nyMinute < 30)
isRegular   = (nyHour == 9 and nyMinute >= 30) or (nyHour > 9 and nyHour < 16)
regularOpen = nyHour == 9 and nyMinute == 30

// ─── Daily values ─────────────────────────────────────────────────────────────
// Pull daily high/low without offset first
_dHigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_off)
_dLow  = request.security(syminfo.tickerid, "D", low,  lookahead=barmerge.lookahead_off)
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLength), lookahead=barmerge.lookahead_off)
atrValue = dailyATR * atrMult

// During premarket the daily bar hasn't started yet so [0] = yesterday's completed bar
// During regular session [0] = today's forming bar so we need [1]
prevDayHigh = isRegular ? _dHigh[1] : _dHigh
prevDayLow  = isRegular ? _dLow[1]  : _dLow

// ─── Premarket High/Low tracking ─────────────────────────────────────────────
var bool  inPM       = false
var float pmHiTrack  = na
var float pmLoTrack  = na
var float pmHiLocked = na
var float pmLoLocked = na

newPM = isPremarket and not inPM
if isPremarket
    inPM := true
else if isRegular
    inPM := false

if newPM
    pmHiTrack := high
    pmLoTrack := low

if isPremarket and not newPM
    pmHiTrack := na(pmHiTrack) ? high : math.max(pmHiTrack, high)
    pmLoTrack := na(pmLoTrack) ? low  : math.min(pmLoTrack, low)

if regularOpen
    pmHiLocked := pmHiTrack
    pmLoLocked := pmLoTrack

pmHigh = isPremarket ? pmHiTrack : pmHiLocked
pmLow  = isPremarket ? pmLoTrack : pmLoLocked

// ─── Current Day High/Low tracking ───────────────────────────────────────────
var float cdHigh = na
var float cdLow  = na

isNewDay = dayofweek != dayofweek[1]
if isNewDay or (isPremarket and not isPremarket[1])
    cdHigh := high
    cdLow  := low

if isPremarket or isRegular
    cdHigh := na(cdHigh) ? high : math.max(cdHigh, high)
    cdLow  := na(cdLow)  ? low  : math.min(cdLow,  low)

// ─── Resolve anchor & box direction ──────────────────────────────────────────
anchorBase = switch anchorMode
    "Previous Day High" => prevDayHigh
    "Previous Day Low"  => prevDayLow
    "Premarket High"    => pmHigh
    "Premarket Low"     => pmLow
    "Current Day High"  => cdHigh
    "Current Day Low"   => cdLow
    "Current Close"     => close
    "Manual Price"      => manualPrice
    => prevDayHigh

topAnchor = anchorMode == "Previous Day High" or anchorMode == "Premarket High" or anchorMode == "Current Day High"

boxTop    = topAnchor ? anchorBase + dragOffset : anchorBase + dragOffset + atrValue
boxBottom = topAnchor ? anchorBase + dragOffset - atrValue : anchorBase + dragOffset

// ─── Draw box ─────────────────────────────────────────────────────────────────
var box atrBox = na

if bar_index >= boxWidth
    if not na(atrBox)
        box.delete(atrBox)
    atrBox := box.new(
         left         = bar_index - boxWidth,
         top          = boxTop,
         right        = bar_index,
         bottom       = boxBottom,
         border_color = borderColor,
         border_width = 1,
         bgcolor      = boxColor,
         extend       = extendRight ? extend.right : extend.none
         )

// ─── Label ────────────────────────────────────────────────────────────────────
var label atrLabel = na

if showLabel
    if not na(atrLabel)
        label.delete(atrLabel)
    anchorName = switch anchorMode
        "Previous Day High" => "PDH"
        "Previous Day Low"  => "PDL"
        "Premarket High"    => "PM High"
        "Premarket Low"     => "PM Low"
        "Current Day High"  => "CD High"
        "Current Day Low"   => "CD Low"
        "Current Close"     => "Close"
        "Manual Price"      => "Manual"
        => "PDH"
    offsetTxt  = dragOffset != 0 ? "  offset: " + str.tostring(dragOffset, "#.####") : ""
    labelLine1 = "Daily ATR(" + str.tostring(atrLength) + "): " + str.tostring(math.round(atrValue, 4))
    labelLine2 = "Anchor: " + anchorName + " " + str.tostring(math.round(anchorBase, 4)) + offsetTxt
    atrLabel  := label.new(
         x         = bar_index,
         y         = boxTop,
         text      = labelLine1 + "\n" + labelLine2,
         style     = label.style_label_lower_right,
         color     = color.new(borderColor, 60),
         textcolor = borderColor,
         size      = size.small
         )

// ─── Data window ──────────────────────────────────────────────────────────────
plot(dailyATR,    title="Daily ATR",        display=display.data_window, color=color.orange)
plot(boxTop,      title="Box Top",          display=display.data_window, color=color.green)
plot(boxBottom,   title="Box Bottom",       display=display.data_window, color=color.red)
plot(prevDayHigh, title="Prev Day High",    display=display.data_window, color=color.blue)
plot(prevDayLow,  title="Prev Day Low",     display=display.data_window, color=color.purple)
plot(pmHigh,      title="Premarket High",   display=display.data_window, color=color.teal)
plot(pmLow,       title="Premarket Low",    display=display.data_window, color=color.yellow)
plot(cdHigh,      title="Current Day High", display=display.data_window, color=color.lime)
plot(cdLow,       title="Current Day Low",  display=display.data_window, color=color.orange)
````
