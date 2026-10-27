# Major Liquidity Sweep + FVG + CSD

- url: https://www.tradingview.com/script/VoSa4cfV-Major-Liquidity-Sweep-FVG-CSD/
- type: indicator
- pine_id: PUB;3fb007caa5aa4b02a7229bef96ce39c4
- version: 1.0

## Description

Major Liquidity Sweep + FVG + CSD

A smart money concepts indicator designed to identify only the most significant liquidity events across all timeframes while keeping the chart clean and actionable.

This indicator combines:

Major Liquidity Sweeps
Fair Value Gaps (FVGs)
Change in State of Delivery (CSD)

to help traders identify potential reversals, continuations, and institutional order flow shifts with higher precision.

Features
Major Liquidity Sweeps

Detects high-quality liquidity grabs using confirmed pivot highs and lows instead of marking every minor sweep.

Bullish Sweep:

Price takes liquidity below a major swing low
Then closes back above the level

Bearish Sweep:

Price takes liquidity above a major swing high
Then closes back below the level

Built-in filters help eliminate noise:

Adjustable swing sensitivity
ATR-based significance filter
Optional volume confirmation
User-controlled display limits
Fair Value Gaps (FVGs)

Automatically detects institutional imbalances using the classic 3-candle FVG model.

Bullish FVG:

Current candle low is above the high from 2 candles ago

Bearish FVG:

Current candle high is below the low from 2 candles ago

Features:

Dynamic FVG boxes
Extend-until-filled logic
Optional automatic deletion once mitigated
ATR filtering for cleaner imbalance zones
Change in State of Delivery (CSD)

Confirms potential directional shifts after liquidity is taken.

Bullish CSD:

Occurs after a bullish liquidity sweep
Price breaks above internal structure

Bearish CSD:

Occurs after a bearish liquidity sweep
Price breaks below internal structure

This helps traders identify:

Market reversals
Continuation entries
Institutional momentum shifts
Alerts Included

Custom alerts for:

Bullish Liquidity Sweep
Bearish Liquidity Sweep
Bullish FVG
Bearish FVG
Bullish CSD
Bearish CSD
Sweep + CSD Confirmation

Perfect for:

Intraday trading
Scalping
Swing trading
SMT / ICT / SMC-style analysis
Best Used For
Identifying stop hunts
Spotting institutional reversals
Finding high-probability entries
Tracking delivery shifts after liquidity is taken
Confluence with market structure and higher timeframe bias
Recommended Settings

Scalping:

Swing Strength: 3–5

Intraday:

Swing Strength: 5–8

Swing Trading:

Swing Strength: 8–15

Higher swing strength = fewer but more significant liquidity sweeps.

Notes
Non-repainting after candle close
Works on all timeframes
Designed to prioritize quality over quantity
Keeps charts clean by limiting displayed objects

Built for traders who want institutional-style liquidity analysis without excessive chart clutter.

## Source Code

````pine
//@version=6
indicator("Major Liquidity Sweep + FVG + CSD", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// INPUTS
swingStrength = input.int(5, "Liquidity Swing Strength", minval=2)
internalStrength = input.int(2, "Internal Swing Strength for CSD", minval=1)

maxSweeps = input.int(10, "Number of Liquidity Sweeps to Display", minval=1)
maxFVGs = input.int(10, "Number of FVGs to Display", minval=1)

atrLength = input.int(14, "ATR Length")
minSweepATR = input.float(0.25, "Minimum Sweep Size ATR Multiplier", step=0.05)
minFVGATR = input.float(0.10, "Minimum FVG Size ATR Multiplier", step=0.05)

useVolumeFilter = input.bool(false, "Use Volume Confirmation")
volumeLength = input.int(20, "Volume MA Length")

showBullSweeps = input.bool(true, "Show Bullish Sweeps")
showBearSweeps = input.bool(true, "Show Bearish Sweeps")
showFVGs = input.bool(true, "Show Fair Value Gaps")
showCSD = input.bool(true, "Show Change in State of Delivery")

deleteFilledFVG = input.bool(true, "Delete Filled FVGs")
useCloseFill = input.bool(false, "Use Close to Fill FVG")

// CALCULATIONS
atr = ta.atr(atrLength)
volMA = ta.sma(volume, volumeLength)
volumeOK = not useVolumeFilter or volume > volMA

// ARRAYS
var label[] sweepLabels = array.new_label()
var line[] sweepLines = array.new_line()
var box[] fvgBoxes = array.new_box()
var label[] csdLabels = array.new_label()

// PIVOTS
pivotHigh = ta.pivothigh(high, swingStrength, swingStrength)
pivotLow = ta.pivotlow(low, swingStrength, swingStrength)

internalHigh = ta.pivothigh(high, internalStrength, internalStrength)
internalLow = ta.pivotlow(low, internalStrength, internalStrength)

var float lastMajorHigh = na
var float lastMajorLow = na
var int lastMajorHighBar = na
var int lastMajorLowBar = na

var float lastInternalHigh = na
var float lastInternalLow = na

if not na(pivotHigh)
    lastMajorHigh := pivotHigh
    lastMajorHighBar := bar_index - swingStrength

if not na(pivotLow)
    lastMajorLow := pivotLow
    lastMajorLowBar := bar_index - swingStrength

if not na(internalHigh)
    lastInternalHigh := internalHigh

if not na(internalLow)
    lastInternalLow := internalLow

// MAJOR LIQUIDITY SWEEPS
bearSweep = not na(lastMajorHigh) and high > lastMajorHigh and close < lastMajorHigh and (high - lastMajorHigh) >= atr * minSweepATR and volumeOK
bullSweep = not na(lastMajorLow) and low < lastMajorLow and close > lastMajorLow and (lastMajorLow - low) >= atr * minSweepATR and volumeOK

var bool waitingBullCSD = false
var bool waitingBearCSD = false

if bullSweep and showBullSweeps
    lbl = label.new(bar_index, low, "Bullish Liquidity Sweep", style=label.style_label_up, textcolor=color.white, color=color.green)
    ln = line.new(lastMajorLowBar, lastMajorLow, bar_index, lastMajorLow, color=color.green, width=2)
    array.push(sweepLabels, lbl)
    array.push(sweepLines, ln)
    waitingBullCSD := true
    waitingBearCSD := false

if bearSweep and showBearSweeps
    lbl = label.new(bar_index, high, "Bearish Liquidity Sweep", style=label.style_label_down, textcolor=color.white, color=color.red)
    ln = line.new(lastMajorHighBar, lastMajorHigh, bar_index, lastMajorHigh, color=color.red, width=2)
    array.push(sweepLabels, lbl)
    array.push(sweepLines, ln)
    waitingBearCSD := true
    waitingBullCSD := false

while array.size(sweepLabels) > maxSweeps
    label.delete(array.shift(sweepLabels))

while array.size(sweepLines) > maxSweeps
    line.delete(array.shift(sweepLines))

// FAIR VALUE GAPS
bullFVG = showFVGs and low > high[2] and (low - high[2]) >= atr * minFVGATR
bearFVG = showFVGs and high < low[2] and (low[2] - high) >= atr * minFVGATR

if bullFVG
    b = box.new(left=bar_index - 2, top=low, right=bar_index, bottom=high[2], bgcolor=color.new(color.green, 85), border_color=color.green)
    array.push(fvgBoxes, b)

if bearFVG
    b = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high, bgcolor=color.new(color.red, 85), border_color=color.red)
    array.push(fvgBoxes, b)

for i = array.size(fvgBoxes) - 1 to 0
    b = array.get(fvgBoxes, i)
    box.set_right(b, bar_index)

    top = box.get_top(b)
    bottom = box.get_bottom(b)

    filledBull = useCloseFill ? close <= bottom : low <= bottom
    filledBear = useCloseFill ? close >= top : high >= top

    isBullBox = bottom < top and close > bottom
    isBearBox = bottom < top and close < top

    if deleteFilledFVG and ((isBullBox and filledBull) or (isBearBox and filledBear))
        box.delete(b)
        array.remove(fvgBoxes, i)

while array.size(fvgBoxes) > maxFVGs
    box.delete(array.shift(fvgBoxes))

// CHANGE IN STATE OF DELIVERY
bullCSD = waitingBullCSD and not na(lastInternalHigh) and close > lastInternalHigh
bearCSD = waitingBearCSD and not na(lastInternalLow) and close < lastInternalLow

if bullCSD and showCSD
    lbl = label.new(bar_index, high, "Bullish CSD", style=label.style_label_down, textcolor=color.white, color=color.blue)
    array.push(csdLabels, lbl)
    waitingBullCSD := false

if bearCSD and showCSD
    lbl = label.new(bar_index, low, "Bearish CSD", style=label.style_label_up, textcolor=color.white, color=color.orange)
    array.push(csdLabels, lbl)
    waitingBearCSD := false

while array.size(csdLabels) > maxSweeps
    label.delete(array.shift(csdLabels))

// ALERTS
alertcondition(bullSweep, "Bullish Liquidity Sweep", "Bullish liquidity sweep detected.")
alertcondition(bearSweep, "Bearish Liquidity Sweep", "Bearish liquidity sweep detected.")
alertcondition(bullFVG, "Bullish FVG Created", "Bullish fair value gap created.")
alertcondition(bearFVG, "Bearish FVG Created", "Bearish fair value gap created.")
alertcondition(bullCSD, "Bullish CSD", "Bullish change in state of delivery detected.")
alertcondition(bearCSD, "Bearish CSD", "Bearish change in state of delivery detected.")
alertcondition(bullCSD or bearCSD, "Sweep + CSD Confirmation", "Liquidity sweep followed by CSD confirmation.")
````
