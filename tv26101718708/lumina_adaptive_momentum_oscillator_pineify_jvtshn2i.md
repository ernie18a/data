# Lumina Adaptive Momentum Oscillator [Pineify]

- url: https://www.tradingview.com/script/jVtshn2i-Lumina-Adaptive-Momentum-Oscillator-Pineify/
- type: indicator
- pine_id: PUB;0e212268bf95449c9d3dd6d23f97fb96
- version: 1.0

## Description

[b]Lumina Adaptive Momentum Oscillator[/b]

This oscillator measures price momentum through a double-smoothed triangular moving average, then overlays a Kaufman-style Adaptive Moving Average as a signal line that accelerates in trending conditions and slows in ranging ones. The result is a histogram that stays cleaner than a simple ROC or MACD while still catching real directional shifts — buy and sell signals fire only when momentum crosses the adaptive signal while on the "wrong" side of zero, filtering out crosses that occur mid-trend.

[b]Key Features[/b]

[list]
[*]Triangular MA momentum — double SMA smoothing cuts through noise that a single-period momentum calculation amplifies

[*]Kaufman Adaptive Moving Average signal line — efficiency-ratio scaling means the signal line tracks fast when price has clear direction and lags conservatively during chop

[*]Polarity-colored histogram — bars flip between bull and bear colors on the zero line, making directional bias readable at a glance

[*]Counter-trend signal filter — buy signals require momentum to be below zero; sell signals require it above, so the oscillator only flags reversals, not trend continuation pulses

[*]Configurable alerts for buy and sell conditions (uncomment the alertcondition lines to enable)
[/list]

[b]How It Works[/b]

[list=1]
[*][i]Triangular momentum[/i]: A triangular moving average is the SMA of an SMA — [i]ta.sma(ta.sma(close, length), length)[/i]. This double pass heavily weights the middle of the lookback window, producing a line that barely reacts to individual candle spikes. Momentum is then the change in this average over [i]length[/i] bars, equivalent to asking: "how much has the ultra-smooth baseline shifted over the period?"

[*][i]Adaptive signal line (AMA)[/i]: The signal applies a Kaufman Adaptive Moving Average to the momentum values. Each bar, an Efficiency Ratio is computed as the absolute cumulative price change divided by the sum of bar-by-bar absolute changes over the window. A high ER (price moving steadily in one direction) produces a fast smoothing constant; a low ER (lots of back-and-forth) produces a slow one. The smoothing constant is squared before application — squaring compresses near-zero values toward zero and pushes higher values closer to one, amplifying the contrast between ranging and trending states.

[*][i]Signals[/i]: A buy condition fires when the momentum histogram crosses above the signal line from below zero. A sell condition fires when momentum crosses below the signal line from above zero. Both plotshape and alertcondition calls are included but commented out by default, so the chart stays clean unless signals are explicitly enabled.
[/list]

[b]How the Components Work Together[/b]

The triangular MA reduces the raw momentum noise that trips up standard crossover strategies. A plain ta.change(close, length) signal line would fire constantly in sideways markets because individual candle closes swing around. By first anchoring momentum to a doubly-smoothed baseline, the histogram only moves when an actual directional shift is underway in price.

The AMA signal line then adapts to how directional that momentum itself is. When momentum is trending (e.g., steadily falling through a corrective move), the AMA tracks it closely, keeping the histogram-to-signal gap narrow and the crossover conditions quiet. When momentum flips abruptly — the scenario a reversal trader wants — the ER spikes, the smoothing constant rises, and the signal line catches up quickly enough to generate a timely cross.

The zero-side filter adds the final constraint: only counter-trend crosses matter. A bullish cross above zero would typically mean momentum is already positive and the trend is continuing, not reversing — those are excluded. This makes the signals less frequent but more aligned with actual turning points.

[b]Trading Ideas and Insights[/b]

[list]
[*]Use on the daily or 4H chart during confirmed trending markets. Wait for pullbacks that drive momentum negative, then watch for a histogram-crosses-signal event below zero as an early re-entry cue. Confirmation from price action (e.g., a higher low or a break of the short-term descending channel) reduces false positives.

[*]On intraday charts, the double smoothing introduces noticeable lag — roughly 2× the period in bars. For a 14-bar setting this means signals may appear 3-5 candles after the actual reversal candle. Consider reducing length to 7-9 on lower timeframes to recover responsiveness.

[*]The signal line (currently commented out) can be uncommented as an additional visual layer. When the histogram bars are shrinking toward zero while the signal line is still diverging, it often indicates momentum exhaustion before the actual cross occurs, giving a heads-up for limit orders.
[/list]

[b]Unique Aspects[/b]

[list]
[*]Most MACD-style oscillators apply EMA smoothing to raw price; this one applies double-SMA smoothing before differencing, which produces a different noise profile — more immune to single-bar wicks but slower to react to sharp moves

[*]Applying the Kaufman AMA to momentum values (rather than price) is less common. The efficiency ratio reflects momentum's own trendiness, not price's, so the adaptive behavior is tuned to the oscillator's dynamic rather than borrowed from a price-following MA

[*]The zero-side signal filter is built in rather than left to the trader to configure — the indicator makes an explicit methodological choice that these signals represent reversals only
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to any chart. The default length of 14 suits daily and 4H charts; adjust lower for faster timeframes.

[*]Watch the histogram color: sustained green bars above zero indicate positive momentum; sustained red bars below zero indicate negative momentum.

[*]For signals: uncomment the two [i]plotshape[/i] lines in the source to display BUY/SELL labels, or uncomment the [i]alertcondition[/i] lines and create alerts via TradingView's alert panel.

[*]A BUY label appears when the histogram crosses above the signal line while below zero — a potential momentum reversal from bearish territory.

[*]A SELL label appears when the histogram crosses below the signal line while above zero — a potential momentum reversal from bullish territory.

[*]Combine with a higher-timeframe trend filter (e.g., price above/below a 200 EMA) to take only signals aligned with the prevailing trend.
[/list]

[b]Customization[/b]

[list]
[*][b]Data Length[/b] (default: 14) — Controls the period for both the triangular MA and the adaptive signal line. Higher values produce smoother output with more lag; lower values react faster but generate more noise. Typical range: 7–21.

[*][b]Bullish Color[/b] (default: green) — Color of histogram bars when momentum is positive.

[*][b]Bearish Color[/b] (default: red) — Color of histogram bars when momentum is negative.
[/list]

[b]Conclusion[/b]

The Lumina Adaptive Momentum Oscillator combines triangular-MA momentum with a Kaufman-adaptive signal line to surface genuine reversal pressure rather than routine oscillations. The built-in zero-side signal filter keeps the indicator focused on counter-trend setups, making it most useful as a timing tool within a larger trend-following framework. Past patterns do not guarantee future results — use alongside price structure and volume confirmation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//
// Lumina Adaptive Momentum Oscillator
// ------------------------------------
// Measures momentum via the change in a triangular (double-SMA) moving average,
// then applies a Kaufman Adaptive Moving Average as a signal line that speeds up
// in trending conditions and slows in choppy ones.
//
// Signal modes:
//   1. Histogram — double-smoothed momentum, colored by polarity relative to zero
//   2. Adaptive signal line — AMA of momentum (uncomment to overlay)
//   3. Reversal signals — cross below zero (buy) or above zero (sell) only
//

//@version=6
indicator('Lumina Adaptive Momentum Oscillator [Pineify]', format=format.price, precision=4)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{

grp_main   = "Momentum Settings"
grp_colors = "Aesthetics & Colors"

lengthInput = input.int(14, 'Data Length', minval=1, group=grp_main,
     tooltip='Period used for both the triangular MA and the adaptive signal line. Higher values produce smoother output at the cost of lag. Typical range: 7–21.')
bullColor   = input.color(#089981, 'Bullish Color', group=grp_colors,
     tooltip='Color of histogram bars when momentum is above zero.')
bearColor   = input.color(#F23645, 'Bearish Color', group=grp_colors,
     tooltip='Color of histogram bars when momentum is below zero.')

//---------------------------------------------------------------------------------------------------------------------}
// CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------{

// Double-SMA (triangular) smoothing concentrates weight on the middle of the lookback window,
// making the baseline far less reactive to individual wick spikes than a plain SMA or EMA.
triangularMA = ta.sma(ta.sma(close, lengthInput), lengthInput)

// Momentum = net shift of the smooth baseline over the period.
// Because the baseline is already heavily filtered, this value only moves when
// a real directional change has sustained itself, not just a single-bar outlier.
momentum     = ta.change(triangularMA, lengthInput)

// Kaufman Adaptive Moving Average applied to momentum values.
// The Efficiency Ratio measures how directional momentum itself is:
//   high ER → fast smoothing constant → signal line tracks closely
//   low ER  → slow smoothing constant → signal line barely moves (ignores chop)
// Squaring the smoothing constant amplifies this contrast nonlinearly.
// [Source: Perry Kaufman, "Smarter Trading", 1995]
getAMA(float data, int length) =>
    var float amaValue  = na
    float absChange     = math.abs(data - data[1])
    float sumAbsChange  = math.sum(absChange, length)
    float er            = sumAbsChange != 0 ? math.abs(data) / sumAbsChange : 0
    float fastSC        = 2.0 / (2.0 + 1.0)
    float slowSC        = 2.0 / (30.0 + 1.0)
    float ssc           = er * (fastSC - slowSC) + slowSC
    // Squaring compresses near-zero values toward zero and pushes high values toward 1,
    // making ranging states very slow and trending states much faster.
    float smoothSC      = ssc * ssc
    amaValue := na(amaValue) ? data : amaValue + smoothSC * (data - amaValue)
    amaValue

signalLine = getAMA(momentum, lengthInput)

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{

// Counter-trend filter: only flag reversals from the opposite side of zero.
// A bullish cross that happens while momentum is already positive is trend continuation — not a reversal setup.
buySignal  = ta.crossover(momentum, signalLine) and momentum < 0
sellSignal = ta.crossunder(momentum, signalLine) and momentum > 0

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{

oscColor = momentum > 0 ? bullColor : bearColor

plot(momentum, 'Lumina Momentum', color=oscColor, style=plot.style_histogram, linewidth=3)
// plot(signalLine, 'Adaptive Signal Line', color=color.white, linewidth=2)

hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// plotshape(buySignal, title="Buy Signal", style=shape.labelup, location=location.bottom, color=bullColor, text="BUY", textcolor=color.white, size=size.tiny)
// plotshape(sellSignal, title="Sell Signal", style=shape.labeldown, location=location.top, color=bearColor, text="SELL", textcolor=color.white, size=size.tiny)

// alertcondition(buySignal, title="LAMO Buy Signal", message="Lumina AMO - BUY Signal: Momentum accelerating upward from oversold territory")
// alertcondition(sellSignal, title="LAMO Sell Signal", message="Lumina AMO - SELL Signal: Momentum accelerating downward from overbought territory")
````
