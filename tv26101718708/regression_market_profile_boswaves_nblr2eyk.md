# Regression Market Profile [BOSWaves]

- url: https://www.tradingview.com/script/NbLR2eyK-Regression-Market-Profile-BOSWaves/
- type: indicator
- pine_id: PUB;8d648612ee4544e9b1620f5be828d7c8
- version: 1.0

## Description

[b]Regression Market Profile [BOSWaves] - Curve-Following Distribution Analysis with TPO Letters, Heatmap, and Profile Modes[/b]

[b]Overview[/b]

Regression Market Profile [BOSWaves] is a regression-anchored market profile system that maps the distribution of price activity relative to a best-fit regression curve rather than within fixed horizontal price boundaries, where row assignment, POC identification, value area construction, and interior visualization are all derived from how far actual price deviated from the regression prediction on each bar rather than from absolute price levels.

[image]https://www.tradingview.com/x/iAzNNpdk/[/image]

Instead of constructing a profile against a static price range, this system fits either a linear or polynomial regression to recent price history and measures each bar's deviation from the fitted curve, distributing that activity into horizontal rows centered on the regression line. As the curve bends and trends through price space, the entire profile follows it, revealing where price consistently clustered above or below the regression prediction and identifying the deviation offset with the highest time-at-price concentration as a dynamic POC that moves with the trend rather than anchoring to a fixed session boundary.

This creates a market profile framework that adapts to the prevailing directional structure of price rather than imposing a fixed container. The interior visualization communicates distribution in three configurable modes: a heatmap that reveals how the distribution migrated across time columns, a profile extending from the right edge showing the cumulative distribution shape, and TPO letter boxes that follow the regression curve encoding chronological time progression through gradient coloring. Standard deviation bounds, value area boundaries, and a dual-line POC glow all follow the curve simultaneously, providing a complete structural reference system that moves with the trend rather than remaining static.

Price is therefore evaluated not for its absolute level but for its position relative to the regression expectation, with the profile revealing which deviation offsets attracted the most sustained activity throughout the regression window.

[b]Conceptual Framework[/b]

Regression Market Profile is founded on the principle that meaningful participation clustering should be measured relative to the expected price path defined by recent price history rather than within arbitrary time or price containers that carry no relationship to the actual directional structure of the market.

Traditional market profile approaches anchor distributions to calendar sessions or fixed price ranges, producing profiles that reflect where price traded within a time box rather than where it clustered relative to its own trend. This framework replaces fixed-container profiling with regression-relative distribution measurement, where each bar's contribution to the profile is determined by how far actual price deviated from the best-fit curve rather than where it sat in absolute price space. The profile therefore reveals the structural tendencies of price relative to its own trend dynamics rather than its behavior within an externally imposed boundary.

Three core principles guide the design:
[list=1]
[*]Profile distribution should be measured as deviation from a fitted regression curve rather than as absolute price position, ensuring the profile captures participation clustering relative to trend expectation rather than within arbitrary price boundaries.
[*]The interior visualization mode should be configurable between temporal migration analysis, cumulative distribution shape, and chronological letter encoding, allowing the same structural data to be interpreted through different analytical lenses depending on the trader's workflow.
[*]All structural reference elements including POC, value area, standard deviation bounds, and centerline should follow the regression curve continuously rather than anchoring to static horizontal levels, maintaining relevance to the current trend structure throughout the regression window.
[/list]
This shifts market profile analysis from session-bounded horizontal distribution tracking into regression-relative participation mapping where the profile reveals structural clustering tendencies within the context of the prevailing trend curvature.

[b]Theoretical Foundation[/b]

The indicator combines matrix-based polynomial and linear regression fitting to recent HL2 price data, rolling standard deviation for channel scaling and SD bound construction, deviation-based row assignment for distribution building, POC identification through maximum row count, value area expansion from POC outward, and three distinct interior visualization systems that present the same distribution data through different geometric representations following the regression curve.

The regression is computed using ordinary least squares matrix operations: the design matrix is constructed with powers of bar index up to the polynomial degree, transposed and multiplied to form the normal equations, inverted, and multiplied by the price vector to produce regression coefficients, which are then applied to generate the full prediction array. Standard deviation of the HL2 series over the regression window provides the channel scaling unit and drives the SD bound envelopes. Row assignment divides the channel height by the number of rows and places each bar's deviation from its predicted value into the corresponding row bin. POC and value area use the same maximum-count and outward-expansion logic as conventional market profile, applied to the curved row counts.

Four internal systems operate in tandem:
[list]
[*][i]Regression Engine[/i]: Computes linear or polynomial best-fit predictions for all bars in the lookback window using matrix least squares, providing the curved baseline that all distribution measurements, row positioning, and visual elements follow.
[*][i]Distribution Construction System[/i]: Measures each bar's deviation from its regression prediction, assigns it to a horizontal row within the standard deviation channel, accumulates row counts across the full window, and derives POC and value area from the resulting distribution.
[*][i]Interior Visualization Engine[/i]: Renders the distribution data inside the channel in one of three modes: curved polygon cells per time column normalized independently for heatmap temporal migration display, curved profile bars extending from the right edge scaled to global row counts for distribution shape display, or TPO letter boxes positioned at the regression-relative row boundaries with gradient chronological coloring for time period encoding.
[*][i]Structural Reference System[/i]: Draws the dual-line POC glow following the regression curve at the POC row offset, value area boundary polylines at the VA top and bottom offsets, standard deviation envelope polylines at one through three sigma above and below the curve, and a dashed centerline following the regression prediction directly.
[/list]
This design ensures the distribution and all structural reference elements continuously adapt to the regression curve while the three interior modes provide complementary analytical perspectives on the same underlying participation data.

[b]How It Works[/b]

Regression Market Profile evaluates price through a sequence of regression-aware distribution and visualization processes:
[list=1]
[*][i]Regression Calculation[/i]: On the last bar, the design matrix is constructed from bar index values raised to polynomial powers up to the configured degree. Ordinary least squares solves for the coefficient vector and applies it to produce a prediction array covering all bars in the lookback window.
[*][i]Channel Scaling[/i]: The standard deviation of HL2 over the regression window multiplied by the configured channel width defines the maximum deviation distance, establishing the vertical extent of the distribution channel centered on the regression curve.
[*][i]Row Assignment and Count Accumulation[/i]: Each bar's actual HL2 is compared to its regression prediction and the deviation is assigned to a horizontal row bin derived from the channel height divided by the row count. Row counts accumulate across all bars in the window.
[*][i]POC Identification[/i]: The row with the maximum accumulated count is identified as the Point of Control, representing the deviation offset from the regression curve where price spent the most time during the lookback window.
[*][i]Value Area Construction[/i]: Starting from the POC row, adjacent rows are added in order of greater count until the cumulative total reaches the configured value area percentage of all bar counts, defining the high-activity zone around the POC.
[*][i]Interior Rendering - Heatmap Mode[/i]: The lookback window is divided into time columns and each column builds its own per-row counts, normalized independently so each column's internal distribution is shown on its own scale. Curved polygon cells are rendered for each occupied cell with hot-cold gradient coloring by normalized density.
[*][i]Interior Rendering - Profile Mode[/i]: Each row's global count is expressed as a fraction of the maximum row count and scaled to a configurable proportion of the total regression length. Curved polygon bars extend leftward from the right edge by the scaled bar length, forming a profile shape that follows the regression curve.
[*][i]Interior Rendering - Letters Mode[/i]: Each bar is assigned a sequential alphabetical letter based on its time period index relative to the TPO timeframe. Letters are accumulated per row and rendered as individual boxes positioned at the regression-relative row boundaries, with gradient coloring that progresses from cold to hot as the letter index advances chronologically.
[*][i]POC Polyline Rendering[/i]: A wide low-opacity glow polyline and a thinner full-opacity core polyline follow the regression curve at the POC deviation offset, providing a continuously curving reference for the maximum activity level throughout the window.
[*][i]Value Area and SD Bound Rendering[/i]: Dotted polylines follow the regression curve at the value area high and low offsets and at one, two, and three standard deviation distances above and below the curve, with opacity increasing with distance from the curve.
[/list]
Together, these elements form a continuously recomputed regression-relative distribution system where every visual element adapts to the current curve shape and all three interior modes present the same participation data from different analytical perspectives.

[b]Interpretation[/b]

Regression Market Profile should be interpreted as a regression-relative structural distribution system where clustering above or below the fitted curve reveals directional bias tendencies and participation concentration within the prevailing trend:
[list]
[*][i]Regression Centerline[/i]: The dashed curve following the best-fit prediction represents the trend's expected price path. Price consistently above it indicates sustained positive deviation bias; price consistently below indicates sustained negative deviation bias.
[*][i]POC Line[/i]: The dual glow and core polyline following the curve at the maximum activity offset marks the deviation level where price spent the most time relative to the regression prediction, representing the most accepted deviation from expected trend behavior during the window.
[*][i]Value Area Boundaries[/i]: Dotted polylines above and below the POC line mark the deviation range containing the configured percentage of total activity, identifying the zone of concentrated acceptance around the POC.
[*][i]Standard Deviation Bounds[/i]: One, two, and three sigma dotted envelopes around the curve mark statistically extreme deviation distances, with progressively greater opacity indicating greater statistical rarity of price reaching those offsets.
[*][i]Heatmap Mode[/i]: Each time column displays its own normalized distribution, with hot colors indicating the most active deviation level within that column and cold colors indicating less active levels. Reading across columns from left to right reveals how the distribution migrated as the window progressed.
[*][i]Profile Mode[/i]: Curved bars extending from the right edge show the cumulative distribution shape across the full window, with longer bars indicating deviation levels with greater total activity and hot coloring marking the densest regions.
[*][i]Letters Mode[/i]: Sequential alphabet letters fill the channel rows at their regression-relative positions, with gradient coloring from cold early-window letters to hot late-window letters encoding chronological time progression. Single-letter rows indicate price visited that deviation level in only one time period, functioning as regression-relative single prints.
[*][i]POC Offset Interpretation[/i]: A POC positioned above the regression centerline indicates that price has consistently traded at a positive deviation from expectations, reflecting bullish structural bias within the window. A POC below the centerline indicates bearish structural bias.
[/list]
POC offset direction, value area extent, distribution shape across modes, and SD bound interactions collectively provide more structural context than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Regression Market Profile does not generate discrete buy or sell signals but provides continuous structural reference through distribution-derived levels:
[list=1]
[*][i]POC Reaction[/i]: Price returning to the deviation level corresponding to the POC polyline encounters the most accepted level within the regression window, frequently acting as magnetic reference for reversion or continuation assessment.
[*][i]Value Area Boundary Interaction[/i]: Price moving outside the value area boundaries enters statistically less accepted deviation territory, suggesting either trend extension beyond typical participation or the beginning of structural repositioning relative to the regression curve.
[/list]
Standard deviation bound interactions provide additional reference for statistically extreme deviation events that historically attract mean reversion activity back toward the regression curve and POC.

[b]Strategy Integration[/b]

Regression Market Profile fits within regression-informed structural analysis and distribution-based approaches:
[list]
[*][i]POC Reversion Framing[/i]: Use the POC polyline as a dynamic reversion target when price has extended to the outer standard deviation bounds, with the curved POC providing a continuously updating level that reflects the trend's accepted center rather than a static price.
[*][i]Value Area Acceptance Testing[/i]: Monitor whether price is trading within or outside the value area boundaries to assess whether current price activity represents accepted trend behavior or extended deviation warranting mean reversion consideration.
[*][i]Heatmap Migration Analysis[/i]: Use temporal migration visible in heatmap mode to assess whether distribution is shifting toward positive or negative deviation over the course of the window, providing directional bias evidence from the distribution's evolution rather than from price alone.
[*][i]Profile Shape Assessment[/i]: Use profile mode to assess distribution symmetry around the regression curve. A distribution skewed above the centerline suggests persistent positive bias; skew below suggests persistent negative bias. A symmetric bell shape suggests balanced acceptance around the regression expectation.
[*][i]Single Print Monitoring in Letters Mode[/i]: Treat single-letter rows in letters mode as regression-relative thin participation levels that price is likely to revisit, analogous to single prints in conventional market profile.
[*][i]Regression Mode Selection[/i]: Use Linear mode for markets trending in a consistent direction where a straight best-fit line accurately represents the price path. Use Polynomial mode for markets with visible curvature in their trend structure where the quadratic bend better fits the actual price trajectory.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Regression Engine[/i]: Matrix OLS computation using design matrix construction, normal equation formation, matrix inversion, and coefficient application for linear or polynomial curve fitting to HL2
[*][i]Channel Construction[/i]: Rolling standard deviation-scaled channel with configurable width multiplier providing deviation row boundaries
[*][i]Distribution System[/i]: Deviation-based row assignment with global count accumulation, POC maximum identification, and outward value area expansion
[*][i]Heatmap Engine[/i]: Per-column count normalization with curved polygon cell rendering using hot-cold gradient by normalized density
[*][i]Profile Engine[/i]: Global count-scaled curved bar polylines extending from the right edge by proportional bar length
[*][i]Letters Engine[/i]: TPO timeframe-ratio letter assignment with per-row accumulation and gradient chronological box rendering at regression-relative boundaries
[*][i]Structural System[/i]: Dual-line POC glow, dotted VA boundary polylines, three-sigma dotted SD envelopes, and dashed centerline all following the regression curve via chart.point arrays
[*][i]Performance Profile[/i]: All rendering triggered only on the last bar with full object cleanup and rebuild on each update, polyline-based curved geometry for all structural elements
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday regression profiling with shorter length and tighter channel for fast-adapting curve that captures intraday trend structure
[*][i]15 - 60 min[/i]: Session-level distribution analysis with balanced length and moderate channel width for meaningful participation mapping across typical session trends
[*][i]4H - Daily[/i]: Swing-level regression profiling with longer lookback and polynomial mode for curve-following distribution across multi-session directional structures
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Length[/i]: 200
[*][i]Mode[/i]: Polynomial
[*][i]Channel Width (SD×)[/i]: 3.0
[*][i]Inner Display[/i]: Letters
[*][i]Rows[/i]: 12
[*][i]TPO Timeframe[/i]: 30
[*][i]Value Area %[/i]: 70
[*][i]Show POC[/i]: Enabled
[*][i]Show Value Area[/i]: Enabled
[*][i]Show SD Bounds[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's trend characteristics, volatility profile, and preferred distribution granularity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Curve fits too loosely to recent price[/i]: Decrease Length to shorten the regression window, producing a curve that adapts more quickly to recent price structure. Switch to Polynomial mode if the trend has visible curvature that a linear fit cannot capture.
[*][i]Curve too reactive to short-term price movement[/i]: Increase Length to smooth the regression across more history, producing a more stable curve that reflects longer-term directional structure and reduces sensitivity to recent fluctuations.
[*][i]Channel too narrow or wide[/i]: Adjust Channel Width to scale the standard deviation multiplier, expanding the channel to capture more price activity within the distribution or contracting it to focus on the core deviation range.
[*][i]Distribution too coarse or granular[/i]: Adjust Rows to increase or decrease the number of horizontal price bins, calibrating vertical resolution to the channel height and the instrument's typical deviation behavior within the regression window.
[*][i]Heatmap columns too few or many[/i]: Adjust Heatmap Columns to control the time resolution of the migration display, with fewer columns showing broader temporal patterns and more columns revealing finer migration detail at the cost of visual density.
[*][i]Profile bars too short or long[/i]: Adjust Profile Width to scale the maximum bar length as a fraction of the regression window, calibrating how far the longest bars extend from the right edge relative to the available chart space.
[*][i]Too few or many letters per row[/i]: Adjust TPO Timeframe to change the time period each letter represents. Higher timeframes produce fewer, broader letters; lower timeframes produce more letters with finer time resolution.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets where the regression curve accurately represents the directional price path and the distribution reveals consistent deviation bias that reflects genuine structural tendencies
[*]Instruments with smooth, curving price trends where polynomial mode produces a better-fitting curve than a straight line and the distribution around the curve is more meaningful than a session-anchored profile
[*]Market profile-informed approaches that benefit from a continuously adapting POC and value area that follow the trend rather than anchoring to fixed session boundaries
[*]Distribution analysis workflows where heatmap temporal migration or profile shape provides directional bias evidence from participation patterns rather than from price indicators alone
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, directionless markets where the regression curve has no clear shape and the distribution is uniform across rows, reducing the interpretive value of POC location and value area extent
[*]Markets with frequent sharp reversals where the regression window spans multiple opposing structural moves, producing a curve that represents none of them accurately and a distribution without meaningful clustering
[*]Extremely short lookback windows where the matrix regression calculation is underdetermined or the distribution contains too few bars per row to produce statistically meaningful counts
[*]Instruments with discontinuous price action including frequent gaps where the HL2 series used for regression produces curves that follow gap-distorted price paths rather than genuine trend structures
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, momentum oscillators, or volume analysis to validate POC and value area interactions with broader analytical context before acting on regression-relative distribution levels
[*][i]POC Offset Bias[/i]: Monitor the position of the POC relative to the centerline across successive sessions as a structural bias indicator. A POC consistently above the centerline across multiple regression windows suggests a persistent positive deviation tendency in the current trend phase.
[*][i]Mode Selection by Objective[/i]: Use Letters mode for structural time-at-price analysis analogous to conventional market profile. Use Heatmap mode to assess how distribution shifted over the regression period. Use Profile mode to quickly assess distribution shape and skew relative to the centerline.
[*][i]Regression Mode Discipline[/i]: Commit to a regression mode based on the instrument's observed trend curvature rather than switching between modes reactively. Polynomial mode adds a second degree of freedom that can overfit short-term noise if the lookback window is too short.
[*][i]Window Length Stability[/i]: Maintain a consistent regression length when using the POC and value area as ongoing structural references. Changing the length significantly shifts the curve and redistributes the profile, making successive POC comparisons unreliable.
[/list]
[b]Disclaimer[/b]

Regression Market Profile [BOSWaves] is a professional-grade regression-relative distribution and market profile analysis tool. It uses ordinary least squares curve fitting with deviation-based participation mapping but does not predict future price movements. Results depend on market conditions, instrument trend characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Regression Market Profile [BOSWaves]", overlay = true, max_polylines_count = 100, max_boxes_count = 500, max_labels_count = 500, calc_bars_count = 500)

// ┌────────────────────────────── BOSWaves ─ Groups ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gCore = "Regression"
const string gTPO  = "Interior"
const string gVis  = "Display"

// ┌────────────────────────────── BOSWaves ─ Tooltips ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string tt_regLen      = "Number of bars in the regression lookback window. Higher = smoother, longer-term curve that reacts slowly; lower = tighter fit to recent price action."
const string tt_regMode     = "Linear = straight best-fit regression line. Polynomial = quadratic curve that bends to follow the curvature of the trend."
const string tt_chanWidth   = "Half-width of the distribution channel in standard deviations. Higher = taller interior spanning more price range around the curve; lower = tighter, more concentrated distribution."
const string tt_innerMode   = "Heatmap: colored grid cells showing the distribution migrating over time.\nProfile: curved volume bars extending from the right edge.\nLetters: TPO letter boxes following the regression curve."
const string tt_numRows     = "Number of horizontal price rows the interior is divided into. Higher = finer vertical granularity and more detailed distribution; lower = coarser, chunkier rows."
const string tt_numCols     = "Number of time segments for heatmap mode. Each column is normalized and colored independently. Higher = more columns showing finer migration of the distribution over time."
const string tt_profilePct  = "Maximum horizontal extent of the profile bars as a fraction of the regression length. Higher = longer bars reaching further left from the right edge."
const string tt_tpoTF       = "Timeframe that defines one TPO period. Each period at this timeframe is assigned its own letter. Higher timeframe = fewer, broader letters covering more bars each."
const string tt_boxWidth    = "Width of each TPO letter box in bars. Higher = wider, more legible letters that occupy more horizontal space on the chart."
const string tt_vaPct       = "Percentage of total activity contained in the Value Area around the POC. Higher = wider value area capturing more of the distribution; lower = tighter core."
const string tt_showPOC     = "Shows the Point of Control — the price row with the highest concentration — as a glowing line following the curve, plus its price label to the right."
const string tt_showVA      = "Shows the Value Area boundaries as dotted lines marking the high-activity zone around the POC."
const string tt_showSD      = "Shows the 1, 2, and 3 standard-deviation envelopes as dotted bounds around the regression curve, fading with distance."
const string tt_hotCol      = "Color for the densest / most recent end of the gradient — the 'hot' side of the heatmap and profile."
const string tt_coldCol     = "Color for the sparsest / oldest end of the gradient — the 'cold' side of the heatmap and profile."
const string tt_pocCol      = "Color applied to the Point of Control line, glow, and price label."
const string tt_vaCol       = "Color applied to the Value Area boundary lines."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
int    regLen      = input.int(200, "Length", minval = 50, maxval = 500, group = gCore, tooltip = tt_regLen)
string regMode     = input.string("Polynomial", "Mode", options = ["Linear", "Polynomial"], group = gCore, tooltip = tt_regMode)
float  chanWidth   = input.float(3.0, "Channel Width (SD×)", minval = 1.0, maxval = 5.0, step = 0.25, group = gCore, tooltip = tt_chanWidth)

string innerMode   = input.string("Letters", "Inner Display", options = ["Heatmap", "Profile", "Letters"], group = gTPO, tooltip = tt_innerMode)
int    numRows     = input.int(12, "Rows", minval = 6, maxval = 20, group = gTPO, tooltip = tt_numRows)
int    numCols     = input.int(6, "Heatmap Columns", minval = 3, maxval = 10, group = gTPO, tooltip = tt_numCols)
float  profilePct  = input.float(0.3, "Profile Width", minval = 0.1, maxval = 0.6, step = 0.05, group = gTPO, tooltip = tt_profilePct)
string tpoTF       = input.timeframe("30", "TPO Timeframe", group = gTPO, tooltip = tt_tpoTF)
int    boxWidth    = input.int(2, "Letter Box Width", minval = 1, maxval = 5, group = gTPO, tooltip = tt_boxWidth)
float  vaPct       = input.float(70, "Value Area %", minval = 30, maxval = 90, group = gTPO, tooltip = tt_vaPct) / 100

bool   showPOC     = input.bool(true, "Show POC", group = gVis, tooltip = tt_showPOC)
bool   showVA      = input.bool(true, "Show Value Area", group = gVis, tooltip = tt_showVA)
bool   showSD      = input.bool(true, "Show SD Bounds", group = gVis, tooltip = tt_showSD)

color  hotCol      = input.color(#ffff00, "Hot", inline = "c", group = gVis, tooltip = tt_hotCol)
color  coldCol     = input.color(#2962ff, "Cold", inline = "c", group = gVis, tooltip = tt_coldCol)
color  pocCol      = input.color(#ff9800, "POC", group = gVis, tooltip = tt_pocCol)
color  vaCol       = input.color(#80cbc4, "VA", group = gVis, tooltip = tt_vaCol)

// ┌────────────────────────────── BOSWaves ─ Regression Engine ──────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
int deg = regMode == "Linear" ? 1 : 2

polyreg(float src, int len, int d) =>
    if barstate.islast
        X = matrix.new<float>(len, d + 1, 0.0)
        for i = 0 to len - 1
            for j = 0 to d
                X.set(i, j, math.pow(i, j))
        y = matrix.new<float>(len, 1, 0.0)
        for i = 0 to len - 1
            y.set(i, 0, src[len - 1 - i])
        Xt      = matrix.transpose(X)
        XtX     = matrix.mult(Xt, X)
        Xty     = matrix.mult(Xt, y)
        XtX_inv = matrix.inv(XtX)
        b       = matrix.mult(XtX_inv, Xty)
        matrix.mult(X, matrix.col(b, 0))

predictions = polyreg(hl2, regLen, deg)
float stdev_val = ta.stdev(hl2, regLen)

// ┌────────────────────────────── BOSWaves ─ Alphabet ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var string[] alpha = array.from(
     "A","B","C","D","E","F","G","H","I","J","K","L","M",
     "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l",
     "m","n","o","p","q","r","s","t","u","v","w","x","y","z")

// ┌────────────────────────────── BOSWaves ─ Drawing Storage ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var polyline[] activePolys = array.new<polyline>()
var box[]      activeBoxes = array.new<box>()
var label[]    activeLbls  = array.new<label>()

// ┌────────────────────────────── BOSWaves ─ Main Render ────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if barstate.islast and not na(predictions)
    int pLen = array.size(predictions)

    if pLen > 0
        // ── Cleanup ──
        for p in activePolys
            p.delete()
        activePolys.clear()
        for b in activeBoxes
            b.delete()
        activeBoxes.clear()
        for lb in activeLbls
            lb.delete()
        activeLbls.clear()

        float maxDev = stdev_val * chanWidth
        float rowH   = (2 * maxDev) / numRows

        // ── Global row counts for POC / VA ──
        globalCounts = array.new<int>(numRows, 0)

        for i = 0 to pLen - 1
            float pred   = array.get(predictions, i)
            float actual = hl2[regLen - 1 - i]
            float dev    = actual - pred
            int   row    = int(math.floor((dev + maxDev) / rowH))
            row         := math.max(0, math.min(numRows - 1, row))
            globalCounts.set(row, globalCounts.get(row) + 1)

        int maxCount  = globalCounts.max()
        int pocRow    = globalCounts.indexof(maxCount)
        int totalBars = globalCounts.sum()

        // Value Area
        int vaBot = pocRow
        int vaTop = pocRow
        int vaSum = globalCounts.get(pocRow)
        float vaThresh = totalBars * vaPct

        while vaSum < vaThresh
            int addBot = vaBot > 0 ? globalCounts.get(vaBot - 1) : 0
            int addTop = vaTop < numRows - 1 ? globalCounts.get(vaTop + 1) : 0
            if addBot >= addTop and vaBot > 0
                vaBot -= 1
                vaSum += globalCounts.get(vaBot)
            else if vaTop < numRows - 1
                vaTop += 1
                vaSum += globalCounts.get(vaTop)
            else
                break

        // ══════════════════════════════════════════════════════════════════
        //  INTERIOR: HEATMAP MODE — curved polygon cells per column
        // ══════════════════════════════════════════════════════════════════
        if innerMode == "Heatmap"
            int colWidth = int(math.ceil(float(pLen) / numCols))

            cellCounts = array.new<int>(numCols * numRows, 0)

            for i = 0 to pLen - 1
                int col     = math.min(int(math.floor(float(i) / colWidth)), numCols - 1)
                float pred  = array.get(predictions, i)
                float actual = hl2[regLen - 1 - i]
                float dev   = actual - pred
                int   row   = int(math.floor((dev + maxDev) / rowH))
                row        := math.max(0, math.min(numRows - 1, row))
                cellCounts.set(col * numRows + row, cellCounts.get(col * numRows + row) + 1)

            for col = 0 to numCols - 1
                int colMax = 0
                for row = 0 to numRows - 1
                    colMax := math.max(colMax, cellCounts.get(col * numRows + row))

                int colStart = col * colWidth
                int colEnd   = math.min(colStart + colWidth - 1, pLen - 1)

                if colMax > 0
                    for row = 0 to numRows - 1
                        int cnt  = cellCounts.get(col * numRows + row)
                        if cnt == 0
                            continue

                        float norm     = float(cnt) / float(colMax)
                        float lowerOff = -maxDev + row * rowH
                        float upperOff = lowerOff + rowH
                        bool  isPOC    = row == pocRow
                        bool  inVA     = row >= vaBot and row <= vaTop

                        cellPts = array.new<chart.point>()

                        for i = colStart to colEnd
                            float pred = array.get(predictions, i)
                            int xIdx   = bar_index + i - regLen + 1
                            cellPts.push(chart.point.from_index(xIdx, pred + upperOff))

                        for i = colEnd to colStart
                            float pred = array.get(predictions, i)
                            int xIdx   = bar_index + i - regLen + 1
                            cellPts.push(chart.point.from_index(xIdx, pred + lowerOff))

                        color fillC = na
                        if isPOC
                            fillC := color.new(pocCol, 8)
                        else
                            int baseT = inVA ? 8 : 12
                            fillC := color.new(
                                 color.from_gradient(norm, 0, 1, coldCol, hotCol),
                                 int(math.max(baseT, 20 - norm * 8)))

                        if cellPts.size() > 2
                            activePolys.push(polyline.new(cellPts, true, true,
                                 line_color = color.new(color.white, 100),
                                 fill_color = fillC))

        // ══════════════════════════════════════════════════════════════════
        //  INTERIOR: PROFILE MODE — curved bars from right edge
        // ══════════════════════════════════════════════════════════════════
        if innerMode == "Profile"
            int dynWidth = math.max(1, math.round(120 / numRows))

            for row = 0 to numRows - 1
                int cnt = globalCounts.get(row)
                if cnt == 0
                    continue

                float norm     = maxCount > 0 ? float(cnt) / float(maxCount) : 0.0
                int   barLen   = math.max(3, int(norm * pLen * profilePct))
                int   startI   = pLen - barLen
                float lowerOff = -maxDev + row * rowH
                float upperOff = lowerOff + rowH
                bool  isPOC    = row == pocRow
                bool  inVA     = row >= vaBot and row <= vaTop

                barPts = array.new<chart.point>()

                for i = startI to pLen - 1
                    float pred = array.get(predictions, i)
                    int xIdx   = bar_index + i - regLen + 1
                    barPts.push(chart.point.from_index(xIdx, pred + upperOff))

                for i = pLen - 1 to startI
                    float pred = array.get(predictions, i)
                    int xIdx   = bar_index + i - regLen + 1
                    barPts.push(chart.point.from_index(xIdx, pred + lowerOff))

                color fillC = na
                if isPOC
                    fillC := color.new(pocCol, 8)
                else
                    int t = inVA ? 8 : 12
                    fillC := color.new(
                         color.from_gradient(norm, 0, 1, coldCol, hotCol),
                         int(math.max(t, 20 - norm * 8)))

                if barPts.size() > 2
                    activePolys.push(polyline.new(barPts, true, true,
                         line_color = color.new(color.white, 100),
                         fill_color = fillC))

        // ══════════════════════════════════════════════════════════════════
        //  INTERIOR: LETTERS MODE — TPO boxes following the curve
        // ══════════════════════════════════════════════════════════════════
        if innerMode == "Letters"
            int desiredTF     = timeframe.in_seconds(tpoTF)
            int chartTF       = timeframe.in_seconds()
            int barsPerPeriod = math.max(1, desiredTF / chartTF)

            int maxPeriods = int(math.ceil(float(pLen) / barsPerPeriod))
            if maxPeriods > alpha.size()
                barsPerPeriod := int(math.ceil(float(pLen) / alpha.size()))

            letters = array.new<string>(numRows, "")
            counts  = array.new<int>(numRows, 0)
            int actualMaxPeriod = 0

            for i = 0 to pLen - 1
                int letterIdx = int(i / barsPerPeriod)
                if letterIdx >= alpha.size()
                    continue
                if letterIdx > actualMaxPeriod
                    actualMaxPeriod := letterIdx

                string letter = alpha.get(letterIdx)
                float pred    = array.get(predictions, i)
                float actual  = hl2[regLen - 1 - i]
                float dev     = actual - pred
                int   row     = int(math.floor((dev + maxDev) / rowH))
                row          := math.max(0, math.min(numRows - 1, row))

                string existing = letters.get(row)
                if not str.contains(existing, letter)
                    letters.set(row, existing + letter)
                    counts.set(row, counts.get(row) + 1)

            float maxPeriodF = math.max(1., float(actualMaxPeriod))
            int   baseX      = bar_index - regLen + 1

            for row = 0 to numRows - 1
                string ltrs = letters.get(row)
                int strLen  = str.length(ltrs)
                if strLen == 0
                    continue

                bool isPOC = row == pocRow
                bool inVA  = row >= vaBot and row <= vaTop
                bool isSP  = strLen == 1

                for c = 0 to strLen - 1
                    string ch  = str.substring(ltrs, c, c + 1)
                    int left   = baseX + c * boxWidth
                    int right  = left + boxWidth

                    // Find regression value at this x position
                    int predIdx = c * boxWidth
                    if predIdx >= pLen
                        continue

                    float pred     = array.get(predictions, predIdx)
                    float lowerOff = -maxDev + row * rowH
                    float upperOff = lowerOff + rowH

                    // Color by letter position in alphabet (time gradient)
                    int alpIdx  = alpha.indexof(ch)
                    float gradT = alpIdx >= 0 ? float(alpIdx) / maxPeriodF : 0.5

                    color bgC = na
                    color txC = na

                    if isPOC
                        bgC := color.new(pocCol, 8)
                        txC := color.black
                    else if isSP
                        bgC := color.new(hotCol, 12)
                        txC := color.white
                    else
                        color gCol = color.from_gradient(gradT, 0, 1, coldCol, hotCol)
                        int trn    = inVA ? 8 : 14
                        bgC := color.new(gCol, trn)
                        txC := color.white

                    activeBoxes.push(box.new(left, pred + upperOff, right, pred + lowerOff,
                         bgcolor = bgC,
                         border_color = color.new(bgC, 15),
                         border_width = 1,
                         text = ch,
                         text_color = txC,
                         text_size = size.tiny))

        // ══════════════════════════════════════════════════════════════════
        //  BACKBONE: POC, VA, SD, Center — always drawn
        // ══════════════════════════════════════════════════════════════════

        // ── POC line — glow + core ──
        if showPOC and pocRow >= 0
            float pocOff = -maxDev + pocRow * rowH + rowH * 0.5
            pocGlow = array.new<chart.point>()
            pocCore = array.new<chart.point>()
            for i = 0 to pLen - 1
                float pred = array.get(predictions, i)
                int xIdx   = bar_index + i - regLen + 1
                pocGlow.push(chart.point.from_index(xIdx, pred + pocOff))
                pocCore.push(chart.point.from_index(xIdx, pred + pocOff))
            if pocGlow.size() > 1
                activePolys.push(polyline.new(pocGlow,
                     line_width = 5, line_color = color.new(pocCol, 60)))
                activePolys.push(polyline.new(pocCore,
                     line_width = 2, line_color = pocCol))

        // ── Value Area ──
        if showVA
            float vaTopOff = -maxDev + (vaTop + 1) * rowH
            float vaBotOff = -maxDev + vaBot * rowH
            vaTPts = array.new<chart.point>()
            vaBPts = array.new<chart.point>()
            for i = 0 to pLen - 1
                float pred = array.get(predictions, i)
                int xIdx   = bar_index + i - regLen + 1
                vaTPts.push(chart.point.from_index(xIdx, pred + vaTopOff))
                vaBPts.push(chart.point.from_index(xIdx, pred + vaBotOff))
            if vaTPts.size() > 1
                activePolys.push(polyline.new(vaTPts,
                     line_width = 1, line_style = line.style_dotted,
                     line_color = color.new(vaCol, 30)))
                activePolys.push(polyline.new(vaBPts,
                     line_width = 1, line_style = line.style_dotted,
                     line_color = color.new(vaCol, 30)))

        // ── SD bounds ──
        if showSD
            for m = 1 to 3
                int trn = m == 1 ? 50 : m == 2 ? 65 : 80
                sdU = array.new<chart.point>()
                sdD = array.new<chart.point>()
                for i = 0 to pLen - 1
                    float pred = array.get(predictions, i)
                    int xIdx   = bar_index + i - regLen + 1
                    sdU.push(chart.point.from_index(xIdx, pred + stdev_val * m))
                    sdD.push(chart.point.from_index(xIdx, pred - stdev_val * m))
                if sdU.size() > 1
                    activePolys.push(polyline.new(sdU,
                         line_width = 1, line_style = line.style_dotted,
                         line_color = color.new(chart.fg_color, trn)))
                    activePolys.push(polyline.new(sdD,
                         line_width = 1, line_style = line.style_dotted,
                         line_color = color.new(chart.fg_color, trn)))

        // ── Centerline ──
        cPts = array.new<chart.point>()
        for i = 0 to pLen - 1
            float pred = array.get(predictions, i)
            int xIdx   = bar_index + i - regLen + 1
            cPts.push(chart.point.from_index(xIdx, pred))
        if cPts.size() > 1
            activePolys.push(polyline.new(cPts,
                 line_width = 1, line_style = line.style_dashed,
                 line_color = color.new(chart.fg_color, 60)))

        // ── POC price label ──
        if showPOC and pocRow >= 0
            float lastPred = array.get(predictions, pLen - 1)
            float pocPrice = lastPred + (-maxDev + pocRow * rowH + rowH * 0.5)
            activeLbls.push(label.new(bar_index + 2, pocPrice,
                 str.tostring(pocPrice, format.mintick),
                 style = label.style_none,
                 textcolor = pocCol,
                 size = size.tiny))
````
