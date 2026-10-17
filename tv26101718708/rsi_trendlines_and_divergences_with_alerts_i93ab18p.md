# RSI Trendlines and Divergences with alerts

- url: https://www.tradingview.com/script/I93ab18p-rsi-trendlines-and-divergences-with-alerts/
- type: indicator
- pine_id: PUB;4bd084d2257a401eba6290c745463b7c
- version: 1.0

## Description

RSI TRENDLINES AND DIVERGENCES

OVERVIEW
An all-in-one RSI toolkit that combines four independent analytical layers in a single indicator: automatic trendlines drawn on the RSI itself, automatic support/resistance trendlines on price, classic pivot-based RSI divergence, and a separate regression-based divergence engine. Instead of stacking several scripts, you get a coordinated set of momentum and structure tools that can confirm one another.


WHAT IT DOES

1. RSI Trendlines (oscillator pane)
Detects pivot highs and pivot lows directly on the RSI line and connects consecutive pivots into dynamic trendlines. Descending lines off RSI peaks act as momentum resistance; ascending lines off RSI troughs act as momentum support. A tolerance band (in RSI points) is drawn around each line and filled, and a break is only flagged when RSI crosses the line beyond that tolerance — which filters out noise. Counter-direction lines (for example, a rising line off highs) are automatically discarded, so only meaningful trendlines stay on the pane.

2. Price Trendlines (main chart)
The same pivot-to-pivot logic applied to price highs and lows, drawn as support and resistance lines directly on the price chart. Breaks use a percentage-based tolerance to reduce false signals, and optional up/down triangle labels mark confirmed breakouts.

3. Pivot Divergence
Classic regular divergence between price and RSI. A lower low in price against a higher low in RSI marks bullish divergence; a higher high in price against a lower high in RSI marks bearish divergence. Detection is limited to a recent window so stale readings are ignored, and results are shown as connecting lines and Bull/Bear labels on the RSI.

4. Regression Divergence (independent method)
A separate, math-driven divergence engine that fits a least-squares linear regression to both RSI and price over a configurable window. When the two regressions slope in opposite directions, and the move clears a minimum magnitude filter, a regression divergence is flagged with lines on both the RSI and the price, plus optional labels. Because it does not rely on pivots, it often catches divergences the pivot method misses, and vice versa.


SETTINGS

- RSI Settings: RSI length, signal SMA length, and source.
- Pivot Settings (Trend): left/right pivot bars, line extension after the 2nd pivot, break tolerance, and max trendlines per type. All lines share TradingView's 500-line budget, so the trendline and regression limits are balanced against each other.
- Price Trendline Settings: independent pivot bars, extension, and a percentage-based break tolerance.
- Divergence Settings: enable/disable plus pivot length for the classic method.
- Regression Divergence: window length, minimum RSI slope, line and label toggles, number of stored line pairs, and colors.
- Style Settings: full color and transparency control for every element on both the RSI pane and the price chart.


ALERTS
Ready-made alert conditions for: bullish and bearish pivot divergence, upper and lower RSI trendline breaks, price resistance and support breaks, and regression bullish and bearish divergence.


HOW TO USE
Use the trendline breaks to time momentum shifts, the price trendlines for structural support and resistance, and treat agreement between the two divergence engines as stronger confluence. Combine these signals with your own market-structure and trend context — the tools highlight conditions, they are not standalone buy or sell calls.


CREDITS
Built on the RSI trendline concept by Uncle_the_shooter. The regression-divergence module is adapted from faytterro's "RSI Divergence." Thanks to both authors.

This script is for educational and informational purposes only and is not financial advice. Test on your own data and always manage risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('RSI Trendlines and Divergences', overlay = false, max_lines_count = 500, max_labels_count = 200)

// ============================ INPUTS ============================
rsiLength = input.int(14, 'RSI Length', group = 'RSI Settings')
smaLength = input.int(9, 'SMA Length', group = 'RSI Settings')
src = input.source(close, 'Source', group = 'RSI Settings')
leftBars = input.int(10, 'Left Bars for Pivot', group = 'Pivot Settings for Trend')
rightBars = input.int(10, 'Right Bars for Pivot', group = 'Pivot Settings for Trend')
extendBars = input.int(30, 'Extension after 2nd Pivot (Bars). 0 = None', minval = 0, group = 'Pivot Settings for Trend')
tolerance = input.float(3.0, 'Tolerance (RSI Points)', minval = 0.0, group = 'Pivot Settings for Trend')
maxTrendlines = input.int(40, 'Max Trendlines per Type', minval = 5, maxval = 50, group = 'Pivot Settings for Trend', tooltip = 'Ліміт трендових на кожен тип (RSI верх/низ, ціна верх/низ). Бюджет ліній 500 спільний: 8*maxTrendlines + 2*Max Reg Div Lines <= 500.')

// --- Price trendline inputs ---
enablePriceTrend = input.bool(true, 'Enable Price Trendlines', group = 'Price Trendline Settings')
pLeftBars = input.int(10, 'Left Bars for Price Pivot', group = 'Price Trendline Settings')
pRightBars = input.int(10, 'Right Bars for Price Pivot', group = 'Price Trendline Settings')
pExtendBars = input.int(30, 'Price Extension after 2nd Pivot (Bars). 0 = None', minval = 0, group = 'Price Trendline Settings')
priceTolPct = input.float(0.1, 'Price Break Tolerance (%)', minval = 0.0, step = 0.05, group = 'Price Trendline Settings', tooltip = 'Допуск пробою у відсотках від ціни. Фільтрує помилкові пробої.')

// Divergence inputs
calculateDivergence = input.bool(true, title = 'Enable Divergence Detection', group = 'Divergence Settings')
divPivotLen = input.int(5, title = 'Pivot Length for Divergence', minval = 1, group = 'Divergence Settings')

// --- Regression divergence inputs (ported from faytterro 'RSI Divergence') ---
enableRegDiv = input.bool(true, 'Enable Regression Divergence', group = 'Regression Divergence', tooltip = 'Незалежний метод: лінійна регресія RSI vs ціни. Дивергенція = протилежні нахили + фільтр величини руху.')
rdLen = input.int(25, 'Regression Length', minval = 5, maxval = 200, group = 'Regression Divergence')
rdThresh = input.float(5.0, 'Min RSI Slope (points)', minval = 0.0, step = 0.5, group = 'Regression Divergence', tooltip = 'Мінімальна зміна RSI на вікні, щоб зарахувати дивергенцію.')
rdDrawLines = input.bool(true, 'Draw Regression Lines', group = 'Regression Divergence')
rdShowLabels = input.bool(true, 'Show Regression Labels', group = 'Regression Divergence', tooltip = 'Показувати плашки Reg Bull/Bear Divergence на графіку.')
rdMaxLines = input.int(20, 'Max Reg Div Lines', minval = 2, maxval = 40, group = 'Regression Divergence', tooltip = 'Скільки останніх пар регресійних ліній тримати (RSI + ціна). Ділять бюджет 500 з трендовими.')
rdBullColor = input.color(color.lime, 'Reg Bullish Color', group = 'Regression Divergence')
rdBearColor = input.color(color.orange, 'Reg Bearish Color', group = 'Regression Divergence')

// Color inputs (RSI pane)
highLineColor = input.color(color.red, 'Upper Trendline Color', group = 'Style Settings')
highFillColor = input.color(color.new(color.red, 70), 'Upper Fill Color', group = 'Style Settings')
lowLineColor = input.color(color.green, 'Lower Trendline Color', group = 'Style Settings')
lowFillColor = input.color(color.new(color.green, 70), 'Lower Fill Color', group = 'Style Settings')
smaColor = input.color(color.yellow, 'SMA Color', group = 'Style Settings')
rsiColor = input.color(color.gray, 'RSI Color', group = 'Style Settings')
bullDivColor = input.color(color.green, 'Bullish Divergence Color', group = 'Style Settings')
bearDivColor = input.color(color.red, 'Bearish Divergence Color', group = 'Style Settings')
textColor = input.color(color.white, 'Text Color', group = 'Style Settings')
bandTransparency = input.int(40, title = 'Divergence Label Transparency', minval = 0, maxval = 100, group = 'Style Settings')
signalTransparency = input.int(80, title = 'Signal Highlight Transparency', minval = 0, maxval = 100, group = 'Style Settings')

// Color inputs (price chart)
priceHighLineColor = input.color(color.red, 'Price Resistance Color', group = 'Price Style Settings')
priceHighFillColor = input.color(color.new(color.red, 80), 'Price Resistance Fill', group = 'Price Style Settings')
priceLowLineColor = input.color(color.green, 'Price Support Color', group = 'Price Style Settings')
priceLowFillColor = input.color(color.new(color.green, 80), 'Price Support Fill', group = 'Price Style Settings')
priceLineWidth = input.int(2, 'Price Trendline Width', minval = 1, group = 'Price Style Settings')
showBreakLabels = input.bool(true, 'Show Break Labels on Chart', group = 'Price Style Settings')

// ============================ RSI & PIVOTS ============================
rsi = ta.rsi(src, rsiLength)
rsiSMA = ta.sma(rsi, smaLength)
pHigh = ta.pivothigh(rsi, leftBars, rightBars)
pLow = ta.pivotlow(rsi, leftBars, rightBars)
pHighDiv = ta.pivothigh(rsi, divPivotLen, divPivotLen)
pLowDiv = ta.pivotlow(rsi, divPivotLen, divPivotLen)
pHighPriceDiv = ta.pivothigh(high, divPivotLen, divPivotLen)
pLowPriceDiv = ta.pivotlow(low, divPivotLen, divPivotLen)

// Price pivots for chart trendlines
pHighPriceTL = ta.pivothigh(high, pLeftBars, pRightBars)
pLowPriceTL = ta.pivotlow(low, pLeftBars, pRightBars)

// ============================ STORAGE (RSI pane) ============================
var array<line> linesHigh = array.new_line()
var array<line> linesLow = array.new_line()
var array<line> parallelsHigh = array.new_line()
var array<line> parallelsLow = array.new_line()
var array<linefill> fillsHigh = array.new_linefill()
var array<linefill> fillsLow = array.new_linefill()
var array<float> slopesHigh = array.new_float()
var array<float> slopesLow = array.new_float()
var array<int> x1High = array.new_int()
var array<int> x1Low = array.new_int()
var array<float> y1High = array.new_float()
var array<float> y1Low = array.new_float()
var array<bool> brokenHigh = array.new_bool()
var array<bool> brokenLow = array.new_bool()
var array<bool> signaledHigh = array.new_bool()
var array<bool> signaledLow = array.new_bool()

// ============================ STORAGE (price chart) ============================
var array<line> pLinesHigh = array.new_line()
var array<line> pLinesLow = array.new_line()
var array<line> pParallelsHigh = array.new_line()
var array<line> pParallelsLow = array.new_line()
var array<linefill> pFillsHigh = array.new_linefill()
var array<linefill> pFillsLow = array.new_linefill()
var array<float> pSlopesHigh = array.new_float()
var array<float> pSlopesLow = array.new_float()
var array<int> pX1High = array.new_int()
var array<int> pX1Low = array.new_int()
var array<float> pY1High = array.new_float()
var array<float> pY1Low = array.new_float()
var array<bool> pBrokenHigh = array.new_bool()
var array<bool> pBrokenLow = array.new_bool()
var array<bool> pSignaledHigh = array.new_bool()
var array<bool> pSignaledLow = array.new_bool()

// ============================ STORAGE (regression divergence) ============================
var array<line> rdLines = array.new_line()

// ============================ FUNCTIONS ============================
f_trim(arrLines, arrSlopes, arrX, arrY, arrBroken, arrParallels, arrFills, arrSignaled, maxCount) =>
    while array.size(arrLines) > maxCount
        ln = array.shift(arrLines)
        line.delete(ln)
        array.shift(arrSlopes)
        array.shift(arrX)
        array.shift(arrY)
        array.shift(arrBroken)
        array.shift(arrSignaled)
        par = array.shift(arrParallels)
        line.delete(par)
        fil = array.shift(arrFills)
        linefill.delete(fil)

f_remove(arrLines, arrSlopes, arrX, arrY, arrBroken, arrParallels, arrFills, arrSignaled, idx) =>
    ln = array.remove(arrLines, idx)
    line.delete(ln)
    array.remove(arrSlopes, idx)
    array.remove(arrX, idx)
    array.remove(arrY, idx)
    array.remove(arrBroken, idx)
    array.remove(arrSignaled, idx)
    par = array.remove(arrParallels, idx)
    line.delete(par)
    fil = array.remove(arrFills, idx)
    linefill.delete(fil)

// RSI break check (uses rsi + RSI-point tolerance)
f_check_break(ln, slope, x1, y1, brokenArr, signaledArr, idx, isHigh, arrFills) =>
    bool crossedDown = false
    bool crossedUp = false
    bool crossOccurred = false
    if idx < array.size(brokenArr)
        if not array.get(brokenArr, idx) and not array.get(signaledArr, idx)
            x2 = line.get_x2(ln)
            if bar_index >= x1 and bar_index <= x2
                prevY = y1 + slope * (bar_index - 1 - x1)
                yLine = y1 + slope * (bar_index - x1)
                crossedUp := isHigh and rsi > yLine + tolerance and rsi[1] <= prevY + tolerance
                crossedDown := not isHigh and rsi < yLine - tolerance and rsi[1] >= prevY - tolerance
                if crossedDown or crossedUp
                    crossOccurred := true
                    baseColor = isHigh ? highLineColor : lowLineColor
                    array.set(brokenArr, idx, true)
                    array.set(signaledArr, idx, true)
                    line.set_color(ln, baseColor)
                    linefill.set_color(array.get(arrFills, idx), isHigh ? highFillColor : lowFillColor)
    [crossedDown, crossedUp, crossOccurred]

// Price break check (uses close + price tolerance passed in)
f_check_break_price(ln, slope, x1, y1, brokenArr, signaledArr, idx, isHigh, arrFills, tol) =>
    bool crossedDown = false
    bool crossedUp = false
    bool crossOccurred = false
    if idx < array.size(brokenArr)
        if not array.get(brokenArr, idx) and not array.get(signaledArr, idx)
            x2 = line.get_x2(ln)
            if bar_index >= x1 and bar_index <= x2
                prevY = y1 + slope * (bar_index - 1 - x1)
                yLine = y1 + slope * (bar_index - x1)
                crossedUp := isHigh and close > yLine + tol and close[1] <= prevY + tol
                crossedDown := not isHigh and close < yLine - tol and close[1] >= prevY - tol
                if crossedDown or crossedUp
                    crossOccurred := true
                    baseColor = isHigh ? priceHighLineColor : priceLowLineColor
                    array.set(brokenArr, idx, true)
                    array.set(signaledArr, idx, true)
                    line.set_color(ln, baseColor)
                    linefill.set_color(array.get(arrFills, idx), isHigh ? priceHighFillColor : priceLowFillColor)
    [crossedDown, crossedUp, crossOccurred]

// ============================ DIVERGENCE DETECTION ============================
var bool plFound = false
var bool phFound = false
var bool bullCond = false
var bool bearCond = false

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    bars <= 60

if calculateDivergence
    plFound := not na(pLowDiv)
    phFound := not na(pHighDiv)
    rsiLbr = rsi[divPivotLen]
    priceLbr = low[divPivotLen]
    priceLh = high[divPivotLen]
    rsiLl = rsiLbr > ta.valuewhen(plFound, rsiLbr, 1) and _inRange(plFound[1])
    priceLl = priceLbr < ta.valuewhen(plFound, priceLbr, 1)
    bullCond := priceLl and rsiLl and plFound
    rsiLh = rsiLbr < ta.valuewhen(phFound, rsiLbr, 1) and _inRange(phFound[1])
    priceHh = priceLh > ta.valuewhen(phFound, priceLh, 1)
    bearCond := priceHh and rsiLh and phFound
    bearCond

// ============================ RSI: ON PIVOT HIGH ============================
if not na(pHigh)
    idx = bar_index - rightBars
    y = pHigh
    var float slope = 0.0
    newL = line.new(idx, y, idx, y, color = highLineColor, width = 2)
    newPar = line.new(idx, math.min(100, y + tolerance), idx, math.min(100, y + tolerance), color = color.new(color.red, 100), width = 2)
    newFill = linefill.new(newL, newPar, highFillColor)
    array.push(linesHigh, newL)
    array.push(parallelsHigh, newPar)
    array.push(fillsHigh, newFill)
    array.push(slopesHigh, 0.0)
    array.push(x1High, idx)
    array.push(y1High, y)
    array.push(brokenHigh, false)
    array.push(signaledHigh, false)
    if array.size(linesHigh) > 1
        last = array.get(linesHigh, array.size(linesHigh) - 2)
        lastPar = array.get(parallelsHigh, array.size(parallelsHigh) - 2)
        x1 = array.get(x1High, array.size(x1High) - 2)
        y1 = array.get(y1High, array.size(y1High) - 2)
        x2_pivot = idx
        y2_pivot = y
        x2_ext = x2_pivot + extendBars
        dx = x2_pivot - x1
        slope := dx != 0 ? (y2_pivot - y1) / float(dx) : 0.0
        y2_ext = y1 + slope * float(x2_ext - x1)
        y2_ext_clamped = math.max(0, math.min(100, y2_ext))
        y2_par_clamped = math.max(0, math.min(100, y2_ext + tolerance))
        line.set_x2(last, x2_ext)
        line.set_y2(last, y2_ext_clamped)
        line.set_x2(lastPar, x2_ext)
        line.set_y2(lastPar, y2_par_clamped)
        array.set(slopesHigh, array.size(slopesHigh) - 2, slope)
        if slope > 0
            f_remove(linesHigh, slopesHigh, x1High, y1High, brokenHigh, parallelsHigh, fillsHigh, signaledHigh, array.size(linesHigh) - 2)
    f_trim(linesHigh, slopesHigh, x1High, y1High, brokenHigh, parallelsHigh, fillsHigh, signaledHigh, maxTrendlines)

// ============================ RSI: ON PIVOT LOW ============================
if not na(pLow)
    idx = bar_index - rightBars
    y = pLow
    var float slope = 0.0
    newL = line.new(idx, y, idx, y, color = lowLineColor, width = 2)
    newPar = line.new(idx, math.max(0, y - tolerance), idx, math.max(0, y - tolerance), color = color.new(color.green, 100), width = 2)
    newFill = linefill.new(newL, newPar, lowFillColor)
    array.push(linesLow, newL)
    array.push(parallelsLow, newPar)
    array.push(fillsLow, newFill)
    array.push(slopesLow, 0.0)
    array.push(x1Low, idx)
    array.push(y1Low, y)
    array.push(brokenLow, false)
    array.push(signaledLow, false)
    if array.size(linesLow) > 1
        last = array.get(linesLow, array.size(linesLow) - 2)
        lastPar = array.get(parallelsLow, array.size(parallelsLow) - 2)
        x1 = array.get(x1Low, array.size(x1Low) - 2)
        y1 = array.get(y1Low, array.size(y1Low) - 2)
        x2_pivot = idx
        y2_pivot = y
        x2_ext = x2_pivot + extendBars
        dx = x2_pivot - x1
        slope := dx != 0 ? (y2_pivot - y1) / float(dx) : 0.0
        y2_ext = y1 + slope * float(x2_ext - x1)
        y2_ext_clamped = math.max(0, math.min(100, y2_ext))
        y2_par_clamped = math.max(0, math.min(100, y2_ext - tolerance))
        line.set_x2(last, x2_ext)
        line.set_y2(last, y2_ext_clamped)
        line.set_x2(lastPar, x2_ext)
        line.set_y2(lastPar, y2_par_clamped)
        array.set(slopesLow, array.size(slopesLow) - 2, slope)
        if slope < 0
            f_remove(linesLow, slopesLow, x1Low, y1Low, brokenLow, parallelsLow, fillsLow, signaledLow, array.size(linesLow) - 2)
    f_trim(linesLow, slopesLow, x1Low, y1Low, brokenLow, parallelsLow, fillsLow, signaledLow, maxTrendlines)

// ============================ PRICE: ON PIVOT HIGH (resistance) ============================
if enablePriceTrend and not na(pHighPriceTL)
    idx = bar_index - pRightBars
    y = pHighPriceTL
    var float pslope = 0.0
    tolCreate = y * priceTolPct / 100.0
    newL = line.new(idx, y, idx, y, color = priceHighLineColor, width = priceLineWidth, force_overlay = true)
    newPar = line.new(idx, y + tolCreate, idx, y + tolCreate, color = color.new(priceHighLineColor, 100), width = priceLineWidth, force_overlay = true)
    newFill = linefill.new(newL, newPar, priceHighFillColor)
    array.push(pLinesHigh, newL)
    array.push(pParallelsHigh, newPar)
    array.push(pFillsHigh, newFill)
    array.push(pSlopesHigh, 0.0)
    array.push(pX1High, idx)
    array.push(pY1High, y)
    array.push(pBrokenHigh, false)
    array.push(pSignaledHigh, false)
    if array.size(pLinesHigh) > 1
        last = array.get(pLinesHigh, array.size(pLinesHigh) - 2)
        lastPar = array.get(pParallelsHigh, array.size(pParallelsHigh) - 2)
        x1 = array.get(pX1High, array.size(pX1High) - 2)
        y1 = array.get(pY1High, array.size(pY1High) - 2)
        x2_pivot = idx
        y2_pivot = y
        x2_ext = x2_pivot + pExtendBars
        dx = x2_pivot - x1
        pslope := dx != 0 ? (y2_pivot - y1) / float(dx) : 0.0
        y2_ext = y1 + pslope * float(x2_ext - x1)
        tol2 = y2_ext * priceTolPct / 100.0
        line.set_x2(last, x2_ext)
        line.set_y2(last, y2_ext)
        line.set_x2(lastPar, x2_ext)
        line.set_y2(lastPar, y2_ext + tol2)
        array.set(pSlopesHigh, array.size(pSlopesHigh) - 2, pslope)
        if pslope > 0
            f_remove(pLinesHigh, pSlopesHigh, pX1High, pY1High, pBrokenHigh, pParallelsHigh, pFillsHigh, pSignaledHigh, array.size(pLinesHigh) - 2)
    f_trim(pLinesHigh, pSlopesHigh, pX1High, pY1High, pBrokenHigh, pParallelsHigh, pFillsHigh, pSignaledHigh, maxTrendlines)

// ============================ PRICE: ON PIVOT LOW (support) ============================
if enablePriceTrend and not na(pLowPriceTL)
    idx = bar_index - pRightBars
    y = pLowPriceTL
    var float pslope = 0.0
    tolCreate = y * priceTolPct / 100.0
    newL = line.new(idx, y, idx, y, color = priceLowLineColor, width = priceLineWidth, force_overlay = true)
    newPar = line.new(idx, y - tolCreate, idx, y - tolCreate, color = color.new(priceLowLineColor, 100), width = priceLineWidth, force_overlay = true)
    newFill = linefill.new(newL, newPar, priceLowFillColor)
    array.push(pLinesLow, newL)
    array.push(pParallelsLow, newPar)
    array.push(pFillsLow, newFill)
    array.push(pSlopesLow, 0.0)
    array.push(pX1Low, idx)
    array.push(pY1Low, y)
    array.push(pBrokenLow, false)
    array.push(pSignaledLow, false)
    if array.size(pLinesLow) > 1
        last = array.get(pLinesLow, array.size(pLinesLow) - 2)
        lastPar = array.get(pParallelsLow, array.size(pParallelsLow) - 2)
        x1 = array.get(pX1Low, array.size(pX1Low) - 2)
        y1 = array.get(pY1Low, array.size(pY1Low) - 2)
        x2_pivot = idx
        y2_pivot = y
        x2_ext = x2_pivot + pExtendBars
        dx = x2_pivot - x1
        pslope := dx != 0 ? (y2_pivot - y1) / float(dx) : 0.0
        y2_ext = y1 + pslope * float(x2_ext - x1)
        tol2 = y2_ext * priceTolPct / 100.0
        line.set_x2(last, x2_ext)
        line.set_y2(last, y2_ext)
        line.set_x2(lastPar, x2_ext)
        line.set_y2(lastPar, y2_ext - tol2)
        array.set(pSlopesLow, array.size(pSlopesLow) - 2, pslope)
        if pslope < 0
            f_remove(pLinesLow, pSlopesLow, pX1Low, pY1Low, pBrokenLow, pParallelsLow, pFillsLow, pSignaledLow, array.size(pLinesLow) - 2)
    f_trim(pLinesLow, pSlopesLow, pX1Low, pY1Low, pBrokenLow, pParallelsLow, pFillsLow, pSignaledLow, maxTrendlines)

// ============================ CHECKING FOR BREAKS (RSI) ============================
bool anyCrossedDown = false
bool anyCrossedUp = false

nHigh = array.size(linesHigh)
if nHigh > 0
    for i = 0 to nHigh - 1 by 1
        [crossedDown, crossedUp, crossOccurred] = f_check_break(array.get(linesHigh, i), array.get(slopesHigh, i), array.get(x1High, i), array.get(y1High, i), brokenHigh, signaledHigh, i, true, fillsHigh)
        if crossOccurred and crossedUp
            anyCrossedUp := true
            anyCrossedUp

nLow = array.size(linesLow)
if nLow > 0
    for i = 0 to nLow - 1 by 1
        [crossedDown, crossedUp, crossOccurred] = f_check_break(array.get(linesLow, i), array.get(slopesLow, i), array.get(x1Low, i), array.get(y1Low, i), brokenLow, signaledLow, i, false, fillsLow)
        if crossOccurred and crossedDown
            anyCrossedDown := true
            anyCrossedDown

// ============================ CHECKING FOR BREAKS (PRICE) ============================
bool anyPriceCrossedUp = false
bool anyPriceCrossedDown = false
priceTolNow = close * priceTolPct / 100.0

if enablePriceTrend
    nPH = array.size(pLinesHigh)
    if nPH > 0
        for i = 0 to nPH - 1 by 1
            [cd, cu, co] = f_check_break_price(array.get(pLinesHigh, i), array.get(pSlopesHigh, i), array.get(pX1High, i), array.get(pY1High, i), pBrokenHigh, pSignaledHigh, i, true, pFillsHigh, priceTolNow)
            if co and cu
                anyPriceCrossedUp := true
                anyPriceCrossedUp
    nPL = array.size(pLinesLow)
    if nPL > 0
        for i = 0 to nPL - 1 by 1
            [cd, cu, co] = f_check_break_price(array.get(pLinesLow, i), array.get(pSlopesLow, i), array.get(pX1Low, i), array.get(pY1Low, i), pBrokenLow, pSignaledLow, i, false, pFillsLow, priceTolNow)
            if co and cd
                anyPriceCrossedDown := true
                anyPriceCrossedDown

// ============================ BREAK LABELS ON CHART ============================
if showBreakLabels and anyPriceCrossedUp
    label.new(bar_index, low, '▲', style = label.style_label_up, color = color.new(priceLowLineColor, 20), textcolor = textColor, size = size.small, yloc = yloc.belowbar, force_overlay = true)
if showBreakLabels and anyPriceCrossedDown
    label.new(bar_index, high, '▼', style = label.style_label_down, color = color.new(priceHighLineColor, 20), textcolor = textColor, size = size.small, yloc = yloc.abovebar, force_overlay = true)

// ============================ REGRESSION DIVERGENCE (ported from faytterro 'RSI Divergence') ============================
// Метод: МНК-регресія RSI та ціни за останні rdLen барів. Дивергенція = протилежні нахили
// (RSI вгору / ціна вниз = бичача; RSI вниз / ціна вгору = ведмежа) з фільтром величини руху.
bool regBull = false
bool regBear = false
if enableRegDiv
    float sxo = 0.0
    float sxx = 0.0
    float syR = 0.0
    float sxyR = 0.0
    float syP = 0.0
    float sxyP = 0.0
    float rdMo = 0.0
    float rdN = rdLen
    for i = 0 to rdLen - 1 by 1
        sxo := sxo + i / rdN
        sxx := sxx + i * i / rdN
        syR := syR + rsi[rdLen - 1 - i] / rdN
        sxyR := sxyR + i * rsi[rdLen - 1 - i] / rdN
        syP := syP + close[rdLen - 1 - i] / rdN
        sxyP := sxyP + i * close[rdLen - 1 - i] / rdN
        rdMo := rdMo + (high[rdLen - 1 - i] - low[rdLen - 1 - i]) / rdN
    float denom = sxo * sxo - sxx
    float ra = denom != 0 ? (sxo * syR - sxyR) / denom : 0.0
    float pa = denom != 0 ? (sxo * syP - sxyP) / denom : 0.0
    float rb = syR - ra * sxo
    float pb = syP - pa * sxo
    int idxB = math.min(24, rdLen - 1)
    // Базова умова: протилежні нахили регресій RSI та ціни
    bool cg0 = ra > 0 and pa < 0
    bool cr0 = ra < 0 and pa > 0
    // Фільтр величини: ціна змістилась більше за середній діапазон бару, RSI — більше за поріг
    regBull := cg0 and (-pa * idxB > rdMo) and (-ra * idxB < -rdThresh)
    regBear := cr0 and (-pa * idxB < -rdMo) and (-ra * idxB > rdThresh)
    // Один сигнал на вікно (без щільних повторів)
    for i = 0 to rdLen - 1 by 1
        regBull := regBull and not regBull[i + 1]
        regBear := regBear and not regBear[i + 1]
    // Малювання + мітки
    if regBull
        if rdDrawLines
            x1r = bar_index - rdLen + 1
            lnR = line.new(x1r, rb, bar_index, ra * (rdLen - 1) + rb, color = rdBullColor, width = 2)
            lnP = line.new(x1r, pb, bar_index, pa * (rdLen - 1) + pb, color = rdBullColor, width = 2, force_overlay = true)
            array.push(rdLines, lnR)
            array.push(rdLines, lnP)
            while array.size(rdLines) > rdMaxLines * 2
                line.delete(array.shift(rdLines))
        if rdShowLabels
            label.new(x = bar_index, y = low, text = 'Reg Bull\nDivergence', xloc = xloc.bar_index, yloc = yloc.belowbar, color = rdBullColor, style = label.style_label_up, textcolor = textColor, size = size.small, textalign = text.align_center, force_overlay = true)
    if regBear
        if rdDrawLines
            x1r = bar_index - rdLen + 1
            lnR = line.new(x1r, rb, bar_index, ra * (rdLen - 1) + rb, color = rdBearColor, width = 2)
            lnP = line.new(x1r, pb, bar_index, pa * (rdLen - 1) + pb, color = rdBearColor, width = 2, force_overlay = true)
            array.push(rdLines, lnR)
            array.push(rdLines, lnP)
            while array.size(rdLines) > rdMaxLines * 2
                line.delete(array.shift(rdLines))
        if rdShowLabels
            label.new(x = bar_index, y = high, text = 'Reg Bear\nDivergence', xloc = xloc.bar_index, yloc = yloc.abovebar, color = rdBearColor, style = label.style_label_down, textcolor = textColor, size = size.small, textalign = text.align_center, force_overlay = true)

// ============================ CROSSOVER SIGNALS (BACKGROUND, RSI pane) ============================
bgcolor(anyCrossedUp ? color.new(lowLineColor, signalTransparency) : na, title = 'Bullish Crossover Background')
bgcolor(anyCrossedDown ? color.new(highLineColor, signalTransparency) : na, title = 'Bearish Crossover Background')

// ============================ DIVERGENCE PLOTS ============================
plotBullDiv = plot(calculateDivergence and plFound ? rsi[divPivotLen] : na, offset = -divPivotLen, title = 'Bullish Divergence', linewidth = 2, color = bullCond ? bullDivColor : color.new(color.white, 100))
plotBearDiv = plot(calculateDivergence and phFound ? rsi[divPivotLen] : na, offset = -divPivotLen, title = 'Bearish Divergence', linewidth = 2, color = bearCond ? bearDivColor : color.new(color.white, 100))

// ============================ DIVERGENCE LABELS ============================
plotshape(bullCond ? rsi[divPivotLen] : na, offset = -divPivotLen, title = 'Bullish Divergence Label', text = ' Bull ', style = shape.labelup, location = location.absolute, color = color.new(bullDivColor, bandTransparency), textcolor = textColor, display = calculateDivergence ? display.all : display.none)
plotshape(bearCond ? rsi[divPivotLen] : na, offset = -divPivotLen, title = 'Bearish Divergence Label', text = ' Bear ', style = shape.labeldown, location = location.absolute, color = color.new(bearDivColor, bandTransparency), textcolor = textColor, display = calculateDivergence ? display.all : display.none)

// ============================ ALERTS ============================
alertcondition(bullCond, title = 'Bullish Divergence Detected', message = 'Bullish divergence detected on RSI pivot, a few bars back.')
alertcondition(bearCond, title = 'Bearish Divergence Detected', message = 'Bearish divergence detected on RSI pivot, a few bars back.')
alertcondition(anyCrossedUp, title = 'Upper RSI Trendline Crossover (Bullish)', message = 'RSI crossed above the upper trendline.')
alertcondition(anyCrossedDown, title = 'Lower RSI Trendline Crossover (Bearish)', message = 'RSI crossed below the lower trendline.')
alertcondition(anyPriceCrossedUp, title = 'Price Resistance Break (Bullish)', message = 'Ціна закрилась вище низхідної трендової опору (пробій вгору).')
alertcondition(anyPriceCrossedDown, title = 'Price Support Break (Bearish)', message = 'Ціна закрилась нижче висхідної трендової підтримки (пробій вниз).')
alertcondition(regBull, title = 'Regression Bullish Divergence', message = 'Регресійна бичача дивергенція: RSI вгору, ціна вниз.')
alertcondition(regBear, title = 'Regression Bearish Divergence', message = 'Регресійна ведмежа дивергенція: RSI вниз, ціна вгору.')

// ============================ PLOT RSI and SMA ============================
plot(rsi, color = rsiColor, title = 'RSI', linewidth = 2)
plot(rsiSMA, color = smaColor, title = 'RSI SMA', linewidth = 1)
hline(70, 'Overbought', color = color.gray)
hline(50, 'Midline', color = color.gray, linestyle = hline.style_dashed)
hline(30, 'Oversold', color = color.gray)
````
