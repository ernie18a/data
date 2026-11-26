# Daily ATR X500

- url: https://www.tradingview.com/script/lzh7iOXf-daily-atr-x500/
- type: indicator
- pine_id: PUB;70cbaf064a3b41dbb49001143d5a3ac8
- version: 1.0

## Description

Daily ATR shows expected daily movement from the symbol’s session day open, using Average True Range on the daily timeframe. When the day’s actual High–Low has already reached that ATR, the forecast is replaced by pullback levels at 30%, 50% and 100% of the real day range.

HOW IT WORKS
• ATR is calculated on the Daily chart (default length 14).
• Today’s forecast uses yesterday’s closed ATR (does not use an unfinished daily bar).

PHASE 1 — Forecast (today’s High−Low still below ATR)
• ATR+ = Open + ATR × K
• ATR− = Open − ATR × K
• Default K = 1 → full ATR possible up and full ATR possible down from the open.
• Optional green/red fills and labels on the active day.

PHASE 2 — Pullbacks (today’s High−Low ≥ ATR)
• Forecast Open±ATR is hidden.
• Three levels of the actual day range (High−Low):
  – 30% (light green)
  – 50% (light yellow)
  – 100% (light red)
• Direction:
  – Price closer to the day High → pullback levels down from High
  – Price closer to the day Low → pullback levels up from Low
• When the session day closes, pullbacks are removed and the day is drawn as actual Open / High / Low. A new day starts with a fresh forecast.

CLOSED DAYS (history)
• Actual Open, High and Low for the selected number of history days.
• Vertical line at each session day open.

INFO TABLE
• Point step used for “pts”
• Today range (+ % of ATR)
• From open / from day’s low / from day’s high
• Yesterday H−L
• Daily ATR (calc)
• Pullbacks status (ACTIVE from High/Low, or off)
• While forecasting: Possible up / Possible down
• While pullbacks active: PB 30% / PB 50% / PB 100% prices

POINT STEP (important)
There is no universal “point” across all markets.
points = price distance ÷ Point step

Suggested starting values (adjust per instrument):
• EURUSD, GBPUSD and most FX majors → 0.0001
• USDJPY and other JPY pairs → 0.01
• XAUUSD (gold) → 0.1
• Or use mintick / manual

If table numbers look huge, the step is too small.
If they look tiny, the step is too large.
The chosen step is shown in the first table row.

SUGGESTED DEFAULTS
• Length: 14
• Multiplier (K): 1.0
• History days: 15
• Enable pullback levels: On
• Point step: set for your symbol (see above)
• Show table: On

Best on intraday charts (e.g. M15–H1) so you can watch the live day band and the switch to pullbacks.

This is a volatility / range reference tool. It does not generate buy or sell signals. Past ATR does not guarantee future range.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Daily ATR — clean daily ATR forecast from session open.
// Live day (range < ATR): Open ± ATR×K (possible move up / down).
// Live day (range ≥ ATR): hide forecast; draw pullback 30% / 50% / 100% of actual High−Low.
// Closed days: actual Open / High / Low. Table: ranges + ATR in user point steps.

//@version=6
indicator(
     title            = "Daily ATR",
     shorttitle       = "Daily ATR",
     overlay          = true,
     max_bars_back    = 500,
     max_lines_count  = 500,
     max_boxes_count  = 500,
     max_labels_count = 500
 )

// ─── Defaults ───────────────────────────────────────────────────────────────
color DEF_VERT  = color.new(#787B86, 0)
color DEF_OPEN  = color.new(#787B86, 0)
color DEF_UPPER = color.new(#787B86, 0)
color DEF_LOWER = color.new(#787B86, 0)
color DEF_UP_FILL = color.new(#26A69A, 85)
color DEF_DN_FILL = color.new(#EF5350, 85)
color DEF_PB30 = color.new(#A5D6A7, 0)   // light green
color DEF_PB50 = color.new(#FFF59D, 0)   // light yellow
color DEF_PB100 = color.new(#EF9A9A, 0)  // light red
int   MS_IN_DAY = 24 * 60 * 60 * 1000

// ─── Inputs ─────────────────────────────────────────────────────────────────
string GRP_ATR = "ATR"
int   atrLen     = input.int(14, "Length", minval = 1, group = GRP_ATR, tooltip = "ATR length on the daily TF. Today's forecast uses yesterday's closed ATR.")
float atrMult    = input.float(1.0, "Multiplier (K)", minval = 0.1, step = 0.1, group = GRP_ATR, tooltip = "Live day while range < ATR: Upper = Open + ATR×K, Lower = Open − ATR×K.")
int   historyDays = input.int(15, "History days", minval = 1, maxval = 100, group = GRP_ATR, tooltip = "Closed days = actual High/Low. Live day = forecast or pullbacks.")

string GRP_PB = "Pullbacks (when today range ≥ ATR)"
bool  showPullbacks = input.bool(true, "Enable pullback levels", group = GRP_PB, tooltip = "When today's High−Low ≥ calculated ATR: hide Open±ATR forecast and show 30/50/100% of the actual day range from the active extreme.")
color pb30Color  = input.color(DEF_PB30, "30% color", group = GRP_PB, inline = "pb")
color pb50Color  = input.color(DEF_PB50, "50%", group = GRP_PB, inline = "pb")
color pb100Color = input.color(DEF_PB100, "100%", group = GRP_PB, inline = "pb")

string GRP_VERT = "Vertical (day open)"
bool   showVert  = input.bool(true, "Show", group = GRP_VERT)
color  vertColor = input.color(DEF_VERT, "Color", group = GRP_VERT, inline = "v")
string vertStyle = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_VERT, inline = "v")
int    vertWidth = input.int(1, "Width", minval = 1, maxval = 4, group = GRP_VERT, inline = "v")

string GRP_LVL = "Levels"
bool   showOpen  = input.bool(true, "Show Open", group = GRP_LVL)
bool   showUpper = input.bool(true, "Show Upper / High", group = GRP_LVL)
bool   showLower = input.bool(true, "Show Lower / Low", group = GRP_LVL)
color  openColor  = input.color(DEF_OPEN, "Open", group = GRP_LVL, inline = "o")
string openStyle  = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GRP_LVL, inline = "o")
int    openWidth  = input.int(1, "", minval = 1, maxval = 4, group = GRP_LVL, inline = "o")
color  upperColor = input.color(DEF_UPPER, "Upper", group = GRP_LVL, inline = "u")
string upperStyle = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GRP_LVL, inline = "u")
int    upperWidth = input.int(1, "", minval = 1, maxval = 4, group = GRP_LVL, inline = "u")
color  lowerColor = input.color(DEF_LOWER, "Lower", group = GRP_LVL, inline = "l")
string lowerStyle = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], group = GRP_LVL, inline = "l")
int    lowerWidth = input.int(1, "", minval = 1, maxval = 4, group = GRP_LVL, inline = "l")

string GRP_FILL = "Fills (forecast only)"
bool  showUpFill = input.bool(true, "Upper fill", group = GRP_FILL)
bool  showDnFill = input.bool(true, "Lower fill", group = GRP_FILL)
color upFill     = input.color(DEF_UP_FILL, "Upper", group = GRP_FILL)
color dnFill     = input.color(DEF_DN_FILL, "Lower", group = GRP_FILL)

string GRP_LAB = "Labels"
bool showLabels = input.bool(true, "Show labels on live day", group = GRP_LAB)

string GRP_TBL = "Table"
string pointStepOpt = input.string("0.0001", "Point step", options = ["1", "0.1", "0.01", "0.001", "0.0001", "0.00001", "mintick", "manual"], group = GRP_TBL, tooltip = "Price ÷ step = points. FX majors ≈ 0.0001, gold ≈ 0.1, JPY ≈ 0.01.")
float  pointStepManual = input.float(0.0001, "Manual step", minval = 0.0, step = 0.0001, group = GRP_TBL, tooltip = "Used only when Point step = manual")
bool   showTable    = input.bool(true, "Show table", group = GRP_TBL)
string tablePos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_TBL)

float pointStep = switch pointStepOpt
    "1" => 1.0
    "0.1" => 0.1
    "0.01" => 0.01
    "0.001" => 0.001
    "0.0001" => 0.0001
    "0.00001" => 0.00001
    "mintick" => syminfo.mintick
    "manual" => pointStepManual
    => 0.0001

// ─── Helpers ────────────────────────────────────────────────────────────────
lineStyleOf(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

tablePosOf(string s) =>
    switch s
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

var array<line>  atrLines  = array.new_line()
var array<box>   atrBoxes  = array.new_box()
var array<label> atrLabels = array.new_label()

pushLine(line id) =>
    if not na(id)
        array.push(atrLines, id)

pushBox(box id) =>
    if not na(id)
        array.push(atrBoxes, id)

pushLabel(label id) =>
    if not na(id)
        array.push(atrLabels, id)

clearDrawings() =>
    while array.size(atrLines) > 0
        line.delete(array.shift(atrLines))
    while array.size(atrBoxes) > 0
        box.delete(array.shift(atrBoxes))
    while array.size(atrLabels) > 0
        label.delete(array.shift(atrLabels))

createForecast(int tStart, int tEnd, float o, float atrVal) =>
    float up = o + atrVal * atrMult
    float dn = o - atrVal * atrMult
    line v  = showVert ? line.new(tStart, up, tStart, dn, xloc = xloc.bar_time, color = vertColor, style = lineStyleOf(vertStyle), width = vertWidth) : na
    line oL = showOpen ? line.new(tStart, o, tEnd, o, xloc = xloc.bar_time, color = openColor, style = lineStyleOf(openStyle), width = openWidth) : na
    line uL = showUpper ? line.new(tStart, up, tEnd, up, xloc = xloc.bar_time, color = upperColor, style = lineStyleOf(upperStyle), width = upperWidth) : na
    line dL = showLower ? line.new(tStart, dn, tEnd, dn, xloc = xloc.bar_time, color = lowerColor, style = lineStyleOf(lowerStyle), width = lowerWidth) : na
    pushLine(v)
    pushLine(oL)
    pushLine(uL)
    pushLine(dL)
    [v, oL, uL, dL]

createActual(int tStart, int tEnd, float o, float dayHi, float dayLo) =>
    line v  = showVert ? line.new(tStart, dayHi, tStart, dayLo, xloc = xloc.bar_time, color = vertColor, style = lineStyleOf(vertStyle), width = vertWidth) : na
    line oL = showOpen ? line.new(tStart, o, tEnd, o, xloc = xloc.bar_time, color = openColor, style = lineStyleOf(openStyle), width = openWidth) : na
    line uL = showUpper ? line.new(tStart, dayHi, tEnd, dayHi, xloc = xloc.bar_time, color = upperColor, style = lineStyleOf(upperStyle), width = upperWidth) : na
    line dL = showLower ? line.new(tStart, dayLo, tEnd, dayLo, xloc = xloc.bar_time, color = lowerColor, style = lineStyleOf(lowerStyle), width = lowerWidth) : na
    pushLine(v)
    pushLine(oL)
    pushLine(uL)
    pushLine(dL)

fLabel(int tEnd, float y, string txt, color css) =>
    showLabels ? label.new(tEnd, y, txt, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.gray, 100), textcolor = css, size = size.small) : na

createExtras(int tStart, int tEnd, float o, float atrVal) =>
    float up = o + atrVal * atrMult
    float dn = o - atrVal * atrMult
    box bUp = showUpFill ? box.new(tStart, up, tEnd, o, xloc = xloc.bar_time, border_color = color.new(color.white, 100), bgcolor = upFill) : na
    box bDn = showDnFill ? box.new(tStart, o, tEnd, dn, xloc = xloc.bar_time, border_color = color.new(color.white, 100), bgcolor = dnFill) : na
    label lO = fLabel(tEnd, o, "Open " + str.tostring(o, format.mintick), openColor)
    label lU = fLabel(tEnd, up, "ATR+ " + str.tostring(up, format.mintick), upperColor)
    label lD = fLabel(tEnd, dn, "ATR- " + str.tostring(dn, format.mintick), lowerColor)
    pushBox(bUp)
    pushBox(bDn)
    pushLabel(lO)
    pushLabel(lU)
    pushLabel(lD)
    [bUp, bDn, lO, lU, lD]

// Pullback levels = 30/50/100% of actual day range from the active extreme
createPullbacks(int tStart, int tEnd, float o, float dayHi, float dayLo, bool fromHigh) =>
    float rng = dayHi - dayLo
    float p30  = fromHigh ? dayHi - rng * 0.30 : dayLo + rng * 0.30
    float p50  = fromHigh ? dayHi - rng * 0.50 : dayLo + rng * 0.50
    float p100 = fromHigh ? dayHi - rng * 1.00 : dayLo + rng * 1.00
    line v = showVert ? line.new(tStart, dayHi, tStart, dayLo, xloc = xloc.bar_time, color = vertColor, style = lineStyleOf(vertStyle), width = vertWidth) : na
    line oL = showOpen ? line.new(tStart, o, tEnd, o, xloc = xloc.bar_time, color = openColor, style = lineStyleOf(openStyle), width = openWidth) : na
    line l30 = line.new(tStart, p30, tEnd, p30, xloc = xloc.bar_time, color = pb30Color, style = line.style_solid, width = 2)
    line l50 = line.new(tStart, p50, tEnd, p50, xloc = xloc.bar_time, color = pb50Color, style = line.style_solid, width = 2)
    line l100 = line.new(tStart, p100, tEnd, p100, xloc = xloc.bar_time, color = pb100Color, style = line.style_solid, width = 2)
    label lb30 = fLabel(tEnd, p30, "30% " + str.tostring(p30, format.mintick), pb30Color)
    label lb50 = fLabel(tEnd, p50, "50% " + str.tostring(p50, format.mintick), pb50Color)
    label lb100 = fLabel(tEnd, p100, "100% " + str.tostring(p100, format.mintick), pb100Color)
    label lO = fLabel(tEnd, o, "Open " + str.tostring(o, format.mintick), openColor)
    pushLine(v)
    pushLine(oL)
    pushLine(l30)
    pushLine(l50)
    pushLine(l100)
    pushLabel(lb30)
    pushLabel(lb50)
    pushLabel(lb100)
    pushLabel(lO)
    [v, oL, l30, l50, l100, lb30, lb50, lb100, lO]

updateForecastEnd(line oL, line uL, line dL, box bUp, box bDn, label lO, label lU, label lD, int tEnd) =>
    if not na(oL)
        line.set_x2(oL, tEnd)
    if not na(uL)
        line.set_x2(uL, tEnd)
    if not na(dL)
        line.set_x2(dL, tEnd)
    if not na(bUp)
        box.set_right(bUp, tEnd)
    if not na(bDn)
        box.set_right(bDn, tEnd)
    if not na(lO)
        label.set_x(lO, tEnd)
    if not na(lU)
        label.set_x(lU, tEnd)
    if not na(lD)
        label.set_x(lD, tEnd)

updatePullbackEnd(line oL, line l30, line l50, line l100, label lb30, label lb50, label lb100, label lO, float o, float dayHi, float dayLo, bool fromHigh, int tEnd) =>
    float rng = dayHi - dayLo
    float p30 = fromHigh ? dayHi - rng * 0.30 : dayLo + rng * 0.30
    float p50 = fromHigh ? dayHi - rng * 0.50 : dayLo + rng * 0.50
    float p100 = fromHigh ? dayHi - rng * 1.00 : dayLo + rng * 1.00
    if not na(oL)
        line.set_xy2(oL, tEnd, o)
    if not na(l30)
        line.set_xy2(l30, tEnd, p30)
        line.set_y1(l30, p30)
    if not na(l50)
        line.set_xy2(l50, tEnd, p50)
        line.set_y1(l50, p50)
    if not na(l100)
        line.set_xy2(l100, tEnd, p100)
        line.set_y1(l100, p100)
    if not na(lb30)
        label.set_xy(lb30, tEnd, p30)
        label.set_text(lb30, "30% " + str.tostring(p30, format.mintick))
    if not na(lb50)
        label.set_xy(lb50, tEnd, p50)
        label.set_text(lb50, "50% " + str.tostring(p50, format.mintick))
    if not na(lb100)
        label.set_xy(lb100, tEnd, p100)
        label.set_text(lb100, "100% " + str.tostring(p100, format.mintick))
    if not na(lO)
        label.set_xy(lO, tEnd, o)

trimHist(array<int> starts, array<int> ends, array<float> opens, array<float> highs, array<float> lows, int maxClosed) =>
    while array.size(starts) > maxClosed
        array.shift(starts)
        array.shift(ends)
        array.shift(opens)
        array.shift(highs)
        array.shift(lows)

// ─── Daily data (symbol session) ────────────────────────────────────────────
[prevDayAtr, closedOpen, closedHigh, closedLow] = request.security(
     syminfo.tickerid, "D",
     [ta.atr(atrLen)[1], open[1], high[1], low[1]],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on
 )

[dayOpen, dayStartTime, dayEndTime, dayHighD, dayLowD] = request.security(
     syminfo.tickerid, "D",
     [open, time, time_close, high, low],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off
 )

int endTime = na(dayEndTime) ? dayStartTime + MS_IN_DAY : dayEndTime

// ─── Day buffers ────────────────────────────────────────────────────────────
var array<int>   startArr = array.new_int()
var array<int>   endArr   = array.new_int()
var array<float> openArr  = array.new_float()
var array<float> highArr  = array.new_float()
var array<float> lowArr   = array.new_float()

var int   curStart   = na
var int   curEnd     = na
var float curOpen    = na
var float curAtr     = na
var int   lastDayKey = na

bool newDay = not na(dayStartTime) and (na(lastDayKey) or dayStartTime != lastDayKey)
int  maxClosed = math.max(historyDays - 1, 0)

if newDay
    if not na(curStart) and not na(curEnd) and not na(closedOpen) and not na(closedHigh) and not na(closedLow)
        array.push(startArr, curStart)
        array.push(endArr, curEnd)
        array.push(openArr, closedOpen)
        array.push(highArr, closedHigh)
        array.push(lowArr, closedLow)
        trimHist(startArr, endArr, openArr, highArr, lowArr, maxClosed)

    if not na(dayOpen) and not na(prevDayAtr) and not na(dayStartTime)
        curStart := dayStartTime
        curEnd   := endTime
        curOpen  := dayOpen
        curAtr   := prevDayAtr
    else
        curStart := na
        curEnd   := na
        curOpen  := na
        curAtr   := na

    lastDayKey := dayStartTime
else if not na(curStart)
    curEnd := endTime

// ─── Metrics ────────────────────────────────────────────────────────────────
float sessHigh = not na(dayHighD) and not na(dayOpen) ? math.max(dayHighD, dayOpen) : dayHighD
float sessLow  = not na(dayLowD) and not na(dayOpen) ? math.min(dayLowD, dayOpen) : dayLowD

float atrPts          = not na(prevDayAtr) and pointStep > 0 ? prevDayAtr / pointStep : na
float prevDayRangePts = not na(closedHigh) and not na(closedLow) and pointStep > 0 ? (closedHigh - closedLow) / pointStep : na
float todayRangePts   = not na(sessHigh) and not na(sessLow) and pointStep > 0 ? (sessHigh - sessLow) / pointStep : na
float todayPctOfAtr   = not na(atrPts) and atrPts > 0 and not na(todayRangePts) ? todayRangePts / atrPts * 100.0 : na
float fromOpenPts     = not na(dayOpen) and pointStep > 0 ? (close - dayOpen) / pointStep : na
float upFromLowPts    = not na(sessLow) and pointStep > 0 ? (close - sessLow) / pointStep : na
float dnFromHighPts   = not na(sessHigh) and pointStep > 0 ? (sessHigh - close) / pointStep : na
float possibleUp      = not na(dayOpen) and not na(prevDayAtr) ? dayOpen + prevDayAtr * atrMult : na
float possibleDn      = not na(dayOpen) and not na(prevDayAtr) ? dayOpen - prevDayAtr * atrMult : na

bool pullbackActive = showPullbacks and not na(todayRangePts) and not na(atrPts) and atrPts > 0 and todayRangePts >= atrPts
bool extremeIsHigh  = not na(dnFromHighPts) and not na(upFromLowPts) and dnFromHighPts <= upFromLowPts

float dayRng = not na(sessHigh) and not na(sessLow) ? sessHigh - sessLow : na
float pb30Price  = pullbackActive and not na(dayRng) ? (extremeIsHigh ? sessHigh - dayRng * 0.30 : sessLow + dayRng * 0.30) : na
float pb50Price  = pullbackActive and not na(dayRng) ? (extremeIsHigh ? sessHigh - dayRng * 0.50 : sessLow + dayRng * 0.50) : na
float pb100Price = pullbackActive and not na(dayRng) ? (extremeIsHigh ? sessHigh - dayRng * 1.00 : sessLow + dayRng * 1.00) : na

// ─── Visuals ────────────────────────────────────────────────────────────────
var line  curVert   = na
var line  curOpenL  = na
var line  curUpper  = na
var line  curLower  = na
var box   curUpBox  = na
var box   curDnBox  = na
var label curOpenLb = na
var label curUpLb   = na
var label curDnLb   = na
var line  curPb30   = na
var line  curPb50   = na
var line  curPb100  = na
var label curPb30Lb = na
var label curPb50Lb = na
var label curPb100Lb = na
var bool  visualsReady   = false
var int   paintedDayKey  = na
var bool  paintedPullback = false

// Current session day (cur*) always gets forecast fills OR pullbacks on last bar.
// Do not gate on timenow — that breaks Bar Replay / historical charts (no colors, no PB).

if barstate.islast
    bool dayChanged  = not visualsReady or paintedDayKey != lastDayKey
    bool modeChanged = paintedPullback != pullbackActive
    bool needFullPaint = dayChanged or modeChanged

    if needFullPaint
        clearDrawings()
        // Reset refs in global scope only (CE10088 — no := to globals inside functions)
        curVert := na
        curOpenL := na
        curUpper := na
        curLower := na
        curUpBox := na
        curDnBox := na
        curOpenLb := na
        curUpLb := na
        curDnLb := na
        curPb30 := na
        curPb50 := na
        curPb100 := na
        curPb30Lb := na
        curPb50Lb := na
        curPb100Lb := na

        int nHist = array.size(startArr)
        if nHist > 0
            for i = 0 to nHist - 1
                createActual(array.get(startArr, i), array.get(endArr, i), array.get(openArr, i), array.get(highArr, i), array.get(lowArr, i))

        // Always draw the current session day (cur*) with forecast OR pullbacks
        if not na(curStart) and not na(curEnd) and not na(curOpen) and not na(curAtr)
            if pullbackActive and not na(sessHigh) and not na(sessLow)
                [v, oL, l30, l50, l100, lb30, lb50, lb100, lO] = createPullbacks(curStart, curEnd, curOpen, sessHigh, sessLow, extremeIsHigh)
                curVert := v
                curOpenL := oL
                curPb30 := l30
                curPb50 := l50
                curPb100 := l100
                curPb30Lb := lb30
                curPb50Lb := lb50
                curPb100Lb := lb100
                curOpenLb := lO
                paintedPullback := true
            else
                [v, oL, uL, dL] = createForecast(curStart, curEnd, curOpen, curAtr)
                curVert := v
                curOpenL := oL
                curUpper := uL
                curLower := dL
                [bUp, bDn, lO, lU, lD] = createExtras(curStart, curEnd, curOpen, curAtr)
                curUpBox := bUp
                curDnBox := bDn
                curOpenLb := lO
                curUpLb := lU
                curDnLb := lD
                paintedPullback := false

        visualsReady  := true
        paintedDayKey := lastDayKey
    else
        if paintedPullback and not na(sessHigh) and not na(sessLow)
            updatePullbackEnd(curOpenL, curPb30, curPb50, curPb100, curPb30Lb, curPb50Lb, curPb100Lb, curOpenLb, curOpen, sessHigh, sessLow, extremeIsHigh, curEnd)
        else
            updateForecastEnd(curOpenL, curUpper, curLower, curUpBox, curDnBox, curOpenLb, curUpLb, curDnLb, curEnd)
            if not pullbackActive and na(curUpBox) and na(curDnBox) and not na(curStart) and not na(curOpen) and not na(curAtr)
                [bUp, bDn, lO, lU, lD] = createExtras(curStart, curEnd, curOpen, curAtr)
                curUpBox := bUp
                curDnBox := bDn
                curOpenLb := lO
                curUpLb := lU
                curDnLb := lD

// ─── Table ──────────────────────────────────────────────────────────────────
var table tbl = table.new(tablePosOf(tablePos), 2, 11, bgcolor = color.new(color.navy, 15), border_width = 1, border_color = color.new(color.white, 60))

if showTable and barstate.islast
    string stepTxt  = pointStepOpt == "mintick" ? "mintick (" + str.tostring(syminfo.mintick) + ")" : pointStepOpt == "manual" ? "manual (" + str.tostring(pointStep) + ")" : str.tostring(pointStep)
    string atrTxt   = na(atrPts) ? "—" : str.tostring(atrPts, "#.#") + " pts"
    string todayTxt = na(todayRangePts) ? "—" : str.tostring(todayRangePts, "#.#") + " pts" + (na(todayPctOfAtr) ? "" : " (" + str.tostring(todayPctOfAtr, "#.#") + "% ATR)")
    string yestTxt  = na(prevDayRangePts) ? "—" : str.tostring(prevDayRangePts, "#.#") + " pts"
    string fromOpenTxt = na(fromOpenPts) ? "—" : (fromOpenPts >= 0 ? "+" : "") + str.tostring(fromOpenPts, "#.#") + " pts"
    string pbStatus = pullbackActive ? "ACTIVE (" + (extremeIsHigh ? "from High" : "from Low") + ")" : "off"

    table.cell(tbl, 0, 0, "Point step", text_color = color.yellow, text_size = size.small, bgcolor = color.new(color.gray, 50))
    table.cell(tbl, 1, 0, stepTxt, text_color = color.yellow, text_size = size.small, bgcolor = color.new(color.gray, 50))
    table.cell(tbl, 0, 1, "Today range", text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 30))
    table.cell(tbl, 1, 1, todayTxt, text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 30))
    table.cell(tbl, 0, 2, "From open", text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 2, fromOpenTxt, text_color = na(fromOpenPts) ? color.gray : (fromOpenPts >= 0 ? color.lime : color.red), text_size = size.small)
    table.cell(tbl, 0, 3, "From day's low", text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 3, na(upFromLowPts) ? "—" : "+" + str.tostring(upFromLowPts, "#.#") + " pts", text_color = color.lime, text_size = size.small)
    table.cell(tbl, 0, 4, "From day's high", text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 4, na(dnFromHighPts) ? "—" : "−" + str.tostring(dnFromHighPts, "#.#") + " pts", text_color = color.red, text_size = size.small)
    table.cell(tbl, 0, 5, "Yesterday H−L", text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 40))
    table.cell(tbl, 1, 5, yestTxt, text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 40))
    table.cell(tbl, 0, 6, "Daily ATR (calc)", text_color = color.gray, text_size = size.small)
    table.cell(tbl, 1, 6, atrTxt, text_color = color.gray, text_size = size.small)
    table.cell(tbl, 0, 7, "Pullbacks", text_color = color.white, text_size = size.small, bgcolor = pullbackActive ? color.new(color.orange, 30) : color.new(color.gray, 60))
    table.cell(tbl, 1, 7, pbStatus, text_color = color.white, text_size = size.small, bgcolor = pullbackActive ? color.new(color.orange, 30) : color.new(color.gray, 60))
    if pullbackActive
        table.cell(tbl, 0, 8, "PB 30%", text_color = pb30Color, text_size = size.small)
        table.cell(tbl, 1, 8, str.tostring(pb30Price, format.mintick), text_color = color.white, text_size = size.small)
        table.cell(tbl, 0, 9, "PB 50%", text_color = pb50Color, text_size = size.small)
        table.cell(tbl, 1, 9, str.tostring(pb50Price, format.mintick), text_color = color.white, text_size = size.small)
        table.cell(tbl, 0, 10, "PB 100%", text_color = pb100Color, text_size = size.small)
        table.cell(tbl, 1, 10, str.tostring(pb100Price, format.mintick), text_color = color.white, text_size = size.small)
    else
        table.cell(tbl, 0, 8, "Possible up", text_color = color.aqua, text_size = size.small)
        table.cell(tbl, 1, 8, na(possibleUp) ? "—" : str.tostring(possibleUp, format.mintick), text_color = color.aqua, text_size = size.small)
        table.cell(tbl, 0, 9, "Possible down", text_color = color.orange, text_size = size.small)
        table.cell(tbl, 1, 9, na(possibleDn) ? "—" : str.tostring(possibleDn, format.mintick), text_color = color.orange, text_size = size.small)
        table.cell(tbl, 0, 10, "", text_color = color.gray, text_size = size.small)
        table.cell(tbl, 1, 10, "", text_color = color.gray, text_size = size.small)
else if barstate.islast
    table.clear(tbl, 0, 0, 1, 10)
````
