# Pivot Point SuperTrend [Backtest]

- url: https://www.tradingview.com/script/DwdC6FT4-Pivot-Point-SuperTrend-Backtest/
- type: strategy
- pine_id: PUB;Yl6GXymMoORyI3fvTknuzaUVACwBwuYp
- version: 3.0

## Description

[b]Hello All,[/b]

This is backtesting result of following indicator/strategy. I didn't work on adding other indicators. maybe in the future I can try to combine this with other indicators.

You can visit following link to see [b]"Pivot Point SuperTrend"[/b]. by using this backtesting tool, you can test&find better options
https://www.tradingview.com/script/L0AIiLvH-Pivot-Point-Supertrend/


There is option [b]"Use Center Line to Close Entry for 50%"[/b]. by default it's not enabled. if you enable this option, pivot point center line may push you to close your entry for 50% (can be used as early stoploss/take profit line if you think it's risky)
https://www.tradingview.com/x/4D2q47Zz/


[b]Enjoy![/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue

//@version=4
strategy("Pivot Point SuperTrend [Backtest]", overlay = true)
prd = input(defval = 2, title="Pivot Point Period", minval = 1, maxval = 50)
Factor=input(defval = 3, title = "ATR Factor", minval = 1, step = 0.1)
Pd=input(defval = 10, title = "ATR Period", minval=1)
minrateu = input(defval = 1.0, title="Min profit Rate if Center Line Used", minval = 0)
usecenter = input(defval = false, title="Use Center Line to Close Entry for 50%")
showpivot = input(defval = false, title="Show Pivot Points")
showcl = input(defval = false, title="Show PP Center Line")
onlylong = input(defval = false, title="Enter Only Long Position")
float minrate = minrateu / 100

float ph = na
float pl = na
ph := pivothigh(prd, prd)
pl := pivotlow(prd, prd)

plotshape(ph and showpivot, text="H",  style=shape.labeldown, color=na, textcolor=color.red, location=location.abovebar, offset = -prd)
plotshape(pl and showpivot, text="L",  style=shape.labeldown, color=na, textcolor=color.lime, location=location.belowbar, offset = -prd)

float center = na
center := center[1]
float lastpp = ph ? ph : pl ? pl : na
if lastpp
    if na(center)
        center := lastpp
    else
        center := (center * 2 + lastpp) / 3

Up = center - (Factor * atr(Pd))
Dn = center + (Factor * atr(Pd))

float TUp = na
float TDown = na
Trend = 0
TUp := close[1] > TUp[1] ? max(Up, TUp[1]) : Up
TDown := close[1] < TDown[1] ? min(Dn, TDown[1]) : Dn
Trend := close > TDown[1] ? 1: close < TUp[1]? -1: nz(Trend[1], 1)
Trailingsl = Trend == 1 ? TUp : TDown

linecolor = Trend == 1 and nz(Trend[1]) == 1 ? color.lime : Trend == -1 and nz(Trend[1]) == -1 ? color.red : na
plot(Trailingsl, color = linecolor ,  linewidth = 2, title = "PP SuperTrend")

plot(showcl ? center : na, color = showcl ? center < hl2 ? color.blue : color.red : na)

bsignal = Trend == 1 and Trend[1] == -1
ssignal = Trend == -1 and Trend[1] == 1

halfexited = false
halfexited := nz(halfexited[1], false)
if change(Trend)
    strategy.close_all()


    
if bsignal
    strategy.entry("Buy", true, comment = "Buy")
if ssignal and not onlylong
    strategy.entry("Sell", false, comment = "Sell")

cpsize = change(strategy.position_size)
if change(strategy.position_size)
    if cpsize > 0 and strategy.position_size > 0 or cpsize< 0 and strategy.position_size < 0
        halfexited := false
    
if strategy.position_size > 0 and center > hl2 and usecenter and not halfexited and close > strategy.position_avg_price * (1 + minrate)
    strategy.close("Buy", qty_percent = 50, comment = "close buy for 50%")
    halfexited := true
if strategy.position_size < 0 and center < hl2 and usecenter and not halfexited and close < strategy.position_avg_price * (1 + minrate)
    strategy.close("Sell", qty_percent = 50, comment = "close sell for 50%")
    halfexited := true
````
