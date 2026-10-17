# Liquidity Sweeps with alert

- url: https://www.tradingview.com/script/olNw5SGd-Liquidity-Sweeps-with-alert/
- type: indicator
- pine_id: PUB;88aaeb7462ef4c13a3c0744bcdfe12aa
- version: 1.0

## Description

This script is designed to detect **liquidity sweeps** — one of the core behaviors of smart money and institutional trading.

It identifies areas where price:

* takes previous highs/lows,
* traps breakout traders,
* grabs stop-loss liquidity,
* and then reverses.

---

# Core Market Psychology

Markets move toward liquidity.

Most retail traders place:

* buy stop orders above swing highs,
* sell stop orders below swing lows.

This script tracks those swing points and detects when price:

1. attacks liquidity,
2. absorbs orders,
3. rejects the level,
4. and reverses direction.

That behavior is called a **liquidity sweep**.

---

# Mathematical Structure

The script first detects pivot highs and lows using swing calculations.

Example:

\text{Pivot High} = \max(High_{n-len:n+len})

and

\text{Pivot Low} = \min(Low_{n-len:n+len})

These pivots become liquidity zones.

---

# Bullish Liquidity Sweep

A bullish sweep happens when:

* price breaks below a previous low,
* traders panic and short,
* stop losses get triggered,
* then price closes back above the level.

Psychology:

* weak hands get trapped,
* institutions absorb selling,
* market reclaims value.

This often becomes:

* reversal setup,
* accumulation signal,
* smart money entry.

---

# Bearish Liquidity Sweep

A bearish sweep happens when:

* price spikes above previous highs,
* breakout traders buy,
* short sellers get stopped out,
* then price closes back below resistance.

Psychology:

* breakout traders become trapped,
* liquidity is collected,
* institutions distribute positions.

This often leads to:

* sharp reversals,
* bearish continuation,
* liquidity-driven selloffs.

---

# Wicks vs Breakouts

The script separates:

* wick sweeps,
* real breakouts,
* and retest failures.

## Wick Sweep

Fast rejection from liquidity.

Meaning:

* aggressive stop hunt,
* emotional liquidity grab,
* instant absorption.

## Outbreak & Retest

True breakout followed by failed continuation.

Meaning:

* market initially accepts breakout,
* then loses strength,
* trapped traders fuel reversal.

---

# Sweep Zones

The colored boxes represent the actual sweep area.

These zones show:

* where liquidity was taken,
* where institutions reacted,
* and where future reactions may occur.

When extended:

* they become dynamic support/resistance,
* showing unmitigated liquidity imbalance.

---

# Alert Logic

The alerts trigger only when a fresh liquidity sweep appears.

This helps traders:

* avoid noise,
* focus on meaningful sweeps,
* and react immediately to potential reversals.

---

# Professional Trading Perspective

Experienced traders use liquidity sweeps to:

* avoid fake breakouts,
* identify manipulation,
* enter after stop hunts,
* and trade with institutional order flow.

The script essentially visualizes:

* trapped trader psychology,
* liquidity engineering,
* and smart money reversals.

---

# Simple Interpretation

* Sweep above highs → possible bearish reversal
* Sweep below lows → possible bullish reversal
* Strong rejection = higher probability setup
* Weak rejection = possible continuation

This indicator is not just detecting highs and lows.
It is tracking where the market is hunting liquidity before making its real move.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator( 'Liquidity Sweeps with alert'
         , 'Liquidity Sweeps with alert'
         ,  max_lines_count=500
         ,  max_boxes_count=500
         ,  overlay=true
         )

//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
len    = input.int(5, 'Swings', minval=1, group='Liquidity Sweeps')
opt    = input.string('Only Wicks', 'options'
       , options=['Only Wicks', 'Only Outbreaks & Retest', 'Wicks + Outbreaks & Retest'], group='Liquidity Sweeps')

colBl  = input.color(#089981, 'Bull ', group='Liquidity Sweeps', inline='c1')
colBr  = input.color(#f23645, 'Bear' , group='Liquidity Sweeps', inline='c2')
colBl2 = input.color(#08998180,  ''  , group='Liquidity Sweeps', inline='c1')
colBr2 = input.color(#f2364580,  ''  , group='Liquidity Sweeps', inline='c2')

extend = input.bool(true, 'Extend', group='Sweep Area') 
maxB   = input.int(300, 'Max bars', minval=1, maxval=5000, group='Sweep Area')
colBl3 = input.color(#08998141, 'Bull ', group='Sweep Area')
colBr3 = input.color(#f2364541, 'Bear' , group='Sweep Area')

oW = opt == 'Only Wicks'
oO = opt == 'Only Outbreaks & Retest'
WO = opt == 'Wicks + Outbreaks & Retest'

n = bar_index 

//-----------------------------------------------------------------------------}      
//UDT's
//-----------------------------------------------------------------------------{
type piv
    float prc // price
    int   bix // bar_index
    bool  brk // broken
    bool  mit // mitigated
    bool  tak // taken
    bool  wic // wick
    line  lin 

type boxBr 
    box  bx 
    line ln
    bool br
    int  dr

//-----------------------------------------------------------------------------}      
//Variables
//-----------------------------------------------------------------------------{
var array< piv >aPivH  = array.new< piv >(1, piv.new  ())
var array< piv >aPivL  = array.new< piv >(1, piv.new  ())
var array<boxBr>aBoxBr = array.new<boxBr>(1, boxBr.new())

//-----------------------------------------------------------------------------}      
//Methods - functions
//-----------------------------------------------------------------------------{
method n(float piv) => bool out = not na(piv)

method p(piv piv, float val) => float out = (100 / piv.prc * val) - 100

method l(piv get, color c, string s='sd') => 
    style = switch s 
        'dt' => line.style_dotted
        'ds' => line.style_dashed
        =>      line.style_solid 
    line.new(get.bix, get.prc, n, get.prc, color=c, style = style)

method br(piv get, color c3, color c, int d) =>
    y1 = d == 1 ? high : get.prc
    y2 = d == 1 ? get.prc : low
    boxBr.new( 
     box.new(n -1, y1, n +1, y2
     , border_color
     = color.new(
       na, na   )
     , bgcolor=c3)
     , line.new(n , y1, n, y2, color=c, width=3)
     , false
     , d)

lnDot(y, c) => line.new(n, y, n+3, y, color=c, style=line.style_dotted)

//-----------------------------------------------------------------------------}      
//Execution
//-----------------------------------------------------------------------------{
ph = ta.pivothigh(len, len)
pl = ta.pivotlow (len, len)

if ph.n() 
    aPivH.unshift(piv.new(ph, n -len, false, false, false, false))

if pl.n() 
    aPivL.unshift(piv.new(pl, n -len, false, false, false, false)) 

for i = aPivH.size() -1 to 0
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
                    aBoxBr.unshift(get.br(colBr3, colBr, 1))       
                    get.l(colBr2, 'dt'), lnDot(low, colBr)
                    get.wic := true  
        else 
            if close < get.prc 
                get.mit := true
            if not oW and low < get.prc and close > get.prc                    
                aBoxBr.unshift(get.br(colBl3, colBl, -1))    
                get.l(colBl2, 'ds'), lnDot(high, colBl)
                get.tak := true 

    if n - get.bix > 2000 or get.mit or get.tak 
        aPivH.remove(i).lin.delete()

for i = aPivL.size() -1 to 0
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
                    aBoxBr.unshift(get.br(colBl3, colBl, -1))     
                    get.l(colBl2, 'dt'), lnDot(high, colBl)
                    get.wic := true 
        else 
            if close > get.prc 
                get.mit := true
            if not oW and high > get.prc and close < get.prc                     
                aBoxBr.unshift(get.br(colBr3, colBr, 1))    
                get.l(colBr2, 'ds'), lnDot(low, colBr)
                get.tak := true  

    if n - get.bix > 2000 or get.mit or get.tak 
        aPivL.remove(i).lin.delete()

if extend
    for bx in aBoxBr 
        if not bx.br and n - bx.bx.get_left() -1 <= maxB 
            bx.bx.set_right(bar_index)
            if bx.dr == -1 and close < bx.bx.get_bottom() 
                bx.br := true 
            if bx.dr ==  1 and close > bx.bx.get_top   () 
                bx.br := true 

//-----------------------------------------------------------------------------
// CLEAN LIQUIDITY SWEEP ALERTS
//-----------------------------------------------------------------------------

bool bullAlert = false
bool bearAlert = false

// Detect latest sweep box
if aBoxBr.size() > 0
    lastBox = aBoxBr.get(0)

    // Bullish Sweep
    bullAlert := lastBox.dr == -1 and not lastBox.br

    // Bearish Sweep
    bearAlert := lastBox.dr == 1 and not lastBox.br

// Trigger only once
bullOnce = bullAlert and not bullAlert[1]
bearOnce = bearAlert and not bearAlert[1]

// Alert Conditions
alertcondition(bullOnce,
     title = "Bullish Liquidity Sweep",
     message = "Bullish Sweep on {{ticker}}")

alertcondition(bearOnce,
     title = "Bearish Liquidity Sweep",
     message = "Bearish Sweep on {{ticker}}")

// Optional popup alerts
if bullOnce
    alert("Bullish Sweep on " + syminfo.ticker,
         alert.freq_once_per_bar_close)

if bearOnce
    alert("Bearish Sweep on " + syminfo.ticker,
         alert.freq_once_per_bar_close)

        //-----------------------------------------------------------------------------
````
