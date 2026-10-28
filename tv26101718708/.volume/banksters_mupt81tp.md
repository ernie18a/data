# banksters

- url: https://www.tradingview.com/script/mupT81tP-banksters/
- type: indicator
- pine_id: PUB;461bab75e23b4653a3fb19ab4e9a9007
- version: 1.0

## Description

Overview & Synergistic Concept

Banksters Workspace is a multi-component trading framework designed to combine structural market levels, momentum divergence tracking, and dynamic trend filtering into a single, cohesive workspace. 

Instead of cluttering the chart with standalone scripts, this tool integrates three distinct non-redundant methodologies to help a trader identify institutional breakouts, overbought/oversold turning points, and the path of least resistance (the core trend).

1. Structural Levels (Breakouts & Retests): Automatically detects significant Swing Highs and Swing Lows using customizable pivot lookbacks. When price breaks these structural points with an impulse expansion (validated by a minimum candle body percentage), a temporary key level is generated. The script monitors this level for either a false breakout (invalidating the line) or a valid retest within a defined buffer zone.
2. Momentum Divergences (MFI & Stochastic): Utilizes the Money Flow Index (MFI) to measure volume-weighted price momentum. By comparing recent MFI peaks/troughs with actual price action across adaptive lookback periods, the script isolates hidden and regular divergences. To prevent premature entries, signals are filtered through a Stochastic Oscillator to ensure they occur strictly within overbought or oversold territories.
3. Dynamic Trend Filtering (EMA Ribbon): Implements a flexible Exponential Moving Average (EMA) matrix (defaulting to 9, 20, 50, 100, and 200 periods). 

How the Components Work Together

The system is built on a "Filter, Trigger, Structure" synergy:
* The Filter (EMA): The 200 EMA and 50 EMA act as the ultimate trend filters. Traders should prioritize bullish structural breakouts when price is trading above these moving averages and bearish breakouts when below.
* The Structure (Banksters Levels): Defines the exact execution zones. An impulse break through a level shows market intent, while a subsequent retest provides an optimal risk-to-reward entry point.
* The Trigger (MFI Divergence): When a price retests a key structural level, an accompanying MFI bullish or bearish divergence serves as the ultimate exhaustion trigger, confirming that institutional order flow is defending the level.

Interface Customization

To ensure a clean charts workflow, the user interface features master toggles to completely enable or disable individual modules. All styling properties (colors, line widths, and plot shapes) have been offloaded to the native TradingView "Style" tab for seamless visual customization.

---

Описание на русском языке / Russian Description

Banksters Workspace — это комплексный инструмент, объединяющий три независимые торговые методики для определения институциональных уровней, импульсных пробоев и зон истощения тренда.

## Source Code

````pine
//@version=6
indicator('banksters', overlay = true, max_lines_count = 500)

// =========================================================================
// --- ГЛАВНЫЕ ТУМБЛЕРЫ ВКЛЮЧЕНИЯ МОДУЛЕЙ ---
// =========================================================================
showBanksters = input.bool(true, title = 'Включить уровни banksters', group = '=== ВКЛЮЧЕНИЕ МОДУЛЕЙ ===')
showMfi       = input.bool(true, title = 'Включить сигналы MFI', group = '=== ВКЛЮЧЕНИЕ МОДУЛЕЙ ===')
showEmaGroup  = input.bool(true, title = 'Включить скользящие EMA', group = '=== ВКЛЮЧЕНИЕ МОДУЛЕЙ ===')

// =========================================================================
// --- НАСТРОЙКИ БЛОКА: BANKSTERS LEVELS ---
// =========================================================================
leftBars      = input.int(5, title = 'Left Bars (Pivot)', minval = 1, group = 'Настройки: Banksters Уровни')
rightBars     = input.int(5, title = 'Right Bars (Pivot)', minval = 1, group = 'Настройки: Banksters Уровни')
useFilterDist = input.bool(true, title = 'Фильтр дубликатов', group = 'Настройки: Banksters Уровни')
filterDistPct = input.float(0.15, title = 'Filter Distance %', minval = 0.0, group = 'Настройки: Banksters Уровни')
levelLifetime = input.int(100, title = 'Max Lifetime (Bars)', minval = 1, group = 'Настройки: Banksters Уровни')
bodyPercent   = input.float(50.0, title = 'Min Breakout Body %', minval = 0.0, maxval = 100.0, group = 'Настройки: Banksters Уровни')
confirmedBars = input.int(5, title = 'False Break Check (Bars)', minval = 1, maxval = 10, group = 'Настройки: Banksters Уровни')
pctLimit      = input.float(0.1, title = 'Retest Buffer Zone %', minval = 0.0, group = 'Настройки: Banksters Уровни')
retestDelay   = input.int(3, title = 'Min Bars to Retest', minval = 1, group = 'Настройки: Banksters Уровни')

// =========================================================================
// --- НАСТРОЙКИ БЛОКА: MFI DIVERGENCES ---
// =========================================================================
len      = input.int(13, minval = 1, title = 'MFI Length', group = 'Настройки: MFI Дивергенции')
ob       = input.int(75, title = 'Overbought (Перекупленность)', minval = 0, maxval = 100, group = 'Настройки: MFI Дивергенции')
os       = input.int(25, title = 'Oversold (Перепроданность)', minval = 0, maxval = 100, group = 'Настройки: MFI Дивергенции')
periodK  = input.int(14, title = 'Stoch period', group = 'Настройки: MFI Дивергенции')
smoothK  = input.int(3, title = 'Stoch smooth', group = 'Настройки: MFI Дивергенции')
piv      = input.bool(false, title = 'Скрыть пивоты MFI (Pivots)?', group = 'Настройки: MFI Дивергенции')

bars1m   = input.int(300, 'Lookback 1m', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars5m   = input.int(110, 'Lookback 5m', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars15m  = input.int(40, 'Lookback 15m', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars30m  = input.int(30, 'Lookback 30m', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars1h   = input.int(10, 'Lookback 1h', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars4h   = input.int(10, 'Lookback 4h', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars12h  = input.int(10, 'Lookback 12h', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars1d   = input.int(10, 'Lookback D', minval = 1, group = 'MFI: Lookback по Таймфреймам')
bars3d   = input.int(10, 'Lookback 3D', minval = 1, group = 'MFI: Lookback по Таймфреймам')
barsW    = input.int(10, 'Lookback W', minval = 1, group = 'MFI: Lookback по Таймфреймам')

// =========================================================================
// --- НАСТРОЙКИ БЛОКА: EMA LINES (Выбор периодов и тумблеры) ---
// =========================================================================
useEma1 = input.bool(true,  title = 'Вкл', inline = 'ema1', group = 'Настройки: Скользящие EMA')
emaLen1 = input.int(9,      title = 'EMA 1 Период', inline = 'ema1', group = 'Настройки: Скользящие EMA')

useEma2 = input.bool(true,  title = 'Вкл', inline = 'ema2', group = 'Настройки: Скользящие EMA')
emaLen2 = input.int(20,     title = 'EMA 2 Период', inline = 'ema2', group = 'Настройки: Скользящие EMA')

useEma3 = input.bool(true,  title = 'Вкл', inline = 'ema3', group = 'Настройки: Скользящие EMA')
emaLen3 = input.int(50,     title = 'EMA 3 Период', inline = 'ema3', group = 'Настройки: Скользящие EMA')

useEma4 = input.bool(false, title = 'Вкл', inline = 'ema4', group = 'Настройки: Скользящие EMA') // Базово отключена
emaLen4 = input.int(100,    title = 'EMA 4 Период', inline = 'ema4', group = 'Настройки: Скользящие EMA')

useEma5 = input.bool(true,  title = 'Вкл', inline = 'ema5', group = 'Настройки: Скользящие EMA')
emaLen5 = input.int(200,    title = 'EMA 5 Период', inline = 'ema5', group = 'Настройки: Скользящие EMA')


// =========================================================================
// ЛОГИКА БЛОКА №1: BANKSTERS LEVELS
// =========================================================================
var array<float> pendingLevels = array.new<float>()
var array<int> pendingIndexes = array.new<int>()
var array<line> activeLines = array.new<line>()
var array<float> activeLevels = array.new<float>()
var array<int> activeBreakIdx = array.new<int>()

pLow = ta.pivotlow(low, leftBars, rightBars)

if showBanksters and not na(pLow)
    canAdd = true
    if useFilterDist and array.size(pendingLevels) > 0
        for i = 0 to array.size(pendingLevels) - 1 by 1
            if math.abs(pLow - array.get(pendingLevels, i)) < pLow * (filterDistPct / 100)
                canAdd := false
                break
    if canAdd
        array.push(pendingLevels, pLow)
        array.push(pendingIndexes, bar_index - rightBars)

if array.size(pendingLevels) > 0
    for i = array.size(pendingLevels) - 1 to 0 by 1
        idx = array.get(pendingIndexes, i)
        if bar_index - idx > levelLifetime or not showBanksters
            array.remove(pendingLevels, i)
            array.remove(pendingIndexes, i)

isBearish = close < open
candleRange = high - low
bodyRange = open - close
isImpulse = candleRange > 0 and bodyRange / candleRange * 100 >= bodyPercent

if showBanksters and isBearish and isImpulse and array.size(pendingLevels) > 0
    for i = array.size(pendingLevels) - 1 to 0 by 1
        lvl = array.get(pendingLevels, i)
        idx = array.get(pendingIndexes, i)

        if close < lvl and close[1] >= lvl
            newLine = line.new(x1 = idx, y1 = lvl, x2 = bar_index, y2 = lvl, xloc = xloc.bar_index, color = color.red, width = 4)
            array.push(activeLines, newLine)
            array.push(activeLevels, lvl)
            array.push(activeBreakIdx, bar_index)
            array.remove(pendingLevels, i)
            array.remove(pendingIndexes, i)

if array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0 by 1
        ln = array.get(activeLines, i)
        level = array.get(activeLevels, i)
        breakBar = array.get(activeBreakIdx, i)

        if not showBanksters
            line.delete(ln)
            array.remove(activeLines, i)
            array.remove(activeLevels, i)
            array.remove(activeBreakIdx, i)
            continue

        line.set_x2(ln, bar_index)
        barsSinceBreak = bar_index - breakBar

        if barsSinceBreak <= confirmedBars
            if barsSinceBreak > 0 and (close > level or high >= level)
                line.delete(ln)
                array.remove(activeLines, i)
                array.remove(activeLevels, i)
                array.remove(activeBreakIdx, i)
                continue

        if bar_index > breakBar + retestDelay
            bufferValue = level * (pctLimit / 100)
            lowerBound = level - bufferValue
            isRetested = high >= lowerBound

            if isRetested
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(color.red, 60))
                line.set_width(ln, 2)
                array.remove(activeLines, i)
                array.remove(activeLevels, i)
                array.remove(activeBreakIdx, i)

// --- БЫЧЬЯ ЛОГИКА ---
var array<float> pendingHighLevels = array.new<float>()
var array<int> pendingHighIndexes = array.new<int>()
var array<line> activeHighLines = array.new<line>()
var array<float> activeHighLevels = array.new<float>()
var array<int> activeHighBreakIdx = array.new<int>()

pHigh = ta.pivothigh(high, leftBars, rightBars)

if showBanksters and not na(pHigh)
    canAddHigh = true
    if useFilterDist and array.size(pendingHighLevels) > 0
        for i = 0 to array.size(pendingHighLevels) - 1 by 1
            if math.abs(pHigh - array.get(pendingHighLevels, i)) < pHigh * (filterDistPct / 100)
                canAddHigh := false
                break
    if canAddHigh
        array.push(pendingHighLevels, pHigh)
        array.push(pendingHighIndexes, bar_index - rightBars)

if array.size(pendingHighLevels) > 0
    for i = array.size(pendingHighLevels) - 1 to 0 by 1
        idx = array.get(pendingHighIndexes, i)
        if bar_index - idx > levelLifetime or not showBanksters
            array.remove(pendingHighLevels, i)
            array.remove(pendingHighIndexes, i)

isBullish = close > open
candleRangeHigh = high - low
bodyRangeHigh = close - open
isImpulseHigh = candleRangeHigh > 0 and bodyRangeHigh / candleRangeHigh * 100 >= bodyPercent

if showBanksters and isBullish and isImpulseHigh and array.size(pendingHighLevels) > 0
    for i = array.size(pendingHighLevels) - 1 to 0 by 1
        lvl = array.get(pendingHighLevels, i)
        idx = array.get(pendingHighIndexes, i)

        if close > lvl and close[1] <= lvl
            newLine = line.new(x1 = idx, y1 = lvl, x2 = bar_index, y2 = lvl, xloc = xloc.bar_index, color = color.green, width = 4)
            array.push(activeHighLines, newLine)
            array.push(activeHighLevels, lvl)
            array.push(activeHighBreakIdx, bar_index)
            array.remove(pendingHighLevels, i)
            array.remove(pendingHighIndexes, i)

if array.size(activeHighLines) > 0
    for i = array.size(activeHighLines) - 1 to 0 by 1
        ln = array.get(activeHighLines, i)
        level = array.get(activeHighLevels, i)
        breakBar = array.get(activeHighBreakIdx, i)

        if not showBanksters
            line.delete(ln)
            array.remove(activeHighLines, i)
            array.remove(activeHighLevels, i)
            array.remove(activeHighBreakIdx, i)
            continue

        line.set_x2(ln, bar_index)
        barsSinceBreak = bar_index - breakBar

        if barsSinceBreak <= confirmedBars
            if barsSinceBreak > 0 and (close < level or low <= level)
                line.delete(ln)
                array.remove(activeHighLines, i)
                array.remove(activeHighLevels, i)
                array.remove(activeHighBreakIdx, i)
                continue

        if bar_index > breakBar + retestDelay
            bufferValue = level * (pctLimit / 100)
            upperBound = level + bufferValue
            isRetestedHigh = low <= upperBound

            if isRetestedHigh
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(color.green, 60))
                line.set_width(ln, 2)
                array.remove(activeHighLines, i)
                array.remove(activeHighLevels, i)
                array.remove(activeHighBreakIdx, i)


// =========================================================================
// ЛОГИКА БЛОКА №2: РАСЧЕТ MFI DIVERGENCES
// =========================================================================
src = hlc3
changeSrc = ta.change(src)

upperMFI = math.sum(volume * (changeSrc <= 0 ? 0 : src), len)
lowerMFI = math.sum(volume * (changeSrc >= 0 ? 0 : src), len)

mfiRSI = lowerMFI == 0 ? 100 : upperMFI == 0 ? 0 : 100 - 100 / (1 + upperMFI / lowerMFI)
stochValue = ta.sma(ta.stoch(close, high, low, periodK), smoothK)

int current_xbars = 10
if timeframe.isintraday
    if timeframe.multiplier == 1
        current_xbars := bars1m
    else if timeframe.multiplier == 5
        current_xbars := bars5m
    else if timeframe.multiplier == 15
        current_xbars := bars15m
    else if timeframe.multiplier == 30
        current_xbars := bars30m
    else
        current_xbars := bars1h
else if timeframe.isdaily
    if timeframe.multiplier == 3
        current_xbars := bars3d
    else
        current_xbars := bars1d
else if timeframe.isweekly
    current_xbars := barsW

hb = math.abs(ta.highestbars(mfiRSI, current_xbars))
lb = math.abs(ta.lowestbars(mfiRSI, current_xbars))

isOS = stochValue[1] < os or stochValue < os
isOB = stochValue[1] > ob or stochValue > ob

var float max_val = na
var float max_rsi = na
var float min_val = na
var float min_rsi = na

max_val := hb == 0 ? close : na(max_val[1]) ? close : max_val[1]
max_rsi := hb == 0 ? mfiRSI : na(max_rsi[1]) ? mfiRSI : max_rsi[1]
min_val := lb == 0 ? close : na(min_val[1]) ? close : min_val[1]
min_rsi := lb == 0 ? mfiRSI : na(min_rsi[1]) ? mfiRSI : min_rsi[1]

if close > max_val
    max_val := close
if mfiRSI > max_rsi
    max_rsi := mfiRSI
if close < min_val
    min_val := close
if mfiRSI < min_rsi
    min_rsi := mfiRSI

pivoth = max_rsi == max_rsi[2] and max_rsi[2] != max_rsi[3]
pivotl = min_rsi == min_rsi[2] and min_rsi[2] != min_rsi[3]

bool divbear = false
bool divbull = false

if max_val[1] > max_val[2] and max_rsi[1] > mfiRSI[1] and mfiRSI <= mfiRSI[1]
    divbear := true
if min_val[1] < min_val[2] and min_rsi[1] < mfiRSI[1] and mfiRSI >= mfiRSI[1]
    divbull := true

// Отрисовка сигналов дивергенций (Цвета и стили вынесены во вкладку Стиль)
plotshape(showMfi and divbear and isOB, title = 'Bear Div Trigger', location = location.abovebar, style = shape.triangledown, color = color.red, size = size.tiny)
plotshape(showMfi and divbull and isOS, title = 'Bull Div Trigger', location = location.belowbar, style = shape.triangleup, color = color.green, size = size.tiny)

plotshape(showMfi and (piv ? false : pivoth and isOB), title = 'Bear Pivot Trigger', location = location.abovebar, style = shape.triangledown, color = color.new(color.red, 50), size = size.tiny)
plotshape(showMfi and (piv ? false : pivotl and isOS), title = 'Bull Pivot Trigger', location = location.belowbar, style = shape.triangleup, color = color.new(color.green, 50), size = size.tiny)


// =========================================================================
// ЛОГИКА БЛОКА №3: ОТРИСОВКА EMA LINES
// =========================================================================
plot(showEmaGroup and useEma1 ? ta.ema(close, emaLen1) : na, title = "EMA 1 Line", color = #f5eb5d, linewidth = 2)
plot(showEmaGroup and useEma2 ? ta.ema(close, emaLen2) : na, title = "EMA 2 Line", color = #f5b771, linewidth = 2)
plot(showEmaGroup and useEma3 ? ta.ema(close, emaLen3) : na, title = "EMA 3 Line", color = #f57b4e, linewidth = 2)
plot(showEmaGroup and useEma4 ? ta.ema(close, emaLen4) : na, title = "EMA 4 Line", color = #f55151, linewidth = 2)
plot(showEmaGroup and useEma5 ? ta.ema(close, emaLen5) : na, title = "EMA 5 Line", color = #9c27b0, linewidth = 2)
````
