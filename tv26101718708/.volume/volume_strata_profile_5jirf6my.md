# Volume Strata Profile

- url: https://www.tradingview.com/script/5jirf6MY-Volume-Strata-Profile/
- type: indicator
- pine_id: PUB;5d26639de99a430fbc7d5d067960c27b
- version: 10.0

## Description

Volume Strata Profile (VSP) is a volume-at-price analysis tool designed to add a chronological dimension to the traditional Volume Profile.
A conventional Volume Profile shows where trading activity accumulated across price, but it does not clearly show when that volume was built. VSP addresses this by dividing the selected lookback period into chronological time strata and displaying each stratum inside the same price-row profile.
This makes it possible to distinguish older accepted-value areas from newer ones, track how the Point of Control changes through time, identify historical high-volume areas that are no longer receiving meaningful recent participation, and evaluate whether value is migrating higher, lower, or remaining relatively balanced.

[b]Core Concept[/b]
The selected lookback is divided into multiple chronological strata.
The default color progression is:
- Indigo: oldest activity
- Teal: intermediate activity
- Amber: newest activity
Within each price row, volume from the individual strata is stacked horizontally. The result shows both:
- where estimated volume accumulated, and
- when that volume entered the profile.
This chronological structure is the primary difference between VSP and a conventional single-layer Volume Profile.
Intrabar Volume Engine
VSP uses lower-timeframe OHLCV data through Pine Script's intrabar functionality whenever it is available.
Instead of assigning the entire volume of a chart bar across that bar's complete High-Low range, the indicator decomposes the chart bar into available lower-timeframe bars and processes their smaller price ranges individually.
For example, on a Daily chart the adaptive engine may use 5-minute data when the available intrabar budget permits it.
The automatic resolution engine selects the finest practical lower timeframe while respecting the available intrabar-data budget.
Users can also manually choose the lower timeframe.
TradingView's own Volume Profile methodology also uses lower-timeframe information to improve price-level resolution. VSP uses its own custom intrabar allocation and chronological-strata model. TradingView
Adaptive Intrabar Resolution
When Intrabar Timeframe is set to Auto, VSP evaluates the chart timeframe, lookback length, and requested intrabar budget.
The High precision mode prioritizes the finest practical intrabar resolution within a maximum 100,000-bar request budget.
Balanced mode uses a smaller approximate budget to reduce processing requirements.
The indicator also measures the quality of the retrieved intrabar dataset using:
- Intrabar coverage
- Average intrabars per covered chart bar
- Maximum observed intrabars per chart bar
- Density adequacy
- Fallback chart-bar count
These metrics are used internally to prevent poor intrabar coverage from producing unjustifiably high confidence readings.
TradingView limits the amount of lower-timeframe history available to scripts depending on the user's plan. TradingView
Composite POC and Value Area
VSP calculates a Composite Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL).
POC represents the price row containing the greatest estimated volume across the complete analysis window.
The Value Area is constructed outward from the POC until the selected percentage of total profile volume is included. The default setting is 70%.
TradingView also commonly defines the Value Area as the region containing the selected percentage of profile volume, with 70% being a commonly used default. TradingView
Value Migration Spine
The colored points displayed to the right of the profile represent the POC of each chronological stratum.
The points are connected from oldest to newest, producing the Value Migration Spine.
This allows the user to visually inspect how the market's estimated accepted-value concentration moved through time.
An upward migration indicates that later strata developed their highest-volume concentrations at progressively higher prices.
A downward migration indicates the opposite.
This should not be interpreted as a prediction of future price direction.
It describes the historical migration of estimated value.
Developing POC
For each chronological layer, VSP also calculates a cumulative Developing POC.
The Developing POC represents the strongest cumulative volume row after adding each successive stratum.
It is available in the migration-point tooltips and provides a second view of how the broader profile developed.
Recent Acceptance POC
VSP independently calculates a Recent Acceptance POC from the most recent portion of the selected lookback.
This is compared with the newest stratum POC.
When both methods identify approximately the same price region, the indicator considers the most recent value concentration more internally consistent.
Value Migration Efficiency
Migration Efficiency measures how directly the stratum POCs moved from the oldest value location to the newest one.
A high reading means that most of the total POC movement occurred in a relatively consistent direction.
A low reading means the POCs moved back and forth considerably before reaching their latest location.
Migration Efficiency measures path consistency. It does not measure the probability of future price movement.
Activity Support
VSP compares average volume per chart bar in the newest stratum with average volume per chart bar across the complete profile.
The raw activity ratio remains visible in the tooltip.
A bounded normalization is then used internally so unusually large volume readings cannot increase confidence without limit.
Participation Balance
VSP compares the total volume of the newest stratum with the previous stratum.
Unlike a simple "higher volume is better" rule, the Participation Balance calculation measures comparability.
A ratio near 1.0 means the two strata contain reasonably comparable total participation.
Very large differences between adjacent strata reduce comparability because they may represent different liquidity, session, or volume regimes.
For example, an extreme newest-to-previous volume ratio is not treated as perfect confirmation simply because the newer period contains substantially more volume.

[b]Value Migration Confidence[/b]
Value Migration Confidence measures the internal reliability of the detected value migration.
It combines:
- Migration Efficiency
- Newest-layer Activity Support
- Participation Balance
- Recent Acceptance alignment
- Intrabar data quality
Poor intrabar quality imposes a confidence ceiling.
This value is specifically a confidence score for the observed value-migration structure.
It is not a probability that price will rise or fall.
Value Stability
Value Stability measures how dispersed the stratum POCs are relative to the complete profile range.
High stability means value remained concentrated within a relatively narrow region.
Low stability means value locations moved substantially throughout the analysis window.
Low stability can coexist with high Migration Efficiency. In that case, value moved significantly, but did so in a relatively orderly direction.
Stale High Volume Nodes

[b]VSP includes an adaptive Stale HVN engine.[/b]
A Stale High Volume Node is a historically important high-volume region that currently receives relatively little recent volume participation.
The engine evaluates:
- Historical row-volume strength
- Adaptive profile-relative HVN thresholds
- Recent volume share
- Nearby-row clustering
- Optional ATR-normalized distance from current price
Adjacent qualifying rows are grouped into logical clusters to avoid multiple redundant stale-HVN lines representing essentially the same historical value area.
When several stale clusters exist, the strongest candidates are prioritized.
Time Ribbon
The colored ribbon beneath the analyzed price range shows the chronological boundaries of the selected strata.
Its colors correspond directly to the colors used inside the profile and provide a visual reference for identifying which historical bars belong to each layer.
Inputs
Lookback bars
Controls the number of chart bars included in the analysis.
Price rows
Controls the vertical price resolution of the profile.
Time strata
Controls the number of chronological layers.
Value area %
Controls the percentage of total estimated volume included in the Value Area.
Use intrabar volume
Enables lower-timeframe volume analysis.
Intrabar timeframe
Selects Auto or a manual lower timeframe.
Auto precision
Controls how aggressively the automatic engine uses the intrabar-data budget.
Profile width / gap / transparency
Visual settings only. They do not modify the underlying calculations.
Adaptive HVN detection
Enables profile-relative statistical HVN filtering.
Recent window
Defines the recent portion of the lookback used for Stale HVNs and Recent Acceptance POC.
Cluster gap tolerance
Controls how nearby stale rows are grouped.
Stale distance filter
Optionally removes stale nodes located beyond the selected ATR-normalized distance.

[b]How to Use VSP[/b]
VSP is designed as a contextual volume-analysis tool rather than an entry/exit signal generator.
Useful observations include:
- Whether newer value is migrating above or below older value
- Whether current price is trading far from accepted value
- Whether recent activity confirms the newest stratum POC
- Whether the migration path is orderly or unstable
- Whether historically important high-volume areas have become inactive
- Whether price and accepted value are moving together or separating
A strong Value Migration Confidence reading means the value-migration structure is internally consistent.
It does not mean that future price direction is known with the same probability.
Originality
The distinguishing feature of VSP is the integration of chronological time strata directly inside a volume-at-price profile.
Rather than presenting volume as one aggregated distribution, the script retains the chronological origin of the estimated volume assigned to each price row.
The indicator then builds additional analysis around this structure, including:
- Stratum-specific POCs
- Value Migration Spine
- Developing POC
- Recent Acceptance POC
- Migration Efficiency
- Value Stability
- Adaptive Intrabar Quality
- Participation Balance
- Adaptive Stale HVN clustering
These components are designed specifically to analyze how accepted value changes through time rather than simply where aggregate volume accumulated.
Limitations
VSP does not have access to transaction-by-transaction Volume-at-Price.
Even when lower-timeframe data is used, each intrabar's volume must still be estimated across the price rows overlapped by that intrabar's High-Low range.
For this reason, the profile should not be interpreted as exchange-level order-flow data.
Lower-timeframe data availability depends on the symbol, market, TradingView data feed, and account plan.
Where lower-timeframe data is unavailable, the script can fall back to chart-bar OHLCV processing.
The active chart bar and its intrabars can change while they are forming.
Historical and realtime lower-timeframe feeds can also differ after a script reload because data providers may revise realtime data. TradingView explicitly notes that lower-timeframe requests are not immune to repainting behavior on realtime data. TradingView
Repainting and Realtime Behavior
The script does not intentionally use future data.
Historical calculations are based on available historical chart and intrabar data.
However, the active realtime bar is not final. Its High, Low, and Volume values, as well as the lower-timeframe bars contained within it, can change until they close.
Consequently, the current profile, newest stratum POC, Recent Acceptance POC, stale-node status, and migration metrics can update during the active bar.
Lower-timeframe data may also differ after a reload if TradingView's data provider revises previously realtime information. 

[b]Important[/b]
VSP is an analytical visualization tool.
It does not predict future prices, provide guaranteed trading signals, or guarantee profitable outcomes.
Volume Profile analysis is primarily reactive: it describes where trading activity occurred and how accepted value developed historically. TradingView similarly characterizes Volume Profile as primarily showing historical trading activity rather than forecasting future movement. TradingView
Use the indicator together with independent market analysis and appropriate risk management.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE
// Version: 2.1
// VSP Scoring Model: 2.2

//@version=6
indicator(
     "Volume Strata Profile v2.1",
     "VSP v2.1",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 120,
     max_labels_count = 80,
     max_bars_back = 3000,
     dynamic_requests = true
)

// ============================================================================
// CORE SERIES
// ============================================================================

float atr14 = ta.atr(14)


// ============================================================================
// INPUTS
// ============================================================================

// ---------------------------------------------------------------------------
// PROFILE RANGE
// ---------------------------------------------------------------------------

grpR = "PROFILE RANGE"

lookback = input.int(
     300,
     "Lookback bars",
     minval = 20,
     maxval = 3000,
     group = grpR,
     tooltip =
         "Number of chart bars used to construct the complete profile."
)

rowsN = input.int(
     45,
     "Price rows",
     minval = 10,
     maxval = 60,
     group = grpR,
     tooltip =
         "Number of horizontal price rows used by the profile."
)

strataN = input.int(
     5,
     "Time strata (layers)",
     minval = 2,
     maxval = 8,
     group = grpR,
     tooltip =
         "Divides the lookback period into chronological layers."
)

vaPct = input.float(
     70,
     "Value area %",
     minval = 10,
     maxval = 95,
     group = grpR,
     tooltip =
         "Percentage of estimated profile volume included inside the Value Area."
)


// ---------------------------------------------------------------------------
// INTRABAR VOLUME ENGINE
// ---------------------------------------------------------------------------

grpI = "INTRABAR VOLUME ENGINE"

useIntrabar = input.bool(
     true,
     "Use intrabar volume",
     group = grpI,
     tooltip =
         "Uses lower-timeframe OHLCV data to improve Volume-at-Price resolution."
)

ltfMode = input.string(
     "Auto",
     "Intrabar timeframe",
     options = [
         "Auto",
         "1",
         "3",
         "5",
         "15",
         "30",
         "60",
         "240",
         "1D"
     ],
     group = grpI,
     active = useIntrabar
)

autoPrecision = input.string(
     "High",
     "Auto precision",
     options = [
         "High",
         "Balanced"
     ],
     group = grpI,
     active = useIntrabar and ltfMode == "Auto"
)


// ---------------------------------------------------------------------------
// DISPLAY
// ---------------------------------------------------------------------------

grpD = "DISPLAY"

widthB = input.int(
     70,
     "Profile width (bars)",
     minval = 10,
     maxval = 200,
     group = grpD
)

gapB = input.int(
     8,
     "Gap from last bar",
     minval = 0,
     maxval = 100,
     group = grpD
)

transpIn = input.int(
     10,
     "Transparency inside VA",
     minval = 0,
     maxval = 90,
     group = grpD
)

transpOut = input.int(
     55,
     "Transparency outside VA",
     minval = 0,
     maxval = 95,
     group = grpD
)

showVA = input.bool(
     true,
     "POC + value area lines",
     group = grpD,
     tooltip =
         "Displays POC, VAH and VAL.\n\n" +
         "POC = highest-volume row.\n" +
         "VAH = Value Area High.\n" +
         "VAL = Value Area Low."
)

showMig = input.bool(
     true,
     "Value migration spine",
     group = grpD
)

showRib = input.bool(
     true,
     "Strata time ribbon",
     group = grpD
)

showSt = input.bool(
     true,
     "Mark stale HVNs",
     group = grpD,
     tooltip =
         "Shows historically important High Volume Nodes that currently have weak recent participation.\n\n" +
         "The distance filter keeps distant historical nodes from cluttering the chart."
)


// ---------------------------------------------------------------------------
// KEY LEVEL APPEARANCE
// ---------------------------------------------------------------------------

grpK = "KEY LEVEL APPEARANCE"

pocLineWidth = input.int(
     2,
     "POC line width",
     minval = 1,
     maxval = 4,
     group = grpK,
     tooltip =
         "POC is the most important volume level, so its default line is intentionally stronger."
)

vaLineWidth = input.int(
     2,
     "VAH / VAL line width",
     minval = 1,
     maxval = 4,
     group = grpK,
     tooltip =
         "Controls the visibility of the Value Area boundaries."
)


// ---------------------------------------------------------------------------
// SCREENING DASHBOARD
// ---------------------------------------------------------------------------

grpDB = "SCREENING DASHBOARD"

showDashboard = input.bool(
     true,
     "Show screening dashboard",
     group = grpDB,
     tooltip =
         "Displays the screening dashboard in the top-right corner.\n\n" +
         "Green = confirmed.\n" +
         "Yellow = watch / intermediate.\n" +
         "Red = not confirmed."
)

dashActivityRatioMin = input.float(
     1.10,
     "Minimum Activity Expansion (x)",
     minval = 0.50,
     maxval = 3.00,
     step = 0.05,
     group = grpDB,
     active = showDashboard,
     tooltip =
         "Newest-stratum volume per bar divided by average profile volume per bar. 1.10 means activity is at least 10% above average."
)

pocToleranceRows = input.int(
     1,
     "POC noise tolerance (rows)",
     minval = 0,
     maxval = 3,
     group = grpDB,
     active = showDashboard,
     tooltip =
         "POC changes inside this row tolerance are treated as noise rather than a confirmed directional shift."
)

dashQualityMin = input.float(
     70,
     "Minimum Intrabar Quality % (gate)",
     minval = 0,
     maxval = 100,
     step = 5,
     group = grpDB,
     active = showDashboard,
     tooltip =
         "Data-quality gate only. It does not add a point to the VSP Structure Score. When intrabar data is available, quality is measured on the newest three strata used by the rotation model. Chart-bar mode is allowed when lower-timeframe data is not applicable."
)

dashNearVahAtr = input.float(
     0.50,
     "Near VAH distance (ATR)",
     minval = 0.10,
     maxval = 3.00,
     step = 0.10,
     group = grpDB,
     active = showDashboard
)


// ---------------------------------------------------------------------------
// STALE NODE RULE
// ---------------------------------------------------------------------------

grpS = "STALE NODE RULE"

adaptiveHVN = input.bool(
     true,
     "Adaptive HVN detection",
     group = grpS,
     active = showSt
)

hvnPct = input.float(
     35,
     "Minimum HVN = % of POC row",
     minval = 10,
     maxval = 100,
     group = grpS,
     active = showSt
)

hvnSigma = input.float(
     0.50,
     "Adaptive HVN strength",
     minval = 0.0,
     maxval = 2.0,
     step = 0.10,
     group = grpS,
     active = showSt
)

recentPct = input.float(
     30,
     "Recent window % of lookback",
     minval = 10,
     maxval = 50,
     step = 5,
     group = grpS,
     active = showSt
)

stalePct = input.float(
     10,
     "Stale = recent volume < % of row",
     minval = 0,
     maxval = 50,
     group = grpS,
     active = showSt
)

clusterGap = input.int(
     1,
     "Cluster gap tolerance (rows)",
     minval = 0,
     maxval = 3,
     group = grpS,
     active = showSt
)

// Final default: show only the single strongest/relevant stale node.
maxStale = input.int(
     1,
     "Maximum stale HVNs",
     minval = 1,
     maxval = 5,
     group = grpS,
     active = showSt,
     tooltip =
         "Recommended default: 1.\n\n" +
         "Only the strongest relevant stale HVN is displayed to keep the chart clean."
)


// ---------------------------------------------------------------------------
// STALE DISTANCE FILTER
// ---------------------------------------------------------------------------

grpSD = "STALE DISTANCE FILTER"

filterStaleDistance = input.bool(
     true,
     "Limit stale HVN distance",
     group = grpSD,
     active = showSt,
     tooltip =
         "Recommended: ON.\n\n" +
         "Suppresses distant historical HVNs that are less relevant to current price."
)

// Final default: tighter 5 ATR relevance range.
staleMaxATR = input.float(
     5.0,
     "Maximum distance (ATR)",
     minval = 1.0,
     maxval = 50.0,
     step = 0.5,
     group = grpSD,
     active = showSt and filterStaleDistance,
     tooltip =
         "A Stale HVN farther than this ATR-normalized distance from current price is hidden.\n\n" +
         "Default: 5 ATR."
)


// ---------------------------------------------------------------------------
// COLORS
// ---------------------------------------------------------------------------

grpC = "COLORS"

cOld = input.color(
     #3f3fb5,
     "Oldest stratum",
     group = grpC
)

cMid = input.color(
     #1fa2a8,
     "Middle stratum",
     group = grpC
)

cNew = input.color(
     #ffb300,
     "Newest stratum",
     group = grpC
)

cPoc = input.color(
     #000000,
     "POC line",
     group = grpC
)

cVa = input.color(
     #8a8a8a,
     "Value area lines",
     group = grpC
)


// ============================================================================
// HELPERS
// ============================================================================

f_layerCol(int k, int S) =>
    float t = S > 1 ? k / (S - 1.0) : 1.0

    t < 0.5 ?
         color.from_gradient(
             t,
             0.0,
             0.5,
             cOld,
             cMid
         ) :
         color.from_gradient(
             t,
             0.5,
             1.0,
             cMid,
             cNew
         )


f_fmt(float p) =>
    str.tostring(
         p,
         format.mintick
    )


f_stateColor(int state) =>
    state == 2 ?
         color.new(#16a34a, 15) :
     state == 1 ?
         color.new(#eab308, 15) :
         color.new(#dc2626, 15)


f_stateText(int state) =>
    state == 2 ?
         "PASS" :
     state == 1 ?
         "WATCH" :
         "FAIL"


// ============================================================================
// SIMPLE-QUALIFIED INTRABAR HELPERS
// ============================================================================

f_requestEstimate(
     simple int chartSec,
     simple int lowerSec,
     simple int bars,
     simple float safetyMargin
) =>
    int result =
         lowerSec > 0 ?
         int(
             math.ceil(
                 float(bars) *
                 math.max(
                     1.0,
                     float(chartSec) /
                     float(lowerSec)
                 ) *
                 safetyMargin
             )
         ) :
         1000000000

    result


f_autoLtf(
     simple int bars,
     simple string precision
) =>

    int chartSec =
         timeframe.in_seconds()

    int budget =
         precision == "High" ?
         100000 :
         50000

    float margin =
         1.10

    string chosen =
         "1D"


    if chartSec > 60 and
         f_requestEstimate(
             chartSec,
             60,
             bars,
             margin
         ) <= budget

        chosen := "1"

    else if chartSec > 180 and
         f_requestEstimate(
             chartSec,
             180,
             bars,
             margin
         ) <= budget

        chosen := "3"

    else if chartSec > 300 and
         f_requestEstimate(
             chartSec,
             300,
             bars,
             margin
         ) <= budget

        chosen := "5"

    else if chartSec > 900 and
         f_requestEstimate(
             chartSec,
             900,
             bars,
             margin
         ) <= budget

        chosen := "15"

    else if chartSec > 1800 and
         f_requestEstimate(
             chartSec,
             1800,
             bars,
             margin
         ) <= budget

        chosen := "30"

    else if chartSec > 3600 and
         f_requestEstimate(
             chartSec,
             3600,
             bars,
             margin
         ) <= budget

        chosen := "60"

    else if chartSec > 14400 and
         f_requestEstimate(
             chartSec,
             14400,
             bars,
             margin
         ) <= budget

        chosen := "240"

    else if chartSec > 86400

        chosen := "1D"

    chosen


// ============================================================================
// ADAPTIVE INTRABAR RESOLUTION
// ============================================================================

simple string autoTF =
     f_autoLtf(
         lookback,
         autoPrecision
     )


simple string lowerTF =
     ltfMode == "Auto" ?
     autoTF :
     ltfMode


simple int chartSeconds =
     timeframe.in_seconds()


simple int lowerSeconds =
     timeframe.in_seconds(
         lowerTF
     )


simple bool validIntrabarTF =
     useIntrabar and
     lowerSeconds > 0 and
     lowerSeconds < chartSeconds


simple float theoreticalIntrabarsPerChartBar =
     validIntrabarTF ?
     math.max(
         1.0,
         float(chartSeconds) /
         float(lowerSeconds)
     ) :
     1.0


simple float intrabarHistorySafetyMargin =
     1.10


simple int requestedIntrabars =
     int(
         math.min(
             100000.0,
             math.max(
                 float(lookback + 10),
                 math.ceil(
                     float(lookback) *
                     theoreticalIntrabarsPerChartBar *
                     intrabarHistorySafetyMargin
                 )
             )
         )
     )


// ============================================================================
// LOWER-TIMEFRAME REQUEST
// ============================================================================

[ltfHigh, ltfLow, ltfVolume] =
     request.security_lower_tf(
         syminfo.tickerid,
         lowerTF,
         [
             high,
             low,
             volume
         ],
         ignore_invalid_timeframe = true,
         calc_bars_count = requestedIntrabars
     )


// ============================================================================
// DRAWING REGISTRIES
// ============================================================================

var array<box> boxes =
     array.new<box>()

var array<line> lines =
     array.new<line>()

var array<label> labels =
     array.new<label>()


// ============================================================================
// DASHBOARD
// ============================================================================

var table dash =
     table.new(
         position.top_right,
         2,
         9,
         border_width = 1,
         frame_width = 1
     )


// ============================================================================
// PINE SCREENER OUTPUTS - SCORING MODEL 2.2
// ============================================================================
//
// These outputs remain separate from the visual profile engine.
// The market-structure score excludes data quality. Intrabar Quality is a gate.
//
// Six compact screener columns:
// 1) VSP Structure Score (0-6)
// 2) POC Rotation (0/1, noise-tolerant)
// 3) New Value Acceptance (0/1)
// 4) Migration Quality (-100 to +100)
// 5) Early Value Rotation (0/1)
// 6) Confirmed Value Expansion (0/1)
// ============================================================================

float screenerScore = na
float screenerPocRotation = na
float screenerNewValueAcceptance = na
float screenerMigrationQuality = na

bool screenerEarlyValueRotation = false
bool screenerConfirmedValueExpansion = false


// ============================================================================
// MAIN ENGINE
// ============================================================================

if barstate.islast

    for b in boxes
        b.delete()

    for l in lines
        l.delete()

    for lb in labels
        lb.delete()

    boxes.clear()
    lines.clear()
    labels.clear()

    table.clear(
         dash,
         0,
         0,
         1,
         8
    )


    int n =
         math.min(
             lookback,
             bar_index + 1
         )

    int S =
         strataN


    if n >= S * 2

        float top =
             high

        float bot =
             low


        for i = 0 to n - 1

            top :=
                 math.max(
                     top,
                     high[i]
                 )

            bot :=
                 math.min(
                     bot,
                     low[i]
                 )


        float priceRange =
             top -
             bot

        float step =
             priceRange /
             rowsN


        if step > 0

            matrix<float> m =
                 matrix.new<float>(
                     rowsN,
                     S,
                     0.0
                 )

            array<float> tot =
                 array.new<float>(
                     rowsN,
                     0.0
                 )

            array<float> lay =
                 array.new<float>(
                     S,
                     0.0
                 )

            array<int> layBars =
                 array.new<int>(
                     S,
                     0
                 )

            array<int> jFirst =
                 array.new<int>(
                     S,
                     -1
                 )

            array<int> jLast =
                 array.new<int>(
                     S,
                     -1
                 )

            array<float> recentRowVol =
                 array.new<float>(
                     rowsN,
                     0.0
                 )

            // New Value Acceptance uses two non-overlapping halves of the
            // newest stratum. This tests whether newly migrated value is
            // being held instead of comparing it back to the prior stratum.
            array<float> newestOlderHalfVol =
                 array.new<float>(
                     rowsN,
                     0.0
                 )

            array<float> newestNewerHalfVol =
                 array.new<float>(
                     rowsN,
                     0.0
                 )


            int recentBars =
                 math.max(
                     1,
                     int(
                         math.ceil(
                             n *
                             recentPct /
                             100.0
                         )
                     )
                 )

            // Build exact chronological partition metadata first. This makes
            // layBars authoritative for the true size of every stratum even
            // when n is not evenly divisible by S.
            for iMeta = 0 to n - 1

                int jMeta =
                     n -
                     1 -
                     iMeta

                int kMeta =
                     math.min(
                         S -
                         1,
                         int(
                             jMeta *
                             S /
                             n
                         )
                     )

                layBars.set(
                     kMeta,
                     layBars.get(kMeta) +
                     1
                )

                if jFirst.get(kMeta) < 0

                    jFirst.set(
                         kMeta,
                         jMeta
                    )

                jFirst.set(
                     kMeta,
                     math.min(
                         jFirst.get(kMeta),
                         jMeta
                     )
                )

                jLast.set(
                     kMeta,
                     math.max(
                         jLast.get(kMeta),
                         jMeta
                     )
                )

            int newestStratumBars =
                 math.max(
                     1,
                     layBars.get(
                         S -
                         1
                     )
                 )

            int newestNewerHalfBars =
                 math.max(
                     1,
                     int(
                         math.ceil(
                             newestStratumBars /
                             2.0
                         )
                     )
                 )

            // Data quality for screening is measured only on the newest three
            // strata because those are the layers used by rotation, persistence
            // and new-value acceptance. Missing old intrabars do not block a
            // current setup.
            int qualityStartStratum =
                 math.max(
                     0,
                     S -
                     3
                 )

            int qualityWindowBars =
                 0

            for qk = 0 to S - 1

                if qk >=
                     qualityStartStratum

                    qualityWindowBars +=
                         layBars.get(qk)


            int parentBarsWithIntrabars =
                 0

            int parentBarsFallback =
                 0

            int totalIntrabarsUsed =
                 0

            int observedMaxIntrabars =
                 0

            int qualityBarsWithIntrabars =
                 0

            int qualityBarsFallback =
                 0

            int qualityIntrabarsUsed =
                 0

            int qualityObservedMaxIntrabars =
                 0


            // =================================================================
            // VOLUME DISTRIBUTION
            // =================================================================

            for i = 0 to n - 1

                int j =
                     n -
                     1 -
                     i


                int k =
                     math.min(
                         S -
                         1,
                         int(
                             j *
                             S /
                             n
                         )
                     )


                bool isRecent =
                     i <
                     recentBars

                bool isNewestNewerHalf =
                     i <
                     newestNewerHalfBars

                bool isNewestOlderHalf =
                     i >=
                     newestNewerHalfBars and
                     i <
                     newestStratumBars

                bool isQualityWindow =
                     k >=
                     qualityStartStratum


                array<float> hiArr =
                     ltfHigh[i]

                array<float> loArr =
                     ltfLow[i]

                array<float> volArr =
                     ltfVolume[i]


                int intraCount =
                     math.min(
                         hiArr.size(),
                         math.min(
                             loArr.size(),
                             volArr.size()
                         )
                     )


                bool useIntrabarForBar =
                     validIntrabarTF and
                     intraCount >
                     0


                if useIntrabarForBar

                    parentBarsWithIntrabars +=
                         1

                    totalIntrabarsUsed +=
                         intraCount


                    observedMaxIntrabars :=
                         math.max(
                             observedMaxIntrabars,
                             intraCount
                         )

                    if isQualityWindow

                        qualityBarsWithIntrabars +=
                             1

                        qualityIntrabarsUsed +=
                             intraCount

                        qualityObservedMaxIntrabars :=
                             math.max(
                                 qualityObservedMaxIntrabars,
                                 intraCount
                             )


                    for q = 0 to intraCount - 1

                        float iHi =
                             hiArr.get(
                                 q
                             )

                        float iLo =
                             loArr.get(
                                 q
                             )

                        float iVol =
                             nz(
                                 volArr.get(
                                     q
                                 )
                             )


                        if iVol > 0 and
                             not na(iHi) and
                             not na(iLo)

                            int r0 =
                                 math.max(
                                     0,
                                     math.min(
                                         rowsN -
                                         1,
                                         int(
                                             (
                                                 iLo -
                                                 bot
                                             ) /
                                             step
                                         )
                                     )
                                 )


                            int r1 =
                                 math.max(
                                     0,
                                     math.min(
                                         rowsN -
                                         1,
                                         int(
                                             (
                                                 iHi -
                                                 bot
                                             ) /
                                             step
                                         )
                                     )
                                 )


                            if iHi <= iLo or
                                 r0 == r1

                                m.set(
                                     r0,
                                     k,
                                     m.get(
                                         r0,
                                         k
                                     ) +
                                     iVol
                                )


                                if isRecent

                                    recentRowVol.set(
                                         r0,
                                         recentRowVol.get(
                                             r0
                                         ) +
                                         iVol
                                    )

                                if isNewestOlderHalf

                                    newestOlderHalfVol.set(
                                         r0,
                                         newestOlderHalfVol.get(
                                             r0
                                         ) +
                                         iVol
                                    )

                                if isNewestNewerHalf

                                    newestNewerHalfVol.set(
                                         r0,
                                         newestNewerHalfVol.get(
                                             r0
                                         ) +
                                         iVol
                                    )


                            else

                                float intraRange =
                                     iHi -
                                     iLo


                                for r = r0 to r1

                                    float rowLo =
                                         bot +
                                         r *
                                         step

                                    float rowHi =
                                         rowLo +
                                         step


                                    float overlap =
                                         math.min(
                                             iHi,
                                             rowHi
                                         ) -
                                         math.max(
                                             iLo,
                                             rowLo
                                         )


                                    if overlap > 0

                                        float allocatedVolume =
                                             iVol *
                                             overlap /
                                             intraRange


                                        m.set(
                                             r,
                                             k,
                                             m.get(
                                                 r,
                                                 k
                                             ) +
                                             allocatedVolume
                                        )


                                        if isRecent

                                            recentRowVol.set(
                                                 r,
                                                 recentRowVol.get(
                                                     r
                                                 ) +
                                                 allocatedVolume
                                            )

                                        if isNewestOlderHalf

                                            newestOlderHalfVol.set(
                                                 r,
                                                 newestOlderHalfVol.get(
                                                     r
                                                 ) +
                                                 allocatedVolume
                                            )

                                        if isNewestNewerHalf

                                            newestNewerHalfVol.set(
                                                 r,
                                                 newestNewerHalfVol.get(
                                                     r
                                                 ) +
                                                 allocatedVolume
                                            )


                else

                    parentBarsFallback +=
                         1

                    if isQualityWindow

                        qualityBarsFallback +=
                             1


                    float v =
                         nz(
                             volume[i]
                         )

                    float lo =
                         low[i]

                    float hi =
                         high[i]


                    if v > 0

                        int r0 =
                             math.max(
                                 0,
                                 math.min(
                                     rowsN -
                                     1,
                                     int(
                                         (
                                             lo -
                                             bot
                                         ) /
                                             step
                                     )
                                 )
                             )


                        int r1 =
                             math.max(
                                 0,
                                 math.min(
                                     rowsN -
                                     1,
                                     int(
                                         (
                                             hi -
                                             bot
                                         ) /
                                             step
                                     )
                                 )
                             )


                        if hi <= lo or
                             r0 == r1

                            m.set(
                                 r0,
                                 k,
                                 m.get(
                                     r0,
                                     k
                                 ) +
                                 v
                            )


                            if isRecent

                                recentRowVol.set(
                                     r0,
                                     recentRowVol.get(
                                         r0
                                     ) +
                                     v
                                )

                            if isNewestOlderHalf

                                newestOlderHalfVol.set(
                                     r0,
                                     newestOlderHalfVol.get(
                                         r0
                                     ) +
                                     v
                                )

                            if isNewestNewerHalf

                                newestNewerHalfVol.set(
                                     r0,
                                     newestNewerHalfVol.get(
                                         r0
                                     ) +
                                     v
                                )


                        else

                            float barRange =
                                 hi -
                                 lo


                            for r = r0 to r1

                                float rowLo =
                                     bot +
                                     r *
                                     step

                                float rowHi =
                                     rowLo +
                                     step


                                float overlap =
                                     math.min(
                                         hi,
                                         rowHi
                                     ) -
                                         math.max(
                                             lo,
                                             rowLo
                                         )


                                if overlap > 0

                                    float allocatedVolume =
                                         v *
                                         overlap /
                                         barRange


                                    m.set(
                                         r,
                                         k,
                                         m.get(
                                             r,
                                             k
                                         ) +
                                         allocatedVolume
                                    )


                                    if isRecent

                                        recentRowVol.set(
                                             r,
                                             recentRowVol.get(
                                                 r
                                             ) +
                                             allocatedVolume
                                        )

                                    if isNewestOlderHalf

                                        newestOlderHalfVol.set(
                                             r,
                                             newestOlderHalfVol.get(
                                                 r
                                             ) +
                                                 allocatedVolume
                                        )

                                    if isNewestNewerHalf

                                        newestNewerHalfVol.set(
                                             r,
                                             newestNewerHalfVol.get(
                                                 r
                                             ) +
                                             allocatedVolume
                                        )


            // =================================================================
            // INTRABAR QUALITY
            // =================================================================

            float intrabarCoverage =
                 n > 0 ?
                 parentBarsWithIntrabars /
                 float(n) :
                 0.0


            float intrabarCoveragePct =
                 intrabarCoverage *
                 100.0


            float averageIntrabarsPerCoveredBar =
                 parentBarsWithIntrabars > 0 ?
                 totalIntrabarsUsed /
                 float(
                     parentBarsWithIntrabars
                 ) :
                 0.0


            float observedDensityTarget =
                 observedMaxIntrabars > 0 ?
                 float(
                     observedMaxIntrabars
                 ) :
                 1.0


            float densityAdequacy =
                 observedDensityTarget > 0 ?
                 math.min(
                     1.0,
                     averageIntrabarsPerCoveredBar /
                     observedDensityTarget
                 ) :
                 0.0


            float densityAdequacyPct =
                 densityAdequacy *
                 100.0


            float intrabarQuality =
                 validIntrabarTF ?
                 math.sqrt(
                     math.max(
                         0.0,
                         intrabarCoverage
                     ) *
                     math.max(
                         0.0,
                         densityAdequacy
                     )
                 ) :
                 0.0


            float intrabarQualityPct =
                 intrabarQuality *
                 100.0


            string intrabarQualityClass =
                 intrabarQualityPct >= 90 ?
                 "EXCELLENT" :
                 intrabarQualityPct >= 75 ?
                 "GOOD" :
                 intrabarQualityPct >= 55 ?
                 "MODERATE" :
                 "LOW"


            float qualityWindowCoverage =
                 qualityWindowBars > 0 ?
                 qualityBarsWithIntrabars /
                 float(qualityWindowBars) :
                 0.0

            float qualityWindowAvgIntrabars =
                 qualityBarsWithIntrabars > 0 ?
                 qualityIntrabarsUsed /
                 float(qualityBarsWithIntrabars) :
                 0.0

            float qualityWindowDensityTarget =
                 qualityObservedMaxIntrabars > 0 ?
                 float(qualityObservedMaxIntrabars) :
                 1.0

            float qualityWindowDensity =
                 qualityWindowDensityTarget > 0 ?
                 math.min(
                     1.0,
                     qualityWindowAvgIntrabars /
                     qualityWindowDensityTarget
                 ) :
                 0.0

            float qualityWindowIntrabarQuality =
                 validIntrabarTF ?
                 math.sqrt(
                     math.max(
                         0.0,
                         qualityWindowCoverage
                     ) *
                     math.max(
                         0.0,
                         qualityWindowDensity
                     )
                 ) :
                 0.0

            float qualityWindowIntrabarQualityPct =
                 qualityWindowIntrabarQuality *
                 100.0


            string engineState =
                 validIntrabarTF and
                 parentBarsWithIntrabars >
                 0 ?
                 "INTRABAR " +
                 lowerTF :
                 "CHART BAR"


            // =================================================================
            // TOTAL PROFILE
            // =================================================================

            float sumAll =
                 0.0

            float maxTot =
                 0.0

            int poc =
                 0


            for r = 0 to rowsN - 1

                float rowTotal =
                     0.0


                for k = 0 to S - 1

                    float mv =
                         m.get(
                             r,
                             k
                         )


                    rowTotal +=
                         mv


                    lay.set(
                         k,
                         lay.get(k) +
                         mv
                    )


                tot.set(
                     r,
                     rowTotal
                )


                sumAll +=
                     rowTotal


                if rowTotal >
                     maxTot

                    maxTot :=
                         rowTotal

                    poc :=
                         r


            if sumAll > 0 and
                 maxTot > 0

                int newestOlderHalfPocRow =
                     0

                int newestNewerHalfPocRow =
                     0

                float newestOlderHalfPocVolume =
                     -1.0

                float newestNewerHalfPocVolume =
                     -1.0

                for r = 0 to rowsN - 1

                    float olderHalfVol =
                         newestOlderHalfVol.get(
                             r
                         )

                    float newerHalfVol =
                         newestNewerHalfVol.get(
                             r
                         )

                    if olderHalfVol >
                         newestOlderHalfPocVolume

                        newestOlderHalfPocVolume :=
                             olderHalfVol

                        newestOlderHalfPocRow :=
                             r

                    if newerHalfVol >
                         newestNewerHalfPocVolume

                        newestNewerHalfPocVolume :=
                             newerHalfVol

                        newestNewerHalfPocRow :=
                             r

                float newestOlderHalfPocP =
                     bot +
                     (
                         newestOlderHalfPocRow +
                         0.5
                     ) *
                     step

                float newestNewerHalfPocP =
                     bot +
                     (
                         newestNewerHalfPocRow +
                         0.5
                     ) *
                     step


                // ===========================================================
                // ROW STATISTICS
                // ===========================================================

                float meanRowVolume =
                     sumAll /
                     rowsN


                float varianceSum =
                     0.0


                for r = 0 to rowsN - 1

                    float d =
                         tot.get(
                             r
                         ) -
                         meanRowVolume


                    varianceSum +=
                         d *
                         d


                float rowStdDev =
                     math.sqrt(
                         varianceSum /
                         rowsN
                     )


                float fixedHVNThreshold =
                     maxTot *
                     hvnPct /
                     100.0


                float adaptiveThreshold =
                     meanRowVolume +
                     hvnSigma *
                     rowStdDev


                float hvnThreshold =
                     adaptiveHVN ?
                     math.max(
                         fixedHVNThreshold,
                         adaptiveThreshold
                     ) :
                     fixedHVNThreshold


                // ===========================================================
                // VALUE AREA
                // ===========================================================

                int up =
                     poc

                int dn =
                     poc


                float accumulated =
                     tot.get(
                         poc
                     )


                float target =
                     sumAll *
                     vaPct /
                     100.0


                while accumulated < target and
                     (
                         up < rowsN - 1 or
                         dn > 0
                     )

                    float aboveVolume =
                         up < rowsN - 1 ?
                         tot.get(
                             up +
                             1
                         ) :
                         -1.0


                    float belowVolume =
                         dn > 0 ?
                         tot.get(
                             dn -
                             1
                         ) :
                         -1.0


                    if aboveVolume >=
                         belowVolume

                        up +=
                             1

                        accumulated +=
                             aboveVolume

                    else

                        dn -=
                             1

                        accumulated +=
                             belowVolume


                float pocP =
                     bot +
                     (
                         poc +
                         0.5
                     ) *
                     step


                float vah =
                     bot +
                     (
                         up +
                         1
                     ) *
                     step


                float val =
                     bot +
                     dn *
                     step


                // ===========================================================
                // STRATUM POCS
                // ===========================================================

                array<int> lPoc =
                     array.new<int>(
                         S,
                         0
                     )


                for k = 0 to S - 1

                    float best =
                         -1.0

                    int bestRow =
                         0


                    for r = 0 to rowsN - 1

                        float mv =
                             m.get(
                                 r,
                                 k
                             )


                        if mv >
                             best

                            best :=
                                 mv

                            bestRow :=
                                 r


                    lPoc.set(
                         k,
                         bestRow
                    )


                // ===========================================================
                // DEVELOPING POC
                // ===========================================================

                array<int> devPoc =
                     array.new<int>(
                         S,
                         0
                     )


                for k = 0 to S - 1

                    float bestCum =
                         -1.0

                    int bestCumRow =
                         0


                    for r = 0 to rowsN - 1

                        float cumulative =
                             0.0


                        for kk = 0 to k

                            cumulative +=
                                 m.get(
                                     r,
                                     kk
                                 )


                        if cumulative >
                             bestCum

                            bestCum :=
                                 cumulative

                            bestCumRow :=
                                 r


                    devPoc.set(
                         k,
                         bestCumRow
                    )


                // ===========================================================
                // ACTIVITY
                // ===========================================================

                array<float> layerVolumePerBar =
                     array.new<float>(
                         S,
                         0.0
                     )


                float overallVolumePerBar =
                     sumAll /
                     n


                for k = 0 to S - 1

                    int barsInLayer =
                         math.max(
                             1,
                             layBars.get(
                                 k
                             )
                         )


                    float volumePerBar =
                         lay.get(
                             k
                         ) /
                         barsInLayer


                    layerVolumePerBar.set(
                         k,
                         volumePerBar
                    )


                float newestVolumePerBar =
                     layerVolumePerBar.get(
                         S -
                         1
                     )


                float newestActivityRatio =
                     overallVolumePerBar >
                     0 ?
                     newestVolumePerBar /
                     overallVolumePerBar :
                     0.0


                // ===========================================================
                // MIGRATION
                // ===========================================================

                float pOld =
                     bot +
                     (
                         lPoc.get(
                             0
                         ) +
                         0.5
                     ) *
                     step


                float pNew =
                     bot +
                     (
                         lPoc.get(
                             S -
                             1
                         ) +
                         0.5
                     ) *
                     step


                int newestPocRow =
                     lPoc.get(
                         S -
                         1
                     )

                int previousPocRow =
                     S >
                     1 ?
                     lPoc.get(
                         S -
                         2
                     ) :
                     newestPocRow

                int previous2PocRow =
                     S >
                     2 ?
                     lPoc.get(
                         S -
                         3
                     ) :
                     previousPocRow

                int latestPocDeltaRows =
                     newestPocRow -
                     previousPocRow

                bool latestPocUp =
                     latestPocDeltaRows >
                     pocToleranceRows

                int previousPocDeltaRows =
                     previousPocRow -
                     previous2PocRow

                bool pocPersistence =
                     previousPocDeltaRows >
                     pocToleranceRows

                bool latestPocDown =
                     latestPocDeltaRows <
                     -pocToleranceRows

                bool previousPocDown =
                     previousPocDeltaRows <
                     -pocToleranceRows

                string recentMigrationClass =
                     latestPocUp and
                     pocPersistence ?
                     "UP" :
                     latestPocDown and
                     previousPocDown ?
                     "DOWN" :
                     latestPocUp and
                     previousPocDown ?
                     "TURNING UP" :
                     latestPocDown and
                     pocPersistence ?
                     "TURNING DOWN" :
                     latestPocUp ?
                     "UP START" :
                     latestPocDown ?
                     "DOWN START" :
                     "FLAT / MIXED"

                bool recentMigrationSupportsLong =
                     recentMigrationClass ==
                     "UP" or
                     recentMigrationClass ==
                     "TURNING UP" or
                     recentMigrationClass ==
                     "UP START"


                float migrationPct =
                     pOld !=
                     0 ?
                     (
                         pNew -
                         pOld
                     ) /
                     pOld *
                     100.0 :
                     0.0


                float normalizedMigration =
                     priceRange >
                     0 ?
                     (
                         pNew -
                         pOld
                     ) /
                     priceRange :
                     0.0


                float migrationPath =
                     0.0


                if S >
                     1

                    for k = 1 to S - 1

                        float p1 =
                             bot +
                             (
                                 lPoc.get(
                                     k -
                                     1
                                 ) +
                                 0.5
                             ) *
                             step


                        float p2 =
                             bot +
                             (
                                 lPoc.get(
                                     k
                                 ) +
                                 0.5
                             ) *
                             step


                        migrationPath +=
                             math.abs(
                                 p2 -
                                 p1
                             )


                float migrationEfficiency =
                     migrationPath >
                     0 ?
                     math.abs(
                         pNew -
                         pOld
                     ) /
                     migrationPath :
                     0.0


                // ===========================================================
                // NEW VALUE ACCEPTANCE
                // ===========================================================
                // Compare two non-overlapping halves of the newest stratum.
                // PASS means the newer half is holding at or above the older
                // half within the configured POC noise tolerance.

                int newValueAcceptanceDeltaRows =
                     newestNewerHalfPocRow -
                     newestOlderHalfPocRow

                bool newValueAcceptance =
                     newestNewerHalfPocRow >=
                     newestOlderHalfPocRow -
                     pocToleranceRows


                // ===========================================================
                // DIRECTIONAL MIGRATION QUALITY
                // ===========================================================
                // Efficiency is now direction-aware for long-side screening.
                // Small net migrations are also down-weighted even if their
                // path is perfectly efficient.

                float migrationDirection =
                     pNew >
                     pOld ?
                     1.0 :
                     pNew <
                     pOld ?
                     -1.0 :
                     0.0

                float migrationMagnitudeFactor =
                     math.min(
                         1.0,
                         math.abs(
                             normalizedMigration
                         ) /
                         0.08
                     )

                float migrationQuality =
                     migrationDirection *
                     migrationEfficiency *
                     migrationMagnitudeFactor

                float migrationQualityScore =
                     migrationQuality *
                     100.0

                string migrationQualityClass =
                     migrationQualityScore >=
                     60 ?
                     "STRONG UP" :
                     migrationQualityScore >=
                     25 ?
                     "UP" :
                     migrationQualityScore <=
                     -60 ?
                     "STRONG DOWN" :
                     migrationQualityScore <=
                     -25 ?
                     "DOWN" :
                     "NEUTRAL"


                // ===========================================================
                // DATA QUALITY GATE
                // ===========================================================
                // Quality is NOT a score point. It only determines whether
                // the screening read is sufficiently reliable.

                bool intrabarModeActive =
                     validIntrabarTF and
                     qualityBarsWithIntrabars >
                     0

                bool qualityGatePass =
                     not intrabarModeActive or
                     qualityWindowIntrabarQualityPct >=
                     dashQualityMin

                bool qualityGateWatch =
                     intrabarModeActive and
                     not qualityGatePass and
                     qualityWindowIntrabarQualityPct >=
                     dashQualityMin *
                     0.75

                string qualityGateClass =
                     not intrabarModeActive ?
                     "CHART BAR" :
                     qualityGatePass ?
                     "PASS" :
                     qualityGateWatch ?
                     "WATCH" :
                     "FAIL"


                // ===========================================================
                // VALUE STABILITY
                // ===========================================================

                float pocMean =
                     0.0


                for k = 0 to S - 1

                    pocMean +=
                         bot +
                         (
                             lPoc.get(
                                 k
                             ) +
                             0.5
                         ) *
                         step


                pocMean /=
                     S


                float pocVariance =
                     0.0


                for k = 0 to S - 1

                    float pk =
                         bot +
                         (
                             lPoc.get(
                                 k
                             ) +
                             0.5
                         ) *
                         step


                    float d =
                         pk -
                         pocMean


                    pocVariance +=
                         d *
                         d


                float pocStd =
                     math.sqrt(
                         pocVariance /
                         S
                     )


                float valueInstability =
                     priceRange >
                     0 ?
                     pocStd /
                     priceRange :
                     0.0


                string stabilityClass =
                     valueInstability <
                     0.08 ?
                     "HIGH" :
                     valueInstability <
                     0.18 ?
                     "MODERATE" :
                     "LOW"


                string migrationClass =
                     normalizedMigration >
                     0.25 ?
                     "STRONG UP" :
                     normalizedMigration >
                     0.08 ?
                     "UP" :
                     normalizedMigration <
                     -0.25 ?
                     "STRONG DOWN" :
                     normalizedMigration <
                     -0.08 ?
                     "DOWN" :
                     "BALANCED"


                // ===========================================================
                // PINE SCREENER ENGINE - SCORING MODEL 2.2
                // ===========================================================
                // Six market-structure points. Data quality uses the newest three strata as a gate.

                bool screenerAcceptancePass =
                     newValueAcceptance

                bool screenerMigrationPass =
                     migrationQualityScore >=
                     40.0 and
                     recentMigrationSupportsLong

                bool screenerActivityPass =
                     newestActivityRatio >=
                     dashActivityRatioMin

                bool screenerPricePocPass =
                     close >=
                     pocP

                bool screenerPriceVahPass =
                     close >=
                     vah -
                     atr14 *
                     dashNearVahAtr

                int screenerPassCount =
                     (latestPocUp ? 1 : 0) +
                     (pocPersistence ? 1 : 0) +
                     (screenerAcceptancePass ? 1 : 0) +
                     (screenerMigrationPass ? 1 : 0) +
                     (screenerPricePocPass ? 1 : 0) +
                     (screenerPriceVahPass ? 1 : 0)

                // Pine Screener must remain usable in CHART BAR mode and when
                // lower-timeframe coverage is incomplete. Data quality remains
                // visible on the chart dashboard, but it does not suppress
                // Screener outputs.
                screenerScore :=
                     float(
                         screenerPassCount
                     )

                screenerPocRotation :=
                     latestPocUp ?
                     1.0 :
                     0.0

                screenerNewValueAcceptance :=
                     newValueAcceptance ?
                     1.0 :
                     0.0

                screenerMigrationQuality :=
                     migrationQualityScore

                // Early stage: upward rotation plus evidence that the new
                // value is being held inside the newest stratum.
                screenerEarlyValueRotation :=
                     latestPocUp and
                     newValueAcceptance and
                     recentMigrationSupportsLong and
                     migrationQualityScore >
                     0.0

                // Confirmed stage: two consecutive upward rotations, new-value
                // acceptance, activity expansion and price above VAH.
                screenerConfirmedValueExpansion :=
                     latestPocUp and
                     pocPersistence and
                     newValueAcceptance and
                     screenerMigrationPass and
                     screenerActivityPass and
                     close >=
                     vah


                // ===========================================================
                // DRAW PROFILE
                // ===========================================================

                int x0 =
                     bar_index +
                     gapB


                for r = 0 to rowsN - 1

                    float rLo =
                         bot +
                         r *
                         step


                    float rHi =
                         rLo +
                         step


                    bool inVA =
                         r >=
                         dn and
                         r <=
                         up


                    int transparency =
                         inVA ?
                         transpIn :
                         transpOut


                    float cumulativeWidth =
                         0.0


                    for k = 0 to S - 1

                        float layerWidth =
                             m.get(
                                 r,
                                 k
                             ) /
                             maxTot *
                             widthB


                        if layerWidth >
                             0

                            int xl =
                                 x0 +
                                 int(
                                     math.round(
                                         cumulativeWidth
                                     )
                                 )


                            int xr =
                                 x0 +
                                 int(
                                     math.round(
                                         cumulativeWidth +
                                         layerWidth
                                     )
                                 )


                            if xr >
                                 xl

                                boxes.push(
                                     box.new(
                                         xl,
                                         rHi,
                                         xr,
                                         rLo,
                                         border_width =
                                             0,
                                         bgcolor =
                                             color.new(
                                                 f_layerCol(
                                                     k,
                                                     S
                                                 ),
                                                 transparency
                                             )
                                     )
                                )


                        cumulativeWidth +=
                             layerWidth


                int pocW =
                     int(
                         math.round(
                             tot.get(
                                 poc
                             ) /
                             maxTot *
                             widthB
                         )
                     )


                boxes.push(
                     box.new(
                         x0,
                         bot +
                         (
                             poc +
                             1
                         ) *
                         step,
                         x0 +
                         math.max(
                             1,
                             pocW
                         ),
                         bot +
                         poc *
                         step,
                         border_color =
                             cPoc,
                         border_width =
                             2,
                         bgcolor =
                             color.new(
                                 color.white,
                                 100
                             )
                     )
                )


                int xStart =
                     bar_index -
                     (
                         n -
                         1
                     )


                int xEnd =
                     x0 +
                     widthB


                // ===========================================================
                // KEY LEVELS
                // ===========================================================

                if showVA

                    lines.push(
                         line.new(
                             xStart,
                             pocP,
                             xEnd,
                             pocP,
                             color =
                                 color.new(
                                     cPoc,
                                     0
                                 ),
                             width =
                                 pocLineWidth,
                             style =
                                 line.style_solid
                         )
                    )


                    lines.push(
                         line.new(
                             xStart,
                             vah,
                             xEnd,
                             vah,
                             color =
                                 color.new(
                                     cVa,
                                     10
                                 ),
                             width =
                                 vaLineWidth,
                             style =
                                 line.style_dashed
                         )
                    )


                    lines.push(
                         line.new(
                             xStart,
                             val,
                             xEnd,
                             val,
                             color =
                                 color.new(
                                     cVa,
                                     10
                                 ),
                             width =
                                 vaLineWidth,
                             style =
                                 line.style_dashed
                         )
                    )


                    labels.push(
                         label.new(
                             xEnd,
                             pocP,
                             "POC  " +
                             f_fmt(
                                 pocP
                             ),
                             style =
                                 label.style_label_left,
                             color =
                                 color.new(
                                     cPoc,
                                     88
                                 ),
                             textcolor =
                                 cPoc,
                             size =
                                 size.small
                         )
                    )


                    labels.push(
                         label.new(
                             xEnd,
                             vah,
                             "VAH  " +
                             f_fmt(
                                 vah
                             ),
                             style =
                                 label.style_label_left,
                             color =
                                 color.new(
                                     cVa,
                                     88
                                 ),
                             textcolor =
                                 cVa,
                             size =
                                 size.small
                         )
                    )


                    labels.push(
                         label.new(
                             xEnd,
                             val,
                             "VAL  " +
                             f_fmt(
                                 val
                             ),
                             style =
                                 label.style_label_left,
                             color =
                                 color.new(
                                     cVa,
                                     88
                                 ),
                             textcolor =
                                 cVa,
                             size =
                                 size.small
                         )
                    )


                // ===========================================================
                // MIGRATION SPINE
                // ===========================================================

                if showMig

                    int spineX =
                         xEnd +
                         16


                    for k = 0 to S - 1

                        float yk =
                             bot +
                             (
                                 lPoc.get(
                                     k
                                 ) +
                                 0.5
                             ) *
                             step


                        float developingYK =
                             bot +
                             (
                                 devPoc.get(
                                     k
                                 ) +
                                 0.5
                             ) *
                             step


                        int xk =
                             spineX +
                             k *
                             4


                        if k >
                             0

                            float yp =
                                 bot +
                                 (
                                     lPoc.get(
                                         k -
                                         1
                                     ) +
                                     0.5
                                 ) *
                                 step


                            lines.push(
                                 line.new(
                                     xk -
                                     4,
                                     yp,
                                     xk,
                                     yk,
                                     color =
                                         f_layerCol(
                                             k,
                                             S
                                         ),
                                     width =
                                         2
                                 )
                            )


                        string migrationTooltip =
                             "Stratum " +
                             str.tostring(
                                 k +
                                 1
                             ) +
                             " of " +
                             str.tostring(
                                 S
                             ) +
                             "\n" +
                             "Stratum POC: " +
                             f_fmt(
                                 yk
                             ) +
                             "\n" +
                             "Developing POC: " +
                             f_fmt(
                                 developingYK
                             )


                        if k ==
                             S -
                             1

                            migrationTooltip +=
                                 "\n\n" +
                                 "Volume engine: " +
                                 engineState +
                                 "\n" +
                                 "Resolution mode: " +
                                 (
                                     ltfMode == "Auto" ?
                                     "AUTO " +
                                     autoPrecision :
                                     "MANUAL"
                                 ) +
                                 "\n" +
                                 "Selected intrabar TF: " +
                                 lowerTF +
                                 "\n" +
                                 "Requested intrabars: " +
                                 str.tostring(
                                     requestedIntrabars
                                 ) +
                                 "\n" +
                                 "Intrabar coverage: " +
                                 str.tostring(
                                     intrabarCoveragePct,
                                     "#.#"
                                 ) +
                                 "%" +
                                 "\n" +
                                 "Avg intrabars / covered bar: " +
                                 str.tostring(
                                     averageIntrabarsPerCoveredBar,
                                     "#.##"
                                 ) +
                                 "\n" +
                                 "Observed max intrabars / bar: " +
                                 str.tostring(
                                     observedMaxIntrabars
                                 ) +
                                 "\n" +
                                 "Density adequacy: " +
                                 str.tostring(
                                     densityAdequacyPct,
                                     "#.#"
                                 ) +
                                 "%" +
                                 "\n" +
                                 "Intrabar quality (full profile): " +
                                 str.tostring(
                                     intrabarQualityPct,
                                     "#"
                                 ) +
                                 "% (" +
                                 intrabarQualityClass +
                                 ")" +
                                 "\n" +
                                 "Recent 3-strata quality: " +
                                 str.tostring(
                                     qualityWindowIntrabarQualityPct,
                                     "#"
                                 ) +
                                 "%" +
                                 "\n" +
                                 "Recent 3-strata coverage: " +
                                 str.tostring(
                                     qualityWindowCoverage *
                                     100.0,
                                     "#.#"
                                 ) +
                                 "%" +
                                 "\n" +
                                 "Recent 3-strata fallback bars: " +
                                 str.tostring(
                                     qualityBarsFallback
                                 ) +
                                 "\n" +
                                 "Intrabars used: " +
                                 str.tostring(
                                     totalIntrabarsUsed
                                 ) +
                                 "\n" +
                                 "Fallback chart bars: " +
                                 str.tostring(
                                     parentBarsFallback
                                 ) +
                                 "\n\n" +
                                 "Value migration: " +
                                 (
                                     migrationPct >=
                                     0 ?
                                     "+" :
                                     ""
                                 ) +
                                 str.tostring(
                                     migrationPct,
                                     "#.##"
                                 ) +
                                 "%" +
                                 "\n" +
                                 "Value migration state: " +
                                 migrationClass +
                                 "\n" +
                                 "Migration efficiency: " +
                                 str.tostring(
                                     migrationEfficiency *
                                     100.0,
                                     "#"
                                 ) +
                                 "%" +
                                 "\n" +
                                 "Newest stratum older-half POC: " +
                                 f_fmt(
                                     newestOlderHalfPocP
                                 ) +
                                 "\n" +
                                 "Newest stratum newer-half POC: " +
                                 f_fmt(
                                     newestNewerHalfPocP
                                 ) +
                                 "\n" +
                                 "New Value Acceptance: " +
                                 (newValueAcceptance ? "PASS" : "FAIL") +
                                 "\n" +
                                 "Acceptance change: " +
                                 str.tostring(
                                     newValueAcceptanceDeltaRows
                                 ) +
                                 " rows" +
                                 "\n" +
                                 "Newest activity: " +
                                 str.tostring(
                                     newestActivityRatio,
                                     "#.##"
                                 ) +
                                 "x average" +
                                 "\n" +
                                 "POC persistence: " +
                                 (pocPersistence ? "PASS" : "NO") +
                                 "\n" +
                                 "Data-quality gate: " +
                                 qualityGateClass +
                                 "\n" +
                                 "Migration Quality: " +
                                 str.tostring(
                                     migrationQualityScore,
                                     "#"
                                 ) +
                                 " / 100 (" +
                                 migrationQualityClass +
                                 ")" +
                                 "\n" +
                                 "Recent migration: " +
                                 recentMigrationClass +
                                 "\n" +
                                 "Migration Quality summarizes the full lookback. Long-side scoring only credits it when Recent migration is UP, TURNING UP, or UP START." +
                                 "\n" +
                                 "Value stability: " +
                                 stabilityClass


                        labels.push(
                             label.new(
                                 xk,
                                 yk,
                                 "",
                                 style =
                                     label.style_circle,
                                 size =
                                     size.tiny,
                                 color =
                                     f_layerCol(
                                         k,
                                         S
                                     ),
                                 tooltip =
                                     migrationTooltip
                             )
                        )


                // ===========================================================
                // TIME RIBBON
                // ===========================================================

                if showRib

                    float ribbonTop =
                         bot -
                         step *
                         0.6


                    float ribbonBottom =
                         bot -
                         step *
                         1.4


                    for k = 0 to S - 1

                        int jf =
                             jFirst.get(
                                 k
                             )

                        int jl =
                             jLast.get(
                                 k
                             )


                        if jf >=
                             0

                            int leftBar =
                                 bar_index -
                                 (
                                     n -
                                     1 -
                                     jf
                                 )


                            int rightBar =
                                 bar_index -
                                 (
                                     n -
                                     1 -
                                     jl
                                 ) +
                                 1


                            boxes.push(
                                 box.new(
                                     leftBar,
                                     ribbonTop,
                                     rightBar,
                                     ribbonBottom,
                                     border_width =
                                         0,
                                     bgcolor =
                                         color.new(
                                             f_layerCol(
                                                 k,
                                                 S
                                             ),
                                             15
                                         )
                                 )
                            )


                // ===========================================================
                // STALE HVN ENGINE
                // FINAL: MAX 1 NODE + 5 ATR DISTANCE
                // ===========================================================

                if showSt

                    array<int> candidateRows =
                         array.new<int>()

                    array<float> candidateScores =
                         array.new<float>()

                    array<float> candidateRecentShares =
                         array.new<float>()


                    for r = 0 to rowsN - 1

                        float rowVolume =
                             tot.get(
                                 r
                             )


                        float recentVolume =
                             recentRowVol.get(
                                 r
                             )


                        float recentShare =
                             rowVolume >
                             0 ?
                             recentVolume /
                             rowVolume *
                             100.0 :
                             0.0


                        float rowPrice =
                             bot +
                             (
                                 r +
                                 0.5
                             ) *
                             step


                        float distanceATR =
                             atr14 >
                             0 ?
                             math.abs(
                                 rowPrice -
                                 close
                             ) /
                             atr14 :
                             0.0


                        bool passesDistance =
                             not filterStaleDistance or
                             distanceATR <=
                             staleMaxATR


                        bool strongNode =
                             r !=
                             poc and
                             rowVolume >=
                             hvnThreshold


                        bool staleNode =
                             strongNode and
                             recentShare <
                             stalePct and
                             passesDistance


                        if staleNode

                            float historicalStrength =
                                 rowVolume /
                                 maxTot


                            float freshnessDeficit =
                                 stalePct >
                                 0 ?
                                 1.0 -
                                 math.min(
                                     1.0,
                                     recentShare /
                                     stalePct
                                 ) :
                                 1.0


                            float proximityWeight =
                                 filterStaleDistance and
                                 staleMaxATR >
                                 0 ?
                                 math.exp(
                                     -distanceATR /
                                     staleMaxATR
                                 ) :
                                 1.0


                            float staleScore =
                                 historicalStrength *
                                 freshnessDeficit *
                                 proximityWeight


                            candidateRows.push(
                                 r
                            )

                            candidateScores.push(
                                 staleScore
                            )

                            candidateRecentShares.push(
                                 recentShare
                            )


                    array<int> clusterRows =
                         array.new<int>()

                    array<float> clusterScores =
                         array.new<float>()

                    array<float> clusterRecentShares =
                         array.new<float>()

                    array<int> clusterLowRows =
                         array.new<int>()

                    array<int> clusterHighRows =
                         array.new<int>()


                    int candidateCount =
                         candidateRows.size()


                    if candidateCount >
                         0

                        int currentLow =
                             candidateRows.get(
                                 0
                             )

                        int currentHigh =
                             candidateRows.get(
                                 0
                             )

                        int currentBestRow =
                             candidateRows.get(
                                 0
                             )

                        float currentBestScore =
                             candidateScores.get(
                                 0
                             )

                        float currentBestRecent =
                             candidateRecentShares.get(
                                 0
                             )


                        if candidateCount >
                             1

                            for idx = 1 to candidateCount - 1

                                int candidateRow =
                                     candidateRows.get(
                                         idx
                                     )

                                float candidateScore =
                                     candidateScores.get(
                                         idx
                                     )

                                float candidateRecent =
                                     candidateRecentShares.get(
                                         idx
                                     )


                                int rowDistance =
                                     candidateRow -
                                     currentHigh


                                bool sameCluster =
                                     rowDistance <=
                                     clusterGap +
                                     1


                                if sameCluster

                                    currentHigh :=
                                         candidateRow


                                    if candidateScore >
                                         currentBestScore

                                        currentBestScore :=
                                             candidateScore

                                        currentBestRow :=
                                             candidateRow

                                        currentBestRecent :=
                                             candidateRecent


                                else

                                    clusterRows.push(
                                         currentBestRow
                                    )

                                    clusterScores.push(
                                         currentBestScore
                                    )

                                    clusterRecentShares.push(
                                         currentBestRecent
                                    )

                                    clusterLowRows.push(
                                         currentLow
                                    )

                                    clusterHighRows.push(
                                         currentHigh
                                    )


                                    currentLow :=
                                         candidateRow

                                    currentHigh :=
                                         candidateRow

                                    currentBestRow :=
                                         candidateRow

                                    currentBestScore :=
                                         candidateScore

                                    currentBestRecent :=
                                         candidateRecent


                        clusterRows.push(
                             currentBestRow
                        )

                        clusterScores.push(
                             currentBestScore
                        )

                        clusterRecentShares.push(
                             currentBestRecent
                        )

                        clusterLowRows.push(
                             currentLow
                        )

                        clusterHighRows.push(
                             currentHigh
                        )


                    int clusterCount =
                         clusterRows.size()


                    int drawCount =
                         math.min(
                             maxStale,
                             clusterCount
                         )


                    if drawCount >
                         0

                        array<bool> used =
                             array.new<bool>(
                                 clusterCount,
                                 false
                             )


                        for selection = 0 to drawCount - 1

                            float bestScore =
                                 -1.0

                            int bestIndex =
                                 -1


                            for idx = 0 to clusterCount - 1

                                if not used.get(
                                     idx
                                )

                                    float score =
                                         clusterScores.get(
                                             idx
                                         )


                                    if score >
                                         bestScore

                                        bestScore :=
                                             score

                                        bestIndex :=
                                             idx


                            if bestIndex >=
                                 0

                                used.set(
                                     bestIndex,
                                     true
                                )


                                int staleRow =
                                     clusterRows.get(
                                         bestIndex
                                     )

                                int lowRow =
                                     clusterLowRows.get(
                                         bestIndex
                                     )

                                int highRow =
                                     clusterHighRows.get(
                                         bestIndex
                                     )


                                float recentShare =
                                     clusterRecentShares.get(
                                         bestIndex
                                     )


                                float staleY =
                                     bot +
                                     (
                                         staleRow +
                                         0.5
                                     ) *
                                     step


                                float zoneLow =
                                     bot +
                                     lowRow *
                                     step


                                float zoneHigh =
                                     bot +
                                     (
                                         highRow +
                                         1
                                     ) *
                                     step


                                float staleDistanceATR =
                                     atr14 >
                                     0 ?
                                     math.abs(
                                         staleY -
                                         close
                                     ) /
                                     atr14 :
                                     0.0


                                lines.push(
                                     line.new(
                                         xStart,
                                         staleY,
                                         x0,
                                         staleY,
                                         color =
                                             color.new(
                                                 cOld,
                                                 35
                                             ),
                                         width =
                                             1,
                                         style =
                                             line.style_dashed
                                     )
                                )


                                labels.push(
                                     label.new(
                                         xStart,
                                         staleY,
                                         "stale HVN",
                                         style =
                                             label.style_label_right,
                                         color =
                                             color.new(
                                                 color.black,
                                                 100
                                             ),
                                         textcolor =
                                             color.new(
                                                 cOld,
                                                 10
                                             ),
                                         size =
                                             size.tiny,
                                         tooltip =
                                             "Stale High Volume Node" +
                                             "\n\n" +
                                             "Historical high-volume acceptance area with weak recent participation." +
                                             "\n" +
                                             "Representative price: " +
                                             f_fmt(
                                                 staleY
                                             ) +
                                             "\n" +
                                             "Cluster range: " +
                                             f_fmt(
                                                 zoneLow
                                             ) +
                                             " - " +
                                             f_fmt(
                                                 zoneHigh
                                             ) +
                                             "\n" +
                                             "Recent share: " +
                                             str.tostring(
                                                 recentShare,
                                                 "#.##"
                                             ) +
                                             "%" +
                                             "\n" +
                                             "Distance: " +
                                             str.tostring(
                                                 staleDistanceATR,
                                                 "#.##"
                                             ) +
                                             " ATR"
                                     )
                                )


                // ===========================================================
                // SCREENING DASHBOARD - SCORING MODEL 2.2
                // ===========================================================

                if showDashboard

                    float pricePocDistanceAtr =
                         atr14 > 0 ?
                         (close - pocP) /
                         atr14 :
                         0.0

                    int statePoc =
                         latestPocUp ?
                         2 :
                         math.abs(
                             latestPocDeltaRows
                         ) <=
                         pocToleranceRows ?
                         1 :
                         0

                    int statePersistence =
                         pocPersistence ?
                         2 :
                         latestPocUp ?
                         1 :
                         0

                    int stateAcceptance =
                         newValueAcceptance ?
                         2 :
                         newValueAcceptanceDeltaRows >=
                         -(pocToleranceRows + 1) ?
                         1 :
                         0

                    int stateMigration =
                         screenerMigrationPass ?
                         2 :
                         migrationQualityScore >
                         0 and
                         recentMigrationSupportsLong ?
                         1 :
                         0

                    int stateActivity =
                         newestActivityRatio >=
                         dashActivityRatioMin ?
                         2 :
                         newestActivityRatio >=
                         0.95 ?
                         1 :
                         0

                    int stateQuality =
                         qualityGatePass ?
                         2 :
                         qualityGateWatch ?
                         1 :
                         0

                    int statePricePoc =
                         close >=
                         pocP ?
                         2 :
                         pricePocDistanceAtr >=
                         -0.25 ?
                         1 :
                         0

                    bool priceNearVah =
                         close >=
                         vah -
                         atr14 *
                         dashNearVahAtr

                    bool priceWatchVah =
                         close >=
                         vah -
                         atr14 *
                         dashNearVahAtr *
                         2.0

                    int statePriceVah =
                         close >= vah ?
                         2 :
                         priceNearVah ?
                         2 :
                         priceWatchVah ?
                         1 :
                         0

                    int passCount =
                         (statePoc == 2 ? 1 : 0) +
                         (statePersistence == 2 ? 1 : 0) +
                         (stateAcceptance == 2 ? 1 : 0) +
                         (stateMigration == 2 ? 1 : 0) +
                         (statePricePoc == 2 ? 1 : 0) +
                         (statePriceVah == 2 ? 1 : 0)

                    bool strongSetup =
                         qualityGatePass and
                         passCount >=
                         5 and
                         latestPocUp and
                         close >=
                         pocP

                    bool watchSetup =
                         qualityGatePass and
                         not strongSetup and
                         passCount >=
                         3

                    string setupText =
                         strongSetup ?
                         "STRONG SETUP" :
                         watchSetup ?
                         "WATCH" :
                         qualityGatePass ?
                         "NO SETUP" :
                         "DATA GATE"

                    color setupBg =
                         strongSetup ?
                         color.new(#16a34a, 0) :
                         watchSetup ?
                         color.new(#eab308, 0) :
                         color.new(#dc2626, 0)

                    table.cell(dash, 0, 0, "VSP STRUCTURE", text_color = color.white, bgcolor = color.new(#1e3a5f, 0), text_size = size.small)
                    table.cell(dash, 1, 0, setupText + "  " + str.tostring(passCount) + "/6", text_color = color.white, bgcolor = setupBg, text_size = size.small)

                    table.cell(dash, 0, 1, "POC Rotation", bgcolor = f_stateColor(statePoc), text_color = color.white)
                    table.cell(dash, 1, 1, f_stateText(statePoc) + "  d " + str.tostring(latestPocDeltaRows) + " rows", bgcolor = f_stateColor(statePoc), text_color = color.white)

                    table.cell(dash, 0, 2, "POC Persistence", bgcolor = f_stateColor(statePersistence), text_color = color.white)
                    table.cell(dash, 1, 2, f_stateText(statePersistence), bgcolor = f_stateColor(statePersistence), text_color = color.white)

                    table.cell(dash, 0, 3, "New Value Acceptance", bgcolor = f_stateColor(stateAcceptance), text_color = color.white)
                    table.cell(dash, 1, 3, f_stateText(stateAcceptance) + "  d " + str.tostring(newValueAcceptanceDeltaRows) + " rows", bgcolor = f_stateColor(stateAcceptance), text_color = color.white)

                    table.cell(dash, 0, 4, "Migration Quality", bgcolor = f_stateColor(stateMigration), text_color = color.white)
                    table.cell(dash, 1, 4, str.tostring(migrationQualityScore, "#") + "  " + migrationQualityClass + " / " + recentMigrationClass, bgcolor = f_stateColor(stateMigration), text_color = color.white)

                    table.cell(dash, 0, 5, "Activity Expansion", bgcolor = f_stateColor(stateActivity), text_color = color.white)
                    table.cell(dash, 1, 5, str.tostring(newestActivityRatio, "#.##") + "x", bgcolor = f_stateColor(stateActivity), text_color = color.white)

                    table.cell(dash, 0, 6, "Data Quality Gate", bgcolor = f_stateColor(stateQuality), text_color = color.white)
                    table.cell(dash, 1, 6, intrabarModeActive ? qualityGateClass + "  " + str.tostring(qualityWindowIntrabarQualityPct, "#") + "%" : qualityGateClass, bgcolor = f_stateColor(stateQuality), text_color = color.white)

                    table.cell(dash, 0, 7, "Price vs POC", bgcolor = f_stateColor(statePricePoc), text_color = color.white)
                    table.cell(dash, 1, 7, close >= pocP ? "ABOVE  " + f_fmt(pocP) : "BELOW  " + f_fmt(pocP), bgcolor = f_stateColor(statePricePoc), text_color = color.white)

                    table.cell(dash, 0, 8, "Price vs VAH", bgcolor = f_stateColor(statePriceVah), text_color = color.white)
                    table.cell(dash, 1, 8, close >= vah ? "ABOVE  " + f_fmt(vah) : priceNearVah ? "NEAR  " + f_fmt(vah) : "BELOW  " + f_fmt(vah), bgcolor = f_stateColor(statePriceVah), text_color = color.white)

// ============================================================================
// PINE SCREENER COLUMNS + CONDITIONS
// ============================================================================
//
// Hidden plots keep the chart visually unchanged while exposing only the
// most decision-relevant VSP Structure Model 2.2 fields to Pine Screener.
// ============================================================================

plot(
     screenerScore,
     title = "VSP Structure Score",
     display = display.none
)

plot(
     screenerPocRotation,
     title = "POC Rotation",
     display = display.none
)

plot(
     screenerNewValueAcceptance,
     title = "New Value Acceptance",
     display = display.none
)

plot(
     screenerMigrationQuality,
     title = "Migration Quality",
     display = display.none
)

plot(
     screenerEarlyValueRotation ? 1.0 : 0.0,
     title = "Early Value Rotation",
     display = display.none
)

plot(
     screenerConfirmedValueExpansion ? 1.0 : 0.0,
     title = "Confirmed Value Expansion",
     display = display.none
)
````
