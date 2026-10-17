# BB Mean Reversion Long + SL

- url: https://www.tradingview.com/script/z1xM8YnZ/
- type: strategy
- pine_id: PUB;abcea0369eac4a5e80b60b84a50c7895
- version: 1.0

## Description

This strategy exploits statistical price extremes using Bollinger Bands 
on a mean reversion logic — when price closes below the lower band, 
it's statistically outside 95% of normal price action. 
That's the entry. The target is simple : get back to the mean.

━━━ LOGIC ━━━
- Entry   → price closes below the lower band (crossunder)
- Take Profit → price returns to the SMA (middle band)
- Stop Loss   → fixed % below entry price

━━━ SETTINGS ━━━
- SMA Period (N)       → default 20
- Standard Deviations (K) → default 2.0
- Stop Loss %          → default 1.5%
- Pyramiding           → up to 3 simultaneous entries

━━━ BEST TIMEFRAME ━━━
Tested and works best between 45min and 2h.
Below 30min : too much noise.
Above 2h : price extremes often reflect real trend, not overreaction.

━━━ NOTES ━━━
→ Designed for mean-reverting assets with clear volatility cycles
→ Works particularly well on XAUUSD, indices ETFs
→ Avoid running during major news events (NFP, CPI, Fed)
→ Not recommended to hold positions over the weekend
→ qty is set to fixed lot — adjust to your broker's lot size

Tune N and K to your asset. Default settings are a starting point, 
not a final answer. The edge is in the calibration.

## Source Code

````pine
//@version=5
strategy("BB Mean Reversion Long + SL", overlay=true, default_qty_type=strategy.fixed, default_qty_value=100, pyramiding=3)

// Paramètres
N     = input.int(20,    "Période SMA",   minval=1)
K     = input.float(2.0, "Écarts-types", minval=0.1, step=0.1)
slPct = input.float(1.5, "Stop Loss %",  minval=0.1, step=0.1)

// Calcul des bandes
[middle, upper, lower] = ta.bb(close, N, K)

// Tracé
plot(middle, "Moyenne",     color=color.gray)
plot(upper,  "Bande haute", color=color.red)
plot(lower,  "Bande basse", color=color.green)

// Entrée long uniquement
longEntry = ta.crossunder(close, lower)

if longEntry
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit Long", "Long", stop=close * (1 - slPct/100), limit=middle)

// Visuels
plotshape(longEntry, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="BUY")
````
