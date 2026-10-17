# Aura Trend Cloud Navigator [Pineify]

- url: https://www.tradingview.com/script/h8hFCBxv-Aura-Trend-Cloud-Navigator-Pineify/
- type: indicator
- pine_id: PUB;8c23adea1df04181b85b1376d2401a29
- version: 1.0

## Description

[b]Aura Trend Cloud Navigator [Pineify][/b]

This indicator builds a trend-following system around a [i]Trend Regularity Adaptive Moving Average[/i] — an adaptive MA that adjusts its responsiveness based on how frequently price makes new period highs or lows. When the market trends, the baseline tracks price closely; when it ranges, the baseline goes nearly flat, cutting down on false crossover signals. An ATR-based volatility cloud wraps around the baseline to frame the trend's expected range.

[b]Key Features[/b]

[list]
[*]Adaptive baseline that self-adjusts speed — fast in trends, nearly frozen in ranges

[*]Dynamic ATR cloud that expands and contracts with real-time volatility

[*]Gradient-filled cloud with automatic color shifts between bullish and bearish states

[*]Crossover-based buy/sell signals filtered by the adaptive regime detection

[*]Bar coloring for quick visual trend identification
[/list]

[b]How It Works[/b]

The core is a recursive adaptive moving average controlled by a [i]trend coefficient[/i] derived from market structure:

[list=1]
[*]On each bar, the script checks whether a new highest high or lowest low has been established over the lookback period (default 99 bars). If either condition is met, a binary signal of 1 is recorded; otherwise 0.

[*]The average of this binary signal over the same period is computed via SMA, then squared. Squaring creates a nonlinear response — the coefficient drops sharply when trend activity fades and rises steeply when price consistently prints new extremes.

[*]This squared value becomes the smoothing factor in a recursive formula: [i]baseline = baseline + coefficient × (close − baseline)[/i]. A high coefficient pulls the baseline toward price; a near-zero coefficient locks it in place.

[*]An [i]Average True Range[/i] envelope is then added above and below the baseline, scaled by a user-defined multiplier. This forms the cloud — a corridor representing expected price movement around the trend.
[/list]

[b]How the Components Work Together[/b]

The adaptive baseline and the ATR cloud serve complementary roles. The baseline handles trend direction and generates entry signals, but because it adapts to market regime, it sidesteps the main weakness of fixed-period moving averages: constant whipsawing during consolidation. The cloud adds a volatility dimension on top of that directional read. When price stays inside the cloud, it is oscillating within the normal range of the current trend. Price pushing beyond the cloud edges may signal overextension or trend acceleration. In short, the baseline answers "which direction" while the cloud answers "how far is normal."

[b]Trading Ideas and Insights[/b]

[list]
[*]When the baseline shifts color and a triangle signal fires, treat it as a potential trend change. Confirmation improves if the crossover happens near or beyond the opposite cloud edge, suggesting genuine momentum rather than a range poke.

[*]In a bullish regime, price hugging the upper cloud boundary suggests strong follow-through. A pullback toward the baseline that holds can offer a continuation entry — especially if the baseline remains clearly sloped upward.

[*]Watch for the baseline going flat while the cloud tightens — this is the indicator explicitly telling you to stand aside. Crossovers that occur while the baseline is flat carry less conviction than those during a clearly sloped baseline, since the adaptive mechanism has detected a low-regularity environment.
[/list]

[b]Unique Aspects[/b]

[list]
[*]The trend regularity approach counts how often new period extremes occur rather than measuring price direction or momentum directly. Most adaptive MAs rely on efficiency ratios or volatility scaling; this one responds to the structural behavior of the market itself — whether it is consistently making progress or stalling out.

[*]Squaring the trend coefficient means the MA doesn't merely slow down in ranges — it practically stops. This creates clear visual separation between trending and non-trending regimes that is immediately readable on the chart.

[*]The gradient cloud gives volatility context without the visual clutter of multi-line band systems. One glance tells you both direction and how stretched the current move is.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to your chart. The thick colored line is the adaptive baseline — green for bullish, red for bearish.

[*]Triangle markers appear at crossover points: upward green triangles below bars for potential long entries, downward red triangles above bars for potential short entries or exits.

[*]Use the cloud as context. Price within the cloud is behaving normally for the trend. Moves beyond the cloud edges are stretched and may revert or signal acceleration.

[*]On higher timeframes (4H, Daily), the default 99-period length works well as a medium-term trend filter. On lower timeframes, consider reducing the length for faster adaptation — though this increases sensitivity to noise.
[/list]

[b]Customization[/b]

[list]
[*][b]Trend Filter Length[/b] (default: 99) — How many bars are used to assess trend regularity. Higher values produce a smoother, slower baseline that only reacts to sustained directional moves. Lower values increase sensitivity but also raise whipsaw risk in choppy markets.

[*][b]Cloud Width / ATR Multiplier[/b] (default: 2.0) — Scales the ATR-based cloud. Wider values capture more price action within the corridor; tighter values make cloud-edge touches more frequent and potentially more meaningful as overextension signals.

[*][b]ATR Length[/b] (default: 14) — Period for the Average True Range calculation. The standard 14 suits most instruments. Increase it for smoother cloud behavior on volatile assets.
[/list]

[b]Conclusion[/b]

The Aura Trend Cloud Navigator provides a regime-adaptive trend filter that goes quiet when the market goes quiet. The TRAMA baseline combined with an ATR cloud delivers both directional guidance and volatility context in a single overlay. It suits swing and position traders looking for a trend filter that avoids generating noise during consolidation — though the adaptive smoothing does introduce lag at trend reversals, so pairing it with a momentum oscillator for timing may improve entries on faster-moving instruments.

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

//@version=6
indicator("Aura Trend Cloud Navigator [Pineify]", shorttitle="Aura Trend [Pineify]", overlay=true)

// --- Settings ---
length = input.int(99, "Trend Filter Length", minval=1, tooltip="Higher values filter out more noise to find the true trend.")
mult = input.float(2.0, "Cloud Width (ATR Multiplier)", minval=0.1, step=0.1, tooltip="Controls the expansion of the trend cloud.")
atrLen = input.int(14, "ATR Length", minval=1)

// --- Colors ---
bullColor = input.color(#089981, "Bullish Aura")
bearColor = input.color(#F23645, "Bearish Aura")

// --- Core Logic: Trend Regularity Adaptive Moving Average ---
// Adapts to the average number of highest highs/lowest lows made over the period to stay stationary during ranging markets.
src = close
var float ama = na
hh = math.max(math.sign(ta.change(ta.highest(length))), 0)
ll = math.max(math.sign(ta.change(ta.lowest(length)) * -1), 0)
signal = (hh > 0 or ll > 0) ? 1.0 : 0.0
tc = math.pow(ta.sma(signal, length), 2)
ama := nz(ama + tc * (src - nz(ama, src)), src)

// --- Volatility Cloud Expansion ---
// Extends an upper and lower boundary based on the Average True Range
atr = ta.atr(atrLen) * mult
upper = ama + atr
lower = ama - atr

// --- Trend Determination ---
isUp = close > ama
isDown = close < ama
trendColor = isUp ? bullColor : bearColor

// --- Plots ---
p_ama = plot(ama, "Aura Baseline", color=trendColor, linewidth=3)
p_upper = plot(upper, "Upper Cloud Edge", color=color.new(trendColor, 70))
p_lower = plot(lower, "Lower Cloud Edge", color=color.new(trendColor, 70))

// --- Beautiful Gradient Fills ---
// Creates a visually appealing dynamic cloud between upper band and AMA
fill(p_upper, p_ama, upper, ama, color.new(trendColor, 90), color.new(trendColor, 50), "Upper Cloud Gradient")

// Creates gradient fill between AMA and lower band
fill(p_lower, p_ama, ama, lower, color.new(trendColor, 50), color.new(trendColor, 90), "Lower Cloud Gradient")

// --- Easy-to-Use Trading Signals ---
buySignal = ta.crossover(close, ama)
sellSignal = ta.crossunder(close, ama)

plotshape(buySignal, "Buy Signal", shape.triangleup, location.belowbar, bullColor, size=size.small)
plotshape(sellSignal, "Sell Signal", shape.triangledown, location.abovebar, bearColor, size=size.small)

// --- Bar Coloring for extra visual clarity ---
barcolor(isUp ? bullColor : isDown ? bearColor : na)
````
