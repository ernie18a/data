# Pure Mark Minervini 10%TP 5%CL

- url: https://www.tradingview.com/script/H9HxZ9Zc-Pure-Mark-Minervini-10-TP-5-CL/
- type: strategy
- pine_id: PUB;86e91c083fef4238927f72a5f224a100
- version: 3.0

## Description

[b]Backtesting Mark Miniverni Template
By Donnie Lee[/b]

Overall, a good basic guideline from Mark Miniverni to choose which stock to buy. His selection are said to be stocks in stage 2 uptrend phase which could see price surge soon.
This script enable backtesting of Mark template (Investor's Business Ranking Excluded) on equity like stocks

Further fine tuning with additional filters are needed to find good entry with desired cut loss level and position sizing.
There is no holy grail strategy. Choose one with an edge that you are comfortable with and stick to it.
Losing is part and parcel of trading. Hesitation to cut loss can lead to big loss. And if you can avoid losing big, you might stand a chance to profit in the end.


Mark Miniverni Template
1. The current stock price is above both the 150-day (30-week) and the 200-day (40-week) moving average price lines.
2. The 150-day moving average is above the 200-day moving average.
3. The 200-day moving average line is trending up for at least 1 month (preferably 4–5 months minimum in most cases).
4. The 50-day (10-week) moving average is above both the 150-day and 200-day moving averages.
5. The current stock price is trading above the 50-day moving average.
6. The current stock price is at least 25% above its 52-week low (30% as per his book 'Trade Like a Stock Market Wizard').
7. The current stock price is within at least 25% of its 52-week high (the closer to a new high the better).[b][/b]

## Source Code

````pine
//@version=4
strategy(title="Pure Mark Minervini 10%TP 5%CL", pyramiding = 0, commission_type=strategy.commission.percent, commission_value=0.08, overlay=true)

ma50 = sma(close,50)
ma150 = sma(close,150)
ma200 = sma(close,200)
ma200_22 = ma200[22]

high_loopback = input(260, "High Lookback Length")
low_loopback = input(260, "Low Lookback Length")
highest_price = highest(high, high_loopback)
lowest_price = lowest(low, low_loopback)
above52lo = ((close/lowest_price)-1)*100
below52hi = (1-(close/highest_price))*100
ep = strategy.position_avg_price


buy = close>ma150 and close>ma200 and ma150>ma200 and ma200>ma200_22 and ma50>ma150 and ma50>ma200 and close>ma50 and above52lo>=25 and below52hi<=25 and close>0.3
sell = close>ep*1.1 or close<ep*0.95

strategy.entry("TF", strategy.long, when = buy)
strategy.close("TF", when = sell)
````
