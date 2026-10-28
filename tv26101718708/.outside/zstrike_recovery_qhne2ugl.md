# Z-Strike Recovery

- url: https://www.tradingview.com/script/QhNe2uGl/
- type: strategy
- pine_id: PUB;ece47fef10ae434ebcb5cd8638c20629
- version: 1.0

## Description

This strategy utilizes the Z-Score of daily changes in the VIX (Volatility Index) to identify moments of extreme market panic and initiate long entries. Scientific research highlights that extreme volatility levels often signal oversold markets, providing opportunities for mean-reversion strategies.

How the Strategy Works

Calculation of Daily VIX Changes:

The difference between today’s and yesterday’s VIX closing prices is calculated.

Z-Score Calculation:
        
The Z-Score quantifies how far the current change deviates from the mean (average), expressed in standard deviations:

        Z-Score=(Daily VIX Change)−MeanStandard Deviation
        Z-Score=Standard Deviation(Daily VIX Change)−Mean​

The mean and standard deviation are computed over a rolling period of 16 days (default).

Entry Condition:
        
A long entry is triggered when the Z-Score exceeds a threshold of 1.3 (adjustable).
A high positive Z-Score indicates a strong overreaction in the market (panic).

Exit Condition:
        
The position is closed after 10 periods (days), regardless of market behavior.

Visualizations:

        The Z-Score is plotted to make extreme values visible.
        Horizontal threshold lines mark entry signals.
        Bars with entry signals are highlighted with a blue background.

This strategy is particularly suitable for mean-reverting markets, such as the S&P 500.
Scientific Background

Volatility and Market Behavior:
        
Studies like Whaley (2000) demonstrate that the VIX, known as the "fear gauge," is highly correlated with market panic phases. A spike in the VIX is often interpreted as an oversold signal due to excessive hedging by investors.
        
Source: Whaley, R. E. (2000). The investor fear gauge. Journal of Portfolio Management, 26(3), 12-17.

Z-Score in Financial Strategies:
        
The Z-Score is a proven method for detecting statistical outliers and is widely used in mean-reversion strategies.

Source: Chan, E. (2009). Quantitative Trading. Wiley Finance.

Mean-Reversion Approach:
        
The strategy builds on the mean-reversion principle, which assumes that extreme market movements tend to revert to the mean over time.
        
Source: Jegadeesh, N., & Titman, S. (1993). Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency. Journal of Finance, 48(1), 65-91.

## Source Code

````pine
//@version=6
strategy("Z-Strike Recovery", overlay=false, pyramiding=0, commission_type=strategy.commission.cash_per_contract, commission_value=0.05, slippage=1)

// --- Inputs ---
volatility_index = input.string(title="Volatility Index", defval="TVC:VIX", options=["TVC:VIX", "CBOE:VXN", "CBOE:RVX", "CBOE:VXST", "CBOE:VXD"])
z_length = input.int(title="Z-Score Lookback Length", defval=16, minval=1)
z_threshold = input.float(title="Z-Score Threshold", defval=1.3, minval=0.1, step=0.1)
exit_periods = input.int(title="Exit After X Periods", defval=10, minval=1)

// --- Data and Calculations ---
// Fetch Volatility Index data with `lookahead` set to `barmerge.lookahead_off` to prevent repainting
vol_data = request.security(volatility_index, timeframe.period, close, lookahead=barmerge.lookahead_off)

// Calculate the daily change in the Volatility Index
vol_change = ta.valuewhen(not na(vol_data), vol_data - vol_data[1], 0)

// Compute mean and standard deviation of the changes (use confirmed historical data only)
vol_change_mean = ta.sma(vol_change, z_length)
vol_change_stddev = ta.stdev(vol_change, z_length)

// Calculate Z-Score
z_score = (vol_change - vol_change_mean) / vol_change_stddev

// --- Entry and Exit Conditions ---
// Long entry condition: Z-Score exceeds the positive threshold
long_entry_condition = z_score > z_threshold
var float entry_bar = na  // Track the bar index of entry

// Enter a long position if the entry condition is met and no position is open
if (long_entry_condition and strategy.position_size == 0)
    strategy.entry("Long SP500", strategy.long)
    entry_bar := bar_index  // Save the entry bar index

// Exit condition: Close the position after X periods
exit_condition = not na(entry_bar) and (bar_index - entry_bar >= exit_periods)
if (exit_condition)
    strategy.close("Long SP500", comment="Exit after X periods")
    entry_bar := na  // Reset the entry bar index after exiting

// --- Visualizations ---
// Plot the Z-Score
plot(z_score, title="Z-Score", color=color.blue, linewidth=2, style= plot.style_areabr)

// Plot horizontal lines for thresholds
hline(z_threshold, title="Positive Z-Threshold", color=color.white, linestyle=hline.style_dotted)
hline(-z_threshold, title="Negative Z-Threshold", color=color.white, linestyle=hline.style_dotted)

// Highlight background for long entry condition
bgcolor(long_entry_condition ? color.new(color.blue, 70) : na, title="Long Entry Highlight")
````
