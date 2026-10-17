# SM EMA21 ADR Cloud + Signal

- url: https://www.tradingview.com/script/3kHmjPuJ-SM-EMA21-ADR-Cloud-Signal/
- type: indicator
- pine_id: PUB;c212415e2f2c43308bbe0e9a8b160e0f
- version: 1.0

## Description

Shows current price distance from 21 ema in ADR terms.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Shashankmusale

//@version=6
indicator("SM EMA21 ADR Cloud + Signal", overlay=true)

// === Inputs ===
adrUpMultiplier   = input.float(1.0, "ADR Up Multiplier")
adrDownMultiplier = input.float(0.5, "ADR Down Multiplier")
contractionTh     = input.float(0.5, "Contraction Threshold")

// === Core calculations ===
ema21 = ta.ema(close, 21)
plot(ema21, "EMA 21", color=color.white, linewidth=2)

adr21 = ta.rma(high - low, 21)

upperBand = ema21 + adrUpMultiplier * adr21
lowerBand = ema21 - adrDownMultiplier * adr21

pU = plot(upperBand, display=display.none)
pL = plot(lowerBand, display=display.none)
fill(pU, pL, color=color.new(color.gray, 70))

// === Condition 1: Close inside ADR cloud ===
inCloud = close >= lowerBand and close <= upperBand

// === Condition 2: Contraction ===
range5  = ta.highest(high, 5)  - ta.lowest(low, 5)
range20 = ta.highest(high, 20) - ta.lowest(low, 20)
contraction = range20 != 0 and (range5 / range20) < contractionTh

// === Condition 3: Closing range > 20% ===
closeRangePct = (high - low) != 0 ? 100 * (close - low) / (high - low) : 0
closeStrong = closeRangePct > 20

// === Final signal ===
signal = inCloud and contraction and closeStrong

// === Arrow ===
plotshape(signal, title="In-Cloud + Contraction + Close Strength",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     color=color.white)
````
