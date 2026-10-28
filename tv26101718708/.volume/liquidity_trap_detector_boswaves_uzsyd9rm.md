# Liquidity Trap Detector [BOSWaves]

- url: https://www.tradingview.com/script/UZSYd9RM-Liquidity-Trap-Detector-BOSWaves/
- type: indicator
- pine_id: PUB;94c39e644b6548ae96bbfb808fd9fada
- version: 1.0

## Description

[b]Liquidity Trap Detector [BOSWaves] - Failed Breakout Detection with Trapped Volume Measurement, DEMA Trend Filtering, and Trend-Aligned Zone Retests[/b]

[b]Overview[/b]

Liquidity Trap Detector [BOSWaves] is a failed breakout detection system that tracks confirmed swing highs and lows as liquidity levels, identifies breakouts that close beyond those levels by an ATR-based buffer, and confirms a trap when price closes back through the broken level within a configurable window. Each confirmed trap is converted into a zone spanning the broken level and the most extreme price reached during the failed breakout, labeled with the total volume transacted while participants were on the wrong side of the move.

[image]https://www.tradingview.com/x/i0S5fi3G/[/image]

Instead of treating every breakout as a continuation signal, each break of a swing level is monitored for acceptance or rejection. If price holds beyond the level for the full trap window, the breakout is accepted and the level is discarded. If price closes back through the level within the window, the breakout has failed, the participants who entered on the break are now trapped, and a zone is created to mark where that trapped positioning sits. A DEMA-based trend engine runs alongside the trap logic, providing directional context through a layered gradient, trend-colored candles, and flip markers, and filtering zone retest signals so that only retests aligned with the prevailing trend are marked on the chart.

This creates a liquidity framework that bridges level detection, trap confirmation, and trend context within a single indicator. The trap zones show where breakout traders were caught, the trapped volume reading quantifies how much participation was involved, and the trend engine identifies which of those zones are positioned to act in the direction of the broader move when price returns to them.

Price is therefore evaluated not just for whether it broke a level, but for whether that break was accepted or rejected, how much volume was caught on the wrong side, and whether a return to the resulting zone aligns with the prevailing trend.

[b]Conceptual Framework[/b]

Liquidity Trap Detector is founded on the principle that a failed breakout is often more informative than a successful one. When price breaks a swing level and quickly reverses back through it, the participants who bought the breakout or sold the breakdown are left holding losing positions, and the zone where they entered becomes a reference for future reactions.

Traditional breakout tools mark the break itself and leave the trader to judge whether it will follow through. This framework closes that gap by tracking every break through a defined acceptance window, confirming only the breakouts that fail, measuring the volume transacted during the failed move, and maintaining each resulting trap zone until it is either retested or invalidated. A separate trend engine supplies directional context, so trap zones can be evaluated relative to the broader move rather than in isolation.

Three core principles guide the design:
[list=1]
[*]A breakout should only be classified as a trap when price closes beyond a confirmed swing level by a measurable ATR buffer and then closes back through that level within a defined window, separating genuine failed breakouts from minor wicks and noise.
[*]The significance of each trap should be quantified by the volume transacted from the breakout bar through the confirmation bar, providing a direct measure of how much participation was caught on the wrong side of the move.
[*]Trap zone retests should be filtered by the prevailing trend, so that only returns to zones positioned in the direction of the broader move are highlighted as actionable reactions.
[/list]
This shifts breakout analysis from a binary break or no-break reading into a structured assessment of breakout failure, trapped participation, and trend-aligned zone interaction.

[b]Theoretical Foundation[/b]

The indicator combines double exponential moving average calculation for trend baseline construction, ATR-scaled flip thresholds with slope confirmation for trend state, pivot-based swing detection for liquidity level identification, ATR-buffered breakout detection, window-bounded failure confirmation, cumulative volume measurement across the failed move, zone construction from the broken level to the excursion extreme, and an armed retest system that requires price to clear a zone before a return to it is registered.

The trend baseline is a DEMA of the HLC3 source with optional additional EMA smoothing. The trend flips bullish only when price closes above the baseline plus the configured ATR multiple while the baseline is rising, and flips bearish only when price closes below the baseline minus the configured ATR multiple while the baseline is falling. Breakouts require a close beyond the swing level plus the ATR break buffer, while trap confirmation only requires a close back through the level itself, so the rejection condition is less demanding than the breakout condition.

Four internal systems operate in tandem:
[list]
[*][i]DEMA Trend Engine[/i]: Calculates the DEMA baseline from HLC3 with optional smoothing, derives upper and lower flip thresholds from a long-period ATR, and flips trend state only when price closes beyond the threshold with the baseline sloping in the new direction. Trend state drives the gradient, candle coloring, flip markers, and retest filtering.
[*][i]Level Tracking System[/i]: Detects swing highs and lows using the configured swing length, stores up to the configured number of levels per side with the oldest discarded first, removes unbroken levels that exceed the maximum age, and monitors each level for an ATR-buffered breakout.
[*][i]Trap Confirmation Engine[/i]: Once a level breaks, tracks the most extreme price reached and accumulates volume on every bar of the excursion. If price closes back through the level within the trap window, the trap is confirmed and a zone is created. If the window expires without a return, the breakout is accepted and the level is discarded.
[*][i]Zone Management System[/i]: Stores active trap zones per side up to the configured limit, optionally replaces overlapping zones, removes zones when price closes beyond the mitigation level, and tracks an armed state so that a retest is registered only after price has fully cleared the zone and then returned to it.
[/list]
This design ensures that trap detection, trapped volume measurement, and trend context are evaluated together, while zone management keeps only the most recent valid zones on the chart.

[b]How It Works[/b]

Liquidity Trap Detector evaluates price through a sequence of trend, level, and trap processes:
[list=1]
[*][i]DEMA Baseline[/i]: A double exponential moving average of HLC3 is calculated over the configured length, with optional EMA smoothing applied to the result.
[*][i]Trend Flip Detection[/i]: A bullish flip requires a close above the baseline plus the flip threshold ATR multiple while the baseline is rising. A bearish flip requires a close below the baseline minus the flip threshold while the baseline is falling. The initial trend is set by the close relative to the baseline.
[*][i]Trend Gradient[/i]: Five fill layers extend from the baseline away from price by the configured gradient width in ATR, drawn below the baseline in bullish trends and above it in bearish trends, with opacity fading from the baseline outward.
[*][i]Level Detection[/i]: Swing highs and lows are confirmed when a bar's high or low is the extreme across the configured swing length on both sides, introducing a confirmation delay equal to the swing length. Each confirmed swing is stored as a liquidity level.
[*][i]Breakout Detection[/i]: A swing high is broken when price closes above it by more than the break buffer multiplied by ATR. A swing low is broken when price closes below it by the same margin. The breakout bar's high or low and its volume are recorded.
[*][i]Excursion Tracking[/i]: On each subsequent bar, the most extreme price reached beyond the level is updated and the bar's volume is added to the trapped volume total.
[*][i]Trap Confirmation[/i]: If price closes back through the broken level within the trap window, the trap is confirmed. A failed break above a swing high is a bull trap. A failed break below a swing low is a bear trap.
[*][i]Breakout Acceptance[/i]: If the trap window expires without a close back through the level, the breakout is treated as accepted and the level is discarded without creating a zone.
[*][i]Zone Construction[/i]: Each trap creates a zone from the broken level to the excursion extreme, starting at the breakout bar. When Hide Overlap is enabled, an existing same-side zone that overlaps the new one is removed. The oldest zone is removed once the per-side limit is exceeded.
[*][i]Mitigation[/i]: In Absolute mode, a bull trap zone is invalidated when price closes above its top and a bear trap zone when price closes below its bottom. In Middle mode, a close beyond the zone midpoint invalidates it. Invalidated zones are removed from the chart.
[*][i]Retest Detection[/i]: A zone becomes armed once a bar trades entirely outside it on the side price returned to. The next bar that touches the zone registers a retest and disarms it until price clears the zone again. Retest markers are plotted only when the retest aligns with the current trend.
[*][i]Zone Rendering[/i]: Each zone is drawn with gradient layers that are most opaque at the broken level and fade toward the trap extreme, a solid trigger line at the broken level, a faint far-edge line at the trap extreme, and the trap type with trapped volume displayed in the projected section of the zone.
[/list]
Together, these elements form a continuously updating map of failed breakouts, trapped participation, and trend context, with retests filtered to the direction of the prevailing move.

[b]Interpretation[/b]

Liquidity Trap Detector should be interpreted as a failed breakout framework with an attached trend filter:
[list]
[*][i]Bull Trap Zone (Red/Pink)[/i]: Created when price breaks above a swing high and closes back below it within the trap window. The zone spans the broken swing high to the highest price reached during the failed breakout, marking where breakout buyers were trapped.
[*][i]Bear Trap Zone (Green)[/i]: Created when price breaks below a swing low and closes back above it within the trap window. The zone spans the broken swing low to the lowest price reached during the failed breakdown, marking where breakdown sellers were trapped.
[*][i]Trigger Line[/i]: The solid line at the broken swing level, representing the edge of the zone nearest to current price and the level that price closed back through to confirm the trap.
[*][i]Far Edge[/i]: The faint line at the trap extreme, representing the furthest point of the failed breakout. In Absolute mitigation mode, a close beyond this edge invalidates the zone.
[*][i]Zone Gradient[/i]: Layers inside each zone are most opaque at the trigger line and fade toward the far edge, emphasizing the broken level as the primary reaction reference within the zone.
[*][i]Trapped Volume[/i]: The figure displayed inside each zone shows the total volume transacted from the breakout bar through the confirmation bar, abbreviated in thousands, millions, or billions. Higher readings indicate greater participation caught on the wrong side of the move.
[*][i]Trend Gradient[/i]: The layered fill beside the DEMA baseline shows the current trend direction, positioned below the baseline in bullish trends and above it in bearish trends.
[*][i]Candle Coloring[/i]: Candles are colored by the current trend state, providing a bar-level reading of the prevailing direction.
[*][i]Zone Removal[/i]: Zones disappear from the chart when they are mitigated, replaced by an overlapping zone, or pushed out by the per-side zone limit.
[/list]
Trap zones, trapped volume, and trend state collectively communicate more breakout and liquidity context than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Liquidity Trap Detector presents two signal types on the chart:
[list=1]
[*][i]Trend Flip Signals (▲ / ▼)[/i]: Green triangle below the bar when the trend flips bullish and red triangle above the bar when the trend flips bearish, each requiring a close beyond the ATR flip threshold with the DEMA baseline sloping in the new direction.
[*][i]Trend-Aligned Retest Signals (✦)[/i]: Green marker at the bar low when price retests an armed bear trap zone during a bullish trend, and red marker at the bar high when price retests an armed bull trap zone during a bearish trend.
[/list]
Trap confirmation itself is shown by the appearance of a new zone rather than a separate marker. Retests of zones that run against the current trend are not marked on the chart.

Alert generation covers bullish and bearish trend flips, bull trap and bear trap confirmations, and trap zone retests. The retest alert fires on any retest regardless of trend direction, while the chart markers show only trend-aligned retests.

[b]Strategy Integration[/b]

Liquidity Trap Detector fits within liquidity sweep, failed breakout, and trend-continuation pullback approaches:
[list=1]
[*][i]Trend-Aligned Trap Retests[/i]: Use the retest markers as the primary reaction signals. A bear trap zone retested during a bullish trend combines trapped selling below the level with a supportive trend, while a bull trap zone retested during a bearish trend combines trapped buying above the level with a declining trend.
[*][i]Trapped Volume Weighting[/i]: Compare trapped volume readings across active zones. Zones created from failed breakouts with heavy participation carry more significance than zones created from low-volume excursions.
[*][i]Breakout Validation[/i]: Use trap confirmations as evidence against continuation. A swing level that is broken and then reclaimed within the window suggests the breakout lacked acceptance, warranting caution before trading in the direction of the original break.
[*][i]Defined Invalidation[/i]: Use the far edge of each zone as a structural reference for invalidation. In Absolute mode, a close beyond the trap extreme removes the zone, indicating the trapped positioning has been resolved.
[*][i]Trend Context for Counter-Trend Traps[/i]: Treat trap zones that oppose the current trend as context rather than signals. Their retests are excluded from the chart markers, and they are more likely to be mitigated if the prevailing trend continues.
[*][i]Multi-Timeframe Liquidity Alignment[/i]: Apply higher-timeframe trap zones and trend state as the primary reference, engaging with lower-timeframe retests only when they occur in the same direction as the higher-timeframe structure.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Trend Engine[/i]: DEMA of HLC3 with optional EMA smoothing; long-period ATR flip thresholds; baseline slope confirmation required for each trend flip
[*][i]Level System[/i]: Pivot-based swing high and low detection; per-side level storage with oldest-first removal; age-based expiry for unbroken levels
[*][i]Trap Engine[/i]: ATR-buffered breakout detection; excursion extreme tracking; cumulative volume from breakout bar through confirmation bar; window-bounded failure confirmation with acceptance-based level removal
[*][i]Zone System[/i]: Zones from broken level to excursion extreme; optional same-side overlap replacement; per-side zone limit; Absolute or Middle mitigation with removal on invalidation
[*][i]Retest System[/i]: Armed state set when price fully clears a zone; retest registered on the next touch; re-arming required between retests; chart markers filtered by trend state
[*][i]Visualization[/i]: Five-layer trend gradient; trend-colored candles; flip triangles; configurable gradient layers within each zone; trigger and far-edge lines; projected zone extension with trap type and abbreviated trapped volume text
[*][i]Performance Profile[/i]: Level, trap, mitigation, and retest logic evaluated on every bar; zone drawing objects created when a trap is confirmed, positioned on the last bar, and deleted when a zone is removed
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday liquidity sweep detection with shorter swing length and a tight trap window to capture fast stop runs and rapid reclaims
[*][i]15 - 60 min[/i]: Session-level failed breakout analysis with balanced swing length and moderate break buffer for meaningful level selection across typical session moves
[*][i]4H - Daily[/i]: Swing-level trap identification with longer swing length and a wider trap window to allow slower failed breakouts to develop before confirmation
[/list]
Suggested Baseline Configuration:
[list]
[*][i]DEMA Length[/i]: 26
[*][i]DEMA Smoothing[/i]: 2
[*][i]Trend ATR Length[/i]: 78
[*][i]Flip Threshold ATR[/i]: 2.55
[*][i]Gradient Width ATR[/i]: 0.8
[*][i]Swing Length[/i]: 5
[*][i]Levels Per Side[/i]: 6
[*][i]Level Max Age[/i]: 300
[*][i]Trap ATR Length[/i]: 14
[*][i]Break Buffer[/i]: 0.1
[*][i]Trap Window[/i]: 5
[*][i]Zones Per Side[/i]: 4
[*][i]Mitigation[/i]: Absolute
[*][i]Hide Overlap[/i]: Enabled
[*][i]Zone Extension[/i]: 40
[*][i]Trap Gradient Layers[/i]: 4
[*][i]Show Trend Gradient[/i]: Enabled
[*][i]Color Candles[/i]: Enabled (requires disabling original chart candles in chart settings)
[*][i]Show Trend Flips[/i]: Enabled
[*][i]Show Trap Text[/i]: Enabled
[*][i]Show Trapped Volume[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, swing structure frequency, volume data quality, and preferred signal sensitivity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Too many traps[/i]: Increase Break Buffer to require a more decisive breakout before monitoring begins, increase Swing Length so only more significant levels are tracked, or decrease Trap Window so only rapid reclaims qualify as traps.
[*][i]Too few traps[/i]: Decrease Break Buffer toward 0 so smaller breaks are monitored, increase Trap Window to allow slower failures, or increase Levels Per Side and Level Max Age so more levels remain eligible.
[*][i]Zones invalidated too quickly[/i]: Use Absolute mitigation so zones remain active until price closes beyond the trap extreme rather than the midpoint.
[*][i]Zones persisting too long[/i]: Use Middle mitigation so zones are removed once price closes through half of the zone.
[*][i]Chart too cluttered[/i]: Reduce Zones Per Side and keep Hide Overlap enabled so overlapping zones are consolidated.
[*][i]Trend flipping too often[/i]: Increase Flip Threshold ATR or DEMA Length to require stronger, more sustained displacement before the trend changes.
[*][i]Trend too slow to flip[/i]: Decrease Flip Threshold ATR or DEMA Length. The default threshold is deliberately wide relative to a long-period ATR, so the trend responds to sustained moves rather than short-term swings.
[*][i]Few retest markers[/i]: Retest markers are only plotted when the retest aligns with the current trend. Use the Trap Retest alert to monitor all retests regardless of direction.
[*][i]Trapped volume not displayed[/i]: The volume reading only appears when the instrument provides volume data and Show Trap Text is enabled.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Markets where price frequently sweeps swing highs and lows before reversing, producing clear failed breakouts with defined excursion extremes
[*]Trending markets with pullbacks into trap zones that formed in the direction of the trend, where trend-aligned retests combine trapped positioning with directional support
[*]Instruments with reliable volume data, where the trapped volume reading provides a meaningful comparison of participation across zones
[*]Liquidity-driven environments where stop runs beyond obvious swing levels are common and quickly reclaimed
[/list]
Reduced Effectiveness:
[list]
[*]Strong impulsive trends where breakouts are consistently accepted, producing few traps, while counter-trend trap zones are frequently mitigated
[*]Instruments without volume data, where the trapped volume metric is unavailable and zones must be assessed by structure alone
[*]Very low volatility environments where the ATR-based break buffer is small, allowing minor breaks and reclaims to qualify as traps
[*]Gap-heavy or news-driven instruments where breaks and reclaims occur through gaps, producing oversized zones with extremes that do not reflect tradable prices
[*]Choppy markets where the trend engine lags rapid direction changes, filtering out retests that would otherwise be marked
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural, momentum, or order flow tools to validate trap zone reactions and assess whether retests align with broader market context
[*][i]Volume Assessment[/i]: Compare trapped volume across active zones before prioritizing reactions. Zones with substantially higher trapped volume reflect larger failed participation and warrant greater attention.
[*][i]Trend Discipline[/i]: Favor retests that align with the current trend state. Counter-trend trap zones remain useful as context but are excluded from retest markers by design.
[*][i]Mitigation Awareness[/i]: Note the selected mitigation mode when evaluating zones. Middle mode removes zones earlier, while Absolute mode keeps them active until the trap extreme is breached.
[*][i]Retest Sequencing[/i]: Each retest disarms the zone until price clears it again. A zone that has already been retested multiple times may carry less remaining trapped positioning than a fresh zone receiving its first retest.
[/list]
[b]Disclaimer[/b]

Liquidity Trap Detector [BOSWaves] is a professional-grade failed breakout detection and liquidity zone visualization tool. It uses ATR-buffered breakout monitoring, trapped volume measurement, and DEMA trend filtering but does not predict future price movements. Results depend on market conditions, instrument liquidity characteristics, volume data quality, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Liquidity Trap Detector [BOSWaves]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ┌────────────────────────────── BOSWaves ─ Constants ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Trend Engine"
const string g2 = "Level Detection"
const string g3 = "Trap Logic"
const string g4 = "Zone Construction"
const string g5 = "Visualization"

color BULL = #00FF00
color BEAR = #FF0066

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

// ─────────────────── Trend Engine ───────────────────
int trendLen      = input.int(26, "DEMA Length", minval = 5, group = g1,
     tooltip = "Number of bars used to calculate the DEMA trend baseline. Higher values produce a smoother, slower baseline.")
int trendSmooth   = input.int(2, "DEMA Smoothing", minval = 1, maxval = 10, group = g1,
     tooltip = "Additional EMA smoothing applied to the DEMA baseline. A value of 1 disables the extra smoothing.")
int trendAtrLen   = input.int(78, "ATR Length", minval = 5, group = g1,
     tooltip = "Number of bars used to calculate the Average True Range for the trend flip thresholds and gradient width.")
float trendBand   = input.float(2.55, "Flip Threshold ATR", minval = 0.25, maxval = 3.0, step = 0.05, group = g1,
     tooltip = "Distance from the DEMA baseline, as a multiple of ATR, that price must close beyond to flip the trend. The baseline must also be sloping in the new direction. Higher values require stronger displacement.")
float cloudWidth  = input.float(0.8, "Gradient Width ATR", minval = 0.20, maxval = 2.0, step = 0.05, group = g1,
     tooltip = "Width of the trend gradient drawn from the DEMA baseline, as a multiple of ATR.")

// ─────────────────── Level Detection ───────────────────
int swingLen      = input.int(5, "Swing Length", minval = 2, maxval = 30, group = g2,
     tooltip = "Number of bars on each side required to confirm a swing high or low used as a breakout level.")
int maxLevels     = input.int(6, "Levels Per Side", minval = 1, maxval = 20, group = g2,
     tooltip = "Maximum number of swing levels tracked on each side. The oldest level is discarded when a new one forms.")
int maxAge        = input.int(300, "Level Max Age (bars)", minval = 20, maxval = 2000, group = g2,
     tooltip = "Maximum number of bars an unbroken swing level is tracked after it forms before it is discarded.")

// ─────────────────── Trap Logic ───────────────────
int atrLen        = input.int(14, "ATR Length", minval = 1, group = g3,
     tooltip = "Number of bars used to calculate the Average True Range for the breakout buffer.")
float breakBuf    = input.float(0.1, "Break Buffer (ATR)", minval = 0.0, step = 0.05, group = g3,
     tooltip = "Distance beyond the level, as a multiple of ATR, that price must close to register a breakout. Higher values require a more decisive break.")
int trapWindow    = input.int(5, "Trap Window (bars)", minval = 1, maxval = 30, group = g3,
     tooltip = "Maximum number of bars after a breakout for price to close back through the level. If it does, a trap is confirmed. If it doesn't, the breakout is accepted and the level is discarded.")

// ─────────────────── Zone Construction ───────────────────
int maxZones      = input.int(4, "Zones Per Side", minval = 1, maxval = 10, group = g4,
     tooltip = "Maximum number of active trap zones displayed on each side. The oldest zone is removed when a new one forms.")
string mitigation = input.string("Absolute", "Mitigation", options = ["Absolute", "Middle"], group = g4,
     tooltip = "Defines when a trap zone is invalidated and removed. Absolute requires a close beyond the trap extreme. Middle requires a close beyond the zone midpoint.")
bool hideOverlap  = input.bool(true, "Hide Overlap", group = g4,
     tooltip = "When enabled, a new trap zone replaces an existing zone on the same side that it overlaps.")
int extendBars    = input.int(40, "Zone Extension", minval = 10, maxval = 500, step = 10, group = g4,
     tooltip = "Number of bars the trap zones and level lines are projected forward from the current bar.")

// ─────────────────── Visualization ───────────────────
bool showTrend    = input.bool(true, "Show Trend Gradient", group = g5,
     tooltip = "Toggles visibility of the DEMA trend gradient.")
bool paintBars    = input.bool(true, "Color Candles", group = g5,
     tooltip = "Toggles coloring of candles based on the current trend direction.")
bool showSignals  = input.bool(true, "Show Trend Flips", group = g5,
     tooltip = "Toggles triangle markers on bullish and bearish trend flips.")
bool showLabel    = input.bool(true, "Show Trap Text", group = g5,
     tooltip = "Toggles the BULL TRAP and BEAR TRAP text inside each zone.")
bool showMetric   = input.bool(true, "Show Trapped Volume", group = g5,
     tooltip = "Toggles the trapped volume reading beneath the trap text. Requires Show Trap Text to be enabled and volume data on the instrument.")
color bullCol     = input.color(BULL, "Bear Trap / Bull Trend", inline = "col", group = g5,
     tooltip = "Color used for bear trap zones, bullish trend elements, and bullish retest markers.")
color bearCol     = input.color(BEAR, "Bull Trap / Bear Trend", inline = "col", group = g5,
     tooltip = "Color used for bull trap zones, bearish trend elements, and bearish retest markers.")
int gradRows      = input.int(4, "Trap Gradient Layers", minval = 2, maxval = 6, group = g5,
     tooltip = "Number of gradient layers inside each trap zone. Layers are most opaque at the broken level and fade toward the trap extreme.")

// ┌────────────────────────────── BOSWaves ─ DEMA Trend ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float src = hlc3
float ema1 = ta.ema(src, trendLen)
float ema2 = ta.ema(ema1, trendLen)
float demaRaw = 2.0 * ema1 - ema2
float basis = trendSmooth > 1 ? ta.ema(demaRaw, trendSmooth) : demaRaw
float tAtr = ta.atr(trendAtrLen)

float upperFlip = basis + tAtr * trendBand
float lowerFlip = basis - tAtr * trendBand

var int trend = 0

if trend == 0
    trend := close >= basis ? 1 : -1
else if trend == -1 and close > upperFlip and basis > basis[1]
    trend := 1
else if trend == 1 and close < lowerFlip and basis < basis[1]
    trend := -1

bool switchUp = trend == 1 and trend[1] == -1
bool switchDown = trend == -1 and trend[1] == 1
color trendCol = trend == 1 ? bullCol : bearCol

// ┌────────────────────────────── BOSWaves ─ Trend Gradient ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float cloud = tAtr * cloudWidth

float c0 = basis
float c1 = trend == 1 ? basis - cloud * 0.20 : basis + cloud * 0.20
float c2 = trend == 1 ? basis - cloud * 0.40 : basis + cloud * 0.40
float c3 = trend == 1 ? basis - cloud * 0.60 : basis + cloud * 0.60
float c4 = trend == 1 ? basis - cloud * 0.80 : basis + cloud * 0.80
float c5 = trend == 1 ? basis - cloud : basis + cloud

p0 = plot(showTrend ? c0 : na, color=color.new(trendCol, 100))
p1 = plot(showTrend ? c1 : na, color=color.new(trendCol, 100))
p2 = plot(showTrend ? c2 : na, color=color.new(trendCol, 100))
p3 = plot(showTrend ? c3 : na, color=color.new(trendCol, 100))
p4 = plot(showTrend ? c4 : na, color=color.new(trendCol, 100))
p5 = plot(showTrend ? c5 : na, color=color.new(trendCol, 100))

fill(p0, p1, color=color.new(trendCol, 22))
fill(p1, p2, color=color.new(trendCol, 32))
fill(p2, p3, color=color.new(trendCol, 44))
fill(p3, p4, color=color.new(trendCol, 57))
fill(p4, p5, color=color.new(trendCol, 72))

barcolor(paintBars ? trendCol : na)

plotshape(showSignals and switchUp, title="Bull Trend", style=shape.triangleup, location=location.belowbar, color=bullCol, size=size.tiny)
plotshape(showSignals and switchDown, title="Bear Trend", style=shape.triangledown, location=location.abovebar, color=bearCol, size=size.tiny)

// ┌────────────────────────────── BOSWaves ─ Types ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
type Level
    float price
    int pivBi
    bool isHigh
    bool broken
    int breakBi
    int breakT
    float extreme
    float trapVol

type TrapZone
    float top
    float btm
    float trig
    float total_vol
    int left_time
    bool bearish
    bool armed

type TrapDraw
    box ob
    box eOB
    array<box> gradBoxes
    line trigLn
    line trigExt
    line farLn
    line farExt

// ┌────────────────────────────── BOSWaves ─ Variables ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var Level[] highLevels = array.new<Level>()
var Level[] lowLevels = array.new<Level>()

var TrapZone[] bullTraps = array.new<TrapZone>()
var TrapZone[] bearTraps = array.new<TrapZone>()

var TrapDraw[] bullDraws = array.new<TrapDraw>()
var TrapDraw[] bearDraws = array.new<TrapDraw>()

float atr = ta.atr(atrLen)
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

// ┌────────────────────────────── BOSWaves ─ Helpers ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_vol_text(float v) =>
    v >= 1000000000 ? str.tostring(math.round(v / 1000000000, 2)) + "B" :
     v >= 1000000 ? str.tostring(math.round(v / 1000000, 2)) + "M" :
     v >= 1000 ? str.tostring(math.round(v / 1000, 2)) + "K" :
     str.tostring(math.round(v))

f_delete_draw(TrapDraw d) =>
    box.delete(d.ob)
    box.delete(d.eOB)

    for b in d.gradBoxes
        b.delete()

    d.gradBoxes.clear()

    line.delete(d.trigLn)
    line.delete(d.trigExt)
    line.delete(d.farLn)
    line.delete(d.farExt)

f_create_draw(color css) =>
    box _ob = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=color.new(css, 70), bgcolor=color.new(color.black, 100), border_width=1)
    box _eOB = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=color.new(css, 80), bgcolor=color.new(color.black, 100), border_width=1)

    gradB = array.new<box>()

    for i = 0 to gradRows - 1
        gradB.push(box.new(na, na, na, na, xloc=xloc.bar_time, border_color=color.new(color.black, 100), bgcolor=na, border_width=0))

    line tL = line.new(na, na, na, na, xloc=xloc.bar_time, color=na, width=2)
    line tE = line.new(na, na, na, na, xloc=xloc.bar_time, color=na, width=2)
    line fL = line.new(na, na, na, na, xloc=xloc.bar_time, color=na, width=1)
    line fE = line.new(na, na, na, na, xloc=xloc.bar_time, color=na, width=1)

    TrapDraw.new(_ob, _eOB, gradB, tL, tE, fL, fE)

f_add(TrapZone[] zArr, TrapDraw[] dArr, TrapZone z, color css) =>
    if hideOverlap and zArr.size() > 0
        for k = zArr.size() - 1 to 0
            TrapZone ez = zArr.get(k)

            if z.btm < ez.top and z.top > ez.btm
                f_delete_draw(dArr.get(k))
                zArr.remove(k)
                dArr.remove(k)
                break

    zArr.unshift(z)
    dArr.unshift(f_create_draw(css))

    while zArr.size() > maxZones
        zArr.pop()
        f_delete_draw(dArr.pop())

f_push_trap(Level lv) =>
    bool bearish = lv.isHigh
    float top = bearish ? lv.extreme : lv.price
    float btm = bearish ? lv.price : lv.extreme
    TrapZone z = TrapZone.new(top, btm, lv.price, lv.trapVol, lv.breakT, bearish, false)

    if bearish
        f_add(bullTraps, bullDraws, z, bearCol)
    else
        f_add(bearTraps, bearDraws, z, bullCol)

// ┌────────────────────────────── BOSWaves ─ Level Tracking ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_new_level(Level[] arr, float price, bool isHigh) =>
    arr.unshift(Level.new(price, bar_index - swingLen, isHigh, false, na, na, na, 0.0))

    if arr.size() > maxLevels
        arr.pop()

f_process_levels(Level[] arr) =>
    bool fired = false

    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Level lv = arr.get(i)
            bool kill = false

            if not lv.broken
                bool brk = lv.isHigh ? close > lv.price + atr * breakBuf : close < lv.price - atr * breakBuf

                if brk
                    lv.broken := true
                    lv.breakBi := bar_index
                    lv.breakT := time
                    lv.extreme := lv.isHigh ? high : low
                    lv.trapVol := nz(volume)

                else if bar_index - lv.pivBi > maxAge
                    kill := true

            else
                lv.extreme := lv.isHigh ? math.max(lv.extreme, high) : math.min(lv.extreme, low)
                lv.trapVol += nz(volume)

                bool back = lv.isHigh ? close < lv.price : close > lv.price

                if back
                    f_push_trap(lv)
                    fired := true
                    kill := true

                else if bar_index - lv.breakBi >= trapWindow
                    kill := true

            if kill
                arr.remove(i)

    fired

if not na(ph)
    f_new_level(highLevels, ph, true)

if not na(pl)
    f_new_level(lowLevels, pl, false)

bool bullTrap = f_process_levels(highLevels)
bool bearTrap = f_process_levels(lowLevels)

// ┌────────────────────────────── BOSWaves ─ Mitigation & Retests ───────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_process_zones(TrapZone[] zArr, TrapDraw[] dArr) =>
    bool retest = false

    if zArr.size() > 0
        for k = zArr.size() - 1 to 0
            TrapZone z = zArr.get(k)
            float mid = math.avg(z.top, z.btm)
            float tg = mitigation == "Middle" ? mid : z.bearish ? z.top : z.btm
            bool invalid = z.bearish ? close > tg : close < tg

            if invalid
                f_delete_draw(dArr.get(k))
                zArr.remove(k)
                dArr.remove(k)

            else
                bool outside = z.bearish ? high < z.btm : low > z.top
                bool touch = z.bearish ? high >= z.btm : low <= z.top

                if outside
                    z.armed := true

                else if touch and z.armed
                    z.armed := false
                    retest := true

    retest

bool bullTrapRetest = f_process_zones(bullTraps, bullDraws)
bool bearTrapRetest = f_process_zones(bearTraps, bearDraws)

// ┌────────────────────────────── BOSWaves ─ Draw Zones ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_draw_all(TrapZone[] zArr, TrapDraw[] dArr, color css) =>
    if barstate.islast and zArr.size() > 0
        int dt = time - time[1]
        int extTime = time + dt * extendBars

        for i = 0 to zArr.size() - 1
            TrapZone z = zArr.get(i)
            TrapDraw d = dArr.get(i)
            float rowH = (z.top - z.btm) / gradRows
            float far = z.bearish ? z.top : z.btm

            // Gradient layers
            for g = 0 to d.gradBoxes.size() - 1
                int transp = int(78 + float(g) / float(gradRows) * 17)
                float rTop = z.bearish ? z.btm + (g + 1) * rowH : z.top - g * rowH
                float rBot = rTop - rowH

                d.gradBoxes.get(g).set_lefttop(z.left_time, rTop)
                d.gradBoxes.get(g).set_rightbottom(extTime, rBot)
                d.gradBoxes.get(g).set_bgcolor(color.new(css, transp))

            // Outer shell
            d.ob.set_lefttop(z.left_time, z.top)
            d.ob.set_rightbottom(time, z.btm)

            // Extended box
            d.eOB.set_lefttop(time, z.top)
            d.eOB.set_rightbottom(extTime, z.btm)

            // Trigger lines
            d.trigLn.set_xy1(z.left_time, z.trig)
            d.trigLn.set_xy2(time, z.trig)
            d.trigLn.set_color(color.new(css, 15))

            d.trigExt.set_xy1(time, z.trig)
            d.trigExt.set_xy2(extTime, z.trig)
            d.trigExt.set_color(color.new(css, 40))

            // Far edge
            d.farLn.set_xy1(z.left_time, far)
            d.farLn.set_xy2(time, far)
            d.farLn.set_color(color.new(css, 75))

            d.farExt.set_xy1(time, far)
            d.farExt.set_xy2(extTime, far)
            d.farExt.set_color(color.new(css, 85))

            // Original text placement
            if showLabel
                string txt = (z.bearish ? "BULL TRAP" : "BEAR TRAP") + (showMetric and z.total_vol > 0 ? "\n" + f_vol_text(z.total_vol) + " TRAPPED" : "")

                d.eOB.set_text(txt)
                d.eOB.set_text_size(size.auto)
                d.eOB.set_text_halign(text.align_right)
                d.eOB.set_text_formatting(text.format_bold)
                d.eOB.set_text_color(chart.fg_color)

f_draw_all(bullTraps, bullDraws, bearCol)
f_draw_all(bearTraps, bearDraws, bullCol)

// ┌────────────────────────────── BOSWaves ─ Retest Markers ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool bullRetest = bearTrapRetest and trend == 1
bool bearRetest = bullTrapRetest and trend == -1

plotchar(bullRetest ? low : na, "Bull Retest", "✦", location.absolute, bullCol, size=size.small)
plotchar(bearRetest ? high : na, "Bear Retest", "✦", location.absolute, bearCol, size=size.small)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(switchUp, "Trend Long", "Liquidity Trap Structure LONG {{ticker}} {{interval}}")
alertcondition(switchDown, "Trend Short", "Liquidity Trap Structure SHORT {{ticker}} {{interval}}")
alertcondition(bullTrap, "Bull Trap", "Bull trap confirmed | {{exchange}}:{{ticker}}")
alertcondition(bearTrap, "Bear Trap", "Bear trap confirmed | {{exchange}}:{{ticker}}")
alertcondition(bullTrapRetest or bearTrapRetest, "Trap Retest", "Trap zone retest | {{exchange}}:{{ticker}}")
````
