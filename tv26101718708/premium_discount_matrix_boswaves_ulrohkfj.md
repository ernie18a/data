# Premium Discount Matrix [BOSWaves]

- url: https://www.tradingview.com/script/ULrohkfj-Premium-Discount-Matrix-BOSWaves/
- type: indicator
- pine_id: PUB;c330c44334cb40e19c598a94d3bce131
- version: 1.0

## Description

[b]Premium Discount Matrix [BOSWaves] - Swing-Anchored Dealing Range with Internal Structure Scoring and Premium, Equilibrium, and Discount Zone Mapping[/b]

[b]Overview[/b]

Premium Discount Matrix [BOSWaves] is a swing-anchored dealing range system that divides the active range between the most recent confirmed swing high and swing low into a configurable grid of horizontal price rows, classifies each row as premium, equilibrium, or discount relative to the range midpoint, and scores every row by the density and rejection quality of the internal pivots that have formed within it.

[image]https://www.tradingview.com/x/BEuLqrFL/[/image]

Instead of simply splitting a range into two static halves, each row of the matrix is weighted by how much real structural activity has occurred at that price level. Internal pivots are detected continuously at a finer scale than the dealing range swings, each one assigned a quality score from its wick rejection and its ATR-normalized distance from the closing price at confirmation. Pivots that fall inside the active range are then mapped to the rows they occupy, and each row's opacity and core band intensity scale with the combined pivot density and average rejection quality at that level. Rows where price has repeatedly turned with strong rejection render brighter and more defined, while rows that price has passed through without reaction remain faint.

This creates a premium and discount framework that goes beyond location alone. The range edges define the dealing range boundaries, the equilibrium band marks the fair value midpoint, and the matrix intensity identifies exactly where within each zone the market has shown meaningful structural interest. The result is a single overlay that communicates both where price sits within the current range and which levels inside that range have historically carried reaction significance.

Price is therefore evaluated not just for whether it is trading at a premium or a discount, but for whether it is trading at a premium or discount level that the internal structure of the range has already validated.

[b]Conceptual Framework[/b]

Premium Discount Matrix is founded on the principle that premium and discount analysis should do more than label the upper and lower halves of a range. It should identify which specific price levels inside each half have demonstrated structural relevance through repeated pivot formation and measurable rejection behavior.

Traditional premium and discount tools draw a range, mark the 50% level, and treat every price above equilibrium as equally expensive and every price below as equally cheap. In practice, reactions cluster at specific levels within a range, and those levels are rarely distributed evenly. This framework closes that gap by dividing the range into discrete rows and scoring each row from the internal pivots that have formed inside it, so that location context and structural context are presented together rather than requiring separate analysis.

Three core principles guide the design:
[list=1]
[*]The dealing range should be anchored to confirmed swing structure rather than arbitrary lookback windows, ensuring the premium, equilibrium, and discount zones reflect the boundaries the market itself has established.
[*]Each level within the range should be weighted by measurable structural evidence, combining how often price has pivoted at that level with how decisively it rejected, so that visual emphasis reflects actual market behavior rather than equal treatment of all prices.
[*]Zone classification and structural intensity should be communicated through a single continuous visual layer, where color identifies the zone and opacity identifies the strength of structure within it, removing the need to cross-reference separate tools.
[/list]
This shifts premium and discount analysis from a binary location reading into a structure-weighted map of the dealing range where every level carries both a zone classification and an evidence-based intensity score.

[b]Theoretical Foundation[/b]

The indicator combines pivot-based swing detection for dealing range construction, midpoint equilibrium calculation with a configurable neutral band, internal pivot detection at a shorter confirmation length, wick-based and ATR-normalized rejection scoring for pivot quality, row-based price partitioning of the active range, and a weighted structure score that blends pivot density with average rejection quality to drive row intensity.

The dealing range high and low are taken from the most recently confirmed swing high and swing low, each requiring the configured number of bars on both sides for confirmation. Equilibrium is the arithmetic midpoint of the range, surrounded by a neutral band sized as a percentage of the total range. Internal pivots are detected at a shorter confirmation length and scored on two components: the wick score, which measures the rejection wick relative to the full candle range, and the rejection score, which measures how far price has moved away from the pivot by the time it confirms, normalized by ATR. These combine into a single 0-1 quality score, weighted 55% toward wick rejection and 45% toward follow-through distance.

Four internal systems operate in tandem:
[list]
[*][i]Dealing Range Engine[/i]: Detects swing highs and lows using the configured swing length, replaces the range high or range low with each newly confirmed swing on the corresponding side, calculates the range size and equilibrium midpoint, and determines the range start bar from the earlier of the two anchoring swings, clamped by the maximum range history.
[*][i]Internal Structure Engine[/i]: Detects internal pivot highs and lows at the shorter internal pivot length, scores each pivot from wick proportion and ATR-normalized rejection distance, and stores price, quality, and bar location in a rolling memory that discards the oldest pivots once the configured capacity is reached.
[*][i]Matrix Scoring System[/i]: Divides the active range into the configured number of rows, counts the stored internal pivots that fall within each row and formed on or after the range start, computes a density score saturating at four pivots and an average rejection score, and blends them using the configured density and rejection weights into a single structure score per row.
[*][i]Zone Rendering System[/i]: Classifies each row as premium, equilibrium, or discount from its midpoint relative to the equilibrium band, maps structure score to row transparency and to a concentrated core band through the center of each row, and renders the range high, range low, dashed equilibrium line, and zone labels projected forward from the current bar.
[/list]
This design ensures the dealing range boundaries, zone classification, and internal structure weighting all update together from a single consistent structural reference.

[b]How It Works[/b]

Premium Discount Matrix evaluates price through a sequence of range construction and structure scoring processes:
[list=1]
[*][i]Swing Detection[/i]: Swing highs and lows are confirmed when a bar's high or low is the extreme across the configured swing length on both sides, introducing a confirmation delay equal to the swing length.
[*][i]Range Construction[/i]: The most recent confirmed swing high becomes the range high and the most recent confirmed swing low becomes the range low. Each new swing replaces its side of the range whether or not it extends beyond the previous boundary. The range is only drawn when the high sits above the low, and it begins at the earlier of the two anchoring swing bars, limited by the maximum range history.
[*][i]Equilibrium Calculation[/i]: The midpoint of the range defines equilibrium, and a neutral band equal to the configured percentage of the range is centered on it.
[*][i]Internal Pivot Detection[/i]: Internal pivot highs and lows are confirmed across the chart using the shorter internal pivot length, capturing minor structure at a finer scale than the dealing range swings.
[*][i]Pivot Quality Scoring[/i]: Each internal pivot receives a wick score from the rejection wick as a proportion of the candle range, and a rejection score from the ATR-normalized distance between the pivot price and the close at confirmation. The two combine into a 0-1 quality score.
[*][i]Pivot Memory Management[/i]: Scored pivots are stored in a rolling memory. Once the configured memory capacity is exceeded, the oldest pivots are removed first.
[*][i]Row Partitioning[/i]: The range is divided into the configured number of equal-height rows from range low to range high.
[*][i]Row Structure Scoring[/i]: For each row, stored internal pivots that fall within its price bounds and formed on or after the range start are counted and their quality averaged. Density saturates at four pivots, and the final structure score blends density and average quality using the configured weights.
[*][i]Zone Classification[/i]: Rows with a midpoint inside the equilibrium band are classified as equilibrium, rows above it as premium, and rows below it as discount.
[*][i]Matrix Rendering[/i]: Each row is filled in its zone color with transparency that decreases as structure score increases. A concentrated core band through the center of each row brightens with structure score, and only renders once a row carries measurable structure.
[*][i]Range and Label Rendering[/i]: The range high, range low, and dashed equilibrium line extend from the range start to the configured right extension, with RANGE HIGH, RANGE LOW, PREMIUM, EQ, and DISCOUNT labels placed at the right edge.
[/list]
Together, these elements form a continuously updating dealing range map that combines zone location with evidence-weighted structural intensity at every level.

[b]Interpretation[/b]

Premium Discount Matrix should be interpreted as a structure-weighted location framework for the current dealing range:
[list]
[*][i]Premium Zone (Red/Pink)[/i]: Rows above the equilibrium band, representing the upper portion of the dealing range where price is relatively expensive. Brighter premium rows mark levels where internal pivots have repeatedly formed with strong rejection, highlighting areas of established supply within the range.
[*][i]Discount Zone (Green)[/i]: Rows below the equilibrium band, representing the lower portion of the dealing range where price is relatively cheap. Brighter discount rows mark levels where internal pivots have repeatedly formed with strong rejection, highlighting areas of established demand within the range.
[*][i]Equilibrium Band (White)[/i]: Rows whose midpoint falls inside the neutral band around the range midpoint, representing fair value within the current dealing range. Price trading inside the equilibrium band carries no location advantage in either direction. If the band is narrower than a single row, no rows are classified as equilibrium and the dashed midpoint line alone marks fair value.
[*][i]Row Intensity[/i]: The opacity of each row reflects its structure score. Faint rows indicate levels price has moved through with little or no pivot activity. Brighter, more opaque rows indicate levels with dense pivot formation and strong rejection behavior.
[*][i]Core Bands[/i]: The concentrated band through the center of each row sharpens as structure score increases, providing a precise visual reference for the most structurally significant levels within each zone.
[*][i]Range High and Range Low[/i]: Solid lines at the confirmed swing extremes that define the boundaries of the current dealing range. Any newly confirmed swing high or swing low replaces the corresponding boundary, redefining the range and rebuilding the matrix.
[*][i]Equilibrium Line[/i]: The dashed line at the exact range midpoint, marking the dividing level between premium and discount pricing.
[*][i]Internal Pivot Markers (◆)[/i]: When enabled, diamonds mark every detected internal pivot high and low, allowing direct inspection of the structure that feeds the matrix. Only pivots within the active range and pivot memory contribute to row scoring.
[/list]
Zone color, row intensity, and core band definition collectively communicate more location and structural context than a simple premium and discount split in isolation.

[b]Signal Logic & Visual Cues[/b]

Premium Discount Matrix is a contextual framework rather than a directional signal generator. It presents two primary structural events that redefine the dealing range:
[list=1]
[*][i]New Range High[/i]: A newly confirmed swing high replaces the previous range high, recalculating equilibrium, redistributing all rows, and rescoring the matrix against the updated range.
[*][i]New Range Low[/i]: A newly confirmed swing low replaces the previous range low, recalculating equilibrium, redistributing all rows, and rescoring the matrix against the updated range.
[/list]
Row intensity and core band brightness provide continuous secondary context throughout the life of each range, with high-scoring rows identifying the levels most likely to carry reaction significance as price revisits them.

Alert generation covers new range high and new range low confirmation events for systematic monitoring workflows.

[b]Strategy Integration[/b]

Premium Discount Matrix fits within dealing range, premium and discount, and structure-based reaction approaches:
[list=1]
[*][i]Location-Filtered Entries[/i]: Favor long setups when price trades in the discount zone and short setups when price trades in the premium zone, using the matrix as a location filter for signals generated by other tools.
[*][i]Structure-Weighted Levels[/i]: Prioritize the brightest rows within each zone as reaction levels. A discount row with high structure score offers stronger evidence of demand than a faint discount row at a similar distance from equilibrium.
[*][i]Equilibrium Awareness[/i]: Treat the equilibrium band as a neutral area where location offers no edge. Setups taken inside equilibrium lack the positional advantage the framework is designed to identify and warrant reduced conviction.
[*][i]Target Planning[/i]: Use high-scoring rows in the opposing zone as structural target references. A long taken from discount can reference bright premium rows as areas where internal supply has previously formed.
[*][i]Range Rotation Tracking[/i]: Monitor range high and range low alerts to identify when the dealing range redefines, reassessing zone classification and row intensity each time a new swing confirms.
[*][i]Multi-Timeframe Range Alignment[/i]: Apply a higher-timeframe dealing range as the primary location context, engaging with lower-timeframe discount or premium rows only when they align with the corresponding higher-timeframe zone.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Range Engine[/i]: Pivot-based swing high and low detection with configurable swing length; each boundary replaced by the latest confirmed swing on its side; range start derived from anchoring swing bars and clamped by maximum range history
[*][i]Structure Engine[/i]: Internal pivot detection at configurable length; wick-proportion and ATR-normalized rejection scoring combined into a 0-1 quality value; rolling pivot memory with oldest-first removal
[*][i]Scoring System[/i]: Row-based price partitioning; pivot density saturating at four pivots per row; average rejection quality per row; configurable density and rejection weighting into a single structure score capped at 1.0
[*][i]Zone Classification[/i]: Midpoint equilibrium with configurable neutral band width; row midpoint classification into premium, equilibrium, or discount
[*][i]Visualization[/i]: Structure-scaled row fills with clamped transparency; concentrated core bands at row centers; solid range boundary lines; dashed equilibrium line; zone labels projected at the right edge; optional internal pivot diamonds
[*][i]Object Management[/i]: Preallocated box, line, and label objects reused and repositioned rather than recreated, keeping object usage constant regardless of chart history. Only the current dealing range is displayed; previous ranges are not retained on the chart.
[*][i]Performance Profile[/i]: Swing and internal pivot detection with quality scoring on every bar; matrix scoring and rendering executed on the last bar and refreshed with each realtime update against the current pivot memory
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday dealing range mapping with shorter swing length and lower internal pivot length for responsive range updates and detailed minor structure capture
[*][i]15 - 60 min[/i]: Session-level range analysis with balanced swing length and moderate row count for meaningful separation between premium, equilibrium, and discount levels
[*][i]4H - Daily[/i]: Swing-level dealing range mapping with longer swing length and larger pivot memory for stable ranges and structure scoring built from extended pivot history
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Swing Length[/i]: 8
[*][i]Maximum Range History[/i]: 250
[*][i]ATR Length[/i]: 14
[*][i]Matrix Rows[/i]: 16
[*][i]Internal Pivot Length[/i]: 3
[*][i]Internal Pivot Memory[/i]: 80
[*][i]Pivot Density Weight[/i]: 0.60
[*][i]Rejection Weight[/i]: 0.40
[*][i]Equilibrium Width[/i]: 0.10
[*][i]Right Extension[/i]: 20
[*][i]Show Range High / Low[/i]: Enabled
[*][i]Show Labels[/i]: Enabled
[*][i]Show Internal Pivots[/i]: Disabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, swing structure frequency, and preferred range sensitivity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Range redefining too often[/i]: Increase Swing Length to require more bars of confirmation on each side, producing larger, more stable dealing ranges that update less frequently.
[*][i]Range too slow to update[/i]: Decrease Swing Length for faster swing confirmation, allowing the dealing range to track more recent structure at the cost of greater range turnover.
[*][i]Matrix too coarse[/i]: Increase Matrix Rows toward 24 for finer price resolution, isolating structurally significant levels more precisely within each zone.
[*][i]Matrix too fragmented[/i]: Decrease Matrix Rows toward 8 so that pivots group into broader rows, producing clearer high-intensity zones on instruments with scattered structure.
[*][i]Too few rows highlighted[/i]: Decrease Internal Pivot Length to detect more minor pivots inside the range, or increase Internal Pivot Memory so more historical pivots contribute to row scoring.
[*][i]Too many rows highlighted[/i]: Increase Internal Pivot Length to restrict scoring to more meaningful internal pivots, filtering out minor noise that lifts row intensity across the entire range.
[*][i]Intensity driven by clustering rather than quality[/i]: Decrease Pivot Density Weight and increase Rejection Weight so that rows are emphasized by decisive rejections rather than by frequent but weak pivots.
[*][i]Matrix appears faint overall[/i]: The maximum structure score is capped by the sum of the two weights. If Pivot Density Weight and Rejection Weight combined fall below 1.0, even the strongest rows cannot reach full intensity. Keep the combined weights near 1.0 for full visual range.
[*][i]Equilibrium band too wide or narrow[/i]: Adjust Equilibrium Width to control how much of the range is treated as neutral. Wider settings reserve premium and discount classification for the outer portions of the range only. If no white rows appear, the band is narrower than a single row; increase Equilibrium Width or Matrix Rows until at least one row midpoint falls inside it.
[*][i]Matrix not extending far enough left[/i]: Increase Maximum Range History so that ranges anchored by older swings are drawn in full and include pivots from further back.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Ranging and rotational markets where price oscillates between well-defined swing boundaries, allowing internal pivots to accumulate and producing clearly differentiated high-intensity rows within each zone
[*]Instruments with consistent swing structure where confirmed swings form meaningful dealing range boundaries rather than minor fluctuations
[*]Location-based trading approaches that benefit from filtering entries by premium and discount context rather than acting on signals regardless of range position
[*]Level-based execution workflows where identifying which specific prices within a zone have carried repeated reactions improves entry and target precision
[/list]
Reduced Effectiveness:
[list]
[*]Strong impulsive trends where price moves persistently in one direction, causing the dealing range to redefine frequently and limiting the time available for internal pivots to accumulate within each range
[*]Extended trends where a newly confirmed swing low forms above the prior swing high or a new swing high forms below the prior swing low, temporarily producing no valid range until structure realigns
[*]Newly formed ranges with little internal history, where row intensity remains uniformly faint until sufficient internal pivots have formed inside the new boundaries
[*]Very low volatility environments where the range is narrow relative to typical candle size, compressing multiple rows into a small price area and reducing the precision of row-level scoring
[*]News-driven or gap-heavy instruments where abrupt price moves produce swing extremes that are not representative of the structure price is likely to revisit
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves trend, momentum, or order flow tools to generate directional signals, using the matrix to confirm whether those signals occur at favorable premium or discount locations with supporting internal structure
[*][i]Intensity Assessment[/i]: Evaluate row intensity at the price level of each setup before committing. Setups at bright rows within the correct zone carry both location and structural support, while setups at faint rows rely on location alone.
[*][i]Range Awareness[/i]: Note how recently the dealing range was redefined. A freshly updated range has limited internal history, and its row intensity should be treated as developing rather than established.
[*][i]Pivot Verification[/i]: Periodically enable internal pivot markers to confirm that the pivots feeding row intensity reflect meaningful structure on the current instrument and timeframe, adjusting internal pivot length if the scored structure appears too sparse or too noisy.
[*][i]Zone Discipline[/i]: Maintain location bias aligned with the current zone until price transitions through equilibrium. Price moving from discount into the equilibrium band reduces location advantage but does not constitute premium pricing until it clears the upper edge of the band.
[/list]
[b]Disclaimer[/b]

Premium Discount Matrix [BOSWaves] is a professional-grade dealing range visualization and internal structure scoring tool. It uses swing-anchored range construction with pivot density and rejection-based level weighting but does not predict future price movements. Results depend on market conditions, instrument swing characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Premium Discount Matrix [BOSWaves]", overlay=true, max_boxes_count=100, max_lines_count=20, max_labels_count=20)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Dealing Range"
const string g2 = "Structure Matrix"
const string g3 = "Display"

int swingLen          = input.int(8, "Swing Length", minval = 2, maxval = 30, group = g1,
     tooltip = "Number of bars on each side required to confirm a swing high or low. Higher values define a larger, slower-updating dealing range.")
int maxRangeBars      = input.int(250, "Maximum Range History", minval = 50, maxval = 1000, group = g1,
     tooltip = "Maximum number of bars back the dealing range and matrix can extend. Limits how far left the zones are drawn.")
int atrLen            = input.int(14, "ATR Length", minval = 5, group = g1,
     tooltip = "Number of bars used to calculate the Average True Range, used to normalize pivot rejection strength.")

int rows              = input.int(16, "Matrix Rows", minval = 8, maxval = 24, group = g2,
     tooltip = "Number of horizontal rows the dealing range is divided into. Higher values produce a finer, more detailed matrix.")
int internalPivotLen  = input.int(3, "Internal Pivot Length", minval = 1, maxval = 10, group = g2,
     tooltip = "Number of bars on each side required to confirm an internal pivot. Lower values detect more minor structure inside the range.")
int pivotMemory       = input.int(80, "Internal Pivot Memory", minval = 20, maxval = 200, group = g2,
     tooltip = "Maximum number of recent internal pivots stored and used to score each matrix row. Older pivots are discarded first.")
float densityWeight   = input.float(0.60, "Pivot Density Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = g2,
     tooltip = "Influence of pivot count on each row's structure score. Higher values emphasize rows where price has pivoted repeatedly.")
float rejectionWeight = input.float(0.40, "Rejection Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = g2,
     tooltip = "Influence of pivot rejection quality on each row's structure score. Higher values emphasize rows with strong wick rejections and follow-through.")
float eqWidth         = input.float(0.10, "Equilibrium Width", minval = 0.02, maxval = 0.30, step = 0.01, group = g2,
     tooltip = "Width of the equilibrium band around the range midpoint, as a percentage of the total range size.")

int extendBars        = input.int(20, "Right Extension", minval = 5, maxval = 100, group = g3,
     tooltip = "Number of bars the matrix, range lines, and labels are projected forward from the current bar.")
bool showRangeEdges   = input.bool(true, "Show Range High / Low", group = g3,
     tooltip = "Toggles visibility of the dealing range high and low lines.")
bool showLabels       = input.bool(true, "Show Labels", group = g3,
     tooltip = "Toggles visibility of the range high, range low, premium, equilibrium, and discount labels.")
bool showInternalPivots = input.bool(false, "Show Internal Pivots", group = g3,
     tooltip = "Toggles markers on the internal pivots used to score the matrix rows.")

color premiumCol      = input.color(#FF0066, "Premium", inline = "c1", group = g3,
     tooltip = "Color used for the premium zone and range high elements.")
color discountCol     = input.color(#00FF00, "Discount", inline = "c1", group = g3,
     tooltip = "Color used for the discount zone and range low elements.")
color eqCol           = input.color(#FFFFFF, "Equilibrium", inline = "c1", group = g3,
     tooltip = "Color used for the equilibrium band and midpoint line.")
color textCol         = input.color(#FFFFFF, "Text", group = g3,
     tooltip = "Color used for label text.")

// ┌────────────────────────────── BOSWaves ─ Swing Range ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float atr = ta.atr(atrLen)
float swingHigh = ta.pivothigh(high, swingLen, swingLen)
float swingLow = ta.pivotlow(low, swingLen, swingLen)

var float rangeHigh = na
var float rangeLow = na
var int rangeHighBar = na
var int rangeLowBar = na

if not na(swingHigh)
    rangeHigh := swingHigh
    rangeHighBar := bar_index - swingLen

if not na(swingLow)
    rangeLow := swingLow
    rangeLowBar := bar_index - swingLen

bool rangeReady = not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow
float rangeSize = rangeReady ? rangeHigh - rangeLow : na
float equilibrium = rangeReady ? (rangeHigh + rangeLow) * 0.5 : na

int rangeStart = rangeReady ? math.max(math.min(rangeHighBar, rangeLowBar), bar_index - maxRangeBars) : bar_index

// ┌────────────────────────────── BOSWaves ─ Internal Structure ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float iph = ta.pivothigh(high, internalPivotLen, internalPivotLen)
float ipl = ta.pivotlow(low, internalPivotLen, internalPivotLen)

var float[] pivotPrice = array.new_float()
var float[] pivotStrength = array.new_float()
var int[] pivotBar = array.new_int()
var int[] pivotType = array.new_int()

if not na(iph)
    int pBar = bar_index - internalPivotLen
    float candleRange = math.max(high[internalPivotLen] - low[internalPivotLen], syminfo.mintick)
    float upperWick = high[internalPivotLen] - math.max(open[internalPivotLen], close[internalPivotLen])
    float wickScore = math.min(1.0, upperWick / candleRange * 2.0)
    float rejectDist = atr > 0 ? math.abs(iph - close) / atr : 0.0
    float rejectScore = math.min(1.0, rejectDist / 2.0)
    float quality = math.min(1.0, wickScore * 0.55 + rejectScore * 0.45)

    array.push(pivotPrice, iph)
    array.push(pivotStrength, quality)
    array.push(pivotBar, pBar)
    array.push(pivotType, -1)

if not na(ipl)
    int pBar = bar_index - internalPivotLen
    float candleRange = math.max(high[internalPivotLen] - low[internalPivotLen], syminfo.mintick)
    float lowerWick = math.min(open[internalPivotLen], close[internalPivotLen]) - low[internalPivotLen]
    float wickScore = math.min(1.0, lowerWick / candleRange * 2.0)
    float rejectDist = atr > 0 ? math.abs(close - ipl) / atr : 0.0
    float rejectScore = math.min(1.0, rejectDist / 2.0)
    float quality = math.min(1.0, wickScore * 0.55 + rejectScore * 0.45)

    array.push(pivotPrice, ipl)
    array.push(pivotStrength, quality)
    array.push(pivotBar, pBar)
    array.push(pivotType, 1)

while array.size(pivotPrice) > pivotMemory
    array.shift(pivotPrice)
    array.shift(pivotStrength)
    array.shift(pivotBar)
    array.shift(pivotType)

// ┌────────────────────────────── BOSWaves ─ Matrix Storage ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var box[] matrixBoxes = array.new_box()
var box[] coreBoxes = array.new_box()

if barstate.isfirst
    for i = 0 to 23
        array.push(matrixBoxes, box.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, bgcolor=na, border_color=na))
        array.push(coreBoxes, box.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, bgcolor=na, border_color=na))

// ┌────────────────────────────── BOSWaves ─ Range Objects ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var line highLine = na
var line lowLine = na
var line eqLine = na

var label highTag = na
var label lowTag = na
var label premiumTag = na
var label eqTag = na
var label discountTag = na

if barstate.isfirst
    highLine := line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index)
    lowLine := line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index)
    eqLine := line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index)

    highTag := label.new(bar_index, close, "", style=label.style_label_left)
    lowTag := label.new(bar_index, close, "", style=label.style_label_left)
    premiumTag := label.new(bar_index, close, "", style=label.style_label_left)
    eqTag := label.new(bar_index, close, "", style=label.style_label_left)
    discountTag := label.new(bar_index, close, "", style=label.style_label_left)

// ┌────────────────────────────── BOSWaves ─ Matrix ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if barstate.islast
    for i = 0 to 23
        box.set_bgcolor(array.get(matrixBoxes, i), na)
        box.set_border_color(array.get(matrixBoxes, i), na)
        box.set_bgcolor(array.get(coreBoxes, i), na)
        box.set_border_color(array.get(coreBoxes, i), na)

    if rangeReady
        float rowSize = rangeSize / rows
        float eqHalf = rangeSize * eqWidth * 0.5

        for r = 0 to rows - 1
            float bottom = rangeLow + rowSize * r
            float top = bottom + rowSize
            float mid = (top + bottom) * 0.5

            int pivotCount = 0
            float totalReaction = 0.0

            if array.size(pivotPrice) > 0
                for p = 0 to array.size(pivotPrice) - 1
                    float pp = array.get(pivotPrice, p)
                    int pb = array.get(pivotBar, p)

                    if pb >= rangeStart and pp >= bottom and pp <= top
                        pivotCount += 1
                        totalReaction += array.get(pivotStrength, p)

            float densityScore = math.min(1.0, pivotCount / 4.0)
            float reactionScore = pivotCount > 0 ? math.min(1.0, totalReaction / pivotCount) : 0.0
            float structureScore = math.min(1.0, densityScore * densityWeight + reactionScore * rejectionWeight)

            bool isEq = mid >= equilibrium - eqHalf and mid <= equilibrium + eqHalf
            bool isPremium = mid > equilibrium + eqHalf
            bool isDiscount = mid < equilibrium - eqHalf

            color rowCol = isEq ? eqCol : isPremium ? premiumCol : discountCol

            int baseTransparency = isEq ? 94 : 95
            int transparency = int(math.round(baseTransparency - structureScore * 50.0))
            transparency := math.max(30, math.min(98, transparency))

            int coreTransparency = int(math.round(97.0 - structureScore * 72.0))
            coreTransparency := math.max(16, math.min(100, coreTransparency))

            box rowBox = array.get(matrixBoxes, r)
            box coreBox = array.get(coreBoxes, r)

            box.set_left(rowBox, rangeStart)
            box.set_right(rowBox, bar_index + extendBars)
            box.set_top(rowBox, top)
            box.set_bottom(rowBox, bottom)
            box.set_bgcolor(rowBox, color.new(rowCol, transparency))
            box.set_border_color(rowBox, color.new(rowCol, 100))

            float coreHeight = rowSize * 0.24

            box.set_left(coreBox, rangeStart)
            box.set_right(coreBox, bar_index + extendBars)
            box.set_top(coreBox, mid + coreHeight * 0.5)
            box.set_bottom(coreBox, mid - coreHeight * 0.5)
            box.set_bgcolor(coreBox, structureScore > 0.05 ? color.new(rowCol, coreTransparency) : na)
            box.set_border_color(coreBox, na)

        int right = bar_index + extendBars

        line.set_xy1(highLine, rangeStart, rangeHigh)
        line.set_xy2(highLine, right, rangeHigh)
        line.set_color(highLine, showRangeEdges ? color.new(premiumCol, 12) : na)
        line.set_width(highLine, 2)

        line.set_xy1(lowLine, rangeStart, rangeLow)
        line.set_xy2(lowLine, right, rangeLow)
        line.set_color(lowLine, showRangeEdges ? color.new(discountCol, 12) : na)
        line.set_width(lowLine, 2)

        line.set_xy1(eqLine, rangeStart, equilibrium)
        line.set_xy2(eqLine, right, equilibrium)
        line.set_color(eqLine, color.new(eqCol, 58))
        line.set_style(eqLine, line.style_dashed)

        label.set_xy(highTag, right + 1, rangeHigh)
        label.set_text(highTag, showLabels ? "RANGE HIGH" : "")
        label.set_color(highTag, showLabels ? color.new(premiumCol, 25) : na)
        label.set_textcolor(highTag, textCol)

        label.set_xy(lowTag, right + 1, rangeLow)
        label.set_text(lowTag, showLabels ? "RANGE LOW" : "")
        label.set_color(lowTag, showLabels ? color.new(discountCol, 25) : na)
        label.set_textcolor(lowTag, textCol)

        float premiumY = equilibrium + rangeSize * 0.25
        float discountY = equilibrium - rangeSize * 0.25

        label.set_xy(premiumTag, right + 1, premiumY)
        label.set_text(premiumTag, showLabels ? "PREMIUM" : "")
        label.set_color(premiumTag, showLabels ? color.new(premiumCol, 58) : na)
        label.set_textcolor(premiumTag, textCol)

        label.set_xy(eqTag, right + 1, equilibrium)
        label.set_text(eqTag, showLabels ? "EQ" : "")
        label.set_color(eqTag, showLabels ? color.new(eqCol, 72) : na)
        label.set_textcolor(eqTag, textCol)

        label.set_xy(discountTag, right + 1, discountY)
        label.set_text(discountTag, showLabels ? "DISCOUNT" : "")
        label.set_color(discountTag, showLabels ? color.new(discountCol, 58) : na)
        label.set_textcolor(discountTag, textCol)

// ┌────────────────────────────── BOSWaves ─ Internal Pivots ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
plotshape(showInternalPivots and not na(iph), title="Internal High", offset=-internalPivotLen, location=location.abovebar, style=shape.diamond, size=size.tiny, color=premiumCol)
plotshape(showInternalPivots and not na(ipl), title="Internal Low", offset=-internalPivotLen, location=location.belowbar, style=shape.diamond, size=size.tiny, color=discountCol)

alertcondition(not na(swingHigh), "New Range High", "New dealing range swing high confirmed")
alertcondition(not na(swingLow), "New Range Low", "New dealing range swing low confirmed")
````
