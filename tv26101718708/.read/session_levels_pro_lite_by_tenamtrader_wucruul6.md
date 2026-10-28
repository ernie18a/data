# Session Levels Pro Lite by TenAMTrader

- url: https://www.tradingview.com/script/WUCruUL6-Session-Levels-Pro-Lite-by-TenAMTrader/
- type: indicator
- pine_id: PUB;f427e33ed3f64a41b03fd503964bb06d
- version: 1.0

## Description

Session Levels Pro Lite by TenAMTrader

A streamlined key-levels indicator for intraday traders. It plots the session, daily, and higher-timeframe levels that price most often reacts to, with an opening range module that includes Fibonacci-based extensions and target zones. Built for index futures (NQ, ES) but works on any intraday chart.

HOW IT WORKS
All session-based levels (Previous Day RTH, Globex, Overnight, ORB, NY Midnight Open, Previous Week) are calculated from 1-minute data rather than the chart's timeframe. That means the levels are exact and identical whether you're on a 1m, 5m, 15m, or 1h chart, and whether your chart is set to RTH or ETH.

DAILY LEVELS
- NYO – New York Midnight Open (00:00 ET), a common intraday bias reference
- PDH / PDL – Previous day's regular-session (RTH) high and low
- GPDH / GPDL – Previous day's full Globex session high and low (18:00–17:00 ET). Captures highs/lows made before the open or after the close that RTH-only levels miss
- ONH / ONL – Overnight high and low (16:00–09:30 ET), updating live during the overnight session

OPENING RANGE (ORB)
- ORBH / ORBM / ORBL – Opening range high, midpoint and low (default 9:30–9:45 ET, fully adjustable)
- Optional shaded clouds between high/mid and mid/low
- Extensions projected from the ORB range above the high and below the low:
  ±23.6%, ±50%, ±61.8%, ±78.6% and ±100%
- Optional target-zone clouds for 50–61.8% and 61.8–78.6%. Turn both on to form one continuous 50–78.6% zone
- Clouds work independently of the lines, so you can show zones only, lines only, or both

HIGHER TIMEFRAME LEVELS
- Previous 4H candle high / low (optional midline)
- Current week and previous week high / low
- Current month (high / mid / low) and previous month high / low
- Previous-period lines are automatically dimmed so they're easy to tell apart from current-period levels

DISPLAY
- Every level has its own toggle, color, line style, and editable label text
- Clean text-only labels with optional price display, adjustable size, position and offsets
- Lines can extend left, right, or both
- ORB and 4H levels auto-hide on Daily and higher charts (optional)

NOTES
- For stocks, set "Globex Start Hour" to 4 to use the 04:00–20:00 extended session
- NYO requires overnight data and will not display on symbols without trading at midnight ET
- Levels update in real time. The ORB builds live during the opening range window and locks once it closes

This script is for educational and informational purposes only and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Session Levels Pro Lite by TenAMTrader", overlay=true, max_labels_count=200, max_lines_count=500)

// ════════════════════════════════════════════════
// GENERAL
// ════════════════════════════════════════════════
grpGeneral = "General"
rthSession       = input.session("0930-1600", "RTH Session (NY)", group=grpGeneral, tooltip="Session used for Previous Day RTH High/Low and Previous Week levels.")
lineWidth        = input.int(1, "Line Width", minval=1, maxval=5, group=grpGeneral, inline="gen1")
prevDimPct       = input.int(60, "Prev Period Dim", minval=0, maxval=90, group=grpGeneral, inline="gen1", tooltip="Previous-period lines (PWH/PWL, LMH/LML) reuse their group's color at this extra transparency.")
extendIntoPast   = input.bool(true, "Extend Left",  group=grpGeneral, inline="gen2")
extendIntoFuture = input.bool(true, "Extend Right", group=grpGeneral, inline="gen2")

// Extended-hours ticker: used for NY Midnight Open and Globex PDH/PDL so
// they include overnight data even when the chart is set to RTH.
tickerExt = ticker.modify(syminfo.tickerid, session.extended)

f_lineStyle(_opt) => _opt == "Dashed" ? line.style_dashed : _opt == "Dotted" ? line.style_dotted : line.style_solid
f_dim(_col) => color.new(_col, prevDimPct)

rayExtend = extend.none
if extendIntoFuture and extendIntoPast
    rayExtend := extend.both
else if extendIntoFuture and not extendIntoPast
    rayExtend := extend.right
else if not extendIntoFuture and extendIntoPast
    rayExtend := extend.left

// ════════════════════════════════════════════════
// LABELS
// ════════════════════════════════════════════════
grpLabels = "Labels"
showLabels       = input.bool(true,  "Show Labels", group=grpLabels, inline="lbl1")
showPriceInLabel = input.bool(false, "Show Price",  group=grpLabels, inline="lbl1")
labelSizeOpt     = input.string("Normal", "Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLabels, inline="lbl2")
labelTextCol     = input.color(color.gray, "Color", group=grpLabels, inline="lbl2")
labelPosition    = input.string("On Line", "Position", options=["Above","On Line","Below"], group=grpLabels, inline="lbl3")
labelOffsetTicks = input.int(100, "Ticks", minval=0, group=grpLabels, inline="lbl3", tooltip="Vertical distance above/below the line in ticks (when Position is Above or Below).")
labelOffsetBars  = input.int(0, "Horizontal Offset (bars)", group=grpLabels, tooltip="Positive = right, Negative = left. Each level also has its own Offset added on top of this.")

labelSize = size.small
if labelSizeOpt == "Tiny"
    labelSize := size.tiny
else if labelSizeOpt == "Small"
    labelSize := size.small
else if labelSizeOpt == "Normal"
    labelSize := size.normal
else if labelSizeOpt == "Large"
    labelSize := size.large
else
    labelSize := size.huge

float yOff = 0.0
if labelPosition == "Above"
    yOff :=  labelOffsetTicks * syminfo.mintick
else if labelPosition == "Below"
    yOff := -labelOffsetTicks * syminfo.mintick

f_labelText(_name, _price, _showPrice) => _showPrice ? (_name + " " + str.tostring(_price, format.mintick)) : _name

// ════════════════════════════════════════════════
// DAILY LEVELS (NYO / PDH-PDL / GPDH-GPDL / ONH-ONL)
// ════════════════════════════════════════════════
grpDaily = "Daily Levels"

showMO             = input.bool(false, "NYO", group=grpDaily, inline="mo1")
moColor            = input.color(color.black, "", group=grpDaily, inline="mo1")
moLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpDaily, inline="mo1")
moLabelText        = input.string("NYO", "Label", group=grpDaily, inline="mo2")
moLabelExtraOffset = input.int(8, "Offset", group=grpDaily, inline="mo2")

showPD             = input.bool(true, "PDH/PDL (RTH)", group=grpDaily, inline="pd1")
pdColor            = input.color(color.black, "", group=grpDaily, inline="pd1")
pdLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpDaily, inline="pd1")
pdhLabelText       = input.string("PDH", "Labels", group=grpDaily, inline="pd2")
pdlLabelText       = input.string("PDL", "", group=grpDaily, inline="pd2")
pdLabelExtraOffset = input.int(8, "Offset", group=grpDaily, inline="pd2")

showPDF             = input.bool(true, "GPDH/GPDL (Globex)", group=grpDaily, inline="pdf1")
pdfColor            = input.color(color.black, "", group=grpDaily, inline="pdf1")
pdfLineStyleOpt     = input.string("Dashed", "", options=["Solid","Dashed","Dotted"], group=grpDaily, inline="pdf1")
pdfhLabelText       = input.string("GPDH", "Labels", group=grpDaily, inline="pdf2")
pdflLabelText       = input.string("GPDL", "", group=grpDaily, inline="pdf2")
pdfLabelExtraOffset = input.int(8, "Offset", group=grpDaily, inline="pdf2")
pdfStartHour        = input.int(8, "Globex Start Hour (NY)", minval=0, maxval=23, group=grpDaily, tooltip="Hour the trading day begins in NY time. 18 = CME Globex (NQ/ES, 18:00–17:00). Use 4 for stocks (04:00–20:00 extended hours).")

showON             = input.bool(true, "ONH/ONL", group=grpDaily, inline="on1")
onColor            = input.color(color.black, "", group=grpDaily, inline="on1")
onLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpDaily, inline="on1")
onhLabelText       = input.string("ONH", "Labels", group=grpDaily, inline="on2")
onlLabelText       = input.string("ONL", "", group=grpDaily, inline="on2")
onLabelExtraOffset = input.int(8, "Offset", group=grpDaily, inline="on2")

// ════════════════════════════════════════════════
// OPENING RANGE (ORB)
// ════════════════════════════════════════════════
grpORB = "Opening Range (ORB)"
orSessionInput = input.session("0930-0945", "ORB Window (NY)", group=grpORB, tooltip="Default is 9:30–9:45 AM NY. e.g. 0930-1000 for a 30-min ORB.")
hideHTFAbove   = input.bool(true, "Hide ORB & 4H on 1D+ Charts", group=grpORB)

showORB            = input.bool(true, "ORBH/ORBL", group=grpORB, inline="orb1")
orbColor           = input.color(color.black, "", group=grpORB, inline="orb1")
showORBMid         = input.bool(true, "Mid", group=grpORB, inline="orb1")
orbMidColor        = input.color(color.black, "", group=grpORB, inline="orb1")
orLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpORB, inline="orb1", tooltip="Line style applies to ORB and all ORB Extensions.")
orhLabelText       = input.string("ORBH", "Labels", group=grpORB, inline="orb2")
ormLabelText       = input.string("ORBM", "", group=grpORB, inline="orb2")
orlLabelText       = input.string("ORBL", "", group=grpORB, inline="orb2")
orLabelExtraOffset = input.int(4, "Offset", group=grpORB, inline="orb2", tooltip="Applies to ORB and all ORB Extension labels.")

showORBClouds    = input.bool(true, "Clouds", group=grpORB, inline="orb3")
orbCloudTopColor = input.color(color.new(color.blue, 86), "Top", group=grpORB, inline="orb3")
orbCloudBotColor = input.color(color.new(color.blue, 86), "Bottom", group=grpORB, inline="orb3", tooltip="ORB clouds work independently of the ORB line toggles.")

// ════════════════════════════════════════════════
// ORB EXTENSIONS
// ════════════════════════════════════════════════
grpORBExt = "ORB Extensions"
showORBExt236      = input.bool(false, "±23.6%", group=grpORBExt, inline="x236")
orbExt236Color     = input.color(color.black, "", group=grpORBExt, inline="x236")
orbExt236HighLabel = input.string("+23.6%", "", group=grpORBExt, inline="x236")
orbExt236LowLabel  = input.string("-23.6%", "", group=grpORBExt, inline="x236")

showORBExt      = input.bool(true, "±50%", group=grpORBExt, inline="x50")
orbExtColor     = input.color(color.black, "", group=grpORBExt, inline="x50")
orbExtHighLabel = input.string("+50%", "", group=grpORBExt, inline="x50")
orbExtLowLabel  = input.string("-50%", "", group=grpORBExt, inline="x50")

showORBGoldenLines = input.bool(false, "±61.8% / 78.6%", group=grpORBExt, inline="xg1")
orbGoldLineColor   = input.color(color.black, "", group=grpORBExt, inline="xg1")
orbG618HighLabel   = input.string("+61.8%", "Labels", group=grpORBExt, inline="xg2")
orbG786HighLabel   = input.string("+78.6%", "", group=grpORBExt, inline="xg2")
orbG618LowLabel    = input.string("-61.8%", "", group=grpORBExt, inline="xg2")
orbG786LowLabel    = input.string("-78.6%", "", group=grpORBExt, inline="xg2")

showORBExt100      = input.bool(true, "±100%", group=grpORBExt, inline="x100")
orbExt100Color     = input.color(color.black, "", group=grpORBExt, inline="x100")
orbExt100HighLabel = input.string("+100%", "", group=grpORBExt, inline="x100")
orbExt100LowLabel  = input.string("-100%", "", group=grpORBExt, inline="x100")

showORBExtGoldClouds = input.bool(false, "Cloud 50–61.8%",   group=grpORBExt, inline="xc")
showORBGoldenClouds  = input.bool(false, "Cloud 61.8–78.6%", group=grpORBExt, inline="xc")
orbGoldenColor       = input.color(color.new(color.yellow, 80), "", group=grpORBExt, inline="xc", tooltip="With both clouds on, they form one continuous zone from 50% to 78.6%. Clouds work independently of the line toggles.")

// ════════════════════════════════════════════════
// HIGHER TIMEFRAME LEVELS (4H / WEEKLY / MONTHLY)
// ════════════════════════════════════════════════
grpHTF = "Higher Timeframe Levels"

show4H                = input.bool(true, "Prev 4H", group=grpHTF, inline="h4a")
fourHColor            = input.color(color.black, "", group=grpHTF, inline="h4a")
show4HMid             = input.bool(false, "Mid", group=grpHTF, inline="h4a")
fourHMidColor         = input.color(color.black, "", group=grpHTF, inline="h4a")
fourHLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpHTF, inline="h4a")
fourHHLabelText       = input.string("4HH", "Labels", group=grpHTF, inline="h4b")
fourHMLabelText       = input.string("4HM", "", group=grpHTF, inline="h4b")
fourHLLabelText       = input.string("4HL", "", group=grpHTF, inline="h4b")
fourHLabelExtraOffset = input.int(8, "Offset", group=grpHTF, inline="h4b")

showCurWeek          = input.bool(false, "Week", group=grpHTF, inline="wk1")
showPW               = input.bool(true,  "Prev Week", group=grpHTF, inline="wk1")
weekColor            = input.color(color.black, "", group=grpHTF, inline="wk1")
weekLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpHTF, inline="wk1")
whLabelText          = input.string("WH",  "Labels", group=grpHTF, inline="wk2")
wlLabelText          = input.string("WL",  "", group=grpHTF, inline="wk2")
pwhLabelText         = input.string("PWH", "", group=grpHTF, inline="wk2")
pwlLabelText         = input.string("PWL", "", group=grpHTF, inline="wk2")
weekLabelExtraOffset = input.int(8, "Offset", group=grpHTF, inline="wk2")

showCurMonth            = input.bool(false, "Month", group=grpHTF, inline="mn1")
showPrevMonth           = input.bool(false, "Prev Month", group=grpHTF, inline="mn1")
monthColor              = input.color(color.black, "", group=grpHTF, inline="mn1")
monthMidColor           = input.color(color.black, "Mid", group=grpHTF, inline="mn1")
monthlyLineStyleOpt     = input.string("Solid", "", options=["Solid","Dashed","Dotted"], group=grpHTF, inline="mn1")
cmhLabelText            = input.string("MH",  "Labels", group=grpHTF, inline="mn2")
cmmLabelText            = input.string("MM",  "", group=grpHTF, inline="mn2")
cmlLabelText            = input.string("ML",  "", group=grpHTF, inline="mn2")
pmhLabelText            = input.string("LMH", "", group=grpHTF, inline="mn2")
pmlLabelText            = input.string("LML", "", group=grpHTF, inline="mn2")
monthlyLabelExtraOffset = input.int(12, "Offset", group=grpHTF, inline="mn2")

// ── HTF visibility gate (ORB + 4H) ────────────
bool isHTFHidden  = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
bool orbVisible   = not (hideHTFAbove and isHTFHidden)
bool fourHVisible = not (hideHTFAbove and isHTFHidden)

showORBeff              = showORB and orbVisible
showORBMidEff           = showORBMid and orbVisible
showORBCloudsEff        = showORBClouds and orbVisible
showORBExt236Eff        = showORBExt236 and orbVisible
showORBExtEff           = showORBExt and orbVisible
showORBGoldenLinesEff   = showORBGoldenLines and orbVisible
showORBExt100Eff        = showORBExt100 and orbVisible
showORBExtGoldCloudsEff = showORBExtGoldClouds and orbVisible
showORBGoldenCloudsEff  = showORBGoldenClouds and orbVisible
show4Heff               = show4H and fourHVisible
show4HMidEff            = show4H and show4HMid and fourHVisible

// Invisible cloud-boundary anchors — clouds never depend on visible line toggles
bool  anchor50Needed  = showORBExtGoldCloudsEff
bool  anchor618Needed = showORBExtGoldCloudsEff or showORBGoldenCloudsEff
bool  anchor786Needed = showORBGoldenCloudsEff
color anchorColor     = color.new(color.black, 100)

// ════════════════════════════════════════════════
// DATA SOURCES (all session levels from 1-minute data)
// ════════════════════════════════════════════════

// ── NY Midnight Open (1m, extended hours) ─────
f_midnightOpen_1m() =>
    int  nyDay  = dayofmonth(time, "America/New_York")
    bool newDay = nyDay != nyDay[1]
    var float mo = na
    if newDay and hour(time, "America/New_York") == 0
        mo := open
    mo

float nyMidOpen = request.security(tickerExt, "1", f_midnightOpen_1m(), barmerge.gaps_off, barmerge.lookahead_off)

// ── Previous Globex Session High/Low (1m, extended hours) ──
// Each bar is assigned a trading-day ID by shifting its time forward so the
// session start hour lands on NY midnight. When the ID changes, the session
// that just finished becomes the "previous" one. This avoids relying on a
// session gap, since NQ/ES trade continuously 16:59 → 18:00 with no bar between.
f_prevFullSession_1m(_startHour) =>
    int   shiftMs = ((24 - _startHour) % 24) * 3600000
    int   tShift  = time + shiftMs
    int   dayId   = year(tShift, "America/New_York") * 10000 + month(tShift, "America/New_York") * 100 + dayofmonth(tShift, "America/New_York")
    var float hi     = na
    var float lo     = na
    var float prevHi = na
    var float prevLo = na
    var int   curId  = na
    if na(curId) or dayId != curId
        if not na(hi) and not na(lo)
            prevHi := hi
            prevLo := lo
        hi    := high
        lo    := low
        curId := dayId
    else
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    [prevHi, prevLo]

[pdfHigh, pdfLow] = request.security(tickerExt, "1", f_prevFullSession_1m(pdfStartHour), barmerge.gaps_off, barmerge.lookahead_off)

// ── Previous Day RTH High/Low (1m) ────────────
f_prevRTH_1m() =>
    bool inR    = not na(time("1", rthSession, "America/New_York"))
    bool rStart = inR and not inR[1]
    bool rEnd   = not inR and inR[1]
    var float hi     = na
    var float lo     = na
    var float prevHi = na
    var float prevLo = na
    if rStart
        hi := high
        lo := low
    else if inR
        hi := math.max(nz(hi, high), high)
        lo := math.min(nz(lo, low),  low)
    if rEnd and not na(hi) and not na(lo)
        prevHi := hi
        prevLo := lo
    [prevHi, prevLo]

[pDH_1m, pDL_1m] = request.security(syminfo.tickerid, "1", f_prevRTH_1m(), barmerge.gaps_off, barmerge.lookahead_off)

float pDH_D   = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
float pDL_D   = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)
float pDH_use = na(pDH_1m) ? pDH_D : pDH_1m
float pDL_use = na(pDL_1m) ? pDL_D : pDL_1m

// ── Previous Week RTH High/Low (1m) ───────────
f_prevWeekRTH_1m() =>
    bool inR              = not na(time("1", rthSession, "America/New_York"))
    bool rStart           = inR and not inR[1]
    bool isWeekday        = dayofweek >= dayofweek.monday and dayofweek <= dayofweek.friday
    int  curWeekId        = year(time, "America/New_York") * 100 + weekofyear(time, "America/New_York")
    int  prevWeekId_local = year(time[1], "America/New_York") * 100 + weekofyear(time[1], "America/New_York")
    bool newWeek          = rStart and (curWeekId != prevWeekId_local)
    var float wkHi     = na
    var float wkLo     = na
    var float prevWkHi = na
    var float prevWkLo = na
    if newWeek
        if not na(wkHi) and not na(wkLo)
            prevWkHi := wkHi
            prevWkLo := wkLo
        wkHi := high
        wkLo := low
    else if inR and isWeekday
        wkHi := math.max(nz(wkHi, high), high)
        wkLo := math.min(nz(wkLo, low),  low)
    [prevWkHi, prevWkLo]

[pWH_1m, pWL_1m] = request.security(syminfo.tickerid, "1", f_prevWeekRTH_1m(), barmerge.gaps_off, barmerge.lookahead_off)

float pWH_W   = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
float pWL_W   = request.security(syminfo.tickerid, "W", low[1],  barmerge.gaps_off, barmerge.lookahead_off)
float pWH_use = na(pWH_1m) ? pWH_W : pWH_1m
float pWL_use = na(pWL_1m) ? pWL_W : pWL_1m

// ── Current Week (in-progress) ────────────────
float curWeekHigh = request.security(syminfo.tickerid, "W", high, barmerge.gaps_off, barmerge.lookahead_off)
float curWeekLow  = request.security(syminfo.tickerid, "W", low,  barmerge.gaps_off, barmerge.lookahead_off)

// ── Monthly (current + previous) ──────────────
float curMonthHigh  = request.security(syminfo.tickerid, "M", high,    barmerge.gaps_off, barmerge.lookahead_off)
float curMonthLow   = request.security(syminfo.tickerid, "M", low,     barmerge.gaps_off, barmerge.lookahead_off)
float curMonthMid   = not na(curMonthHigh) and not na(curMonthLow) ? (curMonthHigh + curMonthLow) / 2.0 : na
float prevMonthHigh = request.security(syminfo.tickerid, "M", high[1], barmerge.gaps_off, barmerge.lookahead_off)
float prevMonthLow  = request.security(syminfo.tickerid, "M", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

// ── 4H (previous completed 4H candle) ─────────
float fourHHigh = request.security(syminfo.tickerid, "240", high[1], barmerge.gaps_off, barmerge.lookahead_off)
float fourHLow  = request.security(syminfo.tickerid, "240", low[1],  barmerge.gaps_off, barmerge.lookahead_off)
float fourHMid  = not na(fourHHigh) and not na(fourHLow) ? (fourHHigh + fourHLow) / 2.0 : na

// ── Overnight High/Low (1m) ───────────────────
overnightSession = "1600-0930"

f_on_1m() =>
    bool inS    = not na(time("1", overnightSession, "America/New_York"))
    bool sStart = inS and not inS[1]
    bool sEnd   = not inS and inS[1]
    var float hi      = na
    var float lo      = na
    var float finalHi = na
    var float finalLo = na
    if sStart
        hi := high
        lo := low
    else if inS
        hi := math.max(nz(hi, high), high)
        lo := math.min(nz(lo, low),  low)
    if sEnd and not na(hi) and not na(lo)
        finalHi := hi
        finalLo := lo
    [inS, hi, lo, finalHi, finalLo]

[inON_1m, curONHigh_1m, curONLow_1m, oNH_final_1m, oNL_final_1m] = request.security(syminfo.tickerid, "1", f_on_1m(), barmerge.gaps_off, barmerge.lookahead_off)
float onhForAll = inON_1m ? curONHigh_1m : oNH_final_1m
float onlForAll = inON_1m ? curONLow_1m  : oNL_final_1m

// ── Opening Range (1m) ────────────────────────
f_or_1m() =>
    bool inS    = not na(time("1", orSessionInput, "America/New_York"))
    bool sStart = inS and not inS[1]
    bool sEnd   = not inS and inS[1]
    var float hi       = na
    var float lo       = na
    var float finalHi  = na
    var float finalLo  = na
    var float finalMid = na
    if sStart
        hi := high
        lo := low
    else if inS
        hi := math.max(nz(hi, high), high)
        lo := math.min(nz(lo, low),  low)
    if sEnd and not na(hi) and not na(lo)
        finalHi  := hi
        finalLo  := lo
        finalMid := finalLo + (finalHi - finalLo) / 2.0
    float curMid = lo + (hi - lo) / 2.0
    [inS, hi, lo, finalHi, finalLo, finalMid, curMid]

[inOR_1m, curORHigh_1m, curORLow_1m, oRHigh_1m, oRLow_1m, oRMid_1m, curORMid_1m] = request.security(syminfo.tickerid, "1", f_or_1m(), barmerge.gaps_off, barmerge.lookahead_off)
float oRHigh_use = inOR_1m ? curORHigh_1m : oRHigh_1m
float oRLow_use  = inOR_1m ? curORLow_1m  : oRLow_1m
float oRMid_use  = inOR_1m ? curORMid_1m  : oRMid_1m

// ── ORB Extensions ────────────────────────────
float orbRange = not na(oRHigh_use) and not na(oRLow_use) ? oRHigh_use - oRLow_use : na

float oRExt236High_use = not na(orbRange) ? oRHigh_use + orbRange * 0.236 : na
float oRExt236Low_use  = not na(orbRange) ? oRLow_use  - orbRange * 0.236 : na
float oRExtHigh_use    = not na(orbRange) ? oRHigh_use + orbRange * 0.5   : na
float oRExtLow_use     = not na(orbRange) ? oRLow_use  - orbRange * 0.5   : na
float oRGoldenHigh618  = not na(orbRange) ? oRHigh_use + orbRange * 0.618 : na
float oRGoldenHigh786  = not na(orbRange) ? oRHigh_use + orbRange * 0.786 : na
float oRGoldenLow618   = not na(orbRange) ? oRLow_use  - orbRange * 0.618 : na
float oRGoldenLow786   = not na(orbRange) ? oRLow_use  - orbRange * 0.786 : na
float oRExt100High_use = not na(orbRange) ? oRHigh_use + orbRange         : na
float oRExt100Low_use  = not na(orbRange) ? oRLow_use  - orbRange         : na

// ════════════════════════════════════════════════
// RAYS
// ════════════════════════════════════════════════
var line moRay          = na
var line pdhRay         = na
var line pdlRay         = na
var line pdfhRay        = na
var line pdflRay        = na
var line onhRay         = na
var line onlRay         = na
var line orhRay         = na
var line ormRay         = na
var line orlRay         = na
var line whRay          = na
var line wlRay          = na
var line pwhRay         = na
var line pwlRay         = na
var line orbExt236HiRay = na
var line orbExt236LoRay = na
var line orbExtHiRay    = na
var line orbExtLoRay    = na
var line orbG618HiRay   = na
var line orbG786HiRay   = na
var line orbG618LoRay   = na
var line orbG786LoRay   = na
var line orbExt100HiRay = na
var line orbExt100LoRay = na
var line cmhRay         = na
var line cmmRay         = na
var line cmlRay         = na
var line pmhRay         = na
var line pmlRay         = na
var line fourHHRay      = na
var line fourHMRay      = na
var line fourHLRay      = na

// Invisible cloud anchors — ORB core
var line orbAHi  = na
var line orbAMid = na
var line orbALo  = na
var linefill orbFillTop = na
var linefill orbFillBot = na

// Invisible cloud anchors — ORB extensions
var line orbA50Hi  = na
var line orbA618Hi = na
var line orbA786Hi = na
var line orbA50Lo  = na
var line orbA618Lo = na
var line orbA786Lo = na
var linefill orbExtGoldHiFill = na
var linefill orbExtGoldLoFill = na
var linefill orbGoldHiFill    = na
var linefill orbGoldLoFill    = na

f_ray(_ray, _show, _price, _col, _style, _w) =>
    bool canDraw = _show and not na(_price)
    line r = _ray
    if canDraw
        if na(r)
            r := line.new(bar_index, _price, bar_index + 1, _price, extend=rayExtend, color=_col, width=_w, style=_style)
        else
            line.set_xy1(r, bar_index,     _price)
            line.set_xy2(r, bar_index + 1, _price)
            line.set_extend(r, rayExtend)
            line.set_color(r, _col)
            line.set_width(r, _w)
            line.set_style(r, _style)
    else
        if not na(r)
            line.delete(r)
            r := na
    r

f_fill(_fillVar, _show, _ray1, _ray2, _col) =>
    linefill f = _fillVar
    bool ok = _show and not na(_ray1) and not na(_ray2)
    if ok
        if na(f)
            f := linefill.new(_ray1, _ray2, color=_col)
        else
            linefill.set_color(f, _col)
    else
        if not na(f)
            linefill.delete(f)
            f := na
    f

moRayStyle      = f_lineStyle(moLineStyleOpt)
pdRayStyle      = f_lineStyle(pdLineStyleOpt)
pdfRayStyle     = f_lineStyle(pdfLineStyleOpt)
onRayStyle      = f_lineStyle(onLineStyleOpt)
orRayStyle      = f_lineStyle(orLineStyleOpt)
weekRayStyle    = f_lineStyle(weekLineStyleOpt)
monthlyRayStyle = f_lineStyle(monthlyLineStyleOpt)
fourHRayStyle   = f_lineStyle(fourHLineStyleOpt)

moRay          := f_ray(moRay,          showMO,                nyMidOpen,        moColor,           moRayStyle, lineWidth)
pdhRay         := f_ray(pdhRay,         showPD,                pDH_use,          pdColor,           pdRayStyle, lineWidth)
pdlRay         := f_ray(pdlRay,         showPD,                pDL_use,          pdColor,           pdRayStyle, lineWidth)
pdfhRay        := f_ray(pdfhRay,        showPDF,               pdfHigh,          pdfColor,          pdfRayStyle, lineWidth)
pdflRay        := f_ray(pdflRay,        showPDF,               pdfLow,           pdfColor,          pdfRayStyle, lineWidth)
onhRay         := f_ray(onhRay,         showON,                onhForAll,        onColor,           onRayStyle, lineWidth)
onlRay         := f_ray(onlRay,         showON,                onlForAll,        onColor,           onRayStyle, lineWidth)
orhRay         := f_ray(orhRay,         showORBeff,            oRHigh_use,       orbColor,          orRayStyle, lineWidth)
ormRay         := f_ray(ormRay,         showORBMidEff,         oRMid_use,        orbMidColor,       orRayStyle, lineWidth)
orlRay         := f_ray(orlRay,         showORBeff,            oRLow_use,        orbColor,          orRayStyle, lineWidth)
whRay          := f_ray(whRay,          showCurWeek,           curWeekHigh,      weekColor,         weekRayStyle, lineWidth)
wlRay          := f_ray(wlRay,          showCurWeek,           curWeekLow,       weekColor,         weekRayStyle, lineWidth)
pwhRay         := f_ray(pwhRay,         showPW,                pWH_use,          f_dim(weekColor),  weekRayStyle, lineWidth)
pwlRay         := f_ray(pwlRay,         showPW,                pWL_use,          f_dim(weekColor),  weekRayStyle, lineWidth)
orbExt236HiRay := f_ray(orbExt236HiRay, showORBExt236Eff,      oRExt236High_use, orbExt236Color,    orRayStyle, lineWidth)
orbExt236LoRay := f_ray(orbExt236LoRay, showORBExt236Eff,      oRExt236Low_use,  orbExt236Color,    orRayStyle, lineWidth)
orbExtHiRay    := f_ray(orbExtHiRay,    showORBExtEff,         oRExtHigh_use,    orbExtColor,       orRayStyle, lineWidth)
orbExtLoRay    := f_ray(orbExtLoRay,    showORBExtEff,         oRExtLow_use,     orbExtColor,       orRayStyle, lineWidth)
orbG618HiRay   := f_ray(orbG618HiRay,   showORBGoldenLinesEff, oRGoldenHigh618,  orbGoldLineColor,  orRayStyle, lineWidth)
orbG786HiRay   := f_ray(orbG786HiRay,   showORBGoldenLinesEff, oRGoldenHigh786,  orbGoldLineColor,  orRayStyle, lineWidth)
orbG618LoRay   := f_ray(orbG618LoRay,   showORBGoldenLinesEff, oRGoldenLow618,   orbGoldLineColor,  orRayStyle, lineWidth)
orbG786LoRay   := f_ray(orbG786LoRay,   showORBGoldenLinesEff, oRGoldenLow786,   orbGoldLineColor,  orRayStyle, lineWidth)
orbExt100HiRay := f_ray(orbExt100HiRay, showORBExt100Eff,      oRExt100High_use, orbExt100Color,    orRayStyle, lineWidth)
orbExt100LoRay := f_ray(orbExt100LoRay, showORBExt100Eff,      oRExt100Low_use,  orbExt100Color,    orRayStyle, lineWidth)
cmhRay         := f_ray(cmhRay,         showCurMonth,          curMonthHigh,     monthColor,        monthlyRayStyle, lineWidth)
cmmRay         := f_ray(cmmRay,         showCurMonth,          curMonthMid,      monthMidColor,     monthlyRayStyle, lineWidth)
cmlRay         := f_ray(cmlRay,         showCurMonth,          curMonthLow,      monthColor,        monthlyRayStyle, lineWidth)
pmhRay         := f_ray(pmhRay,         showPrevMonth,         prevMonthHigh,    f_dim(monthColor), monthlyRayStyle, lineWidth)
pmlRay         := f_ray(pmlRay,         showPrevMonth,         prevMonthLow,     f_dim(monthColor), monthlyRayStyle, lineWidth)
fourHHRay      := f_ray(fourHHRay,      show4Heff,             fourHHigh,        fourHColor,        fourHRayStyle, lineWidth)
fourHMRay      := f_ray(fourHMRay,      show4HMidEff,          fourHMid,         fourHMidColor,     fourHRayStyle, lineWidth)
fourHLRay      := f_ray(fourHLRay,      show4Heff,             fourHLow,         fourHColor,        fourHRayStyle, lineWidth)

// ── ORB Clouds (ORBH↔ORBM↔ORBL) — independent of ORB line toggles ──
orbAHi  := f_ray(orbAHi,  showORBCloudsEff, oRHigh_use, anchorColor, line.style_solid, 1)
orbAMid := f_ray(orbAMid, showORBCloudsEff, oRMid_use,  anchorColor, line.style_solid, 1)
orbALo  := f_ray(orbALo,  showORBCloudsEff, oRLow_use,  anchorColor, line.style_solid, 1)
orbFillTop := f_fill(orbFillTop, showORBCloudsEff, orbAHi,  orbAMid, orbCloudTopColor)
orbFillBot := f_fill(orbFillBot, showORBCloudsEff, orbAMid, orbALo,  orbCloudBotColor)

// ── ORB Extension Clouds (50%–61.8% and 61.8%–78.6%) ──
orbA50Hi  := f_ray(orbA50Hi,  anchor50Needed,  oRExtHigh_use,   anchorColor, line.style_solid, 1)
orbA618Hi := f_ray(orbA618Hi, anchor618Needed, oRGoldenHigh618, anchorColor, line.style_solid, 1)
orbA786Hi := f_ray(orbA786Hi, anchor786Needed, oRGoldenHigh786, anchorColor, line.style_solid, 1)
orbA50Lo  := f_ray(orbA50Lo,  anchor50Needed,  oRExtLow_use,    anchorColor, line.style_solid, 1)
orbA618Lo := f_ray(orbA618Lo, anchor618Needed, oRGoldenLow618,  anchorColor, line.style_solid, 1)
orbA786Lo := f_ray(orbA786Lo, anchor786Needed, oRGoldenLow786,  anchorColor, line.style_solid, 1)

orbExtGoldHiFill := f_fill(orbExtGoldHiFill, showORBExtGoldCloudsEff, orbA50Hi,  orbA618Hi, orbGoldenColor)
orbExtGoldLoFill := f_fill(orbExtGoldLoFill, showORBExtGoldCloudsEff, orbA50Lo,  orbA618Lo, orbGoldenColor)
orbGoldHiFill    := f_fill(orbGoldHiFill,    showORBGoldenCloudsEff,  orbA618Hi, orbA786Hi, orbGoldenColor)
orbGoldLoFill    := f_fill(orbGoldLoFill,    showORBGoldenCloudsEff,  orbA618Lo, orbA786Lo, orbGoldenColor)

// ════════════════════════════════════════════════
// LABELS (text only)
// ════════════════════════════════════════════════
var label moLbl          = na
var label pdhLbl         = na
var label pdlLbl         = na
var label pdfhLbl        = na
var label pdflLbl        = na
var label onhLbl         = na
var label onlLbl         = na
var label orhLbl         = na
var label ormLbl         = na
var label orlLbl         = na
var label whLbl          = na
var label wlLbl          = na
var label pwhLbl         = na
var label pwlLbl         = na
var label orbExt236HiLbl = na
var label orbExt236LoLbl = na
var label orbExtHiLbl    = na
var label orbExtLoLbl    = na
var label orbG618HiLbl   = na
var label orbG786HiLbl   = na
var label orbG618LoLbl   = na
var label orbG786LoLbl   = na
var label orbExt100HiLbl = na
var label orbExt100LoLbl = na
var label cmhLbl         = na
var label cmmLbl         = na
var label cmlLbl         = na
var label pmhLbl         = na
var label pmlLbl         = na
var label fourHHLbl      = na
var label fourHMLbl      = na
var label fourHLLbl      = na

f_lbl(_lbl, _show, _price, _text, _xOff) =>
    label l = _lbl
    bool active = barstate.islast and _show and not na(_price)
    if active
        float y = _price + yOff
        int   x = bar_index + labelOffsetBars + _xOff
        if na(l)
            l := label.new(x, y, _text, style=label.style_none, textcolor=labelTextCol, color=color.new(color.black, 100), size=labelSize)
        else
            label.set_xy(l, x, y)
            label.set_text(l, _text)
            label.set_textcolor(l, labelTextCol)
            label.set_size(l, labelSize)
    else
        if not na(l)
            label.delete(l)
            l := na
    l

if barstate.islast
    moLbl          := f_lbl(moLbl,          showLabels and showMO,                nyMidOpen,        f_labelText(moLabelText,        nyMidOpen,        showPriceInLabel), moLabelExtraOffset)
    pdhLbl         := f_lbl(pdhLbl,         showLabels and showPD,                pDH_use,          f_labelText(pdhLabelText,       pDH_use,          showPriceInLabel), pdLabelExtraOffset)
    pdlLbl         := f_lbl(pdlLbl,         showLabels and showPD,                pDL_use,          f_labelText(pdlLabelText,       pDL_use,          showPriceInLabel), pdLabelExtraOffset)
    pdfhLbl        := f_lbl(pdfhLbl,        showLabels and showPDF,               pdfHigh,          f_labelText(pdfhLabelText,      pdfHigh,          showPriceInLabel), pdfLabelExtraOffset)
    pdflLbl        := f_lbl(pdflLbl,        showLabels and showPDF,               pdfLow,           f_labelText(pdflLabelText,      pdfLow,           showPriceInLabel), pdfLabelExtraOffset)
    onhLbl         := f_lbl(onhLbl,         showLabels and showON,                onhForAll,        f_labelText(onhLabelText,       onhForAll,        showPriceInLabel), onLabelExtraOffset)
    onlLbl         := f_lbl(onlLbl,         showLabels and showON,                onlForAll,        f_labelText(onlLabelText,       onlForAll,        showPriceInLabel), onLabelExtraOffset)
    orhLbl         := f_lbl(orhLbl,         showLabels and showORBeff,            oRHigh_use,       f_labelText(orhLabelText,       oRHigh_use,       showPriceInLabel), orLabelExtraOffset)
    ormLbl         := f_lbl(ormLbl,         showLabels and showORBMidEff,         oRMid_use,        f_labelText(ormLabelText,       oRMid_use,        showPriceInLabel), orLabelExtraOffset)
    orlLbl         := f_lbl(orlLbl,         showLabels and showORBeff,            oRLow_use,        f_labelText(orlLabelText,       oRLow_use,        showPriceInLabel), orLabelExtraOffset)
    orbExt236HiLbl := f_lbl(orbExt236HiLbl, showLabels and showORBExt236Eff,      oRExt236High_use, f_labelText(orbExt236HighLabel, oRExt236High_use, showPriceInLabel), orLabelExtraOffset)
    orbExt236LoLbl := f_lbl(orbExt236LoLbl, showLabels and showORBExt236Eff,      oRExt236Low_use,  f_labelText(orbExt236LowLabel,  oRExt236Low_use,  showPriceInLabel), orLabelExtraOffset)
    orbExtHiLbl    := f_lbl(orbExtHiLbl,    showLabels and showORBExtEff,         oRExtHigh_use,    f_labelText(orbExtHighLabel,    oRExtHigh_use,    showPriceInLabel), orLabelExtraOffset)
    orbExtLoLbl    := f_lbl(orbExtLoLbl,    showLabels and showORBExtEff,         oRExtLow_use,     f_labelText(orbExtLowLabel,     oRExtLow_use,     showPriceInLabel), orLabelExtraOffset)
    orbG618HiLbl   := f_lbl(orbG618HiLbl,   showLabels and showORBGoldenLinesEff, oRGoldenHigh618,  f_labelText(orbG618HighLabel,   oRGoldenHigh618,  showPriceInLabel), orLabelExtraOffset)
    orbG786HiLbl   := f_lbl(orbG786HiLbl,   showLabels and showORBGoldenLinesEff, oRGoldenHigh786,  f_labelText(orbG786HighLabel,   oRGoldenHigh786,  showPriceInLabel), orLabelExtraOffset)
    orbG618LoLbl   := f_lbl(orbG618LoLbl,   showLabels and showORBGoldenLinesEff, oRGoldenLow618,   f_labelText(orbG618LowLabel,    oRGoldenLow618,   showPriceInLabel), orLabelExtraOffset)
    orbG786LoLbl   := f_lbl(orbG786LoLbl,   showLabels and showORBGoldenLinesEff, oRGoldenLow786,   f_labelText(orbG786LowLabel,    oRGoldenLow786,   showPriceInLabel), orLabelExtraOffset)
    orbExt100HiLbl := f_lbl(orbExt100HiLbl, showLabels and showORBExt100Eff,      oRExt100High_use, f_labelText(orbExt100HighLabel, oRExt100High_use, showPriceInLabel), orLabelExtraOffset)
    orbExt100LoLbl := f_lbl(orbExt100LoLbl, showLabels and showORBExt100Eff,      oRExt100Low_use,  f_labelText(orbExt100LowLabel,  oRExt100Low_use,  showPriceInLabel), orLabelExtraOffset)
    fourHHLbl      := f_lbl(fourHHLbl,      showLabels and show4Heff,             fourHHigh,        f_labelText(fourHHLabelText,    fourHHigh,        showPriceInLabel), fourHLabelExtraOffset)
    fourHMLbl      := f_lbl(fourHMLbl,      showLabels and show4HMidEff,          fourHMid,         f_labelText(fourHMLabelText,    fourHMid,         showPriceInLabel), fourHLabelExtraOffset)
    fourHLLbl      := f_lbl(fourHLLbl,      showLabels and show4Heff,             fourHLow,         f_labelText(fourHLLabelText,    fourHLow,         showPriceInLabel), fourHLabelExtraOffset)
    whLbl          := f_lbl(whLbl,          showLabels and showCurWeek,           curWeekHigh,      f_labelText(whLabelText,        curWeekHigh,      showPriceInLabel), weekLabelExtraOffset)
    wlLbl          := f_lbl(wlLbl,          showLabels and showCurWeek,           curWeekLow,       f_labelText(wlLabelText,        curWeekLow,       showPriceInLabel), weekLabelExtraOffset)
    pwhLbl         := f_lbl(pwhLbl,         showLabels and showPW,                pWH_use,          f_labelText(pwhLabelText,       pWH_use,          showPriceInLabel), weekLabelExtraOffset)
    pwlLbl         := f_lbl(pwlLbl,         showLabels and showPW,                pWL_use,          f_labelText(pwlLabelText,       pWL_use,          showPriceInLabel), weekLabelExtraOffset)
    cmhLbl         := f_lbl(cmhLbl,         showLabels and showCurMonth,          curMonthHigh,     f_labelText(cmhLabelText,       curMonthHigh,     showPriceInLabel), monthlyLabelExtraOffset)
    cmmLbl         := f_lbl(cmmLbl,         showLabels and showCurMonth,          curMonthMid,      f_labelText(cmmLabelText,       curMonthMid,      showPriceInLabel), monthlyLabelExtraOffset)
    cmlLbl         := f_lbl(cmlLbl,         showLabels and showCurMonth,          curMonthLow,      f_labelText(cmlLabelText,       curMonthLow,      showPriceInLabel), monthlyLabelExtraOffset)
    pmhLbl         := f_lbl(pmhLbl,         showLabels and showPrevMonth,         prevMonthHigh,    f_labelText(pmhLabelText,       prevMonthHigh,    showPriceInLabel), monthlyLabelExtraOffset)
    pmlLbl         := f_lbl(pmlLbl,         showLabels and showPrevMonth,         prevMonthLow,     f_labelText(pmlLabelText,       prevMonthLow,     showPriceInLabel), monthlyLabelExtraOffset)
````
