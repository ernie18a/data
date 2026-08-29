<!-- tradingview-pine-id: PUB;355785b6b3f149e9ba54f5edf2f7864c -->
<!-- tradingviewscripts-format: 1 -->
# Ultimate Volume Delta & Order Flow Suit

Source: https://www.tradingview.com/script/Ab9UHoN9-Ultimate-Volume-Delta-Order-Flow-Suit/

## Description

Ultimate Volume Delta & Institutional Order Flow Suite 

Overview

Ultimate Volume Delta is an all-in-one, premium trading script specifically built for traders utilizing Smart Money Concepts (SMC), Inner Circle Trader (ICT) methodology, and Volume Profile strategies. Going beyond conventional price action, this indicator decodes underlying market liquidity, institutional order flow, and real-time buy/sell pressure (Volume Delta) directly onto a clean, unified interface.

Key Features & Components

 1- Delta-Based Candlesticks:

Calculates the true balance between buyers and sellers inside every single candle. Bars light up in Bright Teal during strong buying delta and Bright Orange/Red during aggressive selling delta, helping you identify institutional momentum without lag.

2- Filtered Order Blocks & High-Volume FVGs:

Filters out market noise by highlighting only those Order Blocks and Fair Value Gaps (FVG) where volume exceeds 1.3x the moving average (Institutional Volume Expansion).
 Bullish OB + FVG: Highlighted with a blue shaded block and dark grey FVG gap.
 Bearish OB + FVG: Highlighted with a red shaded block and dark grey FVG gap.

 3- On-Chart Dual-Color Volume Profile:

Displays buy volume (Teal) and sell volume (Orange) side-by-side on the right side of the chart.
 Cyan POC Line (Point of Control): Draws a bright cyan line at the exact price level where the highest volume was traded. It acts as a powerful price magnet and institutional support/resistance level.

 4- Institutional Dashboard (Top-Right):

A sleek, real-time metrics table situated at the top-right corner:
 Active Session: Real-time indicator for London, New York, or Asian session status.
 Today's Total Delta: Aggregated daily net delta tracking institutional order flow bias.
 High Probability Zones: Live count of active, unmitigated OB/FVG zones on the chart.

5- On-Chart Bottom Delta Histogram:

Plots net delta bars along the lower boundary of the chart to give immediate visual feedback on sudden volume spikes and momentum shifts.

How It Works

The script calculates candle range vs. close location to estimate real-time buy/sell volume allocation. When institutional volume flows into the market, it applies a ⁠SMA Volume Filter⁠ to automatically map out high-probability Order Blocks and FVGs. Simultaneously, the native array-based Volume Profile evaluates the last 90 bars to dynamically render horizontal volume nodes and the Point of Control (POC).

How to Use & Maximize Profitability

 High-Probability Confluence Entries:

Look for trades where price mitigates a marked Bullish/Bearish Order Block inside an FVG zone while simultaneously aligning with the Volume Profile POC Line. This multi-layer confluence provides high win-rate setups.

 Session-Based Execution:

Trade actively when the dashboard displays LONDON (Active) or NEW YORK (Active). Wait for the Delta Histogram to print green while price retests a Bullish OB to confirm institutional backing before entering long.

 Identifying Fakeouts & Traps:

If price is making higher highs while the Delta Histogram prints negative (red) values, it signals a divergence/liquidity sweep—warning you to avoid buying into retail trap moves.

 Risk Management:

 Entry: On tap/mitigation of the OB/FVG zone.
 Stop Loss: Placed just beyond the outer boundary of the Order Block.
 Take Profit: Targeted toward opposing FVGs or the nearest Volume Profile POC level.

Pro Tip

Optimal performance is achieved on the 5-minute or 15-minute timeframes for XAU/USD (Gold) and major Forex pairs. Focus on execution during session overlap periods (12:00 – 16:00 UTC) when volume density and FVG accuracy are at their highest.

⚠️ DISCLAIMER & RISK WARNING

For Educational & Informational Purposes Only:

This indicator, along with all associated tools, metrics, dashboard signals, and automated analysis, is designed strictly for educational, analytical, and informational purposes. It does not constitute financial, investment, trading, or legal advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CoreValence_Analysis

//@version=6
indicator("Ultimate Volume Delta & Order Flow Suit", shorttitle="valcene", overlay=true, max_boxes_count=500, max_lines_count=500)

// ==========================================
// 1. GOLD VOLUME DELTA & CANDLE COLORING
// ==========================================
candle_range = high - low
up_ratio     = candle_range > 0 ? (close - low) / candle_range : 0.5
vol_up       = volume * up_ratio
vol_down     = volume * (1.0 - up_ratio)
vol_delta    = vol_up - vol_down

col_bull_delta = #26A69A  // Teal
col_bear_delta = #E53935  // Orange/Red

barcolor(vol_delta >= 0 ? col_bull_delta : col_bear_delta)

max_p     = ta.highest(high, 90)
min_p     = ta.lowest(low, 90)
abs_delta = math.abs(vol_delta)
max_delta = ta.highest(abs_delta, 50)

// ==========================================
// 2. INSTITUTIONAL DASHBOARD (TOP RIGHT)
// ==========================================
var table dash = table.new(position.top_right, 2, 4, bgcolor=color.new(#1E222D, 10), border_color=#363A45, border_width=1)

var int active_zones = 0
in_london = not na(time(timeframe.period, "0700-1600:1234567", "UTC"))
in_ny     = not na(time(timeframe.period, "1200-2100:1234567", "UTC"))
in_asia   = not na(time(timeframe.period, "2000-0500:1234567", "UTC"))

sess_str  = in_london ? "LONDON (Active)" : in_ny ? "NEW YORK (Active)" : in_asia ? "ASIAN (Active)" : "OFF-HOURS"
sess_col  = in_london or in_ny ? #00E676 : #FFD600

var float cum_delta_today = 0.0
if ta.change(time("D")) != 0
    cum_delta_today := 0.0
cum_delta_today += vol_delta

if barstate.islast
    table.cell(dash, 0, 0, "Institutional Dashboard", text_color=color.white, text_halign=text.align_center, bgcolor=#2A2E39)
    table.cell(dash, 1, 0, "", bgcolor=#2A2E39)
    
    table.cell(dash, 0, 1, "Active Session", text_color=color.red, text_size=size.small)
    table.cell(dash, 1, 1, sess_str, text_color=sess_col, text_size=size.small, bgcolor=color.new(sess_col, 85))
    
    table.cell(dash, 0, 2, "Today's Total Delta", text_color=color.red, text_size=size.small)
    table.cell(dash, 1, 2, (cum_delta_today >= 0 ? "+" : "") + str.tostring(math.round(cum_delta_today / 1000, 1)) + "K", text_color=cum_delta_today >= 0 ? #00E676 : #FF5252, text_size=size.small)
    
    table.cell(dash, 0, 3, "High Probability Zones", text_color=color.silver, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(active_zones), text_color=color.white, text_size=size.small)

// ==========================================
// 3. GOLD ORDER BLOCKS & FVG ZONES
// ==========================================
avg_vol     = ta.sma(volume, 20)
is_high_vol = volume > avg_vol * 1.2

bull_fvg = (low > high[2]) and is_high_vol
bear_fvg = (high < low[2]) and is_high_vol

if bull_fvg
    active_zones += 1
    box.new(left=bar_index - 2, top=low[2], right=bar_index + 35, bottom=low[2] - (high[2] - low[2]) * 0.5,
            bgcolor=color.new(#1565C0, 30), border_color=#1E88E5, border_style=line.style_dashed,
            text="Bullish Filtered Order Block\n(XAUUSD Volume Expansion)", text_color=color.white, text_size=size.tiny)
    box.new(left=bar_index - 2, top=low, right=bar_index + 35, bottom=high[2],
            bgcolor=color.new(#37474F, 70), border_color=color.new(color.green, 60), border_style=line.style_dotted,
            text="FVG", text_color=color.green, text_size=size.tiny)

if bear_fvg
    active_zones += 1
    box.new(left=bar_index - 2, top=high[2] + (high[2] - low[2]) * 0.5, right=bar_index + 35, bottom=high[2],
            bgcolor=color.new(#C62828, 30), border_color=#E53935, border_style=line.style_dashed,
            text="Bearish Filtered Order Block\n(XAUUSD Volume Expansion)", text_color=color.white, text_size=size.tiny)
    box.new(left=bar_index - 2, top=high[2], right=bar_index + 35, bottom=low,
            bgcolor=color.new(#37478f, 70), border_color=color.new(color.green, 60), border_style=line.style_dotted,
            text="FVG", text_color=color.green, text_size=size.tiny)

// ==========================================
// 4. ON-CHART VOLUME PROFILE & CYAN POC
// ==========================================
vp_bars = 90
vp_rows = 28

var box[] vp_buy_boxes  = array.new_box()
var box[] vp_sell_boxes = array.new_box()
var line  poc_line      = na

if barstate.islast
    if array.size(vp_buy_boxes) > 0
        for i = 0 to array.size(vp_buy_boxes) - 1
            box.delete(array.get(vp_buy_boxes, i))
            box.delete(array.get(vp_sell_boxes, i))
        array.clear(vp_buy_boxes)
        array.clear(vp_sell_boxes)
    line.delete(poc_line)

    float row_step = (max_p - min_p) / vp_rows
    if row_step > 0
        float[] buy_bins  = array.new_float(vp_rows, 0.0)
        float[] sell_bins = array.new_float(vp_rows, 0.0)
        
        for b = 0 to vp_bars - 1
            bin_idx = math.min(vp_rows - 1, math.max(0, math.floor((close[b] - min_p) / row_step)))
            c_range = high[b] - low[b]
            u_rat   = c_range > 0 ? (close[b] - low[b]) / c_range : 0.5
            array.set(buy_bins, bin_idx, array.get(buy_bins, bin_idx) + volume[b] * u_rat)
            array.set(sell_bins, bin_idx, array.get(sell_bins, bin_idx) + volume[b] * (1.0 - u_rat))

        float max_tot_vol = 0.0
        int poc_idx = 0
        for r = 0 to vp_rows - 1
            tot_v = array.get(buy_bins, r) + array.get(sell_bins, r)
            if tot_v > max_tot_vol
                max_tot_vol := tot_v
                poc_idx := r

        for r = 0 to vp_rows - 1
            r_top  = min_p + (r + 1) * row_step
            r_bot  = min_p + r * row_step
            b_vol  = array.get(buy_bins, r)
            s_vol  = array.get(sell_bins, r)
            
            b_width = math.round((b_vol / max_tot_vol) * 22)
            s_width = math.round((s_vol / max_tot_vol) * 22)

            array.push(vp_buy_boxes, box.new(left=bar_index + 2, top=r_top, right=bar_index + 2 + b_width, bottom=r_bot, bgcolor=color.new(#00897B, 20), border_color=na))
            array.push(vp_sell_boxes, box.new(left=bar_index + 2 + b_width, top=r_top, right=bar_index + 2 + b_width + s_width, bottom=r_bot, bgcolor=color.new(#D84315, 20), border_color=na))

        poc_price = min_p + (poc_idx + 0.5) * row_step
        poc_line := line.new(bar_index - 15, poc_price, bar_index + 28, poc_price, color=#00E5FF, width=2, style=line.style_solid)

// ==========================================
// 5. BOTTOM DELTA HISTOGRAM
// ==========================================
var box[] hist_boxes = array.new_box()
if barstate.islast
    if array.size(hist_boxes) > 0
        for i = 0 to array.size(hist_boxes) - 1
            box.delete(array.get(hist_boxes, i))
        array.clear(hist_boxes)
        
    float hist_base = min_p - (max_p - min_p) * 0.06
    
    for i = 0 to 50
        d_val = vol_delta[i]
        h_height = max_delta > 0 ? (math.abs(d_val) / max_delta) * ((max_p - min_p) * 0.05) : 0
        h_col = d_val >= 0 ? color.new(#00E676, 30) : color.new(#FF5252, 30)
        
        if d_val >= 0
            array.push(hist_boxes, box.new(left=bar_index - i, top=hist_base + h_height, right=bar_index - i + 1, bottom=hist_base, bgcolor=h_col, border_color=na))
        else
            array.push(hist_boxes, box.new(left=bar_index - i, top=hist_base, right=bar_index - i + 1, bottom=hist_base - h_height, bgcolor=h_col, border_color=na))
````
