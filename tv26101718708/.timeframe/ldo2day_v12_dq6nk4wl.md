# LDO-2day v1.2

- url: https://www.tradingview.com/script/dQ6Nk4WL-LDO-2day-v1-2/
- type: indicator
- pine_id: PUB;3faba8224ee744dd8a010544e594123f
- version: 6.0

## Description

LDO-2day plots the high-low range of the last two completed days as two boxes that leap-frog each other.

WHAT IT DOES
Each completed day gets a box spanning that day's high and low. The box starts at the day's open and extends 48 hours forward, so it covers its own day and projects across the following day. Only two boxes are ever on the chart. When a day closes, the older box is removed and the day that has just finished takes its place. The two boxes alternate colour so you can tell them apart, and each carries a small label with the day it represents.

WHY TWO OVERLAPPING BOXES
Most daily-level tools draw yesterday's high and low as two lines that reset every day. LDO-2day keeps the last two daily ranges on screen as overlapping zones, each projected 48 hours from its own open. That shows at a glance whether price is trading inside both ranges (balance), has broken out of one but not the other, or is clear of both. Because each new box is drawn from its own day's open, it already extends a full day past the current bar when it appears, so the levels are in place before price reaches them.

HOW IT WORKS
- A day is the symbol's daily session as TradingView defines it (00:00 UTC for most crypto pairs).
- The script tracks each day's running high and low bar by bar.
- On the first bar of a new day it draws the finished day's box, from that day's open to the open plus 48 hours (configurable), and deletes the older of the two boxes on the chart.
- Boxes are only drawn for completed days, so a box never changes once it is on the chart.

HOW TO USE IT
Use it on intraday charts such as 15m, 1h or 4h. Watch how price behaves at the box edges: a sweep of a box high or low followed by a close back inside, or a retest of a broken edge from the other side. The boxes are reference levels, not signals. Combine them with your own entry and risk rules.

SETTINGS
Boxes: box length in hours (default 48), fill and line colour for box A and box B, shade box background on or off, line width, line style.
Day label: show or hide, colour, size.

LIMITATIONS
- Intraday charts only. On daily or higher timeframes the script shows an error message.
- Use timeframes that divide evenly into a day (for example 1h, 2h, 4h). With uneven bars a bar can straddle midnight, and its range is then counted in the wrong day.
- The 48-hour length is clock time. On markets that close at weekends, a Friday box extends into the weekend gap.
- The day boundary follows the exchange session, which may differ from your local time.

Original idea for the leap-frogging two-day boxes: Anton.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// LDO-2day v2.6 — two leap-frogging daily range boxes (idea: Anton) + Asia first-hour box
// v2.6: settings hidden from the name line (display.none on every input), so a new alert's default name is just
//       "LDO-2day v2.6" instead of the name plus every setting value (Anton, 6 Oct 2026).
// v2.5: alert text cut to the line only (Anton, 5 Oct 2026): "Sun bottom", "Asia top"; several lines touched by one
//       candle are joined with ", ". No pair, timeframe, price or time: TradingView's notification already shows the pair.
// v2.4: alerts rebuilt to Anton's spec (4 Oct 2026): any candle that touches, wicks through or crosses a line of a current
//       box (Asia box and two-day boxes), in either direction, every time. Timing option: candle close (default) or on
//       touch. Quiet hours: alerts are dropped (not delayed) between two times in your time zone. "Show outline" tick box
//       on the Asia box, so it can be shade-only.
// v2.3: optional shading for the Asia box (tick box + fill colour with opacity; default off = outline only).
// v2.2: Asia open time can be set (hour + minute, default 01:00) in "Your time zone"; the box is the hour from that time.
// v2.1: settings regrouped: all two-day box settings together, then all Asia box settings.
// v2.0: Asia box rebuilt to the agreed spec (Stuart and Anton, 4 Oct 2026): high/low of the first hour after the
//       Tokyo open (09:00 Tokyo = 00:00 UTC), outline only, colour and line thickness, grows until the next Asia open,
//       previous sessions 1-365, optional "Asia 1st H" text, time zone (UTC offsets in half-hour steps) for the times
//       shown, alerts on a candle close outside the box with side, price and time.
// v1.0-v1.9: two-day boxes and earlier Asia box experiments (backups beside this file).
// Each completed day gets a box spanning its high/low, starting at that day's open
// and extending 48 h forward. When a day closes, the oldest box is replaced by the new one.
// Opening box concept after "StraightKim - Opening Box" by R_Straight_kim (open source); independent implementation.
//@version=6
indicator("LDO-2day v2.6", overlay = true, max_boxes_count = 500)

// ── Inputs
G_BOX = "Two-day boxes"
G_OB  = "Asia first-hour box"
G_AL  = "Alerts (both box types)"
show2d    = input.bool(true, "Show two-day boxes", group = G_BOX, display = display.none)
extHours  = input.int(48, "Box length (hours)", minval = 1, maxval = 240, group = G_BOX, display = display.none)
colA      = input.color(color.new(#1B9E4B, 90), "Box A  fill", inline = "a", group = G_BOX, display = display.none)
bordA     = input.color(#1B9E4B,                 "line",       inline = "a", group = G_BOX, display = display.none)
colB      = input.color(color.new(#2962FF, 90), "Box B  fill", inline = "b", group = G_BOX, display = display.none)
bordB     = input.color(#2962FF,                 "line",       inline = "b", group = G_BOX, display = display.none)
showFill  = input.bool(true, "Shade box background", group = G_BOX, display = display.none)
lineWidth = input.int(1, "Line width", minval = 1, maxval = 5, group = G_BOX, display = display.none)
lineStyle = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = G_BOX, display = display.none)

showLabel = input.bool(true, "Show day labels", group = G_BOX, display = display.none)
labelCol  = input.color(color.new(#B2B5BE, 0), "Label colour", group = G_BOX, display = display.none)
labelSize = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = G_BOX, display = display.none)
al2d      = input.bool(true, "Alerts on two-day box lines", group = G_BOX, display = display.none)

showOB    = input.bool(true, "Show Asia box", group = G_OB,
     tooltip = "High and low of the first hour after the Asia open time below. The box grows until the next Asia open.", display = display.none)
obOutline = input.bool(true, "Outline", inline = "c", group = G_OB, tooltip = "Untick for no outline (use with 'Shade Asia box' for a shade-only box).", display = display.none)
obCol     = input.color(#00BCD4, "", inline = "c", group = G_OB, display = display.none)
obWidth   = input.int(1, "thickness", minval = 1, maxval = 5, inline = "c", group = G_OB, display = display.none)
obShade   = input.bool(false, "Shade Asia box", inline = "s", group = G_OB, tooltip = "Pick the colour and drag the opacity slider in the colour picker.", display = display.none)
obFill    = input.color(color.new(#00BCD4, 85), "", inline = "s", group = G_OB, display = display.none)
obText    = input.bool(true, "Show 'Asia 1st H' text in the box", group = G_OB, display = display.none)
obPrev    = input.bool(false, "Show previous sessions", inline = "p", group = G_OB, display = display.none)
obPrevN   = input.int(5, "how many", minval = 1, maxval = 365, inline = "p", group = G_OB, tooltip = "1 to 365. Older sessions only appear as far back as the chart has history loaded.", display = display.none)
obHour    = input.int(1, "Asia open time  hour", minval = 0, maxval = 23, inline = "t", group = G_OB,
     tooltip = "In your time zone below. Default 01:00 with UTC+1 = 09:00 Tokyo, the Tokyo open.", display = display.none)
obMin     = input.int(0, "minute", options = [0, 15, 30, 45], inline = "t", group = G_OB, display = display.none)
obTz      = input.string("UTC+1", "Your time zone", group = G_OB,
     options = ["UTC-12", "UTC-11:30", "UTC-11", "UTC-10:30", "UTC-10", "UTC-09:30", "UTC-9", "UTC-08:30", "UTC-8", "UTC-07:30",
                "UTC-7", "UTC-06:30", "UTC-6", "UTC-05:30", "UTC-5", "UTC-04:30", "UTC-4", "UTC-03:30", "UTC-3", "UTC-02:30",
                "UTC-2", "UTC-01:30", "UTC-1", "UTC-00:30", "UTC", "UTC+00:30", "UTC+1", "UTC+01:30", "UTC+2", "UTC+02:30",
                "UTC+3", "UTC+03:30", "UTC+4", "UTC+04:30", "UTC+5", "UTC+05:30", "UTC+6", "UTC+06:30", "UTC+7", "UTC+07:30",
                "UTC+8", "UTC+08:30", "UTC+9", "UTC+09:30", "UTC+10", "UTC+10:30", "UTC+11", "UTC+11:30", "UTC+12", "UTC+12:30",
                "UTC+13", "UTC+13:30", "UTC+14"],
     tooltip = "Used for the Asia open time above and the quiet hours. TradingView cannot read your computer's clock. UK: UTC+1 in summer, UTC in winter. A fixed offset does not change with the clocks: UTC+1 01:00 stays at 09:00 Tokyo all year.", display = display.none)
alOB      = input.bool(true, "Alerts on Asia box lines", group = G_OB, display = display.none)

alTiming  = input.string("Candle close", "Alert when", options = ["Candle close", "On touch"], group = G_AL,
     tooltip = "Create one alert on LDO-2day with condition 'Any alert() function call'. It fires when a candle touches, wicks through or crosses a line of a current box, from either side, every time.\nCandle close: one alert as each candle closes, listing every line it touched.\nOn touch: an alert the moment price reaches a line, at most once per line per candle.", display = display.none)
muteOn    = input.bool(false, "Mute alerts  from", inline = "m1", group = G_AL,
     tooltip = "Quiet hours in 'Your time zone' (Asia box settings). Touches during quiet hours are dropped, not sent later. With 'Candle close', a candle that overlaps the quiet hours at all is dropped.", display = display.none)
muteFH    = input.int(23, "", minval = 0, maxval = 23, inline = "m1", group = G_AL, display = display.none)
muteFM    = input.int(0, ":", options = [0, 15, 30, 45], inline = "m1", group = G_AL, display = display.none)
muteTH    = input.int(4, "to", minval = 0, maxval = 23, inline = "m2", group = G_AL, display = display.none)
muteTM    = input.int(0, ":", options = [0, 15, 30, 45], inline = "m2", group = G_AL, display = display.none)

lnStyle = lineStyle == "Dashed" ? line.style_dashed : lineStyle == "Dotted" ? line.style_dotted : line.style_solid
lbSize  = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : labelSize == "Large" ? size.large : size.small

// ── Two-day boxes (day boundary = the symbol's daily session; crypto = 00:00 UTC)
var float dHi    = na
var float dLo    = na
var int   dStart = na
var int   dCount = 0
var box   older  = na
var box   newer  = na

newDay = timeframe.change("1D")

// Day just closed: the oldest box makes way, the new one leap-frogs in front
if newDay and not na(dStart)
    box.delete(older)
    older := newer
    newer := na
    if show2d
        useA = dCount % 2 == 0
        newer := box.new(left = dStart, top = dHi, right = dStart + extHours * 3600000, bottom = dLo,
             xloc = xloc.bar_time, border_color = useA ? bordA : bordB, border_width = lineWidth, border_style = lnStyle,
             bgcolor = showFill ? (useA ? colA : colB) : color(na),
             text = showLabel ? str.format_time(dStart, "EEE dd MMM", syminfo.timezone) : "",
             text_color = labelCol, text_size = lbSize,
             text_halign = text.align_left, text_valign = text.align_bottom)
    dCount += 1

if newDay or na(dStart)
    dHi    := high
    dLo    := low
    dStart := time("1D")
else
    dHi := math.max(dHi, high)
    dLo := math.min(dLo, low)

// ── Asia first-hour box: high/low of the hour from the Asia open time (default 01:00 UTC+1 = 09:00 Tokyo).
// Computed on 15-minute bars (or the chart's own bars when they are shorter), so 1h and 4h charts get the
// true first-hour high/low rather than the high/low of whichever chart bar contains it.
firstHour() =>
    tod   = hour(time, obTz) * 60 + minute(time, obTz)
    inWin = (tod - (obHour * 60 + obMin) + 1440) % 1440 < 60
    var float hi = na
    var float lo = na
    var int   st = na
    if inWin and not inWin[1]
        hi := high
        lo := low
        st := time
    else if inWin
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    [hi, lo, st]

obCtx = timeframe.in_seconds() < 900 ? timeframe.period : "15"
[oHi, oLo, oSt] = request.security(syminfo.tickerid, obCtx, firstHour(), lookahead = barmerge.lookahead_off)
HOUR = 3600000

var box obBox   = na
var obBoxes = array.new<box>()

if showOB and not na(oSt)
    if oSt != nz(oSt[1])
        if not na(obBox)
            box.set_right(obBox, oSt)    // the previous box ends where the new Asia session opens
        obBox := box.new(left = oSt, top = oHi, right = oSt + HOUR, bottom = oLo,
             xloc = xloc.bar_time, border_color = obOutline ? obCol : color(na), border_width = obWidth,
             bgcolor = obShade ? obFill : color(na),
             text = obText ? "Asia 1st H" : "", text_color = obCol, text_size = size.small,
             text_halign = text.align_left, text_valign = text.align_top)
        obBoxes.push(obBox)
        keep = obPrev ? obPrevN : 0   // previous sessions kept besides the current one
        while obBoxes.size() > keep + 1
            box.delete(obBoxes.shift())
    else
        box.set_top(obBox, oHi)
        box.set_bottom(obBox, oLo)

    // The latest box grows with each candle until the next Asia open
    if time >= oSt + HOUR
        box.set_right(obBox, time_close)

// ── Alerts: a candle touches, wicks through or crosses a line of a current box, from either side, every time.
closeMode = alTiming == "Candle close"
prevC     = close[1]

// Lines of the boxes that are current on this candle
alNames  = array.new<string>()
alLevels = array.new<float>()
if al2d and show2d
    for b in array.from(newer, older)
        if not na(b) and time >= b.get_left() and time < b.get_right()
            nm = str.format_time(b.get_left(), "EEE", syminfo.timezone)   // the day on the box's own label
            alNames.push(nm + " top")
            alLevels.push(b.get_top())
            alNames.push(nm + " bottom")
            alLevels.push(b.get_bottom())
if alOB and showOB and not na(obBox) and not na(oSt) and time >= oSt + HOUR   // not while the first hour is still forming
    alNames.push("Asia top")
    alLevels.push(obBox.get_top())
    alNames.push("Asia bottom")
    alLevels.push(obBox.get_bottom())

// Quiet hours, in minutes of the day in the chosen time zone (to-time exclusive; wraps past midnight)
todOf(t) => hour(t, obTz) * 60 + minute(t, obTz)
fromM = muteFH * 60 + muteFM
toM   = muteTH * 60 + muteTM
inQuiet(m) => fromM < toM ? (m >= fromM and m < toM) : (m >= fromM or m < toM)
lenMin = (time_close - time) / 60000
quietBar  = inQuiet(todOf(time)) or (fromM - todOf(time) + 1440) % 1440 <= lenMin   // candle overlaps quiet hours
quietNow  = inQuiet(todOf(timenow))
quiet     = muteOn and fromM != toM and (closeMode ? quietBar : quietNow)

// Candle close: the candle's range (or a gap from the previous close) includes the line.
// On touch: price moved through or onto the line since the previous tick; once per line per candle.
varip float  lastPx = na
varip string fired  = ""
if barstate.isnew
    fired := ""

msg = ""
for [i, L] in alLevels
    nm  = alNames.get(i)
    hitBar  = (high >= L and low <= L) or (not na(prevC) and math.min(prevC, close) <= L and math.max(prevC, close) >= L)
    hitTick = not na(lastPx) and math.min(lastPx, close) <= L and math.max(lastPx, close) >= L
    hit     = closeMode ? hitBar : hitTick
    if hit and not quiet and not str.contains(fired, "|" + nm + "|")
        if not closeMode
            fired += "|" + nm + "|"
        msg += (msg == "" ? "" : ", ") + nm

if msg != ""
    alert(msg, closeMode ? alert.freq_once_per_bar_close : alert.freq_all)

lastPx := close

if barstate.islast and not timeframe.isintraday
    runtime.error("LDO-2day needs an intraday chart (e.g. 15m, 1h, 4h).")
````
