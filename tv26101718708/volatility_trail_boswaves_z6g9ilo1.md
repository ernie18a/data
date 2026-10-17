# Volatility Trail [BOSWaves]

- url: https://www.tradingview.com/script/z6g9ilo1-Volatility-Trail-BOSWaves/
- type: indicator
- pine_id: PUB;0a8af93a67ab4f928bb8221bc6963935
- version: 1.0

## Description

[b]Volatility Trail [BOSWaves] - Hull-Anchored ATR Trail with Gradient Cloud Radiation and Multi-Mode Candle Scoring[/b]

[b]Overview[/b]

Volatility Trail [BOSWaves] is a Hull-anchored trend trailing system that constructs an ATR-scaled ratcheting trail from a Hull Moving Average baseline, where trend state, gradient cloud geometry, and candle coloring intensity are driven by the relationship between price and the adaptive trail rather than by fixed thresholds or static band crossovers.

[image]https://www.tradingview.com/x/tv71SuLe/[/image]

Instead of relying on conventional moving average crossovers or symmetric bands, trend state is determined by a one-directional ratcheting trail that advances in the trend direction and locks in progress, only flipping when price closes through the trail level in the opposing direction. The trail distance from the Hull baseline scales with ATR, ensuring the ratchet respects current volatility conditions rather than applying a fixed distance regardless of market behavior.

This creates a trailing trend framework that combines a responsive Hull baseline with a volatility-calibrated ratchet mechanism, a radiating four-layer gradient cloud that visually maps the space between trail and price, and a configurable candle coloring system that scores each bar by distance from the trail, trail acceleration, or both, producing a chart where candle brightness communicates conviction intensity rather than merely indicating direction.

Price is therefore evaluated not just for its position relative to the trail but for how far it has extended from it and how fast the trail itself is advancing, providing a multi-dimensional conviction reading through the visual layers of the indicator.

[b]Conceptual Framework[/b]

Volatility Trail is founded on the principle that a trailing trend system should do three things simultaneously: define trend state through a ratcheting mechanism that locks in directional progress, communicate the spatial relationship between price and the trail through a graduated visual field, and score candle conviction based on measurable characteristics of that relationship rather than applying uniform coloring regardless of momentum state.

Traditional trailing indicators provide a line that defines trend direction but offer no framework for understanding how convincingly price is separated from that line or whether the trail itself is accelerating. This framework adds those dimensions through the gradient cloud and candle scoring systems, transforming a single trail line into a complete visual conviction map that reveals both where price is relative to the trail and the dynamic quality of the separation between them.

Three core principles guide the design:
[list=1]
[*]The trail should ratchet in the trend direction using ATR-scaled distance from a Hull baseline, locking in progress and only reversing when price demonstrates a genuine closing breach rather than a temporary excursion.
[*]The space between the trail and price should be visualized as a graduated gradient field with multiple opacity layers that radiates from the trail toward price, communicating proximity and separation depth visually rather than numerically.
[*]Candle coloring should reflect measurable conviction characteristics through configurable scoring modes, dimming bars with weak conviction and brightening bars with strong distance or acceleration readings to encode momentum quality into the candlestick display.
[/list]
This shifts trailing trend analysis from single-line direction tracking into a multi-layer conviction visualization where the trail, cloud, and candles collectively communicate trend state, spatial conviction, and momentum quality simultaneously.

[b]Theoretical Foundation[/b]

The indicator combines Hull Moving Average baseline construction, ATR-scaled ratcheting trail mechanics, four-layer gradient cloud construction using proportional gap interpolation, and a dual-mode candle scoring system based on distance normalization and trail acceleration measurement.

The Hull Moving Average provides a low-lag directional baseline that reduces the smoothing delay of standard moving averages while maintaining noise resistance. The trail ratchets by advancing the lower band as a minimum during uptrends and the upper band as a maximum during downtrends, preventing the trail from retreating against price and locking in each bar's progress. The gradient cloud divides the gap between trail and price into four proportionally spaced bands at 20, 40, 65, and 85 percent of the total gap, filling each interval with progressively increasing transparency to create a radiating visual field. Candle scoring normalizes either distance from trail or trail advancement speed against ATR, applies a power transformation to suppress weak readings, and maps the result to a gradient between a neutral dim color and the full trend color.

Four internal systems operate in tandem:
[list]
[*][i]Hull ATR Trail Engine[/i]: Calculates the Hull MA baseline and derives upper and lower ATR-scaled bands, maintaining a ratcheting trail that advances with the trend and flips to the opposing band only when price closes through the current trail level.
[*][i]Gradient Cloud System[/i]: Computes four proportional interpolation points between the smoothed trail and price, plots invisible bands at each point, and fills the intervals with opacity-graduated fills that intensify near the trail and fade toward price, producing a radiating cloud effect.
[*][i]Candle Scoring Engine[/i]: Measures distance from trail normalized by ATR and trail advancement speed normalized by ATR fraction, applies a power exponent to crush weak scores, and maps the resulting score to a gradient from a dim neutral color to the full trend color through configurable distance, acceleration, or combined scoring modes.
[*][i]Retest Detection System[/i]: Monitors price proximity to the trail after the signal buffer period, triggering retest diamonds when price approaches within an ATR-fraction zone of the trail without crossing it, with per-side cooldown enforcement between consecutive signals.
[/list]
This design allows the trail to provide clean directional state through ratcheting mechanics while the cloud and candle systems layer spatial and momentum conviction context onto the same chart space.

[b]How It Works[/b]

Volatility Trail evaluates price through a sequence of trail-aware and conviction-scoring processes:
[list=1]
[*][i]Source Selection[/i]: The price source used for Hull calculation and trail comparison is selected from Close, HL2, HLC3, or OHLC4, allowing the baseline to be anchored to the most appropriate price representation for the target instrument.
[*][i]Hull Baseline Calculation[/i]: The Hull Moving Average is calculated over the configured length from the selected source, providing a low-lag directional reference that minimises the lag penalty of standard moving averages.
[*][i]ATR Band Derivation[/i]: Upper and lower bands are calculated by adding and subtracting ATR multiplied by the configured factor from the Hull baseline, producing volatility-scaled boundaries that adapt to changing market conditions.
[*][i]Trail Ratcheting[/i]: During an uptrend the trail advances as the maximum of the lower band and the prior trail, preventing retreat against price. During a downtrend it advances as the minimum of the upper band and the prior trail. When price closes through the current trail the trend flips and the trail resets to the opposing band.
[*][i]Trail Display Smoothing[/i]: An EMA smoothing pass over the configurable length is applied to the trail for display purposes, producing a visually cleaner line while signals continue to fire from the raw unsmoothed trail.
[*][i]Gradient Cloud Construction[/i]: The gap between the smoothed trail and close is calculated and four interpolation points are derived at proportional fractions of that gap. Each interval between adjacent points is filled with a directional color at progressively increasing transparency, producing a graduated cloud that radiates from the trail outward toward price.
[*][i]Distance Scoring[/i]: The absolute distance between close and the smoothed trail is divided by three times ATR to produce a normalized 0-1 distance score, measuring how far price has extended from the trail relative to recent volatility.
[*][i]Acceleration Scoring[/i]: Trail advancement speed is measured as the absolute change in trail position over the acceleration lookback, normalized by a fraction of ATR, producing a 0-1 score reflecting how quickly the trail is currently advancing.
[*][i]Score Combination and Power Transform[/i]: Depending on the selected candle mode, the distance score, acceleration score, or their maximum is selected, then raised to the power of 2.5 to suppress low-conviction readings and concentrate brightness at genuinely strong bars.
[*][i]Candle Color Mapping[/i]: The transformed score maps from a fixed dim neutral color at zero to the full trend color at one, producing candles that are nearly invisible during low-conviction conditions and fully saturated during strong extension or acceleration events.
[*][i]Retest Diamond Detection[/i]: After the signal buffer period from the most recent flip, price approaching within a fraction of ATR of the trail without crossing it triggers a directional retest diamond, with per-side cooldown enforced between consecutive signals.
[/list]
Together, these elements form a continuously updating trail system where ratcheting mechanics define direction, gradient cloud layers map spatial conviction, and candle scoring communicates momentum quality across every bar of the trend.

[b]Interpretation[/b]

Volatility Trail should be interpreted as a ratcheting trend system with radiating conviction geometry and multi-mode candle intensity scoring:
[list]
[*][i]Bullish Trend State (Green)[/i]: Active when the trail has ratcheted below price and price has not closed below it, with the gradient cloud radiating upward from the trail toward the current bar.
[*][i]Bearish Trend State (Red)[/i]: Active when the trail has ratcheted above price and price has not closed above it, with the gradient cloud radiating downward from the trail toward the current bar.
[*][i]Trail Line[/i]: The smoothed ratcheting trail provides the primary directional boundary, advancing with the trend and serving as the structural invalidation level for the current directional state.
[*][i]Gradient Cloud[/i]: Four fills between the trail and price create a radiating opacity field that intensifies near the trail and fades toward price, visually encoding the spatial relationship between the ratchet boundary and current price action. A thick, prominent cloud indicates substantial separation, while a thin cloud suggests price is close to the trail and near potential retest territory.
[*][i]Distance Mode Candles[/i]: Candle brightness reflects how far price has extended from the trail relative to ATR. Bright candles indicate substantial separation, dim candles indicate proximity to the trail.
[*][i]Acceleration Mode Candles[/i]: Candle brightness reflects how fast the trail itself is advancing. Bright candles indicate the trail is moving quickly with the trend, dim candles indicate the trail is stalling.
[*][i]Both Mode Candles[/i]: Candle brightness reflects the maximum of distance and acceleration scores, brightening when either strong extension or strong trail advancement is present.
[*][i]▲ Buy Signals[/i]: Green triangles mark upward trail flips where trend has switched from bearish to bullish and the trail has reset to the lower ATR band.
[*][i]▼ Sell Signals[/i]: Red triangles mark downward trail flips where trend has switched from bullish to bearish and the trail has reset to the upper ATR band.
[*][i]◆ Retest Diamonds[/i]: Small diamonds plotted below bars during bullish retests and above bars during bearish retests when price approaches within the retest zone of the trail after the signal buffer period, identifying potential continuation interaction points with the trailing boundary.
[/list]
Trail position, cloud depth, candle brightness, and retest diamond placement collectively provide more conviction information than trend direction alone.

[b]Signal Logic & Visual Cues[/b]

Volatility Trail presents two primary trail flip signals alongside continuous retest zone monitoring:
[list=1]
[*][i]Buy Signal (▲)[/i]: Green triangle appears when the trail ratchet flips from bearish to bullish, indicating price has closed above the upper ATR band and the trail has reset to the lower band to begin a new bullish ratchet cycle.
[*][i]Sell Signal (▼)[/i]: Red triangle appears when the trail ratchet flips from bullish to bearish, indicating price has closed below the lower ATR band and the trail has reset to the upper band to begin a new bearish ratchet cycle.
[/list]
Retest diamond detection provides continuous secondary monitoring, marking proximity to the trail after the signal buffer period with independent per-side cooldown enforcement, identifying potential continuation setups at the ratchet boundary throughout the established trend.

Alert generation covers bullish and bearish trail flips and both bullish and bearish retest events for systematic trend monitoring workflows.

[b]Strategy Integration[/b]

Volatility Trail fits within volatility-adaptive trailing and momentum conviction approaches:
[list]
[*][i]Trail Flip Entries[/i]: Use trail flip signals as primary trend initiation triggers where price has closed through the ATR-scaled boundary and the ratchet has reset in the new direction, with the newly positioned trail providing an immediate structural invalidation reference.
[*][i]Candle Mode Selection for Instrument Type[/i]: Use Distance mode on instruments where price extension from the trail is the primary conviction indicator, Acceleration mode on instruments where trail advancement speed is more consistent, and Both mode for instruments where either characteristic can signal high conviction depending on market phase.
[*][i]Cloud Depth Assessment[/i]: Use gradient cloud depth as a real-time spatial conviction reading. A deep cloud with multiple visible layers indicates substantial separation and trend momentum. A thin cloud with minimal fill depth indicates price is compressing toward the trail and a retest is increasingly probable.
[*][i]Retest Diamond Re-entry[/i]: Use retest diamonds as lower-risk continuation entry references within established trends, entering in the trend direction when price approaches the trail boundary after the signal buffer period rather than chasing extended price action far from the trail.
[*][i]ATR Factor Calibration[/i]: Adjust the ATR factor to match the instrument's typical volatility behavior at the target timeframe, using higher factors for instruments requiring more room between price and trail and lower factors for tighter ratchet tracking.
[*][i]Multi-Timeframe Trail Alignment[/i]: Apply higher-timeframe trail direction as a bias filter, engaging with lower-timeframe flip signals and retest diamonds only when they align with the established higher-timeframe ratchet direction.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Core Engine[/i]: Hull Moving Average baseline with configurable source and ATR-scaled ratcheting trail mechanics
[*][i]Trail Logic[/i]: One-directional ratchet advancing as band maximum or minimum in respective trend directions with flip on close breach
[*][i]Gradient Cloud[/i]: Four proportional gap interpolation points with interval fills at graduated transparency levels radiating from trail toward price
[*][i]Candle Scoring[/i]: ATR-normalized distance and acceleration scoring with power transform and gradient mapping to dim-to-trend-color range
[*][i]Retest System[/i]: ATR-fraction proximity zone detection with signal buffer and independent per-side cooldown enforcement
[*][i]Visualization[/i]: Smoothed trail line, four-layer gradient cloud fills, flip signal labels, retest diamond markers, and multi-mode intensity-scored candle coloring
[*][i]Signal Logic[/i]: Raw trail flip detection with smoothing applied to display only, preserving signal timing accuracy
[*][i]Performance Profile[/i]: Optimized for real-time execution across all timeframes with stateful trail variable maintaining ratchet progress between bars
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday trail tracking for scalping with shorter Hull length and tighter ATR factor for fast ratchet response to intraday momentum shifts
[*][i]15 - 60 min[/i]: Session-level trend identification with balanced Hull length and moderate ATR factor for reliable directional framing across typical session moves
[*][i]4H - Daily[/i]: Swing-level trailing with longer Hull length and higher ATR factor for sustained ratchet persistence across multi-session directional moves
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Hull Length[/i]: 72
[*][i]ATR Length[/i]: 9
[*][i]ATR Factor[/i]: 1.7
[*][i]Source[/i]: Close
[*][i]Trail Smoothing[/i]: 4
[*][i]Show Gradient Cloud[/i]: Enabled
[*][i]Color Candles[/i]: Enabled
[*][i]Candle Color Mode[/i]: Distance
[*][i]Show Buy/Sell[/i]: Enabled
[*][i]Retest Diamonds[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, Hull responsiveness at the target timeframe, and preferred signal frequency, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Trail flips too frequently[/i]: Increase ATR Factor to widen the distance between the Hull baseline and the trail boundary, requiring more significant price displacement before a flip is registered.
[*][i]Trail flips too slowly[/i]: Decrease ATR Factor toward 0.5 for a tighter trail that responds faster to directional changes, or decrease Hull Length for a more reactive baseline.
[*][i]Hull baseline too laggy[/i]: Decrease Hull Length toward 20 for a faster baseline that captures directional shifts earlier, accepting increased sensitivity to short-term price fluctuations.
[*][i]Hull baseline too reactive[/i]: Increase Hull Length for a smoother baseline that filters minor oscillations and produces a more stable trail ratchet with fewer noise-driven flips.
[*][i]Candles too uniformly dim[/i]: Switch to Acceleration mode if the instrument's trail advancement speed is more variable than its price extension, or reduce ATR Factor so distance scores normalize against a tighter trail range.
[*][i]Too many retest diamonds[/i]: Increase Retest Cooldown to enforce greater bar separation between consecutive diamond markers, or increase Signal Buffer to delay retest detection further from each flip event.
[*][i]Retest diamonds not firing[/i]: The retest zone is sized as a fraction of ATR multiplied by the ATR Factor. On instruments with very consistent trail distance this zone may be narrow. Increasing ATR Factor slightly widens the retest detection zone relative to the trail boundary.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with sustained directional moves where the Hull baseline advances consistently and the trail ratchets without frequent resets, producing deep gradient clouds and bright high-conviction candles throughout the move
[*]Instruments with consistent ATR behavior where the volatility-scaled trail distance produces reliable flip signals without excessive noise-driven reversals
[*]Momentum continuation strategies that benefit from the retest diamond system identifying pullback interactions with the trail boundary as lower-risk continuation entry points
[*]Multi-mode candle scoring approaches where distance or acceleration scoring provides additional conviction context that supplements the directional trail signal
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, low-momentum markets where price oscillates near the Hull baseline, causing frequent trail flips and preventing the ratchet from establishing meaningful directional progress
[*]Extremely volatile instruments where ATR spikes produce wide trail distances that delay flip detection relative to the actual structural change in price direction
[*]Consolidation environments where the Hull baseline moves sideways and the trail ratchet stalls, producing minimal cloud depth and uniformly dim candles without directional conviction scoring
[*]News-driven or gap-heavy markets where instantaneous price displacements trigger trail flips that immediately reverse before the ratchet can establish sustained directional progress
[*]Mean-reversion dominant conditions where trail flips occur rapidly in alternating directions without the sustained follow-through required for gradient cloud development or sequential retest patterns
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, order flow analysis, or momentum oscillators to validate trail flip signals with broader analytical context before committing to directional positions
[*][i]Cloud Depth Monitoring[/i]: Track gradient cloud depth evolution throughout the trend as a spatial conviction indicator. Progressively deepening cloud layers suggest sustained separation and trend health while thinning cloud depth warns of price compression toward the trail and potential retest or flip conditions.
[*][i]Candle Mode Selection[/i]: Match the candle scoring mode to the instrument's typical conviction expression. Instruments that show conviction through large extension moves favor Distance mode; instruments that show conviction through accelerating trail advancement favor Acceleration mode; instruments that express conviction through either mechanism favor Both mode.
[*][i]Ratchet Progress Awareness[/i]: Recognize that the trail only advances and never retreats against price within a trend. Rapid trail advancement reflected in bright Acceleration mode candles indicates strong directional follow-through, while a stalling trail with minimal advancement suggests momentum is flattening before potential reversal.
[*][i]State Discipline[/i]: Maintain directional bias aligned with the current trail trend state until a confirmed closing breach of the trail triggers a flip. Retest diamonds and cloud thinning within an established trend represent continuation context rather than reversal signals and should not override the ratchet-defined directional state.
[/list]
[b]Disclaimer[/b]

Volatility Trail [BOSWaves] is a professional-grade Hull-anchored trend trailing and conviction visualization tool. It uses ATR-scaled ratcheting trail mechanics with gradient cloud construction and multi-mode candle scoring but does not predict future price movements. Results depend on market conditions, instrument volatility characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Volatility Trail [BOSWaves]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gCore  = "Trail Engine"
const string gCloud = "Cloud & Candles"
const string gSig   = "Signals"

int    hullLen    = input.int(72, "Hull Length", minval = 5, group = gCore, tooltip = "Hull MA smoothing length. Lower = faster response.")
int    atrLen     = input.int(9, "ATR Length", minval = 1, group = gCore, tooltip = "ATR lookback for trail distance.")
float  atrFactor  = input.float(1.7, "ATR Factor", step = 0.1, minval = 0.5, group = gCore, tooltip = "Multiplier for trail distance. Higher = more room before flip.")
string src        = input.string("Close", "Source", options = ["Close", "HL2", "HLC3", "OHLC4"], group = gCore)
int    trailSmth  = input.int(4, "Trail Smoothing", minval = 1, maxval = 10, group = gCore, tooltip = "EMA smoothing on the displayed trail. Signals fire from the raw trail.")

bool   showCloud  = input.bool(true, "Show Gradient Cloud", group = gCloud, tooltip = "Layered gradient that radiates from the trail toward price.")
bool   showCandle = input.bool(true, "Color Candles", group = gCloud)
string candleMode = input.string("Distance", "Candle Color Mode", options = ["Distance", "Acceleration", "Both"], group = gCloud, tooltip = "Distance: brightness by how far price is from the trail.\nAcceleration: brightness by how fast the trail is advancing.\nBoth: combines distance and acceleration.")
int    accelLen   = input.int(2, "Acceleration Lookback",group = gCloud)

bool   showSig    = input.bool(true, "Show Buy/Sell", group = gSig)
bool   showRetest = input.bool(true, "Retest Diamonds", group = gSig, tooltip = "Marks when price dips back toward the trail after trending away.")
int    rtCooldown = input.int(10, "Retest Cooldown", minval = 1, maxval = 50, group = gSig)
int    sigBuffer  = input.int(5, "Signal Buffer", minval = 1, maxval = 20, group = gSig, tooltip = "Bars after a flip before retests can fire.")

color  bullCol    = input.color(#00ff00, "Bullish", inline = "c", group = gCloud)
color  bearCol    = input.color(#ff0000, "Bearish", inline = "c", group = gCloud)

// ┌────────────────────────────── BOSWaves ─ Source ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float srcVal = switch src
    "HL2"   => hl2
    "HLC3"  => hlc3
    "OHLC4" => ohlc4
    => close

// ┌────────────────────────────── BOSWaves ─ Hull + ATR Trail ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float hull = ta.hma(srcVal, hullLen)
float atr  = ta.atr(atrLen)

float upperBand = hull + atr * atrFactor
float lowerBand = hull - atr * atrFactor

var float trail = na
var bool  trend = true

float prevTrail = nz(trail)

if na(trail)
    trail := close > hull ? lowerBand : upperBand

if trend
    trail := math.max(lowerBand, prevTrail)
    if close < trail
        trend := false
        trail := upperBand
else
    trail := math.min(upperBand, prevTrail)
    if close > trail
        trend := true
        trail := lowerBand

float trailVis = ta.ema(trail, trailSmth)

// ┌────────────────────────────── BOSWaves ─ Flip Detection ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool flipUp  = trend and not trend[1]
bool flipDn  = not trend and trend[1]
bool anyFlip = flipUp or flipDn

var int   flipBar    = 0
var int   lastBullRT = na
var int   lastBearRT = na

if anyFlip
    flipBar := bar_index

color trendCol = trend ? bullCol : bearCol

// ┌────────────────────────────── BOSWaves ─ Gradient Layers ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float gap   = close - trailVis
float band1 = trailVis + gap * 0.2
float band2 = trailVis + gap * 0.4
float band3 = trailVis + gap * 0.65
float band4 = trailVis + gap * 0.85

float b1s = ta.ema(band1, trailSmth)
float b2s = ta.ema(band2, trailSmth)
float b3s = ta.ema(band3, trailSmth)
float b4s = ta.ema(band4, trailSmth)

pTrail = plot(trailVis, "Trail", trendCol, linewidth = 2)

pB1 = plot(showCloud ? b1s : na, "Band 1", color = color.new(trendCol, 100), display = display.all, editable = false)
pB2 = plot(showCloud ? b2s : na, "Band 2", color = color.new(trendCol, 100), display = display.all, editable = false)
pB3 = plot(showCloud ? b3s : na, "Band 3", color = color.new(trendCol, 100), display = display.all, editable = false)
pB4 = plot(showCloud ? b4s : na, "Band 4", color = color.new(trendCol, 100), display = display.all, editable = false)

fill(pTrail, pB1, trailVis, b1s, trend ? color.new(bullCol, 20) : color.new(bearCol, 75), trend ? color.new(bullCol, 75) : color.new(bearCol, 20))

fill(pB1, pB2, b1s, b2s, trend ? color.new(bullCol, 50) : color.new(bearCol, 85), trend ? color.new(bullCol, 85) : color.new(bearCol, 50))

fill(pB2, pB3, b2s, b3s, trend ? color.new(bullCol, 75) : color.new(bearCol, 92), trend ? color.new(bullCol, 92) : color.new(bearCol, 75))

fill(pB3, pB4, b3s, b4s, trend ? color.new(bullCol, 88) : color.new(bearCol, 95), trend ? color.new(bullCol, 95) : color.new(bearCol, 88))

// ┌────────────────────────────── BOSWaves ─ Candle Scoring ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float distToTrail = math.abs(close - trailVis)
float distScore   = nz(atr) > 0 ? math.min(distToTrail / (atr * 3), 1.0) : 0.0

float trailSpeed  = math.abs(trailVis - nz(trailVis[accelLen])) / accelLen
float speedNorm   = nz(atr) > 0 ? math.min(trailSpeed / (atr * 0.2), 1.0) : 0.0

float rawScore = switch candleMode
    "Distance"     => distScore
    "Acceleration" => speedNorm
    "Both"         => math.max(distScore, speedNorm)
    => distScore

// Crush low scores hard — only genuinely strong bars break through
float exScore = math.pow(rawScore, 2.5)

// ┌────────────────────────────── BOSWaves ─ Candle Rendering ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color dimCol  = #2a2a2e

color bodyCol = showCandle ? color.from_gradient(exScore, 0, 1, dimCol, trendCol) : na
color wickCol = showCandle ? color.from_gradient(exScore, 0, 1, color.new(dimCol, 30), trendCol) : na
color bordCol = showCandle ? color.from_gradient(exScore, 0, 1, color.new(dimCol, 20), trendCol) : na

plotcandle(open, high, low, close, "Candles",
     wickcolor   = wickCol,
     color       = bodyCol,
     bordercolor = bordCol,
     display     = showCandle ? display.all : display.none)
// ┌────────────────────────────── BOSWaves ─ Retest Diamonds ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool farEnough = bar_index - flipBar >= sigBuffer

float retestZone = atr * atrFactor * 0.3
bool  bullRT     = showRetest and trend and (low - trailVis) < retestZone and (low - trailVis) > 0 and farEnough
bool  bearRT     = showRetest and not trend and (trailVis - high) < retestZone and (trailVis - high) > 0 and farEnough

bool bullRTok = bullRT and (na(lastBullRT) or bar_index - lastBullRT >= rtCooldown)
bool bearRTok = bearRT and (na(lastBearRT) or bar_index - lastBearRT >= rtCooldown)

if bullRTok
    lastBullRT := bar_index
if bearRTok
    lastBearRT := bar_index

plotchar(bullRTok, "Bull Retest", "◆", location.belowbar, bullCol, size = size.tiny)
plotchar(bearRTok, "Bear Retest", "◆", location.abovebar, bearCol, size = size.tiny)

// ┌────────────────────────────── BOSWaves ─ Buy / Sell Signals ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if showSig and flipUp
    label.new(bar_index, low - atr * 1.2, "▲",
         style = label.style_label_up,
         size = size.normal,
         color = bullCol,
         textcolor = color.white)

if showSig and flipDn
    label.new(bar_index, high + atr * 1.2, "▼",
         style = label.style_label_down,
         size = size.normal,
         color = bearCol,
         textcolor = color.white)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(flipUp, "Trail Long", "Volatility Trail flipped bullish on {{ticker}}")
alertcondition(flipDn, "Trail Short", "Volatility Trail flipped bearish on {{ticker}}")
alertcondition(bullRTok, "Bull Retest", "Bullish trail retest on {{ticker}}")
alertcondition(bearRTok, "Bear Retest", "Bearish trail retest on {{ticker}}")
````
