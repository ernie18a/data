# Liquidity Heatmap

- url: https://www.tradingview.com/script/DPrdUZSh-Liquidity-Heatmap/
- type: indicator
- pine_id: PUB;fc50cbf8a94c4ad99eaa10a8d6f8f0a3
- version: 4.0

## Description

Liquidity Heatmap – POC and Value Area.

A rolling volume-density profile rendered directly onto the price chart. Over a configurable lookback window the indicator distributes each historical bar's volume across every price bin its high-low range covered, then draws the resulting distribution as color-graded horizontal lines at each bin's midpoint. Point of Control and Value Area (70 % of total volume) are computed automatically, and a compact right-side histogram mirrors the profile in the future-offset zone. Built for intraday and swing traders who want a live, minimal read of where the market actually did business — the real liquidity anchors, not manual pivots.

How it works:
The indicator recalculates every N bars (default 5). On each recalc it finds the highest and lowest price of the lookback window, splits that range into a configurable number of bins (default 40), and iterates through every bar in the window. For each bar its volume — or a unit weight if volume weighting is disabled — is added to every bin whose price range the bar crossed. The result is a density array: the more time price stayed inside a bin and the higher the volume of those bars, the larger its density value. Bins are drawn as thin horizontal lines at their midpoints, with color and transparency scaled by the ratio of bin density to peak density.

The Point of Control is the bin with the largest total. Value Area is grown outward from POC, alternately taking whichever adjacent side holds more volume, until 70 % of the entire distribution is covered — VAH becomes the upper boundary of that region and VAL the lower. A right-side density histogram in the chart's offset zone re-renders the same profile in bar-chart form, and the level labels (POC / VAH / VAL) sit past the histogram so they never overlap the main heatmap. The information panel in the top-right corner shows the numeric price of each level and its signed percentage delta to the current close, color-coded green when the level sits above price, red when below, gray at parity.

What it calculates:
- Volume density per price bin over the lookback window
- POC — Point of Control, the bin with peak accumulated volume
- VAH — Value Area High, upper boundary of the 70 % volume region
- VAL — Value Area Low, lower boundary of the 70 % volume region
- Signed delta from current close to POC / VAH / VAL, in percent

Key features:
- Rolling recalculation every N bars for tunable CPU / responsiveness balance
- Volume weighting (default) or touch-count mode as a per-price frequency map — useful when volume data is unreliable
- Four-stop plasma color gradient (deep navy → violet → magenta → amber), every stop user-overridable via input.color
- Constant 1-pixel line width across all bins; visual weight is carried entirely by color intensity and transparency
- POC solid line and label placed past the offset histogram for readability
- VAH / VAL dashed lines extended all the way to their labels so the eye follows the level continuously
- Compact right-side density histogram in the future-offset area, mirroring the main profile in bar-chart form
- Top-right information panel with POC / VAH / VAL price and signed percentage delta to the current close, colored by side (green above / red below / gray at parity)
- Independent visibility toggles for POC and Value Area
- Adaptive bin geometry — resolution scales automatically with the price range of the lookback window
- Runs on any timeframe and any instrument; no external data sources required

Who it's for:
Intraday scalpers, swing traders, order-flow and Market Profile practitioners who need to see the true volume anchors of the current regime instead of hand-drawn horizontals. The color-graded strips make dominant liquidity walls, thin gaps and Value Area boundaries visually obvious at a glance, so attention goes to execution rather than to marking up the chart.

## Source Code

````pine
// =============================================================================
// LIQUIDITY HEATMAP - POC AND VALUE AREA
// Rolling volume-density profile drawn directly on the price chart: each price
// bin of the lookback window is rendered as a color-graded horizontal line at
// its midpoint. Point of Control and Value Area (70 % of total volume) are
// computed automatically and mirrored in a compact right-side histogram.
// Built for intraday and swing traders who want a live read of where the
// market actually did business.
// =============================================================================
//@version=6
indicator("Liquidity Heatmap",
          shorttitle="Liquidity Heatmap",
          overlay=true,
          max_boxes_count=200,
          max_lines_count=500,
          max_labels_count=50)


// =============================================================================
// GROUP 1 — DATA
// =============================================================================
lookback = input.int(300, "Analysis window (bars)",
     minval=50, maxval=1500,
     tooltip="How many past bars enter the density calculation. Larger windows smooth the profile but respond slower to regime shifts. 300 is a responsive default that keeps the profile relevant to the current regime; raise to 500-800 for smoother intraday context, 1000+ for full-swing perspective on higher timeframes.",
     group="Data")

n_bins = input.int(80, "Number of price zones",
     minval=10, maxval=200,
     tooltip="Resolution of the profile. More zones = finer detail but noisier visualization. TradingView's built-in Volume Profile uses ~24-50 zones for reference. 80 is the sweet spot for most 1H-4H crypto — precise HVN/LVN placement without visible noise. Push to 100-150 for high-resolution work on wide-range instruments; drop to 40-60 on flat instruments to avoid fragmentation.",
     group="Data")

recalc_freq = input.int(5, "Recalculate every N bars",
     minval=1, maxval=50,
     tooltip="Redraw cadence. Lower = more responsive, higher CPU cost. Use 1 for scalping, 5-10 for intraday, 20+ for higher timeframes.",
     group="Data")

use_vol = input.bool(true, "Weight by volume (else by touch count)",
     tooltip="ON: each bar contributes its volume to every price bin it covered (industry-standard Volume Profile). OFF: each bar contributes 1 (frequency map, useful when volume data is unreliable, e.g. some spot pairs).",
     group="Data")


// =============================================================================
// GROUP 2 — LEVELS
// =============================================================================
show_poc = input.bool(true, "Show POC (Point of Control)",
     tooltip="POC = price bin with the largest accumulated volume. Acts as a magnet — price tends to revisit it, and it often becomes support / resistance on retest.",
     group="Levels")

show_va = input.bool(true, "Show VAH / VAL (Value Area, 70 %)",
     tooltip="Value Area = the price range containing 70 % of total volume. VAH is the upper boundary, VAL the lower. Sustained breakouts outside VA often signal a regime shift.",
     group="Levels")

histo_offset = input.int(6, "Histogram offset from last bar (bars)",
     minval=1, maxval=30,
     tooltip="How far to the right of the last bar the density histogram starts. Increase if the histogram overlaps the current price candle on your timeframe (typical: 3-5 for 1H+, 6-10 for 1-5m).",
     group="Levels")

show_lvn = input.bool(true, "Show liquidity voids (LVN)",
     tooltip="Marks price zones with very low accumulated volume. Price tends to travel through them fast because there are few resting orders to slow it down. Useful for setting profit targets and avoiding weak S/R.",
     group="Levels")

lvn_threshold = input.float(15.0, "LVN threshold (% of POC)",
     minval=1.0, maxval=40.0, step=1.0,
     tooltip="Bins whose volume is below this percentage of the POC bin are flagged as low-volume. Lower = only extreme voids; higher = more zones flagged. 10-20% is typical.",
     group="Levels")

lvn_min_bins = input.int(2, "Min consecutive bins for LVN zone",
     minval=1, maxval=10,
     tooltip="Number of consecutive low-volume bins required to render a zone. 1 = mark every single weak bin (noisy); 2-3 = only real vacuums where price will accelerate. Symmetric with the HVN min-bins input.",
     group="Levels")

lvn_between_hvn = input.bool(false, "Only voids sandwiched between HVN",
     tooltip="ON: draws only voids that sit between two high-volume nodes (density >= 50% of POC on both sides) — the classic 'valley between two peaks' setup, the cleanest LVN in Market Profile terms. OFF: draws every void that meets the threshold and length criteria. Edge voids that touch the top/bottom of the traded range are always excluded regardless of this switch.",
     group="Levels")

lvn_stripes = input.int(12, "LVN diagonal stripes",
     minval=4, maxval=30,
     tooltip="Number of 45-degree hatch lines drawn across each void zone. Higher = denser hatching, easier to spot the zone at a glance. On-screen angle depends on chart zoom.",
     group="Levels")

show_lvn_label = input.bool(true, "Show LVN zone label",
     tooltip="Prints a text tag centred on each void zone so its function (fast-move / no-reaction) is unambiguous at a glance.",
     group="Levels")

lvn_label_text = input.string("LVN · Path of Least Resistance",
     "LVN label text",
     tooltip="Text shown on each void zone. Suggested wording: 'LVN · Path of Least Resistance' (Livermore-style, universally understood), 'Liquidity Void — Fast Move', or 'Low Volume Node'.",
     group="Levels")

show_hvn = input.bool(true, "Show high-volume nodes (HVN)",
     tooltip="Marks price zones with unusually large accumulated volume — the market's 'fair value' pockets. Price tends to react at these zones (stall, reverse, or consolidate) because they hold the largest stack of resting orders. POC is the strongest HVN; this option surfaces the secondary peaks that would otherwise stay hidden in the color gradient.",
     group="Levels")

hvn_threshold = input.float(85.0, "HVN threshold (% of POC)",
     minval=30.0, maxval=95.0, step=1.0,
     tooltip="Bins whose volume reaches at least this percentage of the POC bin are flagged as high-volume. Higher = only near-POC peaks (stricter, cleaner picture — recommended). Lower = wider plateaus qualify (more zones, can visually merge on flat instruments). 80-90% is typical.",
     group="Levels")

hvn_min_bins = input.int(1, "Min consecutive bins for HVN zone",
     minval=1, maxval=10,
     tooltip="Number of consecutive high-volume bins required to render a zone. 1 = mark every single peak bin (finer, catches all significant levels — recommended), 2-3 = only wider high-volume plateaus. Kept lower than the LVN counterpart because missing an HVN loses a real reaction level, while a single-bin LVN is usually noise.",
     group="Levels")

show_hvn_label = input.bool(true, "Show HVN zone label",
     tooltip="Prints a text tag centred on each HVN zone so its function (reaction / S-R) is unambiguous.",
     group="Levels")

hvn_label_text = input.string("HVN · Reaction Zone",
     "HVN label text",
     tooltip="Text shown on each HVN zone. Suggested wording: 'HVN · Reaction Zone', 'High Volume Node', or 'Value Pocket'.",
     group="Levels")


// =============================================================================
// GROUP 3 — PALETTE
// =============================================================================
c_cold = input.color(#0d0221, "Weak liquidity zone",
     tooltip="Color for the lowest-volume bins (rarely traded price levels).",
     group="Palette")

c_cool = input.color(#6d28d9, "Medium",
     tooltip="Middle-tier volume bins.",
     group="Palette")

c_warm = input.color(#ec4899, "High",
     tooltip="High-volume bins — likely support / resistance zones.",
     group="Palette")

c_hot = input.color(#fbbf24, "Extreme",
     tooltip="Peak-volume bins — the strongest liquidity walls in the window.",
     group="Palette")

c_poc = input.color(#fbbf24, "POC color",
     tooltip="Color for the Point of Control line and its label.",
     group="Palette")

c_va = input.color(#ec4899, "Value Area color",
     tooltip="Color for the VAH / VAL dashed lines and their labels.",
     group="Palette")

c_lvn = input.color(color.new(#ef4444, 92), "Liquidity void fill",
     tooltip="Very translucent base fill for LVN zones. Kept faint on purpose so the diagonal hatching does the visual work.",
     group="Palette")

c_lvn_bd = input.color(color.new(#ef4444, 45), "Liquidity void border",
     tooltip="Border color for LVN zone rectangles.",
     group="Palette")

c_lvn_hatch = input.color(color.new(#ef4444, 60), "Liquidity void hatch",
     tooltip="Color of the 45-degree diagonal stripes inside each void zone. Lower alpha = more visible stripes.",
     group="Palette")

c_lvn_label = input.color(color.new(#ef4444, 15), "Liquidity void label",
     tooltip="Background color of the LVN zone text tag.",
     group="Palette")

c_hvn = input.color(color.new(#fbbf24, 92), "HVN zone fill",
     tooltip="Translucent fill for high-volume node zones. Kept faint so the underlying heatmap and price action remain readable.",
     group="Palette")

c_hvn_bd = input.color(color.new(#fbbf24, 35), "HVN zone border",
     tooltip="Border color for HVN zone rectangles.",
     group="Palette")

c_hvn_label = input.color(color.new(#fbbf24, 20), "HVN zone label",
     tooltip="Background color of the HVN zone text tag.",
     group="Palette")


// =============================================================================
// CONSTANTS — compile-time values, upper-case per convention
// =============================================================================
HISTO_WIDTH   = 15                     // max length (in bars) of right-side histogram bars
LBL_TXT       = color.new(#fdf4ff, 0)  // primary label text
LBL_TXT_DARK  = color.new(#0d0221, 0)  // text on light POC capsule
LBL_ACC_UP    = color.new(#22c55e, 20) // positive delta (level above price)
LBL_ACC_DOWN  = color.new(#ef4444, 20) // negative delta (level below price)
LBL_ACC_NEUT  = color.new(#94a3b8, 20) // near-zero delta


// =============================================================================
// DRAWABLE OBJECT STORAGE
// Arrays are prefixed by type — ln_* for lines, bx_* for boxes, lb_* for labels.
// Single-item drawings (POC line, labels, info table) are held in var slots.
// =============================================================================
var array<box>   bx_hist   = array.new_box()    // right-side histogram boxes
var array<box>   bx_lvn    = array.new_box()    // liquidity void (LVN) overlay boxes
var array<line>  ln_lvn    = array.new_line()   // diagonal hatch lines inside LVN zones
var array<label> lb_lvn    = array.new_label()  // labels tagged on each LVN zone
var array<box>   bx_hvn    = array.new_box()    // high volume node (HVN) overlay boxes
var array<label> lb_hvn    = array.new_label()  // labels tagged on each HVN zone
var array<line>  ln_heat   = array.new_line()   // main heatmap lines (one per bin)
var line        ln_poc    = na
var line        ln_vah    = na
var line        ln_val    = na
var label       lb_poc    = na
var label       lb_vah    = na
var label       lb_val    = na
var table       tbl_info  = table.new(position.top_right, 3, 3,
     bgcolor=color.new(color.white, 100),
     border_width=0,
     frame_width=0)


// =============================================================================
// HELPERS
// =============================================================================
// Wipe every drawn object before the next recalc pass. Called at the start of
// each redraw cycle so previous bins do not linger when window/bin count change.
f_clear_all() =>
    while array.size(bx_hist) > 0
        box.delete(array.pop(bx_hist))
    while array.size(bx_lvn) > 0
        box.delete(array.pop(bx_lvn))
    while array.size(ln_lvn) > 0
        line.delete(array.pop(ln_lvn))
    while array.size(lb_lvn) > 0
        label.delete(array.pop(lb_lvn))
    while array.size(bx_hvn) > 0
        box.delete(array.pop(bx_hvn))
    while array.size(lb_hvn) > 0
        label.delete(array.pop(lb_hvn))
    while array.size(ln_heat) > 0
        line.delete(array.pop(ln_heat))
    if not na(ln_poc)
        line.delete(ln_poc)
    if not na(ln_vah)
        line.delete(ln_vah)
    if not na(ln_val)
        line.delete(ln_val)
    if not na(lb_poc)
        label.delete(lb_poc)
    if not na(lb_vah)
        label.delete(lb_vah)
    if not na(lb_val)
        label.delete(lb_val)

// Interpolates a density ratio (0..1) across the 4-stop plasma gradient:
// cold → cool (0..0.33), cool → warm (0.33..0.66), warm → hot (0.66..1).
// Inside a function body Pine forbids multi-line ternaries, hence the if/else.
f_grad_color(float ratio) =>
    color result = c_cold
    if ratio < 0.33
        result := color.from_gradient(ratio / 0.33, 0.0, 1.0, c_cold, c_cool)
    else if ratio < 0.66
        result := color.from_gradient((ratio - 0.33) / 0.33, 0.0, 1.0, c_cool, c_warm)
    else
        result := color.from_gradient((ratio - 0.66) / 0.34, 0.0, 1.0, c_warm, c_hot)
    result

// Formats a signed percentage. Pine's built-in "+0.00" format produces
// "-+1.23" for negatives, so the sign is composed manually.
f_pct_str(float p) =>
    (p >= 0 ? "+" : "-") + str.tostring(math.abs(p), "0.00") + "%"


// =============================================================================
// MAIN RECALC — runs every `recalc_freq` bars once history is deep enough
// =============================================================================
if bar_index > lookback and bar_index % recalc_freq == 0
    f_clear_all()

    // -------------------------------------------------------------------------
    // Window bounds and bin geometry. If the window is flat (hi == lo) no
    // profile can be built — skip silently.
    // -------------------------------------------------------------------------
    hi = ta.highest(high, lookback)
    lo = ta.lowest(low,  lookback)
    if hi > lo
        bin_size = (hi - lo) / n_bins
        density  = array.new_float(n_bins, 0.0)

        // ---------------------------------------------------------------------
        // Distribute each bar's volume across every bin its range covers.
        // Bin indices are double-clamped ([0, n_bins-1]) as defensive guards
        // against float rounding at the boundaries.
        // ---------------------------------------------------------------------
        for i = 0 to lookback - 1
            b_hi = high[i]
            b_lo = low[i]
            b_vol = use_vol ? volume[i] : 1.0
            if not na(b_hi) and not na(b_lo) and not na(b_vol) and b_hi >= b_lo
                start_raw = int(math.floor((b_lo - lo) / bin_size))
                end_raw   = int(math.floor((b_hi - lo) / bin_size))
                bin_start = math.max(0, math.min(n_bins - 1, start_raw))
                bin_end   = math.max(0, math.min(n_bins - 1, end_raw))
                if bin_end >= bin_start
                    for b = bin_start to bin_end
                        array.set(density, b, array.get(density, b) + b_vol)

        max_dens   = array.max(density)
        total_dens = array.sum(density)
        left_x     = bar_index - lookback + 1
        right_x    = bar_index

        // Skip the drawing block entirely when the window carries no volume
        // (e.g. warm-up bars, volume-less symbols with use_vol enabled).
        if max_dens > 0

            // -----------------------------------------------------------------
            // POC and Value Area.
            // POC = bin with peak density. VA is grown outward from POC,
            // taking whichever adjacent side has more volume at each step,
            // until the accumulated volume reaches 70 % of total.
            // -----------------------------------------------------------------
            poc_idx   = array.indexof(density, max_dens)
            poc_price = lo + (poc_idx + 0.5) * bin_size
            va_sum    = max_dens
            va_lo_idx = poc_idx
            va_hi_idx = poc_idx
            target    = total_dens * 0.70
            while va_sum < target and (va_lo_idx > 0 or va_hi_idx < n_bins - 1)
                d_lo = va_lo_idx > 0          ? array.get(density, va_lo_idx - 1) : 0.0
                d_hi = va_hi_idx < n_bins - 1 ? array.get(density, va_hi_idx + 1) : 0.0
                if d_lo >= d_hi and va_lo_idx > 0
                    va_lo_idx -= 1
                    va_sum   += d_lo
                else if va_hi_idx < n_bins - 1
                    va_hi_idx += 1
                    va_sum   += d_hi
                else
                    break
            vah_price = lo + (va_hi_idx + 1) * bin_size
            val_price = lo + va_lo_idx * bin_size

            // -----------------------------------------------------------------
            // Main heatmap: one thin horizontal line at the center of each
            // bin. Color / transparency encode density (bright + opaque =
            // strong liquidity, faded = weak). Width is constant at 1 px so
            // visual weight comes purely from color intensity.
            // -----------------------------------------------------------------
            for b = 0 to n_bins - 1
                dens = array.get(density, b)
                if dens > 0
                    ratio   = dens / max_dens
                    // Alpha range 40 (weak) -> 10 (peak). Keeping the floor
                    // at 40 (not 60) ensures the coldest lines stay legible
                    // on dark themes instead of disappearing.
                    l_alpha = int(40 - math.round(ratio * 30))
                    l_col   = color.new(f_grad_color(ratio), l_alpha)
                    b_mid   = lo + (b + 0.5) * bin_size
                    ln      = line.new(left_x, b_mid, right_x, b_mid,
                                       color=l_col, width=1)
                    array.push(ln_heat, ln)

            // -----------------------------------------------------------------
            // Liquidity voids (LVN clusters). First we locate the real
            // traded range — the first and last bins that carry any
            // volume. Bins outside this span are pure wick tails (price
            // grazed them once with no execution), not real vacuum zones,
            // so we exclude them from the scan. Inside the traded range
            // we look for stretches of bins whose volume is below
            // `lvn_threshold`% of POC and at least `lvn_min_bins` long.
            // Each qualifying stretch is drawn as a translucent band
            // spanning the full lookback window — a visual "vacuum" where
            // price accelerates because there are few resting orders in
            // the way. When `lvn_between_hvn` is on, only voids sandwiched
            // between two high-volume nodes (density > 50% of POC on both
            // sides) are kept — the cleanest, textbook LVN setups.
            // -----------------------------------------------------------------
            if show_lvn
                first_nz = -1
                last_nz  = -1
                for b = 0 to n_bins - 1
                    if array.get(density, b) > 0
                        if first_nz == -1
                            first_nz := b
                        last_nz := b
                if first_nz >= 0 and last_nz > first_nz
                    lvn_cutoff = max_dens * lvn_threshold / 100.0
                    hvn_cutoff = max_dens * 0.50
                    cluster_start = -1
                    for b = first_nz to last_nz
                        is_lvn = array.get(density, b) < lvn_cutoff
                        if is_lvn and cluster_start == -1
                            cluster_start := b
                        is_last = b == last_nz
                        closes_cluster = (not is_lvn or is_last) and cluster_start != -1
                        if closes_cluster
                            cluster_end = is_lvn ? b : b - 1
                            cluster_len = cluster_end - cluster_start + 1
                            keep = cluster_len >= lvn_min_bins
                            if keep and (cluster_start == first_nz or cluster_end == last_nz)
                                keep := false
                            if keep and lvn_between_hvn
                                has_left_hvn  = cluster_start > first_nz and array.get(density, cluster_start - 1) >= hvn_cutoff
                                has_right_hvn = cluster_end < last_nz and array.get(density, cluster_end + 1) >= hvn_cutoff
                                keep := has_left_hvn and has_right_hvn
                            if keep
                                zone_lo = lo + cluster_start * bin_size
                                zone_hi = lo + (cluster_end + 1) * bin_size
                                zb = box.new(left_x, zone_hi, right_x, zone_lo,
                                             bgcolor=c_lvn,
                                             border_color=c_lvn_bd,
                                             border_width=1,
                                             border_style=line.style_dashed)
                                array.push(bx_lvn, zb)

                                // ---------------------------------------------
                                // Diagonal hatching. Draw N parallel segments
                                // running from bottom-left to top-right of the
                                // zone. Each segment spans one horizontal step,
                                // so all segments have identical dx/dy and are
                                // visually parallel — a "/////" pattern. Actual
                                // on-screen angle depends on chart zoom because
                                // the price and time axes have different units.
                                // ---------------------------------------------
                                width_bars = right_x - left_x
                                if width_bars > 0
                                    step_x = math.max(1, int(math.round(width_bars / lvn_stripes)))
                                    hx = left_x
                                    while hx < right_x
                                        hx_end = math.min(right_x, hx + step_x)
                                        hln = line.new(hx, zone_lo, hx_end, zone_hi,
                                                       color=c_lvn_hatch, width=1)
                                        array.push(ln_lvn, hln)
                                        hx += step_x

                                // ---------------------------------------------
                                // Zone label — placed at the geometric centre
                                // of the void so it reads as a badge on top of
                                // the hatched area rather than sitting off to
                                // the side. label.style_label_center anchors
                                // the tag by its middle, keeping it centred
                                // no matter how wide the zone is.
                                // ---------------------------------------------
                                if show_lvn_label
                                    zone_mid_y = (zone_lo + zone_hi) / 2
                                    zone_mid_x = int((left_x + right_x) / 2)
                                    hlb = label.new(zone_mid_x, zone_mid_y, lvn_label_text,
                                                    style=label.style_label_center,
                                                    color=c_lvn_label,
                                                    textcolor=LBL_TXT,
                                                    size=size.small,
                                                    textalign=text.align_center)
                                    array.push(lb_lvn, hlb)
                            cluster_start := -1

            // -----------------------------------------------------------------
            // High Volume Nodes (HVN clusters). Symmetric to the LVN scan
            // above, but with the opposite predicate: bins whose volume
            // reaches at least `hvn_threshold`% of POC are flagged as HVN,
            // consecutive HVN bins are grouped, and each group of length
            // >= `hvn_min_bins` becomes a zone. HVN zones highlight the
            // secondary peaks that would otherwise stay hidden inside the
            // heatmap gradient. POC itself falls naturally into an HVN
            // cluster and is emphasised twice: once by its solid line and
            // once by the HVN band around it — which is intentional, POC
            // is the strongest HVN and deserves the visual weight.
            // -----------------------------------------------------------------
            if show_hvn
                hvn_cutoff = max_dens * hvn_threshold / 100.0
                cluster_start = -1
                for b = 0 to n_bins - 1
                    is_hvn = array.get(density, b) >= hvn_cutoff
                    if is_hvn and cluster_start == -1
                        cluster_start := b
                    is_last = b == n_bins - 1
                    closes_cluster = (not is_hvn or is_last) and cluster_start != -1
                    if closes_cluster
                        cluster_end = is_hvn ? b : b - 1
                        cluster_len = cluster_end - cluster_start + 1
                        if cluster_len >= hvn_min_bins
                            zone_lo = lo + cluster_start * bin_size
                            zone_hi = lo + (cluster_end + 1) * bin_size
                            zb = box.new(left_x, zone_hi, right_x, zone_lo,
                                         bgcolor=c_hvn,
                                         border_color=c_hvn_bd,
                                         border_width=1,
                                         border_style=line.style_dashed)
                            array.push(bx_hvn, zb)
                            if show_hvn_label
                                zone_mid_y = (zone_lo + zone_hi) / 2
                                zone_mid_x = int((left_x + right_x) / 2)
                                hlb = label.new(zone_mid_x, zone_mid_y, hvn_label_text,
                                                style=label.style_label_center,
                                                color=c_hvn_label,
                                                textcolor=LBL_TXT_DARK,
                                                size=size.small,
                                                textalign=text.align_center)
                                array.push(lb_hvn, hlb)
                        cluster_start := -1

            // -----------------------------------------------------------------
            // Right-side density histogram in the future-offset zone: bar
            // length is the density ratio × HISTO_WIDTH, starting at
            // right_x + histo_offset so the current-price candle stays clear.
            // Level labels are placed past the histogram to keep the heatmap
            // area unobstructed.
            // -----------------------------------------------------------------
            histo_start = right_x + histo_offset
            label_x     = histo_start + HISTO_WIDTH + 1
            for b = 0 to n_bins - 1
                dens = array.get(density, b)
                if dens > 0
                    ratio   = dens / max_dens
                    bar_len = int(math.round(ratio * HISTO_WIDTH))
                    if bar_len > 0
                        b_lo  = lo + b * bin_size
                        b_hi  = b_lo + bin_size
                        h_col = color.new(f_grad_color(ratio), int(60 - math.round(ratio * 45)))
                        hb    = box.new(histo_start, b_hi, histo_start + bar_len, b_lo,
                                        bgcolor=h_col,
                                        border_color=color.new(f_grad_color(ratio), 20),
                                        border_width=1)
                        array.push(bx_hist, hb)

            // -----------------------------------------------------------------
            // POC line + label. Solid, drawn to the last real bar; label
            // sits past the histogram for readability.
            // -----------------------------------------------------------------
            if show_poc
                ln_poc := line.new(left_x, poc_price, right_x, poc_price,
                                   color=color.new(c_poc, 0), width=1)
                lb_poc := label.new(label_x, poc_price, "POC",
                                    style=label.style_label_left,
                                    color=color.new(c_poc, 15),
                                    textcolor=LBL_TXT_DARK,
                                    size=size.normal,
                                    textalign=text.align_center)

            // -----------------------------------------------------------------
            // VAH / VAL: dashed lines extended all the way to their labels
            // past the histogram so the eye follows the level continuously.
            // -----------------------------------------------------------------
            if show_va
                ln_vah := line.new(left_x, vah_price, label_x, vah_price,
                                   color=color.new(c_va, 55), width=1,
                                   style=line.style_dashed)
                ln_val := line.new(left_x, val_price, label_x, val_price,
                                   color=color.new(c_va, 55), width=1,
                                   style=line.style_dashed)
                lb_vah := label.new(label_x, vah_price, "VAH",
                                    style=label.style_label_left,
                                    color=color.new(c_va, 55),
                                    textcolor=LBL_TXT,
                                    size=size.small,
                                    textalign=text.align_center)
                lb_val := label.new(label_x, val_price, "VAL",
                                    style=label.style_label_left,
                                    color=color.new(c_va, 55),
                                    textcolor=LBL_TXT,
                                    size=size.small,
                                    textalign=text.align_center)

            // -----------------------------------------------------------------
            // Info panel — 3 rows × 3 cols: label | price | signed delta to
            // current close in percent. Delta color: green when the level
            // sits above price, red when below, gray at parity.
            // -----------------------------------------------------------------
            poc_pct  = (poc_price - close) / close * 100
            vah_pct  = (vah_price - close) / close * 100
            val_pct  = (val_price - close) / close * 100
            c_poc_pt = poc_pct > 0 ? LBL_ACC_UP : poc_pct < 0 ? LBL_ACC_DOWN : LBL_ACC_NEUT
            c_vah_pt = vah_pct > 0 ? LBL_ACC_UP : vah_pct < 0 ? LBL_ACC_DOWN : LBL_ACC_NEUT
            c_val_pt = val_pct > 0 ? LBL_ACC_UP : val_pct < 0 ? LBL_ACC_DOWN : LBL_ACC_NEUT

            table.cell(tbl_info, 0, 0, "POC",
                       text_color=color.new(c_poc, 0), text_size=size.small,
                       text_halign=text.align_left)
            table.cell(tbl_info, 1, 0, str.tostring(poc_price, format.mintick),
                       text_color=LBL_TXT, text_size=size.small,
                       text_halign=text.align_right)
            table.cell(tbl_info, 2, 0, f_pct_str(poc_pct),
                       text_color=c_poc_pt, text_size=size.small,
                       text_halign=text.align_right)

            table.cell(tbl_info, 0, 1, "VAH",
                       text_color=color.new(c_va, 20), text_size=size.small,
                       text_halign=text.align_left)
            table.cell(tbl_info, 1, 1, str.tostring(vah_price, format.mintick),
                       text_color=LBL_TXT, text_size=size.small,
                       text_halign=text.align_right)
            table.cell(tbl_info, 2, 1, f_pct_str(vah_pct),
                       text_color=c_vah_pt, text_size=size.small,
                       text_halign=text.align_right)

            table.cell(tbl_info, 0, 2, "VAL",
                       text_color=color.new(c_va, 20), text_size=size.small,
                       text_halign=text.align_left)
            table.cell(tbl_info, 1, 2, str.tostring(val_price, format.mintick),
                       text_color=LBL_TXT, text_size=size.small,
                       text_halign=text.align_right)
            table.cell(tbl_info, 2, 2, f_pct_str(val_pct),
                       text_color=c_val_pt, text_size=size.small,
                       text_halign=text.align_right)
````
