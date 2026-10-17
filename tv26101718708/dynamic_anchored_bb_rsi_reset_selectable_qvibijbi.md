# Dynamic Anchored BB (RSI reset selectable)

- url: https://www.tradingview.com/script/qvibiJbI-Dynamic-Anchored-BB-RSI-reset-selectable/
- type: indicator
- pine_id: PUB;332318b34ce742d487a88b446e1ff0a6
- version: 1.0

## Description

🔵 Overview 🔵

[quote]Sometimes, rather than using Bollinger Bands based on a fixed, static period, you might want to plot them starting from a specific trigger point.
This indicator plots Bollinger Bands that originate at points where the RSI reaches 80 or higher (or, 20 or lower); the look-back period expands with each subsequent bar.[/quote]


🔵 How it works 🔵

[quote]Please take a look at the chart above. It shows the display with the "Upper Only" setting and the EMA selected for the moving average.
Starting from the point where the RSI reaches 80, the Bollinger Bands' period extends progressively with each passing bar; this continues until the RSI reaches 80 again.
This indicator views the market not as something static, but as a dynamic, living entity driven by specific events; it maps the starting point of a separate trend indicator—in this case, the RSI—onto the Bollinger Bands.
You can observe a clear correlation between the price's position relative to the Bollinger Bands and the actual price movement as the bars progress.

The image below shows the "Upper and Lower" display option.

[image]https://www.tradingview.com/x/Wg3wG44X/[/image][/quote]


🔵 How to use 🔵

[quote]Please open the settings and configure the values ​​and options according to your preferences:
[list]
[*]Choose the price source: close, ohlc4, or another option.
[*]RSI length: the default is set to the standard 14.
[*]Reset mode: select whether the reset is triggered by reaching the Upper level, the Lower level, or both.
[*]Specify the threshold values ​​for both the Upper and Lower levels.
[*]Base MA: select the type of moving average to serve as the basis for the Bollinger Bands.
[*]You can adjust the Bollinger Bands' standard deviation value. An option to plot pi (3.14) is also included.
[*]Three color schemes are available.
[/list][/quote]


🔵 Notes 🔵

[quote]This indicator can be used on charts for any asset and any timeframe.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NoriAlgo

//@version=6
indicator('Dynamic Anchored BB (RSI reset selectable)', overlay = true, max_bars_back = 5000)

// =========================================================================
// 1. INPUTS
// =========================================================================
grp_reset = 'RSI Reset Settings'
rsi_src = input.source(close, 'RSI source', group = grp_reset)
rsi_len = input.int(14, 'RSI length', minval = 1, group = grp_reset)
reset_mode = input.string('Upper and Lower', 'Reset mode', options = ['Upper Only', 'Lower Only', 'Upper and Lower'], group = grp_reset)
rsi_upper = input.float(80.0, 'Upper Reset Threshold', minval = 1, maxval = 100, group = grp_reset)
rsi_lower = input.float(20.0, 'Lower Reset Threshold', minval = 0, maxval = 99, group = grp_reset)

grp_ma = 'Moving Average Settings'
ma_type = input.string('SMA', 'Base MA', options = ['SMA', 'EMA', 'WMA', 'VWMA'], group = grp_ma)

grp_bb = 'Bollinger Bands'
mult1 = input.float(1.0, 'Stdev 1', group = grp_bb, inline = 'm1')
mult2 = input.float(2.0, 'Stdev 2', group = grp_bb, inline = 'm2')
mult3 = input.float(3.0, 'Stdev 3', group = grp_bb, inline = 'm3')
show_pi = input.bool(true, 'Show π (3.14) Bands', group = grp_bb)
color_theme = input.string('Blue-Orange', 'Color Theme', options = ['Blue-Orange', 'Neon', 'Monochrome'], group = grp_bb)


// =========================================================================
// 2. CORE LOGIC
// =========================================================================
float current_rsi = ta.rsi(rsi_src, rsi_len)
bool hit_upper = current_rsi >= rsi_upper
bool hit_lower = current_rsi <= rsi_lower

bool is_reset_up = hit_upper and (reset_mode == 'Upper Only' or reset_mode == 'Upper and Lower')
bool is_reset_dn = hit_lower and (reset_mode == 'Lower Only' or reset_mode == 'Upper and Lower')
bool is_reset = is_reset_up or is_reset_dn

var int period_k = 0
var float mean_M = 0.0
var float sum_sq_S = 0.0
var float ema_val = 0.0
var float sum_vol = 0.0
var float sum_svol = 0.0

if is_reset
    period_k := 1
    mean_M := close
    sum_sq_S := 0.0
    ema_val := close
    sum_vol := volume
    sum_svol := close * volume
    sum_svol
else
    period_k := period_k + 1

    float old_M = mean_M
    mean_M := mean_M + (close - mean_M) / period_k
    sum_sq_S := sum_sq_S + (close - mean_M) * (close - old_M)

    float alpha = 2.0 / (period_k + 1)
    ema_val := alpha * close + (1.0 - alpha) * ema_val

    sum_vol := sum_vol + volume
    sum_svol := sum_svol + close * volume
    sum_svol

float basis = switch ma_type
    'SMA' => mean_M
    'EMA' => ema_val
    'VWMA' => sum_vol > 0 ? sum_svol / sum_vol : mean_M
    'WMA' => ta.wma(close, math.max(1, period_k))
    => mean_M

float variance = period_k > 1 ? sum_sq_S / period_k : 0.0
float stdev = math.sqrt(math.max(0, variance))

// =========================================================================
// 3. BAND CALCULATIONS
// =========================================================================
float dev1 = stdev * mult1
float dev2 = stdev * mult2
float dev3 = stdev * mult3
float devPi = stdev * math.pi

float up1 = basis + dev1
float dn1 = basis - dev1
float up2 = basis + dev2
float dn2 = basis - dev2
float up3 = basis + dev3
float dn3 = basis - dev3
float upPi = basis + devPi
float dnPi = basis - devPi

// =========================================================================
// 4. PLOTTING & STYLIN
// =========================================================================
color c_basis = color.new(color.black, 0)
color c_b1 = color_theme == 'Neon' ? color.new(#00E676, 10) : color_theme == 'Monochrome' ? color.new(color.gray, 30) : color.new(#2962FF, 10)
color c_b2 = color_theme == 'Neon' ? color.new(#00E5FF, 10) : color_theme == 'Monochrome' ? color.new(color.gray, 50) : color.new(#00BCD4, 10)
color c_b3 = color_theme == 'Neon' ? color.new(#FF1744, 10) : color_theme == 'Monochrome' ? color.new(color.gray, 70) : color.new(#FF9800, 10)
color c_pi = color.new(color.fuchsia, 0)

p_basis = plot(basis, title = 'Basis MA', color = c_basis, linewidth = 2)

p_up1 = plot(up1, title = 'Upper 1', color = c_b1, linewidth = 1)
p_dn1 = plot(dn1, title = 'Lower 1', color = c_b1, linewidth = 1)
p_up2 = plot(up2, title = 'Upper 2', color = c_b2, linewidth = 1)
p_dn2 = plot(dn2, title = 'Lower 2', color = c_b2, linewidth = 1)
p_up3 = plot(up3, title = 'Upper 3', color = c_b3, linewidth = 1)
p_dn3 = plot(dn3, title = 'Lower 3', color = c_b3, linewidth = 1)

p_upPi = plot(show_pi ? upPi : na, title = 'Upper Pi', color = c_pi, linewidth = 2, style = plot.style_line)
p_dnPi = plot(show_pi ? dnPi : na, title = 'Lower Pi', color = c_pi, linewidth = 2, style = plot.style_line)

fill(p_basis, p_up1, color = color.new(c_b1, 85), title = 'Fill +1')
fill(p_basis, p_dn1, color = color.new(c_b1, 85), title = 'Fill -1')
fill(p_up1, p_up2, color = color.new(c_b2, 85), title = 'Fill +2')
fill(p_dn1, p_dn2, color = color.new(c_b2, 85), title = 'Fill -2')
fill(p_up2, p_up3, color = color.new(c_b3, 85), title = 'Fill +3')
fill(p_dn2, p_dn3, color = color.new(c_b3, 85), title = 'Fill -3')

// =========================================================================
// 5. VISUAL MARKERS
// =========================================================================
color bg_col = is_reset_up ? color.new(color.red, 85) : is_reset_dn ? color.new(color.green, 85) : na
bgcolor(bg_col, title = 'Reset Background')

plotshape(is_reset_up, title = 'Reset Upper', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, text = 'RSI Upper\nRESET', textcolor = color.red)
plotshape(is_reset_dn, title = 'Reset Lower', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small, text = 'RSI Lower\nRESET', textcolor = color.green)

plotchar(period_k, title = 'Current BB Period', char = '', location = location.bottom, color = color.new(color.black, 0))
````
