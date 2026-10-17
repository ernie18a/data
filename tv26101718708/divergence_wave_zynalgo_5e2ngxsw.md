# DIVERGENCE WAVE [ZynAlgo]

- url: https://www.tradingview.com/script/5e2NGxSw-DIVERGENCE-WAVE-ZynAlgo/
- type: indicator
- pine_id: PUB;1628ab14eeed4d9c838e9460506c7014
- version: 1.0

## Description

[b]Overview[/b]
ZynAlgo DIVERGENCE WAVE is a momentum-divergence oscillator designed to analyze the relationship between directional volume pressure, internal market participation, wave-based delta momentum, and structural exhaustion behavior.
The system transforms buying and selling activity into a smoothed quantitative wave structure called the Divergence Wave. This helps traders identify:
[list]
[*]Hidden market weakness
[*]Buyer or seller exhaustion
[*]Divergence structures
[*]Momentum inefficiencies
[*]Potential reversal regions
[/list]
Unlike traditional RSI or MACD divergence systems, ZynAlgo DIVERGENCE WAVE focuses on the interaction between:
[list]
[*]Price expansion
[*]Delta participation imbalance
[*]Structural wave deterioration
[/list]
This creates an adaptive interpretation of market pressure across trending and volatile environments.
Chart example:
[image]https://www.tradingview.com/x/Q0y4eDQZ/[/image]
[b]Core System Architecture[/b]
The indicator is built around seven major components:
[list=1]
[*]Quantum Delta Wave Engine
[*]Critical Exhaustion Thresholds
[*]Structural Divergence Engine
[*]Premium Oscillator Visualization
[*]Overlay Signal Layer
[*]Metric Dashboard System
[*]Smart Alert Matrix
[/list]
Each component contributes to filtering noise and improving divergence quality.
[b]1. Quantum Delta Wave Engine[/b]
The Quantum Delta Wave Engine is the mathematical core of the system.
It evaluates:
[list]
[*]Bullish participation
[*]Bearish participation
[*]Relative volume dominance
[/list]
Wave engine example:
[image]https://www.tradingview.com/x/Hu5sq4Xe/[/image]
The engine separates volume into two categories:
[b]Bullish Volume[/b]
Volume generated when candles close bullish.
[b]Bearish Volume[/b]
Volume generated when candles close bearish.
The system smooths both streams using EMA calculations to reduce market noise and produce a cleaner flow structure.
The final output becomes the Divergence Wave. This wave represents the current dominance between buyers and sellers.
[b]Wave Interpretation[/b]
[b]Positive Divergence Wave[/b]
[list]
[*]Buyers dominate market participation.
[*]Bullish pressure is increasing.
[*]Market momentum may support continuation.
[/list]
[b]Negative Divergence Wave[/b]
[list]
[*]Sellers dominate market participation.
[*]Bearish pressure is increasing.
[*]Downside pressure becomes stronger.
[/list]
[b]Flattening Wave[/b]
[list]
[*]Participation imbalance weakens.
[*]Trend momentum may be slowing.
[*]Potential transition or consolidation may develop.
[/list]
[b]2. Critical Exhaustion Thresholds[/b]
The system uses two major exhaustion regions:
Threshold example:
[image]https://www.tradingview.com/x/dAQAlEpH/[/image]

## Source Code

````pine
// © ZynAlgo Studio - 2026
// All rights reserved. This source code is proprietary to ZynAlgo.
//@version=6
indicator("DIVERGENCE WAVE [ZynAlgo]", overlay = false, precision = 2, max_labels_count = 500, max_lines_count = 500)

// ---------------------------------------------------------
// COMPONENT 1: MASTER QUANTITATIVE INPUTS
// ---------------------------------------------------------
group_wave    = "1. Quantum Delta Wave Engine"
wave_len      = input.int(20, "Delta Wave Lookback Range", minval = 5, tooltip = "Chu kỳ hồi cứu để tính toán sức mạnh Delta tương đối.")
smooth_len    = input.int(5, "Wave Smoothing Period", minval = 1, tooltip = "Độ mượt hóa cuối cùng của dải sóng.")

group_levels  = "2. Critical Exhaustion Thresholds"
ob_threshold  = input.float(25.0, "Upper Matrix Boundary (OB)", minval = 1.0)
os_threshold  = input.float(-25.0, "Lower Matrix Boundary (OS)", maxval = -1.0)

group_matrix  = "3. Divergence Structural Filter"
min_gap       = input.int(5, "Minimum Pivot Bar Spacing", minval = 2, tooltip = "Số lượng nến tối thiểu giữa 2 đỉnh/đáy để xác nhận phân kỳ.")
show_lines    = input.bool(true, "Render Structural Divergence Lines")
strict_filter = input.bool(true, "Enable Extreme Zone Filter", tooltip = "Bật bộ lọc nâng cao: Chỉ chấp nhận phân kỳ khi sóng nằm sâu trong vùng biên để loại bỏ nhiễu sideway.")

group_palette = "4. Premium Synthwave Display"
theme_bull    = input.color(#00f0ff, "Bullish Quantum (Cyan)", group = group_palette)
theme_bear    = input.color(#ff007f, "Bearish Quantum (Pink)", group = group_palette)
theme_neut    = input.color(#6b7b8f, "Core Grid Baseline", group = group_palette)

group_dash    = "5. System Metric Dashboard"
show_dash     = input.bool(true, "Display Interactive Dashboard", group = group_dash)
dash_pos      = input.string("Top Right", "Dashboard Dashboard Anchor", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = group_dash)
dash_size     = input.string("Small", "Metric Font Scale", options = ["Tiny", "Small", "Normal", "Large"], group = group_dash)

color_void    = color.new(color.white, 100)
text_light    = color.white
text_dark     = color.black

// ---------------------------------------------------------
// COMPONENT 2: CORE WAVE MATHEMATICS
// ---------------------------------------------------------
buy_vol   = close > open ? volume : 0.0
sell_vol  = close < open ? volume : 0.0

smoothed_buy  = ta.ema(buy_vol, wave_len)
smoothed_sell = ta.ema(sell_vol, wave_len)
smoothed_tot  = ta.ema(volume > 0 ? volume : 1, wave_len)

rds_raw    = (smoothed_buy - smoothed_sell) / (smoothed_tot > 0 ? smoothed_tot : 1) * 100
delta_wave = ta.ema(rds_raw, smooth_len)

// Định nghĩa đỉnh đáy sóng kèm bộ lọc vùng biên nâng cao
ob_filter_line = strict_filter ? (ob_threshold * 0.4) : 0.0
os_filter_line = strict_filter ? (os_threshold * 0.4) : 0.0

is_wave_high = delta_wave < delta_wave[1] and delta_wave[1] > delta_wave[2] and delta_wave[1] > ob_filter_line
is_wave_low  = delta_wave > delta_wave[1] and delta_wave[1] < delta_wave[2] and delta_wave[1] < os_filter_line

// ---------------------------------------------------------
// COMPONENT 3: STRUCTURAL DIVERGENCE ENGINE
// ---------------------------------------------------------
var float last_price_high = 0.0
var int   last_price_high_idx = 0
var float last_wave_high = 0.0
var int   last_wave_high_idx = 0

var float last_price_low = 0.0
var int   last_price_low_idx = 0
var float last_wave_low = 0.0
var int   last_wave_low_idx = 0

bool quantum_bear_div = false
bool quantum_bull_div = false

// Logic Phân kỳ Giảm (Bearish Divergence)
if is_wave_high
    if high[1] > last_price_high and delta_wave[1] < last_wave_high and (bar_index[1] - last_price_high_idx) >= min_gap
        quantum_bear_div := true
        if show_lines
            line.new(last_price_high_idx, last_price_high, bar_index[1], high[1], xloc.bar_index, extend.none, theme_bear, line.style_solid, 2, force_overlay = true)
            line.new(last_wave_high_idx, last_wave_high, bar_index[1], delta_wave[1], xloc.bar_index, extend.none, theme_bear, line.style_solid, 2)
    
    last_price_high     := high[1]
    last_price_high_idx := bar_index[1]
    last_wave_high      := delta_wave[1]
    last_wave_high_idx  := bar_index[1]

// Logic Phân kỳ Tăng (Bullish Divergence)
if is_wave_low
    if low[1] < last_price_low and delta_wave[1] > last_wave_low and (bar_index[1] - last_price_low_idx) >= min_gap
        quantum_bull_div := true
        if show_lines
            line.new(last_price_low_idx, last_price_low, bar_index[1], low[1], xloc.bar_index, extend.none, theme_bull, line.style_solid, 2, force_overlay = true)
            line.new(last_wave_low_idx, last_wave_low, bar_index[1], delta_wave[1], xloc.bar_index, extend.none, theme_bull, line.style_solid, 2)

    last_price_low     := low[1]
    last_price_low_idx := bar_index[1]
    last_wave_low      := delta_wave[1]
    last_wave_low_idx  := bar_index[1]

// ---------------------------------------------------------
// COMPONENT 4: PREMIUM OSCILLATOR VISUALIZATION
// ---------------------------------------------------------
plot(0, "System Baseline", color = color.new(theme_neut, 50), style = plot.style_linebr)
plot(ob_threshold, "OB Matrix Level", color = color.new(theme_neut, 80), style = plot.style_linebr)
plot(os_threshold, "OS Matrix Level", color = color.new(theme_neut, 80), style = plot.style_linebr)

wave_color = delta_wave > 0 ? theme_bull : theme_bear
wave_plot  = plot(delta_wave, "DeltaPulse Wave Stream", color = wave_color, linewidth = 2)

fill(wave_plot, plot(0, display = display.none, editable = false),
     top_value    = delta_wave > 0 ? delta_wave : 0,
     bottom_value = delta_wave < 0 ? delta_wave : 0,
     top_color    = delta_wave > 0 ? color.new(theme_bull, 45) : color.new(theme_bull, 100),
     bottom_color = delta_wave < 0 ? color.new(theme_bear, 45) : color.new(theme_bear, 100))

// Điểm chấm tròn báo phân kỳ dưới bảng phụ Osc
plotshape(quantum_bull_div, "Bull Cloud Dot", shape.circle, location.bottom, theme_bull, size = size.tiny, offset = -1)
plotshape(quantum_bear_div, "Bear Cloud Dot", shape.circle, location.top, theme_bear, size = size.tiny, offset = -1)

// ---------------------------------------------------------
// COMPONENT 5: PREMIUM OVERLAY LAYER (Hệ thống Tag độc quyền ZynAlgo)
// ---------------------------------------------------------
// Thay thế hoàn toàn plotshape cũ thành nhãn dán bo góc chuyên nghiệp bám sát nến ở chart chính
if quantum_bull_div
    label.new(bar_index[1], low[1], text="▲", style=label.style_label_up, color=theme_bull, textcolor=text_light, size=size.small, force_overlay=true)

if quantum_bear_div
    label.new(bar_index[1], high[1], text="▼", style=label.style_label_down, color=theme_bear, textcolor=text_light, size=size.small, force_overlay=true)

// Khóa màu nến theo dòng chảy động lượng
barcolor(wave_color)

// ---------------------------------------------------------
// COMPONENT 6: METRIC DASHBOARD SYSTEM
// ---------------------------------------------------------
var table dash_table = na
var string current_div_state = "None"
var color current_div_color = chart.fg_color

if quantum_bull_div
    current_div_state := "Bullish"
    current_div_color := theme_bull
if quantum_bear_div
    current_div_state := "Bearish"
    current_div_color := theme_bear

if show_dash and barstate.islast
    table_anchor = switch dash_pos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

    font_scale = switch dash_size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

    dash_table := table.new(table_anchor, 2, 4, color.new(chart.bg_color, 10), chart.fg_color, 1, chart.fg_color, 1)
    
    table.cell(dash_table, 0, 0, "ZynAlgo Wave", text_color = chart.fg_color, text_size = font_scale, bgcolor = color.new(theme_neut, 80))
    table.cell(dash_table, 1, 0, "Metrics",      text_color = chart.fg_color, text_size = font_scale, bgcolor = color.new(theme_neut, 80))
    
    table.cell(dash_table, 0, 1, "Wave Vector",   text_color = chart.fg_color, text_halign = text.align_left, text_size = font_scale)
    table.cell(dash_table, 1, 1, str.format("{0,number,#.##}", delta_wave), text_color = wave_color, text_size = font_scale)
    
    table.cell(dash_table, 0, 2, "Market Flow",  text_color = chart.fg_color, text_halign = text.align_left, text_size = font_scale)
    table.cell(dash_table, 1, 2, delta_wave > 0 ? "BULLISH" : "BEARISH", text_color = wave_color, text_size = font_scale)
 
    table.cell(dash_table, 0, 3, "Last Pattern", text_color = chart.fg_color, text_halign = text.align_left, text_size = font_scale)
    table.cell(dash_table, 1, 3, current_div_state, text_color = current_div_color, text_size = font_scale)

// ---------------------------------------------------------
// COMPONENT 7: SYSTEM ALERTS MATRIX
// ---------------------------------------------------------
alertcondition(quantum_bull_div, "ZynAlgo Delta: Bullish Divergence", "ZynAlgo Wave Engine: Bullish Divergence Confirmed")
alertcondition(quantum_bear_div, "ZynAlgo Delta: Bearish Divergence", "ZynAlgo Wave Engine: Bearish Divergence Confirmed")
````
