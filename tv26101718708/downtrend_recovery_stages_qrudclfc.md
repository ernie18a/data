# Downtrend Recovery Stages

- url: https://www.tradingview.com/script/qRUDcLFc-Downtrend-Recovery-Stages/
- type: indicator
- pine_id: PUB;848dbcdc94b649a881aab87b73c16bba
- version: 1.0

## Description

Long-Only Recovery Stages is a trend-recovery indicator designed for long-only investors. It helps separate falling-knife conditions from early signs of repair by tracking price behaviour against the 20-day, 50-day and 200-day moving averages.

The script uses a staged framework:

Avoid when price is below a falling 200-day moving average.
Watch when price reclaims the 20-day moving average.
Early Recovery when price reclaims the 50-day moving average.
Trend Repair when price reclaims the 200-day moving average.
Confirmed Recovery when the 50-day moving average turns up and crosses above the 200-day moving average.

It is not intended to predict bottoms. It is designed to reduce false confidence during downtrends and highlight when price action is starting to improve.

## Source Code

````pine
//@version=5
indicator("Downtrend Recovery Stages", overlay=true)

// Moving averages
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// 200-day slope
sma200Falling = sma200 < sma200[10]
sma50Rising   = sma50 > sma50[10]

// Conditions
avoid             = close < sma200 and sma200Falling
watch             = ta.crossover(close, sma20)
earlyRecovery     = ta.crossover(close, sma50)
trendRepair       = ta.crossover(close, sma200)
confirmedRecovery = sma50Rising and ta.crossover(sma50, sma200)

// Plots
plot(sma20,  "20 SMA",  color=color.orange)
plot(sma50,  "50 SMA",  color=color.blue)
plot(sma200, "200 SMA", color=color.red, linewidth=2)

// Signals
plotshape(avoid and not avoid[1], title="Avoid", text="Avoid", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(watch, title="Watch", text="Watch", style=shape.labelup, location=location.belowbar, color=color.yellow, textcolor=color.black, size=size.tiny)

plotshape(earlyRecovery, title="Early Recovery", text="Early", style=shape.labelup, location=location.belowbar, color=color.blue, textcolor=color.white, size=size.tiny)

plotshape(trendRepair, title="Trend Repair", text="Repair", style=shape.labelup, location=location.belowbar, color=color.purple, textcolor=color.white, size=size.tiny)

plotshape(confirmedRecovery, title="Confirmed Recovery", text="Confirmed", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

// Background traffic light
bgcolor(avoid ? color.new(color.red, 88) : na)
bgcolor(close > sma20 and close < sma50 ? color.new(color.yellow, 90) : na)
bgcolor(close > sma50 and close < sma200 ? color.new(color.blue, 90) : na)
bgcolor(close > sma200 ? color.new(color.green, 92) : na)

// Alerts
alertcondition(avoid and not avoid[1], title="Avoid", message="Price is below a falling 200-day SMA. Avoid.")
alertcondition(watch, title="Watch", message="Price has reclaimed the 20-day SMA. Watchlist signal.")
alertcondition(earlyRecovery, title="Early Recovery", message="Price has reclaimed the 50-day SMA. Early recovery signal.")
alertcondition(trendRepair, title="Trend Repair", message="Price has reclaimed the 200-day SMA. Trend repair signal.")
alertcondition(confirmedRecovery, title="Confirmed Recovery", message="50-day SMA is rising and has crossed above the 200-day SMA. Confirmed recovery.")
````
