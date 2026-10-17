# SUMIT XAUUSD GOLD MASTER PRO V6

- url: https://www.tradingview.com/script/gUQy6UfU-SUMIT-XAUUSD-GOLD-MASTER-PRO-V6/
- type: indicator
- pine_id: PUB;b35bfde9915e4724974016d59ba1ca8e
- version: 1.0

## Description

XAUUSD GOLD MASTER PRO

Best Gold Trading Indicator for 15 Minute Timeframe.

Features:
• EMA 5, EMA 10, EMA 21 Trend System
• Buy & Sell Signals
• Strong Buy/Sell Crossovers
• Long Term Trend Signals
• UT BOT Confirmation
• Auto Stop Loss & Take Profit Levels
• Gold Scalping & Intraday Setup
• Trading Alerts Included

Best For:
• XAUUSD / GOLD
• 15 Minute Timeframe
• Scalping
• Intraday Trading

Signal Logic:
• EMA 5 crossing EMA 10 = Strong Signals
• EMA 5 crossing EMA 21 = Long Trend Signals
• UT BOT confirms entry direction
• SL & TP automatically displayed

Recommended:
• Use during London & New York Sessions
• Avoid high impact news timing

## Source Code

````pine
//@version=6
indicator("SUMIT XAUUSD GOLD MASTER PRO V6", overlay=true)

// EMA
ema5 = ta.ema(close, 5)
ema10 = ta.ema(close, 10)
ema21 = ta.ema(close, 21)

// CONDITIONS
buySignal = close > ema5
sellSignal = close < ema5

strongBuy = ta.crossover(ema5, ema10)
strongSell = ta.crossunder(ema5, ema10)

longBuy = ta.crossover(ema5, ema21) and ema10 > ema21
longSell = ta.crossunder(ema5, ema21) and ema10 < ema21

// UT BOT STYLE
buyATR = ta.atr(300)
sellATR = ta.atr(4)

buyStop = close - (buyATR * 4.0)
sellStop = close + (sellATR * 1.0)

utBuy = ta.crossover(close, buyStop)
utSell = ta.crossunder(close, sellStop)

// FINAL SIGNALS
finalBuy = close > ema5 and ema10 > ema21 and utBuy
finalSell = close < ema5 and ema10 < ema21 and utSell

// SL TP
slBuy = close - 100.0
tpBuy = close + 250.0

slSell = close + 100.0
tpSell = close - 250.0

// EMA PLOTS
plot(ema5, title="EMA 5", color=color.yellow, linewidth=2)
plot(ema10, title="EMA 10", color=color.blue, linewidth=2)
plot(ema21, title="EMA 21", color=color.red, linewidth=2)

// BUY SELL SIGNALS
plotshape(buySignal, title="BUY", location=location.belowbar, color=color.green, style=shape.triangleup, text="BUY")
plotshape(sellSignal, title="SELL", location=location.abovebar, color=color.red, style=shape.triangledown, text="SELL")

// STRONG SIGNALS
plotshape(strongBuy, title="STRONG BUY", location=location.belowbar, color=color.lime, style=shape.labelup, text="STRONG BUY")
plotshape(strongSell, title="STRONG SELL", location=location.abovebar, color=color.maroon, style=shape.labeldown, text="STRONG SELL")

// LONG TERM SIGNALS
plotshape(longBuy, title="LONG BUY", location=location.belowbar, color=color.aqua, style=shape.labelup, text="LONG BUY")
plotshape(longSell, title="LONG SELL", location=location.abovebar, color=color.orange, style=shape.labeldown, text="LONG SELL")

// UT BUY / SELL
plotshape(finalBuy, title="UT BUY", location=location.belowbar, color=color.green, style=shape.circle, size=size.large, text="UT BUY")
plotshape(finalSell, title="UT SELL", location=location.abovebar, color=color.red, style=shape.circle, size=size.large, text="UT SELL")

// LABELS
if finalBuy
    label.new(bar_index, low, "BUY\nSL: " + str.tostring(slBuy) + "\nTP: " + str.tostring(tpBuy), style=label.style_label_up, color=color.green, textcolor=color.white)

if finalSell
    label.new(bar_index, high, "SELL\nSL: " + str.tostring(slSell) + "\nTP: " + str.tostring(tpSell), style=label.style_label_down, color=color.red, textcolor=color.white)

// ALERTS
alertcondition(finalBuy, title="BUY ALERT", message="XAUUSD BUY SIGNAL")
alertcondition(finalSell, title="SELL ALERT", message="XAUUSD SELL SIGNAL")
````
