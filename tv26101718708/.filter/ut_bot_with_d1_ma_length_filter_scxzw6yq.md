# UT Bot with D1 MA Length Filter

- url: https://www.tradingview.com/script/SCxZW6YQ-UT-Bot-with-D1-MA-Length-Filter/
- type: indicator
- pine_id: PUB;a69de5c382d34a20b2b6a4503af45e82
- version: 1.0

## Description

This indicator uses a daily moving average as a higher-timeframe trend filter and ATR-based UT-style signals for entries on the current chart timeframe. The daily MA period is adjustable, so the user can adapt the trend filter to different trading styles, while the ATR component helps generate entries based on current-timeframe volatility. For more frequent entries, try setting the Key Value to 1 and the ATR Period to 46.

## Source Code

````pine
//@version=6
indicator("UT Bot with D1 MA Length Filter", overlay=true)

// Inputs
keyValue   = input.float(3.0, "Key Value", step=0.5)
atrPeriod  = input.int(10, "ATR Period", minval=1)
maLength   = input.int(30, "D1 MA Length", minval=1)
showDailyMA = input.bool(true, "Show D1 MA")
colorBars   = input.bool(true, "Color Bars by Filter")

src = close

// ATR
xATR  = ta.atr(atrPeriod)
nLoss = keyValue * xATR

// UT trailing stop
var float xATRTrailingStop = na
prevStop = nz(xATRTrailingStop[1], 0.0)

if src > prevStop and src[1] > prevStop
    xATRTrailingStop := math.max(prevStop, src - nLoss)
else if src < prevStop and src[1] < prevStop
    xATRTrailingStop := math.min(prevStop, src + nLoss)
else
    xATRTrailingStop := src > prevStop ? src - nLoss : src + nLoss

// Trend state
var int pos = 0
prevPos = nz(pos[1], 0)

if src[1] < prevStop and src > prevStop
    pos := 1
else if src[1] > prevStop and src < prevStop
    pos := -1
else
    pos := prevPos

xcolor = pos == -1 ? color.red : pos == 1 ? color.green : color.blue
plot(xATRTrailingStop, color=xcolor, title="UT Trailing Stop", linewidth=2)

// Raw UT signals
buy  = ta.crossover(src, xATRTrailingStop)
sell = ta.crossunder(src, xATRTrailingStop)

// Daily MA filter
dClose = request.security(syminfo.tickerid, "D", close)
dMA    = request.security(syminfo.tickerid, "D", ta.sma(close, maLength))

allowLong  = dClose > dMA
allowShort = dClose < dMA

// Filtered signals
buyFiltered  = buy and allowLong
sellFiltered = sell and allowShort

// Plot daily MA
plot(showDailyMA ? dMA : na, title="D1 MA", color=color.yellow, linewidth=2)

// Signals
plotshape(buyFiltered, title="Buy", text="Buy", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(sellFiltered, title="Sell", text="Sell", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

// Blocked signals
plotshape(buy and not allowLong, title="Blocked Buy", text="x", style=shape.circle, location=location.belowbar, color=color.gray, textcolor=color.white, size=size.tiny)
plotshape(sell and not allowShort, title="Blocked Sell", text="x", style=shape.circle, location=location.abovebar, color=color.gray, textcolor=color.white, size=size.tiny)

// Bar colors
barcolor(colorBars ? (allowLong ? color.green : allowShort ? color.red : color.gray) : na)

// Alerts
alertcondition(buyFiltered, title="UT Buy Filtered", message="UT Bot Buy + D1 MA filter")
alertcondition(sellFiltered, title="UT Sell Filtered", message="UT Bot Sell + D1 MA filter")
````
