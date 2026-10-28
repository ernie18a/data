# Multiple Timeframe Six Moving Averages

- url: https://www.tradingview.com/script/jtnXYiVH-Multiple-Timeframe-Six-Moving-Averages/
- type: indicator
- pine_id: PUB;bc82efb85462414897145c2e24b55081
- version: 1.0

## Description

Multi TF MAs — plots six moving averages (8 / 20 / 50 / 88 / 200 / 500), each switchable between SMA, EMA, or Hull, on the current chart timeframe or a higher one you select. Volume-independent, so it works on any symbol — stocks, futures, ratios, or index/data feeds.

How to read it: it's a trend stack.

Price above a stacked, rising set → uptrend (offense)
Below a stacked, falling set → downtrend (defense)
Tangled/crossing → no trend (neutral)
The lines, by horizon: 8/20 = short-term tape · 50 = swing trend · 88 = quarterly · 200 = cyclical regime · 500 = secular regime.

Credit to BTCMoonBear

## Source Code

````pine
//@version=6
//Use this to add different timeframe MA to your chart
//Select MA style per line: 1=SMA, 2=EMA, 3=HullMA
//Six MAs — defaults 8/20/50/88/200/500. v6 port.

indicator(title="Multiple Timeframe Six Moving Averages", shorttitle="Multi TF MAs", overlay=true)

//global inputs
res_chart = input.bool(true, title="Use Current Chart Resolution?")
res_user  = input.timeframe("D", title="Time Frame")

//moving avg 1 inputs
mavg1  = input.bool(true, title="Enable 1st MA?")
len1   = input.int(8, minval=1, title="Length")
atype1 = input.int(1, minval=1, maxval=3, title="1=SMA, 2=EMA, 3=HullMA")
src1   = input.source(close, title="Source")

//moving avg 2 inputs
mavg2  = input.bool(true, title="Enable 2nd MA?")
len2   = input.int(20, minval=1, title="Length")
atype2 = input.int(1, minval=1, maxval=3, title="1=SMA, 2=EMA, 3=HullMA")
src2   = input.source(close, title="Source")

//moving avg 3 inputs
mavg3  = input.bool(true, title="Enable 3rd MA?")
len3   = input.int(50, minval=1, title="Length")
atype3 = input.int(1, minval=1, maxval=3, title="1=SMA, 2=EMA, 3=HullMA")
src3   = input.source(close, title="Source")

//moving avg 4 inputs
mavg4  = input.bool(true, title="Enable 4th MA?")
len4   = input.int(88, minval=1, title="Length")
atype4 = input.int(1, minval=1, maxval=3, title="1=SMA, 2=EMA, 3=HullMA")
src4   = input.source(close, title="Source")

//moving avg 5 inputs
mavg5  = input.bool(true, title="Enable 5th MA?")
len5   = input.int(200, minval=1, title="Length")
atype5 = input.int(1, minval=1, maxval=3, title="1=SMA, 2=EMA, 3=HullMA")
src5   = input.source(close, title="Source")

//moving avg 6 inputs
mavg6  = input.bool(true, title="Enable 6th MA?")
len6   = input.int(500, minval=1, title="Length")
atype6 = input.int(1, minval=1, maxval=3, title="1=SMA, 2=EMA, 3=HullMA")
src6   = input.source(close, title="Source")

//HullMA Definitions
hullma1 = ta.wma(2*ta.wma(src1, int(len1/2))-ta.wma(src1, len1), int(math.round(math.sqrt(len1))))
hullma2 = ta.wma(2*ta.wma(src2, int(len2/2))-ta.wma(src2, len2), int(math.round(math.sqrt(len2))))
hullma3 = ta.wma(2*ta.wma(src3, int(len3/2))-ta.wma(src3, len3), int(math.round(math.sqrt(len3))))
hullma4 = ta.wma(2*ta.wma(src4, int(len4/2))-ta.wma(src4, len4), int(math.round(math.sqrt(len4))))
hullma5 = ta.wma(2*ta.wma(src5, int(len5/2))-ta.wma(src5, len5), int(math.round(math.sqrt(len5))))
hullma6 = ta.wma(2*ta.wma(src6, int(len6/2))-ta.wma(src6, len6), int(math.round(math.sqrt(len6))))

//MA types logic
ma_type1 = atype1 == 1 ? ta.sma(src1, len1) : atype1 == 2 ? ta.ema(src1, len1) : hullma1
ma_type2 = atype2 == 1 ? ta.sma(src2, len2) : atype2 == 2 ? ta.ema(src2, len2) : hullma2
ma_type3 = atype3 == 1 ? ta.sma(src3, len3) : atype3 == 2 ? ta.ema(src3, len3) : hullma3
ma_type4 = atype4 == 1 ? ta.sma(src4, len4) : atype4 == 2 ? ta.ema(src4, len4) : hullma4
ma_type5 = atype5 == 1 ? ta.sma(src5, len5) : atype5 == 2 ? ta.ema(src5, len5) : hullma5
ma_type6 = atype6 == 1 ? ta.sma(src6, len6) : atype6 == 2 ? ta.ema(src6, len6) : hullma6

//Timeframe logic moving avg 1
resboolt1 = request.security(syminfo.tickerid, timeframe.period, ma_type1)
resboolf1 = request.security(syminfo.tickerid, res_user, ma_type1)
ma1 = res_chart ? resboolt1 : resboolf1
enablebool1 = mavg1 ? ma1 : na

//Timeframe logic moving avg 2
resboolt2 = request.security(syminfo.tickerid, timeframe.period, ma_type2)
resboolf2 = request.security(syminfo.tickerid, res_user, ma_type2)
ma2 = res_chart ? resboolt2 : resboolf2
enablebool2 = mavg2 ? ma2 : na

//Timeframe logic moving avg 3
resboolt3 = request.security(syminfo.tickerid, timeframe.period, ma_type3)
resboolf3 = request.security(syminfo.tickerid, res_user, ma_type3)
ma3 = res_chart ? resboolt3 : resboolf3
enablebool3 = mavg3 ? ma3 : na

//Timeframe logic moving avg 4
resboolt4 = request.security(syminfo.tickerid, timeframe.period, ma_type4)
resboolf4 = request.security(syminfo.tickerid, res_user, ma_type4)
ma4 = res_chart ? resboolt4 : resboolf4
enablebool4 = mavg4 ? ma4 : na

//Timeframe logic moving avg 5
resboolt5 = request.security(syminfo.tickerid, timeframe.period, ma_type5)
resboolf5 = request.security(syminfo.tickerid, res_user, ma_type5)
ma5 = res_chart ? resboolt5 : resboolf5
enablebool5 = mavg5 ? ma5 : na

//Timeframe logic moving avg 6
resboolt6 = request.security(syminfo.tickerid, timeframe.period, ma_type6)
resboolf6 = request.security(syminfo.tickerid, res_user, ma_type6)
ma6 = res_chart ? resboolt6 : resboolf6
enablebool6 = mavg6 ? ma6 : na

//Plot
plot(enablebool1, title="MA 8",   color=color.green)
plot(enablebool2, title="MA 20",  color=color.orange)
plot(enablebool3, title="MA 50",  color=color.red)
plot(enablebool4, title="MA 88",  color=color.teal)
plot(enablebool5, title="MA 200", color=color.white)
plot(enablebool6, title="MA 500", color=color.purple)
````
