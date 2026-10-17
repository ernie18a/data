# Touch Turn Reversal Zones

- url: https://www.tradingview.com/script/mYBtzUnP-Touch-Turn-Reversal-Zones/
- type: indicator
- pine_id: PUB;d1760c73665c4ae799b7a265b8de5bbb
- version: 3.0

## Description

Description:

The Touch Turn Reversal Zones indicator is a comprehensive tool designed to help traders read market structure, establish directional bias, and identify high-probability reversal zones. By combining Market Structure shifts (BOS/CHoCH) with automated Fibonacci-based logic, this script highlights precise points of interest where the price is most likely to react.

Key Features & How It Helps:

Upper & Lower Touch-Turn (TT) Boxes: These target boxes represent near-ideal areas for direct price reversals. When price enters or wicks into these zones and subsequently closes in the opposite direction, the box is "activated" and visually highlighted (becoming brighter). The indicator will keep the most recently activated box prominent until a new setup triggers, allowing you to easily track the current active reversal point.
The 0.5 Level Magnet: A core component of this strategy revolves around the 0.5 Fibonacci levels generated from CHoCH legs. When multiple 0.5 levels cluster together (grouped 0.5 lines), they create a high-confluence zone. In market dynamics, price naturally gravitates towards these grouped levels.
Targeting & Bias Reading: The script not only pinpoints where a reversal might start but also helps predict where the move could end. For example, if the price bounces perfectly from a Lower TT Box, the immediate and most logical target for that bullish reversal is often the nearest cluster of grouped 0.5 levels above. This allows traders to effectively gauge their bias and establish clear take-profit zones.
Internal & External Range Liquidity (IRL / ERL): The code maps out swing pivots (ERL) and Fair Value Gaps (IRL). This provides additional context on liquidity sweeps and market imbalances that often precede or confirm reversals.
Comprehensive Alert System:
The indicator includes a built-in, ready-to-use alert system to keep you notified of structural changes in real-time:

https://www.tradingview.com/x/iOKoirV8/

https://www.tradingview.com/x/VoKzpmTb/

Box Activation Alerts: Get notified instantly when the Lower Box is Active or the Upper Box is Active (triggering a Touch & Turn).
Combined Confluence Alerts: Optional alerts allow you to be notified when an active box perfectly aligns with the creation of structural liquidity, such as “Lower Box Active with Bullish IRL Created” or “Upper Box Active with Bearish IRL Created”. This helps you catch reversals backed by strong momentum and imbalance confirmation.
Whether you are trying to catch a precise reversal or aiming to ride the wave toward clustered equilibrium (0.5) levels, the Touch Turn Reversal Zones indicator provides a clear, structured roadmap of price action.

Disclaimer: This indicator is designed for educational and informational purposes only. Trading in financial markets involves a high degree of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always perform your own backtesting, use proper risk management, and never make financial decisions based solely on the signals of a single indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("Touch Turn Reversal Zones", shorttitle="Touch Turn Reversal Zones", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//==================== WATERMARK ====================
var table wmTable = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wmTable, 0, 0, "erdensedat", text_color=color.new(color.gray, 70), text_size=size.huge)

//==================== MARKET STRUCTURE CORE ====================
grpCore = "Core Market Structure"
len         = input.int(10, "Fractal Length (odd)", minval=3, maxval=51, group=grpCore)
barsToRight = input.int(10, "Bars to Right", minval=1, maxval=300, group=grpCore)
requireBody = input.bool(true, "Break = Close Beyond Level", group=grpCore)

//==================== PERFORMANCE & LIMITS ====================
grpPerf = "Performance & Limits"
calcLastBars = input.int(20000, "Calc Only Last N Bars (0=all)", minval=0, maxval=50000, group=grpPerf)
maxKeep      = input.int(500, "Max Stored Broken (hard cap)", minval=50, maxval=2000, group=grpPerf)
showLastN    = input.int(4, "Show Last N Broken (0=all)", minval=0, maxval=500, group=grpPerf) // Default 4

//==================== MS CANDIDATE & BROKEN ====================
grpCand = "Candidate (Pre-break)"
candCol     = input.color(color.new(color.black, 60), "Candidate Color", group=grpCand)
candW       = input.int(1, "Candidate Width", minval=1, maxval=5, group=grpCand)
candStyleS  = input.string("Dotted", "Candidate Style", options=["Solid","Dashed","Dotted"], group=grpCand)

grpBrk = "Broken (Post-break)"
brkUpCol   = input.color(color.rgb(8,153,129), "Broken UP Color", group=grpBrk)
brkDnCol   = input.color(color.new(color.red, 0), "Broken DN Color", group=grpBrk)
brkW       = input.int(1, "Broken Width", minval=1, maxval=5, group=grpBrk)
brkStyleS  = input.string("Solid", "Broken Style", options=["Solid","Dashed","Dotted"], group=grpBrk)

//==================== CHOCH FIB ZONES ====================
grpFib = "CHoCH Fib Zones"
showFib     = input.bool(true, "Show Fib on CHoCH", group=grpFib)
fibMode     = input.string("Cool", "Fib Pivot Mode", options=["Aggressive", "Cool"], group=grpFib, tooltip="Aggressive: Tracks the absolute lowest/highest point during the move.\nCool: Uses the last confirmed Market Structure pivot.")
fibLineCol  = input.color(color.new(color.orange, 70), "Fib 0.5 Level Color", group=grpFib)
fibBullCol  = input.color(color.new(#006064, 70), "Upper Target Box (1.47 - 1.55)", group=grpFib)
fibBearCol  = input.color(color.new(#801922, 70), "Lower Target Box (0.2 - 0.23)", group=grpFib)
fibMaxKeep  = input.int(10, "Keep Last N Fib Setups", group=grpFib, minval=1, maxval=20)
fibMergeDist= input.float(0.4, "Merge Distance % (for 3+ Fibs)", group=grpFib, step=0.01)

//==================== LABELS ====================
grpLbl = "BOS/CHoCH Labels"
lbOn     = input.bool(true, "Show BOS/CHoCH Labels", group=grpLbl)
lbSzS    = input.string("tiny", "Label Size", options=["tiny","small","normal"], group=grpLbl)
lbBg     = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grpLbl)
lbTxtUp  = input.color(color.rgb(8,153,129), "UP Label Text Color", group=grpLbl)
lbTxtDn  = input.color(color.new(color.red, 0), "DN Label Text Color", group=grpLbl)

//==================== IRL / ERL INPUTS ====================
grp_erl = "External Range Liquidity (ERL)"
pivotLeft   = input.int(5, "Swing Left", group = grp_erl)
pivotRight  = input.int(5, "Swing Right", group = grp_erl)
erlMaxKeep  = input.int(10, "Keep Last N ERL", group = grp_erl)
erlBull     = input.color(color.new(#089981, 30), "ERL Support Color", group = grp_erl)
erlBear     = input.color(color.new(#f23645, 30), "ERL Resistance Color", group = grp_erl)

grp_irl = "Internal Range Liquidity (IRL)"
showIrl     = input.bool(false, "Show IRL Boxes", group = grp_irl)
irlBull     = input.color(color.new(#089981, 90), "IRL Bullish (FVG) Color", group = grp_irl)
irlBear     = input.color(color.new(#f23645, 90), "IRL Bearish (FVG) Color", group = grp_irl)

//==================== HELPERS ====================
f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
f_sz(string s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

//==================== PERF GATE & GLOBALS ====================
inCalc = bar_index >= last_bar_index - calcLastBars or calcLastBars == 0
L = (len % 2 == 0) ? (len + 1) : len
p = int(L / 2)
tfSec = timeframe.in_seconds(timeframe.period)
extMs = tfSec * 1000 * barsToRight

candStyle = f_ls(candStyleS)
brkStyle  = f_ls(brkStyleS)
lbSize    = f_sz(lbSzS)

//==================== MS PIVOTS ====================
phVal = ta.pivothigh(high, p, p)
plVal = ta.pivotlow(low,  p, p)
phHit = not na(phVal)
plHit = not na(plVal)

// Track extreme lows/highs for Fib legs
var float lowestSincePh = na
var int   lowestSincePhT = na
var float lastConfirmedPh = na
var int   lastConfirmedPhT = na

if phHit
    lowestSincePh := low[p]
    lowestSincePhT := time[p]
    lastConfirmedPh := phVal
    lastConfirmedPhT := time[p]
else if not na(lowestSincePh)
    if low < lowestSincePh
        lowestSincePh := low
        lowestSincePhT := time

var float highestSincePl = na
var int   highestSincePlT = na
var float lastConfirmedPl = na
var int   lastConfirmedPlT = na

if plHit
    highestSincePl := high[p]
    highestSincePlT := time[p]
    lastConfirmedPl := plVal
    lastConfirmedPlT := time[p]
else if not na(highestSincePl)
    if high > highestSincePl
        highestSincePl := high
        highestSincePlT := time

//==================== MS CANDIDATE STATE ====================
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

var int os = 0  // last break direction: +1 up, -1 down, 0 none

//==================== BROKEN & FIB STORAGE ====================
var line[]  brkLines = array.new_line()
var label[] brkLabs  = array.new_label()

type FibSetup
    line l05
    box targetBx
    label lbl05
    bool isUpper
    bool touched
    bool activated

var array<FibSetup> fibSetups = array.new<FibSetup>()
var int lastActiveFibIndex = na

f_trimBroken() =>
    if showLastN > 0
        while array.size(brkLines) > showLastN
            line.delete(array.shift(brkLines))
            label.delete(array.shift(brkLabs))

    while array.size(fibSetups) > fibMaxKeep
        fs = array.shift(fibSetups)
        line.delete(fs.l05)
        box.delete(fs.targetBx)
        label.delete(fs.lbl05)

f_pushBrokenMS(line ln, label lb) =>
    array.push(brkLines, ln)
    array.push(brkLabs,  lb)
    f_trimBroken()

//==================== MS LOGIC ====================
if inCalc
    if phHit
        if not na(upLine) and not upBroken
            line.delete(upLine)
            label.delete(upCandLb)
        upLvl := phVal
        upT   := time[p]
        upBroken := false
        upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

    if plHit
        if not na(dnLine) and not dnBroken
            line.delete(dnLine)
            label.delete(dnCandLb)
        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false
        dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, extend=extend.none, color=candCol, style=candStyle, width=candW)

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

if inCalc
    if brkUp
        upBroken := true
        isChoch = (os == -1)

        if not na(upLine)
            line.set_color(upLine, brkUpCol)
            line.set_style(upLine, brkStyle)
            line.set_width(upLine, brkW)
            line.set_x2(upLine, time)
        
        label lb = na
        if lbOn
            txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=lbTxtUp, color=lbBg, size=lbSize)

        f_pushBrokenMS(upLine, lb)
        upLine := na
        os := 1
        
        // DRAW BULLISH CHOCH FIB
        if isChoch and showFib
            float legLow = na
            int legLowT = na
            
            if fibMode == "Aggressive" and not na(lowestSincePh)
                legLow := lowestSincePh
                legLowT := lowestSincePhT
            else if fibMode == "Cool" and not na(lastConfirmedPl)
                legLow := lastConfirmedPl
                legLowT := lastConfirmedPlT
                
            if not na(legLow)
                legHigh = high
                dist = legHigh - legLow
                
                // Draw only 0.5 line
                l05 = line.new(legLowT, legLow + dist*0.5, time + extMs * 3, legLow + dist*0.5, xloc=xloc.bar_time, color=fibLineCol, style=line.style_dashed)
                lbl05 = label.new(time + extMs * 3, legLow + dist*0.5, "0.5", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white,100), textcolor=fibLineCol, size=size.tiny)
                
                // Draw Target Box (1.47 to 1.55) -> Upper Target Box
                tLow = legLow + dist * 1.47
                tHigh = legLow + dist * 1.55
                bx = box.new(time, tHigh, time + extMs * 3, tLow, xloc=xloc.bar_time, border_color=color.new(color.white,100), bgcolor=fibBullCol, text="1.47 - 1.55 Touch - Turn", text_size=size.tiny, text_color=color.new(#089981, 0))
                
                array.push(fibSetups, FibSetup.new(l05, bx, lbl05, true, false, false))
                f_trimBroken()

    if brkDn
        dnBroken := true
        isChoch = (os == 1)

        if not na(dnLine)
            line.set_color(dnLine, brkDnCol)
            line.set_style(dnLine, brkStyle)
            line.set_width(dnLine, brkW)
            line.set_x2(dnLine, time)

        label lb = na
        if lbOn
            txt = isChoch ? "CHoCH" : "BOS"
            lb := label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=lbTxtDn, color=lbBg, size=lbSize)

        f_pushBrokenMS(dnLine, lb)
        dnLine := na
        os := -1
        
        // DRAW BEARISH CHOCH FIB
        if isChoch and showFib
            float legHigh = na
            int legHighT = na
            
            if fibMode == "Aggressive" and not na(highestSincePl)
                legHigh := highestSincePl
                legHighT := highestSincePlT
            else if fibMode == "Cool" and not na(lastConfirmedPh)
                legHigh := lastConfirmedPh
                legHighT := lastConfirmedPhT
                
            if not na(legHigh)
                legLow = low
                dist = legHigh - legLow
                
                // Draw only 0.5 line
                l05 = line.new(legHighT, legLow + dist*0.5, time + extMs * 3, legLow + dist*0.5, xloc=xloc.bar_time, color=fibLineCol, style=line.style_dashed)
                lbl05 = label.new(time + extMs * 3, legLow + dist*0.5, "0.5", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white,100), textcolor=fibLineCol, size=size.tiny)
                
                // Draw Target Box (0.2 to 0.23) -> Lower Target Box
                tHigh = legLow + dist * 0.23
                tLow = legLow + dist * 0.2
                bx = box.new(time, tHigh, time + extMs * 3, tLow, xloc=xloc.bar_time, border_color=color.new(color.white,100), bgcolor=fibBearCol, text="0.2 - 0.23 Touch - Turn", text_size=size.tiny, text_color=color.new(#f23645, 0))
                
                array.push(fibSetups, FibSetup.new(l05, bx, lbl05, false, false, false))
                f_trimBroken()

// Extend Fib zones live and Check Box logic
bool alertLowerBoxActive = false
bool alertUpperBoxActive = false

if inCalc
    for i = 0 to (array.size(fibSetups) == 0 ? na : array.size(fibSetups) - 1)
        if i < array.size(fibSetups)
            fs = array.get(fibSetups, i)
            if barstate.islast
                line.set_x2(fs.l05, time + extMs * 3)
                box.set_right(fs.targetBx, time + extMs * 3)
                label.set_x(fs.lbl05, time + extMs * 3)
            
                // Fade out if 3 or more 0.5 levels are clustered closely
                price = line.get_y1(fs.l05)
                countClose = 0
                for j = 0 to (array.size(fibSetups) == 0 ? na : array.size(fibSetups) - 1)
                    if j < array.size(fibSetups)
                        other_price = line.get_y1(array.get(fibSetups, j).l05)
                        diffPct = math.abs(price - other_price) / price * 100
                        if diffPct <= fibMergeDist
                            countClose += 1
                
                if countClose >= 3
                    line.set_color(fs.l05, color.new(color.orange, 50))
                    label.set_textcolor(fs.lbl05, color.new(color.orange, 50))
                else
                    line.set_color(fs.l05, color.new(color.orange, 70))
                    label.set_textcolor(fs.lbl05, color.new(color.orange, 70))
            
            // Box Touch & Turn Logic
            bxTop = box.get_top(fs.targetBx)
            bxBot = box.get_bottom(fs.targetBx)
            
            if not fs.touched
                if high >= bxBot and low <= bxTop
                    fs.touched := true
            
            if fs.touched and not fs.activated
                if fs.isUpper // Upper Box, wait for turn (close below box)
                    if close < bxBot
                        fs.activated := true
                        alertUpperBoxActive := true
                        lastActiveFibIndex := i
                else // Lower Box, wait for turn (close above box)
                    if close > bxTop
                        fs.activated := true
                        alertLowerBoxActive := true
                        lastActiveFibIndex := i
                        
            if fs.activated
                if lastActiveFibIndex == i
                    box.set_bgcolor(fs.targetBx, color.new(fs.isUpper ? fibBullCol : fibBearCol, 50))
                else
                    box.set_bgcolor(fs.targetBx, color.new(fs.isUpper ? fibBullCol : fibBearCol, 70))


//==================== ERL & IRL STORAGE ====================
var line[]  brkErlBullLines = array.new_line()
var label[] brkErlBullLabs  = array.new_label()
var line[]  brkErlBearLines = array.new_line()
var label[] brkErlBearLabs  = array.new_label()

var box[] brkIrlBullBoxes = array.new_box()
var box[] brkIrlBearBoxes = array.new_box()

f_trimLiq() =>
    if showLastN > 0
        while array.size(brkErlBullLines) > showLastN
            line.delete(array.shift(brkErlBullLines))
            label.delete(array.shift(brkErlBullLabs))
        while array.size(brkErlBearLines) > showLastN
            line.delete(array.shift(brkErlBearLines))
            label.delete(array.shift(brkErlBearLabs))
            
        while array.size(brkIrlBullBoxes) > showLastN
            box.delete(array.shift(brkIrlBullBoxes))
        while array.size(brkIrlBearBoxes) > showLastN
            box.delete(array.shift(brkIrlBearBoxes))

//==================== IRL / ERL LOGIC ====================
type ErlActive
    line ln
    label lbl
    float price
    bool isBull

type IrlActive
    box bx
    float top
    float bottom
    bool isBull

var array<ErlActive> activeErl = array.new<ErlActive>()
var array<IrlActive> activeIrl = array.new<IrlActive>()

bool alertBullishIrl = false
bool alertBearishIrl = false

if inCalc
    erlPh = ta.pivothigh(high, pivotLeft, pivotRight)
    erlPl = ta.pivotlow(low, pivotLeft, pivotRight)

    if not na(erlPh)
        l = line.new(bar_index[pivotRight], erlPh, bar_index, erlPh, color = erlBear, style = line.style_solid)
        lbl = label.new(bar_index[pivotRight], erlPh, "ERL", color = color.new(color.white, 100), textcolor = erlBear, style = label.style_label_down, size = size.tiny)
        array.push(activeErl, ErlActive.new(l, lbl, erlPh, false))
        
    if not na(erlPl)
        l = line.new(bar_index[pivotRight], erlPl, bar_index, erlPl, color = erlBull, style = line.style_solid)
        lbl = label.new(bar_index[pivotRight], erlPl, "ERL", color = color.new(color.white, 100), textcolor = erlBull, style = label.style_label_up, size = size.tiny)
        array.push(activeErl, ErlActive.new(l, lbl, erlPl, true))

    // Manage Active ERL Limits
    int bullErlCount = 0
    int bearErlCount = 0
    for i = array.size(activeErl) - 1 to 0
        if array.size(activeErl) > 0
            zone = array.get(activeErl, i)
            if zone.isBull
                bullErlCount += 1
                if bullErlCount > erlMaxKeep
                    line.delete(zone.ln)
                    label.delete(zone.lbl)
                    array.remove(activeErl, i)
            else
                bearErlCount += 1
                if bearErlCount > erlMaxKeep
                    line.delete(zone.ln)
                    label.delete(zone.lbl)
                    array.remove(activeErl, i)

    for i = array.size(activeErl) - 1 to 0
        if array.size(activeErl) > 0
            zone = array.get(activeErl, i)
            line.set_x2(zone.ln, bar_index)
            
            crossed = false
            if zone.isBull
                if low <= zone.price
                    crossed := true
            else
                if high >= zone.price
                    crossed := true
                    
            if crossed
                line.set_style(zone.ln, line.style_dotted)
                label.set_textcolor(zone.lbl, color.new(zone.isBull ? erlBull : erlBear, 50))
                
                if zone.isBull
                    array.push(brkErlBullLines, zone.ln)
                    array.push(brkErlBullLabs, zone.lbl)
                else
                    array.push(brkErlBearLines, zone.ln)
                    array.push(brkErlBearLabs, zone.lbl)
                    
                array.remove(activeErl, i)
                f_trimLiq()

    isBullFvg = low > high[2]
    isBearFvg = high < low[2]

    if isBullFvg
        if showIrl
            bx = box.new(bar_index[2], low, bar_index, high[2], border_color = color.new(color.white, 100), bgcolor = irlBull, text = "IRL", text_size = size.tiny, text_color = color.new(#089981, 0), text_valign = text.align_bottom)
            array.push(activeIrl, IrlActive.new(bx, low, high[2], true))
        alertBullishIrl := true

    if isBearFvg
        if showIrl
            bx = box.new(bar_index[2], high, bar_index, low[2], border_color = color.new(color.white, 100), bgcolor = irlBear, text = "IRL", text_size = size.tiny, text_color = color.new(#f23645, 0), text_valign = text.align_top)
            array.push(activeIrl, IrlActive.new(bx, high, low[2], false))
        alertBearishIrl := true

    // Manage Active IRL Limits
    int bullIrlCount = 0
    int bearIrlCount = 0
    for i = array.size(activeIrl) - 1 to 0
        if array.size(activeIrl) > 0
            zone = array.get(activeIrl, i)
            if zone.isBull
                bullIrlCount += 1
                if bullIrlCount > showLastN
                    box.delete(zone.bx)
                    array.remove(activeIrl, i)
            else
                bearIrlCount += 1
                if bearIrlCount > showLastN
                    box.delete(zone.bx)
                    array.remove(activeIrl, i)

    for i = array.size(activeIrl) - 1 to 0
        if array.size(activeIrl) > 0
            zone = array.get(activeIrl, i)
            box.set_right(zone.bx, bar_index)
            
            mitigated = false
            if zone.isBull
                if low <= zone.bottom
                    mitigated := true
            else
                if high >= zone.top
                    mitigated := true
                    
            if mitigated
                box.set_border_style(zone.bx, line.style_dotted)
                box.set_border_color(zone.bx, color.new(zone.isBull ? erlBull : erlBear, 50))
                
                if zone.isBull
                    array.push(brkIrlBullBoxes, zone.bx)
                else
                    array.push(brkIrlBearBoxes, zone.bx)
                    
                array.remove(activeIrl, i)
                f_trimLiq()

//==================== ALERTS ====================
if alertLowerBoxActive
    alert("Lower Box Active (Touch & Turn)", alert.freq_once_per_bar_close)

if alertUpperBoxActive
    alert("Upper Box Active (Touch & Turn)", alert.freq_once_per_bar_close)

if alertLowerBoxActive and alertBullishIrl
    alert("Lower Box Active with Bullish IRL Created", alert.freq_once_per_bar_close)

if alertUpperBoxActive and alertBearishIrl
    alert("Upper Box Active with Bearish IRL Created", alert.freq_once_per_bar_close)
````
