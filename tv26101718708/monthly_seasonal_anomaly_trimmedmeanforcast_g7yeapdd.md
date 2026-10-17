# Monthly Seasonal Anomaly (TrimmedMean,forcast)

- url: https://www.tradingview.com/script/G7yEapDD/
- type: indicator
- pine_id: PUB;ce33b434e13a4059b81e2f4003824096
- version: 1.0

## Description

When analyzing seasonality, the issue of "outlier years" inevitably arises.
As a potential solution, I have utilized a trimmed mean approach.
While the reference values ​​are still under consideration, I have designed the parameters to be fully customizable, and I hope this proves useful for your research.

・Indicator Overview
This script is a projection tool that extracts "monthly price fluctuation seasonality" from historical market data and plots a predicted trajectory for the next three months. Unlike a simple historical average, it features "cross-filtering" capabilities that automatically detect and exclude macroeconomic outliers (years marked by extreme crashes or surges).

・Core Architecture (Trimming Mechanism)
Instead of a standard "trimmed mean," this indicator incorporates a "cross-filtering" logic (annual assessment followed by monthly exclusion).

1. Rationale for Annual Exclusion
Consider a scenario where the market experienced a historic crash in October 2008 (the Lehman Shock). If this were included in the monthly average as an "October anomaly" (implying a general tendency for prices to fall in October), it would significantly distort statistics based on normal market conditions. This is because the event represents an "annual anomaly" rather than a "monthly anomaly."

2. Two-Step Trimming Process
The indicator eliminates noise through the following process:

Phase 1 (Identifying Anomaly Years):
First, the script calculates the "Year-to-Date (YTD) rate of change" for each year in the background and ranks them. Based on a configurable percentage (default: 10%), it identifies years with extreme gains (Top) and extreme losses (Bottom) and adds them to an "Excluded Years" list.

Phase 2 (Refined Monthly Calculation):
When calculating monthly seasonality (e.g., the March anomaly), any years blacklisted during Phase 1 are skipped in the calculation. This approach aims to isolate "pure seasonality" observed during normal market conditions.
You can verify exactly which years were excluded by checking the information table at the bottom right.

3. Compounding Chain Across Months
For the forecast line covering the next three months, we have moved away from simply connecting the monthly averages.
Instead, we use the "projected closing level for the current month" as a baseline and apply a compounding calculation using the "seasonal average rate of change" for the following month. This method differs from the calculation used for historical bars; it eliminates discontinuities at month-end transitions, resulting in a smooth projection line that flows continuously from the current price into the future.

・Intended Use Cases
Use Case 1: Trend-Following Market Context Analysis (Reinforcing Your Edge)
The seasonal line serves as a filter to gauge the "underlying market sentiment."
For example, suppose your primary trading strategy involves buying on a MACD "golden cross." If the future forecast line indicates a "gradual upward trend over the next two months," this provides additional support for your decision. Conversely, if the data shows that "next month is historically prone to a deep correction," you can use this as a risk management filter—deciding, for instance, to skip the trade or halve your position size.

Use Case 2: Swing Trading – Profit Taking and Position Adjustment
Since the tool plots a projection for the next three months, it offers a guideline on "how long to hold a position for a statistical advantage."
If you hold a long position and the forecast line traces an arc that "peaks between the latter half of the current month and the early part of the next month before declining," you can plan to take profits in stages (scaling out) as the price approaches that peak.

Use Case 3: Detecting Divergence from Current Market Action (Breakdown of Anomalies)
By enabling the "Show Current Month Line" setting, the actual price movement for the current year is overlaid as a white line. If there is a significant divergence between the historical average during normal market conditions (orange line) and this year's trend (white line), it provides a crucial insight: the market has entered a regime—or trading environment—where the usual seasonal cycle no longer applies. This serves as a basis for deciding to switch from a seasonal strategy to an alternative approach, such as a momentum breakout strategy.

A note on parameter adjustment:
The number of trading days varies depending on the market in question (e.g., stock indices, commodities, or cryptocurrencies). By adjusting the "Bars per Month (Days)" setting—typically to around 21 for stocks and forex, or 30 for cryptocurrencies—you can more accurately align the X-axis (time axis) of the future projection line with the chart.

## Source Code

````pine
//@version=6
// 未来予測の線オブジェクトを多数描画するため、max_lines_countを拡張しています
indicator("Monthly Seasonal Anomaly (TrimmedMean,forcast)", shorttitle="Monthly Seasonal %", overlay=false, format=format.percent, precision=2, max_lines_count=500)

// ============================================================================
// [Inputs] 入力パラメータ
// ============================================================================
grp_main = "Seasonal Settings"
int lookback_years = input.int(24, title="Lookback Years", minval=1, maxval=50, group=grp_main)
color col_seasonal = input.color(color.new(color.orange, 0), title="Seasonal Line (Historical Avg)", group=grp_main)

// 【修正箇所】現在の月のラインの表示/非表示を切り替えるトグルを追加（デフォルト: false）
bool show_current  = input.bool(false, title="Show Current Month Line", group=grp_main, tooltip="現在の月の推移（Current Month %）の表示・非表示を切り替えます。")
color col_current  = input.color(color.new(color.white, 0), title="Current Month Line Color", group=grp_main)

grp_filter = "Filtering Settings"
float trim_percent = input.float(10.0, title="Trim Percentage (%)", minval=0.0, maxval=40.0, step=5.0, group=grp_filter, tooltip="年初からの変化率を基準に異常な年を特定し、月間計算から除外します。")
bool show_table    = input.bool(true, title="Show Excluded Years Table", group=grp_filter)

grp_fcast = "Forward Projection Settings"
int forecast_months = input.int(3, title="Forecast Months", minval=1, maxval=6, group=grp_fcast, tooltip="何ヶ月先まで予測ラインを描画するかを指定します。")
int bars_per_month  = input.int(21, title="Bars per Month (Days)", minval=5, maxval=31, group=grp_fcast, tooltip="1ヶ月の平均営業日数です。株や為替は21、仮想通貨は30を目安にしてください。")
color col_forecast  = input.color(color.new(color.orange, 30), title="Forecast Line Color", group=grp_fcast)

// ============================================================================
// [Calculations] 計算とデータ構造の初期化
// ============================================================================
int MAX_BARS_PER_YEAR  = 400
int MAX_BARS_PER_MONTH = 40
int BUFFER_YEARS       = lookback_years + 1 

int TOTAL_BUFFER_SIZE_YEAR  = BUFFER_YEARS * MAX_BARS_PER_YEAR
int TOTAL_BUFFER_SIZE_MONTH = 12 * BUFFER_YEARS * MAX_BARS_PER_MONTH

var float[] history_year_pct  = array.new_float(TOTAL_BUFFER_SIZE_YEAR, na)
var float[] history_month_pct = array.new_float(TOTAL_BUFFER_SIZE_MONTH, na)

var int current_year = na
var float year_open  = na
var int bar_in_year  = 0
var float month_open = na
var int bar_in_month = 0

bool is_new_year  = year(time) != year(time[1])
bool is_new_month = month(time) != month(time[1])

if is_new_year
    current_year := year(time)
    year_open    := open
    bar_in_year  := 0
else
    bar_in_year += 1

if is_new_month
    month_open   := open
    bar_in_month := 0
else
    bar_in_month += 1

int m_idx = month(time) - 1
int year_idx = current_year % BUFFER_YEARS

float pct_change_y = na
float pct_change_m = na

if not na(year_open) and year_open != 0
    pct_change_y := (close / year_open - 1.0) * 100.0
if not na(month_open) and month_open != 0
    pct_change_m := (close / month_open - 1.0) * 100.0

if not na(pct_change_y) and math.abs(pct_change_y) < 10000 and bar_in_year < MAX_BARS_PER_YEAR
    int flat_idx_y = (year_idx * MAX_BARS_PER_YEAR) + bar_in_year
    array.set(history_year_pct, flat_idx_y, pct_change_y)

if not na(pct_change_m) and math.abs(pct_change_m) < 10000 and bar_in_month < MAX_BARS_PER_MONTH
    int flat_idx_m = (m_idx * BUFFER_YEARS * MAX_BARS_PER_MONTH) + (year_idx * MAX_BARS_PER_MONTH) + bar_in_month
    array.set(history_month_pct, flat_idx_m, pct_change_m)

// ============================================================================
// [Conditions] クロス・フィルタリング（年間判定 → 月間除外）
// ============================================================================
var float[] y_vals = array.new_float()
var int[] y_years  = array.new_int()
var int[] excluded_years = array.new_int()

array.clear(y_vals)
array.clear(y_years)
array.clear(excluded_years)

var string[] top_trimmed_years = array.new_string()
var string[] bot_trimmed_years = array.new_string()
array.clear(top_trimmed_years)
array.clear(bot_trimmed_years)

if bar_in_year < MAX_BARS_PER_YEAR
    for i = 1 to lookback_years
        int past_year = current_year - i
        int y_i = past_year % BUFFER_YEARS
        if y_i < 0
            y_i += BUFFER_YEARS
        int flat_idx_y = (y_i * MAX_BARS_PER_YEAR) + bar_in_year
        float val_y = array.get(history_year_pct, flat_idx_y)
        if not na(val_y)
            array.push(y_vals, val_y)
            array.push(y_years, past_year)

    int sz = array.size(y_vals)
    if sz > 0
        int[] sorted_indices = array.sort_indices(y_vals)
        int trim_count = int(math.round(sz * (trim_percent / 100.0)))
        if trim_count * 2 >= sz
            trim_count := int(math.floor((sz - 1) / 2))
            
        if trim_count > 0
            for i = 0 to trim_count - 1
                int bot_idx = array.get(sorted_indices, i)
                int bot_year = array.get(y_years, bot_idx)
                array.push(excluded_years, bot_year)
                if barstate.islast
                    array.push(bot_trimmed_years, str.tostring(bot_year))
                    
                int top_idx = array.get(sorted_indices, sz - 1 - i)
                int top_year = array.get(y_years, top_idx)
                array.push(excluded_years, top_year)
                if barstate.islast
                    array.push(top_trimmed_years, str.tostring(top_year))

float seasonal_avg = na
float sum = 0.0
int count = 0

if bar_in_month < MAX_BARS_PER_MONTH
    for i = 1 to lookback_years
        int past_year = current_year - i
        if not array.includes(excluded_years, past_year)
            int y_i = past_year % BUFFER_YEARS
            if y_i < 0
                y_i += BUFFER_YEARS
            int flat_idx_m = (m_idx * BUFFER_YEARS * MAX_BARS_PER_MONTH) + (y_i * MAX_BARS_PER_MONTH) + bar_in_month
            float val_m = array.get(history_month_pct, flat_idx_m)
            if not na(val_m)
                sum += val_m
                count += 1
                
    if count > 0
        seasonal_avg := sum / count

// ============================================================================
// [Plots/Orders] 描画・3ヶ月未来予測チェーン
// ============================================================================
hline(0, title="Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

plot(seasonal_avg, title="Monthly Seasonal (Filtered)", color=col_seasonal, linewidth=2)

// 【修正箇所】チェックボックスがOnの場合のみデータをプロットし、Offの場合はna（非表示）とする
plot(show_current ? pct_change_m : na, title="Current Month %", color=col_current, linewidth=1)

var line[] forecast_lines = array.new_line()
var float[] f_temp_vals = array.new_float()

// --- 複数月チェーン予測処理 ---
if barstate.islast
    if array.size(forecast_lines) > 0
        while array.size(forecast_lines) > 0
            line.delete(array.pop(forecast_lines))
            
    float current_plot_y = seasonal_avg
    float base_cumulative = 0.0
    int x_offset = 1
    
    // m_step = 0(当月残り), 1(翌月), 2(翌々月), 3(3ヶ月後)
    for m_step = 0 to forecast_months
        int target_m_idx = (m_idx + m_step) % 12
        
        // 当月(m_step=0)は現在の足の次から、翌月以降は0(月初)から描画
        int start_bar = (m_step == 0) ? (bar_in_month + 1) : 0
        int end_bar = bars_per_month - 1
        float month_final_val = na
        
        if start_bar <= end_bar
            for b = start_bar to end_bar
                array.clear(f_temp_vals)
                
                // 過去データの抽出
                for y = 1 to lookback_years
                    int past_year = current_year - y
                    if not array.includes(excluded_years, past_year)
                        int y_i = past_year % BUFFER_YEARS
                        if y_i < 0
                            y_i += BUFFER_YEARS
                        int flat_idx_m = (target_m_idx * BUFFER_YEARS * MAX_BARS_PER_MONTH) + (y_i * MAX_BARS_PER_MONTH) + b
                        float val_m = array.get(history_month_pct, flat_idx_m)
                        if not na(val_m)
                            array.push(f_temp_vals, val_m)
                            
                int f_sz = array.size(f_temp_vals)
                if f_sz > 0
                    array.sort(f_temp_vals)
                    int f_trim_count = int(math.round(f_sz * (trim_percent / 100.0)))
                    if f_trim_count * 2 >= f_sz
                        f_trim_count := int(math.floor((f_sz - 1) / 2))
                        
                    float f_sum = 0.0
                    int f_count = 0
                    for j = f_trim_count to (f_sz - 1 - f_trim_count)
                        f_sum += array.get(f_temp_vals, j)
                        f_count += 1
                        
                    if f_count > 0
                        float f_avg = f_sum / f_count
                        float projected_y = na
                        
                        // 複利計算で月またぎを滑らかに連結
                        if m_step == 0
                            projected_y := f_avg
                        else
                            projected_y := ((1.0 + base_cumulative / 100.0) * (1.0 + f_avg / 100.0) - 1.0) * 100.0
                            
                        if not na(current_plot_y) and not na(projected_y)
                            line ln = line.new(x1=bar_index + x_offset - 1, y1=current_plot_y, x2=bar_index + x_offset, y2=projected_y, color=col_forecast, style=line.style_dotted, width=2)
                            array.push(forecast_lines, ln)
                            
                        current_plot_y := projected_y
                        month_final_val := projected_y
                        x_offset += 1
                        
        // その月の終値を、翌月計算のためのベース値（オフセット）として記録
        if not na(month_final_val)
            base_cumulative := month_final_val

// --- 除外された年の情報テーブル描画 ---
var table trim_table = table.new(position.bottom_right, 2, 2, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)

if barstate.islast and show_table
    string top_str = array.size(top_trimmed_years) > 0 ? array.join(top_trimmed_years, ", ") : "None"
    string bot_str = array.size(bot_trimmed_years) > 0 ? array.join(bot_trimmed_years, ", ") : "None"
    
    table.cell(trim_table, 0, 0, "Excl. Year (High)", text_color=color.white, bgcolor=color.new(color.red, 50), text_size=size.small)
    table.cell(trim_table, 1, 0, "Excl. Year (Low)", text_color=color.white, bgcolor=color.new(color.blue, 50), text_size=size.small)
    table.cell(trim_table, 0, 1, top_str, text_color=color.white, text_size=size.small)
    table.cell(trim_table, 1, 1, bot_str, text_color=color.white, text_size=size.small)
````
