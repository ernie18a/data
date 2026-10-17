# rt maax EMA cross strategy

- url: https://www.tradingview.com/script/QgiJQoBE-rt-maax-EMA-cross-strategy/
- type: strategy
- pine_id: PUB;f1588589adc34304868ec34dbb68107b
- version: 4.0

## Description

this just sample of our strategies we published with open source, to learning our investor the way of trading and analysis, this strategy just for study and learning 
in this strategy we use expontial moving avarage 20 , 50 , 200 and the we build this strategy when the price move up ema 200 and ema 20,50 cross up the 200 ema in this conditions the strargey will open long postion 

and the oppisit it is true for short postion in this sitation the price should be under ema 200 and the ema 20 , 50 should cross under 200 ema then the strategy will open the short postion 

we try this strategy on forex ,crypto and futures and it give us  very good result ,, also we try this postion on multi time frame we find the stragey give us good result on 1 hour time frame .

in the end our advice for you before you use any stratgy you should have the knowledg of the indecators how it is work and also you should have information about the market you trade and the last news for this market beacuse it effect so much on the price moving .

so we hope this strategy give you brefing of the way we work and build our strategy

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//made by MSD TRADING
//@version=5

strategy(title = "MSD EMA cross strategy", shorttitle = "MSD 1 ", overlay = true, precision = 8, max_bars_back = 200, pyramiding = 0, initial_capital = 100000, 
     currency = currency.USD, default_qty_type = strategy.cash, default_qty_value = 100000, commission_type = "percent", commission_value = 0.27)
fastema = ta.ema (close , 50)
fema=ta.ema(close,20)
slowema= ta.ema(close,200)
price = close

// === INPUT BACKTEST RANGE ===
fromMonth = input.int(defval = 1,    title = "From Month",  minval = 1, maxval = 12)
fromDay   = input.int(defval = 1,    title = "From Day",    minval = 1, maxval = 31)
fromYear  = input.int(defval = 2021, title = "From Year",   minval = 1970)
thruMonth = input.int(defval = 10,    title = "Thru Month",  minval = 1, maxval = 12)
thruDay   = input.int(defval = 25,    title = "Thru Day",    minval = 1, maxval = 31)
thruYear  = input.int(defval = 2112, title = "Thru Year",   minval = 1970)

// === INPUT SHOW PLOT ===
showDalte  = input(defval = true, title = "Show Date Range")

// === FUNCTION EXAMPLE ===



longCondition1= ta.crossover (fema , fastema) 
longcondition2= fema> slowema
longcondition3=fastema>slowema


if (longCondition1 and longcondition2 and longcondition3 )
    stoploss=low*0.97
    takeprofit=high*1.12
    strategy.entry("Long Entry", strategy.long)
    strategy.exit ("exit","long",stop=stoploss,limit=takeprofit)
   


shortCondition1 = ta.crossunder (fema , fastema )
shortcondition2= fastema< slowema
shortcondition3= fema< slowema

if (shortCondition1 and shortcondition2 and shortcondition3 )
    stoploss=low*0.97 
    takeprofit=high*1.5
    strategy.entry("Short Entry", strategy.short)
    strategy.exit("exit","short",stop=stoploss,limit=takeprofit)
````
