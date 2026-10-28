# NY Open Anchored VWAP (+2/+3 bands)

- url: https://www.tradingview.com/script/OR7th7UL-NY-Open-Anchored-VWAP-2-3-bands/
- type: indicator
- pine_id: PUB;a831a34ed3814c9f90c2cac0eef2f3e9
- version: 1.0

## Description

A VWAP that anchors to the New York open instead of the default session start, with bands at 2x and 3x deviation and fills in between. Anchoring at the open means the line only reflects today's auction, which is a cleaner fair-value read intraday, and the outer bands flag where moves tend to stall or snap back. Above the line buyers have it, below it sellers do, and the +2/+3 are your over-extension zones. Self-contained, one symbol, no outside pulls, so it won't repaint. Anchored VWAP itself is standard. The part that's mine is the fixed NY-open anchor and the 2x/3x framing.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NY Open Anchored VWAP with +2 and +3 bands
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  A VWAP that anchors to the New York open instead of the default session
//  start, with bands at 2x and 3x deviation and fills in between. Anchoring
//  at the open means the line only reflects today's auction, which is a
//  cleaner fair-value read intraday, and the outer bands flag where moves
//  tend to stall or snap back. Above the line buyers have it, below it
//  sellers do, and the +2/+3 are your over-extension zones. Self-contained,
//  one symbol, no outside pulls, so it won't repaint. Anchored VWAP itself is
//  standard. The part that's mine is the fixed NY-open anchor and the 2x/3x
//  framing.
// ============================================================================
//
//@version=6
indicator('NY Open Anchored VWAP (+2/+3 bands)', overlay = true, max_lines_count = 500)

// ─── Inputs ──────────────────────────────────────────────────────────────
src = input.source(hlc3, 'Source')
showVWAP = input.bool(true, 'Show VWAP line')
band2Mult = input.float(2.0, 'Band 2 multiplier', step = 0.5)
band3Mult = input.float(3.0, 'Band 3 multiplier', step = 0.5)
fillBands = input.bool(true, 'Fill between bands')
sessTZ = input.string('America/New_York', 'Anchor timezone')
anchorSess = input.session('0831-1600', 'Anchor session (start = anchor time)')

// VWMA crossover
showVWMA = input.bool(true, 'Show 21 VWMA', group = 'VWMA crossover')
vwmaLen = input.int(21, 'VWMA length', minval = 1, group = 'VWMA crossover')
showSignals = input.bool(true, 'Show cross signals', group = 'VWMA crossover')

// ─── Anchor: first bar of the chosen NY session each day ────────────────────
// Session start (default 08:31 ET) = where the VWAP re-anchors each day.
inSession = not na(time(timeframe.period, anchorSess, sessTZ))
isNewAnchor = inSession and not inSession[1]

// ─── Anchored VWAP + standard-deviation bands ───────────────────────────────
[vwapValue, upper2, lower2] = ta.vwap(src, isNewAnchor, band2Mult)
[_, upper3, lower3] = ta.vwap(src, isNewAnchor, band3Mult)

// ─── Plots ──────────────────────────────────────────────────────────────────
pV = plot(showVWAP ? vwapValue : na, 'VWAP', color.new(color.blue, 0), 2)

pU2 = plot(upper2, 'Upper Band 2', color.new(color.green, 0), 1)
pL2 = plot(lower2, 'Lower Band 2', color.new(color.green, 0), 1)
pU3 = plot(upper3, 'Upper Band 3', color.new(color.red, 0), 1)
pL3 = plot(lower3, 'Lower Band 3', color.new(color.red, 0), 1)

// ─── Optional shading ───────────────────────────────────────────────────────
fill(pU2, pU3, fillBands ? color.new(color.green, 90) : na, 'Upper 2→3 fill')
fill(pL2, pL3, fillBands ? color.new(color.red, 90) : na, 'Lower 2→3 fill')

// ─── 21 VWMA + crossover with the anchored VWAP ─────────────────────────────
vwma = ta.vwma(src, vwmaLen)
plot(showVWMA ? vwma : na, '21 VWMA', color.new(color.orange, 0), 2)

bullCross = ta.crossover(vwma, vwapValue) // VWMA crosses above VWAP
bearCross = ta.crossunder(vwma, vwapValue) // VWMA crosses below VWAP

plotshape(showSignals and bullCross, 'Bull cross', shape.triangleup, location.belowbar, color.new(color.green, 0), size = size.small, text = '▲')
plotshape(showSignals and bearCross, 'Bear cross', shape.triangledown, location.abovebar, color.new(color.red, 0), size = size.small, text = '▼')

alertcondition(bullCross, 'VWMA crosses above VWAP', '21 VWMA crossed ABOVE anchored VWAP')
alertcondition(bearCross, 'VWMA crosses below VWAP', '21 VWMA crossed BELOW anchored VWAP')
````
