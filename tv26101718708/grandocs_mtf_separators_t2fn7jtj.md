# Grandoc's MTF Separators

- url: https://www.tradingview.com/script/t2FN7jtJ-Grandoc-s-MTF-Separators/
- type: indicator
- pine_id: PUB;81a7daf58f6f46b5af3b55874ff17b3e
- version: 3.0

## Description

[b]What it is[/b]
This indicator draws vertical lines at the day, week, month and year opens, plus the open and close of the five main forex sessions: Sydney, Tokyo, Frankfurt, London and New York. It can also box each session's high and low, and the last 30 minutes before each session closes (the "closing range").

[b]What is different about it[/b]
Most period separators use the exchange's day, or one fixed time zone for every session. Then the lines move by an hour whenever a country changes its clocks, and you have to go back into the settings to fix them. This script works differently:
[list]
[*]The trading day starts at 09:00 Sydney time. This is the day roll used here, and the hour can be changed. The week, month and year also start at a Sydney open. The week starts on the Sunday evening (European/African time) Sydney open, the first open of the forex week.
[*]Each session is read on its own city clock: Sydney (Australia/Sydney), Tokyo (Asia/Tokyo), Frankfurt (Europe/Berlin), London (Europe/London) and New York (America/New_York). Each city changes for daylight saving on its own date, so the lines move on the right day without any input from you. For example, in late October London's open moves from 08:00 to 09:00 on a Lagos clock, while it stays at 08:00 on a London clock.
[*]The lines use the real moment in time, so they land in the right place whatever time zone the chart is set to. Changing the chart's time zone, or the season, gives nothing to readjust.
[/list]

[b]How it works[/b]
[list]
[*]Period opens: on each candle the script finds the 09:00 Sydney open of that Sydney date and decides which Sydney trading day the candle belongs to. A line is drawn on the first candle at or after a new open. A new week is a new Sydney Monday. A new month or year is the first Sydney open in that month or year. Broker candles that print before 09:00 Sydney on Monday morning do not create a false open. When several periods open on the same candle, only the biggest one is drawn (Year, then Month, Week, Day), so lines do not stack.
[*]Sessions: each session's hours are checked on its own city clock, Monday to Friday in that city. An open line goes on the first candle inside the session. A close line goes at the end of the last candle inside it.
[*]Session box: starts at the session open, grows candle by candle while the session runs, and shows the session's highest and lowest price.
[*]Closing range: the same idea for a short window you choose, by default the last 30 minutes before each session closes. The box shows the high and low traded in that window.
[*]Written in Pine Script v6. The script uses only the chart's own candles. It requests no other data and has no lookahead. Lines and boxes on past candles do not change. Only the box of a session that is still running keeps growing until that session ends.
[/list]

[b]How to use it[/b]
Add it to an intraday chart (1 to 60 minutes works best for sessions). Use the day, week, month and year lines to see where each period starts. Use the session lines to see which market is open. Turn on the session boxes or closing ranges when you want the high and low of a session or of its final minutes as reference levels. Each session has its own master switch, so you can show only the sessions you follow.

[b]Settings[/b]
[list]
[*][b]General[/b]: Day open hour and minute on the Sydney clock (default 09:00). "Hide session lines/boxes/closing ranges above" a chart timeframe in minutes (default 60). "Sessions to keep" sets how many past sessions keep their drawings (default 20).
[*][b]Day / Week / Month / Year open[/b]: show, colour, width, style (solid, dashed, dotted) and lookback (how many past lines to keep). Defaults: Day white dotted 1, Week green dashed 2, Month red solid 3, Year purple solid 3. The solid lines default to 60% transparency.
[*][b]Each session (Sydney, Tokyo, Frankfurt, London, New York)[/b]:
- Show (master switch for everything in that session)
- Hours in that city's local time. Defaults: Sydney 09:00-18:00, Tokyo 09:00-18:00, Frankfurt 08:00-17:00, London 08:00-17:00, New York 08:00-17:00.
- City time zone (leave as is so daylight saving is automatic)
- Line colour
- Open line: on/off, width, style
- Close line: on/off, width, style
- Session box: on/off, colour, fill transparency, border width
- Closing range: on/off, window in local time (default last 30 minutes, e.g. 16:30-17:00 for London), colour, fill transparency, border width
[/list]

[b]Limitations[/b]
[list]
[*]Session lines, session boxes and closing ranges are hidden on charts above 60 minutes by default. On bigger candles a session or a 30-minute window cannot be drawn accurately. You can raise this limit, but the results will be rough.
[*]Lines can only sit on a candle. On higher intraday timeframes such as 4 hours, the day open lands on the first candle that starts at or after 09:00 Sydney, which can be up to a few hours after the true open.
[*]On daily and higher charts the day line is not drawn, and week, month and year opens are judged by each candle's close time.
[*]TradingView allows at most 500 lines and 500 boxes per script. Lookback and "Sessions to keep" values are capped so the drawings stay within this.
[*]Sessions run Monday to Friday. Public holidays and early closes are not handled separately. If a market has no candles at an open time, the line goes on the next candle.
[*]The Sydney session open falls on the same candle as the day open. Turn off the Sydney open line if you only want one line there.
[*]This is a visual time reference. It gives no buy or sell signals and makes no prediction.
[/list]

[b]Credits[/b]
This script started from sbtnc's open-source "Multi-Timeframe Period Separators" (Mozilla Public License 2.0). Thanks to sbtnc for the original. It was rewritten and extended: the opens are anchored to the Sydney open with a Sunday-evening week, each of the five sessions follows its own city clock with automatic daylight saving, each session has its own line settings and master switch, and session high/low boxes and editable closing-range boxes were added. Published open-source under the same license. 

This indicator is built with HORC(Hendray's Open Range Concept) traders in Mind

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sbtnc - original "Multi-Timeframe Period Separators"
// Modified by Grandoc - "Grandoc's MTF Separators", version 2.4.1 (preview image refresh, no behaviour change)
//
// Changes from the original:
// - Day / Week / Month / Year opens anchored to 23:00 London (Europe/London clock, follows London's DST only):
//     London summer time (BST): 22:00 UTC = 23:00 Lagos = 07:00 Japan
//     London winter time (GMT): 23:00 UTC = 00:00 Lagos = 08:00 Japan
// - Week = Sunday-evening forex week open (the 23:00 London open on Sunday starts Monday's trading day)
// - Five sessions (Sydney, Tokyo, Frankfurt, London, New York), each read on its own city clock (DST automatic)
// - Per-session open/close lines, optional session high/low boxes and editable closing-range boxes

//@version=6
indicator("Grandoc's MTF Separators", "Grandoc's MTF Separators", overlay = true, max_lines_count = 500, max_boxes_count = 500)

//#region Constants & helpers
string OPEN_TZ = "Europe/London"   // clock for the day / week / month / year opens
int    DAY_MS  = 86400000
string WEEKDAYS = ":23456"   // Mon-Fri in the session's own city clock (1 = Sunday ... 7 = Saturday)

f_style(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_vline(int t, color c, int w, string s, array<line> arr, int keep) =>
    if keep > 0
        arr.push(line.new(t, high, t, low, xloc.bar_time, extend.both, c, f_style(s), w))
        while arr.size() > keep
            arr.shift().delete()

// UTC day number (days since 1970-01-01) of a calendar date
f_dayNum(int y, int m, int d) =>
    int(math.floor(timestamp("UTC", y, m, d, 0, 0, 0) / DAY_MS))

f_trimBoxes(array<box> arr, int keep) =>
    while arr.size() > keep
        arr.shift().delete()
//#endregion

//#region Inputs - general
string G0 = "General"
int i_dayHour  = input.int(23, "Day open hour (London time)", 0, 23, group = G0, tooltip = "The trading day, week, month and year all start at this hour on the London clock (default 23:00). It follows London's daylight saving only: during London summer time 23:00 London = 22:00 UTC = 23:00 Lagos; during London winter time 23:00 London = 23:00 UTC = 00:00 Lagos. It switches by itself on London's change dates, whatever the chart's time zone. An evening hour (12:00 or later) opens the next day's trading day.")
int i_dayMin   = input.int(0, "Day open minute (London time)", 0, 59, group = G0)
int i_maxTF    = input.int(60, "Hide session lines/boxes/closing ranges above (minutes)", 1, 1440, group = G0, tooltip = "On bigger candles a session or a 30-minute window cannot be drawn accurately.")
int i_keepDays = input.int(20, "Sessions to keep (per session)", 1, 45, group = G0, tooltip = "How many past sessions keep their lines / boxes / closing ranges.")
//#endregion

//#region Inputs - period opens
string GD = "Day open"
bool   i_showD  = input.bool(true, "Show", inline = "Da", group = GD)
color  i_colD   = input.color(color.white, "", inline = "Da", group = GD)
int    i_wD     = input.int(1, "Width", 1, 10, inline = "Da", group = GD)
string i_stD    = input.string("Dotted", "Style", ["Solid", "Dashed", "Dotted"], inline = "Db", group = GD)
int    i_lbD    = input.int(30, "Lookback", 0, 200, inline = "Db", group = GD)
string GW = "Week open"
bool   i_showW  = input.bool(true, "Show", inline = "Wa", group = GW)
color  i_colW   = input.color(color.green, "", inline = "Wa", group = GW)
int    i_wW     = input.int(2, "Width", 1, 10, inline = "Wa", group = GW)
string i_stW    = input.string("Dashed", "Style", ["Solid", "Dashed", "Dotted"], inline = "Wb", group = GW)
int    i_lbW    = input.int(12, "Lookback", 0, 200, inline = "Wb", group = GW)
string GM = "Month open"
bool   i_showM  = input.bool(true, "Show", inline = "Ma", group = GM)
color  i_colM   = input.color(color.new(#FF5252, 60), "", inline = "Ma", group = GM)
int    i_wM     = input.int(3, "Width", 1, 10, inline = "Ma", group = GM)
string i_stM    = input.string("Solid", "Style", ["Solid", "Dashed", "Dotted"], inline = "Mb", group = GM)
int    i_lbM    = input.int(12, "Lookback", 0, 200, inline = "Mb", group = GM)
string GY = "Year open"
bool   i_showY  = input.bool(true, "Show", inline = "Ya", group = GY)
color  i_colY   = input.color(color.new(color.purple, 60), "", inline = "Ya", group = GY)
int    i_wY     = input.int(3, "Width", 1, 10, inline = "Ya", group = GY)
string i_stY    = input.string("Solid", "Style", ["Solid", "Dashed", "Dotted"], inline = "Yb", group = GY)
int    i_lbY    = input.int(5, "Lookback", 0, 200, inline = "Yb", group = GY)
//#endregion

//#region Inputs - sessions
string G_syd = "Sydney session"
bool   i_sydShow  = input.bool(true, "Show Sydney", group = G_syd, tooltip = "Master switch: untick to hide everything for this session (open, close, box, closing range).")
string i_sydSess  = input.session("0900-1800", "Hours (local Sydney time)", group = G_syd)
string i_sydTz    = input.string("Australia/Sydney", "City time zone", group = G_syd, tooltip = "Leave as is: hours above are read on this clock so daylight saving adjusts by itself.")
color  i_sydCol   = input.color(color.new(#2e9d5b, 0), "Line colour", group = G_syd)
bool   i_sydOpen  = input.bool(true, "Open line", inline = "sydo", group = G_syd)
int    i_sydOW    = input.int(1, "W", 1, 10, inline = "sydo", group = G_syd)
string i_sydOS    = input.string("Dashed", "", ["Solid", "Dashed", "Dotted"], inline = "sydo", group = G_syd)
bool   i_sydClose = input.bool(false, "Close line", inline = "sydc", group = G_syd)
int    i_sydCW    = input.int(1, "W", 1, 10, inline = "sydc", group = G_syd)
string i_sydCS    = input.string("Dotted", "", ["Solid", "Dashed", "Dotted"], inline = "sydc", group = G_syd)
bool   i_sydBox   = input.bool(false, "Session box", inline = "sydb", group = G_syd)
color  i_sydBCol  = input.color(color.new(#2e9d5b, 0), "", inline = "sydb", group = G_syd)
int    i_sydBTr   = input.int(90, "Fill transp.", 0, 100, inline = "sydb", group = G_syd)
int    i_sydBBw   = input.int(1, "Border", 0, 5, inline = "sydb", group = G_syd)
bool   i_sydCR    = input.bool(true, "Closing range", inline = "sydr", group = G_syd)
string i_sydCRS   = input.session("1730-1800", "", inline = "sydr", group = G_syd, tooltip = "Window in local Sydney time. Box marks the high and low inside it.")
color  i_sydCRCol = input.color(color.new(#2e9d5b, 0), "", inline = "sydr2", group = G_syd)
int    i_sydCRTr  = input.int(80, "Fill transp.", 0, 100, inline = "sydr2", group = G_syd)
int    i_sydCRBw  = input.int(1, "Border", 0, 5, inline = "sydr2", group = G_syd)
string G_tyo = "Tokyo session"
bool   i_tyoShow  = input.bool(true, "Show Tokyo", group = G_tyo, tooltip = "Master switch: untick to hide everything for this session (open, close, box, closing range).")
string i_tyoSess  = input.session("0900-1800", "Hours (local Tokyo time)", group = G_tyo)
string i_tyoTz    = input.string("Asia/Tokyo", "City time zone", group = G_tyo, tooltip = "Leave as is: hours above are read on this clock so daylight saving adjusts by itself.")
color  i_tyoCol   = input.color(color.new(#d9822b, 0), "Line colour", group = G_tyo)
bool   i_tyoOpen  = input.bool(true, "Open line", inline = "tyoo", group = G_tyo)
int    i_tyoOW    = input.int(1, "W", 1, 10, inline = "tyoo", group = G_tyo)
string i_tyoOS    = input.string("Dashed", "", ["Solid", "Dashed", "Dotted"], inline = "tyoo", group = G_tyo)
bool   i_tyoClose = input.bool(false, "Close line", inline = "tyoc", group = G_tyo)
int    i_tyoCW    = input.int(1, "W", 1, 10, inline = "tyoc", group = G_tyo)
string i_tyoCS    = input.string("Dotted", "", ["Solid", "Dashed", "Dotted"], inline = "tyoc", group = G_tyo)
bool   i_tyoBox   = input.bool(false, "Session box", inline = "tyob", group = G_tyo)
color  i_tyoBCol  = input.color(color.new(#d9822b, 0), "", inline = "tyob", group = G_tyo)
int    i_tyoBTr   = input.int(90, "Fill transp.", 0, 100, inline = "tyob", group = G_tyo)
int    i_tyoBBw   = input.int(1, "Border", 0, 5, inline = "tyob", group = G_tyo)
bool   i_tyoCR    = input.bool(true, "Closing range", inline = "tyor", group = G_tyo)
string i_tyoCRS   = input.session("1730-1800", "", inline = "tyor", group = G_tyo, tooltip = "Window in local Tokyo time. Box marks the high and low inside it.")
color  i_tyoCRCol = input.color(color.new(#d9822b, 0), "", inline = "tyor2", group = G_tyo)
int    i_tyoCRTr  = input.int(80, "Fill transp.", 0, 100, inline = "tyor2", group = G_tyo)
int    i_tyoCRBw  = input.int(1, "Border", 0, 5, inline = "tyor2", group = G_tyo)
string G_fra = "Frankfurt session"
bool   i_fraShow  = input.bool(true, "Show Frankfurt", group = G_fra, tooltip = "Master switch: untick to hide everything for this session (open, close, box, closing range).")
string i_fraSess  = input.session("0800-1700", "Hours (local Frankfurt time)", group = G_fra)
string i_fraTz    = input.string("Europe/Berlin", "City time zone", group = G_fra, tooltip = "Leave as is: hours above are read on this clock so daylight saving adjusts by itself.")
color  i_fraCol   = input.color(color.new(#8e44ad, 0), "Line colour", group = G_fra)
bool   i_fraOpen  = input.bool(true, "Open line", inline = "frao", group = G_fra)
int    i_fraOW    = input.int(1, "W", 1, 10, inline = "frao", group = G_fra)
string i_fraOS    = input.string("Dashed", "", ["Solid", "Dashed", "Dotted"], inline = "frao", group = G_fra)
bool   i_fraClose = input.bool(false, "Close line", inline = "frac", group = G_fra)
int    i_fraCW    = input.int(1, "W", 1, 10, inline = "frac", group = G_fra)
string i_fraCS    = input.string("Dotted", "", ["Solid", "Dashed", "Dotted"], inline = "frac", group = G_fra)
bool   i_fraBox   = input.bool(false, "Session box", inline = "frab", group = G_fra)
color  i_fraBCol  = input.color(color.new(#8e44ad, 0), "", inline = "frab", group = G_fra)
int    i_fraBTr   = input.int(90, "Fill transp.", 0, 100, inline = "frab", group = G_fra)
int    i_fraBBw   = input.int(1, "Border", 0, 5, inline = "frab", group = G_fra)
bool   i_fraCR    = input.bool(true, "Closing range", inline = "frar", group = G_fra)
string i_fraCRS   = input.session("1630-1700", "", inline = "frar", group = G_fra, tooltip = "Window in local Frankfurt time. Box marks the high and low inside it.")
color  i_fraCRCol = input.color(color.new(#8e44ad, 0), "", inline = "frar2", group = G_fra)
int    i_fraCRTr  = input.int(80, "Fill transp.", 0, 100, inline = "frar2", group = G_fra)
int    i_fraCRBw  = input.int(1, "Border", 0, 5, inline = "frar2", group = G_fra)
string G_lon = "London session"
bool   i_lonShow  = input.bool(true, "Show London", group = G_lon, tooltip = "Master switch: untick to hide everything for this session (open, close, box, closing range).")
string i_lonSess  = input.session("0800-1700", "Hours (local London time)", group = G_lon)
string i_lonTz    = input.string("Europe/London", "City time zone", group = G_lon, tooltip = "Leave as is: hours above are read on this clock so daylight saving adjusts by itself.")
color  i_lonCol   = input.color(color.new(#1f6fd1, 0), "Line colour", group = G_lon)
bool   i_lonOpen  = input.bool(true, "Open line", inline = "lono", group = G_lon)
int    i_lonOW    = input.int(1, "W", 1, 10, inline = "lono", group = G_lon)
string i_lonOS    = input.string("Dashed", "", ["Solid", "Dashed", "Dotted"], inline = "lono", group = G_lon)
bool   i_lonClose = input.bool(false, "Close line", inline = "lonc", group = G_lon)
int    i_lonCW    = input.int(1, "W", 1, 10, inline = "lonc", group = G_lon)
string i_lonCS    = input.string("Dotted", "", ["Solid", "Dashed", "Dotted"], inline = "lonc", group = G_lon)
bool   i_lonBox   = input.bool(false, "Session box", inline = "lonb", group = G_lon)
color  i_lonBCol  = input.color(color.new(#1f6fd1, 0), "", inline = "lonb", group = G_lon)
int    i_lonBTr   = input.int(90, "Fill transp.", 0, 100, inline = "lonb", group = G_lon)
int    i_lonBBw   = input.int(1, "Border", 0, 5, inline = "lonb", group = G_lon)
bool   i_lonCR    = input.bool(true, "Closing range", inline = "lonr", group = G_lon)
string i_lonCRS   = input.session("1630-1700", "", inline = "lonr", group = G_lon, tooltip = "Window in local London time. Box marks the high and low inside it.")
color  i_lonCRCol = input.color(color.new(#1f6fd1, 0), "", inline = "lonr2", group = G_lon)
int    i_lonCRTr  = input.int(80, "Fill transp.", 0, 100, inline = "lonr2", group = G_lon)
int    i_lonCRBw  = input.int(1, "Border", 0, 5, inline = "lonr2", group = G_lon)
string G_ny = "New York session"
bool   i_nyShow  = input.bool(true, "Show New York", group = G_ny, tooltip = "Master switch: untick to hide everything for this session (open, close, box, closing range).")
string i_nySess  = input.session("0800-1700", "Hours (local New York time)", group = G_ny)
string i_nyTz    = input.string("America/New_York", "City time zone", group = G_ny, tooltip = "Leave as is: hours above are read on this clock so daylight saving adjusts by itself.")
color  i_nyCol   = input.color(color.new(#c0392b, 0), "Line colour", group = G_ny)
bool   i_nyOpen  = input.bool(true, "Open line", inline = "nyo", group = G_ny)
int    i_nyOW    = input.int(1, "W", 1, 10, inline = "nyo", group = G_ny)
string i_nyOS    = input.string("Dashed", "", ["Solid", "Dashed", "Dotted"], inline = "nyo", group = G_ny)
bool   i_nyClose = input.bool(false, "Close line", inline = "nyc", group = G_ny)
int    i_nyCW    = input.int(1, "W", 1, 10, inline = "nyc", group = G_ny)
string i_nyCS    = input.string("Dotted", "", ["Solid", "Dashed", "Dotted"], inline = "nyc", group = G_ny)
bool   i_nyBox   = input.bool(false, "Session box", inline = "nyb", group = G_ny)
color  i_nyBCol  = input.color(color.new(#c0392b, 0), "", inline = "nyb", group = G_ny)
int    i_nyBTr   = input.int(90, "Fill transp.", 0, 100, inline = "nyb", group = G_ny)
int    i_nyBBw   = input.int(1, "Border", 0, 5, inline = "nyb", group = G_ny)
bool   i_nyCR    = input.bool(true, "Closing range", inline = "nyr", group = G_ny)
string i_nyCRS   = input.session("1630-1700", "", inline = "nyr", group = G_ny, tooltip = "Window in local New York time. Box marks the high and low inside it.")
color  i_nyCRCol = input.color(color.new(#c0392b, 0), "", inline = "nyr2", group = G_ny)
int    i_nyCRTr  = input.int(80, "Fill transp.", 0, 100, inline = "nyr2", group = G_ny)
int    i_nyCRBw  = input.int(1, "Border", 0, 5, inline = "nyr2", group = G_ny)
//#endregion

//#region Types
type Sess
    string sess
    string tz
    color  col
    bool   showOpen
    int    openW
    string openS
    bool   showClose
    int    closeW
    string closeS
    bool   showBox
    color  boxCol
    int    boxTr
    int    boxBw
    bool   showCR
    string crSess
    color  crCol
    int    crTr
    int    crBw
    array<line> lines
    array<box>  boxes
    array<box>  crs
    box    curBox = na
    box    curCR  = na
    bool   wasIn   = false
    bool   wasInCR = false
    int    lastClose = na

// Called on every bar (keeps time() history consistent).
method run(Sess this, bool allowed) =>
    bool inS  = not na(time(timeframe.period, this.sess + WEEKDAYS, this.tz))
    bool inCR = not na(time(timeframe.period, this.crSess + WEEKDAYS, this.tz))
    if allowed
        // session open / close lines
        if inS and not this.wasIn and this.showOpen
            f_vline(time, this.col, this.openW, this.openS, this.lines, i_keepDays * 2)
        if not inS and this.wasIn and this.showClose and not na(this.lastClose)
            f_vline(this.lastClose, this.col, this.closeW, this.closeS, this.lines, i_keepDays * 2)
        // session box (open -> close, high / low)
        if this.showBox
            if inS and not this.wasIn
                this.curBox := box.new(time, high, time_close, low, this.boxCol, this.boxBw, xloc = xloc.bar_time, bgcolor = color.new(this.boxCol, this.boxTr))
                this.boxes.push(this.curBox)
                f_trimBoxes(this.boxes, i_keepDays)
            else if inS and not na(this.curBox)
                this.curBox.set_right(time_close)
                this.curBox.set_top(math.max(this.curBox.get_top(), high))
                this.curBox.set_bottom(math.min(this.curBox.get_bottom(), low))
        // closing range (high / low inside the window)
        if this.showCR
            if inCR and not this.wasInCR
                this.curCR := box.new(time, high, time_close, low, this.crCol, this.crBw, xloc = xloc.bar_time, bgcolor = color.new(this.crCol, this.crTr))
                this.crs.push(this.curCR)
                f_trimBoxes(this.crs, i_keepDays)
            else if inCR and not na(this.curCR)
                this.curCR.set_right(time_close)
                this.curCR.set_top(math.max(this.curCR.get_top(), high))
                this.curCR.set_bottom(math.min(this.curCR.get_bottom(), low))
    if not inS
        this.curBox := na
    if not inCR
        this.curCR := na
    if inS
        this.lastClose := time_close
    this.wasIn   := inS
    this.wasInCR := inCR
//#endregion

//#region Period opens (London clock)
bool  higherTF = not timeframe.isintraday
// Daily+ candles start before the open on forex feeds, so read them by their close.
int   refT     = higherTF ? time_close - 1 : time
// London calendar date of this candle, as a UTC day number
int   lonDay   = f_dayNum(year(refT, OPEN_TZ), month(refT, OPEN_TZ), dayofmonth(refT, OPEN_TZ))
f_openAt(int dn) =>   // the open on London calendar day dn (built from the date, so DST days are exact)
    int t = dn * DAY_MS
    timestamp(OPEN_TZ, year(t, "UTC"), month(t, "UTC"), dayofmonth(t, "UTC"), i_dayHour, i_dayMin, 0)
int   openRef  = f_openAt(lonDay)
bool  afterOpen = refT >= openRef
int   lastOpen = afterOpen ? openRef : f_openAt(lonDay - 1)     // most recent open at/before this candle
// An evening open (default 23:00 London) starts the NEXT calendar day's trading day.
int   nextShift = i_dayHour >= 12 ? 1 : 0
int   dayNum   = lonDay + (afterOpen ? nextShift : nextShift - 1) // trading day this candle belongs to
int   tdT      = dayNum * DAY_MS
int   tdY      = year(tdT, "UTC")
int   tdM      = month(tdT, "UTC")
int   weekNum  = int(math.floor((dayNum + 3) / 7.0))          // week starts on Monday's trading day = the Sunday 23:00 London open
int   monthNum = tdY * 12 + tdM

var int lastDay = na
var int lastWeek = na
var int lastMonth = na
var int lastYear = na
// Intraday: only fire on a candle that starts within 12 hours after a real open
// (or within one candle, on charts with candles longer than 12 hours). Early broker
// Sunday candles (before the Sunday 23:00 London open) are ~a day after Saturday's
// unused open, so they never create a false open; the line waits for 23:00 London.
int  ARM_MS = math.max(12 * 3600000, timeframe.in_seconds() * 1000)
bool armed = higherTF or (refT - lastOpen < ARM_MS)
bool newDay   = false
bool newWeek  = false
bool newMonth = false
bool newYear  = false
if armed and not na(time) and (na(lastDay) or dayNum != lastDay)
    bool first = na(lastDay)
    newDay   := not first
    newWeek  := not first and weekNum != lastWeek
    newMonth := not first and monthNum != lastMonth
    newYear  := not first and tdY != lastYear
    lastDay   := dayNum
    lastWeek  := weekNum
    lastMonth := monthNum
    lastYear  := tdY

var array<line> linesD = array.new<line>()
var array<line> linesW = array.new<line>()
var array<line> linesM = array.new<line>()
var array<line> linesY = array.new<line>()
// Draw only the biggest period that opens on this candle (avoids stacked duplicates).
if newYear and i_showY
    f_vline(time, i_colY, i_wY, i_stY, linesY, i_lbY)
else if newMonth and i_showM
    f_vline(time, i_colM, i_wM, i_stM, linesM, i_lbM)
else if newWeek and i_showW
    f_vline(time, i_colW, i_wW, i_stW, linesW, i_lbW)
else if newDay and i_showD and timeframe.in_seconds() < 86400
    f_vline(time, i_colD, i_wD, i_stD, linesD, i_lbD)
//#endregion

//#region Sessions
var Sess s_syd = Sess.new(i_sydSess, i_sydTz, i_sydCol, i_sydOpen, i_sydOW, i_sydOS, i_sydClose, i_sydCW, i_sydCS, i_sydBox, i_sydBCol, i_sydBTr, i_sydBBw, i_sydCR, i_sydCRS, i_sydCRCol, i_sydCRTr, i_sydCRBw, array.new<line>(), array.new<box>(), array.new<box>())
var Sess s_tyo = Sess.new(i_tyoSess, i_tyoTz, i_tyoCol, i_tyoOpen, i_tyoOW, i_tyoOS, i_tyoClose, i_tyoCW, i_tyoCS, i_tyoBox, i_tyoBCol, i_tyoBTr, i_tyoBBw, i_tyoCR, i_tyoCRS, i_tyoCRCol, i_tyoCRTr, i_tyoCRBw, array.new<line>(), array.new<box>(), array.new<box>())
var Sess s_fra = Sess.new(i_fraSess, i_fraTz, i_fraCol, i_fraOpen, i_fraOW, i_fraOS, i_fraClose, i_fraCW, i_fraCS, i_fraBox, i_fraBCol, i_fraBTr, i_fraBBw, i_fraCR, i_fraCRS, i_fraCRCol, i_fraCRTr, i_fraCRBw, array.new<line>(), array.new<box>(), array.new<box>())
var Sess s_lon = Sess.new(i_lonSess, i_lonTz, i_lonCol, i_lonOpen, i_lonOW, i_lonOS, i_lonClose, i_lonCW, i_lonCS, i_lonBox, i_lonBCol, i_lonBTr, i_lonBBw, i_lonCR, i_lonCRS, i_lonCRCol, i_lonCRTr, i_lonCRBw, array.new<line>(), array.new<box>(), array.new<box>())
var Sess s_ny = Sess.new(i_nySess, i_nyTz, i_nyCol, i_nyOpen, i_nyOW, i_nyOS, i_nyClose, i_nyCW, i_nyCS, i_nyBox, i_nyBCol, i_nyBTr, i_nyBBw, i_nyCR, i_nyCRS, i_nyCRCol, i_nyCRTr, i_nyCRBw, array.new<line>(), array.new<box>(), array.new<box>())

bool sessAllowed = timeframe.isintraday and timeframe.in_seconds() <= i_maxTF * 60
s_syd.run(sessAllowed and i_sydShow)
s_tyo.run(sessAllowed and i_tyoShow)
s_fra.run(sessAllowed and i_fraShow)
s_lon.run(sessAllowed and i_lonShow)
s_ny.run(sessAllowed and i_nyShow)
//#endregion
````
