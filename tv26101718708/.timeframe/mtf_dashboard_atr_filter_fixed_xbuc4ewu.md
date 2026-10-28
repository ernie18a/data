# MTF Dashboard + ATR Filter (Fixed)

- url: https://www.tradingview.com/script/xbuc4EwU-MTF-Dashboard-ATR-Filter-Fixed/
- type: indicator
- pine_id: PUB;5dd6742fe5c4472a8bb13ef6afeb257a
- version: 1.0

## Description

Multi-Timeframe Dashboard with Smart Color Coding

This clean and practical dashboard helps you analyze market bias across 3 timeframes (1H, 30m, and 5m) with clear visual signals and mechanical rules.

**Key Features:**
- EMA 200 alignment
- DI Delta + ADX Slope (direction + trend strength change)
- Enhanced WaveTrend with automatic Cross Up / Cross Down detection
- RSI status with timeframe-specific logic
- ATR-based Move Status on 5m (detects extended vs normal moves)
- Smart color coding: Blue = Bullish, Gray = Bearish

**Best Long Conditions:**
- Price above EMA 200 on 1H
- DI Delta positive + rising (↑) on 1H
- WaveTrend: WT1 > WT2 or Cross Up (minimum 2 out of 3 timeframes)
- 5m Move Status = Normal (not Extended)

**Best Short Conditions:**
- Price below EMA 200 on 1H
- DI Delta negative + falling (↓) on 1H
- WaveTrend: WT1 < WT2 or Cross Down (minimum 2 out of 3 timeframes)
- 5m Move Status = Normal (not Extended)

**How to use:**
1. Check the 1H column first (most important for bias)
2. Use 30m and 5m for entry timing
3. Only take trades when at least 2 WaveTrend conditions align with the higher timeframe bias
4. Avoid entries when 5m Move Status shows "Extended"

Ideal for traders who want a mechanical and confluence-based approach.

Works well on Crypto, Forex, and Indices.

## Source Code

````pine
//@version=6
indicator('MTF Dashboard + ATR Filter (Fixed)', overlay = true, max_labels_count = 500)

// ================== Inputs ==================
emaLen = input.int(200, 'EMA Length', group = 'Settings')
atrLen = input.int(14, 'ATR Length', group = 'ATR Filter')

// ================== Calculations ==================
ema200 = ta.ema(close, emaLen)
atr14 = ta.atr(atrLen)

// WaveTrend
wtChannelLen = input.int(10, 'WT Channel Length', group = 'WaveTrend')
wtAverageLen = input.int(21, 'WT Average Length', group = 'WaveTrend')
ap = hlc3
esa = ta.ema(ap, wtChannelLen)
d = ta.ema(math.abs(ap - esa), wtChannelLen)
ci = (ap - esa) / (0.015 * d)
tci = ta.ema(ci, wtAverageLen)
wt1 = tci
wt2 = ta.sma(wt1, 4)

// ADX + DI
[diplus, diminus, adx] = ta.dmi(14, 14)

// RSI
rsi = ta.rsi(close, 14)

// ================== Colors ==================
bullColor = color.new(#2196F3, 0)
bearColor = color.new(#607D8B, 0)
flatColor = color.new(#FFC107, 0)
extendedColor = color.new(#FF5252, 0)

// ================== Status Functions ==================

f_ema_1h() =>
    request.security(syminfo.tickerid, '60', close > ema200 ? 'Above' : close < ema200 ? 'Below' : 'Near')
f_ema_30m() =>
    request.security(syminfo.tickerid, '30', close > ema200 ? 'Above' : close < ema200 ? 'Below' : 'Near')
f_ema_5m() =>
    request.security(syminfo.tickerid, '5', close > ema200 ? 'Above' : close < ema200 ? 'Below' : 'Near')

// ================== WaveTrend (اصلاح شده با ternary) ==================
f_wt_1h() =>
    w1 = request.security(syminfo.tickerid, '60', wt1)
    w2 = request.security(syminfo.tickerid, '60', wt2)
    crossUp = ta.crossover(w1, w2)
    crossDown = ta.crossunder(w1, w2)

    if crossUp
        'Cross Up'
    else if crossDown
        'Cross Down'
    else if w1 > w2
        'WT1 > WT2'
    else
        'WT1 < WT2'

f_wt_30m() =>
    w1 = request.security(syminfo.tickerid, '30', wt1)
    w2 = request.security(syminfo.tickerid, '30', wt2)
    crossUp = ta.crossover(w1, w2)
    crossDown = ta.crossunder(w1, w2)

    if crossUp
        'Cross Up'
    else if crossDown
        'Cross Down'
    else if w1 > w2
        'WT1 > WT2'
    else
        'WT1 < WT2'

f_wt_5m() =>
    w1 = request.security(syminfo.tickerid, '5', wt1)
    w2 = request.security(syminfo.tickerid, '5', wt2)
    crossUp = ta.crossover(w1, w2)
    crossDown = ta.crossunder(w1, w2)

    if crossUp
        'Cross Up'
    else if crossDown
        'Cross Down'
    else if w1 > w2
        'WT1 > WT2'
    else
        'WT1 < WT2'

// ================== DI Delta + ADX Slope ==================
f_di_delta_slope(tf) =>
    [dp, dm, ax] = request.security(syminfo.tickerid, tf, [diplus, diminus, adx])
    delta = dp - dm
    ax_prev = request.security(syminfo.tickerid, tf, adx[3])
    slope = ax > ax_prev ? '↑' : ax < ax_prev ? '↓' : '→'
    str.tostring(delta, '#.##') + ' ' + slope

// ================== RSI ==================
f_rsi_1h() =>
    rsi >= 65 ? 'Overbought' : rsi <= 35 ? 'Oversold' : rsi > 50 ? 'Bullish' : 'Bearish'
f_rsi_30m() =>
    rsi >= 70 ? 'Overbought' : rsi <= 30 ? 'Oversold' : rsi > 50 ? 'Bullish' : 'Bearish'
f_rsi_5m() =>
    rsi >= 75 ? 'Overbought' : rsi <= 25 ? 'Oversold' : rsi > 50 ? 'Bullish' : 'Bearish'

// ================== ATR Filter ==================
f_atr_status() =>
    lowestLow = ta.lowest(low, 25)
    moveDistance = close - lowestLow
    if moveDistance > atr14 * 2.5
        'Extended'
    else
        'Normal'

// ================== Helper ==================
f_getBgColor(status) =>
    str.contains(status, 'Bullish') or str.contains(status, 'Above') or str.contains(status, 'Oversold') or str.contains(status, 'Cross Up') or str.contains(status, 'WT1 > WT2') or str.contains(status, 'Normal') ? bullColor : bearColor

f_getDeltaBg(val) =>
    str.contains(val, '↑') ? bullColor : str.contains(val, '↓') ? bearColor : flatColor

f_getAtrBg(status) =>
    status == 'Extended' ? extendedColor : bullColor

// ================== Dashboard Table ==================
var table dash = table.new(position.top_right, 4, 6, bgcolor = color.new(#1e222d, 80), border_width = 1)

if barstate.islast
    // Header
    table.cell(dash, 0, 0, 'Timeframe', text_color = color.white, bgcolor = #363a45)
    table.cell(dash, 1, 0, '1H (Strict)', text_color = color.white, bgcolor = #363a45)
    table.cell(dash, 2, 0, '30m', text_color = color.white, bgcolor = #363a45)
    table.cell(dash, 3, 0, '5m (Entry)', text_color = color.white, bgcolor = #363a45)

    // EMA 200
    table.cell(dash, 0, 1, 'EMA 200', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 1, 1, f_ema_1h(), text_color = color.white, bgcolor = f_getBgColor(f_ema_1h()))
    table.cell(dash, 2, 1, f_ema_30m(), text_color = color.white, bgcolor = f_getBgColor(f_ema_30m()))
    table.cell(dash, 3, 1, f_ema_5m(), text_color = color.white, bgcolor = f_getBgColor(f_ema_5m()))

    // DI Delta + ADX Slope
    ds1h = f_di_delta_slope('60')
    ds30m = f_di_delta_slope('30')
    ds5m = f_di_delta_slope('5')
    table.cell(dash, 0, 2, 'DI Delta + ADX Slope', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 1, 2, ds1h, text_color = color.white, bgcolor = f_getDeltaBg(ds1h))
    table.cell(dash, 2, 2, ds30m, text_color = color.white, bgcolor = f_getDeltaBg(ds30m))
    table.cell(dash, 3, 2, ds5m, text_color = color.white, bgcolor = f_getDeltaBg(ds5m))

    // WaveTrend
    table.cell(dash, 0, 3, 'WaveTrend', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 1, 3, f_wt_1h(), text_color = color.white, bgcolor = f_getBgColor(f_wt_1h()))
    table.cell(dash, 2, 3, f_wt_30m(), text_color = color.white, bgcolor = f_getBgColor(f_wt_30m()))
    table.cell(dash, 3, 3, f_wt_5m(), text_color = color.white, bgcolor = f_getBgColor(f_wt_5m()))

    // RSI
    table.cell(dash, 0, 4, 'RSI 14', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 1, 4, f_rsi_1h(), text_color = color.white, bgcolor = f_getBgColor(f_rsi_1h()))
    table.cell(dash, 2, 4, f_rsi_30m(), text_color = color.white, bgcolor = f_getBgColor(f_rsi_30m()))
    table.cell(dash, 3, 4, f_rsi_5m(), text_color = color.white, bgcolor = f_getBgColor(f_rsi_5m()))

    // ATR Filter
    atrStatus = f_atr_status()
    table.cell(dash, 0, 5, '5m Move Status (ATR)', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 1, 5, '-', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 2, 5, '-', text_color = color.white, bgcolor = #2a2e39)
    table.cell(dash, 3, 5, atrStatus, text_color = color.white, bgcolor = f_getAtrBg(atrStatus))
````
