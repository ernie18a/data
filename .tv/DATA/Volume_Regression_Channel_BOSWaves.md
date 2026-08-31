<!-- tradingview-pine-id: PUB;8f7d5f2c4744477e8f18a3862203b7ea -->
<!-- tradingviewscripts-format: 1 -->
# Volume Regression Channel [BOSWaves]

Source: https://www.tradingview.com/script/ZUhXviyz-Volume-Regression-Channel-BOSWaves/

## Description

Volume Regression Channel [BOSWaves] - Regression-Anchored Volume Flow Visualization with Inward Pressure Bars, Edge Flares, and Cumulative End Profile

Overview

Volume Regression Channel [BOSWaves] is a regression-anchored volume flow analysis system that fits a polynomial or linear curve to recent price history and maps buy and sell volume pressure inward from the channel boundaries toward the centerline on every bar, where bar height, coloring, edge flare intensity, and end profile distribution are all driven by actual volume participation and close-position-derived directional weighting rather than fixed histogram positions or arbitrary price levels.

[image]https://www.tradingview.com/x/ll2DoHkr/[/image]

Instead of displaying volume as a separate panel histogram detached from price context, this system integrates volume directly into the regression channel structure. Each bar's volume is split into buy and sell components based on where close sat within the bar's range, and those components are rendered as inward-pointing bars anchored to the upper and lower channel edges, with bar height proportional to normalized volume and coloring distinguishing above-average from below-average participation. The result is a channel where the volume activity on every bar is visible in spatial relationship to the channel boundaries that define the structural context.

This creates a complete price and volume framework within a single overlay. The regression curve defines the trend's expected path. The gradient channel fills communicate the statistical distance from the centerline. The inward volume bars reveal participation intensity and directional split at each bar. The flow-colored centerline segments expose directional pressure evolution across the window. Edge flares highlight exceptional volume events occurring near the channel boundaries. Bound diamond markers identify the first bar of each new boundary touch. And the cumulative end profile extending from the current bar provides a full buy-sell volume distribution summary across the channel's price range for the entire regression window.

Price is therefore evaluated not just for its position within the regression channel but for the volume participation and directional flow composition supporting its location at every bar across the full lookback window.

Conceptual Framework

Volume Regression Channel is founded on the principle that a regression channel becomes significantly more analytically powerful when volume participation is integrated directly into its structure rather than displayed separately, allowing the trader to simultaneously assess where price sits relative to the statistical trend expectation and how much and what type of volume supported each bar's position within that channel.

Standard regression channel tools provide structural price context through the curve and its standard deviation bounds but offer no volume intelligence, leaving traders to consult a separate panel to understand participation dynamics. This framework eliminates that separation by embedding volume directly into the channel geometry, with inward bars, edge flares, centerline flow coloring, and the end profile all deriving from the same volume and price data that defines the channel itself.

Three core principles guide the design:

[]Volume should be displayed in direct spatial relationship to the channel structure it relates to, with inward bars anchored to the boundaries and sized proportionally to participation intensity so that high-volume bars are immediately identifiable within their structural context.
[]Buy and sell volume should be separated using close position within the bar range, rendering the directional split of each bar's participation as distinct inward segments that reveal whether volume at each price location was predominantly absorbed by buyers or sellers.
[*]A cumulative end profile should summarize the full window's volume distribution at the current channel position, providing a reference for where participation has been most concentrated across the regression window without requiring a separate profile indicator.

This shifts regression channel analysis from structural price context alone into an integrated price-volume framework where participation intensity, directional flow composition, and cumulative distribution are all visible within the channel geometry itself.

Theoretical Foundation

The indicator combines matrix ordinary least squares regression fitting to HL2 price data, standard deviation channel construction, close-position buy-sell volume splitting, volume SMA normalization for significance classification, three-layer gradient polyline fill construction, inward volume bar rendering with dynamic width scaling, flow-weighted centerline segment coloring, edge flare detection combining volume and boundary proximity conditions, and an overlap-weighted cumulative buy-sell profile with smoothing applied across the channel rows.

The regression is computed using the same OLS matrix approach as conventional polynomial regression, producing a prediction array covering all bars in the lookback window for both linear and quadratic modes. The channel width is scaled by the rolling standard deviation of HL2, ensuring channel boundaries adapt to the instrument's actual price variability. Volume splitting uses close position within the high-low range as the proxy for directional commitment, with bars closing near the high allocating more volume to buying and bars closing near the low allocating more to selling. The end profile smooths each row's accumulated buy and sell volume with a three-point weighted average before normalizing and rendering.

Four internal systems operate in tandem:

[]Regression Channel Engine: Computes OLS curve fitting in linear or polynomial mode, derives the standard deviation channel width, and constructs all polyline geometry for the gradient fills, glow boundary lines, and centerline using chart.point arrays that follow the regression curve.
[]Inward Volume Bar System: For each bar in the recent display window, normalizes volume against the window maximum, splits the normalized height into buy and sell components by close position, and renders inward lines from the channel edges with dynamic width scaling and above-average volume coloring.
[]Edge Flare and Bound Marker System: Monitors each recent bar for the combination of above-threshold volume and boundary zone proximity, rendering bright glowing line segments on the channel edge when qualifying conditions are met, and places diamond markers at the first bar of each new boundary touch.
[]Centerline Flow and End Profile Engine: Divides the centerline into sixty flow segments and computes volume-weighted directional bias for each, coloring segments by flow direction and strength. Simultaneously accumulates overlap-weighted buy and sell volume into channel rows across the full window, smooths the distribution, and renders horizontal profile bars extending from the current bar edge.

This design ensures volume participation is embedded into every layer of the channel visualization while the end profile provides a complete cumulative distribution summary that updates with each new bar.

How It Works

Volume Regression Channel evaluates price through a sequence of regression-aware and volume-integrated processes:

[]Regression Curve Fitting: On the last bar, the OLS matrix computation produces a prediction array covering all bars in the configured lookback window using either a linear or polynomial fit to HL2, providing the baseline curve that all channel geometry and volume positioning follows.
[]Channel Width Calculation: The standard deviation of HL2 over the regression window multiplied by the SD multiplier defines the channel half-width, establishing the upper and lower boundary distances from the curve at each bar position.
[]Gradient Fill Construction: Three polyline polygon regions are constructed for each of the upper and lower channel halves at proportional fractions of the standard deviation width, filled with progressively increasing opacity from inner to outer to produce a smooth visual gradient across the channel depth.
[]Boundary Glow Rendering: Triple polylines at the upper and lower channel boundaries create a glow effect using wide low-opacity outer lines and a narrow full-opacity core line, providing visually prominent boundary markers that follow the regression curve.
[]Volume Normalization and Splitting: For each bar in the volume display window, raw volume is normalized against the window maximum to produce a proportional height score. Close position within the high-low range splits this height into buy and sell components, with the buy portion anchored to the lower boundary and the sell portion anchored to the upper boundary pointing inward.
[]Inward Bar Rendering: Buy and sell component heights are rendered as inward-pointing lines from the respective channel edges with dynamic width scaling based on relative volume and opacity intensifying for above-average participation bars.
[]Edge Flare Detection: Each recent bar is tested for the combination of volume exceeding the flare multiplier threshold and price high or low reaching within the configured edge zone percentage of the channel boundary. Qualifying bars receive bright dual-layer line segments on the boundary edge with width scaling by relative volume strength.
[]Bound Diamond Placement: Each bar is tested for initial channel boundary contact, with a diamond marker placed at the first bar of each new upper or lower boundary touch to mark where price newly reached the statistical extremes.
[]Centerline Flow Coloring: The centerline is divided into sixty equal segments and each segment's volume-weighted close position bias is computed across its constituent bars. Segments are colored green, red, or neutral based on the directional flow value and intensity with line width scaling to strength.
[]End Profile Construction: All bars in the regression window contribute their volume to the profile rows based on price overlap between the bar range and each row boundary, with the contribution split into buy and sell portions by close position. The accumulated distribution is smoothed and normalized before rendering as horizontal buy and sell bars extending from the current bar.

Together, these elements form a continuously updating integrated price-volume framework where the regression structure, volume participation, flow direction, and cumulative distribution are all rendered within the same channel geometry on each bar update.

Interpretation

Volume Regression Channel should be interpreted as a regression-anchored structural framework with embedded volume participation intelligence at every level:

[]Regression Curve: The fitted centerline represents the trend's statistical best-fit path through the lookback window, with the flow-colored segments revealing whether volume-weighted directional bias above or below the curve was predominantly bullish or bearish across each portion of the window.
[]Channel Boundaries: The upper boundary with its red glow represents the upper standard deviation limit where price is statistically extended above the regression expectation. The lower boundary with its green glow represents the lower limit where price is statistically extended below.
[]Gradient Fill Depth: The three-layer gradient within each channel half provides visual depth cues, with the innermost near-transparent fill representing mild deviation and the outermost fully opaque fill representing maximum channel boundary proximity.
[]Inward Buy Bars (Green): Lines extending upward from the lower channel boundary reflect the buy-attributed volume portion of each bar. Taller bars indicate greater buying participation. Brighter coloring indicates above-average total volume on that bar.
[]Inward Sell Bars (Red): Lines extending downward from the upper channel boundary reflect the sell-attributed volume portion of each bar. Taller bars indicate greater selling participation. Brighter coloring indicates above-average total volume.
[]Neutral Volume Bars (Gray): Below-average volume bars render in neutral gray regardless of direction, identifying periods of low participation where the directional split carries reduced analytical significance.
[]Edge Flares: Bright glowing line segments on the channel boundary mark bars where significant volume occurred close to the boundary edge, identifying high-participation boundary interaction events that frequently precede reversals or continuations from the statistical extremes.
[]Bound Diamonds: Small colored diamonds at boundary touch initiation bars mark where price first reached the channel edge after a period of interior activity, identifying the onset of boundary interaction sequences.
[]End Profile: The horizontal bar chart extending from the right edge shows the cumulative volume distribution across the channel's price range for the full regression window, with green segments showing buy-attributed volume and red segments showing sell-attributed volume at each price row. The longest bars identify the price levels with the greatest total participation concentration.
[]Colored Candles: Optional candle coloring reflects whether price is above or below the regression centerline, providing a continuous directional bias reference directly on the price chart.

Boundary proximity, inward bar height and direction, edge flare frequency, centerline flow coloring, and end profile distribution collectively provide more analytical depth than any element in isolation.

Signal Logic & Visual Cues

Volume Regression Channel does not generate discrete buy or sell signals but provides continuous structural and volume participation reference through several interaction cues:

[]Edge Flare Events: High-volume boundary proximity bars highlighted by bright edge flares identify exceptional participation at the statistical extremes, marking the bars most likely to precede structural reactions from channel boundaries.
[]Bound Diamond Initiation: Diamond markers at the first bar of new boundary touches identify where price has newly entered channel extreme territory, providing early warning of boundary interaction sequences before their outcome is determined.

Centerline flow segment coloring provides ongoing directional pressure context across the full window, with color and width encoding whether the volume-weighted bias at each point in the regression history was bullish, bearish, or neutral.

Strategy Integration

Volume Regression Channel fits within regression-informed structural and volume-participation-based analytical approaches:

[]Boundary Interaction Trading: Use channel boundary touches combined with edge flare presence as elevated-significance interaction events. High-volume flares at the boundary suggest meaningful participation at the statistical extreme that frequently precedes a reaction back toward the centerline or a volume-supported continuation beyond it.
[]End Profile Acceptance Reading: Use the end profile distribution to identify the price rows with the greatest cumulative participation concentration. Price returning to high-volume profile rows encounters levels where the greatest historical participation occurred within the regression window, making them structurally significant references for support, resistance, or reversion.
[]Inward Bar Volume Divergence: Monitor situations where price is approaching a boundary but inward bar height from the opposing direction is increasing, indicating growing participation against the directional move and potentially signaling that the boundary interaction will result in rejection rather than continuation.
[]Centerline Flow Direction: Use centerline flow coloring as a mid-channel directional bias indicator. Sustained green flow segments suggest dominant buying pressure within the regression window. Sustained red segments suggest dominant selling. Neutral gray segments indicate a contested equilibrium without clear directional participation weight.
[]Regression Mode Selection: Use Polynomial mode for markets with visible curvature in their trend structure where the quadratic bend produces a more accurate fit. Use Linear mode for markets trending in a straight consistent direction where the polynomial's additional degree of freedom would overfit noise.
[]Profile Distribution Skew Analysis: Compare the buy and sell distribution balance in the end profile to assess whether the window's participation was predominantly concentrated above or below the centerline, providing a volume-based directional bias reading that complements the price-based trend assessment.

Technical Implementation Details

[]Regression Engine: Matrix OLS with design matrix construction, normal equation formation, matrix inversion, and prediction array application for linear or polynomial curve fitting to HL2
[]Channel Construction: Standard deviation-scaled channel width with three-layer gradient polyline fills and triple-line glow boundaries following the regression curve
[]Inward Volume System: Window-maximum normalization with close-position buy-sell splitting, dynamic width scaling by relative volume, and above-average volume color intensification
[]Edge Flare System: Volume multiplier threshold combined with boundary zone percentage proximity testing with dual-layer glow line rendering and width scaling by relative volume
[]Centerline Flow: Sixty-segment volume-weighted close-position bias computation with directional color and width encoding
[]End Profile: Overlap-weighted row accumulation across the full regression window with three-point smoothing, normalization, and horizontal buy-sell bar rendering with curved outline polyline
[*]Performance Profile: All rendering triggered on last bar with full object cleanup and rebuild each cycle, configurable regression length capped at 490 bars for object management

Optimal Application Parameters

Timeframe Guidance:

[]1 - 5 min: Intraday regression flow tracking with shorter length and tighter SD multiplier for fast-adapting channel that captures intraday trend structure with responsive volume distribution
[]15 - 60 min: Session-level structural volume analysis with balanced regression length and moderate SD multiplier for meaningful channel geometry across typical session directional moves
[]4H - Daily: Swing-level regression channel profiling with longer lookback and polynomial mode for a curve-following channel spanning multi-session trend structures

Suggested Baseline Configuration:

[]Regression Length: 236
[]SD Multiplier: 1.75
[]Mode: Polynomial
[]Volume SMA: 15
[]Bar Height (ATR×): 2.1
[]Show Edge Flares: Enabled
[]Show Bound Diamonds: Enabled
[]Show Centerline: Enabled
[]Show End Profile: Enabled
[*]Color Candles: Enabled (requires disabling original chart candles in chart settings)

These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, volume behavior, and preferred channel sensitivity, so fine-tuning is expected for optimal performance.

Parameter Calibration Notes

Use the following adjustments to refine behavior without altering the core logic:

[]Channel too wide or narrow: Adjust SD Multiplier to expand or contract the channel width relative to the instrument's typical deviation from the regression curve, calibrating boundary distance to realistic price excursion ranges.
[]Curve fits too loosely to recent price: Decrease Regression Length to shorten the lookback window, producing a tighter curve that adapts more quickly to recent structural changes. Switch to Polynomial mode if visible trend curvature is present.
[]Inward bars too tall or short: Adjust Bar Height (ATR×) to scale the maximum inward bar height, making volume bars more prominent during high-participation sessions or more subtle on instruments with lower volume variance.
[]Too many or too few edge flares: Increase Flare Volume Multiplier to restrict flares to only exceptional volume events, or adjust Flare Edge Zone % to control how close to the boundary price must be before a flare qualifies.
[]End profile too wide or compact: Adjust Profile Width to control the maximum horizontal extent of the end profile bars, calibrating the profile size to the available chart space at the current zoom level.
[]Profile rows too coarse or granular: Adjust Profile Rows to increase or decrease vertical resolution, with higher values providing finer detail across the channel's price range and lower values producing broader, more readable rows.
[*]Too many bound diamonds cluttering the chart: The diamond system marks only first-bar boundary touches. On instruments with frequent boundary contact the marker density may be high. Disable Show Bound Diamonds and rely on edge flares alone for boundary interaction identification.

Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

Performance Characteristics

High Effectiveness:

[]Trending markets where the regression curve provides an accurate fit to the directional price path and the channel boundaries represent meaningful statistical extremes with genuine participation significance
[]Liquid instruments with consistent volume where the buy-sell splitting produces reliable directional participation readings and the end profile accumulates a statistically meaningful distribution across the regression window
[]Boundary interaction strategies where edge flares and bound diamond markers identify high-participation channel extreme events that frequently precede structural reactions
[]Distribution analysis workflows where the end profile provides a regression-relative volume profile summary that replaces or complements standalone volume profile indicators

Reduced Effectiveness:

[]Choppy, directionless markets where the regression curve has no clear shape and channel boundaries are penetrated frequently without the sustained trend structure required for meaningful boundary interaction analysis
[]Low-liquidity instruments where thin volume produces unreliable buy-sell splits and end profile distributions that reflect random participation patterns rather than genuine directional flow
[]Markets with frequent gaps where the HL2 series used for regression produces curves distorted by discontinuous price events that shift the channel relative to actual price structure
[]Very short regression windows where insufficient bars per channel row produce end profiles dominated by noise rather than statistically meaningful participation concentration
[]Consolidation environments where price oscillates near the regression centerline without reaching channel boundaries, reducing the analytical value of edge flares and bound diamonds while producing uniformly short inward bars

Integration Guidelines

[]Confluence: Combine with BOSWaves momentum tools, order block analysis, or structural indicators to validate channel boundary interactions and edge flare events with broader analytical context
[]End Profile Reference: Use the end profile distribution as a volume-based reference layer for price levels visited by price within the regression window. High-volume rows in the profile identify price levels with the greatest historical participation concentration, making them structurally significant references for future interaction.
[]Inward Bar Divergence Monitoring: Monitor inward bar height on opposing sides as price approaches boundaries. Growing opposing-side bars during boundary approach suggest increasing counter-directional participation that may oppose the boundary continuation.
[]Regression Mode Consistency: Maintain a consistent regression mode when using the channel as an ongoing structural reference. Switching between Linear and Polynomial shifts the curve and redistributes the channel geometry, making successive comparisons of profile distribution and boundary levels unreliable.
[]Centerline Cross Awareness: Treat price crossing the regression centerline as a potential flow transition event. Combined with a centerline flow segment color change from one direction to the other, centerline crossings with above-average volume suggest genuine directional repositioning within the channel structure.

Disclaimer

Volume Regression Channel [BOSWaves] is a professional-grade regression-anchored volume flow analysis tool. It uses OLS curve fitting with close-position volume splitting and cumulative profile construction but does not predict future price movements. Results depend on market conditions, instrument volume characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates momentum context, order flow analysis, and comprehensive risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Volume Regression Channel [BOSWaves]", overlay = true,
     max_polylines_count = 100, max_lines_count = 500, max_labels_count = 500,
     max_bars_back = 500, calc_bars_count = 500)


// ┌────────────────────────────── BOSWaves ─ Tooltips ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

const string g1 = "Regression Channel"
const string g2 = "Volume Flow"
const string g3 = "Bound Markers"
const string g4 = "Display"

const string tt_regLen          = "Number of bars in the regression lookback window. Higher = smoother, longer-term curve that reacts slowly to recent price changes; lower = tighter fit to recent price action."
const string tt_sdMult          = "Number of standard deviations defining the channel width. Higher = wider channel spanning more price range; lower = tighter channel hugging the regression curve more closely."
const string tt_regMode         = "Linear = straight best-fit regression line. Polynomial = quadratic curve that bends to follow the curvature of the prevailing trend."
const string tt_volSmaLen       = "Lookback length for the volume SMA baseline. Used to determine whether each bar's volume is above or below average for flow bar coloring and flare detection."
const string tt_volScale        = "Maximum height of the inward volume bars as an ATR multiple. Higher = taller bars that are more visually prominent; lower = subtler bars that stay closer to the channel edges."
const string tt_barWidth        = "Base width of each inward volume bar in pixels. Scales up further for bars with above-average volume participation."
const string tt_showFlares      = "Highlights bars where significant volume occurred near the channel boundaries, drawing bright edge lines that intensify with volume strength."
const string tt_flareVolMult    = "Minimum volume relative to SMA required to trigger an edge flare. 1.0 = any above-average bar qualifies; higher values restrict flares to more exceptional volume events."
const string tt_flareZonePct    = "How close to the channel boundary price must be for a flare to fire, expressed as a percentage of the channel half-width. Higher = flares fire further from the edge; lower = only very near-boundary bars trigger flares."
const string tt_showBoundMarks  = "Shows a small diamond marker at the first bar of each new channel boundary touch, marking where price initially reached the upper or lower band edge."
const string tt_showCenter      = "Shows the regression centerline with a flow-colored pressure overlay that reflects the directional bias and volume weight of each price segment along the curve."
const string tt_showSidebar     = "Shows the end-of-channel volume profile extending to the right of the current bar, displaying the cumulative buy and sell volume distribution across the channel's price range."
const string tt_showProfileOutline = "Adds white boundary lines around the end profile including the seam line, centerline connector, right edge, and a curved outline tracing the profile shape."
const string tt_sideRows        = "Number of horizontal price rows in the end profile. Higher = finer vertical granularity and more detailed flow distribution; lower = coarser, chunkier rows."
const string tt_sideWidth       = "Maximum horizontal width of the end profile in bars. Higher = longer bars reaching further to the right; lower = more compact profile closer to the current bar."
const string tt_profileBarWidth = "Line thickness of each horizontal row in the end profile. Higher = thicker, more visible profile bars; lower = finer, more subtle rows."
const string tt_paintBars       = "Colors chart candles by current trend direction relative to the regression centerline. Green when price is above, red when below. Requires disabling original chart candles in chart settings."
const string tt_buyCol          = "Color applied to bullish flow bars, lower channel gradient, and buy-dominant profile rows."
const string tt_sellCol         = "Color applied to bearish flow bars, upper channel gradient, and sell-dominant profile rows."
const string tt_neutralCol      = "Color applied to below-average volume bars where participation is insufficient to classify directional flow."
const string tt_chanCol         = "Color applied to the channel boundary glow lines, centerline, and end profile outline elements."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘

int    regLen     = input.int(236, "Regression Length", minval = 50, maxval = 490, group = g1, tooltip = tt_regLen)
float  sdMult     = input.float(1.75, "SD Multiplier", minval = 0.5, maxval = 4.0, step = 0.25, group = g1, tooltip = tt_sdMult)
string regMode    = input.string("Polynomial", "Mode", options = ["Linear", "Polynomial"], group = g1, tooltip = tt_regMode)

int    volSmaLen    = input.int(15, "Volume SMA", minval = 5, group = g2, tooltip = tt_volSmaLen)
float  volScale     = input.float(2.1, "Bar Height (ATR×)", step = 0.1, group = g2, tooltip = tt_volScale)
int    barWidth     = input.int(5, "Bar Width", minval = 1, maxval = 5, group = g2, tooltip = tt_barWidth)
bool   showFlares   = input.bool(true, "Show Edge Flares", group = g2, tooltip = tt_showFlares)
float  flareVolMult = input.float(1.0, "Flare Volume Multiplier", minval = 1.0, maxval = 3.0, step = 0.05, group = g2, tooltip = tt_flareVolMult)
float  flareZonePct = input.float(40, "Flare Edge Zone %", minval = 5, maxval = 40, step = 5, group = g2, tooltip = tt_flareZonePct)

bool   showBoundMarks = input.bool(true, "Show Bound Diamonds", group = g3, tooltip = tt_showBoundMarks)

bool   showCenter         = input.bool(true, "Show Centerline", group = g4, tooltip = tt_showCenter)
bool   showSidebar        = input.bool(true, "Show End Profile", group = g4, tooltip = tt_showSidebar)
bool   showProfileOutline = input.bool(true, "Show Profile White Lines", group = g4, tooltip = tt_showProfileOutline)
int    sideRows           = input.int(36, "Profile Rows", minval = 12, maxval = 36, group = g4, tooltip = tt_sideRows)
int    sideWidth          = input.int(30, "Profile Width", minval = 6, maxval = 30, group = g4, tooltip = tt_sideWidth)
int    profileBarWidth    = input.int(10, "Profile Thickness", minval = 3, maxval = 10, group = g4, tooltip = tt_profileBarWidth)
bool   paintBars          = input.bool(true, "Color Candles", group = g4, tooltip = tt_paintBars)
color  buyCol             = input.color(#00FF00, "Buy", inline = "c", group = g4, tooltip = tt_buyCol)
color  sellCol            = input.color(#FF0066, "Sell", inline = "c", group = g4, tooltip = tt_sellCol)
color  neutralCol         = input.color(#555555, "Low Vol", group = g4, tooltip = tt_neutralCol)
color  chanCol            = input.color(#ffffff, "Channel", group = g4, tooltip = tt_chanCol)

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

// ┌────────────────────────────── BOSWaves ─ Live Channel Values ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float regCenter = ta.linreg(hl2, regLen, 0)
float sd        = stdev_val * sdMult
float upperLive = regCenter + sd
float lowerLive = regCenter - sd
float chanRange = upperLive - lowerLive
float atr       = ta.atr(14)

// ┌────────────────────────────── BOSWaves ─ Volume + Trend ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float volSma = ta.sma(volume, volSmaLen)

bool  trendUp  = close > regCenter
color trendCol = trendUp ? buyCol : sellCol

// ┌────────────────────────────── BOSWaves ─ Candle Coloring ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
plotcandle(open, high, low, close, "Candles",
     color = trendCol,
     wickcolor = trendCol,
     bordercolor = trendCol,
     display = paintBars ? display.all : display.none)

// ┌────────────────────────────── BOSWaves ─ Drawing Storage ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var polyline[] polys      = array.new<polyline>()
var line[]     volLines   = array.new<line>()
var line[]     sideLines  = array.new<line>()
var line[]     flareLines = array.new<line>()
var label[]    boundMarks = array.new<label>()

// ┌────────────────────────────── BOSWaves ─ Render ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if barstate.islast and not na(predictions)
    int pLen = array.size(predictions)

    if pLen > 0
        for p in polys
            p.delete()
        polys.clear()
        for ln in volLines
            ln.delete()
        volLines.clear()
        for sl in sideLines
            sl.delete()
        sideLines.clear()
        for fl in flareLines
            fl.delete()
        flareLines.clear()
        for mark in boundMarks
            mark.delete()
        boundMarks.clear()

        float sdVal = stdev_val * sdMult
        float maxH  = nz(atr) * volScale

        float volMax = 0.0
        for i = 0 to pLen - 1
            int off = pLen - 1 - i
            if off < 490
                volMax := math.max(volMax, nz(volume[off]))

        // ── Channel gradient: upper inner ──
        upperInner = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperInner.push(chart.point.from_index(x, p + sdVal * 0.45))
        for i = pLen - 1 to 0
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperInner.push(chart.point.from_index(x, p))
        if upperInner.size() > 2
            polys.push(polyline.new(upperInner, true, true,
                 line_color = color.new(chanCol, 100),
                 fill_color = color.new(sellCol, 97)))

        // ── Channel gradient: upper middle ──
        upperMiddle = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperMiddle.push(chart.point.from_index(x, p + sdVal * 0.75))
        for i = pLen - 1 to 0
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperMiddle.push(chart.point.from_index(x, p + sdVal * 0.45))
        if upperMiddle.size() > 2
            polys.push(polyline.new(upperMiddle, true, true,
                 line_color = color.new(chanCol, 100),
                 fill_color = color.new(sellCol, 94)))

        // ── Channel gradient: upper outer ──
        upperOuter = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperOuter.push(chart.point.from_index(x, p + sdVal))
        for i = pLen - 1 to 0
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperOuter.push(chart.point.from_index(x, p + sdVal * 0.75))
        if upperOuter.size() > 2
            polys.push(polyline.new(upperOuter, true, true,
                 line_color = color.new(chanCol, 100),
                 fill_color = color.new(sellCol, 88)))

        // ── Channel gradient: lower inner ──
        lowerInner = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerInner.push(chart.point.from_index(x, p))
        for i = pLen - 1 to 0
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerInner.push(chart.point.from_index(x, p - sdVal * 0.45))
        if lowerInner.size() > 2
            polys.push(polyline.new(lowerInner, true, true,
                 line_color = color.new(chanCol, 100),
                 fill_color = color.new(buyCol, 97)))

        // ── Channel gradient: lower middle ──
        lowerMiddle = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerMiddle.push(chart.point.from_index(x, p - sdVal * 0.45))
        for i = pLen - 1 to 0
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerMiddle.push(chart.point.from_index(x, p - sdVal * 0.75))
        if lowerMiddle.size() > 2
            polys.push(polyline.new(lowerMiddle, true, true,
                 line_color = color.new(chanCol, 100),
                 fill_color = color.new(buyCol, 94)))

        // ── Channel gradient: lower outer ──
        lowerOuter = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerOuter.push(chart.point.from_index(x, p - sdVal * 0.75))
        for i = pLen - 1 to 0
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerOuter.push(chart.point.from_index(x, p - sdVal))
        if lowerOuter.size() > 2
            polys.push(polyline.new(lowerOuter, true, true,
                 line_color = color.new(chanCol, 100),
                 fill_color = color.new(buyCol, 88)))

        // ── Upper band glow + core ──
        upperPts = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            upperPts.push(chart.point.from_index(x, p + sdVal))
        if upperPts.size() > 1
            polys.push(polyline.new(upperPts, false, false,
                 line_width = 7, line_color = color.new(sellCol, 90)))
            polys.push(polyline.new(upperPts, false, false,
                 line_width = 4, line_color = color.new(sellCol, 68)))
            polys.push(polyline.new(upperPts, false, false,
                 line_width = 1, line_color = color.new(sellCol, 12)))

        // ── Lower band glow + core ──
        lowerPts = array.new<chart.point>()
        for i = 0 to pLen - 1
            float p = array.get(predictions, i)
            int x   = bar_index + i - regLen + 1
            lowerPts.push(chart.point.from_index(x, p - sdVal))
        if lowerPts.size() > 1
            polys.push(polyline.new(lowerPts, false, false,
                 line_width = 7, line_color = color.new(buyCol, 90)))
            polys.push(polyline.new(lowerPts, false, false,
                 line_width = 4, line_color = color.new(buyCol, 68)))
            polys.push(polyline.new(lowerPts, false, false,
                 line_width = 1, line_color = color.new(buyCol, 12)))

        // ── Reactive outer edge flares ──
        if showFlares
            int flareDrawLen = math.min(pLen, 80)
            int flareStart   = math.max(1, pLen - flareDrawLen)
            int flareCount   = 0

            for i = pLen - 1 to flareStart
                if flareCount >= 30
                    break

                int off = pLen - 1 - i
                float p = array.get(predictions, i)
                float previousP = array.get(predictions, i - 1)
                float vSma = nz(volSma[off])
                float rVol = vSma > 0 ? nz(volume[off]) / vSma : 0.0

                float upperBand = p + sdVal
                float lowerBand = p - sdVal
                float upperZone = p + sdVal * (1.0 - flareZonePct / 100.0)
                float lowerZone = p - sdVal * (1.0 - flareZonePct / 100.0)

                bool highVolume = rVol >= flareVolMult
                bool nearUpper  = high[off] >= upperZone
                bool nearLower  = low[off] <= lowerZone

                float upperDistance = math.abs(close[off] - upperBand)
                float lowerDistance = math.abs(close[off] - lowerBand)

                bool flareUpper = highVolume and nearUpper and (not nearLower or upperDistance <= lowerDistance)
                bool flareLower = highVolume and nearLower and (not nearUpper or lowerDistance < upperDistance)

                int x1 = bar_index + i - regLen
                int x2 = bar_index + i - regLen + 1
                int flareWidth = int(math.max(4, math.min(7, 4 + math.round(math.max(0.0, rVol - flareVolMult) * 2.0))))

                if flareUpper
                    float y1 = previousP + sdVal
                    float y2 = p + sdVal
                    flareLines.push(line.new(x1, y1, x2, y2,
                         color = color.new(sellCol, 78), width = math.min(10, flareWidth + 3)))
                    flareLines.push(line.new(x1, y1, x2, y2,
                         color = color.new(sellCol, 0), width = flareWidth))
                    flareCount += 1

                if flareLower and flareCount < 30
                    float y1 = previousP - sdVal
                    float y2 = p - sdVal
                    flareLines.push(line.new(x1, y1, x2, y2,
                         color = color.new(buyCol, 78), width = math.min(10, flareWidth + 3)))
                    flareLines.push(line.new(x1, y1, x2, y2,
                         color = color.new(buyCol, 0), width = flareWidth))
                    flareCount += 1

        // ── Channel bound hit diamonds ──
        if showBoundMarks
            int markerCount = 0
            for i = pLen - 1 to 0
                if markerCount >= 120
                    break

                int off = pLen - 1 - i
                if off >= 490
                    continue

                float p         = array.get(predictions, i)
                float upperBand = p + sdVal
                float lowerBand = p - sdVal
                int x           = bar_index + i - regLen + 1

                bool upperHit = high[off] >= upperBand
                bool lowerHit = low[off] <= lowerBand
                bool previousUpperHit = false
                bool previousLowerHit = false

                if i > 0
                    int previousOff     = off + 1
                    float previousP     = array.get(predictions, i - 1)
                    float previousUpper = previousP + sdVal
                    float previousLower = previousP - sdVal

                    if previousOff < 490
                        previousUpperHit := high[previousOff] >= previousUpper
                        previousLowerHit := low[previousOff] <= previousLower

                float markerOffset = math.max(nz(atr[off], atr) * 0.08, syminfo.mintick * 4.0)

                if upperHit and not previousUpperHit
                    boundMarks.push(label.new(x, math.max(high[off], upperBand) + markerOffset, "",
                         style = label.style_diamond,
                         size = size.small,
                         color = sellCol,
                         textcolor = sellCol))
                    markerCount += 1

                if lowerHit and not previousLowerHit and markerCount < 120
                    boundMarks.push(label.new(x, math.min(low[off], lowerBand) - markerOffset, "",
                         style = label.style_diamond,
                         size = size.small,
                         color = buyCol,
                         textcolor = buyCol))
                    markerCount += 1

        // ── Centerline flow glow + pressure segments ──
        if showCenter
            centerPts = array.new<chart.point>()
            for i = 0 to pLen - 1
                float p = array.get(predictions, i)
                int x   = bar_index + i - regLen + 1
                centerPts.push(chart.point.from_index(x, p))
            if centerPts.size() > 1
                polys.push(polyline.new(centerPts, false, false,
                     line_width = 6, line_color = color.new(chanCol, 88)))

            int flowStep = int(math.max(1, math.ceil((pLen - 1) / 60.0)))
            for chunk = 0 to 59
                int startI = chunk * flowStep
                if startI >= pLen - 1
                    break

                int chunkEnd = math.min(startI + flowStep, pLen - 1)
                float flowSum = 0.0
                float weightSum = 0.0
                flowPts = array.new<chart.point>()

                for j = startI to chunkEnd
                    int off = pLen - 1 - j
                    float p = array.get(predictions, j)
                    int x   = bar_index + j - regLen + 1
                    flowPts.push(chart.point.from_index(x, p))

                    if off < 490
                        float span = math.max(high[off] - low[off], syminfo.mintick)
                        float pos  = math.max(0.0, math.min(1.0, (close[off] - low[off]) / span))
                        float vSma = nz(volSma[off])
                        float rVol = vSma > 0 ? math.min(nz(volume[off]) / vSma, 3.0) / 3.0 : 0.0
                        flowSum   += (pos * 2.0 - 1.0) * rVol
                        weightSum += rVol

                float flowValue = weightSum > 0 ? flowSum / weightSum : 0.0
                float strength  = math.min(1.0, math.abs(flowValue))
                int flowWidth   = 1 + int(math.round(strength * 4.0))
                int flowT       = int(math.max(8, 58 - strength * 50.0))
                color flowCol   = math.abs(flowValue) < 0.08 ? color.new(neutralCol, 42) : color.new(flowValue > 0 ? buyCol : sellCol, flowT)

                if flowPts.size() > 1
                    polys.push(polyline.new(flowPts, false, false,
                         line_width = flowWidth, line_color = flowCol))

        // ── Volume bars pointing INWARD ──
        int flowDrawLen = math.min(pLen, 180)
        for i = pLen - flowDrawLen to pLen - 1
            int off = pLen - 1 - i
            if off >= 490
                continue

            int   x       = bar_index + i - regLen + 1
            float pred    = array.get(predictions, i)
            float vol     = nz(volume[off])
            float vSma    = nz(volSma[off])
            float volNorm = volMax > 0 ? vol / volMax : 0.0
            float barH    = volNorm * maxH

            float barSpan = math.max(high[off] - low[off], syminfo.mintick)
            float closeP  = math.max(0.0, math.min(1.0, (close[off] - low[off]) / barSpan))
            float buyH    = barH * closeP
            float sellH   = barH * (1.0 - closeP)

            bool  highVol = vol > vSma
            float rVol    = vSma > 0 ? vol / vSma : 1.0
            int dynWidth  = int(math.max(1, math.min(5, math.round(barWidth + (rVol - 1.0) * 1.25))))
            int flowT     = highVol ? int(math.max(5, 62 - math.min(rVol, 3.0) * 18.0)) : 58

            if buyH > syminfo.mintick
                float y1 = pred - sdVal
                float y2 = y1 + buyH
                color c  = highVol ? color.new(buyCol, flowT) : color.new(neutralCol, 62)
                volLines.push(line.new(x, y1, x, y2, color = c, width = dynWidth))

            if sellH > syminfo.mintick
                float y1 = pred + sdVal
                float y2 = y1 - sellH
                color c  = highVol ? color.new(sellCol, flowT) : color.new(neutralCol, 62)
                volLines.push(line.new(x, y1, x, y2, color = c, width = dynWidth))

        // ── Curved volume pressure profile ──
        if showSidebar
            float lastPred = array.get(predictions, pLen - 1)
            float sideTop  = lastPred + sdVal
            float sideBot  = lastPred - sdVal
            float sideSpan = sideTop - sideBot
            float rowH     = sideSpan / sideRows

            buyDelta  = array.new<float>(sideRows, 0.0)
            sellDelta = array.new<float>(sideRows, 0.0)

            for i = 0 to pLen - 1
                int off = pLen - 1 - i
                if off >= 490
                    continue

                float pred    = array.get(predictions, i)
                float pTop    = pred + sdVal
                float pBot    = pred - sdVal
                float pSpan   = pTop - pBot
                float pRowH   = pSpan / sideRows
                float vol     = nz(volume[off])
                float barSpan = math.max(high[off] - low[off], syminfo.mintick)
                float closeP  = math.max(0.0, math.min(1.0, (close[off] - low[off]) / barSpan))
                float bVol    = vol * closeP
                float sVol    = vol * (1.0 - closeP)
                float bHi     = high[off]
                float bLo     = low[off]

                for r = 0 to sideRows - 1
                    float rBot = pBot + pRowH * r
                    float rTop = rBot + pRowH
                    float olap = math.max(0.0, math.min(bHi, rTop) - math.max(bLo, rBot))
                    if olap > 0
                        float frac = olap / barSpan
                        buyDelta.set(r, buyDelta.get(r) + bVol * frac)
                        sellDelta.set(r, sellDelta.get(r) + sVol * frac)

            buySmooth  = array.new<float>(sideRows, 0.0)
            sellSmooth = array.new<float>(sideRows, 0.0)
            float sideMax = 0.0

            for r = 0 to sideRows - 1
                float bPrev = buyDelta.get(math.max(0, r - 1))
                float bNow  = buyDelta.get(r)
                float bNext = buyDelta.get(math.min(sideRows - 1, r + 1))
                float sPrev = sellDelta.get(math.max(0, r - 1))
                float sNow  = sellDelta.get(r)
                float sNext = sellDelta.get(math.min(sideRows - 1, r + 1))
                float bSm   = (bPrev + bNow * 2.0 + bNext) / 4.0
                float sSm   = (sPrev + sNow * 2.0 + sNext) / 4.0
                buySmooth.set(r, bSm)
                sellSmooth.set(r, sSm)
                sideMax := math.max(sideMax, bSm + sSm)

            int sideX = bar_index + 2
            profilePts = array.new<chart.point>()

            for r = 0 to sideRows - 1
                float bVal  = buySmooth.get(r)
                float sVal  = sellSmooth.get(r)
                float total = bVal + sVal
                float norm  = sideMax > 0 ? total / sideMax : 0.0
                int totalW  = int(math.round(norm * sideWidth))
                int buyW    = total > 0 ? int(math.round(totalW * bVal / total)) : 0
                int sellW   = math.max(0, totalW - buyW)
                int buyX    = sideX + buyW
                int endX    = buyX + sellW
                float y     = sideBot + rowH * (r + 0.5)
                int rowT    = int(math.max(8, 72 - norm * 64.0))

                if buyW > 0
                    sideLines.push(line.new(sideX, y, buyX, y,
                         color = color.new(buyCol, rowT), width = profileBarWidth))

                if sellW > 0
                    sideLines.push(line.new(buyX, y, endX, y,
                         color = color.new(sellCol, rowT), width = profileBarWidth))

                profilePts.push(chart.point.from_index(endX, y))

            if showProfileOutline
                sideLines.push(line.new(bar_index, sideBot, bar_index, sideTop,
                     color = color.new(chanCol, 78), width = 5))
                sideLines.push(line.new(bar_index, sideBot, bar_index, sideTop,
                     color = color.new(chanCol, 20), width = 1))
                sideLines.push(line.new(bar_index, lastPred, sideX, lastPred,
                     color = color.new(chanCol, 72), width = 4))
                sideLines.push(line.new(bar_index, lastPred, sideX, lastPred,
                     color = color.new(chanCol, 18), width = 1))
                sideLines.push(line.new(sideX, sideBot, sideX, sideTop,
                     color = color.new(chanCol, 82), width = 2))

                if profilePts.size() > 1
                    polys.push(polyline.new(profilePts, true, false,
                         line_width = 7, line_color = color.new(chanCol, 88)))
                    polys.push(polyline.new(profilePts, true, false,
                         line_width = 1, line_color = color.new(chanCol, 24)))
````
