# SLOW RSI OB/OS Strategy

- url: https://www.tradingview.com/script/xLBZSeTs-SLOW-RSI-OB-OS-Strategy/
- type: strategy
- pine_id: PUB;h9oqRTPhhYNB4uYeNFDQnWxiAdN5Wssl
- version: 1.0

## Description

Slowing the RSI down opens up a whole new world of possibilities. 
This concept can work for a lot of TA indicators including the MACD.

See script source code for further description. Feel free to add pyramid trades at your own discretion in your format menu.
No this doesn't repaint!

## Source Code

````pine

// Wilder was a very influential man when it comes to TA. However, I'm one to always try to think outside the box. 
// While Wilder recommended that the RSI be used only with a 14 bar lookback period, I on the other hand think there is a lot to learn from RSI if one simply slows down the lookback period 
// Same applies for MACD.
// Every market has its dynmaics. So don't narrow your mind by thinking my source code input levels are the only levels that work.
// Since the long lookback period weakens the plot volatility, again, one must think outside the box when trying to guage overbought and oversold levels. 

// Good luck and don't bash me if some off-the-wall FA spurned divergence causes you to lose money.
// And NO this doesn't repaint and I won't answer those who ask. 


strategy("SLOW RSI OB/OS Strategy", overlay=false, pyramiding=0, calc_on_order_fills=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, currency="USD", default_qty_value=100)
price = input(ohlc4, title="Price Source")
len = input(500, minval=1, step=5,  title="RSI Length")
smoother = input(250, minval=1, step=5, title="RSI SMA")
up = rma(max(change(price), 0), len)
down = rma(-min(change(price), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
EmaRSI = ema(rsi,smoother)
plot(EmaRSI, title="EmaRSI", style=line, linewidth=1, color=yellow)


OB = input(52, step=0.1)
OS = input(48, step=0.1)
hline(OB, linewidth=1, color=red)
hline(OS,linewidth=1, color=green)
hline(50,linewidth=1, color=gray)


long = change(EmaRSI) > 0 and EmaRSI <= 50 and crossover(EmaRSI, OS)
short = change(EmaRSI) < 0 and EmaRSI >= 50 and crossunder(EmaRSI, OB)


strategy.entry("Long", strategy.long, when=long) //_signal or long) //or closeshort_signal)
strategy.entry("Short", strategy.short, when=short) //_signal or short) // or closelong_signal)

// If you want to try to play with exits you can activate these!

//closelong = crossunder(EmaRSI, 0) //or crossunder(EmaRSI, OS)
//closeshort = crossover(EmaRSI, 0) //or crossover(EmaRSI, OB)

//strategy.close("Long", when=closelong)
//strategy.close("Short", when=closeshort)
````
