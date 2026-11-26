# ISM Indicator As a Strategy  

- url: https://www.tradingview.com/script/XDWNySNY-ISM-Indicator-As-a-Strategy/
- type: strategy
- pine_id: PUB;2018
- version: -1.0

## Description

Here's a very easy code, plotting the ISM against the SPX. In this exercise, i wanted to see if one could use the ISM indicator only to generate buy/sell signal, and what would be the performance.  

[b]What is the ISM[/b]

The ISM Manufacturing Index monitors employment, production inventories, new orders and supplier deliveries.By monitoring the ISM Manufacturing Index, investors are able to better understand national economic conditions. When this index is increasing, investors can assume that the stock markets should increase because of higher corporate profits. The opposite can be thought of the bond markets, which may decrease as the ISM Manufacturing Index increases because of sensitivity to potential inflation.

[b]Buy/Sell Signal[/b]

ISM  above 50 usually good economic condition and  vice versa when below 50 . For this code I used 48.50 as my buy/sell signal line.

[b]Results[/b]

To test this on a longer time period, I use the SPX index instead of SPY. The results are surprisingly good. 76.92% profitability with 3.03 profit factor. 

[b]Conclusion  [/b]

Investors could use the ISM with other indicators to determine better entry and exit point. I will see if combining the ISM with other custom indicators , could generate better result. Feel free to share your results here.

Cheers 

Algo.

## Source Code

````pine
//@version=2
strategy("ISM Indicator Strategy ", overlay=true)

ism = security("MAN_PMI","M",close)

buy = ism > 48.50
sell = ism < 48.50

longCondition = buy
if (longCondition)
    strategy.entry("My Long Entry Id", strategy.long)
strategy.close_all(when = sell)

mid = 48.50

plot (mid, color = lime)
````
