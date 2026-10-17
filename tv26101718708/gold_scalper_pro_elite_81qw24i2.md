# Gold Scalper Pro Elite

- url: https://www.tradingview.com/script/81qW24I2/
- type: indicator
- pine_id: PUB;635e640d478f4542b19a6db3df52431e
- version: 1.0

## Description

موشر يعتمد على بوك ماب ويعتمد على اشاره دخول بلستو قليل

## Source Code

````pine
//@version=5
indicator("Gold Scalper Pro Elite", overlay=true)

//========== الإعدادات ==========
emaPeriod = input.int(50, "EMA")
volLen = input.int(10, "Volume Length")
volMult = input.float(1.5, "Volume Multiplier")
rr = input.float(2.0, "Risk Reward")

//========== الحسابات ==========
ema = ta.ema(close, emaPeriod)
avgVol = ta.sma(volume, volLen)

// مناطق سيولة (High/Low سابق)
liqHigh = ta.highest(high, 20)
liqLow = ta.lowest(low, 20)

//========== شروط قوية ==========
strongBuy =
 close > ema and
 close > open and
 volume > avgVol * volMult and
 low <= liqLow

strongSell =
 close < ema and
 close < open and
 volume > avgVol * volMult and
 high >= liqHigh

//========== إشارات ==========
plotshape(strongBuy, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(strongSell, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

//========== هدف وستوب ==========
buySL = low
buyTP = close + (close - buySL) * rr

sellSL = high
sellTP = close - (sellSL - close) * rr

// رسم الهدف والاستوب
plot(strongBuy ? buyTP : na, color=color.green, style=plot.style_linebr)
plot(strongBuy ? buySL : na, color=color.red, style=plot.style_linebr)

plot(strongSell ? sellTP : na, color=color.green, style=plot.style_linebr)
plot(strongSell ? sellSL : na, color=color.red, style=plot.style_linebr)

//========== تنبيهات احتراف ==========
alertcondition(strongBuy, title="BUY SIGNAL", message="BUY GOLD | TP & SL READY")
alertcondition(strongSell, title="SELL SIGNAL", message="SELL GOLD | TP & SL READY")
````
