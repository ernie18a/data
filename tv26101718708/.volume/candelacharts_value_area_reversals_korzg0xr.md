# CandelaCharts - Value Area Reversals

- url: https://www.tradingview.com/script/korzg0xR-CandelaCharts-Value-Area-Reversals/
- type: indicator
- pine_id: PUB;d50a8db5837a48e9b41dab1783a67e81
- version: 2.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - Value Area Reversals[/b] indicator is a powerful tool designed to identify high-probability institutional reversals around key volume nodes. By generating a rolling session Volume Profile and tracking the Value Area High (VAH) and Value Area Low (VAL), this script highlights moments where price aggressively rejects the boundaries of fair value with anomalous volume.

https://www.tradingview.com/x/Hlv9Auxu/

This tool introduces [b]Dynamic CISD (Change In State of Delivery)[/b] tracking, automatically anchoring to the true swing point of a reversal and projecting institutional support/resistance levels until formally confirmed by price action.

📦 [b]Features[/b]
[list]
[*] [b]Session Volume Profiles[/b]: Highly customizable rolling profiles. Choose between classic stepped Histograms or a beautifully smoothed Curved aesthetic that accurately maps volume distribution.
[*] [b]Value Area Reversals[/b]: Automatically detects when price dips outside of the established Value Area (VA) and aggressively reclaims it. Signals are filtered by volume—only firing when the reversal candle exceeds the volume of the last N similar-type candles.
[*] [b]Dynamic CISD Tracking[/b]: When a reversal signal fires, the script actively tracks price to find the absolute lowest/highest swing point of the manipulation leg. It then maps the body of that swing as a Change in State of Delivery (CISD) level, drawing a projection line until price formally breaks and confirms the shift in delivery.
[*] [b]Volume Spike Candles[/b]: Optionally colors individual candles on the chart that exhibit significant volume spikes relative to their recent peers, providing immediate visual context for momentum shifts.
[/list]

⚙️ [b]Settings[/b]
[list]
[*] [b]Volume Profile[/b]: Configure the timeframe used to define a session (e.g., Daily), the number of horizontal bins, the Value Area percentage (default 70%), and the aesthetic style (Curved vs Histogram).
[*] [b]Change In State Of Delivery[/b]: Toggle the CISD tracking system, customize the line style and colors for bullish and bearish CISD projections.
[*] [b]Signals[/b]: Enable or disable the VA Reclaim signals, and adjust the lookback window used to qualify a volume spike.
[*] [b]Style[/b]: Full color control over up/down volume nodes, VAH/VAL/POC levels, and signal markers.
[/list]

⚡️ [b]Showcase[/b]

[i]Volume Profile - Curved Style[/i]
https://www.tradingview.com/x/d7Bb8Ymw/

[i]Volume Profile - Histogram Style[/i]
https://www.tradingview.com/x/GAcgVrbi/

[i]CISD[/i]
https://www.tradingview.com/x/alM9AWRq/

🚨 [b]Alerts[/b]

The indicator includes native, ready-to-use alert conditions for:
[list]
[*] [b]Bullish / Bearish VA Reclaims[/b]: Fires the moment a volume-backed reversal back into the Value Area is detected.
[*] [b]Bullish / Bearish CISD Confirmation[/b]: Fires the exact moment price action structurally confirms the swing by breaking the dynamic CISD level.
[/list]

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - Value Area Reversals", shorttitle = "CandelaCharts - Value Area Reversals", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000, max_polylines_count = 100)




 


 


 

// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_white                        = color.white
colors_black                        = color.black
colors_green                        = color.green
colors_orange                       = color.orange
colors_blue                         = color.blue
colors_aqua                         = color.aqua
colors_fuchsia                      = color.fuchsia
colors_lime                         = color.lime
colors_maroon                       = color.maroon
colors_navy                         = color.navy
colors_olive                        = color.olive
colors_purple                       = color.purple
colors_teal                         = color.teal
colors_yellow                       = color.yellow
colors_red                          = color.red
colors_gray                         = color.gray
colors_silver                       = color.silver
colors_transparent                  = color.new(color.white, 100)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                        = input.string("Monospace", "Text                  ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Font family and text size for all on-chart labels.")
general_brand_show                  = input.bool(false, "Hide brand", group = "General")

prof_tf                             = input.timeframe("D", "Timeframe       ", group = "Volume Profile", tooltip = "Higher timeframe used to determine when a new profile session begins.")
prof_rows                           = input.int(50, "Rows             ", minval = 10, maxval = 200, group = "Volume Profile", tooltip = "Number of horizontal bins in the volume profile histogram.")
prof_va_pct                         = input.int(70, "Value area    ", minval = 50, maxval = 95, group = "Volume Profile", tooltip = "Percentage of total volume included within the Value Area.")
prof_max_width                      = input.int(30, "Max width       ", minval = 5, maxval = 100, group = "Volume Profile", tooltip = "Maximum horizontal extent of the profile in bars.")
prof_insig_pct                      = input.int(10, "Threshold       ", minval = 0, maxval = 50, group = "Volume Profile", tooltip = "Volume level (%) below which profile rows are considered insignificant.")
prof_style                          = input.string("Histogram", "Style            ", options = ["Curved", "Histogram"], group = "Volume Profile", tooltip = "Curved draws a smooth outline, Histogram draws stepped volume bars.")
prof_hist                           = input.int(1, "History           ", minval = 1, maxval = 10, group = "Volume Profile", tooltip = "Number of historical profiles to display (including the current period).")

style_cisd_show                     = input.bool(true, "CISD          ", inline = "8.0", group = "Change In State Of Delivery", tooltip = "Detect and display Change in State of Delivery (CISD) lines.")
style_cisd_style                    = input.string('⎯⎯⎯', "", options = ['⎯⎯⎯', '----', '····'], inline = "8.0", group = "Change In State Of Delivery")
style_cisd_bull_color               = input.color(color.teal, "", inline = "8.0", group = "Change In State Of Delivery")
style_cisd_bear_color               = input.color(color.orange, "", inline = "8.0", group = "Change In State Of Delivery")

sig_show_signals                    = input.bool(true, "Lookback   ", inline = "3.0", group = "Signals", tooltip = "Enable or disable Value Area rejection signals.")
sig_sibling_count                   = input.int(20, "", minval = 1, maxval = 60, inline = "3.0", group = "Signals", tooltip = "Number of previous candles whose volume must be exceeded for a signal to fire.")
sig_algo                            = input.string("Algorithm 1 (Same Type)", "Algorithm ", options = ["Algorithm 1 (Same Type)", "Algorithm 2 (All Types)"], group = "Signals", tooltip = "Algorithm 1 compares volume to the last N candles of the same type. Algorithm 2 compares volume to the last N candles regardless of type.")
sig_bias                            = input.string("Neutral", "Bias              ", options = ["Bullish", "Bearish", "Neutral"], group = "Signals", tooltip = "Filter signals by bias. Neutral shows all signals.")

style_vah_css                       = input.color(#787b86, "Levels               ", inline = "4.0", group = "Style", tooltip = "Colors for VAH, VAL, and POC horizontal levels.")
style_val_css                       = input.color(#787b86, "VAL", inline = "4.0", group = "Style")
style_poc_css                       = input.color(color.black, "POC", inline = "4.0", group = "Style")
style_up_vol_css                    = input.color(color.teal, "Volume             ", inline = "5.0", group = "Style", tooltip = "Fill colors for up-volume and down-volume profile areas.")
style_dn_vol_css                    = input.color(color.orange, "Down", inline = "5.0", group = "Style")
style_bull_signal_css               = input.color(color.teal, "Signal               ", inline = "6.0", group = "Style", tooltip = "Colors for bullish and bearish reclaim signal markers.")
style_bear_signal_css               = input.color(color.orange, "Bearish", inline = "6.0", group = "Style")
style_va_style                      = input.string('⎯⎯⎯', "VAH/L Line ", options = ['⎯⎯⎯', '----', '····'], group = "Style")
style_color_candles                 = input.bool(true, "Color Candles", group = "Style", tooltip = "Color candles that have higher volume than their recent same-type siblings.")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type ColoredCandle
    int b_idx
    int t
    int t_step
    float o
    float h
    float l
    float c
    color col

type SessionProfile
    int     start_idx
    int     end_idx
    float   high_p
    float   low_p
    array<float>  bar_h
    array<float>  bar_l
    array<float>  bar_c
    array<float>  bar_v
    array<bool>   bar_b

type SignalMarker
    int     b_idx          // bar_index where signal fired
    bool    bull           // true = bullish reclaim, false = bearish reclaim
    float   price_h        // high of signal bar
    float   price_l        // low of signal bar

type CISDTracker
    int     b_idx
    int     start_t
    float   level
    bool    bull
    bool    confirmed
    int     conf_t
    bool    locked

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Functions   |
// # ========================================================================= #

//#region

method text_size(string size) =>
    out = switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
    out

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

method set_opacity(color css, int opacity) =>
    blue  = color.b(css)
    red   = color.r(css)
    green = color.g(css)
    color.rgb(red, green, blue, opacity)

// Compute anchored volume profile bins, POC, VAH, VAL from bar data arrays
// Returns [poc_price, vah_price, val_price, buy_bins, sell_bins, total_bins, max_bin_vol, poc_bin, va_high_bin, va_low_bin, p_high, p_low, p_step]
method compute_profile(SessionProfile p, int rows, int va_pct) =>
    float p_high = p.high_p
    float p_low  = p.low_p
    float p_step = (p_high - p_low) / rows

    float out_poc  = na
    float out_vah  = na
    float out_val  = na
    int   out_poc_bin     = 0
    int   out_va_high_bin = 0
    int   out_va_low_bin  = 0
    float out_max_bin_vol = 0.0

    array<float> buy_bins   = array.new<float>(rows, 0.0)
    array<float> sell_bins  = array.new<float>(rows, 0.0)
    array<float> total_bins = array.new<float>(rows, 0.0)

    if p_step > 0 and p.bar_v.size() > 0
        float total_vol = 0.0

        for i = 0 to p.bar_v.size() - 1
            float bh = p.bar_h.get(i)
            float bl = p.bar_l.get(i)
            float bc = p.bar_c.get(i)
            float bv = p.bar_v.get(i)
            bool  bb = p.bar_b.get(i)

            float bar_range = bh - bl
            if bar_range == 0
                int bin_idx = math.floor((bc - p_low) / p_step)
                bin_idx := math.max(0, math.min(rows - 1, bin_idx))
                if bb
                    buy_bins.set(bin_idx, buy_bins.get(bin_idx) + bv)
                else
                    sell_bins.set(bin_idx, sell_bins.get(bin_idx) + bv)
                total_bins.set(bin_idx, total_bins.get(bin_idx) + bv)
                total_vol += bv
            else
                for j = 0 to rows - 1
                    float bin_low  = p_low + j * p_step
                    float bin_high = bin_low + p_step
                    float overlap_low  = math.max(bl, bin_low)
                    float overlap_high = math.min(bh, bin_high)
                    float overlap = math.max(0.0, overlap_high - overlap_low)

                    if overlap > 0
                        float vol_fraction = bv * (overlap / bar_range)
                        if bb
                            buy_bins.set(j, buy_bins.get(j) + vol_fraction)
                        else
                            sell_bins.set(j, sell_bins.get(j) + vol_fraction)
                        total_bins.set(j, total_bins.get(j) + vol_fraction)
                        total_vol += vol_fraction

        // Find POC bin
        int poc_bin = 0
        float max_bin_vol = 0.0
        for j = 0 to rows - 1
            float v = total_bins.get(j)
            if v > max_bin_vol
                max_bin_vol := v
                poc_bin := j

        // Expand VA from POC
        float va_target_vol = total_vol * (va_pct / 100.0)
        float current_va_vol = total_bins.get(poc_bin)
        int va_high_bin = poc_bin
        int va_low_bin  = poc_bin

        while current_va_vol < va_target_vol and (va_high_bin < rows - 1 or va_low_bin > 0)
            float upper_vol = va_high_bin < rows - 1 ? total_bins.get(va_high_bin + 1) : -1.0
            float lower_vol = va_low_bin > 0 ? total_bins.get(va_low_bin - 1) : -1.0

            if upper_vol >= lower_vol and upper_vol >= 0
                va_high_bin += 1
                current_va_vol += upper_vol
            else if lower_vol >= 0
                va_low_bin -= 1
                current_va_vol += lower_vol
            else
                break

        out_poc  := p_low + poc_bin * p_step + p_step / 2
        out_vah  := p_low + va_high_bin * p_step + p_step
        out_val  := p_low + va_low_bin * p_step
        out_poc_bin     := poc_bin
        out_va_high_bin := va_high_bin
        out_va_low_bin  := va_low_bin
        out_max_bin_vol := max_bin_vol

    [out_poc, out_vah, out_val, buy_bins, sell_bins, total_bins, out_max_bin_vol, out_poc_bin, out_va_high_bin, out_va_low_bin, p_high, p_low, p_step]

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

var colored_candles = array.new<ColoredCandle>()
var draw_polys    = array.new<polyline>()
var draw_lines    = array.new<line>()
var draw_boxes    = array.new<box>()
var draw_labels   = array.new<label>()
var sig_labels    = array.new<label>()

var array<SignalMarker> signal_markers = array.new<SignalMarker>()
var array<SessionProfile> stored_profiles = array.new<SessionProfile>()
var SessionProfile current_profile = na

// Previous session profile levels (finalized)
var float prev_vah = na
var float prev_val = na
var float prev_poc = na

var array<CISDTracker> cisd_trackers = array.new<CISDTracker>()

find_cisd_data(bool look_for_bullish, int start_idx) =>
    int streak_start = start_idx
    for i = start_idx to start_idx + 20
        bool is_bull_candle = close[i] > open[i]
        if is_bull_candle == look_for_bullish
            streak_start := i
            break
            
    int idx = streak_start
    for i = streak_start to streak_start + 20
        bool is_bull_candle = close[i] > open[i]
        if is_bull_candle != look_for_bullish
            break
        idx := i
        
    [open[idx], close[idx], high[idx], low[idx], look_for_bullish, time[idx]]

get_line_style(string str) =>
    str == '----' ? line.style_dashed : str == '····' ? line.style_dotted : line.style_solid

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Profile Engine   |
// # ========================================================================= #

//#region

// Detect new session
bool is_new_session = ta.change(time(prof_tf)) != 0

// Manage session profiles
if is_new_session or na(current_profile)
    if not na(current_profile)
        current_profile.end_idx := bar_index - 1

        // Compute and cache previous session's finalized levels
        [f_poc, f_vah, f_val, _b1, _s1, _t1, _m1, _p1, _vh1, _vl1, _ph1, _pl1, _ps1] = current_profile.compute_profile(prof_rows, prof_va_pct)
        prev_poc := f_poc
        prev_vah := f_vah
        prev_val := f_val

        // Store for rendering
        int max_prev = math.max(0, prof_hist - 1)
        while stored_profiles.size() > 0 and stored_profiles.size() >= max_prev
            stored_profiles.shift()
        if max_prev > 0
            stored_profiles.push(current_profile)

    current_profile := SessionProfile.new(bar_index, bar_index, high, low, array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<bool>())

    // Trim signal markers dynamically to prevent memory overflow
    int min_start = na
    if stored_profiles.size() > 0
        min_start := stored_profiles.get(0).start_idx
    else if not na(current_profile)
        min_start := current_profile.start_idx
        
    if not na(min_start)
        while signal_markers.size() > 0 and signal_markers.get(0).b_idx < min_start
            signal_markers.shift()
        while cisd_trackers.size() > 0 and cisd_trackers.get(0).b_idx < min_start
            cisd_trackers.shift()

if not na(current_profile)
    current_profile.high_p  := math.max(current_profile.high_p, high)
    current_profile.low_p   := math.min(current_profile.low_p, low)
    current_profile.end_idx := bar_index

    current_profile.bar_h.push(high)
    current_profile.bar_l.push(low)
    current_profile.bar_c.push(close)
    current_profile.bar_v.push(volume)
    current_profile.bar_b.push(close >= open)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Signal Engine   |
// # ========================================================================= #

//#region

// Bar-by-bar VA computation for signal detection
float curr_vah = na
float curr_val = na
float curr_poc = na

if not na(current_profile) and current_profile.bar_v.size() >= 2
    [s_poc, s_vah, s_val, _b2, _s2, _t2, _m2, _p2, _vh2, _vl2, _ph2, _pl2, _ps2] = current_profile.compute_profile(prof_rows, prof_va_pct)
    curr_vah := s_vah
    curr_val := s_val
    curr_poc := s_poc

// Determine which VA levels to use for signals
// Previous day signals use stored previous session's finalized VA

// Volume sibling tracking arrays
var array<float> bull_vols = array.new<float>()
var array<float> bear_vols = array.new<float>()

// Check if volume exceeds the last N entries in a sibling array
f_vol_above_siblings(array<float> sibling_vols, float vol, int count) =>
    if sibling_vols.size() < count
        false
    else
        bool result = true
        for i = 0 to count - 1
            if vol <= sibling_vols.get(sibling_vols.size() - 1 - i)
                result := false
                break
        result

bool bull_reclaim_signal = false
bool bear_reclaim_signal = false

// Compute volume spikes for both signal and coloring logic
bool is_bullish      = close > open
bool is_bearish      = close < open

bool algo1_bull_vol_spike = f_vol_above_siblings(bull_vols, volume, sig_sibling_count)
bool algo1_bear_vol_spike = f_vol_above_siblings(bear_vols, volume, sig_sibling_count)

bool algo2_vol_spike = true
for i = 1 to sig_sibling_count
    if volume <= nz(volume[i])
        algo2_vol_spike := false
        break

bool bull_vol_spike  = sig_algo == "Algorithm 1 (Same Type)" ? algo1_bull_vol_spike : algo2_vol_spike
bool bear_vol_spike  = sig_algo == "Algorithm 1 (Same Type)" ? algo1_bear_vol_spike : algo2_vol_spike

if sig_show_signals and not na(prev_vah) and not na(prev_val) and barstate.isconfirmed
    // Bearish rejection from VAH: candle reached VAH, closed bearish, volume stands out
    bool touched_vah     = high >= prev_vah
    if touched_vah and is_bearish and bear_vol_spike and (sig_bias == "Bearish" or sig_bias == "Neutral")
        bear_reclaim_signal := true
        signal_markers.push(SignalMarker.new(bar_index, false, high, low))
        if style_cisd_show
            cisd_trackers.push(CISDTracker.new(bar_index, na, na, false, false, na, false))

    // Bullish rejection from VAL: candle reached VAL, closed bullish, volume stands out
    bool touched_val     = low <= prev_val
    if touched_val and is_bullish and bull_vol_spike and (sig_bias == "Bullish" or sig_bias == "Neutral")
        bull_reclaim_signal := true
        signal_markers.push(SignalMarker.new(bar_index, true, high, low))
        if style_cisd_show
            cisd_trackers.push(CISDTracker.new(bar_index, na, na, true, false, na, false))

// Push current bar's volume to the appropriate sibling array (after signal check)
if is_bullish
    bull_vols.push(volume)
else if is_bearish
    bear_vols.push(volume)

bool cisd_bull_alert = false
bool cisd_bear_alert = false

// Final signals (based only on previous day)
if style_cisd_show
    for tracker in cisd_trackers
        if not tracker.locked
            int look_left = bar_index - tracker.b_idx + 1
            if tracker.bull
                [o, c, h, l, bull, t] = find_cisd_data(false, look_left)
                tracker.level := o
                tracker.start_t := t
                tracker.locked := true
            else
                [o, c, h, l, bull, t] = find_cisd_data(true, look_left)
                tracker.level := o
                tracker.start_t := t
                tracker.locked := true
        else if not tracker.confirmed
            if tracker.bull and close > tracker.level
                tracker.confirmed := true
                tracker.conf_t := time
                cisd_bull_alert := true
            else if not tracker.bull and close < tracker.level
                tracker.confirmed := true
                tracker.conf_t := time
                cisd_bear_alert := true

bool final_bull_signal = bull_reclaim_signal
bool final_bear_signal = bear_reclaim_signal

// Candle Coloring based on volume spikes
if style_color_candles
    int step = time - nz(time[1], time)
    if is_bullish and bull_vol_spike
        colored_candles.push(ColoredCandle.new(bar_index, time, step, open, high, low, close, style_up_vol_css))
    else if is_bearish and bear_vol_spike
        colored_candles.push(ColoredCandle.new(bar_index, time, step, open, high, low, close, style_dn_vol_css))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Visuals   |
// # ========================================================================= #

//#region

if barstate.islast
    // Clean previous drawings
    if draw_polys.size() > 0
        for py in draw_polys
            py.delete()
    if draw_lines.size() > 0
        for ln in draw_lines
            ln.delete()
    if draw_boxes.size() > 0
        for bx in draw_boxes
            bx.delete()
    if draw_labels.size() > 0
        for lb in draw_labels
            lb.delete()
    if sig_labels.size() > 0
        for lb in sig_labels
            lb.delete()

    draw_polys.clear()
    draw_lines.clear()
    draw_boxes.clear()
    draw_labels.clear()
    sig_labels.clear()

    // Collect profiles to render
    array<SessionProfile> render_list = array.new<SessionProfile>()

    if stored_profiles.size() > 0
        for sp in stored_profiles
            render_list.push(sp)

    if not na(current_profile)
        render_list.push(current_profile)

    for p in render_list
        if p.bar_v.size() == 0
            continue

        [r_poc, r_vah, r_val, r_buy, r_sell, r_total, r_max, r_poc_bin, r_va_hi, r_va_lo, r_p_hi, r_p_lo, r_p_step] = p.compute_profile(prof_rows, prof_va_pct)

        if na(r_poc) or r_p_step == 0
            continue

        int prof_width = math.min(prof_max_width, math.max(10, int((p.end_idx - p.start_idx) / 3)))

        // Draw profile shape
        float tot_b = 0.0
        float tot_s = 0.0
        for j = 0 to prof_rows - 1
            tot_b += r_buy.get(j)
            tot_s += r_sell.get(j)
        color poly_color = tot_b > tot_s ? style_up_vol_css : style_dn_vol_css

        if prof_style == "Curved"
            // Full profile
            array<chart.point> cp_full_fill = array.new<chart.point>()
            array<chart.point> cp_full_stroke = array.new<chart.point>()
            cp_full_fill.push(chart.point.from_index(p.start_idx, r_p_lo))
            cp_full_fill.push(chart.point.from_index(p.start_idx, r_p_lo))
            cp_full_fill.push(chart.point.from_index(p.start_idx, r_p_lo))
            for j = 0 to prof_rows - 1
                float t_vol = r_total.get(j)
                float mid = r_p_lo + j * r_p_step + r_p_step / 2
                int value = 0
                if r_max > 0 and t_vol > 0
                    value := math.max(1, math.round((t_vol / r_max) * prof_width))
                chart.point pt = chart.point.from_index(p.start_idx + value, mid)
                cp_full_fill.push(pt)
                cp_full_stroke.push(pt)
            cp_full_fill.push(chart.point.from_index(p.start_idx, r_p_hi))
            cp_full_fill.push(chart.point.from_index(p.start_idx, r_p_hi))
            cp_full_fill.push(chart.point.from_index(p.start_idx, r_p_hi))
            for j = prof_rows - 1 to 0
                float mid = r_p_lo + j * r_p_step + r_p_step / 2
                cp_full_fill.push(chart.point.from_index(p.start_idx, mid))
                
            draw_polys.push(polyline.new(cp_full_fill, curved = true, closed = true, line_color = na, fill_color = color.new(poly_color, 90)))
            draw_polys.push(polyline.new(cp_full_stroke, curved = true, closed = false, line_color = color.new(poly_color, 70), fill_color = na))

            // VA overlay
            array<chart.point> cp_va_fill = array.new<chart.point>()
            array<chart.point> cp_va_stroke = array.new<chart.point>()
            float va_bot = r_p_lo + r_va_lo * r_p_step
            float va_top = r_p_lo + (r_va_hi + 1) * r_p_step
            cp_va_fill.push(chart.point.from_index(p.start_idx, va_bot))
            cp_va_fill.push(chart.point.from_index(p.start_idx, va_bot))
            cp_va_fill.push(chart.point.from_index(p.start_idx, va_bot))
            for j = r_va_lo to r_va_hi
                float t_vol = r_total.get(j)
                float mid = r_p_lo + j * r_p_step + r_p_step / 2
                int value = 0
                if r_max > 0 and t_vol > 0
                    value := math.max(1, math.round((t_vol / r_max) * prof_width))
                chart.point pt = chart.point.from_index(p.start_idx + value, mid)
                cp_va_fill.push(pt)
                cp_va_stroke.push(pt)
            cp_va_fill.push(chart.point.from_index(p.start_idx, va_top))
            cp_va_fill.push(chart.point.from_index(p.start_idx, va_top))
            cp_va_fill.push(chart.point.from_index(p.start_idx, va_top))
            for j = r_va_hi to r_va_lo
                float mid = r_p_lo + j * r_p_step + r_p_step / 2
                cp_va_fill.push(chart.point.from_index(p.start_idx, mid))
                
            draw_polys.push(polyline.new(cp_va_fill, curved = true, closed = true, line_color = na, fill_color = color.new(poly_color, 70)))
            draw_polys.push(polyline.new(cp_va_stroke, curved = true, closed = false, line_color = color.new(poly_color, 30), fill_color = na))

        else
            // Full histogram (faded — outside VA appearance)
            array<chart.point> hp_full = array.new<chart.point>()
            for j = 0 to prof_rows - 1
                float t_vol = r_total.get(j)
                float bin_low  = r_p_lo + j * r_p_step
                float bin_high = bin_low + r_p_step
                int bar_w = 0
                if r_max > 0 and t_vol > 0
                    bar_w := math.max(1, math.round((t_vol / r_max) * prof_width))
                hp_full.push(chart.point.from_index(p.start_idx + bar_w, bin_low))
                hp_full.push(chart.point.from_index(p.start_idx + bar_w, bin_high))
            hp_full.push(chart.point.from_index(p.start_idx, r_p_hi))
            hp_full.push(chart.point.from_index(p.start_idx, r_p_lo))
            draw_polys.push(polyline.new(hp_full, curved = false, closed = true, line_color = color.new(poly_color, 70), fill_color = color.new(poly_color, 90)))

            // VA histogram overlay (opaque — inside VA)
            array<chart.point> hp_va = array.new<chart.point>()
            float va_bot = r_p_lo + r_va_lo * r_p_step
            float va_top = r_p_lo + (r_va_hi + 1) * r_p_step
            for j = r_va_lo to r_va_hi
                float t_vol = r_total.get(j)
                float bin_low  = r_p_lo + j * r_p_step
                float bin_high = bin_low + r_p_step
                int bar_w = 0
                if r_max > 0 and t_vol > 0
                    bar_w := math.max(1, math.round((t_vol / r_max) * prof_width))
                hp_va.push(chart.point.from_index(p.start_idx + bar_w, bin_low))
                hp_va.push(chart.point.from_index(p.start_idx + bar_w, bin_high))
            hp_va.push(chart.point.from_index(p.start_idx, va_top))
            hp_va.push(chart.point.from_index(p.start_idx, va_bot))
            draw_polys.push(polyline.new(hp_va, curved = false, closed = true, line_color = color.new(poly_color, 30), fill_color = color.new(poly_color, 70)))

        // Draw POC line
        draw_lines.push(line.new(p.start_idx, r_poc, p.end_idx, r_poc, color = style_poc_css, width = 3))

        // Draw VAH / VAL lines
        string line_style_va = get_line_style(style_va_style)
        draw_lines.push(line.new(p.start_idx, r_vah, p.end_idx, r_vah, color = style_vah_css, style = line_style_va, width = 1))
        draw_lines.push(line.new(p.start_idx, r_val, p.end_idx, r_val, color = style_val_css, style = line_style_va, width = 1))

        // Labels for levels
        draw_labels.push(label.new(p.end_idx, r_vah, text = "VAH", color = color(na), textcolor = style_vah_css, style = label.style_label_left, size = size.tiny, text_font_family = font_style(general_font)))
        draw_labels.push(label.new(p.end_idx, r_val, text = "VAL", color = color(na), textcolor = style_val_css, style = label.style_label_left, size = size.tiny, text_font_family = font_style(general_font)))
        draw_labels.push(label.new(p.end_idx, r_poc, text = "POC", color = color(na), textcolor = style_poc_css, style = label.style_label_left, size = size.tiny, text_font_family = font_style(general_font)))

    // ── Colored Candles (all enabled profiles) ───────────────────────────────── //

    if style_color_candles and colored_candles.size() > 0
        int min_start_idx = na
        if stored_profiles.size() > 0
            min_start_idx := stored_profiles.get(0).start_idx
        else if not na(current_profile)
            min_start_idx := current_profile.start_idx

        for c in colored_candles
            if na(min_start_idx) or c.b_idx >= min_start_idx
                color solid_color = color.new(c.col, 0)
                // Draw thin line for wick
                draw_lines.push(line.new(c.t, c.h, c.t, c.l, color = solid_color, width = 1, xloc = xloc.bar_time))
                // Draw box for body
                if c.o == c.c
                    draw_lines.push(line.new(c.t, c.c, c.t, c.c + syminfo.mintick, color = solid_color, width = 4, xloc = xloc.bar_time))
                else
                    int half_step = int(c.t_step * 0.35)
                    draw_boxes.push(box.new(left = c.t - half_step, top = math.max(c.o, c.c), right = c.t + half_step, bottom = math.min(c.o, c.c), border_color = solid_color, border_width = 1, bgcolor = solid_color, xloc = xloc.bar_time))

    // ── CISD Lines ───────────────────────────────────────────────────────────── //

    if style_cisd_show and cisd_trackers.size() > 0
        int min_start_idx = na
        if stored_profiles.size() > 0
            min_start_idx := stored_profiles.get(0).start_idx
        else if not na(current_profile)
            min_start_idx := current_profile.start_idx

        for tracker in cisd_trackers
            if tracker.locked and (na(min_start_idx) or tracker.b_idx >= min_start_idx)
                int end_t = tracker.confirmed ? tracker.conf_t : time
                color c_color = tracker.bull ? style_cisd_bull_color : style_cisd_bear_color
                draw_lines.push(line.new(tracker.start_t, tracker.level, end_t, tracker.level, xloc=xloc.bar_time, color=c_color, style=get_line_style(style_cisd_style), width=2))
                draw_labels.push(label.new(end_t, tracker.level, text="CISD", xloc=xloc.bar_time, color=color(na), style=label.style_label_left, textcolor=c_color, size=size.tiny))

    // ── Signal Labels (all enabled profiles) ─────────────────────────────────── //

    if sig_show_signals and signal_markers.size() > 0
        int min_start_idx = na
        if stored_profiles.size() > 0
            min_start_idx := stored_profiles.get(0).start_idx
        else if not na(current_profile)
            min_start_idx := current_profile.start_idx

        for sig in signal_markers
            if na(min_start_idx) or sig.b_idx >= min_start_idx
                if sig.bull
                    sig_labels.push(label.new(sig.b_idx, sig.price_l, text = "▲", color = color(na), textcolor = style_bull_signal_css, style = label.style_label_up, size = size.large, tooltip = "Bullish VA Reclaim"))
                else
                    sig_labels.push(label.new(sig.b_idx, sig.price_h, text = "▼", color = color(na), textcolor = style_bear_signal_css, style = label.style_label_down, size = size.large, tooltip = "Bearish VA Reclaim"))



//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Alerts   |
// # ========================================================================= #

//#region

if final_bull_signal
    alert(str.format("Bullish VA Reclaim on {0} at {1}", syminfo.ticker, str.tostring(close)), alert.freq_once_per_bar_close)

if final_bear_signal
    alert(str.format("Bearish VA Reclaim on {0} at {1}", syminfo.ticker, str.tostring(close)), alert.freq_once_per_bar_close)

if cisd_bull_alert
    alert(str.format("Bullish CISD Confirmed on {0} at {1}", syminfo.ticker, str.tostring(close)), alert.freq_once_per_bar_close)

if cisd_bear_alert
    alert(str.format("Bearish CISD Confirmed on {0} at {1}", syminfo.ticker, str.tostring(close)), alert.freq_once_per_bar_close)

alertcondition(final_bull_signal, "Bullish VA Reclaim", "Bullish Value Area Reclaim Signal")
alertcondition(final_bear_signal, "Bearish VA Reclaim", "Bearish Value Area Reclaim Signal")
alertcondition(cisd_bull_alert, "Bullish CISD", "Bullish Change in State of Delivery Confirmed")
alertcondition(cisd_bear_alert, "Bearish CISD", "Bearish Change in State of Delivery Confirmed")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Brand   |
// # ========================================================================= #

//#region

if barstate.isfirst and not general_brand_show
    var table brand = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand, 0, 0, "© CandelaCharts", text_color = color.gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
