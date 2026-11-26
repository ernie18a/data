# Parabolic Move Detector

- url: https://www.tradingview.com/script/uXC03EWc-Parabolic-Move-Detector/
- type: indicator
- pine_id: PUB;841378645c0f4c3c9b610a07b6a8a9c9
- version: 1.0

## Description

It achieves this by combining two completely different mathematical concepts: Momentum Acceleration and Mean Reversion Overextension.

Here is how the script works under the hood:

1. Momentum Acceleration (Parabolic SAR)
First, the script calculates the standard Parabolic SAR (Stop and Reverse).

PSAR prints small dots above or below the price candles.

It is designed to trail the price and physically "accelerate" (move closer to the price) the longer a trend goes on.

When the price finally hits the PSAR dots, the dots flip to the other side. This generates the baseline BUY (bullish momentum shift) and SELL (bearish momentum shift) signals you see on the chart.

2. Overextension (VWAP + ATR Stretch)
A momentum flip alone isn't enough to call a "parabolic reversal"—you need to know if the asset is historically overextended.

The script calculates the VWAP (Volume Weighted Average Price), which acts as the asset's "fair value" mean for the day/session.

It then calculates the ATR (Average True Range) to measure the current volatility.

It draws an Upper Stretch Limit and a Lower Stretch Limit. These are created by adding/subtracting a multiple of the ATR (default 2.0x) from the VWAP. If the price travels outside these bands, the script flags the asset as isStretched (officially in a parabolic/overextended state).

3. The Reversal Detection (The "Blowoff")
The true power of the script lies in combining these two concepts to filter out false signals.

A standard PSAR flip happens all the time in choppy markets. But a Blow-off Top or Capitulation Bottom is exceptionally rare. The script demands two things happen simultaneously to trigger the major alerts:

The price must be heavily deviated from its mean volume price (isStretched).
The accelerating momentum must break (buySignal or sellSignal).

pinescript
blowoffTop = isStretched and sellSignal
capitulationBottom = isStretched and buySignal

BLOWOFF: Prints a large fuchsia cross above the candle. It means the price went on a massive run above the Upper Stretch Limit, and the buyers just failed to hold the momentum, causing the PSAR to flip bearish.

CAPITULATION: Prints a large fuchsia cross below the candle. It means the price dumped severely below the Lower Stretch Limit, and sellers just exhausted themselves, causing the PSAR to flip bullish.

These exact moments are often the highest-probability, lowest-risk areas to catch a violent mean-reversion trade!

## Source Code

````pine
//@version=6
indicator("Parabolic Move Detector", shorttitle="GM_PMD", overlay=true)

// --- PSAR Settings ---
grp_psar = "Parabolic SAR (Momentum)"
start = input.float(0.02, "Start", step=0.01, group=grp_psar)
increment = input.float(0.02, "Increment", step=0.01, group=grp_psar)
maximum = input.float(0.2, "Maximum", step=0.01, group=grp_psar)

// --- VWAP Stretch Settings ---
grp_stretch = "VWAP + ATR Stretch (Overextension)"
mult = input.float(2.0, "Stretch Multiplier", step=0.1, group=grp_stretch)
atrLen = input.int(14, "ATR Length", group=grp_stretch)

// --- Calculations ---
psar = ta.sar(start, increment, maximum)
vwapVal = ta.vwap(hlc3)
atrVal = ta.atr(atrLen)

// Distance from VWAP
dist = math.abs(close - vwapVal)
isStretched = dist > (mult * atrVal)

// PSAR Signals
buySignal = ta.crossover(close, psar)
sellSignal = ta.crossunder(close, psar)

// Parabolic Continuation / Blow-off Top Detection
// A blow-off top is when price is stretched AND momentum reverses
blowoffTop = isStretched and sellSignal
capitulationBottom = isStretched and buySignal

// --- Plotting ---
plot(psar, "PSAR", style=plot.style_cross, color=color.new(color.blue, 30))
plot(vwapVal, "VWAP", color=color.new(color.orange, 0))

// Stretch Zones
upperStretch = vwapVal + (mult * atrVal)
lowerStretch = vwapVal - (mult * atrVal)
plot(upperStretch, "Upper Stretch Limit", color=color.new(color.red, 50), style=plot.style_stepline)
plot(lowerStretch, "Lower Stretch Limit", color=color.new(color.green, 50), style=plot.style_stepline)

// Signals
plotshape(buySignal, style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), text="BUY", size=size.small)
plotshape(sellSignal, style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", size=size.small)

// Blowoff Alerts
plotshape(blowoffTop, style=shape.xcross, location=location.abovebar, color=color.new(color.fuchsia, 0), text="BLOWOFF", size=size.normal)
plotshape(capitulationBottom, style=shape.xcross, location=location.belowbar, color=color.new(color.fuchsia, 0), text="CAPITULATION", size=size.normal)

// --- Alerts ---
alertcondition(blowoffTop, title="Blow-off Top Detected", message="Price is overextended from VWAP and PSAR flipped bearish.")
alertcondition(capitulationBottom, title="Capitulation Bottom Detected", message="Price is overextended below VWAP and PSAR flipped bullish.")
````
