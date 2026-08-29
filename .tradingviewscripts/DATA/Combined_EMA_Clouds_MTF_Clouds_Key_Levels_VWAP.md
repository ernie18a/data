<!-- tradingview-pine-id: PUB;fc40591b084f48a7a1309c70592e2c49 -->
<!-- tradingviewscripts-format: 1 -->
# Combined EMA Clouds + MTF Clouds + Key Levels + VWAP

Source: https://www.tradingview.com/script/IzzIKNp9-Combined-EMA-Clouds-MTF-Key-Levels-VWAP/

## Description

This is a all in one script that combines ripster ema clouds ripster MTF clouds key levels such as previous day low/high and pre market low/high and also VWAP. all in a single script.

EMA Cloud System is a Trading System Invented by Ripster where areas are shaded between two desired EMAs. The concept implies the EMA cloud area serves as support or resistance for Intraday & Swing Trading. This can be utilized effectively on 10 Min for day trading and 1Hr/Daily for Swings. Ripster himself utilizes various combinations of the 5-12, 34-50, 8-9, 20-21 EMA clouds but the possibilities are endless to find what works best for you.
“Ideally, 5-12 or 5-13 EMA cloud acts as a fluid trendline for day trades. 8-9 EMA Clouds can be used as pullback Levels –(optional). Additionally, a high level price over or under 34-50 EMA clouds confirms either bullish or bearish bias on the price action for any timeframe” – Ripster

8-9 CLOUD (RIBBON) IS USED TO
AS PULLBACK POSITION ADD

5-12 CLOUD IS USED TO RIDE THE
TREND OR HIT POPS IF LONG

34-50 CLOUD DECIDES
OVERALL TREND UP OR DOWN

This system can be utilized effectively on the 10 Minute chart for day trading
and 1 Hour/Daily Chart for swing trades

Over 50 emas trend is bullish below is Bearish.
Whenever you long or short that 34-50 ema cloud is your risk level.

---

## Source Code

````pine
//@version=6
indicator("Combined EMA Clouds + MTF Clouds + Key Levels + VWAP", overlay=true, max_lines_count=100)

// ==========================================
// --- VWAP SETTINGS ---
// ==========================================
showVwap      = input.bool(true, "Show VWAP Line", group="VWAP")
vwapColor     = input.color(color.black, "VWAP Color", group="VWAP")
vwapThickness = input.int(1, "VWAP Thickness", minval=1, maxval=10, group="VWAP")
hideVwapHigh  = input.bool(true, "Hide VWAP on D/W/M", group="VWAP")

// ==========================================
// --- KEY LEVELS VISIBILITY & STYLE ---
// ==========================================
showDO        = input.bool(false, "Daily Open", group="Key Level Visibility")
showPDHL      = input.bool(true, "Prev Day High/Low", group="Key Level Visibility")
showPMHL      = input.bool(true, "Pre-Market High/Low", group="Key Level Visibility")
showWO        = input.bool(false, "Weekly Open", group="Key Level Visibility")
showMO        = input.bool(false, "Monthly Open", group="Key Level Visibility")
showMon       = input.bool(false, "Monday Range", group="Key Level Visibility")
nyShow        = input.bool(false, "NY Lunch High/Low", group="Key Level Visibility")
levelExt      = input.int(20, "Level Extension (Bars)", group="Key Level Visibility")
nyWidth       = input.int(2, "NY Lunch Line Width", minval=1, maxval=5, group="Key Level Visibility")

// New Option to Hide Intraday Levels on HTF
hideIntradayOnHTF = input.bool(true, "Hide Daily/Intraday Levels on D/W/M", group="Key Level Visibility")

labelsize = input.string(defval='Medium', title='Text Size', options=['Small', 'Medium', 'Large'], group="Key Level Visibility")
linesize  = input.string(defval='Medium', title='Line Width', options=['Small', 'Medium', 'Large'], inline='Line', group="Key Level Visibility")

final_lab_size = labelsize == 'Small' ? size.small : labelsize == 'Medium' ? size.normal : size.large
final_line_wid = linesize  == 'Small' ? 1 : linesize == 'Medium' ? 2 : 3

// ==========================================
// --- KEY LEVEL COLORS ---
// ==========================================
c_do  = input.color(color.gray, "Daily Open Color", group="Key Level Colors")
c_pdh = input.color(color.blue, "PDH Color", group="Key Level Colors")
c_pdl = input.color(color.blue, "PDL Color", group="Key Level Colors")
c_pmh = input.color(color.purple, "Pre-Market High Color", group="Key Level Colors")
c_pml = input.color(color.purple, "Pre-Market Low Color", group="Key Level Colors")
c_wo  = input.color(color.white, "Weekly Open Color", group="Key Level Colors")
c_mo  = input.color(color.aqua, "Monthly Open Color", group="Key Level Colors")
c_mon = input.color(color.orange, "Monday Range Color", group="Key Level Colors")
nyColor = input.color(color.black, "NY Lunch HL Color", group="Key Level Colors")

// ==========================================
// --- EMA CLOUD INPUTS ---
// ==========================================
src  = input.source(hl2, "EMA Source", group="EMA Clouds")

ema1_en = input.bool(true, "Show Cloud 1", group="EMA Clouds", inline="C1")
ema1_s  = input.int(8, "S", group="EMA Clouds", inline="C1")
ema1_l  = input.int(9, "L", group="EMA Clouds", inline="C1")

ema2_en = input.bool(true, "Show Cloud 2", group="EMA Clouds", inline="C2")
ema2_s  = input.int(5, "S", group="EMA Clouds", inline="C2")
ema2_l  = input.int(13, "L", group="EMA Clouds", inline="C2")

ema3_en = input.bool(true, "Show Cloud 3", group="EMA Clouds", inline="C3")
ema3_s  = input.int(34, "S", group="EMA Clouds", inline="C3")
ema3_l  = input.int(50, "L", group="EMA Clouds", inline="C3")

ema4_en = input.bool(false, "Show Cloud 4", group="EMA Clouds", inline="C4")
ema4_s  = input.int(72, "S", group="EMA Clouds", inline="C4")
ema4_l  = input.int(89, "L", group="EMA Clouds", inline="C4")

ema5_en = input.bool(true, "Show Cloud 5", group="EMA Clouds", inline="C5")
ema5_s  = input.int(180, "S", group="EMA Clouds", inline="C5")
ema5_l  = input.int(200, "L", group="EMA Clouds", inline="C5")

// ==========================================
// --- MTF EMA CLOUD INPUTS ---
// ==========================================
showMTF  = input.bool(true, "Enable MTF Clouds", group="MTF EMA CLOUDS (ADDED)")
ma_off   = input.int(0, "MTF Offset", group="MTF EMA CLOUDS (ADDED)")

res1     = input.timeframe("60", "MTF 1 Resolution", group="MTF EMA CLOUDS (ADDED)")
ma_len1  = input.int(34, "MTF 1 Short", group="MTF EMA CLOUDS (ADDED)", inline="MTF1")
ma_len2  = input.int(50, "MTF 1 Long", group="MTF EMA CLOUDS (ADDED)", inline="MTF1")

res2     = input.timeframe("D", "MTF 2 Resolution", group="MTF EMA CLOUDS (ADDED)")
ma_len3  = input.int(20, "MTF 2 Short", group="MTF EMA CLOUDS (ADDED)", inline="MTF2")
ma_len4  = input.int(21, "MTF 2 Long", group="MTF EMA CLOUDS (ADDED)", inline="MTF2")

res3     = input.timeframe("D", "MTF 3 Resolution", group="MTF EMA CLOUDS (ADDED)")
ma_len5  = input.int(50, "MTF 3 Short", group="MTF EMA CLOUDS (ADDED)", inline="MTF3")
ma_len6  = input.int(55, "MTF 3 Long", group="MTF EMA CLOUDS (ADDED)", inline="MTF3")

// ==========================================
// --- CALCULATIONS & PLOTTING ---
// ==========================================
e1a = ta.ema(src, ema1_s)
e1b = ta.ema(src, ema1_l)
e2a = ta.ema(src, ema2_s)
e2b = ta.ema(src, ema2_l)
e3a = ta.ema(src, ema3_s)
e3b = ta.ema(src, ema3_l)
e4a = ta.ema(src, ema4_s)
e4b = ta.ema(src, ema4_l)
e5a = ta.ema(src, ema5_s)
e5b = ta.ema(src, ema5_l)

p1a = plot(ema1_en ? e1a : na, color=color.new(#036103, 90), title="C1 Short", display=display.none)
p1b = plot(ema1_en ? e1b : na, color=color.new(#880e4f, 90), title="C1 Long", display=display.none)
fill(p1a, p1b, color = e1a >= e1b ? color.new(#036103, 45) : color.new(#880e4f, 45))

p2a = plot(ema2_en ? e2a : na, color=color.new(#4caf50, 90), title="C2 Short", display=display.none)
p2b = plot(ema2_en ? e2b : na, color=color.new(#f44336, 90), title="C2 Long", display=display.none)
fill(p2a, p2b, color = e2a >= e2b ? color.new(#4caf50, 65) : color.new(#f44336, 65))

p3a = plot(ema3_en ? e3a : na, color=color.new(#2196f3, 90), title="C3 Short", display=display.none)
p3b = plot(ema3_en ? e3b : na, color=color.new(#ffb74d, 90), title="C3 Long", display=display.none)
fill(p3a, p3b, color = e3a >= e3b ? color.new(#2196f3, 70) : color.new(#ffb74d, 70))

p4a = plot(ema4_en ? e4a : na, color=color.new(#009688, 90), title="C4 Short", display=display.none)
p4b = plot(ema4_en ? e4b : na, color=color.new(#f06292, 90), title="C4 Long", display=display.none)
fill(p4a, p4b, color = e4a >= e4b ? color.new(#009688, 70) : color.new(#f06292, 70))

p5a = plot(ema5_en ? e5a : na, color=color.new(#05bed5, 90), title="C5 Short", display=display.none)
p5b = plot(ema5_en ? e5b : na, color=color.new(#e65100, 90), title="C5 Long", display=display.none)
fill(p5a, p5b, color = e5a >= e5b ? color.new(#05bed5, 70) : color.new(#e65100, 70))

// --- MTF CALCULATIONS ---
htf1_s = request.security(syminfo.tickerid, res1, ta.ema(src, ma_len1))
htf1_l = request.security(syminfo.tickerid, res1, ta.ema(src, ma_len2))
htf2_s = request.security(syminfo.tickerid, res2, ta.ema(src, ma_len3))
htf2_l = request.security(syminfo.tickerid, res2, ta.ema(src, ma_len4))
htf3_s = request.security(syminfo.tickerid, res3, ta.ema(src, ma_len5))
htf3_l = request.security(syminfo.tickerid, res3, ta.ema(src, ma_len6))

m1s = plot(showMTF ? htf1_s : na, color=color.new(#05bed5, 50), offset=ma_off, title="MTF 1 Short", display=display.none)
m1l = plot(showMTF ? htf1_l : na, color=color.new(#05bed5, 50), offset=ma_off, title="MTF 1 Long", display=display.none)
fill(m1s, m1l, color=color.new(#05bed5, 85), title="MTF 1 Cloud")

m2s = plot(showMTF ? htf2_s : na, color=color.new(color.black, 50), offset=ma_off, title="MTF 2 Short", display=display.none)
m2l = plot(showMTF ? htf2_l : na, color=color.new(color.black, 50), offset=ma_off, title="MTF 2 Long", display=display.none)
fill(m2s, m2l, color=color.new(color.black, 70), title="MTF 2 Cloud")

m3s = plot(showMTF ? htf3_s : na, color=color.new(color.purple, 50), offset=ma_off, title="MTF 3 Short", display=display.none)
m3l = plot(showMTF ? htf3_l : na, color=color.new(color.purple, 50), offset=ma_off, title="MTF 3 Long", display=display.none)
fill(m3s, m3l, color=color.new(color.purple, 85), title="MTF 3 Cloud")

// VWAP Logic
v_val = ta.vwap(hlc3)
plotVwap = showVwap and (hideVwapHigh ? timeframe.isintraday : true)
plot(plotVwap ? v_val : na, "VWAP", color=vwapColor, linewidth=vwapThickness)

// --- VISIBILITY FILTER ---
isHTF = timeframe.isweekly or timeframe.ismonthly or timeframe.isdaily
showIntraday = hideIntradayOnHTF ? not isHTF : true

// --- DRAWING FUNCTIONS ---
drawLevel(show, startTime, price, txt, col) =>
    var line ln = na
    var label lb = na
    if show and barstate.islast and not na(price)
        int limit = timenow + (time - time[1]) * levelExt
        ln := line.new(startTime, price, limit, price, xloc=xloc.bar_time, color=col, width=final_line_wid)
        lb := label.new(limit, price, txt, xloc=xloc.bar_time, style=label.style_none, textcolor=col, size=final_lab_size)
        line.delete(ln[1]), label.delete(lb[1])

drawNY(show, startTime, price, txt) =>
    var line  ln = na
    var label lb = na
    if show and barstate.islast and not na(price) and not na(startTime)
        int limit = timenow + (time - time[1]) * levelExt
        ln := line.new(startTime, price, limit, price, xloc=xloc.bar_time, color=nyColor, width=nyWidth)
        lb := label.new(limit, price, txt, xloc=xloc.bar_time, style=label.style_none, textcolor=nyColor, size=final_lab_size)
        line.delete(ln[1])
        label.delete(lb[1])

// --- KEY LEVELS DATA ---
[dO, dTime] = request.security(syminfo.tickerid, "D", [open, time], lookahead=barmerge.lookahead_on)
[pdH, pdL]  = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[wO, wTime] = request.security(syminfo.tickerid, "W", [open, time], lookahead=barmerge.lookahead_on)
[mO, mTime] = request.security(syminfo.tickerid, "M", [open, time], lookahead=barmerge.lookahead_on)

// Level Drawings with HTF Filter
drawLevel(showDO and showIntraday, dTime, dO, "Daily Open", c_do)
drawLevel(showPDHL and showIntraday, dTime, pdH, "PDH", c_pdh)
drawLevel(showPDHL and showIntraday, dTime, pdL, "PDL", c_pdl)
drawLevel(showWO, wTime, wO, "Weekly Open", c_wo)
drawLevel(showMO, mTime, mO, "Monthly Open", c_mo)

// Pre-Market Logic
var float pmH = na
var float pmL = na
var int pmTime = na
if ta.change(time("D")) != 0
    pmH := na
    pmL := na
if session.ispremarket
    if na(pmH) or high > pmH
        pmH := high
        pmTime := time
    if na(pmL) or low < pmL
        pmL := low

drawLevel(showPMHL and showIntraday and not session.ispremarket, pmTime, pmH, "PMH", c_pmh)
drawLevel(showPMHL and showIntraday and not session.ispremarket, pmTime, pmL, "PML", c_pml)

// --- NY LUNCH HIGH/LOW LOGIC ---
var float nylH = na
var float nylL = na
var int   nylHTime = na
var int   nylLTime = na
nyLunchSession = "1200-1300"
nyTz           = "America/New_York"

inNYL = not na(time("", nyLunchSession, nyTz))

if ta.change(time("D")) != 0
    nylH := na
    nylL := na
    nylHTime := na
    nylLTime := na

if inNYL
    if na(nylH) or high > nylH
        nylH := high
        nylHTime := time
    if na(nylL) or low < nylL
        nylL := low
        nylLTime := time

drawNY(nyShow and showIntraday and not inNYL, nylHTime, nylH, "NYL.H")
drawNY(nyShow and showIntraday and not inNYL, nylLTime, nylL, "NYL.L")

// Monday Range
var float monH = na
var float monL = na
var int monTime = na
if ta.change(time("W")) != 0
    monH := na
    monL := na
if dayofweek == dayofweek.monday
    if na(monH) or high > monH
        monH := high
        monTime := time
    if na(monL) or low < monL
        monL := low

drawLevel(showMon and showIntraday and not na(monH), monTime, monH, "Mon High", c_mon)
drawLevel(showMon and showIntraday and not na(monL), monTime, monL, "Mon Low", c_mon)
````
