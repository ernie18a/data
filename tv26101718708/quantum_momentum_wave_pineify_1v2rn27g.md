# Quantum Momentum Wave [Pineify]

- url: https://www.tradingview.com/script/1v2RN27G-Quantum-Momentum-Wave-Pineify/
- type: indicator
- pine_id: PUB;cadc2fd531e6420ca1f74ceceb9bba82
- version: 1.0

## Description

[b]Quantum Momentum Wave [Pineify][/b]

Quantum Momentum Wave is a signed peak-momentum oscillator paired with a Kaufman-style adaptive filter. Instead of measuring the net change from one point to another, the wave scans the full lookback window and returns the largest absolute price displacement with its original sign. The wave is linearly smoothed and then tracked by an adaptive signal line, so entry markers fire on context-filtered reversals rather than every momentum flip.

[b]Key Features[/b]

[list]
[*]Signed peak-momentum engine that isolates the strongest move inside the lookback

[*]Linear regression smoothing to tame the step-change behavior of raw peak readings

[*]Adaptive signal line that speeds up when the wave is stretched and slows down in noise

[*]Zone-filtered BUY and SELL markers that only fire when the wave is past zero in the opposite direction

[*]Gradient fill between the wave and zero — bullish above, bearish below

[*]Alerts for reversal setups and for zero-line regime shifts
[/list]

[b]How It Works[/b]

The core function is a QMW scan. On each bar it walks the last [i]Momentum Lookback[/i] bars, computes price minus each historical bar, and keeps the comparison that produced the largest absolute change. It returns that value with its original sign. So a -6 reading means the single strongest move inside the window was a 6-unit drop, even if the bar-to-bar change right now is small.

Raw peak readings step when a new candle takes over as the dominant move, so the output is passed through [i]linear regression[/i] over the Signal Smoothing length. LR fits a straight line through the recent raw values and returns its endpoint, preserving signed direction while cutting short-term jitter.

The adaptive signal runs a Kaufman-style update on top of the smoothed wave. Its coefficient is the ratio of the wave's absolute value to the sum of its recent absolute one-bar changes. When momentum is clearly extended and directional, the ratio is high and the signal follows quickly. When the wave oscillates near zero, the ratio collapses and the line nearly freezes.

[b]How the Components Work Together[/b]

Three layers combine into one output. The peak scan answers [i]how hard has price moved[/i] inside the window, not just where it ended. Linear regression answers [i]what is the underlying direction[/i] of the peak reading after filtering out one-bar swaps between competing peak bars. The adaptive signal answers [i]when has that direction actually shifted[/i] by providing a responsive reference line.

Entries layer a location filter on top. A crossover only qualifies when the wave is on the opposite side of zero — buys look for the wave turning up while stretched below zero, sells for the wave rolling over while stretched above it. Crosses near the midline are ignored because they tend to be low-conviction flips without prior displacement, so the setup is biased toward reversals from extended states rather than trend-chasing entries.

[b]Trading Ideas and Insights[/b]

[list]
[*]BUY triangles below zero can flag exhaustion of a downside push and a possible rotation back toward the mean

[*]SELL triangles above zero can flag fading upside strength after an extended rally

[*]Zero-line crosses act as broader regime markers; alerts on those can frame intraday bias

[*]During strong trends the wave may stay on one side of zero for many bars. Counter-trend BUY or SELL labels in that state often need extra confirmation from price structure or higher-timeframe context
[/list]

Signals are context aids, not standalone trade instructions. Past reactions at these conditions do not guarantee future ones.

[b]Unique Aspects[/b]

[list]
[*]The momentum calculation returns the peak signed displacement within the lookback, not a simple close-minus-close value. The reading stays elevated while the dominant move is still inside the window, which tracks the strongest displacement in memory rather than just endpoint delta

[*]The adaptive signal uses a non-standard variation of Kaufman's efficiency ratio — absolute wave value divided by total absolute wave travel — tuned for oscillator input rather than raw price

[*]Entry markers require both a crossover and a zone match. No label prints for a crossover that happens in the neutral zone around zero, which filters out the weakest setups
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to the chart and start with the defaults. The thicker line is the Quantum Wave; the fainter line is the Adaptive Signal

[*]Read the wave color and the gradient fill to see which side of zero the wave is on and how stretched it is

[*]Watch for BUY triangles when the wave is clearly below zero and turning up through the signal line

[*]Watch for SELL triangles when the wave is clearly above zero and turning down through the signal line

[*]Configure alerts for buy, sell, or zero-cross conditions if you want notifications outside the chart
[/list]

[b]Customization[/b]

[list]
[*][b]Source Data[/b] (default: close) — Price series used for the peak momentum scan

[*][b]Momentum Lookback[/b] (default: 14) — Window size for the peak displacement scan. Higher values capture broader swings; lower values react faster

[*][b]Signal Smoothing[/b] (default: 9) — Linear regression length applied to the raw wave. Higher values produce a cleaner line with more lag

[*][b]Bullish Color[/b] / [b]Bearish Color[/b] — Wave color in positive and negative territory, and the BUY/SELL marker colors

[*][b]Adaptive Signal Color[/b] — Color of the adaptive reference line; a subtle contrast against the wave usually reads cleanest
[/list]

[b]Limitations[/b]

[list]
[*]Linear regression smoothing introduces a small amount of lag. On fast reversals the wave can reach the crossover a few bars after price has already moved

[*]Because the adaptive ratio uses the wave's own value, very small wave readings near zero make the signal line nearly freeze. This is deliberate but means the reference reacts slowly while momentum is mild

[*]Mean-reversion style BUY and SELL labels can occur repeatedly during strong trends. Pair them with price structure or higher-timeframe bias instead of using them in isolation
[/list]

[b]Conclusion[/b]

Quantum Momentum Wave is for traders who want an oscillator that reflects the strongest recent move rather than the endpoint delta. Its value comes from the combination of peak-momentum measurement, linear regression smoothing, and an adaptive reference line that only produces labels when the wave is both stretched past zero and visibly turning back.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Quantum Momentum Wave
// ---------------------
// A signed peak-momentum oscillator. Instead of measuring the net change
// over a fixed window, the engine scans the full lookback and returns the
// largest absolute price displacement with its original sign. Linear
// regression smoothing cleans the raw wave, and an adaptive filter drives
// a signal line that speeds up when the wave is extended and slows down
// when it oscillates near zero.
//
// Three practical momentum states are highlighted:
//   1. Above zero — peak recent displacement is upward, bullish regime
//   2. At zero    — regime transition, direction is neutral or flipping
//   3. Below zero — peak recent displacement is downward, bearish regime
//
// Entry markers combine direction change (wave crosses its adaptive line)
// with location (wave stretched past zero) to favor context-filtered
// reversal setups over low-conviction midline flips.
//

//@version=6
indicator("Quantum Momentum Wave [Pineify]", "QMW [Pineify]", max_lines_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

grp_core   = "Core Settings"
grp_visual = "Aesthetics & Colors"

src       = input.source(close, "Source Data", group = grp_core, tooltip = "Price series that feeds the peak momentum scan and the adaptive signal line.")
len       = input.int(14, "Momentum Lookback", minval = 1, group = grp_core, tooltip = "How far back the peak displacement scan looks. Larger values smooth the wave and reveal broader swings; smaller values react faster but pick up more noise.")
smoothLen = input.int(9, "Signal Smoothing", minval = 1, group = grp_core, tooltip = "Linear regression length applied to the raw peak readings. Higher values reduce jitter at the cost of lag; lower values preserve timing but leave more step-change artifacts.")

bullColor = input.color(#00E676, "Bullish Color", group = grp_visual, tooltip = "Color applied to the wave and BUY markers while momentum is above zero.")
bearColor = input.color(#FF5252, "Bearish Color", group = grp_visual, tooltip = "Color applied to the wave and SELL markers while momentum is below zero.")
sigColor  = input.color(color.new(color.white, 30), "Adaptive Signal Color", group = grp_visual, tooltip = "Color of the adaptive reference line. A muted contrast against the wave usually reads cleanest.")

//---------------------------------------------------------------------------------------------------------------------}
// CORE CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// Peak signed momentum: walk back `length` bars, keep the comparison with
// the largest absolute change, and return that change with its original sign.
// Unlike a plain Momentum(length) reading, this ignores where the window
// ended and focuses on the strongest displacement inside the window — so
// the value stays elevated while the dominant move is still in the lookback.
calc_qmw(float data, int length) =>
    float max_val = 0.0
    float qmw_val = 0.0
    for i = 1 to length
        delta  = data - data[i]
        absMom = math.abs(delta)
        max_val := math.max(max_val, absMom)
        qmw_val := max_val == absMom ? delta : qmw_val
    qmw_val

// Adaptive signal filter. [Source: Kaufman Adaptive Moving Average family]
// The update uses the standard AMA form: ama = ama[1] + k * (data - ama[1]).
// The coefficient k is a non-standard efficiency variant: the absolute value
// of the input divided by the sum of its absolute one-bar changes. When the
// wave is clearly displaced versus its own back-and-forth travel, k is high
// and the filter tracks quickly. When the wave chops near zero, k collapses
// and the filter barely moves. Tuned for oscillator input rather than price.
calc_ama(float data, int length) =>
    var float ama_val = 0.0
    float sumChange       = math.sum(math.abs(ta.change(data)), length)
    float efficiencyRatio = sumChange != 0 ? math.abs(data) / sumChange : 0.0
    float alpha           = efficiencyRatio * (data - nz(ama_val[1], data))
    ama_val := nz(ama_val[1], data) + alpha
    ama_val

// Raw peak reading first, then linear-regression smoothed. The LR endpoint
// fit suppresses the one-bar step changes that happen when a new candle
// takes over as the peak inside the lookback, without discarding signed direction.
raw_mom    = calc_qmw(src, len)
smooth_mom = ta.linreg(raw_mom, smoothLen, 0)

// Adaptive reference that trails the wave during drift and accelerates once
// the wave is clearly stretched in one direction.
signal = calc_ama(smooth_mom, len)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{

// Sign of the smoothed wave drives regime coloring so the line itself carries state.
waveColor = smooth_mom > 0 ? bullColor : bearColor

plot(smooth_mom, "Quantum Wave",    color = waveColor, style = plot.style_line, linewidth = 2)
plot(signal,     "Adaptive Signal", color = sigColor,  linewidth = 1)

// Invisible zero baseline anchors the gradient fill between the wave and zero.
zeroPlot = plot(0, "Zero Baseline", color = color.new(color.gray, 80), display = display.none)

// Gradient aura: dense near the wave, transparent near zero. Above zero the
// fill leans bull-color, below zero it flips to bear-color. Visual weight
// communicates how stretched the wave is without adding extra labels.
fill(zeroPlot, zeroPlot,
     top_value    = smooth_mom > 0 ? smooth_mom : 0,
     bottom_value = smooth_mom > 0 ? 0 : smooth_mom,
     top_color    = smooth_mom > 0 ? color.new(bullColor, 50)  : color.new(bearColor, 100),
     bottom_color = smooth_mom > 0 ? color.new(bullColor, 95)  : color.new(bearColor, 50),
     title = "Momentum Gradient Fill")

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Context-filtered reversal setups. The wave must be on the opposite side of
// zero at the time of the cross: buys require the wave to be stretched below
// zero and turning up through its adaptive line; sells require the mirror.
// Crosses near the midline are intentionally ignored because they tend to
// represent low-conviction flips without prior displacement.
buyCond  = ta.crossover(smooth_mom, signal)  and smooth_mom < 0
sellCond = ta.crossunder(smooth_mom, signal) and smooth_mom > 0

plotshape(buyCond,  title = "Buy Signal",  text = "BUY",  style = shape.triangleup,   location = location.bottom, color = bullColor, textcolor = bullColor, size = size.small)
plotshape(sellCond, title = "Sell Signal", text = "SELL", style = shape.triangledown, location = location.top,    color = bearColor, textcolor = bearColor, size = size.small)

alertcondition(buyCond,                      title = "QMW Buy Alert",          message = "QMW Buy Signal - wave turned up while below zero")
alertcondition(sellCond,                     title = "QMW Sell Alert",         message = "QMW Sell Signal - wave turned down while above zero")
alertcondition(ta.crossover(smooth_mom, 0),  title = "QMW Bullish Zero Cross", message = "QMW crossed above zero - momentum regime turned bullish")
alertcondition(ta.crossunder(smooth_mom, 0), title = "QMW Bearish Zero Cross", message = "QMW crossed below zero - momentum regime turned bearish")
````
