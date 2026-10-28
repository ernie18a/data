# Volumetric Energy Profiles (VEP) [The Quant Science]

- url: https://www.tradingview.com/script/1wCTZdaF-Volumetric-Energy-Profiles-VEP-The-Quant-Science/
- type: indicator
- pine_id: PUB;74a6ab3e262846deb583f19bedc4378c
- version: 1.0

## Description

An advanced quantitative indicator that maps volatility in a two-dimensional manner by combining price volatility bands with volumetric energy profiles.
[image]https://www.tradingview.com/x/LVeJUyzQ/[/image]

[b]1. The Price Dimension[/b]
The script calculates the percentage ratio of the price relative to the moving average, measures its standard deviation, and generates dynamic channels. This dimension visually shows when volatility contracts (narrow bands) or expands (wide bands).
[image]https://www.tradingview.com/x/9txFSzRV/[/image]
[image]https://www.tradingview.com/x/ZLiFF9Vl/[/image]

[b]2. The Volume Dimension[/b]
The horizontal profiles do not simply measure "where volumes are most volatile", but instead calculate a combined energy score by multiplying the [b]True Range[/b] by [b]Volume[/b]. This dimension maps where the highest energy—combining price and volume—has concentrated within that time block. In simple terms, it identifies the "heaviest and most intense" price levels where the market has moved significant volume accompanied by real price swings.
[image]https://www.tradingview.com/x/jv1oZ2Pq/[/image]

🔷 [b]What it does [/b]

🔹 [b]1. The Dynamic Volatility Bands[/b]
It calculates a Moving Average and plots dynamic bands based on standard deviation (Sigma) multiples. This component does not calculate the standard deviation directly on the raw price, but rather on the percentage deviation of the price relative to the moving average, thus normalizing volatility across different timeframes.

🔹 [b]2. The Normalized Volatility Profile Engine (0–100)[/b]
Transforms a time series into a vertical block histogram. It periodically divides historical data into vertical blocks (default: every 30 bars) and generates horizontal bar profiles normalized on a scale from 0 to 100.

[list]
[*][b]Block-Based Time Partitioning[/b]
The indicator partitions time into discrete, fixed-width blocks (default: 30 bars).
[*][b]Price Range / Price Extension[/b]
For each block, it identifies the absolute high and low prices reached.
[*][b]Price Binning / Price Bin Subdivision[/b]
The total vertical range is divided into a predefined number of discrete intervals (referred to as bins).
[*][b]Bar-Weighted Energy Score[/b]
For each bar within the block, an "energy score" is calculated by combining the actual price excursion (True Range) and Volume.
[*][b]Min-Max Normalization (0–100)[/b]
To make different blocks comparable regardless of the volume traded at different times, the raw weights are normalized relative to the maximum weight recorded within that single block.
[*][b]Width Conversion / Translation to Width[/b]
Finally, the normalized score (from 1 to 100) is converted into the horizontal width of the profiles drawn on the chart. As a result, price levels with higher energy concentration receive a score close to 100 and render wider horizontal bars within the time block.
[/list]

🔷 [b]What It Is Used For[/b]
Thanks to its two-dimensional nature, it is primarily used to:

🔹 [b]Identify Breakout and Consolidation Zones (Breakout & Range)[/b]
[list]
[*][b]Volatility compression:[/b] When the dynamic bands contract significantly and the profile blocks concentrate within a narrow price range, the market is accumulating energy.
[*][b] Volatility Expansion:[/b] A breakout from these areas often signals the beginning of a strong trend, helping to filter out false signals.
[/list]

🔹 [b]Identify Volatility and Volume "Points of Control" (HVN/LVN)[/b]
The block-based horizontal profiles function similarly to a dynamic Volume Profile. The longer bars (highlighted by score levels reaching up to 100) reveal high-energy price levels, which frequently act as powerful dynamic support or resistance. Areas lacking profiles or exhibiting low intensity indicate vacuum zones where price can move rapidly (acceleration zones).

🔹 [b]Risk Management and Dynamic Stop Losses[/b]
Bands based on volatility standard deviation ([b]Sigma[/b]) multiples allow traders to adapt stop loss and take profit levels to current market volatility, preventing premature stop-outs during periods of normal price fluctuations.

🔹 [b]Trend Strength Analysis[/b]
The code visually distinguishes between bullish zones and bearish zones. The density of the profiles within these areas indicates whether the directional move is backed by real volumes and price swings or driven by weak trading activity.

🔷 [b]Who Uses It[/b]
This advanced indicator is a highly versatile tool for both quantitative and technical traders.

🔷 [b]How to Use It[/b]
In the settings panel, select the [b]moving average type[/b].
Adjust [b]Bars per Profile Block[/b] (default: 30 bars) to define the frequency with which new volume profiles are generated.
[image]https://www.tradingview.com/x/0rEwFLkV/[/image]
It works on any timeframe, but performs best on liquid assets where volume data is accurate and meaningful.

[b]Dashboard[/b] 
Real-time visual guide for interpreting volatility block density and color coding.
[image]https://www.tradingview.com/x/loBB68d7/[/image]
The dashboard is structured into 3 columns and 4 intensity levels.

[b]Columns[/b]
[b]Scale [0–100] Column:[/b] Displays the normalized numerical scale of the energy score.
[b]Bullish Profile Column:[/b] Displays the block colors and opacity when positioned above the moving average.
[b]Bearish Profile Column:[/b] Displays the block colors and opacity when positioned below the moving average.

[b]Intensity Bands[/b]
[b]0–49 (Low Base):[/b] The blocks are highly transparent and thin. They represent "cold" price zones with minimal movement or negligible trading activity.
[b]50–59 (Mid-Low):[/b] An intermediate intensity level indicating normal market activity.
[b]60–79 (Mid-High): [/b]The area becomes denser and more visible, signaling growing trader interest at that price level.
[b]80–100 🔥 (High Energy):[/b] These are the most vibrant, solid, and horizontally extended blocks on the chart. They represent true energetic [b]Points of Control[/b] ("hot" levels) where the market concentrated maximum volumetric momentum and price excursion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thequantscience

//@version=6
indicator("Volumetric Energy Profiles (VEP) [The Quant Science]", overlay=true, max_boxes_count=1000)

ma_type = input.string("EMA", title="Type", options=["SMA", "EMA", "WMA", "HMA", "RMA"], group="Settings")
step_bars = input.int(30, title="Bars per Profile Block", minval=10, maxval=200, group="Settings")

num_bins = 30
max_blocks = 20

mult_step1 = 0.8
mult_step2 = 1.5
mult_step3 = 2.2

color_bull = #00ff0d 
color_bear = #ff0000

get_ma(type, source, len) =>
    switch type
        "SMA" => ta.sma(source, len)
        "EMA" => ta.ema(source, len)
        "WMA" => ta.wma(source, len)
        "HMA" => ta.hma(source, len)
        "RMA" => ta.rma(source, len)
        => na

ma_value = get_ma(ma_type, close, 20)
ratio = (close - ma_value) / ma_value * 100
ratio_sma = ta.sma(ratio, 20)
ratio_stdev = ta.stdev(ratio, 20)

u1 = ma_value * (1 + (ratio_sma + ratio_stdev * mult_step1) / 100)
u2 = ma_value * (1 + (ratio_sma + ratio_stdev * mult_step2) / 100)
u3 = ma_value * (1 + (ratio_sma + ratio_stdev * mult_step3) / 100)
d1 = ma_value * (1 + (ratio_sma - ratio_stdev * mult_step1) / 100)
d2 = ma_value * (1 + (ratio_sma - ratio_stdev * mult_step2) / 100)
d3 = ma_value * (1 + (ratio_sma - ratio_stdev * mult_step3) / 100)

p_u3 = plot(u3, color=color.new(color.white, 100), display=display.none)
p_u2 = plot(u2, color=color.new(color.white, 100), display=display.none)
p_u1 = plot(u1, color=color.new(color.white, 100), display=display.none)
p_ma = plot(ma_value, color=color.new(color.white, 100), display=display.none)
p_d1 = plot(d1, color=color.new(color.white, 100), display=display.none)
p_d2 = plot(d2, color=color.new(color.white, 100), display=display.none)
p_d3 = plot(d3, color=color.new(color.white, 100), display=display.none)

fill(p_u3, p_u2, color=color.new(color_bull, 92), title="Outer Blur")
fill(p_u2, p_u1, color=color.new(color_bull, 90), title="Mid Blur")
fill(p_u1, p_ma, color=color.new(color_bull, 88), title="Core Glow")
fill(p_ma, p_d1, color=color.new(color_bear, 88), title="Core Glow")
fill(p_d1, p_d2, color=color.new(color_bear, 90), title="Mid Blur")
fill(p_d2, p_d3, color=color.new(color_bear, 92), title="Outer Blur")

float true_range = ta.tr(true)

is_new_block = (bar_index % step_bars == 0)
var box[] all_profile_boxes = array.new<box>()

if is_new_block and barstate.isconfirmed
    int block_end = bar_index
    int block_start = math.max(0, bar_index - step_bars)
    
    float highest_p = high
    float lowest_p = low
    
    for i = 0 to step_bars - 1
        int idx = math.min(bar_index, block_end - i)
        highest_p := math.max(highest_p, high[bar_index - idx])
        lowest_p := math.min(lowest_p, low[bar_index - idx])

    float step_size = (highest_p - lowest_p) / num_bins
    
    if step_size > 0
        float[] block_vol_weights = array.new<float>(num_bins, 0.0)
        
        for i = 0 to step_bars - 1
            int lookback = i
            float bar_mid = (high[lookback] + low[lookback]) / 2
            int bin_idx = math.min(num_bins - 1, math.floor((bar_mid - lowest_p) / step_size))
            if bin_idx >= 0
                float cur_w = array.get(block_vol_weights, bin_idx)
                float bar_volatility_score = true_range[lookback] * nz(volume[lookback], 1.0)
                array.set(block_vol_weights, bin_idx, cur_w + bar_volatility_score)

        float max_block_weight = 0.0
        for i = 0 to num_bins - 1
            max_block_weight := math.max(max_block_weight, array.get(block_vol_weights, i))

        if max_block_weight > 0
            for i = 0 to num_bins - 1
                float bin_bottom = lowest_p + (i * step_size)
                float bin_top = bin_bottom + step_size
                float raw_weight = array.get(block_vol_weights, i)
                
                int normalized_score = math.round((raw_weight / max_block_weight) * 99 + 1)
                int max_span = math.round(step_bars * 0.7)
                int box_width = math.max(1, math.round((normalized_score / 100.0) * max_span))
                int box_right = block_end
                int box_left = math.max(0, box_right - box_width)

                bool is_tier_4 = (normalized_score >= 80)
                bool is_tier_3 = (normalized_score >= 60 and normalized_score < 80)
                bool is_tier_2 = (normalized_score >= 50 and normalized_score < 60)
                
                color base_col = bin_bottom >= ma_value[0] ? color_bull : color_bear
                color box_col  = is_tier_4 ? color.new(base_col, 20) : 
                                 is_tier_3 ? color.new(base_col, 45) : 
                                 is_tier_2 ? color.new(base_col, 65) : color.new(base_col, 85)
                
                color border_c = color.new(base_col, 100)
                
                box b = box.new(left=box_left, top=bin_top, right=box_right, bottom=bin_bottom, 
                                border_color=border_c, 
                                border_width=1, 
                                bgcolor=box_col)
                array.push(all_profile_boxes, b)

    int max_total_boxes = max_blocks * num_bins
    if array.size(all_profile_boxes) > max_total_boxes
        int excess = array.size(all_profile_boxes) - max_total_boxes
        for j = 0 to excess - 1
            box.delete(array.shift(all_profile_boxes))

var table scale_legend = table.new(position = position.bottom_right, columns = 3, rows = 5, bgcolor = #090d16, border_color = #00f2fe, border_width = 1)
if barstate.islast
    table.cell(scale_legend, 0, 0, "Scale [0-100]", text_color=#00f2fe, text_size=size.small, text_halign=text.align_center)
    table.cell(scale_legend, 1, 0, "Bullish Profile", text_color=#00f2fe, text_size=size.small, text_halign=text.align_center)
    table.cell(scale_legend, 2, 0, "Bearish Profile", text_color=#00f2fe, text_size=size.small, text_halign=text.align_center)
    
    table.cell(scale_legend, 0, 1, "0 - 49", text_color=color.silver, text_size=size.small, text_halign=text.align_center)
    table.cell(scale_legend, 1, 1, "Low Base", text_color=#f8fafc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bull, 85))
    table.cell(scale_legend, 2, 1, "Low Base", text_color=#f8fafc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bear, 85))
    
    table.cell(scale_legend, 0, 2, "50 - 59", text_color=color.silver, text_size=size.small, text_halign=text.align_center)
    table.cell(scale_legend, 1, 2, "Mid-Low", text_color=#f8fafc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bull, 65))
    table.cell(scale_legend, 2, 2, "Mid-Low", text_color=#f8fafc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bear, 65))
    
    table.cell(scale_legend, 0, 3, "60 - 79", text_color=color.silver, text_size=size.small, text_halign=text.align_center)
    table.cell(scale_legend, 1, 3, "Mid-High", text_color=#f8fafc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bull, 45))
    table.cell(scale_legend, 2, 3, "Mid-High", text_color=#f8fafc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bear, 45))
    
    table.cell(scale_legend, 0, 4, "80 - 100 🔥", text_color=#00f2fe, text_size=size.small, text_halign=text.align_center)
    table.cell(scale_legend, 1, 4, "High Energy", text_color=color.white, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bull, 20))
    table.cell(scale_legend, 2, 4, "High Energy", text_color=color.white, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bear, 20))
````
