# Smart Money vs Retail Flow 

- url: https://www.tradingview.com/script/01fHaeoO-Smart-Money-vs-Retail-Flow/
- type: indicator
- pine_id: PUB;b5e75b230f8a4093af507c8dd826eff0
- version: 1.0

## Description

This indicator estimates the balance of power between institutional ("smart money") participants and retail traders by analyzing the relationship between price movement and volume relative to its average.
How it works:
Smart money tends to move markets with purpose — large volume accompanied by decisive price movement. Retail traders often chase price, buying tops and selling bottoms. This indicator attempts to separate these two behaviors by weighting price momentum against normalized volume activity, then applying RSI-based normalization to create two oscillating lines that reflect each group's relative dominance.
The two lines:

Aqua line (Commercials / Smart Money) — rises when significant price movement is backed by above-average volume, suggesting institutional participation
Red line (Retail Traders) — the inverse signal, rising when retail-style flow dominates

Key levels:

Above 70 — dominant zone. When the smart money line crosses above 70, institutions are aggressively entering
Below 30 — exhaustion zone. A crossover back above 30 on the smart money line triggers a buy signal
50 — midline equilibrium between buyers and sellers

Signals:

Green triangle (Smart Money Buy) — smart money line crosses back above 30, suggesting institutional accumulation after a pullback
Red triangle (Retail Trap) — retail line crosses above 70, suggesting retail traders are overextended and a reversal may follow

Background shading:

Green background — smart money in dominant zone
Red background — retail flow in dominant zone, potential exhaustion or trap

Best used with:
Price action context, support/resistance levels, and volume profile. Works on all assets and timeframes. Most effective on liquid markets such as indices (ES, NQ, DAX), major forex pairs, and high-volume crypto pairs.
Settings:

Momentum Length — RSI normalization period (default 14)
Volume Length — baseline volume average period (default 20)
Smoothing — EMA smoothing applied to raw flow signal (default 5)

Note: This indicator does not use actual order book or Level 2 data. Smart money flow is estimated using price-volume weighting relative to average volume. Use in confluence with other analysis for best results.

## Source Code

````pine
//@version=5
indicator("Smart Money vs Retail Flow ", overlay=false)

// === INPUTS ===
length      = input.int(14, "Momentum Length")
volLength   = input.int(20, "Volume Length")
smoothLen   = input.int(5, "Smoothing")

// === PRICE + VOLUME LOGIC ===
priceMove = close - close[1]
volAvg    = ta.sma(volume, volLength)

// Smart money estimation
smartFlowRaw =
     (priceMove * volume) / volAvg

smartFlow = ta.ema(smartFlowRaw, smoothLen)

// Retail estimation
retailFlow = ta.ema(-smartFlowRaw, smoothLen)

// === NORMALIZE ===
smartNorm  = ta.rsi(smartFlow, length)
retailNorm = ta.rsi(retailFlow, length)

// === ZONES ===
hline(70, "Commercial Zone", color=color.new(color.green, 50))
hline(30, "Retail Zone", color=color.new(color.red, 50))
hline(50, "Midline", color=color.gray)

// Background zones
bgcolor(smartNorm > 70 ? color.new(color.green, 90) : na)
bgcolor(retailNorm > 70 ? color.new(color.red, 90) : na)

// === PLOTS ===
plot(smartNorm,
     color=color.aqua,
     linewidth=2,
     title="Commercials / Smart Money")

plot(retailNorm,
     color=color.red,
     linewidth=2,
     title="Retail Traders")

// === SIGNALS ===
bullSignal =
     ta.crossover(smartNorm, 30)

bearSignal =
     ta.crossover(retailNorm, 70)

plotshape(
     bullSignal,
     title="Smart Money Buy",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.small)

plotshape(
     bearSignal,
     title="Retail Trap",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.small)

// === ALERTS ===
alertcondition(
     bullSignal,
     title="Smart Money Buy Alert",
     message="Smart money entering market")

alertcondition(
     bearSignal,
     title="Retail Trap Alert",
     message="Retail traders trapped")
````
