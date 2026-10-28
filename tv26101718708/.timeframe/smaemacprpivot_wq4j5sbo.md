# SMA_EMA_CPR_Pivot

- url: https://www.tradingview.com/script/wq4j5SBo-SMA-EMA-CPR-Pivot/
- type: indicator
- pine_id: PUB;49f14dfc68e6468b860001df8885fe89
- version: 1.0

## Description

This Script can do multiple jobs in single indicator.

Like -:
Plot 3 SMA as per your inputs.
Plot 3 EMA as per your inputs.
Plot CPR Levels.
Plot Pivot Levels.
Plot Previous Day High Low.

Indicator can used in Intraday stock trading, Positional Trading and options trading.
Please Enjoy.

## Source Code

````pine
//@version=5
indicator(title='SMA_EMA_CPR_Pivot', shorttitle='SMA_EMA_CPR_Pivot', overlay=true)

CPR_LEVEL = input.int(title='CPR_LEVEL', defval=1, minval=0)

CPR_Display = input(true, title='CPR_Display')

PrevHL_Display = input(true, title='PrevHL_Display')

EMA_Display = input(false, title='EMA_Display')

SMA_Display = input(true, title='SMA_Display')

Camarilla_Display = input(false, title='Camarilla_Display')



new_bar(res) =>
    ta.change(time(res)) != 0
new_period(condition, src) =>
    result = 0.0
    result := condition ? src : result[1]
    result


//Pivot Formula Calculation
Pivot = (high + low + close) / 3.0
BC = (high + low) / 2.0
TC = Pivot - BC + Pivot
R1 = 2 * Pivot - low
S1 = 2 * Pivot - high
R2 = Pivot + high - low
S2 = Pivot - (high - low)
R3 = high + 2 * (Pivot - low)
S3 = low - 2 * (high - Pivot)
R4 = R3 + R2 - R1
S4 = S3 + S2 - S1
PH = high
PL = low


//Pivot Display Properties
Display_PP = request.security(syminfo.tickerid, 'D', Pivot[1], lookahead=barmerge.lookahead_on)
Display_BC = request.security(syminfo.tickerid, 'D', BC[1], lookahead=barmerge.lookahead_on)
Display_TC = request.security(syminfo.tickerid, 'D', TC[1], lookahead=barmerge.lookahead_on)
Display_R1 = request.security(syminfo.tickerid, 'D', R1[1], lookahead=barmerge.lookahead_on)
Display_S1 = request.security(syminfo.tickerid, 'D', S1[1], lookahead=barmerge.lookahead_on)
Display_R2 = request.security(syminfo.tickerid, 'D', R2[1], lookahead=barmerge.lookahead_on)
Display_S2 = request.security(syminfo.tickerid, 'D', S2[1], lookahead=barmerge.lookahead_on)
Display_R3 = request.security(syminfo.tickerid, 'D', R3[1], lookahead=barmerge.lookahead_on)
Display_S3 = request.security(syminfo.tickerid, 'D', S3[1], lookahead=barmerge.lookahead_on)
Display_R4 = request.security(syminfo.tickerid, 'D', R4[1], lookahead=barmerge.lookahead_on)
Display_S4 = request.security(syminfo.tickerid, 'D', S4[1], lookahead=barmerge.lookahead_on)
Display_PH = request.security(syminfo.tickerid, 'D', PH[1], lookahead=barmerge.lookahead_on)
Display_PL = request.security(syminfo.tickerid, 'D', PL[1], lookahead=barmerge.lookahead_on)

one_day = 1000 * 60 * 60 * 24

new_day = CPR_LEVEL > 0 and timenow - time < one_day * CPR_LEVEL and new_bar('D')
Display_PP_ = new_period(new_day, Display_PP)
Display_TC_ = new_period(new_day, Display_TC)
Display_BC_ = new_period(new_day, Display_BC)
Display_R1_ = new_period(new_day, Display_R1)
Display_S1_ = new_period(new_day, Display_S1)
Display_R2_ = new_period(new_day, Display_R2)
Display_S2_ = new_period(new_day, Display_S2)
Display_R3_ = new_period(new_day, Display_R3)
Display_S3_ = new_period(new_day, Display_S3)
Display_R4_ = new_period(new_day, Display_R4)
Display_S4_ = new_period(new_day, Display_S4)
Display_PH_ = new_period(new_day, Display_PH)
Display_PL_ = new_period(new_day, Display_PL)

plot(timeframe.isintraday and CPR_Display ? Display_TC_ >= Display_BC_ ? Display_TC_ : Display_BC_ : na, title='Daily TC', style=plot.style_circles, color=color.new(#2196f3, 0), linewidth=2)
plot(timeframe.isintraday and CPR_Display ? Display_PP_ : na, title='Daily PP', style=plot.style_circles, color=color.new(#9C27B0, 0), linewidth=2)
plot(timeframe.isintraday and CPR_Display ? Display_TC_ >= Display_BC_ ? Display_BC_ : Display_TC_ : na, title='Daily BC', style=plot.style_circles, color=color.new(#2196f3, 0), linewidth=2)

plot(CPR_Display ? Display_R1_ : na, title='R1', title='Daily R1', style=plot.style_circles, color=color.new(#ff0000, 0), linewidth=3)
plot(CPR_Display ? Display_R2_ : na, title='R2', title='Daily R2', style=plot.style_circles, color=color.new(#ff0000, 0), linewidth=2)
plot(CPR_Display ? Display_R3_ : na, title='R3', title='Daily R3', style=plot.style_circles, color=color.new(#ff0000, 0), linewidth=2)
plot(CPR_Display ? Display_R4_ : na, title='R4', title='Daily R4', style=plot.style_circles, color=color.new(#ff0000, 0), linewidth=2)
plot(CPR_Display ? Display_S1_ : na, title='S1', title='Daily S1', style=plot.style_circles, color=color.new(#008000, 0), linewidth=3)
plot(CPR_Display ? Display_S2_ : na, title='S2', title='Daily S2', style=plot.style_circles, color=color.new(#008000, 0), linewidth=2)
plot(CPR_Display ? Display_S3_ : na, title='S3', title='Daily S3', style=plot.style_circles, color=color.new(#008000, 0), linewidth=2)
plot(CPR_Display ? Display_S4_ : na, title='S4', title='Daily S4', style=plot.style_circles, color=color.new(#008000, 0), linewidth=2)
plot(PrevHL_Display ? Display_PH_ : na, title='PDH', title='Previous Day High', style=plot.style_circles, color=color.new(#ff9800, 0), linewidth=2)
plot(PrevHL_Display ? Display_PL_ : na, title='PDL', title='Previous Day Low', style=plot.style_circles, color=color.new(#ff9800, 0), linewidth=2)

EMA_1 = input.int(9, minval=1, title='EMA 1')
SOURCE_1 = input(close, title='Source')
OUTPUT_1 = ta.ema(SOURCE_1, EMA_1)
plot(EMA_Display ? OUTPUT_1 : na, color=color.new(#fb41ff, 0), title='EMA 1', linewidth=2)
EMA_2 = input.int(20, minval=1, title='EMA 2')
SOURCE_2 = input(close, title='Source')
OUTPUT_2 = ta.ema(SOURCE_2, EMA_2)
plot(EMA_Display ? OUTPUT_2 : na, color=color.new(#fb41ff, 0), title='EMA 2', linewidth=2)
EMA_3 = input.int(50, minval=1, title='EMA 3')
SOURCE_3 = input(close, title='Source')
OUTPUT_3 = ta.ema(SOURCE_3, EMA_3)
plot(EMA_Display ? OUTPUT_3 : na, color=color.new(#fb41ff, 0), title='EMA 3', linewidth=2)


SMA_1 = input.int(9, minval=1, title='SMA 1')
SOURCE_1_S = input(close, title='Source')
OUTPUT_1_S = ta.sma(SOURCE_1, SMA_1)
plot(SMA_Display ? OUTPUT_1_S : na, color=color.new(#ffeb3b, 0), title='SMA 1', linewidth=2)
SMA_2 = input.int(20, minval=1, title='SMA 2')
SOURCE_2_S = input(close, title='Source')
OUTPUT_2_S = ta.sma(SOURCE_2, SMA_2)
plot(SMA_Display ? OUTPUT_2 : na, color=color.new(#008000, 0), title='SMA 2', linewidth=2)
SMA_3 = input.int(50, minval=1, title='SMA 3')
SOURCE_3_S = input(close, title='Source')
OUTPUT_3_S = ta.sma(SOURCE_3, SMA_3)
plot(SMA_Display ? OUTPUT_3 : na, color=color.new(#ff0000, 0), title='SMA 3', linewidth=2)


sopen = request.security(syminfo.tickerid, 'D', open[1], barmerge.gaps_off, barmerge.lookahead_on)
shigh = request.security(syminfo.tickerid, 'D', high[1], barmerge.gaps_off, barmerge.lookahead_on)
slow = request.security(syminfo.tickerid, 'D', low[1], barmerge.gaps_off, barmerge.lookahead_on)
sclose = request.security(syminfo.tickerid, 'D', close[1], barmerge.gaps_off, barmerge.lookahead_on)
r = shigh - slow

h1 = sclose + r * (1.1 / 12)
h2 = sclose + r * (1.1 / 6)
h3 = sclose + r * (1.1 / 4)
h4 = sclose + r * (1.1 / 2)

l1 = sclose - r * (1.1 / 12)
l2 = sclose - r * (1.1 / 6)
l3 = sclose - r * (1.1 / 4)
l4 = sclose - r * (1.1 / 2)


h1_ = new_period(new_day, h1)
h2_ = new_period(new_day, h2)
h3_ = new_period(new_day, h3)
h4_ = new_period(new_day, h4)
l1_ = new_period(new_day, l1)
l2_ = new_period(new_day, l2)
l3_ = new_period(new_day, l3)
l4_ = new_period(new_day, l4)


c4 = sopen != sopen[1] ? na : color.fuchsia
c3 = sopen != sopen[1] ? na : color.green
c2 = sopen != sopen[1] ? na : color.blue
c1 = sopen != sopen[1] ? na : color.gray
//cc=sopen != sopen[1] ? na : color.black


plot(Camarilla_Display ? h4_ : na, title='H4', color=sopen != sopen[1] ? na : #BCae2d, style=plot.style_cross, linewidth=2)
plot(Camarilla_Display ? h3_ : na, title='H3', color=sopen != sopen[1] ? na : #f0da19, style=plot.style_cross, linewidth=2)
plot(Camarilla_Display ? l3_ : na, title='L3', color=sopen != sopen[1] ? na : #00ff0e, style=plot.style_cross, linewidth=2)
plot(Camarilla_Display ? l4_ : na, title='L4', color=sopen != sopen[1] ? na : #389d3d, style=plot.style_cross, linewidth=2)
plot(Camarilla_Display ? h2_ : na, title='H2', color=sopen != sopen[1] ? na : #fff176, style=plot.style_cross, linewidth=1)
plot(Camarilla_Display ? h1_ : na, title='H1', color=sopen != sopen[1] ? na : #fff176, style=plot.style_cross, linewidth=1)
plot(Camarilla_Display ? l1_ : na, title='L1', color=sopen != sopen[1] ? na : #66bb6a, style=plot.style_cross, linewidth=1)
plot(Camarilla_Display ? l2_ : na, title='L2', color=sopen != sopen[1] ? na : #66bb6a, style=plot.style_cross, linewidth=1)
````
