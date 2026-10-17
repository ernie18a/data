# Pivot Reversal Strategy with Alerts - Ramesh

- url: https://www.tradingview.com/script/RjR2mPDp-Pivot-Reversal-Strategy-with-Alerts-Ramesh/
- type: indicator
- pine_id: PUB;38K2uPiQqHHvBhnoRrTrUUxwZNAa9kjr
- version: 6.0

## Description

Maximize the profit with just one script

## Source Code

````pine
//@version=4
study("Pivot Reversal Strategy New - Alerts - Ramesh", overlay=true)

// === INPUT VARIABLES ===
leftBars = input(6)
rightBars = input(5)

swh = pivothigh(leftBars, rightBars)
swl = pivotlow(leftBars, rightBars)

swh_cond = not na(swh)

hprice = 0.0
hprice := swh_cond ? swh : hprice[1]

le = false
//le := swh_cond ? true : (le[1] and high > hprice  ? false : le[1])
le := high > hprice  ? true : false

swl_cond = not na(swl)

lprice = 0.0
lprice := swl_cond ? swl : lprice[1]

se = false
//se := swl_cond ? true : (se[1] and low < lprice  ? false : se[1])
se :=  low < lprice  ? true : false

// Filter out signals if opposite signal is also on
se_filtered = se and not le
le_filtered = le and not se

// Filter consecutive entries 
prev = 0
prev := se_filtered ? 1 : le_filtered ? -1 : prev[1]

se_final = se_filtered and prev[1] == -1
le_final = le_filtered and prev[1] == 1

plotshape(le_final, color=color.green,title="Long Entry", text="BUY", style=shape.triangleup, location=location.belowbar,size=size.tiny,transp=0)
plotshape(se_final, color=color.red, title="Short Entry" ,text="SELL", style=shape.triangledown, location=location.abovebar,size=size.tiny,transp=0)

UpTrendPrice = le_final == 1 ? hprice : na
DownTrendPrice = se_final == 1 ? lprice : na

plotchar(UpTrendPrice,char='—',title="High Alert Price",color=color.lime,location=location.absolute,size=size.tiny,transp=0)
plotchar(DownTrendPrice,char='—',title="Low Alert Price",color=color.maroon,location=location.absolute,size=size.tiny,transp=0)
plot(hprice,title="High Price Line", color=color.green)
plot(lprice,title="Low Price Line", color=color.red)
//plotshape(PreUpTrendPrice,color =orange,style=circles,size=size.tiny)
//plotshape(PreDownTrendPrice,color =blue,style=circles,size=size.tiny)

alertcondition(le_final, "Long-Buy", "")
alertcondition(se_final, "Short-Sell", "")
````
