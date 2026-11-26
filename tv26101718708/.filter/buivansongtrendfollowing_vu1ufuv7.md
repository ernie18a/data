# buivansongtrendfollowing

- url: https://www.tradingview.com/script/VU1UFUV7-buivansongtrendfollowing/
- type: indicator
- pine_id: PUB;4227d134a2ae444b95f9cad3708e80e3
- version: 1.0

## Description

sadfas fsdafasd fsadf ádf ádfasdfssfafdsfsadfasdfasd        ádfa dsa fsdafasdfasdsf

## Source Code

````pine
//@version=5
indicator(title="CM_Ultimate_MA_MTF_V2_Fixed", shorttitle="CM_Ultimate_MA_MTF_V2", overlay=true)

//inputs
src = close
useCurrentRes = input.bool(true, title="Use Current Chart Resolution?")
resCustom = input.timeframe(title="Use Different Timeframe? Uncheck Box Above", defval="D")
len = input.int(20, title="Moving Average Length - LookBack Period")
//periodT3 = input(defval=7, title="Tilson T3 Period", minval=1) 
factorT3 = input.int(defval=7, title="Tilson T3 Factor - *.10 - so 7 = .7 etc.", minval=0) 
atype = input.int(1, minval=1, maxval=8, title="1=SMA, 2=EMA, 3=WMA, 4=HullMA, 5=VWMA, 6=RMA, 7=TEMA, 8=Tilson T3")
spc=input.bool(false, title="Show Price Crossing 1st Mov Avg - Highlight Bar?")
cc = input.bool(true, title="Change Color Based On Direction?")
smoothe = input.int(2, minval=1, maxval=10, title="Color Smoothing - Setting 1 = No Smoothing")
doma2 = input.bool(false, title="Optional 2nd Moving Average")
spc2=input.bool(false, title="Show Price Crossing 2nd Mov Avg?")
len2 = input.int(50, title="Moving Average Length - Optional 2nd MA")
sfactorT3 = input.int(defval=7, title="Tilson T3 Factor - *.10 - so 7 = .7 etc.", minval=0)
atype2 = input.int(1, minval=1, maxval=8, title="1=SMA, 2=EMA, 3=WMA, 4=HullMA, 5=VWMA, 6=RMA, 7=TEMA, 8=Tilson T3")
cc2 = input.bool(true, title="Change Color Based On Direction 2nd MA?")
warn = input.bool(false, title="***You Can Turn On The Show Dots Parameter Below Without Plotting 2nd MA to See Crosses***")
warn2 = input.bool(false, title="***If Using Cross Feature W/O Plotting 2ndMA - Make Sure 2ndMA Parameters are Set Correctly***")
sd = input.bool(false, title="Show Dots on Cross of Both MA's")

res = useCurrentRes ? timeframe.period : resCustom
//hull ma definition
hullma = ta.wma(2*ta.wma(src, len/2)-ta.wma(src, len), math.round(math.sqrt(len)))
//TEMA definition
ema1 = ta.ema(src, len)
ema2 = ta.ema(ema1, len)
ema3 = ta.ema(ema2, len)
tema = 3 * (ema1 - ema2) + ema3

//Tilson T3
factor = factorT3 *.10
gd(src, len, factor) => ta.ema(src, len) * (1 + factor) - ta.ema(ta.ema(src, len), len) * factor 
t3(src, len, factor) => gd(gd(gd(src, len, factor), len, factor), len, factor) 
tilT3 = t3(src, len, factor) 
 

avg = atype == 1 ? ta.sma(src,len) : atype == 2 ? ta.ema(src,len) : atype == 3 ? ta.wma(src,len) : atype == 4 ? hullma : atype == 5 ? ta.vwma(src, len) : atype == 6 ? ta.rma(src,len) : atype == 7 ? 3 * (ema1 - ema2) + ema3 : tilT3
//2nd Ma - hull ma definition
hullma2 = ta.wma(2*ta.wma(src, len2/2)-ta.wma(src, len2), math.round(math.sqrt(len2)))
//2nd MA TEMA definition
sema1 = ta.ema(src, len2)
sema2 = ta.ema(sema1, len2)
sema3 = ta.ema(sema2, len2)
stema = 3 * (sema1 - sema2) + sema3

//2nd MA Tilson T3
sfactor = sfactorT3 *.10
sgd(src, len2, sfactor) => ta.ema(src, len2) * (1 + sfactor) - ta.ema(ta.ema(src, len2), len2) * sfactor 
st3(src, len2, sfactor) => sgd(sgd(gd(src, len2, sfactor), len2, sfactor), len2, sfactor) 
stilT3 = st3(src, len2, sfactor) 

avg2 = atype2 == 1 ? ta.sma(src,len2) : atype2 == 2 ? ta.ema(src,len2) : atype2 == 3 ? ta.wma(src,len2) : atype2 == 4 ? hullma2 : atype2 == 5 ? ta.vwma(src, len2) : atype2 == 6 ? ta.rma(src,len2) : atype2 == 7 ? 3 * (ema1 - ema2) + ema3 : stilT3

out = avg 
out_two = avg2

out1 = request.security(syminfo.tickerid, res, out)
out2 = request.security(syminfo.tickerid, res, out_two)

//Formula for Price Crossing Moving Average #1
cr_up = open < out1 and close > out1
cr_Down = open > out1 and close < out1
//Formula for Price Crossing Moving Average #2
cr_up2 = open < out2 and close > out2
cr_Down2 = open > out2 and close < out2
//barcolor Criteria for Price Crossing Moving Average #1
iscrossUp() => cr_up
iscrossDown() => cr_Down
//barcolor Criteria for Price Crossing Moving Average #2
iscrossUp2() => cr_up2
iscrossDown2() => cr_Down2

ma_up = out1 >= out1[smoothe]
ma_down = out1 < out1[smoothe]

col = cc ? ma_up ? color.lime : ma_down ? color.red : color.aqua : color.aqua
col2 = cc2 ? ma_up ? color.lime : ma_down ? color.red : color.aqua : color.white

circleYPosition = out2

plot(out1, title="Multi-Timeframe Moving Avg", style=plot.style_line, linewidth=4, color = col)
plot(doma2 and out2 ? out2 : na, title="2nd Multi-TimeFrame Moving Average", style=plot.style_circles, linewidth=4, color=col2)
plot(sd and ta.cross(out1, out2) ? circleYPosition : na, style=plot.style_cross, linewidth=15, color=color.aqua)
//barcolor Plot for Price Crossing Moving Average #1
barcolor(spc and iscrossUp() ? (iscrossUp() ? color.yellow : na) : na)
barcolor(spc and iscrossDown() ? (iscrossDown() ? color.yellow : na) : na)
//barcolor Plot for Price Crossing Moving Average #2
barcolor(spc2 and iscrossUp2() ? (iscrossUp2() ? color.yellow : na) : na)
barcolor(spc2 and iscrossDown2() ? (iscrossDown2() ? color.yellow : na) : na)
````
