# Northsea Auction Map [JOAT]

- url: https://www.tradingview.com/script/N0rMhUr6-Northsea-Auction-Map-JOAT/
- type: indicator
- pine_id: PUB;731fb7a99a184a6bab071accdd267127
- version: 1.0

## Description

[b]Northsea Auction Map [JOAT][/b]

[b]Introduction[/b]

Northsea Auction Map is an open-source auction-style overlay that builds a rolling or session-anchored profile directly on the chart. It estimates where business has been conducted, where value is concentrated, where activity is thin, and how price is positioned relative to that structure.

The problem this script solves is that directional tools alone do not explain where the market is accepting price and where it is rejecting price. Auction context is useful because trend and reversal behavior both depend on where price is trading relative to value. Northsea uses a configurable anchor, builds a profile histogram, derives value area and point of control, approximates delta bias, and summarizes that information in a clean on-chart framework.

[image]https://www.tradingview.com/x/BkVYcCiC/[/image]

[b]Core Concepts[/b]

[b]1. Session or Rolling Anchoring[/b]

The script can build its auction map from a live session anchor or from a fixed rolling window. That allows it to serve both intraday session analysis and broader window-based contextual analysis. Session anchoring can use exchange-aware timing or an explicit timezone selection so the profile starts from the intended session definition.

[b]2. Profile Row Construction[/b]

The chosen anchor range is divided into configurable price rows. Each eligible bar contributes volume into those rows, producing a simplified volume-at-price map. The widest concentration becomes the point of control, while the surrounding rows are expanded outward until the configured percentage of activity defines the value area.

[b]3. Point of Control and Value Area[/b]

Northsea calculates:

[list]
[*][b]POC:[/b] the highest-activity row
[*][b]VAH:[/b] the upper boundary of the selected value area
[*][b]VAL:[/b] the lower boundary of the selected value area
[/list]

These levels are drawn forward on the chart so users can quickly see whether price is trading inside accepted value or outside it.

[b]4. Delta Bias and Node Logic[/b]

The script derives a directional participation proxy and combines it with profile concentration to estimate whether the current map leans more bid-dominant, offer-dominant, or balanced. It also classifies high-value nodes and low-value nodes using row-level z-score logic so pockets of acceptance and low-participation gaps stand out.

[b]5. Anchored VWAP and Range Context[/b]

An anchored VWAP and session range lines are drawn alongside the profile. This gives the user both price-distribution context and mean-location context in the same overlay.

[b]Features[/b]

[list]
[*][b]Two anchoring modes:[/b] Session Anchor and Rolling Window
[*][b]Flexible session timezone handling:[/b] Supports exchange-aware or explicit timezone session anchoring
[*][b]Configurable profile density:[/b] Adjustable lookback, row count, width, and offset
[*][b]POC and value area:[/b] Automatically derived and extended on the chart
[*][b]HVN and LVN identification:[/b] Highlights acceptance nodes and thin areas
[*][b]Anchored VWAP:[/b] Adds a fair-value style reference line
[*][b]Session range guides:[/b] High, low, and midpoint lines
[*][b]Delta bias proxy:[/b] Adds directional auction context
[*][b]Dashboard summary:[/b] Anchor bars, range, POC/VWAP, value area, delta bias, location, and balance metrics
[/list]

[b]Input Parameters[/b]

[b]Anchoring:[/b]
[list]
[*]Anchor Mode
[*]Session Window
[*]Session Timezone
[*]Profile Lookback
[*]Profile Rows
[*]Value Area Percentage
[/list]

[b]Layout:[/b]
[list]
[*]Right Offset
[*]Profile Width
[*]Session Range toggle
[*]Anchored VWAP toggle
[*]Profile Labels toggle
[*]Node Summary toggle
[/list]

[b]Node Logic:[/b]
[list]
[*]High-Value Node Z
[*]Low-Value Node Z
[*]Node Transparency
[*]POC Highlight toggle
[*]Value Area Highlight toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Locate Price Relative to Value[/b]
If price is trading inside the value area, the market is operating near accepted value. If price is outside value and not returning quickly, the market may be discovering a new area.

[b]Step 2: Compare POC With VWAP[/b]
The relationship between POC and anchored VWAP can help show whether the bulk of business and the weighted mean price are clustered together or diverging.

[b]Step 3: Watch HVNs and LVNs[/b]
High-value nodes often behave like acceptance shelves. Low-value nodes often behave like traversal zones where price moves more quickly. These are not guaranteed reactions, but they are useful structural references.

[b]Step 4: Use the Delta Bias as Context, Not Certainty[/b]
The delta bias proxy helps describe whether the current map is leaning more bid-side or offer-side. It should be read as auction context rather than treated as direct order-book truth.

[b]Indicator Limitations[/b]

[list]
[*]The script approximates auction structure from bar data and does not reconstruct true exchange-level volume at every traded price
[*]Profile interpretation depends on the selected anchor; different anchors can produce different maps
[*]Thinly traded instruments may generate unstable row distributions
[*]Node thresholds are model-based and may require tuning by instrument
[/list]

[b]Originality Statement[/b]

Northsea Auction Map is original in the way it combines anchored profiling, value-area construction, node classification, delta bias estimation, and anchored VWAP into one restrained overlay. The goal is not to duplicate a platform-native profile panel, but to provide a configurable auction context tool that can travel with the chart and integrate directly with other analytical layers.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice. Profile levels and node classifications are derived from historical bar data and model assumptions, so they can differ from full exchange or footprint tools. Use independent judgment and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Northsea Auction Map [JOAT]", shorttitle="Northsea Auction [JOAT]", overlay=true, max_bars_back=5000, max_boxes_count=500, max_lines_count=500, max_labels_count=100)

// =============================================================================
// INPUTS
// =============================================================================
group_anchor = "Anchoring"
anchor_mode = input.string("Session Anchor", "Anchor Mode", options=["Session Anchor", "Rolling Window"], group=group_anchor)
anchor_session = input.session("0930-1600", "Session Window", group=group_anchor)
anchor_timezone = input.string("Exchange", "Session Timezone", options=["Exchange", "UTC", "America/New_York", "Europe/London", "Europe/Amsterdam", "Asia/Tokyo"], group=group_anchor)
profile_lookback = input.int(160, "Profile Lookback", minval=30, maxval=400, group=group_anchor)
profile_rows = input.int(56, "Profile Rows", minval=20, maxval=120, group=group_anchor)
value_area_pct = input.float(70.0, "Value Area %", minval=50.0, maxval=95.0, step=1.0, group=group_anchor)

group_layout = "Layout"
profile_offset = input.int(8, "Right Offset", minval=1, maxval=40, group=group_layout)
profile_width = input.int(36, "Profile Width", minval=12, maxval=90, group=group_layout)
show_session_range = input.bool(true, "Show Session Range", group=group_layout)
show_session_vwap = input.bool(true, "Show Anchored VWAP", group=group_layout)
show_profile_labels = input.bool(true, "Show Key Labels", group=group_layout)
show_node_summary = input.bool(true, "Show Node Summary", group=group_layout)

group_nodes = "Node Logic"
hvn_z = input.float(1.15, "High-Value Node Z", minval=0.5, maxval=3.0, step=0.05, group=group_nodes)
lvn_z = input.float(-0.80, "Low-Value Node Z", minval=-3.0, maxval=-0.1, step=0.05, group=group_nodes)
node_shade = input.int(72, "Node Transparency", minval=20, maxval=95, group=group_nodes)
highlight_poc = input.bool(true, "Highlight POC", group=group_nodes)
highlight_value_area = input.bool(true, "Highlight Value Area", group=group_nodes)

group_visual = "Visuals"
palette_mode = input.string("Northsea", "Palette", options=["Northsea", "Tide", "Harbor"], group=group_visual)
show_delta_tint = input.bool(true, "Show Delta Tint", group=group_visual)
show_profile_body = input.bool(true, "Show Profile Body", group=group_visual)
show_session_extremes = input.bool(true, "Show Session Extremes", group=group_visual)
label_scale = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=group_visual)

group_dash = "Dashboard"
show_dashboard = input.bool(true, "Show Dashboard", group=group_dash)
dash_size = input.string("Medium", "Dashboard Size", options=["Small", "Medium", "Large"], group=group_dash)
dash_position = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=group_dash)

// =============================================================================
// THEME
// =============================================================================
color ns_bg = color.new(#071018, 0)
color ns_bg_soft = color.new(#0b1722, 0)
color ns_panel = color.new(#0f1b28, 0)
color ns_border = color.new(#223244, 0)
color ns_text = color.new(#eef4ff, 0)
color ns_dim = color.new(#8da2b5, 0)
color ns_bull = color.new(#58d1b0, 0)
color ns_bear = color.new(#d96f7b, 0)
color ns_neutral = color.new(#8fa8bd, 0)
color ns_warn = color.new(#d2b36f, 0)
color ns_accent = color.new(#62a8ff, 0)
color ns_grid = color.new(#284055, 0)

color bull_color = palette_mode == "Harbor" ? color.new(#66ddc3, 0) : palette_mode == "Tide" ? color.new(#53c6ff, 0) : ns_bull
color bear_color = palette_mode == "Harbor" ? color.new(#df7b8d, 0) : palette_mode == "Tide" ? color.new(#ff8c6b, 0) : ns_bear
color accent_color = palette_mode == "Harbor" ? color.new(#74b0ff, 0) : palette_mode == "Tide" ? color.new(#95c8ff, 0) : ns_accent
color neutral_color = ns_neutral

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================
f_safe_div(float num, float den, float fallback) =>
    math.abs(den) > 0.0000001 ? num / den : fallback

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_lerp_color(color c1, color c2, float t) =>
    float p = f_clamp(t, 0.0, 1.0)
    color.rgb(
         int(color.r(c1) * (1.0 - p) + color.r(c2) * p),
         int(color.g(c1) * (1.0 - p) + color.g(c2) * p),
         int(color.b(c1) * (1.0 - p) + color.b(c2) * p))

f_array_sum(float[] source) =>
    float total = 0.0
    int size_ = array.size(source)
    if size_ > 0
        for i = 0 to size_ - 1
            total += array.get(source, i)
    total

f_array_mean(float[] source) =>
    int size_ = array.size(source)
    size_ > 0 ? f_array_sum(source) / size_ : 0.0

f_array_stdev(float[] source) =>
    int size_ = array.size(source)
    float mean_ = f_array_mean(source)
    float sum_sq = 0.0
    if size_ > 1
        for i = 0 to size_ - 1
            float diff = array.get(source, i) - mean_
            sum_sq += diff * diff
        math.sqrt(sum_sq / math.max(size_ - 1, 1))
    else
        0.0

f_array_argmax(float[] source) =>
    int size_ = array.size(source)
    int idx = 0
    float best = size_ > 0 ? array.get(source, 0) : 0.0
    if size_ > 1
        for i = 1 to size_ - 1
            float val = array.get(source, i)
            if val > best
                best := val
                idx := i
    idx

f_overlap_ratio(float lo1, float hi1, float lo2, float hi2) =>
    float overlap = math.max(0.0, math.min(hi1, hi2) - math.max(lo1, lo2))
    float width = math.max(hi1 - lo1, syminfo.mintick)
    overlap / width

f_bar_imbalance(float o, float h, float l, float c, float v) =>
    float range_ = math.max(h - l, syminfo.mintick)
    float close_pos = f_safe_div(c - l, range_, 0.5)
    float body = math.abs(c - o)
    float body_ratio = f_safe_div(body, range_, 0.0)
    float wick_buy = (math.min(o, c) - l) + (c > o ? body : 0.0)
    float wick_sell = (h - math.max(o, c)) + (c < o ? body : 0.0)
    float wick_bias = f_safe_div(wick_buy - wick_sell, wick_buy + wick_sell, 0.0)
    float close_bias = 2.0 * close_pos - 1.0
    float blended = 0.45 * close_bias + 0.35 * wick_bias + 0.20 * (c >= o ? body_ratio : -body_ratio)
    v * blended

f_bin_low(float range_low, float step, int idx) =>
    range_low + step * idx

f_bin_high(float range_low, float step, int idx) =>
    range_low + step * (idx + 1)

f_bin_mid(float range_low, float step, int idx) =>
    range_low + step * (idx + 0.5)

f_reset_float_array(float[] source, float fill) =>
    int size_ = array.size(source)
    if size_ > 0
        for i = 0 to size_ - 1
            array.set(source, i, fill)

f_clear_boxes(box[] items) =>
    int size_ = array.size(items)
    if size_ > 0
        for i = 0 to size_ - 1
            box.delete(array.get(items, i))
    array.clear(items)

f_clear_lines(line[] items) =>
    int size_ = array.size(items)
    if size_ > 0
        for i = 0 to size_ - 1
            line.delete(array.get(items, i))
    array.clear(items)

f_clear_labels(label[] items) =>
    int size_ = array.size(items)
    if size_ > 0
        for i = 0 to size_ - 1
            label.delete(array.get(items, i))
    array.clear(items)

f_profile_label_size(string scale) =>
    scale == "Tiny" ? size.tiny : scale == "Normal" ? size.normal : size.small

f_dashboard_size(string scale) =>
    scale == "Small" ? size.small : scale == "Medium" ? size.normal : size.large

f_dashboard_position(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     pos == "Bottom Left" ? position.bottom_left : position.top_right

f_profile_fill_color(float delta_value, bool in_value_area, bool is_poc, bool is_hvn, bool is_lvn) =>
    color base = delta_value >= 0.0 ? bull_color : bear_color
    color area_tint = in_value_area ? color.new(accent_color, 0) : base
    color node_tint = is_poc ? color.new(ns_warn, 0) : is_hvn ? color.new(accent_color, 0) : is_lvn ? color.new(ns_neutral, 0) : area_tint
    node_tint

f_profile_border_color(float delta_value, bool in_value_area, bool is_poc, bool is_hvn, bool is_lvn) =>
    color base = delta_value >= 0.0 ? color.new(bull_color, 0) : color.new(bear_color, 0)
    color area_tint = in_value_area ? color.new(accent_color, 0) : base
    color node_tint = is_poc ? color.new(ns_warn, 0) : is_hvn ? color.new(accent_color, 0) : is_lvn ? color.new(ns_neutral, 0) : area_tint
    node_tint

f_metric_color(float value, float neutral_band) =>
    value > neutral_band ? bull_color : value < -neutral_band ? bear_color : neutral_color

f_price_location(float price, float low_, float high_) =>
    float span = math.max(high_ - low_, syminfo.mintick)
    f_clamp(f_safe_div(price - low_, span, 0.5), 0.0, 1.0)

f_format_session_mode(string mode, bool fallback) =>
    fallback ? "Rolling Fallback" : mode

f_level_text(float price) =>
    str.tostring(price, format.mintick)

f_small_dash_value(float value) =>
    str.tostring(value, "#.##")

f_round_int(float value) =>
    int(math.round(value))

f_bar_valid(int idx, int max_scan) =>
    idx >= 0 and idx <= max_scan

// =============================================================================
// PERSISTENT OBJECTS / ARRAYS
// =============================================================================
var float[] profile_total = array.new_float(profile_rows, 0.0)
var float[] profile_buy = array.new_float(profile_rows, 0.0)
var float[] profile_sell = array.new_float(profile_rows, 0.0)
var float[] profile_delta = array.new_float(profile_rows, 0.0)
var box[] profile_boxes = array.new_box()
var box[] overlay_boxes = array.new_box()
var line[] guide_lines = array.new_line()
var label[] info_labels = array.new_label()
var table northsea_dash = table.new(position.top_right, 2, 8, frame_color=ns_border, frame_width=1)

// =============================================================================
// CORE AUCTION STATE
// =============================================================================
int max_scan = math.min(profile_lookback - 1, bar_index)
string session_timezone = anchor_timezone == "Exchange" ? syminfo.timezone : anchor_timezone
series int session_stamp = time(timeframe.period, anchor_session, session_timezone)

int anchor_start_offset = na
int anchor_end_offset = na
bool use_rolling_window = anchor_mode == "Rolling Window"

if not use_rolling_window
    for i = 0 to max_scan
        if na(anchor_end_offset) and not na(session_stamp[i])
            anchor_end_offset := i
    if na(anchor_end_offset)
        use_rolling_window := true
    else
        anchor_start_offset := anchor_end_offset
        for j = anchor_end_offset to max_scan
            if na(session_stamp[j])
                anchor_start_offset := math.max(j - 1, anchor_end_offset)
                break
            if j == max_scan
                anchor_start_offset := max_scan

int anchor_begin = use_rolling_window ? max_scan : anchor_start_offset
int anchor_finish = use_rolling_window ? 0 : anchor_end_offset
int anchor_bar_count = use_rolling_window ? (max_scan + 1) : (not na(anchor_end_offset) and not na(anchor_start_offset) ? math.max(anchor_start_offset - anchor_end_offset + 1, 1) : 0)

float anchor_low = na
float anchor_high = na
float anchor_volume = 0.0
float anchor_vwap_num = 0.0
float anchor_vwap_den = 0.0
float anchor_delta_sum = 0.0
float anchor_buy_sum = 0.0
float anchor_sell_sum = 0.0
float anchor_body_sum = 0.0
int eligible_bars = 0

// =============================================================================
// ANALYTICAL PASS 1
// Finds the price envelope, session statistics, and anchored VWAP basis.
// =============================================================================
if barstate.islast
    for i = 0 to max_scan
        bool eligible_bar = use_rolling_window ? true : f_bar_valid(i, max_scan) and i >= anchor_finish and i <= anchor_begin
        if eligible_bar
            float hi_i = high[i]
            float lo_i = low[i]
            float vol_i = volume[i]
            float price_i = hlc3[i]
            float delta_i = f_bar_imbalance(open[i], hi_i, lo_i, close[i], vol_i)
            float body_i = math.abs(close[i] - open[i])
            float range_i = math.max(hi_i - lo_i, syminfo.mintick)
            float delta_share = f_clamp(f_safe_div(delta_i, vol_i, 0.0), -1.0, 1.0)
            float buy_share = 0.5 + 0.5 * delta_share
            float sell_share = 1.0 - buy_share

            anchor_low := na(anchor_low) ? lo_i : math.min(anchor_low, lo_i)
            anchor_high := na(anchor_high) ? hi_i : math.max(anchor_high, hi_i)
            anchor_volume += vol_i
            anchor_vwap_num += price_i * vol_i
            anchor_vwap_den += vol_i
            anchor_delta_sum += delta_i
            anchor_buy_sum += vol_i * buy_share
            anchor_sell_sum += vol_i * sell_share
            anchor_body_sum += body_i / range_i
            eligible_bars += 1

float anchor_mid = na(anchor_low) or na(anchor_high) ? na : (anchor_high + anchor_low) * 0.5
float anchor_vwap = f_safe_div(anchor_vwap_num, anchor_vwap_den, na)
float profile_step = na(anchor_low) or na(anchor_high) ? syminfo.mintick : math.max((anchor_high - anchor_low) / profile_rows, syminfo.mintick)

// =============================================================================
// ANALYTICAL PASS 2
// Builds the auction histogram, buy/sell proxy, and delta distribution.
// =============================================================================
if barstate.islast
    f_reset_float_array(profile_total, 0.0)
    f_reset_float_array(profile_buy, 0.0)
    f_reset_float_array(profile_sell, 0.0)
    f_reset_float_array(profile_delta, 0.0)

    if eligible_bars > 0 and not na(anchor_low) and not na(anchor_high)
        for i = 0 to max_scan
            bool eligible_bar = use_rolling_window ? true : f_bar_valid(i, max_scan) and i >= anchor_finish and i <= anchor_begin
            if eligible_bar
                float hi_i = high[i]
                float lo_i = low[i]
                float vol_i = volume[i]
                float delta_i = f_bar_imbalance(open[i], hi_i, lo_i, close[i], vol_i)
                float delta_share = f_clamp(f_safe_div(delta_i, vol_i, 0.0), -1.0, 1.0)
                float buy_share = 0.5 + 0.5 * delta_share
                float sell_share = 1.0 - buy_share
                float bar_range = math.max(hi_i - lo_i, syminfo.mintick)

                for r = 0 to profile_rows - 1
                    float row_lo = f_bin_low(anchor_low, profile_step, r)
                    float row_hi = f_bin_high(anchor_low, profile_step, r)
                    float overlap = math.max(0.0, math.min(hi_i, row_hi) - math.max(lo_i, row_lo))
                    float weight = f_safe_div(overlap, bar_range, 0.0)
                    if weight > 0.0
                        float alloc = vol_i * weight
                        array.set(profile_total, r, array.get(profile_total, r) + alloc)
                        array.set(profile_buy, r, array.get(profile_buy, r) + alloc * buy_share)
                        array.set(profile_sell, r, array.get(profile_sell, r) + alloc * sell_share)
                        array.set(profile_delta, r, array.get(profile_delta, r) + alloc * (buy_share - sell_share))

    float profile_total_volume = f_array_sum(profile_total)
    int poc_index = profile_total_volume > 0.0 ? f_array_argmax(profile_total) : 0
    float poc_volume = profile_total_volume > 0.0 ? array.get(profile_total, poc_index) : 0.0
    float poc_price = f_bin_mid(anchor_low, profile_step, poc_index)

    int vah_index = poc_index
    int val_index = poc_index
    float accepted_volume = poc_volume
    float target_volume = profile_total_volume * value_area_pct / 100.0
    int left_scan = poc_index - 1
    int right_scan = poc_index + 1
    for _ = 0 to profile_rows - 1
        if accepted_volume >= target_volume
            break
        float left_vol = left_scan >= 0 ? array.get(profile_total, left_scan) : -1.0
        float right_vol = right_scan < profile_rows ? array.get(profile_total, right_scan) : -1.0
        if right_vol >= left_vol
            if right_scan < profile_rows
                accepted_volume += right_vol
                vah_index := right_scan
                right_scan += 1
        else
            if left_scan >= 0
                accepted_volume += left_vol
                val_index := left_scan
                left_scan -= 1

    float vah_price = f_bin_high(anchor_low, profile_step, vah_index)
    float val_price = f_bin_low(anchor_low, profile_step, val_index)
    float value_area_volume = accepted_volume
    float value_area_ratio = f_safe_div(value_area_volume, profile_total_volume, 0.0)
    float profile_mean = f_array_mean(profile_total)
    float profile_stdev = f_array_stdev(profile_total)
    float profile_delta_total = f_array_sum(profile_delta)
    float delta_bias = f_safe_div(profile_delta_total, profile_total_volume, 0.0)
    float buy_pressure = f_safe_div(f_array_sum(profile_buy), profile_total_volume, 0.0)
    float sell_pressure = f_safe_div(f_array_sum(profile_sell), profile_total_volume, 0.0)
    float location_now = na(anchor_low) or na(anchor_high) ? na : f_price_location(close, anchor_low, anchor_high)
    float vwap_dist = na(anchor_vwap) ? na : f_safe_div(close - anchor_vwap, math.max(anchor_high - anchor_low, syminfo.mintick), 0.0)
    float range_size = na(anchor_low) or na(anchor_high) ? na : anchor_high - anchor_low
    float balance_metric = f_safe_div(profile_mean, math.max(profile_stdev, syminfo.mintick), 0.0)
    float acceptance_metric = f_safe_div(value_area_volume, math.max(profile_total_volume, syminfo.mintick), 0.0)

    // =============================================================================
    // DRAWING RESET
    // Clean object lifecycle keeps the overlay tidy on every update.
    // =============================================================================
    f_clear_boxes(profile_boxes)
    f_clear_boxes(overlay_boxes)
    f_clear_lines(guide_lines)
    f_clear_labels(info_labels)

    // =============================================================================
    // PROFILE RENDERING
    // Draw the auction histogram to the right of price, using wide boxes that
    // remain readable on dark themes and do not clutter the active candles.
    // =============================================================================
    if show_profile_body and eligible_bars > 0 and profile_total_volume > 0.0
        float max_profile_volume = math.max(poc_volume, syminfo.mintick)
        int profile_left_x = bar_index + profile_offset
        for r = 0 to profile_rows - 1
            float row_vol = array.get(profile_total, r)
            float row_delta = array.get(profile_delta, r)
            float row_buy = array.get(profile_buy, r)
            float row_sell = array.get(profile_sell, r)
            float row_lo = f_bin_low(anchor_low, profile_step, r)
            float row_hi = f_bin_high(anchor_low, profile_step, r)
            float vol_ratio = f_safe_div(row_vol, max_profile_volume, 0.0)
            float width_scale = math.sqrt(math.max(vol_ratio, 0.0))
            int row_width = math.max(1, f_round_int(profile_width * width_scale))
            int row_right_x = profile_left_x + row_width

            float z_score = profile_stdev > syminfo.mintick ? (row_vol - profile_mean) / profile_stdev : 0.0
            bool is_poc = r == poc_index
            bool is_hvn = z_score >= hvn_z
            bool is_lvn = z_score <= lvn_z
            bool in_value_area = r >= val_index and r <= vah_index
            bool bullish_row = row_buy >= row_sell

            color fill_color = f_profile_fill_color(row_delta, in_value_area, is_poc, is_hvn, is_lvn)
            color border_color = f_profile_border_color(row_delta, in_value_area, is_poc, is_hvn, is_lvn)
            int fill_alpha = is_poc ? 60 : in_value_area ? 78 : is_hvn ? 82 : is_lvn ? 88 : 84
            int border_alpha = is_poc ? 10 : is_hvn ? 18 : is_lvn ? 35 : 50
            color tint = bullish_row ? bull_color : bear_color
            color blended = f_lerp_color(fill_color, tint, 0.35)
            color final_fill = color.new(blended, fill_alpha)
            color final_border = color.new(border_color, border_alpha)

            box row_box = box.new(left=profile_left_x, top=row_hi, right=row_right_x, bottom=row_lo, xloc=xloc.bar_index, bgcolor=final_fill, border_color=final_border)
            array.push(profile_boxes, row_box)

        if highlight_value_area
            box va_box = box.new(left=profile_left_x, top=vah_price, right=profile_left_x + profile_width, bottom=val_price, xloc=xloc.bar_index, bgcolor=color.new(accent_color, 88), border_color=color.new(accent_color, 45))
            array.push(overlay_boxes, va_box)

        if show_session_range and not na(anchor_low) and not na(anchor_high)
            int range_left_x = bar_index - anchor_bar_count + 1
            line hi_line = line.new(x1=range_left_x, y1=anchor_high, x2=bar_index + profile_offset + profile_width, y2=anchor_high, xloc=xloc.bar_index, extend=extend.right, color=color.new(ns_warn, 15), width=1)
            line lo_line = line.new(x1=range_left_x, y1=anchor_low, x2=bar_index + profile_offset + profile_width, y2=anchor_low, xloc=xloc.bar_index, extend=extend.right, color=color.new(ns_neutral, 25), width=1)
            line mid_line = line.new(x1=range_left_x, y1=anchor_mid, x2=bar_index + profile_offset + profile_width, y2=anchor_mid, xloc=xloc.bar_index, extend=extend.right, color=color.new(ns_grid, 60), width=1)
            array.push(guide_lines, hi_line)
            array.push(guide_lines, lo_line)
            array.push(guide_lines, mid_line)

        if show_session_vwap and not na(anchor_vwap)
            int vwap_left_x = bar_index - anchor_bar_count + 1
            line vwap_line = line.new(x1=vwap_left_x, y1=anchor_vwap, x2=bar_index + profile_offset + profile_width, y2=anchor_vwap, xloc=xloc.bar_index, extend=extend.right, color=color.new(accent_color, 0), width=2)
            array.push(guide_lines, vwap_line)

        line poc_line = line.new(x1=bar_index + profile_offset, y1=poc_price, x2=bar_index + profile_offset + profile_width, y2=poc_price, xloc=xloc.bar_index, extend=extend.right, color=color.new(ns_warn, 0), width=2)
        line vah_line = line.new(x1=bar_index + profile_offset, y1=vah_price, x2=bar_index + profile_offset + profile_width, y2=vah_price, xloc=xloc.bar_index, extend=extend.right, color=color.new(accent_color, 20), width=1)
        line val_line = line.new(x1=bar_index + profile_offset, y1=val_price, x2=bar_index + profile_offset + profile_width, y2=val_price, xloc=xloc.bar_index, extend=extend.right, color=color.new(accent_color, 20), width=1)
        array.push(guide_lines, poc_line)
        array.push(guide_lines, vah_line)
        array.push(guide_lines, val_line)

        if highlight_poc
            box poc_box = box.new(left=bar_index + profile_offset, top=poc_price + profile_step * 0.5, right=bar_index + profile_offset + profile_width, bottom=poc_price - profile_step * 0.5, xloc=xloc.bar_index, bgcolor=color.new(ns_warn, 88), border_color=color.new(ns_warn, 25))
            array.push(overlay_boxes, poc_box)

        if show_profile_labels
            int label_x = bar_index + profile_offset + profile_width + 1
            label poc_label = label.new(x=label_x, y=poc_price, text="POC " + f_level_text(poc_price), xloc=xloc.bar_index, style=label.style_label_left, textcolor=ns_text, color=color.new(ns_bg_soft, 75), size=f_profile_label_size(label_scale))
            label vah_label = label.new(x=label_x, y=vah_price, text="VAH " + f_level_text(vah_price), xloc=xloc.bar_index, style=label.style_label_left, textcolor=ns_text, color=color.new(ns_bg_soft, 80), size=f_profile_label_size(label_scale))
            label val_label = label.new(x=label_x, y=val_price, text="VAL " + f_level_text(val_price), xloc=xloc.bar_index, style=label.style_label_left, textcolor=ns_text, color=color.new(ns_bg_soft, 80), size=f_profile_label_size(label_scale))
            array.push(info_labels, poc_label)
            array.push(info_labels, vah_label)
            array.push(info_labels, val_label)

        if show_node_summary
            int node_label_x = bar_index + profile_offset + profile_width + 1
            string node_text = "Nodes " + str.tostring(profile_rows) + " / " + str.tostring(eligible_bars)
            node_text := node_text + "\nVA " + str.tostring(math.round(acceptance_metric * 100.0)) + "%"
            node_text := node_text + "\nBias " + str.tostring(math.round(delta_bias * 100.0)) + "%"
            node_text := node_text + "\nLoc " + str.tostring(math.round(location_now * 100.0)) + "%"
            label node_label = label.new(x=node_label_x, y=anchor_high, text=node_text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=ns_text, color=color.new(ns_panel, 76), size=size.small)
            array.push(info_labels, node_label)

    // =============================================================================
    // DASHBOARD
    // Medium top-right panel with live auction metrics.
    // =============================================================================
    if show_dashboard
        color dash_fill = color.new(ns_panel, 10)
        color dash_header = color.new(ns_border, 0)
        color metric_bias = f_metric_color(delta_bias, 0.10)
        color metric_vwap = na(vwap_dist) ? neutral_color : f_metric_color(-vwap_dist, 0.05)
        color metric_location = na(location_now) ? neutral_color : location_now > 0.66 ? bull_color : location_now < 0.33 ? bear_color : neutral_color
        color metric_value = value_area_ratio >= 0.70 ? bull_color : value_area_ratio >= 0.55 ? neutral_color : bear_color
        color metric_balance = balance_metric >= 1.5 ? bull_color : balance_metric <= 0.7 ? bear_color : neutral_color

        table.cell(northsea_dash, 0, 0, "Auction Context", text_color=ns_text, bgcolor=dash_header, text_size=size.normal)
        table.cell(northsea_dash, 1, 0, f_format_session_mode(anchor_mode, use_rolling_window), text_color=ns_dim, bgcolor=dash_header, text_size=size.normal)

        table.cell(northsea_dash, 0, 1, "Anchor Bars", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 1, str.tostring(eligible_bars), text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)

        table.cell(northsea_dash, 0, 2, "Range", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 2, na(range_size) ? "na" : str.tostring(range_size, format.mintick), text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)

        table.cell(northsea_dash, 0, 3, "POC / VWAP", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 3, f_level_text(poc_price) + " / " + (na(anchor_vwap) ? "na" : f_level_text(anchor_vwap)), text_color=metric_vwap, bgcolor=dash_fill, text_size=size.normal)

        table.cell(northsea_dash, 0, 4, "Value Area", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 4, f_level_text(val_price) + " - " + f_level_text(vah_price), text_color=metric_value, bgcolor=dash_fill, text_size=size.normal)

        table.cell(northsea_dash, 0, 5, "Delta Bias", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 5, str.tostring(math.round(delta_bias * 100.0)) + "%", text_color=metric_bias, bgcolor=dash_fill, text_size=size.normal)

        table.cell(northsea_dash, 0, 6, "Location", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 6, na(location_now) ? "na" : str.tostring(math.round(location_now * 100.0)) + "%", text_color=metric_location, bgcolor=dash_fill, text_size=size.normal)

        table.cell(northsea_dash, 0, 7, "Balance / VA", text_color=ns_text, bgcolor=dash_fill, text_size=size.normal)
        table.cell(northsea_dash, 1, 7, str.tostring(balance_metric, "#.##") + " / " + str.tostring(math.round(value_area_ratio * 100.0)) + "%", text_color=metric_balance, bgcolor=dash_fill, text_size=size.normal)

// =============================================================================
// SAFE PLACEHOLDER PLOTS
// The overlay is driven by lines and boxes; plots are intentionally minimal.
// =============================================================================
plot(na, title="Northsea Placeholder", display=display.none)
````
