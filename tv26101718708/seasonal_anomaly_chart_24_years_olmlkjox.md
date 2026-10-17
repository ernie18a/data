# Seasonal Anomaly Chart (24 Years) 

- url: https://www.tradingview.com/script/olMlKjox/
- type: indicator
- pine_id: PUB;7f414d121da249d38e13df3621ebdf0d
- version: 1.0

## Description

Seasonal Anomaly Indicator: Overview

This is an advanced analytical tool that extracts the "year-to-date price movement patterns (seasonality)" of a target symbol over the past 24 years (default setting), compares them with the current year's performance, and automatically plots a projected trajectory for the next 180 days—based on historical statistics—onto the right side of the chart (the future space).

While seasonal anomalies are a powerful tool, they do not represent an absolute rule that plays out identically every year. Years marked by macroeconomic shocks (such as sudden interest rate fluctuations or pandemics) can see price action deviate completely from established anomalies.
Therefore, this indicator should not be used in isolation to make trading decisions.
We recommend using it as a filter for market context—providing supporting evidence for your edge—such as entering a trade only when a trend-following signal appears during a period where seasonality suggests an upward move.

Technical Prerequisites:
To ensure accurate data synchronization while bypassing Pine Script's inherent execution limits (such as memory constraints and loop timeouts), this script employs the following design:

1. Flattened Ring Buffer
Since Pine Script limits the dynamic handling of multi-dimensional arrays, this script uses a "flattened index" approach, treating a one-dimensional array like a two-dimensional matrix. It constructs a ring buffer sized for the target number of past years plus one; by using modulo operations to cyclically overwrite data, it maintains a continuous record of the most recent 24 years of data.

2. Absolute Synchronization Based on Trading Days
Synchronizing historical data based on calendar dates (month and day) results in data gaps caused by weekends, holidays, and leap years. This system synchronizes data using the "number of bars elapsed since the start of the year" (*bar_in_year*) as the reference axis. This allows historical cycles to be overlaid without distortion—whether using daily or weekly charts—based purely on actual market trading days. 3. Mathematical Calculation of Volatility
Data for each bar is calculated and normalized in real-time as a percentage change relative to the opening price on the first trading day of the year.


User Manual (Settings and Interpretation)

Step 1: Adjusting Parameters

You can make the following adjustments via the "gear icon (Settings)" next to the indicator name ("Seasonal %") on the chart:
① Historical years (Default: 24):
The number of past years used to calculate the seasonal average. While 24 years is effective for stock indices, you should optimize this by reducing it to "5" or "10" for markets with shorter histories (such as cryptocurrency) or to align with the current market regime (market environment).
② Number of future bars for the forecast (Default: 180):
The length of the forecast line drawn in the empty space to the right of the chart.
③ Color settings:
Colors can be changed to ensure visibility against the chart's background color.

Step 2: How to Read the Chart

The indicator displays four elements:
① Gray dotted line (Zero Line):
The baseline (0%) representing the start of the year (as of January 1st).
② Orange solid line (Historical Average):
The average performance (anomaly) over the past 24 years. It indicates statistical tendencies, such as periods when prices are likely to rise or fall.
③ White solid line (Current Year's Performance):
The actual price movement (%) for the current year. By observing the divergence between the historical average (orange) and the current year (white), you can relatively assess whether the market is stronger or weaker than usual.
④ Orange dotted line (Future Forecast):
A future projection based on the historical average, drawn in the empty space to the right of the current bar. Use this to gauge potential profit-taking points or to predict trend reversal timings.

## Source Code

````pine
//@version=6
indicator("Seasonal Anomaly Chart (24 Years) with Forecast", shorttitle="Seasonal %", overlay=false, format=format.percent, precision=2)

// ============================================================================
// [Inputs] 入力パラメータ
// ============================================================================
grp_main = "シーズナル設定"
int lookback_years = input.int(24, title="過去の対象年数", minval=1, maxval=50, group=grp_main, tooltip="シーズナル平均を算出するための過去の年数です。")
color col_seasonal = input.color(color.new(color.orange, 0), title="シーズナルライン（過去平均）", group=grp_main)
color col_current  = input.color(color.new(color.white, 0), title="現在の年の推移", group=grp_main)

grp_fcast = "未来予測（フォワード・プロジェクション）設定"
int forecast_bars  = input.int(180, title="予測を描画する未来のバー数", minval=0, maxval=300, group=grp_fcast)
color col_forecast = input.color(color.new(color.orange, 30), title="予測ラインの色", group=grp_fcast)

// ============================================================================
// [Calculations] 計算とデータ構造の初期化
// ============================================================================
// 1年間の最大足数（仮想通貨や休場を含まない市場にも対応するため余裕を持たせる）
int MAX_BARS_PER_YEAR = 400

// リングバッファのサイズ（現在の年 + 過去の対象年数）
int BUFFER_YEARS = lookback_years + 1 
int TOTAL_BUFFER_SIZE = BUFFER_YEARS * MAX_BARS_PER_YEAR

// 過去のデータを保持するフラット化リングバッファ
var float[] history_data = array.new_float(TOTAL_BUFFER_SIZE, na)

var int current_year = na
var float year_open = na
var int bar_in_year = 0

// 年初（その年の最初の足）の判定
bool is_new_year = year(time) != year(time[1])

if is_new_year
    current_year := year(time)
    year_open := open  // その年の最初の取引日の始値を基準(0%)とする
    bar_in_year := 0
else
    bar_in_year += 1

// 現在の足の変化率の算出 (%)
float pct_change = na
if not na(year_open) and year_open != 0
    pct_change := (close / year_open - 1.0) * 100.0

// データ異常（極端なエラー値等）のフィルタリング
bool is_valid_data = not na(pct_change) and math.abs(pct_change) < 10000

// 現在の年のデータをリングバッファに格納
if is_valid_data and bar_in_year < MAX_BARS_PER_YEAR
    int year_idx = current_year % BUFFER_YEARS
    int flat_idx = (year_idx * MAX_BARS_PER_YEAR) + bar_in_year
    array.set(history_data, flat_idx, pct_change)

// ============================================================================
// [Conditions] シーズナル（過去平均）の算出
// ============================================================================
float seasonal_avg = na
float sum = 0.0
int count = 0

// 現在の足までの過去平均を計算
if bar_in_year < MAX_BARS_PER_YEAR
    for i = 1 to lookback_years
        int past_year = current_year - i
        int y_idx = past_year % BUFFER_YEARS
        
        // マイナスインデックスの調整
        if y_idx < 0
            y_idx += BUFFER_YEARS
            
        int flat_idx = (y_idx * MAX_BARS_PER_YEAR) + bar_in_year
        float val = array.get(history_data, flat_idx)
        
        if not na(val)
            sum += val
            count += 1

    if count > 0
        seasonal_avg := sum / count

// ============================================================================
// [Plots/Orders] 描画と未来予測（プロジェクション）
// ============================================================================
// 基準となる0%ライン
hline(0, title="Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// 現在までの過去平均と今年の推移をプロット
plot(seasonal_avg, title="Seasonal Anomaly (Avg)", color=col_seasonal, linewidth=2)
plot(pct_change, title="Current Year %", color=col_current, linewidth=1)

// --- 未来予測ラインの描画処理 ---
// 未来のラインオブジェクトを保持する配列
var line[] forecast_lines = array.new_line()

// チャートの最新の足（リアルタイム更新含む）でのみ実行
if barstate.islast and forecast_bars > 0
    
    // リアルタイムティック毎の重複描画を防ぐため、前回のティックで描画した予測線を全て削除
    if array.size(forecast_lines) > 0
        while array.size(forecast_lines) > 0
            line.delete(array.pop(forecast_lines))
            
    float prev_val = seasonal_avg // 線の始点（現在の足のシーズナル平均値）
    
    // 指定されたバー数先までループ処理
    for i = 1 to forecast_bars
        int target_biy = bar_in_year + i
        
        // 1年間の最大足数を超えた場合は描画を終了
        if target_biy >= MAX_BARS_PER_YEAR
            break
            
        float f_sum = 0.0
        int f_count = 0
        
        // ターゲットとなる未来の日の過去平均を算出
        for y = 1 to lookback_years
            int past_year = current_year - y
            int y_idx = past_year % BUFFER_YEARS
            if y_idx < 0
                y_idx += BUFFER_YEARS
                
            int flat_idx = (y_idx * MAX_BARS_PER_YEAR) + target_biy
            float val = array.get(history_data, flat_idx)
            
            if not na(val)
                f_sum += val
                f_count += 1
                
        // データが存在すれば未来の空間へ線を引く
        if f_count > 0
            float curr_val = f_sum / f_count
            
            if not na(prev_val)
                // 【修正箇所】line.style_dot を line.style_dotted に変更
                line ln = line.new(x1=bar_index + i - 1, y1=prev_val, x2=bar_index + i, y2=curr_val, color=col_forecast, style=line.style_dotted, width=2)
                array.push(forecast_lines, ln)
                
            prev_val := curr_val
        else
            break // 過去のデータが途切れた場合は終了
````
