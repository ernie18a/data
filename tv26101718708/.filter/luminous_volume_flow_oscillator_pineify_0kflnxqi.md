# Luminous Volume Flow Oscillator [Pineify]

- url: https://www.tradingview.com/script/0KflNXqI-Luminous-Volume-Flow-Oscillator-Pineify/
- type: indicator
- pine_id: PUB;716786c1ca8045e79027739ea5674511
- version: 1.0

## Description

[b]Luminous Volume Flow Oscillator [Pineify][/b]

This indicator splits each bar's volume into buying and selling pressure using bar polarity — where the close sits within the high-low range — then smooths the net delta into a flowing oscillator. Unlike simple up/down volume counters that only compare close vs. open, bar polarity captures intrabar conviction: a close near the high with heavy volume tells a different story than a close near the midpoint. The result is a momentum-style oscillator driven by volume direction rather than price alone.

[b]Key Features[/b]

[list]
[*]Bar-polarity volume splitting that goes beyond basic open/close comparison

[*]EMA-smoothed volume delta oscillator with dynamic gradient coloring

[*]Signal line crossovers filtered by oscillator zone — buy signals only fire below zero, sell signals only above

[*]Adaptive color intensity that scales to recent volume momentum range
[/list]

[b]How It Works[/b]

The calculation starts by classifying each bar's directional bias. If the close is closer to the high than the low — meaning [i](close − low) > (high − close)[/i] — the bar is considered buyer-dominated and the full volume is assigned as buying pressure. The inverse applies for seller-dominated bars. When the close position is ambiguous, the indicator falls back to a simple close-vs-open check.

[list=1]
[*]Volume is split into buying (upVol) and selling (dnVol) components based on bar polarity

[*]The raw [i]volume delta[/i] (upVol − dnVol) is calculated — positive means net buying, negative means net selling

[*]An EMA smooths the delta to filter out single-bar noise, producing the main oscillator line

[*]A simple moving average of the smoothed delta creates the signal line for crossover detection
[/list]

[b]How the Components Work Together[/b]

The bar-polarity classification acts as the first filter: it determines who controlled the bar. The EMA smoothing then reveals the underlying trend in volume direction by stripping out random fluctuations. On top of this, the signal line provides timing — when the oscillator crosses the signal line, it suggests a shift in volume momentum direction.

The zone filter ties everything together. Buy signals require the oscillator to be below zero (net selling territory) when the bullish crossover occurs. This means you're catching potential reversals where selling pressure is already dominant but starting to weaken — not chasing after volume momentum is already extended. Sell signals work in reverse, firing only when the oscillator is above zero and bearish momentum starts to take over.

[b]Trading Ideas and Insights[/b]

[list]
[*]When the oscillator crosses above the signal line while below zero, it may indicate that selling pressure is exhausting and buyers are stepping in — consider this a potential early reversal signal rather than a confirmed trend change

[*]Divergence between price making new highs and the oscillator failing to do so can flag weakening conviction behind the move

[*]The histogram gradient intensity provides a quick visual read: deep, saturated colors mean strong directional volume; faded colors suggest the move is losing participation
[/list]

Note that bar-polarity volume splitting is an approximation — it doesn't use actual tick-level order flow data. During low-volume or choppy sessions, the oscillator can produce noise even after EMA smoothing. Combine with price structure or trend context for better results.

[b]Unique Aspects[/b]

[list]
[*]Bar polarity is a more nuanced volume classification than simple candle direction. A bullish candle with its close near the midpoint gets less credit than one closing near the high — this distinction matters in real markets where wicks tell the story

[*]The zone-filtered signal approach acts as a built-in mean-reversion guard. Rather than generating signals at momentum extremes (where risk/reward deteriorates), it targets the inflection zone where directional volume is shifting

[*]Dynamic gradient scaling using a 100-bar lookback means the color intensity adapts to recent conditions — a moderate reading in a low-volatility period still shows up clearly
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to your chart. The histogram shows the smoothed volume delta — bars above zero indicate net buying pressure, below zero net selling

[*]Watch for the gray signal line crossovers. A crossover while the histogram is below zero is a potential buy setup; a crossunder while above zero is a potential sell setup

[*]Use the gradient color intensity as a confidence gauge — stronger colors mean more decisive volume flow in that direction

[*]Set up alerts for automated notifications when buy or sell conditions trigger
[/list]

[b]Customization[/b]

[list]
[*][b]Volume Smoothing Length[/b] (default: 14) — Controls how much the raw volume delta is smoothed. Higher values produce a calmer oscillator but introduce more lag; lower values are more responsive but noisier

[*][b]Signal Line Length[/b] (default: 9) — Sets the SMA period for the signal line. Shorter lengths generate more frequent crossovers; longer lengths filter out minor fluctuations

[*][b]Bullish / Bearish Color[/b] — Customize the gradient palette for positive and negative volume flow

[*][b]Show Signals / Histogram / Signal Line[/b] — Toggle individual visual components on or off to declutter the chart
[/list]

[b]Conclusion[/b]

The Luminous Volume Flow Oscillator turns raw volume into a directional momentum reading by splitting each bar's volume according to where price closed within its range. The zone-filtered signal approach keeps entries focused on inflection points rather than chasing extended moves. It works best as a confirmation tool alongside price action or trend-following methods — volume tells you the conviction behind a move, but never the whole story on its own.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Luminous Volume Flow Oscillator
// --------------------------------
// Splits each bar's volume into buying/selling pressure using bar polarity —
// where the close sits within the high-low range — then smooths the net delta
// into a directional oscillator. A signal line provides crossover timing.
//
// Key concepts:
//   1. Bar polarity — close near high = buyer-dominated, close near low = seller-dominated
//   2. Volume delta — net difference between buying and selling volume per bar
//   3. Zone-filtered signals — crossovers only valid in the opposite zone (buy below 0, sell above 0)
//

//@version=6
indicator("Luminous Volume Flow Oscillator [Pineify]", format=format.volume, max_lines_count=500, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
GREEN = #089981
RED   = #F23645

grp_core = "Core Settings"
lengthInput  = input.int(14, 'Volume Smoothing Length', minval=1, group=grp_core, tooltip='EMA period for the volume delta. Higher values produce a calmer oscillator but add lag; lower values are more responsive but noisier.')
signalLength = input.int(9, 'Signal Line Length', minval=1, group=grp_core, tooltip='SMA period for the signal line. Shorter lengths generate more frequent crossovers; longer lengths filter out minor fluctuations.')

grp_style = "Style"
bullColorInput = input.color(GREEN, 'Bullish Color', inline='Colors', group=grp_style, tooltip='Color for positive volume flow (net buying pressure).')
bearColorInput = input.color(RED, 'Bearish Color', inline='Colors', group=grp_style, tooltip='Color for negative volume flow (net selling pressure).')

grp_display = "Display Options"
showSignals    = input.bool(true, 'Show Signals', inline='Display', group=grp_display, tooltip='Toggle buy/sell signal markers on the chart.')
showHistogram  = input.bool(true, 'Show Histogram', inline='Display', group=grp_display, tooltip='Toggle the main volume flow histogram.')
showSignalLine = input.bool(true, 'Show Signal Line', inline='Display', group=grp_display, tooltip='Toggle the signal line overlay.')

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{
// Bar polarity: where the close sits within the high-low range determines directional bias.
// A close near the high (large close-low, small high-close) signals buyer control;
// a close near the low signals seller control. This is more granular than candle color alone.
bull_pressure = (close - low) > (high - close)
bear_pressure = (close - low) < (high - close)

// When polarity is ambiguous (close near midpoint), fall back to simple open/close direction
upVol = bull_pressure ? volume : (close > open ? volume : 0)
dnVol = bear_pressure ? volume : (close < open ? volume : 0)

volDelta = upVol - dnVol

// EMA smoothing reveals the underlying volume direction trend by filtering out single-bar noise
smoothedDelta = ta.ema(volDelta, lengthInput)
signalLine    = ta.sma(smoothedDelta, signalLength)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
// 100-bar lookback for gradient scaling — adapts color intensity to recent conditions
// so moderate readings in quiet periods still show up clearly
maxDelta = ta.highest(smoothedDelta, 100)
minDelta = ta.lowest(smoothedDelta, 100)

// Gradient maps oscillator value to color opacity: near-zero = faded, at extremes = fully saturated
bullGrad = color.from_gradient(smoothedDelta, 0, maxDelta, color.new(bullColorInput, 80), bullColorInput)
bearGrad = color.from_gradient(smoothedDelta, minDelta, 0, bearColorInput, color.new(bearColorInput, 80))

histColor = smoothedDelta > 0 ? bullGrad : bearGrad

plot(showHistogram ? smoothedDelta : na, 'Volume Flow', histColor, style=plot.style_columns)
plot(showSignalLine ? signalLine : na, 'Signal Line', color=color.new(color.gray, 30), linewidth=2)

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
// Zone-filtered crossovers: requiring the oscillator to be in the opposite zone
// catches inflection points where pressure is shifting, not chasing extended moves
buySignal  = ta.crossover(smoothedDelta, signalLine) and smoothedDelta < 0
sellSignal = ta.crossunder(smoothedDelta, signalLine) and smoothedDelta > 0

// plotshape(showSignals and buySignal,  title='Buy Signal',  style=shape.triangleup,   location=location.bottom, color=bullColorInput, size=size.small)
// plotshape(showSignals and sellSignal, title='Sell Signal', style=shape.triangledown, location=location.top,    color=bearColorInput, size=size.small)

alertcondition(buySignal, title='Buy Signal', message='Luminous VFO: Buy Signal detected - Volume momentum shifting positive')
alertcondition(sellSignal, title='Sell Signal', message='Luminous VFO: Sell Signal detected - Volume momentum shifting negative')
````
