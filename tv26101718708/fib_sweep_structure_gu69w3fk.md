# Fib Sweep Structure

- url: https://www.tradingview.com/script/gu69w3Fk-Fib-Sweep-Structure/
- type: indicator
- pine_id: PUB;8fb0de8ccd444439998ab4586f585eae
- version: 1.0

## Description

[b]Fib Sweep Structure[/b]

This indicator combines three concepts into a single workflow: liquidity sweeps, break of structure (BOS), and Fibonacci retracement zones with internal structure tracking.

[b]What it does[/b]

When price breaks a major swing high or low, the indicator draws a Fib retracement between the breakout level and the most recent opposing swing. The 0.25, 0.50, and 0.75 levels are plotted as a discount/premium zone for entries on the pullback. Inside that zone, smaller pivot breaks are flagged as internal structure shifts so you can time entries against confirmed minor momentum.

Liquidity sweeps are tracked independently. Pivot highs and lows are monitored for wicks (failed breakouts) and outbreak-and-retest patterns. Each sweep prints a colored box marking the sweep area, which extends until price closes through it.

[b]How to use it[/b]

Wait for a BOS in the direction you want to trade. Once the Fib zone prints, look for price to retrace into the 0.5 to 0.75 region. Use the internal structure shifts as confirmation that momentum is turning in the direction of the original BOS. Liquidity sweeps inside or near the zone add confluence.

[b]Settings[/b]

- Sweeps Length: lookback for the swing points used in liquidity sweep detection
- Options: choose between wick sweeps only, outbreak and retest only, or both
- Sweep Area: toggle extension of sweep boxes and set max bar length
- BOS Structure Length: lookback for major structure pivots. Larger values isolate higher timeframe structure
- Internal Structure Length: lookback for the minor shifts plotted inside the active Fib zone. Keep this smaller than the BOS length

[b]Notes[/b]

Only the most recent BOS and its Fib zone are active at any time. A new BOS clears the previous Fib levels and internal shift lines. Internal shift lines are static and stop at the bar where the break occurred, so they read as historical signals rather than ongoing levels.

[b]Credits[/b]

Built on top of the open-source Liquidity Sweeps logic by LuxAlgo, released under the Mozilla Public License 2.0. The BOS detection, Fibonacci zone generation, and internal structure tracking are additions to that base.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator( 'Fib Sweep Structure'
         , 'Fib Sweep Structure'
         ,  max_lines_count=500
         ,  max_boxes_count=500
         ,  overlay=true
         )

//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
lenSweeps = input.int(5, 'Sweeps Length', minval=1, group='Liquidity Sweeps', tooltip="Lookback for swing points used in Liquidity Sweeps")
opt       = input.string('Only Wicks', 'options'
          , options=['Only Wicks', 'Only Outbreaks & Retest', 'Wicks + Outbreaks & Retest'], group='Liquidity Sweeps')

colBl  = input.color(#089981, 'Bull ', group='Liquidity Sweeps', inline='c1')
colBr  = input.color(#f23645, 'Bear' , group='Liquidity Sweeps', inline='c2')
colBl2 = input.color(#08998180,  ''  , group='Liquidity Sweeps', inline='c1')
colBr2 = input.color(#f2364580,  ''  , group='Liquidity Sweeps', inline='c2')

extend = input.bool(true, 'Extend', group='Sweep Area') 
maxB   = input.int(300, 'Max bars', minval=1, maxval=5000, group='Sweep Area')
colBl3 = input.color(#08998141, 'Bull ', group='Sweep Area')
colBr3 = input.color(#f2364541, 'Bear' , group='Sweep Area')

// BOS & Fib Settings
showBos = input.bool(true, 'Show BOS & Fib Levels', group='BOS & Fib Levels')
lenBos  = input.int(10, 'BOS Structure Length', minval=1, group='BOS & Fib Levels', tooltip="Adjust this to match major swings. Larger values = Major structure.")
colFib  = input.color(#f2364580, 'Fib Levels Color', group='BOS & Fib Levels')

// Internal Structure Settings
showInternal = input.bool(true, 'Show Internal Shifts', group='Internal Structure')
lenInternal  = input.int(3, 'Internal Structure Length', minval=1, group='Internal Structure', tooltip="Lookback for minor shifts inside the Fib zone.")

oW = opt == 'Only Wicks'
oO = opt == 'Only Outbreaks & Retest'
WO = opt == 'Wicks + Outbreaks & Retest'

n = bar_index 

//-----------------------------------------------------------------------------}      
//UDT's
//-----------------------------------------------------------------------------{
type pivotUDT
    float prc // price
    int   bix // bar_index
    bool  brk // broken
    bool  mit // mitigated
    bool  tak // taken
    bool  wic // wick
    line  lin 

type bosPoint
    float prc
    int   bix
    int   tix // time
    bool  broken
    float originPrc
    int   originTix

type boxUDT
    box  bx 
    line ln
    bool br
    int  dr

//-----------------------------------------------------------------------------}      
//Variables
//-----------------------------------------------------------------------------{
var array<pivotUDT> aPivH  = array.new<pivotUDT>()
var array<pivotUDT> aPivL  = array.new<pivotUDT>()
var array<boxUDT>   aBoxBr = array.new<boxUDT>()

// BOS tracking
var array<bosPoint> bosPivotsH = array.new<bosPoint>()
var array<bosPoint> bosPivotsL = array.new<bosPoint>()

var float lastMajorPH_prc = na
var int   lastMajorPH_tix = na
var float lastMajorPL_prc = na
var int   lastMajorPL_tix = na

// Internal Structure tracking
var array<pivotUDT> internalPivotsH = array.new<pivotUDT>()
var array<pivotUDT> internalPivotsL = array.new<pivotUDT>()

// Active Fib management
var array<line> activeFibLines = array.new<line>()
var array<label> activeFibLabels = array.new<label>()
var array<line> activeInternalLines = array.new<line>()

var float activeFibHigh = na
var float activeFibLow  = na
var int   activeFibStartBix = na

//-----------------------------------------------------------------------------}      
//Methods - functions
//-----------------------------------------------------------------------------{
method isNotNa(float p) => not na(p)

method l(pivotUDT get, color c, string s='sd') => 
    style = switch s 
        'dt' => line.style_dotted
        'ds' => line.style_dashed
        =>      line.style_solid 
    line.new(get.bix, get.prc, n, get.prc, color=c, style = style)

method br(pivotUDT get, color c3, color c, int d) =>
    y1 = d == 1 ? high : get.prc
    y2 = d == 1 ? get.prc : low
    boxUDT.new( 
     box.new(n -1, y1, n +1, y2, border_color=color.new(color.black, 100), bgcolor=c3),
     line.new(n , y1, n, y2, color=c, width=3),
     false,
     d)

lnDot(y, c) => line.new(n, y, n+3, y, color=c, style=line.style_dotted)

//-----------------------------------------------------------------------------}      
//Execution
//-----------------------------------------------------------------------------{
// 1. Pivot Detection
phS = ta.pivothigh(lenSweeps, lenSweeps)
plS = ta.pivotlow (lenSweeps, lenSweeps)

phB = ta.pivothigh(lenBos, lenBos)
plB = ta.pivotlow (lenBos, lenBos)

phI = ta.pivothigh(lenInternal, lenInternal)
plI = ta.pivotlow (lenInternal, lenInternal)

// 2. Update Major Highs/Lows
if not na(phB)
    lastMajorPH_prc := phB
    lastMajorPH_tix := time[lenBos]
    bosPivotsH.unshift(bosPoint.new(phB, n - lenBos, time[lenBos], false, lastMajorPL_prc, lastMajorPL_tix))

if not na(plB)
    lastMajorPL_prc := plB
    lastMajorPL_tix := time[lenBos]
    bosPivotsL.unshift(bosPoint.new(plB, n - lenBos, time[lenBos], false, lastMajorPH_prc, lastMajorPH_tix))

// 3. Update Internal Pivots
if not na(phI)
    internalPivotsH.unshift(pivotUDT.new(phI, n - lenInternal, false, false, false, false, na))
if not na(plI)
    internalPivotsL.unshift(pivotUDT.new(plI, n - lenInternal, false, false, false, false, na))

// 4. Update Sweeps Pivots
if not na(phS) 
    aPivH.unshift(pivotUDT.new(phS, n - lenSweeps, false, false, false, false, na))
if not na(plS) 
    aPivL.unshift(pivotUDT.new(plS, n - lenSweeps, false, false, false, false, na))

// 5. BOS Detection (Major Structure)
if showBos
    newBosFound = false
    float breakoutPrc = na
    float swingPrc    = na
    int   breakoutTix = na
    int   swingTix    = na
    color currentBosColor = na

    if bosPivotsH.size() > 0
        for i = bosPivotsH.size() - 1 to 0
            p = bosPivotsH.get(i)
            if not p.broken and close > p.prc
                if lastMajorPL_prc.isNotNa()
                    newBosFound := true
                    breakoutPrc := p.prc
                    swingPrc    := lastMajorPL_prc
                    breakoutTix := p.tix
                    swingTix    := lastMajorPL_tix
                    currentBosColor := colBl
                p.broken := true
    
    if bosPivotsL.size() > 0
        for i = bosPivotsL.size() - 1 to 0
            p = bosPivotsL.get(i)
            if not p.broken and close < p.prc
                if lastMajorPH_prc.isNotNa()
                    newBosFound := true
                    breakoutPrc := p.prc
                    swingPrc    := lastMajorPH_prc
                    breakoutTix := p.tix
                    swingTix    := lastMajorPH_tix
                    currentBosColor := colBr
                p.broken := true

    if newBosFound
        activeFibHigh := math.max(breakoutPrc, swingPrc)
        activeFibLow  := math.min(breakoutPrc, swingPrc)
        activeFibStartBix := n

        if activeFibLines.size() > 0
            for li in activeFibLines
                li.delete()
            activeFibLines.clear()
        if activeFibLabels.size() > 0
            for lb in activeFibLabels
                lb.delete()
            activeFibLabels.clear()
        if activeInternalLines.size() > 0
            for li in activeInternalLines
                li.delete()
            activeInternalLines.clear()
            
        tExt = time + (time - time[1]) * 5
        diff = breakoutPrc - swingPrc
        l25 = breakoutPrc - diff * 0.25
        l50 = breakoutPrc - diff * 0.50
        l75 = breakoutPrc - diff * 0.75

        line breakoutLi = line.new(breakoutTix, breakoutPrc, tExt, breakoutPrc, xloc=xloc.bar_time, color=currentBosColor, width=1)
        label breakoutLb = label.new(tExt, breakoutPrc, "BOS (" + str.tostring(breakoutPrc, "#.##") + ")", xloc=xloc.bar_time, color=#00000000, textcolor=currentBosColor, style=label.style_label_left, size=size.small)
        activeFibLines.push(breakoutLi)
        activeFibLabels.push(breakoutLb)

        line swingLi = line.new(swingTix, swingPrc, tExt, swingPrc, xloc=xloc.bar_time, color=colFib, width=1)
        label swingLb = label.new(tExt, swingPrc, "Recent Swing (" + str.tostring(swingPrc, "#.##") + ")", xloc=xloc.bar_time, color=#00000000, textcolor=colFib, style=label.style_label_left, size=size.small)
        activeFibLines.push(swingLi)
        activeFibLabels.push(swingLb)

        activeFibLines.push(line.new(swingTix, l25, tExt, l25, xloc=xloc.bar_time, color=colFib))
        activeFibLabels.push(label.new(tExt, l25, "0.25 (" + str.tostring(l25, "#.##") + ")", xloc=xloc.bar_time, color=#00000000, textcolor=colFib, style=label.style_label_left, size=size.small))

        activeFibLines.push(line.new(swingTix, l50, tExt, l50, xloc=xloc.bar_time, color=colFib))
        activeFibLabels.push(label.new(tExt, l50, "0.50 (" + str.tostring(l50, "#.##") + ")", xloc=xloc.bar_time, color=#00000000, textcolor=colFib, style=label.style_label_left, size=size.small))

        activeFibLines.push(line.new(swingTix, l75, tExt, l75, xloc=xloc.bar_time, color=colFib))
        activeFibLabels.push(label.new(tExt, l75, "0.75 (" + str.tostring(l75, "#.##") + ")", xloc=xloc.bar_time, color=#00000000, textcolor=colFib, style=label.style_label_left, size=size.small))
        
        activeFibLines.push(line.new(swingTix, breakoutPrc, swingTix, swingPrc, xloc=xloc.bar_time, color=colFib, style=line.style_dotted))

// 6. Internal Structure Detection
if showInternal and not na(activeFibStartBix)
    // High Shifts
    if internalPivotsH.size() > 0
        for i = internalPivotsH.size() - 1 to 0
            pivotUDT curH = internalPivotsH.get(i)
            if not curH.brk
                if curH.bix >= activeFibStartBix and close > curH.prc
                    if curH.prc < activeFibHigh and curH.prc > activeFibLow
                        // Static line: stops at the bar of the break (n)
                        activeInternalLines.push(line.new(curH.bix, curH.prc, n, curH.prc, color=colBl, style=line.style_dotted))
                    curH.brk := true
            if n - curH.bix > 500
                internalPivotsH.remove(i)
    
    // Low Shifts
    if internalPivotsL.size() > 0
        for i = internalPivotsL.size() - 1 to 0
            pivotUDT curL = internalPivotsL.get(i)
            if not curL.brk
                if curL.bix >= activeFibStartBix and close < curL.prc
                    if curL.prc < activeFibHigh and curL.prc > activeFibLow
                        // Static line: stops at the bar of the break (n)
                        activeInternalLines.push(line.new(curL.bix, curL.prc, n, curL.prc, color=colBr, style=line.style_dotted))
                    curL.brk := true
            if n - curL.bix > 500
                internalPivotsL.remove(i)

// 7. Liquidity Sweeps Logic
if aPivH.size() > 0
    for i = aPivH.size() - 1 to 0
        getH = aPivH.get(i)
        if not getH.mit
            if not getH.brk
                if close > getH.prc 
                    getH.brk := true
                if not oO and not getH.wic 
                    if high > getH.prc and close < getH.prc                   
                        aBoxBr.unshift(getH.br(colBr3, colBr, 1))       
                        getH.lin := getH.l(colBr2, 'dt')
                        lnDot(low, colBr)
                        getH.wic := true  
            else 
                if close < getH.prc 
                    getH.mit := true
                if not oW and low < getH.prc and close > getH.prc                    
                    aBoxBr.unshift(getH.br(colBl3, colBl, -1))    
                    getH.lin := getH.l(colBl2, 'ds')
                    lnDot(high, colBl)
                    getH.tak := true 
        if n - getH.bix > 2000 or getH.mit or getH.tak 
            removedH = aPivH.remove(i)
            if not na(removedH.lin)
                removedH.lin.delete()

if aPivL.size() > 0
    for i = aPivL.size() - 1 to 0
        getL = aPivL.get(i)
        if not getL.mit
            if not getL.brk
                if close < getL.prc 
                    getL.brk := true
                if not oO and not getL.wic 
                    if low < getL.prc and close > getL.prc                              
                        aBoxBr.unshift(getL.br(colBl3, colBl, -1))     
                        getL.lin := getL.l(colBl2, 'dt')
                        lnDot(high, colBl)
                        getL.wic := true 
            else 
                if close > getL.prc 
                    getL.mit := true
                if not oW and high > getL.prc and close < getL.prc                     
                    aBoxBr.unshift(getL.br(colBr3, colBr, 1))    
                    getL.lin := getL.l(colBr2, 'ds')
                    lnDot(low, colBr)
                    getL.tak := true  
        if n - getL.bix > 2000 or getL.mit or getL.tak 
            removedL = aPivL.remove(i)
            if not na(removedL.lin)
                removedL.lin.delete()

// 8. Box Extension
if extend
    for bx in aBoxBr 
        if not bx.br and n - bx.bx.get_left() - 1 <= maxB 
            bx.bx.set_right(bar_index)
            if bx.dr == -1 and close < bx.bx.get_bottom() 
                bx.br := true 
            if bx.dr ==  1 and close > bx.bx.get_top   () 
                bx.br := true 

// 9. Update active objects
if activeFibLines.size() > 0
    tExtFinal = time + (time - time[1]) * 5
    for li in activeFibLines
        if li.get_x1() != li.get_x2()
            li.set_x2(tExtFinal)
if activeFibLabels.size() > 0
    tExtFinal = time + (time - time[1]) * 5
    for lb in activeFibLabels
        lb.set_x(tExtFinal)

//-----------------------------------------------------------------------------}
````
