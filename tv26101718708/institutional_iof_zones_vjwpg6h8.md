# Institutional IOF Zones

- url: https://www.tradingview.com/script/Vjwpg6h8-Institutional-IOF-Zones/
- type: indicator
- pine_id: PUB;9631542e9c9b4a6b936de495a7056e75
- version: 1.0

## Description

[b]The Institutional IOF (Order Flow) Zones - Pro[/b] is a high-precision technical indicator designed to identify and track "Smart Money" interest through the mathematical lens of Candlestick Imbalance and Momentum Displacement. Unlike standard Supply/Demand indicators, this script requires a specific "Cause and Effect" relationship before a zone is validated, filtering out market noise and focus on high-probability institutional footprints.

[b]The Mathematical Framework[/b]
The indicator operates on two primary quantitative filters to validate a zone:

[b]1. Imbalance Detection (The Cause)[/b]
The script identifies "Imbalance Candles" (Dojis, Hammers, Spinning Tops) where the market is in a state of high compression or indecision.

Total Range (R) = High - Low
Body Size (B) = |Close - Open|
Wick Ratio (W) = (R - B) / R
Criterion: A candle is marked for potential imbalance ONLY IF W > Threshold (Default 50%). This ensures the candle represents a battleground of orders where wicks dominate the body.
[b]2. Displacement Validation (The Effect)[/b]
An imbalance candle is only meaningful if it is followed by an institutional "run." The following candle (Index 0) must show significant Displacement:

Momentum Ratio (M) = B / R
Criterion: The breakout candle must satisfy M > 0.60. Mathematically, this means the body must occupy at least 60% of the total candle range, proving that one side of the market has overwhelmed the other with high-volume intent.

[b]Zone Physics & Institutional Order Flow (IOF)[/b]
Once validated, the zone is projected forward using specific price coordinates:

Demand Zone (Bullish): Top = Close of Imbalance Candle; Bottom = Low of Imbalance Candle.
Supply Zone (Bearish): Top = High of Imbalance Candle; Bottom = Close of Imbalance Candle.
Mitigation & Flip Logic (Dynamic Calculus)
The indicator tracks price interaction with these zones in real-time:

Mitigation: If Price (P) enters the zone (P < Zone Top for Demand), the state transitions to "Mitigated." This suggests the "unfilled orders" have been tapped.
The Flip (Breaker Logic): If Price (P) entirely violates the zone (P < Zone Bottom for Demand), the zone mathematically "Flips."
Bullish -> Bearish: Becomes a Supply zone.
Bearish -> Bullish: Becomes a Demand zone.

[b]Fibonacci & Internal Defense Levels[/b]
Within each zone, the script calculates internal mathematical equilibrium points:

Midline (Equilibrium): (Zone Top + Zone Bottom) / 2
Golden Pocket (GP): Zone Top - (Range * 0.618)
Optimal Trade Entry (OTE): Zone Top - (Range * 0.705)
These levels act as high-sensitivity areas where institutions typically re-accumulate or distribute positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Institutional IOF Zones", overlay = true, max_boxes_count = 500, max_lines_count = 500)

wPerc = input.float(50.0, "Wick % Threshold") / 100.0
mAct  = input.int(20, "Max Active Zones")
mMit  = input.int(10, "Max Mitigated Zones")
mExp  = input.int(20, "Mitigated Expiry (Bars)")
tMit  = input.bool(true, "Use Touch Mitigation")

sMid  = input.bool(true, "Show Midline", inline="L1")
sGP   = input.bool(false, "Show Golden Pocket", inline="L1")
sOTE  = input.bool(false, "Show OTE (0.705)", inline="L2")
s80   = input.bool(false, "Show 80% Defense", inline="L2")
s90   = input.bool(false, "Show 90% Defense", inline="L3")
lCol  = input.color(color.gray, "Level Color", inline="L3")

bullC = input.color(#089981cc, "Bullish Color")
bearC = input.color(#f23645cc, "Bearish Color")
mitC  = input.color(#808080cc, "Mitigated Color")

type IOFZone
    box   zBox
    float zTop
    float zBot
    bool  zIsBull
    bool  zIsMit
    int   zMTime
    line  zL1
    line  zL2
    line  zL3
    line  zL4
    line  zL5

var activeArr = array.new<IOFZone>()
var mitArr    = array.new<IOFZone>()

cRng = high - low
bSiz = math.abs(close - open)
isI  = cRng > 0 and bSiz < cRng * (1.0 - wPerc)
isB  = isI[1] and close[1] > open[1] and low > close[1]
isS  = isI[1] and close[1] < open[1] and high < close[1]

if array.size(activeArr) > 0
    for i = array.size(activeArr) - 1 to 0
        z = array.get(activeArr, i)
        p = tMit ? (z.zIsBull ? low : high) : close
        bool becameMit = false
        
        if not z.zIsMit
            if z.zIsBull and p < z.zTop
                if p < z.zBot
                    z.zIsBull := false
                    box.set_bgcolor(z.zBox, bearC)
                else
                    z.zIsMit := true, z.zMTime := bar_index
                    box.set_bgcolor(z.zBox, mitC)
                    becameMit := true
            else if not z.zIsBull and p > z.zBot
                if p > z.zTop
                    z.zIsBull := true
                    box.set_bgcolor(z.zBox, bullC)
                else
                    z.zIsMit := true, z.zMTime := bar_index
                    box.set_bgcolor(z.zBox, mitC)
                    becameMit := true
        
        box.set_right(z.zBox, bar_index)
        
        rng = z.zTop - z.zBot
        x1 = int(box.get_left(z.zBox))
        x2 = bar_index
        
        if sMid
            v = z.zBot + rng * 0.5
            if na(z.zL1)
                z.zL1 := line.new(x1, v, x2, v, color=lCol, style=line.style_dashed)
            else
                line.set_xy2(z.zL1, x2, v)
        if sGP
            v = z.zIsBull ? z.zTop - rng * 0.618 : z.zBot + rng * 0.618
            if na(z.zL2)
                z.zL2 := line.new(x1, v, x2, v, color=lCol, style=line.style_dotted)
            else
                line.set_xy2(z.zL2, x2, v)
        if sOTE
            v = z.zIsBull ? z.zTop - rng * 0.705 : z.zBot + rng * 0.705
            if na(z.zL3)
                z.zL3 := line.new(x1, v, x2, v, color=lCol, style=line.style_dotted)
            else
                line.set_xy2(z.zL3, x2, v)
        if s80
            v = z.zIsBull ? z.zTop - rng * 0.80 : z.zBot + rng * 0.80
            if na(z.zL4)
                z.zL4 := line.new(x1, v, x2, v, color=lCol, style=line.style_dotted)
            else
                line.set_xy2(z.zL4, x2, v)
        if s90
            v = z.zIsBull ? z.zTop - rng * 0.90 : z.zBot + rng * 0.90
            if na(z.zL5)
                z.zL5 := line.new(x1, v, x2, v, color=lCol, style=line.style_dotted)
            else
                line.set_xy2(z.zL5, x2, v)

        if becameMit
            array.remove(activeArr, i), array.unshift(mitArr, z)

if array.size(mitArr) > 0
    for i = array.size(mitArr) - 1 to 0
        z = array.get(mitArr, i)
        box.set_right(z.zBox, bar_index)
        
        x2 = bar_index
        if not na(z.zL1)
            line.set_xy2(z.zL1, x2, line.get_y1(z.zL1))
        if not na(z.zL2)
            line.set_xy2(z.zL2, x2, line.get_y1(z.zL2))
        if not na(z.zL3)
            line.set_xy2(z.zL3, x2, line.get_y1(z.zL3))
        if not na(z.zL4)
            line.set_xy2(z.zL4, x2, line.get_y1(z.zL4))
        if not na(z.zL5)
            line.set_xy2(z.zL5, x2, line.get_y1(z.zL5))

        if bar_index - z.zMTime > mExp or i >= mMit
            box.delete(z.zBox)
            line.delete(z.zL1), line.delete(z.zL2), line.delete(z.zL3), line.delete(z.zL4), line.delete(z.zL5)
            array.remove(mitArr, i)

if isB or isS
    t = isB ? close[1] : high[1]
    b = isB ? low[1] : close[1]
    bx = box.new(bar_index-1, t, bar_index, b, bgcolor=isB?bullC:bearC, border_color=na)
    array.unshift(activeArr, IOFZone.new(bx, t, b, isB, false, 0, na, na, na, na, na))

if array.size(activeArr) > mAct
    oz = array.pop(activeArr)
    box.delete(oz.zBox)
    line.delete(oz.zL1), line.delete(oz.zL2), line.delete(oz.zL3), line.delete(oz.zL4), line.delete(oz.zL5)

plotshape(isB, "B", shape.triangleup, location.belowbar, color.new(#089981, 0), size=size.tiny, offset=-1)
plotshape(isS, "S", shape.triangledown, location.abovebar, color.new(#f23645, 0), size=size.tiny, offset=-1)
````
