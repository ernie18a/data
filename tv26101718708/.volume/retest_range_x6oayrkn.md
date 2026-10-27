# Retest Range

- url: https://www.tradingview.com/script/X6OaYrkn-Retest-Range/
- type: indicator
- pine_id: PUB;094d68958c1c415d95e2db403d3c7b6b
- version: 2.0

## Description

Retest Range: Advanced Market Structure & Setup Engine
Overview
The Retest Range indicator is a sophisticated price action tool designed to identify powerful 3-candle reversal structures, automatically map out their internal mathematics, and project highly accurate support, resistance, and target zones. It combines raw momentum filtering with an internal Market Structure (BOS/CHoCH) engine to provide a complete, minimalist dashboard for serious traders.

How It Works: The 3-Candle Setup
The core engine hunts for a specific cluster of momentum:

Bullish Setup: A single bearish (red) candle followed immediately by 3 consecutive bullish (green) candles that engulf the high of the initial red candle.
Bearish Setup: A single bullish (green) candle followed immediately by 3 consecutive bearish (red) candles that engulf the low of the initial green candle.
Once a valid setup is identified, the indicator draws a transparent box around these 3 candles to visualize the "Range".

Mathematical Levels (0.75, 0.50, 0.25)
Inside every active Box, the script automatically projects three critical Fibonacci-like quartiles:

0.75, 0.50 (The Mid/Entry Level), and 0.25.
These lines extend forward to act as immediate dynamic support and resistance. The closest, untouched active box will continuously extend its lines along with the live price until a new box forms.
Box Targets & The "Inverse" Mechanics (Hocus Pocus)
Every valid setup projects a 1:1 Box Target based on its own range size.

A Bullish box projects a target box above it.
A Bearish box projects a target box below it.
The Inverse Trap: If the price fails to hit its intended target and instead reverses to close beyond the 0.50 mid-level of the active box, an "Inverse" is triggered.
When an Inverse occurs:

The original setup lines flip their colors (a failed Bullish box turns red).
The initial Box Target transforms into a hard "Resistance" (or Support) block.
A brand new Box Target is immediately projected in the opposite direction.
This allows traders to catch failed setups and instantly ride the momentum of the reversal trap!
Built-In Market Structure Engine (BOS / CHoCH)
Running silently in the background is a pure fractal-based Market Structure engine. It maps out confirmed Pivot Highs and Pivot Lows, labeling Break of Structure (BOS) and Change of Character (CHoCH) levels. It requires a hard candle body close to confirm breaks, filtering out fake wick sweeps.

The Stats Dashboard
A clean, minimalist ICT-style panel adapts to your chart's theme (Dark/Light mode). It provides live intelligence:

Daily Bias: Compared to the daily open.
MS State: The latest trend direction from the BOS/CHoCH engine.
Live Momentum & Volume: Real-time percentage strength of the current 3-candle move compared to the historical average of all previous boxes (highlighting STRONG vs. WEAK moves).
RSI & DMI (DI+ / DI-): Essential trend strength metrics at a glance.
Key Features:

Fully customizable Body Multiplier to filter out weak/doji setups.
Automatic preservation of validated Support/Resistance (Inverse) target boxes.
Clean, non-overlapping labels and lines.
Minimalist aesthetics designed for Quant and Price Action traders.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("Retest Range", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

//==================== BOX OPTIONS & COLORS ====================
grpBox = "Box Options & Colors"
boxBullColor        = input.color(#089981, "Bullish Color", group=grpBox)
boxBearColor        = input.color(#f23645, "Bearish Color", group=grpBox)
showBox             = input.bool(true, "Show Boxes", group=grpBox)
boxTransp           = input.int(85, "Box Transparency", minval=0, maxval=100, group=grpBox)
boxExtendBars       = input.int(5, "Line Initial Extend (Bars)", minval=1, group=grpBox)
boxShowLastN        = input.int(1, "Show Last N Boxes (0 = All)", minval=0, group=grpBox)
srShowLastN         = input.int(0, "Show Last N Sup/Res Boxes (0 = All)", minval=0, group=grpBox)
boxLineStyleS       = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=grpBox)

// Body Filter
bodySmaLength = input.int(20, "Body SMA Period", group=grpBox)
bodyFilter = input.float(0.0, "Min Body Multiplier (0 = Off)", step=0.1, group=grpBox, tooltip="Candle body must be at least this multiplier of the average body.")

//==================== MA & VWAP SETTINGS ====================
grpMA = "Moving Averages & VWAP"
showMAs   = input.bool(false, "Show MAs", group=grpMA)
ma1Length = input.int(20, "MA 1 Length", group=grpMA)
ma1Type   = input.string("SMA", "MA 1 Type", options=["SMA","EMA","WMA","RMA"], group=grpMA)
ma2Length = input.int(50, "MA 2 Length", group=grpMA)
ma2Type   = input.string("SMA", "MA 2 Type", options=["SMA","EMA","WMA","RMA"], group=grpMA)
showVWAP  = input.bool(false, "Show VWAP", group=grpMA)

//==================== MARKET STRUCTURE CORE ====================
grpMSCore = "Market Structure (BOS/CHoCH)"
len         = input.int(10, "Fractal Length", minval=3, maxval=51, group=grpMSCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpMSCore)

//==================== MS PERFORMANCE ====================
grpMSPerf = "MS Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpMSPerf)
maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpMSPerf)
msShowLastN  = input.int(0, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpMSPerf)

//==================== MS BROKEN STYLE ====================
grpMSBrk = "MS Broken Style"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpMSBrk)
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpMSBrk)
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpMSBrk)
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpMSBrk)

//==================== MS LABELS ====================
grpMSLbl = "MS Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpMSLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpMSLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpMSLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color (#089981)", group=grpMSLbl)
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpMSLbl)

//==================== DASHBOARD / PANEL ====================
grpPan = "Dashboard Panel"
showPanel = input.bool(true, "Show Dashboard", group=grpPan)
panelPos  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpPan)
panelSize = input.string("normal", "Table Size", options=["tiny", "small", "normal", "large", "huge"], group=grpPan)

//==================== HELPERS ====================
isRed(index) => close[index] < open[index]
isGreen(index) => close[index] > open[index]

f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

f_format_vol(float v) =>
    if na(v)
        "0"
    else if v >= 1000000
        str.tostring(v / 1000000, "#.##") + "M"
    else if v >= 1000
        str.tostring(v / 1000, "#.##") + "K"
    else
        str.tostring(v, "#.##")

getMA(type, src, length) =>
    switch type
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        => ta.sma(src, length)

bodySize(index) => math.abs(close[index] - open[index])
avgBody = ta.sma(bodySize(0), bodySmaLength)
isValidBody(index) => bodyFilter == 0.0 ? true : bodySize(index) > (avgBody[index] * bodyFilter)

color autoFg = chart.fg_color

//==================== INDICATOR CALCULATIONS ====================
float rsiVal = ta.rsi(close, 14)
[diPlus, diMinus, adx] = ta.dmi(14, 14)

float curMomRaw = ((close - close[3]) / close[3]) * 100
string momArrow = curMomRaw > 0 ? " ▲" : curMomRaw < 0 ? " ▼" : " ▬"

float ma1 = getMA(ma1Type, close, ma1Length)
float ma2 = getMA(ma2Type, close, ma2Length)
float vwapVal = ta.vwap(close)

plot(showMAs ? ma1 : na, "MA 1", color=color.blue)
plot(showMAs ? ma2 : na, "MA 2", color=color.orange)
plot(showVWAP ? vwapVal : na, "VWAP", color=color.fuchsia)

//#####################################################################
//#                   STATS TRACKING                                  #
//#####################################################################
var float totalBoxVol = 0.0
var float totalBoxMom = 0.0
var int   totalBoxCount = 0

//#####################################################################
//#                   SUPPORT/RESISTANCE STORAGE                      #
//#####################################################################
var box[]   srBoxes  = array.new_box()
var label[] srLabels = array.new_label()

f_pushSR(box b, label l) =>
    array.push(srBoxes, b)
    array.push(srLabels, l)
    if srShowLastN > 0
        while array.size(srBoxes) > srShowLastN
            box oldB = array.shift(srBoxes)
            box.delete(oldB)
        while array.size(srLabels) > srShowLastN
            label oldL = array.shift(srLabels)
            label.delete(oldL)

//#####################################################################
//#                   BOX & INVERSE LOGIC                             #
//#####################################################################

type Setup
    box b
    line l75
    line l50
    line l25
    box bTgt
    box bTgt2
    label lbl75
    label lbl50
    label lbl25
    label lblTgt
    label lblTgt2
    label lblInfo
    int dir
    float lvl50
    float top
    float bot
    float rangeDiff
    bool isInverse
    int endBar
    int startBar
    bool isTgt1Touched
    bool isTgt2Touched
    bool isSupRes // Sup/Res olduysa silinmemesi için

var Setup[] setups = array.new<Setup>()

f_deleteSetup(Setup s) =>
    if not na(s.b)
        box.delete(s.b)
    if not s.isSupRes // Sadece Sup/Res olmadıysa hedef kutusunu sil
        if not na(s.bTgt)
            box.delete(s.bTgt)
        if not na(s.lblTgt)
            label.delete(s.lblTgt)
    if not na(s.bTgt2)
        box.delete(s.bTgt2)
    if not na(s.l75)
        line.delete(s.l75)
    if not na(s.l50)
        line.delete(s.l50)
    if not na(s.l25)
        line.delete(s.l25)
    if not na(s.lbl75)
        label.delete(s.lbl75)
    if not na(s.lbl50)
        label.delete(s.lbl50)
    if not na(s.lbl25)
        label.delete(s.lbl25)
    if not na(s.lblTgt2)
        label.delete(s.lblTgt2)
    if not na(s.lblInfo)
        label.delete(s.lblInfo)

bullBodyValid = isValidBody(0) and isValidBody(1) and isValidBody(2)
bearBodyValid = isValidBody(0) and isValidBody(1) and isValidBody(2)

bullPattern = isRed(3) and isGreen(2) and isGreen(1) and isGreen(0) and bullBodyValid
bearPattern = isGreen(3) and isRed(2) and isRed(1) and isRed(0) and bearBodyValid

bLStyle = f_ls(boxLineStyleS)
var string latestBoxStrength = "N/A"

if bullPattern or bearPattern
    int dir = bullPattern ? 1 : -1
    color mainCol = dir == 1 ? boxBullColor : boxBearColor
    
    float top = math.max(high[2], high[1], high[0])
    float bot = math.min(low[2], low[1], low[0])
    float rangeDiff = top - bot
    
    float lvl75 = bot + (rangeDiff * 0.75)
    float lvl50 = bot + (rangeDiff * 0.50)
    float lvl25 = bot + (rangeDiff * 0.25)
    
    float t1 = dir == 1 ? top + rangeDiff : bot - rangeDiff
    float t2 = dir == 1 ? t1 - (rangeDiff * 0.25) : t1 + (rangeDiff * 0.25)
    float tTop = math.max(t1, t2)
    float tBot = math.min(t1, t2)
    
    if array.size(setups) > 0
        for i = 0 to array.size(setups) - 1
            Setup oldS = array.get(setups, i)
            oldS.endBar := oldS.startBar
            line.set_x2(oldS.l75, oldS.endBar)
            line.set_x2(oldS.l50, oldS.endBar)
            line.set_x2(oldS.l25, oldS.endBar)
            if not oldS.isSupRes
                box.set_right(oldS.bTgt, oldS.endBar)
                label.set_x(oldS.lblTgt, oldS.endBar)
            if not na(oldS.bTgt2)
                box.set_right(oldS.bTgt2, oldS.endBar)
            label.set_x(oldS.lbl75, oldS.endBar)
            label.set_x(oldS.lbl50, oldS.endBar)
            label.set_x(oldS.lbl25, oldS.endBar)
    
    float vol3 = volume[0] + volume[1] + volume[2]
    float mom3 = math.abs(((close[0] - close[3]) / close[3]) * 100)
    
    float avgVol = totalBoxCount > 0 ? (totalBoxVol / totalBoxCount) : vol3
    float avgMom = totalBoxCount > 0 ? (totalBoxMom / totalBoxCount) : mom3
    string strength = (vol3 >= avgVol and mom3 >= avgMom) ? "STRONG" : "WEAK"
    latestBoxStrength := strength
    
    totalBoxVol += vol3
    totalBoxMom += mom3
    totalBoxCount += 1
    
    string infoText = "Vol: " + f_format_vol(vol3) + "\nMom: " + str.tostring(mom3, "#.##") + "%\n" + strength
    
    color boxCol = color.new(mainCol, boxTransp)
    bx = showBox ? box.new(bar_index[2], top, bar_index, bot, border_color=mainCol, bgcolor=boxCol, border_style=bLStyle) : na
    
    int endB = bar_index + boxExtendBars
    int startB = bar_index
    
    ln75 = line.new(startB, lvl75, endB, lvl75, color=mainCol, style=bLStyle)
    ln50 = line.new(startB, lvl50, endB, lvl50, color=mainCol, style=bLStyle)
    ln25 = line.new(startB, lvl25, endB, lvl25, color=mainCol, style=bLStyle)
    
    bxTgt = box.new(startB, tTop, endB, tBot, border_color=autoFg, bgcolor=na, border_style=line.style_solid)
    
    lb75 = label.new(endB, lvl75, "0.75", color=color.new(color.white, 100), textcolor=mainCol, style=label.style_label_left, size=size.small)
    lb50 = label.new(endB, lvl50, "0.50", color=color.new(color.white, 100), textcolor=mainCol, style=label.style_label_left, size=size.small)
    lb25 = label.new(endB, lvl25, "0.25", color=color.new(color.white, 100), textcolor=mainCol, style=label.style_label_left, size=size.small)
    
    string tgtTxt = "Box Target " + str.tostring(t1, format.mintick)
    int initX = int(math.avg(startB, endB))
    
    string initStyle = dir == 1 ? label.style_label_down : label.style_label_up
    
    lbTgt = label.new(initX, t1, tgtTxt, color=color.new(color.white, 100), textcolor=autoFg, style=initStyle, size=size.small)
    
    label lbInfo = na
    if dir == 1
        lbInfo := label.new(bar_index[1], bot, infoText, color=color.new(color.white, 100), textcolor=mainCol, style=label.style_label_up, size=size.small)
    else
        lbInfo := label.new(bar_index[1], top, infoText, color=color.new(color.white, 100), textcolor=mainCol, style=label.style_label_down, size=size.small)

    array.push(setups, Setup.new(bx, ln75, ln50, ln25, bxTgt, na, lb75, lb50, lb25, lbTgt, na, lbInfo, dir, lvl50, top, bot, rangeDiff, false, endB, startB, false, false, false))
    
    if boxShowLastN > 0 and array.size(setups) > boxShowLastN
        Setup old = array.shift(setups)
        f_deleteSetup(old)

if array.size(setups) > 0
    for i = array.size(setups) - 1 to 0
        Setup s = array.get(setups, i)
        
        if i == array.size(setups) - 1
            s.endBar := bar_index + boxExtendBars
            line.set_x2(s.l75, s.endBar)
            line.set_x2(s.l50, s.endBar)
            line.set_x2(s.l25, s.endBar)
            if not s.isSupRes
                box.set_right(s.bTgt, s.endBar)
                label.set_x(s.lblTgt, s.endBar)
            if not na(s.bTgt2)
                box.set_right(s.bTgt2, s.endBar)
                
            label.set_x(s.lbl75, s.endBar)
            label.set_x(s.lbl50, s.endBar)
            label.set_x(s.lbl25, s.endBar)
        
        // --- Target Touch Checks ---
        float tgt1Top = box.get_top(s.bTgt)
        float tgt1Bot = box.get_bottom(s.bTgt)
        
        if not s.isTgt1Touched
            if s.dir == 1 and high >= tgt1Bot 
                s.isTgt1Touched := true
            else if s.dir == -1 and low <= tgt1Top 
                s.isTgt1Touched := true
                
        // Position TGT 1 Label if NOT yet Sup/Res
        if not s.isSupRes
            if s.isTgt1Touched
                label.set_x(s.lblTgt, s.endBar)
                label.set_y(s.lblTgt, math.avg(tgt1Top, tgt1Bot))
                label.set_style(s.lblTgt, label.style_label_left)
            else
                label.set_x(s.lblTgt, int(math.avg(s.startBar, s.endBar)))
                if s.dir == 1
                    label.set_y(s.lblTgt, tgt1Top)
                    label.set_style(s.lblTgt, label.style_label_down)
                else
                    label.set_y(s.lblTgt, tgt1Bot)
                    label.set_style(s.lblTgt, label.style_label_up)

        if not na(s.bTgt2)
            float tgt2Top = box.get_top(s.bTgt2)
            float tgt2Bot = box.get_bottom(s.bTgt2)
            
            if not s.isTgt2Touched
                if s.dir == 1 and low <= tgt2Top 
                    s.isTgt2Touched := true
                else if s.dir == -1 and high >= tgt2Bot 
                    s.isTgt2Touched := true
            
            if s.isTgt2Touched
                label.set_x(s.lblTgt2, s.endBar)
                label.set_y(s.lblTgt2, math.avg(tgt2Top, tgt2Bot))
                label.set_style(s.lblTgt2, label.style_label_left)
            else
                label.set_x(s.lblTgt2, int(math.avg(s.startBar, s.endBar)))
                if s.dir == 1 
                    label.set_y(s.lblTgt2, tgt2Bot)
                    label.set_style(s.lblTgt2, label.style_label_up)
                else 
                    label.set_y(s.lblTgt2, tgt2Top)
                    label.set_style(s.lblTgt2, label.style_label_down)

        // --- Inverse Logic ---
        if bar_index <= s.endBar and not s.isInverse
            if s.dir == 1 and close < s.lvl50
                s.isInverse := true
                line.set_color(s.l75, boxBearColor)
                line.set_color(s.l50, boxBearColor)
                line.set_color(s.l25, boxBearColor)
                
                label.set_textcolor(s.lbl75, boxBearColor)
                label.set_textcolor(s.lbl50, boxBearColor)
                label.set_textcolor(s.lbl25, boxBearColor)
                label.set_text(s.lbl50, "0.50 Inverse")
                
                float newTgt1 = s.bot - s.rangeDiff
                float newTgt2 = newTgt1 - (s.rangeDiff * 0.25)
                float newTop = math.max(newTgt1, newTgt2)
                float newBot = math.min(newTgt1, newTgt2)
                
                if s.isTgt1Touched
                    label.set_text(s.lblTgt, "Resistance")
                    label.set_textcolor(s.lblTgt, boxBearColor)
                    
                    // Sup/Res olarak kaydet
                    s.isSupRes := true
                    f_pushSR(s.bTgt, s.lblTgt)
                    
                    s.bTgt2 := box.new(s.startBar, newTop, s.endBar, newBot, border_color=autoFg, bgcolor=na, border_style=line.style_solid)
                    s.lblTgt2 := label.new(int(math.avg(s.startBar, s.endBar)), newTgt1, "Box Target " + str.tostring(newTgt1, format.mintick), color=color.new(color.white, 100), textcolor=autoFg, style=label.style_label_up, size=size.small)
                else
                    box.set_top(s.bTgt, newTop)
                    box.set_bottom(s.bTgt, newBot)
                    s.isTgt1Touched := false 
                
                alert("Bullish Box Inverse Triggered!", alert.freq_once_per_bar_close)
                
            else if s.dir == -1 and close > s.lvl50
                s.isInverse := true
                line.set_color(s.l75, boxBullColor)
                line.set_color(s.l50, boxBullColor)
                line.set_color(s.l25, boxBullColor)
                
                label.set_textcolor(s.lbl75, boxBullColor)
                label.set_textcolor(s.lbl50, boxBullColor)
                label.set_textcolor(s.lbl25, boxBullColor)
                label.set_text(s.lbl50, "0.50 Inverse")
                
                float newTgt1 = s.top + s.rangeDiff
                float newTgt2 = newTgt1 + (s.rangeDiff * 0.25)
                float newTop = math.max(newTgt1, newTgt2)
                float newBot = math.min(newTgt1, newTgt2)
                
                if s.isTgt1Touched
                    label.set_text(s.lblTgt, "Support")
                    label.set_textcolor(s.lblTgt, boxBullColor)
                    
                    // Sup/Res olarak kaydet
                    s.isSupRes := true
                    f_pushSR(s.bTgt, s.lblTgt)
                    
                    s.bTgt2 := box.new(s.startBar, newTop, s.endBar, newBot, border_color=autoFg, bgcolor=na, border_style=line.style_solid)
                    s.lblTgt2 := label.new(int(math.avg(s.startBar, s.endBar)), newTgt1, "Box Target " + str.tostring(newTgt1, format.mintick), color=color.new(color.white, 100), textcolor=autoFg, style=label.style_label_down, size=size.small)
                else
                    box.set_top(s.bTgt, newTop)
                    box.set_bottom(s.bTgt, newBot)
                    s.isTgt1Touched := false 
                
                alert("Bearish Box Inverse Triggered!", alert.freq_once_per_bar_close)
                
        if boxShowLastN == 0 and bar_index > s.endBar + 100
            if i != array.size(setups) - 1 
                Setup old = array.remove(setups, i)
                f_deleteSetup(old)


//#####################################################################
//#                   MARKET STRUCTURE (BOS/CHoCH)                    #
//#####################################################################

inCalc = true
if calcLastBars == 0
    inCalc := true
else
    inCalc := bar_index >= last_bar_index - calcLastBars

L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)

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

var int os = 0  

var line[]  brkLines = array.new_line()
var label[] brkLabs  = array.new_label()

f_trimBroken() =>
    if msShowLastN > 0
        while array.size(brkLines) > msShowLastN
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

if inCalc
    if brkUp
        upBroken := true
        line ln = line.new(upT, upLvl, time, upLvl, xloc=xloc.bar_time, color=brkUpCol, style=brkStyle, width=brkW)
        
        label lb = na
        if lbOn
            string txt = os == -1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)

        f_pushBroken(ln, lb)
        os := 1

    if brkDn
        dnBroken := true
        line ln = line.new(dnT, dnLvl, time, dnLvl, xloc=xloc.bar_time, color=brkDnCol, style=brkStyle, width=brkW)
        
        label lb = na
        if lbOn
            string txt = os == 1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)

        f_pushBroken(ln, lb)
        os := -1

//#####################################################################
//#                   DASHBOARD PANEL                                 #
//#####################################################################
var table dash = na

getPos(pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

getPanelSize(sz) =>
    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "large"  => size.large
        "huge"   => size.huge
        => size.normal

if showPanel and barstate.islast
    color bgPanel = na
    color borderPanel = na 
    color textDark = autoFg    
    color textMuted = color.new(autoFg, 30)   
    
    string tSize = getPanelSize(panelSize)
    
    dash := table.new(getPos(panelPos), 2, 8, border_width = 1, border_color = borderPanel, frame_color = borderPanel, frame_width = 1, bgcolor = bgPanel)
    
    float dOpen = request.security(syminfo.tickerid, "D", open)
    string dBias = close > dOpen ? "Bullish" : "Bearish"
    color dBiasCol = close > dOpen ? boxBullColor : boxBearColor
    
    string msState = os == 1 ? "Bullish" : os == -1 ? "Bearish" : "Neutral"
    color msCol = os == 1 ? boxBullColor : os == -1 ? boxBearColor : textMuted
    
    color rsiCol = rsiVal > 70 ? boxBearColor : rsiVal < 30 ? boxBullColor : textDark
    
    string momTxt = str.tostring(math.abs(curMomRaw), "#.##") + "%" + momArrow
    color momCol = curMomRaw > 0 ? boxBullColor : curMomRaw < 0 ? boxBearColor : textDark
    
    color strCol = latestBoxStrength == "STRONG" ? boxBullColor : textMuted
    
    string diTxt = "+" + str.tostring(diPlus, "#.#") + " / -" + str.tostring(diMinus, "#.#")
    color diCol = diPlus > diMinus ? boxBullColor : boxBearColor
    
    table.cell(dash, 0, 0, " RETEST ENGINE ", text_color=textDark, text_halign=text.align_left, text_size=tSize, bgcolor=na)
    table.cell(dash, 1, 0, " STATS ", text_color=textDark, text_halign=text.align_right, text_size=tSize, bgcolor=na)
    
    table.cell(dash, 0, 1, " Daily Bias ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 1, " " + dBias + " ", text_color=dBiasCol, text_halign=text.align_right, text_size=tSize)
    
    table.cell(dash, 0, 2, " Market Structure ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 2, " " + msState + " ", text_color=msCol, text_halign=text.align_right, text_size=tSize)
    
    table.cell(dash, 0, 3, " RSI (14) ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 3, " " + str.tostring(rsiVal, "#.##") + " ", text_color=rsiCol, text_halign=text.align_right, text_size=tSize)
    
    table.cell(dash, 0, 4, " DI+ / DI- ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 4, " " + diTxt + " ", text_color=diCol, text_halign=text.align_right, text_size=tSize)
    
    table.cell(dash, 0, 5, " Live Momentum ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 5, " " + momTxt + " ", text_color=momCol, text_halign=text.align_right, text_size=tSize)
    
    table.cell(dash, 0, 6, " Latest Box Info ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 6, " " + latestBoxStrength + " ", text_color=strCol, text_halign=text.align_right, text_size=tSize)
    
    float avgBoxVol = totalBoxCount > 0 ? (totalBoxVol / totalBoxCount) : 0
    float avgBoxMom = totalBoxCount > 0 ? (totalBoxMom / totalBoxCount) : 0
    
    table.cell(dash, 0, 7, " Avg Box (Vol|Mom) ", text_color=textMuted, text_halign=text.align_left, text_size=tSize)
    table.cell(dash, 1, 7, " " + f_format_vol(avgBoxVol) + " | " + str.tostring(avgBoxMom, "#.##") + "% ", text_color=textDark, text_halign=text.align_right, text_size=tSize)
````
