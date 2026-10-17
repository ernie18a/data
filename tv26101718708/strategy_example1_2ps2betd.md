# Strategy example1

- url: https://www.tradingview.com/script/2PS2BETd-Strategy-example1/
- type: strategy
- pine_id: PUB;Ek4Y3UFflRw7vSaBRGnNm6NGpgjb68cn
- version: 1.0

## Description

There is nothing special in this strategy , the only reason why its work becouse the take profit and the stop loss 
I put this example just for teaching 
by twiking the model to buy and sell allot we get fantastic results but the question is it true results or not?
so the avreage buy and sell here is about 8 bars (x30 min ) so it buy and sell every 4 hours which is not so bad 
on the other hand if we put commission then we will see the % of win will go down as well as the winning are not so much related to the model but rather to the take profit 
many startegy which are consider failure by this tweek will be looking as victorious one . the only question is what the reality when we try to make take profit and stop loss by this way?
what you think?

## Source Code

````pine

//@version=3
strategy(title="Strategy example1", shorttitle="example1",overlay=true, calc_on_order_fills=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, overlay=false)

trackprice = input(title='Track Price', type=bool, defval=false)
length1 = input(title='Support / Resistance length:', type=integer, defval=20)
top1 = valuewhen(high >= highest(high, length1), high, 0)
bot1 = valuewhen(low <= lowest(low, length1), low, 0)
plot(top1, color=top1 != top1[1] ? na : black, linewidth=1, offset=0, trackprice=trackprice, transp=0)
plot(bot1, color=bot1 != bot1[1] ? na : green, linewidth=1, offset=0, trackprice=trackprice, transp=0)
barlength = input(title='Bar length:', type=integer, defval=20)

length = input(title="Length", type=integer, defval=14, minval=1)
src = input(title="Source", type=source, defval=close)

factor = 0.0
slope = 0.0

for i = 1 to length
    factor := 1 + 2 * (i - 1)
    slope := slope + (src[i - 1]) * (length - factor) / 2

shmma = sma(src, length) + (6 * slope) / ((length + 1) * length)

newtop = shmma >= highest(shmma, barlength)
newbot = shmma <= lowest(shmma, barlength)
top = valuewhen(newtop, shmma, 0)
bot = valuewhen(newbot, shmma, 0)
plot(top, color=top != top[1] ? na : red, linewidth=1, offset=0, transp=0)
plot(bot, color=bot != bot[1] ? na : lime, linewidth=1, offset=0, transp=0)
//
mode = input('ATR', options=["ATR", "Traditional"])
modeValue = input(14.000, type=float)
bricksize = na
if mode == "ATR"
    bricksize := atr(round(modeValue))
if mode == "Traditional"
    bricksize := modeValue

showOverlay = input(false)

ropen = na
propen = nz(ropen[1])
ropen := close > propen+bricksize or high > propen+bricksize ? propen+bricksize : close < propen-bricksize or low < propen-bricksize ? propen-bricksize : propen

rclose = na
rclose := ropen > propen ? ropen-bricksize : ropen < propen ? ropen+bricksize : nz(rclose[1])
direction = na
direction := ropen > propen ? 1 : ropen < propen ? -1 : nz(direction[1])

rc = direction == 1 ? green : direction == -1 ? maroon : na

p00 = plot(not showOverlay ? na : ropen, style=cross, color=rc, linewidth=3)
p01 = plot(not showOverlay ? na : rclose, style=circles, color=gray, linewidth=2)

fill(p00, p01, color=gray, transp=75)
//
tf=input(1440)

lookBack = isintraday and interval >= 1 ? tf/interval * 7 : isintraday and interval < 60 ? 60/interval * 24 * 7 : 7

High = highest(high, lookBack) 
Low = lowest(low, lookBack) 

highRatio = ((close-Low) / (High-Low)) * 500
lowRatio = -((High-close) / (High-Low)) * 500

//highColor = High > High[1] ? #006400 : #90EE90 
//lowRatio1 = Low < Low[1] ? #8B0000 : #EDAFAF
//h=High > High[1]
//l=Low < Low[1]

//
up=crossunder(Low , Low[1]) 
down=crossover(High , High[1]) 
plotshape(down, title= "high channel", location=location.abovebar, color=black, style=shape.arrowup, text= "H")
plotshape(up, title= "low channel", location=location.belowbar, color=black, style=shape.arrowup, text= "L")

// Standard PSAR parameters
start = input(0.03, "PSAR Start")
increment = input(0.02, "PSAR Increment")
maximum = input(0.2, "PSAR Maximum")

psar_perc() => 
    nz(100*(sar(start, increment, maximum)-close)/close)

c=0.0 // variable used to assign current PSAR
p=0.0 // sum of positive PSARs
m=0.0 // sum of negative PSARs
current=security(tickerid, period, psar_perc()), c:=current, p:=p+nz(c>0?c:0), m:=m+nz(c<0?c:0)


psars=-(p+m) // sum of both positive and negative PSARs

len = input(1)

x=sma(psars,len)

// Show the sums of positive and negative PSARs
//plot(-p, "PSARs above price", style=columns, color=red)
//plot(-m, "PSARs under price", style=columns, color=green)
//hline(0, color=black)
input_src         = -p
input_ma_period   = input(50, title="Moving average")
input_max_height  = input(1000, title="Maximum value on left bar")


ma                = sma(input_src, input_ma_period)
normalized = min(input_src / ma * 100, input_max_height * 1)

//plot(input_max_height, transp=100, title="")
//plot(normalized, color=red, style=histogram, title="Sell power", transp=60, linewidth=2)
//
input_src1         = -m
input_ma_period1  = input(50, title="Moving average")
input_max_height1  = input(1000, title="Maximum value on left bar")
ma1                = sma(input_src1, input_ma_period1)
normalized1 = min(input_src1 / ma1 * 100, input_max_height1 * 1)
//plot(normalized1, color=blue, style=histogram, title="Buy power", transp=60, linewidth=2)


//band1 = hline(700, title="Upper Line", linestyle=dashed, linewidth=1, color=red)
//band0 = hline(300, title="Lower Line", linestyle=dashed, linewidth=1, color=green)

// Super Trend 

sLines = input(false, "Show Super-Trend Lines")
Factor1=input(1,type =float, minval=1,maxval = 100)
Factor2=input(2,type =float, minval=1,maxval = 100)
Factor3=input(3,type =float, minval=1,maxval = 100)
Pd1=10 //input(10,minval=1,maxval = 100)
Pd2=10 //input(10,minval=1,maxval = 100)
Pd3=10 //input(10,minval=1,maxval = 100)

// ST1

Up1=hlc3-(Factor1*atr(Pd1))
Up2=hlc3-(Factor2*atr(Pd2))
Up3=hlc3-(Factor3*atr(Pd3))
Dn1=hlc3+(Factor1*atr(Pd1))
Dn2=hlc3+(Factor2*atr(Pd2))
Dn3=hlc3+(Factor3*atr(Pd3))

// ST1.2

TrendUp1=na
TrendUp2=na
TrendUp3=na
TrendUp1:=close[1]>TrendUp1[1]? max(Up1,TrendUp1[1]) : Up1
TrendUp2:=close[1]>TrendUp2[1]? max(Up2,TrendUp2[1]) : Up2
TrendUp3:=close[1]>TrendUp3[1]? max(Up3,TrendUp3[1]) : Up3

TrendDown1=na
TrendDown2=na
TrendDown3=na
TrendDown1:=close[1]<TrendDown1[1]? min(Dn1,TrendDown1[1]) : Dn1
TrendDown2:=close[1]<TrendDown2[1]? min(Dn2,TrendDown2[1]) : Dn2
TrendDown3:=close[1]<TrendDown3[1]? min(Dn3,TrendDown3[1]) : Dn3
 
Trend1 = na
Tsl1 = na
Trend2 = na
Tsl2 = na
Trend3 = na
Tsl3 = na
Trend1 := close[1] > TrendDown1[1] ? 1: close[1] < TrendUp1[1]? -1: nz(Trend1[1],1)
Tsl1 := Trend1==1 ? TrendUp1: TrendDown1
Trend2 := close[1] > TrendDown2[1] ? 1: close[1] < TrendUp2[1]? -1: nz(Trend2[1],1)
Tsl2 := Trend2==1 ? TrendUp2: TrendDown2
Trend3 := close[1] > TrendDown3[1] ? 1: close[1] < TrendUp3[1]? -1: nz(Trend3[1],1)
Tsl3 := Trend3==1 ? TrendUp3: TrendDown3
len1=input(9)
x1=rsi(Tsl2,len1)
pp=x1*10
// Plotting

linecolor = Tsl1 < Tsl2 and Tsl2 < Tsl3 ? red : Tsl1 > Tsl2 and Tsl2 > Tsl3 ? lime : orange
//plot(pp , color = linecolor , style = line , linewidth = 3 ,title = "SuperTrend")
//tgreen=crossover(close, Tsl2)
//tred=crossunder(close, Tsl2) 
down1=crossunder(x,0) and pp>400
//plotchar(tgreen, title="buy", char='b', location=location.bottom, color=black, transp=0, offset=0,size=size.tiny)
//plotchar(tred, title="sell", char='s', location=location.top, color=black, transp=0, offset=0,size=size.tiny)
//plotchar(down, title="sell1", char='S', location=location.top, color=red, transp=0, offset=0,size=size.tiny)
//
// Conditions

longCond = na
shortCond = na
longCond := crossover(close, Tsl2) 
shortCond := crossunder(close,Tsl2) or down or down1


TP = input(500) * 10
SL = input(500) * 10
TS = input(30) * 10
TO = input(0) * 10
CQ = 100

TPP = (TP > 0) ? TP : na
SLP = (SL > 0) ? SL : na
TSP = (TS > 0) ? TS : na
TOP = (TO > 0) ? TO : na

longCondition = crossover(close, Tsl2) 
if (longCondition)
    strategy.entry("Long", strategy.long)


shortCondition =  crossunder(close,Tsl2) or down or down1
if (shortCondition)
    strategy.entry("Short", strategy.short)

strategy.exit("Close Short", "Short", qty_percent=CQ, profit=TPP, loss=SLP, trail_points=TSP, trail_offset=TOP)
strategy.exit("Close Long", "Long", qty_percent=CQ, profit=TPP, loss=SLP, trail_points=TSP, trail_offset=TOP)
````
