# Equal Highs and Lows Finder

- url: https://www.tradingview.com/script/A8UaCjyF-Equal-Highs-and-Lows-Finder/
- type: indicator
- pine_id: PUB;a11169a6f71b4137816b89b4479f65d8
- version: 1.0

## Description

Overview
The Equal Highs & Lows (EQH/EQL) Finder is a price-action tool designed to identify potential liquidity pools and "double top/bottom" structures automatically. In many technical analysis strategies (such as SMC or Inner Circle Trader methodologies), equal highs and lows represent areas where buy-side or sell-side liquidity is likely resting, often acting as a magnet for future price action.

How It WorksThe script utilizes Pivot Points to detect local peaks and valleys. When two consecutive pivots occur at nearly the same price level, the script draws a dashed trendline connecting them and labels the area.Because markets are rarely "perfect" to the cent, this indicator includes a Sensitivity Threshold. This allows you to define how much of a percentage deviation is acceptable for two points to still be considered "equal."

Key Features
Automated Detection: Saves time by instantly spotting EQH and EQL across any timeframe.

Customizable Sensitivity: Adjust the Threshold % to filter for "perfect" matches or broader zones.

Visual Clarity: Clean, dashed trendlines and labels (EQH/EQL) ensure your chart remains readable.

Pivot Control: Modify the Lookback period to find short-term micro-structures or major long-term swing points.

How to UseLiquidity Targets: Use the lines as potential targets for take-profits, as price often seeks out these "equal" levels to sweep liquidity.Support & Resistance: Identify strong horizontal levels where the market has reacted multiple times.Breakout Confirmation: Watch for price to "clear" these levels with high volume, indicating a liquidity grab.

SettingsThreshold %: The maximum price difference (in percentage) allowed between two pivots.Pivot Lookback: The number of bars required on either side of a high/low to confirm it as a pivot point. Higher numbers detect more significant swings.

## Source Code

````pine
//@version=5
indicator("Equal Highs and Lows Finder", overlay=true, max_lines_count=500)

// --- Inputs ---
// threshold_perc: How close prices must be (0.05% is usually a good starting point)
threshold_perc = input.float(0.05, "Threshold % (Sensitivity)", minval=0.01, step=0.01)
lookback       = input.int(3, "Pivot Lookback Left/Right", minval=1)
line_color_eqh = input.color(color.red, "EQH Line Color")
line_color_eql = input.color(color.green, "EQL Line Color")

// --- Pivot Logic ---
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

// Persist pivot data across bars
var float last_ph_price = na
var int   last_ph_index = na
var float last_pl_price = na
var int   last_pl_index = na

// --- EQH Logic (Equal Highs) ---
if not na(ph)
    if not na(last_ph_price)
        // Check if the current pivot high is within the threshold of the last one
        diff = math.abs(ph - last_ph_price) / last_ph_price * 100
        if diff <= threshold_perc
            line.new(x1=last_ph_index, y1=last_ph_price, x2=bar_index - lookback, y2=ph, 
                     color=line_color_eqh, width=2, style=line.style_dashed)
            label.new(bar_index - lookback, ph, "EQH", color=color.new(color.red, 80), 
                      style=label.style_label_down, textcolor=color.white, size=size.small)
    
    last_ph_price := ph
    last_ph_index := bar_index - lookback

// --- EQL Logic (Equal Lows) ---
if not na(pl)
    if not na(last_pl_price)
        diff = math.abs(pl - last_pl_price) / last_pl_price * 100
        if diff <= threshold_perc
            line.new(x1=last_pl_index, y1=last_pl_price, x2=bar_index - lookback, y2=pl, 
                     color=line_color_eql, width=2, style=line.style_dashed)
            label.new(bar_index - lookback, pl, "EQL", color=color.new(color.green, 80), 
                      style=label.style_label_up, textcolor=color.white, size=size.small)
    
    last_pl_price := pl
    last_pl_index := bar_index - lookback
````
