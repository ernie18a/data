# FX Session Highlighter

- url: https://www.tradingview.com/script/6AHLYSdW/
- type: indicator
- pine_id: PUB;66fa8c0c6f694252abce7f48f42f15c6
- version: 1.0

## Description

This indicator highlights the Tokyo, London and New York trading sessions on intraday charts, so you can see at a glance which market is active and how price behaves inside each session.

How it works

Each session is defined by a time range interpreted in its own local timezone (Asia/Tokyo, Europe/London, America/New_York). Because the timezone is attached to each session, daylight-saving shifts are handled automatically — you do not need to adjust the times twice a year.

Features


Background highlight per session (colors and time ranges are fully configurable, each session can be toggled individually)
Optional session high/low tracking, drawn as lines while the session is active
Alert conditions for the open of each session


Notes and limitations

The indicator works on intraday timeframes only; on daily and higher timeframes nothing is drawn. Default time ranges reflect commonly used market hours, but "session" definitions vary between traders — adjust the ranges to match your own approach. This is a visualization tool and implies nothing about future price movement.

## Source Code

````pine
//@version=6
// ============================================================
//  FX Session Highlighter
//  Highlights Tokyo / London / New York sessions on intraday
//  charts, with optional session high/low tracking and
//  session-open alerts.
// ============================================================
indicator("FX Session Highlighter", overlay = true)

// ---------- Inputs ----------
grpS = "Sessions"
showTok = input.bool(true, "Tokyo",    group = grpS, inline = "tok")
tokSess = input.session("0900-1500", "", group = grpS, inline = "tok")
tokCol  = input.color(color.new(#ef5350, 88), "", group = grpS, inline = "tok")

showLon = input.bool(true, "London",   group = grpS, inline = "lon")
lonSess = input.session("0800-1630", "", group = grpS, inline = "lon")
lonCol  = input.color(color.new(#2962ff, 88), "", group = grpS, inline = "lon")

showNy  = input.bool(true, "New York", group = grpS, inline = "ny")
nySess  = input.session("0930-1600", "", group = grpS, inline = "ny")
nyCol   = input.color(color.new(#26a69a, 88), "", group = grpS, inline = "ny")

grpHl = "Session High/Low"
showHL  = input.bool(true, "Track session high/low", group = grpHl)
hlWidth = input.int(1, "Line width", minval = 1, maxval = 3, group = grpHl)

// Each session uses its own local timezone, so DST shifts are handled
// automatically. Session times are interpreted in that timezone.
tzTok = "Asia/Tokyo"
tzLon = "Europe/London"
tzNy  = "America/New_York"

// ---------- Session detection ----------
f_inSession(simple string sess, simple string tz) =>
    not na(time(timeframe.period, sess, tz))

inTok = showTok and timeframe.isintraday and f_inSession(tokSess, tzTok)
inLon = showLon and timeframe.isintraday and f_inSession(lonSess, tzLon)
inNy  = showNy  and timeframe.isintraday and f_inSession(nySess,  tzNy)

// ---------- Background ----------
bgcolor(inTok ? tokCol : na, title = "Tokyo session")
bgcolor(inLon ? lonCol : na, title = "London session")
bgcolor(inNy  ? nyCol  : na, title = "New York session")

// ---------- Session high/low tracking ----------
f_track(bool inS) =>
    var float hi = na
    var float lo = na
    if inS and not inS[1]
        hi := high
        lo := low
    else if inS
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    [inS ? hi : na, inS ? lo : na]

[tokHi, tokLo] = f_track(inTok)
[lonHi, lonLo] = f_track(inLon)
[nyHi,  nyLo]  = f_track(inNy)

plot(showHL ? tokHi : na, "Tokyo high",    color.new(#ef5350, 30), hlWidth, plot.style_linebr)
plot(showHL ? tokLo : na, "Tokyo low",     color.new(#ef5350, 30), hlWidth, plot.style_linebr)
plot(showHL ? lonHi : na, "London high",   color.new(#2962ff, 30), hlWidth, plot.style_linebr)
plot(showHL ? lonLo : na, "London low",    color.new(#2962ff, 30), hlWidth, plot.style_linebr)
plot(showHL ? nyHi  : na, "New York high", color.new(#26a69a, 30), hlWidth, plot.style_linebr)
plot(showHL ? nyLo  : na, "New York low",  color.new(#26a69a, 30), hlWidth, plot.style_linebr)

// ---------- Alerts ----------
alertcondition(inTok and not inTok[1], "Tokyo open",    "FX Session Highlighter: Tokyo session opened")
alertcondition(inLon and not inLon[1], "London open",   "FX Session Highlighter: London session opened")
alertcondition(inNy  and not inNy[1],  "New York open", "FX Session Highlighter: New York session opened")
````
