# Boshmann's Regime Counters

- url: https://www.tradingview.com/script/olidrsMg-Boshmann-s-Regime-Counters/
- type: indicator
- pine_id: PUB;5622467211c94764abd472039c934d0d
- version: 5.0

## Description

Summary of Boshmann's Regime Counters
At its core, this indicator is designed to remove human subjectivity from chart reading by translating market behavior into purely objective, mathematically defined states. Rather than relying on discretionary trendlines or "gut feelings" about market speed, it uses robust statistical baselines to continuously classify the market into discrete Trend and Volatility regimes.

For TradingView users, this provides an immediate, systematic context of the market environment, which is crucial because trading strategies (like mean-reversion vs. trend-following) only perform well when aligned with the correct market state.

1. Trend Regime Classification (Directional Bias)
The indicator evaluates moving average alignments to determine the structural trend. It requires both price position and momentum to agree before declaring a strong trend:

Bull: The closing price is strictly above a long-term baseline (200 SMA) AND short-term momentum (20 SMA) is leading the medium-term momentum (100 SMA).
Bear: The closing price is below the 200 SMA AND the 20 SMA has crossed below the 100 SMA.
Sideways: Any state where the price and moving averages are in conflict or tangled.
Visuals: The chart bars are painted dynamically (Green for Bull, Red for Bear, Golden for Sideways) so the current regime is instantly visible.
2. Volatility Regime Classification (Market Speed)
Instead of using fixed point values to measure volatility (which break down across different timeframes and assets), the indicator uses an Adaptive Z-Score of the Average True Range (ATR). By looking back over a large sample size (250 periods), it calculates a rolling mean and standard deviation of the ATR. This normalizes volatility into a universal metric:

Quiet (Z-Score < -0.5): The market is contracting and experiencing significantly below-average movement.
Normal (Z-Score -0.5 to 0.5): The market is operating within its standard, expected historical variance.
Volatile (Z-Score > 0.5): The market is expanding, experiencing statistically significant, out-sized movement.
3. The Statistics Dashboard
The script anchors a real-time statistical dashboard to the chart. It tallies the exact number of bars—and calculates the overall historical percentage—spent in each specific trend and volatility regime.

What this does for TradingView users:

Strategy Alignment: By quantifying exactly how much time an asset spends trending versus chopping sideways, traders can objectively decide whether to deploy a trend-following system or a range-bound strategy on that specific asset.
Contextual Awareness: The adaptive Z-score prevents users from being caught off guard by volatility expansion, giving them a mathematical warning when the market shifts from "Quiet" accumulation into "Volatile" distribution.
Backtesting Validation: The on-chart percentages give quantitative traders immediate insight into the asset's structural personality over the loaded history (e.g., realizing an asset is only in a "Strong Bull" state 25% of the time helps set realistic win-rate expectations).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © boshmann

//@version=6
indicator('Boshmann\'s Regime Counters v2', overlay = true, max_bars_back = 5000)

showTable = input.bool(true, 'Show Statistics Table')
tablePosInput = input.string('Top Right', 'Table Position', options=['Top Right', 'Bottom Right'])
tableSizeInput = input.string('Normal', 'Table Size', options=['Small', 'Normal'])
tSize = tableSizeInput == 'Normal' ? size.normal : size.small

grp_mr = 'Market Regime (v2) Settings'
trendPeriod = input.int(200, 'Trend SMA Period', minval = 1, group = grp_mr)
shortPeriod = input.int(20, 'Short SMA Period', minval = 1, group = grp_mr)
longPeriod = input.int(100, 'Long SMA Period', minval = 1, group = grp_mr)
atrPeriod_MR = input.int(14, 'ATR Normalization Period', minval = 1, group = grp_mr, tooltip="Used to calculate the normalized spread shown in Data Window")

grp_vol = 'Volatility (v3) Settings'
atrPeriod = input.int(14, 'ATR Period', minval = 1, group = grp_vol)
zLookback = input.int(250, 'Z-Score Lookback', minval = 2, group = grp_vol)
zLower = input.float(-0.5, 'Z-Score Lower Threshold (Quiet)', group = grp_vol)
zUpper = input.float(0.5, 'Z-Score Upper Threshold (Volatile)', group = grp_vol)
zStress = input.float(1.0, 'Z-Score Stress Threshold', group = grp_vol)

// --- Logic ---
trendSMA = ta.sma(close, trendPeriod)
shortSMA = ta.sma(close, shortPeriod)
longSMA = ta.sma(close, longPeriod)

isPriceAboveTrend = close > trendSMA
isShortAboveLong = shortSMA > longSMA

isStrongBull = isPriceAboveTrend and isShortAboveLong
isStrongBear = not isPriceAboveTrend and not isShortAboveLong
isSideways = not isStrongBull and not isStrongBear

// v2 Normalization values for data window transparency
rawSpread = shortSMA - longSMA
atrVal_MR = ta.atr(atrPeriod_MR)
normalizedSpread = atrVal_MR == 0 ? 0 : rawSpread / atrVal_MR
plot(normalizedSpread, "Normalized Spread (ATR)", display=display.data_window)

atrVal = ta.atr(atrPeriod)
atrSma = ta.sma(atrVal, zLookback)
atrStdDev = ta.stdev(atrVal, zLookback)
zScore = atrStdDev == 0 ? 0 : (atrVal - atrSma) / atrStdDev

isQuiet = zScore < zLower
isNormal = zScore >= zLower and zScore <= zUpper
isVolatile = zScore > zUpper

// --- Coloring ---
colorBull = color.new(color.green, 0)
colorBear = color.new(color.red, 0)
colorSideways = color.new(#DAA520, 0)

colorQuiet = color.new(color.green, 0)
colorNormal = color.new(#DAA520, 0)
colorVolatile = color.new(color.red, 0)

dirColor = isSideways ? colorSideways : na
barcolor(dirColor)

// --- Statistics Table ---
var int countBull = 0
var int countBear = 0
var int countSideways = 0
var int countQuiet = 0
var int countNormal = 0
var int countVolatile = 0
var int totalBars = 0

var float ptsBull = 0.0
var float ptsBear = 0.0
var float ptsSideways = 0.0
var float ptsQuiet = 0.0
var float ptsNormal = 0.0
var float ptsVolatile = 0.0

barPoints = ta.tr / syminfo.mintick

inVisibleRange = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
if barstate.isconfirmed and inVisibleRange
    totalBars := totalBars + 1
    if isStrongBull
        countBull := countBull + 1
        ptsBull := ptsBull + barPoints
    else if isStrongBear
        countBear := countBear + 1
        ptsBear := ptsBear + barPoints
    else
        countSideways := countSideways + 1
        ptsSideways := ptsSideways + barPoints

    if isQuiet
        countQuiet := countQuiet + 1
        ptsQuiet := ptsQuiet + barPoints
    else if isNormal
        countNormal := countNormal + 1
        ptsNormal := ptsNormal + barPoints
    else
        countVolatile := countVolatile + 1
        ptsVolatile := ptsVolatile + barPoints

tPos = tablePosInput == 'Top Right' ? position.top_right : position.bottom_right
var table statsTable = table.new(tPos, 5, 8, bgcolor = color.new(color.white, 100), border_width = 0)

if showTable and barstate.islast
    pctBull = totalBars > 0 ? countBull / totalBars * 100 : 0
    pctBear = totalBars > 0 ? countBear / totalBars * 100 : 0
    pctSide = totalBars > 0 ? countSideways / totalBars * 100 : 0
    pctQuiet = totalBars > 0 ? countQuiet / totalBars * 100 : 0
    pctNormal = totalBars > 0 ? countNormal / totalBars * 100 : 0
    pctVol = totalBars > 0 ? countVolatile / totalBars * 100 : 0

    // Round percentages and ensure they sum to exactly 100
    rPctBull = math.round(pctBull)
    rPctBear = math.round(pctBear)
    rPctSide = math.round(pctSide)
    if totalBars > 0
        diffDir = 100 - (rPctBull + rPctBear + rPctSide)
        if diffDir != 0
            if countBull >= countBear and countBull >= countSideways
                rPctBull := rPctBull + diffDir
            else if countBear >= countBull and countBear >= countSideways
                rPctBear := rPctBear + diffDir
            else
                rPctSide := rPctSide + diffDir

    rPctQuiet = math.round(pctQuiet)
    rPctNormal = math.round(pctNormal)
    rPctVol = math.round(pctVol)
    if totalBars > 0
        diffVol = 100 - (rPctQuiet + rPctNormal + rPctVol)
        if diffVol != 0
            if countQuiet >= countNormal and countQuiet >= countVolatile
                rPctQuiet := rPctQuiet + diffVol
            else if countNormal >= countQuiet and countNormal >= countVolatile
                rPctNormal := rPctNormal + diffVol
            else
                rPctVol := rPctVol + diffVol

    avgPtsBull = countBull > 0 ? math.round(ptsBull / countBull) : 0
    avgPtsBear = countBear > 0 ? math.round(ptsBear / countBear) : 0
    avgPtsSide = countSideways > 0 ? math.round(ptsSideways / countSideways) : 0
    avgPtsQuiet = countQuiet > 0 ? math.round(ptsQuiet / countQuiet) : 0
    avgPtsNormal = countNormal > 0 ? math.round(ptsNormal / countNormal) : 0
    avgPtsVol = countVolatile > 0 ? math.round(ptsVolatile / countVolatile) : 0
    avgPtsTotal = totalBars > 0 ? math.round((ptsBull + ptsBear + ptsSideways) / totalBars) : 0

    // Headers Row
    table.cell(statsTable, 0, 0, 'Regime', text_color = color.gray, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 0, '# Bars', text_color = color.gray, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 0, '%', text_color = color.gray, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 0, 'Avg Pts', text_color = color.gray, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 4, 0, '', width = 3) // Invisible right margin

    // Direction Regimes
    table.cell(statsTable, 0, 1, 'Bull', text_color = colorBull, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 1, str.tostring(countBull), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 1, str.tostring(rPctBull), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 1, str.tostring(avgPtsBull), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))

    table.cell(statsTable, 0, 2, 'Bear', text_color = colorBear, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 2, str.tostring(countBear), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 2, str.tostring(rPctBear), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 2, str.tostring(avgPtsBear), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))

    table.cell(statsTable, 0, 3, 'Sideways', text_color = colorSideways, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 3, str.tostring(countSideways), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 3, str.tostring(rPctSide), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 3, str.tostring(avgPtsSide), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))

    // Total Row
    table.cell(statsTable, 0, 4, 'TOTAL', text_color = color.black, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 4, str.tostring(totalBars), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 4, '100', text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 4, str.tostring(avgPtsTotal), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))

    // Volatility Regimes
    table.cell(statsTable, 0, 5, 'Quiet', text_color = colorQuiet, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 5, str.tostring(countQuiet), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 5, str.tostring(rPctQuiet), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 5, str.tostring(avgPtsQuiet), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))

    table.cell(statsTable, 0, 6, 'Normal', text_color = colorNormal, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 6, str.tostring(countNormal), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 6, str.tostring(rPctNormal), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 6, str.tostring(avgPtsNormal), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))

    table.cell(statsTable, 0, 7, 'Volatile', text_color = colorVolatile, text_size = tSize, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 1, 7, str.tostring(countVolatile), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 2, 7, str.tostring(rPctVol), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
    table.cell(statsTable, 3, 7, str.tostring(avgPtsVol), text_color = color.black, text_size = tSize, text_halign = text.align_right, bgcolor = color.new(color.black, 80))
````
