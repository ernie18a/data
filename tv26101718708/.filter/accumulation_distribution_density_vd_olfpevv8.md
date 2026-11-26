# Accumulation / Distribution Density (VD)

- url: https://www.tradingview.com/script/olfpEvv8/
- type: indicator
- pine_id: PUB;ff53290f4c234b07930f0b2e0d6b4858
- version: 1.0

## Description

A volume indicator for TradingView (Pine Script v6), modeled after [b]Mieczyslaw Siudek's "Accumulation / Distribution Density" (VD)[/b] from xStation (XTB). It hunts for candles where a [b]disproportionately large volume produced a disproportionately small price move[/b] at a fresh local extreme - a classic footprint of a big player building (accumulation) or unloading (distribution) a position.

█ [b]🧠 THE IDEA: DENSITY[/b]

[b]Density = volume / candle range (high - low)[/b] - "how much turnover per unit of movement".

[list]
[*]🚚 [b]A lot of volume + a small candle[/b] = high density. Someone big is absorbing everything the market throws at them, so price cannot move.
[*]🪶 A lot of volume + a big candle = normal. The volume simply traveled with the price.
[/list]

[pine]
   normal candle              density candle
   volume:  ██ 2K             volume:  ████████ 8K
   range:   │ (big)           range:   ▮ (small)
            │
            │                          ▮  ← 8K went in, price barely moved:
            │                          ▲     someone ABSORBED it (marker)
[/pine]

When such a candle also sets a [b]new local low[/b], buyers were absorbing the sell-off → [b]accumulation[/b] (marker [b]below[/b] the candle). At a [b]new local high[/b], sellers were absorbing the buying → [b]distribution[/b] (marker [b]above[/b] the candle).

[pine]
 price
   │      ▼  ← distribution: new high, huge volume, small candle
   │   ┌──┸──┐
   │  ─┘     └─┐
   │           └──┐        ┌───
   │              └─┐   ┌──┘
   │                └─┰─┘
   │                  ▲  ← accumulation: new low, huge volume, small candle
   └────────────────────────── time
[/pine]

█ [b]⚙️ SIGNAL CONDITIONS[/b]

A marker appears on a candle only when [b]all[/b] of these hold:

[list=1]
[*]📉 [b]New extreme[/b] - the candle's [b]low[/b] is at or below the lowest low of the previous [i]Max/Min of[/i] candles (accumulation), or its [b]high[/b] is at or above the highest high of those candles (distribution).
[*]🚚 [b]High density[/b] - [b]volume / range >= Density Factor x average density[/b].
[*]🤏 [b]Small candle[/b] (optional, [i]Spread condition[/i]) - [b]range <= Spread Factor x average range[/b].
[*]🎯 [b]Close position[/b] (optional, [i]Bar close %[/i]) - for accumulation the close must sit at least X% above the low; for distribution at least X% below the high. [b]0[/b] disables the filter.
[*]🔊 [b]volume > 0[/b] - instruments without volume data never signal.
[/list]

Both averages (range and density) use a window [b]ending at the previous candle[/b] - the signal candle does not inflate its own threshold.

By default the conditions are checked only once the candle [b]closes[/b] ([i]Signal on closed candle only[/i]) - a marker never appears and then disappears on the live candle.

█ [b]🛠️ PARAMETERS[/b]

[b]Parameters (as in xStation)[/b]

[list]
[*][b]Max/Min of (bars)[/b] [i](default 5)[/i] - how many previous candles the signal candle must out-low / out-high.
[*][b]Average Spread of (bars)[/b] [i](default 5)[/i] - window for the average range.
[*][b]Average Density of (bars)[/b] [i](default 5)[/i] - window for the average density.
[*][b]Spread condition[/b] [i](default on)[/i] - toggle for the "candle must not be too big" filter.
[*][b]Spread Factor[/b] [i](default 1.4)[/i] - how much larger than the average range the signal candle may be.
[*][b]Density Factor[/b] [i](default 2)[/i] - how many times the average density the candle must reach.
[*][b]Bar close (%)[/b] [i](default 0)[/i] - the close-position filter described above.
[*][b]Signal on closed candle only[/b] [i](default on)[/i] - evaluate signals only when a candle closes (no repainting). Turn off to watch signals form in real time on the unclosed candle - such a signal may vanish before the close.
[/list]

[b]Appearance (Style tab)[/b]

Markers are plotshapes, so each signal gets its own row in the [b]Style[/b] tab of the indicator settings - with a visibility checkbox, a marker-shape picker, a position dropdown ([i]Above bar[/i] / [i]Below bar[/i]), and a color:

[list]
[*][b]Accumulation[/b] [i](default: triangle below the bar)[/i],
[*][b]Distribution[/b] [i](default: triangle above the bar)[/i].
[/list]

█ [b]🔔 ALERTS[/b]

[list]
[*][b]Accumulation density[/b] - potential bullish signal (heavy volume, little movement, new low).
[*][b]Distribution density[/b] - potential bearish signal (heavy volume, little movement, new high).
[/list]

With [i]Signal on closed candle only[/i] on (default) alerts fire at the candle close. If you turn that option off, set the alert trigger to [b]Once Per Bar Close[/b] - otherwise an alert can fire on a live-candle signal that later vanishes.

█ [b]📤 SIGNAL OUTPUT[/b]

The script exposes a hidden [b]Signal[/b] series: [b]+1[/b] (accumulation), [b]-1[/b] (distribution), [b]0[/b] (none). It is visible in the Data Window and can be used as an [b]external source[/b] in other indicators and strategies (any [b]input.source[/b] field) - e.g. to build your own strategy on top of these signals.

█ [b]✅ CORRECTNESS - VERIFIED[/b]

The implementation was verified empirically (2026-08-18): signals recomputed [b]independently[/b] (Node.js, same formulas) from OHLCV bars pulled off a live TradingView chart (COMEX:GC1!, 60m, 300 bars) and compared with the markers the Pine script actually drew:

[list]
[*]default parameters → [b]1 signal, exact match[/b] (and 299 bars correctly without a marker),
[*]relaxed parameters (Max/Min 3, Spread Factor 2.5, Density Factor 1.2) → [b]63 signals, exact match[/b], zero missing, zero extra.
[/list]

The script does exactly what this note describes.

█ [b]⚠️ WHY MARKERS DIFFER FROM XSTATION[/b]

Even with identical parameter values, markers [b]will not land 1:1[/b] on xStation's. This is expected, not a bug:

[list=1]
[*]📊 [b]Different data.[/b] xStation runs on XTB's own CFD feed; its volume is XTB [b]tick volume[/b] (count of price updates in XTB's book). TradingView shows [b]real exchange volume[/b] (futures/stocks) or another provider's feed. Density = volume / range is extremely sensitive to both - different volume [b]and[/b] different OHLC (session hours, timezone, weekend CFD candles) shift every threshold in the formula.
[*]🔒 [b]The original algorithm is closed source.[/b] XTB only published parameter descriptions, not formulas. Ambiguities the port had to decide (each can move single markers):
[list]
[*]averages computed over the window [b]ending at the previous candle[/b] (the original may include the signal candle),
[*]new-extreme check uses [b]<=[/b] / [b]>=[/b] (the original may require a strict break),
[*]a zero-range candle (doji) divides by one tick instead of being skipped,
[*]"Bar close %" measured from the low (accumulation) / from the high (distribution).
[/list]
[*]⏳ [b]Live-candle behavior.[/b] With [i]Signal on closed candle only[/i] turned off, conditions are evaluated on live values, so a marker on an unclosed candle can disappear before the close. The default (on) evaluates only closed candles; xStation's behavior here is unknown.
[/list]

[b]Practical takeaway:[/b] compare the two on the [b]same market data type[/b] (e.g. gold futures on both), expect agreement in [i]character[/i] (markers cluster in the same spots), not in identical candles.

█ [b]⛔ LIMITATIONS[/b]

[list]
[*]Requires an instrument with [b]volume data[/b] - many TVC CFDs (TVC:GOLD, TVC:USOIL) have zero volume and never signal; the script then shows a warning in the top-right corner of the chart. Check per symbol (e.g. TVC:UKOIL [i]does[/i] have volume) or use futures (e.g. COMEX:GC1!).
[*]A signal on an unclosed candle may vanish before the close - only with [i]Signal on closed candle only[/i] turned off (see above).
[/list]

© Piotr Kowalski "piecioshka". License: Mozilla Public License 2.0.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Piotr Kowalski "piecioshka"
// Docs (EN): https://github.com/piecioshka/tradingview-pine-scripts/blob/main/indicators/volume/accumulation-distribution-density/accumulation-distribution-density.md
// Docs (PL): https://github.com/piecioshka/tradingview-pine-scripts/blob/main/indicators/volume/accumulation-distribution-density/accumulation-distribution-density.pl.md

//@version=6
indicator('Accumulation / Distribution Density (VD)', overlay=true)

// Accumulation / distribution density (VD) — modeled after Mieczyslaw Siudek's indicator from xStation (XTB).
// Looks for candles whose volume-to-price-movement ratio (density = volume per unit of range)
// is disproportionately high and which set a local extreme. Heavy turnover with little movement
// at a low/high suggests position accumulation/distribution and a potential turning point.
// Marker below a candle = accumulation density  (potential bullish signal),
// marker above a candle = distribution density  (potential bearish signal).
// Each marker is a plotshape, so the Style tab gives it its own visibility checkbox,
// shape picker, position (above/below bar) dropdown, and color — per signal.
// By default signals are evaluated only on closed candles (no repainting); with the
// "Signal on closed candle only" option off, a signal on an unclosed candle may disappear
// before it closes (conditions use live values).

g = 'Parameters'
lenExtreme    = input.int(5, 'Max/Min of (bars)', minval=1, group=g, tooltip='Number of previous candles against which the signal candle must set a new low (accumulation) or a new high (distribution).')
lenSpread     = input.int(5, 'Average Spread of (bars)', minval=1, group=g, tooltip='Number of candles for the average range (high − low).')
lenDensity    = input.int(5, 'Average Density of (bars)', minval=1, group=g, tooltip='Number of candles for the average density (volume / range).')
useSpread     = input.bool(true, 'Spread condition', group=g, tooltip='Require the signal candle range not to exceed Spread Factor × average range (the candle must not be too big — density means heavy turnover with LITTLE movement).')
spreadFactor  = input.float(1.4, 'Spread Factor', minval=0.1, step=0.1, group=g, tooltip='How much larger the signal candle range may be than the average for a signal to appear.')
densityFactor = input.float(2, 'Density Factor', minval=1.0, step=0.1, group=g, tooltip='How much the signal candle density must exceed the average density.')
closePct      = input.int(0, 'Bar close (%)', minval=0, maxval=100, group=g, tooltip='Filter on the close position within the candle range: for accumulation the close must be at least X% above the low, for distribution at least X% below the high. 0 disables the filter.')
onlyConfirmed = input.bool(true, 'Signal on closed candle only', group=g, tooltip='Evaluate signals only when a candle closes - a marker never appears and then disappears on the live candle (no repainting). Turn off to watch signals form in real time on the unclosed candle.')

spread  = high - low
density = volume / math.max(spread, syminfo.mintick)   // volume per unit of movement; a zero-range doji → volume per 1 tick

// Averages use a window ENDING at the previous candle — the signal candle does not inflate its own threshold.
avgSpread  = ta.sma(spread, lenSpread)[1]
avgDensity = ta.sma(density, lenDensity)[1]

isNewLow  = low <= ta.lowest(low, lenExtreme)[1]
isNewHigh = high >= ta.highest(high, lenExtreme)[1]

densityOK = density >= densityFactor * avgDensity
spreadOK  = not useSpread or spread <= spreadFactor * avgSpread

// Close position within the candle range (0–100); a zero-range candle passes the filter in both directions
posFromLow  = spread > 0 ? (close - low) / spread * 100 : 100
posFromHigh = spread > 0 ? (high - close) / spread * 100 : 100

// On historical candles barstate.isconfirmed is always true — the option only affects the live candle.
confirmedOK = not onlyConfirmed or barstate.isconfirmed

accSignal  = confirmedOK and volume > 0 and isNewLow and densityOK and spreadOK and posFromLow >= closePct
distSignal = confirmedOK and volume > 0 and isNewHigh and densityOK and spreadOK and posFromHigh >= closePct

// Markers as plotshapes — shape, position, and color live in the Style tab, per signal.
plotshape(accSignal, 'Accumulation', style=shape.triangleup, location=location.belowbar, color=color.rgb(74, 136, 250), size=size.small)
plotshape(distSignal, 'Distribution', style=shape.triangledown, location=location.abovebar, color=color.rgb(215, 125, 95), size=size.small)

alertcondition(accSignal, 'Accumulation density', 'Accumulation density — potential bullish signal (heavy volume with little movement at a new low)')
alertcondition(distSignal, 'Distribution density', 'Distribution density — potential bearish signal (heavy volume with little movement at a new high)')

// Hidden signal series (+1 accumulation, -1 distribution, 0 none) — lets other scripts
// use this indicator as an external source (input.source) and shows up in the Data Window.
plot(accSignal ? 1 : distSignal ? -1 : 0, 'Signal', display=display.data_window, editable=false)

// Warn when the symbol has no volume data at all — the indicator can never signal there.
cumVolume = ta.cum(nz(volume))
if barstate.islast and cumVolume == 0
    var table warn = table.new(position.top_right, 1, 1)
    table.cell(warn, 0, 0, 'No volume data on this symbol - the indicator cannot signal', text_color=color.white, bgcolor=color.new(color.red, 15), text_size=size.small)
````
