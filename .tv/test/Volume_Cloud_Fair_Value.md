<!-- tradingview-pine-id: PUB;0b3d07bad95b4ecc892c07c7840c7d4a -->
<!-- tradingviewscripts-format: 1 -->
# Volume Cloud + Fair Value

Source: https://www.tradingview.com/script/BD0Rn5xv-Volume-Cloud-Fair-Value/

## Description

Tired of entering a trade only to realize the pullback wasn't actually over? The Volume Cloud + Fair Value indicator is specifically designed to solve this problem by helping you pinpoint exactly when a retracement has exhausted itself.

By tracking institutional volume and isolating the true midpoint of the market, this tool gives you a clear visual edge. The core strategy is simple but highly effective: wait for the pullback, and look for buying opportunities precisely when the price breaks back above the Fair Value line, signaling that buyers have regained control.

☕ If this indicator helps you catch better entries and optimize your trading plan, consider supporting my work! You can buy me a coffee here: https://ko-fi.com/tradeguru/
(Feel free to reach out if you need custom Pine Script development!)

⏱️ Optimal Settings
While this indicator is highly customizable, the absolute best timeframe to use it on is the 1-Hour (1H) chart.
For the most accurate signals, apply these settings:

Fair Value Lookback: 24

Cloud Lookback: 24

This 24-hour setup perfectly captures the daily institutional cycle, filtering out intraday noise while keeping you aligned with the true daily trend.

🛠️ Key Features
Independent Fair Value Line: A dedicated midline that acts as your ultimate pullback filter.

Dynamic Volume Cloud: Visualizes the market ceiling (high) and floor (low) independently from the Fair Value, keeping your chart clean.

Institutional Volume Dashboard: A built-in table that tracks filtered buy and sell volume inside the Cloud, allowing you to instantly see who is really in control of the current range.

Split Customization: Assign completely different colors and transparency levels to your Fair Value line and your Volume Cloud for maximum visual clarity.

---

## Source Code

````pine
// © jan80hansen

//@version=6
indicator("Volume Cloud + Fair Value", overlay = true, max_bars_back = 5000)

// --- 1. SETTINGS ---
g_vol = "ICL Volume Filter Settings"
use_vol_filter = input.bool(true, title = "Enable Volume Filter", group = g_vol)
vol_mult       = input.float(1.3, title = "Volume Strength Multiplier", step = 0.05, group = g_vol, tooltip = "Filters out retail noise. Only sums volume from bars that exceed average volume multiplied by this factor.")
vol_length     = input.int(20, title = "Volume SMA Period", minval = 1, group = g_vol)

g_fv = "Fair Value Settings"
lookback_fv = input.int(24, title = "Fair Value Lookback", minval = 1, group = g_fv, tooltip = "Period length to calculate the exact middle point (Fair Value).")
color_fv    = input.color(color.yellow, title = "Fair Value Line Color", group = g_fv)

g_cloud = "Cloud & Extremes Settings"
lookback_cloud = input.int(48, title = "Cloud Lookback", minval = 1, group = g_cloud, tooltip = "Period length to calculate the ceiling (high), floor (low), and the structural volume.")
showExtremes   = input.bool(true, title = "Show Cloud Extremes (High/Low)", group = g_cloud)
showFill       = input.bool(true, title = "Fill Cloud Range", group = g_cloud)
color_cloud    = input.color(color.new(color.yellow, 25), title = "Cloud Color", group = g_cloud)

// --- 2. CALCULATION ENGINE FUNCTION ---
// Calculate Fair Value (Midpoint only)
hi_fv = ta.highest(high, lookback_fv)
lo_fv = ta.lowest(low, lookback_fv)
fvMid = (hi_fv + lo_fv) / 2

// Calculate Cloud Extremes
cloudHi = ta.highest(high, lookback_cloud)
cloudLo = ta.lowest(low, lookback_cloud)

// Calculate Volume over Cloud Lookback
float sumBuyVol = 0.0
float sumSellVol = 0.0
volSma = ta.sma(volume, vol_length)

for i = 0 to lookback_cloud - 1
    bool is_strong_volume = not use_vol_filter or (volume[i] > volSma[i] * vol_mult)
    if is_strong_volume
        if close[i] > open[i]
            sumBuyVol += volume[i]
        if close[i] < open[i]
            sumSellVol += volume[i]

// --- 3. PLOT: MIDLINE (Fair Value) + EXTREMES (Cloud) ---
// Fair Value Line
plot(fvMid, title = "Fair Value Line", color = color_fv, linewidth = 2)

// Cloud Extremes
p_hi = plot(showExtremes ? cloudHi : na, title = "Cloud High", color = color_cloud, linewidth = 1)
p_lo = plot(showExtremes ? cloudLo : na, title = "Cloud Low",  color = color_cloud, linewidth = 1)

// Cloud Fill
fill(p_hi, p_lo, color = showFill ? color.new(color_cloud, 85) : na, title = "Cloud Fill")

// --- 4. VOLUME DASHBOARD TABLE ---
var table tabStats = table.new(position.top_right, 3, 2, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

if barstate.islast
    string buy_header  = use_vol_filter ? "FILTERED BUY VOL" : "RAW BUY VOL"
    string sell_header = use_vol_filter ? "FILTERED SELL VOL" : "RAW SELL VOL"

    table.cell(tabStats, 0, 0, "PERIOD", text_color = color.white, text_size = size.small)
    table.cell(tabStats, 1, 0, buy_header, text_color = color.green, text_size = size.small)
    table.cell(tabStats, 2, 0, sell_header, text_color = color.red, text_size = size.small)

    table.cell(tabStats, 0, 1, "Cloud (" + str.tostring(lookback_cloud) + ")", text_color = color.white)
    table.cell(tabStats, 1, 1, str.format("{0,number,#}", sumBuyVol), text_color = color.green)
    table.cell(tabStats, 2, 1, str.format("{0,number,#}", sumSellVol), text_color = color.red)
````
