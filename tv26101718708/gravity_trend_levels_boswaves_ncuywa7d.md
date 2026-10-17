# Gravity Trend Levels [BOSWaves]

- url: https://www.tradingview.com/script/nCUyWa7D-Gravity-Trend-Levels-BOSWaves/
- type: indicator
- pine_id: PUB;1c117e61197b42258dc62d0c4a8c0309
- version: 1.0

## Description

[b]Gravity Trend Levels [BOSWaves] - Acceleration-Derived Gravity Modeling with Adaptive Cloud Trail and Fail Level Projection[/b]

[b]Overview[/b]

Gravity Trend Levels [BOSWaves] is a momentum acceleration-based trend system that models directional gravity through the normalized rate of change of an EMA-derived velocity measurement, where cloud thickness, trail distance, and trend state are continuously adapted based on whether gravitational pull is building, sustained, or decaying rather than through fixed volatility multipliers or static band thresholds.

[image]https://www.tradingview.com/x/bvDC6Wu1/[/image]

Instead of relying on conventional moving average crossovers or ATR-scaled bands that treat all market conditions identically, trend state and cloud positioning are determined by measuring price acceleration relative to MAD-normalized volatility, converting that acceleration into a gravity score that decays exponentially when momentum diminishes and drives adaptive band interpolation between configurable tight and wide trail distances.

This creates a trend framework where the cloud reflects genuine momentum dynamics rather than arbitrary indicator levels. The cloud tightens and hugs price during high gravity periods when acceleration is strong and directional pull is confirmed, expands during gravity decay when momentum is weakening, and generates gravity fail levels at the precise price points where trend state changed, marking the exact locations where prior gravitational force collapsed and direction reversed.

Price is therefore evaluated against a cloud that continuously updates its distance from price based on measured acceleration dynamics, producing a trail that reflects the actual pull state of the current trend rather than applying a uniform band regardless of momentum conditions.

[b]Conceptual Framework[/b]

Gravity Trend Levels is founded on the principle that trend confidence should be measured through the acceleration characteristics of price momentum rather than through price position relative to fixed indicators, and that the distance between price and its trailing cloud boundary should dynamically reflect whether momentum is actively pulling price in the trend direction or losing gravitational force.

Traditional trend-following tools apply consistent band distances regardless of whether momentum is surging or stalling, producing identical visual representations for high-conviction and deteriorating trend conditions. This framework replaces uniform band geometry with an acceleration-driven gravity model where band distance shrinks under strong gravitational pull and expands as gravity decays, communicating trend health through cloud behavior rather than requiring separate momentum indicators for context.

Three core principles guide the design:
[list=1]
[*]Gravitational pull should be derived from normalized price acceleration rather than from price position alone, ensuring that cloud behavior reflects actual momentum intensity rather than the mere direction of a smoothed average.
[*]Cloud thickness and trail distance should adapt continuously to the measured pull state, contracting during strong gravity and expanding during decay to provide a visual representation of trend conviction at all times.
[*]Gravity fail levels should be projected from the precise price points where trend state changed, marking the locations where gravitational force reversed as permanent structural references for future price interaction.
[/list]
This shifts trend analysis from static band monitoring into continuous gravitational force measurement where cloud dynamics communicate momentum state and fail levels preserve the structural evidence of prior gravity collapses.

[b]Theoretical Foundation[/b]

The indicator combines EMA-based trend baseline construction, MAD volatility measurement, velocity and acceleration derivation from baseline rate of change, gravity scoring with exponential decay, and adaptive trail interpolation that maps pull strength to band distance.

The trend baseline is calculated as an EMA of close over the configured length, providing a smoothed directional reference. Velocity measures the change in baseline over the gravity lookback period, and acceleration measures the bar-to-bar change in velocity. Acceleration is normalized by MAD to produce a dimensionless score that reflects momentum change intensity relative to current volatility. When normalized acceleration exceeds the minimum threshold, gravity is set proportionally to the acceleration reading and capped at a maximum value. When acceleration falls below the threshold, gravity decays multiplicatively by the configured decay rate each bar. Pull converts gravity to a normalized 0-1 range that drives trail multiplier interpolation between the minimum tight distance and the maximum wide distance.

Four internal systems operate in tandem:
[list]
[*][i]Gravity Detection Engine[/i]: Derives velocity from EMA baseline change over the gravity lookback, calculates acceleration as the bar-to-bar velocity change, normalizes against MAD, and updates the gravity state either by setting it proportional to current acceleration or applying exponential decay when acceleration subsides.
[*][i]Adaptive Trail Construction[/i]: Converts gravity to a normalized pull value and interpolates the trail multiplier between the configured minimum and maximum settings, scaling MAD to produce upper and lower band distances from the baseline that tighten with strong pull and widen with decay.
[*][i]Gravity Cloud System[/i]: Constructs a one-sided cloud positioned below price in uptrends and above price in downtrends, with cloud thickness scaling proportionally to current pull strength through a separate MAD-scaled thickness calculation that produces a visually dynamic pull indicator.
[*][i]Gravity Fail Level Engine[/i]: On each trend state switch, projects a horizontal line from the flip bar's low for bullish flips and high for bearish flips, extending forward for the configured projection length to mark the price level where prior gravitational force collapsed and direction changed.
[/list]
This design allows the cloud and trail to respond continuously to gravity dynamics while fail levels accumulate as a historical record of structural gravity collapses.

[b]How It Works[/b]

Gravity Trend Levels evaluates price through a sequence of acceleration-aware and gravity-driven processes:
[list=1]
[*][i]Baseline Calculation[/i]: EMA smoothing of close over the configured trend length produces the directional reference from which velocity and acceleration are derived.
[*][i]MAD Volatility Measurement[/i]: Mean Absolute Deviation over the configured length provides the adaptive volatility unit that normalizes acceleration and scales all band and cloud distances.
[*][i]Velocity Derivation[/i]: The difference between the current baseline and the baseline a configurable number of bars ago provides the velocity reading that captures the rate of directional change in the smoothed trend.
[*][i]Acceleration Calculation[/i]: The bar-to-bar change in velocity produces the acceleration reading, which captures whether directional momentum is intensifying or diminishing.
[*][i]Gravity State Update[/i]: Normalized acceleration above the minimum threshold sets gravity proportionally to the acceleration magnitude scaled by eight and capped at two. Below the threshold, gravity decays by multiplying by the configured decay rate each bar.
[*][i]Pull Normalization[/i]: Gravity is divided by 1.5 and capped at one to produce a normalized pull value that maps the full gravity range to a 0-1 scale for trail interpolation.
[*][i]Trail Multiplier Interpolation[/i]: The pull value interpolates between the maximum trail distance at zero pull and the minimum trail distance at full pull, producing a continuously adapting multiplier that scales MAD into upper and lower band distances.
[*][i]Trend State Logic[/i]: Price crossing above the upper band triggers bullish state. Price crossing below the lower band triggers bearish state. State persists until the opposing band is breached.
[*][i]Cloud Construction[/i]: The active cloud positions at the lower band in uptrends and upper band in downtrends, with an inner boundary offset by a pull-scaled thickness producing a two-edge cloud whose depth visually reflects current gravitational pull.
[*][i]Gravity Fail Level Projection[/i]: On each trend switch, a horizontal line is projected from the flip bar at the bar's low for bullish flips and high for bearish flips, extending forward for the configured projection length as a structural fail reference.
[*][i]Retest Diamond Detection[/i]: After the configured signal buffer period from the most recent flip, price touching the cloud inner edge triggers a retest diamond marker with a configurable minimum bar cooldown between consecutive signals on the same side.
[/list]
Together, these elements form a continuously updating gravity-driven trend system where cloud dynamics reveal pull strength, fail levels mark structural collapse points, and retest diamonds identify price interactions with the inner cloud boundary throughout the trend.

[b]Interpretation[/b]

Gravity Trend Levels should be interpreted as a momentum-gravity conviction system with dynamically adaptive cloud geometry and structural fail level mapping:
[list]
[*][i]Bullish Trend State (Green)[/i]: Established when price closes above the upper adaptive band, with the gravity cloud positioned below price reflecting the upward gravitational pull state.
[*][i]Bearish Trend State (Red)[/i]: Established when price closes below the lower adaptive band, with the gravity cloud positioned above price reflecting the downward gravitational pull state.
[*][i]Gravity Cloud[/i]: The one-sided filled zone between the outer and inner cloud boundaries reflects current pull strength through its thickness. A thick cloud indicates strong gravitational pull with high trend conviction. A thin cloud indicates gravity decay and diminishing directional force.
[*][i]Cloud Outer Edge[/i]: The primary structural boundary of the gravity cloud, positioned at the active adaptive band and colored fully in the trend direction, representing the outer limit of the gravitational field.
[*][i]Cloud Inner Edge[/i]: The pull-scaled inner boundary of the cloud, representing the nearer edge of the gravitational zone and the threshold for retest diamond detection.
[*][i]Gravity Fail Levels[/i]: Horizontal lines projected from trend flip bars at the flip bar's low for bullish flips and high for bearish flips, marking the exact price level where prior gravitational force collapsed. These levels persist as structural references for the configured projection length.
[*][i]𝑩 Buy Signals[/i]: Green labels appearing below the bar when trend state switches from bearish to bullish, marking the gravity flip bar where upward pull has been established.
[*][i]𝑺 Sell Signals[/i]: Red labels appearing above the bar when trend state switches from bullish to bearish, marking the gravity flip bar where downward pull has been established.
[*][i]✦ Retest Diamonds[/i]: Small star diamonds plotted below bars during bullish retests and above bars during bearish retests when price touches the cloud inner edge after the signal buffer period, identifying interactions with the gravitational boundary during the trend.
[*][i]Colored Candles[/i]: Optional bar coloring reflects current trend state direction, providing continuous directional context independent of cloud proximity or signal generation. [b]Note: The original chart candles must be disabled in chart settings for the trend-colored candles to display properly.[/b]
[/list]
Cloud thickness dynamics, fail level locations, and retest diamond positioning collectively provide more information than trend direction alone.

[b]Signal Logic & Visual Cues[/b]

Gravity Trend Levels presents two primary trend transition signals alongside continuous cloud retest monitoring:
[list=1]
[*][i]Buy Signal (𝑩)[/i]: Green label appears when trend state switches from bearish to bullish via upper band crossover, indicating gravitational pull has reversed to the upside and a fail level is projected from the flip bar's low.
[*][i]Sell Signal (𝑺)[/i]: Red label appears when trend state switches from bullish to bearish via lower band crossunder, indicating gravitational pull has reversed to the downside and a fail level is projected from the flip bar's high.
[/list]
Retest diamond detection provides continuous secondary monitoring, marking price touches of the cloud inner edge throughout the established trend after the signal buffer period with per-side cooldown enforcement.

Alert generation covers bullish and bearish gravity trend flips and any retest diamond occurrence for systematic monitoring workflows.

[b]Strategy Integration[/b]

Gravity Trend Levels fits within momentum-informed and adaptive trend-following approaches:
[list]
[*][i]Gravity Flip Entries[/i]: Use trend state switches as primary entry triggers where gravitational acceleration has driven price through the adaptive band, entering in the flip direction with the projected fail level providing an immediate structural reference for invalidation.
[*][i]Cloud Thickness Conviction Reading[/i]: Monitor cloud thickness as a real-time gravity strength gauge. A thick, prominent cloud indicates strong active pull supporting the trend. A thin, contracting cloud warns of gravitational decay and warrants reduced confidence in trend continuation.
[*][i]Fail Level Framework[/i]: Use gravity fail levels as structural references for subsequent price interaction, monitoring whether price respects or violates the level where prior gravity collapsed to assess the structural significance of the most recent trend change.
[*][i]Retest Diamond Re-entry[/i]: Treat cloud inner edge retests after the signal buffer period as potential continuation opportunities within the established trend, using the diamond signal as a lower-risk re-entry reference relative to the initial flip signal.
[*][i]Cloud Proximity Risk Management[/i]: Use the outer cloud edge as a dynamic trailing reference for position management, maintaining directional bias while price remains beyond the cloud and reassessing when price approaches or enters the gravitational zone.
[*][i]Multi-Timeframe Gravity Alignment[/i]: Apply higher-timeframe gravity trend state as a directional bias filter, engaging with lower-timeframe flip signals only when they align with the established higher-timeframe gravitational direction.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Core Engine[/i]: EMA baseline with MAD volatility measurement for adaptive scaling
[*][i]Gravity Model[/i]: Velocity from baseline rate of change, acceleration from velocity change, MAD normalization, proportional gravity setting with exponential decay
[*][i]Adaptive Trail[/i]: Pull-normalized interpolation between configurable minimum and maximum MAD multipliers
[*][i]Cloud Construction[/i]: One-sided pull-scaled thickness fill between outer and inner boundaries with EMA smoothing on both edges
[*][i]Fail Levels[/i]: Flip-triggered horizontal line projection from bar extreme at configurable length and width
[*][i]Retest System[/i]: Inner cloud edge proximity detection with signal buffer and per-side cooldown enforcement
[*][i]Visualization[/i]: Gravity cloud fill, fail level lines, trend flip labels, retest diamond markers, and optional trend candle coloring
[*][i]Performance Profile[/i]: Optimized for real-time execution across all timeframes with stateful gravity variable maintaining continuous decay between acceleration events
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday gravity tracking for scalping with shorter trend length and gravity lookback for faster acceleration detection and responsive cloud behavior
[*][i]15 - 60 min[/i]: Session-level trend identification with balanced gravity decay and moderate trail settings for reliable intraday directional framing
[*][i]4H - Daily[/i]: Swing-level gravity trend mapping with longer trend length and higher decay rate for sustained gravitational pull persistence across multi-session moves
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Trend Length[/i]: 14
[*][i]Gravity Lookback[/i]: 19
[*][i]Gravity Decay[/i]: 0.96
[*][i]MAD Length[/i]: 24
[*][i]Trail Min (Strong Pull)[/i]: 1.0
[*][i]Trail Max (Weak Pull)[/i]: 1.0
[*][i]Show Gravity Cloud[/i]: Enabled
[*][i]Show Gravity Fail Levels[/i]: Enabled
[*][i]Show Buy/Sell Signals[/i]: Enabled
[*][i]Retest Diamonds[/i]: Enabled
[*][i]Color Bars[/i]: Enabled (requires disabling original chart candles in chart settings)
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's momentum characteristics, volatility behavior, and preferred signal frequency, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Cloud too wide throughout[/i]: Decrease Trail Max to reduce band distance during low gravity periods, bringing the cloud closer to price during momentum decay phases.
[*][i]Cloud too tight throughout[/i]: Increase Trail Max to allow greater band expansion during gravity decay, producing a more visually prominent cloud separation during low-conviction conditions.
[*][i]Gravity builds too slowly[/i]: Decrease Gravity Lookback toward 5 for a shorter velocity measurement window that captures acceleration shifts more rapidly, producing faster gravity activation on momentum changes.
[*][i]Gravity activates too frequently[/i]: Increase Gravity Lookback to smooth the velocity measurement across more bars, requiring more sustained directional change before acceleration registers as gravitational pull.
[*][i]Gravity decays too quickly[/i]: Increase Gravity Decay toward 0.99 to sustain gravitational pull longer between acceleration events, maintaining cloud contraction for more bars after acceleration subsides.
[*][i]Gravity lingers too long[/i]: Decrease Gravity Decay toward 0.80 for faster pull dissipation, allowing the cloud to expand more quickly when momentum weakens and reducing lag between gravity collapse and visual cloud response.
[*][i]Too many retest diamonds[/i]: Increase Retest Cooldown to enforce greater bar separation between consecutive diamond markers, or increase Signal Buffer Period to delay retest detection further from each flip event.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with clear momentum phases where gravitational acceleration builds and sustains across multiple bars, producing thick, persistent clouds that visually confirm directional pull throughout the move
[*]Instruments with consistent volatility behavior where MAD normalization accurately calibrates acceleration significance and cloud distance across varying market conditions
[*]Momentum continuation strategies where cloud retest diamonds identify lower-risk re-entry points within established gravity trends after the initial flip signal
[*]Structural reference frameworks where gravity fail levels provide meaningful historical markers at the exact price points where prior directional momentum collapsed
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, low-momentum markets where acceleration readings oscillate without sustained directional pull, producing frequent gravity flips and thin clouds that fail to establish meaningful directional framing
[*]Extremely volatile environments where individual bar acceleration spikes generate momentary gravity readings that decay before producing sustained cloud contraction or reliable trend state persistence
[*]News-driven or gap-heavy instruments where instantaneous momentum changes trigger gravity activation and immediate flip signals without the gradual acceleration buildup the model is designed to detect
[*]Consolidation and sideways conditions where velocity and acceleration remain near zero, preventing meaningful gravity generation and causing the cloud to remain in its expanded low-pull state without directional conviction
[*]Mean-reversion dominant markets where band crossovers trigger frequent state changes that repeatedly project fail levels without the subsequent directional follow-through that validates their structural significance
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves order flow tools, volume analysis, or structural indicators to validate gravity flip signals with participation context before committing to directional positions
[*][i]Cloud Thickness Monitoring[/i]: Track cloud thickness evolution throughout the trend as an ongoing gravity health assessment. Consistently thick clouds support continuation confidence while progressive thinning signals approaching decay and warrants defensive position management.
[*][i]Fail Level Awareness[/i]: Monitor price behavior when it returns to prior gravity fail levels. These levels mark the exact prices where directional force previously collapsed, making them structurally meaningful references for future support, resistance, or reversal reactions.
[*][i]Decay Anticipation[/i]: Use cloud thinning as an early warning of approaching gravity decay before a formal flip signal is generated. Thinning during an extended trend suggests acceleration is subsiding and the probability of a state change is increasing.
[*][i]State Discipline[/i]: Maintain directional bias aligned with current gravity trend state until a confirmed band crossover flip occurs. Cloud retests and fail level interactions within an established trend do not constitute state changes and should be interpreted as continuation context rather than reversal signals.
[/list]
[b]Disclaimer[/b]

Gravity Trend Levels [BOSWaves] is a professional-grade momentum acceleration and trend conviction analysis tool. It uses acceleration-derived gravity modeling with adaptive cloud construction and structural fail level projection but does not predict future price movements. Results depend on market conditions, instrument momentum characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, volume analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Gravity Trend Levels [BOSWaves]", overlay=true, max_labels_count=500, max_lines_count=500)

// ┌────────────────────────────── BOSWaves ─ Constants ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Core Engine"
const string g2 = "Gravity Model"
const string g3 = "Signals & Display"

color BULL = #00FF00
color BEAR = #FF0000

// ┌────────────────────────────── BOSWaves ─ Tooltips ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string tt_len       = "Baseline smoothing length. Higher = smoother trend, fewer flips."
const string tt_gravLen   = "Lookback for gravity detection. Lower = more reactive to acceleration shifts."
const string tt_decay     = "How fast gravity fades when acceleration drops. Higher = gravity lingers longer."
const string tt_madLen    = "MAD lookback for volatility sizing. Higher = smoother trail."
const string tt_trailMin  = "Trail distance during strong gravity. Lower = cloud hugs price tighter."
const string tt_trailMax  = "Trail distance during weak gravity. Higher = cloud drifts further from price."
const string tt_cloud     = "Show the one-sided gravity cloud beneath price in uptrends, above in downtrends."
const string tt_bars      = "Color candles by current trend direction."
const string tt_signals   = "Show Buy/Sell labels on trend switches."
const string tt_levels    = "Project horizontal levels from where gravity failed — the flip points."
const string tt_levelLen  = "How many bars forward the gravity-fail levels extend."
const string tt_levelW    = "Line width for gravity-fail levels."
const string tt_dots      = "Diamond markers when price retests the gravity cloud."
const string tt_dotCD     = "Minimum bars between consecutive retest diamonds."
const string tt_sigBuf    = "Bars to wait after a flip before retest diamonds can fire."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
int    len         = input.int(14, "Trend Length", minval=5, group=g1, tooltip=tt_len)
int    gravLen     = input.int(19, "Gravity Lookback", minval=1, group=g2, tooltip=tt_gravLen)
float  decayRate   = input.float(0.96, "Gravity Decay", minval=0.80, maxval=0.99, step=0.01, group=g2, tooltip=tt_decay)
int    madLen      = input.int(24, "MAD Length", minval=5, group=g2, tooltip=tt_madLen)
float  trailMin    = input.float(1.0, "Trail Min (Strong Pull)", minval=0.3, step=0.1, group=g2, tooltip=tt_trailMin)
float  trailMax    = input.float(1, "Trail Max (Weak Pull)", minval=1.0, step=0.1, group=g2, tooltip=tt_trailMax)

bool   showCloud   = input.bool(true, "Show Gravity Cloud", group=g3, tooltip=tt_cloud)
bool   paintBars   = input.bool(true, "Color Bars", group=g3, tooltip=tt_bars)
bool   showSignals = input.bool(true, "Show Buy/Sell Signals", group=g3, tooltip=tt_signals)
bool   showLevels  = input.bool(true, "Show Gravity Fail Levels", group=g3, tooltip=tt_levels)
int    levelLen    = input.int(50, "Level Projection Length", minval=10, group=g3, tooltip=tt_levelLen)
int    levelW      = input.int(4, "Level Line Width", minval=1, group=g3, tooltip=tt_levelW)
bool   showDots    = input.bool(true, "Retest Diamonds", group=g3, tooltip=tt_dots)
int    dotCooldown = input.int(12, "Retest Cooldown", minval=0, group=g3, tooltip=tt_dotCD)
int    signalBuffer = input.int(10, "Signal Buffer Period", minval=1, maxval=30, group=g3, tooltip=tt_sigBuf)
color  bullCol     = input.color(BULL, "Bullish", inline="col", group=g3)
color  bearCol     = input.color(BEAR, "Bearish", inline="col", group=g3)

// ┌────────────────────────────── BOSWaves ─ State ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var float gravity    = 0.0
var int   lastSignal = 0
var int   lastBullDot = na
var int   lastBearDot = na
var int   lastSignalBar = 0

// ┌────────────────────────────── BOSWaves ─ Core Calculations ──────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float basisC = ta.ema(close, len)
float basisO = ta.ema(open, len)
float basis  = basisC

// Volatility — Mean Absolute Deviation
float mean = ta.sma(close, madLen)
float mad  = ta.sma(math.abs(close - mean), madLen)

// ┌────────────────────────────── BOSWaves ─ Gravity Detection ──────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float velocity  = basis - basis[gravLen]
float accel     = velocity - nz(velocity[1])
float normAccel = mad > 0 ? math.abs(accel) / mad : 0.0

if normAccel > 0.01
    gravity := math.min(normAccel * 8.0, 2.0)
else
    gravity := gravity * decayRate

float pull = math.min(gravity / 1.5, 1.0)

// ┌────────────────────────────── BOSWaves ─ Adaptive Trail ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float trailMult = trailMax - (trailMax - trailMin) * pull
float upper     = basis + mad * trailMult
float lower     = basis - mad * trailMult

// ┌────────────────────────────── BOSWaves ─ Signal Logic ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool longCond  = ta.crossover(close, upper)
bool shortCond = ta.crossunder(close, lower)

int prevSignal = lastSignal
lastSignal := longCond ? 1 : shortCond ? -1 : lastSignal

bool  switchUp   = lastSignal == 1 and prevSignal == -1
bool  switchDown = lastSignal == -1 and prevSignal == 1
color trendCol   = lastSignal == 1 ? bullCol : bearCol

if switchUp or switchDown
    lastSignalBar := bar_index

// ┌────────────────────────────── BOSWaves ─ Candles ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
plotcandle(open, high, low, close, "Candles",
     trendCol, trendCol,
     bordercolor=trendCol,
     display=paintBars ? display.all : display.none)

// ┌────────────────────────────── BOSWaves ─ Gravity Cloud ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float cloudThick = mad * (0.3 + 0.5 * pull)
float cloudOuter = lastSignal == 1 ? lower : upper
float cloudInner = lastSignal == 1 ? lower + cloudThick : upper - cloudThick

float cloudOuterVis = ta.ema(cloudOuter, 5)
float cloudInnerVis = ta.ema(cloudInner, 5)

pOuter = plot(showCloud ? cloudOuterVis : na, "Cloud Outer", color=trendCol, linewidth=2)
pInner = plot(showCloud ? cloudInnerVis : na, "Cloud Inner", color=color.new(trendCol, 70), linewidth=1)

fill(pOuter, pInner, cloudOuter, cloudInner,
     lastSignal == 1 ? color.new(bullCol, 30) : color.new(bearCol, 80),
     lastSignal == 1 ? color.new(bullCol, 80) : color.new(bearCol, 30))

// ┌────────────────────────────── BOSWaves ─ Gravity Fail Levels ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if showLevels and switchUp
    line.new(bar_index, low, bar_index + levelLen, low,
         color=color.new(bullCol, 40), style=line.style_solid, width=levelW)

if showLevels and switchDown
    line.new(bar_index, high, bar_index + levelLen, high,
         color=color.new(bearCol, 40), style=line.style_solid, width=levelW)

// ┌────────────────────────────── BOSWaves ─ Retest Diamonds ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool farEnough = bar_index - lastSignalBar >= signalBuffer

bool bullRetest = showDots and lastSignal == 1  and low  < cloudInner and farEnough
bool bearRetest = showDots and lastSignal == -1 and high > cloudInner and farEnough

bool bullDotOk = bullRetest and (na(lastBullDot) or bar_index - lastBullDot >= dotCooldown)
bool bearDotOk = bearRetest and (na(lastBearDot) or bar_index - lastBearDot >= dotCooldown)

if bullDotOk
    lastBullDot := bar_index
if bearDotOk
    lastBearDot := bar_index

plotchar(bullDotOk, title="Bull Retest", char="✦", location=location.belowbar, color=bullCol, size=size.tiny)
plotchar(bearDotOk, title="Bear Retest", char="✦", location=location.abovebar, color=bearCol, size=size.tiny)

// ┌────────────────────────────── BOSWaves ─ Signals ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if showSignals and switchUp
    label.new(bar_index, low - mad * 1.5, "𝑩",
         style=label.style_label_up,
         size=size.normal,
         color=bullCol,
         textcolor=color.black)

if showSignals and switchDown
    label.new(bar_index, high + mad * 1.5, "𝑺",
         style=label.style_label_down,
         size=size.normal,
         color=bearCol,
         textcolor=color.white)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(switchUp, "Gravity Long", "Gravity Trail LONG {{ticker}} {{interval}}")
alertcondition(switchDown, "Gravity Short", "Gravity Trail SHORT {{ticker}} {{interval}}")
alertcondition(bullDotOk or bearDotOk, "Gravity Retest", "Gravity Trail Retest {{ticker}} {{interval}}")
````
