# Long-Only Recovery Stages

- url: https://www.tradingview.com/script/09HPxefz-Long-Only-Recovery-Stages/
- type: indicator
- pine_id: PUB;c3f312d678724786af562d42cb3a36d4
- version: 1.0

## Description

Recovery indicators using simple labels. It uses moving averages.

## Source Code

````pine
//@version=5
indicator("Long-Only Recovery Stages", overlay=true)

// Moving averages
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// Slope checks
sma200Falling = sma200 < sma200[10]
sma50Rising   = sma50 > sma50[10]

// Stage conditions
avoid          = close < sma200 and sma200Falling
watch          = ta.crossover(close, sma20)
earlyRecovery  = ta.crossover(close, sma50)
trendRepair    = ta.crossover(close, sma200)

// Earlier confirmation
confirmedRecovery = close > sma200 and close > sma50 and sma50Rising
confirmedSignal   = confirmedRecovery and not confirmedRecovery[1]

// Later bull-trend confirmation
bullTrend = sma50Rising and ta.crossover(sma50, sma200)

// Stage labels
plotshape(avoid and not avoid[1], title="Avoid", text="Avoid", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(watch, title="Watch", text="Watch", style=shape.labelup, location=location.belowbar, color=color.yellow, textcolor=color.black, size=size.tiny)

plotshape(earlyRecovery, title="Early Recovery", text="Early", style=shape.labelup, location=location.belowbar, color=color.blue, textcolor=color.white, size=size.tiny)

plotshape(trendRepair, title="Trend Repair", text="Repair", style=shape.labelup, location=location.belowbar, color=color.purple, textcolor=color.white, size=size.tiny)

plotshape(confirmedSignal, title="Confirmed Recovery", text="Confirmed", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(bullTrend, title="Bull Trend", text="Bull Trend", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)

// Background traffic light
bgcolor(avoid ? color.new(color.red, 88) : na)
bgcolor(close > sma20 and close < sma50 ? color.new(color.yellow, 90) : na)
bgcolor(close > sma50 and close < sma200 ? color.new(color.blue, 90) : na)
bgcolor(close > sma200 and close > sma50 and sma50Rising ? color.new(color.green, 92) : na)

// Alerts
alertcondition(avoid and not avoid[1], title="Avoid", message="Price is below a falling 200-day SMA. Avoid.")
alertcondition(watch, title="Watch", message="Price has reclaimed the 20-day SMA. Watchlist signal.")
alertcondition(earlyRecovery, title="Early Recovery", message="Price has reclaimed the 50-day SMA. Early recovery signal.")
alertcondition(trendRepair, title="Trend Repair", message="Price has reclaimed the 200-day SMA. Trend repair signal.")
alertcondition(confirmedSignal, title="Confirmed Recovery", message="Price is above the 200-day SMA, above the 50-day SMA, and the 50-day SMA is rising.")
alertcondition(bullTrend, title="Bull Trend", message="50-day SMA has crossed above the 200-day SMA.")
````
