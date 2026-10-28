# Multi-Timeframe Bollinger Target Zones

- url: https://www.tradingview.com/script/TZYwTA4F-Multi-Timeframe-Bollinger-Target-Zones/
- type: indicator
- pine_id: PUB;77e586fab4d94cb0bee46519cdece7e0
- version: 1.0

## Description

▎ Options trading with a jade lizard on SPX just got a full data study, comparing five, seven,
  ▎ and ten day cycles across two spread widths. The 0DTE options strategy space is moving fast,
  ▎ and this episode shows exactly which setup captures the most capital efficiency without
  ▎ holding trades all the way to expiration.

  ▎ The data is clear: the seven and five day cycles outperform, wider put spreads bring home more
  ▎  total profits in line with the buying power increase, and taking winners at 25% of max profit
  ▎  is optimal.

  ---
  Key English Talking Points from Host

  ┌────────────────┬──────────────────────────────────────────────────────────────────────────┐
  │    Segment     │                                  Quote                                   │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Strategy type  │ "a bullish to neutral strategy"                                          │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Structure      │ "a skewed iron condor"                                                   │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Why Jade       │ "nobody's really trading naked SPX short puts — not capital efficient"   │
  │ Lizard         │                                                                          │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Risk defined   │ "$10/$30 wide spreads with defined risk"                                 │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Cycle time     │ "being able to cycle that capital into something else"                   │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Winner exit    │ "when winners taken as early as 25% — that's really what we showed here" │
  ├────────────────┼──────────────────────────────────────────────────────────────────────────┤
  │ Width          │ "using wider legs brought home more total profits, but about in line     │
  │ conclusion     │ with the increase in buying power"                                       │
  └────────────────┴──────────────────────────────────────────────────────────────────────────┘

  ---
  Core Conclusion (English)

  ▎ "The 10-day is really not the one to use. Sense to do this either 7 or 5 days."
  ▎ "Win rates high across the board."
  ▎ "The 7 and 5 day, that's the spot you want to be on these."
  ▎ "Seems pretty definitive."

  ---
  Summary: Host (tastylive) presents 3-year SPX Jade Lizard backtest across 5/7/10-day cycles with
   two spread widths ($5/$20 vs $10/$30). Key finding: 5-day and 7-day cycles are the sweet spot —
   10-day underperforms. Wider spreads add total profit but maintain capital efficiency. Take
  profits at 25%-50% max profit rather than holding to expiration. Win rates are high across all
  configurations.

这个指标是一个多周期布林带目标位工具，用来辅助判断短线目标价、低吸区和布林带收口。

  核心逻辑：

  | 周期 | 用途 |
  |---|---|
  | 1H | 主交易周期，上轨看短线目标价，下轨看短线买入区 |
  | 4H | 波段参考，看价格是否还有延伸空间 |
  | 1D | 大趋势边界，看更大级别目标和深回调区 |

  图上会显示：

  - 1H 上轨：资金短线可能想打到的位置。
  - 1H 下轨：短线回调买入参考。
  - 4H/1D 上下轨：更大周期的目标和支撑。
  - 中轨：趋势中枢。
  - 右上角表格：显示各周期上轨、下轨、是否收口。
  - 收口提示：当布林带宽度明显低于过去平均宽度时，表格显示 Squeeze YES，1H 图表背景会变淡橙色。

  收口的意义：

  - 布林带收口代表波动压缩。
  - 收口后通常容易出现方向选择。
  - 如果收口后向上突破上轨，可能进入加速段。
  - 如果跌破下轨，可能进入回调/破位段。

  适合用法：

  - 强势股看 1H 上轨 做短线目标。
  - 等回调看 1H 下轨 或 4H 中轨/下轨。
  - 如果 1H 和 4H 上轨接近，那里可能是较强止盈区。
  - 如果多个周期都收口，要重点关注后续放量突破方向。

## Source Code

````pine
//@version=5
indicator("Multi-Timeframe Bollinger Target Zones", overlay=true, max_labels_count=50)

length = input.int(20, "Length", minval=1)
mult = input.float(2.0, "StdDev multiplier", minval=0.1, step=0.1)
src = input.source(close, "Source")
squeeze_length = input.int(50, "Squeeze lookback", minval=5)
squeeze_ratio = input.float(0.75, "Squeeze threshold vs average width", minval=0.1, maxval=1.5, step=0.05)

show_basis = input.bool(true, "Show middle band")
show_fill = input.bool(true, "Fill target range")
show_labels = input.bool(true, "Show latest labels")
show_table = input.bool(true, "Show value table")
show_4h = input.bool(true, "Show 4H reference bands")
show_1d = input.bool(true, "Show 1D reference bands")
show_squeeze_bg = input.bool(true, "Highlight 1H squeeze")
table_theme = input.string("Light", "Table theme", options=["Light", "Dark"])

txt_color = table_theme == "Light" ? color.rgb(20, 24, 31) : color.white
header_bg = table_theme == "Light" ? color.rgb(225, 229, 235) : color.rgb(20, 24, 31)
cell_bg = table_theme == "Light" ? color.rgb(248, 250, 252) : color.rgb(35, 39, 47)
muted_bg = table_theme == "Light" ? color.rgb(238, 242, 247) : color.rgb(55, 60, 70)
oneh_bg = table_theme == "Light" ? color.rgb(221, 235, 255) : color.new(color.blue, 80)
fourh_bg = table_theme == "Light" ? color.rgb(244, 226, 255) : color.new(color.fuchsia, 82)
oned_bg = table_theme == "Light" ? color.rgb(237, 228, 255) : color.new(color.purple, 82)
squeeze_yes_bg = table_theme == "Light" ? color.rgb(255, 204, 128) : color.new(color.orange, 35)
squeeze_no_bg = table_theme == "Light" ? color.rgb(235, 239, 244) : color.new(color.gray, 85)

[basis_1h, upper_1h, lower_1h, width_1h, avg_width_1h] = request.security(
     syminfo.tickerid,
     "60",
     [ta.sma(src, length), ta.sma(src, length) + mult * ta.stdev(src, length), ta.sma(src, length) - mult * ta.stdev(src, length), ((ta.sma(src, length) + mult * ta.stdev(src, length)) - (ta.sma(src, length) - mult * ta.stdev(src, length))) / ta.sma(src, length) * 100.0, ta.sma(((ta.sma(src, length) + mult * ta.stdev(src, length)) - (ta.sma(src, length) - mult * ta.stdev(src, length))) / ta.sma(src, length) * 100.0, squeeze_length)],
     barmerge.gaps_off,
     barmerge.lookahead_off)

[basis_4h, upper_4h, lower_4h, width_4h, avg_width_4h] = request.security(
     syminfo.tickerid,
     "240",
     [ta.sma(src, length), ta.sma(src, length) + mult * ta.stdev(src, length), ta.sma(src, length) - mult * ta.stdev(src, length), ((ta.sma(src, length) + mult * ta.stdev(src, length)) - (ta.sma(src, length) - mult * ta.stdev(src, length))) / ta.sma(src, length) * 100.0, ta.sma(((ta.sma(src, length) + mult * ta.stdev(src, length)) - (ta.sma(src, length) - mult * ta.stdev(src, length))) / ta.sma(src, length) * 100.0, squeeze_length)],
     barmerge.gaps_off,
     barmerge.lookahead_off)

[basis_1d, upper_1d, lower_1d, width_1d, avg_width_1d] = request.security(
     syminfo.tickerid,
     "D",
     [ta.sma(src, length), ta.sma(src, length) + mult * ta.stdev(src, length), ta.sma(src, length) - mult * ta.stdev(src, length), ((ta.sma(src, length) + mult * ta.stdev(src, length)) - (ta.sma(src, length) - mult * ta.stdev(src, length))) / ta.sma(src, length) * 100.0, ta.sma(((ta.sma(src, length) + mult * ta.stdev(src, length)) - (ta.sma(src, length) - mult * ta.stdev(src, length))) / ta.sma(src, length) * 100.0, squeeze_length)],
     barmerge.gaps_off,
     barmerge.lookahead_off)

squeeze_1h = width_1h < avg_width_1h * squeeze_ratio
squeeze_4h = width_4h < avg_width_4h * squeeze_ratio
squeeze_1d = width_1d < avg_width_1d * squeeze_ratio

upper_plot = plot(upper_1h, "1H upper target", color=squeeze_1h ? color.new(color.orange, 0) : color.new(color.red, 0), linewidth=2)
basis_plot = plot(show_basis ? basis_1h : na, "1H basis", color=color.new(color.gray, 20), linewidth=1)
lower_plot = plot(lower_1h, "1H lower buy zone", color=squeeze_1h ? color.new(color.orange, 0) : color.new(color.lime, 0), linewidth=2)

plot(show_4h ? upper_4h : na, "4H upper extension target", color=color.new(color.fuchsia, 20), linewidth=1, style=plot.style_linebr)
plot(show_4h ? lower_4h : na, "4H lower swing buy zone", color=color.new(color.teal, 20), linewidth=1, style=plot.style_linebr)
plot(show_1d ? upper_1d : na, "1D upper major target", color=color.new(color.purple, 35), linewidth=1, style=plot.style_linebr)
plot(show_1d ? lower_1d : na, "1D lower major buy zone", color=color.new(color.green, 35), linewidth=1, style=plot.style_linebr)

fill(upper_plot, lower_plot, color=show_fill ? color.new(color.blue, 92) : na, title="1H Bollinger range")

distance_to_upper = (upper_1h / close - 1.0) * 100.0
distance_to_lower = (close / lower_1h - 1.0) * 100.0
band_width = (upper_1h / lower_1h - 1.0) * 100.0

near_upper = close >= upper_1h * 0.995
near_lower = close <= lower_1h * 1.005

bgcolor(near_upper ? color.new(color.red, 88) : na, title="Near upper target")
bgcolor(near_lower ? color.new(color.green, 88) : na, title="Near lower buy zone")
bgcolor(show_squeeze_bg and squeeze_1h ? color.new(color.orange, 88) : na, title="1H Bollinger squeeze")

var label upper_label = na
var label lower_label = na
var label basis_label = na

if barstate.islast and show_labels
    label.delete(upper_label)
    label.delete(lower_label)
    label.delete(basis_label)

    upper_label := label.new(
         bar_index,
         upper_1h,
         "1H upper target\n" + str.tostring(upper_1h, format.mintick),
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.red, 0))

    lower_label := label.new(
         bar_index,
         lower_1h,
         "1H lower buy zone\n" + str.tostring(lower_1h, format.mintick),
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.green, 0))

    if show_basis
        basis_label := label.new(
             bar_index,
             basis_1h,
             "1H basis\n" + str.tostring(basis_1h, format.mintick),
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(color.gray, 20))

var table t = table.new(position.top_right, 4, 6, frame_color=color.rgb(120, 127, 140), frame_width=1, border_color=color.rgb(165, 172, 184), border_width=1)

if barstate.islast and show_table
    table.cell(t, 0, 0, "TF", text_color=txt_color, bgcolor=header_bg)
    table.cell(t, 1, 0, "Upper", text_color=txt_color, bgcolor=header_bg)
    table.cell(t, 2, 0, "Lower", text_color=txt_color, bgcolor=header_bg)
    table.cell(t, 3, 0, "Squeeze", text_color=txt_color, bgcolor=header_bg)

    table.cell(t, 0, 1, "1H", text_color=txt_color, bgcolor=oneh_bg)
    table.cell(t, 1, 1, str.tostring(upper_1h, format.mintick) + " (" + str.tostring(distance_to_upper, "#.##") + "%)", text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 2, 1, str.tostring(lower_1h, format.mintick) + " (" + str.tostring(distance_to_lower, "#.##") + "%)", text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 3, 1, squeeze_1h ? "YES " + str.tostring(width_1h, "#.##") + "%" : "NO " + str.tostring(width_1h, "#.##") + "%", text_color=txt_color, bgcolor=squeeze_1h ? squeeze_yes_bg : squeeze_no_bg)

    table.cell(t, 0, 2, "4H", text_color=txt_color, bgcolor=fourh_bg)
    table.cell(t, 1, 2, str.tostring(upper_4h, format.mintick), text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 2, 2, str.tostring(lower_4h, format.mintick), text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 3, 2, squeeze_4h ? "YES " + str.tostring(width_4h, "#.##") + "%" : "NO " + str.tostring(width_4h, "#.##") + "%", text_color=txt_color, bgcolor=squeeze_4h ? squeeze_yes_bg : squeeze_no_bg)

    table.cell(t, 0, 3, "1D", text_color=txt_color, bgcolor=oned_bg)
    table.cell(t, 1, 3, str.tostring(upper_1d, format.mintick), text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 2, 3, str.tostring(lower_1d, format.mintick), text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 3, 3, squeeze_1d ? "YES " + str.tostring(width_1d, "#.##") + "%" : "NO " + str.tostring(width_1d, "#.##") + "%", text_color=txt_color, bgcolor=squeeze_1d ? squeeze_yes_bg : squeeze_no_bg)

    table.cell(t, 0, 4, "Basis", text_color=txt_color, bgcolor=muted_bg)
    table.cell(t, 1, 4, str.tostring(basis_1h, format.mintick), text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 2, 4, str.tostring(basis_4h, format.mintick), text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 3, 4, str.tostring(basis_1d, format.mintick), text_color=txt_color, bgcolor=cell_bg)

    table.cell(t, 0, 5, "Avg width", text_color=txt_color, bgcolor=muted_bg)
    table.cell(t, 1, 5, str.tostring(avg_width_1h, "#.##") + "%", text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 2, 5, str.tostring(avg_width_4h, "#.##") + "%", text_color=txt_color, bgcolor=cell_bg)
    table.cell(t, 3, 5, str.tostring(avg_width_1d, "#.##") + "%", text_color=txt_color, bgcolor=cell_bg)

alertcondition(ta.crossover(close, upper_1h), "Breaks above 1H upper band", "Price broke above 1H Bollinger upper target.")
alertcondition(ta.crossunder(close, lower_1h), "Breaks below 1H lower band", "Price broke below 1H Bollinger lower buy zone.")
alertcondition(near_upper, "Near 1H upper target", "Price is near the 1H Bollinger upper target.")
alertcondition(near_lower, "Near 1H lower buy zone", "Price is near the 1H Bollinger lower buy zone.")
alertcondition(squeeze_1h, "1H Bollinger squeeze", "1H Bollinger band width is contracting.")
alertcondition(squeeze_4h, "4H Bollinger squeeze", "4H Bollinger band width is contracting.")
alertcondition(squeeze_1d, "1D Bollinger squeeze", "1D Bollinger band width is contracting.")
````
