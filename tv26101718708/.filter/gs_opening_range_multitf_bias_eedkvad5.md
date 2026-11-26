# GS Opening Range & Multi-TF Bias

- url: https://www.tradingview.com/script/eeDKvaD5-GS-Opening-Range-Multi-TF-Bias/
- type: indicator
- pine_id: PUB;2596d9b5b5e746e09bf25382379b585c
- version: 1.0

## Description

A simple orb with breakout signals bull and bear stack Ema Signals Weekly , previous week , daily High and Lows as Targets. Dash board with macd values and daily bias .

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © murkomusic13

//@version=6
indicator("GS Opening Range & Multi-TF Bias", shorttitle="GS ORB W LEVELS", overlay=true)

// --- Constants ---
const string GRP_OR   = "Opening Range Settings"
const string GRP_DISP = "Display Settings"
const string GRP_MACD = "MACD Settings"
const string GRP_EMA  = "EMA Settings"
const string GRP_STYL = "Style Settings"
const string GRP_DASH = "Dashboard Settings"
const string GRP_WEEK = "Weekly Levels"
const string GRP_DAY  = "Daily Levels"

// --- Inputs ---
useSession         = input.bool(true,  "Use Regular Trading Hours (RTH)",  group=GRP_OR)
rthSession         = input.session("0930-1600", "RTH Session String",     group=GRP_OR)
pmSession          = input.session("0400-0930", "Premarket Session String", group=GRP_OR)
rangeMinutes       = input.int(60,     "Opening Range Minutes",            group=GRP_OR, minval=1)

showRange          = input.bool(true,  "Show OR High/Low",                 group=GRP_DISP)
showMid            = input.bool(true,  "Show OR Midline",                  group=GRP_DISP)
showPriceLabels    = input.bool(true,  "Show Price Labels on Levels",      group=GRP_DISP)
showSignalLabels   = input.bool(true,  "Show Breakout Signal Labels",      group=GRP_DISP)
showStackLabels    = input.bool(true,  "Show EMA Stack Signal Labels",     group=GRP_DISP)
showPremarket      = input.bool(true,  "Show Premarket High/Low Targets",  group=GRP_DISP)
showDashboard      = input.bool(true,  "Show Bias Dashboard",              group=GRP_DISP)

fastLen            = input.int(12,     "MACD Fast Length",                 group=GRP_MACD)
slowLen            = input.int(26,     "MACD Slow Length",                 group=GRP_MACD)
sigLen             = input.int(9,      "MACD Signal Length",               group=GRP_MACD)
macdFilter         = input.bool(true,  "Require MACD Confluence",          group=GRP_MACD)
showMacdDash       = input.bool(true,  "Show MACD Values in Dashboard",    group=GRP_MACD)

showEma9           = input.bool(true,  "Show 9 EMA",                       group=GRP_EMA)
showEma20          = input.bool(true,  "Show 20 EMA",                      group=GRP_EMA)
showEma50          = input.bool(true,  "Show 50 EMA",                      group=GRP_EMA)
showEma200         = input.bool(true,  "Show 200 EMA",                     group=GRP_EMA)
showEma250         = input.bool(true,  "Show 250 EMA",                     group=GRP_EMA)
ema9Color          = input.color(#00bcd4, "9 EMA Color",                   group=GRP_EMA)
ema20Color         = input.color(#ff9800, "20 EMA Color",                  group=GRP_EMA)
ema50Color         = input.color(#9c27b0, "50 EMA Color",                  group=GRP_EMA)
ema200Color        = input.color(#f44336, "200 EMA Color",                 group=GRP_EMA)
ema250Color        = input.color(#607d8b, "250 EMA Color",                 group=GRP_EMA)

bullColor          = input.color(#089981, "Bullish Color",                 group=GRP_STYL)
bearColor          = input.color(#f23645, "Bearish Color",                 group=GRP_STYL)
neutralColor       = input.color(#5b9cf6, "Neutral/Mid Color",             group=GRP_STYL)
pmColorHigh        = input.color(#ff9800, "Premarket High Color",          group=GRP_STYL)
pmColorLow         = input.color(#e91e63, "Premarket Low Color",           group=GRP_STYL)
dashBgColor        = input.color(color.new(#1e222d, 10), "Dashboard BG",   group=GRP_STYL)
macdGreenColor     = input.color(#00e676, "All-MACD-Positive Candle Color", group=GRP_STYL)

dashPos            = input.string("top_right", "Dashboard Position",       group=GRP_DASH, options=["top_right", "bottom_right", "top_left", "bottom_left"])
dashSize           = input.string("small",     "Dashboard Size",           group=GRP_DASH, options=["tiny", "small", "normal"])

showWeekly         = input.bool(true,  "Show Current Week High/Low",       group=GRP_WEEK)
showPrevWeek       = input.bool(true,  "Show Previous Week High/Low",      group=GRP_WEEK)
wkHighColor        = input.color(#26c6da, "Week High Color",               group=GRP_WEEK)
wkLowColor         = input.color(#ef5350, "Week Low Color",                group=GRP_WEEK)
pwkHighColor       = input.color(color.new(#26c6da, 50), "Prev Week High Color", group=GRP_WEEK)
pwkLowColor        = input.color(color.new(#ef5350, 50), "Prev Week Low Color",  group=GRP_WEEK)

showDaily          = input.bool(true,  "Show Current Day High/Low",        group=GRP_DAY)
showPrevDay        = input.bool(true,  "Show Previous Day High/Low",       group=GRP_DAY)
dHighColor         = input.color(#66bb6a, "Day High Color",                group=GRP_DAY)
dLowColor          = input.color(#ff7043, "Day Low Color",                 group=GRP_DAY)
pdHighColor        = input.color(color.new(#66bb6a, 55), "Prev Day High Color", group=GRP_DAY)
pdLowColor         = input.color(color.new(#ff7043, 55), "Prev Day Low Color",  group=GRP_DAY)

// --- Logic: Session & Range ---
isRTH              = not na(time(timeframe.period, rthSession))
isPremarket        = not na(time(timeframe.period, pmSession))
newDay             = ta.change(time("D")) != 0
rthStarted         = isRTH and not isRTH[1]

// Premarket Levels
var float pmHigh = na, var float pmLow = na
var float pmHighFrozen = na, var float pmLowFrozen = na

if newDay
    pmHigh := na, pmLow := na
    pmHighFrozen := na, pmLowFrozen := na

if isPremarket
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow,  low)

if rthStarted
    pmHighFrozen := pmHigh
    pmLowFrozen  := pmLow

// Opening Range
barSeconds   = timeframe.in_seconds()
maxRangeBars = math.max(1, math.floor((rangeMinutes * 60) / barSeconds))
var float orH = na, var float orL = na
var int orStart = na

if rthStarted
    orH := high, orL := low, orStart := bar_index
else if isRTH and not na(orStart) and (bar_index - orStart) < maxRangeBars
    orH := math.max(orH, high), orL := math.min(orL, low)

orM = (orH + orL) / 2

// --- Weekly Levels ---
isNewWeek = ta.change(time("W")) != 0

var float curWeekH = na
var float curWeekL = na
var float pwkH     = na
var float pwkL     = na

if isNewWeek
    pwkH      := curWeekH
    pwkL      := curWeekL
    curWeekH  := high
    curWeekL  := low
else
    curWeekH  := na(curWeekH) ? high : math.max(curWeekH, high)
    curWeekL  := na(curWeekL) ? low  : math.min(curWeekL, low)

// --- Daily Levels ---
var float curDayH = na
var float curDayL = na
var float pdH     = na
var float pdL     = na

if newDay
    pdH      := curDayH
    pdL      := curDayL
    curDayH  := high
    curDayL  := low
else
    curDayH  := na(curDayH) ? high : math.max(curDayH, high)
    curDayL  := na(curDayL) ? low  : math.min(curDayL, low)

// --- Indicators (Current TF) ---
[mLine, sLine, mHist] = ta.macd(close, fastLen, slowLen, sigLen)
mBull = mLine > sLine

// All MACD positive: MACD line > 0, Signal line > 0, Histogram > 0
allMacdPositive = mLine > 0 and sLine > 0 and mHist > 0

// --- EMAs ---
ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
ema250 = ta.ema(close, 250)

// --- EMA Stack Logic ---
// Bull Stack: all EMAs in ascending order (fastest above slowest)
bullStack = ema9 > ema20 and ema20 > ema50 and ema50 > ema200 and ema200 > ema250
// Bear Stack: all EMAs in descending order (fastest below slowest)
bearStack = ema9 < ema20 and ema20 < ema50 and ema50 < ema200 and ema200 < ema250

// Fire signal only on the bar the stack first forms
bullStackSignal = bullStack and not bullStack[1]
bearStackSignal = bearStack and not bearStack[1]

// --- Multi-TF Data (Daily) ---
[dMacd, dSig, _] = request.security(syminfo.tickerid, "D", ta.macd(close, fastLen, slowLen, sigLen))
dEma   = request.security(syminfo.tickerid, "D", ta.ema(close, 20))
dClose = request.security(syminfo.tickerid, "D", close)

dMacdBull = dMacd > dSig
dTrendUp  = dClose > dEma
dailyBias = dMacdBull and dTrendUp ? "Strong Bull" : not dMacdBull and not dTrendUp ? "Strong Bear" : "Neutral"
dailyCol  = dailyBias == "Strong Bull" ? bullColor : dailyBias == "Strong Bear" ? bearColor : neutralColor

// --- Signals & Alerts ---
orH_Cross = ta.crossover(close, orH)
orL_Cross = ta.crossunder(close, orL)
pmH_Cross = ta.crossover(close, pmHighFrozen)
pmL_Cross = ta.crossunder(close, pmLowFrozen)

postOR    = isRTH and not na(orStart) and (bar_index - orStart) >= maxRangeBars
longSig   = postOR and orH_Cross and (not macdFilter or mBull)
shortSig  = postOR and orL_Cross and (not macdFilter or not mBull)

// --- Candle Coloring: Bright Green when all MACD values positive ---
barcolor(allMacdPositive ? macdGreenColor : na, title="All MACD Positive Candle")

// --- Visuals: Plots & Fills ---
plotORH = plot(showRange ? orH : na, "OR High", color.new(bearColor, 40), 2, plot.style_linebr)
plotORL = plot(showRange ? orL : na, "OR Low",  color.new(bullColor, 40), 2, plot.style_linebr)
fill(plotORH, plotORL, orH, orL, color.new(bearColor, 90), color.new(bullColor, 90), "OR Zone")

plot(showMid      ? orM          : na, "OR Mid",        color.new(neutralColor, 60), 1, plot.style_linebr)
plot(showPremarket ? pmHighFrozen : na, "PM High",       pmColorHigh,                 1, plot.style_linebr)
plot(showPremarket ? pmLowFrozen  : na, "PM Low",        pmColorLow,                  1, plot.style_linebr)

// --- Weekly Level Plots ---
plot(showWeekly   ? curWeekH : na, "Week High",       wkHighColor,  1, plot.style_linebr)
plot(showWeekly   ? curWeekL : na, "Week Low",        wkLowColor,   1, plot.style_linebr)
plot(showPrevWeek ? pwkH     : na, "Prev Week High",  pwkHighColor, 1, plot.style_linebr)
plot(showPrevWeek ? pwkL     : na, "Prev Week Low",   pwkLowColor,  1, plot.style_linebr)

// --- Daily Level Plots ---
plot(showDaily   ? curDayH : na, "Day High",       dHighColor,  1, plot.style_linebr)
plot(showDaily   ? curDayL : na, "Day Low",        dLowColor,   1, plot.style_linebr)
plot(showPrevDay ? pdH     : na, "Prev Day High",  pdHighColor, 1, plot.style_linebr)
plot(showPrevDay ? pdL     : na, "Prev Day Low",   pdLowColor,  1, plot.style_linebr)

// --- EMA Plots ---
plot(showEma9   ? ema9   : na, "9 EMA",   ema9Color,   1, plot.style_line)
plot(showEma20  ? ema20  : na, "20 EMA",  ema20Color,  1, plot.style_line)
plot(showEma50  ? ema50  : na, "50 EMA",  ema50Color,  1, plot.style_line)
plot(showEma200 ? ema200 : na, "200 EMA", ema200Color, 2, plot.style_line)
plot(showEma250 ? ema250 : na, "250 EMA", ema250Color, 2, plot.style_line)

// --- OR Breakout Signal Labels ---
if showSignalLabels
    if longSig
        label.new(bar_index, low,  "LONG",  color=bullColor, textcolor=color.white, style=label.style_label_up,   size=size.small, yloc=yloc.belowbar)
    if shortSig
        label.new(bar_index, high, "SHORT", color=bearColor, textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

// --- EMA Stack Signal Labels ---
if showStackLabels
    if bullStackSignal
        label.new(bar_index, low,  "BULL\nSTACK", color=bullColor, textcolor=color.white, style=label.style_label_up,   size=size.small, yloc=yloc.belowbar)
    if bearStackSignal
        label.new(bar_index, high, "BEAR\nSTACK", color=bearColor, textcolor=color.white, style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

// --- Price Labels at Last Bar ---
var label lblH    = label.new(na, na, "", color=#00000000, textcolor=bearColor,    style=label.style_label_left, size=size.small)
var label lblL    = label.new(na, na, "", color=#00000000, textcolor=bullColor,    style=label.style_label_left, size=size.small)
var label lblM    = label.new(na, na, "", color=#00000000, textcolor=neutralColor, style=label.style_label_left, size=size.small)
var label lblPMH  = label.new(na, na, "", color=#00000000, textcolor=pmColorHigh,  style=label.style_label_left, size=size.small)
var label lblPML  = label.new(na, na, "", color=#00000000, textcolor=pmColorLow,   style=label.style_label_left, size=size.small)
var label lblWKH  = label.new(na, na, "", color=#00000000, textcolor=wkHighColor,  style=label.style_label_left, size=size.small)
var label lblWKL  = label.new(na, na, "", color=#00000000, textcolor=wkLowColor,   style=label.style_label_left, size=size.small)
var label lblPWKH = label.new(na, na, "", color=#00000000, textcolor=pwkHighColor, style=label.style_label_left, size=size.small)
var label lblPWKL = label.new(na, na, "", color=#00000000, textcolor=pwkLowColor,  style=label.style_label_left, size=size.small)
var label lblDH   = label.new(na, na, "", color=#00000000, textcolor=dHighColor,   style=label.style_label_left, size=size.small)
var label lblDL   = label.new(na, na, "", color=#00000000, textcolor=dLowColor,    style=label.style_label_left, size=size.small)
var label lblPDH  = label.new(na, na, "", color=#00000000, textcolor=pdHighColor,  style=label.style_label_left, size=size.small)
var label lblPDL  = label.new(na, na, "", color=#00000000, textcolor=pdLowColor,   style=label.style_label_left, size=size.small)

if barstate.islast and showPriceLabels
    // OR High label
    if not na(orH)
        label.set_xy(lblH, bar_index + 1, orH)
        label.set_text(lblH, "ORH: " + str.tostring(orH, format.mintick))
    else
        label.set_xy(lblH, na, na)

    // OR Low label
    if not na(orL)
        label.set_xy(lblL, bar_index + 1, orL)
        label.set_text(lblL, "ORL: " + str.tostring(orL, format.mintick))
    else
        label.set_xy(lblL, na, na)

    // OR Mid label
    if not na(orM)
        label.set_xy(lblM, bar_index + 1, orM)
        label.set_text(lblM, "ORM: " + str.tostring(orM, format.mintick))
    else
        label.set_xy(lblM, na, na)

    // Premarket High label
    if not na(pmHighFrozen) and showPremarket
        label.set_xy(lblPMH, bar_index + 1, pmHighFrozen)
        label.set_text(lblPMH, "PMH: " + str.tostring(pmHighFrozen, format.mintick))
    else
        label.set_xy(lblPMH, na, na)

    // Premarket Low label
    if not na(pmLowFrozen) and showPremarket
        label.set_xy(lblPML, bar_index + 1, pmLowFrozen)
        label.set_text(lblPML, "PML: " + str.tostring(pmLowFrozen, format.mintick))
    else
        label.set_xy(lblPML, na, na)

    // Weekly High label
    if not na(curWeekH) and showWeekly
        label.set_xy(lblWKH, bar_index + 1, curWeekH)
        label.set_text(lblWKH, "WKH: " + str.tostring(curWeekH, format.mintick))
    else
        label.set_xy(lblWKH, na, na)

    // Weekly Low label
    if not na(curWeekL) and showWeekly
        label.set_xy(lblWKL, bar_index + 1, curWeekL)
        label.set_text(lblWKL, "WKL: " + str.tostring(curWeekL, format.mintick))
    else
        label.set_xy(lblWKL, na, na)

    // Prev Week High label
    if not na(pwkH) and showPrevWeek
        label.set_xy(lblPWKH, bar_index + 1, pwkH)
        label.set_text(lblPWKH, "PWH: " + str.tostring(pwkH, format.mintick))
    else
        label.set_xy(lblPWKH, na, na)

    // Prev Week Low label
    if not na(pwkL) and showPrevWeek
        label.set_xy(lblPWKL, bar_index + 1, pwkL)
        label.set_text(lblPWKL, "PWL: " + str.tostring(pwkL, format.mintick))
    else
        label.set_xy(lblPWKL, na, na)

    // Day High label
    if not na(curDayH) and showDaily
        label.set_xy(lblDH, bar_index + 1, curDayH)
        label.set_text(lblDH, "DH: " + str.tostring(curDayH, format.mintick))
    else
        label.set_xy(lblDH, na, na)

    // Day Low label
    if not na(curDayL) and showDaily
        label.set_xy(lblDL, bar_index + 1, curDayL)
        label.set_text(lblDL, "DL: " + str.tostring(curDayL, format.mintick))
    else
        label.set_xy(lblDL, na, na)

    // Prev Day High label
    if not na(pdH) and showPrevDay
        label.set_xy(lblPDH, bar_index + 1, pdH)
        label.set_text(lblPDH, "PDH: " + str.tostring(pdH, format.mintick))
    else
        label.set_xy(lblPDH, na, na)

    // Prev Day Low label
    if not na(pdL) and showPrevDay
        label.set_xy(lblPDL, bar_index + 1, pdL)
        label.set_text(lblPDL, "PDL: " + str.tostring(pdL, format.mintick))
    else
        label.set_xy(lblPDL, na, na)

// --- Dashboard ---
// 13 rows: header + Pos + Bias + 1D Bias + Stack + MACD(4) + Wk High + Wk Low + PW High + PW Low
getPos(pos) =>
    switch pos
        "top_right"    => position.top_right
        "bottom_right" => position.bottom_right
        "top_left"     => position.top_left
        "bottom_left"  => position.bottom_left
        => position.top_right

var table dash = table.new(getPos(dashPos), 2, 13, bgcolor=dashBgColor, border_color=chart.fg_color, border_width=1)

if barstate.islast and showDashboard
    currPos  = close > orH ? "Above" : close < orL ? "Below" : "Inside"
    currBias = (close > orM and mBull) ? "Bull" : (close < orM and not mBull) ? "Bear" : "Neut"
    currCol  = currBias == "Bull" ? bullColor : currBias == "Bear" ? bearColor : neutralColor

    stackStr = bullStack ? "Bull Stack" : bearStack ? "Bear Stack" : "None"
    stackCol = bullStack ? bullColor    : bearStack ? bearColor    : neutralColor

    // Row 0: Header
    table.cell(dash, 0, 0, "Bias Dashboard", text_color=chart.fg_color, text_size=dashSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Row 1: Position
    table.cell(dash, 0, 1, "Pos",    text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, currPos,  text_color=currCol,        text_size=dashSize, text_halign=text.align_right)

    // Row 2: Intraday Bias
    table.cell(dash, 0, 2, "Bias",   text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, currBias, text_color=currCol,        text_size=dashSize, text_halign=text.align_right)

    // Row 3: Daily Bias
    table.cell(dash, 0, 3, "1D Bias",  text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, dailyBias,  text_color=dailyCol,        text_size=dashSize, text_halign=text.align_right)

    // Row 4: EMA Stack
    table.cell(dash, 0, 4, "Stack",   text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, stackStr,  text_color=stackCol,        text_size=dashSize, text_halign=text.align_right)

    // Rows 5–8: MACD Values (only if enabled)
    if showMacdDash
        macdLineCol = mLine > 0 ? bullColor : bearColor
        macdSigCol  = sLine > 0 ? bullColor : bearColor
        macdHistCol = mHist > 0 ? bullColor : bearColor
        allPosCol   = allMacdPositive ? macdGreenColor : bearColor
        allPosStr   = allMacdPositive ? "YES ✓" : "NO"

        table.cell(dash, 0, 5, "MACD",   text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, 5, str.tostring(mLine, "#.##"), text_color=macdLineCol, text_size=dashSize, text_halign=text.align_right)

        table.cell(dash, 0, 6, "Signal", text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, 6, str.tostring(sLine, "#.##"), text_color=macdSigCol,  text_size=dashSize, text_halign=text.align_right)

        table.cell(dash, 0, 7, "Hist",   text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, 7, str.tostring(mHist, "#.##"), text_color=macdHistCol, text_size=dashSize, text_halign=text.align_right)

        table.cell(dash, 0, 8, "All+",   text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
        table.cell(dash, 1, 8, allPosStr, text_color=allPosCol,     text_size=dashSize, text_halign=text.align_right)

    // Rows 9–12: Weekly Levels
    wkHStr  = not na(curWeekH) ? str.tostring(curWeekH, format.mintick) : "—"
    wkLStr  = not na(curWeekL) ? str.tostring(curWeekL, format.mintick) : "—"
    pwkHStr = not na(pwkH)     ? str.tostring(pwkH,     format.mintick) : "—"
    pwkLStr = not na(pwkL)     ? str.tostring(pwkL,     format.mintick) : "—"

    table.cell(dash, 0, 9,  "Wk High", text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 9,  wkHStr,    text_color=wkHighColor,    text_size=dashSize, text_halign=text.align_right)

    table.cell(dash, 0, 10, "Wk Low",  text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 10, wkLStr,    text_color=wkLowColor,     text_size=dashSize, text_halign=text.align_right)

    table.cell(dash, 0, 11, "PW High", text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 11, pwkHStr,   text_color=pwkHighColor,   text_size=dashSize, text_halign=text.align_right)

    table.cell(dash, 0, 12, "PW Low",  text_color=chart.fg_color, text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 12, pwkLStr,   text_color=pwkLowColor,    text_size=dashSize, text_halign=text.align_right)

// --- Alerts ---
alertcondition(longSig,         "OR Long Breakout")
alertcondition(shortSig,        "OR Short Breakout")
alertcondition(pmH_Cross,       "PM High Hit")
alertcondition(pmL_Cross,       "PM Low Hit")
alertcondition(allMacdPositive and not allMacdPositive[1], "All MACD Values Turned Positive")
alertcondition(bullStackSignal, "Bull EMA Stack Formed")
alertcondition(bearStackSignal, "Bear EMA Stack Formed")
````
