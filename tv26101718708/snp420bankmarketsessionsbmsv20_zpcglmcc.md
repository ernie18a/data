# SNP420:Bank_Market_Sessions(BMS)_v2.0

- url: https://www.tradingview.com/script/ZpcglMcc-SNP420-Bank-Market-Sessions-BMS-v2-0/
- type: indicator
- pine_id: PUB;d364b825f39641f9aade8e218c97f119
- version: 1.0

## Description

Bank Market Sessions (BMS)

What it does
BMS marks the low of each major trading session (Tokyo, London and New York, with Sydney as an optional fourth session) with a single dashed line on the price chart. The name of the session is printed in the middle of its line. The goal is to keep the chart clean: instead of colored boxes or background shading, you see only the price level where each session found its low, together with the time span of that session. If you prefer session highs, one setting switches all lines from the low to the high.

How it works
For every enabled session, the script checks on each bar whether the bar falls inside the session window defined by its time and time zone. When the first bar of a session appears, a line is created that starts at that bar and ends at the scheduled end of the session. While the session is open, the line moves down every time price makes a new low within the session (or up to every new high if the High mode is selected), so the line always shows the lowest price reached so far. When the session ends, the line stays at its final value and becomes a reference level for the rest of the day.

Each session has its own time zone (Asia/Tokyo, Europe/London, America/New_York and Australia/Sydney by default). Session times are entered in the local time of each market, so they follow daylight saving time changes automatically instead of staying fixed in GMT. Default times are Tokyo 09:00-18:00, London 08:00-17:00, New York 08:00-17:00 and Sydney 07:00-16:00.

An optional setting, "Extend the last finished level until price breaks it", keeps the level of the most recent finished session extending to the right until price trades through it. This shows at a glance which session lows are still intact and which have already been taken out.

The script can also send alerts when a session starts, when it ends, and when price breaks the low (or high) of the last finished session.

How to use it
Add the script to an intraday chart, for example 5 minutes to 1 hour, of a forex pair or any other symbol that trades across the sessions. Adjust the session names, times, time zones and colors in the settings if your definition of the sessions differs from the defaults. The lines can be used as reference levels: for example, to see whether London has taken out the Tokyo low, or whether New York is holding above the London low. To receive alerts, create an alert on the script and choose "Any alert() function call".

Settings
Session 1-4: on/off, name, color, session time and time zone.
Line level: Low or High.
Line style, line width, name size and whether the name is shown.
Sessions kept per market: how many past sessions stay on the chart.
Extend the last finished level until price breaks it.

Originality
The script is written from scratch. Its minimalist session-line look was inspired by the open-source script "FX Market Sessions" by boitoki, and credit for that visual idea goes to its author. No code from that script is used. What BMS adds is a single-level view of each session, per-market time zones that follow daylight saving time automatically, the option to extend the last session level until it is broken, and alerts for breaks of that level.

Limitations
The script works only on intraday timeframes and draws nothing on daily and higher timeframes.
The low or high of the session that is currently open changes in real time until the session ends. Only finished sessions have a final level.
The right end of each line is drawn at the scheduled session end in advance, so during an open session the line extends into the future.
Session detection depends on the bars of your chart. On higher intraday timeframes, such as 4 hours, a session can start or end in the middle of a bar, and the whole bar is then counted as part of the session, so the level and timing are approximate. Lower timeframes give more precise results.
If the chart history starts in the middle of a session, the first session on the chart is incomplete.
Levels are based on the price data of the chart's symbol and broker feed, so different feeds can show slightly different session lows and highs.
The extend option and the break alert follow only the most recent finished session of each market. Older levels are not tracked.
A break is detected when the bar's low (or high) trades beyond the level, so a wick through the level counts as a break.
For a session that crosses midnight, the scheduled end can be off by one hour on the day of a daylight saving time change.
The script shows historical price levels only. It does not predict price movement and is not a trading signal on its own.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) SNP420
// Author: SNP420
// Company: Finexus s.r.o.
// Original code. The minimalist session-line look was inspired by the open-source "FX Market Sessions" by boitoki (no code reused).

//@version=6
indicator("SNP420:Bank_Market_Sessions(BMS)", "SNP420:Bank_Market_Sessions(BMS)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ---------- Inputs ----------
G1 = "Session 1"
G2 = "Session 2"
G3 = "Session 3"
G4 = "Session 4"
GS = "Style"
GL = "Levels"

s1On  = input.bool(true, "", inline = "a", group = G1, display = display.none)
s1Nm  = input.string("Tokyo", "", inline = "a", group = G1, display = display.none)
s1Col = input.color(color.rgb(51, 255, 0), "", inline = "a", group = G1, display = display.none)
s1Ses = input.session("0900-1800", "Time", inline = "b", group = G1, display = display.none)
s1Tz  = input.string("Asia/Tokyo", "", options = ["UTC", "Europe/London", "Europe/Berlin", "Europe/Prague", "America/New_York", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], inline = "b", group = G1, display = display.none)

s2On  = input.bool(true, "", inline = "a", group = G2, display = display.none)
s2Nm  = input.string("London", "", inline = "a", group = G2, display = display.none)
s2Col = input.color(#FFFF00, "", inline = "a", group = G2, display = display.none)
s2Ses = input.session("0800-1700", "Time", inline = "b", group = G2, display = display.none)
s2Tz  = input.string("Europe/London", "", options = ["UTC", "Europe/London", "Europe/Berlin", "Europe/Prague", "America/New_York", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], inline = "b", group = G2, display = display.none)

s3On  = input.bool(true, "", inline = "a", group = G3, display = display.none)
s3Nm  = input.string("New York", "", inline = "a", group = G3, display = display.none)
s3Col = input.color(color.rgb(255, 0, 0), "", inline = "a", group = G3, display = display.none)
s3Ses = input.session("0800-1700", "Time", inline = "b", group = G3, display = display.none)
s3Tz  = input.string("America/New_York", "", options = ["UTC", "Europe/London", "Europe/Berlin", "Europe/Prague", "America/New_York", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], inline = "b", group = G3, display = display.none)

s4On  = input.bool(false, "", inline = "a", group = G4, display = display.none)
s4Nm  = input.string("Sydney", "", inline = "a", group = G4, display = display.none)
s4Col = input.color(#FFFF00, "", inline = "a", group = G4, display = display.none)
s4Ses = input.session("0700-1600", "Time", inline = "b", group = G4, display = display.none)
s4Tz  = input.string("Australia/Sydney", "", options = ["UTC", "Europe/London", "Europe/Berlin", "Europe/Prague", "America/New_York", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"], inline = "b", group = G4, display = display.none)

lvlMode = input.string("Low", "Line level", options = ["Low", "High"], group = GS, display = display.none)
lnStyle = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = GS, display = display.none)
lnWidth = input.int(1, "Line width", minval = 1, maxval = 4, group = GS, display = display.none)
lbShow  = input.bool(true, "Show session name", group = GS, display = display.none)
lbSize  = input.string("Small", "Name size", options = ["Tiny", "Small", "Normal", "Large"], group = GS, display = display.none)
history = input.int(10, "Sessions kept per market", minval = 1, maxval = 100, group = GS, display = display.none)
extendOn = input.bool(false, "Extend the last finished level until price breaks it", group = GL, display = display.none)

// ---------- Constants ----------
NONE     = color.new(color.black, 100)
USE_HIGH = lvlMode == "High"
LN_STYLE = lnStyle == "Solid" ? line.style_solid : lnStyle == "Dotted" ? line.style_dotted : line.style_dashed
LB_SIZE  = switch lbSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

// ---------- Session object ----------
type Sess
    string       name
    string       sess
    string       tz
    color        col
    array<line>  lines
    array<label> labels
    bool         wasIn  = false
    int          x1
    int          xEnd
    float        lvl
    line         ln
    label        lb
    line         lastLn
    float        lastLvl
    bool         broken = true

// Session end as a timestamp (handles sessions crossing midnight)
f_endTime(string sess, string tz) =>
    eH = int(str.tonumber(str.substring(sess, 5, 7)))
    eM = int(str.tonumber(str.substring(sess, 7, 9)))
    t  = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), eH, eM)
    t <= time ? t + 86400000 : t

// Session finished: its final level becomes the level to watch
method finish(Sess s) =>
    s.lastLn  := s.ln
    s.lastLvl := s.lvl
    s.broken  := false
    alert(s.name + " session ended", alert.freq_once_per_bar)

method step(Sess s, bool inS) =>
    if inS and (not s.wasIn or time >= s.xEnd)
        if s.wasIn
            s.finish()

        s.x1   := time
        s.xEnd := f_endTime(s.sess, s.tz)
        s.lvl  := USE_HIGH ? high : low
        s.ln   := line.new(s.x1, s.lvl, s.xEnd, s.lvl, xloc = xloc.bar_time, color = s.col, style = LN_STYLE, width = lnWidth)
        s.lb   := label.new(math.round((s.x1 + s.xEnd) / 2), s.lvl, lbShow ? s.name : "", xloc = xloc.bar_time, color = lbShow ? chart.bg_color : NONE, textcolor = s.col, style = label.style_label_center, size = LB_SIZE, text_formatting = text.format_bold)

        s.lines.push(s.ln)
        s.labels.push(s.lb)
        if s.lines.size() > history
            s.lines.shift().delete()
            s.labels.shift().delete()

        alert(s.name + " session started", alert.freq_once_per_bar)

    else if inS
        newLvl = USE_HIGH ? math.max(s.lvl, high) : math.min(s.lvl, low)
        if newLvl != s.lvl
            s.lvl := newLvl
            s.ln.set_y1(newLvl)
            s.ln.set_y2(newLvl)
            s.lb.set_y(newLvl)

    else if s.wasIn
        s.finish()

    // Watch the last finished level until price trades through it
    if not inS and not s.broken
        if extendOn
            s.lastLn.set_x2(math.max(time, s.xEnd))
        hit = USE_HIGH ? high > s.lastLvl : low < s.lastLvl
        if hit
            s.broken := true
            alert(s.name + (USE_HIGH ? " high " : " low ") + str.tostring(s.lastLvl, format.mintick) + " broken", alert.freq_once_per_bar)

    s.wasIn := inS

// ---------- Run ----------
var Sess sA = Sess.new(s1Nm, s1Ses, s1Tz, s1Col, array.new<line>(), array.new<label>())
var Sess sB = Sess.new(s2Nm, s2Ses, s2Tz, s2Col, array.new<line>(), array.new<label>())
var Sess sC = Sess.new(s3Nm, s3Ses, s3Tz, s3Col, array.new<line>(), array.new<label>())
var Sess sD = Sess.new(s4Nm, s4Ses, s4Tz, s4Col, array.new<line>(), array.new<label>())

in1 = timeframe.isintraday and not na(time(timeframe.period, s1Ses, s1Tz))
in2 = timeframe.isintraday and not na(time(timeframe.period, s2Ses, s2Tz))
in3 = timeframe.isintraday and not na(time(timeframe.period, s3Ses, s3Tz))
in4 = timeframe.isintraday and not na(time(timeframe.period, s4Ses, s4Tz))

sA.step(s1On and in1)
sB.step(s2On and in2)
sC.step(s3On and in3)
sD.step(s4On and in4)
````
