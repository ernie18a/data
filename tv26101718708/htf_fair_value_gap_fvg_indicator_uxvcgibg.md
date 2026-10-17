# HTF Fair Value Gap (FVG) Indicator

- url: https://www.tradingview.com/script/uxVcgIBG-HTF-Fair-Value-Gap-FVG-Indicator/
- type: indicator
- pine_id: PUB;9c6b65ccec554fe597138d0d450cdd04
- version: 1.0

## Description

Automatically detects and plots Fair Value Gaps from the 1H, 4H, and Daily timeframes directly on any chart. A Fair Value Gap is a 3-candle imbalance where the wick of candle A and the wick of candle C do not overlap, leaving an unfilled gap in price. Bullish FVGs form when the high of candle A is below the low of candle C. Bearish FVGs form when the low of candle A is above the high of candle C.
Each FVG is drawn as a colored box spanning the gap zone with a dotted midline. When price trades back through a zone it becomes an Inverse Fair Value Gap (IFVG), changing color to indicate the shift in character. IFVGs can be toggled off to simply remove mitigated zones. All colors and borders are fully customizable. You can control how many FVGs per timeframe are displayed at once, keeping the chart clean regardless of what timeframe you are trading on.

## Source Code

````pine
//@version=6
indicator("HTF FVG", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show_1h  = input.bool(true, "Show 1H FVGs")
show_4h  = input.bool(true, "Show 4H FVGs")
show_1d  = input.bool(true, "Show Daily FVGs")

bull_col    = input.color(color.new(color.green,  75), "Bullish FVG Color")
bear_col    = input.color(color.new(color.red,    75), "Bearish FVG Color")
bull_border = input.color(color.new(color.green,  20), "Bullish FVG Border")
bear_border = input.color(color.new(color.red,    20), "Bearish FVG Border")

show_ifvg        = input.bool(true, "Show IFVGs")
ifvg_bull_col    = input.color(color.new(color.orange, 75), "Bullish IFVG Color")
ifvg_bear_col    = input.color(color.new(color.purple, 75), "Bearish IFVG Color")
ifvg_bull_border = input.color(color.new(color.orange, 20), "Bullish IFVG Border")
ifvg_bear_border = input.color(color.new(color.purple, 20), "Bearish IFVG Border")

max_fvgs = input.int(5, "Max FVGs per Timeframe", minval=1, maxval=10)

// ─── ARRAYS ───────────────────────────────────────────────────────────────────
var float[]  fvg_top       = array.new_float()
var float[]  fvg_bot       = array.new_float()
var int[]    fvg_time      = array.new_int()
var bool[]   fvg_bull      = array.new_bool()
var string[] fvg_tf        = array.new_string()
var bool[]   fvg_mitigated = array.new_bool()

var box[]   drawn_boxes  = array.new<box>()
var line[]  drawn_lines  = array.new<line>()
var label[] drawn_labels = array.new<label>()

// ─── COLLECT ──────────────────────────────────────────────────────────────────
// Uses high[1]/[2]/[3] INSIDE request.security — these are HTF bar offsets,
// not current chart bar offsets. lookahead_on delivers them at HTF bar open.
collect_fvgs(tf, show) =>
    if show
        // Each request pulls a specific closed HTF candle
        // [1] = just closed (C), [2] = middle (B), [3] = oldest (A)
        hi_a  = request.security(syminfo.tickerid, tf, high[3], lookahead=barmerge.lookahead_on)
        lo_a  = request.security(syminfo.tickerid, tf, low[3],  lookahead=barmerge.lookahead_on)
        hi_c  = request.security(syminfo.tickerid, tf, high[1], lookahead=barmerge.lookahead_on)
        lo_c  = request.security(syminfo.tickerid, tf, low[1],  lookahead=barmerge.lookahead_on)
        t_a   = request.security(syminfo.tickerid, tf, time[3], lookahead=barmerge.lookahead_on)
        t_c   = request.security(syminfo.tickerid, tf, time[1], lookahead=barmerge.lookahead_on)
        t_now = request.security(syminfo.tickerid, tf, time,    lookahead=barmerge.lookahead_on)

        is_new_bar = ta.change(t_now) != 0

        if is_new_bar
            // Gap filter: A→C should span exactly 2 HTF periods
            // If much larger, it crossed a weekend/holiday — skip it
            tf_ms         = timeframe.in_seconds(tf) * 1000
            expected_span = tf_ms * 2
            actual_span   = t_c - t_a
            no_gap        = actual_span <= expected_span * 1.1

            if no_gap
                // Bearish FVG: low of A > high of C
                if lo_a > hi_c
                    array.push(fvg_top,       lo_a)
                    array.push(fvg_bot,       hi_c)
                    array.push(fvg_time, t_a)
                    array.push(fvg_bull,      false)
                    array.push(fvg_tf,        tf)
                    array.push(fvg_mitigated, false)

                // Bullish FVG: high of A < low of C
                if hi_a < lo_c
                    array.push(fvg_top,       lo_c)
                    array.push(fvg_bot,       hi_a)
                    array.push(fvg_time, t_a)
                    array.push(fvg_bull,      true)
                    array.push(fvg_tf,        tf)
                    array.push(fvg_mitigated, false)

collect_fvgs("60",  show_1h)
collect_fvgs("240", show_4h)
collect_fvgs("1D",  show_1d)

// ─── MITIGATION CHECK ─────────────────────────────────────────────────────────
n_check = array.size(fvg_top)
if n_check > 0
    for j = 0 to n_check - 1
        if not array.get(fvg_mitigated, j)
            top     = array.get(fvg_top,  j)
            bot     = array.get(fvg_bot,  j)
            is_bull = array.get(fvg_bull, j)
            if is_bull and low < bot
                array.set(fvg_mitigated, j, true)
            if not is_bull and high > top
                array.set(fvg_mitigated, j, true)

// ─── DRAW ON LAST BAR ─────────────────────────────────────────────────────────
if barstate.islast
    for b in drawn_boxes
        box.delete(b)
    for l in drawn_lines
        line.delete(l)
    for lb in drawn_labels
        label.delete(lb)
    array.clear(drawn_boxes)
    array.clear(drawn_lines)
    array.clear(drawn_labels)

    n           = array.size(fvg_top)
    future_time = timenow + (timeframe.in_seconds() * 1000 * 500)

    if n > 0
        count_1h = 0
        count_4h = 0
        count_1d = 0

        for j = n - 1 to 0
            tf_str    = array.get(fvg_tf,        j)
            mitigated = array.get(fvg_mitigated,  j)

            if mitigated and not show_ifvg
                continue

            can_draw = false
            if tf_str == "60" and count_1h < max_fvgs
                count_1h += 1
                can_draw := true
            else if tf_str == "240" and count_4h < max_fvgs
                count_4h += 1
                can_draw := true
            else if tf_str == "1D" and count_1d < max_fvgs
                count_1d += 1
                can_draw := true

            if can_draw
                top     = array.get(fvg_top,  j)
                bot     = array.get(fvg_bot,  j)
                mid     = math.avg(top, bot)
                fvg_t   = array.get(fvg_time, j)
                is_bull = array.get(fvg_bull, j)

                bd       = mitigated ? (is_bull ? ifvg_bull_border : ifvg_bear_border) : (is_bull ? bull_border : bear_border)
                bc       = mitigated ? (is_bull ? ifvg_bull_col    : ifvg_bear_col)    : (is_bull ? bull_col    : bear_col)
                lp       = is_bull ? label.style_label_upper_left : label.style_label_lower_left
                ly       = is_bull ? bot : top
                tf_label = tf_str == "60" ? "1H" : tf_str == "240" ? "4H" : "Daily"
                ltxt     = mitigated ? "IFVG " + tf_label : tf_label

                b  = box.new(fvg_t, top, future_time, bot,
                             border_color=bd, border_width=1, bgcolor=bc,
                             xloc=xloc.bar_time)
                l  = line.new(fvg_t, mid, future_time, mid,
                              color=bd, style=line.style_dotted, width=1,
                              xloc=xloc.bar_time)
                lb = label.new(fvg_t, ly, ltxt,
                               color=color.new(color.black, 100), textcolor=bd,
                               size=size.small, style=lp,
                               xloc=xloc.bar_time)

                array.push(drawn_boxes,  b)
                array.push(drawn_lines,  l)
                array.push(drawn_labels, lb)
````
