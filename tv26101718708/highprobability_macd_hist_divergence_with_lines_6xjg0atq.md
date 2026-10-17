# High-Probability MACD Hist Divergence (with Lines)

- url: https://www.tradingview.com/script/6Xjg0atQ-High-Probability-MACD-Hist-Divergence-with-Lines/
- type: indicator
- pine_id: PUB;6ba778d8b10f42719aa86470b47b799d
- version: 1.0

## Description

High-Probability MACD Histogram Divergence (with Lines)
This indicator identifies High-Probability MACD Histogram Divergences TradingView. It automatically tracks visual pivot points, draws technical confirmation lines, and applies a dynamic filter to remove market noise TradingView.
Key Features
Dynamic Divergence Detection: Automatically scans and plots standard Bullish (BU) and Bearish (BR) divergences between price action and MACD momentum TradingView.
Automatic Anchor Lines: Draws clean, visual trendlines connecting historical divergence structural peaks directly on your sub-chart.
Noise Filtering (Momentum Peak Filter): Features a dynamic threshold filter (%) based on historical volatility. It ensures only significant momentum waves are considered, weeding out minor histogram fluctuations TradingView.
Optimized Pivot Engine: Pre-calculates market pivot structural points globally across the historical data array to prevent missing hidden or complex signals.

## Source Code

````pine
//@version=5
indicator("High-Probability MACD Hist Divergence (with Lines)", shorttitle="Hi-Prob Hist Div Lines", overlay=false)

// --- Inputs ---
fast_length = input.int(12, title="Fast Length")
slow_length = input.int(26, title="Slow Length")
signal_length = input.int(9, title="Signal Smoothing")
src = input.source(close, title="Source")

// Pivot Settings
pivot_left = input.int(5, title="Pivot Left Bars", minval=1)
pivot_right = input.int(2, title="Pivot Right Bars", minval=1)
lookback_max = input.int(60, title="Max Lookback Range", minval=10)
lookback_min = input.int(5, title="Min Lookback Range", minval=2)

// High Probability Filter Settings
use_filter = input.bool(true, title="Use Momentum Peak Filter", tooltip="Filters out tiny noise peaks by checking if the past peak was strong")
threshold_pct = input.float(30.0, title="Peak Threshold Filter (%)", minval=0, maxval=100)

// --- MACD Calculation ---
[macd_line, signal_line, hist] = ta.macd(src, fast_length, slow_length, signal_length)

// --- Plot Fast and Slow Lines ---
plot(macd_line, color=color.blue, title="MACD (Fast Line)", linewidth=1)
plot(signal_line, color=color.orange, title="Signal (Slow Line)", linewidth=1)

// --- Plot Histogram Column Bars ---
// Bright colors = expanding momentum | Dark colors = contracting momentum
hist_color = hist >= 0 ? (hist > hist[1] ? color.teal : color.green) : (hist < hist[1] ? color.maroon : color.red)
plot(hist, color=hist_color, style=plot.style_columns, title="MACD Histogram")
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_solid)

// --- High Probability Filter Bounds ---
highest_hist = ta.highest(hist, lookback_max)
lowest_hist = ta.lowest(hist, lookback_max)
bear_threshold = highest_hist * (threshold_pct / 100.0)
bull_threshold = lowest_hist * (threshold_pct / 100.0)

// --- Pre-Calculate Pivot Arrays Globally (Fixes Missing Signals) ---
hist_ph = ta.pivothigh(hist, pivot_left, pivot_right)
hist_pl = ta.pivotlow(hist, pivot_left, pivot_right)

// Track and control lines using persistent pointers
var line bull_line = na
var line bear_line = na

// --- 1. High Probability Bullish Divergence Detection ---
if not na(hist_pl)
    int found_pl_idx = na
    // Look backward through history to find a matching old pivot low
    for i = pivot_right + 1 to lookback_max
        if not na(hist_pl[i - pivot_right])
            found_pl_idx := i - pivot_right
            break
    
    if not na(found_pl_idx) and found_pl_idx >= lookback_min
        // Extract conditions cleanly from pre-calculated series
        bool price_lower_low = low[pivot_right] < low[found_pl_idx + pivot_right]
        bool hist_higher_low = hist[pivot_right] > hist[found_pl_idx + pivot_right]
        bool pass_filter = not use_filter or (hist[found_pl_idx + pivot_right] < bull_threshold[pivot_right])
        
        if price_lower_low and hist_higher_low and pass_filter
            // Plot BU Label
            label.new(x=bar_index - pivot_right, y=hist[pivot_right], text="BU", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
            // Draw connecting line between divergence anchor points
            bull_line := line.new(x1=bar_index - found_pl_idx - pivot_right, y1=hist[found_pl_idx + pivot_right], x2=bar_index - pivot_right, y2=hist[pivot_right], color=color.green, width=2)

// --- 2. High Probability Bearish Divergence Detection ---
if not na(hist_ph)
    int found_ph_idx = na
    // Look backward through history to find a matching old pivot high
    for i = pivot_right + 1 to lookback_max
        if not na(hist_ph[i - pivot_right])
            found_ph_idx := i - pivot_right
            break
            
    if not na(found_ph_idx) and found_ph_idx >= lookback_min
        // Extract conditions cleanly from pre-calculated series
        bool price_higher_high = high[pivot_right] > high[found_ph_idx + pivot_right]
        bool hist_lower_high = hist[pivot_right] < hist[found_ph_idx + pivot_right]
        bool pass_filter = not use_filter or (hist[found_ph_idx + pivot_right] > bear_threshold[pivot_right])
        
        if price_higher_high and hist_lower_high and pass_filter
            // Plot BR Label
            label.new(x=bar_index - pivot_right, y=hist[pivot_right], text="BR", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
            // Draw connecting line between divergence anchor points
            bear_line := line.new(x1=bar_index - found_ph_idx - pivot_right, y1=hist[found_ph_idx + pivot_right], x2=bar_index - pivot_right, y2=hist[pivot_right], color=color.red, width=2)
````
