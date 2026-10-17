# Order 66

- url: https://www.tradingview.com/script/k4w5oyyd-Order-66/
- type: indicator
- pine_id: PUB;768810e711e54f1db0762faf863ef771
- version: 1.0

## Description

Inverse FVGs with a liquidity sweep. This was a personal code that I grabbed from LUXALGO using the quant software. This indicator will find Inverse FVGs after a liquidity sweep.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Liquidity Sweeps & Inverse FVG [LuxAlgo]", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Groups ---
groupLS = "Liquidity Sweeps"
groupFVG = "Inverse Fair Value Gaps"

// --- Inputs: Liquidity Sweeps ---
len    = input.int(5, "Swing Length", minval = 1, group = groupLS, tooltip = "Lookback for pivot highs and lows.")
opt    = input.string("Only Wicks", "LS Options", options = ["Only Wicks", "Only Outbreaks & Retest", "Wicks + Outbreaks & Retest"], group = groupLS)
colBl  = input.color(color.new(#089981, 0), "Bullish Sweep", group = groupLS, inline = "c1")
colBr  = input.color(color.new(#f23645, 0), "Bearish Sweep", group = groupLS, inline = "c2")
colBl2 = input.color(color.new(#089981, 50), "", group = groupLS, inline = "c1")
colBr2 = input.color(color.new(#f23645, 50), "", group = groupLS, inline = "c2")

// --- Inputs: iFVG ---
showIFVG = input.bool(true, "Show Inverse FVGs", group = groupFVG)
volMult  = input.float(0.5, "Volatility Filter (ATR Multiplier)", minval = 0, step = 0.1, group = groupFVG, tooltip = "Filters FVGs based on their size relative to ATR. 0 to disable.")
atrLen   = input.int(14, "ATR Length", minval = 1, group = groupFVG)
ifvgBullColor = input.color(color.new(#089981, 80), "Bullish iFVG", group = groupFVG)
ifvgBearColor = input.color(color.new(#f23645, 80), "Bearish iFVG", group = groupFVG)

// --- Constants & Variables ---
var float atr = na
atr := ta.atr(atrLen)

// --- UDTs ---
type piv
    float prc
    int   bix
    bool  brk
    bool  mit
    bool  tak
    bool  wic
    line  lin

type boxBr 
    box  bx 
    line ln
    bool br
    int  dr

type fvg
    float top
    float btm
    int   start
    bool  isBull
    bool  active = true
    box   bx

// --- Arrays ---
var array<piv> aPivH   = array.new<piv>()
var array<piv> aPivL   = array.new<piv>()
var array<boxBr> aBoxBr = array.new<boxBr>()
var array<fvg> aFVGs   = array.new<fvg>()

// --- Functions/Methods ---
method n(float p) => not na(p)

method l(piv get, color c, string s = "sd") => 
    style = switch s 
        "dt" => line.style_dotted
        "ds" => line.style_dashed
        =>      line.style_solid 
    line.new(get.bix, get.prc, bar_index, get.prc, color = c, style = style)

method br(piv get, color c3, color c, int d) =>
    y1 = d == 1 ? high : get.prc
    y2 = d == 1 ? get.prc : low
    boxBr.new(box.new(bar_index - 1, y1, bar_index + 1, y2, border_color = color.new(na, 0), bgcolor = c3), 
              line.new(bar_index, y1, bar_index, y2, color = c, width = 3), false, d)

lnDot(y, c) => line.new(bar_index, y, bar_index + 3, y, color = c, style = line.style_dotted)

// --- Core Logic: Liquidity Sweeps ---
ph = ta.pivothigh(len, len)
pl = ta.pivotlow (len, len)

if ph.n() 
    aPivH.unshift(piv.new(ph, bar_index - len, false, false, false, false))

if pl.n() 
    aPivL.unshift(piv.new(pl, bar_index - len, false, false, false, false)) 

oW = opt == "Only Wicks"
oO = opt == "Only Outbreaks & Retest"

// Iterate backward using 'by -1' and check size
if aPivH.size() > 0
    for i = aPivH.size() - 1 to 0 by -1
        get = aPivH.get(i)
        if not get.mit
            if not get.brk
                if close > get.prc 
                    if not oW
                        get.brk := true
                    else 
                        get.mit := true
                if not oO and not get.wic 
                    if high > get.prc and close < get.prc                   
                        aBoxBr.unshift(get.br(color.new(colBr, 80), colBr, 1))       
                        get.l(colBr2, "dt"), lnDot(low, colBr)
                        get.wic := true  
            else 
                if close < get.prc 
                    get.mit := true
                if not oW and low < get.prc and close > get.prc                    
                    aBoxBr.unshift(get.br(color.new(colBl, 80), colBl, -1))    
                    get.l(colBl2, "ds"), lnDot(high, colBl)
                    get.tak := true 

        if bar_index - get.bix > 2000 or get.mit or get.tak 
            p = aPivH.remove(i)
            if not na(p.lin)
                p.lin.delete()

if aPivL.size() > 0
    for i = aPivL.size() - 1 to 0 by -1
        get = aPivL.get(i)
        if not get.mit
            if not get.brk
                if close < get.prc 
                    if not oW
                        get.brk := true
                    else 
                        get.mit := true
                if not oO and not get.wic 
                    if low < get.prc and close > get.prc                              
                        aBoxBr.unshift(get.br(color.new(colBl, 80), colBl, -1))     
                        get.l(colBl2, "dt"), lnDot(high, colBl)
                        get.wic := true 
            else 
                if close > get.prc 
                    get.mit := true
                if not oW and high > get.prc and close < get.prc                     
                    aBoxBr.unshift(get.br(color.new(colBr, 80), colBr, 1))    
                    get.l(colBr2, "ds"), lnDot(low, colBr)
                    get.tak := true  

        if bar_index - get.bix > 2000 or get.mit or get.tak 
            p = aPivL.remove(i)
            if not na(p.lin)
                p.lin.delete()

for bx in aBoxBr 
    if not bx.br and bar_index - bx.bx.get_left() - 1 <= 300
        bx.bx.set_right(bar_index)
        if bx.dr == -1 and close < bx.bx.get_bottom() 
            bx.br := true 
        if bx.dr == 1 and close > bx.bx.get_top() 
            bx.br := true 

// --- Core Logic: Inverse FVG ---
if showIFVG
    // Identify new FVGs
    bullFVG = low > high[2]
    bearFVG = high < low[2]
    
    threshold = (volMult > 0 ? atr * volMult : 0)

    if bullFVG and (low - high[2]) > threshold
        aFVGs.push(fvg.new(low, high[2], bar_index - 1, true))
        
    if bearFVG and (low[2] - high) > threshold
        aFVGs.push(fvg.new(low[2], high, bar_index - 1, false))

    // Manage iFVG transitions
    if aFVGs.size() > 0
        for i = aFVGs.size() - 1 to 0 by -1
            element = aFVGs.get(i)
            
            if element.active
                // Check for inversion
                if element.isBull
                    if close < element.btm // Closed below bullish FVG
                        element.active := false
                        element.bx := box.new(element.start, element.top, bar_index, element.btm, 
                                              bgcolor = ifvgBearColor, border_color = color.new(na, 0))
                else
                    if close > element.top // Closed above bearish FVG
                        element.active := false
                        element.bx := box.new(element.start, element.top, bar_index, element.btm, 
                                              bgcolor = ifvgBullColor, border_color = color.new(na, 0))
                                              
            // Update box length for inverted gaps
            if not element.active and not na(element.bx)
                element.bx.set_right(bar_index)
                
                // Mitigate iFVG (Simple mitigation: price touches the other side)
                if element.isBull // Inverted to Bearish
                    if close > element.top
                        element.bx := na // Stop drawing
                else // Inverted to Bullish
                    if close < element.btm
                        element.bx := na

            // Cleanup
            if bar_index - element.start > 500
                aFVGs.remove(i)
````
