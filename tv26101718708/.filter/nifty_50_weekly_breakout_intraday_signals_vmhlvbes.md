# Nifty 50 Weekly Breakout Intraday Signals

- url: https://www.tradingview.com/script/vmhLvBeS-Nifty-50-Weekly-Breakout-Intraday-Signals/
- type: indicator
- pine_id: PUB;0580b6343e8043a38d5b57fedcd81678
- version: 1.0

## Description

Nifty 50 weekly breakout Intraday signals with TP 1-1.5% & SL-0.75% using weekly breakout strategy & PWL & PWH

## Source Code

````pine
//@version=6
indicator("Nifty 50 Weekly Breakout Intraday Signals", overlay=true)

tp1 = input.float(1.0, "Target 1 %") / 100
tp2 = input.float(1.5, "Target 2 %") / 100
sl  = input.float(0.75, "Stop Loss %") / 100

pwh = request.security(syminfo.tickerid, "W", high[1])
pwl = request.security(syminfo.tickerid, "W", low[1])

plot(pwh, "Previous Week High", color.green, 2)
plot(pwl, "Previous Week Low", color.red, 2)

buySignal  = ta.crossover(close, pwh)
sellSignal = ta.crossunder(close, pwl)

plotshape(buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white)
plotshape(sellSignal, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white)

if buySignal
    entry = close
    stop  = entry * (1 - sl)
    t1    = entry * (1 + tp1)
    t2    = entry * (1 + tp2)
    label.new(bar_index, low, "BUY\nEntry: " + str.tostring(entry) + "\nSL: " + str.tostring(stop) + "\nTP1: " + str.tostring(t1) + "\nTP2: " + str.tostring(t2), style=label.style_label_up, color=color.green, textcolor=color.white)

if sellSignal
    entry = close
    stop  = entry * (1 + sl)
    t1    = entry * (1 - tp1)
    t2    = entry * (1 - tp2)
    label.new(bar_index, high, "SELL\nEntry: " + str.tostring(entry) + "\nSL: " + str.tostring(stop) + "\nTP1: " + str.tostring(t1) + "\nTP2: " + str.tostring(t2), style=label.style_label_down, color=color.red, textcolor=color.white)

alertcondition(buySignal, title="BUY Alert", message="BUY: Previous Week High breakout")
alertcondition(sellSignal, title="SELL Alert", message="SELL: Previous Week Low breakdown")
````
