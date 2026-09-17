<!-- tradingview-pine-id: PUB;22796e7c1e554da08f1d48996a5f6d99 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fibonacci Retracement Depth & Retest Grid - Swing High Low

Source: https://www.tradingview.com/script/SqK5NBqp-Fibonacci-Retracement-Depth-Retest-Grid-Swing-High-Low/

## Description

OVERVIEW

Fibonacci Retracement Depth & Retest Grid - Swing High Low is an open-source chart overlay for measuring retracement depth inside an automatically selected price leg.

The script combines an automatic right-confirmed swing engine, a bounded local-range fallback, optional manual-origin control, rolling-range analysis, configurable Fibonacci ratios, distinct touch-episode tracking, fixed-horizon response measurements, larger-range ratio proximity, factual alerts, and a compact context readout.

It is a descriptive research tool. It does not generate entries, exits, targets, stops, position sizes, probability estimates, win rates, or performance claims. It does not use artificial intelligence, machine learning, external datasets, or third-party libraries.

CORE FIBONACCI CALCULATION

For an active origin and terminal, each level is calculated as:

level = terminal + (origin - terminal) * ratio

The terminal anchor is 0%, and the origin anchor is 100%.

Current retracement depth is calculated as:

depth = (reference price - terminal) / (origin - terminal)

This produces the same interpretation for upward and downward legs:

- 0% means price is at the terminal anchor.
- 100% means price is at the origin anchor.
- A value below 0% means price has moved beyond the terminal.
- A value above 100% means price has moved beyond the origin.

The current-depth cursor displays the actual calculated value. Its chart position is bounded between the two anchors so that an extreme value does not distort the visible layout.

ANCHOR ENGINES

The script provides three anchor engines.

1. Automatic swing

Automatic swing is the default.

The engine detects pivot highs and lows from either wicks or closing prices. A pivot is accepted only after the configured number of right-side bars has closed. Accepted pivots must alternate between high and low.

A new opposite-side pivot must satisfy:

- Minimum spacing in chart bars.
- A non-zero price distance.
- An optional minimum leg size expressed in ATR.

A later pivot of the same type can revise the active terminal only when it is more extreme by at least the configured minimum-tick threshold. This reduces small live revisions and visual flicker.

When a complete confirmed pivot pair is not yet available, the script uses a bounded local high-low range so the chart does not remain blank. The default local window is 120 finalized bars. The fallback is replaced automatically when a valid confirmed swing pair becomes available.

2. Manual origin

Manual origin is an explicit optional mode.

The user selects a paired time-and-price point as the structural origin. The script then searches after that point for the most extreme valid terminal in the selected direction.

Direction can be:

- Auto from point
- Up leg
- Down leg

The origin price can snap to the selected bar or preserve the exact selected price. By default, the terminal uses closed bars only to reduce intrabar movement of the complete Fibonacci structure.

Manual origin does not silently fall back to an automatic structure. If the selected point or terminal is invalid, no manual grid is displayed until the point or settings are corrected.

3. Rolling range

Rolling range uses the highest and lowest selected source values inside a fixed lookback. The chronological order of the two extremes determines whether the leg is upward or downward.

A minimum span in bars is required between the extremes. The anchors can change as the lookback advances, so current-structure statistics reset whenever the active pair changes.

CONFIRMATION AND HISTORICAL PLACEMENT

In Automatic swing mode, an H or L marker is placed at the historical pivot bar after that pivot becomes confirmed.

The diagonal anchor leg connects the actual origin and terminal bars. However, the horizontal Fibonacci levels do not begin before the complete structure became available to the script. They begin from the availability point rather than being extended backward through bars where the completed pair was not yet knowable.

This distinction is intentional:

- The anchor marker shows where the pivot occurred.
- The level start shows when the active structure became available.

A marker on a historical pivot bar should not be interpreted as evidence that the pivot was known on that original bar.

If a high pivot and low pivot are both confirmed from the same chart bar, finalized OHLC data cannot prove which extreme occurred first inside that bar. When a previous terminal type exists, the engine prefers the opposite candidate to preserve alternation. It does not invent an intrabar order that the available data cannot establish.

PAST-CHART STUDY

When Use visible right edge in past charts is enabled and the chart is scrolled away from the latest bar, the visible right edge becomes the study endpoint.

Inside the configurable local window, the script first looks for a recent accepted confirmed swing. If a suitable pair is not available, it uses a bounded local high-low range ending at the visible right edge.

This prevents historical study from automatically expanding to the absolute high and low of an excessively large viewport.

Past-chart auto-follow is retrospective. The completed visible period is already known. Therefore:

- Sequential touch-response statistics are disabled.
- Price-event alerts are disabled.
- The readout changes from Response to Study.

For chronology-sensitive historical testing, use Automatic swing with TradingView Bar Replay. Pivots will become available only after the configured right-side confirmation bars.

CONFIGURABLE FIBONACCI LEVELS

The script contains ten independently editable ratio slots.

The default enabled ratios are:

- 0.000
- 0.236
- 0.382
- 0.500
- 0.618
- 0.786
- 1.000

The following ratios are available but disabled by default:

- 0.650
- 0.705
- 0.886

Each slot can be enabled, disabled, or changed. Inputs accept values from -2.000 to 3.000, allowing custom retracement or extension research.

The script does not assume that a custom ratio is predictive or statistically significant.

DEPTH BANDS

Three optional visual bands organize the interior of the active retracement.

By default, they represent:

- 38.2% to 50.0%
- 50.0% to 61.8%
- 61.8% to 78.6%

The bands are built from configurable ratio slots. Changing those inputs changes the corresponding band boundaries.

The readout classifies proportional location as:

- Shallow
- Mid
- Deep
- T+ for beyond the terminal
- O+ for beyond the origin

These labels describe location only. They do not describe trade quality or reversal probability.

DISTINCT TOUCH EPISODES

Reaction research is available for enabled interior ratios greater than 0 and less than 1.

A level is contacted when the bar range intersects the configured tolerance around that price. Tolerance can be defined using:

- ATR
- A percentage of the active leg
- Minimum ticks

The script does not count every consecutive bar near a level as a separate reaction.

After an initial touch, price must move completely outside the wider re-arm envelope before another touch can be counted. This separates repeated contact into distinct touch episodes and reduces inflated counts caused by several bars remaining near the same price.

The latest counted touch for each level can be marked on the chart.

Touch statistics belong only to the current active anchor structure. They reset whenever the active origin or terminal changes.

FIXED-HORIZON RESPONSE RESEARCH

Each new touch episode creates an independent pending measurement.

After the configured number of chart bars has elapsed, the script measures the closing price relative to the touched level and normalizes the result by the active leg size.

The sign is aligned with the active leg direction:

- A positive response means the horizon close moved toward the terminal direction.
- A negative response means the horizon close moved toward the origin direction.

The readout uses:

- T for counted touch episodes.
- R for completed fixed-horizon measurements.

The displayed average is the arithmetic mean of completed measurements for the nearest enabled ratio within the current active structure.

This measurement is not:

- A bounce rate.
- A support or resistance score.
- Maximum favorable excursion.
- Maximum adverse excursion.
- A win rate.
- A probability estimate.
- A strategy result.

If the active anchors change before a pending response reaches its horizon, that pending measurement is discarded with the other statistics from the previous structure.

LARGER-RANGE RATIO PROXIMITY

The script can calculate a second Fibonacci structure from a longer rolling high-low range.

Each enabled primary level is compared with every enabled level in the larger-range structure. Proximity tolerance can be defined using:

- ATR
- A percentage of the primary leg
- Minimum ticks

When a primary level is sufficiently close to a larger-range ratio:

- Its line is highlighted.
- Its line width is increased.
- A diamond is added to its label.

This is a distance comparison only. It does not mean that the level is stronger, that price will reverse, or that the level will hold.

VISUAL OUTPUT

The default visual structure includes:

- A directional origin-to-terminal anchor leg.
- H and L anchor markers.
- Configurable Fibonacci level lines.
- Ratio and price labels.
- Three optional depth bands.
- A current-depth cursor.
- Latest-touch markers.
- Larger-range proximity diamonds.
- A compact bold context readout.

The readout summarizes:

- Active anchor engine and leg span.
- Current retracement depth.
- Nearest enabled level and ATR-normalized distance.
- Touch and response information, or historical study scope.
- Larger-range proximity and event-timing context.

Detailed explanations are available through cell and label tooltips so the visible panel can remain concise.

The readout also reserves a transparent horizontal edge-clearance lane. This keeps TradingView High/Low labels and price-scale markers visible when the panel is placed at a chart edge. The default clearance is 6% and can be adjusted in Settings.

Colors, line style, line widths, label content, label size, table position, table size, edge clearance, band opacity, and individual ratios are configurable.

ALERTS

The script provides factual alert conditions for:

- New confirmed Fibonacci swing structure
- Confirmed Fibonacci terminal revision
- Fibonacci level touch episode
- Core Fibonacci band entered
- Fibonacci origin crossed
- Fibonacci terminal crossed

The core band is defined by the Ratio 4 and Ratio 5 inputs.

Dynamic touch alerts are also available. When enabled, create a TradingView alert using Any alert() function call. The message reports the touched ratios, symbol, chart timeframe, and current close.

Confirmed-bar event evaluation is enabled by default.

Past-chart retrospective mode does not generate these price-event alerts.

Alerts report observed chart events only. They are not trade recommendations.

SUGGESTED WORKFLOWS

For current-market observation:

1. Keep Anchor engine on Automatic swing.
2. Keep Evaluate events on confirmed bars only enabled.
3. Select Wicks or Closes according to the research definition.
4. Adjust pivot left and right bars to control swing sensitivity.
5. Use Minimum leg ATR and Minimum bars between alternating pivots to reduce minor structures.
6. Use Automatic local window bars to control the warm-up and historical fallback horizon.
7. Read current depth and responses as descriptive context, not as an entry instruction.

For chronology-sensitive historical study:

1. Keep Anchor engine on Automatic swing.
2. Start TradingView Bar Replay before the period being studied.
3. Advance one bar at a time or at a controlled speed.
4. Observe when pivots become confirmed and when the Fibonacci grid becomes available.
5. Review touch episodes and completed fixed-horizon responses as replay advances.

For fast retrospective study:

1. Keep Use visible right edge in past charts enabled.
2. Scroll to the historical period.
3. Adjust the chart so the desired local structure is near the visible right edge.
4. Adjust Automatic local window bars if more or less structural context is required.
5. Review the Past swing or Past range readout state.

For a user-defined structural start:

1. Select Manual origin.
2. Set or reset the paired Origin point.
3. Choose Auto from point, Up leg, or Down leg.
4. Choose whether to snap to the selected bar or use the exact selected price.
5. Keep closed-bar terminal updates enabled for the more stable live behavior.

For an objective fixed-window range:

1. Select Rolling range.
2. Set the desired lookback.
3. Increase Minimum range span bars when short high-low pairs create excessive changes.

WHAT MAKES THIS IMPLEMENTATION DISTINCT

Fibonacci ratios and arithmetic retracement geometry are established public concepts. This script does not claim ownership of them.

Its distinct implementation choices include:

- Separation of historical pivot location from the later time when the structure becomes available.
- Availability-gated horizontal levels rather than unrestricted backward extension.
- Automatic confirmed-swing selection with a bounded finalized-bar warm-up fallback.
- Local past-chart auto-follow that avoids forcing the absolute extremes of a large viewport.
- Optional manual-origin and rolling-range engines in the same open implementation.
- Minimum spacing, ATR size, range-span, and tick-based terminal-revision filters.
- Distinct touch episodes controlled by a re-arm envelope.
- Independent fixed-horizon measurements normalized by active leg size.
- Direction-aligned descriptive responses rather than predictive bounce scores.
- Larger-range ratio proximity with configurable tolerance.
- Explicit separation of live, Bar Replay, and retrospective chart study.
- Compact tooltips and an edge-clearance lane designed to preserve chart-label visibility.
- Factual alerts without entries, exits, or performance claims.

The implementation uses conventional Fibonacci arithmetic and Pine Script built-ins. It does not import another author's library, reproduce a paper-specific model, request outside-market data, or present a proprietary trading methodology.

LIMITATIONS

- Fibonacci levels are proportional reference levels. They do not guarantee support, resistance, reversal, continuation, or any other future outcome.
- Confirmed pivots require right-side bars, so recognition necessarily occurs after the pivot bar.
- The active terminal can be revised when a later confirmed same-side pivot exceeds it by the configured threshold.
- During automatic warm-up, the bounded local-range fallback can change as finalized bars change until a confirmed pivot pair becomes available.
- The script displays one active Fibonacci structure rather than a permanent archive of every historical grid.
- Rolling range changes as its lookback advances and can reset all current-structure statistics.
- Past-chart auto-follow is retrospective and changes when the visible right edge or local-window setting changes.
- Finalized OHLC bars do not reveal the sequence of price movement inside each bar.
- If one bar intersects several levels, each level can be recorded, but their exact intrabar order is unknown.
- If confirmed-bar evaluation is disabled, realtime event states can change before the bar closes. Reloaded historical bars contain finalized OHLC, not the original realtime tick sequence.
- The calculation uses the chart's current symbol, timeframe, session, and price series. It does not request higher-timeframe or external-market data.
- Results depend on the history supplied by TradingView and the selected data provider.
- The Fibonacci calculation is arithmetic in price. Changing the chart to logarithmic scale changes visual spacing but does not change the underlying formula.
- Heikin-Ashi, Renko, Kagi, Line Break, and other non-standard charts can contain synthetic prices. Use standard candles when actual traded-price geometry is required.
- ATR-normalized filters and distances depend on the selected symbol and timeframe.
- Custom ratios can be duplicated, reordered, or placed outside the 0-to-1 interval. Users are responsible for interpreting custom configurations.
- Default settings are general research starting points. They are not optimized for any instrument, timeframe, market, or outcome.
- This is an indicator, not a strategy or backtest engine.
- Nothing displayed by the script constitutes financial or investment advice.

OPEN-SOURCE NOTE

The source is published under the Mozilla Public License 2.0 so users can inspect, verify, modify, and study the implementation.

The script is intended to support transparent chart research without hidden calculations, restricted access, or performance promises.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SG_Group

//@version=6
indicator(
    "Fibonacci Retracement Depth & Retest Grid - Swing High Low",
    overlay = true,
    behind_chart = false,
    max_bars_back = 5000,
    max_lines_count = 80,
    max_labels_count = 120,
    max_boxes_count = 12
)

// This open-source indicator uses conventional Fibonacci ratios and Pine Script built-ins only.
// It does not issue entries, exits, targets, stops, probability estimates, or performance claims.
// The default workflow displays an automatic, right-confirmed swing structure.
// A bounded local-range fallback keeps the Fibonacci grid visible while a confirmed swing pair is still unavailable.
// Manual origin selection remains available as an explicit optional mode and recalculates the opposite terminal from that point.
// Historical auto-follow uses a configurable local window so past study remains possible without forcing a full-viewport macro range.
// The context readout reserves a transparent edge-clearance lane so chart High/Low labels remain unobstructed.

//#region ———————————————————— Constants and groups
const int LEVEL_COUNT = 10
const string GROUP_ANCHOR = "01 — Anchor engine"
const string GROUP_LEVELS = "02 — Fibonacci levels"
const string GROUP_REACTION = "03 — Reaction research"
const string GROUP_CONTEXT = "04 — Larger-range overlap"
const string GROUP_VISUAL = "05 — Visual design"
const string GROUP_READOUT = "06 — Readout and alerts"

const color DARK_PANEL = color.rgb(8, 14, 28)
const color DARK_PANEL_2 = color.rgb(13, 22, 40)
const color MUTED_TEXT = color.rgb(205, 219, 242)
const color BRIGHT_TEXT = color.rgb(240, 247, 255)
const color WARNING_COLOR = color.rgb(255, 193, 7)
//#endregion

//#region ———————————————————— Inputs
bool followVisibleRangeInput = input.bool(
    true,
    "Use visible right edge in past charts",
    tooltip = "When the latest bar is outside the visible chart, the visible right edge becomes the study endpoint. Automatic swing mode recalculates from a bounded local historical window; Manual origin preserves the selected point and searches only up to that visible endpoint.",
    group = GROUP_ANCHOR,
    display = display.none
)
string anchorModeInput = input.string(
    "Automatic swing",
    "Anchor engine",
    options = ["Automatic swing", "Manual origin", "Rolling range"],
    tooltip = "Automatic swing is the default. It uses the latest accepted right-confirmed pivot leg and a bounded local-range fallback during warm-up, so the grid remains visible. Manual origin lets you select the structural start point and calculates the opposite terminal automatically. Rolling range uses a fixed lookback.",
    group = GROUP_ANCHOR,
    display = display.none
)
float userOriginPriceInput = input.price(
    0.0,
    "Origin point",
    inline = "user-origin",
    group = GROUP_ANCHOR,
    confirm = false,
    display = display.none,
    active = anchorModeInput == "Manual origin"
)
int userOriginTimeInput = input.time(
    0,
    "",
    tooltip = "Used only in Manual origin mode. After switching modes, use Reset points from the script menu to place the paired point, then drag it when needed. Every point change recalculates the origin, direction, terminal, levels, depth, and statistics from scratch.",
    inline = "user-origin",
    group = GROUP_ANCHOR,
    confirm = false,
    display = display.none,
    active = anchorModeInput == "Manual origin"
)
string userOriginDirectionInput = input.string(
    "Auto from point",
    "Origin direction",
    options = ["Auto from point", "Up leg", "Down leg"],
    tooltip = "Auto first interprets a point nearer the selected bar's low as an up-leg origin and a point nearer its high as a down-leg origin. If that preferred side has no valid later terminal but the opposite side does, Auto uses the valid side instead. Up leg and Down leg enforce the selected direction without fallback.",
    group = GROUP_ANCHOR,
    display = display.none,
    active = anchorModeInput == "Manual origin"
)
string userOriginPriceModeInput = input.string(
    "Snap to selected bar",
    "Origin price handling",
    options = ["Snap to selected bar", "Use selected price"],
    tooltip = "Snap uses the selected bar's low for an up leg or high for a down leg; when Swing source is Closes, it uses the selected bar's close. Use selected price preserves the exact price coordinate of the point.",
    group = GROUP_ANCHOR,
    display = display.none,
    active = anchorModeInput == "Manual origin"
)
bool userTerminalClosedBarsInput = input.bool(
    true,
    "Use closed bars for auto terminal",
    tooltip = "Recommended for live use. The automatic terminal updates from closed bars only, reducing intrabar anchor flicker. Current depth can still update with the live price.",
    group = GROUP_ANCHOR,
    display = display.none,
    active = anchorModeInput == "Manual origin"
)
int userTerminalSearchLimitInput = input.int(
    0,
    "Terminal search limit bars",
    minval = 0,
    maxval = 5000,
    tooltip = "Maximum bars searched after the selected origin. Zero searches through the live edge or the visible historical endpoint. If the limit leaves no valid terminal, no Fibonacci structure is displayed.",
    group = GROUP_ANCHOR,
    display = display.none,
    active = anchorModeInput == "Manual origin"
)
string swingSourceInput = input.string(
    "Wicks",
    "Swing source",
    options = ["Wicks", "Closes"],
    tooltip = "Wicks uses high and low. Closes uses close for both upper and lower pivot/range detection.",
    group = GROUP_ANCHOR,
    display = display.none
)
int pivotLeftInput = input.int(
    5,
    "Pivot left bars",
    minval = 1,
    maxval = 50,
    group = GROUP_ANCHOR,
    inline = "pivot",
    display = display.none
)
int pivotRightInput = input.int(
    5,
    "Right bars",
    minval = 1,
    maxval = 50,
    tooltip = "A swing pivot becomes available only after this many bars have closed to its right.",
    group = GROUP_ANCHOR,
    inline = "pivot",
    display = display.none
)
int minimumPivotSpacingInput = input.int(
    3,
    "Minimum bars between alternating pivots",
    minval = 1,
    maxval = 200,
    group = GROUP_ANCHOR,
    display = display.none
)
int minimumRangeSpanInput = input.int(
    5,
    "Minimum range span bars",
    minval = 1,
    maxval = 500,
    tooltip = "Used only when Anchor engine is Rolling range.",
    group = GROUP_ANCHOR,
    display = display.none
)
int atrLengthInput = input.int(
    14,
    "ATR length",
    minval = 1,
    maxval = 500,
    group = GROUP_ANCHOR,
    inline = "legfilter",
    display = display.none
)
float minimumLegAtrInput = input.float(
    1.0,
    "Minimum leg ATR",
    minval = 0.0,
    maxval = 100.0,
    step = 0.1,
    tooltip = "Filters newly alternating pivots whose price distance is smaller than this ATR multiple. A value of 0 disables the size filter.",
    group = GROUP_ANCHOR,
    inline = "legfilter",
    display = display.none
)
float sameSideRevisionTicksInput = input.float(
    1.0,
    "Same-side revision ticks",
    minval = 0.0,
    maxval = 1000.0,
    step = 0.25,
    tooltip = "A same-side pivot updates the active terminal only if it exceeds the previous terminal by at least this many minimum ticks. This reduces flicker from tiny revisions in live conditions.",
    group = GROUP_ANCHOR,
    display = display.none
)
int rollingLookbackInput = input.int(
    200,
    "Rolling range lookback",
    minval = 10,
    maxval = 3000,
    tooltip = "Used only when Anchor engine is Rolling range.",
    group = GROUP_ANCHOR,
    display = display.none
)
int historicalLocalWindowInput = input.int(
    120,
    "Automatic local window bars",
    minval = 20,
    maxval = 500,
    tooltip = "Controls the bounded local range used while Automatic swing is warming up and when studying a past chart. A larger value expands structural context; a smaller value keeps the calculation more local. Manual origin ignores this window.",
    group = GROUP_ANCHOR,
    display = display.none,
    active = anchorModeInput != "Manual origin"
)
bool level0EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l0", display = display.none)
float level0RatioInput = input.float(0.000, "Ratio 1", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l0", display = display.none)
bool level1EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l1", display = display.none)
float level1RatioInput = input.float(0.236, "Ratio 2", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l1", display = display.none)
bool level2EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l2", display = display.none)
float level2RatioInput = input.float(0.382, "Ratio 3", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l2", display = display.none)
bool level3EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l3", display = display.none)
float level3RatioInput = input.float(0.500, "Ratio 4", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l3", display = display.none)
bool level4EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l4", display = display.none)
float level4RatioInput = input.float(0.618, "Ratio 5", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l4", display = display.none)
bool level5EnabledInput = input.bool(false, "Show", group = GROUP_LEVELS, inline = "l5", display = display.none)
float level5RatioInput = input.float(0.650, "Ratio 6", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l5", display = display.none)
bool level6EnabledInput = input.bool(false, "Show", group = GROUP_LEVELS, inline = "l6", display = display.none)
float level6RatioInput = input.float(0.705, "Ratio 7", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l6", display = display.none)
bool level7EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l7", display = display.none)
float level7RatioInput = input.float(0.786, "Ratio 8", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l7", display = display.none)
bool level8EnabledInput = input.bool(false, "Show", group = GROUP_LEVELS, inline = "l8", display = display.none)
float level8RatioInput = input.float(0.886, "Ratio 9", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l8", display = display.none)
bool level9EnabledInput = input.bool(true, "Show", group = GROUP_LEVELS, inline = "l9", display = display.none)
float level9RatioInput = input.float(1.000, "Ratio 10", minval = -2.0, maxval = 3.0, step = 0.001, group = GROUP_LEVELS, inline = "l9", display = display.none)

bool reactionResearchInput = input.bool(
    true,
    "Track level-touch episodes",
    tooltip = "Counts a new touch only after price has first moved outside the re-arm distance. Statistics reset whenever the active anchors change.",
    group = GROUP_REACTION,
    display = display.none
)
string touchToleranceModeInput = input.string(
    "ATR",
    "Touch tolerance mode",
    options = ["ATR", "Leg percent", "Ticks"],
    group = GROUP_REACTION,
    display = display.none
)
float touchAtrInput = input.float(0.08, "ATR tolerance", minval = 0.0, maxval = 10.0, step = 0.01, group = GROUP_REACTION, inline = "tolerance", display = display.none)
float touchLegPercentInput = input.float(0.20, "Leg %", minval = 0.0, maxval = 20.0, step = 0.05, group = GROUP_REACTION, inline = "tolerance", display = display.none)
int touchTicksInput = input.int(4, "Ticks", minval = 1, maxval = 10000, group = GROUP_REACTION, inline = "tolerance", display = display.none)
float rearmMultiplierInput = input.float(
    1.75,
    "Re-arm distance multiplier",
    minval = 1.0,
    maxval = 20.0,
    step = 0.25,
    tooltip = "After a touch, price must move completely outside tolerance multiplied by this value before another touch can be counted.",
    group = GROUP_REACTION,
    display = display.none
)
int responseBarsInput = input.int(
    5,
    "Response measurement bars",
    minval = 1,
    maxval = 100,
    tooltip = "Measures price a fixed number of chart bars after each new touch. With confirmed-only events enabled, the measurement uses the closing value of the horizon bar. Positive values mean movement back toward the terminal anchor; negative values mean movement toward or beyond the origin anchor. This is descriptive, not predictive.",
    group = GROUP_REACTION,
    display = display.none
)
bool confirmedEventsOnlyInput = input.bool(
    true,
    "Evaluate events on confirmed bars only",
    group = GROUP_REACTION,
    display = display.none
)
bool showLatestTouchMarkersInput = input.bool(
    true,
    "Show latest touch marker per level",
    group = GROUP_REACTION,
    display = display.none
)

bool largerRangeOverlapInput = input.bool(
    true,
    "Highlight larger-range ratio overlap",
    tooltip = "Compares each active Fibonacci level with the same enabled ratios calculated from a longer rolling high/low range. A diamond identifies proximity within the selected tolerance; it does not imply that a level will hold.",
    group = GROUP_CONTEXT,
    display = display.none
)
int largerRangeLookbackInput = input.int(
    500,
    "Larger-range lookback",
    minval = 20,
    maxval = 3000,
    group = GROUP_CONTEXT,
    display = display.none
)
string overlapToleranceModeInput = input.string(
    "ATR",
    "Overlap tolerance mode",
    options = ["ATR", "Primary leg percent", "Ticks"],
    group = GROUP_CONTEXT,
    display = display.none
)
float overlapAtrInput = input.float(0.12, "ATR tolerance", minval = 0.0, maxval = 10.0, step = 0.01, group = GROUP_CONTEXT, inline = "overlap", display = display.none)
float overlapLegPercentInput = input.float(0.30, "Leg %", minval = 0.0, maxval = 20.0, step = 0.05, group = GROUP_CONTEXT, inline = "overlap", display = display.none)
int overlapTicksInput = input.int(6, "Ticks", minval = 1, maxval = 10000, group = GROUP_CONTEXT, inline = "overlap", display = display.none)

bool showSwingLineInput = input.bool(true, "Show anchor leg", group = GROUP_VISUAL, display = display.none)
bool showAnchorMarkersInput = input.bool(true, "Show origin and terminal markers", group = GROUP_VISUAL, display = display.none)
bool showLevelLabelsInput = input.bool(true, "Show level labels", group = GROUP_VISUAL, display = display.none)
bool showDepthBandsInput = input.bool(
    true,
    "Show depth bands",
    tooltip = "Uses the Ratio 3, 4, 5, and 8 input slots to form three configurable retracement-depth bands.",
    group = GROUP_VISUAL,
    display = display.none
)
bool extendRightInput = input.bool(true, "Extend levels right", group = GROUP_VISUAL, display = display.none)
string levelLineStyleInput = input.string("Solid", "Level line style", options = ["Solid", "Dashed", "Dotted"], group = GROUP_VISUAL, display = display.none)
int regularLineWidthInput = input.int(2, "Regular line width", minval = 1, maxval = 4, group = GROUP_VISUAL, inline = "width", display = display.none)
int keyLineWidthInput = input.int(4, "Ratio 4 / 5 width", minval = 1, maxval = 5, group = GROUP_VISUAL, inline = "width", display = display.none)
string labelContentInput = input.string(
    "Ratio + price",
    "Level label content",
    options = ["Ratio", "Price", "Ratio + price", "Research detail"],
    group = GROUP_VISUAL,
    display = display.none
)
int labelOffsetInput = input.int(2, "Label offset bars", minval = 0, maxval = 50, group = GROUP_VISUAL, display = display.none)
string labelSizeInput = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = GROUP_VISUAL, display = display.none)
int inactiveTransparencyInput = input.int(
    0,
    "Base line transparency",
    minval = 0,
    maxval = 80,
    group = GROUP_VISUAL,
    display = display.none
)
int shallowBandTransparencyInput = input.int(90, "Shallow band transparency", minval = 70, maxval = 100, group = GROUP_VISUAL, inline = "bands", display = display.none)
int coreBandTransparencyInput = input.int(82, "Core", minval = 70, maxval = 100, group = GROUP_VISUAL, inline = "bands", display = display.none)
int deepBandTransparencyInput = input.int(90, "Deep", minval = 70, maxval = 100, group = GROUP_VISUAL, inline = "bands", display = display.none)

color shallowColorInput = input.color(color.rgb(0, 214, 255), "Shallow color", group = GROUP_VISUAL, inline = "colors1", display = display.none)
color middleColorInput = input.color(color.rgb(146, 92, 255), "Middle", group = GROUP_VISUAL, inline = "colors1", display = display.none)
color deepColorInput = input.color(color.rgb(255, 56, 118), "Deep", group = GROUP_VISUAL, inline = "colors1", display = display.none)
color originColorInput = input.color(color.rgb(255, 196, 0), "Origin", group = GROUP_VISUAL, inline = "colors2", display = display.none)
color upwardColorInput = input.color(color.rgb(0, 255, 163), "Up leg", group = GROUP_VISUAL, inline = "colors2", display = display.none)
color downwardColorInput = input.color(color.rgb(255, 86, 86), "Down leg", group = GROUP_VISUAL, inline = "colors2", display = display.none)
color overlapColorInput = input.color(color.rgb(173, 255, 47), "Overlap", group = GROUP_VISUAL, inline = "colors3", display = display.none)
color depthCursorColorInput = input.color(color.rgb(255, 214, 0), "Depth cursor", group = GROUP_VISUAL, inline = "colors3", display = display.none)

bool showReadoutInput = input.bool(true, "Show context readout", group = GROUP_READOUT, display = display.none)
string readoutPositionInput = input.string("Top right", "Readout position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = GROUP_READOUT, display = display.none)
int readoutEdgeClearanceInput = input.int(
    6,
    "Readout edge clearance (%)",
    minval = 2,
    maxval = 20,
    tooltip = "Reserves transparent horizontal space between the readout and the chart edge. This prevents the fixed panel from covering TradingView High/Low labels and price-scale markers. Increase only when a narrow device or large chart labels need more room.",
    group = GROUP_READOUT,
    display = display.none
)
string readoutSizeInput = input.string("Normal", "Readout text size", options = ["Tiny", "Small", "Normal"], group = GROUP_READOUT, display = display.none)
bool showDepthCursorInput = input.bool(true, "Show current-depth cursor", group = GROUP_READOUT, display = display.none)
bool enableDynamicTouchAlertsInput = input.bool(
    false,
    "Enable dynamic touch alert() calls",
    tooltip = "When enabled, an alert created with 'Any alert() function call' receives the touched-ratio list and the current close. Confirmed-bar evaluation remains controlled by the event setting above.",
    group = GROUP_READOUT,
    display = display.none
)
//#endregion

//#region ———————————————————— Utility functions
f_lineStyle(string styleText) =>
    switch styleText
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_textSize(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_tablePosition(string positionText) =>
    switch positionText
        "Bottom right" => position.bottom_right
        "Top left" => position.top_left
        "Bottom left" => position.bottom_left
        => position.top_right

f_level(float originPrice, float terminalPrice, float ratio) =>
    terminalPrice + (originPrice - terminalPrice) * ratio

f_depth(float originPrice, float terminalPrice, float price) =>
    float denominator = originPrice - terminalPrice
    math.abs(denominator) > 0.0 ? (price - terminalPrice) / denominator : na

f_ratioText(float ratio) =>
    str.tostring(ratio * 100.0, "#.###") + "%"

f_priceText(float price) =>
    str.tostring(price, format.mintick)

f_levelColor(float ratio) =>
    color result = na
    if ratio <= 0.0
        result := shallowColorInput
    else if ratio >= 1.0
        result := originColorInput
    else if ratio <= 0.5
        result := color.from_gradient(ratio, 0.0, 0.5, shallowColorInput, middleColorInput)
    else
        result := color.from_gradient(ratio, 0.5, 1.0, middleColorInput, deepColorInput)
    result

f_depthState(float depthValue) =>
    string state = "n/a"
    if not na(depthValue)
        if depthValue < 0.0
            state := "Beyond terminal"
        else if depthValue < 0.382
            state := "Shallow"
        else if depthValue < 0.618
            state := "Middle"
        else if depthValue <= 1.0
            state := "Deep"
        else
            state := "Beyond origin"
    state

f_depthStateShort(float depthValue) =>
    string state = "n/a"
    if not na(depthValue)
        if depthValue < 0.0
            state := "T+"
        else if depthValue < 0.382
            state := "Shallow"
        else if depthValue < 0.618
            state := "Mid"
        else if depthValue <= 1.0
            state := "Deep"
        else
            state := "O+"
    state

f_signedText(float value) =>
    na(value) ? "n/a" : (value > 0.0 ? "+" : "") + str.tostring(value, "#.##") + "%"

f_tolerance(string modeText, float atrValue, float legSize, float atrFactor, float legPercent, int tickCount, float minimumTick) =>
    float rawTolerance = switch modeText
        "Leg percent" => legSize * legPercent * 0.01
        "Primary leg percent" => legSize * legPercent * 0.01
        "Ticks" => minimumTick * tickCount
        => atrValue * atrFactor
    math.max(minimumTick, nz(rawTolerance, minimumTick))
//#endregion

//#region ———————————————————— Core series and configurable level arrays
float minimumTick = math.max(syminfo.mintick, 0.0000000001)
float atrValue = ta.atr(atrLengthInput)
float atrSafe = math.max(nz(atrValue, ta.tr(true)), minimumTick)
float upperSource = swingSourceInput == "Wicks" ? high : close
float lowerSource = swingSourceInput == "Wicks" ? low : close
bool replayMode = str.contains(syminfo.tickerid, "replay")
bool automaticSwingMode = anchorModeInput == "Automatic swing"
bool userOriginMode = anchorModeInput == "Manual origin"
bool historicalViewportMode = followVisibleRangeInput and not replayMode and chart.right_visible_bar_time < last_bar_time
bool automaticHistoricalMode = historicalViewportMode and not userOriginMode
bool confirmedMode = not historicalViewportMode and automaticSwingMode
bool rollingMode = not historicalViewportMode and anchorModeInput == "Rolling range"

var array<float> ratios = array.new<float>(LEVEL_COUNT, na)
var array<bool> levelEnabled = array.new<bool>(LEVEL_COUNT, false)

array.set(ratios, 0, level0RatioInput)
array.set(ratios, 1, level1RatioInput)
array.set(ratios, 2, level2RatioInput)
array.set(ratios, 3, level3RatioInput)
array.set(ratios, 4, level4RatioInput)
array.set(ratios, 5, level5RatioInput)
array.set(ratios, 6, level6RatioInput)
array.set(ratios, 7, level7RatioInput)
array.set(ratios, 8, level8RatioInput)
array.set(ratios, 9, level9RatioInput)

array.set(levelEnabled, 0, level0EnabledInput)
array.set(levelEnabled, 1, level1EnabledInput)
array.set(levelEnabled, 2, level2EnabledInput)
array.set(levelEnabled, 3, level3EnabledInput)
array.set(levelEnabled, 4, level4EnabledInput)
array.set(levelEnabled, 5, level5EnabledInput)
array.set(levelEnabled, 6, level6EnabledInput)
array.set(levelEnabled, 7, level7EnabledInput)
array.set(levelEnabled, 8, level8EnabledInput)
array.set(levelEnabled, 9, level9EnabledInput)
//#endregion

//#region ———————————————————— Confirmed alternating swing engines
// Global engine: authoritative at the live edge and for alerts/reaction research.
var int swingPreviousType = 0
var float swingPreviousPrice = na
var int swingPreviousTime = na
var int swingPreviousIndex = na

var int swingLastType = 0
var float swingLastPrice = na
var int swingLastTime = na
var int swingLastIndex = na

// Historical local engine: rebuilt only from pivots that occur and become confirmed inside the visible past window.
var int viewSwingPreviousType = 0
var float viewSwingPreviousPrice = na
var int viewSwingPreviousTime = na
var int viewSwingPreviousIndex = na

var int viewSwingLastType = 0
var float viewSwingLastPrice = na
var int viewSwingLastTime = na
var int viewSwingLastIndex = na

float confirmedPivotHigh = ta.pivothigh(upperSource, pivotLeftInput, pivotRightInput)
float confirmedPivotLow = ta.pivotlow(lowerSource, pivotLeftInput, pivotRightInput)
bool hasPivotHigh = barstate.isconfirmed and not na(confirmedPivotHigh)
bool hasPivotLow = barstate.isconfirmed and not na(confirmedPivotLow)
bool hasAnyPivot = hasPivotHigh or hasPivotLow

int candidateTime = hasAnyPivot ? time[pivotRightInput] : na
int candidateIndex = hasAnyPivot ? bar_index - pivotRightInput : na
float candidateAtr = hasAnyPivot ? nz(atrValue[pivotRightInput], atrSafe) : na

// Resolve the candidate independently for each engine when both pivot types are confirmed from one bar.
int candidateType = 0
float candidatePrice = na
if hasPivotHigh and not hasPivotLow
    candidateType := 1
    candidatePrice := confirmedPivotHigh
else if hasPivotLow and not hasPivotHigh
    candidateType := -1
    candidatePrice := confirmedPivotLow
else if hasPivotHigh and hasPivotLow
    // Final OHLC cannot establish the intrabar order of both extremes.
    // Prefer the opposite type only when an existing terminal type supplies an unambiguous alternating context.
    if swingLastType == 1
        candidateType := -1
        candidatePrice := confirmedPivotLow
    else if swingLastType == -1
        candidateType := 1
        candidatePrice := confirmedPivotHigh

int viewCandidateType = 0
float viewCandidatePrice = na
if hasPivotHigh and not hasPivotLow
    viewCandidateType := 1
    viewCandidatePrice := confirmedPivotHigh
else if hasPivotLow and not hasPivotHigh
    viewCandidateType := -1
    viewCandidatePrice := confirmedPivotLow
else if hasPivotHigh and hasPivotLow
    if viewSwingLastType == 1
        viewCandidateType := -1
        viewCandidatePrice := confirmedPivotLow
    else if viewSwingLastType == -1
        viewCandidateType := 1
        viewCandidatePrice := confirmedPivotHigh

bool newAlternatingSwing = false
bool sameSideSwingRevision = false

// Process the global, live-first engine.
if candidateType != 0 and not na(candidatePrice)
    if swingLastType == 0
        swingLastType := candidateType
        swingLastPrice := candidatePrice
        swingLastTime := candidateTime
        swingLastIndex := candidateIndex
    else if candidateType == swingLastType
        float revisionThreshold = minimumTick * sameSideRevisionTicksInput
        bool moreExtreme = candidateType == 1 ? candidatePrice > swingLastPrice + revisionThreshold : candidatePrice < swingLastPrice - revisionThreshold
        if moreExtreme
            swingLastPrice := candidatePrice
            swingLastTime := candidateTime
            swingLastIndex := candidateIndex
            sameSideSwingRevision := swingPreviousType != 0
    else
        int pivotSpacing = candidateIndex - swingLastIndex
        float candidateLegSize = math.abs(candidatePrice - swingLastPrice)
        bool spacingAccepted = pivotSpacing >= minimumPivotSpacingInput
        bool nonZeroLeg = candidateLegSize >= minimumTick
        bool sizeAccepted = nonZeroLeg and (minimumLegAtrInput <= 0.0 or candidateLegSize >= math.max(candidateAtr, minimumTick) * minimumLegAtrInput)
        if spacingAccepted and sizeAccepted
            swingPreviousType := swingLastType
            swingPreviousPrice := swingLastPrice
            swingPreviousTime := swingLastTime
            swingPreviousIndex := swingLastIndex
            swingLastType := candidateType
            swingLastPrice := candidatePrice
            swingLastTime := candidateTime
            swingLastIndex := candidateIndex
            newAlternatingSwing := true

// Process a separate confirmed swing sequence for the currently visible historical chart.
bool viewCandidateEligible = automaticHistoricalMode and viewCandidateType != 0 and not na(viewCandidatePrice) and not na(candidateTime) and candidateTime >= chart.left_visible_bar_time and candidateTime <= chart.right_visible_bar_time and time <= chart.right_visible_bar_time
if viewCandidateEligible
    if viewSwingLastType == 0
        viewSwingLastType := viewCandidateType
        viewSwingLastPrice := viewCandidatePrice
        viewSwingLastTime := candidateTime
        viewSwingLastIndex := candidateIndex
    else if viewCandidateType == viewSwingLastType
        float viewRevisionThreshold = minimumTick * sameSideRevisionTicksInput
        bool viewMoreExtreme = viewCandidateType == 1 ? viewCandidatePrice > viewSwingLastPrice + viewRevisionThreshold : viewCandidatePrice < viewSwingLastPrice - viewRevisionThreshold
        if viewMoreExtreme
            viewSwingLastPrice := viewCandidatePrice
            viewSwingLastTime := candidateTime
            viewSwingLastIndex := candidateIndex
    else
        int viewPivotSpacing = candidateIndex - viewSwingLastIndex
        float viewCandidateLegSize = math.abs(viewCandidatePrice - viewSwingLastPrice)
        bool viewSpacingAccepted = viewPivotSpacing >= minimumPivotSpacingInput
        bool viewNonZeroLeg = viewCandidateLegSize >= minimumTick
        bool viewSizeAccepted = viewNonZeroLeg and (minimumLegAtrInput <= 0.0 or viewCandidateLegSize >= math.max(candidateAtr, minimumTick) * minimumLegAtrInput)
        if viewSpacingAccepted and viewSizeAccepted
            viewSwingPreviousType := viewSwingLastType
            viewSwingPreviousPrice := viewSwingLastPrice
            viewSwingPreviousTime := viewSwingLastTime
            viewSwingPreviousIndex := viewSwingLastIndex
            viewSwingLastType := viewCandidateType
            viewSwingLastPrice := viewCandidatePrice
            viewSwingLastTime := candidateTime
            viewSwingLastIndex := candidateIndex
//#endregion

//#region ———————————————————— Rolling and visible chart engines
float rollingHigh = ta.highest(upperSource, rollingLookbackInput)
float rollingLow = ta.lowest(lowerSource, rollingLookbackInput)
int rollingHighOffset = ta.highestbars(upperSource, rollingLookbackInput)
int rollingLowOffset = ta.lowestbars(lowerSource, rollingLookbackInput)
int rollingHighBack = na(rollingHighOffset) ? 0 : math.abs(rollingHighOffset)
int rollingLowBack = na(rollingLowOffset) ? 0 : math.abs(rollingLowOffset)
int rollingHighTime = not na(rollingHigh) ? time[rollingHighBack] : na
int rollingLowTime = not na(rollingLow) ? time[rollingLowBack] : na
int rollingHighIndex = not na(rollingHigh) ? bar_index - rollingHighBack : na
int rollingLowIndex = not na(rollingLow) ? bar_index - rollingLowBack : na

// Bounded local range used for automatic warm-up and as a historical fallback when no suitable confirmed pair is available.
float localTailHighSeries = ta.highest(upperSource, historicalLocalWindowInput)
float localTailLowSeries = ta.lowest(lowerSource, historicalLocalWindowInput)
int localTailHighOffset = ta.highestbars(upperSource, historicalLocalWindowInput)
int localTailLowOffset = ta.lowestbars(lowerSource, historicalLocalWindowInput)
int localTailHighBack = na(localTailHighOffset) ? 0 : math.abs(localTailHighOffset)
int localTailLowBack = na(localTailLowOffset) ? 0 : math.abs(localTailLowOffset)
int localTailHighTimeSeries = not na(localTailHighSeries) ? time[localTailHighBack] : na
int localTailLowTimeSeries = not na(localTailLowSeries) ? time[localTailLowBack] : na
int localTailHighIndexSeries = not na(localTailHighSeries) ? bar_index - localTailHighBack : na
int localTailLowIndexSeries = not na(localTailLowSeries) ? bar_index - localTailLowBack : na

var float visibleHigh = na
var float visibleLow = na
var int visibleHighTime = na
var int visibleLowTime = na
var int visibleHighIndex = na
var int visibleLowIndex = na
var int visibleLeftTime = na
var int visibleRightTime = na
var int visibleRightIndex = na
var int visibleRightStepMs = na
var float visibleRightClose = na
var float visibleRightAtr = na
var int visibleBarCount = 0

var float visibleTailHigh = na
var float visibleTailLow = na
var int visibleTailHighTime = na
var int visibleTailLowTime = na
var int visibleTailHighIndex = na
var int visibleTailLowIndex = na

if barstate.isfirst
    visibleHigh := na
    visibleLow := na
    visibleHighTime := na
    visibleLowTime := na
    visibleHighIndex := na
    visibleLowIndex := na
    visibleLeftTime := na
    visibleRightTime := na
    visibleRightIndex := na
    visibleRightStepMs := na
    visibleRightClose := na
    visibleRightAtr := na
    visibleBarCount := 0
    visibleTailHigh := na
    visibleTailLow := na
    visibleTailHighTime := na
    visibleTailLowTime := na
    visibleTailHighIndex := na
    visibleTailLowIndex := na

bool insideVisibleRange = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
bool eligiblePastFallbackBar = insideVisibleRange

if insideVisibleRange
    visibleBarCount += 1
    if na(visibleLeftTime)
        visibleLeftTime := time

    if eligiblePastFallbackBar
        if na(visibleHigh) or upperSource > visibleHigh
            visibleHigh := upperSource
            visibleHighTime := time
            visibleHighIndex := bar_index
        if na(visibleLow) or lowerSource < visibleLow
            visibleLow := lowerSource
            visibleLowTime := time
            visibleLowIndex := bar_index

    if time == chart.right_visible_bar_time
        visibleRightTime := time
        visibleRightIndex := bar_index
        visibleRightStepMs := bar_index > 0 ? math.max(1, time - time[1]) : 1
        visibleRightClose := close
        visibleRightAtr := atrSafe

        visibleTailHigh := localTailHighSeries
        visibleTailLow := localTailLowSeries
        visibleTailHighTime := localTailHighTimeSeries
        visibleTailLowTime := localTailLowTimeSeries
        visibleTailHighIndex := localTailHighIndexSeries
        visibleTailLowIndex := localTailLowIndexSeries
//#endregion

//#region ———————————————————— User-selected origin engine
// The paired time/price input defines one interactive chart point. Input changes restart the script on the full dataset.
// This engine also resets its own cached origin and terminal candidates on the first bar, preventing stale automatic anchors
// from surviving after the point, direction, price handling, symbol, timeframe, or viewport endpoint changes.
var float userOriginBarLow = na
var float userOriginBarHigh = na
var float userOriginBarClose = na
var int userResolvedOriginTime = na
var int userResolvedOriginIndex = na
var int userPreferredDirection = 0

var float userUpTerminalPrice = na
var int userUpTerminalTime = na
var int userUpTerminalIndex = na
var float userDownTerminalPrice = na
var int userDownTerminalTime = na
var int userDownTerminalIndex = na

if barstate.isfirst
    userOriginBarLow := na
    userOriginBarHigh := na
    userOriginBarClose := na
    userResolvedOriginTime := na
    userResolvedOriginIndex := na
    userPreferredDirection := 0
    userUpTerminalPrice := na
    userUpTerminalTime := na
    userUpTerminalIndex := na
    userDownTerminalPrice := na
    userDownTerminalTime := na
    userDownTerminalIndex := na

bool userPointConfigured = userOriginMode and userOriginTimeInput > 0

// Keep replacing the candidate until the selected timestamp is reached. The final assignment is the closest chart bar
// whose opening time does not exceed the selected point time, so the point remains usable after timeframe changes.
if userPointConfigured and time <= userOriginTimeInput
    userOriginBarLow := low
    userOriginBarHigh := high
    userOriginBarClose := close
    userResolvedOriginTime := time
    userResolvedOriginIndex := bar_index
    userPreferredDirection := math.abs(userOriginPriceInput - low) <= math.abs(userOriginPriceInput - high) ? 1 : -1

    // A later origin candidate supersedes every terminal accumulated from an earlier candidate.
    userUpTerminalPrice := na
    userUpTerminalTime := na
    userUpTerminalIndex := na
    userDownTerminalPrice := na
    userDownTerminalTime := na
    userDownTerminalIndex := na

bool userOriginResolved = userPointConfigured and not na(userResolvedOriginTime) and not na(userResolvedOriginIndex) and not na(userOriginBarLow) and not na(userOriginBarHigh) and not na(userOriginBarClose)
float userUpOriginPrice = userOriginResolved ? (userOriginPriceModeInput == "Use selected price" ? userOriginPriceInput : swingSourceInput == "Closes" ? userOriginBarClose : userOriginBarLow) : na
float userDownOriginPrice = userOriginResolved ? (userOriginPriceModeInput == "Use selected price" ? userOriginPriceInput : swingSourceInput == "Closes" ? userOriginBarClose : userOriginBarHigh) : na

int userCalculationEndpointTime = historicalViewportMode ? chart.right_visible_bar_time : last_bar_time
bool userOriginBeforeEndpoint = userOriginResolved and userResolvedOriginTime < userCalculationEndpointTime
bool userBarAfterOrigin = userOriginBeforeEndpoint and bar_index > userResolvedOriginIndex
bool userBarBeforeEndpoint = userOriginBeforeEndpoint and time <= userCalculationEndpointTime
bool userBarInsideLimit = userOriginBeforeEndpoint and (userTerminalSearchLimitInput == 0 or bar_index - userResolvedOriginIndex <= userTerminalSearchLimitInput)
bool userTerminalBarAccepted = historicalViewportMode or not userTerminalClosedBarsInput or barstate.isconfirmed

// Track both possible directions. Auto mode can therefore recover when point proximity suggests a direction that has no
// valid later terminal, while explicit Up leg / Down leg selections remain strict.
if userBarAfterOrigin and userBarBeforeEndpoint and userBarInsideLimit and userTerminalBarAccepted
    float upCandidate = upperSource
    bool validUpCandidate = upCandidate > userUpOriginPrice + minimumTick
    bool moreExtremeUp = na(userUpTerminalPrice) or upCandidate > userUpTerminalPrice
    if validUpCandidate and moreExtremeUp
        userUpTerminalPrice := upCandidate
        userUpTerminalTime := time
        userUpTerminalIndex := bar_index

    float downCandidate = lowerSource
    bool validDownCandidate = downCandidate < userDownOriginPrice - minimumTick
    bool moreExtremeDown = na(userDownTerminalPrice) or downCandidate < userDownTerminalPrice
    if validDownCandidate and moreExtremeDown
        userDownTerminalPrice := downCandidate
        userDownTerminalTime := time
        userDownTerminalIndex := bar_index

bool userUpPairValid = userOriginBeforeEndpoint and not na(userUpTerminalPrice) and not na(userUpTerminalTime) and not na(userUpTerminalIndex) and userUpTerminalIndex > userResolvedOriginIndex and userUpTerminalPrice > userUpOriginPrice + minimumTick
bool userDownPairValid = userOriginBeforeEndpoint and not na(userDownTerminalPrice) and not na(userDownTerminalTime) and not na(userDownTerminalIndex) and userDownTerminalIndex > userResolvedOriginIndex and userDownTerminalPrice < userDownOriginPrice - minimumTick

int userAutoDirection = 0
if userPreferredDirection == 1
    userAutoDirection := userUpPairValid ? 1 : userDownPairValid ? -1 : 0
else if userPreferredDirection == -1
    userAutoDirection := userDownPairValid ? -1 : userUpPairValid ? 1 : 0
else if userUpPairValid or userDownPairValid
    float upExcursion = userUpPairValid ? userUpTerminalPrice - userUpOriginPrice : -1.0
    float downExcursion = userDownPairValid ? userDownOriginPrice - userDownTerminalPrice : -1.0
    userAutoDirection := upExcursion >= downExcursion ? 1 : -1

int userResolvedDirection = userOriginDirectionInput == "Up leg" ? (userUpPairValid ? 1 : 0) : userOriginDirectionInput == "Down leg" ? (userDownPairValid ? -1 : 0) : userAutoDirection
float userResolvedOriginPrice = userResolvedDirection == 1 ? userUpOriginPrice : userResolvedDirection == -1 ? userDownOriginPrice : na
float userAutoTerminalPrice = userResolvedDirection == 1 ? userUpTerminalPrice : userResolvedDirection == -1 ? userDownTerminalPrice : na
int userAutoTerminalTime = userResolvedDirection == 1 ? userUpTerminalTime : userResolvedDirection == -1 ? userDownTerminalTime : na
int userAutoTerminalIndex = userResolvedDirection == 1 ? userUpTerminalIndex : userResolvedDirection == -1 ? userDownTerminalIndex : na
bool userPairValid = userOriginResolved and userOriginBeforeEndpoint and userResolvedDirection != 0 and not na(userResolvedOriginPrice) and not na(userAutoTerminalPrice) and not na(userAutoTerminalTime) and not na(userAutoTerminalIndex) and userAutoTerminalIndex > userResolvedOriginIndex
//#endregion

//#region ———————————————————— Active anchor selection
float activeOriginPrice = na
float activeTerminalPrice = na
int activeOriginTime = na
int activeTerminalTime = na
int activeOriginIndex = na
int activeTerminalIndex = na
int activeDirection = 0
bool activeAnchorValid = false

// Automatic candidates are prepared for the default automatic engine and the explicit rolling-range engine.
float automaticOriginPrice = na
float automaticTerminalPrice = na
int automaticOriginTime = na
int automaticTerminalTime = na
int automaticOriginIndex = na
int automaticTerminalIndex = na
int automaticDirection = 0
bool automaticAnchorValid = false
bool automaticUsesConfirmedSwing = false
bool automaticUsesLiveRangeFallback = false
bool automaticUsesRollingRange = false
bool automaticUsesHistoricalSwing = false
bool automaticUsesHistoricalRange = false

int historicalStudyBars = automaticHistoricalMode ? math.min(visibleBarCount, historicalLocalWindowInput) : na
int historicalWindowStartIndex = automaticHistoricalMode and not na(visibleRightIndex) ? visibleRightIndex - historicalLocalWindowInput + 1 : na
int historicalTerminalAgeLimit = math.max(8, int(math.floor(historicalLocalWindowInput * 0.50)))
int userStudyEndpointIndex = historicalViewportMode and not na(visibleRightIndex) ? visibleRightIndex : last_bar_index
int userStudyBars = userOriginResolved and not na(userStudyEndpointIndex) ? math.max(0, userStudyEndpointIndex - userResolvedOriginIndex) : na

if automaticHistoricalMode
    bool viewPairValid = viewSwingPreviousType != 0 and viewSwingLastType != 0 and viewSwingPreviousType != viewSwingLastType and not na(viewSwingPreviousPrice) and not na(viewSwingLastPrice) and not na(viewSwingPreviousTime) and not na(viewSwingLastTime) and not na(viewSwingPreviousIndex) and not na(viewSwingLastIndex) and math.abs(viewSwingLastPrice - viewSwingPreviousPrice) >= minimumTick
    int viewPairSpan = viewPairValid ? math.abs(viewSwingLastIndex - viewSwingPreviousIndex) : 0
    int viewTerminalAge = viewPairValid and not na(visibleRightIndex) ? visibleRightIndex - viewSwingLastIndex : 1000000
    bool viewPairFitsLocalWindow = viewPairValid and not na(historicalWindowStartIndex) and viewSwingPreviousIndex >= historicalWindowStartIndex and viewPairSpan <= historicalLocalWindowInput and viewTerminalAge >= 0 and viewTerminalAge <= historicalTerminalAgeLimit

    if viewPairFitsLocalWindow
        automaticAnchorValid := true
        automaticUsesHistoricalSwing := true
        automaticOriginPrice := viewSwingPreviousPrice
        automaticTerminalPrice := viewSwingLastPrice
        automaticOriginTime := viewSwingPreviousTime
        automaticTerminalTime := viewSwingLastTime
        automaticOriginIndex := viewSwingPreviousIndex
        automaticTerminalIndex := viewSwingLastIndex
        automaticDirection := automaticTerminalPrice > automaticOriginPrice ? 1 : -1
    else
        bool useTailFallback = visibleBarCount > historicalLocalWindowInput
        float fallbackHigh = useTailFallback ? visibleTailHigh : visibleHigh
        float fallbackLow = useTailFallback ? visibleTailLow : visibleLow
        int fallbackHighTime = useTailFallback ? visibleTailHighTime : visibleHighTime
        int fallbackLowTime = useTailFallback ? visibleTailLowTime : visibleLowTime
        int fallbackHighIndex = useTailFallback ? visibleTailHighIndex : visibleHighIndex
        int fallbackLowIndex = useTailFallback ? visibleTailLowIndex : visibleLowIndex
        bool fallbackValid = not na(fallbackHigh) and not na(fallbackLow) and not na(fallbackHighTime) and not na(fallbackLowTime) and not na(fallbackHighIndex) and not na(fallbackLowIndex) and fallbackHigh > fallbackLow and fallbackHighTime != fallbackLowTime and math.abs(fallbackHighIndex - fallbackLowIndex) >= 1

        automaticAnchorValid := fallbackValid
        automaticUsesHistoricalRange := fallbackValid
        if automaticAnchorValid
            if fallbackLowTime < fallbackHighTime
                automaticOriginPrice := fallbackLow
                automaticTerminalPrice := fallbackHigh
                automaticOriginTime := fallbackLowTime
                automaticTerminalTime := fallbackHighTime
                automaticOriginIndex := fallbackLowIndex
                automaticTerminalIndex := fallbackHighIndex
                automaticDirection := 1
            else
                automaticOriginPrice := fallbackHigh
                automaticTerminalPrice := fallbackLow
                automaticOriginTime := fallbackHighTime
                automaticTerminalTime := fallbackLowTime
                automaticOriginIndex := fallbackHighIndex
                automaticTerminalIndex := fallbackLowIndex
                automaticDirection := -1
else if confirmedMode
    bool confirmedPairValid = swingPreviousType != 0 and swingLastType != 0 and swingPreviousType != swingLastType and not na(swingPreviousPrice) and not na(swingLastPrice) and math.abs(swingLastPrice - swingPreviousPrice) >= minimumTick
    if confirmedPairValid
        automaticAnchorValid := true
        automaticUsesConfirmedSwing := true
        automaticOriginPrice := swingPreviousPrice
        automaticTerminalPrice := swingLastPrice
        automaticOriginTime := swingPreviousTime
        automaticTerminalTime := swingLastTime
        automaticOriginIndex := swingPreviousIndex
        automaticTerminalIndex := swingLastIndex
        automaticDirection := automaticTerminalPrice > automaticOriginPrice ? 1 : -1
    else
        // During warm-up, use only finalized local extremes. This avoids a blank chart without allowing the live bar
        // to move the entire Fibonacci structure tick by tick.
        float liveFallbackHigh = barstate.isconfirmed ? localTailHighSeries : localTailHighSeries[1]
        float liveFallbackLow = barstate.isconfirmed ? localTailLowSeries : localTailLowSeries[1]
        int liveFallbackHighTime = barstate.isconfirmed ? localTailHighTimeSeries : localTailHighTimeSeries[1]
        int liveFallbackLowTime = barstate.isconfirmed ? localTailLowTimeSeries : localTailLowTimeSeries[1]
        int liveFallbackHighIndex = barstate.isconfirmed ? localTailHighIndexSeries : localTailHighIndexSeries[1]
        int liveFallbackLowIndex = barstate.isconfirmed ? localTailLowIndexSeries : localTailLowIndexSeries[1]
        bool liveFallbackValid = not na(liveFallbackHigh) and not na(liveFallbackLow) and not na(liveFallbackHighTime) and not na(liveFallbackLowTime) and not na(liveFallbackHighIndex) and not na(liveFallbackLowIndex) and liveFallbackHigh > liveFallbackLow and liveFallbackHighTime != liveFallbackLowTime and math.abs(liveFallbackHighIndex - liveFallbackLowIndex) >= 1

        automaticAnchorValid := liveFallbackValid
        automaticUsesLiveRangeFallback := liveFallbackValid
        if automaticAnchorValid
            if liveFallbackLowTime < liveFallbackHighTime
                automaticOriginPrice := liveFallbackLow
                automaticTerminalPrice := liveFallbackHigh
                automaticOriginTime := liveFallbackLowTime
                automaticTerminalTime := liveFallbackHighTime
                automaticOriginIndex := liveFallbackLowIndex
                automaticTerminalIndex := liveFallbackHighIndex
                automaticDirection := 1
            else
                automaticOriginPrice := liveFallbackHigh
                automaticTerminalPrice := liveFallbackLow
                automaticOriginTime := liveFallbackHighTime
                automaticTerminalTime := liveFallbackLowTime
                automaticOriginIndex := liveFallbackHighIndex
                automaticTerminalIndex := liveFallbackLowIndex
                automaticDirection := -1
else if rollingMode
    bool rollingTimesValid = not na(rollingHigh) and not na(rollingLow) and rollingHigh > rollingLow and rollingHighTime != rollingLowTime
    int rollingSpanBars = rollingTimesValid ? math.abs(rollingHighIndex - rollingLowIndex) : 0
    automaticAnchorValid := rollingTimesValid and rollingSpanBars >= minimumRangeSpanInput
    automaticUsesRollingRange := automaticAnchorValid
    if automaticAnchorValid
        if rollingLowTime < rollingHighTime
            automaticOriginPrice := rollingLow
            automaticTerminalPrice := rollingHigh
            automaticOriginTime := rollingLowTime
            automaticTerminalTime := rollingHighTime
            automaticOriginIndex := rollingLowIndex
            automaticTerminalIndex := rollingHighIndex
            automaticDirection := 1
        else
            automaticOriginPrice := rollingHigh
            automaticTerminalPrice := rollingLow
            automaticOriginTime := rollingHighTime
            automaticTerminalTime := rollingLowTime
            automaticOriginIndex := rollingHighIndex
            automaticTerminalIndex := rollingLowIndex
            automaticDirection := -1

bool activeUsesUserOrigin = false
bool activeUsesConfirmedSwing = false
bool activeUsesAutoRangeFallback = false
bool activeUsesRollingRange = false
bool historicalUsesUserOrigin = false
bool historicalUsesConfirmedSwing = false
bool historicalUsesRangeFallback = false

if userOriginMode
    // Explicit Manual origin mode: no point, invalid direction, or missing terminal means no manual Fibonacci structure.
    if userPairValid
        activeAnchorValid := true
        activeUsesUserOrigin := true
        historicalUsesUserOrigin := historicalViewportMode
        activeOriginPrice := userResolvedOriginPrice
        activeTerminalPrice := userAutoTerminalPrice
        activeOriginTime := userResolvedOriginTime
        activeTerminalTime := userAutoTerminalTime
        activeOriginIndex := userResolvedOriginIndex
        activeTerminalIndex := userAutoTerminalIndex
        activeDirection := userResolvedDirection
else if automaticAnchorValid
    activeAnchorValid := true
    activeUsesConfirmedSwing := automaticUsesConfirmedSwing
    activeUsesAutoRangeFallback := automaticUsesLiveRangeFallback
    activeUsesRollingRange := automaticUsesRollingRange
    historicalUsesConfirmedSwing := automaticUsesHistoricalSwing
    historicalUsesRangeFallback := automaticUsesHistoricalRange
    activeOriginPrice := automaticOriginPrice
    activeTerminalPrice := automaticTerminalPrice
    activeOriginTime := automaticOriginTime
    activeTerminalTime := automaticTerminalTime
    activeOriginIndex := automaticOriginIndex
    activeTerminalIndex := automaticTerminalIndex
    activeDirection := automaticDirection

float activeAtrReference = historicalViewportMode and not na(visibleRightAtr) ? visibleRightAtr : atrSafe
float activeLegSize = activeAnchorValid ? math.abs(activeTerminalPrice - activeOriginPrice) : na
float activeLegAtr = activeAnchorValid ? activeLegSize / math.max(activeAtrReference, minimumTick) : na
int activeLegBars = activeAnchorValid ? math.abs(activeTerminalIndex - activeOriginIndex) : na

var bool previousAnchorValid = false
var float previousOriginPrice = na
var float previousTerminalPrice = na
var int previousOriginTime = na
var int previousTerminalTime = na

bool anchorTimeChanged = activeAnchorValid and (not previousAnchorValid or activeOriginTime != previousOriginTime or activeTerminalTime != previousTerminalTime)
bool anchorPriceChanged = activeAnchorValid and (not previousAnchorValid or math.abs(activeOriginPrice - previousOriginPrice) >= minimumTick * 0.5 or math.abs(activeTerminalPrice - previousTerminalPrice) >= minimumTick * 0.5)
bool activeAnchorChanged = activeAnchorValid and (anchorTimeChanged or anchorPriceChanged)
bool activeAnchorRemoved = not activeAnchorValid and previousAnchorValid
//#endregion

//#region ———————————————————— Larger-range Fibonacci overlap
float largerHigh = ta.highest(upperSource, largerRangeLookbackInput)
float largerLow = ta.lowest(lowerSource, largerRangeLookbackInput)
int largerHighOffset = ta.highestbars(upperSource, largerRangeLookbackInput)
int largerLowOffset = ta.lowestbars(lowerSource, largerRangeLookbackInput)
int largerHighBack = na(largerHighOffset) ? 0 : math.abs(largerHighOffset)
int largerLowBack = na(largerLowOffset) ? 0 : math.abs(largerLowOffset)
int largerHighTime = not na(largerHigh) ? time[largerHighBack] : na
int largerLowTime = not na(largerLow) ? time[largerLowBack] : na

var float visibleContextHigh = na
var float visibleContextLow = na
var int visibleContextHighTime = na
var int visibleContextLowTime = na

if barstate.isfirst
    visibleContextHigh := na
    visibleContextLow := na
    visibleContextHighTime := na
    visibleContextLowTime := na

if time == chart.right_visible_bar_time
    visibleContextHigh := largerHigh
    visibleContextLow := largerLow
    visibleContextHighTime := largerHighTime
    visibleContextLowTime := largerLowTime

float selectedLargerHigh = historicalViewportMode ? visibleContextHigh : largerHigh
float selectedLargerLow = historicalViewportMode ? visibleContextLow : largerLow
int selectedLargerHighTime = historicalViewportMode ? visibleContextHighTime : largerHighTime
int selectedLargerLowTime = historicalViewportMode ? visibleContextLowTime : largerLowTime

float largerOriginPrice = na
float largerTerminalPrice = na
int largerOriginTime = na
int largerTerminalTime = na
bool largerRangeValid = largerRangeOverlapInput and not na(selectedLargerHigh) and not na(selectedLargerLow) and selectedLargerHigh > selectedLargerLow and selectedLargerHighTime != selectedLargerLowTime

if largerRangeValid
    if selectedLargerLowTime < selectedLargerHighTime
        largerOriginPrice := selectedLargerLow
        largerTerminalPrice := selectedLargerHigh
        largerOriginTime := selectedLargerLowTime
        largerTerminalTime := selectedLargerHighTime
    else
        largerOriginPrice := selectedLargerHigh
        largerTerminalPrice := selectedLargerLow
        largerOriginTime := selectedLargerHighTime
        largerTerminalTime := selectedLargerLowTime

bool largerRangeDistinct = largerRangeValid and activeAnchorValid and (
    largerOriginTime != activeOriginTime or
    largerTerminalTime != activeTerminalTime or
    math.abs(largerOriginPrice - activeOriginPrice) >= minimumTick * 0.5 or
    math.abs(largerTerminalPrice - activeTerminalPrice) >= minimumTick * 0.5
)

float overlapTolerance = activeAnchorValid ? f_tolerance(
    overlapToleranceModeInput,
    activeAtrReference,
    activeLegSize,
    overlapAtrInput,
    overlapLegPercentInput,
    overlapTicksInput,
    minimumTick
) : na

var array<bool> overlapFlags = array.new<bool>(LEVEL_COUNT, false)
for i = 0 to LEVEL_COUNT - 1
    bool overlapFound = false
    if activeAnchorValid and largerRangeDistinct and array.get(levelEnabled, i)
        float primaryLevel = f_level(activeOriginPrice, activeTerminalPrice, array.get(ratios, i))
        for j = 0 to LEVEL_COUNT - 1
            if array.get(levelEnabled, j)
                float contextLevel = f_level(largerOriginPrice, largerTerminalPrice, array.get(ratios, j))
                if math.abs(primaryLevel - contextLevel) <= overlapTolerance
                    overlapFound := true
    array.set(overlapFlags, i, overlapFound)
//#endregion

//#region ———————————————————— Touch episodes and fixed-horizon responses
var array<int> touchCounts = array.new<int>(LEVEL_COUNT, 0)
var array<bool> touchArmed = array.new<bool>(LEVEL_COUNT, true)
var array<int> pendingResponseLevels = array.new<int>()
var array<int> pendingResponseStartBars = array.new<int>()
var array<float> responseSums = array.new<float>(LEVEL_COUNT, 0.0)
var array<int> responseCounts = array.new<int>(LEVEL_COUNT, 0)
var array<label> latestTouchLabels = array.new<label>(LEVEL_COUNT, na)
var int anchorKnownBar = na
var int anchorKnownTime = na
var float maximumObservedDepth = na

if activeAnchorChanged or activeAnchorRemoved
    anchorKnownBar := activeAnchorValid ? bar_index : na
    anchorKnownTime := activeAnchorValid ? time : na
    maximumObservedDepth := na
    for i = 0 to LEVEL_COUNT - 1
        array.set(touchCounts, i, 0)
        array.set(touchArmed, i, true)
        array.set(responseSums, i, 0.0)
        array.set(responseCounts, i, 0)
        label oldTouchLabel = array.get(latestTouchLabels, i)
        if not na(oldTouchLabel)
            label.delete(oldTouchLabel)
            array.set(latestTouchLabels, i, na)
    array.clear(pendingResponseLevels)
    array.clear(pendingResponseStartBars)

bool eventBarAccepted = confirmedEventsOnlyInput ? barstate.isconfirmed : true
bool reactionModeAvailable = reactionResearchInput and activeAnchorValid and not historicalViewportMode
float touchTolerance = activeAnchorValid ? f_tolerance(
    touchToleranceModeInput,
    activeAtrReference,
    activeLegSize,
    touchAtrInput,
    touchLegPercentInput,
    touchTicksInput,
    minimumTick
) : na
float rearmTolerance = touchTolerance * rearmMultiplierInput
bool anyNewTouch = false
string touchedRatiosThisBar = ""

if reactionModeAvailable and eventBarAccepted and not activeAnchorChanged and bar_index >= nz(anchorKnownBar, bar_index)
    float excursionPrice = activeDirection == 1 ? low : high
    float observedDepth = f_depth(activeOriginPrice, activeTerminalPrice, excursionPrice)
    if not na(observedDepth)
        maximumObservedDepth := na(maximumObservedDepth) ? observedDepth : math.max(maximumObservedDepth, observedDepth)

    for i = 0 to LEVEL_COUNT - 1
        bool enabled = array.get(levelEnabled, i)
        float ratio = array.get(ratios, i)
        bool interiorRatio = ratio > 0.0 and ratio < 1.0
        if enabled and interiorRatio
            float levelPrice = f_level(activeOriginPrice, activeTerminalPrice, ratio)
            bool intersectsTolerance = high >= levelPrice - touchTolerance and low <= levelPrice + touchTolerance
            bool completelyOutsideRearm = high < levelPrice - rearmTolerance or low > levelPrice + rearmTolerance
            bool armed = array.get(touchArmed, i)

            if not armed and completelyOutsideRearm
                array.set(touchArmed, i, true)
                armed := true

            if armed and intersectsTolerance
                int updatedTouchCount = array.get(touchCounts, i) + 1
                array.set(touchCounts, i, updatedTouchCount)
                array.set(touchArmed, i, false)
                array.push(pendingResponseLevels, i)
                array.push(pendingResponseStartBars, bar_index)
                anyNewTouch := true
                touchedRatiosThisBar := touchedRatiosThisBar == "" ? f_ratioText(ratio) : touchedRatiosThisBar + ", " + f_ratioText(ratio)

                if showLatestTouchMarkersInput
                    label touchLabel = array.get(latestTouchLabels, i)
                    color markerColor = array.get(overlapFlags, i) ? overlapColorInput : f_levelColor(ratio)
                    if na(touchLabel)
                        touchLabel := label.new(
                            time,
                            levelPrice,
                            "",
                            xloc = xloc.bar_time,
                            yloc = yloc.price,
                            style = label.style_circle,
                            color = color.new(markerColor, 5),
                            textcolor = markerColor,
                            size = size.tiny,
                            tooltip = "Latest counted touch episode for this ratio."
                        )
                        array.set(latestTouchLabels, i, touchLabel)
                    else
                        label.set_xy(touchLabel, time, levelPrice)
                        label.set_style(touchLabel, label.style_circle)
                        label.set_color(touchLabel, color.new(markerColor, 5))
                        label.set_textcolor(touchLabel, markerColor)
                        label.set_size(touchLabel, size.tiny)
                        label.set_tooltip(touchLabel, "Latest counted touch episode for this ratio.")

    int pendingMeasurementCount = array.size(pendingResponseLevels)
    if pendingMeasurementCount > 0
        for pendingIndex = pendingMeasurementCount - 1 to 0
            int pendingBar = array.get(pendingResponseStartBars, pendingIndex)
            if bar_index - pendingBar >= responseBarsInput
                int pendingLevelIndex = array.get(pendingResponseLevels, pendingIndex)
                float pendingRatio = array.get(ratios, pendingLevelIndex)
                float pendingLevelPrice = f_level(activeOriginPrice, activeTerminalPrice, pendingRatio)
                float signedResponse = (close - pendingLevelPrice) * activeDirection / activeLegSize * 100.0
                array.set(responseSums, pendingLevelIndex, array.get(responseSums, pendingLevelIndex) + signedResponse)
                array.set(responseCounts, pendingLevelIndex, array.get(responseCounts, pendingLevelIndex) + 1)
                array.remove(pendingResponseLevels, pendingIndex)
                array.remove(pendingResponseStartBars, pendingIndex)

if enableDynamicTouchAlertsInput and anyNewTouch
    string dynamicMessage = "Fibonacci level touch episode | " + syminfo.ticker + " | " + timeframe.period + " | Ratios: " + touchedRatiosThisBar + " | Close: " + f_priceText(close)
    if confirmedEventsOnlyInput
        alert(dynamicMessage, alert.freq_once_per_bar_close)
    else
        alert(dynamicMessage, alert.freq_once_per_bar)
//#endregion

//#region ———————————————————— Current depth, nearest level, and factual events
float analysisPrice = historicalViewportMode and not na(visibleRightClose) ? visibleRightClose : close
float currentDepth = activeAnchorValid ? f_depth(activeOriginPrice, activeTerminalPrice, analysisPrice) : na
float nearestDistance = na
float nearestRatio = na
int nearestLevelIndex = na

if activeAnchorValid
    for i = 0 to LEVEL_COUNT - 1
        if array.get(levelEnabled, i)
            float candidateRatioValue = array.get(ratios, i)
            float candidateLevelValue = f_level(activeOriginPrice, activeTerminalPrice, candidateRatioValue)
            float candidateDistance = math.abs(analysisPrice - candidateLevelValue)
            if na(nearestDistance) or candidateDistance < nearestDistance
                nearestDistance := candidateDistance
                nearestRatio := candidateRatioValue
                nearestLevelIndex := i

float nearestDistanceAtr = activeAnchorValid and not na(nearestDistance) ? nearestDistance / math.max(activeAtrReference, minimumTick) : na

float coreRatioA = level3RatioInput
float coreRatioB = level4RatioInput
float coreRatioLow = math.min(coreRatioA, coreRatioB)
float coreRatioHigh = math.max(coreRatioA, coreRatioB)
bool alertModeAvailable = not historicalViewportMode
bool insideCoreBand = activeAnchorValid and level3EnabledInput and level4EnabledInput and currentDepth >= coreRatioLow and currentDepth <= coreRatioHigh
bool enteredCoreBand = alertModeAvailable and eventBarAccepted and insideCoreBand and not insideCoreBand[1] and not activeAnchorChanged
bool rawOriginCross = ta.cross(currentDepth, 1.0)
bool rawTerminalCross = ta.cross(currentDepth, 0.0)
bool crossedOrigin = alertModeAvailable and eventBarAccepted and activeAnchorValid and not activeAnchorChanged and rawOriginCross
bool crossedTerminal = alertModeAvailable and eventBarAccepted and activeAnchorValid and not activeAnchorChanged and rawTerminalCross

bool confirmedNewStructureAlert = activeUsesConfirmedSwing and newAlternatingSwing and activeAnchorValid and barstate.isconfirmed
bool confirmedStructureRevisionAlert = activeUsesConfirmedSwing and sameSideSwingRevision and activeAnchorValid and barstate.isconfirmed
//#endregion

//#region ———————————————————— Drawing object declarations
var array<line> levelLines = array.new<line>(LEVEL_COUNT, na)
var array<label> levelLabels = array.new<label>(LEVEL_COUNT, na)
var line anchorLegLine = na
var label originMarker = na
var label terminalMarker = na
var label depthCursorLabel = na
var box shallowDepthBand = na
var box coreDepthBand = na
var box deepDepthBand = na

bool readoutAnchoredRight = readoutPositionInput == "Top right" or readoutPositionInput == "Bottom right"
int readoutLabelColumn = readoutAnchoredRight ? 0 : 1
int readoutValueColumn = readoutAnchoredRight ? 1 : 2
int readoutSpacerColumn = readoutAnchoredRight ? 2 : 0

var table contextReadout = table.new(
    f_tablePosition(readoutPositionInput),
    3,
    6,
    bgcolor = na,
    frame_color = color.new(shallowColorInput, 8),
    frame_width = 1,
    border_color = color.new(color.white, 76),
    border_width = 1
)

if barstate.isfirst
    for row = 0 to 5
        table.cell(contextReadout, readoutSpacerColumn, row, "", width = readoutEdgeClearanceInput, bgcolor = na)
    table.merge_cells(contextReadout, readoutSpacerColumn, 0, readoutSpacerColumn, 5)
//#endregion

//#region ———————————————————— Last-bar visual rendering
if barstate.islast
    string selectedTextSize = f_textSize(labelSizeInput)
    string selectedReadoutSize = f_textSize(readoutSizeInput)
    string selectedLineStyle = f_lineStyle(levelLineStyleInput)
    int currentStepMs = bar_index > 0 ? math.max(1, time - time[1]) : 1
    int renderRightTime = historicalViewportMode and not na(visibleRightTime) ? visibleRightTime : time
    int renderStepMs = historicalViewportMode and not na(visibleRightStepMs) ? visibleRightStepMs : currentStepMs
    int viewportLeftTime = historicalViewportMode and not na(visibleLeftTime) ? visibleLeftTime : chart.left_visible_bar_time
    int levelStartTime = activeAnchorValid ? (historicalViewportMode ? math.max(viewportLeftTime, activeTerminalTime) : (not na(anchorKnownTime) ? math.max(activeTerminalTime, anchorKnownTime) : activeTerminalTime)) : renderRightTime
    int safeRenderRightTime = activeAnchorValid ? math.max(renderRightTime, levelStartTime + 1) : renderRightTime
    int labelTime = historicalViewportMode ? safeRenderRightTime : safeRenderRightTime + renderStepMs * labelOffsetInput
    string levelLabelStyle = historicalViewportMode ? label.style_label_right : label.style_label_left
    string activeExtend = historicalViewportMode ? extend.none : (extendRightInput ? extend.right : extend.none)

    if showReadoutInput
        table.cell(
            contextReadout,
            readoutSpacerColumn,
            0,
            "",
            width = readoutEdgeClearanceInput,
            bgcolor = na,
            tooltip = "Transparent clearance reserved for chart High/Low and price-scale labels."
        )

    if activeAnchorValid
        // Anchor leg.
        color directionColor = activeDirection == 1 ? upwardColorInput : downwardColorInput
        if showSwingLineInput
            if na(anchorLegLine)
                anchorLegLine := line.new(
                    activeOriginTime,
                    activeOriginPrice,
                    activeTerminalTime,
                    activeTerminalPrice,
                    xloc = xloc.bar_time,
                    extend = extend.none,
                    color = color.new(directionColor, 0),
                    style = line.style_solid,
                    width = 3
                )
            else
                line.set_xy1(anchorLegLine, activeOriginTime, activeOriginPrice)
                line.set_xy2(anchorLegLine, activeTerminalTime, activeTerminalPrice)
                line.set_color(anchorLegLine, directionColor)
                line.set_style(anchorLegLine, line.style_solid)
                line.set_width(anchorLegLine, 3)
        else if not na(anchorLegLine)
            line.delete(anchorLegLine)
            anchorLegLine := na

        // Origin and terminal markers.
        if showAnchorMarkersInput
            string originText = activeDirection == 1 ? "L" : "H"
            string terminalText = activeDirection == 1 ? "H" : "L"
            if na(originMarker)
                originMarker := label.new(
                    activeOriginTime,
                    activeOriginPrice,
                    originText,
                    xloc = xloc.bar_time,
                    yloc = yloc.price,
                    style = label.style_circle,
                    color = color.new(originColorInput, 0),
                    textcolor = DARK_PANEL,
                    size = size.small,
                    tooltip = "Origin anchor"
                )
            else
                label.set_xy(originMarker, activeOriginTime, activeOriginPrice)
                label.set_text(originMarker, originText)
                label.set_color(originMarker, originColorInput)
                label.set_textcolor(originMarker, DARK_PANEL)
                label.set_style(originMarker, label.style_circle)
                label.set_size(originMarker, size.small)
                label.set_tooltip(originMarker, "Origin anchor")

            if na(terminalMarker)
                terminalMarker := label.new(
                    activeTerminalTime,
                    activeTerminalPrice,
                    terminalText,
                    xloc = xloc.bar_time,
                    yloc = yloc.price,
                    style = label.style_circle,
                    color = color.new(directionColor, 0),
                    textcolor = DARK_PANEL,
                    size = size.small,
                    tooltip = "Terminal anchor"
                )
            else
                label.set_xy(terminalMarker, activeTerminalTime, activeTerminalPrice)
                label.set_text(terminalMarker, terminalText)
                label.set_color(terminalMarker, directionColor)
                label.set_textcolor(terminalMarker, DARK_PANEL)
                label.set_style(terminalMarker, label.style_circle)
                label.set_size(terminalMarker, size.small)
                label.set_tooltip(terminalMarker, "Terminal anchor")
        else
            if not na(originMarker)
                label.delete(originMarker)
                originMarker := na
            if not na(terminalMarker)
                label.delete(terminalMarker)
                terminalMarker := na

        // Depth bands begin at the anchor-availability time in confirmed swing and rolling modes.
        // They use the configurable Ratio 3, 4, 5, and 8 slots (defaults: 0.382, 0.500, 0.618, 0.786).
        float bandLevel382 = f_level(activeOriginPrice, activeTerminalPrice, level2RatioInput)
        float bandLevel500 = f_level(activeOriginPrice, activeTerminalPrice, level3RatioInput)
        float bandLevel618 = f_level(activeOriginPrice, activeTerminalPrice, level4RatioInput)
        float bandLevel786 = f_level(activeOriginPrice, activeTerminalPrice, level7RatioInput)

        bool shallowBandAvailable = showDepthBandsInput and level2EnabledInput and level3EnabledInput and math.abs(bandLevel382 - bandLevel500) >= minimumTick
        bool coreBandAvailable = showDepthBandsInput and level3EnabledInput and level4EnabledInput and math.abs(bandLevel500 - bandLevel618) >= minimumTick
        bool deepBandAvailable = showDepthBandsInput and level4EnabledInput and level7EnabledInput and math.abs(bandLevel618 - bandLevel786) >= minimumTick

        if shallowBandAvailable
            float shallowTop = math.max(bandLevel382, bandLevel500)
            float shallowBottom = math.min(bandLevel382, bandLevel500)
            if na(shallowDepthBand)
                shallowDepthBand := box.new(
                    left = levelStartTime,
                    top = shallowTop,
                    right = safeRenderRightTime,
                    bottom = shallowBottom,
                    border_color = na,
                    border_width = 0,
                    extend = activeExtend,
                    xloc = xloc.bar_time,
                    bgcolor = color.new(shallowColorInput, shallowBandTransparencyInput)
                )
            else
                box.set_lefttop(shallowDepthBand, levelStartTime, shallowTop)
                box.set_rightbottom(shallowDepthBand, safeRenderRightTime, shallowBottom)
                box.set_extend(shallowDepthBand, activeExtend)
                box.set_bgcolor(shallowDepthBand, color.new(shallowColorInput, shallowBandTransparencyInput))
                box.set_border_color(shallowDepthBand, na)
        else if not na(shallowDepthBand)
            box.delete(shallowDepthBand)
            shallowDepthBand := na

        if coreBandAvailable
            float coreTop = math.max(bandLevel500, bandLevel618)
            float coreBottom = math.min(bandLevel500, bandLevel618)
            if na(coreDepthBand)
                coreDepthBand := box.new(
                    left = levelStartTime,
                    top = coreTop,
                    right = safeRenderRightTime,
                    bottom = coreBottom,
                    border_color = na,
                    border_width = 0,
                    extend = activeExtend,
                    xloc = xloc.bar_time,
                    bgcolor = color.new(middleColorInput, coreBandTransparencyInput)
                )
            else
                box.set_lefttop(coreDepthBand, levelStartTime, coreTop)
                box.set_rightbottom(coreDepthBand, safeRenderRightTime, coreBottom)
                box.set_extend(coreDepthBand, activeExtend)
                box.set_bgcolor(coreDepthBand, color.new(middleColorInput, coreBandTransparencyInput))
                box.set_border_color(coreDepthBand, na)
        else if not na(coreDepthBand)
            box.delete(coreDepthBand)
            coreDepthBand := na

        if deepBandAvailable
            float deepTop = math.max(bandLevel618, bandLevel786)
            float deepBottom = math.min(bandLevel618, bandLevel786)
            if na(deepDepthBand)
                deepDepthBand := box.new(
                    left = levelStartTime,
                    top = deepTop,
                    right = safeRenderRightTime,
                    bottom = deepBottom,
                    border_color = na,
                    border_width = 0,
                    extend = activeExtend,
                    xloc = xloc.bar_time,
                    bgcolor = color.new(deepColorInput, deepBandTransparencyInput)
                )
            else
                box.set_lefttop(deepDepthBand, levelStartTime, deepTop)
                box.set_rightbottom(deepDepthBand, safeRenderRightTime, deepBottom)
                box.set_extend(deepDepthBand, activeExtend)
                box.set_bgcolor(deepDepthBand, color.new(deepColorInput, deepBandTransparencyInput))
                box.set_border_color(deepDepthBand, na)
        else if not na(deepDepthBand)
            box.delete(deepDepthBand)
            deepDepthBand := na

        // Level lines and labels.
        for i = 0 to LEVEL_COUNT - 1
            bool enabled = array.get(levelEnabled, i)
            line existingLine = array.get(levelLines, i)
            label existingLabel = array.get(levelLabels, i)

            if enabled
                float ratio = array.get(ratios, i)
                float levelPrice = f_level(activeOriginPrice, activeTerminalPrice, ratio)
                bool overlap = array.get(overlapFlags, i)
                color baseLevelColor = overlap ? overlapColorInput : f_levelColor(ratio)
                color renderedLevelColor = color.new(baseLevelColor, inactiveTransparencyInput)
                bool keyGuide = i == 0 or i == 3 or i == 4 or i == 9
                int renderedWidth = keyGuide ? keyLineWidthInput : regularLineWidthInput
                renderedWidth := overlap ? math.min(5, renderedWidth + 1) : renderedWidth

                if na(existingLine)
                    existingLine := line.new(
                        levelStartTime,
                        levelPrice,
                        safeRenderRightTime,
                        levelPrice,
                        xloc = xloc.bar_time,
                        extend = activeExtend,
                        color = renderedLevelColor,
                        style = selectedLineStyle,
                        width = renderedWidth
                    )
                    array.set(levelLines, i, existingLine)
                else
                    line.set_xy1(existingLine, levelStartTime, levelPrice)
                    line.set_xy2(existingLine, safeRenderRightTime, levelPrice)
                    line.set_extend(existingLine, activeExtend)
                    line.set_color(existingLine, renderedLevelColor)
                    line.set_style(existingLine, selectedLineStyle)
                    line.set_width(existingLine, renderedWidth)

                int touchCount = array.get(touchCounts, i)
                int responseCount = array.get(responseCounts, i)
                float averageResponse = responseCount > 0 ? array.get(responseSums, i) / responseCount : na
                bool researchEligible = reactionModeAvailable and ratio > 0.0 and ratio < 1.0
                string overlapPrefix = overlap ? "◆ " : ""
                string researchSummary = researchEligible ? "T" + str.tostring(touchCount) + "  R" + str.tostring(responseCount) + " " + f_signedText(averageResponse) : "Research n/a"
                string levelText = switch labelContentInput
                    "Ratio" => overlapPrefix + f_ratioText(ratio)
                    "Price" => overlapPrefix + f_priceText(levelPrice)
                    "Research detail" => overlapPrefix + f_ratioText(ratio) + "  " + f_priceText(levelPrice) + "  " + researchSummary
                    => overlapPrefix + f_ratioText(ratio) + "  " + f_priceText(levelPrice)
                string researchTooltip = researchEligible ? "\nTouch episodes: " + str.tostring(touchCount) + "\nMeasured responses: " + str.tostring(responseCount) + "\nAverage fixed-horizon response: " + f_signedText(averageResponse) : "\nReaction research is unavailable for this endpoint or anchor mode."
                string levelTooltip = "Ratio: " + f_ratioText(ratio) + "\nPrice: " + f_priceText(levelPrice) + researchTooltip + (overlap ? "\nNear a larger-range Fibonacci level." : "")

                if showLevelLabelsInput
                    if na(existingLabel)
                        existingLabel := label.new(
                            labelTime,
                            levelPrice,
                            levelText,
                            xloc = xloc.bar_time,
                            yloc = yloc.price,
                            style = levelLabelStyle,
                            color = color.new(DARK_PANEL, 4),
                            textcolor = baseLevelColor,
                            size = selectedTextSize,
                            textalign = text.align_left,
                            tooltip = levelTooltip
                        )
                        array.set(levelLabels, i, existingLabel)
                    else
                        label.set_xy(existingLabel, labelTime, levelPrice)
                        label.set_text(existingLabel, levelText)
                        label.set_style(existingLabel, levelLabelStyle)
                        label.set_color(existingLabel, color.new(DARK_PANEL, 4))
                        label.set_textcolor(existingLabel, baseLevelColor)
                        label.set_size(existingLabel, selectedTextSize)
                        label.set_textalign(existingLabel, text.align_left)
                        label.set_tooltip(existingLabel, levelTooltip)
                else if not na(existingLabel)
                    label.delete(existingLabel)
                    array.set(levelLabels, i, na)
            else
                if not na(existingLine)
                    line.delete(existingLine)
                    array.set(levelLines, i, na)
                if not na(existingLabel)
                    label.delete(existingLabel)
                    array.set(levelLabels, i, na)

        // Current-depth cursor.
        if showDepthCursorInput and not na(currentDepth)
            float clampedDepth = math.max(0.0, math.min(1.0, currentDepth))
            float cursorPrice = f_level(activeOriginPrice, activeTerminalPrice, clampedDepth)
            string edgePrefix = currentDepth < 0.0 ? "T+ " : currentDepth > 1.0 ? "O+ " : ""
            string cursorText = "▶ " + edgePrefix + f_ratioText(currentDepth) + "  " + f_depthState(currentDepth)
            int cursorTime = historicalViewportMode ? labelTime : labelTime + renderStepMs * 2
            if na(depthCursorLabel)
                depthCursorLabel := label.new(
                    cursorTime,
                    cursorPrice,
                    cursorText,
                    xloc = xloc.bar_time,
                    yloc = yloc.price,
                    style = levelLabelStyle,
                    color = color.new(DARK_PANEL, 0),
                    textcolor = depthCursorColorInput,
                    size = selectedTextSize,
                    tooltip = "Reference close expressed as retracement depth. Past-chart study uses the rightmost visible bar close. Values below 0% are beyond the terminal anchor; values above 100% are beyond the origin anchor."
                )
            else
                label.set_xy(depthCursorLabel, cursorTime, cursorPrice)
                label.set_text(depthCursorLabel, cursorText)
                label.set_style(depthCursorLabel, levelLabelStyle)
                label.set_color(depthCursorLabel, DARK_PANEL)
                label.set_textcolor(depthCursorLabel, depthCursorColorInput)
                label.set_size(depthCursorLabel, selectedTextSize)
                label.set_tooltip(depthCursorLabel, "Reference close expressed as retracement depth. Past-chart study uses the rightmost visible bar close. Values below 0% are beyond the terminal anchor; values above 100% are beyond the origin anchor.")
        else if not na(depthCursorLabel)
            label.delete(depthCursorLabel)
            depthCursorLabel := na

        // Context readout.
        if showReadoutInput
            string directionText = activeDirection == 1 ? "Up" : "Down"
            string historicalAnchorText = historicalUsesConfirmedSwing ? "Past swing" : historicalUsesRangeFallback ? "Past range" : "Past auto"
            string anchorText = activeUsesUserOrigin ? "User" : historicalViewportMode ? historicalAnchorText : activeUsesRollingRange ? "Rolling" : activeUsesAutoRangeFallback ? "Auto range" : "Confirmed"
            string legText = str.tostring(activeLegBars) + "b/" + str.tostring(activeLegAtr, "#.##") + " ATR"
            string depthText = f_ratioText(currentDepth) + " · " + f_depthStateShort(currentDepth)
            string maximumDepthText = reactionModeAvailable and not na(maximumObservedDepth) ? f_ratioText(maximumObservedDepth) : "n/a"
            string nearestText = not na(nearestRatio) ? f_ratioText(nearestRatio) + " · " + str.tostring(nearestDistanceAtr, "#.##") + " ATR" : "n/a"
            int nearestTouches = not na(nearestLevelIndex) ? array.get(touchCounts, nearestLevelIndex) : 0
            int nearestResponses = not na(nearestLevelIndex) ? array.get(responseCounts, nearestLevelIndex) : 0
            float nearestAverageResponse = nearestResponses > 0 ? array.get(responseSums, nearestLevelIndex) / nearestResponses : na
            bool nearestIsInterior = not na(nearestRatio) and nearestRatio > 0.0 and nearestRatio < 1.0
            string historicalStudyText = activeUsesUserOrigin ? "Origin · " + str.tostring(userStudyBars) + "b" : historicalUsesConfirmedSwing ? "Swing · " + str.tostring(activeLegBars) + "b" : "Range · " + str.tostring(historicalStudyBars) + "b"
            string reactionText = historicalViewportMode ? historicalStudyText : (reactionModeAvailable ? (nearestIsInterior ? "T" + str.tostring(nearestTouches) + "/R" + str.tostring(nearestResponses) + " · " + f_signedText(nearestAverageResponse) : "Endpoint") : "Off")
            string responseRowLabel = historicalViewportMode ? "▣ Study" : "✦ Response"
            bool nearestOverlap = not na(nearestLevelIndex) and array.get(overlapFlags, nearestLevelIndex)
            string overlapCompactText = largerRangeDistinct and nearestOverlap ? "◆ Overlap" : "◆ None"
            string integrityCompactText = historicalViewportMode ? (activeUsesUserOrigin ? "Past · User" : "Past · Auto") : (activeUsesUserOrigin ? (userTerminalClosedBarsInput ? "✓ User · closed" : "⚡ User · live") : confirmedEventsOnlyInput ? "✓ Bar close" : "⚡ Intrabar")
            string contextCompactText = not chart.is_standard ? "⚠ Non-standard" : overlapCompactText + " · " + integrityCompactText

            string anchorCompactText = anchorText + " · " + legText
            string anchorModeDetail = activeUsesUserOrigin ? "User-selected origin with automatic opposite terminal" : historicalViewportMode ? (historicalUsesConfirmedSwing ? "Local confirmed swing in the visible past chart" : "Bounded historical range fallback") : activeUsesRollingRange ? "Rolling range" : activeUsesAutoRangeFallback ? "Bounded automatic range while the confirmed swing engine is warming up" : "Confirmed swing leg"
            string anchorTooltip = "Direction: " + directionText + " leg\nAnchor mode: " + anchorModeDetail + "\nLeg span: " + str.tostring(activeLegBars) + " bars\nLeg size: " + str.tostring(activeLegAtr, "#.##") + " ATR" + (activeUsesUserOrigin ? "\nMove the paired Origin point to recalculate the complete structure." : "")
            string depthTooltip = "Current retracement depth: " + f_ratioText(currentDepth) + " (" + f_depthState(currentDepth) + ")" + (reactionModeAvailable ? "\nMaximum observed depth: " + maximumDepthText : "")
            string nearestTooltip = not na(nearestRatio) ? "Nearest enabled ratio: " + f_ratioText(nearestRatio) + "\nDistance: " + str.tostring(nearestDistanceAtr, "#.##") + " ATR\nLevel price: " + f_priceText(f_level(activeOriginPrice, activeTerminalPrice, nearestRatio)) : "No enabled Fibonacci level is available."
            string responseTooltip = historicalViewportMode ? (activeUsesUserOrigin ? "The user-selected origin is preserved and the visible right edge is the study endpoint. Sequential response statistics are disabled because the completed viewport is retrospective." : historicalUsesConfirmedSwing ? "A recent right-confirmed swing was selected inside the visible past chart. Sequential response statistics remain disabled in historical auto-follow mode." : "No sufficiently recent confirmed pair was available, so the configured local range was used. Sequential response statistics remain disabled.") : (reactionModeAvailable ? "T = independent touch episodes.\nR = completed fixed-horizon responses.\nAverage response: " + f_signedText(nearestAverageResponse) : "Reaction research is disabled in Settings.")
            string baseContextTooltip = historicalViewportMode ? (activeUsesUserOrigin ? "Past study uses the selected origin and stops at the visible right edge." : "Automatic historical study follows the visible right edge and uses the configured bounded local window.") : (activeUsesUserOrigin ? "The origin is controlled by the paired chart point. The terminal is the most extreme opposite price after it" + (userTerminalClosedBarsInput ? " on closed bars." : " including the live bar.") : activeUsesAutoRangeFallback ? "The automatic engine is warming up on a bounded closed-bar range and will switch to the next accepted confirmed swing pair." : "The automatic anchor engine is active. Event timing: " + (confirmedEventsOnlyInput ? "bar close." : "intrabar."))
            string contextTooltip = baseContextTooltip + (nearestOverlap ? "\nThe nearest level is close to an enabled ratio from the larger rolling range." : "\nNo larger-range overlap is detected at the nearest level.")

            table.cell(contextReadout, readoutLabelColumn, 0, "FIB RETRACEMENT", text_color = shallowColorInput, bgcolor = DARK_PANEL_2, text_size = selectedReadoutSize, text_halign = text.align_left, tooltip = "Fibonacci retracement structure and research context.", text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 0, activeDirection == 1 ? "▲" : "▼", text_color = directionColor, bgcolor = DARK_PANEL_2, text_size = selectedReadoutSize, text_halign = text.align_right, tooltip = directionText + " leg", text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 1, "⧉ Anchor", text_color = MUTED_TEXT, bgcolor = DARK_PANEL, text_size = selectedReadoutSize, text_halign = text.align_left, tooltip = anchorTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 1, anchorCompactText, text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL, text_size = selectedReadoutSize, text_halign = text.align_right, tooltip = anchorTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 2, "◎ Depth", text_color = MUTED_TEXT, bgcolor = DARK_PANEL_2, text_size = selectedReadoutSize, text_halign = text.align_left, tooltip = depthTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 2, depthText, text_color = f_levelColor(math.max(0.0, math.min(1.0, currentDepth))), bgcolor = DARK_PANEL_2, text_size = selectedReadoutSize, text_halign = text.align_right, tooltip = depthTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 3, "◉ Nearest", text_color = MUTED_TEXT, bgcolor = DARK_PANEL, text_size = selectedReadoutSize, text_halign = text.align_left, tooltip = nearestTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 3, nearestText, text_color = not na(nearestRatio) ? f_levelColor(nearestRatio) : BRIGHT_TEXT, bgcolor = DARK_PANEL, text_size = selectedReadoutSize, text_halign = text.align_right, tooltip = nearestTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 4, responseRowLabel, text_color = MUTED_TEXT, bgcolor = DARK_PANEL_2, text_size = selectedReadoutSize, text_halign = text.align_left, tooltip = responseTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 4, reactionText, text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL_2, text_size = selectedReadoutSize, text_halign = text.align_right, tooltip = responseTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 5, "⚙ Context", text_color = nearestOverlap ? overlapColorInput : MUTED_TEXT, bgcolor = DARK_PANEL, text_size = selectedReadoutSize, text_halign = text.align_left, tooltip = contextTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 5, contextCompactText, text_color = chart.is_standard ? BRIGHT_TEXT : WARNING_COLOR, bgcolor = DARK_PANEL, text_size = selectedReadoutSize, text_halign = text.align_right, tooltip = contextTooltip, text_formatting = text.format_bold)
        else
            table.clear(contextReadout, 0, 0, 2, 5)
    else
        // Remove price drawings when an anchor is unavailable.
        for i = 0 to LEVEL_COUNT - 1
            line existingLine = array.get(levelLines, i)
            label existingLabel = array.get(levelLabels, i)
            if not na(existingLine)
                line.delete(existingLine)
                array.set(levelLines, i, na)
            if not na(existingLabel)
                label.delete(existingLabel)
                array.set(levelLabels, i, na)

        if not na(anchorLegLine)
            line.delete(anchorLegLine)
            anchorLegLine := na
        if not na(terminalMarker)
            label.delete(terminalMarker)
            terminalMarker := na

        // Keep one origin marker visible after the point is accepted, even while the automatic terminal is still unavailable.
        if userOriginMode and userOriginResolved
            int pendingDirection = userOriginDirectionInput == "Up leg" ? 1 : userOriginDirectionInput == "Down leg" ? -1 : userPreferredDirection
            float pendingOriginPrice = pendingDirection == 1 ? userUpOriginPrice : userDownOriginPrice
            string pendingOriginText = pendingDirection == 1 ? "L" : "H"
            string pendingOriginTooltip = userResolvedOriginTime >= userCalculationEndpointTime ? "Origin accepted, but the calculation endpoint must be later than the origin." : "Origin accepted. Waiting for a valid later opposite terminal."
            if not na(pendingOriginPrice)
                if na(originMarker)
                    originMarker := label.new(
                        userResolvedOriginTime,
                        pendingOriginPrice,
                        pendingOriginText,
                        xloc = xloc.bar_time,
                        yloc = yloc.price,
                        style = label.style_circle,
                        color = color.new(originColorInput, 0),
                        textcolor = DARK_PANEL,
                        size = size.small,
                        tooltip = pendingOriginTooltip
                    )
                else
                    label.set_xy(originMarker, userResolvedOriginTime, pendingOriginPrice)
                    label.set_text(originMarker, pendingOriginText)
                    label.set_color(originMarker, originColorInput)
                    label.set_textcolor(originMarker, DARK_PANEL)
                    label.set_style(originMarker, label.style_circle)
                    label.set_size(originMarker, size.small)
                    label.set_tooltip(originMarker, pendingOriginTooltip)
            else if not na(originMarker)
                label.delete(originMarker)
                originMarker := na
        else if not na(originMarker)
            label.delete(originMarker)
            originMarker := na
        if not na(depthCursorLabel)
            label.delete(depthCursorLabel)
            depthCursorLabel := na
        if not na(shallowDepthBand)
            box.delete(shallowDepthBand)
            shallowDepthBand := na
        if not na(coreDepthBand)
            box.delete(coreDepthBand)
            coreDepthBand := na
        if not na(deepDepthBand)
            box.delete(deepDepthBand)
            deepDepthBand := na

        if showReadoutInput
            bool userPointAfterEndpoint = userOriginResolved and userResolvedOriginTime >= userCalculationEndpointTime
            bool explicitUpMissing = userOriginMode and userOriginDirectionInput == "Up leg" and not userUpPairValid
            bool explicitDownMissing = userOriginMode and userOriginDirectionInput == "Down leg" and not userDownPairValid
            string manualWaitingText = not userPointConfigured ? "Select the Origin point on the chart" : not userOriginResolved ? "The selected origin time is outside the loaded chart history" : userPointAfterEndpoint ? "Move the Origin point to a bar before the calculation endpoint" : explicitUpMissing ? "The selected Up leg needs a later price above its origin" : explicitDownMissing ? "The selected Down leg needs a later price below its origin" : "The selected origin needs a valid later opposite terminal"
            string automaticWaitingText = historicalViewportMode ? "The visible past chart needs two distinct prices inside the automatic local window" : confirmedMode ? "The automatic engine needs at least two distinct finalized prices" : "Waiting for a valid rolling high-low range"
            string waitingText = userOriginMode ? manualWaitingText : automaticWaitingText
            string waitingCompactText = userOriginMode ? (not userPointConfigured ? "Set origin" : userPointAfterEndpoint ? "Move origin" : "Need terminal") : historicalViewportMode ? "Need local range" : confirmedMode ? "Need 2 prices" : "Need valid range"
            string waitingAnchorText = userOriginMode ? "User" : historicalViewportMode ? "Past auto" : confirmedMode ? "Automatic" : "Rolling"
            string waitingAnchorTooltip = userOriginMode ? "Manual origin is an explicit mode. Set or move the paired point until a valid terminal exists." : historicalViewportMode ? "Automatic historical calculation uses the visible right edge and the configured local window." : "Automatic swing mode is active and uses a bounded closed-bar range during warm-up."

            table.cell(contextReadout, readoutLabelColumn, 0, "FIB RETRACEMENT", text_color = shallowColorInput, bgcolor = DARK_PANEL_2, text_size = f_textSize(readoutSizeInput), text_halign = text.align_left, tooltip = waitingText, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 0, "…", text_color = WARNING_COLOR, bgcolor = DARK_PANEL_2, text_size = f_textSize(readoutSizeInput), text_halign = text.align_right, tooltip = waitingText, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 1, "⧉ Anchor", text_color = MUTED_TEXT, bgcolor = DARK_PANEL, text_size = f_textSize(readoutSizeInput), text_halign = text.align_left, tooltip = waitingAnchorTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 1, waitingAnchorText, text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL, text_size = f_textSize(readoutSizeInput), text_halign = text.align_right, tooltip = waitingAnchorTooltip, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 2, "◎ Status", text_color = MUTED_TEXT, bgcolor = DARK_PANEL_2, text_size = f_textSize(readoutSizeInput), text_halign = text.align_left, tooltip = waitingText, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 2, waitingCompactText, text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL_2, text_size = f_textSize(readoutSizeInput), text_halign = text.align_right, tooltip = waitingText, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 3, "◉ Nearest", text_color = MUTED_TEXT, bgcolor = DARK_PANEL, text_size = f_textSize(readoutSizeInput), text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 3, "—", text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL, text_size = f_textSize(readoutSizeInput), text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 4, historicalViewportMode ? "▣ Study" : "✦ Response", text_color = MUTED_TEXT, bgcolor = DARK_PANEL_2, text_size = f_textSize(readoutSizeInput), text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 4, "—", text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL_2, text_size = f_textSize(readoutSizeInput), text_halign = text.align_right, text_formatting = text.format_bold)
            table.cell(contextReadout, readoutLabelColumn, 5, "⚙ Context", text_color = MUTED_TEXT, bgcolor = DARK_PANEL, text_size = f_textSize(readoutSizeInput), text_formatting = text.format_bold)
            table.cell(contextReadout, readoutValueColumn, 5, userOriginMode ? "Manual" : "Auto", text_color = BRIGHT_TEXT, bgcolor = DARK_PANEL, text_size = f_textSize(readoutSizeInput), text_halign = text.align_right, tooltip = waitingAnchorTooltip, text_formatting = text.format_bold)
        else
            table.clear(contextReadout, 0, 0, 2, 5)
//#endregion

//#region ———————————————————— Alert conditions
alertcondition(
    confirmedNewStructureAlert,
    "New confirmed Fibonacci swing structure",
    "A new opposite-pivot Fibonacci retracement structure was confirmed on {{ticker}} {{interval}}."
)
alertcondition(
    confirmedStructureRevisionAlert,
    "Confirmed Fibonacci terminal revision",
    "The terminal pivot of the active Fibonacci retracement structure was revised by a more extreme confirmed same-side pivot on {{ticker}} {{interval}}."
)
alertcondition(
    anyNewTouch,
    "Fibonacci level touch episode",
    "Price entered the configured tolerance around at least one enabled interior Fibonacci level on {{ticker}} {{interval}}."
)
alertcondition(
    enteredCoreBand,
    "Core Fibonacci band entered",
    "Price entered the band defined by the Ratio 4 and Ratio 5 inputs on {{ticker}} {{interval}}."
)
alertcondition(
    crossedOrigin,
    "Fibonacci origin crossed",
    "Price crossed the active Fibonacci origin level on {{ticker}} {{interval}}."
)
alertcondition(
    crossedTerminal,
    "Fibonacci terminal crossed",
    "Price crossed the active Fibonacci terminal level on {{ticker}} {{interval}}."
)
//#endregion

//#region ———————————————————— Preserve anchor fingerprint for the next execution
previousAnchorValid := activeAnchorValid
previousOriginPrice := activeOriginPrice
previousTerminalPrice := activeTerminalPrice
previousOriginTime := activeOriginTime
previousTerminalTime := activeTerminalTime
//#endregion
````
