# Bitlinc MARSI Study AST w/ Take Profit & Stop loss - beta 0.1

- url: https://www.tradingview.com/script/tlggvJRH-Bitlinc-MARSI-Study-AST-w-Take-Profit-Stop-loss-beta-0-1/
- type: strategy
- pine_id: PUB;iWb84322yCOckVwQzhDyd8gTBfskC2jZ
- version: 2.0

## Description

[b]This script is beta 0.1 - will update as soon as the script is tradable [/b]

This script is based on AST on a 10 minute timeframe. You can change the asset and the timeframe for any asset you want to trade, but for it to work correct ALL settings have to be testes in the Strategy section of the TradingView. Each assets and timeframe require a different mixture of settings. This is NOT a one settings fits all trading for all assets on any timeframe. Below are the settings and explanation on how it works. 


[b]How it fires a buy / sell: [/b]
The script will plot an RSI with upper and lower bands in a separate indicator window. The idea behind this script is to fire a LONG when MA crosses OVER lower band and fire a SHORT when the MA crosses under the lower band. Each order that fires is an OCO (Order Cancels Order) for pyramiding. 

[b]Settings:[/b]
You have full control of these settings as mentioned above, you must configure every part of this script for each asset and timeframe you trade. 

 - Length of MA
 - Length 
 - Upper bands of RSI 
 - Lower bands of RSI
 - Take profit percentage 
 - Stop loss percentage
 - Month to start and end the strategy (within 2020)
 - Day to start and end the strategy (within 2020)
 - Quantity type
 - Slippage
 - Pyramiding 

***Remember that after the signal to enter or exit a trade is fired, the alert will trigger AFTER the close of the candle that caused the tigger to fire

## Source Code

````pine
//@version=3
strategy(title = "Bitlinc MARSI Study AST",shorttitle="Bitlinc MARSI Study AST",default_qty_type = strategy.percent_of_equity, default_qty_value = 100,commission_type=strategy.commission.percent,commission_value=0.1,initial_capital=1000,currency="USD",pyramiding=0, calc_on_order_fills=false)

// === General Inputs ===
lengthofma = input(62, minval=1, title="Length of MA")
len = input(31, minval=1, title="Length")
upperband = input(89, minval=1, title='Upper Band for RSI')
lowerband = input(10, minval=1, title="Lower Band for RSI")
longtakeprofit =input(1.25, title="Long Take Profit Percent")
shorttakeprofit =input(1.25, title="Short Take Profit Percent")
longstoploss =input(.04, title ="Long Stop Loss Percent")
shortstoploss =input(.04, title ="Short Stop Loss Percent")
monthfrom =input(8, title = "Month Start")
monthuntil =input(12, title = "Month End")
dayfrom=input(1, title= "Day Start")
dayuntil=input(31, title= "Day End")

// === Innput Backtest Range ===
//FromMonth = input(defval = 9, title = "From Month", minval = 1, maxval = 12)
//FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
//FromYear  = input(defval = 2018, title = "From Year", minval = 2017)
//ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
//ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
//ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

// === Create RSI ===
src=sma(close,lengthofma)
up = rma(max(change(src), 0), len)
down = rma(-min(change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
plot(rsi,linewidth = 2, color=purple)

// === Plot Bands ===
band1 = hline(upperband)
band0 = hline(lowerband)
fill(band1, band0, color=blue, transp=95)

// === Entry and Exit Methods ===
longCond =  crossover(rsi,lowerband)
shortCond =  crossunder(rsi,upperband)

// === Long Entry Logic ===
if (  longCond    and  month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil) 
    strategy.entry("LONG", strategy.long, stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="LONG")
else
    strategy.cancel(id="LONG")

// === Short Entry Logic ===    
if ( shortCond   and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil ) 
    strategy.entry("SHORT", strategy.short,stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="SHORT")
else
    strategy.cancel(id="SHORT")

// === Take Profit and Stop Loss Logic ===
strategy.exit("LONG EXIT", "LONG", profit = close * longtakeprofit / syminfo.mintick, loss = close * longstoploss / syminfo.mintick)
strategy.exit("SHORT EXIT", "SHORT", profit = close * shorttakeprofit / syminfo.mintick, loss = close * shortstoploss / syminfo.mintick)
````
