# Seasons percentage (KenshinC)

- url: https://www.tradingview.com/script/qmkPgplE-Seasons-percentage-KenshinC/
- type: indicator
- pine_id: PUB;77fdfd93625644efac009261347b706b
- version: 2.0

## Description

[b]Seasons percentage (KenshinC)[/b]
6 Years Monthly Range AnalysisThis indicator provides a clear and organized overview of Bitcoin's monthly price range percentage (High - Low)/Close over the past 6 years.
[b]Key Features:[/b]
Displays 6 years of monthly statistics side by side in a clean table format (12 columns total)
Each block of 4 columns shows 2 consecutive years for easy comparison
Shows Max %, Min %, and Average % range for every month
Highlights values above or below the yearly average using green (above) and red (below) colors
Includes a "12-Month Average" row for each year with summary statistics
Seasonal background coloring (Summer, Spring, Fall, Winter) based on your chosen hemisphere
Visual markers for February 4th and all historical Bitcoin Halving dates.
[b]How to use:[/b]
Set your desired start year (default: 2021) and number of years (up to 10). The table will automatically adjust to show the data in a well-structured horizontal layout, making it much easier to compare seasonal patterns and volatility across multiple years.Perfect for traders and analysts who want to study Bitcoin’s historical monthly behavior, identify recurring seasonal trends, and better understand market volatility patterns over time.

## Source Code

````pine
//@version=6
indicator(title = "Seasons percentage (KenshinC)", shorttitle = "Seasons", overlay = true)

// ==================== INPUTS ====================
show_summer = input.bool(true,  "Show Summer")
show_spring = input.bool(true,  "Show Spring")
show_winter = input.bool(true,  "Show Winter")
show_fall   = input.bool(true,  "Show Fall")

hemisphere = input.string("Northern", "Current Hemisphere", options = ["Northern", "Southern"])

start_year = input.int(2021, "Start Year", minval = 1900, maxval = 2100)
num_years  = input.int(6,    "Number of Years", minval = 2, maxval = 10, step = 2)

// Table settings
show_table      = input.bool(true, "Show Statistics Table")
table_position  = input.string("top_right", "Table Position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"])
frame_w         = input.int(4, "Table Frame Width", minval = 1, maxval = 6)
border_w        = input.int(2, "Table Border Width", minval = 1, maxval = 3)

// Season colors
summer_color = input.color(color.new(color.red,    75), "Summer Background")
spring_color = input.color(color.new(color.green,  75), "Spring Background")
fall_color   = input.color(color.new(color.yellow, 75), "Fall Background")
winter_color = input.color(color.new(color.gray,   75), "Winter Background")

// ==================== SEASON LOGIC ====================
is_summer = hemisphere == "Northern" ? (month >= 6 and month <= 8) : (month == 12 or month == 1 or month == 2)
is_spring = hemisphere == "Northern" ? (month >= 3 and month <= 5) : (month >= 9 and month <= 11)
is_fall   = hemisphere == "Northern" ? (month >= 9 and month <= 11) : (month >= 3 and month <= 5)
is_winter = hemisphere == "Northern" ? (month == 12 or month == 1 or month == 2) : (month >= 6 and month <= 8)

bgcolor(is_summer and show_summer ? summer_color : na)
bgcolor(is_spring and show_spring ? spring_color : na)
bgcolor(is_fall   and show_fall   ? fall_color   : na)
bgcolor(is_winter and show_winter ? winter_color : na)

// ==================== LINES ====================
show_feb_line = input.bool(true, "Show Feb 4th Line")
show_halving  = input.bool(true, "Show Halving Lines")

if show_feb_line and (month == 2 and dayofmonth == 4)
    line.new(bar_index, low - 10, bar_index, high + 10, color = input.color(color.black, "Feb Line Color"), width = 4)

// Halving dates
halving_dates = array.from(timestamp(2012,11,28), timestamp(2016,7,9), timestamp(2020,5,11), timestamp(2024,4,20), timestamp(2028,5,20), timestamp(2032,4,20), timestamp(2036,5,20), timestamp(2040,4,20), timestamp(2044,5,20), timestamp(2048,4,20))

if show_halving
    for i = 0 to array.size(halving_dates) - 1
        if time >= array.get(halving_dates, i)
            line.new(bar_index, low - 10, bar_index, high + 10, color = color.red, width = 2)

// ==================== STATISTICS CALCULATION ====================
var array<float> yearly_max   = array.new_float(num_years * 12, 0.0)
var array<float> yearly_min   = array.new_float(num_years * 12, 1e10)
var array<float> yearly_sum   = array.new_float(num_years * 12, 0.0)
var array<int>   yearly_count = array.new_int(num_years * 12, 0)

if year >= start_year and year < start_year + num_years
    int y_idx = year - start_year
    int m_idx = month - 1
    int flat_idx = y_idx * 12 + m_idx
    float range_pct = (high - low) / close * 100
    
    int cnt = array.get(yearly_count, flat_idx)
    if cnt == 0
        array.set(yearly_max, flat_idx, range_pct)
        array.set(yearly_min, flat_idx, range_pct)
        array.set(yearly_sum, flat_idx, range_pct)
        array.set(yearly_count, flat_idx, 1)
    else
        array.set(yearly_max, flat_idx, math.max(array.get(yearly_max, flat_idx), range_pct))
        array.set(yearly_min, flat_idx, math.min(array.get(yearly_min, flat_idx), range_pct))
        array.set(yearly_sum, flat_idx, array.get(yearly_sum, flat_idx) + range_pct)
        array.set(yearly_count, flat_idx, cnt + 1)

// ==================== STATISTICS TABLE ====================
var table stats_table = table.new(table_position == "top_right" ? position.top_right : table_position == "top_left" ? position.top_left : table_position == "bottom_right" ? position.bottom_right : table_position == "bottom_left" ? position.bottom_left : position.middle_right, 12, 120, color.new(color.white, 85), border_width = border_w, border_color = color.black, frame_width = frame_w, frame_color = color.black)

if barstate.islast and show_table
    table.clear(stats_table, 0, 0)
    
    array<string> month_names = array.from("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
    
    int blocks = 3
    int rows_per_year = 14
    int current_row = 1
    
    // Block colors siêu nhạt
    var array<color> block_colors = array.new_color(3)
    array.set(block_colors, 0, color.new(color.blue,   92))
    array.set(block_colors, 1, color.new(color.purple, 92))
    array.set(block_colors, 2, color.new(color.orange, 90))
    
    // Headers
    for b = 0 to blocks - 1
        int base = b * 4
        table.cell(stats_table, base,     0, "Year / Month", bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = size.normal)
        table.cell(stats_table, base + 1, 0, "Max %",        bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = size.normal)
        table.cell(stats_table, base + 2, 0, "Min %",        bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = size.normal)
        table.cell(stats_table, base + 3, 0, "Avg %",        bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = size.normal)
    
    for pair = 0 to 1
        int start_row = current_row
        for b = 0 to blocks - 1
            int y = b * 2 + pair
            if y >= num_years
                continue
            int base_col = b * 4
            int r = start_row
            int cur_year = start_year + y
            color block_bg = array.get(block_colors, b)
            
            // Year title
            table.cell(stats_table, base_col, r, "Year " + str.tostring(cur_year), bgcolor = color.new(color.orange, 80), text_halign = text.align_left, text_size = size.normal)
            r += 1
            
            float sum_max = 0.0
            float sum_min = 0.0
            float sum_avg = 0.0
            int valid = 0
            
            for m = 0 to 11
                int idx = y * 12 + m
                int cnt = array.get(yearly_count, idx)
                if cnt > 0
                    valid += 1
                    sum_max += array.get(yearly_max, idx)
                    sum_min += array.get(yearly_min, idx)
                    sum_avg += array.get(yearly_sum, idx) / cnt
            
            float year_avg = valid > 0 ? sum_avg / valid : 0.0
            
            // Months + Data
            for m = 0 to 11
                int idx = y * 12 + m
                int cnt = array.get(yearly_count, idx)
                
                table.cell(stats_table, base_col, r, array.get(month_names, m), 
                           text_size = size.normal, bgcolor = block_bg)
                
                if cnt > 0
                    float maxp = array.get(yearly_max, idx)
                    float minp = array.get(yearly_min, idx)
                    float avgp = array.get(yearly_sum, idx) / cnt
                    
                    color cmax = maxp > year_avg ? color.green : maxp < year_avg ? color.red : color.black
                    color cmin = minp > year_avg ? color.green : minp < year_avg ? color.red : color.black
                    color cavg = avgp > year_avg ? color.green : avgp < year_avg ? color.red : color.black
                    
                    table.cell(stats_table, base_col + 1, r, str.tostring(maxp, "#.##") + "%", text_color = cmax, bgcolor = block_bg)
                    table.cell(stats_table, base_col + 2, r, str.tostring(minp, "#.##") + "%", text_color = cmin, bgcolor = block_bg)
                    table.cell(stats_table, base_col + 3, r, str.tostring(avgp, "#.##") + "%", text_color = cavg, bgcolor = block_bg)
                else
                    table.cell(stats_table, base_col + 1, r, "N/A", text_color = color.gray, bgcolor = block_bg)
                    table.cell(stats_table, base_col + 2, r, "N/A", text_color = color.gray, bgcolor = block_bg)
                    table.cell(stats_table, base_col + 3, r, "N/A", text_color = color.gray, bgcolor = block_bg)
                r += 1
            
            // Average row
            table.cell(stats_table, base_col, r, "12-Month Avg", bgcolor = color.new(color.lime, 80), text_halign = text.align_left)
            if valid > 0
                table.cell(stats_table, base_col + 1, r, str.tostring(sum_max / valid, "#.##") + "%", bgcolor = block_bg)
                table.cell(stats_table, base_col + 2, r, str.tostring(sum_min / valid, "#.##") + "%", bgcolor = block_bg)
                table.cell(stats_table, base_col + 3, r, str.tostring(year_avg, "#.##") + "%", bgcolor = block_bg)
        
        current_row += rows_per_year
````
