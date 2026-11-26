# EMA + VWAP + Sessions + ORB v2

- url: https://www.tradingview.com/script/EuujpA0G-EMA-VWAP-Sessions-ORB-v2/
- type: indicator
- pine_id: PUB;9c441a1c2fda49bc859f8bb82df55e15
- version: 1.0

## Description

EMA + VWAP + Sessions + ORB

An all-in-one intraday toolkit combining trend, mean-reversion, session-timing, and opening-range tools in a single overlay — every element independently customizable.

📈 Triple EMA
Three fully independent EMAs, each with its own length, color, visibility toggle, and line style (Solid / Dashed / Dotted). Defaults: 9 (red) / 21 (white) / 50 (blue).

⚖️ VWAP
Session-anchored VWAP with adjustable color, line width, and style (Solid / Dashed / Dotted). Default: yellow.

🎨 Adjustable Dash/Dot Spacing
Dashed and Dotted styles use a custom-built rendering method so they show exactly as much chart history as Solid lines — no artificial history limit. Dash length, dash gap, and dot gap are all independently tunable to match your timeframe.

🌍 Session Overlay
Highlights the London, New York, Tokyo, and Sydney sessions directly on the chart. Each session has its own show/hide toggle, editable time window, and color. Choose between full background shading or a band that hugs just the session's high/low range — useful for spotting session overlaps and volatility windows at a glance.

🎯 Opening Range Breakout (ORB)
Define any custom time window (not locked to fixed 5/15/30-min presets) and the script plots the resulting opening range as a shaded box with extending high, low, and halfway (50%) lines. Includes:

Optional breakout and retest signals, with failed-retest detection
Previous-day range visibility
Built-in alert conditions for both simple level crosses and confirmed breakouts

🎯 ORB-Based Take-Profit Levels
Six auto-calculated TP lines — TP1/TP2/TP3 for both long and short scenarios — measured as configurable multiples of the ORB range, projected from the ORB midpoint. Default multiples are 1x / 2x / 3x, each independently adjustable, so you can size targets to your own risk model.

Fully customizable colors and toggles across every component — EMAs, VWAP, all four sessions, and every ORB element — so the indicator can be tuned to match any chart theme or trading style.

## Source Code

````pine
//@version=6
indicator("EMA + VWAP + Sessions + ORB", overlay=true, max_labels_count=500, max_boxes_count=500)

// helper: simulates Dashed/Dotted styling via a repeating gap pattern in plot() itself.
// Unlike drawing individual line objects, this has NO cap on how far back it renders -
// Dashed/Dotted will show exactly as much history as Solid does.
// Adjustable spacing so Dashed/Dotted can be tuned per chart/timeframe
lineStyleGroup = "Line Style Spacing (Dashed/Dotted)"
dashSegLen = input.int(1, "Dash Length (bars on)", minval=1, maxval=10, group=lineStyleGroup)
dashGapLen = input.int(1, "Dash Gap (bars off)", minval=1, maxval=10, group=lineStyleGroup)
dotGapLen  = input.int(1, "Dot Gap (bars off, dot is always 1 bar on)", minval=1, maxval=10, group=lineStyleGroup)

f_applyLineStyle(float val, string styleIn) =>
    dashCycle = dashSegLen + dashGapLen
    dotCycle  = 1 + dotGapLen
    dashOn = bar_index % dashCycle < dashSegLen
    dotOn  = bar_index % dotCycle == 0
    styleIn == "Dashed" ? (dashOn ? val : na) : styleIn == "Dotted" ? (dotOn ? val : na) : val

// ================= EMA SETTINGS =================
emaGroup = "EMA Settings"
showEma1  = input.bool(true, "Show EMA 1", group=emaGroup, inline="e1")
ema1Len   = input.int(9, "Length", minval=1, group=emaGroup, inline="e1")
ema1Col   = input.color(color.red, "Color", group=emaGroup, inline="e1")
ema1Style = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=emaGroup, inline="e1")

showEma2  = input.bool(true, "Show EMA 2", group=emaGroup, inline="e2")
ema2Len   = input.int(21, "Length", minval=1, group=emaGroup, inline="e2")
ema2Col   = input.color(color.white, "Color", group=emaGroup, inline="e2")
ema2Style = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=emaGroup, inline="e2")

showEma3  = input.bool(true, "Show EMA 3", group=emaGroup, inline="e3")
ema3Len   = input.int(50, "Length", minval=1, group=emaGroup, inline="e3")
ema3Col   = input.color(color.blue, "Color", group=emaGroup, inline="e3")
ema3Style = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=emaGroup, inline="e3")

ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)

plot(showEma1 ? f_applyLineStyle(ema1, ema1Style) : na, "EMA 1", ema1Col, linewidth=2, style=plot.style_linebr)
plot(showEma2 ? f_applyLineStyle(ema2, ema2Style) : na, "EMA 2", ema2Col, linewidth=2, style=plot.style_linebr)
plot(showEma3 ? f_applyLineStyle(ema3, ema3Style) : na, "EMA 3", ema3Col, linewidth=2, style=plot.style_linebr)

// ================= VWAP SETTINGS =================
vwapGroup  = "VWAP Settings"
showVwap   = input.bool(true, "Show VWAP", group=vwapGroup, inline="vw")
vwapCol    = input.color(color.yellow, "Color", group=vwapGroup, inline="vw")
vwapWidth  = input.int(2, "Width", minval=1, maxval=5, group=vwapGroup, inline="vw")
vwapStyle  = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=vwapGroup, inline="vw")

vwapVal = ta.vwap(hlc3)
vwapPlotVal = f_applyLineStyle(vwapVal, vwapStyle)
plot(showVwap ? vwapPlotVal : na, "VWAP", vwapCol, linewidth=vwapWidth, style=plot.style_linebr)

// ================= SESSION OVERLAY =================
sessGroup   = "Session Overlay"
bgColorMode = input.bool(false, "Activate High/Low Range Fill (off = full background shade)", group=sessGroup)
sessRes     = input.timeframe("D", "Session Resolution", options=["D","W","M"], group=sessGroup)
sessTZ      = input.string("America/New_York", "Session Timezone", group=sessGroup)

showLondon  = input.bool(true, "London Session", group=sessGroup, inline="ldn")
londonTime  = input.session("0300-1200:1234567", "", group=sessGroup, inline="ldn")
londonCol   = input.color(color.new(color.green, 90), "", group=sessGroup, inline="ldn")

showNY      = input.bool(true, "New York Session", group=sessGroup, inline="ny")
nyTime      = input.session("0800-1700:1234567", "", group=sessGroup, inline="ny")
nyCol       = input.color(color.new(color.red, 90), "", group=sessGroup, inline="ny")

showTokyo   = input.bool(true, "Tokyo Session", group=sessGroup, inline="tok")
tokyoTime   = input.session("2000-0400:1234567", "", group=sessGroup, inline="tok")
tokyoCol    = input.color(color.new(color.yellow, 90), "", group=sessGroup, inline="tok")

showSydney  = input.bool(false, "Sydney Session", group=sessGroup, inline="syd")
sydneyTime  = input.session("1700-0200:1234567", "", group=sessGroup, inline="syd")
sydneyCol   = input.color(color.new(color.blue, 90), "", group=sessGroup, inline="syd")

is_newbar(sess) =>
    t = time(sessRes, sess, sessTZ)
    na(t[1]) and not na(t) or t[1] < t

is_session(sess) =>
    not na(time(timeframe.period, sess, sessTZ))

f_sessionData(bool show, string sessTime) =>
    newbar = is_newbar(sessTime)
    sess   = is_session(sessTime)

    var float sessLow  = na
    var float sessHigh = na

    sessLow  := sess ? (newbar ? low  : math.min(sessLow[1], low))  : sessLow
    sessHigh := sess ? (newbar ? high : math.max(sessHigh[1], high)) : sessHigh

    [sess, sessLow, sessHigh]

[londonSess, londonLow, londonHigh] = f_sessionData(showLondon, londonTime)
pLondonLow  = plot(londonLow, color=color.new(#000000, 100), editable=false)
pLondonHigh = plot(londonHigh, color=color.new(#000000, 100), editable=false)
fill(pLondonLow, pLondonHigh, color = londonSess and showLondon and bgColorMode ? londonCol : na)
bgcolor(londonSess and showLondon and not bgColorMode ? londonCol : na)

[nySess, nyLow, nyHigh] = f_sessionData(showNY, nyTime)
pNyLow  = plot(nyLow, color=color.new(#000000, 100), editable=false)
pNyHigh = plot(nyHigh, color=color.new(#000000, 100), editable=false)
fill(pNyLow, pNyHigh, color = nySess and showNY and bgColorMode ? nyCol : na)
bgcolor(nySess and showNY and not bgColorMode ? nyCol : na)

[tokyoSess, tokyoLow, tokyoHigh] = f_sessionData(showTokyo, tokyoTime)
pTokyoLow  = plot(tokyoLow, color=color.new(#000000, 100), editable=false)
pTokyoHigh = plot(tokyoHigh, color=color.new(#000000, 100), editable=false)
fill(pTokyoLow, pTokyoHigh, color = tokyoSess and showTokyo and bgColorMode ? tokyoCol : na)
bgcolor(tokyoSess and showTokyo and not bgColorMode ? tokyoCol : na)

[sydneySess, sydneyLow, sydneyHigh] = f_sessionData(showSydney, sydneyTime)
pSydneyLow  = plot(sydneyLow, color=color.new(#000000, 100), editable=false)
pSydneyHigh = plot(sydneyHigh, color=color.new(#000000, 100), editable=false)
fill(pSydneyLow, pSydneyHigh, color = sydneySess and showSydney and bgColorMode ? sydneyCol : na)
bgcolor(sydneySess and showSydney and not bgColorMode ? sydneyCol : na)

// ================= ORB (OPENING RANGE BREAKOUT) =================
orbGroup = "ORB Settings"
orbSession  = input.session("0930-0945", "ORB Time Window", group=orbGroup, tooltip="Set the exact start-end time the opening range is measured over, e.g. 0930-0945")
orbTZ       = input.string("America/New_York", "ORB Timezone", options=["America/New_York","Europe/Amsterdam","Europe/Berlin","Asia/Kolkata","Asia/Shanghai","Asia/Tokyo","Etc/UTC"], group=orbGroup)

showOrbLabels    = input.bool(true, "Show High/Low Labels", group=orbGroup)
showPrevDayOrbs  = input.bool(true, "Show ORB Ranges on Previous Days", group=orbGroup)
showOrbEntries   = input.bool(true, "Show Breakout/Retest Signals", group=orbGroup)
alertBreakoutsOnly = input.bool(false, "Alert Only on ORB Breakouts (not price ticks)", group=orbGroup)

showOrbBox  = input.bool(true, "Shade the ORB Range", group=orbGroup)
orbBoxCol   = input.color(color.new(color.teal, 80), "ORB Box Color", group=orbGroup)
orbHighCol  = input.color(color.green, "ORB High Line Color", group=orbGroup)
orbLowCol   = input.color(color.red, "ORB Low Line Color", group=orbGroup)
showOrbMid  = input.bool(true, "Show ORB Halfway Line", group=orbGroup)
orbMidCol   = input.color(color.white, "ORB Halfway Line Color", group=orbGroup)

tpGroup     = "ORB Take-Profit Levels"
showLongTP  = input.bool(true, "Show Long TP Lines", group=tpGroup, inline="tpshow")
showShortTP = input.bool(true, "Show Short TP Lines", group=tpGroup, inline="tpshow")
showTPLabels = input.bool(true, "Show TP Labels", group=tpGroup)

tp1Mult = input.float(1.0, "TP1 Multiple (x ORB range)", minval=0.1, step=0.1, group=tpGroup, inline="tp1")
tp1Col  = input.color(color.lime, "Color", group=tpGroup, inline="tp1")

tp2Mult = input.float(2.0, "TP2 Multiple (x ORB range)", minval=0.1, step=0.1, group=tpGroup, inline="tp2")
tp2Col  = input.color(color.aqua, "Color", group=tpGroup, inline="tp2")

tp3Mult = input.float(3.0, "TP3 Multiple (x ORB range)", minval=0.1, step=0.1, group=tpGroup, inline="tp3")
tp3Col  = input.color(color.fuchsia, "Color", group=tpGroup, inline="tp3")

orbTitle = "ORB"

in_session_orb = not na(time(timeframe.period, orbSession, orbTZ))
isTodayOrb = year(time) == year(timenow) and month(time) == month(timenow) and dayofmonth(time) == dayofmonth(timenow)
drawOrbs = showPrevDayOrbs or isTodayOrb

var float orbHighPrice = na
var float orbLowPrice  = na
var box   dailyOrbBox  = na
var bool  inOrbBreakout = false

isFirstOrbBar = in_session_orb and not in_session_orb[1]

if isFirstOrbBar
    orbHighPrice := high
    orbLowPrice  := low
    inOrbBreakout := false
else if in_session_orb
    orbHighPrice := math.max(orbHighPrice[1], high)
    orbLowPrice  := math.min(orbLowPrice[1], low)
else
    orbHighPrice := orbHighPrice[1]
    orbLowPrice  := orbLowPrice[1]

if drawOrbs and showOrbBox
    if isFirstOrbBar
        dailyOrbBox := box.new(left=bar_index, top=orbHighPrice, right=bar_index + 1, bottom=orbLowPrice, border_width=2)
        box.set_right(dailyOrbBox[1], bar_index[1])
    else if in_session_orb
        box.set_top(dailyOrbBox, orbHighPrice)
        box.set_rightbottom(dailyOrbBox, right=bar_index + 1, bottom=orbLowPrice)
    box.set_bgcolor(dailyOrbBox, orbBoxCol)
    box.set_border_color(dailyOrbBox, color.new(orbBoxCol, 20))

plot(not in_session_orb and drawOrbs ? orbHighPrice : na, style=plot.style_linebr, color=orbHighPrice[1] != orbHighPrice ? na : orbHighCol, title="ORB High", linewidth=2)
plot(not in_session_orb and drawOrbs ? orbLowPrice  : na, style=plot.style_linebr, color=orbLowPrice[1]  != orbLowPrice  ? na : orbLowCol,  title="ORB Low",  linewidth=2)

orbMidPrice = (orbHighPrice + orbLowPrice) / 2
plot(not in_session_orb and drawOrbs and showOrbMid ? orbMidPrice : na, style=plot.style_linebr, color=orbMidPrice[1] != orbMidPrice ? na : orbMidCol, title="ORB Halfway", linewidth=1)

// ---- Take-profit levels, measured from the ORB midpoint ----
orbRangeSize = orbHighPrice - orbLowPrice

longTP1 = orbMidPrice + orbRangeSize * tp1Mult
longTP2 = orbMidPrice + orbRangeSize * tp2Mult
longTP3 = orbMidPrice + orbRangeSize * tp3Mult

shortTP1 = orbMidPrice - orbRangeSize * tp1Mult
shortTP2 = orbMidPrice - orbRangeSize * tp2Mult
shortTP3 = orbMidPrice - orbRangeSize * tp3Mult

plot(not in_session_orb and drawOrbs and showLongTP  ? longTP1  : na, style=plot.style_linebr, color=longTP1[1]  != longTP1  ? na : tp1Col, title="Long TP1",  linewidth=1)
plot(not in_session_orb and drawOrbs and showLongTP  ? longTP2  : na, style=plot.style_linebr, color=longTP2[1]  != longTP2  ? na : tp2Col, title="Long TP2",  linewidth=1)
plot(not in_session_orb and drawOrbs and showLongTP  ? longTP3  : na, style=plot.style_linebr, color=longTP3[1]  != longTP3  ? na : tp3Col, title="Long TP3",  linewidth=1)

plot(not in_session_orb and drawOrbs and showShortTP ? shortTP1 : na, style=plot.style_linebr, color=shortTP1[1] != shortTP1 ? na : tp1Col, title="Short TP1", linewidth=1)
plot(not in_session_orb and drawOrbs and showShortTP ? shortTP2 : na, style=plot.style_linebr, color=shortTP2[1] != shortTP2 ? na : tp2Col, title="Short TP2", linewidth=1)
plot(not in_session_orb and drawOrbs and showShortTP ? shortTP3 : na, style=plot.style_linebr, color=shortTP3[1] != shortTP3 ? na : tp3Col, title="Short TP3", linewidth=1)

f_orbLabel(float price, string txt, color col) =>
    if showOrbLabels
        var label lbl = label.new(bar_index, price, style=label.style_label_lower_left, text=orbTitle + " " + txt, color=col, textcolor=color.white)
        label.set_xy(lbl, bar_index + 2, price)

f_orbLabel(orbHighPrice, "HIGH", orbHighCol)
f_orbLabel(orbLowPrice, "LOW", orbLowCol)
if showOrbMid
    f_orbLabel(orbMidPrice, "50%", orbMidCol)

if showTPLabels and showLongTP
    f_orbLabel(longTP1, "TP1", tp1Col)
    f_orbLabel(longTP2, "TP2", tp2Col)
    f_orbLabel(longTP3, "TP3", tp3Col)

if showTPLabels and showShortTP
    f_orbLabel(shortTP1, "TP1", tp1Col)
    f_orbLabel(shortTP2, "TP2", tp2Col)
    f_orbLabel(shortTP3, "TP3", tp3Col)

// breakout / retest detection (only evaluated once the opening range is complete)
bool highCrossBO = not in_session_orb and low[2] < orbHighPrice and close[2] > orbHighPrice and low[1] > orbHighPrice and close[1] > orbHighPrice and close > low[1] and low > orbHighPrice
bool lowCrossBO  = not in_session_orb and high[2] > orbLowPrice and close[2] < orbLowPrice and high[1] < orbLowPrice and close[1] < orbLowPrice and close < high[1] and high < orbLowPrice

bool highCross = (not alertBreakoutsOnly and ta.cross(close, orbHighPrice)) or (alertBreakoutsOnly and highCrossBO)
bool lowCross  = (not alertBreakoutsOnly and ta.cross(close, orbLowPrice))  or (alertBreakoutsOnly and lowCrossBO)

bool isRetestOrbHigh = close[1] > orbHighPrice and low <= orbHighPrice and close >= orbHighPrice
bool isRetestOrbLow  = close[1] < orbLowPrice and high >= orbLowPrice and close <= orbLowPrice
bool failedOrbRetest = inOrbBreakout and ((close[1] > orbHighPrice and close < orbHighPrice) or (close[1] < orbLowPrice and close > orbLowPrice))

if showOrbEntries and not in_session_orb
    if highCrossBO
        lbl = label.new(bar_index, na, yloc=yloc.abovebar, style=label.style_triangledown, color=color.green, textcolor=color.green, text="Breakout\nWait for Retest", size=size.tiny)
        inOrbBreakout := true
    if lowCrossBO
        lbl = label.new(bar_index, na, yloc=yloc.belowbar, style=label.style_triangleup, color=color.green, textcolor=color.green, text="Breakout\nWait for Retest", size=size.tiny)
        inOrbBreakout := true
    if inOrbBreakout and (isRetestOrbHigh or isRetestOrbLow)
        lbl = label.new(bar_index, na, yloc=yloc.abovebar, style=label.style_label_down, color=color.green, textcolor=color.white, text="Retest", size=size.tiny)
        inOrbBreakout := false
    if inOrbBreakout and failedOrbRetest
        lbl = label.new(bar_index, na, yloc=yloc.abovebar, style=label.style_label_down, color=color.red, textcolor=color.white, text="Failed Retest", size=size.tiny)
        inOrbBreakout := false

alertcondition(not in_session_orb and (highCross or lowCross), title="ORB Level Cross", message="Price crossing ORB Level")
alertcondition(not in_session_orb and alertBreakoutsOnly and (highCrossBO or lowCrossBO), title="ORB Breakout", message="Price breaking out of ORB Level, look for retest")
````
