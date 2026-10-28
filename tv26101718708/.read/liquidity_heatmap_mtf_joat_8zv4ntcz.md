# Liquidity Heatmap MTF [JOAT]

- url: https://www.tradingview.com/script/8ZV4NtcZ-Liquidity-Heatmap-MTF-JOAT/
- type: indicator
- pine_id: PUB;f7555c279aef4f7091c7e82f2dfd4de9
- version: 1.0

## Description

[b]LIQUIDITY HEATMAP MTF [JOAT][/b]

A weighted multi-timeframe liquidity-zone heatmap that aggregates pivot-based resting liquidity from up to four higher timeframes (1H / 4H / 1D / 1W by default), decays old pivots over a configurable half-life, and projects the resulting hot bins as a right-side colour strip plus optional horizontal lines that extend back across the chart so the key levels are visible on price. Adds an estimated liquidation-level layer on top — the price ranges where leveraged positions get unwound — and warns when price approaches one.

[image]https://www.tradingview.com/x/7sPKZPXF/[/image]

[b]Why MTF aggregation matters[/b]

Single-timeframe liquidity maps miss the structural reality that institutional flow operates on multiple horizons simultaneously. A daily pivot high carries more resting liquidity than a 1H pivot high, but both contribute. Liquidity Heatmap MTF lets you turn on / off each of four timeframes (1H, 4H, 1D, 1W) independently and assign each a [b]weight[/b] so the contribution to the heatmap is proportional to your conviction about how much that timeframe matters.

Defaults:

[list]
[*] 1H weight 1.0×
[*] 4H weight 1.5×
[*] 1D weight 2.5×
[*] 1W weight 4.0× (off by default; enable for macro reads)
[/list]

Pivots are detected in each HTF context using configurable left/right lookbacks. Each pivot contributes intensity proportional to the volume traded on its bar (with optional log compression for instruments that have rare extreme prints).

[b]Decay — half-life modelled[/b]

A pivot from 200 bars ago should not contribute equally to today's heatmap. The script applies an exponential decay:

[i]intensity = volume × exp(−ln(2) × age / halfLife)[/i]

The [b]Decay Half-Life[/b] input (default 180 bars) sets how quickly old pivots fade. After one half-life, an old pivot contributes half as much; after two, a quarter; and so on. This is the principled way to weight history — it never drops contributions discontinuously and it never lets ancient liquidity poison the current read.

[b]Heatmap grid + hot-zone classification[/b]

The price range over the visible lookback (configurable, default 500 bars + 2% padding) is divided into [b]N bins[/b] (default 60, capped at 200 by Pine's max_boxes_count). Each pivot's decayed intensity is accumulated into the bin closest to its level. Bins are then normalised against the hottest bin and any bin above the [b]Hot Zone Threshold[/b] (default 70% of max) is tagged HOT.

The heatmap is rendered as a vertical strip on the right of the chart (configurable width and gap from latest bar) with bins coloured along a deep-ocean blue gradient — cold bins are near-invisible (transparency floor), hot bins are vivid cyan.

[b]Hot-zone projection across chart (JOAT enhancement)[/b]

This is the headline visual: the top hot bins are projected back across the chart as [b]horizontal lines[/b] (configurable count, default 5) with price labels, extending back a configurable number of bars (default 120). So you do not just see the heatmap as a right-side strip — you see the key levels [i]on[/i] the chart at the price levels they actually occupy. Toggleable.

[b]Estimated liquidation levels (the second layer)[/b]

On top of the liquidity heatmap, an optional liquidation layer estimates where leveraged positions get stopped out. Each significant HTF pivot extreme gets a projected liquidation level at:

[i]liq_level = pivot ± (ATR × liqPad)[/i]

Configurable [b]liqPad[/b] (default 0.5 ATR). Configurable caps on liquidation lines above (default 4) and below (default 4) the current price. Lines extend right by a configurable bar count. When price comes within [b]liqAtrMult × ATR[/b] of a liquidation line, the [b]!LIQ[/b] alert fires and the line is rendered in the accent colour (the only off-family colour in the palette — bright orange).

The liquidation logic is intentionally conservative — pivots provide the structural anchor; the ATR pad is the only configurable variable; lines are capped to avoid clutter.

[image]https://www.tradingview.com/x/UwZ4L9EZ/[/image]

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Active timeframes and their weights.
[*] Total pivots tracked.
[*] Hottest bin price and intensity %.
[*] Hot-zone count.
[*] Liquidation lines above / below current price counts.
[*] Distance (in ATR units) to nearest liquidation line.
[*] Last hot-zone activation with bar-age.
[/list]

[b]Visual system[/b]

[list]
[*] Heat strip (toggleable width / gap / transparency).
[*] HOT tags on hottest bins (toggleable).
[*] Optional strip border.
[*] Horizontal hot-zone lines extending back across the chart (toggleable, capped, configurable length).
[*] Liquidation level lines above and below (toggleable, capped).
[*] LIQ labels (toggleable).
[/list]

A locked Deep Ocean palette (bathypelagic blue gradient on near-black, with the bright orange #FF6B00 reserved exclusively for liquidation warnings) gives the chart a distinct institutional liquidity-map identity.

[b]Alerts[/b]

Three alert conditions, each independently controllable, each cooldown-gated:

[list]
[*] [b]Hot Zone Activated[/b] — fires when a new bin crosses the hot threshold.
[*] [b]Approaching Liq Level[/b] — fires when price comes within liqAtrMult × ATR of a liquidation line.
[*] [b]New HTF Pivot Added[/b] — fires when a new HTF pivot is detected and added to the cache.
[/list]

A configurable cooldown (default 8 bars) prevents back-to-back alert spam.

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Approaching Liq Level alert[/b] — the most actionable single signal. Price is within striking distance of estimated leveraged-position stop-out levels. Liquidations tend to be self-fulfilling on the way in (cascade through stops) and exhaustive at the extreme (no more sellers / buyers left after the cascade).
[*] [b]Multi-timeframe hot zone[/b] — when a hot bin is contributed to by more than one HTF, it is by definition more significant. The hot line projections show you which levels are MTF-confluent.
[*] [b]New HTF Pivot in 1D or 1W context[/b] — these are the slowest-moving structural events. A new daily or weekly pivot reshapes the heatmap meaningfully.
[/list]

[b]Suggested settings[/b]

Defaults (1H/4H/1D enabled, weights 1.0/1.5/2.5, decay half-life 180, hot threshold 70%) are tuned for intraday-to-swing trading on liquid futures, FX, and crypto. For pure scalping, disable 1D / 1W and raise 1H weight. For pure macro, enable 1W and raise its weight; reduce 1H to 0.5×. The liqPad default 0.5× ATR is conservative — raise to 1.0× for more cautious liquidation projections.

[b]Originality[/b]

The implementation — the MTF pivot aggregation pipeline with per-TF weights, the exponential half-life decay model, the bin-grid heatmap with hot-zone threshold, the cross-chart hot-line projection layer, the ATR-based liquidation level estimator with above/below caps, the cooldown-gated multi-alert engine, and the deep-ocean palette with the orange liquidation accent — is JOAT-original. No third-party code reused. The "liquidity map" concept comes from professional desks; the implementation here is purpose-built for Pine v6 with bar data only.

[b]Limitations[/b]

Estimated liquidation levels are an [i]inference[/i] from pivots and ATR — Pine cannot read actual leverage data or aggregated futures funding/open-interest. The lines mark where stop clusters are statistically likely to sit, not where they actually do. Pine's max_boxes_count caps the grid at 200 bins; the script clamps to 200 max even though the input allows higher requests. MTF pivots use request.security in non-lookahead mode, so they are non-repainting once confirmed at their HTF.

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Liquidity Heatmap MTF [JOAT]", shorttitle="LHM [JOAT]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)


// =====================================================================================================
//  SECTION 1 - INPUTS
//  Grouped by responsibility. Box-drawing chars used as group headers per the JOAT house style.
// =====================================================================================================

string grpTF      = "===== Multi-Timeframe Sources ====="
string grpBins    = "===== Heatmap Grid ====="
string grpDecay   = "===== Decay & Weighting ====="
string grpThresh  = "===== Thresholds & Detection ====="
string grpVis     = "===== Visuals ====="
string grpLiq     = "===== Liquidation Levels ====="
string grpDash    = "===== Dashboard ====="
string grpAlerts  = "===== Alerts ====="

// --- Multi-Timeframe Sources ---
bool   useTF1     = input.bool(true,  "Use 1H",     group=grpTF, inline="tf1")
string tf1Code    = input.timeframe("60",   "TF1 Code",  group=grpTF, inline="tf1")
float  tf1Weight  = input.float(1.0, "Weight 1H",  minval=0.0, maxval=10.0, step=0.1, group=grpTF, inline="tf1w")

bool   useTF2     = input.bool(true,  "Use 4H",     group=grpTF, inline="tf2")
string tf2Code    = input.timeframe("240",  "TF2 Code",  group=grpTF, inline="tf2")
float  tf2Weight  = input.float(1.5, "Weight 4H",  minval=0.0, maxval=10.0, step=0.1, group=grpTF, inline="tf2w")

bool   useTF3     = input.bool(true,  "Use 1D",     group=grpTF, inline="tf3")
string tf3Code    = input.timeframe("D",    "TF3 Code",  group=grpTF, inline="tf3")
float  tf3Weight  = input.float(2.5, "Weight 1D",  minval=0.0, maxval=10.0, step=0.1, group=grpTF, inline="tf3w")

bool   useTF4     = input.bool(false, "Use 1W",     group=grpTF, inline="tf4")
string tf4Code    = input.timeframe("W",    "TF4 Code",  group=grpTF, inline="tf4")
float  tf4Weight  = input.float(4.0, "Weight 1W",  minval=0.0, maxval=10.0, step=0.1, group=grpTF, inline="tf4w")

int    pivLeft    = input.int(5, "HTF Pivot Left",  minval=1, maxval=50, group=grpTF, tooltip="Bars to the left of the pivot candidate that must be lower (highs) / higher (lows). Evaluated in the HTF context.")
int    pivRight   = input.int(5, "HTF Pivot Right", minval=1, maxval=50, group=grpTF, tooltip="Bars to the right of the pivot candidate that must be lower (highs) / higher (lows). Evaluated in the HTF context.")

// --- Heatmap Grid ---
int    binCount   = input.int(60, "Bin Count", minval=10, maxval=200, group=grpBins, tooltip="Number of horizontal price slices. More bins = finer detail but heavier rendering. Capped to 200 to respect max_boxes_count.")
int    rangeLB    = input.int(500, "Range Lookback (bars)", minval=50, maxval=5000, group=grpBins, tooltip="How many chart bars to scan when computing the price range of the grid (highest high / lowest low).")
float  rangePad   = input.float(0.02, "Range Padding (%)", minval=0.0, maxval=0.5, step=0.005, group=grpBins, tooltip="Expand the high/low range by this fraction so edge bins still have room.")
int    stripWidth = input.int(60, "Heat Strip Width (bars)", minval=10, maxval=500, group=grpBins, tooltip="Width of the heat panel in bars to the right of the latest bar.")
int    stripGap   = input.int(2,  "Strip Gap (bars)", minval=0, maxval=20, group=grpBins, tooltip="Gap between the latest bar and the start of the heat panel.")

// --- Decay & Weighting ---
float  decayHalf  = input.float(180.0, "Decay Half-Life (bars)", minval=10.0, maxval=2000.0, step=10.0, group=grpDecay, tooltip="Half-life of pivot intensity. After this many bars, the contribution of an old pivot is halved. Uses intensity * exp(-ln(2) * age / halfLife).")
float  volNorm    = input.float(1.0, "Volume Normalization", minval=0.1, maxval=10.0, step=0.1, group=grpDecay, tooltip="Scales raw HTF volume before accumulation. Useful for symbols where volume is in odd units.")
bool   useLog     = input.bool(false, "Use Log Volume", group=grpDecay, tooltip="Apply log1p() to volume before accumulating. Compresses outliers, useful for stocks with rare extreme prints.")

// --- Thresholds & Detection ---
float  hotPct     = input.float(70.0, "Hot Zone Threshold (% of max)", minval=10.0, maxval=99.0, step=1.0, group=grpThresh, tooltip="Bins whose intensity exceeds this percentage of the hottest bin are tagged HOT.")
float  liqAtrMult = input.float(0.5,  "Sweep Risk ATR Mult", minval=0.1, maxval=5.0, step=0.1, group=grpThresh, tooltip="If price is within ATR * this multiplier of an estimated liquidation level, a !LIQ warning fires.")
int    atrLen     = input.int(14, "ATR Length", minval=2, maxval=200, group=grpThresh)
int    cooldownB  = input.int(8, "Alert Cooldown (bars)", minval=0, maxval=200, group=grpThresh, tooltip="Minimum bars between consecutive HOT / LIQ alerts to prevent spam.")

// --- Visuals ---
int    baseTransp = input.int(35, "Base Transparency", minval=0, maxval=95, group=grpVis, tooltip="Alpha of the heat strips. 0 = solid, 95 = nearly invisible.")
int    fadeTransp = input.int(85, "Cool-Bin Transparency", minval=0, maxval=99, group=grpVis, tooltip="Transparency floor for cold bins. Hot bins use baseTransp.")
bool   showStrips = input.bool(true, "Show Heat Strips", group=grpVis)
bool   showHotTag = input.bool(true, "Show HOT Tags", group=grpVis)
bool   showBorder = input.bool(false, "Show Strip Border", group=grpVis)
bool   showHotLines = input.bool(true, "Project Hot Zones Across Chart", group=grpVis, tooltip="Draws horizontal lines + price labels at the top hot liquidity zones extending back across the candles, so the key levels are visible on the chart itself.")
int    maxHotLines  = input.int(5, "Max Hot Zone Lines", minval=1, maxval=20, group=grpVis, tooltip="Caps the number of horizontal hot lines drawn across the chart.")
int    hotLineBack  = input.int(120, "Hot Zone Line Length (bars back)", minval=20, maxval=1000, group=grpVis, tooltip="How many bars back the hot zone lines reach from the heat strip.")

// --- Liquidation Levels ---
bool   showLiq    = input.bool(true,  "Show Liq Levels", group=grpLiq)
float  liqPad     = input.float(0.5, "Liq Pad ATR Mult", minval=0.0, maxval=5.0, step=0.1, group=grpLiq, tooltip="Estimated liquidation level = pivot extreme +/- (ATR * this multiplier). Higher = further past the pivot.")
int    maxLiqAbv  = input.int(4, "Max Liq Levels Above", minval=1, maxval=20, group=grpLiq)
int    maxLiqBlw  = input.int(4, "Max Liq Levels Below", minval=1, maxval=20, group=grpLiq)
int    liqExtend  = input.int(80, "Liq Line Extend (bars)", minval=5, maxval=500, group=grpLiq)
bool   showLiqLab = input.bool(true, "Show LIQ Labels", group=grpLiq)

// --- Dashboard ---
bool   showDash   = input.bool(true, "Show Dashboard", group=grpDash)
string dashPos    = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"], group=grpDash)
string dashSize   = input.string("Small", "Dashboard Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)

// --- Alerts ---
bool   alertHot   = input.bool(true, "Alert: Hot Zone Activated", group=grpAlerts)
bool   alertLiq   = input.bool(true, "Alert: Approaching Liq Level", group=grpAlerts)
bool   alertNewP  = input.bool(true, "Alert: New HTF Pivot Added", group=grpAlerts)


// =====================================================================================================
//  SECTION 2 - CURATED DEEP OCEAN PALETTE + GRADIENT STOPS
//  Single locked bathypelagic blue ramp. Bull / bear share the ocean family
//  intentionally. Liquidation warnings get the only off-family accent (#FF6B00).
// =====================================================================================================

var array<color> heatStops = array.from(
     color.new(#00040D, 0),
     color.new(#002862, 0),
     color.new(#0072C0, 0),
     color.new(#00BCE8, 0),
     color.new(#00E4FF, 0),
     color.new(#80FFFF, 0))

color accentCol = #FF6B00              // liquidation warning accent (only off-family color)
color C_BG      = #00040D
color C_FRAME   = #0A1F3D
color C_TEXT    = color.new(color.white, 0)
color C_MUTED   = color.new(color.gray, 30)
color C_HOT     = #00E4FF
color C_LIQ_UP  = color.new(#FF6B00, 10)
color C_LIQ_DN  = color.new(#00BCE8, 10)


// =====================================================================================================
//  SECTION 3 - HELPER FUNCTIONS
//  Pure utilities. All re-used helpers from the JOAT KB are centralized here so the rest of the
//  script reads as orchestration rather than math.
// =====================================================================================================

// 3.1 -- Two-color linear interpolation in RGB space.
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// 3.2 -- Multi-stop gradient (N stops). ratio in [0,1].
f_gradientMulti(float ratio, array<color> stops) =>
    n = array.size(stops) - 1
    color out = na
    if n < 1
        out := color.new(color.gray, 0)
    else
        float r = math.max(0.0, math.min(1.0, ratio))
        float pos = r * n
        int idx = math.min(n - 1, math.max(0, int(pos)))
        float local = pos - idx
        out := f_colorGradient(local, array.get(stops, idx), array.get(stops, idx + 1))
    out

// 3.3 -- Clamp helper.
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// 3.4 -- String to position enum.
f_strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// 3.5 -- String to text size enum.
f_strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// 3.6 -- Volume formatter (k/M/B).
f_formatVolume(float v) =>
    string s = ""
    if na(v) or v == 0.0
        s := "0"
    else if v >= 1e9
        s := str.tostring(v / 1e9, "#.##") + "B"
    else if v >= 1e6
        s := str.tostring(v / 1e6, "#.##") + "M"
    else if v >= 1e3
        s := str.tostring(v / 1e3, "#.##") + "K"
    else
        s := str.tostring(v, "#.##")
    s

// 3.7 -- Log1p (compress outliers).
f_log1p(float v) => v <= 0.0 ? 0.0 : math.log(1.0 + v)

// 3.8 -- Exp decay factor from age and half-life.
f_decay(float age, float halfLife) =>
    halfLife <= 0.0 ? 1.0 : math.exp(-math.log(2.0) * math.max(age, 0.0) / halfLife)

// 3.9 -- Compute the bin index of a price within [lo, hi] subdivided into nBins.
f_binOf(float price, float lo, float hi, int nBins) =>
    int idx = -1
    if not na(price) and hi > lo and nBins > 0
        float ratio = (price - lo) / (hi - lo)
        if ratio >= 0.0 and ratio <= 1.0
            idx := math.min(nBins - 1, math.max(0, int(ratio * nBins)))
    idx

// 3.10 -- Compute the center price of a bin index.
f_binPrice(int idx, float lo, float hi, int nBins) =>
    float p = na
    if nBins > 0 and hi > lo and idx >= 0 and idx < nBins
        float binSize = (hi - lo) / nBins
        p := lo + binSize * (idx + 0.5)
    p

// 3.11 -- Safe bar guard (avoid drawing past max_bars_back).
f_safeBar(int b) =>
    int minSafe = bar_index - 4900
    b < minSafe ? minSafe : b

// 3.12 -- Format a TF code into a friendly short string.
f_tfShort(string code) =>
    switch code
        "60"  => "1H"
        "240" => "4H"
        "D"   => "1D"
        "W"   => "1W"
        => code


// =====================================================================================================
//  SECTION 4 - MTF DATA FETCH + PIVOT EXTRACTION
//  Per TF we request a tuple: [pivotHigh, pivotLow, volume]. Evaluating ta.pivothigh/low INSIDE the
//  request.security() expression means the pivot is detected ON the higher timeframe (correctly),
//  not on the chart timeframe with re-binned data. lookahead defaults to off; no future leak.
// =====================================================================================================

// Each tuple is non-na ONLY on the HTF bar where a pivot was confirmed; on every other chart bar
// the values are na. That makes downstream binning trivial: we only push when not na.
[ph1, pl1, vh1, vl1] = request.security(syminfo.tickerid, tf1Code, [ta.pivothigh(high, pivLeft, pivRight), ta.pivotlow(low, pivLeft, pivRight), volume[pivRight], volume[pivRight]])
[ph2, pl2, vh2, vl2] = request.security(syminfo.tickerid, tf2Code, [ta.pivothigh(high, pivLeft, pivRight), ta.pivotlow(low, pivLeft, pivRight), volume[pivRight], volume[pivRight]])
[ph3, pl3, vh3, vl3] = request.security(syminfo.tickerid, tf3Code, [ta.pivothigh(high, pivLeft, pivRight), ta.pivotlow(low, pivLeft, pivRight), volume[pivRight], volume[pivRight]])
[ph4, pl4, vh4, vl4] = request.security(syminfo.tickerid, tf4Code, [ta.pivothigh(high, pivLeft, pivRight), ta.pivotlow(low, pivLeft, pivRight), volume[pivRight], volume[pivRight]])


// =====================================================================================================
//  SECTION 5 - STATE (PIVOT EVENT BUFFER + BIN GRID)
//  We keep a rolling list of pivot events (price, volume, sourceTf, weight, eventBar) and rebuild
//  the bin grid on the last bar. This separation lets the user re-tune binCount / decayHalf without
//  having to maintain a parallel set of per-bin var arrays for every TF.
// =====================================================================================================

type PivotEvent
    float price
    float vol
    int   eventBar
    int   srcTf       // 1..4
    bool  isHigh
    float weight

var array<PivotEvent> events = array.new<PivotEvent>()
var array<float>      binIntensity = array.new<float>()
var array<int>        binPivotCount = array.new<int>()

// Track last alerts to enforce cooldown.
var int lastHotBar = -10000
var int lastLiqBar = -10000
var int lastPivBar = -10000

// Memory cap on the event buffer. Picked so the worst-case 4-TF stream is sustainable for years.
int MAX_EVENTS = 1500

// Helper: push a new event, shift the oldest when full.
f_pushEvent(float p, float v, int tfIdx, bool isHigh, float weight) =>
    if not na(p) and p > 0.0
        float safeVol = (na(v) or v <= 0.0) ? 0.0 : (useLog ? f_log1p(v * volNorm) : v * volNorm)
        PivotEvent ev = PivotEvent.new(price=p, vol=safeVol, eventBar=bar_index, srcTf=tfIdx, isHigh=isHigh, weight=weight)
        array.push(events, ev)
        while array.size(events) > MAX_EVENTS
            array.shift(events)


// =====================================================================================================
//  SECTION 6 - INTENSITY CALCULATION + DECAY + GRID BUILD
//  On every confirmed bar we push any newly-arrived HTF pivots. On the last bar we rebuild the bin
//  grid from scratch (cheap: events << bar_index, ~hundreds). For each event we apply the
//  exponential age decay and TF weight, then accumulate into the bin holding its price.
// =====================================================================================================

// 6.1 -- Push new events for the current bar (one per active TF that confirmed a pivot this chart bar).
bool addedThisBar = false

if barstate.isconfirmed
    if useTF1
        if not na(ph1)
            f_pushEvent(ph1, vh1, 1, true,  tf1Weight)
            addedThisBar := true
        if not na(pl1)
            f_pushEvent(pl1, vl1, 1, false, tf1Weight)
            addedThisBar := true
    if useTF2
        if not na(ph2)
            f_pushEvent(ph2, vh2, 2, true,  tf2Weight)
            addedThisBar := true
        if not na(pl2)
            f_pushEvent(pl2, vl2, 2, false, tf2Weight)
            addedThisBar := true
    if useTF3
        if not na(ph3)
            f_pushEvent(ph3, vh3, 3, true,  tf3Weight)
            addedThisBar := true
        if not na(pl3)
            f_pushEvent(pl3, vl3, 3, false, tf3Weight)
            addedThisBar := true
    if useTF4
        if not na(ph4)
            f_pushEvent(ph4, vh4, 4, true,  tf4Weight)
            addedThisBar := true
        if not na(pl4)
            f_pushEvent(pl4, vl4, 4, false, tf4Weight)
            addedThisBar := true

// 6.2 -- Grid range (compute lazily on last bar). We use the rolling highest/lowest of the chart
//        across rangeLB bars, padded by rangePad.
float rawHi = ta.highest(high, math.min(rangeLB, bar_index + 1))
float rawLo = ta.lowest(low,   math.min(rangeLB, bar_index + 1))
float padAmt = (rawHi - rawLo) * rangePad
float gridHi = rawHi + padAmt
float gridLo = math.max(0.0, rawLo - padAmt)

// 6.3 -- Rebuild the bin grid on the last bar only.
float maxIntensity = 0.0
int   maxBinIdx    = -1
int   activeEvents = 0

if barstate.islast
    // (re)size accumulators
    if array.size(binIntensity) != binCount
        array.clear(binIntensity)
        array.clear(binPivotCount)
        for i = 0 to binCount - 1
            array.push(binIntensity, 0.0)
            array.push(binPivotCount, 0)
    else
        for i = 0 to binCount - 1
            array.set(binIntensity, i, 0.0)
            array.set(binPivotCount, i, 0)

    // accumulate decayed weighted volume into bins
    int nEv = array.size(events)
    for i = 0 to nEv - 1
        PivotEvent ev = array.get(events, i)
        if not na(ev.price)
            int bIdx = f_binOf(ev.price, gridLo, gridHi, binCount)
            if bIdx >= 0
                float age = math.max(0.0, float(bar_index - ev.eventBar))
                float dec = f_decay(age, decayHalf)
                float contribution = ev.vol * ev.weight * dec
                if contribution > 0.0
                    array.set(binIntensity, bIdx, array.get(binIntensity, bIdx) + contribution)
                    array.set(binPivotCount, bIdx, array.get(binPivotCount, bIdx) + 1)
                    activeEvents += 1

    // identify the hottest bin
    for i = 0 to binCount - 1
        float v = array.get(binIntensity, i)
        if v > maxIntensity
            maxIntensity := v
            maxBinIdx := i


// =====================================================================================================
//  SECTION 7 - RENDERING: HEAT STRIPS VIA BOX.NEW
//  All boxes are deleted and rebuilt on the last bar (one-shot pattern). Each bin becomes a single
//  semi-transparent horizontal box spanning [bar_index + stripGap .. bar_index + stripGap + stripWidth].
//  Color = f_gradientMulti(intensityRatio, heatStops). Transparency interpolates between fadeTransp
//  (cold) and baseTransp (hot) so cold bins disappear into the chart.
// =====================================================================================================

var array<box>   heatBoxes = array.new<box>()
var array<label> heatLabels = array.new<label>()
var array<line>  heatLines = array.new<line>()

f_clearHeat() =>
    int nB = array.size(heatBoxes)
    if nB > 0
        for i = 0 to nB - 1
            box.delete(array.get(heatBoxes, i))
    array.clear(heatBoxes)
    int nL = array.size(heatLabels)
    if nL > 0
        for i = 0 to nL - 1
            label.delete(array.get(heatLabels, i))
    array.clear(heatLabels)
    int nLn = array.size(heatLines)
    if nLn > 0
        for i = 0 to nLn - 1
            line.delete(array.get(heatLines, i))
    array.clear(heatLines)

if barstate.islast and showStrips and binCount > 0 and gridHi > gridLo
    f_clearHeat()
    int leftBar  = bar_index + stripGap
    int rightBar = bar_index + stripGap + stripWidth
    float binSize = (gridHi - gridLo) / binCount

    // pre-compute hotness threshold (raw intensity)
    float hotAbs = maxIntensity * (hotPct / 100.0)

    for i = 0 to binCount - 1
        float intens = array.get(binIntensity, i)
        if intens > 0.0 and maxIntensity > 0.0
            float ratio = f_clamp(intens / maxIntensity, 0.0, 1.0)
            color baseC = f_gradientMulti(ratio, heatStops)
            // transparency that scales: cold bins are nearly invisible, hot bins use baseTransp
            int alpha = int(math.round(fadeTransp - (fadeTransp - baseTransp) * ratio))
            alpha := math.max(0, math.min(99, alpha))
            color cellC = color.new(baseC, alpha)
            float yLo = gridLo + binSize * i
            float yHi = yLo + binSize
            box bx = box.new(left=leftBar, top=yHi, right=rightBar, bottom=yLo, bgcolor=cellC, border_color=showBorder ? color.new(baseC, math.max(50, alpha)) : na, border_width=showBorder ? 1 : 0, xloc=xloc.bar_index)
            array.push(heatBoxes, bx)

    // ------------------------------------------------------------------
    // Project the top hot zones ACROSS the chart as horizontal lines
    // with price + intensity labels.  Cap at maxHotLines to stay clean.
    // ------------------------------------------------------------------
    if showHotLines
        int hotLineLeftBar = bar_index - hotLineBack
        int rightAnchor    = leftBar - 1
        int placed         = 0
        // Walk bins ordered by intensity (greedy: scan whole grid each round)
        // by snapshotting and zeroing the picked bin; cheap because binCount <= 200.
        array<float> tmpIntens = array.copy(binIntensity)
        while placed < maxHotLines
            float bestIntens = 0.0
            int   bestIdx    = -1
            for k = 0 to binCount - 1
                float v = array.get(tmpIntens, k)
                if v > bestIntens
                    bestIntens := v
                    bestIdx    := k
            if bestIdx < 0 or bestIntens < hotAbs or maxIntensity <= 0.0
                break
            array.set(tmpIntens, bestIdx, 0.0)
            float hRatio = f_clamp(bestIntens / maxIntensity, 0.0, 1.0)
            color hBase  = f_gradientMulti(hRatio, heatStops)
            float hLo    = gridLo + binSize * bestIdx
            float hHi    = hLo + binSize
            float hMid   = (hLo + hHi) / 2.0
            // Horizontal line across the chart at this hot price level
            line hLn = line.new(hotLineLeftBar, hMid, rightAnchor, hMid,
                 color = color.new(hBase, 25),
                 style = bestIdx == maxBinIdx ? line.style_solid : line.style_dashed,
                 width = bestIdx == maxBinIdx ? 2 : 1,
                 xloc  = xloc.bar_index)
            array.push(heatLines, hLn)
            // Label on the left side of the strip showing price + %
            string hTxt = (bestIdx == maxBinIdx ? "HOTTEST " : "HOT ") + str.tostring(hMid, format.mintick) + "  " + str.tostring(hRatio * 100.0, "#") + "%"
            label hLb = label.new(rightAnchor, hMid, text = hTxt,
                 style     = label.style_label_left,
                 color     = color.new(hBase, 15),
                 textcolor = color.white,
                 size      = bestIdx == maxBinIdx ? size.small : size.tiny,
                 xloc      = xloc.bar_index)
            array.push(heatLabels, hLb)
            placed += 1

            // Original right-edge HOT tag only for the absolute max bin
            if showHotTag and bestIdx == maxBinIdx
                label rb = label.new(rightBar + 2, hMid, text="HOT", style=label.style_label_left, color=color.new(C_HOT, 20), textcolor=color.white, size=size.tiny, xloc=xloc.bar_index)
                array.push(heatLabels, rb)


// =====================================================================================================
//  SECTION 8 - LIQUIDATION LEVEL MARKERS + HOT / LIQ LABELS
//  Estimated liq levels are pivot extremes pushed outward by ATR * liqPad. We rank the most recent
//  pivot highs ABOVE current price and the most recent pivot lows BELOW current price, then draw
//  thin solid lines from a few bars back to liqExtend bars into the future. If price approaches a
//  liq level within ATR * liqAtrMult, a !LIQ warning label is placed at the current bar.
// =====================================================================================================

var array<line>  liqLines  = array.new<line>()
var array<label> liqLabels = array.new<label>()

f_clearLiq() =>
    int nL = array.size(liqLines)
    if nL > 0
        for i = 0 to nL - 1
            line.delete(array.get(liqLines, i))
    array.clear(liqLines)
    int nLb = array.size(liqLabels)
    if nLb > 0
        for i = 0 to nLb - 1
            label.delete(array.get(liqLabels, i))
    array.clear(liqLabels)

float atr = ta.atr(atrLen)
float nearestLiqAbove = na
float nearestLiqBelow = na
bool  sweepRiskAbove  = false
bool  sweepRiskBelow  = false

if barstate.islast and showLiq
    f_clearLiq()
    int leftBar  = bar_index - 3
    int rightBar = bar_index + liqExtend

    // Gather pivot-high and pivot-low events separately, most recent first.
    array<float> highsAbove = array.new<float>()
    array<int>   highsBars  = array.new<int>()
    array<float> lowsBelow  = array.new<float>()
    array<int>   lowsBars   = array.new<int>()

    int nEv = array.size(events)
    if nEv > 0
        // iterate newest -> oldest so we get the most recent pivots first
        for k = 0 to nEv - 1
            int i = nEv - 1 - k
            PivotEvent ev = array.get(events, i)
            float liqPrice = ev.isHigh ? ev.price + atr * liqPad : ev.price - atr * liqPad
            if ev.isHigh and liqPrice > close
                if array.size(highsAbove) < maxLiqAbv
                    array.push(highsAbove, liqPrice)
                    array.push(highsBars,  ev.eventBar)
            if (not ev.isHigh) and liqPrice < close
                if array.size(lowsBelow) < maxLiqBlw
                    array.push(lowsBelow,  liqPrice)
                    array.push(lowsBars,   ev.eventBar)

    // draw above levels
    int nA = array.size(highsAbove)
    if nA > 0
        nearestLiqAbove := array.get(highsAbove, 0)
        for i = 0 to nA - 1
            float lp = array.get(highsAbove, i)
            line ln = line.new(x1=leftBar, y1=lp, x2=rightBar, y2=lp, color=C_LIQ_UP, style=line.style_solid, width=1, xloc=xloc.bar_index)
            array.push(liqLines, ln)
            if showLiqLab
                label lb = label.new(rightBar, lp, text="LIQ " + str.tostring(lp, format.mintick), style=label.style_label_left, color=color.new(C_LIQ_UP, 60), textcolor=color.white, size=size.tiny, xloc=xloc.bar_index)
                array.push(liqLabels, lb)
            if not na(lp) and math.abs(lp - close) <= atr * liqAtrMult
                sweepRiskAbove := true

    // draw below levels
    int nB = array.size(lowsBelow)
    if nB > 0
        nearestLiqBelow := array.get(lowsBelow, 0)
        for i = 0 to nB - 1
            float lp = array.get(lowsBelow, i)
            line ln = line.new(x1=leftBar, y1=lp, x2=rightBar, y2=lp, color=C_LIQ_DN, style=line.style_solid, width=1, xloc=xloc.bar_index)
            array.push(liqLines, ln)
            if showLiqLab
                label lb = label.new(rightBar, lp, text="LIQ " + str.tostring(lp, format.mintick), style=label.style_label_left, color=color.new(C_LIQ_DN, 60), textcolor=color.white, size=size.tiny, xloc=xloc.bar_index)
                array.push(liqLabels, lb)
            if not na(lp) and math.abs(close - lp) <= atr * liqAtrMult
                sweepRiskBelow := true

    // emit a !LIQ warning at the current bar if either side is in the danger zone
    if sweepRiskAbove and not na(nearestLiqAbove)
        label warnUp = label.new(bar_index, nearestLiqAbove, text="! LIQ", style=label.style_label_down, color=color.new(C_LIQ_UP, 0), textcolor=color.white, size=size.small, xloc=xloc.bar_index)
        array.push(liqLabels, warnUp)
    if sweepRiskBelow and not na(nearestLiqBelow)
        label warnDn = label.new(bar_index, nearestLiqBelow, text="! LIQ", style=label.style_label_up, color=color.new(C_LIQ_DN, 0), textcolor=color.white, size=size.small, xloc=xloc.bar_index)
        array.push(liqLabels, warnDn)


// =====================================================================================================
//  SECTION 9 - DASHBOARD
//  9-row metrics panel summarising: active TFs, total bins, hottest level, nearest liq above and
//  below, decay half-life, threshold, and a suggested JOAT companion indicator based on whether a
//  hot zone or sweep risk is currently active.
// =====================================================================================================

f_activeTfs() =>
    string s = ""
    if useTF1
        s += f_tfShort(tf1Code)
    if useTF2
        s += (s == "" ? "" : "+") + f_tfShort(tf2Code)
    if useTF3
        s += (s == "" ? "" : "+") + f_tfShort(tf3Code)
    if useTF4
        s += (s == "" ? "" : "+") + f_tfShort(tf4Code)
    s == "" ? "none" : s

f_suggestedJoat(bool hot, bool liq) =>
    string s = "LRB [JOAT]"
    if liq
        s := "Stop Hunt Magnet [JOAT]"
    else if hot
        s := "Volume Profile MTF [JOAT]"
    s

var table dash = na

if showDash
    if na(dash)
        dash := table.new(f_strToPos(dashPos), 2, 10, bgcolor=C_BG, frame_color=C_FRAME, frame_width=1, border_color=color.new(C_FRAME, 65), border_width=1)

if showDash and barstate.islast
    table.clear(dash, 0, 0, 1, 9)
    color hdrBg = color.new(accentCol, 30)
    color rowBg = color.new(color.black, 88)
    string sz   = dashSize

    // row 0: header
    table.cell(dash, 0, 0, "LIQUIDITY HEATMAP MTF", text_color=C_TEXT, bgcolor=hdrBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 0, "[JOAT]",                text_color=C_TEXT, bgcolor=hdrBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 1: active TFs
    table.cell(dash, 0, 1, "Active TFs",  text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 1, f_activeTfs(), text_color=color.new(accentCol, 0), bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 2: total bins
    table.cell(dash, 0, 2, "Total Bins", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 2, str.tostring(binCount), text_color=C_TEXT, bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 3: hottest level + intensity %
    string hotStr = "n/a"
    if maxBinIdx >= 0 and maxIntensity > 0.0
        float hp = f_binPrice(maxBinIdx, gridLo, gridHi, binCount)
        hotStr := str.tostring(hp, format.mintick) + "  100%"
    table.cell(dash, 0, 3, "Hottest Level", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 3, hotStr, text_color=color.new(accentCol, 0), bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 4: nearest liq above
    string nlaStr = na(nearestLiqAbove) ? "n/a" : str.tostring(nearestLiqAbove, format.mintick) + " (" + str.tostring((nearestLiqAbove - close) / close * 100.0, "#.##") + "%)"
    table.cell(dash, 0, 4, "Nearest Liq Above", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 4, nlaStr, text_color=accentCol, bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 5: nearest liq below
    string nlbStr = na(nearestLiqBelow) ? "n/a" : str.tostring(nearestLiqBelow, format.mintick) + " (" + str.tostring((nearestLiqBelow - close) / close * 100.0, "#.##") + "%)"
    table.cell(dash, 0, 5, "Nearest Liq Below", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 5, nlbStr, text_color=C_HOT, bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 6: decay half-life
    table.cell(dash, 0, 6, "Decay Half-Life", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 6, str.tostring(decayHalf, "#") + " bars", text_color=C_TEXT, bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 7: hot threshold
    table.cell(dash, 0, 7, "Hot Threshold", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 7, str.tostring(hotPct, "#") + "%", text_color=C_TEXT, bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 8: events buffer size
    table.cell(dash, 0, 8, "Pivot Events", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 8, str.tostring(array.size(events)) + " / " + str.tostring(MAX_EVENTS), text_color=C_MUTED, bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))

    // row 9: suggested JOAT companion
    bool curHot  = maxIntensity > 0.0
    bool curLiq  = sweepRiskAbove or sweepRiskBelow
    table.cell(dash, 0, 9, "Suggested JOAT", text_color=C_TEXT, bgcolor=rowBg, text_font_family=font.family_monospace, text_size=f_strToSize(sz))
    table.cell(dash, 1, 9, f_suggestedJoat(curHot, curLiq), text_color=color.new(accentCol, 0), bgcolor=rowBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=f_strToSize(sz))


// =====================================================================================================
//  SECTION 10 - ALERTS
//  Three alert conditions with cooldown debouncing so a single hot zone or liq approach does not
//  spam dozens of fires per session.
// =====================================================================================================

// 10.1 -- Hot zone activated: fire once when the hottest bin first crosses hotPct % of self (i.e.
//         a new max bin has emerged that is distinctly hotter than any previous max). Cooldown applies.
bool hotZoneActive = barstate.islast and maxBinIdx >= 0 and maxIntensity > 0.0

// 10.2 -- Approaching liq: any side within ATR * liqAtrMult of a level.
bool approachingLiq = barstate.islast and (sweepRiskAbove or sweepRiskBelow)

// 10.3 -- New HTF pivot pushed this bar.
bool newPivot = barstate.isconfirmed and addedThisBar

// debounce
bool canHot = (bar_index - lastHotBar) >= cooldownB
bool canLiq = (bar_index - lastLiqBar) >= cooldownB
bool canPiv = (bar_index - lastPivBar) >= cooldownB

if alertHot and hotZoneActive and canHot
    alert("LHM [JOAT] Hot Zone Activated at " + str.tostring(f_binPrice(maxBinIdx, gridLo, gridHi, binCount), format.mintick), alert.freq_once_per_bar)
    lastHotBar := bar_index

if alertLiq and approachingLiq and canLiq
    string side = sweepRiskAbove ? "above" : "below"
    float refPrice = sweepRiskAbove ? nearestLiqAbove : nearestLiqBelow
    alert("LHM [JOAT] Approaching Liq " + side + " at " + str.tostring(refPrice, format.mintick), alert.freq_once_per_bar)
    lastLiqBar := bar_index

if alertNewP and newPivot and canPiv
    alert("LHM [JOAT] New HTF pivot added to heatmap", alert.freq_once_per_bar)
    lastPivBar := bar_index

// Native alertcondition() entries so users can also wire these via the UI without using alert().
alertcondition(hotZoneActive,  title="LHM Hot Zone",      message="Liquidity Heatmap MTF: Hot Zone Activated")
alertcondition(approachingLiq, title="LHM Approaching Liq", message="Liquidity Heatmap MTF: Price approaching estimated liquidation level")
alertcondition(newPivot,       title="LHM New HTF Pivot",  message="Liquidity Heatmap MTF: New HTF pivot added")


// =====================================================================================================
//  SECTION 11 - INVISIBLE PLOTS (DATA WINDOW)
//  Expose key scalar metrics to TradingView's Data Window so users can hover any bar to inspect
//  the underlying numbers without having to read them off the dashboard. display.data_window only.
// =====================================================================================================

plot(maxIntensity,                       title="Max Intensity",      color=color.new(accentCol,  0), display=display.data_window)
plot(maxBinIdx,                          title="Hottest Bin Idx",    color=color.new(accentCol,  0), display=display.data_window)
plot(maxBinIdx >= 0 ? f_binPrice(maxBinIdx, gridLo, gridHi, binCount) : float(na), title="Hottest Bin Price",   color=color.new(accentCol, 0), display=display.data_window)
plot(nearestLiqAbove,                    title="Nearest Liq Above",  color=accentCol,                 display=display.data_window)
plot(nearestLiqBelow,                    title="Nearest Liq Below",  color=C_HOT,                     display=display.data_window)
plot(array.size(events),                 title="Pivot Events Count", color=C_MUTED,                   display=display.data_window)
plot(atr,                                title="ATR",                color=C_MUTED,                   display=display.data_window)
plot(gridHi,                             title="Grid High",          color=C_MUTED,                   display=display.data_window)
plot(gridLo,                             title="Grid Low",           color=C_MUTED,                   display=display.data_window)
plot(activeEvents,                       title="Active Events",      color=C_MUTED,                   display=display.data_window)

// end of file
````
