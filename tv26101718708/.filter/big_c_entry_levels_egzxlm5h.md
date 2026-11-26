# Big C Entry & Levels

- url: https://www.tradingview.com/script/eGZXlm5h-Big-C-Entry-Levels/
- type: indicator
- pine_id: PUB;895df69da0334c1f975e6feb6dc9d28d
- version: 8.0

## Description

Most intraday charts get ruined by clutter. Too many lines, too many signals, and no clear idea what actually matters.

Big C Entry & Levels was built to solve that.

This is a clean intraday trading system focused on liquid names and fast-moving charts. It combines momentum, trend structure, and key price levels into one tool designed to help spot higher-quality breakout, continuation, and sweep opportunities without overwhelming the screen.

What It Does

The script filters setups using multiple layers of context, including:

Trend alignment with EMA structure
VWAP positioning
Relative volume (RVOL)
Candle quality and momentum
Stretch from trend averages
Time-of-day conditions
Reward-to-risk viability before confirming entries

The goal is not to fire signals constantly. The goal is to highlight cleaner opportunities when multiple factors align.

Smart Support & Resistance

Instead of plotting endless levels everywhere, the script scans major reference points such as:

Previous Day High / Low
Opening Range High / Low
Session extremes
Recent pivots

It then prioritizes the nearest relevant support and resistance zones so the chart stays readable and decision-focused.

Setup Types

CONT
Continuation setups during established trend conditions, often after shallow pullbacks.

BO
Breakout setups through important structure with momentum confirmation.

SWEEP
Reclaims after liquidity grabs or failed pushes through key levels.

Preset Modes

A built-in preset system lets users adapt quickly without changing dozens of inputs.

Balanced
Recommended default. Strong mix of quality and frequency.

Conservative
Stricter filters, fewer signals, more selectivity.

Aggressive
More responsive settings for fast markets and active traders.

Custom
Manual control of thresholds and behavior.

Clean Visual Design

The chart is designed to stay usable:

Clear EMA hierarchy
VWAP context
Opening Range plotting
Active stop and target levels during trades
Compact entry labels
Optional advanced visuals hidden by default
Alerts Included
Long Entries
Short Entries
Trade Exits
Breakout Triggers
Continuation Triggers
Support / Resistance Crosses
Best Use

Designed primarily for intraday traders using lower timeframes where momentum, level-to-level movement, and clean structure matter most.

Notes

No indicator predicts every move. This tool is built to improve structure, context, and consistency so decisions become clearer.

Use proper risk management and test settings that fit your market and style.

## Source Code

````pine
//@version=6
indicator("Big C Entry & Levels", overlay=true, max_lines_count=400, max_labels_count=400)

// ==========================================
// 1. USER SETTINGS
// ==========================================

// Display
showLabels      = input.bool(true,  "Show Right-Side Labels",       group="Display")
showPrices      = input.bool(true,  "Show Prices In Labels",        group="Display")
lineBack        = input.int(120,    "Line Length Back",   minval=25,  maxval=500, group="Display")
lineForward     = input.int(20,     "Line Length Forward", minval=5,  maxval=100, group="Display")
labelOffset     = input.int(3,      "Label Offset",       minval=1,   maxval=25,  group="Display")
showBreakMarks  = input.bool(true,  "Show Breakout Markers",        group="Display")
showNearLevel   = input.bool(true,  "Highlight Levels Near Price",  tooltip="Brightens any level within 1 ATR of current price.", group="Display")
showAlertPlots  = input.bool(true,  "Show Alert Source Plots",      tooltip="Keeps key levels in TradingView's alert source dropdown.", group="Display")

// Trend Tools
showMAs         = input.bool(true,  "Show Moving Averages",         group="Trend Tools")
showVWAP        = input.bool(true,  "Show VWAP + Bands",            group="Trend Tools")
vwapBandMult    = input.float(1.0,  "VWAP Band Multiplier", minval=0.25, step=0.25, tooltip="Standard deviation multiplier for VWAP bands. 1.0 = 1 SD, 2.0 = 2 SD.", group="Trend Tools")
emaFastLen      = input.int(8,      "Fast EMA",  minval=1,          group="Trend Tools")
emaMidLen       = input.int(34,     "Mid EMA",   minval=1,          group="Trend Tools")
sma50Len        = input.int(50,     "50 SMA",    minval=1,          group="Trend Tools")
sma200Len       = input.int(200,    "200 SMA",   minval=1,          group="Trend Tools")

// Opening Range
showOR          = input.bool(true,  "Opening Range High/Low",       group="Opening Range")
orTimeframe     = input.string("15m", "Opening Range Time", options=["5m","15m","30m","1hr"], group="Opening Range")
showORMid       = input.bool(false, "Opening Range Midpoint",       group="Opening Range")

// Premarket
showPM          = input.bool(true,  "Premarket High/Low",           group="Premarket")
showPMMid       = input.bool(false, "Premarket Midpoint",           group="Premarket")

// Current Levels
showCD          = input.bool(true,  "Current Day High/Low",         group="Current Levels")
showCDO         = input.bool(true,  "Current Day Open",             group="Current Levels")
showCW          = input.bool(false, "Current Week High/Low",        group="Current Levels")
showCM          = input.bool(false, "Current Month High/Low",       group="Current Levels")

// Previous Levels
showPD          = input.bool(true,  "Previous Day High/Low",        group="Previous Levels")
showPDO         = input.bool(true,  "Previous Day Open",            group="Previous Levels")
showPW          = input.bool(true,  "Previous Week High/Low",       group="Previous Levels")
showPMo         = input.bool(false, "Previous Month High/Low",      group="Previous Levels")
showPQ          = input.bool(false, "Previous Quarter High/Low",    tooltip="Recommended for daily/weekly charts only.", group="Previous Levels")
showPY          = input.bool(false, "Previous Year High/Low",       tooltip="Recommended for daily/weekly charts only.", group="Previous Levels")

// Midpoints
showPDMid       = input.bool(false, "Previous Day Midpoint",        group="Midpoints")
showPWMid       = input.bool(false, "Previous Week Midpoint",       group="Midpoints")
showPMoMid      = input.bool(false, "Previous Month Midpoint",      group="Midpoints")
showPQMid       = input.bool(false, "Previous Quarter Midpoint",    group="Midpoints")
showPYMid       = input.bool(false, "Previous Year Midpoint",       group="Midpoints")

// Major Levels
showATH         = input.bool(true,  "All-Time High",                group="Major Levels")
showATL         = input.bool(false, "All-Time Low",                 group="Major Levels")
showRoundNums   = input.bool(false, "Round Number Levels",          group="Major Levels")
roundStep       = input.float(10.0, "Round Number Step", minval=0.25, step=0.25, group="Major Levels")
roundCount      = input.int(2,      "Round Numbers Above/Below",    minval=1, maxval=6, group="Major Levels")

// Alerts
alertMode       = input.string("Close Break", "Alert Mode", options=["Touch","Close Break","Confirmed Break"], group="Alerts")
bufferAtr       = input.float(0.03, "Confirmed Break Buffer (ATR)", minval=0.0, step=0.01, group="Alerts")
useRTHAlerts    = input.bool(true,  "Alerts During RTH Only",       group="Alerts")

// Style
levelWidth      = input.int(1, "Level Line Width",  minval=1, maxval=4, group="Style")
mainWidth       = input.int(2, "Major Line Width",  minval=1, maxval=4, group="Style")
lineStyleInput  = input.string("Dashed", "Level Line Style", options=["Solid","Dashed","Dotted"], group="Style")

// Colors
colorOR         = input.color(color.new(#4DA6FF, 0),   "Opening Range",   group="Colors")
colorPM         = input.color(color.new(#FFA726, 0),   "Premarket",       group="Colors")
colorCurrent    = input.color(color.new(#B388FF, 0),   "Current Levels",  group="Colors")
colorOpen       = input.color(color.new(#E040FB, 0),   "Day Open",        group="Colors")
colorHigh       = input.color(color.new(#00E676, 0),   "Previous Highs",  group="Colors")
colorLow        = input.color(color.new(#FF5252, 0),   "Previous Lows",   group="Colors")
colorMid        = input.color(color.new(#FFFFFF, 55),  "Midpoints",       group="Colors")
colorMajor      = input.color(color.new(#FFD600, 0),   "Major Levels",    group="Colors")
colorRound      = input.color(color.new(#FFFFFF, 75),  "Round Numbers",   group="Colors")
colorVWAP       = input.color(color.new(#FFFFFF, 40),  "VWAP",            group="Colors")
colorVWAPBand   = input.color(color.new(#FFFFFF, 75),  "VWAP Bands",      group="Colors")

// ==========================================
// 2. BASE CONDITIONS
// ==========================================

isIntraday     = timeframe.isintraday
rthTime        = time(timeframe.period, "0930-1600:23456", "America/New_York")
pmTime         = time(timeframe.period, "0400-0929:23456", "America/New_York")
inRTH          = not na(rthTime) and isIntraday
inPM           = not na(pmTime)  and isIntraday
isNewDay       = ta.change(time("D"))   != 0
isNewWeek      = ta.change(time("W"))   != 0
isNewMonth     = ta.change(time("M"))   != 0

// Reliable quarter detection using calendar months instead of "3M" resolution
_cm            = month(time)
_pm            = month(time[1])
isNewQuarter   = _cm != _pm and (_cm == 1 or _cm == 4 or _cm == 7 or _cm == 10)

isNewYear      = ta.change(time("12M")) != 0
currTime       = hour(time, "America/New_York") * 100 + minute(time, "America/New_York")
atr            = ta.atr(14)
safeAtr        = nz(atr, close * 0.001)
labelYOffset   = safeAtr * 0.06
breakBuffer    = safeAtr * bufferAtr
alertSessionOK = not useRTHAlerts or inRTH
levelStyle     = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dotted" ? line.style_dotted : line.style_dashed

// ==========================================
// 3. TREND TOOLS — MAs + VWAP WITH SD BANDS
// ==========================================

emaFast  = ta.ema(close, emaFastLen)
emaMid   = ta.ema(close, emaMidLen)
sma50    = ta.sma(close, sma50Len)
sma200   = ta.sma(close, sma200Len)

// VWAP with standard deviation bands
[vwapVal, vwapUpper, vwapLower] = ta.vwap(close, false, 1)
vwapSD1Upper = nz(vwapVal + vwapBandMult * (vwapUpper - vwapVal), vwapVal)
vwapSD1Lower = nz(vwapVal - vwapBandMult * (vwapVal - vwapLower), vwapVal)

plot(showMAs ? emaFast : na,                            "Fast EMA", linewidth=1, color=color.new(#00D9FF, 0))
plot(showMAs ? emaMid  : na,                            "Mid EMA",  linewidth=2, color=color.new(#FFD000, 0))
plot(showMAs ? sma50   : na,                            "50 SMA",   linewidth=1, color=color.new(#A020F0, 0))
plot(showMAs ? sma200  : na,                            "200 SMA",  linewidth=2, color=color.new(#FFFFFF, 0))
plot(showVWAP and isIntraday ? vwapVal      : na,       "VWAP",       linewidth=2, color=colorVWAP)
plot(showVWAP and isIntraday ? vwapSD1Upper : na,       "VWAP +1 SD", linewidth=1, color=colorVWAPBand)
plot(showVWAP and isIntraday ? vwapSD1Lower : na,       "VWAP -1 SD", linewidth=1, color=colorVWAPBand)

// ==========================================
// 4. SESSION LEVELS — OR + PREMARKET
// ==========================================

orEndTime  = orTimeframe == "5m" ? 935 : orTimeframe == "15m" ? 945 : orTimeframe == "30m" ? 1000 : 1030
inOR       = inRTH and currTime >= 930 and currTime < orEndTime
orComplete = inRTH and currTime >= orEndTime

var float orh      = na
var float orl      = na
var bool  orLocked = false
var float pmh      = na
var float pml      = na

if isNewDay and isIntraday
    orh      := na
    orl      := na
    orLocked := false
    pmh      := na
    pml      := na

if inPM
    pmh := na(pmh) ? high : math.max(pmh, high)
    pml := na(pml) ? low  : math.min(pml, low)

if inOR
    orh := na(orh) ? high : math.max(orh, high)
    orl := na(orl) ? low  : math.min(orl, low)

// Lock OR only when complete and values are valid
if not orLocked and orComplete and not na(orh) and not na(orl)
    orLocked := true

orMid = (orh + orl) / 2.0
pmMid = (pmh + pml) / 2.0

// ==========================================
// 5. CURRENT LEVELS
// ==========================================

var float cdOpen = na
var float cdh    = na
var float cdl    = na
var float cwh    = na
var float cwl    = na
var float cmh    = na
var float cml    = na

// Current day open — capture only the first bar of each new day
if isNewDay
    cdOpen := open
    cdh    := high
    cdl    := low
else
    cdh := math.max(nz(cdh, high), high)
    cdl := math.min(nz(cdl, low),  low)

if isNewWeek
    cwh := high
    cwl := low
else
    cwh := math.max(nz(cwh, high), high)
    cwl := math.min(nz(cwl, low),  low)

if isNewMonth
    cmh := high
    cml := low
else
    cmh := math.max(nz(cmh, high), high)
    cml := math.min(nz(cml, low),  low)

// ==========================================
// 6. PREVIOUS LEVELS — D / W / M / Q / Y
// ==========================================
// 6. PREVIOUS LEVELS — D / W / M / Q / Y
// ==========================================

// Fetch each timeframe in one tuple call to minimize TV's internal plot count
[pdHigh, pdLow, pdOpen]   = request.security(syminfo.tickerid, "D",   [high[1], low[1], open[1]],  lookahead=barmerge.lookahead_on)
[pwHigh, pwLow]            = request.security(syminfo.tickerid, "W",   [high[1], low[1]],           lookahead=barmerge.lookahead_on)
[pmHigh, pmLow]            = request.security(syminfo.tickerid, "M",   [high[1], low[1]],           lookahead=barmerge.lookahead_on)
[pqHigh, pqLow]            = request.security(syminfo.tickerid, "3M",  [high[1], low[1]],           lookahead=barmerge.lookahead_on)
[pyHigh, pyLow]            = request.security(syminfo.tickerid, "12M", [high[1], low[1]],           lookahead=barmerge.lookahead_on)

pdMid     = (pdHigh + pdLow) / 2.0
pwMid     = (pwHigh + pwLow) / 2.0
pmMidPrev = (pmHigh + pmLow) / 2.0
pqMid     = (pqHigh + pqLow) / 2.0
pyMid     = (pyHigh + pyLow) / 2.0

// ==========================================
// 7. ATH / ATL — PROPER HIGHER-TF CALCULATION
// ==========================================

// Pull ATH/ATL from monthly timeframe for true historical range.
// Merging into the existing monthly call saves a security call.
[athFromMTF, atlFromMTF] = request.security(syminfo.tickerid, "M", [ta.highest(high, 500), ta.lowest(low, 500)], lookahead=barmerge.lookahead_on)

// Rolling fallback if MTF data is unavailable
var float athRolling = na
var float atlRolling = na
athRolling := na(athRolling) ? high : math.max(athRolling, high)
atlRolling := na(atlRolling) ? low  : math.min(atlRolling, low)

ath = nz(athFromMTF, athRolling)
atl = nz(atlFromMTF, atlRolling)


// ==========================================
// 8. DRAWING ENGINE
// ==========================================

f_text(_name, _price) =>
    showPrices ? _name + " " + str.tostring(_price, format.mintick) : _name

type LevelDraw
    line  ln
    label lb

// _near = true brightens the level when price is within 1 ATR
f_update_level(_show, _price, _name, _clr, _width, _style, _side, LevelDraw _draw) =>
    if barstate.islast
        if _show and not na(_price)
            x1     = bar_index - lineBack
            x2     = bar_index + lineForward
            lx     = x2 + labelOffset
            ly     = _side == 1 ? _price + labelYOffset : _side == -1 ? _price - labelYOffset : _price
            isNear = showNearLevel and math.abs(close - _price) <= safeAtr
            drawClr  = isNear ? color.new(_clr, 0)  : _clr
            drawWidth = isNear ? math.min(_width + 1, 4) : _width

            if na(_draw.ln)
                _draw.ln := line.new(x1, _price, x2, _price, color=drawClr, width=drawWidth, style=_style)
            else
                line.set_xy1(_draw.ln,   x1, _price)
                line.set_xy2(_draw.ln,   x2, _price)
                line.set_color(_draw.ln, drawClr)
                line.set_width(_draw.ln, drawWidth)
                line.set_style(_draw.ln, _style)

            if showLabels
                if na(_draw.lb)
                    _draw.lb := label.new(lx, ly, "", color=color.new(color.black, 100), textcolor=drawClr, style=label.style_label_left, size=size.tiny)
                label.set_x(_draw.lb,         lx)
                label.set_y(_draw.lb,         ly)
                label.set_text(_draw.lb,      f_text(_name, _price))
                label.set_textcolor(_draw.lb, drawClr)
            if not showLabels and not na(_draw.lb)
                label.delete(_draw.lb)
                _draw.lb := na
        else
            if not na(_draw.ln)
                line.delete(_draw.ln)
                _draw.ln := na
            if not na(_draw.lb)
                label.delete(_draw.lb)
                _draw.lb := na

// ── Persistent drawing objects ────────────────────────────────────────────────
var draw_orh  = LevelDraw.new(na, na)
var draw_orl  = LevelDraw.new(na, na)
var draw_orm  = LevelDraw.new(na, na)
var draw_pmh  = LevelDraw.new(na, na)
var draw_pml  = LevelDraw.new(na, na)
var draw_pmm  = LevelDraw.new(na, na)
var draw_cdo  = LevelDraw.new(na, na)
var draw_cdh  = LevelDraw.new(na, na)
var draw_cdl  = LevelDraw.new(na, na)
var draw_cwh  = LevelDraw.new(na, na)
var draw_cwl  = LevelDraw.new(na, na)
var draw_cmh  = LevelDraw.new(na, na)
var draw_cml  = LevelDraw.new(na, na)
var draw_pdo  = LevelDraw.new(na, na)
var draw_pdh  = LevelDraw.new(na, na)
var draw_pdl  = LevelDraw.new(na, na)
var draw_pwh  = LevelDraw.new(na, na)
var draw_pwl  = LevelDraw.new(na, na)
var draw_moh  = LevelDraw.new(na, na)
var draw_mol  = LevelDraw.new(na, na)
var draw_pqh  = LevelDraw.new(na, na)
var draw_pql  = LevelDraw.new(na, na)
var draw_pyh  = LevelDraw.new(na, na)
var draw_pyl  = LevelDraw.new(na, na)
var draw_pdm  = LevelDraw.new(na, na)
var draw_pwm  = LevelDraw.new(na, na)
var draw_mom  = LevelDraw.new(na, na)
var draw_pqm  = LevelDraw.new(na, na)
var draw_pym  = LevelDraw.new(na, na)
var draw_ath  = LevelDraw.new(na, na)
var draw_atl  = LevelDraw.new(na, na)

// ── Draw calls ────────────────────────────────────────────────────────────────
f_update_level(showOR and orLocked and isIntraday,              orh,      "ORH",    colorOR,      mainWidth,  line.style_solid, 1,  draw_orh)
f_update_level(showOR and orLocked and isIntraday,              orl,      "ORL",    colorOR,      mainWidth,  line.style_solid, -1, draw_orl)
f_update_level(showOR and showORMid and orLocked and isIntraday,orMid,    "OR Mid", colorMid,     levelWidth, levelStyle,       0,  draw_orm)
f_update_level(showPM and isIntraday,                           pmh,      "PMH",    colorPM,      levelWidth, levelStyle,       1,  draw_pmh)
f_update_level(showPM and isIntraday,                           pml,      "PML",    colorPM,      levelWidth, levelStyle,       -1, draw_pml)
f_update_level(showPM and showPMMid and isIntraday,             pmMid,    "PM Mid", colorMid,     levelWidth, levelStyle,       0,  draw_pmm)
f_update_level(showCDO,                                         cdOpen,   "CDO",    colorOpen,    levelWidth, levelStyle,       0,  draw_cdo)
f_update_level(showCD,                                          cdh,      "CDH",    colorCurrent, levelWidth, levelStyle,       1,  draw_cdh)
f_update_level(showCD,                                          cdl,      "CDL",    colorCurrent, levelWidth, levelStyle,       -1, draw_cdl)
f_update_level(showCW,                                          cwh,      "CWH",    colorCurrent, levelWidth, levelStyle,       1,  draw_cwh)
f_update_level(showCW,                                          cwl,      "CWL",    colorCurrent, levelWidth, levelStyle,       -1, draw_cwl)
f_update_level(showCM,                                          cmh,      "CMH",    colorCurrent, levelWidth, levelStyle,       1,  draw_cmh)
f_update_level(showCM,                                          cml,      "CML",    colorCurrent, levelWidth, levelStyle,       -1, draw_cml)
f_update_level(showPDO,                                         pdOpen,   "PDO",    colorOpen,    levelWidth, levelStyle,       0,  draw_pdo)
f_update_level(showPD,                                          pdHigh,   "PDH",    colorHigh,    mainWidth,  levelStyle,       1,  draw_pdh)
f_update_level(showPD,                                          pdLow,    "PDL",    colorLow,     mainWidth,  levelStyle,       -1, draw_pdl)
f_update_level(showPW,                                          pwHigh,   "PWH",    colorHigh,    levelWidth, levelStyle,       1,  draw_pwh)
f_update_level(showPW,                                          pwLow,    "PWL",    colorLow,     levelWidth, levelStyle,       -1, draw_pwl)
f_update_level(showPMo,                                         pmHigh,   "PMoH",   colorHigh,    levelWidth, levelStyle,       1,  draw_moh)
f_update_level(showPMo,                                         pmLow,    "PMoL",   colorLow,     levelWidth, levelStyle,       -1, draw_mol)
f_update_level(showPQ,                                          pqHigh,   "PQH",    colorHigh,    levelWidth, levelStyle,       1,  draw_pqh)
f_update_level(showPQ,                                          pqLow,    "PQL",    colorLow,     levelWidth, levelStyle,       -1, draw_pql)
f_update_level(showPY,                                          pyHigh,   "PYH",    colorHigh,    levelWidth, levelStyle,       1,  draw_pyh)
f_update_level(showPY,                                          pyLow,    "PYL",    colorLow,     levelWidth, levelStyle,       -1, draw_pyl)
f_update_level(showPDMid,                                       pdMid,    "PD Mid", colorMid,     levelWidth, levelStyle,       0,  draw_pdm)
f_update_level(showPWMid,                                       pwMid,    "PW Mid", colorMid,     levelWidth, levelStyle,       0,  draw_pwm)
f_update_level(showPMoMid,                                      pmMidPrev,"PMo Mid",colorMid,     levelWidth, levelStyle,       0,  draw_mom)
f_update_level(showPQMid,                                       pqMid,    "PQ Mid", colorMid,     levelWidth, levelStyle,       0,  draw_pqm)
f_update_level(showPYMid,                                       pyMid,    "PY Mid", colorMid,     levelWidth, levelStyle,       0,  draw_pym)
f_update_level(showATH,                                         ath,      "ATH",    colorMajor,   mainWidth,  line.style_solid, 1,  draw_ath)
f_update_level(showATL,                                         atl,      "ATL",    colorMajor,   mainWidth,  line.style_solid, -1, draw_atl)

// ── Round numbers (pool built on last bar so close/atr are always valid) ──────
var array<line>  rnLines  = array.new<line>()
var array<label> rnLabels = array.new<label>()

if barstate.islast
    if array.size(rnLines) == 0
        for i = 0 to 12
            array.push(rnLines,  line.new(bar_index, close, bar_index + 1, close, color=color.new(colorRound, 100), width=1, style=line.style_dotted))
            array.push(rnLabels, label.new(bar_index, close, "", color=color.new(color.black, 100), textcolor=colorRound, style=label.style_label_left, size=size.tiny))

    rnTotal   = roundCount * 2 + 1
    baseRound = math.round(close / roundStep) * roundStep

    for i = 0 to 12
        ln      = array.get(rnLines,  i)
        lb      = array.get(rnLabels, i)
        validRN = showRoundNums and i < rnTotal and roundStep > 0

        if validRN
            lvl    = baseRound + (i - roundCount) * roundStep
            x1     = bar_index - lineBack
            x2     = bar_index + lineForward
            lx     = x2 + labelOffset
            isNear = showNearLevel and math.abs(close - lvl) <= safeAtr
            rnClr  = isNear ? color.new(colorRound, 0) : colorRound

            line.set_xy1(ln,    x1,  lvl)
            line.set_xy2(ln,    x2,  lvl)
            line.set_color(ln,  rnClr)

            if showLabels
                label.set_x(lb,         lx)
                label.set_y(lb,         lvl + labelYOffset)
                label.set_text(lb,      "RN " + str.tostring(lvl, format.mintick))
                label.set_textcolor(lb, rnClr)
            else
                label.set_text(lb, "")
        else
            line.set_color(ln,  color.new(colorRound, 100))
            label.set_text(lb,  "")

// ==========================================
// 9. ALERT SOURCE PLOTS
// ==========================================

// Trimmed to most actionable levels — all alertconditions still fire regardless.
plot(showAlertPlots and showOR  and orLocked and isIntraday ? orh    : na, "ORH",              color=color.new(colorOR,      100))
plot(showAlertPlots and showOR  and orLocked and isIntraday ? orl    : na, "ORL",              color=color.new(colorOR,      100))
plot(showAlertPlots and showPM  and isIntraday              ? pmh    : na, "Premarket High",   color=color.new(colorPM,      100))
plot(showAlertPlots and showPM  and isIntraday              ? pml    : na, "Premarket Low",    color=color.new(colorPM,      100))
plot(showAlertPlots and showCD                              ? cdh    : na, "Current Day High", color=color.new(colorCurrent, 100))
plot(showAlertPlots and showCD                              ? cdl    : na, "Current Day Low",  color=color.new(colorCurrent, 100))
plot(showAlertPlots and showPD                              ? pdHigh : na, "Prev Day High",    color=color.new(colorHigh,    100))
plot(showAlertPlots and showPD                              ? pdLow  : na, "Prev Day Low",     color=color.new(colorLow,     100))
plot(showAlertPlots and showPW                              ? pwHigh : na, "Prev Week High",   color=color.new(colorHigh,    100))
plot(showAlertPlots and showPW                              ? pwLow  : na, "Prev Week Low",    color=color.new(colorLow,     100))
plot(showAlertPlots and showATH                             ? ath    : na, "All-Time High",    color=color.new(colorMajor,   100))

// ==========================================
// 10. BREAKOUT LOGIC
// ==========================================

// cooldownBars = how many bars must pass before the same level can fire again.
// Prevents repeated re-cross spam on levels price bounces around.
cooldownBars = input.int(5, "Break Cooldown (bars)", minval=1, maxval=50,
     tooltip="Minimum bars between break signals on the same level. Prevents re-cross spam.", group="Alerts")

// Core break functions — only fire on static, locked levels
f_bull_break(_level) =>
    valid          = alertSessionOK and not na(_level)
    touchBreak     = high  >= _level and high[1]  <  _level
    closeBreak     = close >  _level and close[1] <= _level
    confirmedBreak = close >  _level + breakBuffer and close[1] <= _level
    valid and (alertMode == "Touch" ? touchBreak : alertMode == "Confirmed Break" ? confirmedBreak : closeBreak)

f_bear_break(_level) =>
    valid          = alertSessionOK and not na(_level)
    touchBreak     = low   <= _level and low[1]   >  _level
    closeBreak     = close <  _level and close[1] >= _level
    confirmedBreak = close <  _level - breakBuffer and close[1] >= _level
    valid and (alertMode == "Touch" ? touchBreak : alertMode == "Confirmed Break" ? confirmedBreak : closeBreak)

// Cooldown wrapper — suppresses re-fires within cooldownBars of the last signal
f_with_cooldown(_rawSignal, _lastBar) =>
    _rawSignal and (bar_index - _lastBar) >= cooldownBars

// Track last fired bar per level to enforce cooldown
var int last_orh  = 0
var int last_orl  = 0
var int last_pmh  = 0
var int last_pml  = 0
var int last_cdo  = 0
var int last_cdoB = 0
var int last_pdo  = 0
var int last_pdoB = 0
var int last_pdh  = 0
var int last_pdl  = 0
var int last_pwh  = 0
var int last_pwl  = 0
var int last_pmoh = 0
var int last_pmol = 0
var int last_pqh  = 0
var int last_pql  = 0
var int last_pyh  = 0
var int last_pyl  = 0
var int last_ath  = 0
var int last_atl  = 0

// Raw signals — only on static locked levels, never on dynamic current levels
raw_orh  = showOR  and orLocked and isIntraday and f_bull_break(orh)
raw_orl  = showOR  and orLocked and isIntraday and f_bear_break(orl)
raw_pmh  = showPM  and isIntraday              and f_bull_break(pmh)
raw_pml  = showPM  and isIntraday              and f_bear_break(pml)
raw_cdo  = showCDO                             and f_bull_break(cdOpen)
raw_cdoB = showCDO                             and f_bear_break(cdOpen)
raw_pdo  = showPDO                             and f_bull_break(pdOpen)
raw_pdoB = showPDO                             and f_bear_break(pdOpen)
raw_pdh  = showPD                              and f_bull_break(pdHigh)
raw_pdl  = showPD                              and f_bear_break(pdLow)
raw_pwh  = showPW                              and f_bull_break(pwHigh)
raw_pwl  = showPW                              and f_bear_break(pwLow)
raw_pmoh = showPMo                             and f_bull_break(pmHigh)
raw_pmol = showPMo                             and f_bear_break(pmLow)
raw_pqh  = showPQ                              and f_bull_break(pqHigh)
raw_pql  = showPQ                              and f_bear_break(pqLow)
raw_pyh  = showPY                              and f_bull_break(pyHigh)
raw_pyl  = showPY                              and f_bear_break(pyLow)
raw_ath  = showATH                             and f_bull_break(ath)
raw_atl  = showATL                             and f_bear_break(atl)

// Apply cooldown
orhBreak     = f_with_cooldown(raw_orh,  last_orh)
orlBreak     = f_with_cooldown(raw_orl,  last_orl)
pmhBreak     = f_with_cooldown(raw_pmh,  last_pmh)
pmlBreak     = f_with_cooldown(raw_pml,  last_pml)
cdoBreak     = f_with_cooldown(raw_cdo,  last_cdo)
cdoBrk       = f_with_cooldown(raw_cdoB, last_cdoB)
pdoBreak     = f_with_cooldown(raw_pdo,  last_pdo)
pdoBrk       = f_with_cooldown(raw_pdoB, last_pdoB)
pdhBreak     = f_with_cooldown(raw_pdh,  last_pdh)
pdlBreak     = f_with_cooldown(raw_pdl,  last_pdl)
pwhBreak     = f_with_cooldown(raw_pwh,  last_pwh)
pwlBreak     = f_with_cooldown(raw_pwl,  last_pwl)
pmhPrevBreak = f_with_cooldown(raw_pmoh, last_pmoh)
pmlPrevBreak = f_with_cooldown(raw_pmol, last_pmol)
pqhBreak     = f_with_cooldown(raw_pqh,  last_pqh)
pqlBreak     = f_with_cooldown(raw_pql,  last_pql)
pyhBreak     = f_with_cooldown(raw_pyh,  last_pyh)
pylBreak     = f_with_cooldown(raw_pyl,  last_pyl)
athBreak     = f_with_cooldown(raw_ath,  last_ath)
atlBreak     = f_with_cooldown(raw_atl,  last_atl)

// Update last-fired bars
if orhBreak
    last_orh  := bar_index
if orlBreak
    last_orl  := bar_index
if pmhBreak
    last_pmh  := bar_index
if pmlBreak
    last_pml  := bar_index
if cdoBreak
    last_cdo  := bar_index
if cdoBrk
    last_cdoB := bar_index
if pdoBreak
    last_pdo  := bar_index
if pdoBrk
    last_pdoB := bar_index
if pdhBreak
    last_pdh  := bar_index
if pdlBreak
    last_pdl  := bar_index
if pwhBreak
    last_pwh  := bar_index
if pwlBreak
    last_pwl  := bar_index
if pmhPrevBreak
    last_pmoh := bar_index
if pmlPrevBreak
    last_pmol := bar_index
if pqhBreak
    last_pqh  := bar_index
if pqlBreak
    last_pql  := bar_index
if pyhBreak
    last_pyh  := bar_index
if pylBreak
    last_pyl  := bar_index
if athBreak
    last_ath  := bar_index
if atlBreak
    last_atl  := bar_index

anyBullBreak  = orhBreak or pmhBreak or cdoBreak or pdoBreak or pdhBreak or pwhBreak or pmhPrevBreak or pqhBreak or pyhBreak or athBreak
anyBearBreak  = orlBreak or pmlBreak or cdoBrk   or pdoBrk   or pdlBreak or pwlBreak or pmlPrevBreak or pqlBreak or pylBreak or atlBreak
anyLevelBreak = anyBullBreak or anyBearBreak

plotshape(showBreakMarks and anyBullBreak, title="Bullish Break", style=shape.triangleup,   location=location.belowbar, color=color.new(#00E676, 0), size=size.tiny, text="BREAK")
plotshape(showBreakMarks and anyBearBreak, title="Bearish Break", style=shape.triangledown, location=location.abovebar, color=color.new(#FF5252, 0), size=size.tiny, text="BREAK")

// ==========================================
// 11. ALERT CONDITIONS
// ==========================================

alertcondition(orhBreak,     title="ORH Breakout",                   message="{{ticker}} broke above ORH @ {{close}}")
alertcondition(orlBreak,     title="ORL Breakdown",                  message="{{ticker}} broke below ORL @ {{close}}")
alertcondition(pmhBreak,     title="PMH Breakout",                   message="{{ticker}} broke above Premarket High @ {{close}}")
alertcondition(pmlBreak,     title="PML Breakdown",                  message="{{ticker}} broke below Premarket Low @ {{close}}")
alertcondition(cdoBreak,     title="Current Day Open Breakout",      message="{{ticker}} broke above Current Day Open @ {{close}}")
alertcondition(cdoBrk,       title="Current Day Open Breakdown",     message="{{ticker}} broke below Current Day Open @ {{close}}")
alertcondition(pdoBreak,     title="Prev Day Open Breakout",         message="{{ticker}} broke above Previous Day Open @ {{close}}")
alertcondition(pdoBrk,       title="Prev Day Open Breakdown",        message="{{ticker}} broke below Previous Day Open @ {{close}}")
alertcondition(pdhBreak,     title="PDH Breakout",                   message="{{ticker}} broke above Previous Day High @ {{close}}")
alertcondition(pdlBreak,     title="PDL Breakdown",                  message="{{ticker}} broke below Previous Day Low @ {{close}}")
alertcondition(pwhBreak,     title="PWH Breakout",                   message="{{ticker}} broke above Previous Week High @ {{close}}")
alertcondition(pwlBreak,     title="PWL Breakdown",                  message="{{ticker}} broke below Previous Week Low @ {{close}}")
alertcondition(pmhPrevBreak, title="Previous Month High Breakout",   message="{{ticker}} broke above Previous Month High @ {{close}}")
alertcondition(pmlPrevBreak, title="Previous Month Low Breakdown",   message="{{ticker}} broke below Previous Month Low @ {{close}}")
alertcondition(pqhBreak,     title="Previous Quarter High Breakout", message="{{ticker}} broke above Previous Quarter High @ {{close}}")
alertcondition(pqlBreak,     title="Previous Quarter Low Breakdown", message="{{ticker}} broke below Previous Quarter Low @ {{close}}")
alertcondition(pyhBreak,     title="Previous Year High Breakout",    message="{{ticker}} broke above Previous Year High @ {{close}}")
alertcondition(pylBreak,     title="Previous Year Low Breakdown",    message="{{ticker}} broke below Previous Year Low @ {{close}}")
alertcondition(athBreak,     title="All-Time High Breakout",         message="{{ticker}} broke above All-Time High @ {{close}}")
alertcondition(atlBreak,     title="All-Time Low Breakdown",         message="{{ticker}} broke below All-Time Low @ {{close}}")
alertcondition(anyBullBreak, title="Any Bullish Level Break",        message="{{ticker}} broke above a key level @ {{close}}")
alertcondition(anyBearBreak, title="Any Bearish Level Break",        message="{{ticker}} broke below a key level @ {{close}}")
alertcondition(anyLevelBreak,title="Any Key Level Break",            message="{{ticker}} broke a key level @ {{close}}")
````
