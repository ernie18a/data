# FVG Bias Finder [erdensedat]

- url: https://www.tradingview.com/script/xjXBqWYi-FVG-Bias-Finder-erdensedat/
- type: indicator
- pine_id: PUB;5d56f4fb394845d3bc4ca9f2caa443b6
- version: 2.0

## Description

The "FVG Bias Finder [erdensedat]" is an advanced, all-in-one price action toolkit designed to help traders identify structural shifts, market bias, and high-probability zones of interest. By combining core Smart Money Concepts (SMC) such as Break of Structure (BOS), Change of Character (CHoCH), and Fair Value Gaps (FVG), this script provides a clear and objective view of the market trend and institutional footprints.

Key Features & Functionality

Dynamic Market Structure (BOS & CHoCH):
The indicator automatically maps out pivot highs and lows (fractals) to detect structural breaks. Pre-break "candidate" lines help you anticipate incoming structure shifts. Once broken, the lines dynamically change to indicate a confirmed BOS or CHoCH.
High-Volume BOS Detection:
Not all breakouts are equal. The script filters and highlights structural breaks that occur with significant volume (volume exceeding a configurable SMA multiplier). It plots a highlighted zone and prints the exact volume at the breakdown/breakout point, confirming true displacement.
Advanced FVG Engine (erdensedat):
The core of the indicator heavily relies on detecting Fair Value Gaps (FVGs).
Draws bullish and bearish FVGs with customizable lengths and threshold filters based on ATR.
Tracks mitigation logic in real-time (Close, Wick, or Average).
Overlap hiding capabilities to keep your charts clean.
Plots a dynamic SMA trajectory inside the unmitigated gaps to gauge short-term trend strength within the zone.
Bias Directional Signals:
The indicator removes the guesswork by printing explicit Bullish (Green) and Bearish (Red) arrows. A signal is triggered when:
A BOS occurs while a corresponding directional FVG is currently active.
A BOS and a fresh FVG are confirmed on the exact same candle.
This creates high-probability setups, confirming that structural breaks are supported by strong momentum (displacement).
Additional Confluence Tools:
Built-in toggles allow you to overlay VWAP and up to two Moving Averages (SMA, EMA, RMA, WMA, HMA) directly from the indicator settings, eliminating the need to clutter your chart with multiple separate indicators.
How to Use It

Trend Following: Use the BOS/CHoCH mapping in combination with the directional arrows to ride the prevailing trend. When an arrow prints, it signifies that structure has shifted with institutional displacement (FVG).
Entries & Pullbacks: Wait for the price to retrace into the active unmitigated FVG boxes (Bullish Green / Bearish Red zones) following a structural break to find optimal trade entries.
Filtering Noise: Pay close attention to the "High Volume" highlights on the BOS lines. A break of structure backed by high volume implies a stronger likelihood of continuation.
Disclaimer: This script is an analytical tool and does not guarantee future performance. Always use proper risk management.

## Source Code

````pine
// © erdensedat
//@version=6
indicator("FVG Bias Finder [erdensedat]", shorttitle="FVG Bias [erdensedat]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_polylines_count=100)

//==================== BOS CORE ====================
grpCore = "Core"
len         = input.int(6, "Fractal Length", minval=3, maxval=51, group=grpCore)
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCore)  // DEFAULT 10
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

grpPerf = "Performance"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
showLastN    = input.int(0, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

grpCand = "Candidate (Pre-break)"
candCol     = input.color(color.new(color.black, 60), "Candidate Color (near-black gray)", group=grpCand) // DEFAULT
candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpCand) // DEFAULT 1
candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand) // DEFAULT Dotted

showCandText = input.bool(true, "Show Candidate Text", group=grpCand) // CHANGED DEFAULT TO TRUE
candTxtUp    = input.string("BOS ↑", "Candidate UP Text", group=grpCand)
candTxtDn    = input.string("BOS ↓", "Candidate DN Text", group=grpCand)
candTxtColUp = input.color(color.rgb(8,153,129), "Candidate UP Text Color (#089981)", group=grpCand) // DEFAULT
candTxtColDn = input.color(color.new(color.red, 0), "Candidate DN Text Color", group=grpCand)

grpBrk = "Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpBrk) // DEFAULT
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)        // DEFAULT red
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)              // DEFAULT 1
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk) // DEFAULT Solid

grpLbl = "BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color (#089981)", group=grpLbl) // DEFAULT
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

grpVol = "High Volume BOS"
showVolBos = input.bool(true, "Highlight High Volume BOS", group=grpVol)
volMult    = input.float(1.5, "Volume Multiplier vs SMA(20)", group=grpVol)

grpMA = "Moving Averages & VWAP"
showVwap   = input.bool(false, "Show VWAP", group=grpMA)

showMa1    = input.bool(false, "Show MA 1", group=grpMA, inline="ma1")
ma1Type    = input.string("SMA", "", options=["SMA", "EMA", "RMA", "WMA", "HMA"], group=grpMA, inline="ma1")
ma1Len     = input.int(50, "", group=grpMA, inline="ma1", minval=1)

showMa2    = input.bool(false, "Show MA 2", group=grpMA, inline="ma2")
ma2Type    = input.string("SMA", "", options=["SMA", "EMA", "RMA", "WMA", "HMA"], group=grpMA, inline="ma2")
ma2Len     = input.int(200, "", group=grpMA, inline="ma2", minval=1)

f_ma(type, len) =>
    switch type
        "SMA" => ta.sma(close, len)
        "EMA" => ta.ema(close, len)
        "RMA" => ta.rma(close, len)
        "WMA" => ta.wma(close, len)
        "HMA" => ta.hma(close, len)
        => ta.sma(close, len)

// Optional VWAP and MAs
plot(showVwap ? ta.vwap : na, "VWAP", color=color.new(#2962FF, 0), linewidth=2)
plot(showMa1 ? f_ma(ma1Type, ma1Len) : na, "MA 1", color=color.new(#FF9800, 0), linewidth=2)
plot(showMa2 ? f_ma(ma2Type, ma2Len) : na, "MA 2", color=color.new(#9C27B0, 0), linewidth=2)

// Helpers
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

candStyle = f_ls(candStyleS)
brkStyle  = f_ls(brkStyleS)
lbSize    = f_sz(lbSzS)

inCalc = true
if calcLastBars != 0
    inCalc := bar_index >= last_bar_index - calcLastBars

L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)
tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight

phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

//==================== STRUCTURE MAPPING ====================
grpMap = "Structure Mapping"
showMapping = input.bool(false, "Show Structure Mapping", group=grpMap)
mapColor = input.color(color.new(color.gray, 50), "Mapping Line Color", group=grpMap)
mapWidth = input.int(1, "Mapping Line Width", minval=1, maxval=5, group=grpMap)

var int lastPivotType = 0
var float lastPivotVal = na
var int lastPivotTime = na
var line lastMapLine = na

if showMapping and inCalc
    if phHit
        if lastPivotType != 1
            if not na(lastPivotTime)
                lastMapLine := line.new(lastPivotTime, lastPivotVal, time[p], phVal, xloc=xloc.bar_time, color=mapColor, width=mapWidth)
            lastPivotType := 1
            lastPivotVal := phVal
            lastPivotTime := time[p]
        else
            if phVal > lastPivotVal
                if not na(lastMapLine)
                    line.set_xy2(lastMapLine, time[p], phVal)
                lastPivotVal := phVal
                lastPivotTime := time[p]
                
    if plHit
        if lastPivotType != -1
            if not na(lastPivotTime)
                lastMapLine := line.new(lastPivotTime, lastPivotVal, time[p], plVal, xloc=xloc.bar_time, color=mapColor, width=mapWidth)
            lastPivotType := -1
            lastPivotVal := plVal
            lastPivotTime := time[p]
        else
            if plVal < lastPivotVal
                if not na(lastMapLine)
                    line.set_xy2(lastMapLine, time[p], plVal)
                lastPivotVal := plVal
                lastPivotTime := time[p]


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
            oldLn = array.shift(brkLines)
            oldLb = array.shift(brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)
    while array.size(brkLines) > maxKeep
        oldLn = array.shift(brkLines)
        oldLb = array.shift(brkLabs)
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
        brkUp := requireBody ? close > upLvl : high > upLvl
    if not na(dnLvl) and not dnBroken
        brkDn := requireBody ? close < dnLvl : low < dnLvl

// High Volume Logic
isHighVol = volume > ta.sma(volume, 20) * volMult

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
            txt = os == -1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)
        f_pushBroken(upLine, lb)
        upLine := na
        os := 1
        
        // Volume Box & Label
        if showVolBos
            volText = str.tostring(volume, format.volume) + (isHighVol ? " *" : "")
            if isHighVol
                box.new(left=bar_index-1, top=high, right=bar_index, bottom=low, xloc=xloc.bar_index, border_color=brkUpCol, border_width=2, bgcolor=color.new(brkUpCol, 85))
            label.new(bar_index, low, volText, yloc=yloc.belowbar, style=label.style_label_up, textcolor=brkUpCol, color=color.new(color.white, 100), size=size.small)

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
            txt = os == 1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)
        f_pushBroken(dnLine, lb)
        dnLine := na
        os := -1
        
        // Volume Box & Label
        if showVolBos
            volText = str.tostring(volume, format.volume) + (isHighVol ? " *" : "")
            if isHighVol
                box.new(left=bar_index-1, top=high, right=bar_index, bottom=low, xloc=xloc.bar_index, border_color=brkDnCol, border_width=2, bgcolor=color.new(brkDnCol, 85))
            label.new(bar_index, high, volText, yloc=yloc.abovebar, style=label.style_label_down, textcolor=brkDnCol, color=color.new(color.white, 100), size=size.small)


//==================== NEW FVG ENGINE ====================
grpFVG = "FAIR VALUE GAP"
fvg_enable   = input.bool(true, "", inline="1", group=grpFVG, tooltip="Display fair value gap")
what_fvg     = input.string("FVG", "", inline="1", group=grpFVG, tooltip="Display fair value gap", options=["FVG", "Breakers"])
fvg_num      = input.int(3, "Show Last", inline="1a", group=grpFVG, tooltip="Number of fvg to show", minval=0)
fvg_upcss    = input.color(color.new(#089981, 80), "", inline="1", group=grpFVG)
fvg_dncss    = input.color(color.new(#f23645, 80), "", inline="1", group=grpFVG)
fvg_src      = input.string("Close", "Mitigation", inline="3", group=grpFVG, tooltip="[Close] Use the close of the body as trigger\n\n[Wick] Use the extreme point of the body as trigger", options=["Close", "Wick", "Avg"])
fvgthresh    = input.float(0, "Threshold", tooltip="Filter out non significative FVG", group=grpFVG, inline="asd", minval=0, maxval=2, step=0.1)
fvgoverlap   = input.bool(true, "Hide Overlap", tooltip="Hide overlapping FVG", group=grpFVG)
fvgline      = input.bool(true, "Show Mid-Line", group=grpFVG)
fvgextend    = input.bool(false, "Extend FVG", group=grpFVG)
dispraid     = input.bool(true, "Display Raids", inline="raid", group=grpFVG)

type FVG
    float top     = na
    float btm     = na
    int   loc     = bar_index
    bool  isbb    = false
    int   bbloc   = na
    bool  israid  = false
    float raidy   = na
    int   raidloc = na
    int   raidx2  = na
    bool  active  = false
    color raidcs  = na

type store
    line    [] ln
    label   [] lb
    box     [] bx
    linefill[] lf

var store bin = store.new(array.new<line>(), array.new<label>(), array.new<box>(), array.new<linefill>())

if barstate.islast
    for obj in bin.ln
        obj.delete()
    for obj in bin.lb
        obj.delete()
    for obj in bin.bx
        obj.delete()
    
    bin.ln.clear()
    bin.lb.clear()
    bin.bx.clear()

ghl() => [high[2], low[2], close[1], open[1], close, open, high, low, high[1], low[1], ta.atr(200)]

overlapFVG(FVG[] blFVG, FVG[] brFVG) =>
    if blFVG.size() > 1
        for i = blFVG.size() - 1 to 1
            stuff = blFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)

    if brFVG.size() > 1
        for i = brFVG.size() - 1 to 1
            stuff = brFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

    if blFVG.size() > 0 and brFVG.size() > 0
        for i = blFVG.size() - 1 to 0
            stuff = blFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)

    if blFVG.size() > 0 and brFVG.size() > 0
        for i = brFVG.size() - 1 to 0
            stuff = brFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

method dispFVG(FVG fvg, int i, bool bull) =>
    ext = fvgextend ? extend.right : extend.none
    if not fvg.isbb
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = time, border_color = color.new(bull ? fvg_upcss : fvg_dncss, 0), border_style=line.style_dashed, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), xloc = xloc.bar_time, color = color.new(bull ? fvg_upcss : fvg_dncss, 0), extend = ext))
        if dispraid
            bin.ln.unshift(line.new(x1 = fvg.raidloc, x2 = fvg.raidx2, y1 = fvg.raidy, y2 = fvg.raidy, xloc = xloc.bar_time, color = fvg.raidcs))
            bin.lb.unshift(label.new(x = int(math.avg(fvg.raidloc, fvg.raidx2)), y = fvg.raidy, text = "x", xloc = xloc.bar_time, textcolor = fvg.raidcs, style = bull ? label.style_label_up : label.style_label_down, size = size.small, color = #ffffff00))

    else
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = fvg.bbloc, border_color = color.new(bull ? fvg_upcss : fvg_dncss, 0), border_style=line.style_dashed, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.bbloc, right = time, border_color = bull ? fvg_dncss : fvg_upcss, border_style=line.style_dashed, bgcolor = bull ? fvg_dncss : fvg_upcss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = fvg.bbloc, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_upcss : fvg_dncss, 0), xloc = xloc.bar_time))
            bin.ln.unshift(line.new(x1 = fvg.bbloc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_dncss : fvg_upcss, 0), xloc = xloc.bar_time, extend = ext, style = line.style_dashed))

[h2, l2, c1, o1, c, o, h, l, h1, l1, fvatr] = ghl()
var FVG[] blFVG = array.new<FVG>()
var FVG[] brFVG = array.new<FVG>()
bool upfvg = false
bool dnfvg = false
float blth = l1 + (fvatr[1] * fvgthresh)
float brth = h1 - (fvatr[1] * fvgthresh)

cc = timeframe.change()

if fvg_enable
    switch
        what_fvg == "FVG" or what_fvg == "Breakers" =>
            if l > h2 and cc and c1 > blth
                upfvg := true
                
            if l2 > h and cc and c1 < brth
                dnfvg := true

    if upfvg[1]
        if blFVG.size() > 0
            fvg = blFVG.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        blFVG.unshift(FVG.new(top = l[1], btm = h2[1], loc = time[3]))

    if dnfvg[1]
        if brFVG.size() > 0
            fvg = brFVG.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        brFVG.unshift(FVG.new(top = l2[1], btm = h[1], loc = time[3]))

    if blFVG.size() > 0
        for [i, fvg] in blFVG
            if not fvg.isbb
                if fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        blFVG.remove(i)
            else
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    blFVG.remove(i)
                    
    if brFVG.size() > 0
        for [i, fvg] in brFVG
            if not fvg.isbb
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false)
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        brFVG.remove(i)
            else
                if (fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    brFVG.remove(i)
                    
    if fvgoverlap
        overlapFVG(blFVG, brFVG)

    if dispraid
        for [i, fvg] in blFVG
            if not fvg.israid and not fvg.isbb
                if low < fvg.top and close > fvg.top
                    fvg.israid  := true
                    fvg.raidloc := time
                    fvg.raidx2  := time
                    fvg.raidy   := low
                    fvg.raidcs  := chart.fg_color
            else
                if low <= fvg.raidy and fvg.active == false and not fvg.isbb
                    fvg.active := true
                    fvg.raidx2 := time
                else
                    if fvg.active == false and not fvg.isbb
                        fvg.raidx2 := time

        for [i, fvg] in brFVG
            if not fvg.israid and not fvg.isbb
                if high > fvg.btm and close < fvg.btm and not fvg.isbb
                    fvg.israid  := true
                    fvg.raidloc := time
                    fvg.raidy   := high
                    fvg.raidx2  := time
                    fvg.raidcs  := chart.fg_color
            else
                if high >= fvg.raidy and fvg.active == false and not fvg.isbb
                    fvg.active := true
                    fvg.raidx2 := time
                else
                    if fvg.active == false and not fvg.isbb
                        fvg.raidx2 := time

    if barstate.islast
        if blFVG.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, blFVG.size() - 1)
                fvg = blFVG.get(i)
                dispFVG(fvg, i, true)

        if brFVG.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, brFVG.size() - 1)
                fvg = brFVG.get(i)
                dispFVG(fvg, i, false)

bool bullFvgActive = false
for f in blFVG
    if not f.isbb
        bullFvgActive := true
        break

bool bearFvgActive = false
for f in brFVG
    if not f.isbb
        bearFvgActive := true
        break

//==================== TREND SIGNALS (ARROWS) ====================
bool plotBullArrow = false
bool plotBearArrow = false

// 1. If BOS occurs while matching FVG is active
if brkUp and bullFvgActive
    plotBullArrow := true

if brkDn and bearFvgActive
    plotBearArrow := true

// 2. If the current bar breaks BOS *and* confirms FVG simultaneously
if brkUp and upfvg
    plotBullArrow := true

if brkDn and dnfvg
    plotBearArrow := true

// Plot signals on current bar
plotshape(plotBullArrow, title="Bull Direction (Current)", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(plotBearArrow, title="Bear Direction (Current)", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// 3. If the *previous* bar created the BOS (the strong displacement candle) 
// and the *current* bar confirms an FVG, we plot the arrow on that previous displacement candle.
bool plotBullArrow_prev = brkUp[1] and upfvg
bool plotBearArrow_prev = brkDn[1] and dnfvg

plotshape(plotBullArrow_prev, title="Bull Direction (Displacement)", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, offset=-1)
plotshape(plotBearArrow_prev, title="Bear Direction (Displacement)", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, offset=-1)
````
