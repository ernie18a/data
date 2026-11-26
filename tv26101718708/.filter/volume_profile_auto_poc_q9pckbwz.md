# Volume Profile Auto POC

- url: https://www.tradingview.com/script/q9pckbWZ-Volume-Profile-Auto-POC/
- type: indicator
- pine_id: PUB;61d054bf4d3e479db75b7b1826896fd5
- version: 1.0

## Description

[b]📌 Overview[/b]
Volume Profile Auto POC is a trend-following strategy that uses the automatically calculated Point of Control (POC) from the volume profile, combined with ATR zones, to capture reversals and breakouts.
By basing decisions on volume concentration, it dynamically visualizes the price levels most watched by market participants.

⚠️ This strategy is provided for educational and research purposes only.
Past performance does not guarantee future results.

[b]🎯 Strategy Objectives[/b]
[list]
[] Automatically detect the volume concentration area (POC) to improve entry accuracy
[] Optimize risk management through ATR-based volatility adjustment
[*] Provide early and consistent signals when trends emerge
[/list]

[b]✨ Key Features[/b]
[list]
[] [b]Automatic POC Detection[/b]: Updates the volume profile over a defined lookback window in real time
[] [b]ATR Zone Integration[/b]: Defines a POC ± 0.5 ATR zone to clarify potential reversals/breakouts
[*] [b]Visual Support[/b]: Plots the POC line and zones on the chart for intuitive decision-making
[/list]

[b]📊 Trading Rules[/b]
Long Entry:

Price breaks above the POC + 0.5 ATR zone

Volume is above average to support the breakout

Short Entry:

Price breaks below the POC - 0.5 ATR zone

Volume is above average to support the downside move

Exit (or Reverse Position):

Price returns to the POC area

Or touches the ATR band

[b]⚙️ Trading Parameters & Considerations[/b]
Indicator Name: Volume Profile Auto POC

Parameters:
[list]
[] Lookback Bars: 50
[] Bins for Volume Profile: 24
[] ATR Length: 14
[] ATR Multiplier: 2.0
[/list]

[b]🖼 Visual Support[/b]

POC line plotted in red

POC ± 0.5 ATR zone displayed as a semi-transparent box

ATR bands plotted in blue for confirmation

[b]🔧 Strategy Improvements & Uniqueness[/b]
This strategy is inspired by traditional Volume Profile + ATR analysis,
while adding the improvement of a sliding-window mechanism for automatic POC updates.

Compared with conventional trend-following approaches,
its strength lies in combining both price and volume perspectives for decision-making.

[b]✅ Summary[/b]
Volume Profile Auto POC automatically extracts key market levels (POC) and combines them with ATR-based zones,
providing a responsive trend-following method.
It balances clarity with practicality, aiming for both usability and reproducibility.

⚠️ This strategy is based on historical data and does not guarantee future profits.
Always use proper risk management when applying it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PakunFX

//@version=6
indicator("Volume Profile Auto POC", overlay=true, max_bars_back=500)

// === User Inputs ===
lookback = input.int(50, title="Lookback Bars for POC", minval=10)
bins = input.int(24, title="Bins for Volume Profile", minval=5)
atr_length = input.int(14, title="ATR Length")
atr_mult = input.float(2.0, title="ATR Multiplier")
show_box = input.bool(true, title="Show POC ± 0.5 ATR Zone")
box_fill_color = input.color(color.new(color.red, 90), title="POC Zone Fill Color")
box_border_color = input.color(color.new(color.red, 60), title="POC Zone Border Color")

// === ATR Calculation ===
atr = ta.atr(atr_length)
upper_atr_band = close + atr * atr_mult
lower_atr_band = close - atr * atr_mult
plot(upper_atr_band, title="Upper ATR Band", color=color.new(color.blue, 70))
plot(lower_atr_band, title="Lower ATR Band", color=color.new(color.blue, 70))

// === Volume Profile (Sliding Window) ===
var float[] vol_bins = array.new_float()
var float poc_price = na

array.clear(vol_bins)
for _ = 0 to bins - 1
    array.push(vol_bins, 0.0)

// Get price range over the lookback period
min_price = ta.lowest(low, lookback)
max_price = ta.highest(high, lookback)
price_range = max_price - min_price
bin_size = price_range / bins

// Distribute volume into bins
for i = 0 to lookback - 1
    price = close[i]
    vol = volume[i]
    bin_index_f = (price - min_price) / bin_size
    bin_index = math.floor(bin_index_f)
    bin_index := math.max(math.min(bin_index, bins - 1), 0)
    prev = array.get(vol_bins, bin_index)
    array.set(vol_bins, bin_index, prev + vol)

// Determine the POC (highest volume bin center price)
float max_vol = 0.0
float temp_poc = na
for i = 0 to bins - 1
    float v = array.get(vol_bins, i)
    if v > max_vol
        max_vol := v
        temp_poc := min_price + bin_size * (i + 0.5)
poc_price := temp_poc

// Plot the POC line
plot(poc_price, title="POC", color=color.red, linewidth=2)

// === Stable POC Zone Box Drawing with Color Selection ===
var box zone_box = na
if show_box and not na(poc_price)
    float zone_top = poc_price + atr * 0.5
    float zone_bot = poc_price - atr * 0.5

    if not na(zone_box)
        box.delete(zone_box)

    zone_box := box.new(left = bar_index - lookback,right = bar_index,top = zone_top,bottom = zone_bot,xloc = xloc.bar_index,bgcolor = box_fill_color,border_color = box_border_color)
````
