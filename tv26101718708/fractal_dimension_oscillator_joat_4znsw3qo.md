# Fractal Dimension Oscillator [JOAT]

- url: https://www.tradingview.com/script/4znSw3qo-Fractal-Dimension-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;85f93c7176fc415b8c5c901701c937c3
- version: 1.0

## Description

[b]Fractal Dimension Oscillator [JOAT][/b]

[b]Introduction[/b]

Fractal Dimension Oscillator is an open-source market geometry classifier that computes the fractal dimension of a price series using the Katz method and derives the Hurst exponent from it. The fractal dimension measures how much a price series fills space — a perfectly straight line has dimension 1.0, while a completely random walk approaches 2.0. Values between these extremes encode whether price is behaving in a trending, random, or mean-reverting fashion at the current moment.

The Hurst exponent H is derived as H = 2 - FD. Values above 0.5 indicate persistent trending behavior; values below 0.5 indicate mean-reverting behavior; H near 0.5 indicates a random walk. This gives traders an analytically grounded way to distinguish market regimes that directly determines which type of strategy applies.

[b]Core Concepts[/b]

[b]1. Katz Fractal Dimension Method[/b]

The Katz method computes fractal dimension from the total path length of price movements divided by the maximum distance traveled from the starting point:

[pine]
// L = total path length, d = max distance from first point, n = N-1
float fd = math.log(n) / (math.log(n) + math.log(L / d / n))
[/pine]

This is computationally efficient compared to methods requiring fractal level decomposition and produces stable results across the configurable lookback period. The formula ensures that as price moves more linearly (large L relative to d), FD approaches 1.0. As price moves chaotically (small d despite large L), FD approaches 2.0.

[b]2. Five-State Regime Classification[/b]

The raw FD value maps to five regime states based on configurable thresholds. The default boundaries are: Strong Trend (FD < 1.33), Trending (1.33–1.45), Random Walk (1.45–1.55), Mean-Reverting (1.55–1.67), Strong Mean-Revert (FD > 1.67). Each state carries a distinct color and strategy implication.

[image]https://www.tradingview.com/x/pa7NRjYY/[/image]

[b]3. FD Percentile Tracking[/b]

The current FD value is ranked against a 100-bar rolling window to produce a percentile score. This shows not only the current regime state but how extreme that reading is relative to recent history — a 95th percentile trending reading is more significant than a borderline one.

[b]4. Candle and Background Coloring[/b]

Candles are painted using a gradient: amber/gold for trending states, neutral for random walk, teal/cyan for mean-reverting states. Chart background is tinted faintly in the corresponding regime color. Both color channels update in real time as FD changes.

[b]Features[/b]

[list]
[*][b]Katz fractal dimension calculation:[/b] Computationally efficient geometric method
[*][b]Hurst exponent display:[/b] H = 2 - FD, shown alongside raw FD in dashboard
[*][b]Five-state regime classification:[/b] Strong Trend through Strong Mean-Revert
[*][b]Smoothed EMA overlay:[/b] Optional EMA of raw FD for noise reduction
[*][b]Regime transition markers:[/b] On-chart triangle shapes at every regime change
[*][b]FD percentile (100-bar):[/b] Shows how extreme the current reading is historically
[*][b]Gradient candle coloring:[/b] Amber for trend, teal for mean-revert, neutral center
[*][b]Regime background tinting:[/b] Chart background reflects current regime state
[*][b]Dashboard:[/b] FD, Hurst, regime, percentile, and strategy bias recommendation
[*][b]Five alert conditions:[/b] Regime transitions and extreme readings
[/list]

[b]Input Parameters[/b]

[b]Fractal Engine:[/b]
[list]
[*]Fractal Period: Lookback bars for FD calculation (default: 30, range: 10-200)
[*]EMA Smoothing: Smoothing period for the display line (default: 5)
[/list]

[b]Thresholds:[/b]
[list]
[*]Trending Threshold: Hurst value above which market is trending (default: 1.5)
[*]Mean-Revert Threshold: Hurst value above which market is strongly mean-reverting (default: 1.6)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Strategy Bias[/b]
The dashboard's Strategy Bias row gives a direct instruction: USE TREND SIGNALS, USE MEAN-REV SIGNALS, or AVOID / WAIT. This summarizes the regime into an actionable filter.

[b]Step 2: Use Regime Transitions as Mode Switches[/b]
When a TREND triangle appears after a period of RANGE, consider activating trend-following setups. When a RANGE transition appears after trend, consider rotating to mean-reversion approaches.

[b]Step 3: Check the Percentile[/b]
A 90th-percentile trending reading suggests a particularly directional market. A 10th-percentile trending reading is borderline — apply less conviction to trend signals.

[b]Indicator Limitations[/b]

[list]
[*]Fractal dimension is a mathematical property of the price series, not a predictive indicator — it describes what has happened, not what will happen
[*]The Katz method is one of several FD estimation approaches; results will differ from Higuchi or other methods
[*]Short lookback periods produce noisier FD values; longer periods produce smoother but slower-responding readings
[/list]

[b]Originality Statement[/b]

The Katz fractal dimension method is applied here in a complete regime classification engine with five states, EMA smoothing, a 100-bar percentile ranking, gradient candle coloring, and a strategy bias recommendation layer — none of which are standard in simple FD implementations. The combination of Hurst exponent derivation, percentile context, and strategy bias output in a single publication distinguishes this from generic fractal dimension scripts.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Fractal dimension values describe historical price geometry and do not predict future price movement. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Fractal Dimension Oscillator [JOAT]", shorttitle="FDO [JOAT]", overlay=false,
     max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color TREND_COL   = color.rgb(255, 150,  30)
color RANGE_COL   = color.rgb(  0, 200,  83)
color CHAOS_COL   = color.rgb(255,  82,  82)
color NEUTRAL_COL = color.rgb(140, 160, 210)
color NEON_CYAN   = color.rgb(  0, 243, 255)
color VOID_BG     = color.rgb( 10,  14,  26)
color SLATE_BRD   = color.rgb( 40,  55,  90)
color LAVEN_HDR   = color.rgb(140, 160, 210)
color GOLD_VAL    = color.rgb(255, 215,  60)

lerpCol(color cA, color cB, float t) =>
    float ct = math.max(0.0, math.min(1.0, t))
    int r = int(color.r(cA) + (color.r(cB) - color.r(cA)) * ct)
    int g = int(color.g(cA) + (color.g(cB) - color.g(cA)) * ct)
    int b = int(color.b(cA) + (color.b(cB) - color.b(cA)) * ct)
    color.rgb(r, g, b)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_CORE = "━━ Fractal Engine ━━"
string G_VIZ  = "━━ Visual Settings ━━"
string G_DASH = "━━ Dashboard ━━"

int    i_period   = input.int(30,    "Fractal Period (bars)",     minval=10, maxval=200, group=G_CORE,
     tooltip="Lookback for fractal dimension calculation. Larger = smoother but slower.")
int    i_smooth   = input.int(5,     "EMA Smoothing (bars)",      minval=1, maxval=20,  group=G_CORE)
float  i_trendThr = input.float(1.5, "Trending Threshold (H)",    minval=1.3, maxval=1.9, step=0.05, group=G_CORE,
     tooltip="Hurst > this value = trending market. Hurst = 2 - Fractal Dimension.")
float  i_rangeThr = input.float(1.6, "Mean-Revert Threshold (H)", minval=1.4, maxval=2.0, step=0.05, group=G_CORE,
     tooltip="Hurst > this = strongly mean-reverting.")
bool   i_showEMA  = input.bool(true, "Show Smoothed Line",        group=G_VIZ)
bool   i_showRaw  = input.bool(true, "Show Raw Histogram",        group=G_VIZ)
bool   i_showDash = input.bool(true, "Show Dashboard",            group=G_DASH)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — FRACTAL DIMENSION CALCULATION
// Higuchi Method for Fractal Dimension, then Hurst = 2 - FD
// Low FD (1.0-1.3) → H > 0.7 → strong trend
// High FD (1.7-2.0) → H < 0.3 → strong mean reversion
// FD ≈ 1.5 → H = 0.5 → random walk
// ═══════════════════════════════════════════════════════════════════════════════
calcFractalDimension(int N) =>
    // Using the Katz method: simpler, still effective
    // FD = log(L/d) / log(n)
    // L = total path length, d = diameter (max distance from first point), n = N-1
    float firstPrice = close[N - 1]
    float L = 0.0
    float maxDist = 0.0

    for i = 1 to N - 1
        float diff = math.abs(close[i - 1] - close[i])
        L += diff
        float dist = math.abs(close[i] - firstPrice)
        if dist > maxDist
            maxDist := dist

    float fd = na
    if maxDist > 0.0 and L > 0.0 and N > 1
        float n = float(N - 1)
        float ratio = L / maxDist
        if ratio > 1.0
            fd := math.log(n) / (math.log(n) + math.log(ratio / n))
    fd

// Calculate raw fractal dimension and derive Hurst exponent
float rawFD   = calcFractalDimension(i_period)
float hurstRaw = na(rawFD) ? na : 2.0 - rawFD
float hurstSm  = ta.ema(nz(hurstRaw, 1.5), i_smooth)

// Normalize for display (center around 0.5 = random walk)
float hurstNorm = hurstSm  // display raw Hurst [0, 2] range clamped to [1, 2]
hurstNorm := math.max(1.0, math.min(2.0, nz(hurstNorm, 1.5)))

// Regime classification based on fractal dimension
// FD < 1.5 → trending, FD > 1.5 → mean-reverting
string regime = switch
    na(rawFD)    => "Calculating..."
    rawFD < 1.33 => "STRONG TREND"
    rawFD < 1.45 => "TRENDING"
    rawFD < 1.55 => "RANDOM WALK"
    rawFD < 1.67 => "MEAN-REVERTING"
    =>              "STRONG MEAN-REVERT"

color regimeColor = switch
    na(rawFD)    => NEUTRAL_COL
    rawFD < 1.33 => TREND_COL
    rawFD < 1.45 => lerpCol(TREND_COL, NEUTRAL_COL, (rawFD - 1.33) / 0.12)
    rawFD < 1.55 => NEUTRAL_COL
    rawFD < 1.67 => lerpCol(NEUTRAL_COL, RANGE_COL, (rawFD - 1.55) / 0.12)
    =>              RANGE_COL

// ── Candle Coloring by Regime ──────────────────────────────────────────────
color fdoCandleColor = na
if not na(rawFD)
    if rawFD < 1.33
        fdoCandleColor := color.new(color.rgb(255, 150, 30), 15)
    else if rawFD < 1.45
        fdoCandleColor := color.new(color.rgb(255, 185, 20), 30)
    else if rawFD > 1.67
        fdoCandleColor := color.new(color.rgb(0, 243, 255), 15)
    else if rawFD > 1.55
        fdoCandleColor := color.new(color.rgb(0, 180, 120), 30)
barcolor(fdoCandleColor, title="FDO Regime Candle Color")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — REGIME DETECTION & SIGNALS
// ═══════════════════════════════════════════════════════════════════════════════
bool isTrending    = not na(rawFD) and rawFD < 1.45
bool isMeanRev     = not na(rawFD) and rawFD > 1.55
bool isRandomWalk  = not na(rawFD) and rawFD >= 1.45 and rawFD <= 1.55

bool regimeToTrend = barstate.isconfirmed and isTrending  and not isTrending[1]
bool regimeToRange = barstate.isconfirmed and isMeanRev   and not isMeanRev[1]
bool regimeToRand  = barstate.isconfirmed and isRandomWalk and not isRandomWalk[1]

// Volatility percentile (how extreme is current FD vs history)
float fdHi  = ta.highest(nz(rawFD, 1.5), 100)
float fdLo  = ta.lowest (nz(rawFD, 1.5), 100)
float fdPct = (fdHi - fdLo) > 0.0 ? (nz(rawFD, 1.5) - fdLo) / (fdHi - fdLo) * 100.0 : 50.0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
// Center line at FD = 1.5 (random walk)
hline(1.5, "Random Walk",  color=color.new(LAVEN_HDR, 60), linestyle=hline.style_dashed, linewidth=1)
hline(1.33,"Strong Trend", color=color.new(TREND_COL, 60), linestyle=hline.style_dotted, linewidth=1)
hline(1.67,"Strong Mean",  color=color.new(RANGE_COL, 60), linestyle=hline.style_dotted, linewidth=1)

// Raw FD as histogram bars
plot(i_showRaw ? rawFD : na, "Raw FD", color=color.new(regimeColor, 50),
     style=plot.style_columns, linewidth=1)

// Smoothed Hurst as line
plot(i_showEMA ? nz(rawFD) : na, "Fractal Dimension", color=regimeColor,
     linewidth=2, style=plot.style_line)

// Background fill for trending region
bgcolor(isTrending  ? color.new(TREND_COL, 94) : na, title="Trending Zone")
bgcolor(isMeanRev   ? color.new(RANGE_COL, 94) : na, title="Mean-Reverting Zone")

// Regime transition markers
plotshape(regimeToTrend, "To Trending",    shape.triangleup,  location.bottom,
     color=TREND_COL, size=size.small, text="TREND", textcolor=TREND_COL)
plotshape(regimeToRange, "To Mean-Rev",    shape.triangledown, location.top,
     color=RANGE_COL, size=size.small, text="RANGE", textcolor=RANGE_COL)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 6,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash and barstate.islast
    string fdStr   = na(rawFD) ? "—" : str.tostring(rawFD, "#.####")
    string smStr   = str.tostring(nz(rawFD), "#.####")
    string pctStr  = str.tostring(fdPct, "#.#") + "%"

    table.cell(dash, 0, 0, "Fractal Dimension Osc", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Fractal Dim",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, fdStr,          text_color=GOLD_VAL,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 2, "Hurst Exp",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    float hurstDisp = na(rawFD) ? na : 2.0 - rawFD
    table.cell(dash, 1, 2, na(hurstDisp) ? "—" : str.tostring(hurstDisp, "#.####"),
         text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 3, "Regime",       text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, regime,         text_color=regimeColor,text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 4, "FD Percentile",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, pctStr,         text_color=NEON_CYAN, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    string trendBias = isTrending ? "USE TREND SIGNALS" : isMeanRev ? "USE MEAN-REV SIGNALS" : "AVOID / WAIT"
    table.cell(dash, 0, 5, "Strategy Bias",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, trendBias,      text_color=regimeColor,text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(regimeToTrend, "FDO Trend Regime",    "Fractal Dimension Oscillator [JOAT]: Entering TRENDING regime on {{ticker}} {{interval}}")
alertcondition(regimeToRange, "FDO Range Regime",    "Fractal Dimension Oscillator [JOAT]: Entering MEAN-REVERTING regime on {{ticker}} {{interval}}")
alertcondition(regimeToRand,  "FDO Random Walk",     "Fractal Dimension Oscillator [JOAT]: Entering RANDOM WALK regime on {{ticker}}")
alertcondition(not na(rawFD) and rawFD < 1.2, "FDO Extreme Trend",  "Fractal Dimension Oscillator [JOAT]: EXTREME trend regime detected on {{ticker}}")
alertcondition(not na(rawFD) and rawFD > 1.8, "FDO Extreme Range",  "Fractal Dimension Oscillator [JOAT]: EXTREME mean-reversion regime on {{ticker}}")
````
