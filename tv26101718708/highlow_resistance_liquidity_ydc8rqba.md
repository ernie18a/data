# High/Low Resistance Liquidity

- url: https://www.tradingview.com/script/YDC8rQba-High-Low-Resistance-Liquidity/
- type: indicator
- pine_id: PUB;0c561a701a3347ef9bcd30f131d214f3
- version: 1.0

## Description

Description

Not all liquidity pools are created equal. The market behaves very differently when attacking a clean, pristine target versus when it is grinding through jagged, already-swept price action.

The High/Low Resistance Liquidity indicator is an automated structural mapping engine that programmatically identifies and categorizes liquidity pools into Low Resistance (LRLR) and High Resistance (HRLR) targets in real-time.

🎯 What is LRLR and HRLR?
LRLR (Low Resistance Liquidity Run): These are "clean" targets. When stops are perfectly clustered at the exact same price, it creates a massive, unobstructed magnetic pull for price. When price attacks these areas, it displaces quickly and aggressively.
HRLR (High Resistance Liquidity Run): These are "dirty" or swept targets. If a pivot high has already swept a previous high and rejected (a false breakout or sweep), the liquidity resting there was already purged. Price will struggle, chop, and overlap heavily if it attempts to push back into that isolated zone.

✨ Key Features
Automated Target Detection: The indicator maps structural highs and lows using customizable left/right bar pivot confirmations, and immediately evaluates their relationship to the previous market structure.
EQH/EQL Detection (LRLR): If a new structural pivot forms within a tight tick threshold of the previous pivot, it validates them as Equal Highs or Equal Lows. A solid, highly visible line is drawn forward, marking a pristine Low Resistance target.
Swept Pivot Detection (HRLR): If a new pivot extends past the old pivot and reverses, it validates a sweep. A dotted warning line is drawn forward, marking a High Resistance target where price is likely to struggle.
Real-Time Mitigation: The script actively monitors price action. The exact moment a future candle wicks or closes through an active liquidity line, the line stops extending and its label updates to "Mitigated", keeping your charts completely free of historical clutter.
Standard Liquidity Toggle: Choose whether you only want to see explicit LRLR/HRLR targets, or if you want to also track all standard, unmitigated intermediate pivots in the background.

⚙️ Settings
Pivot Strength: Fully customize how many bars are required left and right to confirm a major structural point.
EQH/EQL Tolerance (Ticks): You dictate exactly how tight the price must align to be considered "Equal". (e.g., 5-10 ticks on lower timeframes, or expand it for Daily charts).
Display Settings: Toggle the visibility of Standard Unmitigated Pivots, turn text labels on or off, and fully customize the line colors to fit your exact chart aesthetic.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("High/Low Resistance Liquidity", shorttitle="HRLR/LRLR", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Settings ---
grp_pivots = "Pivot & Structure Settings"
pivotLeft  = input.int(5, "Pivot Left Bars", minval=1, group=grp_pivots, tooltip="Number of bars to the left to confirm a structural high/low.")
pivotRight = input.int(5, "Pivot Right Bars", minval=1, group=grp_pivots, tooltip="Number of bars to the right to confirm a structural high/low.")

grp_lrlr = "LRLR Settings (Low Resistance)"
lrlrToleranceTicks = input.int(10, "EQH/EQL Tolerance (Ticks)", minval=0, group=grp_lrlr, tooltip="Maximum tick distance between two structural points to be considered Equal Highs or Equal Lows (LRLR).")

grp_visuals = "Display & Visuals"
colLRLR            = input.color(color.new(#2962FF, 0), "LRLR Color (EQH/EQL)", group=grp_visuals)
colHRLR            = input.color(color.new(#FF5252, 0), "HRLR Color (Swept Pivot)", group=grp_visuals)
showStandardPivots = input.bool(false, "Show Standard Unmitigated Pivots", group=grp_visuals)
colStd             = input.color(color.new(#9E9E9E, 50), "Standard Pivot Color", group=grp_visuals)
showLabels         = input.bool(true, "Show Text Labels", group=grp_visuals)


// --- Data Structures ---
type LiquidityPool
    float priceLevel
    int   startBar
    bool  isHigh
    int   poolType // 0 = Standard, 1 = LRLR, 2 = HRLR
    line  ln
    label lbl

var array<LiquidityPool> activePools = array.new<LiquidityPool>()

// Track historical pivots to compare new ones against
var array<float> phHistory = array.new<float>()
var array<float> plHistory = array.new<float>()

// --- Pivot Detection ---
float ph = ta.pivothigh(high, pivotLeft, pivotRight)
float pl = ta.pivotlow(low, pivotLeft, pivotRight)

bool newPH = not na(ph)
bool newPL = not na(pl)

// The bar index where the pivot ACTUALLY occurred
int phBar = bar_index - pivotRight
int plBar = bar_index - pivotRight

float tickSize = syminfo.mintick

// --- Evaluate New Pivot Highs ---
if newPH
    int poolType = 0 // 0 = Standard
    float lastPH = na
    
    if array.size(phHistory) > 0
        lastPH := array.get(phHistory, array.size(phHistory) - 1)
        
    if not na(lastPH)
        // Check LRLR (Equal Highs)
        if math.abs(ph - lastPH) / tickSize <= lrlrToleranceTicks
            poolType := 1 // LRLR
        // Check HRLR (Swept High)
        else if ph > lastPH
            poolType := 2 // HRLR
            
    array.push(phHistory, ph)
    if array.size(phHistory) > 500
        array.shift(phHistory)
        
    if poolType > 0 or showStandardPivots
        color  col   = poolType == 1 ? colLRLR : (poolType == 2 ? colHRLR : colStd)
        string style = poolType == 1 ? line.style_solid : (poolType == 2 ? line.style_dotted : line.style_dashed)
        string txt   = poolType == 1 ? "LRLR (EQH)" : (poolType == 2 ? "HRLR (Sweep)" : "Liq")
        
        line ln = line.new(phBar, ph, bar_index, ph, color=col, style=style, width=poolType > 0 ? 2 : 1)
        label lbl = na
        if showLabels
            lbl := label.new(phBar, ph, text=txt, color=color.new(color.white, 100), textcolor=col, style=label.style_label_left, size=size.tiny)
            
        array.push(activePools, LiquidityPool.new(ph, phBar, true, poolType, ln, lbl))

// --- Evaluate New Pivot Lows ---
if newPL
    int poolType = 0 // 0 = Standard
    float lastPL = na
    
    if array.size(plHistory) > 0
        lastPL := array.get(plHistory, array.size(plHistory) - 1)
        
    if not na(lastPL)
        // Check LRLR (Equal Lows)
        if math.abs(pl - lastPL) / tickSize <= lrlrToleranceTicks
            poolType := 1 // LRLR
        // Check HRLR (Swept Low)
        else if pl < lastPL
            poolType := 2 // HRLR
            
    array.push(plHistory, pl)
    if array.size(plHistory) > 500
        array.shift(plHistory)
        
    if poolType > 0 or showStandardPivots
        color  col   = poolType == 1 ? colLRLR : (poolType == 2 ? colHRLR : colStd)
        string style = poolType == 1 ? line.style_solid : (poolType == 2 ? line.style_dotted : line.style_dashed)
        string txt   = poolType == 1 ? "LRLR (EQL)" : (poolType == 2 ? "HRLR (Sweep)" : "Liq")
        
        line ln = line.new(plBar, pl, bar_index, pl, color=col, style=style, width=poolType > 0 ? 2 : 1)
        label lbl = na
        if showLabels
            lbl := label.new(plBar, pl, text=txt, color=color.new(color.white, 100), textcolor=col, style=label.style_label_left, size=size.tiny)
            
        array.push(activePools, LiquidityPool.new(pl, plBar, false, poolType, ln, lbl))


// --- Real-Time Mitigation Engine ---
if array.size(activePools) > 0
    for i = array.size(activePools) - 1 to 0
        LiquidityPool p = array.get(activePools, i)
        
        bool mitigated = false
        if p.isHigh and high >= p.priceLevel
            mitigated := true
        else if not p.isHigh and low <= p.priceLevel
            mitigated := true
            
        if mitigated
            line.set_x2(p.ln, bar_index)
            if not na(p.lbl)
                label.set_x(p.lbl, bar_index)
                label.set_text(p.lbl, p.poolType == 1 ? "LRLR (Mitigated)" : (p.poolType == 2 ? "HRLR (Mitigated)" : "Liq (Mitigated)"))
            // Remove from active array so it stops extending
            array.remove(activePools, i)
        else
            // Extend the lines and labels forward
            line.set_x2(p.ln, bar_index)
            if not na(p.lbl)
                label.set_x(p.lbl, bar_index)
````
