# Liquidity & Imbalance

- url: https://www.tradingview.com/script/HndOnBmX-Liquidity-Imbalance/
- type: indicator
- pine_id: PUB;02264ad6e6a8439bad91b461298978bd
- version: 1.0

## Description

Easily spot areas of inefficiency and pools of liquidity above or below price.
Tailor made for both swing and day trading styles, this visual aid ensures your entries and exits remain pristine.

We help you turn complex data into actionable insights

## Source Code

````pine
//@version=6
indicator(" FA + Imbalance + Liquidity Sweeps", overlay = true)

// ==============================
// SESSION FILTER (RTH)
// ==============================
isRTH = not na(time(timeframe.period, "0930-1600"))

// ==============================
// VWAP
// ==============================
vwap = ta.vwap(hlc3)
plot(vwap, "VWAP", color=color.orange, linewidth=2)

// ==============================
// VALUE AREA PROXY
// ==============================
devLen  = 20
devMult = 1.0

vwapDev = ta.stdev(close, devLen)
VAH = vwap + devMult * vwapDev
VAL = vwap - devMult * vwapDev

plot(VAH, "VAH", color=color.red)
plot(VAL, "VAL", color=color.green)

// ==============================
// HTF DISTRIBUTION FILTER (1H)
// ==============================
htfHigh  = request.security(syminfo.tickerid, "60", high,  barmerge.gaps_off, barmerge.lookahead_off)
htfClose = request.security(syminfo.tickerid, "60", close, barmerge.gaps_off, barmerge.lookahead_off)

distribution =
     htfHigh > htfHigh[1] and
     htfHigh[1] > htfHigh[2] and
     htfClose < htfHigh[1]

// ==============================
// FAILED ACCEPTANCE SHORT SIGNAL
// ==============================
aboveVAH_prev  = high[1] > VAH[1]
closeBackBelow = close < VAH
failedReclaim  = high < VAH
volWeak        = volume < ta.sma(volume, 20)

shortSignal =
     isRTH and
     distribution and
     aboveVAH_prev and
     closeBackBelow and
     failedReclaim and
     volWeak

plotshape(shortSignal, title="FA Short",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small)

// ==============================
// LIQUIDITY SWEEP LOGIC
// ==============================
swingLen = 5

priorHigh = ta.highest(high, swingLen)[1]
priorLow  = ta.lowest(low, swingLen)[1]

buySideSweep  = high > priorHigh and close < priorHigh
sellSideSweep = low < priorLow and close > priorLow

plotshape(buySideSweep, title="Buy-Side Sweep",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="BSL")

plotshape(sellSideSweep, title="Sell-Side Sweep",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="SSL")

// ==============================
// IMBALANCE DETECTION (FIXED)
// ==============================
barRange = high - low
avgRange = ta.sma(barRange, 20)
volAvg   = ta.sma(volume, 20)

buyImbalance =
     close > open and
     barRange > avgRange * 1.3 and
     volume > volAvg * 1.2

sellImbalance =
     close < open and
     barRange > avgRange * 1.3 and
     volume > volAvg * 1.2

plotshape(buyImbalance, title="Buy Imbalance",
     style=shape.square,
     location=location.belowbar,
     color=color.blue,
     size=size.tiny)

plotshape(sellImbalance, title="Sell Imbalance",
     style=shape.square,
     location=location.abovebar,
     color=color.purple,
     size=size.tiny)

// ==============================
// CONTEXT BACKGROUND
// ==============================
bgcolor(distribution ? color.new(color.red, 92) : na)

// ==============================
// ALERTS
// ==============================
alertcondition(buySideSweep, title="Buy-Side Liquidity Sweep",
     message="Buy-side liquidity sweep detected")

alertcondition(sellSideSweep, title="Sell-Side Liquidity Sweep",
     message="Sell-side liquidity sweep detected")

alertcondition(shortSignal, title="Failed Acceptance Short",
     message="Auction failure above value – short setup")
````
