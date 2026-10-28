# PC + FVG

- url: https://www.tradingview.com/script/0StmDlv1-PC-FVG/
- type: indicator
- pine_id: PUB;dd201e24e68d471dbfeadc754a3b80fe
- version: 10.0

## Description

the indicator detect PC in the 15min timeline graph. then shows windows of 15 candles in the 1min timeline graph. limit stop tp. only if there are FVGs in the wick of the PC. all based on the side of TDO.

## Source Code

````pine
//@version=5
indicator("PC + FVG", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ==========================================
// --- GLOBAL / SHARED INPUTS ---
// ==========================================
s_nq_sym = input.symbol("CME_MINI:MNQ1!", "PC: Index 1 (NQ)")
s_es_sym = input.symbol("CME_MINI:MES1!", "PC: Index 2 (ES)")

// ==========================================
// --- PC VISIBILITY INPUTS ---
// ==========================================
showNormalPC      = input.bool(true, "Enable 15m Normal PC", group="PC Visibility")
showOppositePC    = input.bool(true, "Enable 15m Opposite PC", group="PC Visibility")
showNormalPC_1h   = input.bool(true, "Enable 1h Normal PC", group="PC Visibility")
showOppositePC_1h = input.bool(true, "Enable 1h Opposite PC", group="PC Visibility")
showNormalPC_4h   = input.bool(true, "Enable 4h Normal PC", group="PC Visibility")
showOppositePC_4h = input.bool(true, "Enable 4h Opposite PC", group="PC Visibility")
showPC_1d         = input.bool(true, "Enable 1D PC", group="PC Visibility")
showPC_1w         = input.bool(true, "Enable 1W PC", group="PC Visibility")
enableAlerts      = input.bool(true, "Enable Standard PC Alerts", group="PC Alerts")

// ==========================================
// --- PC STYLES (Unified) ---
// ==========================================
color_standard    = input.color(color.black, "Standard PC Color", group="PC Styles")
pc_text_color     = input.color(color.white, "PC Text Color", group="PC Styles")
color_opposite    = input.color(color.blue, "Opposite PC Color", group="PC Styles")
pc_opp_text_color = input.color(color.white, "Opposite PC Text Color", group="PC Styles")
color_1d_pc       = input.color(color.orange, "Daily PC Color", group="PC Styles")
color_1w_pc       = input.color(color.purple, "Weekly PC Color", group="PC Styles")

// ==========================================
// --- TDO STYLES ---
// ==========================================
tdo_text_color    = input.color(color.black, "TDO Text Color", group="TDO Styles")
tdo_color         = input.color(color.gray, "TDO Line Color", group="TDO Styles")
tdo_session_input = input.string("0700-0701", "TDO Session (HHMM-HHMM)", group="TDO Styles")

// ==========================================
// --- TWO STYLES ---
// ==========================================
two_session_input = input.string("0100-0101", "TWO Session (HHMM-HHMM)", group="TWO Styles")
two_text_color    = input.color(color.black, "TWO Text Color", group="TWO Styles")
two_color         = input.color(color.gray, "TWO Line Color", group="TWO Styles")

// ==========================================
// ─── FVG SECTION INPUTS ───
// ==========================================
bullColor      = input.color(color.new(#00ff68, 70), "Bullish FVG Color", group="FVG Styles")
bearColor      = input.color(color.new(#ff0008, 70), "Bearish FVG Color", group="FVG Styles")
ifvgColor      = input.color(color.new(#ff0008, 70), "IFVG Color (Bull→Bear)", group="FVG Styles")
ifvgBullColor  = input.color(color.new(#00ff68, 70), "IFVG Color (Bear→Bull)")
poiColor       = input.color(color.new(#0088ff, 70), "POI Color", group="FVG Styles")
lookback       = input.int(500, "Lookback (bars)", minval = 10, maxval = 5000, group="FVG Logic")
extendBars     = input.int(10,  "Extend Bars",     minval = 1,  maxval = 500, group="FVG Logic")

useHTF1m       = input.bool(false, "Enable 1m HTF Mode", group="HTF Logic")
htfMinutes1m   = input.int(15, "1m HTF Window (Minutes)", minval = 1, group="HTF Logic")

useHTF5m       = input.bool(false, "Enable 5m HTF Mode", group="HTF Logic")
htfMinutes5m   = input.int(60, "5m HTF Window (Minutes)", minval = 1, group="HTF Logic")

useHTF15m      = input.bool(false, "Enable 15m HTF Mode (16 Candles)", group="HTF Logic")

showDivider    = input.bool(true, "Show Window Divider", group="HTF Window Visualization")
midLineColor   = input.color(color.new(color.gray, 50), "Open Price Line Color", group="HTF Window Visualization")
upSideColor    = input.color(color.new(#00ff68, 95), "Up Side Fill (Top)", group="HTF Window Visualization")
downSideColor  = input.color(color.new(#ff0008, 95), "Down Side Fill (Bottom)", group="HTF Window Visualization")

// --- Timeframe Checks ---
is60m = timeframe.period == "60"
is15m = timeframe.period == "15"
is5m  = timeframe.period == "5"
is1m  = timeframe.period == "1"
is4h  = timeframe.period == "240"
is1d  = timeframe.isdaily
is1w  = timeframe.isweekly

// ==========================================
// --- SECURITY DATA FETCHING ---
// ==========================================
[o_nq_15, c_nq_15] = request.security(s_nq_sym, "15", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[o_es_15, c_es_15] = request.security(s_es_sym, "15", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[o_nq_1h, c_nq_1h] = request.security(s_nq_sym, "60", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[o_es_1h, c_es_1h] = request.security(s_es_sym, "60", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[o_nq_4h, h_nq_4h, l_nq_4h, c_nq_4h] = request.security(s_nq_sym, "240", [open, high, low, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[o_es_4h, c_es_4h] = request.security(s_es_sym, "240", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[o_nq_1d, c_nq_1d] = request.security(s_nq_sym, "1D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[o_es_1d, c_es_1d] = request.security(s_es_sym, "1D", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[o_nq_1w, c_nq_1w] = request.security(s_nq_sym, "1W", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[o_es_1w, c_es_1w] = request.security(s_es_sym, "1W", [open, close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[o_nq, c_nq] = request.security(s_nq_sym, timeframe.period, [open, close], gaps=barmerge.gaps_off)
[o_es, c_es] = request.security(s_es_sym, timeframe.period, [open, close], gaps=barmerge.gaps_off)

// ==========================================
// --- TDO LOGIC ---
// ==========================================
t_isLondonOpen = time(timeframe.period, tdo_session_input, "GMT+3")

var float tdo = na
var line tdo_line = na
var label tdo_price_label = na

if not is1w
    if not na(t_isLondonOpen)
        tdo := o_nq
        tdo_line := line.new(bar_index, tdo, bar_index, tdo, color=tdo_color, width=1, style=line.style_solid)
        tdo_price_label := label.new(bar_index, tdo, text="TDO: " + str.tostring(tdo), color=color.new(color.white, 100), textcolor=tdo_text_color, style=label.style_label_left, size=size.small)

    if not na(tdo_line) and na(t_isLondonOpen)
        line.set_x2(tdo_line, bar_index)
        label.set_x(tdo_price_label, bar_index)

// ==========================================
// --- TWO LOGIC ---
// ==========================================
t_isTuesdayTime  = time(timeframe.period, two_session_input + ":3", "GMT+3")
t_isTuesdayDaily = is1d and dayofweek(time, "GMT+3") == dayofweek.tuesday and dayofweek(time[1], "GMT+3") != dayofweek.tuesday

var float two = na
var line two_line = na
var label two_price_label = na

if (is15m or is4h or is1d)
    if not na(t_isTuesdayTime) or t_isTuesdayDaily
        two := open
        if (is4h or is1d)
            two_line := line.new(bar_index, two, bar_index, two, color=two_color, width=1, style=line.style_solid)
            two_price_label := label.new(bar_index, two, text="TWO: " + str.tostring(two), color=color.new(color.white, 100), textcolor=two_text_color, style=label.style_label_left, size=size.small)

    if not na(two_line) and (na(t_isTuesdayTime) and not t_isTuesdayDaily)
        line.set_x2(two_line, bar_index)
        label.set_x(two_price_label, bar_index)

// ==========================================
// --- PC LOGIC & ALERTS ---
// ==========================================
// 1. GLOBAL CALCULATIONS (Calculated here so they are visible to both Labels and Alerts)
isDiv15 = (c_nq_15 > o_nq_15 and c_es_15 <= o_es_15) or (c_nq_15 < o_nq_15 and c_es_15 >= o_es_15)
isNormalPC15 = isDiv15 and not na(tdo) and ((c_nq_15 < o_nq_15 and o_nq_15 > tdo) or (c_nq_15 > o_nq_15 and o_nq_15 < tdo))
isOppositePC15 = isDiv15 and not na(tdo) and ((c_nq_15 > o_nq_15 and o_nq_15 > tdo) or (c_nq_15 < o_nq_15 and o_nq_15 < tdo))

isDiv1h = (c_nq_1h > o_nq_1h and c_es_1h <= o_es_1h) or (c_nq_1h < o_nq_1h and c_es_1h >= o_es_1h)
isNormalPC1h = isDiv1h and not na(tdo) and ((c_nq_1h < o_nq_1h and o_nq_1h > tdo) or (c_nq_1h > o_nq_1h and o_nq_1h < tdo))
isOppositePC1h = isDiv1h and not na(tdo) and ((c_nq_1h > o_nq_1h and o_nq_1h > tdo) or (c_nq_1h < o_nq_1h and o_nq_1h < tdo))

mid_nq_4h = (h_nq_4h + l_nq_4h) / 2
isDiv4h = (c_nq_4h > o_nq_4h and c_es_4h <= o_es_4h) or (c_nq_4h < o_nq_4h and c_es_4h >= o_es_4h)
isNormalPC4h = isDiv4h and not na(two) and ((c_nq_4h < o_nq_4h and mid_nq_4h > two) or (c_nq_4h > o_nq_4h and mid_nq_4h < two))
isOppositePC4h = isDiv4h and not na(two) and ((c_nq_4h < o_nq_4h and mid_nq_4h < two) or (c_nq_4h > o_nq_4h and mid_nq_4h > two))

isDiv1d = (c_nq_1d > o_nq_1d and c_es_1d <= o_es_1d) or (c_nq_1d < o_nq_1d and c_es_1d >= o_es_1d)
isDiv1w = (c_nq_1w > o_nq_1w and c_es_1w <= o_es_1w) or (c_nq_1w < o_nq_1w and c_es_1w >= o_es_1w)

// 2. LABEL DRAWING
if is15m
    if showNormalPC and isNormalPC15
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_standard, textcolor=pc_text_color, yloc=yloc.abovebar, size=size.small)
    if showOppositePC and isOppositePC15
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_opposite, textcolor=pc_opp_text_color, yloc=yloc.abovebar, size=size.small)

if is60m
    if showNormalPC_1h and isNormalPC1h
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_standard, textcolor=pc_text_color, yloc=yloc.abovebar, size=size.small)
    if showOppositePC_1h and isOppositePC1h
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_opposite, textcolor=pc_opp_text_color, yloc=yloc.abovebar, size=size.small)

if is4h
    if showNormalPC_4h and isNormalPC4h
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_standard, textcolor=pc_text_color, yloc=yloc.abovebar, size=size.small)
    if showOppositePC_4h and isOppositePC4h
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_opposite, textcolor=pc_opp_text_color, yloc=yloc.abovebar, size=size.small)

if is1d
    if showPC_1d and isDiv1d
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_1d_pc, textcolor=pc_text_color, yloc=yloc.abovebar, size=size.small)

if is1w
    if showPC_1w and isDiv1w
        label.new(bar_index, high, text="PC", style=label.style_label_down, color=color_1w_pc, textcolor=pc_text_color, yloc=yloc.abovebar, size=size.small)

// 3. ALERT LOGIC (Wait for Close, then Check if Label was triggered)
if enableAlerts and barstate.isnew
    bool alertTriggered = false
    string pcType = ""

    // Check which timeframe we are on and if the candle that just closed [1] was a PC
    if is15m
        alertTriggered := isNormalPC15[1] or isOppositePC15[1]
        pcType := isNormalPC15[1] ? "15m Normal PC" : "15m Opposite PC"
    else if is60m
        alertTriggered := isNormalPC1h[1] or isOppositePC1h[1]
        pcType := isNormalPC1h[1] ? "1h Normal PC" : "1h Opposite PC"
    else if is4h
        alertTriggered := isNormalPC4h[1] or isOppositePC4h[1]
        pcType := isNormalPC4h[1] ? "4h Normal PC" : "4h Opposite PC"
    else if is1d
        alertTriggered := isDiv1d[1]
        pcType := "Daily PC"
    else if is1w
        alertTriggered := isDiv1w[1]
        pcType := "Weekly PC"

    // Get the hour of the *closed* candle in UTC+3 timezone
    // We use time[1] because the alert is checking the *previous* (closed) candle
    int closedCandleHourUTC3 = hour(time[1], "GMT+3")

    // Define the alert time window (9:00 to 19:00 UTC+3)
    bool isWithinAlertHours = closedCandleHourUTC3 >= 9 and closedCandleHourUTC3 < 19

    // Trigger the alert only if a PC was detected AND it's within the specified hours
    if alertTriggered and isWithinAlertHours
        string msg = pcType + " Closed on " + timeframe.period + " Chart: " + syminfo.ticker + " at " + str.tostring(close[1])
        alert(msg, alert.freq_once_per_bar)

// ==========================================
// ─── HTF WINDOW LOGIC (1m, 5m, 15m) ───
// ==========================================
m_now = hour * 60 + minute
int htfWindowStartMinutes = na 
currHTFMin = is1m ? htfMinutes1m : (is5m ? htfMinutes5m : (is15m ? 240 : 1))

// Standard logic for 1m and 5m
if is1m or is5m
    htfWindowStartMinutes := int(m_now / currHTFMin) * currHTFMin

// Custom logic for 15m chart: 4h windows starting at 01:00
if is15m
    if m_now >= 1260      // 21:00 - 00:00 (3h / 12 candles)
        htfWindowStartMinutes := 1260
        currHTFMin := 240 
    else if m_now >= 1020 // 17:00 - 21:00 (4h / 16 candles)
        htfWindowStartMinutes := 1020
        currHTFMin := 240
    else if m_now >= 780  // 13:00 - 17:00 (4h / 16 candles)
        htfWindowStartMinutes := 780
        currHTFMin := 240
    else if m_now >= 540  // 09:00 - 13:00 (4h / 16 candles)
        htfWindowStartMinutes := 540
        currHTFMin := 240
    else if m_now >= 300  // 05:00 - 09:00 (4h / 16 candles)
        htfWindowStartMinutes := 300
        currHTFMin := 240
    else if m_now >= 60   // 01:00 - 05:00 (4h / 16 candles)
        htfWindowStartMinutes := 60
        currHTFMin := -1200 // Offset for 21:00 yesterday
    else                  // 00:00 - 01:00 (Gap period)
        htfWindowStartMinutes := 0
        currHTFMin := -1260

var float htfWinOpen = na, var float htfWinHigh = na, var float htfWinLow = na, var int htfWinBar = -1
var float prevWinOpen = na, var float prevWinHigh = na, var float prevWinLow = na
var line midLine = na, var box upBox = na, var box downBox = na

isNewWindow = htfWindowStartMinutes != htfWindowStartMinutes[1]

if is1m or is5m or is15m
    // Only track window data if we aren't in the 00:00-01:00 gap on the 15m
    isActivePeriod = not (is15m and m_now < 60)

    if isNewWindow
        prevWinOpen := htfWinOpen, prevWinHigh := htfWinHigh, prevWinLow := htfWinLow
        if isActivePeriod
            htfWinOpen := open, htfWinBar := bar_index, htfWinHigh := high, htfWinLow := low
            if showDivider
                midLine := line.new(bar_index, na, bar_index, na, color=midLineColor, style=line.style_dashed)
                upBox   := box.new(bar_index, na, bar_index, na, border_color=color.new(color.white, 100), bgcolor=upSideColor)
                downBox := box.new(bar_index, na, bar_index, na, border_color=color.new(color.white, 100), bgcolor=downSideColor)
        else
            htfWinOpen := na, htfWinBar := -1, htfWinHigh := na, htfWinLow := na
    else if htfWinBar != -1
        htfWinHigh := math.max(high, nz(htfWinHigh, high)), htfWinLow := math.min(low, nz(htfWinLow, low))

    if showDivider and not na(midLine) and htfWinBar != -1
        line.set_xy1(midLine, htfWinBar, htfWinOpen), line.set_xy2(midLine, bar_index, htfWinOpen)
        box.set_lefttop(upBox, htfWinBar, htfWinHigh), box.set_rightbottom(upBox, bar_index, htfWinOpen)
        box.set_lefttop(downBox, htfWinBar, htfWinOpen), box.set_rightbottom(downBox, bar_index, htfWinLow)

// ==========================================
// ─── FVG + IFVG LOGIC ───
// ==========================================
bullFVG = (is1m or is5m or is15m) and low  > high[2]
bearFVG = (is1m or is5m or is15m) and high < low[2]

var box[] fvgBoxes = array.new<box>(), var int[] fvgTypes = array.new<int>(), var int[] fvgFlipped = array.new<int>(), var int[] fvgTouched = array.new<int>()
var float[] fvgMidWicks = array.new<float>(), var float[] fvgMids = array.new<float>(), var int[] fvgHTFWindow = array.new<int>()
var float[] fvgPrevWinOpen = array.new<float>(), var float[] fvgPrevWinHigh = array.new<float>(), var float[] fvgPrevWinLow = array.new<float>()
var float[] fvgTwoVal = array.new<float>()
var line[] fvgLimitLines = array.new<line>(), var line[] fvgStopLines = array.new<line>(), var line[] fvgTpLines = array.new<line>()
var label[] fvgLimitLabels = array.new<label>(), var label[] fvgStopLabels = array.new<label>(), var label[] fvgTpLabels = array.new<label>()

if bullFVG
    gapTop = low, gapBot = high[2], limitPrice = (gapTop + gapBot) / 2
    stopPrice = low[1], tpPrice = limitPrice + 3 * (limitPrice - stopPrice)
    lineLeft = bar_index[2], lineRight = bar_index + extendBars
    b = box.new(lineLeft, gapTop, lineRight, gapBot, border_color = bullColor, bgcolor = bullColor)
    lLimit = line.new(lineLeft, limitPrice, lineRight, limitPrice, color = color.black), lblLimit = label.new(lineRight, limitPrice, "LIMIT", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.small)
    lStop = line.new(lineLeft, stopPrice, lineRight, stopPrice, color = color.black, style = line.style_dashed), lblStop = label.new(lineRight, stopPrice, "STOP", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.small)
    lTp = line.new(lineLeft, tpPrice, lineRight, tpPrice, color = color.black, style = line.style_dashed), lblTp = label.new(lineRight, tpPrice, "TP", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.small)
    fvgBoxes.unshift(b), fvgTypes.unshift(1), fvgFlipped.unshift(0), fvgTouched.unshift(0), fvgMidWicks.unshift(high[1]), fvgMids.unshift(limitPrice), fvgHTFWindow.unshift(htfWindowStartMinutes)
    fvgPrevWinOpen.unshift(htfWinOpen), fvgPrevWinHigh.unshift(htfWinHigh), fvgPrevWinLow.unshift(htfWinLow), fvgTwoVal.unshift(two)
    fvgLimitLines.unshift(lLimit), fvgStopLines.unshift(lStop), fvgTpLines.unshift(lTp), fvgLimitLabels.unshift(lblLimit), fvgStopLabels.unshift(lblStop), fvgTpLabels.unshift(lblTp)

if bearFVG
    gapTop = low[2], gapBot = high, limitPrice = (gapTop + gapBot) / 2
    stopPrice = high[1], tpPrice = limitPrice - 3 * (stopPrice - limitPrice)
    lineLeft = bar_index[2], lineRight = bar_index + extendBars
    b = box.new(lineLeft, gapTop, lineRight, gapBot, border_color = bearColor, bgcolor = bearColor)
    lLimit = line.new(lineLeft, limitPrice, lineRight, limitPrice, color = color.black), lblLimit = label.new(lineRight, limitPrice, "LIMIT", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.small)
    lStop = line.new(lineLeft, stopPrice, lineRight, stopPrice, color = color.black, style = line.style_dashed), lblStop = label.new(lineRight, stopPrice, "STOP", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.small)
    lTp = line.new(lineLeft, tpPrice, lineRight, tpPrice, color = color.black, style = line.style_dashed), lblTp = label.new(lineRight, tpPrice, "TP", style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.small)
    fvgBoxes.unshift(b), fvgTypes.unshift(-1), fvgFlipped.unshift(0), fvgTouched.unshift(0), fvgMidWicks.unshift(low[1]), fvgMids.unshift(limitPrice), fvgHTFWindow.unshift(htfWindowStartMinutes)
    fvgPrevWinOpen.unshift(htfWinOpen), fvgPrevWinHigh.unshift(htfWinHigh), fvgPrevWinLow.unshift(htfWinLow), fvgTwoVal.unshift(two)
    fvgLimitLines.unshift(lLimit), fvgStopLines.unshift(lStop), fvgTpLines.unshift(lTp), fvgLimitLabels.unshift(lblLimit), fvgStopLabels.unshift(lblStop), fvgTpLabels.unshift(lblTp)

if fvgBoxes.size() > 0
    i = fvgBoxes.size() - 1
    while i >= 0
        b = fvgBoxes.get(i), t = fvgTypes.get(i), flipped = fvgFlipped.get(i), touched = fvgTouched.get(i), mid = fvgMids.get(i)
        top = box.get_top(b), bot = box.get_bottom(b), lft = box.get_left(b), fvgWindow = fvgHTFWindow.get(i)
        pOpen = fvgPrevWinOpen.get(i)
        showFVG = (is1m or is5m or is15m), shouldDelete = false

        if touched == 0 and low <= mid and high >= mid
            fvgTouched.set(i, 1), touched := 1
        if touched == 1
            if flipped == 0 and ((t == -1 and close < bot) or (t == 1 and close > top))
                shouldDelete := true
            else if flipped == 1 and (close > top or close < bot)
                shouldDelete := true

        if not shouldDelete and flipped == 0 and ((t == 1 and close < bot) or (t == -1 and close > top))
            box.set_bgcolor(b, t == 1 ? ifvgColor : ifvgBullColor), box.set_border_color(b, t == 1 ? ifvgColor : ifvgBullColor)
            newStop = fvgMidWicks.get(i), newTp = t == 1 ? mid - 3 * (newStop - mid) : mid + 3 * (mid - newStop)
            line.set_y1(fvgStopLines.get(i), newStop), line.set_y2(fvgStopLines.get(i), newStop), label.set_y(fvgStopLabels.get(i), newStop)
            line.set_y1(fvgTpLines.get(i), newTp), line.set_y2(fvgTpLines.get(i), newTp), label.set_y(fvgTpLabels.get(i), newTp)
            fvgFlipped.set(i, 1), fvgTouched.set(i, 0)

        // ── HTF Filtering ──
        if (is1m and useHTF1m) or (is5m and useHTF5m)
            if fvgWindow != (htfWindowStartMinutes - currHTFMin)
                showFVG := false
            else
                winMid = (prevWinHigh + prevWinLow) / 2.0
                if (winMid < tdo and mid > pOpen) or (winMid > tdo and mid < pOpen)
                    showFVG := false

        if (is15m and useHTF15m)
            if fvgWindow != (htfWindowStartMinutes - currHTFMin)
                showFVG := false
            else
                winMid = (prevWinHigh + prevWinLow) / 2.0
                fTwo = fvgTwoVal.get(i)
                if not na(fTwo)
                    if winMid < fTwo
                        if mid > pOpen
                            showFVG := false
                    else if winMid > fTwo
                        if mid < pOpen
                            showFVG := false
                else
                    showFVG := false

        if (bar_index - lft) > lookback
            showFVG := false

        if not showFVG
            box.set_bgcolor(b, na), box.set_border_color(b, na)
            line.set_color(fvgLimitLines.get(i), na), line.set_color(fvgStopLines.get(i), na), line.set_color(fvgTpLines.get(i), na)
            label.set_textcolor(fvgLimitLabels.get(i), na), label.set_textcolor(fvgStopLabels.get(i), na), label.set_textcolor(fvgTpLabels.get(i), na)
        else
            box.set_bgcolor(b, flipped == 1 ? (t == 1 ? ifvgColor : ifvgBullColor) : (t == 1 ? bullColor : bearColor))
            box.set_border_color(b, flipped == 1 ? (t == 1 ? ifvgColor : ifvgBullColor) : (t == 1 ? bullColor : bearColor))
            line.set_color(fvgLimitLines.get(i), color.black), line.set_color(fvgStopLines.get(i), color.black), line.set_color(fvgTpLines.get(i), color.black)
            label.set_textcolor(fvgLimitLabels.get(i), color.black), label.set_textcolor(fvgStopLabels.get(i), color.black), label.set_textcolor(fvgTpLabels.get(i), color.black)

        if shouldDelete
            box.delete(b), line.delete(fvgLimitLines.get(i)), line.delete(fvgStopLines.get(i)), line.delete(fvgTpLines.get(i))
            label.delete(fvgLimitLabels.get(i)), label.delete(fvgStopLabels.get(i)), label.delete(fvgTpLabels.get(i))
            fvgBoxes.remove(i), fvgTypes.remove(i), fvgFlipped.remove(i), fvgTouched.remove(i), fvgMidWicks.remove(i), fvgMids.remove(i), fvgHTFWindow.remove(i)
            fvgPrevWinOpen.remove(i), fvgPrevWinHigh.remove(i), fvgPrevWinLow.remove(i), fvgTwoVal.remove(i), fvgLimitLines.remove(i), fvgStopLines.remove(i), fvgTpLines.remove(i)
            fvgLimitLabels.remove(i), fvgStopLabels.remove(i), fvgTpLabels.remove(i)
        i := i - 1

// --- POI logic ---
bullPOI = (is1m or is5m or is15m) and open > close[1] and close > open and close[1] > open[1]
bearPOI = (is1m or is5m or is15m) and open < close[1] and close < open and close[1] < open[1]
var box[] poiBoxes = array.new<box>(), var int[] poiCreatedBar = array.new<int>()
if bullPOI
    poiBoxes.unshift(box.new(bar_index[1], open, bar_index[1], close[1], border_color = poiColor, bgcolor = poiColor, extend = extend.right)), poiCreatedBar.unshift(bar_index)
if bearPOI
    poiBoxes.unshift(box.new(bar_index[1], close[1], bar_index[1], open, border_color = poiColor, bgcolor = poiColor, extend = extend.right)), poiCreatedBar.unshift(bar_index)
if poiBoxes.size() > 0
    j = poiBoxes.size() - 1
    while j >= 0
        pb = poiBoxes.get(j), pcreated = poiCreatedBar.get(j), pTop = box.get_top(pb), pBot = box.get_bottom(pb)
        if (bar_index - pcreated) > lookback or (bar_index - pcreated >= 1 and low <= math.max(pTop, pBot) and high >= math.min(pTop, pBot))
            box.delete(pb), poiBoxes.remove(j), poiCreatedBar.remove(j)
        j := j - 1
````
