<!-- tradingview-pine-id: PUB;265b5fa74bc64c099ba60a75a57df35d -->
<!-- tradingviewscripts-format: 1 -->
# Swing Structure Forecast [BOSWaves]

Source: https://www.tradingview.com/script/Ft4zyO1F-Swing-Structure-Forecast-BOSWaves/

## Description

Swing Structure Forecast [BOSWaves] - Statistical Swing Projection System with Volatility-Adaptive Support and Resistance Detection

Overview

Swing Structure Forecast [BOSWaves] is a statistically-driven swing analysis system that maps directional price structure through confirmed pivot identification, where support and resistance zones construct automatically at each swing extreme and a probabilistic forecast beam projects the next swing leg using aggregated historical swing measurements.

[image]https://www.tradingview.com/x/DGrUDanz/[/image]

Rather than applying fixed price targets, universal extension ratios, or lagging directional filters, zone boundaries, forecast direction, and projection magnitude are governed by structural pivot confirmation, ATR-proportioned zone sizing, and rolling statistical measurement of completed swing history across a configurable sample window.

This produces a continuously refreshed structural map alongside a data-grounded forward projection. Zones breathe with volatility cycles and forecasts are calibrated to the instrument's own measured behaviour rather than theoretical constants or fixed multiples.

Price is therefore assessed against structurally-anchored zones derived from confirmed swing pivots, with directional expectations built from the statistical record of prior completed legs rather than external reference points.

Conceptual Framework

Swing Structure Forecast is built on the premise that genuine support and resistance originate at confirmed swing extremes, and that the statistical character of completed swing legs contains meaningful information about the magnitude and duration of the move that will follow.

Standard projection methodologies apply predetermined ratios that treat every instrument and market condition as interchangeable. This framework instead extracts magnitude expectations from the instrument's own swing record, building an evidence base from recent completed legs and distilling it into a statistically-grounded projection originating at the current confirmed pivot.

Three core principles shape the design:

[*]Support and resistance zones should originate at structurally confirmed swing highs and lows, not at indicator crossovers, arbitrary distances, or price patterns lacking pivot confirmation.
[*]Zone width must respond to prevailing volatility, expanding proportionally when ATR is elevated and compressing when market conditions quieten.
[*]Forecast targets and projection uncertainty should be derived from the distribution of the instrument's own recent swing history, with variability expressed visually rather than hidden behind a single projected level.

This repositions price structure work from passive historical reference into an active, instrument-specific projection framework that updates with each new confirmed swing.

Theoretical Foundation

The indicator unifies structural pivot detection, ATR-responsive zone construction, rolling statistical aggregation, and Fibonacci extension mapping.

Swing highs and lows are established through a rolling highest/lowest comparison across a configurable lookback window, accepting only pivots surrounded by sufficient structural confirmation on both sides. A 200-period ATR provides a slow-moving, stable volatility reference that scales zone thickness and beam width proportionately across varying instruments and timeframes. Completed swing percentages and durations populate a rolling sample array, with three aggregation modes — weighted, average, and median — giving users direct control over how heavily recent legs are weighted against older history. Standard deviation across this sample governs beam width, producing narrow projections when swing history is consistent and widening the beam when prior legs have varied significantly in magnitude.

Four internal systems work in coordination:

[*]Pivot Detection Engine: Confirms swing highs and lows through multi-bar structural comparison, withholding confirmation until price movement validates the extreme and eliminating repainting.
[*]Zone Construction System: Builds dual-layer ATR-proportioned boxes at each confirmed pivot, applying progressive opacity reduction with age and monitoring for structural breach events.
[*]Forecast Engine: Processes the rolling swing sample through the selected statistical method and casts the next projected leg as a smoothed cone beam originating at the current pivot, scaled by historical variance.
[*]Fibonacci Extension System: Deploys individually toggleable extension levels beyond the primary forecast target, each with a fully configurable ratio for defining continuation objectives.

This structure keeps the structural map and forward projection permanently coupled, refreshing in unison whenever a new swing confirms.

How It Works

Swing Structure Forecast processes price through a structured sequence of pivot-aware operations:

[*]Pivot Confirmation: Bar highs and lows are continuously compared against a rolling window of configurable length. A swing high locks in once price retreats sufficiently from the peak; a swing low locks in once price advances sufficiently from the trough, ensuring no repainting occurs.
[*]Zone Placement: A dual-layer box anchors at each confirmed pivot. An outer boundary encloses the broader reaction area and an inner zone concentrates the higher-probability interaction region.
[*]Age-Based Fading: Zone opacity diminishes progressively as elapsed bars accumulate since formation, weighting recent structural levels visually above older historical context.
[*]Breach Detection: A close beyond a zone's anchor level triggers conversion to a dotted outline and initiates an automatic removal sequence, purging invalidated structure from the chart.
[*]Swing Recording: Each completed leg is logged as a percentage magnitude and a bar duration into the rolling sample array, capped at the user-defined sample count with oldest entries discarded first.
[*]Statistical Aggregation: The selected method, weighted, average, or median, resolves the sample into an expected magnitude and duration for the forthcoming swing leg.
[*]Beam Construction: A three-layer cone extends forward from the current pivot anchor using smoothstep-eased interpolation, with width proportional to sample standard deviation and opacity grading across nested layers.
[*]Target Zone: A bounding box placed at the beam terminus presents the projected price level and expected percentage move, with box height communicating the degree of forecast uncertainty.
[*]Fibonacci Extensions: Configurable ratio levels project beyond the primary target, establishing pre-mapped objectives for continuation moves that exceed the base projection.

These processes collectively sustain a live structural framework and a statistically-grounded projection that regenerates with every newly confirmed swing pivot.

Interpretation

Swing Structure Forecast should be read as a structural boundary map combined with a probabilistic directional projection:

[*]Support Zones (Green): Constructed at confirmed swing lows, marking price regions where prior downside pressure exhausted and upward reversals originated.
[*]Resistance Zones (Red): Established at confirmed swing highs, identifying areas where prior upside pressure stalled and downward reversals began.
[*]Zone Opacity: Communicates structural age. Vivid zones reflect recent pivot formation; subdued zones represent older levels retained for broader historical context.
[*]Broken Zones: Transition to faint dotted outlines on breach, preserved as reference markers without visually competing with structurally intact levels.
[*]Forecast Beam: Extends forward from the most recently confirmed pivot, projecting the statistically expected next leg. Cone width encodes uncertainty drawn from sample variance.
[*]Narrow Beam: Prior swing history shows consistent magnitude, indicating relatively high projection confidence.
[*]Wide Beam: Prior swing history shows significant variability, indicating greater uncertainty and warranting additional confirmation before acting.
[*]Target Zone and Label: Mark the statistically derived price destination alongside expected percentage move and absolute price level.
[*]Fibonacci Extensions: Pre-mapped levels beyond the primary target defining structured continuation objectives for extended directional moves.
[*]Path Markers: Dot markers positioned along the beam centerline with opacity fading toward the target, conveying projected trajectory and directional progression.

Structural context, beam width, and sample consistency are more significant than any individual projected value in isolation.

Signal Logic and Visual Cues

Swing Structure Forecast operates through two principal visual frameworks:

[*]Structural Zones: Continuously maintained support and resistance boxes anchored at confirmed pivots. Intact zones carry unbroken structural relevance; broken zones document levels that price has already closed through and structurally dismissed.
[*]Forecast Beam: Repositions automatically on every new swing confirmation, simultaneously refreshing the beam geometry, target zone, path markers, and Fibonacci extensions to reflect the updated pivot origin and current statistical aggregation.

Alert conditions trigger on confirmed swing high and swing low events, supporting systematic structural monitoring without requiring active chart observation.

Strategy Integration

Swing Structure Forecast applies across structure-based, mean-reversion, and trend-continuation trading methodologies:

[*]Structure-Referenced Entries: Treat intact zones as interaction boundaries for entry decisions, assigning greater weight to recently formed levels over aged, heavily faded structure.
[*]Instrument-Calibrated Targets: Use the statistical projection as a primary take-profit reference built from the instrument's own measured swing history rather than applied universal ratios.
[*]Beam Width Conviction Scaling: Adjust confirmation requirements relative to current beam width. Wide beams call for additional validation before committing; narrow beams reflect historically stable swing magnitude.
[*]Fibonacci Continuation Planning: Reference extension levels beyond the primary target when trending conditions suggest the initial projection may be exceeded.
[*]Broken Zone Flip Monitoring: Track recently breached zones as candidate reversal levels where former support may transition to resistance and vice versa following structural invalidation.
[*]Multi-Timeframe Structural Context: Reference higher-timeframe zones as macro boundaries while applying lower-timeframe forecast projections for entry precision and target identification.
[*]Sample Population Patience: Defer high-conviction treatment of projection outputs until the sample window has accumulated sufficient completed swings, particularly on instruments or timeframes with limited history.

Technical Implementation Details

[*]Core Engine: Rolling highest/lowest pivot detection with configurable lookback and no-repaint confirmation logic
[*]Zone Construction: Dual-layer ATR-proportioned boxes with progressive opacity fading, breach detection, and automatic invalidation removal
[*]Statistical Model: Weighted, average, or median aggregation across configurable rolling sample with standard deviation uncertainty scaling
[*]Forecast Geometry: Smoothstep-eased three-layer polyline beam with standard deviation width scaling and graduated opacity
[*]Target Visualisation: Projection label with percentage move and price level enclosed by uncertainty-proportioned target box
[*]Fibonacci System: Five independently toggleable extension levels with fully configurable ratios
[*]Alert Coverage: Swing high confirmation and swing low confirmation events
[*]Performance Profile: Optimised for real-time execution across all timeframes with configurable zone capacity and sample limits

Optimal Application Parameters

Timeframe Guidance:

[*]1 - 15 min: Near-term swing structure with short-horizon projection for intraday approaches
[*]1H - 4H: Intraday to multi-session structural mapping with intermediate forecast range
[*]Daily - Weekly: Macro swing structure identification with extended projection targets

Suggested Baseline Configuration:

[*]Swing Length: 16
[*]Zone Width (ATR): 0.3
[*]Max Level Age: 300 bars
[*]Samples: 20
[*]Method: Weighted
[*]Forecast Bars: 5
[*]Fib Extensions: 1.0, 1.272, 1.618 active

These suggested parameters serve as a starting baseline; their effectiveness varies with the instrument's volatility profile, characteristic swing cadence, and preferred zone density, so incremental adjustment across multiple session types is recommended before drawing performance conclusions.

Parameter Calibration Notes

Apply the following refinements to adjust behaviour without modifying core logic:

[*]Zones too wide: Lower Zone Width (ATR) to narrow zone boundaries, particularly on lower timeframes where ATR values produce oversized zones relative to typical price movement.
[*]Too many zones forming: Raise Swing Length to impose stricter structural requirements before a pivot qualifies for zone creation.
[*]Beam excessively wide: Sample history contains high variance. Raise Samples to dilute outlier legs or switch to Median to limit their influence on the projected magnitude.
[*]Projection slow to reflect recent behaviour: Lower Samples or switch to Weighted method to concentrate projection weight on the most recently completed swing legs.
[*]Significant pivots going undetected: Lower Swing Length to increase sensitivity and qualify shorter structural moves as confirmed pivots.
[*]Forecast visual range misaligned with chart: Modify Forecast Bars to adjust how far projection visuals extend rightward without altering the underlying price target calculation.
[*]Stale levels persisting on chart: Reduce Max Level Age to accelerate removal of older unbroken zones, keeping structural reference anchored to recent pivot history.

Adjustments should be applied incrementally and assessed across varied session conditions rather than calibrated against a single market period.

Performance Characteristics

High Effectiveness:

[*]Markets exhibiting rhythmic swing sequences with clearly defined structural turning points
[*]Instruments where volatility follows identifiable expansion and contraction patterns that ATR captures proportionately
[*]Trend-continuation approaches targeting measured extensions derived from the instrument's own swing record
[*]Mean-reversion strategies using confirmed structural zones as primary entry and exit reference boundaries

Reduced Effectiveness:

[*]Directionless, low-conviction conditions generating frequent shallow pivots that populate the sample with structurally insignificant measurements
[*]Event-driven or gap-heavy sessions producing swing magnitudes that are unrepresentative of normal instrument behaviour
[*]Instruments with erratic or non-stationary volatility profiles where ATR-based proportioning loses consistency
[*]Early sessions on a given timeframe before sufficient completed swings have accumulated to produce statistically reliable projections

Integration Guidelines

[*]Confluence: Pair with BOSWaves volume tools, order flow indicators, or broader market structure analysis to reinforce zone and forecast interpretation
[*]Sample Discipline: Reserve high-conviction treatment for projections generated once the sample window is fully populated with completed swings
[*]Breach Acceptance: Treat breached zones as structurally void and resist anchoring expectations to levels price has already invalidated with a closing breach
[*]Beam Width Respect: Read a wide beam as a requirement for additional confirmation before acting, not permission to disregard the projection entirely
[*]Directional Consistency: Sustain bias aligned with the current forecast direction until a newly confirmed swing pivot shifts the projection origin
[*]Timeframe Confluence: Highest-quality structural setups emerge when active zones and forecast direction correspond across multiple timeframes simultaneously

Disclaimer

Swing Structure Forecast [BOSWaves] is a professional-grade swing structure and statistical forecasting tool. All projections are derived from historical swing behaviour and represent probabilistic expectations rather than assured outcomes. Performance depends on the consistency of prior swing history, prevailing market conditions, parameter selection, and disciplined application. BOSWaves recommends deploying this indicator as one component within a comprehensive analytical framework incorporating trend context, volume analysis, and rigorous risk management practices.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Swing Structure Forecast [BOSWaves]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ┌───────────────────────────── BOSWaves ─ Inputs ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

GRP_DETECT = "Detection"
swingLen = input.int(16, "Swing Length", minval = 10, group = GRP_DETECT, tooltip = "Number of bars used to identify swing highs and lows. Larger values produce fewer but stronger, more significant pivots. Smaller values are more sensitive and catch minor swings.")

GRP_SR = "Support / Resistance"
showLevels   = input.bool(true,  "Show S/R Levels",  group = GRP_SR, tooltip = "Toggle visibility of all support and resistance zones. When off, no zones or level lines are drawn.")
zoneATR      = input.float(0.3,  "Zone Width (ATR)", minval = 0.05, maxval = 0.5, step = 0.05, group = GRP_SR, tooltip = "Controls the height of each S/R zone as a multiple of ATR(200). Higher values create wider zones that are easier to see but less precise.")
maxAge       = input.int(300,    "Max Level Age",    minval = 30, group = GRP_SR, tooltip = "Maximum number of bars an unbroken S/R level will remain on the chart before being removed. Broken levels are removed after 30 bars regardless of this setting.")

GRP_PROJ = "Forecast"
samples      = input.int(20,           "Samples",         minval = 3, maxval = 20, group = GRP_PROJ, tooltip = "Number of the most recent completed swing legs used to calculate the forecast. Higher values smooth out outliers; lower values react faster to recent behaviour.")
method       = input.string("Weighted", "Method",         ["Weighted", "Average", "Median"], group = GRP_PROJ, tooltip = "Statistical method used to aggregate swing history.\n\nWeighted: recent swings have more influence.\nAverage: all swings weighted equally.\nMedian: uses the middle value, ignoring outliers.")
fwdBars      = input.int(5,            "Forecast Bars",   minval = 5, group = GRP_PROJ, tooltip = "How many bars ahead the forecast beam and target zone are projected. Does not affect the price target calculation — only how far right the visuals extend.")
showBeam     = input.bool(true,        "Projection Beam", group = GRP_PROJ, tooltip = "Show the layered cone-shaped beam representing the projected path and uncertainty range. The beam widens with higher standard deviation across recent swings.")
showTarget   = input.bool(true,        "Target Zone",     group = GRP_PROJ, tooltip = "Show the target box at the end of the forecast beam. The box height is derived from the standard deviation of recent swing sizes — wider box means less consistent history.")
showDots     = input.bool(true,        "Path Markers",    group = GRP_PROJ, tooltip = "Show small dot markers along the center trajectory of the forecast beam. Dots fade in opacity as they approach the target, giving a sense of the projected path.")
showFibs     = input.bool(true,    "Fib Extensions",  group = GRP_PROJ, tooltip = "Draw Fibonacci extension levels beyond the forecast target. Enable or disable individual levels using the inputs below.")
fib1Active   = input.bool(true,    "Level 1",         group = GRP_PROJ, inline = "f1")
fib1Val      = input.float(1.0,    "",                group = GRP_PROJ, inline = "f1", minval = 0.001, step = 0.001, tooltip = "First Fibonacci extension level. 1.0 = 100% of the projected move.")
fib2Active   = input.bool(true,    "Level 2",         group = GRP_PROJ, inline = "f2")
fib2Val      = input.float(1.272,  "",                group = GRP_PROJ, inline = "f2", minval = 0.001, step = 0.001, tooltip = "Second Fibonacci extension level. 1.272 = 127.2% of the projected move.")
fib3Active   = input.bool(true,    "Level 3",         group = GRP_PROJ, inline = "f3")
fib3Val      = input.float(1.618,  "",                group = GRP_PROJ, inline = "f3", minval = 0.001, step = 0.001, tooltip = "Third Fibonacci extension level. 1.618 = 161.8% of the projected move.")
fib4Active   = input.bool(false,   "Level 4",         group = GRP_PROJ, inline = "f4")
fib4Val      = input.float(2.0,    "",                group = GRP_PROJ, inline = "f4", minval = 0.001, step = 0.001, tooltip = "Fourth Fibonacci extension level. Disabled by default. 2.0 = 200% of the projected move.")
fib5Active   = input.bool(false,   "Level 5",         group = GRP_PROJ, inline = "f5")
fib5Val      = input.float(2.618,  "",                group = GRP_PROJ, inline = "f5", minval = 0.001, step = 0.001, tooltip = "Fifth Fibonacci extension level. Disabled by default. 2.618 = 261.8% of the projected move.")

GRP_CLR = "Colors"
bullClr      = input.color(#00ff00, "Bull",     inline = "c",  group = GRP_CLR, tooltip = "Color used for bullish swing S/R zones and support levels.")
bearClr      = input.color(#ff0000, "Bear",     inline = "c",  group = GRP_CLR, tooltip = "Color used for bearish swing S/R zones and resistance levels.")
projClr      = input.color(#42a5f5, "Forecast", inline = "c2", group = GRP_CLR, tooltip = "Color used for the projection beam, center trajectory line, path markers, and target zone.")
fibClr       = input.color(#ffeb3b, "Fib",      inline = "c2", group = GRP_CLR, tooltip = "Color used for all Fibonacci extension lines and their labels.")

CLEAR = color.new(color.black, 100)

// ┌───────────────────────────── BOSWaves ─ Types ───────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

type Pivot
    float price
    int   idx

type SRZone
    float price
    int   startIdx
    bool  isResistance
    bool  broken
    box   outerBox
    box   innerBox
    line  lvlLine

// ┌───────────────────────────── BOSWaves ─ State ───────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

var hi   = Pivot.new(na, na)
var lo   = Pivot.new(na, na)
var bool dir = false

var srZones = array.new<SRZone>()
var pcts    = array.new<float>()
var durs    = array.new<float>()

var polyline beamOuter  = na
var polyline beamMid    = na
var polyline beamInner  = na
var line     centerLine = na
var box      tgtOuter   = na
var box      tgtInner   = na
var label    tgtLabel   = na
var label[]  dots       = array.new<label>()
var line[]   fibLines   = array.new<line>()
var label[]  fibLabels  = array.new<label>()

atr = ta.atr(200)

// ┌───────────────────────────── BOSWaves ─ Beam Builder ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

buildBeamPts(int oIdx, int tIdx, float orig, float tgt, float bHalf, float mult, int steps) =>
    pts = array.new<chart.point>()
    for s = 0 to steps
        t     = s / float(steps)
        eased = t * t * (3.0 - 2.0 * t)
        x     = oIdx + int((tIdx - oIdx) * t)
        yc    = orig + (tgt - orig) * eased
        sp    = bHalf * mult * eased
        pts.push(chart.point.from_index(x, yc + sp))
    for s = steps to 0
        t     = s / float(steps)
        eased = t * t * (3.0 - 2.0 * t)
        x     = oIdx + int((tIdx - oIdx) * t)
        yc    = orig + (tgt - orig) * eased
        sp    = bHalf * mult * eased
        pts.push(chart.point.from_index(x, yc - sp))
    pts

// ┌───────────────────────────── BOSWaves ─ Pivot Detection ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

H = ta.highest(high, swingLen)
L = ta.lowest(low, swingLen)

if high == H
    dir := true
if low == L
    dir := false

if high[1] == H[1] and high < H
    hi.idx   := bar_index[1]
    hi.price := high[1]

if low[1] == L[1] and low > L
    lo.idx   := bar_index[1]
    lo.price := low[1]

// ┌───────────────────────────── BOSWaves ─ Swing Recording & S/R Creation ──────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

if dir != dir[1]

    pct  = not dir ? (hi.price - lo.price) / lo.price * 100 : (lo.price - hi.price) / hi.price * 100
    bars = math.abs(hi.idx - lo.idx)

    pcts.push(math.abs(pct))
    durs.push(bars)
    if pcts.size() > samples
        pcts.shift()
        durs.shift()

    if showLevels
        zWidth = atr * zoneATR

        if dir
            z = SRZone.new()
            z.price        := hi.price
            z.startIdx     := hi.idx
            z.isResistance := true
            z.broken       := false
            z.outerBox     := box.new(hi.idx, hi.price + zWidth, bar_index + 5, hi.price, border_color = CLEAR, bgcolor = color.new(bearClr, 90))
            z.innerBox     := box.new(hi.idx, hi.price + (zWidth * 0.35), bar_index + 5, hi.price, border_color = CLEAR, bgcolor = color.new(bearClr, 82))
            z.lvlLine      := line.new(hi.idx, hi.price, bar_index + 5, hi.price, color = color.new(bearClr, 45), width = 1)
            srZones.push(z)

        else
            z = SRZone.new()
            z.price        := lo.price
            z.startIdx     := lo.idx
            z.isResistance := false
            z.broken       := false
            z.outerBox     := box.new(lo.idx, lo.price, bar_index + 5, lo.price - zWidth, border_color = CLEAR, bgcolor = color.new(bullClr, 90))
            z.innerBox     := box.new(lo.idx, lo.price, bar_index + 5, lo.price - (zWidth * 0.35), border_color = CLEAR, bgcolor = color.new(bullClr, 82))
            z.lvlLine      := line.new(lo.idx, lo.price, bar_index + 5, lo.price, color = color.new(bullClr, 45), width = 1)
            srZones.push(z)

// ┌───────────────────────────── BOSWaves ─ S/R Level Management ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

if srZones.size() > 0
    for i = srZones.size() - 1 to 0

        z   = srZones.get(i)
        age = bar_index - z.startIdx
        clr = z.isResistance ? bearClr : bullClr

        if not z.broken
            if z.isResistance and close > z.price
                z.broken := true
                line.set_style(z.lvlLine, line.style_dotted)
                line.set_color(z.lvlLine, color.new(clr, 80))
                box.set_bgcolor(z.outerBox, color.new(clr, 96))
                box.set_bgcolor(z.innerBox, color.new(clr, 94))

            if not z.isResistance and close < z.price
                z.broken := true
                line.set_style(z.lvlLine, line.style_dotted)
                line.set_color(z.lvlLine, color.new(clr, 80))
                box.set_bgcolor(z.outerBox, color.new(clr, 96))
                box.set_bgcolor(z.innerBox, color.new(clr, 94))

        if age > maxAge or (z.broken and age > 30)
            box.delete(z.outerBox)
            box.delete(z.innerBox)
            line.delete(z.lvlLine)
            srZones.remove(i)
            continue

        if not z.broken
            fade    = math.min(float(age) / float(maxAge), 1.0)
            outerT  = int(90.0 + (10.0 * fade))
            innerT  = int(82.0 + (18.0 * fade))
            lineT   = int(45.0 + (55.0 * fade))

            box.set_right(z.outerBox, bar_index + 5)
            box.set_right(z.innerBox, bar_index + 5)
            line.set_x2(z.lvlLine, bar_index + 5)

            box.set_bgcolor(z.outerBox, color.new(clr, outerT))
            box.set_bgcolor(z.innerBox, color.new(clr, innerT))
            line.set_color(z.lvlLine, color.new(clr, lineT))

// ┌───────────────────────────── BOSWaves ─ Forecast Engine ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

if barstate.islast and pcts.size() >= 2

    // ── Cleanup ──
    beamOuter.delete()
    beamMid.delete()
    beamInner.delete()
    centerLine.delete()
    tgtOuter.delete()
    tgtInner.delete()
    tgtLabel.delete()
    for d in dots
        d.delete()
    dots.clear()
    for fl in fibLines
        fl.delete()
    fibLines.clear()
    for flb in fibLabels
        flb.delete()
    fibLabels.clear()

    fPct  = 0.0
    fBars = 0.0

    if method == "Weighted"
        tw = 0.0
        wp = 0.0
        wb = 0.0
        for i = 0 to pcts.size() - 1
            w   = i + 1.0
            wp += pcts.get(i) * w
            wb += durs.get(i) * w
            tw += w
        fPct  := wp / tw
        fBars := wb / tw
    else if method == "Median"
        fPct  := pcts.median()
        fBars := durs.median()
    else
        fPct  := pcts.avg()
        fBars := durs.avg()

    variance = 0.0
    for i = 0 to pcts.size() - 1
        diff      = pcts.get(i) - fPct
        variance += diff * diff
    stdDev = math.sqrt(variance / pcts.size())

    isBear    = not dir
    origin    = isBear ? hi.price : lo.price
    originIdx = isBear ? hi.idx   : lo.idx
    target    = isBear ? origin * (1.0 - fPct / 100.0) : origin * (1.0 + fPct / 100.0)
    targetIdx = bar_index + fwdBars
    bandHalf  = math.max(origin * stdDev / 100.0, atr * 0.1)

    // ── Layered glow beam ──
    if showBeam
        outerPts = buildBeamPts(originIdx, targetIdx, origin, target, bandHalf, 1.5, 12)
        midPts   = buildBeamPts(originIdx, targetIdx, origin, target, bandHalf, 1.0, 12)
        innerPts = buildBeamPts(originIdx, targetIdx, origin, target, bandHalf, 0.5, 12)

        beamOuter := polyline.new(outerPts, false, true, line_color = CLEAR,                    fill_color = color.new(projClr, 93))
        beamMid   := polyline.new(midPts,   false, true, line_color = color.new(projClr, 80),   fill_color = color.new(projClr, 87))
        beamInner := polyline.new(innerPts, false, true, line_color = CLEAR,                    fill_color = color.new(projClr, 78))

    // ── Center trajectory ──
    centerLine := line.new(originIdx, origin, targetIdx, target, color = color.new(projClr, 30), width = 1, style = line.style_dashed)

    // ── Path markers ──
    if showDots
        for s = 1 to 4
            t     = s / 5.0
            eased = t * t * (3.0 - 2.0 * t)
            x     = originIdx + int((targetIdx - originIdx) * t)
            y     = origin + (target - origin) * eased
            tr    = int(25.0 + (45.0 * (1.0 - t)))
            dots.push(label.new(x, y, "●", style = label.style_none, textcolor = color.new(projClr, tr), size = size.tiny))

    // ── Target zone ──
    if showTarget
        tgtTop = target + bandHalf * 0.6
        tgtBot = target - bandHalf * 0.6

        tgtOuter := box.new(targetIdx - 3, tgtTop + bandHalf * 0.3, targetIdx + 6, tgtBot - bandHalf * 0.3, border_color = CLEAR, bgcolor = color.new(projClr, 90))
        tgtInner := box.new(targetIdx - 2, tgtTop, targetIdx + 5, tgtBot, border_color = color.new(projClr, 40), border_width = 1, bgcolor = color.new(projClr, 80))

        sign     = isBear ? "▼ " : "▲ "
        tgtLabel := label.new(targetIdx + 6, target, sign + str.tostring(fPct, "#.##") + "%\n" + str.tostring(target, format.mintick), style = label.style_label_left, color = color.new(projClr, 15), textcolor = color.white, size = size.normal)

    // ── Fibonacci extensions ──
    if showFibs
        fullMove = target - origin

        fibActive = array.from(fib1Active, fib2Active, fib3Active, fib4Active, fib5Active)
        fibVals   = array.from(fib1Val,    fib2Val,    fib3Val,    fib4Val,    fib5Val)
        fibAlphas = array.from(30,         45,         30,         55,         65)

        for i = 0 to fibVals.size() - 1
            if not fibActive.get(i)
                continue

            ratio    = fibVals.get(i)
            fibPrice = origin + fullMove * ratio
            alpha    = fibAlphas.get(i)

            fibLines.push(
              line.new(bar_index, fibPrice, targetIdx + 20, fibPrice,
                       color = color.new(fibClr, alpha),
                       width = 1,
                       style = ratio == 1.0 ? line.style_solid : line.style_dashed))

            fibLabels.push(
              label.new(targetIdx + 22, fibPrice,
                        str.tostring(ratio, "#.###") + "  " + str.tostring(fibPrice, format.mintick),
                        style     = label.style_label_left,
                        color     = color.new(fibClr, 80),
                        textcolor = color.new(fibClr, 10),
                        size      = size.small))

// ┌───────────────────────────── BOSWaves ─ Alerts ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

alertcondition(dir != dir[1] and dir,     title = "Swing High Confirmed", message = "{{ticker}} New swing high confirmed")
alertcondition(dir != dir[1] and not dir, title = "Swing Low Confirmed",  message = "{{ticker}} New swing low confirmed")
````
