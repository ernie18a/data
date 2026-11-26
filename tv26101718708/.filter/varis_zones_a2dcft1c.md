# VARIS Zones

- url: https://www.tradingview.com/script/a2dCFt1c-VARIS-Zones/
- type: indicator
- pine_id: PUB;42d8453e85bc46f7a65ceebeea1826eb
- version: 5.0

## Description

[b]VARIS (Volume Adjusted Risk Interval Structure) is a VWAP-centered auction framework designed to identify overextended market conditions, positional stress, and volatility-driven expansion away from fair value.[/b]

Rather than functioning as a traditional overbought/oversold indicator, VARIS models how far price can efficiently expand from volume-weighted value before liquidity conditions, volatility pressure, dealer hedging flows, or mean reversion behavior begin influencing auction structure.

The framework is built around dynamic Risk Intervals projected around VWAP:

Inner Risk Interval bands (0.5 RI) represent healthy expansion and trend acceptance zones
Outer Risk Interval bands (1.0 RI) represent elevated stress, exhaustion, and unstable auction territory

VARIS is not intended to predict exact reversals or generate mechanical entries. Instead, it provides contextual insight into:

Trend health vs exhaustion
Liquidity-driven expansion
Acceptance/rejection behavior outside value
Volatility displacement
Market imbalance conditions
Positional squeeze environments
Statistical extension from fair value

In balanced market conditions, price often rotates back toward VWAP after reaching expansion extremes. In strong momentum or gamma-driven environments, price may continue riding the inner expansion bands while VWAP itself rises or falls to re-establish equilibrium.

Persistent acceptance outside the outer Risk Interval bands typically reflects abnormal market conditions such as:

Momentum cascades
Dealer hedging pressure
Short squeeze dynamics
Passive flow dominance
Liquidity vacuum expansion

VARIS is best used alongside:

Volume profile
Market internals (TICK, ADD, VOLD)
Auction market theory
Liquidity mapping
Higher timeframe structure
Dealer positioning analysis

## Source Code

````pine
//@version=6
indicator("VARIS Zones", overlay=true)

// ===== Visibility Inputs =====
showVWAP    = input.bool(true, "Show VWAP")


// ===== VWAP Style =====
vwapColor   = input.color(color.rgb(255, 0, 0, 10), "VWAP Line Color")
vwapWidth   = input.int(1, "VWAP Line Width", minval=1, maxval=5)


// ===== Session Reset Detection (timezone-safe) =====
// Fixed - forces ET regardless of chart timezone
isNewSession = hour(time, "America/New_York") == 18 and minute(time, "America/New_York") == 0

tp = (high + low + close) / 3

var float cumTPV = 0.0
var float cumVol = 0.0

if isNewSession
    cumTPV := tp * volume
    cumVol := volume
else
    cumTPV += tp * volume
    cumVol += volume

vwapValue = cumVol != 0 ? cumTPV / cumVol : na



// ===== Plots =====
vwapPlot   = plot(showVWAP   ? vwapValue   : na, title="VWAP",         color=vwapColor,   linewidth=vwapWidth)
````
