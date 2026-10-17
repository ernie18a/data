# 2 AM 4H Candle Levels

- url: https://www.tradingview.com/script/MG4syeRS-2-AM-4H-Candle-Levels/
- type: indicator
- pine_id: PUB;5c35022849a4487f92349b27176aa3df
- version: 1.0

## Description

**2 AM 4H Candle Levels**

This indicator marks the high and low of the 4-hour candle that opens at 2:00 AM and projects those levels forward through the rest of the trading day — for every historical day on the chart as well as the current session.

Many intraday strategies treat the early-morning 4H range (2 AM – 6 AM) as a key reference: it often brackets the pre-session liquidity that price later sweeps or respects once the more active hours begin. This tool makes that range visible at a glance so you can watch how price interacts with it — breakouts, retests, or rejections — without redrawing levels every day.

**What it draws**

- **Window box** — a box spanning the full 4H window, from the 2 AM open to the 6 AM close, framed at the candle's high and low. The left and right borders mark the open and close times; the top and bottom borders trace the range. Optional fill with adjustable transparency.
- **Extended level lines** — from the 6 AM close, a high line and a low line carry the range forward. You choose where they stop: **End of day**, or a **Custom time** you set (e.g. 9:30 AM for the NYSE open).
- On the **current day**, the box builds in real time while the 2 AM candle is still forming, and the lines can optionally extend to the right edge of the chart until their cutoff arrives.

**Settings**

- **4H candle open hour** — defaults to 2 AM; anchor the window to any hour.
- **Timezone** — "Exchange" by default; set it to match your chart's displayed timezone (UTC, America/New_York, GMT+2, …) so the window lands on the candle you see.
- **Lines end at** — End of day, or a custom hour/minute (24-hour clock).
- **Window box** — show/hide, border color, width, style (solid/dashed/dotted), and fill color.
- **Extended lines** — independent colors for the high and low lines, width, and style.

**How it works**

The script does not rely on `request.security`. It identifies all chart bars whose open time falls inside the 4-hour window (in your chosen timezone) and accumulates their high and low directly. This keeps the levels accurate and non-repainting on any intraday timeframe — from 1 minute up to 4 hours — and means the levels appear at the window itself rather than four hours late, a common artifact of higher-timeframe data requests.

**Notes & limitations**

- Works on intraday timeframes up to 4H. On Daily and above a whole day is a single bar, so there is nothing to draw; the indicator shows a small notice instead.
- If the levels don't line up with the candle you expect, the timezone setting is almost always the reason — match it to the clock at the bottom-right of your chart.
- TradingView caps drawing objects per indicator, so history reaches back roughly 250 trading days.

---

## Source Code

````pine
//@version=6
indicator("2 AM 4H Candle Levels", overlay = true, max_lines_count = 500, max_boxes_count = 500)

// ─── Settings ─────────────────────────────────────────────────────────────────
grp = "Settings"
start_hour  = input.int(2, "4H candle open hour", minval = 0, maxval = 23, group = grp)
tz_input    = input.string("Exchange", "Timezone", group = grp,
     tooltip = "Set this to match the timezone your chart is displayed in (bottom-right of TradingView). \"Exchange\" = the symbol's exchange timezone. You can also type UTC, America/New_York, GMT+2, etc.")
extend_live = input.bool(true, "Extend current day's lines to right edge", group = grp)
end_mode    = input.string("End of day", "Lines end at", options = ["End of day", "Custom time"], group = grp)
end_hour    = input.int(9,  "Custom end hour",   minval = 0, maxval = 23, group = grp,
     tooltip = "Only used when \"Lines end at\" is set to Custom time. 24-hour clock — 9:30 AM = hour 9, minute 30; 3:00 PM = hour 15.")
end_minute  = input.int(30, "Custom end minute", minval = 0, maxval = 59, group = grp)

grpB = "Window Box (2 AM – 6 AM)"
show_box     = input.bool(true, "Show window box", group = grpB)
box_border   = input.color(color.orange, "Border color", group = grpB)
box_fill     = input.color(color.new(color.orange, 90), "Fill color", group = grpB,
     tooltip = "Use the color picker's opacity slider; set it fully transparent for an outline-only box.")
box_width    = input.int(1, "Border width", minval = 1, maxval = 4, group = grpB)
box_style_in = input.string("Solid", "Border style", options = ["Solid", "Dashed", "Dotted"], group = grpB)

grpS = "Extended Lines (6 AM – end of day)"
high_color = input.color(color.green, "High line color", group = grpS)
low_color  = input.color(color.red,   "Low line color",  group = grpS)
line_width = input.int(1, "Line width", minval = 1, maxval = 4, group = grpS)
style_str  = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpS)

lineStyle = style_str == "Dashed" ? line.style_dashed :
     style_str == "Dotted" ? line.style_dotted : line.style_solid

boxStyle = box_style_in == "Dashed" ? line.style_dashed :
     box_style_in == "Dotted" ? line.style_dotted : line.style_solid

// ─── Time window detection (no request.security — works on any intraday TF) ──
tz = tz_input == "Exchange" ? syminfo.timezone : tz_input

h      = hour(time, tz)
dayId  = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
newDay = na(dayId[1]) or dayId != dayId[1]

endHour  = start_hour + 4
inWindow = endHour <= 24 ? (h >= start_hour and h < endHour) : (h >= start_hour or h < endHour - 24)

// ─── State ────────────────────────────────────────────────────────────────────
var box   winBox    = na   // spans the 4H window: open → close, high → low
var line  hiLine    = na   // extended lines: 6 AM → end of day (or custom time)
var line  loLine    = na
var float winHi     = na
var float winLo     = na
var bool  linesDone = false   // true once today's lines were capped at the custom time

// ─── New day: freeze yesterday's lines at yesterday's last bar ───────────────
if newDay
    if not na(hiLine) and not linesDone
        line.set_extend(hiLine, extend.none)
        line.set_extend(loLine, extend.none)
        line.set_x2(hiLine, bar_index - 1)
        line.set_x2(loLine, bar_index - 1)
    winBox    := na
    hiLine    := na
    loLine    := na
    winHi     := na
    winLo     := na
    linesDone := false

// ─── Inside the window: build the candle's high/low, grow the box ────────────
if inWindow
    if na(winHi)
        winHi := high
        winLo := low
        if show_box
            winBox := box.new(bar_index, winHi, bar_index, winLo,
                 border_color = box_border, border_width = box_width,
                 border_style = boxStyle, bgcolor = box_fill)
    else
        winHi := math.max(winHi, high)
        winLo := math.min(winLo, low)
        if not na(winBox)
            box.set_top(winBox, winHi)
            box.set_bottom(winBox, winLo)
    if not na(winBox)
        box.set_right(winBox, bar_index)

// ─── Window just closed: cap the box at 6 AM, start the extended lines ───────
if not inWindow and not na(winHi) and na(hiLine)
    if not na(winBox)
        box.set_right(winBox, bar_index)
    hiLine := line.new(bar_index, winHi, bar_index, winHi,
         color = high_color, width = line_width, style = lineStyle,
         extend = extend_live ? extend.right : extend.none)
    loLine := line.new(bar_index, winLo, bar_index, winLo,
         color = low_color, width = line_width, style = lineStyle,
         extend = extend_live ? extend.right : extend.none)

// ─── Custom end time: cap the lines once the cutoff is reached ───────────────
minuteOfDay = h * 60 + minute(time, tz)
cutoff      = end_hour * 60 + end_minute
if end_mode == "Custom time" and not na(hiLine) and not linesDone and minuteOfDay >= cutoff
    line.set_extend(hiLine, extend.none)
    line.set_extend(loLine, extend.none)
    line.set_x2(hiLine, bar_index)
    line.set_x2(loLine, bar_index)
    linesDone := true

// ─── Stretch today's lines to the latest bar (until the day rolls over) ──────
if not na(hiLine) and not linesDone
    line.set_x2(hiLine, bar_index)
    line.set_x2(loLine, bar_index)

// ─── Warn on timeframes above 4H, where an intraday line can't be drawn ──────
if barstate.islast and timeframe.in_seconds() > 240 * 60
    var table warn = table.new(position.top_center, 1, 1)
    table.cell(warn, 0, 0, "2 AM 4H Levels: switch to a 4H or lower timeframe",
         text_color = color.white, bgcolor = color.new(color.red, 15))
````
