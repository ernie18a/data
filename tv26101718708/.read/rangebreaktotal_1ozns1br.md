# rangebreak(total)

- url: https://www.tradingview.com/script/1ozNs1BR-rangebreak-total/
- type: strategy
- pine_id: PUB;d20fbFioB44PjXy2sn28VLmRK3MvMrEk
- version: 1.0

## Description

Range Break Strategy using Coin Market Cap

## Source Code

````pine
//@version=3
strategy(title = "rangebreak(total)", shorttitle = "rangebreak", overlay = true,pyramiding=1)
timescale = (time > timestamp(2019, 1, 1, 00, 00) and time < timestamp(2019, 12, 31, 00, 00))

total =  security("CRYPTOCAP:TOTAL", period, close)

source = total

//Logic
term=input(44)

Buy_IN = highest(source[1],term)<source
Sell_IN = lowest(source[1],term)>source


if Buy_IN 
    strategy.entry("BUY", strategy.long, na, when=timescale)
if Sell_IN
    strategy.entry("SELL", strategy.short, na, when=timescale)
````
