# 4-Year Cycle Seasonal Chart (%)

- url: https://www.tradingview.com/script/C6t4fGHs/
- type: indicator
- pine_id: PUB;a1f33db71af54607b68add4d025fb578
- version: 2.0

## Description

4-Year Cycle Seasonal Chart (%) - Explanation
1. Logic Overview

This indicator is based on the hypothesis that markets move in a "4-year cycle" (an economic and financial cycle often exemplified by the US presidential election cycle).

Data Accumulation: It extracts data for years matching the cycle (e.g., every 4 years) over a specified lookback period. It records and averages daily performance, setting the start of the year (January 1st) as 0%.

Dynamic Calculation: It looks back from a specified base year and calculates the "Average Path" across all relevant years (in this case, every 4 years).

Future Projection: It projects the "expected path" based on historical average data as an orange line, extending from the current data point into the future.

2. Meaning of Each Line

Base Year (Blue) / Previous Year (Yellow) / Past Years (Orange/Red): Each colored line represents a specific year within the 4-year cycle group. By displaying them together, you can determine whether the current year is historically a period with a "strong upward bias" or a period prone to "corrections."

White Line (Current YTD): Represents the year-to-date performance of the current year. By comparing this to the historical average paths (colored lines), you can visually assess whether the asset is currently "stronger than average" (outperforming) or "weaker" (underperforming).

Orange Line (Projection Line): Plots the "average scenario" based on historical statistical data, extending from the current date into the future.


3. Practical Usage Workflow
① Assessing Strength/Weakness Relative to Seasonal Patterns

If the current white line (Current YTD) deviates significantly from the historical averages (colored lines), you can use this information to consider a contrarian trade (betting on mean reversion) or a trend-following trade (confirming the continuation of a strong trend).
By comparing the current year's performance (white line) against the historical lines, you can determine whether the asset is currently showing relative strength or weakness regarding these seasonal patterns. If the white line remains flat during a period where a decline is historically expected (an "anomaly"), it suggests the subsequent rise will be strong; conversely, if the white line remains flat during a period where a rise is expected, it suggests a significant drop will follow.

② Predicting "Seasonal Turning Points"

Within the four-year cycle, if historical anomalies exist—such as a tendency for a market correction around a specific month or a rally beginning around another—this indicator statistically highlights those periods.

Usage Tip: When the daily trend (based on VStop) is about to reverse, use this indicator to check if the timing aligns with historically probable reversal periods; it serves as a filter to increase your confidence in the trade.

③ The Advantage of Multi-Year Display

By displaying data for four years rather than just a single reference year, you can verify the consistency of trends over recent years. For instance, if there is a consistent tendency for prices to rise toward the end of the year across all displayed years, you can confidently extend the holding period for long positions.

4. Operational Tips
Lookback Years Setting: The default setting of "24 years" is suitable for capturing long-term trends. If you feel market conditions have shifted significantly (e.g., a dramatic change in interest rate environments), adjust this to 12 or 8 years to place greater emphasis on more recent cycles.

Market Adaptation: While four-year cycle anomalies are often very pronounced in US stock indices (such as ES or NQ), individual stocks or commodities may exhibit completely different cycles. Adjust the "Base Year" and "Lookback" settings according to the asset class you are trading to identify the cycle configuration that offers the best fit.

This tool is designed to help you grasp the "forest"—market seasonality—rather than focusing on the "trees"—short-term price fluctuations. By combining this with trend analysis from your main chart, you can formulate highly accurate trading strategies.

## Source Code

````pine
//@version=6
indicator("4-Year Cycle Seasonal Chart (%)", overlay=false, max_lines_count=500)

// --- Inputs ---
baseYear = input.int(2026, "Base Year")
lookback = input.int(48, "Lookback Years")
future_bars = input.int(180, "Future Prediction Bars", maxval=500)

// 新規追加：現在の年の表示ON/OFF（デフォルトOff）
show_current = input.bool(false, "Show Current Year YTD")

// 新規追加：除外する年の手動設定と表示オプション
exclude_str = input.string("1929, 1987, 1997, 2000, 2008, 2020", "Excluded Years (comma separated)", tooltip="除外したい年をカンマ区切りで入力してください（例：2008, 2020）")
show_excluded = input.bool(true, "Show Excluded Years Table")

y0 = baseYear
y1 = baseYear - 1
y2 = baseYear - 2
y3 = baseYear - 3

// --- 除外年の配列化処理 ---
var int[] exclude_arr = array.new<int>(0)
if barstate.isfirst
    string[] split_str = str.split(exclude_str, ",")
    for s in split_str
        float num = str.tonumber(str.replace_all(s, " ", ""))
        if not na(num)
            array.push(exclude_arr, int(num))

// --- 除外年表示用テーブル ---
var table ex_table = table.new(position.bottom_right, 1, 2, bgcolor=color.new(color.black, 50), border_width=1, border_color=color.gray)
if barstate.islast and show_excluded
    table.cell(ex_table, 0, 0, "Excluded Years", text_color=color.white, text_size=size.small)
    table.cell(ex_table, 0, 1, exclude_str, text_color=color.red, text_size=size.small)

// --- 日数計算 ---
getDayOfYear(y, m, d) =>
    isLeap = (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)
    int days = d
    if m > 1
        days += 31
    if m > 2
        days += (isLeap ? 29 : 28)
    if m > 3
        days += 31
    if m > 4
        days += 30
    if m > 5
        days += 31
    if m > 6
        days += 30
    if m > 7
        days += 31
    if m > 8
        days += 31
    if m > 9
        days += 30
    if m > 10
        days += 31
    if m > 11
        days += 30
    days

doy = getDayOfYear(year, month, dayofmonth)

// --- データ保持配列 ---
var sum0 = array.new<float>(367, 0.0)
var count0 = array.new<int>(367, 0)
var sum1 = array.new<float>(367, 0.0)
var count1 = array.new<int>(367, 0)
var sum2 = array.new<float>(367, 0.0)
var count2 = array.new<int>(367, 0)
var sum3 = array.new<float>(367, 0.0)
var count3 = array.new<int>(367, 0)

var daily_pct = array.new<float>(367, na)
var float year_open = na

// --- 年替わり時の過去データ集計（空白埋めロジック） ---
if year != year[1]
    int py = year[1]
    bool is_excluded = array.includes(exclude_arr, py)
    
    bool is0 = not na(py) and (py % 4 == y0 % 4) and (py >= y0 - lookback) and (py < y0)
    bool is1 = not na(py) and (py % 4 == y1 % 4) and (py >= y1 - lookback) and (py < y1)
    bool is2 = not na(py) and (py % 4 == y2 % 4) and (py >= y2 - lookback) and (py < y2)
    bool is3 = not na(py) and (py % 4 == y3 % 4) and (py >= y3 - lookback) and (py < y3)
    
    if is0 or is1 or is2 or is3
        int last_doy = doy[1]
        float last_val = daily_pct.get(last_doy)
        if last_doy < 366 and not na(last_val)
            for i = last_doy + 1 to 366
                daily_pct.set(i, last_val)
        
        // 除外対象の年でなければ、平均算出用の配列に加算する
        if not is_excluded
            for i = 1 to 366
                float val = daily_pct.get(i)
                if not na(val)
                    if is0
                        sum0.set(i, sum0.get(i) + val)
                        count0.set(i, count0.get(i) + 1)
                    if is1
                        sum1.set(i, sum1.get(i) + val)
                        count1.set(i, count1.get(i) + 1)
                    if is2
                        sum2.set(i, sum2.get(i) + val)
                        count2.set(i, count2.get(i) + 1)
                    if is3
                        sum3.set(i, sum3.get(i) + val)
                        count3.set(i, count3.get(i) + 1)
                    
    daily_pct.fill(na)
    year_open := open

// --- 現在年の記録 ---
pct_current = na(year_open) ? na : (close - year_open) / year_open * 100
daily_pct.set(doy, pct_current)

if year == year[1] and doy > doy[1] + 1
    for i = doy[1] + 1 to doy - 1
        daily_pct.set(i, daily_pct.get(doy[1]))

// --- 描画（対象年のみに限定） ---
float avg0 = count0.get(doy) > 0 ? sum0.get(doy) / count0.get(doy) : na
float avg1 = count1.get(doy) > 0 ? sum1.get(doy) / count1.get(doy) : na
float avg2 = count2.get(doy) > 0 ? sum2.get(doy) / count2.get(doy) : na
float avg3 = count3.get(doy) > 0 ? sum3.get(doy) / count3.get(doy) : na

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

is_target_year = (year == y0 or year == y1 or year == y2 or year == y3)

// show_current が true の場合のみ現在年のYTDを描画する
plot(show_current and is_target_year ? pct_current : na, "Current Asset YTD (%)", color=color.white, linewidth=2)

plot(year == y0 ? avg0 : na, "Base Year Avg (%)", color=color.blue, linewidth=2)
plot(year == y1 ? avg1 : na, "Prev Year Avg (%)", color=color.yellow, linewidth=2)
plot(year == y2 ? avg2 : na, "2 Years Ago Avg (%)", color=color.orange, linewidth=2)
plot(year == y3 ? avg3 : na, "3 Years Ago Avg (%)", color=color.red, linewidth=2)

// --- 未来予測の描画 ---
if barstate.islast
    int total_days = math.round(future_bars * 1.45)
    float prev_val = na
    int prev_time = na
    for i = 0 to total_days
        int target_time = time + i * 86400000
        int target_doy = (doy + i - 1) % 366 + 1
        int c = count0.get(target_doy)
        float val = c > 0 ? sum0.get(target_doy) / c : na
        
        if na(val)
            val := prev_val
            
        if i == 0
            prev_val := val
            prev_time := target_time
        else if not na(val) and not na(prev_val)
            line.new(x1=prev_time, y1=prev_val, x2=target_time, y2=val, xloc=xloc.bar_time, color=color.orange, width=2)
            prev_val := val
            prev_time := target_time
````
