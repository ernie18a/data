# M1 CVD Divergence + Divergence Traps Indicator [XAU Optimized]

- url: https://www.tradingview.com/script/Xk73A0El-M1-CVD-Divergence-Divergence-Traps-Indicator-XAU-Optimized/
- type: indicator
- pine_id: PUB;83da715036da4781b52f41082b829107
- version: 1.0

## Description

M1 Indicator optimized for Gold that indicates when CVD divergence happens. Now added divergence traps indiocators as well. Best used in trending markets. Avoid in consolidation and sideways market.

## Source Code

````pine
//@version=6
indicator("Pivot-to-Pivot CVD [With Divergence Traps]", overlay=true, max_labels_count=500)

// Standard Gold Structure Inputs
left = input.int(5, title="Pivot Left Bars")
right = input.int(2, title="Pivot Right Bars")
useHidden = input.bool(true, title="Include Hidden Divergence")

// THE TIMER: Max candles to wait for the stop run to trigger
trapWindow = input.int(12, title="Max Trap Window (Bars)", tooltip="If the level doesn't break within this many bars, the trap expires.")

// Pure Cumulative Volume Delta for Gold
volDelta = close > open ? volume : close < open ? -volume : 0
cvd = ta.cum(volDelta)

// Structural Pivot Calculation
pl = ta.pivotlow(low, left, right)
ph = ta.pivothigh(high, left, right)

// Base State Variables
var float lastPLPrice = na
var float lastPLCVD = na
var float lastPHPrice = na
var float lastPHCVD = na

bool isBull = false
bool isBear = false

// NEW TRAP STATE VARIABLES
var float activeBullPivotLevel = na
var float activeBearPivotLevel = na
var int activeBullPivotBar = na
var int activeBearPivotBar = na

bool isBullTrap = false
bool isBearTrap = false

// Bullish Divergence Evaluation
if not na(pl)
    currentPLPrice = pl
    currentPLCVD = cvd[right] 
    
    if not na(lastPLPrice)
        regBull = currentPLPrice < lastPLPrice and currentPLCVD > lastPLCVD
        hidBull = useHidden and currentPLPrice > lastPLPrice and currentPLCVD < lastPLCVD
        
        if regBull or hidBull
            isBull := true
            // Lock in support level and the exact bar index it occurred on
            activeBullPivotLevel := currentPLPrice 
            activeBullPivotBar := bar_index - right 
            // Reset opposing trap
            activeBearPivotLevel := na 
            
    lastPLPrice := currentPLPrice
    lastPLCVD := currentPLCVD

// Bearish Divergence Evaluation
if not na(ph)
    currentPHPrice = ph
    currentPHCVD = cvd[right] 
    
    if not na(lastPHPrice)
        regBear = currentPHPrice > lastPHPrice and currentPHCVD < lastPHCVD
        hidBear = useHidden and currentPHPrice < lastPHPrice and currentPHCVD > lastPHCVD
        
        if regBear or hidBear
            isBear := true
            // Lock in resistance level and the exact bar index it occurred on
            activeBearPivotLevel := currentPHPrice 
            activeBearPivotBar := bar_index - right
            // Reset opposing trap
            activeBullPivotLevel := na 
            
    lastPHPrice := currentPHPrice
    lastPHCVD := currentPHCVD

// EVALUATE TRAPS (With 12-Bar Expiration)

// Bull Trap (Failed Support = Go Short)
if not na(activeBullPivotLevel)
    // Check if we are still within the 12 candle window
    if (bar_index - activeBullPivotBar) <= trapWindow
        if close < activeBullPivotLevel
            isBullTrap := true
            activeBullPivotLevel := na // Deactivate trap after it fires
    else
        activeBullPivotLevel := na // Window expired, clear the memory

// Bear Trap (Failed Resistance = Go Long)
if not na(activeBearPivotLevel)
    // Check if we are still within the 12 candle window
    if (bar_index - activeBearPivotBar) <= trapWindow
        if close > activeBearPivotLevel
            isBearTrap := true
            activeBearPivotLevel := na // Deactivate trap after it fires
    else
        activeBearPivotLevel := na // Window expired, clear the memory

// Plotting Original Signals
plotchar(isBear, title="Bear Divergence", char="▼", location=location.abovebar, color=color.red, size=size.small, text="Bear", textcolor=color.white, offset=-right)
plotchar(isBull, title="Bull Divergence", char="▲", location=location.belowbar, color=color.green, size=size.small, text="Bull", textcolor=color.white, offset=-right)

// Plotting Pointed Trap Signals with Custom Soft Colors
// Bull trap triggers a drop, so the label points DOWN at the candle top.
plotshape(isBullTrap, title="Bull Trap Triggered", style=shape.labeldown, location=location.abovebar, color=#ff6666, size=size.normal, text="TRAP", textcolor=color.white)

// Bear trap triggers a pump, so the label points UP at the candle bottom.
plotshape(isBearTrap, title="Bear Trap Triggered", style=shape.labelup, location=location.belowbar, color=#66ff66, size=size.normal, text="TRAP", textcolor=color.black)
````
