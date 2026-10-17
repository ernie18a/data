# Suraj Relative Keltner Map

- url: https://www.tradingview.com/script/eHQPyMft-Suraj-Relative-Keltner-Map/
- type: indicator
- pine_id: PUB;9eedd2bb2eea449c962a7814339405ed
- version: 1.0

## Description

📊 Suraj Relative Keltner Map (KC)

A normalised oscillator that plots price position in ATR units relative to the 20 EMA, converting the Keltner Channel into a fixed-scale reference map.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW IT WORKS

Instead of overlaying Keltner bands on price, this indicator asks: "Where is price sitting within the channel right now?" It divides the distance between price and the EMA by the ATR, producing a dimensionless score centred on zero.

The result is a clean oscillator where:
- 0.0 = price is exactly at the EMA
- +3.1 = price is touching the Upper Keltner Channel (3.1 ATR)
- −2.0 = price is at the Lower Keltner Channel (2.0 ATR)
- −2.5 = price is at the Deep Lower Keltner Channel (2.5 ATR)

Because the scale is ATR-normalised, the levels are identical across any ticker or timeframe — SPY, QQQ, SMH, or individual stocks all map onto the same grid.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REFERENCE LEVELS

🔵 U-KC 3.1 — Upper extreme (3.1 ATR above EMA)
🟡 EMA Basis — Moving average centreline
🟢 L-KC 2.0 — Lower channel (2.0 ATR below EMA)
🔴 L-KC 2.5 — Deep lower channel (2.5 ATR below EMA)
⚪ Price Position — Current normalised reading

Right-edge labels display the actual dollar values of each level on the current chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

USE CASES

→ Mean-reversion timing: Identify when price has stretched to statistical extremes relative to its own volatility.
→ Cross-asset comparison: Compare how "extended" different instruments are on a single normalised scale.
→ Regime filtering: Readings persistently above zero indicate trending conditions; readings compressing near zero indicate consolidation.
→ Crash-deployment signals: Deep negative readings (below −2.0) flag capitulation-grade dislocations suitable for leveraged mean-reversion strategies.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS

- EMA Length (default 20) — lookback for the central moving average
- ATR Length (default 10) — lookback for the volatility measure
- Source (default close) — price input
- Price Line Smoothing (default 1) — optional EMA smoothing on the normalised line; increase for a cleaner signal
- Show Zone Fills — toggle shaded bands between reference levels
- Show Live Value Labels — toggle right-edge dollar-value labels

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTES

This indicator is designed as a decision-support map, not a standalone signal generator. It is most effective when combined with volatility regime indicators (VIX, term structure), breadth measures, and momentum confirmation. The reference levels can be customised in the source code to match your own channel multipliers.

## Source Code

````pine
//@version=6
indicator(title="Suraj Relative Keltner Map", shorttitle="KC", overlay=false)

// Inputs
length     = input.int(20, minval=1, title="EMA Length")
atrlength  = input.int(10, minval=1, title="ATR Length")
src        = input.source(close, title="Source")
smoothLen  = input.int(1, minval=1, title="Price Line Smoothing")
showFill   = input.bool(true, title="Show Zone Fills")
showLabels = input.bool(true, title="Show Live Value Labels")

// Live basis and ATR
basis  = ta.ema(src, length)
atrVal = ta.atr(atrlength)

// Actual live Keltner values
upperKC_actual = basis + atrVal * 3.1
lower20_actual = basis - atrVal * 2.0
lower25_actual = basis - atrVal * 2.5

// Convert current price into ATR units relative to EMA
relPriceRaw = atrVal != 0 ? (close - basis) / atrVal : na
relPrice    = smoothLen > 1 ? ta.ema(relPriceRaw, smoothLen) : relPriceRaw

// Fixed horizontal Keltner reference levels
upperKC = 3.1
basisKC = 0.0
lower20 = -2.0
lower25 = -2.5

// Plots — linewidth=1, display pane only (no price scale labels)
pUpper   = plot(upperKC, title="U-KC 3.1", color=color.blue, linewidth=1, display=display.pane)
pBasis   = plot(basisKC, title="EMA Basis", color=color.yellow, linewidth=1, display=display.pane)
pLower20 = plot(lower20, title="L-KC 2.0", color=color.green, linewidth=1, display=display.pane)
pLower25 = plot(lower25, title="L-KC 2.5", color=color.red, linewidth=1, display=display.pane)
pPrice   = plot(relPrice, title="Price Position", color=color.white, linewidth=1, display=display.pane)

// Fills
fill(pUpper, pBasis, color=showFill ? color.new(color.blue, 90) : na, title="Upper Fill")
fill(pBasis, pLower20, color=showFill ? color.new(color.green, 92) : na, title="Mid Lower Fill")
fill(pLower20, pLower25, color=showFill ? color.new(color.red, 92) : na, title="Deep Lower Fill")

// Right-edge labels pinned to each Keltner level
var label lbUpper   = na
var label lbBasis   = na
var label lbLower20 = na
var label lbLower25 = na

if barstate.islast and showLabels
    int offset = bar_index + 4

    label.delete(lbUpper)
    label.delete(lbBasis)
    label.delete(lbLower20)
    label.delete(lbLower25)

    lbUpper := label.new(offset, upperKC,
         " " + str.tostring(upperKC_actual, format.mintick),
         xloc.bar_index, yloc.price, color.blue,
         label.style_label_left, color.white, size.small)

    lbBasis := label.new(offset, basisKC,
         " " + str.tostring(basis, format.mintick),
         xloc.bar_index, yloc.price, color.yellow,
         label.style_label_left, color.black, size.small)

    lbLower20 := label.new(offset, lower20,
         "" + str.tostring(lower20_actual, format.mintick),
         xloc.bar_index, yloc.price, color.green,
         label.style_label_left, color.white, size.small)

    lbLower25 := label.new(offset, lower25,
         " " + str.tostring(lower25_actual, format.mintick),
         xloc.bar_index, yloc.price, color.red,
         label.style_label_left, color.white, size.small)
````
