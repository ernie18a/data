# Geometric Monthly Returns Heatmap

- url: https://www.tradingview.com/script/OsAQHt42-Geometric-Monthly-Returns-Heatmap/
- type: indicator
- pine_id: PUB;530ae62763c349a882757227485e70dc
- version: 1.0

## Description

[b]Overview[/b]
The Geometric Monthly Returns Heatmap is a powerful visual dashboard that breaks down asset performance by month and year. Unlike standard performance tables that only show simple arithmetic sums, this indicator calculates both Geometric and Arithmetic Year-to-Date (YTD) returns side-by-side. This allows traders to see the true compounding impact of monthly gains and losses on their equity.

[b]How It Works & Calculations[/b]
The script initializes a dynamic table in the bottom-right corner of your chart and populates historical data using a localized historical indexing loop:
[list]
[*]Monthly Returns ((m_ret)): Calculated using the closing price of the current month versus the closing price of the previous month: ((close / close[1]) - 1) * 100.
[*]Arithmetic YTD (Ari YTD): The simple linear sum of all monthly returns for that specific year ((sum R_i)).
[*]Geometric YTD (Geo YTD): Reflects the actual compounded return of the asset by converting percentages to multipliers, compounding them, and converting them back: ((prod (1 + R_i) - 1) times 100). This exposes the true dragging effect of large negative months on overall performance.
[/list]

[b]Key Features[/b]
[list]
[*]Dual YTD View: Instantly compare the linear performance against the actual compounded performance.
[*]Smart Data Fetching: Built using request.security arrays to pull precise monthly metrics.
[*]Error Handling: Features a safety check (timeframe.ismonthly) that alerts you to switch to a Monthly chart, ensuring the data arrays map perfectly to the grid.
[*]]Fully Customizable Layout: Change lookback depth and color thresholds instantly via the user input menu.
[/list]

[b]How to Use[/b]
[list=1]
[*]Add the script to your chart.
[*]Crucial: Switch your chart timeframe to Monthly (1M). The script will throw a clear runtime error if used on lower timeframes to prevent data distortion.
[*]Open the script settings to adjust the lookback window (up to 30 years) or modify the positive/negative color heat thresholds to match your chart theme.
[/list]

[b]Disclaimer[/b]
This script is strictly for educational and informational purposes. Past performance, whether geometric or arithmetic, is not a guarantee of future market results. Always apply proper risk management.

## Source Code

````pine
//@version=5
indicator("Geometric Monthly Returns Heatmap", overlay = true)

// Ensure script runs only on Monthly timeframes
if not timeframe.ismonthly
    runtime.error("Please switch timeframe to Monthly")

// --- Inputs ---
int lookback_years = input.int(7, "Years to Display", minval = 1, maxval = 30)
color up_color     = input.color(color.new(#26a69a, 20), "Positive Color")
color dn_color     = input.color(color.new(#ef5350, 20), "Negative Color")
color neutral_color = color.new(color.gray, 80)
color txt_color    = input.color(color.white, "Text Color")
color head_color   = color.gray

// --- Data Fetching ---
// request.security ensures we get monthly data regardless of chart timeframe
[m_open, m_close, m_month, m_year] = request.security(syminfo.tickerid, "M", [open, close, month, year])
//m_ret = ((m_close / m_open) - 1) * 100
m_ret = ((m_close / m_close[1]) - 1) * 100

// Increase buffer to handle historical indexing
max_bars_back(m_ret, 500)

// --- Table Initialization ---
// Columns: Year(0), Jan-Dec(1-12), Geo(13), Ari(14) = 15 columns total
var perf_table = table.new(position.bottom_right, 15, lookback_years + 1, border_width = 1, border_color = color.new(color.gray, 50))

if barstate.islast
    // 1. Headers
    table.cell(perf_table, 0, 0, "Year", bgcolor = head_color, text_color = txt_color)
    month_names = array.from("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
    for i = 0 to 11
        table.cell(perf_table, i + 1, 0, array.get(month_names, i), bgcolor = head_color, text_color = txt_color)
    
    table.cell(perf_table, 13, 0, "Geo YTD", bgcolor = color.rgb(67, 70, 81), text_color = txt_color)
    table.cell(perf_table, 14, 0, "Ari YTD", bgcolor = color.rgb(67, 70, 81), text_color = txt_color)

    // 2. Data Rows
    for y_idx = 0 to lookback_years - 1
        int target_year = year - y_idx
        float year_geo_mult = 1.0     
        float year_ari_sum  = 0.0     
        bool year_has_data  = false

        for target_month = 1 to 12
            // Calculate monthly offset
            int months_back = ((year - target_year) * 12) + (month - target_month)
            
            if months_back >= 0
                float m_val = m_ret[months_back]
                
                // Verify the data belongs to the correct slot
                if m_year[months_back] == target_year and m_month[months_back] == target_month
                    year_has_data := true
                    year_geo_mult *= (1 + m_val / 100)
                    year_ari_sum  += m_val
                    
                    color cell_bg = m_val >= 0 ? up_color : dn_color
                    table.cell(perf_table, target_month, y_idx + 1, str.tostring(m_val, "#.##") + "%", bgcolor = cell_bg, text_color = txt_color)
                else
                    table.cell(perf_table, target_month, y_idx + 1, "-", bgcolor = neutral_color, text_color = txt_color)
            else
                table.cell(perf_table, target_month, y_idx + 1, "-", bgcolor = neutral_color, text_color = txt_color)

        // 3. Finalize Year Summary
        if year_has_data
            float geo_final = (year_geo_mult - 1) * 100
            color geo_color = geo_final >= 0 ? up_color : dn_color
            color ari_color = year_ari_sum >= 0 ? up_color : dn_color
            
            table.cell(perf_table, 0, y_idx + 1, str.tostring(target_year), bgcolor = head_color, text_color = txt_color)
            table.cell(perf_table, 13, y_idx + 1, str.tostring(geo_final, "#.##") + "%", bgcolor = geo_color, text_color = txt_color)
            table.cell(perf_table, 14, y_idx + 1, str.tostring(year_ari_sum, "#.##") + "%", bgcolor = ari_color, text_color = txt_color)
````
