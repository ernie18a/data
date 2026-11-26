# Session Levels  VWAP S/R  Supply-Demand  Liquidity v6  fixed V1

- url: https://www.tradingview.com/script/Fjy9ya6u-Session-Levels-VWAP-S-R-Supply-Demand-Liquidity-v6-fixed-V1/
- type: indicator
- pine_id: PUB;c1776f3f99524409b0d8973cd83b174d
- version: 1.0

## Description

Session / Levels / VWAP / S/R / Supply-Demand / Liquidity [v6 • fixed]

## Source Code

````pine
//@version=6
indicator("Session / Levels / VWAP / S/R / Supply-Demand / Liquidity [v6 • fixed]", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
groupGeneral = "General"
string tz = input.string("Asia/Kabul", "Timezone", group = groupGeneral)
string distanceMode = input.string("Points", "Distance display", options = ["Points", "Percent"], group = groupGeneral)
bool showDistBoth = input.bool(true, "Show distance in % or points", group = groupGeneral)
int mergeTicks = input.int(5, "Merge tolerance (ticks)", minval = 0, group = groupGeneral)
string labelSizeIn = input.string("Large", "Label Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupGeneral)
bool showLevelLabels = input.bool(true, "Show labels", group = groupGeneral)
int keepSessionBoxes = input.int(20, "Keep recent session boxes", minval = 1, maxval = 100, group = groupGeneral)

groupSessionA = "Session Levels • Asia"
bool enAsia = input.bool(true, "Enable Asia", group = groupSessionA)
bool asiaFillBg = input.bool(true, "Asia Fill Session background", group = groupSessionA)
string asiaSession = input.session("0400-1300", "Asia Session", group = groupSessionA)
color asiaColor = input.color(color.new(color.yellow, 0), "Asia Box/Line Color", group = groupSessionA)
bool asiaH = input.bool(true, "H", inline = "asiaHLOC", group = groupSessionA)
bool asiaL = input.bool(true, "L", inline = "asiaHLOC", group = groupSessionA)
bool asiaO = input.bool(false, "O", inline = "asiaHLOC", group = groupSessionA)
bool asiaC = input.bool(false, "C", inline = "asiaHLOC", group = groupSessionA)
bool asiaTagNaked = input.bool(true, "Tag Asia levels as (naked) until closed", group = groupSessionA)
string asiaNakedText = input.string("naked", "Asia naked tag text", group = groupSessionA)

groupSessionL = "Session Levels • London"
bool enLondon = input.bool(true, "Enable London", group = groupSessionL)
bool londonFillBg = input.bool(false, "London Fill Session background", group = groupSessionL)
string londonSession = input.session("1200-2100", "London Session", group = groupSessionL)
color londonColor = input.color(color.new(color.blue, 0), "London Box/Line Color", group = groupSessionL)
bool londonH = input.bool(true, "H", inline = "lonHLOC", group = groupSessionL)
bool londonL = input.bool(true, "L", inline = "lonHLOC", group = groupSessionL)
bool londonO = input.bool(false, "O", inline = "lonHLOC", group = groupSessionL)
bool londonC = input.bool(false, "C", inline = "lonHLOC", group = groupSessionL)

groupSessionN = "Session Levels • New York"
bool enNY = input.bool(true, "Enable New York", group = groupSessionN)
bool nyFillBg = input.bool(false, "NY Fill Session background", group = groupSessionN)
string nySession = input.session("1600-0100", "New York Session", group = groupSessionN)
color nyColor = input.color(color.new(color.purple, 0), "NY Box/Line Color", group = groupSessionN)
bool nyH = input.bool(true, "H", inline = "nyHLOC", group = groupSessionN)
bool nyL = input.bool(true, "L", inline = "nyHLOC", group = groupSessionN)
bool nyO = input.bool(false, "O", inline = "nyHLOC", group = groupSessionN)
bool nyC = input.bool(false, "C", inline = "nyHLOC", group = groupSessionN)

groupSessionC = "Session Levels • Custom"
bool enCustom = input.bool(false, "Enable Custom Name", group = groupSessionC)
string customName = input.string("Custom", "Custom Name", group = groupSessionC)
string customSession = input.session("0000-0900", "Custom Session", group = groupSessionC)
color customColor = input.color(color.new(color.teal, 0), "Custom Color", group = groupSessionC)
bool customH = input.bool(true, "H", inline = "cusHLOC", group = groupSessionC)
bool customL = input.bool(true, "L", inline = "cusHLOC", group = groupSessionC)
bool customO = input.bool(false, "O", inline = "cusHLOC", group = groupSessionC)
bool customC = input.bool(false, "C", inline = "cusHLOC", group = groupSessionC)

groupPre = "Pre-Market Levels"
bool enPM = input.bool(true, "Enable Pre-Market", group = groupPre)
bool pmH = input.bool(true, "H", inline = "pmhl", group = groupPre)
bool pmL = input.bool(true, "L", inline = "pmhl", group = groupPre)
string pmSession = input.session("0600-1529", "Pre-Market Session", group = groupPre)
color pmColor = input.color(color.new(color.fuchsia, 0), "PM Line Color", group = groupPre)
int pmWidth = input.int(1, "Line width", minval = 1, maxval = 5, group = groupPre)

groupTimeBox = "Time Box"
bool enTimeBox = input.bool(false, "Enable Time Box", group = groupTimeBox)
string timeBoxSession = input.session("1730-1759", "Time Box (Session Format)", group = groupTimeBox)
color timeBoxFill = input.color(color.new(color.purple, 85), "Fill", inline = "tbcol", group = groupTimeBox)
color timeBoxBorder = input.color(color.new(color.purple, 0), "Border", inline = "tbcol", group = groupTimeBox)

groupSessVWAP = "Session VWAP"
bool showAsiaVWAP = input.bool(false, "Asia VWAP", group = groupSessVWAP)
bool showLondonVWAP = input.bool(false, "London VWAP", group = groupSessVWAP)
bool showNYVWAP = input.bool(false, "NY VWAP", group = groupSessVWAP)
bool showCustomVWAP = input.bool(false, "Custom VWAP", group = groupSessVWAP)

groupDVWAP = "Daily VWAP"
bool showDailyVWAP = input.bool(true, "Daily VWAP", group = groupDVWAP)
color dVwapColor = input.color(color.new(color.white, 0), "Daily VWAP Color", group = groupDVWAP)
int dVwapWidth = input.int(1, "Line width", minval = 1, maxval = 5, group = groupDVWAP)
bool showNakedDVWAP = input.bool(false, "Naked DWVAP lines", group = groupDVWAP)
color nakedDVwapColor = input.color(color.new(color.white, 0), "Naked line color", group = groupDVWAP)
int nakedDVwapWidth = input.int(1, "Naked line width", minval = 1, maxval = 5, group = groupDVWAP)
bool showDwapLabels = input.bool(true, "Show labels", group = groupDVWAP)
string nakedDVwapText = input.string("Naked dvwap", "Label text (naked)", group = groupDVWAP)
bool showClosedDVwap = input.bool(false, "Show CLOSED (filled) DWVAP", group = groupDVWAP)
string closedDVwapText = input.string("Closed dvwap", "Label text (closed)", group = groupDVWAP)

groupWVWAP = "Weekly VWAP"
bool showWeeklyVWAP = input.bool(false, "Weekly VWAP", group = groupWVWAP)
color wVwapColor = input.color(color.new(color.aqua, 0), "Weekly VWAP Color", group = groupWVWAP)
int wVwapWidth = input.int(1, "Line width", minval = 1, maxval = 5, group = groupWVWAP)

groupDay = "Day Levels"
bool showD0 = input.bool(true, "Show Daily Open (d0)", group = groupDay)
color d0Color = input.color(color.new(color.blue, 0), "D0 Line Color", group = groupDay)
bool showPDH = input.bool(true, "Show Previous Day High", group = groupDay)
color pdhColor = input.color(color.new(color.blue, 0), "High Line Color", group = groupDay)
bool showPDL = input.bool(true, "Show Previous Day Low", group = groupDay)
color pdlColor = input.color(color.new(color.blue, 0), "Low Line Color", group = groupDay)
bool showPDC = input.bool(true, "Show Previous Day Close", group = groupDay)
color pdcColor = input.color(color.new(color.blue, 0), "Close Line Color", group = groupDay)
bool showDayDiff = input.bool(true, "Show dH/dL + % diff", group = groupDay)
bool showPDO = input.bool(true, "Show Previous Day Open", group = groupDay)
color pdoColor = input.color(color.new(color.blue, 0), "Open Line Color", group = groupDay)
bool showPDCandleClose = input.bool(false, "Show PD Close (D candle)", group = groupDay)
color pdcandleColor = input.color(color.new(color.gray, 0), "PD Close (D) Color", group = groupDay)
bool tagPDNaked = input.bool(true, "Tag PD levels as (naked) until closed", group = groupDay)
string pdNakedText = input.string("naked", "Naked tag text", group = groupDay)

groupFri = "Friday Levels"
bool showFriClose = input.bool(true, "Show Friday Close", group = groupFri)
color friCloseColor = input.color(color.new(color.red, 0), "Friday Close Color", group = groupFri)
bool showFriOpen = input.bool(false, "Show Friday Open", group = groupFri)
color friOpenColor = input.color(color.new(color.blue, 0), "Friday Open Color", group = groupFri)
bool showFriHigh = input.bool(true, "Show Friday High", group = groupFri)
color friHighColor = input.color(color.new(color.blue, 0), "Friday High Color", group = groupFri)
bool showFriLow = input.bool(true, "Show Friday Low", group = groupFri)
color friLowColor = input.color(color.new(color.blue, 0), "Friday Low Color", group = groupFri)

groupWeek = "Week Levels"
bool showPrevWeek = input.bool(true, "Prev Week", group = groupWeek)
bool showPWH = input.bool(true, "H", inline = "pwhloc", group = groupWeek)
bool showPWL = input.bool(true, "L", inline = "pwhloc", group = groupWeek)
bool showPWO = input.bool(false, "O", inline = "pwhloc", group = groupWeek)
bool showPWC = input.bool(true, "C", inline = "pwhloc", group = groupWeek)
color pwhColor = input.color(color.new(color.teal, 0), "Prev W High Color", group = groupWeek)
color pwlColor = input.color(color.new(color.teal, 0), "Prev W Low Color", group = groupWeek)
color pwoColor = input.color(color.new(color.teal, 0), "Prev W Open Color", group = groupWeek)
color pwcColor = input.color(color.new(color.teal, 0), "Prev W Close Color", group = groupWeek)
bool showThisWeek = input.bool(true, "This Week", group = groupWeek)
bool showTWH = input.bool(true, "H", inline = "twhlo", group = groupWeek)
bool showTWL = input.bool(true, "L", inline = "twhlo", group = groupWeek)
bool showTWO = input.bool(true, "O", inline = "twhlo", group = groupWeek)
color twhColor = input.color(color.new(color.orange, 0), "This W High Color", group = groupWeek)
color twlColor = input.color(color.new(color.orange, 0), "This W Low Color", group = groupWeek)
color twoColor = input.color(color.new(color.orange, 0), "This W Open Color", group = groupWeek)

groupMonth = "Month Levels"
bool showPrevMonth = input.bool(true, "Prev Month", group = groupMonth)
bool showPMH = input.bool(true, "H", inline = "pmhloc", group = groupMonth)
bool showPML = input.bool(true, "L", inline = "pmhloc", group = groupMonth)
bool showPMO = input.bool(false, "O", inline = "pmhloc", group = groupMonth)
bool showPMC = input.bool(true, "C", inline = "pmhloc", group = groupMonth)
color pmhColor2 = input.color(color.new(color.orange, 0), "Prev M High Color", group = groupMonth)
color pmlColor2 = input.color(color.new(color.orange, 0), "Prev M Low Color", group = groupMonth)
color pmoColor2 = input.color(color.new(color.orange, 0), "Prev M Open Color", group = groupMonth)
color pmcColor2 = input.color(color.new(color.orange, 0), "Prev M Close Color", group = groupMonth)
bool showThisMonth = input.bool(true, "This Month", group = groupMonth)
bool showTMH = input.bool(true, "H", inline = "tmhlo", group = groupMonth)
bool showTML = input.bool(true, "L", inline = "tmhlo", group = groupMonth)
bool showTMO = input.bool(true, "O", inline = "tmhlo", group = groupMonth)
color tmhColor = input.color(color.new(color.green, 0), "This M High Color", group = groupMonth)
color tmlColor = input.color(color.new(color.green, 0), "This M Low Color", group = groupMonth)
color tmoColor = input.color(color.new(color.green, 0), "This M Open Color", group = groupMonth)

groupEQ = "EQ Levels"
bool showPdEQ = input.bool(true, "Previous Day EQ (pd EQ)", group = groupEQ)
color pdEqColor = input.color(color.new(color.blue, 0), "Pd EQ Line Color", group = groupEQ)
bool showDEQ = input.bool(true, "Intra-Day EQ (dEQ)", group = groupEQ)
color dEqColor = input.color(color.new(color.gray, 0), "DEQ Line Color", group = groupEQ)
bool showPrevWeekEQ = input.bool(false, "Previous Week EQ", group = groupEQ)
color prevWeekEqColor = input.color(color.new(color.teal, 0), "Prev Week EQ Color", group = groupEQ)
bool showThisWeekEQ = input.bool(false, "This Week EQ", group = groupEQ)
color thisWeekEqColor = input.color(color.new(color.orange, 0), "This Week EQ Color", group = groupEQ)

groupADR = "ADR Intel"
bool showADR = input.bool(true, "Show ADR block", group = groupADR)
int adrLen = input.int(10, "ADR length (days)", minval = 2, group = groupADR)
bool adrUseTR = input.bool(true, "Use True Range (TR)", group = groupADR)
bool adrShowPct = input.bool(true, "Sessions include %", group = groupADR)
bool adrShowPoints = input.bool(true, "Sessions include points", group = groupADR)
string adrPos = input.string("Top Right", "Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = groupADR)
string adrTextSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = groupADR)

groupORL = "Opening Range • London"
bool showLondonOR = input.bool(false, "Show London OR", group = groupORL)
string londonORSession = input.session("1200-2100", "London OR (Session Format)", group = groupORL)
int londonORMinutes = input.int(15, "London OR Minutes", minval = 1, group = groupORL)
color londonORHighColor = input.color(color.new(color.blue, 0), "London OR High Color", group = groupORL)
color londonORLowColor = input.color(color.new(color.blue, 0), "London OR Low Color", group = groupORL)
color londonORFill = input.color(color.new(color.blue, 85), "London OR Fill", group = groupORL)

groupORN = "Opening Range • New York"
bool showNYOR = input.bool(false, "Show NY OR", group = groupORN)
string nyORSession = input.session("1600-0100", "NY OR (Session Format)", group = groupORN)
int nyORMinutes = input.int(15, "NY OR Minutes", minval = 1, group = groupORN)
color nyORHighColor = input.color(color.new(color.fuchsia, 0), "NY OR High Color", group = groupORN)
color nyORLowColor = input.color(color.new(color.fuchsia, 0), "NY OR Low Color", group = groupORN)
color nyORFill = input.color(color.new(color.fuchsia, 85), "NY OR Fill", group = groupORN)

groupORA = "Opening Range • Asia"
bool showAsiaOR = input.bool(false, "Show Asia OR", group = groupORA)
string asiaORSession = input.session("0400-1300", "Asia OR (Session Format)", group = groupORA)
int asiaORMinutes = input.int(15, "Asia OR Minutes", minval = 1, group = groupORA)
color asiaORHighColor = input.color(color.new(color.yellow, 0), "Asia OR High Color", group = groupORA)
color asiaORLowColor = input.color(color.new(color.yellow, 0), "Asia OR Low Color", group = groupORA)
color asiaORFill = input.color(color.new(color.yellow, 85), "Asia OR Fill", group = groupORA)

groupSR = "Support / Resistance"
bool showSR = input.bool(true, "Enable S/R", group = groupSR)
int srLeft = input.int(3, "Pivot left", minval = 1, group = groupSR)
int srRight = input.int(3, "Pivot right", minval = 1, group = groupSR)
string srHTF = input.timeframe("240", "Higher TF", group = groupSR)
float srBoxATR = input.float(0.10, "Box size ATR multiplier", minval = 0.01, step = 0.01, group = groupSR)
int srKeep = input.int(12, "Max S/R zones", minval = 1, maxval = 50, group = groupSR)
color ltfResColor = input.color(color.new(color.red, 78), "LTF Resistance Box", group = groupSR)
color ltfSupColor = input.color(color.new(color.lime, 78), "LTF Support Box", group = groupSR)
color htfResColor = input.color(color.new(color.maroon, 78), "HTF Resistance Box", group = groupSR)
color htfSupColor = input.color(color.new(color.green, 78), "HTF Support Box", group = groupSR)

groupSD = "Supply / Demand"
bool showSD = input.bool(true, "Enable Supply / Demand", group = groupSD)
int sdLeft = input.int(3, "Pivot left", minval = 1, group = groupSD)
int sdRight = input.int(3, "Pivot right", minval = 1, group = groupSD)
string sdHTF = input.timeframe("240", "Higher TF", group = groupSD)
int sdKeep = input.int(12, "Max D/S zones", minval = 1, maxval = 50, group = groupSD)
color ltfSupplyColor = input.color(color.new(color.red, 82), "LTF Supply Box", group = groupSD)
color ltfDemandColor = input.color(color.new(color.green, 82), "LTF Demand Box", group = groupSD)
color htfSupplyColor = input.color(color.new(color.maroon, 82), "HTF Supply Box", group = groupSD)
color htfDemandColor = input.color(color.new(color.teal, 82), "HTF Demand Box", group = groupSD)

groupLiq = "Liquidity Levels"
bool showLiquidity = input.bool(true, "Enable Liquidity Levels", group = groupLiq)
int liqLeft = input.int(2, "Pivot left", minval = 1, group = groupLiq)
int liqRight = input.int(2, "Pivot right", minval = 1, group = groupLiq)
string liqHTF = input.timeframe("240", "Higher TF", group = groupLiq)
int liqKeep = input.int(20, "Max liquidity lines", minval = 1, maxval = 100, group = groupLiq)
color ltfLiqHighColor = input.color(color.new(color.red, 0), "LTF High-side Liquidity", group = groupLiq)
color ltfLiqLowColor = input.color(color.new(color.green, 0), "LTF Low-side Liquidity", group = groupLiq)
color htfLiqHighColor = input.color(color.new(color.maroon, 0), "HTF High-side Liquidity", group = groupLiq)
color htfLiqLowColor = input.color(color.new(color.teal, 0), "HTF Low-side Liquidity", group = groupLiq)

groupAlerts = "Alerts"
int wickToleranceTicks = input.int(0, "Wick tolerance (ticks)", minval = 0, group = groupAlerts)
int cooldownBars = input.int(30, "Global cooldown (bars)", minval = 0, group = groupAlerts)
int cooldownMinutes = input.int(30, "Global cooldown (minutes)", minval = 0, group = groupAlerts)

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
fInSession(sess, timezone) =>
    not na(time(timeframe.period, sess, timezone))

fLabelSize(sz) =>
    sz == "Tiny" ? size.tiny :
     sz == "Small" ? size.small :
     sz == "Normal" ? size.normal :
     sz == "Large" ? size.large : size.huge

fTablePos(p) =>
    p == "Top Left" ? position.top_left :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Right" ? position.bottom_right : position.top_right

fTableTextSize(sz) =>
    sz == "Tiny" ? size.tiny :
     sz == "Small" ? size.small :
     sz == "Normal" ? size.normal : size.large

fDistText(level) =>
    float diff = close - level
    string pts = str.tostring(diff, format.mintick)
    string pct = str.tostring(level != 0.0 ? (diff / level) * 100.0 : 0.0, "#.##") + "%"
    showDistBoth ? (distanceMode == "Points" ? pts + " | " + pct : pct + " | " + pts) : (distanceMode == "Points" ? pts : pct)

fTouch(level, tolTicks) =>
    float tol = tolTicks * syminfo.mintick
    not na(level) and high >= level - tol and low <= level + tol

fPushBox(array<box> bxArr, array<float> midArr, box bx, float mid, int keep) =>
    array.push(bxArr, bx)
    array.push(midArr, mid)
    if array.size(bxArr) > keep
        box.delete(array.shift(bxArr))
        array.shift(midArr)

fPushLine(array<line> lnArr, array<float> lvArr, line ln, float lv, int keep) =>
    array.push(lnArr, ln)
    array.push(lvArr, lv)
    if array.size(lnArr) > keep
        line.delete(array.shift(lnArr))
        array.shift(lvArr)

fPushOnlyBox(array<box> bxArr, box bx, int keep) =>
    array.push(bxArr, bx)
    if array.size(bxArr) > keep
        box.delete(array.shift(bxArr))

fHLine(line lnIn, bool show, int x1, float y, color col, int width) =>
    line _ln = lnIn
    if not show or na(x1) or na(y)
        if not na(_ln)
            line.delete(_ln)
        _ln := na
    else
        if na(_ln)
            _ln := line.new(x1, y, bar_index, y, xloc = xloc.bar_index, extend = extend.none, color = col, width = width)
        else
            line.set_xy1(_ln, x1, y)
            line.set_xy2(_ln, bar_index, y)
            line.set_color(_ln, col)
            line.set_width(_ln, width)
    _ln

fLevelLabel(label lbIn, bool show, float y, string txt, color bg, color fg, string sz) =>
    label _lb = lbIn
    if not show or na(y)
        if not na(_lb)
            label.delete(_lb)
        _lb := na
    else
        if not na(_lb)
            label.delete(_lb)
        _lb := label.new(bar_index, y, txt, style = label.style_label_left, color = bg, textcolor = fg, size = fLabelSize(sz))
    _lb

fZoneExists(array<float> mids, float mid, float tol) =>
    bool exists = false
    if array.size(mids) > 0
        for i = 0 to array.size(mids) - 1
            if math.abs(array.get(mids, i) - mid) <= tol
                exists := true
    exists

// ─────────────────────────────────────────────────────────────────────────────
// TIME KEYS
// ─────────────────────────────────────────────────────────────────────────────
int dayKey = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
int weekKey = year(time, tz) * 100 + weekofyear(time, tz)
int monthKey = year(time, tz) * 100 + month(time, tz)

bool newDay = barstate.isfirst ? true : dayKey != dayKey[1]
bool newWeek = barstate.isfirst ? true : weekKey != weekKey[1]
bool newMonth = barstate.isfirst ? true : monthKey != monthKey[1]

// ─────────────────────────────────────────────────────────────────────────────
// PERIOD TRACKERS
// ─────────────────────────────────────────────────────────────────────────────
var float dOpen = na
var float dHigh = na
var float dLow = na
var float dClose = na
var int dOpenBar = na
var int dHighBar = na
var int dLowBar = na
var int dCloseBar = na

var float pdOpen = na
var float pdHigh = na
var float pdLow = na
var float pdClose = na
var int pdOpenBar = na
var int pdHighBar = na
var int pdLowBar = na
var int pdCloseBar = na

var bool pdoActive = false
var bool pdhActive = false
var bool pdlActive = false
var bool pdcActive = false

var float friOpen = na
var float friHigh = na
var float friLow = na
var float friClose = na
var int friOpenBar = na
var int friHighBar = na
var int friLowBar = na
var int friCloseBar = na

var array<float> dayRanges = array.new<float>()

if newDay
    if not barstate.isfirst
        pdOpen := dOpen
        pdHigh := dHigh
        pdLow := dLow
        pdClose := dClose
        pdOpenBar := dOpenBar
        pdHighBar := dHighBar
        pdLowBar := dLowBar
        pdCloseBar := dCloseBar
        pdoActive := tagPDNaked
        pdhActive := tagPDNaked
        pdlActive := tagPDNaked
        pdcActive := tagPDNaked

        if dayofweek(time[1], tz) == dayofweek.friday
            friOpen := dOpen
            friHigh := dHigh
            friLow := dLow
            friClose := dClose
            friOpenBar := dOpenBar
            friHighBar := dHighBar
            friLowBar := dLowBar
            friCloseBar := dCloseBar

        float prevRefClose = nz(pdClose, dClose)
        float trDay = adrUseTR ? math.max(dHigh - dLow, math.max(math.abs(dHigh - prevRefClose), math.abs(dLow - prevRefClose))) : (dHigh - dLow)
        array.push(dayRanges, trDay)
        if array.size(dayRanges) > adrLen
            array.shift(dayRanges)

    dOpen := open
    dHigh := high
    dLow := low
    dClose := close
    dOpenBar := bar_index
    dHighBar := bar_index
    dLowBar := bar_index
    dCloseBar := bar_index
else
    dClose := close
    dCloseBar := bar_index
    if high >= dHigh
        dHigh := high
        dHighBar := bar_index
    if low <= dLow
        dLow := low
        dLowBar := bar_index

if pdoActive and fTouch(pdOpen, mergeTicks)
    pdoActive := false
if pdhActive and fTouch(pdHigh, mergeTicks)
    pdhActive := false
if pdlActive and fTouch(pdLow, mergeTicks)
    pdlActive := false
if pdcActive and fTouch(pdClose, mergeTicks)
    pdcActive := false

var float wOpen = na
var float wHigh = na
var float wLow = na
var float wClose = na
var int wOpenBar = na
var int wHighBar = na
var int wLowBar = na
var int wCloseBar = na

var float pwOpen = na
var float pwHigh = na
var float pwLow = na
var float pwClose = na
var int pwOpenBar = na
var int pwHighBar = na
var int pwLowBar = na
var int pwCloseBar = na

if newWeek
    if not barstate.isfirst
        pwOpen := wOpen
        pwHigh := wHigh
        pwLow := wLow
        pwClose := wClose
        pwOpenBar := wOpenBar
        pwHighBar := wHighBar
        pwLowBar := wLowBar
        pwCloseBar := wCloseBar
    wOpen := open
    wHigh := high
    wLow := low
    wClose := close
    wOpenBar := bar_index
    wHighBar := bar_index
    wLowBar := bar_index
    wCloseBar := bar_index
else
    wClose := close
    wCloseBar := bar_index
    if high >= wHigh
        wHigh := high
        wHighBar := bar_index
    if low <= wLow
        wLow := low
        wLowBar := bar_index

var float mOpen = na
var float mHigh = na
var float mLow = na
var float mClose = na
var int mOpenBar = na
var int mHighBar = na
var int mLowBar = na
var int mCloseBar = na

var float pmOpen = na
var float pmHigh = na
var float pmLow = na
var float pmClose = na
var int pmOpenBar = na
var int pmHighBar = na
var int pmLowBar = na
var int pmCloseBar = na

if newMonth
    if not barstate.isfirst
        pmOpen := mOpen
        pmHigh := mHigh
        pmLow := mLow
        pmClose := mClose
        pmOpenBar := mOpenBar
        pmHighBar := mHighBar
        pmLowBar := mLowBar
        pmCloseBar := mCloseBar
    mOpen := open
    mHigh := high
    mLow := low
    mClose := close
    mOpenBar := bar_index
    mHighBar := bar_index
    mLowBar := bar_index
    mCloseBar := bar_index
else
    mClose := close
    mCloseBar := bar_index
    if high >= mHigh
        mHigh := high
        mHighBar := bar_index
    if low <= mLow
        mLow := low
        mLowBar := bar_index

// ─────────────────────────────────────────────────────────────────────────────
// SESSION TRACKERS
// ─────────────────────────────────────────────────────────────────────────────
bool inAsia = enAsia and timeframe.isintraday and fInSession(asiaSession, tz)
bool inLondon = enLondon and timeframe.isintraday and fInSession(londonSession, tz)
bool inNY = enNY and timeframe.isintraday and fInSession(nySession, tz)
bool inCustom = enCustom and timeframe.isintraday and fInSession(customSession, tz)
bool inPM = enPM and timeframe.isintraday and fInSession(pmSession, tz)
bool inTB = enTimeBox and timeframe.isintraday and fInSession(timeBoxSession, tz)

var array<box> asiaBoxes = array.new<box>()
var array<box> londonBoxes = array.new<box>()
var array<box> nyBoxes = array.new<box>()
var array<box> customBoxes = array.new<box>()
var array<box> timeBoxes = array.new<box>()
var array<box> londonORBoxes = array.new<box>()
var array<box> nyORBoxes = array.new<box>()
var array<box> asiaORBoxes = array.new<box>()

var float aOpen = na
var float aHigh = na
var float aLow = na
var float aClose = na
var int aOpenBar = na
var int aHighBar = na
var int aLowBar = na
var int aCloseBar = na
var bool aOActive = false
var bool aHActive = false
var bool aLActive = false
var bool aCActive = false
var box asiaBox = na

if inAsia and not inAsia[1]
    aOpen := open
    aHigh := high
    aLow := low
    aClose := close
    aOpenBar := bar_index
    aHighBar := bar_index
    aLowBar := bar_index
    aCloseBar := bar_index
    asiaBox := box.new(bar_index, high, bar_index, low, border_color = asiaColor, bgcolor = asiaFillBg ? color.new(asiaColor, 88) : na)
    fPushOnlyBox(asiaBoxes, asiaBox, keepSessionBoxes)
else if inAsia
    aClose := close
    aCloseBar := bar_index
    if high >= aHigh
        aHigh := high
        aHighBar := bar_index
    if low <= aLow
        aLow := low
        aLowBar := bar_index
    if not na(asiaBox)
        box.set_right(asiaBox, bar_index)
        box.set_top(asiaBox, aHigh)
        box.set_bottom(asiaBox, aLow)
else if not inAsia and inAsia[1]
    aOActive := asiaTagNaked
    aHActive := asiaTagNaked
    aLActive := asiaTagNaked
    aCActive := asiaTagNaked

if aOActive and fTouch(aOpen, mergeTicks)
    aOActive := false
if aHActive and fTouch(aHigh, mergeTicks)
    aHActive := false
if aLActive and fTouch(aLow, mergeTicks)
    aLActive := false
if aCActive and fTouch(aClose, mergeTicks)
    aCActive := false

var float lOpen = na
var float lHigh = na
var float lLow = na
var float lClose = na
var int lOpenBar = na
var int lHighBar = na
var int lLowBar = na
var int lCloseBar = na
var box londonBox = na

if inLondon and not inLondon[1]
    lOpen := open
    lHigh := high
    lLow := low
    lClose := close
    lOpenBar := bar_index
    lHighBar := bar_index
    lLowBar := bar_index
    lCloseBar := bar_index
    londonBox := box.new(bar_index, high, bar_index, low, border_color = londonColor, bgcolor = londonFillBg ? color.new(londonColor, 88) : na)
    fPushOnlyBox(londonBoxes, londonBox, keepSessionBoxes)
else if inLondon
    lClose := close
    lCloseBar := bar_index
    if high >= lHigh
        lHigh := high
        lHighBar := bar_index
    if low <= lLow
        lLow := low
        lLowBar := bar_index
    if not na(londonBox)
        box.set_right(londonBox, bar_index)
        box.set_top(londonBox, lHigh)
        box.set_bottom(londonBox, lLow)

var float nOpen = na
var float nHigh = na
var float nLow = na
var float nClose = na
var int nOpenBar = na
var int nHighBar = na
var int nLowBar = na
var int nCloseBar = na
var box nyBox = na

if inNY and not inNY[1]
    nOpen := open
    nHigh := high
    nLow := low
    nClose := close
    nOpenBar := bar_index
    nHighBar := bar_index
    nLowBar := bar_index
    nCloseBar := bar_index
    nyBox := box.new(bar_index, high, bar_index, low, border_color = nyColor, bgcolor = nyFillBg ? color.new(nyColor, 88) : na)
    fPushOnlyBox(nyBoxes, nyBox, keepSessionBoxes)
else if inNY
    nClose := close
    nCloseBar := bar_index
    if high >= nHigh
        nHigh := high
        nHighBar := bar_index
    if low <= nLow
        nLow := low
        nLowBar := bar_index
    if not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nHigh)
        box.set_bottom(nyBox, nLow)

var float cOpen = na
var float cHigh = na
var float cLow = na
var float cClose = na
var int cOpenBar = na
var int cHighBar = na
var int cLowBar = na
var int cCloseBar = na
var box customBox = na

if inCustom and not inCustom[1]
    cOpen := open
    cHigh := high
    cLow := low
    cClose := close
    cOpenBar := bar_index
    cHighBar := bar_index
    cLowBar := bar_index
    cCloseBar := bar_index
    customBox := box.new(bar_index, high, bar_index, low, border_color = customColor, bgcolor = color.new(customColor, 88))
    fPushOnlyBox(customBoxes, customBox, keepSessionBoxes)
else if inCustom
    cClose := close
    cCloseBar := bar_index
    if high >= cHigh
        cHigh := high
        cHighBar := bar_index
    if low <= cLow
        cLow := low
        cLowBar := bar_index
    if not na(customBox)
        box.set_right(customBox, bar_index)
        box.set_top(customBox, cHigh)
        box.set_bottom(customBox, cLow)

var float pmSessHigh = na
var float pmSessLow = na
var int pmSessHighBar = na
var int pmSessLowBar = na

if inPM and not inPM[1]
    pmSessHigh := high
    pmSessLow := low
    pmSessHighBar := bar_index
    pmSessLowBar := bar_index
else if inPM
    if high >= pmSessHigh
        pmSessHigh := high
        pmSessHighBar := bar_index
    if low <= pmSessLow
        pmSessLow := low
        pmSessLowBar := bar_index

var box sessionTimeBox = na
var float tbHigh = na
var float tbLow = na
if inTB and not inTB[1]
    tbHigh := high
    tbLow := low
    sessionTimeBox := box.new(bar_index, tbHigh, bar_index, tbLow, border_color = timeBoxBorder, bgcolor = timeBoxFill)
    fPushOnlyBox(timeBoxes, sessionTimeBox, keepSessionBoxes)
else if inTB
    tbHigh := math.max(nz(tbHigh, high), high)
    tbLow := math.min(nz(tbLow, low), low)
    if not na(sessionTimeBox)
        box.set_right(sessionTimeBox, bar_index)
        box.set_top(sessionTimeBox, tbHigh)
        box.set_bottom(sessionTimeBox, tbLow)

// ─────────────────────────────────────────────────────────────────────────────
// VWAPS
// ─────────────────────────────────────────────────────────────────────────────
float src = hlc3

var float asiaPV = na
var float asiaVol = na
float asiaVW = na
if inAsia and not inAsia[1]
    asiaPV := src * volume
    asiaVol := volume
else if inAsia
    asiaPV += src * volume
    asiaVol += volume
asiaVW := inAsia and asiaVol != 0 ? asiaPV / asiaVol : na

var float londonPV = na
var float londonVol = na
float londonVW = na
if inLondon and not inLondon[1]
    londonPV := src * volume
    londonVol := volume
else if inLondon
    londonPV += src * volume
    londonVol += volume
londonVW := inLondon and londonVol != 0 ? londonPV / londonVol : na

var float nyPV = na
var float nyVol = na
float nyVW = na
if inNY and not inNY[1]
    nyPV := src * volume
    nyVol := volume
else if inNY
    nyPV += src * volume
    nyVol += volume
nyVW := inNY and nyVol != 0 ? nyPV / nyVol : na

var float customPV = na
var float customVol = na
float customVW = na
if inCustom and not inCustom[1]
    customPV := src * volume
    customVol := volume
else if inCustom
    customPV += src * volume
    customVol += volume
customVW := inCustom and customVol != 0 ? customPV / customVol : na

var float dayPV = na
var float dayVol = na
var float prevDayVW = na
var bool prevDayVWActive = false

if newDay
    if not barstate.isfirst
        prevDayVW := dayVol != 0 ? dayPV / dayVol : na
        prevDayVWActive := showNakedDVWAP
    dayPV := src * volume
    dayVol := volume
else
    dayPV += src * volume
    dayVol += volume

float dayVW = dayVol != 0 ? dayPV / dayVol : na

var float weekPV = na
var float weekVol = na
if newWeek
    weekPV := src * volume
    weekVol := volume
else
    weekPV += src * volume
    weekVol += volume

float weekVW = weekVol != 0 ? weekPV / weekVol : na

if prevDayVWActive and fTouch(prevDayVW, mergeTicks)
    prevDayVWActive := false

// ─────────────────────────────────────────────────────────────────────────────
// OPENING RANGES
// ─────────────────────────────────────────────────────────────────────────────
fOrWindow(active, mins, startTs) =>
    active and not na(startTs) and (time - startTs) < mins * 60000

bool inLOr = timeframe.isintraday and showLondonOR and fInSession(londonORSession, tz)
var int lorStartTs = na
var int lorStartBar = na
var float lorHigh = na
var float lorLow = na
var box lorBox = na
if inLOr and not inLOr[1]
    lorStartTs := time
    lorStartBar := bar_index
    lorHigh := high
    lorLow := low
    lorBox := box.new(bar_index, high, bar_index, low, border_color = londonORHighColor, bgcolor = londonORFill)
    fPushOnlyBox(londonORBoxes, lorBox, keepSessionBoxes)
else if fOrWindow(inLOr, londonORMinutes, lorStartTs)
    lorHigh := math.max(nz(lorHigh, high), high)
    lorLow := math.min(nz(lorLow, low), low)
    if not na(lorBox)
        box.set_right(lorBox, bar_index)
        box.set_top(lorBox, lorHigh)
        box.set_bottom(lorBox, lorLow)

bool inNOr = timeframe.isintraday and showNYOR and fInSession(nyORSession, tz)
var int norStartTs = na
var int norStartBar = na
var float norHigh = na
var float norLow = na
var box norBox = na
if inNOr and not inNOr[1]
    norStartTs := time
    norStartBar := bar_index
    norHigh := high
    norLow := low
    norBox := box.new(bar_index, high, bar_index, low, border_color = nyORHighColor, bgcolor = nyORFill)
    fPushOnlyBox(nyORBoxes, norBox, keepSessionBoxes)
else if fOrWindow(inNOr, nyORMinutes, norStartTs)
    norHigh := math.max(nz(norHigh, high), high)
    norLow := math.min(nz(norLow, low), low)
    if not na(norBox)
        box.set_right(norBox, bar_index)
        box.set_top(norBox, norHigh)
        box.set_bottom(norBox, norLow)

bool inAOr = timeframe.isintraday and showAsiaOR and fInSession(asiaORSession, tz)
var int aorStartTs = na
var int aorStartBar = na
var float aorHigh = na
var float aorLow = na
var box aorBox = na
if inAOr and not inAOr[1]
    aorStartTs := time
    aorStartBar := bar_index
    aorHigh := high
    aorLow := low
    aorBox := box.new(bar_index, high, bar_index, low, border_color = asiaORHighColor, bgcolor = asiaORFill)
    fPushOnlyBox(asiaORBoxes, aorBox, keepSessionBoxes)
else if fOrWindow(inAOr, asiaORMinutes, aorStartTs)
    aorHigh := math.max(nz(aorHigh, high), high)
    aorLow := math.min(nz(aorLow, low), low)
    if not na(aorBox)
        box.set_right(aorBox, bar_index)
        box.set_top(aorBox, aorHigh)
        box.set_bottom(aorBox, aorLow)

// ─────────────────────────────────────────────────────────────────────────────
// S/R + SUPPLY/DEMAND + LIQUIDITY
// ─────────────────────────────────────────────────────────────────────────────
float atr14 = ta.atr(14)
float zonePad = atr14 * srBoxATR
float tol = mergeTicks * syminfo.mintick

var array<box> srBoxes = array.new<box>()
var array<float> srMids = array.new<float>()

if showSR
    float pl = ta.pivotlow(low, srLeft, srRight)
    float ph = ta.pivothigh(high, srLeft, srRight)

    if not na(pl)
        float mid = pl
        if not fZoneExists(srMids, mid, tol)
            box bx = box.new(bar_index - srRight, mid + zonePad, bar_index + 60, mid - zonePad, border_color = color.new(ltfSupColor, 0), bgcolor = ltfSupColor)
            fPushBox(srBoxes, srMids, bx, mid, srKeep)

    if not na(ph)
        float mid = ph
        if not fZoneExists(srMids, mid, tol)
            box bx = box.new(bar_index - srRight, mid + zonePad, bar_index + 60, mid - zonePad, border_color = color.new(ltfResColor, 0), bgcolor = ltfResColor)
            fPushBox(srBoxes, srMids, bx, mid, srKeep)

    float htfPL = request.security(syminfo.tickerid, srHTF, ta.pivotlow(low, srLeft, srRight))
    float htfPH = request.security(syminfo.tickerid, srHTF, ta.pivothigh(high, srLeft, srRight))
    float htfATR = request.security(syminfo.tickerid, srHTF, ta.atr(14))
    float htfPad = htfATR * srBoxATR

    if not na(htfPL) and na(htfPL[1])
        float mid = htfPL
        if not fZoneExists(srMids, mid, tol)
            box bx = box.new(bar_index, mid + htfPad, bar_index + 120, mid - htfPad, border_color = color.new(htfSupColor, 0), bgcolor = htfSupColor)
            fPushBox(srBoxes, srMids, bx, mid, srKeep)

    if not na(htfPH) and na(htfPH[1])
        float mid = htfPH
        if not fZoneExists(srMids, mid, tol)
            box bx = box.new(bar_index, mid + htfPad, bar_index + 120, mid - htfPad, border_color = color.new(htfResColor, 0), bgcolor = htfResColor)
            fPushBox(srBoxes, srMids, bx, mid, srKeep)

var array<box> sdBoxes = array.new<box>()
var array<float> sdMids = array.new<float>()

if showSD
    float sdPh = ta.pivothigh(high, sdLeft, sdRight)
    float sdPl = ta.pivotlow(low, sdLeft, sdRight)

    if not na(sdPh)
        float zTop = high[sdRight]
        float zBot = math.min(open[sdRight], close[sdRight])
        float mid = (zTop + zBot) * 0.5
        if not fZoneExists(sdMids, mid, tol)
            box bx = box.new(bar_index - sdRight, zTop, bar_index + 60, zBot, border_color = color.new(ltfSupplyColor, 0), bgcolor = ltfSupplyColor)
            fPushBox(sdBoxes, sdMids, bx, mid, sdKeep)

    if not na(sdPl)
        float zTop = math.max(open[sdRight], close[sdRight])
        float zBot = low[sdRight]
        float mid = (zTop + zBot) * 0.5
        if not fZoneExists(sdMids, mid, tol)
            box bx = box.new(bar_index - sdRight, zTop, bar_index + 60, zBot, border_color = color.new(ltfDemandColor, 0), bgcolor = ltfDemandColor)
            fPushBox(sdBoxes, sdMids, bx, mid, sdKeep)

    float htfSdPh = request.security(syminfo.tickerid, sdHTF, ta.pivothigh(high, sdLeft, sdRight))
    float htfSdPl = request.security(syminfo.tickerid, sdHTF, ta.pivotlow(low, sdLeft, sdRight))
    float htfBodyLow = request.security(syminfo.tickerid, sdHTF, math.min(open[sdRight], close[sdRight]))
    float htfBodyHigh = request.security(syminfo.tickerid, sdHTF, math.max(open[sdRight], close[sdRight]))

    if not na(htfSdPh) and na(htfSdPh[1])
        float zTop = htfSdPh
        float zBot = htfBodyLow
        float mid = (zTop + zBot) * 0.5
        if not fZoneExists(sdMids, mid, tol)
            box bx = box.new(bar_index, zTop, bar_index + 120, zBot, border_color = color.new(htfSupplyColor, 0), bgcolor = htfSupplyColor)
            fPushBox(sdBoxes, sdMids, bx, mid, sdKeep)

    if not na(htfSdPl) and na(htfSdPl[1])
        float zTop = htfBodyHigh
        float zBot = htfSdPl
        float mid = (zTop + zBot) * 0.5
        if not fZoneExists(sdMids, mid, tol)
            box bx = box.new(bar_index, zTop, bar_index + 120, zBot, border_color = color.new(htfDemandColor, 0), bgcolor = htfDemandColor)
            fPushBox(sdBoxes, sdMids, bx, mid, sdKeep)

var array<line> liqLines = array.new<line>()
var array<float> liqLvls = array.new<float>()

if showLiquidity
    float ltfLiqH = ta.pivothigh(high, liqLeft, liqRight)
    float ltfLiqL = ta.pivotlow(low, liqLeft, liqRight)

    if not na(ltfLiqH)
        float lv = ltfLiqH
        if not fZoneExists(liqLvls, lv, tol)
            line ln = line.new(bar_index - liqRight, lv, bar_index + 80, lv, color = ltfLiqHighColor, width = 1)
            fPushLine(liqLines, liqLvls, ln, lv, liqKeep)

    if not na(ltfLiqL)
        float lv = ltfLiqL
        if not fZoneExists(liqLvls, lv, tol)
            line ln = line.new(bar_index - liqRight, lv, bar_index + 80, lv, color = ltfLiqLowColor, width = 1)
            fPushLine(liqLines, liqLvls, ln, lv, liqKeep)

    float htfLiqH = request.security(syminfo.tickerid, liqHTF, ta.pivothigh(high, liqLeft, liqRight))
    float htfLiqL = request.security(syminfo.tickerid, liqHTF, ta.pivotlow(low, liqLeft, liqRight))

    if not na(htfLiqH) and na(htfLiqH[1])
        float lv = htfLiqH
        if not fZoneExists(liqLvls, lv, tol)
            line ln = line.new(bar_index, lv, bar_index + 120, lv, color = htfLiqHighColor, width = 2)
            fPushLine(liqLines, liqLvls, ln, lv, liqKeep)

    if not na(htfLiqL) and na(htfLiqL[1])
        float lv = htfLiqL
        if not fZoneExists(liqLvls, lv, tol)
            line ln = line.new(bar_index, lv, bar_index + 120, lv, color = htfLiqLowColor, width = 2)
            fPushLine(liqLines, liqLvls, ln, lv, liqKeep)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW LEVEL LINES
// ─────────────────────────────────────────────────────────────────────────────
var line lnAO = na
var line lnAH = na
var line lnAL = na
var line lnAC = na

var line lnLO = na
var line lnLH = na
var line lnLL = na
var line lnLC = na

var line lnNO = na
var line lnNH = na
var line lnNL = na
var line lnNC = na

var line lnCO = na
var line lnCH = na
var line lnCL = na
var line lnCC = na

var line lnPMH = na
var line lnPML = na

var line lnD0 = na
var line lnPDH = na
var line lnPDL = na
var line lnPDO = na
var line lnPDC = na
var line lnPDCD = na

var line lnFriO = na
var line lnFriH = na
var line lnFriL = na
var line lnFriC = na

var line lnPWH = na
var line lnPWL = na
var line lnPWO = na
var line lnPWC = na
var line lnTWH = na
var line lnTWL = na
var line lnTWO = na

var line lnPMH2 = na
var line lnPML2 = na
var line lnPMO2 = na
var line lnPMC2 = na
var line lnTMH = na
var line lnTML = na
var line lnTMO = na

var line lnPdEQ = na
var line lnDEQ = na
var line lnPwEQ = na
var line lnTwEQ = na

var line lnLORH = na
var line lnLORL = na
var line lnNORH = na
var line lnNORL = na
var line lnAORH = na
var line lnAORL = na

lnAO := fHLine(lnAO, enAsia and asiaO and not na(aOpen) and (inAsia or not asiaTagNaked or aOActive), aOpenBar, aOpen, asiaColor, 1)
lnAH := fHLine(lnAH, enAsia and asiaH and not na(aHigh) and (inAsia or not asiaTagNaked or aHActive), aHighBar, aHigh, asiaColor, 1)
lnAL := fHLine(lnAL, enAsia and asiaL and not na(aLow) and (inAsia or not asiaTagNaked or aLActive), aLowBar, aLow, asiaColor, 1)
lnAC := fHLine(lnAC, enAsia and asiaC and not na(aClose) and (inAsia or not asiaTagNaked or aCActive), aCloseBar, aClose, asiaColor, 1)

lnLO := fHLine(lnLO, enLondon and londonO and not na(lOpen), lOpenBar, lOpen, londonColor, 1)
lnLH := fHLine(lnLH, enLondon and londonH and not na(lHigh), lHighBar, lHigh, londonColor, 1)
lnLL := fHLine(lnLL, enLondon and londonL and not na(lLow), lLowBar, lLow, londonColor, 1)
lnLC := fHLine(lnLC, enLondon and londonC and not na(lClose), lCloseBar, lClose, londonColor, 1)

lnNO := fHLine(lnNO, enNY and nyO and not na(nOpen), nOpenBar, nOpen, nyColor, 1)
lnNH := fHLine(lnNH, enNY and nyH and not na(nHigh), nHighBar, nHigh, nyColor, 1)
lnNL := fHLine(lnNL, enNY and nyL and not na(nLow), nLowBar, nLow, nyColor, 1)
lnNC := fHLine(lnNC, enNY and nyC and not na(nClose), nCloseBar, nClose, nyColor, 1)

lnCO := fHLine(lnCO, enCustom and customO and not na(cOpen), cOpenBar, cOpen, customColor, 1)
lnCH := fHLine(lnCH, enCustom and customH and not na(cHigh), cHighBar, cHigh, customColor, 1)
lnCL := fHLine(lnCL, enCustom and customL and not na(cLow), cLowBar, cLow, customColor, 1)
lnCC := fHLine(lnCC, enCustom and customC and not na(cClose), cCloseBar, cClose, customColor, 1)

lnPMH := fHLine(lnPMH, enPM and pmH and not na(pmSessHigh), pmSessHighBar, pmSessHigh, pmColor, pmWidth)
lnPML := fHLine(lnPML, enPM and pmL and not na(pmSessLow), pmSessLowBar, pmSessLow, pmColor, pmWidth)

lnD0 := fHLine(lnD0, showD0 and not na(dOpen), dOpenBar, dOpen, d0Color, 1)
lnPDH := fHLine(lnPDH, showPDH and not na(pdHigh) and (not tagPDNaked or pdhActive), pdHighBar, pdHigh, pdhColor, 1)
lnPDL := fHLine(lnPDL, showPDL and not na(pdLow) and (not tagPDNaked or pdlActive), pdLowBar, pdLow, pdlColor, 1)
lnPDO := fHLine(lnPDO, showPDO and not na(pdOpen) and (not tagPDNaked or pdoActive), pdOpenBar, pdOpen, pdoColor, 1)
lnPDC := fHLine(lnPDC, showPDC and not na(pdClose) and (not tagPDNaked or pdcActive), pdCloseBar, pdClose, pdcColor, 1)
lnPDCD := fHLine(lnPDCD, showPDCandleClose and not na(pdClose), pdCloseBar, pdClose, pdcandleColor, 1)

lnFriO := fHLine(lnFriO, showFriOpen and not na(friOpen), friOpenBar, friOpen, friOpenColor, 1)
lnFriH := fHLine(lnFriH, showFriHigh and not na(friHigh), friHighBar, friHigh, friHighColor, 1)
lnFriL := fHLine(lnFriL, showFriLow and not na(friLow), friLowBar, friLow, friLowColor, 1)
lnFriC := fHLine(lnFriC, showFriClose and not na(friClose), friCloseBar, friClose, friCloseColor, 1)

lnPWH := fHLine(lnPWH, showPrevWeek and showPWH and not na(pwHigh), pwHighBar, pwHigh, pwhColor, 1)
lnPWL := fHLine(lnPWL, showPrevWeek and showPWL and not na(pwLow), pwLowBar, pwLow, pwlColor, 1)
lnPWO := fHLine(lnPWO, showPrevWeek and showPWO and not na(pwOpen), pwOpenBar, pwOpen, pwoColor, 1)
lnPWC := fHLine(lnPWC, showPrevWeek and showPWC and not na(pwClose), pwCloseBar, pwClose, pwcColor, 1)
lnTWH := fHLine(lnTWH, showThisWeek and showTWH and not na(wHigh), wHighBar, wHigh, twhColor, 1)
lnTWL := fHLine(lnTWL, showThisWeek and showTWL and not na(wLow), wLowBar, wLow, twlColor, 1)
lnTWO := fHLine(lnTWO, showThisWeek and showTWO and not na(wOpen), wOpenBar, wOpen, twoColor, 1)

lnPMH2 := fHLine(lnPMH2, showPrevMonth and showPMH and not na(pmHigh), pmHighBar, pmHigh, pmhColor2, 1)
lnPML2 := fHLine(lnPML2, showPrevMonth and showPML and not na(pmLow), pmLowBar, pmLow, pmlColor2, 1)
lnPMO2 := fHLine(lnPMO2, showPrevMonth and showPMO and not na(pmOpen), pmOpenBar, pmOpen, pmoColor2, 1)
lnPMC2 := fHLine(lnPMC2, showPrevMonth and showPMC and not na(pmClose), pmCloseBar, pmClose, pmcColor2, 1)
lnTMH := fHLine(lnTMH, showThisMonth and showTMH and not na(mHigh), mHighBar, mHigh, tmhColor, 1)
lnTML := fHLine(lnTML, showThisMonth and showTML and not na(mLow), mLowBar, mLow, tmlColor, 1)
lnTMO := fHLine(lnTMO, showThisMonth and showTMO and not na(mOpen), mOpenBar, mOpen, tmoColor, 1)

float pdEQ = (pdHigh + pdLow) * 0.5
float dEQ = (dHigh + dLow) * 0.5
float pwEQ = (pwHigh + pwLow) * 0.5
float twEQ = (wHigh + wLow) * 0.5

lnPdEQ := fHLine(lnPdEQ, showPdEQ and not na(pdEQ), pdLowBar, pdEQ, pdEqColor, 1)
lnDEQ := fHLine(lnDEQ, showDEQ and not na(dEQ), dLowBar, dEQ, dEqColor, 1)
lnPwEQ := fHLine(lnPwEQ, showPrevWeekEQ and not na(pwEQ), pwLowBar, pwEQ, prevWeekEqColor, 1)
lnTwEQ := fHLine(lnTwEQ, showThisWeekEQ and not na(twEQ), wLowBar, twEQ, thisWeekEqColor, 1)

lnLORH := fHLine(lnLORH, showLondonOR and not na(lorHigh), lorStartBar, lorHigh, londonORHighColor, 1)
lnLORL := fHLine(lnLORL, showLondonOR and not na(lorLow), lorStartBar, lorLow, londonORLowColor, 1)
lnNORH := fHLine(lnNORH, showNYOR and not na(norHigh), norStartBar, norHigh, nyORHighColor, 1)
lnNORL := fHLine(lnNORL, showNYOR and not na(norLow), norStartBar, norLow, nyORLowColor, 1)
lnAORH := fHLine(lnAORH, showAsiaOR and not na(aorHigh), aorStartBar, aorHigh, asiaORHighColor, 1)
lnAORL := fHLine(lnAORL, showAsiaOR and not na(aorLow), aorStartBar, aorLow, asiaORLowColor, 1)

// ─────────────────────────────────────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────────────────────────────────────
var label lbAH = na
var label lbAL = na
var label lbPDH = na
var label lbPDL = na
var label lbDV = na
var label lbDiff = na

lbAH := fLevelLabel(lbAH, showLevelLabels and enAsia and asiaH and not na(aHigh), aHigh, "Asia H " + (aHActive ? "(" + asiaNakedText + ")\n" : "\n") + fDistText(aHigh), color.new(asiaColor, 15), color.white, labelSizeIn)
lbAL := fLevelLabel(lbAL, showLevelLabels and enAsia and asiaL and not na(aLow), aLow, "Asia L " + (aLActive ? "(" + asiaNakedText + ")\n" : "\n") + fDistText(aLow), color.new(asiaColor, 15), color.white, labelSizeIn)
lbPDH := fLevelLabel(lbPDH, showLevelLabels and showPDH and not na(pdHigh), pdHigh, "PDH " + ((tagPDNaked and pdhActive) ? "(" + pdNakedText + ")\n" : "\n") + fDistText(pdHigh), color.new(pdhColor, 15), color.white, labelSizeIn)
lbPDL := fLevelLabel(lbPDL, showLevelLabels and showPDL and not na(pdLow), pdLow, "PDL " + ((tagPDNaked and pdlActive) ? "(" + pdNakedText + ")\n" : "\n") + fDistText(pdLow), color.new(pdlColor, 15), color.white, labelSizeIn)
lbDV := fLevelLabel(lbDV, showDwapLabels and not na(prevDayVW), prevDayVW, (prevDayVWActive ? nakedDVwapText : closedDVwapText) + "\n" + fDistText(prevDayVW), color.new(nakedDVwapColor, 0), color.black, labelSizeIn)

if showDayDiff and not na(pdHigh) and not na(pdLow)
    float rng = pdHigh - pdLow
    float pct = pdLow != 0 ? (rng / pdLow) * 100.0 : 0.0
    lbDiff := fLevelLabel(lbDiff, true, pdHigh, "dH/dL: " + str.tostring(rng, format.mintick) + " | " + str.tostring(pct, "#.##") + "%", color.new(color.gray, 40), color.white, labelSizeIn)
else
    if not na(lbDiff)
        label.delete(lbDiff)
        lbDiff := na

// ─────────────────────────────────────────────────────────────────────────────
// VWAP PLOTS
// ─────────────────────────────────────────────────────────────────────────────
plot(showAsiaVWAP ? asiaVW : na, "Asia VWAP", color = asiaColor, linewidth = 2, style = plot.style_linebr)
plot(showLondonVWAP ? londonVW : na, "London VWAP", color = londonColor, linewidth = 2, style = plot.style_linebr)
plot(showNYVWAP ? nyVW : na, "NY VWAP", color = nyColor, linewidth = 2, style = plot.style_linebr)
plot(showCustomVWAP ? customVW : na, "Custom VWAP", color = customColor, linewidth = 2, style = plot.style_linebr)
plot(showDailyVWAP ? dayVW : na, "Daily VWAP", color = dVwapColor, linewidth = dVwapWidth, style = plot.style_linebr)
plot(showWeeklyVWAP ? weekVW : na, "Weekly VWAP", color = wVwapColor, linewidth = wVwapWidth, style = plot.style_linebr)
plot(showNakedDVWAP and prevDayVWActive ? prevDayVW : na, "Naked DVWAP", color = nakedDVwapColor, linewidth = nakedDVwapWidth, style = plot.style_linebr)
plot(showClosedDVwap and not prevDayVWActive ? prevDayVW : na, "Closed DVWAP", color = color.new(nakedDVwapColor, 35), linewidth = nakedDVwapWidth, style = plot.style_linebr)

// ─────────────────────────────────────────────────────────────────────────────
// ADR TABLE
// ─────────────────────────────────────────────────────────────────────────────
float adr = na
if array.size(dayRanges) > 0
    float sumR = 0.0
    for i = 0 to array.size(dayRanges) - 1
        sumR += array.get(dayRanges, i)
    adr := sumR / array.size(dayRanges)

float currDayRange = dHigh - dLow
float asiaRange = not na(aHigh) and not na(aLow) ? aHigh - aLow : na
float londonRange = not na(lHigh) and not na(lLow) ? lHigh - lLow : na
float nyRange = not na(nHigh) and not na(nLow) ? nHigh - nLow : na

var table adrTable = table.new(fTablePos(adrPos), 2, 5, bgcolor = color.new(color.black, 15), border_width = 1)
if barstate.islast and showADR
    table.cell(adrTable, 0, 0, "ADR", text_color = color.white, text_size = fTableTextSize(adrTextSize))
    table.cell(adrTable, 1, 0, str.tostring(adr, format.mintick), text_color = color.white, text_size = fTableTextSize(adrTextSize))

    string dTxt = adrShowPoints ? str.tostring(currDayRange, format.mintick) : ""
    if adrShowPct and not na(adr) and adr != 0
        dTxt += (str.length(dTxt) > 0 ? " | " : "") + str.tostring(currDayRange / adr * 100.0, "#.##") + "%"
    table.cell(adrTable, 0, 1, "Day", text_color = color.white, text_size = fTableTextSize(adrTextSize))
    table.cell(adrTable, 1, 1, dTxt, text_color = color.white, text_size = fTableTextSize(adrTextSize))

    string aTxt = adrShowPoints and not na(asiaRange) ? str.tostring(asiaRange, format.mintick) : ""
    if adrShowPct and not na(asiaRange) and not na(adr) and adr != 0
        aTxt += (str.length(aTxt) > 0 ? " | " : "") + str.tostring(asiaRange / adr * 100.0, "#.##") + "%"
    table.cell(adrTable, 0, 2, "Asia", text_color = color.white, text_size = fTableTextSize(adrTextSize))
    table.cell(adrTable, 1, 2, aTxt, text_color = color.white, text_size = fTableTextSize(adrTextSize))

    string lTxt = adrShowPoints and not na(londonRange) ? str.tostring(londonRange, format.mintick) : ""
    if adrShowPct and not na(londonRange) and not na(adr) and adr != 0
        lTxt += (str.length(lTxt) > 0 ? " | " : "") + str.tostring(londonRange / adr * 100.0, "#.##") + "%"
    table.cell(adrTable, 0, 3, "London", text_color = color.white, text_size = fTableTextSize(adrTextSize))
    table.cell(adrTable, 1, 3, lTxt, text_color = color.white, text_size = fTableTextSize(adrTextSize))

    string nTxt = adrShowPoints and not na(nyRange) ? str.tostring(nyRange, format.mintick) : ""
    if adrShowPct and not na(nyRange) and not na(adr) and adr != 0
        nTxt += (str.length(nTxt) > 0 ? " | " : "") + str.tostring(nyRange / adr * 100.0, "#.##") + "%"
    table.cell(adrTable, 0, 4, "NY", text_color = color.white, text_size = fTableTextSize(adrTextSize))
    table.cell(adrTable, 1, 4, nTxt, text_color = color.white, text_size = fTableTextSize(adrTextSize))

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
var int lastAlertBar = na
var int lastAlertTime = na
bool cooldownOk = (na(lastAlertBar) or bar_index - lastAlertBar >= cooldownBars) and (na(lastAlertTime) or time - lastAlertTime >= cooldownMinutes * 60000)

bool alertTap = false
alertTap := alertTap or (showPDH and fTouch(pdHigh, wickToleranceTicks))
alertTap := alertTap or (showPDL and fTouch(pdLow, wickToleranceTicks))
alertTap := alertTap or (showDailyVWAP and fTouch(dayVW, wickToleranceTicks))
alertTap := alertTap or (showWeeklyVWAP and fTouch(weekVW, wickToleranceTicks))
alertTap := alertTap or (enAsia and asiaH and fTouch(aHigh, wickToleranceTicks))
alertTap := alertTap or (enAsia and asiaL and fTouch(aLow, wickToleranceTicks))

bool liqSweep = false
if array.size(liqLvls) > 0
    for i = 0 to array.size(liqLvls) - 1
        liqSweep := liqSweep or fTouch(array.get(liqLvls, i), wickToleranceTicks)

if cooldownOk and (alertTap or liqSweep)
    lastAlertBar := bar_index
    lastAlertTime := time

alertcondition(cooldownOk and alertTap, "Level Tap", "Price tapped an enabled level.")
alertcondition(cooldownOk and liqSweep, "Liquidity Sweep", "Price swept a stored liquidity level.")
````
