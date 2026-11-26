# Shaakuni - Liquidity Levels & Order Blocks

- url: https://www.tradingview.com/script/PRotRcMl-Shaakuni-Liquidity-Levels-Order-Blocks/
- type: indicator
- pine_id: PUB;d7fdae49e2cf4ece8207d6b9124faede
- version: 1.0

## Description

Overview

Shaakuni - Liquidity Levels & Order Blocks is a context tool for intraday and swing charts. It draws the previous week's and previous day's highs and lows, marks the midpoint of each range, finds simple Order Blocks (zones where a strong move started), and shows a small panel with the active trading session and what price is doing around yesterday's high and low. It does not generate buy or sell signals and it does not predict anything. It only organizes reference areas on the chart so you can read price against them.

Key concepts

Liquidity levels: many traders place stop orders just beyond obvious highs and lows, such as the previous day's high or the previous week's low. Because of this, these levels are often treated as areas where price may pause, reverse or accelerate. The script draws them so you do not have to mark them by hand every day.

EQ (equilibrium): this is the 50% point between a range's high and low. Some traders treat prices above it as premium and prices below it as discount relative to that range. The script draws this midpoint for the previous week and previous day.

Order Block (OB): in this script an Order Block is the last candle of the opposite colour before a strong move that breaks recent structure. A bullish OB is the last down candle before a strong up move, and a bearish OB is the last up candle before a strong down move. The idea is that the area around that candle may matter if price returns to it. On 1H and higher timeframes the zones are labelled POI (point of interest) instead of OB.

What the script draws

Previous week high (PWH) and low (PWL) with a shaded range box and the weekly 50% line (W-EQ). The week before that is shown as thin dotted lines when "Show Previous Week" is on. Previous day high (PDH) and low (PDL) with the daily 50% line (D-EQ); daily levels are hidden on weekly and monthly charts. If a daily level sits at exactly the same price as a weekly level, the labels are merged (for example PDH / PWH). Order Blocks are drawn as boxes that extend to the right while they are untouched.

How Order Blocks are calculated

The calculation runs once per closed bar. First, the script looks back over the last N bars ("OB Structure Lookback", default 10) and finds the highest high (bullish case) or lowest low (bearish case) before the current bar. Second, if the current bar closes beyond that level, it counts as a structure break; the swing must be at least 3 bars old, so very small moves are ignored. Third, the script finds the lowest low (or highest high for the bearish case) that formed after that swing, and looks for an impulse candle between that point and the current bar: a candle in the direction of the break whose body is at least a set multiple of ATR(14) ("OB Impulse Candle", default 0.7 x ATR). If no such candle exists, no zone is created. Fourth, the Order Block is the closest opposite-coloured candle before that impulse, no further back than the swing extreme; its high-to-low range becomes the box. Fifth, the zone is kept only if price has not already traded back into it since it formed. Finally, once a later bar touches the box, the zone is marked as mitigated and, by default, hidden. Old zones are removed after a lookback that depends on the timeframe (or a manual value you set).

Important behaviour: the Order Block is drawn on the earlier candle where the zone formed, but it only appears when the bar that breaks structure closes. In other words, boxes are placed in the past after the fact. This is deliberate, but it means a zone appearing on your chart was not visible at the moment that earlier candle printed.

Session and sweep panel

The panel shows the current session in New York time (Asian 20:00-00:00, London 02:00-05:00, New York 07:00-10:00, London Close 10:00-12:00) and the status of the previous day's high and low relative to today's price. "Sweep !" means price traded beyond that level today but the latest close is back inside it. "Broken X" means the latest close is beyond the level. "Active" means neither has happened. The timezone can be automatic (handles daylight saving) or fixed to UTC-4 or UTC-5.

How to use it

Use higher-timeframe levels to frame lower-timeframe price action. For example, on a 15-minute chart, note whether price is trading near the previous day's high or the previous week's low, and whether one of them has already been swept. Treat an untouched Order Block as an area to watch and a mitigated one as already tested. Many traders combine references like these with their own confirmation and risk rules; this script is meant as a map, not a trade plan. Every element (weekly levels, daily levels, EQ lines, Order Blocks, mitigated zones, panel) can be switched off in the settings, and you can change colours, theme (dark or light), panel position and size, the OB structure lookback and the impulse size.

Why it is built this way

The ideas here (previous highs and lows, 50% levels, order blocks) are widely used and this script does not claim to have invented them. What it adds is a specific, transparent implementation in one place: Order Blocks are created only after a structure break confirmed by an ATR-scaled impulse, kept only while untouched, and removed from view once tested, and they are shown together with weekly and daily levels and a session and sweep panel so everything can be read in the same context. The source code is open, so you can check each step and adapt it.

Limitations

Weekly and daily levels are built from the bars loaded on your chart, so on low timeframes with limited history the first week or day can be incomplete. The Order Block rule is a simple mechanical approximation of a discretionary idea; it will not match every trader's definition and can create or miss zones you would not choose by eye. Mitigation is checked on every price update, so a zone can be marked as mitigated during a bar. The panel status uses the live bar and can change until the bar closes. On weekends, the most recently completed week and day are treated as the previous ones. Past reactions at a level do not guarantee future reactions. This is a visual aid and not financial advice.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) Shaakuni
//
// Shaakuni - Liquidity Levels & Order Blocks
// Version 1.4.0 (Pine Script v6)
//
// WHAT THIS SCRIPT DOES
//  1) Plots previous-week and previous-day highs/lows and their 50% (EQ) levels.
//  2) Detects simple Order Blocks (OB) / Points of Interest (POI) from a swing break + ATR impulse rule.
//  3) Shows a small panel with the active NY-time session and the status of the previous day's high/low.
//
// WHAT IT DOES NOT DO
//  No BOS/CHoCH, no FVG, no buy/sell signals. It is a context tool, not a strategy.
//
// LIMITATIONS
//  Weekly/daily levels are built from the bars loaded on the chart, so on low timeframes with limited
//  history the first week/day can be incomplete. Order Blocks are confirmed on bar close and do not repaint.
//  The panel status (Sweep/Break) is evaluated on the live bar and can change until the bar closes.
// =======================================================================

//@version=6
indicator("Shaakuni - Liquidity Levels & Order Blocks", shorttitle="Shaakuni Levels & OB", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// -----------------------------
//  INPUTS
// -----------------------------
grpUI       = "UI"
showPanel   = input.bool(true, "Show Panel", group=grpUI)
panelPos    = input.string("Top Right", "Panel Position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"], group=grpUI)
theme       = input.string("Dark", "Theme", options=["Dark","Light"], group=grpUI)
tzChoice    = input.string("Auto (DST)", "Timezone", options=["Auto (DST)","Manual UTC-4 (EDT)","Manual UTC-5 (EST)"], group=grpUI, tooltip="Sessions (NY time): Asian 20:00-00:00, London 02:00-05:00, New York 07:00-10:00, London Close 10:00-12:00")
displayName = input.string("Levels & OB", "Panel Display Name", group=grpUI, tooltip="Shown as the panel header/subtitle")

grpText     = "Text Style"
panelSize   = input.string("Small", "Panel Text Size", options=["Small","Medium","Large"], group=grpText)
headerColor = input.color(color.rgb(255,200,80), "Header Text Color", group=grpText)
labelColor  = input.color(color.rgb(160,160,160), "Label Text Color", group=grpText)

grpLevels   = "Levels"
showWeek    = input.bool(true, "Show Weekly High/Low", group=grpLevels)
showEQ      = input.bool(true, "Show Weekly EQ (50%)", group=grpLevels)
showPrevW   = input.bool(true, "Show Previous Week", group=grpLevels)
showDay     = input.bool(true, "Show Daily High/Low", group=grpLevels)
showDEQ     = input.bool(true, "Show Daily EQ (50%)", group=grpLevels)
showOB      = input.bool(true, "Show Order Blocks (OB / POI)", group=grpLevels)
showFresh   = input.bool(true, "Show Unmitigated", group=grpLevels)
showMit     = input.bool(false, "Show Mitigated", group=grpLevels)
lookbackMode= input.string("Auto", "Zone Lookback", options=["Auto","Manual"], group=grpLevels)
lookbackMan = input.int(500, "Manual Lookback (bars)", minval=30, maxval=2000, group=grpLevels)
obSwingLen  = input.int(10, "OB Structure Lookback (bars)", minval=3, maxval=50, group=grpLevels)
impMult     = input.float(0.7, "OB Impulse Candle (x ATR)", minval=0.1, maxval=5.0, step=0.1, group=grpLevels)

grpCol      = "Colors"
colBullOB   = input.color(color.new(color.rgb(41,121,255), 82), "Bull OB / POI", group=grpCol)
colBearOB   = input.color(color.new(color.rgb(255,112,67), 82), "Bear OB / POI", group=grpCol)
colEQ       = input.color(color.rgb(255, 215, 0), "Weekly EQ Color", group=grpCol)
colDEQ      = input.color(color.rgb(0, 229, 255), "Daily EQ Color", group=grpCol)

// -----------------------------
//  CONSTANTS & HELPERS
// -----------------------------
ATR_PERIOD  = 14
BOX_EXTEND  = 5
OB_MIN_HOFF = 3

isDark      = theme == "Dark"
obTxt       = timeframe.in_seconds(timeframe.period) >= 3600 ? "POI" : "OB"

// TF Checks
isWeeklyTF  = timeframe.isweekly
isMonthlyTF = timeframe.ismonthly
isHTF       = isWeeklyTF or isMonthlyTF

// Hide Daily levels if timeframe is Weekly or higher
canShowDaily = showDay and not isHTF

autoLookback() =>
    s = timeframe.in_seconds(timeframe.period)
    s <= 60     ? 2000 : s <= 300    ? 1500 : s <= 900    ? 1000 : s <= 1800   ? 700  : s <= 3600   ? 500  : s <= 14400  ? 250  : 150

zoneLB = lookbackMode == "Auto" ? autoLookback() : lookbackMan

PB   = color.new(#141414, 5)
PH   = color.new(#1f1f1f, 0)
PS   = color.new(#2d2d2d, 0)
PD   = labelColor
PBDR = color.new(#2a2a2a, 0)

pSize = panelSize == "Large" ? size.large : panelSize == "Medium" ? size.normal : size.small

C_PWH = isDark ? color.rgb(220,50,50)  : color.rgb(139,0,0)
C_PWL = isDark ? color.rgb(30,180,100) : color.rgb(10,92,52)
C_PDH = isDark ? color.rgb(255,140,0)  : color.rgb(150,69,0)
C_PDL = isDark ? color.rgb(0,150,200)  : color.rgb(0,78,124)
C_BOX = isDark ? color.new(color.gray,95) : color.new(color.rgb(120,120,120),93)

C_BOB  = isDark ? colBullOB  : color.new(color.rgb(30,90,200),68)
C_SOB  = isDark ? colBearOB  : color.new(color.rgb(200,90,40),68)

C_BOB_B  = isDark ? color.new(color.rgb(41,121,255),30) : color.new(color.rgb(30,90,200),20)
C_SOB_B  = isDark ? color.new(color.rgb(255,112,67),30) : color.new(color.rgb(200,90,40),20)

C_GRN  = color.rgb(100,200,140)
C_RED  = color.rgb(230,120,120)
C_DGY  = color.rgb(160,160,160)

tblPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left"  => position.middle_left
        => position.middle_right

clampBar(b) => math.max(b, bar_index - 499)

fmtPrice(p) => na(p) ? "-" : math.abs(p) >= 1000 ? str.tostring(math.round(p)) : str.tostring(p, format.mintick)

statusLabel(s) =>
    switch s
        "Sweep !" => "Sweep !"
        "Break"   => "Broken X"
        => "Active"

statusColor(s) =>
    switch s
        "Sweep !" => color.rgb(255,255,255)
        "Break"   => color.rgb(200,100,100)
        => C_DGY

statusBgColor(s) =>
    s == "Sweep !" ? color.new(color.rgb(0, 180, 80), 25) : PB

// -----------------------------
//  TIME & SESSION (NY)
// -----------------------------
nyTimeHM() =>
    int h = 0
    int m = 0
    if tzChoice == "Auto (DST)"
        h := hour(timenow, "America/New_York")
        m := minute(timenow, "America/New_York")
    else if tzChoice == "Manual UTC-4 (EDT)"
        h := (hour(timenow,"UTC") - 4 + 24) % 24
        m := minute(timenow,"UTC")
    else
        h := (hour(timenow,"UTC") - 5 + 24) % 24
        m := minute(timenow,"UTC")
    [h,m]

currentSession() =>
    [h,m] = nyTimeHM()
    mins = h*60 + m
    string sess = "-"
    if mins >= 1200 and mins < 1440
        sess := "Asian"
    else if mins >= 120 and mins < 300
        sess := "London"
    else if mins >= 420 and mins < 600
        sess := "New York"
    else if mins >= 600 and mins < 720
        sess := "London Close"
    sess

// -----------------------------
//  WEEKLY RANGE (PWH/PWL/EQ)
// -----------------------------
var float trkHi = na
var float trkLo = na
var int   trkHiBar = na
var int   trkLoBar = na
var float pwh = na
var float pwl = na
var int   pwhBar = na
var int   pwlBar = na
var float pwh2 = na
var float pwl2 = na
var int   pwh2Bar = na
var int   pwl2Bar = na
var bool  wkShifted = false

isNewWeek = timeframe.change("W")

if isNewWeek
    if not wkShifted
        pwh2     := pwh
        pwl2     := pwl
        pwh2Bar  := pwhBar
        pwl2Bar  := pwlBar
        pwh      := trkHi
        pwl      := trkLo
        pwhBar   := trkHiBar
        pwlBar   := trkLoBar
    trkHi     := high
    trkLo     := low
    trkHiBar  := bar_index
    trkLoBar  := bar_index
    wkShifted := false
else
    if high > trkHi or na(trkHi)
        trkHi     := high
        trkHiBar  := bar_index
    if low < trkLo or na(trkLo)
        trkLo     := low
        trkLoBar  := bar_index

isWeekend = dayofweek(timenow) == dayofweek.saturday or dayofweek(timenow) == dayofweek.sunday
wkShiftNow = barstate.islast and isWeekend and not wkShifted and not na(trkHi) and not na(trkLo) and (na(pwh) or trkHi != pwh or trkLo != pwl)

if wkShiftNow
    pwh2     := pwh
    pwl2     := pwl
    pwh2Bar  := pwhBar
    pwl2Bar  := pwlBar
    pwh      := trkHi
    pwl      := trkLo
    pwhBar   := trkHiBar
    pwlBar   := trkLoBar
    wkShifted := true

livePWH = na(pwh) ? trkHi : pwh
livePWL = na(pwl) ? trkLo : pwl

// -----------------------------
//  DAILY RANGE (PDH/PDL/DEQ) + STATUS
// -----------------------------
var float dHi = na
var float dLo = na
var int   dHiBar = na
var int   dLoBar = na
var float pdh = na
var float pdl = na
var int   pdhBar = na
var int   pdlBar = na

isNewDay = timeframe.change("D")

if isNewDay
    pdh     := dHi
    pdl     := dLo
    pdhBar  := dHiBar
    pdlBar  := dLoBar

    dHi     := high
    dLo     := low
    dHiBar  := bar_index
    dLoBar  := bar_index
else
    if high > dHi or na(dHi)
        dHi     := high
        dHiBar  := bar_index
    if low < dLo or na(dLo)
        dLo     := low
        dLoBar  := bar_index

// Status of previous-day high/low vs today's live price (stateless, recalculated on the last bar)
string pdhSt = "Active"
string pdlSt = "Active"
if barstate.islast
    if not na(pdh)
        if close > pdh
            pdhSt := "Break"
        else if dHi > pdh
            pdhSt := "Sweep !"
    if not na(pdl)
        if close < pdl
            pdlSt := "Break"
        else if dLo < pdl
            pdlSt := "Sweep !"

var bool dWkShifted = false
if isNewDay
    dWkShifted := false
bool dWkShiftNow = barstate.islast and isWeekend and not dWkShifted and not na(dHi) and not na(dLo) and (na(pdh) or dHi != pdh or dLo != pdl)
if dWkShiftNow
    pdh     := dHi
    pdl     := dLo
    pdhBar  := dHiBar
    pdlBar  := dLoBar
    dWkShifted := true

livePDH = na(pdh) ? dHi : pdh
livePDL = na(pdl) ? dLo : pdl

// -----------------------------
//  ORDER BLOCKS / POI
// -----------------------------
atrVal = ta.atr(ATR_PERIOD)

var array<int>   zType  = array.new<int>()
var array<float> zTop   = array.new<float>()
var array<float> zBot   = array.new<float>()
var array<box>   zBox   = array.new<box>()
var array<int>   zCBar  = array.new<int>()
var array<int>   zState = array.new<int>()
var array<int>   zMitBar= array.new<int>()

var int lastBullObBar = -1
var int lastBearObBar = -1

pushZone(_ty,_top,_bot,_cbar,_bx) =>
    array.push(zType,  _ty)
    array.push(zTop,   _top)
    array.push(zBot,   _bot)
    array.push(zBox,   _bx)
    array.push(zCBar,  _cbar)
    array.push(zState, 0)
    array.push(zMitBar,-1)

if barstate.isconfirmed and not na(atrVal) and bar_index > obSwingLen + 2
    // Bullish OB
    float hh   = high[1]
    int   hOff = 1
    for i = 2 to obSwingLen
        if high[i] > hh
            hh   := high[i]
            hOff := i

    if close > hh and hOff >= OB_MIN_HOFF
        float mnLow = low[1]
        int   mnOff = 1
        for i = 2 to hOff - 1
            if low[i] < mnLow
                mnLow := low[i]
                mnOff := i

        int dOff = -1
        for k = 0 to mnOff - 1
            int o = mnOff - 1 - k
            if close[o] > open[o] and (close[o] - open[o]) >= atrVal * impMult
                dOff := o
                break

        if dOff >= 0
            int obOff = mnOff
            for j = dOff + 1 to mnOff
                if close[j] < open[j]
                    obOff := j
                    break
            bool fresh = true
            if obOff >= 2
                for k = 0 to obOff - 2
                    if low[k] <= high[obOff]
                        fresh := false
                        break
            int obBar = bar_index - obOff
            if fresh and showOB and obBar != lastBullObBar
                lastBullObBar := obBar
                pushZone(5, high[obOff], low[obOff], bar_index, box.new(obBar, high[obOff], obBar + 1, low[obOff], bgcolor=C_BOB, border_color=C_BOB_B, border_width=1, text=obTxt, text_size=size.tiny, text_color=color.new(color.white,15), text_halign=text.align_center, text_valign=text.align_center))

    // Bearish OB
    float ll   = low[1]
    int   lOff = 1
    for i = 2 to obSwingLen
        if low[i] < ll
            ll   := low[i]
            lOff := i

    if close < ll and lOff >= OB_MIN_HOFF
        float mxHigh = high[1]
        int   mxOff  = 1
        for i = 2 to lOff - 1
            if high[i] > mxHigh
                mxHigh := high[i]
                mxOff  := i

        int dOff = -1
        for k = 0 to mxOff - 1
            int o = mxOff - 1 - k
            if close[o] < open[o] and (open[o] - close[o]) >= atrVal * impMult
                dOff := o
                break

        if dOff >= 0
            int obOff = mxOff
            for j = dOff + 1 to mxOff
                if close[j] > open[j]
                    obOff := j
                    break
            bool fresh = true
            if obOff >= 2
                for k = 0 to obOff - 2
                    if high[k] >= low[obOff]
                        fresh := false
                        break
            int obBar = bar_index - obOff
            if fresh and showOB and obBar != lastBearObBar
                lastBearObBar := obBar
                pushZone(6, high[obOff], low[obOff], bar_index, box.new(obBar, high[obOff], obBar + 1, low[obOff], bgcolor=C_SOB, border_color=C_SOB_B, border_width=1, text=obTxt, text_size=size.tiny, text_color=color.new(color.white,15), text_halign=text.align_center, text_valign=text.align_center))

int zsz = array.size(zType)
if zsz > 0
    int i = zsz - 1
    while i >= 0
        int created = array.get(zCBar,i)
        if bar_index > created and array.get(zState,i) == 0
            float t = array.get(zTop,i)
            float b = array.get(zBot,i)
            bool  onM = showOB
            if high >= b and low <= t
                array.set(zState,i,2)
                array.set(zMitBar,i,bar_index)
                box bx = array.get(zBox,i)
                if not na(bx)
                    if onM and showMit
                        box.set_bgcolor(bx, color.new(color.black,75))
                        box.set_border_color(bx, color.new(color.black,100))
                    else
                        box.set_bgcolor(bx, color.new(color.black,100))
                        box.set_border_color(bx, color.new(color.black,100))
        i := i - 1

zsz := array.size(zType)
if zsz > 0
    int cutoff = bar_index - zoneLB
    int j = 0
    while j < array.size(zType)
        if array.get(zCBar,j) < cutoff
            box bx = array.get(zBox,j)
            if not na(bx)
                box.delete(bx)
            array.remove(zType,  j)
            array.remove(zTop,   j)
            array.remove(zBot,   j)
            array.remove(zBox,   j)
            array.remove(zCBar,  j)
            array.remove(zState, j)
            array.remove(zMitBar,j)
        else
            j := j + 1

int boxRX = bar_index + BOX_EXTEND
zsz := array.size(zType)
if zsz > 0
    for k = 0 to zsz - 1
        box bx = array.get(zBox,k)
        if not na(bx)
            int s  = array.get(zState,k)
            int ty = array.get(zType,k)
            int mb = array.get(zMitBar,k)
            bool on = showOB
            if s < 2
                box.set_right(bx, boxRX)
                if not on or not showFresh
                    box.set_bgcolor(bx, color.new(color.black,100))
                    box.set_border_color(bx, color.new(color.black,100))
                else
                    color fc = ty == 5 ? C_BOB : C_SOB
                    color fb = ty == 5 ? C_BOB_B : C_SOB_B
                    box.set_bgcolor(bx, fc)
                    box.set_border_color(bx, fb)
            else
                if mb > 0
                    box.set_right(bx, mb + 2)
                if not on or not showMit
                    box.set_bgcolor(bx, color.new(color.black,100))
                    box.set_border_color(bx, color.new(color.black,100))
                else
                    box.set_bgcolor(bx, color.new(color.black,75))
                    box.set_border_color(bx, color.new(color.black,100))

// -----------------------------
//  DRAWING: WEEKLY, DAILY & EQ LINES
// -----------------------------
var line  lPWH  = na
var line  lPWL  = na
var line  lEQ   = na
var label lbPWH = na
var label lbPWL = na
var label lbEQ  = na
var box   bRNG  = na

var line  lPWH2 = na
var line  lPWL2 = na
var label lbPWH2 = na
var label lbPWL2 = na

var line  lPDH  = na
var line  lPDL  = na
var line  lDEQ  = na
var label lbPDH = na
var label lbPDL = na
var label lbDEQ = na

isSamePrice(p1, p2) => not na(p1) and not na(p2) and math.abs(p1 - p2) < syminfo.mintick

if (isNewWeek or wkShiftNow) and not na(pwh)
    line.delete(lPWH)
    line.delete(lPWL)
    line.delete(lEQ)
    label.delete(lbPWH)
    label.delete(lbPWL)
    label.delete(lbEQ)
    box.delete(bRNG)
    line.delete(lPWH2)
    line.delete(lPWL2)
    label.delete(lbPWH2)
    label.delete(lbPWL2)

    int x2 = bar_index + 5
    int xh = clampBar(pwhBar)
    int xl = clampBar(pwlBar)

    if showWeek
        lPWH := line.new(xh, pwh, x2, pwh, color=C_PWH, width=1)
        lPWL := line.new(xl, pwl, x2, pwl, color=C_PWL, width=1)
        bRNG := box.new(xh, pwh, x2, pwl, bgcolor=C_BOX, border_color=color.new(color.gray,100), border_width=1)
        
        bool sameHigh = canShowDaily and isSamePrice(pdh, pwh)
        bool sameLow  = canShowDaily and isSamePrice(pdl, pwl)
        
        lbPWH := label.new(x2, pwh, (sameHigh ? "PDH / PWH  " : "PWH  ") + fmtPrice(pwh), color=C_PWH, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        lbPWL := label.new(x2, pwl, (sameLow ? "PDL / PWL  " : "PWL  ") + fmtPrice(pwl), color=C_PWL, textcolor=color.white, style=label.style_label_left, size=size.tiny)

        // Weekly EQ
        if showEQ
            float eqVal = (pwh + pwl) / 2.0
            int xMin = math.min(xh, xl)
            lEQ  := line.new(xMin, eqVal, x2, eqVal, color=colEQ, width=1, style=line.style_dashed)
            lbEQ := label.new(x2, eqVal, "W-EQ (50%)  " + fmtPrice(eqVal), color=colEQ, textcolor=color.black, style=label.style_label_left, size=size.tiny)

    if showPrevW and not na(pwh2)
        int ph2 = clampBar(pwh2Bar)
        int pl2 = clampBar(pwl2Bar)
        lPWH2 := line.new(ph2, pwh2, x2, pwh2, color=color.new(C_PWH,60), width=1, style=line.style_dotted)
        lPWL2 := line.new(pl2, pwl2, x2, pwl2, color=color.new(C_PWL,60), width=1, style=line.style_dotted)
        lbPWH2 := label.new(ph2, pwh2, fmtPrice(pwh2), color=color.new(color.gray,100), textcolor=C_PWH, style=label.style_label_down, size=size.tiny)
        lbPWL2 := label.new(pl2, pwl2, fmtPrice(pwl2), color=color.new(color.gray,100), textcolor=C_PWL, style=label.style_label_up, size=size.tiny)

if barstate.islast and not isNewWeek and not wkShiftNow and not na(lPWH)
    int x2 = bar_index + 5
    line.set_x2(lPWH, x2)
    line.set_x2(lPWL, x2)
    box.set_right(bRNG, x2)
    label.set_x(lbPWH, x2)
    label.set_x(lbPWL, x2)
    if not na(lEQ)
        line.set_x2(lEQ, x2)
        label.set_x(lbEQ, x2)
    if not na(lPWH2)
        line.set_x2(lPWH2, x2)
        line.set_x2(lPWL2, x2)

// PDH / PDL / Daily EQ Drawing (Only for Intraday & Daily Charts)
if (isNewDay or dWkShiftNow) and not na(pdh)
    line.delete(lPDH)
    line.delete(lPDL)
    line.delete(lDEQ)
    label.delete(lbPDH)
    label.delete(lbPDL)
    label.delete(lbDEQ)
    
    if canShowDaily
        int dx2 = bar_index + 5
        int dh  = clampBar(pdhBar)
        int dl  = clampBar(pdlBar)
        
        bool sameHigh = showWeek and isSamePrice(pdh, pwh)
        bool sameLow  = showWeek and isSamePrice(pdl, pwl)
        
        lPDH := line.new(dh, pdh, dx2, pdh, color=C_PDH, width=1)
        lPDL := line.new(dl, pdl, dx2, pdl, color=C_PDL, width=1)
        
        if not sameHigh
            lbPDH := label.new(dx2, pdh, "PDH  " + fmtPrice(pdh), color=C_PDH, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else if not na(lbPWH)
            label.set_text(lbPWH, "PDH / PWH  " + fmtPrice(pwh))

        if not sameLow
            lbPDL := label.new(dx2, pdl, "PDL  " + fmtPrice(pdl), color=C_PDL, textcolor=color.white, style=label.style_label_left, size=size.tiny)
        else if not na(lbPWL)
            label.set_text(lbPWL, "PDL / PWL  " + fmtPrice(pwl))

        // Daily EQ
        if showDEQ
            float deqVal = (pdh + pdl) / 2.0
            int xMinD = math.min(dh, dl)
            lDEQ  := line.new(xMinD, deqVal, dx2, deqVal, color=colDEQ, width=1, style=line.style_dashed)
            lbDEQ := label.new(dx2, deqVal, "D-EQ (50%)  " + fmtPrice(deqVal), color=colDEQ, textcolor=color.black, style=label.style_label_left, size=size.tiny)

if barstate.islast and not isNewDay and not dWkShiftNow and not na(lPDH)
    if canShowDaily
        int dx2 = bar_index + 5
        line.set_x2(lPDH, dx2)
        line.set_x2(lPDL, dx2)
        if not na(lbPDH)
            label.set_x(lbPDH, dx2)
        if not na(lbPDL)
            label.set_x(lbPDL, dx2)
        if not na(lDEQ)
            line.set_x2(lDEQ, dx2)
            label.set_x(lbDEQ, dx2)
    else
        line.delete(lPDH)
        line.delete(lPDL)
        line.delete(lDEQ)
        label.delete(lbPDH)
        label.delete(lbPDL)
        label.delete(lbDEQ)

if barstate.islast and na(lPWH) and not na(trkHi) and showWeek and na(pwh)
    int x2 = bar_index + 5
    int xh = clampBar(trkHiBar)
    int xl = clampBar(trkLoBar)
    lPWH := line.new(xh, trkHi, x2, trkHi, color=C_PWH, width=1)
    lPWL := line.new(xl, trkLo, x2, trkLo, color=C_PWL, width=1)
    bRNG := box.new(xh, trkHi, x2, trkLo, bgcolor=C_BOX, border_color=color.new(color.gray,100))
    lbPWH := label.new(x2, trkHi, "PWH  " + fmtPrice(trkHi), color=C_PWH, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    lbPWL := label.new(x2, trkLo, "PWL  " + fmtPrice(trkLo), color=C_PWL, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if showEQ
        float eqVal = (trkHi + trkLo) / 2.0
        int xMin = math.min(xh, xl)
        lEQ  := line.new(xMin, eqVal, x2, eqVal, color=colEQ, width=1, style=line.style_dashed)
        lbEQ := label.new(x2, eqVal, "W-EQ (50%)  " + fmtPrice(eqVal), color=colEQ, textcolor=color.black, style=label.style_label_left, size=size.tiny)

if barstate.islast and na(lPDH) and not na(dHi) and canShowDaily and na(pdh)
    int dx2 = bar_index + 5
    int dh  = clampBar(dHiBar)
    int dl  = clampBar(dLoBar)
    lPDH := line.new(dh, dHi, dx2, dHi, color=C_PDH, width=1)
    lPDL := line.new(dl, dLo, dx2, dLo, color=C_PDL, width=1)
    lbPDH := label.new(dx2, dHi, "PDH  " + fmtPrice(dHi), color=C_PDH, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    lbPDL := label.new(dx2, dLo, "PDL  " + fmtPrice(dLo), color=C_PDL, textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if showDEQ
        float deqVal = (dHi + dLo) / 2.0
        int xMinD = math.min(dh, dl)
        lDEQ  := line.new(xMinD, deqVal, dx2, deqVal, color=colDEQ, width=1, style=line.style_dashed)
        lbDEQ := label.new(dx2, deqVal, "D-EQ (50%)  " + fmtPrice(deqVal), color=colDEQ, textcolor=color.black, style=label.style_label_left, size=size.tiny)

// -----------------------------
//  INFO PANEL
// -----------------------------
row(_tbl, _r, _lbl, _val, _lcol, _vcol, _bg) =>
    table.cell(_tbl, 0, _r, _lbl, text_color=_lcol, text_size=pSize, bgcolor=_bg, text_halign=text.align_left)
    table.cell(_tbl, 1, _r, _val, text_color=_vcol, text_size=pSize, bgcolor=_bg, text_halign=text.align_right)
    _r + 1

var table tbl = na
if showPanel and barstate.islast and (not na(livePWH) or not na(livePDH))
    if not na(tbl)
        table.delete(tbl)

    string liveSess = currentSession()
    bool   sessLive = liveSess != "-"
    string sessStr  = sessLive ? liveSess : "No Active Session"
    color  sessCol  = sessLive ? C_GRN : PD
    bool   hasDaily = canShowDaily and not na(livePDH)

    int nRows = 2 + (hasDaily ? 2 : 0)
    tbl := table.new(tblPos(panelPos), 2, nRows, bgcolor=PB, border_color=PBDR, border_width=1, frame_color=PBDR, frame_width=1)
    int r = 0
    r := row(tbl, r, "Shaakuni - " + displayName, syminfo.ticker + " / " + timeframe.period, headerColor, PD, PH)
    r := row(tbl, r, "Session", sessStr, PD, sessCol, PS)
    if hasDaily
        color bgDH = statusBgColor(pdhSt)
        color bgDL = statusBgColor(pdlSt)
        r := row(tbl, r, "Day High", statusLabel(pdhSt) + "  " + fmtPrice(livePDH), C_PDH, statusColor(pdhSt), bgDH)
        r := row(tbl, r, "Day Low",  statusLabel(pdlSt) + "  " + fmtPrice(livePDL), C_PDL, statusColor(pdlSt), bgDL)
````
