# Al AMIR TRADING GOLD PRECISION

- url: https://www.tradingview.com/script/xjtenXMf/
- type: indicator
- pine_id: PUB;b33ff1f48c674f0bbd78f4891ac70147
- version: 1.0

## Description

مؤشر دقيق جدا مبرمج على قراءة زخم و تقلب السوق

لافضل النتائج الرجاء استخدام فريم 5 , 10 دقائق على الذهب

## Source Code

````pine
//@version=6
indicator(title="Al AMIR TRADING GOLD PRECISION", overlay = true)

// Inputs
a = input.float(1.0,  title = "Key Vaule. 'This changes the sensitivity'")
c = input.int(10,     title = "ATR Period")
h = input.bool(false, title = "Signals from Heikin Ashi Candles")

xATR  = ta.atr(c)
nLoss = a * xATR

src = h ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead = barmerge.lookahead_off) : close

var float xATRTrailingStop = 0.0
xATRTrailingStop := (src > nz(xATRTrailingStop[1], 0.0) and src[1] > nz(xATRTrailingStop[1], 0.0)) ? math.max(nz(xATRTrailingStop[1]), src - nLoss) :
   (src < nz(xATRTrailingStop[1], 0.0) and src[1] < nz(xATRTrailingStop[1], 0.0)) ? math.min(nz(xATRTrailingStop[1]), src + nLoss) :
   (src > nz(xATRTrailingStop[1], 0.0)) ? src - nLoss : src + nLoss
 
var int pos = 0   
pos := (src[1] < nz(xATRTrailingStop[1], 0.0) and src > nz(xATRTrailingStop[1], 0.0)) ? 1 :
   (src[1] > nz(xATRTrailingStop[1], 0.0) and src < nz(xATRTrailingStop[1], 0.0)) ? -1 : nz(pos[1], 0) 
   
xcolor = pos == -1 ? color.red : pos == 1 ? color.green : color.blue 

ema   = ta.ema(src, 1)
above = ta.crossover(ema, xATRTrailingStop)
below = ta.crossover(xATRTrailingStop, ema)

buy  = src > xATRTrailingStop and above 
sell = src < xATRTrailingStop and below

barbuy  = src > xATRTrailingStop 
barsell = src < xATRTrailingStop 

plotshape(buy,  title = "Buy",  text = 'Buy',  style = shape.labelup,   location = location.belowbar, color = color.green, textcolor = color.white, size = size.tiny)
plotshape(sell, title = "Sell", text = 'Sell', style = shape.labeldown, location = location.abovebar, color = color.red,   textcolor = color.white, size = size.tiny)

barcolor(barbuy  ? color.green : na)
barcolor(barsell ? color.red   : na)

// التنبيهات في الإصدار الجديد يتم ضبطها مباشرة من قائمة التنبيهات بالشارت بعد اختيار المؤشر
````
