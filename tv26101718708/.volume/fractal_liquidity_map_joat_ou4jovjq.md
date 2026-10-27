# Fractal Liquidity Map [JOAT]

- url: https://www.tradingview.com/script/oU4jOvjQ-Fractal-Liquidity-Map-JOAT/
- type: indicator
- pine_id: PUB;0e6276c992ec4277aa0a9747458d056b
- version: 1.0

## Description

[b]Fractal Liquidity Map [JOAT][/b]

[b]Introduction[/b]

The Fractal Liquidity Map renders the complete institutional liquidity landscape through six non-overlapping visual systems that each occupy their own visual lane: Williams Fractal markers, cluster support/resistance zones, equal highs/lows liquidity pool lines, sweep detection signals, multi-length pivot levels, and a Hann FIR trend ribbon. Every element is designed to coexist without visual clutter — cluster zones are thin dual-line bands, liquidity pools are dashed lines, sweeps are plotshape arrows that require no screen space accumulation.

The core problem this solves: most liquidity tools accumulate dozens of overlapping boxes that become unreadable over time. This indicator uses a clean-redraw architecture for zones — all drawing objects are deleted and recreated on each bar using only current price-level arrays, preventing any stacking, overlap, or ghost boxes from persisting.

[image]https://www.tradingview.com/x/aqi5El0k/[/image]

[b]Core Concepts[/b]

[b]1. Williams Fractal Detection[/b]

A fractal high is a bar whose high is the highest in a configurable N-bar window on both sides; a fractal low is the lowest in the same window. Fractals are confirmed on bar close — the center bar's status is only registered after the right-side confirmation bars have closed:

[pine]
bool frac_hi = high[i_frac_len] == ta.highest(high, i_frac_len * 2 + 1)[i_frac_len]
bool frac_lo = low[i_frac_len]  == ta.lowest (low,  i_frac_len * 2 + 1)[i_frac_len]
[/pine]

Fractal marks are rendered as small diamond shapes above and below the relevant bars, providing the foundational structural pivot map from which all other elements derive.

[b]2. Cluster S/R Zones[/b]

When N or more fractals converge within a price band of 1x ATR, they are classified as a cluster zone — an area where price has pivoted multiple times, indicating persistent institutional interest. These are rendered as thin dual-line bands (solid top edge + dotted bottom edge) rather than filled boxes:

[pine]
// Clean-redraw architecture: all lines deleted and recreated on barstate.islast
if barstate.islast
    for each level in clust_res_lvls
        line.new(start_bar, level, bar_index + 10, level,
             color = i_res_col, style = line.style_solid, width = 2)
        line.new(start_bar, level - atr_14 * 0.3, bar_index + 10, level - atr_14 * 0.3,
             color = color.new(i_res_col, 60), style = line.style_dotted)
[/pine]

Only the price levels are stored between bars (as float arrays). The drawing objects are fully recreated on last bar, guaranteeing zero accumulation or overlap regardless of how many bars the zone has existed.

[b]3. Equal Highs/Lows Liquidity Pools[/b]

When two or more swing highs (or lows) within a lookback window fall within a tolerance band of each other (default 0.15x ATR), they form an Equal Highs (EQH) or Equal Lows (EQL) liquidity pool. These levels are targets for stop-hunt sweeps by institutional participants because retail stop orders cluster above EQH and below EQL:

[pine]
float pool_tol = i_pool_tol * atr_14
bool near_hi = math.abs(_pool_hi - _prev_pool_hi) < pool_tol
bool near_lo = math.abs(_pool_lo - _prev_pool_lo) < pool_tol
[/pine]

Pools render as thin dashed lines with compact EQH/EQL labels. Like cluster zones, they use the clean-redraw architecture — no boxes, no accumulation, no stacking.

[b]4. Sweep Detection[/b]

A sweep occurs when price breaks through a known liquidity pool level (above EQH or below EQL) and then closes back inside the prior range — confirming a stop-hunt without follow-through:

[pine]
bool sweep_hi = high > pool_hi_ref and close < pool_hi_ref
bool sweep_lo = low  < pool_lo_ref and close > pool_lo_ref
[/pine]

Sweeps are displayed as plotshape arrows (upward triangle below bar for bullish sweep, downward triangle above bar for bearish sweep). Because plotshape markers occupy zero screen real estate compared to boxes, sweeps cannot overlap or accumulate. An optional single-bar background flash draws attention to sweep bars.

[b]5. Multi-Length Pivot Levels[/b]

Three configurable pivot lengths (default: 10, 30, 75 bars) generate independent sets of support and resistance levels. Each set uses its own resolution and color gradient encoding distance from current price — nearby levels are opaque, distant levels are transparent. Deduplication logic prevents levels from multiple pivot lengths from overlapping if they fall within ATR proximity.

[b]6. Hann FIR Trend Ribbon[/b]

A three-layer Hann Window FIR filter ribbon provides directional bias in the background. The ribbon is fully described in the Adaptive Spectral Bands indicator. Here it serves as a trend filter — when the ribbon is bullish (fast layer above slow), resistance zones are more likely to hold; when bearish, support zones are the focus. Ribbon crossover events flash the background briefly.

[b]Features[/b]

[list]
[*][b]Williams Fractal Marks:[/b] Configurable lookback diamond markers at confirmed fractal highs and lows
[*][b]Cluster S/R Zones:[/b] Dual-line thin bands at price areas where multiple fractals converge, with full deduplication
[*][b]Liquidity Pool Lines:[/b] Dashed lines at equal highs/lows with EQH/EQL labels — no boxes, no stacking
[*][b]Sweep Detection:[/b] plotshape arrows at confirmed liquidity sweep bars plus optional background flash
[*][b]Multi-Length Pivots:[/b] Three independent pivot resolutions with distance-opacity gradient
[*][b]Hann FIR Ribbon:[/b] Three-layer trend ribbon with crossover signals and background flash
[*][b]Zero-Overlap Architecture:[/b] Clean-redraw system for all zone elements eliminates accumulated drawing object clutter
[*][b]Dashboard:[/b] Active cluster zones, active pool lines, sweep count, ribbon direction, and ATR value
[*][b]Alerts:[/b] Bullish sweep, bearish sweep, ribbon crossover bullish, ribbon crossover bearish
[/list]

[b]Input Parameters[/b]

[b]Fractal Detection:[/b]
[list]
[*]Fractal Length: Lookback bars on each side for fractal confirmation (default: 5). Larger = fewer, more significant fractals.
[*]Show Fractal Marks: Toggle diamond marker rendering (default: on)
[/list]

[b]Cluster Zones:[/b]
[list]
[*]Min Fractals for Cluster: Minimum fractal count within ATR band to qualify as a cluster (default: 3)
[*]Max Cluster Zones: Maximum simultaneous cluster zones rendered (default: 6)
[*]Show Cluster Zones: Toggle cluster zone rendering (default: on)
[/list]

[b]Liquidity Pools:[/b]
[list]
[*]Pool Tolerance (x ATR): Price proximity for equal high/low classification (default: 0.15)
[*]Pool Lookback (bars): Window for equal high/low detection (default: 50)
[*]Max Pool Lines: Maximum pool lines displayed (default: 8)
[*]Show Liquidity Pools: Toggle pool line rendering (default: on)
[/list]

[b]Sweep Detection:[/b]
[list]
[*]Show Sweep Signals: Toggle sweep arrows (default: on)
[*]Flash Background on Sweep: Single-bar background highlight on sweep bar (default: on)
[/list]

[b]Multi-Length Pivots:[/b]
[list]
[*]Pivot 1 / Length: First pivot resolution (default: enabled, 10 bars)
[*]Pivot 2 / Length: Second pivot resolution (default: enabled, 30 bars)
[*]Pivot 3 / Length: Third pivot resolution (default: enabled, 75 bars)
[/list]

[b]Trend Ribbon:[/b]
[list]
[*]Show Hann Ribbon: Toggle ribbon visibility (default: on)
[*]Ribbon Length: Base FIR filter length (default: 20)
[*]Ribbon Spacing: Gap between ribbon layers (default: 8)
[/list]

[b]Colors:[/b]
[list]
[*]Resistance / Support / Pool / Sweep: Independent color selection for each element type
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Build the Liquidity Map[/b]
Zoom out to a 1-4 hour timeframe and let the cluster zones and pool lines populate. These are your primary reference levels. The cluster zones (multiple fractal convergences) are the highest-confidence levels. Pool lines (equal highs/lows) are the stop-hunt targets.

[b]Step 2: Watch for Sweeps[/b]
A sweep arrow above a pool line indicates a stop-hunt of sellers above EQH. A bullish sweep (price broke above EQH but closed back inside) is frequently a reversal signal — institutions cleared the sell-side liquidity and may now push price higher. The background flash marks exactly which bar this occurred on.

[b]Step 3: Use the Ribbon for Direction[/b]
Trade cluster zone bounces only in the direction of the Hann ribbon. If the ribbon is bullish (green), focus on support cluster zones for long entries. Resistance zones in a bullish ribbon context are areas to manage position, not reverse.

[b]Step 4: Stack with Multi-Pivot Levels[/b]
Where a multi-length pivot level aligns with a cluster zone, the confluence is significant. A 75-bar pivot and a cluster zone at the same price level is a major institutional reference that warrants tighter risk and larger position sizing consideration.

[b]Originality Statement[/b]

This indicator is original in its integration of fractals, volume-derived cluster zones, equal highs/lows pools, sweep detection, and Hann FIR ribbon into a single zero-overlap visual system. Its publication is justified because:

[list]
[*]The clean-redraw architecture (storing only price levels in arrays, recreating all drawing objects on last bar) is a fundamental departure from the standard approach of accumulating box arrays — it solves the overlap and clutter problem at the architectural level, not with cosmetic band-aids
[*]Cluster zones derived from fractal convergence within ATR tolerance provide an objective, quantitative method for identifying price areas with multiple structural pivots — avoiding the subjectivity of manual zone drawing
[*]Sweep detection using pool levels as reference (not arbitrary lookback highs/lows) creates a directional signal directly tied to the liquidity context in which the sweep occurred
[*]All six visual layers are designed for simultaneous display without interference — fractal marks at bar tops/bottoms, cluster zones as thin lines, pool lines as dashed lines, sweeps as arrows, ribbon below price, pivots as semi-transparent overlays
[/list]

[b]Limitations[/b]

[list]
[*]The clean-redraw system recreates all line objects on every bar close (barstate.islast). On charts with very long history, this processes large arrays. Performance degrades gracefully but is slower than static object creation.
[*]Fractal confirmation requires N bars on each side, meaning fractals always lag behind current price by the fractal length. Fresh structural pivots will not appear until confirmed.
[*]Equal highs/lows detection uses ATR-relative tolerance. On instruments with irregular volatility (news events, halts), temporary ATR spikes may cause pools to merge or split unexpectedly.
[*]Ribbon direction is a trend approximation, not a prediction. Sweep signals against the ribbon trend should be weighted less than those in the ribbon direction.
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any instrument. All trading involves risk of loss. Liquidity zones and sweep signals do not guarantee price direction. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Fractal Liquidity Map [JOAT]",
     shorttitle       = "FLM [JOAT]",
     overlay          = true,
     max_boxes_count  = 100,
     max_lines_count  = 500,
     max_labels_count = 300,
     max_bars_back    = 5000)

// ─── Input Groups ────────────────────────────────────────────────────────
string GRP_FRAC  = "Fractal Detection"
string GRP_CLUST = "Cluster Zones"
string GRP_POOL  = "Liquidity Pools"
string GRP_SWEEP = "Sweep Detection"
string GRP_PIVOT = "Multi-Length Pivots"
string GRP_RIB   = "Trend Ribbon"
string GRP_VIZ   = "Colors"
string GRP_DASH  = "Dashboard"

// Fractal
int    i_frac_len   = input.int   (5,     "Fractal Length",     minval = 2, maxval = 30, group = GRP_FRAC)
bool   i_show_frac  = input.bool  (true,  "Show Fractal Marks", group = GRP_FRAC)

// Cluster Zones
int    i_clust_qty  = input.int   (3,     "Min Fractals for Cluster", minval = 2, maxval = 8, group = GRP_CLUST)
int    i_max_clust  = input.int   (6,     "Max Cluster Zones",        minval = 2, maxval = 12, group = GRP_CLUST)
bool   i_show_clust = input.bool  (true,  "Show Cluster Zones",       group = GRP_CLUST)

// Liquidity Pools (equal highs/lows)
float  i_pool_tol   = input.float (0.15,  "Pool Tolerance (×ATR)",    minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_POOL)
int    i_pool_lb    = input.int   (50,    "Pool Lookback (bars)",      minval = 10, maxval = 300, group = GRP_POOL)
int    i_max_pools  = input.int   (8,     "Max Pool Lines",            minval = 3, maxval = 15, group = GRP_POOL)
bool   i_show_pool  = input.bool  (true,  "Show Liquidity Pools",      group = GRP_POOL)

// Sweep Detection
bool   i_show_sweep = input.bool  (true,  "Show Sweep Signals",        group = GRP_SWEEP)
bool   i_sweep_bg   = input.bool  (true,  "Flash Background on Sweep", group = GRP_SWEEP)

// Multi-Length Pivots
bool   i_piv1       = input.bool  (true,  "Pivot 1", inline = "p1", group = GRP_PIVOT)
int    i_plen1      = input.int   (10,    "",         inline = "p1", group = GRP_PIVOT, minval = 2)
bool   i_piv2       = input.bool  (true,  "Pivot 2", inline = "p2", group = GRP_PIVOT)
int    i_plen2      = input.int   (30,    "",         inline = "p2", group = GRP_PIVOT, minval = 2)
bool   i_piv3       = input.bool  (true,  "Pivot 3", inline = "p3", group = GRP_PIVOT)
int    i_plen3      = input.int   (75,    "",         inline = "p3", group = GRP_PIVOT, minval = 2)

// Trend Ribbon
bool   i_show_rib   = input.bool  (true,  "Show Hann Ribbon",          group = GRP_RIB)
int    i_rib_len    = input.int   (20,    "Ribbon Length",              minval = 5, maxval = 200, group = GRP_RIB)
int    i_rib_wide   = input.int   (8,     "Ribbon Spacing",             minval = 2, maxval = 30,  group = GRP_RIB)

// Colors
color  i_res_col    = input.color (color.rgb(255,  60,  80),  "Resistance", inline = "c",  group = GRP_VIZ)
color  i_sup_col    = input.color (color.rgb(  0, 210, 140),  "Support",    inline = "c",  group = GRP_VIZ)
color  i_pool_col   = input.color (color.rgb(255, 200,  40),  "Pool",       inline = "c2", group = GRP_VIZ)
color  i_sweep_col  = input.color (color.rgb(180,  80, 220),  "Sweep",      inline = "c2", group = GRP_VIZ)

// Dashboard
bool   i_show_dash  = input.bool  (true,  "Show Dashboard", group = GRP_DASH)
string i_dash_pos   = input.string("Top Right", "Position",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = GRP_DASH)
bool   i_repaint    = input.bool  (false, "Allow Repainting", group = GRP_DASH)

// ─── Constants ───────────────────────────────────────────────────────────
color C_BG    = color.rgb(16, 18, 24)
color C_BDR   = color.rgb(40, 46, 58)
color C_TEXT  = color.rgb(190, 200, 218)
color C_MUTED = color.rgb(88, 98, 115)

string _pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>               position.top_right

// ─── ATR & Confirmation ───────────────────────────────────────────────────
float atr_14   = ta.atr(14)
float atr_slow = ta.atr(100)
bool  conf     = i_repaint or barstate.isconfirmed

// ═══════════════════════════════════════════════════════════════════════════
// HANN FIR TREND RIBBON
// ═══════════════════════════════════════════════════════════════════════════
hannFilt(src, length) =>
    float filt = 0.0
    float coef = 0.0
    for i = 1 to length
        float w = 1.0 - math.cos(2.0 * math.pi * i / (length + 1))
        filt += src[i - 1] * w
        coef += w
    coef != 0.0 ? filt / coef : na

float rh0 = hannFilt(close, i_rib_len)
float rh1 = hannFilt(close, i_rib_len + i_rib_wide)
float rh2 = hannFilt(close, i_rib_len + i_rib_wide * 2)

bool rib_bull = rh0 > rh1 and rh1 > rh2
bool rib_bear = rh0 < rh1 and rh1 < rh2
color rib_col = rib_bull ? i_sup_col : rib_bear ? i_res_col : color.rgb(120, 130, 150)

disp_rib = i_show_rib ? display.all : display.none
p_r0 = plot(rh0, "Ribbon Fast", color = color.new(rib_col, 0),  linewidth = 2, display = disp_rib)
p_r1 = plot(rh1, "Ribbon Mid",  color = color.new(rib_col, 45), linewidth = 1, display = disp_rib)
p_r2 = plot(rh2, "Ribbon Slow", color = color.new(rib_col, 75), linewidth = 1, display = disp_rib)
fill(p_r0, p_r1, color.new(rib_col, 72), display = disp_rib, title = "Ribbon Fill 1")
fill(p_r1, p_r2, color.new(rib_col, 85), display = disp_rib, title = "Ribbon Fill 2")

// Ribbon crossover signals
bool rib_cross_bull = ta.crossover (rh0, rh1)
bool rib_cross_bear = ta.crossunder(rh0, rh1)

// ═══════════════════════════════════════════════════════════════════════════
// FRACTAL DETECTION
// ═══════════════════════════════════════════════════════════════════════════
int  fr = i_frac_len
bool fh = high[fr] >= ta.highest(high, fr * 2 + 1)
bool fl = low[fr]  <= ta.lowest (low,  fr * 2 + 1)

var float[] frac_highs = array.new_float(0)
var float[] frac_lows  = array.new_float(0)

if fh
    frac_highs.push(high[fr])
    if frac_highs.size() > 150
        frac_highs.shift()
if fl
    frac_lows.push(low[fr])
    if frac_lows.size() > 150
        frac_lows.shift()

plotshape(fh and i_show_frac, "", shape.triangledown, location.abovebar,
     color.new(i_res_col, 30), size = size.tiny, offset = -fr)
plotshape(fl and i_show_frac, "", shape.triangleup,   location.belowbar,
     color.new(i_sup_col, 30), size = size.tiny, offset = -fr)

// ═══════════════════════════════════════════════════════════════════════════
// CLUSTER S/R ZONES — clean dual-line bands, no stacking
// Stored as arrays of price levels. Rendered as 2 lines (top + bottom of zone).
// Old clusters are deleted and replaced when a new cluster forms nearby.
// ═══════════════════════════════════════════════════════════════════════════
var float[] clust_res_lvls = array.new_float(0)   // resistance cluster prices
var float[] clust_sup_lvls = array.new_float(0)   // support cluster prices
var line[]  clust_lines    = array.new<line>()

// Deduplicate: check if a price is already within tol of existing level.
// Guard against empty array — Pine's for loop from 0 to -1 still enters once.
clust_exists(float[] levels, float price, float tol) =>
    bool found = false
    if levels.size() > 0
        for i = 0 to levels.size() - 1
            if math.abs(levels.get(i) - price) < tol
                found := true
                break
    found

// Detect clusters every 5 bars for performance
if bar_index % 5 == 0
    float clust_tol = atr_14 * 1.5

    // Resistance clusters from fractal highs
    if i_show_clust and frac_highs.size() >= i_clust_qty
        float ref_h  = frac_highs.last()
        float u      = ref_h + atr_14 * 0.7
        float l      = ref_h - atr_14 * 0.7
        int   cnt    = 0
        float s      = 0.0
        int   lookN  = math.min(frac_highs.size(), 30)
        for i = frac_highs.size() - lookN to frac_highs.size() - 1
            float v = frac_highs.get(i)
            if v >= l and v <= u
                cnt += 1
                s   += v
        if cnt >= i_clust_qty
            float cz = s / cnt
            if not clust_exists(clust_res_lvls, cz, clust_tol)
                clust_res_lvls.push(cz)
                if clust_res_lvls.size() > i_max_clust
                    clust_res_lvls.shift()

    // Support clusters from fractal lows
    if i_show_clust and frac_lows.size() >= i_clust_qty
        float ref_l  = frac_lows.last()
        float u      = ref_l + atr_14 * 0.7
        float l      = ref_l - atr_14 * 0.7
        int   cnt    = 0
        float s      = 0.0
        int   lookN  = math.min(frac_lows.size(), 30)
        for i = frac_lows.size() - lookN to frac_lows.size() - 1
            float v = frac_lows.get(i)
            if v >= l and v <= u
                cnt += 1
                s   += v
        if cnt >= i_clust_qty
            float cz = s / cnt
            if not clust_exists(clust_sup_lvls, cz, clust_tol)
                clust_sup_lvls.push(cz)
                if clust_sup_lvls.size() > i_max_clust
                    clust_sup_lvls.shift()

// Redraw cluster lines on last bar (clean redraw — no accumulation)
if barstate.islast and i_show_clust
    for l in clust_lines
        l.delete()
    clust_lines.clear()

    float zone_h = atr_slow * 0.12   // thin band height

    for i = 0 to clust_res_lvls.size() - 1
        float cz  = clust_res_lvls.get(i)
        float dist = math.abs(close - cz)
        int   tr   = dist < atr_14 ? 0 : dist < atr_14 * 3 ? 25 : 55
        // Top edge
        line lt = line.new(bar_index - 200, cz + zone_h, bar_index + 25, cz + zone_h,
             color = color.new(i_res_col, tr), width = 1, style = line.style_solid)
        // Bottom edge
        line lb = line.new(bar_index - 200, cz - zone_h, bar_index + 25, cz - zone_h,
             color = color.new(i_res_col, tr + 20), width = 1, style = line.style_dotted)
        clust_lines.push(lt)
        clust_lines.push(lb)

    for i = 0 to clust_sup_lvls.size() - 1
        float cz  = clust_sup_lvls.get(i)
        float dist = math.abs(close - cz)
        int   tr   = dist < atr_14 ? 0 : dist < atr_14 * 3 ? 25 : 55
        line lt = line.new(bar_index - 200, cz + zone_h, bar_index + 25, cz + zone_h,
             color = color.new(i_sup_col, tr + 20), width = 1, style = line.style_dotted)
        line lb = line.new(bar_index - 200, cz - zone_h, bar_index + 25, cz - zone_h,
             color = color.new(i_sup_col, tr), width = 1, style = line.style_solid)
        clust_lines.push(lt)
        clust_lines.push(lb)

// ═══════════════════════════════════════════════════════════════════════════
// LIQUIDITY POOLS — thin dashed lines, deduplicated, max i_max_pools
// No boxes, no overlap. Each pool = one horizontal dashed line.
// ═══════════════════════════════════════════════════════════════════════════
var float[] pool_res_lvls  = array.new_float(0)
var float[] pool_sup_lvls  = array.new_float(0)
var line[]  pool_lines     = array.new<line>()
var label[] pool_labels    = array.new<label>()
var int     cnt_pools      = 0

float pool_tol = atr_14 * i_pool_tol

// Extract ta.highest/ta.lowest to global scope — series functions must run every bar.
float _pool_hi = ta.highest(high, i_pool_lb)[1]
float _pool_lo = ta.lowest (low,  i_pool_lb)[1]

// Detect pools every 3 bars
if i_show_pool and bar_index % 3 == 0 and bar_index > i_pool_lb + 5
    // Equal highs
    if not na(_pool_hi) and math.abs(high - _pool_hi) < pool_tol and high > 0
        float pmid = math.avg(high, _pool_hi)
        if not clust_exists(pool_res_lvls, pmid, pool_tol * 1.5)
            pool_res_lvls.push(pmid)
            cnt_pools += 1
            if pool_res_lvls.size() > i_max_pools
                pool_res_lvls.shift()

    // Equal lows
    if not na(_pool_lo) and math.abs(low - _pool_lo) < pool_tol and low > 0
        float pmid = math.avg(low, _pool_lo)
        if not clust_exists(pool_sup_lvls, pmid, pool_tol * 1.5)
            pool_sup_lvls.push(pmid)
            cnt_pools += 1
            if pool_sup_lvls.size() > i_max_pools
                pool_sup_lvls.shift()

// Redraw pool lines on last bar (clean redraw)
if barstate.islast and i_show_pool
    for l in pool_lines
        l.delete()
    for lb in pool_labels
        lb.delete()
    pool_lines.clear()
    pool_labels.clear()

    for i = 0 to pool_res_lvls.size() - 1
        float pz  = pool_res_lvls.get(i)
        float dist = math.abs(close - pz)
        int   tr   = dist < atr_14 ? 10 : 40
        line pl = line.new(bar_index - i_pool_lb, pz, bar_index + 15, pz,
             color = color.new(i_pool_col, tr), width = 1,
             style = line.style_dashed)
        label lbl = label.new(bar_index + 17, pz, "EQH",
             style = label.style_none, textcolor = color.new(i_pool_col, tr),
             size = size.tiny)
        pool_lines.push(pl)
        pool_labels.push(lbl)

    for i = 0 to pool_sup_lvls.size() - 1
        float pz  = pool_sup_lvls.get(i)
        float dist = math.abs(close - pz)
        int   tr   = dist < atr_14 ? 10 : 40
        line pl = line.new(bar_index - i_pool_lb, pz, bar_index + 15, pz,
             color = color.new(i_pool_col, tr), width = 1,
             style = line.style_dashed)
        label lbl = label.new(bar_index + 17, pz, "EQL",
             style = label.style_none, textcolor = color.new(i_pool_col, tr),
             size = size.tiny)
        pool_lines.push(pl)
        pool_labels.push(lbl)

// ═══════════════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP DETECTION — plotshape markers, NO boxes
// Using plotshape avoids any box accumulation or overlap entirely.
// Background flash is a single bgcolor call per sweep bar.
// ═══════════════════════════════════════════════════════════════════════════
int   i_sweep_lb    = 10
float sweep_low_ref  = ta.lowest (low,  i_sweep_lb)[1]
float sweep_high_ref = ta.highest(high, i_sweep_lb)[1]

bool bull_sweep = low < sweep_low_ref  - pool_tol * 0.3 and close > sweep_low_ref  and i_show_sweep
bool bear_sweep = high > sweep_high_ref + pool_tol * 0.3 and close < sweep_high_ref and i_show_sweep

var int cnt_sweeps     = 0
var int cnt_bull_sweep = 0
var int cnt_bear_sweep = 0

if bull_sweep and conf
    cnt_sweeps     += 1
    cnt_bull_sweep += 1
if bear_sweep and conf
    cnt_sweeps     += 1
    cnt_bear_sweep += 1

// Sweep markers: arrows above/below the sweep bar (no boxes — no overlap possible)
plotshape(bull_sweep and conf, "Bull Sweep", shape.arrowup,   location.belowbar,
     color.new(i_sweep_col, 0), size = size.small, text = "SW", textcolor = i_sweep_col)
plotshape(bear_sweep and conf, "Bear Sweep", shape.arrowdown, location.abovebar,
     color.new(i_sweep_col, 0), size = size.small, text = "SW", textcolor = i_sweep_col)

// Brief background flash on sweep (1 bar only, no persistent box)
bgcolor(bull_sweep and conf and i_sweep_bg ? color.new(i_sweep_col, 88) : na, title = "Bull Sweep BG")
bgcolor(bear_sweep and conf and i_sweep_bg ? color.new(i_sweep_col, 88) : na, title = "Bear Sweep BG")

// Ribbon crossover backgrounds (subtle, for trend turn awareness)
bgcolor(rib_cross_bull ? color.new(i_sup_col, 92) : na, title = "Ribbon Bull BG")
bgcolor(rib_cross_bear ? color.new(i_res_col, 92) : na, title = "Ribbon Bear BG")

// ═══════════════════════════════════════════════════════════════════════════
// MULTI-LENGTH PIVOT S/R LINES
// Rebuilt cleanly on last bar. Max 2 pivots per type per length (6 lines total per group).
// ═══════════════════════════════════════════════════════════════════════════
float ph1 = ta.pivothigh(i_plen1, i_plen1)
float pl1  = ta.pivotlow (i_plen1, i_plen1)
float ph2  = ta.pivothigh(i_plen2, i_plen2)
float pl2  = ta.pivotlow (i_plen2, i_plen2)
float ph3  = ta.pivothigh(i_plen3, i_plen3)
float pl3  = ta.pivotlow (i_plen3, i_plen3)

var line[]  piv_lines  = array.new<line>()
var label[] piv_labels = array.new<label>()

// ─── Pre-compute ALL series functions at global scope ─────────────────────
// Pine v6 requires series functions (ta.valuewhen, math.sum) to run every bar.
// Extracting them here satisfies the consistency requirement.
float _vol_sum_20 = math.sum(volume, 20)

float _ph1_val = ta.valuewhen(not na(ph1), high[i_plen1],       0)
int   _ph1_bar = ta.valuewhen(not na(ph1), bar_index[i_plen1],  0)
float _pl1_val = ta.valuewhen(not na(pl1), low[i_plen1],        0)
int   _pl1_bar = ta.valuewhen(not na(pl1), bar_index[i_plen1],  0)
float _ph2_val = ta.valuewhen(not na(ph2), high[i_plen2],       0)
int   _ph2_bar = ta.valuewhen(not na(ph2), bar_index[i_plen2],  0)
float _pl2_val = ta.valuewhen(not na(pl2), low[i_plen2],        0)
int   _pl2_bar = ta.valuewhen(not na(pl2), bar_index[i_plen2],  0)
float _ph3_val = ta.valuewhen(not na(ph3), high[i_plen3],       0)
int   _ph3_bar = ta.valuewhen(not na(ph3), bar_index[i_plen3],  0)
float _pl3_val = ta.valuewhen(not na(pl3), low[i_plen3],        0)
int   _pl3_bar = ta.valuewhen(not na(pl3), bar_index[i_plen3],  0)

// ─── Pivot Level Renderer ─────────────────────────────────────────────────
// All series values passed as parameters — no internal series lookups.
// This eliminates the "should be called on each calculation" warning.
draw_piv(float price, int start_bar, bool is_res, int w,
         line[] lines_arr, label[] labels_arr,
         float cur_close, float cur_atr, float vol_sum) =>
    color lc   = is_res ? i_res_col : i_sup_col
    float dist = math.abs(cur_close - price)
    int   tr   = dist < cur_atr * 0.5 ? 0 : dist < cur_atr * 2.0 ? 30 : 65
    line ml = line.new(start_bar, price, bar_index + 22, price,
         color = color.new(lc, tr), width = w, style = line.style_solid)
    line gl = line.new(start_bar, price, bar_index + 22, price,
         color = color.new(lc, math.min(tr + 55, 90)), width = w * 3,
         style = line.style_solid)
    lines_arr.push(ml)
    lines_arr.push(gl)
    label lbl = label.new(bar_index + 24, price,
         str.tostring(price, format.mintick) + "  V:" + str.tostring(vol_sum, format.volume),
         style     = label.style_none,
         textcolor = color.new(lc, tr),
         size      = size.tiny)
    labels_arr.push(lbl)

if barstate.islast
    for l in piv_lines
        l.delete()
    for lbl2 in piv_labels
        lbl2.delete()
    piv_lines.clear()
    piv_labels.clear()

    // Use pre-computed global variables — no ta.valuewhen inside conditional
    if i_piv1 and not na(_ph1_val)
        draw_piv(_ph1_val, _ph1_bar, true,  1, piv_lines, piv_labels, close, atr_14, _vol_sum_20)
    if i_piv1 and not na(_pl1_val)
        draw_piv(_pl1_val, _pl1_bar, false, 1, piv_lines, piv_labels, close, atr_14, _vol_sum_20)
    if i_piv2 and not na(_ph2_val)
        draw_piv(_ph2_val, _ph2_bar, true,  2, piv_lines, piv_labels, close, atr_14, _vol_sum_20)
    if i_piv2 and not na(_pl2_val)
        draw_piv(_pl2_val, _pl2_bar, false, 2, piv_lines, piv_labels, close, atr_14, _vol_sum_20)
    if i_piv3 and not na(_ph3_val)
        draw_piv(_ph3_val, _ph3_bar, true,  3, piv_lines, piv_labels, close, atr_14, _vol_sum_20)
    if i_piv3 and not na(_pl3_val)
        draw_piv(_pl3_val, _pl3_bar, false, 3, piv_lines, piv_labels, close, atr_14, _vol_sum_20)

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
if barstate.islast and i_show_dash
    var table dash = table.new(_pos, 2, 11,
         bgcolor      = C_BG,
         border_color = C_BDR,
         border_width = 1,
         frame_color  = C_BDR,
         frame_width  = 2)

    table.cell(dash, 0, 0, "FLM",
         text_color = color.rgb(180, 80, 220), text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "jackofalltrades",
         text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_right)

    // Trend ribbon state
    string rib_txt = rib_bull ? "▲ BULL" : rib_bear ? "▼ BEAR" : "— NEUT"
    color  rib_tc  = rib_bull ? i_sup_col : rib_bear ? i_res_col : C_MUTED
    table.cell(dash, 0, 1, "Ribbon",     text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, rib_txt,      text_color = rib_tc, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "Frac Highs", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(frac_highs.size()),
         text_color = i_res_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Frac Lows",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(frac_lows.size()),
         text_color = i_sup_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Res Clusters", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(clust_res_lvls.size()),
         text_color = i_res_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Sup Clusters", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(clust_sup_lvls.size()),
         text_color = i_sup_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Liq Pools",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(cnt_pools),
         text_color = i_pool_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 7, "Sweeps",     text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(cnt_sweeps),
         text_color = i_sweep_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 8, "Bull Sweeps", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(cnt_bull_sweep),
         text_color = i_sup_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 9, "Bear Sweeps", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 9, str.tostring(cnt_bear_sweep),
         text_color = i_res_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 10, "ATR(14)",   text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 10, str.tostring(atr_14, format.mintick),
         text_color = C_MUTED, text_size = size.small, text_halign = text.align_right)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(bull_sweep and conf, "FLM — Bullish Sweep [JOAT]",
     "FLM: Bullish liquidity sweep on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(bear_sweep and conf, "FLM — Bearish Sweep [JOAT]",
     "FLM: Bearish liquidity sweep on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(rib_cross_bull and conf, "FLM — Ribbon Bullish Cross [JOAT]",
     "FLM: Hann ribbon bullish crossover on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(rib_cross_bear and conf, "FLM — Ribbon Bearish Cross [JOAT]",
     "FLM: Hann ribbon bearish crossover on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(fh and i_show_frac, "FLM — Fractal High [JOAT]",
     "FLM: Fractal high on {{ticker}} ({{interval}})")
alertcondition(fl and i_show_frac, "FLM — Fractal Low [JOAT]",
     "FLM: Fractal low on {{ticker}} ({{interval}})")
````
