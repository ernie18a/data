# Daily ATR Box

- url: https://www.tradingview.com/script/072od1ps-Daily-ATR-Box/
- type: indicator
- pine_id: PUB;ab449181038945fab1f82c3e9573c811
- version: 2.0

## Description

Daily ATR Box
This indicator plots a dynamic ATR-based price box anchored to key daily levels, giving you a clean visual range target directly on your chart.
How It Works
The box is sized by the Daily ATR (Average True Range) multiplied by a user-defined multiplier, so the range always reflects current volatility. You choose what price level anchors the box, and the indicator handles the rest — placing the box either above or below the anchor depending on the mode selected.
Anchor Modes

Previous Day High — Box top sits at PDH, extending downward by one ATR. Useful for gauging how far price may retrace after reclaiming the prior high.
Previous Day Low — Box bottom sits at PDL, extending upward by one ATR. Great for measuring bounce potential off prior lows.
Premarket High — Box top sits at the current session's premarket high (4:00 AM – 9:30 AM ET), extending downward. Updates live during premarket and locks at the open.
Premarket Low — Box bottom sits at the current session's premarket low, extending upward. Updates live during premarket and locks at the open.
Current Close — Box floats with the current bar's close. Useful for intraday range projection.
Manual Price — Set any price level as the anchor for full custom control.

Features

ATR length and multiplier are fully adjustable
Drag Offset input lets you shift the box up or down freely without changing the anchor
Box width adjustable in bars
Optional right extension to project the zone forward
Customizable fill and border colors
Label displays the live ATR value, anchor mode, anchor price, and offset
Box Top, Box Bottom, PDH, PDL, Premarket High, and Premarket Low all plotted to the Data Window for easy reference

Recommended Usage
Works on any timeframe but is designed around the daily ATR, so it is most useful on intraday charts (1m – 15m) where the daily range provides meaningful context. Pair it with your existing support/resistance levels or volume profile to identify high-probability reaction zones within the expected daily range.

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

// ─── Daily values ─────────────────────────────────────────────────────────────
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
dailyATR    = request.security(syminfo.tickerid, "D", ta.atr(atrLength), lookahead=barmerge.lookahead_off)
atrValue    = dailyATR * atrMult

// ─── Time helpers (all in ET) ─────────────────────────────────────────────────
nyHour   = hour(time,   "America/New_York")
nyMinute = minute(time, "America/New_York")

isPremarket = (nyHour >= 4 and nyHour < 9) or (nyHour == 9 and nyMinute < 30)
isRegular   = (nyHour == 9 and nyMinute >= 30) or (nyHour > 9 and nyHour < 16)
regularOpen = nyHour == 9 and nyMinute == 30

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
