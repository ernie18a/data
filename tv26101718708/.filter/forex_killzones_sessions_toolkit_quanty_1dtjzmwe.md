# Forex Killzones & Sessions Toolkit [Quanty]

- url: https://www.tradingview.com/script/1DTjzmWe-Forex-Killzones-Sessions-Toolkit-Quanty/
- type: indicator
- pine_id: PUB;cbb44141aed14551a90853bc73f1297d
- version: 1.0

## Description

A session map for forex traders. It puts the reference points most intraday forex traders already draw by hand on one chart: the Monday range, the killzones, the session highs and lows that the market tends to come back to, the previous day and week, the opens that matter (New York midnight, 08:30, the week), the ICT Silver Bullet hours and a day separator, with a small panel that shows the session hours in your own time zone.

WHAT IT DRAWS

Monday range: the high, low and midpoint of Monday's daily candle, carried to the end of the week. Monday follows the symbol's own daily candle, which on most forex feeds opens on Sunday at 17:00 New York time.

Killzones: Asia (20:00 to 00:00), London (02:00 to 05:00), New York (07:00 to 10:00) and London Close (10:00 to 12:00), New York time, plus an optional New York PM session. Each is drawn as a box around its own high and low.

Session highs and lows: the Asia and London highs and lows extend to the right until price trades through them, then stop at the candle that took them and turn dotted.

Key levels: previous day and previous week high and low, the New York midnight open, the New York 08:30 open (when most US data is released; charts of 30 minutes and below) and the weekly open, each labelled at the right edge. The new week opening gap (NWOG), between Friday's last close and the week's first open, is carried through the week as a faint box.

Day separator: a thin dashed vertical line where each day starts, so the days read apart at a glance. It follows the symbol's daily candle by default, the same day the previous day high and low use, and can be set to New York midnight instead.

ICT windows: the three Silver Bullet hours (London 03:00-04:00, New York 10:00-11:00 and 14:00-15:00, New York time) drawn as dotted outlines so they read apart from the killzone boxes. Two more can be switched on: the central bank dealers range (CBDR, 14:00-20:00), which prints its size when it closes, and the New York lunch hour (12:00-13:00).

Legend card: an optional key in the corner lists everything drawn, with the session hours in your time zone, and says what the script leaves out: news times and buy or sell calls. It is off by default; switch it on in the Panel settings.

Panel: the time now and each session's hours in the time zone you choose, the average daily range (in pips on forex), how much of it today has used, and the size of the Monday range.

TIME ZONES

Session hours are defined in New York time, and the America/New_York time zone carries daylight saving, so the boxes stay on the right hours all year without any change on your side. The time zone setting changes only how hours are shown, so a trader on UTC+3 sees London as 09:00 to 12:00 in summer and 10:00 to 13:00 after US clocks change. If you prefer, the session hours can be entered in your own time zone instead; they then stay fixed and drift by an hour when US clocks change.

NOTES AND LIMITATIONS

Killzones, ICT windows and the midnight open are drawn on charts of 1 hour and below. Everything drawn is a clock time or a price that already printed; nothing forecasts direction. Economic news times are not included, because scripts cannot read an economic calendar.

ALERTS

Monday high break and Monday low break; Asia, London and New York session high or low taken; London and New York killzone open; Silver Bullet hour open.

HOW TO READ THE STATS TABLE

The table in the corner measures this indicator's own past signals on the chart you are viewing: how many signals fired (the number after the slash), and in how many of them price moved at least 1 ATR (14 bars) in the signal's direction within the next 10 bars. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The row below it runs the same test on every bar of the chart in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume: signals whose candle volume was at least 2 times the average of the previous 50 bars, and the rest. When one side has only a handful of signals, read it as a handful, not as a rate. Pending signals are too recent to be measured and are not counted. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting.

Here a signal is the first close of the day above the previous day's high (upward) or below the previous day's low (downward). Intraday charts only; on daily and higher charts nothing is counted.

## Source Code

````pine
//@version=6
// Forex Killzones & Sessions Toolkit [Quanty] - v0.6 - 2026-09-30 - working copy, awaiting first compile
// v0.6: palette follows the Quanty design tokens (no off-brand hues)
// v0.5: legend card (what is on the chart and what is not), lighter killzone boxes
// v0.4: ICT time windows (Silver Bullet, CBDR, New York lunch), New York 08:30 open, new week opening gap
// v0.3: day separator (thin dashed vertical line at each new day)
// v0.2: Quanty Stats table (close through the previous day's high or low) + volume split
indicator("Forex Killzones & Sessions Toolkit [Quanty]", shorttitle="Quanty FX", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// A session map for forex traders:
//   - Monday range: high, low and midpoint of Monday, carried to the end of the week
//   - Killzones: Asia, London, New York, London Close (New York PM optional)
//   - Session highs and lows that run right until price takes them
//   - Previous day and previous week high / low
//   - New York midnight open and weekly open
//   - Day separator: a thin dashed vertical line where each day starts
//   - ICT windows: the three Silver Bullet hours, the central bank dealers
//     range (CBDR) and the New York lunch hour
//   - New York 08:30 open and the new week opening gap (NWOG)
//   - Panel: today's session hours in your own time zone, average daily range,
//     how much of it today has used, Monday's range
//
// Session hours are entered in New York time by default. The America/New_York
// time zone carries daylight saving, so the boxes stay on the right hours all
// year. "Your time zone" only changes how hours are SHOWN (panel, box names):
// a trader on UTC+3 sees London as 09:00-12:00 in summer and 10:00-13:00 once
// US clocks go back, without touching any setting.
//
// Nothing here forecasts direction. Every mark is a clock time or a price that
// already printed. A forming session or a forming Monday grows until it
// closes; after that it is fixed and never moved.

// ===========================================================================
// Palette
// ===========================================================================
// Quanty design system v1: every colour below is a brand token.
const color C_NIGHT  = #0B1015
const color C_PANEL  = #10171E
const color C_LINE   = #202B35
const color C_MINT   = #65E1C6
const color C_CREAM  = #F2EFE6
const color C_SOFT   = #A9B4C2
const color C_MUTED  = #707C8A
const color C_AMBER  = #F5B041
const color C_ORANGE = #EF7A2B
const color C_RED    = #E0576B

const string TZ = "America/New_York"

// ===========================================================================
// Inputs
// ===========================================================================
const string G_TZ  = "1. Time zone"
const string G_MON = "2. Monday range"
const string G_KZ  = "3. Killzones"
const string G_LIQ = "4. Session highs and lows"
const string G_LVL = "5. Key levels"
const string G_ADR = "6. Panel"
const string G_ICT = "7. ICT windows"

string tzPick = input.string("UTC", "Your time zone",
     options=["UTC-10", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3", "UTC-2", "UTC-1", "UTC",
     "UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+5:30", "UTC+6", "UTC+7", "UTC+8", "UTC+9", "UTC+10", "UTC+11", "UTC+12"],
     group=G_TZ, tooltip="Session hours in the panel and on the boxes are shown in this time zone. A fixed offset does not follow summer time: if your own country moves its clocks, pick the new offset.")
string sessIn = input.string("New York time", "Session hours below are in", options=["New York time", "My time zone"], group=G_TZ,
     tooltip="New York time (default): the killzones follow US daylight saving by themselves and stay right all year. My time zone: retype the hours below in your own time. They then stay fixed, so they drift by one hour when US clocks change.")

bool  monShow  = input.bool(true, "Monday range", group=G_MON,
     tooltip="High and low of Monday's daily candle, carried to the end of the week. The day follows the symbol's own daily candle: on most forex feeds it opens Sunday 17:00 New York.")
bool  monMid   = input.bool(true, "Midpoint", group=G_MON)
int   monWeeks = input.int(4, "Weeks kept", minval=1, maxval=20, group=G_MON)
color monCol   = input.color(C_CREAM, "Color", group=G_MON)

bool   asiaOn = input.bool(true, "Asia", group=G_KZ, inline="asia")
string asiaS  = input.session("2000-0000", "", group=G_KZ, inline="asia")
color  asiaC  = input.color(C_AMBER, "", group=G_KZ, inline="asia")
bool   lonOn  = input.bool(true, "London", group=G_KZ, inline="lon")
string lonS   = input.session("0200-0500", "", group=G_KZ, inline="lon")
color  lonC   = input.color(C_RED, "", group=G_KZ, inline="lon")
bool   nyOn   = input.bool(true, "New York", group=G_KZ, inline="ny")
string nyS    = input.session("0700-1000", "", group=G_KZ, inline="ny")
color  nyC    = input.color(C_MINT, "", group=G_KZ, inline="ny")
bool   lcOn   = input.bool(true, "London Close", group=G_KZ, inline="lc")
string lcS    = input.session("1000-1200", "", group=G_KZ, inline="lc")
color  lcC    = input.color(C_ORANGE, "", group=G_KZ, inline="lc")
bool   pmOn   = input.bool(false, "New York PM", group=G_KZ, inline="pm")
string pmS    = input.session("1330-1600", "", group=G_KZ, inline="pm")
color  pmC    = input.color(C_SOFT, "", group=G_KZ, inline="pm")
int    kzDays  = input.int(5, "Days kept", minval=1, maxval=60, group=G_KZ)
bool   kzNames = input.bool(true, "Session names", group=G_KZ)
int    kzFill  = input.int(94, "Fill transparency", minval=0, maxval=100, group=G_KZ,
     tooltip="Killzones and the midnight open are drawn on charts of 1 hour and below.")
int    kzEdge  = input.int(78, "Border transparency", minval=0, maxval=100, group=G_KZ,
     tooltip="Borders are already one pixel wide, the thinnest a chart can draw; a higher value makes them fainter.")

bool extAsia = input.bool(true, "Asia", group=G_LIQ, inline="ext")
bool extLon  = input.bool(true, "London", group=G_LIQ, inline="ext")
bool extNy   = input.bool(false, "New York", group=G_LIQ, inline="ext",
     tooltip="The session's high and low run to the right until price trades through them. A taken level stops at the candle that took it and turns dotted.")

bool   sbOn = input.bool(true, "Silver Bullet hours", group=G_ICT, inline="sb",
     tooltip="Three one-hour windows ICT singles out inside the sessions: London 03:00-04:00, New York AM 10:00-11:00 and New York PM 14:00-15:00, New York time. Drawn as a dotted outline so they read apart from the killzone boxes.")
color  sbC  = input.color(C_CREAM, "", group=G_ICT, inline="sb")
string sb1S = input.session("0300-0400", "London", group=G_ICT, inline="sbs")
string sb2S = input.session("1000-1100", "AM", group=G_ICT, inline="sbs")
string sb3S = input.session("1400-1500", "PM", group=G_ICT, inline="sbs")
bool   cbOn = input.bool(false, "CBDR", group=G_ICT, inline="cb",
     tooltip="Central bank dealers range: 14:00-20:00 New York, the quiet stretch between the New York afternoon and the Asian open. Its size is printed on the box when it closes; ICT reads a narrow CBDR (under about 40 pips on EURUSD) as room for a larger move the next day.")
string cbS  = input.session("1400-2000", "", group=G_ICT, inline="cb")
color  cbC  = input.color(C_SOFT, "", group=G_ICT, inline="cb")
bool   luOn = input.bool(false, "New York lunch", group=G_ICT, inline="lu",
     tooltip="12:00-13:00 New York: the hour ICT treats as a pause between the morning and afternoon moves.")
string luS  = input.session("1200-1300", "", group=G_ICT, inline="lu")
color  luC  = input.color(C_MUTED, "", group=G_ICT, inline="lu")

bool  pdOn   = input.bool(true, "Previous day high / low", group=G_LVL, inline="pd")
color pdC    = input.color(C_MUTED, "", group=G_LVL, inline="pd")
bool  pwOn   = input.bool(true, "Previous week high / low", group=G_LVL, inline="pw")
color pwC    = input.color(C_MUTED, "", group=G_LVL, inline="pw")
bool  moOn   = input.bool(true, "New York midnight open", group=G_LVL, inline="mo")
color moC    = input.color(C_SOFT, "", group=G_LVL, inline="mo")
bool  woOn   = input.bool(true, "Weekly open", group=G_LVL, inline="wo")
color woC    = input.color(C_SOFT, "", group=G_LVL, inline="wo")
bool  o830On = input.bool(true, "New York 08:30 open", group=G_LVL, inline="o830",
     tooltip="The opening price of the 08:30 New York candle, when most US data is released. Drawn on charts of 30 minutes and below.")
color o830C  = input.color(C_SOFT, "", group=G_LVL, inline="o830")
bool  nwOn   = input.bool(true, "New week opening gap (NWOG)", group=G_LVL, inline="nw",
     tooltip="The gap between Friday's last close and the first open of the new week, carried through the week.")
color nwC    = input.color(C_MUTED, "", group=G_LVL, inline="nw")
bool   dsOn   = input.bool(true, "Day separator", group=G_LVL, inline="ds")
color  dsC    = input.color(color.new(C_MUTED, 55), "", group=G_LVL, inline="ds")
string dsAt   = input.string("Daily candle open", "at", options=["Daily candle open", "New York midnight"], group=G_LVL, inline="ds",
     tooltip="Daily candle open: the line sits where the symbol's daily candle starts (17:00 New York on most forex feeds), the same day the previous day high and low use. New York midnight: the line sits at 00:00 New York.")
int    dsDays = input.int(20, "Day separators kept", minval=1, maxval=200, group=G_LVL)
int   lblGap = input.int(4, "Label distance (bars)", minval=0, maxval=50, group=G_LVL)

bool   adrOn  = input.bool(true, "Show panel", group=G_ADR)
int    adrLen = input.int(14, "ADR length (days)", minval=1, maxval=100, group=G_ADR)
string adrPos = input.string("Top right", "Position", options=["Top right", "Bottom right", "Bottom left", "Top left"], group=G_ADR)
bool   lgOn   = input.bool(false, "Legend card", group=G_ADR, inline="lg",
     tooltip="A small key to everything drawn, with the session hours in your time zone, and a line on what the script leaves out. Off by default.")
string lgPos  = input.string("Bottom left", "", options=["Bottom left", "Top left", "Bottom right", "Top right"], group=G_ADR, inline="lg")

// ===========================================================================
// Timeframe gates and units
// ===========================================================================
bool tfIntra = timeframe.isintraday
bool weekOk  = timeframe.isintraday or timeframe.isdaily
// Sessions of 2-4 hours need at least hourly candles to mean anything.
bool kzOk    = tfIntra and timeframe.in_seconds(timeframe.period) <= 3600

// Display zone, and the zone the session inputs are read in.
string tzUser = tzPick == "UTC+5:30" ? "GMT+0530" : tzPick
string tzSess = sessIn == "New York time" ? TZ : tzUser

// Forex ranges are shown in pips (0.01 on JPY quotes, 0.0001 otherwise);
// anything else is shown in its own price units.
bool  isFx = syminfo.type == "forex"
float pip  = str.contains(syminfo.currency, "JPY") ? 0.01 : 0.0001

f_size(float x) =>
    na(x) ? "-" : isFx ? str.tostring(x / pip, "#,##0.0") + " pips" : str.tostring(x, format.mintick)

// ===========================================================================
// Period anchors: day, week, New York midnight
// ===========================================================================
// Day and week follow the symbol's own daily and weekly candles.
bool newDay  = timeframe.change("D")
bool newWeek = timeframe.change("W")

var int   dayBar   = na
var float dayHi    = na
var float dayLo    = na
var int   weekBar  = na
var float weekOpen = na
if newDay
    dayBar := bar_index
    dayHi  := high
    dayLo  := low
else
    dayHi := math.max(nz(dayHi, high), high)
    dayLo := math.min(nz(dayLo, low), low)
if newWeek
    weekBar  := bar_index
    weekOpen := open

var int   midBar  = na
var float midOpen = na
int nyHour = hour(time, TZ)
var int   o830Bar  = na
var float o830Open = na
if kzOk and nyHour == 0 and nyHour[1] != 0
    midBar  := bar_index
    midOpen := open
    // A new New York day: yesterday's 08:30 open no longer applies.
    o830Bar  := na
    o830Open := na
if kzOk and nyHour == 8 and minute(time, TZ) == 30
    o830Bar  := bar_index
    o830Open := open

// New week opening gap: Friday's last close against the week's first open.
var array<box> nwBoxes = array.new<box>()
if nwOn and weekOk and newWeek and not na(close[1])
    float gTop = math.max(open, close[1])
    float gBot = math.min(open, close[1])
    if gTop - gBot >= syminfo.mintick
        nwBoxes.push(box.new(bar_index, gTop, bar_index, gBot, border_color=color.new(nwC, 40), border_width=1, border_style=line.style_dotted,
             bgcolor=color.new(nwC, 88), text="NWOG", text_size=size.small, text_color=nwC, text_halign=text.align_left, text_valign=text.align_top))
        if nwBoxes.size() > monWeeks
            nwBoxes.shift().delete()
if nwOn and nwBoxes.size() > 0
    nwBoxes.last().set_right(bar_index)

// Day separator: one thin dashed vertical line on the first candle of each day.
// Intraday charts only. The line is drawn once, on a candle that has already
// opened, and never moves.
var array<line> dsLines = array.new<line>()
bool dsNew = dsAt == "New York midnight" ? dayofmonth(time, TZ) != dayofmonth(time[1], TZ) : newDay
if dsOn and tfIntra and dsNew
    dsLines.push(line.new(bar_index, low, bar_index, low + math.max(high - low, syminfo.mintick),
         extend=extend.both, color=dsC, style=line.style_dashed, width=1))
    if dsLines.size() > dsDays
        dsLines.shift().delete()

// Previous completed day / week, read one candle back with lookahead_on:
// the value is final the moment the new period opens and never changes.
[pdh, pdl, adr] = request.security(syminfo.tickerid, "D", [high[1], low[1], ta.sma(high - low, adrLen)[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl]      = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// ===========================================================================
// Killzones
// ===========================================================================
type KzDay
    box   bx
    line  hiLn
    line  loLn
    float hi
    float lo
    int   hiBar
    int   loBar
    bool  hiOpen = false
    bool  loOpen = false

type Killzone
    string name
    color  col
    bool   ext
    bool   thin = false    // dotted outline, no fill (ICT windows)
    bool   sz   = false    // print the range on the box when the window closes
    bool   active = false
    KzDay  cur
    array<KzDay> days

// Draws one killzone for the current bar. Returns [high taken, low taken].
method run(Killzone z, bool enabled, bool inS) =>
    bool hiTaken = false
    bool loTaken = false
    if enabled
        if inS and not z.active
            KzDay nd = KzDay.new(hi=high, lo=low, hiBar=bar_index, loBar=bar_index)
            nd.bx := box.new(bar_index, high, bar_index, low, border_color=color.new(z.col, z.thin ? 45 : kzEdge), border_width=1,
                 border_style=z.thin ? line.style_dotted : line.style_solid,
                 bgcolor=color.new(z.col, z.thin ? 100 : kzFill), text=kzNames ? z.name + " " + str.format_time(time, "HH:mm", tzUser) : "", text_size=size.small,
                 text_color=z.col, text_halign=text.align_left, text_valign=text.align_top)
            z.cur := nd
            z.days.push(nd)
            z.active := true
            if z.days.size() > kzDays
                KzDay od = z.days.shift()
                od.bx.delete()
                if not na(od.hiLn)
                    od.hiLn.delete()
                if not na(od.loLn)
                    od.loLn.delete()
        else if inS
            KzDay cd = z.cur
            if high > cd.hi
                cd.hi    := high
                cd.hiBar := bar_index
            if low < cd.lo
                cd.lo    := low
                cd.loBar := bar_index
            cd.bx.set_top(cd.hi)
            cd.bx.set_bottom(cd.lo)
            cd.bx.set_right(bar_index)
        else if z.active
            // The session just closed: its high and low become levels.
            z.active := false
            if z.sz
                KzDay sd = z.cur
                sd.bx.set_text(z.name + " " + f_size(sd.hi - sd.lo))
            if z.ext
                KzDay fd = z.cur
                fd.hiLn   := line.new(fd.hiBar, fd.hi, bar_index, fd.hi, color=z.col, width=1)
                fd.loLn   := line.new(fd.loBar, fd.lo, bar_index, fd.lo, color=z.col, width=1)
                fd.hiOpen := true
                fd.loOpen := true
        // Open levels run right until price trades through them.
        if z.ext
            for k in z.days
                if k.hiOpen
                    k.hiLn.set_x2(bar_index)
                    if high > k.hi
                        k.hiOpen := false
                        k.hiLn.set_style(line.style_dotted)
                        hiTaken := true
                if k.loOpen
                    k.loLn.set_x2(bar_index)
                    if low < k.lo
                        k.loOpen := false
                        k.loLn.set_style(line.style_dotted)
                        loTaken := true
    [hiTaken, loTaken]

bool inAsia = not na(time(timeframe.period, asiaS, tzSess))
bool inLon  = not na(time(timeframe.period, lonS, tzSess))
bool inNy   = not na(time(timeframe.period, nyS, tzSess))
bool inLc   = not na(time(timeframe.period, lcS, tzSess))
bool inPm   = not na(time(timeframe.period, pmS, tzSess))

var Killzone zAsia = Killzone.new(name="Asia", col=asiaC, ext=extAsia, days=array.new<KzDay>())
var Killzone zLon  = Killzone.new(name="London", col=lonC, ext=extLon, days=array.new<KzDay>())
var Killzone zNy   = Killzone.new(name="New York", col=nyC, ext=extNy, days=array.new<KzDay>())
var Killzone zLc   = Killzone.new(name="London Close", col=lcC, ext=false, days=array.new<KzDay>())
var Killzone zPm   = Killzone.new(name="NY PM", col=pmC, ext=false, days=array.new<KzDay>())

[asiaHiT, asiaLoT] = zAsia.run(kzOk and asiaOn, inAsia)
[lonHiT, lonLoT]   = zLon.run(kzOk and lonOn, inLon)
[nyHiT, nyLoT]     = zNy.run(kzOk and nyOn, inNy)
[lcHiT, lcLoT]     = zLc.run(kzOk and lcOn, inLc)
[pmHiT, pmLoT]     = zPm.run(kzOk and pmOn, inPm)

// ICT windows, drawn with the same machinery: Silver Bullet hours and New York
// lunch as dotted outlines, CBDR as a box that prints its size when it closes.
bool inSb1 = not na(time(timeframe.period, sb1S, tzSess))
bool inSb2 = not na(time(timeframe.period, sb2S, tzSess))
bool inSb3 = not na(time(timeframe.period, sb3S, tzSess))
bool inCb  = not na(time(timeframe.period, cbS, tzSess))
bool inLu  = not na(time(timeframe.period, luS, tzSess))

var Killzone zSb1 = Killzone.new(name="SB", col=sbC, ext=false, thin=true, days=array.new<KzDay>())
var Killzone zSb2 = Killzone.new(name="SB", col=sbC, ext=false, thin=true, days=array.new<KzDay>())
var Killzone zSb3 = Killzone.new(name="SB", col=sbC, ext=false, thin=true, days=array.new<KzDay>())
var Killzone zCb  = Killzone.new(name="CBDR", col=cbC, ext=false, sz=true, days=array.new<KzDay>())
var Killzone zLu  = Killzone.new(name="Lunch", col=luC, ext=false, thin=true, days=array.new<KzDay>())

[sb1HiT, sb1LoT] = zSb1.run(kzOk and sbOn, inSb1)
[sb2HiT, sb2LoT] = zSb2.run(kzOk and sbOn, inSb2)
[sb3HiT, sb3LoT] = zSb3.run(kzOk and sbOn, inSb3)
[cbHiT, cbLoT]   = zCb.run(kzOk and cbOn, inCb)
[luHiT, luLoT]   = zLu.run(kzOk and luOn, inLu)
bool sbLive  = kzOk and sbOn and (inSb1 or inSb2 or inSb3)
bool sbStart = kzOk and sbOn and ((inSb1 and not inSb1[1]) or (inSb2 and not inSb2[1]) or (inSb3 and not inSb3[1]))

// ===========================================================================
// Monday range
// ===========================================================================
type MonRange
    float hi
    float lo
    line  hiLn
    line  loLn
    line  midLn
    bool  closed = false
    bool  done = false

bool monOk    = monShow and weekOk
// The trading day decides "Monday": a forex candle that opens Sunday 17:00
// New York belongs to Monday, exactly as on the daily chart.
bool isMonday = dayofweek(time_tradingday, "UTC") == dayofweek.monday
bool monStart = isMonday and not isMonday[1]

var MonRange mon = na
var array<MonRange> monHist = array.new<MonRange>()

if monOk
    // A week with no Monday (holiday) still ends last week's range.
    if newWeek and not monStart and not na(mon)
        mon.done := true
    if monStart
        if not na(mon)
            mon.done := true
        MonRange m = MonRange.new(hi=high, lo=low)
        m.hiLn := line.new(bar_index, high, bar_index, high, color=monCol, width=2)
        m.loLn := line.new(bar_index, low, bar_index, low, color=monCol, width=2)
        if monMid
            m.midLn := line.new(bar_index, (high + low) / 2, bar_index, (high + low) / 2, color=monCol, width=1, style=line.style_dotted)
        monHist.push(m)
        if monHist.size() > monWeeks
            MonRange o = monHist.shift()
            o.hiLn.delete()
            o.loLn.delete()
            if not na(o.midLn)
                o.midLn.delete()
        mon := m
    else if not na(mon) and not mon.done
        if isMonday and not mon.closed
            mon.hi := math.max(mon.hi, high)
            mon.lo := math.min(mon.lo, low)
            mon.hiLn.set_y1(mon.hi)
            mon.hiLn.set_y2(mon.hi)
            mon.loLn.set_y1(mon.lo)
            mon.loLn.set_y2(mon.lo)
            if not na(mon.midLn)
                mon.midLn.set_y1((mon.hi + mon.lo) / 2)
                mon.midLn.set_y2((mon.hi + mon.lo) / 2)
        else
            mon.closed := true
        mon.hiLn.set_x2(bar_index)
        mon.loLn.set_x2(bar_index)
        if not na(mon.midLn)
            mon.midLn.set_x2(bar_index)

float monHiS  = na(mon) ? na : mon.hi
float monLoS  = na(mon) ? na : mon.lo
bool  crossUp = ta.crossover(close, monHiS)
bool  crossDn = ta.crossunder(close, monLoS)
bool  monLive = monOk and not na(mon) and mon.closed and not mon.done

// ===========================================================================
// Key levels and labels (redrawn on the last bar only)
// ===========================================================================
var array<line>  lvLines  = array.new<line>()
var array<label> lvLabels = array.new<label>()

f_level(array<line> ls, array<label> lbs, int x1, float y, string txt, color c, string st) =>
    if not na(x1) and not na(y)
        int x2 = bar_index + lblGap
        ls.push(line.new(x1, y, x2, y, color=c, style=st, width=1))
        lbs.push(label.new(x2, y, txt, style=label.style_label_left, color=color(na), textcolor=c, size=size.small))

f_tag(array<label> lbs, float y, string txt, color c) =>
    lbs.push(label.new(bar_index + lblGap, y, txt, style=label.style_label_left, color=color(na), textcolor=c, size=size.small))

if barstate.islast
    for l in lvLines
        l.delete()
    lvLines.clear()
    for b in lvLabels
        b.delete()
    lvLabels.clear()

    if pdOn and tfIntra
        f_level(lvLines, lvLabels, dayBar, pdh, "PDH", pdC, line.style_dashed)
        f_level(lvLines, lvLabels, dayBar, pdl, "PDL", pdC, line.style_dashed)
    if pwOn and weekOk
        f_level(lvLines, lvLabels, weekBar, pwh, "PWH", pwC, line.style_solid)
        f_level(lvLines, lvLabels, weekBar, pwl, "PWL", pwC, line.style_solid)
    if moOn and kzOk
        f_level(lvLines, lvLabels, midBar, midOpen, "NY 00:00", moC, line.style_dotted)
    if o830On and kzOk
        f_level(lvLines, lvLabels, o830Bar, o830Open, "NY 08:30", o830C, line.style_dotted)
    if woOn and weekOk
        f_level(lvLines, lvLabels, weekBar, weekOpen, "W OPEN", woC, line.style_dashed)

    if monOk and not na(mon) and not mon.done
        int x2 = bar_index + lblGap
        mon.hiLn.set_x2(x2)
        mon.loLn.set_x2(x2)
        f_tag(lvLabels, mon.hi, "MON H", monCol)
        f_tag(lvLabels, mon.lo, "MON L", monCol)
        if not na(mon.midLn)
            mon.midLn.set_x2(x2)
            f_tag(lvLabels, (mon.hi + mon.lo) / 2, "MON EQ", monCol)

// ===========================================================================
// Panel
// ===========================================================================
string tPos = adrPos == "Top right" ? position.top_right : adrPos == "Bottom right" ? position.bottom_right : adrPos == "Bottom left" ? position.bottom_left : position.top_left
var table panel = table.new(tPos, 2, 12, bgcolor=C_PANEL, frame_color=C_LINE, frame_width=1)

f_row(table t, int r, string k, color kc, string v, color vc) =>
    table.cell(t, 0, r, k, text_color=kc, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, r, v, text_color=vc, text_size=size.small, text_halign=text.align_right)

// Today's window of a session input ("HHMM-HHMM"), read in the session zone
// and shown in the display zone. Built from today's date, so the shown hours
// already include whatever daylight saving applies today.
f_win(string s) =>
    float h1 = str.tonumber(str.substring(s, 0, 2))
    float m1 = str.tonumber(str.substring(s, 2, 4))
    float h2 = str.tonumber(str.substring(s, 5, 7))
    float m2 = str.tonumber(str.substring(s, 7, 9))
    string out = "-"
    if not na(h1) and not na(m1) and not na(h2) and not na(m2)
        int yy = year(time, tzSess)
        int mm = month(time, tzSess)
        int dd = dayofmonth(time, tzSess)
        int t1 = timestamp(tzSess, yy, mm, dd, int(h1), int(m1))
        int t2 = timestamp(tzSess, yy, mm, dd, int(h2), int(m2))
        out := str.format_time(t1, "HH:mm", tzUser) + "-" + str.format_time(t2, "HH:mm", tzUser)
    out

// Start hour of a session input, in the display zone.
f_start(string s) =>
    string w = f_win(s)
    w == "-" ? "-" : str.substring(w, 0, 5)

// The live session is lit in mint; the others stay muted.
f_sess(table t, int r, string name, string s, bool live) =>
    f_row(t, r, name, live ? C_MINT : C_SOFT, f_win(s), live ? C_MINT : C_CREAM)

if adrOn and weekOk and barstate.islast
    float  todayR  = dayHi - dayLo
    string usedTxt = na(adr) or adr <= 0 ? "" : "  " + str.tostring(math.round(100 * todayR / adr)) + "%"
    string monTxt  = na(mon) or mon.done ? "-" : f_size(mon.hi - mon.lo) + (mon.closed ? "" : " (forming)")
    int r = 0
    f_row(panel, r, "Now (" + tzPick + ")", C_SOFT, str.format_time(timenow, "HH:mm", tzUser), C_CREAM)
    if asiaOn
        r += 1
        f_sess(panel, r, "Asia", asiaS, kzOk and inAsia)
    if lonOn
        r += 1
        f_sess(panel, r, "London", lonS, kzOk and inLon)
    if nyOn
        r += 1
        f_sess(panel, r, "New York", nyS, kzOk and inNy)
    if lcOn
        r += 1
        f_sess(panel, r, "London Close", lcS, kzOk and inLc)
    if pmOn
        r += 1
        f_sess(panel, r, "New York PM", pmS, kzOk and inPm)
    if sbOn
        r += 1
        f_row(panel, r, "Silver Bullet", sbLive ? C_MINT : C_SOFT, f_start(sb1S) + " / " + f_start(sb2S) + " / " + f_start(sb3S), sbLive ? C_MINT : C_CREAM)
    if cbOn
        r += 1
        f_sess(panel, r, "CBDR", cbS, kzOk and inCb)
    if luOn
        r += 1
        f_sess(panel, r, "NY lunch", luS, kzOk and inLu)
    r += 1
    f_row(panel, r, "ADR " + str.tostring(adrLen), C_SOFT, f_size(adr), C_CREAM)
    r += 1
    f_row(panel, r, "Today", C_SOFT, f_size(todayR) + usedTxt, todayR >= adr ? C_MINT : C_CREAM)
    r += 1
    f_row(panel, r, "Monday", C_SOFT, monTxt, monCol)

// ===========================================================================
// Legend card: what is on the chart, and what is not
// ===========================================================================
string lPos = lgPos == "Top left" ? position.top_left : lgPos == "Bottom right" ? position.bottom_right : lgPos == "Top right" ? position.top_right : position.bottom_left
var table legend = table.new(lPos, 2, 14, bgcolor=C_PANEL, frame_color=C_LINE, frame_width=1)

// One row: a colour swatch and what it stands for.
f_leg(table t, int r, color sw, string txt) =>
    table.cell(t, 0, r, "  ", bgcolor=sw, text_size=size.tiny)
    table.cell(t, 1, r, txt, text_color=C_CREAM, text_size=size.small, text_halign=text.align_left)

if lgOn and barstate.islast
    int q = 0
    table.cell(legend, 0, q, "", text_size=size.tiny)
    table.cell(legend, 1, q, "ON THIS CHART (" + tzPick + ")", text_color=C_MINT, text_size=size.small, text_halign=text.align_left)
    if kzOk and asiaOn
        q += 1
        f_leg(legend, q, asiaC, "Asia killzone  " + f_win(asiaS))
    if kzOk and lonOn
        q += 1
        f_leg(legend, q, lonC, "London killzone  " + f_win(lonS))
    if kzOk and nyOn
        q += 1
        f_leg(legend, q, nyC, "New York killzone  " + f_win(nyS))
    if kzOk and lcOn
        q += 1
        f_leg(legend, q, lcC, "London Close  " + f_win(lcS))
    if kzOk and pmOn
        q += 1
        f_leg(legend, q, pmC, "New York PM  " + f_win(pmS))
    if kzOk and sbOn
        q += 1
        f_leg(legend, q, sbC, "Silver Bullet hours (dotted)")
    if kzOk and cbOn
        q += 1
        f_leg(legend, q, cbC, "CBDR  " + f_win(cbS))
    if kzOk and luOn
        q += 1
        f_leg(legend, q, luC, "New York lunch  " + f_win(luS))
    if monOk
        q += 1
        f_leg(legend, q, monCol, "Monday range: high, low, midpoint")
    if (pdOn and tfIntra) or (pwOn and weekOk)
        q += 1
        f_leg(legend, q, pdC, "Previous day and week high / low")
    if (moOn and kzOk) or (o830On and kzOk) or (woOn and weekOk)
        q += 1
        f_leg(legend, q, moC, "Opens: NY midnight, NY 08:30, week")
    if (dsOn and tfIntra) or (nwOn and weekOk)
        q += 1
        f_leg(legend, q, color.new(C_MUTED, 30), "Day separator, week opening gap")
    q += 1
    table.cell(legend, 0, q, "", text_size=size.tiny)
    table.cell(legend, 1, q, "Not here: news times, buy or sell calls", text_color=C_MUTED, text_size=size.tiny, text_halign=text.align_left)

// ===========================================================================
// Alerts
// ===========================================================================
alertcondition(monLive and crossUp, "Monday high break", "{{ticker}}: close above the Monday high")
alertcondition(monLive and crossDn, "Monday low break", "{{ticker}}: close below the Monday low")
alertcondition(asiaHiT, "Asia high taken", "{{ticker}}: price took the Asia high")
alertcondition(asiaLoT, "Asia low taken", "{{ticker}}: price took the Asia low")
alertcondition(lonHiT, "London high taken", "{{ticker}}: price took the London high")
alertcondition(lonLoT, "London low taken", "{{ticker}}: price took the London low")
alertcondition(nyHiT, "New York high taken", "{{ticker}}: price took the New York high")
alertcondition(nyLoT, "New York low taken", "{{ticker}}: price took the New York low")
alertcondition(kzOk and lonOn and inLon and not inLon[1], "London killzone open", "{{ticker}}: London killzone opened")
alertcondition(kzOk and nyOn and inNy and not inNy[1], "New York killzone open", "{{ticker}}: New York killzone opened")
alertcondition(sbStart, "Silver Bullet hour open", "{{ticker}}: a Silver Bullet hour opened")

// ===========================================================================
// Signals handed to the stats block: the first close of the day above the
// previous day's high (long) or below its low (short). Intraday charts only;
// on daily and higher the levels have no meaning and nothing is counted.
// ===========================================================================
var bool pdUpDone = false
var bool pdDnDone = false
if newDay
    pdUpDone := false
    pdDnDone := false
bool sigLong  = tfIntra and not na(pdh) and not pdUpDone and close > pdh and close[1] <= pdh and not newDay
bool sigShort = tfIntra and not na(pdl) and not pdDnDone and close < pdl and close[1] >= pdl and not newDay
if sigLong
    pdUpDone := true
if sigShort
    pdDnDone := true

// ===========================================================================
// Quanty Stats - paste from here to the end into the host script
// ===========================================================================
const string G_ST = "8. Quanty Stats"
bool  stOn     = input.bool(true, "Stats table", group=G_ST,
     tooltip="Measures this script's own past signals on this chart. History, not a forecast.")
int   stK      = input.int(10, "Bars ahead (K)", minval=1, maxval=200, group=G_ST)
float stX      = input.float(1.0, "Move threshold (X)", minval=0.05, maxval=50.0, step=0.05, group=G_ST, inline="x",
     tooltip="A signal counts as reached when price moves at least this much in the signal's direction within K bars. In ATR units the test means the same thing on a 15m memecoin chart and a daily BTC chart; in percent it does not.")
string stUnit  = input.string("ATR", "", options=["ATR", "%"], group=G_ST, inline="x")
int   stAtrLen = input.int(14, "ATR length for the threshold", minval=1, maxval=200, group=G_ST)
int   stN      = input.int(50, "Signals measured (last N)", minval=5, maxval=500, group=G_ST)
bool  stVolOn  = input.bool(true, "Split by volume confirmation", group=G_ST)
float stVolMin = input.float(2.0, "Volume confirmation (x baseline)", minval=1.0, maxval=50.0, step=0.5, group=G_ST)
int   stVolLen = input.int(50, "Volume baseline (bars)", minval=5, maxval=1000, group=G_ST,
     tooltip="Baseline is the average volume of the bars before the signal bar. The percentile column ranks the signal bar's volume against the same window.")
string stPos   = input.string("Bottom right", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=G_ST)

// --- Relative volume module (also usable on its own by the host script) ---
// ratio: this bar's volume against the average of the previous stVolLen bars.
// pct:   the share of the previous stVolLen bars with volume at or below this one.
float stVolBase = ta.sma(volume[1], stVolLen)
float stVolRatio = not na(stVolBase) and stVolBase > 0 ? volume / stVolBase : na
float stVolPct   = ta.percentrank(volume, stVolLen)
bool  stVolOk    = not na(stVolRatio) and stVolRatio >= stVolMin

// --- Outcome of the signal that fired K bars ago (its K bars are now closed) ---
bool  stSigL = sigLong[stK]
bool  stSigS = sigShort[stK]
float stEntry = close[stK]
float stHi = ta.highest(high, stK)   // bars signal+1 .. signal+K
float stLo = ta.lowest(low, stK)
// Moves are kept in percent of the entry price; the threshold is converted to
// percent on the signal bar when it is given in ATR units.
float stAtrPct = ta.atr(stAtrLen) / close * 100.0
float stThr  = stUnit == "ATR" ? stX * stAtrPct[stK] : stX
float stPeak = stSigL ? (stHi / stEntry - 1.0) * 100.0 : stSigS ? (1.0 - stLo / stEntry) * 100.0 : na
float stEnd  = stSigL ? (close / stEntry - 1.0) * 100.0 : stSigS ? (1.0 - close / stEntry) * 100.0 : na
bool  stVolAtSig = stVolOk[stK]

// --- Baseline: the same test on every bar, in a random direction ---
// Gives the number a yardstick. On a volatile coin almost any bar moves 1% in
// 10 bars; the signal only says something if it beats this row.
int   stBaseLen = input.int(500, "Baseline window (bars)", minval=50, maxval=2000, group=G_ST,
     tooltip="Share of all recent bars after which price moved at least the threshold up, averaged with the share that moved at least the threshold down. What a coin toss would have scored.")
bool  stBaseUp = not na(stEntry) and stEntry > 0 and not na(stThr) and (stHi / stEntry - 1.0) * 100.0 >= stThr
bool  stBaseDn = not na(stEntry) and stEntry > 0 and not na(stThr) and (1.0 - stLo / stEntry) * 100.0 >= stThr
float stBase   = ta.sma((stBaseUp ? 0.5 : 0.0) + (stBaseDn ? 0.5 : 0.0), stBaseLen)

var array<float> stPeaks  = array.new<float>()
var array<float> stEnds   = array.new<float>()
var array<int>   stHits   = array.new<int>()
var array<int>   stVols   = array.new<int>()

if stOn and barstate.isconfirmed and (stSigL or stSigS) and not na(stEntry) and stEntry > 0 and not na(stPeak) and not na(stThr)
    stPeaks.push(stPeak)
    stEnds.push(stEnd)
    stHits.push(stPeak >= stThr ? 1 : 0)
    stVols.push(stVolAtSig ? 1 : 0)
    if stPeaks.size() > stN
        stPeaks.shift()
        stEnds.shift()
        stHits.shift()
        stVols.shift()

// Signals fired in the last K bars are still open: counted as pending, not measured.
int stPending = 0
for i = 0 to stK - 1
    if sigLong[i] or sigShort[i]
        stPending += 1

f_stFrac(int hits, int n) =>
    n == 0 ? "0/0" : str.tostring(hits) + "/" + str.tostring(n) + " (" + str.tostring(math.round(100.0 * hits / n)) + "%)"

f_stPct(float v) =>
    na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

f_stPos(string p) =>
    p == "Top left" ? position.top_left : p == "Bottom right" ? position.bottom_right : p == "Bottom left" ? position.bottom_left : position.top_right

var table stT = table.new(f_stPos(stPos), 2, 9, bgcolor=#10171E, frame_color=#202B35, frame_width=1, border_color=#202B35, border_width=1)
if stOn and barstate.islast
    int n = stHits.size()
    int hits = n > 0 ? int(stHits.sum()) : 0
    int nV = 0
    int hV = 0
    if n > 0
        for i = 0 to n - 1
            if stVols.get(i) == 1
                nV += 1
                hV += stHits.get(i)
    string thr = (stUnit == "ATR" ? str.tostring(stX, "#.##") + " ATR" : str.tostring(stX, "#.##") + "%") + " within " + str.tostring(stK) + " bars"
    table.cell(stT, 0, 0, "Quanty Stats", text_color=#65E1C6, text_size=size.small, text_halign=text.align_left)
    table.cell(stT, 1, 0, "last " + str.tostring(stN) + " signals", text_color=#707C8A, text_size=size.small, text_halign=text.align_right)
    table.cell(stT, 0, 1, "Signals measured", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(stT, 1, 1, str.tostring(n) + (stPending > 0 ? " (" + str.tostring(stPending) + " pending)" : ""), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    table.cell(stT, 0, 2, "Moved at least " + thr, text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(stT, 1, 2, f_stFrac(hits, n), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    table.cell(stT, 0, 3, "Any bar, same test (last " + str.tostring(stBaseLen) + ")", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(stT, 1, 3, na(stBase) ? "-" : str.tostring(math.round(100.0 * stBase)) + "%", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    table.cell(stT, 0, 4, "Median peak move", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(stT, 1, 4, n > 0 ? f_stPct(stPeaks.median()) : "-", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    table.cell(stT, 0, 5, "Median move at bar " + str.tostring(stK), text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(stT, 1, 5, n > 0 ? f_stPct(stEnds.median()) : "-", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    if stVolOn
        table.cell(stT, 0, 6, "With volume >= " + str.tostring(stVolMin, "#.#") + "x", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 6, f_stFrac(hV, nV), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 7, "Without", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 7, f_stFrac(hits - hV, n - nV), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    else
        table.cell(stT, 0, 6, "", text_size=size.tiny)
        table.cell(stT, 1, 6, "", text_size=size.tiny)
        table.cell(stT, 0, 7, "", text_size=size.tiny)
        table.cell(stT, 1, 7, "", text_size=size.tiny)
    table.cell(stT, 0, 8, "History on this chart, not a forecast", text_color=#707C8A, text_size=size.tiny, text_halign=text.align_left)
    table.cell(stT, 1, 8, "", text_size=size.tiny)
````
