# Macd and RSI % Change Signals  MTF 

- url: https://www.tradingview.com/script/DZPX8sPZ/
- type: indicator
- pine_id: PUB;310fb39c077044979b4ef70042252a51
- version: 1.0

## Description

MACD & RSI % Change Signals + MTF Open Confirmation
Advanced momentum indicator combining Logarithmic RSI % Change, modified MACD, and Multi-Timeframe Open Price Confirmation.
This indicator detects high-probability entries by filtering custom MACD and RSI-based signals with strict multi-timeframe price action confirmation.

How It Works
1. Dual Signal Engine

Logarithmic RSI % Change System:
Uses RSI calculated on logarithmic scale (high, low, close) to generate more sensitive momentum signals.
Multiple bullish and bearish crossover levels (C20, C10, L20 for longs / L20, C20, C10 for shorts).
Modified MACD System:
Special MACD built with RSI applied to the oscillator for smoother and more responsive signals.
Multiple threshold levels (M2, M3, M4, M5) for both long and short entries.

2. MTF Open Price Confirmation (Core Filter)

Checks current price against the opening price of 4 customizable timeframes (default: 5m, 15m, 60m, 240m).
Long Signal is only valid if price is above the open on all selected timeframes.
Short Signal is only valid if price is below the open on all selected timeframes.
This powerful filter ensures you only trade in the direction of the current multi-timeframe bias.

3. Visual Elements

Clear triangle signals with labels (C20L, M5S, etc.) for easy identification.
Pullback Levels: Automatically plots the most recent confirmed signal’s high/low as dynamic support/resistance.
Live MTF Status Table: Shows current Open prices of all timeframes and overall market bias (LONG / SHORT / NEUTRAL).


Key Features

Log RSI % Change signals (highly responsive)
Modified MACD with multiple confirmation levels
Strict 4-Timeframe Open Price Confirmation Filter
Pullback level plotting for better risk management
Real-time MTF Open Status Panel
Fully customizable timeframes
Multiple alert conditions


Best Used For

Intraday & Scalping on lower timeframes (5m, 15m)
Swing Trading on 1H and 4H charts
Filtering false MACD/RSI signals in choppy markets
Trading with the dominant multi-timeframe momentum


This system significantly reduces whipsaws by combining powerful momentum oscillators with a strict higher-timeframe open price alignment filter.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © engineerofmoney

//@version=6

indicator('Macd and RSI % Change Signals  MTF ', overlay = true, max_lines_count = 500)

// ===== MTF AYARLARI =====
grpMTF = 'Multi Timeframe Onayı - TF Open Fiyatı'
useMTF = input.bool(true, 'MTF Onayı Aktif', group = grpMTF)
tf1 = input.timeframe('5', 'Zaman Dilimi 1', group = grpMTF)
tf2 = input.timeframe('15', 'Zaman Dilimi 2', group = grpMTF)
tf3 = input.timeframe('60', 'Zaman Dilimi 3', group = grpMTF)
tf4 = input.timeframe('240', 'Zaman Dilimi 4', group = grpMTF)

// ===== ORİJİNAL HESAPLAR =====
logHigh = math.log(high)
logLow = math.log(low)
logClose = math.log(close)

rsihigh = ta.rsi(logHigh, 14)
rsilow = ta.rsi(logLow, 14)
rsiclose = ta.rsi(logClose, 14)

rsiChangehigh = ta.change(rsihigh)
rsiChangelow = ta.change(rsilow)
rsiChangeclose = ta.change(rsiclose)

long_signal1 = ta.crossover(rsiChangeclose, 14)
long_signal2 = ta.crossover(rsiChangeclose, 10)
long_signal3 = ta.crossover(rsiChangelow, 20)

short_signal1 = ta.crossunder(rsiChangelow, -20)
short_signal2 = ta.crossunder(rsiChangeclose, -14)
short_signal3 = ta.crossunder(rsiChangeclose, -10)

// MACD Bölümü
fast_length = input(title = 'Fast Length', defval = 12)
slow_length = input(title = 'Slow Length', defval = 26)
src = input(title = 'Source', defval = close)
signal_length = input.int(title = 'Signal Smoothing', minval = 1, maxval = 50, defval = 9, display = display.data_window)
sma_source = input.string(title = 'Oscillator MA Type', defval = 'EMA', options = ['SMA', 'EMA'], display = display.data_window)
sma_signal = input.string(title = 'Signal Line MA Type', defval = 'EMA', options = ['SMA', 'EMA'], display = display.data_window)

fast_ma = sma_source == 'SMA' ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source == 'SMA' ? ta.sma(src, slow_length) : ta.ema(src, slow_length)
macd = ta.change(ta.rsi(fast_ma - slow_ma, 100))
signal = ta.change(ta.rsi(sma_signal == 'SMA' ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length), 100))
top = (macd + signal) / 2

long_signal11 = ta.crossover(macd, 2) or ta.crossover(signal, 2) or ta.crossover(top, 2)
long_signal21 = ta.crossover(macd, 3) or ta.crossover(signal, 3) or ta.crossover(top, 3)
long_signal31 = ta.crossover(macd, 4) or ta.crossover(signal, 4) or ta.crossover(top, 4)
long_signal41 = ta.crossover(macd, 5) or ta.crossover(signal, 5) or ta.crossover(top, 5)
short_signal11 = ta.crossunder(macd, -2) or ta.crossunder(signal, -2) or ta.crossunder(top, -2)
short_signal21 = ta.crossunder(macd, -3) or ta.crossunder(signal, -3) or ta.crossunder(top, -3)
short_signal31 = ta.crossunder(macd, -4) or ta.crossunder(signal, -4) or ta.crossunder(top, -4)
short_signal41 = ta.crossunder(macd, -5) or ta.crossunder(signal, -5) or ta.crossunder(top, -5)

// ===== MTF OPEN FİLTRE FONKSİYONU =====
// İlgili TF'nin o anki mumunun open fiyatını al
getTFOpen(_tf) =>
    request.security(syminfo.tickerid, _tf, open, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// 4 TF'nin hepsinde fiyat > open mı?
mtfBullish(_tf) =>
    close > getTFOpen(_tf)
    // 4 TF'nin hepsinde fiyat < open mı?
mtfBearish(_tf) =>
    close < getTFOpen(_tf)

// 4 TF'nin hepsi long onayı veriyor mu?
allMTFLong = not useMTF or mtfBullish(tf1) and mtfBullish(tf2) and mtfBullish(tf3) and mtfBullish(tf4)
// 4 TF'nin hepsi short onayı veriyor mu?
allMTFShort = not useMTF or mtfBearish(tf1) and mtfBearish(tf2) and mtfBearish(tf3) and mtfBearish(tf4)

// ===== SİNYALLERİ MTF İLE FİLTRELE =====
final_long_signal1 = long_signal1 and allMTFLong
final_long_signal2 = long_signal2 and allMTFLong
final_long_signal3 = long_signal3 and allMTFLong
final_short_signal1 = short_signal1 and allMTFShort
final_short_signal2 = short_signal2 and allMTFShort
final_short_signal3 = short_signal3 and allMTFShort

final_long_signal11 = long_signal11 and allMTFLong
final_long_signal21 = long_signal21 and allMTFLong
final_long_signal31 = long_signal31 and allMTFLong
final_long_signal41 = long_signal41 and allMTFLong
final_short_signal11 = short_signal11 and allMTFShort
final_short_signal21 = short_signal21 and allMTFShort
final_short_signal31 = short_signal31 and allMTFShort
final_short_signal41 = short_signal41 and allMTFShort

// ===== PLOTLAR =====
plotshape(series = final_long_signal1, location = location.belowbar, color = color.green, style = shape.triangleup, text = 'C20L', size = size.normal, textcolor = color.green, title = 'C20 Long Signal')
plotshape(series = final_long_signal2, location = location.belowbar, color = #44f321, style = shape.triangleup, text = 'C10L', size = size.tiny, textcolor = #44f321, title = 'C10 Long Signal')
plotshape(series = final_long_signal3, location = location.belowbar, color = color.rgb(26, 231, 146), style = shape.triangleup, text = 'L20L', size = size.normal, textcolor = color.rgb(26, 231, 146), title = 'L20 Long Signal')

plotshape(series = final_short_signal1, location = location.abovebar, color = #c50fda, style = shape.triangledown, text = 'L20S', size = size.small, textcolor = color.red, title = 'L20 Short Signal')
plotshape(series = final_short_signal2, location = location.abovebar, color = color.rgb(251, 7, 19), style = shape.triangledown, text = 'C20S', size = size.normal, textcolor = #ee07db, title = 'C20 Short Signal')
plotshape(series = final_short_signal3, location = location.abovebar, color = #fe16d7, style = shape.triangledown, text = 'C10S', size = size.tiny, textcolor = color.yellow, title = 'C10 Short Signal')

plotshape(series = final_long_signal11, location = location.belowbar, color = color.green, style = shape.triangleup, text = 'M2L', size = size.tiny, textcolor = color.green, title = 'M2 Long Signal')
plotshape(series = final_long_signal21, location = location.belowbar, color = #44f321, style = shape.triangleup, text = 'M3L', size = size.small, textcolor = #44f321, title = 'M3 Long Signal')
plotshape(series = final_long_signal31, location = location.belowbar, color = color.rgb(26, 231, 146), style = shape.triangleup, text = 'M4L', size = size.normal, textcolor = color.rgb(26, 231, 146), title = 'M4 Long Signal')
plotshape(series = final_long_signal41, location = location.belowbar, color = color.lime, style = shape.triangleup, text = 'M5L', size = size.large, textcolor = color.lime, title = 'M5 Long Signal')

plotshape(series = final_short_signal11, location = location.abovebar, color = color.red, style = shape.triangledown, text = 'M2S', size = size.tiny, textcolor = color.red, title = 'M2 Short Signal')
plotshape(series = final_short_signal21, location = location.abovebar, color = color.rgb(238, 7, 18), style = shape.triangledown, text = 'M3S', size = size.small, textcolor = color.rgb(238, 7, 18), title = 'M3 Short Signal')
plotshape(series = final_short_signal31, location = location.abovebar, color = color.yellow, style = shape.triangledown, text = 'M4S', size = size.normal, textcolor = color.yellow, title = 'M4 Short Signal')
plotshape(series = final_short_signal41, location = location.abovebar, color = #f06ab2, style = shape.triangledown, text = 'M5S', size = size.large, textcolor = #f06ab2, title = 'M5 Short Signal')

// ===== PULLBACK SEVİYELERİ - SADECE MTF ONAYLI SİNYALLER İÇİN =====
var float longPullbackLevel = na
var float shortPullbackLevel = na

if final_long_signal1 or final_long_signal2 or final_long_signal3 or final_long_signal11 or final_long_signal21 or final_long_signal31 or final_long_signal41
    longPullbackLevel := low
    longPullbackLevel

if final_short_signal1 or final_short_signal2 or final_short_signal3 or final_short_signal11 or final_short_signal21 or final_short_signal31 or final_short_signal41
    shortPullbackLevel := high
    shortPullbackLevel

plot(longPullbackLevel, title = 'Long Pullback Seviyesi', color = color.rgb(11, 174, 238), linewidth = 2, style = plot.style_linebr)
plot(shortPullbackLevel, title = 'Short Pullback Seviyesi', color = #f50dc3, linewidth = 2, style = plot.style_linebr)

// ===== ALERTLER =====
alertcondition(final_long_signal1, title = 'MTF Open Long Alert', message = '4 TF Open Onaylı Long C20')
alertcondition(final_short_signal1, title = 'MTF Open Short Alert', message = '4 TF Open Onaylı Short C20')

// ===== MTF DURUM PANELİ =====
tf1Open = getTFOpen(tf1)
tf2Open = getTFOpen(tf2)
tf3Open = getTFOpen(tf3)
tf4Open = getTFOpen(tf4)

var table mtfTable = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islastconfirmedhistory
    table.cell(mtfTable, 0, 0, 'MTF Open', text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(mtfTable, 1, 0, allMTFLong ? 'LONG' : allMTFShort ? 'SHORT' : 'NÖTR', text_color = allMTFLong ? color.lime : allMTFShort ? color.red : color.gray, bgcolor = color.new(color.black, 0))

    table.cell(mtfTable, 0, 1, tf1, text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(mtfTable, 1, 1, str.tostring(tf1Open, format.mintick), text_color = close > tf1Open ? color.lime : color.red, bgcolor = color.new(color.black, 0))

    table.cell(mtfTable, 0, 2, tf2, text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(mtfTable, 1, 2, str.tostring(tf2Open, format.mintick), text_color = close > tf2Open ? color.lime : color.red, bgcolor = color.new(color.black, 0))

    table.cell(mtfTable, 0, 3, tf3, text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(mtfTable, 1, 3, str.tostring(tf3Open, format.mintick), text_color = close > tf3Open ? color.lime : color.red, bgcolor = color.new(color.black, 0))

    table.cell(mtfTable, 0, 4, tf4, text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(mtfTable, 1, 4, str.tostring(tf4Open, format.mintick), text_color = close > tf4Open ? color.lime : color.red, bgcolor = color.new(color.black, 0))
````
