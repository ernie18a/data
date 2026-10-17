# Proper lookback period

- url: https://www.tradingview.com/script/hn4ukQWj-Proper-lookback-period/
- type: strategy
- pine_id: PUB;f5VrFxydCDhFjir4aRbX1GcDPj6I4dK6
- version: 1.0

## Description

This will allow you to enter the date when the strategy should start trading. It cancels all orders if the the current bar is older than the date you entered in the input field.
Motivation: strategy(lookback) never worked for me and even if it did, it is garbage, because I want to set a date instead of number of bars. I can see on the chart clearly what period is irrelevant (in futures trading).

## Source Code

````pine
//@version=4
strategy("Proper lookback period", overlay=true)
startWhen = input(title="Enter date when the strategy should start trading", type=input.time, defval=timestamp("2 Jan 1900 00:00 +0000"))

if (sma(close, 20) > sma(close, 200))
    strategy.entry("Long", strategy.long)
else
    strategy.entry("Short", strategy.short)

// This line will cancel all orders if the current bar preceeds the date you entered in "startWhen"
strategy.cancel_all(when = time < startWhen)
````
