<!-- tradingview-pine-id: PUB;42535daa496047e78a9ab574f014bc72 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FLD&#039;s - Future Lines of Demarcation

Source: https://www.tradingview.com/script/wYNDpT7E-FLD-s-Future-Lines-of-Demarcation/

## Description

FLD (Future Line of Demarcation)
This Pine Script indicator plots a (optionally smoothed) price source shifted forward by a user-defined number of bars (default 40).

How it works
Takes a source (default: hl2)
Optionally applies SMA, EMA, or RMA smoothing
Plots the result offset forward by the Period value

Use case
Primarily used in cycle analysis (especially JM Hurst-style methods). The FLD acts as a dynamic future support/resistance line. Traders watch for price interactions with the FLD to time entries, exits, or potential cycle turns.

I was surprised no real pine 6 versions existed....

---

## Source Code

````pine
//@version=6
////////////////////////////////////////////////////////////////////
indicator(title="FLD's - Future Lines of Demarcation", overlay=true)

// Input parameters
Period = input.int(title="Period", defval=40, minval=1)
src = input.source(title="Source", defval=hl2)
smoothingType = input.string(title="Smoothing", defval="None", options=["None", "SMA", "EMA", "RMA"])
smoothLen = input.int(title="Smoothing Length", defval=10, minval=1)

// Calculate source with optional smoothing
var float smoothedSrc = na
if smoothingType == "SMA"
    smoothedSrc := ta.sma(src, smoothLen)
else if smoothingType == "EMA"
    smoothedSrc := ta.ema(src, smoothLen)
else if smoothingType == "RMA"
    smoothedSrc := ta.rma(src, smoothLen)
else
    smoothedSrc := src

// Plot FLD
plot(smoothedSrc, title="FLD", linewidth=1, color=color.white, offset=Period)
````
