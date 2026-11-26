# Anchored VWAP Origin Chronicle - Manual Swing High and Low

- url: https://www.tradingview.com/script/5CuNNYSY-Anchored-VWAP-Origin-Chronicle-Manual-Swing-High-and-Low/
- type: indicator
- pine_id: PUB;b895810c9272435b9790089a8c98f360
- version: 1.0

## Description

Overview

Anchored VWAP Origin Chronicle is an open-source chart overlay for studying chart-reported volume-weighted price from three independently managed origins:

* one manually selected chart point;
* the latest accepted, confirmed swing-high origin;
* the latest accepted, confirmed swing-low origin.

The manual time selects the first chart bar included in the manual anchored VWAP. The manual price is used only to position the M marker; moving that marker vertically does not change the calculation.

This is not a session-reset VWAP, a deviation-band study, a prediction model, a strategy, or a buy/sell signal system. Its purpose is to make origin selection, confirmation timing, volume availability, visible-window context, and the relationship between two independently anchored structural means explicit and researchable.

What the script calculates

For each active origin, the calculation is:

AVWAP = sum(source x positive chart-reported volume) / sum(positive chart-reported volume)

The manual, swing-high, and swing-low AVWAPs maintain independent numerators and denominators. The implementation uses compensated floating-point accumulation to reduce numerical cancellation that can occur when recent anchored values are obtained by subtracting large chart-wide cumulative totals.

Missing, zero, negative, or otherwise unusable volume receives zero weight. The script does not replace unavailable volume with equal bar weighting or TWAP. The calculation can therefore remain unavailable on symbols or ranges that do not provide positive chart volume.

Manual origin

When the indicator is added, select the chart point that should act as the manual origin.

* The selected time determines the first included bar.
* The selected price positions the M marker only.
* The cyan manual AVWAP is independent of the two automatic AVWAPs.
* If the selected time is earlier than the loaded dataset, the manual calculation is blocked instead of silently substituting the first loaded bar.
* By default, the manual AVWAP is hidden when its origin is outside the current visible horizontal range. This prevents an off-screen manual anchor from appearing as an unexplained line. Disable "Hide manual AVWAP when origin is outside view" when a long-horizon manual projection should remain visible.

Hiding the manual curve is a presentation rule only. It does not redefine the selected origin or convert the calculation into a visible-range VWAP.

Confirmed swing origins

The magenta high-origin AVWAP and green low-origin AVWAP are managed independently. Replacing one origin does not force the other side to reset.

An automatic origin is not accepted solely because it is a local high or low. Users can control:

* bars required on the left and right of a pivot;
* minimum local prominence normalized by ATR;
* minimum spacing between same-type origins;
* an optional relative-volume requirement at the pivot bar;
* the replacement policy.

The available replacement policies are:

* Latest qualified: accepts each new candidate that passes the active filters.
* More prominent only: requires a candidate to improve on the active same-type origin by the configured ATR-normalized margin.
* New price extreme only: requires a higher high for the high-origin curve or a lower low for the low-origin curve.

Confirmation chronology

Automatic pivots require the configured number of right-side bars. A pivot therefore becomes knowable only after its confirmation delay has elapsed.

H and L labels identify the historical origin bars after confirmation. The optional confirmation marker identifies the later bar where the pivot became available, and the dotted bridge shows the origin-to-confirmation delay.

The automatic AVWAP includes chart-reported volume beginning at the actual pivot bar. However, the curve is not backfilled through the origin-to-confirmation interval. It first appears after confirmation and is broken on an anchor-replacement bar so the previous and replacement origins are not visually connected.

This distinction is important: the calculation starts at the pivot, but the automatic origin is not treated as known before confirmation.

Visible-window historical research

The indicator is designed to support both live observation and historical chart research.

Plots, endpoint symbols, retained origin drawings, visible-range volume statistics, and the status panel follow the chart's current visible horizontal range. Scrolling or zooming the chart re-evaluates that research view.

The status panel is evaluated at the rightmost visible bar:

* LIVE means the visible right edge is the developing realtime bar.
* CLOSED means the visible right edge is the latest confirmed bar.
* HISTORY means the latest chart bar is outside the visible range and the panel is reporting a historical research state.

When HISTORY is shown, later bars do not redefine the panel state displayed for the visible right edge. A pivot that would only be confirmed after that visible right edge is not drawn as an available historical origin in that research view.

The underlying AVWAP accumulation still begins at the true accepted origin. The script does not restart an automatic AVWAP at the left edge of the screen.

Swing-pair relationship model

When both automatic AVWAPs are available, the script reports:

* whether the selected context source is above both curves, below both curves, or between them;
* the separation between the two curves in ATR units;
* whether the pair is within the user-defined convergence threshold;
* whether the high-origin curve is above or below the low-origin curve;
* optional confirmed order-flip events when the curves cross.

The transparent fill describes the current price context. When the two automatic curves are close enough to satisfy the convergence threshold, an amber midpoint spine helps preserve visual separation without moving either AVWAP.

These relationships are descriptive. They are not directional forecasts, entries, exits, or trade recommendations.

Visual design

The default presentation uses:

* cyan for the manual AVWAP;
* magenta for the confirmed swing-high-origin AVWAP;
* green for the confirmed swing-low-origin AVWAP;
* a dark contrast halo;
* an optional one-pixel precision core;
* compact endpoint symbols at the rightmost visible values;
* a transparent relationship fill;
* an amber convergence spine when the automatic curves overlap closely.

Cross, convergence-event, and order-flip markers are available but disabled by default to keep the chart readable. Colors, widths, transparency, retained marker history, panel position, panel size, and right-axis clearance are configurable.

Status panel

The panel summarizes:

◆ Manual anchor
▲ High origin
▼ Low origin
● Price context
↔ Pair relation
✓ or ! Data integrity

The panel can report states including WAITING, ORIGIN OUTSIDE VIEW, OUTSIDE LOADED DATA, BLOCKED, NO VOLUME, SYNTHETIC, PARTIAL, and READY.

READY has a narrow meaning: the percentage of visible bars with positive usable chart volume meets the configured threshold. It is not a certification of exchange data, broker data, data-vendor accuracy, or market quality.

Chart-type and volume handling

Standard chart prices are accepted by default.

Heikin Ashi, Renko, Kagi, Line Break, Point & Figure, Range, and other calculated-price chart types are blocked by default because their displayed prices are synthetic or transformed. Users can opt in intentionally. When enabled on such charts, the panel identifies the state as SYNTHETIC.

The panel also reports the chart's volume type when available. Depending on the symbol, volume can represent exchange volume, base volume, quote volume, tick volume, another reported measure, or no usable value.

Alerts

All optional events are routed through one dynamic alert call. To use alerts:

1. Enable "Dynamic alerts" in the indicator settings.
2. Create a TradingView alert.
3. Select this indicator.
4. Choose "Any alert() function call."

Dynamic messages can report:

* newly accepted confirmed swing origins;
* confirmed price crosses of the manual, high-origin, or low-origin AVWAP;
* transitions into above-both or below-both context;
* entry into swing-pair convergence;
* order flips between the two automatic AVWAPs.

Automatic anchor replacement, event conditions, and alerts are evaluated on confirmed bar close. Active AVWAP values can still change while the current realtime bar is forming because its price and cumulative volume are not final.

The visible-window presentation does not redefine the alert conditions. Alert events use the underlying live series and confirmed-bar logic.

Suggested workflow

1. Add the indicator and select a meaningful manual origin.
2. Confirm that the chart provides the type of volume you intend to study.
3. Read H and L as confirmed historical origins, not as signals available on the original pivot bar.
4. Compare the independent manual, high-origin, and low-origin AVWAP paths.
5. Use the panel to inspect price context, pair separation, curve order, visible-range volume coverage, and LIVE/CLOSED/HISTORY state.
6. Adjust pivot qualification and replacement policy to study how different origin definitions change the result.
7. Enable optional event markers or alerts only when they are useful to the research question.

Limitations

* Results depend entirely on the price and volume series supplied by the chart and data provider.
* No AVWAP is produced when total positive chart-reported volume from an origin is zero.
* Tick volume, base volume, quote volume, and exchange volume are not interchangeable economic measures.
* Pivot confirmation necessarily occurs after the pivot bar. Larger right-side settings increase the delay.
* H and L labels are placed on historical origin bars only after confirmation.
* The open realtime bar can change the current AVWAP values until that bar closes.
* Scrolling or zooming changes the visible-window research scope and therefore the panel's visible-range statistics and right-edge state.
* Default settings are general research starting points. They are not optimized for a symbol, timeframe, market, or outcome.
* ATR prominence, relative volume, convergence, curve order, fills, markers, and alerts describe observed chart relationships only.
* This indicator does not claim profitability, predictive accuracy, or future performance and does not provide financial advice.

Open-source note

This is an independent open-source implementation built from the conventional definition of volume-weighted average price and standard Pine Script features. It does not incorporate third-party indicator source code, a proprietary trading methodology, or a paper-specific implementation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SG_Group

//@version=6
indicator(
     title = "Anchored VWAP Origin Chronicle - Manual Swing High and Low",
     shorttitle = "Anchored VWAP Origin Chronicle",
     overlay = true,
     max_bars_back = 1000,
     max_labels_count = 300,
     max_lines_count = 200,
     explicit_plot_zorder = true,
     behind_chart = false)

//------------------------------------------------------------------------------
// Input groups
//------------------------------------------------------------------------------
const string GROUP_MANUAL = "1. Manual Anchor"
const string GROUP_SWINGS = "2. Confirmed Swing Anchors"
const string GROUP_CALC = "3. Calculation"
const string GROUP_VISUALS = "4. Visuals"
const string GROUP_READOUT = "5. Anchor Readout"
const string GROUP_ALERTS = "6. Alerts"

//------------------------------------------------------------------------------
// Manual anchor
// The paired time and price inputs create one interactive chart point.
// Time selects the first included bar. Price positions the M marker only.
//------------------------------------------------------------------------------
bool showManual = input.bool(
     true,
     "Show manual AVWAP",
     group = GROUP_MANUAL,
     tooltip = "Displays a VWAP beginning on the bar selected by the interactive anchor point.",
     display = display.none)

bool hideManualWhenOriginOutsideView = input.bool(
     true,
     "Hide manual AVWAP when origin is outside view",
     group = GROUP_MANUAL,
     tooltip = "Keeps the chart focused on the current visible time range. Disable this only when you intentionally want a manual AVWAP to remain visible after its anchor has moved outside the viewport.",
     display = display.none)

float manualAnchorPriceInput = input.price(
     0.0,
     "Manual anchor",
     inline = "manualPoint",
     group = GROUP_MANUAL,
     confirm = true,
     tooltip = "The selected price positions the M marker only. It does not alter the VWAP calculation.",
     display = display.none)

int manualAnchorTimeInput = input.time(
     timestamp("01 Jan 2024 00:00 +0000"),
     "",
     inline = "manualPoint",
     group = GROUP_MANUAL,
     confirm = true,
     tooltip = "Click an important chart point when adding the script. Time selects the first included bar; price positions the M marker only.",
     display = display.none)

//------------------------------------------------------------------------------
// Confirmed swing anchors
//------------------------------------------------------------------------------
bool showSwingHigh = input.bool(
     true,
     "Show confirmed swing-high AVWAP",
     group = GROUP_SWINGS,
     display = display.none)

bool showSwingLow = input.bool(
     true,
     "Show confirmed swing-low AVWAP",
     group = GROUP_SWINGS,
     display = display.none)

int swingLeft = input.int(
     8,
     "Pivot bars left",
     minval = 1,
     maxval = 50,
     group = GROUP_SWINGS,
     tooltip = "Bars required to the left of a candidate pivot.",
     display = display.none)

int swingRight = input.int(
     5,
     "Pivot bars right",
     minval = 1,
     maxval = 50,
     group = GROUP_SWINGS,
     tooltip = "Bars required to the right before a pivot is confirmed. Automatic anchors never activate before this delay has elapsed.",
     display = display.none)

float minimumProminenceAtr = input.float(
     1.00,
     "Minimum local prominence in ATR",
     minval = 0.0,
     maxval = 20.0,
     step = 0.05,
     group = GROUP_SWINGS,
     tooltip = "A high must stand this many ATR above the completed pivot window low. A low must stand this many ATR below the completed pivot window high.",
     display = display.none)

int minimumBarsBetweenSameType = input.int(
     15,
     "Minimum bars between same-type anchors",
     minval = 0,
     maxval = 1000,
     group = GROUP_SWINGS,
     tooltip = "Reduces rapid replacement of one high-origin anchor by another high, and likewise for low-origin anchors.",
     display = display.none)

string replacementPolicy = input.string(
     "Latest qualified",
     "Automatic anchor replacement policy",
     options = ["Latest qualified", "More prominent only", "New price extreme only"],
     group = GROUP_SWINGS,
     tooltip = "Latest qualified follows every accepted swing. More prominent only requires an ATR-prominence improvement. New price extreme only requires a higher high or lower low.",
     display = display.none)

float prominenceImprovementAtr = input.float(
     0.10,
     "Prominence improvement margin in ATR",
     minval = 0.0,
     maxval = 20.0,
     step = 0.05,
     group = GROUP_SWINGS,
     tooltip = "Used by More prominent only. A replacement must improve on the active same-type origin by at least this ATR-normalized amount.",
     display = display.none)

bool useRelativeVolumeFilter = input.bool(
     false,
     "Require relative volume at swing origin",
     group = GROUP_SWINGS,
     tooltip = "When enabled, an automatic origin is accepted only when chart-reported volume on the pivot bar meets the selected ratio versus its moving average.",
     display = display.none)

int relativeVolumeLength = input.int(
     50,
     "Relative volume average length",
     minval = 2,
     maxval = 500,
     group = GROUP_SWINGS,
     display = display.none)

float minimumRelativeVolume = input.float(
     1.00,
     "Minimum relative volume ratio",
     minval = 0.0,
     maxval = 20.0,
     step = 0.05,
     group = GROUP_SWINGS,
     display = display.none)

//------------------------------------------------------------------------------
// Calculation
//------------------------------------------------------------------------------
float vwapSource = input.source(
     hlc3,
     "VWAP source",
     group = GROUP_CALC,
     tooltip = "Price source multiplied by the volume series supplied by the chart.",
     display = display.none)

float contextSource = input.source(
     close,
     "Price-context source",
     group = GROUP_CALC,
     tooltip = "Used only for confirmed cross events and the above, between, or below pair classification.",
     display = display.none)

int atrLength = input.int(
     14,
     "ATR length",
     minval = 1,
     maxval = 500,
     group = GROUP_CALC,
     tooltip = "Used for swing-prominence normalization and the swing-pair spread readout.",
     display = display.none)

float convergenceThresholdAtr = input.float(
     0.25,
     "Pair convergence threshold in ATR",
     minval = 0.0,
     maxval = 10.0,
     step = 0.05,
     group = GROUP_CALC,
     tooltip = "The two automatic AVWAPs are classified as converged at or below this ATR-normalized separation.",
     display = display.none)

bool allowNonStandardCharts = input.bool(
     false,
     "Allow calculated-price chart types",
     group = GROUP_CALC,
     tooltip = "Disabled by default. Heikin Ashi, Renko, Kagi, Line Break, Point and Figure, and Range charts use calculated prices. Enable only when you intentionally want this script to use those chart prices.",
     display = display.none)

float minimumVolumeCoveragePercent = input.float(
     90.0,
     "Minimum volume coverage for READY status",
     minval = 1.0,
     maxval = 100.0,
     step = 1.0,
     group = GROUP_CALC,
     tooltip = "Classifies volume coverage in the readout. It never fills missing volume and never changes the AVWAP formula.",
     display = display.none)

//------------------------------------------------------------------------------
// Visual controls
//------------------------------------------------------------------------------
bool showPairFill = input.bool(
     true,
     "Fill between swing-origin AVWAPs",
     group = GROUP_VISUALS,
     display = display.none)

bool showContrastHalo = input.bool(
     true,
     "Use high-contrast line halo",
     group = GROUP_VISUALS,
     tooltip = "Draws a wider dark line below each bright AVWAP for visibility on both light and dark charts.",
     display = display.none)

bool showPrecisionCore = input.bool(
     true,
     "Show thin precision core",
     group = GROUP_VISUALS,
     tooltip = "Adds a one-pixel light center trace inside each colored AVWAP. This keeps the exact path readable when candles or filled areas use similar colors.",
     display = display.none)

int precisionCoreTransparency = input.int(
     58,
     "Precision core transparency",
     minval = 0,
     maxval = 95,
     group = GROUP_VISUALS,
     display = display.none)

bool showConvergedPairSpine = input.bool(
     true,
     "Highlight overlapping swing AVWAPs",
     group = GROUP_VISUALS,
     tooltip = "Draws a thin amber spine at the midpoint while the high-origin and low-origin AVWAPs are within the configured convergence threshold. It identifies overlap without moving either AVWAP.",
     display = display.none)

bool showActiveLineEndpoints = input.bool(
     true,
     "Show active AVWAP endpoints",
     group = GROUP_VISUALS,
     tooltip = "Adds one compact symbol at the latest visible value of each active AVWAP: diamond for manual, downward triangle for high origin, and upward triangle for low origin.",
     display = display.none)

bool showAnchorMarkers = input.bool(
     true,
     "Show origin markers",
     group = GROUP_VISUALS,
     tooltip = "M is the manual point. H and L mark confirmed pivot origins.",
     display = display.none)

bool showConfirmationMarkers = input.bool(
     false,
     "Show confirmation markers",
     group = GROUP_VISUALS,
     tooltip = "Optional markers identify the later bar where each automatic pivot became knowable. They are hidden by default to keep the publication view clean.",
     display = display.none)

bool showConfirmationBridges = input.bool(
     true,
     "Show pivot-to-confirmation bridges",
     group = GROUP_VISUALS,
     tooltip = "A dotted bridge makes the automatic pivot confirmation delay explicit instead of implying that the origin was known on the pivot bar.",
     display = display.none)

string confirmationMarkerStyle = input.string(
     "C badge",
     "Confirmation marker style",
     options = ["C badge", "Dot"],
     group = GROUP_VISUALS,
     tooltip = "Used only when confirmation markers are enabled. C badge is explicit; Dot is more compact.",
     display = display.none)

bool showCrossMarkers = input.bool(
     false,
     "Show confirmed price-cross markers",
     group = GROUP_VISUALS,
     tooltip = "Small circles mark bar-close crosses of active AVWAPs. They are factual events, not trade signals.",
     display = display.none)

bool showConvergenceMarkers = input.bool(
     false,
     "Show pair-convergence markers",
     group = GROUP_VISUALS,
     display = display.none)

bool showPairOrderMarkers = input.bool(
     false,
     "Show swing-pair order-flip markers",
     group = GROUP_VISUALS,
     tooltip = "Marks confirmed crosses between the high-origin and low-origin AVWAP curves. These are relationship events, not trade signals.",
     display = display.none)

int eventMarkerWidth = input.int(
     3,
     "Event marker width",
     minval = 1,
     maxval = 5,
     group = GROUP_VISUALS,
     tooltip = "Controls optional cross, convergence-event, and pair-order markers. These markers are hidden by default to keep the AVWAP paths unobstructed.",
     display = display.none)

int markerHistory = input.int(
     18,
     "Confirmed swing events retained",
     minval = 1,
     maxval = 80,
     group = GROUP_VISUALS,
     tooltip = "Limits H/L origin labels, optional confirmation markers, and dotted confirmation bridges retained inside the current visible chart range.",
     display = display.none)

int mainLineWidth = input.int(
     2,
     "Main line width",
     minval = 1,
     maxval = 6,
     group = GROUP_VISUALS,
     display = display.none)

int haloExtraWidth = input.int(
     2,
     "Halo extra width",
     minval = 1,
     maxval = 6,
     group = GROUP_VISUALS,
     display = display.none)

int haloTransparency = input.int(
     10,
     "Halo transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_VISUALS,
     display = display.none)

int pairFillTransparency = input.int(
     84,
     "Pair fill transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_VISUALS,
     display = display.none)

color manualColor = input.color(
     color.rgb(0, 229, 255),
     "Manual AVWAP color",
     group = GROUP_VISUALS,
     display = display.none)

color swingHighColor = input.color(
     color.rgb(255, 61, 141),
     "Swing-high AVWAP color",
     group = GROUP_VISUALS,
     display = display.none)

color swingLowColor = input.color(
     color.rgb(57, 255, 136),
     "Swing-low AVWAP color",
     group = GROUP_VISUALS,
     display = display.none)

color betweenColor = input.color(
     color.rgb(124, 77, 255),
     "Between-pair fill color",
     group = GROUP_VISUALS,
     display = display.none)

color pairEventColor = input.color(
     color.rgb(255, 202, 40),
     "Pair relationship event color",
     group = GROUP_VISUALS,
     display = display.none)

color haloColor = input.color(
     color.rgb(5, 8, 15),
     "Contrast halo color",
     group = GROUP_VISUALS,
     display = display.none)

//------------------------------------------------------------------------------
// Readout controls
//------------------------------------------------------------------------------
bool showReadout = input.bool(
     true,
     "Show anchor readout",
     group = GROUP_READOUT,
     display = display.none)

string readoutPositionInput = input.string(
     "Top Right",
     "Readout position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group = GROUP_READOUT,
     tooltip = "Right-side positions keep the panel in the chart corner while reserving only a small transparent clearance for right-axis High and Low labels.",
     display = display.none)

int readoutRightPaddingPercent = input.int(
     2,
     "Right-axis clearance percent",
     minval = 1,
     maxval = 10,
     group = GROUP_READOUT,
     tooltip = "Small transparent clearance between a right-side panel and the price scale, measured as a percentage of pane width. The two-percent default keeps the panel distinctly upper-right while preserving room for High and Low scale labels.",
     display = display.none)

string readoutSizeInput = input.string(
     "Normal",
     "Readout text size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GROUP_READOUT,
     display = display.none)

int readoutTransparency = input.int(
     4,
     "Readout background transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_READOUT,
     display = display.none)

//------------------------------------------------------------------------------
// Alert controls
// Only alert() is used, so the Create Alert dialog exposes one condition:
// Any alert() function call.
//------------------------------------------------------------------------------
bool enableAlerts = input.bool(
     false,
     "Enable dynamic alerts",
     group = GROUP_ALERTS,
     tooltip = "After enabling this input, create one TradingView alert using Any alert() function call.",
     display = display.none)

bool alertOnNewAnchors = input.bool(
     true,
     "Alert on new confirmed swing anchors",
     group = GROUP_ALERTS,
     display = display.none)

bool alertOnPriceCrosses = input.bool(
     true,
     "Alert on confirmed AVWAP crosses",
     group = GROUP_ALERTS,
     display = display.none)

bool alertOnPairTransitions = input.bool(
     true,
     "Alert when price enters above-both or below-both context",
     group = GROUP_ALERTS,
     display = display.none)

bool alertOnConvergence = input.bool(
     true,
     "Alert when the swing pair enters convergence",
     group = GROUP_ALERTS,
     display = display.none)

bool alertOnPairOrderFlip = input.bool(
     true,
     "Alert when swing-origin AVWAP order flips",
     group = GROUP_ALERTS,
     display = display.none)

//------------------------------------------------------------------------------
// Utility functions
//------------------------------------------------------------------------------
f_tablePosition(string value) =>
    switch value
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_textSize(string value) =>
    switch value
        "Tiny" => 9
        "Small" => 11
        "Large" => 15
        => 13

f_appendEvent(string currentText, string newText) =>
    currentText == "" ? newText : currentText + "\n" + newText

f_compensatedAdd(float runningTotal, float correction, float value) =>
    float adjustedValue = value - correction
    float updatedTotal = runningTotal + adjustedValue
    float updatedCorrection = (updatedTotal - runningTotal) - adjustedValue
    [updatedTotal, updatedCorrection]

f_chartTypeText() =>
    switch
        chart.is_standard => "STANDARD"
        chart.is_heikinashi => "HEIKIN ASHI"
        chart.is_renko => "RENKO"
        chart.is_kagi => "KAGI"
        chart.is_linebreak => "LINE BREAK"
        chart.is_pnf => "POINT & FIGURE"
        chart.is_range => "RANGE"
        => "NON-STANDARD"

f_volumeTypeText() =>
    switch syminfo.volumetype
        "base" => "BASE"
        "quote" => "QUOTE"
        "tick" => "TICK"
        "n/a" => "N/A"
        => "OTHER"

f_percentText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

//------------------------------------------------------------------------------
// Numerically stable chart-volume engine
// Each anchor owns independent compensated numerator and denominator totals.
// This avoids subtracting two very large chart-wide cumulative values when an
// anchor is recent. Realtime rollback makes each forming bar contribute its
// current cumulative volume exactly once per execution.
//------------------------------------------------------------------------------
bool chartTypeAllowed = chart.is_standard or allowNonStandardCharts
float chartWeight = chartTypeAllowed and not na(vwapSource) and not na(volume) and volume > 0 ? volume : 0.0
float weightedPrice = chartWeight > 0 ? vwapSource * chartWeight : 0.0
int usableBarFlag = chartWeight > 0 ? 1 : 0
float atrValue = ta.atr(atrLength)
float volumeForAverage = not na(volume) and volume >= 0 ? volume : na
float relativeVolumeBasis = ta.sma(volumeForAverage, relativeVolumeLength)
var int datasetFirstTime = time

//------------------------------------------------------------------------------
// Visible-window research scope
// chart.left_visible_bar_time and chart.right_visible_bar_time force a full
// recalculation whenever the user scrolls or zooms. Calculations continue over
// all loaded bars for mathematical continuity, while plots, drawings, endpoint
// symbols, data-integrity statistics, and the status panel focus exclusively on
// the currently visible horizontal chart range.
//------------------------------------------------------------------------------
int visibleLeftTime = chart.left_visible_bar_time
int visibleRightTime = chart.right_visible_bar_time
bool barInVisibleWindow = time >= visibleLeftTime and time <= visibleRightTime
bool barIsVisibleRightEdge = time == visibleRightTime
bool viewportIncludesLatestBar = visibleRightTime == last_bar_time

var int visibleBarsObserved = 0
var int visibleUsableBars = 0
var int visibleManualObservedBars = 0
var int visibleManualUsableBars = 0
var int visibleHighObservedBars = 0
var int visibleHighUsableBars = 0
var int visibleLowObservedBars = 0
var int visibleLowUsableBars = 0

//------------------------------------------------------------------------------
// Manual anchor state
// A selected time earlier than the loaded dataset is blocked. This prevents a
// silent substitution of the first loaded bar for an unavailable true origin.
//------------------------------------------------------------------------------
var bool manualStarted = false
var int manualAnchorBar = na
var int manualActualAnchorTime = na
var float manualWeightedSum = 0.0
var float manualWeightedCorrection = 0.0
var float manualWeightSum = 0.0
var float manualWeightCorrection = 0.0
var label manualOriginLabel = na

bool manualAnchorBeforeDataset = manualAnchorTimeInput < datasetFirstTime
bool manualStartsNow = showManual and chartTypeAllowed and not manualAnchorBeforeDataset and not manualStarted and time >= manualAnchorTimeInput

if manualStartsNow
    manualStarted := true
    manualAnchorBar := bar_index
    manualActualAnchorTime := time
    manualWeightedSum := weightedPrice
    manualWeightedCorrection := 0.0
    manualWeightSum := chartWeight
    manualWeightCorrection := 0.0

    if showAnchorMarkers and barInVisibleWindow
        if not na(manualOriginLabel)
            label.delete(manualOriginLabel)
        manualOriginLabel := label.new(
             x = manualAnchorBar,
             y = manualAnchorPriceInput,
             text = "M",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             color = manualColor,
             style = label.style_label_left,
             textcolor = color.rgb(5, 8, 15),
             size = size.small,
             text_formatting = text.format_bold,
             tooltip = "Manual anchor point\nThe selected time starts the AVWAP.\nThe selected price positions this marker only.")
else if manualStarted
    [nextManualWeightedSum, nextManualWeightedCorrection] = f_compensatedAdd(manualWeightedSum, manualWeightedCorrection, weightedPrice)
    [nextManualWeightSum, nextManualWeightCorrection] = f_compensatedAdd(manualWeightSum, manualWeightCorrection, chartWeight)
    manualWeightedSum := nextManualWeightedSum
    manualWeightedCorrection := nextManualWeightedCorrection
    manualWeightSum := nextManualWeightSum
    manualWeightCorrection := nextManualWeightCorrection

float manualAvwap = manualStarted and manualWeightSum > 0 ? manualWeightedSum / manualWeightSum : na

//------------------------------------------------------------------------------
// Confirmed pivot candidates and acceptance filters
// The completed left/right pivot window is used for local prominence.
//------------------------------------------------------------------------------
int pivotWindow = swingLeft + swingRight + 1
float confirmedHigh = ta.pivothigh(high, swingLeft, swingRight)
float confirmedLow = ta.pivotlow(low, swingLeft, swingRight)
float localWindowLow = ta.lowest(low, pivotWindow)
float localWindowHigh = ta.highest(high, pivotWindow)
float pivotAtr = atrValue[swingRight]
float pivotVolume = volume[swingRight]
float pivotVolumeMean = relativeVolumeBasis[swingRight]
float pivotRelativeVolume = not na(pivotVolume) and not na(pivotVolumeMean) and pivotVolumeMean > 0 ? pivotVolume / pivotVolumeMean : na
float highProminenceAtr = not na(confirmedHigh) and not na(pivotAtr) and pivotAtr > 0 ? (confirmedHigh - localWindowLow) / pivotAtr : na
float lowProminenceAtr = not na(confirmedLow) and not na(pivotAtr) and pivotAtr > 0 ? (localWindowHigh - confirmedLow) / pivotAtr : na
int candidateAnchorBar = bar_index - swingRight
int candidateAnchorTime = time[swingRight]

var int highAnchorBar = na
var int highAnchorTime = na
var int highAnchorSerial = 0
var float highAnchorPrice = na
var float highAnchorProminence = na
var float highWeightedSum = 0.0
var float highWeightedCorrection = 0.0
var float highWeightSum = 0.0
var float highWeightCorrection = 0.0

var int lowAnchorBar = na
var int lowAnchorTime = na
var int lowAnchorSerial = 0
var float lowAnchorPrice = na
var float lowAnchorProminence = na
var float lowWeightedSum = 0.0
var float lowWeightedCorrection = 0.0
var float lowWeightSum = 0.0
var float lowWeightCorrection = 0.0

bool highCandidate = not na(confirmedHigh)
bool lowCandidate = not na(confirmedLow)
bool relativeVolumePass = not useRelativeVolumeFilter or (not na(pivotRelativeVolume) and pivotRelativeVolume >= minimumRelativeVolume)
bool highProminencePass = highCandidate and not na(highProminenceAtr) and highProminenceAtr >= minimumProminenceAtr
bool lowProminencePass = lowCandidate and not na(lowProminenceAtr) and lowProminenceAtr >= minimumProminenceAtr
bool highCooldownPass = na(highAnchorBar) or candidateAnchorBar - highAnchorBar >= minimumBarsBetweenSameType
bool lowCooldownPass = na(lowAnchorBar) or candidateAnchorBar - lowAnchorBar >= minimumBarsBetweenSameType
bool highReplacementPass = na(highAnchorBar) or replacementPolicy == "Latest qualified" or (replacementPolicy == "More prominent only" and highProminenceAtr >= highAnchorProminence + prominenceImprovementAtr) or (replacementPolicy == "New price extreme only" and confirmedHigh > highAnchorPrice)
bool lowReplacementPass = na(lowAnchorBar) or replacementPolicy == "Latest qualified" or (replacementPolicy == "More prominent only" and lowProminenceAtr >= lowAnchorProminence + prominenceImprovementAtr) or (replacementPolicy == "New price extreme only" and confirmedLow < lowAnchorPrice)
bool acceptHighAnchor = barstate.isconfirmed and chartTypeAllowed and showSwingHigh and highCandidate and highProminencePass and relativeVolumePass and highCooldownPass and highReplacementPass
bool acceptLowAnchor = barstate.isconfirmed and chartTypeAllowed and showSwingLow and lowCandidate and lowProminencePass and relativeVolumePass and lowCooldownPass and lowReplacementPass

var array<label> originMarkerLabels = array.new<label>()
var array<label> confirmationMarkerLabels = array.new<label>()
var array<line> confirmationBridgeLines = array.new<line>()

// A historical viewport must never receive labels from pivots that were only
// confirmed after the viewport's right edge. These predicates retain the
// original confirmation semantics and prevent future-derived drawings from
// leaking backward into historical research.
bool confirmationKnownByVisibleRight = time <= visibleRightTime
bool candidateOriginInVisibleWindow = not na(candidateAnchorTime) and candidateAnchorTime >= visibleLeftTime and candidateAnchorTime <= visibleRightTime
bool confirmationInVisibleWindow = barInVisibleWindow
bool confirmationBridgeIntersectsVisibleWindow = confirmationKnownByVisibleRight and not na(candidateAnchorTime) and candidateAnchorTime <= visibleRightTime and time >= visibleLeftTime

if acceptHighAnchor
    highAnchorBar := candidateAnchorBar
    highAnchorTime := candidateAnchorTime
    highAnchorPrice := confirmedHigh
    highAnchorProminence := highProminenceAtr
    highAnchorSerial += 1

    float highSeedWeightedSum = 0.0
    float highSeedWeightedCorrection = 0.0
    float highSeedWeightSum = 0.0
    float highSeedWeightCorrection = 0.0

    for seedOffset = swingRight to 0
        if not na(time[seedOffset])
            float seedWeightedValue = nz(weightedPrice[seedOffset], 0.0)
            float seedWeightedAdjusted = seedWeightedValue - highSeedWeightedCorrection
            float seedWeightedUpdated = highSeedWeightedSum + seedWeightedAdjusted
            highSeedWeightedCorrection := (seedWeightedUpdated - highSeedWeightedSum) - seedWeightedAdjusted
            highSeedWeightedSum := seedWeightedUpdated

            float seedWeightValue = nz(chartWeight[seedOffset], 0.0)
            float seedWeightAdjusted = seedWeightValue - highSeedWeightCorrection
            float seedWeightUpdated = highSeedWeightSum + seedWeightAdjusted
            highSeedWeightCorrection := (seedWeightUpdated - highSeedWeightSum) - seedWeightAdjusted
            highSeedWeightSum := seedWeightUpdated


    highWeightedSum := highSeedWeightedSum
    highWeightedCorrection := highSeedWeightedCorrection
    highWeightSum := highSeedWeightSum
    highWeightCorrection := highSeedWeightCorrection

    string highTooltip = "Confirmed swing-high AVWAP origin\nOrigin: " +
         str.format_time(candidateAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) +
         "\nProminence: " + str.tostring(highProminenceAtr, "#.##") + " ATR" +
         (useRelativeVolumeFilter ? "\nRelative volume: " + str.tostring(pivotRelativeVolume, "#.##") + "x" : "") +
         "\nConfirmed " + str.tostring(swingRight) + " bar(s) later."

    if showAnchorMarkers and confirmationKnownByVisibleRight and candidateOriginInVisibleWindow
        label highOriginMarker = label.new(
             x = candidateAnchorBar,
             y = confirmedHigh,
             text = "H",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             color = swingHighColor,
             style = label.style_label_down,
             textcolor = color.white,
             size = size.small,
             text_formatting = text.format_bold,
             tooltip = highTooltip)
        array.push(originMarkerLabels, highOriginMarker)

    if showConfirmationMarkers and confirmationInVisibleWindow
        label highConfirmationMarker = label.new(
             x = bar_index,
             y = confirmedHigh,
             text = confirmationMarkerStyle == "C badge" ? "C" : "",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             color = color.new(swingHighColor, confirmationMarkerStyle == "C badge" ? 12 : 0),
             style = confirmationMarkerStyle == "C badge" ? label.style_label_left : label.style_circle,
             textcolor = color.white,
             size = size.tiny,
             text_formatting = text.format_bold,
             tooltip = "Confirmation bar\nThe high-origin anchor becomes available only here.")
        array.push(confirmationMarkerLabels, highConfirmationMarker)

    if showConfirmationBridges and confirmationBridgeIntersectsVisibleWindow
        line highBridge = line.new(
             x1 = candidateAnchorBar,
             y1 = confirmedHigh,
             x2 = bar_index,
             y2 = confirmedHigh,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(swingHighColor, 35),
             style = line.style_dotted,
             width = 2)
        array.push(confirmationBridgeLines, highBridge)
else if not na(highAnchorBar)
    [nextHighWeightedSum, nextHighWeightedCorrection] = f_compensatedAdd(highWeightedSum, highWeightedCorrection, weightedPrice)
    [nextHighWeightSum, nextHighWeightCorrection] = f_compensatedAdd(highWeightSum, highWeightCorrection, chartWeight)
    highWeightedSum := nextHighWeightedSum
    highWeightedCorrection := nextHighWeightedCorrection
    highWeightSum := nextHighWeightSum
    highWeightCorrection := nextHighWeightCorrection

if acceptLowAnchor
    lowAnchorBar := candidateAnchorBar
    lowAnchorTime := candidateAnchorTime
    lowAnchorPrice := confirmedLow
    lowAnchorProminence := lowProminenceAtr
    lowAnchorSerial += 1

    float lowSeedWeightedSum = 0.0
    float lowSeedWeightedCorrection = 0.0
    float lowSeedWeightSum = 0.0
    float lowSeedWeightCorrection = 0.0

    for seedOffset = swingRight to 0
        if not na(time[seedOffset])
            float seedWeightedValue = nz(weightedPrice[seedOffset], 0.0)
            float seedWeightedAdjusted = seedWeightedValue - lowSeedWeightedCorrection
            float seedWeightedUpdated = lowSeedWeightedSum + seedWeightedAdjusted
            lowSeedWeightedCorrection := (seedWeightedUpdated - lowSeedWeightedSum) - seedWeightedAdjusted
            lowSeedWeightedSum := seedWeightedUpdated

            float seedWeightValue = nz(chartWeight[seedOffset], 0.0)
            float seedWeightAdjusted = seedWeightValue - lowSeedWeightCorrection
            float seedWeightUpdated = lowSeedWeightSum + seedWeightAdjusted
            lowSeedWeightCorrection := (seedWeightUpdated - lowSeedWeightSum) - seedWeightAdjusted
            lowSeedWeightSum := seedWeightUpdated


    lowWeightedSum := lowSeedWeightedSum
    lowWeightedCorrection := lowSeedWeightedCorrection
    lowWeightSum := lowSeedWeightSum
    lowWeightCorrection := lowSeedWeightCorrection

    string lowTooltip = "Confirmed swing-low AVWAP origin\nOrigin: " +
         str.format_time(candidateAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) +
         "\nProminence: " + str.tostring(lowProminenceAtr, "#.##") + " ATR" +
         (useRelativeVolumeFilter ? "\nRelative volume: " + str.tostring(pivotRelativeVolume, "#.##") + "x" : "") +
         "\nConfirmed " + str.tostring(swingRight) + " bar(s) later."

    if showAnchorMarkers and confirmationKnownByVisibleRight and candidateOriginInVisibleWindow
        label lowOriginMarker = label.new(
             x = candidateAnchorBar,
             y = confirmedLow,
             text = "L",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             color = swingLowColor,
             style = label.style_label_up,
             textcolor = color.rgb(5, 8, 15),
             size = size.small,
             text_formatting = text.format_bold,
             tooltip = lowTooltip)
        array.push(originMarkerLabels, lowOriginMarker)

    if showConfirmationMarkers and confirmationInVisibleWindow
        label lowConfirmationMarker = label.new(
             x = bar_index,
             y = confirmedLow,
             text = confirmationMarkerStyle == "C badge" ? "C" : "",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             color = color.new(swingLowColor, confirmationMarkerStyle == "C badge" ? 12 : 0),
             style = confirmationMarkerStyle == "C badge" ? label.style_label_left : label.style_circle,
             textcolor = color.rgb(5, 8, 15),
             size = size.tiny,
             text_formatting = text.format_bold,
             tooltip = "Confirmation bar\nThe low-origin anchor becomes available only here.")
        array.push(confirmationMarkerLabels, lowConfirmationMarker)

    if showConfirmationBridges and confirmationBridgeIntersectsVisibleWindow
        line lowBridge = line.new(
             x1 = candidateAnchorBar,
             y1 = confirmedLow,
             x2 = bar_index,
             y2 = confirmedLow,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(swingLowColor, 35),
             style = line.style_dotted,
             width = 2)
        array.push(confirmationBridgeLines, lowBridge)
else if not na(lowAnchorBar)
    [nextLowWeightedSum, nextLowWeightedCorrection] = f_compensatedAdd(lowWeightedSum, lowWeightedCorrection, weightedPrice)
    [nextLowWeightSum, nextLowWeightCorrection] = f_compensatedAdd(lowWeightSum, lowWeightCorrection, chartWeight)
    lowWeightedSum := nextLowWeightedSum
    lowWeightedCorrection := nextLowWeightedCorrection
    lowWeightSum := nextLowWeightSum
    lowWeightCorrection := nextLowWeightCorrection

while array.size(originMarkerLabels) > markerHistory
    label.delete(array.shift(originMarkerLabels))

while array.size(confirmationMarkerLabels) > markerHistory
    label.delete(array.shift(confirmationMarkerLabels))

while array.size(confirmationBridgeLines) > markerHistory
    line.delete(array.shift(confirmationBridgeLines))

//------------------------------------------------------------------------------
// Automatic AVWAP values
// Each replacement is seeded with the actual pivot-through-confirmation bars.
// The plot is deliberately broken on the confirmation bar, so it never joins
// the old anchor to the new anchor or backfills a curve into unknowable history.
//------------------------------------------------------------------------------
float highAvwap = not na(highAnchorBar) and highWeightSum > 0 ? highWeightedSum / highWeightSum : na
float lowAvwap = not na(lowAnchorBar) and lowWeightSum > 0 ? lowWeightedSum / lowWeightSum : na

// The manual AVWAP is a real analytical curve, not a visible-range boundary.
// By default it is suppressed when its selected origin lies outside the current
// viewport, preventing an off-screen anchor from creating an unexplained cyan
// line across the top or bottom of a historical research view. Users can opt
// out of this viewport rule from the Manual Anchor settings when needed.
bool manualOriginInVisibleWindow = manualStarted and not na(manualActualAnchorTime) and manualActualAnchorTime >= visibleLeftTime and manualActualAnchorTime <= visibleRightTime
bool manualHiddenByViewport = showManual and hideManualWhenOriginOutsideView and manualStarted and not manualOriginInVisibleWindow
bool manualVisibleInViewport = showManual and (not hideManualWhenOriginOutsideView or manualOriginInVisibleWindow)

// Visible-range coverage is measured only across bars currently on screen.
// Per-anchor coverage counts only visible bars on which that anchor was active.
if barInVisibleWindow
    visibleBarsObserved += 1
    visibleUsableBars += usableBarFlag

    if manualVisibleInViewport and manualStarted
        visibleManualObservedBars += 1
        visibleManualUsableBars += usableBarFlag

    if showSwingHigh and not na(highAnchorBar)
        visibleHighObservedBars += 1
        visibleHighUsableBars += usableBarFlag

    if showSwingLow and not na(lowAnchorBar)
        visibleLowObservedBars += 1
        visibleLowUsableBars += usableBarFlag

float manualPlotValue = manualVisibleInViewport and barInVisibleWindow ? manualAvwap : na
float highPlotValue = showSwingHigh and barInVisibleWindow and not acceptHighAnchor ? highAvwap : na
float lowPlotValue = showSwingLow and barInVisibleWindow and not acceptLowAnchor ? lowAvwap : na

//------------------------------------------------------------------------------
// Swing-pair relationship model
//------------------------------------------------------------------------------
bool pairReady = showSwingHigh and showSwingLow and not na(highAvwap) and not na(lowAvwap)
float pairTop = pairReady ? math.max(highAvwap, lowAvwap) : na
float pairBottom = pairReady ? math.min(highAvwap, lowAvwap) : na
float pairMidpoint = pairReady ? (highAvwap + lowAvwap) * 0.5 : na
float pairSpreadAtr = pairReady and not na(atrValue) and atrValue > 0 ? math.abs(highAvwap - lowAvwap) / atrValue : na
bool aboveBoth = pairReady and contextSource > pairTop
bool belowBoth = pairReady and contextSource < pairBottom
bool pairConverged = pairReady and not na(pairSpreadAtr) and pairSpreadAtr <= convergenceThresholdAtr
bool highOriginCurveAbove = pairReady and highAvwap > lowAvwap
bool highOriginCurveBelow = pairReady and highAvwap < lowAvwap
color dynamicPairFillColor = pairConverged ? color.new(pairEventColor, math.max(pairFillTransparency - 8, 0)) : aboveBoth ? color.new(swingLowColor, pairFillTransparency) : belowBoth ? color.new(swingHighColor, pairFillTransparency) : color.new(betweenColor, pairFillTransparency)

//------------------------------------------------------------------------------
// Confirmed events
// All event decisions are made on bar close.
//------------------------------------------------------------------------------
bool manualCrossUpRaw = ta.crossover(contextSource, manualAvwap)
bool manualCrossDownRaw = ta.crossunder(contextSource, manualAvwap)
bool highCrossUpRaw = ta.crossover(contextSource, highAvwap)
bool highCrossDownRaw = ta.crossunder(contextSource, highAvwap)
bool lowCrossUpRaw = ta.crossover(contextSource, lowAvwap)
bool lowCrossDownRaw = ta.crossunder(contextSource, lowAvwap)
bool pairOrderFlipRaw = ta.cross(highAvwap, lowAvwap)

bool manualCrossUp = barstate.isconfirmed and not manualStartsNow and manualCrossUpRaw
bool manualCrossDown = barstate.isconfirmed and not manualStartsNow and manualCrossDownRaw
bool stableHighAnchor = not acceptHighAnchor and highAnchorSerial == highAnchorSerial[1]
bool stableLowAnchor = not acceptLowAnchor and lowAnchorSerial == lowAnchorSerial[1]
bool highCrossUp = barstate.isconfirmed and stableHighAnchor and highCrossUpRaw
bool highCrossDown = barstate.isconfirmed and stableHighAnchor and highCrossDownRaw
bool lowCrossUp = barstate.isconfirmed and stableLowAnchor and lowCrossUpRaw
bool lowCrossDown = barstate.isconfirmed and stableLowAnchor and lowCrossDownRaw
bool pairWasReady = pairReady[1]
bool enteredAboveBoth = barstate.isconfirmed and pairWasReady and aboveBoth and not aboveBoth[1] and not acceptHighAnchor and not acceptLowAnchor
bool enteredBelowBoth = barstate.isconfirmed and pairWasReady and belowBoth and not belowBoth[1] and not acceptHighAnchor and not acceptLowAnchor
bool enteredConvergence = barstate.isconfirmed and pairWasReady and pairConverged and not pairConverged[1] and not acceptHighAnchor and not acceptLowAnchor
bool pairOrderFlip = barstate.isconfirmed and pairWasReady and stableHighAnchor and stableLowAnchor and pairOrderFlipRaw

//------------------------------------------------------------------------------
// Plots
// A dark halo, bright two-pixel body, and optional one-pixel precision core
// keep each AVWAP readable without making the chart visually heavy. Optional
// event symbols are disabled by default; active endpoint symbols identify the
// three current curves without covering their historical paths.
//------------------------------------------------------------------------------
highFillHandle = plot(
     showPairFill ? highPlotValue : na,
     title = "Swing-high fill handle",
     color = color.new(swingHighColor, 100),
     linewidth = 1,
     style = plot.style_linebr,
     display = display.pane)

lowFillHandle = plot(
     showPairFill ? lowPlotValue : na,
     title = "Swing-low fill handle",
     color = color.new(swingLowColor, 100),
     linewidth = 1,
     style = plot.style_linebr,
     display = display.pane)

fill(
     highFillHandle,
     lowFillHandle,
     color = showPairFill and pairReady ? dynamicPairFillColor : na,
     title = "Swing-origin pair fill",
     fillgaps = false)

float convergedPairSpineValue = showConvergedPairSpine and barInVisibleWindow and pairConverged and not acceptHighAnchor and not acceptLowAnchor ? pairMidpoint : na
color precisionCoreColor = color.new(color.white, precisionCoreTransparency)

plot(
     showContrastHalo ? manualPlotValue : na,
     title = "Manual AVWAP halo",
     color = color.new(haloColor, haloTransparency),
     linewidth = mainLineWidth + haloExtraWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     manualPlotValue,
     title = "Manual AVWAP",
     color = manualColor,
     linewidth = mainLineWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showPrecisionCore ? manualPlotValue : na,
     title = "Manual AVWAP precision core",
     color = precisionCoreColor,
     linewidth = 1,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showContrastHalo ? highPlotValue : na,
     title = "Swing-high AVWAP halo",
     color = color.new(haloColor, haloTransparency),
     linewidth = mainLineWidth + haloExtraWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     highPlotValue,
     title = "Swing-high AVWAP",
     color = swingHighColor,
     linewidth = mainLineWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showPrecisionCore ? highPlotValue : na,
     title = "Swing-high AVWAP precision core",
     color = precisionCoreColor,
     linewidth = 1,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showContrastHalo ? lowPlotValue : na,
     title = "Swing-low AVWAP halo",
     color = color.new(haloColor, haloTransparency),
     linewidth = mainLineWidth + haloExtraWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     lowPlotValue,
     title = "Swing-low AVWAP",
     color = swingLowColor,
     linewidth = mainLineWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showPrecisionCore ? lowPlotValue : na,
     title = "Swing-low AVWAP precision core",
     color = precisionCoreColor,
     linewidth = 1,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showContrastHalo ? convergedPairSpineValue : na,
     title = "Converged pair spine halo",
     color = color.new(haloColor, math.min(haloTransparency + 20, 100)),
     linewidth = mainLineWidth + haloExtraWidth,
     style = plot.style_linebr,
     display = display.pane)

plot(
     convergedPairSpineValue,
     title = "Converged pair spine",
     color = pairEventColor,
     linewidth = 2,
     style = plot.style_linebr,
     display = display.pane)

plot(
     showCrossMarkers and manualVisibleInViewport and barInVisibleWindow and (manualCrossUp or manualCrossDown) ? manualAvwap : na,
     title = "Manual AVWAP cross marker",
     color = manualColor,
     linewidth = eventMarkerWidth,
     style = plot.style_circles,
     display = display.pane)

plot(
     showCrossMarkers and barInVisibleWindow and (highCrossUp or highCrossDown) ? highAvwap : na,
     title = "Swing-high AVWAP cross marker",
     color = swingHighColor,
     linewidth = eventMarkerWidth,
     style = plot.style_circles,
     display = display.pane)

plot(
     showCrossMarkers and barInVisibleWindow and (lowCrossUp or lowCrossDown) ? lowAvwap : na,
     title = "Swing-low AVWAP cross marker",
     color = swingLowColor,
     linewidth = eventMarkerWidth,
     style = plot.style_circles,
     display = display.pane)

plot(
     showConvergenceMarkers and barInVisibleWindow and enteredConvergence ? pairMidpoint : na,
     title = "Swing-pair convergence marker",
     color = betweenColor,
     linewidth = math.min(eventMarkerWidth + 1, 6),
     style = plot.style_circles,
     display = display.pane)

plot(
     showPairOrderMarkers and barInVisibleWindow and pairOrderFlip ? pairMidpoint : na,
     title = "Swing-pair order-flip marker",
     color = pairEventColor,
     linewidth = eventMarkerWidth,
     style = plot.style_cross,
     display = display.pane)

plotshape(
     showActiveLineEndpoints and barIsVisibleRightEdge ? manualPlotValue : na,
     title = "Manual AVWAP active endpoint",
     style = shape.diamond,
     location = location.absolute,
     color = manualColor,
     size = size.tiny,
     display = display.pane)

plotshape(
     showActiveLineEndpoints and barIsVisibleRightEdge ? highPlotValue : na,
     title = "Swing-high AVWAP active endpoint",
     style = shape.triangledown,
     location = location.absolute,
     color = swingHighColor,
     size = size.tiny,
     display = display.pane)

plotshape(
     showActiveLineEndpoints and barIsVisibleRightEdge ? lowPlotValue : na,
     title = "Swing-low AVWAP active endpoint",
     style = shape.triangleup,
     location = location.absolute,
     color = swingLowColor,
     size = size.tiny,
     display = display.pane)

//------------------------------------------------------------------------------
// AVWAP origin status panel
// A narrow transparent right-side gutter leaves room for High/Low scale labels
// while keeping the visible panel firmly in the chart's upper-right corner.
//------------------------------------------------------------------------------
color panelLabelBackground = color.new(color.rgb(15, 23, 38), readoutTransparency)
color panelHeaderBackground = color.new(color.rgb(20, 31, 50), readoutTransparency)
color panelMuted = color.rgb(111, 128, 148)
color panelWarning = pairEventColor
color panelError = color.rgb(255, 74, 128)
color panelValid = color.rgb(57, 255, 136)

var table anchorReadout = table.new(
     f_tablePosition(readoutPositionInput),
     4,
     7,
     bgcolor = color.new(color.black, 100),
     frame_width = 0,
     border_width = 0)

if barstate.isfirst
    table.merge_cells(anchorReadout, 0, 0, 1, 0)

float manualCoveragePercent = visibleManualObservedBars > 0 ? float(visibleManualUsableBars) / visibleManualObservedBars * 100.0 : na
float highCoveragePercent = visibleHighObservedBars > 0 ? float(visibleHighUsableBars) / visibleHighObservedBars * 100.0 : na
float lowCoveragePercent = visibleLowObservedBars > 0 ? float(visibleLowUsableBars) / visibleLowObservedBars * 100.0 : na
float integrityCoveragePercent = visibleBarsObserved > 0 ? float(visibleUsableBars) / visibleBarsObserved * 100.0 : na

bool noUsableChartVolume = visibleBarsObserved > 0 and visibleUsableBars <= 0
bool usingCalculatedChartPrices = not chart.is_standard and allowNonStandardCharts
bool blockedChartType = not chart.is_standard and not allowNonStandardCharts
bool partialVolumeCoverage = not noUsableChartVolume and not na(integrityCoveragePercent) and integrityCoveragePercent < minimumVolumeCoveragePercent
bool historicalViewport = not viewportIncludesLatestBar
bool formingRealtimeBar = viewportIncludesLatestBar and barstate.isrealtime and not barstate.isconfirmed
bool paddedRightReadout = readoutPositionInput == "Top Right" or readoutPositionInput == "Bottom Right"
int effectiveRightPaddingPercent = paddedRightReadout ? readoutRightPaddingPercent : 0
int readoutTextSize = f_textSize(readoutSizeInput)
string chartTypeText = f_chartTypeText()
string volumeTypeText = f_volumeTypeText()
string visibleRangeText = str.format_time(visibleLeftTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " → " + str.format_time(visibleRightTime, "yyyy-MM-dd HH:mm", syminfo.timezone)

string runtimeStatusText = historicalViewport ? "● HISTORY" : formingRealtimeBar ? "● LIVE" : "● CLOSED"
color runtimeStatusColor = historicalViewport ? pairEventColor : formingRealtimeBar ? manualColor : panelMuted
color runtimeStatusTextColor = historicalViewport or formingRealtimeBar ? color.rgb(5, 8, 15) : color.white
string runtimeStatusTooltip = historicalViewport ? "Historical research view. All visible plots, endpoint symbols, status values, and integrity statistics are evaluated as of the rightmost visible bar: " + str.format_time(visibleRightTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + ". Later bars do not alter this panel." : formingRealtimeBar ? "The visible right edge is the developing realtime bar. AVWAP lines include its current cumulative price and volume, while close-only events and alerts remain unconfirmed until the bar closes." : "The visible right edge is the latest available confirmed bar. All panel values are evaluated at that bar."

string manualStateText = not showManual ? "HIDDEN" : blockedChartType ? "BLOCKED BY CHART TYPE" : manualAnchorBeforeDataset ? "OUTSIDE LOADED DATA" : not manualStarted ? "WAITING FOR TIME" : manualHiddenByViewport ? "ORIGIN OUTSIDE VIEW" : na(manualAvwap) ? "ORIGIN SET | NO VWAP" : str.tostring(manualAvwap, format.mintick) + " | " + str.tostring(bar_index - manualAnchorBar) + "b"
string highStateText = not showSwingHigh ? "HIDDEN" : blockedChartType ? "BLOCKED BY CHART TYPE" : na(highAnchorBar) ? "WAITING FOR HIGH" : na(highAvwap) ? str.tostring(highAnchorPrice, format.mintick) + " | NO VWAP" : str.tostring(highAvwap, format.mintick) + " | P" + str.tostring(highAnchorProminence, "#.##") + " | " + str.tostring(bar_index - highAnchorBar) + "b"
string lowStateText = not showSwingLow ? "HIDDEN" : blockedChartType ? "BLOCKED BY CHART TYPE" : na(lowAnchorBar) ? "WAITING FOR LOW" : na(lowAvwap) ? str.tostring(lowAnchorPrice, format.mintick) + " | NO VWAP" : str.tostring(lowAvwap, format.mintick) + " | P" + str.tostring(lowAnchorProminence, "#.##") + " | " + str.tostring(bar_index - lowAnchorBar) + "b"
string pairContextText = blockedChartType ? "UNAVAILABLE" : not pairReady ? "WAITING FOR H + L" : aboveBoth ? "ABOVE BOTH" : belowBoth ? "BELOW BOTH" : "BETWEEN AVWAPS"
string pairOrderText = not pairReady ? "n/a" : highOriginCurveAbove ? "H > L" : highOriginCurveBelow ? "H < L" : "H = L"
string pairSpreadText = not pairReady or na(pairSpreadAtr) ? "NOT AVAILABLE" : (pairConverged ? "CONVERGED " : "SEPARATED ") + str.tostring(pairSpreadAtr, "#.##") + " ATR | " + pairOrderText
string dataStateText = blockedChartType ? "BLOCKED | " + chartTypeText : noUsableChartVolume ? "NO VOLUME | STRICT" : usingCalculatedChartPrices ? "SYNTHETIC | " + f_percentText(integrityCoveragePercent) + " " + volumeTypeText : partialVolumeCoverage ? "PARTIAL | " + f_percentText(integrityCoveragePercent) + " " + volumeTypeText : "READY | " + f_percentText(integrityCoveragePercent) + " " + volumeTypeText

color manualValueBackground = color.new(manualHiddenByViewport or na(manualAvwap) ? panelMuted : manualColor, manualHiddenByViewport or na(manualAvwap) ? 78 : 82)
color highValueBackground = color.new(na(highAvwap) ? panelMuted : swingHighColor, na(highAvwap) ? 78 : 82)
color lowValueBackground = color.new(na(lowAvwap) ? panelMuted : swingLowColor, na(lowAvwap) ? 78 : 82)
color pairContextColor = aboveBoth ? swingLowColor : belowBoth ? swingHighColor : pairReady ? betweenColor : panelMuted
color pairStateColor = pairReady ? (pairConverged ? betweenColor : panelWarning) : panelMuted
bool dataStateReady = not blockedChartType and not noUsableChartVolume and not usingCalculatedChartPrices and not partialVolumeCoverage
bool dataStateCaution = not blockedChartType and not noUsableChartVolume and (usingCalculatedChartPrices or partialVolumeCoverage)
color dataStateColor = blockedChartType or noUsableChartVolume ? panelError : dataStateCaution ? panelWarning : panelValid
color contextBadgeTextColor = aboveBoth ? color.rgb(5, 8, 15) : color.white
color pairBadgeTextColor = pairReady and not pairConverged ? color.rgb(5, 8, 15) : color.white
color dataBadgeTextColor = dataStateReady or dataStateCaution ? color.rgb(5, 8, 15) : color.white
string dataBadgeText = dataStateReady ? "✓" : "!"

string manualReadoutTooltip = manualAnchorBeforeDataset ? "The selected manual time is earlier than the first bar in the loaded dataset. The script blocks the manual AVWAP rather than silently substituting the first loaded bar." : not manualStarted ? "The manual AVWAP begins on the first loaded bar whose opening time is at or after the selected time." : manualHiddenByViewport ? "The manual AVWAP is intentionally hidden because its selected origin is outside the current visible time range. This prevents an off-screen manual anchor from appearing as an unexplained cyan line. Disable Hide manual AVWAP when origin is outside view to keep it visible." : "Requested time: " + str.format_time(manualAnchorTimeInput, "yyyy-MM-dd HH:mm", syminfo.timezone) + "\nFirst included bar: " + str.format_time(manualActualAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + "\nMarker price: " + str.tostring(manualAnchorPriceInput, format.mintick) + "\nVisible-window volume coverage while active: " + f_percentText(manualCoveragePercent) + "\nEvaluated at visible right edge: " + str.format_time(visibleRightTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + "\nThe marker price does not affect the calculation."
string highReadoutTooltip = na(highAnchorBar) ? "Waiting, as of the visible right edge, for a high pivot that satisfies the confirmation, prominence, spacing, replacement, and optional volume filters." : "High origin: " + str.format_time(highAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + "\nOrigin price: " + str.tostring(highAnchorPrice, format.mintick) + "\nProminence: " + str.tostring(highAnchorProminence, "#.##") + " ATR\nVisible-window volume coverage while active: " + f_percentText(highCoveragePercent) + "\nThe origin became available " + str.tostring(swingRight) + " bar(s) later.\nEvaluated at visible right edge: " + str.format_time(visibleRightTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
string lowReadoutTooltip = na(lowAnchorBar) ? "Waiting, as of the visible right edge, for a low pivot that satisfies the confirmation, prominence, spacing, replacement, and optional volume filters." : "Low origin: " + str.format_time(lowAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + "\nOrigin price: " + str.tostring(lowAnchorPrice, format.mintick) + "\nProminence: " + str.tostring(lowAnchorProminence, "#.##") + " ATR\nVisible-window volume coverage while active: " + f_percentText(lowCoveragePercent) + "\nThe origin became available " + str.tostring(swingRight) + " bar(s) later.\nEvaluated at visible right edge: " + str.format_time(visibleRightTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
string pairContextTooltip = "Classifies the selected context source against the two automatic AVWAP curves at the rightmost visible bar. It is a factual location state, not a trade direction."
string pairStateTooltip = "Shows ATR-normalized separation and curve order at the rightmost visible bar. H > L means the high-origin AVWAP is above the low-origin AVWAP."
string dataReadoutTooltip = "Visible range: " + visibleRangeText + "\nVisible bars measured: " + str.tostring(visibleBarsObserved) + "\nChart type: " + chartTypeText + "\nVolume type: " + volumeTypeText + "\nVisible-window volume coverage: " + f_percentText(integrityCoveragePercent) + "\nREADY means the configured coverage threshold is met within the visible range; it is not a data-provider certification.\nMissing or zero volume receives zero weight. The script never substitutes equal bar weighting."

if barIsVisibleRightEdge
    if showReadout
        for readoutRow = 0 to 6
            table.cell(
                 anchorReadout,
                 3,
                 readoutRow,
                 "",
                 width = effectiveRightPaddingPercent,
                 bgcolor = color.new(color.black, 100))

        table.cell(anchorReadout, 0, 0, "AVWAP ORIGIN STATUS", text_color = color.white, text_size = readoutTextSize + 1, text_halign = text.align_center, bgcolor = panelHeaderBackground, text_formatting = text.format_bold, tooltip = "Plots, drawings, endpoint symbols, data-integrity statistics, and panel values follow the current visible chart range. The panel is evaluated at its rightmost visible bar. Automatic anchor replacement, event markers, and alerts still confirm only at bar close.")
        table.cell(anchorReadout, 2, 0, runtimeStatusText, text_color = runtimeStatusTextColor, text_size = readoutTextSize, text_halign = text.align_center, bgcolor = runtimeStatusColor, text_formatting = text.format_bold, tooltip = runtimeStatusTooltip)

        table.cell(anchorReadout, 0, 1, "◆", width = 3, text_color = color.rgb(5, 8, 15), text_size = readoutTextSize, text_halign = text.align_center, bgcolor = manualColor, text_formatting = text.format_bold, tooltip = "Manual anchor")
        table.cell(anchorReadout, 1, 1, "Manual anchor", text_color = manualColor, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = panelLabelBackground, text_formatting = text.format_bold)
        table.cell(anchorReadout, 2, 1, manualStateText, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = manualValueBackground, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = manualReadoutTooltip)

        table.cell(anchorReadout, 0, 2, "▲", width = 3, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_center, bgcolor = swingHighColor, text_formatting = text.format_bold, tooltip = "Confirmed swing-high origin")
        table.cell(anchorReadout, 1, 2, "High origin", text_color = swingHighColor, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = panelLabelBackground, text_formatting = text.format_bold)
        table.cell(anchorReadout, 2, 2, highStateText, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = highValueBackground, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = highReadoutTooltip)

        table.cell(anchorReadout, 0, 3, "▼", width = 3, text_color = color.rgb(5, 8, 15), text_size = readoutTextSize, text_halign = text.align_center, bgcolor = swingLowColor, text_formatting = text.format_bold, tooltip = "Confirmed swing-low origin")
        table.cell(anchorReadout, 1, 3, "Low origin", text_color = swingLowColor, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = panelLabelBackground, text_formatting = text.format_bold)
        table.cell(anchorReadout, 2, 3, lowStateText, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = lowValueBackground, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = lowReadoutTooltip)

        table.cell(anchorReadout, 0, 4, "●", width = 3, text_color = contextBadgeTextColor, text_size = readoutTextSize, text_halign = text.align_center, bgcolor = pairContextColor, text_formatting = text.format_bold, tooltip = "Price context")
        table.cell(anchorReadout, 1, 4, "Price context", text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = panelLabelBackground, text_formatting = text.format_bold)
        table.cell(anchorReadout, 2, 4, pairContextText, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = color.new(pairContextColor, 74), text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = pairContextTooltip)

        table.cell(anchorReadout, 0, 5, "↔", width = 3, text_color = pairBadgeTextColor, text_size = readoutTextSize, text_halign = text.align_center, bgcolor = pairStateColor, text_formatting = text.format_bold, tooltip = "Swing-origin AVWAP relationship")
        table.cell(anchorReadout, 1, 5, "Pair relation", text_color = panelWarning, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = panelLabelBackground, text_formatting = text.format_bold)
        table.cell(anchorReadout, 2, 5, pairSpreadText, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = color.new(pairStateColor, 74), text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = pairStateTooltip)

        table.cell(anchorReadout, 0, 6, dataBadgeText, width = 3, text_color = dataBadgeTextColor, text_size = readoutTextSize, text_halign = text.align_center, bgcolor = dataStateColor, text_formatting = text.format_bold, tooltip = "Chart and volume data status")
        table.cell(anchorReadout, 1, 6, "Data integrity", text_color = dataStateColor, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = panelLabelBackground, text_formatting = text.format_bold)
        table.cell(anchorReadout, 2, 6, dataStateText, text_color = color.white, text_size = readoutTextSize, text_halign = text.align_left, bgcolor = color.new(dataStateColor, 72), text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = dataReadoutTooltip)
    else
        table.clear(anchorReadout, 0, 0, 3, 6)

//------------------------------------------------------------------------------
// Dynamic single-condition alerts
//------------------------------------------------------------------------------
if enableAlerts and barstate.isconfirmed
    string symbolPrefix = syminfo.tickerid + " | " + timeframe.period + " | "
    string eventMessage = ""

    if alertOnNewAnchors and acceptHighAnchor
        string highWeightStatus = highWeightSum > 0 ? "weighted AVWAP active" : "origin recorded; no usable volume yet"
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "New confirmed swing-high AVWAP anchor | origin " + str.format_time(highAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " | price " + str.tostring(highAnchorPrice, format.mintick) + " | prominence " + str.tostring(highAnchorProminence, "#.##") + " ATR | " + highWeightStatus)

    if alertOnNewAnchors and acceptLowAnchor
        string lowWeightStatus = lowWeightSum > 0 ? "weighted AVWAP active" : "origin recorded; no usable volume yet"
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "New confirmed swing-low AVWAP anchor | origin " + str.format_time(lowAnchorTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " | price " + str.tostring(lowAnchorPrice, format.mintick) + " | prominence " + str.tostring(lowAnchorProminence, "#.##") + " ATR | " + lowWeightStatus)

    if alertOnPriceCrosses and manualCrossUp
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price closed above manual AVWAP | AVWAP " + str.tostring(manualAvwap, format.mintick))

    if alertOnPriceCrosses and manualCrossDown
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price closed below manual AVWAP | AVWAP " + str.tostring(manualAvwap, format.mintick))

    if alertOnPriceCrosses and highCrossUp
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price closed above swing-high-origin AVWAP | AVWAP " + str.tostring(highAvwap, format.mintick))

    if alertOnPriceCrosses and highCrossDown
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price closed below swing-high-origin AVWAP | AVWAP " + str.tostring(highAvwap, format.mintick))

    if alertOnPriceCrosses and lowCrossUp
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price closed above swing-low-origin AVWAP | AVWAP " + str.tostring(lowAvwap, format.mintick))

    if alertOnPriceCrosses and lowCrossDown
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price closed below swing-low-origin AVWAP | AVWAP " + str.tostring(lowAvwap, format.mintick))

    if alertOnPairTransitions and enteredAboveBoth
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price entered above-both swing AVWAP context")

    if alertOnPairTransitions and enteredBelowBoth
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Price entered below-both swing AVWAP context")

    if alertOnConvergence and enteredConvergence
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Swing-origin AVWAP pair entered convergence | spread " + str.tostring(pairSpreadAtr, "#.##") + " ATR")

    if alertOnPairOrderFlip and pairOrderFlip
        eventMessage := f_appendEvent(eventMessage, symbolPrefix + "Swing-origin AVWAP order flipped | " + pairOrderText)

    if eventMessage != ""
        alert(eventMessage, alert.freq_once_per_bar_close)
````
