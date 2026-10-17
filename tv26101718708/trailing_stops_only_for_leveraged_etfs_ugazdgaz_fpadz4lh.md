# Trailing Stops Only - For Leveraged ETFs (UGAZ/DGAZ)

- url: https://www.tradingview.com/script/fpAdz4lh-Trailing-Stops-Only-For-Leveraged-ETFs-UGAZ-DGAZ/
- type: strategy
- pine_id: PUB;IjdKt630qN0CS3RV2ZwG9OZjr4uJ6Y4K
- version: 1.0

## Description

Looking for Statistical trades that work.  This one seems to work on some Leveraged ETFs with a lot of noise like UGAZ/DGAZ.  It can also be used on Futures Contracts, but be sure to change up the type of investment from % of equity to contracts.  Also one point I'm trying to make with this strategy is the trades are best made in the morning around market open.  When used with Contracts, be sure to make use of the time settings.  It will limit buying between the hours set.  Selling will occur at any time the trailing stop is triggered.  

This Strategy is best used on 5min or 15min charts.

!!!! very important !!!!
Due to decay, leveraged ETFs will give false results if the price gets far out of range.  For example, your ETF is trading around $20 and you choose a 1 hour chart, it may back test back to a time before a reverse split.  If the price gets to be too large, like $200, or $1200, the movement on the chart creates false indication of profit/loss.  

Most important.  Do not trade off this strategy, you may lose lots of money.  This is for educational use only.

## Source Code

````pine
//@version=3
strategy("Trailing Stops Only", overlay=true, initial_capital=25000, default_qty_type=strategy.percent_of_equity, default_qty_value=20)

stop = input(25, "Trailing Stop (in ticks)")
longorshort = input(true, "Go Long/Short")
tpd = input(4, "Max Trades Per Day", minval=2, step=2)
timec = input(true, "Limit Time of Day (Buying Side)")

//Time Session
sess = input("0930-1100", "Start/Stop trades (Est time)", type=session)
t = time(period, sess)

//Orders
strategy.risk.max_intraday_filled_orders(tpd)
if(timec)
    strategy.entry("Enter", long = longorshort, when = t>1)
else
    strategy.entry("Enter", long = longorshort)
strategy.exit("Exit","Enter", trail_points = 0, trail_offset = stop)
````
