# Historical Date Average Prediction

- url: https://www.tradingview.com/script/qxANUPow-Historical-Date-Average-Prediction/
- type: indicator
- pine_id: PUB;def17fc1447343d188a868d4789bddd1
- version: 2.0

## Description

How it Works
Date Matching: The script attempts to find the bar where the month and dayofmonth match today’s date.

Offset Calculation: Since there are roughly 252 trading days in a year, the script looks back in increments of 252 (or uses timestamp functions) to find the price action from 1, 2, or 5 years ago today.

The Average: It sums the highs and lows of those specific historical days and divides them by the number of years found.

## Source Code

````pine
//@version=6
indicator("Historical High Band Only", overlay=true, precision=2, max_bars_back=2000)

// ==========================================
// SETTINGS
// ==========================================
yearsToLook = input.int(3, "Years to Average", minval=1, maxval=10)
showLabel   = input.bool(true, "Show High Target Label")

// ==========================================
// CALCULATION LOGIC
// ==========================================
getHistData() =>
    float sumH = 0.0
    float sumL = 0.0
    int count  = 0
    for i = 1 to (252 * yearsToLook)
        if month[i] == month and dayofmonth[i] == dayofmonth
            sumH := sumH + ((high[i] / open[i]) - 1)
            sumL := sumL + ((low[i] / open[i]) - 1)
            count := count + 1
    [sumH / count, sumL / count]

[avgPctHigh, avgPctLow] = getHistData()

// Apply to current open
predictHigh = open * (1 + nz(avgPctHigh))
predictLow  = open * (1 + nz(avgPctLow))

// ==========================================
// VISUALS
// ==========================================
pHigh = plot(predictHigh, "Predicted High", color=color.new(color.green, 0), linewidth=2)
pLow  = plot(predictLow, "Predicted Low", color=color.new(color.red, 0), linewidth=2)

fill(pHigh, pLow, color=color.new(color.blue, 90), title="Prediction Zone")

// ==========================================
// LABEL - PINNED TO GREEN ONLY
// ==========================================
if barstate.islast and showLabel and not na(avgPctHigh)
    // This creates a label only on the Green line
    label.new(bar_index, predictHigh, "High Target: +" + str.tostring(avgPctHigh * 100, "#.##") + "%", 
         color=color.green, 
         textcolor=color.white, 
         style=label.style_label_down, 
         yloc=yloc.price)
````
