# Smart StochRSI Divergence Oscillator with GAPS & HEAT [Zofesu]

- url: https://www.tradingview.com/script/GUl7CjXK-Smart-StochRSI-Divergence-Oscillator-with-GAPS-HEAT-Zofesu/
- type: indicator
- pine_id: PUB;75cac4013d8a448290d5683d7f663761
- version: 1.0

## Description

[b]Smart StochRSI Divergence Oscillator with GAPS & HEAT [Zofesu][/b] is a momentum oscillator built on Stochastic RSI extended with three original signal layers not present in standard StochRSI implementations: a classical divergence engine with institutional volume confirmation, a gap return detection system, and a Heat signal that identifies parabolic price extensions from oscillator extremes.

Each layer operates independently and addresses a different market condition — divergence captures momentum exhaustion at extremes, gap return tracks liquidity rebalancing, and Heat identifies the continuation phase of parabolic moves. Seven alert conditions cover all signal types individually and as a combined trigger.

─────────────────────────────────────
[b]01 — What is WatchDog?[/b]
─────────────────────────────────────
WatchDog monitors the Stochastic RSI oscillator across three behavioral states and generates signals only when precise conditions align — oscillator position, K/D crossover direction, price confirmation, and volume participation.

The base oscillator uses a long lookback period (default 700 bars for both RSI and Stochastic) to produce a stable, low-noise read of momentum across the full market cycle. This is intentional — short lookbacks produce too many false extremes. At 700 bars the oscillator reaches its upper and lower extremes only during genuine momentum events.

─────────────────────────────────────
[b]02 — Classical Divergence Signals[/b]
─────────────────────────────────────
The classical signal engine uses a state machine with three phases:

[b]Phase 1 — Extreme entry[/b]
K rises above the upper extreme (default 98) → mode set to BEAR watch. Price at that moment is stored as the reference level.
K falls below the lower extreme (default 2) → mode set to BULL watch. Price stored.

[b]Phase 2 — Return through midpoint[/b]
K must cross back through the midpoint (default 50) before a signal can fire. This prevents premature signals while the oscillator is still deep in the extreme zone.

[b]Phase 3 — Signal confirmation[/b]
[b]Bear signal:[/b] K crosses under D while between upper extreme and midpoint, AND current price is higher than the stored reference price (price divergence) AND volume is above the selected percentile.
[b]Bull signal:[/b] K crosses over D while between lower extreme and midpoint, AND current price is lower than the stored reference price AND volume is above the selected percentile.

This three-phase structure ensures classical signals represent genuine momentum divergence — price making a higher high while K crosses down from an extreme is the textbook definition of bearish hidden divergence with volume confirmation.

─────────────────────────────────────
[b]03 — Institutional Volume Filter[/b]
─────────────────────────────────────
Classical signals require volume to exceed a minimum percentile rank (default 25th percentile over 500 bars). This means current volume must be in the top 75% of recent volume — filtering out low-conviction crossovers that occur on thin trading days.

When the filter is disabled, all K/D crossovers meeting the price and oscillator conditions will signal regardless of volume.

─────────────────────────────────────
[b]04 — Gap Return Signals[/b]
─────────────────────────────────────
[b]Price gaps represent unfilled liquidity[/b] — areas where no trading occurred and orders were left unmatched. Institutional algorithms often return to fill these gaps before continuing the move.

WatchDog detects gaps by comparing the current candle's range to the 14-bar average range. A gap is registered when the distance between the previous candle's high and current candle's low (bull gap) or previous candle's low and current candle's high (bear gap) exceeds the average range by the configured minimum deviation percentage (default 30%).

Once a gap is registered, the indicator monitors for price returning to the gap boundary:
[b]Bull Gap Return (green square)[/b] — price returned to fill a bullish gap below. Potential support reaction zone.
[b]Bear Gap Return (red square)[/b] — price returned to fill a bearish gap above. Potential resistance reaction zone.

The gap level is cleared after being filled — each gap is tracked once.

─────────────────────────────────────
[b]05 — Heat Signals[/b]
─────────────────────────────────────
In equities and high-momentum assets, significant percentage moves from a prior extreme often attract additional momentum capital — amplifying the move further before exhaustion sets in. Strong price action tends to generate more strong price action in the short term as trend-followers and algorithms pile in.

The Heat signal is designed to detect this pattern. While K is at or above the upper extreme, the indicator tracks the price level at each new extreme touch. If price subsequently moves more than the configured percentage (default 15%) above that reference level while K remains in the extreme zone, a Heat Bearish signal fires — marking a potential parabolic overheating condition.

Heat Bullish fires symmetrically when K is at the lower extreme and price drops more than 15% below the reference level.

[b]Heat Bearish (purple label down)[/b] — price has moved significantly higher while oscillator stays overbought. Parabolic extension, potential exhaustion ahead.
[b]Heat Bullish (purple label up)[/b] — price has dropped significantly while oscillator stays oversold. Panic extension, potential exhaustion ahead.

Purple background highlights Heat signal bars for immediate visibility.

─────────────────────────────────────
[b]06 — Settings[/b]
─────────────────────────────────────
[b]Calculation[/b]
[b]Stochastic Length[/b] — lookback for StochRSI. Default: 700.
[b]RSI Length[/b] — lookback for base RSI. Default: 700.
[b]K Smoothing[/b] — SMA period for K line. Default: 5.
[b]D Smoothing[/b] — SMA period for D line. Default: 3.

[b]Volume Settings[/b]
[b]Use Institutional Volume Filter[/b] — enable/disable volume gate for classical signals.
[b]Target Volume Percentile[/b] — minimum volume rank required. Default: 25.
[b]Volume Lookback Period[/b] — bars for percentile calculation. Default: 500.

[b]Gap Settings[/b]
[b]Gap Minimal Deviation %[/b] — minimum gap size as % of 14-bar average range. Default: 30%.

[b]Heat Signal Settings[/b]
[b]Heat Signal Distance %[/b] — minimum % move from last extreme to trigger Heat. Default: 15%.
[b]Show Heat Breakout Signals[/b] — enable/disable Heat signals.

[b]Levels[/b]
[b]Upper Extreme Level[/b] — overbought threshold. Default: 98.
[b]Mid Level[/b] — midpoint reference. Default: 50.
[b]Lower Extreme Level[/b] — oversold threshold. Default: 2.

─────────────────────────────────────
[b]07 — How To Use[/b]
─────────────────────────────────────
[b]Step 1 — Watch for K to reach an extreme[/b]
[b]Upper extreme (98)[/b] = overbought state entered. [b]Lower extreme (2)[/b] = oversold state entered. The oscillator must reach these levels for any classical or Heat signal to become possible.

[b]Step 2 — Wait for the classical signal[/b]
[b]Red label[/b] = bearish divergence confirmed with volume. K crossed under D returning from overbought, price made a higher high. Enter short on next bar, SL above recent swing high.
[b]Green label[/b] = bullish divergence confirmed with volume. K crossed over D returning from oversold, price made a lower low. Enter long on next bar, SL below recent swing low.

[b]Step 3 — Monitor Heat signals[/b]
[b]Purple label[/b] = parabolic extension detected. On equities this can mark either a continuation entry for momentum traders or an exhaustion warning for counter-trend traders. Context matters — use with higher timeframe bias.

[b]Step 4 — Use Gap Return squares as context[/b]
[b]Green square[/b] = liquidity below was rebalanced. Watch for support reaction.
[b]Red square[/b] = liquidity above was rebalanced. Watch for resistance reaction.

[b]Step 5 — Alerts[/b]
Seven alert conditions are pre-configured:
[b]Bearish Divergence / Bullish Divergence
Extreme HEAT Bearish / Extreme HEAT Bullish
Gap Fill Bullish / Gap Fill Bearish[/b]
Any Zofesu Signal — combined trigger for all events

Works on all asset classes: Indices, Forex, Gold, Oil, Crypto, Stocks.
Best timeframes: H4, D1, W1

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu

//@version=6
indicator("Smart StochRSI Divergence Oscillator with GAPS & HEAT [Zofesu]", shorttitle = "[Zofesu] WatchDog",  overlay=false, precision=2)

// --- Inputs for calculation ---
stochLen = input.int(700, "Stochastic Length", group="Calculation", tooltip="Lookback period for the Stochastic RSI calculation. Higher = smoother, less reactive. Default 700.")
rsiLen   = input.int(700, "RSI Length", group="Calculation", tooltip="Lookback period for the RSI used inside the Stochastic. Higher = smoother baseline. Default 700.")
smoothK  = input.int(5, "K Smoothing", group="Calculation", tooltip="SMA smoothing period applied to the raw Stochastic RSI to produce the K line. Default 5.")
smoothD  = input.int(3, "D Smoothing", group="Calculation", tooltip="SMA smoothing period applied to K to produce the signal D line. Default 3.")

// --- Volume Filter Inputs ---
useVolFilter = input.bool(true, "Use Institutional Volume Filter", group="Volume Settings", tooltip="When enabled, classic divergence signals require volume to be above the selected percentile threshold. Filters out low-conviction signals.")
volPercentile = input.int(25, "Target Volume Percentile", group="Volume Settings", tooltip="Minimum volume percentile rank required for a classic signal to fire. 25 = volume must be in the top 75% of the lookback period. Default 25.")
volLookback = input.int(500, "Volume Lookback Period", group="Volume Settings", tooltip="Number of bars used to calculate the volume percentile rank. Default 500.")

// --- Gap Deviation Inputs ---
gapMinDev = input.float(30.0, "Gap Minimal Deviation %", minval=0.0, group="Gap Settings", tooltip="Minimum gap size required to register a price gap, expressed as a percentage of the 14-bar average range. Higher = only significant gaps detected. Default 30%.")

// --- Heat Signal Inputs ---
heatPerc = input.float(15.0, "Heat Signal Distance %", minval=1.0, group="Heat Signal Settings", tooltip="Minimum price move from the last extreme level required to trigger a Heat signal. Measures parabolic overheating — how far price has traveled since the last overbought or oversold touch. Default 15%.")
showHeat = input.bool(true, "Show Heat Breakout Signals", group="Heat Signal Settings", tooltip="Enable or disable Heat signals on the chart. Heat signals mark parabolic price moves away from extreme StochRSI levels.")

// --- Inputs for levels ---
upperExtreme = input.float(98.0, "Upper Extreme Level", group="Levels", tooltip="StochRSI K level above which the indicator enters overbought state. Classic bear signals and Heat bear tracking activate above this threshold. Default 98.")
midLevel     = input.float(50.0, "Mid Level", group="Levels", tooltip="Midpoint reference line. Classic signals must cross back through this level before triggering. Default 50.")
lowerExtreme = input.float(02.0, "Lower Extreme Level", group="Levels", tooltip="StochRSI K level below which the indicator enters oversold state. Classic bull signals and Heat bull tracking activate below this threshold. Default 2.")

// --- Calculations ---
rsiVal = ta.rsi(close, rsiLen)
stochRsi = ta.stoch(rsiVal, rsiVal, rsiVal, stochLen)
k = ta.sma(stochRsi, smoothK)
d = ta.sma(k, smoothD)

// --- Volume Filter Logic ---
float volRank = ta.percentrank(volume, volLookback)
bool highVolume = not useVolFilter or volRank >= volPercentile

// --- Gap Deviation Logic ---
avgRange = ta.sma(high - low, 14) 
minGapThreshold = avgRange * (gapMinDev / 100)

// --- Return to Gap Tracking Logic ---
var float bullGapLevel = na 
var float bearGapLevel = na 

if (low - high[1]) > minGapThreshold
    bullGapLevel := high[1]
if (low[1] - high) > minGapThreshold
    bearGapLevel := low[1]

bool bullGapReturn = false
bool bearGapReturn = false

if not na(bullGapLevel) and low <= bullGapLevel
    bullGapReturn := true
    bullGapLevel := na 

if not na(bearGapLevel) and high >= bearGapLevel
    bearGapReturn := true
    bearGapLevel := na 

// --- Memory for Heat Signals ---
var float lastExtremePriceBear = na
var float lastExtremePriceBull = na
bool heatBearSignal = false
bool heatBullSignal = false

if k >= upperExtreme
    if not na(lastExtremePriceBear) and showHeat
        if close >= lastExtremePriceBear * (1 + heatPerc / 100)
            heatBearSignal := true
    lastExtremePriceBear := close 

if k <= lowerExtreme
    if not na(lastExtremePriceBull) and showHeat
        if close <= lastExtremePriceBull * (1 - heatPerc / 100)
            heatBullSignal := true
    lastExtremePriceBull := close 

// --- State memory for classical signals ---
var int mode = 0 
var float lastCrossPrice = na

crossUnder = ta.crossunder(k, d)
crossOver  = ta.crossover(k, d)

if k > upperExtreme
    mode := 1
    lastCrossPrice := close 

if k < lowerExtreme
    mode := 2
    lastCrossPrice := close

// --- Logic of classical signals ---
bool bearSignal = false
bool bullSignal = false

if mode == 1 and k <= upperExtreme and k >= midLevel and crossUnder
    if not na(lastCrossPrice) and close > lastCrossPrice and highVolume
        bearSignal := true
    lastCrossPrice := close

if mode == 2 and k >= lowerExtreme and k <= midLevel and crossOver
    if not na(lastCrossPrice) and close < lastCrossPrice and highVolume
        bullSignal := true
    lastCrossPrice := close

// --- Rendering ---
plot(k, "K", color.new(#2962FF, 0), 2)
plot(d, "D", color.new(#FF6D00, 0), 1)

hline(upperExtreme, "Upper Extreme", color=color.new(#ff0000, 50), linestyle=hline.style_dashed)
hline(midLevel, "Mid Level", color=color.new(color.gray, 50), linestyle=hline.style_dotted)
hline(lowerExtreme, "Lower Extreme", color=color.new(#00ff08, 50), linestyle=hline.style_dashed)

// Gap Return
plotshape(bullGapReturn ? 2 : na, "Gap Fill Bullish", shape.square, location.absolute, color.new(#00ff08, 20), size=size.tiny)
plotshape(bearGapReturn ? 98 : na, "Gap Fill Bearish", shape.square, location.absolute, color.new(#ff0000, 20), size=size.tiny)

// Heat Signals
plotshape(heatBearSignal ? 100 : na, "Heat Bearish", shape.labeldown, location.absolute, #9C27B0, size=size.tiny)
plotshape(heatBullSignal ? 0 : na, "Heat Bullish", shape.labelup, location.absolute, #9C27B0, size=size.tiny)
bgcolor(heatBearSignal or heatBullSignal ? color.new(#9C27B0, 80) : na)

// Classic Signals
plotshape(bearSignal ? k : na, "Bearish Label", shape.labeldown, location.absolute, color.rgb(255, 0, 0), size=size.tiny)
plotshape(bullSignal ? k : na, "Bullish Label", shape.labelup, location.absolute, color.rgb(0, 255, 8), size=size.tiny)

bgcolor(bearSignal ? color.new(color.red, 85) : bullSignal ? color.new(color.green, 85) : na)

// --- ALERT CONDITION SETTINGS ---

// 1. Classic Divergence Signals
alertcondition(bearSignal, title="Bearish Divergence Label", message="BEAR Divergence on {{ticker}} - Institutional Sell Signal")
alertcondition(bullSignal, title="Bullish Divergence Label", message="BULL Divergence on {{ticker}} - Institutional Buy Signal")

// 2. Heat Breakout Signals (Parabolic Overheating)
alertcondition(heatBearSignal, title="Extreme HEAT Bearish", message="HEAT Bearish on {{ticker}} - Parabolic Overheating! Price > % from last extreme")
alertcondition(heatBullSignal, title="Extreme HEAT Bullish", message="HEAT Bullish on {{ticker}} - Parabolic Panic! Price < % from last extreme")

// 3. Gap Fill Signals (Return to Liquidity)
alertcondition(bullGapReturn, title="Gap Fill Bullish (Square)", message="BULL Gap Filled on {{ticker}} - Liquidity Rebalanced Below")
alertcondition(bearGapReturn, title="Gap Fill Bearish (Square)", message="BEAR Gap Filled on {{ticker}} - Liquidity Rebalanced Above")

// 4. Combined alert for all important events
alertcondition(bearSignal or bullSignal or heatBearSignal or heatBullSignal or bullGapReturn or bearGapReturn, title="Any Zofesu Signal", message="New Signal on {{ticker}} - Check the chart!")
````
