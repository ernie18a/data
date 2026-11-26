# Intraday Key Levels 

- url: https://www.tradingview.com/script/QdHj3xiA-Intraday-Key-Levels/
- type: indicator
- pine_id: PUB;5f62443259bd4a238508b51e91d13c56
- version: 2.0

## Description

PML
PMH
FRI LOD
FRI HOD 
PWL
PWH
intraday key levels equities

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// INTRADAY KEY LEVELS v8 — Pine v6 | Daily max TF + full 15m ORB
// ─────────────────────────────────────────────────────────────────
// PDH/PDL, PWH/PWL, FRI-H/FRI-L, OPEN PRICE = RTH (intraday) / full bar (daily)
// PMH/PML, ORB-H/ORB-L/ORB CLOSE = intraday timeframes only
// ORB = first 15-min opening range (9:30–9:45 ET)
// Left anchor clamped so far-back origins still render on 1m
// Display TF: ≤ Daily  |  Alerts: one-time cross per day
// ─────────────────────────────────────────────────────────────────

//@version=6
indicator("Intraday Key Levels v8", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ──────────────────────────── INPUTS ────────────────────────────

grpDO  = "Daily Open"
grpORB = "Opening Range (15m)"
grpPD  = "Previous Day"
grpPM  = "Pre-Market"
grpPW  = "Previous Week"
grpFR  = "Friday"
grpSTY = "Style"

i_showDO   = input.bool(true, "Show Daily Open",               group=grpDO)
i_showORB  = input.bool(true, "Show 15m ORB High/Low",         group=grpORB)
i_showORBC = input.bool(true, "Show 15m ORB Close",            group=grpORB)
i_showPD   = input.bool(true, "Show Previous Day High/Low",    group=grpPD)
i_showPM   = input.bool(true, "Show Pre-Market High/Low",      group=grpPM)
i_showPW   = input.bool(true, "Show Previous Week High/Low",   group=grpPW)
i_showFR   = input.bool(true, "Show Friday High/Low",          group=grpFR)

i_colDO   = input.color(color.new(#FFFFFF, 0),  "Daily Open",        group=grpDO)
i_colORBH = input.color(color.new(#18FFFF, 0),  "ORB High",          group=grpORB)
i_colORBL = input.color(color.new(#EA80FC, 0),  "ORB Low",           group=grpORB)
i_colORBC = input.color(color.new(#C6FF00, 0),  "ORB Close",         group=grpORB)
i_colPDH  = input.color(color.new(#FF6D00, 0),  "Prev Day High",     group=grpPD)
i_colPDL  = input.color(color.new(#2962FF, 0),  "Prev Day Low",      group=grpPD)
i_colPMH  = input.color(color.new(#00E676, 0),  "Pre-Market High",   group=grpPM)
i_colPML  = input.color(color.new(#AA00FF, 0),  "Pre-Market Low",    group=grpPM)
i_colPWH  = input.color(color.new(#FF1744, 0),  "Prev Week High",    group=grpPW)
i_colPWL  = input.color(color.new(#00BCD4, 0),  "Prev Week Low",     group=grpPW)
i_colFRH  = input.color(color.new(#FFD600, 0),  "Friday High",       group=grpFR)
i_colFRL  = input.color(color.new(#F50057, 0),  "Friday Low",        group=grpFR)

i_lineWidth  = input.int(2, "Line Width", minval=1, maxval=5, group=grpSTY)
i_lineStyle  = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=grpSTY)
i_labelSize  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grpSTY)

// ────────────────────── TIMEFRAME GATE ──────────────────────────

isTFValid    = timeframe.in_seconds() <= 86400   // ≤ Daily
isIntradayTF = timeframe.isintraday

// Effective show flags (PM + ORB only make sense intraday)
showORB_eff  = i_showORB  and isIntradayTF
showORBC_eff = i_showORBC and isIntradayTF
showPM_eff   = i_showPM   and isIntradayTF

// ────────────────────── STYLE HELPERS ───────────────────────────

f_lineStyle() =>
    switch i_lineStyle
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

f_labelSz() =>
    switch i_labelSize
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large

// ────────────────────── SESSION DETECTION ───────────────────────

utcH   = hour(time,   "America/New_York")
utcM   = minute(time, "America/New_York")
timeMn = utcH * 60 + utcM

// On intraday: real sessions. On daily+: treat whole bar as RTH so
// PD/PW/FRI/OPEN populate correctly (fixes blank levels/table on daily).
isPM  = isIntradayTF and timeMn >= 240 and timeMn < 570    // 4:00 – 9:30 ET
isRTH = isIntradayTF ? (timeMn >= 570 and timeMn < 960) : true
isORB = isIntradayTF and timeMn >= 570 and timeMn < 585    // 9:30 – 9:45 ET

isNewDay  = ta.change(time("D")) != 0
isNewWeek = ta.change(time("W")) != 0
dowToday  = dayofweek(time, "America/New_York")

isFridayRTH = dowToday == dayofweek.friday and isRTH

// ══════════════════════════════════════════════════════════════════
//  LEVEL TRACKING — price + origin bar_index
// ══════════════════════════════════════════════════════════════════

// ──────── DAILY OPEN (first RTH candle open) ────────
var float dailyOpen     = na,  var int dailyOpen_bar = na
var bool  dailyOpenSet  = false

if isNewDay
    dailyOpen    := na
    dailyOpen_bar := na
    dailyOpenSet := false

if isRTH and not dailyOpenSet
    dailyOpen     := open
    dailyOpen_bar := bar_index
    dailyOpenSet  := true

// ──────── 15-MIN OPENING RANGE: HIGH / LOW / CLOSE (9:30–9:45 ET) ────────
var float orbH       = na,  var int orbH_bar     = na
var float orbL       = na,  var int orbL_bar     = na
var float orbClose   = na,  var int orbClose_bar = na

if isNewDay
    orbH       := na
    orbH_bar   := na
    orbL       := na
    orbL_bar   := na
    orbClose   := na
    orbClose_bar := na

if isORB
    if na(orbH) or high > orbH
        orbH     := high
        orbH_bar := bar_index
    if na(orbL) or low < orbL
        orbL     := low
        orbL_bar := bar_index
    orbClose     := close          // last value before 9:45 = ORB close
    orbClose_bar := bar_index

// ──────── PREVIOUS DAY HIGH / LOW ────────
var float currDayH    = na,  var int currDayH_bar  = na
var float currDayL    = na,  var int currDayL_bar  = na
var float prevDayH    = na,  var int prevDayH_bar  = na
var float prevDayL    = na,  var int prevDayL_bar  = na

if isNewDay
    if not na(currDayH)
        prevDayH     := currDayH
        prevDayH_bar := currDayH_bar
    if not na(currDayL)
        prevDayL     := currDayL
        prevDayL_bar := currDayL_bar
    currDayH     := na
    currDayH_bar := na
    currDayL     := na
    currDayL_bar := na

if isRTH
    if na(currDayH) or high > currDayH
        currDayH     := high
        currDayH_bar := bar_index
    if na(currDayL) or low < currDayL
        currDayL     := low
        currDayL_bar := bar_index

// ──────── PRE-MARKET HIGH / LOW ────────
var float pmH       = na,  var int pmH_bar  = na
var float pmL       = na,  var int pmL_bar  = na
var bool  pmLocked  = false

if isNewDay
    pmH      := na
    pmL      := na
    pmH_bar  := na
    pmL_bar  := na
    pmLocked := false

if isPM and not pmLocked
    if na(pmH) or high > pmH
        pmH     := high
        pmH_bar := bar_index
    if na(pmL) or low < pmL
        pmL     := low
        pmL_bar := bar_index

if isRTH and not pmLocked
    pmLocked := true

// ──────── PREVIOUS WEEK HIGH / LOW ────────
var float currWkH    = na,  var int currWkH_bar  = na
var float currWkL    = na,  var int currWkL_bar  = na
var float prevWkH    = na,  var int prevWkH_bar  = na
var float prevWkL    = na,  var int prevWkL_bar  = na

if isNewWeek
    if not na(currWkH)
        prevWkH     := currWkH
        prevWkH_bar := currWkH_bar
    if not na(currWkL)
        prevWkL     := currWkL
        prevWkL_bar := currWkL_bar
    currWkH     := na
    currWkH_bar := na
    currWkL     := na
    currWkL_bar := na

if isRTH
    if na(currWkH) or high > currWkH
        currWkH     := high
        currWkH_bar := bar_index
    if na(currWkL) or low < currWkL
        currWkL     := low
        currWkL_bar := bar_index

// ──────── FRIDAY HIGH / LOW ────────
var float friH          = na,  var int friH_bar      = na
var float friL          = na,  var int friL_bar      = na
var float lastFriH      = na,  var int lastFriH_bar  = na
var float lastFriL      = na,  var int lastFriL_bar  = na
var bool  fridayStarted = false

if isNewDay and dowToday == dayofweek.friday
    friH     := na
    friH_bar := na
    friL     := na
    friL_bar := na
    fridayStarted := true

if isNewDay and dowToday != dayofweek.friday and fridayStarted
    lastFriH     := friH
    lastFriH_bar := friH_bar
    lastFriL     := friL
    lastFriL_bar := friL_bar
    fridayStarted := false

if isFridayRTH
    if na(friH) or high > friH
        friH     := high
        friH_bar := bar_index
    if na(friL) or low < friL
        friL     := low
        friL_bar := bar_index

dispFriH     = dowToday == dayofweek.friday ? friH     : lastFriH
dispFriH_bar = dowToday == dayofweek.friday ? friH_bar : lastFriH_bar
dispFriL     = dowToday == dayofweek.friday ? friL     : lastFriL
dispFriL_bar = dowToday == dayofweek.friday ? friL_bar : lastFriL_bar

// ══════════════════════════════════════════════════════════════════
//  DRAWING ENGINE — anchored lines + labels (right-top)
// ══════════════════════════════════════════════════════════════════

var line  lnDO   = na, var label lbDO   = na
var line  lnORBH = na, var label lbORBH = na
var line  lnORBL = na, var label lbORBL = na
var line  lnORBC = na, var label lbORBC = na
var line  lnPDH  = na, var label lbPDH  = na
var line  lnPDL  = na, var label lbPDL  = na
var line  lnPMH  = na, var label lbPMH  = na
var line  lnPML  = na, var label lbPML  = na
var line  lnPWH  = na, var label lbPWH  = na
var line  lnPWL  = na, var label lbPWL  = na
var line  lnFRH  = na, var label lbFRH  = na
var line  lnFRL  = na, var label lbFRL  = na

f_draw(_ln, _lb, _price, _originBar, _col, _tag, _show) =>
    resLn = _ln
    resLb = _lb
    if isTFValid and _show and not na(_price) and not na(_originBar)
        line.delete(resLn)
        label.delete(resLb)

        // Clamp left anchor so a far-back origin never exceeds loaded
        // history (otherwise line.new throws "too far in the past" on 1m
        // and the whole indicator renders blank).
        int maxBack    = 4900
        int safeOrigin = _originBar < bar_index - maxBack ? bar_index - maxBack : _originBar

        int rightBar = bar_index + 5

        resLn := line.new(safeOrigin, _price, rightBar, _price,
             color=_col, width=i_lineWidth, style=f_lineStyle())

        string labelTxt = _tag + "  " + str.tostring(_price, format.mintick)
        resLb := label.new(rightBar, _price, labelTxt,
             style=label.style_none,
             textcolor=_col,
             size=f_labelSz(),
             textalign=text.align_left)

    [resLn, resLb]

if barstate.islast or barstate.isrealtime
    [a0,b0]   = f_draw(lnDO,   lbDO,   dailyOpen,  dailyOpen_bar, i_colDO,   "OPEN PRICE", i_showDO)
    lnDO := a0, lbDO := b0

    [aH,bH]   = f_draw(lnORBH, lbORBH, orbH,       orbH_bar,      i_colORBH, "ORB-H",      showORB_eff)
    lnORBH := aH, lbORBH := bH
    [aL,bL]   = f_draw(lnORBL, lbORBL, orbL,       orbL_bar,      i_colORBL, "ORB-L",      showORB_eff)
    lnORBL := aL, lbORBL := bL
    [aC,bC]   = f_draw(lnORBC, lbORBC, orbClose,   orbClose_bar,  i_colORBC, "ORB CLOSE",  showORBC_eff)
    lnORBC := aC, lbORBC := bC

    [a1,b1]   = f_draw(lnPDH,  lbPDH,  prevDayH,   prevDayH_bar,  i_colPDH,  "PDH",   i_showPD)
    lnPDH := a1, lbPDH := b1
    [a2,b2]   = f_draw(lnPDL,  lbPDL,  prevDayL,   prevDayL_bar,  i_colPDL,  "PDL",   i_showPD)
    lnPDL := a2, lbPDL := b2

    [a3,b3]   = f_draw(lnPMH,  lbPMH,  pmH,        pmH_bar,       i_colPMH,  "PMH",   showPM_eff)
    lnPMH := a3, lbPMH := b3
    [a4,b4]   = f_draw(lnPML,  lbPML,  pmL,        pmL_bar,       i_colPML,  "PML",   showPM_eff)
    lnPML := a4, lbPML := b4

    [a5,b5]   = f_draw(lnPWH,  lbPWH,  prevWkH,    prevWkH_bar,   i_colPWH,  "PWH",   i_showPW)
    lnPWH := a5, lbPWH := b5
    [a6,b6]   = f_draw(lnPWL,  lbPWL,  prevWkL,    prevWkL_bar,   i_colPWL,  "PWL",   i_showPW)
    lnPWL := a6, lbPWL := b6

    [a7,b7]   = f_draw(lnFRH,  lbFRH,  dispFriH,   dispFriH_bar,  i_colFRH,  "FRI-H", i_showFR)
    lnFRH := a7, lbFRH := b7
    [a8,b8]   = f_draw(lnFRL,  lbFRL,  dispFriL,   dispFriL_bar,  i_colFRL,  "FRI-L", i_showFR)
    lnFRL := a8, lbFRL := b8

// ══════════════════════════════════════════════════════════════════
//  HIDDEN PLOTS FOR ALERTS
// ══════════════════════════════════════════════════════════════════

plot(isTFValid and i_showDO   ? dailyOpen : na, "OPEN PRICE", display=display.none)
plot(isTFValid and showORB_eff  ? orbH    : na, "ORB-H",      display=display.none)
plot(isTFValid and showORB_eff  ? orbL    : na, "ORB-L",      display=display.none)
plot(isTFValid and showORBC_eff ? orbClose: na, "ORB CLOSE",  display=display.none)
plot(isTFValid and i_showPD   ? prevDayH  : na, "PDH", display=display.none)
plot(isTFValid and i_showPD   ? prevDayL  : na, "PDL", display=display.none)
plot(isTFValid and showPM_eff ? pmH       : na, "PMH", display=display.none)
plot(isTFValid and showPM_eff ? pmL       : na, "PML", display=display.none)
plot(isTFValid and i_showPW   ? prevWkH   : na, "PWH", display=display.none)
plot(isTFValid and i_showPW   ? prevWkL   : na, "PWL", display=display.none)
plot(isTFValid and i_showFR   ? dispFriH  : na, "FRI-H", display=display.none)
plot(isTFValid and i_showFR   ? dispFriL  : na, "FRI-L", display=display.none)

// ══════════════════════════════════════════════════════════════════
//  ONE-TIME CROSS ALERTS (reset daily)
// ══════════════════════════════════════════════════════════════════

var bool xDO   = false
var bool xORBH = false, var bool xORBL = false, var bool xORBC = false
var bool xPDH  = false, var bool xPDL  = false
var bool xPMH  = false, var bool xPML  = false
var bool xPWH  = false, var bool xPWL  = false
var bool xFRH  = false, var bool xFRL  = false

if isNewDay
    xDO   := false
    xORBH := false, xORBL := false, xORBC := false
    xPDH  := false, xPDL  := false
    xPMH  := false, xPML  := false
    xPWH  := false, xPWL  := false
    xFRH  := false, xFRL  := false

if i_showDO and not xDO and not na(dailyOpen) and ta.cross(close, dailyOpen)
    alert("Price crossed OPEN PRICE " + str.tostring(dailyOpen, format.mintick), alert.freq_once_per_bar)
    xDO := true

if showORB_eff and not xORBH and not na(orbH) and ta.cross(close, orbH)
    alert("Price crossed ORB-H " + str.tostring(orbH, format.mintick), alert.freq_once_per_bar)
    xORBH := true
if showORB_eff and not xORBL and not na(orbL) and ta.cross(close, orbL)
    alert("Price crossed ORB-L " + str.tostring(orbL, format.mintick), alert.freq_once_per_bar)
    xORBL := true
if showORBC_eff and not xORBC and not na(orbClose) and ta.cross(close, orbClose)
    alert("Price crossed ORB CLOSE " + str.tostring(orbClose, format.mintick), alert.freq_once_per_bar)
    xORBC := true

if i_showPD and not xPDH and ta.cross(close, prevDayH)
    alert("Price crossed PDH " + str.tostring(prevDayH, format.mintick), alert.freq_once_per_bar)
    xPDH := true
if i_showPD and not xPDL and ta.cross(close, prevDayL)
    alert("Price crossed PDL " + str.tostring(prevDayL, format.mintick), alert.freq_once_per_bar)
    xPDL := true

if showPM_eff and not xPMH and not na(pmH) and ta.cross(close, pmH)
    alert("Price crossed PMH " + str.tostring(pmH, format.mintick), alert.freq_once_per_bar)
    xPMH := true
if showPM_eff and not xPML and not na(pmL) and ta.cross(close, pmL)
    alert("Price crossed PML " + str.tostring(pmL, format.mintick), alert.freq_once_per_bar)
    xPML := true

if i_showPW and not xPWH and ta.cross(close, prevWkH)
    alert("Price crossed PWH " + str.tostring(prevWkH, format.mintick), alert.freq_once_per_bar)
    xPWH := true
if i_showPW and not xPWL and ta.cross(close, prevWkL)
    alert("Price crossed PWL " + str.tostring(prevWkL, format.mintick), alert.freq_once_per_bar)
    xPWL := true

if i_showFR and not xFRH and not na(dispFriH) and ta.cross(close, dispFriH)
    alert("Price crossed FRI-H " + str.tostring(dispFriH, format.mintick), alert.freq_once_per_bar)
    xFRH := true
if i_showFR and not xFRL and not na(dispFriL) and ta.cross(close, dispFriL)
    alert("Price crossed FRI-L " + str.tostring(dispFriL, format.mintick), alert.freq_once_per_bar)
    xFRL := true

// ══════════════════════════════════════════════════════════════════
//  INFO TABLE (top-right)
// ══════════════════════════════════════════════════════════════════

var table tbl = table.new(position.top_right, 2, 13, bgcolor=color.new(#1e1e1e, 15), border_width=1)

if barstate.islast and isTFValid
    table.cell(tbl, 0, 0, "Level", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 0, "Price", text_color=color.white, text_size=size.small)
    if i_showDO
        table.cell(tbl, 0, 1, "OPEN PRICE", text_color=i_colDO, text_size=size.small)
        table.cell(tbl, 1, 1, str.tostring(dailyOpen, format.mintick), text_color=i_colDO, text_size=size.small)
    if showORB_eff
        table.cell(tbl, 0, 2, "ORB-H", text_color=i_colORBH, text_size=size.small)
        table.cell(tbl, 1, 2, str.tostring(orbH, format.mintick), text_color=i_colORBH, text_size=size.small)
        table.cell(tbl, 0, 3, "ORB-L", text_color=i_colORBL, text_size=size.small)
        table.cell(tbl, 1, 3, str.tostring(orbL, format.mintick), text_color=i_colORBL, text_size=size.small)
    if showORBC_eff
        table.cell(tbl, 0, 4, "ORB CLOSE", text_color=i_colORBC, text_size=size.small)
        table.cell(tbl, 1, 4, str.tostring(orbClose, format.mintick), text_color=i_colORBC, text_size=size.small)
    if i_showPD
        table.cell(tbl, 0, 5, "PDH", text_color=i_colPDH, text_size=size.small)
        table.cell(tbl, 1, 5, str.tostring(prevDayH, format.mintick), text_color=i_colPDH, text_size=size.small)
        table.cell(tbl, 0, 6, "PDL", text_color=i_colPDL, text_size=size.small)
        table.cell(tbl, 1, 6, str.tostring(prevDayL, format.mintick), text_color=i_colPDL, text_size=size.small)
    if showPM_eff
        table.cell(tbl, 0, 7, "PMH", text_color=i_colPMH, text_size=size.small)
        table.cell(tbl, 1, 7, str.tostring(pmH, format.mintick), text_color=i_colPMH, text_size=size.small)
        table.cell(tbl, 0, 8, "PML", text_color=i_colPML, text_size=size.small)
        table.cell(tbl, 1, 8, str.tostring(pmL, format.mintick), text_color=i_colPML, text_size=size.small)
    if i_showPW
        table.cell(tbl, 0, 9, "PWH", text_color=i_colPWH, text_size=size.small)
        table.cell(tbl, 1, 9, str.tostring(prevWkH, format.mintick), text_color=i_colPWH, text_size=size.small)
        table.cell(tbl, 0, 10, "PWL", text_color=i_colPWL, text_size=size.small)
        table.cell(tbl, 1, 10, str.tostring(prevWkL, format.mintick), text_color=i_colPWL, text_size=size.small)
    if i_showFR
        table.cell(tbl, 0, 11, "FRI-H", text_color=i_colFRH, text_size=size.small)
        table.cell(tbl, 1, 11, str.tostring(dispFriH, format.mintick), text_color=i_colFRH, text_size=size.small)
        table.cell(tbl, 0, 12, "FRI-L", text_color=i_colFRL, text_size=size.small)
        table.cell(tbl, 1, 12, str.tostring(dispFriL, format.mintick), text_color=i_colFRL, text_size=size.small)
````
