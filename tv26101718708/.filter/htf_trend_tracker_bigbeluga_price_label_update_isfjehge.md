# HTF Trend Tracker [BigBeluga] - Price label update

- url: https://www.tradingview.com/script/IsFJehGe-HTF-Trend-Tracker-BigBeluga-Price-label-update/
- type: indicator
- pine_id: PUB;d26f940047fa49afb03e9ec9d403cc00
- version: 1.0

## Description

HTF Trend Tracker [BigBeluga] is a higher timeframe (HTF) trend tracking indicator designed to help traders identify significant trends, key levels, and market sentiment. The indicator dynamically adapts to the current price action, using HTF highs and lows to display trend direction and strength with detailed visuals.


Key Features:
Dynamic Trend Detection:
Uptrend is identified when the price closes above the HTF high.
Downtrend is detected when the price closes below the HTF low.
Midline changes color dynamically based on the trend direction:
Bullish Green: Indicates an uptrend.
Bearish Red: Indicates a downtrend.


Historical and Active HTF Levels:
Historic HTF highs and lows are displayed as dotted lines.
Current active HTF high and low levels are shown as solid lines.
Timeframe labels (e.g., "1D High" or "1D Low") mark the active levels for clarity.


Usage:
Identify uptrends and downtrends using the midline's color and the position of the close relative to the HTF levels.
Use solid lines and timeframe labels to track current HTF high and low levels.
Observe dotted lines for historical HTF levels to understand past price behavior.
Watch for checkmark (✓) and cross (✕) signals to spot trend changes and key market shifts.
Monitor candle colors to gauge trend intensity and proximity to the midline:
Intense colors signal strong trends, while neutral gray indicates consolidation near the midline.
HTF Trend Tracker [BigBeluga] is an essential tool for traders aiming to follow higher timeframe trends, identify key levels, and make data-driven decisions based on price dynamics and trend strength. Its customizable features allow for flexible integration into any trading strategy.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("HTF Trend Tracker [BigBeluga]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───── INPUTS ─────────────────────────────────────────────
tf = input.timeframe("D", "Timeframe")

bull_col = input.color(color.rgb(12, 193, 142), "✓", inline = "col")
bear_col = input.color(color.red, "✕", inline = "col")
mid_col  = input.color(color.rgb(121, 121, 121), "-", inline = "col")

arrow_width  = input.int(3, "Arrow Line Thickness", minval = 1, maxval = 10)
dotted_width = input.int(3, "Dotted HTF Line Thickness", minval = 1, maxval = 10)

// PRICE LABEL SIZE CONTROL
label_size_input = input.string(
     "Large",
     "Price Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"])

// CONVERT INPUT TO PINE SIZE
label_size =
     label_size_input == "Tiny"   ? size.tiny   :
     label_size_input == "Small"  ? size.small  :
     label_size_input == "Normal" ? size.normal :
     label_size_input == "Large"  ? size.large  :
     size.huge

// ───── VARIABLES ───────────────────────────────────────────
var line line_1 = na
var line line_2 = na
var color color_trend = na
var bool trend = false

// ───── FUNCTION TO DRAW DOTTED HTF LINES ──────────────────
draw_line(x1, x2, y, txt, col)=>
    l = line.new(
         x1, y, x2, y,
         color = col,
         style = line.style_dotted,
         width = dotted_width)

    label.delete(label.new(
         x1,
         y,
         txt,
         color = color(na),
         style = label.style_label_right)[1])

    l

// ───── CALCULATIONS ────────────────────────────────────────
var float h = na
var float l = na
var int count = 0

if not timeframe.change(tf)
    count += 1
    h := ta.highest(count)
    l := ta.lowest(count)

if timeframe.change(tf)
    count := 0

    line_1 := draw_line(
         bar_index,
         bar_index,
         h[1],
         tf + " High",
         bear_col)

    line_2 := draw_line(
         bar_index,
         bar_index,
         l[1],
         tf + " Low",
         bull_col)

// ───── EXTEND DOTTED LINES ────────────────────────────────
if not na(line_1)
    line.set_x2(line_1, bar_index)

if not na(line_2)
    line.set_x2(line_2, bar_index)

// ───── LABEL OFFSET ───────────────────────────────────────
offset = ta.atr(14) * 0.15

// ───── RIGHT-SIDE ARROW PROJECTION + PRICE LABELS ─────────
if barstate.islast and not na(line_1) and not na(line_2)

    // RED HTF HIGH ARROW
    red_y = line.get_y1(line_1)

    line.delete(line.new(
         line.get_x1(line_1),
         red_y,
         bar_index + 15,
         red_y,
         color = bear_col,
         style = line.style_arrow_right,
         width = arrow_width)[1])

    // RED PRICE LABEL
    label.delete(label.new(
         bar_index - 1,
         red_y + offset,
         "{" + str.tostring(red_y, format.mintick) + "}",
         style = label.style_none,
         textcolor = bear_col,
         size = label_size)[1])

    // GREEN HTF LOW ARROW
    green_y = line.get_y1(line_2)

    line.delete(line.new(
         line.get_x1(line_2),
         green_y,
         bar_index + 15,
         green_y,
         color = bull_col,
         style = line.style_arrow_right,
         width = arrow_width)[1])

    // GREEN PRICE LABEL
    label.delete(label.new(
         bar_index - 1,
         green_y - offset,
         "{" + str.tostring(green_y, format.mintick) + "}",
         style = label.style_none,
         textcolor = bull_col,
         size = label_size)[1])

// ───── MIDPOINT ────────────────────────────────────────────
mid = math.avg(
     line.get_y1(line_1),
     line.get_y1(line_2))

// ───── TREND LOGIC ─────────────────────────────────────────
if ta.crossover(close, line.get_y1(line_1)) and barstate.isconfirmed
    color_trend := bull_col
    trend := true

if ta.crossunder(close, line.get_y1(line_2)) and barstate.isconfirmed
    color_trend := bear_col
    trend := false

// ───── SIGNAL LABELS ───────────────────────────────────────
if trend and trend != trend[1]

    label.new(
         bar_index,
         low - ta.sma(high - low, 100),
         "✓",
         style = label.style_label_up,
         size = size.tiny,
         color = bull_col)

if not trend and trend != trend[1]

    label.new(
         bar_index,
         high + ta.sma(high - low, 100),
         "✕",
         style = label.style_label_down,
         size = size.tiny,
         color = bear_col)

// ───── BAR COLORS ──────────────────────────────────────────
high_sdv = (high - mid)
low_sdv  = (mid - low)

color_bars =
       trend
     ? color.from_gradient(
         high_sdv,
         0,
         ta.highest(high_sdv, 100),
         mid_col,
         bull_col)

     : color.from_gradient(
         low_sdv,
         0,
         ta.highest(low_sdv, 100),
         mid_col,
         bear_col)

// ───── PLOTS ───────────────────────────────────────────────
plotcandle(
     open,
     high,
     low,
     close,
     title = "Candles",
     color = color_bars,
     wickcolor = color_bars,
     bordercolor = color_bars)

plot(
     mid,
     "Trend",
     color = color_trend,
     linewidth = 2)
````
