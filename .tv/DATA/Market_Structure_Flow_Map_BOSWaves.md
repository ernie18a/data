<!-- tradingview-pine-id: PUB;69f45c4ce46844edafe6efbc048d1b05 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Structure Flow Map [BOSWaves]

Source: https://www.tradingview.com/script/fdGNrwvp-Market-Structure-Flow-Map-BOSWaves/

## Description

Market Structure Flow Map [BOSWaves] - Strength-Scored Curved Ribbon Visualization of Break of Structure and Change of Character Events

Overview

Market Structure Flow Map [BOSWaves] is a market structure event visualization system that renders each Break of Structure and Change of Character as a curved three-layer ribbon connecting the broken swing pivot to the bar where the break occurred, where ribbon thickness, glow intensity, and arc curvature are driven by a composite strength score derived from the displacement beyond the broken level and the relative volume at the break bar rather than applying uniform visual treatment regardless of the conviction behind each structural event.

[image]https://www.tradingview.com/x/W8o45qWQ/[/image]

Instead of marking BOS and CHoCH events with simple horizontal lines or static labels, this system renders each structural break as a curved polyline ribbon that physically connects the origin swing point to the breakout bar, with the ribbon's visual weight scaling continuously from the configured minimum to maximum width based on how far price moved beyond the broken level and how significantly above average volume was at the moment of the break. Wider, brighter ribbons represent high-conviction structural breaks with strong displacement and volume evidence. Thinner, more subtle ribbons represent marginal breaks that barely cleared the structural level with below-average participation.

This creates a market structure visualization where the visual record of structural history is encoded with conviction information rather than presenting all breaks as visually equivalent events. The curved arc geometry provides an immediate spatial reading of the distance between the origin swing and the break bar, with longer arcs indicating structural breaks that developed over more bars. The three-layer glow, body, and core rendering gives each ribbon depth and visual prominence scaled to its structural significance. And the circular node markers at each broken swing pivot anchor the ribbon origins to the precise structural prices that were violated.

Price structure is therefore presented not just as a sequence of labeled events but as a visually weighted conviction map where the strongest structural breaks are immediately identifiable by their visual dominance over weaker ones.

Conceptual Framework

Market Structure Flow Map is founded on the principle that not all structural breaks carry equal significance, and that a visualization system which presents every BOS and CHoCH with identical visual weight fails to communicate the most important information available at the moment of each break: how convincingly price moved through the structural level and whether that move was supported by meaningful participation.

Traditional market structure tools mark every qualifying break with the same line, label, or zone regardless of whether the break was a decisive high-volume displacement or a marginal low-volume close that barely cleared the level. This framework replaces uniform visual treatment with strength-scaled ribbon geometry where every visual property of the ribbon reflects the composite conviction of the underlying structural event, creating a chart where the structural history reads as a visual conviction hierarchy rather than a flat sequence of identical events.

Three core principles guide the design:

[*]Each structural break should be rendered as a physical curved connection between its origin swing and its break bar, preserving the spatial and temporal relationship between the structural level that was violated and the moment of violation rather than abstracting the event to a horizontal line.
[*]Ribbon visual weight should scale continuously with a composite strength score that combines displacement magnitude and volume significance, ensuring that the chart's visual hierarchy reflects the structural conviction hierarchy rather than being independent of it.
[*]BOS and CHoCH events should be visually distinguished not only through color but through the arc geometry, with the ribbon curvature and length encoding the temporal distance between the swing origin and the break completion.

This shifts market structure visualization from event marking into conviction-weighted structural flow mapping where the cumulative visual record encodes the relative significance of every structural event in the chart history.

Theoretical Foundation

The indicator combines pivot high and low detection for swing origin identification, configurable close or wick break confirmation for structural break detection, displacement-based and volume-ratio-based strength scoring with configurable weighting, structural state tracking for BOS versus CHoCH classification, three-layer curved polyline ribbon construction with strength-scaled width and distance-adaptive arc height, and circular node markers at broken swing pivot prices.

Displacement strength is calculated as the distance from the broken level to the break bar's source price, normalized against an ATR multiple and capped at the configured maximum. Volume strength is calculated as the excess of the break bar's volume above average relative to the configured maximum ratio, with below-average volume bars receiving zero volume strength. These two components are combined using the configured dispWeight and volWeight parameters, normalized by their sum so the total always produces a 0-1 strength score regardless of the weight distribution chosen. The arc height scales with both ATR and the temporal distance between the swing origin and break bar, so ribbons connecting distant origin-break pairs curve more dramatically than ribbons connecting adjacent ones.

Four internal systems operate in tandem:

[*]Swing Detection and State Engine: Identifies confirmed pivot highs and lows using the configurable lookback, tracks the most recent unbroken high and low with their bar indices and prices, classifies each qualifying break as BOS or CHoCH based on the current structural state, and updates the structural state on each confirmed break.
[*]Strength Scoring System: Calculates displacement from the broken level normalized against ATR, calculates volume ratio normalized against the configured maximum, combines both components with configurable weights, and maps the result to a 0-1 composite strength score that drives all ribbon visual properties.
[*]Curved Ribbon Rendering Engine: Constructs three-point curved polyline paths from origin to arc midpoint to break bar for each of the three ribbon layers, applying strength-derived width to the body layer, additive width to the glow layer, and subtractive width to the core layer, with arc height scaling by both ATR and temporal distance.
[*]Label and Node System: Places circular node markers at each broken pivot price to anchor ribbon origins visually, places directional event labels at each break bar offset by a small ATR fraction, and enforces maximum event count limits across all object arrays independently.

This design ensures every structural event produces a visually complete conviction-weighted representation while the object management system maintains a clean configurable historical event window.

How It Works

Market Structure Flow Map evaluates price through a sequence of structure-aware and strength-scored processes:

[*]Pivot Detection: Confirmed swing highs and lows are identified using the configured left-right bar symmetry requirement, updating the tracked last high and last low prices and bar indices on each new confirmation.
[*]Break Source Selection: Depending on the break mode setting, either the close price or the bar's high and low extremes are used as the source for testing structural breaks, allowing either confirmed closing breaks or intrabar wick-based breaks to qualify.
[*]Break Detection: On each bar, the bullish break source is tested against the last unbroken high and the bearish break source is tested against the last unbroken low. A qualifying break requires the current bar to have crossed the level while the previous bar had not, and the level must not have been broken previously since its last registration.
[*]Structural State Classification: Bullish breaks during a bearish structural state classify as bullish CHoCH. Bullish breaks during a neutral or bullish state classify as bullish BOS. The same logic applies in reverse for bearish breaks, with structural state updating to the new direction on each confirmed event.
[*]Displacement Strength Calculation: The absolute distance between the break source price and the broken level price is divided by the product of ATR and the configured maximum displacement multiplier, clamped to a 0-1 range.
[*]Volume Strength Calculation: The excess volume above average is normalized by the configured maximum ratio minus one, clamped to a 0-1 range. Bars with below-average volume receive a volume strength of zero.
[*]Composite Strength Derivation: Displacement and volume strengths are combined using the configured weights normalized by their sum, producing a 0-1 composite score that drives all ribbon visual properties.
[*]Ribbon Geometry Construction: Three chart points are derived at the origin swing bar, the temporal midpoint between origin and break, and the break bar. The midpoint arc height is calculated from ATR, the arc ATR multiplier, a distance factor derived from the bar span, and the composite strength. For bullish breaks the arc curves above both endpoints; for bearish breaks below.
[*]Three-Layer Ribbon Drawing: The glow layer renders at the body width plus five with high transparency. The body layer renders at the strength-scaled width with low transparency. The core layer renders at the body width minus two with a near-white color at low transparency, providing depth and brightness.
[*]Node and Label Placement: A circular node is placed at the origin swing price and bar. A directional event label is placed at the break bar offset by a small ATR fraction above for bullish breaks and below for bearish breaks.
[*]Object Count Management: All five object arrays are independently trimmed to the maximum event count by removing the oldest entries, maintaining a clean rolling window of the most recent structural history.

Together, these elements form a continuously updating market structure visualization where every structural event is rendered as a spatially accurate, conviction-weighted curved ribbon that communicates both the structural significance and participation quality of each break.

Interpretation

Market Structure Flow Map should be interpreted as a conviction-weighted structural event history where ribbon visual weight communicates break significance:

[*]Bullish BOS Ribbon (Cyan): Curved ribbon arcing upward from a broken swing high to the break bar, indicating a continuation structural break in the direction of the prevailing bullish structural state. Ribbon width reflects break strength.
[*]Bearish BOS Ribbon (Red): Curved ribbon arcing downward from a broken swing low to the break bar, indicating a continuation structural break in the direction of the prevailing bearish structural state. Ribbon width reflects break strength.
[*]Bullish CHoCH Ribbon (Green): Curved ribbon arcing upward from a broken swing high during a bearish structural state, indicating a potential trend reversal where price has broken bullish structure against the prior downtrend.
[*]Bearish CHoCH Ribbon (Amber): Curved ribbon arcing downward from a broken swing low during a bullish structural state, indicating a potential trend reversal where price has broken bearish structure against the prior uptrend.
[*]Ribbon Thickness: The primary strength indicator. Thick ribbons represent high composite strength with strong displacement and above-average volume. Thin ribbons represent weak breaks that barely cleared the structural level with low participation.
[*]Ribbon Arc Height: Reflects both ATR-relative volatility and the temporal distance between the swing origin and break bar. Tall arcs indicate breaks that developed over many bars or occurred during high-volatility conditions. Flat arcs indicate quick breaks between adjacent swings.
[*]Glow Layer: The wide transparent outer layer provides visual prominence that scales with ribbon width, making the strongest ribbons immediately identifiable across the full chart view.
[*]Core Layer: The bright near-white inner layer provides a luminous center line that reinforces the direction and curvature of each ribbon while adding visual depth to the three-layer geometry.
[*]Structure Nodes (Circles): Circular markers at each ribbon origin anchor the structural event to its precise swing price, making it clear which pivot level was broken to produce each ribbon.
[*]Event Labels: BOS and CHoCH text labels at each break bar identify the event type with color coding matching the ribbon, providing a text-based reference that complements the visual ribbon hierarchy.
[*]Colored Candles: Optional bar coloring reflects the current structural state, coloring cyan during bullish structure and red during bearish structure regardless of individual bar direction.

Ribbon width hierarchy, arc geometry, color coding, and node placement collectively communicate more structural conviction information than text labels alone.

Signal Logic & Visual Cues

Market Structure Flow Map presents four distinct event types across two structural break categories:

[*]Bullish BOS: Cyan ribbon connecting a broken swing high to the break bar during an established bullish structural state, confirming continuation of the prevailing upward structural sequence.
[*]Bearish BOS: Red ribbon connecting a broken swing low to the break bar during an established bearish structural state, confirming continuation of the prevailing downward structural sequence.
[*]Bullish CHoCH: Green ribbon connecting a broken swing high to the break bar during a bearish structural state, signaling a potential reversal of the prevailing downward structural sequence.
[*]Bearish CHoCH: Amber ribbon connecting a broken swing low to the break bar during a bullish structural state, signaling a potential reversal of the prevailing upward structural sequence.

Both BOS and CHoCH events can be independently toggled, allowing the chart to focus exclusively on continuation signals, exclusively on reversal signals, or both simultaneously.

Alert generation covers bullish and bearish structural breaks for systematic structural monitoring workflows.

Strategy Integration

Market Structure Flow Map fits within momentum-validated market structure and conviction-weighted structural analysis approaches:

[*]Ribbon Width Prioritization: Assign greater analytical weight to thick, wide ribbons representing high-strength breaks. Thin ribbons from marginal low-volume breaks carry reduced structural significance and warrant more caution before acting on the direction signal.
[*]CHoCH Reversal Framework: Use green and amber CHoCH ribbons as primary reversal identification signals, treating their appearance as the first confirmation that structural direction may be shifting. Subsequent BOS ribbons in the new direction following a CHoCH provide continuation confirmation.
[*]BOS Continuation Framework: Use cyan and red BOS ribbons as trend continuation evidence within established structural regimes, with wider BOS ribbons providing stronger confirmation of sustained directional momentum.
[*]Arc Length Context: Monitor ribbon arc lengths as a temporal context indicator. Short low arcs between adjacent swings indicate rapid structural progression. Tall arcs spanning many bars indicate structural breaks that required extended time to develop, which may reflect different momentum characteristics than immediate breaks.
[*]Ribbon Density Assessment: The density and direction consistency of recent ribbons provides a visual structural momentum reading. A sequence of uniformly wide same-direction ribbons indicates sustained structural conviction. A mix of widths and directions indicates contested structure without clear dominance.
[*]Multi-Timeframe Structure Hierarchy: Apply higher-timeframe structural state as directional bias context, using lower-timeframe BOS ribbons to time continuation entries within the structural direction established on the higher timeframe.

Technical Implementation Details

[*]Structure Detection: Pivot high and low confirmation with configurable lookback and close or wick break mode selection
[*]Strength Scoring: ATR-normalized displacement combined with SMA-normalized volume excess using configurable weights summing to a 0-1 composite score
[*]Ribbon Geometry: Three-point curved polyline construction with distance-adaptive arc height scaling and strength-proportional line width across three layers
[*]Classification Logic: Structural state tracking for BOS versus CHoCH identification with independent visibility toggles per event type
[*]Object Management: Five independent arrays with configurable maximum event count enforced by oldest-first removal
[*]Candle Coloring: Structural state-driven bar color applied to body, wick, and border independently
[*]Performance Profile: Real-time execution on each confirmed bar with polyline and label objects created at event time and managed through independent array trimming

Optimal Application Parameters

Timeframe Guidance:

[*]1 - 5 min: Intraday structural flow mapping for scalping with shorter swing length for faster structural event detection on smaller swings
[*]15 - 60 min: Session-level structural analysis with balanced swing length and moderate displacement and volume thresholds for meaningful event density across typical session structure
[*]4H - Daily: Swing-level market structure visualization with longer swing detection for broader structural events that reflect significant trend-level breaks

Suggested Baseline Configuration:

[*]Swing Length: 8
[*]Break Confirmation: Close
[*]Volume Average: 20
[*]Displacement Weight: 0.6
[*]Volume Weight: 0.4
[*]Ribbon Arc (ATR×): 0.7
[*]Maximum Events: 35
[*]Show BOS: Enabled
[*]Show CHoCH: Enabled
[*]Show Structure Nodes: Enabled
[*]Color Candles: Disabled

These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's swing frequency, typical displacement characteristics, and preferred structural event density, so fine-tuning is expected for optimal performance.

Parameter Calibration Notes

Use the following adjustments to refine behavior without altering the core logic:

[*]Too many structural events firing: Increase Swing Length to demand more structurally significant pivot confirmation, reducing the frequency of detected breaks, or switch Break Confirmation to Close to filter out wick-based marginal breaks.
[*]Structural events too infrequent: Decrease Swing Length toward 2 for more sensitive pivot detection, or switch to Wick mode to capture structural breaks that close below the level but print a wick through it.
[*]All ribbons appearing similar width: Adjust Max Displacement ATR and Max Volume Ratio to calibrate the scoring thresholds to the instrument's typical break characteristics. If most breaks exceed the maximum thresholds the scoring range collapses and all ribbons appear near maximum width.
[*]Volume scoring not contributing: Decrease Max Volume Ratio to make above-average volume easier to achieve on the scoring scale, or increase Volume Weight to give volume a larger proportion of the composite score.
[*]Ribbons too flat or too curved: Adjust Ribbon Arc ATR to scale the arc height. Lower values produce flatter, more linear ribbons. Higher values produce more pronounced curves, particularly on breaks that span many bars.
[*]Too many ribbons cluttering the chart: Reduce Maximum Events to limit the historical ribbon count, or reduce Swing Length to produce more frequent events that each span shorter temporal distances, resulting in smaller arcs and less visual overlap.

Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

Performance Characteristics

High Effectiveness:

[*]Trending markets with clear directional structural sequences where BOS ribbons accumulate in the trend direction and CHoCH ribbons mark definitive reversal points with distinct visual separation from the preceding BOS sequence
[*]Instruments with consistent volume participation where the volume scoring component produces meaningful differentiation between high-conviction and low-conviction breaks rather than uniform low scores
[*]Market structure-based trading approaches where the visual conviction hierarchy of ribbon widths provides immediate differentiation between structural breaks worth acting on and marginal breaks warranting caution
[*]Multi-timeframe structural analysis where the ribbon history provides a visual structural narrative that communicates trend progression, reversal identification, and conviction levels simultaneously

Reduced Effectiveness:

[*]Choppy, range-bound markets where frequent alternating BOS and CHoCH events in both directions produce a dense mixed-color ribbon cluster without a clear structural narrative
[*]Low-liquidity instruments where volume is consistently below average, suppressing volume strength scores and causing most ribbons to render at or near minimum width regardless of structural significance
[*]Markets with very large or small typical ATR ranges where the arc height calculations produce ribbons that are either too flat to read or that arc so dramatically they dominate the visible chart area
[*]Extremely fast-moving markets where structural breaks occur on single large bars that span large price distances, producing short temporal ribbons that offer limited visual differentiation from one another
[*]Consolidation environments where price oscillates between two nearby swing levels without establishing clear directional structural progression, generating frequent opposing CHoCH events without the sustained BOS sequences that define clear structural trends

Integration Guidelines

[*]Confluence: Combine with BOSWaves volume flow tools, order flow analysis, or momentum indicators to validate high-strength CHoCH and BOS ribbons with broader analytical context before committing to structural direction trades
[*]Width Hierarchy Respect: Build a ribbon width filter into your analysis workflow. Thin ribbons from marginal breaks should be treated as weak structural evidence requiring additional confirmation. Thick ribbons from high-displacement high-volume breaks warrant greater directional confidence.
[*]CHoCH Sequencing: A single CHoCH ribbon is not sufficient confirmation of a structural reversal in isolation. Wait for a subsequent BOS ribbon in the new direction to confirm that structural momentum has genuinely shifted before treating the CHoCH as a completed reversal.
[*]Arc Geometry Reading: Use ribbon arc height as a secondary strength indicator. Tall arcs on strong ribbons indicate breaks that developed over many bars with sustained momentum. Short arcs on strong ribbons indicate rapid decisive breaks that required minimal time to complete.
[*]State Discipline: Maintain structural bias aligned with the current state established by the most recent CHoCH until a new CHoCH in the opposing direction confirms a structural shift. Individual BOS ribbons within an established trend do not alter the structural regime and should be interpreted as continuation rather than reversal evidence.

Disclaimer

Market Structure Flow Map [BOSWaves] is a professional-grade market structure visualization and conviction-weighted structural event analysis tool. It uses pivot-based break detection with composite displacement and volume strength scoring but does not predict future price movements. Results depend on market conditions, instrument structural characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, volume analysis, and comprehensive risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator(
     "Market Structure Flow Map [BOSWaves]",
     overlay = true,
     max_polylines_count = 100,
     max_labels_count = 300,
     max_lines_count = 50,
     max_bars_back = 500)

// ┌────────────────────────────── BOSWaves ─ Groups ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gStruct = "Structure"
const string gFlow   = "Flow Strength"
const string gRibbon = "Ribbon Rendering"
const string gVis    = "Display"

// ┌────────────────────────────── BOSWaves ─ Tooltips ────────────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
const string tt_swingLen   = "Pivot confirmation length used to define structural swing highs and lows. Higher values create fewer, larger structural events."
const string tt_breakMode  = "Close requires price to close through structure. Wick allows the candle extreme to trigger the break."
const string tt_dispWeight = "Contribution of displacement beyond the broken structure level to ribbon strength."
const string tt_volWeight  = "Contribution of relative breakout volume to ribbon strength."
const string tt_dispMax    = "Displacement in ATR multiples considered maximum strength. Values beyond this are capped."
const string tt_volMax     = "Volume relative to its moving average considered maximum strength."
const string tt_arc        = "Vertical curvature of each structure ribbon in ATR units."
const string tt_maxEvents  = "Maximum number of historical BOS / CHoCH ribbons retained on the chart."
const string tt_candles    = "Colors price candles according to the active structural regime."
const string tt_labelSize  = "Size of the BOS / CHoCH event labels and structure node markers."
const string tt_volLen     = "Lookback length used to calculate the average volume that breakout volume is compared against."
const string tt_minWidth   = "Ribbon line width used for the weakest structural breaks."
const string tt_maxWidth   = "Ribbon line width used for the strongest structural breaks."
const string tt_showBOS    = "Toggles ribbons and labels for Break of Structure events, where price continues in the direction of the prevailing trend."
const string tt_showCHoCH  = "Toggles ribbons and labels for Change of Character events, where price breaks structure against the prevailing trend."
const string tt_showNodes  = "Toggles the circular markers plotted at the swing high or low that was broken to create each structural event."
const string tt_bullCol    = "Color used for bullish Break of Structure ribbons and labels."
const string tt_bearCol    = "Color used for bearish Break of Structure ribbons and labels."
const string tt_bullShift  = "Color used for bullish Change of Character ribbons and labels."
const string tt_bearShift  = "Color used for bearish Change of Character ribbons and labels."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
int    swingLen     = input.int(8, "Swing Length", minval = 2, maxval = 50, group = gStruct, tooltip = tt_swingLen)
string breakMode    = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = gStruct, tooltip = tt_breakMode)

int    volLen       = input.int(20, "Volume Average", minval = 5, maxval = 100, group = gFlow, tooltip = tt_volLen)
float  dispWeight   = input.float(0.6, "Displacement Weight", minval = 0, maxval = 1, step = 0.05, group = gFlow, tooltip = tt_dispWeight)
float  volWeight    = input.float(0.4, "Volume Weight", minval = 0, maxval = 1, step = 0.05, group = gFlow, tooltip = tt_volWeight)
float  maxDispATR   = input.float(0.8, "Max Displacement (ATR×)", minval = 0.1, maxval = 3, step = 0.1, group = gFlow, tooltip = tt_dispMax)
float  maxVolRatio  = input.float(2.5, "Max Volume Ratio", minval = 1, maxval = 5, step = 0.1, group = gFlow, tooltip = tt_volMax)

float  arcATR       = input.float(0.7, "Ribbon Arc (ATR×)", minval = 0.1, maxval = 3, step = 0.1, group = gRibbon, tooltip = tt_arc)
int    minWidth     = input.int(2, "Minimum Width", minval = 1, maxval = 5, group = gRibbon, tooltip = tt_minWidth)
int    maxWidth     = input.int(8, "Maximum Width", minval = 3, maxval = 12, group = gRibbon, tooltip = tt_maxWidth)
int    maxEvents    = input.int(35, "Maximum Events", minval = 5, maxval = 70, group = gRibbon, tooltip = tt_maxEvents)

bool   showBOS      = input.bool(true, "Show BOS", group = gVis, tooltip = tt_showBOS)
bool   showCHoCH    = input.bool(true, "Show CHoCH", group = gVis, tooltip = tt_showCHoCH)
bool   showNodes    = input.bool(true, "Show Structure Nodes", group = gVis, tooltip = tt_showNodes)
bool   paintBars    = input.bool(false, "Color Candles", group = gVis, tooltip = tt_candles)
string labelSizeIn  = input.string("Tiny", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gVis, tooltip = tt_labelSize)

color  bullCol      = input.color(#00e5ff, "Bullish", inline = "c1", group = gVis, tooltip = tt_bullCol)
color  bearCol      = input.color(#ff3264, "Bearish", inline = "c1", group = gVis, tooltip = tt_bearCol)
color  bullShiftCol = input.color(#00ff88, "Bull CHoCH", inline = "c2", group = gVis, tooltip = tt_bullShift)
color  bearShiftCol = input.color(#ffb300, "Bear CHoCH", inline = "c2", group = gVis, tooltip = tt_bearShift)

// ┌────────────────────────────── BOSWaves ─ Helpers ─────────────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
f_labelSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.tiny

string lblSize = f_labelSize(labelSizeIn)

// ┌────────────────────────────── BOSWaves ─ Core Measurements ───────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
float atr    = ta.atr(14)
float volAvg = ta.sma(volume, volLen)

float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

// ┌────────────────────────────── BOSWaves ─ Structure State ─────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
var float lastHighPrice = na
var float lastLowPrice  = na

var int lastHighBar = na
var int lastLowBar  = na

var bool highBroken = false
var bool lowBroken  = false

var int structureState = 0

if not na(ph)
    lastHighPrice := ph
    lastHighBar   := bar_index - swingLen
    highBroken    := false

if not na(pl)
    lastLowPrice := pl
    lastLowBar   := bar_index - swingLen
    lowBroken    := false

float bullBreakSrc = breakMode == "Close" ? close : high
float bearBreakSrc = breakMode == "Close" ? close : low

float bullPrevSrc = breakMode == "Close" ? close[1] : high[1]
float bearPrevSrc = breakMode == "Close" ? close[1] : low[1]

bool bullBreak =
     not highBroken and
     not na(lastHighPrice) and
     bullBreakSrc > lastHighPrice and
     bullPrevSrc <= lastHighPrice

bool bearBreak =
     not lowBroken and
     not na(lastLowPrice) and
     bearBreakSrc < lastLowPrice and
     bearPrevSrc >= lastLowPrice

// ┌────────────────────────────── BOSWaves ─ Drawing Storage ─────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
var polyline[] ribbonGlow = array.new<polyline>()
var polyline[] ribbonBody = array.new<polyline>()
var polyline[] ribbonCore = array.new<polyline>()

var label[] eventLabels = array.new<label>()
var label[] pivotNodes  = array.new<label>()

// ┌────────────────────────────── BOSWaves ─ Bullish Break ───────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
if bullBreak
    bool isCHoCH = structureState == -1
    bool visible = isCHoCH ? showCHoCH : showBOS

    highBroken := true

    float breakPx = breakMode == "Close" ? close : high

    float displacement = math.max(0, breakPx - lastHighPrice)
    float dispN = atr > 0 ? math.min(displacement / (atr * maxDispATR), 1) : 0

    float volRatio = volAvg > 0 ? volume / volAvg : 1
    float volN = math.min(math.max((volRatio - 1) / math.max(maxVolRatio - 1, 0.01), 0), 1)

    float weightTotal = math.max(dispWeight + volWeight, 0.01)
    float strength = math.min(
         (dispN * dispWeight + volN * volWeight) / weightTotal,
         1)

    int bodyWidth = int(math.round(
         minWidth + strength * (maxWidth - minWidth)))

    int glowWidth = math.min(bodyWidth + 5, 15)
    int coreWidth = math.max(1, bodyWidth - 2)

    color eventCol = isCHoCH ? bullShiftCol : bullCol

    int startX = lastHighBar
    int endX   = bar_index
    int midX   = startX + int(math.round((endX - startX) * 0.52))

    float distanceFactor = math.min(
         math.max(float(endX - startX) / 40, 0.35),
         1.5)

    float arcHeight =
         atr *
         arcATR *
         distanceFactor *
         (0.7 + strength * 0.55)

    float startY = lastHighPrice
    float endY   = breakPx
    float midY   = math.max(startY, endY) + arcHeight

    if visible
        ptsGlow = array.new<chart.point>()
        ptsGlow.push(chart.point.from_index(startX, startY))
        ptsGlow.push(chart.point.from_index(midX, midY))
        ptsGlow.push(chart.point.from_index(endX, endY))

        ptsBody = array.new<chart.point>()
        ptsBody.push(chart.point.from_index(startX, startY))
        ptsBody.push(chart.point.from_index(midX, midY))
        ptsBody.push(chart.point.from_index(endX, endY))

        ptsCore = array.new<chart.point>()
        ptsCore.push(chart.point.from_index(startX, startY))
        ptsCore.push(chart.point.from_index(midX, midY))
        ptsCore.push(chart.point.from_index(endX, endY))

        ribbonGlow.push(polyline.new(
             ptsGlow,
             curved = true,
             line_color = color.new(eventCol, 82),
             line_width = glowWidth))

        ribbonBody.push(polyline.new(
             ptsBody,
             curved = true,
             line_color = color.new(eventCol, 18),
             line_width = bodyWidth))

        ribbonCore.push(polyline.new(
             ptsCore,
             curved = true,
             line_color = color.new(color.white, 18),
             line_width = coreWidth))

        if showNodes
            pivotNodes.push(label.new(
                 lastHighBar,
                 lastHighPrice,
                 "",
                 style = label.style_circle,
                 color = color.new(eventCol, 5),
                 size = lblSize))

        eventLabels.push(label.new(
             bar_index,
             endY + atr * 0.12,
             isCHoCH ? "CHoCH" : "BOS",
             style = label.style_label_down,
             color = color.new(eventCol, 5),
             textcolor = isCHoCH ? color.black : color.white,
             size = lblSize))

    structureState := 1

// ┌────────────────────────────── BOSWaves ─ Bearish Break ───────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
if bearBreak
    bool isCHoCH = structureState == 1
    bool visible = isCHoCH ? showCHoCH : showBOS

    lowBroken := true

    float breakPx = breakMode == "Close" ? close : low

    float displacement = math.max(0, lastLowPrice - breakPx)
    float dispN = atr > 0 ? math.min(displacement / (atr * maxDispATR), 1) : 0

    float volRatio = volAvg > 0 ? volume / volAvg : 1
    float volN = math.min(math.max((volRatio - 1) / math.max(maxVolRatio - 1, 0.01), 0), 1)

    float weightTotal = math.max(dispWeight + volWeight, 0.01)
    float strength = math.min(
         (dispN * dispWeight + volN * volWeight) / weightTotal,
         1)

    int bodyWidth = int(math.round(
         minWidth + strength * (maxWidth - minWidth)))

    int glowWidth = math.min(bodyWidth + 5, 15)
    int coreWidth = math.max(1, bodyWidth - 2)

    color eventCol = isCHoCH ? bearShiftCol : bearCol

    int startX = lastLowBar
    int endX   = bar_index
    int midX   = startX + int(math.round((endX - startX) * 0.52))

    float distanceFactor = math.min(
         math.max(float(endX - startX) / 40, 0.35),
         1.5)

    float arcHeight =
         atr *
         arcATR *
         distanceFactor *
         (0.7 + strength * 0.55)

    float startY = lastLowPrice
    float endY   = breakPx
    float midY   = math.min(startY, endY) - arcHeight

    if visible
        ptsGlow = array.new<chart.point>()
        ptsGlow.push(chart.point.from_index(startX, startY))
        ptsGlow.push(chart.point.from_index(midX, midY))
        ptsGlow.push(chart.point.from_index(endX, endY))

        ptsBody = array.new<chart.point>()
        ptsBody.push(chart.point.from_index(startX, startY))
        ptsBody.push(chart.point.from_index(midX, midY))
        ptsBody.push(chart.point.from_index(endX, endY))

        ptsCore = array.new<chart.point>()
        ptsCore.push(chart.point.from_index(startX, startY))
        ptsCore.push(chart.point.from_index(midX, midY))
        ptsCore.push(chart.point.from_index(endX, endY))

        ribbonGlow.push(polyline.new(
             ptsGlow,
             curved = true,
             line_color = color.new(eventCol, 82),
             line_width = glowWidth))

        ribbonBody.push(polyline.new(
             ptsBody,
             curved = true,
             line_color = color.new(eventCol, 18),
             line_width = bodyWidth))

        ribbonCore.push(polyline.new(
             ptsCore,
             curved = true,
             line_color = color.new(color.white, 18),
             line_width = coreWidth))

        if showNodes
            pivotNodes.push(label.new(
                 lastLowBar,
                 lastLowPrice,
                 "",
                 style = label.style_circle,
                 color = color.new(eventCol, 5),
                 size = lblSize))

        eventLabels.push(label.new(
             bar_index,
             endY - atr * 0.12,
             isCHoCH ? "CHoCH" : "BOS",
             style = label.style_label_up,
             color = color.new(eventCol, 5),
             textcolor = isCHoCH ? color.black : color.white,
             size = lblSize))

    structureState := -1

// ┌────────────────────────────── BOSWaves ─ Object Management ───────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
while ribbonBody.size() > maxEvents
    polyline.delete(ribbonBody.shift())

while ribbonGlow.size() > maxEvents
    polyline.delete(ribbonGlow.shift())

while ribbonCore.size() > maxEvents
    polyline.delete(ribbonCore.shift())

while eventLabels.size() > maxEvents
    label.delete(eventLabels.shift())

while pivotNodes.size() > maxEvents
    label.delete(pivotNodes.shift())

// ┌────────────────────────────── BOSWaves ─ Candle Coloring ─────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
color stateCol = structureState == 1 ? bullCol : structureState == -1 ? bearCol : chart.fg_color

color candleBody = paintBars ? color.new(stateCol, 18) : na
color candleWick = paintBars ? color.new(stateCol, 35) : na

plotcandle(
     open,
     high,
     low,
     close,
     "Structure Candles",
     color = candleBody,
     wickcolor = candleWick,
     bordercolor = candleBody,
     display = paintBars ? display.all : display.none)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(bullBreak, "Bullish Structure Break", "Bullish structure break on {{ticker}}")
alertcondition(bearBreak, "Bearish Structure Break", "Bearish structure break on {{ticker}}")
````
