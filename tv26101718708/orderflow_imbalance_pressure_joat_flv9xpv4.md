# Orderflow Imbalance Pressure [JOAT]

- url: https://www.tradingview.com/script/Flv9XpV4-Orderflow-Imbalance-Pressure-JOAT/
- type: indicator
- pine_id: PUB;39773988574a45179f38125843442b6e
- version: 1.0

## Description

[b]Orderflow Imbalance Pressure [JOAT][/b]

[b]Introduction[/b]

Orderflow Imbalance Pressure is an open-source indicator that estimates the imbalance between buying and selling pressure on each bar without access to real bid-ask data, derives a Z-score normalized delta oscillator from that estimate, tracks cumulative delta over the session, and detects structural divergences between price extremes and delta behavior at confirmed pivot points.

The core analytical insight is that when price reaches a new high while the cumulative buying pressure behind it is declining, the move is potentially unsupported — buyers are diminishing while the market is being pushed to new levels. Conversely, price making new lows while selling pressure contracts suggests exhaustion rather than conviction. These divergences are objectively measurable and provide leading context that price action alone does not.

[b]Core Concepts[/b]

[b]1. Delta Estimation from OHLC[/b]

True tick-level delta (bid volume minus ask volume) requires raw tick data. This indicator estimates it from bar data using the classic candle ratio method: buying pressure is proportional to how close the close is to the high, and selling pressure to how close it is to the low:

[pine]
float buyVol  = rng > 0.0 ? volume * (close - low)  / rng : volume * 0.5
float sellVol = rng > 0.0 ? volume * (high - close) / rng : volume * 0.5
float delta   = buyVol - sellVol
[/pine]

This is an approximation — not a substitute for real order flow data — but provides a directionally useful signal on instruments where tick data is unavailable.

[b]2. Delta Z-Score Normalization[/b]

Raw delta varies in scale across instruments and volume conditions. The indicator normalizes delta by computing a rolling Z-score: the delta minus its period mean, divided by its period standard deviation. This produces a dimensionless oscillator centered at zero:

[pine]
float deltaZ = deltaStd > 0.0 ? (delta - deltaMA) / deltaStd : 0.0
[/pine]

Extreme Z-score readings above +1.5 or below -1.5 indicate statistically significant delta imbalances relative to recent history.

[image]https://www.tradingview.com/x/l0BFuNPr/[/image]

[b]3. Cumulative Delta[/b]

Delta values are accumulated across the session to track the net buying or selling bias since session open. The cumulative delta line is scaled and overlaid on the histogram for context. Session resets are configurable (None, Session, or Manual). The cumulative delta often reveals sustained institutional bias that individual bar delta obscures.

[b]4. Imbalance Threshold Markers[/b]

When the delta ratio (delta divided by total volume) exceeds a configurable threshold (default 0.6 = 60% of volume in one direction), the bar is classified as an extreme imbalance. Triangle markers appear at these bars and the background is lightly tinted. Extreme imbalance bars often mark exhaustion points or momentum bursts.

[b]5. Pivot-Confirmed Divergence Detection[/b]

Divergences are detected using confirmed structural pivots rather than rolling high/low lookbacks. A bullish divergence requires a confirmed pivot low that is lower than the prior confirmed pivot low, while the cumulative delta at that pivot is higher than at the prior one. This fires a signal only at genuine structural turning points — typically 5–10 signals per extended chart rather than hundreds:

[pine]
if not na(pivotLow)
    float dAtPivot = cumDelta[pivSide]
    if pivotLow < lastPivLow and dAtPivot > lastPivLowDelta
        bullDiv := true
[/pine]

[b]Features[/b]

[list]
[*][b]OHLC-based delta estimation:[/b] Buy and sell volume proxy from candle structure
[*][b]Z-score normalized oscillator:[/b] Delta normalized by rolling mean and standard deviation
[*][b]Gradient histogram:[/b] Bars colored by delta direction and magnitude intensity
[*][b]Cumulative delta overlay:[/b] Net session delta as a scaled line on the oscillator
[*][b]Session reset modes:[/b] None, Session boundary, or Manual reset options
[*][b]Extreme imbalance markers:[/b] Triangle shapes at bars exceeding the delta ratio threshold
[*][b]Pivot-confirmed divergences:[/b] Bull and bear divergences fired only at structural pivot points
[*][b]Dashboard:[/b] Current delta, bias, buy volume, sell volume, cumulative delta, and Z-score
[*][b]Six alert conditions:[/b] Bull/bear imbalance, bull/bear divergence, delta surge bull/bear
[/list]

[b]Input Parameters[/b]

[b]Delta Engine:[/b]
[list]
[*]Delta Smoothing EMA: Smoothing for delta oscillator line (default: 3)
[*]Delta Normalization Length: Z-score rolling window (default: 20)
[*]Imbalance Threshold: Delta ratio required for extreme marker (default: 0.6)
[/list]

[b]Cumulative Delta:[/b]
[list]
[*]Show Cumulative Delta toggle
[*]Reset Mode: None, Session, or Manual (default: Session)
[*]Cumulative EMA Smooth: Smoothing for cumulative line (default: 5)
[/list]

[b]Signal Settings:[/b]
[list]
[*]Delta Divergence Signal toggle
[*]Divergence Lookback: Base period for pivot divergence detection (default: 20)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Delta Bias[/b]
Check the dashboard's Bias row. BUYING PRESSURE, SELLING PRESSURE, or BALANCED reflects the current delta ratio. Use this to understand whether the current bar's volume is dominated by buyers or sellers.

[b]Step 2: Watch the Cumulative Delta Trend[/b]
A rising cumulative delta line during a price advance confirms the move is volume-supported. Declining cumulative delta during a price advance is a warning sign that buyers are weakening.

[b]Step 3: Act on Divergence Signals[/b]
When a DIV label appears (bullish or bearish), a confirmed structural pivot has formed with a diverging cumulative delta. This is the primary signal output of the indicator — use it to anticipate potential turning points in price.

[b]Step 4: Note Extreme Imbalance Bars[/b]
The triangle markers at extreme imbalance bars often coincide with momentum exhaustion (after a sustained run) or momentum ignition (at a breakout). Context determines which interpretation applies.

[b]Indicator Limitations[/b]

[list]
[*]OHLC delta estimation is a proxy; it does not capture true bid-ask imbalance and will systematically differ from actual order flow data
[*]On instruments with wide spreads or gaps, the candle ratio delta estimation becomes less reliable
[*]Divergences in strong trends often resolve with further trend continuation before the divergence is acted upon
[*]Cumulative delta resets at session boundaries, so intraday and multi-day comparisons require switching reset modes
[/list]

[b]Originality Statement[/b]

The combination of OHLC delta estimation, Z-score normalization, cumulative session delta with configurable resets, and pivot-confirmed divergence detection — requiring structural pivot confirmation rather than rolling lookback extremes — in a single publication is the original contribution. The pivot-gated divergence detection specifically prevents the signal spam common in delta divergence tools that use rolling high/low comparisons.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Delta estimation from OHLC data is an approximation. All signals are based on historical data and do not guarantee future results. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Orderflow Imbalance Pressure [JOAT]", shorttitle="OIP [JOAT]", overlay=false,
     max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color BUY_TEAL   = color.rgb(  0, 200, 160)
color SELL_RED   = color.rgb(220,  40,  70)
color NEUTRAL_GR = color.rgb(140, 160, 210)
color IMBAL_GOLD = color.rgb(255, 185,  20)
color VOID_BG    = color.rgb( 10,  14,  26)
color SLATE_BRD  = color.rgb( 40,  55,  90)
color LAVEN_HDR  = color.rgb(140, 160, 210)
color GOLD_VAL   = color.rgb(255, 215,  60)
color NEON_CYAN  = color.rgb(  0, 243, 255)
color GLOW_MINT  = color.rgb( 60, 245, 155)

lerpCol(color cA, color cB, float t) =>
    float ct = math.max(0.0, math.min(1.0, t))
    int r = int(color.r(cA) + (color.r(cB) - color.r(cA)) * ct)
    int g = int(color.g(cA) + (color.g(cB) - color.g(cA)) * ct)
    int b = int(color.b(cA) + (color.b(cB) - color.b(cA)) * ct)
    color.rgb(r, g, b)

formatVol(float v) =>
    v >= 1000000.0 ? str.tostring(v / 1000000.0, "#.##") + "M" : v >= 1000.0 ? str.tostring(v / 1000.0, "#.##") + "K" : str.tostring(v, "#.#")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_CORE = "━━ Delta Engine ━━"
string G_CUM  = "━━ Cumulative Delta ━━"
string G_SIG  = "━━ Signal Settings ━━"
string G_VIZ  = "━━ Visual ━━"

int    i_deltaSmooth = input.int(3,    "Delta Smoothing (EMA)",       minval=1, maxval=20, group=G_CORE)
int    i_normLen     = input.int(20,   "Delta Normalization Length",  minval=5, group=G_CORE,
     tooltip="Normalizes delta relative to recent volume for cross-asset comparison.")
float  i_imbalThr   = input.float(0.6, "Imbalance Threshold (0-1)",  minval=0.3, maxval=0.95, step=0.05, group=G_CORE,
     tooltip="Delta ratio must exceed this to mark extreme imbalance. 0.6 = 60% buy or sell pressure.")

bool   i_showCum     = input.bool(true,  "Show Cumulative Delta",    group=G_CUM)
string i_resetMode   = input.string("Session", "Reset Mode",
     options=["None","Session","Manual"], group=G_CUM)
int    i_cumSmooth   = input.int(5,    "Cumulative EMA Smooth",      minval=1, group=G_CUM)

bool   i_sigDiv      = input.bool(true, "Delta Divergence Signal",   group=G_SIG,
     tooltip="Fires when price makes new extreme but cumulative delta diverges.")
int    i_divLook     = input.int(20,   "Divergence Lookback",        minval=5, group=G_SIG)

bool   i_showDash    = input.bool(true, "Show Dashboard",            group=G_VIZ)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — DELTA CALCULATION
// Buy volume estimate: vol × (close - low) / (high - low)
// Sell volume estimate: vol × (high - close) / (high - low)
// Delta = Buy - Sell
// ═══════════════════════════════════════════════════════════════════════════════
float rng     = high - low
float buyVol  = rng > 0.0 ? volume * (close - low)  / rng : volume * 0.5
float sellVol = rng > 0.0 ? volume * (high - close) / rng : volume * 0.5
float delta   = buyVol - sellVol

// Normalized delta (ratio -1 to +1)
float deltaRatio = volume > 0.0 ? delta / volume : 0.0

// Smoothed delta
float deltaSmooth = ta.ema(delta, i_deltaSmooth)

// Imbalance flag
bool   bullImbal  = deltaRatio >  i_imbalThr
bool   bearImbal  = deltaRatio < -i_imbalThr

// Delta magnitude as % of average volume
float  volAvg    = ta.sma(volume, 20)
float  deltaPct  = volAvg > 0.0 ? math.abs(delta) / volAvg * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — CUMULATIVE DELTA
// ═══════════════════════════════════════════════════════════════════════════════
bool resetCum = false
if i_resetMode == "Session"
    resetCum := ta.change(dayofweek) != 0 or (hour == 8 and minute == 30 and second == 0)

var float cumDelta = 0.0

if resetCum
    cumDelta := delta
else
    cumDelta += delta

float cumSmooth = ta.ema(cumDelta, i_cumSmooth)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — DIVERGENCE DETECTION (Pivot-confirmed, non-repainting)
// ═══════════════════════════════════════════════════════════════════════════════
// Only fires when a confirmed structural pivot forms with diverging cumulative delta.
// pivSide = bars required on each side to confirm pivot → eliminates noise spamming.
int   pivSide   = math.max(3, i_divLook / 5)
float pivotLow  = ta.pivotlow (low,  pivSide, pivSide)
float pivotHigh = ta.pivothigh(high, pivSide, pivSide)

var float lastPivLow       = na
var float lastPivLowDelta  = na
var float lastPivHigh      = na
var float lastPivHighDelta = na

bool bullDiv = false
bool bearDiv = false

if not na(pivotLow)
    float dAtPivot = cumDelta[pivSide]
    if not na(lastPivLow) and not na(lastPivLowDelta)
        if pivotLow < lastPivLow and dAtPivot > lastPivLowDelta
            bullDiv := true
    lastPivLow      := pivotLow
    lastPivLowDelta := dAtPivot

if not na(pivotHigh)
    float dAtPivot = cumDelta[pivSide]
    if not na(lastPivHigh) and not na(lastPivHighDelta)
        if pivotHigh > lastPivHigh and dAtPivot < lastPivHighDelta
            bearDiv := true
    lastPivHigh      := pivotHigh
    lastPivHighDelta := dAtPivot

bullDiv := barstate.isconfirmed and bullDiv
bearDiv := barstate.isconfirmed and bearDiv

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — ROLLING DELTA OSCILLATOR
// Normalizes delta to rolling zscore for cross-comparison
// ═══════════════════════════════════════════════════════════════════════════════
int    normLen   = i_normLen
float  deltaMA   = ta.sma(delta, normLen)
float  deltaStd  = ta.stdev(delta, normLen)
float  deltaZ    = deltaStd > 0.0 ? (delta - deltaMA) / deltaStd : 0.0
float  deltaZSm  = ta.ema(deltaZ, i_deltaSmooth)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — VISUAL RENDERING
// ═══════════════════════════════════════════════════════════════════════════════
// Reference lines
hline(0,    "Zero Line",     color=color.new(LAVEN_HDR, 60), linestyle=hline.style_solid, linewidth=1)
hline(1.5,  "Upper Thresh",  color=color.new(BUY_TEAL, 60),  linestyle=hline.style_dotted, linewidth=1)
hline(-1.5, "Lower Thresh",  color=color.new(SELL_RED, 60),  linestyle=hline.style_dotted, linewidth=1)

// Delta Z-score histogram
color histCol = deltaZSm >= 0.0 ?
     lerpCol(NEUTRAL_GR, BUY_TEAL, math.min(1.0, deltaZSm / 2.0)) :
     lerpCol(NEUTRAL_GR, SELL_RED, math.min(1.0, -deltaZSm / 2.0))

plot(deltaZSm, "Delta Z-Score", color=histCol, style=plot.style_histogram, linewidth=2)

// Smoothed oscillator line
plot(deltaZSm, "Delta Smooth Line", color=color.new(histCol, 40), linewidth=1, style=plot.style_line)

// Cumulative delta in separate sub-plot (same pane, scaled)
float cumNorm = cumSmooth / (volAvg * 20.0 + 0.0001)
cumNorm := math.max(-3.0, math.min(3.0, cumNorm))
plot(i_showCum ? cumNorm : na, "Cum Delta (Scaled)", color=color.new(NEON_CYAN, 40),
     linewidth=1, style=plot.style_line)

// Imbalance markers
plotshape(bullImbal, "Bull Imbalance", shape.triangleup, location.bottom,
     color=color.new(BUY_TEAL, 20), size=size.tiny)
plotshape(bearImbal, "Bear Imbalance", shape.triangledown, location.top,
     color=color.new(SELL_RED, 20), size=size.tiny)

// Divergence signals
plotshape(i_sigDiv and bullDiv, "Bull Div", shape.labelup, location.bottom,
     color=GLOW_MINT, textcolor=color.black, text="DIV", size=size.small)
plotshape(i_sigDiv and bearDiv, "Bear Div", shape.labeldown, location.top,
     color=SELL_RED,  textcolor=color.white, text="DIV", size=size.small)

// Background for extreme imbalance
bgcolor(bullImbal ? color.new(BUY_TEAL, 95) : bearImbal ? color.new(SELL_RED, 95) : na,
     title="Imbalance Zone")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 7,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash
    string biasStr = deltaRatio > 0.3 ? "BUYING PRESSURE" : deltaRatio < -0.3 ? "SELLING PRESSURE" : "BALANCED"
    color  biasCol = deltaRatio > 0.3 ? BUY_TEAL : deltaRatio < -0.3 ? SELL_RED : LAVEN_HDR
    string cumStr  = cumDelta >= 0.0 ? "+" + formatVol(cumDelta) : formatVol(cumDelta)
    color  cumCol  = cumDelta >= 0.0 ? BUY_TEAL : SELL_RED
    string zStr    = str.tostring(deltaZSm, "#.##")

    table.cell(dash, 0, 0, "Orderflow Imbalance", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Delta",      text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, formatVol(delta), text_color=delta >= 0.0 ? BUY_TEAL : SELL_RED,
         text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 2, "Bias",       text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 2, biasStr,      text_color=biasCol,   text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 3, "Buy Volume", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, formatVol(buyVol), text_color=BUY_TEAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 4, "Sell Volume",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, formatVol(sellVol), text_color=SELL_RED, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 5, "Cum Delta",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, cumStr,        text_color=cumCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 6, "Z-Score",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, zStr,          text_color=GOLD_VAL,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullImbal, "OIP Bull Imbalance",
     "Orderflow Imbalance Pressure [JOAT]: EXTREME buying pressure on {{ticker}} {{interval}}")
alertcondition(bearImbal, "OIP Bear Imbalance",
     "Orderflow Imbalance Pressure [JOAT]: EXTREME selling pressure on {{ticker}} {{interval}}")
alertcondition(i_sigDiv and bullDiv, "OIP Bull Divergence",
     "Orderflow Imbalance Pressure [JOAT]: Bullish delta divergence on {{ticker}}")
alertcondition(i_sigDiv and bearDiv, "OIP Bear Divergence",
     "Orderflow Imbalance Pressure [JOAT]: Bearish delta divergence on {{ticker}}")
alertcondition(ta.crossover(deltaZSm, 1.5),  "OIP Delta Surge Bull",
     "Orderflow Imbalance Pressure [JOAT]: Delta surging bullish on {{ticker}}")
alertcondition(ta.crossunder(deltaZSm, -1.5), "OIP Delta Surge Bear",
     "Orderflow Imbalance Pressure [JOAT]: Delta surging bearish on {{ticker}}")
````
