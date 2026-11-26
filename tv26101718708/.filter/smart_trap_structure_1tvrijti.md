# Smart Trap Structure

- url: https://www.tradingview.com/script/1TVRIJTI-Smart-Trap-Structure/
- type: indicator
- pine_id: PUB;6d1b64f0127f4263b01fd54ecad3e4fe
- version: 2.0

## Description

Smart Trap Structure (STS)

The Smart Trap Structure (STS) is an advanced institutional and structural trading indicator designed to filter out market noise, identify deep liquidity hunts (traps), and track the true directional intent of the market.

Unlike standard market structure scripts that clutter the chart with endless BOS (Break of Structure) and CHoCH (Change of Character) labels, STS utilizes an exclusive "Active Setup Cycle" logic. This ensures that you only see the most relevant price ranges and confirmation points for the current market phase.

https://www.tradingview.com/x/xmgRx1FS/

Key Features:

The Decision Line (Orange Retest Line):
Whenever a valid CHoCH occurs, an active orange "Decision Line" is projected forward. This line acts as the ultimate truth for the setup. If price violently pierces this line, it is often hunting for stop-losses (Smart Money Trap) before continuing in the intended direction.
Reaction Zones (HH & LL Boxes):
Instead of just drawing wicks, STS dynamically maps the extreme Highest Highs (HH) and Lowest Lows (LL) of a confirmed structural phase using shaded Reaction Zone boxes (from the absolute wick to the body). These zones act as highly reactive supply and demand areas for future retests.
Dynamic Fibonacci Engine:
STS features a built-in Fibonacci drawing tool that automatically anchors to the confirmed extremes (HH to LL or LL to HH) of the active setup phase. It perfectly projects structural retracement and extension levels (0, 0.236, 0.382, 0.618, 0.764, 1.0, 1.382, 1.618). When Fibo mode is active, it automatically hides unnecessary historical dotted lines for maximum chart clarity.
Clean Chart Mechanics:
You will never suffer from "indicator fatigue". When the structure shifts, the indicator forcefully deletes old, irrelevant lines, reaction boxes, and labels from past cycles. Only the active CHoCH label remains standard-sized, while internal BOS events are scaled down to keep your chart visually clean.
Integrated MA & VWAP:
Toggle the built-in VWAP and select from a variety of Moving Averages (SMA, EMA, WMA, HMA, VWMA) straight from the settings without needing an extra indicator slot on your chart.
Disclaimer:
This script is provided for educational and analytical purposes only. Past performance does not guarantee future results. The script does not constitute financial advice. Always use proper risk management and execute trades based on your own comprehensive market analysis.

## Source Code

````pine
//@version=6
// erdensedat- Smart Trap Structure
indicator("Smart Trap Structure", shorttitle="STS", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== WATERMARK ====================
var table wm = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wm, 0, 0, "erdensedat", text_color=color.new(color.gray, 80), text_size=size.huge)

//==================== CORE ====================
grpCore = "Core"
len         = input.int(10, "Fractal Length (odd)", minval=3, maxval=51, group=grpCore)
barsToRight = input.int(1, "Bars to Right", minval=1, maxval=300, group=grpCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

//==================== SETUPS & CLEAN MODE ====================
grpSetups = "Setups & Visibility"
maxSetups    = input.int(1, "Show Last N Setups (1 = Active Only)", minval=1, maxval=50, group=grpSetups)
showDotted   = input.bool(true, "Show Dotted CHoCH Lines", group=grpSetups)
showReaction = input.bool(true, "Show Reaction Zones (Boxes)", group=grpSetups)

//==================== FIBONACCI ====================
grpFib = "Fibonacci Levels"
showFib   = input.bool(true, "Show Fibonacci Levels", group=grpFib) // Default ON
fibCol    = input.color(color.rgb(82, 114, 190), "Fibonacci Line Color (#5272be)", group=grpFib)
fibTxtCol = input.color(color.rgb(120, 160, 255), "Fibonacci Text Color (#78a0ff)", group=grpFib)

//==================== SWEEP WICK RETURN ====================
grpSweep = "Sweep Wick Return"
showSweep    = input.bool(true, "Show Sweep Wick Return Boxes", group=grpSweep)
sweepBullCol = input.color(color.new(color.green, 85), "Sweep Bullish Color", group=grpSweep)
sweepBearCol = input.color(color.new(color.red, 85), "Sweep Bearish Color", group=grpSweep)

//==================== PERFORMANCE ====================
grpPerf = "Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)

//==================== BROKEN STYLE ====================
grpBrk = "Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpBrk)
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)
brkW       = input.int(1, "BOS Width (CHoCH +1)", minval=1, maxval=5, group=grpBrk)
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk)

//==================== DECISION LINE (RETEST) ====================
grpDec = "Decision Line (Retest)"
decCol     = input.color(color.orange, "Decision Line Color", group=grpDec)
decW       = input.int(2, "Decision Line Width", minval=1, maxval=10, group=grpDec)
decStyleS  = input.string("Solid", "Decision Line Style", options=["Solid","Dashed","Dotted"], group=grpDec)

//==================== REACTION ZONES (HH/LL) ====================
grpRange = "Reaction Zones"
rangeCol  = input.color(color.blue, "Reaction Zone Color", group=grpRange)

//==================== LABELS ====================
grpLbl = "BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color (#089981)", group=grpLbl)
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

//==================== MOVING AVERAGES ====================
grpMA = "Moving Averages & VWAP"
showVwap = input.bool(false, "Show VWAP", group=grpMA)
maType   = input.string("None", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "None"], group=grpMA)
maLen    = input.int(50, "MA Length", minval=1, group=grpMA)
maCol    = input.color(color.new(color.gray, 0), "MA Color", group=grpMA)

//==================== HELPERS ====================
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

//==================== PERF GATE ====================
inCalc = true
if calcLastBars == 0
    inCalc := true
else
    inCalc := bar_index >= last_bar_index - calcLastBars

//==================== ODD LEN + P ====================
L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)

//==================== TIME EXTEND ====================
tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight
brkStyle = f_ls(brkStyleS)
decStyle = f_ls(decStyleS)

bosLbSize   = size.tiny
chochLbSize = size.normal

//==================== PIVOTS ====================
phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

//==================== STATE ====================
var float upLvl = na
var int   upT   = na
var bool  upBroken = false

var float dnLvl = na
var int   dnT   = na
var bool  dnBroken = false

var int os = 0  // last break direction: +1 up, -1 down, 0 none

//==================== SETUP MANAGEMENT (UDT) ====================
type Phase
    int dir
    line chochLine
    label chochLabel
    line[] bosLines
    label[] bosLabels
    line orangeLine
    line dottedLine
    box rxBox
    box wickBox
    label wickLabel

var Phase[] phases = array.new<Phase>()
if barstate.isfirst
    array.push(phases, Phase.new(0, na, na, array.new_line(), array.new_label(), na, na, na, na, na))

var float tempHH = na
var int   tempHHT = na
var float tempHHBody = na

var float tempLL = na
var int   tempLLT = na
var float tempLLBody = na

// For Fibonacci
var float lastLockedHH = na
var float lastLockedLL = na
var line[] activeFibLines = array.new_line()
var label[] activeFibLabels = array.new_label()
var float[] fibLevels = array.from(0.0, 0.236, 0.382, 0.618, 0.764, 1.0, 1.382, 1.618)
var string[] fibNames = array.from("0", "0.236", "0.382", "0.618", "0.764", "1", "1.382", "1.618")

f_trimPhases() =>
    int maxAllowed = (maxSetups * 2) + 1
    while array.size(phases) > maxAllowed
        Phase old = array.shift(phases)
        if not na(old.chochLine)
            line.delete(old.chochLine)
        if not na(old.chochLabel)
            label.delete(old.chochLabel)
        for l in old.bosLines
            line.delete(l)
        for l in old.bosLabels
            label.delete(l)
        if not na(old.orangeLine)
            line.delete(old.orangeLine)
        if not na(old.dottedLine)
            line.delete(old.dottedLine)
        if not na(old.rxBox)
            box.delete(old.rxBox)
        if not na(old.wickBox)
            box.delete(old.wickBox)
        if not na(old.wickLabel)
            label.delete(old.wickLabel)

f_drawFibs() =>
    if showFib and not na(lastLockedHH) and not na(lastLockedLL)
        for ln in activeFibLines
            line.delete(ln)
        for lb in activeFibLabels
            label.delete(lb)
        array.clear(activeFibLines)
        array.clear(activeFibLabels)
        
        float diff = lastLockedHH - lastLockedLL
        
        for i = 0 to array.size(fibLevels) - 1
            float lvlMult = array.get(fibLevels, i)
            string lvlName = array.get(fibNames, i)
            
            float yVal = na
            if os == 1
                yVal := lastLockedLL + (diff * lvlMult)
            else
                yVal := lastLockedHH - (diff * lvlMult)
                
            ln = line.new(time, yVal, time + extMs, yVal, xloc=xloc.bar_time, color=fibCol, style=line.style_solid, width=1)
            lb = label.new(time + extMs, yVal, lvlName, xloc=xloc.bar_time, style=label.style_label_left, textcolor=fibTxtCol, color=color.new(color.white, 100), size=size.small)
            
            array.push(activeFibLines, ln)
            array.push(activeFibLabels, lb)

//==================== UPDATE PIVOTS ====================
if inCalc
    if phHit
        upLvl := phVal
        upT   := time[p]
        upBroken := false

    if plHit
        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false

//==================== BREAK CONDITIONS ====================
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

//==================== TRACK TEMP HH / LL ====================
if inCalc
    if os == 1
        if na(tempHH) or high > tempHH
            tempHH := high
            tempHHT := time
            tempHHBody := math.max(open, close)

    if os == -1
        if na(tempLL) or low < tempLL
            tempLL := low
            tempLLT := time
            tempLLBody := math.min(open, close)

//==================== EXTEND ACTIVE LINES/BOXES ====================
if inCalc
    for p_obj in phases
        if not na(p_obj.dottedLine)
            line.set_x2(p_obj.dottedLine, time + extMs)
        if not na(p_obj.rxBox)
            box.set_right(p_obj.rxBox, time + extMs)
        if not na(p_obj.wickBox)
            box.set_right(p_obj.wickBox, time + extMs)
        if not na(p_obj.wickLabel)
            label.set_x(p_obj.wickLabel, time + extMs)
            
    Phase act = array.get(phases, array.size(phases) - 1)
    if not na(act.orangeLine)
        line.set_x2(act.orangeLine, time + extMs)
        
    if showFib
        for ln in activeFibLines
            line.set_x2(ln, time + extMs)
        for lb in activeFibLabels
            label.set_x(lb, time + extMs)

//==================== APPLY BREAKS ====================
if inCalc
    if brkUp
        upBroken := true
        isChoch = (os == -1 or os == 0)
        
        if isChoch
            Phase activePhase = array.get(phases, array.size(phases) - 1)
            
            if activePhase.dir != 0
                if not na(activePhase.chochLabel)
                    label.set_size(activePhase.chochLabel, size.tiny)
                // HIDE SWEEP WICK RETURN FROM PAST SETUP
                if not na(activePhase.wickBox)
                    box.delete(activePhase.wickBox)
                if not na(activePhase.wickLabel)
                    label.delete(activePhase.wickLabel)

            if activePhase.dir == -1
                if not na(activePhase.orangeLine)
                    line.set_x2(activePhase.orangeLine, time)
                    
                if showDotted and not showFib and not na(activePhase.orangeLine)
                    float lvl = line.get_y1(activePhase.orangeLine)
                    activePhase.dottedLine := line.new(time, lvl, time + extMs, lvl, xloc=xloc.bar_time, color=brkDnCol, style=line.style_dotted, width=1)
                    
                if showReaction and not na(tempLL)
                    activePhase.rxBox := box.new(tempLLT, tempLLBody, time + extMs, tempLL, xloc=xloc.bar_time, border_color=rangeCol, bgcolor=color.new(rangeCol, 85), text="Reaction Zone", text_size=size.tiny, text_color=rangeCol, text_halign=text.align_right, text_valign=text.align_bottom)

            // Lock LL for Fibs
            if not na(tempLL)
                lastLockedLL := tempLL

            tempHH := high
            tempHHT := time
            tempHHBody := math.max(open, close)
            
            line cl = line.new(upT, upLvl, time, upLvl, xloc=xloc.bar_time, color=brkUpCol, style=brkStyle, width=brkW+1)
            label clb = na
            if lbOn
                clb := label.new(int(math.avg(time, upT)), upLvl, "CHoCH", xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=chochLbSize)
                
            line ol = line.new(time, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, color=decCol, width=decW, style=decStyle)
            
            box wBox = na
            label wLbl = na
            if showSweep
                float wTop = math.min(open, close)
                float wBot = low
                wBox := box.new(time, wTop, time + extMs, wBot, xloc=xloc.bar_time, border_color=na, bgcolor=sweepBullCol)
                wLbl := label.new(time + extMs, math.avg(wTop, wBot), "sweep wick return", xloc=xloc.bar_time, textcolor=color.white, color=color.new(color.white, 100), size=size.small, style=label.style_label_left)
            
            Phase newPhase = Phase.new(1, cl, clb, array.new_line(), array.new_label(), ol, na, na, wBox, wLbl)
            array.push(phases, newPhase)
            
        else
            Phase act = array.get(phases, array.size(phases) - 1)
            line bl = line.new(upT, upLvl, time, upLvl, xloc=xloc.bar_time, color=brkUpCol, style=brkStyle, width=brkW)
            label blb = na
            if lbOn
                blb := label.new(int(math.avg(time, upT)), upLvl, "BOS", xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=bosLbSize)
            array.push(act.bosLines, bl)
            array.push(act.bosLabels, blb)
            
        os := 1
        f_trimPhases()
        if isChoch
            f_drawFibs()

    if brkDn
        dnBroken := true
        isChoch = (os == 1 or os == 0)
        
        if isChoch
            Phase activePhase = array.get(phases, array.size(phases) - 1)
            
            if activePhase.dir != 0
                if not na(activePhase.chochLabel)
                    label.set_size(activePhase.chochLabel, size.tiny)
                // HIDE SWEEP WICK RETURN FROM PAST SETUP
                if not na(activePhase.wickBox)
                    box.delete(activePhase.wickBox)
                if not na(activePhase.wickLabel)
                    label.delete(activePhase.wickLabel)

            if activePhase.dir == 1
                if not na(activePhase.orangeLine)
                    line.set_x2(activePhase.orangeLine, time)
                    
                if showDotted and not showFib and not na(activePhase.orangeLine)
                    float lvl = line.get_y1(activePhase.orangeLine)
                    activePhase.dottedLine := line.new(time, lvl, time + extMs, lvl, xloc=xloc.bar_time, color=brkUpCol, style=line.style_dotted, width=1)
                    
                if showReaction and not na(tempHH)
                    activePhase.rxBox := box.new(tempHHT, tempHH, time + extMs, tempHHBody, xloc=xloc.bar_time, border_color=rangeCol, bgcolor=color.new(rangeCol, 85), text="Reaction Zone", text_size=size.tiny, text_color=rangeCol, text_halign=text.align_right, text_valign=text.align_top)

            // Lock HH for Fibs
            if not na(tempHH)
                lastLockedHH := tempHH

            tempLL := low
            tempLLT := time
            tempLLBody := math.min(open, close)
            
            line cl = line.new(dnT, dnLvl, time, dnLvl, xloc=xloc.bar_time, color=brkDnCol, style=brkStyle, width=brkW+1)
            label clb = na
            if lbOn
                clb := label.new(int(math.avg(time, dnT)), dnLvl, "CHoCH", xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=chochLbSize)
                
            line ol = line.new(time, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, color=decCol, width=decW, style=decStyle)
            
            box wBox = na
            label wLbl = na
            if showSweep
                float wTop = high
                float wBot = math.max(open, close)
                wBox := box.new(time, wTop, time + extMs, wBot, xloc=xloc.bar_time, border_color=na, bgcolor=sweepBearCol)
                wLbl := label.new(time + extMs, math.avg(wTop, wBot), "sweep wick return", xloc=xloc.bar_time, textcolor=color.white, color=color.new(color.white, 100), size=size.small, style=label.style_label_left)
            
            Phase newPhase = Phase.new(-1, cl, clb, array.new_line(), array.new_label(), ol, na, na, wBox, wLbl)
            array.push(phases, newPhase)
            
        else
            Phase act = array.get(phases, array.size(phases) - 1)
            line bl = line.new(dnT, dnLvl, time, dnLvl, xloc=xloc.bar_time, color=brkDnCol, style=brkStyle, width=brkW)
            label blb = na
            if lbOn
                blb := label.new(int(math.avg(time, dnT)), dnLvl, "BOS", xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=bosLbSize)
            array.push(act.bosLines, bl)
            array.push(act.bosLabels, blb)

        os := -1
        f_trimPhases()
        if isChoch
            f_drawFibs()

//==================== PLOT MA & VWAP ====================
plot(showVwap ? ta.vwap : na, "VWAP", color=color.blue, linewidth=1)

float maVal = na
if maType == "SMA"
    maVal := ta.sma(close, maLen)
else if maType == "EMA"
    maVal := ta.ema(close, maLen)
else if maType == "WMA"
    maVal := ta.wma(close, maLen)
else if maType == "HMA"
    maVal := ta.hma(close, maLen)
else if maType == "VWMA"
    maVal := ta.vwma(close, maLen)

plot(maType != "None" ? maVal : na, "Moving Average", color=maCol, linewidth=1)
````
