# HTF ORDER FLOW [erdensedat]

- url: https://www.tradingview.com/script/ktnIWaRc-HTF-ORDER-FLOW-erdensedat/
- type: indicator
- pine_id: PUB;751c5f4e89b14b9fb245b9d3e0989e31
- version: 1.0

## Description

The HTF ORDER FLOW is an advanced, all-in-one institutional trading indicator designed to bring High Timeframe (HTF) market structure, volume profile dynamics, and order flow context directly to your current chart. By combining deep volume analysis with the BLVL (BOS/CHoCH) break detection algorithm, this script offers a comprehensive view of institutional activity without cluttering your screen.

Key Features:

HTF Candle Projection: Projects the live Higher Timeframe candle (e.g., Daily, Weekly) seamlessly onto your current trading timeframe with customizable width and opacity.
Dynamic Volume Profile: Displays a customized Volume Profile mapped specifically to the HTF period. It highlights the Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL) to instantly visualize where the majority of trading volume took place.
High Volume Nodes (HVN): Automatically highlights specific bins inside the profile that experience significantly higher volume, signaling potential hidden support or resistance areas.
Initial Balance (IB) & VWAP Tracking: Tracks and extends the Initial Balance High/Low and the Volume Weighted Average Price (VWAP) for the HTF session.
Previous Day/Week (PD/PW) Levels: Toggle critical historical liquidity levels such as Previous Day Open/High/Low and Previous Week Open/High/Low, drawing them exactly from their historical birth-points.
Premium & Discount Zones: Automatically calculates and displays Premium and Discount range boxes relative to the HTF candle, helping you visualize equilibrium and optimal entry zones.
Integrated BLVL System (BOS/CHoCH): A built-in Fractal break-of-structure engine that detects and labels potential and confirmed structural shifts (BOS / CHoCH). It displays live candidate lines and solidifies them once a structural break is confirmed by price action.
Custom Styling Engine: Choose from beautiful pre-built visual themes (Classic TV, Cyberpunk, Midnight, Forest, Luxury Gold) or enable total custom control over specific lines like VWAP, VAH/VAL, and IB levels.
The Quantum Signal HUD Panel:
Located at the top right of your chart, the built-in Heads Up Display (HUD) acts as your real-time order flow navigator. It tracks:

Price & VWAP: Current price relation to the HTF VWAP.
Market Bias: Displays a simple BULLISH/BEARISH bias based on the VWAP baseline.
Quantum Signal: Analyzes cumulative volume delta (CVD) relative to VWAP positioning to interpret market state as "INST. BUYING", "INST. SELLING", or "NEUTRAL/TRAP".
Session Progress: Shows the percentage of time elapsed in the current HTF candle.
HTF CVD: The live Cumulative Volume Delta of the ongoing HTF session.
How to Use:
Use the HTF Volume Profile and Premium/Discount boxes to identify where institutions are doing business. Wait for the integrated BLVL system to confirm a structural shift (CHoCH or BOS) inside these key liquidity zones. Check the Quantum Signal HUD to ensure institutional order flow (CVD) aligns with your bias before entering a trade.

Optimize your edge by trading with the HTF trend, volume, and structure.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
indicator("HTF ORDER FLOW [erdensedat]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ==============================================================================
// ----------------------- HTF ORDER FLOW INPUTS & SETUP ------------------------
// ==============================================================================

// --- Theme and Visual Inputs ---
themeMode = input.string("Classic TV", "Active Theme", options = ["Classic TV", "Cyberpunk", "Midnight", "Forest", "Luxury Gold"], group = "Theme Engine")
htfInput  = input.timeframe("D", "HTF Timeframe", group = "General Settings")
offsetInput = input.int(25, "Right Offset", minval = 5, group = "General Settings")
rowSize   = input.int(24, "Volume Rows", minval = 5, group = "General Settings")

// --- Dynamic Color Palettes ---
var color bullColor    = na
var color bearColor    = na
var color vpColor      = na
var color pocColor     = na
var color vwapColor    = na
var color ibColor      = na
var color hudText      = na
var color hudBorder    = na
var color vaLineColor  = na

textColorAuto = themeMode == "Classic TV" ? chart.fg_color : #ffffff

switch themeMode
    "Cyberpunk" =>
        bullColor := #00ffcc, bearColor := #ff2a6d, vpColor := color.new(#05d9e8, 70)
        pocColor := #ff2a6d, vwapColor := #d1fe00, ibColor := #00bfff
        hudText := #ffffff, hudBorder := color.new(#05d9e8, 30), vaLineColor := color.new(#ffffff, 40)
    "Midnight" =>
        bullColor := #4dd0e1, bearColor := #ba68c8, vpColor := color.new(#1a237e, 60)
        pocColor := #f06292, vwapColor := #ffea00, ibColor := #7986cb
        hudText := #e0e0e0, hudBorder := color.new(#ffffff, 20), vaLineColor := color.new(#9e9e9e, 30)
    "Forest" =>
        bullColor := #81c784, bearColor := #e57373, vpColor := color.new(#aed581, 70)
        pocColor := #795548, vwapColor := #ffb74d, ibColor := #d4e157
        hudText := #f5f5dc, hudBorder := color.new(#8d6e63, 40), vaLineColor := color.new(#8d6e63, 50)
    "Luxury Gold" =>
        bullColor := #d4af37, bearColor := #e0e0e0, vpColor := color.new(#333333, 70)
        pocColor := #d4af37, vwapColor := #ffffff, ibColor := #c0c0c0
        hudText := #d4af37, hudBorder := color.new(#d4af37, 30), vaLineColor := color.new(#ffffff, 20)
    => // Classic TV
        bullColor := #089981, bearColor := #f23645, vpColor := color.new(#5b9cf6, 75)
        pocColor := #f23645, vwapColor := #ff9800, ibColor := #ffb74d
        hudText := textColorAuto, hudBorder := color.new(textColorAuto, 30), vaLineColor := color.new(textColorAuto, 30)

group_candle = "HTF Candle & Visuals"
showHtfCandle = input.bool(true, "Show HTF Candle Projection", group = group_candle)
useCustomCandle = input.bool(false, "Use Custom Candle Colors", group = group_candle)
customBullCol   = input.color(#00ffcc, "Custom Bullish Body", group = group_candle)
customBearCol   = input.color(#ff2a6d, "Custom Bearish Body", group = group_candle)
candleWidth     = input.int(10, "Candle Width", minval = 5, group = group_candle)
candleTransp    = input.int(0, "Body Opacity", minval = 0, maxval = 100, group = group_candle)

showHtfStartLine = input.bool(true, "Show HTF Start Vertical Line", group = group_candle)
showRangeBoxes   = input.bool(true, "Show Premium/Discount Boxes", group = group_candle)
lastNBoxes       = input.int(1, "Show Last N Range Boxes", minval = 1, maxval = 50, group = group_candle)

group_lines = "HTF Level Extensions (Back to Candles)"
showOpenLine  = input.bool(true, "Show Opening Line", group = group_lines)
showVahLine   = input.bool(true, "Show VAH Line", group = group_lines)
showValLine   = input.bool(true, "Show VAL Line", group = group_lines)
showPocLine   = input.bool(true, "Show POC Line", group = group_lines)
showVwapLine  = input.bool(true, "Show VWAP Line", group = group_lines)
showIbhLine   = input.bool(true, "Show IB High Line", group = group_lines)
showIblLine   = input.bool(true, "Show IB Low Line", group = group_lines)

group_colors_extra = "Level Custom Colors"
useCustomVwapCol = input.bool(false, "Use Custom VWAP Color", group = group_colors_extra)
customVwapCol    = input.color(#ff9800, "Custom VWAP Color", group = group_colors_extra)
useCustomVaCol   = input.bool(false, "Use Custom VAH/VAL Color", group = group_colors_extra)
customVaCol      = input.color(#ffffff, "Custom VAH/VAL Color", group = group_colors_extra)
useCustomIbCol   = input.bool(false, "Use Custom IB Color", group = group_colors_extra)
customIbCol      = input.color(#ffb74d, "Custom IB Color", group = group_colors_extra)

group_pd = "Previous Day (PD) Levels"
showPdo = input.bool(false, "PD Open (PDO)", group = group_pd)
showPdh = input.bool(false, "PD High (PDH)", group = group_pd)
showPdl = input.bool(false, "PD Low (PDL)", group = group_pd)

group_pw = "Previous Week (PW) Levels"
showPwo = input.bool(false, "PW Open (PWO)", group = group_pw)
showPwh = input.bool(false, "PW High (PWH)", group = group_pw)
showPwl = input.bool(false, "PW Low (PWL)", group = group_pw)

group_vp = "Volume Profile Options"
htfWidth     = input.int(40, "Profile Max Width", minval = 10, group = group_vp)
showLabels   = input.bool(true, "Show Volume Values", group = group_vp)
showNodes    = input.bool(true, "Highlight High Volume Nodes (HVN)", group = group_vp)

// ==============================================================================
// ----------------------- BLVL INPUTS & SETUP ----------------------------------
// ==============================================================================

grpCore = "BLVL - Core"
blvl_len         = input.int(10, "Fractal Length (odd)", minval=3, maxval=51, group=grpCore)
blvl_barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCore)  // DEFAULT 10
blvl_requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

grpPerf = "BLVL - Performance"
blvl_calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
blvl_maxKeep      = input.int(2500, "Max Stored Broken (hard cap)", minval=100, maxval=20000, group=grpPerf)
blvl_showLastN    = input.int(0, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grpPerf)

grpCand = "BLVL - Candidate (Pre-break)"
blvl_candCol     = input.color(color.new(color.black, 60), "Candidate Color (near-black gray)", group=grpCand) // DEFAULT
blvl_candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpCand) // DEFAULT 1
blvl_candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand) // DEFAULT Dotted

blvl_showCandText = input.bool(false, "Show Candidate Text", group=grpCand) // DEFAULT OFF
blvl_candTxtUp    = input.string("BOS ↑", "Candidate UP Text", group=grpCand)
blvl_candTxtDn    = input.string("BOS ↓", "Candidate DN Text", group=grpCand)
blvl_candTxtColUp = input.color(color.rgb(8,153,129), "Candidate UP Text Color (#089981)", group=grpCand) // DEFAULT
blvl_candTxtColDn = input.color(color.new(color.red, 0), "Candidate DN Text Color", group=grpCand)

grpBrk = "BLVL - Broken (Post-break)"
blvl_brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grpBrk) // DEFAULT
blvl_brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)        // DEFAULT red
blvl_brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)              // DEFAULT 1
blvl_brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk) // DEFAULT Solid

grpLbl = "BLVL - BOS/CHoCH Labels"
blvl_lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
blvl_lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
blvl_lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
blvl_lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color (#089981)", group=grpLbl) // DEFAULT
blvl_lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

grpDbg = "BLVL - Debug"
blvl_showPivotMarks = input.bool(false, "Show Pivot Marks", group=grpDbg)

// ==============================================================================
// ----------------------- HTF CORE CALCULATIONS --------------------------------
// ==============================================================================

[dOpen, dHigh, dLow, dClose, dTime, dTimeEnd] = request.security(syminfo.tickerid, htfInput, [open, high, low, close, time, time_close], lookahead = barmerge.lookahead_on)

// Previous Day/Week Data with Start Times for birth-point drawing
[pdTime, pdO, pdH, pdL] = request.security(syminfo.tickerid, "D", [time[1], open[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwTime, pwO, pwH, pwL] = request.security(syminfo.tickerid, "W", [time[1], open[1], high[1], low[1]], lookahead = barmerge.lookahead_on)

isNewPeriod = ta.change(dTime) != 0
var int htfStartBar = 0
var float ibH = na, var float ibL = na
var float totalCVD = 0.0, var float totalVol = 0.0, var float vwapSum = 0.0
var float[] priceHistory = array.new_float(), var float[] volumeHistory = array.new_float()

// Arrays for historical boxes/lines
var box[] premBoxes = array.new_box()
var box[] discBoxes = array.new_box()
var line[] startLines = array.new_line()
var label[] premLabels = array.new_label()
var label[] discLabels = array.new_label()

if isNewPeriod
    htfStartBar := bar_index
    ibH := high, ibL := low, totalCVD := 0.0, totalVol := 0.0, vwapSum := 0.0
    array.clear(priceHistory), array.clear(volumeHistory)
    
    if showHtfStartLine
        newLine = line.new(bar_index, low, bar_index, high, extend = extend.both, color = hudBorder, width = 3)
        array.push(startLines, newLine)
        if array.size(startLines) > lastNBoxes
            line.delete(array.shift(startLines))
            
    if showRangeBoxes
        newPrem = box.new(bar_index, dHigh, bar_index, (dHigh+dLow)/2, border_color = na, bgcolor = color.new(bullColor, 85))
        newDisc = box.new(bar_index, (dHigh+dLow)/2, bar_index, dLow, border_color = na, bgcolor = color.new(bearColor, 85))
        newPremLb = label.new(bar_index, dHigh, "Premium", style=label.style_label_down, color=#00000000, textcolor=hudText, size=size.small)
        newDiscLb = label.new(bar_index, dLow, "Discount", style=label.style_label_up, color=#00000000, textcolor=hudText, size=size.small)
        
        array.push(premBoxes, newPrem)
        array.push(discBoxes, newDisc)
        array.push(premLabels, newPremLb)
        array.push(discLabels, newDiscLb)
        
        if array.size(premBoxes) > lastNBoxes
            box.delete(array.shift(premBoxes))
            box.delete(array.shift(discBoxes))
            label.delete(array.shift(premLabels))
            label.delete(array.shift(discLabels))

curDelta = close >= open ? volume : -volume
totalCVD += curDelta, totalVol += volume, vwapSum += (hlc3 * volume)
array.push(priceHistory, close), array.push(volumeHistory, volume)

if not isNewPeriod and (time - dTime) <= 3600000
    ibH := math.max(nz(ibH, high), high), ibL := math.min(nz(ibL, low), low)

float htfVwap = totalVol > 0 ? vwapSum / totalVol : na
float sessionProgress = math.min(100, ((time - dTime) / math.max(1, dTimeEnd - dTime)) * 100)

// Update current period boxes and labels
if showRangeBoxes and array.size(premBoxes) > 0
    curPrem = array.get(premBoxes, array.size(premBoxes) - 1)
    curDisc = array.get(discBoxes, array.size(discBoxes) - 1)
    box.set_top(curPrem, dHigh)
    box.set_bottom(curPrem, (dHigh+dLow)/2)
    box.set_right(curPrem, bar_index)
    box.set_top(curDisc, (dHigh+dLow)/2)
    box.set_bottom(curDisc, dLow)
    box.set_right(curDisc, bar_index)
    
    curPremLb = array.get(premLabels, array.size(premLabels) - 1)
    curDiscLb = array.get(discLabels, array.size(discLabels) - 1)
    label.set_xy(curPremLb, int(math.avg(box.get_left(curPrem), box.get_right(curPrem))), dHigh)
    label.set_xy(curDiscLb, int(math.avg(box.get_left(curDisc), box.get_right(curDisc))), dLow)

// Birth Bar detection for PD/PW
pdStartBar = ta.valuewhen(time == pdTime, bar_index, 0)
pwStartBar = ta.valuewhen(time == pwTime, bar_index, 0)

// --- Helper Function for Lines ---
f_updateLevelLine(line _l, float _y, bool _visible, int _xStart, int _labelEnd, color _c) =>
    if _visible and not na(_y)
        line.set_xy1(_l, _xStart, _y), line.set_xy2(_l, _labelEnd, _y), line.set_color(_l, _c)
    else
        line.set_color(_l, color.new(color.white, 100))


// ==============================================================================
// ----------------------- BLVL CORE CALCULATIONS -------------------------------
// ==============================================================================

blvl_f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
blvl_f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

blvl_inCalc = true
if blvl_calcLastBars == 0
    blvl_inCalc := true
else
    blvl_inCalc := bar_index >= last_bar_index - blvl_calcLastBars

blvl_L = (blvl_len % 2 == 0) ? (blvl_len + 1) : blvl_len
blvl_p = int(blvl_L / 2)

blvl_tfSec = timeframe.in_seconds(timeframe.period)
blvl_extMs = blvl_tfSec * 1000 * blvl_barsToRight

blvl_candStyle = blvl_f_ls(blvl_candStyleS)
blvl_brkStyle  = blvl_f_ls(blvl_brkStyleS)
blvl_lbSize    = blvl_f_sz(blvl_lbSzS)

blvl_phVal = ta.pivothigh(high, blvl_p, blvl_p)
blvl_plVal = ta.pivotlow(low,  blvl_p, blvl_p)
blvl_phHit = not na(blvl_phVal)
blvl_plHit = not na(blvl_plVal)

plotshape(blvl_showPivotMarks and blvl_phHit, title="PH", style=shape.triangledown, location=location.abovebar, size=size.tiny, text="PH", textcolor = chart.fg_color)
plotshape(blvl_showPivotMarks and blvl_plHit, title="PL", style=shape.triangleup,   location=location.belowbar, size=size.tiny, text="PL", textcolor = chart.fg_color)

var float blvl_upLvl = na
var int   blvl_upT   = na
var bool  blvl_upBroken = false
var line  blvl_upLine = na
var label blvl_upCandLb = na

var float blvl_dnLvl = na
var int   blvl_dnT   = na
var bool  blvl_dnBroken = false
var line  blvl_dnLine = na
var label blvl_dnCandLb = na

var int blvl_os = 0  

var line[]  blvl_brkLines = array.new_line()
var label[] blvl_brkLabs  = array.new_label()

blvl_f_trimBroken() =>
    if blvl_showLastN > 0
        while array.size(blvl_brkLines) > blvl_showLastN
            line oldLn = array.shift(blvl_brkLines)
            label oldLb = array.shift(blvl_brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

    while array.size(blvl_brkLines) > blvl_maxKeep
        line oldLn = array.shift(blvl_brkLines)
        label oldLb = array.shift(blvl_brkLabs)
        if not na(oldLn)
            line.delete(oldLn)
        if not na(oldLb)
            label.delete(oldLb)

blvl_f_pushBroken(line ln, label lb) =>
    array.push(blvl_brkLines, ln)
    array.push(blvl_brkLabs,  lb)
    blvl_f_trimBroken()

if blvl_inCalc
    if blvl_phHit
        if not na(blvl_upLine) and not blvl_upBroken
            line.delete(blvl_upLine)
        if not na(blvl_upCandLb)
            label.delete(blvl_upCandLb)

        blvl_upLvl := blvl_phVal
        blvl_upT   := time[blvl_p]
        blvl_upBroken := false

        blvl_upLine := line.new(blvl_upT, blvl_upLvl, time + blvl_extMs, blvl_upLvl, xloc=xloc.bar_time, extend=extend.none, color=blvl_candCol, style=blvl_candStyle, width=blvl_candW)

        if blvl_showCandText
            blvl_upCandLb := label.new(blvl_upT, blvl_upLvl, blvl_candTxtUp, xloc=xloc.bar_time, style=label.style_label_down, textcolor=blvl_candTxtColUp, color=blvl_lbBg, size=blvl_lbSize)
        else
            blvl_upCandLb := na

    if blvl_plHit
        if not na(blvl_dnLine) and not blvl_dnBroken
            line.delete(blvl_dnLine)
        if not na(blvl_dnCandLb)
            label.delete(blvl_dnCandLb)

        blvl_dnLvl := blvl_plVal
        blvl_dnT   := time[blvl_p]
        blvl_dnBroken := false

        blvl_dnLine := line.new(blvl_dnT, blvl_dnLvl, time + blvl_extMs, blvl_dnLvl, xloc=xloc.bar_time, extend=extend.none, color=blvl_candCol, style=blvl_candStyle, width=blvl_candW)

        if blvl_showCandText
            blvl_dnCandLb := label.new(blvl_dnT, blvl_dnLvl, blvl_candTxtDn, xloc=xloc.bar_time, style=label.style_label_up, textcolor=blvl_candTxtColDn, color=blvl_lbBg, size=blvl_lbSize)
        else
            blvl_dnCandLb := na

if blvl_inCalc
    if not na(blvl_upLine) and not blvl_upBroken
        line.set_x2(blvl_upLine, time + blvl_extMs)
    if not na(blvl_dnLine) and not blvl_dnBroken
        line.set_x2(blvl_dnLine, time + blvl_extMs)

blvl_brkUp = false
blvl_brkDn = false

if blvl_inCalc
    if not na(blvl_upLvl) and not blvl_upBroken
        if blvl_requireBody
            blvl_brkUp := close > blvl_upLvl
        else
            blvl_brkUp := high > blvl_upLvl

    if not na(blvl_dnLvl) and not blvl_dnBroken
        if blvl_requireBody
            blvl_brkDn := close < blvl_dnLvl
        else
            blvl_brkDn := low < blvl_dnLvl

if blvl_inCalc
    if blvl_brkUp
        blvl_upBroken := true

        if not na(blvl_upLine)
            line.set_color(blvl_upLine, blvl_brkUpCol)
            line.set_style(blvl_upLine, blvl_brkStyle)
            line.set_width(blvl_upLine, blvl_brkW)
            line.set_x2(blvl_upLine, time)

        if not na(blvl_upCandLb)
            label.delete(blvl_upCandLb)
            blvl_upCandLb := na

        label lb = na
        if blvl_lbOn
            string txt = blvl_os == -1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, blvl_upT)), blvl_upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=blvl_lbTxtUp, color=blvl_lbBg, size=blvl_lbSize)

        blvl_f_pushBroken(blvl_upLine, lb)
        blvl_upLine := na
        blvl_os := 1

    if blvl_brkDn
        blvl_dnBroken := true

        if not na(blvl_dnLine)
            line.set_color(blvl_dnLine, blvl_brkDnCol)
            line.set_style(blvl_dnLine, blvl_brkStyle)
            line.set_width(blvl_dnLine, blvl_brkW)
            line.set_x2(blvl_dnLine, time)

        if not na(blvl_dnCandLb)
            label.delete(blvl_dnCandLb)
            blvl_dnCandLb := na

        label lb = na
        if blvl_lbOn
            string txt = blvl_os == 1 ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, blvl_dnT)), blvl_dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=blvl_lbTxtDn, color=blvl_lbBg, size=blvl_lbSize)

        blvl_f_pushBroken(blvl_dnLine, lb)
        blvl_dnLine := na
        blvl_os := -1

// ==============================================================================
// ----------------------- HTF VISUALS RENDERING --------------------------------
// ==============================================================================

var box htfBody      = box.new(na, na, na, na, border_width = 2)
var line htfWick     = line.new(na, na, na, na, width = 1)
var line openLine    = line.new(na, na, na, na, style = line.style_dashed, width = 1)
var line vahLine     = line.new(na, na, na, na, style = line.style_dashed, width = 1)
var line valLine     = line.new(na, na, na, na, style = line.style_dashed, width = 1)
var line pocLine     = line.new(na, na, na, na, width = 2)
var line vwapExtLine = line.new(na, na, na, na, width = 2)
var line ibhLine     = line.new(na, na, na, na, width = 1, style = line.style_dotted)
var line iblLine     = line.new(na, na, na, na, width = 1, style = line.style_dotted)
// PD/PW Lines
var line pdoL = line.new(na, na, na, na, style = line.style_dashed), var line pdhL = line.new(na, na, na, na, style = line.style_solid), var line pdlL = line.new(na, na, na, na, style = line.style_solid)
var line pwoL = line.new(na, na, na, na, style = line.style_dashed), var line pwhL = line.new(na, na, na, na, style = line.style_solid), var line pwlL = line.new(na, na, na, na, style = line.style_solid)

var box ibBar        = box.new(na, na, na, na, border_width = 1)
var box[] vpBars     = array.new_box()
var label[] vpLabels = array.new_label()
var table hudTable   = table.new(position.top_right, 2, 11, bgcolor = color.new(#000000, 100), border_width = 1, border_color = hudBorder)

if barstate.islast
    int startX      = bar_index + offsetInput
    int candleEndX  = startX + (showHtfCandle ? candleWidth : 0)
    int vpStartX    = candleEndX + (showHtfCandle ? 8 : 2) 
    int vpMaxEndX   = vpStartX + htfWidth
    int labelX      = vpMaxEndX + 15
    
    color finalBull = useCustomCandle ? customBullCol : bullColor
    color finalBear = useCustomCandle ? customBearCol : bearColor
    color mainColor = dClose >= dOpen ? finalBull : finalBear
    color finalIbColor = useCustomIbCol ? customIbCol : ibColor
    color finalVwapColor = useCustomVwapCol ? customVwapCol : vwapColor
    color finalVaColor = useCustomVaCol ? customVaCol : vaLineColor

    if showHtfCandle
        box.set_lefttop(htfBody, startX, math.max(dOpen, dClose)), box.set_rightbottom(htfBody, candleEndX, math.min(dOpen, dClose))
        box.set_border_color(htfBody, mainColor), box.set_bgcolor(htfBody, color.new(mainColor, candleTransp))
        line.set_xy1(htfWick, startX + candleWidth/2, dHigh), line.set_xy2(htfWick, startX + candleWidth/2, dLow), line.set_color(htfWick, mainColor)
    else
        box.set_lefttop(htfBody, na, na), box.set_rightbottom(htfBody, na, na), line.set_xy1(htfWick, na, na), line.set_xy2(htfWick, na, na)

    for b in vpBars
        box.delete(b)
    array.clear(vpBars)
    for l in vpLabels
        label.delete(l)
    array.clear(vpLabels)

    if array.size(priceHistory) > 0
        float priceStep = (dHigh - dLow) / rowSize
        float maxVol = 0.0, float vSum = 0.0, int pocBin = 0
        map<int, float> binVolMap = map.new<int, float>()
        for i = 0 to array.size(priceHistory) - 1
            int bin = math.max(0, math.min(rowSize - 1, int(math.floor((array.get(priceHistory, i) - dLow) / math.max(0.000001, priceStep)))))
            binVolMap.put(bin, nz(binVolMap.get(bin)) + array.get(volumeHistory, i)), vSum += array.get(volumeHistory, i)
            if nz(binVolMap.get(bin)) > maxVol
                maxVol := nz(binVolMap.get(bin)), pocBin := bin

        float vaTarget = vSum * 0.7, float curVA = nz(binVolMap.get(pocBin))
        int upB = pocBin, int dnB = pocBin
        for j = 1 to rowSize
            if curVA >= vaTarget or (upB >= rowSize - 1 and dnB <= 0)
                break
            vU = upB < rowSize - 1 ? nz(binVolMap.get(upB + 1)) : 0, vD = dnB > 0 ? nz(binVolMap.get(dnB - 1)) : 0
            if vU >= vD and upB < rowSize - 1
                upB += 1, curVA += vU
            else if dnB > 0
                dnB -= 1, curVA += vD

        float vH = dLow + ((upB + 1) * priceStep), float vL = dLow + (dnB * priceStep), float pC = dLow + (pocBin * priceStep) + priceStep/2
        
        // HTF Levels (Extended from current period start)
        f_updateLevelLine(openLine, dOpen, showOpenLine, htfStartBar, labelX, vaLineColor)
        f_updateLevelLine(vahLine, vH, showVahLine, htfStartBar, labelX, finalVaColor)
        f_updateLevelLine(valLine, vL, showValLine, htfStartBar, labelX, finalVaColor)
        f_updateLevelLine(pocLine, pC, showPocLine, htfStartBar, labelX, pocColor)
        f_updateLevelLine(vwapExtLine, htfVwap, showVwapLine, htfStartBar, labelX, finalVwapColor)
        f_updateLevelLine(ibhLine, ibH, showIbhLine, htfStartBar, labelX, finalIbColor)
        f_updateLevelLine(iblLine, ibL, showIblLine, htfStartBar, labelX, finalIbColor)
        
        // PD Levels (Extended from actual Birth Bar)
        f_updateLevelLine(pdoL, pdO, showPdo, pdStartBar, labelX, hudText)
        f_updateLevelLine(pdhL, pdH, showPdh, pdStartBar, labelX, bullColor)
        f_updateLevelLine(pdlL, pdL, showPdl, pdStartBar, labelX, bearColor)
        
        // PW Levels (Extended from actual Birth Bar)
        f_updateLevelLine(pwoL, pwO, showPwo, pwStartBar, labelX, hudText)
        f_updateLevelLine(pwhL, pwH, showPwh, pwStartBar, labelX, bullColor)
        f_updateLevelLine(pwlL, pwL, showPwl, pwStartBar, labelX, bearColor)
        
        // Individual Label Visibility Controls
        if true
            if showOpenLine
                array.push(vpLabels, label.new(labelX, dOpen, "OPEN", color=#00000000, textcolor=hudText, style=label.style_label_left, size=size.small))
            if showVahLine
                array.push(vpLabels, label.new(labelX, vH, "VAH", color=#00000000, textcolor=finalVaColor, style=label.style_label_left, size=size.small))
            if showValLine
                array.push(vpLabels, label.new(labelX, vL, "VAL", color=#00000000, textcolor=finalVaColor, style=label.style_label_left, size=size.small))
            if showPocLine
                array.push(vpLabels, label.new(labelX, pC, "POC", color=#00000000, textcolor=pocColor, style=label.style_label_left, size=size.small))
            if showVwapLine
                array.push(vpLabels, label.new(labelX, htfVwap, "VWAP", color=#00000000, textcolor=finalVwapColor, style=label.style_label_left, size=size.small))
            if showIbhLine
                array.push(vpLabels, label.new(labelX, ibH, "IBH", color=#00000000, textcolor=finalIbColor, style=label.style_label_left, size=size.small))
            if showIblLine
                array.push(vpLabels, label.new(labelX, ibL, "IBL", color=#00000000, textcolor=finalIbColor, style=label.style_label_left, size=size.small))
            
            // PD Independent Labels
            if showPdo
                array.push(vpLabels, label.new(labelX, pdO, "PDO", color=#00000000, textcolor=hudText, style=label.style_label_left, size=size.small))
            if showPdh
                array.push(vpLabels, label.new(labelX, pdH, "PDH", color=#00000000, textcolor=bullColor, style=label.style_label_left, size=size.small))
            if showPdl
                array.push(vpLabels, label.new(labelX, pdL, "PDL", color=#00000000, textcolor=bearColor, style=label.style_label_left, size=size.small))
            
            // PW Independent Labels
            if showPwo
                array.push(vpLabels, label.new(labelX, pwO, "PWO", color=#00000000, textcolor=hudText, style=label.style_label_left, size=size.small))
            if showPwh
                array.push(vpLabels, label.new(labelX, pwH, "PWH", color=#00000000, textcolor=bullColor, style=label.style_label_left, size=size.small))
            if showPwl
                array.push(vpLabels, label.new(labelX, pwL, "PWL", color=#00000000, textcolor=bearColor, style=label.style_label_left, size=size.small))

        avgBinV = vSum / rowSize
        for i = 0 to rowSize - 1
            v = nz(binVolMap.get(i))
            if v > 0
                float btm = dLow + (i * priceStep), top = btm + priceStep
                int w = math.round((v / (maxVol > 0 ? maxVol : 1)) * htfWidth)
                array.push(vpBars, box.new(vpStartX, top, vpStartX + w, btm, bgcolor = (i == pocBin ? color.new(pocColor, 40) : vpColor), border_color = color.new(vpColor, 90)))
                if showNodes and v > (i > 0 ? nz(binVolMap.get(i - 1)) : 0) and v > (i < rowSize - 1 ? nz(binVolMap.get(i + 1)) : 0) and v > avgBinV * 1.2 and i != pocBin
                    array.push(vpLabels, label.new(vpStartX + w, (top + btm) / 2, "◊", color=#00000000, textcolor=hudText, style=label.style_label_left, size=size.tiny))
                if showLabels
                    string txt = v > 1000000 ? str.tostring(v/1000000, "#.#") + "M" : (v > 1000 ? str.tostring(v/1000, "#.#") + "K" : str.tostring(v, "#"))
                    array.push(vpLabels, label.new(vpStartX + w, (top+btm)/2, txt, color=#00000000, textcolor=hudText, style=label.style_label_left, size=size.tiny))

    box.set_lefttop(ibBar, vpStartX - 5, ibH), box.set_rightbottom(ibBar, vpStartX - 1, ibL), box.set_border_color(ibBar, finalIbColor), box.set_bgcolor(ibBar, color.new(finalIbColor, 40))

    biasText  = close > htfVwap ? "BULLISH" : "BEARISH", biasCol = close > htfVwap ? bullColor : bearColor
    marketState = (close > htfVwap and totalCVD > 0) ? "INST. BUYING" : (close < htfVwap and totalCVD < 0) ? "INST. SELLING" : "NEUTRAL/TRAP"
    stateCol = marketState == "INST. BUYING" ? bullColor : (marketState == "INST. SELLING" ? bearColor : finalVwapColor)

    table.cell(hudTable, 0, 0, "HTF QUANTUM SIGNAL", text_color = hudText, text_halign = text.align_center), table.merge_cells(hudTable, 0, 0, 1, 0)
    table.cell(hudTable, 0, 1, "Price", text_color = hudText, text_halign = text.align_left), table.cell(hudTable, 1, 1, str.tostring(close), text_color = biasCol, text_halign = text.align_right)
    table.cell(hudTable, 0, 2, "VWAP", text_color = hudText, text_halign = text.align_left), table.cell(hudTable, 1, 2, str.tostring(htfVwap, "#.##"), text_color = finalVwapColor, text_halign = text.align_right)
    table.cell(hudTable, 0, 3, "Market Bias", text_color = hudText, text_halign = text.align_left), table.cell(hudTable, 1, 3, biasText, text_color = biasCol, text_halign = text.align_right)
    table.cell(hudTable, 0, 4, "Quantum Signal", text_color = hudText, text_halign = text.align_left), table.cell(hudTable, 1, 4, marketState, text_color = stateCol, text_halign = text.align_right)
    table.cell(hudTable, 0, 5, "Progress", text_color = hudText, text_halign = text.align_left), table.cell(hudTable, 1, 5, str.tostring(sessionProgress, "#") + "%", text_color = hudText, text_halign = text.align_right)
    table.cell(hudTable, 0, 6, "HTF CVD", text_color = hudText, text_halign = text.align_left), table.cell(hudTable, 1, 6, str.tostring(totalCVD, "###,###"), text_color = totalCVD >= 0 ? bullColor : bearColor, text_halign = text.align_right)
````
