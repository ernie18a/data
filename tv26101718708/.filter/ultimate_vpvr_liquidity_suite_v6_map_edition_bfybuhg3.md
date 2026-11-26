# Ultimate VPVR & Liquidity Suite [v6 Map Edition]

- url: https://www.tradingview.com/script/bfybuHG3-Ultimate-VPVR-Liquidity-Suite-v6-Map-Edition/
- type: indicator
- pine_id: PUB;275532336d3241a395a00f13e4c3a0ac
- version: 2.0

## Description

[b]Ultimate VPVR & Liquidity Suite [v6 Map Engine][/b]
Trading without volume context is like flying blind. Price action tells you what is happening, but Volume Profile tells you where the heavy hitters are actually positioned.

The Ultimate VPVR & Liquidity Suite is a massive upgrade over traditional "poor man's" volume profiles. Built from the ground up using Pine Script v6's new map (dictionary) functionality, this indicator abandons arbitrary price "bins" and instead maps volume to the exact price tick. The result is an institutional-grade, highly precise mapping of supply, demand, and liquidity.

But Volume Profile alone isn't enough. This suite synergizes true tick-based VPVR with Anchored VWAP, EMA Mean Reversion alerts, and Institutional Order Blocks to give you a complete, actionable trading system on a single chart.

[b]🔥 Core Features[/b]
Tick-Perfect VPVR (v6 Map Engine): No more distorted volume bars. This script calculates volume exactly where it traded, offering unmatched precision.

[b]Value Area Heatmapping:[/b] Instantly visualize the 70% Value Area (VA). The histogram uses a dynamic gradient (Dark Blue to Bright Yellow) so you can instantly spot the Volume Point of Control (VPoC) and high-liquidity nodes.

Auto-Anchored VWAP: Automatically anchors a VWAP to the exact start of your VPVR Lookback period, giving you the true volume-weighted average price of the profile.

[b]EMA Mean Reversion Alerts[/b]: Plots a 50-period EMA and triggers on-chart warnings when the price becomes dangerously overextended (e.g., "Warning: Overextended 15% from EMA").
[b]
Institutional Order Blocks[/b]: Highlights the last opposing candles before massive impulsive moves (Red/Green Boxes), mapping out hidden supply and demand zones.

[b]📖 How to Trade the Suite (Real-World Examples)[/b]
To understand the power of combining these metrics, here are four textbook setups this indicator is designed to catch:

[b]Example 1[/b]: The "Rubber Band" Buy Setup (Mean Reversion)
The Setup: Price crashes violently, triggering a red "Overextended from EMA" warning tag. The "rubber band" is stretched to the downside.

The Catalyst: The falling price slams directly into the thickest part of the "Yellow Mountain" (the VPoC) and lands exactly on a Green Bullish Order Block.

The Play: This is a prime, high-probability long entry. The downside is heavily protected by historical volume (the brick wall), and the stretched EMA tension suggests a rapid bounce back up.
[b]
Example 2[/b]: The "Air Pocket" Trapdoor (Short Setup)
The Setup: Price rockets upward, flashing an overextended warning above the EMA.

The Catalyst: The rally stalls perfectly at a historical Red Box (Bearish Order Block), creating a hard ceiling.

The Danger: Directly below the current price, the volume histogram is completely grey and thin. This is an "Air Pocket" (Low Volume Node).

The Play: Because there is no floor of historical buyers directly beneath the price, if that Red Box ceiling holds, the price is highly likely to drop rapidly through the thin air to retest lower support. Excellent short setup.

[b]Example 3[/b]: The Heavy Consolidation Channel
The Setup: The price is trapped. It is sitting securely on the white VPoC line (massive floor), but is struggling against overhead Red Order Blocks and a descending 50 EMA (heavy ceiling).

The Play: The Value Area (yellow bars) is incredibly thick here, indicating the market accepts this as "fair value." Expect choppy, sideways range-trading until a major volume catalyst forces a breakout above the EMA or below the Value Area Low (dashed red line).

[b]Example 4[/b]: The Parabolic Anomaly (Take-Profit Warning)
The Setup: An asset goes parabolic, stretching 50%+ away from the EMA.

The Danger: The VPoC (solid white line) remains anchored at the absolute bottom of your screen. The current price is floating in extreme low-volume territory (indicated by dark blue profile bars).

The Play: The market hasn't built a base here. The lack of a "yellow mountain" beneath the price means there is zero safety net. This is a screaming signal to take profits and tighten stop-losses before the inevitable, violent mean-reversion drop.

[b]⚙️ Best Settings & Customization[/b]
[b]For Crypto / High Volatility (4H Chart)[/b]: Set the Lookback to 100-300 bars. Set the "Tick Grouping" to 10-20 to smooth out erratic wicks. Keep the EMA deviation threshold tight (around 3-5%).

[b]For Macro / Stocks (Daily Chart)[/b]: Set the Lookback to 300-500 bars to capture massive institutional accumulation zones. Lower the Tick Grouping (1-5) for higher precision. Increase the EMA deviation threshold (5-10%).

[b]Disclaimer[/b]: [i]This script is for educational and analytical purposes only. Volume profiles indicate historical interest, not guaranteed future performance. Always use proper risk management.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © R2D2_4Life

//@version=6
indicator("Ultimate VPVR & Liquidity Suite [v6 Map Edition]", "Ult_VPVR_v6", overlay=true, max_lines_count=500, max_labels_count=100, max_boxes_count=50)

// =========================================================================
// 1. INPUTS, SETTINGS & HELP GUIDES
// =========================================================================

// --- VPVR Core (v6 Map Engine) ---
grp_vpvr = "VPVR Core (Map Engine)"

enable_vpvr = input.bool(true, "Show VPVR Profile", group=grp_vpvr, 
  tooltip="Toggles the visual Volume Profile on the right side of your chart.")

vpvr_n_bars = input.int(100, "VPVR Lookback (Bars)", minval=10, maxval=2000, group=grp_vpvr, 
  tooltip="How many bars back the volume is calculated.\n\nBEST SETTINGS:\n- 4H Chart (Crypto/Volatility): 100-300 bars to capture the current local trend.\n- Daily Chart (Macro/Growth Stocks): 300-500+ bars to find major institutional accumulation zones.")

vp_tick_mult = input.int(10, "Tick Grouping (Precision)", minval=1, group=grp_vpvr, 
  tooltip="Combines micro-ticks into thicker price blocks for a cleaner histogram.\n\nBEST SETTINGS:\n- 1 to 5: High precision, best for tight forex pairs or tight stock ranges.\n- 10 to 50+: Best for volatile assets like XRP or high-growth tech stocks to smooth out the noise.")

vp_width = input.int(20, "Profile Width (Bars)", minval=5, maxval=100, group=grp_vpvr, 
  tooltip="Controls how far the histogram stretches horizontally across your screen. Adjust this based on your monitor size.")

vp_offset = input.int(5, "Profile Offset (Bars)", minval=0, maxval=50, group=grp_vpvr, 
  tooltip="Pushes the histogram to the right, creating a visual buffer so it doesn't block the current candles.")

va_percent = input.float(70.0, "Value Area %", minval=10.0, maxval=100.0, group=grp_vpvr, 
  tooltip="The percentage of total volume considered 'fair value'.\n\n70% is the industry standard. Price tends to bounce between the top and bottom of this range.")

// --- Synergy Indicators ---
grp_syn = "Synergy Indicators"

enable_vwap = input.bool(true, "Show Auto-Anchored VWAP", group=grp_syn, 
  tooltip="Automatically anchors a VWAP to the exact start of your VPVR Lookback period, giving you the true average price of the profile.")

enable_ema = input.bool(true, "Show 50 EMA & Mean Reversion Alert", group=grp_syn, 
  tooltip="Plots a standard 50-period EMA and triggers an overextended warning if price moves too far away from it.")

ema_dev_thresh = input.float(5.0, "EMA Deviation Alert Threshold (%)", group=grp_syn, 
  tooltip="How far price must stretch from the EMA to trigger a warning.\n\nBEST SETTINGS:\n- 4H Chart: 2% to 4%\n- Daily Chart: 5% to 10% (depending on asset volatility).")

enable_ob = input.bool(true, "Show Order Blocks (Institutional Footprints)", group=grp_syn, 
  tooltip="Highlights the last opposing candle before a massive impulse move. These zones often act as heavy support/resistance on retests.")

// Colors
color_vpoc    = color.new(color.white, 0)
color_va_low  = color.new(color.blue, 60)
color_va_high = color.new(color.yellow, 20)
color_ob_bull = color.new(color.teal, 80)
color_ob_bear = color.new(color.red, 80)

// =========================================================================
// 2. v6 MAP-BASED VPVR LOGIC (INTEGER INDEXING FIX)
// =========================================================================
var vp_map = map.new<int, float>()
var vpvr_lines = array.new<line>()
var vpvr_labels = array.new<label>()

if barstate.islast and enable_vpvr
    // Clear previous data
    vp_map.clear()
    for l in vpvr_lines
        l.delete()
    for lbl in vpvr_labels
        lbl.delete()
    vpvr_lines.clear()
    vpvr_labels.clear()

    float step = syminfo.mintick * vp_tick_mult
    float total_vol = 0.0

    // 1. Build the Volume Map using strict integer levels to avoid float errors
    for i = 0 to vpvr_n_bars - 1
        int min_lvl = math.floor(low[i] / step)
        int max_lvl = math.ceil(high[i] / step)
        int num_steps = math.max(1, max_lvl - min_lvl)
        float vol_slice = volume[i] / num_steps
        
        for j = min_lvl to max_lvl
            float current_vol = nz(vp_map.get(j))
            vp_map.put(j, current_vol + vol_slice)
            total_vol += vol_slice

    // 2. Find VPoC & Extract Keys
    array<int> levels = vp_map.keys()
    levels.sort() // Ascending order
    
    float max_vol = 0.0
    int vpoc_lvl = na
    int vpoc_idx = -1
    
    for i = 0 to levels.size() - 1
        int lvl = levels.get(i)
        float v = vp_map.get(lvl)
        if v > max_vol
            max_vol := v
            vpoc_lvl := lvl
            vpoc_idx := i

    float vpoc_price = vpoc_lvl * step

    // 3. Calculate 70% Value Area (VAH / VAL)
    float va_target = total_vol * (va_percent / 100)
    float current_va_vol = max_vol
    int up_idx = vpoc_idx + 1
    int down_idx = vpoc_idx - 1
    
    while current_va_vol < va_target and (up_idx < levels.size() or down_idx >= 0)
        float vol_up = up_idx < levels.size() ? vp_map.get(levels.get(up_idx)) : -1.0
        float vol_down = down_idx >= 0 ? vp_map.get(levels.get(down_idx)) : -1.0
        
        if vol_up >= vol_down and vol_up != -1.0
            current_va_vol += vol_up
            up_idx += 1
        else if vol_down != -1.0
            current_va_vol += vol_down
            down_idx -= 1
        else
            break
            
    float vah_price = levels.get(math.min(up_idx - 1, levels.size() - 1)) * step
    float val_price = levels.get(math.max(down_idx + 1, 0)) * step

    // 4. Render the VPVR Profile using v6 Array Methods
    int dt = time - time[1]
    
    for i = 0 to levels.size() - 1
        int lvl = levels.get(i)
        float lvl_price = lvl * step
        float lvl_val = vp_map.get(lvl)
        
        color node_color = color.from_gradient(lvl_val, 0, max_vol, color_va_low, color_va_high)
        bool is_in_va = (lvl_price >= val_price and lvl_price <= vah_price)
        color final_color = lvl == vpoc_lvl ? color_vpoc : (is_in_va ? node_color : color.new(color.gray, 70))
        
        float width_prop = lvl_val / math.max(max_vol, 1)
        int x1 = math.floor(time + dt + vp_offset*dt + vp_width*dt - (width_prop*(vp_width*dt)))
        int x2 = math.floor(time + dt + vp_offset*dt + vp_width*dt)
        
        vpvr_lines.push(line.new(x1=x1, y1=lvl_price, x2=x2, y2=lvl_price, width=3, xloc=xloc.bar_time, color=final_color))

    // Render VAH, VAL lines, and VPoC Label
    vpvr_lines.push(line.new(x1=time, y1=vah_price, x2=math.floor(time + dt + vp_offset*dt + vp_width*dt), y2=vah_price, xloc=xloc.bar_time, color=color.new(color.green, 40), style=line.style_dashed))
    vpvr_lines.push(line.new(x1=time, y1=val_price, x2=math.floor(time + dt + vp_offset*dt + vp_width*dt), y2=val_price, xloc=xloc.bar_time, color=color.new(color.red, 40), style=line.style_dashed))
    
    string vpoc_txt = str.tostring(vpoc_price, "#.####")
    vpvr_labels.push(label.new(math.floor(time + dt + vp_offset*dt + vp_width*dt), vpoc_price, text=vpoc_txt, xloc=xloc.bar_time, color=color_vpoc, style=label.style_label_left))

// =========================================================================
// 3. ANCHORED VWAP (v6 Sliding Array Method)
// =========================================================================
var num_arr = array.new<float>()
var den_arr = array.new<float>()

num_arr.unshift(hlc3 * volume)
den_arr.unshift(volume)

if num_arr.size() > vpvr_n_bars
    num_arr.pop()
    den_arr.pop()

float anchored_vwap = num_arr.sum() / den_arr.sum()
plot(enable_vwap ? anchored_vwap : na, color=color.orange, title="Anchored VWAP", linewidth=2)

// =========================================================================
// 4. EMA & MEAN REVERSION DISTANCE
// =========================================================================
float ema50 = ta.ema(close, 50)
plot(enable_ema ? ema50 : na, color=color.purple, title="50 EMA", linewidth=2)

if enable_ema and barstate.islast
    float dist_pct = math.abs(close - ema50) / ema50 * 100
    if dist_pct > ema_dev_thresh
        label.new(bar_index, high, text="Warning: Overextended\n" + str.tostring(dist_pct, "#.#") + "% from EMA", color=color.red, textcolor=color.white, style=label.style_label_down)

// =========================================================================
// 5. ORDER BLOCKS (Institutional Footprints)
// =========================================================================
var boxes = array.new<box>()

if enable_ob
    bool impulse_bull = close > close[3] * 1.02 and close > open and close[1] > open[1]
    bool impulse_bear = close < close[3] * 0.98 and close < open and close[1] < open[1]
    
    if impulse_bull and close[3] < open[3]
        boxes.push(box.new(left=bar_index[3], top=high[3], right=bar_index, bottom=low[3], border_color=color.new(color.teal, 50), bgcolor=color_ob_bull))
    if impulse_bear and close[3] > open[3]
        boxes.push(box.new(left=bar_index[3], top=high[3], right=bar_index, bottom=low[3], border_color=color.new(color.red, 50), bgcolor=color_ob_bear))
    
    if boxes.size() > 10
        box b = boxes.shift()
        b.delete()

// May the trades be with you.
````
