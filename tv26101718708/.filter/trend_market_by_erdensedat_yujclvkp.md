# Trend Market by erdensedat

- url: https://www.tradingview.com/script/yUJcLvkP-Trend-Market-by-erdensedat/
- type: indicator
- pine_id: PUB;c8180681593d419e9a73b2121598653e
- version: 1.0

## Description

This indicator ("Trend Market") is a highly comprehensive trading system that brings together modern Smart Money Concepts (SMC), Price Action analysis, and dynamic trend structures under one roof. Breaking away from the lagging nature of traditional indicators, it focuses entirely on the real-time market structure dictated by price itself.

Here are the core features of the indicator and what they mean for your trading:

1. Market Structure (MS) Breakouts
The indicator instantly detects shifts in market structure. When price breaks through previous lower highs or higher lows, it labels them as BOS (Break of Structure) to indicate trend continuation, or CHoCH (Change of Character) at points where the trend changes direction. These breakouts are the most fundamental Price Action components for understanding where the price wants to go.

2. Order Blocks and High-Probability Entries (Re-Tests)
When a BOS or CHoCH occurs, the indicator automatically draws "Order Block" zones, which highlight where the institutional volume that initiated the breakout is concentrated.

Why it matters: Order Blocks (OB) are areas where "smart money" enters the market with large volume. After these breakouts, price often retraces (re-tests) these zones to grab liquidity. Entering a trade when a trend-aligned Order Block is tested provides the highest risk-to-reward (R/R) ratio and the most robust, reliable entry opportunities (sniper entries).
3. FVG (Fair Value Gaps)
The indicator detects FVGs, which represent imbalances in the market.

Why it matters: FVGs occur during rapid, high-volume price movements when there is an imbalance between buyers and sellers. FVGs formed at the beginning of a new trend (especially alongside a CHoCH) confirm the strength of that trend. FVGs formed while a trend is ongoing act as magnets for the price during pullbacks, serving as potential support/resistance and target areas.
4. Ghost Trend Engine
Unlike traditional static trendlines, this feature calculates the slopes of price wicks to generate dynamic trendlines that adapt to the market's momentum. It draws both Minor (Ghost) and Major (Confirm) resistance and support slopes.

The Confirmation Mechanism: If price bounces off one of these dynamic Ghost/Confirm trendlines during an Order Block re-test or an FVG fill, your entry signal becomes "double confirmed." Furthermore, when these trendlines are broken, they serve as early warning signs of an impending trend reversal.
5. Dynamic TP (Take Profit) Machine (Infinite Fibonacci)
It plots automatic Fibonacci extension levels calculated from your entry point (CHoCH/BOS) and the peak/trough of the current structure.

How it works: As price hits these targets (TP1, TP2, etc.), the indicator automatically extends the targets higher/lower, creating an infinite sequence of Take Profit levels. No matter how far a trend extends, your potential target levels will always be ready on your chart.
Summary: How to Trade with It?
Determine the market direction using the CHoCH and BOS labels.
Don't rush in immediately after a breakout; wait for the price to retrace (Re-test) into the Order Block (OB) or FVG zones.
When price reaches these zones, observe the reaction from the Ghost Trend lines to confirm that the trend will continue.
Once you enter a trade, use the automatically generated Dynamic TP levels for scaled profit-taking.
Disclaimer
This indicator is designed for educational, analytical, and informational purposes only. The signals, labels, or support/resistance zones provided do not constitute financial or investment advice. Trading cryptocurrencies, stocks, and forex involves a high degree of risk and can result in the loss of your entire capital. All trades taken using this indicator are strictly at your own risk and responsibility. Please ensure you apply your own risk management and trading plan.

## Source Code

````pine
//@version=6
indicator("Trend Market by erdensedat", shorttitle="Trend Market", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== TYPES ====================
type OB
    box b
    label lbl
    float top
    float bot
    int dir
    bool active

//==================== MS (BLVL) INPUTS ====================
grpCore = "MS Core"
len         = input.int(10, "Fractal Length (odd)", minval=3, maxval=51, group=grpCore)
barsToRightMS = input.int(7, "Bars to Right", minval=1, maxval=300, group=grpCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

grpPerf = "MS Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
showLastN    = input.int(3, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

grpBrk = "MS Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color", group=grpBrk)
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk)

grpLbl = "MS BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color", group=grpLbl)
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

//==================== TP MACHINE INPUTS ====================
grpTP = "TP Machine (Pro Features)"
showFibTP = input.bool(true, "Auto Infinite Fibonacci TP Levels", group=grpTP)
showOB = input.bool(true, "Show Order Blocks (Re-test Zones)", group=grpTP)
showFVG = input.bool(true, "Show Fair Value Gaps (FVG)", group=grpTP)

obBullCol = input.color(color.new(color.rgb(8,153,129), 85), "Bullish OB Color", group=grpTP)
obBearCol = input.color(color.new(color.red, 85), "Bearish OB Color", group=grpTP)

fvgBullCol = input.color(color.new(color.blue, 85), "Bullish FVG Color", group=grpTP)
fvgBearCol = input.color(color.new(color.orange, 85), "Bearish FVG Color", group=grpTP)

//==================== ALERTS INPUTS ====================
grpAlerts = "Alert Settings"
alLongEntry = input.bool(true, "Alert: Long Entry Triggered", group=grpAlerts)
alShortEntry = input.bool(true, "Alert: Short Entry Triggered", group=grpAlerts)
alBullOB = input.bool(true, "Alert: Bullish OB in Main Bullish Trend", group=grpAlerts)
alBearOB = input.bool(true, "Alert: Bearish OB in Main Bearish Trend", group=grpAlerts)

//==================== GHOST TREND INPUTS ====================
grpGT = "Ghost Trend Settings"
ghostLen = input.int(5, "Ghost Pivot Len", minval=1, maxval=10, group=grpGT)
confLen = input.int(20, "Confirm Pivot Len", minval=2, maxval=50, group=grpGT)
barsToRightGT = input.int(3, "Bars To Right (Trends)", minval=1, maxval=50, group=grpGT)
slopeMult = input.float(1.0, "Slope Mult (Esneklik)", minval=0.1, maxval=5.0, step=0.1, group=grpGT)

showHzLines = input.bool(true, "Show Horizontal S/R Lines", group=grpGT)

grpGhostHigh = "Ghost High Line"
ghHighCol = input.color(color.new(#f23645, 20), "Color", group=grpGhostHigh)
ghHighWidth = input.int(2, "Width", minval=1, maxval=5, group=grpGhostHigh)
ghHighStyleOpt = input.string("Dashed", "Style", options=["Solid", "Dotted", "Dashed"], group=grpGhostHigh)

grpConfHigh = "Confirm High Line"
cfHighCol = input.color(color.new(#f23645, 0), "Color", group=grpConfHigh)
cfHighWidth = input.int(3, "Width", minval=1, maxval=5, group=grpConfHigh)
cfHighStyleOpt = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], group=grpConfHigh)

grpGhostLow = "Ghost Low Line"
ghLowCol = input.color(color.new(#089981, 20), "Color", group=grpGhostLow)
ghLowWidth = input.int(2, "Width", minval=1, maxval=5, group=grpGhostLow)
ghLowStyleOpt = input.string("Dashed", "Style", options=["Solid", "Dotted", "Dashed"], group=grpGhostLow)

grpConfLow = "Confirm Low Line"
cfLowCol = input.color(color.new(#089981, 0), "Color", group=grpConfLow)
cfLowWidth = input.int(3, "Width", minval=1, maxval=5, group=grpConfLow)
cfLowStyleOpt = input.string("Solid", "Style", options=["Solid", "Dotted", "Dashed"], group=grpConfLow)

//==================== INDICATORS INPUTS ====================
grpInd = "Additional Indicators"
showVwap = input.bool(false, "Show Session VWAP", group=grpInd)
vwapCol = input.color(color.purple, "VWAP Color", group=grpInd)

showMa1 = input.bool(false, "Show MA 1", group=grpInd, inline="ma1")
ma1Type = input.string("EMA", "", options=["SMA", "EMA", "WMA", "RMA"], group=grpInd, inline="ma1")
ma1Len = input.int(50, "Len", minval=1, group=grpInd, inline="ma1")
ma1Col = input.color(color.blue, "", group=grpInd, inline="ma1")

showMa2 = input.bool(false, "Show MA 2", group=grpInd, inline="ma2")
ma2Type = input.string("SMA", "", options=["SMA", "EMA", "WMA", "RMA"], group=grpInd, inline="ma2")
ma2Len = input.int(200, "Len", minval=1, group=grpInd, inline="ma2")
ma2Col = input.color(color.orange, "", group=grpInd, inline="ma2")

//==================== HELPERS ====================
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

getTPMult(int n) =>
    n % 2 != 0 ? (n - 1) / 2 + 0.618 : n / 2.0

f_getMA(string type, int length) =>
    switch type
        "SMA" => ta.sma(close, length)
        "EMA" => ta.ema(close, length)
        "WMA" => ta.wma(close, length)
        "RMA" => ta.rma(close, length)
        => ta.sma(close, length)

f_getWickSlopeHigh(len) =>
    startY = high[len]
    float maxSlope = na
    for i = 1 to len
        slp = (high[len - i] - startY) / i
        if na(maxSlope) or slp > maxSlope
            maxSlope := slp
    nz(maxSlope, 0.0)

f_getWickSlopeLow(len) =>
    startY = low[len]
    float minSlope = na
    for i = 1 to len
        slp = (low[len - i] - startY) / i
        if na(minSlope) or slp < minSlope
            minSlope := slp
    nz(minSlope, 0.0)

// Dynamic Y-Axis Offset for Labels
f_getYOffset(lvl, step, dir, index) =>
    lvl + (dir * step * ta.atr(14) * 0.5 * index)

//==================== INDICATORS LOGIC ====================
v_vwap = ta.vwap
plot(showVwap ? v_vwap : na, "VWAP", color=vwapCol, linewidth=2)

ma1 = f_getMA(ma1Type, ma1Len)
plot(showMa1 ? ma1 : na, "MA 1", color=ma1Col, linewidth=2)

ma2 = f_getMA(ma2Type, ma2Len)
plot(showMa2 ? ma2 : na, "MA 2", color=ma2Col, linewidth=2)

//==================== MS LOGIC ====================
inCalc = true
if calcLastBars == 0
    inCalc := true
else
    inCalc := bar_index >= last_bar_index - calcLastBars

L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)

tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRightMS

brkStyle  = f_ls(brkStyleS)
lbSize    = f_sz(lbSzS)

phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

var float upLvl = na
var int   upT   = na
var bool  upBroken = false

var float dnLvl = na
var int   dnT   = na
var bool  dnBroken = false

var int os = 0  // 1 = UP, -1 = DOWN

var line[]  brkLines = array.new_line()
var label[] brkLabs  = array.new_label()

f_trimBroken() =>
    if showLastN > 0
        while array.size(brkLines) > showLastN
            line oldLn = array.shift(brkLines)
            label oldLb = array.shift(brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

    while array.size(brkLines) > maxKeep
        line oldLn = array.shift(brkLines)
        label oldLb = array.shift(brkLabs)
        if not na(oldLn)
            line.delete(oldLn)
        if not na(oldLb)
            label.delete(oldLb)

f_pushBroken(line ln, label lb) =>
    array.push(brkLines, ln)
    array.push(brkLabs,  lb)
    f_trimBroken()

//==================== TP MACHINE VARIABLES ====================
var line[] tpLines = array.new_line(2, na)
var label[] tpLabels = array.new_label(2, na)

var line activeChochLine = na
var label activeChochLbl = na

var line activeStopLine = na
var label activeStopLbl = na

var float currentEntry = na
var float currentDist = na
var int currentDir = 0
var int highestTPHit = 0
var int currentMaxTP = 0

var obArray = array.new<OB>()

// FVG Detection
bullFVG = low > high[2] and close[1] > open[1]
bearFVG = high < low[2] and close[1] < open[1]

if inCalc and showFVG
    if bullFVG
        box.new(bar_index - 2, low, bar_index, high[2], border_color=na, bgcolor=fvgBullCol)
    if bearFVG
        box.new(bar_index - 2, low[2], bar_index, high, border_color=na, bgcolor=fvgBearCol)

// Create Candidate Levels Internally
if inCalc
    if phHit
        upLvl := phVal
        upT   := time[p]
        upBroken := false

    if plHit
        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false

brkUp = false
brkDn = false

if inCalc
    if not na(upLvl) and not upBroken
        if requireBody
            brkUp := close > upLvl
        else
            brkUp := high > upLvl

    if not na(dnLvl) and not dnBroken
        if requireBody
            brkDn := close < dnLvl
        else
            brkDn := low < dnLvl

// ALERTS LOGIC
if brkUp
    isBOS = os == 1
    if alLongEntry
        alert("Long Entry Triggered! Price broke above " + str.tostring(upLvl, format.mintick), alert.freq_once_per_bar_close)
    if showOB and isBOS and alBullOB
        alert("Bullish OB created in main Bullish trend line", alert.freq_once_per_bar_close)

if brkDn
    isBOS = os == -1
    if alShortEntry
        alert("Short Entry Triggered! Price broke below " + str.tostring(dnLvl, format.mintick), alert.freq_once_per_bar_close)
    if showOB and isBOS and alBearOB
        alert("Bearish OB created in main Bearish trend line", alert.freq_once_per_bar_close)

if inCalc
    if brkUp
        upBroken := true
        isChoch = os == -1 or os == 0
        
        // CHoCH Entry & Stop Level
        if isChoch
            if not na(activeChochLine)
                line.delete(activeChochLine)
                label.delete(activeChochLbl)
            if not na(activeStopLine)
                line.delete(activeStopLine)
                label.delete(activeStopLbl)
                
            activeChochLine := line.new(bar_index, upLvl, bar_index + barsToRightMS, upLvl, color=brkUpCol, style=line.style_dashed)
            activeChochLbl := label.new(bar_index + barsToRightMS, upLvl, "Long CHoCH Entry", style=label.style_label_left, color=color.new(color.white, 100), textcolor=brkUpCol, size=size.small)
            
            if not na(dnLvl)
                activeStopLine := line.new(bar_index, dnLvl, bar_index + barsToRightMS, dnLvl, color=color.red, style=line.style_dashed)
                activeStopLbl := label.new(bar_index + barsToRightMS, dnLvl, "Stop Level", style=label.style_label_left, color=color.new(color.white, 100), textcolor=color.red, size=size.small)

        // Fib TP Logic
        if not na(dnLvl)
            if showFibTP
                for i = 0 to 1
                    if not na(array.get(tpLines, i))
                        line.delete(array.get(tpLines, i))
                        label.delete(array.get(tpLabels, i))
                        array.set(tpLines, i, na)
                        array.set(tpLabels, i, na)
                
                currentEntry := upLvl
                currentDist := upLvl - dnLvl
                currentDir := 1
                highestTPHit := 0
                currentMaxTP := 2
                
                for i = 0 to 1
                    idx = i + 1
                    lvl = currentEntry + currentDir * currentDist * getTPMult(idx)
                    ln = line.new(bar_index, lvl, bar_index + barsToRightMS, lvl, color=brkUpCol, style=line.style_dashed)
                    ext = getTPMult(idx) + 1.0
                    lb = label.new(bar_index + barsToRightMS, lvl, "TP" + str.tostring(idx) + " (" + str.tostring(ext) + ")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=brkUpCol, size=size.small)
                    array.set(tpLines, i, ln)
                    array.set(tpLabels, i, lb)

        // Order Block Creation
        if showOB
            obIdx = bar_index
            obHigh = high
            obLow = low
            for i = 1 to L * 2
                if close[i] < open[i]
                    obIdx := bar_index[i]
                    obHigh := high[i]
                    obLow := low[i]
                    break
            bx = box.new(obIdx, obHigh, bar_index + barsToRightMS, obLow, border_color=na, bgcolor=obBullCol)
            lbl = label.new(bar_index + barsToRightMS, math.avg(obHigh, obLow), "OB", style=label.style_label_left, color=color.new(color.white, 100), textcolor=brkUpCol, size=size.small)
            array.push(obArray, OB.new(bx, lbl, obHigh, obLow, 1, true))
            
            if array.size(obArray) > 10
                oldOB = array.shift(obArray)
                box.delete(oldOB.b)
                if not na(oldOB.lbl)
                    label.delete(oldOB.lbl)

        upLine = line.new(upT, upLvl, time, upLvl, xloc=xloc.bar_time, color=brkUpCol, style=brkStyle, width=brkW)

        label lb = na
        if lbOn
            string txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)

        f_pushBroken(upLine, lb)
        os := 1

    if brkDn
        dnBroken := true
        isChoch = os == 1 or os == 0
        
        // CHoCH Entry & Stop Level
        if isChoch
            if not na(activeChochLine)
                line.delete(activeChochLine)
                label.delete(activeChochLbl)
            if not na(activeStopLine)
                line.delete(activeStopLine)
                label.delete(activeStopLbl)
                
            activeChochLine := line.new(bar_index, dnLvl, bar_index + barsToRightMS, dnLvl, color=brkDnCol, style=line.style_dashed)
            activeChochLbl := label.new(bar_index + barsToRightMS, dnLvl, "Short CHoCH Entry", style=label.style_label_left, color=color.new(color.white, 100), textcolor=brkDnCol, size=size.small)
            
            if not na(upLvl)
                activeStopLine := line.new(bar_index, upLvl, bar_index + barsToRightMS, upLvl, color=color.red, style=line.style_dashed)
                activeStopLbl := label.new(bar_index + barsToRightMS, upLvl, "Stop Level", style=label.style_label_left, color=color.new(color.white, 100), textcolor=color.red, size=size.small)

        // Fib TP Logic
        if not na(upLvl)
            if showFibTP
                for i = 0 to 1
                    if not na(array.get(tpLines, i))
                        line.delete(array.get(tpLines, i))
                        label.delete(array.get(tpLabels, i))
                        array.set(tpLines, i, na)
                        array.set(tpLabels, i, na)
                
                currentEntry := dnLvl
                currentDist := upLvl - dnLvl
                currentDir := -1
                highestTPHit := 0
                currentMaxTP := 2
                
                for i = 0 to 1
                    idx = i + 1
                    lvl = currentEntry + currentDir * currentDist * getTPMult(idx)
                    ln = line.new(bar_index, lvl, bar_index + barsToRightMS, lvl, color=brkDnCol, style=line.style_dashed)
                    ext = getTPMult(idx) + 1.0
                    lb = label.new(bar_index + barsToRightMS, lvl, "TP" + str.tostring(idx) + " (" + str.tostring(ext) + ")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=brkDnCol, size=size.small)
                    array.set(tpLines, i, ln)
                    array.set(tpLabels, i, lb)

        // Order Block Creation
        if showOB
            obIdx = bar_index
            obHigh = high
            obLow = low
            for i = 1 to L * 2
                if close[i] > open[i]
                    obIdx := bar_index[i]
                    obHigh := high[i]
                    obLow := low[i]
                    break
            bx = box.new(obIdx, obHigh, bar_index + barsToRightMS, obLow, border_color=na, bgcolor=obBearCol)
            lbl = label.new(bar_index + barsToRightMS, math.avg(obHigh, obLow), "OB", style=label.style_label_left, color=color.new(color.white, 100), textcolor=brkDnCol, size=size.small)
            array.push(obArray, OB.new(bx, lbl, obHigh, obLow, -1, true))
            
            if array.size(obArray) > 10
                oldOB = array.shift(obArray)
                box.delete(oldOB.b)
                if not na(oldOB.lbl)
                    label.delete(oldOB.lbl)

        dnLine = line.new(dnT, dnLvl, time, dnLvl, xloc=xloc.bar_time, color=brkDnCol, style=brkStyle, width=brkW)

        label lb = na
        if lbOn
            string txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)

        f_pushBroken(dnLine, lb)
        os := -1

// Dynamic TP Infinite System & Line Extensions
if showFibTP and currentDir != 0
    hitChanged = false
    while highestTPHit < currentMaxTP
        idx = highestTPHit + 1
        lvl = currentEntry + currentDir * currentDist * getTPMult(idx)
        isHit = currentDir == 1 ? high >= lvl : low <= lvl
        if isHit
            highestTPHit += 1
            hitChanged := true
        else
            break
            
    if highestTPHit == currentMaxTP
        currentMaxTP += 2
        hitChanged := true
        
    if hitChanged
        for i = 0 to 1
            if not na(array.get(tpLines, i))
                line.delete(array.get(tpLines, i))
                label.delete(array.get(tpLabels, i))
                array.set(tpLines, i, na)
                array.set(tpLabels, i, na)
                
        c = currentDir == 1 ? brkUpCol : brkDnCol
        for i = 0 to 1
            idx = highestTPHit + 1 + i
            if idx <= currentMaxTP
                lvl = currentEntry + currentDir * currentDist * getTPMult(idx)
                ln = line.new(bar_index, lvl, bar_index + barsToRightMS, lvl, color=c, style=line.style_dashed)
                ext = getTPMult(idx) + 1.0
                lb = label.new(bar_index + barsToRightMS, lvl, "TP" + str.tostring(idx) + " (" + str.tostring(ext) + ")", style=label.style_label_left, color=color.new(color.white, 100), textcolor=c, size=size.small)
                array.set(tpLines, i, ln)
                array.set(tpLabels, i, lb)
    else
        for i = 0 to 1
            ln = array.get(tpLines, i)
            lb = array.get(tpLabels, i)
            if not na(ln)
                line.set_x2(ln, bar_index + barsToRightMS)
                label.set_x(lb, bar_index + barsToRightMS)

// Active Order Blocks Extension & Break Logic
if array.size(obArray) > 0
    for i = array.size(obArray) - 1 to 0
        OB obj = array.get(obArray, i)
        if obj.active
            isBroken = false
            if obj.dir == 1 and close < obj.bot
                isBroken := true
            else if obj.dir == -1 and close > obj.top
                isBroken := true
                
            if isBroken
                obj.active := false
                box.set_right(obj.b, bar_index) // Freeze the box at the breakout candle
                if not na(obj.lbl)
                    label.delete(obj.lbl) // Clean up label once OB is broken
            else
                box.set_right(obj.b, bar_index + barsToRightMS)
                if not na(obj.lbl)
                    label.set_x(obj.lbl, bar_index + barsToRightMS)

//==================== GHOST TREND LOGIC ====================
ghHighStyle = f_ls(ghHighStyleOpt)
cfHighStyle = f_ls(cfHighStyleOpt)
ghLowStyle = f_ls(ghLowStyleOpt)
cfLowStyle = f_ls(cfLowStyleOpt)

gPH = ta.pivothigh(high, ghostLen, ghostLen)
gPL = ta.pivotlow(low, ghostLen, ghostLen)
cPH = ta.pivothigh(high, confLen, confLen)
cPL = ta.pivotlow(low, confLen, confLen)

var line ghHighLine = na
var line ghHighHzLine = na
var label ghHighHzLbl = na
var float ghHighLevel = na
var float ghHighStartY = na
var float ghHighSlope = na
var int ghHighX1 = na

var line cfHighLine = na
var line cfHighHzLine = na
var label cfHighHzLbl = na
var float cfHighLevel = na
var float cfHighStartY = na
var float cfHighSlope = na
var int cfHighX1 = na

var line ghLowLine = na
var line ghLowHzLine = na
var label ghLowHzLbl = na
var float ghLowLevel = na
var float ghLowStartY = na
var float ghLowSlope = na
var int ghLowX1 = na

var line cfLowLine = na
var line cfLowHzLine = na
var label cfLowHzLbl = na
var float cfLowLevel = na
var float cfLowStartY = na
var float cfLowSlope = na
var int cfLowX1 = na

atr14 = ta.atr(14)

if not na(gPH)
    if not na(ghHighLine)
        line.delete(ghHighLine)
    if not na(ghHighHzLine)
        line.delete(ghHighHzLine)
    if not na(ghHighHzLbl)
        label.delete(ghHighHzLbl)
        
    startY = high[ghostLen]
    actualSlope = f_getWickSlopeHigh(ghostLen)
    
    ghHighLevel := gPH
    ghHighStartY := startY
    ghHighSlope := actualSlope * slopeMult
    ghHighX1 := bar_index - ghostLen
    
    initialX2 = bar_index
    initialY2 = startY + ghHighSlope * (initialX2 - ghHighX1)
    
    ghHighLine := line.new(ghHighX1, startY, initialX2, initialY2, color=na, width=ghHighWidth, style=ghHighStyle)
    if showHzLines
        ghHighHzLine := line.new(ghHighX1, startY, initialX2, startY, color=na, width=1, style=line.style_solid)
        ghHighHzLbl := label.new(initialX2, startY, "Minor Res: " + str.tostring(startY, format.mintick), color=color.new(color.white, 100), textcolor=na, style=label.style_label_down, size=size.small)
    
    // Bearish Re-Entry (Lower High)
    if os == -1
        label.new(ghHighX1, startY + (atr14[ghostLen] * 0.2), "▼", style=label.style_none, textcolor=brkDnCol, size=size.tiny)

if not na(cPH)
    if not na(cfHighLine)
        line.delete(cfHighLine)
    if not na(cfHighHzLine)
        line.delete(cfHighHzLine)
    if not na(cfHighHzLbl)
        label.delete(cfHighHzLbl)
        
    startY = high[confLen]
    actualSlope = f_getWickSlopeHigh(confLen)
    
    cfHighLevel := cPH
    cfHighStartY := startY
    cfHighSlope := actualSlope * slopeMult
    cfHighX1 := bar_index - confLen
    
    initialX2 = bar_index
    initialY2 = startY + cfHighSlope * (initialX2 - cfHighX1)
    
    cfHighLine := line.new(cfHighX1, startY, initialX2, initialY2, color=cfHighCol, width=cfHighWidth, style=cfHighStyle)
    if showHzLines
        cfHighHzLine := line.new(cfHighX1, startY, initialX2, startY, color=cfHighCol, width=1, style=line.style_solid)
        cfHighHzLbl := label.new(initialX2, startY, "Major Res: " + str.tostring(startY, format.mintick), color=color.new(color.white, 100), textcolor=cfHighCol, style=label.style_label_down, size=size.small)

if not na(gPL)
    if not na(ghLowLine)
        line.delete(ghLowLine)
    if not na(ghLowHzLine)
        line.delete(ghLowHzLine)
    if not na(ghLowHzLbl)
        label.delete(ghLowHzLbl)
        
    startY = low[ghostLen]
    actualSlope = f_getWickSlopeLow(ghostLen)
    
    ghLowLevel := gPL
    ghLowStartY := startY
    ghLowSlope := actualSlope * slopeMult
    ghLowX1 := bar_index - ghostLen
    
    initialX2 = bar_index
    initialY2 = startY + ghLowSlope * (initialX2 - ghLowX1)
    
    ghLowLine := line.new(ghLowX1, startY, initialX2, initialY2, color=na, width=ghLowWidth, style=ghLowStyle)
    if showHzLines
        ghLowHzLine := line.new(ghLowX1, startY, initialX2, startY, color=na, width=1, style=line.style_solid)
        ghLowHzLbl := label.new(initialX2, startY, "Minor Sup: " + str.tostring(startY, format.mintick), color=color.new(color.white, 100), textcolor=na, style=label.style_label_up, size=size.small)
    
    // Bullish Re-Entry (Higher Low)
    if os == 1
        label.new(ghLowX1, startY - (atr14[ghostLen] * 0.2), "▲", style=label.style_none, textcolor=brkUpCol, size=size.tiny)

if not na(cPL)
    if not na(cfLowLine)
        line.delete(cfLowLine)
    if not na(cfLowHzLine)
        line.delete(cfLowHzLine)
    if not na(cfLowHzLbl)
        label.delete(cfLowHzLbl)
        
    startY = low[confLen]
    actualSlope = f_getWickSlopeLow(confLen)
    
    cfLowLevel := cPL
    cfLowStartY := startY
    cfLowSlope := actualSlope * slopeMult
    cfLowX1 := bar_index - confLen
    
    initialX2 = bar_index
    initialY2 = startY + cfLowSlope * (initialX2 - cfLowX1)
    
    cfLowLine := line.new(cfLowX1, startY, initialX2, initialY2, color=cfLowCol, width=cfLowWidth, style=cfLowStyle)
    if showHzLines
        cfLowHzLine := line.new(cfLowX1, startY, initialX2, startY, color=cfLowCol, width=1, style=line.style_solid)
        cfLowHzLbl := label.new(initialX2, startY, "Major Sup: " + str.tostring(startY, format.mintick), color=color.new(color.white, 100), textcolor=cfLowCol, style=label.style_label_up, size=size.small)

if not na(ghHighLevel) and close > ghHighLevel
    if not na(ghHighLine)
        line.delete(ghHighLine)
        ghHighLine := na
    if not na(ghHighHzLine)
        line.delete(ghHighHzLine)
        ghHighHzLine := na
    if not na(ghHighHzLbl)
        label.delete(ghHighHzLbl)
        ghHighHzLbl := na
    ghHighLevel := na

if not na(cfHighLevel) and close > cfHighLevel
    if not na(cfHighLine)
        line.delete(cfHighLine)
        cfHighLine := na
    if not na(cfHighHzLine)
        line.delete(cfHighHzLine)
        cfHighHzLine := na
    if not na(cfHighHzLbl)
        label.delete(cfHighHzLbl)
        cfHighHzLbl := na
    cfHighLevel := na

if not na(ghLowLevel) and close < ghLowLevel
    if not na(ghLowLine)
        line.delete(ghLowLine)
        ghLowLine := na
    if not na(ghLowHzLine)
        line.delete(ghLowHzLine)
        ghLowHzLine := na
    if not na(ghLowHzLbl)
        label.delete(ghLowHzLbl)
        ghLowHzLbl := na
    ghLowLevel := na

if not na(cfLowLevel) and close < cfLowLevel
    if not na(cfLowLine)
        line.delete(cfLowLine)
        cfLowLine := na
    if not na(cfLowHzLine)
        line.delete(cfLowHzLine)
        cfLowHzLine := na
    if not na(cfLowHzLbl)
        label.delete(cfLowHzLbl)
        cfLowHzLbl := na
    cfLowLevel := na

// Visiblity based on Market Structure break direction
color activeGhHighCol = os == -1 ? ghHighCol : na
color activeGhLowCol  = os ==  1 ? ghLowCol  : na

if not na(ghHighLine)
    newX2 = bar_index
    newY2 = ghHighStartY + ghHighSlope * (newX2 - ghHighX1)
    line.set_x2(ghHighLine, newX2)
    line.set_y2(ghHighLine, newY2)
    line.set_color(ghHighLine, activeGhHighCol)
    line.set_width(ghHighLine, ghHighWidth)
    line.set_style(ghHighLine, ghHighStyle)
    
    if not na(ghHighHzLine)
        line.set_x2(ghHighHzLine, newX2)
        line.set_color(ghHighHzLine, activeGhHighCol)
    if not na(ghHighHzLbl)
        label.set_x(ghHighHzLbl, newX2)
        label.set_y(ghHighHzLbl, ghHighStartY)
        label.set_textcolor(ghHighHzLbl, activeGhHighCol)

if not na(cfHighLine)
    newX2 = bar_index
    newY2 = cfHighStartY + cfHighSlope * (newX2 - cfHighX1)
    line.set_x2(cfHighLine, newX2)
    line.set_y2(cfHighLine, newY2)
    line.set_color(cfHighLine, cfHighCol)
    line.set_width(cfHighLine, cfHighWidth)
    line.set_style(cfHighLine, cfHighStyle)
    
    if not na(cfHighHzLine)
        line.set_x2(cfHighHzLine, newX2)
        line.set_color(cfHighHzLine, cfHighCol)
    if not na(cfHighHzLbl)
        label.set_x(cfHighHzLbl, newX2)
        label.set_y(cfHighHzLbl, cfHighStartY)
        label.set_textcolor(cfHighHzLbl, cfHighCol)

if not na(ghLowLine)
    newX2 = bar_index
    newY2 = ghLowStartY + ghLowSlope * (newX2 - ghLowX1)
    line.set_x2(ghLowLine, newX2)
    line.set_y2(ghLowLine, newY2)
    line.set_color(ghLowLine, activeGhLowCol)
    line.set_width(ghLowLine, ghLowWidth)
    line.set_style(ghLowLine, ghLowStyle)
    
    if not na(ghLowHzLine)
        line.set_x2(ghLowHzLine, newX2)
        line.set_color(ghLowHzLine, activeGhLowCol)
    if not na(ghLowHzLbl)
        label.set_x(ghLowHzLbl, newX2)
        label.set_y(ghLowHzLbl, ghLowStartY)
        label.set_textcolor(ghLowHzLbl, activeGhLowCol)

if not na(cfLowLine)
    newX2 = bar_index
    newY2 = cfLowStartY + cfLowSlope * (newX2 - cfLowX1)
    line.set_x2(cfLowLine, newX2)
    line.set_y2(cfLowLine, newY2)
    line.set_color(cfLowLine, cfLowCol)
    line.set_width(cfLowLine, cfLowWidth)
    line.set_style(cfLowLine, cfLowStyle)
    
    if not na(cfLowHzLine)
        line.set_x2(cfLowHzLine, newX2)
        line.set_color(cfLowHzLine, cfLowCol)
    if not na(cfLowHzLbl)
        label.set_x(cfLowHzLbl, newX2)
        label.set_y(cfLowHzLbl, cfLowStartY)
        label.set_textcolor(cfLowHzLbl, cfLowCol)
````
