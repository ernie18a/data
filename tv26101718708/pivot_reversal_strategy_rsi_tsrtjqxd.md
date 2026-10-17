# Pivot Reversal Strategy + RSI

- url: https://www.tradingview.com/script/TsRtJQXd-Pivot-Reversal-Strategy-RSI/
- type: indicator
- pine_id: PUB;zQSYqxixmvoCXwvX10sTLDsxFM25IR9W
- version: 2.0

## Description

[b]Pivot Reversal Strategy + RSI[/b]

A modified version of the standard PRS with an RSI overbought/oversold filter

Comment/uncomment "Study/Strategy" to easily switch to strategy() mode
As long as it is used in the study() version, the indicator is compatible with the [url=https://www.tradingview.com/script/6MYLOs5H-Ultimate-Risk-Management-System/]Risk Management Wrapper[/url]

Separate Alerts for Buy & Sell signals
Single Alert for both Buy & Sell signals - it can also be used by another indicator as a source

## Source Code

````pine
//@version=4
// comment/uncomment Study/Strategy to easily switch to strategy() mode
// as long as it is used in the study() version, the indicator is compatible with the Risk Management Wrapper (https://www.tradingview.com/script/6MYLOs5H-Ultimate-Risk-Management-System/)
study("Pivot Reversal Strategy + RSI | Alerts", overlay=true)          // ---------------------- STUDY -----------------------
// strategy("Pivot Reversal Strategy + RSI | Strategy", overlay=true)  // --------------------- STRATEGY ---------------------

leftBars  = input(4)
rightBars = input(2)
rsi_ob = input(58, title="rsi - overbought level")
rsi_os = input(42, title="rsi - oversold   level")

swh = pivothigh(leftBars,rightBars)
swl = pivotlow(leftBars, rightBars)
pivots = not na(swh)? swh: not na(swl)? swl : na

swh_cond = not na(swh)
hprice = 0.0
hprice := swh_cond ? swh : hprice[1]
le = false
le := swh_cond ? true : (le[1] and high > hprice ? false : le[1]) and (rsi(close, 14)<rsi_ob)

swl_cond = not na(swl)
lprice = 0.0
lprice := swl_cond ? swl : lprice[1]
se = false
se := swl_cond ? true : (se[1] and  low < lprice ? false : se[1]) and (rsi(close, 14)>rsi_os)

le_se = 0
le_se := ( crossover(high,hprice+syminfo.mintick) )? +1 : ( crossunder(low,lprice-syminfo.mintick) )? -1 : nz(le_se[1])
_le_se = le_se[1]==-1 and le_se==+1 and rsi(close, 14)<rsi_ob? 1 : le_se[1]==+1 and le_se==-1 and rsi(close, 14)>rsi_os? -1 :0 // single variable for alerts

// // single plot alerts required by other indicators, such as the Risk Management Wrapper (https://www.tradingview.com/script/6MYLOs5H-Ultimate-Risk-Management-System/)
// plot(_le_se, title="BUY SELL alerts", color=le_se==-1?color.red:color.green, style=plot.style_areabr) // uncomment to activate

plot(hprice+syminfo.mintick, color=#24e47f, transp=80, style=plot.style_stepline, linewidth=4)
plot(hprice+syminfo.mintick, color=#00ff00, transp=00, style=plot.style_stepline)
plot(lprice-syminfo.mintick, color=#ff4554, transp=80, style=plot.style_stepline, linewidth=4)
plot(lprice-syminfo.mintick, color=#ff0000, transp=00, style=plot.style_stepline)
plot(pivots, color=pivots==swh?color.teal:color.aqua, transp=0, style=plot.style_line, linewidth=1)
plot(pivots, color=pivots==swh?color.teal:color.aqua, transp=0, style=plot.style_circles, linewidth=4)
plotshape(_le_se==+1, color=color.lime,style=shape.triangleup,  location=location.belowbar, size=size.small)
plotshape(_le_se==-1, color=color.red, style=shape.triangledown,location=location.abovebar, size=size.small)

// ---------------------- STUDY -----------------------
alertcondition(_le_se, title='*** BUY SELL alerts ***', message='*** BUY SELL alerts ***')
alertcondition(_le_se==+1, title='*** BUY alert ***',  message='*** BUY alert ***')
alertcondition(_le_se==-1, title='*** SELL alert ***', message='*** SELL alert ***')
// ---------------------- STUDY -----------------------

// // --------------------- STRATEGY --------------------- this simulates an alarm that is set to fire "Only Once" (check alarm settings)
// if ( le and rsi(close, 14)<rsi_ob )
//     strategy.entry("PivRevLE", strategy.long,  comment="PivRevLE", stop=hprice + syminfo.mintick)
// if ( se and rsi(close, 14)>rsi_os )
//     strategy.entry("PivRevSE", strategy.short, comment="PivRevSE", stop=lprice - syminfo.mintick)
// //plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
// // --------------------- STRATEGY ---------------------
````
