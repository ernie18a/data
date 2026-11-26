# VWAP (The Trader Richie)

- url: https://www.tradingview.com/script/gBOWlpMJ-VWAP-The-Trader-Richie/
- type: indicator
- pine_id: PUB;28b727ede3814208a1f5eaf571fecf70
- version: 1.0

## Description

This indicator plots the session's Volume Weighted Average Price (VWAP) with standard deviation bands at ±1σ, ±2σ and ±3σ. VWAP resets at the start of each trading day, so it always shows the average price weighted by that day's volume. Many intraday traders and institutions treat it as a benchmark for "fair value."

How to read it

VWAP (orange line): Price above VWAP suggests buyers are in control. Price below suggests sellers are. The line often acts as dynamic support or resistance.
±1σ (gray bands): The normal trading range around fair value. The shaded zone in the middle is where price spends most of the session.
±2σ (red / green): Price is stretched. Moves into this zone often mean overbought or oversold conditions and a higher chance of a pullback toward VWAP.
±3σ (bold red / green): Extreme deviation, which is statistically rare. It's useful for spotting exhaustion, taking profits or looking for mean-reversion setups.

Features

Resets VWAP and bands automatically each day
Adjustable deviation values for each band
Option to show or hide the 2nd and 3rd bands
Selectable price source (default: hl2)
Optional previous-day VWAP close, colored green or red depending on whether price is above or below it
Shaded overbought and oversold zones for quick visual reading

Best used on intraday timeframes (1m–1h) for stocks, futures, crypto and forex. It works well for mean-reversion entries, trend confirmation and setting profit targets.

## Source Code

````pine
//@version=6
indicator("VWAP (The Trader Richie)", shorttitle="VWAP TTR", overlay=true)

// ── Inputs ──────────────────────────────────────────────
src          = input.source(hl2, "Source")
devMult1     = input.float(1.0, "Stdev (1)", minval=0, step=0.1)
devMult2     = input.float(2.0, "Stdev (2)", minval=0, step=0.1)
devMult3     = input.float(3.0, "Stdev (3)", minval=0, step=0.1)
showDv2      = input.bool(true,  "Show 2nd band?")
showDv3      = input.bool(true,  "Show 3rd band?")
showPrevVWAP = input.bool(false, "Show previous VWAP close")

// ── Daily session reset ─────────────────────────────────
newSession = timeframe.change("D")

var float vwapSum   = 0.0
var float volumeSum = 0.0
var float v2Sum     = 0.0

if newSession
    vwapSum   := 0.0
    volumeSum := 0.0
    v2Sum     := 0.0

vol = nz(volume)
vwapSum   += src * vol
volumeSum += vol
v2Sum     += vol * src * src

myVwap = vwapSum / volumeSum
dev    = math.sqrt(math.max(v2Sum / volumeSum - myVwap * myVwap, 0))

// ── Plots ───────────────────────────────────────────────
A  = plot(myVwap, "VWAP", color=color.orange, linewidth=2)

U1 = plot(myVwap + devMult1 * dev, "Upper +1σ", color=color.gray)
D1 = plot(myVwap - devMult1 * dev, "Lower -1σ", color=color.gray)

U2 = plot(showDv2 ? myVwap + devMult2 * dev : na, "Upper +2σ", color=color.red)
D2 = plot(showDv2 ? myVwap - devMult2 * dev : na, "Lower -2σ", color=color.green)

U3 = plot(showDv3 ? myVwap + devMult3 * dev : na, "Upper +3σ", color=color.red, linewidth=2)
D3 = plot(showDv3 ? myVwap - devMult3 * dev : na, "Lower -3σ", color=color.green, linewidth=2)

// Previous session's closing VWAP
prevVwapCandidate = myVwap[1]
var float prevVwap = na
if newSession
    prevVwap := prevVwapCandidate
plot(showPrevVWAP ? prevVwap : na, "Prev VWAP", style=plot.style_circles, color=close > prevVwap ? color.green : color.red)

// ── Fills ───────────────────────────────────────────────
fill(A,  U1, color=color.new(color.gray,  90), title="Middle Fill Up")
fill(A,  D1, color=color.new(color.gray,  90), title="Middle Fill Down")
fill(U1, U2, color=color.new(color.red,   90), title="Overbought Fill 1")
fill(D1, D2, color=color.new(color.green, 90), title="Oversold Fill 1")
fill(U2, U3, color=color.new(color.red,   85), title="Overbought Fill 2")
fill(D2, D3, color=color.new(color.green, 85), title="Oversold Fill 2")
````
