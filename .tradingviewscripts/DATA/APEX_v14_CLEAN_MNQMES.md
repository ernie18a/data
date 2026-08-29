<!-- tradingview-pine-id: PUB;e0424d06731c4472affbc8b78fdcc54d -->
<!-- tradingviewscripts-format: 1 -->
# APEX v14 CLEAN - MNQ/MES

Source: https://www.tradingview.com/script/WiDfQxMm-APEX-v14-CLEAN-MNQ-MES/

## Description

NITRO V15 amazing bot just try it out is an advanced AI-powered trading assistant built for precision, discipline, and consistency. Designed around smart money concepts, liquidity analysis, and market structure, it identifies high-probability trading opportunities while filtering out low-quality setups. By combining multiple layers of confluence—including liquidity sweeps, order blocks, fair value gaps (FVGs), optimal trade entries (OTE), trend strength, volatility, and higher-timeframe confirmation—BRABUZ helps traders make confident, data-driven decisions with a strong focus on risk management and capital preservation.

Rather than generating constant signals, BRABUZ is engineered to prioritize quality over quantity, waiting patiently for A+ setups with the highest statistical edge. It continuously adapts to changing market conditions, providing clear trade entries, stop-loss placement, profit targets, and real-time market bias in a clean, easy-to-read interface. Whether you're a prop firm trader, futures trader, or experienced retail trader, BRABUZ is designed to eliminate emotional decision-making, improve consistency, and give you a professional-grade trading edge. is an advanced AI-powered trading assistant built for precision, discipline, and consistency. Designed around smart money concepts, liquidity analysis, and market structure, it identifies high-probability trading opportunities while filtering out low-quality setups. By combining multiple layers of confluence—including liquidity sweeps, order blocks, fair value gaps (FVGs), optimal trade entries (OTE), trend strength, volatility, and higher-timeframe confirmation—BRABUZ helps traders make confident, data-driven decisions with a strong focus on risk management and capital preservation.

Rather than generating constant signals, BRABUZ is engineered to prioritize quality over quantity, waiting patiently for A+ setups with the highest statistical edge. It continuously adapts to changing market conditions, providing clear trade entries, stop-loss placement, profit targets, and real-time market bias in a clean, easy-to-read interface. Whether you're a prop firm trader, futures trader, or experienced retail trader, BRABUZ is designed to eliminate emotional decision-making, improve consistency, and give you a professional-grade trading edge.

---

## Source Code

````pine
//@version=6
indicator("APEX v14 CLEAN - MNQ/MES", shorttitle="APEX v14 CLEAN", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=300, max_bars_back=5000)

//====================
// GROUPS
//====================
G1 = "Engine"
G2 = "Structure"
G3 = "Zones"
G4 = "Risk"
G5 = "Visuals"

//====================
// INPUTS
//====================
atrLen      = input.int(14, "ATR Length", group=G1, minval=5)
swingLen    = input.int(8, "Swing Strength", group=G2, minval=3, maxval=30)
htfTf       = input.timeframe("15", "HTF Bias", group=G1)
emaLen      = input.int(50, "HTF EMA", group=G1)

useSession  = input.bool(false, "Use Session Filter", group=G1)
showVWAP    = input.bool(false, "Show VWAP/SD Lines", group=G5)
showFVG     = input.bool(true, "Show Clean FVGs", group=G3)
showOB      = input.bool(true, "Show Clean OBs", group=G3)
showOTE     = input.bool(true, "Show Main OTE", group=G3)
showBOS     = input.bool(true, "Show Small BOS/CHoCH", group=G2)
showPanel   = input.bool(true, "Show Compact Panel", group=G5)
showZones   = input.bool(true, "Show Trade Zones", group=G5)

maxFVG      = input.int(3, "Max FVGs", group=G3, minval=1, maxval=8)
maxOB       = input.int(2, "Max OBs", group=G3, minval=1, maxval=6)

slATR       = input.float(1.2, "Stop xATR", group=G4, step=0.1)
tp1R        = input.float(1.0, "TP1 R", group=G4, step=0.25)
tp2R        = input.float(2.0, "TP2 R", group=G4, step=0.25)
tp3R        = input.float(3.0, "TP3 R", group=G4, step=0.25)

cooldown    = input.int(6, "Cooldown Bars", group=G1, minval=1)

cBull       = input.color(#00e676, "Bull", group=G5)
cBear       = input.color(#ff1744, "Bear", group=G5)
cGold       = input.color(#ffd600, "OTE", group=G5)

//====================
// CORE
//====================
atr = ta.atr(atrLen)
vwap = ta.vwap(hlc3)
dev = ta.stdev(close - vwap, 50)
upperSD = vwap + dev * 1.5
lowerSD = vwap - dev * 1.5

plot(showVWAP ? vwap : na, "VWAP", color=color.new(color.white, 60))
plot(showVWAP ? upperSD : na, "Upper SD", color=color.new(cBear, 75))
plot(showVWAP ? lowerSD : na, "Lower SD", color=color.new(cBull, 75))

htfClose = request.security(syminfo.tickerid, htfTf, close, lookahead=barmerge.lookahead_off)
htfEMA   = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)

htfBull = htfClose > htfEMA
htfBear = htfClose < htfEMA

nyHr = hour(time, "America/New_York")
nyMn = minute(time, "America/New_York")
nyT  = nyHr * 100 + nyMn
inLondon = nyT >= 200 and nyT < 500
inNY     = nyT >= 830 and nyT < 1130
sessionOK = not useSession or inLondon or inNY
sessionTxt = inLondon ? "LONDON" : inNY ? "NY" : "OFF"

//====================
// STRUCTURE
//====================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastPH = na
var float lastPL = na
var int lastPHBar = na
var int lastPLBar = na
var int trend = 0

if not na(ph)
    lastPH := ph
    lastPHBar := bar_index - swingLen

if not na(pl)
    lastPL := pl
    lastPLBar := bar_index - swingLen

bullBreak = not na(lastPH) and ta.crossover(close, lastPH)
bearBreak = not na(lastPL) and ta.crossunder(close, lastPL)

bullCHoCH = trend == -1 and bullBreak
bearCHoCH = trend == 1 and bearBreak

if bullBreak
    trend := 1
    if showBOS
        line.new(lastPHBar, lastPH, bar_index, lastPH, color=color.new(cBull, 35), style=line.style_dotted, width=1)
        label.new(bar_index, lastPH, bullCHoCH ? "CHoCH" : "BOS", style=label.style_label_down, color=color.new(cBull, 75), textcolor=cBull, size=size.tiny)

if bearBreak
    trend := -1
    if showBOS
        line.new(lastPLBar, lastPL, bar_index, lastPL, color=color.new(cBear, 35), style=line.style_dotted, width=1)
        label.new(bar_index, lastPL, bearCHoCH ? "CHoCH" : "BOS", style=label.style_label_up, color=color.new(cBear, 75), textcolor=cBear, size=size.tiny)

//====================
// FVG
//====================
type Zone
    box bx
    float top
    float bot
    bool bull

var Zone[] bullFVGs = array.new<Zone>()
var Zone[] bearFVGs = array.new<Zone>()

bullFVG = showFVG and low > high[2] and close[1] > open[1] and math.abs(close[1] - open[1]) > atr * 0.25
bearFVG = showFVG and high < low[2] and close[1] < open[1] and math.abs(close[1] - open[1]) > atr * 0.25

if bullFVG
    bx = box.new(bar_index - 2, low, bar_index + 20, high[2], bgcolor=color.new(cBull, 88), border_color=color.new(cBull, 55), text="FVG", text_color=color.new(cBull, 10), text_size=size.tiny)
    array.push(bullFVGs, Zone.new(bx, low, high[2], true))
    while array.size(bullFVGs) > maxFVG
        box.delete(array.get(bullFVGs, 0).bx)
        array.shift(bullFVGs)

if bearFVG
    bx = box.new(bar_index - 2, low[2], bar_index + 20, high, bgcolor=color.new(cBear, 88), border_color=color.new(cBear, 55), text="FVG", text_color=color.new(cBear, 10), text_size=size.tiny)
    array.push(bearFVGs, Zone.new(bx, low[2], high, false))
    while array.size(bearFVGs) > maxFVG
        box.delete(array.get(bearFVGs, 0).bx)
        array.shift(bearFVGs)

inBullFVG = false
inBearFVG = false

if array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        z = array.get(bullFVGs, i)
        box.set_right(z.bx, bar_index + 20)
        if close < z.bot
            box.delete(z.bx)
            array.remove(bullFVGs, i)
        else if low <= z.top and close >= z.bot
            inBullFVG := true

if array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        z = array.get(bearFVGs, i)
        box.set_right(z.bx, bar_index + 20)
        if close > z.top
            box.delete(z.bx)
            array.remove(bearFVGs, i)
        else if high >= z.bot and close <= z.top
            inBearFVG := true

//====================
// ORDER BLOCKS
//====================
var Zone[] bullOBs = array.new<Zone>()
var Zone[] bearOBs = array.new<Zone>()

if showOB and not na(pl)
    off = swingLen
    if close[off] < open[off]
        bx = box.new(bar_index - off, high[off], bar_index + 25, low[off], bgcolor=color.new(cBull, 91), border_color=color.new(cBull, 65), text="OB", text_color=color.new(cBull, 25), text_size=size.tiny)
        array.push(bullOBs, Zone.new(bx, high[off], low[off], true))
        while array.size(bullOBs) > maxOB
            box.delete(array.get(bullOBs, 0).bx)
            array.shift(bullOBs)

if showOB and not na(ph)
    off = swingLen
    if close[off] > open[off]
        bx = box.new(bar_index - off, high[off], bar_index + 25, low[off], bgcolor=color.new(cBear, 91), border_color=color.new(cBear, 65), text="OB", text_color=color.new(cBear, 25), text_size=size.tiny)
        array.push(bearOBs, Zone.new(bx, high[off], low[off], false))
        while array.size(bearOBs) > maxOB
            box.delete(array.get(bearOBs, 0).bx)
            array.shift(bearOBs)

inBullOB = false
inBearOB = false

if array.size(bullOBs) > 0
    for i = array.size(bullOBs) - 1 to 0
        z = array.get(bullOBs, i)
        box.set_right(z.bx, bar_index + 25)
        if close < z.bot
            box.delete(z.bx)
            array.remove(bullOBs, i)
        else if low <= z.top and close >= z.bot
            inBullOB := true

if array.size(bearOBs) > 0
    for i = array.size(bearOBs) - 1 to 0
        z = array.get(bearOBs, i)
        box.set_right(z.bx, bar_index + 25)
        if close > z.top
            box.delete(z.bx)
            array.remove(bearOBs, i)
        else if high >= z.bot and close <= z.top
            inBearOB := true

//====================
// OTE
//====================
var box oteBox = na
var float oteTop = na
var float oteBot = na
var string oteTxt = "-"

if showOTE and not na(lastPH) and not na(lastPL) and lastPH > lastPL
    rng = lastPH - lastPL

    if trend == 1
        oteTop := lastPH - rng * 0.618
        oteBot := lastPH - rng * 0.786
        oteTxt := close <= oteTop and close >= oteBot ? "BULL OTE" : "-"
        box.delete(oteBox)
        oteBox := box.new(bar_index - 5, oteTop, bar_index + 35, oteBot, bgcolor=color.new(cGold, 88), border_color=color.new(cGold, 35), text="OTE BUY", text_color=cGold, text_size=size.tiny)

    if trend == -1
        oteBot := lastPL + rng * 0.618
        oteTop := lastPL + rng * 0.786
        oteTxt := close >= oteBot and close <= oteTop ? "BEAR OTE" : "-"
        box.delete(oteBox)
        oteBox := box.new(bar_index - 5, oteTop, bar_index + 35, oteBot, bgcolor=color.new(cGold, 88), border_color=color.new(cGold, 35), text="OTE SELL", text_color=cGold, text_size=size.tiny)

if not na(oteBox)
    box.set_right(oteBox, bar_index + 35)

inBullOTE = trend == 1 and not na(oteTop) and not na(oteBot) and close <= oteTop and close >= oteBot
inBearOTE = trend == -1 and not na(oteTop) and not na(oteBot) and close >= oteBot and close <= oteTop

//====================
// SCORE ENGINE
//====================
body = math.abs(close - open)
rngC = high - low
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

bullReject = lowerWick > body * 1.2 and close > open
bearReject = upperWick > body * 1.2 and close < open

bullScore = 0
bullScore += htfBull ? 2 : 0
bullScore += trend == 1 ? 2 : 0
bullScore += inBullFVG ? 2 : 0
bullScore += inBullOB ? 2 : 0
bullScore += inBullOTE ? 2 : 0
bullScore += bullReject ? 2 : 0
bullScore += sessionOK ? 1 : 0

bearScore = 0
bearScore += htfBear ? 2 : 0
bearScore += trend == -1 ? 2 : 0
bearScore += inBearFVG ? 2 : 0
bearScore += inBearOB ? 2 : 0
bearScore += inBearOTE ? 2 : 0
bearScore += bearReject ? 2 : 0
bearScore += sessionOK ? 1 : 0

var int lastSignal = -999
cdOK = bar_index - lastSignal >= cooldown

longSignal = barstate.isconfirmed and cdOK and bullScore >= 8
shortSignal = barstate.isconfirmed and cdOK and bearScore >= 8

if longSignal or shortSignal
    lastSignal := bar_index

//====================
// TRADE VISUALS
//====================
var box riskBox = na
var box rewardBox = na
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var label tradeLabel = na

clearTrade() =>
    box.delete(riskBox)
    box.delete(rewardBox)
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    label.delete(tradeLabel)

if longSignal
    clearTrade()
    entry = close
    sl = low - atr * 0.2
    risk = entry - sl
    tp1 = entry + risk * tp1R
    tp2 = entry + risk * tp2R

    if showZones
        riskBox := box.new(bar_index, entry, bar_index + 40, sl, bgcolor=color.new(cBear, 82), border_color=color.new(cBear, 50))
        rewardBox := box.new(bar_index, tp2, bar_index + 40, entry, bgcolor=color.new(cBull, 86), border_color=color.new(cBull, 50))

    entryLine := line.new(bar_index, entry, bar_index + 40, entry, color=color.white, width=2)
    slLine := line.new(bar_index, sl, bar_index + 40, sl, color=cBear, width=2)
    tp1Line := line.new(bar_index, tp1, bar_index + 40, tp1, color=cBull, style=line.style_dashed)
    tp2Line := line.new(bar_index, tp2, bar_index + 40, tp2, color=cBull, style=line.style_dashed, width=2)

    tradeLabel := label.new(bar_index, low, "LONG\nApex " + str.tostring(bullScore) + "/13", style=label.style_label_up, color=color.new(cBull, 0), textcolor=color.white, size=size.small)

if shortSignal
    clearTrade()
    entry = close
    sl = high + atr * 0.2
    risk = sl - entry
    tp1 = entry - risk * tp1R
    tp2 = entry - risk * tp2R

    if showZones
        riskBox := box.new(bar_index, sl, bar_index + 40, entry, bgcolor=color.new(cBear, 82), border_color=color.new(cBear, 50))
        rewardBox := box.new(bar_index, entry, bar_index + 40, tp2, bgcolor=color.new(cBull, 86), border_color=color.new(cBull, 50))

    entryLine := line.new(bar_index, entry, bar_index + 40, entry, color=color.white, width=2)
    slLine := line.new(bar_index, sl, bar_index + 40, sl, color=cBear, width=2)
    tp1Line := line.new(bar_index, tp1, bar_index + 40, tp1, color=cBull, style=line.style_dashed)
    tp2Line := line.new(bar_index, tp2, bar_index + 40, tp2, color=cBull, style=line.style_dashed, width=2)

    tradeLabel := label.new(bar_index, high, "SHORT\nApex " + str.tostring(bearScore) + "/13", style=label.style_label_down, color=color.new(cBear, 0), textcolor=color.white, size=size.small)

//====================
// PANEL
//====================
var table panel = table.new(position.top_right, 2, 9, bgcolor=color.new(#070810, 12), border_color=color.new(#1a1d2e, 0), border_width=1)

if barstate.islast and showPanel
    biasTxt = htfBull ? "BULLISH" : htfBear ? "BEARISH" : "NEUTRAL"
    biasCol = htfBull ? cBull : htfBear ? cBear : color.gray
    tradeTxt = longSignal ? "LONG" : shortSignal ? "SHORT" : "WAIT"
    tradeCol = longSignal ? cBull : shortSignal ? cBear : color.gray
    scoreTxt = htfBull ? str.tostring(bullScore) + "/13" : str.tostring(bearScore) + "/13"

    waitReason = not sessionOK ? "Session" : htfBull and bullScore < 8 ? "Need Bull Stack" : htfBear and bearScore < 8 ? "Need Bear Stack" : "Scanning"

    table.cell(panel, 0, 0, "APEX v14", bgcolor=#2962ff, text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, "CLEAN", bgcolor=#2962ff, text_color=color.white, text_size=size.small)
    table.cell(panel, 0, 1, "Bias", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 1, biasTxt, text_color=biasCol, text_size=size.small)
    table.cell(panel, 0, 2, "Action", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 2, tradeTxt, text_color=tradeCol, text_size=size.small)
    table.cell(panel, 0, 3, "Score", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 3, scoreTxt, text_color=tradeCol, text_size=size.small)
    table.cell(panel, 0, 4, "Session", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 4, sessionTxt, text_color=sessionOK ? cBull : color.gray, text_size=size.small)
    table.cell(panel, 0, 5, "FVG", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 5, inBullFVG ? "BULL" : inBearFVG ? "BEAR" : "-", text_color=inBullFVG ? cBull : inBearFVG ? cBear : color.gray, text_size=size.small)
    table.cell(panel, 0, 6, "OB", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 6, inBullOB ? "BULL" : inBearOB ? "BEAR" : "-", text_color=inBullOB ? cBull : inBearOB ? cBear : color.gray, text_size=size.small)
    table.cell(panel, 0, 7, "OTE", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 7, oteTxt, text_color=oteTxt == "-" ? color.gray : cGold, text_size=size.small)
    table.cell(panel, 0, 8, "Wait", text_color=color.gray, text_size=size.small)
    table.cell(panel, 1, 8, waitReason, text_color=color.gray, text_size=size.small)

//====================
// ALERTS
//====================
alertcondition(longSignal, "APEX v14 LONG", "APEX v14 CLEAN LONG")
alertcondition(shortSignal, "APEX v14 SHORT", "APEX v14 CLEAN SHORT")
````
