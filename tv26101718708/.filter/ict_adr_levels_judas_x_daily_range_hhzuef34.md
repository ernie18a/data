# ICT ADR Levels - Judas x Daily Range

- url: https://www.tradingview.com/script/hHZuEF34-ICT-ADR-Levels-Judas-x-Daily-Range/
- type: indicator
- pine_id: PUB;e4600207c55246e3b64a8ab84070eeba
- version: 7.0

## Description

This indicator provides a clean and flexible way to monitor Average Daily Range (ADR) with two distinct calculation modes, along with visual levels and a detailed historical table.
Calculation Modes


- Classic Mode: Uses the standard daily candle range (high minus low of regular daily bars). This is the traditional daily range calculation.
- Midnight Mode: Calculates the daily range from midnight to midnight in America/New_York time. This provides a true calendar-day range independent of session opens.

You can switch between the two modes instantly using the dropdown in the settings. All table values, percentages, and 80% ADR levels update dynamically based on the selected mode.

The indicator plots the following levels from a session anchor point:

- Full ADR (above and below)
- 1/3 ADR (Judas levels)
- 80% ADR measured from the current daily high and low (two lines) - user selectable %

All lines are dynamically managed to avoid duplication and update cleanly as new sessions begin. Labels on the right side display price levels and can be toggled on or off.

Historical Table
A customizable table displays the following information for the selected number of days:

- Day or Date (user selectable)
- 5-Day ADR value for each historical day
- 80% of that day's 5-Day ADR
- Actual daily Range
- Percentage of the 5-Day ADR reached that day

The current/live row shows Today's Range compared against the active 5-Day ADR, including the percentage reached and the 80% target level. The table supports multiple sizes and positions.
Key Features

- Toggle between Classic and Midnight ADR calculations
- 80% ADR levels drawn from daily high and low
- Clean, non-duplicating horizontal lines and labels
- Historical data table with day/date, ADR, 80% ADR, Range, and percentage columns
- Adjustable styling, colors, text size, and visibility for all elements
- Option to plot levels from a session anchor or current price

This tool is designed for traders who want precise ADR-based levels with the flexibility to choose between standard daily ranges and strict midnight-to-midnight calculations.

## Source Code

````pine
//@version=6
// ICT ADR Levels - Judas x Daily Range
// Manual anchors: Classic 6pm / Daily, Midnight 00:00, RTH 09:30
// Visuals aligned with native TradingView price-tag + ray styling

indicator("ICT ADR Levels - Judas x Daily Range",
     shorttitle="ICT ADR",
     overlay=true,
     format=format.price,
     precision=2,
     max_lines_count=500,
     max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

group_general = "GENERAL SETTINGS"
autoColor = input.bool(true, "Auto Color?", group=group_general,
     tooltip="When enabled, upside levels use green and downside levels use red.")

group_acr = "RANGE SETTINGS"
acrTF     = input.timeframe("1D", "Timeframe", group=group_acr)
acrLen    = input.int(5, "Number of Days", minval=1, maxval=30, group=group_acr)
showTable = input.bool(true, "Show Previous Candle Ranges Table?", group=group_acr)
tableSize = input.string("small", "Table Size", options=["tiny","small","normal","large"], group=group_acr)
percacr   = input.int(80, "Percentage of Range", minval=1, maxval=100, group=group_acr) / 100
tablePos  = input.string("bottom_left", "Table Position",
     options=["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"],
     group=group_acr)
dateFormat = input.string("Day of Week", "Table Date Column", options=["Date", "Day of Week"], group=group_acr)

group_daily = "DAILY SETTINGS (only used when Timeframe = Daily)"
adrType = input.string("Classic", "Daily ADR Type", options=["Classic", "Midnight", "RTH"], group=group_daily)

group_plot = "PLOT SETTINGS"
showText          = input.bool(true, "Show Text?", group=group_plot)
textSize          = input.string("small", "Text Size", options=["tiny","small","normal","large"], group=group_plot)
labelColor        = input.color(#000000, "Label Color", group=group_plot,
     tooltip="Text color for in-pane labels. Use white on dark charts, black on light charts.")
plotFromAnchor    = input.bool(true, "Plot from Anchor?", group=group_plot)
adrMethod         = input.string("Traditional", "ADR Method", options=["Developing", "Traditional"], group=group_plot,
     tooltip="Developing (default): High/Low and 1/3 track the live session extreme so you can measure remaining nADR in real time.\nTraditional: High/Low and 1/3 are fixed from the session open (Open ± nADR). 80% is always from the live high/low.")
histDays          = input.int(1, "Historical Sessions", minval=0, maxval=30, group=group_plot,
     tooltip="How many completed sessions to leave drawn on the chart. 0 = current session only.")
showPricesInLabels = input.bool(false, "Show Prices in Labels?", group=group_plot)
rightBuffer       = input.int(6, "Right Buffer (bars)", minval=0, maxval=50, group=group_plot,
     tooltip="How many bars past the last candle the line stops. The label sits centered on that endpoint.")

showACR  = input.bool(true, "Show High/Low Lines (Full Range)", group=group_plot)
styleACR = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group=group_plot)
colorACR = input.color(#000000, "Color", group=group_plot)
hideACR  = input.bool(false, "Hide?", group=group_plot)

showJudas  = input.bool(true, "1/3 Level", group=group_plot)
styleJudas = input.string("Dotted", "Style", options=["Solid","Dashed","Dotted"], group=group_plot)
colorJudas = input.color(#000000, "Color", group=group_plot)
hideJudas  = input.bool(false, "Hide?", group=group_plot)

showAnchor  = input.bool(false, "Anchor", group=group_plot)
styleAnchor = input.string("Dotted", "Style", options=["Solid","Dashed","Dotted"], group=group_plot)
colorAnchor = input.color(#000000, "Color", group=group_plot)
hideAnchor  = input.bool(false, "Hide?", group=group_plot)

show80HL = input.bool(true, "80% Level from High/Low", group=group_plot)
style80  = input.string("Dashed", "Style", options=["Solid","Dashed","Dotted"], group=group_plot)
color80  = input.color(#000000, "Color", group=group_plot)
hide80   = input.bool(false, "Hide?", group=group_plot)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

toLineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

toSize(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal

dayNameFromDow(int dow) =>
    dow == dayofweek.monday    ? "Monday"    :
     dow == dayofweek.tuesday   ? "Tuesday"   :
     dow == dayofweek.wednesday ? "Wednesday" :
     dow == dayofweek.thursday  ? "Thursday"  :
     dow == dayofweek.friday    ? "Friday"    :
     dow == dayofweek.saturday  ? "Saturday"  : "Sunday"

fmtDate(int t, string tz) =>
    str.tostring(year(t, tz)) + "-" + str.tostring(month(t, tz), "00") + "-" + str.tostring(dayofmonth(t, tz), "00")

pushHist(array<float> ranges, array<float> adrs, array<string> dates, array<string> names, float rng, string dt, string nm, int cap) =>
    array.unshift(adrs, array.size(ranges) >= acrLen ? array.avg(array.slice(ranges, 0, acrLen)) : na)
    array.unshift(ranges, rng)
    array.unshift(dates, dt)
    array.unshift(names, nm)
    if array.size(ranges) > cap
        array.pop(ranges)
        array.pop(adrs)
        array.pop(dates)
        array.pop(names)

// ═══════════════════════════════════════════════════════════════════════════════
// DETECT MODE
// ═══════════════════════════════════════════════════════════════════════════════

bool isDailyTF = acrTF == "D" or acrTF == "1D" or acrTF == "W" or acrTF == "M"
bool isClassic = adrType == "Classic"
bool isRTH     = adrType == "RTH"

// ═══════════════════════════════════════════════════════════════════════════════
// DAILY LOGIC + ANCHOR PRICES
// ═══════════════════════════════════════════════════════════════════════════════

var float nyAnchorPrice       = na
var float midnightAnchorPrice = na
var float rthAnchorPrice      = na

bool isNewDay = ta.change(time("D")) != 0

var float curDayHighClassic = na
var float curDayLowClassic  = na

if isNewDay
    curDayHighClassic := high
    curDayLowClassic  := low
    nyAnchorPrice     := open
else if not na(curDayHighClassic)
    curDayHighClassic := math.max(curDayHighClassic, high)
    curDayLowClassic  := math.min(curDayLowClassic, low)

float curDayRangeClassic = not na(curDayHighClassic) and not na(curDayLowClassic) ? curDayHighClassic - curDayLowClassic : na

bool inRTH = not na(time("1", "0930-1615", "America/New_York"))

var float curDayHighRTH = na
var float curDayLowRTH  = na

if isNewDay
    curDayHighRTH := na
    curDayLowRTH  := na

if inRTH
    curDayHighRTH := na(curDayHighRTH) ? high : math.max(curDayHighRTH, high)
    curDayLowRTH  := na(curDayLowRTH)  ? low  : math.min(curDayLowRTH, low)

float curDayRangeRTH = not na(curDayHighRTH) and not na(curDayLowRTH) ? curDayHighRTH - curDayLowRTH : na

int nyHour     = hour(time, "America/New_York")
int nyMinute   = minute(time, "America/New_York")
bool isMidnight = nyHour == 0 and nyMinute == 0
bool isRTHStart = nyHour == 9 and nyMinute == 30

var float curDayHighMid = na
var float curDayLowMid  = na

if isMidnight
    curDayHighMid         := high
    curDayLowMid          := low
    midnightAnchorPrice   := open
else if not na(curDayHighMid)
    curDayHighMid := math.max(curDayHighMid, high)
    curDayLowMid  := math.min(curDayLowMid, low)

float curDayRangeMid = not na(curDayHighMid) and not na(curDayLowMid) ? curDayHighMid - curDayLowMid : na

var array<float>  histRanges   = array.new_float()
var array<string> histDates    = array.new_string()
var array<float>  histADRs     = array.new_float()
var array<string> histDayNames = array.new_string()

var array<float>  histRangesMid   = array.new_float()
var array<string> histDatesMid    = array.new_string()
var array<float>  histADRsMid     = array.new_float()
var array<string> histDayNamesMid = array.new_string()

var array<float>  histRangesRTH   = array.new_float()
var array<string> histDatesRTH    = array.new_string()
var array<float>  histADRsRTH     = array.new_float()
var array<string> histDayNamesRTH = array.new_string()

if isNewDay and bar_index > 5
    if not na(curDayHighClassic[1]) and curDayHighClassic[1] > curDayLowClassic[1]
        pushHist(histRanges, histADRs, histDates, histDayNames,
             curDayHighClassic[1] - curDayLowClassic[1],
             fmtDate(time[1], syminfo.timezone),
             dayNameFromDow(dayofweek(time[1])),
             40)
    if not na(curDayHighRTH[1]) and curDayHighRTH[1] > curDayLowRTH[1]
        pushHist(histRangesRTH, histADRsRTH, histDatesRTH, histDayNamesRTH,
             curDayHighRTH[1] - curDayLowRTH[1],
             fmtDate(time[1], syminfo.timezone),
             dayNameFromDow(dayofweek(time[1])),
             40)

if isMidnight and bar_index > 5
    if not na(curDayHighMid[1]) and curDayHighMid[1] > curDayLowMid[1]
        pushHist(histRangesMid, histADRsMid, histDatesMid, histDayNamesMid,
             curDayHighMid[1] - curDayLowMid[1],
             fmtDate(time[1], "America/New_York"),
             dayNameFromDow(dayofweek(time[1], "America/New_York")),
             40)

if isRTHStart
    rthAnchorPrice := open

float adrClassic = array.size(histRanges)    >= acrLen ? array.avg(array.slice(histRanges,    0, acrLen)) : na
float adrMid     = array.size(histRangesMid) >= acrLen ? array.avg(array.slice(histRangesMid, 0, acrLen)) : na
float adrRTH     = array.size(histRangesRTH) >= acrLen ? array.avg(array.slice(histRangesRTH, 0, acrLen)) : na

float adrDaily          = isClassic ? adrClassic : isRTH ? adrRTH : adrMid
float curDayRangeDaily  = isClassic ? curDayRangeClassic : isRTH ? curDayRangeRTH : curDayRangeMid

// ═══════════════════════════════════════════════════════════════════════════════
// INTRADAY LOGIC
// ═══════════════════════════════════════════════════════════════════════════════

bool isNewCandle = ta.change(time(acrTF)) != 0

float secHigh = request.security(syminfo.tickerid, acrTF, high)
float secLow  = request.security(syminfo.tickerid, acrTF, low)
float secOpen = request.security(syminfo.tickerid, acrTF, open)

var float curCandleHigh = na
var float curCandleLow  = na

if isNewCandle
    curCandleHigh := secHigh
    curCandleLow  := secLow
else
    curCandleHigh := math.max(curCandleHigh, secHigh)
    curCandleLow  := math.min(curCandleLow, secLow)

float curCandleRange = curCandleHigh - curCandleLow

var array<float>  histACRRanges     = array.new_float()
var array<int>    histACRCloseTimes = array.new_int()
var array<string> histACRDayNames   = array.new_string()
var array<float>  histACRValues     = array.new_float()

if isNewCandle and bar_index > 10 and not isDailyTF
    float completedHigh  = request.security(syminfo.tickerid, acrTF, high[1])
    float completedLow   = request.security(syminfo.tickerid, acrTF, low[1])
    float completedRange = completedHigh - completedLow
    array.unshift(histACRRanges, completedRange)

    float completedCloseTime = request.security(syminfo.tickerid, acrTF, time_close[1])
    array.unshift(histACRCloseTimes, int(completedCloseTime))
    array.unshift(histACRDayNames, dayNameFromDow(dayofweek(time[1])))

    float currentACR = array.size(histACRRanges) >= acrLen ? array.avg(array.slice(histACRRanges, 0, acrLen)) : na
    array.unshift(histACRValues, currentACR)

    if array.size(histACRRanges) > 200
        array.pop(histACRRanges)
        array.pop(histACRCloseTimes)
        array.pop(histACRDayNames)
        array.pop(histACRValues)

float acrIntraday = array.size(histACRRanges) >= acrLen ? array.avg(array.slice(histACRRanges, 0, acrLen)) : na

// ═══════════════════════════════════════════════════════════════════════════════
// COMMON VALUES
// ═══════════════════════════════════════════════════════════════════════════════

float adr      = isDailyTF ? adrDaily : acrIntraday
float curRange = isDailyTF ? curDayRangeDaily : curCandleRange

float anchor = isDailyTF ?
     (isClassic ? nyAnchorPrice : isRTH ? rthAnchorPrice : midnightAnchorPrice) : secOpen

float sessHigh = isDailyTF ? (isClassic ? curDayHighClassic : isRTH ? curDayHighRTH : curDayHighMid) : secHigh
float sessLow  = isDailyTF ? (isClassic ? curDayLowClassic  : isRTH ? curDayLowRTH  : curDayLowMid)  : secLow

bool isTraditional = adrMethod == "Traditional"

float lvlMid = anchor

// Traditional: Open ± nADR (industry-standard projection from the session anchor).
// Developing:  opposite extreme ± nADR (remaining range in real time).
// 80% always uses the live high/low — it measures how much of nADR is already used.
float lvlUp         = isTraditional ? anchor + adr : (not na(sessLow)  ? sessLow  + adr : na)
float lvlDown       = isTraditional ? anchor - adr : (not na(sessHigh) ? sessHigh - adr : na)
float lvlJudasUp    = isTraditional ? anchor + adr / 3 : (not na(sessLow)  ? sessLow  + adr / 3 : na)
float lvlJudasDown  = isTraditional ? anchor - adr / 3 : (not na(sessHigh) ? sessHigh - adr / 3 : na)
float lvl80FromHigh = not na(sessHigh) ? sessHigh - adr * percacr : na
float lvl80FromLow  = not na(sessLow)  ? sessLow  + adr * percacr : na

bool valid = not na(adr) and adr > 0

bool newSession = isDailyTF ? (isClassic ? isNewDay : isRTH ? isRTHStart : isMidnight) : isNewCandle

var int sessionStart = na
int prevSessionStart = sessionStart
if newSession
    sessionStart := bar_index

bool drawFromSession = not na(sessionStart) and bar_index >= sessionStart
int  lineX1          = plotFromAnchor and not na(sessionStart) ? sessionStart : bar_index

// Colors — Auto Color paints upside green / downside red like long/short scale tags
color colUp     = autoColor ? #26a69a : colorACR
color colDown   = autoColor ? #ef5350 : colorACR
color colJudasU = autoColor ? #26a69a : colorJudas
color colJudasD = autoColor ? #ef5350 : colorJudas
color colMid    = autoColor ? #787b86 : colorAnchor
color col80H    = autoColor ? #ef5350 : color80
color col80L    = autoColor ? #26a69a : color80

lineStyle       = toLineStyle(styleACR)
lineStyleJudas  = toLineStyle(styleJudas)
lineStyleAnchor = toLineStyle(styleAnchor)
lineStyle80     = toLineStyle(style80)
string sz       = textSize

string unitTag  = isDailyTF ? "ADR" : "ACR"
string txt80    = str.tostring(percacr * 100, "#") + "% " + str.tostring(acrLen) + unitTag

makeLabelText(string name, float px) =>
    showPricesInLabels ? name + "  " + str.tostring(px, format.mintick) : name

// ═══════════════════════════════════════════════════════════════════════════════
// LINES  (from anchor to last bar + buffer — no extend, so labels sit on the end)
// ═══════════════════════════════════════════════════════════════════════════════

var line lUp        = na
var line lDown      = na
var line lJudasUp   = na
var line lJudasDown = na
var line lAnchor    = na
var line l80H       = na
var line l80L       = na

var array<line>  histLines     = array.new_line()
var array<label> histLbls      = array.new_label()
var array<int>   histLineCount = array.new_int()
var array<int>   histLblCount  = array.new_int()

int lineX2 = bar_index + rightBuffer

trimHist() =>
    while array.size(histLineCount) > histDays
        int n = array.shift(histLineCount)
        for i = 0 to n - 1
            if array.size(histLines) > 0
                line.delete(array.shift(histLines))
        int m = array.size(histLblCount) > 0 ? array.shift(histLblCount) : 0
        for j = 0 to m - 1
            if array.size(histLbls) > 0
                label.delete(array.shift(histLbls))
    while array.size(histLblCount) > histDays
        int m2 = array.shift(histLblCount)
        for j2 = 0 to m2 - 1
            if array.size(histLbls) > 0
                label.delete(array.shift(histLbls))

freezeLine(bool show, float y, color c, string st, int x1, int x2) =>
    if show and not na(y) and x2 > x1
        array.push(histLines, line.new(x1, y, x2, y, color=color.new(c, 40), width=1, style=st, extend=extend.none))

freezeLbl(bool show, float y, string txt, int x) =>
    if show and showText and not na(y)
        array.push(histLbls, label.new(x, y, " " + txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color(na),
             textcolor=color.new(labelColor, 35),
             size=sz,
             textalign=text.align_left,
             text_font_family=font.family_monospace))

// Freeze the session that just closed (use [1] so we get that session's final levels)
if newSession and histDays > 0 and not na(prevSessionStart) and valid[1]
    int hx1 = prevSessionStart
    int hx2 = bar_index
    int linesBefore = array.size(histLines)
    int lblsBefore  = array.size(histLbls)
    freezeLine(showACR    and not hideACR,    lvlUp[1],        colUp,     lineStyle,       hx1, hx2)
    freezeLine(showACR    and not hideACR,    lvlDown[1],      colDown,   lineStyle,       hx1, hx2)
    freezeLine(showJudas  and not hideJudas,  lvlJudasUp[1],   colJudasU, lineStyleJudas,  hx1, hx2)
    freezeLine(showJudas  and not hideJudas,  lvlJudasDown[1], colJudasD, lineStyleJudas,  hx1, hx2)
    freezeLine(showAnchor and not hideAnchor, lvlMid[1],       colMid,    lineStyleAnchor, hx1, hx2)
    freezeLine(show80HL   and not hide80,     lvl80FromHigh[1], col80H,   lineStyle80,     hx1, hx2)
    freezeLine(show80HL   and not hide80,     lvl80FromLow[1],  col80L,   lineStyle80,     hx1, hx2)
    if showText
        string hUnit = isDailyTF ? "ADR" : "ACR"
        string h80   = str.tostring(percacr * 100, "#") + "% " + str.tostring(acrLen) + hUnit
        string hJ    = "1/3 " + str.tostring(acrLen) + hUnit
        freezeLbl(showACR    and not hideACR,    lvlUp[1],         makeLabelText(hUnit + " High", lvlUp[1]),         hx2)
        freezeLbl(showACR    and not hideACR,    lvlDown[1],       makeLabelText(hUnit + " Low",  lvlDown[1]),       hx2)
        freezeLbl(showJudas  and not hideJudas,  lvlJudasUp[1],    makeLabelText(hJ,              lvlJudasUp[1]),    hx2)
        freezeLbl(showJudas  and not hideJudas,  lvlJudasDown[1],  makeLabelText(hJ,              lvlJudasDown[1]),  hx2)
        freezeLbl(showAnchor and not hideAnchor, lvlMid[1],        makeLabelText("Anchor",        lvlMid[1]),        hx2)
        freezeLbl(show80HL   and not hide80,     lvl80FromHigh[1], makeLabelText(h80,             lvl80FromHigh[1]), hx2)
        freezeLbl(show80HL   and not hide80,     lvl80FromLow[1],  makeLabelText(h80,             lvl80FromLow[1]),  hx2)
    array.push(histLineCount, array.size(histLines) - linesBefore)
    array.push(histLblCount,  array.size(histLbls)  - lblsBefore)
    trimHist()

trimHist()

upsertLine(line id, bool show, float y, color c, string st) =>
    line out = id
    if not show or not valid or not drawFromSession or na(y)
        if not na(out)
            line.delete(out)
        na
    else
        if na(out)
            out := line.new(lineX1, y, lineX2, y, color=c, width=1, style=st, extend=extend.none)
        else
            line.set_xy1(out, lineX1, y)
            line.set_xy2(out, lineX2, y)
            line.set_color(out, c)
            line.set_style(out, st)
            line.set_extend(out, extend.none)
        out

if newSession
    line.delete(lUp)
    line.delete(lDown)
    line.delete(lJudasUp)
    line.delete(lJudasDown)
    line.delete(lAnchor)
    line.delete(l80H)
    line.delete(l80L)
    lUp        := na
    lDown      := na
    lJudasUp   := na
    lJudasDown := na
    lAnchor    := na
    l80H       := na
    l80L       := na

lUp        := upsertLine(lUp,        showACR    and not hideACR,    lvlUp,        colUp,     lineStyle)
lDown      := upsertLine(lDown,      showACR    and not hideACR,    lvlDown,      colDown,   lineStyle)
lJudasUp   := upsertLine(lJudasUp,   showJudas  and not hideJudas,  lvlJudasUp,   colJudasU, lineStyleJudas)
lJudasDown := upsertLine(lJudasDown, showJudas  and not hideJudas,  lvlJudasDown, colJudasD, lineStyleJudas)
lAnchor    := upsertLine(lAnchor,    showAnchor and not hideAnchor, lvlMid,       colMid,    lineStyleAnchor)
l80H       := upsertLine(l80H,       show80HL   and not hide80,     lvl80FromHigh, col80H,   lineStyle80)
l80L       := upsertLine(l80L,       show80HL   and not hide80,     lvl80FromLow,  col80L,   lineStyle80)

// ═══════════════════════════════════════════════════════════════════════════════
// RIGHT LABELS  — compact price-scale pills (colored fill, tabular font)
// ═══════════════════════════════════════════════════════════════════════════════

var label lblUp        = na
var label lblDown      = na
var label lblAnchor    = na
var label lblJudasUp   = na
var label lblJudasDown = na
var label lbl80H       = na
var label lbl80L       = na

upsertLbl(label id, bool show, float y, string txt) =>
    label out = id
    if not show or not valid or na(y) or not showText
        if not na(out)
            label.delete(out)
        na
    else
        int lx = lineX2
        // label_left + color(na): text starts at the line endpoint and is
        // vertically centered on the line — no box, no arrow.
        if na(out)
            out := label.new(lx, y, " " + txt,
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=color(na),
                 textcolor=labelColor,
                 size=sz,
                 textalign=text.align_left,
                 text_font_family=font.family_monospace)
        else
            label.set_xy(out, lx, y)
            label.set_text(out, " " + txt)
            label.set_style(out, label.style_label_left)
            label.set_yloc(out, yloc.price)
            label.set_color(out, color(na))
            label.set_textcolor(out, labelColor)
            label.set_textalign(out, text.align_left)
            label.set_size(out, sz)
        out

if barstate.islast
    string upName     = unitTag + " High"
    string downName   = unitTag + " Low"
    string judasName  = "1/3 " + str.tostring(acrLen) + unitTag
    string midName    = "Anchor"

    lblUp        := upsertLbl(lblUp,        showACR    and not hideACR,    lvlUp,        makeLabelText(upName, lvlUp))
    lblDown      := upsertLbl(lblDown,      showACR    and not hideACR,    lvlDown,      makeLabelText(downName, lvlDown))
    lblJudasUp   := upsertLbl(lblJudasUp,   showJudas  and not hideJudas,  lvlJudasUp,   makeLabelText(judasName, lvlJudasUp))
    lblJudasDown := upsertLbl(lblJudasDown, showJudas  and not hideJudas,  lvlJudasDown, makeLabelText(judasName, lvlJudasDown))
    lblAnchor    := upsertLbl(lblAnchor,    showAnchor and not hideAnchor, lvlMid,       makeLabelText(midName, lvlMid))
    lbl80H       := upsertLbl(lbl80H,       show80HL   and not hide80,     lvl80FromHigh, makeLabelText(txt80, lvl80FromHigh))
    lbl80L       := upsertLbl(lbl80L,       show80HL   and not hide80,     lvl80FromLow,  makeLabelText(txt80, lvl80FromLow))

// Native price-scale badges (the green/red pills on the axis in the screenshot)
plot(showACR and not hideACR and valid ? lvlUp   : na, "ADR/ACR High", color=colUp,   linewidth=1, display=display.price_scale)
plot(showACR and not hideACR and valid ? lvlDown : na, "ADR/ACR Low",  color=colDown, linewidth=1, display=display.price_scale)
plot(showJudas and not hideJudas and valid ? lvlJudasUp   : na, "1/3 High", color=colJudasU, display=display.price_scale)
plot(showJudas and not hideJudas and valid ? lvlJudasDown : na, "1/3 Low",  color=colJudasD, display=display.price_scale)
plot(show80HL and not hide80 and valid ? lvl80FromHigh : na, "80% from High", color=col80H, display=display.price_scale)
plot(show80HL and not hide80 and valid ? lvl80FromLow  : na, "80% from Low",  color=col80L, display=display.price_scale)
plot(showAnchor and not hideAnchor and valid ? lvlMid : na, "Anchor", color=colMid, display=display.price_scale)

// ═══════════════════════════════════════════════════════════════════════════════
// TABLE
// ═══════════════════════════════════════════════════════════════════════════════

color tblHeaderBg = color.new(#26a69a, 55)
color tblRowA     = color.new(#131722, 35)
color tblRowB     = color.new(#2a2e39, 45)
color tblFootBg   = color.new(#1e222d, 20)
color tblBorder   = color.new(#434651, 0)

if showTable and barstate.islast
    if isDailyTF
        bool useClassicTable = isClassic
        bool useRTHTable     = isRTH
        int n = math.min(acrLen, useRTHTable ? array.size(histRangesRTH) : useClassicTable ? array.size(histRanges) : array.size(histRangesMid))
        int rows = n + 2

        var table t = table.new(tablePos, 5, rows, bgcolor=color.new(#131722, 20), border_width=1, frame_width=1, border_color=tblBorder, frame_color=tblBorder)

        table.cell(t, 0, 0, "Day",                         text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg, text_font_family=font.family_default)
        table.cell(t, 1, 0, str.tostring(acrLen) + "-Day ADR", text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 2, 0, str.tostring(percacr * 100, "#") + "% ADR", text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 3, 0, "Range",                       text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 4, 0, "% of ADR",                    text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)

        for i = 0 to n - 1
            int r = i + 1
            float rng     = useRTHTable ? array.get(histRangesRTH, i) : useClassicTable ? array.get(histRanges, i) : array.get(histRangesMid, i)
            float dayADR  = useRTHTable ? array.get(histADRsRTH, i)   : useClassicTable ? array.get(histADRs, i)   : array.get(histADRsMid, i)
            string dt     = useRTHTable ? array.get(histDatesRTH, i)  : useClassicTable ? array.get(histDates, i)  : array.get(histDatesMid, i)
            string dName  = useRTHTable ? array.get(histDayNamesRTH, i) : useClassicTable ? array.get(histDayNames, i) : array.get(histDayNamesMid, i)
            string displayDay = dateFormat == "Date" ? dt : dName
            string displayADR = na(dayADR) ? "—" : str.tostring(dayADR, format.mintick)
            string display80  = na(dayADR) ? "—" : str.tostring(dayADR * percacr, format.mintick)
            float pct = (not na(dayADR) and dayADR > 0) ? rng / dayADR * 100 : 0
            string displayPct = na(dayADR) ? "—" : str.tostring(pct, "#.##") + "%"
            color bg = i % 2 == 0 ? tblRowA : tblRowB
            color pctCol = pct > 100 ? #ef5350 : color.white

            table.cell(t, 0, r, displayDay,                        text_color=color.white, text_size=tableSize, bgcolor=bg)
            table.cell(t, 1, r, displayADR,                        text_color=color.white, text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)
            table.cell(t, 2, r, display80,                         text_color=color.white, text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)
            table.cell(t, 3, r, str.tostring(rng, format.mintick), text_color=color.white, text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)
            table.cell(t, 4, r, displayPct,                        text_color=pctCol,      text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)

        int sep = n + 1
        table.cell(t, 0, sep, "Current " + str.tostring(acrLen) + "-Day ADR (" + adrType + ")", text_color=color.white, text_size=tableSize, bgcolor=tblFootBg)
        table.cell(t, 1, sep, str.tostring(adrDaily, format.mintick), text_color=#26a69a, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)

        if not na(curDayRangeDaily) and valid
            float tp = adrDaily > 0 ? curDayRangeDaily / adrDaily * 100 : 0
            color pctColor = tp > 100 ? #ef5350 : #26a69a
            table.cell(t, 2, sep, str.tostring(adrDaily * percacr, format.mintick), text_color=#26a69a, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)
            table.cell(t, 3, sep, str.tostring(curDayRangeDaily, format.mintick),   text_color=color.white, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)
            table.cell(t, 4, sep, str.tostring(tp, "#.##") + "%",                   text_color=pctColor, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)
        else
            table.cell(t, 2, sep, "", bgcolor=tblFootBg)
            table.cell(t, 3, sep, "", bgcolor=tblFootBg)
            table.cell(t, 4, sep, "", bgcolor=tblFootBg)
    else
        float currentCloseTime    = request.security(syminfo.tickerid, acrTF, time_close)
        int   currentCloseTimeInt = int(currentCloseTime)

        array<string> matchingDays   = array.new_string()
        array<float>  matchingRanges = array.new_float()
        array<float>  matchingACRs   = array.new_float()

        int millisPerDay     = 86400000
        int currentTimeOfDay = currentCloseTimeInt % millisPerDay

        for i = 0 to array.size(histACRDayNames) - 1
            if array.size(matchingDays) >= acrLen
                break
            int histClose     = array.get(histACRCloseTimes, i)
            int histTimeOfDay = histClose % millisPerDay
            if histTimeOfDay == currentTimeOfDay
                string d = array.get(histACRDayNames, i)
                bool alreadyExists = false
                for j = 0 to array.size(matchingDays) - 1
                    if array.get(matchingDays, j) == d
                        alreadyExists := true
                        break
                if not alreadyExists
                    array.push(matchingDays, d)
                    array.push(matchingRanges, array.get(histACRRanges, i))
                    array.push(matchingACRs, array.get(histACRValues, i))

        int n    = array.size(matchingDays)
        int rows = n + 2

        var table t = table.new(tablePos, 5, rows, bgcolor=color.new(#131722, 20), border_width=1, frame_width=1, border_color=tblBorder, frame_color=tblBorder)

        table.cell(t, 0, 0, "Day",                                          text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 1, 0, str.tostring(acrLen) + " ACR",                  text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 2, 0, str.tostring(percacr * 100, "#") + "% ACR",      text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 3, 0, "Range",                                        text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)
        table.cell(t, 4, 0, "% of ACR",                                     text_color=color.white, text_size=tableSize, bgcolor=tblHeaderBg)

        if n > 0 and array.size(matchingRanges) > 0
            for k = 0 to n - 1
                int r = k + 1
                float rng     = array.get(matchingRanges, k)
                float thisACR = array.get(matchingACRs, k)
                string dName  = array.get(matchingDays, k)
                string displayACR = na(thisACR) ? "—" : str.tostring(thisACR, format.mintick)
                string display80  = na(thisACR) ? "—" : str.tostring(thisACR * percacr, format.mintick)
                float pct = (not na(thisACR) and thisACR > 0) ? rng / thisACR * 100 : 0
                string displayPct = na(thisACR) ? "—" : str.tostring(pct, "#.##") + "%"
                color bg = k % 2 == 0 ? tblRowA : tblRowB
                color pctCol = pct > 100 ? #ef5350 : color.white

                table.cell(t, 0, r, dName,                                text_color=color.white, text_size=tableSize, bgcolor=bg)
                table.cell(t, 1, r, displayACR,                           text_color=color.white, text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)
                table.cell(t, 2, r, display80,                            text_color=color.white, text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)
                table.cell(t, 3, r, str.tostring(rng, format.mintick),    text_color=color.white, text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)
                table.cell(t, 4, r, displayPct,                           text_color=pctCol,      text_size=tableSize, bgcolor=bg, text_font_family=font.family_monospace)

        int sep = n + 1
        table.cell(t, 0, sep, "Current " + str.tostring(acrLen) + " ACR (" + acrTF + ")", text_color=color.white, text_size=tableSize, bgcolor=tblFootBg)
        table.cell(t, 1, sep, str.tostring(acrIntraday, format.mintick), text_color=#26a69a, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)

        if not na(curCandleRange) and valid
            float tp = acrIntraday > 0 ? curCandleRange / acrIntraday * 100 : 0
            color pctColor = tp > 100 ? #ef5350 : #26a69a
            table.cell(t, 2, sep, str.tostring(acrIntraday * percacr, format.mintick), text_color=#26a69a, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)
            table.cell(t, 3, sep, str.tostring(curCandleRange, format.mintick),        text_color=color.white, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)
            table.cell(t, 4, sep, str.tostring(tp, "#.##") + "%",                      text_color=pctColor, text_size=tableSize, bgcolor=tblFootBg, text_font_family=font.family_monospace)
        else
            table.cell(t, 2, sep, "", bgcolor=tblFootBg)
            table.cell(t, 3, sep, "", bgcolor=tblFootBg)
            table.cell(t, 4, sep, "", bgcolor=tblFootBg)
````
