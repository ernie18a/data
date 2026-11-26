# Session Sweeps Pro | GainzAlgo

- url: https://www.tradingview.com/script/A7dusy8g-Session-Sweeps-Pro-GainzAlgo/
- type: indicator
- pine_id: PUB;e0f70b3accca4dd29f682a414cfc94f0
- version: 1.0

## Description

[b]What are Liquidity Sweeps?[/b]

In modern algorithmic markets, price does not move randomly; it moves from one [b]pocket of liquidity[/b] to the next. Liquidity Sweeps (also known as [b]stop runs[/b] or [b]"grabs"[/b]) occur when price briefly breaches a well-defined technical level (like a swing high or low) to trigger the stop-loss orders resting there.

Once this liquidity is "tapped," large institutional players often use these orders to fill their own counter-positions, leading to a [b]sharp reversal[/b]. Identifying where these sweeps have occurred and where they are likely to occur next, is the cornerstone of [b]institutional-grade supply and demand trading[/b].

[b]Introducing: Session Sweeps by GainzAlgo[/b]

This indicator is a [b]premium technical suite[/b] designed to visualize the "gravity" of market liquidity. Unlike 90% of liquidity indicators that simply label old highs and lows, the Session Sweeps uses a [b]probabilistic model[/b] to map out exactly where the "business" of the market is being conducted.

It combines [b]real-time sweep detection[/b] with a [b]Cumulative Distribution Function (CDF)[/b] to provide a heads-up display (HUD) of the session's liquidity health.

[b]How It Works:[/b]

The engine monitors price action for [b]"breach and reclaim" signatures[/b].

[list]
[*][b]Detection:[/b] When a pivot high or low is swept and price closes back within the previous range, the script identifies a [b]confirmed sweep[/b].

[*][b]Ghost S/R Zones:[/b] Upon detection, the script anchors a [b]"Ghost Box"[/b] at the sweep level. These zones extend through the current session, acting as [b]dynamic support and resistance levels[/b] that represent "already tapped" liquidity.

[*][b]Conflict Resolution:[/b] To keep your charts clean, the script includes a built-in [b]"De-overlapping" logic[/b]. If multiple sweeps occur in the same tight price area, it prioritizes the [b]most significant level[/b], preventing visual clutter.
[/list]

[b]The Liquidity Sweep CDF Profile[/b]

The centerpiece of this indicator is the [b]HUD Profile[/b] on the right margin. While standard Volume Profiles show you where volume was traded, our Sweep CDF shows you the [b]distribution of liquidity grabs[/b].

[list]
[*][b]Weighted Gravity:[/b] Every bar in the profile is weighted by the [b]frequency of sweeps[/b]. A "thick" area in the profile indicates a price zone where the market has repeatedly reached for stops.

[*][b]Color-Coded Probability:[/b] The profile uses a [b]manual RGB interpolation[/b] (shifting from Neon Cyan to Magenta). As the bars widen and change color, they represent the [b]cumulative probability (0% to 100%)[/b] of the session's total liquidity being found at or below that price.

[*][b]Sweep POC (Point of Control):[/b] The yellow dashed line represents the [b]Sweep POC[/b], the specific price level with the [b]highest density of liquidity sweeps[/b] in the current session. This is the market's true [b]"Center of Gravity."[/b]
[/list]

[b]Session Anchoring & Menu Inputs[/b]

The indicator is built for the [b]professional intraday and swing trader[/b], offering full control over the data's scope:

[list]
[*][b]Session Period:[/b] Select between [b]Daily, Weekly, or Monthly[/b] anchors. The CDF profile and S/R zones will automatically reset at the start of each new period, ensuring your data is [b]fresh and relevant[/b].

[*][b]Profile Resolution:[/b] Adjust the number of [b]"Rows"[/b] to fine-tune the granularity of the [b]CDF heatmap[/b].

[*][b]Risk Threshold:[/b] Customize the sensitivity of the [b]Sweep Risk Index[/b] (top right), which monitors [b]volatility compression[/b] to warn you when a sweep is [b]statistically imminent[/b].
[/list]

[b]How to Trade with Session Sweeps[/b]

[list=1]
[*][b]Mean Reversion:[/b] Watch for price to approach the [b]Sweep POC[/b] during low-volatility periods. These often act as [b]magnets[/b] where price stabilizes.

[*][b]Exhaustion Signals:[/b] Use the [b]CDF percentages[/b] (85%, 70%, etc.). If price is trading at the [b]90% CDF level[/b], it means the majority of the session's liquidity has already been [b]"cleared"[/b] below. Pursuing further moves in that direction carries [b]higher risk[/b].

[*][b]S/R Flips:[/b] Use the [b]Ghost S/R Boxes[/b] as high-probability entry/exit zones. A [b]Bearish Sweep zone[/b] that was once resistance will often act as a [b]"re-entry" point[/b] if price returns to test the liquidity remaining in that pocket.

[*][b]The Risk Index:[/b] Monitor the [b]Sweep Risk %[/b] in the dashboard. When this index spikes ([b]Red[/b]), be wary of placing stops at obvious swing points, as the [b]"Stop Hunt" probability[/b] is at its peak.
[/list]

## Source Code

````pine
//@version=6
indicator("Session Sweeps Pro | GainzAlgo", overlay = true, max_boxes_count = 500, max_lines_count = 100, max_bars_back = 5000)

// rbg colours 
int r1 = 0,   g1 = 242, b1 = 255 
int r2 = 255, g2 = 0,   b2 = 255 

// ui
group_hud      = "Profile Settings"
session_type   = input.string("Daily", "Session Period", options = ["Daily", "Weekly", "Monthly"], group=group_hud)
num_rows       = input.int(40, "Rows", minval = 10, maxval = 100, group=group_hud)
glow_width     = input.int(40, "Glow Width", minval = 5, maxval = 100, group=group_hud)

group_sweeps   = "Sweep S/R Logic"
lookback_p     = input.int(1000, "Historical Lookback", minval = 100, group=group_sweeps)
risk_threshold = input.int(75, "Risk Score Threshold (%)", group=group_sweeps)
ghost_opacity  = input.int(85, "Ghost S/R Transparency", minval = 0, maxval = 100, group=group_sweeps)

group_extra    = "Supplemental Features"
poc_alert_prox = input.float(0.1, "POC Alert Proximity (%)", group=group_extra)

// array initalize 
type SweepEvent
    float price
    float top
    float bot
    int   startTime
    bool  isBearish
    box   ghostBox
    label retestLabel
    int   retestCount = 0
    bool  wasRetested = false
    bool  isBroken    = false

var sweep_history = array.new<SweepEvent>()
var float s_max = 0.0
var float s_min = 0.0
var int   s_start_time = 0
var float[] sweep_prices = array.new_float()

//sessions 
bool is_new = switch session_type
    "Daily"   => timeframe.change("D")
    "Weekly"  => timeframe.change("W")
    "Monthly" => timeframe.change("M")

if is_new
    array.clear(sweep_prices)
    s_max := high
    s_min := low
    s_start_time := time
else
    s_max := math.max(s_max, high)
    s_min := math.min(s_min, low)

//R:R 
f_get_risk_score() =>
    float atr = ta.atr(14)
    float std = ta.stdev(close, 10)
    na(atr) or atr == 0 ? 50.0 : math.max(0.0, math.min(100.0, 100.0 - (std / atr) * 50.0))

ph = ta.pivothigh(high, 20, 20)
pl = ta.pivotlow(low, 20, 20)
atr = ta.atr(14)

f_is_overlapping(new_price) =>
    bool overlap = false
    if array.size(sweep_history) > 0
        for i = 0 to array.size(sweep_history) - 1
            if math.abs(array.get(sweep_history, i).price - new_price) < (atr * 1.5)
                overlap := true
                break
    overlap


var int session_zones = 0
var int total_retests = 0
var int held_zones    = 0
var int broken_zones  = 0

if is_new
    session_zones := 0
    total_retests := 0
    held_zones    := 0
    broken_zones  := 0

if not na(ph) and not f_is_overlapping(high[20])
    float top = high[20] + (atr*0.2), float bot = high[20]
    c = color.rgb(r2, g2, b2, ghost_opacity)
    gb = box.new(bar_index[20], top, bar_index, bot, bgcolor=c, border_color=color.new(c, 70))
    lb = label.new(bar_index, high[20], "", color=color.new(color.black, 100), textcolor=color.white, size=size.tiny)
    sweep_history.push(SweepEvent.new(high[20], top, bot, s_start_time, true, gb, lb))
    array.push(sweep_prices, high[20]) 
    label.new(bar_index[20], high[20], "▼", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)
    alert("New Bearish Sweep Detected at " + str.tostring(high[20]), alert.freq_once_per_bar)

if not na(pl) and not f_is_overlapping(low[20])
    float top = low[20], float bot = low[20] - (atr*0.2)
    c = color.rgb(r1, g1, b1, ghost_opacity)
    gb = box.new(bar_index[20], top, bar_index, bot, bgcolor=c, border_color=color.new(c, 70))
    lb = label.new(bar_index, low[20], "", color=color.new(color.black, 100), textcolor=color.white, size=size.tiny)
    sweep_history.push(SweepEvent.new(low[20], top, bot, s_start_time, false, gb, lb))
    array.push(sweep_prices, low[20])
    label.new(bar_index[20], low[20], "▲", style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
    alert("New Bullish Sweep Detected at " + str.tostring(low[20]), alert.freq_once_per_bar)

if array.size(sweep_history) > 0
    for i = 0 to array.size(sweep_history) - 1
        SweepEvent s = array.get(sweep_history, i)
        bool in_session = s.startTime == s_start_time
        if in_session
            session_zones += 1
            
        if not s.isBroken
            box.set_right(s.ghostBox, bar_index)
            label.set_x(s.retestLabel, bar_index)
            
  
            bool touching = high >= s.bot and low <= s.top
            if touching and not s.wasRetested
                s.retestCount += 1
                s.wasRetested := true
                total_retests += 1
                label.new(bar_index, s.price, "↺", style=label.style_label_center, color=color.new(color.yellow, 20), textcolor=color.white, size=size.tiny)
                alert("Zone Re-touch: Price returned to sweep at " + str.tostring(s.price))
            else if not touching
                s.wasRetested := false
            
            // Break Logic
            if (s.isBearish and close > s.top) or (not s.isBearish and close < s.bot)
                s.isBroken := true
                broken_zones += in_session ? 1 : 0
            else
                held_zones += in_session ? 1 : 0
            
            if s.retestCount > 0
                label.set_text(s.retestLabel, "R:" + str.tostring(s.retestCount))

// stats 
if barstate.islast and array.size(sweep_prices) > 0
    for b in box.all 
        if box.get_left(b) > bar_index 
            box.delete(b) 
    for l in line.all 
        line.delete(l)
    for lb in label.all
        if label.get_x(lb) > bar_index
            label.delete(lb)

    float range_size = s_max - s_min
    float step = range_size / num_rows
    float[] counts = array.new_float(num_rows, 0.0)

    for p in sweep_prices
        int bin = math.min(num_rows - 1, int((p - s_min) / step))
        if bin >= 0
            array.set(counts, bin, array.get(counts, bin) + 1)

    float cumulative = 0.0
    float max_freq = array.max(counts)
    int poc_bin = 0

    for i = 0 to num_rows - 1
        float freq = array.get(counts, i) / array.size(sweep_prices)
        if array.get(counts, i) == max_freq
            poc_bin := i
        
        cumulative += freq
        float p_low = s_min + (i * step)
        float p_high = p_low + step
        
        int r = int(r1 + (r2 - r1) * cumulative)
        int g = int(g1 + (g2 - g1) * cumulative)
        int b = int(b1 + (b2 - b1) * cumulative)
        color dyn_color = color.rgb(r, g, b)
        
        box current_box = box.new(bar_index + 2, p_high, bar_index + 2 + int(cumulative * glow_width), p_low,
          bgcolor=color.new(dyn_color, 70), border_color=color.new(dyn_color, 90))

        float perc = cumulative * 100
        if perc % 15 <= 2 or perc >= 98
            box.set_text(current_box, str.format("{0,number,#}%", perc))
            box.set_text_size(current_box, size.tiny)
            box.set_text_color(current_box, dyn_color)
            box.set_text_halign(current_box, text.align_left)

    float poc_price = s_min + (poc_bin + 0.5) * step
    line.new(s_start_time, poc_price, time + (glow_width * 50000), poc_price,
      color=color.yellow, width=3, style=line.style_dashed, xloc=xloc.bar_time)
    
    label.new(time + (glow_width * 60000), poc_price, "⬥ SWEEP POC", 
      color=color.new(color.black, 100), textcolor=color.yellow, style=label.style_label_left, size=size.normal, xloc=xloc.bar_time)


    if math.abs(close - poc_price) / poc_price <= (poc_alert_prox / 100)
        alert("Price approaching Session Sweep POC", alert.freq_once_per_bar)

// stats table 
var table risk_tab = table.new(position.top_right, 2, 5, bgcolor=color.rgb(5, 5, 20, 10), border_width=1, border_color=color.rgb(80, 80, 180))
if barstate.islast
    rs = f_get_risk_score(), rc = rs > risk_threshold ? color.red : color.green
    table.cell(risk_tab, 0, 0, "SWEEP RISK", text_color=color.rgb(160,160,255), text_size=size.small)
    table.cell(risk_tab, 1, 0, str.tostring(math.round(rs)) + "%", text_color=rc, text_size=size.large)
    table.cell(risk_tab, 0, 1, "HISTORIC", text_color=color.rgb(160,160,255), text_size=size.small)
    table.cell(risk_tab, 1, 1, str.tostring(array.size(sweep_history)), text_color=color.white)
    table.cell(risk_tab, 0, 2, "SESSION", text_color=color.rgb(160,160,255), text_size=size.small)
    table.cell(risk_tab, 1, 2, str.tostring(session_zones), text_color=color.white)
    table.cell(risk_tab, 0, 3, "RETESTS", text_color=color.rgb(160,160,255), text_size=size.small)
    table.cell(risk_tab, 1, 3, str.tostring(total_retests), text_color=color.white)
    table.cell(risk_tab, 0, 4, "HOLD/BRK", text_color=color.rgb(160,160,255), text_size=size.small)
    table.cell(risk_tab, 1, 4, str.tostring(held_zones) + "/" + str.tostring(broken_zones), text_color=color.white)



if barstate.islast and array.size(sweep_prices) > 0

    for b in box.all 
        if box.get_left(b) > bar_index 
            box.delete(b) 
    for l in line.all 
        line.delete(l)
    for lb in label.all
        if label.get_x(lb) > bar_index
            label.delete(lb)

    // Binning & Frequency Logic
    float range_size = s_max - s_min
    float step = range_size / num_rows
    float[] counts = array.new_float(num_rows, 0.0)
    
    for p in sweep_prices
        int bin = math.min(num_rows - 1, int((p - s_min) / step))
        if bin >= 0
            array.set(counts, bin, array.get(counts, bin) + 1)

    float cumulative = 0.0
    float max_freq = array.max(counts)
    int poc_bin = 0 

    for i = 0 to num_rows - 1
        float freq = array.get(counts, i) / array.size(sweep_prices)
        if array.get(counts, i) == max_freq
            poc_bin := i 
        
        cumulative += freq
        float p_low = s_min + (i * step)
        float p_high = p_low + step
        
        color dyn_color = color.rgb(int(r1 + (r2 - r1) * cumulative), int(g1 + (g2 - g1) * cumulative), int(b1 + (b2 - b1) * cumulative))
        box current_box = box.new(bar_index + 2, p_high, bar_index + 2 + int(cumulative * glow_width), p_low, bgcolor=color.new(dyn_color, 70), border_color=color.new(dyn_color, 90))

        // HUD Labels
        float perc = cumulative * 100
        if perc % 15 <= 2 or perc >= 98
            box.set_text(current_box, str.format("{0,number,#}%", perc))
            box.set_text_size(current_box, size.tiny)
            box.set_text_color(current_box, dyn_color)
            box.set_text_halign(current_box, text.align_left)

   
    float poc_price = s_min + (poc_bin + 0.5) * step 
    
    line.new(s_start_time, poc_price, time + (glow_width * 50000), poc_price,
      color=color.yellow, width=3, style=line.style_dashed, xloc=xloc.bar_time)
    
    label.new(time + (glow_width * 60000), poc_price, "⬥ SWEEP POC", 
      color=color.new(color.black, 100), textcolor=color.yellow, style=label.style_label_left, size=size.normal, xloc=xloc.bar_time) 

    // Supplemental Alert Logic
    bool approaching_poc = math.abs(close - poc_price) / poc_price <= 0.001 
    bool hit_poc = ta.cross(close, poc_price)

    if approaching_poc
        alert("Price is approaching the Session POC", alert.freq_once_per_bar)
    if hit_poc
        alert("POC Hit at " + str.tostring(close), alert.freq_once_per_bar)
````
