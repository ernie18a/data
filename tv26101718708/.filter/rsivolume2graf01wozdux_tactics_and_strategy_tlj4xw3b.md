# RSIVolume_2graf.01[wozdux] Tactics and strategy 

- url: https://www.tradingview.com/script/tlJ4xw3b-rsivolume-2graf-01-wozdux-tactics-and-strategy/
- type: indicator
- pine_id: PUB;5haVAfZgmtKon3UvKTSUR5R3IyF2jA9w
- version: 1.0

## Description

Tactics and strategy 
The indicator combines 2 variants of the RSI indicator. The first option is calculated relative to the normal close price. The second option is calculated relative to the volume price. The volume price is calculated as the product of the volume price. For normal RSI, the default period is 9, for the volume price .
Settings. Level_close sets the width of the middle region, the oscillations of the indicator chart for the average of the closing price. Level_volume*close sets the critical level for the volume price. Period 24 (len1) specifies the RSI calculation period for the volume price. Period 9 (len3) specifies the RSI calculation period for the regular price.
The combination of two versions of the indicator helps to see more truthful information about the mood of buyers and sellers. When the volume price reaches its critical level of 8 units, it is a signal to a strong fall in the price.  In this state, you should monitor the classic RSI. Thus, the classic RSI determines the tactical movement, and the volumetric RSI – strategic.

-------------------------------------
Тактика и стратегия 
Индикатор совмещает в себе 2 варианта индикатора RSI. Первый вариант вычисляется относительно обычной цены закрытия. Второй вариант вычисляется относительно объемной цены. Объемную цену  вычисляют как произведение цены на объем. Для обычного RSI по умолчанию берется период 9 , для объемной цены .
Настройки. Level_close   задает ширину средней области колебания графика индикатора для обычной цены закрытия. Level_volume*close задает критический уровень для объемной цены. Период 24 (len1) задает период вычисления RSI для объемной цены. Период 9(len3) задает период вычисления RSI для обычной цены.
Сочетание двух вариантов индикатора помогает  увидеть более правдивую информацию о настроениях покупателей и продавцов. Когда объемная цена достигает своего критического уровня 8 единиц, то это является сигналом к сильному  падению цены.  В этом состоянии следует следить за классической RSI. Таким образом классическое RSI  определяет тактическое движение, а объемное RSI – стратегическое.

## Source Code

````pine
//
// @wozdux
// гладкие линии -это rsi от обычной цены
// красная линия=это самая быстрая. Она показывает  интенсинвость закупок по сравнению с продажами
// прерывистые линии показывают rsi по объемной цене.
// фактически rsi-это интенсивность закупок
// поэтому объемная rsi это включение объема в импульс.
study(title="RSIVolume_2graf.01[wozdux] ", shorttitle="RSIVol_2graf.01")
uplimit = input(70, minval=1,title="level_close")
urvol = input(8, minval=1,title="level_volume*close")
dnlimit=100-uplimit
cena = close
h0 = hline(uplimit, linestyle=dotted,title="color70")
h1 = hline(dnlimit,linestyle=dotted,title="color30")
h50 = hline(50,linestyle=dotted, title="color50")
fill(h0, h50, color= green)
fill(h1, h50, color= red)
len1 = input(24, minval=1,title="rsi(close*volume,len1)")
len3 = input(9, minval=1, title="rsi(close,len3)")
// БЕРЕМ ЗА ОСНОВУ ОБЪЕМНУЮ ЦЕНУ
/////////////////////////////////////////////////////
// ОБЪЕМНАЯ ЦЕНА ЗА ДЛИННЫЙ ПЕРИОД=СРЕДНЯЯ ЦЕНА НА ЕДИНИЦУ ОБЪЕМА
aaa1 = ema( volume * cena, len1 ) / ema( volume, len1 ) 
/////////объемная цена/////////////////////
rsi11 = rsi(aaa1, len1)
plot(rsi11, color=blue, style=circles,linewidth=2, title="rsi(close*volume,len1)")
//////////обычная цена////////////////////////////////
rsi3 = rsi(cena, len3)
rs3=plot(rsi3, color=red, linewidth=2 , title="rsi(close,len3)")
/////////раскрашиваем уровни/////////////////////////

uu = hline(urvol, linestyle=dotted,title="color70")
uu0 = hline(urvol-3, linestyle=solid, title="color70")
fill(uu, uu0, color=yellow, transp=80)
///////////////////////////////////////////////////////////
// окрашиваем графики выше и ниже уровня
upl=uplimit,dnl=dnlimit,rrr=rsi3,rrs=rs3
col=red
bs = (rrr >upl) ? upl :rrr
us = (rrr < dnl) ? dnl : rrr
bl=plot(bs, color=col)
ul=plot(us, color=col)

fill(bl, rrs, color=red, transp=40)
fill(ul, rrs, color=lime, transp=40)
````
