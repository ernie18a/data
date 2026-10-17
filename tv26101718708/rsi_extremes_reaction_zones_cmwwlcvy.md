# RSI Extremes Reaction Zones

- url: https://www.tradingview.com/script/cmWWlCvy/
- type: indicator
- pine_id: PUB;02ae2f53a762426aa7cd99388ff9dadc
- version: 1.0

## Description

# RSI Extremes Reaction Zones

RSI Extremes Reaction Zones is a price-level analysis tool designed to identify historically significant market areas based on extreme Relative Strength Index (RSI) readings.

Rather than using RSI solely as an oscillator below the chart, this indicator converts historical RSI extremes into actionable price levels directly on the chart. By doing so, traders can visualize where strong momentum expansions or momentum exhaustion events previously occurred and monitor how price interacts with those areas in the future.

The indicator automatically scans a user-defined historical range, ranks the strongest RSI highs and RSI lows, maps those values to their corresponding market prices, and transforms them into support and resistance zones.

In addition to identifying RSI-derived reaction areas, the script also measures how frequently price has interacted with each level and highlights the most actively tested zones.

---

## Why RSI Extremes Matter

RSI is commonly used to measure momentum strength and identify overbought or oversold conditions. However, many traders focus only on the current RSI reading and overlook the price levels where extreme RSI values originally occurred.

Historical RSI extremes often represent areas where:

• Strong buying pressure entered the market

• Strong selling pressure entered the market

• Trend acceleration occurred

• Momentum exhaustion appeared

• Important market reactions developed

When price revisits these areas in the future, market participants may once again react to those levels, creating potential support, resistance, rejection, or breakout opportunities.

This indicator is built around the idea that historical momentum extremes can leave behind meaningful market reference points long after the original RSI signal has disappeared.

---

## Features

• Detects the highest RSI readings within the selected lookback period

• Detects the lowest RSI readings within the selected lookback period

• Converts RSI extremes into chart-based support and resistance zones

• ATR-based dynamic zone sizing

• Highlights the two most frequently tested levels

• Displays historical touch information

• Shows time elapsed since each extreme occurred

• Automatic label collision management

• Built-in statistical dashboard

• Adjustable analysis range

• Fully customizable zone width and touch sensitivity

---

## How The Indicator Works

The script continuously calculates RSI values and stores the corresponding market prices.

Within the selected lookback window, the indicator identifies:

• The strongest RSI highs

• The strongest RSI lows

The prices associated with these RSI events are then ranked and displayed directly on the chart.

Instead of treating these prices as single horizontal lines, the indicator creates dynamic support and resistance zones around each level using the Average True Range (ATR).

This allows the zones to automatically adapt to the volatility characteristics of the current market.

Higher volatility markets produce wider zones, while lower volatility markets generate tighter zones.

The result is a more realistic representation of potential reaction areas compared to using fixed-price levels.

---

## Most Touched Levels

Not all RSI-based levels are equally important.

To help identify the strongest reaction areas, the script measures how often price has revisited each detected level.

A configurable ATR-based threshold is used to determine whether a historical price interaction qualifies as a valid touch.

The two levels with the highest number of interactions are highlighted separately as:

🏆 Most Touched #1

🥈 Most Touched #2

These levels often represent areas where buyers and sellers repeatedly agreed on value and therefore may attract future market attention.

---

## Dashboard Overview

The built-in dashboard provides a complete overview of the detected RSI-based levels.

### Highest RSI Section

Displays:

• Highest recorded RSI values

• Associated market prices

• Ranking order

• Number of bars since occurrence

These levels frequently act as potential resistance or reaction areas.

### Lowest RSI Section

Displays:

• Lowest recorded RSI values

• Associated market prices

• Ranking order

• Number of bars since occurrence

These levels frequently act as potential support or reaction areas.

### Most Touched Section

Displays:

• Most interacted price levels

• Number of touches

• Current price relationship

• Most recent interaction information

This helps identify areas that have repeatedly influenced market behavior.

---

## Understanding The Zones

The indicator uses color-coded zones to make interpretation easier.

### Upper Zones

Levels generated from historically high RSI readings are displayed as potential resistance regions.

These areas represent locations where strong bullish momentum previously existed.

Potential observations:

• Price rejection

• Trend slowdown

• Consolidation

• Breakout continuation

### Lower Zones

Levels generated from historically low RSI readings are displayed as potential support regions.

These areas represent locations where strong bearish momentum previously existed.

Potential observations:

• Bounce reactions

• Trend stabilization

• Reversal attempts

• Breakdown continuation

The indicator does not assume that a level will hold. Instead, it highlights historically significant areas where market reactions may deserve additional attention.

---

## How To Use

### Trend Following

Use the indicator to identify pullback zones during strong trends.

In uptrends:

• Monitor lower RSI zones for support reactions

• Look for bullish confirmations before entering

In downtrends:

• Monitor higher RSI zones for resistance reactions

• Look for bearish confirmations before entering

---

### Reversal Trading

Watch for price reaching historical RSI extreme zones after extended moves.

Potential confirmation signals may include:

• Rejection candles

• Momentum divergence

• Volume expansion

• Market structure shifts

The indicator should be used as a location tool rather than a standalone entry signal.

---

### Support & Resistance Analysis

Historical RSI-based levels often align with traditional support and resistance structures.

When multiple analytical methods point to the same area, the level may carry greater significance.

Examples include:

• Swing highs and lows

• Market structure levels

• Fibonacci retracements

• Trendlines

• Volume profile zones

---

### Confluence Analysis

The indicator becomes particularly useful when combined with other technical tools.

Look for overlap between RSI-derived zones and:

• Existing support and resistance

• Trendlines

• Moving averages

• Volume-based levels

• Higher timeframe structure

Areas where multiple analytical concepts align may offer stronger trading opportunities than any individual signal alone.

---

## Input Settings

### RSI Period

Controls the sensitivity of RSI calculations.

Lower values:

• More responsive

• More frequent extremes

• More short-term signals

Higher values:

• Smoother behavior

• Fewer extremes

• Greater emphasis on major momentum events

---

### Bar Count

Defines the historical range used for analysis.

Smaller values:

• Focus on recent market behavior

• Faster adaptation

Larger values:

• Include older market data

• Highlight longer-term reaction levels

---

### Zone Width

Controls the ATR multiplier used to create support and resistance zones.

Higher values:

• Wider zones

• More tolerance for volatility

Lower values:

• Tighter zones

• Greater precision

---

### Touch Threshold

Controls how close price must come to a level for an interaction to be counted as a touch.

Lower values:

• Stricter touch requirements

Higher values:

• More forgiving interaction detection

---

## Best Used For

• Support and resistance trading

• Swing trading

• Trend continuation analysis

• Market structure analysis

• Momentum studies

• Confluence-based trading

• Reaction zone identification

• Historical price level analysis

• Multi-factor technical analysis

---

## Originality

This indicator presents an alternative approach to RSI analysis by transforming historical momentum extremes into chart-based price structures.

The script combines:

• Historical RSI ranking

• Price-level mapping

• ATR-based zone construction

• Touch-frequency analysis

• Dynamic visualization

• Statistical reporting

into a single framework designed to help traders identify historically significant reaction areas directly on the chart.

---

## Disclaimer

This indicator is intended for educational and analytical purposes only.

Historical RSI extremes and past market reactions do not guarantee future results. All trading decisions should be based on independent analysis, proper risk management, and additional confirmation methods.

No indicator can predict future market behavior with certainty.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('RSI Extremes Reaction Zones', overlay = true, max_bars_back = 500)

// ─── PARAMETERS ───────────────────────────────────────────────────
rsiLength = input.int(14, 'RSI Period')
rsiSource = input.source(close, 'RSI Source')
barCount = input.int(500, 'Bar Count', minval = 50, maxval = 500)
tablePos = input.string('top_right', 'Table Position', options = ['top_right', 'top_left', 'bottom_right', 'bottom_left', 'middle_right', 'middle_left'])
zoneMult = input.float(0.5, 'Zone Width (ATR multiplier)', minval = 0.1, maxval = 2.0, step = 0.1)
touchThresh = input.float(0.3, 'Touch Threshold (ATR %)', minval = 0.1, maxval = 1.0, step = 0.05)
labelGapMult = input.float(1.5, 'Label Min Gap (ATR multiplier)', minval = 0.5, maxval = 5.0, step = 0.1, tooltip = 'Minimum vertical distance between labels. Increase if labels still overlap.')

// ─── RSI & ATR ────────────────────────────────────────────────────
rsiVal = ta.rsi(rsiSource, rsiLength)
atrVal = ta.atr(14)

// ─── ARRAYS ───────────────────────────────────────────────────────
var array<float> allRsi = array.new_float(0)
var array<float> allClose = array.new_float(0)
var array<int> allBarIndex = array.new_int(0)
var array<float> histClose = array.new_float(0)
var array<int> histBar = array.new_int(0)

// ─── LINE OBJECTS ─────────────────────────────────────────────────
var array<line> priceLines = array.new_line(0)
var array<label> lineLabels = array.new_label(0)
var array<linefill> zoneFills = array.new_linefill(0)
var array<line> zoneTopLines = array.new_line(0)
var array<line> zoneBotLines = array.new_line(0)

// ─── DRAW LEVEL FUNCTION (global scope) ───────────────────────────
drawLevel(lvl, isHigh, lastTouchBar) =>
    isBelow = close < lvl
    mainColor = isBelow ? color.new(color.red, 0) : color.new(color.green, 0)
    zoneColor = isHigh ? color.new(color.red, 88) : color.new(color.green, 88)
    lineStyle = isHigh ? line.style_dashed : line.style_dotted
    prefix = isHigh ? '🔺' : '🔻'
    barAgo = bar_index - lastTouchBar
    agoText = barAgo <= 0 ? 'this bar' : str.tostring(barAgo) + ' bars ago'
    [mainColor, zoneColor, lineStyle, prefix, agoText]

// ─── DATA COLLECTION ──────────────────────────────────────────────
if not na(rsiVal) and bar_index >= rsiLength
    array.push(histClose, close)
    array.push(histBar, bar_index)
    if bar_index >= last_bar_index - barCount + 1
        array.push(allRsi, rsiVal)
        array.push(allClose, close)
        array.push(allBarIndex, bar_index)

// ─── TOUCH COUNTER ────────────────────────────────────────────────
countTouches(level, threshold) =>
    int cnt = 0
    int lastB = -1
    int hSize = array.size(histClose)
    if hSize > 0
        for i = 0 to hSize - 1 by 1
            p = array.get(histClose, i)
            if math.abs(p - level) <= threshold
                cnt := cnt + 1
                lastB := array.get(histBar, i)
                lastB
    [cnt, lastB]

// ─── LABEL COLLISION AVOIDANCE ────────────────────────────────────
// Sorts an array of prices descending, then pushes apart any pair
// that is closer than minGap. Works top-down so upper labels push
// lower ones down (or vice-versa if needed).
avoidCollisions(array<float> prices, float minGap) =>
    sz = array.size(prices)
    // Bubble-sort descending
    for i = 0 to sz - 2 by 1
        for j = 0 to sz - 2 - i by 1
            if array.get(prices, j) < array.get(prices, j + 1)
                tmp = array.get(prices, j)
                array.set(prices, j, array.get(prices, j + 1))
                array.set(prices, j + 1, tmp)
    // Push apart from top to bottom
    for i = 1 to sz - 1 by 1
        above = array.get(prices, i - 1)
        cur = array.get(prices, i)
        if above - cur < minGap
            array.set(prices, i, above - minGap)

// ─── MAIN BLOCK ───────────────────────────────────────────────────
if barstate.islast
    n = array.size(allRsi)

    if n >= 2
        topN = math.min(5, n)
        atrNow = na(atrVal) ? close * 0.01 : atrVal
        touchTh = atrNow * touchThresh
        zoneW = atrNow * zoneMult
        minGap = atrNow * labelGapMult // minimum vertical gap between labels

        // ── Sort by RSI descending ──
        array<float> sortedRsi = array.copy(allRsi)
        array<float> sortedClose = array.copy(allClose)
        array<int> sortedBar = array.copy(allBarIndex)
        sz = array.size(sortedRsi)

        for i = 0 to sz - 2 by 1
            for j = 0 to sz - 2 - i by 1
                if array.get(sortedRsi, j) < array.get(sortedRsi, j + 1)
                    tR = array.get(sortedRsi, j)
                    array.set(sortedRsi, j, array.get(sortedRsi, j + 1))
                    array.set(sortedRsi, j + 1, tR)
                    tC = array.get(sortedClose, j)
                    array.set(sortedClose, j, array.get(sortedClose, j + 1))
                    array.set(sortedClose, j + 1, tC)
                    tB = array.get(sortedBar, j)
                    array.set(sortedBar, j, array.get(sortedBar, j + 1))
                    array.set(sortedBar, j + 1, tB)

        // ── Top 5 highest RSI → sort by price descending ──
        array<float> highRsi = array.new_float(0)
        array<float> highClose = array.new_float(0)
        array<int> highBar = array.new_int(0)
        for i = 0 to topN - 1 by 1
            array.push(highRsi, array.get(sortedRsi, i))
            array.push(highClose, array.get(sortedClose, i))
            array.push(highBar, array.get(sortedBar, i))

        for i = 0 to topN - 2 by 1
            for j = 0 to topN - 2 - i by 1
                if array.get(highClose, j) < array.get(highClose, j + 1)
                    tR = array.get(highRsi, j)
                    array.set(highRsi, j, array.get(highRsi, j + 1))
                    array.set(highRsi, j + 1, tR)
                    tC = array.get(highClose, j)
                    array.set(highClose, j, array.get(highClose, j + 1))
                    array.set(highClose, j + 1, tC)
                    tB = array.get(highBar, j)
                    array.set(highBar, j, array.get(highBar, j + 1))
                    array.set(highBar, j + 1, tB)

        // ── Top 5 lowest RSI → sort by price descending ──
        array<float> lowRsi = array.new_float(0)
        array<float> lowClose = array.new_float(0)
        array<int> lowBar = array.new_int(0)
        for i = 0 to topN - 1 by 1
            idx = sz - topN + i
            array.push(lowRsi, array.get(sortedRsi, idx))
            array.push(lowClose, array.get(sortedClose, idx))
            array.push(lowBar, array.get(sortedBar, idx))

        for i = 0 to topN - 2 by 1
            for j = 0 to topN - 2 - i by 1
                if array.get(lowClose, j) < array.get(lowClose, j + 1)
                    tR = array.get(lowRsi, j)
                    array.set(lowRsi, j, array.get(lowRsi, j + 1))
                    array.set(lowRsi, j + 1, tR)
                    tC = array.get(lowClose, j)
                    array.set(lowClose, j, array.get(lowClose, j + 1))
                    array.set(lowClose, j + 1, tC)
                    tB = array.get(lowBar, j)
                    array.set(lowBar, j, array.get(lowBar, j + 1))
                    array.set(lowBar, j + 1, tB)

        // ── Top 2 most-touched levels ──
        array<float> allLevels = array.new_float(0)
        array<int> allTouches = array.new_int(0)
        array<int> allLastBars = array.new_int(0)

        for i = 0 to topN - 1 by 1
            array.push(allLevels, array.get(highClose, i))
        for i = 0 to topN - 1 by 1
            array.push(allLevels, array.get(lowClose, i))

        lvlSz = array.size(allLevels)
        for i = 0 to lvlSz - 1 by 1
            lvl = array.get(allLevels, i)
            [cnt, lastB] = countTouches(lvl, touchTh)
            array.push(allTouches, cnt)
            array.push(allLastBars, lastB)

        for i = 0 to lvlSz - 2 by 1
            for j = 0 to lvlSz - 2 - i by 1
                if array.get(allTouches, j) < array.get(allTouches, j + 1)
                    tL = array.get(allLevels, j)
                    array.set(allLevels, j, array.get(allLevels, j + 1))
                    array.set(allLevels, j + 1, tL)
                    tT = array.get(allTouches, j)
                    array.set(allTouches, j, array.get(allTouches, j + 1))
                    array.set(allTouches, j + 1, tT)
                    tB = array.get(allLastBars, j)
                    array.set(allLastBars, j, array.get(allLastBars, j + 1))
                    array.set(allLastBars, j + 1, tB)

        touch1Level = array.get(allLevels, 0)
        touch1Count = array.get(allTouches, 0)
        touch1LastBar = array.get(allLastBars, 0)
        touch2Level = lvlSz >= 2 ? array.get(allLevels, 1) : na
        touch2Count = lvlSz >= 2 ? array.get(allTouches, 1) : 0
        touch2LastBar = lvlSz >= 2 ? array.get(allLastBars, 1) : -1

        // ── Clear old drawings ──
        if array.size(zoneFills) > 0
            for i = 0 to array.size(zoneFills) - 1 by 1
                linefill.delete(array.get(zoneFills, i))
        array.clear(zoneFills)
        if array.size(zoneTopLines) > 0
            for i = 0 to array.size(zoneTopLines) - 1 by 1
                line.delete(array.get(zoneTopLines, i))
        array.clear(zoneTopLines)
        if array.size(zoneBotLines) > 0
            for i = 0 to array.size(zoneBotLines) - 1 by 1
                line.delete(array.get(zoneBotLines, i))
        array.clear(zoneBotLines)
        if array.size(priceLines) > 0
            for i = 0 to array.size(priceLines) - 1 by 1
                line.delete(array.get(priceLines, i))
        array.clear(priceLines)
        if array.size(lineLabels) > 0
            for i = 0 to array.size(lineLabels) - 1 by 1
                label.delete(array.get(lineLabels, i))
        array.clear(lineLabels)

        startBar = bar_index - barCount
        endBar = bar_index + 20

// ══════════════════════════════════════════════════════
// COLLISION AVOIDANCE – build adjusted label Y positions
// Collect all real price levels → adjust → use adjusted Y for labels
// Lines stay at real price; only label anchor moves.
// ══════════════════════════════════════════════════════

        // Pool: 5 high + 5 low + touch1 + touch2 = up to 12 entries
        // We track: real price, adjusted label Y, type (0=high,1=low,2=touch1,3=touch2)
        array<float> poolReal = array.new_float(0)
        array<float> poolAdj = array.new_float(0)
        array<int> poolType = array.new_int(0) // 0=high 1=low 2=touch1 3=touch2
        array<int> poolIdx = array.new_int(0) // index within group

        for i = 0 to topN - 1 by 1
            array.push(poolReal, array.get(highClose, i))
            array.push(poolAdj, array.get(highClose, i))
            array.push(poolType, 0)
            array.push(poolIdx, i)
        for i = 0 to topN - 1 by 1
            array.push(poolReal, array.get(lowClose, i))
            array.push(poolAdj, array.get(lowClose, i))
            array.push(poolType, 1)
            array.push(poolIdx, i)
        if not na(touch1Level)
            array.push(poolReal, touch1Level)
            array.push(poolAdj, touch1Level)
            array.push(poolType, 2)
            array.push(poolIdx, 0)
        if not na(touch2Level)
            array.push(poolReal, touch2Level)
            array.push(poolAdj, touch2Level)
            array.push(poolType, 3)
            array.push(poolIdx, 0)

        // Sort pool by adjusted price descending (bubble sort on poolAdj, sync all arrays)
        pSz = array.size(poolAdj)
        for i = 0 to pSz - 2 by 1
            for j = 0 to pSz - 2 - i by 1
                if array.get(poolAdj, j) < array.get(poolAdj, j + 1)
                    // swap all four arrays
                    tmpA = array.get(poolAdj, j)
                    array.set(poolAdj, j, array.get(poolAdj, j + 1))
                    array.set(poolAdj, j + 1, tmpA)
                    tmpR = array.get(poolReal, j)
                    array.set(poolReal, j, array.get(poolReal, j + 1))
                    array.set(poolReal, j + 1, tmpR)
                    tmpT = array.get(poolType, j)
                    array.set(poolType, j, array.get(poolType, j + 1))
                    array.set(poolType, j + 1, tmpT)
                    tmpI = array.get(poolIdx, j)
                    array.set(poolIdx, j, array.get(poolIdx, j + 1))
                    array.set(poolIdx, j + 1, tmpI)



        // ── High RSI lines & labels ──
        for i = 0 to topN - 1 by 1
            lvl = array.get(highClose, i)
            lastB = array.get(highBar, i)
            [mColor, zColor, lStyle, pfx, agoTxt] = drawLevel(lvl, true, lastB)
            ln = line.new(startBar, lvl, endBar, lvl, extend = extend.none, color = mColor, style = lStyle, width = 2)
            array.push(priceLines, ln)
            topLn = line.new(startBar, lvl + zoneW, endBar, lvl + zoneW, color = color.new(mColor, 80), style = line.style_dotted, width = 1)
            botLn = line.new(startBar, lvl - zoneW, endBar, lvl - zoneW, color = color.new(mColor, 80), style = line.style_dotted, width = 1)
            array.push(zoneTopLines, topLn)
            array.push(zoneBotLines, botLn)
            array.push(zoneFills, linefill.new(topLn, botLn, color = zColor))
            labelY = lvl

            for k = 0 to array.size(poolType) - 1 by 1
                if array.get(poolType, k) == 0 and array.get(poolIdx, k) == i
                    labelY := array.get(poolAdj, k)
                    break

            array.push(lineLabels, label.new(endBar, labelY, pfx + ' ' + str.tostring(lvl, '#.##') + ' ⏱ ' + agoTxt, color = color.new(#7b0000, 70), textcolor = color.new(#ffcccc, 0), style = label.style_label_left, size = size.small))

        // ── Low RSI lines & labels ──
        for i = 0 to topN - 1 by 1
            lvl = array.get(lowClose, i)
            lastB = array.get(lowBar, i)
            [mColor, zColor, lStyle, pfx, agoTxt] = drawLevel(lvl, false, lastB)
            ln = line.new(startBar, lvl, endBar, lvl, extend = extend.none, color = mColor, style = lStyle, width = 2)
            array.push(priceLines, ln)
            topLn = line.new(startBar, lvl + zoneW, endBar, lvl + zoneW, color = color.new(mColor, 80), style = line.style_dotted, width = 1)
            botLn = line.new(startBar, lvl - zoneW, endBar, lvl - zoneW, color = color.new(mColor, 80), style = line.style_dotted, width = 1)
            array.push(zoneTopLines, topLn)
            array.push(zoneBotLines, botLn)
            array.push(zoneFills, linefill.new(topLn, botLn, color = zColor))
            //labelY = getLabelY(1, i)
            //array.push(lineLabels, label.new(endBar, labelY,
            labelY = lvl

            for k = 0 to array.size(poolType) - 1 by 1
                if array.get(poolType, k) == 1 and array.get(poolIdx, k) == i
                    labelY := array.get(poolAdj, k)
                    break

            array.push(lineLabels, label.new(endBar, labelY, pfx + ' ' + str.tostring(lvl, '#.##') + ' ⏱ ' + agoTxt, color = color.new(#003d1a, 70), textcolor = color.new(#ccffdd, 0), style = label.style_label_left, size = size.small))

        // ── Most touched #1 ──
        if not na(touch1Level)
            t1Color = close < touch1Level ? color.new(#ff9900, 0) : color.new(#00ccff, 0)
            t1TopLn = line.new(startBar, touch1Level + zoneW, endBar, touch1Level + zoneW, color = color.new(t1Color, 80), style = line.style_dotted, width = 1)
            t1BotLn = line.new(startBar, touch1Level - zoneW, endBar, touch1Level - zoneW, color = color.new(t1Color, 80), style = line.style_dotted, width = 1)
            array.push(zoneTopLines, t1TopLn)
            array.push(zoneBotLines, t1BotLn)
            array.push(zoneFills, linefill.new(t1TopLn, t1BotLn, color = color.new(t1Color, 85)))
            t1Ln = line.new(startBar, touch1Level, endBar, touch1Level, color = t1Color, style = line.style_solid, width = 2)
            array.push(priceLines, t1Ln)
            t1BarAgo = bar_index - touch1LastBar
            t1AgoText = t1BarAgo <= 0 ? 'this bar' : str.tostring(t1BarAgo) + ' bars ago'
            //t1LabelY  = getLabelY(2, 0)
            t1LabelY = touch1Level

            for k = 0 to array.size(poolType) - 1 by 1
                if array.get(poolType, k) == 2 and array.get(poolIdx, k) == 0
                    t1LabelY := array.get(poolAdj, k)
                    break
            array.push(lineLabels, label.new(endBar + 50, t1LabelY, '🏆 #1 Touches: ' + '\n' + str.tostring(touch1Level, '#.##'), color = color.new(#333300, 70), textcolor = color.new(#ffee00, 0), style = label.style_label_left, size = size.small))

        // ── Most touched #2 ──
        if not na(touch2Level)
            t2Color = close < touch2Level ? color.new(#ff9900, 30) : color.new(#00ccff, 30)
            t2TopLn = line.new(startBar, touch2Level + zoneW, endBar, touch2Level + zoneW, color = color.new(t2Color, 80), style = line.style_dotted, width = 1)
            t2BotLn = line.new(startBar, touch2Level - zoneW, endBar, touch2Level - zoneW, color = color.new(t2Color, 80), style = line.style_dotted, width = 1)
            array.push(zoneTopLines, t2TopLn)
            array.push(zoneBotLines, t2BotLn)
            array.push(zoneFills, linefill.new(t2TopLn, t2BotLn, color = color.new(t2Color, 88)))
            t2Ln = line.new(startBar, touch2Level, endBar, touch2Level, color = t2Color, style = line.style_solid, width = 2)
            array.push(priceLines, t2Ln)
            t2BarAgo = bar_index - touch2LastBar
            t2AgoText = t2BarAgo <= 0 ? 'this bar' : str.tostring(t2BarAgo) + ' bars ago'
            //t2LabelY  = getLabelY(3, 0)
            t2LabelY = touch2Level

            for k = 0 to array.size(poolType) - 1 by 1
                if array.get(poolType, k) == 3 and array.get(poolIdx, k) == 0
                    t2LabelY := array.get(poolAdj, k)
                    break
            array.push(lineLabels, label.new(endBar + 80, t2LabelY, '🥈 #2 Touches: ' + '\n' + str.tostring(touch2Level, '#.##'), color = color.new(#333300, 70), textcolor = color.new(#ffee00, 0), style = label.style_label_left, size = size.small))

        // ════════════════════════════════════════════
        // TABLE
        // ════════════════════════════════════════════
        totalRows = topN * 2 + 7

        tPos = tablePos == 'top_right' ? position.top_right : tablePos == 'top_left' ? position.top_left : tablePos == 'bottom_right' ? position.bottom_right : tablePos == 'bottom_left' ? position.bottom_left : tablePos == 'middle_right' ? position.middle_right : position.middle_left

        tbl = table.new(tPos, 4, totalRows, border_width = 1, border_color = color.new(color.gray, 60), frame_color = color.new(color.gray, 40), frame_width = 2)

        fSz = size.small
        tinySz = size.tiny
        subTxt = color.new(color.silver, 0)

        // ── High Header (0) ──
        highBg = color.new(#7b0000, 0)
        table.cell(tbl, 0, 0, '🔺 HIGHEST RSI', text_color = color.white, bgcolor = highBg, text_size = fSz)
        table.cell(tbl, 1, 0, 'RSI', text_color = color.white, bgcolor = highBg, text_size = fSz)
        table.cell(tbl, 2, 0, 'Price ↓', text_color = color.white, bgcolor = highBg, text_size = fSz)
        table.cell(tbl, 3, 0, 'Last Touch', text_color = color.white, bgcolor = highBg, text_size = fSz)

        subHighBg = color.new(#4a0000, 0)
        table.cell(tbl, 0, 1, 'Rank', text_color = subTxt, bgcolor = subHighBg, text_size = tinySz)
        table.cell(tbl, 1, 1, 'RSI(' + str.tostring(rsiLength) + ')', text_color = subTxt, bgcolor = subHighBg, text_size = tinySz)
        table.cell(tbl, 2, 1, 'Last ' + str.tostring(barCount) + ' Bars', text_color = subTxt, bgcolor = subHighBg, text_size = tinySz)
        table.cell(tbl, 3, 1, 'Bars Ago', text_color = subTxt, bgcolor = subHighBg, text_size = tinySz)

        for i = 0 to topN - 1 by 1
            row = 2 + i
            rsiV = array.get(highRsi, i)
            closeV = array.get(highClose, i)
            bIdx = array.get(highBar, i)
            barAgo = bar_index - bIdx
            isBelow = close < closeV
            priceColor = isBelow ? color.new(color.red, 0) : color.new(color.green, 0)
            medal = i == 0 ? '🥇 1.' : i == 1 ? '🥈 2.' : i == 2 ? '🥉 3.' : '   ' + str.tostring(i + 1) + '.'
            rowBg = i % 2 == 0 ? color.new(#3d0000, 85) : color.new(#3d0000, 90)
            table.cell(tbl, 0, row, medal, text_color = color.white, bgcolor = rowBg, text_size = fSz)
            table.cell(tbl, 1, row, str.tostring(rsiV, '#.##'), text_color = color.new(#ffaaaa, 0), bgcolor = rowBg, text_size = fSz)
            table.cell(tbl, 2, row, str.tostring(closeV, '#.##'), text_color = priceColor, bgcolor = rowBg, text_size = fSz)
            table.cell(tbl, 3, row, str.tostring(barAgo) + ' bars', text_color = color.new(color.orange, 0), bgcolor = rowBg, text_size = tinySz)

        // ── Separator ──
        sepRow = topN + 2
        sepBg = color.new(#222244, 0)
        table.cell(tbl, 0, sepRow, '━━━━', text_color = subTxt, bgcolor = sepBg, text_size = tinySz)
        table.cell(tbl, 1, sepRow, 'RSI(' + str.tostring(rsiLength) + ')  •  ' + str.tostring(barCount) + ' Bars', text_color = color.white, bgcolor = sepBg, text_size = tinySz)
        table.cell(tbl, 2, sepRow, '━━━━', text_color = subTxt, bgcolor = sepBg, text_size = tinySz)
        table.cell(tbl, 3, sepRow, '━━━━', text_color = subTxt, bgcolor = sepBg, text_size = tinySz)

        // ── Low Header ──
        lowHeaderRow = topN + 3
        lowBg = color.new(#003d1a, 0)
        table.cell(tbl, 0, lowHeaderRow, '🔻 LOWEST RSI', text_color = color.white, bgcolor = lowBg, text_size = fSz)
        table.cell(tbl, 1, lowHeaderRow, 'RSI', text_color = color.white, bgcolor = lowBg, text_size = fSz)
        table.cell(tbl, 2, lowHeaderRow, 'Price ↓', text_color = color.white, bgcolor = lowBg, text_size = fSz)
        table.cell(tbl, 3, lowHeaderRow, 'Last Touch', text_color = color.white, bgcolor = lowBg, text_size = fSz)

        subLowRow = topN + 4
        subLowBg = color.new(#002211, 0)
        table.cell(tbl, 0, subLowRow, 'Rank', text_color = subTxt, bgcolor = subLowBg, text_size = tinySz)
        table.cell(tbl, 1, subLowRow, 'RSI(' + str.tostring(rsiLength) + ')', text_color = subTxt, bgcolor = subLowBg, text_size = tinySz)
        table.cell(tbl, 2, subLowRow, 'Last ' + str.tostring(barCount) + ' Bars', text_color = subTxt, bgcolor = subLowBg, text_size = tinySz)
        table.cell(tbl, 3, subLowRow, 'Bars Ago', text_color = subTxt, bgcolor = subLowBg, text_size = tinySz)

        for i = 0 to topN - 1 by 1
            row = topN + 5 + i
            rsiV = array.get(lowRsi, i)
            closeV = array.get(lowClose, i)
            bIdx = array.get(lowBar, i)
            barAgo = bar_index - bIdx
            isBelow = close < closeV
            priceColor = isBelow ? color.new(color.red, 0) : color.new(color.green, 0)
            medal = i == 0 ? '🥇 1.' : i == 1 ? '🥈 2.' : i == 2 ? '🥉 3.' : '   ' + str.tostring(i + 1) + '.'
            rowBg = i % 2 == 0 ? color.new(#003d1a, 85) : color.new(#003d1a, 90)
            table.cell(tbl, 0, row, medal, text_color = color.white, bgcolor = rowBg, text_size = fSz)
            table.cell(tbl, 1, row, str.tostring(rsiV, '#.##'), text_color = color.new(#aaffcc, 0), bgcolor = rowBg, text_size = fSz)
            table.cell(tbl, 2, row, str.tostring(closeV, '#.##'), text_color = priceColor, bgcolor = rowBg, text_size = fSz)
            table.cell(tbl, 3, row, str.tostring(barAgo) + ' bars', text_color = color.new(color.orange, 0), bgcolor = rowBg, text_size = tinySz)

        // ── Most Touched Section ──
        touchHeaderRow = topN * 2 + 5
        touchBg = color.new(#2a2a00, 0)
        table.cell(tbl, 0, touchHeaderRow, '🏆 MOST TOUCHED', text_color = color.new(#ffee00, 0), bgcolor = touchBg, text_size = fSz)
        table.cell(tbl, 1, touchHeaderRow, 'Touches', text_color = color.new(#ffee00, 0), bgcolor = touchBg, text_size = fSz)
        table.cell(tbl, 2, touchHeaderRow, 'Price', text_color = color.new(#ffee00, 0), bgcolor = touchBg, text_size = fSz)
        table.cell(tbl, 3, touchHeaderRow, 'Last Touch', text_color = color.new(#ffee00, 0), bgcolor = touchBg, text_size = fSz)

        // #1
        t1Row = topN * 2 + 6
        t1BarAgo = bar_index - touch1LastBar
        t1AgoTxt = t1BarAgo <= 0 ? 'this bar' : str.tostring(t1BarAgo) + ' bars ago'
        t1PColor = close < touch1Level ? color.new(color.red, 0) : color.new(color.green, 0)
        t1RowBg = color.new(#1a1a00, 85)
        table.cell(tbl, 0, t1Row, '🥇 #1', text_color = color.new(#ffee00, 0), bgcolor = t1RowBg, text_size = fSz)
        table.cell(tbl, 1, t1Row, str.tostring(touch1Count) + 'x', text_color = color.new(#ffee00, 0), bgcolor = t1RowBg, text_size = fSz)
        table.cell(tbl, 2, t1Row, str.tostring(touch1Level, '#.##'), text_color = t1PColor, bgcolor = t1RowBg, text_size = fSz)
        table.cell(tbl, 3, t1Row, t1AgoTxt, text_color = color.new(color.orange, 0), bgcolor = t1RowBg, text_size = tinySz)
````
