# Marco Top Detector

- url: https://www.tradingview.com/script/gyq3Jq14-Marco-Top-Detector/
- type: indicator
- pine_id: PUB;e0a7356f8d744e3983ba74f346606bdc
- version: 3.0

## Description

Marco Top Detector (v1.0)
This release introduces the Marco Top Detector, a specialized technical indicator designed to filter market noise and pinpoint significant structural highs and lows.

核心功能 (Core Features)
Deviation-Based Logic: Employs an ATR-linked percentage threshold to ensure that only meaningful price reversals are marked, ignoring minor "choppy" fluctuations.

Depth-Verified Pivots: Uses a look-back/look-forward window (Depth) to verify that a peak or valley is the absolute highest or lowest point in its neighborhood before triggering.

Native Style Integration: Powered by plotshape, allowing you to customize colors, toggle visibility, and adjust label shapes directly from the Style tab in indicator settings.

Auto-Updating Peaks: The logic "drags" labels higher (for Tops) or lower (for Bottoms) if price continues to push in the same direction before a reversal is confirmed.

Alerts & UI
Top/Bottom Detected Alerts: Two dedicated alert conditions are available for real-time notifications when a confirmed pivot is identified.

Offset Precision: Labels are automatically offset to the exact historical bar where the high or low occurred, rather than the bar where the confirmation was finalized.

Theme Compatibility: Includes a White Mode toggle to switch text contrast for light or dark chart backgrounds.

How to Use
Add to Chart: Search for "Marco Top Detector" in your scripts.

Adjust Sensitivity: Increase Deviation to ignore smaller moves or increase Depth for more conservative, long-term peak detection.

Set Alerts: Create a new alert and select "Top Detected" or "Bottom Detected" from the condition dropdown.

## Source Code

````pine
//@version=5
indicator("Marco Polo Top Detective", overlay=true)

// --- Inputs ---
threshold_multiplier = input.float(title="Deviation", defval=2.0, minval=0)
depth = input.int(title="Depth", defval=22, minval=1)
whiteMode = input.bool(true, "White Text (False for Black)")

// --- Global Variables ---
var float pLast = 0.0
var int iLast = 0
var bool isHighLast = false

// --- Calculations ---
dev_threshold = ta.atr(10) / close * 100 * threshold_multiplier

// Pivot Detection Function
pivots(src, length, isHigh) =>
    c = nz(src[length])
    ok = true
    for i = 0 to length
        if (isHigh and src[i] > c) or (not isHigh and src[i] < c)
            ok := false
            break
    int pivotIndex = ok ? bar_index[length] : na
    float pivotPrice = ok ? c : na
    [pivotIndex, pivotPrice]

[iH, pH] = pivots(high, depth, true)
[iL, pL] = pivots(low, depth, false)

calc_dev(base_price, price) =>
    100 * (price - base_price) / price

// --- Logic & Plotting ---
// Initialize as false to ensure clean boolean toggling each bar
bool isTopPlot = false
bool isBottomPlot = false

if not na(iH) or not na(iL)
    foundIndex = not na(iH) ? iH : iL
    foundPrice = not na(iH) ? pH : pL
    isHigh     = not na(iH)
    
    dev = calc_dev(pLast, foundPrice)
    
    if isHighLast == isHigh
        if (isHighLast ? foundPrice > pLast : foundPrice < pLast)
            iLast := foundIndex
            pLast := foundPrice
    else
        if math.abs(dev) > dev_threshold or pLast == 0.0
            if isHigh
                isTopPlot := true 
            else
                isBottomPlot := true 
            
            iLast      := foundIndex
            pLast      := foundPrice
            isHighLast := isHigh


////////////// reversal bearish and bullish /////////////////
// inputs
length = input.int(19, title="BBands Length", minval=1, group="Reversal Bar")   
reversal_mult = input.float(2, title="BBands Multiplier", minval=0.001, maxval=50, group="Reversal Bar")    

// calculate bollinger bands
reversal_basis = ta.sma(close, length)
dev = reversal_mult * ta.stdev(close, length)
upper = reversal_basis + dev
lower = reversal_basis - dev

// Reversal Bar - Bullish Signal logic maintained 100%
// Pseudo: everything above AND candle close above signal candles wick.
bullReversalConfirm = low[2] < lower[2] and close[2] < open[2] and close[1] > lower[1] and close[1] > open[1] and close > high[1]

// Reversal Bar - Bearish Signal logic maintained 100%
// Pseudo: everything above AND candle close below signal candles wick.
bearReversalConfirm = high[2] > upper[2] and close[2] > open[2] and close[1] < upper[1] and close[1] < open[1] and close < low[1]

//isTop = isTopPlot or bearReversalConfirm
//isBottom = isBottomPlot or bullReversalConfirm
// --- UI Output ---

// 1. Plot the Pivot Labels (Requires Offset)
plotshape(isTopPlot, title="Top Pivot", text="Top", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=whiteMode ? color.white : color.black, size=size.normal, offset=-depth)
plotshape(isBottomPlot, title="Bottom Pivot", text="Bottom", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=whiteMode ? color.white : color.black, size=size.normal, offset=-depth)

// 2. Plot the Reversal Labels (No Offset - Appears on Current Bar)
plotshape(bearReversalConfirm, title="Bearish Reversal",style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small)
plotshape(bullReversalConfirm, title="Bullish Reversal", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)

alertcondition(bearReversalConfirm, "Top Bearish Reversal Detected", "Marco Top Detector: Bearish Reversal identified.")
alertcondition(bullReversalConfirm, "Bottom Bullish Reversal Detected", "Marco Top Detector: Bullish Reversal identified.")
````
