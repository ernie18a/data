# EMA 8/20 Cross 1min 

- url: https://www.tradingview.com/script/C8PPpcB2-EMA-8-20-Cross-1min/
- type: indicator
- pine_id: PUB;40bb53040cac444db1887960ad65d21d
- version: 1.0

## Description

EMA 8/20 Cross Alert – 1 Minute
This indicator plots the 8 EMA and 20 EMA pulled from the 1-minute timeframe directly onto your chart, regardless of what timeframe you're currently viewing. It detects and visually marks every crossover event in real time.
A green label appears below the bar when the 8 EMA crosses above the 20 EMA, signaling bullish momentum. A red label appears above the bar when the 8 EMA crosses below the 20 EMA, signaling bearish momentum.
Built-in alerts let you know the moment a cross occurs so you never miss an entry signal, even when you're away from the screen. Compatible with any ticker.

## Source Code

````pine
//@version=6
indicator(title="EMA 8/20 Cross Alert 1m", shorttitle="EMA 8/20 1m", overlay=true)

// Inputs
src = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none)

// 1m EMA Calculations
ema8_1  = request.security(syminfo.tickerid, "1", ta.ema(src, 8))
ema20_1 = request.security(syminfo.tickerid, "1", ta.ema(src, 20))

// 1m Cross Detection
crossUp_1   = ta.crossover(ema8_1,  ema20_1)
crossDown_1 = ta.crossunder(ema8_1, ema20_1)

// Plots — 1m
plot(ema8_1,  title="EMA 8  (1m)", color=color.new(color.aqua,   0), linewidth=1, offset=offset)
plot(ema20_1, title="EMA 20 (1m)", color=color.new(color.orange, 0), linewidth=1, offset=offset)

// 1m Shape markers
plotshape(crossUp_1,   title="1m Bullish Cross", location=location.belowbar, style=shape.labelup,   color=color.green, text="1m Bull", textcolor=color.white, size=size.small)
plotshape(crossDown_1, title="1m Bearish Cross", location=location.abovebar, style=shape.labeldown, color=color.red,   text="1m Bear", textcolor=color.white, size=size.small)

// Alerts — 1m
alertcondition(crossUp_1,   title="1m: 8 EMA crossed ABOVE 20 EMA", message="🟢 [1m] EMA 8 crossed ABOVE EMA 20 — Bullish!")
alertcondition(crossDown_1, title="1m: 8 EMA crossed BELOW 20 EMA", message="🔴 [1m] EMA 8 crossed BELOW EMA 20 — Bearish!")

// Alert — Any
alertcondition(crossUp_1 or crossDown_1, title="Any 1m EMA Event", message="⚡ [1m] EMA 8/20 cross detected!")
````
