# Volume Band Asymmetric: Dynamic Volatility Envelopes

- url: https://www.tradingview.com/script/uCwVfcbY-Volume-Band-Asymmetric-Dynamic-Volatility-Envelopes/
- type: indicator
- pine_id: PUB;3d439ee1659d4d8084a6a93f2622c208
- version: 1.0

## Description

This indicator filters market noise by dynamically adjusting entry bands based on candle structure (Wick/Body) and real-time volume analysis. By using an asymmetric approach, it identifies exhaustion points where price tends to revert or break out, giving you a statistical edge in trending and ranging markets

Dynamic Offsets: Uses candle statistics (Wick, Body, or ATR) to define support/resistance bands.

Volume Normalization: The Volume Power input scales the channel width based on relative volume, expanding bands during high volatility/volume.

Crypto: Use higher volLookback and ATR settings to filter high-volatility spikes.

Forex: Tighten the multipliers (multBuy/multSell) to capture smaller, frequent trend exhaustion points.

I’m committed to making this tool as accurate as possible. Your feedback is invaluable! Please share your backtest results, suggest features, or report any issues in the comments below. Let’s evolve this strategy together!

Disclaimer: Trading involves significant risk of loss and is not suitable for all investors. Past performance is not indicative of future results. This script is for educational purposes only.

## Source Code

````pine
//@version=5
indicator("Volume Band Asymmetric", overlay=true)

// ═══════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════

multBuy  = input.float(2.0,  "Buy Multiplier (Green)",  minval=0.1, maxval=20.0, step=0.1, group="Multipliers")
multSell = input.float(2.0,  "Sell Multiplier (Red)", minval=0.1, maxval=20.0, step=0.1, group="Multipliers")

useVolume   = input.bool(true,  "Use Volume",      group="Logic")
useWicks    = input.bool(true,  "Use Wicks",      group="Logic")
sourceType  = input.string("Wick", "Offset Source", options=["Wick", "Body", "Full Candle", "ATR"], group="Logic")
atrLen      = input.int(14, "ATR Length (if ATR selected)", minval=1, maxval=100, group="Logic")

volLookback = input.int(50, "Volume Lookback (Normalization)", minval=1, maxval=500, group="Volume")
volPower    = input.float(1.0, "Volume Power (Influence strength)", minval=0.1, maxval=3.0, step=0.1, group="Volume")

offsetBuy  = input.float(0.0, "Buy Manual Offset",  minval=-10.0, maxval=10.0, step=0.1, group="Fine Tune")
offsetSell = input.float(0.0, "Sell Manual Offset", minval=-10.0, maxval=10.0, step=0.1, group="Fine Tune")

colorBuy   = input.color(color.green, "Buy Color",  group="Visuals")
colorSell  = input.color(color.red,   "Sell Color", group="Visuals")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=4,           group="Visuals")
showFill   = input.bool(false, "Fill Between Lines",                 group="Visuals")
fillAlpha  = input.int(90, "Fill Transparency", minval=0, maxval=100,  group="Visuals")

// ═══════════════════════════════════════
// LOGIC
// ═══════════════════════════════════════

// Offset source
baseOffset = switch sourceType
    "Wick"        => math.max(close - low, 0)
    "Body"        => math.abs(close - open)
    "Full Candle" => high - low
    "ATR"         => ta.atr(atrLen)
    => high - low

bullBase = useWicks ? math.max(close - low, 0)  : math.max(close - open, 0)
bearBase = useWicks ? math.max(high - close, 0) : math.max(open - close, 0)

finalBase = sourceType == "ATR" ? ta.atr(atrLen) : sourceType == "Full Candle" ? (high - low) : na

bullOffset = na(finalBase) ? bullBase : finalBase
bearOffset = na(finalBase) ? bearBase : finalBase

// Volume normalization
volNorm = useVolume ? math.pow(volume / ta.highest(volume, volLookback), volPower) : 1.0

// Final lines
buyLine  = high + bullOffset * multBuy  * volNorm + offsetBuy
sellLine = low  - bearOffset * multSell * volNorm - offsetSell

// ═══════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════

p1 = plot(buyLine,  "Buy",  color=colorBuy,  linewidth=lineWidth)
p2 = plot(sellLine, "Sell", color=colorSell, linewidth=lineWidth)

fill(p1, p2, color=showFill ? color.new(colorBuy, fillAlpha) : na)
````
