# True Strength Indicator BTCUSD 15p thaieibvn

- url: https://www.tradingview.com/script/VWrDRERB-True-Strength-Indicator-BTCUSD-15p-thaieibvn/
- type: strategy
- pine_id: PUB;gutQ5l5PPFbwY4qYPYXBEXRsngouXoJu
- version: 1.0

## Description

True Strength Indicator BTCUSD 15p thaieibvn

## Source Code

````pine
strategy("True Strength Indicator BTCUSD 15p", shorttitle="TSI BTCUSD 15p",initial_capital=1000, commission_value=0.15, commission_type =strategy.commission.percent, default_qty_value=100 , overlay = false, pyramiding=10, default_qty_type=strategy.percent_of_equity)

//BASED ON True Strength Indicator MTF
resCustom = input(title="Timeframe", type=resolution, defval="15" )
long = input(title="Long Length", type=integer, defval=25)
short = input(title="Short Length", type=integer, defval=13)
signal = input(title="Signal Length", type=integer, defval=13)
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




rsiserie = rsi(price,7)
cciserie = cci(price,14)
stochserie = stoch(price,14,3,3)

plot(rsiserie,color=purple)



hline(30, title="Zero")
hline(50, title="Zero",linestyle=solid, linewidth=2)
hline(70, title="Zero")

buy = crossover(tsi_value, tsi2) //and rsiserie[1]<25 //and cciserie<-100 and stochserie<20
sell = crossunder(tsi_value, tsi2) //and rsiserie[1]>85 //and cciserie>100 and stochserie>80


alertcondition(buy, title='TSI system', message='Buy signal at!' )
alertcondition(sell, title='TSI system', message='Sell signal at!' )

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
````
