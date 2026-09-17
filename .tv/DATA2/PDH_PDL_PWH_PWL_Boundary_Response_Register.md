<!-- tradingview-pine-id: PUB;91c595a7afa44ee49e5889878a8cce78 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PDH PDL PWH PWL Boundary Response Register

Source: https://www.tradingview.com/script/fiN9VAJh-PDH-PDL-PWH-PWL-Boundary-Response-Register/

## Description

OVERVIEW

PDH PDL PWH PWL Boundary Response Register is an open-source prior-range research tool for time-based intraday charts and the 1D chart.

It plots four raw boundaries from completed higher-timeframe periods:

* PDH: Previous completed daily high
* PDL: Previous completed daily low
* PWH: Previous completed weekly high
* PWL: Previous completed weekly low

The script then records how the current day or week interacts with each boundary.

Its purpose is descriptive research. It does not calculate a conventional pivot ladder, assign support or resistance, predict direction, identify a target, generate entries or exits, or report win rates or profitability.

BOUNDARY LIFECYCLE

Each enabled boundary maintains an independent lifecycle for its active source period:

1. Untested

No confirmed contact has been recorded under the selected contact definition and tolerance.

2. Contacted

The boundary has received its first confirmed contact.

3. Sustained beyond

The configured number of consecutive confirmed closes finished beyond the boundary.

This state is independent of direct wick or body contact, so a price gap can satisfy the confirmed-close condition without first recording a conventional wick or body contact.

4. Re-entered

After Sustained beyond, a confirmed close crossed back through the boundary into the corresponding previous-day or previous-week range.

These states are factual classifications.

Sustained beyond does not mean that a breakout will continue. Re-entered does not mean that a reversal will follow.

CONTACT DEFINITIONS

The Contact definition input provides three research modes:

* Wick range: the confirmed bar's high-low range reaches the boundary.
* Candle body: the confirmed bar's open-close body reaches the boundary.
* Close-to-close span: two consecutive confirmed closes straddle the boundary, including a gap when the closes lie on opposite sides.

Contact tolerance can be configured as:

* Exact
* Ticks
* A fraction of the last completed daily ATR

These settings change the contact measurement rule. They do not change the underlying PDH, PDL, PWH, or PWL price.

POST-CONTACT RESPONSE REGISTER

After the first confirmed contact, the script can record an independent response profile for each boundary.

The measurements include:

* First-contact form: Gap beyond, Close through, Wick through, or Boundary touch.
* Confirmed post-contact observation count.
* Outside-close residency: the percentage of confirmed post-contact observations that closed beyond the boundary.
* Close-side recross count: the number of confirmed changes between the inside and outside sides of the boundary.
* Maximum outside excursion.
* Maximum return into the corresponding prior range.
* Chart bars from first contact to Sustained beyond.
* Chart bars from Sustained beyond to the first Re-entered event.

The register abbreviates two response fields:

OUT/X

* OUT: outside-close residency percentage.
* X: confirmed close-side recross count.

MAX O/I

* O: maximum outside excursion.
* I: maximum return into the corresponding prior range.

Maximum excursions are normalized with a daily ATR value frozen at the relevant daily or weekly reset.

These values describe the currently active source period. They are not historical probabilities, confidence scores, success rates, expectancy measurements, or performance statistics.

CROSS-HORIZON RANGE GEOMETRY

The register also measures how the completed daily and weekly ranges relate to each other.

Its cross-horizon fields include:

* The current confirmed close's coordinate inside the previous-day range.
* The current confirmed close's coordinate inside the previous-week range.
* Daily contact coverage for PDH and PDL.
* Weekly contact coverage for PWH and PWL.
* Bar separation between the two boundaries when both boundaries in a pair have been contacted.
* Daily and weekly range containment or overlap.
* The mathematical intersection of the previous daily and weekly ranges.
* The shared interval as a percentage of each prior range.
* Current day range use relative to the previous completed daily range.
* Current week range use relative to the previous completed weekly range.
* PDH/PWH separation in completed daily ATR units and ticks.
* PDL/PWL separation in completed daily ATR units and ticks.
* Configurable nearby-pair detection.
* A four-level hull formed by the outermost values of PDH, PDL, PWH, and PWL.
* The current close's coordinate inside that hull.
* The hull's upper and lower boundary anchors.
* The hull width in completed daily ATR units.
* State breadth across all enabled boundaries.

State breadth reports how many enabled boundaries have reached:

* C: Contacted
* S: Sustained beyond
* R: Re-entered

The shared corridor, nearby pairs, range relation, and four-level hull are geometric references.

The script does not classify them as support, resistance, liquidity, supply, demand, accumulation, distribution, institutional levels, or trade setups.

VISUAL OUTPUT

The default presentation includes:

* Distinct PDH, PDL, PWH, and PWL lines.
* Different default styling for daily and weekly boundaries.
* Optional prior-day and prior-week range ribbons.
* Optional shared-corridor highlighting.
* Optional nearby-pair highlighting.
* Historical daily and weekly segments with adjustable retention.
* Reduced emphasis for completed historical segments.
* Optional first-contact or full-lifecycle event marks.
* Compact right-edge identification tags.
* Automatic merging of nearby daily and weekly tags.
* Optional dotted leaders when a display tag is displaced from its exact boundary price.
* A fixed Boundary Response Register in the selected chart corner.

The right-edge tags use the currently visible chart range, visible bar count, completed daily ATR, and tick-size floors only to resolve annotation spacing and future-side placement.

The tags can reposition when the chart is scrolled or zoomed.

This visual repositioning does not change:

* The exact PDH, PDL, PWH, or PWL prices.
* Horizontal boundary-line prices.
* Lifecycle states.
* Post-contact response measurements.
* Range geometry.
* Alert conditions.

Exact prices and full state details remain available in the Boundary Response Register and label tooltips.

DATA HANDLING AND REALTIME BEHAVIOR

PDH, PDL, PWH, PWL, and the ATR normalization value are requested from completed higher-timeframe bars.

The expressions used with higher-timeframe lookahead are offset by one completed higher-timeframe bar before being used. The four active boundary prices therefore do not change during their corresponding current day or week.

Lifecycle and response events are committed on confirmed chart bars.

The combined dynamic alert also uses once-per-bar-close frequency.

Some current-context fields can continue changing while the realtime bar is open, including:

* Current close distance from each boundary.
* Current day range use.
* Current week range use.
* Developing current-period high and low values.

Those current-context fields are distinct from confirmed lifecycle history.

SOURCE MODES

Three reference-data modes are available:

Automatic

Uses the chart context on standard charts and standard-symbol candles on non-standard charts.

Chart context

Preserves the current chart's ticker context and modifiers.

Standard candles

Requests standard market candles without non-standard chart construction or other ticker modifiers.

When the selected event source has no usable bar aligned with the current chart timestamp, event evaluation pauses instead of treating an older forward-filled candle as a new observation.

NON-STANDARD CHARTS

Heikin Ashi, Renko, Kagi, Line Break, Point and Figure, Range, and other non-standard charts can contain synthetic OHLC values.

The completed daily and weekly boundaries remain available, but lifecycle events, current-range progress, and related alerts are disabled by default on non-standard charts.

Users can enable non-standard-chart event evaluation only for explicit research.

SUPPORTED TIMEFRAMES

The script supports:

* Time-based intraday charts.
* The 1D chart.

Tick charts and timeframes above 1D are excluded because their relationship with the requested event data would require ambiguous lower-timeframe reconstruction.

An on-chart notice is displayed when the selected timeframe is unsupported.

IMPORTANT 1D LIMITATION

On the 1D chart, the daily boundary lifecycle resets on each new daily bar.

PDH and PDL therefore cannot accumulate more than one daily close before the next daily reset.

When Closes required beyond is set above 1, the multi-close Sustained beyond state for PDH and PDL is primarily meaningful on intraday charts.

PWH and PWL can still accumulate multiple daily closes during the active week.

For full daily-boundary lifecycle and post-contact research, a time-based intraday chart is recommended.

ALERTS

Factual alert conditions are available for:

* First confirmed contact of any enabled boundary.
* First confirmed contact of each individual boundary.
* Sustained beyond for any enabled boundary.
* Sustained beyond for each individual boundary.
* Re-entered for any enabled boundary.
* Re-entered for each individual boundary.
* Formation of a nearby PDH/PWH pair.
* Formation of a nearby PDL/PWL pair.
* Completion of the daily contact pair.
* Completion of the weekly contact pair.
* A configurable outside-close residency threshold.
* A configurable maximum outside-excursion threshold.
* A combined confirmed-bar alert() message that consolidates simultaneous events.

Alerts report observed conditions only.

They do not instruct the user to buy, sell, enter, exit, place a stop, or select a profit target.

HOW TO USE

1. Apply the script to a standard time-based intraday chart or the 1D chart.

2. Select Automatic, Chart context, or Standard candles according to the data context being researched.

3. Enable daily and weekly boundaries and select the amount of historical retention.

4. Choose the contact definition and tolerance.

5. Select the number of confirmed closes required for Sustained beyond.

6. Read each boundary's lifecycle together with OUT/X and MAX O/I rather than interpreting a horizontal line in isolation.

7. Use the lower register rows to compare daily and weekly range geometry, shared overlap, current range use, pair spacing, hull position, and state breadth.

8. Adjust nearby-pair thresholds, historical event-mark density, right-edge tag content, and register size for the symbol and timeframe.

9. Use Market Replay and multiple symbols to verify customized settings before creating alerts.

WHY THIS IS A SEPARATE PUBLICATION

This study is separate from Previous Day Pivot Path - Intraday Support Resistance because the two scripts address different research questions and use different analytical structures.

Previous Day Pivot Path is a previous-day pivot-formula and arrival-order study. It calculates P, R, and S levels, supports pivot formula families, records first-arrival rank, distinguishes reached and unreached levels, and can emphasize the next unreached level. PDH and PDL are optional context references in that study.

Boundary Response Register calculates no:

* P/R/S ladder.
* CPR.
* Pivot formula family.
* Pivot arrival rank.
* Reached-versus-unreached path.
* Next unreached level.
* Next target.

Its four primary objects are the raw completed-period boundaries PDH, PDL, PWH, and PWL.

It tracks:

* Their independent lifecycle.
* Their post-contact response measurements.
* Daily and weekly range geometry.
* Shared range overlap.
* High-pair and low-pair spacing.
* Four-level hull position.
* State breadth.

Combining these functions into the existing pivot study would materially change that publication's purpose, supported horizon, default output, settings structure, alerts, and user workflow.

This is therefore a separate research tool rather than a minor visual variation or version update.

DISTINGUISHING DESIGN

Many previous-period high and low tools focus on one or more of the following:

* Drawing horizontal lines only.
* Tested or untested status.
* Swept or unswept status.
* Previous-month levels.
* Range midpoints or equilibrium levels.
* Nearest-target labels.
* Directional bias.
* Historical reach or break rates.
* Trade-plan instructions.

This implementation instead combines:

* Four raw completed daily and weekly boundaries.
* A four-stage lifecycle for each boundary.
* Confirmed post-contact response measurements.
* Frozen-ATR normalization of outside and inside excursions.
* Daily and weekly range-intersection geometry.
* Contact-pair timing.
* A four-level hull.
* State breadth.
* Neutral confirmed-bar alerts.
* Scale-aware annotation collision management.

The common PDH, PDL, PWH, and PWL inputs are objective completed-period prices.

The distinguishing purpose of this implementation is the state, response, geometry, source-handling, and visualization framework built around those four boundaries.

LIMITATIONS

* OHLC bars do not reveal the exact tick-by-tick sequence inside a candle.
* The script does not invent an intrabar event order.
* Contact results depend on the selected Wick range, Candle body, or Close-to-close span definition.
* Contact results also depend on the selected tolerance.
* Multiple events confirmed on the same chart bar are simultaneous at chart resolution unless the available data proves otherwise.
* Sustained beyond is a configurable confirmed-close condition, not proof that a move will continue.
* Re-entered is a recorded return through a boundary, not proof of reversal.
* ATR-normalized values depend on the symbol's completed daily data and the selected ATR length.
* Current day and week range-use values are incomplete while the current period is developing.
* The first loaded day or week can contain partial history if the chart dataset begins after that source period started.
* Session definitions, holidays, early closes, broker feeds, exchange data, and ticker modifiers can change completed-period OHLC values.
* Synthetic charts can produce event timing different from standard market candles.
* Historical drawing retention is limited by the selected settings and TradingView object limits.
* The visual annotation rail can move when the visible chart window changes.
* The script provides no entries, exits, targets, stops, position sizing, probability forecasts, or performance claims.

OPEN-SOURCE IMPLEMENTATION

The script is written in Pine Script v6 using Pine built-ins and independently implemented state, measurement, and drawing logic.

It imports no external libraries.

The source is published openly so users can inspect the calculations and adapt the research settings within TradingView's rules.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG_Group
// Independent implementation using standard OHLC, ATR, and Pine drawing primitives.
// v2.4.2: Publication hardening retained, with a three-layer scale-aware right-edge annotation system.
// A viewport-proportional future offset keeps tags away from the latest candles as horizontal zoom changes.
// Every active tag is resolved in one collision set using visible-bar range, completed daily ATR, and tick floors.
// High-boundary boxes render above their anchors and low-boundary boxes below them, preventing the overlap seen in v2.4.1.
// This is not a pivot-formula or pivot-arrival study: it calculates no P/R/S ladder, CPR, pivot rank, or next target.
// No explicit scale argument is declared: drawings inherit the symbol pane's main price scale.

//@version=6
indicator(
     "PDH PDL PWH PWL Boundary Response Register",
     overlay = true,
     behind_chart = false,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500)

//------------------------------------------------------------------------------
// Input groups
//------------------------------------------------------------------------------
const string G_DATA     = "Reference data and history"
const string G_LIFE     = "Boundary response lifecycle"
const string G_RESPONSE = "Post-contact response measurements"
const string G_CLUSTER  = "Cross-horizon range geometry"
const string G_LINES    = "Lines and range ribbons"
const string G_LABELS   = "Labels and event marks"
const string G_PANEL    = "Boundary response register"
const string G_ALERTS   = "Alerts"

//------------------------------------------------------------------------------
// Reference data and history
//------------------------------------------------------------------------------
string sourceMode = input.string(
     "Automatic",
     "Reference data",
     options = ["Automatic", "Chart context", "Standard candles"],
     tooltip = "Automatic uses the chart context on standard charts and standard-candle data on non-standard charts. Chart context preserves chart modifiers. Standard candles removes non-standard chart calculations and other ticker modifiers.",
     group = G_DATA,
     display = display.none)

bool showDaily = input.bool(
     true,
     "Show previous-day high and low",
     group = G_DATA,
     display = display.none)

bool showWeekly = input.bool(
     true,
     "Show previous-week high and low",
     group = G_DATA,
     display = display.none)

bool keepHistory = input.bool(
     true,
     "Keep completed period segments",
     tooltip = "Keeps prior daily and weekly line segments on the chart for historical study. Disable this to retain only the active day and week.",
     group = G_DATA,
     display = display.none)

int dailyPeriodsKept = input.int(
     30,
     "Daily periods kept",
     minval = 1,
     maxval = 120,
     active = keepHistory,
     group = G_DATA,
     display = display.none)

int weeklyPeriodsKept = input.int(
     16,
     "Weekly periods kept",
     minval = 1,
     maxval = 52,
     active = keepHistory,
     group = G_DATA,
     display = display.none)

int atrLength = input.int(
     14,
     "Daily ATR length",
     minval = 1,
     maxval = 100,
     tooltip = "Uses the last completed daily ATR value for normalized distances and optional tolerance calculations.",
     group = G_DATA,
     display = display.none)

bool allowNonStandardEvents = input.bool(
     false,
     "Allow lifecycle events on non-standard charts",
     tooltip = "Levels remain available on non-standard charts. Lifecycle events, current-range progress, and related alerts are paused by default because synthetic bar construction can make event timing ambiguous. Enable only for explicit research use.",
     group = G_DATA,
     display = display.none)

//------------------------------------------------------------------------------
// Interaction lifecycle
//------------------------------------------------------------------------------
string contactBasis = input.string(
     "Wick range",
     "Contact definition",
     options = ["Wick range", "Candle body", "Close-to-close span"],
     tooltip = "Wick range checks the confirmed bar's high-low span. Candle body checks the open-close span. Close-to-close span checks whether consecutive confirmed closes straddle the level, including a gap when the two closes lie on opposite sides.",
     group = G_LIFE,
     display = display.none)

string touchToleranceMode = input.string(
     "Exact",
     "Contact tolerance",
     options = ["Exact", "Ticks", "Daily ATR"],
     group = G_LIFE,
     display = display.none)

int touchToleranceTicks = input.int(
     0,
     "Tolerance in ticks",
     minval = 0,
     maxval = 1000,
     active = touchToleranceMode == "Ticks",
     group = G_LIFE,
     display = display.none)

float touchToleranceAtr = input.float(
     0.02,
     "Tolerance as daily ATR",
     minval = 0.0,
     maxval = 1.0,
     step = 0.01,
     active = touchToleranceMode == "Daily ATR",
     tooltip = "0.02 means 2% of the last completed daily ATR.",
     group = G_LIFE,
     display = display.none)

int holdCloseCount = input.int(
     2,
     "Closes required beyond",
     minval = 1,
     maxval = 10,
     tooltip = "A level enters Sustained beyond only after this many consecutive confirmed closes beyond it. This state is independent of direct wick/body contact, so a gap can qualify. It is descriptive, not a trade signal.",
     group = G_LIFE,
     display = display.none)

bool lifecycleLineStyling = input.bool(
     true,
     "Reflect lifecycle in line style",
     tooltip = "Untested levels use their selected base style. Contacted levels become dashed, Sustained beyond levels become emphasized, and Re-entered levels become dotted.",
     group = G_LIFE,
     display = display.none)

//------------------------------------------------------------------------------
// Post-contact response measurements
//------------------------------------------------------------------------------
bool trackResponseRegister = input.bool(
     true,
     "Track post-contact response",
     tooltip = "After a boundary's first confirmed contact, records outside-close residency, close-side recrosses, maximum outside excursion, maximum return into the prior range, the first-contact form, and lifecycle timing. These are descriptive measurements, not trade signals.",
     group = G_RESPONSE,
     display = display.none)

string responseExcursionSource = input.string(
     "Wicks",
     "Excursion measurement",
     options = ["Wicks", "Closes"],
     active = trackResponseRegister,
     tooltip = "Wicks uses confirmed bar highs/lows for maximum excursions. Closes uses confirmed closing prices. Outside-close residency always uses confirmed closes.",
     group = G_RESPONSE,
     display = display.none)

//------------------------------------------------------------------------------
// Level clustering
//------------------------------------------------------------------------------
bool showClusters = input.bool(
     true,
     "Highlight nearby day-week pairs",
     tooltip = "Highlights PDH near PWH and PDL near PWL. It does not classify a cluster as support or resistance.",
     group = G_CLUSTER,
     display = display.none)

string clusterMode = input.string(
     "Daily ATR",
     "Cluster threshold",
     options = ["Daily ATR", "Ticks", "Percent"],
     active = showClusters,
     group = G_CLUSTER,
     display = display.none)

float clusterAtr = input.float(
     0.12,
     "Threshold as daily ATR",
     minval = 0.0,
     maxval = 2.0,
     step = 0.01,
     active = showClusters and clusterMode == "Daily ATR",
     tooltip = "0.12 means the two levels are treated as nearby when their separation is no more than 12% of the last completed daily ATR.",
     group = G_CLUSTER,
     display = display.none)

int clusterTicks = input.int(
     25,
     "Threshold in ticks",
     minval = 0,
     maxval = 100000,
     active = showClusters and clusterMode == "Ticks",
     group = G_CLUSTER,
     display = display.none)

float clusterPercent = input.float(
     0.10,
     "Threshold in percent",
     minval = 0.0,
     maxval = 10.0,
     step = 0.01,
     active = showClusters and clusterMode == "Percent",
     tooltip = "0.10 means 0.10% of the two compared levels' mean absolute price.",
     group = G_CLUSTER,
     display = display.none)

color highClusterColor = input.color(
     color.rgb(255, 235, 59),
     "High-pair highlight",
     active = showClusters,
     group = G_CLUSTER,
     display = display.none)

color lowClusterColor = input.color(
     color.rgb(64, 255, 218),
     "Low-pair highlight",
     active = showClusters,
     group = G_CLUSTER,
     display = display.none)

int clusterTransparency = input.int(
     91,
     "Highlight transparency",
     minval = 70,
     maxval = 98,
     active = showClusters,
     group = G_CLUSTER,
     display = display.none)

bool showSharedCorridor = input.bool(
     true,
     "Show shared prior-range corridor",
     tooltip = "Highlights only the price interval shared by the previous completed daily range and the previous completed weekly range. This is a geometric overlap reference, not a support/resistance classification.",
     group = G_CLUSTER,
     display = display.none)

color sharedCorridorColor = input.color(
     color.rgb(82, 255, 255),
     "Shared-corridor color",
     active = showSharedCorridor,
     group = G_CLUSTER,
     display = display.none)

int sharedCorridorTransparency = input.int(
     95,
     "Shared-corridor transparency",
     minval = 80,
     maxval = 98,
     active = showSharedCorridor,
     group = G_CLUSTER,
     display = display.none)

//------------------------------------------------------------------------------
// Lines and range ribbons
//------------------------------------------------------------------------------
color pdhColor = input.color(
     color.rgb(0, 229, 255),
     "PDH color",
     group = G_LINES,
     display = display.none)

color pdlColor = input.color(
     color.rgb(118, 255, 3),
     "PDL color",
     group = G_LINES,
     display = display.none)

color pwhColor = input.color(
     color.rgb(213, 0, 249),
     "PWH color",
     group = G_LINES,
     display = display.none)

color pwlColor = input.color(
     color.rgb(255, 171, 0),
     "PWL color",
     group = G_LINES,
     display = display.none)

int dailyLineWidth = input.int(
     3,
     "Daily line width",
     minval = 1,
     maxval = 5,
     group = G_LINES,
     display = display.none)

int weeklyLineWidth = input.int(
     4,
     "Weekly line width",
     minval = 1,
     maxval = 5,
     group = G_LINES,
     display = display.none)

bool showActiveLineHalo = input.bool(
     true,
     "Add active-level contrast halo",
     tooltip = "Draws a chart-background-colored outline beneath the four active levels. The outline stays on the symbol's main price scale and improves separation from candles, grids, and range shading.",
     group = G_LINES,
     display = display.none)

int activeHaloExtraWidth = input.int(
     2,
     "Halo width addition",
     minval = 1,
     maxval = 4,
     active = showActiveLineHalo,
     group = G_LINES,
     display = display.none)

int activeHaloTransparency = input.int(
     12,
     "Halo transparency",
     minval = 0,
     maxval = 70,
     active = showActiveLineHalo,
     tooltip = "Lower values create a stronger separation outline. The outline automatically follows the chart background color.",
     group = G_LINES,
     display = display.none)

bool dimHistoricalSegments = input.bool(
     true,
     "Dim completed period segments",
     tooltip = "Keeps historical study context while making the four currently active levels visually dominant.",
     group = G_LINES,
     display = display.none)

int historicalLineTransparency = input.int(
     58,
     "Completed-segment transparency",
     minval = 0,
     maxval = 95,
     active = dimHistoricalSegments,
     group = G_LINES,
     display = display.none)

int historicalWidthReduction = input.int(
     1,
     "Completed-segment width reduction",
     minval = 0,
     maxval = 4,
     active = dimHistoricalSegments,
     group = G_LINES,
     display = display.none)

string dailyLineStyleInput = input.string(
     "Solid",
     "Daily base line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = G_LINES,
     display = display.none)

string weeklyLineStyleInput = input.string(
     "Dashed",
     "Weekly base line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = G_LINES,
     display = display.none)

bool showRangeRibbons = input.bool(
     true,
     "Show prior-range ribbons",
     tooltip = "Adds very light ribbons between PDH-PDL and PWH-PWL. The ribbons are visual references only.",
     group = G_LINES,
     display = display.none)

color dailyRibbonColor = input.color(
     color.new(color.rgb(0, 188, 212), 96),
     "Daily ribbon",
     active = showRangeRibbons,
     group = G_LINES,
     display = display.none)

color weeklyRibbonColor = input.color(
     color.new(color.rgb(156, 39, 176), 97),
     "Weekly ribbon",
     active = showRangeRibbons,
     group = G_LINES,
     display = display.none)

//------------------------------------------------------------------------------
// Labels and event marks
//------------------------------------------------------------------------------
bool showRightLabels = input.bool(
     true,
     "Show right-edge level labels",
     group = G_LABELS,
     display = display.none)

string rightLabelContent = input.string(
     "Code only",
     "Right-label content",
     options = ["Code + price", "Code only", "Code + lifecycle"],
     active = showRightLabels,
     tooltip = "Code only is the compact default. Exact prices and lifecycle details remain available in the Boundary Response Register and label tooltips.",
     group = G_LABELS,
     display = display.none)

string rightLabelPlacementMode = input.string(
     "Responsive",
     "Right-label horizontal placement",
     options = ["Responsive", "Fixed bars"],
     active = showRightLabels,
     tooltip = "Responsive converts a percentage of the currently visible bar count into the future-bar offset, keeping a more consistent screen-space distance as horizontal zoom changes. Fixed bars uses only the minimum/fixed offset below.",
     group = G_LABELS,
     display = display.none)

float rightLabelViewportPercent = input.float(
     8.0,
     "Responsive offset as visible width (%)",
     minval = 2.0,
     maxval = 25.0,
     step = 0.5,
     active = showRightLabels and rightLabelPlacementMode == "Responsive",
     tooltip = "Approximate share of the visible bar count reserved between the latest bar and the annotation rail. The result is capped below Pine's 500-bar future-drawing limit and never falls below the minimum offset.",
     group = G_LABELS,
     display = display.none)

bool splitRightLabelLanes = input.bool(
     true,
     "Stagger daily and weekly rail anchors",
     active = showRightLabels,
     tooltip = "When enabled, weekly annotations use a second horizontal anchor lane. Responsive placement can enlarge the gutter as the visible bar count increases.",
     group = G_LABELS,
     display = display.none)

bool mergeNearbyRightLabels = input.bool(
     true,
     "Merge nearby day/week labels",
     active = showRightLabels and showClusters,
     tooltip = "When PDH is within the configured proximity threshold of PWH, or PDL is near PWL, the two chart tags collapse into PDH/PWH or PDL/PWL. Exact prices, states, and separate horizontal levels remain unchanged and are preserved in the tooltip and register.",
     group = G_LABELS,
     display = display.none)

int rightLabelOffset = input.int(
     12,
     "Minimum / fixed right-label offset",
     minval = 4,
     maxval = 200,
     active = showRightLabels,
     tooltip = "Minimum future-bar distance used by Responsive placement, or the exact distance used by Fixed bars placement.",
     group = G_LABELS,
     display = display.none)

int rightLabelLaneGutter = input.int(
     4,
     "Daily-weekly rail stagger",
     minval = 1,
     maxval = 20,
     active = showRightLabels and splitRightLabelLanes,
     tooltip = "Minimum additional future bars between daily and weekly anchor points. Responsive placement can enlarge this gutter in proportion to the visible bar count.",
     group = G_LABELS,
     display = display.none)

bool autoSeparateSameLaneLabels = input.bool(
     true,
     "Auto-separate close rail labels",
     active = showRightLabels,
     tooltip = "Resolves every active right-edge tag in one collision set, including merged pairs and cross-group labels. Exact boundary prices and horizontal lines remain unchanged. Optional leader segments identify displaced tags.",
     group = G_LABELS,
     display = display.none)

float rightLabelMinimumGapAtr = input.float(
     0.30,
     "Minimum rail-label gap as daily ATR",
     minval = 0.0,
     maxval = 2.0,
     step = 0.05,
     active = showRightLabels and autoSeparateSameLaneLabels,
     tooltip = "Minimum visual separation between nearby display tags, expressed as a fraction of the last completed daily ATR.",
     group = G_LABELS,
     display = display.none)

int rightLabelMinimumGapTicks = input.int(
     12,
     "Minimum rail-label gap in ticks",
     minval = 0,
     maxval = 10000,
     active = showRightLabels and autoSeparateSameLaneLabels,
     tooltip = "Tick-based floor for automatic rail-label separation. The larger of this value and the ATR-based value is used.",
     group = G_LABELS,
     display = display.none)

bool useVisibleRangeLabelGap = input.bool(
     true,
     "Scale-aware rail-label spacing",
     active = showRightLabels and autoSeparateSameLaneLabels,
     tooltip = "Adds a spacing floor derived from the highest and lowest visible chart bars. The script recalculates this floor when the visible window changes, so label separation adapts when the chart is scrolled or zoomed.",
     group = G_LABELS,
     display = display.none)

float rightLabelMinimumGapVisiblePercent = input.float(
     6.0,
     "Minimum rail-label gap as visible range (%)",
     minval = 0.0,
     maxval = 20.0,
     step = 0.25,
     active = showRightLabels and autoSeparateSameLaneLabels and useVisibleRangeLabelGap,
     tooltip = "Minimum display-anchor separation as a percentage of the visible bars' high-low range. The final gap is the largest of this value, the daily-ATR floor, and the tick floor.",
     group = G_LABELS,
     display = display.none)

bool showRightLabelLeaders = input.bool(
     true,
     "Show displaced-label leaders",
     active = showRightLabels and autoSeparateSameLaneLabels,
     tooltip = "Draws a short dotted segment between the exact boundary price and a display tag that was shifted vertically. Merged pair tags can receive one leader from each exact boundary.",
     group = G_LABELS,
     display = display.none)

string labelSizeInput = input.string(
     "Large",
     "Right-label size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     active = showRightLabels,
     group = G_LABELS,
     display = display.none)

string eventMarkMode = input.string(
     "First contact",
     "Historical event marks",
     options = ["Off", "First contact", "Full lifecycle"],
     tooltip = "First contact marks only the first confirmed contact per level and period. Full lifecycle also marks the first Sustained beyond and first Re-entered event.",
     group = G_LABELS,
     display = display.none)

string eventMarkContent = input.string(
     "Symbol only",
     "Event-mark content",
     options = ["Symbol only", "Symbol + code"],
     active = eventMarkMode != "Off",
     tooltip = "Symbol only is the cleaner default. Colors identify PDH, PDL, PWH, and PWL, while tooltips preserve the full event description.",
     group = G_LABELS,
     display = display.none)

int eventMarksKept = input.int(
     90,
     "Event marks kept",
     minval = 10,
     maxval = 450,
     active = eventMarkMode != "Off",
     group = G_LABELS,
     display = display.none)

string eventMarkSizeInput = input.string(
     "Normal",
     "Event-mark size",
     options = ["Tiny", "Small", "Normal"],
     active = eventMarkMode != "Off",
     group = G_LABELS,
     display = display.none)

//------------------------------------------------------------------------------
// Boundary response register
//------------------------------------------------------------------------------
bool showPanel = input.bool(
     true,
     "Show boundary response register",
     group = G_PANEL,
     display = display.none)

string panelPositionInput = input.string(
     "Top right",
     "Register position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left"],
     active = showPanel,
     group = G_PANEL,
     display = display.none)

string panelSizePresetInput = input.string(
     "Compact",
     "Register size",
     options = ["Compact", "Balanced", "Presentation", "Custom"],
     active = showPanel,
     tooltip = "Compact is the default and is designed to preserve chart space while keeping every visible cell bold and high contrast. Balanced adds moderate size. Presentation restores the large publication-oriented scale. Custom unlocks the three point-size inputs below.",
     group = G_PANEL,
     display = display.none)

int panelBodyTextSizeInput = input.int(
     13,
     "Custom body text size (pt)",
     minval = 9,
     maxval = 26,
     active = showPanel and panelSizePresetInput == "Custom",
     tooltip = "Used only when Register size is Custom. All visible register text remains bold.",
     group = G_PANEL,
     display = display.none)

int panelColumnTextSizeInput = input.int(
     14,
     "Custom column text size (pt)",
     minval = 10,
     maxval = 28,
     active = showPanel and panelSizePresetInput == "Custom",
     group = G_PANEL,
     display = display.none)

int panelTitleTextSizeInput = input.int(
     16,
     "Custom title text size (pt)",
     minval = 12,
     maxval = 32,
     active = showPanel and panelSizePresetInput == "Custom",
     group = G_PANEL,
     display = display.none)

string panelFontInput = input.string(
     "Default",
     "Register font",
     options = ["Default", "Monospace"],
     active = showPanel,
     tooltip = "Default uses the system's proportional chart font and generally appears heavier. Monospace remains available for fixed-width numerical alignment.",
     group = G_PANEL,
     display = display.none)

color panelBackground = input.color(
     color.rgb(0, 3, 9),
     "Register background",
     active = showPanel,
     group = G_PANEL,
     display = display.none)

color panelHeader = input.color(
     color.rgb(0, 229, 255),
     "Register header",
     active = showPanel,
     group = G_PANEL,
     display = display.none)

color panelTextColor = input.color(
     color.rgb(250, 252, 255),
     "Primary text",
     active = showPanel,
     group = G_PANEL,
     display = display.none)

color panelMutedTextColor = input.color(
     color.rgb(222, 231, 245),
     "Secondary text",
     active = showPanel,
     group = G_PANEL,
     display = display.none)

color panelGridColor = input.color(
     color.new(color.white, 24),
     "Register grid",
     active = showPanel,
     group = G_PANEL,
     display = display.none)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
bool enableDynamicAlerts = input.bool(
     false,
     "Enable combined dynamic alert()",
     tooltip = "When enabled, confirmed lifecycle, completed contact-pair, and response-threshold events on the same bar are combined into one alert() message. Create the TradingView alert using Any alert() function call.",
     group = G_ALERTS,
     display = display.none)

int responseAlertMinimumBars = input.int(
     4,
     "Minimum response observations",
     minval = 1,
     maxval = 100,
     active = trackResponseRegister,
     tooltip = "Minimum confirmed post-contact observations required before an outside-close residency threshold can trigger.",
     group = G_ALERTS,
     display = display.none)

float responseOutsideShareThreshold = input.float(
     75.0,
     "Outside-close residency threshold (%)",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     active = trackResponseRegister,
     tooltip = "Triggers once per boundary and source period when the outside-close share reaches this threshold after the minimum observation count.",
     group = G_ALERTS,
     display = display.none)

float responseExcursionThresholdAtr = input.float(
     0.50,
     "Outside-excursion threshold (ATR)",
     minval = 0.0,
     maxval = 20.0,
     step = 0.05,
     active = trackResponseRegister,
     tooltip = "Triggers once per boundary and source period when maximum outside excursion reaches this many frozen daily ATR units.",
     group = G_ALERTS,
     display = display.none)

//------------------------------------------------------------------------------
// Utility functions
//------------------------------------------------------------------------------
f_lineStyle(string styleName) =>
    switch styleName
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_size(string sizeName) =>
    switch sizeName
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_panelPosition(string positionName) =>
    switch positionName
        "Top left"     => position.top_left
        "Bottom right" => position.bottom_right
        "Bottom left"  => position.bottom_left
        => position.top_right

f_panelFont(string fontName) =>
    fontName == "Monospace" ? font.family_monospace : font.family_default

f_contrastText(color backgroundColor) =>
    float luminance = 0.299 * color.r(backgroundColor) + 0.587 * color.g(backgroundColor) + 0.114 * color.b(backgroundColor)
    luminance >= 165.0 ? color.black : color.white

f_trimLines(array<line> ids, int maximum) =>
    while array.size(ids) > maximum
        line.delete(array.shift(ids))

f_trimBoxes(array<box> ids, int maximum) =>
    while array.size(ids) > maximum
        box.delete(array.shift(ids))

f_trimLabels(array<label> ids, int maximum) =>
    while array.size(ids) > maximum
        label.delete(array.shift(ids))

f_signedNumber(float value) =>
    na(value) ? "n/a" : (value > 0.0 ? "+" : "") + str.tostring(value, "#.##")

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_percent(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_atrMetric(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

f_rangeCoordinate(float value, float upper, float lower) =>
    not na(value) and not na(upper) and not na(lower) and upper > lower ? (value - lower) / (upper - lower) * 100.0 : na

f_coordinateText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_gaugeIcon(float value) =>
    if na(value)
        "·"
    else
        float bounded = math.max(0.0, math.min(100.0, value))
        bounded < 20.0 ? "○" : bounded < 40.0 ? "◔" : bounded < 60.0 ? "◑" : bounded < 80.0 ? "◕" : "●"

f_levelGlyph(string code) =>
    code == "PDH" or code == "PWH" ? "▲" : "▼"

f_pairGapText(float firstLevel, float secondLevel, float normalizerAtr) =>
    if na(firstLevel) or na(secondLevel)
        "n/a"
    else
        float gap = math.abs(firstLevel - secondLevel)
        string atrPart = not na(normalizerAtr) and normalizerAtr > 0.0 ? str.tostring(gap / normalizerAtr, "#.##") + " ATR" : "ATR n/a"
        string tickPart = syminfo.mintick > 0.0 ? str.tostring(math.round(gap / syminfo.mintick)) + " T" : "T n/a"
        atrPart + " | " + tickPart

f_append(string baseText, string addition) =>
    baseText == "" ? addition : baseText + " | " + addition

f_relation(float dayHigh, float dayLow, float weekHigh, float weekLow) =>
    string result = "Unavailable"
    float epsilon = syminfo.mintick * 2.0
    if not na(dayHigh) and not na(dayLow) and not na(weekHigh) and not na(weekLow)
        if dayLow > weekHigh + epsilon
            result := "Day entirely above week"
        else if dayHigh < weekLow - epsilon
            result := "Day entirely below week"
        else if dayLow >= weekLow - epsilon and dayHigh <= weekHigh + epsilon
            result := "Day inside week"
        else if dayLow <= weekLow + epsilon and dayHigh >= weekHigh - epsilon
            result := "Day envelops week"
        else if dayHigh > weekHigh and dayLow > weekLow
            result := "Upper overlap"
        else if dayHigh < weekHigh and dayLow < weekLow
            result := "Lower overlap"
        else
            result := "Overlapping"
    result

f_location(float value, float upper, float lower, string upperCode, string lowerCode) =>
    na(value) or na(upper) or na(lower) ? "Unavailable" : value > upper ? "Above " + upperCode : value < lower ? "Below " + lowerCode : "Inside " + upperCode + " / " + lowerCode

f_lifecycleCode(string lifecycle) =>
    lifecycle == "Re-entered" ? "R" : lifecycle == "Sustained beyond" ? "S" : lifecycle == "Contacted" ? "C" : lifecycle == "Untested" ? "U" : "—"

f_rightLabelText(string code, float level, string lifecycle) =>
    string prefix = f_levelGlyph(code) + " " + code
    switch rightLabelContent
        "Code only"        => prefix
        "Code + lifecycle" => prefix + " · " + f_lifecycleCode(lifecycle)
        => prefix + " · " + f_price(level)

f_pairRightLabelText(string firstCode, float firstLevel, string firstLifecycle, string secondCode, float secondLevel, string secondLifecycle) =>
    string prefix = f_levelGlyph(firstCode) + " " + firstCode + "/" + secondCode
    switch rightLabelContent
        "Code only"        => prefix
        "Code + lifecycle" => prefix + " · " + f_lifecycleCode(firstLifecycle) + "/" + f_lifecycleCode(secondLifecycle)
        => prefix + " · " + f_price(firstLevel) + "/" + f_price(secondLevel)

f_eventMarkText(string symbolText, string code) =>
    eventMarkContent == "Symbol + code" ? symbolText + " " + code : symbolText

f_updateRightLeader(line currentLine, bool shouldShow, int xPosition, float exactY, float displayY, color levelColor) =>
    line result = currentLine
    bool displaced = shouldShow and not na(exactY) and not na(displayY) and math.abs(displayY - exactY) > syminfo.mintick * 0.25
    if displaced
        color leaderColor = color.new(levelColor, 12)
        if na(result)
            result := line.new(
                 x1 = xPosition,
                 y1 = exactY,
                 x2 = xPosition,
                 y2 = displayY,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = leaderColor,
                 style = line.style_dotted,
                 width = 2)
        else
            line.set_xy1(result, xPosition, exactY)
            line.set_xy2(result, xPosition, displayY)
            line.set_color(result, leaderColor)
            line.set_style(result, line.style_dotted)
            line.set_width(result, 2)
    else if not na(result)
        line.delete(result)
        result := na
    result

f_updateRightLabel(label currentLabel, bool shouldShow, int xPosition, float yPosition, string textValue, string tooltipValue, color backgroundColor, string styleValue) =>
    label result = currentLabel
    color readableBackground = color.new(backgroundColor, 0)
    color readableText = f_contrastText(readableBackground)
    string textAlignment = styleValue == label.style_label_right ? text.align_right : styleValue == label.style_label_left ? text.align_left : text.align_center
    if shouldShow and not na(yPosition)
        if na(result)
            result := label.new(
                 x = xPosition,
                 y = yPosition,
                 text = textValue,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = styleValue,
                 color = readableBackground,
                 textcolor = readableText,
                 size = f_size(labelSizeInput),
                 textalign = textAlignment,
                 text_font_family = font.family_default,
                 text_formatting = text.format_bold,
                 tooltip = tooltipValue)
        else
            label.set_x(result, xPosition)
            label.set_y(result, yPosition)
            label.set_text(result, textValue)
            label.set_tooltip(result, tooltipValue)
            label.set_color(result, readableBackground)
            label.set_textcolor(result, readableText)
            label.set_size(result, f_size(labelSizeInput))
            label.set_style(result, styleValue)
            label.set_textalign(result, textAlignment)
            label.set_text_font_family(result, font.family_default)
            label.set_text_formatting(result, text.format_bold)
    else if not na(result)
        label.delete(result)
        result := na
    result

//------------------------------------------------------------------------------
// Resolved source and requested data
//------------------------------------------------------------------------------
bool useStandardSource = sourceMode == "Standard candles" or (sourceMode == "Automatic" and not chart.is_standard)
string referenceTicker = useStandardSource ? ticker.standard(syminfo.tickerid) : syminfo.tickerid
string resolvedSourceName = useStandardSource ? "Standard candles" : "Chart context"

bool atOrBelowOneDay = timeframe.isticks or timeframe.isintraday or (timeframe.isdaily and timeframe.multiplier == 1)
bool supportedTimeframe = (timeframe.isintraday and not timeframe.isticks) or (timeframe.isdaily and timeframe.multiplier == 1)
bool lifecycleEvaluationAllowed = supportedTimeframe and (chart.is_standard or allowNonStandardEvents)
string dailyRequestTimeframe = atOrBelowOneDay ? "D" : timeframe.main_period
string weeklyRequestTimeframe = atOrBelowOneDay ? "W" : timeframe.main_period
string eventRequestTimeframe = supportedTimeframe ? timeframe.main_period : dailyRequestTimeframe

[pdh, pdl, completedDailyAtr] = request.security(
     referenceTicker,
     dailyRequestTimeframe,
     [high[1], low[1], ta.atr(atrLength)[1]],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

[pwh, pwl] = request.security(
     referenceTicker,
     weeklyRequestTimeframe,
     [high[1], low[1]],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

// Period timestamps are known at the opening of each chart-context day/week and do not
// require a higher-timeframe request with lookahead. The requested price/ATR series above
// remain fully offset to the last completed higher-timeframe bar.
int dayStart = time(dailyRequestTimeframe)
int weekStart = time(weeklyRequestTimeframe)

[eventTime, eventOpen, eventHigh, eventLow, eventClose] = request.security(
     referenceTicker,
     eventRequestTimeframe,
     [time, open, high, low, close],
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

bool newDay = supportedTimeframe and not na(dayStart) and (na(dayStart[1]) or dayStart != dayStart[1])
bool newWeek = supportedTimeframe and not na(weekStart) and (na(weekStart[1]) or weekStart != weekStart[1])
bool eventSourceReady = not na(eventTime) and not na(eventOpen) and not na(eventHigh) and not na(eventLow) and not na(eventClose)
int barRightTime = na(time_close) ? time : time_close

bool touchToleranceReady = touchToleranceMode != "Daily ATR" or (not na(completedDailyAtr) and completedDailyAtr > 0.0)
float touchTolerance = switch touchToleranceMode
    "Ticks"     => syminfo.mintick * touchToleranceTicks
    "Daily ATR" => touchToleranceReady ? completedDailyAtr * touchToleranceAtr : na
    => 0.0

f_clusterThreshold(float firstLevel, float secondLevel) =>
    float pairReference = (math.abs(firstLevel) + math.abs(secondLevel)) * 0.5
    switch clusterMode
        "Ticks"   => syminfo.mintick * clusterTicks
        "Percent" => pairReference * clusterPercent / 100.0
        => not na(completedDailyAtr) and completedDailyAtr > 0.0 ? completedDailyAtr * clusterAtr : na

float highClusterThreshold = f_clusterThreshold(pdh, pwh)
float lowClusterThreshold = f_clusterThreshold(pdl, pwl)

//------------------------------------------------------------------------------
// Boundary lifecycle and response storage
// Index order: 0 PDH, 1 PDL, 2 PWH, 3 PWL
//------------------------------------------------------------------------------
var array<bool> levelContacted = array.new_bool(4, false)
var array<bool> levelHeldOutside = array.new_bool(4, false)
var array<bool> levelReturned = array.new_bool(4, false)
var array<bool> levelContactNow = array.new_bool(4, false)
var array<int> levelOutsideSequence = array.new_int(4, 0)
var array<int> levelContactEpisodes = array.new_int(4, 0)
var array<int> levelFirstContactTime = array.new_int(4, na)
var array<int> levelHeldTime = array.new_int(4, na)
var array<int> levelReturnTime = array.new_int(4, na)
var array<int> levelFirstContactBar = array.new_int(4, na)
var array<int> levelHeldBar = array.new_int(4, na)
var array<int> levelReturnBar = array.new_int(4, na)
var array<int> levelResponseBars = array.new_int(4, 0)
var array<int> levelOutsideCloses = array.new_int(4, 0)
var array<int> levelCloseRecrosses = array.new_int(4, 0)
var array<bool> levelHasResponseSample = array.new_bool(4, false)
var array<bool> levelLastResponseOutside = array.new_bool(4, false)
var array<float> levelMaxOutsideExcursion = array.new_float(4, 0.0)
var array<float> levelMaxInsideExcursion = array.new_float(4, 0.0)
var array<float> levelAnchorAtr = array.new_float(4, na)
var array<string> levelFirstContactForm = array.new_string(4, "")
var array<bool> levelResidencyAlerted = array.new_bool(4, false)
var array<bool> levelExcursionAlerted = array.new_bool(4, false)

f_resetLevel(int index, float anchorAtr) =>
    array.set(levelContacted, index, false)
    array.set(levelHeldOutside, index, false)
    array.set(levelReturned, index, false)
    array.set(levelContactNow, index, false)
    array.set(levelOutsideSequence, index, 0)
    array.set(levelContactEpisodes, index, 0)
    array.set(levelFirstContactTime, index, na)
    array.set(levelHeldTime, index, na)
    array.set(levelReturnTime, index, na)
    array.set(levelFirstContactBar, index, na)
    array.set(levelHeldBar, index, na)
    array.set(levelReturnBar, index, na)
    array.set(levelResponseBars, index, 0)
    array.set(levelOutsideCloses, index, 0)
    array.set(levelCloseRecrosses, index, 0)
    array.set(levelHasResponseSample, index, false)
    array.set(levelLastResponseOutside, index, false)
    array.set(levelMaxOutsideExcursion, index, 0.0)
    array.set(levelMaxInsideExcursion, index, 0.0)
    array.set(levelAnchorAtr, index, anchorAtr)
    array.set(levelFirstContactForm, index, "")
    array.set(levelResidencyAlerted, index, false)
    array.set(levelExcursionAlerted, index, false)

f_updateLevel(
     int index,
     float level,
     int side,
     bool resetNow,
     bool canTrack,
     bool enabled,
     float o,
     float h,
     float l,
     float c,
     float previousClose,
     int eventTimestamp,
     float tolerance,
     string basis,
     int requiredCloses,
     float normalizerAtr,
     bool trackResponse,
     string excursionSource) =>
    if resetNow
        f_resetLevel(index, normalizerAtr)

    bool contactEvent = false
    bool heldEvent = false
    bool returnEvent = false

    bool validBar = enabled and canTrack and barstate.isconfirmed and not na(level) and not na(o) and not na(h) and not na(l) and not na(c) and not na(eventTimestamp) and not na(tolerance)
    if validBar
        bool contact = switch basis
            "Candle body" => math.max(o, c) >= level - tolerance and math.min(o, c) <= level + tolerance
            "Close-to-close span" => not na(previousClose) and math.max(previousClose, c) >= level - tolerance and math.min(previousClose, c) <= level + tolerance
            => h >= level - tolerance and l <= level + tolerance

        bool outside = side > 0 ? c > level + tolerance : c < level - tolerance
        bool priorOutside = not na(previousClose) and (side > 0 ? previousClose > level + tolerance : previousClose < level - tolerance)
        bool openedOutside = side > 0 ? o > level + tolerance : o < level - tolerance
        bool wickOutside = side > 0 ? h > level + tolerance : l < level - tolerance

        bool priorContact = array.get(levelContactNow, index)
        if contact and not priorContact
            array.set(levelContactEpisodes, index, array.get(levelContactEpisodes, index) + 1)

        if contact and not array.get(levelContacted, index)
            array.set(levelContacted, index, true)
            array.set(levelFirstContactTime, index, eventTimestamp)
            array.set(levelFirstContactBar, index, bar_index)
            string contactForm = openedOutside and not na(previousClose) and not priorOutside ? "Gap beyond" : outside ? "Close through" : wickOutside ? "Wick through" : "Boundary touch"
            array.set(levelFirstContactForm, index, contactForm)
            contactEvent := true

        int outsideSequence = outside ? array.get(levelOutsideSequence, index) + 1 : 0
        array.set(levelOutsideSequence, index, outsideSequence)

        if outsideSequence >= requiredCloses and not array.get(levelHeldOutside, index)
            array.set(levelHeldOutside, index, true)
            array.set(levelHeldTime, index, eventTimestamp)
            array.set(levelHeldBar, index, bar_index)
            heldEvent := true

        bool returnedThrough = side > 0 ? c <= level + tolerance : c >= level - tolerance
        if array.get(levelHeldOutside, index) and not array.get(levelReturned, index) and returnedThrough
            array.set(levelReturned, index, true)
            array.set(levelReturnTime, index, eventTimestamp)
            array.set(levelReturnBar, index, bar_index)
            returnEvent := true

        if trackResponse and array.get(levelContacted, index)
            int observations = array.get(levelResponseBars, index) + 1
            array.set(levelResponseBars, index, observations)
            if outside
                array.set(levelOutsideCloses, index, array.get(levelOutsideCloses, index) + 1)

            bool hasSample = array.get(levelHasResponseSample, index)
            bool lastOutside = array.get(levelLastResponseOutside, index)
            if hasSample and outside != lastOutside
                array.set(levelCloseRecrosses, index, array.get(levelCloseRecrosses, index) + 1)
            array.set(levelHasResponseSample, index, true)
            array.set(levelLastResponseOutside, index, outside)

            float outsideSource = excursionSource == "Closes" ? c : (side > 0 ? h : l)
            float insideSource = excursionSource == "Closes" ? c : (side > 0 ? l : h)
            float outsideExcursion = side > 0 ? math.max(0.0, outsideSource - level) : math.max(0.0, level - outsideSource)
            float insideExcursion = side > 0 ? math.max(0.0, level - insideSource) : math.max(0.0, insideSource - level)
            array.set(levelMaxOutsideExcursion, index, math.max(array.get(levelMaxOutsideExcursion, index), outsideExcursion))
            array.set(levelMaxInsideExcursion, index, math.max(array.get(levelMaxInsideExcursion, index), insideExcursion))

        array.set(levelContactNow, index, contact)

    [contactEvent, heldEvent, returnEvent]

f_lifecycle(int index, bool canTrack, bool canEvaluate, bool sourceReady) =>
    not canEvaluate ? "Paused" : not sourceReady ? "Source gap" : not touchToleranceReady ? "Warming up" : not canTrack ? "Partial history" : array.get(levelReturned, index) ? "Re-entered" : array.get(levelHeldOutside, index) ? "Sustained beyond" : array.get(levelContacted, index) ? "Contacted" : "Untested"

f_lifecycleCompact(int index, bool canTrack, bool canEvaluate, bool sourceReady) =>
    not canEvaluate ? "PAUSED" : not sourceReady ? "SOURCE GAP" : not touchToleranceReady ? "WARM-UP" : not canTrack ? "PARTIAL" : array.get(levelReturned, index) ? "RE-ENTERED" : array.get(levelHeldOutside, index) ? "BEYOND" : array.get(levelContacted, index) ? "CONTACTED" : "UNTESTED"

f_outsideShare(int index) =>
    int observations = array.get(levelResponseBars, index)
    observations > 0 ? array.get(levelOutsideCloses, index) * 100.0 / observations : na

f_responseAtr(int index, bool outsideMetric) =>
    float anchorAtr = array.get(levelAnchorAtr, index)
    float rawValue = outsideMetric ? array.get(levelMaxOutsideExcursion, index) : array.get(levelMaxInsideExcursion, index)
    not na(anchorAtr) and anchorAtr > 0.0 ? rawValue / anchorAtr : na

f_contactFormCompact(int index) =>
    string form = array.get(levelFirstContactForm, index)
    form == "Gap beyond" ? "GAP" : form == "Close through" ? "CLOSE" : form == "Wick through" ? "WICK" : form == "Boundary touch" ? "TOUCH" : ""

f_stateFormText(int index, bool canTrack, bool canEvaluate, bool sourceReady) =>
    string state = f_lifecycleCompact(index, canTrack, canEvaluate, sourceReady)
    string icon = state == "RE-ENTERED" ? "↺" : state == "BEYOND" ? "◆" : state == "CONTACTED" ? "●" : state == "UNTESTED" ? "○" : state == "PARTIAL" ? "◐" : state == "WARM-UP" ? "…" : "!"
    string form = f_contactFormCompact(index)
    bool appendForm = canEvaluate and sourceReady and touchToleranceReady and canTrack and array.get(levelContacted, index) and form != ""
    appendForm ? icon + " " + state + " · " + form : icon + " " + state

f_outsideRecrossText(int index) =>
    int observations = array.get(levelResponseBars, index)
    observations > 0 ? f_percent(f_outsideShare(index)) + " / " + str.tostring(array.get(levelCloseRecrosses, index)) : "— / —"

f_excursionPairText(int index) =>
    int observations = array.get(levelResponseBars, index)
    observations > 0 ? f_atrMetric(f_responseAtr(index, true)) + " / " + f_atrMetric(f_responseAtr(index, false)) : "— / —"

f_responseCellColor(color baseColor, float outsideShare) =>
    na(outsideShare) ? color.new(baseColor, 93) : color.new(baseColor, int(math.round(math.max(66.0, 92.0 - outsideShare * 0.22))))

f_responseTooltip(string code, int index) =>
    int observations = array.get(levelResponseBars, index)
    int outsideCloses = array.get(levelOutsideCloses, index)
    int recrosses = array.get(levelCloseRecrosses, index)
    float maxOutsideAtr = f_responseAtr(index, true)
    float maxInsideAtr = f_responseAtr(index, false)
    int firstBar = array.get(levelFirstContactBar, index)
    int heldBar = array.get(levelHeldBar, index)
    int returnBar = array.get(levelReturnBar, index)
    string tooltip = code + " post-contact response"
    tooltip += "\nFirst-contact form: " + (array.get(levelFirstContactForm, index) == "" ? "None" : array.get(levelFirstContactForm, index))
    tooltip += "\nConfirmed observations: " + str.tostring(observations)
    tooltip += "\nOutside closes: " + str.tostring(outsideCloses) + " (" + f_percent(f_outsideShare(index)) + ")"
    tooltip += "\nClose-side recrosses: " + str.tostring(recrosses)
    tooltip += "\nMaximum outside excursion: " + f_atrMetric(maxOutsideAtr) + " frozen ATR"
    tooltip += "\nMaximum return inside: " + f_atrMetric(maxInsideAtr) + " frozen ATR"
    if not na(firstBar) and not na(heldBar)
        tooltip += "\nContact to sustained beyond: " + str.tostring(heldBar - firstBar) + " chart bars"
    if not na(heldBar) and not na(returnBar)
        tooltip += "\nSustained beyond to first re-entry: " + str.tostring(returnBar - heldBar) + " chart bars"
    tooltip += "\nATR is frozen at the relevant daily/weekly reset. Measurements are descriptive, not predictive."
    tooltip

f_responseThresholdEvents(int index) =>
    bool residencyEvent = false
    bool excursionEvent = false
    int observations = array.get(levelResponseBars, index)
    float outsideShare = f_outsideShare(index)
    float outsideExcursionAtr = f_responseAtr(index, true)
    if trackResponseRegister and barstate.isconfirmed
        if observations >= responseAlertMinimumBars and not na(outsideShare) and outsideShare >= responseOutsideShareThreshold and not array.get(levelResidencyAlerted, index)
            array.set(levelResidencyAlerted, index, true)
            residencyEvent := true
        if observations > 0 and not na(outsideExcursionAtr) and outsideExcursionAtr >= responseExcursionThresholdAtr and not array.get(levelExcursionAlerted, index)
            array.set(levelExcursionAlerted, index, true)
            excursionEvent := true
    [residencyEvent, excursionEvent]

f_contactSpanText(int upperIndex, int lowerIndex, string upperCode, string lowerCode) =>
    int upperBar = array.get(levelFirstContactBar, upperIndex)
    int lowerBar = array.get(levelFirstContactBar, lowerIndex)
    string result = "0/2"
    if not na(upperBar) and na(lowerBar)
        result := "1/2 · " + upperCode
    else if na(upperBar) and not na(lowerBar)
        result := "1/2 · " + lowerCode
    else if not na(upperBar) and not na(lowerBar)
        int separation = math.abs(upperBar - lowerBar)
        result := separation == 0 ? "2/2 · SAME BAR" : "2/2 · " + str.tostring(separation) + " BARS APART"
    result

f_stateBreadthText(bool includeDaily, bool includeWeekly) =>
    int enabledCount = (includeDaily ? 2 : 0) + (includeWeekly ? 2 : 0)
    int contactedCount = (includeDaily and array.get(levelContacted, 0) ? 1 : 0) + (includeDaily and array.get(levelContacted, 1) ? 1 : 0) + (includeWeekly and array.get(levelContacted, 2) ? 1 : 0) + (includeWeekly and array.get(levelContacted, 3) ? 1 : 0)
    int sustainedCount = (includeDaily and array.get(levelHeldOutside, 0) ? 1 : 0) + (includeDaily and array.get(levelHeldOutside, 1) ? 1 : 0) + (includeWeekly and array.get(levelHeldOutside, 2) ? 1 : 0) + (includeWeekly and array.get(levelHeldOutside, 3) ? 1 : 0)
    int reenteredCount = (includeDaily and array.get(levelReturned, 0) ? 1 : 0) + (includeDaily and array.get(levelReturned, 1) ? 1 : 0) + (includeWeekly and array.get(levelReturned, 2) ? 1 : 0) + (includeWeekly and array.get(levelReturned, 3) ? 1 : 0)
    enabledCount > 0 ? "C " + str.tostring(contactedCount) + "/" + str.tostring(enabledCount) + " · S " + str.tostring(sustainedCount) + "/" + str.tostring(enabledCount) + " · R " + str.tostring(reenteredCount) + "/" + str.tostring(enabledCount) : "OFF"


f_contactSpanCompact(int upperIndex, int lowerIndex, string upperCode, string lowerCode) =>
    int upperBar = array.get(levelFirstContactBar, upperIndex)
    int lowerBar = array.get(levelFirstContactBar, lowerIndex)
    string result = "0/2"
    if not na(upperBar) and na(lowerBar)
        result := "1/2 " + upperCode
    else if na(upperBar) and not na(lowerBar)
        result := "1/2 " + lowerCode
    else if not na(upperBar) and not na(lowerBar)
        int separation = math.abs(upperBar - lowerBar)
        result := separation == 0 ? "2/2 SAME" : "2/2 " + str.tostring(separation) + "B"
    result

f_stateBreadthCompact(bool includeDaily, bool includeWeekly) =>
    int enabledCount = (includeDaily ? 2 : 0) + (includeWeekly ? 2 : 0)
    int contactedCount = (includeDaily and array.get(levelContacted, 0) ? 1 : 0) + (includeDaily and array.get(levelContacted, 1) ? 1 : 0) + (includeWeekly and array.get(levelContacted, 2) ? 1 : 0) + (includeWeekly and array.get(levelContacted, 3) ? 1 : 0)
    int sustainedCount = (includeDaily and array.get(levelHeldOutside, 0) ? 1 : 0) + (includeDaily and array.get(levelHeldOutside, 1) ? 1 : 0) + (includeWeekly and array.get(levelHeldOutside, 2) ? 1 : 0) + (includeWeekly and array.get(levelHeldOutside, 3) ? 1 : 0)
    int reenteredCount = (includeDaily and array.get(levelReturned, 0) ? 1 : 0) + (includeDaily and array.get(levelReturned, 1) ? 1 : 0) + (includeWeekly and array.get(levelReturned, 2) ? 1 : 0) + (includeWeekly and array.get(levelReturned, 3) ? 1 : 0)
    enabledCount > 0 ? "●C" + str.tostring(contactedCount) + "/" + str.tostring(enabledCount) + " ◆S" + str.tostring(sustainedCount) + "/" + str.tostring(enabledCount) + " ↺R" + str.tostring(reenteredCount) + "/" + str.tostring(enabledCount) : "OFF"

f_pairGapCompact(float firstLevel, float secondLevel, float normalizerAtr) =>
    if na(firstLevel) or na(secondLevel)
        "n/a"
    else
        float gap = math.abs(firstLevel - secondLevel)
        string atrPart = not na(normalizerAtr) and normalizerAtr > 0.0 ? str.tostring(gap / normalizerAtr, "#.##") + "A" : "A n/a"
        string tickPart = syminfo.mintick > 0.0 ? str.tostring(math.round(gap / syminfo.mintick)) + "T" : "T n/a"
        atrPart + " | " + tickPart

f_relationCompact(string relation) =>
    relation == "Day inside week" ? "D INSIDE W" : relation == "Day envelops week" ? "D ENVELOPS W" : relation == "Upper overlap" ? "UPPER OVERLAP" : relation == "Lower overlap" ? "LOWER OVERLAP" : relation == "Day entirely above week" ? "D ABOVE W" : relation == "Day entirely below week" ? "D BELOW W" : relation == "Overlapping" ? "OVERLAP" : str.upper(relation)

f_levelTooltip(string code, string description, float level, int index, bool canTrack, bool canEvaluate, bool sourceReady) =>
    string lifecycle = f_lifecycle(index, canTrack, canEvaluate, sourceReady)
    string tooltip = code + " — " + description + "\nPrice: " + f_price(level) + "\nLifecycle: " + lifecycle
    int firstTime = array.get(levelFirstContactTime, index)
    int sustainedTime = array.get(levelHeldTime, index)
    int reentryTime = array.get(levelReturnTime, index)
    if not na(firstTime)
        tooltip += "\nFirst contact: " + str.format_time(firstTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
    if not na(sustainedTime)
        tooltip += "\nSustained beyond: " + str.format_time(sustainedTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
    if not na(reentryTime)
        tooltip += "\nRe-entered: " + str.format_time(reentryTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
    tooltip += "\nContact episodes: " + str.tostring(array.get(levelContactEpisodes, index))
    if trackResponseRegister
        tooltip += "\n\n" + f_responseTooltip(code, index)
    tooltip

f_stateColor(color baseColor, int index, bool canTrack, bool canEvaluate) =>
    color result = baseColor
    if canEvaluate and (not touchToleranceReady or not canTrack)
        result := color.new(baseColor, 62)
    else if canEvaluate and lifecycleLineStyling
        if array.get(levelReturned, index)
            result := color.new(baseColor, 12)
        else if array.get(levelHeldOutside, index)
            result := color.new(baseColor, 0)
        else if array.get(levelContacted, index)
            result := color.new(baseColor, 35)
    result

f_stateStyle(string baseStyle, int index, bool canTrack, bool canEvaluate) =>
    string result = f_lineStyle(baseStyle)
    if canEvaluate and (not touchToleranceReady or not canTrack)
        result := line.style_dotted
    else if canEvaluate and lifecycleLineStyling
        if array.get(levelReturned, index)
            result := line.style_dotted
        else if array.get(levelHeldOutside, index)
            result := line.style_solid
        else if array.get(levelContacted, index)
            result := line.style_dashed
    result

f_stateWidth(int baseWidth, int index, bool canTrack, bool canEvaluate) =>
    int result = baseWidth
    if canEvaluate and touchToleranceReady and canTrack and lifecycleLineStyling and array.get(levelHeldOutside, index) and not array.get(levelReturned, index)
        result := math.min(baseWidth + 1, 5)
    result

f_applyLineState(line lineId, color baseColor, string baseStyle, int baseWidth, int index, bool canTrack, bool canEvaluate) =>
    if not na(lineId)
        line.set_color(lineId, f_stateColor(baseColor, index, canTrack, canEvaluate))
        line.set_style(lineId, f_stateStyle(baseStyle, index, canTrack, canEvaluate))
        line.set_width(lineId, f_stateWidth(baseWidth, index, canTrack, canEvaluate))

f_applyHaloState(line lineId, string baseStyle, int baseWidth, int index, bool canTrack, bool canEvaluate) =>
    if not na(lineId)
        int visibleWidth = f_stateWidth(baseWidth, index, canTrack, canEvaluate)
        line.set_color(lineId, color.new(chart.bg_color, activeHaloTransparency))
        line.set_style(lineId, f_stateStyle(baseStyle, index, canTrack, canEvaluate))
        line.set_width(lineId, math.min(visibleWidth + activeHaloExtraWidth, 5))

f_finalizePeriodLine(line lineId, int endTime, color baseColor, int baseWidth) =>
    if not na(lineId)
        line.set_extend(lineId, extend.none)
        line.set_x2(lineId, endTime)
        if dimHistoricalSegments
            line.set_color(lineId, color.new(baseColor, historicalLineTransparency))
            line.set_width(lineId, math.max(1, baseWidth - historicalWidthReduction))

//------------------------------------------------------------------------------
// Track whether the first loaded day/week is complete enough for first-contact use
//------------------------------------------------------------------------------
var bool dayTrackable = false
var bool weekTrackable = false

if newDay
    dayTrackable := not barstate.isfirst or time <= dayStart

if newWeek
    weekTrackable := not barstate.isfirst or time <= weekStart

//------------------------------------------------------------------------------
// Persistent period drawings
//------------------------------------------------------------------------------
var array<line> dailyLines = array.new<line>()
var array<line> weeklyLines = array.new<line>()
var array<box> dailyBoxes = array.new<box>()
var array<box> weeklyBoxes = array.new<box>()
var array<label> eventLabels = array.new<label>()

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var line pdhHaloLine = na
var line pdlHaloLine = na
var line pwhHaloLine = na
var line pwlHaloLine = na
var box dailyRangeBox = na
var box weeklyRangeBox = na

int dailyKeepCount = keepHistory ? dailyPeriodsKept : 1
int weeklyKeepCount = keepHistory ? weeklyPeriodsKept : 1

if newDay
    f_finalizePeriodLine(pdhLine, dayStart, pdhColor, dailyLineWidth)
    f_finalizePeriodLine(pdlLine, dayStart, pdlColor, dailyLineWidth)
    if not na(pdhHaloLine)
        line.delete(pdhHaloLine)
    if not na(pdlHaloLine)
        line.delete(pdlHaloLine)
    if not na(dailyRangeBox)
        box.set_right(dailyRangeBox, dayStart)

    pdhLine := na
    pdlLine := na
    pdhHaloLine := na
    pdlHaloLine := na
    dailyRangeBox := na

    if showDaily and not na(pdh) and not na(pdl)
        if showActiveLineHalo
            pdhHaloLine := line.new(
                 x1 = dayStart,
                 y1 = pdh,
                 x2 = barRightTime,
                 y2 = pdh,
                 xloc = xloc.bar_time,
                 extend = extend.right,
                 color = color.new(chart.bg_color, activeHaloTransparency),
                 style = f_lineStyle(dailyLineStyleInput),
                 width = math.min(dailyLineWidth + activeHaloExtraWidth, 5))
            pdlHaloLine := line.new(
                 x1 = dayStart,
                 y1 = pdl,
                 x2 = barRightTime,
                 y2 = pdl,
                 xloc = xloc.bar_time,
                 extend = extend.right,
                 color = color.new(chart.bg_color, activeHaloTransparency),
                 style = f_lineStyle(dailyLineStyleInput),
                 width = math.min(dailyLineWidth + activeHaloExtraWidth, 5))

        pdhLine := line.new(
             x1 = dayStart,
             y1 = pdh,
             x2 = barRightTime,
             y2 = pdh,
             xloc = xloc.bar_time,
             extend = extend.right,
             color = pdhColor,
             style = f_lineStyle(dailyLineStyleInput),
             width = dailyLineWidth)
        pdlLine := line.new(
             x1 = dayStart,
             y1 = pdl,
             x2 = barRightTime,
             y2 = pdl,
             xloc = xloc.bar_time,
             extend = extend.right,
             color = pdlColor,
             style = f_lineStyle(dailyLineStyleInput),
             width = dailyLineWidth)
        array.push(dailyLines, pdhLine)
        array.push(dailyLines, pdlLine)
        f_trimLines(dailyLines, dailyKeepCount * 2)

        if showRangeRibbons
            dailyRangeBox := box.new(
                 left = dayStart,
                 top = pdh,
                 right = barRightTime,
                 bottom = pdl,
                 xloc = xloc.bar_time,
                 border_color = color.new(dailyRibbonColor, 100),
                 border_width = 1,
                 bgcolor = dailyRibbonColor)
            array.push(dailyBoxes, dailyRangeBox)
            f_trimBoxes(dailyBoxes, dailyKeepCount)

if newWeek
    f_finalizePeriodLine(pwhLine, weekStart, pwhColor, weeklyLineWidth)
    f_finalizePeriodLine(pwlLine, weekStart, pwlColor, weeklyLineWidth)
    if not na(pwhHaloLine)
        line.delete(pwhHaloLine)
    if not na(pwlHaloLine)
        line.delete(pwlHaloLine)
    if not na(weeklyRangeBox)
        box.set_right(weeklyRangeBox, weekStart)

    pwhLine := na
    pwlLine := na
    pwhHaloLine := na
    pwlHaloLine := na
    weeklyRangeBox := na

    if showWeekly and not na(pwh) and not na(pwl)
        if showActiveLineHalo
            pwhHaloLine := line.new(
                 x1 = weekStart,
                 y1 = pwh,
                 x2 = barRightTime,
                 y2 = pwh,
                 xloc = xloc.bar_time,
                 extend = extend.right,
                 color = color.new(chart.bg_color, activeHaloTransparency),
                 style = f_lineStyle(weeklyLineStyleInput),
                 width = math.min(weeklyLineWidth + activeHaloExtraWidth, 5))
            pwlHaloLine := line.new(
                 x1 = weekStart,
                 y1 = pwl,
                 x2 = barRightTime,
                 y2 = pwl,
                 xloc = xloc.bar_time,
                 extend = extend.right,
                 color = color.new(chart.bg_color, activeHaloTransparency),
                 style = f_lineStyle(weeklyLineStyleInput),
                 width = math.min(weeklyLineWidth + activeHaloExtraWidth, 5))

        pwhLine := line.new(
             x1 = weekStart,
             y1 = pwh,
             x2 = barRightTime,
             y2 = pwh,
             xloc = xloc.bar_time,
             extend = extend.right,
             color = pwhColor,
             style = f_lineStyle(weeklyLineStyleInput),
             width = weeklyLineWidth)
        pwlLine := line.new(
             x1 = weekStart,
             y1 = pwl,
             x2 = barRightTime,
             y2 = pwl,
             xloc = xloc.bar_time,
             extend = extend.right,
             color = pwlColor,
             style = f_lineStyle(weeklyLineStyleInput),
             width = weeklyLineWidth)
        array.push(weeklyLines, pwhLine)
        array.push(weeklyLines, pwlLine)
        f_trimLines(weeklyLines, weeklyKeepCount * 2)

        if showRangeRibbons
            weeklyRangeBox := box.new(
                 left = weekStart,
                 top = pwh,
                 right = barRightTime,
                 bottom = pwl,
                 xloc = xloc.bar_time,
                 border_color = color.new(weeklyRibbonColor, 100),
                 border_width = 1,
                 bgcolor = weeklyRibbonColor)
            array.push(weeklyBoxes, weeklyRangeBox)
            f_trimBoxes(weeklyBoxes, weeklyKeepCount)

if not na(pdhLine)
    line.set_x2(pdhLine, barRightTime)
if not na(pdlLine)
    line.set_x2(pdlLine, barRightTime)
if not na(pwhLine)
    line.set_x2(pwhLine, barRightTime)
if not na(pwlLine)
    line.set_x2(pwlLine, barRightTime)
if not na(pdhHaloLine)
    line.set_x2(pdhHaloLine, barRightTime)
if not na(pdlHaloLine)
    line.set_x2(pdlHaloLine, barRightTime)
if not na(pwhHaloLine)
    line.set_x2(pwhHaloLine, barRightTime)
if not na(pwlHaloLine)
    line.set_x2(pwlHaloLine, barRightTime)
if not na(dailyRangeBox)
    box.set_right(dailyRangeBox, barRightTime)
if not na(weeklyRangeBox)
    box.set_right(weeklyRangeBox, barRightTime)

//------------------------------------------------------------------------------
// Current day/week range progress
//------------------------------------------------------------------------------
var float currentDayHigh = na
var float currentDayLow = na
var float currentWeekHigh = na
var float currentWeekLow = na

if newDay
    currentDayHigh := eventHigh
    currentDayLow := eventLow
else if not na(eventHigh) and not na(eventLow)
    currentDayHigh := na(currentDayHigh) ? eventHigh : math.max(currentDayHigh, eventHigh)
    currentDayLow := na(currentDayLow) ? eventLow : math.min(currentDayLow, eventLow)

if newWeek
    currentWeekHigh := eventHigh
    currentWeekLow := eventLow
else if not na(eventHigh) and not na(eventLow)
    currentWeekHigh := na(currentWeekHigh) ? eventHigh : math.max(currentWeekHigh, eventHigh)
    currentWeekLow := na(currentWeekLow) ? eventLow : math.min(currentWeekLow, eventLow)

float priorDayRange = not na(pdh) and not na(pdl) ? pdh - pdl : na
float priorWeekRange = not na(pwh) and not na(pwl) ? pwh - pwl : na
float currentDayRange = not na(currentDayHigh) and not na(currentDayLow) ? currentDayHigh - currentDayLow : na
float currentWeekRange = not na(currentWeekHigh) and not na(currentWeekLow) ? currentWeekHigh - currentWeekLow : na
float dayRangeUse = not na(priorDayRange) and priorDayRange > 0.0 ? currentDayRange / priorDayRange * 100.0 : na
float weekRangeUse = not na(priorWeekRange) and priorWeekRange > 0.0 ? currentWeekRange / priorWeekRange * 100.0 : na

//------------------------------------------------------------------------------
// Update lifecycle states
//------------------------------------------------------------------------------
var float lastConfirmedSourceClose = na
float previousSourceClose = lastConfirmedSourceClose

[pdhContactEvent, pdhHeldEvent, pdhReturnEvent] = f_updateLevel(
     0, pdh, 1, newDay, dayTrackable, lifecycleEvaluationAllowed and showDaily,
     eventOpen, eventHigh, eventLow, eventClose, previousSourceClose, eventTime, touchTolerance, contactBasis, holdCloseCount,
     completedDailyAtr, trackResponseRegister, responseExcursionSource)

[pdlContactEvent, pdlHeldEvent, pdlReturnEvent] = f_updateLevel(
     1, pdl, -1, newDay, dayTrackable, lifecycleEvaluationAllowed and showDaily,
     eventOpen, eventHigh, eventLow, eventClose, previousSourceClose, eventTime, touchTolerance, contactBasis, holdCloseCount,
     completedDailyAtr, trackResponseRegister, responseExcursionSource)

[pwhContactEvent, pwhHeldEvent, pwhReturnEvent] = f_updateLevel(
     2, pwh, 1, newWeek, weekTrackable, lifecycleEvaluationAllowed and showWeekly,
     eventOpen, eventHigh, eventLow, eventClose, previousSourceClose, eventTime, touchTolerance, contactBasis, holdCloseCount,
     completedDailyAtr, trackResponseRegister, responseExcursionSource)

[pwlContactEvent, pwlHeldEvent, pwlReturnEvent] = f_updateLevel(
     3, pwl, -1, newWeek, weekTrackable, lifecycleEvaluationAllowed and showWeekly,
     eventOpen, eventHigh, eventLow, eventClose, previousSourceClose, eventTime, touchTolerance, contactBasis, holdCloseCount,
     completedDailyAtr, trackResponseRegister, responseExcursionSource)

if barstate.isconfirmed and eventSourceReady
    lastConfirmedSourceClose := eventClose

[pdhResidencyThresholdEvent, pdhExcursionThresholdEvent] = f_responseThresholdEvents(0)
[pdlResidencyThresholdEvent, pdlExcursionThresholdEvent] = f_responseThresholdEvents(1)
[pwhResidencyThresholdEvent, pwhExcursionThresholdEvent] = f_responseThresholdEvents(2)
[pwlResidencyThresholdEvent, pwlExcursionThresholdEvent] = f_responseThresholdEvents(3)

bool dailyContactPairCompletedNow = (pdhContactEvent and not na(array.get(levelFirstContactBar, 1))) or (pdlContactEvent and not na(array.get(levelFirstContactBar, 0)))
bool weeklyContactPairCompletedNow = (pwhContactEvent and not na(array.get(levelFirstContactBar, 3))) or (pwlContactEvent and not na(array.get(levelFirstContactBar, 2)))

f_applyHaloState(pdhHaloLine, dailyLineStyleInput, dailyLineWidth, 0, dayTrackable, lifecycleEvaluationAllowed)
f_applyHaloState(pdlHaloLine, dailyLineStyleInput, dailyLineWidth, 1, dayTrackable, lifecycleEvaluationAllowed)
f_applyHaloState(pwhHaloLine, weeklyLineStyleInput, weeklyLineWidth, 2, weekTrackable, lifecycleEvaluationAllowed)
f_applyHaloState(pwlHaloLine, weeklyLineStyleInput, weeklyLineWidth, 3, weekTrackable, lifecycleEvaluationAllowed)

f_applyLineState(pdhLine, pdhColor, dailyLineStyleInput, dailyLineWidth, 0, dayTrackable, lifecycleEvaluationAllowed)
f_applyLineState(pdlLine, pdlColor, dailyLineStyleInput, dailyLineWidth, 1, dayTrackable, lifecycleEvaluationAllowed)
f_applyLineState(pwhLine, pwhColor, weeklyLineStyleInput, weeklyLineWidth, 2, weekTrackable, lifecycleEvaluationAllowed)
f_applyLineState(pwlLine, pwlColor, weeklyLineStyleInput, weeklyLineWidth, 3, weekTrackable, lifecycleEvaluationAllowed)

//------------------------------------------------------------------------------
// Event marks
//------------------------------------------------------------------------------
f_addEventMark(bool eventCondition, float level, string textValue, string tooltipValue, color markColor) =>
    if eventCondition and eventMarkMode != "Off" and not na(level) and not na(eventTime)
        label eventLabel = label.new(
             x = eventTime,
             y = level,
             text = textValue,
             xloc = xloc.bar_time,
             yloc = yloc.price,
             color = chart.bg_color,
             style = label.style_text_outline,
             textcolor = markColor,
             size = f_size(eventMarkSizeInput),
             text_font_family = font.family_default,
             text_formatting = text.format_bold,
             tooltip = tooltipValue)
        array.push(eventLabels, eventLabel)
        f_trimLabels(eventLabels, eventMarksKept)

bool showContactMarks = eventMarkMode == "First contact" or eventMarkMode == "Full lifecycle"
bool showLifecycleMarks = eventMarkMode == "Full lifecycle"

f_addEventMark(showContactMarks and pdhContactEvent, pdh, f_eventMarkText("●", "PDH"), "PDH first confirmed contact", pdhColor)
f_addEventMark(showContactMarks and pdlContactEvent, pdl, f_eventMarkText("●", "PDL"), "PDL first confirmed contact", pdlColor)
f_addEventMark(showContactMarks and pwhContactEvent, pwh, f_eventMarkText("●", "PWH"), "PWH first confirmed contact", pwhColor)
f_addEventMark(showContactMarks and pwlContactEvent, pwl, f_eventMarkText("●", "PWL"), "PWL first confirmed contact", pwlColor)

f_addEventMark(showLifecycleMarks and pdhHeldEvent, pdh, f_eventMarkText("◆", "PDH"), "PDH reached Sustained beyond", pdhColor)
f_addEventMark(showLifecycleMarks and pdlHeldEvent, pdl, f_eventMarkText("◆", "PDL"), "PDL reached Sustained beyond", pdlColor)
f_addEventMark(showLifecycleMarks and pwhHeldEvent, pwh, f_eventMarkText("◆", "PWH"), "PWH reached Sustained beyond", pwhColor)
f_addEventMark(showLifecycleMarks and pwlHeldEvent, pwl, f_eventMarkText("◆", "PWL"), "PWL reached Sustained beyond", pwlColor)

f_addEventMark(showLifecycleMarks and pdhReturnEvent, pdh, f_eventMarkText("↺", "PDH"), "Price closed back through PDH into the prior-day range after Sustained beyond", pdhColor)
f_addEventMark(showLifecycleMarks and pdlReturnEvent, pdl, f_eventMarkText("↺", "PDL"), "Price closed back through PDL into the prior-day range after Sustained beyond", pdlColor)
f_addEventMark(showLifecycleMarks and pwhReturnEvent, pwh, f_eventMarkText("↺", "PWH"), "Price closed back through PWH into the prior-week range after Sustained beyond", pwhColor)
f_addEventMark(showLifecycleMarks and pwlReturnEvent, pwl, f_eventMarkText("↺", "PWL"), "Price closed back through PWL into the prior-week range after Sustained beyond", pwlColor)

//------------------------------------------------------------------------------
// Shared prior-range corridor
//------------------------------------------------------------------------------
float sharedRangeTop = showDaily and showWeekly and not na(pdh) and not na(pdl) and not na(pwh) and not na(pwl) ? math.min(pdh, pwh) : na
float sharedRangeBottom = showDaily and showWeekly and not na(pdh) and not na(pdl) and not na(pwh) and not na(pwl) ? math.max(pdl, pwl) : na
bool sharedRangeExists = supportedTimeframe and not na(sharedRangeTop) and not na(sharedRangeBottom) and sharedRangeTop > sharedRangeBottom
float sharedRangeWidth = sharedRangeExists ? sharedRangeTop - sharedRangeBottom : na
float sharedOfDay = sharedRangeExists and not na(priorDayRange) and priorDayRange > 0.0 ? sharedRangeWidth / priorDayRange * 100.0 : na
float sharedOfWeek = sharedRangeExists and not na(priorWeekRange) and priorWeekRange > 0.0 ? sharedRangeWidth / priorWeekRange * 100.0 : na

var box sharedRangeBox = na

if showSharedCorridor and sharedRangeExists and not na(dayStart) and not na(weekStart)
    if na(sharedRangeBox) or newDay or newWeek
        if not na(sharedRangeBox)
            box.delete(sharedRangeBox)
        sharedRangeBox := box.new(
             left = math.max(dayStart, weekStart),
             top = sharedRangeTop,
             right = barRightTime,
             bottom = sharedRangeBottom,
             xloc = xloc.bar_time,
             border_color = color.new(sharedCorridorColor, 42),
             border_width = 1,
             bgcolor = color.new(sharedCorridorColor, sharedCorridorTransparency))
    else
        box.set_right(sharedRangeBox, barRightTime)
        box.set_top(sharedRangeBox, sharedRangeTop)
        box.set_bottom(sharedRangeBox, sharedRangeBottom)
else if not na(sharedRangeBox)
    box.delete(sharedRangeBox)
    sharedRangeBox := na

//------------------------------------------------------------------------------
// Day-week level clusters
//------------------------------------------------------------------------------
bool highCluster = supportedTimeframe and showDaily and showWeekly and showClusters and not na(highClusterThreshold) and highClusterThreshold >= 0.0 and not na(pdh) and not na(pwh) and math.abs(pdh - pwh) <= highClusterThreshold
bool lowCluster = supportedTimeframe and showDaily and showWeekly and showClusters and not na(lowClusterThreshold) and lowClusterThreshold >= 0.0 and not na(pdl) and not na(pwl) and math.abs(pdl - pwl) <= lowClusterThreshold
bool clusterContextChanged = newDay or newWeek

var box highClusterBox = na
var box lowClusterBox = na

if highCluster and not na(dayStart) and not na(weekStart)
    float highPadding = math.max(syminfo.mintick, highClusterThreshold * 0.08)
    if na(highClusterBox) or clusterContextChanged
        if not na(highClusterBox)
            box.delete(highClusterBox)
        highClusterBox := box.new(
             left = math.max(dayStart, weekStart),
             top = math.max(pdh, pwh) + highPadding,
             right = barRightTime,
             bottom = math.min(pdh, pwh) - highPadding,
             xloc = xloc.bar_time,
             border_color = color.new(highClusterColor, 35),
             border_width = 1,
             bgcolor = color.new(highClusterColor, clusterTransparency))
    else
        box.set_right(highClusterBox, barRightTime)
        box.set_top(highClusterBox, math.max(pdh, pwh) + highPadding)
        box.set_bottom(highClusterBox, math.min(pdh, pwh) - highPadding)
else if not na(highClusterBox)
    box.delete(highClusterBox)
    highClusterBox := na

if lowCluster and not na(dayStart) and not na(weekStart)
    float lowPadding = math.max(syminfo.mintick, lowClusterThreshold * 0.08)
    if na(lowClusterBox) or clusterContextChanged
        if not na(lowClusterBox)
            box.delete(lowClusterBox)
        lowClusterBox := box.new(
             left = math.max(dayStart, weekStart),
             top = math.max(pdl, pwl) + lowPadding,
             right = barRightTime,
             bottom = math.min(pdl, pwl) - lowPadding,
             xloc = xloc.bar_time,
             border_color = color.new(lowClusterColor, 35),
             border_width = 1,
             bgcolor = color.new(lowClusterColor, clusterTransparency))
    else
        box.set_right(lowClusterBox, barRightTime)
        box.set_top(lowClusterBox, math.max(pdl, pwl) + lowPadding)
        box.set_bottom(lowClusterBox, math.min(pdl, pwl) - lowPadding)
else if not na(lowClusterBox)
    box.delete(lowClusterBox)
    lowClusterBox := na

bool highClusterFormed = highCluster and (clusterContextChanged or not highCluster[1])
bool lowClusterFormed = lowCluster and (clusterContextChanged or not lowCluster[1])

//------------------------------------------------------------------------------
// Visible-window range for scale-aware right-edge label spacing
//------------------------------------------------------------------------------
var float visibleChartHigh = na
var float visibleChartLow = na
var int visibleChartBarCount = 0
bool visibleWindowReady = not na(chart.left_visible_bar_time) and not na(chart.right_visible_bar_time)
bool insideVisibleChartWindow = visibleWindowReady and time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
bool enteringVisibleChartWindow = insideVisibleChartWindow and (barstate.isfirst or not insideVisibleChartWindow[1] or time == chart.left_visible_bar_time)

if enteringVisibleChartWindow
    visibleChartHigh := high
    visibleChartLow := low
    visibleChartBarCount := 1
else if insideVisibleChartWindow
    visibleChartHigh := na(visibleChartHigh) ? high : math.max(visibleChartHigh, high)
    visibleChartLow := na(visibleChartLow) ? low : math.min(visibleChartLow, low)
    visibleChartBarCount += 1

//------------------------------------------------------------------------------
// Right-edge labels
//------------------------------------------------------------------------------
var label pdhRightLabel = na
var label pdlRightLabel = na
var label pwhRightLabel = na
var label pwlRightLabel = na
var label highPairRightLabel = na
var label lowPairRightLabel = na
var line pdhRightLeader = na
var line pdlRightLeader = na
var line pwhRightLeader = na
var line pwlRightLeader = na
var label timeframeNotice = na

if barstate.islast
    int maximumFutureRail = 480
    int maximumPrimaryOffset = 440
    int responsiveOffset = int(math.round(visibleChartBarCount * rightLabelViewportPercent / 100.0))
    int requestedRightLabelOffset = rightLabelPlacementMode == "Responsive" ? math.max(rightLabelOffset, responsiveOffset) : rightLabelOffset
    int resolvedRightLabelOffset = math.min(maximumPrimaryOffset, requestedRightLabelOffset)
    int responsiveLaneGutter = int(math.round(visibleChartBarCount * 0.018))
    int requestedLaneGutter = splitRightLabelLanes ? (rightLabelPlacementMode == "Responsive" ? math.max(rightLabelLaneGutter, responsiveLaneGutter) : rightLabelLaneGutter) : 0
    int resolvedLaneGutter = math.min(requestedLaneGutter, math.max(0, maximumFutureRail - resolvedRightLabelOffset))
    int labelRailX = bar_index + resolvedRightLabelOffset
    int dailyLabelX = labelRailX
    int weeklyLabelX = labelRailX + resolvedLaneGutter
    int pairLabelX = labelRailX
    string highLabelStyle = label.style_label_down
    string lowLabelStyle = label.style_label_up

    string pdhLifecycle = f_lifecycle(0, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string pdlLifecycle = f_lifecycle(1, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string pwhLifecycle = f_lifecycle(2, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string pwlLifecycle = f_lifecycle(3, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady)

    bool basePdhRight = supportedTimeframe and showRightLabels and showDaily
    bool basePdlRight = supportedTimeframe and showRightLabels and showDaily
    bool basePwhRight = supportedTimeframe and showRightLabels and showWeekly
    bool basePwlRight = supportedTimeframe and showRightLabels and showWeekly
    bool mergeHighPair = basePdhRight and basePwhRight and mergeNearbyRightLabels and highCluster
    bool mergeLowPair = basePdlRight and basePwlRight and mergeNearbyRightLabels and lowCluster

    bool showPdhRight = basePdhRight and not mergeHighPair
    bool showPdlRight = basePdlRight and not mergeLowPair
    bool showPwhRight = basePwhRight and not mergeHighPair
    bool showPwlRight = basePwlRight and not mergeLowPair
    bool showHighPairRight = mergeHighPair
    bool showLowPairRight = mergeLowPair

    float pdhLabelY = pdh
    float pdlLabelY = pdl
    float pwhLabelY = pwh
    float pwlLabelY = pwl
    float highPairLabelY = mergeHighPair and not na(pdh) and not na(pwh) ? (pdh + pwh) * 0.5 : na
    float lowPairLabelY = mergeLowPair and not na(pdl) and not na(pwl) ? (pdl + pwl) * 0.5 : na

    float railVisibleHigh = visibleChartHigh
    float railVisibleLow = visibleChartLow
    if basePdhRight and not na(pdh)
        railVisibleHigh := na(railVisibleHigh) ? pdh : math.max(railVisibleHigh, pdh)
        railVisibleLow := na(railVisibleLow) ? pdh : math.min(railVisibleLow, pdh)
    if basePdlRight and not na(pdl)
        railVisibleHigh := na(railVisibleHigh) ? pdl : math.max(railVisibleHigh, pdl)
        railVisibleLow := na(railVisibleLow) ? pdl : math.min(railVisibleLow, pdl)
    if basePwhRight and not na(pwh)
        railVisibleHigh := na(railVisibleHigh) ? pwh : math.max(railVisibleHigh, pwh)
        railVisibleLow := na(railVisibleLow) ? pwh : math.min(railVisibleLow, pwh)
    if basePwlRight and not na(pwl)
        railVisibleHigh := na(railVisibleHigh) ? pwl : math.max(railVisibleHigh, pwl)
        railVisibleLow := na(railVisibleLow) ? pwl : math.min(railVisibleLow, pwl)

    float railVisibleRange = not na(railVisibleHigh) and not na(railVisibleLow) and railVisibleHigh > railVisibleLow ? railVisibleHigh - railVisibleLow : na
    float atrBasedLabelGap = not na(completedDailyAtr) and completedDailyAtr > 0.0 ? completedDailyAtr * rightLabelMinimumGapAtr : 0.0
    float tickBasedLabelGap = syminfo.mintick > 0.0 ? syminfo.mintick * rightLabelMinimumGapTicks : 0.0
    float visibleBasedLabelGap = useVisibleRangeLabelGap and not na(railVisibleRange) ? railVisibleRange * rightLabelMinimumGapVisiblePercent / 100.0 : 0.0
    float minimumRailGap = autoSeparateSameLaneLabels ? math.max(math.max(atrBasedLabelGap, tickBasedLabelGap), visibleBasedLabelGap) : 0.0

    // IDs: 0 PDH, 1 PDL, 2 PWH, 3 PWL, 4 merged high pair, 5 merged low pair.
    array<float> railDesiredY = array.new_float()
    array<int> railIds = array.new_int()

    if showPdhRight and not na(pdhLabelY)
        array.push(railDesiredY, pdhLabelY)
        array.push(railIds, 0)
    if showPdlRight and not na(pdlLabelY)
        array.push(railDesiredY, pdlLabelY)
        array.push(railIds, 1)
    if showPwhRight and not na(pwhLabelY)
        array.push(railDesiredY, pwhLabelY)
        array.push(railIds, 2)
    if showPwlRight and not na(pwlLabelY)
        array.push(railDesiredY, pwlLabelY)
        array.push(railIds, 3)
    if showHighPairRight and not na(highPairLabelY)
        array.push(railDesiredY, highPairLabelY)
        array.push(railIds, 4)
    if showLowPairRight and not na(lowPairLabelY)
        array.push(railDesiredY, lowPairLabelY)
        array.push(railIds, 5)

    int railCount = array.size(railDesiredY)
    if autoSeparateSameLaneLabels and minimumRailGap > 0.0 and railCount > 1
        array<int> sortedRailIndices = array.sort_indices(railDesiredY, order.descending)
        array<float> sortedRailY = array.new_float(railCount, na)

        for sortedPosition = 0 to railCount - 1
            int originalIndex = array.get(sortedRailIndices, sortedPosition)
            float desiredY = array.get(railDesiredY, originalIndex)
            float resolvedY = sortedPosition == 0 ? desiredY : math.min(desiredY, array.get(sortedRailY, sortedPosition - 1) - minimumRailGap)
            array.set(sortedRailY, sortedPosition, resolvedY)

        int topOriginalIndex = array.get(sortedRailIndices, 0)
        int bottomOriginalIndex = array.get(sortedRailIndices, railCount - 1)
        float originalCenter = (array.get(railDesiredY, topOriginalIndex) + array.get(railDesiredY, bottomOriginalIndex)) * 0.5
        float resolvedCenter = (array.get(sortedRailY, 0) + array.get(sortedRailY, railCount - 1)) * 0.5
        float centerShift = originalCenter - resolvedCenter

        float shiftedTop = array.get(sortedRailY, 0) + centerShift
        float shiftedBottom = array.get(sortedRailY, railCount - 1) + centerShift
        float edgeShift = 0.0
        if not na(railVisibleHigh) and shiftedTop > railVisibleHigh
            edgeShift := railVisibleHigh - shiftedTop
        if not na(railVisibleLow) and shiftedBottom + edgeShift < railVisibleLow
            edgeShift += railVisibleLow - (shiftedBottom + edgeShift)

        for sortedPosition = 0 to railCount - 1
            int originalIndex = array.get(sortedRailIndices, sortedPosition)
            int railId = array.get(railIds, originalIndex)
            float resolvedY = array.get(sortedRailY, sortedPosition) + centerShift + edgeShift
            switch railId
                0 => pdhLabelY := resolvedY
                1 => pdlLabelY := resolvedY
                2 => pwhLabelY := resolvedY
                3 => pwlLabelY := resolvedY
                4 => highPairLabelY := resolvedY
                5 => lowPairLabelY := resolvedY

    int pdhLeaderX = mergeHighPair ? pairLabelX : dailyLabelX
    int pwhLeaderX = mergeHighPair ? pairLabelX : weeklyLabelX
    int pdlLeaderX = mergeLowPair ? pairLabelX : dailyLabelX
    int pwlLeaderX = mergeLowPair ? pairLabelX : weeklyLabelX
    float pdhDisplayY = mergeHighPair ? highPairLabelY : pdhLabelY
    float pwhDisplayY = mergeHighPair ? highPairLabelY : pwhLabelY
    float pdlDisplayY = mergeLowPair ? lowPairLabelY : pdlLabelY
    float pwlDisplayY = mergeLowPair ? lowPairLabelY : pwlLabelY

    pdhRightLeader := f_updateRightLeader(
         pdhRightLeader,
         basePdhRight and showRightLabelLeaders,
         pdhLeaderX,
         pdh,
         pdhDisplayY,
         pdhColor)

    pdlRightLeader := f_updateRightLeader(
         pdlRightLeader,
         basePdlRight and showRightLabelLeaders,
         pdlLeaderX,
         pdl,
         pdlDisplayY,
         pdlColor)

    pwhRightLeader := f_updateRightLeader(
         pwhRightLeader,
         basePwhRight and showRightLabelLeaders,
         pwhLeaderX,
         pwh,
         pwhDisplayY,
         pwhColor)

    pwlRightLeader := f_updateRightLeader(
         pwlRightLeader,
         basePwlRight and showRightLabelLeaders,
         pwlLeaderX,
         pwl,
         pwlDisplayY,
         pwlColor)

    string pdhTooltip = f_levelTooltip("PDH", "Previous completed daily high", pdh, 0, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string pdlTooltip = f_levelTooltip("PDL", "Previous completed daily low", pdl, 1, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string pwhTooltip = f_levelTooltip("PWH", "Previous completed weekly high", pwh, 2, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string pwlTooltip = f_levelTooltip("PWL", "Previous completed weekly low", pwl, 3, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady)
    string highPairTooltip = "Nearby high-boundary pair\n\n" + pdhTooltip + "\n\n" + pwhTooltip
    string lowPairTooltip = "Nearby low-boundary pair\n\n" + pdlTooltip + "\n\n" + pwlTooltip

    pdhRightLabel := f_updateRightLabel(
         pdhRightLabel,
         showPdhRight,
         dailyLabelX,
         pdhLabelY,
         f_rightLabelText("PDH", pdh, pdhLifecycle),
         pdhTooltip,
         f_stateColor(pdhColor, 0, dayTrackable, lifecycleEvaluationAllowed),
         highLabelStyle)

    pdlRightLabel := f_updateRightLabel(
         pdlRightLabel,
         showPdlRight,
         dailyLabelX,
         pdlLabelY,
         f_rightLabelText("PDL", pdl, pdlLifecycle),
         pdlTooltip,
         f_stateColor(pdlColor, 1, dayTrackable, lifecycleEvaluationAllowed),
         lowLabelStyle)

    pwhRightLabel := f_updateRightLabel(
         pwhRightLabel,
         showPwhRight,
         weeklyLabelX,
         pwhLabelY,
         f_rightLabelText("PWH", pwh, pwhLifecycle),
         pwhTooltip,
         f_stateColor(pwhColor, 2, weekTrackable, lifecycleEvaluationAllowed),
         highLabelStyle)

    pwlRightLabel := f_updateRightLabel(
         pwlRightLabel,
         showPwlRight,
         weeklyLabelX,
         pwlLabelY,
         f_rightLabelText("PWL", pwl, pwlLifecycle),
         pwlTooltip,
         f_stateColor(pwlColor, 3, weekTrackable, lifecycleEvaluationAllowed),
         lowLabelStyle)

    highPairRightLabel := f_updateRightLabel(
         highPairRightLabel,
         showHighPairRight,
         pairLabelX,
         highPairLabelY,
         f_pairRightLabelText("PDH", pdh, pdhLifecycle, "PWH", pwh, pwhLifecycle),
         highPairTooltip,
         highClusterColor,
         highLabelStyle)

    lowPairRightLabel := f_updateRightLabel(
         lowPairRightLabel,
         showLowPairRight,
         pairLabelX,
         lowPairLabelY,
         f_pairRightLabelText("PDL", pdl, pdlLifecycle, "PWL", pwl, pwlLifecycle),
         lowPairTooltip,
         lowClusterColor,
         lowLabelStyle)

    if not supportedTimeframe
        if na(timeframeNotice)
            timeframeNotice := label.new(
                 x = bar_index,
                 y = close,
                 text = "Use a time-based intraday or 1D chart",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_down,
                 color = color.rgb(255, 82, 82),
                 textcolor = color.white,
                 size = 18,
                 text_font_family = font.family_default,
                 text_formatting = text.format_bold,
                 tooltip = "This indicator supports time-based intraday charts and the 1D chart. Tick charts and timeframes above 1D are excluded to avoid ambiguous lower-timeframe reconstruction.")
        else
            label.set_x(timeframeNotice, bar_index)
            label.set_y(timeframeNotice, close)
    else if not na(timeframeNotice)
        label.delete(timeframeNotice)
        timeframeNotice := na

//------------------------------------------------------------------------------
// Compact high-contrast boundary response register
//------------------------------------------------------------------------------
int panelBodyTextSize = panelSizePresetInput == "Compact" ? 12 : panelSizePresetInput == "Balanced" ? 14 : panelSizePresetInput == "Presentation" ? 18 : panelBodyTextSizeInput
int panelColumnTextSize = panelSizePresetInput == "Compact" ? 13 : panelSizePresetInput == "Balanced" ? 15 : panelSizePresetInput == "Presentation" ? 20 : panelColumnTextSizeInput
int panelTitleTextSize = panelSizePresetInput == "Compact" ? 15 : panelSizePresetInput == "Balanced" ? 18 : panelSizePresetInput == "Presentation" ? 24 : panelTitleTextSizeInput
int panelFrameWidth = panelSizePresetInput == "Compact" ? 3 : panelSizePresetInput == "Balanced" ? 4 : 5
int panelBorderWidth = panelSizePresetInput == "Presentation" ? 2 : 1

var table contextPanel = table.new(
     f_panelPosition(panelPositionInput),
     6,
     12,
     bgcolor = panelBackground,
     frame_color = color.new(panelHeader, 0),
     frame_width = panelFrameWidth,
     border_color = panelGridColor,
     border_width = panelBorderWidth)

if barstate.isfirst
    table.merge_cells(contextPanel, 0, 0, 5, 0)
    table.merge_cells(contextPanel, 1, 6, 2, 6)
    table.merge_cells(contextPanel, 4, 6, 5, 6)
    table.merge_cells(contextPanel, 1, 7, 2, 7)
    table.merge_cells(contextPanel, 4, 7, 5, 7)
    table.merge_cells(contextPanel, 1, 8, 2, 8)
    table.merge_cells(contextPanel, 4, 8, 5, 8)
    table.merge_cells(contextPanel, 1, 9, 2, 9)
    table.merge_cells(contextPanel, 4, 9, 5, 9)
    table.merge_cells(contextPanel, 1, 10, 2, 10)
    table.merge_cells(contextPanel, 4, 10, 5, 10)
    table.merge_cells(contextPanel, 1, 11, 2, 11)
    table.merge_cells(contextPanel, 4, 11, 5, 11)

if barstate.islast
    if showPanel
        string panelFont = f_panelFont(panelFontInput)
        color headerText = f_contrastText(panelHeader)
        color headerRowBackground = color.rgb(24, 43, 65)
        color dailyRowBackground = color.rgb(6, 17, 31)
        color weeklyRowBackground = color.rgb(19, 13, 39)
        color summaryLabelBackground = color.rgb(20, 39, 59)
        color summaryValueBackground = color.rgb(3, 10, 20)

        table.cell(
             contextPanel, 0, 0, "◈ BOUNDARY RESPONSE REGISTER",
             text_color = headerText,
             text_size = panelTitleTextSize,
             text_font_family = panelFont,
             text_formatting = text.format_bold,
             text_halign = text.align_center,
             bgcolor = panelHeader,
             tooltip = "PDH · PDL · PWH · PWL\nStateful response measurements for four raw completed-period boundaries. This register calculates no pivot formulas, pivot ladder, arrival rank, or next target.")

        if supportedTimeframe
            table.cell(contextPanel, 0, 1, "LEVEL", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = headerRowBackground)
            table.cell(contextPanel, 1, 1, "PRICE", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = headerRowBackground)
            table.cell(contextPanel, 2, 1, "STATE", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = headerRowBackground, tooltip = "Lifecycle plus abbreviated first-contact form when available: GAP, CLOSE, WICK, or TOUCH.")
            table.cell(contextPanel, 3, 1, "Δ ATR", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = headerRowBackground, tooltip = "Current confirmed source close minus the boundary, divided by the last completed daily ATR.")
            table.cell(contextPanel, 4, 1, "OUT/X", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = headerRowBackground, tooltip = "Outside-close residency percentage / close-side recross count.")
            table.cell(contextPanel, 5, 1, "MAX O/I", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = headerRowBackground, tooltip = "Maximum outside excursion / maximum return into the prior range, both in frozen daily ATR units.")

            float pdhAtrDistance = not na(eventClose) and not na(completedDailyAtr) and completedDailyAtr > 0.0 ? (eventClose - pdh) / completedDailyAtr : na
            float pdlAtrDistance = not na(eventClose) and not na(completedDailyAtr) and completedDailyAtr > 0.0 ? (eventClose - pdl) / completedDailyAtr : na
            float pwhAtrDistance = not na(eventClose) and not na(completedDailyAtr) and completedDailyAtr > 0.0 ? (eventClose - pwh) / completedDailyAtr : na
            float pwlAtrDistance = not na(eventClose) and not na(completedDailyAtr) and completedDailyAtr > 0.0 ? (eventClose - pwl) / completedDailyAtr : na

            string pdhState = showDaily ? f_stateFormText(0, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady) : "OFF"
            string pdlState = showDaily ? f_stateFormText(1, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady) : "OFF"
            string pwhState = showWeekly ? f_stateFormText(2, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady) : "OFF"
            string pwlState = showWeekly ? f_stateFormText(3, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady) : "OFF"

            string pdhTooltip = f_levelTooltip("PDH", "Previous completed daily high", pdh, 0, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady)
            string pdlTooltip = f_levelTooltip("PDL", "Previous completed daily low", pdl, 1, dayTrackable, lifecycleEvaluationAllowed, eventSourceReady)
            string pwhTooltip = f_levelTooltip("PWH", "Previous completed weekly high", pwh, 2, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady)
            string pwlTooltip = f_levelTooltip("PWL", "Previous completed weekly low", pwl, 3, weekTrackable, lifecycleEvaluationAllowed, eventSourceReady)

            float pdhOutsideShare = f_outsideShare(0)
            float pdlOutsideShare = f_outsideShare(1)
            float pwhOutsideShare = f_outsideShare(2)
            float pwlOutsideShare = f_outsideShare(3)

            color pdhStateBackground = color.new(pdhColor, array.get(levelReturned, 0) ? 62 : array.get(levelHeldOutside, 0) ? 50 : array.get(levelContacted, 0) ? 68 : 86)
            color pdlStateBackground = color.new(pdlColor, array.get(levelReturned, 1) ? 62 : array.get(levelHeldOutside, 1) ? 50 : array.get(levelContacted, 1) ? 68 : 86)
            color pwhStateBackground = color.new(pwhColor, array.get(levelReturned, 2) ? 62 : array.get(levelHeldOutside, 2) ? 50 : array.get(levelContacted, 2) ? 68 : 86)
            color pwlStateBackground = color.new(pwlColor, array.get(levelReturned, 3) ? 62 : array.get(levelHeldOutside, 3) ? 50 : array.get(levelContacted, 3) ? 68 : 86)

            table.cell(contextPanel, 0, 2, "▲ PDH", text_color = f_contrastText(pdhColor), text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pdhColor, tooltip = pdhTooltip)
            table.cell(contextPanel, 1, 2, showDaily ? f_price(pdh) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = dailyRowBackground, tooltip = pdhTooltip)
            table.cell(contextPanel, 2, 2, pdhState, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pdhStateBackground, tooltip = pdhTooltip)
            table.cell(contextPanel, 3, 2, showDaily ? f_signedNumber(pdhAtrDistance) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = dailyRowBackground, tooltip = "Current close distance from PDH in completed daily ATR units.")
            table.cell(contextPanel, 4, 2, not trackResponseRegister or not showDaily ? "OFF" : f_outsideRecrossText(0), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pdhColor, pdhOutsideShare), tooltip = f_responseTooltip("PDH", 0))
            table.cell(contextPanel, 5, 2, not trackResponseRegister or not showDaily ? "OFF" : f_excursionPairText(0), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pdhColor, pdhOutsideShare), tooltip = f_responseTooltip("PDH", 0))

            table.cell(contextPanel, 0, 3, "▼ PDL", text_color = f_contrastText(pdlColor), text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pdlColor, tooltip = pdlTooltip)
            table.cell(contextPanel, 1, 3, showDaily ? f_price(pdl) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = dailyRowBackground, tooltip = pdlTooltip)
            table.cell(contextPanel, 2, 3, pdlState, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pdlStateBackground, tooltip = pdlTooltip)
            table.cell(contextPanel, 3, 3, showDaily ? f_signedNumber(pdlAtrDistance) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = dailyRowBackground, tooltip = "Current close distance from PDL in completed daily ATR units.")
            table.cell(contextPanel, 4, 3, not trackResponseRegister or not showDaily ? "OFF" : f_outsideRecrossText(1), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pdlColor, pdlOutsideShare), tooltip = f_responseTooltip("PDL", 1))
            table.cell(contextPanel, 5, 3, not trackResponseRegister or not showDaily ? "OFF" : f_excursionPairText(1), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pdlColor, pdlOutsideShare), tooltip = f_responseTooltip("PDL", 1))

            table.cell(contextPanel, 0, 4, "▲ PWH", text_color = f_contrastText(pwhColor), text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pwhColor, tooltip = pwhTooltip)
            table.cell(contextPanel, 1, 4, showWeekly ? f_price(pwh) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = weeklyRowBackground, tooltip = pwhTooltip)
            table.cell(contextPanel, 2, 4, pwhState, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pwhStateBackground, tooltip = pwhTooltip)
            table.cell(contextPanel, 3, 4, showWeekly ? f_signedNumber(pwhAtrDistance) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = weeklyRowBackground, tooltip = "Current close distance from PWH in completed daily ATR units.")
            table.cell(contextPanel, 4, 4, not trackResponseRegister or not showWeekly ? "OFF" : f_outsideRecrossText(2), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pwhColor, pwhOutsideShare), tooltip = f_responseTooltip("PWH", 2))
            table.cell(contextPanel, 5, 4, not trackResponseRegister or not showWeekly ? "OFF" : f_excursionPairText(2), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pwhColor, pwhOutsideShare), tooltip = f_responseTooltip("PWH", 2))

            table.cell(contextPanel, 0, 5, "▼ PWL", text_color = f_contrastText(pwlColor), text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pwlColor, tooltip = pwlTooltip)
            table.cell(contextPanel, 1, 5, showWeekly ? f_price(pwl) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = weeklyRowBackground, tooltip = pwlTooltip)
            table.cell(contextPanel, 2, 5, pwlState, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = pwlStateBackground, tooltip = pwlTooltip)
            table.cell(contextPanel, 3, 5, showWeekly ? f_signedNumber(pwlAtrDistance) : "—", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = weeklyRowBackground, tooltip = "Current close distance from PWL in completed daily ATR units.")
            table.cell(contextPanel, 4, 5, not trackResponseRegister or not showWeekly ? "OFF" : f_outsideRecrossText(3), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pwlColor, pwlOutsideShare), tooltip = f_responseTooltip("PWL", 3))
            table.cell(contextPanel, 5, 5, not trackResponseRegister or not showWeekly ? "OFF" : f_excursionPairText(3), text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_right, bgcolor = f_responseCellColor(pwlColor, pwlOutsideShare), tooltip = f_responseTooltip("PWL", 3))

            string dayContactSpan = showDaily ? f_contactSpanCompact(0, 1, "PDH", "PDL") : "OFF"
            string weekContactSpan = showWeekly ? f_contactSpanCompact(2, 3, "PWH", "PWL") : "OFF"
            bool dayContactPairComplete = not na(array.get(levelFirstContactBar, 0)) and not na(array.get(levelFirstContactBar, 1))
            bool weekContactPairComplete = not na(array.get(levelFirstContactBar, 2)) and not na(array.get(levelFirstContactBar, 3))
            float dailyCoordinate = f_rangeCoordinate(eventClose, pdh, pdl)
            float weeklyCoordinate = f_rangeCoordinate(eventClose, pwh, pwl)
            string rangeRelationFull = showDaily and showWeekly ? f_relation(pdh, pdl, pwh, pwl) : "Requires daily + weekly"
            string rangeRelation = showDaily and showWeekly ? f_relationCompact(rangeRelationFull) : "NEED D+W"
            string sharedText = not (showDaily and showWeekly) ? "OFF" : not sharedRangeExists ? "○ NONE" : "D " + f_gaugeIcon(sharedOfDay) + " " + f_percent(sharedOfDay) + " | W " + f_gaugeIcon(sharedOfWeek) + " " + f_percent(sharedOfWeek)
            string dayRangeText = not showDaily ? "OFF" : not lifecycleEvaluationAllowed ? "! PAUSED" : not eventSourceReady ? "! SOURCE GAP" : f_gaugeIcon(dayRangeUse) + " " + f_percent(dayRangeUse) + (dayTrackable ? "" : " PARTIAL")
            string weekRangeText = not showWeekly ? "OFF" : not lifecycleEvaluationAllowed ? "! PAUSED" : not eventSourceReady ? "! SOURCE GAP" : f_gaugeIcon(weekRangeUse) + " " + f_percent(weekRangeUse) + (weekTrackable ? "" : " PARTIAL")
            bool clusterDataReady = not na(highClusterThreshold) and not na(lowClusterThreshold)
            string clusterText = not showClusters ? "OFF" : not (showDaily and showWeekly) ? "NEED D+W" : not clusterDataReady ? (clusterMode == "Daily ATR" ? "… WARM-UP" : "! UNAVAILABLE") : highCluster and lowCluster ? "▲ + ▼" : highCluster ? "▲ HIGH" : lowCluster ? "▼ LOW" : "○ NONE"
            bool hullReady = showDaily and showWeekly and not na(pdh) and not na(pdl) and not na(pwh) and not na(pwl)
            float hullUpper = hullReady ? math.max(pdh, pwh) : na
            float hullLower = hullReady ? math.min(pdl, pwl) : na
            float hullCoordinate = f_rangeCoordinate(eventClose, hullUpper, hullLower)
            float hullWidthAtr = hullReady and not na(completedDailyAtr) and completedDailyAtr > 0.0 ? (hullUpper - hullLower) / completedDailyAtr : na
            string hullUpperCode = not hullReady ? "—" : pdh > pwh ? "PDH" : pwh > pdh ? "PWH" : "PDH=PWH"
            string hullLowerCode = not hullReady ? "—" : pdl < pwl ? "PDL" : pwl < pdl ? "PWL" : "PDL=PWL"
            string hullText = not hullReady ? "OFF" : f_gaugeIcon(hullCoordinate) + " " + f_coordinateText(hullCoordinate) + " | " + hullUpperCode + "/" + hullLowerCode + " | " + f_atrMetric(hullWidthAtr) + "A"
            string breadthText = f_stateBreadthCompact(showDaily, showWeekly)
            string sourceBase = useStandardSource ? "STD" : "CHART"
            string sourceText = sourceMode == "Automatic" ? "AUTO|" + sourceBase : sourceBase
            if not chart.is_standard and not useStandardSource
                sourceText += "|SYN"
            if not chart.is_standard and not allowNonStandardEvents
                sourceText += "|PAUSED"
            if not eventSourceReady
                sourceText += "|GAP"
            string sourceTooltip = "Resolved source: " + resolvedSourceName
            sourceTooltip += "\nReference-data mode: " + sourceMode
            if not chart.is_standard and not useStandardSource
                sourceTooltip += "\nLevels use the synthetic chart context."
            if not chart.is_standard and not allowNonStandardEvents
                sourceTooltip += "\nLifecycle events are paused on this non-standard chart."
            if not eventSourceReady
                sourceTooltip += "\nThe selected event source has no usable bar at the current chart timestamp."

            string dayStatusText = showDaily ? "C " + dayContactSpan + " | " + f_gaugeIcon(dailyCoordinate) + " " + f_coordinateText(dailyCoordinate) : "OFF"
            string weekStatusText = showWeekly ? "C " + weekContactSpan + " | " + f_gaugeIcon(weeklyCoordinate) + " " + f_coordinateText(weeklyCoordinate) : "OFF"

            table.cell(contextPanel, 0, 6, "◉ DAY", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "C = contact coverage/span for PDH and PDL. P = confirmed-close coordinate within the prior daily range.")
            table.cell(contextPanel, 1, 6, dayStatusText, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = dayContactPairComplete ? color.new(pdhColor, 70) : summaryValueBackground)
            table.cell(contextPanel, 3, 6, "◉ WEEK", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "C = contact coverage/span for PWH and PWL. P = confirmed-close coordinate within the prior weekly range.")
            table.cell(contextPanel, 4, 6, weekStatusText, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = weekContactPairComplete ? color.new(pwhColor, 70) : summaryValueBackground)

            table.cell(contextPanel, 0, 7, "↔ REL", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Full relationship: " + str.upper(rangeRelationFull))
            table.cell(contextPanel, 1, 7, rangeRelation, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = summaryValueBackground)
            table.cell(contextPanel, 3, 7, "∩ SHARED", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Intersection as a percentage of the prior daily and weekly ranges.")
            table.cell(contextPanel, 4, 7, sharedText, text_color = sharedRangeExists ? panelTextColor : panelMutedTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = sharedRangeExists ? color.new(sharedCorridorColor, 70) : summaryValueBackground)

            table.cell(contextPanel, 0, 8, "◒ D RANGE", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Current day range as a percentage of the previous completed daily range.")
            table.cell(contextPanel, 1, 8, dayRangeText, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = summaryValueBackground)
            table.cell(contextPanel, 3, 8, "◒ W RANGE", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Current week range as a percentage of the previous completed weekly range.")
            table.cell(contextPanel, 4, 8, weekRangeText, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = summaryValueBackground)

            table.cell(contextPanel, 0, 9, "▲ GAP", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Absolute PDH/PWH separation. A = completed daily ATR units. T = ticks.")
            table.cell(contextPanel, 1, 9, showDaily and showWeekly ? f_pairGapCompact(pdh, pwh, completedDailyAtr) : "OFF", text_color = highCluster ? panelTextColor : panelMutedTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = highCluster ? color.new(highClusterColor, 65) : summaryValueBackground)
            table.cell(contextPanel, 3, 9, "▼ GAP", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Absolute PDL/PWL separation. A = completed daily ATR units. T = ticks.")
            table.cell(contextPanel, 4, 9, showDaily and showWeekly ? f_pairGapCompact(pdl, pwl, completedDailyAtr) : "OFF", text_color = lowCluster ? panelTextColor : panelMutedTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = lowCluster ? color.new(lowClusterColor, 65) : summaryValueBackground)

            table.cell(contextPanel, 0, 10, "◇ HULL", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Four-level outer envelope. The value shows close coordinate, upper/lower anchors, and total width in completed daily ATR units.")
            table.cell(contextPanel, 1, 10, hullText, text_color = hullReady ? panelTextColor : panelMutedTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = hullReady ? color.new(panelHeader, 76) : summaryValueBackground)
            table.cell(contextPanel, 3, 10, "● BREADTH", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "C = contacted, S = sustained beyond, R = re-entered. Denominator = enabled boundaries.")
            table.cell(contextPanel, 4, 10, breadthText, text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = color.new(panelHeader, 82))

            table.cell(contextPanel, 0, 11, "≈ NEARBY", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = "Configured proximity result for PDH/PWH and PDL/PWL. No support/resistance meaning is assigned.")
            table.cell(contextPanel, 1, 11, clusterText, text_color = highCluster or lowCluster ? panelTextColor : panelMutedTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = highCluster or lowCluster ? color.new(panelHeader, 62) : summaryValueBackground)
            table.cell(contextPanel, 3, 11, "• SOURCE", text_color = panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_left, bgcolor = summaryLabelBackground, tooltip = sourceTooltip)
            table.cell(contextPanel, 4, 11, sourceText, text_color = not chart.is_standard or not eventSourceReady ? color.rgb(255, 224, 102) : panelTextColor, text_size = panelBodyTextSize, text_font_family = panelFont, text_formatting = text.format_bold, text_halign = text.align_center, bgcolor = summaryValueBackground, tooltip = sourceTooltip)
        else
            color unsupportedBackground = color.rgb(156, 34, 52)
            table.cell(contextPanel, 0, 1, "USE", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, bgcolor = unsupportedBackground)
            table.cell(contextPanel, 1, 1, "TIME", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, bgcolor = unsupportedBackground)
            table.cell(contextPanel, 2, 1, "BASED", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, bgcolor = unsupportedBackground)
            table.cell(contextPanel, 3, 1, "INTRADAY", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, bgcolor = unsupportedBackground)
            table.cell(contextPanel, 4, 1, "OR 1D", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, bgcolor = unsupportedBackground)
            table.cell(contextPanel, 5, 1, "CHART", text_color = panelTextColor, text_size = panelColumnTextSize, text_font_family = panelFont, text_formatting = text.format_bold, bgcolor = unsupportedBackground)
    else
        table.clear(contextPanel, 0, 0, 5, 11)

//------------------------------------------------------------------------------
// Neutral alerts
//------------------------------------------------------------------------------
bool anyContactEvent = pdhContactEvent or pdlContactEvent or pwhContactEvent or pwlContactEvent
bool anyHeldEvent = pdhHeldEvent or pdlHeldEvent or pwhHeldEvent or pwlHeldEvent
bool anyReturnEvent = pdhReturnEvent or pdlReturnEvent or pwhReturnEvent or pwlReturnEvent

alertcondition(anyContactEvent, "Any prior high/low first contact", "A previous-day or previous-week high/low received its first confirmed contact on {{ticker}} {{interval}}.")
alertcondition(pdhContactEvent, "PDH first contact", "PDH received its first confirmed contact on {{ticker}} {{interval}}.")
alertcondition(pdlContactEvent, "PDL first contact", "PDL received its first confirmed contact on {{ticker}} {{interval}}.")
alertcondition(pwhContactEvent, "PWH first contact", "PWH received its first confirmed contact on {{ticker}} {{interval}}.")
alertcondition(pwlContactEvent, "PWL first contact", "PWL received its first confirmed contact on {{ticker}} {{interval}}.")

alertcondition(anyHeldEvent, "Any prior high/low sustained beyond", "A previous-day or previous-week high/low reached the configured confirmed-close sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pdhHeldEvent, "PDH sustained beyond", "PDH reached the configured confirmed-close sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pdlHeldEvent, "PDL sustained beyond", "PDL reached the configured confirmed-close sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pwhHeldEvent, "PWH sustained beyond", "PWH reached the configured confirmed-close sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pwlHeldEvent, "PWL sustained beyond", "PWL reached the configured confirmed-close sustained-beyond condition on {{ticker}} {{interval}}.")

alertcondition(anyReturnEvent, "Any prior high/low re-entered", "Price closed back through a previous-day or previous-week boundary after the configured sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pdhReturnEvent, "PDH re-entered", "Price closed back through PDH into the prior-day range after the configured sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pdlReturnEvent, "PDL re-entered", "Price closed back through PDL into the prior-day range after the configured sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pwhReturnEvent, "PWH re-entered", "Price closed back through PWH into the prior-week range after the configured sustained-beyond condition on {{ticker}} {{interval}}.")
alertcondition(pwlReturnEvent, "PWL re-entered", "Price closed back through PWL into the prior-week range after the configured sustained-beyond condition on {{ticker}} {{interval}}.")

alertcondition(highClusterFormed, "PDH and PWH became nearby", "PDH and PWH entered the configured nearby-level threshold on {{ticker}} {{interval}}.")
alertcondition(lowClusterFormed, "PDL and PWL became nearby", "PDL and PWL entered the configured nearby-level threshold on {{ticker}} {{interval}}.")

alertcondition(dailyContactPairCompletedNow, "Daily boundary pair contacted", "Both PDH and PDL have now received a first confirmed contact during the current source day on {{ticker}} {{interval}}.")
alertcondition(weeklyContactPairCompletedNow, "Weekly boundary pair contacted", "Both PWH and PWL have now received a first confirmed contact during the current source week on {{ticker}} {{interval}}.")

bool anyResidencyThresholdEvent = pdhResidencyThresholdEvent or pdlResidencyThresholdEvent or pwhResidencyThresholdEvent or pwlResidencyThresholdEvent
bool anyExcursionThresholdEvent = pdhExcursionThresholdEvent or pdlExcursionThresholdEvent or pwhExcursionThresholdEvent or pwlExcursionThresholdEvent

alertcondition(anyResidencyThresholdEvent, "Any boundary outside-close residency threshold", "A PDH/PDL/PWH/PWL post-contact outside-close residency threshold was reached on {{ticker}} {{interval}}.")
alertcondition(anyExcursionThresholdEvent, "Any boundary outside-excursion threshold", "A PDH/PDL/PWH/PWL post-contact outside-excursion threshold was reached on {{ticker}} {{interval}}.")

if enableDynamicAlerts and barstate.isconfirmed
    string dynamicMessage = ""
    if pdhContactEvent
        dynamicMessage := f_append(dynamicMessage, "PDH first contact @ " + f_price(pdh))
    if pdlContactEvent
        dynamicMessage := f_append(dynamicMessage, "PDL first contact @ " + f_price(pdl))
    if pwhContactEvent
        dynamicMessage := f_append(dynamicMessage, "PWH first contact @ " + f_price(pwh))
    if pwlContactEvent
        dynamicMessage := f_append(dynamicMessage, "PWL first contact @ " + f_price(pwl))

    if pdhHeldEvent
        dynamicMessage := f_append(dynamicMessage, "PDH sustained beyond @ " + f_price(pdh))
    if pdlHeldEvent
        dynamicMessage := f_append(dynamicMessage, "PDL sustained beyond @ " + f_price(pdl))
    if pwhHeldEvent
        dynamicMessage := f_append(dynamicMessage, "PWH sustained beyond @ " + f_price(pwh))
    if pwlHeldEvent
        dynamicMessage := f_append(dynamicMessage, "PWL sustained beyond @ " + f_price(pwl))

    if pdhReturnEvent
        dynamicMessage := f_append(dynamicMessage, "PDH closed back through @ " + f_price(pdh))
    if pdlReturnEvent
        dynamicMessage := f_append(dynamicMessage, "PDL closed back through @ " + f_price(pdl))
    if pwhReturnEvent
        dynamicMessage := f_append(dynamicMessage, "PWH closed back through @ " + f_price(pwh))
    if pwlReturnEvent
        dynamicMessage := f_append(dynamicMessage, "PWL closed back through @ " + f_price(pwl))

    if highClusterFormed
        dynamicMessage := f_append(dynamicMessage, "PDH/PWH nearby pair")
    if lowClusterFormed
        dynamicMessage := f_append(dynamicMessage, "PDL/PWL nearby pair")

    if dailyContactPairCompletedNow
        dynamicMessage := f_append(dynamicMessage, "Daily contact pair " + f_contactSpanText(0, 1, "PDH", "PDL"))
    if weeklyContactPairCompletedNow
        dynamicMessage := f_append(dynamicMessage, "Weekly contact pair " + f_contactSpanText(2, 3, "PWH", "PWL"))

    if pdhResidencyThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PDH outside-close residency " + f_percent(f_outsideShare(0)))
    if pdlResidencyThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PDL outside-close residency " + f_percent(f_outsideShare(1)))
    if pwhResidencyThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PWH outside-close residency " + f_percent(f_outsideShare(2)))
    if pwlResidencyThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PWL outside-close residency " + f_percent(f_outsideShare(3)))

    if pdhExcursionThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PDH max outside excursion " + f_atrMetric(f_responseAtr(0, true)) + " ATR")
    if pdlExcursionThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PDL max outside excursion " + f_atrMetric(f_responseAtr(1, true)) + " ATR")
    if pwhExcursionThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PWH max outside excursion " + f_atrMetric(f_responseAtr(2, true)) + " ATR")
    if pwlExcursionThresholdEvent
        dynamicMessage := f_append(dynamicMessage, "PWL max outside excursion " + f_atrMetric(f_responseAtr(3, true)) + " ATR")

    if dynamicMessage != ""
        alert(syminfo.ticker + " " + timeframe.period + " | " + dynamicMessage, alert.freq_once_per_bar_close)
````
