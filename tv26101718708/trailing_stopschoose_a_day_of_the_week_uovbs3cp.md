# Trailing Stops/Choose a Day of the Week

- url: https://www.tradingview.com/script/UoVBS3CP-Trailing-Stops-Choose-a-Day-of-the-Week/
- type: strategy
- pine_id: PUB;NUAXa8vYFpEHeUxYcbv4pojGn6dEIwsH
- version: 1.0

## Description

This would be my second ever published strategy.  It is almost the same as my first ever published script [url=https://www.tradingview.com/script/fpAdz4lh-Trailing-Stops-Only-For-Leveraged-ETFs-UGAZ-DGAZ/]https://www.tradingview.com/script/fpAdz4lh-Trailing-Stops-Only-For-Leveraged-ETFs-UGAZ-DGAZ/[/url].  I've been working primarily on [symbol="UGAZ"]UGAZ[/symbol] and [symbol="DGAZ"]DGAZ[/symbol].  

This is basically a statistical trade.  It buys every morning near market open (or by choosing a "time constraint"), then immediately places a trailing stop at a specified amount in ticks (if used on UGAZ a tick = $0.01, if used on NG at tick = $0.001).  I've found between 2% and 3% works well for the trailing stop (ie. if UGAZ = $75, a 3% trailing stop = $2.25)

-----What is different from my first strategy?------
You can test the trailing stop strategy one 1 day of the week.  Days of the week are assigned numbers. Sunday=1, Monday=2, Tuesday=3 and so on.  Just choose a number that correlates to the day of the week you want to test.  The Trailing stop may go past that day, that's a good thing if it's making money.  

-- Go long/Short is just that, it will buy shares/contracts or short them.

-- Trades per day.  This may not be a good choice, when left on "2", it will trade once per day.  If set above 2 and there is time left for another trade, an order will enter on the open of the next candle.  I'm am still working on ideas for this.

-- Time constraints. When you select this check box, the strategy will limit an entry to the time specified below the "Use Time Constraints" check box.  An Exit order will still continue past this window of time until it is stopped out.


----  very important  ----
Due to decay, leveraged ETFs will give false results if the price gets far out of range. For example, your ETF is trading around $20 and you choose a 1 hour chart, it may back test back to a time before a reverse split. If the price gets to be too large, like $200, or $1200, the movement on the chart creates false indication of profit/loss. 

---  Most important. ---  
Do not trade off this strategy, you may lose lots of money. This is for educational use only.



Good luck

## Source Code

````pine
//@version=3
strategy("Trailing Stops/Choose A Day", overlay=true, initial_capital=25000, default_qty_type=strategy.percent_of_equity, default_qty_value=20)

stop = input(75, "Trailing Stop (in ticks)", step=5)
longorshort = input(true, "Go Long/Short")
day = input(title = "Day of week(2=Mon, 3=Tues...)", defval = 2, minval = 2, maxval = 6)
tpd = input(2, "Trades per day", step=2, minval=2)
timec = input(true, "Use Time constraints")

//Time Session
sess = input("0930-1400", "Start/Stop trades (Est time)", type=session)
t = time(period, sess)

//Orders
strategy.risk.max_intraday_filled_orders(tpd)
if(timec)
    strategy.entry("Enter", long = longorshort, when = t>1 and dayofweek == day)
else
    strategy.entry("Enter", long = longorshort, when = dayofweek == day)
strategy.exit("Exit", "Enter", trail_points = 0, trail_offset = stop)
````
