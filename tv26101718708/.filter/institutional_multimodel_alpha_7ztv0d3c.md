# Institutional Multi-Model Alpha

- url: https://www.tradingview.com/script/7zTv0D3C-Institutional-Multi-Model-Alpha/
- type: indicator
- pine_id: PUB;a47532f2e1904a9c85d96a98a862369d
- version: 1.0

## Description

[b]Overview[/b]
The Institutional Multi-Model Alpha is a quantitative "voting" system that aggregates seven independent algorithmic modules to determine market direction. Instead of relying on a single indicator, this tool acts as a Committee of Models, only firing long or short signals when a specific user-defined threshold of mathematical agreement is met.

[b]The 7 Quantitative Modules[/b]
[list]
[*]
[/list]Kalman Filter: A noise-reduction algorithm that tracks the underlying price trend by filtering out "market noise."

[list]
[*]
[/list]Stat-Arb Z-Score: Measures price deviation from the mean (Standard Deviation) to identify extreme overbought/oversold conditions.

[list]
[*]
[/list]Regime Detection: Uses the ADX (Average Directional Index) and 200-day SMA to determine if the market is trending or ranging.

[list]
[*]
[/list]Volatility Risk: Analyzes the Rate of Change (ROC) of volatility to identify periods of stabilizing or expanding risk.

[list]
[*]
[/list]Linear Regression Slope: Measures the velocity and angle of the current price trend.

[list]
[*]
[/list]Momentum Cluster: Combines RSI and ROC to confirm that price movement is backed by real strength.

[list]
[*]
[/list]Beta/Correlation (SPY): Analyzes the asset's correlation to the S&P 500 (SPY) to ensure the move is supported by broader market beta.

[list]
[*]
[/list]Key Features
Ensemble Scoring: Each module outputs a score of +1 (Bullish), -1 (Bearish), or 0 (Neutral).

[list]
[*]
[/list]Weighted Thresholds: Users can set a "Signal Threshold" (e.g., 3). A signal only triggers when the net score across all 7 models exceeds that number.

[list]
[*]
[/list]Real-Time Dashboard: A visual table on the chart displays the status of every internal module simultaneously, providing full transparency into why a signal is occurring.

[list]
[*]
[/list]Multi-Asset Analysis: Includes an integrated request.security call to pull S&P 500 data for institutional-grade correlation analysis.

[Technical Specifics
Script Version: Pine Script v6

Overlay: Yes (Plots directly on price)

Visuals: Dynamic background coloring, trend-following "Quant Line," and signal shapes for easy entry/exit identification.

How to Use
Confirmation: Use the Dashboard to see if the majority of models are aligned.

Aggressive vs. Conservative: Lower the Threshold input for more frequent signals, or raise it to 5 or 6 for high-conviction, institutional-style setups.

Trend Following: The central line (Kalman Filter) changes color based on the aggregate score, serving as a dynamic trailing stop or trend bias indicator.

## Source Code

````pine
//@version=6
indicator("Institutional Multi-Model Alpha", overlay=true, max_labels_count=500)

// ==========================================
// 1. FUNCTIONS (Must be at the top level)
// ==========================================
f_adx(_len) =>
    [di_plus, di_minus, adx_value] = ta.dmi(_len, _len)
    adx_value

// ==========================================
// 2. GLOBAL CALCULATIONS (Fixes CW10002)
// ==========================================
// All ta.* functions must be assigned to variables here, outside of logic gates
sma200    = ta.sma(close, 200)
sma50     = ta.sma(close, 50)
sma20     = ta.sma(close, 20)
stdev20   = ta.stdev(close, 20)
adx_val   = f_adx(14)
vol_stdev = ta.stdev(close, 20)
vol_roc   = ta.roc(vol_stdev, 5)
rsi_val   = ta.rsi(close, 14)
roc_val   = ta.roc(close, 10)
spy_price = request.security("SPY", timeframe.period, close)
spy_sma50 = ta.sma(spy_price, 50)
corr_spy  = ta.correlation(close, spy_price, 20)

// ==========================================
// 3. INPUTS
// ==========================================
grp_1 = "Model Settings"
show_dashboard = input.bool(true, "Show Signal Dashboard", group=grp_1)
threshold      = input.int(3, "Signal Threshold (1-7)", group=grp_1)

// ==========================================
// 4. THE 7 QUANT MODULES (Using Pre-Calculated Vars)
// ==========================================

// Module 1: Kalman Filter
var float k_est = na
float k_gain = 0.7 
k_est := na(k_est[1]) ? close : k_est[1] + k_gain * (close - k_est[1])
int m1_score = close > k_est ? 1 : -1

// Module 2: Stat-Arb Z-Score
float z_score = (close - sma20) / stdev20
int m2_score = z_score < -2 ? 1 : z_score > 2 ? -1 : 0

// Module 3: Regime Detection
int m3_score = adx_val > 25 and close > sma200 ? 1 : adx_val > 25 and close < sma200 ? -1 : 0

// Module 4: Volatility Risk
int m4_score = vol_roc < 0 ? 1 : -1

// Module 5: Linear Regression Slope
float lr_slope = ta.linreg(close, 25, 0) - ta.linreg(close, 25, 1)
int m5_score = lr_slope > 0 ? 1 : -1

// Module 6: Momentum Cluster
int m6_score = (rsi_val > 50 and roc_val > 0) ? 1 : -1

// Module 7: Beta/Correlation
int m7_score = corr_spy > 0.7 and close > sma50 ? 1 : -1

// ==========================================
// 5. AGGREGATION & SIGNALS
// ==========================================
int total_score = m1_score + m2_score + m3_score + m4_score + m5_score + m6_score + m7_score

bool long_signal  = ta.crossover(total_score, threshold)
bool short_signal = ta.crossunder(total_score, -threshold)

// ==========================================
// 6. VISUALS
// ==========================================
bgcolor(total_score >= threshold ? color.new(color.green, 85) : total_score <= -threshold ? color.new(color.red, 85) : na)
plot(k_est, color=total_score > 0 ? color.teal : color.maroon, linewidth=2, title="Quant Trend")

plotshape(long_signal,  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small)
plotshape(short_signal, style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small)

// Dashboard Logic
var table quant_dash = table.new(position.bottom_right, 4, 12, bgcolor=color.new(color.black, 20), border_width=1)
if show_dashboard and barstate.islast
    table.cell(quant_dash, 0, 0, "Model Name", text_color=color.white)
    table.cell(quant_dash, 1, 0, "Signal", text_color=color.white)
    
    // Add data to table
    table.cell(quant_dash, 0, 1, "Kalman Filter", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 1, m1_score > 0 ? "Bull" : "Bear", bgcolor=m1_score > 0 ? color.green : color.red)
    
    table.cell(quant_dash, 0, 2, "Stat-Arb Proxy", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 2, m2_score > 0 ? "Bull" : m2_score < 0 ? "Bear" : "Neut", bgcolor=m2_score > 0 ? color.green : m2_score < 0 ? color.red : color.gray)
    
    table.cell(quant_dash, 0, 3, "Regime HMM", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 3, m3_score > 0 ? "Bull" : m3_score < 0 ? "Bear" : "Neut", bgcolor=m3_score > 0 ? color.green : m3_score < 0 ? color.red : color.gray)
    
    table.cell(quant_dash, 0, 4, "Vol Clustering", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 4, m4_score > 0 ? "Bull" : "Bear", bgcolor=m4_score > 0 ? color.green : color.red)
    
    table.cell(quant_dash, 0, 5, "LinReg Alpha", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 5, m5_score > 0 ? "Bull" : "Bear", bgcolor=m5_score > 0 ? color.green : color.red)

    table.cell(quant_dash, 0, 6, "Momentum KNN", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 6, m6_score > 0 ? "Bull" : "Bear", bgcolor=m6_score > 0 ? color.green : color.red)

    table.cell(quant_dash, 0, 7, "Beta/Corr", text_color=color.white, text_halign=text.align_left)
    table.cell(quant_dash, 1, 7, m7_score > 0 ? "Bull" : "Bear", bgcolor=m7_score > 0 ? color.green : color.red)
````
