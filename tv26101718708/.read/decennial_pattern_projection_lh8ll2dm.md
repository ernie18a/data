# Decennial Pattern Projection

- url: https://www.tradingview.com/script/lH8ll2Dm/
- type: indicator
- pine_id: PUB;a9b049613f64437ba19fcc51c3bef53c
- version: 1.0

## Description

This tool was created to map out a "blueprint" for future market movements based on historical cycles.

**Important Prerequisite: Monthly Timeframe Only**

First and foremost, this indicator is designed exclusively for **monthly charts**.
If applied to other timeframes—such as daily or weekly charts—it is programmed to intentionally stop functioning and display an error message ("This indicator requires a Monthly timeframe") to prevent coordinate misalignment or redundant data calculations. Please ensure you use it only on monthly charts.

**Indicator Overview and Usage**
This indicator extracts the "10-year cycle pattern"—a classic market anomaly where performance trends align based on the last digit of the calendar year. It then plots a projected future trajectory—showing the "average year-to-date (YTD) movement (%)"—directly onto the chart for the specified year (and the following year).

**Practical Trading Applications**
**Grasping Broad Seasonality**
You can visually identify seasonal rhythms—such as which months tend to mark market bottoms or whether prices often weaken in early autumn—for years ending in a specific digit. This helps reduce the risk of unnecessary contrarian trades and allows you to formulate trading plans that align with historical capital flow patterns.

**Can it be used for entry and exit timing?**
This line does not generate direct buy/sell signals (such as arrows). However, it serves as a tool to gauge market strength and inform strategy when seasonal patterns are pronounced—such as considering long positions during "statistically strong months" or lightening positions (or switching to short strategies) during "weak months." It also helps you determine if the market is deviating from the anomaly due to specific, overriding biases.

**Improving Accuracy by Excluding "Black Swan" Events**
If you believe that outlier data from specific years—such as the 2008 Lehman Shock or the 2020 COVID-19 crash—is skewing the average, you can exclude those years via the settings. As this is a matter of individual judgment, one might choose not to exclude it if one views it as an inevitable occurrence aligned with cycles of debt or similar obligations.

## Source Code

````pine
//@version=6
indicator("Decennial Pattern Projection", overlay=false, format=format.percent)

// =========================================================================
// [Inputs] セクション: ユーザー設定 (UIは英語、コメントは日本語)
// =========================================================================
sym_input       = input.symbol("TVC:DJI", title="Symbol")
target_year     = input.int(2026, title="Target Year", minval=1900)
lookback_years  = input.int(70, title="Lookback Period (Years)", minval=10)
exclude_str     = input.string("", title="Exclude Years (comma-separated, e.g., 2008, 2020)")
show_next_year  = input.bool(true, title="Show Next Year (+1) Projection")

// =========================================================================
// [Calculations] セクション: 前提条件とデータ取得
// =========================================================================
if not timeframe.ismonthly
    runtime.error("This indicator requires a Monthly timeframe.") // エラーメッセージも英語化

[d_open, d_close, d_year, d_month] = request.security(sym_input, "1M", [open, close, year(time), month(time)])

// 除外年文字列の配列化
var int[] exclude_arr = array.new_int()
if barstate.isfirst and exclude_str != ""
    string[] str_arr = str.split(exclude_str, ",")
    if array.size(str_arr) > 0
        for i = 0 to array.size(str_arr) - 1
            float parsed_num = str.tonumber(str.trim(array.get(str_arr, i)))
            if not na(parsed_num)
                array.push(exclude_arr, int(math.round(parsed_num)))

// 集計用配列の初期化（基準年用と翌年用）
var float[] sum_y1   = array.new_float(12, 0.0)
var int[]   count_y1 = array.new_int(12, 0)
var float[] sum_y2   = array.new_float(12, 0.0)
var int[]   count_y2 = array.new_int(12, 0)

// 各年の1月始値を記憶（年が変わるたびにリセット）
var float jan_open = na
if d_year != d_year[1]
    jan_open := na
if not na(d_month) and d_month == 1
    jan_open := d_open

// 過去データの集計処理
if d_year >= target_year - lookback_years and d_year < target_year
    if not array.includes(exclude_arr, d_year) and not na(jan_open) and not na(d_close) and not na(d_month)
        float ytd_return = ((d_close - jan_open) / jan_open) * 100
        int m_idx = d_month - 1
        
        // 基準年と同じ下一桁の場合 (例: 2026年なら "6")
        if d_year % 10 == target_year % 10
            array.set(sum_y1, m_idx, array.get(sum_y1, m_idx) + ytd_return)
            array.set(count_y1, m_idx, array.get(count_y1, m_idx) + 1)
            
        // 翌年と同じ下一桁の場合 (例: 2027年なら "7")
        if d_year % 10 == (target_year + 1) % 10
            array.set(sum_y2, m_idx, array.get(sum_y2, m_idx) + ytd_return)
            array.set(count_y2, m_idx, array.get(count_y2, m_idx) + 1)

// =========================================================================
// [Plots/Displays] セクション: 未来へのライン描画 (line.new)
// =========================================================================
// チャートの最後のバーに到達した時点で、計算済みの平均値を使って未来の空間に線を引く
if barstate.islast
    // 各月の平均値を計算
    float[] avg_y1 = array.new_float(12, na)
    float[] avg_y2 = array.new_float(12, na)
    for i = 0 to 11
        if array.get(count_y1, i) > 0
            array.set(avg_y1, i, array.get(sum_y1, i) / array.get(count_y1, i))
        if array.get(count_y2, i) > 0
            array.set(avg_y2, i, array.get(sum_y2, i) / array.get(count_y2, i))

    // 基準年のライン描画 (青色)
    for i = 0 to 10
        float val1 = array.get(avg_y1, i)
        float val2 = array.get(avg_y1, i+1)
        if not na(val1) and not na(val2)
            // 描画位置を各月の15日に設定（月足チャートの中央に配置するため）
            int t1 = timestamp(syminfo.timezone, target_year, i+1, 15, 0, 0, 0)
            int t2 = timestamp(syminfo.timezone, target_year, i+2, 15, 0, 0, 0)
            line.new(x1=t1, y1=val1, x2=t2, y2=val2, xloc=xloc.bar_time, color=color.new(#2962FF, 0), width=2)

    // 翌年のライン描画 (オレンジ色)
    if show_next_year
        for i = 0 to 10
            float val1 = array.get(avg_y2, i)
            float val2 = array.get(avg_y2, i+1)
            if not na(val1) and not na(val2)
                int t1 = timestamp(syminfo.timezone, target_year + 1, i+1, 15, 0, 0, 0)
                int t2 = timestamp(syminfo.timezone, target_year + 1, i+2, 15, 0, 0, 0)
                line.new(x1=t1, y1=val1, x2=t2, y2=val2, xloc=xloc.bar_time, color=color.new(#FF6D00, 0), width=2)

// =========================================================================
// オートスケール用の非表示プロット（インジケーターの縦軸を自動調整させるための工夫）
// =========================================================================
float dummy_scale = na
if d_year == target_year and not na(d_month)
    if array.get(count_y1, d_month - 1) > 0
        dummy_scale := array.get(sum_y1, d_month - 1) / array.get(count_y1, d_month - 1)
plot(dummy_scale, title="Auto Scale Helper", color=color.new(color.black, 100))
````
