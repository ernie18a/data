# Target Fusion Overlay TheGutixx

- url: https://www.tradingview.com/script/BJt20Ylf/
- type: indicator
- pine_id: PUB;49d0430fee914a1bb444773e5218a7df
- version: 1.0

## Description

TheGutixx Fusion Overlay es un indicador avanzado de análisis técnico diseñado para combinar en una sola herramienta la fuerza del RSI Trend, la estructura de tendencia mediante EMA 9/21 y un sistema visual de objetivos de precio.

Este indicador ayuda a identificar posibles oportunidades de mercado mediante la combinación de momentum, dirección de tendencia y estructura del precio, mostrando señales visuales directamente sobre el gráfico.

Características principales:

✅ RSI Trend Integration
Detecta cambios de momentum y posibles giros de tendencia mediante el comportamiento del RSI y Hull Trend.

✅ EMA 9/21 Trend System
Utiliza cruces de medias exponenciales para visualizar cambios de dirección del mercado y zonas de posible continuación.

✅ CALL & PUT Signals
Señales visuales integradas sobre el gráfico para facilitar la lectura de oportunidades alcistas y bajistas.

✅ Bull & Bear Targets
Proyección automática de objetivos de precio después de los cruces EMA, ayudando a visualizar posibles zonas de movimiento.

✅ Multi-Market Compatible
Diseñado para utilizarse en diferentes mercados:

📈 Acciones (Stocks)
💱 Forex
₿ Criptomonedas
📊 Índices

✅ Multi-Timeframe
Puede utilizarse en diferentes temporalidades, desde scalping en marcos pequeños hasta análisis de mayor duración.

✅ Alertas TradingView
Compatible con alertas personalizadas para señales y cruces importantes.

TheGutixx Fusion Overlay fue creado para traders que buscan una lectura más limpia del mercado combinando tendencia, momentum y objetivos en un solo indicador.

## Source Code

````pine
//@version=6
indicator("RSITrend + EMA 9/21 Target Fusion Overlay", overlay=true, max_lines_count=500, max_labels_count=500)


//================ RSI TREND =================//

[plus,minus,adx]=ta.dmi(14,14)

sw=input.bool(true,'Highlight Ranging/Sideways')
showbarcolor=input.bool(true,'Apply Barcolor')
show_Baseline=input.bool(true,'Show Hull Trend')

rsiLengthInput=input.int(14,minval=1,title="RSI Length 1")
rsiLengthInput2=input.int(28,minval=1,title="RSI Length 2")

trendlen=input.int(30,title="Hull Trend Length")

oversold=input.int(30,title="Over Sold")
overbought=input.int(70,title="Over Bought")


BBMC=ta.hma(close,trendlen)

MHULL=BBMC
SHULL=BBMC[2]


hullBull=MHULL > SHULL
hullBear=MHULL < SHULL


frsi=ta.hma(ta.rsi(close,rsiLengthInput),10)
srsi=ta.hma(ta.rsi(close,rsiLengthInput2),10)


hullrsi1=ta.rsi(MHULL,rsiLengthInput)
hullrsi2=ta.rsi(SHULL,rsiLengthInput)



rsiBuySignal =
     hullBull and hullBear[1]


rsiSellSignal =
     hullBear and hullBull[1]



plotshape(
 rsiBuySignal,
 title="RSI BUY",
 style=shape.labelup,
 location=location.belowbar,
 color=color.green,
 text="CALL",
 textcolor=color.white,
 size=size.small)


plotshape(
 rsiSellSignal,
 title="RSI SELL",
 style=shape.labeldown,
 location=location.abovebar,
 color=color.red,
 text="PUT",
 textcolor=color.white,
 size=size.small)



alertcondition(
 rsiBuySignal,
 title="RSI CALL",
 message="RSI TREND CALL")


alertcondition(
 rsiSellSignal,
 title="RSI PUT",
 message="RSI TREND PUT")



//================ EMA 9/21 =================//


arraylookback=input.int(500,"Target Lookback")

showlbls=input.bool(true,"Show Target Labels")



ema9=ta.ema(close,9)

ema21=ta.ema(close,21)



emaBullCross=ta.crossover(ema9,ema21)

emaBearCross=ta.crossunder(ema9,ema21)



plotshape(
 emaBullCross,
 title="EMA BUY",
 location=location.belowbar,
 style=shape.triangleup,
 color=color.lime,
 size=size.small)


plotshape(
 emaBearCross,
 title="EMA SELL",
 location=location.abovebar,
 style=shape.triangledown,
 color=color.red,
 size=size.small)



bullish=close>=ema9 and close>=ema21

bearish=close<=ema9 and close<=ema21


emaColor =
 bullish ? color.lime :
 bearish ? color.red :
 color.gray



p1=plot(
 ema9,
 color=emaColor,
 linewidth=2,
 title="EMA 9")


p2=plot(
 ema21,
 color=emaColor,
 linewidth=2,
 title="EMA 21")



fill(
 p1,
 p2,
 color=color.new(emaColor,80))



//================ TARGETS =================//


bullArr=array.new_float()
bearArr=array.new_float()


for i=0 to arraylookback

    if bullish[i]
        array.push(bullArr,close[i])

    if bearish[i]
        array.push(bearArr,close[i])



maxBull=array.size(bullArr)>0 ? array.max(bullArr) : close

minBear=array.size(bearArr)>0 ? array.min(bearArr) : close



bullRange=(maxBull-close)/2

bearRange=(close-minBear)/2



var line bullTarget1=na
var line bullTarget2=na

var line bearTarget1=na
var line bearTarget2=na



var label bullLbl1=na
var label bullLbl2=na

var label bearLbl1=na
var label bearLbl2=na



if emaBullCross and barstate.isconfirmed


    line.delete(bullTarget1)
    line.delete(bullTarget2)

    label.delete(bullLbl1)
    label.delete(bullLbl2)



    t1=close+bullRange

    t2=close+(bullRange*2)



    bullTarget1:=line.new(
     bar_index,
     t1,
     bar_index+1,
     t1,
     extend=extend.right,
     color=color.green,
     width=3)



    bullTarget2:=line.new(
     bar_index,
     t2,
     bar_index+1,
     t2,
     extend=extend.right,
     color=color.green,
     width=3)



    if showlbls

        bullLbl1:=label.new(
         bar_index,
         t1,
         "Bull Target 1\n"+str.tostring(t1),
         color=color.green,
         textcolor=color.white)



        bullLbl2:=label.new(
         bar_index,
         t2,
         "Bull Target 2\n"+str.tostring(t2),
         color=color.green,
         textcolor=color.white)




if emaBearCross and barstate.isconfirmed


    line.delete(bearTarget1)
    line.delete(bearTarget2)

    label.delete(bearLbl1)
    label.delete(bearLbl2)



    t1=close-bearRange

    t2=close-(bearRange*2)



    bearTarget1:=line.new(
     bar_index,
     t1,
     bar_index+1,
     t1,
     extend=extend.right,
     color=color.red,
     width=3)



    bearTarget2:=line.new(
     bar_index,
     t2,
     bar_index+1,
     t2,
     extend=extend.right,
     color=color.red,
     width=3)



    if showlbls

        bearLbl1:=label.new(
         bar_index,
         t1,
         "Bear Target 1\n"+str.tostring(t1),
         color=color.red,
         textcolor=color.white)



        bearLbl2:=label.new(
         bar_index,
         t2,
         "Bear Target 2\n"+str.tostring(t2),
         color=color.red,
         textcolor=color.white)



alertcondition(
 emaBullCross,
 title="EMA Bull Cross",
 message="EMA 9/21 Bullish")


alertcondition(
 emaBearCross,
 title="EMA Bear Cross",
 message="EMA 9/21 Bearish")
````
