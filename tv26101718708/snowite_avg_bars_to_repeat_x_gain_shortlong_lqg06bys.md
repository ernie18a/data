# [Snowite] Avg Bars to Repeat X% Gain (Short/Long)

- url: https://www.tradingview.com/script/LQg06bYs-Snowite-Avg-Bars-to-Repeat-X-Gain-Short-Long/
- type: indicator
- pine_id: PUB;ee1daf2c6bf04b1fadbca6c989bea59e
- version: 1.0

## Description

This script flags any candle that closes at least X% above its open (e.g. open 10, close 10.30 = +3%). Each time this happens, it measures how many bars passed since the last time it happened, then averages all those gaps over the last N bars — shown in a table on the top-right of the chart.
2 adjustable settings:

X% Threshold – how big the up-move needs to be to count
Lookback (bars) – how far back to look when calculating the average

## Source Code

````pine
//@version=6
indicator('Avg Bars to Repeat X% Gain (Short/Long)', overlay = true)

// ============ Inputs ============
xPct = input.float(3.0, 'X% Threshold (close > open by X%)', minval = 0.01, step = 0.1)
lookbackS = input.int(100, 'Lookback - Short (bars)', minval = 5, maxval = 5000)
lookbackL = input.int(500, 'Lookback - Long (bars)', minval = 5, maxval = 5000)
fontSizeOpt = input.string('Small', 'Table Font Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'])

fontSize = fontSizeOpt == 'Tiny' ? size.tiny : fontSizeOpt == 'Small' ? size.small : fontSizeOpt == 'Normal' ? size.normal : fontSizeOpt == 'Large' ? size.large : size.huge

// ============ Signal ============
// สัญญาณ: แท่งนั้น close > open และ (close-open)/open*100 >= X%
pctMove = (close - open) / open * 100
isSignal = close > open and pctMove >= xPct

// ============ Track signal bar indices ============
var array<int> signalBars = array.new_int(0)

if isSignal
    array.push(signalBars, bar_index)

// ============ Helper: compute stats for a given lookback ============
computeStats(int lb) =>
    int sizeArr = array.size(signalBars)
    int cntInWindow = 0
    float sumGap = 0.0
    int gapCount = 0
    int lastBarsAgo = na

    if sizeArr > 0
        lastIdx = array.get(signalBars, sizeArr - 1)
        lastBarsAgo := bar_index - lastIdx

        for i = 0 to sizeArr - 1 by 1
            sb = array.get(signalBars, i)
            if bar_index - sb <= lb
                cntInWindow := cntInWindow + 1
                if i > 0
                    prevSb = array.get(signalBars, i - 1)
                    gap = sb - prevSb
                    sumGap := sumGap + gap
                    gapCount := gapCount + 1
                    gapCount

    float avgGap = gapCount > 0 ? sumGap / gapCount : na
    [cntInWindow, avgGap, lastBarsAgo]

// ============ Table ============
var table t = table.new(position.top_right, 3, 6, border_width = 1, bgcolor = color.new(color.black, 20), border_color = color.gray)

if barstate.islast
    [cntS, avgGapS, lastAgoS] = computeStats(lookbackS)
    [cntL, avgGapL, lastAgoL] = computeStats(lookbackL)

    // Header row
    table.cell(t, 0, 0, 'Metric', text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = fontSize)
    table.cell(t, 1, 0, 'Short (' + str.tostring(lookbackS) + ')', text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = fontSize)
    table.cell(t, 2, 0, 'Long (' + str.tostring(lookbackL) + ')', text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = fontSize)

    // Threshold (shared, shown once but repeated for clarity)
    table.cell(t, 0, 1, 'Threshold', text_color = color.white, text_size = fontSize)
    table.cell(t, 1, 1, str.tostring(xPct, '#.##') + '%', text_color = color.white, text_size = fontSize)
    table.cell(t, 2, 1, str.tostring(xPct, '#.##') + '%', text_color = color.white, text_size = fontSize)

    table.cell(t, 0, 2, 'Signal Count', text_color = color.white, text_size = fontSize)
    table.cell(t, 1, 2, str.tostring(cntS), text_color = color.white, text_size = fontSize)
    table.cell(t, 2, 2, str.tostring(cntL), text_color = color.white, text_size = fontSize)

    // Bias: compare Avg Wait Short vs Long, % diff based on Long
    // pctDiff > 10%  -> Short much faster than Long (momentum accelerating) -> BULLISH
    // pctDiff <= 10% -> not enough acceleration (or Short slower than Long) -> BEARISH
    float pctDiff = not na(avgGapS) and not na(avgGapL) and avgGapL != 0 ? (avgGapL - avgGapS) / avgGapL * 100 : na
    bool isBullish = not na(pctDiff) and pctDiff > 10
    bool hasData = not na(pctDiff)
    color shortWaitColor = hasData ? isBullish ? color.new(color.lime, 0) : color.new(color.red, 0) : color.yellow

    table.cell(t, 0, 3, 'Avg Wait (bars)', text_color = color.white, text_size = fontSize)
    table.cell(t, 1, 3, na(avgGapS) ? 'n/a' : str.tostring(avgGapS, '#.##'), text_color = shortWaitColor, text_size = fontSize)
    table.cell(t, 2, 3, na(avgGapL) ? 'n/a' : str.tostring(avgGapL, '#.##'), text_color = color.yellow, text_size = fontSize)

    table.cell(t, 0, 4, 'Last Signal', text_color = color.white, text_size = fontSize)
    table.cell(t, 1, 4, na(lastAgoS) ? 'n/a' : str.tostring(lastAgoS) + ' bars ago', text_color = color.white, text_size = fontSize)
    table.cell(t, 2, 4, na(lastAgoL) ? 'n/a' : str.tostring(lastAgoL) + ' bars ago', text_color = color.white, text_size = fontSize)

    table.cell(t, 0, 5, 'Bias', text_color = color.white, text_size = fontSize)
    table.merge_cells(t, 1, 5, 2, 5)
    string biasText = not hasData ? 'n/a' : isBullish ? 'BULLISH (accelerating)' : 'BEARISH'
    color biasColor = not hasData ? color.gray : isBullish ? color.new(color.lime, 0) : color.new(color.red, 0)
    table.cell(t, 1, 5, biasText, text_color = biasColor, text_size = fontSize)
````
