# Volume-Weighted Information Rate [AlgoPoint]

- url: https://www.tradingview.com/script/hMY666LD-Volume-Weighted-Information-Rate-AlgoPoint/
- type: indicator
- pine_id: PUB;0a2082a932294d8786b5340c51fce11f
- version: 1.0

## Description

[b]🧠 The Mathematical Engine[/b]

VWIR doesn't just track where the price is going; it measures the **quality** of the move using three core pillars:

1. [i]Shannon Entropy (Information Density):[/i] By calculating the probability distribution of log returns, the script measures market "uncertainty." Low entropy indicates that the market has reached a consensus, meaning "clear information" is flowing into the price.
2.[i] Volume-Weighted Conviction: [/i]We multiply information clarity by relative volume. If a move happens with low volume and high entropy, it is flagged as **Market Noise**. If it happens with high volume and low entropy, it is flagged as an **Institutional Surge**.
3. [i]Z-Score Normalization:[/i] The raw data is transformed into standard deviations. This allows the indicator to maintain consistent sensitivity across all asset classes—be it Crypto, Forex, or Equities.

[b]💎 Key Features[/b]

* [i]Info Dashboard: [/i]Real-time calculation of **Information Clarity (%)** and Market Efficiency. It tells you instantly if the current environment is "Pure Noise" or a "High-Signal" trend.
* [i]Institutional Surge Signals:[/i] The oscillator identifies "Exhaustion" and "Surge" points when the Z-Score crosses the $\pm2.0$ thresholds.
* [i]Alerts:[/i] Fully integrated with JSON placeholders for webhook automation and standard alerts for manual traders.

[b]📈 How to Use[/b]

* [i]Trend Confirmation:[/i] Look for a VWIR Z-Score breakout accompanied by "Information Clarity" above 70%. This confirms institutional participation.
* [i]Mean Reversion:[/i] When the Z-Score reaches extreme levels (Exhaustion), expect a cooling-off period or a sharp reversal as "Information" becomes overpriced.
* [i]Noise Filter:[/i] Avoid trading when the Dashboard displays "Pure Noise." This protects your capital during choppy, low-probability conditions.

## Source Code

````pine
//@version=5
indicator("Volume-Weighted Information Rate [AlgoPoint]", shorttitle="VWIR", overlay=false, precision=4)

// -----------------------------------------------------------------------------
// | © AlgoPoint                                                               |
// | Indicator: Volume-Weighted Information Rate [AlgoPoint]                    |
// | Developer: Harmony Algo & AlgoPoint Collaboration                         |
// -----------------------------------------------------------------------------

// ==========================================
// ## INPUTS ##
// ==========================================
grp_calc = "VWIR Core Calculation"
lookback = input.int(20, "Lookback Period", minval=5, group=grp_calc, tooltip="The period for calculating Shannon Entropy and VWMA.")
bin_count = input.int(5, "Entropy Bins", minval=3, maxval=10, group=grp_calc, tooltip="Number of buckets to categorize price returns for information density.")

grp_norm = "Normalization & Thresholds"
z_len = input.int(20, "Z-Score Smoothing", group=grp_norm)
z_threshold = input.float(2.0, "Signal Threshold (Z)", step=0.1, group=grp_norm)

grp_ui = "Visuals & UI"
show_labels = input.bool(true, "Show Signal Labels", group=grp_ui)
color_bars  = input.bool(true, "Colorize Bars by VWIR", group=grp_ui)
show_dash   = input.bool(true, "Show Information Dashboard", group=grp_ui)

// Colors Palette (AlgoPoint Standards)
color_bull = #2ee319
color_bear = #f31623
color_neut = #7f49de
color_dark_bull = #166d33
color_dark_bear = #ae2392

// ==========================================
// ## MATH ENGINE: INFORMATION THEORY ##
// ==========================================

// 1. Log Returns Calculation
log_ret = math.log(close / close[1])

// 2. Shannon Entropy Implementation (Optimized Loop)
get_entropy(src, len, bins) =>
    float entropy = 0.0
    float min_r = ta.lowest(src, len)
    float max_r = ta.highest(src, len)
    float range_r = max_r - min_r
    float bin_size = math.max(range_r / bins, 0.000001) // Avoid division by zero
    
    for i = 0 to bins - 1
        float b_start = min_r + (i * bin_size)
        float b_end = b_start + bin_size
        int count = 0
        for j = 0 to len - 1
            if src[j] >= b_start and src[j] < b_end
                count += 1
        
        float p = count / len
        if p > 0
            entropy -= p * (math.log(p) / math.log(2)) 
    entropy

raw_entropy = get_entropy(log_ret, lookback, bin_count)
max_possible_entropy = math.log(bin_count) / math.log(2)
norm_entropy = raw_entropy / max_possible_entropy

// 3. Information Clarity (1 - Entropy)
info_clarity = 1.0 - norm_entropy

// 4. Volume-Weighted Price Change
vol_sma = ta.sma(volume, lookback)
vol_ratio = volume / (vol_sma > 0 ? vol_sma : 1)
vwir_raw = info_clarity * vol_ratio * log_ret

// 5. Z-Score Normalization
vwir_mean = ta.sma(vwir_raw, z_len)
vwir_stdev = ta.stdev(vwir_raw, z_len)
vwir_z = (vwir_raw - vwir_mean) / (vwir_stdev > 0 ? vwir_stdev : 1)

// ==========================================
// ## VISUALS: OSCILLATOR & GRADIENTS ##
// ==========================================

// Gradient for Histogram
hist_color = color.from_gradient(vwir_z, -z_threshold, z_threshold, color_bear, color_bull)
plot(vwir_z, "VWIR Z-Score Histogram", color=hist_color, style=plot.style_columns)

// Threshold Lines
hline(z_threshold, "Upper Bound", color=color.new(color_bull, 50), linestyle=hline.style_dashed)
hline(-z_threshold, "Lower Bound", color=color.new(color_bear, 50), linestyle=hline.style_dashed)
hline(0, "Zero Line", color=color.new(color.gray, 70))

// FIX: barcolor must be in global scope. 
// We use a conditional within the function instead of an 'if' block.
bar_grad_color = color.from_gradient(vwir_z, -z_threshold, z_threshold, color_bear, color_bull)
barcolor(color_bars ? bar_grad_color : na)

// ==========================================
// ## SIGNALS & LABELS ##
// ==========================================
buy_signal  = ta.crossover(vwir_z, z_threshold)
sell_signal = ta.crossunder(vwir_z, -z_threshold)

// Signal Markers on Oscillator
plotshape(show_labels ? buy_signal : na, "Info Surge Bull", shape.triangleup, location.bottom, color_bull, size=size.small)
plotshape(show_labels ? sell_signal : na, "Info Surge Bear", shape.triangledown, location.top, color_bear, size=size.small)

// ==========================================
// ## DASHBOARD: QUANT INFORMATION ##
// ==========================================
var table info_dash = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if show_dash and barstate.islast
    table.cell(info_dash, 0, 0, "METRIC", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(info_dash, 1, 0, "QUANT VALUE", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    
    clarity_pct = math.round(info_clarity * 100, 2)
    table.cell(info_dash, 0, 1, "Info Clarity", text_color=color.white, text_halign=text.align_left)
    table.cell(info_dash, 1, 1, str.tostring(clarity_pct) + "%", bgcolor=color.from_gradient(info_clarity, 0, 1, color_bear, color_bull), text_color=color.white)
    
    eff_txt = info_clarity > 0.7 ? "High Signal" : info_clarity < 0.3 ? "Pure Noise" : "Mixed Data"
    table.cell(info_dash, 0, 2, "Efficiency", text_color=color.white, text_halign=text.align_left)
    table.cell(info_dash, 1, 2, eff_txt, bgcolor=info_clarity > 0.5 ? color_dark_bull : color_dark_bear, text_color=color.white)

    table.cell(info_dash, 0, 3, "VWIR Z-Score", text_color=color.white, text_halign=text.align_left)
    table.cell(info_dash, 1, 3, str.tostring(math.round(vwir_z, 2)), text_color=vwir_z > 0 ? color_bull : color_bear)

// ==========================================
// ## ALERTS ##
// ==========================================
if buy_signal and barstate.isconfirmed
    alert('{"ticker": "' + syminfo.ticker + '", "type": "VWIR_BULL", "z_score": ' + str.tostring(vwir_z) + '}', alert.freq_once_per_bar_close)

if sell_signal and barstate.isconfirmed
    alert('{"ticker": "' + syminfo.ticker + '", "type": "VWIR_BEAR", "z_score": ' + str.tostring(vwir_z) + '}', alert.freq_once_per_bar_close)

alertcondition(buy_signal, "Institutional Info Surge (Bull)", "VWIR has crossed the upper threshold.")
alertcondition(sell_signal, "Institutional Info Surge (Bear)", "VWIR has crossed the lower threshold.")
````
