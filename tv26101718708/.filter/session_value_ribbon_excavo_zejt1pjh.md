# Session Value Ribbon [EXCAVO]

- url: https://www.tradingview.com/script/ZEJt1PjH-Session-Value-Ribbon-EXCAVO/
- type: indicator
- pine_id: PUB;6d1aaf5b4490441e863b85f8a8586b3f
- version: 1.0

## Description

Anchored volume-weighted mean with a harmonic value ribbon and HTF confluence

The [i]Session Value Ribbon[/i] plots a volume-weighted mean of price and a volatility-scaled sigma envelope, then partitions the space between them into a harmonic value ribbon (0.236, 0.382, 0.5, 0.618, 0.786). Three anchor modes let the wave adapt to any chart: Rolling (a sliding N-bar window, default), Timeframe (classical anchored VWAP that resets each session), and Date (fixed anchor). A second accumulator on a slower reference timeframe runs the same math and plots as an HTF confluence line for multi-scale reads.

This is not a basic VWAP indicator. The ribbon layers, the volatility-regime scaling of the sigma bands, the HTF confluence overlay, and the auto-resolver that picks the anchor from the chart timeframe turn a single-line mean into a full value map of the current session.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. The anchored mean, sigma envelope
              and value ribbon draw immediately on whatever anchor
              mode is selected (Rolling by default).
[b]Step 2[/b]  →  Read the mean as fair value for the active anchor.
              Price above the mean = participants are bidding higher
              than the anchor-window average; price below = lower.
[b]Step 3[/b]  →  Watch the outer sigma bands. A close beyond them
              means price is stretched from fair value; the ribbon
              layers below act as pullback shelves.
[b]Step 4[/b]  →  Use ribbon layers as intraday shelves. The 0.5 layer
              is the midpoint between mean and outer band; the 0.236
              layer sits close to the mean; the 0.786 layer sits
              close to the outer band. Look for stalls and false
              breaks at each layer.
[b]Step 5[/b]  →  Cross-check with the HTF confluence line. When the
              primary mean and the HTF mean converge, price is in a
              multi-scale value zone; when they diverge, one session
              is running ahead of the other.
[b]Step 6[/b]  →  Read the dashboard for anchor mode, current mean,
              distance from mean in sigmas, slope regime and bar
              count since the anchor.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Volume-Weighted Mean[/b]
The mean is a running weighted average of the selected price source. Weights come from volume with three modes: Full uses raw volume (classical MIDAS weighting), Root uses the square root of volume (dampens single-bar spikes so one huge candle cannot drag the mean), and None uses equal weight (the mean degenerates to a plain arithmetic average of the source).

[b]◆  Anchor Modes[/b]
Rolling accumulates over a sliding N-bar window (default 200 bars), so the wave is always N bars long regardless of chart timeframe. Timeframe resets the accumulator on each boundary of the chosen anchor timeframe (Daily by default), matching the behaviour of a classical anchored VWAP. Date locks the anchor to a specific timestamp and keeps accumulating forever after.

[b]◆  Sigma Envelope[/b]
Sigma is computed from the anchor-window weighted variance, E[X²] − (E[X])². The outer bands are drawn at ±sigmaMultiplier × sigma around the mean. Optional Volatility Regime Adjust multiplies sigma by an ATR-relative factor, bounded between 0.7x and 1.4x, so the bands breathe with the current activity state, giving tighter bands in quiet regimes and wider bands in wild ones.

[b]◆  Harmonic Value Ribbon[/b]
The space between the mean and each outer band is split into harmonic layers at 0.236, 0.382, 0.5, 0.618 and 0.786 of the sigma distance. The ribbon is rendered as a progressive-opacity fill, not as separate labelled lines, so the eye reads a continuous value gradient instead of a stack of horizontal ledger lines.

[b]◆  HTF Confluence Layer[/b]
A second accumulator runs the exact same math on the next slower anchor timeframe (Rolling with a longer window when the primary is Rolling; the next-slower TF step when the primary is Timeframe). The HTF mean plots as a thin coloured line. When the primary mean and the HTF mean align, price is in a multi-scale value zone.

[b]◆  Slope-Based Regime Classifier[/b]
The classifier measures the slope of the primary mean over the slope-lookback window and normalises it by ATR. If |slope|/ATR exceeds the slope threshold (default 0.05 xATR), the ribbon and mean tint bull or bear. Below the threshold the regime is flat and the palette stays neutral.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Chart-Timeframe Auto-Resolver[/b]
The anchor timeframe is resolved automatically from the chart timeframe, so the wave shape stays consistent across intraday, swing and position TFs without manual tuning.

[b]◆  Volatility-Regime Scaling[/b]
The sigma envelope adapts to activity state instead of being fixed at a static multiplier. Tight regimes contract the bands, wild regimes widen them, with a bounded 0.7x to 1.4x multiplier so the visual stays stable.

[b]◆  Harmonic Ribbon as Progressive Fill[/b]
The intra-band space is drawn as a smooth value gradient rather than a stack of horizontal lines. Layer count is user-selectable (Harmonic 3, 5 or 7).

[b]◆  HTF Confluence Overlay[/b]
A second anchored mean on the next slower timeframe plots as a companion line so multi-scale value alignment is visible without a second indicator on the chart.

[b]◆  Distance-In-Sigma Readout[/b]
A right-edge readout reports the current mean and the current distance from mean in sigmas, so the extreme readings are legible without measuring.

[b]◆  EXCAVO Overlay Visual[/b]
Chart-anchored overlay only, with no pane oscillator and no floating badges. The wave, ribbon and HTF line share a single tonal palette that stays out of the way of price action.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel (top right by default) with all key metrics:
[list]
[*][b]Anchor[/b] - active anchor mode with its parameter (Rolling N, Timeframe TF, or Date)
[*][b]Mean[/b] - current value of the anchored mean
[*][b]Distance[/b] - price distance from mean in sigmas, signed
[*][b]Regime[/b] - Up / Down / Flat classification from the slope-based regime engine
[*][b]Bars in Anchor[/b] - bar count since the anchor started accumulating
[/list]

Legend table (bottom left) explains every glyph and colour used on the chart. Toggle in Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Anchor[/b]
[list]
[*][b]Anchor Mode[/b] - Rolling (default), Timeframe, or Date
[*][b]Rolling Length (bars)[/b] - 200 (window used in Rolling mode)
[*][b]Anchor Timeframe[/b] - D (used in Timeframe mode)
[*][b]Anchor Date[/b] - 01 Jan 2025 (used in Date mode)
[/list]

[b]Source[/b]
[list]
[*][b]Price Source[/b] - (H+L+C)/3 (typical price)
[*][b]Volume Weight[/b] - Full (raw volume) - Root (square root of volume) - None (equal weight)
[/list]

[b]Sigma Bands[/b]
[list]
[*][b]Sigma Multiplier[/b] - 2.0 (band distance in sigmas)
[*][b]Volatility Regime Adjust[/b] - OFF (ATR-scaled sigma with 0.7x-1.4x bounds)
[/list]

[b]Value Ribbon[/b]
[list]
[*][b]Show Value Ribbon[/b] - ON
[*][b]Ribbon Set[/b] - Harmonic 5 (0.236 / 0.382 / 0.5 / 0.618 / 0.786)
[*][b]Ribbon Opacity Base[/b] - 80
[*][b]Show Zone Fill[/b] - ON
[*][b]Zone Fill Opacity[/b] - 88
[/list]

[b]HTF Confluence[/b]
[list]
[*][b]Enable HTF Confluence[/b] - ON (draws a second mean from the next slower anchor)
[/list]

[b]Regime Coloring[/b]
[list]
[*][b]Slope Regime Coloring[/b] - ON
[*][b]Slope Lookback[/b] - 20 bars
[*][b]Slope Threshold (xATR)[/b] - 0.05
[/list]

[b]Visualization[/b]
[list]
[*][b]Bull Color[/b] - deep blue
[*][b]Bear Color[/b] - red
[*][b]Flat Color[/b] - neutral grey
[*][b]HTF Confluence Color[/b] - amber
[*][b]Show Right-Edge Readout[/b] - ON
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Legend[/b] - ON
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

Directional alerts only.

[list]
[*][b]Price Crossed Above Anchored Mean[/b] - close crosses over the primary anchored mean
[*][b]Price Crossed Below Anchored Mean[/b] - close crosses under the primary anchored mean
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Built on MIDAS anchored VWAP (Paul Levine, 1990s), extended with three anchor modes (Rolling / Timeframe / Date), selectable volume weighting, volatility-regime scaling of the sigma bands, a harmonic ribbon rendered as a progressive-opacity fill, an HTF confluence layer, a slope-based regime classifier, and a right-edge distance-in-sigma readout.

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// Session Value Ribbon [EXCAVO]
// -----------------------------------------------------------------------------
// Session-anchored volume-weighted mean (MIDAS-style) with volatility-scaled
// outer bands and an internal value ribbon that partitions the intra-band
// range into harmonic layers. The anchor resets automatically on the boundary
// of the session picked by the chart TF (or by a manual timeframe / date).
// A second, slower anchor is available as an HTF confluence overlay. The
// mean's slope is regime-scored so the ribbon colour tracks the intra-anchor
// trend (up / flat / down).
//
// Concept lineage: MIDAS anchored VWAP (Levine, 1990s) and the open-source
// VWAP Fibonacci Bands by Zeiierman (CC-BY-NC-SA 4.0). This implementation
// is independent code with original touches:
//     - auto-resolver that picks the anchor TF from the chart TF (rather
//       than requiring a manual selection);
//     - selectable volume weighting (Full / Root / None) instead of a fixed
//       linear volume weight;
//     - volatility-regime scaling of the sigma bands (bands breathe with
//       ATR-relative activity, not just with the anchor-window variance);
//     - internal harmonic ribbon rendered as a progressive-opacity fill
//       rather than as independent labelled lines;
//     - HTF confluence layer (a second anchor on a slower TF resolved in the
//       same script, no cross-TF request) for multi-scale reads;
//     - slope-based regime classifier drives the ribbon colour;
//     - right-edge distance-in-sigma readout in the header dashboard;
//     - EXCAVO chart-anchored overlay visual (single navy palette, no
//       rainbow lines).
// Shared under CC-BY-NC-SA per the ShareAlike clause.
//
//@version=6
indicator("Session Value Ribbon [EXCAVO]", "EXCAVO Session Value Ribbon",
     overlay             = true,
     max_labels_count    = 500,
     max_lines_count     = 500,
     max_boxes_count     = 500,
     max_polylines_count = 100,
     max_bars_back       = 2000)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_ANCHOR = "Anchor"
string GRP_SRC    = "Source"
string GRP_BANDS  = "Sigma Bands"
string GRP_RIB    = "Value Ribbon"
string GRP_HTF    = "HTF Confluence"
string GRP_REG    = "Regime Coloring"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"

// --- Anchor ---
// Rolling (default) — sliding N-bar volume-weighted mean so the wave is
// always the same visual length regardless of chart TF. Timeframe —
// classical Zeiierman-style anchored VWAP that resets at each boundary
// (best for scalp TFs where the daily reset gives many bars). Date —
// fixed anchor point, never resets.
string i_anchorMode = input.string("Rolling", "Anchor Mode",
     options = ["Rolling", "Timeframe", "Date"], group = GRP_ANCHOR,
     tooltip = "Rolling: sliding N-bar VWAP — full N-bar wave on any chart TF. Timeframe: classical anchored VWAP, resets at each boundary of Anchor Timeframe. Date: anchor at the exact Anchor Date timestamp and never reset.")
int    i_rollLen    = input.int(200, "Rolling Length (bars)", minval = 20, maxval = 2000, group = GRP_ANCHOR,
     tooltip = "Used when Anchor Mode = Rolling. Number of bars in the sliding window that feeds the VWAP. 200 gives a clean multi-day wave on hourly charts and a multi-week wave on Daily.")
string i_anchorTf   = input.timeframe("D", "Anchor Timeframe", group = GRP_ANCHOR,
     tooltip = "Used when Anchor Mode = Timeframe. The accumulator resets at every boundary of this TF.")
int    i_anchorDate = input.time(timestamp("01 Jan 2025 00:00 UTC"), "Anchor Date", group = GRP_ANCHOR,
     tooltip = "Used when Anchor Mode = Date. Accumulation starts at this timestamp and does not reset.")

// --- Source ---
string i_priceSrc   = input.string("(H+L+C)/3", "Price Source",
     options = ["Close", "High", "Low", "(H+L)/2", "(H+L+C)/3", "(O+H+L+C)/4"], group = GRP_SRC,
     tooltip = "Which price series feeds the weighted mean.")
string i_volMode    = input.string("Full", "Volume Weight",
     options = ["Full", "Root", "None"], group = GRP_SRC,
     tooltip = "Full: v; Root: sqrt(v) (dampens single-bar spikes); None: 1 (equal-weight, degenerates to arithmetic mean).")

// --- Sigma Bands ---
float  i_sigmaMult  = input.float(2.0, "Sigma Multiplier", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_BANDS,
     tooltip = "Outer band distance in standard deviations. 2.0 covers roughly 95 percent of the anchor-window distribution.")
bool   i_regimeAdj  = input.bool(false, "Volatility Regime Adjust", group = GRP_BANDS,
     tooltip = "Multiply the sigma by an ATR-relative factor so the bands breathe with the current volatility state (tight regime = tighter bands; wild = wider). Off by default — the raw MIDAS sigma is closer to the classical reference behaviour and renders as a smoother wave.")

// --- Value Ribbon ---
bool   i_showRibbon = input.bool(true, "Show Value Ribbon", group = GRP_RIB,
     tooltip = "Layered inner bands between the mean and each outer sigma band. Renders as a progressive-opacity fill rather than independent labelled lines.")
string i_ribbonSet  = input.string("Harmonic 5", "Ribbon Set",
     options = ["Harmonic 3", "Harmonic 5", "Harmonic 7"], group = GRP_RIB,
     tooltip = "How many intra-band layers to render. Harmonic 5 uses 0.236 / 0.382 / 0.5 / 0.618 / 0.786 (the classical set).")
int    i_ribbonOpac = input.int(80, "Ribbon Opacity Base (0-100)", minval = 40, maxval = 95, group = GRP_RIB,
     tooltip = "Base transparency for the ribbon fill. Higher = fainter. Inner layers get progressively less opaque than outer.")
bool   i_showFill   = input.bool(true, "Show Zone Fill", group = GRP_RIB,
     tooltip = "Semi-transparent wash between the mean and each outer sigma band. Renders behind the polyline layers.")
int    i_fillOpac   = input.int(88, "Zone Fill Opacity (0-100)", minval = 70, maxval = 97, group = GRP_RIB,
     tooltip = "Transparency of the zone fill. Higher = fainter (softer wash). 88 gives a subtle backdrop that reads without overwhelming the ribbon.")

// --- HTF Confluence ---
bool   i_htfEnable  = input.bool(true, "Enable HTF Confluence", group = GRP_HTF,
     tooltip = "Overlay a second anchored mean using an anchor one step slower than the primary. Read the two together to spot multi-scale value alignment.")

// --- Regime Coloring ---
bool   i_regimeCol  = input.bool(true, "Slope Regime Coloring", group = GRP_REG,
     tooltip = "Colour the ribbon and the mean by the slope of the mean itself (positive slope = bull tint, negative = bear, flat = neutral).")
int    i_slopeLen   = input.int(20, "Slope Lookback", minval = 5, maxval = 100, group = GRP_REG,
     tooltip = "How many bars back to measure the slope of the mean.")
float  i_slopeThr   = input.float(0.05, "Slope Threshold (xATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = GRP_REG,
     tooltip = "Slope must exceed this many ATRs (over slope lookback) to leave the flat state. Higher = more time spent flat.")

// --- Visualization ---
// Colors from the EXCAVO Color Scheme standard (standards/color-scheme.md).
// C_BULL / C_BEAR / C_FLAT are the exact values every EXCAVO indicator uses;
// they read cleanly against the light-blue TradingView chart background.
color  C_BULL       = input.color(color.rgb(0, 60, 180),    "Bull Color",   group = GRP_VIZ,
     tooltip = "Tint when the mean's slope is positive. EXCAVO standard bullish colour.")
color  C_BEAR       = input.color(color.rgb(200, 40, 40),   "Bear Color",   group = GRP_VIZ,
     tooltip = "Tint when the mean's slope is negative. EXCAVO standard bearish colour.")
color  C_FLAT       = input.color(color.rgb(80, 80, 100),   "Flat Color",   group = GRP_VIZ,
     tooltip = "Tint when the slope is within the threshold. EXCAVO standard neutral colour.")
color  C_HTF        = input.color(color.rgb(255, 140, 0),   "HTF Confluence Color", group = GRP_VIZ,
     tooltip = "Colour of the HTF confluence line. EXCAVO standard accent orange.")
bool   i_showEdge   = input.bool(true, "Show Right-Edge Readout", group = GRP_VIZ,
     tooltip = "Small label at the right edge showing the current mean value and the price's distance from it in sigmas.")

// --- Dashboard ---
bool   i_showDash   = input.bool(true, "Show Dashboard", group = GRP_DASH)
string i_dashPos    = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)
bool   i_showLegnd  = input.bool(true, "Show Legend", group = GRP_DASH)

//-----------------------------------------------------------------------------}
// Constants (EXCAVO palette per standards/color-scheme.md — locked 2026-06-19)
//-----------------------------------------------------------------------------{
color C_DASH_BG      = color.rgb(50,  53,  60)   // #32353C dark grey (no alpha)
color C_DASH_BORDER  = color.rgb(80,  85,  95)   // #50555F grey border
color C_DASH_BULL    = color.rgb(80,  200, 255)  // #50C8FF neon cyan-blue (headers + bull states)
color C_DASH_BEAR    = color.rgb(255, 85,  95)   // #FF555F neon pink-red
color C_DASH_SIGNAL  = color.rgb(255, 170, 50)   // #FFAA32 warning / highlight
color C_DASH_NEUTRAL = color.rgb(80,  80,  100)  // #505064 neutral / inactive

//-----------------------------------------------------------------------------}
// Helpers
//-----------------------------------------------------------------------------{
// Resolve the numeric source series from the string input.
f_price(string s) =>
    switch s
        "Close"       => close
        "High"        => high
        "Low"         => low
        "(H+L)/2"     => (high + low) / 2.0
        "(H+L+C)/3"   => (high + low + close) / 3.0
        "(O+H+L+C)/4" => (open + high + low + close) / 4.0
        => (high + low + close) / 3.0

// Resolve the numeric weight from the volume mode.
f_weight(string mode) =>
    result = 1.0
    if mode == "Full"
        result := volume
    else if mode == "Root"
        result := math.sqrt(math.max(volume, 0.0))
    else
        result := 1.0
    result

// Auto-picked primary anchor TF based on the chart TF. In Auto mode the
// accumulator ANCHORS at the first bar of the chart data (Zeiierman-style
// continuous wave — no periodic reset). The returned TF is only used for
// the HTF confluence layer offset and for the dashboard label.
f_autoAnchor() =>
    int sec = timeframe.in_seconds()
    string tf = "D"
    if sec <= 900
        tf := "D"
    else if sec <= 14400
        tf := "W"
    else if sec <= 86400
        tf := "M"
    else
        tf := "3M"
    tf

// One step slower than the primary anchor, used for the HTF confluence layer.
f_htfAnchor(string primary) =>
    result = "M"
    if primary == "D"
        result := "W"
    else if primary == "W"
        result := "M"
    else if primary == "M"
        result := "3M"
    else
        result := "12M"
    result

// Progressive-opacity ribbon colour. Deeper layers (closer to the mean) get
// less opaque so the fill visually pulses out from the mean.
f_ribbonCol(color base, int baseOpac, int layerIdx, int layerN) =>
    // layerIdx = 0 is the outermost band, layerN-1 is the innermost.
    // The innermost layer is a bit stronger than the outer to draw the eye
    // toward the centre.
    float step = (95.0 - baseOpac) / math.max(1, layerN - 1)
    int   opac = int(baseOpac + step * layerIdx)
    color.new(base, opac)

// Adaptive numeric formatting for the header dashboard.
f_fmtNum(float v) =>
    result = "--"
    if not na(v)
        float a = math.abs(v)
        if a >= 10000
            result := str.tostring(v / 1000, "0.0") + "k"
        else if a >= 1
            result := str.tostring(v, "0.00")
        else
            result := str.tostring(v, "0.0000")
    result

//-----------------------------------------------------------------------------}
// Anchor resolution
//-----------------------------------------------------------------------------{
string primaryTf = i_anchorMode == "Timeframe" ? i_anchorTf : f_autoAnchor()
string htfTf     = f_htfAnchor(primaryTf)

//-----------------------------------------------------------------------------}
// Primary accumulator — three code paths depending on Anchor Mode:
//   Rolling   -> sliding N-bar VWAP via math.sum, no anchor state
//   Timeframe -> classical Zeiierman-style anchored VWAP with reset
//   Date      -> anchored at a fixed timestamp, no reset
//-----------------------------------------------------------------------------{
float px    = f_price(i_priceSrc)
float w     = f_weight(i_volMode)
float pvw   = px * w
float pSqvw = px * px * w

// --- Cumulative running sums (feed both Rolling and Timeframe/Date paths) ---
// Manual cumulative sums let the Rolling window degrade gracefully into an
// expanding window for the first N bars (avoids the visual cliff where the
// wave would otherwise "pop" into existence at bar N).
var float cum_pv   = 0.0
var float cum_pSqv = 0.0
var float cum_v    = 0.0
cum_pv    := cum_pv   + nz(pvw)
cum_pSqv  := cum_pSqv + nz(pSqvw)
cum_v     := cum_v    + nz(w)

// --- Timeframe / Date accumulator state (used only in those modes) ---
var float acc_pv     = 0.0
var float acc_pSqv   = 0.0
var float acc_v      = 0.0
var int   accBars    = 0

// Reset boundary — only meaningful in Timeframe mode.
bool primaryReset = false
if i_anchorMode == "Timeframe"
    primaryReset := ta.change(time(i_anchorTf)) != 0

if primaryReset
    acc_pv     := 0.0
    acc_pSqv   := 0.0
    acc_v      := 0.0
    accBars    := 0

// In Timeframe mode we always accumulate; in Date mode only after the
// anchor timestamp; in Rolling mode the state accumulator is unused.
bool accActive = i_anchorMode == "Timeframe" or (i_anchorMode == "Date" and time >= i_anchorDate)
if accActive
    acc_pv    := acc_pv   + pvw
    acc_pSqv  := acc_pSqv + pSqvw
    acc_v     := acc_v    + w
    accBars   := accBars  + 1

// --- Choose midas / sigma / anchorBars based on mode ---
float midas = na
float sigma = na
int   anchorBars = 0

if i_anchorMode == "Rolling"
    // Rolling window as (cum_now - cum_N_ago). For bars where fewer than N
    // bars of history exist, cum[i_rollLen] is na and nz returns 0, so the
    // formula collapses to an expanding window from bar 0 — the wave grows
    // gradually from the left edge with no cliff.
    float roll_pv = cum_pv   - nz(cum_pv[i_rollLen])
    float roll_pS = cum_pSqv - nz(cum_pSqv[i_rollLen])
    float roll_v  = cum_v    - nz(cum_v[i_rollLen])
    if roll_v > 0.0
        midas := roll_pv / roll_v
        float variance = roll_pS / roll_v - midas * midas
        sigma := variance > 0.0 ? math.sqrt(variance) : na
    anchorBars := math.min(bar_index + 1, i_rollLen)
else
    if acc_v != 0.0
        midas := acc_pv / acc_v
        float variance = acc_pSqv / acc_v - midas * midas
        sigma := variance > 0.0 ? math.sqrt(variance) : na
    anchorBars := accBars

// A short warmup — variance is unstable when very few bars are in the
// window (would collapse the bands onto the mean, producing a vertical
// spike). After 5 bars the bands stabilise.
int  WARMUP_BARS = 5
bool bandsReady  = anchorBars >= WARMUP_BARS
if not bandsReady
    sigma := na
    midas := na

//-----------------------------------------------------------------------------}
// Volatility regime scaling
// A tight regime (recent ATR small vs. its long baseline) tightens the bands;
// a wild regime widens them. Bounded so the outer bands never blow up.
//-----------------------------------------------------------------------------{
float atrShort = ta.atr(14)
float atrLong  = ta.ema(atrShort, 200)
float regimeK  = not na(atrLong) and atrLong > 0 ? atrShort / atrLong : 1.0
regimeK := math.max(0.7, math.min(1.4, regimeK))
float sigmaEff = i_regimeAdj and not na(sigma) ? sigma * regimeK : sigma

float upperBand = not na(midas) and not na(sigmaEff) ? midas + i_sigmaMult * sigmaEff : na
float lowerBand = not na(midas) and not na(sigmaEff) ? midas - i_sigmaMult * sigmaEff : na

//-----------------------------------------------------------------------------}
// Value ribbon — inner harmonic bands rendered as progressive-opacity fills
//-----------------------------------------------------------------------------{
// Harmonic sets (classical retracement fractions).
var array<float> ribbonRatios = array.new_float()
if bar_index == 0
    ribbonRatios.clear()
    if i_ribbonSet == "Harmonic 3"
        ribbonRatios.push(0.382)
        ribbonRatios.push(0.5)
        ribbonRatios.push(0.618)
    else if i_ribbonSet == "Harmonic 7"
        ribbonRatios.push(0.146)
        ribbonRatios.push(0.236)
        ribbonRatios.push(0.382)
        ribbonRatios.push(0.5)
        ribbonRatios.push(0.618)
        ribbonRatios.push(0.786)
        ribbonRatios.push(0.886)
    else
        // Harmonic 5 default
        ribbonRatios.push(0.236)
        ribbonRatios.push(0.382)
        ribbonRatios.push(0.5)
        ribbonRatios.push(0.618)
        ribbonRatios.push(0.786)

//-----------------------------------------------------------------------------}
// HTF confluence — second VWAP that mirrors the primary's math but at a
// slower reference:
//   Rolling primary   -> HTF is a Rolling VWAP of length 3 x i_rollLen
//   Timeframe primary -> HTF is anchored VWAP that resets on the slower
//                        anchor TF (htfTf)
//   Date primary      -> HTF disabled (single anchor, no meaningful second
//                        reference exists)
//-----------------------------------------------------------------------------{
int htfRollLen = i_rollLen * 3

var float acc_pv_h   = 0.0
var float acc_pSqv_h = 0.0
var float acc_v_h    = 0.0
var int   htfAnchorBars = 0

// Anchored-mode reset (only used in Timeframe primary).
bool htfReset = i_anchorMode == "Timeframe" and ta.change(time(htfTf)) != 0
if htfReset
    acc_pv_h      := 0.0
    acc_pSqv_h    := 0.0
    acc_v_h       := 0.0
    htfAnchorBars := 0

// Accumulate for the anchored path only.
if i_htfEnable and i_anchorMode == "Timeframe"
    acc_pv_h      := acc_pv_h      + pvw
    acc_pSqv_h    := acc_pSqv_h    + pSqvw
    acc_v_h       := acc_v_h       + w
    htfAnchorBars := htfAnchorBars + 1

float midasHtf = na
if i_htfEnable
    if i_anchorMode == "Rolling"
        // Same expanding-into-rolling trick used on the primary, so the
        // HTF line also flares in from the left edge with no cliff.
        float roll_pv_h = cum_pv - nz(cum_pv[htfRollLen])
        float roll_v_h  = cum_v  - nz(cum_v[htfRollLen])
        if roll_v_h > 0.0
            midasHtf := roll_pv_h / roll_v_h
    else if i_anchorMode == "Timeframe"
        if acc_v_h != 0.0 and htfAnchorBars >= WARMUP_BARS
            midasHtf := acc_pv_h / acc_v_h
    // Date mode leaves midasHtf as na — HTF confluence is meaningless with
    // a single fixed anchor.

//-----------------------------------------------------------------------------}
// Slope regime — measure slope of the primary mean and classify
//-----------------------------------------------------------------------------{
float slopeAtr = ta.atr(math.max(5, i_slopeLen))
float thrAbs   = not na(slopeAtr) ? slopeAtr * i_slopeThr : 0.0
float slope    = not na(midas) and not na(midas[i_slopeLen]) ? (midas - midas[i_slopeLen]) / i_slopeLen : 0.0

int regime = 0
if slope >  thrAbs / i_slopeLen
    regime := 1
else if slope < -thrAbs / i_slopeLen
    regime := -1

color C_ACTIVE = i_regimeCol ? (regime == 1 ? C_BULL : regime == -1 ? C_BEAR : C_FLAT) : C_BULL

//-----------------------------------------------------------------------------}
// Ribbon layer values (used by both the polyline renderer and the right-edge
// tag labels)
//-----------------------------------------------------------------------------{
int   ribbonN = ribbonRatios.size()
float rUp1    = i_showRibbon and ribbonN >= 1 and not na(midas) and not na(upperBand) ? midas + ribbonRatios.get(0) * (upperBand - midas) : na
float rUp2    = i_showRibbon and ribbonN >= 2 and not na(midas) and not na(upperBand) ? midas + ribbonRatios.get(1) * (upperBand - midas) : na
float rUp3    = i_showRibbon and ribbonN >= 3 and not na(midas) and not na(upperBand) ? midas + ribbonRatios.get(2) * (upperBand - midas) : na
float rUp4    = i_showRibbon and ribbonN >= 4 and not na(midas) and not na(upperBand) ? midas + ribbonRatios.get(3) * (upperBand - midas) : na
float rUp5    = i_showRibbon and ribbonN >= 5 and not na(midas) and not na(upperBand) ? midas + ribbonRatios.get(4) * (upperBand - midas) : na
float rDn1    = i_showRibbon and ribbonN >= 1 and not na(midas) and not na(lowerBand) ? midas - ribbonRatios.get(0) * (midas - lowerBand) : na
float rDn2    = i_showRibbon and ribbonN >= 2 and not na(midas) and not na(lowerBand) ? midas - ribbonRatios.get(1) * (midas - lowerBand) : na
float rDn3    = i_showRibbon and ribbonN >= 3 and not na(midas) and not na(lowerBand) ? midas - ribbonRatios.get(2) * (midas - lowerBand) : na
float rDn4    = i_showRibbon and ribbonN >= 4 and not na(midas) and not na(lowerBand) ? midas - ribbonRatios.get(3) * (midas - lowerBand) : na
float rDn5    = i_showRibbon and ribbonN >= 5 and not na(midas) and not na(lowerBand) ? midas - ribbonRatios.get(4) * (midas - lowerBand) : na

//-----------------------------------------------------------------------------}
// Polyline renderer — draws the CURRENT session's wave per series. Values
// are accumulated into arrays every bar and materialised as polyline
// objects on the last bar. On anchor reset the arrays are cleared so
// only the current session is visible (Zeiierman-style behaviour, but
// via polylines because Pine's plot.style_linebr can't be dynamically
// coloured per bar the way we need).
//-----------------------------------------------------------------------------{
// Primary-session arrays (mean, outer bands, and up-to-5 ribbon layers per side).
var array<chart.point> pts_mid = array.new<chart.point>()
var array<chart.point> pts_up  = array.new<chart.point>()
var array<chart.point> pts_dn  = array.new<chart.point>()
var array<chart.point> pts_ru1 = array.new<chart.point>()
var array<chart.point> pts_ru2 = array.new<chart.point>()
var array<chart.point> pts_ru3 = array.new<chart.point>()
var array<chart.point> pts_ru4 = array.new<chart.point>()
var array<chart.point> pts_ru5 = array.new<chart.point>()
var array<chart.point> pts_rd1 = array.new<chart.point>()
var array<chart.point> pts_rd2 = array.new<chart.point>()
var array<chart.point> pts_rd3 = array.new<chart.point>()
var array<chart.point> pts_rd4 = array.new<chart.point>()
var array<chart.point> pts_rd5 = array.new<chart.point>()
// HTF array — grows from the first HTF boundary onward and resets on each
// HTF boundary.
var array<chart.point> pts_htf = array.new<chart.point>()

// In Timeframe mode we clear the arrays at each anchor reset so the
// polyline renders only the current session. Rolling / Date modes do
// not clear — Rolling keeps a FIFO tail of the last N bars, Date keeps
// growing from the anchor onward.
if primaryReset
    pts_mid.clear()
    pts_up.clear()
    pts_dn.clear()
    pts_ru1.clear()
    pts_ru2.clear()
    pts_ru3.clear()
    pts_ru4.clear()
    pts_ru5.clear()
    pts_rd1.clear()
    pts_rd2.clear()
    pts_rd3.clear()
    pts_rd4.clear()
    pts_rd5.clear()

if htfReset
    pts_htf.clear()

// Push this bar's values (only when they're valid — post-warmup, source active).
if not na(midas)
    pts_mid.push(chart.point.from_index(bar_index, midas))
if not na(upperBand)
    pts_up.push(chart.point.from_index(bar_index, upperBand))
if not na(lowerBand)
    pts_dn.push(chart.point.from_index(bar_index, lowerBand))
if i_showRibbon and not na(rUp1)
    pts_ru1.push(chart.point.from_index(bar_index, rUp1))
if i_showRibbon and not na(rUp2)
    pts_ru2.push(chart.point.from_index(bar_index, rUp2))
if i_showRibbon and not na(rUp3)
    pts_ru3.push(chart.point.from_index(bar_index, rUp3))
if i_showRibbon and not na(rUp4)
    pts_ru4.push(chart.point.from_index(bar_index, rUp4))
if i_showRibbon and not na(rUp5)
    pts_ru5.push(chart.point.from_index(bar_index, rUp5))
if i_showRibbon and not na(rDn1)
    pts_rd1.push(chart.point.from_index(bar_index, rDn1))
if i_showRibbon and not na(rDn2)
    pts_rd2.push(chart.point.from_index(bar_index, rDn2))
if i_showRibbon and not na(rDn3)
    pts_rd3.push(chart.point.from_index(bar_index, rDn3))
if i_showRibbon and not na(rDn4)
    pts_rd4.push(chart.point.from_index(bar_index, rDn4))
if i_showRibbon and not na(rDn5)
    pts_rd5.push(chart.point.from_index(bar_index, rDn5))
if i_htfEnable and not na(midasHtf)
    pts_htf.push(chart.point.from_index(bar_index, midasHtf))

// FIFO cap in Rolling mode so each polyline holds only the last N points
// (matches the sliding-window meaning of the mode and prevents the array
// from growing over the entire chart history).
if i_anchorMode == "Rolling"
    while pts_mid.size() > i_rollLen
        pts_mid.shift()
    while pts_up.size()  > i_rollLen
        pts_up.shift()
    while pts_dn.size()  > i_rollLen
        pts_dn.shift()
    while pts_ru1.size() > i_rollLen
        pts_ru1.shift()
    while pts_ru2.size() > i_rollLen
        pts_ru2.shift()
    while pts_ru3.size() > i_rollLen
        pts_ru3.shift()
    while pts_ru4.size() > i_rollLen
        pts_ru4.shift()
    while pts_ru5.size() > i_rollLen
        pts_ru5.shift()
    while pts_rd1.size() > i_rollLen
        pts_rd1.shift()
    while pts_rd2.size() > i_rollLen
        pts_rd2.shift()
    while pts_rd3.size() > i_rollLen
        pts_rd3.shift()
    while pts_rd4.size() > i_rollLen
        pts_rd4.shift()
    while pts_rd5.size() > i_rollLen
        pts_rd5.shift()
    while pts_htf.size() > htfRollLen
        pts_htf.shift()

// Ribbon colours — bull tint above the mean, bear tint below — keeps the
// direction of the layer obvious. Outer bands use the regime-scored active
// colour, dimmer than the mean.
color colMid = C_ACTIVE
color colBnd = color.new(C_ACTIVE, 30)
color colUpR = i_showRibbon ? color.new(C_BEAR, 20) : na
color colDnR = i_showRibbon ? color.new(C_BULL, 20) : na
color colHtf = i_htfEnable  ? color.new(C_HTF,  30) : na

// Persistent polyline objects — deleted and recreated on every last-bar
// redraw so a fresh session's data replaces the previous one cleanly.
var polyline pl_mid = na
var polyline pl_up  = na
var polyline pl_dn  = na
var polyline pl_ru1 = na
var polyline pl_ru2 = na
var polyline pl_ru3 = na
var polyline pl_ru4 = na
var polyline pl_ru5 = na
var polyline pl_rd1 = na
var polyline pl_rd2 = na
var polyline pl_rd3 = na
var polyline pl_rd4 = na
var polyline pl_rd5 = na
var polyline pl_htf = na

f_drawPl(polyline prev, array<chart.point> pts, color c, int lw) =>
    result = prev
    if not na(prev)
        polyline.delete(prev)
    if pts.size() >= 2
        // array.copy so the polyline holds its own snapshot; the source
        // array is cleared at the next anchor reset without affecting
        // the drawn polyline until the next last-bar redraw.
        result := polyline.new(array.copy(pts), curved = false, closed = false,
             line_color = c, line_width = lw, xloc = xloc.bar_index)
    else
        result := na
    result

if barstate.islast
    pl_mid := f_drawPl(pl_mid, pts_mid, colMid, 2)
    pl_up  := f_drawPl(pl_up,  pts_up,  colBnd, 1)
    pl_dn  := f_drawPl(pl_dn,  pts_dn,  colBnd, 1)
    if i_showRibbon and ribbonN >= 1
        pl_ru1 := f_drawPl(pl_ru1, pts_ru1, colUpR, 1)
        pl_rd1 := f_drawPl(pl_rd1, pts_rd1, colDnR, 1)
    if i_showRibbon and ribbonN >= 2
        pl_ru2 := f_drawPl(pl_ru2, pts_ru2, colUpR, 1)
        pl_rd2 := f_drawPl(pl_rd2, pts_rd2, colDnR, 1)
    if i_showRibbon and ribbonN >= 3
        pl_ru3 := f_drawPl(pl_ru3, pts_ru3, colUpR, 1)
        pl_rd3 := f_drawPl(pl_rd3, pts_rd3, colDnR, 1)
    if i_showRibbon and ribbonN >= 4
        pl_ru4 := f_drawPl(pl_ru4, pts_ru4, colUpR, 1)
        pl_rd4 := f_drawPl(pl_rd4, pts_rd4, colDnR, 1)
    if i_showRibbon and ribbonN >= 5
        pl_ru5 := f_drawPl(pl_ru5, pts_ru5, colUpR, 1)
        pl_rd5 := f_drawPl(pl_rd5, pts_rd5, colDnR, 1)
    if i_htfEnable
        pl_htf := f_drawPl(pl_htf, pts_htf, colHtf, 1)

// Invisible plots — used as fill anchors. Line colour is na so nothing
// draws on chart, but the plot series is exposed to fill() and to the
// crosshair / data-window value readouts. The two fill() calls behind
// them paint a soft wash between the mean and each outer sigma band —
// bear tint above the mean (overextension zone), bull tint below the
// mean (discount zone). Fills render underneath the polylines.
plotMidFill = plot(midas,     "Anchored Mean", color = na)
plotUpFill  = plot(upperBand, "Upper Band",    color = na)
plotDnFill  = plot(lowerBand, "Lower Band",    color = na)

fill(plotMidFill, plotUpFill,
     color = i_showFill ? color.new(C_BEAR, i_fillOpac) : na,
     title = "Upper Zone Fill")
fill(plotMidFill, plotDnFill,
     color = i_showFill ? color.new(C_BULL, i_fillOpac) : na,
     title = "Lower Zone Fill")

//-----------------------------------------------------------------------------}
// Right-edge readouts — ratio tags on the ribbon layers plus the mean tag
//-----------------------------------------------------------------------------{
// Ratio labels give the eye an immediate reference for each ribbon layer,
// the same way Zeiierman's tags do — without them the ribbon reads as a
// wash of colour with no anchor. Delete-and-recreate on every last-bar redraw
// (pre-allocated pattern would leak lines on input change).
var label lbl_mid   = na
var label lbl_ru1   = na
var label lbl_ru2   = na
var label lbl_ru3   = na
var label lbl_ru4   = na
var label lbl_ru5   = na
var label lbl_rd1   = na
var label lbl_rd2   = na
var label lbl_rd3   = na
var label lbl_rd4   = na
var label lbl_rd5   = na
var label lbl_up    = na
var label lbl_dn    = na
var label lbl_htf   = na

f_ratioLbl(float y, string ratio, color base) =>
    result = label.new(bar_index + 4, y, ratio,
         xloc      = xloc.bar_index,
         style     = label.style_label_left,
         color     = color.new(base, 15),
         textcolor = color.white,
         size      = size.small)
    result

if i_showEdge and barstate.islast
    // Kill previous instances first — labels persist across bar re-renders.
    if not na(lbl_mid)
        label.delete(lbl_mid)
    if not na(lbl_ru1)
        label.delete(lbl_ru1)
    if not na(lbl_ru2)
        label.delete(lbl_ru2)
    if not na(lbl_ru3)
        label.delete(lbl_ru3)
    if not na(lbl_ru4)
        label.delete(lbl_ru4)
    if not na(lbl_ru5)
        label.delete(lbl_ru5)
    if not na(lbl_rd1)
        label.delete(lbl_rd1)
    if not na(lbl_rd2)
        label.delete(lbl_rd2)
    if not na(lbl_rd3)
        label.delete(lbl_rd3)
    if not na(lbl_rd4)
        label.delete(lbl_rd4)
    if not na(lbl_rd5)
        label.delete(lbl_rd5)
    if not na(lbl_up)
        label.delete(lbl_up)
    if not na(lbl_dn)
        label.delete(lbl_dn)
    if not na(lbl_htf)
        label.delete(lbl_htf)

    if not na(midas)
        // Anchored mean — always visible.
        float dSigma = not na(sigmaEff) and sigmaEff > 0 ? (close - midas) / sigmaEff : na
        string dText = na(dSigma) ? "" : "  " + (dSigma >= 0 ? "+" : "") + str.tostring(dSigma, "0.01") + "s"
        string mText = f_fmtNum(midas) + dText
        lbl_mid := label.new(bar_index + 4, midas, mText,
             xloc      = xloc.bar_index,
             style     = label.style_label_left,
             color     = color.new(C_ACTIVE, 15),
             textcolor = color.white,
             size      = size.small)

    // Outer sigma bands — semantic coloring (upper = bear tint = overextension,
    // lower = bull tint = discount) regardless of the mean's slope regime.
    // Only the anchored mean itself reflects the regime.
    if not na(upperBand)
        lbl_up := f_ratioLbl(upperBand, "+" + str.tostring(i_sigmaMult, "0.0") + "s", C_BEAR)
    if not na(lowerBand)
        lbl_dn := f_ratioLbl(lowerBand, "-" + str.tostring(i_sigmaMult, "0.0") + "s", C_BULL)

    // Ribbon ratio tags — upper layers use bear tint, lower use bull tint.
    if i_showRibbon and ribbonN >= 1
        if not na(rUp1)
            lbl_ru1 := f_ratioLbl(rUp1, str.tostring(ribbonRatios.get(0), "0.000"), C_BEAR)
        if not na(rDn1)
            lbl_rd1 := f_ratioLbl(rDn1, str.tostring(ribbonRatios.get(0), "0.000"), C_BULL)
    if i_showRibbon and ribbonN >= 2
        if not na(rUp2)
            lbl_ru2 := f_ratioLbl(rUp2, str.tostring(ribbonRatios.get(1), "0.000"), C_BEAR)
        if not na(rDn2)
            lbl_rd2 := f_ratioLbl(rDn2, str.tostring(ribbonRatios.get(1), "0.000"), C_BULL)
    if i_showRibbon and ribbonN >= 3
        if not na(rUp3)
            lbl_ru3 := f_ratioLbl(rUp3, str.tostring(ribbonRatios.get(2), "0.000"), C_BEAR)
        if not na(rDn3)
            lbl_rd3 := f_ratioLbl(rDn3, str.tostring(ribbonRatios.get(2), "0.000"), C_BULL)
    if i_showRibbon and ribbonN >= 4
        if not na(rUp4)
            lbl_ru4 := f_ratioLbl(rUp4, str.tostring(ribbonRatios.get(3), "0.000"), C_BEAR)
        if not na(rDn4)
            lbl_rd4 := f_ratioLbl(rDn4, str.tostring(ribbonRatios.get(3), "0.000"), C_BULL)
    if i_showRibbon and ribbonN >= 5
        if not na(rUp5)
            lbl_ru5 := f_ratioLbl(rUp5, str.tostring(ribbonRatios.get(4), "0.000"), C_BEAR)
        if not na(rDn5)
            lbl_rd5 := f_ratioLbl(rDn5, str.tostring(ribbonRatios.get(4), "0.000"), C_BULL)

    // HTF confluence mean tag (only when enabled and the layer is warmed up).
    if i_htfEnable and not na(midasHtf)
        lbl_htf := f_ratioLbl(midasHtf, "HTF " + f_fmtNum(midasHtf), C_HTF)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
f_dashPos(string s) =>
    result = position.top_right
    if s == "Top Left"
        result := position.top_left
    else if s == "Bottom Right"
        result := position.bottom_right
    else if s == "Bottom Left"
        result := position.bottom_left
    result

if i_showDash and barstate.islast
    var table dash = table.new(f_dashPos(i_dashPos), 2, 6,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER, border_width = 2,
         frame_color  = C_DASH_BORDER, frame_width  = 2)

    // Header: two-cell EXCAVO | short product name in C_DASH_BULL per
    // constitution (standards/color-scheme.md line 199). Shortened from
    // "Session Value Ribbon" to "Value Ribbon" so the dashboard is compact.
    // Static values use color.white (C_DASH_NEUTRAL is a dark chart tint
    // and would be invisible on the dark grey dashboard background).
    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Value Ribbon",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_right)

    string modeStr = i_anchorMode == "Rolling" ? "Rolling " + str.tostring(i_rollLen) : i_anchorMode == "Timeframe" ? i_anchorTf : "Date"
    table.cell(dash, 0, 1, "Anchor",
         text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 1, modeStr,
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "Mean",
         text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 2, f_fmtNum(midas),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

    string dsText = "--"
    color  distCol = color.white
    if not na(sigmaEff) and sigmaEff > 0 and not na(midas)
        float ds = (close - midas) / sigmaEff
        dsText  := (ds >= 0 ? "+" : "") + str.tostring(ds, "0.00") + " sigma"
        distCol := ds > 0.0 ? C_DASH_BULL : ds < 0.0 ? C_DASH_BEAR : color.white
    table.cell(dash, 0, 3, "Distance",
         text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 3, dsText,
         text_color = distCol,     text_size = size.small, text_halign = text.align_right)

    string regText = regime == 1 ? "Up" : regime == -1 ? "Down" : "Flat"
    color  regCol  = regime == 1 ? C_DASH_BULL : regime == -1 ? C_DASH_BEAR : color.white
    table.cell(dash, 0, 4, "Regime",
         text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 4, regText,
         text_color = regCol,      text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Bars in Anchor",
         text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 5, str.tostring(anchorBars),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if i_showLegnd and barstate.islast
    var table leg = table.new(position.bottom_left, 2, 6,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER, border_width = 1,
         frame_color  = C_DASH_BORDER, frame_width  = 1)

    // Header row spans both columns (single merged cell) so "LEGEND" isn't
    // pushed left. Populate both cells first, then merge them into one.
    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_center)
    table.cell(leg, 1, 0, "",
         text_color = C_DASH_BULL, text_size = size.normal)
    table.merge_cells(leg, 0, 0, 1, 0)

    // Legend glyphs use the BRIGHT dashboard palette (C_DASH_*) — chart
    // colours (C_BULL/C_BEAR) are too dark on the dashboard background per
    // standards/color-scheme.md line 206. Glyph is a heavy horizontal bar
    // ▬ at size.normal so it's readable as a line-style swatch, not a dash.
    color legMidCol = regime == 1 ? C_DASH_BULL : regime == -1 ? C_DASH_BEAR : color.white
    table.cell(leg, 0, 1, "▬",
         text_color = legMidCol, text_size = size.normal, text_halign = text.align_center)
    table.cell(leg, 1, 1, "Anchored mean (trend-coloured)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 2, "▬",
         text_color = C_DASH_BEAR, text_size = size.normal, text_halign = text.align_center)
    table.cell(leg, 1, 2, "Upper bands (overextension)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 3, "▬",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_center)
    table.cell(leg, 1, 3, "Lower bands (discount)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    table.cell(leg, 0, 4, "▬",
         text_color = C_DASH_SIGNAL, text_size = size.normal, text_halign = text.align_center)
    table.cell(leg, 1, 4, "HTF confluence mean",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)

    // Spacer row (EXCAVO convention).
    table.cell(leg, 0, 5, "", text_size = size.small)
    table.cell(leg, 1, 5, "", text_size = size.small)

//-----------------------------------------------------------------------------}
// Alerts (directional slope-flip only; no combined helper)
//-----------------------------------------------------------------------------{
bool crossBull = ta.crossover(close, midas)
bool crossBear = ta.crossunder(close, midas)
alertcondition(crossBull, title = "Price Crossed Above Anchored Mean",
     message = "Session Value Ribbon [EXCAVO]: price crossed ABOVE the anchored mean on {{ticker}} ({{interval}})")
alertcondition(crossBear, title = "Price Crossed Below Anchored Mean",
     message = "Session Value Ribbon [EXCAVO]: price crossed BELOW the anchored mean on {{ticker}} ({{interval}})")
````
