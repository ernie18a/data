# ETH Futures VWAP RSI MACD Scalper + Levels

- url: https://www.tradingview.com/script/Pk2DVVqo-ETH-Futures-VWAP-RSI-MACD-Scalper-Levels/
- type: indicator
- pine_id: PUB;61f398123c9545658e14ee1856572d9a
- version: 1.0

## Description

This fold alerts into the same ETH futures script so it gives you BUY/SELL + Entry + SL + T1 + T2 and can be used for notifications too. TradingView supports alert triggers, and strategy-style alert messages can include stop/target values as part of the alert text.

How to use alerts
Add the script to your ETH 5m chart.

Create an alert and choose this indicator.

Select BUY Alert or SELL Alert from the condition list.

Use Once Per Bar Close for cleaner entries.

For your 4–5 trades/day goal
Keep the pullbackLong / pullbackShort logic active.

Keep RSI thresholds relatively loose.

Use 5m instead of 1m if you want fewer but cleaner alerts.

If you want more trades, lower bodyMin slightly to 0.30 and distATR to 0.02.

## Source Code

````pine
//@version=5
indicator("ETH Futures VWAP RSI MACD Scalper + Levels", overlay=true, max_labels_count=500, max_lines_count=500)

// Fixed settings
emaFastLen = 9
emaSlowLen = 21
rsiLen     = 14
volLen     = 20
atrLen     = 14

bodyMin    = 0.35
distATR    = 0.03
rsiBuyMin  = 48
rsiSellMax = 52
t1ATR      = 0.4
t2ATR      = 0.8
slATR      = 0.35

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
vwapVal = ta.vwap(hlc3)
rsi     = ta.rsi(close, rsiLen)
volSma  = ta.sma(volume, volLen)
atr     = ta.atr(atrLen)
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)

body     = math.abs(close - open)
barRange = high - low
bodyPct  = barRange > 0 ? body / barRange : 0.0
volOk    = volume > volSma

bullCandle = close > open and bodyPct >= bodyMin and close >= high[1]
bearCandle = close < open and bodyPct >= bodyMin and close <= low[1]

trendUp = close > vwapVal and emaFast > emaSlow and emaFast > vwapVal
trendDn = close < vwapVal and emaFast < emaSlow and emaFast < vwapVal

pullbackLong = trendUp and close <= vwapVal and rsi >= rsiBuyMin and hist > -0.01 and volOk
breakoutLong = ta.crossover(close, vwapVal) and trendUp and rsi >= rsiBuyMin and hist > 0 and volOk and bullCandle

pullbackShort = trendDn and close >= vwapVal and rsi <= rsiSellMax and hist < 0.01 and volOk
breakoutShort = ta.crossunder(close, vwapVal) and trendDn and rsi <= rsiSellMax and hist < 0 and volOk and bearCandle

buySetup  = pullbackLong or breakoutLong
sellSetup = pullbackShort or breakoutShort

var int state = 0
buySignal  = buySetup and state <= 0
sellSignal = sellSetup and state >= 0

var line entryLine = na
var line t1Line = na
var line t2Line = na
var line slLine = na

f_clear_lines() =>
    if not na(entryLine)
        line.delete(entryLine)
    if not na(t1Line)
        line.delete(t1Line)
    if not na(t2Line)
        line.delete(t2Line)
    if not na(slLine)
        line.delete(slLine)

if buySignal
    state := 1
    f_clear_lines()
    entry = close
    t1 = entry + atr * t1ATR
    t2 = entry + atr * t2ATR
    sl = entry - atr * slATR
    label.new(bar_index, low * 0.999,
         "BUY\nEntry: " + str.tostring(entry, format.mintick) +
         "\nSL: " + str.tostring(sl, format.mintick) +
         "\nT1: " + str.tostring(t1, format.mintick) +
         "\nT2: " + str.tostring(t2, format.mintick),
         color=color.new(color.green, 0), style=label.style_label_up, textcolor=color.white, size=size.large)
    entryLine := line.new(bar_index, entry, bar_index + 15, entry, extend=extend.right, color=color.green, width=2)
    t1Line := line.new(bar_index, t1, bar_index + 15, t1, extend=extend.right, color=color.lime, width=2)
    t2Line := line.new(bar_index, t2, bar_index + 15, t2, extend=extend.right, color=color.teal, width=2)
    slLine := line.new(bar_index, sl, bar_index + 15, sl, extend=extend.right, color=color.red, width=2)

if sellSignal
    state := -1
    f_clear_lines()
    entry = close
    t1 = entry - atr * t1ATR
    t2 = entry - atr * t2ATR
    sl = entry + atr * slATR
    label.new(bar_index, high * 1.001,
         "SELL\nEntry: " + str.tostring(entry, format.mintick) +
         "\nSL: " + str.tostring(sl, format.mintick) +
         "\nT1: " + str.tostring(t1, format.mintick) +
         "\nT2: " + str.tostring(t2, format.mintick),
         color=color.new(color.red, 0), style=label.style_label_down, textcolor=color.white, size=size.large)
    entryLine := line.new(bar_index, entry, bar_index + 15, entry, extend=extend.right, color=color.red, width=2)
    t1Line := line.new(bar_index, t1, bar_index + 15, t1, extend=extend.right, color=color.orange, width=2)
    t2Line := line.new(bar_index, t2, bar_index + 15, t2, extend=extend.right, color=color.maroon, width=2)
    slLine := line.new(bar_index, sl, bar_index + 15, sl, extend=extend.right, color=color.green, width=2)

alertcondition(buySignal, title="BUY Alert", message="ETH BUY signal: VWAP + RSI + MACD scalp")
alertcondition(sellSignal, title="SELL Alert", message="ETH SELL signal: VWAP + RSI + MACD scalp")

plot(emaFast, color=color.orange, title="EMA Fast")
plot(emaSlow, color=color.yellow, title="EMA Slow")
plot(vwapVal, color=color.blue, title="VWAP")
````
