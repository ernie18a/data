# Flag Pattern Breakout [Dots3Red]

- url: https://www.tradingview.com/script/tMHhzI6j-Flag-Pattern-Breakout-Dots3Red/
- type: indicator
- pine_id: PUB;3acb50b19e244f7380b5bacaf62c8e61
- version: 1.0

## Description

█ FLAG PATTERN BREAKOUT [Dots3Red]
This script detects bull and bear flag patterns using two structural components: the staff (the impulsive pole) and the edge (the consolidation channel). Rather than relying on generic pivot-to-pivot zigzag lines, both components are built from regression-fitted geometry so the drawn shapes reflect the actual price structure rather than an approximation.

█ THE STAFF
The staff is the sharp, near-straight-line impulsive move that starts a flag. Two checks work together to identify it:

[b]Structural continuity[/b] — instead of checking candle color (green vs red), the script checks whether each bar's wick still overlaps the bar before it. For a rising staff, a bar whose high fails to reach the previous bar's low counts as a break in the move. This catches genuine gaps in the advance while tolerating a normal red pullback candle that still overlaps the prior bar.

[b]Straightness (R²)[/b] — a linear regression is fit through the closing prices of the candidate window, and its R² (coefficient of determination) is required to clear a minimum threshold (default 0.85). An R² of 1.0 would mean the closes sit exactly on a straight line; lower values reflect real curvature. Since real price data rarely produces a perfectly straight move, the threshold is adjustable rather than fixed at 1.0.

The search checks the longest possible window first and works down to shorter ones. A long window is only accepted if it clears both the wick-overlap test and the R² threshold — so the result favors the longest staff that still qualifies as straight, rather than the first short segment that happens to pass.

The staff line itself is drawn using the actual price at the two boundary bars (not the highest/lowest price found anywhere inside the scanning window), so it sits flush against the real candle wicks at both ends.


█ THE EDGE
The edge is the flag itself — a channel that runs opposite to the staff's direction. It is built as follows:

[b]Slope[/b] — a running linear regression is fit through the highs (for a bull flag's falling edge) or the lows (for a bear flag's rising edge) of every bar since the staff ended. This produces one slope value that updates each bar as more data arrives.

[b]Direction and steepness constraints[/b] — the edge's slope must run opposite to the staff (negative for a bull flag, positive for a bear flag) and must be shallower than the staff's own slope by a configurable ratio (default 60%). A flag that slopes as steeply as its pole is not behaving like a consolidation.

[b]Width cap[/b] — the vertical distance between the tracked high and low extremes of the edge cannot exceed a percentage of the staff's height (default 60%). This is measured in absolute price distance, not bar count, so a slow-forming edge and a fast-forming edge are held to the same physical size constraint.

[b]Breakout confirmation[/b] — the pattern is not finalized as soon as it meets minimum criteria. It keeps extending, bar by bar, for as long as price stays inside the channel. Confirmation only happens when price closes beyond the channel boundary by a configurable ATR buffer, in the direction that continues the original staff move (upward for a bull flag, downward for a bear flag). This means the edge is drawn at its full, longest actual duration rather than being cut short at an arbitrary minimum.

[b]Envelope construction[/b] — once a pattern confirms, the two boundary lines are built by taking the regression-fitted line and shifting it by the maximum deviation observed on each side across every bar in the edge. The upper boundary is shifted up by the largest high-to-line distance seen; the lower boundary is shifted down by the largest line-to-low distance seen. Both lines share the identical slope, so they are parallel by construction, and together they contain the full price range of the consolidation rather than only touching two points.


█ VISUALS
The staff is drawn with a glow layer behind a sharp core line, color-coded green for bull and red for bear. The edge channel is filled with a soft translucent tint between its two boundary lines. A label at the breakout point shows the staff's height in ATR units, the edge's duration in bars, and the channel's width in ATR units.


█ SETTINGS
[b]Staff[/b]
• Min Staff Height (×ATR) — minimum impulsive move size relative to ATR
• Min/Max Staff Duration (bars) — bounds on how many bars the staff can span
• Max Opposite-Direction Bars — structural wick-overlap tolerance
• Min Straightness (R²) — how closely the staff must fit a straight line

[b]Edge[/b]
• Min Bars Before Breakout Eligible — minimum edge duration before a breakout can confirm
• Max Edge Duration (bars) — safety cap; abandons the pattern if no breakout occurs in time
• Max Channel Width (% of Staff Height) — absolute-distance cap on the edge's vertical size
• Max Edge Slope (× staff slope) — how much shallower the edge must be than the staff
• Min Edge Slope (×ATR per bar) — minimum slope magnitude so the edge counts as genuinely sloped
• Breakout Buffer (×ATR) — margin required beyond the boundary to confirm a breakout

█EXAMPLE ([b]DAILY APPLE STOCK[/b][i][/i])
[image]https://www.tradingview.com/x/AolOuGH1/[/image]


█ NOTES
Because confirmation only happens at breakout, the pattern appears on the chart once the move has already resumed — this script identifies completed flag-and-breakout structures for review and study, not an early-warning signal before the breakout occurs. Works on any timeframe; behavior depends on how the ATR-based thresholds interact with the instrument's typical volatility.
[b]However[/b](!), with the [b]ATR Breakout[/b] setting, it is possible to set a lower value, and by doing so we might [b]"anticipate"[/b] Flag Development and consequent Breakout.

█ DISCLAIMER
This is a pattern visualization tool. It does not generate trade signals and does not constitute financial advice. Historical pattern detection does not guarantee that similar structures will behave the same way in the future.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Flag Pattern Breakout [Dots3Red]",
          shorttitle    = "Flag Dev [D3R]",
          overlay       = true,
          max_bars_back = 1000,
          max_boxes_count  = 500,
          max_lines_count  = 500,
          max_labels_count = 500)


// COLORS
C_BULL = color.new(#00f0ff, 0)
C_BEAR = color.new(#ff00aa, 0)
C_DIM  = color.new(#94a3b8, 0)
C_BAR = #b2b5be
C_EDGE = color.new(#ffb700, 0)

//COLORS
color C_GREEN_CORE = #00ff66                  // Electric Emerald
color C_GREEN_GLOW = color.new(#00ff66, 70)   // Outer Neon Bloom
color C_GREEN_FILL = color.new(#00ff66, 90)   // Translucent Fill

color C_RED_CORE   = #ff0055                  // Crimson Coral
color C_RED_GLOW   = color.new(#ff0055, 70)   // Outer Neon Bloom
color C_RED_FILL   = color.new(#ff0055, 90)   // Translucent Fill



// INPUTS
GRP_STAFF = "📏 Staff"
GRP_EDGE  = "🚩 Edge"
GRP_VIS   = "🎨 Visualization"

staff_min_atr      = input.float(2.0, "Min Staff Height (×ATR)",  minval=0.5, step=0.5, group=GRP_STAFF)
staff_min_bars     = input.int  (2,   "Min Staff Duration (bars)", minval=1, group=GRP_STAFF)
staff_max_bars     = input.int  (12,  "Max Staff Duration (bars)", minval=3, group=GRP_STAFF)
staff_max_opposite = input.int  (1,   "Max Opposite-Direction Bars", minval=0, maxval=5, group=GRP_STAFF,
                     tooltip="Secondary structural guard against wick-overlap breaks.")
staff_min_r2       = input.float(0.85,"Min Straightness (R²)", minval=0.5, maxval=0.999, step=0.01, group=GRP_STAFF,
                     tooltip="How closely the bars must fit a straight line, 0-1. Since the search checks the longest window first, raising this favors shorter but straighter staffs.")

edge_min_bars       = input.int  (3,   "Min Bars Before Breakout Eligible", minval=2, maxval=15, group=GRP_EDGE,
                     tooltip="Minimum bars the edge must run before a breakout can confirm the pattern.")
edge_max_bars        = input.int  (30,  "Max Edge Duration (bars)", minval=5, group=GRP_EDGE,
                     tooltip="Safety cap. If no breakout occurs within this many bars, the pattern is abandoned.")
edge_max_width_pct   = input.float(60.0,"Max Channel Width (% of Staff Height)", minval=10.0, maxval=90.0, step=5.0, group=GRP_EDGE,
                     tooltip="The vertical gap between the two parallel boundary lines cannot exceed this percentage of the staff's height.")
max_edge_slope_ratio = input.float(0.6, "Max Edge Slope (× staff slope)", minval=0.05, maxval=1.0, step=0.05, group=GRP_EDGE,
                     tooltip="The flag must be visibly shallower than the pole.")
min_slope_atr        = input.float(0.02,"Min Edge Slope (×ATR per bar)", minval=0.0, maxval=0.5, step=0.01, group=GRP_EDGE,
                     tooltip="Minimum slope magnitude per bar so the edge counts as genuinely sloped, not flat.")
breakout_atr_mult    = input.float(0.15,"Breakout Buffer (×ATR)", minval=0.0, maxval=1.0, step=0.05, group=GRP_EDGE,
                     tooltip="Close must clear the channel boundary by this ATR margin to confirm a breakout.")

max_patterns       = input.int  (20,  "Max Patterns Tracked", minval=5, maxval=100, group=GRP_VIS)
zone_ext           = input.int  (3,  "Label Offset (bars)",  minval=1, maxval=15,  group=GRP_VIS)


atr_raw = ta.atr(14)


// TYPES
type Staff
    int   start_bar
    int   end_bar
    float high
    float low
    float height
    bool  rising

type Edge
    int   start_bar
    int   end_bar
    int   n
    float sumX
    float sumY
    float sumXY
    float sumX2
    float slope
    float hi_price
    int   hi_bar
    float lo_price
    int   lo_bar

type FlagPattern
    Staff staff
    Edge  edge
    bool  is_bull
    line  staff_ln
    line  edge_upper_ln
    line  edge_lower_ln
    label lbl


// STRAIGHTNESS — R² of a linear regression fit through closes
f_window_r2(int lookback) =>
    float sumX  = 0.0
    float sumY  = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    float sumY2 = 0.0
    for i = 0 to lookback
        float xi = float(i)
        float yi = close[lookback - i]
        sumX  += xi
        sumY  += yi
        sumXY += xi * yi
        sumX2 += xi * xi
        sumY2 += yi * yi
    float nf  = float(lookback + 1)
    float sxy = sumXY - sumX * sumY / nf
    float sxx = sumX2 - sumX * sumX / nf
    float syy = sumY2 - sumY * sumY / nf
    float r2  = (sxx > 0.0 and syy > 0.0) ? (sxy * sxy) / (sxx * syy) : 0.0
    r2


// STAFF DETECTION — longest qualifying straight-line window first
f_find_staff_rising() =>
    bool  found  = false
    int   s      = na
    int   e      = na
    float lo_p   = na
    float hi_p   = na

    for lookback = staff_max_bars to staff_min_bars
        if bar_index - lookback < 0
            continue
        float start_low = low[lookback]
        float end_high  = high
        height = end_high - start_low
        if height >= atr_raw * staff_min_atr
            int opposite = 0
            for k = 0 to lookback - 1
                if high[k] <= low[k + 1]
                    opposite += 1
            if opposite <= staff_max_opposite
                float r2 = f_window_r2(lookback)
                if r2 >= staff_min_r2
                    found := true
                    s     := bar_index - lookback
                    e     := bar_index
                    lo_p  := start_low
                    hi_p  := end_high
                    break

    [found, s, e, lo_p, hi_p]

f_find_staff_falling() =>
    bool  found  = false
    int   s      = na
    int   e      = na
    float lo_p   = na
    float hi_p   = na

    for lookback = staff_max_bars to staff_min_bars
        if bar_index - lookback < 0
            continue
        float start_high = high[lookback]
        float end_low    = low
        height = start_high - end_low
        if height >= atr_raw * staff_min_atr
            int opposite = 0
            for k = 0 to lookback - 1
                if low[k] >= high[k + 1]
                    opposite += 1
            if opposite <= staff_max_opposite
                float r2 = f_window_r2(lookback)
                if r2 >= staff_min_r2
                    found := true
                    s     := bar_index - lookback
                    e     := bar_index
                    lo_p  := end_low
                    hi_p  := start_high
                    break

    [found, s, e, lo_p, hi_p]


// STATE
var bool  tr_bull = false
var Staff st_bull = na
var Edge  eg_bull = na

var bool  tr_bear = false
var Staff st_bear = na
var Edge  eg_bear = na

var FlagPattern[] patterns = array.new<FlagPattern>()

f_new_edge(int s) =>
    Edge.new(s, na, 0, 0.0, 0.0, 0.0, 0.0, na, na, na, na, na)


f_update_slope(Edge eg, int bar_idx, float y_val) =>
    float x = float(bar_idx - eg.start_bar)
    eg.n     += 1
    eg.sumX  += x
    eg.sumY  += y_val
    eg.sumXY += x * y_val
    eg.sumX2 += x * x
    if eg.n >= 2
        float denom = eg.n * eg.sumX2 - eg.sumX * eg.sumX
        if denom != 0.0
            eg.slope := (eg.n * eg.sumXY - eg.sumX * eg.sumY) / denom
    eg

f_update_extremes(Edge eg, int bar_idx, float hi_val, float lo_val) =>
    if na(eg.hi_price) or hi_val > eg.hi_price
        eg.hi_price := hi_val
        eg.hi_bar   := bar_idx
    if na(eg.lo_price) or lo_val < eg.lo_price
        eg.lo_price := lo_val
        eg.lo_bar   := bar_idx
    eg


// MAIN LOOP
if barstate.isconfirmed

    // ── BULL SIDE: rising staff → falling parallelogram edge ──────────
    if not tr_bull
        [found, s, e, lo_p, hi_p] = f_find_staff_rising()
        if found
            tr_bull := true
            st_bull := Staff.new(s, e, hi_p, lo_p, hi_p - lo_p, true)
            eg_bull := f_new_edge(e)
            eg_bull := f_update_slope(eg_bull, e, hi_p)
            eg_bull := f_update_extremes(eg_bull, e, hi_p, hi_p)
    else
        eg_bull := f_update_slope(eg_bull, bar_index, high)
        eg_bull := f_update_extremes(eg_bull, bar_index, high, low)

        // Both boundary lines share this slope. Upper passes through the
        // tracked highest high, lower passes through the tracked lowest low.
        float upper_now = eg_bull.hi_price + eg_bull.slope * float(bar_index - eg_bull.hi_bar)
        float lower_now = eg_bull.lo_price + eg_bull.slope * float(bar_index - eg_bull.lo_bar)
        float gap_now    = upper_now - lower_now

        float staff_bars_bull  = float(st_bull.end_bar - st_bull.start_bar)
        float staff_slope_bull = staff_bars_bull > 0 ? st_bull.height / staff_bars_bull : 0.0

        float edgeL = math.abs(eg_bull.hi_price - eg_bull.lo_price)
        float staffL = math.abs(st_bull.high - st_bull.low)
        float too_wide_val = eg_bull.hi_price - eg_bull.lo_price


        bool  too_wide     =  too_wide_val > (edge_max_width_pct / 100.0) * st_bull.height //gap_now > (edge_max_width_pct / 100.0) * st_bull.height
        bool  too_old      = (bar_index - eg_bull.start_bar) > edge_max_bars
        bool  eligible     = eg_bull.n >= edge_min_bars
        bool  slope_negative = eg_bull.slope < -(min_slope_atr * atr_raw)
        bool  slope_shallow  = math.abs(eg_bull.slope) <= max_edge_slope_ratio * staff_slope_bull
        bool  valid_slope     = slope_negative and slope_shallow

        bool  breakout = eligible and valid_slope and close > upper_now + breakout_atr_mult * atr_raw

        if breakout
            eg_bull.end_bar := bar_index
            FlagPattern fp = FlagPattern.new(st_bull, eg_bull, true, na, na, na, na)
            array.push(patterns, fp)
            tr_bull := false
        else if too_wide or too_old or (eligible and not valid_slope)
            tr_bull := false
        // else: still developing — keep extending

    // ── BEAR SIDE: falling staff → rising parallelogram edge ──────────
    if not tr_bear
        [found, s, e, lo_p, hi_p] = f_find_staff_falling()
        if found
            tr_bear := true
            st_bear := Staff.new(s, e, hi_p, lo_p, hi_p - lo_p, false)
            eg_bear := f_new_edge(e)
            eg_bear := f_update_slope(eg_bear, e, lo_p)
            eg_bear := f_update_extremes(eg_bear, e, lo_p, lo_p)
    else
        eg_bear := f_update_slope(eg_bear, bar_index, low)
        eg_bear := f_update_extremes(eg_bear, bar_index, high, low)

        float upper_now_b = eg_bear.hi_price + eg_bear.slope * float(bar_index - eg_bear.hi_bar)
        float lower_now_b = eg_bear.lo_price + eg_bear.slope * float(bar_index - eg_bear.lo_bar)
        float gap_now_b     = upper_now_b - lower_now_b

        float staff_bars_bear  = float(st_bear.end_bar - st_bear.start_bar)
        float staff_slope_bear = staff_bars_bear > 0 ? st_bear.height / staff_bars_bear : 0.0

        bool  too_wide_b   = gap_now_b > (edge_max_width_pct / 100.0) * st_bear.height
        bool  too_old_b    = (bar_index - eg_bear.start_bar) > edge_max_bars
        bool  eligible_b   = eg_bear.n >= edge_min_bars
        bool  slope_positive = eg_bear.slope > (min_slope_atr * atr_raw)
        bool  slope_shallow_b = math.abs(eg_bear.slope) <= max_edge_slope_ratio * staff_slope_bear
        bool  valid_slope_b    = slope_positive and slope_shallow_b

        bool  breakout_b = eligible_b and valid_slope_b and close < lower_now_b - breakout_atr_mult * atr_raw

        if breakout_b
            eg_bear.end_bar := bar_index
            FlagPattern fp = FlagPattern.new(st_bear, eg_bear, false, na, na, na, na)
            array.push(patterns, fp)
            tr_bear := false
        else if too_wide_b or too_old_b or (eligible_b and not valid_slope_b)
            tr_bear := false

    while array.size(patterns) > max_patterns
        old = array.shift(patterns)
        if not na(old.staff_ln)
            line.delete(old.staff_ln)
        if not na(old.edge_upper_ln)
            line.delete(old.edge_upper_ln)
        if not na(old.edge_lower_ln)
            line.delete(old.edge_lower_ln)
        if not na(old.lbl)
            label.delete(old.lbl)

f_get_envelope_bounds(FlagPattern fp)=>
// Regression line anchor (using hi_bar/hi_price or base slope)
    float slp = fp.edge.slope
    int s_bar = fp.edge.start_bar
    int e_bar = fp.edge.end_bar

    float max_up_diff = -1e10
    float max_lo_diff = -1e10

    for b = e_bar to s_bar
        int offset = bar_index - b
        if offset >= 0
            float base_y = fp.edge.hi_price + slp * float(b - fp.edge.hi_bar)
            
            float up_diff = high[offset] - base_y
            float lo_diff = base_y - low[offset]

            if up_diff > max_up_diff
                max_up_diff := up_diff
            if lo_diff > max_lo_diff
                max_lo_diff := lo_diff

    float up_start = (fp.edge.hi_price + slp * float(s_bar - fp.edge.hi_bar)) + max_up_diff
    float up_end   = (fp.edge.hi_price + slp * float(e_bar - fp.edge.hi_bar)) + max_up_diff
    
    float lo_start = (fp.edge.hi_price + slp * float(s_bar - fp.edge.hi_bar)) - max_lo_diff
    float lo_end   = (fp.edge.hi_price + slp * float(e_bar - fp.edge.hi_bar)) - max_lo_diff

    [up_start, up_end, lo_start, lo_end]


// VISUALIZATION 
if array.size(patterns) > 0
    for i = 0 to array.size(patterns) - 1
        fp = array.get(patterns, i)
        if na(fp.staff_ln)
            color core_c = fp.is_bull ? C_GREEN_CORE : C_RED_CORE
            color glow_c = fp.is_bull ? C_GREEN_GLOW : C_RED_GLOW
            color fill_c = fp.is_bull ? C_GREEN_FILL : C_RED_FILL

            line.new(fp.staff.start_bar, fp.is_bull ? fp.staff.low : fp.staff.high, 
                     fp.staff.end_bar,   fp.is_bull ? fp.staff.high : fp.staff.low, 
                     color=color.new(fill_c,70), width=7)

            fp.staff_ln := line.new(fp.staff.start_bar, fp.is_bull ? fp.staff.low : fp.staff.high, 
                                    fp.staff.end_bar,   fp.is_bull ? fp.staff.high : fp.staff.low, 
                                    color=color.new(core_c,35), width=3)


            [up_start, up_end, lo_start, lo_end] = f_get_envelope_bounds(fp)

            fp.edge_upper_ln := line.new(
            fp.edge.start_bar, up_start,
            fp.edge.end_bar,   up_end,
            color=core_c, width=1, style=line.style_solid)

            fp.edge_lower_ln := line.new(
            fp.edge.start_bar, lo_start,
            fp.edge.end_bar,   lo_end,
            color=core_c, width=1, style=line.style_solid)

            linefill.new(fp.edge_upper_ln, fp.edge_lower_ln, color=color.new(fill_c,65))

            float gap_final = up_end - lo_end
            string tag  = fp.is_bull ? "⚡ BULL_FLAG::BREAKOUT" : "⚡ BEAR_FLAG::BREAKOUT"
            string body = tag + "\n┌─ STAFF : " + str.tostring(math.round(fp.staff.height / atr_raw, 1)) + " ATR"
            body := body + "\n├─ EDGE  : " + str.tostring(fp.edge.n) + " BARS"
            body := body + "\n└─ GAP   : " + str.tostring(math.round(gap_final / atr_raw, 2)) + " ATR"




            fp.lbl := label.new(
                 fp.staff.start_bar - zone_ext,
                 fp.is_bull ? fp.staff.high + atr_raw*2 : fp.staff.low - atr_raw*2,
                 body, style=label.style_label_left,
                 textcolor=core_c, color=color.new(#090d16, 100),
                 size=size.small, textalign=text.align_left)

            array.set(patterns, i, fp)

barcolor(C_BAR)
````
