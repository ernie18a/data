# TSI BTCUSD WS

- url: https://www.tradingview.com/script/paq771aX-TSI-BTCUSD-WS/
- type: strategy
- pine_id: PUB;C6x6pBpKaa4Agw2DPj41tvpIn5ujxhPa
- version: 2.0

## Description

Script based on True Strength Index (TSI) and RSI

## Source Code

````pine
strategy("TSI BTCUSD WS", shorttitle="TSI BTCUSD WS",initial_capital=100000, commission_value=0.2, commission_type =strategy.commission.percent, default_qty_value=1 , overlay = false, pyramiding=1, default_qty_type=strategy.fixed)
//study("True Strength Indicator BTCUSD 2H", shorttitle="TSI BTCUSD WS)

//BASED ON True Strength Indicator MTF
resCustom = input(title="Timeframe", type=resolution, defval="240" )
long = input(title="Long Length", type=integer, defval=10)
short = input(title="Short Length", type=integer, defval=10)
signal = input(title="Signal Length", type=integer, defval=15)
price = security(tickerid,resCustom,close)


double_smooth(src, long, short) =>
    fist_smooth = ema(src, long)
    ema(fist_smooth, short)
pc = change(price)
double_smoothed_pc = double_smooth(pc, long, short)
double_smoothed_abs_pc = double_smooth(abs(pc), long, short)
tsi_value = 100 * (double_smoothed_pc / double_smoothed_abs_pc)
tsi2=ema(tsi_value, signal)
plot(tsi_value, color=lime,linewidth=2)
plot(tsi2, color=red,linewidth=2)




rsiserie = rsi(price,14)

plot(rsiserie,color=purple)



hline(30, title="Zero")
hline(50, title="Zero",linestyle=solid, linewidth=2)
hline(70, title="Zero")

buy = crossover(tsi_value, tsi2)
sell = crossunder(tsi_value, tsi2)

strategy.entry("BUY", strategy.long, 1, when = buy)
strategy.entry("SELL", strategy.short, 1, when = sell ) 

greentsi =tsi_value
redtsi = tsi2

bgcolor( greentsi>redtsi and rsiserie > 50 ? lime : na, transp=90)
bgcolor( greentsi<redtsi and rsiserie < 50 ? red : na, transp=90)

yellow1= redtsi > greentsi and rsiserie > 50 
yellow2 = redtsi < greentsi and rsiserie < 50 
bgcolor( yellow1 ? yellow : na, transp=80)
bgcolor( yellow2  ? yellow : na, transp=50)

bgcolor( yellow1 and yellow1[1] ? yellow : na, transp=70)
bgcolor( yellow2  and yellow2[2] ? yellow : na, transp=70)

bgcolor( rsiserie > 70 ? lime : na, transp=60)
bgcolor( rsiserie < 30  ? red : na, transp=60)

// Generate Alert Arrows
 
//plotarrow(buy==1?1:na, title="BUY Arrow", colorup=lime, maxheight=60, minheight=50, transp=20)
//plotarrow(sell==1?-1:na, title="SELL Arrow", colordown=red, maxheight=60, minheight=50, transp=20)
 
// Generate Alarm signals.
//alertcondition(buy==1 or sell==1,title="Swing Alert Arrow",message="Swing Alert")
````
