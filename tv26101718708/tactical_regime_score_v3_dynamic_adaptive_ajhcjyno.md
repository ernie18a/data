# Tactical Regime Score v3 (Dynamic Adaptive)

- url: https://www.tradingview.com/script/AJHcjyno-Tactical-Regime-Score-v3-Dynamic-Adaptive/
- type: indicator
- pine_id: PUB;6a3ce233e09641df90d66b3505ed42c6
- version: 1.0

## Description

Quant-Grade Market Regime Classification Engine
1. Executive Summary
Market "Regime" is the most critical yet often misunderstood variable in trading. Applying a trending strategy to a mean-reverting market is a mathematical death sentence. The Tactical Regime Score v3 (Dynamic Adaptive) is an institutional-grade tool that utilizes the Augmented Dickey-Fuller (ADF) Test logic to classify price action into two distinct physical states: Mean Reversion (Stationary) and Trending/Random Walk (Non-Stationary).

2. The Engine: How it Works
Unlike retail indicators that rely on lagged moving averages, this engine uses Ordinary Least Squares (OLS) Regression to calculate a normalized ADF-style statistic in real-time.

Stationarity Detection: It measures the "slope" of price changes relative to their lagged values. A negative slope indicates that price has a "restoring force" pulling it back to a mean (Stationarity).

Dynamic Adaptive Thresholding: Static thresholds are a "Retail Trap." Markets evolve; a stationary state in a low-volatility period looks different than one in a high-volatility period. This script uses Linear Interpolation Percentiles over a 500-bar lookback to determine a relative threshold for "restoring force," making it self-adjusting to current market conditions.

3. Key Features
Regime-Colorized Columns:

Green (Mean Reversion): The price is mathematically stationary. Statistical arbitrage and mean-reversion strategies (Oscillators, Mean Reversion Levels) are favored.

Red (Trending/Random): Price is non-stationary. Directional momentum or "Random Walk" dominates. Trend-following logic or breakout strategies are favored.

HV-Percentile Scoring: The height of the columns represents the Historical Volatility (HV) Percentile. A high score in a Red regime indicates a high-conviction trend; a high score in a Green regime indicates an overextended mean-reversion move.

Real-time Dashboard: Displays the raw ADF value, the current dynamic threshold, and the finalized Tactical Score for immediate situational awareness.

4. Tactical SOP (How to use)
Regime Filter: Check the column color before entering a trade.

If Green, do not chase breakouts; look for "Rubber Band" snaps back to the POC.

If Red, do not attempt to "pick tops" or "pick bottoms"; follow the momentum.

Confidence Check: * Score > 75 (High Confidence): Strong physical regime. Expect the current behavior (Trending or Reverting) to persist.

Score < 25 (Low Confidence): "Dead Zone." Market is indecisive. Market makers are usually range-bound.

ADF Scaled Line (White): Watch the interaction between the White Line and the Blue Threshold line. A cross below the threshold is the "Physical Event" that triggers the Green (Mean Reversion) state.

5. Technical Parameters
ADF Lookback: Controls the sensitivity of stationarity detection.

Adaptive Percentile (%): Determines how "strict" the system is before declaring a mean-reversion state. Higher values (35-40%) make the script more likely to turn green.

HV Window: Sets the lookback for the Historical Volatility ranking.

Publishing Instructions for TradingView:
Category: Select Volatility and Indicators.

Tags: Regime, ADF, Mean Reversion, Quantitative, Market Structure.

Description: Copy and paste the text above.

Note: Ensure your chart displays the indicator clearly with the dashboard visible in the screenshot.

This script is designed for traders who prioritize objective data over subjective intuition. Reality is cold; trade the numbers.

## Source Code

````pine
// @version=5
indicator("Tactical Regime Score v3 (Dynamic Adaptive)", overlay=false, precision=3)

// ==========================================
// --- 1. 参数设置 ---
// ==========================================
adf_len    = input.int(30, "ADF Lookback", minval=10, tooltip="缩短这个值会让平稳性检测更敏感")
dynamic_p  = input.int(25, "Adaptive Percentile (%)", minval=5, maxval=50, tooltip="如果还是不变绿，调大这个值(如35或40)")
hv_len     = input.int(20, "HV Window")
hv_p_len   = input.int(200, "HV Percentile Lookback")

// ==========================================
// --- 2. 自适应标准化 ADF 计算 ---
// ==========================================
f_get_adf_normalized(src, len) =>
    log_src = math.log(src)
    dy = log_src - log_src[1]
    y_lag = log_src[1]
    
    // 基础 OLS
    sX = 0.0, sY = 0.0, sXY = 0.0, sX2 = 0.0
    for i = 0 to len - 1
        x = y_lag[i], y = dy[i]
        sX += x, sY += y, sXY += x * y, sX2 += x * x
    
    n = float(len)
    slope = (n * sXY - sX * sY) / (n * sX2 - sX * sX)
    sRes2 = 0.0
    for i = 0 to len - 1
        sRes2 += math.pow(dy[i] - (slope * y_lag[i]), 2)
    
    denom = math.sqrt(sX2 - (math.pow(sX, 2) / n))
    stdErr = math.sqrt(sRes2 / (n - 2)) / (denom == 0 ? 0.0001 : denom)
    slope / (stdErr == 0 ? 0.0001 : stdErr)

// 获取当前的 ADF 值
current_adf = f_get_adf_normalized(close, adf_len)

// 【核心进化】获取过去 500 根 K 线的 ADF 分布
// 我们不设死门槛，我们要找“相对最平稳”的时刻
float dynamic_threshold = ta.percentile_linear_interpolation(current_adf, 500, dynamic_p)

// ==========================================
// --- 3. 评分与视觉输出 ---
// ==========================================
hv_raw = ta.stdev(math.log(close / close[1]), hv_len) * math.sqrt(365) * 100
hv_p = ta.percentrank(hv_raw, hv_p_len)

// 变色逻辑：如果当前的 ADF 值低于它历史 25% 的水平，就判定为回归（变绿）
bool is_mean_reversion = current_adf < dynamic_threshold
color scoreColor = is_mean_reversion ? color.new(color.green, 20) : current_adf > -0.5 ? color.new(color.red, 20) : color.gray

// 绘制柱状图
plot(hv_p, "Tactical Score", color = scoreColor, style = plot.style_columns)

// 【调试工具】绘制 ADF 实时线，让你看清楚它到底在干嘛
plot(current_adf * 10, "ADF Value (Scaled x10)", color=color.new(color.white, 50), linewidth=1)
hline(0, "Zero Line", color.gray, hline.style_dotted)

// 决策阈值
hline(75, "High Confidence", color.new(color.red, 50), hline.style_dashed)
hline(25, "Low Confidence", color.new(color.yellow, 50), hline.style_dashed)

// 信息面板
var table info = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(info, 0, 0, "Regime", bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 0, is_mean_reversion ? "Mean Reversion" : "Trending/Random", bgcolor = scoreColor)
    table.cell(info, 0, 1, "ADF Value", bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 1, str.tostring(current_adf, "#.###"), bgcolor = color.black, text_color = color.white)
    table.cell(info, 0, 2, "Threshold", bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 2, str.tostring(dynamic_threshold, "#.###"), bgcolor = color.blue, text_color = color.white)
    table.cell(info, 0, 3, "Score", bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 3, str.tostring(hv_p, "#.#"), bgcolor = scoreColor)
````
