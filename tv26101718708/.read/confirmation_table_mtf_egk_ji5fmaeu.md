#  Confirmation Table (MTF) - [EGK]

- url: https://www.tradingview.com/script/jI5FmAeu-Confirmation-Table-MTF-EGK/
- type: indicator
- pine_id: PUB;e12be18b0475496cae880978cd284e83
- version: 3.0

## Description

# Confirmation Table (MTF)

The **AI Confirmation Table (MTF)** is an all-in-one multi-timeframe dashboard designed to evaluate market conditions using a quantitative scoring matrix. It aggregates underlying trend direction, volume validation, structural breakouts, and momentum triggers across customizable timeframes into a real-time HUD (Heads-Up Display) overlay.

---

## 🔑 Key Features

- **Multi-Timeframe Engine (MTF):** Track higher timeframe trend dynamics while confirming lower timeframe execution entries simultaneously.
- **Dual-Layer Scoring System:** Separates macro direction (**Trend Score**) from precise execution signals (**Entry Score**).
- **Structure & Volatility Integration:** Built-in Order Block tracking and ATR volatility filters prevent false breakouts during low-liquidity phases.
- **Customizable Interface:** Choose between a fully detailed diagnostic table or a streamlined compact summary view.
- **Dynamic Chart Bar Coloring:** Optional overlay coloring matching the net bias of the mathematical score.

---

## 📊 How It Works & Calculation Logic

The script partitions indicators into two distinct modules to minimize market noise:

### 1. Trend Direction Module
Determines the macroeconomic structural bias:
- **EMA (12/26):** Bullish if Exponential Moving Average 12 is above 26; Bearish if below.
- **MACD (12/26/9):** Bullish if the MACD line is above the Signal Line and greater than 0; Bearish if below signal and below 0.
- **ADX (14):** Confirms trend strength. Active only if ADX > 20 and directional DI (+DI vs -DI) aligns.
- **SuperTrend (3, 10):** Evaluates overall directional bias and trajectory.

### 2. Momentum & Entry Module
Evaluates execution probability and localized market flow:
- **RSI (14):** Bullish above 50 level; Bearish below 50.
- **OBV (On-Balance Volume):** Bullish when OBV is above its 20-period SMA and rising; Bearish when below and falling.
- **Volume Oscillator:** Validates volume expansion when short-term volume exceeds its 20-period moving average.
- **Order Block (Structure):** Tracks pivot highs/lows (3,3) to identify dynamic support/resistance breaks.
- **ATR Volatility Filter:** Flags active volatility phases ([symbol="NYSE:ATR"]NYSE:ATR[/symbol] > SMA(ATR, 50)$) to ensure trade viability.

---

## ⚙️ Settings Guide

### 📊 Table Display Settings
- **Display Confirmation Table:** Toggle dashboard visibility on/off.
- **Compact Mode (Summary Only):** Hides individual module rows and displays only the aggregated numeric scores for a clean chart view.
- **Table Position & Size:** Customize table alignment and scale on your screen.

### ⏱️ Timeframe Settings (MTF)
- **Trend Timeframe:** Define the higher timeframe for structural trend evaluation (e.g., 4H, Daily). Leave blank to match current chart timeframe.
- **Entry Timeframe:** Define the timeframe for entry execution triggers (e.g., 5m, 15m). Leave blank to match current chart timeframe.

### 📊 Active Confirmation Modules
- Toggle individual modules on/off. Disabled indicators are automatically excluded from total score recalculations.

### 🎨 Dynamic Bar Coloring
- Paints chart candles dynamically based on dominant score bias (Green for Net Bullish, Red for Net Bearish, Gray for Neutral).

---

## 💡 How to Trade with This Tool

1. **Establish Trend Alignment:** Ensure **Trend Score** exhibits maximum confluence (e.g., 4/4 or 3/4 Bullish).
2. **Wait for Entry Confluence:** Look for **Entry Score** to align with the higher timeframe trend direction.
3. **Volatility Confirmation:** Verify that the **Volatility (ATR)** indicator displays **⚡ High Volatility**, confirming sufficient liquidity for price expansion.

---

*Disclaimer: This script is intended purely for informational and educational purposes. It does not constitute financial or investment advice.*

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// © AI Confirmation Table (MTF) & EGK.
// Chart layout updated
//@version=6
indicator('AI Confirmation Table (MTF)', shorttitle = 'AI Table MTF', overlay = true, max_labels_count = 500, max_lines_count = 500)

// ============================================================================
// INPUT GROUPS & CONFIGURATION
// ============================================================================

// --- Table Settings ---
group_table      = '📊 Table Display Settings'
showConfTable   = input.bool(true, 'Display Confirmation Table', group = group_table, tooltip = 'Toggle table visibility on chart.')
SumConfTable    = input.bool(false, 'Compact Mode (Summary Only)', group = group_table, tooltip = 'Shows only total score counts instead of detailed indicators.')
ConftablePos    = input.string('top_right', 'Table Position', options = ['top_left', 'top_center', 'top_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = group_table)
ConftableSize   = input.string('small', 'Table Size', options = ['small', 'normal', 'large'], group = group_table)

// --- MTF Settings ---
group_mtf       = '⏱️ Timeframe Settings (MTF)'
trendTF         = input.timeframe('', 'Trend Timeframe', group = group_mtf, tooltip = 'Leave blank to use current chart timeframe.')
entryTF         = input.timeframe('', 'Entry Timeframe', group = group_mtf, tooltip = 'Leave blank to use current chart timeframe.')

// --- Style & Border Settings ---
group_border    = '🔲 Table Aesthetics'
showBorder      = input.bool(true, 'Show Table Borders', group = group_border)
borderColor     = input.color(color.rgb(150, 150, 150), 'Border Color', group = group_border)
borderWidth     = input.int(1, 'Border Thickness', minval = 1, maxval = 5, group = group_border)

// --- Indicator Toggles ---
group_confirm   = '📊 Active Confirmation Modules'
useEMA          = input.bool(true, 'EMA (12/26)', group = group_confirm)
useMACD         = input.bool(true, 'MACD (12/26/9)', group = group_confirm)
useADX          = input.bool(true, 'ADX (14, Threshold: 20)', group = group_confirm)
useSuper        = input.bool(true, 'SuperTrend (3, 10)', group = group_confirm)
useRSI          = input.bool(true, 'RSI (14)', group = group_confirm)
useOBV          = input.bool(true, 'OBV & SMA 20', group = group_confirm)
useVolume       = input.bool(true, 'Volume Oscillator', group = group_confirm)
useATR          = input.bool(true, 'ATR Volatility Filter', group = group_confirm)
useOB           = input.bool(true, 'Order Block Structure', group = group_confirm)

// --- EMA Inputs & Plot Settings ---
group_ema       = '📈 EMA Settings'
fastEMALen      = input.int(12, 'Fast EMA Length', group = group_ema)
slowEMALen      = input.int(26, 'Slow EMA Length', group = group_ema)
longEMALen      = input.int(200, '200 EMA Length', group = group_ema)
showFastEMA     = input.bool(true, 'Show Fast EMA', group = group_ema)
showSlowEMA     = input.bool(true, 'Show Slow EMA', group = group_ema)
showLongEMA     = input.bool(true, 'Show 200 EMA', group = group_ema)
fastEMAColor    = input.color(color.rgb(72, 212, 6), 'Fast EMA Color', group = group_ema)
slowEMAColor    = input.color(color.rgb(238, 255, 0), 'Slow EMA Color', group = group_ema)
longEMAColor    = input.color(color.rgb(250, 250, 250), 'Long EMA Color', group = group_ema)
fastEMAWidth    = input.int(1, 'Fast EMA Width', minval=1, maxval=5, group = group_ema)
slowEMAWidth    = input.int(2, 'Slow EMA Width', minval=1, maxval=5, group = group_ema)
longEMAWidth    = input.int(3, '200 EMA Width', minval=1, maxval=5, group = group_ema)
emaStyle        = input.string('Line', 'EMA Style', options=['Line', 'Stepline'], group = group_ema)

// --- Bar Coloring Options ---
group_bar       = '🎨 Dynamic Bar Coloring'
useBarColor     = input.bool(false, 'Enable Bar Coloring', group = group_bar, tooltip = 'Colors chart bars based on dominant Trend Score bias.')
barLongColor    = input.color(color.rgb(5, 248, 46), 'Bullish Bar Color', group = group_bar)
barShortColor   = input.color(color.rgb(250, 10, 10), 'Bearish Bar Color', group = group_bar)
barNeutralColor = input.color(color.gray, 'Neutral Bar Color', group = group_bar)
barTransp       = input.int(25, 'Transparency', minval = 0, maxval = 100, group = group_bar)

// Position & Size Mapping
pos = switch ConftablePos
    'top_left'      => position.top_left
    'top_center'    => position.top_center
    'top_right'     => position.top_right
    'bottom_left'   => position.bottom_left
    'bottom_center' => position.bottom_center
    => position.bottom_right

ts = switch ConftableSize
    'small'  => size.small
    'large'  => size.large
    => size.normal

// Timeframe Format Helper Function with "TF:" prefix
f_format_tf(string tf) =>
    string formatted = ""
    if tf == ''
        formatted := "Chart"
    else
        string raw_tf = tf
        if raw_tf == timeframe.period
            formatted := "Chart"
        else
            if str.endswith(raw_tf, "D") or str.endswith(raw_tf, "W") or str.endswith(raw_tf, "M") or str.endswith(raw_tf, "H") or str.endswith(raw_tf, "S") or str.endswith(raw_tf, "m")
                formatted := raw_tf
            else
                float val = str.tonumber(raw_tf)
                if not na(val)
                    int int_val = int(val)
                    if int_val >= 525600
                        formatted := str.tostring(int_val / 525600) + "Y"
                    else if int_val >= 43200
                        formatted := str.tostring(int_val / 43200) + "M"
                    else if int_val >= 1440
                        formatted := str.tostring(int_val / 1440) + "D"
                    else if int_val >= 60
                        formatted := str.tostring(int_val / 60) + "H"
                    else
                        formatted := raw_tf + "m"
                else
                    formatted := raw_tf
    formatted == "Chart" ? "Chart" : "TF:" + formatted

tTF = f_format_tf(trendTF)
eTF = f_format_tf(entryTF)

// ============================================================================
// 8. TREND EMAS PLOTTING ENGINE
// ============================================================================

fastEMAVal = ta.ema(close, fastEMALen)
slowEMAVal = ta.ema(close, slowEMALen)
longEMAVal = ta.ema(close, longEMALen)

emaPlotStyle = emaStyle == 'Stepline' ? plot.style_stepline : plot.style_line

plot(showFastEMA ? fastEMAVal : na, title="Fast EMA", color=fastEMAColor, linewidth=fastEMAWidth, style=emaPlotStyle)
plot(showSlowEMA ? slowEMAVal : na, title="Slow EMA", color=slowEMAColor, linewidth=slowEMAWidth, style=emaPlotStyle)
plot(showLongEMA ? longEMAVal : na, title="Long EMA", color=longEMAColor, linewidth=longEMAWidth, style=emaPlotStyle)


// ============================================================================
// 9. CONFIRMATION TABLE SYSTEM (MTF)
// ============================================================================

f_trend_calc() =>
    emaFast = ta.ema(close, fastEMALen)
    emaSlow = ta.ema(close, slowEMALen)
    _emaLong = emaFast > emaSlow
    _emaShort = emaFast < emaSlow
    macdLine = emaFast - emaSlow
    macdSignal = ta.ema(macdLine, 9)
    _macdLong = macdLine > macdSignal and macdLine > 0
    _macdShort = macdLine < macdSignal and macdLine < 0
    up = ta.change(high)
    dn = -ta.change(low)
    plusDM = up > dn and up > 0 ? up : 0.0
    minusDM = dn > up and dn > 0 ? dn : 0.0
    atrVal = ta.atr(14)
    pDI = atrVal != 0 ? 100 * ta.rma(plusDM, 14) / atrVal : 0.0
    mDI = atrVal != 0 ? 100 * ta.rma(minusDM, 14) / atrVal : 0.0
    dx = pDI + mDI != 0 ? 100 * math.abs(pDI - mDI) / (pDI + mDI) : 0.0
    adxVal = ta.rma(dx, 14)
    _adxLong = adxVal > 20 and pDI > mDI
    _adxShort = adxVal > 20 and mDI > pDI
    [st, dirst] = ta.supertrend(3, 10)
    _stLong = dirst < 0
    _stShort = dirst > 0
    [_emaLong, _emaShort, _macdLong, _macdShort, _adxLong, _adxShort, _stLong, _stShort]

f_entry_calc() =>
    rsi14 = ta.rsi(close, 14)
    _rsiLong = rsi14 > 50
    _rsiShort = rsi14 < 50
    obvStep = close > close[1] ? volume : close < close[1] ? -volume : 0.0
    var float obvSeries = 0.0
    obvSeries := nz(obvSeries[1]) + obvStep
    obvSma = ta.sma(obvSeries, 20)
    _obvLong = obvSeries > obvSma and obvSeries > obvSeries[1]
    _obvShort = obvSeries < obvSma and obvSeries < obvSeries[1]
    volOsc = ta.sma(volume, 5) - ta.sma(volume, 20)
    volRatio = volume / ta.sma(volume, 20)
    _volLong = volOsc > 0 and volRatio > 1
    _volShort = volOsc < 0 and volRatio < 1
    atrVal = ta.atr(14)
    atrMean = ta.sma(atrVal, 50)
    _atrActive = atrVal > atrMean
    _atrInactive = atrVal <= atrMean
    pHi = ta.pivothigh(high, 3, 3)
    pLo = ta.pivotlow(low, 3, 3)
    var float lastOB_High = na
    var float lastOB_Low = na
    var string obBias = "NONE"
    if not na(pHi)
        lastOB_High := pHi
    if not na(pLo)
        lastOB_Low := pLo
    if not na(lastOB_High) and close > lastOB_High
        obBias := "LONG"
    else if not na(lastOB_Low) and close < lastOB_Low
        obBias := "SHORT"
    _obLong  = (obBias == "LONG")
    _obShort = (obBias == "SHORT")
    [_rsiLong, _rsiShort, _obvLong, _obvShort, _volLong, _volShort, _atrActive, _atrInactive, _obLong, _obShort]

[emaLong, emaShort, macdLong, macdShort, adxLong, adxShort, stLong, stShort] = request.security(syminfo.tickerid, trendTF == '' ? timeframe.period : trendTF, f_trend_calc(), barmerge.gaps_off, barmerge.lookahead_off)
[rsiLong, rsiShort, obvLong, obvShort, volLong, volShort, atrActive, atrInactive, obLong, obShort] = request.security(syminfo.tickerid, entryTF == '' ? timeframe.period : entryTF, f_entry_calc(), barmerge.gaps_off, barmerge.lookahead_off)

trendLongScore  = (useEMA and emaLong ? 1 : 0) + (useMACD and macdLong ? 1 : 0) + (useADX and adxLong ? 1 : 0) + (useSuper and stLong ? 1 : 0)
trendShortScore = (useEMA and emaShort ? 1 : 0) + (useMACD and macdShort ? 1 : 0) + (useADX and adxShort ? 1 : 0) + (useSuper and stShort ? 1 : 0)
trendCount      = (useEMA ? 1 : 0) + (useMACD ? 1 : 0) + (useADX ? 1 : 0) + (useSuper ? 1 : 0)

entryLongScore  = (useRSI and rsiLong ? 1 : 0) + (useOBV and obvLong ? 1 : 0) + (useVolume and volLong ? 1 : 0) + (useOB and obLong ? 1 : 0) + (useATR and atrActive ? 1 : 0)
entryShortScore = (useRSI and rsiShort ? 1 : 0) + (useOBV and obvShort ? 1 : 0) + (useVolume and volShort ? 1 : 0) + (useOB and obShort ? 1 : 0) + (useATR and atrInactive ? 1 : 0)
entryCount      = (useRSI ? 1 : 0) + (useOBV ? 1 : 0) + (useVolume ? 1 : 0) + (useOB ? 1 : 0) + (useATR ? 1 : 0)

rowStyle(use, condLong, condShort) =>
    txtCol   = use ? color.white : color.gray
    longCol  = condLong ? (use ? color.lime : color.gray) : color.new(color.white, 70)
    shortCol = condShort ? (use ? color.red : color.gray) : color.new(color.white, 70)
    bg       = use ? na : color.new(color.gray, 85)
    [txtCol, longCol, shortCol, bg]

var table t = na
var bool prevOzet = false

if barstate.isfirst or prevOzet != SumConfTable
    if not na(t)
        table.delete(t)
    t := table.new(position = pos, columns = 3, rows = SumConfTable ? 4 : 14, 
                   border_width = showBorder ? borderWidth : 0, 
                   border_color = showBorder ? borderColor : color.new(color.white, 100))
    prevOzet := SumConfTable

if barstate.islast and showConfTable
    table.set_border_width(t, showBorder ? borderWidth : 0)
    table.set_border_color(t, showBorder ? borderColor : color.new(color.white, 100))

    if SumConfTable
        // Compact Summary View
        table.cell(t, 0, 0, 'Indicator', bgcolor = color.black, text_color = color.white, text_size = ts)
        table.cell(t, 1, 0, 'BULLISH', bgcolor = color.green, text_color = color.white, text_size = ts)
        table.cell(t, 2, 0, 'BEARISH', bgcolor = color.red, text_color = color.white, text_size = ts)

        trendHeaderColor = trendLongScore == trendCount ? color.lime : trendShortScore == trendCount ? color.red : color.rgb(50, 50, 50)
        table.cell(t, 0, 1, '📈 Trend Direction', text_color = color.white, bgcolor = trendHeaderColor, text_size = ts)
        table.cell(t, 1, 1, tTF, text_color = color.white, bgcolor = trendHeaderColor, text_size = ts, text_halign = text.align_left)
        table.cell(t, 2, 1, '', bgcolor = trendHeaderColor)

        table.cell(t, 0, 2, '📈 Trend Score', text_color = color.white, bgcolor = color.rgb(168, 203, 231, 30), text_size = ts)
        table.cell(t, 1, 2, str.tostring(trendLongScore) + '/' + str.tostring(trendCount), text_color = trendLongScore > trendShortScore ? color.lime : color.gray, text_size = ts)
        table.cell(t, 2, 2, str.tostring(trendShortScore) + '/' + str.tostring(trendCount), text_color = trendShortScore > trendLongScore ? color.red : color.gray, text_size = ts)

        table.cell(t, 0, 3, '🎯 Entry Score', text_color = color.white, bgcolor = color.rgb(168, 203, 231, 30), text_size = ts)
        table.cell(t, 1, 3, str.tostring(entryLongScore) + '/' + str.tostring(entryCount), text_color = entryLongScore > entryShortScore ? color.lime : color.gray, text_size = ts)
        table.cell(t, 2, 3, str.tostring(entryShortScore) + '/' + str.tostring(entryCount), text_color = entryShortScore > entryLongScore ? color.red : color.gray, text_size = ts)

    else
        // Full Detailed View
        table.cell(t, 0, 0, 'Indicator', bgcolor = color.black, text_color = color.white, text_size = ts)
        table.cell(t, 1, 0, 'BULLISH', bgcolor = color.green, text_color = color.white, text_size = ts)
        table.cell(t, 2, 0, 'BEARISH', bgcolor = color.red, text_color = color.white, text_size = ts)

        trendHeaderColor = trendLongScore == trendCount ? color.lime : trendShortScore == trendCount ? color.red : color.rgb(50, 50, 50)
        table.cell(t, 0, 1, '📈 Trend Direction', text_color = color.white, bgcolor = trendHeaderColor, text_size = ts)
        table.cell(t, 1, 1, tTF, text_color = color.white, bgcolor = trendHeaderColor, text_size = ts, text_halign = text.align_left)
        table.cell(t, 2, 1, '', bgcolor = trendHeaderColor)

        [txt1, lc1, sc1, bg1] = rowStyle(useEMA, emaLong, emaShort)
        table.cell(t, 0, 2, 'EMA (' + str.tostring(fastEMALen) + '/' + str.tostring(slowEMALen) + ')', text_color = txt1, bgcolor = bg1, text_size = ts)
        table.cell(t, 1, 2, emaLong ? '✓' : '', text_color = lc1, bgcolor = bg1, text_size = ts)
        table.cell(t, 2, 2, emaShort ? '✓' : '', text_color = sc1, bgcolor = bg1, text_size = ts)

        [txt2, lc2, sc2, bg2] = rowStyle(useMACD, macdLong, macdShort)
        table.cell(t, 0, 3, 'MACD', text_color = txt2, bgcolor = bg2, text_size = ts)
        table.cell(t, 1, 3, macdLong ? '✓' : '', text_color = lc2, bgcolor = bg2, text_size = ts)
        table.cell(t, 2, 3, macdShort ? '✓' : '', text_color = sc2, bgcolor = bg2, text_size = ts)

        [txt3, lc3, sc3, bg3] = rowStyle(useADX, adxLong, adxShort)
        table.cell(t, 0, 4, 'ADX Filter', text_color = txt3, bgcolor = bg3, text_size = ts)
        table.cell(t, 1, 4, adxLong ? '✓' : '', text_color = lc3, bgcolor = bg3, text_size = ts)
        table.cell(t, 2, 4, adxShort ? '✓' : '', text_color = sc3, bgcolor = bg3, text_size = ts)

        [txt4, lc4, sc4, bg4] = rowStyle(useSuper, stLong, stShort)
        table.cell(t, 0, 5, 'SuperTrend', text_color = txt4, bgcolor = bg4, text_size = ts)
        table.cell(t, 1, 5, stLong ? '✓' : '', text_color = lc4, bgcolor = bg4, text_size = ts)
        table.cell(t, 2, 5, stShort ? '✓' : '', text_color = sc4, bgcolor = bg4, text_size = ts)

        entryHeaderColor = entryLongScore == entryCount ? color.lime : entryShortScore == entryCount ? color.red : color.rgb(50, 50, 50)
        table.cell(t, 0, 6, '🎯 Momentum / Entry', text_color = color.white, bgcolor = entryHeaderColor, text_size = ts)
        table.cell(t, 1, 6, eTF, text_color = color.white, bgcolor = entryHeaderColor, text_size = ts, text_halign = text.align_left)
        table.cell(t, 2, 6, '', bgcolor = entryHeaderColor)

        [txt5, lc5, sc5, bg5] = rowStyle(useRSI, rsiLong, rsiShort)
        table.cell(t, 0, 7, 'RSI (14)', text_color = txt5, bgcolor = bg5, text_size = ts)
        table.cell(t, 1, 7, rsiLong ? '✓' : '', text_color = lc5, bgcolor = bg5, text_size = ts)
        table.cell(t, 2, 7, rsiShort ? '✓' : '', text_color = sc5, bgcolor = bg5, text_size = ts)

        [txt6, lc6, sc6, bg6] = rowStyle(useOBV, obvLong, obvShort)
        table.cell(t, 0, 8, 'OBV Trend', text_color = txt6, bgcolor = bg6, text_size = ts)
        table.cell(t, 1, 8, obvLong ? '✓' : '', text_color = lc6, bgcolor = bg6, text_size = ts)
        table.cell(t, 2, 8, obvShort ? '✓' : '', text_color = sc6, bgcolor = bg6, text_size = ts)

        [txt7, lc7, sc7, bg7] = rowStyle(useVolume, volLong, volShort)
        table.cell(t, 0, 9, 'Volume Surge', text_color = txt7, bgcolor = bg7, text_size = ts)
        table.cell(t, 1, 9, volLong ? '✓' : '', text_color = lc7, bgcolor = bg7, text_size = ts)
        table.cell(t, 2, 9, volShort ? '✓' : '', text_color = sc7, bgcolor = bg7, text_size = ts)

        if useATR
            table.cell(t, 0, 10, 'Volatility (ATR)', text_color = color.white, bgcolor = color.rgb(35, 35, 35), text_size = ts)
            table.cell(t, 1, 10, atrActive ? '⚡ High Volatility' : '… Low Volatility', text_color = atrActive ? color.orange : color.gray, bgcolor = na, text_size = ts)
            table.merge_cells(t, 1, 10, 2, 10)

        [txtOB, lcOB, scOB, bgOB] = rowStyle(useOB, obLong, obShort)
        table.cell(t, 0, 11, 'Order Block', text_color = txtOB, bgcolor = bgOB, text_size = ts)
        table.cell(t, 1, 11, obLong ? '✓' : '', text_color = lcOB, bgcolor = bgOB, text_size = ts)
        table.cell(t, 2, 11, obShort ? '✓' : '', text_color = scOB, bgcolor = bgOB, text_size = ts)

        table.cell(t, 0, 12, '📈 Trend Score', text_color = color.white, bgcolor = color.rgb(168, 203, 231, 30), text_size = ts)
        table.cell(t, 1, 12, str.tostring(trendLongScore) + '/' + str.tostring(trendCount), text_color = trendLongScore > trendShortScore ? color.lime : color.gray, text_size = ts)
        table.cell(t, 2, 12, str.tostring(trendShortScore) + '/' + str.tostring(trendCount), text_color = trendShortScore > trendLongScore ? color.red : color.gray, text_size = ts)

        table.cell(t, 0, 13, '🎯 Entry Score', text_color = color.white, bgcolor = color.rgb(168, 203, 231, 30), text_size = ts)
        table.cell(t, 1, 13, str.tostring(entryLongScore) + '/' + str.tostring(entryCount), text_color = entryLongScore > entryShortScore ? color.lime : color.gray, text_size = ts)
        table.cell(t, 2, 13, str.tostring(entryShortScore) + '/' + str.tostring(entryCount), text_color = entryShortScore > entryLongScore ? color.red : color.gray, text_size = ts)

// ============================================================================
// BAR COLORING ENGINE
// ============================================================================

trendBias = trendLongScore > trendShortScore ? 1 : trendShortScore > trendLongScore ? -1 : 0
barcolor(useBarColor ? trendBias == 1 ? color.new(barLongColor, barTransp) : trendBias == -1 ? color.new(barShortColor, barTransp) : color.new(barNeutralColor, barTransp) : na)
````
