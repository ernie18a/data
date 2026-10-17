# Ema cross alert 

- url: https://www.tradingview.com/script/bNL8mUMd-Ema-cross-alert/
- type: indicator
- pine_id: PUB;zFSGXK6UALR8n3kbkVKa79OJvV5uVr8Z
- version: 1.0

## Description

ALERT VERSION

link to strategy :  https://www.tradingview.com/script/hMied5Zb-Ema-cross-strat-Turtle-Trading/

## Source Code

````pine
//@version=3
//
study(title="Ema cross alert", overlay=true)
resCustom = input(title="EMA Timeframe", type=resolution, defval="240" )
source = close,
len2 = input(21, minval=1, title="EMA1")
len3 = input(10, minval=1, title="EMA2")
ema2 = security(tickerid,resCustom,ema(source,len2), lookahead=barmerge.lookahead_off)
ema3 = security(tickerid,resCustom,ema(source,len3),  lookahead=barmerge.lookahead_off)


mylong = crossover(ema3, ema2)
myshort = crossunder(ema3,ema2)

last_long = na
last_short = na
last_long := mylong ? time : nz(last_long[1])
last_short := myshort ? time : nz(last_short[1])

in_long = last_long > last_short ? 2 : 0
in_short = last_short > last_long ? 2 : 0


condlongx =   in_long
condlong = crossover(condlongx, 1.9)
condlongclose = crossunder(condlongx, 1.9)

condshortx =  in_short
condshort = crossover(condshortx, 1.9)
condshortclose = crossover(condshortx, 1.9)


alertcondition(condlong,"Long / Buy")
alertcondition(condshort,"Short / Sell")


plotshape(condlong ,title="Long",color=green,location=location.belowbar,style=shape.diamond, size=size.small, offset=1)
plotshape(condshort ,title="Short",color=red,style=shape.diamond,size=size.small, offset=1)


plot(ema2,"Ema 2", style=line, linewidth=2, color=red)
plot(ema3,"Ema 3", style=line, linewidth=2, color=blue)
````
