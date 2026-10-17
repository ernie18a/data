# Buy and hold strategy

- url: https://www.tradingview.com/script/0ZIDvEAV-Buy-and-hold-strategy/
- type: strategy
- pine_id: PUB;72bd7399b0aa4d80a7e50d73f3f0bc00
- version: 1.0

## Description

A simple buy and hold strategy. A short or a long position can be chosen. The start date will determine the date where your position will start and end date is the date it will end. This works well as a baseline to your other existing strategies since buy and hold is just the simplest strategy available.

## Source Code

````pine
//@version=4
strategy("Buy and hold strategy")

startDate = input(title="Start Date", type=input.time, defval=timestamp("01 Jan 1970 00:00"))
endDate = input(title="End Date", type=input.time, defval=timestamp("20 June 2022"))
tradeDirection = input(title="Trade Direction", options=["Long", "Short"], defval="Long")

inDateRange = (time >= startDate) and (time < endDate)

if(inDateRange)
    if(tradeDirection == "Long")
        strategy.entry("Long", strategy.long)
    if(tradeDirection == "Short")
        strategy.entry("Short", strategy.short)
if(not inDateRange)
    strategy.exit(id="Exit", stop=close)
````
