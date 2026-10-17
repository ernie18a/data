# Auto Trendlines & Market Structure - MTF

- url: https://www.tradingview.com/script/YhyU49QG-Auto-Trendlines-Market-Structure-MTF/
- type: indicator
- pine_id: PUB;3171f112606542708a143d9f07f5a90c
- version: 1.0

## Description

[b]Auto Trendlines & Market Structure - MTF[/b]

Auto Trendlines & Market Structure - MTF is a visual analytical indicator that automatically draws support and resistance trendlines through swing pivots and classifies the resulting structure into one of seven states: Uptrend, Downtrend, Expanding, Contracting, Range, HH Trending, or LL Trending. A compact panel in the top-right shows how that classification compares across the current chart timeframe and three higher timeframes.

The goal is to remove the subjectivity of manual trendline drawing while keeping the chart readable: only the two currently relevant lines (one from recent pivot highs, one from recent pivot lows) are drawn as active, while older invalidated lines fade into a dashed historical layer for context.

This is a visual analytical tool intended for chart reading and structure mapping. It does not execute trades and does not provide financial advice.

[b]Key Features[/b]

[list]
[*]Auto-detected trendlines through the two most recent valid pivot highs (resistance) and pivot lows (support)
[*]Adaptive pivot lookback that scales with ATR-relative volatility, with optional fixed-length mode
[*]Seven-class structure classification rather than a binary up/down trend
[*]Multi-timeframe panel scanning the current TF plus three higher TFs
[*]Validation logic that rejects lines penetrated by older pivots beyond an ATR-based tolerance
[*]Historical line trail (dashed) preserved when an active trendline gets broken or replaced
[*]Two-layer neon line rendering and gradient channel fill scaled by ATR
[/list]

[b]Core Concept[/b]

Most automatic trendline scripts simply connect the two most recent pivots and call it a trendline. This produces noisy output in choppy markets and resists no contradiction from older swings. This indicator adds three layers on top of that base.

[b]1. Pivot Validation.[/b] Before a candidate trendline becomes active, it is checked against up to four older pivots in the same direction. If any of them sits more than 0.3 ATR above a resistance line (or below a support line), the candidate is rejected. This filters out lines that look correct on the latest two pivots but conflict with established structure.

[b]2. ATR-Normalized Slope.[/b] Slope is stored not in raw price-per-bar units but in ATR-per-bar units. This makes slope comparable across instruments and timeframes: a normalized slope of 0.1 means roughly one-tenth of an ATR per bar regardless of whether the chart is EURUSD on 15m or BTCUSD on 4H. Strength buckets (Weak / Moderate / Strong / Very Strong) are then defined on this normalized scale.

[b]3. Seven-Class Structure Classification.[/b] Instead of collapsing everything into "up or down", the indicator combines the slope sign of both lines:

[list]
[*]Both up — Uptrend
[*]Both down — Downtrend
[*]Resistance up, support down — Expanding (broadening)
[*]Resistance down, support up — Contracting (converging)
[*]Both flat within threshold — Range
[*]Only support active — LL Trending (one-sided structure)
[*]Only resistance active — HH Trending (one-sided structure)
[/list]

This classification surfaces structural states that a single trend label cannot describe — particularly Expanding and Contracting, which often precede volatility expansions or breakouts.

[b]Trendline Lifecycle[/b]

Each line goes through a defined lifecycle:

[list]
[*]Built from the two newest valid pivots in its direction
[*]Projected to the right and rendered with a colored core plus a wider transparent glow
[*]Replaced when a newer pivot pair forms a more recent line — the previous line is then frozen as a dashed historical reference
[*]Invalidated when price closes more than 0.5 ATR beyond the line — at that moment the line stops projecting, freezes at the breakpoint, and a break alert can fire
[/list]

The historical trail is capped at 80 frozen lines (FIFO) so the chart does not accumulate clutter on long histories.

[b]Multi-Timeframe Panel[/b]

A compact panel in the top-right corner displays the current trend classification across the current timeframe and three higher timeframes. The three HTFs are selected automatically from the standard ladder (1m, 5m, 15m, 1H, 4H, 1D, 1W, 1M, 3M, 12M) based on the active chart timeframe — for example, on a 1H chart the panel shows 4H, 1D, 1W.

Each row shows:

[list]
[*]Timeframe label
[*]Block-bar strength gauge
[*]Class name (Uptrend / Downtrend / Expanding / Contracting / Range / HH Trending / LL Trending / Building)
[*]Strength tier (Weak / Moderate / Strong / Very Strong)
[/list]

The panel also shows the current chart's HH and LL line levels and the absolute and percentage channel width when both lines are active. HTF data is pulled with non-repainting parameters so the panel stays consistent on confirmed bars.

[b]Typical Analysis Workflow[/b]

A common analytical workflow may include:

[list=1]
[*]Reading the structure class on the chart timeframe to understand the immediate state
[*]Comparing it to the three higher timeframes in the panel to detect alignment or conflict
[*]Watching the channel width as the structure transitions between Expanding, Contracting, and Range
[*]Using line breaks and the dashed historical trail to time potential structure shifts
[*]Combining the structure read with other forms of analysis and risk management
[/list]

[b]Configuration[/b]

[b]Pivot Lookback Mode[/b] — Adaptive (default) scales the pivot length with ATR-relative volatility (between 5 and 10 bars on each side). Fixed lets you set a single lookback between 3 and 15 bars.

[b]Show Trend Lines[/b] — Toggles the active two-layer neon trendlines.

[b]Show Channel Fill[/b] — Fills the area between active lines with a gradient. Only rendered when both lines are active and the structure is Uptrend, Downtrend, or Range (skipped during Expanding and Contracting to avoid visual confusion).

[b]Show MTF Panel[/b] — Toggles the multi-timeframe panel.

[b]Show Pivot Markers[/b] — Triangle markers at the most recent pivots, capped at 6 to avoid clutter.

[b]Show Trend Status[/b] — Large class badge above price.

[b]Show Line Labels[/b] — "HH" and "LL" anchor markers at the right end of each active line.

[b]Line Width (Core)[/b] — Width of the inner core line. The outer glow is always rendered at core + 7.

[b]Markets and Timeframes[/b]

The indicator can be applied across multiple markets and timeframes:

[list]
[*]Forex
[*]Stocks and Indices
[*]Commodities
[*]Cryptocurrencies
[/list]

Because slope is ATR-normalized and pivot lookback is volatility-adaptive, the visual behavior remains consistent across instruments and timeframes without manual re-tuning.

[b]Alerts[/b]

Three alert conditions are available:

[list]
[*]Trend Class Changed — fires when the structure classification transitions between any of the seven states
[*]Resistance Break — fires when price closes more than 0.5 ATR above the active resistance line
[*]Support Break — fires when price closes more than 0.5 ATR below the active support line
[/list]

All alerts evaluate on confirmed bars to avoid intra-bar oscillation.

[b]Notes on Repainting[/b]

Active trendlines are anchored to confirmed pivot highs and pivot lows, which are themselves only validated after a pivot lookback window has fully passed. Once an active line is drawn its anchor points do not move. The MTF panel uses confirmed higher-timeframe values with a one-bar offset, so its readings stay consistent across historical and realtime bars. Alerts trigger only on confirmed bars.

[b]Important Notes[/b]

This indicator is an analytical visualization tool. It does not execute trades and does not provide financial advice. All outputs are informational and should be interpreted within the context of independent market analysis and proper risk management.

Past behavior of any technical indicator does not guarantee future results.

If you find this indicator useful, feel free to add it to your favorites and share your feedback in the comments. Community feedback helps improve future updates.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MQLSoftware

//@version=6
indicator("Auto Trendlines & Market Structure - MTF", shorttitle="Auto Trendlines & Market Structure - MTF", overlay=true,
     max_lines_count=200,
     max_boxes_count=20,
     max_labels_count=300)

// ============================================================================
// SECTION 0 — DESIGN TOKENS (Neo Slate)
// ============================================================================

color C_BULL  = color.rgb(  0, 210, 255)
color C_BEAR  = color.rgb(255,  70, 105)
color C_AMBER = color.rgb(255, 175,  20)
color C_WHITE = color.rgb(225, 230, 240)
color C_LBL   = color.rgb(170, 178, 195)
color C_DIM   = color.rgb(140, 148, 168)
color C_SEC   = color.rgb( 90,  98, 115)

color P_BG    = color.new(color.rgb(  8,  11,  18),  4)
color P_ROW   = color.new(color.rgb( 16,  20,  30),  6)
color P_SEP   = color.new(color.rgb( 30,  38,  56), 10)

// ============================================================================
// SECTION 1 — INPUTS
// ============================================================================

string grp_quick   = "Quick Setup"
string grp_pivot   = "Pivot Detection"
string grp_visual  = "Visual"
string grp_alerts  = "Alerts"

bool show_lines_inp   = input.bool(true,  "Show Trend Lines",     group=grp_quick)
bool show_fill_inp    = input.bool(true,  "Show Channel Fill",    group=grp_quick)
bool show_panel_inp   = input.bool(true,  "Show MTF Panel",       group=grp_quick)
bool show_pivots_inp  = input.bool(true,  "Show Pivot Markers",   group=grp_quick)
bool show_status_inp  = input.bool(true,  "Show Trend Status",    group=grp_quick)
bool show_endlbls_inp = input.bool(true,  "Show Line Labels",     group=grp_quick)

string lookback_mode_inp = input.string("Adaptive", "Pivot Lookback Mode",
     options=["Adaptive", "Fixed"], group=grp_pivot)
int    fixed_lookback_inp = input.int(5, "Fixed Lookback",
     minval=3, maxval=15, group=grp_pivot)

int line_width_inp   = input.int(3,  "Line Width (Core)",     minval=1, maxval=5, group=grp_visual,
     tooltip="Core line width. Glow halo is always rendered at width = core + 7.")

bool alert_change_inp = input.bool(false, "Alert on Trend Change",    group=grp_alerts)
bool alert_break_inp  = input.bool(false, "Alert on Trendline Break", group=grp_alerts)

// ============================================================================
// SECTION 2 — MARKET DATA
// ============================================================================

float atr14        = ta.atr(14)
float atr_relative = atr14 / close * 100

// Adaptive lookback period
int adaptive_lb = math.max(int(atr_relative * 5), 5)
adaptive_lb := math.min(adaptive_lb, 10)

int pivot_lookback = lookback_mode_inp == "Adaptive" ? adaptive_lb : fixed_lookback_inp

// Stable y-anchor for status label (won't jump on bar-to-bar high spikes)
float anchor_high = ta.highest(high, 50)

// ============================================================================
// SECTION 3 — PIVOT DETECTION
// ============================================================================

float pivot_high_now = ta.pivothigh(high, pivot_lookback, pivot_lookback)
float pivot_low_now  = ta.pivotlow(low,  pivot_lookback, pivot_lookback)

// Storage: index 0 = newest pivot
var array<float> ph_prices = array.new<float>()
var array<int>   ph_bars   = array.new<int>()
var array<float> pl_prices = array.new<float>()
var array<int>   pl_bars   = array.new<int>()

// Add new pivot high
if not na(pivot_high_now)
    array.unshift(ph_prices, pivot_high_now)
    array.unshift(ph_bars,   bar_index - pivot_lookback)
    if array.size(ph_prices) > 20
        array.pop(ph_prices)
        array.pop(ph_bars)

// Add new pivot low
if not na(pivot_low_now)
    array.unshift(pl_prices, pivot_low_now)
    array.unshift(pl_bars,   bar_index - pivot_lookback)
    if array.size(pl_prices) > 20
        array.pop(pl_prices)
        array.pop(pl_bars)

// ============================================================================
// SECTION 4 — TRENDLINE CONSTRUCTION
// ============================================================================

// Top-level state vars (required for request.security & cross-bar persistence)
var float hh_slope     = na
var float ll_slope     = na
var float hh_slope_atr = na
var float ll_slope_atr = na
var float hh_p1_price  = na
var float ll_p1_price  = na
var int   hh_p1_bar    = na
var int   ll_p1_bar    = na
var bool  hh_valid     = false
var bool  ll_valid     = false
var bool  hh_invalidated = false
var bool  ll_invalidated = false

// Storage for frozen historical lines (FIFO eviction on max_lines)
// Keep ~80 historical lines (~40 pairs HH+LL); leave headroom for active glow+core
var array<line> frozen_lines = array.new<line>()
int FROZEN_LIMIT = 80

f_freeze_push(line ln) =>
    array.push(frozen_lines, ln)
    if array.size(frozen_lines) > FROZEN_LIMIT
        line oldest = array.shift(frozen_lines)
        if not na(oldest)
            line.delete(oldest)

// --- Build HH (resistance) line from two newest pivot highs ---
if array.size(ph_prices) >= 2
    float p2_price = array.get(ph_prices, 0)
    int   p2_bar   = array.get(ph_bars,   0)
    float p1_price = array.get(ph_prices, 1)
    int   p1_bar   = array.get(ph_bars,   1)

    float new_slope = (p2_price - p1_price) / (p2_bar - p1_bar)

    // Validate: older pivots should not be significantly above the line
    bool valid = true
    if array.size(ph_prices) >= 3
        int max_check = math.min(array.size(ph_prices) - 1, 5)
        for i = 2 to max_check
            float old_price = array.get(ph_prices, i)
            int   old_bar   = array.get(ph_bars,   i)
            float line_at_old = p1_price + new_slope * (old_bar - p1_bar)
            if old_price > line_at_old + atr14 * 0.3
                valid := false
                break

    // On new pivot high: freeze previous active line, then refresh state
    if not na(pivot_high_now)
        if hh_valid and not hh_invalidated and not na(hh_slope)
            float frozen_end_y = hh_p1_price + hh_slope * (p2_bar - hh_p1_bar)
            line frz = line.new(hh_p1_bar, hh_p1_price, p2_bar, frozen_end_y,
                 color=color.new(C_DIM, 35),
                 width=2,
                 style=line.style_dashed,
                 extend=extend.none)
            f_freeze_push(frz)

        hh_slope    := new_slope
        hh_p1_price := p1_price
        hh_p1_bar   := p1_bar
        hh_valid    := valid
        hh_slope_atr := atr14 > 0 ? new_slope / atr14 : na
        hh_invalidated := false

// --- Build LL (support) line from two newest pivot lows ---
if array.size(pl_prices) >= 2
    float p2_price = array.get(pl_prices, 0)
    int   p2_bar   = array.get(pl_bars,   0)
    float p1_price = array.get(pl_prices, 1)
    int   p1_bar   = array.get(pl_bars,   1)

    float new_slope = (p2_price - p1_price) / (p2_bar - p1_bar)

    bool valid = true
    if array.size(pl_prices) >= 3
        int max_check = math.min(array.size(pl_prices) - 1, 5)
        for i = 2 to max_check
            float old_price = array.get(pl_prices, i)
            int   old_bar   = array.get(pl_bars,   i)
            float line_at_old = p1_price + new_slope * (old_bar - p1_bar)
            if old_price < line_at_old - atr14 * 0.3
                valid := false
                break

    if not na(pivot_low_now)
        if ll_valid and not ll_invalidated and not na(ll_slope)
            float frozen_end_y = ll_p1_price + ll_slope * (p2_bar - ll_p1_bar)
            line frz = line.new(ll_p1_bar, ll_p1_price, p2_bar, frozen_end_y,
                 color=color.new(C_DIM, 35),
                 width=2,
                 style=line.style_dashed,
                 extend=extend.none)
            f_freeze_push(frz)

        ll_slope    := new_slope
        ll_p1_price := p1_price
        ll_p1_bar   := p1_bar
        ll_valid    := valid
        ll_slope_atr := atr14 > 0 ? new_slope / atr14 : na
        ll_invalidated := false

// --- Project lines to current bar ---
float hh_line_now = (not na(hh_slope) and hh_valid and not hh_invalidated) ? hh_p1_price + hh_slope * (bar_index - hh_p1_bar) : na
float ll_line_now = (not na(ll_slope) and ll_valid and not ll_invalidated) ? ll_p1_price + ll_slope * (bar_index - ll_p1_bar) : na

// --- Invalidation by clear break ---
float hh_proj_raw = (not na(hh_slope) and hh_valid and not hh_invalidated) ? hh_p1_price + hh_slope * (bar_index - hh_p1_bar) : na
float ll_proj_raw = (not na(ll_slope) and ll_valid and not ll_invalidated) ? ll_p1_price + ll_slope * (bar_index - ll_p1_bar) : na

bool hh_broken = not na(hh_proj_raw) and close > hh_proj_raw + atr14 * 0.5
bool ll_broken = not na(ll_proj_raw) and close < ll_proj_raw - atr14 * 0.5

if hh_broken and not hh_invalidated
    if not na(hh_slope)
        float frz_end_y = hh_p1_price + hh_slope * (bar_index - hh_p1_bar)
        line frz = line.new(hh_p1_bar, hh_p1_price, bar_index, frz_end_y,
             color=color.new(C_DIM, 35),
             width=2,
             style=line.style_dashed,
             extend=extend.none)
        f_freeze_push(frz)
    hh_invalidated := true

if ll_broken and not ll_invalidated
    if not na(ll_slope)
        float frz_end_y = ll_p1_price + ll_slope * (bar_index - ll_p1_bar)
        line frz = line.new(ll_p1_bar, ll_p1_price, bar_index, frz_end_y,
             color=color.new(C_DIM, 35),
             width=2,
             style=line.style_dashed,
             extend=extend.none)
        f_freeze_push(frz)
    ll_invalidated := true

bool hh_active = hh_valid and not hh_invalidated and not na(hh_slope)
bool ll_active = ll_valid and not ll_invalidated and not na(ll_slope)

// ============================================================================
// SECTION 5 — TREND CLASSIFICATION (5 classes + one-sided + strength)
// ============================================================================

float slope_threshold = 0.05

float hh_s_eff = hh_active ? hh_slope_atr : na
float ll_s_eff = ll_active ? ll_slope_atr : na

bool hh_up   = not na(hh_s_eff) and hh_s_eff >  slope_threshold
bool hh_down = not na(hh_s_eff) and hh_s_eff < -slope_threshold
bool ll_up   = not na(ll_s_eff) and ll_s_eff >  slope_threshold
bool ll_down = not na(ll_s_eff) and ll_s_eff < -slope_threshold

bool both_lines  = hh_active and ll_active
bool only_hh     = hh_active and not ll_active
bool only_ll     = ll_active and not hh_active
bool no_lines    = not hh_active and not ll_active

string trend_class = both_lines ? (hh_up and ll_up ? "Uptrend" : hh_down and ll_down ? "Downtrend" : hh_up and ll_down ? "Expanding" : hh_down and ll_up ? "Contracting" : "Range") : only_ll ? "LL Trending" : only_hh ? "HH Trending" : "Building"

float trend_strength = both_lines ? (math.abs(nz(hh_s_eff, 0)) + math.abs(nz(ll_s_eff, 0))) / 2 : only_ll ? math.abs(nz(ll_s_eff, 0)) : only_hh ? math.abs(nz(hh_s_eff, 0)) : 0.0

string strength_class = no_lines ? "—" : trend_strength < 0.05 ? "Weak" : trend_strength < 0.15 ? "Moderate" : trend_strength < 0.30 ? "Strong" : "Very Strong"

color trend_color = trend_class == "Uptrend" ? C_BULL : trend_class == "Downtrend" ? C_BEAR : trend_class == "Expanding" ? C_AMBER : trend_class == "Contracting" ? C_AMBER : trend_class == "LL Trending" ? (ll_up ? C_BULL : ll_down ? C_BEAR : C_SEC) : trend_class == "HH Trending" ? (hh_up ? C_BULL : hh_down ? C_BEAR : C_SEC) : C_SEC

// ============================================================================
// SECTION 6 — MTF COMPUTATION
// ============================================================================

int chart_minutes = timeframe.in_seconds() / 60

f_mtf_set() =>
    string t1 = "240"
    string t2 = "1D"
    string t3 = "1W"
    if timeframe.isseconds
        t1 := "5"
        t2 := "15"
        t3 := "60"
    else if chart_minutes <= 1
        t1 := "5"
        t2 := "15"
        t3 := "60"
    else if chart_minutes <= 5
        t1 := "15"
        t2 := "60"
        t3 := "240"
    else if chart_minutes <= 15
        t1 := "60"
        t2 := "240"
        t3 := "1D"
    else if chart_minutes <= 60
        t1 := "240"
        t2 := "1D"
        t3 := "1W"
    else if chart_minutes <= 240
        t1 := "1D"
        t2 := "1W"
        t3 := "1M"
    else if timeframe.isdaily
        t1 := "1W"
        t2 := "1M"
        t3 := "3M"
    else if timeframe.isweekly
        t1 := "1M"
        t2 := "3M"
        t3 := "12M"
    else if timeframe.ismonthly
        t1 := "1M"
        t2 := "3M"
        t3 := "12M"
    [t1, t2, t3]

[mtf1_tf, mtf2_tf, mtf3_tf] = f_mtf_set()

f_get_mtf_trend(string tf) =>
    // Non-repainting: offset all expressions by [1] so we read CLOSED HTF bar values.
    // This means MTF panel data is up to one HTF bar "late" but never changes
    // retroactively — required for honest "non-repainting" claim.
    [_hh_s, _ll_s, _hh_inv, _ll_inv] =
         request.security(syminfo.tickerid, tf,
              [hh_slope_atr[1], ll_slope_atr[1], hh_invalidated[1], ll_invalidated[1]],
              lookahead=barmerge.lookahead_off)

    bool _hh_act = not na(_hh_s) and not _hh_inv
    bool _ll_act = not na(_ll_s) and not _ll_inv

    float _hhe = _hh_act ? _hh_s : na
    float _lle = _ll_act ? _ll_s : na

    bool _hh_up   = not na(_hhe) and _hhe >  slope_threshold
    bool _hh_down = not na(_hhe) and _hhe < -slope_threshold
    bool _ll_up   = not na(_lle) and _lle >  slope_threshold
    bool _ll_down = not na(_lle) and _lle < -slope_threshold

    bool _both    = _hh_act and _ll_act
    bool _only_h  = _hh_act and not _ll_act
    bool _only_l  = _ll_act and not _hh_act
    bool _none    = not _hh_act and not _ll_act

    string _cls = _both ? (_hh_up and _ll_up ? "Uptrend" : _hh_down and _ll_down ? "Downtrend" : _hh_up and _ll_down ? "Expanding" : _hh_down and _ll_up ? "Contracting" : "Range") : _only_l ? "LL Trending" : _only_h ? "HH Trending" : "Building"

    float _str = _both ? (math.abs(nz(_hhe, 0)) + math.abs(nz(_lle, 0))) / 2 : _only_l ? math.abs(nz(_lle, 0)) : _only_h ? math.abs(nz(_hhe, 0)) : 0.0
    string _strcls = _none ? "—" : _str < 0.05 ? "Weak" : _str < 0.15 ? "Moderate" : _str < 0.30 ? "Strong" : "V.Strong"

    int _dir = _only_l ? (_ll_up ? 1 : _ll_down ? -1 : 0) : _only_h ? (_hh_up ? 1 : _hh_down ? -1 : 0) : 0

    [_cls, _strcls, _str, _dir]

[mtf1_cls, mtf1_str_cls, mtf1_str, mtf1_dir] = f_get_mtf_trend(mtf1_tf)
[mtf2_cls, mtf2_str_cls, mtf2_str, mtf2_dir] = f_get_mtf_trend(mtf2_tf)
[mtf3_cls, mtf3_str_cls, mtf3_str, mtf3_dir] = f_get_mtf_trend(mtf3_tf)

// ============================================================================
// SECTION 7 — VISUALIZATION
//   Active lines: TWO-LAYER neon glow rendering
//     Layer A (glow):  width = core+6, opacity 65, solid
//     Layer B (core):  width = core,   opacity  0, solid
//   Channel fill: TWO linefills (inner bright between cores, outer faded between glows)
//   Endpoint labels: anchor markers "▶ HH" / "▶ LL" at right end
// ============================================================================

var line     hh_glow      = na
var line     hh_core      = na
var line     ll_glow      = na
var line     ll_core      = na
var linefill chan_fill_inner = na
var linefill chan_fill_outer = na
var label    status_lbl   = na
var label    hh_end_lbl   = na
var label    ll_end_lbl   = na

// Glow opacity = 50, core opacity = 0 (full)
int GLOW_WIDTH_BONUS = 7
int glow_width = line_width_inp + GLOW_WIDTH_BONUS

if barstate.islast
    // 1. Delete linefills FIRST (depend on lines)
    if not na(chan_fill_inner)
        linefill.delete(chan_fill_inner)
        chan_fill_inner := na
    if not na(chan_fill_outer)
        linefill.delete(chan_fill_outer)
        chan_fill_outer := na

    // 2. Delete old line objects (glow + core for both HH and LL)
    if not na(hh_glow)
        line.delete(hh_glow)
        hh_glow := na
    if not na(hh_core)
        line.delete(hh_core)
        hh_core := na
    if not na(ll_glow)
        line.delete(ll_glow)
        ll_glow := na
    if not na(ll_core)
        line.delete(ll_core)
        ll_core := na

    // 3. Delete old endpoint labels
    if not na(hh_end_lbl)
        label.delete(hh_end_lbl)
        hh_end_lbl := na
    if not na(ll_end_lbl)
        label.delete(ll_end_lbl)
        ll_end_lbl := na

    // 4. Create new active lines (two-layer neon)
    int   end_bar    = bar_index + 50
    float hh_end_y   = na
    float ll_end_y   = na

    if show_lines_inp and hh_active
        hh_end_y := hh_p1_price + hh_slope * (end_bar - hh_p1_bar)
        // Layer A — outer glow
        hh_glow := line.new(hh_p1_bar, hh_p1_price, end_bar, hh_end_y,
             color=color.new(trend_color, 50),
             width=glow_width,
             style=line.style_solid,
             extend=extend.right)
        // Layer B — inner core
        hh_core := line.new(hh_p1_bar, hh_p1_price, end_bar, hh_end_y,
             color=color.new(trend_color, 0),
             width=line_width_inp,
             style=line.style_solid,
             extend=extend.right)

    if show_lines_inp and ll_active
        ll_end_y := ll_p1_price + ll_slope * (end_bar - ll_p1_bar)
        ll_glow := line.new(ll_p1_bar, ll_p1_price, end_bar, ll_end_y,
             color=color.new(trend_color, 50),
             width=glow_width,
             style=line.style_solid,
             extend=extend.right)
        ll_core := line.new(ll_p1_bar, ll_p1_price, end_bar, ll_end_y,
             color=color.new(trend_color, 0),
             width=line_width_inp,
             style=line.style_solid,
             extend=extend.right)

    // 5. Channel fill (two-layer gradient): only stable structures
    bool show_channel_fill = trend_class == "Uptrend" or trend_class == "Downtrend" or trend_class == "Range"
    if show_fill_inp and show_channel_fill and not na(hh_core) and not na(ll_core)
        // Inner bright fill between core lines
        chan_fill_inner := linefill.new(hh_core, ll_core,
             color=color.new(trend_color, 70))
        // Outer subtle fill between glow lines
        if not na(hh_glow) and not na(ll_glow)
            chan_fill_outer := linefill.new(hh_glow, ll_glow,
                 color=color.new(trend_color, 88))

    // 6. Endpoint anchor labels
    if show_endlbls_inp and hh_active and not na(hh_end_y)
        hh_end_lbl := label.new(end_bar, hh_end_y,
             "▶ HH",
             style=label.style_label_left,
             color=color.new(trend_color, 20),
             textcolor=C_WHITE,
             size=size.normal,
             textalign=text.align_left)

    if show_endlbls_inp and ll_active and not na(ll_end_y)
        ll_end_lbl := label.new(end_bar, ll_end_y,
             "▶ LL",
             style=label.style_label_left,
             color=color.new(trend_color, 20),
             textcolor=C_WHITE,
             size=size.normal,
             textalign=text.align_left)

    // 7. Status indicator — large colored badge
    if not na(status_lbl)
        label.delete(status_lbl)
        status_lbl := na

    if show_status_inp and trend_class != "Building"
        string sym = trend_class == "Uptrend" ? "↗ UP" : trend_class == "Downtrend" ? "↘ DOWN" : trend_class == "Expanding" ? "↗↘ EXP" : trend_class == "Contracting" ? "↘↗ CON" : trend_class == "Range" ? "⇆ RANGE" : trend_class == "LL Trending" ? "↗ LL" : trend_class == "HH Trending" ? "↗ HH" : ""
        float status_y = anchor_high + atr14 * 1.5
        status_lbl := label.new(bar_index, status_y, sym,
             style=label.style_label_down,
             color=color.new(trend_color, 25),
             textcolor=C_WHITE,
             size=size.normal,
             textalign=text.align_center)

// Pivot markers — only most recent few (FIFO, limit 6).
// Older pivots stay informationally encoded in the line endpoints; markers
// just show "where the current structure is anchored".
var array<label> pivot_lbls = array.new<label>()
int PIVOT_LBL_LIMIT = 6

f_pivot_push(label lb) =>
    array.push(pivot_lbls, lb)
    if array.size(pivot_lbls) > PIVOT_LBL_LIMIT
        label oldest = array.shift(pivot_lbls)
        if not na(oldest)
            label.delete(oldest)

if show_pivots_inp and not na(pivot_high_now)
    label new_lbl = label.new(bar_index - pivot_lookback, pivot_high_now,
         "▼",
         style=label.style_label_down,
         color=color.new(C_BEAR, 30),
         textcolor=C_WHITE,
         size=size.small)
    f_pivot_push(new_lbl)

if show_pivots_inp and not na(pivot_low_now)
    label new_lbl = label.new(bar_index - pivot_lookback, pivot_low_now,
         "▲",
         style=label.style_label_up,
         color=color.new(C_BULL, 30),
         textcolor=C_WHITE,
         size=size.small)
    f_pivot_push(new_lbl)

// ============================================================================
// SECTION 8 — MTF PANEL
// ============================================================================

f_class_color(string cls, int dir) =>
    cls == "Uptrend" ? C_BULL : cls == "Downtrend" ? C_BEAR : cls == "Expanding" ? C_AMBER : cls == "Contracting" ? C_AMBER : cls == "LL Trending" ? (dir > 0 ? C_BULL : dir < 0 ? C_BEAR : C_SEC) : cls == "HH Trending" ? (dir > 0 ? C_BULL : dir < 0 ? C_BEAR : C_SEC) : C_SEC

f_strength_bars(float s) =>
    int filled = math.floor(s * 7 / 0.30)
    filled := math.min(filled, 6)
    filled := math.max(filled, 0)
    str.repeat("█", filled) + str.repeat("░", 7 - filled)

var table panel = table.new(position.top_right, 2, 10,
     bgcolor=na, border_width=0, frame_width=0)

if show_panel_inp and barstate.islast
    table.clear(panel, 0, 0, 1, 9)

    // --- Header (much brighter — opacity 25, was 75) ---
    table.cell(panel, 0, 0, "SMART TRENDLINE",
         text_color=C_WHITE, bgcolor=color.new(trend_color, 25),
         text_size=size.normal, text_halign=text.align_left)
    table.cell(panel, 1, 0, syminfo.ticker,
         text_color=C_WHITE, bgcolor=color.new(trend_color, 25),
         text_size=size.normal, text_halign=text.align_right)

    // --- Trend ---
    string trend_display = trend_class == "Building" ? "Building..." : trend_class + " (" + strength_class + ")"
    color tcol = trend_color

    table.cell(panel, 0, 1, "Trend",
         text_color=C_LBL, bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 1, trend_display,
         text_color=tcol, bgcolor=P_ROW,
         text_size=size.normal, text_halign=text.align_right)

    table.cell(panel, 0, 2, "Slope",
         text_color=C_LBL, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 2, strength_class,
         text_color=tcol, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_right)

    string hh_str = hh_active ? str.tostring(hh_line_now, format.mintick) : "—"
    table.cell(panel, 0, 3, "HH Line",
         text_color=C_LBL, bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 3, hh_str,
         text_color=C_WHITE, bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_right)

    string ll_str = ll_active ? str.tostring(ll_line_now, format.mintick) : "—"
    table.cell(panel, 0, 4, "LL Line",
         text_color=C_LBL, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 4, ll_str,
         text_color=C_WHITE, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_right)

    table.cell(panel, 0, 5, "MTF SCREENER",
         text_color=C_WHITE, bgcolor=P_SEP,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 5, "",
         bgcolor=P_SEP)

    string mtf1_label = mtf1_cls == "Building" ? "Building..." : f_strength_bars(mtf1_str) + " " + mtf1_cls + " " + mtf1_str_cls
    string mtf2_label = mtf2_cls == "Building" ? "Building..." : f_strength_bars(mtf2_str) + " " + mtf2_cls + " " + mtf2_str_cls
    string mtf3_label = mtf3_cls == "Building" ? "Building..." : f_strength_bars(mtf3_str) + " " + mtf3_cls + " " + mtf3_str_cls

    table.cell(panel, 0, 6, mtf1_tf,
         text_color=C_LBL, bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 6, mtf1_label,
         text_color=f_class_color(mtf1_cls, mtf1_dir), bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_right)

    table.cell(panel, 0, 7, mtf2_tf,
         text_color=C_LBL, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 7, mtf2_label,
         text_color=f_class_color(mtf2_cls, mtf2_dir), bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_right)

    table.cell(panel, 0, 8, mtf3_tf,
         text_color=C_LBL, bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 8, mtf3_label,
         text_color=f_class_color(mtf3_cls, mtf3_dir), bgcolor=P_ROW,
         text_size=size.small, text_halign=text.align_right)

    string ch_text = "—"
    if both_lines
        float channel_width     = math.abs(hh_line_now - ll_line_now)
        float channel_width_pct = channel_width / close * 100
        ch_text := str.tostring(channel_width, format.mintick) + " (" +
                   str.tostring(channel_width_pct, "#.#") + "%)"

    color ch_value_color = both_lines ? C_WHITE : C_DIM
    table.cell(panel, 0, 9, "Channel",
         text_color=C_LBL, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 9, ch_text,
         text_color=ch_value_color, bgcolor=P_BG,
         text_size=size.small, text_halign=text.align_right)

// ============================================================================
// SECTION 9 — ALERTS
// ============================================================================

// All alerts gated by barstate.isconfirmed to ensure they fire only on closed bars
// (prevents multiple intra-bar firings on real-time tick updates).
bool trend_changed = barstate.isconfirmed and (trend_class != trend_class[1])
bool hh_break_alert = barstate.isconfirmed and hh_broken and not hh_broken[1]
bool ll_break_alert = barstate.isconfirmed and ll_broken and not ll_broken[1]

alertcondition(trend_changed and alert_change_inp,
     title="Trend Class Changed",
     message="Auto TL MTF: Trend class changed on {{ticker}} ({{interval}})")

alertcondition(hh_break_alert and alert_break_inp,
     title="Resistance Break",
     message="Auto TL MTF: Resistance (HH) trendline broken upward on {{ticker}}")

alertcondition(ll_break_alert and alert_break_inp,
     title="Support Break",
     message="Auto TL MTF: Support (LL) trendline broken downward on {{ticker}}")
````
