<!-- tradingview-pine-id: PUB;4b3f7f0c6f1c409587e4498c179c422c -->
<!-- tradingviewscripts-format: 1 -->
# Navyraid FVA

Source: https://www.tradingview.com/script/0HIeZkad-Navyraid-FVA/

## Description

Navyraid FVA (Fair Value Area)

Description:

Overview
The Navyraid Fair Value Area (FVA) is a specialized analytical tool built upon the principles of Auction Market Theory (AMT). According to AMT, financial markets exist to facilitate trade, constantly moving between states of balance and imbalance. The market tends to travel from one established Value Area to another.

This indicator maps out these crucial areas by analyzing where the market spends the most time and how frequently specific price levels are visited throughout the trading day. By identifying these zones of high historical acceptance, the indicator projects key levels from previous sessions that act as strong magnets and significant support/resistance zones for current and future market action.

How It Works (Core Logic)
The indicator evaluates price action by breaking down the high-to-low range of each candle into specific discrete price bins (ticks). It then tallies how often the price trades through each bin over a defined period (daily basis).

[*] Value Area Calculation: It accumulates these price interactions to find the area where a specified percentage of trading activity occurred (default is 68%, representing one standard deviation of the mean).
[*] Key Level Extraction: It isolates the single price levels with the highest concentration of activity for both the Mayor and Minor FVA.

Main Features

[*] Mayor FVA: This represents the Point of Control (POC) or the price level with the highest time accumulation strictly within the 68% Value Area. This zone acts as the primary focal point of market balance and a high-probability price magnet.
[*] Minor FVA: This marks the most significant high-time node located strictly outside the established Value Area. These peripheral nodes frequently serve as crucial turning points, rejection zones, or targets when the market breaks out of its primary balance.
[*] Smart Mitigation (Freeze Logic): To keep the chart clean and relevant, FVA zones are projected forward as boxes. By default, once the current price touches or "mitigates" an extended box, the box stops extending (freezes).
[*] Force Extend: A toggle that overrides the mitigation logic, forcing the FVA boxes to continuously project forward regardless of price interaction, useful for long-term level tracking.
[*] Auto Tick Size: The script automatically scales the bin sizes based on the asset's specific price range and minimum tick, making it universally applicable across Forex, Indices, Crypto, and Equities without manual adjustment.

How to Use in Trading
Traders can utilize the Navyraid FVA to understand the broader market context based on AMT.

[*] Targets: If the price is moving directionally, previous Mayor FVAs serve as logical take-profit zones, as the market seeks historical balance.
[*] Reactions: Minor FVAs can be observed for potential pullbacks or continuation setups when the market tests extreme areas outside of the previous day's accepted value.

Disclaimer: This indicator is designed for educational and analytical purposes to visualize Auction Market Theory concepts. It does not constitute financial advice.

---

## Source Code

````pine
//@version=6
indicator("Navyraid FVA", overlay=true, max_boxes_count=500)

// --- TOGGLES & INPUTS ---
show_fva_in = input.bool(true, title="Show Mayor FVA", group="Toggles")
show_fva_out = input.bool(true, title="Show Minor FVA", group="Toggles")
va_pct = input.float(68.0, title="Value Area (%)", minval=1, maxval=100, group="Toggles") / 100.0

// --- TIMEFRAME BASE FVA ---
base_tf = input.timeframe("30", title="Base Timeframe FVA", group="Timeframe Settings")

// --- CUSTOM COLORS ---
fva_in_color = input.color(color.new(#673ab7, 80), title="Mayor FVA Color", group="Colors")
fva_out_color = input.color(color.new(#f23645, 80), title="Minor FVA Color", group="Colors")

// Opsi Input Umum
history_limit = input.int(30, title="History (Daily)", minval=1, maxval=500)
extend_box = input.bool(true, title="Extend Box?")
force_extend = input.bool(false, title="Force Extend (Ignore Freeze)", group="Toggles") 

// --- FITUR TICK SIZE ---
tick_mode = input.string("Auto", title="Tick Size Mode", options=["Auto", "Manual"], group="Tick Settings")
manual_tick = input.float(20.0, title="Manual Tick Size", group="Tick Settings")

// Perhitungan Mayor FVA & Minor FVA (OPTIMIZED)
f_get_fva() =>
    var float[] p_levels = array.new_float(0)
    var int[] p_counts = array.new_int(0)
    var float t_size = na
    
    if ta.change(time("D")) != 0 or na(t_size)
        t_size := tick_mode == "Auto" ? math.max(open * 0.001, syminfo.mintick) : manual_tick
        array.clear(p_levels)
        array.clear(p_counts)
        
    float bar_low = math.round(low / t_size) * t_size
    float bar_high = math.round(high / t_size) * t_size
    
    if t_size > 0
        int steps = math.max(0, math.round((bar_high - bar_low) / t_size))
        for j = 0 to steps
            // OPTIMASI 1: Hilangkan pembulatan (math.round) berulang karena bar_low sudah bersih
            float curr_p = bar_low + (j * t_size) 
            int idx = array.indexof(p_levels, curr_p)
            if idx == -1
                array.push(p_levels, curr_p)
                array.push(p_counts, 1)
            else
                array.set(p_counts, idx, array.get(p_counts, idx) + 1)
            
    int max_c = -1
    int total_c = 0
    float curr_fva_in = na
    float curr_fva_out = na

    if array.size(p_counts) > 0
        for i = 0 to array.size(p_counts) - 1
            int c = array.get(p_counts, i)
            total_c += c
            if c > max_c
                max_c := c
                curr_fva_in := array.get(p_levels, i)

        float[] sorted_p = array.copy(p_levels)
        array.sort(sorted_p)
        
        // OPTIMASI 2: Buat array frekuensi statis agar tidak repot array.indexof di dalam while loop (jauh lebih cepat)
        int[] sorted_c = array.new_int(array.size(sorted_p))
        for k = 0 to array.size(sorted_p) - 1
            array.set(sorted_c, k, array.get(p_counts, array.indexof(p_levels, array.get(sorted_p, k))))
        
        // Value Area Logic
        int poc_s_idx = array.indexof(sorted_p, curr_fva_in)
        int up_s_idx = poc_s_idx + 1
        int dn_s_idx = poc_s_idx - 1
        float va_target = total_c * va_pct
        int va_count = max_c
        
        while va_count < va_target and (up_s_idx < array.size(sorted_p) or dn_s_idx >= 0)
            int c_up = up_s_idx < array.size(sorted_p) ? array.get(sorted_c, up_s_idx) : -1
            int c_dn = dn_s_idx >= 0 ? array.get(sorted_c, dn_s_idx) : -1
            
            if c_up >= c_dn and c_up != -1
                va_count += c_up
                up_s_idx += 1
            else if c_dn != -1
                va_count += c_dn
                dn_s_idx -= 1
                
        float va_high = array.get(sorted_p, math.max(0, math.min(up_s_idx - 1, array.size(sorted_p) - 1)))
        float va_low = array.get(sorted_p, math.max(0, math.min(dn_s_idx + 1, array.size(sorted_p) - 1)))
        
        // Minor FVA Logic (FVA Out)
        int max_out_c = -1
        float dist_to_poc = 999999.0 
        for i = 0 to array.size(p_levels) - 1
            float price = array.get(p_levels, i)
            int count = array.get(p_counts, i)
            if price > va_high or price < va_low
                if count > max_out_c
                    max_out_c := count
                    curr_fva_out := price
                    dist_to_poc := math.abs(price - curr_fva_in)
                else if count == max_out_c
                    float current_dist = math.abs(price - curr_fva_in) // Cegah kalkulasi ulang math.abs
                    if current_dist < dist_to_poc
                        curr_fva_out := price
                        dist_to_poc := current_dist

    [curr_fva_in, curr_fva_out, t_size]

// Request data FVA Daily
[fva_in, fva_out, t_size_d] = request.security(syminfo.tickerid, base_tf, f_get_fva())

// Box Arrays
var box[] in_boxes = array.new_box()
var box[] active_in_boxes = array.new_box()

var box[] out_boxes = array.new_box()
var box[] active_out_boxes = array.new_box()

var int start_bar = bar_index
var box rt_in_box = na
var box rt_out_box = na

new_day = ta.change(time("D")) != 0
color inv_border = color.new(color.white, 100) // Invisible border

// --- DRAW DAILY FVA ---
if new_day
    int init_r = extend_box ? bar_index + 10 : bar_index
    // OPTIMASI 3: Caching t_size dibagi 2
    float half_t_prev = na(t_size_d[1]) ? 0.0 : t_size_d[1] / 2
    
    if show_fva_in and not na(fva_in[1])
        new_in = box.new(left=start_bar, top=fva_in[1] + half_t_prev, right=init_r, bottom=fva_in[1] - half_t_prev, border_color=inv_border, bgcolor=fva_in_color, extend=extend.none)
        array.push(in_boxes, new_in)
        if extend_box
            array.push(active_in_boxes, new_in)
        if array.size(in_boxes) > history_limit
            b_del = array.shift(in_boxes)
            idx = array.indexof(active_in_boxes, b_del)
            if idx != -1
                array.remove(active_in_boxes, idx)
            box.delete(b_del)
            
    if show_fva_out and not na(fva_out[1])
        new_out = box.new(left=start_bar, top=fva_out[1] + half_t_prev, right=init_r, bottom=fva_out[1] - half_t_prev, border_color=inv_border, bgcolor=fva_out_color, extend=extend.none)
        array.push(out_boxes, new_out)
        if extend_box
            array.push(active_out_boxes, new_out)
        if array.size(out_boxes) > history_limit
            b_del = array.shift(out_boxes)
            idx = array.indexof(active_out_boxes, b_del)
            if idx != -1
                array.remove(active_out_boxes, idx)
            box.delete(b_del)
            
    start_bar := bar_index

// --- BREAK LOGIC (+10 BAR EXTENSION & FREEZE) ---
if extend_box
    if show_fva_in and array.size(active_in_boxes) > 0
        for i = array.size(active_in_boxes) - 1 to 0
            b = array.get(active_in_boxes, i)
            if not force_extend and high >= box.get_bottom(b) and low <= box.get_top(b)
                box.set_right(b, bar_index) 
                array.remove(active_in_boxes, i)
            else
                box.set_right(b, bar_index + 10) 

    if show_fva_out and array.size(active_out_boxes) > 0
        for i = array.size(active_out_boxes) - 1 to 0
            b = array.get(active_out_boxes, i)
            if not force_extend and high >= box.get_bottom(b) and low <= box.get_top(b)
                box.set_right(b, bar_index) 
                array.remove(active_out_boxes, i)
            else
                box.set_right(b, bar_index + 10) 

// --- REALTIME UPDATE (HEAVILY OPTIMIZED) ---
if barstate.islast
    int rt_r = extend_box ? bar_index + 10 : bar_index
    float half_t = na(t_size_d) ? 0.0 : t_size_d / 2

    if show_fva_in and not na(fva_in)
        float top_in = fva_in + half_t
        float bot_in = fva_in - half_t
        if na(rt_in_box)
            rt_in_box := box.new(left=start_bar, top=top_in, right=rt_r, bottom=bot_in, border_color=inv_border, bgcolor=fva_in_color, extend=extend.none)
        else
            // OPTIMASI 4: Update koordinat ketimbang Delete dan Create ulang terus-menerus
            box.set_left(rt_in_box, start_bar)
            box.set_top(rt_in_box, top_in)
            box.set_bottom(rt_in_box, bot_in)
            box.set_right(rt_in_box, rt_r)
        
    if show_fva_out and not na(fva_out)
        float top_out = fva_out + half_t
        float bot_out = fva_out - half_t
        if na(rt_out_box)
            rt_out_box := box.new(left=start_bar, top=top_out, right=rt_r, bottom=bot_out, border_color=inv_border, bgcolor=fva_out_color, extend=extend.none)
        else
            box.set_left(rt_out_box, start_bar)
            box.set_top(rt_out_box, top_out)
            box.set_bottom(rt_out_box, bot_out)
            box.set_right(rt_out_box, rt_r)
````
