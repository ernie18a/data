# Camarilla Pivot Points with Actual Price Data for Heikin Ashi

- url: https://www.tradingview.com/script/hqueAyB6-Camarilla-Pivot-Points-with-Actual-Price-Data-for-Heikin-Ashi/
- type: indicator
- pine_id: PUB;95435831f9d3445cb0beeb282da45e7e
- version: 2.0

## Description

Nick Stott developed the Camarilla system in 1989 while trading bonds. The name comes from the Latin word for a small, private room — the implication being that these are hidden levels the market naturally gravitates toward. The core insight is that markets are mean-reverting by nature on an intraday basis — price tends to oscillate around a central value during the day (such as VWAP or some other level) rather than trend continuously. The Camarilla levels are designed to identify the precise price points where that mean reversion is most likely to occur, and where it's most likely to fail and become a genuine breakout instead.

The formula takes yesterday's high, low, and close and generates four resistance levels above (H1–H4) and four support levels below (L1–L4). The multipliers (0.0916, 0.183, 0.275, 0.55) are derived from Fibonacci ratios, which is what distinguishes Camarilla from classic pivot points that use simpler arithmetic.

H3 and L3 — the counter-trend levels. These are the workhorses of the system for day traders. The theory is that on a typical day, price will trade up to H3 or down to L3 and then reverse. You trade against the move at these levels — short at H3, long at L3 — with your stop placed just beyond H4 or L4 respectively. These setups have a high win rate in ranging, non-trending conditions because the market is simply oscillating within its expected daily range.

H4 and L4 — the breakout levels. When price breaks convincingly through H4 or L4, the mean-reversion thesis is invalidated. The market is telling you something unusual is happening — there's genuine directional momentum. At that point you flip your approach entirely and trade with the move, going long above H4 or short below L4, targeting H5 (which is H4 + the H4–H3 range) or L5 respectively. These are the high-reward trades but they occur less frequently.

H1, H2, L1, L2 — the minor levels. These are weaker and less reliable individually. Experienced Camarilla traders often use them as partial profit targets or as zones to tighten stops rather than as primary entry signals.

I prefer using Heikin Ashi candles on my chart -- however they are mathematically derived averages of price, calculated using a specific formula. Heikin Ashi candles do not show real price data. But on a regular candlestick chart it gets the actual market high, low, and close. On a Heikin Ashi chart you get the smoothed, averaged versions of those values -- which are always closer to the midpoint of the day's range and never reflect the true extremes. So I had to add in a tweak to use actual OHLC price data.

## Source Code

````pine
//@version=6 
////////////////////////////////////////////////////////////
// Camarilla Pivot Points V2 — with right-side labels
// Original formula by Nick Stott (bond trader)
// Labels added: each level labeled on the right edge of the chart,
// vertically centered on the line price.
//
// REAL PRICE FIX 1: uses ticker.new() to force actual OHLC data
// regardless of whether the chart is showing regular candles
// or Heikin Ashi candles. Pivot levels will now be identical
// on both chart types, correctly reflecting true market structure.
//
// REAL PRICE FIX 2: uses ticker.new() with session = syminfo.session
// and the non_heikin_ashi adjustment to force genuine OHLC data
// without creating ghost/duplicate levels on Heikin Ashi charts.
////////////////////////////////////////////////////////////
indicator(title = 'Camarilla Pivot Points V2', shorttitle = 'CPP v3', overlay = true)

res   = input.timeframe(title = 'Resolution', defval = 'D')
width = input.int(1, minval = 1)

// ── Label options ─────────────────────────────────────────────────────────────
showLabels  = input.bool(true,  title = 'Show labels',         group = 'Label Settings')
labelOffset = input.int(5,      title = 'Label offset (bars right of last bar)',
                                 minval = 0, maxval = 50,      group = 'Label Settings')
labelSize   = input.string('small', title = 'Label size',
                                 options = ['tiny','small','normal','large'],
                                 group = 'Label Settings')

// ── Real price ticker (ghost-free) ────────────────────────────────────────────
// ticker.new() with adjustment.none prevents Pine Script from inheriting
// the Heikin Ashi transformation applied to the chart, eliminating the
// duplicate ghost levels that appear between the real Camarilla levels.
realTicker = ticker.new(
     prefix     = syminfo.prefix,
     ticker     = syminfo.ticker,
     session    = syminfo.session,
     adjustment = adjustment.none
     )

xHigh  = request.security(realTicker, res, high[1],  gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
xLow   = request.security(realTicker, res, low[1],   gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
xClose = request.security(realTicker, res, close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// ── Level calculations ────────────────────────────────────────────────────────
H4 =  0.55   * (xHigh - xLow) + xClose
H3 =  0.275  * (xHigh - xLow) + xClose
H2 =  0.183  * (xHigh - xLow) + xClose
H1 =  0.0916 * (xHigh - xLow) + xClose
L1 = xClose - 0.0916 * (xHigh - xLow)
L2 = xClose - 0.183  * (xHigh - xLow)
L3 = xClose - 0.275  * (xHigh - xLow)
L4 = xClose - 0.55   * (xHigh - xLow)

// ── Colors ────────────────────────────────────────────────────────────────────
cH1 = color.new(#ff0000, 0)
cH2 = color.new(#ff002a, 0)
cH3 = color.new(#ff014a, 0)
cH4 = color.new(#ff014a, 0)
cL1 = color.new(#009600, 0)
cL2 = color.new(#006F00, 0)
cL3 = color.new(#004900, 0)
cL4 = color.new(#004900, 0)

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(H1[1], color = cH1, title = 'H1', style = plot.style_circles, linewidth = math.max(1, width))
plot(H2[1], color = cH2, title = 'H2', style = plot.style_circles, linewidth = math.max(1, width))
plot(H3[1], color = cH3, title = 'H3', style = plot.style_circles, linewidth = math.max(1, width))
plot(H4[1], color = cH4, title = 'H4', style = plot.style_circles, linewidth = math.max(1, width))
plot(L1[1], color = cL1, title = 'L1', style = plot.style_circles, linewidth = math.max(1, width))
plot(L2[1], color = cL2, title = 'L2', style = plot.style_circles, linewidth = math.max(1, width))
plot(L3[1], color = cL3, title = 'L3', style = plot.style_circles, linewidth = math.max(1, width))
plot(L4[1], color = cL4, title = 'L4', style = plot.style_circles, linewidth = math.max(1, width))

// ── Labels ────────────────────────────────────────────────────────────────────
f_size() =>
    switch labelSize
        'tiny'   => size.tiny
        'small'  => size.small
        'normal' => size.normal
        'large'  => size.large
        =>          size.small

f_label(lvl, txt, clr) =>
    if showLabels and barstate.islast
        label.new(
             x         = bar_index + labelOffset,
             y         = lvl,
             text      = txt,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(clr, 85),
             textcolor = clr,
             style     = label.style_label_left,
             size      = f_size()
         )

f_label(H4[1], 'H4 — Breakout',   cH4)
f_label(H3[1], 'H3 — Resistance', cH3)
f_label(H2[1], 'H2',              cH2)
f_label(H1[1], 'H1',              cH1)
f_label(L1[1], 'L1',              cL1)
f_label(L2[1], 'L2',              cL2)
f_label(L3[1], 'L3 — Support',    cL3)
f_label(L4[1], 'L4 — Breakout',   cL4)
````
