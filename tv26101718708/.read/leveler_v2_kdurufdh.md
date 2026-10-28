# Leveler v2

- url: https://www.tradingview.com/script/KduRuFdH-Leveler-v2/
- type: strategy
- pine_id: PUB;5sWdaODdCohrYe2tz5QgX51r6mwBBvzs
- version: 1.0

## Description

To be use in short time frame (1min or 3min)

## Source Code

````pine
strategy(title='leveltrd',precision=8,overlay=true,initial_capital=1000,default_qty_type=strategy.percent_of_equity, default_qty_value=100,commission_type=strategy.commission.percent,commission_value=0.15)
tf = input(title='Timeframe:', defval='60', type=string)
src = input(title='Source', type=source, defval=close)
multiplier = input(title='Range Multiplier:', type=float, defval=1, step=0.01)

catr(_m) => (cum(tr)/(n+1))*_m

d_open = security(tickerid, tf, round(src/catr(1))*catr(1))
d_high = security(tickerid, tf, round(1+src/catr(1))*catr(1))
d_low = security(tickerid, tf, round(src/catr(1)-1)*catr(1))

d_open_buy = d_open+catr(multiplier)
d_open_sel = d_open-catr(multiplier)
d_high_buy = d_high+catr(multiplier)
d_high_sel = d_high-catr(multiplier)
d_low_buy = d_low+catr(multiplier)
d_low_sel = d_low-catr(multiplier)

//dob = plot(title='d_open_buy', series=d_open_buy, style=circles, color=lime)
//dos = plot(title='d_open_sel', series=d_open_sel, style=circles, color=red)
//dhb = plot(title='d_high_buy', series=d_high_buy, style=circles, color=lime)
//dhs = plot(title='d_high_sel', series=d_high_sel, style=circles, color=red)
//dlb = plot(title='d_low_buy', series=d_low_buy, style=circles, color=lime)
//dls = plot(title='d_low_sel', series=d_low_sel, style=circles, color=red)


//fill(title='mf', plot1=dob, plot2=dos, color=orange, transp=75)
//fill(title='hf', plot1=dhb, plot2=dhs, color=green, transp=75)
//fill(title='lf', plot1=dlb, plot2=dls, color=red, transp=75)

//plot(title='m', series=d_open, style=circles, color=orange)
//plot(title='h', series=d_high, style=circles, color=green)
//plot(title='l', series=d_low, style=circles, color=red)

Factor=input(3, minval=1,maxval = 100)
Pd=input(18, minval=1,maxval = 100)
shortallowed=input(true)
longallowed=input(true)
Up=hl2-(Factor*atr(Pd))
Dn=hl2+(Factor*atr(Pd))


TrendUp=d_low_buy[1]>TrendUp[1]? max(Up,TrendUp[1]) : Up
TrendDown=d_low_buy[1]<TrendDown[1]? min(Dn,TrendDown[1]) : Dn


Trend = d_low_buy > TrendDown[1] ? 1: d_low_buy< TrendUp[1]? -1: nz(Trend[1],1)
Tsl = Trend==1? TrendUp: TrendDown

plotshape(d_open_buy < Tsl , style=shape.xcross,color=green)
plotshape(d_low_buy < Tsl , style=shape.xcross,color=green)
plotshape(d_high_buy < Tsl , style=shape.xcross,color=green)


plotshape(d_high_sel < Tsl , style=shape.xcross,color=red)
plotshape(d_open_sel < Tsl , style=shape.xcross,color=red)
plotshape(d_low_sel < Tsl , style=shape.xcross,color=red)



linecolor = Trend == 1 ? green : red

plot(Tsl, color = linecolor , style = cross ,title = "SuperTrend")

//plotshape(cross(close,Tsl) and close>Tsl , "Up Arrow", shape.triangleup,location.belowbar,green,0,0)
//plotshape(cross(Tsl,close) and close<Tsl , "Down Arrow", shape.triangledown , location.abovebar, red,0,0)

//plotarrow(Trend == 1 and Trend[1] == -1  ? Trend : na, title="Up Entry Arrow", colorup=lime, maxheight=60, minheight=50, transp=0)
//plotarrow(Trend == -1 and Trend[1] == 1  ? Trend : na, title="Down Entry Arrow", colordown=red, maxheight=60, minheight=50, transp=0)


DownModeContinue = Trend == -1 and TrendDown
UpModeContinue = Trend == 1 and TrendUp

strategy.entry("l0", strategy.long, when = crossover(low,d_low_sel) and Trend == 1)
strategy.close("l0", when = crossover(close,d_open_buy) and UpModeContinue == false)

strategy.entry("short", strategy.short, when = crossunder(high,d_high) and Trend == -1)
strategy.close("short", when = crossover(low,d_open) and DownModeContinue == false)
````
