# Price Reaction Zones

- url: https://www.tradingview.com/script/4PnsnD7Z-Price-Reaction-Zones/
- type: indicator
- pine_id: PUB;1909da1dabe24b438ffa2aed6bb16af0
- version: 1.0

## Description

Price Reaction Zones (PRZ) is an advanced structural analytics tool designed for traders who focus on market microstructure, dynamic support/resistance levels, and liquidity sweeps. By blending traditional Change of Character (CHoCH) concepts with a custom-engineered "AXIS Motor", this indicator offers dynamic kinetic sensitivity and highly strategic Fibonacci-based target zones.

This script maps out historical structure ranges, isolates liquidity traps (sweeps), and projects tactical ghost vectors to evaluate micro-trend strength.

Key Features:

1. Smart Market Structure & Dynamic Fib Boxes
When a valid Break of Structure (BOS) or Change of Character (CHoCH) occurs, the indicator identifies the absolute extremes (Highest High and Lowest Low wicks) of the most recently broken structure.

Bullish CHoCH (Upward Break): Creates a dynamic Fibonacci box between 0.318 and 0.500 of the previous downward structure.
Bearish CHoCH (Downward Break): Creates a dynamic Fibonacci box between 0.618 and 0.790 of the previous upward structure.
These boxes act as immediate high-probability reaction zones for the very next wave. An Equilibrium (EQ - 0.5) limit line is also drawn to clearly divide the market bias.
2. External Ranges & Liquidity Sweep Detection
Instead of cluttering the chart with every single swing high or low, PRZ calculates an overarching "External Range" based on a lookback of the last 6 structural phases.

It automatically frames a beautiful Price Range Box mapping the exact tick difference and percentage span of the overarching macro structure.
Rejected Wick Logic (Sweeps): If price pierces the external High or Low boundaries but closes inside the range, a permanent "UP" or "DOWN" text is pinned to that wick. This signals a textbook liquidity sweep (a trap for breakout traders) and potential reversal.
Alerts are fully integrated for UP and DOWN sweep detections.
3. The AXIS Engine & Auto-Kinetic Sensitivity
Unlike static trendlines, the integrated AXIS Engine measures the "Velocity" of the market.

Auto-Kinetic Multiplier: By analyzing the real-time sum of bullish vs. bearish momentum (close to open differences) over a rolling window, the script dynamically adjusts the slope sensitivity of the resistance and support lines entirely independent of one another.
Tactical Ghost Vectors: Projects subtle, short-term momentum paths (Minor Lookbacks) to help you visualize the micro-trend inside the macro-structure, offering early warnings of momentum shifts before structural breaks happen.
4. Highly Customizable Interface
You have complete control over visualization. Tweak kinetic multipliers manually, adjust lookback lengths, alter Fibonacci box colors, and toggle lines to keep your chart as clean or as detailed as you prefer. A minimalist "erdensedat" watermark is embedded dynamically on the chart.

How to Use:

Use the Fibonacci boxes inside the latest active CHoCH range to enter pullbacks.
Watch the boundaries of the macro Price Range Box. Enter mean-reversion trades when "UP" or "DOWN" liquidity sweep labels appear.
Utilize the AXIS lines to trail your stops dynamically based on the current market velocity.
Disclaimer:
This indicator is designed for educational and analytical purposes only. It does not constitute financial advice. Trading in financial markets involves significant risk. The concepts of market structure, CHoCH, and liquidity sweeps are interpretive; always combine this tool with your own risk management strategy and other confluences. Past performance of any setup does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Price Reaction Zones", shorttitle="PRZ", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== WATERMARK ====================
var table wm = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wm, 0, 0, "erdensedat", text_color=color.new(color.gray, 85), text_size=size.huge)

//==================== AXIS ENGINE INPUTS ====================
groupMajor  = "Major Structure (AXIS)"
axisLookback= input.int(8, "Major Lookback", minval=2, maxval=20, group=groupMajor)
axisLength  = input.int(4, "AXIS LENGTH", minval=1, group=groupMajor)
axisProj    = input.int(3, "Projection Offset", minval=1, maxval=50, group=groupMajor)

autoKinetic = input.bool(true, "Auto Kinetic Sensitivity", group=groupMajor)
slopeMult   = input.float(1.5, "Kinetic Base Multiplier (If Auto Off)", minval=0.1, maxval=5.0, step=0.1, group=groupMajor)

groupGhost  = "Minor Structure (Ghost Vector)"
showGhost   = input.bool(true, "Enable Tactical Ghost (Micro Trend)", group=groupGhost)
ghostLen    = input.int(2, "Minor Lookback", minval=1, maxval=10, group=groupGhost)
ghCol       = input.color(color.new(#5b9cf6, 0), "Ghost Micro-Trend Color", group=groupGhost)

//==================== CORE ====================
grpCore = "Core"
len         = input.int(10, "Fractal Length (odd)", minval=3, maxval=51, group=grpCore)
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

//==================== PERFORMANCE ====================
grpPerf = "Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
showLastN    = input.int(0, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

//==================== CANDIDATE STYLE ====================
grpCand = "Candidate (Pre-break)"
candCol     = input.color(color.new(color.black, 60), "Candidate Color", group=grpCand)
candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpCand)
candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand)

showCandText = input.bool(false, "Show Candidate Text", group=grpCand)
candTxtUp    = input.string("BOS ↑", "Candidate UP Text", group=grpCand)
candTxtDn    = input.string("BOS ↓", "Candidate DN Text", group=grpCand)
candTxtColUp = input.color(color.rgb(8,153,129), "Candidate UP Text Color", group=grpCand)
candTxtColDn = input.color(color.new(color.red, 0), "Candidate DN Text Color", group=grpCand)

//==================== BROKEN STYLE ====================
grpBrk = "Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color", group=grpBrk)
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk)

//==================== LABELS ====================
grpLbl = "BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color", group=grpLbl)
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

//==================== CHOCH TARGETS ====================
grpTg = "CHoCH Targets"
showChochTg = input.int(6, "Lookback for External Ranges", minval=1, maxval=20, group=grpTg)

extLineCol  = input.color(color.rgb(85, 126, 237), "External HH/LL Line Color", group=grpTg)
extLineSty  = input.string("Solid", "External Line Style", options=["Solid","Dashed","Dotted"], group=grpTg)
extLineW    = input.int(1, "External Line Width", minval=1, maxval=5, group=grpTg)

lastTgColUp = input.color(color.rgb(8,153,129, 30), "Last CHoCH Bullish Line Color (Green)", group=grpTg)
lastTgColDn = input.color(color.new(color.red, 30), "Last CHoCH Bearish Line Color (Red)", group=grpTg)
lastEqCol   = input.color(color.new(color.orange, 0), "Last CHoCH EQ Line Color", group=grpTg)

grpFib = "Last CHoCH Fib Box"
fibBoxCol = input.color(color.new(color.blue, 85), "Fib Box Color", group=grpFib)

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

candStyle = f_ls(candStyleS)
brkStyle  = f_ls(brkStyleS)
extStyle  = f_ls(extLineSty)
lbSize    = f_sz(lbSzS)

//==================== PIVOTS (CONFIRMED) ====================
phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

cPH = ta.pivothigh(high, axisLookback, axisLookback)
cPL = ta.pivotlow(low, axisLookback, axisLookback)
gPH = ta.pivothigh(high, ghostLen, ghostLen)
gPL = ta.pivotlow(low, ghostLen, ghostLen)

//==================== DYNAMIC SENSITIVITY CALC ====================
float bullP = math.sum(close > open ? close - open : 0, 20)
float bearP = math.sum(close < open ? open - close : 0, 20)
float totalP = bullP + bearP == 0 ? 1 : bullP + bearP

float dynMultH = autoKinetic ? (0.5 + (bearP / totalP)) * 2.0 : slopeMult
float dynMultL = autoKinetic ? (0.5 + (bullP / totalP)) * 2.0 : slopeMult

//==================== CANDIDATE STATE ====================
var float upLvl = na
var int   upT   = na
var bool  upBroken = false
var line  upLine = na
var label upCandLb = na

var float dnLvl = na
var int   dnT   = na
var bool  dnBroken = false
var line  dnLine = na
var label dnCandLb = na

var int os = 0

//==================== CHOCH TARGET TRACKING ====================
type ChochRange
    int dir
    int startT
    float hh
    float ll
    int hhT
    int llT

var ChochRange currentRange = na
var ChochRange[] storedRanges = array.new<ChochRange>()

// Global visuals
var box activeBx = na

var line lastHhLine = na
var line lastLlLine = na
var line lastEqLine = na

var line extHhLine = na
var line extLlLine = na
var line extVertLine = na
var label extPriceLbl = na
var label extTargetLbl = na

var float globalExtHH = na
var float globalExtLL = na
var int globalExtMinT = na
var bool hhSwept = false
var bool llSwept = false

//==================== AXIS ENGINE STORAGE ====================
var line cfH_Main = na, var line cfH_Level = na, var line cfH_Med = na, var linefill cfH_Fill = na
var line cfL_Main = na, var line cfL_Level = na, var line cfL_Med = na, var linefill cfL_Fill = na
var float cfH_S = 0.0, var float cfL_S = 0.0, var int cfH_X = 0, var float cfH_Y = 0.0, var float cfL_Y = 0.0, var int cfL_X = 0
var label cfH_Lbl = na, var label cfH_LblV = na, var label cfL_Lbl = na, var label cfL_LblV = na
var int lastH_Time = 0, var int lastL_Time = 0

var line ghH_Main = na, var line ghL_Main = na
var float ghH_S = 0.0, var float ghL_S = 0.0, var int ghH_X = 0, var float ghH_Y = 0.0, var float ghL_Y = 0.0, var int ghL_X = 0
var int lastGH_Time = 0, var int lastGL_Time = 0

msUnit = 86400000 
atrVal = ta.atr(14)
resCol = #f23645
supCol = #089981

deleteH() => 
    line.delete(cfH_Main), line.delete(cfH_Level), line.delete(cfH_Med), label.delete(cfH_Lbl), label.delete(cfH_LblV)
deleteL() => 
    line.delete(cfL_Main), line.delete(cfL_Level), line.delete(cfL_Med), label.delete(cfL_Lbl), label.delete(cfL_LblV)
deleteGH() => line.delete(ghH_Main)
deleteGL() => line.delete(ghL_Main)

calcBestSlope(int startX, float startY, bool isHigh, float mult) =>
    float bSlope = isHigh ? -1e10 : 1e10
    int lookback = bar_index - startX
    if lookback > 0
        for i = 0 to lookback
            int dist = bar_index - i - startX
            if dist > 0
                float val = isHigh ? high[i] : low[i]
                float slope = (val - startY) / dist
                if isHigh
                    if slope > bSlope 
                        bSlope := slope
                else
                    if slope < bSlope 
                        bSlope := slope
    bSlope * mult

getMomentumTier(float s) =>
    float norm = atrVal > 0 ? math.abs(s) / atrVal : 0
    norm > 0.8 ? " [EXTREME]" : norm > 0.4 ? " [AGGRESSIVE]" : norm > 0.1 ? " [STABLE]" : " [WEAK]"

//==================== BROKEN STORAGE ====================
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

f_pushBroken(line ln, label lb) =>
    array.push(brkLines, ln)
    array.push(brkLabs,  lb)
    f_trimBroken()

//==================== CREATE / REPLACE CANDIDATES ====================
if inCalc
    if phHit
        if not na(upLine) and not upBroken
            line.delete(upLine)
        if not na(upCandLb)
            label.delete(upCandLb)

        upLvl := phVal
        upT   := time[p]
        upBroken := false

        upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

    if plHit
        if not na(dnLine) and not dnBroken
            line.delete(dnLine)
        if not na(dnCandLb)
            label.delete(dnCandLb)

        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false

        dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

//==================== EXTEND LIVE CANDIDATES ====================
if inCalc
    if not na(upLine) and not upBroken
        line.set_x2(upLine, time + extMs)
    if not na(dnLine) and not dnBroken
        line.set_x2(dnLine, time + extMs)
        
    if not na(currentRange)
        if high > currentRange.hh
            currentRange.hh := high
            currentRange.hhT := time
        if low < currentRange.ll
            currentRange.ll := low
            currentRange.llT := time
                
    if not na(activeBx)
        box.set_right(activeBx, time + extMs)
        
    if not na(lastHhLine)
        line.set_x2(lastHhLine, time + extMs)
    if not na(lastLlLine)
        line.set_x2(lastLlLine, time + extMs)
    if not na(lastEqLine)
        line.set_x2(lastEqLine, time + extMs)
        
    if not na(extHhLine)
        line.set_x2(extHhLine, time + extMs)
    if not na(extLlLine)
        line.set_x2(extLlLine, time + extMs)
        
    // Sweep Detection
    if not na(globalExtHH) and not hhSwept
        if high > globalExtHH and close < globalExtHH
            // USING 'DOWN' AND LARGER TEXT FOR VISIBILITY
            label.new(time, high, "DOWN", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.white, 100), textcolor=color.red, size=size.large)
            alert("Price Reaction Zones: DOWN Sweep Detected!", alert.freq_once_per_bar_close)
            hhSwept := true
            
    if not na(globalExtLL) and not llSwept
        if low < globalExtLL and close > globalExtLL
            // USING 'UP' AND LARGER TEXT FOR VISIBILITY
            label.new(time, low, "UP", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.white, 100), textcolor=color.green, size=size.large)
            alert("Price Reaction Zones: UP Sweep Detected!", alert.freq_once_per_bar_close)
            llSwept := true

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

//==================== APPLY BREAKS ====================
if inCalc
    if brkUp
        upBroken := true
        isChoch = os == -1
        
        if not na(upLine)
            line.set_color(upLine, brkUpCol)
            line.set_style(upLine, brkStyle)
            line.set_x2(upLine, time)

        label lb = na
        if lbOn
            string txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)
        f_pushBroken(upLine, lb)

        if isChoch
            if not na(currentRange)
                array.push(storedRanges, currentRange)
                
                if array.size(storedRanges) > showChochTg + 1
                    array.shift(storedRanges)
                    
                lastR = array.last(storedRanges)
                
                if not na(activeBx)
                    box.delete(activeBx)
                if not na(lastHhLine)
                    line.delete(lastHhLine)
                if not na(lastLlLine)
                    line.delete(lastLlLine)
                if not na(lastEqLine)
                    line.delete(lastEqLine)
                    
                rng = lastR.hh - lastR.ll
                float eqLvl = lastR.ll + (rng * 0.5)
                
                lastHhLine := line.new(lastR.hhT, lastR.hh, time, lastR.hh, xloc=xloc.bar_time, color=lastTgColUp, style=line.style_dashed)
                lastLlLine := line.new(lastR.llT, lastR.ll, time, lastR.ll, xloc=xloc.bar_time, color=lastTgColUp, style=line.style_dashed)
                lastEqLine := line.new(math.min(lastR.hhT, lastR.llT), eqLvl, time, eqLvl, xloc=xloc.bar_time, color=lastEqCol, style=line.style_dotted)
                
                fibTop = lastR.ll + rng * 0.500
                fibBot = lastR.ll + rng * 0.318
                activeBx := box.new(lastR.startT, fibTop, time, fibBot, xloc=xloc.bar_time, border_color=na, bgcolor=fibBoxCol)
                
                sz = array.size(storedRanges)
                if sz > 1
                    float extHH = -999999
                    float extLL = 999999
                    int extHhT = time
                    int extLlT = time
                    int minT = time
                    
                    for i = 0 to sz - 2
                        r = array.get(storedRanges, i)
                        if r.hh > extHH
                            extHH := r.hh
                            extHhT := r.hhT
                        if r.ll < extLL
                            extLL := r.ll
                            extLlT := r.llT
                        minT := math.min(minT, r.startT)
                        
                    if globalExtHH != extHH
                        hhSwept := false
                    if globalExtLL != extLL
                        llSwept := false
                        
                    globalExtHH := extHH
                    globalExtLL := extLL
                    globalExtMinT := minT
                        
                    if not na(extHhLine)
                        line.delete(extHhLine)
                    if not na(extLlLine)
                        line.delete(extLlLine)
                    if not na(extVertLine)
                        line.delete(extVertLine)
                    if not na(extPriceLbl)
                        label.delete(extPriceLbl)
                    if not na(extTargetLbl)
                        label.delete(extTargetLbl)
                        
                    extHhLine := line.new(extHhT, extHH, time, extHH, xloc=xloc.bar_time, color=extLineCol, style=extStyle, width=extLineW)
                    extLlLine := line.new(extLlT, extLL, time, extLL, xloc=xloc.bar_time, color=extLineCol, style=extStyle, width=extLineW)
                    
                    int vertTime = int(math.avg(extHhT, extLlT))
                    extVertLine := line.new(vertTime, extHH, vertTime, extLL, xloc=xloc.bar_time, color=extLineCol, style=line.style_arrow_both, width=1)
                    
                    float diff = extHH - extLL
                    float diffPct = (diff / extLL) * 100
                    string diffStr = str.tostring(diff, format.mintick) + " (" + str.tostring(diffPct, "#.##") + "%)"
                    
                    extPriceLbl := label.new(vertTime, extHH, diffStr, xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.gray, 20), textcolor=color.white, size=size.small)
                    extTargetLbl := label.new(vertTime, extLL, "TARGET LEVEL", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(color.rgb(8,153,129),0), size=size.normal)
                    
            currentRange := ChochRange.new(1, time, high, low, time, time)
        else if na(currentRange)
            currentRange := ChochRange.new(1, time, high, low, time, time)
            
        upLine := na
        os := 1

    if brkDn
        dnBroken := true
        isChoch = os == 1
        
        if not na(dnLine)
            line.set_color(dnLine, brkDnCol)
            line.set_style(dnLine, brkStyle)
            line.set_x2(dnLine, time)

        label lb = na
        if lbOn
            string txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)
        f_pushBroken(dnLine, lb)

        if isChoch
            if not na(currentRange)
                array.push(storedRanges, currentRange)
                
                if array.size(storedRanges) > showChochTg + 1
                    array.shift(storedRanges)
                    
                lastR = array.last(storedRanges)
                
                if not na(activeBx)
                    box.delete(activeBx)
                if not na(lastHhLine)
                    line.delete(lastHhLine)
                if not na(lastLlLine)
                    line.delete(lastLlLine)
                if not na(lastEqLine)
                    line.delete(lastEqLine)
                    
                rng = lastR.hh - lastR.ll
                float eqLvl = lastR.ll + (rng * 0.5)
                
                lastHhLine := line.new(lastR.hhT, lastR.hh, time, lastR.hh, xloc=xloc.bar_time, color=lastTgColDn, style=line.style_dashed)
                lastLlLine := line.new(lastR.llT, lastR.ll, time, lastR.ll, xloc=xloc.bar_time, color=lastTgColDn, style=line.style_dashed)
                lastEqLine := line.new(math.min(lastR.hhT, lastR.llT), eqLvl, time, eqLvl, xloc=xloc.bar_time, color=lastEqCol, style=line.style_dotted)
                
                fibTop = lastR.hh - rng * 0.618
                fibBot = lastR.hh - rng * 0.790
                activeBx := box.new(lastR.startT, fibTop, time, fibBot, xloc=xloc.bar_time, border_color=na, bgcolor=fibBoxCol)
                
                sz = array.size(storedRanges)
                if sz > 1
                    float extHH = -999999
                    float extLL = 999999
                    int extHhT = time
                    int extLlT = time
                    int minT = time
                    
                    for i = 0 to sz - 2
                        r = array.get(storedRanges, i)
                        if r.hh > extHH
                            extHH := r.hh
                            extHhT := r.hhT
                        if r.ll < extLL
                            extLL := r.ll
                            extLlT := r.llT
                        minT := math.min(minT, r.startT)
                        
                    if globalExtHH != extHH
                        hhSwept := false
                    if globalExtLL != extLL
                        llSwept := false
                        
                    globalExtHH := extHH
                    globalExtLL := extLL
                    globalExtMinT := minT
                        
                    if not na(extHhLine)
                        line.delete(extHhLine)
                    if not na(extLlLine)
                        line.delete(extLlLine)
                    if not na(extVertLine)
                        line.delete(extVertLine)
                    if not na(extPriceLbl)
                        label.delete(extPriceLbl)
                    if not na(extTargetLbl)
                        label.delete(extTargetLbl)
                        
                    extHhLine := line.new(extHhT, extHH, time, extHH, xloc=xloc.bar_time, color=extLineCol, style=extStyle, width=extLineW)
                    extLlLine := line.new(extLlT, extLL, time, extLL, xloc=xloc.bar_time, color=extLineCol, style=extStyle, width=extLineW)
                    
                    int vertTime = int(math.avg(extHhT, extLlT))
                    extVertLine := line.new(vertTime, extHH, vertTime, extLL, xloc=xloc.bar_time, color=extLineCol, style=line.style_arrow_both, width=1)
                    
                    float diff = extHH - extLL
                    float diffPct = (diff / extLL) * 100
                    string diffStr = str.tostring(diff, format.mintick) + " (" + str.tostring(diffPct, "#.##") + "%)"
                    
                    extPriceLbl := label.new(vertTime, extHH, diffStr, xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.gray, 20), textcolor=color.white, size=size.small)
                    extTargetLbl := label.new(vertTime, extLL, "TARGET LEVEL", xloc=xloc.bar_time, style=label.style_none, textcolor=color.new(color.rgb(8,153,129),0), size=size.normal)
                    
            currentRange := ChochRange.new(-1, time, high, low, time, time)
        else if na(currentRange)
            currentRange := ChochRange.new(-1, time, high, low, time, time)

        dnLine := na
        os := -1

//==================== AXIS ENGINES ====================
if inCalc
    nxExtAxis = bar_index + axisProj
    
    // Major Axis
    if (na(cfH_Main) or (time - lastH_Time >= msUnit * axisLength)) and not na(cPH)
        deleteH(), cfH_X := bar_index - axisLookback, cfH_Y := high[axisLookback], lastH_Time := time[axisLookback], cfH_S := calcBestSlope(cfH_X, cfH_Y, true, dynMultH)
        cfH_Main := line.new(cfH_X, cfH_Y, nxExtAxis, cfH_Y + cfH_S * (nxExtAxis - cfH_X), color=resCol, width=1)
        cfH_Level := line.new(cfH_X, cfH_Y, nxExtAxis, cfH_Y, color=resCol, width=1)
        cfH_Med := line.new(cfH_X, cfH_Y, nxExtAxis, cfH_Y + (cfH_S * 0.5) * (nxExtAxis - cfH_X), color=color.new(resCol, 50), style=line.style_dashed)
        cfH_Lbl := label.new(nxExtAxis, cfH_Y, str.tostring(cfH_Y, format.mintick), color=#00000000, textcolor=resCol, style=label.style_label_left, size=size.small)
        cfH_LblV := label.new(cfH_X, cfH_Y, "VELOCITY: " + str.tostring(cfH_S, "#.####") + getMomentumTier(cfH_S), color=#00000000, textcolor=resCol, style=label.style_label_down, size=size.small)
        cfH_Fill := linefill.new(cfH_Main, cfH_Level, color.new(resCol, 90))
    
    if (na(cfL_Main) or (time - lastL_Time >= msUnit * axisLength)) and not na(cPL)
        deleteL(), cfL_X := bar_index - axisLookback, cfL_Y := low[axisLookback], lastL_Time := time[axisLookback], cfL_S := calcBestSlope(cfL_X, cfL_Y, false, dynMultL)
        cfL_Main := line.new(cfL_X, cfL_Y, nxExtAxis, cfL_Y + cfL_S * (nxExtAxis - cfL_X), color=supCol, width=1)
        cfL_Level := line.new(cfL_X, cfL_Y, nxExtAxis, cfL_Y, color=supCol, width=1)
        cfL_Med := line.new(cfL_X, cfL_Y, nxExtAxis, cfL_Y + (cfL_S * 0.5) * (nxExtAxis - cfL_X), color=color.new(supCol, 50), style=line.style_dashed)
        cfL_Lbl := label.new(nxExtAxis, cfL_Y, str.tostring(cfL_Y, format.mintick), color=#00000000, textcolor=supCol, style=label.style_label_left, size=size.small)
        cfL_LblV := label.new(cfL_X, cfL_Y, "VELOCITY: " + str.tostring(cfL_S, "#.####") + getMomentumTier(cfL_S), color=#00000000, textcolor=supCol, style=label.style_label_up, size=size.small)
        cfL_Fill := linefill.new(cfL_Main, cfL_Level, color.new(supCol, 90))
    
    // Ghost Axis (Cyan Micro Vector)
    if showGhost
        if (na(ghH_Main) or (time - lastGH_Time >= msUnit * axisLength)) and not na(gPH)
            deleteGH(), ghH_X := bar_index - ghostLen, ghH_Y := high[ghostLen], lastGH_Time := time[ghostLen], ghH_S := calcBestSlope(ghH_X, ghH_Y, true, dynMultH)
            ghH_Main := line.new(ghH_X, ghH_Y, nxExtAxis, ghH_Y + ghH_S * (nxExtAxis - ghH_X), color=ghCol, width=1, style=line.style_dashed)
        if (na(ghL_Main) or (time - lastGL_Time >= msUnit * axisLength)) and not na(gPL)
            deleteGL(), ghL_X := bar_index - ghostLen, ghL_Y := low[ghostLen], lastGL_Time := time[ghostLen], ghL_S := calcBestSlope(ghL_X, ghL_Y, false, dynMultL)
            ghL_Main := line.new(ghL_X, ghL_Y, nxExtAxis, ghL_Y + ghL_S * (nxExtAxis - ghL_X), color=ghCol, width=1, style=line.style_dashed)
    else
        deleteGH(), deleteGL(), ghH_Main := na, ghL_Main := na
    
    // AXIS Dynamic Updates
    hDom = math.abs(cfH_S) > math.abs(cfL_S)
    medY_H = cfH_Y + (cfH_S * 0.5) * (bar_index - cfH_X)
    medY_L = cfL_Y + (cfL_S * 0.5) * (bar_index - cfL_X)
    
    if not na(cfH_Main)
        if close > cfH_Y
            deleteH(), cfH_Main := na
        else
            if ta.crossover(close, medY_H) 
                cfH_S := calcBestSlope(cfH_X, cfH_Y, true, dynMultH)
            line.set_x2(cfH_Main, nxExtAxis), line.set_y2(cfH_Main, cfH_Y + cfH_S * (nxExtAxis - cfH_X))
            line.set_x2(cfH_Level, nxExtAxis), line.set_x2(cfH_Med, nxExtAxis), line.set_y2(cfH_Med, cfH_Y + (cfH_S * 0.5) * (nxExtAxis - cfH_X))
            label.set_x(cfH_Lbl, nxExtAxis), label.set_x(cfH_LblV, cfH_X), label.set_text(cfH_LblV, "VELOCITY: " + str.tostring(cfH_S, "#.####") + getMomentumTier(cfH_S)), line.set_width(cfH_Main, hDom ? 2 : 1)
    
    if not na(cfL_Main)
        if close < cfL_Y
            deleteL(), cfL_Main := na
        else
            if ta.crossunder(close, medY_L) 
                cfL_S := calcBestSlope(cfL_X, cfL_Y, false, dynMultL)
            line.set_x2(cfL_Main, nxExtAxis), line.set_y2(cfL_Main, cfL_Y + cfL_S * (nxExtAxis - cfL_X))
            line.set_x2(cfL_Level, nxExtAxis), line.set_x2(cfL_Med, nxExtAxis), line.set_y2(cfL_Med, cfL_Y + (cfL_S * 0.5) * (nxExtAxis - cfL_X))
            label.set_x(cfL_Lbl, nxExtAxis), label.set_x(cfL_LblV, cfL_X), label.set_text(cfL_LblV, "VELOCITY: " + str.tostring(cfL_S, "#.####") + getMomentumTier(cfL_S)), line.set_width(cfL_Main, not hDom ? 2 : 1)
    
    if not na(ghH_Main)
        if close > ghH_Y
            deleteGH(), ghH_Main := na
        else
            ghH_S := calcBestSlope(ghH_X, ghH_Y, true, dynMultH), line.set_x2(ghH_Main, nxExtAxis), line.set_y2(ghH_Main, ghH_Y + ghH_S * (nxExtAxis - ghH_X))
    if not na(ghL_Main)
        if close < ghL_Y
            deleteGL(), ghL_Main := na
        else
            ghL_S := calcBestSlope(ghL_X, ghL_Y, false, dynMultL), line.set_x2(ghL_Main, nxExtAxis), line.set_y2(ghL_Main, ghL_Y + ghL_S * (nxExtAxis - ghL_X))
````
