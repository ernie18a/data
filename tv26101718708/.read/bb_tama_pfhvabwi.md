# [BB] TAMA

- url: https://www.tradingview.com/script/PFHVabwi/
- type: indicator
- pine_id: PUB;9b9b10f56b37479286fc1c410a08f4c7
- version: 1.0

## Description

메인 차트

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bbtanman

//@version=6
indicator(title="[BB] TAMA", overlay=true, explicit_plot_zorder=true, max_bars_back=1000, max_lines_count=500)
src = input(hl2, title="Source")
lenA = input.int(112, title="lenA")
lenB = input.int(224, title="lenB")
lenC = input.int(448, title="lenC")
lenD = input.int(896, title="lenD")

//  3일-432   4일-576    5일-720   10일-1440   20일-2880   60일-8640   100일-14400    200일-28800

boxp = input.int(50, "BOX LENGTH")
mult   = input.float(2.8, title="BasicSenv") 
smult = input.float(10.0, title="StdDev")
bp = input.float(0.995, title="BuyPount")
sp = input.float(1.005, title="SellPoint")
threshold = input.float(0.3, "Near distance", step=0.1)
sigma = input.int(10)
senv = input.float(1.3, title="senv")
hgt1 = input.int(200, 'hgt1', options = [200, 300, 400, 500, 700, 1000, 1500, 2000, 5000])
hgt2 = input.int(500, "hgt2", options = [500, 700, 1000, 1500, 2000, 5000])
hgt3 = input.int(1000, "hgt3", options = [1000, 1500, 2000, 3000, 4000, 5000])
hgt4 = input.int(1500, "hgt4", options = [1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000])
highlight = input(true, title="Highlight ?")

//----------------------------------------------------------------------------------------------------------------------

angle(_src) =>
    rad2degree = 180 / 3.14159265359  //pi 
    ang = rad2degree * math.atan((_src[0] - _src[1]) / ta.atr(14))
    ang


//----------------------------------------------------------------------------------------------------------------------

string res = timeframe.from_seconds(timeframe.in_seconds() * 4)                                   

// 타임프레임 할당 값
// if timeframe.isdaily                                              // 1Day
//     res := "1"
// else if timeframe.isminutes and timeframe.multiplier <= 1         //  1분 이내의 타임프레임 이면 아래의 값을 할당 3~5 minutes
//     res := "4" 
// else if timeframe.isminutes and timeframe.multiplier <= 5         //  5분 이내의 타임프레임 이면 아래의 값을 할당 3~5 minutes
//     res := "20"
// else if timeframe.isminutes and timeframe.multiplier <= 10        //  10분 이내의 타임프레임 이면 아래의 값을 할당 3~5 minutes
//     res := "40"
// else if timeframe.isminutes and timeframe.multiplier <= 15        //  15분 이내의 타임프레임 이면 아래의 값을 할당 3~5 minutes
//     res := "60"
// else if timeframe.isminutes and timeframe.multiplier <= 20        //  20분 이내의 타임프레임 이면 아래의 값을 할당 3~5 minutes
//     res := "80"    
// else if timeframe.isminutes and timeframe.multiplier < 30        //  30분 이내의 타임프레임 이면 아래의 값을 할당 5~15 minutes
//     res := "120"    
// else if timeframe.isminutes and timeframe.multiplier < 60        //  60분(1시간) 이내의 타임프레임 이면 아래의 값을 할당 15~59 minutes 
//     res := "240"
// else if timeframe.isminutes and timeframe.multiplier < 240       //  240분(4시간) 이내의 타임프레임 이면 아래의 값을 할당 *60~240 minutes
//     res := "960"
// else
//     res := "10"


//----------------------------------------------------------------------------------------------------------------------

h1high = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_on)     //  1h 고가 
h1low = request.security(syminfo.tickerid, "60", low[1], lookahead=barmerge.lookahead_on)       //  1h 저가 
h1close = request.security(syminfo.tickerid, "60", close[1], lookahead=barmerge.lookahead_on)   //  1h 종가 
h4high = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_on)    //  4h 고가 
h4low = request.security(syminfo.tickerid, "240", low[1], lookahead=barmerge.lookahead_on)      //  4h 저가 
h4close = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_on)  //  4h 종가 
dhigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)       //  1D 고가 
dlow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)         //  1D 저가 
dclose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)     //  1D 종가  
dcloseVol = request.security(syminfo.tickerid, "D", volume[1], lookahead=barmerge.lookahead_on)     //  1D 거래량  
dopen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)          //  1D 시가 
whigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)       //  1W 고가 
wlow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)         //  1W 저가 
wclose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)     //  1W 종가 
wopen = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)          //  1W 시가 
mhigh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)       //  1M 고가 
mlow = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)         //  1M 저가 
mclose = request.security(syminfo.tickerid, "M", close[1], lookahead=barmerge.lookahead_on)     //  1M 종가 
mopen = request.security(syminfo.tickerid, "M", open, lookahead=barmerge.lookahead_on)          //  1M 시가 
h1ctr = (h1high + h1low + h1close)/3                                                            //  1h 중심가 
h4ctr = (h4high + h4low + h4close)/3                                                            //  4h 중심가 
dctr = (dhigh + dlow + dclose)/3                                                                //  1D 중심가 
dctr2 = (dhigh + dlow)/2                                                                        //  1D 중심가  
legdctr = ta.linreg(dctr, 200, 0)
legdctr2 = ta.linreg(dctr2, 200, 0)
wctr = (whigh + wlow + wclose)/3                                                                //  1W 중심가 
wctr75 = (whigh + wctr)/2                                                                       //  1W 75%
wctr25 = (wlow + wctr)/2                                                                        //  1W 25%
mctr = (mhigh + mlow + mclose)/3                                                                //  1M 중심가 
mctr75 = (mhigh + mctr)/2                                                                       //  1M 75%
mctr25 = (mlow + mctr)/2                                                                        //  1M 25%

dc20 = ta.alma(dclose[20], 20, 0, sigma)
dc50 = ta.alma(dclose[50], 50, 0, sigma)
dc60 = ta.alma(dclose[60], 60, 0, sigma)
dc200 = ta.alma(dclose[200], 200, 0, sigma)

mctr200ema = ta.ema(mctr, 200)
wctr200ema = ta.ema(wctr, 200)
dctr200ema = ta.ema(dctr, 200)
h4ctr200ema = ta.ema(h4ctr, 200)
h1ctr200ema = ta.ema(h1ctr, 200)
ctr = ta.linreg(dctr, 200, 0)
f1 = math.avg(h1ctr200ema, h4ctr200ema)
f2 = math.avg(h4ctr200ema, dctr200ema)
f3 = math.avg(dctr200ema, wctr200ema)
f4 = math.avg(wctr200ema, mctr200ema)

f1f = ta.vwma(f1, 200)
f2f = ta.vwma(f2, 200)
f3f = ta.vwma(f3, 200)
f4f = ta.vwma(f4, 200)

ffLine = math.avg(f3f, f4f)

ff12 = math.avg(f1f, f2f)
ff12dev = 10.0 * ta.stdev(ff12, 200)
ff12Up = ff12 + ff12dev
ff12Dn = ff12 - ff12dev

f3dev = mult * ta.stdev(f3, 200)
f3Up = f3f + f3dev
f3Dn = f3f - f3dev

f4dev = mult * ta.stdev(f4, 200)
f4Up = f4f + f4dev
f4Dn = f4f - f4dev

//----------------------------------------------------------------------------------------------------------------------
// BB
// ema 이동평균
ema5 = ta.ema(close, 5)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema60 = ta.ema(close, 60)
ema100 = ta.ema(close, 100)
ema112 = ta.ema(close, 112)
ema120 = ta.ema(close, 120)
eema120 = ta.ema(ema120, 120)
ema200 = ta.ema(close, 200)
ema224 = ta.ema(close, 224)
eema200 = ta.ema(ema200, 200)
ema300 = ta.ema(close, 300)
ema400 = ta.ema(close, 400)
ema448 = ta.ema(close, 448)
ema720 = ta.ema(close, 720)
ema800 = ta.ema(close, 800)
ema896 = ta.ema(close, 896)
ema1000 = ta.ema(close, 1000)
ema1200 = ta.ema(close, 1200)
ema2880 = ta.ema(close, 2880)
emaA = ta.ema(close, lenA)
eemaA = ta.ema(emaA, lenA)
emaB = ta.ema(close, lenB)
emaC = ta.ema(close, lenC)
emaD = ta.ema(close, lenD)

   
// 4x 타임프레임에서 EMA 값 가져오기
ema20res  = request.security(syminfo.tickerid, res, ta.ema(close, 20))
ema50res  = request.security(syminfo.tickerid, res, ta.ema(close, 50))
ema60res  = request.security(syminfo.tickerid, res, ta.ema(close, 60))
ema112res = request.security(syminfo.tickerid, res, ta.ema(close, 112))
ema200res  = request.security(syminfo.tickerid, res, ta.ema(close, 200))
ema224res = request.security(syminfo.tickerid, res, ta.ema(close, 224))
ema448res = request.security(syminfo.tickerid, res, ta.ema(close, 448))
ema896res = request.security(syminfo.tickerid, res, ta.ema(close, 896))



//------------------------------------------------------------------------------------------

sbasis = ta.ema(eema120, 120)
sdev = 1 * ta.stdev(eema120, 120)
up1618 = sbasis + sdev*1.618
upBB = sbasis + sdev
dnBB = sbasis - sdev
dn1618 = sbasis - sdev*1.618

// bb0 = plot(up1618, title="+1618", color=#00000000, linewidth=1)
// bb1 = plot(upBB, title="+BB", color=#000000, linewidth=1)
// bb2 = plot(dnBB, title="-BB", color=#000000, linewidth=1)
// bb3 = plot(dn1618, title="-1618", color=#00000000, linewidth=1)
// fill(bb0, bb1, #000000)
// fill(bb2, bb3, #000000)

base100 = ta.ema(ema100, 100)
dev100 = 1 * ta.stdev(ema100, 100)
bb100Up = base100 + dev100
bb100Dn = base100 - dev100
base200 = ta.ema(ema200, 200)
dev200 = 1 * ta.stdev(ema200, 200)
bb200Up = base200 + dev200
bb200Dn = base200 - dev200
base300 = ta.ema(ema300, 300)
dev300 = 1 * ta.stdev(ema300, 300)
bb300Up = base300 + dev300
bb300Dn = base300 - dev300
base400 = ta.ema(ema400, 400)
dev400 = 1 * ta.stdev(ema400, 400)
bb400Up = base400 + dev400
bb400Dn = base400 - dev400
base800 = ta.ema(ema800, 800)
dev800 = 1 * ta.stdev(ema800, 800)
bb800Up = base800 + dev800
bb800Dn = base800 - dev800
base1200 = ta.ema(ema1200, 1200)
dev1200 = 1 * ta.stdev(ema1200, 1200)
bb1200Up = base1200 + dev1200
bb1200Dn = base1200 - dev1200

bb14up = ta.crossover(bb100Up, bb400Up)
bb14upValue = ta.valuewhen(bb14up, open, 0)
bb14dn = ta.crossunder(bb100Dn, bb400Dn)
bb14dnValue = ta.valuewhen(bb14dn, open, 0)
bb28up = ta.crossover(bb200Up, bb800Up)
bb28upValue = ta.valuewhen(bb28up, open, 0)
bb28dn = ta.crossunder(bb200Dn, bb800Dn)
bb28dnValue = ta.valuewhen(bb28dn, open, 0)
bb312up = ta.crossover(bb300Up, bb1200Up)
bb312upValue = ta.valuewhen(bb312up, open, 0)
bb312dn = ta.crossunder(bb300Dn, bb1200Dn)
bb312dnValue = ta.valuewhen(bb312dn, open, 0)
bb14avg = math.avg(bb14upValue, bb14dnValue)
bb28avg = math.avg(bb28upValue, bb28dnValue)
bb312avg = math.avg(bb312upValue, bb312dnValue)
w3HighValue = math.max(bb14avg, bb28avg, bb312avg)
w3LowValue = math.min(bb14avg, bb28avg, bb312avg)

legw3High = ta.linreg(w3HighValue, 60, 0)
legw3HighD = angle(legw3High)
legw3Low = ta.linreg(w3LowValue, 60, 0)
legw3LowD = angle(legw3Low)
w3Avg = math.avg(legw3High, legw3Low)

legw3 = ta.linreg(w3Avg, 200, 0)
plot(legw3, title="legw3", color=#00FFFF, linewidth=4, style=plot.style_line)
plot(legw3, title="legw3", color=#000000, linewidth=1, style=plot.style_circles)

//----------------------------------------------------------------------------------------------------------------------
// zlsma    //  15분봉 :  200일선  =  1시간 :  50일선

ls50 = ta.linreg(src, 50, 0)
alsma50 = ta.linreg(ls50, 50, 0)
aeq50 = ls50 - alsma50
zls50 = ls50 + aeq50

ls60 = ta.linreg(src, 60, 0)
alsma60 = ta.linreg(ls60, 60, 0)
aeq60 = ls60 - alsma60
zls60 = ls60 + aeq60

ls100 = ta.linreg(src, 100, 0)
alsma100 = ta.linreg(ls100, 100, 0)
aeq100 = ls100 - alsma100
zls100 = ls100 + aeq100

ls112 = ta.linreg(src, 112, 0)
alsma112 = ta.linreg(ls112, 112, 0)
aeq112 = ls112 - alsma112
zls112 = ls112 + aeq112

ls200 = ta.linreg(src, 200, 0)
alsma200 = ta.linreg(ls200, 200, 0)
aeq200 = ls200-alsma200
zls200 = ls200+aeq200

ls224 = ta.linreg(src, 224, 0)
alsma224 = ta.linreg(ls224, 224, 0)
aeq224 = ls224 - alsma224
zls224 = ls224 + aeq224

ls448 = ta.linreg(src, 448, 0)
alsma448 = ta.linreg(ls448, 448, 0)
aeq448 = ls448 - alsma448
zls448 = ls448 + aeq448

ls896 = ta.linreg(src, 896, 0)
alsma896 = ta.linreg(ls896, 896, 0)
aeq896 = ls896 - alsma896
zls896 = ls896 + aeq896



lsA = ta.linreg(src, lenA, 0)
alsmaA = ta.linreg(lsA, lenA, 0)
aeqA= lsA-alsmaA
zlsA = lsA+aeqA


lsB = ta.linreg(src, lenB, 0)
alsmaB = ta.linreg(lsB, lenB, 0)
aeqB= lsB-alsmaB
zlsB = lsB+aeqB


lsC = ta.linreg(src, lenC, 0)
alsmaC = ta.linreg(lsC, lenC, 0)
aeqC= lsC-alsmaC
zlsC = lsC+aeqC


lsD = ta.linreg(src, lenD, 0)
alsmaD = ta.linreg(lsD, lenD, 0)
aeqD= lsD-alsmaD
zlsD = lsD+aeqD


// 4x 타임프레임에서 ZLS 값 가져오기
zls50res  = request.security(syminfo.tickerid, res, zls50)
zls112res = request.security(syminfo.tickerid, res, zls112)
zls200res  = request.security(syminfo.tickerid, res, zls200)
zls224res = request.security(syminfo.tickerid, res, zls224)
zls448res = request.security(syminfo.tickerid, res, zls448)
zls896res = request.security(syminfo.tickerid, res, zls896)

//--------------------------------------------------------------------------
// Trend Detection Logic
bullish_trend = ema5 > ema20 and ema20 > ema50 and ema50 > ema112 and ema112 > ema224 and ema224 > ema448
bearish_trend = ema5 < ema20 and ema20 < ema50 and ema50 < ema112 and ema112 < ema224 and ema224 < ema448

// EMA Color Based on Trend
ema_color = bullish_trend ? color.lime : bearish_trend ? color.red : #CCCCCC
emaBGColor = highlight ? ( bullish_trend  ?  #8BC34A50 : #E5393550) : #CCCCCC50

// Plot EMAs with updated thickness
// plot(ema20res, title='EMA 20', linewidth=1, color=ema_color)
e0 = plot(ema50res, title='EMA 50', linewidth=1, color=ema_color)
// plot(ema112res, title='EMA 112', linewidth=1, color=ema_color)
e1 = plot(ema224res, title='EMA 224', linewidth=1, color=ema_color)  
// plot(ema448res, title='EMA 448', linewidth=1, color=ema_color)  
fill(e0, e1, emaBGColor)


// Trend Detection Logic
zbullish_trend = zls50res > zls112res and zls112res > zls224res and zls224res > zls448res
zbearish_trend = zls50res < zls112res and zls112res < zls224res and zls224res < zls448res

// EMA Color Based on Trend
zls_color = zbullish_trend ? color.lime : bearish_trend ? color.red : #CCCCCC
zlsBGColor = highlight ? ( zbullish_trend  ?  #8BC34A50 : #E5393550) : #CCCCCC50

// Plot EMAs with updated thickness
// plot(ema20res, title='ZLS 20', linewidth=1, color=zls_color)
// z0 = plot(zls50res, title='ZLS 50', linewidth=1, color=ema_color)
// plot(zls112res, title='ZLS 112', linewidth=1, color=zls_color)
// plot(zls224res, title='ZLS 224', linewidth=1, color=zls_color)  
// z1 = plot(zls448res, title='ZLS 448', linewidth=1, color=zls_color)  
// fill(z0, z1, zlsBGColor)



// zAreaColor = highlight ? ( zlsA > zhmaA  ?  #D5000050 : #01579B60) : na

plot(zls200, title="zls200", color=#FFFF00, linewidth=1, style=plot.style_steplinebr)
// z1 = plot(zhmaA, title="zhmaA", color=#FFFF00, linewidth=1, style=plot.style_steplinebr)
// fill(z0, z1, color=zAreaColor)

// plot(zhmaB, title="zhmaB", color=#689F3800, linewidth=2, style=plot.style_line)
// plot(zhmaB, title="zhmaB", color=#689F38, linewidth=2, style=plot.style_line)

// plot(zhmaC, title="zhmaC", color=#00B0FF, linewidth=2, style=plot.style_line)
// plot(eemaA, title="eemaA", color=#FFFFFF, linewidth=2, style=plot.style_line)
// plot(eemaA, title="eemaA", color=#000000, linewidth=1, style=plot.style_circles)


//----------------------------------------------------------------------------------------------------------------------
// res
// ema20res = request.security(syminfo.tickerid, res, ema20, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
eres20 = ta.ema(ema20res, 20)
// ema60res = request.security(syminfo.tickerid, res, ema60, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
eres60 = ta.ema(ema60res, 60)
// ema200res = request.security(syminfo.tickerid, res, ema200, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
eres200 = ta.ema(ema200res, 200)
// plot(eres200, title="eres200", color=#FFCC00, linewidth=3, style=plot.style_line, offset=5)
// plot(eres200, title="eres200", color=#000000, linewidth=1, style=plot.style_circles, offset=5)

//----------------------------------------------------------------------------------------------------------------------


ema1000Label = label.new(x=bar_index - 90, y=ema1000, color=#FFFF0000, textcolor=#DDDDDD, style=label.style_label_right, size=size.small)
label.set_text(id=ema1000Label, text="1000")
label.delete(ema1000Label[1])

ema200Label = label.new(x=bar_index - 90, y=ema200, color=#FFFF0000, textcolor=#DDDDDD, style=label.style_label_right, size=size.small)
label.set_text(id=ema200Label, text="200")
label.delete(ema200Label[1])

ema100Label = label.new(x=bar_index - 90, y=ema100, color=#FFFF0000, textcolor=#DDDDDD, style=label.style_label_right, size=size.small)
label.set_text(id=ema100Label, text="100")
label.delete(ema100Label[1])

ema50Label = label.new(x=bar_index - 90, y=ema50, color=#FFFF0000, textcolor=#DDDDDD, style=label.style_label_right, size=size.small)
label.set_text(id=ema50Label, text="50")
label.delete(ema50Label[1])

ema20Label = label.new(x=bar_index - 90, y=ema20, color=#FFFF0000, textcolor=#DDDDDD, style=label.style_label_right, size=size.small)
label.set_text(id=ema20Label, text="20")
label.delete(ema20Label[1])

ema2880Label = label.new(x=bar_index - 70, y=ema2880, color=#81D4FA, textcolor=#000000, style=label.style_label_right, size=size.small)
label.set_text(id=ema2880Label, text="E20일")
label.delete(ema2880Label[1])

ema720Label = label.new(x=bar_index - 70, y=ema720, color=#81C784, textcolor=#000000, style=label.style_label_right, size=size.small)
label.set_text(id=ema720Label, text="E5일")
label.delete(ema720Label[1])

whighLabel = label.new(x=bar_index - 170, y=whigh, color=#8D6E63, textcolor=#000000, style=label.style_label_left, size=size.small)
label.set_text(id=whighLabel, text="주봉100%")
label.delete(whighLabel[1])

wctr75Label = label.new(x=bar_index - 170, y=wctr75, color=#8D6E63, textcolor=#000000, style=label.style_label_left, size=size.small)
label.set_text(id=wctr75Label, text="주봉75%")
label.delete(wctr75Label[1])

wctrLabel = label.new(x=bar_index - 170, y=wctr, color=#8D6E63, textcolor=#000000, style=label.style_label_left, size=size.small)
label.set_text(id=wctrLabel, text="주봉중심가")
label.delete(wctrLabel[1])
plot(wctr, title="주봉중심", color=#000000, linewidth=1, style=plot.style_line)

wctr25Label = label.new(x=bar_index - 170, y=wctr25, color=#8D6E63, textcolor=#000000, style=label.style_label_left, size=size.small)
label.set_text(id=wctr25Label, text="주봉25%")
label.delete(wctr25Label[1])

wlowLabel = label.new(x=bar_index - 170, y=wlow, color=#8D6E63, textcolor=#000000, style=label.style_label_left, size=size.small)
label.set_text(id=wlowLabel, text="주봉0%")
label.delete(wlowLabel[1])

mctrLabel = label.new(x=bar_index + 15, y=mctr, color=#000000, textcolor=#FFCC00, style=label.style_label_left, size=size.small)
label.set_text(id=mctrLabel, text="월봉중심")
label.delete(mctrLabel[1])
plot(mctr, title="월봉중심", color=#000000, linewidth=1, style=plot.style_line)

mopenLabel = label.new(x=bar_index + 15, y=mopen, color=#000000, textcolor=#FFCC00, style=label.style_label_left, size=size.small)
label.set_text(id=mopenLabel, text="월봉시가")
label.delete(mopenLabel[1])

dctrLabel = label.new(x=bar_index + 15, y=legdctr, color=#000000, textcolor=#FFCC00, style=label.style_label_left, size=size.small)
label.set_text(id=dctrLabel, text="일봉중심")
label.delete(dctrLabel[1])
plot(legdctr, title="일봉중심", color=#DDDDDD00, linewidth=1, style=plot.style_line)

wctrALabel = label.new(x=bar_index + 15, y=wctr, color=#000000, textcolor=#FFCC00, style=label.style_label_left, size=size.small)
label.set_text(id=wctrALabel, text="주봉중심")
label.delete(wctrALabel[1])


//----------------------------------------------------------------------------------------------------------------------
````
