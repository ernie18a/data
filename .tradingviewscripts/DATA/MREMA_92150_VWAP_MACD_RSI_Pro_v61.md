<!-- tradingview-pine-id: PUB;66fd686b0de54c87bb4ef9b5695a9193 -->
<!-- tradingviewscripts-format: 1 -->
# [MR]EMA 9/21/50 + VWAP + MACD + RSI Pro [v6.1]

Source: https://www.tradingview.com/script/mAyLcRiW-MR-EMA-9-21-50-VWAP-MACD-RSI-Pro-v6-1/

## Description

## What it does / how to use it

This is an improved indicator based on © joses2777 (overlaid on price):

- **EMA 9/21/50**: the trend ribbon. Stacked in order = strong trend.
- **VWAP**: the day's volume-weighted average price — intraday only (resets every day). → use it on M5/M15/H1, never on Daily+.
- **MACD + RSI**: momentum filters (the MACD isn't plotted, it's used for the logic).
- **Green/red background** = bullish/bearish regime.
- **🟢 BUY / 🔴 SELL label** = full confluence (trend + EMA9/21 cross + MACD + VWAP + RSI).
- **Table in the top-right** = live status of each component.

**Usage:**
Pine Editor → paste → Add to chart.
Wait until all the lights are green in the table + the entry label.
Create an alert on Bullish/Bearish Entry.

## Fixes

- **The RSI was plotted on the price chart** (`overlay=true`) — an RSI ranging from 0 to 100 squashed onto gold's price scale (~4000) is invisible/unusable, despite the "separate pane" comment. → removed from the chart, kept in the table. (For a real RSI panel, add TradingView's native RSI below.)
- **`show_alerts` was also disabling the visual signals** — the two were mixed together. → separated (`show_signals` vs `enable_alerts`).
- **RSI confirmation too fragile**: it required the RSI to cross 30 exactly at the moment of the EMA cross — nearly impossible, hence very few signals. → replaced with a momentum filter (RSI > 50 bullish / < 50 bearish, outside the OB/OS zones), far more usable.
- **Broken RSI format** (`format.mintick` → was showing the symbol's tick). → fixed to `#.0`.
- **No risk management** → added SL/TP labels based on the ATR (volatility) with a configurable R:R ratio.
- **Repetition/repaint**: signals that could stack up. → one signal per reversal + alerts on `once_per_bar_close` (no repaint).

**N.B.:** If you have any ideas, feel free to share them with us…

---

## Source Code

````pine
//@version=6
indicator('[MR]EMA 9/21/50 + VWAP + MACD + RSI Pro [v6.1]', overlay=true, precision=2, max_labels_count=500)
// Improved by Neo from © joses2777 original (MPL 2.0). Changes: RSI removed from
// price overlay (broken there) -> kept in dashboard; signals decoupled from alerts;
// RSI confirmation via midline momentum; ATR SL/TP labels; one-signal-per-flip;
// no-repaint alerts (once per bar close); RSI number format fixed.

// ===== Inputs =====
ema9_len  = input.int(9,'EMA 9',  group='Moving Averages', minval=1)
ema21_len = input.int(21,'EMA 21',group='Moving Averages', minval=1)
ema50_len = input.int(50,'EMA 50',group='Moving Averages', minval=1)

macd_fast   = input.int(12,'MACD Fast',  group='MACD', minval=1)
macd_slow   = input.int(26,'MACD Slow',  group='MACD', minval=1)
macd_signal = input.int(9, 'MACD Signal',group='MACD', minval=1)

rsi_length     = input.int(14,'RSI Length',    group='RSI', minval=1)
rsi_overbought = input.int(70,'RSI Overbought',group='RSI', minval=50, maxval=90)
rsi_oversold   = input.int(30,'RSI Oversold',  group='RSI', minval=10, maxval=50)
rsi_mid        = input.int(50,'RSI Midline',   group='RSI')

useATR = input.bool(true,'Show SL/TP labels (ATR)', group='Risk')
atrLen = input.int(14,'ATR Length', group='Risk', minval=1)
slMult = input.float(1.5,'SL x ATR', group='Risk', step=0.1)
rr     = input.float(2.0,'Reward:Risk', group='Risk', step=0.1)

show_signals  = input.bool(true,'Show entry signals', group='Signals')
enable_alerts = input.bool(true,'Enable alerts',      group='Signals')
oneflip       = input.bool(true,'One signal per trend flip', group='Signals')

ema9_color = input.color(#2962FF,'EMA 9', group='Style')
ema21_color= input.color(#FF6D00,'EMA 21',group='Style')
ema50_color= input.color(#00C853,'EMA 50',group='Style')
vwap_color = input.color(#AA00FF,'VWAP',  group='Style')

// ===== Calculations =====
ema9  = ta.ema(close, ema9_len)
ema21 = ta.ema(close, ema21_len)
ema50 = ta.ema(close, ema50_len)

vwap_value = ta.vwap(hlc3)
is_new_day = ta.change(time('D')) != 0

[macdLine, signalLine, histLine] = ta.macd(close, macd_fast, macd_slow, macd_signal)
macd_bull = histLine > 0 and histLine > histLine[1]
macd_bear = histLine < 0 and histLine < histLine[1]

rsi_value = ta.rsi(close, rsi_length)
atr = ta.atr(atrLen)

// Trend
trendBull = ema9 > ema21 and ema21 > ema50 and close > ema50
trendBear = ema9 < ema21 and ema21 < ema50 and close < ema50

crossUp = ta.crossover(ema9, ema21)
crossDn = ta.crossunder(ema9, ema21)

// RSI momentum confirmation (relative to midline, not a fragile OS/OB cross)
rsiBull = rsi_value > rsi_mid and rsi_value < rsi_overbought
rsiBear = rsi_value < rsi_mid and rsi_value > rsi_oversold

vwapOkLong  = na(vwap_value) or close > vwap_value
vwapOkShort = na(vwap_value) or close < vwap_value

rawLong  = trendBull and crossUp and macd_bull and rsiBull and vwapOkLong
rawShort = trendBear and crossDn and macd_bear and rsiBear and vwapOkShort

// One-signal-per-flip filter
var int lastSig = 0
longSig  = rawLong  and (not oneflip or lastSig != 1)
shortSig = rawShort and (not oneflip or lastSig != -1)
if longSig
    lastSig := 1
if shortSig
    lastSig := -1

// ===== Plots =====
plot(ema9, 'EMA 9', ema9_color, 2)
plot(ema21,'EMA 21',ema21_color,2)
plot(ema50,'EMA 50',ema50_color,2)
plot(is_new_day ? na : vwap_value, 'VWAP', vwap_color, 2, style=plot.style_linebr)

bgcolor(trendBull ? color.new(color.green,90) : trendBear ? color.new(color.red,90) : na)

plotshape(show_signals and longSig,  'Long',  shape.labelup,   location.belowbar, color.new(color.green,0), text='BUY',  textcolor=color.white, size=size.normal)
plotshape(show_signals and shortSig, 'Short', shape.labeldown, location.abovebar, color.new(color.red,0),   text='SELL', textcolor=color.white, size=size.normal)

// SL / TP labels (ATR based)
if useATR and longSig
    sl = close - slMult*atr
    tp = close + slMult*atr*rr
    label.new(bar_index, low,  'BUY\nSL '+str.tostring(sl,format.mintick)+'\nTP '+str.tostring(tp,format.mintick), color=color.new(color.green,0), textcolor=color.white, style=label.style_label_up, size=size.small)
if useATR and shortSig
    sl = close + slMult*atr
    tp = close - slMult*atr*rr
    label.new(bar_index, high, 'SELL\nSL '+str.tostring(sl,format.mintick)+'\nTP '+str.tostring(tp,format.mintick), color=color.new(color.red,0), textcolor=color.white, style=label.style_label_down, size=size.small)

// ===== Alerts (no repaint: once per closed bar) =====
if enable_alerts and longSig
    alert('LONG '+syminfo.ticker+' @ '+str.tostring(close,format.mintick), alert.freq_once_per_bar_close)
if enable_alerts and shortSig
    alert('SHORT '+syminfo.ticker+' @ '+str.tostring(close,format.mintick), alert.freq_once_per_bar_close)

alertcondition(longSig,  'Bullish Entry', 'EMA9>21, MACD up, RSI up, price strong')
alertcondition(shortSig, 'Bearish Entry', 'EMA9<21, MACD down, RSI down, price weak')

// ===== Dashboard =====
var table t = table.new(position.top_right, 2, 6, border_width=1, frame_color=color.gray)
if barstate.islast
    table.cell(t,0,0,'SYSTEM', bgcolor=color.new(color.blue,0), text_color=color.white)
    table.cell(t,1,0,timeframe.period, bgcolor=color.new(color.blue,0), text_color=color.white)
    table.cell(t,0,1,'Trend', bgcolor=color.gray, text_color=color.white)
    table.cell(t,1,1, trendBull?'BULLISH':trendBear?'BEARISH':'NEUTRAL', bgcolor=trendBull?color.new(color.green,0):trendBear?color.new(color.red,0):color.gray, text_color=color.white)
    table.cell(t,0,2,'EMA', bgcolor=color.gray, text_color=color.white)
    table.cell(t,1,2, ema9>ema21?'9 > 21':'9 < 21', bgcolor=ema9>ema21?color.new(color.green,0):color.new(color.red,0), text_color=color.white)
    table.cell(t,0,3,'MACD', bgcolor=color.gray, text_color=color.white)
    table.cell(t,1,3, macd_bull?'BULLISH':macd_bear?'BEARISH':'NEUTRAL', bgcolor=macd_bull?color.new(color.green,0):macd_bear?color.new(color.red,0):color.gray, text_color=color.white)
    table.cell(t,0,4,'RSI', bgcolor=color.gray, text_color=color.white)
    table.cell(t,1,4, str.tostring(rsi_value,'#.0')+(rsi_value>=rsi_overbought?' OB':rsi_value<=rsi_oversold?' OS':''), bgcolor=rsi_value>=rsi_overbought?color.new(color.red,0):rsi_value<=rsi_oversold?color.new(color.green,0):color.gray, text_color=color.white)
    table.cell(t,0,5,'VWAP', bgcolor=color.gray, text_color=color.white)
    table.cell(t,1,5, na(vwap_value)?'n/a':(close>vwap_value?'Price>VWAP':'Price<VWAP'), bgcolor=na(vwap_value)?color.gray:(close>vwap_value?color.new(color.green,0):color.new(color.red,0)), text_color=color.white)
````
