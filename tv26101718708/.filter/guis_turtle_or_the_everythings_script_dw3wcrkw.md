# Gui's Turtle or The everythings Script

- url: https://www.tradingview.com/script/DW3wCRKw-Gui-s-Turtle-or-The-everythings-Script/
- type: strategy
- pine_id: PUB;MtpoL4sDMtVHmlJN5HesJl1IYPxnkpSe
- version: 4.0

## Description

This script has a lot of stuff. Its cool.

## Source Code

````pine
//This script has to be used with Heikin Ashi Caddles for the strategy to work well, Thank you to all the ones that have their scripts public so we can make this everything one, The colours and thicknesses have to be altered and messed with
strategy("Gui's Turtle", shorttitle = "Guis Turtles", overlay=true, pyramiding=0, default_qty_value = 10)
transp=input(0)
Numbers=input(true)
SR=input(true)
Barcolor=input(true)
TD = close > close[4] ?nz(TD[1])+1:0
TS = close < close[4] ?nz(TS[1])+1:0

TDUp = TD - valuewhen(TD < TD[1], TD , 1 )
TDDn = TS - valuewhen(TS < TS[1], TS , 1 )
plotshape(Numbers?(TDUp==1?true:na):na,style=shape.triangleup,text="1",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==2?true:na):na,style=shape.triangleup,text="2",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==3?true:na):na,style=shape.triangleup,text="3",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==4?true:na):na,style=shape.triangleup,text="4",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==5?true:na):na,style=shape.triangleup,text="5",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==6?true:na):na,style=shape.triangleup,text="6",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==7?true:na):na,style=shape.triangleup,text="7",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==8?true:na):na,style=shape.triangleup,text="8",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDUp==9?true:na):na,style=shape.triangleup,text="9",color=green,location=location.belowbar,transp=transp)
plotshape(Numbers?(TDDn==1?true:na):na,style=shape.triangledown,text="1",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==2?true:na):na,style=shape.triangledown,text="2",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==3?true:na):na,style=shape.triangledown,text="3",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==4?true:na):na,style=shape.triangledown,text="4",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==5?true:na):na,style=shape.triangledown,text="5",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==6?true:na):na,style=shape.triangledown,text="6",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==7?true:na):na,style=shape.triangledown,text="7",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==8?true:na):na,style=shape.triangledown,text="8",color=red,location=location.abovebar,transp=transp)
plotshape(Numbers?(TDDn==9?true:na):na,style=shape.triangledown,text="9",color=red,location=location.abovebar,transp=transp)
priceflip = barssince(close<close[4])
sellsetup = close>close[4] and priceflip
sell = sellsetup and barssince(priceflip!=9)
sellovershoot = sellsetup and barssince(priceflip!=13)
sellovershoot1 = sellsetup and barssince(priceflip!=14)
sellovershoot2 = sellsetup and barssince(priceflip!=15)
sellovershoot3 = sellsetup and barssince(priceflip!=16)
priceflip1 = barssince(close>close[4])
buysetup = close<close[4] and priceflip1
buy = buysetup and barssince(priceflip1!=9)
buyovershoot = barssince(priceflip1!=13) and buysetup
buyovershoot1 = barssince(priceflip1!=14) and buysetup
buyovershoot2 = barssince(priceflip1!=15) and buysetup
buyovershoot3 = barssince(priceflip1!=16) and buysetup
TDbuyh = valuewhen(buy,high,0)
TDbuyl = valuewhen(buy,low,0)
TDsellh = valuewhen(sell,high,0)
TDselll = valuewhen(sell,low,0)
plot(SR?(TDbuyh ? TDbuyl: na):na,style=circles, linewidth=2, color=red)
plot(SR?(TDselll ? TDsellh : na):na,style=circles, linewidth=2, color=lime)
barcolor(Barcolor?(sell? #FF0000 : buy? #00FF00 : sellovershoot? #FF66A3 : sellovershoot1? #FF3385 : sellovershoot2? #FF0066 : sellovershoot3? #CC0052 : buyovershoot? #D6FF5C : buyovershoot1? #D1FF47 : buyovershoot2? #B8E62E : buyovershoot3? #8FB224 : na):na)

sma1 = sma(close, 10)
sma2 = sma(close, 20)
plot(sma1, title="SMA10", color = yellow, linewidth = 2)
plot(sma2, title="SMA20", color = orange, linewidth = 2)
sma3 = sma(close, 50)
sma4 = sma(close, 100)
sma5 = sma(close, 200)
plot(sma3, title="SMA50", color = white, linewidth = 2)
plot(sma4, title="SMA100", color = blue, linewidth = 2)
plot(sma5, title="SMA200", color = fuchsia, linewidth = 2)
plot(cross(sma1, sma2) ? sma1 : na, style = cross, color = red, linewidth = 4)

length = input(200, minval=1)
src = input(hlc3, title="Source")
mult = input(3.0, minval=0.001, maxval=50)
basis = vwma(src, length)
dev = mult * stdev(src, length)
upper_1= basis + (0.236*dev)
upper_2= basis + (0.382*dev)
upper_3= basis + (0.5*dev)
upper_4= basis + (0.618*dev)
upper_5= basis + (0.764*dev)
upper_6= basis + (1*dev)
lower_1= basis - (0.236*dev)
lower_2= basis - (0.382*dev)
lower_3= basis - (0.5*dev)
lower_4= basis - (0.618*dev)
lower_5= basis - (0.764*dev)
lower_6= basis - (1*dev)
p1 = plot(upper_1, color=white, linewidth=1, title="0.236")
p2 = plot(upper_2, color=white, linewidth=1, title="0.382")
p3 = plot(upper_3, color=white, linewidth=1, title="0.5")
p4 = plot(upper_4, color=white, linewidth=1, title="0.618")
p5 = plot(upper_5, color=white, linewidth=1, title="0.764")
p6 = plot(upper_6, color=red, linewidth=2, title="1")
p13 = plot(lower_1, color=white, linewidth=1, title="0.236")
p14 = plot(lower_2, color=white, linewidth=1, title="0.382")
p15 = plot(lower_3, color=white, linewidth=1, title="0.5")
p16 = plot(lower_4, color=white, linewidth=1, title="0.618")
p17 = plot(lower_5, color=white, linewidth=1, title="0.764")
p18 = plot(lower_6, color=green, linewidth=2, title="1")

window1 = input(title='lookback window 1:', type=integer, defval=8)
window2 = input(title='lookback window 2:', type=integer, defval=21)
top1 = valuewhen(high >= highest(high, window1), high, 0)
bot1 = valuewhen(low <= lowest(low, window1), low, 0)
top2 = valuewhen(high >= highest(high, window2), high, 0)
bot2 = valuewhen(low <= lowest(low, window2), low, 0)
t1 = plot(top1, color=top1 != top1[1] ? na : red)
b1 = plot(bot1, color=bot1 != bot1[1] ? na : green)
t2 = plot(top2, color=top2 != top2[1] ? na : red)
b2 = plot(bot2, color=bot2 != bot2[1] ? na : green)
fill(t1, t2, color=orange, transp=80)
fill(b1, b2, color=olive, transp=80)


h_left = input(title="H left", type=integer, defval=10)
h_right = input(title="H right", type=integer, defval=10)
sample_period = input(title="Sample bars for % TZ", type=integer, defval=5000)
show_ptz = input(title="Show PTZ", type=bool, defval=true)
show_channel = input(title="Show channel", type=bool, defval=true)
h_left_low = lowest(h_left)
h_left_high = highest(h_left)
newlow = low <= h_left_low
newhigh = high >= h_left_high
plotshape(newlow and show_ptz, style=shape.triangledown, location=location.belowbar, color=red)
plotshape(newhigh and show_ptz, style=shape.triangleup, location=location.abovebar, color=green)
channel_high = plot(show_channel ? h_left_low : 0, color=silver)
channel_low = plot (show_channel ? h_left_high : 0, color=silver)
central_bar_low = low[h_right + 1]
central_bar_high = high[h_right + 1]
full_zone_low = lowest(h_left + h_right + 1)
full_zone_high = highest(h_left + h_right + 1)
central_bar_is_highest = central_bar_high >= full_zone_high
central_bar_is_lowest = central_bar_low <= full_zone_low
plotarrow(central_bar_is_highest ? -1 : 0, offset=-h_right-1)
plotarrow(central_bar_is_lowest ? 1 : 0, offset=-h_right-1)
x = central_bar_is_highest ? 1 : 0
high_bar_tz_count = cum(x)
y = central_bar_is_lowest ? 1 : 0
low_bar_tz_count = cum(y)
total_tz = high_bar_tz_count + low_bar_tz_count
percent_tz_high = (high_bar_tz_count / sample_period) * 100
percent_tz_low = (low_bar_tz_count / sample_period) * 100
percent_total_tz = (percent_tz_high + percent_tz_low)
plot(percent_total_tz, color=black, transp=100)

i = newhigh ? 1 : 0
high_bar_ptz_count = cum(i)
j = newlow ? 1 : 0
low_bar_ptz_count = cum(j)
total_ptz = high_bar_ptz_count + low_bar_ptz_count
percent_ptz_high = (high_bar_ptz_count / sample_period) * 100
percent_ptz_low = (low_bar_ptz_count / sample_period) * 100
percent_total_ptz = (percent_ptz_high + percent_ptz_low)
plot(percent_total_ptz, color=navy,  transp=100)
percent_ptz_resolved = (1 - (total_tz / total_ptz)) * 100
plot(percent_ptz_resolved, color=gray,  transp=100)
devUp1 = input(1.28, title="Stdev above (1)")
devDn1 = input(1.28, title="Stdev below (1)")

showPrevVWAP = input(false, type=bool, title="Show previous VWAP close")
ColorSrc=input(close)
price=ColorSrc
start = security(tickerid, "W", time)
newSession = iff(change(start), 1, 0)
vwapsum = iff(newSession, hl2*volume, vwapsum[1]+hl2*volume)
volumesum = iff(newSession, volume, volumesum[1]+volume)
v2sum = iff(newSession, volume*hl2*hl2, v2sum[1]+volume*hl2*hl2)
myvwap = vwapsum/volumesum
dev9 = sqrt(max(v2sum/volumesum - myvwap*myvwap, 0))
A=plot(myvwap,style=circles, title="VWAP", color=black, linewidth=3)
myvwapu1= myvwap + devUp1 * dev9
myvwapd1= myvwap - devDn1 * dev9
prevwap = iff(newSession, myvwap[1], prevwap[1])
plot(showPrevVWAP ? prevwap : na, style=circles, color=close > prevwap ? green : red)

start1 = input(2, minval=0, maxval=10, title="Start1 - Default = 2 - Multiplied by .01")
increment = input(2, minval=0, maxval=10, title="Step Setting (Sensitivity) - Default = 2 - Multiplied by .01" )
maximum = input(2, minval=1, maxval=10, title="Maximum Step (Sensitivity) - Default = 2 - Multiplied by .10")
sus = input(true, "Show Up Trending Parabolic Sar")
sds = input(true, "Show Down Trending Parabolic Sar")
disc = input(false, title="Start1 and Step settings are *.01 so 2 = .02 etc, Maximum Step is *.10 so 2 = .2")
startCalc = start1 * .01
incrementCalc = increment * .01
maximumCalc = maximum * .10
sarUp = sar(startCalc, incrementCalc, maximumCalc)
sarDown = sar(startCalc, incrementCalc, maximumCalc)
colUp = close >= sarDown ? lime : na
colDown = close <= sarUp ? red : na
plot(sus and sarUp ? sarUp : na, title="Up Trending SAR", style=circles, linewidth=4,color=colUp)
plot(sds and sarDown ? sarDown : na, title="Up Trending SAR", style=circles, linewidth=4,color=colDown)

TurtleSpeed = input(6, minval=1)
FastSpeed = highest(TurtleSpeed)
SlowSpeed = lowest(TurtleSpeed)
enterLong = high > FastSpeed[1]
enterShort = low < SlowSpeed[1]

strategy.entry("Long", strategy.long, when = enterLong)
strategy.entry("Short", strategy.short, when = enterShort)
````
