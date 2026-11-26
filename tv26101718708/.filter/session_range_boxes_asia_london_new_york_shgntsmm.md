# Session Range Boxes - Asia / London / New York

- url: https://www.tradingview.com/script/sHgNTSMM-Session-Range-Boxes-Asia-London-New-York/
- type: indicator
- pine_id: PUB;ab416ca35ee44f13878b7ed69a2c7f5d
- version: 1.0

## Description

OVERVIEW
This indicator draws the high-low range of the three main trading sessions (Asia, London, New York) as boxes on intraday charts. When a session ends, its high and low are projected forward as reference levels, the box is labelled with the session's range and with how that range compares to the same session's recent average, and optional signals mark the first confirmed close beyond a chosen session's range. It is built for instruments that trade around the clock, such as forex pairs, gold, oil and index CFDs.

WHAT MAKES IT DIFFERENT
- One time zone setting drives every session, and named time zones (for example America/New_York or Europe/London) adjust for daylight-saving time automatically, so the boxes stay on the correct hours throughout the year.
- Every completed range is compared with that session's own average over the last N sessions (for example "Asia 0.00412 | 64% of avg"). This shows at a glance whether a session was quiet or unusually wide compared with its normal behaviour.
- Breakout markers use only closed bars and only the range of a session that has already finished, so they never appear and then disappear.

HOW IT WORKS
- Each bar is tested against each session's hours with Pine's time() function, using the selected time zone. Sessions that cross midnight (for example 19:00-03:00) are supported.
- While a session is running, its box grows to the highest high and lowest low printed so far.
- When the session ends, the final high and low are stored. The range (high minus low) is compared with the average of the previous N completed ranges of the same session.
- If enabled, the completed high and low are extended to the right until the same session starts again.
- Previous-day high/low (optional) is taken from the prior completed daily bar of the symbol, so it stays fixed during the day.
- Breakout signal: outside the reference session, a bar that closes above the completed session high (or below the low) after closing at or inside it on the previous bar. Signals are evaluated only on confirmed bars. With "First breakout per side only", each side can trigger once until the reference session runs again.

HOW TO USE
1. Apply it to an intraday chart (1-hour or lower works best; 5-15 minutes gives the most precise boxes).
2. Choose the time zone you want to work in, then adjust the session hours if your preferred definitions differ from the defaults.
3. Use the completed Asian range as a reference during the London and New York sessions: note whether price is holding inside it or has closed beyond it.
4. Read the "% of avg" value: a very narrow session compared with its average often comes before range expansion, while a very wide session means a lot of the typical daily movement may already have happened. Treat this as context, not as a signal on its own.
5. Optionally create alerts with "Close above reference session high" / "Close below reference session low" (the conditions are already confirmed-bar based).

INPUTS
Time zone
- Session time zone: the zone used to read all session hours. "Exchange" uses the symbol's exchange time zone.
Sessions
- Asia / London / New York: show or hide each session, set its hours and set its color. Defaults (New York time): Asia 19:00-03:00, London 03:00-12:00, New York 08:00-17:00.
Boxes & levels
- Fill boxes / Transparency: box background on or off, and how transparent it is.
- Show session name and range: text inside each box, plus the range and % of average once the session completes.
- Average range lookback: how many previous sessions of the same type are averaged.
- Text size, Level line style.
- Extend completed session high/low: projects levels until that session starts again.
Previous day
- Show previous day high/low and its color.
Range breakout signals
- Reference session: Asia, London, New York or None. That session must be enabled.
- First breakout per side only: limits markers and alerts to the first close beyond each side.
- Show breakout markers and their colors.

NON-REPAINTING NOTES
- Session boxes update live while a session is in progress (that is the developing range), but a completed box and its stored high/low never change afterwards.
- Breakout markers and alerts require a closed bar.
- Previous-day levels are requested with the prior daily bar's values only (expression offset by one bar with lookahead enabled, the standard non-repainting form), so historical and real-time values match.

LIMITATIONS
- Intraday timeframes only. On higher timeframes a single bar can span several sessions, so session boundaries cannot be resolved accurately; the script shows a notice on daily and higher charts.
- Accuracy is limited by the chart timeframe: on a 1-hour chart a session starting at 08:30 is detected from the bar that opens at 09:00.
- Session times are definitions, not exchange facts. Brokers and data feeds differ in their trading hours and daily close, and symbols with gaps or thin data may show incomplete boxes.
- The range is shown in price units of the symbol. Pip and point conventions vary by instrument.
- Older boxes and lines are removed automatically when the drawing limits are reached.

This script is for educational and informational purposes only and is not financial advice. Trading CFDs and forex involves significant risk of loss.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cfdtools
//
// Session Range Boxes - Asia / London / New York
// Draws the high/low range of the Asian, London and New York sessions as boxes,
// extends each completed session's high/low as reference levels, compares every
// completed range with that session's own recent average range, and marks
// confirmed closes beyond the range of a chosen reference session.
// Sessions are evaluated in one user-selected time zone (DST-aware for named zones).

indicator("Session Range Boxes - Asia / London / New York", shorttitle = "Session Ranges", overlay = true, max_boxes_count = 300, max_lines_count = 300)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
GRP_TZ  = "Time zone"
GRP_SES = "Sessions (hours in the selected time zone)"
GRP_DSP = "Boxes & levels"
GRP_PD  = "Previous day"
GRP_BRK = "Range breakout signals"

tzInput = input.string("America/New_York", "Session time zone", options = ["America/New_York", "Europe/London", "UTC", "Asia/Tokyo", "Asia/Singapore", "Asia/Dubai", "Asia/Kolkata", "Australia/Sydney", "Europe/Berlin", "Exchange"], group = GRP_TZ, tooltip = "Time zone used to read all session hours below. Named zones (e.g. America/New_York) follow daylight-saving changes automatically. 'Exchange' uses the chart symbol's exchange time zone.")

showAs = input.bool(true, "Asia    ", inline = "as", group = GRP_SES)
sessAs = input.session("1900-0300", "", inline = "as", group = GRP_SES)
colAs  = input.color(#2962FF, "", inline = "as", group = GRP_SES, tooltip = "Asian session hours. The default 19:00-03:00 New York time covers the Tokyo morning and the hours before the London open. Sessions that cross midnight are supported.")

showLn = input.bool(true, "London  ", inline = "ln", group = GRP_SES)
sessLn = input.session("0300-1200", "", inline = "ln", group = GRP_SES)
colLn  = input.color(#FF9800, "", inline = "ln", group = GRP_SES, tooltip = "London session hours. The default 03:00-12:00 New York time is roughly 08:00-17:00 London time.")

showNy = input.bool(true, "New York", inline = "ny", group = GRP_SES)
sessNy = input.session("0800-1700", "", inline = "ny", group = GRP_SES)
colNy  = input.color(#9C27B0, "", inline = "ny", group = GRP_SES, tooltip = "New York session hours. The default 08:00-17:00 New York time ends at the conventional forex daily close.")

showFill   = input.bool(true, "Fill boxes", inline = "fill", group = GRP_DSP)
fillTransp = input.int(90, "Transparency", minval = 0, maxval = 100, inline = "fill", group = GRP_DSP, tooltip = "Background transparency of the session boxes (0 = solid, 100 = invisible).")
showText   = input.bool(true, "Show session name and range", group = GRP_DSP, tooltip = "Prints the session name inside each box. After a session completes, its range (high minus low, in price units) and that range as a percentage of the session's own recent average range are added.")
avgLen     = input.int(20, "Average range lookback (sessions)", minval = 1, maxval = 200, group = GRP_DSP, tooltip = "Number of previous completed sessions of the same type used to compute the average range. Example: 120% means the session was 20% wider than its recent average.")
txtSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GRP_DSP)
extendLv   = input.bool(true, "Extend completed session high/low", group = GRP_DSP, tooltip = "After a session ends, its high and low are projected to the right until the same session starts again.")
lvStyleIn  = input.string("Dashed", "Level line style", options = ["Solid", "Dashed", "Dotted"], group = GRP_DSP)

showPD = input.bool(false, "Show previous day high/low", inline = "pd", group = GRP_PD)
colPD  = input.color(color.gray, "", inline = "pd", group = GRP_PD, tooltip = "Previous completed daily bar high and low, as defined by the symbol's daily session. Values come from the prior daily bar only, so they do not change during the day.")

brkRef    = input.string("Asia", "Reference session", options = ["Asia", "London", "New York", "None"], group = GRP_BRK, tooltip = "Breakout signals compare the bar close with the high/low of the most recently completed session of this type. Signals are only evaluated outside that session and only on confirmed (closed) bars. The selected session must be enabled above.")
firstOnly = input.bool(true, "First breakout per side only", group = GRP_BRK, tooltip = "When enabled, only the first close above the high and the first close below the low are marked until the reference session runs again.")
showBrk   = input.bool(true, "Show breakout markers", inline = "bm", group = GRP_BRK)
colBUp    = input.color(#26A69A, "", inline = "bm", group = GRP_BRK)
colBDn    = input.color(#EF5350, "", inline = "bm", group = GRP_BRK)

// ─────────────────────────────────────────────────────────────────────────────
// Derived settings
// ─────────────────────────────────────────────────────────────────────────────
string sessTz = tzInput == "Exchange" ? syminfo.timezone : tzInput

string txtSize = switch txtSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

string lvStyle = switch lvStyleIn
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    => line.style_dashed

// ─────────────────────────────────────────────────────────────────────────────
// Session engine
// Each call keeps its own persistent state (var), so one function serves all
// three sessions. It must be called on every bar (it is, at global scope).
// Returns: [last completed high, last completed low, bar is in session]
// ─────────────────────────────────────────────────────────────────────────────
sessionRange(string sessHours, string tzone, string name, color col, bool show) =>
    bool inRaw   = not na(time(timeframe.period, sessHours + ":1234567", tzone))
    bool inS     = show and timeframe.isintraday and inRaw
    bool started = inS and not inS[1]
    bool ended   = inS[1] and not inS

    var float hi     = na
    var float lo     = na
    var float lastHi = na
    var float lastLo = na
    var box   bx     = na
    var line  hiLn   = na
    var line  loLn   = na
    var array<float> ranges = array.new<float>()

    if started
        hi := high
        lo := low
        bx := box.new(bar_index, high, bar_index, low, border_color = col, border_width = 1, bgcolor = showFill ? color.new(col, fillTransp) : color(na), text = showText ? name : "", text_size = txtSize, text_color = col, text_halign = text.align_left, text_valign = text.align_top)
    else if inS
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        if not na(bx)
            box.set_top(bx, hi)
            box.set_bottom(bx, lo)
            box.set_right(bx, bar_index)

    if ended and not na(hi) and not na(lo)
        lastHi := hi
        lastLo := lo
        float rng = hi - lo
        float avg = ranges.size() > 0 ? ranges.avg() : na
        ranges.push(rng)
        if ranges.size() > avgLen
            ranges.shift()
        if showText and not na(bx)
            string txt = name + "  " + str.tostring(rng, format.mintick)
            if not na(avg) and avg > 0
                txt += "  |  " + str.tostring(rng / avg * 100.0, "#") + "% of avg"
            box.set_text(bx, txt)
        if extendLv
            hiLn := line.new(bar_index, lastHi, bar_index, lastHi, color = col, style = lvStyle, width = 1)
            loLn := line.new(bar_index, lastLo, bar_index, lastLo, color = col, style = lvStyle, width = 1)
    else if not inS and extendLv and not na(hiLn) and not na(loLn)
        line.set_x2(hiLn, bar_index)
        line.set_x2(loLn, bar_index)

    [lastHi, lastLo, inS]

[asHi, asLo, asIn] = sessionRange(sessAs, sessTz, "Asia", colAs, showAs)
[lnHi, lnLo, lnIn] = sessionRange(sessLn, sessTz, "London", colLn, showLn)
[nyHi, nyLo, nyIn] = sessionRange(sessNy, sessTz, "New York", colNy, showNy)

// ─────────────────────────────────────────────────────────────────────────────
// Previous day high/low (non-repainting: prior daily bar values only)
// high[1]/low[1] with lookahead_on returns the last *completed* daily bar on
// both historical and realtime bars, which is the documented no-repaint form.
// ─────────────────────────────────────────────────────────────────────────────
[pdHi, pdLo] = request.security(syminfo.tickerid, "1D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
bool  pdShowNow = showPD and timeframe.isintraday
float pdHiPlot  = pdShowNow and pdHi == pdHi[1] ? pdHi : na
float pdLoPlot  = pdShowNow and pdLo == pdLo[1] ? pdLo : na
plot(pdHiPlot, "Previous day high", color = colPD, style = plot.style_linebr, linewidth = 1)
plot(pdLoPlot, "Previous day low", color = colPD, style = plot.style_linebr, linewidth = 1)

// ─────────────────────────────────────────────────────────────────────────────
// Range breakout signals (confirmed bars only)
// ─────────────────────────────────────────────────────────────────────────────
float refHi = switch brkRef
    "Asia"     => asHi
    "London"   => lnHi
    "New York" => nyHi
    => na

float refLo = switch brkRef
    "Asia"     => asLo
    "London"   => lnLo
    "New York" => nyLo
    => na

bool refIn = switch brkRef
    "Asia"     => asIn
    "London"   => lnIn
    "New York" => nyIn
    => false

var bool upDone = false
var bool dnDone = false
if refIn
    upDone := false
    dnDone := false

bool rawUp = barstate.isconfirmed and not refIn and not na(refHi) and close > refHi and close[1] <= refHi
bool rawDn = barstate.isconfirmed and not refIn and not na(refLo) and close < refLo and close[1] >= refLo
bool brkUp = rawUp and (not firstOnly or not upDone)
bool brkDn = rawDn and (not firstOnly or not dnDone)
if brkUp
    upDone := true
if brkDn
    dnDone := true

plotshape(showBrk and brkUp, "Breakout above reference high", shape.triangleup, location.belowbar, colBUp, size = size.small)
plotshape(showBrk and brkDn, "Breakout below reference low", shape.triangledown, location.abovebar, colBDn, size = size.small)

alertcondition(brkUp, "Close above reference session high", "{{ticker}}: confirmed close above the completed reference session high.")
alertcondition(brkDn, "Close below reference session low", "{{ticker}}: confirmed close below the completed reference session low.")

// ─────────────────────────────────────────────────────────────────────────────
// Timeframe notice
// ─────────────────────────────────────────────────────────────────────────────
var table notice = table.new(position.bottom_right, 1, 1)
if barstate.islast and not timeframe.isintraday
    table.cell(notice, 0, 0, "Session Ranges: switch to an intraday timeframe (1H or lower recommended).", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
````
