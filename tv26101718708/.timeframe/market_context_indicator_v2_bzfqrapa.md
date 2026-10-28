# Market Context Indicator v2

- url: https://www.tradingview.com/script/BzfQRApa-Market-Context-Indicator-v2/
- type: indicator
- pine_id: PUB;6a2494a49e9f44519ba8a4fbad62c529
- version: 4.0

## Description

# Market Context Indicator v2

Market Context Indicator v2 was built around the idea that price moves between areas of liquidity, participation, and imbalance. Instead of relying on a single signal, it combines the major pieces of market structure I use to read the trading day into one clean chart.

### Session Structure

Tracks Asia, London, and New York sessions with visual session ranges, previous session highs and lows, and individual session VWAPs. This provides context for where liquidity was created and where price may revisit.

### Opening Range

Displays the NY Opening Range high, low, and midpoint. The ORB is used to identify early session acceptance, continuation, and potential directional bias.

### Liquidity Framework

Plots key higher-timeframe liquidity levels including previous week highs/lows and previous month highs/lows, allowing important external liquidity targets to remain visible throughout the session.

### Fair Value Gaps (FVGs)

Detects bullish and bearish imbalances based on three-candle displacement. FVGs include customizable minimum size, mitigation threshold, and lifespan to focus on meaningful inefficiencies.

### Order Blocks

Highlights significant areas of previous institutional participation using volume-based pivot detection. Invalidated zones are automatically removed, leaving only active areas of interest.

### High Interest Price Levels (HIPL)

A custom concept designed to identify price levels that show repeated interaction combined with meaningful volume participation. These are areas where buyers and sellers have consistently shown interest and where reactions are more likely to occur.

### Trend & Structure

Includes an EMA 9/50 trend cloud, EMA crossover highlights, and confirmed swing highs and lows to provide additional context for momentum and structural shifts.

### Purpose

This indicator is not designed to predict every move or provide automatic buy and sell signals. Its purpose is to organize the important areas of the market into one view, allowing traders to make decisions based on confluence between liquidity, imbalance, participation, trend, and session behavior.

Built from my own trading concepts and continuously refined around how I read market structure, rather than following any single trading methodology.

## Source Code

````pine
//@version=6
indicator("Market Context Indicator v2", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUTS
//====================================================

// ORB
orbSession      = input.session("0930-1000", "ORB Time")


tz = "America/New_York"
asiaSess   = input.session("2000-0200", "Asia Session")
londonSess = input.session("0300-0830", "London Session")
nySess     = input.session("0830-1130", "NY Session")
obShowCount = input.int(3, "OB Zones to Show", minval=1, maxval=20)
// Session VWAP Toggles
showAsiaVWAP = input.bool(true, "Show Asia VWAP", group="Session VWAP")
showLonVWAP  = input.bool(true, "Show London VWAP", group="Session VWAP")
showNYVWAP   = input.bool(true, "Show NY VWAP", group="Session VWAP")

//====================================================
// MTF VWAP (SINGLE SELECTION)
//====================================================
groupMtfVwap = "MTF VWAP"
showMtfVwap = input.bool(true, "Show MTF VWAP", group=groupMtfVwap)
mtfTimeframe = input.string("15", "MTF Timeframe", options=["15", "30", "60", "240"], group=groupMtfVwap)
mtfVwapColor = input.color(color.new(#ff6d00, 0), "MTF VWAP Color", group=groupMtfVwap)
mtfVwapWidth = input.int(2, "MTF VWAP Width", minval=1, maxval=3, group=groupMtfVwap)

// MTF VWAP Calculation
mtfVwapVal = request.security(syminfo.tickerid, mtfTimeframe, ta.vwap[1], lookahead=barmerge.lookahead_on)

//====================================================
// SESSION LOGIC
//====================================================

inORB       = not na(time(timeframe.period, orbSession))

newORB      = inORB and not inORB[1]


// ==========================
// SESSION IDENTIFICATION
// ==========================

// ==========================
// UTILITY FUNCTIONS
// ==========================
f_in(sess) => not na(time(timeframe.period, sess, tz))

inAsia = f_in(asiaSess)
inLon  = f_in(londonSess)
inNY   = f_in(nySess)

string activeSession =
     inAsia ? "ASIA" :
     inLon  ? "LONDON" :
     inNY   ? "NY" : "NONE"

// Session specific colors
c_sess_asia = input.color(color.blue, "Prev Asia Color", group="Colors")
c_sess_lon  = input.color(color.purple, "Prev London Color", group="Colors")
c_sess_ny   = input.color(color.orange, "Prev NY Color", group="Colors")

// ==========================
// SESSION BOXES & TRACKING
// ==========================
var box[] sessBoxes = array.new_box()

// Variables for Session Tracking (Previous Levels)
var float pAsiaH = na, var float pAsiaL = na, var float cAsiaH = na, var float cAsiaL = na
var float pLonH  = na, var float pLonL  = na, var float cLonH  = na, var float cLonL  = na
var float pNYH   = na, var float pNYL   = na, var float cNYH   = na, var float cNYL   = na

// Asia Tracking
if inAsia and not inAsia[1]
    cAsiaH := high
    cAsiaL := low
else if inAsia
    cAsiaH := math.max(cAsiaH, high)
    cAsiaL := math.min(cAsiaL, low)
else if not inAsia and inAsia[1]
    pAsiaH := cAsiaH
    pAsiaL := cAsiaL

// London Tracking
if inLon and not inLon[1]
    cLonH := high
    cLonL := low
else if inLon
    cLonH := math.max(cLonH, high)
    cLonL := math.min(cLonL, low)
else if not inLon and inLon[1]
    pLonH := cLonH
    pLonL := cLonL

// NY Tracking
if inNY and not inNY[1]
    cNYH := high
    cNYL := low
else if inNY
    cNYH := math.max(cNYH, high)
    cNYL := math.min(cNYL, low)
else if not inNY and inNY[1]
    pNYH := cNYH
    pNYL := cNYL

drawSession(sess, name, col)=>
    var float h_val = na
    var float l_val = na
    var int start_idx = na
    inSess = f_in(sess)

    if inSess and not inSess[1]
        h_val := high
        l_val := low
        start_idx := bar_index

    if inSess
        h_val := math.max(h_val, high)
        l_val := math.min(l_val, low)

    if not inSess and inSess[1]
        b = box.new(start_idx, h_val, bar_index, l_val, bgcolor=color.new(col, 85), border_color=na)
        label.new(start_idx, h_val, name, size=size.tiny, textcolor=chart.fg_color, color=#00000000)
        array.push(sessBoxes, b)

        if array.size(sessBoxes) > 5
            box.delete(array.shift(sessBoxes))

drawSession(asiaSess, "Asia", c_sess_asia)
drawSession(londonSess, "London", c_sess_lon)
drawSession(nySess, "NY", c_sess_ny)

// ==========================
// SESSION SPECIFIC VWAPS
// ==========================
var float asiaPV = 0.0, var float asiaVol = 0.0, var float asiaVWAP = na, var float lastAsiaVWAP = na
var float lonPV  = 0.0, var float lonVol  = 0.0, var float lonVWAP  = na, var float lastLonVWAP  = na
var float nyPV   = 0.0, var float nyVol   = 0.0, var float nyVWAP   = na, var float lastNYVWAP   = na

// Asia VWAP
if inAsia
    if not inAsia[1]
        asiaPV := hlc3 * volume
        asiaVol := volume
    else
        asiaPV += hlc3 * volume
        asiaVol += volume
    asiaVWAP := asiaPV / asiaVol
    lastAsiaVWAP := asiaVWAP
else
    asiaPV := 0.0, asiaVol := 0.0, asiaVWAP := na

// London VWAP
if inLon
    if not inLon[1]
        lonPV := hlc3 * volume
        lonVol := volume
    else
        lonPV += hlc3 * volume
        lonVol += volume
    lonVWAP := lonPV / lonVol
    lastLonVWAP := lonVWAP
else
    lonPV := 0.0, lonVol := 0.0, lonVWAP := na

// NY VWAP
if inNY
    if not inNY[1]
        nyPV := hlc3 * volume
        nyVol := volume
    else
        nyPV += hlc3 * volume
        nyVol += volume
    nyVWAP := nyPV / nyVol
    lastNYVWAP := nyVWAP
else
    nyPV := 0.0, nyVol := 0.0, nyVWAP := na

// Plotting ONLY during active session
plot(showAsiaVWAP ? asiaVWAP : na, "Asia VWAP", color=c_sess_asia, linewidth=2, style=plot.style_linebr)
plot(showLonVWAP  ? lonVWAP  : na, "London VWAP", color=c_sess_lon, linewidth=2, style=plot.style_linebr)
plot(showNYVWAP   ? nyVWAP   : na, "NY VWAP", color=c_sess_ny, linewidth=2, style=plot.style_linebr)

// ==========================
// VWAP (Daily)
// ==========================
vwapValue = ta.vwap(hlc3)
plot(vwapValue, "VWAP", color=color.new(#ffb109, 0), linewidth=2)

// MTF VWAP Plot
plot(showMtfVwap ? mtfVwapVal : na, "MTF VWAP", color=mtfVwapColor, linewidth=mtfVwapWidth)

// ==========================
// HTF LIQUIDITY LEVELS
// ==========================
// --- Style Settings ---
c_pwh = input.color(color.new(color.white, 0), "PWH/PWL Color", group="Colors")
c_pmh = input.color(color.new(color.white, 0), "PMH/PML Color", group="Colors")

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)

plot(pwh, "PWH", color=c_pwh, linewidth=1, style=plot.style_linebr)
plot(pwl, "PWL", color=c_pwh, linewidth=1, style=plot.style_linebr)
plot(pmh, "PMH", color=c_pmh, linewidth=1, style=plot.style_linebr)
plot(pml, "PML", color=c_pmh, linewidth=1, style=plot.style_linebr)

plot(pAsiaH, "PAsiaH", color=c_sess_asia, linewidth=1, style=plot.style_linebr)
plot(pAsiaL, "PAsiaL", color=c_sess_asia, linewidth=1, style=plot.style_linebr)
plot(pLonH,  "PLonH",  color=c_sess_lon, linewidth=1, style=plot.style_linebr)
plot(pLonL,  "PLonL",  color=c_sess_lon, linewidth=1, style=plot.style_linebr)
plot(pNYH,   "PNYH",   color=c_sess_ny, linewidth=1, style=plot.style_linebr)
plot(pNYL,   "PNYL",   color=c_sess_ny, linewidth=1, style=plot.style_linebr)

//====================================================
// ORB VARIABLES
//====================================================

var float orbHigh = na
var float orbLow  = na
var float orbMid  = na

var bool orbLocked = false

//====================================================
// BUILD ORB
//====================================================

if newORB
    orbHigh := high
    orbLow  := low
    orbLocked := false

if inORB
    orbHigh := math.max(orbHigh, high)
    orbLow  := math.min(orbLow, low)

if not inORB and inORB[1]
    orbLocked := true
    orbMid := (orbHigh + orbLow) / 2.0

//====================================================
// PLOTS
//====================================================

plot(orbHigh, "OR High", color=color.blue, linewidth=2)
plot(orbLow,  "OR Low",  color=color.blue, linewidth=2)
plot(orbMid,  "OR Mid",  color=color.white, linewidth=2)

// ==========================
// LABELS (LAST BAR)
// ==========================
var label lbl_pwh = na, var label lbl_pwl = na
var label lbl_pmh = na, var label lbl_pml = na
var label lbl_pash = na, var label lbl_pasl = na
var label lbl_ploh = na, var label lbl_plol = na
var label lbl_pnyh = na, var label lbl_pnyl = na
var label lbl_orh = na, var label lbl_orl = na
var label lbl_orbMid = na
var label lbl_vwap = na
var label lbl_asia_vwap = na, var label lbl_lon_vwap = na, var label lbl_ny_vwap = na
var label lbl_mtf_vwap = na

f_updateLabel(lbl, val, txt, col) =>
    if not na(val)
        if na(lbl)
            label.new(bar_index, val, txt,
                 style=label.style_label_left,
                 size=size.tiny,
                 color=col,
                 textcolor=color.white)
        else
            label.set_xy(lbl, bar_index, val)
            label.set_text(lbl, txt)
            label.set_color(lbl, col)
            lbl
    else
        label.delete(lbl)
        na

if barstate.islast
    lbl_orbMid  := f_updateLabel(lbl_orbMid, orbMid, "ORM", color.rgb(82, 249, 255))
    lbl_pwh  := f_updateLabel(lbl_pwh, pwh, "PWH", c_pwh)
    lbl_pwl  := f_updateLabel(lbl_pwl, pwl, "PWL", c_pwh)
    lbl_pmh  := f_updateLabel(lbl_pmh, pmh, "PMH", c_pmh)
    lbl_pml  := f_updateLabel(lbl_pml, pml, "PML", c_pmh)
    lbl_pash := f_updateLabel(lbl_pash, pAsiaH, "P-Asia H", c_sess_asia)
    lbl_pasl := f_updateLabel(lbl_pasl, pAsiaL, "P-Asia L", c_sess_asia)
    lbl_ploh := f_updateLabel(lbl_ploh, pLonH, "P-Lon H", c_sess_lon)
    lbl_plol := f_updateLabel(lbl_plol, pLonL, "P-Lon L", c_sess_lon)
    lbl_pnyh := f_updateLabel(lbl_pnyh, pNYH, "P-NY H", c_sess_ny)
    lbl_pnyl := f_updateLabel(lbl_pnyl, pNYL, "P-NY L", c_sess_ny)
    lbl_orh  := f_updateLabel(lbl_orh, orbHigh, "ORH", color.blue)
    lbl_orl  := f_updateLabel(lbl_orl, orbLow, "ORL", color.blue)
    lbl_vwap := f_updateLabel(lbl_vwap, vwapValue, "VWAP", color.new(#ffb109, 0))
    
    // PERSISTENT Session VWAP Labels (Value stays at last known point)
    lbl_asia_vwap := f_updateLabel(lbl_asia_vwap, showAsiaVWAP ? lastAsiaVWAP : na, "ASIA VWAP", c_sess_asia)
    lbl_lon_vwap  := f_updateLabel(lbl_lon_vwap, showLonVWAP ? lastLonVWAP : na, "LON VWAP", c_sess_lon)
    lbl_ny_vwap   := f_updateLabel(lbl_ny_vwap, showNYVWAP ? lastNYVWAP : na, "NY VWAP", c_sess_ny)
    
    // MTF VWAP Label
    lbl_mtf_vwap := f_updateLabel(lbl_mtf_vwap, showMtfVwap ? mtfVwapVal : na, mtfTimeframe + "m VWAP", mtfVwapColor)

//----------------------------------------------------
// FVG
//----------------------------------------------------

groupFVG = "FVG"

minGapTicks     = input.int(4, "Minimum Gap Size (ticks)", minval=1, group=groupFVG)
maxFvgLife      = input.int(20, "Maximum FVG Lifetime", minval=1, group=groupFVG)
midpointTouchPc = input.float(0.50, "Mitigation Threshold", minval=0.1, maxval=1.0, step=0.05, group=groupFVG)

//====================================================
// FVG
//====================================================

minGap = syminfo.mintick * minGapTicks

bullFVG =
     low > high[2] and
     (low - high[2]) >= minGap

bearFVG =
     high < low[2] and
     (low[2] - high) >= minGap

bullTop = low
bullBot = high[2]

bearTop = low[2]
bearBot = high

bbullMid = bullBot + ((bullTop - bullBot) * midpointTouchPc)
bearMid = bearTop - ((bearTop - bearBot) * midpointTouchPc)

//====================================================
// FVG VISUALS
//====================================================

var box bullBox = na
var box bearBox = na

var line bullMidLine = na
var line bearMidLine = na

//====================================================
// FVG VISUAL PLOTTING
//====================================================

showFVGs = input.bool(true, "Show FVG Zones")

fvgExtend = input.int(20, "FVG Box Extension", minval=1)

showMidline = input.bool(true, "Show FVG Midline")

deleteFilledFVG = input.bool(true, "Delete Filled FVG")

if showFVGs and bullFVG
    bullBox := box.new(
         left = bar_index - 2,
         top = bullTop,
         right = bar_index + fvgExtend,
         bottom = bullBot,
         bgcolor = color.new(color.lime, 88),
         border_color = color.new(color.lime, 30))
    
    if showMidline
        bullMidLine := line.new(
             x1 = bar_index - 2,
             y1 = bbullMid,
             x2 = bar_index + fvgExtend,
             y2 = bbullMid,
             color = color.lime,
             style = line.style_dotted)

if showFVGs and bearFVG
    bearBox := box.new(
         left = bar_index - 2,
         top = bearTop,
         right = bar_index + fvgExtend,
         bottom = bearBot,
         bgcolor = color.new(color.red, 88),
         border_color = color.new(color.red, 30))
    
    if showMidline
        bearMidLine := line.new(
             x1 = bar_index - 2,
             y1 = bearMid,
             x2 = bar_index + fvgExtend,
             y2 = bearMid,
             color = color.red,
             style = line.style_dotted)

//====================================================
// FVG EXPIRY
//====================================================
var int bullFvgBar = na
var int bearFvgBar = na


// Bull FVG expiry
if not na(bullFvgBar) and (bar_index - bullFvgBar > maxFvgLife)
    box.delete(bullBox)
    line.delete(bullMidLine)
    bullBox := na
    bullMidLine := na
    bullFvgBar := na


// Bear FVG expiry
if not na(bearFvgBar) and (bar_index - bearFvgBar > maxFvgLife)
    box.delete(bearBox)
    line.delete(bearMidLine)
    bearBox := na
    bearMidLine := na
    bearFvgBar := na

    // ==========================
// ORDER BLOCKS
// ==========================
ob_len = 5
ob_max = 20
var float[] ob_bull_top = array.new_float(), var float[] ob_bull_bot = array.new_float()
var int[]   ob_bull_left = array.new_int(), var bool[]  ob_bull_valid = array.new_bool()
var float[] ob_bear_top = array.new_float(), var float[] ob_bear_bot = array.new_float()
var int[]   ob_bear_left = array.new_int(), var bool[]  ob_bear_valid = array.new_bool()

phv_ob = not na(ta.pivothigh(volume, ob_len, ob_len))
if phv_ob
    if close[ob_len] > open[ob_len]
        array.unshift(ob_bull_top, hl2[ob_len]), array.unshift(ob_bull_bot, low[ob_len]), array.unshift(ob_bull_left, time[ob_len]), array.unshift(ob_bull_valid, true)
    else
        array.unshift(ob_bear_top, high[ob_len]), array.unshift(ob_bear_bot, hl2[ob_len]), array.unshift(ob_bear_left, time[ob_len]), array.unshift(ob_bear_valid, true)
    if array.size(ob_bull_top) > ob_max
        array.pop(ob_bull_top), array.pop(ob_bull_bot), array.pop(ob_bull_left), array.pop(ob_bull_valid)
    if array.size(ob_bear_top) > ob_max
        array.pop(ob_bear_top), array.pop(ob_bear_bot), array.pop(ob_bear_left), array.pop(ob_bear_valid)

if array.size(ob_bull_valid) > 0
    for i = 0 to array.size(ob_bull_valid) - 1
        if array.get(ob_bull_valid, i) and low < array.get(ob_bull_bot, i)
            array.set(ob_bull_valid, i, false)
if array.size(ob_bear_valid) > 0
    for i = 0 to array.size(ob_bear_valid) - 1
        if array.get(ob_bear_valid, i) and high > array.get(ob_bear_top, i)
            array.set(ob_bear_valid, i, false)

var box[] ob_drawn = array.new_box()
if barstate.islast
    for b in ob_drawn
        box.delete(b)
    array.clear(ob_drawn)
    int b_count_bull = 0, int b_count_bear = 0
    for i = 0 to math.min(50, array.size(ob_bull_top)) - 1
        if b_count_bull >= obShowCount
            break
        if array.get(ob_bull_valid, i)
            array.push(ob_drawn, box.new(array.get(ob_bull_left, i), array.get(ob_bull_top, i), time, array.get(ob_bull_bot, i), xloc = xloc.bar_time, bgcolor = color.new(color.green, 85), border_color = na))
            b_count_bull += 1
    for i = 0 to math.min(50, array.size(ob_bear_top)) - 1
        if b_count_bear >= obShowCount
            break
        if array.get(ob_bear_valid, i)
            array.push(ob_drawn, box.new(array.get(ob_bear_left, i), array.get(ob_bear_top, i), time, array.get(ob_bear_bot, i), xloc = xloc.bar_time, bgcolor = color.new(#ff52f1, 56), border_color = na))
            b_count_bear += 1

//====================================================
// BREAKOUT STATE
//====================================================

var bool bullishState = false
var bool bearishState = false

if newORB
    bullishState := false
    bearishState := false

// bullish continuation environment
if orbLocked and close > orbHigh
    bullishState := true
    bearishState := false

// bearish continuation environment
if orbLocked and close < orbLow
    bearishState := true
    bullishState := false

//====================================================
// EMA 9 / EMA 50 TREND CLOUD
//====================================================

groupCloud = "Trend Cloud"

showCloud = input.bool(true, "Show EMA 9/50 Cloud", group=groupCloud)

bullCloudColor = input.color(color.new(color.green, 75), "Bull Cloud Color", group=groupCloud)
bearCloudColor = input.color(color.new(color.red, 75), "Bear Cloud Color", group=groupCloud)

bullCrossBG = input.color(color.new(color.green, 85), "Bull Cross Background", group=groupCloud)
bearCrossBG = input.color(color.new(color.red, 85), "Bear Cross Background", group=groupCloud)

// EMA Calculations
ema9 = ta.ema(close, 9)
ema50 = ta.ema(close, 50)

// Hidden EMA plots used for cloud fill
ema9Plot = plot(showCloud ? ema9 : na, title="EMA 9 Hidden", display=display.none)
ema50Plot = plot(showCloud ? ema50 : na, title="EMA 50 Hidden", display=display.none)

// Cloud Logic
isBull = ema9 > ema50
isBear = ema9 < ema50

fill(
    ema9Plot,
    ema50Plot,
    color = isBull ? bullCloudColor : bearCloudColor,
    title = "EMA 9/50 Trend Cloud"
)

//====================================================
// SWING HIGH / LOW DETECTION
//====================================================

groupSwing = "Swing Levels"

swingLookback    = input.int(5, "Swing Lookback Period", minval=2, maxval=20, group=groupSwing)
showSwingLines   = input.bool(true, "Show Swing Lines", group=groupSwing)
swingHighColor   = input.color(color.new(color.blue, 0), "Swing High Color", group=groupSwing)
swingLowColor    = input.color(color.new(color.orange, 0), "Swing Low Color", group=groupSwing)
swingLineWidth   = input.int(1, "Swing Line Width", minval=1, maxval=3, group=groupSwing)

var line[] swingHighLines = array.new_line()
var line[] swingLowLines = array.new_line()
var label[] swingHighLabels = array.new_label()
var label[] swingLowLabels = array.new_label()

var string lastSwingType = "none"
var int lastSwingIdx = 0

// Check if a bar X positions ago is a swing high
f_checkSwingHigh(lookAhead) =>
    barIdx = lookAhead
    // Current bar must be higher than lookback bars before AND lookback bars after
    highVal = high[barIdx]
    isSH = true
    
    // Check bars before
    for i = 1 to swingLookback
        if high[barIdx + i] >= highVal
            isSH := false
            break
    
    // Check bars after
    for i = 1 to swingLookback
        if high[barIdx - i] >= highVal
            isSH := false
            break
    
    isSH

// Check if a bar X positions ago is a swing low
f_checkSwingLow(lookAhead) =>
    barIdx = lookAhead
    lowVal = low[barIdx]
    isSL = true
    
    // Check bars before
    for i = 1 to swingLookback
        if low[barIdx + i] <= lowVal
            isSL := false
            break
    
    // Check bars after
    for i = 1 to swingLookback
        if low[barIdx - i] <= lowVal
            isSL := false
            break
    
    isSL

if showSwingLines
    // Look back at completed bars with lookback period of confirmation
    lookbackOffset = swingLookback + 1
    
    isSwingHigh = f_checkSwingHigh(lookbackOffset)
    isSwingLow = f_checkSwingLow(lookbackOffset)
    
    // SWING HIGH
    if isSwingHigh and (lastSwingType != "high") and (bar_index - lastSwingIdx > swingLookback)
        swingPrice = high[lookbackOffset]
        swingBar = bar_index - lookbackOffset
        
        newLine = line.new(
            x1 = swingBar,
            y1 = swingPrice,
            x2 = swingBar + 3,
            y2 = swingPrice,
            color = swingHighColor,
            width = swingLineWidth,
            style = line.style_dashed,
            extend = extend.none)
        array.push(swingHighLines, newLine)
        
        lbl = label.new(
            x = swingBar + 3,
            y = swingPrice,
            text = "SH",
            style = label.style_label_left,
            size = size.tiny,
            color = swingHighColor,
            textcolor = color.white)
        array.push(swingHighLabels, lbl)
        
        if array.size(swingHighLines) > 15
            line.delete(array.shift(swingHighLines))
            label.delete(array.shift(swingHighLabels))
        
        lastSwingType := "high"
        lastSwingIdx := bar_index
    
    // SWING LOW
    if isSwingLow and (lastSwingType != "low") and (bar_index - lastSwingIdx > swingLookback)
        swingPrice = low[lookbackOffset]
        swingBar = bar_index - lookbackOffset
        
        newLine = line.new(
            x1 = swingBar,
            y1 = swingPrice,
            x2 = swingBar + 3,
            y2 = swingPrice,
            color = swingLowColor,
            width = swingLineWidth,
            style = line.style_dashed,
            extend = extend.none)
        array.push(swingLowLines, newLine)
        
        lbl = label.new(
            x = swingBar + 3,
            y = swingPrice,
            text = "SL",
            style = label.style_label_left,
            size = size.tiny,
            color = swingLowColor,
            textcolor = color.white)
        array.push(swingLowLabels, lbl)
        
        if array.size(swingLowLines) > 15
            line.delete(array.shift(swingLowLines))
            label.delete(array.shift(swingLowLabels))
        
        lastSwingType := "low"
        lastSwingIdx := bar_index

//====================================================
// HIPL (HIGH-INTEREST PRICE LEVELS) - ZONES
//====================================================

groupHIPL = "HIPL"

showHIPL = input.bool(true, "Show HIPL", group=groupHIPL)
hipl_sensitivity = input.int(3, "Test Proximity (ticks)", minval=1, maxval=20, group=groupHIPL)
hipl_minTests = input.int(2, "Minimum Tests Required", minval=2, maxval=5, group=groupHIPL)
hipl_volMultiplier = input.float(1.5, "Volume Spike Multiplier", minval=1.0, maxval=3.0, step=0.1, group=groupHIPL)
hipl_lookback = input.int(50, "HIPL Lookback Bars", minval=20, maxval=100, group=groupHIPL)
hipl_color_bull = input.color(color.new(color.green, 70), "HIPL Bull Color", group=groupHIPL)
hipl_color_bear = input.color(color.new(color.red, 70), "HIPL Bear Color", group=groupHIPL)
hipl_zoneWidth = input.int(5, "Zone Height (ticks)", minval=1, maxval=50, group=groupHIPL)
hipl_expiry = input.int(100, "HIPL Expiry (bars)", minval=20, maxval=500, group=groupHIPL)

// HIPL Data Structure
var float[] hipl_levels = array.new_float()
var int[] hipl_tests = array.new_int()
var float[] hipl_volume = array.new_float()
var int[] hipl_age = array.new_int()
var bool[] hipl_isBull = array.new_bool()
var box[] hipl_boxes = array.new_box()
var line[] hipl_lines = array.new_line()
var label[] hipl_labels = array.new_label()

hipl_tolerance = syminfo.mintick * hipl_sensitivity
hipl_zoneValue = syminfo.mintick * hipl_zoneWidth

// Detect price tests against existing HIPLs
f_detectHIPLTest() =>
    if array.size(hipl_levels) > 0
        for i = 0 to array.size(hipl_levels) - 1
            level = array.get(hipl_levels, i)
            if math.abs(close - level) <= hipl_tolerance
                currentVol = array.get(hipl_volume, i)
                if volume >= currentVol * hipl_volMultiplier
                    array.set(hipl_tests, i, array.get(hipl_tests, i) + 1)
                    array.set(hipl_volume, i, (currentVol + volume) / 2.0)

// Identify new HIPL candidates
f_identifyNewHIPL() =>
    for offset = hipl_lookback to 1
        testPrice = close[offset]
        testCount = 0
        totalVol = volume[offset]
        
        for check = offset - 5 to offset + 5
            if check >= 0 and check < 500
                if math.abs(close[check] - testPrice) <= hipl_tolerance
                    testCount += 1
                    totalVol += volume[check]
        
        if testCount >= hipl_minTests
            isNewLevel = true
            if array.size(hipl_levels) > 0
                for existing = 0 to array.size(hipl_levels) - 1
                    if math.abs(array.get(hipl_levels, existing) - testPrice) <= hipl_tolerance
                        isNewLevel := false
                        break
            
            if isNewLevel
                array.push(hipl_levels, testPrice)
                array.push(hipl_tests, testCount)
                array.push(hipl_volume, totalVol / testCount)
                array.push(hipl_age, 0)
                array.push(hipl_isBull, close > testPrice)

if showHIPL
    f_detectHIPLTest()
    
    if bar_index % 5 == 0
        f_identifyNewHIPL()
    
    // Age and cleanup
    if array.size(hipl_levels) > 0
        for i = array.size(hipl_levels) - 1 to 0
            if not na(array.get(hipl_levels, i))
                array.set(hipl_age, i, array.get(hipl_age, i) + 1)
                
                if array.get(hipl_age, i) > hipl_expiry
                    array.remove(hipl_levels, i)
                    array.remove(hipl_tests, i)
                    array.remove(hipl_volume, i)
                    array.remove(hipl_age, i)
                    array.remove(hipl_isBull, i)
    
    // Redraw on last bar only
    if barstate.islast
        for b in hipl_boxes
            box.delete(b)
        for ln in hipl_lines
            line.delete(ln)
        for lbl in hipl_labels
            label.delete(lbl)
        
        array.clear(hipl_boxes)
        array.clear(hipl_lines)
        array.clear(hipl_labels)
        
        if array.size(hipl_levels) > 0
            for i = 0 to array.size(hipl_levels) - 1
                if not na(array.get(hipl_levels, i))
                    level = array.get(hipl_levels, i)
                    tests = array.get(hipl_tests, i)
                    isBull := array.get(hipl_isBull, i)
                    
                    if tests >= hipl_minTests
                        // Determine control
                        buyerControl = close > level
                        zoneColor = buyerControl ? hipl_color_bull : hipl_color_bear
                        zoneLabel = buyerControl ? "▲ HIPL(" + str.tostring(tests) + ")" : "▼ HIPL(" + str.tostring(tests) + ")"
                        
                        // Draw zone as box
                        zoneTop = level + hipl_zoneValue
                        zoneBot = level - hipl_zoneValue
                        
                        b = box.new(
                            left=bar_index - hipl_lookback,
                            top=zoneTop,
                            right=bar_index,
                            bottom=zoneBot,
                            bgcolor=zoneColor,
                            border_color=color.new(buyerControl ? color.green : color.red, 0),
                            border_width=1)
                        array.push(hipl_boxes, b)
                        
                        // Center line
                        ln = line.new(
                            x1=bar_index - hipl_lookback,
                            y1=level,
                            x2=bar_index,
                            y2=level,
                            color=color.new(buyerControl ? color.green : color.red, 0),
                            width=2,
                            style=line.style_solid)
                        array.push(hipl_lines, ln)
                        
                        // Label
                        lbl = label.new(
                            x=bar_index,
                            y=level,
                            text=zoneLabel,
                            style=label.style_label_left,
                            size=size.tiny,
                            color=zoneColor,
                            textcolor=color.white)
                        array.push(hipl_labels, lbl)

//====================================================
// EMA CROSS BACKGROUND HIGHLIGHT
//====================================================

bullCross = ta.crossover(ema9, ema50)
bearCross = ta.crossunder(ema9, ema50)

bgcolor(
    bullCross ? bullCrossBG :
    bearCross ? bearCrossBG :
    na,
    title="EMA Cross Background"
)
````
