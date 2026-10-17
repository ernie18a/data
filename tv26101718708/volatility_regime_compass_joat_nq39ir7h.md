# Volatility Regime Compass [JOAT]

- url: https://www.tradingview.com/script/NQ39Ir7h-Volatility-Regime-Compass-JOAT/
- type: indicator
- pine_id: PUB;538b5e05500b4d35ad788c5e50771077
- version: 1.0

## Description

[b]Volatility Regime Compass [JOAT][/b]

[b]Introduction[/b]

Volatility Regime Compass is an open-source volatility state classifier that continuously measures where current ATR stands relative to its own historical distribution and maps it to one of four named regimes: Compressed, Normal, Elevated, and Extreme. The classification is not binary (high or low) — it uses a rolling percentile ranking against configurable lookback windows so the regime reflects where current volatility stands within its recent history, not against a fixed absolute threshold that becomes stale as market conditions evolve.

The practical value is in strategy switching: mean-reversion techniques tend to work in compressed regimes, breakout and momentum techniques in elevated ones. Knowing which regime is active before selecting a technique reduces category errors that produce losses.

[b]Core Concepts[/b]

[b]1. ATR Percentile Ranking[/b]

Rather than comparing ATR to a static multiplier, the indicator ranks the current ATR value within a rolling distribution of historical ATR values. This produces a percentile score from 0 to 100 that is self-normalizing across different instruments and timeframes:

[pine]
float atrHi  = ta.highest(atrVal, i_rankLen)
float atrLo  = ta.lowest (atrVal, i_rankLen)
float atrPct = (atrHi - atrLo) > 0 ?
     (atrVal - atrLo) / (atrHi - atrLo) * 100.0 : 50.0
[/pine]

A reading of 80 means current ATR is in the 80th percentile of its recent range — clearly elevated. A reading of 15 means ATR is near multi-period lows — compressed.

[b]2. Four-State Regime Classification[/b]

The percentile score maps to four regimes with configurable boundary thresholds. Defaults are: Compressed (below 25th percentile), Normal (25th to 60th), Elevated (60th to 85th), Extreme (above 85th). Crossing a regime boundary triggers a transition event labeled on the chart.

[image]https://www.tradingview.com/x/mIcFj3nL/[/image]

[b]3. Multi-Band Visualization[/b]

Five ATR bands project above and below close at configurable multiples (0.5×, 1×, 1.5×, 2×, 2.5× ATR). Each band is color-coded by regime — tighter bands in compressed regimes shade cooler, wider bands in extreme regimes shade hotter using a 5-stop gradient. This gives instant visual calibration of price's relationship to current volatility structure.

[b]4. Volatility Trend[/b]

The rate of change of ATR is computed and smoothed. Positive volatility trend (ATR rising) is labeled differently from negative trend (ATR contracting). This distinguishes a currently-elevated but contracting regime from one that is expanding — the former is more likely to produce consolidation, the latter continuation.

[b]Features[/b]

[list]
[*][b]ATR percentile ranking:[/b] Self-normalizing volatility score relative to recent history
[*][b]Four volatility regimes:[/b] Compressed, Normal, Elevated, Extreme with configurable boundaries
[*][b]Regime transition labels:[/b] On-chart labels at every regime change event
[*][b]Five ATR expansion bands:[/b] Projected above and below close, gradient-colored by regime
[*][b]Volatility trend direction:[/b] Rising vs contracting ATR tracked independently of level
[*][b]Candle coloring:[/b] Candles reflect current volatility regime in real time
[*][b]Regime background shading:[/b] Chart background tint corresponds to current regime
[*][b]Dashboard:[/b] Current ATR, percentile, regime, trend direction, and band levels
[/list]

[b]Input Parameters[/b]

[b]ATR Settings:[/b]
[list]
[*]ATR Period: ATR calculation length (default: 14)
[*]Percentile Lookback: Rolling window for ATR percentile ranking (default: 100)
[/list]

[b]Regime Thresholds:[/b]
[list]
[*]Compressed Below: Percentile below which regime is Compressed (default: 25)
[*]Elevated Above: Percentile above which regime is Elevated (default: 60)
[*]Extreme Above: Percentile above which regime is Extreme (default: 85)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Check the Current Regime[/b]
Read the REGIME row in the dashboard. This tells you whether to expect range-bound or trending behavior in the near term.

[b]Step 2: Watch for Regime Transitions[/b]
A transition from Compressed to Elevated is the setup for breakout strategies. A transition from Extreme back toward Normal may signal trend exhaustion.

[b]Step 3: Use Bands as Structural Reference[/b]
The ATR bands define statistically reasonable price excursion limits for the current volatility state. Closes beyond the 2× or 2.5× band while in a Compressed regime are structurally significant events.

[b]Step 4: Combine with Directional Indicators[/b]
This indicator classifies volatility magnitude, not direction. Pair it with a trend or momentum tool to apply regime context to directional decisions.

[b]Indicator Limitations[/b]

[list]
[*]Percentile ranking depends on lookback length; very short lookbacks can produce unstable regime classifications during sudden volatility spikes
[*]The four-state classification is a simplification; volatility is continuous and regime boundaries are heuristic
[*]Volatility expansion does not indicate direction — it only measures magnitude of movement
[/list]

[b]Originality Statement[/b]

The combination of a self-normalizing ATR percentile ranking, a four-state regime classifier with configurable percentile boundaries, gradient-coded multi-band projection, and a simultaneous volatility trend tracker in a single Pine Script v6 publication constitutes the original contribution. Standard ATR indicators display the raw value or a fixed-multiple band without regime classification or percentile normalization.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Volatility regime classifications are statistical summaries of historical data and do not predict future price movement. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volatility Regime Compass [JOAT]", shorttitle="VRC [JOAT]", overlay=false,
     max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color COMPRESS_COL = color.rgb( 50, 120, 255)
color NORMAL_COL   = color.rgb(140, 160, 210)
color EXPAND_COL   = color.rgb(255, 150,  30)
color SPIKE_COL    = color.rgb(255,  40,  60)
color VOID_BG      = color.rgb( 10,  14,  26)
color SLATE_BRD    = color.rgb( 40,  55,  90)
color LAVEN_HDR    = color.rgb(140, 160, 210)
color GOLD_VAL     = color.rgb(255, 215,  60)
color NEON_CYAN    = color.rgb(  0, 243, 255)

lerpCol(color cA, color cB, float t) =>
    float ct = math.max(0.0, math.min(1.0, t))
    int r = int(color.r(cA) + (color.r(cB) - color.r(cA)) * ct)
    int g = int(color.g(cA) + (color.g(cB) - color.g(cA)) * ct)
    int b = int(color.b(cA) + (color.b(cB) - color.b(cA)) * ct)
    color.rgb(r, g, b)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_CORE = "━━ Volatility Engine ━━"
string G_REG  = "━━ Regime Thresholds ━━"
string G_VIZ  = "━━ Visual ━━"
string G_DASH = "━━ Dashboard ━━"

int    i_atrLen   = input.int(14,   "ATR Length",                   minval=1, group=G_CORE)
int    i_atrMA    = input.int(50,   "ATR MA Length (baseline)",     minval=10, group=G_CORE)
int    i_hvLen    = input.int(20,   "Historical Vol Length (bars)", minval=5, group=G_CORE,
     tooltip="Historical volatility = annualized stdev of log returns over this period.")
int    i_hvMA     = input.int(100,  "HV Baseline Length",           minval=20, group=G_CORE)
int    i_bbLen    = input.int(20,   "Bollinger Band Length",        minval=5, group=G_CORE)
float  i_bbMult   = input.float(2.0,"BB Multiplier",               minval=0.5, step=0.1, group=G_CORE)
int    i_smooth   = input.int(3,    "Composite Smoothing",          minval=1, group=G_CORE)

float  i_compThr  = input.float(0.65,"Compression Threshold (ratio)", minval=0.3, maxval=0.9, step=0.05, group=G_REG,
     tooltip="ATR ratio below this = compression regime.")
float  i_expThr   = input.float(1.35,"Expansion Threshold (ratio)",   minval=1.0, maxval=2.0, step=0.05, group=G_REG,
     tooltip="ATR ratio above this = expansion regime.")
float  i_spikeThr = input.float(2.0, "Spike Threshold (ratio)",       minval=1.5, maxval=4.0, step=0.1, group=G_REG,
     tooltip="ATR ratio above this = volatility spike.")

bool   i_showHV   = input.bool(true, "Show Historical Vol Line",  group=G_VIZ)
bool   i_showBB   = input.bool(true, "Show BB Width Line",         group=G_VIZ)
bool   i_showDash = input.bool(true, "Show Dashboard",             group=G_DASH)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — MULTI-MODEL VOLATILITY
// ═══════════════════════════════════════════════════════════════════════════════
// Model 1: ATR Ratio (current ATR vs baseline)
float atrVal     = ta.atr(i_atrLen)
float atrBaseline= ta.sma(atrVal, i_atrMA)
float atrRatio   = atrBaseline > 0.0 ? atrVal / atrBaseline : 1.0

// Model 2: Historical Volatility (annualized, %)
float logRet     = math.log(close / nz(close[1], close))
float hvRaw      = ta.stdev(logRet, i_hvLen) * math.sqrt(252.0) * 100.0
float hvBaseline = ta.sma(hvRaw, i_hvMA)
float hvRatio    = hvBaseline > 0.0 ? hvRaw / hvBaseline : 1.0
float hvZ        = ta.stdev(hvRaw, i_hvMA) > 0.0 ?
     (hvRaw - hvBaseline) / ta.stdev(hvRaw, i_hvMA) : 0.0

// Model 3: Bollinger Band Width
float bbBasis    = ta.sma(close, i_bbLen)
float bbDev      = ta.stdev(close, i_bbLen)
float bbW        = bbBasis > 0.0 ? (bbDev * i_bbMult * 2.0) / bbBasis * 100.0 : 0.0
float bbWBaseline= ta.sma(bbW, i_hvMA)
float bbWRatio   = bbWBaseline > 0.0 ? bbW / bbWBaseline : 1.0

// Composite volatility ratio (equally weighted)
float compositeRatio = (atrRatio + hvRatio + bbWRatio) / 3.0
float smoothed       = ta.ema(compositeRatio, i_smooth)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — REGIME CLASSIFICATION
// ═══════════════════════════════════════════════════════════════════════════════
string regime = switch
    smoothed >= i_spikeThr => "SPIKE"
    smoothed >= i_expThr   => "EXPANSION"
    smoothed <= i_compThr  => "COMPRESSION"
    =>                        "NORMAL"

color regimeColor = switch
    smoothed >= i_spikeThr => SPIKE_COL
    smoothed >= i_expThr   => EXPAND_COL
    smoothed <= i_compThr  => COMPRESS_COL
    =>                        NORMAL_COL

bool isSpike       = regime == "SPIKE"
bool isExpansion   = regime == "EXPANSION"
bool isNormal      = regime == "NORMAL"
bool isCompression = regime == "COMPRESSION"

bool regimeChanged = barstate.isconfirmed and regime != regime[1]
bool toSpike       = barstate.isconfirmed and isSpike       and not isSpike[1]
bool toExpansion   = barstate.isconfirmed and isExpansion   and not isExpansion[1]
bool toCompression = barstate.isconfirmed and isCompression and not isCompression[1]

// Volatility percentile (100-bar rolling)
float smHi  = ta.highest(smoothed, 100)
float smLo  = ta.lowest (smoothed, 100)
float volPct= (smHi - smLo) > 0.0 ? (smoothed - smLo) / (smHi - smLo) * 100.0 : 50.0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — REFERENCE LINES
// ═══════════════════════════════════════════════════════════════════════════════
hline(1.0,         "Normal Baseline",   color=color.new(NORMAL_COL, 60), linestyle=hline.style_dashed,  linewidth=1)
hline(i_compThr,   "Compression Thr",  color=color.new(COMPRESS_COL, 60), linestyle=hline.style_dotted, linewidth=1)
hline(i_expThr,    "Expansion Thr",    color=color.new(EXPAND_COL, 60),  linestyle=hline.style_dotted,  linewidth=1)
hline(i_spikeThr,  "Spike Thr",        color=color.new(SPIKE_COL, 60),   linestyle=hline.style_dotted,  linewidth=1)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
// ATR Ratio as main histogram
plot(atrRatio, "ATR Ratio", color=color.new(regimeColor, 60), style=plot.style_columns, linewidth=1)

// Composite smoothed line
plot(smoothed, "Composite Vol Ratio", color=regimeColor, linewidth=2, style=plot.style_line)

// HV z-score line (secondary, lighter)
plot(i_showHV ? (1.0 + hvZ * 0.2) : na, "HV Z-Score (scaled)",
     color=color.new(NEON_CYAN, 50), linewidth=1, style=plot.style_line)

// BB Width ratio line
plot(i_showBB ? bbWRatio : na, "BB Width Ratio",
     color=color.new(GOLD_VAL, 60), linewidth=1, style=plot.style_line)

// Background fills by regime
bgcolor(isSpike       ? color.new(SPIKE_COL,    96) : na, title="Spike Zone")
bgcolor(isExpansion   ? color.new(EXPAND_COL,   96) : na, title="Expansion Zone")
bgcolor(isCompression ? color.new(COMPRESS_COL, 96) : na, title="Compression Zone")

// Regime transition markers
plotshape(toSpike,       "To Spike",       shape.triangledown, location.top,
     color=SPIKE_COL,    size=size.small,  text="SPIKE",       textcolor=SPIKE_COL)
plotshape(toExpansion,   "To Expansion",   shape.triangleup,   location.top,
     color=EXPAND_COL,   size=size.small,  text="EXPAND",      textcolor=EXPAND_COL)
plotshape(toCompression, "To Compression", shape.triangledown, location.bottom,
     color=COMPRESS_COL, size=size.small,  text="SQUEEZE",     textcolor=COMPRESS_COL)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash
    string trendBias = switch
        isCompression => "BREAKOUT IMMINENT"
        isExpansion   => "USE TREND SIGNALS"
        isSpike       => "AVOID / WIDEN STOPS"
        =>               "NORMAL TRADING"
    color biasCol = switch
        isCompression => COMPRESS_COL
        isExpansion   => EXPAND_COL
        isSpike       => SPIKE_COL
        =>               NORMAL_COL

    table.cell(dash, 0, 0, "Volatility Regime Compass", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Regime",     text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, regime,       text_color=regimeColor,text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 2, "Composite",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 2, str.tostring(smoothed, "#.###"), text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 3, "ATR Ratio",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, str.tostring(atrRatio, "#.###"), text_color=regimeColor, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 4, "Hist Vol",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, str.tostring(hvRaw, "#.#") + "%", text_color=NEON_CYAN, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 5, "BB Width",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, str.tostring(bbW, "#.##") + "%", text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 6, "Percentile", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, str.tostring(volPct, "#.#") + "%", text_color=regimeColor, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 7, "Strategy",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 7, trendBias,    text_color=biasCol,   text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(toSpike,       "VRC Volatility Spike",    "VRC [JOAT]: VOLATILITY SPIKE detected on {{ticker}} {{interval}} — widen stops!")
alertcondition(toExpansion,   "VRC Regime Expansion",    "VRC [JOAT]: Volatility EXPANSION regime on {{ticker}} — trend signals preferred")
alertcondition(toCompression, "VRC Regime Compression",  "VRC [JOAT]: Volatility COMPRESSION (squeeze) on {{ticker}} — breakout imminent")
alertcondition(regimeChanged, "VRC Regime Change",       "VRC [JOAT]: Volatility regime changed on {{ticker}} — reassess strategy")
alertcondition(smoothed > i_spikeThr * 1.5, "VRC Extreme Spike",
     "VRC [JOAT]: EXTREME volatility event on {{ticker}} — exercise extreme caution")
````
