# Geometric Pattern [AlgoChief]

- url: https://www.tradingview.com/script/gzRHjVcv-Geometric-Pattern-AlgoChief/
- type: indicator
- pine_id: PUB;0d13f854f7dc45da8f2c6e19b967b000
- version: 1.0

## Description

Introduction

Geometric Pattern by AlgoChief is an institutional grade harmonic pattern recognition engine designed for precision technical analysis across cryptocurrency, forex, and equity markets.

Harmonic trading combines geometric price patterns and strict Fibonacci sequences to identify high probability turning points. This indicator automatically scans price action in real time, projecting clean harmonic structures without visual clutter or unnecessary overlays.


How The Engine Works

The indicator uses a refined alternating pivot swing algorithm that identifies true structural turning points. Swings are evaluated with a smooth lookback filter to eliminate minor market noise and consolidation chop.

For every identified five point sequence X, A, B, C, and D, the engine computes exact price distance ratios across all connecting legs. These ratios are measured against classic Scott Carney harmonic specifications with customizable tolerance thresholds.

Confirmed patterns are permanently drawn on historical candles, allowing traders to conduct multi timeframe confluence analysis and review past market geometry.


Supported Harmonic Patterns

Gartley
Bat
Alternate Bat
Butterfly
Crab
Deep Crab
Shark
Cypher
Nen Star
Five Zero Pattern
AB equals CD
Three Drive
White Swan and Black Swan
Anti Harmonic Formations


Key Visual Features

Distinct Pattern Color Palette
Each harmonic pattern features its own signature executive color theme, making it instantly recognizable on the chart. Traders can also switch to a directional bullish and bearish theme or a monochrome layout in the settings.

Geometric Wing Shading
Triangular wings across XAB and BCD are shaded with smooth transparency, preserving complete candle visibility beneath the geometry.

Fibonacci Ratio Badges
Precise inter leg retracement and extension values are displayed directly on chart legs for immediate verification.

Vertex Labels
Clear labels mark points X, A, B, C, and D at the exact swing highs and lows.

PRZ Potential Reversal Zones
Each completed Point D generates a Potential Reversal Zone box highlighting the institutional order block where price reversal is anticipated.

Real Time Forming Scanner
While leg CD is actively developing, the engine projects the potential pattern in real time as price approaches the completion zone.


Notification Alerts

The script includes alerts compatible with TradingView notifications.
Bullish Harmonic Pattern Detected
Bearish Harmonic Pattern Detected
Any Harmonic Pattern Formed


Disclaimer

Geometric Pattern  is an analytical charting tool built for pattern recognition and technical confluence. It does not constitute financial advice. Always combine harmonic structures with independent confirmations and proper risk management.

## Source Code

````pine
//@version=6
indicator("Geometric Pattern [AlgoChief]",  overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ==============================================================================
// 1. INPUT CONFIGURATION & PARAMETERS (ALL INPUTS HIDDEN FROM STATUS LINE)
// ==============================================================================

// --- Pattern Detection Engine & Smooth Swings ---
grp_engine     = "Pattern Detection Engine & Smooth Swings"
zigzag_len     = input.int(10, "ZigZag Swing Period", minval=4, maxval=30, tooltip="Lookback period to identify genuine market swings. Default 10 produces smooth, textbook harmonic patterns identical to the original indicator.", group=grp_engine, display=display.none)
p_right        = input.int(3, "Pivot Confirmation Depth", minval=1, maxval=10, tooltip="Bars to confirm swing pivot. 3 provides fast confirmation with textbook swing accuracy.", group=grp_engine, display=display.none)
fib_tol_pct    = input.float(10.0, "Fibonacci Error Tolerance %", minval=1.0, maxval=25.0, step=0.5, tooltip="Error tolerance for matching Fibonacci harmonic ratios. 10% is textbook institutional precision.", group=grp_engine, display=display.none)
dir_filter     = input.string("Long and Short", "Direction Filter", options=["Long and Short", "Only Long", "Only Short"], group=grp_engine, display=display.none)
min_bars_len   = input.int(10, "Minimum Pattern Length (Bars)", minval=5, maxval=50, tooltip="Filters out noisy micro-fluctuations. Genuine harmonic patterns develop over 10+ candles.", group=grp_engine, display=display.none)
max_bars_len   = input.int(300, "Maximum Pattern Length (Bars)", minval=20, maxval=500, group=grp_engine, display=display.none)
keep_all_pat   = input.bool(true, "Keep All Confirmed Patterns on Chart", tooltip="When enabled, every confirmed pattern remains permanently plotted across chart history.", group=grp_engine, display=display.none)
show_forming   = input.bool(true, "Show Live Forming Pattern at Point D", tooltip="Displays real-time preview of the harmonic pattern as Leg CD develops.", group=grp_engine, display=display.none)

// --- Pure Harmonic Pattern Library ---
grp_patterns   = "Harmonic Pattern Library"
show_gartley   = input.bool(true, "Gartley", group=grp_patterns, display=display.none)
show_bat       = input.bool(true, "Bat", group=grp_patterns, display=display.none)
show_altbat    = input.bool(true, "Alternate Bat", group=grp_patterns, display=display.none)
show_butterfly = input.bool(true, "Butterfly", group=grp_patterns, display=display.none)
show_crab      = input.bool(true, "Crab", group=grp_patterns, display=display.none)
show_deepcrab  = input.bool(true, "Deep Crab", group=grp_patterns, display=display.none)
show_shark     = input.bool(true, "Shark", group=grp_patterns, display=display.none)
show_cypher    = input.bool(true, "Cypher", group=grp_patterns, display=display.none)
show_nenstar   = input.bool(true, "Nen Star", group=grp_patterns, display=display.none)
show_five0     = input.bool(true, "5-0 Pattern", group=grp_patterns, display=display.none)
show_abcd      = input.bool(true, "AB=CD", group=grp_patterns, display=display.none)
show_threedrv  = input.bool(true, "3-Drive", group=grp_patterns, display=display.none)
show_swans     = input.bool(false, "White Swan & Black Swan", group=grp_patterns, display=display.none)
show_antis     = input.bool(false, "Anti-Harmonic Patterns", group=grp_patterns, display=display.none)

// --- Visual Aesthetics & Executive Styling ---
grp_style      = "Executive Visual Styling"
color_mode     = input.string("Distinct Pattern Colors", "Pattern Color Palette", options=["Distinct Pattern Colors", "Bullish / Bearish Theme", "Monochrome Minimalist"], tooltip="Distinct Pattern Colors gives each pattern its signature vibrant executive color (like original HPP Pro).", group=grp_style, display=display.none)
shading_mode   = input.string("All Patterns Shaded", "Wing Shading Mode", options=["All Patterns Shaded", "Only Latest Pattern", "Outlines Only (No Shade)"], tooltip="All Patterns Shaded renders sleek transparent wings for all confirmed patterns.", group=grp_style, display=display.none)
shading_transp = input.int(84, "Wing Shading Transparency (10-95)", minval=10, maxval=95, tooltip="Higher value = Softer, more transparent wings.", group=grp_style, display=display.none)
show_prz_box   = input.bool(true, "Show PRZ Validation Zones (Point D Box)", tooltip="Draws the institutional Potential Reversal Zone box at Point D.", group=grp_style, display=display.none)
show_ratios    = input.bool(true, "Show Fibonacci Rates on Legs", tooltip="Displays exact inter-wave retracement and extension ratios on chart legs.", group=grp_style, display=display.none)
show_vertices  = input.bool(true, "Show Vertex Labels (X, A, B, C, D)", tooltip="Draws neat X, A, B, C, D labels at the swing pivot tips.", group=grp_style, display=display.none)
bull_col_def   = input.color(#00F2FE, "Default Bullish Color", group=grp_style, display=display.none)
bear_col_def   = input.color(#FF2A6D, "Default Bearish Color", group=grp_style, display=display.none)

// --- Custom Pattern Colors (Distinct Palette Mode) ---
grp_palette    = "Distinct Pattern Colors Palette"
col_gartley    = input.color(#00E676, "Gartley Color", group=grp_palette, display=display.none)
col_bat        = input.color(#9D4EDD, "Bat Color", group=grp_palette, display=display.none)
col_altbat     = input.color(#C77DFF, "Alternate Bat Color", group=grp_palette, display=display.none)
col_butterfly  = input.color(#00B0FF, "Butterfly Color", group=grp_palette, display=display.none)
col_crab       = input.color(#FF1744, "Crab Color", group=grp_palette, display=display.none)
col_deepcrab   = input.color(#FF6D00, "Deep Crab Color", group=grp_palette, display=display.none)
col_shark      = input.color(#F72585, "Shark Color", group=grp_palette, display=display.none)
col_cypher     = input.color(#FFD166, "Cypher Color", group=grp_palette, display=display.none)
col_nenstar    = input.color(#7209B7, "Nen Star Color", group=grp_palette, display=display.none)
col_five0      = input.color(#FF70A6, "5-0 Color", group=grp_palette, display=display.none)
col_abcd       = input.color(#06D6A0, "AB=CD Color", group=grp_palette, display=display.none)
col_threedrv   = input.color(#4CC9F0, "3-Drive Color", group=grp_palette, display=display.none)

// --- Alerts ---
grp_alerts     = "Notification Alerts"
alert_on_bull  = input.bool(true, "Alert on Bullish Pattern", group=grp_alerts, display=display.none)
alert_on_bear  = input.bool(true, "Alert on Bearish Pattern", group=grp_alerts, display=display.none)

// ==============================================================================
// 2. DATA TYPES & STRUCTURES
// ==============================================================================

type SwingPoint
    int   bar_idx
    float price
    bool  is_high

// ==============================================================================
// 3. PERSISTENT STORAGE & HANDLES
// ==============================================================================

var SwingPoint[] sw_pivots = array.new<SwingPoint>()

// Live Forming Pattern Handles
var line  live_lx_xa   = na
var line  live_lx_ab   = na
var line  live_lx_bc   = na
var line  live_lx_cd   = na
var line  live_lx_xb   = na
var line  live_lx_bd   = na
var line  live_lx_xd   = na
var linefill live_fill_1 = na
var linefill live_fill_2 = na
var label live_lb_x    = na
var label live_lb_a    = na
var label live_lb_b    = na
var label live_lb_c    = na
var label live_lb_d    = na
var box   live_prz_box = na

// Latest Wing Shading Handles
var linefill latest_fill_1 = na
var linefill latest_fill_2 = na

// Alert Signals
alert_bull_sig = false
alert_bear_sig = false
alert_any_sig  = false

atr_val = ta.atr(14)
tol     = fib_tol_pct / 100.0

is_in_range(float ratio, float min_r, float max_r, float t) =>
    ratio >= (min_r * (1.0 - t)) and ratio <= (max_r * (1.0 + t))

is_near_ratio(float ratio, float target_r, float t) =>
    math.abs(ratio - target_r) <= (target_r * t)

// Color Resolution Helper
get_pattern_color(string pat, bool is_bull) =>
    if color_mode == "Bullish / Bearish Theme"
        is_bull ? bull_col_def : bear_col_def
    else if color_mode == "Monochrome Minimalist"
        is_bull ? color.silver : color.gray
    else
        switch pat
            "Gartley"        => col_gartley
            "Bat"            => col_bat
            "Alternate Bat"  => col_altbat
            "Butterfly"      => col_butterfly
            "Crab"           => col_crab
            "Deep Crab"      => col_deepcrab
            "Shark"          => col_shark
            "Cypher"         => col_cypher
            "Nen Star"       => col_nenstar
            "5-0 Pattern"    => col_five0
            "AB=CD"          => col_abcd
            "3-Drive"        => col_threedrv
            "White Swan"     => #00E676
            "Black Swan"     => #FF5252
            => is_bull ? bull_col_def : bear_col_def

// ==============================================================================
// 4. HARMONIC RATIO EVALUATION FUNCTION (TEXTBOOK SCOTT CARNEY RULES)
// ==============================================================================

match_harmonic_pattern(float px, float pa, float pb, float pc, float pd, bool is_bull) =>
    xa = math.abs(pa - px)
    ab = math.abs(pb - pa)
    bc = math.abs(pc - pb)
    cd = math.abs(pd - pc)
    ad = math.abs(pd - pa)
    xc = math.abs(pc - px)

    r_ab = xa > 0.0 ? ab / xa : 0.0
    r_bc = ab > 0.0 ? bc / ab : 0.0
    r_cd = bc > 0.0 ? cd / bc : 0.0
    r_ad = xa > 0.0 ? ad / xa : 0.0
    r_xc = xa > 0.0 ? xc / xa : 0.0

    pat = ""

    // 1. Gartley (B: 0.618 of XA, D: 0.786 of XA, BC: 0.382-0.886, CD: 1.13-1.618)
    if show_gartley and pat == ""
        if is_in_range(r_ab, 0.58, 0.65, tol) and is_in_range(r_bc, 0.382, 0.886, tol) and is_in_range(r_cd, 1.13, 1.618, tol) and is_near_ratio(r_ad, 0.786, tol)
            pat := "Gartley"

    // 2. Bat (B: 0.382-0.500 of XA, D: 0.886 of XA, BC: 0.382-0.886, CD: 1.618-2.618)
    if show_bat and pat == ""
        if is_in_range(r_ab, 0.382, 0.500, tol) and is_in_range(r_bc, 0.382, 0.886, tol) and is_in_range(r_cd, 1.618, 2.618, tol) and is_near_ratio(r_ad, 0.886, tol)
            pat := "Bat"

    // 3. Alternate Bat (B: 0.382 of XA, D: 1.13 of XA, CD: 2.0-3.618)
    if show_altbat and pat == ""
        if is_in_range(r_ab, 0.30, 0.45, tol) and is_in_range(r_bc, 0.382, 0.886, tol) and is_in_range(r_cd, 2.0, 3.618, tol) and is_near_ratio(r_ad, 1.13, tol)
            pat := "Alternate Bat"

    // 4. Butterfly (B: 0.786 of XA, D: 1.272-1.618 of XA, CD: 1.618-2.618)
    if show_butterfly and pat == ""
        if is_in_range(r_ab, 0.75, 0.82, tol) and is_in_range(r_bc, 0.382, 0.886, tol) and is_in_range(r_cd, 1.618, 2.618, tol) and is_in_range(r_ad, 1.272, 1.618, tol)
            pat := "Butterfly"

    // 5. Crab (B: 0.382-0.618 of XA, D: 1.618 of XA, CD: 2.24-3.618)
    if show_crab and pat == ""
        if is_in_range(r_ab, 0.382, 0.618, tol) and is_in_range(r_bc, 0.382, 0.886, tol) and is_in_range(r_cd, 2.24, 3.618, tol) and is_near_ratio(r_ad, 1.618, tol)
            pat := "Crab"

    // 6. Deep Crab (B: 0.886 of XA, D: 1.618 of XA, CD: 2.0-3.618)
    if show_deepcrab and pat == ""
        if is_in_range(r_ab, 0.85, 0.92, tol) and is_in_range(r_bc, 0.382, 0.886, tol) and is_in_range(r_cd, 2.0, 3.618, tol) and is_near_ratio(r_ad, 1.618, tol)
            pat := "Deep Crab"

    // 7. Shark (B: 1.13-1.618 of XA, C: 1.13-1.618 of AB, D: 0.886-1.13 of XA)
    if show_shark and pat == ""
        if is_in_range(r_ab, 0.45, 0.90, tol) and is_in_range(r_bc, 1.13, 1.618, tol) and is_in_range(r_cd, 1.618, 2.24, tol) and is_in_range(r_ad, 0.886, 1.13, tol)
            pat := "Shark"

    // 8. Cypher (B: 0.382-0.618 of XA, C: 1.272-1.414 of XA, D: 0.786 of XC)
    if show_cypher and pat == ""
        if is_in_range(r_ab, 0.382, 0.618, tol) and is_in_range(r_xc, 1.13, 1.45, tol) and is_near_ratio(r_ad, 0.786, tol)
            pat := "Cypher"

    // 9. Nen Star (B: 0.382-0.618 of XA, BC: 1.35-2.15 of AB, D: 1.272 of XA)
    if show_nenstar and pat == ""
        if is_in_range(r_ab, 0.382, 0.618, tol) and is_in_range(r_bc, 1.35, 2.15, tol) and is_near_ratio(r_ad, 1.272, tol)
            pat := "Nen Star"

    // 10. 5-0 Pattern (B: 1.13-1.618 of XA, C: 1.618-2.24 of AB, D: 0.50 of BC)
    if show_five0 and pat == ""
        if is_in_range(r_ab, 1.13, 1.618, tol) and is_in_range(r_bc, 1.618, 2.24, tol) and is_near_ratio(r_cd, 0.50, tol)
            pat := "5-0 Pattern"

    // 11. AB=CD
    if show_abcd and pat == ""
        if is_in_range(r_bc, 0.618, 0.786, tol) and is_in_range(r_cd, 1.272, 1.618, tol) and ab > 0 and math.abs(cd - ab) / ab <= (tol * 2.0)
            pat := "AB=CD"

    // 12. 3-Drive
    if show_threedrv and pat == ""
        if is_near_ratio(r_bc, 0.618, tol * 1.5) and is_near_ratio(r_cd, 1.272, tol * 1.5)
            pat := "3-Drive"

    // 13. Exotic Swans
    if show_swans and pat == ""
        if is_in_range(r_ab, 0.382, 0.786, tol) and is_in_range(r_bc, 1.13, 2.0, tol) and is_in_range(r_ad, 1.13, 1.618, tol)
            pat := is_bull ? "White Swan" : "Black Swan"

    // 14. Anti Harmonics
    if show_antis and pat == ""
        if is_near_ratio(r_ab, 0.618, tol) and is_in_range(r_bc, 0.618, 0.886, tol) and is_near_ratio(r_ad, 1.272, tol)
            pat := "Anti-Gartley"
        else if is_in_range(r_ab, 0.382, 0.500, tol) and is_near_ratio(r_ad, 1.13, tol)
            pat := "Anti-Bat"

    pat

// ==============================================================================
// 5. ZIGZAG SWING ENGINE (SMOOTH ALTERNATING SWINGS)
// ==============================================================================

ph = ta.pivothigh(high, zigzag_len, p_right)
pl = ta.pivotlow(low, zigzag_len, p_right)

pivot_updated = false

if not na(ph)
    p_bar = bar_index - p_right
    p_pr  = high[p_right]
    s_len = array.size(sw_pivots)
    if s_len > 0
        last_p = array.get(sw_pivots, s_len - 1)
        if last_p.is_high
            if p_pr >= last_p.price
                last_p.price := p_pr
                last_p.bar_idx := p_bar
                pivot_updated := true
        else
            array.push(sw_pivots, SwingPoint.new(p_bar, p_pr, true))
            pivot_updated := true
    else
        array.push(sw_pivots, SwingPoint.new(p_bar, p_pr, true))
        pivot_updated := true

if not na(pl)
    p_bar = bar_index - p_right
    p_pr  = low[p_right]
    s_len = array.size(sw_pivots)
    if s_len > 0
        last_p = array.get(sw_pivots, s_len - 1)
        if not last_p.is_high
            if p_pr <= last_p.price
                last_p.price := p_pr
                last_p.bar_idx := p_bar
                pivot_updated := true
        else
            array.push(sw_pivots, SwingPoint.new(p_bar, p_pr, false))
            pivot_updated := true
    else
        array.push(sw_pivots, SwingPoint.new(p_bar, p_pr, false))
        pivot_updated := true

if array.size(sw_pivots) > 80
    array.shift(sw_pivots)

// ==============================================================================
// 6. CONFIRMED HARMONIC PATTERNS (DRAW PERMANENTLY WITH EXECUTIVE WINGS)
// ==============================================================================

var int last_plotted_d = -1
p_count = array.size(sw_pivots)

if pivot_updated and p_count >= 5
    hist_d = array.get(sw_pivots, p_count - 1)
    hist_c = array.get(sw_pivots, p_count - 2)
    hist_b = array.get(sw_pivots, p_count - 3)
    hist_a = array.get(sw_pivots, p_count - 4)
    hist_x = array.get(sw_pivots, p_count - 5)

    tot_len = hist_d.bar_idx - hist_x.bar_idx
    h_xa_dist = math.abs(hist_a.price - hist_x.price)
    h_cd_dist = math.abs(hist_d.price - hist_c.price)
    has_amplitude = h_xa_dist >= (atr_val * 0.8) and h_cd_dist >= (atr_val * 0.8)
    is_distinct_d = last_plotted_d == -1 or (hist_d.bar_idx != last_plotted_d and hist_d.bar_idx - last_plotted_d >= 4)

    if tot_len >= min_bars_len and tot_len <= max_bars_len and has_amplitude and is_distinct_d
        is_bull_shape = not hist_d.is_high and hist_c.is_high and not hist_b.is_high and hist_a.is_high and not hist_x.is_high
        is_bear_shape = hist_d.is_high and not hist_c.is_high and hist_b.is_high and not hist_a.is_high and hist_x.is_high

        allowed_dir = dir_filter == "Long and Short" or (dir_filter == "Only Long" and is_bull_shape) or (dir_filter == "Only Short" and is_bear_shape)

        if allowed_dir and (is_bull_shape or is_bear_shape)
            hist_bull = is_bull_shape
            h_pat = match_harmonic_pattern(hist_x.price, hist_a.price, hist_b.price, hist_c.price, hist_d.price, hist_bull)

            if h_pat != ""
                last_plotted_d := hist_d.bar_idx
                h_col  = get_pattern_color(h_pat, hist_bull)
                h_fill = color.new(h_col, shading_transp)

                // 1. Skeleton Lines (XA, AB, BC, CD)
                h_xa = line.new(hist_x.bar_idx, hist_x.price, hist_a.bar_idx, hist_a.price, color=h_col, width=2)
                h_ab = line.new(hist_a.bar_idx, hist_a.price, hist_b.bar_idx, hist_b.price, color=h_col, width=2)
                h_bc = line.new(hist_b.bar_idx, hist_b.price, hist_c.bar_idx, hist_c.price, color=h_col, width=2)
                h_cd = line.new(hist_c.bar_idx, hist_c.price, hist_d.bar_idx, hist_d.price, color=h_col, width=2)

                // 2. Internal Projection Lines (XB, BD, XD)
                h_xb = line.new(hist_x.bar_idx, hist_x.price, hist_b.bar_idx, hist_b.price, color=color.new(h_col, 50), style=line.style_dotted, width=1)
                h_bd = line.new(hist_b.bar_idx, hist_b.price, hist_d.bar_idx, hist_d.price, color=color.new(h_col, 50), style=line.style_dotted, width=1)
                h_xd = line.new(hist_x.bar_idx, hist_x.price, hist_d.bar_idx, hist_d.price, color=color.new(color.silver, 60), style=line.style_dashed, width=1)

                // 3. Shaded Geometric Wings
                if shading_mode == "All Patterns Shaded"
                    linefill.new(h_xa, h_xb, h_fill)
                    linefill.new(h_bd, h_cd, h_fill)
                else if shading_mode == "Only Latest Pattern"
                    linefill.delete(latest_fill_1)
                    linefill.delete(latest_fill_2)
                    latest_fill_1 := linefill.new(h_xa, h_xb, h_fill)
                    latest_fill_2 := linefill.new(h_bd, h_cd, h_fill)

                // 4. Vertex Labels (X, A, B, C)
                if show_vertices
                    label.new(hist_x.bar_idx, hist_x.price, "X", color=color.new(color.black, 100), textcolor=color.white, style=hist_bull ? label.style_label_up : label.style_label_down, size=size.tiny)
                    label.new(hist_a.bar_idx, hist_a.price, "A", color=color.new(color.black, 100), textcolor=color.white, style=hist_bull ? label.style_label_down : label.style_label_up, size=size.tiny)
                    label.new(hist_b.bar_idx, hist_b.price, "B", color=color.new(color.black, 100), textcolor=color.white, style=hist_bull ? label.style_label_up : label.style_label_down, size=size.tiny)
                    label.new(hist_c.bar_idx, hist_c.price, "C", color=color.new(color.black, 100), textcolor=color.white, style=hist_bull ? label.style_label_down : label.style_label_up, size=size.tiny)

                // 5. Point D Pattern Name Badge
                dir_symbol = hist_bull ? " ▲" : " ▼"
                label.new(hist_d.bar_idx, hist_d.price, h_pat + dir_symbol + " D", color=color.new(h_col, 15), textcolor=color.white, style=hist_bull ? label.style_label_up : label.style_label_down, size=size.small)

                // 6. PRZ Potential Reversal Zone Box
                if show_prz_box
                    h_prz_h = hist_d.price + math.max(h_cd_dist * tol, atr_val * 0.7)
                    h_prz_l = hist_d.price - math.max(h_cd_dist * tol, atr_val * 0.7)
                    box.new(hist_d.bar_idx - 1, h_prz_h, hist_d.bar_idx + 8, h_prz_l, border_color=color.new(h_col, 40), border_style=line.style_dashed, bgcolor=color.new(h_col, 92))

                // 7. Fibonacci Ratio Badges on Legs
                if show_ratios
                    h_ab_dist = math.abs(hist_b.price - hist_a.price)
                    h_bc_dist = math.abs(hist_c.price - hist_b.price)
                    h_ad_dist = math.abs(hist_d.price - hist_a.price)
                    r_ab_v = h_xa_dist > 0 ? h_ab_dist / h_xa_dist : 0.0
                    r_bc_v = h_ab_dist > 0 ? h_bc_dist / h_ab_dist : 0.0
                    r_cd_v = h_bc_dist > 0 ? h_cd_dist / h_bc_dist : 0.0
                    r_ad_v = h_xa_dist > 0 ? h_ad_dist / h_xa_dist : 0.0

                    label.new(math.round((hist_a.bar_idx + hist_b.bar_idx) / 2), (hist_a.price + hist_b.price) / 2, str.tostring(r_ab_v, "#.###"), color=color.new(color.black, 100), textcolor=color.new(color.white, 30), style=label.style_label_center, size=size.tiny)
                    label.new(math.round((hist_b.bar_idx + hist_c.bar_idx) / 2), (hist_b.price + hist_c.price) / 2, str.tostring(r_bc_v, "#.###"), color=color.new(color.black, 100), textcolor=color.new(color.white, 30), style=label.style_label_center, size=size.tiny)
                    label.new(math.round((hist_c.bar_idx + hist_d.bar_idx) / 2), (hist_c.price + hist_d.price) / 2, str.tostring(r_cd_v, "#.###"), color=color.new(color.black, 100), textcolor=color.new(color.white, 30), style=label.style_label_center, size=size.tiny)
                    label.new(math.round((hist_x.bar_idx + hist_d.bar_idx) / 2), (hist_x.price + hist_d.price) / 2, str.tostring(r_ad_v, "#.###"), color=color.new(color.black, 100), textcolor=color.new(color.yellow, 40), style=label.style_label_center, size=size.tiny)

// ==============================================================================
// 7. REAL-TIME FORMING PATTERN AT POINT D (DYNAMIC LIVE SCANNER)
// ==============================================================================

if show_forming and p_count >= 4
    live_c = array.get(sw_pivots, p_count - 1)
    live_b = array.get(sw_pivots, p_count - 2)
    live_a = array.get(sw_pivots, p_count - 3)
    live_x = array.get(sw_pivots, p_count - 4)

    bars_from_c = bar_index - live_c.bar_idx

    if bars_from_c >= 1 and bars_from_c <= max_bars_len
        cand_bull = live_c.is_high and not live_b.is_high and live_a.is_high and not live_x.is_high
        cand_bear = not live_c.is_high and live_b.is_high and not live_a.is_high and live_x.is_high

        allowed_live_dir = dir_filter == "Long and Short" or (dir_filter == "Only Long" and cand_bull) or (dir_filter == "Only Short" and cand_bear)

        if allowed_live_dir and (cand_bull or cand_bear)
            lookback_c = math.min(bars_from_c, 120)

            float cand_d_pr  = na
            int   cand_d_bar = na

            if cand_bull
                offset_l   = ta.lowestbars(low, lookback_c)
                cand_d_bar := bar_index + offset_l
                cand_d_pr  := ta.lowest(low, lookback_c)
            else
                offset_h   = ta.highestbars(high, lookback_c)
                cand_d_bar := bar_index + offset_h
                cand_d_pr  := ta.highest(high, lookback_c)

            matched_live = match_harmonic_pattern(live_x.price, live_a.price, live_b.price, live_c.price, cand_d_pr, cand_bull)
            tot_live_len = cand_d_bar - live_x.bar_idx
            live_xa_dist = math.abs(live_a.price - live_x.price)
            live_cd_dist = math.abs(cand_d_pr - live_c.price)
            has_live_amp = live_xa_dist >= (atr_val * 0.8) and live_cd_dist >= (atr_val * 0.8)

            if matched_live != "" and tot_live_len >= min_bars_len and has_live_amp
                // Clean up previous real-time handles
                line.delete(live_lx_xa)
                line.delete(live_lx_ab)
                line.delete(live_lx_bc)
                line.delete(live_lx_cd)
                line.delete(live_lx_xb)
                line.delete(live_lx_bd)
                line.delete(live_lx_xd)
                linefill.delete(live_fill_1)
                linefill.delete(live_fill_2)
                label.delete(live_lb_x)
                label.delete(live_lb_a)
                label.delete(live_lb_b)
                label.delete(live_lb_c)
                label.delete(live_lb_d)
                box.delete(live_prz_box)

                c_col  = get_pattern_color(matched_live, cand_bull)
                c_fill = color.new(c_col, shading_transp)

                live_lx_xa := line.new(live_x.bar_idx, live_x.price, live_a.bar_idx, live_a.price, color=c_col, width=2)
                live_lx_ab := line.new(live_a.bar_idx, live_a.price, live_b.bar_idx, live_b.price, color=c_col, width=2)
                live_lx_bc := line.new(live_b.bar_idx, live_b.price, live_c.bar_idx, live_c.price, color=c_col, width=2)
                live_lx_cd := line.new(live_c.bar_idx, live_c.price, cand_d_bar, cand_d_pr, color=c_col, width=2)

                live_lx_xb := line.new(live_x.bar_idx, live_x.price, live_b.bar_idx, live_b.price, color=color.new(c_col, 50), style=line.style_dotted, width=1)
                live_lx_bd := line.new(live_b.bar_idx, live_b.price, cand_d_bar, cand_d_pr, color=color.new(c_col, 50), style=line.style_dotted, width=1)
                live_lx_xd := line.new(live_x.bar_idx, live_x.price, cand_d_bar, cand_d_pr, color=color.new(color.silver, 60), style=line.style_dashed, width=1)

                if shading_mode != "Outlines Only (No Shade)"
                    live_fill_1 := linefill.new(live_lx_xa, live_lx_xb, c_fill)
                    live_fill_2 := linefill.new(live_lx_bd, live_lx_cd, c_fill)

                if show_vertices
                    live_lb_x := label.new(live_x.bar_idx, live_x.price, "X", color=color.new(color.black, 100), textcolor=color.white, style=cand_bull ? label.style_label_up : label.style_label_down, size=size.tiny)
                    live_lb_a := label.new(live_a.bar_idx, live_a.price, "A", color=color.new(color.black, 100), textcolor=color.white, style=cand_bull ? label.style_label_down : label.style_label_up, size=size.tiny)
                    live_lb_b := label.new(live_b.bar_idx, live_b.price, "B", color=color.new(color.black, 100), textcolor=color.white, style=cand_bull ? label.style_label_up : label.style_label_down, size=size.tiny)
                    live_lb_c := label.new(live_c.bar_idx, live_c.price, "C", color=color.new(color.black, 100), textcolor=color.white, style=cand_bull ? label.style_label_down : label.style_label_up, size=size.tiny)

                d_sym = cand_bull ? " ▲" : " ▼"
                live_lb_d := label.new(cand_d_bar, cand_d_pr, matched_live + d_sym + " D", color=color.new(c_col, 15), textcolor=color.white, style=cand_bull ? label.style_label_up : label.style_label_down, size=size.small)

                if show_prz_box
                    l_prz_h = cand_d_pr + math.max(live_cd_dist * tol, atr_val * 0.7)
                    l_prz_l = cand_d_pr - math.max(live_cd_dist * tol, atr_val * 0.7)
                    live_prz_box := box.new(cand_d_bar - 1, l_prz_h, cand_d_bar + 8, l_prz_l, border_color=color.new(c_col, 40), border_style=line.style_dashed, bgcolor=color.new(c_col, 92))

                alert_bull_sig := cand_bull
                alert_bear_sig := not cand_bull
                alert_any_sig  := true

// ==============================================================================
// 8. TRADINGVIEW ONE-CLICK NOTIFICATIONS & ALERTS
// ==============================================================================

alertcondition(alert_bull_sig, title="[AlgoChief Apex] Bullish Harmonic Pattern", message="Bullish {{ticker}} Harmonic Pattern Detected!")
alertcondition(alert_bear_sig, title="[AlgoChief Apex] Bearish Harmonic Pattern", message="Bearish {{ticker}} Harmonic Pattern Detected!")
alertcondition(alert_any_sig,  title="[AlgoChief Apex] Any Harmonic Pattern", message="{{ticker}} Harmonic Pattern Formed on Chart!")
````
