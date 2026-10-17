# Volatility Gated Supertrend [BackQuant]

- url: https://www.tradingview.com/script/UsLuKZH9-Volatility-Gated-Supertrend-BackQuant/
- type: indicator
- pine_id: PUB;19984abceff64b6e9cdf9f907f482de4
- version: 1.0

## Description

[b]Volatility Gated Supertrend [BackQuant][/b]

[b]Overview[/b]  
Volatility Gated Supertrend is a regime-aware trend-following indicator built around a modified Supertrend engine with an integrated [b]volatility filter[/b]. Unlike a traditional Supertrend, which flips direction whenever price crosses its trailing bands, this version introduces a gating mechanism that can [b]block trend reversals during low-volatility conditions[/b].

The purpose of the indicator is simple:
[list]
[*]Keep the responsiveness and structure of a Supertrend.
[*]Reduce false flips during sideways or compressed conditions.
[*]Allow trend transitions primarily when volatility is expanding enough to justify participation.
[/list]

The result is a smoother and more selective trend engine designed to suppress whipsaws while still reacting to meaningful directional movement.

The full source structure for the indicator can be referenced here: :contentReference[oaicite:0]{index=0}

[b]Core idea[/b]  
Traditional Supertrend indicators work well during directional markets but struggle in compressed environments:
[list]
[*]Price repeatedly crosses the trailing bands.
[*]Trend direction flips too frequently.
[*]False reversals appear during chop.
[/list]

This indicator attempts to solve that problem by asking:
[list]
[*]“Is there enough volatility expansion to justify accepting a new trend?”[/list]

Instead of blindly allowing every flip, the indicator measures:
[list]
[*]Current volatility,
[*]Baseline volatility,
[*]Relative expansion or compression.
[/list]

Only when volatility conditions are sufficient does the trend engine allow a directional transition.

[b]What the Supertrend is[/b]  
The Supertrend is a volatility-based trailing trend indicator built from:
[list]
[*]ATR (Average True Range)
[*]A central price source
[*]A directional trailing stop structure
[/list]

The classic logic:
[list]
[*]Upper band = price source + ATR × multiplier
[*]Lower band = price source − ATR × multiplier
[/list]

These bands trail price dynamically:
[list]
[*]In bullish conditions, the lower band ratchets upward.
[*]In bearish conditions, the upper band ratchets downward.
[/list]

When price crosses one of the bands:
[list]
[*]The trend flips direction.
[/list]

This creates a clean directional regime model.

[b]How this version differs[/b]  
The major difference is the [b]volatility gate[/b].

A normal Supertrend asks:
[list]
[*]“Did price cross the band?”
[/list]

This indicator asks:
[list]
[*]“Did price cross the band, and is volatility strong enough to trust the move?”
[/list]

That additional filter dramatically changes behavior in sideways conditions.

[b]ATR and volatility structure[/b]  
The indicator uses two ATR measurements:
[list]
[*][b]Fast ATR[/b] → current short-term volatility
[*][b]Slow ATR[/b] → baseline long-term volatility
[/list]

The core ratio:
[list]
[*]Volatility Ratio = Fast ATR / Slow ATR
[/list]

Interpretation:
[list]
[*]Ratio above threshold → volatility expansion
[*]Ratio below threshold → volatility compression
[/list]

This becomes the gate logic.

[b]Volatility Gate Logic[/b]  
The gate opens only when:
[list]
[*]Fast ATR / Slow ATR ≥ Gate Threshold
[/list]

If volatility is too compressed:
[list]
[*]The gate closes.
[*]Trend flips are blocked.
[/list]

Importantly:
[list]
[*]The Supertrend bands still calculate normally.
[*]Price can still cross them.
[*]But the directional state will not update while the gate is closed.
[/list]

This distinction matters because it means:
[list]
[*]The market may technically trigger a reversal,
[*]But the indicator intentionally ignores it if volatility conditions are weak.
[/list]

[b]Why this helps[/b]  
Most trend-following systems fail in chop because:
[list]
[*]Small meaningless moves trigger directional flips.
[*]There is insufficient range expansion.
[*]The market lacks trend persistence.
[/list]

By requiring volatility confirmation:
[list]
[*]Weak reversals are filtered out.
[*]Trend state becomes more stable.
[*]Noise is reduced.
[/list]

This makes the indicator particularly useful during:
[list]
[*]Low-volatility consolidations,
[*]Mean-reverting conditions,
[*]Slow drifting ranges.
[/list]

[b]Band construction[/b]  
The indicator uses:
[list]
[*]hl2 as the central source,
[*]ATR for dynamic width,
[*]A configurable multiplier for sensitivity.
[/list]

Formulas:
[list]
[*]Upper Band = hl2 + ATR × multiplier
[*]Lower Band = hl2 − ATR × multiplier
[/list]

The trailing logic prevents the bands from moving backward unnecessarily:
[list]
[*]Bullish lower band only rises.
[*]Bearish upper band only falls.
[/list]

This creates the staircase-style trailing structure common in Supertrend systems.

[b]Trend state[/b]  
Trend direction is binary:
[list]
[*]1 = bullish
[*]-1 = bearish
[/list]

A raw bullish flip occurs when:
[list]
[*]Close > trailing upper band
[/list]

A raw bearish flip occurs when:
[list]
[*]Close < trailing lower band
[/list]

However:
[list]
[*]The trend only updates if the volatility gate is open.
[/list]

This is the defining behavior of the script.

[b]Blocked flips[/b]  
One of the most important features is the visualization of [b]blocked signals[/b].

When:
[list]
[*]Price crosses a band,
[*]But volatility is insufficient,
[/list]

The script:
[list]
[*]Plots an X-cross marker,
[*]Keeps the existing trend state,
[*]Refuses the flip.
[/list]

This gives traders visibility into:
[list]
[*]Potential but unconfirmed reversals,
[*]Areas of weak participation,
[*]Fake breakouts or low-energy transitions.
[/list]

[b]Visual behavior[/b]

[b]Trend band[/b]  
The active trailing band changes color based on trend direction:
[list]
[*]Bullish → bullish color
[*]Bearish → bearish color
[*]Gate closed → gated color (dimmed)
[/list]

[b]Trend fill[/b]  
The script fills the space between price and the active band:
[list]
[*]Bullish fill during bullish regimes
[*]Bearish fill during bearish regimes
[/list]

This creates a cleaner directional overlay.

[b]Outer glow[/b]  
An additional glow layer expands slightly beyond the trend band:
[list]
[*]Adds directional emphasis,
[*]Improves trend readability,
[*]Visually reinforces active regime.
[/list]

When the gate closes:
[list]
[*]The band and candles dim.
[/list]

This visually communicates:
[list]
[*]“The trend engine is currently suppressing flips.”
[/list]

[b]Candle coloring[/b]  
Candles can optionally inherit the trend state:
[list]
[*]Bullish regime → bullish candles
[*]Bearish regime → bearish candles
[*]Gate closed → dimmed neutral appearance
[/list]

This allows the indicator to function as a full-chart regime overlay.

[b]Signal logic[/b]

[b]Bullish signal[/b]  
Occurs when:
[list]
[*]Trend flips from bearish to bullish,
[*]AND the gate is open.
[/list]

[b]Bearish signal[/b]  
Occurs when:
[list]
[*]Trend flips from bullish to bearish,
[*]AND the gate is open.
[/list]

[b]Blocked signal[/b]  
Occurs when:
[list]
[*]A raw flip condition appears,
[*]BUT volatility ratio is below threshold.
[/list]

This distinction is important:
[list]
[*]A blocked signal is not ignored information.
[*]It is a rejected transition.
[/list]

[b]How to interpret the gate[/b]

[b]Gate open[/b]
[list]
[*]Volatility is active.
[*]Market expansion is sufficient.
[*]Trend flips are allowed.
[/list]

[b]Gate closed[/b]
[list]
[*]Market is compressed.
[*]Conditions are likely choppy.
[*]Trend reversals are suppressed.
[/list]

This effectively turns the indicator into a:
[list]
[*]Trend-following system during expansion,
[*]Trend-holding system during compression.
[/list]

[b]Why ATR ratio works well[/b]  
ATR ratio is a powerful regime detector because it measures:
[list]
[*]Current volatility relative to normal volatility.
[/list]

Not just:
[list]
[*]“Is volatility high?”
[/list]

But:
[list]
[*]“Is volatility high relative to its recent baseline?”
[/list]

This adaptive behavior allows the gate to work across:
[list]
[*]Different assets,
[*]Different timeframes,
[*]Different volatility environments.
[/list]

[b]Input guide[/b]

[b]ATR Multiplier[/b]  
Controls band width:
[list]
[*]Higher = wider bands, fewer flips
[*]Lower = tighter bands, more sensitivity
[/list]

[b]ATR Length[/b]  
Controls volatility calculation for the Supertrend itself.

[b]Fast ATR[/b]  
Short-term volatility measure.

[b]Slow ATR[/b]  
Long-term baseline volatility measure.

[b]Gate Threshold[/b]  
Controls how strict the gate is:
[list]
[*]Lower threshold = more permissive
[*]Higher threshold = more restrictive
[/list]

Example:
[list]
[*]0.6 → allows more flips
[*]1.0 → requires current volatility to match baseline
[*]1.2 → requires expansion regime
[/list]

[b]Strengths[/b]
[list]
[*]Reduces Supertrend whipsaws in chop.
[*]Adds regime awareness.
[*]Uses adaptive volatility filtering.
[*]Clean trend visualization.
[*]Blocked-signal logic provides extra context.
[/list]

[b]Limitations[/b]
[list]
[*]Can delay reversals during early expansion.
[*]Very high thresholds may suppress legitimate transitions.
[*]Still fundamentally a trend-following system.
[*]Not designed for low-volatility mean reversion trading.
[/list]

[b]Best use case[/b]  
Volatility Gated Supertrend works best as:
[list]
[*]A directional regime filter,
[*]A swing trend overlay,
[*]A volatility-aware trend confirmation tool,
[*]A way to suppress noise during consolidations.
[/list]

It is particularly useful for traders who:
[list]
[*]Like Supertrend logic,
[*]But dislike how often it flips in sideways markets.
[/list]

[b]Summary[/b]  
Volatility Gated Supertrend extends the classic Supertrend framework by introducing a volatility-aware gating engine that blocks trend reversals during compressed market conditions. By comparing fast ATR against slow ATR, the script determines whether enough volatility expansion exists to justify a directional transition. The result is a cleaner, more stable trend system that retains the strengths of Supertrend logic while dramatically reducing whipsaws during low-energy market regimes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant


//@version=6
indicator("Volatility Gated Supertrend [BackQuant]", "Vol-Gated ST [BackQuant]", overlay = true)

// Inputs 
const string g1 = "Supertrend"
const string g2 = "Volatility Gate"
const string g3 = "UI Settings"

float mult    = input.float(3.0, "ATR Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = g1,tooltip = "Standard supertrend multiplier. Higher = wider bands, fewer flips.")
int   atrLen  = input.int(14, "ATR Length", minval = 1, maxval = 100, group = g1,tooltip = "ATR lookback for band width.")

bool  useGate = input.bool(true, "Volatility Gate", group = g2,tooltip = "When enabled, trend flips are blocked during low-volatility regimes. Kills whipsaws in chop.")
int   fastATR_= input.int(7, "Fast ATR", minval = 1, maxval = 50, group = g2,tooltip = "Short ATR used to measure current volatility.")
int   slowATR_= input.int(50, "Slow ATR", minval = 20, maxval = 200, group = g2,tooltip = "Long ATR used as the baseline for normal volatility.")
float gateMin = input.float(0.75, "Gate Threshold", minval = 0.1, maxval = 2.0, step = 0.05, group = g2,tooltip = "When fast ATR / slow ATR drops below this, the gate closes and flips are blocked. Lower = more permissive.")

bool  showSig  = input.bool(true, "Show Signals", group = g3)
bool  showFill = input.bool(true, "Trend Fill", group = g3)
bool  showGate = input.bool(true, "Show Gate Status", group = g3,tooltip = "Dims the band and candles when the volatility gate is blocking flips.")
bool  paintBar = input.bool(true, "Color Candles", group = g3)
color bullCol  = input.color(#00ff00, "Bullish", inline = "c", group = g3)
color bearCol  = input.color(#ff0000, "Bearish", inline = "c", group = g3)
color gateCol  = input.color(#555555, "Gated", inline = "c", group = g3)

// Supertrend 
float atr = ta.atr(atrLen)
float src = hl2
float rawUpper = src + atr * mult
float rawLower = src - atr * mult

var float trailUpper = na
var float trailLower = na

trailLower := not na(trailLower[1]) and close[1] > trailLower[1] ? math.max(rawLower, trailLower[1]) : rawLower
trailUpper := not na(trailUpper[1]) and close[1] < trailUpper[1] ? math.min(rawUpper, trailUpper[1]) : rawUpper

// Volatility Gate 
float fastATR  = ta.atr(fastATR_)
float slowATR  = ta.atr(slowATR_)
float volRatio = slowATR > 0 ? fastATR / slowATR : 1.0
bool  gateOpen = not useGate or volRatio >= gateMin

// Trend Logic 
var int trend = 0

bool rawBullFlip = close > trailUpper and trend != 1
bool rawBearFlip = close < trailLower and trend != -1

if rawBullFlip and gateOpen
    trend := 1
if rawBearFlip and gateOpen
    trend := -1

float trendBand = trend == 1 ? trailLower : trend == -1 ? trailUpper : na

bool trendFlip = trend != trend[1] and trend[1] != 0
bool bullFlip  = trend == 1 and trend[1] == -1
bool bearFlip  = trend == -1 and trend[1] == 1
bool blocked   = (rawBullFlip or rawBearFlip) and not gateOpen

// Plot  
color trendCol = not gateOpen and showGate ? gateCol : trend == 1 ? bullCol : trend == -1 ? bearCol : color.gray
int bandAlpha  = not gateOpen and showGate ? 50 : 20

pBand  = plot(not trendFlip ? trendBand : na, "Supertrend", color.new(trendCol, bandAlpha), 2, plot.style_linebr)
pPrice = plot(hl2, display = display.none, editable = false)
fill(pBand, pPrice, hl2, trendBand, color(na), color.new(trendCol, showFill ? 82 : 100))

// Outer glow
float glowUp = not trendFlip and trend == 1 ? trendBand - atr * 0.15 : na
float glowDn = not trendFlip and trend == -1 ? trendBand + atr * 0.15 : na
pGlowUp  = plot(glowUp, display = display.none, editable = false)
pGlowDn  = plot(glowDn, display = display.none, editable = false)
pBandUp  = plot(trend == 1 and not trendFlip ? trendBand : na, display = display.none, editable = false)
pBandDn  = plot(trend == -1 and not trendFlip ? trendBand : na, display = display.none, editable = false)
fill(pBandUp, pGlowUp, color = color.new(trendCol, 88))
fill(pBandDn, pGlowDn, color = color.new(trendCol, 88))

// Candles
barcolor(paintBar ? color.new(trendCol, 30) : na)

// Signals
plotshape(showSig and bullFlip ? trendBand : na, "Bull Flip",shape.labelup, location.absolute, bullCol,text = "▲", textcolor = chart.bg_color, size = size.small)
plotshape(showSig and bearFlip ? trendBand : na, "Bear Flip",shape.labeldown, location.absolute, bearCol,text = "▼", textcolor = chart.bg_color, size = size.small)

// Blocked flips
plotshape(showSig and showGate and blocked ? (rawBullFlip ? trailUpper : trailLower) : na, "Blocked",shape.xcross, location.absolute, gateCol, size = size.tiny)

// Alerts 
alertcondition(bullFlip, "Vol-Gated ST Bullish", "Vol-Gated ST bullish on {{ticker}}")
alertcondition(bearFlip, "Vol-Gated ST Bearish", "Vol-Gated ST bearish on {{ticker}}")
alertcondition(blocked, "Signal Blocked", "Flip blocked by volatility gate on {{ticker}}")
````
