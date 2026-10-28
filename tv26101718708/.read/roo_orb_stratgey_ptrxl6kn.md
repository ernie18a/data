# ROO ORB STRATGEY

- url: https://www.tradingview.com/script/PtrxL6Kn-ROO-ORB-STRATGEY/
- type: indicator
- pine_id: PUB;eebda2a72a794f9fa3ec693f65b1d6b9
- version: 1.0

## Description

ORB trader focused on support & resistance, price action, and key levels from the Asia and London sessions. Keeping it simple, staying patient, and only taking clean setups.

## Source Code

````pine
//@version=6
// =============================================================================
//  NQ ORB Prop Clean  (2:1 fixed-risk version)
//  -------------------------------------------------------------------------
//  Built for prop-firm rules. Only two things on the chart: the Opening Range
//  break and prior Support / Resistance. Every trade is a fixed 10-20 point
//  target at a locked 2:1 reward-to-risk, with the stop placement drawn and
//  labeled, and the dollar value per unit (per contract) shown so you know
//  exactly what you make or risk. No VWAP, no EMAs, no extra noise.
//
//  No repaint: breaks confirm on bar close; S/R uses confirmed swing pivots
//  and the completed prior-day bar.
// =============================================================================

indicator("NQ ORB Prop Clean", "NQ ORB Prop", overlay = true, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
//  INPUTS
// =============================================================================
g1 = "Opening Range"
orTypeInput = input.string("15 min", "OR Duration", options = ["5 min", "15 min", "30 min"], group = g1, tooltip = "Range built from the 09:30 ET open.")

g2 = "Target / Risk"
targetPts  = input.float(15.0, "Target (points)", minval = 5.0, maxval = 30.0, step = 1.0, group = g2, tooltip = "Profit target in index points. For NQ keep it 10-20.")
rrRatio    = input.float(2.0, "Reward : Risk", minval = 1.0, step = 0.5, group = g2, tooltip = "Stop = Target / this ratio. 2 = a 2:1 trade.")
autoPV     = input.bool(true, "Auto $/Point from Chart", group = g2, tooltip = "ON = detect the contract automatically (NQ = $20/pt, MNQ = $2/pt). Works on both - just open the chart you're trading.")
pointValManual = input.float(20.0, "Manual $ per Point", minval = 0.0, step = 1.0, group = g2, tooltip = "Only used when Auto is OFF. NQ = 20, MNQ = 2.")

// Auto-detect the dollar value of one point for the current contract.
pointValue = autoPV and not na(syminfo.pointvalue) and syminfo.pointvalue > 0 ? syminfo.pointvalue : pointValManual

gE = "Entry Mode"
entryMode = input.string("Break (take it on the break)", "How to enter", options = ["Break (take it on the break)", "Candle close beyond"], group = gE, tooltip = "BREAK = trigger the moment price trades through the OR level after the range locks; entry, stop and target are measured from the OR level itself. CLOSE = wait for a candle to close beyond the level.")
alertLive = input.bool(true, "Alert the instant of the break", group = gE, tooltip = "ON = the alert fires live the moment price breaks the level (real-time). OFF = the alert waits for the breaking bar to close.")
isBreak   = entryMode == "Break (take it on the break)"

g3 = "Quality Filters"
useBody = input.bool(true, "Require Strong Body", group = g3)
minBody = input.float(0.50, "Min Body %", minval = 0.0, maxval = 1.0, step = 0.05, group = g3)
useVol  = input.bool(true, "Require Volume > Avg", group = g3)
volLen  = input.int(20, "Volume MA Length", minval = 1, group = g3)

g4 = "Support / Resistance"
useSR      = input.bool(true, "Require Clear Room to Target", group = g4, tooltip = "Block the trade if a prior S/R level sits between entry and target.")
pivotLen   = input.int(10, "Swing Strength", minval = 2, group = g4, tooltip = "Bars on each side that define a swing high/low.")
showPDHL   = input.bool(true, "Show Previous Day High/Low", group = g4)
showDayHL  = input.bool(true, "Show Overnight High/Low (HOD/LOD)", group = g4, tooltip = "High and low of the overnight session, frozen and drawn ending at the close of the window below.")
ovnSess    = input.session("1800-0930", "Overnight Range (ET)", group = g4, tooltip = "Window for the HOD/LOD. Default 6:00 PM - 9:30 AM ET.")
showAsia   = input.bool(true, "Show Asian Session High/Low", group = g4)
asianSess  = input.session("1800-0300", "Asian Session (ET)", group = g4, tooltip = "Tokyo/Asia range in Eastern Time. Default 6:00 PM - 3:00 AM ET. Shows the most recently completed session.")
showLondon = input.bool(true, "Show London Session High/Low", group = g4)
londonSess = input.session("0200-0500", "London Session (ET)", group = g4, tooltip = "London range in Eastern Time. Default 2:00-5:00 AM ET (completes before the NY open).")
showSwings = input.bool(true, "Mark Swing S/R", group = g4)

g5 = "Session"
tz      = "America/New_York"
useSess = input.bool(true, "Signals only 09:30-11:30 ET", group = g5)

g6 = "Visuals"
showDash = input.bool(true, "Show Info Table", group = g6)

// OR selection -> minutes -> session end string.
orMinutes = orTypeInput == "5 min" ? 5 : orTypeInput == "30 min" ? 30 : 15
orEndStr  = orMinutes == 5 ? "0935" : orMinutes == 30 ? "1000" : "0945"
orSession = "0930-" + orEndStr

// Derived risk math (locked ratio).
stopDist      = targetPts / rrRatio
profitPerUnit = targetPts * pointValue
riskPerUnit   = stopDist  * pointValue

// =============================================================================
//  SESSION / OPENING RANGE
// =============================================================================
inRTH    = not na(time(timeframe.period, "0930-1600", tz))
inOR     = not na(time(timeframe.period, orSession, tz))
inSignal = not na(time(timeframe.period, "0930-1130", tz))
newDay   = inRTH and not inRTH[1]
canSig   = inRTH and (not useSess or inSignal)

var float orHigh   = na
var float orLow    = na
var bool  orLocked = false

firstORbar = inOR and not inOR[1]
if firstORbar
    orHigh   := high
    orLow    := low
    orLocked := false
else if inOR
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)

if inRTH and not inOR and not na(orHigh)
    orLocked := true

if newDay and not inOR
    orHigh   := na
    orLow    := na
    orLocked := false

// =============================================================================
//  PRIOR-DAY LEVELS + SWING PIVOTS (Support / Resistance memory)
// =============================================================================
volMA = ta.sma(volume, volLen)

pdh = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

var array<float> hiPv = array.new<float>()
var array<float> loPv = array.new<float>()
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)
if not na(ph)
    array.push(hiPv, ph)
    if array.size(hiPv) > 30
        array.shift(hiPv)
if not na(pl)
    array.push(loPv, pl)
    if array.size(loPv) > 30
        array.shift(loPv)

// --- Overnight High / Low, frozen at the 09:30 open (drawn ending at 09:30) ----
inOvn    = not na(time(timeframe.period, ovnSess, tz))
firstOvn = inOvn and not inOvn[1]
var float ovnHiTmp = na
var float ovnLoTmp = na
var int   ovnStart = na
var float ovnHigh  = na
var float ovnLow   = na
if firstOvn
    ovnHiTmp := high
    ovnLoTmp := low
    ovnStart := bar_index
else if inOvn
    ovnHiTmp := math.max(ovnHiTmp, high)
    ovnLoTmp := math.min(ovnLoTmp, low)
ovnEnded = not inOvn and inOvn[1]
if ovnEnded
    ovnHigh := ovnHiTmp
    ovnLow  := ovnLoTmp

// --- Previous Asian-session High / Low (most recent completed range) -----------
inAsia    = not na(time(timeframe.period, asianSess, tz))
firstAsia = inAsia and not inAsia[1]
var float aHiTmp    = na
var float aLoTmp    = na
var float asianHigh = na
var float asianLow  = na
if firstAsia
    aHiTmp := high
    aLoTmp := low
else if inAsia
    aHiTmp := math.max(aHiTmp, high)
    aLoTmp := math.min(aLoTmp, low)
if not inAsia and inAsia[1]
    asianHigh := aHiTmp
    asianLow  := aLoTmp

// --- Previous London-session High / Low (most recent completed range) ----------
inLon    = not na(time(timeframe.period, londonSess, tz))
firstLon = inLon and not inLon[1]
var float lHiTmp     = na
var float lLoTmp     = na
var float londonHigh = na
var float londonLow  = na
if firstLon
    lHiTmp := high
    lLoTmp := low
else if inLon
    lHiTmp := math.max(lHiTmp, high)
    lLoTmp := math.min(lLoTmp, low)
if not inLon and inLon[1]
    londonHigh := lHiTmp
    londonLow  := lLoTmp

// Nearest level above / below a price from an array (na entries ignored).
f_nearAbove(price, arr) =>
    float r = na
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            v = array.get(arr, i)
            if not na(v) and v > price
                r := na(r) ? v : math.min(r, v)
    r

f_nearBelow(price, arr) =>
    float s = na
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            v = array.get(arr, i)
            if not na(v) and v < price
                s := na(s) ? v : math.max(s, v)
    s

// Build the full S/R pools: swing pivots + prior day, prior close, Asia, London, overnight.
resPool = array.copy(hiPv)
array.push(resPool, pdh)
array.push(resPool, pdc)
array.push(resPool, asianHigh)
array.push(resPool, londonHigh)
array.push(resPool, ovnHigh)
supPool = array.copy(loPv)
array.push(supPool, pdl)
array.push(supPool, pdc)
array.push(supPool, asianLow)
array.push(supPool, londonLow)
array.push(supPool, ovnLow)

resAbove = f_nearAbove(close, resPool)
supBelow = f_nearBelow(close, supPool)

roomLong  = not useSR or na(resAbove) or (resAbove - close) >= targetPts
roomShort = not useSR or na(supBelow) or (close - supBelow) >= targetPts

// =============================================================================
//  CANDLE QUALITY
// =============================================================================
body    = math.abs(close - open)
rng     = high - low
bodyPct = rng > 0 ? body / rng : 0.0
bodyOK  = not useBody or bodyPct >= minBody
volOK   = not useVol or volume > volMA

// =============================================================================
//  BREAKOUT SIGNALS (one per side until price re-enters the range)
// =============================================================================
var bool longDone  = false
var bool shortDone = false

if orLocked and not na(orHigh) and not na(orLow)
    if close < orHigh
        longDone := false
    if close > orLow
        shortDone := false
if newDay
    longDone  := false
    shortDone := false

// BREAK mode  = trigger the moment price trades through the OR level.
// CLOSE mode  = wait for a candle to close fully beyond the level.
breakLong  = isBreak ? high > orHigh : (close > orHigh and math.min(open, close) > orHigh)
breakShort = isBreak ? low  < orLow  : (close < orLow  and math.max(open, close) < orLow)
// Body / volume quality only apply to closed candles (a forming break has no body yet).
qualOK = isBreak or (bodyOK and volOK)

longSig  = orLocked and not na(orHigh) and canSig and not longDone  and breakLong  and qualOK and roomLong
shortSig = orLocked and not na(orLow)  and canSig and not shortDone and breakShort and qualOK and roomShort

if longSig
    longDone := true
if shortSig
    shortDone := true

// =============================================================================
//  TRADE LEVELS
// =============================================================================
var float entryPrice = na
var float stopPrice  = na
var float tgtPrice   = na
var int   dir        = 0

if newDay
    entryPrice := na
    stopPrice  := na
    tgtPrice   := na
    dir        := 0

// In BREAK mode the entry is the OR level itself (where you take the break);
// in CLOSE mode it is the close of the confirming candle.
if longSig
    entryPrice := isBreak ? orHigh : close
    stopPrice  := entryPrice - stopDist
    tgtPrice   := entryPrice + targetPts
    dir        := 1
else if shortSig
    entryPrice := isBreak ? orLow : close
    stopPrice  := entryPrice + stopDist
    tgtPrice   := entryPrice - targetPts
    dir        := -1

active = dir != 0

// --- S/R RISK RATING: how much clear room is in front of the trade vs target ---
// More room past the target = lower chance an S/R level stalls the move.
roomPtsFwd = dir == 1 ? (na(resAbove) ? na : resAbove - entryPrice) : dir == -1 ? (na(supBelow) ? na : entryPrice - supBelow) : na
riskRate   = not active ? "-" : na(roomPtsFwd) ? "LOW (open sky)" : roomPtsFwd >= targetPts * 2 ? "LOW (clear)" : roomPtsFwd >= targetPts * 1.5 ? "MEDIUM" : "ELEVATED (level near target)"
riskCol2   = not active ? color.gray : riskRate == "MEDIUM" ? color.orange : str.startswith(riskRate, "ELEVATED") ? color.red : color.green

// =============================================================================
//  CHART DRAWINGS — entry / stop / target (labeled with $ value)
// =============================================================================
var line  enLine = na
var line  slLine = na
var line  tpLine = na
var label slLab  = na
var label tpLab  = na

if longSig or shortSig
    if not na(enLine)
        line.delete(enLine)
        line.delete(slLine)
        line.delete(tpLine)
        label.delete(slLab)
        label.delete(tpLab)
    enLine := line.new(bar_index, entryPrice, bar_index + 50, entryPrice, color = color.new(color.gray, 0),  style = line.style_dashed, width = 1)
    slLine := line.new(bar_index, stopPrice,  bar_index + 50, stopPrice,  color = color.new(color.red, 0),   style = line.style_dotted, width = 1)
    tpLine := line.new(bar_index, tgtPrice,   bar_index + 50, tgtPrice,   color = color.new(color.green, 0), style = line.style_solid,  width = 2)
    slLab  := label.new(bar_index + 50, stopPrice, "SL " + str.tostring(stopPrice, format.mintick) + "  -$" + str.tostring(riskPerUnit, "#") + "/unit", style = label.style_label_left, color = color.new(color.red, 10),   textcolor = color.white, size = size.small)
    tpLab  := label.new(bar_index + 50, tgtPrice,  "TP " + str.tostring(tgtPrice, format.mintick) + "  +$" + str.tostring(profitPerUnit, "#") + "/unit", style = label.style_label_left, color = color.new(color.green, 10), textcolor = color.white, size = size.small)

// =============================================================================
//  VISUALS — Opening Range (dotted) + bold session levels
// =============================================================================

// --- Opening Range: DOTTED green (high) / red (low), redrawn each day ----------
orJustLocked = orLocked and not orLocked[1]
var line orHiLn = na
var line orLoLn = na
if newDay and not na(orHiLn)
    line.delete(orHiLn)
    line.delete(orLoLn)
    orHiLn := na
    orLoLn := na
if orJustLocked
    orHiLn := line.new(bar_index, orHigh, bar_index + 1, orHigh, extend = extend.right, color = color.new(color.green, 0), style = line.style_dotted, width = 2)
    orLoLn := line.new(bar_index, orLow,  bar_index + 1, orLow,  extend = extend.right, color = color.new(color.red, 0),   style = line.style_dotted, width = 2)

// --- Bold session levels, shown across the RTH day -----------------------------
//     Previous Day High = GREEN, Previous Day Low = RED
//     Asia High/Low = BLUE,  London High/Low = RED  (all bold, width 3)
showLvl = orLocked and inRTH
plot(showPDHL   and showLvl ? pdh        : na, "PREV DAY HIGH", color = color.new(color.green, 0), linewidth = 3, style = plot.style_linebr)
plot(showPDHL   and showLvl ? pdl        : na, "PREV DAY LOW",  color = color.new(color.red, 0),   linewidth = 3, style = plot.style_linebr)
plot(showAsia   and showLvl ? asianHigh  : na, "ASIA HIGH",     color = color.new(color.blue, 0),  linewidth = 3, style = plot.style_linebr)
plot(showAsia   and showLvl ? asianLow   : na, "ASIA LOW",      color = color.new(color.blue, 0),  linewidth = 3, style = plot.style_linebr)
plot(showLondon and showLvl ? londonHigh : na, "LONDON HIGH",   color = color.new(color.red, 0),   linewidth = 3, style = plot.style_linebr)
plot(showLondon and showLvl ? londonLow  : na, "LONDON LOW",    color = color.new(color.red, 0),   linewidth = 3, style = plot.style_linebr)

// --- Overnight High / Low: BOLD lines that END at the 09:30 open ---------------
var line  hodLn = na
var line  lodLn = na
var label hodLb = na
var label lodLb = na
if ovnEnded
    if not na(hodLn)
        line.delete(hodLn)
        line.delete(lodLn)
        label.delete(hodLb)
        label.delete(lodLb)
    if showDayHL and not na(ovnStart) and not na(ovnHigh)
        hodLn := line.new(ovnStart, ovnHigh, bar_index, ovnHigh, color = color.new(color.yellow, 0), width = 3)
        lodLn := line.new(ovnStart, ovnLow,  bar_index, ovnLow,  color = color.new(color.yellow, 0), width = 3)
        hodLb := label.new(bar_index, ovnHigh, "HOD", style = label.style_label_left, color = color.new(color.yellow, 0), textcolor = color.black, size = size.normal)
        lodLb := label.new(bar_index, ovnLow,  "LOD", style = label.style_label_left, color = color.new(color.yellow, 0), textcolor = color.black, size = size.normal)

// --- Bold uppercase labels pinned to the right edge of each level ---------------
f_lvlLabel(lbl, show, price, txt, col) =>
    label out = lbl
    if show and not na(price)
        if na(out)
            out := label.new(bar_index, price, txt, style = label.style_label_left, color = col, textcolor = color.white, size = size.normal)
        else
            label.set_xy(out, bar_index, price)
            label.set_text(out, txt)
    out

var label lbPDH = na
var label lbPDL = na
var label lbAH  = na
var label lbAL  = na
var label lbLH  = na
var label lbLL  = na
var label lbORH = na
var label lbORL = na
if barstate.islast
    lbPDH := f_lvlLabel(lbPDH, showPDHL,   pdh,        "PDH "      + str.tostring(pdh, format.mintick),        color.new(color.green, 0))
    lbPDL := f_lvlLabel(lbPDL, showPDHL,   pdl,        "PDL "      + str.tostring(pdl, format.mintick),        color.new(color.red, 0))
    lbAH  := f_lvlLabel(lbAH,  showAsia,   asianHigh,  "ASIA H "   + str.tostring(asianHigh, format.mintick),  color.new(color.blue, 0))
    lbAL  := f_lvlLabel(lbAL,  showAsia,   asianLow,   "ASIA L "   + str.tostring(asianLow, format.mintick),   color.new(color.blue, 0))
    lbLH  := f_lvlLabel(lbLH,  showLondon, londonHigh, "LONDON H " + str.tostring(londonHigh, format.mintick), color.new(color.red, 0))
    lbLL  := f_lvlLabel(lbLL,  showLondon, londonLow,  "LONDON L " + str.tostring(londonLow, format.mintick),  color.new(color.red, 0))
    lbORH := f_lvlLabel(lbORH, orLocked,   orHigh,     "ORB HIGH " + str.tostring(orHigh, format.mintick),     color.new(color.green, 0))
    lbORL := f_lvlLabel(lbORL, orLocked,   orLow,      "ORB LOW "  + str.tostring(orLow, format.mintick),      color.new(color.red, 0))

// Mark confirmed swing S/R as it forms.
if showSwings and not na(ph)
    label.new(bar_index[pivotLen], ph, "R", style = label.style_label_down, color = color.new(color.maroon, 40), textcolor = color.white, size = size.tiny)
if showSwings and not na(pl)
    label.new(bar_index[pivotLen], pl, "S", style = label.style_label_up,   color = color.new(color.teal, 40),   textcolor = color.white, size = size.tiny)

// Entry arrows.
plotshape(longSig,  title = "Long Entry",  style = shape.triangleup,   location = location.belowbar, color = color.new(color.green, 0), textcolor = color.white, size = size.normal, text = "LONG")
plotshape(shortSig, title = "Short Entry", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0),   textcolor = color.white, size = size.normal, text = "SHORT")

// =============================================================================
//  ALERTS — fire on the break with full plan + stop placement
// =============================================================================
alertMsg = (longSig ? "LONG" : "SHORT") + " NQ ORB " + (isBreak ? "(break)" : "(close)") + " | Entry " + str.tostring(entryPrice, format.mintick) + " | STOP " + str.tostring(stopPrice, format.mintick) + " (-$" + str.tostring(riskPerUnit, "#") + "/unit) | TARGET " + str.tostring(tgtPrice, format.mintick) + " (+$" + str.tostring(profitPerUnit, "#") + "/unit) | " + str.tostring(rrRatio, "#.#") + ":1 | S/R risk " + riskRate
if longSig or shortSig
    alert(alertMsg, alertLive ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)

// Simple per-direction conditions (for the basic alert dialog).
alertcondition(longSig,  title = "Long Breakout",  message = "NQ ORB Prop: LONG breakout - see chart for stop/target")
alertcondition(shortSig, title = "Short Breakout", message = "NQ ORB Prop: SHORT breakout - see chart for stop/target")

// =============================================================================
//  INFO TABLE
// =============================================================================
roomTxt = dir == 1 ? (na(resAbove) ? "Open sky" : str.tostring(resAbove - entryPrice, "#.#") + " pts") : dir == -1 ? (na(supBelow) ? "Open sky" : str.tostring(entryPrice - supBelow, "#.#") + " pts") : "-"
dirTxt  = dir == 1 ? "LONG" : dir == -1 ? "SHORT" : "Flat"
dirCol  = dir == 1 ? color.green : dir == -1 ? color.red : color.gray

var table dash = na
if showDash
    if na(dash)
        dash := table.new(position.top_right, 2, 10, border_width = 1)
    if barstate.islast
        table.cell(dash, 0, 8, "$ / point",     text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 8, "$" + str.tostring(pointValue, "#.#"), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 0, "Signal",        text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
        table.cell(dash, 1, 0, dirTxt,          text_color = color.white, bgcolor = color.new(dirCol, 20),     text_size = size.small)
        table.cell(dash, 0, 1, "Entry",         text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 1, na(entryPrice) ? "-" : str.tostring(entryPrice, format.mintick), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 2, "Stop",          text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 2, na(stopPrice) ? "-" : str.tostring(stopPrice, format.mintick), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 3, "Target",        text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 3, na(tgtPrice) ? "-" : str.tostring(tgtPrice, format.mintick), text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 4, "Reward:Risk",   text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 4, str.tostring(rrRatio, "#.#") + " : 1", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 5, "Risk / unit",   text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 5, "-$" + str.tostring(riskPerUnit, "#"), text_color = color.white, bgcolor = color.new(color.maroon, 30), text_size = size.small)
        table.cell(dash, 0, 6, "Profit / unit", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 6, "+$" + str.tostring(profitPerUnit, "#"), text_color = color.white, bgcolor = color.new(color.green, 30), text_size = size.small)
        table.cell(dash, 0, 7, "Room to Tgt",   text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 7, roomTxt,         text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 0, 9, "S/R Risk",      text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
        table.cell(dash, 1, 9, riskRate,        text_color = color.white, bgcolor = color.new(riskCol2, 20),   text_size = size.small)
````
