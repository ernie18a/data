# Confirmed Close Intraday

- url: https://www.tradingview.com/script/OEc3hRh4-Confirmed-Close-Intraday/
- type: indicator
- pine_id: PUB;8e41e6740dc74aeebcaaf85e99e3e75b
- version: 2.0

## Description

WHAT THIS IS

Confirmed Close Intraday is a context map for the 1 hour chart. It does not give buy or sell signals. It shows you where you are in the trading day and what the bigger timeframes are doing, so the decisions you make on the 1H are made with the full picture in view.

On one chart you get:
- The Asia, London and New York sessions as boxes, each in its own local time.
- The Asia range carried through the day, with a mark when London or New York closes through it or sweeps it.
- The 4H and daily trend, and a background tint when they agree.
- The CME weekend gap, kept on the chart until it is filled.
- The daily open, the previous day's high and low, optional weekly levels, and VWAP.
- The hours of the day that have historically been strong or weak.
- A dashboard that sums it all up, including a countdown to the next session open.

It was built for crypto, where the market never closes but the traders who move it still work in sessions.


WHY THERE ARE NO SIGNALS

Before building this, I tested three common 1 hour setups on BTC, ETH and SOL from January 2024 onward: a trend pullback, an Asia range breakout at the London and New York opens, and a volatility squeeze breakout. After realistic fees none of them held up in both halves of the data on all three coins. Printing Buy and Sell labels for them would have been dishonest.

What the 1H does offer is structure: sessions, ranges, opens and the bigger trend. That is what this script shows.


WHY CONFIRMED CLOSE

Everything that marks an event is decided on a closed candle. A break or sweep mark that prints stays printed, and an alert set to "Once Per Bar Close" fires once, at the close.

The 4H and daily trend are read from the last CLOSED 4H and daily candle, never from the one that is still forming. The previous day and week levels work the same way. The daily and weekly open are fixed the moment the period starts, so they do not move either.

Session boxes do grow while a session is running. That is the point of them: the box shows the range so far, and it is final when the session ends.


HOW TO READ THE CHART

Sessions
- Asia (blue): Tokyo, 09:00 to 15:00 Tokyo time.
- London (orange): 08:00 to 16:30 London time.
- New York (purple): 09:30 to 16:00 New York time, the US stock market hours. This is when ETF flows and US macro news hit crypto.
Each session is set in its own timezone, so summer and winter time changes are handled for you. Sessions are drawn on weekdays only.

The Asia range
The overnight range is the level the European and American sessions trade against. Its high and low are extended through the rest of the day as dashed lines.
- "AH" with a small triangle: the first 1H candle of the day that CLOSED above the Asia high during London or New York.
- "AL": the same for a close below the Asia low.
- A small cross: a sweep. The candle traded beyond the Asia high or low but closed back inside. Sweeps often mark a failed break.
Each of these prints at most once per side per day.

Trend tint
A faint green background means the 4H and the daily trend are both up. Faint red means both are down. No tint means they disagree. The trend is a Supertrend (ATR 10, multiplier 3) read on those timeframes.

Hours of the day
Thin vertical shading marks hours in UTC. Green covers 21:00 to 23:00 UTC. Red marks 13:00 and 23:00 UTC. On Binance 1H data for BTC, ETH and SOL, these hours leaned the same way in 2024 and again from 2025 to September 2026. The effect is a few basis points on average. That is too small to trade on its own after fees, so treat it as a timing preference, not a signal. Both windows can be changed in the settings.

Levels
- Daily open: 00:00 UTC, the open of the crypto daily candle.
- Previous day high and low.
- Weekly open and previous week high and low (off by default).

VWAP
A volume weighted average price that resets each day by default. You can anchor it to the week or to the New York open instead, and add 1 and 2 standard deviation bands.

CME weekend gap
CME bitcoin futures close on Friday at 16:00 and reopen on Sunday at 17:00 Chicago time, while spot crypto keeps trading. Many traders watch the price at those two moments. The script marks the zone between the chart's price at the Friday close and at the Sunday reopen, and keeps it on the chart until price trades back through the Friday close. It is then labelled as filled. The prices come from the chart you are on, so they are a spot approximation of the futures gap, not the futures prices themselves.

Dashboard
Bottom right by default:
- 4H trend and daily trend, and whether they are aligned.
- The session running now, or "Between sessions".
- The next session to open and how long until it does.
- Where price sits against the Asia range, VWAP and the daily open.
- Whether the current hour is in a strong or weak window.


HOW TO USE IT

A few ways people use a map like this:
1. Trade in the direction of the tint. When the 4H and daily agree, a break of the Asia range in that direction has the bigger picture behind it.
2. Treat a sweep of the Asia high or low against the trend as a warning that the break may fail.
3. Use the daily open and VWAP as a quick read on who is in control today: above both is strong, below both is weak.
4. Know where the unfilled CME gap sits. It is a level many traders watch.
5. Be patient in the red hours and around session changes.

None of this is a rule. It is context for your own decisions.

Alerts
After adding the script, open Create Alert and choose Confirmed Close Intraday as the condition. Available conditions:
- Asia open, London open, New York open.
- Asia high broken, Asia low broken.
- Asia high swept, Asia low swept.
- 4H trend changed, Daily trend changed.
- 4H and daily aligned up, 4H and daily aligned down.
- CME gap filled.
Use "Once Per Bar Close". TradingView stores the settings when an alert is created, so after changing a setting, delete the alert and create it again.


SETTINGS

Sessions
- Asia (Tokyo) (on, 09:00 to 15:00 Tokyo time, Monday to Friday).
- London (on, 08:00 to 16:30 London time).
- New York (on, 09:30 to 16:00 New York time).
- Each session has its own colour.
- Session names (on): the name in the top left corner of each box.
- Extend the Asia high and low through the day (on).
- Extend London and New York high and low (off): turn on to carry those ranges forward as well.
- Sessions to keep on the chart (5 of each).

Asia range
- Mark the first close through the Asia range (on).
- Mark sweeps of the Asia range (on).

Trend (4H and daily)
- ATR period (10) and Multiplier (3.0): the Supertrend used on both timeframes.
- Tint background when 4H and daily agree (on).

Levels
- Daily open (on), Previous day high/low (on), Weekly open (off), Previous week high/low (off).

VWAP
- Show VWAP (on).
- Anchor (Day): Day, Week or New York open.
- 1 stdev band (off), 2 stdev band (off).

CME weekend gap
- Show weekend gap (on).
- Unfilled gaps to keep (4).

Hours of the day (UTC)
- Shade hour windows (on).
- Historically strong hours (21:00 to 23:00).
- Historically weak hours (13:00 to 14:00 and 23:00 to 00:00).

Dashboard
- Show dashboard (on), Position (Bottom right), Text size (Small).

Colours
- Up, Down and Levels colours.

The sessions, ranges and gap are drawn on intraday charts of 1 hour or lower. On higher timeframes they are hidden, because a 4H candle cannot tell you when a session started.


CREDIT

The trend is the Supertrend method (Olivier Seban). VWAP and the session and range concepts are standard market tools. The code, the confirmed close handling, the weekend gap tracking and the hour of day research behind the default windows are original to this script. It is a companion to my Confirmed Close Flow, which is built for 4H swing signals.


LIMITATIONS

- This script does not tell you when to buy or sell.
- Session times are fixed windows. Liquidity does not switch on and off at the exact minute.
- The weekend gap uses the chart's own prices, not CME futures prices, so it approximates the real futures gap.
- The hour of day windows describe the past on three coins. They can weaken or disappear.
- A 1H candle can move far between the moment a level breaks and the close that confirms it.
- This is a charting tool for education and analysis. It is not financial advice and it does not place trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnTRW

//@version=6
// Confirmed Close Intraday
// A context map for the 1H chart: the 4H and daily trend, the Asia, London and New York
// sessions, the Asia range and what London and New York do with it, the New York opening
// range, the CME weekend gap, key opens and highs/lows, VWAP and the hours of the day.
// No buy or sell signals.
// Everything that marks an event is decided on a CLOSED bar.
indicator("Confirmed Close Intraday", shorttitle = "CC Intraday", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ============================================================ INPUTS
const string G_SE = "Sessions (local exchange time, daylight saving handled)"
showAs  = input.bool(true, "Asia (Tokyo)", inline = "as", group = G_SE)
sesAs   = input.session("0900-1500:23456", "", inline = "as", group = G_SE)
colAs   = input.color(#4fc3f7, "", inline = "as", group = G_SE)
showLo  = input.bool(true, "London", inline = "lo", group = G_SE)
sesLo   = input.session("0800-1630:23456", "", inline = "lo", group = G_SE)
colLo   = input.color(#ffb74d, "", inline = "lo", group = G_SE)
showNy  = input.bool(true, "New York", inline = "ny", group = G_SE)
sesNy   = input.session("0930-1600:23456", "", inline = "ny", group = G_SE)
colNy   = input.color(#ba68c8, "", inline = "ny", group = G_SE)
showSL  = input.bool(true, "Session names", group = G_SE)
extAs   = input.bool(true, "Extend the Asia high and low through the day", group = G_SE)
extOth  = input.bool(false, "Extend London and New York high and low", group = G_SE)
keepN   = input.int(5, "Sessions to keep on the chart (each)", minval = 1, maxval = 60, group = G_SE)

const string G_AR = "Asia range"
showBrk = input.bool(true, "Mark the first close through the Asia range", group = G_AR, tooltip = "During London and New York only, once per side per day, on a closed bar. A break of the overnight range is information, not a signal.")
showSwp = input.bool(true, "Mark sweeps of the Asia range", group = G_AR, tooltip = "The bar trades beyond the Asia high or low but closes back inside. Once per side per day.")

const string G_OR = "New York opening range"
showOR  = input.bool(true, "Show the New York opening range", group = G_OR, tooltip = "The high and low of the first minutes after the New York open, built from 15 minute bars so the range is exact on the 1H chart. Tested on BTC, ETH and SOL since 2021: a break of this range has leaned toward continuing into the New York close, but the effect is smaller than typical taker fees and has weakened since 2024. Context, not a signal.")
orMin   = input.int(30, "Range length (minutes)", options = [15, 30, 60], group = G_OR)
showORB = input.bool(true, "Mark the first close through the range", group = G_OR, tooltip = "Once per day, within 3 hours of the New York open, decided on a closed 15 minute bar and shown when the chart bar closes.")
orExt   = input.bool(true, "Extend the range to the New York close", group = G_OR)

const string G_TR = "Trend (4H and daily)"
stLen   = input.int(10, "ATR period", minval = 1, group = G_TR)
stMult  = input.float(3.0, "Multiplier", minval = 0.1, step = 0.1, group = G_TR)
showTnt = input.bool(true, "Tint background when 4H and daily agree", group = G_TR)

const string G_LV = "Levels"
showDO  = input.bool(true, "Daily open (00:00 UTC)", group = G_LV)
showPD  = input.bool(true, "Previous day high/low", group = G_LV)
showWO  = input.bool(false, "Weekly open", group = G_LV)
showPW  = input.bool(false, "Previous week high/low", group = G_LV)

const string G_VW = "VWAP"
showVW  = input.bool(true, "Show VWAP", group = G_VW)
vwAnc   = input.string("Day", "Anchor", options = ["Day", "Week", "New York open"], group = G_VW)
showB1  = input.bool(false, "1 stdev band", group = G_VW)
showB2  = input.bool(false, "2 stdev band", group = G_VW)

const string G_GP = "CME weekend gap"
showGap = input.bool(true, "Show weekend gap", group = G_GP, tooltip = "CME bitcoin futures close Friday 16:00 and reopen Sunday 17:00 Chicago time. The zone between the chart's price at those two moments stays until price trades back through the Friday close.")
keepGap = input.int(4, "Unfilled gaps to keep", minval = 1, maxval = 20, group = G_GP)

const string G_HR = "Hours of the day (UTC)"
showHr  = input.bool(true, "Shade hour windows", group = G_HR)
hrGood  = input.session("2100-2300", "Historically strong hours", group = G_HR)
hrBad   = input.session("1300-1400,2300-0000", "Historically weak hours", group = G_HR)

const string G_DB = "Dashboard"
showTbl = input.bool(true, "Show dashboard", group = G_DB)
tblPos  = input.string("Bottom right", "Position", options = ["Bottom right", "Bottom left", "Top right", "Top left", "Middle right"], group = G_DB)
tblTxt  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = G_DB)

const string G_CO = "Colours"
bullCol = input.color(#26a69a, "Up", group = G_CO)
bearCol = input.color(#ef5350, "Down", group = G_CO)
lvlCol  = input.color(#9598a1, "Levels", group = G_CO)

// ============================================================ COMMON
const string TZ_AS = "Asia/Tokyo"
const string TZ_LO = "Europe/London"
const string TZ_NY = "America/New_York"
const string TZ_CM = "America/Chicago"
conf  = barstate.isconfirmed
tfOk  = timeframe.isintraday and timeframe.in_seconds() <= 3600
clear = #00000000

// ============================================================ SESSIONS
f_session(string ses, string tz, color col, bool show, string name, bool ext) =>
    bool inS = not na(time(timeframe.period, ses, tz))
    bool start = inS and not inS[1]
    bool stop = not inS and inS[1]
    var float hi = na
    var float lo = na
    var box bx = na
    var line lh = na
    var line ll = na
    var array<box> boxes = array.new<box>()
    var array<line> lines = array.new<line>()
    bool drawIt = show and tfOk
    if start
        hi := high
        lo := low
        lh := na
        ll := na
        if drawIt
            bx := box.new(bar_index, high, bar_index, low, border_color = color.new(col, 40), border_style = line.style_dotted, bgcolor = color.new(col, 90), text = showSL ? name : "", text_color = color.new(col, 10), text_size = size.small, text_halign = text.align_left, text_valign = text.align_top)
            boxes.push(bx)
            if boxes.size() > keepN
                box.delete(boxes.shift())
    else if inS
        hi := math.max(hi, high)
        lo := math.min(lo, low)
        if drawIt and not na(bx)
            bx.set_right(bar_index)
            bx.set_top(hi)
            bx.set_bottom(lo)
    if stop and drawIt and ext and not na(hi)
        lh := line.new(bar_index - 1, hi, bar_index, hi, color = color.new(col, 30), style = line.style_dashed)
        ll := line.new(bar_index - 1, lo, bar_index, lo, color = color.new(col, 30), style = line.style_dashed)
        lines.push(lh)
        lines.push(ll)
        while lines.size() > 2 * keepN
            line.delete(lines.shift())
    else if not inS and not na(lh)
        lh.set_x2(bar_index)
        ll.set_x2(bar_index)
    [inS, start, stop, hi, lo]

[asIn, asStart, asStop, asHi, asLo] = f_session(sesAs, TZ_AS, colAs, showAs, "Asia", extAs)
[loIn, loStart, loStop, loHi, loLo] = f_session(sesLo, TZ_LO, colLo, showLo, "London", extOth)
[nyIn, nyStart, nyStop, nyHi, nyLo] = f_session(sesNy, TZ_NY, colNy, showNy, "New York", extOth)

// ============================================================ ASIA RANGE: BREAKS AND SWEEPS
var float aHi = na
var float aLo = na
var bool brkUpDone = false
var bool brkDnDone = false
var bool swpUpDone = false
var bool swpDnDone = false
if asStart
    aHi := na
    aLo := na
    brkUpDone := false
    brkDnDone := false
    swpUpDone := false
    swpDnDone := false
if asStop
    aHi := asHi
    aLo := asLo

tradeWin = (loIn or nyIn) and not asIn and not na(aHi)
brkUp = conf and tradeWin and not brkUpDone and close > aHi
brkDn = conf and tradeWin and not brkDnDone and close < aLo
swpUp = conf and tradeWin and not swpUpDone and not brkUp and high > aHi and close < aHi
swpDn = conf and tradeWin and not swpDnDone and not brkDn and low < aLo and close > aLo
if brkUp
    brkUpDone := true
if brkDn
    brkDnDone := true
if swpUp
    swpUpDone := true
if swpDn
    swpDnDone := true

plotshape(showBrk and tfOk and brkUp, "Asia high broken", shape.triangleup, location.belowbar, colAs, size = size.tiny, text = "AH", textcolor = colAs)
plotshape(showBrk and tfOk and brkDn, "Asia low broken", shape.triangledown, location.abovebar, colAs, size = size.tiny, text = "AL", textcolor = colAs)
plotshape(showSwp and tfOk and swpUp, "Asia high swept", shape.xcross, location.abovebar, colAs, size = size.tiny)
plotshape(showSwp and tfOk and swpDn, "Asia low swept", shape.xcross, location.belowbar, colAs, size = size.tiny)

// ============================================================ NEW YORK OPENING RANGE
// Built from 15 minute bars (or the chart's own bars below 15 minutes). Every value inside a
// closed chart bar is final, and the break mark is only shown once the chart bar has closed.
ltf    = timeframe.in_seconds() <= 900 ? timeframe.period : "15"
ltfMs  = timeframe.in_seconds(ltf) * 1000
tA = request.security_lower_tf(syminfo.tickerid, ltf, time)
hA = request.security_lower_tf(syminfo.tickerid, ltf, high)
lA = request.security_lower_tf(syminfo.tickerid, ltf, low)
cA = request.security_lower_tf(syminfo.tickerid, ltf, close)
nyOH = int(str.tonumber(str.substring(sesNy, 0, 2)))
nyOM = int(str.tonumber(str.substring(sesNy, 2, 4)))
nyEH = int(str.tonumber(str.substring(sesNy, 5, 7)))
nyEM = int(str.tonumber(str.substring(sesNy, 7, 9)))

var float orHi = na
var float orLo = na
var int orS = na
var int orE = na
var int orEnd = na
var bool orDone = false
var bool orBrkDone = false
var float orLastC = na
var box orBox = na
var array<box> orBoxes = array.new<box>()
var array<line> orLines = array.new<line>()
bool orNew = false
bool orFormed = false
bool orUpRaw = false
bool orDnRaw = false
int nA = tA.size()
if nA > 0
    for i = 0 to nA - 1
        int ti = tA.get(i)
        int s = timestamp(TZ_NY, year(ti, TZ_NY), month(ti, TZ_NY), dayofmonth(ti, TZ_NY), nyOH, nyOM, 0)
        int dw = dayofweek(ti, TZ_NY)
        bool wkd = dw != dayofweek.saturday and dw != dayofweek.sunday
        if wkd and ti >= s and ti < s + orMin * 60000
            if na(orS) or s != orS
                orS := s
                orE := s + orMin * 60000
                orEnd := timestamp(TZ_NY, year(ti, TZ_NY), month(ti, TZ_NY), dayofmonth(ti, TZ_NY), nyEH, nyEM, 0)
                orHi := hA.get(i)
                orLo := lA.get(i)
                orDone := false
                orBrkDone := false
                orNew := true
            else
                orHi := math.max(orHi, hA.get(i))
                orLo := math.min(orLo, lA.get(i))
            if ti + ltfMs >= orE
                orDone := true
                orFormed := true
        else if orDone and not orBrkDone and not na(orS) and ti >= orE and ti < orS + 3 * 3600000 and not na(orLastC)
            float ci = cA.get(i)
            if ci > orHi and orLastC <= orHi
                orUpRaw := true
                orBrkDone := true
            else if ci < orLo and orLastC >= orLo
                orDnRaw := true
                orBrkDone := true
        orLastC := cA.get(i)

orDraw = showOR and tfOk
if orNew and orDraw
    orBox := box.new(time, orHi, time_close, orLo, xloc = xloc.bar_time, border_color = color.new(colNy, 20), bgcolor = color.new(colNy, 80), text = showSL ? "NY range" : "", text_color = color.new(colNy, 0), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom)
    orBoxes.push(orBox)
    if orBoxes.size() > keepN
        box.delete(orBoxes.shift())
else if orDraw and not na(orBox) and not na(orS) and time < orE
    orBox.set_right(time_close)
if orDraw and not na(orBox)
    orBox.set_top(orHi)
    orBox.set_bottom(orLo)
if orFormed and orDraw and orExt
    orLines.push(line.new(time_close, orHi, orEnd, orHi, xloc = xloc.bar_time, color = color.new(colNy, 20), style = line.style_dotted))
    orLines.push(line.new(time_close, orLo, orEnd, orLo, xloc = xloc.bar_time, color = color.new(colNy, 20), style = line.style_dotted))
    while orLines.size() > 2 * keepN
        line.delete(orLines.shift())

orUp = conf and orUpRaw
orDn = conf and orDnRaw
plotshape(showORB and orDraw and orUp, "NY range broken up", shape.triangleup, location.belowbar, colNy, size = size.tiny, text = "OR", textcolor = colNy)
plotshape(showORB and orDraw and orDn, "NY range broken down", shape.triangledown, location.abovebar, colNy, size = size.tiny, text = "OR", textcolor = colNy)

// ============================================================ TREND: 4H AND DAILY
// read from the previous CLOSED bar of each timeframe, so it cannot repaint
f_dir() =>
    [_s, _d] = ta.supertrend(stMult, stLen)
    _d[1]
d4 = request.security(syminfo.tickerid, "240", f_dir(), lookahead = barmerge.lookahead_on)
dD = request.security(syminfo.tickerid, "1D", f_dir(), lookahead = barmerge.lookahead_on)
up4 = d4 < 0
upD = dD < 0
alUp = up4 and upD
alDn = not up4 and not upD
bgcolor(showTnt and tfOk ? (alUp ? color.new(bullCol, 95) : alDn ? color.new(bearCol, 95) : na) : na, title = "Trend tint")

// ============================================================ HOURS OF THE DAY
inGood = not na(time(timeframe.period, hrGood, "UTC"))
inBad  = not na(time(timeframe.period, hrBad, "UTC"))
bgcolor(showHr and tfOk ? (inGood ? color.new(bullCol, 90) : inBad ? color.new(bearCol, 92) : na) : na, title = "Hour windows")

// ============================================================ LEVELS
dOpen = request.security(syminfo.tickerid, "1D", open, lookahead = barmerge.lookahead_on)
wOpen = request.security(syminfo.tickerid, "1W", open, lookahead = barmerge.lookahead_on)
[pdh, pdl] = request.security(syminfo.tickerid, "1D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "1W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
newD = timeframe.change("1D")
newW = timeframe.change("1W")
plot(showDO and tfOk and not newD ? dOpen : na, "Daily open", color.new(lvlCol, 0), 1, plot.style_linebr)
plot(showPD and tfOk and not newD ? pdh : na, "Previous day high", color.new(lvlCol, 40), 1, plot.style_linebr)
plot(showPD and tfOk and not newD ? pdl : na, "Previous day low", color.new(lvlCol, 40), 1, plot.style_linebr)
plot(showWO and tfOk and not newW ? wOpen : na, "Weekly open", color.new(lvlCol, 0), 2, plot.style_linebr)
plot(showPW and tfOk and not newW ? pwh : na, "Previous week high", color.new(lvlCol, 20), 2, plot.style_linebr)
plot(showPW and tfOk and not newW ? pwl : na, "Previous week low", color.new(lvlCol, 20), 2, plot.style_linebr)

// ============================================================ VWAP
anc = vwAnc == "Week" ? newW : vwAnc == "New York open" ? nyStart : newD
[vw, vwU1, vwL1] = ta.vwap(hlc3, anc, 1.0)
[vw2, vwU2, vwL2] = ta.vwap(hlc3, anc, 2.0)
plot(showVW and tfOk and not anc ? vw : na, "VWAP", color.new(#ffffff, 20), 1, plot.style_linebr)
plot(showVW and showB1 and tfOk and not anc ? vwU1 : na, "VWAP +1", color.new(#ffffff, 70), 1, plot.style_linebr)
plot(showVW and showB1 and tfOk and not anc ? vwL1 : na, "VWAP -1", color.new(#ffffff, 70), 1, plot.style_linebr)
plot(showVW and showB2 and tfOk and not anc ? vwU2 : na, "VWAP +2", color.new(#ffffff, 60), 1, plot.style_linebr)
plot(showVW and showB2 and tfOk and not anc ? vwL2 : na, "VWAP -2", color.new(#ffffff, 60), 1, plot.style_linebr)

// ============================================================ CME WEEKEND GAP
// Friday close = the chart bar that closes at 16:00 Chicago time on a Friday.
// Sunday open  = the chart bar that opens at 17:00 Chicago time on a Sunday.
friBar = dayofweek(time_close, TZ_CM) == dayofweek.friday and hour(time_close, TZ_CM) == 16 and minute(time_close, TZ_CM) == 0
sunBar = dayofweek(time, TZ_CM) == dayofweek.sunday and hour(time, TZ_CM) == 17 and minute(time, TZ_CM) == 0
var float friClose = na
var int friIdx = na
var array<box> gaps = array.new<box>()
var array<float> gapLvl = array.new<float>()
bool gapFilled = false
if friBar
    friClose := close
    friIdx := bar_index
if sunBar and not na(friClose) and showGap and tfOk and open != friClose
    gaps.push(box.new(friIdx, math.max(open, friClose), bar_index, math.min(open, friClose), border_color = color.new(lvlCol, 30), border_style = line.style_dashed, bgcolor = color.new(lvlCol, 88), text = "CME gap", text_color = lvlCol, text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top))
    gapLvl.push(friClose)
    if gaps.size() > keepGap
        box.delete(gaps.shift())
        gapLvl.shift()
if gaps.size() > 0
    for i = gaps.size() - 1 to 0
        b = gaps.get(i)
        float lvl = gapLvl.get(i)
        if conf and low <= lvl and high >= lvl and bar_index > b.get_left() + 1 and not sunBar
            b.set_right(bar_index)
            b.set_bgcolor(color.new(lvlCol, 95))
            b.set_text("CME gap filled")
            gaps.remove(i)
            gapLvl.remove(i)
            gapFilled := true
        else
            b.set_right(bar_index)

// ============================================================ DASHBOARD
f_minsTo(string ses, string tz) =>
    int hh = int(str.tonumber(str.substring(ses, 0, 2)))
    int mm = int(str.tonumber(str.substring(ses, 2, 4)))
    int t = timestamp(tz, year(timenow, tz), month(timenow, tz), dayofmonth(timenow, tz), hh, mm, 0)
    if t <= timenow
        t += 86400000
    // sessions run Monday to Friday local time
    for k = 0 to 3
        int dw = dayofweek(t, tz)
        if dw == dayofweek.saturday or dw == dayofweek.sunday
            t += 86400000
    int((t - timenow) / 60000)

f_hm(int m) =>
    str.tostring(math.floor(m / 60)) + "h " + str.tostring(m % 60) + "m"

tPos = switch tblPos
    "Bottom left" => position.bottom_left
    "Top right" => position.top_right
    "Top left" => position.top_left
    "Middle right" => position.middle_right
    => position.bottom_right
tSize = switch tblTxt
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

var table tb = table.new(tPos, 2, 11, bgcolor = color.new(#131722, 8), border_color = #363a45, border_width = 1)

f_cell(int c, int r, string t, color tc) =>
    table.cell(tb, c, r, t, text_color = tc, text_size = tSize, text_halign = text.align_left)

if barstate.islast and showTbl
    string sesNow = asIn ? "Asia" : loIn and nyIn ? "London + New York" : loIn ? "London" : nyIn ? "New York" : "Between sessions"
    color sesCol = asIn ? colAs : loIn and nyIn ? colNy : loIn ? colLo : nyIn ? colNy : lvlCol
    int mAs = f_minsTo(sesAs, TZ_AS)
    int mLo = f_minsTo(sesLo, TZ_LO)
    int mNy = f_minsTo(sesNy, TZ_NY)
    int mMin = math.min(mAs, math.min(mLo, mNy))
    string nxt = mMin == mAs ? "Asia" : mMin == mLo ? "London" : "New York"
    string asPos = asIn or na(aHi) ? "Forming" : close > aHi ? "Above" : close < aLo ? "Below" : "Inside"
    f_cell(0, 0, "Confirmed Close Intraday", color.white)
    f_cell(0, 1, "4H trend", color.white)
    f_cell(1, 1, up4 ? "Up" : "Down", up4 ? bullCol : bearCol)
    f_cell(0, 2, "Daily trend", color.white)
    f_cell(1, 2, upD ? "Up" : "Down", upD ? bullCol : bearCol)
    f_cell(0, 3, "Alignment", color.white)
    f_cell(1, 3, alUp ? "Both up" : alDn ? "Both down" : "Mixed", alUp ? bullCol : alDn ? bearCol : lvlCol)
    f_cell(0, 4, "Session", color.white)
    f_cell(1, 4, sesNow, sesCol)
    f_cell(0, 5, "Next open", color.white)
    f_cell(1, 5, nxt + " in " + f_hm(mMin), color.white)
    f_cell(0, 6, "Asia range", color.white)
    f_cell(1, 6, asPos, asPos == "Above" ? bullCol : asPos == "Below" ? bearCol : lvlCol)
    f_cell(0, 7, "VWAP", color.white)
    f_cell(1, 7, close > vw ? "Above" : "Below", close > vw ? bullCol : bearCol)
    f_cell(0, 8, "Daily open", color.white)
    f_cell(1, 8, close > dOpen ? "Above" : "Below", close > dOpen ? bullCol : bearCol)
    f_cell(0, 9, "Hour (UTC)", color.white)
    f_cell(1, 9, inGood ? "Strong window" : inBad ? "Weak hour" : "Neutral", inGood ? bullCol : inBad ? bearCol : lvlCol)
    string orPos = na(orS) ? "None yet" : not orDone ? "Forming" : close > orHi ? "Above" : close < orLo ? "Below" : "Inside"
    f_cell(0, 10, "NY range", color.white)
    f_cell(1, 10, orPos, orPos == "Above" ? bullCol : orPos == "Below" ? bearCol : lvlCol)

if barstate.isfirst and showTbl
    table.merge_cells(tb, 0, 0, 1, 0)

// ============================================================ ALERTS (use Once Per Bar Close)
alertcondition(asStart, "Asia open", "CC Intraday: Asia session open on {{ticker}}")
alertcondition(loStart, "London open", "CC Intraday: London session open on {{ticker}}")
alertcondition(nyStart, "New York open", "CC Intraday: New York session open on {{ticker}}")
alertcondition(brkUp, "Asia high broken", "CC Intraday: close above the Asia high on {{ticker}}")
alertcondition(brkDn, "Asia low broken", "CC Intraday: close below the Asia low on {{ticker}}")
alertcondition(swpUp, "Asia high swept", "CC Intraday: Asia high swept and rejected on {{ticker}}")
alertcondition(swpDn, "Asia low swept", "CC Intraday: Asia low swept and rejected on {{ticker}}")
alertcondition(conf and d4 != d4[1], "4H trend changed", "CC Intraday: 4H trend changed on {{ticker}}")
alertcondition(conf and dD != dD[1], "Daily trend changed", "CC Intraday: daily trend changed on {{ticker}}")
alertcondition(conf and alUp and not alUp[1], "4H and daily aligned up", "CC Intraday: 4H and daily trend both up on {{ticker}}")
alertcondition(conf and alDn and not alDn[1], "4H and daily aligned down", "CC Intraday: 4H and daily trend both down on {{ticker}}")
alertcondition(orUp, "NY range broken up", "CC Intraday: close above the New York opening range on {{ticker}}")
alertcondition(orDn, "NY range broken down", "CC Intraday: close below the New York opening range on {{ticker}}")
alertcondition(gapFilled, "CME gap filled", "CC Intraday: CME weekend gap filled on {{ticker}}")
````
