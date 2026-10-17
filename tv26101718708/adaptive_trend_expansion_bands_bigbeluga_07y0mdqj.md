# Adaptive Trend Expansion Bands [BigBeluga]

- url: https://www.tradingview.com/script/07y0mdqJ-Adaptive-Trend-Expansion-Bands-BigBeluga/
- type: indicator
- pine_id: PUB;6da4e6fd951f4bec9a0b7623d6da2e05
- version: 1.0

## Description

[b]Adaptive Trend Expansion Bands [BigBeluga][/b] is an advanced, volatility-scaled mathematical modeling terminal engineered for TradingView. It operates as a dynamic trend-following corridor system that maps asset extension, mean-reversion horizons, and structural exhaustion thresholds across four distinct mathematical volatility tiers.

Rather than relying on static channels or fixed-percentage envelopes, this system uses an adaptive algorithmic architecture. It combines a selectable baseline smoothing core (such as an EMA or HMA) with standard Average True Range (ATR) step multipliers. This approach maps predictable, gradient-shaded risk corridors that expand and contract in perfect synchronization with real-time market volatility.

[b]🔵 SYSTEM ARCHITECTURE & EXECUTING CORE ENGINES[/b]
[b]1. Smooth Multi-Engine Core Baseline[/b]
[list]
[*] [b]Selectable Mathematical Foundations:[/b] The central anchor line runs your preferred moving average smoothing type ([b]SMA, EMA, WMA, or HMA[/b]). This allows you to tailor the script to act as a responsive high-velocity scalp line or an institutional trend tracking system.
[image]https://www.tradingview.com/x/y0qTh1B9/[/image]
[*] [b]Volatility Expansion Envelopes:[/b] Spawns four upper and four lower risk bands symmetrically off the baseline. Driven by the asset's raw [b]ATR Length[/b], these bands act as a multi-layered support and resistance map, defining exactly where price action transitions from normal distribution into extreme variance.
[image]https://www.tradingview.com/x/ZUW3eGga/[/image]
[/list]

[b]2. Asymmetric Structural Trend Inversion Locking[/b]
[list]
[*] [b]Zone 3 Structural Threshold Flipped Tracking:[/b] The script utilizes a structural state machine that changes color parameters only when a candle successfully forces a crossover above the upper Zone 3 band ([b]Bullish Lock[/b]) or a crossunder below the lower Zone 3 band ([b]Bearish Lock[/b]).
[image]https://www.tradingview.com/x/DjejyaRb/[/image]
[*] [b]Clean Workspace Overwrites:[/b] Once a trend direction is verified, the engine overwrites your primary layout candle bars with clear, customized hex-theme presets ([b]Bullish/Bearish Base Colors[/b]) to maintain absolute structural awareness.
[*] [b]Dynamic Zone-Tier Mapping Labels:[/b] When a structural trend shift occurs, the system prints crisp zone indicators ([b]+1 to +4[/b] or [b]-1 to -4[/b]) directly in the background spaces to immediately define the volatility tiers.
[image]https://www.tradingview.com/x/kSMj2tF6/[/image]
[/list]

[b]3. High-Variance Exhaustion Spotting (Zone 4 Hits)[/b]
[list]
[*] [b]Counter-Trend Spike Identifiers:[/b] The terminal flags moments when an active trend experiences a sudden, high-velocity counter-trend surge into deep premium or discount territory ([b]Zone 4 Extreme Target Layers[/b]).
[*] [b]Localized Inversion Candlestick Highlights:[/b] The exact candle that spikes into a Zone 4 level is instantly recolored with a high-visibility contrast override ([b]Zone 4 Hit Candle Color[/b]). This provides immediate visual warning of exhaustion before any pullback begins.
[*] [b]Anti-Overlap Cooldown Guardrails:[/b] Built-in index buffer logic ([b]Zone 4 Label Bar Gap[/b]) prevents the system from cluttering your workspace with consecutive text labels during high-velocity runs.
[image]https://www.tradingview.com/x/2wECj00p/[/image]
[/list]

[b]4. Automatic Order-Tracking Boxes & Escape Latches[/b]
[list]
[*] [b]Historical Low/High Sizing Brackets:[/b] The moment a Zone 4 anomaly is logged, the graphical engine automatically anchors a structural box tracking the recent 3-bar high/low territory.
[*] [b]Dynamic Trailing Tracker Dashed Lines:[/b] Extends crisp upper and lower horizontal tracker boundaries from the exhaustion point. These dashed lines track the consolidation range and remain active until the market breaches either boundary, triggering a directional arrow glyph ([b]▲ or ▼[/b]) to mark the breakout.
[image]https://www.tradingview.com/x/XijObrQQ/[/image]
[/list]

[b]🔵 SYSTEMATIC EXECUTION STRATEGIES & RISK INTERPRETATION[/b]
[list]
[*] [b]Counter-Trend Overextension Inversions:[/b] When an asset is structurally trading in a downtrend but experiences an aggressive squeeze that spikes into the upper Zone 4 envelope, it triggers a Zone 4 exhaustion print. This alerts you that buyers have pushed deep into an illiquid mathematical ceiling. Look for short-side setups as price targets a mean-reversion move back down toward the primary baseline.
[*] [b]Zone Range Breakdown Continuations:[/b] Monitor the horizontal dashed tracking lines spawned by a Zone 4 hit. If price action consolidates inside these boundaries and then prints a strong close outside the high/low bracket, look to trade the breakout in that direction, using the opposite dashed line as a hard risk invalidation level.
[*] [b]Trend Health Assessment via Gradient Fills:[/b] Use the layered background fills to gauge trend strength. Healthy, sustainable trends typically ride smoothly along the Zone 1 and Zone 2 channels. When price aggressively pierces into Zone 3 or Zone 4, it signals a climax state, warning you to tighten trailing protective lines or take profits before a mean-reversion event.
[/list]

[b]🔵 INTERFACE CONFIGURATION AND PARAMETERS[/b]
[list]
[*] [b]Core Mathematical Tuning:[/b] Easily adjust baseline types, lookback periods, and baseline multipliers to optimize the indicator for any asset class, volatility cycle, or chart time frame.
[*] [b]Exhaustion Label Cleanliness Filters:[/b] Customize the bar index gap parameters to keep your layout workspace clean and legible during highly volatile market conditions.
[*] [b]Visual Theme Customization Modifiers:[/b] Fully adjust color properties for bullish states, bearish states, and exhaustion candle overrides to blend seamlessly into your dark or light charting interface.
[/list]

Transform your charting layout from flat geometric indicators into a highly responsive, volatility-scaled risk map with the [b]Adaptive Trend Expansion Bands[/b] terminal.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator('Adaptive Trend Expansion Bands [BigBeluga]', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

//  Core Indicator Settings 
ma_type    = input.string('EMA', title = 'MA Type', options = ['SMA', 'EMA', 'WMA', 'HMA'], group = "Core Settings", tooltip = "Choose the mathematical moving average type used to build the central baseline trend line.")
ma_length  = input.int(20, title = 'MA Length', minval = 1, group = "Core Settings", tooltip = "The number of bars used to calculate the central baseline. Higher numbers create smoother, slower trends.")
atr_length = input.int(14, title = 'ATR Length', minval = 1, group = "Core Settings", tooltip = "The period used to calculate the Average True Range (ATR), which dictates the height and volatility expansion of the 4 zones.")

//  Zone Multipliers 
mult1 = input.float(1.0, title = 'Zone Multiplier', step = 0.1, group = "Zone Bands (ATR Multipliers)", tooltip = "Distance of Zone 1 band from the baseline. Standard is 1.0x ATR.")
mult2 = mult1 + 0.5 
mult3 = mult2 + 0.5 
mult4 = mult3 + 0.5 

//  Visibility & Utility 
label_cooldown = input.int(10, title = "Zone 4 Label Bar Gap", minval = 1, group = "Label Settings", tooltip = "The minimum number of bars required between consecutive Zone 4 hit labels to keep the chart clean and prevent text overlapping.")

//  Custom Theme Color Inputs 
color_bull_base = input.color(color.teal, title = "Bullish Base Color", group = "Color Stylings", tooltip = "The base color applied to the bands, backgrounds, and text labels when the market is in an upward bullish trend.")
color_bear_base = input.color(color.red,   title = "Bearish Base Color", group = "Color Stylings", tooltip = "The base color applied to the bands, backgrounds, and text labels when the market is in a downward bearish trend.")
color_hit_base  = input.color(color.orange, title = "Zone 4 Hit Candle Color", group = "Color Stylings", tooltip = "The color applied to a single candle when it spikes into a Zone 4 target level.")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

get_ma(source, length, type) =>
    switch type
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'WMA' => ta.wma(source, length)
        'HMA' => ta.hma(source, length)
        => ta.sma(source, length)

base_ma = get_ma(close, ma_length, ma_type)
v_atr = ta.atr(atr_length)

// Calculate the 4 upper and lower bands
u1 = base_ma + v_atr * mult1
u2 = base_ma + v_atr * mult2
u3 = base_ma + v_atr * mult3
u4 = base_ma + v_atr * mult4

l1 = base_ma - v_atr * mult1
l2 = base_ma - v_atr * mult2
l3 = base_ma - v_atr * mult3
l4 = base_ma - v_atr * mult4

//  Trend Detection Logic 
var int trend = 0

if ta.crossover(close, u3)
    trend := 1
if ta.crossunder(close, l3)
    trend := -1

// Detect the exact bar where the trend flips
trend_flipped_bullish = trend == 1 and trend[1] != 1
trend_flipped_bearish = trend == -1 and trend[1] != -1
trend_flipped = trend_flipped_bullish or trend_flipped_bearish

//  Zone 4 Hit Tracking 
var int last_upper_hit_bar = 0
var int last_lower_hit_bar = 0

upper_zone4_hit = (trend == -1) and (high >= u3) and (bar_index - last_upper_hit_bar >= label_cooldown) and not trend_flipped
lower_zone4_hit = (trend == 1) and (low <= l3) and (bar_index - last_lower_hit_bar >= label_cooldown) and not trend_flipped

is_zone4_hit = upper_zone4_hit or lower_zone4_hit

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Candlestick Color Engine 
candle_body_color   = is_zone4_hit ? color.new(color_hit_base, 0)  : trend == 1 ? color.new(color_bull_base, 30) : trend == -1 ? color.new(color_bear_base, 30) : color.new(color.gray, 30)
candle_border_color = is_zone4_hit ? color.new(color_hit_base, 0)  : trend == 1 ? color.new(color_bull_base, 10) : trend == -1 ? color.new(color_bear_base, 10) : color.new(color.gray, 10)
candle_wick_color   = is_zone4_hit ? color.new(color_hit_base, 0)  : trend == 1 ? color.new(color_bull_base, 0)  : trend == -1 ? color.new(color_bear_base, 0)  : color.new(color.gray, 0)

plotcandle(open, high, low, close, title = "Trend Candles", color = candle_body_color, wickcolor = candle_wick_color, bordercolor = candle_border_color)

// Bands Plotting 
color_bull1 = color.new(color_bull_base, 90)
color_bull2 = color.new(color_bull_base, 80)
color_bull3 = color.new(color_bull_base, 70)
color_bull4 = color.new(color_bull_base, 50)

color_bear1 = color.new(color_bear_base, 90)
color_bear2 = color.new(color_bear_base, 80)
color_bear3 = color.new(color_bear_base, 70)
color_bear4 = color.new(color_bear_base, 50)

p_ma = plot(base_ma, color = trend == 1 ? color_bull_base : trend == -1 ? color_bear_base : color.gray, title = 'Base MA', display = display.none)

pu1 = plot(trend == -1 ? u1 : na, color = color.new(color_bear_base, 80), title = 'Upper 1', style = plot.style_linebr)
pu2 = plot(trend == -1 ? u2 : na, color = color.new(color_bear_base, 70), title = 'Upper 2', style = plot.style_linebr)
pu3 = plot(trend == -1 ? u3 : na, color = color.new(color_bear_base, 60), title = 'Upper 3', style = plot.style_linebr)
pu4 = plot(trend == -1 ? u4 : na, color = color.new(color_bear_base, 40), title = 'Upper 4', style = plot.style_linebr)

pl1 = plot(trend == 1 ? l1 : na, color = color.new(color_bull_base, 80), title = 'Lower 1', style = plot.style_linebr)
pl2 = plot(trend == 1 ? l2 : na, color = color.new(color_bull_base, 70), title = 'Lower 2', style = plot.style_linebr)
pl3 = plot(trend == 1 ? l3 : na, color = color.new(color_bull_base, 60), title = 'Lower 3', style = plot.style_linebr)
pl4 = plot(trend == 1 ? l4 : na, color = color.new(color_bull_base, 40), title = 'Lower 4', style = plot.style_linebr)

//  Gradient Area Fills 
fill(p_ma, pu1, color = trend == -1 ? color_bear1 : na, title = 'Bear Zone 1 Fill')
fill(pu1, pu2, color = trend == -1 ? color_bear2 : na, title = 'Bear Zone 2 Fill')
fill(pu2, pu3, color = trend == -1 ? color_bear3 : na, title = 'Bear Zone 3 Fill')
fill(pu3, pu4, color = trend == -1 ? color_bear4 : na, title = 'Bear Zone 4 Fill')

fill(p_ma, pl1, color = trend == 1 ? color_bull1 : na, title = 'Bull Zone 1 Fill')
fill(pl1, pl2, color = trend == 1 ? color_bull2 : na, title = 'Bull Zone 2 Fill')
fill(pl2, pl3, color = trend == 1 ? color_bull3 : na, title = 'Bull Zone 3 Fill')
fill(pl3, pl4, color = trend == 1 ? color_bull4 : na, title = 'Bull Zone 4 Fill')

//  Trend Shift Labels Function 
plot_zone_labels(is_bullish, b_ma, b1, b2, b3, b4, plus = false) =>
    lbl_color = is_bullish ? color_bull_base : color_bear_base
    txt_color = chart.fg_color
    mid1 = (b_ma + b1) / 2
    mid2 = (b1 + b2) / 2
    mid3 = (b2 + b3) / 2
    mid4 = (b3 + b4) / 2
    txt = plus ? '+' : '-'
    label.new(x = bar_index, y = mid1, text = txt + '1', color = color.new(lbl_color, 100), textcolor = txt_color, style = label.style_label_center, size = size.small)
    label.new(x = bar_index, y = mid2, text = txt + '2', color = color.new(lbl_color, 100), textcolor = txt_color, style = label.style_label_center, size = size.small)
    label.new(x = bar_index, y = mid3, text = txt + '3', color = color.new(lbl_color, 100), textcolor = txt_color, style = label.style_label_center, size = size.small)
    label.new(x = bar_index, y = mid4, text = txt + '4', color = color.new(lbl_color, 100), textcolor = txt_color, style = label.style_label_center, size = size.small)

if trend_flipped_bullish[1]
    plot_zone_labels(true, base_ma, l1, l2, l3, l4)

if trend_flipped_bearish[1]
    plot_zone_labels(false, base_ma, u1, u2, u3, u4, true)

//  Dynamic Box & Order Tracking Plots 
lowww = ta.lowest(3)
highh = ta.highest(3)
var upperBox = box(na)
var lowerBox = box(na)
var upperLine = line(na)
var lowerLine = line(na)

if upper_zone4_hit and na(upperLine) and na(lowerLine)
    label.new(x = bar_index, y = high, text = "+4\n▼", color = color.new(color_bear_base, 100), textcolor = color_bear_base, style = label.style_label_down, size = size.normal)
    last_upper_hit_bar := bar_index
    upperBox  := box.new(bar_index-3, high, bar_index, lowww, border_color = chart.fg_color, bgcolor = color.new(color_bear_base, 100))
    upperLine := line.new(bar_index, high, bar_index, high, color = chart.fg_color, style = line.style_dashed)
    lowerLine := line.new(bar_index, lowww, bar_index, lowww, color = chart.fg_color, style = line.style_dashed)

if lower_zone4_hit and na(upperLine) and na(lowerLine)
    label.new(x = bar_index, y = low, text = "▲\n-4", color = color.new(color_bull_base, 100), textcolor = color_bull_base, style = label.style_label_up, size = size.normal)
    last_lower_hit_bar := bar_index
    lowerBox  := box.new(bar_index-3, highh, bar_index, low, border_color = chart.fg_color, bgcolor = color.new(color_bull_base, 100))
    upperLine := line.new(bar_index, highh, bar_index, highh, color = chart.fg_color, style = line.style_dashed)
    lowerLine := line.new(bar_index, low, bar_index, low, color = chart.fg_color, style = line.style_dashed)

if close < upperLine.get_y2() and close > lowerLine.get_y2()
    upperLine.set_x2(bar_index)
    lowerLine.set_x2(bar_index)
else if not na(upperLine) and not na(lowerLine)
    txt = close < upperLine.get_y2() ? "▼" : "▲"
    stl = close < upperLine.get_y2() ? label.style_label_down : label.style_label_up
    col = close < upperLine.get_y2() ? color_bear_base : color_bull_base
    label.new(x = bar_index, y = close < upperLine.get_y2() ? high : low, text = txt, color = color.new(color_bull_base, 100), textcolor = col, style = stl, size = size.normal)
    upperLine.set_x2(bar_index)
    lowerLine.set_x2(bar_index)
    upperLine := line(na)
    lowerLine := line(na)

// if trend_flipped
//     upperLine := line(na)
//     lowerLine := line(na)

// }
````
