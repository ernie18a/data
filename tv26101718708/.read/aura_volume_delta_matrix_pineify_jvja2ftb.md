# Aura Volume Delta Matrix [Pineify]

- url: https://www.tradingview.com/script/jVJa2Ftb-Aura-Volume-Delta-Matrix-Pineify/
- type: indicator
- pine_id: PUB;6ace816f27974730ac1488de0ca81c55
- version: 1.0

## Description

[b]Aura Volume Delta Matrix [Pineify][/b]

This indicator measures the net demand pressure behind each bar by separating candle volume into buying and selling components, smoothing the difference, and plotting it as a gradient histogram against a signal line. Rather than treating volume as a single unsigned number, it asks: how much of this bar's volume was buying versus selling? The answer — [i]volume delta[/i] — reveals whether the crowd was net accumulating or distributing, even when price barely moved.

[b]Key Features[/b]

[list]
[*]Candle-polarity volume split: full bar volume attributed to buyers when close > open, sellers when close < open, and split 50/50 on doji candles

[*]Dual EMA smoothing pipeline — one pass to extract the trend from noisy raw delta, a second pass to generate a crossover signal line

[*]Normalized gradient histogram: bar intensity scales to the 100-bar rolling maximum, so weak readings appear faint and strong readings appear saturated, giving an immediate visual sense of magnitude relative to recent history

[*]Crossover signals that only fire when delta is already on the correct side of zero — filtering out shallow, mean-reverting crosses that would otherwise generate noise
[/list]

[b]How It Works[/b]

The calculation pipeline has three stages.

[list=1]
[*][i]Volume attribution:[ /i] Each bar's total volume is assigned to buyers or sellers based on candle polarity. A bullish close (close > open) attributes 100% to buyers; a bearish close (close < open) attributes 100% to sellers; equal open and close splits it evenly. This is a bar-level proxy for order flow — not tick-level CVD, but a reasonable approximation available on any timeframe without premium data.

[*][i]Delta smoothing:[ /i] Raw delta (bullVol − bearVol) is noisy on its own. A configurable EMA (default 14) removes single-bar spikes and reveals the directional bias over recent bars. This smoothed delta is what plots as the histogram.

[*][i]Signal line:[ /i] A second EMA (default 9) is applied to the smoothed delta. This behaves like the MACD signal line — when the histogram crosses above it while already positive, demand is re-accelerating from a bullish baseline; crossing below while negative signals the opposite.
[/list]

The gradient coloring normalizes the histogram against its own 100-bar peak, so you can immediately tell whether current delta intensity is historically significant or just routine churn.

[b]How the Components Work Together[/b]

The two-pass EMA structure is intentional. A single EMA of raw delta would react quickly but produce too many false crosses. By smoothing first and then deriving a signal from the smoothed output, the crossover logic only fires when momentum has already built enough to survive the first layer of filtering. The zero-side gate on signals adds a second filter: a bullish crossover below zero means demand is recovering within a still-bearish context, which is a weaker setup than a crossover that occurs while net buying is already dominant. Together these two conditions — crossover confirmed by zero-side context — push the signal rate down and focus it on higher-conviction shifts.

[b]Trading Ideas and Insights[/b]

[list]
[*]Use bullish crossovers (delta crosses above signal while delta > 0) as a candidate entry trigger on trending assets. Consider waiting for price to also be above a longer-period moving average before acting on the signal.

[*]Divergence between price making a new high and delta making a lower high may indicate absorption — sellers stepping in at resistance without moving price yet. This is worth watching rather than acting on automatically.

[*]On ranging markets, delta will oscillate around zero and the smoothing will compress toward the baseline. Low histogram intensity (faint gradient bars) visually signals low-conviction conditions where crossover signals are less reliable.

[*]The signal line alert conditions can be used to push notifications when the crossover setup occurs, removing the need to watch the chart continuously. Still, confirm with price structure before entering.
[/list]

As with any volume-based indicator, results vary by asset liquidity and data provider. Crypto and futures markets with transparent volume data tend to produce cleaner delta readings than instruments where reported volume is an estimate.

[b]Unique Aspects[/b]

[list]
[*]The gradient normalization against a rolling 100-bar peak is a visual improvement over fixed-scale histograms: it adapts to each instrument's typical volume range without manual scaling, making the chart readable across different assets.

[*]The zero-side signal filter avoids a common problem in oscillator crossover systems — signals that fire during shallow pullbacks within a larger counter-trend, where the histogram is technically crossing but the broader context is unfavorable.

[*]The doji split (50/50 at open = close) is a minor but honest edge case handling that most simplified volume delta scripts skip.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart. It works on all timeframes, though intraday timeframes tend to show more granular delta shifts.

[*]Watch histogram color and intensity. Solid, saturated green bars suggest strong net buying relative to recent history; faint bars suggest low-conviction buying or a quiet session.

[*]Look for crossovers of the orange signal line. Bullish: histogram rises through the signal line while above zero. Bearish: histogram falls below the signal while below zero. Half-crossovers (histogram crosses signal but is on the wrong side of zero) are filtered from alerts.

[*]Set alerts via the indicator's alert conditions if you want to monitor for crossover setups without watching the chart.
[/list]

[b]Customization[/b]

[list]
[*][b]Delta Smoothing Length[/b] (default: 14) — Controls how much the raw volume delta is smoothed before plotting. Higher values produce a slower, more stable histogram but introduce more lag. Lower values react faster and may show more noise.

[*][b]Signal Line Length[/b] (default: 9) — The EMA length applied to the smoothed delta to create the crossover trigger. Shorter values generate more frequent signals; longer values are more selective.

[*][b]Bullish / Bearish / Signal Colors[/b] — Fully customizable to match your chart theme or personal preference.
[/list]

[b]Conclusion[/b]

Aura Volume Delta Matrix translates raw bar volume into a directional demand measure, smooths it through a dual-EMA pipeline, and presents the result as a gradient histogram with a signal-line crossover system. It's most useful for traders who want a volume-based confirmation layer that isn't just "volume went up" but instead reflects which side of the trade had more participation. Pair it with price structure or trend context for best results — no volume indicator tells the full story on its own.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//
// Aura Volume Delta Matrix
// ------------------------
// Splits each bar's volume into buying and selling components based on candle polarity,
// computes the net delta, and smooths it through a dual-EMA pipeline into a gradient histogram.
// A second EMA (signal line) triggers crossover alerts only when delta is already on the
// correct side of zero — filtering shallow mean-reverting crosses from higher-conviction shifts.
//
// Delta states:
//   1. Positive and rising  — net buying pressure re-accelerating; potential bullish continuation
//   2. Positive and fading  — demand exhausting; watch for crossunder signal
//   3. Negative and falling — net selling dominant; potential bearish continuation
//

//@version=6
indicator("Aura Volume Delta Matrix [Pineify]", format=format.volume)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

grpCalc = "Calculation Settings"
smoothLen = input.int(14, "Delta Smoothing Length", minval=1, group=grpCalc, tooltip="Smooths out the raw volume delta to identify the true trend direction. Higher values reduce noise but add lag.")
sigLen    = input.int(9,  "Signal Line Length",     minval=1, group=grpCalc, tooltip="EMA of the smoothed delta used for crossover signals. Shorter = more signals, longer = more selective.")

grpStyle = "Aesthetic Settings"
bullColor = input.color(#089981, "Bullish Color", group=grpStyle, tooltip="Color applied to positive delta bars and their gradient fill.")
bearColor = input.color(#F23645, "Bearish Color", group=grpStyle, tooltip="Color applied to negative delta bars and their gradient fill.")
sigColor  = input.color(#FFB74D, "Signal Line Color", group=grpStyle, tooltip="Color of the signal line overlaid on the histogram.")

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// Attribute volume to buyers or sellers based on candle polarity.
// Doji candles (open == close) split volume evenly — a neutral assumption when direction is ambiguous.
bullVol = close > open ? volume : close == open ? volume * 0.5 : 0
bearVol = close < open ? volume : close == open ? volume * 0.5 : 0

// Net demand per bar: positive = buyers dominated, negative = sellers dominated
rawDelta = bullVol - bearVol

// First EMA pass smooths bar-level noise to reveal the directional bias over recent bars.
// Second EMA pass creates the signal line — analagous to the MACD signal — used for crossover detection.
smoothDelta = ta.ema(rawDelta, smoothLen)
signalLine  = ta.ema(smoothDelta, sigLen)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{

// Normalize delta magnitude against its 100-bar peak so the gradient reflects relative intensity,
// not absolute volume (which varies widely across assets and sessions).
maxDelta  = ta.highest(math.abs(smoothDelta), 100)
maxDelta  := na(maxDelta) or maxDelta == 0 ? 1 : maxDelta
normDelta = math.abs(smoothDelta) / maxDelta

// Gradient from faint (low intensity) to saturated (high intensity) within the bullish/bearish palette.
histColor = smoothDelta > 0
     ? color.from_gradient(normDelta, 0, 1, color.new(bullColor, 85), bullColor)
     : color.from_gradient(normDelta, 0, 1, color.new(bearColor, 85), bearColor)

plot(smoothDelta, "Aura Delta",  style=plot.style_columns, color=histColor)
plot(signalLine,  "Signal Line", color=sigColor, linewidth=2)

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Zero-side gate: only fire when delta is already on the favored side of zero.
// A bullish cross below zero means demand is recovering within a bearish context — a weaker setup
// that is intentionally excluded to reduce false positives.
buySignal  = ta.crossover(smoothDelta, signalLine)  and smoothDelta > 0
sellSignal = ta.crossunder(smoothDelta, signalLine) and smoothDelta < 0

// plotshape(buySignal,  title="Buy Signal",  style=shape.triangleup,   location=location.bottom, color=bullColor, size=size.small)
// plotshape(sellSignal, title="Sell Signal", style=shape.triangledown,  location=location.top,    color=bearColor, size=size.small)

alertcondition(buySignal,  title="Aura Buy Alert",  message="Aura Volume Delta: Bullish Momentum Shift Detected!")
alertcondition(sellSignal, title="Aura Sell Alert", message="Aura Volume Delta: Bearish Momentum Shift Detected!")
````
