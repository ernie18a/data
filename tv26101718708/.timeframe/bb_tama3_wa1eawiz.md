# [BB] TAMA3

- url: https://www.tradingview.com/script/Wa1EAwiZ/
- type: indicator
- pine_id: PUB;8b2cf1cbabfd41a980aa9addf1564f67
- version: 1.0

## Description

메인 TAMA3  보조 TA3

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bbtanman

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bbtanman

//@version=6
indicator(title="[BB] TAMA3", overlay=true, explicit_plot_zorder=true, max_bars_back=1000, max_lines_count=500)
src = input(hlc3, title="Source")
lenA = input.int(112, title="lenA")
lenB = input.int(224, title="lenB")
lenC = input.int(448, title="lenC")
lenD = input.int(896, title="lenD")

//  3일-432   4일-576    5일-720   10일-1440   20일-2880   60일-8640   100일-14400    200일-28800

boxp = input.int(100, "BOX LENGTH")
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

// 최저값과 최고값 계산
LL = ta.lowest(low, 100)
k1 = ta.highest(high, 100)
k2 = ta.highest(high, 100 - 1)
k3 = ta.highest(high, 100 - 2)
NH = ta.valuewhen(high > k1[1], high, 0)
box1 = k3 < k2
boxup = ta.valuewhen(ta.barssince(high > k1[1]) == boxp - 2 and box1, NH, 0)
boxdn = ta.valuewhen(ta.barssince(high > k1[1]) == boxp - 2 and box1, LL, 0)
boxAvg = math.avg(boxup, boxdn)
legbup = ta.linreg(boxup, 100, 0)
legbdn = ta.linreg(boxdn, 100, 0)

// 박스 상단과 하단 플롯
b0 = plot(legbup, linewidth=3, color=color.green, title="Bup")
b1 = plot(legbdn, linewidth=3, color=color.red, title="Bdn")
fill(b0, b1, #00000060)


//----------------------------------------------------------------------------------------------------------------------

h1high = request.security(syminfo.tickerid, "60", high[1], lookahead=barmerge.lookahead_on)
h1low = request.security(syminfo.tickerid, "60", low[1], lookahead=barmerge.lookahead_on)
h1close = request.security(syminfo.tickerid, "60", close[1], lookahead=barmerge.lookahead_on)
h4high = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_on)
h4low = request.security(syminfo.tickerid, "240", low[1], lookahead=barmerge.lookahead_on)
h4close = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_on)
dhigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
dlow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
dclose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
dcloseVol = request.security(syminfo.tickerid, "D", volume[1], lookahead=barmerge.lookahead_on)
dopen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
whigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
wlow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
wclose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
wopen = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)
mhigh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
mlow = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)
mclose = request.security(syminfo.tickerid, "M", close[1], lookahead=barmerge.lookahead_on)
mopen = request.security(syminfo.tickerid, "M", open, lookahead=barmerge.lookahead_on)
h1ctr = (h1high + h1low + h1close)/3
h4ctr = (h4high + h4low + h4close)/3
dctr = (dhigh + dlow + dclose)/3
dctr2 = (dhigh + dlow)/2
legdctr = ta.linreg(dctr, 200, 0)
legdctr2 = ta.linreg(dctr2, 200, 0)
wctr = (whigh + wlow + wclose)/3
wctr75 = (whigh + wctr)/2
wctr25 = (wlow + wctr)/2
mctr = (mhigh + mlow + mclose)/3
mctr75 = (mhigh + mctr)/2
mctr25 = (mlow + mctr)/2

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
bullish_trend = zls50res > zls112res and zls112res > zls112res and zls224res > zls448res 
bearish_trend = zls50res < zls112res and zls112res < zls112res and zls224res < zls448res 

// EMA Color Based on Trend
ema_color = bullish_trend ? color.lime : bearish_trend ? color.red : #CCCCCC
zlsBGColor = highlight ? ( bullish_trend  ?  #8BC34A40 : #E5393540) : #CCCCCC50

e0 = plot(ema50res, title='EMA 50', linewidth=1, color=#CCCCCC50)
e1 = plot(ema224res, title='EMA 224', linewidth=1, color=#CCCCCC50)  
fill(e0, e1, zlsBGColor)

// Trend Detection Logic
zbullish_trend = zls50res > zls112res and zls112res > zls224res and zls224res > zls448res
zbearish_trend = zls50res < zls112res and zls112res < zls224res and zls224res < zls448res

// EMA Color Based on Trend
zls_color = zbullish_trend ? color.lime : bearish_trend ? color.red : #CCCCCC

// plot(ema20res, title='ZLS 20', linewidth=1, color=zls_color)
// z0 = plot(zls50res, title='ZLS 50', linewidth=1, color=ema_color)
// plot(zls112res, title='ZLS 112', linewidth=1, color=zls_color)
// plot(zls224res, title='ZLS 224', linewidth=1, color=zls_color)  
// z1 = plot(zls448res, title='ZLS 448', linewidth=1, color=zls_color)  
// fill(z0, z1, zlsBGColor)

plot(zls200, title="zls200", color=#FFFF00, linewidth=1, style=plot.style_line)
plot(zls200res, title="zls200res", color=#FFFF00, linewidth=2, style=plot.style_line)

//----------------------------------------------------------------------------------------------------------------------
// res
eres20 = ta.ema(ema20res, 20)
eres60 = ta.ema(ema60res, 60)
eres200 = ta.ema(ema200res, 200)

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
// ── TA3 신호 기반 진입 (buy2 → legbdn 매수, sell2 → legbup 매도) ─────────────

// zlsB200 재계산 (TA3와 동일 로직, hlc3 소스)
ta3_src      = hlc3
ta3_ls200    = ta.linreg(ta3_src, 200, 0)
ta3_zls200   = ta3_ls200 + (ta3_ls200 - ta.linreg(ta3_ls200, 200, 0))
ta3_agzls200 = ta.sma(math.atan((ta3_zls200 - ta3_zls200[1]) / ta3_zls200[1]) * (180.0 / math.pi), 199) * 10

ta3_ang_hi   = ta.highest(ta3_agzls200, 200)
ta3_ang_lo   = ta.lowest(ta3_agzls200,  200)
ta3_ang_rng  = ta3_ang_hi - ta3_ang_lo
ta3_norm_ang = ta3_ang_rng != 0 ? (ta3_agzls200 - ta3_ang_lo) / ta3_ang_rng * 2 - 1 : 0

ta3_zls_hi   = ta.highest(ta3_zls200, 200)
ta3_zls_lo   = ta.lowest(ta3_zls200,  200)
ta3_zls_rng  = ta3_zls_hi - ta3_zls_lo
ta3_norm_zls = ta3_zls_rng != 0 ? (ta3_zls200 - ta3_zls_lo) / ta3_zls_rng * 2 - 1 : 0

ta3_zlsB200  = math.avg(ta3_norm_ang, ta3_norm_zls)

// zlsC200 재계산 — TAMA의 legbup/legbdn 정규화
ta3_box_ref_hi  = ta.highest(math.max(legbup, legbdn), 200)
ta3_box_ref_lo  = ta.lowest(math.min(legbup, legbdn),  200)
ta3_box_rng     = ta3_box_ref_hi - ta3_box_ref_lo
ta3_norm_legbup = ta3_box_rng != 0 ? (legbup - ta3_box_ref_lo) / ta3_box_rng * 2 - 1 : 0
ta3_norm_legbdn = ta3_box_rng != 0 ? (legbdn - ta3_box_ref_lo) / ta3_box_rng * 2 - 1 : 0
ta3_zlsC200     = math.avg(ta3_norm_legbup, ta3_norm_legbdn)

// norm_adx 재계산
ta3_adx_len = 14
ta3_tr      = math.max(math.max(high - low, math.abs(high - nz(close[1]))), math.abs(low - nz(close[1])))
ta3_dmp     = high - nz(high[1]) > nz(low[1]) - low ? math.max(high - nz(high[1]), 0) : 0
ta3_dmm     = nz(low[1]) - low > high - nz(high[1]) ? math.max(nz(low[1]) - low, 0)  : 0

var float ta3_str  = 0.0
var float ta3_sdmp = 0.0
var float ta3_sdmm = 0.0
ta3_str  := nz(ta3_str[1])  - nz(ta3_str[1])  / ta3_adx_len + ta3_tr
ta3_sdmp := nz(ta3_sdmp[1]) - nz(ta3_sdmp[1]) / ta3_adx_len + ta3_dmp
ta3_sdmm := nz(ta3_sdmm[1]) - nz(ta3_sdmm[1]) / ta3_adx_len + ta3_dmm

ta3_dip      = ta3_str != 0 ? ta3_sdmp / ta3_str * 100 : 0
ta3_dim      = ta3_str != 0 ? ta3_sdmm / ta3_str * 100 : 0
ta3_dx       = (ta3_dip + ta3_dim) != 0 ? (ta3_dip - ta3_dim) / (ta3_dip + ta3_dim) : 0
ta3_norm_adx = ta.ema(ta3_dx, ta3_adx_len)

// buy2 / sell2 조건
ta3_adx_rising  = ta3_norm_adx[2] < 0 and ta3_norm_adx[2] < ta3_norm_adx[1] and ta3_norm_adx[1] < ta3_norm_adx[0]
ta3_adx_falling = ta3_norm_adx[2] > 0 and ta3_norm_adx[2] > ta3_norm_adx[1] and ta3_norm_adx[1] > ta3_norm_adx[0]
ta3_buy2  = ta.crossover(ta3_zlsB200,  ta3_zlsC200) and (ta3_norm_adx >= 0 or ta3_adx_rising)
ta3_sell2 = ta.crossunder(ta3_zlsB200, ta3_zlsC200) and (ta3_norm_adx <= 0 or ta3_adx_falling)

// 진입 레이블 + 수평 점선
if ta3_buy2
    label.new(bar_index, legbdn,
              "매수진입\n" + str.tostring(math.round(legbdn)),
              style=label.style_label_up, color=#00E67680, textcolor=color.white, size=size.small)
    line.new(bar_index, legbdn, bar_index + 20, legbdn,
             color=#00E676, width=1, style=line.style_dashed)

if ta3_sell2
    label.new(bar_index, legbup,
              "매도진입\n" + str.tostring(math.round(legbup)),
              style=label.style_label_down, color=#FF525280, textcolor=color.white, size=size.small)
    line.new(bar_index, legbup, bar_index + 20, legbup,
             color=#FF5252, width=1, style=line.style_dashed)

alertcondition(ta3_buy2,  "TAMA 매수진입", "{{ticker}} 매수진입 — legbdn")
alertcondition(ta3_sell2, "TAMA 매도진입", "{{ticker}} 매도진입 — legbup")
````
