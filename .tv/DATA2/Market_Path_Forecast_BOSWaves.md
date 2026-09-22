<!-- tradingview-pine-id: PUB;b2abd960bc424086a2f66fcad6e09b77 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Path Forecast [BOSWaves]

Source: https://www.tradingview.com/script/2sBh2G8D-Market-Path-Forecast-BOSWaves/

## Description

Market Path Forecast [BOSWaves] - Swing-Calibrated Directional Forecast with Confidence Cone, Structure-Snapped Levels, and Adaptive Horizon

Overview

Market Path Forecast [BOSWaves] is a swing-calibrated probabilistic directional forecast system that derives its target price, forecast duration, and cone width entirely from the statistical properties of the instrument's own historical swing behavior, where the path cone, level placement, and forecast horizon all adapt continuously to the accumulated record of completed swings rather than applying fixed ATR multiples or arbitrary projection distances.

[image]https://www.tradingview.com/x/KtHVU75j/[/image]

Instead of projecting fixed percentage moves or static ATR extensions, the system accumulates the percentage size and bar duration of each completed directional swing into weighted sample arrays, computes the weighted average and standard deviation of those samples, and uses these statistics to estimate where the current swing is likely to travel and how long it is likely to take. The resulting forecast is not a generic technical projection but a statistically calibrated estimate derived from the instrument's actual measured movement history.

This creates a forecast framework that is self-calibrating to each instrument and timeframe. Instruments with large consistent swings produce wide confident cones pointing to distant targets. Instruments with small erratic swings produce narrower cones with closer targets. The confidence interval setting scales the cone width relative to the measured historical variance, allowing the trader to choose whether to view the tight central tendency or the broader probable range. Structure snap alignment pulls forecast levels toward nearby historical pivot prices, anchoring statistically derived targets to structurally significant levels. And the adaptive horizon dynamically adjusts the projection duration as the current swing develops, so the cone length reflects how much time is estimated to remain rather than a fixed number of bars.

Price is therefore evaluated against a forecast that reflects the instrument's own statistical swing personality rather than a generic overlay applied identically regardless of how the instrument actually moves.

Conceptual Framework

Market Path Forecast is founded on the principle that the most reliable basis for a directional price forecast is the statistical distribution of the instrument's own completed swing history, and that both the target level and the confidence around that target should derive from measured historical variance rather than from fixed indicator parameters.

Traditional forecast tools apply static extensions, fixed ATR projections, or Fibonacci ratios that carry no relationship to how the specific instrument actually moves. This framework replaces static projection with statistical estimation, accumulating a rolling weighted sample of historical swing sizes and durations and deriving forecast parameters from that sample on every bar. Recent swings receive greater weight than older ones, ensuring the forecast adapts dynamically to evolving market behavior while maintaining the stability that comes from a sufficient sample of historical evidence.

Three core principles guide the design:

[]Forecast targets, durations, and cone widths should derive from the statistical properties of the instrument's own swing history rather than from fixed parameters, ensuring every element of the projection reflects actual measured behavior rather than generic assumptions.
[]The confidence cone should scale with historical swing variance through a statistically meaningful confidence interval parameter, so traders understand they are viewing a fraction of the measured probability distribution rather than an arbitrary visual band.
[*]Forecast levels should be snapped toward nearby historical structure prices where they exist within the configurable snap range, anchoring statistically derived targets to the structural price levels that may have influenced prior swing reversals.

This shifts directional forecasting from fixed-parameter projection into instrument-specific statistical estimation where all visual elements adapt to the instrument's own historical behavior.

Theoretical Foundation

The indicator combines swing detection through highest and lowest lookback comparison, recent-weighted average and standard deviation calculation across historical swing percentage moves and bar durations, directional forecast derivation from the appropriate bull or bear sample arrays, momentum-adjusted path curvature using EMA difference normalization, structure-snap level alignment using nearest historical pivot within the configurable ATR search radius, and historical support and resistance zone construction from separate pivot detection with age-based expiry and break detection.

Swing direction is tracked by monitoring whether the current highest or lowest lookback value is being set by the current high or low, with confirmed swing points registered when price rotates away from a prior extreme. Each completed directional leg contributes its percentage move and bar duration to separate bull and bear sample arrays using a weighted push that replaces oldest samples beyond the configured maximum. The weighted average applies linearly increasing weights from oldest to most recent, giving recent swings proportionally greater influence. Standard deviation is computed from the same weighted scheme, producing a variance measure that reflects recent behavior more than distant history. The forecast target is calculated as a percentage move from the swing origin, with the extension factor derived from the deviation ratio to scale the extension level beyond the primary target.

Four internal systems operate in tandem:

[]Swing History Engine: Detects confirmed swing direction changes, measures the percentage move and bar duration of each completed leg, and accumulates these into directional and combined weighted sample arrays that feed all downstream forecast calculations.
[]Statistical Forecast Engine: Derives weighted average target percentage and duration from the directional sample arrays, falls back to combined samples when directional sample count is insufficient, calculates the standard deviation for cone width scaling, and applies minimum spacing enforcement to prevent levels from overlapping.
[]Path and Level Rendering System: Constructs the three-layer confidence cone using eased smooth interpolation with momentum-derived curvature, and renders up to six forecast levels as three-layer box zones with structure-snapped prices, directional coloring, and configurable label display.
[]Historical Structure System: Independently detects pivot highs and lows at the configured structure pivot length, maintains active zone boxes with age-based fading and break detection, stores pivot prices in a rolling array that feeds the structure snap function for all forecast levels, and enforces maximum zone count and age limits.

This design ensures the forecast derives entirely from measured historical behavior while the structure snap layer connects statistically derived levels to structurally significant prices where they exist in proximity.

How It Works

Market Path Forecast evaluates price through a sequence of swing-calibrated and statistically derived processes:

[]Swing Direction Tracking: On each bar, the highest high and lowest low over the configured swing length are compared to the current bar. When the current high sets the lookback high, direction tracks bullish. When the current low sets the lookback low, direction tracks bearish. Confirmed swing points are registered when price rotates away from the prior extreme.
[]Swing Sample Accumulation: On each confirmed swing direction change, the completed leg's percentage move and bar duration are calculated and pushed into the appropriate directional and combined sample arrays with size capping at the configured maximum. Bull legs accumulate into the bull arrays and bear legs into the bear arrays.
[]Weighted Forecast Derivation: The weighted average of the directional sample array provides the forecast percentage move. The weighted average of the duration array provides the forecast bar count. The weighted standard deviation of the directional array provides the variance measure for cone scaling. When fewer than three directional samples exist, the combined arrays are used as fallback.
[]Adaptive Horizon Calculation: The estimated remaining bars for the current swing are calculated by subtracting elapsed bars from the estimated total duration and clamping to the configured minimum and maximum. When adaptive horizon is disabled, the fixed bar count is used instead.
[]Target Calculation: The primary target is derived from the swing origin price adjusted by the forecast percentage in the forecast direction, with a minimum distance floor enforced as an ATR multiple to prevent targets from forming too close to current price.
[]Level Derivation: Target 1, 2, and 3 are placed at 40, 70, and 100 percent of the base distance. The extension level is placed beyond Target 3 using a factor derived from the deviation-to-mean ratio. The opposite structure reference and invalidation level are placed on the opposing side of price.
[]Structure Snap Application: Each raw level price is tested against the rolling historical structure price array. If a matching structural high or low exists within the ATR snap range on the correct side of price, the level is blended toward that structural price by the configured snap strength.
[]Minimum Spacing Enforcement: After snapping, all levels are adjusted to maintain a minimum separation equal to twice the zone ATR width, preventing levels from overlapping regardless of snap results.
[]Cone Construction: The base band half-width is derived from the greater of the ATR floor and the price-converted standard deviation, clamped to a maximum fraction of the distance to Target 3, then multiplied by the confidence interval setting. Smooth eased interpolation builds the outer, inner, and center polyline paths between current price and the Target 3 level with momentum-derived curvature applied.
[]Historical Structure Zone Management: Pivot highs and lows detected at the structure pivot length receive dual-layer zone boxes that extend rightward each bar, fade with cubic age scaling, convert to dotted broken style when price closes through them, and expire after the configured maximum age or break age.

Together, these elements form a continuously updating forecast system where every visual element adapts to the instrument's measured swing history and structural price environment.

Interpretation

Market Path Forecast should be interpreted as a statistically calibrated swing forecast with a probabilistic confidence cone and structure-aligned target levels:

[]Forecast Path Cone: The three-layer cone extending from current price represents the probable range of price paths based on historical swing behavior. The outer layer covers the full confidence interval width. The inner layer covers approximately 55 percent of the cone width. The center line represents the weighted average expected path.
[]Cone Width: A wide cone indicates high historical swing variance where completed swings varied significantly in size. A narrow cone indicates consistent swing behavior with low variance. The confidence interval setting controls how many standard deviations of historical variance the cone spans.
[]Cone Curvature: The cone bends in the direction of current EMA momentum, reflecting whether the trend currently has upside or downside momentum bias that may influence the directional path of the developing swing.
[]Target 1, 2, 3 Levels: Three-layer zone boxes at progressively greater distances represent the expected first, intermediate, and primary swing completion levels derived from the weighted average of historical swings at 40, 70, and 100 percent of the base distance.
[]Extension Level: Beyond Target 3, the extension level marks where larger-than-average swings have historically reached, scaled by the ratio of standard deviation to mean swing size. A larger extension factor indicates that historical swings have been more variable and have occasionally traveled significantly beyond average.
[]Support / Resistance Level: The opposing-direction level on the near side of price identifies the closest structural reference in the opposing direction, representing the level where a counter-swing could develop before the forecast target is reached.
[]Invalidation Level: The furthest opposing level marks the price beyond which the current swing forecast would be statistically invalidated, representing the distance at which counter-directional movement exceeds what is consistent with the current swing remaining intact.
[]Historical Structure Zones: Green support zones and red resistance zones from historical pivot detection provide the structural price environment that both informs the forecast level snap function and serves as ongoing structural reference for price interaction monitoring.
[*]Broken Structure Zones: Zones that have been closed through convert to dotted style with faded coloring, indicating the former level has been breached and may now function in the opposing structural role.

Cone width, target level placement, snap alignment to structure, and invalidation level distance collectively provide more forecast context than any element in isolation.

Signal Logic & Visual Cues

Market Path Forecast generates two directional signals tied to swing direction changes:

[]Bullish Forecast: Triggered when swing direction flips from bearish to bullish, resetting the forecast origin to the confirmed swing low and projecting the cone and levels upward toward the statistically estimated bull swing targets.
[]Bearish Forecast: Triggered when swing direction flips from bullish to bearish, resetting the forecast origin to the confirmed swing high and projecting the cone and levels downward toward the statistically estimated bear swing targets.

Each forecast reset incorporates the newly completed swing into the weighted sample arrays before generating the next projection, ensuring every forecast benefits from the most recent available behavioral evidence.

Alert generation covers bullish and bearish forecast direction changes for systematic swing-based monitoring workflows.

Strategy Integration

Market Path Forecast fits within swing-calibrated directional and statistical target-based trading approaches:

[]Target-Based Exit Planning: Use the three forecast target levels as a staged exit framework, planning partial position reductions at T1, T2, and T3 rather than targeting a single fixed level, allowing structured progression through the statistically estimated swing completion zone.
[]Cone Containment Monitoring: Monitor whether price is staying within the inner confidence cone or pressing against the outer boundaries as a real-time swing health indicator. Price persistently hugging the outer cone boundary in the forecast direction suggests above-average momentum. Price compressing toward the center early in the forecast suggests weakening follow-through.
[]Extension Level Context: Use the extension level as a target for high-momentum setups where the deviation-to-mean ratio is elevated, indicating that historical swings have occasionally extended significantly beyond the average. A larger gap between T3 and the extension level reflects greater historical variability.
[]Invalidation Level Risk Management: Use the invalidation level as the maximum tolerable counter-directional excursion, beyond which the current swing forecast is no longer statistically consistent with historical behavior and the position rationale is undermined.
[]Structure Snap Confluence: Prioritize levels that have been snapped to nearby structural pivot prices over purely statistically derived levels, as these represent locations where both the measured swing expectation and historical price structure align simultaneously.
[]Confidence Interval Calibration: Use a lower confidence interval such as 0.5 for tight conviction analysis where you want to see only the central tendency of the forecast. Use 1.5 or 2.0 to visualize the broader probability range that captures less typical swing outcomes.

Technical Implementation Details

[]Swing Detection: Highest and lowest lookback comparison with direction tracking and confirmed point registration on price rotation
[]Sample Arrays: Weighted push accumulation for bull, bear, and combined percentage and duration arrays with configurable maximum size
[]Forecast Statistics: Linearly increasing weight scheme for weighted average and standard deviation with directional to combined fallback below minimum sample threshold
[]Cone Construction: Eased smooth interpolation with momentum-normalized EMA curvature across configurable step count for outer, inner, and center polyline paths
[]Level System: Six forecast levels with percentage-of-base-distance placement, deviation-ratio extension scaling, structure snap blending, minimum spacing enforcement, and three-layer zone box rendering
[]Structure System: Pivot-based zone detection with dual-layer boxes, rolling structure price array for snap function, cubic age fading, break detection with style conversion, and configurable zone count and age limits
[*]Performance Profile: Last-bar rendering with full polyline and object rebuild each update, configurable level count for object management

Optimal Application Parameters

Timeframe Guidance:

[]1 - 5 min: Intraday swing forecasting with shorter swing length and fewer historical swings for fast adaptation to intraday directional changes
[]15 - 60 min: Session-level swing projection with balanced swing length and moderate sample count for meaningful statistical accumulation across typical session swings
[]4H - Daily: Swing-level directional forecasting with longer swing detection and larger sample count for statistically robust estimates derived from significant structural moves

Suggested Baseline Configuration:

[]Swing Length: 16
[]Historical Swings: 20
[]Volatility Length: 200
[]Adaptive Forecast Horizon: Enabled
[]Confidence Interval (SD): 1.0
[]Path Curvature: 0.45
[]Number of Levels: 6
[]Structure Snap Strength: 0.65
[]Show Historical Structure: Enabled
[]Show Forecast Path: Enabled
[]Show Forecast Levels: Enabled

These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's swing frequency, historical swing consistency, and preferred forecast horizon, so fine-tuning is expected for optimal performance.

Parameter Calibration Notes

Use the following adjustments to refine behavior without altering the core logic:

[]Forecast targets too close to price: Decrease Minimum Target Distance toward 1.0 to allow targets to form closer to price, or increase Historical Swings to accumulate more samples that may include larger average moves.
[]Forecast targets too far from price: Increase Minimum Target Distance to enforce greater separation, or decrease Historical Swings to weight more recent and potentially smaller swing samples more heavily.
[]Cone too wide or too narrow: Adjust Confidence Interval to expand or contract the cone relative to the measured standard deviation of historical swings, using 0.5 for a tight central tendency view or 2.0 for a broad probability range.
[]Forecast flipping too frequently: Increase Swing Length to require more bars on each side of a confirmed swing extreme, filtering shorter-term oscillations from the swing detection.
[]Forecast too slow to update: Decrease Swing Length toward 6 for faster swing confirmation, or decrease Historical Swings to allow the weighted average to adapt more quickly to recent behavior changes.
[]Levels not snapping to structure: Increase Structure Snap Range to widen the ATR distance within which structural pivot prices attract forecast levels, or increase Structure Snap Strength toward 1.0 for stronger magnetic pull toward nearby structure.
[*]Too many historical structure zones: Reduce Maximum Zones to limit visible structural zones, or decrease Maximum Zone Age to expire older zones sooner and keep the chart focused on more recent structural history.

Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

Performance Characteristics

High Effectiveness:

[]Instruments with consistent swing behavior where historical percentage moves and durations cluster tightly, producing low variance forecasts with narrow confident cones that accurately reflect the instrument's typical directional tendency
[]Trending markets where completed swings accumulate rapidly and the weighted sample arrays update frequently, keeping the forecast calibrated to current momentum characteristics
[]Swing-based trading approaches where statistically derived target levels replace arbitrary Fibonacci or ATR projections with instrument-specific measurements of where swings have historically terminated
[]Structure-rich instruments where the snap function can align statistically derived levels with meaningful historical pivot prices, creating confluence between statistical expectation and structural significance

Reduced Effectiveness:

[]Instruments with highly erratic swing behavior where percentage moves vary widely between legs, producing large standard deviations and wide uncertain cones that reduce the specificity of target level placement
[]Range-bound or choppy markets where swing detection fires frequently on minor oscillations, populating the sample arrays with small inconsistent measurements that undermine forecast reliability
[]Instruments with insufficient completed swings within the sample window where the fallback to combined arrays may produce forecasts that blend bull and bear statistical properties inappropriately
[]Very short timeframes where completed swings are so numerous and small that the weighted average converges on noise-level movements without statistical significance
[]Markets undergoing structural regime changes where historical swing statistics are no longer representative of current behavior, making the weighted average a poor estimate of future swing potential until sufficient new samples accumulate

Integration Guidelines

[]Confluence: Combine with BOSWaves structural tools, volume analysis, or momentum indicators to validate forecast direction and target level interactions with broader analytical context before committing to swing-based trade plans
[]Sample Count Awareness: Monitor whether the forecast is drawing on directional or combined samples by assessing how many completed swings in the current direction exist within the historical window. Fewer than three directional samples means the forecast is using combined statistics that blend both directions.
[]Cone Evolution Monitoring: Track cone width changes across successive forecast resets as a volatility regime indicator. Progressively widening cones across multiple swings suggest increasing swing size variability. Narrowing cones suggest the instrument is entering a more consistent swing rhythm.
[]Structure Snap Validation: When a level snaps significantly from its raw statistical position to a nearby structural pivot, treat the snapped level with elevated confidence as it represents simultaneous statistical expectation and structural significance.
[]Invalidation Discipline: Respect the invalidation level as a hard position management boundary. A close beyond the invalidation level indicates counter-directional movement that exceeds the statistical parameters of the current forecast, warranting position reassessment regardless of other analytical factors.

Disclaimer

Market Path Forecast [BOSWaves] is a professional-grade swing-calibrated statistical forecast and structural analysis tool. It uses weighted historical swing statistics with confidence interval scaling and structure snap alignment but does not predict future price movements with certainty. All forecasts represent statistical estimates based on historical behavior and carry inherent uncertainty that increases with forecast horizon. Results depend on market conditions, instrument swing consistency, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Market Path Forecast [BOSWaves]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_polylines_count = 100, max_bars_back = 5000)

// ┌───────────────────────────── BOSWaves ─ Inputs ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

GRP_DETECT = "Forecast Detection"
GRP_PATH = "Market Path"
GRP_LEVELS = "Forecast Levels"
GRP_STRUCT = "Historical Structure"
GRP_STYLE = "Style"

swingLen = input.int(16, "Swing Length", minval = 6, maxval = 100, group = GRP_DETECT, tooltip = "Controls the swing structure used by the forecast engine.")
samples = input.int(20, "Historical Swings", minval = 5, maxval = 50, group = GRP_DETECT, tooltip = "Number of completed historical swings used to estimate future movement and duration.")
atrLen = input.int(200, "Volatility Length", minval = 20, maxval = 500, group = GRP_DETECT, tooltip = "Lookback for ATR volatility measurement. Higher = smoother baseline less reactive to short-term spikes.")

showPath = input.bool(true, "Show Forecast Path", group = GRP_PATH, tooltip = "Displays the forecast path cone projecting from current price toward the estimated target.")
adaptiveHorizon = input.bool(true, "Adaptive Forecast Horizon", group = GRP_PATH, tooltip = "When enabled the forecast horizon adapts dynamically based on average historical swing duration. When disabled the fixed bar count is used.")
fixedForecastBars = input.int(78, "Fixed Forecast Bars", minval = 5, maxval = 100, group = GRP_PATH, tooltip = "Fixed number of bars the forecast projects forward when Adaptive Forecast Horizon is disabled.")
minForecastBars = input.int(8, "Minimum Bars", minval = 5, maxval = 50, group = GRP_PATH, inline = "h", tooltip = "Minimum number of bars the adaptive forecast will project regardless of estimated swing duration.")
maxForecastBars = input.int(105, "Maximum Bars", minval = 10, maxval = 150, group = GRP_PATH, inline = "h", tooltip = "Maximum number of bars the adaptive forecast will project regardless of estimated swing duration.")
pathStretch = input.float(2, "Forecast Width", minval = 0.80, maxval = 2.00, step = 0.05, group = GRP_PATH, tooltip = "Horizontal multiplier applied to the forecast display length. Higher values spread the path further across the chart.")
confidenceInterval = input.float(1.0, "Confidence Interval (SD)", minval = 0.5, maxval = 2.0, step = 0.1, group = GRP_PATH, tooltip = "Width of the forecast cone expressed as standard deviation multiples of historical swing variance. 1.0 = 68% of historical outcomes, 1.5 = 87%, 2.0 = 95%.")
minTargetATR = input.float(5, "Minimum Target Distance", minval = 0.25, maxval = 5.0, step = 0.25, group = GRP_PATH, tooltip = "Minimum distance between current price and the forecast target expressed as an ATR multiple. Prevents targets from forming too close to price.")
pathBend = input.float(0.45, "Path Curvature", minval = 0.0, maxval = 1.5, step = 0.05, group = GRP_PATH, tooltip = "Amount of curvature applied to the forecast path based on current momentum. Higher values produce a more pronounced curve.")

showForecastLevels = input.bool(true, "Show Forecast Levels", group = GRP_LEVELS, tooltip = "Displays the forecast target zones, extension level, opposite structure reference, and invalidation level.")
maxForecastLevels = input.int(6, "Number of Levels", minval = 1, maxval = 6, group = GRP_LEVELS, tooltip = "Number of forecast levels displayed from T1 outward. 1 = T1 only, 6 = all levels including Extension, Support/Resistance, and Invalidation.")
forecastZoneATR = input.float(0.10, "Forecast Zone Width", minval = 0.03, maxval = 0.50, step = 0.01, group = GRP_LEVELS, tooltip = "Vertical thickness of each forecast level zone expressed as an ATR multiple.")
levelStartPct = input.float(0.38, "Level Start Offset", minval = 0.10, maxval = 0.80, step = 0.01, group = GRP_LEVELS, tooltip = "How far along the forecast horizon the level zones begin, as a fraction of the total display length.")
structureSnapATR = input.float(0.75, "Structure Snap Range", minval = 0.10, maxval = 3.0, step = 0.05, group = GRP_LEVELS, tooltip = "Maximum distance from a raw forecast level to a historical structure price for the snap to activate, expressed as ATR multiples.")
structureSnapStrength = input.float(0.65, "Structure Snap Strength", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_LEVELS, tooltip = "How strongly forecast levels are pulled toward nearby historical structure prices. 0.0 = no snap, 1.0 = full snap to structure.")
confluenceRadiusATR = input.float(0.40, "Confluence Radius", minval = 0.10, maxval = 1.5, step = 0.05, group = GRP_LEVELS, tooltip = "Search radius for counting historical structure prices near a forecast level, expressed as ATR multiples.")

showStructure = input.bool(true, "Show Historical Structure", group = GRP_STRUCT, tooltip = "Displays historical pivot high and low zones on the chart as structural reference areas.")
structureLen = input.int(5, "Structure Pivot Length", minval = 2, maxval = 20, group = GRP_STRUCT, tooltip = "Pivot lookback length for historical structure detection. Higher = fewer but more significant structural levels.")
structureZoneATR = input.float(0.18, "Structure Zone Width", minval = 0.05, maxval = 0.75, step = 0.01, group = GRP_STRUCT, tooltip = "Vertical thickness of historical structure zones expressed as ATR multiples.")
maxStructureZones = input.int(12, "Maximum Zones", minval = 2, maxval = 30, group = GRP_STRUCT, tooltip = "Maximum number of historical structure zones displayed simultaneously. Oldest zones are removed first when the limit is reached.")
structureMaxAge = input.int(350, "Maximum Zone Age", minval = 50, maxval = 2000, group = GRP_STRUCT, tooltip = "Maximum bar age of a historical structure zone before it expires and is removed from the chart.")

bullStructClr = input.color(#00E676, "Support", group = GRP_STYLE, inline = "s1")
bearStructClr = input.color(#FF3D57, "Resistance", group = GRP_STYLE, inline = "s1")

bullPathClr = input.color(#26C6DA, "Bull Path", group = GRP_STYLE, inline = "p1")
bearPathClr = input.color(#FF8A3D, "Bear Path", group = GRP_STYLE, inline = "p1")

bullT1Clr = input.color(#4DD0E1, "Bull T1", group = GRP_STYLE, inline = "bt")
bullT2Clr = input.color(#26C6DA, "T2", group = GRP_STYLE, inline = "bt")
bullT3Clr = input.color(#00BFA5, "T3", group = GRP_STYLE, inline = "bt")

bearT1Clr = input.color(#FFB74D, "Bear T1", group = GRP_STYLE, inline = "br")
bearT2Clr = input.color(#FF9800, "T2", group = GRP_STYLE, inline = "br")
bearT3Clr = input.color(#FF6D00, "T3", group = GRP_STYLE, inline = "br")

extensionClr = input.color(#AB47BC, "Extension", group = GRP_STYLE, inline = "e")
levelTextClr = input.color(color.white, "Text", group = GRP_STYLE, inline = "e")
showPrices = input.bool(true, "Show Level Prices", group = GRP_STYLE, inline = "lbl")
showLevelNames = input.bool(true, "Show Level Names", group = GRP_STYLE, inline = "lbl")

CLEAR = color.new(color.black, 100)

// ┌───────────────────────────── BOSWaves ─ Types ───────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

type Pivot
    float price
    int idx

type SRZone
    float price
    float half
    int startIdx
    bool resistance
    bool broken
    int brokenIdx
    box outerBox
    box innerBox
    line lvlLine

// ┌───────────────────────────── BOSWaves ─ State ───────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

var hi = Pivot.new(na, na)
var lo = Pivot.new(na, na)
var bool dir = false

var bullPcts = array.new<float>()
var bearPcts = array.new<float>()
var bullDurs = array.new<float>()
var bearDurs = array.new<float>()
var allPcts = array.new<float>()
var allDurs = array.new<float>()

var structurePrices = array.new<float>()
var structureHighs = array.new<bool>()
var structureZones = array.new<SRZone>()

var forecastBoxes = array.new<box>()
var forecastLines = array.new<line>()
var forecastLabels = array.new<label>()

var polyline pathOuter = na
var polyline pathInner = na
var polyline pathCenter = na

atr = ta.atr(atrLen)
fastEMA = ta.ema(close, 8)
slowEMA = ta.ema(close, 21)
atrSafe = math.max(nz(atr, math.max(high - low, syminfo.mintick)), syminfo.mintick * 10.0)

// ┌───────────────────────────── BOSWaves ─ Functions ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

weightedAverage(array<float> values) =>
    result = float(na)
    if values.size() > 0
        tw = 0.0
        ws = 0.0
        for i = 0 to values.size() - 1
            w = i + 1.0
            ws += values.get(i) * w
            tw += w
        result := ws / tw
    result

weightedDeviation(array<float> values, float meanValue) =>
    result = 0.0
    if values.size() > 0 and not na(meanValue)
        tw = 0.0
        wv = 0.0
        for i = 0 to values.size() - 1
            w = i + 1.0
            diff = values.get(i) - meanValue
            wv += diff * diff * w
            tw += w
        result := math.sqrt(wv / tw)
    result

pushSample(array<float> values, float value, int maximum) =>
    if not na(value) and value > 0
        values.push(value)
        if values.size() > maximum
            values.shift()

pushStructure(float price, bool isHigh) =>
    if not na(price) and price > 0
        structurePrices.push(price)
        structureHighs.push(isHigh)
        if structurePrices.size() > 100
            structurePrices.shift()
            structureHighs.shift()

snapLevel(float raw, float maximumDistance, float blend, bool wantHigh, float anchor, int side) =>
    bestPrice = raw
    bestDistance = maximumDistance + syminfo.mintick
    if structurePrices.size() > 0 and not na(raw)
        for i = 0 to structurePrices.size() - 1
            p = structurePrices.get(i)
            isHigh = structureHighs.get(i)
            correctSide = side > 0 ? p > anchor : p < anchor
            if isHigh == wantHigh and correctSide
                distance = math.abs(p - raw)
                if distance <= maximumDistance and distance < bestDistance
                    bestDistance := distance
                    bestPrice := p
    raw * (1.0 - blend) + bestPrice * blend

countConfluence(float level, float radius, bool wantHigh) =>
    count = 0
    if structurePrices.size() > 0 and not na(level)
        for i = 0 to structurePrices.size() - 1
            p = structurePrices.get(i)
            isHigh = structureHighs.get(i)
            if isHigh == wantHigh and math.abs(p - level) <= radius
                count += 1
    math.min(count, 5)

buildBand(int startIdx, int endIdx, float startPrice, float endPrice, float endHalf, float bend, float widthMult, int steps) =>
    pts = array.new<chart.point>()
    for s = 0 to steps
        t = s / float(steps)
        eased = t * t * (3.0 - 2.0 * t)
        x = startIdx + int(math.round((endIdx - startIdx) * t))
        curve = bend * 4.0 * t * (1.0 - t)
        center = startPrice + (endPrice - startPrice) * eased + curve
        spread = endHalf * widthMult * (0.10 + 0.90 * eased)
        pts.push(chart.point.from_index(x, center + spread))
    for s = steps to 0
        t = s / float(steps)
        eased = t * t * (3.0 - 2.0 * t)
        x = startIdx + int(math.round((endIdx - startIdx) * t))
        curve = bend * 4.0 * t * (1.0 - t)
        center = startPrice + (endPrice - startPrice) * eased + curve
        spread = endHalf * widthMult * (0.10 + 0.90 * eased)
        pts.push(chart.point.from_index(x, center - spread))
    pts

buildCenter(int startIdx, int endIdx, float startPrice, float endPrice, float bend, int steps) =>
    pts = array.new<chart.point>()
    for s = 0 to steps
        t = s / float(steps)
        eased = t * t * (3.0 - 2.0 * t)
        x = startIdx + int(math.round((endIdx - startIdx) * t))
        curve = bend * 4.0 * t * (1.0 - t)
        center = startPrice + (endPrice - startPrice) * eased + curve
        pts.push(chart.point.from_index(x, center))
    pts

// ┌───────────────────────────── BOSWaves ─ Swing Detection ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

H = ta.highest(high, swingLen)
L = ta.lowest(low, swingLen)

if high == H
    dir := true

if low == L
    dir := false

if high[1] == H[1] and high < H
    hi.price := high[1]
    hi.idx := bar_index[1]

if low[1] == L[1] and low > L
    lo.price := low[1]
    lo.idx := bar_index[1]

directionChanged = dir != dir[1]

// ┌───────────────────────────── BOSWaves ─ Swing History ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

if directionChanged and not na(hi.price) and not na(lo.price) and not na(hi.idx) and not na(lo.idx)
    legBars = math.abs(hi.idx - lo.idx)

    if not dir
        bullMove = math.abs((hi.price - lo.price) / lo.price * 100.0)
        pushSample(bullPcts, bullMove, samples)
        pushSample(bullDurs, legBars, samples)
        pushSample(allPcts, bullMove, samples * 2)
        pushSample(allDurs, legBars, samples * 2)
    else
        bearMove = math.abs((hi.price - lo.price) / hi.price * 100.0)
        pushSample(bearPcts, bearMove, samples)
        pushSample(bearDurs, legBars, samples)
        pushSample(allPcts, bearMove, samples * 2)
        pushSample(allDurs, legBars, samples * 2)

// ┌───────────────────────────── BOSWaves ─ Historical Structure ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

pivotHigh = ta.pivothigh(high, structureLen, structureLen)
pivotLow = ta.pivotlow(low, structureLen, structureLen)

if not na(pivotHigh)
    pivotIdx = bar_index - structureLen
    pushStructure(pivotHigh, true)

    if showStructure
        half = math.max(nz(atr[structureLen], atrSafe) * structureZoneATR, syminfo.mintick)
        z = SRZone.new()
        z.price := pivotHigh
        z.half := half
        z.startIdx := pivotIdx
        z.resistance := true
        z.broken := false
        z.brokenIdx := na
        z.outerBox := box.new(pivotIdx, pivotHigh + half, bar_index + 4, pivotHigh, border_color = CLEAR, bgcolor = color.new(bearStructClr, 92))
        z.innerBox := box.new(pivotIdx, pivotHigh + half * 0.35, bar_index + 4, pivotHigh, border_color = CLEAR, bgcolor = color.new(bearStructClr, 84))
        z.lvlLine := line.new(pivotIdx, pivotHigh, bar_index + 4, pivotHigh, color = color.new(bearStructClr, 45), width = 1)
        structureZones.push(z)

if not na(pivotLow)
    pivotIdx = bar_index - structureLen
    pushStructure(pivotLow, false)

    if showStructure
        half = math.max(nz(atr[structureLen], atrSafe) * structureZoneATR, syminfo.mintick)
        z = SRZone.new()
        z.price := pivotLow
        z.half := half
        z.startIdx := pivotIdx
        z.resistance := false
        z.broken := false
        z.brokenIdx := na
        z.outerBox := box.new(pivotIdx, pivotLow, bar_index + 4, pivotLow - half, border_color = CLEAR, bgcolor = color.new(bullStructClr, 92))
        z.innerBox := box.new(pivotIdx, pivotLow, bar_index + 4, pivotLow - half * 0.35, border_color = CLEAR, bgcolor = color.new(bullStructClr, 84))
        z.lvlLine := line.new(pivotIdx, pivotLow, bar_index + 4, pivotLow, color = color.new(bullStructClr, 45), width = 1)
        structureZones.push(z)

while structureZones.size() > maxStructureZones
    old = structureZones.shift()
    box.delete(old.outerBox)
    box.delete(old.innerBox)
    line.delete(old.lvlLine)

if structureZones.size() > 0
    for i = structureZones.size() - 1 to 0
        z = structureZones.get(i)
        age = bar_index - z.startIdx
        clr = z.resistance ? bearStructClr : bullStructClr

        if not z.broken
            if z.resistance and close > z.price
                z.broken := true
                z.brokenIdx := bar_index
                line.set_style(z.lvlLine, line.style_dotted)
                line.set_color(z.lvlLine, color.new(clr, 80))
                box.set_bgcolor(z.outerBox, color.new(clr, 97))
                box.set_bgcolor(z.innerBox, color.new(clr, 95))

            if not z.resistance and close < z.price
                z.broken := true
                z.brokenIdx := bar_index
                line.set_style(z.lvlLine, line.style_dotted)
                line.set_color(z.lvlLine, color.new(clr, 80))
                box.set_bgcolor(z.outerBox, color.new(clr, 97))
                box.set_bgcolor(z.innerBox, color.new(clr, 95))

        if age > structureMaxAge or (z.broken and not na(z.brokenIdx) and bar_index - z.brokenIdx > 30)
            box.delete(z.outerBox)
            box.delete(z.innerBox)
            line.delete(z.lvlLine)
            structureZones.remove(i)
            continue

        if not z.broken
            box.set_right(z.outerBox, bar_index + 4)
            box.set_right(z.innerBox, bar_index + 4)
            line.set_x2(z.lvlLine, bar_index + 4)

// ┌───────────────────────────── BOSWaves ─ Forecast Engine ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

isBear = not dir
forecastSide = isBear ? -1 : 1

directionalSamples = isBear ? bearPcts.size() : bullPcts.size()
forecastPct = isBear ? weightedAverage(bearPcts) : weightedAverage(bullPcts)
forecastDuration = isBear ? weightedAverage(bearDurs) : weightedAverage(bullDurs)

if directionalSamples < 3 or na(forecastPct)
    forecastPct := weightedAverage(allPcts)
    forecastDuration := weightedAverage(allDurs)

forecastStd = isBear ? weightedDeviation(bearPcts, forecastPct) : weightedDeviation(bullPcts, forecastPct)

if directionalSamples < 3
    forecastStd := weightedDeviation(allPcts, forecastPct)

origin = isBear ? hi.price : lo.price
originIdx = isBear ? hi.idx : lo.idx

forecastReady = allPcts.size() >= 3 and not na(forecastPct) and forecastPct > 0 and not na(forecastDuration) and forecastDuration > 0 and not na(origin) and origin > 0 and not na(originIdx)

float forecastTarget1 = na
float forecastTarget2 = na
float forecastTarget3 = na
float forecastExtension = na
float forecastOpposite = na
float forecastInvalidation = na
int calculatedForecastBars = fixedForecastBars

if forecastReady
    elapsedBars = math.max(bar_index - originIdx, 0)
    adaptiveBarsLeft = int(math.round(forecastDuration)) - elapsedBars
    clampedAdaptiveBars = math.max(minForecastBars, math.min(maxForecastBars, adaptiveBarsLeft))
    calculatedForecastBars := adaptiveHorizon ? clampedAdaptiveBars : fixedForecastBars

    rawSwingTarget = isBear ? origin * (1.0 - forecastPct / 100.0) : origin * (1.0 + forecastPct / 100.0)
    minimumAhead = atrSafe * minTargetATR
    mainTarget = isBear ? math.min(rawSwingTarget, close - minimumAhead) : math.max(rawSwingTarget, close + minimumAhead)
    baseDistance = math.max(math.abs(mainTarget - close), minimumAhead)

    deviationRatio = forecastPct > 0.0 ? forecastStd / forecastPct : 0.0
    extensionFactor = 1.0 + math.max(0.25, math.min(0.75, deviationRatio * 0.75))

    rawTarget1 = close + forecastSide * baseDistance * 0.40
    rawTarget2 = close + forecastSide * baseDistance * 0.70
    rawTarget3 = close + forecastSide * baseDistance
    rawExtension = close + forecastSide * baseDistance * extensionFactor
    rawOpposite = close - forecastSide * math.max(atrSafe * 0.80, baseDistance * 0.18)
    rawInvalidation = close - forecastSide * math.max(atrSafe * 1.50, baseDistance * 0.40)

    snapDistance = atrSafe * structureSnapATR
    targetWantsHigh = not isBear
    oppositeWantsHigh = isBear

    forecastTarget1 := snapLevel(rawTarget1, snapDistance, structureSnapStrength, targetWantsHigh, close, forecastSide)
    forecastTarget2 := snapLevel(rawTarget2, snapDistance, structureSnapStrength, targetWantsHigh, close, forecastSide)
    forecastTarget3 := snapLevel(rawTarget3, snapDistance, structureSnapStrength, targetWantsHigh, close, forecastSide)
    forecastExtension := snapLevel(rawExtension, snapDistance, structureSnapStrength, targetWantsHigh, close, forecastSide)
    forecastOpposite := snapLevel(rawOpposite, snapDistance, structureSnapStrength, oppositeWantsHigh, close, -forecastSide)
    forecastInvalidation := snapLevel(rawInvalidation, snapDistance, structureSnapStrength, oppositeWantsHigh, close, -forecastSide)

    minimumSpacing = atrSafe * forecastZoneATR * 2.4

    if not isBear
        forecastTarget1 := math.max(forecastTarget1, close + minimumSpacing)
        forecastTarget2 := math.max(forecastTarget2, forecastTarget1 + minimumSpacing)
        forecastTarget3 := math.max(forecastTarget3, forecastTarget2 + minimumSpacing)
        forecastExtension := math.max(forecastExtension, forecastTarget3 + minimumSpacing)
        forecastOpposite := math.min(forecastOpposite, close - minimumSpacing)
        forecastInvalidation := math.min(forecastInvalidation, forecastOpposite - minimumSpacing)
    else
        forecastTarget1 := math.min(forecastTarget1, close - minimumSpacing)
        forecastTarget2 := math.min(forecastTarget2, forecastTarget1 - minimumSpacing)
        forecastTarget3 := math.min(forecastTarget3, forecastTarget2 - minimumSpacing)
        forecastExtension := math.min(forecastExtension, forecastTarget3 - minimumSpacing)
        forecastOpposite := math.max(forecastOpposite, close + minimumSpacing)
        forecastInvalidation := math.max(forecastInvalidation, forecastOpposite + minimumSpacing)

// ┌───────────────────────────── BOSWaves ─ Forecast Rendering ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

if barstate.islast
    if not na(pathOuter)
        polyline.delete(pathOuter)
        pathOuter := na

    if not na(pathInner)
        polyline.delete(pathInner)
        pathInner := na

    if not na(pathCenter)
        polyline.delete(pathCenter)
        pathCenter := na

    for b in forecastBoxes
        box.delete(b)
    forecastBoxes.clear()

    for l in forecastLines
        line.delete(l)
    forecastLines.clear()

    for lb in forecastLabels
        label.delete(lb)
    forecastLabels.clear()

    pathDataReady = forecastReady and not na(forecastTarget1) and not na(forecastTarget2) and not na(forecastTarget3) and not na(forecastExtension) and not na(forecastOpposite) and not na(forecastInvalidation)

    if pathDataReady
        pathClr = isBear ? bearPathClr : bullPathClr
        structuralClr = isBear ? bearStructClr : bullStructClr
        invalidationClr = isBear ? bullStructClr : bearStructClr

        displayBars = math.max(minForecastBars, int(math.round(calculatedForecastBars * pathStretch)))
        targetIdx = bar_index + displayBars
        levelStart = bar_index + math.max(3, int(math.round(displayBars * levelStartPct)))
        levelEnd = targetIdx + 12

        zoneHalfBase = atrSafe * forecastZoneATR
        momentumNorm = atrSafe > 0.0 ? (fastEMA - slowEMA) / atrSafe : 0.0
        momentumNorm := math.max(-1.0, math.min(1.0, momentumNorm))
        momentumBend = momentumNorm * atrSafe * pathBend

        dispersion = close * forecastStd / 100.0
        bandHalf = math.max(atrSafe * 0.32, dispersion * confidenceInterval)
        bandHalf := math.min(bandHalf, math.abs(forecastTarget3 - close) * 0.65)

        pathSteps = math.max(6, math.min(18, displayBars))

        if showPath
            outerPoints = buildBand(bar_index, targetIdx, close, forecastTarget3, bandHalf, momentumBend, 1.0, pathSteps)
            innerPoints = buildBand(bar_index, targetIdx, close, forecastTarget3, bandHalf, momentumBend, 0.55, pathSteps)
            centerPoints = buildCenter(bar_index, targetIdx, close, forecastTarget3, momentumBend, pathSteps)

            pathOuter := polyline.new(outerPoints, curved = false, closed = true, line_color = color.new(pathClr, 65), fill_color = color.new(pathClr, 91), line_width = 1)
            pathInner := polyline.new(innerPoints, curved = false, closed = true, line_color = color.new(pathClr, 28), fill_color = color.new(pathClr, 81), line_width = 2)
            pathCenter := polyline.new(centerPoints, curved = false, closed = false, line_color = pathClr, line_width = 3)

        if showForecastLevels
            levelValues = array.from(forecastTarget1, forecastTarget2, forecastTarget3, forecastExtension, forecastOpposite, forecastInvalidation)
            levelNames = array.from("Target 1", "Target 2", "Target 3", "Extension", isBear ? "Resistance" : "Support", "Invalidation")

            for i = 0 to math.min(levelValues.size() - 1, maxForecastLevels - 1)
                level = levelValues.get(i)
                name = levelNames.get(i)

                if not na(level)
                    levelClr = pathClr
                    zoneHalf = zoneHalfBase
                    outerAlpha = 92
                    middleAlpha = 86
                    innerAlpha = 76
                    lineAlpha = 12
                    lineWidth = 2
                    lineStyle = line.style_solid
                    labelAlpha = 16
                    labelSize = size.small

                    if i == 0
                        levelClr := isBear ? bearT1Clr : bullT1Clr
                        zoneHalf := zoneHalfBase * 0.70
                        outerAlpha := 94
                        middleAlpha := 90
                        innerAlpha := 84
                        lineAlpha := 24
                        lineWidth := 1
                        lineStyle := line.style_dotted

                    else if i == 1
                        levelClr := isBear ? bearT2Clr : bullT2Clr
                        zoneHalf := zoneHalfBase * 0.78
                        outerAlpha := 92
                        middleAlpha := 86
                        innerAlpha := 76
                        lineAlpha := 12
                        lineWidth := 2
                        lineStyle := line.style_dashed
                        labelSize := size.normal

                    else if i == 2
                        levelClr := isBear ? bearT3Clr : bullT3Clr
                        zoneHalf := zoneHalfBase * 0.92
                        outerAlpha := 88
                        middleAlpha := 75
                        innerAlpha := 56
                        lineAlpha := 0
                        lineWidth := 3
                        lineStyle := line.style_solid
                        labelAlpha := 0
                        labelSize := size.normal

                    else if i == 3
                        levelClr := extensionClr
                        zoneHalf := zoneHalfBase * 0.62
                        outerAlpha := 95
                        middleAlpha := 90
                        innerAlpha := 82
                        lineAlpha := 24
                        lineWidth := 1
                        lineStyle := line.style_dotted
                        labelAlpha := 20

                    else if i == 4
                        levelClr := structuralClr
                        zoneHalf := zoneHalfBase * 0.76
                        outerAlpha := 93
                        middleAlpha := 87
                        innerAlpha := 78
                        lineAlpha := 10
                        lineWidth := 2
                        lineStyle := line.style_solid
                        labelSize := size.normal

                    else
                        levelClr := invalidationClr
                        zoneHalf := zoneHalfBase * 0.68
                        outerAlpha := 95
                        middleAlpha := 90
                        innerAlpha := 84
                        lineAlpha := 25
                        lineWidth := 2
                        lineStyle := line.style_dashed
                        labelAlpha := 20

                    outerZone = box.new(levelStart, level + zoneHalf, levelEnd, level - zoneHalf, border_color = CLEAR, bgcolor = color.new(levelClr, outerAlpha))
                    middleZone = box.new(levelStart, level + zoneHalf * 0.62, levelEnd, level - zoneHalf * 0.62, border_color = CLEAR, bgcolor = color.new(levelClr, middleAlpha))
                    innerZone = box.new(levelStart, level + zoneHalf * 0.28, levelEnd, level - zoneHalf * 0.28, border_color = CLEAR, bgcolor = color.new(levelClr, innerAlpha))
                    levelLine = line.new(levelStart, level, levelEnd, level, color = color.new(levelClr, lineAlpha), width = lineWidth, style = lineStyle)

                    forecastBoxes.push(outerZone)
                    forecastBoxes.push(middleZone)
                    forecastBoxes.push(innerZone)
                    forecastLines.push(levelLine)

                    labelText = ""

                    if showLevelNames
                        labelText += name

                    if showPrices
                        if str.length(labelText) > 0
                            labelText += " "
                        labelText += str.tostring(level, format.mintick)

                    if str.length(labelText) > 0
                        levelLabel = label.new(levelEnd + 1, level, labelText, style = label.style_label_left, color = color.new(levelClr, labelAlpha), textcolor = levelTextClr, size = labelSize)
                        forecastLabels.push(levelLabel)

// ┌───────────────────────────── BOSWaves ─ Alerts ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

alertcondition(directionChanged and dir, title = "Market Path Bullish", message = "{{ticker}} Market Path Forecast flipped bullish")
alertcondition(directionChanged and not dir, title = "Market Path Bearish", message = "{{ticker}} Market Path Forecast flipped bearish")
````
