# Apex Volatility Flow [Pineify]

- url: https://www.tradingview.com/script/t3nZMLCT-Apex-Volatility-Flow-Pineify/
- type: indicator
- pine_id: PUB;9686303407dc4ff68d43b5906ac07e07
- version: 1.0

## Description

[b]Apex Volatility Flow ATR Chandelier Oscillator[/b]

Apex Volatility Flow converts ATR-based Chandelier behavior into a normalized 0-100 oscillator. It tracks flow above or below 50, and marks ATR contraction when volatility falls below a longer baseline.

[b]Key Features[/b]

[list]
[*]Chandelier-style direction logic using extremes and ATR distance.

[*]Bullish/bearish oscillator coloring around the 50-line bias filter.

[*]Squeeze dots and alerts for compression and flow crosses.
[/list]

[b]How It Works[/b]

The script begins with [i]Average True Range[/i]. A long reference uses recent highs minus ATR times the multiplier, while a short reference uses recent lows plus ATR times the multiplier. The anchors blend close-based and wick extremes to reduce one-bar distortion.

[list=1]
[*]A close above the short reference is bullish; a close below the long reference is bearish.

[*]The active level is tracked, then its range resets when direction changes.

[*]The active level is normalized, smoothed with an SMA, and compared with 50.

[*]A squeeze appears when ATR is below 80% of a longer ATR baseline.
[/list]

[b]How the Components Work Together[/b]

The Chandelier logic supplies trend context, while the oscillator scale helps compare charts. Squeeze dots stay separate because compression can break either way; read them with flow crosses, 50-line retests, and price structure.

[b]Trading Ideas and Insights[/b]

[list]
[*]Bullish continuation may be worth studying when flow holds above 50 and compression releases.

[*]Bearish crosses below 50 can whipsaw in strong uptrends; follow-through matters.

[*]During extended squeezes, confirm direction with structure, volume, or higher-timeframe trend.
[/list]

[b]Unique Aspects[/b]

[list]
[*]It turns Chandelier-style stops into a compact oscillator instead of a price overlay.

[*]Normalization resets on direction changes, avoiding stale values from the prior move.
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator to a liquid market and timeframe.

[*]Use 50 as the main bullish/bearish flow reference.

[*]Treat squeeze dots as compression context, not standalone entries.

[*]Use the built-in alert conditions for crosses or squeeze events.
[/list]

[b]Customization[/b]

[list]
[*][b]Volatility Length[/b] (default: 22) - Controls ATR and anchors. Higher values smooth but react later.

[*][b]ATR Multiplier[/b] (default: 3.0) - Sets stop distance. Higher values reduce flips but delay regime changes.

[*][b]Oscillator Smoothing[/b] (default: 4) - Smooths the output. Higher values reduce noise but add lag.

[*][b]Colors[/b] - Adjust bullish, bearish, and squeeze marker colors.
[/list]

[b]Conclusion[/b]

Apex Volatility Flow is for traders who want ATR and Chandelier-style context in one oscillator pane. It can help organize flow bias and compression, but should be combined with structure and risk management. It uses no higher-timeframe security calls; live-bar values may still change before close.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify
//
// Apex Volatility Flow [Pineify]
// ------------------------------
// This oscillator converts ATR-based Chandelier stop behavior into a normalized 0-100 volatility-flow reading.
// It is designed to show whether directional pressure is expanding above or below equilibrium while also marking
// compression periods where current ATR contracts below its longer-term baseline.
//
// Market states and key concepts:
//   1. Bullish flow - the normalized Chandelier level holds above the 50 equilibrium line.
//   2. Bearish flow - the normalized Chandelier level holds below the 50 equilibrium line.
//   3. Squeeze compression - short-term ATR falls below the longer-term ATR threshold, suggesting reduced volatility.

//@version=6
indicator("Apex Volatility Flow [Pineify]", "Apex Volatility Flow", format=format.price, max_lines_count=500, overlay=false)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
grpVolatility = "Volatility Settings"
grpVisuals    = "Aesthetics"

length = input.int(22, "Volatility Length", minval=1, group=grpVolatility, tooltip="Lookback used for ATR, highest/lowest range tracking, and the Chandelier-style stop levels. Higher values smooth the oscillator and reduce sensitivity.")
mult   = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=grpVolatility, tooltip="Scales the ATR offset used in the Chandelier-style stop calculation. Higher values require larger moves before trend direction changes.")
smooth = input.int(4, "Oscillator Smoothing", minval=1, group=grpVolatility, tooltip="SMA smoothing applied after normalization. Higher values reduce noise but add lag to equilibrium crosses.")

bullColor    = input.color(#089981, "Bullish Flow", group=grpVisuals, tooltip="Color used when the volatility-flow oscillator is above the 50 equilibrium line.")
bearColor    = input.color(#f23645, "Bearish Flow", group=grpVisuals, tooltip="Color used when the volatility-flow oscillator is below the 50 equilibrium line.")
squeezeColor = input.color(#ffeb3b, "Squeeze Zone (Compression)", group=grpVisuals, tooltip="Color used for compression markers when short-term ATR is meaningfully below the longer-term ATR baseline.")

//---------------------------------------------------------------------------------------------------------------------}
// CORE LOGIC
//---------------------------------------------------------------------------------------------------------------------{
// ATR supplies the adaptive distance for the Chandelier-style levels, so the stop envelope expands in volatile
// markets and tightens when price action contracts.
atr = ta.atr(length)

// Averaging close-based extremes with raw high/low extremes creates a slightly less jumpy anchor than using only
// wick extremes, while still respecting the outer range of recent price action.
highestHigh = math.avg(ta.highest(close, length), ta.highest(length))
lowestLow   = math.avg(ta.lowest(close, length), ta.lowest(length))

// The long and short reference levels follow the Chandelier Exit concept: recent extremes shifted by an ATR
// multiple. Direction only flips when price clears the opposite reference, which helps avoid single-bar noise.
chandLong  = highestHigh - atr * mult
chandShort = lowestLow + atr * mult

var int dir = 1
dir := close > chandShort ? 1 : close < chandLong ? -1 : dir

// The oscillator needs a local normalization window that resets on regime changes. Tracking the active Chandelier
// extremes keeps the 0-100 scale tied to the current directional leg rather than to a fixed historical range.
var float maxChand = na
var float minChand = na

maxChand := dir > 0 ? math.max(chandLong, nz(maxChand, chandLong)) : maxChand
minChand := dir < 0 ? math.min(chandShort, nz(minChand, chandShort)) : minChand

// A fresh direction should start with a fresh normalization range; otherwise the prior leg can compress new
// readings and delay equilibrium crosses.
maxChand := ta.change(dir) != 0 ? chandLong : maxChand
minChand := ta.change(dir) != 0 ? chandShort : minChand

// Normalization maps the active stop level into oscillator space. In bullish legs, stronger flow pushes toward
// 100; in bearish legs, stronger downside flow pushes toward 0.
float chandValue = dir > 0 ? chandLong : chandShort
float chandRange = dir > 0 ? maxChand - minChand : maxChand - minChand

float rawOsc = dir > 0 
 ? (chandValue - minChand) / math.max(chandRange, 0.0001) * 100 
 : (maxChand - chandValue) / math.max(chandRange, 0.0001) * 100

// Light smoothing reduces flip-flopping around the 50 line while preserving enough responsiveness for alerts.
flowOsc = ta.sma(rawOsc, smooth)

// Compression is defined as current ATR dropping below 80% of a three-times-longer ATR baseline. This is a simple
// volatility contraction filter, not a directional signal by itself.
longAtr = ta.atr(length * 3)
isSqueezing = atr < longAtr * 0.8

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
midLine = hline(50, "Equilibrium", color=color.new(#787b86, 50), linestyle=hline.style_dashed, linewidth=1)

// The 50 line is the regime boundary: bullish color above equilibrium, bearish color below it.
flowLineColor = flowOsc > 50 ? bullColor : bearColor
plot(flowOsc, "Volatility Flow", color=flowLineColor, linewidth=2)

// Hidden area series preserve separated bull/bear flow values for alert workflows without cluttering the
// oscillator pane.
plot(flowOsc > 50 ? flowOsc : na, "Bull Flow Area", color=color.new(bullColor, 60), style=plot.style_area, editable=false, display=display.none)
plot(flowOsc < 50 ? flowOsc : na, "Bear Flow Area", color=color.new(bearColor, 60), style=plot.style_area, editable=false, display=display.none)

plotchar(isSqueezing, title="Squeeze Dots", char="•", color=squeezeColor, size=size.normal, location=location.abovebar)

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
// Equilibrium crosses flag a change in the dominant normalized flow bias. Compression alerts are intentionally
// separate because low volatility can resolve in either direction.
alertcondition(flowOsc > 50 and flowOsc[1] <= 50, title="Bullish Flow Cross", message="Volatility Flow crossed above 50 - Bullish momentum")
alertcondition(flowOsc < 50 and flowOsc[1] >= 50, title="Bearish Flow Cross", message="Volatility Flow crossed below 50 - Bearish momentum")
alertcondition(isSqueezing, title="Squeeze Alert", message="Volatility squeeze detected - Prepare for breakout")
````
