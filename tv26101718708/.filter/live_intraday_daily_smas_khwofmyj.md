# Live Intraday Daily SMAs

- url: https://www.tradingview.com/script/khwOfmYj-Live-Intraday-Daily-SMAs/
- type: indicator
- pine_id: PUB;c8f0e583184e4fafb3e8560a09cdd590
- version: 1.0

## Description

Shows real-time 5, 20, and 200 period daily SMA's on intraday charts

## Source Code

````pine
//@version=5
indicator("Live Intraday Daily SMAs", overlay=true)

// Inputs
show5   = input.bool(true, "Show Live 5-Day SMA")
show20  = input.bool(true, "Show Live 20-Day SMA")
show200 = input.bool(true, "Show Live 200-Day SMA")

// Function: live daily SMA recalculated intraday
liveDailySMA(len) =>
    priorSum = request.security(
         syminfo.tickerid,
         "D",
         math.sum(close[1], len - 1),
         lookahead = barmerge.lookahead_on
     )
    (close + priorSum) / len

// Live daily SMAs
sma5   = liveDailySMA(5)
sma20  = liveDailySMA(20)
sma200 = liveDailySMA(200)

// Plots
plot(show5 ? sma5 : na, title="Live 5-Day SMA", color=color.yellow, linewidth=1)
plot(show20 ? sma20 : na, title="Live 20-Day SMA", color=color.red, linewidth=1)
plot(show200 ? sma200 : na, title="Live 200-Day SMA", color=color.green, linewidth=1)
````
