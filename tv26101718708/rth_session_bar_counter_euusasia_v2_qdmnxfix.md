# RTH Session Bar Counter EU/US/Asia v.2

- url: https://www.tradingview.com/script/qdMNxfiX-RTH-Session-Bar-Counter-EU-US-Asia-v-2/
- type: indicator
- pine_id: PUB;adf09bdf1a4e41428a0fd5175ab34730
- version: 2.0

## Description

Counts bars inside Regular Trading Hours for Frankfurt (DAX), London (FTSE), US (NYSE/Nasdaq), or Tokyo (Nikkei) — auto-detected from the chart's symbol, with manual override.

Auto-detects the right session, or force it manually
Resets each session, runs through the Tokyo lunch break without resetting
Editable RTH hours per session
Hour-end bars marked in a different color
Optional marker on a specific bar number 
Adjustable size, color, and offset
Works on any intraday timeframe
Session times use each exchange's own local time + timezone, so they're correct regardless of your chart's timezone and auto-adjust for DST — no manual UTC math needed.

## Source Code

````pine
//@version=6
indicator("RTH Session Bar Counter", shorttitle="RTH Bars", overlay=true, max_labels_count=500)

// ============================================================================
// RTH SESSION BAR COUNTER
//
// Auto-detects which session applies to the current chart from the symbol's
// exchange timezone — Frankfurt/DAX, London/FTSE, US/NYSE, or Asia/Tokyo
// (Nikkei) — or lets you force one manually. Counts bars inside that
// session's RTH, resetting to 1 at the start of each session day and
// continuing straight through any intraday break (e.g. the Tokyo lunch
// break) without resetting.
//
// Session times are defined in each exchange's OWN local time plus its IANA
// timezone name. Pine automatically converts that to whatever timezone YOUR
// chart is displaying, and automatically adjusts for Daylight Saving Time —
// no manual UTC offset math needed, ever.
//
// Built and verified for 5m / 15m / 1h, but works on any intraday timeframe.
// ============================================================================

// ---------------------------- SESSION SELECTION ------------------------------
grpSess = "Session"
sessionMode = input.string("Auto-detect", "Session", options = ["Auto-detect", "Force Frankfurt/DAX", "Force London/FTSE", "Force US", "Force Asia"], group = grpSess)

grpTime = "Exchange RTH hours (exchange-local time — edit only if needed)"
frankfurtSess = input.session("0900-1730", "Frankfurt/DAX", group = grpTime)
londonSess    = input.session("0800-1630", "London/FTSE", group = grpTime)
usSess        = input.session("0930-1600", "US/NYSE", group = grpTime)
asiaSess      = input.session("0900-1130,1230-1530", "Asia/Tokyo-Nikkei (lunch break supported)", group = grpTime)

frankfurtTZ = "Europe/Berlin"
londonTZ    = "Europe/London"
usTZ        = "America/New_York"
asiaTZ      = "Asia/Tokyo"

// Which session applies, based on the symbol's exchange timezone (or a forced override)
autoSession = syminfo.timezone == frankfurtTZ ? "Frankfurt/DAX" : syminfo.timezone == londonTZ ? "London/FTSE" : syminfo.timezone == usTZ ? "US" : syminfo.timezone == asiaTZ ? "Asia" : "None"

activeSession = sessionMode == "Auto-detect" ? autoSession : sessionMode == "Force Frankfurt/DAX" ? "Frankfurt/DAX" : sessionMode == "Force London/FTSE" ? "London/FTSE" : sessionMode == "Force US" ? "US" : sessionMode == "Force Asia" ? "Asia" : "None"

noMatch = activeSession == "None"

// fall back to US hours internally when there's no match — result is discarded via noMatch below, this just avoids feeding na into time()/hour()
activeSess = activeSession == "Frankfurt/DAX" ? frankfurtSess : activeSession == "London/FTSE" ? londonSess : activeSession == "US" ? usSess : activeSession == "Asia" ? asiaSess : usSess
activeTZ   = activeSession == "Frankfurt/DAX" ? frankfurtTZ   : activeSession == "London/FTSE" ? londonTZ   : activeSession == "US" ? usTZ   : activeSession == "Asia" ? asiaTZ   : usTZ

// ---------------------------- APPEARANCE -------------------------------------
grpStyle = "Number appearance"
sizeOpt    = input.string("Small", "Number size", options = ["Tiny", "Small", "Normal", "Large"], group = grpStyle)
numColor   = input.color(#787b86, "Number color", group = grpStyle)
hourColor  = input.color(#ff9100, "Hour-end number color", group = grpStyle)
offsetMult = input.float(0.6, "Offset below bar (x ATR)", minval = 0.0, step = 0.1, group = grpStyle)

grpMarker = "Special bar marker"
markEnabled = input.bool(false, "Mark a specific bar number", group = grpMarker)
markBarNum  = input.int(18, "Bar number to mark", minval = 1, maxval = 999, group = grpMarker)
markColor   = input.color(#e91e63, "Marker color", group = grpMarker)

grpExtra = "Extras"
markStart   = input.bool(true, "Shade the first bar of every session", group = grpExtra)
startColor  = input.color(color.new(color.blue, 85), "Session-start shade color", group = grpExtra)
markHourBg  = input.bool(false, "Also shade background on hour-end bars", group = grpExtra)
hourBgColor = input.color(color.new(color.orange, 90), "Hour-end shade color", group = grpExtra)

lblSize = sizeOpt == "Tiny" ? size.tiny : sizeOpt == "Normal" ? size.normal : sizeOpt == "Large" ? size.large : size.small

// ---------------------------- SESSION DETECTION ------------------------------
tfOK      = timeframe.in_seconds(timeframe.period) <= 3600
sessNow   = time(timeframe.period, activeSess, activeTZ)
inSession = not noMatch and not na(sessNow) and tfOK

dateKey    = year(time, activeTZ) * 10000 + month(time, activeTZ) * 100 + dayofmonth(time, activeTZ)
hourEndNow = inSession and (hour(time_close, activeTZ) != hour(time, activeTZ))

// ---------------------------- BAR COUNTER ------------------------------------
var int barCount = 0
var int lastDate = -1

if inSession
    if dateKey != lastDate
        barCount := 1
        lastDate := dateKey
    else
        barCount += 1

isSessStart = inSession and barCount == 1
isMarked    = markEnabled and inSession and barCount == markBarNum

// ---------------------------- DRAW NUMBERS -----------------------------------
var label[] lbls = array.new<label>()
atrVal = ta.atr(20)

if inSession
    txtColor = isMarked ? markColor : hourEndNow ? hourColor : numColor
    yPos = low - atrVal * offsetMult
    lbl = label.new(bar_index, yPos, text = str.tostring(barCount), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = txtColor, size = lblSize)
    array.push(lbls, lbl)
    if array.size(lbls) > 480
        label.delete(array.shift(lbls))

bgcolor(markStart and isSessStart ? startColor : na)
bgcolor(markHourBg and hourEndNow ? hourBgColor : na)

// ---------------------------- WARNINGS ---------------------------------------
if barstate.islast and noMatch and tfOK
    label.new(bar_index, high, "No session match for this symbol's timezone (" + syminfo.timezone + ") — pick a Force option in Settings", style = label.style_label_down, color = color.red, textcolor = color.white, size = size.normal)
````
