# Geometric Matrix Intelligence [GMI]

- url: https://www.tradingview.com/script/XSKuF1tY-Geometric-Matrix-Intelligence-GMI/
- type: indicator
- pine_id: PUB;dcb57276e1244528953ed6aa5a3da546
- version: 1.0

## Description

Description:
Welcome to the Geometric Matrix Intelligence [GMI] + Market Structure indicator. This script is a hybrid trading tool that merges advanced structural concepts (BOS/CHoCH) with geometric probability levels and volatility-based trend analysis.

Core Features:

Geometric Probability Levels (GMI):
When a shift in trend direction is detected based on our custom ATR volatility filter, the script automatically projects forward geometric expansion levels (Φ1 to Φ4). These levels are highly versatile:
Reversal Zones: Price often reacts directly at these mathematical levels, creating excellent pivot or bounce areas.
Take Profit (TP) Targets: Once you are in a trade, these expansion lines provide objective, dynamic targets to scale out or close your positions.
Market Structure (BOS / CHoCH):
Automatically identifies structural pivot highs and lows using a fractal length (defaulted to 12).
Plots pending "Candidate" structure lines (in blue by default).
Confirms Break of Structure (BOS) or Change of Character (CHoCH) when the price breaks these pivots, updating dynamically on your chart.
VWAP Integration:
Includes a built-in Volume Weighted Average Price (VWAP) as a primary institutional baseline to help gauge overall intraday or multi-day bias. (Enabled by default).
Interactive Trend Dashboard & Shading:
An on-chart dashboard tracks the immediate trend status, the initial trigger entry price, maximum projected targets (Φ4), and current ATR volatility.
Visual trend shading allows for immediate macro-trend recognition.
How to Use:

Watch for Market Structure shifts (BOS/CHoCH) aligning with the GMI generated levels.
Use the projected Φ levels as primary take profit targets when trading a newly confirmed structural break.
Monitor the VWAP to ensure your structural trades are on the correct side of the institutional volume average.
Disclaimer:
This script is provided for educational and informational purposes only. It is not intended to be a financial advice, investment recommendation, or a signal to buy/sell any asset. Trading in financial markets involves significant risk of loss. Always do your own research and test any indicator or strategy in a paper-trading environment before committing real capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("Geometric Matrix Intelligence [GMI]", "GMI", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ---------------------------------------------------------------------------------------------------------------------
// --- GEOMETRIC ENGINE INPUTS ---
// ---------------------------------------------------------------------------------------------------------------------

grp_math = "Mathematical Core"
sensitivity = input.float(2, "Reversal Sensitivity", minval = 1.0, step = 0.1, tooltip = "Controls the distance between the price and the reality line.")
atrLen      = input.int(10, "Volatility Lookback", group = grp_math, tooltip = "Lookback period for ATR volatility calculation.")

grp_geom = "Geometric Probability Levels (GPL)"
ratio1      = input.float(1.47, "Expansion 1", group = grp_geom)
ratio2      = input.float(2.47, "Expansion 2", group = grp_geom)
ratio3      = input.float(3.47, "Expansion 3", group = grp_geom)
ratio4      = input.float(4.47, "Expansion 4", group = grp_geom)

grp_vis  = "Visual Logic"
theme        = input.string("Classic", "Color Theme", options = ["Classic", "Neon", "Monochrome", "Gold"], group = grp_vis)
showShading  = input.bool(true, "Show Trend Shading", group = grp_vis)
dashPos      = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grp_vis)
dashSize     = input.string("Small", "Dashboard Size", options = ["Tiny", "Small", "Normal"], group = grp_vis)
labelOffset  = input.int(20, "Label Offset", minval = 0, group = grp_vis)

grp_vwap = "VWAP Settings"
showVwap = input.bool(true, "Show VWAP", group = grp_vwap)
vwapColor = input.color(color.blue, "VWAP Color", group = grp_vwap)

// --- Color Theme Logic ---
var color bullColor = #089981
var color bearColor = #f23645

if theme == "Neon"
    bullColor := #00ffbb
    bearColor := #ff0055
else if theme == "Monochrome"
    bullColor := chart.fg_color
    bearColor := chart.fg_color
else if theme == "Gold"
    bullColor := #ffcc00
    bearColor := #ff5500
else
    bullColor := #089981
    bearColor := #f23645

// ---------------------------------------------------------------------------------------------------------------------
// --- DATA STRUCTURES & TYPES ---
// ---------------------------------------------------------------------------------------------------------------------

type TargetSet
    line[]  lines
    label[] labels
    int     direction 

var TargetSet bullSet = TargetSet.new(array.new_line(), array.new_label(), 1)
var TargetSet bearSet = TargetSet.new(array.new_line(), array.new_label(), -1)
var int latestSignalDir = 0 // Tracks the absolute latest signal

clearTargetSet(TargetSet ts) =>
    if array.size(ts.lines) > 0
        for i = 0 to array.size(ts.lines) - 1
            line.delete(array.get(ts.lines, i))
        array.clear(ts.lines)
    if array.size(ts.labels) > 0
        for i = 0 to array.size(ts.labels) - 1
            label.delete(array.get(ts.labels, i))
        array.clear(ts.labels)

updateTargetSet(TargetSet ts) =>
    if array.size(ts.lines) > 0
        for i = 0 to array.size(ts.lines) - 1
            ln = array.get(ts.lines, i)
            lb = array.get(ts.labels, i)
            line.set_x2(ln, bar_index + labelOffset)
            label.set_x(lb, bar_index + labelOffset)

// ---------------------------------------------------------------------------------------------------------------------
// --- CORE MATHEMATICS ---
// ---------------------------------------------------------------------------------------------------------------------

atr = ta.atr(atrLen)
var float trailLevel = na
var int   trendDir   = 0 
var float lastBullEntry = na
var float lastBearEntry = na

float src = close
float upDist = src - (sensitivity * atr)
float dnDist = src + (sensitivity * atr)

trailLevel := src > nz(trailLevel[1]) and src[1] > nz(trailLevel[1]) ? math.max(nz(trailLevel[1]), upDist) : 
              src < nz(trailLevel[1]) and src[1] < nz(trailLevel[1]) ? math.min(nz(trailLevel[1]), dnDist) : 
              src > nz(trailLevel[1]) ? upDist : dnDist

bool turnBull = ta.crossover(src, trailLevel)
bool turnBear = ta.crossunder(src, trailLevel)

// ---------------------------------------------------------------------------------------------------------------------
// --- LEVEL GENERATION ---
// ---------------------------------------------------------------------------------------------------------------------

createLevel(TargetSet ts, float entry, float stopVal, float ratio, color col, string name) =>
    float priceRange = math.abs(entry - stopVal)
    float targetPrice = ts.direction == 1 ? entry + (priceRange * ratio) : entry - (priceRange * ratio)
    
    line  ln = line.new(bar_index, targetPrice, bar_index + labelOffset, targetPrice, color = color.new(col, 20), width = 1, style = line.style_dashed)
    label lb = label.new(bar_index + labelOffset, targetPrice, name + " " + str.tostring(targetPrice, format.mintick), 
                 style = label.style_label_left, textcolor = col, color = #00000000, size = size.small)
    
    array.push(ts.lines, ln)
    array.push(ts.labels, lb)

if turnBull
    clearTargetSet(bullSet)
    lastBullEntry := close
    trendDir      := 1
    latestSignalDir := 1
    createLevel(bullSet, lastBullEntry, trailLevel, ratio1, bullColor, "Φ1")
    createLevel(bullSet, lastBullEntry, trailLevel, ratio2, bullColor, "Φ2")
    createLevel(bullSet, lastBullEntry, trailLevel, ratio3, bullColor, "Φ3")
    createLevel(bullSet, lastBullEntry, trailLevel, ratio4, bullColor, "Φ4")
    line.new(bar_index, high, bar_index, low, color = bullColor, width = 2)

if turnBear
    clearTargetSet(bearSet)
    lastBearEntry := close
    trendDir      := -1
    latestSignalDir := -1
    createLevel(bearSet, lastBearEntry, trailLevel, ratio1, bearColor, "Φ1")
    createLevel(bearSet, lastBearEntry, trailLevel, ratio2, bearColor, "Φ2")
    createLevel(bearSet, lastBearEntry, trailLevel, ratio3, bearColor, "Φ3")
    createLevel(bearSet, lastBearEntry, trailLevel, ratio4, bearColor, "Φ4")
    line.new(bar_index, high, bar_index, low, color = bearColor, width = 2)

// --- DYNAMIC FREEZE LOGIC ---
if latestSignalDir == 1
    updateTargetSet(bullSet)
else if latestSignalDir == -1
    updateTargetSet(bearSet)

// ---------------------------------------------------------------------------------------------------------------------
// --- VISUALS & DASHBOARD ---
// ---------------------------------------------------------------------------------------------------------------------

// Shading
p_reality = plot(trailLevel, "Reality Line", display = display.none) // Hidden Reality Line
p_price   = plot(close, "Price Reference", display = display.none)

fill(p_reality, p_price, top_value = math.max(close, trailLevel), bottom_value = math.min(close, trailLevel),
     top_color = close > trailLevel ? color.new(bullColor, 80) : color.new(bearColor, 100),
     bottom_color = close > trailLevel ? color.new(bullColor, 100) : color.new(bearColor, 80),
     title = "Trend Shading", display = showShading ? display.all : display.none)


// VWAP
vwapValue = ta.vwap(hlc3)
plot(showVwap ? vwapValue : na, "VWAP", color = vwapColor)

// Table Config
t_pos = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Top Left" ? position.top_left : position.bottom_left
t_size = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal

var table dash = table.new(t_pos, 2, 4, bgcolor = #000000, border_color = #333333, border_width = 1)
if barstate.islast
    activeEntry = trendDir == 1 ? lastBullEntry : lastBearEntry
    float curRange = math.abs(activeEntry - trailLevel)
    
    table.cell(dash, 0, 0, "GMI Status", text_color = color.white, text_size = t_size)
    table.cell(dash, 1, 0, trendDir == 1 ? "BULL" : "BEAR", bgcolor = trendDir == 1 ? bullColor : bearColor, text_color = color.white, text_size = t_size)
    table.cell(dash, 0, 1, "Sigma Entry", text_color = color.white, text_size = t_size)
    table.cell(dash, 1, 1, str.tostring(activeEntry, format.mintick), text_color = color.white, text_size = t_size)
    table.cell(dash, 0, 2, "Φ4 (Max)", text_color = color.white, text_size = t_size)
    table.cell(dash, 1, 2, str.tostring(trendDir == 1 ? activeEntry + (curRange * ratio4) : activeEntry - (curRange * ratio4), format.mintick), text_color = color.white, text_size = t_size)
    table.cell(dash, 0, 3, "Volatility", text_color = color.white, text_size = t_size)
    table.cell(dash, 1, 3, str.tostring(atr, format.mintick), text_color = color.white, text_size = t_size)

// Watermark
var table watermark = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(watermark, 0, 0, "erdensedat", text_color = color.new(chart.fg_color, 90), text_size = size.huge)

// Alerts
alertcondition(turnBull or turnBear, "GMI Turn Activated", "GMI: Sigma Matrix Reversal Detected")


//==================== STRUCTURE: CANDIDATE→BROKEN BOS/CHOCH ====================

grpCoreBOS = "Structure Core"
len         = input.int(12, "Fractal Length (odd)", minval=3, maxval=51, group=grpCoreBOS) // Default 12
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCoreBOS)  
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCoreBOS)

grpPerf = "Structure Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
showLastN    = input.int(0, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

grpCand = "Candidate (Pre-break)"
candCol     = input.color(color.blue, "Candidate Color", group=grpCand) // Default Blue
candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpCand) 
candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand) 

showCandText = input.bool(true, "Show Candidate Text", group=grpCand) // Default ON
candTxtUp    = input.string("BOS ↑", "Candidate UP Text", group=grpCand)
candTxtDn    = input.string("BOS ↓", "Candidate DN Text", group=grpCand)
candTxtColUp = input.color(color.rgb(8,153,129), "Candidate UP Text Color", group=grpCand) 
candTxtColDn = input.color(color.new(color.red, 0), "Candidate DN Text Color", group=grpCand)

grpBrk = "Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpBrk) 
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)        
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)              
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk) 

grpLbl = "BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color", group=grpLbl) 
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

grpDbg = "Structure Debug"
showPivotMarks = input.bool(false, "Show Pivot Marks", group=grpDbg)

f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

inCalc = true
if calcLastBars == 0
    inCalc := true
else
    inCalc := bar_index >= last_bar_index - calcLastBars

L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)

tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight

candStyle = f_ls(candStyleS)
brkStyle  = f_ls(brkStyleS)
lbSize    = f_sz(lbSzS)

phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

plotshape(showPivotMarks and phHit, title="PH", style=shape.triangledown, location=location.abovebar, size=size.tiny, text="PH")
plotshape(showPivotMarks and plHit, title="PL", style=shape.triangleup,   location=location.belowbar, size=size.tiny, text="PL")

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

        if showCandText
            upCandLb := label.new(upT, upLvl, candTxtUp, xloc=xloc.bar_time, style=label.style_label_down, textcolor=candTxtColUp, color=lbBg, size=lbSize)
        else
            upCandLb := na

    if plHit
        if not na(dnLine) and not dnBroken
            line.delete(dnLine)
        if not na(dnCandLb)
            label.delete(dnCandLb)

        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false

        dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

        if showCandText
            dnCandLb := label.new(dnT, dnLvl, candTxtDn, xloc=xloc.bar_time, style=label.style_label_up, textcolor=candTxtColDn, color=lbBg, size=lbSize)
        else
            dnCandLb := na

if inCalc
    if not na(upLine) and not upBroken
        line.set_x2(upLine, time + extMs)
    if not na(dnLine) and not dnBroken
        line.set_x2(dnLine, time + extMs)

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

if inCalc
    if brkUp
        upBroken := true

        if not na(upLine)
            line.set_color(upLine, brkUpCol)
            line.set_style(upLine, brkStyle)
            line.set_width(upLine, brkW)
            line.set_x2(upLine, time)

        if not na(upCandLb)
            label.delete(upCandLb)
            upCandLb := na

        label lb = na
        if lbOn
            string txt = os == -1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)

        f_pushBroken(upLine, lb)
        upLine := na
        os := 1

    if brkDn
        dnBroken := true

        if not na(dnLine)
            line.set_color(dnLine, brkDnCol)
            line.set_style(dnLine, brkStyle)
            line.set_width(dnLine, brkW)
            line.set_x2(dnLine, time)

        if not na(dnCandLb)
            label.delete(dnCandLb)
            dnCandLb := na

        label lb = na
        if lbOn
            string txt = os == 1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)

        f_pushBroken(dnLine, lb)
        dnLine := na
        os := -1
````
