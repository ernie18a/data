# GrowWithCare Multi TF

- url: https://www.tradingview.com/script/R5gsuQ4K-GrowWithCare-Multi-TF/
- type: indicator
- pine_id: PUB;633fc988b85543a989cb5caa8b3d6eb6
- version: 1.0

## Description

GrowWithCare Multi TF Dashboard this is good indicetor to trand

## Source Code

````pine
//@version=5
indicator("GrowWithCare Multi TF Dashboard", overlay=true)

// EMA LENGTH
emaLen = input.int(48, title="EMA Length")

// TIMEFRAMES
tf1 = input.timeframe("5", title="5M TF")
tf2 = input.timeframe("15", title="15M TF")
tf3 = input.timeframe("60", title="1H TF")
tf4 = input.timeframe("240", title="4H TF")
tf5 = input.timeframe("D", title="1D TF")
tf6 = input.timeframe("W", title="1W TF")
tf7 = input.timeframe("M", title="1M TF")

// ADX
adxLen = input.int(14, title="ADX Length")

[diplus, diminus, adxValue] = ta.dmi(adxLen, adxLen)

// EMA VALUES
emaHigh5 = request.security(syminfo.tickerid, tf1, ta.ema(high, emaLen))
emaLow5 = request.security(syminfo.tickerid, tf1, ta.ema(low, emaLen))

emaHigh15 = request.security(syminfo.tickerid, tf2, ta.ema(high, emaLen))
emaLow15 = request.security(syminfo.tickerid, tf2, ta.ema(low, emaLen))

emaHigh1H = request.security(syminfo.tickerid, tf3, ta.ema(high, emaLen))
emaLow1H = request.security(syminfo.tickerid, tf3, ta.ema(low, emaLen))

emaHigh4H = request.security(syminfo.tickerid, tf4, ta.ema(high, emaLen))
emaLow4H = request.security(syminfo.tickerid, tf4, ta.ema(low, emaLen))

emaHigh1D = request.security(syminfo.tickerid, tf5, ta.ema(high, emaLen))
emaLow1D = request.security(syminfo.tickerid, tf5, ta.ema(low, emaLen))

emaHigh1W = request.security(syminfo.tickerid, tf6, ta.ema(high, emaLen))
emaLow1W = request.security(syminfo.tickerid, tf6, ta.ema(low, emaLen))

emaHigh1M = request.security(syminfo.tickerid, tf7, ta.ema(high, emaLen))
emaLow1M = request.security(syminfo.tickerid, tf7, ta.ema(low, emaLen))

// TREND STATUS
trend5 = close > emaHigh5 ? "BULL" : close < emaLow5 ? "BEAR" : "NEUTRAL"
trend15 = close > emaHigh15 ? "BULL" : close < emaLow15 ? "BEAR" : "NEUTRAL"
trend1H = close > emaHigh1H ? "BULL" : close < emaLow1H ? "BEAR" : "NEUTRAL"
trend4H = close > emaHigh4H ? "BULL" : close < emaLow4H ? "BEAR" : "NEUTRAL"
trend1D = close > emaHigh1D ? "BULL" : close < emaLow1D ? "BEAR" : "NEUTRAL"
trend1W = close > emaHigh1W ? "BULL" : close < emaLow1W ? "BEAR" : "NEUTRAL"
trend1M = close > emaHigh1M ? "BULL" : close < emaLow1M ? "BEAR" : "NEUTRAL"

// MOVE %
move5 = ((close - emaHigh5) / emaHigh5) * 100
move15 = ((close - emaHigh15) / emaHigh15) * 100
move1H = ((close - emaHigh1H) / emaHigh1H) * 100
move4H = ((close - emaHigh4H) / emaHigh4H) * 100
move1D = ((close - emaHigh1D) / emaHigh1D) * 100
move1W = ((close - emaHigh1W) / emaHigh1W) * 100
move1M = ((close - emaHigh1M) / emaHigh1M) * 100

// TABLE
var table dashboard = table.new(position.bottom_left, 4, 9, border_width=1)

// HEADER
if barstate.islast

    table.cell(dashboard, 0, 0, "TF", bgcolor=color.gray)
    table.cell(dashboard, 1, 0, "TREND", bgcolor=color.gray)
    table.cell(dashboard, 2, 0, "MOVE %", bgcolor=color.gray)
    table.cell(dashboard, 3, 0, "SL", bgcolor=color.gray)

    table.cell(dashboard, 0, 1, "5M")
    table.cell(dashboard, 1, 1, trend5, bgcolor=trend5=="BULL"?color.green:trend5=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 1, str.tostring(move5, "#.##"))
    table.cell(dashboard, 3, 1, str.tostring(emaLow5))

    table.cell(dashboard, 0, 2, "15M")
    table.cell(dashboard, 1, 2, trend15, bgcolor=trend15=="BULL"?color.green:trend15=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 2, str.tostring(move15, "#.##"))
    table.cell(dashboard, 3, 2, str.tostring(emaLow15))

    table.cell(dashboard, 0, 3, "1H")
    table.cell(dashboard, 1, 3, trend1H, bgcolor=trend1H=="BULL"?color.green:trend1H=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 3, str.tostring(move1H, "#.##"))
    table.cell(dashboard, 3, 3, str.tostring(emaLow1H))

    table.cell(dashboard, 0, 4, "4H")
    table.cell(dashboard, 1, 4, trend4H, bgcolor=trend4H=="BULL"?color.green:trend4H=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 4, str.tostring(move4H, "#.##"))
    table.cell(dashboard, 3, 4, str.tostring(emaLow4H))

    table.cell(dashboard, 0, 5, "1D")
    table.cell(dashboard, 1, 5, trend1D, bgcolor=trend1D=="BULL"?color.green:trend1D=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 5, str.tostring(move1D, "#.##"))
    table.cell(dashboard, 3, 5, str.tostring(emaLow1D))

    table.cell(dashboard, 0, 6, "1W")
    table.cell(dashboard, 1, 6, trend1W, bgcolor=trend1W=="BULL"?color.green:trend1W=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 6, str.tostring(move1W, "#.##"))
    table.cell(dashboard, 3, 6, str.tostring(emaLow1W))

    table.cell(dashboard, 0, 7, "1M")
    table.cell(dashboard, 1, 7, trend1M, bgcolor=trend1M=="BULL"?color.green:trend1M=="BEAR"?color.red:color.yellow)
    table.cell(dashboard, 2, 7, str.tostring(move1M, "#.##"))
    table.cell(dashboard, 3, 7, str.tostring(emaLow1M))

    table.cell(dashboard, 0, 8, "ADX")
    table.cell(dashboard, 1, 8, str.tostring(adxValue, "#.##"), bgcolor=adxValue>20?color.green:color.red)
````
