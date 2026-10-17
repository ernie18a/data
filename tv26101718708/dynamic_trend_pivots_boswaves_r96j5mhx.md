# Dynamic Trend Pivots [BOSWaves]

- url: https://www.tradingview.com/script/r96J5mhx-Dynamic-Trend-Pivots-BOSWaves/
- type: indicator
- pine_id: PUB;a3e7f93d9f494c5ab306973e5e0ebef9
- version: 1.0

## Description

[b]Dynamic Trend Pivots [BOSWaves] - Conviction-Driven Trend Detection with Pulse-Adaptive Exhaustion Level Mapping[/b]

[b]Overview[/b]

Dynamic Trend Pivots [BOSWaves] is a conviction-based trend identification and structural level mapping system that tracks directional price commitment through a pulse accumulation engine, where band width, trend confidence, and exhaustion level placement are driven by real-time measurement of close-position conviction across consecutive bars rather than arbitrary moving average relationships or fixed volatility multiples.

[image]https://www.tradingview.com/x/JK1FN80L/[/image]

Instead of relying on standard crossover logic or static band thresholds, trend state, adaptive band behavior, and exhaustion level generation are determined through bar-level conviction scoring, pulse saturation modeling, and peak-to-trough saturation drop detection that identifies genuine momentum exhaustion events as they occur.

This creates a trend framework that reflects actual directional commitment rather than lagged price averages - tightening bands during high-conviction pulse saturation when trend confidence is elevated, expanding bands as conviction decays and directional commitment weakens, and planting structural exhaustion levels at the precise price points where pulse energy peaked before collapsing, marking locations of maximum prior commitment for future reference.

Price is therefore evaluated against bands and structural levels that respond to measurable conviction dynamics rather than conventional indicator thresholds.

[b]Conceptual Framework[/b]

Dynamic Trend Pivots is founded on the principle that meaningful trend signals and structural reference levels emerge from the accumulation and exhaustion of bar-level directional conviction, not from price crossing smoothed averages or breaching fixed statistical bands.

Traditional trend-following approaches identify directional changes through indicator crossovers or band penetrations that treat all bars equally regardless of their internal structure and conviction quality. This framework replaces undifferentiated price-level logic with conviction-weighted pulse tracking that distinguishes between bars demonstrating genuine directional commitment and bars that merely move price without close-position confirmation.

Three core principles guide the design:
[list=1]
[*]Trend conviction should be measured through close positioning within the bar range combined with directional agreement, not through price displacement alone.
[*]Band width must dynamically reflect pulse saturation state, contracting during high-conviction conditions and expanding as conviction decays.
[*]Structural reference levels should be planted at exhaustion events — the precise price points where accumulated conviction peaked before collapsing — rather than at arbitrary pivot formations.
[/list]
This shifts trend analysis from static threshold detection into a continuously updating conviction framework anchored in measurable bar-level directional commitment.

[b]Theoretical Foundation[/b]

The indicator combines close-position conviction measurement, pulse accumulation and decay modeling, MAD-based adaptive band construction, and saturation peak tracking for exhaustion event detection.

Conviction bars are identified through close positioning within the bar range: a bull conviction bar closes in the upper fraction of its range on an up-close bar, and a bear conviction bar closes in the lower fraction on a down-close bar. A pulse counter accumulates these conviction readings up to a configurable saturation cap, while decaying exponentially between conviction events. Saturation drives the band multiplier interpolation between tight and wide settings, reflecting real-time trend confidence. Exhaustion detection monitors saturation's relationship to its recent peak, planting structural levels when saturation drops sufficiently from that peak.

Four internal systems operate in tandem:
[list]
[*][i]Pulse Accumulation Engine[/i]: Evaluates each bar for directional conviction based on close positioning within the high-low range, accumulating bull and bear pulse counters independently with configurable decay between conviction events.
[*][i]Saturation Measurement System[/i]: Converts raw pulse counts into a normalized saturation reading relative to the pulse cap, providing the continuous 0-1 conviction metric that drives all adaptive behavior.
[*][i]MAD Adaptive Band Construction[/i]: Applies Mean Absolute Deviation-scaled bands around an EMA baseline, with the band multiplier dynamically interpolating between minimum and maximum settings based on current saturation.
[*][i]Exhaustion Level Engine[/i]: Tracks saturation peaks with their associated price and direction, planting structural zone levels when saturation drops below a configurable fraction of its recent peak, with lifecycle management including break detection, zone extension, and retest identification.
[/list]
This design allows trend confidence and structural reference levels to reflect actual conviction dynamics rather than responding mechanically to price or indicator crossovers.

[b]How It Works[/b]

Dynamic Trend Pivots evaluates price through a sequence of conviction-aware processes:
[list=1]
[*][i]Conviction Bar Classification[/i]: Each bar's close position within its high-low range is measured; bars closing in the upper fraction on an up-close qualify as bull conviction bars, and bars closing in the lower fraction on a down-close qualify as bear conviction bars.
[*][i]Pulse Counter Update[/i]: Bull or bear pulse counters increment by one on each qualifying conviction bar up to the saturation cap, and decay multiplicatively by the configured decay rate when conviction bars are absent.
[*][i]Saturation Calculation[/i]: The dominant pulse counter (bull or bear) divided by the pulse cap yields a normalized saturation value, with signed directional pulse providing the complete conviction state.
[*][i]Saturation Peak Tracking[/i]: The system continuously monitors saturation, recording the peak value, direction, associated price level (high for bull, low for bear), and bar index when each new saturation maximum is established.
[*][i]Exhaustion Event Detection[/i]: When current saturation drops below the configured fraction of the recorded saturation peak, an exhaustion event fires, triggering structural level placement at the recorded peak price.
[*][i]Adaptive Band Construction[/i]: The band multiplier interpolates between the minimum (saturated, tight) and maximum (exhausted, wide) settings based on current saturation, scaling MAD to determine upper and lower band distances from the EMA baseline.
[*][i]Trend State Logic[/i]: Price crossing above the raw upper band triggers bullish state; crossing below the raw lower band triggers bearish state; state persists until the opposite breach occurs.
[*][i]Signal Generation[/i]: State transitions from bearish to bullish produce buy labels; bullish to bearish transitions produce sell labels, both plotted at MAD-scaled offsets from price.
[*][i]Exhaustion Level Lifecycle[/i]: Planted levels extend rightward with zone boxes, dashed midlines, and price labels until price closes beyond the zone boundary with ATR buffer confirmation, at which point the level is removed.
[*][i]Retest Detection[/i]: When price re-enters an active exhaustion zone after the minimum origin bar offset, a retest signal fires with a configurable cooldown enforced between subsequent retests on the same level.
[/list]
Together, these elements form a continuously updating conviction map that simultaneously tracks trend state and marks the structural fingerprints left by exhausted momentum.

[b]Interpretation[/b]

Dynamic Trend Pivots should be interpreted as a conviction-weighted trend framework with exhaustion-derived structural reference levels:
[list]
[*][i]Bullish Trend State (Green)[/i]: Established when price closes above the raw adaptive upper band, indicating a conviction-supported upward directional breach.
[*][i]Bearish Trend State (Magenta)[/i]: Established when price closes below the raw adaptive lower band, signaling a conviction-supported downward directional breach.
[*][i]Band Cloud[/i]: Visual gradient zone fills between the outer band edge and close, with opacity and color reflecting current trend state and providing a continuous conviction boundary reference.
[*][i]Band Width Dynamics[/i]: Tight bands indicate high pulse saturation (elevated conviction), while wide bands reflect saturation decay (diminished conviction and increased caution).
[*][i]▲ Buy Signals[/i]: Green upward triangles mark bullish state initiations at upper band crossovers, plotted below the bar at a MAD-scaled offset.
[*][i]▼ Sell Signals[/i]: Red downward triangles mark bearish state initiations at lower band crossunders, plotted above the bar at a MAD-scaled offset.
[*][i]Exhaustion Zone[/i]: ATR-scaled rectangular zones centered on the saturation peak price mark prior conviction exhaustion locations, with colored borders and subtle fills distinguishing bull from bear exhaustion origin.
[*][i]Exhaustion Midline[/i]: Dashed line through the precise saturation peak price within each zone provides a high-precision structural reference at the exact level of maximum prior conviction.
[*][i]◆ Origin Marker[/i]: Diamond label plotted on the bar where each exhaustion event occurred, marking the conviction peak location for retrospective analysis.
[*][i]✦ Retest Signals[/i]: Small star diamonds mark price re-entry into active exhaustion zones after the origin buffer period, identifying potential reaction points within proven conviction regions.
[*][i]Retest Extension Lines[/i]: Horizontal lines projected forward from retest bar highs or lows mark the retest price level for ongoing reference.
[*][i]Colored Candles[/i]: Optional bar coloring reflects trend state and fades toward neutral as saturation decays, providing an immediate visual exhaustion cue. [b]Note: The original chart candles must be disabled in chart settings for the conviction-colored candles to display properly.[/b]
[/list]
Saturation state, band width dynamics, and exhaustion level proximity outweigh isolated price movements in isolation.

[b]Signal Logic & Visual Cues[/b]

Dynamic Trend Pivots presents two primary trend interaction signals alongside a continuous exhaustion level monitoring system:
[list=1]
[*][i]Buy Signal (▲)[/i]: Green triangle appears when trend state switches from bearish to bullish via upper band crossover, indicating conviction-supported directional shift to the upside.
[*][i]Sell Signal (▼)[/i]: Red triangle displays when trend state switches from bullish to bearish via lower band crossunder, indicating conviction-supported directional shift to the downside.
[/list]
Exhaustion zone retests provide secondary structural signals when price revisits prior conviction peak regions after the minimum origin offset, subject to per-level cooldown enforcement.

Alert generation covers bullish and bearish state switches, exhaustion events triggering new level placement, and both bullish and bearish retest occurrences for systematic structural monitoring.

[b]Strategy Integration[/b]

Dynamic Trend Pivots fits within conviction-informed and structural level-based trading approaches:
[list]
[*][i]Conviction-Confirmed Entries[/i]: Use band crossover signals as trend initiation points where saturation-supported conviction has driven price through the adaptive boundary, rather than acting on low-conviction crossovers during band expansion.
[*][i]Saturation-Based Position Sizing[/i]: Scale exposure relative to current pulse saturation — favor larger positions during high-saturation fresh trend conditions and reduce sizing as conviction decays and bands widen.
[*][i]Band-Width Risk Calibration[/i]: Expect tighter price ranges and more reliable directional follow-through during contracted band periods; treat expanded bands as a signal of reduced trend reliability requiring tighter risk management.
[*][i]Exhaustion Level Trade Planning[/i]: Use planted exhaustion zones as anticipatory structural levels — price reactions at these zones reflect the influence of the same conviction dynamics that originally caused the momentum peak and collapse.
[*][i]Retest-Based Re-entry[/i]: Treat exhaustion zone retests as lower-risk re-entry or continuation opportunities within established trends, using the midline as a precision reference for entry and invalidation.
[*][i]Multi-Timeframe Conviction Hierarchy[/i]: Apply higher-timeframe trend state and exhaustion level locations as directional bias filters while using lower-timeframe pulse signals for entry precision.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Core Engine[/i]: EMA-based trend baseline with MAD volatility measurement
[*][i]Conviction Model[/i]: Close-position ratio within high-low range with directional agreement gating
[*][i]Pulse System[/i]: Capped accumulation with configurable multiplicative decay between conviction events
[*][i]Band Construction[/i]: Linear interpolation between min/max multipliers based on saturation, scaling MAD offset from EMA baseline
[*][i]Exhaustion Detection[/i]: Saturation peak tracking with configurable drop threshold triggering level placement
[*][i]Visualization[/i]: Gradient-filled band cloud with ATR-scaled exhaustion zones, dashed midlines, and retest extension lines
[*][i]Signal Logic[/i]: Raw band crossover state-switch detection with saturation-faded candle coloring
[*][i]Performance Profile[/i]: Optimized for real-time execution with configurable level caps managing object count
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Micro-structure conviction tracking for scalping with responsive pulse and tight band settings
[*][i]15 - 60 min[/i]: Intraday trend identification with balanced decay characteristics and moderate exhaustion sensitivity
[*][i]4H - Daily[/i]: Swing-level conviction trend mapping with sustained pulse persistence and wider exhaustion zone tolerance
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Trend Length[/i]: 21
[*][i]Close Zone[/i]: 0.30
[*][i]Pulse Decay[/i]: 0.85
[*][i]Pulse Cap[/i]: 8
[*][i]MAD Length[/i]: 17
[*][i]Band Min (Saturated)[/i]: 1.4
[*][i]Band Max (Exhausted)[/i]: 2.2
[*][i]Exhaustion Drop[/i]: 0.4
[*][i]Max Levels[/i]: 8
[*][i]Break Buffer (ATR)[/i]: 0.25
[*][i]Show Band Cloud[/i]: Enabled
[*][i]Color Candles[/i]: Enabled (requires disabling original chart candles in chart settings)
[*][i]Show Buy/Sell Signals[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, conviction frequency, and preferred signal density, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Excessive signal noise[/i]: Increase Trend Length for a smoother baseline or tighten Close Zone toward 0.2 to demand more extreme close positioning before conviction is registered.
[*][i]Missed conviction events[/i]: Widen Close Zone toward 0.4 for more inclusive bar qualification or decrease Trend Length for a more reactive baseline.
[*][i]Pulse sustains too long[/i]: Decrease Pulse Decay toward 0.5 for faster conviction fade between qualifying bars, accelerating band expansion during low-conviction periods.
[*][i]Pulse fades too quickly[/i]: Increase Pulse Decay toward 0.99 to sustain saturation longer between conviction events, maintaining tighter bands through minor pullbacks.
[*][i]Bands too tight or wide across the board[/i]: Adjust Band Min and Band Max multipliers to rescale the full saturation-to-exhaustion band range for the instrument's volatility characteristics.
[*][i]Too many exhaustion levels forming[/i]: Increase Exhaustion Drop threshold toward 0.6 to demand a more severe saturation collapse before a level is planted, filtering for higher-conviction exhaustion events only.
[*][i]Levels not forming frequently enough[/i]: Decrease Exhaustion Drop toward 0.2 to plant levels on more modest saturation pullbacks, increasing structural level density.
[*][i]Levels breaking too easily[/i]: Increase Break Buffer ATR multiplier to require a more decisive close beyond the zone boundary before invalidation occurs.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with clear conviction phases where pulse saturation builds and sustains before exhausting at structural turning points
[*]Instruments with consistent bar structure where close positioning within the range reliably reflects directional commitment
[*]Momentum continuation strategies entering on fresh pulse saturation signals with contracted bands
[*]Structural level frameworks benefiting from exhaustion-derived reference zones rather than arbitrary pivot-based support and resistance
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, low-conviction environments where close positioning provides unreliable directional signals and pulse saturation builds and collapses rapidly without sustained directional follow-through
[*]Extremely gapped or news-driven markets where bar range structure becomes discontinuous and close positioning loses meaningful conviction interpretation
[*]Mean-reversion dominant conditions where band breaches quickly reverse without sufficient pulse saturation to sustain directional state
[*]Low-volatility compression periods where MAD scaling produces narrow bands that generate frequent false crossovers
[*]Consolidation and sideways conditions where conviction builds in alternating directions without achieving the sustained saturation required for reliable trend state establishment
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves order flow tools, volume analysis, or multi-timeframe structure indicators for layered confirmation
[*][i]Saturation Respect[/i]: Prioritize signals and level interactions occurring during high-saturation periods; treat low-saturation crossovers and retests with reduced confidence
[*][i]Exhaustion Awareness[/i]: Monitor candle fade coloring as an early warning of declining conviction before formal signal generation confirms a state change
[*][i]Level Hierarchy[/i]: Treat exhaustion levels planted during peak saturation events as higher-conviction structural references than levels formed during moderate saturation peaks
[*][i]Retest Discipline[/i]: Use exhaustion zone retests as continuation confirmation rather than reversal triggers unless accompanied by opposing band crossover signals
[/list]
[b]Disclaimer[/b]

Dynamic Trend Pivots [BOSWaves] is a professional-grade conviction analysis and structural level mapping tool. It uses pulse accumulation modeling with adaptive band construction and exhaustion-driven level placement but does not predict future price movements. Results depend on market conditions, instrument conviction characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, volume analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Dynamic Trend Pivots [BOSWaves]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ┌────────────────────────────── BOSWaves ─ Constants ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Pulse Engine"
const string g2 = "Adaptive Bands"
const string g3 = "Exhaustion Levels"
const string g4 = "Signals & Display"

color BULL = #00FF00
color BEAR = #FF0066

// ┌────────────────────────────── BOSWaves ─ Tooltips ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string tt_len          = "Baseline smoothing length. Higher = smoother trend, fewer signals."
const string tt_closeZone    = "What fraction of a bar's range the close must sit in to count as a conviction bar. Default 0.3 = top/bottom 30%."
const string tt_pulseDecay   = "How fast the pulse counter decays when a conviction bar doesn't print. Higher = pulse sustains longer."
const string tt_pulseCap     = "Maximum pulse count before saturation. Once reached, further conviction bars don't add — the engine is fully charged."
const string tt_mad_len      = "Lookback for Mean Absolute Deviation. Higher = smoother bands."
const string tt_bandMin      = "Band multiplier at full saturation (fully charged pulse → tight bands, confidence)."
const string tt_bandMax      = "Band multiplier when pulse is exhausted (bands wide, caution)."
const string tt_dropThresh   = "Saturation must fall below this fraction of its recent peak to plant an exhaustion level. Lower = only plant on heavy exhaustion."
const string tt_maxLevels    = "Maximum number of active exhaustion levels. Oldest removed first."
const string tt_breakBuffer  = "ATR buffer past a level required for it to be counted as broken."
const string tt_retestCd     = "Minimum bars between retest signals on a single level."
const string tt_zoneHeight   = "Thickness of each exhaustion zone as an ATR multiplier. Higher = thicker, more visible zones."
const string tt_zoneTransp   = "Transparency of the exhaustion zone fill. 0 = fully opaque, 95 = nearly invisible."
const string tt_smoothType   = "Smoothing method applied to the displayed band lines.\nSMA — simple average\nEMA — exponential\nHMA — Hull (low lag, fast)\nALMA — arnaud legoux (smoothest)"
const string tt_smoothLen    = "Smoothing length for the displayed band lines. Higher = smoother curves. Signals are NOT affected by this setting."
const string tt_cloud        = "Display the adaptive band cloud."
const string tt_bars         = "Color candles based on current trend direction and pulse saturation."
const string tt_signals      = "Show Buy/Sell labels on trend flips."
const string tt_bands        = "Show the adaptive upper and lower bands."
const string tt_colors       = "Colors for bullish and bearish trend states."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

// ─────────────────── Pulse Engine ───────────────────
int   len         = input.int(21, "Trend Length", minval=5, group=g1, tooltip=tt_len)
float closeZone   = input.float(0.3, "Close Zone", minval=0.1, maxval=0.5, step=0.05, group=g1, tooltip=tt_closeZone)
float pulseDecay  = input.float(0.85, "Pulse Decay", minval=0.5, maxval=0.99, step=0.01, group=g1, tooltip=tt_pulseDecay)
int   pulseCap    = input.int(8, "Pulse Cap", minval=3, maxval=20, group=g1, tooltip=tt_pulseCap)

// ─────────────────── Adaptive Bands ───────────────────
int    madLen      = input.int(17, "MAD Length", minval=5, group=g2, tooltip=tt_mad_len)
float  bandMin     = input.float(1.4, "Band Min (Saturated)", minval=0.5, step=0.1, group=g2, tooltip=tt_bandMin)
float  bandMax     = input.float(2.2, "Band Max (Exhausted)", minval=1.0, step=0.1, group=g2, tooltip=tt_bandMax)
bool   showBands   = input.bool(true, "Show Bands", group=g2, tooltip=tt_bands)
string smoothType  = input.string("EMA", "Line Smoothing", options=["SMA", "EMA", "HMA", "ALMA"], group=g2, tooltip=tt_smoothType)
int    smoothLen   = input.int(20, "Smoothing Length", minval=1, maxval=20, group=g2, tooltip=tt_smoothLen)

// ─────────────────── Exhaustion Levels ───────────────────
bool  showLevels  = input.bool(true, "Show Exhaustion Levels", group=g3)
float dropThresh  = input.float(0.4, "Exhaustion Drop", minval=0.1, maxval=0.8, step=0.05, group=g3, tooltip=tt_dropThresh)
int   maxLevels   = input.int(8, "Max Levels", minval=2, maxval=30, group=g3, tooltip=tt_maxLevels)
float breakBuffer = input.float(0.25, "Break Buffer (ATR)", minval=0.0, step=0.05, group=g3, tooltip=tt_breakBuffer)
int   retestCd    = input.int(8, "Retest Cooldown", minval=1, maxval=50, group=g3, tooltip=tt_retestCd)
float zoneHeight  = input.float(0.25, "Zone Thickness (ATR)", minval=0.05, maxval=1.0, step=0.05, group=g3, tooltip=tt_zoneHeight)
int   zoneTransp  = input.int(78, "Zone Transparency", minval=50, maxval=95, group=g3, tooltip=tt_zoneTransp)

// ─────────────────── Signals & Display ───────────────────
bool  showCloud   = input.bool(true, "Show Band Cloud", group=g4, tooltip=tt_cloud)
bool  paintBars   = input.bool(true, "Color Candles", group=g4, tooltip=tt_bars)
bool  showSignals = input.bool(true, "Show Buy/Sell Signals", group=g4, tooltip=tt_signals)
color bullCol     = input.color(BULL, "Bullish", inline="col", group=g4, tooltip=tt_colors)
color bearCol     = input.color(BEAR, "Bearish", inline="col", group=g4)
int   rtW         = input.int(5, "Retest Line Width", minval=1, maxval=10, group=g4)

// ┌────────────────────────────── BOSWaves ─ Core Calculations ──────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float basis = ta.ema(close, len)
float atrV  = ta.atr(14)

float mean = ta.sma(close, madLen)
float mad  = ta.sma(math.abs(close - mean), madLen)

// ┌────────────────────────────── BOSWaves ─ Pulse Engine ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// A conviction bar closes in the upper/lower closeZone of its range AND in the direction of travel
float barRange = math.max(high - low, syminfo.mintick)
float closeLoc = (close - low) / barRange  // 0 = at low, 1 = at high

bool bullConv = closeLoc >= (1.0 - closeZone) and close > open
bool bearConv = closeLoc <= closeZone and close < open

var float bullPulse = 0.0
var float bearPulse = 0.0

if bullConv
    bullPulse := math.min(bullPulse + 1.0, float(pulseCap))
else
    bullPulse := bullPulse * pulseDecay

if bearConv
    bearPulse := math.min(bearPulse + 1.0, float(pulseCap))
else
    bearPulse := bearPulse * pulseDecay

float saturation    = math.max(bullPulse, bearPulse) / float(pulseCap)
int   dominantDir   = bullPulse > bearPulse ? 1 : bullPulse < bearPulse ? -1 : 0
float signedPulse   = dominantDir == 1 ? bullPulse / float(pulseCap) :
                     dominantDir == -1 ? -bearPulse / float(pulseCap) : 0.0

// Track recent saturation peak for exhaustion detection
var float satPeak     = 0.0
var int   satPeakDir  = 0
var float satPeakPrice = na
var int   satPeakBar   = na

if saturation > satPeak
    satPeak       := saturation
    satPeakDir    := dominantDir
    satPeakPrice  := dominantDir == 1 ? high : low
    satPeakBar    := bar_index

bool exhausted = satPeak > 0.5 and saturation < satPeak * dropThresh

// ┌────────────────────────────── BOSWaves ─ Adaptive Bands ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// Saturated pulse = tight bands (confident trend). Exhausted = wide bands (caution).
float bandMult = bandMax - (bandMax - bandMin) * saturation
float upper    = basis + mad * bandMult
float lower    = basis - mad * bandMult

// ┌────── Display-only smoothing (signals still fire from raw upper/lower) ──────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_smooth(float src, string kind, int length) =>
    switch kind
        "SMA"  => ta.sma(src, length)
        "EMA"  => ta.ema(src, length)
        "HMA"  => ta.hma(src, length)
        "ALMA" => ta.alma(src, length, 0.85, 6)
        =>        ta.ema(src, length)

float upperPlot = smoothLen > 1 ? f_smooth(upper, smoothType, smoothLen) : upper
float lowerPlot = smoothLen > 1 ? f_smooth(lower, smoothType, smoothLen) : lower

// ┌────────────────────────────── BOSWaves ─ Signal Logic ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var int lastSignal = 0

// Signals use RAW upper/lower — smoothing does not affect timing
bool longCond  = ta.crossover(close, upper)
bool shortCond = ta.crossunder(close, lower)

int prevSignal = lastSignal
lastSignal := longCond ? 1 : shortCond ? -1 : lastSignal

bool  switchUp   = lastSignal == 1  and prevSignal == -1
bool  switchDown = lastSignal == -1 and prevSignal == 1
color trendCol   = lastSignal == 1 ? bullCol : bearCol

// Fade candle color toward neutral as saturation drops (visual exhaustion cue)
color barCol = color.from_gradient(saturation, 0.05, 0.7, color.new(trendCol, 55), trendCol)

// ┌────────────────────────────── BOSWaves ─ Band Cloud ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float bandThickness = mad * 0.5
float bandOuter     = lastSignal == 1 ? lowerPlot : upperPlot
float bandInner     = lastSignal == 1 ? lowerPlot + bandThickness : upperPlot - bandThickness

// Dimmed outer line — was linewidth=2 at full opacity, now subtle so signals dominate
pOuter = plot(showCloud ? bandOuter : na, "Band Outer", color=color.new(trendCol, 55), linewidth=1)
pClose = plot(showCloud ? close : na, "Close", color=color.new(color.white, 100))

// Dimmed fill gradient — bright edge lifted from 30 → 70 so the cloud reads as a wash
fill(pOuter, pClose,
     bandOuter, close,
     lastSignal == 1 ? color.new(bullCol, 70) : color.new(bearCol, 95),
     lastSignal == 1 ? color.new(bullCol, 95) : color.new(bearCol, 70))

// Show upper/lower bands if toggle on
plot(showBands ? upper : na, "Upper", color=color.new(color.black, 100), linewidth=1)
plot(showBands ? lower : na, "Lower", color=color.new(color.black, 79), linewidth=1)

// ┌────────────────────────────── BOSWaves ─ Candles ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
plotcandle(open, high, low, close, "Candles",
     barCol, barCol,
     bordercolor=barCol,
     display=paintBars ? display.all : display.none)

// ┌────────────────────────────── BOSWaves ─ Exhaustion Levels ──────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
type ExhLvl
    float price
    float zoneTop
    float zoneBot
    int   dir
    int   originBar
    box   zoneBox
    line  midLine
    label priceLbl
    int   lastRetest

var ExhLvl[] levels = array.new<ExhLvl>()

if exhausted and showLevels and not na(satPeakPrice) and satPeakDir != 0
    if levels.size() >= maxLevels
        ExhLvl old = levels.shift()
        box.delete(old.zoneBox)
        line.delete(old.midLine)
        label.delete(old.priceLbl)

    color lc      = satPeakDir == 1 ? bullCol : bearCol
    float halfH   = atrV * zoneHeight / 2.0
    float zTop    = satPeakPrice + halfH
    float zBot    = satPeakPrice - halfH

    // Main zone box — subtle fill, thin colored border
    box zb = box.new(satPeakBar, zTop, bar_index + 40, zBot,
         bgcolor     = color.new(lc, zoneTransp),
         border_color= color.new(lc, 55),
         border_width= 1,
         border_style= line.style_solid)

    // Mid-line through the exact peak price for precision
    line ml = line.new(satPeakBar, satPeakPrice, bar_index + 40, satPeakPrice,
         color = color.new(lc, 30),
         width = 1,
         style = line.style_dashed)

    // Right-edge price label
    label pl = label.new(bar_index + 40, satPeakPrice, str.tostring(satPeakPrice, format.mintick),
         color     = color.new(lc, 100),
         textcolor = lc,
         style     = label.style_label_left,
         size      = size.small)

    levels.push(ExhLvl.new(satPeakPrice, zTop, zBot, satPeakDir, satPeakBar, zb, ml, pl, 0))

    // Origin marker (diamond on the peak bar)
    label.new(satPeakBar, satPeakPrice, "◆",
         color     = color(na),
         textcolor = lc,
         style     = satPeakDir == 1 ? label.style_label_down : label.style_label_up,
         size      = size.small)

    satPeak      := 0.0
    satPeakPrice := na
    satPeakDir   := 0
    satPeakBar   := na

// Lifecycle: extend, detect break, detect retest
var bool bullRetestSig = false
var bool bearRetestSig = false
bullRetestSig := false
bearRetestSig := false

if levels.size() > 0
    int i = levels.size() - 1
    while i >= 0
        if i >= levels.size()
            break
        ExhLvl lvl = levels.get(i)

        float buf = atrV * breakBuffer
        // Bull-exhaustion level (above) — broken if we close above it with buffer
        // Bear-exhaustion level (below) — broken if we close below it with buffer
        bool broken = lvl.dir == 1 ? close > lvl.zoneTop + buf : close < lvl.zoneBot - buf

        if broken
            box.delete(lvl.zoneBox)
            line.delete(lvl.midLine)
            label.delete(lvl.priceLbl)
            levels.remove(i)
        else
            // Extend zone, mid-line and label
            box.set_right(lvl.zoneBox, bar_index + 40)
            line.set_x2(lvl.midLine, bar_index + 40)
            label.set_x(lvl.priceLbl, bar_index + 40)

            // Retest: price touches inside the zone
            bool touching = high >= lvl.zoneBot and low <= lvl.zoneTop
            bool cdOk     = (bar_index - lvl.lastRetest) >= retestCd

            if touching and cdOk and bar_index > lvl.originBar + 2
                if lvl.dir == 1 and close < lvl.price
                    bearRetestSig := true
                    line.new(bar_index, high, bar_index + 25, high,
                         color=color.new(bearCol, 50), style=line.style_solid, width=rtW)
                    lvl.lastRetest := bar_index
                if lvl.dir == -1 and close > lvl.price
                    bullRetestSig := true
                    line.new(bar_index, low, bar_index + 25, low,
                         color=color.new(bullCol, 50), style=line.style_solid, width=rtW)
                    lvl.lastRetest := bar_index

        i -= 1

// ┌────────────────────────────── BOSWaves ─ Trend Signals ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if showSignals and switchUp
    label.new(bar_index, low - mad * 1.5, "▲",
         style=label.style_label_up,
         size=size.normal,
         color=bullCol,
         textcolor=color.white)

if showSignals and switchDown
    label.new(bar_index, high + mad * 1.5, "▼",
         style=label.style_label_down,
         size=size.normal,
         color=bearCol,
         textcolor=color.white)

plotchar(bullRetestSig ? low  : na, "Bull Retest", "✦", location.absolute, bullCol, size=size.small)
plotchar(bearRetestSig ? high : na, "Bear Retest", "✦", location.absolute, bearCol, size=size.small)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(switchUp,       "Pulse Long",      "Exhaustion Pulse LONG {{ticker}} {{interval}}")
alertcondition(switchDown,     "Pulse Short",     "Exhaustion Pulse SHORT {{ticker}} {{interval}}")
alertcondition(exhausted,      "Exhaustion",      "Pulse exhausted — level planted {{ticker}}")
alertcondition(bullRetestSig,  "Bull Retest",     "Bullish exhaustion retest {{ticker}}")
alertcondition(bearRetestSig,  "Bear Retest",     "Bearish exhaustion retest {{ticker}}")
````
