# Bar HL Distribution [XWiseTrade]

- url: https://www.tradingview.com/script/5ct1j8u1-Bar-HL-Distribution-XWiseTrade/
- type: indicator
- pine_id: PUB;a7d406a191bb4587a13216ae007126d1
- version: 1.0

## Description

Analyze the distribution of High-Low ranges over the last N bars.

This indicator groups candle ranges (in ticks) into bins and displays:
• Count per bin
• Percentage and cumulative %
• Visual histogram bars

Perfect for understanding typical volatility, setting realistic targets/stops, and spotting unusual bar sizes.

Features:
• Adjustable lookback and bin size
• Clean table with truncation warning
• Lightweight and always up-to-date

## Source Code

````pine
//@version=6
indicator("Bar HL Distribution [XWiseTrade]", overlay = false)

int n = input.int(100, title = "Lookback Bars", minval = 1)
int interval_ticks = input.int(5, title = "Interval in Ticks", minval = 1)
const int max_display_bins = 100  // 最大支持显示的bin数量，如果超过会提示

var array<float> hl_ticks_array = array.new<float>(0)

// 计算当前Bar的HL in ticks
float current_hl_ticks = (high - low) / syminfo.mintick
array.push(hl_ticks_array, current_hl_ticks)
if array.size(hl_ticks_array) > n
    array.shift(hl_ticks_array)

// 只在最后一个Bar更新表格
if barstate.islast
    // 找到最大HL和最大bin
    float max_hl = array.max(hl_ticks_array)
    int max_bin = math.floor(max_hl / interval_ticks)
    
    // 如果bin太多，限制显示
    if max_bin >= max_display_bins
        max_bin := max_display_bins - 1
    
    // 计算每个bin的计数
    array<int> bin_counts = array.new<int>(max_bin + 1, 0)
    for i = 0 to array.size(hl_ticks_array) - 1
        float hl = array.get(hl_ticks_array, i)
        int bin = math.floor(hl / interval_ticks)
        if bin <= max_bin
            array.set(bin_counts, bin, array.get(bin_counts, bin) + 1)
    
    // 计算总计数
    int total_count = array.size(hl_ticks_array)
    
    // 找到最大计数，用于缩放histogram
    int max_count = array.max(bin_counts)
    max_count := nz(max_count, 1)
    
    // 创建或更新表格（现在5列：Bin, Count, Percentage, Cumulative, Distribution）
    var table dist_table = table.new(position = position.top_right, columns = 5, rows = max_display_bins + 1, border_width = 1, frame_width = 1)
    
    // 清空表格内容
    for row = 0 to max_display_bins
        table.cell(dist_table, column = 0, row = row, text = "")
        table.cell(dist_table, column = 1, row = row, text = "")
        table.cell(dist_table, column = 2, row = row, text = "")
        table.cell(dist_table, column = 3, row = row, text = "")
        table.cell(dist_table, column = 4, row = row, text = "")
    
    // 设置表头
    table.cell(dist_table, column = 0, row = 0, text = "Bin (ticks)", bgcolor = color.gray, text_color = color.white)
    table.cell(dist_table, column = 1, row = 0, text = "Count", bgcolor = color.gray, text_color = color.white)
    table.cell(dist_table, column = 2, row = 0, text = "Percentage", bgcolor = color.gray, text_color = color.white)
    table.cell(dist_table, column = 3, row = 0, text = "Cumulative", bgcolor = color.gray, text_color = color.white)
    table.cell(dist_table, column = 4, row = 0, text = "Distribution", bgcolor = color.gray, text_color = color.white)
    
    // 填充数据，只显示有计数的bin或所有到max_bin
    float cumulative = 0.0
    for bin = 0 to max_bin
        int count = array.get(bin_counts, bin)
        float percentage = total_count > 0 ? (count / total_count * 100.0) : 0.0
        cumulative += percentage
        string bin_label = str.tostring(bin * interval_ticks) + " - " + str.tostring((bin + 1) * interval_ticks - 1)
        table.cell(dist_table, column = 0, row = bin + 1, text = bin_label)
        table.cell(dist_table, column = 1, row = bin + 1, text = str.tostring(count))
        table.cell(dist_table, column = 2, row = bin + 1, text = str.tostring(percentage, "#.##") + "%")
        table.cell(dist_table, column = 3, row = bin + 1, text = str.tostring(cumulative, "#.##") + "%")
        
        // 计算histogram长度
        int hist_length = math.round(count * 50.0 / max_count)
        if count > 0 and hist_length < 1
            hist_length := 1
        string hist_bar = str.repeat("█", hist_length)
        table.cell(dist_table, column = 4, row = bin + 1, text = hist_bar, bgcolor = color.green, text_color = color.black)
    
    // 如果bin超过限制，显示警告
    if math.floor(max_hl / interval_ticks) >= max_display_bins
        table.cell(dist_table, column = 0, row = max_display_bins, text = "Too many bins, truncated", bgcolor = color.red)
````
