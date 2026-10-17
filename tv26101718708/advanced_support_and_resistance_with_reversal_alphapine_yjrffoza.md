# Advanced Support and Resistance with Reversal [AlphaPine]

- url: https://www.tradingview.com/script/YJRFfoza-Advanced-Support-and-Resistance-with-Reversal-AlphaPine/
- type: indicator
- pine_id: PUB;6ad3807b81fa4aacb424b6c9cbb3279c
- version: 1.0

## Description

[b]Advanced Support and Resistance with Reversal | AlphaPine[/b]

I built this indicator for a simple reason: a breakout line on its own does not tell me enough. I also want to know whether price comes back, holds the level from the other side, and later loses it again.

The script starts with confirmed swing highs and lows. Those become resistance and support. It then follows each level through three possible events: breakout, retest, and failure. Nothing here predicts the next move. It is a way to keep market structure organised without redrawing the same levels by hand.

The image below shows the full level lifecycle in one view, including the symbols that appear at each stage:

https://www.tradingview.com/x/VqSKyCmF/

[b]How a level is created[/b]

A resistance level comes from a confirmed pivot high. A support level comes from a confirmed pivot low. If zones are enabled, the zone uses the wick range of the pivot candle rather than an arbitrary fixed width.

Pivot confirmation takes time. With Pivot Length set to 10, for example, the script needs ten bars on the right side of the pivot before the level exists. This delay is intentional.

[list]
[*][b]Pivot Length[/b] controls how selective the swing detection is. A larger value usually gives fewer levels and confirms them later.
[*][b]Lookback Period[/b] sets how long a level remains in the script's working history.
[*][b]Maximum Levels per Type[/b] limits stored resistance and support records so the chart does not keep growing indefinitely.
[*][b]Wick Dominance Filter[/b] keeps only pivot candles whose rejection wick is larger than the body and opposite wick.
[*][b]Merge Nearby Active Levels[/b] removes clutter by skipping a new pivot when an active level of the same type is already nearby. Broken levels do not block a fresh one.
[/list]

The merge distance uses ATR-14, so it adjusts to the instrument instead of relying on one fixed price interval.

[b]Breakouts[/b]

The default breakout mode is [b]Close[/b]. Resistance must close above its boundary, while support must close below it. This avoids counting every small wick through a level.

[b]Wick[/b] mode reacts earlier. It triggers when the high or low crosses the boundary during the live candle. The recorded extreme cannot retract, but price can still close back inside the level, so Wick mode will naturally include more intrabar fakeouts.

[b]Breakout Buffer[/b] adds an optional ATR-based distance beyond the level. Leave it at zero for the exact boundary, or raise it if very small breaks are not useful for your chart.

By default:

[list]
[*]A resistance breakout prints an upward blue triangle below the candle.
[*]A support breakout prints a downward orange triangle above the candle.
[/list]

The marker colours are fully adjustable.

[b]Retests and role reversals[/b]

After resistance breaks, the script waits to see whether price can retest it as support. After support breaks, it watches for the same level to act as resistance.

[list]
[*][b]RS[/b] means old resistance has been confirmed as new support.
[*][b]SR[/b] means old support has been confirmed as new resistance.
[/list]

[b]Reversal Confirmation[/b] controls what counts as a retest:

[list]
[*][b]Close[/b] (default) requires the retest candle to touch the original zone and close back beyond the whole zone on the new-role side.
[*][b]Touch[/b] accepts any later overlap with the zone. It is more sensitive and less strict.
[/list]

Once confirmed, the new role stays fixed. An RS level remains tracked as support; it does not turn red merely because the latest candle happens to sit below it.

[b]When a flip fails[/b]

A flipped level is removed when a confirmed candle closes through the far side of its zone. In other words, RS support fails below the zone and SR resistance fails above it.

If [b]Show Reversal Failures[/b] is enabled, an ✕ marks the failure candle. The flipped line stops there, but the cross stays on the chart as a record of where the level died. That is why a failure cross can appear without a continuing line.

Breakout triangles and failure crosses use the original pivot as their Lookback anchor. This keeps their expiry on the same structural clock as the level they came from instead of giving every marker a new lifetime from its event candle.

[b]Reading the chart[/b]

[list]
[*][b]R1[/b] is the nearest active resistance above price, followed by R2, R3, and so on.
[*][b]S1[/b] is the nearest active support below price, followed by S2, S3, and so on.
[*][b]RS[/b] marks a confirmed resistance-to-support flip.
[*][b]SR[/b] marks a confirmed support-to-resistance flip.
[*]Triangles mark breakouts. Crosses mark failed flips.
[/list]

A breakout marker is an event, not an entry instruction. I find the retest more useful than the first break, but how it is traded still depends on trend, execution, and risk rules outside this indicator.

[b]Lines, zones, and historical placement[/b]

[b]Historical Level Start[/b] decides where an original level begins:

[list]
[*][b]Confirmation[/b] (default) starts it on the bar where the pivot became known in real time.
[*][b]Pivot[/b] extends it back to the swing candle. This is useful for visual context, but the level was not available on that earlier candle.
[/list]

[b]Display as Zones[/b] replaces the single-price lines with the original pivot-wick range. If that level flips, the same price range is preserved; the zone is not moved to the opposite side of the price.

[b]Colours[/b]

The [b]Colors[/b] group separates colours by purpose, so changing a label does not force the matching line to use the same colour.

[list]
[*]Resistance and support lines/zones.
[*]RS and SR lines/zones.
[*]Resistance, support, RS, and SR price labels.
[*]Resistance and support breakout triangles.
[*]Support and resistance failure crosses.
[/list]

Zone fills and borders use transparent versions of the selected line colour so candles remain visible underneath.

[b]Alerts[/b]

Seven alert conditions are included:

[list]
[*]Resistance Breakout
[*]Support Breakout
[*]Resistance to Support Flip
[*]Support to Resistance Flip
[*]Flipped Support Failed
[*]Flipped Resistance Failed
[*]Any S/R Event
[/list]

The combined alert is useful when one alert should cover every structural event. Separate conditions are available when different actions are needed for breaks, flips, or failures.

[b]A sensible starting setup[/b]

The defaults use Close confirmation for both breakouts and retests. Start there if you prefer signals that wait for the candle to finish. Wick breakout and Touch retest are available when earlier, more sensitive reactions are more important.

If the chart feels crowded, try increasing Pivot Length, increasing Merge Distance, enabling the Wick Dominance Filter, or reducing Maximum Levels per Type. Settings should be adjusted for the instrument and timeframe rather than treated as universal values.

[b]Important limitations[/b]

[list]
[*]Confirmed pivots always arrive late by Pivot Length bars. That is how pivot confirmation works, not a hidden predictive signal.
[*]Pivot historical placement back-draws a confirmed level for context. Use Confirmation placement when real-time availability matters.
[*]Wick mode can mark a breakout that later closes back inside the level.
[*]The current-bar drawings rebuild while the candle updates.
[*]The script uses chart data only. It does not request higher-timeframe data or use lookahead.
[*]It does not place orders, calculate position size, or guarantee that a level will hold.
[/list]

Use it as a structure tool, then apply your own trade plan and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaPine

// Advanced Support and Resistance with Reversal | AlphaPine
// Confirmed pivot S/R, breakout tracking, role-reversal retests, and flip invalidation.

//@version=6
indicator("Advanced Support and Resistance with Reversal | AlphaPine", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//--------------------------------------------------------------------------------------------------
// INPUTS
//--------------------------------------------------------------------------------------------------
g_detect  = "Level Detection"
g_signal  = "Breakout & Reversal"
g_display = "Display"
g_colors  = "Colors"

pivot_length        = input.int(10, "Pivot Length", minval = 2, maxval = 50, group = g_detect, tooltip = "Bars required on each side to confirm a pivot. The level is not known until Pivot Length bars after the pivot candle.")
lookback_period     = input.int(200, "Lookback Period", minval = 50, maxval = 500, group = g_detect, tooltip = "Remove a level after its original pivot is older than this number of bars.")
max_levels_per_type = input.int(30, "Maximum Levels per Type", minval = 5, maxval = 75, group = g_detect, tooltip = "Safety cap for stored resistance and support levels. Oldest levels are removed first.")
use_wick_filter     = input.bool(false, "Wick Dominance Filter", group = g_detect, tooltip = "Only register pivots whose wick on the pivot side is larger than both the candle body and the opposite wick.")
merge_levels        = input.bool(true, "Merge Nearby Active Levels", group = g_detect, tooltip = "Skip a new pivot when an ACTIVE level of the same type already exists within the merge distance. Broken levels do not block new levels.")
merge_atr_mult      = input.float(0.5, "Merge Distance (x ATR-14)", minval = 0.1, step = 0.1, group = g_detect, tooltip = "Minimum spacing between active same-type levels, measured using current ATR-14.")

breakout_mode    = input.string("Close", "Breakout Confirmation", options = ["Wick", "Close"], group = g_signal, tooltip = "Wick is faster but includes intrabar fakeouts. Close waits for a confirmed candle close beyond the level.")
breakout_atr_buf = input.float(0.0, "Breakout Buffer (x ATR-14)", minval = 0.0, maxval = 2.0, step = 0.05, group = g_signal, tooltip = "Optional distance beyond the level required for a breakout. Zero keeps the exact level boundary.")
show_breakouts   = input.bool(true, "Show Breakout Signals", group = g_signal)
show_reversals   = input.bool(true, "Show Confirmed Reversal Levels", group = g_signal, tooltip = "Track broken resistance retested as support and broken support retested as resistance.")
retest_mode      = input.string("Close", "Reversal Confirmation", options = ["Touch", "Close"], group = g_signal, tooltip = "Touch is aggressive and accepts any later overlap with the zone. Close requires a confirmed retest candle to close back on the new-role side of the entire zone.")
show_failures    = input.bool(true, "Show Reversal Failures", group = g_signal, tooltip = "Mark and invalidate flipped support/resistance when a confirmed close crosses the far side of its zone.")

level_start_mode = input.string("Confirmation", "Historical Level Start", options = ["Confirmation", "Pivot"], group = g_display, tooltip = "Confirmation is honest to real-time availability. Pivot back-draws the level to the original pivot candle for visual context.")
use_boxes        = input.bool(false, "Display as Zones", group = g_display, tooltip = "Use the original pivot wick range as a zone. The same price range is preserved after an S/R flip.")
show_labels      = input.bool(true, "Show Price Labels", group = g_display)
signal_size      = input.int(4, "Event Marker Size", minval = 1, maxval = 24, group = g_display, tooltip = "Font size of the on-chart event markers (breakout triangles and reversal-failure crosses) in typographic points. Kept compact by default; raise it if the markers feel too small.")

resistance_line_col = input.color(color.red, "Resistance Line/Zone", inline = "base_lines", group = g_colors)
support_line_col    = input.color(color.green, "Support Line/Zone", inline = "base_lines", group = g_colors)
rs_line_col         = input.color(color.green, "R→S Line/Zone", inline = "flip_lines", group = g_colors)
sr_line_col         = input.color(color.red, "S→R Line/Zone", inline = "flip_lines", group = g_colors)

resistance_label_col = input.color(color.red, "Resistance Label", inline = "base_labels", group = g_colors)
support_label_col    = input.color(color.green, "Support Label", inline = "base_labels", group = g_colors)
rs_label_col         = input.color(color.green, "R→S Label", inline = "flip_labels", group = g_colors)
sr_label_col         = input.color(color.red, "S→R Label", inline = "flip_labels", group = g_colors)

res_breakout_col = input.color(color.blue, "Resistance Breakout", inline = "breakout_signals", group = g_colors)
sup_breakout_col = input.color(color.orange, "Support Breakout", inline = "breakout_signals", group = g_colors)
support_fail_col = input.color(color.red, "Support Failure", inline = "failure_signals", group = g_colors)
resistance_fail_col = input.color(color.lime, "Resistance Failure", inline = "failure_signals", group = g_colors)

//--------------------------------------------------------------------------------------------------
// CONSTANTS & DERIVED SETTINGS
//--------------------------------------------------------------------------------------------------
int LABEL_OFFSET     = 7
int STATE_ACTIVE     = 0
int STATE_BROKEN     = 1
int STATE_RETESTED   = 2
int MAX_EVENT_LABELS = 150

bool breakout_close  = breakout_mode == "Close"
bool retest_close    = retest_mode == "Close"
bool start_at_pivot  = level_start_mode == "Pivot"
int max_flip_levels  = max_levels_per_type * 2

float atr_value = ta.atr(14)
float confirmed_pivot_high = ta.pivothigh(pivot_length, pivot_length)
float confirmed_pivot_low  = ta.pivotlow(pivot_length, pivot_length)

//--------------------------------------------------------------------------------------------------
// STATE
//--------------------------------------------------------------------------------------------------
// Resistance arrays remain index-aligned.
var indexes_r          = array.new_int()
var confirm_indexes_r  = array.new_int()
var prices_r           = array.new_float()
var zone_tops_r        = array.new_float()
var zone_bottoms_r     = array.new_float()
var states_r           = array.new_int()
var breakout_indexes_r = array.new_int()

// Support arrays remain index-aligned.
var indexes_s          = array.new_int()
var confirm_indexes_s  = array.new_int()
var prices_s           = array.new_float()
var zone_tops_s        = array.new_float()
var zone_bottoms_s     = array.new_float()
var states_s           = array.new_int()
var breakout_indexes_s = array.new_int()

// A flip has one fixed new role. Its original zone is preserved until expiry or invalidation.
var flip_prices           = array.new_float()
var flip_zone_tops        = array.new_float()
var flip_zone_bottoms     = array.new_float()
var flip_orig_indexes     = array.new_int()
var flip_breakout_indexes = array.new_int()
var flip_is_support       = array.new_bool()

// Last-bar drawings are transient. Event markers persist for a bounded number of bars/events.
var draw_lines  = array.new_line()
var draw_labels = array.new_label()
var draw_boxes  = array.new_box()

var event_labels        = array.new_label()
var event_label_indexes = array.new_int()

//--------------------------------------------------------------------------------------------------
// HELPERS
//--------------------------------------------------------------------------------------------------
drawPriceLabel(string prefix, float price, color col) =>
    lbl = label.new(bar_index + LABEL_OFFSET, price, prefix + str.tostring(price, format.mintick), color = color.new(col, 90), style = label.style_label_left, textcolor = col, size = size.small)
    label.set_text_font_family(lbl, font.family_monospace)
    label.set_text_formatting(lbl, text.format_bold)
    array.push(draw_labels, lbl)

// anchor_idx ties marker expiry to the source level's original-pivot lookback.
// A failure marker can intentionally remain after its invalidated flip drawing is removed.
trackEventLabel(label lbl, int anchor_idx) =>
    array.push(event_labels, lbl)
    array.push(event_label_indexes, anchor_idx)
    if array.size(event_labels) > MAX_EVENT_LABELS
        label.delete(array.shift(event_labels))
        array.shift(event_label_indexes)

//--------------------------------------------------------------------------------------------------
// CLEAR AND PRUNE STATE
//--------------------------------------------------------------------------------------------------
// Rebuild transient last-bar drawings so labels and lines always reflect current state.
if barstate.islast
    if array.size(draw_lines) > 0
        for i = 0 to array.size(draw_lines) - 1
            line.delete(array.get(draw_lines, i))
    if array.size(draw_labels) > 0
        for i = 0 to array.size(draw_labels) - 1
            label.delete(array.get(draw_labels, i))
    if array.size(draw_boxes) > 0
        for i = 0 to array.size(draw_boxes) - 1
            box.delete(array.get(draw_boxes, i))
    array.clear(draw_lines)
    array.clear(draw_labels)
    array.clear(draw_boxes)

// Event markers use their source level's original pivot as the lookback anchor.
if array.size(event_labels) > 0
    for i = array.size(event_labels) - 1 to 0
        if bar_index - array.get(event_label_indexes, i) > lookback_period
            label.delete(array.get(event_labels, i))
            array.remove(event_labels, i)
            array.remove(event_label_indexes, i)

// Invalidate a flipped level only on a confirmed close beyond the far side of its fixed zone.
bool flipped_support_failed    = false
bool flipped_resistance_failed = false

if array.size(flip_prices) > 0
    for i = array.size(flip_prices) - 1 to 0
        bool expired    = bar_index - array.get(flip_orig_indexes, i) > lookback_period
        bool is_support = array.get(flip_is_support, i)
        bool failed     = barstate.isconfirmed and (is_support ? close < array.get(flip_zone_bottoms, i) : close > array.get(flip_zone_tops, i))
        if failed
            flipped_support_failed    := flipped_support_failed or is_support
            flipped_resistance_failed := flipped_resistance_failed or not is_support
            if show_failures
                fail_lbl = label.new(bar_index, is_support ? low : high, style = label.style_xcross, color = is_support ? support_fail_col : resistance_fail_col, size = signal_size)
                label.set_yloc(fail_lbl, is_support ? yloc.belowbar : yloc.abovebar)
                trackEventLabel(fail_lbl, array.get(flip_orig_indexes, i))
        if expired or failed
            array.remove(flip_prices, i)
            array.remove(flip_zone_tops, i)
            array.remove(flip_zone_bottoms, i)
            array.remove(flip_orig_indexes, i)
            array.remove(flip_breakout_indexes, i)
            array.remove(flip_is_support, i)

//--------------------------------------------------------------------------------------------------
// LEVEL PROCESSING (one call per type, every bar)
//--------------------------------------------------------------------------------------------------
processLevels(bool isRes, float pivot_price) =>
    float upper_wick = high - math.max(open, close)
    float lower_wick = math.min(open, close) - low
    float body_size  = math.abs(close - open)
    float own_wick   = isRes ? upper_wick : lower_wick
    float opp_wick   = isRes ? lower_wick : upper_wick

    indexes          = isRes ? indexes_r : indexes_s
    confirm_indexes  = isRes ? confirm_indexes_r : confirm_indexes_s
    prices           = isRes ? prices_r : prices_s
    zone_tops        = isRes ? zone_tops_r : zone_tops_s
    zone_bottoms     = isRes ? zone_bottoms_r : zone_bottoms_s
    states           = isRes ? states_r : states_s
    breakout_indexes = isRes ? breakout_indexes_r : breakout_indexes_s
    color level_col  = isRes ? resistance_line_col : support_line_col
    color label_col  = isRes ? resistance_label_col : support_label_col

    // Remove expired levels before merge detection so stale history cannot block a fresh pivot.
    if array.size(indexes) > 0
        for i = array.size(indexes) - 1 to 0
            if bar_index - array.get(indexes, i) > lookback_period
                array.remove(indexes, i)
                array.remove(confirm_indexes, i)
                array.remove(prices, i)
                array.remove(zone_tops, i)
                array.remove(zone_bottoms, i)
                array.remove(states, i)
                array.remove(breakout_indexes, i)

    // Register a confirmed pivot. Only ACTIVE levels participate in merge suppression.
    if not na(pivot_price)
        int pivot_idx    = bar_index - pivot_length
        float pivot_top  = isRes ? pivot_price : math.min(open[pivot_length], close[pivot_length])
        float pivot_bot  = isRes ? math.max(open[pivot_length], close[pivot_length]) : pivot_price
        bool wick_ok     = not use_wick_filter or (own_wick[pivot_length] > body_size[pivot_length] and own_wick[pivot_length] > opp_wick[pivot_length])
        bool merge_ok    = true
        if merge_levels and array.size(prices) > 0
            for i = 0 to array.size(prices) - 1
                if array.get(states, i) == STATE_ACTIVE and math.abs(array.get(prices, i) - pivot_price) <= atr_value * merge_atr_mult
                    merge_ok := false
                    break
        if wick_ok and merge_ok
            array.push(indexes, pivot_idx)
            array.push(confirm_indexes, bar_index)
            array.push(prices, pivot_price)
            array.push(zone_tops, pivot_top)
            array.push(zone_bottoms, pivot_bot)
            array.push(states, STATE_ACTIVE)
            array.push(breakout_indexes, int(na))

            // Hard cap: remove the oldest full record while keeping every array aligned.
            if array.size(indexes) > max_levels_per_type
                array.shift(indexes)
                array.shift(confirm_indexes)
                array.shift(prices)
                array.shift(zone_tops)
                array.shift(zone_bottoms)
                array.shift(states)
                array.shift(breakout_indexes)

    bool broke_now   = false
    bool flipped_now = false

    if array.size(indexes) > 0
        for i = 0 to array.size(indexes) - 1
            int state          = array.get(states, i)
            int pivot_idx      = array.get(indexes, i)
            float price        = array.get(prices, i)
            float zone_top     = array.get(zone_tops, i)
            float zone_bottom  = array.get(zone_bottoms, i)
            int breakout_idx   = array.get(breakout_indexes, i)
            float buffer       = nz(atr_value) * breakout_atr_buf
            float break_level  = isRes ? zone_top + buffer : zone_bottom - buffer

            if state == STATE_ACTIVE
                bool crossed = breakout_close ? barstate.isconfirmed and (isRes ? close > break_level : close < break_level) : (isRes ? high > break_level : low < break_level)
                if crossed
                    array.set(states, i, STATE_BROKEN)
                    array.set(breakout_indexes, i, bar_index)
                    broke_now := true
                    if show_breakouts
                        breakout_lbl = label.new(bar_index, isRes ? low : high, style = isRes ? label.style_triangleup : label.style_triangledown, color = isRes ? res_breakout_col : sup_breakout_col, size = signal_size)
                        label.set_yloc(breakout_lbl, isRes ? yloc.belowbar : yloc.abovebar)
                        trackEventLabel(breakout_lbl, pivot_idx)

            else if state == STATE_BROKEN and show_reversals and bar_index > breakout_idx
                bool zone_touched = high >= zone_bottom and low <= zone_top
                bool held_new_side = not retest_close or (barstate.isconfirmed and (isRes ? close >= zone_top : close <= zone_bottom))
                if zone_touched and held_new_side
                    array.set(states, i, STATE_RETESTED)
                    array.push(flip_prices, price)
                    array.push(flip_zone_tops, zone_top)
                    array.push(flip_zone_bottoms, zone_bottom)
                    array.push(flip_orig_indexes, pivot_idx)
                    array.push(flip_breakout_indexes, breakout_idx)
                    array.push(flip_is_support, isRes)
                    flipped_now := true

                    if array.size(flip_prices) > max_flip_levels
                        array.shift(flip_prices)
                        array.shift(flip_zone_tops)
                        array.shift(flip_zone_bottoms)
                        array.shift(flip_orig_indexes)
                        array.shift(flip_breakout_indexes)
                        array.shift(flip_is_support)

    // Draw original levels. Broken/retested levels stop at the breakout bar.
    if barstate.islast
        valid_prices = array.new_float()
        if array.size(indexes) > 0
            for i = 0 to array.size(indexes) - 1
                int state         = array.get(states, i)
                int pivot_idx     = array.get(indexes, i)
                int confirm_idx   = array.get(confirm_indexes, i)
                float price       = array.get(prices, i)
                float zone_top    = array.get(zone_tops, i)
                float zone_bottom = array.get(zone_bottoms, i)
                int breakout_idx  = array.get(breakout_indexes, i)
                bool is_active    = state == STATE_ACTIVE
                bool is_valid     = is_active and (isRes ? price > close : price < close)
                int line_start    = start_at_pivot ? pivot_idx : confirm_idx
                int line_end      = is_active ? bar_index : breakout_idx

                if use_boxes
                    array.push(draw_boxes, box.new(line_start, zone_top, line_end, zone_bottom, bgcolor = color.new(level_col, 82), border_color = color.new(level_col, 70)))
                else
                    array.push(draw_lines, line.new(line_start, price, line_end, price, color = level_col, width = 1))
                if is_valid
                    array.push(valid_prices, price)

        if show_labels and array.size(valid_prices) > 0
            if isRes
                array.sort(valid_prices, order.ascending)
            else
                array.sort(valid_prices, order.descending)
            for i = 0 to array.size(valid_prices) - 1
                drawPriceLabel((isRes ? "R" : "S") + str.tostring(i + 1) + ": ", array.get(valid_prices, i), label_col)

    [broke_now, flipped_now]

//--------------------------------------------------------------------------------------------------
// EXECUTION AND FLIPPED-LEVEL DRAWING
//--------------------------------------------------------------------------------------------------
[res_breakout, res_flip] = processLevels(true, confirmed_pivot_high)
[sup_breakout, sup_flip] = processLevels(false, confirmed_pivot_low)

if barstate.islast and show_reversals and array.size(flip_prices) > 0
    for i = 0 to array.size(flip_prices) - 1
        float price       = array.get(flip_prices, i)
        float zone_top    = array.get(flip_zone_tops, i)
        float zone_bottom = array.get(flip_zone_bottoms, i)
        int breakout_idx  = array.get(flip_breakout_indexes, i)
        bool is_support   = array.get(flip_is_support, i)
        color state_col   = is_support ? rs_line_col : sr_line_col
        color label_col   = is_support ? rs_label_col : sr_label_col

        if use_boxes
            array.push(draw_boxes, box.new(breakout_idx, zone_top, bar_index, zone_bottom, bgcolor = color.new(state_col, 78), border_color = color.new(state_col, 60)))
        else
            array.push(draw_lines, line.new(breakout_idx, price, bar_index, price, color = state_col, width = 2))
        if show_labels
            drawPriceLabel(is_support ? "RS: " : "SR: ", price, label_col)

//--------------------------------------------------------------------------------------------------
// ALERTS
//--------------------------------------------------------------------------------------------------
alertcondition(res_breakout, "Resistance Breakout", "{{ticker}} broke above a confirmed resistance level at {{close}}")
alertcondition(sup_breakout, "Support Breakout", "{{ticker}} broke below a confirmed support level at {{close}}")
alertcondition(res_flip, "Resistance to Support Flip", "{{ticker}} retested broken resistance as confirmed support")
alertcondition(sup_flip, "Support to Resistance Flip", "{{ticker}} retested broken support as confirmed resistance")
alertcondition(flipped_support_failed, "Flipped Support Failed", "{{ticker}} closed below the far side of a flipped support zone")
alertcondition(flipped_resistance_failed, "Flipped Resistance Failed", "{{ticker}} closed above the far side of a flipped resistance zone")
alertcondition(res_breakout or sup_breakout or res_flip or sup_flip or flipped_support_failed or flipped_resistance_failed, "Any S/R Event", "{{ticker}} generated a support/resistance event")
````
