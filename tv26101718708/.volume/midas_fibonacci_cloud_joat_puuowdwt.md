# MIDAS Fibonacci Cloud [JOAT]

- url: https://www.tradingview.com/script/PuUowdwt-MIDAS-Fibonacci-Cloud-JOAT/
- type: indicator
- pine_id: PUB;9d639b5403c24e93bf5461feffff3d64
- version: 1.0

## Description

[b]MIDAS Fibonacci Cloud [JOAT][/b]

[b]Introduction[/b]

MIDAS Fibonacci Cloud is an open-source VWAP-based analytical tool that combines a MIDAS-anchored volume-weighted average price with six Fibonacci-scaled standard deviation bands, a Z-score probability engine, and a synthetic order flow score to produce an integrated picture of institutional value, statistical deviation, and directional pressure on a single overlay.

The problem this solves is band relevance. Standard VWAP deviations use fixed multipliers (1×, 2×, 3× standard deviation) that carry no structural meaning in market terms. Replacing those multipliers with Fibonacci ratios (0.236, 0.382, 0.5, 0.618, 1.0, 1.618) means the band levels correspond to proportional retracement relationships that institutional participants commonly reference. The 1.618 band in particular acts as an extreme extension zone where reversion probability, quantified by the built-in Z-score engine, typically exceeds 99.7%.

[image]https://www.tradingview.com/x/Zi6kB8Gh/[/image]

[b]Core Concepts[/b]

[b]1. MIDAS VWAP with Configurable Anchoring[/b]

The VWAP calculation uses the MIDAS method — cumulative volume-weighted price that resets at a user-selected anchor point rather than running as a continuous session VWAP. The anchor can be set automatically (based on the current timeframe), manually to a specific higher timeframe, or to a precise date. This allows the VWAP to be anchored to any significant market event.

The variance term used for standard deviation is computed directly from the volume-weighted sum of squared prices, producing a statistically correct VWAP standard deviation:

[pine]
float midasVwap = sumVolPrice / sumVol
float variance  = (sumVolSq / sumVol) - math.pow(midasVwap, 2)
float stdDev    = math.sqrt(math.max(0, variance))
[/pine]

[b]2. Fibonacci Deviation Bands[/b]

Six band pairs are computed above and below the VWAP anchor using the standard deviation scaled by a global sensitivity multiplier and each Fibonacci ratio. Upper bands are colored in the bull theme color with decreasing opacity from band 1 to band 6; lower bands in the bear theme color with the same gradient. A gradient fill connects the outer zone (fib4–fib6) to visually highlight the extreme deviation region.

[b]3. Z-Score and Bell Curve Probability[/b]

Each bar's Z-score is computed as the signed distance from the VWAP in units of standard deviation. The dashboard converts this to a mean-reversion probability using standard normal distribution thresholds: within 1σ = 68.2%, within 2σ = 95.4%, within 3σ = 99.7%, beyond 3σ = 99.9%.

[b]4. Synthetic Order Flow Score[/b]

A bar-level order flow score is computed from three components: candle body-to-range ratio (directional conviction), volume relative to the 20-bar average (institutional participation), and wick rejection percentage (price acceptance or rejection). These are weighted 40/35/25 and scored 0 to 100. VWAP crossover signals are gated by this score — crossovers with low order flow scores are filtered as noise.

[b]5. Gradient Fill Zones[/b]

The two outer Fibonacci bands (fib4 and fib6) are connected with a gradient fill that creates a visual glow effect identifying the extreme deviation zones — the regions where price is statistically most likely to be overextended.

[image]https://www.tradingview.com/x/dSSxFdKJ/[/image]

[b]Features[/b]

[list]
[*][b]MIDAS VWAP with three anchor modes:[/b] Auto (timeframe-adaptive), Timeframe (manual higher TF), Date (specific date anchor)
[*][b]Six Fibonacci deviation band pairs:[/b] Levels at 0.236, 0.382, 0.500, 0.618, 1.000, 1.618 × standard deviation × global sensitivity
[*][b]Gradient fill on extreme zones:[/b] Color-to-transparent gradient between fib4 and fib6 identifies overextension zones
[*][b]Z-score and reversion probability:[/b] Computed every bar with bell curve probability output (68.2% / 95.4% / 99.7% / 99.9%)
[*][b]Synthetic order flow gate:[/b] Body ratio, volume participation, and wick rejection combined into a 0-100 score that gates VWAP cross signals
[*][b]Candle coloring by Z-score:[/b] Bar colors intensity-coded by distance from VWAP — neutral near center, saturated at extremes
[*][b]Band labels at right edge:[/b] Each band level labeled with its Fibonacci ratio and price value, updated each bar
[*][b]Anchor reset marker:[/b] Vertical marker in elite theme color at each VWAP reset point
[*][b]Four color themes:[/b] Phantom, Neon, Classic, Solar
[*][b]Non-repainting:[/b] VWAP and bands computed cumulatively from anchor; no future data referenced
[*][b]Institutional dashboard:[/b] 8-row table showing VWAP price, distance %, Z-score, reversion probability, order flow score, and market state
[/list]

[b]Input Parameters[/b]

[b]Anchor Settings:[/b]
[list]
[*]Anchor Method: Auto / Timeframe / Date
[*]Manual Timeframe: Timeframe to anchor to when method is Timeframe
[*]Manual Date: Specific timestamp when method is Date
[/list]

[b]Fibonacci Multipliers:[/b]
[list]
[*]Global Sensitivity: Scales all band widths proportionally (default: 1.2)
[*]Fib Level 1 through 6: Individual Fibonacci ratios (defaults: 0.236, 0.382, 0.500, 0.618, 1.000, 1.618)
[/list]

[b]Visual Styles:[/b]
[list]
[*]Color Theme: Phantom / Neon / Classic / Solar
[*]Highlight Candles: Toggle candle coloring by Z-score
[*]Show Band Labels: Toggle right-edge price labels on each band
[*]Table Position and Size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Choose Your Anchor[/b]
For intraday scalping, use Auto or Daily anchor. For swing trading, use Weekly or Monthly. For event-driven analysis, use Date and anchor to a specific earnings release, FOMC announcement, or major swing point.

[b]Step 2: Read Band Levels as Statistical Reference[/b]
The 0.5 band is one half standard deviation from VWAP — a mild deviation typical of normal trending behavior. The 1.618 band is the extreme extension zone. Price at the 1.618 band has a statistical reversion probability above 99.7%, but this does not mean reversion is imminent or guaranteed.

[b]Step 3: Check the Reversion Probability[/b]
Read the Reversion Prob row in the dashboard. As Z-score rises above 2, reversion probability exceeds 95.4%. This quantifies how unusual the current deviation is relative to the full history from the anchor point.

[b]Step 4: Confirm with Order Flow Score[/b]
The Order Flow score reflects whether the current bar has institutional characteristics. A high score (above 60) during a VWAP cross suggests genuine participation. A low score (below 30) during a cross suggests a potentially false signal.

[b]Indicator Limitations[/b]

[list]
[*]The VWAP standard deviation widens significantly with the anchor period. Bands anchored to a six-month period will be very wide; bands anchored to one day will be tight. The global sensitivity parameter must be adjusted accordingly
[*]The Z-score probabilities assume normally distributed returns, which markets do not produce. Fat tails mean extreme Z-scores occur more frequently than the percentages suggest
[*]The synthetic order flow score uses tick volume as a proxy for actual order flow. On assets with low tick frequency, this approximation is less reliable
[*]VWAP-based analysis is most relevant for liquid instruments
[*]This indicator does not generate entry or exit signals. It provides statistical deviation context
[/list]

[b]Originality Statement[/b]

[list]
[*]Replacing standard deviation band multipliers with Fibonacci ratios (0.236 through 1.618), scaled by a volume-weighted standard deviation from a MIDAS anchor, is not replicated in existing open-source Pine Script v6 VWAP publications
[*]The combination of Z-score computation, bell curve probability quantification, and a synthetic order flow score as a gate for VWAP cross signals within a single indicator is an original integration
[*]The candle coloring gradient driven by Z-score intensity provides real-time deviation awareness directly on price bars without requiring a separate oscillator panel
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Statistical deviation probabilities are based on a normal distribution assumption that financial markets do not satisfy. Past VWAP behavior does not predict future price action. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("MIDAS Fibonacci Cloud [JOAT]", overlay=true, max_labels_count=30)

// ============================================================================
// ◈ COLOR THEMES
// ============================================================================
string themeInput = input.string("Phantom", "Color Theme",
     options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// ============================================================================
// ◈ ANCHOR SETTINGS
// ============================================================================
var string GRP_ANCHOR = "◈ Anchor Settings"

string anchorMethod = input.string("Auto", "Anchor Method",
     options=["Auto","Timeframe","Date"], group=GRP_ANCHOR)

simple string anchorTf = input.timeframe("D", "Manual Timeframe",
     group=GRP_ANCHOR)

int anchorDate = input.time(timestamp("2024-01-01 00:00:00"),
     "Manual Date", group=GRP_ANCHOR)

// ============================================================================
// ◈ FIBONACCI MULTIPLIERS
// ============================================================================
var string GRP_BANDS = "◈ Fibonacci Multipliers"

float stdDevMult = input.float(1.2,  "Global Sensitivity",
     minval=0.1, maxval=5.0, step=0.1, group=GRP_BANDS)

float fib1 = input.float(0.236, "Fib Level 1", minval=0.0, group=GRP_BANDS)
float fib2 = input.float(0.382, "Fib Level 2", minval=0.0, group=GRP_BANDS)
float fib3 = input.float(0.500, "Fib Level 3", minval=0.0, group=GRP_BANDS)
float fib4 = input.float(0.618, "Fib Level 4", minval=0.0, group=GRP_BANDS)
float fib5 = input.float(1.000, "Fib Level 5", minval=0.0, group=GRP_BANDS)
float fib6 = input.float(1.618, "Fib Level 6", minval=0.0, group=GRP_BANDS)

// ============================================================================
// ◈ ORDER FLOW
// ============================================================================
var string GRP_OF = "◈ Order Flow"

float ofThreshold = input.float(40.0, "Min Order Flow Score to Signal",
     minval=0.0, maxval=100.0, group=GRP_OF)

// ============================================================================
// ◈ VISUAL STYLES
// ============================================================================
var string GRP_STYLE = "◈ Visual Styles"

bool   showCandles  = input.bool(true,  "Color Candles by Z-Score",
     group=GRP_STYLE)
bool   showLabels   = input.bool(true,  "Show Band Labels",
     group=GRP_STYLE)
string tableSize    = input.string("small", "Table Size",
     options=["tiny","small","normal"], group=GRP_STYLE)
string tablePos     = input.string("Top Right", "Table Position",
     options=["Top Right","Bottom Right","Top Left","Bottom Left"],
     group=GRP_STYLE)
int    tableTransp  = input.int(15, "Table Background Transparency",
     minval=0, maxval=100, group=GRP_STYLE)

// ============================================================================
// ◈ ANCHOR RESET LOGIC
// ============================================================================
// Determine auto timeframe based on chart resolution
string autoTf = timeframe.isintraday
     ? (timeframe.multiplier <= 15 ? "D" : "W")
     : (timeframe.isdaily ? "M" : "12M")

// Reset condition — one-bar true whenever the chosen anchor boundary is crossed
bool isReset = switch anchorMethod
    "Auto"      => timeframe.change(autoTf)
    "Timeframe" => timeframe.change(anchorTf)
    "Date"      => time >= anchorDate and time[1] < anchorDate
    => false

// ============================================================================
// ◈ MIDAS VWAP CALCULATION
// Cumulative volume-weighted average price that resets at the anchor boundary.
// Uses the exact MIDAS formula: price² term for online variance tracking.
// ============================================================================
var float sumVol      = 0.0
var float sumVolPrice = 0.0
var float sumVolSq    = 0.0

if isReset
    sumVol      := volume
    sumVolPrice := volume * hlc3
    sumVolSq    := volume * math.pow(hlc3, 2)
else
    sumVol      += volume
    sumVolPrice += volume * hlc3
    sumVolSq    += volume * math.pow(hlc3, 2)

// MIDAS VWAP – guard against zero volume
float midasVwap = sumVol > 0.0 ? sumVolPrice / sumVol : hlc3

// Population variance via computational formula: E[X²] - E[X]²
float variance = sumVol > 0.0
     ? (sumVolSq / sumVol) - math.pow(midasVwap, 2)
     : 0.0

// Clamp variance to zero before sqrt to avoid NaN on tiny floating-point errors
float stdDev = math.sqrt(math.max(0.0, variance))

// ============================================================================
// ◈ FIBONACCI DEVIATION BANDS
// Each band = VWAP ± (stdDev × sensitivity × fibLevel)
// ============================================================================
float baseDev = stdDev * stdDevMult

float upper1 = midasVwap + baseDev * fib1
float upper2 = midasVwap + baseDev * fib2
float upper3 = midasVwap + baseDev * fib3
float upper4 = midasVwap + baseDev * fib4
float upper5 = midasVwap + baseDev * fib5
float upper6 = midasVwap + baseDev * fib6

float lower1 = midasVwap - baseDev * fib1
float lower2 = midasVwap - baseDev * fib2
float lower3 = midasVwap - baseDev * fib3
float lower4 = midasVwap - baseDev * fib4
float lower5 = midasVwap - baseDev * fib5
float lower6 = midasVwap - baseDev * fib6

// ============================================================================
// ◈ Z-SCORE + REVERSION PROBABILITY
// Z-score measures standard-deviation distance from VWAP.
// Bell-curve cumulative probability approximation for reversion expectation.
// ============================================================================
float zScore  = stdDev > 0.0 ? (close - midasVwap) / stdDev : 0.0
float distPct = midasVwap > 0.0 ? (close - midasVwap) / midasVwap * 100.0 : 0.0
float absZ    = math.abs(zScore)

// Empirical rule probabilities (two-tailed)
float reversionPr = absZ < 1.0 ? 68.2
     : absZ < 2.0 ? 95.4
     : absZ < 3.0 ? 99.7
     : 99.9

// Market state relative to innermost Fibonacci band
bool isBullish = close > upper1
bool isBearish = close < lower1

// ============================================================================
// ◈ SYNTHETIC ORDER FLOW SCORE  (0–100)
// Composite of three micro-structure proxies:
//   bodyRatio   — proportion of bar range consumed by body (directionality)
//   volPartic   — relative volume normalised to 20-bar EMA (participation)
//   wickRejPct  — wick rejection in trend direction (institutional acceptance)
// ============================================================================
float bodyRatio  = (high - low) > 0.0
     ? math.abs(close - open) / (high - low)
     : 0.0

float avgVol20  = ta.ema(volume, 20)
float volPartic = avgVol20 > 0.0
     ? math.min(volume / avgVol20, 3.0) / 3.0
     : 0.5

float wickRejPct = (high - low) > 0.0
     ? (close > open
          ? (close - low)  / (high - low)
          : (high - close) / (high - low))
     : 0.5

// Weighted composite score
float orderFlow = bodyRatio * 40.0 + volPartic * 35.0 + wickRejPct * 25.0

// ============================================================================
// ◈ SIGNALS — VWAP cross gated by order flow score
// ============================================================================
bool crossAboveVwap = ta.crossover(close, midasVwap)
     and orderFlow >= ofThreshold
     and barstate.isconfirmed

bool crossBelowVwap = ta.crossunder(close, midasVwap)
     and orderFlow >= ofThreshold
     and barstate.isconfirmed

bool breakUpper6 = ta.crossover(close, upper6)
     and barstate.isconfirmed

bool breakLower6 = ta.crossunder(close, lower6)
     and barstate.isconfirmed

// ============================================================================
// ◈ CANDLE COLORING  — gradient tint from neutral to full theme colour
//   by z-score magnitude; disabled when showCandles = false
// ============================================================================
color candleColor = na
if showCandles
    if zScore > 0.0
        candleColor := color.from_gradient(
             zScore, 0.0, 3.0,
             color.new(colorBULL, 70), colorBULL)
    else
        candleColor := color.from_gradient(
             -zScore, 0.0, 3.0,
             color.new(colorBEAR, 70), colorBEAR)

barcolor(showCandles ? candleColor : na)

// ============================================================================
// ◈ PLOTS
// ============================================================================

// ── MIDAS VWAP centre line ──────────────────────────────────────────────────
plot(midasVwap, "MIDAS VWAP", color.new(chart.fg_color, 40), 2)

// ── Upper Fibonacci bands ───────────────────────────────────────────────────
p_u1 = plot(upper1, "U1 (0.236)", color.new(colorBULL, 85), 1)
p_u2 = plot(upper2, "U2 (0.382)", color.new(colorBULL, 80), 1)
p_u3 = plot(upper3, "U3 (0.500)", color.new(colorBULL, 75), 1)
p_u4 = plot(upper4, "U4 (0.618)", color.new(colorBULL, 70), 1)
p_u5 = plot(upper5, "U5 (1.000)", color.new(colorBULL, 60), 1)
p_u6 = plot(upper6, "U6 (1.618)", color.new(colorBULL, 40), 1)

// ── Lower Fibonacci bands ───────────────────────────────────────────────────
p_l1 = plot(lower1, "L1 (0.236)", color.new(colorBEAR, 85), 1)
p_l2 = plot(lower2, "L2 (0.382)", color.new(colorBEAR, 80), 1)
p_l3 = plot(lower3, "L3 (0.500)", color.new(colorBEAR, 75), 1)
p_l4 = plot(lower4, "L4 (0.618)", color.new(colorBEAR, 70), 1)
p_l5 = plot(lower5, "L5 (1.000)", color.new(colorBEAR, 60), 1)
p_l6 = plot(lower6, "L6 (1.618)", color.new(colorBEAR, 40), 1)

// ── Gradient fills ──────────────────────────────────────────────────────────
// Outer bull zone: fib4 → fib6 (upper bands, gradient from faint to rich)
fill(p_u4, p_u6, upper6, upper4,
     color.new(colorBULL, 95), color.new(colorBULL, 60),
     title="Upper Bull Zone")

// Outer bear zone: fib4 → fib6 (lower bands, gradient from faint to rich)
fill(p_l4, p_l6, lower4, lower6,
     color.new(colorBEAR, 95), color.new(colorBEAR, 60),
     title="Lower Bear Zone")

// Inner VWAP channel: gentle background between ±fib1
fill(p_u1, p_l1, upper1, lower1,
     color.new(colorBULL, 98), color.new(colorBEAR, 98),
     title="VWAP Channel")

// ── Anchor reset marker ─────────────────────────────────────────────────────
plotchar(isReset, "Anchor Reset", "|",
     location.top, colorELITE, size=size.tiny)

// ============================================================================
// ◈ BAND LABELS  — right-edge labels, updated only on the last bar
// ============================================================================
var label lb_u6 = na
var label lb_u5 = na
var label lb_u4 = na
var label lb_u3 = na
var label lb_vw = na
var label lb_l3 = na
var label lb_l4 = na
var label lb_l5 = na
var label lb_l6 = na

if showLabels and barstate.islast
    // Delete stale labels before creating fresh ones
    label.delete(lb_u6)
    label.delete(lb_u5)
    label.delete(lb_u4)
    label.delete(lb_u3)
    label.delete(lb_vw)
    label.delete(lb_l3)
    label.delete(lb_l4)
    label.delete(lb_l5)
    label.delete(lb_l6)

    int lbX = bar_index + 1

    lb_u6 := label.new(lbX, upper6,
         str.tostring(fib6, "#.###") + "  " + str.tostring(upper6, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBULL, 85),
         textcolor=colorBULL,
         size=size.tiny)

    lb_u5 := label.new(lbX, upper5,
         str.tostring(fib5, "#.###") + "  " + str.tostring(upper5, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBULL, 85),
         textcolor=color.new(colorBULL, 30),
         size=size.tiny)

    lb_u4 := label.new(lbX, upper4,
         str.tostring(fib4, "#.###") + "  " + str.tostring(upper4, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBULL, 85),
         textcolor=color.new(colorBULL, 40),
         size=size.tiny)

    lb_u3 := label.new(lbX, upper3,
         str.tostring(fib3, "#.###") + "  " + str.tostring(upper3, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBULL, 85),
         textcolor=color.new(colorBULL, 50),
         size=size.tiny)

    lb_vw := label.new(lbX, midasVwap,
         "VWAP  " + str.tostring(midasVwap, format.mintick),
         style=label.style_label_left,
         color=color.new(chart.fg_color, 80),
         textcolor=chart.fg_color,
         size=size.tiny)

    lb_l3 := label.new(lbX, lower3,
         str.tostring(fib3, "#.###") + "  " + str.tostring(lower3, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBEAR, 85),
         textcolor=color.new(colorBEAR, 50),
         size=size.tiny)

    lb_l4 := label.new(lbX, lower4,
         str.tostring(fib4, "#.###") + "  " + str.tostring(lower4, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBEAR, 85),
         textcolor=color.new(colorBEAR, 40),
         size=size.tiny)

    lb_l5 := label.new(lbX, lower5,
         str.tostring(fib5, "#.###") + "  " + str.tostring(lower5, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBEAR, 85),
         textcolor=color.new(colorBEAR, 30),
         size=size.tiny)

    lb_l6 := label.new(lbX, lower6,
         str.tostring(fib6, "#.###") + "  " + str.tostring(lower6, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBEAR, 85),
         textcolor=colorBEAR,
         size=size.tiny)

// ============================================================================
// ◈ SIGNAL LABELS  — intra-bar arrow labels for confirmed signals
// ============================================================================
float atr14 = ta.atr(14)

if crossAboveVwap
    label.new(bar_index, low - atr14 * 0.3,
         "▲  VWAP Cross",
         style=label.style_label_up,
         color=color.new(colorBULL, 75),
         textcolor=colorBULL,
         size=size.small)

if crossBelowVwap
    label.new(bar_index, high + atr14 * 0.3,
         "▼  VWAP Cross",
         style=label.style_label_down,
         color=color.new(colorBEAR, 75),
         textcolor=colorBEAR,
         size=size.small)

if breakUpper6 and not crossAboveVwap
    label.new(bar_index, high + atr14 * 0.3,
         "1.618 BREACH",
         style=label.style_label_down,
         color=color.new(colorELITE, 75),
         textcolor=colorELITE,
         size=size.tiny)

if breakLower6 and not crossBelowVwap
    label.new(bar_index, low - atr14 * 0.3,
         "1.618 BREACH",
         style=label.style_label_up,
         color=color.new(colorELITE, 75),
         textcolor=colorELITE,
         size=size.tiny)

// ============================================================================
// ◈ DASHBOARD TABLE  (8 data rows + header + footer = 10 rows total, index 0–9)
// ============================================================================

// Resolve table position inline — `position` is not a valid local type keyword in Pine v6
var table statsTable = table.new(
     tablePos == "Bottom Right" ? position.bottom_right :
     tablePos == "Top Left"     ? position.top_left :
     tablePos == "Bottom Left"  ? position.bottom_left :
     position.top_right,
     2, 10,
     bgcolor      = color.new(chart.bg_color, tableTransp),
     border_width = 1,
     border_color = color.new(#30363d, 40))

// Resolve table text size — infer type from initial value (no explicit `size` keyword)
tSz = tableSize == "tiny" ? size.tiny : tableSize == "normal" ? size.normal : size.small

// Helper closure: populate one cell
f_tc(int col, int row, string txt, color tc) =>
    table.cell(statsTable, col, row, txt,
         text_color  = tc,
         text_size   = tSz,
         bgcolor     = col == 0
              ? color.new(#161b22, 0)
              : color.new(#0d1117, 10),
         text_halign = col == 0
              ? text.align_left
              : text.align_right)

// Populate on last confirmed bar only to avoid redundant redraws
if barstate.islast
    // ── Colours ──────────────────────────────────────────────────────────
    color hBg  = color.new(#1A237E, 0)
    color cMut = color.new(#8b949e, 0)

    // ── Row 0: header ─────────────────────────────────────────────────────
    table.cell(statsTable, 0, 0,
         "MIDAS Fibonacci Cloud [JOAT]",
         text_color  = colorELITE,
         text_size   = tSz,
         bgcolor     = hBg,
         text_halign = text.align_left)
    table.cell(statsTable, 1, 0,
         timeframe.period + " | v1.0",
         text_color  = cMut,
         text_size   = tSz,
         bgcolor     = hBg,
         text_halign = text.align_right)

    // ── Row 1: VWAP ───────────────────────────────────────────────────────
    f_tc(0, 1, "VWAP", cMut)
    f_tc(1, 1, str.tostring(midasVwap, format.mintick), chart.fg_color)

    // ── Row 2: Distance % ─────────────────────────────────────────────────
    f_tc(0, 2, "Distance", cMut)
    color distCol = distPct > 0.0 ? colorBULL : colorBEAR
    f_tc(1, 2,
         (distPct > 0.0 ? "+" : "") + str.tostring(distPct, "#.##") + "%",
         distCol)

    // ── Row 3: Z-Score ────────────────────────────────────────────────────
    f_tc(0, 3, "Z-Score", cMut)
    color zCol = absZ > 2.0 ? colorBEAR
         : absZ > 1.0 ? colorNEUTR
         : colorBULL
    f_tc(1, 3, str.tostring(zScore, "#.##"), zCol)

    // ── Row 4: Reversion Probability ─────────────────────────────────────
    f_tc(0, 4, "Reversion Pr", cMut)
    color prCol = reversionPr > 95.0 ? colorBEAR
         : reversionPr > 68.0 ? colorNEUTR
         : colorBULL
    f_tc(1, 4, str.tostring(reversionPr, "#.#") + "%", prCol)

    // ── Row 5: Order Flow ─────────────────────────────────────────────────
    f_tc(0, 5, "Order Flow", cMut)
    color ofCol = orderFlow >= ofThreshold ? colorBULL : colorBEAR
    f_tc(1, 5,
         str.tostring(math.round(orderFlow)) + " / 100",
         ofCol)

    // ── Row 6: Market State ───────────────────────────────────────────────
    f_tc(0, 6, "State", cMut)
    string stateTxt = isBullish ? "BULLISH" : isBearish ? "BEARISH" : "RANGING"
    color  stateCol = isBullish ? colorBULL : isBearish ? colorBEAR : colorNEUTR
    f_tc(1, 6, stateTxt, stateCol)

    // ── Row 7: StdDev ─────────────────────────────────────────────────────
    f_tc(0, 7, "StdDev", cMut)
    f_tc(1, 7, str.tostring(stdDev, format.mintick), cMut)

    // ── Row 8: BaseDev ────────────────────────────────────────────────────
    f_tc(0, 8, "BaseDev", cMut)
    f_tc(1, 8, str.tostring(baseDev, format.mintick), cMut)

    // ── Row 9: footer ─────────────────────────────────────────────────────
    table.cell(statsTable, 0, 9,
         "[JOAT]",
         text_color  = color.new(#6C63FF, 0),
         text_size   = size.tiny,
         bgcolor     = color.new(#0d1117, 20),
         text_halign = text.align_left)
    table.cell(statsTable, 1, 9,
         "jackofalltrades",
         text_color  = cMut,
         text_size   = size.tiny,
         bgcolor     = color.new(#0d1117, 20),
         text_halign = text.align_right)

// ============================================================================
// ◈ ALERT CONDITIONS
// ============================================================================
alertcondition(crossAboveVwap,
     "MIDAS Fibonacci Cloud VWAP Cross Bull",
     "MIDAS Fibonacci Cloud: Bullish VWAP crossover — order flow confirmed.")

alertcondition(crossBelowVwap,
     "MIDAS Fibonacci Cloud VWAP Cross Bear",
     "MIDAS Fibonacci Cloud: Bearish VWAP crossunder — order flow confirmed.")

alertcondition(breakUpper6,
     "MIDAS Fibonacci Cloud 1.618 Upper Breach",
     "MIDAS Fibonacci Cloud: Price breached the 1.618 upper Fibonacci band.")

alertcondition(breakLower6,
     "MIDAS Fibonacci Cloud 1.618 Lower Breach",
     "MIDAS Fibonacci Cloud: Price breached the 1.618 lower Fibonacci band.")

alertcondition(absZ > 2.0 and orderFlow < 30.0,
     "MIDAS Fibonacci Cloud Extreme Reversion Zone",
     "MIDAS Fibonacci Cloud: Extreme Z-score with weak order flow — reversion zone.")

// ============================================================================
// END — MIDAS Fibonacci Cloud [JOAT]
// ============================================================================
````
