# Wedge Polaris [JOAT]

- url: https://www.tradingview.com/script/QwCkHqOr-Wedge-Polaris-JOAT/
- type: indicator
- pine_id: PUB;0cee716fb89642509e740ea06a068731
- version: 1.0

## Description

[b]Wedge Polaris [JOAT][/b]

Wedge Polaris is a multi-pattern auto-detector. It identifies five distinct converging-channel pattern families from zigzag pivots — Ascending Triangle, Descending Triangle, Symmetric Wedge, Rising Wedge, Falling Wedge — and on confirmed breakout projects a three-target ladder (Fibonacci times ATR times historical-duration blend). Pattern statistics, breakout probabilities, target hit / miss tracking, completed-pattern history, and a right-side bias gauge are all surfaced on the chart.

[image]https://www.tradingview.com/x/nVxC0KL7/[/image]

[b]What makes it different[/b]
[list]
[*] Most wedge / triangle indicators detect a single pattern type. This script classifies five families using slope analysis of the top and bottom channels.
[*] Collinearity tolerance is adaptive. It scales with ATR percentile so the script is strict in low-volatility regimes (clean pivots) and forgiving in high-volatility regimes (noisier pivots) without being retuned.
[*] Breakout probability is computed from the standard-normal CDF on the z-scored duration of the current pattern against a rolling history of completed patterns. Class-conditional bull / bear probabilities are blended with net-volume polarity inside the pattern.
[*] A strong-break filter requires the breakout candle's body Z-score to exceed three AND its 25th or 75th body percentile to be on the correct side of the boundary. This distinguishes decisive expansion from noise probes.
[*] A completed-pattern history strip tracks the last ten patterns with their outcomes (Target 1 hit, Stop hit, expired) so you can see the recent quality of the detector on the current instrument.
[/list]

[b]How it works[/b]
[list=1]
[*] Zigzag pivots are tracked via standard ta.pivothigh and ta.pivotlow with parallel arrays.
[*] Collinearity is tested between the two outer pivots and a middle pivot. Tolerance widens in high-volatility environments.
[*] Two collinear lines (one for highs, one for lows) form a channel. Convergence, alignment, and inside-the-channel tests confirm a valid pattern.
[*] Slope analysis classifies the pattern family.
[*] On breakout confirmation, target lines are projected. T1 equals entry plus or minus 0.5 times width. T2 equals entry plus or minus 1.0 times width. T3 equals entry plus or minus (1.618 times width plus atr-z times ATR). SL is symmetric at width times the user SL multiplier.
[*] Each completed pattern's duration and direction is appended to a 200-entry history buffer, which feeds the probability statistics.
[/list]

[b]Reading the chart[/b]
[list]
[*] Pattern channels: two lines plus a linefill between them. Line style differentiates pattern type (solid for triangles, dashed for wedges, dotted for channels).
[*] Completed-pattern ghost outlines fade for a user-configurable number of bars after the pattern ends.
[*] A pattern stats label at the channel midpoint reads, for example: WEDGE 23 bars P(bull) 64% P(break) 78% ATR x.xx.
[*] A three-target ladder on confirmed breakout: entry / SL / T1 / T2 / T3 horizontal lines plus price-only right-edge labels (no arrows, no shout text). Linefills shade the risk and reward zones.
[*] Volume confluence: if breakout-bar volume exceeds 1.5 times the 20-bar SMA, target labels append VOL+.
[*] A right-side bias gauge: 21-segment vertical band with a pointer.
[*] Optional right-side breakout-probability gauge (separate from bias gauge).
[*] A completed-pattern history strip above past pattern midpoints.
[*] A strong-break flash: bgcolor pulse on the strong-break bar.
[/list]

[b]Signals[/b]
[list]
[*] Pattern formed
[*] Bullish / bearish breakout
[*] Strong bullish / strong bearish breakout
[*] Target 1 / Target 2 / Target 3 hit
[*] Stop loss hit
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references.

[b]Inputs[/b]
[list]
[*] [b]Zigzag[/b]: zigzag length.
[*] [b]Collinearity[/b]: base tolerance (as a fraction of price).
[*] [b]Breakout[/b]: SL width multiplier, target line extension bars.
[*] [b]Visual[/b]: bullish / bearish colors, bias gauge, breakout probability gauge, pattern stats label, target ladder.
[*] [b]On-chart[/b]: completed-pattern history, ghost outlines extension bars, line-style differentiation.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Pattern plus volume[/b]: a confirmed breakout with the VOL+ tag and a high P(bull) reading is a higher-probability continuation entry.
[*] [b]Mean-reversion fades[/b]: when a wedge's third or later touch happens at the convergence apex with low P(break), the pattern often fails to break. Fade trades inside the channel are possible.
[*] [b]R-multiple management[/b]: once target 1 prints, common practice is to move stops to breakeven and let the remainder run for T2 / T3. The target ladder makes this straightforward.
[*] [b]Pattern history[/b]: the strip lets you assess whether the detector is performing well on the current instrument and timeframe before sizing up new signals.
[/list]

[b]Limitations[/b]
[list]
[*] Pivot detection inherits the right-bar delay of ta.pivothigh and ta.pivotlow. Patterns are confirmed only after the pivot-right-window passes.
[*] Collinearity tolerance is a heuristic. Extremely volatile or extremely clean charts may need tuning of the base tolerance.
[*] The class-conditional probability statistics need a minimum sample (five completed patterns) before they are meaningful.
[*] Pattern recognition is fundamentally interpretive. Even confirmed patterns fail.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator. Imports TradingView/ta/12 for ta.atr2 (series-period ATR used in duration-adaptive target projection). Any symbol, any timeframe. No request.security calls.

[b]Defaults[/b]
7-bar zigzag, 0.5 percent base collinearity tolerance, mint / red colors, top-right medium dashboard. For very fast charts shorten the zigzag length. For slow charts lengthen it and tighten the collinearity tolerance.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// ════════════════════════════════════════════════════════════════════
//   JOAT — Wedge Polaris [JOAT]
// ════════════════════════════════════════════════════════════════════

indicator("Wedge Polaris [JOAT]", "WPL [JOAT]",
     overlay              = true,
     explicit_plot_zorder = true,
     max_lines_count      = 500,
     max_labels_count     = 500,
     max_boxes_count      = 500,
     behind_chart         = false)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_zz     = "Zigzag"
g_col    = "Collinearity"
g_brk    = "Breakout"
g_vis    = "Visual"
g_dash   = "Dashboard"

zzLen        = input.int(7,      "Zigzag Length",                        minval=2,                         group=g_zz,
     tooltip="Pivot lookback for ta.pivothigh/pivotlow. Smaller values resolve shorter swings; larger values isolate dominant structure.")

baseTol      = input.float(0.005,"Base Collinearity Tolerance (fraction)",minval=0.001, maxval=0.05, step=0.001, group=g_col,
     tooltip="Strictness of three-pivot alignment as a fraction of price. The effective tolerance is scaled by ATR volatility Z so quiet regimes demand tighter alignment.")

flatThreshPct= input.float(0.05, "Flat-Slope Threshold (ATR/bar)",       minval=0.001, maxval=1.0, step=0.005, group=g_col,
     tooltip="Below this ATR-normalized slope magnitude, a wedge boundary is considered flat — used to classify ascending and descending triangles.")

slMultiplier = input.float(0.5,  "SL Width Multiplier",                  minval=0.1, step=0.1,             group=g_brk,
     tooltip="Stop loss distance as a multiple of the breakout-bar channel width.")

extendBars   = input.int(80,     "Target Lines Extend Bars",             minval=10,                        group=g_brk,
     tooltip="Number of bars the target ladder extends to the right of the current bar.")

strongBodyZ  = input.float(3.0,  "Strong Break Body Z Threshold",        minval=1.0, step=0.5,             group=g_brk,
     tooltip="Minimum body-length Z-score (over 20 bars) for a breakout to be flagged as strong.")

bullColor    = input.color(#00ffbb, "Bullish", inline="cBull",                                            group=g_vis,
     tooltip="Primary bullish color — JOAT brand mint.")
bearColor    = input.color(#ff1100, "Bearish", inline="cBull",                                            group=g_vis,
     tooltip="Primary bearish color — JOAT brand red.")
showGauge    = input.bool(true,  "Show Right-Edge Bias Gauge",                                            group=g_vis,
     tooltip="Toggle the 21-segment vertical bias gauge at the right edge.")
showStats    = input.bool(true,  "Show Pattern Stats Label",                                              group=g_vis,
     tooltip="Toggle the pattern stats text label drawn at the midpoint of the active channel.")
showTargets  = input.bool(true,  "Show Breakout Target Ladder",                                           group=g_vis,
     tooltip="Toggle the 3-target ladder (entry, SL, T1, T2, T3) drawn on confirmed breakout.")
showPulse    = input.bool(true,  "Show Pattern Pulse",                                                    group=g_vis,
     tooltip="Toggle the single-bar background pulse when a new pattern is detected.")
showFlash    = input.bool(true,  "Show Strong-Break Flash",                                               group=g_vis,
     tooltip="Toggle the 2-bar background flash on strong bullish or bearish breakouts.")

showHistory  = input.bool(true,  "Show Pattern History Strip",                                            group=g_vis,
     tooltip="Toggle the FIFO history strip of the last 10 completed patterns (with T-hit / SL-hit / expired tags).")
showBreakProbGauge = input.bool(true, "Show Breakout Probability Gauge",                                   group=g_vis,
     tooltip="Toggle the right-edge 21-segment vertical band that mirrors p(break).")
showGhost    = input.bool(true,  "Show Ghost (Faded) Completed Patterns",                                  group=g_vis,
     tooltip="Keep channel lines visible at low opacity after a pattern is broken or expires.")
historyExtendBars = input.int(30, "Ghost Extend Bars",                  minval=5, maxval=200,             group=g_vis,
     tooltip="How many extra bars to keep a completed pattern's ghost lines on chart before deletion.")
showMultiStrip = input.bool(true, "Show Right-Edge Multi-Pattern Strip",                                  group=g_vis,
     tooltip="Right-edge cluster summarising active pattern count, latest type/duration and majority P(bull).")
showRMult    = input.bool(true,  "Show R-Multiple Label",                                                 group=g_vis,
     tooltip="Display current MFE / MAE in R-multiples (R relative to risk) at the entry line right edge.")
showBrkCandle = input.bool(true, "Recolour Breakout Candle Body",                                         group=g_vis,
     tooltip="Recolour the breakout bar body with full saturation (strong break) or softer tint (regular break).")
showDash     = input.bool(true,  "Show Dashboard",                                                        group=g_dash,
     tooltip="Toggle the institutional dashboard panel.")
dashPos      = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize     = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

lineY(float x1, float y1, float x2, float y2, float x) =>
    y1 + (y2 - y1) * (x - x1) / math.max(x2 - x1, 1)

isCollinear(float ay, float ax, float my, float mx, float cy, float cx, float tol) =>
    float interp = ay + (cy - ay) * (mx - ax) / math.max(cx - ax, 1)
    float dev    = math.abs(my - interp) / math.max(math.abs(ay), syminfo.mintick)
    dev < tol

calcEndY(float p1y, float p1x, float p2y, float p2x, float p3y, float p3x) =>
    float mx = (p2x + p3x) / 2.0
    float my = (p2y + p3y) / 2.0
    p1y + (my - p1y) * (p3x - p1x) / math.max(mx - p1x, 1)

isAligned(float x1a, float x2a, float x1b, float x2b) =>
    float len_a   = x2a - x1a
    float len_b   = x2b - x1b
    float max_len = math.max(len_a, len_b)
    float min_len = math.min(len_a, len_b)
    float overlap = math.min(x2a, x2b) - math.max(x1a, x1b)
    max_len > 0 and overlap / max_len >= 0.5 and min_len / max_len >= 0.5

isConverging(float hx1, float hy1, float hx2, float hy2, float lx1, float ly1, float lx2, float ly2) =>
    float left_x  = math.min(hx1, lx1)
    float right_x = math.max(hx2, lx2)
    float h_left  = lineY(hx1, hy1, hx2, hy2, left_x)
    float l_left  = lineY(lx1, ly1, lx2, ly2, left_x)
    float h_right = lineY(hx1, hy1, hx2, hy2, right_x)
    float l_right = lineY(lx1, ly1, lx2, ly2, right_x)
    math.abs(h_right - l_right) < math.abs(h_left - l_left)

isInside(float ax1, float ay1, float ax2, float ay2, float bx1, float by1, float bx2, float by2, float price, float x) =>
    float a_proj = lineY(ax1, ay1, ax2, ay2, x)
    float b_proj = lineY(bx1, by1, bx2, by2, x)
    float left_x = math.min(ax1, bx1)
    float a_left = lineY(ax1, ay1, ax2, ay2, left_x)
    float b_left = lineY(bx1, by1, bx2, by2, left_x)
    float upper  = a_left > b_left ? a_proj : b_proj
    float lower  = a_left > b_left ? b_proj : a_proj
    upper > lower and price >= lower and price <= upper

sumSinceBar(float cumSeries, int startBar) =>
    int barsBack = bar_index - startBar
    barsBack < 0 ? na : cumSeries - nz(cumSeries[barsBack + 1], 0.0)

norm_cdf(float z) =>
    float t    = 1.0 / (1.0 + 0.2316419 * math.abs(z))
    float d_   = 0.3989423 * math.exp(-0.5 * z * z)
    float poly = t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))
    float p    = d_ * poly
    z >= 0 ? 1.0 - p : p

formatVolume(float v) =>
    na(v) ? "—" : math.abs(v) >= 1e9 ? str.tostring(v / 1e9, "0.00") + "B" : math.abs(v) >= 1e6 ? str.tostring(v / 1e6, "0.00") + "M" : math.abs(v) >= 1e3 ? str.tostring(v / 1e3, "0.00") + "K" : str.tostring(v, "0.0")

styleForPattern(string pT) =>
    pT == "ASCENDING TRI" or pT == "DESCENDING TRI"  ? line.style_solid  :
     pT == "CHANNEL"                                 ? line.style_dotted :
     line.style_dashed

classifyPattern(float hi_slope, float lo_slope, float flatThresh) =>
    string p = "CHANNEL"
    if math.abs(hi_slope) < flatThresh and lo_slope > 0
        p := "ASCENDING TRI"
    else if math.abs(lo_slope) < flatThresh and hi_slope < 0
        p := "DESCENDING TRI"
    else if hi_slope < 0 and lo_slope > 0
        p := "SYMMETRIC WEDGE"
    else if hi_slope > 0 and lo_slope > 0 and hi_slope < lo_slope
        p := "RISING WEDGE"
    else if hi_slope < 0 and lo_slope < 0 and hi_slope < lo_slope
        p := "FALLING WEDGE"
    p

// ════════════════════════════════════════════════════════════════════
// ADAPTIVE COLLINEARITY TOLERANCE
// ════════════════════════════════════════════════════════════════════
atr14      = ta.atr(14)
atrMean50  = ta.sma(atr14, 50)
atrStd50   = ta.stdev(atr14, 50)
atrZ       = (atr14 - atrMean50) / math.max(atrStd50, 1e-8)
atrZc      = math.max(-1.0, math.min(2.0, atrZ))
colTol     = baseTol * (1.0 + 0.5 * atrZc)
flatThresh = flatThreshPct * atr14 / math.max(close, syminfo.mintick)

confirmedBar = barstate.isconfirmed or barstate.ishistory

// ════════════════════════════════════════════════════════════════════
// ZIGZAG ENGINE
// ════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(zzLen, zzLen)
pl = ta.pivotlow (zzLen, zzLen)

var int lasttype = 0
var array<float> pivh   = array.new_float()
var array<float> pivl   = array.new_float()
var array<int>   pivh_i = array.new_int()
var array<int>   pivl_i = array.new_int()

if not na(ph)
    if lasttype != 1
        pivh.unshift(ph)
        pivh_i.unshift(bar_index - zzLen)
    else
        if ph > pivh.first()
            pivh.unshift(ph)
            pivh_i.unshift(bar_index - zzLen)
    lasttype := 1

if not na(pl)
    if lasttype != -1
        pivl.unshift(pl)
        pivl_i.unshift(bar_index - zzLen)
    else
        if pl < pivl.first()
            pivl.unshift(pl)
            pivl_i.unshift(bar_index - zzLen)
    lasttype := -1

while pivh.size() > 500
    pivh.pop()
    pivh_i.pop()
while pivl.size() > 500
    pivl.pop()
    pivl_i.pop()

var array<float> zzp = array.new_float()

if lasttype != lasttype[1] and pivh.size() > 3 and pivl.size() > 3
    if lasttype == 1
        zzp.unshift(pivl_i.first())
        zzp.unshift(pivl.first())
    else
        zzp.unshift(pivh_i.first())
        zzp.unshift(pivh.first())

while zzp.size() > 200
    zzp.pop()
    zzp.pop()

var float pot_val = na
var int   pot_idx = na

if lasttype != lasttype[1]
    pot_val := na
    pot_idx := na
if lasttype == 1
    if na(pot_val) or low <= pot_val
        pot_val := low
        pot_idx := bar_index
if lasttype == -1
    if na(pot_val) or high >= pot_val
        pot_val := high
        pot_idx := bar_index

// ════════════════════════════════════════════════════════════════════
// PATTERN STATE MACHINE
// ════════════════════════════════════════════════════════════════════
var bool  hi_pat = false
var float hi_x1 = na
var float hi_y1 = na
var float hi_x2 = na
var float hi_y2 = na
var int   hi_piv = 0

var bool  lo_pat = false
var float lo_x1 = na
var float lo_y1 = na
var float lo_x2 = na
var float lo_y2 = na
var int   lo_piv = 0

var int piv_cnt          = 0
var int last_draw_piv    = -10
var int last_draw_end_x  = -1

var array<line>     act_hi    = array.new_line()
var array<line>     act_lo    = array.new_line()
var array<linefill> act_fill  = array.new_linefill()
var array<int>      act_state = array.new_int()
var array<int>      act_start = array.new_int()
var array<string>   act_type  = array.new_string()
var array<int>      pat_out   = array.new_int()

var array<float> histDur  = array.new_float()
var array<int>   histBull = array.new_int()
int   histMax    = 200
int   histMinForZ = 5

var line  entry_line = na
var line  sl_line    = na
var line  t1_line    = na
var line  t2_line    = na
var line  t3_line    = na
var label entry_lab  = na
var label sl_lab     = na
var label t1_lab     = na
var label t2_lab     = na
var label t3_lab     = na
var linefill lf_loss = na
var linefill lf_rew  = na
var int   trade_dir  = 0
var bool  t1_hit_st  = false
var bool  t2_hit_st  = false
var bool  t3_hit_st  = false
var bool  sl_hit_st  = false
var bool  trade_open = false
var float t1_level   = na
var float t2_level   = na
var float t3_level   = na
var float sl_level   = na
var float entry_lvl  = na

var array<label> act_stats = array.new_label()

var array<line> gaugeLines      = array.new_line()
var label       gaugeLabel      = na
var array<line> breakGaugeLines = array.new_line()
var label       breakGaugeLabel = na

var array<label> patternHistory = array.new_label()

var array<label> targetHitLabels = array.new_label()
var array<label> slHitLabels     = array.new_label()

var label multiStripLab1 = na
var label multiStripLab2 = na
var label rMultLabel     = na

var array<line>     ghostHi     = array.new_line()
var array<line>     ghostLo     = array.new_line()
var array<linefill> ghostFill   = array.new_linefill()
var array<int>      ghostExpire = array.new_int()

var float brkCandleO = na
var float brkCandleH = na
var float brkCandleL = na
var float brkCandleC = na
var color brkCandleCol = na
brkCandleO := na
brkCandleH := na
brkCandleL := na
brkCandleC := na
brkCandleCol := na

var float tradeRisk = na
var float tradeMFE  = na
var float tradeMAE  = na

var bool  trade_volStrong = false

float volMA20 = ta.sma(volume, 20)

color patternNeutralLineColor = color.new(chart.fg_color, 50)
color patternNeutralFillColor = color.new(chart.fg_color, 90)

bool draw_bar = false

zzp1 = array.new_float()
zzp2 = array.new_float()

if zzp.size() > 16
    for i = 0 to zzp.size() - 1 by 4
        zzp1.push(zzp.get(i))
        zzp1.push(zzp.get(i + 1))
        if i + 3 <= zzp.size() - 1
            zzp2.push(zzp.get(i + 2))
            zzp2.push(zzp.get(i + 3))

    if lasttype != lasttype[1]
        piv_cnt += 1

        bool s1 = zzp1.size() >= 6 and isCollinear(zzp1.get(4), zzp1.get(5), zzp1.get(2), zzp1.get(3), zzp1.get(0), zzp1.get(1), colTol)

        float cur_y = lasttype == 1 ? pivh.first() : pivl.first()
        float cur_x = lasttype == 1 ? float(pivh_i.first()) : float(pivl_i.first())
        bool s2 = zzp2.size() >= 4 and isCollinear(zzp2.get(2), zzp2.get(3), zzp2.get(0), zzp2.get(1), cur_y, cur_x, colTol)

        if lasttype == 1
            if s1
                lo_pat := true
                lo_y1  := zzp1.get(4)
                lo_x1  := zzp1.get(5)
                lo_y2  := calcEndY(zzp1.get(4), zzp1.get(5), zzp1.get(2), zzp1.get(3), zzp1.get(0), zzp1.get(1))
                lo_x2  := zzp1.get(1)
                lo_piv := piv_cnt
            if s2
                hi_pat := true
                hi_y1  := zzp2.get(2)
                hi_x1  := zzp2.get(3)
                hi_y2  := calcEndY(zzp2.get(2), zzp2.get(3), zzp2.get(0), zzp2.get(1), cur_y, cur_x)
                hi_x2  := cur_x
                hi_piv := piv_cnt
        else
            if s1
                hi_pat := true
                hi_y1  := zzp1.get(4)
                hi_x1  := zzp1.get(5)
                hi_y2  := calcEndY(zzp1.get(4), zzp1.get(5), zzp1.get(2), zzp1.get(3), zzp1.get(0), zzp1.get(1))
                hi_x2  := zzp1.get(1)
                hi_piv := piv_cnt
            if s2
                lo_pat := true
                lo_y1  := zzp2.get(2)
                lo_x1  := zzp2.get(3)
                lo_y2  := calcEndY(zzp2.get(2), zzp2.get(3), zzp2.get(0), zzp2.get(1), cur_y, cur_x)
                lo_x2  := cur_x
                lo_piv := piv_cnt

        if hi_pat and lo_pat and math.abs(hi_piv - lo_piv) <= 1 and piv_cnt - last_draw_piv >= 2 and isAligned(hi_x1, hi_x2, lo_x1, lo_x2) and int(math.min(hi_x1, lo_x1)) > last_draw_end_x and isConverging(hi_x1, hi_y1, hi_x2, hi_y2, lo_x1, lo_y1, lo_x2, lo_y2) and isInside(hi_x1, hi_y1, hi_x2, hi_y2, lo_x1, lo_y1, lo_x2, lo_y2, close, float(bar_index))
            float hi_slope = (hi_y2 - hi_y1) / math.max(hi_x2 - hi_x1, 1)
            float lo_slope = (lo_y2 - lo_y1) / math.max(lo_x2 - lo_x1, 1)
            string patType = classifyPattern(hi_slope, lo_slope, flatThresh)

            string patStyleSel = styleForPattern(patType)
            line  hi_line = line.new(int(hi_x1), hi_y1, int(hi_x2), hi_y2, color = patternNeutralLineColor, width = 1, style = patStyleSel)
            line  lo_line = line.new(int(lo_x1), lo_y1, int(lo_x2), lo_y2, color = patternNeutralLineColor, width = 1, style = patStyleSel)
            linefill fill_obj = linefill.new(hi_line, lo_line, patternNeutralFillColor)

            act_hi.push(hi_line)
            act_lo.push(lo_line)
            act_fill.push(fill_obj)
            act_state.push(0)
            act_start.push(int(math.min(hi_x1, lo_x1)))
            act_type.push(patType)
            pat_out.push(0)

            label sl_obj = label.new(x = bar_index, y = close, text = "", color = na, textcolor = chart.fg_color, textalign = text.align_center, size = size.small, style = label.style_none)
            act_stats.push(sl_obj)

            draw_bar         := true
            hi_pat           := false
            lo_pat           := false
            last_draw_piv    := piv_cnt
            last_draw_end_x  := int(math.max(hi_x2, lo_x2))

        if hi_pat and piv_cnt - hi_piv > 1
            hi_pat := false
        if lo_pat and piv_cnt - lo_piv > 1
            lo_pat := false

// ════════════════════════════════════════════════════════════════════
// BREAKOUT DETECTION + TARGET PROJECTION
// ════════════════════════════════════════════════════════════════════
float body_top  = math.max(open, close)
float body_bot  = math.min(open, close)
float body_len  = body_top - body_bot
float body_25   = body_bot + 0.25 * body_len
float body_75   = body_bot + 0.75 * body_len
float body_mean = ta.sma(body_len, 20)
float body_std  = ta.stdev(body_len, 20)
float body_z    = body_std > 0 ? (body_len - body_mean) / body_std : 0.0

float upBarVol    = close > open ? volume : 0.0
float downBarVol  = close < open ? volume : 0.0
float cumUpVol    = ta.cum(upBarVol)
float cumDownVol  = ta.cum(downBarVol)
float cumTotalVol = ta.cum(volume)

bool patternFormed   = draw_bar and confirmedBar
bool bullBreakout    = false
bool bearBreakout    = false
bool strongBullBreak = false
bool strongBearBreak = false

if act_hi.size() > 0 and confirmedBar
    for i = act_hi.size() - 1 to 0
        line hi_l       = act_hi.get(i)
        line lo_l       = act_lo.get(i)
        linefill fill_l = act_fill.get(i)
        int state       = act_state.get(i)
        int startBar    = act_start.get(i)

        if state == 0
            float hx1 = float(line.get_x1(hi_l))
            float hy1 = line.get_y1(hi_l)
            float hx2 = float(line.get_x2(hi_l))
            float hy2 = line.get_y2(hi_l)
            float lx1 = float(line.get_x1(lo_l))
            float ly1 = line.get_y1(lo_l)
            float lx2 = float(line.get_x2(lo_l))
            float ly2 = line.get_y2(lo_l)

            float hi_proj = lineY(hx1, hy1, hx2, hy2, float(bar_index))
            float lo_proj = lineY(lx1, ly1, lx2, ly2, float(bar_index))
            float upper   = math.max(hi_proj, lo_proj)
            float lower   = math.min(hi_proj, lo_proj)

            bool inside    = close >= lower and close <= upper
            bool bullBreak = close > upper
            bool strong    = not inside and body_z >= strongBodyZ and (body_25 > upper or body_75 < lower)

            int   durBars = math.max(bar_index - startBar + 1, 1)
            float width   = math.max(upper - lower, syminfo.mintick)
            float atrNow  = atr14

            line.set_x2(hi_l, bar_index)
            line.set_y2(hi_l, hi_proj)
            line.set_x2(lo_l, bar_index)
            line.set_y2(lo_l, lo_proj)

            if inside
                pat_out.set(i, 0)
                line.set_color(hi_l, patternNeutralLineColor)
                line.set_color(lo_l, patternNeutralLineColor)
                linefill.set_color(fill_l, patternNeutralFillColor)
            else
                color brkLine = color.new(bullBreak ? bullColor : bearColor, 50)
                color brkFill = color.new(bullBreak ? bullColor : bearColor, 90)
                line.set_color(hi_l, brkLine)
                line.set_color(lo_l, brkLine)
                linefill.set_color(fill_l, brkFill)

                int cnt = pat_out.get(i) + 1
                pat_out.set(i, cnt)

                if strong or cnt >= 2
                    if bullBreak
                        bullBreakout := true
                        act_state.set(i, 1)
                        if strong
                            strongBullBreak := true
                    else
                        bearBreakout := true
                        act_state.set(i, -1)
                        if strong
                            strongBearBreak := true

                    array.unshift(histDur,  float(durBars))
                    array.unshift(histBull, bullBreak ? 1 : 0)
                    while array.size(histDur) > histMax
                        array.pop(histDur)
                        array.pop(histBull)

                    if showTargets
                        float histAvg   = array.size(histDur) > 0 ? array.avg(histDur) : float(durBars)
                        float dur_ratio = float(durBars) / math.max(histAvg, 1.0)
                        float dur_factor= math.max(0.5, math.min(2.0, dur_ratio))
                        float brkClose  = close
                        float w         = width
                        float atrComp   = math.abs(atrZc) * atrNow

                        float t1L = bullBreak ? brkClose + w * 0.5 * dur_factor : brkClose - w * 0.5 * dur_factor
                        float t2L = bullBreak ? brkClose + w * 1.0 * dur_factor : brkClose - w * 1.0 * dur_factor
                        float t3L = bullBreak ? brkClose + (w * 1.618 * dur_factor + atrComp) : brkClose - (w * 1.618 * dur_factor + atrComp)
                        float slL = bullBreak ? brkClose - w * slMultiplier : brkClose + w * slMultiplier

                        line.delete(entry_line)
                        line.delete(sl_line)
                        line.delete(t1_line)
                        line.delete(t2_line)
                        line.delete(t3_line)
                        label.delete(entry_lab)
                        label.delete(sl_lab)
                        label.delete(t1_lab)
                        label.delete(t2_lab)
                        label.delete(t3_lab)
                        linefill.delete(lf_loss)
                        linefill.delete(lf_rew)

                        color cBull = color.new(bullColor, 20)
                        color cBear = color.new(bearColor, 20)
                        color cMint = color.new(bullColor, 30)
                        color cRed  = color.new(bearColor, 30)

                        int rx = bar_index + extendBars
                        entry_line := line.new(bar_index, brkClose, rx, brkClose, color = bullBreak ? cBull : cBear, width = 3)
                        sl_line    := line.new(bar_index, slL,      rx, slL,      color = cRed, width = 2)
                        t1_line    := line.new(bar_index, t1L,      rx, t1L,      color = cMint, width = 2)
                        t2_line    := line.new(bar_index, t2L,      rx, t2L,      color = cMint, width = 2)
                        t3_line    := line.new(bar_index, t3L,      rx, t3L,      color = cMint, width = 3)

                        entry_lab := label.new(x = rx, y = brkClose, text = "ENTRY " + str.tostring(brkClose, format.mintick), style = label.style_label_left, color = na, textcolor = chart.fg_color, size = size.small)
                        sl_lab    := label.new(x = rx, y = slL,      text = "SL "    + str.tostring(slL,      format.mintick), style = label.style_label_left, color = na, textcolor = bearColor,     size = size.small)
                        t1_lab    := label.new(x = rx, y = t1L,      text = "T1 "    + str.tostring(t1L,      format.mintick), style = label.style_label_left, color = na, textcolor = bullColor,     size = size.small)
                        t2_lab    := label.new(x = rx, y = t2L,      text = "T2 "    + str.tostring(t2L,      format.mintick), style = label.style_label_left, color = na, textcolor = bullColor,     size = size.small)
                        t3_lab    := label.new(x = rx, y = t3L,      text = "T3 "    + str.tostring(t3L,      format.mintick), style = label.style_label_left, color = na, textcolor = bullColor,     size = size.small)

                        lf_loss := linefill.new(entry_line, sl_line, color.new(bearColor, 95))
                        lf_rew  := linefill.new(entry_line, t3_line, color.new(bullColor, 95))

                        trade_dir  := bullBreak ? 1 : -1
                        trade_open := true
                        t1_hit_st  := false
                        t2_hit_st  := false
                        t3_hit_st  := false
                        sl_hit_st  := false
                        entry_lvl  := brkClose
                        t1_level   := t1L
                        t2_level   := t2L
                        t3_level   := t3L
                        sl_level   := slL
                        tradeRisk  := math.abs(brkClose - slL)
                        tradeMFE   := 0.0
                        tradeMAE   := 0.0
                        trade_volStrong := not na(volMA20) and volMA20 > 0 and volume > 1.5 * volMA20

                    if showBrkCandle
                        color brkBase = bullBreak ? bullColor : bearColor
                        brkCandleCol := color.new(brkBase, (strong ? 0 : 30))
                        brkCandleO := open
                        brkCandleH := high
                        brkCandleL := low
                        brkCandleC := close

if act_hi.size() > 0 and confirmedBar
    for i = act_hi.size() - 1 to 0
        if act_state.get(i) == 0
            int sb0   = act_start.get(i)
            int age   = bar_index - sb0
            line hLx  = act_hi.get(i)
            int spanX = math.max(int(line.get_x2(hLx)) - int(line.get_x1(hLx)), 1)
            if age > spanX * 2
                act_state.set(i, 2)

if act_hi.size() > 0
    for i = act_hi.size() - 1 to 0
        int st0 = act_state.get(i)
        if st0 != 0
            line  hL0    = act_hi.get(i)
            line  lL0    = act_lo.get(i)
            string pT0   = act_type.get(i)
            int    sb0   = act_start.get(i)
            int    midBar0 = int(math.round((sb0 + bar_index) / 2.0))
            float  hiMid0  = lineY(float(line.get_x1(hL0)), line.get_y1(hL0), float(line.get_x2(hL0)), line.get_y2(hL0), float(midBar0))
            float  loMid0  = lineY(float(line.get_x1(lL0)), line.get_y1(lL0), float(line.get_x2(lL0)), line.get_y2(lL0), float(midBar0))
            float  topMid  = math.max(hiMid0, loMid0)
            float  histY   = topMid + nz(atr14, syminfo.mintick) * 1.5

            if showGhost
                color ghLine = color.new(chart.fg_color, 90)
                color ghFill = color.new(chart.fg_color, 95)
                string gSty = styleForPattern(pT0)
                line gH = line.new(int(line.get_x1(hL0)), line.get_y1(hL0), int(line.get_x2(hL0)), line.get_y2(hL0), color = ghLine, width = 1, style = gSty)
                line gL = line.new(int(line.get_x1(lL0)), line.get_y1(lL0), int(line.get_x2(lL0)), line.get_y2(lL0), color = ghLine, width = 1, style = gSty)
                linefill gF = linefill.new(gH, gL, ghFill)
                ghostHi.push(gH)
                ghostLo.push(gL)
                ghostFill.push(gF)
                ghostExpire.push(bar_index + historyExtendBars)

            if showHistory
                string tag    = st0 == 2 ? "expired" : (st0 == 1 ? "bull" : "bear")
                string hitStr = st0 == 2 ? "expired" : "open"
                color tagCol  = st0 == 2 ? color.new(chart.fg_color, 60) : color.new(chart.fg_color, 50)
                label histLab = label.new(x = midBar0, y = histY, text = pT0 + "  " + tag + "  " + hitStr, color = na, textcolor = tagCol, style = label.style_none, size = size.tiny, textalign = text.align_center)
                patternHistory.push(histLab)
                while patternHistory.size() > 10
                    label.delete(patternHistory.shift())

            label.delete(act_stats.get(i))
            line.delete(hL0)
            line.delete(lL0)
            linefill.delete(act_fill.get(i))
            act_hi.remove(i)
            act_lo.remove(i)
            act_fill.remove(i)
            act_state.remove(i)
            act_start.remove(i)
            act_type.remove(i)
            pat_out.remove(i)
            act_stats.remove(i)

if ghostHi.size() > 0
    for gi = ghostHi.size() - 1 to 0
        if bar_index >= ghostExpire.get(gi) or not showGhost
            line.delete(ghostHi.get(gi))
            line.delete(ghostLo.get(gi))
            linefill.delete(ghostFill.get(gi))
            ghostHi.remove(gi)
            ghostLo.remove(gi)
            ghostFill.remove(gi)
            ghostExpire.remove(gi)

// ════════════════════════════════════════════════════════════════════
// ACTIVE PATTERN STATS (latest only)
// ════════════════════════════════════════════════════════════════════
float patternUpVol     = na
float patternDownVol   = na
float patternNetVol    = na
float patternTotalVol  = na
float patternAtr       = na
int   patternBars      = na
float patternWidth     = na
float patternHi        = na
float patternLo        = na
float patternGaugeVal  = na
float gaugeTopBound    = na
float gaugeBottomBound = na
float probBreakDisp    = na
float probBullDisp     = na
string latestType      = "—"

if act_hi.size() > 0 and act_lo.size() > 0
    int li        = act_hi.size() - 1
    line hL       = act_hi.get(li)
    line lL       = act_lo.get(li)
    int startBar  = act_start.get(li)
    latestType    := act_type.get(li)
    patternBars   := math.max(bar_index - startBar + 1, 1)
    patternUpVol    := sumSinceBar(cumUpVol,    startBar)
    patternDownVol  := sumSinceBar(cumDownVol,  startBar)
    patternTotalVol := sumSinceBar(cumTotalVol, startBar)
    patternNetVol   := nz(patternUpVol) - nz(patternDownVol)
    patternAtr      := atr14
    patternHi       := math.max(line.get_y2(hL), line.get_y2(lL))
    patternLo       := math.min(line.get_y2(hL), line.get_y2(lL))
    patternWidth    := patternHi - patternLo
    float netRatio  = nz(patternTotalVol) > 0 ? patternNetVol / patternTotalVol : 0.0
    patternGaugeVal := math.max(math.min(100 * netRatio, 100), -100)
    gaugeTopBound   := patternHi
    gaugeBottomBound:= patternLo

    int hn = array.size(histDur)
    if hn >= histMinForZ
        float sumAll = 0.0
        for i = 0 to hn - 1
            sumAll += array.get(histDur, i)
        float meanAll = sumAll / hn
        float vAll    = 0.0
        for i = 0 to hn - 1
            float da = array.get(histDur, i) - meanAll
            vAll += da * da
        float stAll = hn > 1 ? math.sqrt(vAll / (hn - 1)) : 1.0
        float zBreak = stAll > 1e-6 ? (patternBars - meanAll) / stAll : 0.0
        probBreakDisp := math.max(0.01, math.min(0.99, norm_cdf(zBreak)))

    float pBull = 0.5
    if hn > 0
        float sumB = 0.0
        float sumS = 0.0
        int   cntB = 0
        int   cntS = 0
        for i = 0 to hn - 1
            if array.get(histBull, i) == 1
                sumB += array.get(histDur, i)
                cntB += 1
            else
                sumS += array.get(histDur, i)
                cntS += 1
        float meanB = cntB > 0 ? sumB / cntB : na
        float meanS = cntS > 0 ? sumS / cntS : na
        float vB    = 0.0
        float vS    = 0.0
        for i = 0 to hn - 1
            if array.get(histBull, i) == 1 and not na(meanB)
                float db = array.get(histDur, i) - meanB
                vB += db * db
            if array.get(histBull, i) == 0 and not na(meanS)
                float ds = array.get(histDur, i) - meanS
                vS += ds * ds
        float stB = cntB > 1 ? math.sqrt(vB / (cntB - 1)) : na
        float stS = cntS > 1 ? math.sqrt(vS / (cntS - 1)) : na

        if cntB >= 3 and cntS >= 3 and not na(stB) and not na(stS) and stB > 1e-6 and stS > 1e-6 and not na(meanB) and not na(meanS)
            float zBull = (patternBars - meanB) / stB
            float zBear = (patternBars - meanS) / stS
            float wBull = norm_cdf(zBull)
            float wBear = norm_cdf(zBear)
            float wSum  = wBull + wBear
            pBull := wSum > 0 ? wBull / wSum : 0.5
        else
            int bullTot = 0
            for i = 0 to hn - 1
                if array.get(histBull, i) == 1
                    bullTot += 1
            pBull := float(bullTot) / hn

        if nz(patternTotalVol) > 0
            float pNet = math.max(0.01, math.min(0.99, 0.5 + 0.5 * (nz(patternNetVol) / patternTotalVol)))
            pBull := 0.55 * pBull + 0.45 * pNet
        probBullDisp := math.max(0.01, math.min(0.99, pBull))
    else
        probBullDisp := nz(patternTotalVol) > 0 ? math.max(0.01, math.min(0.99, 0.5 + 0.5 * (nz(patternNetVol) / patternTotalVol))) : 0.5

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE — TARGET HIT DETECTION
// ════════════════════════════════════════════════════════════════════
bool t1Hit = false
bool t2Hit = false
bool t3Hit = false
bool slHit = false

if trade_open and confirmedBar
    if trade_dir == 1
        if not t1_hit_st and high >= t1_level and nz(high[1]) < t1_level
            t1Hit     := true
            t1_hit_st := true
        if not t2_hit_st and high >= t2_level and nz(high[1]) < t2_level
            t2Hit     := true
            t2_hit_st := true
        if not t3_hit_st and high >= t3_level and nz(high[1]) < t3_level
            t3Hit     := true
            t3_hit_st := true
        if not sl_hit_st and low <= sl_level and nz(low[1], sl_level + 1) > sl_level
            slHit     := true
            sl_hit_st := true
    else if trade_dir == -1
        if not t1_hit_st and low <= t1_level and nz(low[1], t1_level - 1) > t1_level
            t1Hit     := true
            t1_hit_st := true
        if not t2_hit_st and low <= t2_level and nz(low[1], t2_level - 1) > t2_level
            t2Hit     := true
            t2_hit_st := true
        if not t3_hit_st and low <= t3_level and nz(low[1], t3_level - 1) > t3_level
            t3Hit     := true
            t3_hit_st := true
        if not sl_hit_st and high >= sl_level and nz(high[1]) < sl_level
            slHit     := true
            sl_hit_st := true

    if not na(entry_line)
        int rx2 = bar_index + extendBars
        line.set_x2(entry_line, rx2)
        line.set_x2(sl_line,    rx2)
        line.set_x2(t1_line,    rx2)
        line.set_x2(t2_line,    rx2)
        line.set_x2(t3_line,    rx2)
        label.set_x(entry_lab,  rx2)
        label.set_x(sl_lab,     rx2)
        label.set_x(t1_lab,     rx2)
        label.set_x(t2_lab,     rx2)
        label.set_x(t3_lab,     rx2)

    float curMove = (close - entry_lvl) * (trade_dir == 1 ? 1.0 : -1.0)
    if not na(curMove)
        tradeMFE := math.max(nz(tradeMFE), curMove)
        tradeMAE := math.min(nz(tradeMAE), curMove)

    string volSfx = trade_volStrong ? "  VOL+" : ""
    color  winCol = trade_dir == 1 ? bullColor : bearColor
    if t1Hit
        label tLab = label.new(x = bar_index, y = t1_level, text = "T1 hit " + str.tostring(t1_level, format.mintick) + volSfx, color = na, textcolor = winCol, style = label.style_label_down, size = size.small)
        targetHitLabels.push(tLab)
    if t2Hit
        label tLab = label.new(x = bar_index, y = t2_level, text = "T2 hit " + str.tostring(t2_level, format.mintick) + volSfx, color = na, textcolor = winCol, style = label.style_label_down, size = size.small)
        targetHitLabels.push(tLab)
    if t3Hit
        label tLab = label.new(x = bar_index, y = t3_level, text = "T3 hit " + str.tostring(t3_level, format.mintick) + volSfx, color = na, textcolor = winCol, style = label.style_label_down, size = size.small)
        targetHitLabels.push(tLab)
    while targetHitLabels.size() > 15
        label.delete(targetHitLabels.shift())

    if slHit
        label sLab = label.new(x = bar_index, y = sl_level, text = "SL hit " + str.tostring(sl_level, format.mintick), color = na, textcolor = bearColor, style = label.style_label_up, size = size.small)
        slHitLabels.push(sLab)
        while slHitLabels.size() > 10
            label.delete(slHitLabels.shift())

    if showHistory and patternHistory.size() > 0 and (t1Hit or t2Hit or t3Hit or slHit)
        label lastH = patternHistory.last()
        string hitTag = t3Hit ? "T3 hit" : t2Hit ? "T2 hit" : t1Hit ? "T1 hit" : "SL hit"
        color  hitCol = slHit and not (t1Hit or t2Hit or t3Hit) ? color.new(bearColor, 30) : color.new(bullColor, 30)
        string baseTxt = label.get_text(lastH)
        string newTxt = str.contains(baseTxt, "  open") ? str.replace_all(baseTxt, "  open", "  " + hitTag) : baseTxt
        label.set_text(lastH, newTxt)
        label.set_textcolor(lastH, hitCol)

    if t3_hit_st or sl_hit_st
        trade_open := false

// ════════════════════════════════════════════════════════════════════
// VISUALS — PATTERN STATS LABEL
// ════════════════════════════════════════════════════════════════════
if showStats and act_stats.size() > 0 and act_hi.size() > 0
    for i = 0 to act_stats.size() - 1
        label statLab = act_stats.get(i)
        line  hL      = act_hi.get(i)
        line  lL      = act_lo.get(i)
        int   sb      = act_start.get(i)
        string pT     = act_type.get(i)
        int    dur    = math.max(bar_index - sb + 1, 1)
        int    midBar = int(math.round((sb + bar_index) / 2.0))
        float  midX   = float(midBar)
        float  hiMid  = lineY(float(line.get_x1(hL)), line.get_y1(hL), float(line.get_x2(hL)), line.get_y2(hL), midX)
        float  loMid  = lineY(float(line.get_x1(lL)), line.get_y1(lL), float(line.get_x2(lL)), line.get_y2(lL), midX)
        float  upMid  = math.max(hiMid, loMid)
        float  loMid2 = math.min(hiMid, loMid)
        float  midY   = (upMid + loMid2) / 2.0
        bool   isLast = i == act_stats.size() - 1
        string pbull  = isLast and not na(probBullDisp)  ? str.tostring(probBullDisp  * 100.0, "#.#") + "%" : "—"
        string pbrk   = isLast and not na(probBreakDisp) ? str.tostring(probBreakDisp * 100.0, "#.#") + "%" : "—"
        string atrStr = isLast and not na(patternAtr)    ? "  ATR " + str.tostring(patternAtr, format.mintick) : ""
        string txt    = pT + "  " + str.tostring(dur) + " bars  P(bull) " + pbull + "  P(brk) " + pbrk + atrStr
        label.set_xy(statLab, midBar, midY)
        label.set_text(statLab, txt)

// ════════════════════════════════════════════════════════════════════
// VISUALS — RIGHT-EDGE 21-SEGMENT BIAS GAUGE
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    if array.size(gaugeLines) > 0
        for ln in gaugeLines
            line.delete(ln)
        array.clear(gaugeLines)
    if not na(gaugeLabel)
        label.delete(gaugeLabel)
        gaugeLabel := na

    if showGauge and not na(gaugeTopBound) and not na(gaugeBottomBound) and gaugeTopBound != gaugeBottomBound and not na(probBullDisp)
        int segments = 21
        float segLen = (gaugeTopBound - gaugeBottomBound) / segments
        for i = 0 to segments - 1
            float y1 = gaugeTopBound - i * segLen
            float y2 = gaugeTopBound - (i + 1) * segLen
            color segCol = color.from_gradient(y1, gaugeBottomBound, gaugeTopBound, bearColor, bullColor)
            line ln = line.new(x1 = bar_index + 2, y1 = y1, x2 = bar_index + 2, y2 = y2, color = segCol, width = 4)
            array.unshift(gaugeLines, ln)

        float pPct       = probBullDisp * 100.0
        float pointerPos = gaugeBottomBound + (gaugeTopBound - gaugeBottomBound) * probBullDisp
        string netSign   = na(patternGaugeVal) ? "" : patternGaugeVal >= 0 ? "+" : ""
        string netStr    = na(patternGaugeVal) ? "" : "  NetVol " + netSign + str.tostring(patternGaugeVal, "#")
        string biasText  = pPct > 55.0 ? "BIAS bull " + str.tostring(pPct, "#.#") + "%" + netStr : pPct < 45.0 ? "BIAS bear " + str.tostring(100.0 - pPct, "#.#") + "%" + netStr : "P(bull) " + str.tostring(pPct, "#.#") + "%" + netStr
        gaugeLabel := label.new(x = bar_index + 4, y = pointerPos, text = biasText, color = na, textcolor = chart.fg_color, size = size.small, style = label.style_label_left)

// ════════════════════════════════════════════════════════════════════
// VISUALS — BREAKOUT CANDLE RECOLOUR (single-bar plotcandle overlay)
// ════════════════════════════════════════════════════════════════════
plotcandle(brkCandleO, brkCandleH, brkCandleL, brkCandleC,
     title       = "Breakout Bar Highlight",
     color       = brkCandleCol,
     wickcolor   = brkCandleCol,
     bordercolor = brkCandleCol,
     force_overlay = true)

// ════════════════════════════════════════════════════════════════════
// VISUALS — RIGHT-EDGE BREAKOUT-PROBABILITY GAUGE
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    if breakGaugeLines.size() > 0
        for bln in breakGaugeLines
            line.delete(bln)
        array.clear(breakGaugeLines)
    if not na(breakGaugeLabel)
        label.delete(breakGaugeLabel)
        breakGaugeLabel := na

    if showBreakProbGauge and not na(gaugeTopBound) and not na(gaugeBottomBound) and gaugeTopBound != gaugeBottomBound and not na(probBreakDisp)
        int bSegs   = 21
        float bSeg  = (gaugeTopBound - gaugeBottomBound) / bSegs
        color bCold = color.new(chart.fg_color, 60)
        color bHot  = color.new(#ffaa00, 30)
        for i = 0 to bSegs - 1
            float y1 = gaugeBottomBound + i * bSeg
            float y2 = gaugeBottomBound + (i + 1) * bSeg
            color segCol = color.from_gradient(y1, gaugeBottomBound, gaugeTopBound, bCold, bHot)
            line ln = line.new(x1 = bar_index + 6, y1 = y1, x2 = bar_index + 6, y2 = y2, color = segCol, width = 4)
            array.unshift(breakGaugeLines, ln)
        float bPct  = probBreakDisp * 100.0
        float bPtY  = gaugeBottomBound + (gaugeTopBound - gaugeBottomBound) * probBreakDisp
        breakGaugeLabel := label.new(x = bar_index + 8, y = bPtY, text = "p(break) " + str.tostring(bPct, "#.#") + "%", color = na, textcolor = chart.fg_color, size = size.small, style = label.style_label_left)

// ════════════════════════════════════════════════════════════════════
// VISUALS — RIGHT-EDGE MULTI-PATTERN STRIP
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    if not na(multiStripLab1)
        label.delete(multiStripLab1)
        multiStripLab1 := na
    if not na(multiStripLab2)
        label.delete(multiStripLab2)
        multiStripLab2 := na
    if showMultiStrip and act_hi.size() > 0
        int ac      = act_hi.size()
        int lastIdx = ac - 1
        string latT = act_type.get(lastIdx)
        int    latD = math.max(bar_index - act_start.get(lastIdx) + 1, 1)
        string pBs  = na(probBullDisp) ? "—" : str.tostring(probBullDisp * 100.0, "#") + "%"
        float  midPriceTop = math.max(line.get_y2(act_hi.get(lastIdx)), line.get_y2(act_lo.get(lastIdx)))
        float  midPriceBot = math.min(line.get_y2(act_hi.get(lastIdx)), line.get_y2(act_lo.get(lastIdx)))
        float  stripY1 = midPriceTop
        float  stripY2 = midPriceTop - (midPriceTop - midPriceBot) * 0.2
        color  tintCol = na(probBullDisp) ? color.new(chart.fg_color, 50) : (probBullDisp > 0.5 ? color.new(bullColor, 35) : color.new(bearColor, 35))
        multiStripLab1 := label.new(x = bar_index + 30, y = stripY1, text = "Patterns: " + str.tostring(ac) + " active", color = na, textcolor = tintCol, style = label.style_label_left, size = size.small)
        multiStripLab2 := label.new(x = bar_index + 30, y = stripY2, text = "Latest: " + latT + "  " + str.tostring(latD) + "bar  P(bull) " + pBs, color = na, textcolor = tintCol, style = label.style_label_left, size = size.small)

// ════════════════════════════════════════════════════════════════════
// VISUALS — R-MULTIPLE REACH LABEL
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    if not na(rMultLabel)
        label.delete(rMultLabel)
        rMultLabel := na
    if showRMult and trade_open and not na(entry_lvl) and not na(tradeRisk) and tradeRisk > 0
        float rMfe = nz(tradeMFE) / tradeRisk
        float rMae = nz(tradeMAE) / tradeRisk
        string mSign = rMfe >= 0 ? "+" : ""
        string aSign = rMae >= 0 ? "+" : ""
        string rTxt  = "R: " + mSign + str.tostring(rMfe, "0.0") + " / " + aSign + str.tostring(rMae, "0.0")
        color rCol   = trade_dir == 1 ? bullColor : bearColor
        rMultLabel := label.new(x = bar_index + extendBars + 4, y = entry_lvl, text = rTxt, color = na, textcolor = rCol, style = label.style_label_left, size = size.small)

// ════════════════════════════════════════════════════════════════════
// VISUALS — BGCOLOR PULSES
// ════════════════════════════════════════════════════════════════════
bgcolor(patternFormed and showPulse ? color.new(chart.fg_color, 90) : na, title="Pattern Detected")

var int flashCntBull = 0
var int flashCntBear = 0
if strongBullBreak
    flashCntBull := 2
else if flashCntBull > 0
    flashCntBull -= 1
if strongBearBreak
    flashCntBear := 2
else if flashCntBear > 0
    flashCntBear -= 1

bgcolor(showFlash and flashCntBull > 0 ? color.new(bullColor, 80) : na, title="Strong Bull Break Flash")
bgcolor(showFlash and flashCntBear > 0 ? color.new(bearColor, 80) : na, title="Strong Bear Break Flash")

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 12,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

f_lastBreakStr() =>
    int n = array.size(histBull)
    n > 0 ? (array.get(histBull, 0) == 1 ? "BULL" : "BEAR") : "—"

f_lastBreakBg() =>
    int n = array.size(histBull)
    n > 0 ? (array.get(histBull, 0) == 1 ? color.new(bullColor, 60) : color.new(bearColor, 60)) : color.new(chart.fg_color, 80)

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 12,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    table.clear(dash, 0, 0, 1, 11)
    txtSize = sizeFromString(dashSize)

    table.cell(dash, 0, 0, "Wedge Polaris [JOAT]", text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.cell(dash, 1, 0, "",                     text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize)
    table.merge_cells(dash, 0, 0, 1, 0)

    int activeCount = act_hi.size()
    table.cell(dash, 0, 1, "Active Patterns",        text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 1, str.tostring(activeCount),text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 2, "Latest Type", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 2, latestType,    text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    string durText = na(patternBars) ? "—" : str.tostring(patternBars) + " bars"
    table.cell(dash, 0, 3, "Duration", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 3, durText,    text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    string pbrkTxt = na(probBreakDisp) ? "—" : str.tostring(probBreakDisp * 100.0, "0.0") + "%"
    color pbrkBg   = na(probBreakDisp) ? color.new(chart.fg_color, 80) : color.new(probBreakDisp > 0.6 ? bullColor : probBreakDisp < 0.4 ? bearColor : chart.fg_color, 65)
    table.cell(dash, 0, 4, "P(break)", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 4, pbrkTxt,    text_color=color.white,    bgcolor=pbrkBg,  text_size=txtSize)

    string pbullTxt = na(probBullDisp) ? "—" : str.tostring(probBullDisp * 100.0, "0.0") + "%"
    color pbullBg   = na(probBullDisp) ? color.new(chart.fg_color, 80) : color.new(bullColor, math.round(85 - math.min(1.0, probBullDisp) * 70))
    table.cell(dash, 0, 5, "P(bull)", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 5, pbullTxt,  text_color=color.white,    bgcolor=pbullBg, text_size=txtSize)

    float pBearVal = na(probBullDisp) ? na : 1.0 - probBullDisp
    string pbearTxt = na(pBearVal) ? "—" : str.tostring(pBearVal * 100.0, "0.0") + "%"
    color pbearBg   = na(pBearVal) ? color.new(chart.fg_color, 80) : color.new(bearColor, math.round(85 - math.min(1.0, pBearVal) * 70))
    table.cell(dash, 0, 6, "P(bear)", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 6, pbearTxt,  text_color=color.white,    bgcolor=pbearBg, text_size=txtSize)

    string volTxt = na(patternTotalVol) ? "—" : formatVolume(patternTotalVol)
    table.cell(dash, 0, 7, "Pattern Vol", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 7, volTxt,        text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    float atrRef    = na(patternAtr) or patternAtr <= 0 ? atr14 : patternAtr
    float atrMult   = na(patternWidth) or na(atrRef) or atrRef <= 0 ? na : patternWidth / atrRef
    string atrWTxt  = na(atrMult) ? "—" : str.tostring(atrMult, "0.0") + "x ATR"
    table.cell(dash, 0, 8, "ATR Width", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 8, atrWTxt,     text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize)

    table.cell(dash, 0, 9, "Last Breakout", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 9, f_lastBreakStr(),text_color=color.white,    bgcolor=f_lastBreakBg(), text_size=txtSize)

    string entryTxt = (not trade_open or na(entry_lvl)) ? "—" : (trade_dir == 1 ? "L " : "S ") + str.tostring(entry_lvl, format.mintick) + " / " + str.tostring(sl_level, format.mintick)
    color  entryBg  = not trade_open ? color.new(chart.fg_color, 80) : color.new(trade_dir == 1 ? bullColor : bearColor, 65)
    table.cell(dash, 0, 10, "Entry / SL", text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize)
    table.cell(dash, 1, 10, entryTxt,     text_color=color.white,    bgcolor=entryBg, text_size=txtSize)

    table.cell(dash, 0, 11, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.cell(dash, 1, 11, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize)
    table.merge_cells(dash, 0, 11, 1, 11)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(patternFormed,    title="WPL Pattern Formed",    message="Wedge Polaris [JOAT] — Pattern formed")
alertcondition(bullBreakout,     title="WPL Bull Breakout",     message="Wedge Polaris [JOAT] — Bullish breakout")
alertcondition(bearBreakout,     title="WPL Bear Breakout",     message="Wedge Polaris [JOAT] — Bearish breakout")
alertcondition(strongBullBreak,  title="WPL Strong Bull Break", message="Wedge Polaris [JOAT] — Strong bullish breakout")
alertcondition(strongBearBreak,  title="WPL Strong Bear Break", message="Wedge Polaris [JOAT] — Strong bearish breakout")
alertcondition(t1Hit,            title="WPL Target 1 Hit",      message="Wedge Polaris [JOAT] — Target 1 reached")
alertcondition(t2Hit,            title="WPL Target 2 Hit",      message="Wedge Polaris [JOAT] — Target 2 reached")
alertcondition(t3Hit,            title="WPL Target 3 Hit",      message="Wedge Polaris [JOAT] — Target 3 reached")
alertcondition(slHit,            title="WPL Stop Loss Hit",     message="Wedge Polaris [JOAT] — Stop loss triggered")
````
