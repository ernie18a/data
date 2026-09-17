<!-- tradingview-pine-id: PUB;3ab3dea06c49496aac39940f8b7df29c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Footprint [Auto-Scale & Filter]

Source: https://www.tradingview.com/script/FYAfeYLD/

## Description

This indicator provides a functional approximation of a Footprint Chart within TradingView by extracting lower timeframe (LTF) data and visualizing the bid/ask volume distribution directly inside the current candles.

While TradingView's Pine Script has a hard limit on the number of labels (maximum 500) that prevents a full historical footprint mapping, this script bypasses structural limitations using smart auto-scaling and historical offsetting.

Key Features:

Auto-Scaling by Asset: Uses ATR to automatically calculate the optimal price bin step. Whether you are viewing Crypto, Forex, or Indices, the script adjusts itself to maintain readable density without cluttering the screen.

Volume Filtering: Includes a minimum volume filter. Price levels with total volume below your specified threshold will not be rendered, allowing you to focus on high-liquidity nodes and true absorption.

Customizable Visuals: You can customize the buy/sell delta text colors, toggle the label backgrounds on or off, and adjust background opacity so the numbers remain clearly visible over the candles.

History Offset: Due to the 500-label limit, the script limits visibility to the most recent candles. To view the footprint of older price action, simply increase the "Bar Offset" in the settings to shift the focus window backward.

How to Use:

Apply it to your chart and set the "Lower Timeframe" in the settings. (If you are on a Premium plan, using "1S" or "5S" will provide highly granular tick-level approximations. Otherwise, "1" minute is recommended).

Adjust the "Min Volume Filter" based on the asset's average volume to clean up noise.

Toggle "Show Background" depending on your chart theme for better visibility.

Limitations:

This is not a native order flow footprint chart. It estimates bid/ask by evaluating if the LTF close was higher or lower than its open.

Cannot display footprint data for the entire chart history at once due to Pine Script’s rendering limits. Use the "Offset" feature to inspect past structure.

I built this tool to provide a practical workaround for order flow traders relying on Pine Script. Feel free to adjust the settings to fit your preferred assets and trading style.

Feel free to modify the code however you like.

---

## Source Code

````pine
//@version=6
indicator("Advanced Footprint [Auto-Scale & Filter]", overlay=true, max_labels_count=500)

// ==========================================
// 1. Main Settings
// ==========================================
grp_main = "Main Settings"
ltf = input.timeframe("1", title="Lower Timeframe", group=grp_main, tooltip="Use '1S' for 1 second (Premium only) or '1' for 1 minute.")
rows_per_candle = input.int(10, title="Avg Rows per Candle", minval=3, maxval=30, group=grp_main, tooltip="Automatically adjusts price bins to fit this many rows inside an average candle.")
min_vol_filter = input.float(30.0, title="Min Volume Filter", group=grp_main, tooltip="Hides data if the total volume (Buy+Sell) at a price level is below this value.")

// ==========================================
// 2. Style & Colors
// ==========================================
grp_style = "Style & Colors"
color_buy = input.color(color.lime, title="Buy Dominant Text Color", group=grp_style)
color_sell = input.color(color.red, title="Sell Dominant Text Color", group=grp_style)
color_neutral = input.color(color.white, title="Neutral Text Color", group=grp_style)

show_bg = input.bool(true, title="Show Background", group=grp_style)
color_bg = input.color(color.new(color.black, 40), title="Background Color", group=grp_style)

// ==========================================
// 3. History & Offset
// ==========================================
grp_hist = "History & Offset"
show_bars = input.int(20, title="Bars to Display", minval=1, maxval=50, group=grp_hist, tooltip="TradingView limits labels to 500 per chart. Keep this low.")
bar_offset = input.int(0, title="Bar Offset (Lookback)", minval=0, group=grp_hist, tooltip="Increase this to view footprint data of past candles.")

// ==========================================
// 4. Auto-Scaling & Formatting
// ==========================================
// Calculate the optimal price bin step using ATR
atr = ta.atr(100)
auto_step = math.max(syminfo.mintick, math.round((atr / rows_per_candle) / syminfo.mintick) * syminfo.mintick)

// Format volume (e.g., 1500 -> 1.5K)
f_format_vol(v) =>
    if v >= 1000000
        str.tostring(v / 1000000, "#.##M")
    else if v >= 1000
        str.tostring(v / 1000, "#.##K")
    else
        str.tostring(v, "#.##")

// ==========================================
// 5. Fetch Lower Timeframe Data
// ==========================================
ltf_c = request.security_lower_tf(syminfo.tickerid, ltf, close)
ltf_o = request.security_lower_tf(syminfo.tickerid, ltf, open)
ltf_v = request.security_lower_tf(syminfo.tickerid, ltf, volume)

var array<label> all_labels = array.new<label>()

// ==========================================
// 6. Footprint Calculation & Rendering
// ==========================================
target_bar = last_bar_index - bar_offset
is_in_range = bar_index <= target_bar and bar_index > (target_bar - show_bars)

if is_in_range
    map_prices = array.new<float>()
    map_buy_vol = array.new<float>()
    map_sell_vol = array.new<float>()

    if array.size(ltf_c) > 0
        for i = 0 to array.size(ltf_c) - 1
            c = array.get(ltf_c, i)
            o = array.get(ltf_o, i)
            v = nz(array.get(ltf_v, i), 0)

            // Binning prices
            bin_p = math.floor(c / auto_step) * auto_step + (auto_step / 2)
            idx = array.indexof(map_prices, bin_p)

            is_buy = c > o
            is_sell = c < o
            
            if idx == -1
                array.push(map_prices, bin_p)
                array.push(map_buy_vol, is_buy ? v : (is_sell ? 0 : v / 2))
                array.push(map_sell_vol, is_sell ? v : (is_buy ? 0 : v / 2))
            else
                if is_buy
                    array.set(map_buy_vol, idx, array.get(map_buy_vol, idx) + v)
                else if is_sell
                    array.set(map_sell_vol, idx, array.get(map_sell_vol, idx) + v)
                else
                    array.set(map_buy_vol, idx, array.get(map_buy_vol, idx) + v / 2)
                    array.set(map_sell_vol, idx, array.get(map_sell_vol, idx) + v / 2)

        // Render labels on the chart
        for i = 0 to array.size(map_prices) - 1
            b = array.get(map_buy_vol, i)
            s = array.get(map_sell_vol, i)
            p = array.get(map_prices, i)
            
            total_vol = b + s 

            // Filter out low volume nodes
            if total_vol >= min_vol_filter
                txt = f_format_vol(s) + " | " + f_format_vol(b)
                
                delta = b - s
                txt_color = delta > 0 ? color_buy : (delta < 0 ? color_sell : color_neutral)

                // Background styling
                lbl_bg_color = show_bg ? color_bg : color.new(color.white, 100)
                lbl_style = show_bg ? label.style_label_center : label.style_none
                
                lbl = label.new(bar_index, p, text=txt, style=lbl_style, color=lbl_bg_color, textcolor=txt_color, textalign=text.align_center, size=size.small)
                array.push(all_labels, lbl)

// 7. Garbage Collection (Prevent exceeding 500 labels limit)
if array.size(all_labels) > 500
    for i = 1 to (array.size(all_labels) - 500)
        label.delete(array.shift(all_labels))
````
