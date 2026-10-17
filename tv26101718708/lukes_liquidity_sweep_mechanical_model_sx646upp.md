# Luke's liquidity sweep mechanical model

- url: https://www.tradingview.com/script/SX646uPP-Luke-s-liquidity-sweep-mechanical-model/
- type: indicator
- pine_id: PUB;f42197f48eb841efb26892971cc645f0
- version: 1.0

## Description

this is a mechanical entry model that uses liquidity sweeps, MSS and the fib retracement level.

Essentially all we want to see is a liquidity sweep, price break a fractal high or low, break structure,come back to the 0.618 level and enter for a fixed 1:3

## Source Code

````pine
 //@version=6
indicator("Session Liquidity MSS Fib - Ultra-Responsive Recursive", overlay = true, max_lines_count = 500, max_boxes_count = 500)

// --- Settings ---
string asiaSess  = input.session("0000-0800", "Asia Session")
string lonSess   = input.session("0800-1200", "London Session")
string nySess    = input.session("1300-1700", "NY Session")
string sessionTZ = input.string("UTC+2", "Timezone")
float fibLevel   = 0.618 
float rrRatio    = 3.0 

// --- State Variables ---
var float asiaH = na, var float asiaL = na
var float targetH = na, var float targetL = na
var bool  isArmed = false
var bool  isPending = false
var int   tradeDir = 0
var float sweepAnchor = na
var float currentExt = na 

inAsia = not na(time(timeframe.period, asiaSess, sessionTZ))
inLon  = not na(time(timeframe.period, lonSess, sessionTZ))
inNY   = not na(time(timeframe.period, nySess, sessionTZ))

// 1. Session Range Capture
if inAsia
    asiaH := not inAsia[1] ? high : math.max(high, nz(asiaH, high))
    asiaL := not inAsia[1] ? low  : math.min(low,  nz(asiaL, low))

if (inLon or inNY)
    targetH := asiaH
    targetL := asiaL

// 2. Fractal Tracking for MSS
float pLow  = ta.pivotlow(low, 2, 1)
float pHigh = ta.pivothigh(high, 2, 1)
var float lastSwingLow = na, var float lastSwingHigh = na
if not na(pLow)
    lastSwingLow := pLow
if not na(pHigh)
    lastSwingHigh := pHigh

// 3. CRITICAL: INSTANT RESET ON NEW SWEEP
// This allows the "second sell signal" to trigger by clearing the old one immediately
if (inLon or inNY)
    if tradeDir == -1 and high > nz(sweepAnchor, targetH)
        isArmed := true
        isPending := false
        tradeDir := -1
        sweepAnchor := high // New higher high becomes the new Anchor
    else if tradeDir == 1 and low < nz(sweepAnchor, targetL)
        isArmed := true
        isPending := false
        tradeDir := 1
        sweepAnchor := low
    else if not isArmed and not isPending
        if high > targetH
            isArmed := true, tradeDir := -1, sweepAnchor := high
        if low < targetL
            isArmed := true, tradeDir := 1, sweepAnchor := low

// 4. MSS Trigger (Must happen AFTER the latest sweepAnchor)
if isArmed and not isPending
    if tradeDir == -1 and low < lastSwingLow
        isPending := true, currentExt := low
    if tradeDir == 1 and high > lastSwingHigh
        isPending := true, currentExt := high

// 5. Signal Rendering
if isPending
    if tradeDir == -1 // SHORT
        currentExt := math.min(low, currentExt)
        float entry = currentExt + ((sweepAnchor - currentExt) * fibLevel)
        float sl = sweepAnchor + (syminfo.mintick * 10) // SL above the high that grabbed liquidity
        float tp = entry - ((sl - entry) * rrRatio)
        
        // DISPLAY PENDING (Always drawn on last bar if waiting for retrace)
        if barstate.islast
            box.new(bar_index, sl, bar_index + 20, entry, bgcolor=color.new(color.red, 90), border_color=color.red)
            box.new(bar_index, entry, bar_index + 20, tp, bgcolor=color.new(color.green, 90), border_color=color.green)

        // FILL TRIGGER
        if high >= entry
            box.new(bar_index, sl, bar_index + 30, entry, bgcolor=color.new(color.red, 60), border_color=color.red)
            box.new(bar_index, entry, bar_index + 30, tp, bgcolor=color.new(color.green, 60), border_color=color.green)
            label.new(bar_index, entry, "SHORT FILLED\nSL: " + str.tostring(sl, "#.#") + "\nTP: " + str.tostring(tp, "#.#"), color=color.red, textcolor=color.white)
            // Immediate state reset after fill to allow for the NEXT sweep
            isPending := false, isArmed := false, sweepAnchor := na, currentExt := na

    else if tradeDir == 1 // LONG
        currentExt := math.max(high, currentExt)
        float entry = currentExt - ((currentExt - sweepAnchor) * fibLevel)
        float sl = sweepAnchor - (syminfo.mintick * 10)
        float tp = entry + ((entry - sl) * rrRatio)

        if barstate.islast
            box.new(bar_index, tp, bar_index + 20, entry, bgcolor=color.new(color.green, 90), border_color=color.green)
            box.new(bar_index, entry, bar_index + 20, sl, bgcolor=color.new(color.red, 90), border_color=color.red)

        if low <= entry
            box.new(bar_index, tp, bar_index + 30, entry, bgcolor=color.new(color.green, 60), border_color=color.green)
            box.new(bar_index, entry, bar_index + 30, sl, bgcolor=color.new(color.red, 60), border_color=color.red)
            label.new(bar_index, entry, "LONG FILLED\nSL: " + str.tostring(sl, "#.#") + "\nTP: " + str.tostring(tp, "#.#"), color=color.green, textcolor=color.white)
            isPending := false, isArmed := false, sweepAnchor := na, currentExt := na

// Daily cleanup
if inAsia and not inAsia[1]
    isArmed := false, isPending := false, sweepAnchor := na, currentExt := na
````
