# GreenStar ATR% Extension Monitor

- url: https://www.tradingview.com/script/EWIHUwTF-GreenStar-ATR-Extension-Monitor/
- type: indicator
- pine_id: PUB;ee600314584e4ab996c82abccf1f6baf
- version: 2.0

## Description

[b]GreenStar ATR% Extension Monitor[/b]

The GreenStar ATR% Extension Monitor answers two questions in one window:
1) How volatile is the name? (14-period ATR as a percent of price)
2) How far has price stretched from a moving average, in relation to historical data?

Some names routinely stretch to 10-12x before mean-reverting. Others rarely clear 5x.
Scroll back on a daily chart to see extension habits for that symbol.


[b]Why extension matters[/b]

Dollar distance from a 50-day MA does not compare a $15 name to a $400 name.

Dividing percent gain from the MA by ATR% provides a multiple of normal daily range.
That is the blue [b]xFromMA[/b] line.

The green [b]ATR%[/b] stepline shows the denominator: typical range relative to price.
These are separate formulas on the same pane and timeline to show correlation.
(It does not draw on the price chart.)


[b]Two plots with independent calculations[/b]

[b]ATR%[/b] (green stepline): 14-period ATR as a percent of price. Typical daily range relative to price level.

[b]xFromMA[/b] (blue line): how many ATR% units price sits above or below the MA.

ATR%    = ATR(14) / close x 100
xFromMA = ((close - MA) / MA x 100) / ATR%

Zero on xFromMA means price is at the MA.
A negative value indicates price is currently below the MA level.


[b]Reading the pane[/b]

Both lines declining together often means the name is compressing toward the MA. Volatility and stretch easing at the same time.

Both rising means it's expanding.

Diverging slopes happen too.
xFromMA climbing while ATR% falls can mean price drifting from the MA while day-to-day volatility cools.
Read each line first, then note whether they agree.

Note: The lines share a pane for context, not because they combine into a signal.
A green/blue touch or cross is not a buy or sell event.


[b]Visible-range markers (optional)[/b]

High, low, and mean for xFromMA are calculated from the visible bars on the chart.
There is no fixed lookback period.
They update on scroll or zoom, comparing current stretch to recent visible history.

The mean is the average xFromMA over those visible bars, not the midpoint between high and low.
Visible-range mean requires high/low lines enabled in the same settings group.

Optional zero line (dotted): xFromMA = 0, full width of the pane.

ATR% high/low bands exist too, off by default.


[b]Settings[/b]

MA period (default 50)
MA type (default SMA)
ATR period (default 14)
Line colors and widths (default: dark green ATR%, blue xFromMA)
Zero line (default on)
High/low bands, xFromMA (default on)
Visible-range mean (default on)
ATR% high/low bands (default off)


[b]Disclaimer[/b]

Context tool only. Not a signal, not financial advice. No entry or exit triggers. Past extension habits do not predict future price action.

## Source Code

````pine
//@version=6
// ATR% + xFromMA extension pane
indicator("GreenStar ATR% Extension Monitor", shorttitle="GS ATR% Ext.", overlay=false, max_lines_count=50, max_bars_back=5000)

ma_period = input.int(50, "MA Period", minval=1)
atr_period = input.int(14, "ATR Period", minval=1)
ma_type = input.string("SMA", "MA Type", options=["SMA", "EMA"])

show_atr = input.bool(true, "Show ATR%", group="ATR%", tooltip="Primary ATR% stepline. ATR% Average is the SMA of this series, not of xFromMA.")
show_atr_avg = input.bool(true, "Show ATR% Average", group="ATR% Average", tooltip="SMA of the ATR% plot (not xFromMA, not ATR(n)).")
atr_avg_period = input.int(50, "ATR% Average Length", minval=1, group="ATR% Average", tooltip="Bars to average/smooth the primary ATR% plot (default 50). Example: ATR 21 with length 100.")
show_ext = input.bool(true, "Show xFromMA", group="xFromMA", tooltip="Extension multiple: percent from MA divided by ATR%.")

atr_plot_color = input.color(color.new(#558855, 15), "ATR% Line Color", group="Colors")
atr_avg_plot_color = input.color(color.new(#c084fc, 35), "ATR% Average Color", group="Colors")
ext_plot_color = input.color(color.blue, "xFromMA Line Color", group="Colors")
atr_line_width = input.int(1, "ATR% Line Width", minval=1, maxval=5, group="Colors")
atr_avg_line_width = input.int(1, "ATR% Average Line Width", minval=1, maxval=5, group="Colors")
ext_line_width = input.int(2, "xFromMA Line Width", minval=1, maxval=5, group="Colors")

show_zero_line = input.bool(true, "Show Zero Line", group="Reference", tooltip="Dotted line at xFromMA = 0 (price at MA)")
zero_line_color = input.color(color.new(color.gray, 35), "Zero Line Color", group="Reference")
zero_line_width = input.int(2, "Zero Line Width", minval=1, maxval=5, group="Reference")

show_atrx_range = input.bool(true, "Show High/Low Lines", group="ATRx Min/Max", tooltip="Visible-chart max/min dashed lines and price scale labels for xFromMA")
atrx_range_color = input.color(color.new(#9ecbff, 58), "High/Low Line Color", group="ATRx Min/Max")
show_atrx_mean = input.bool(true, "Show Visible-Range Mean", group="ATRx Min/Max", tooltip="Dotted visible-range mean line and mean price scale label for xFromMA")
show_atr_range = input.bool(false, "Show High/Low Lines", group="ATR% Min/Max", tooltip="Visible-chart max/min dashed lines and price scale labels for ATR%")
atr_range_color = input.color(color.new(#a8d8a8, 58), "High/Low Line Color", group="ATR% Min/Max")

ma = ma_type == "SMA" ? ta.sma(close, ma_period) : ta.ema(close, ma_period)
atr_pct = (ta.atr(atr_period) / close) * 100
atr_pct_avg = ta.sma(atr_pct, atr_avg_period)
ma_gain_pct = ((close - ma) / ma) * 100
ext = ma_gain_pct / atr_pct

plot(show_atr ? atr_pct : na, title="ATR% volatility", color=atr_plot_color, linewidth=atr_line_width, style=plot.style_stepline)
plot(show_atr_avg ? atr_pct_avg : na, title="ATR% average", color=atr_avg_plot_color, linewidth=atr_avg_line_width)
plot(show_ext ? ext : na, title="xFromMA multiple", color=ext_plot_color, linewidth=ext_line_width)
plot(show_zero_line ? 0.0 : na, "Zero", color=zero_line_color, display=display.price_scale, editable=false)

// Visible-range stats recomputed on last bar so pan/zoom refreshes without a click
var float vis_ext_high = na
var float vis_ext_low = na
var float vis_ext_mean = na
var float vis_atr_high = na
var float vis_atr_low = na

var line zero_line = na
var line ext_hi_line = na
var line ext_mean_line = na
var line ext_lo_line = na
var line atr_hi_line = na
var line atr_lo_line = na

// Recompute on last bar from current viewport (pan/zoom updates without needing a click)
if barstate.islast
    float tmp_ext_high = na
    float tmp_ext_low = na
    float tmp_ext_sum = 0.0
    int tmp_ext_count = 0
    float tmp_atr_high = na
    float tmp_atr_low = na

    for i = 0 to bar_index
        int t = time[i]
        if t > chart.right_visible_bar_time
            continue
        if t < chart.left_visible_bar_time
            break
        float e = ext[i]
        if not na(e)
            tmp_ext_high := na(tmp_ext_high) ? e : math.max(tmp_ext_high, e)
            tmp_ext_low := na(tmp_ext_low) ? e : math.min(tmp_ext_low, e)
            tmp_ext_sum += e
            tmp_ext_count += 1
        float a = atr_pct[i]
        tmp_atr_high := na(tmp_atr_high) ? a : math.max(tmp_atr_high, a)
        tmp_atr_low := na(tmp_atr_low) ? a : math.min(tmp_atr_low, a)

    vis_ext_high := tmp_ext_high
    vis_ext_low := tmp_ext_low
    vis_ext_mean := tmp_ext_count > 0 ? tmp_ext_sum / tmp_ext_count : na
    vis_atr_high := tmp_atr_high
    vis_atr_low := tmp_atr_low

    atrx_range_on = show_atrx_range and not na(vis_ext_high) and not na(vis_ext_low)
    atrx_mean_on = show_atrx_range and show_atrx_mean and not na(vis_ext_mean)
    atr_range_on = show_atr_range and not na(vis_atr_high) and not na(vis_atr_low)

    if show_zero_line
        if na(zero_line)
            zero_line := line.new(chart.left_visible_bar_time, 0.0, chart.right_visible_bar_time, 0.0, xloc.bar_time, extend=extend.both, color=zero_line_color, style=line.style_dotted, width=zero_line_width)
        else
            line.set_xy1(zero_line, chart.left_visible_bar_time, 0.0)
            line.set_xy2(zero_line, chart.right_visible_bar_time, 0.0)
        line.set_color(zero_line, zero_line_color)
        line.set_style(zero_line, line.style_dotted)
        line.set_width(zero_line, zero_line_width)
    else if not na(zero_line)
        line.delete(zero_line)
        zero_line := na

    if atrx_range_on
        if na(ext_hi_line)
            ext_hi_line := line.new(chart.left_visible_bar_time, vis_ext_high, chart.right_visible_bar_time, vis_ext_high, xloc.bar_time, extend=extend.both, color=atrx_range_color, style=line.style_dashed, width=1)
            ext_lo_line := line.new(chart.left_visible_bar_time, vis_ext_low, chart.right_visible_bar_time, vis_ext_low, xloc.bar_time, extend=extend.both, color=atrx_range_color, style=line.style_dashed, width=1)
        else
            line.set_xy1(ext_hi_line, chart.left_visible_bar_time, vis_ext_high)
            line.set_xy2(ext_hi_line, chart.right_visible_bar_time, vis_ext_high)
            line.set_xy1(ext_lo_line, chart.left_visible_bar_time, vis_ext_low)
            line.set_xy2(ext_lo_line, chart.right_visible_bar_time, vis_ext_low)
        line.set_color(ext_hi_line, atrx_range_color)
        line.set_color(ext_lo_line, atrx_range_color)
        line.set_style(ext_hi_line, line.style_dashed)
        line.set_style(ext_lo_line, line.style_dashed)
    else if not na(ext_hi_line)
        line.delete(ext_hi_line)
        line.delete(ext_lo_line)
        ext_hi_line := na
        ext_lo_line := na

    if atrx_mean_on
        if na(ext_mean_line)
            ext_mean_line := line.new(chart.left_visible_bar_time, vis_ext_mean, chart.right_visible_bar_time, vis_ext_mean, xloc.bar_time, extend=extend.both, color=atr_avg_plot_color, style=line.style_dotted, width=1)
        else
            line.set_xy1(ext_mean_line, chart.left_visible_bar_time, vis_ext_mean)
            line.set_xy2(ext_mean_line, chart.right_visible_bar_time, vis_ext_mean)
        line.set_color(ext_mean_line, atr_avg_plot_color)
        line.set_style(ext_mean_line, line.style_dotted)
    else if not na(ext_mean_line)
        line.delete(ext_mean_line)
        ext_mean_line := na

    if atr_range_on
        if na(atr_hi_line)
            atr_hi_line := line.new(chart.left_visible_bar_time, vis_atr_high, chart.right_visible_bar_time, vis_atr_high, xloc.bar_time, extend=extend.both, color=atr_range_color, style=line.style_dashed, width=1)
            atr_lo_line := line.new(chart.left_visible_bar_time, vis_atr_low, chart.right_visible_bar_time, vis_atr_low, xloc.bar_time, extend=extend.both, color=atr_range_color, style=line.style_dashed, width=1)
        else
            line.set_xy1(atr_hi_line, chart.left_visible_bar_time, vis_atr_high)
            line.set_xy2(atr_hi_line, chart.right_visible_bar_time, vis_atr_high)
            line.set_xy1(atr_lo_line, chart.left_visible_bar_time, vis_atr_low)
            line.set_xy2(atr_lo_line, chart.right_visible_bar_time, vis_atr_low)
        line.set_color(atr_hi_line, atr_range_color)
        line.set_color(atr_lo_line, atr_range_color)
    else if not na(atr_hi_line)
        line.delete(atr_hi_line)
        line.delete(atr_lo_line)
        atr_hi_line := na
        atr_lo_line := na

atrx_range_on_plot = show_atrx_range and not na(vis_ext_high) and not na(vis_ext_low)
atrx_mean_on_plot = show_atrx_range and show_atrx_mean and not na(vis_ext_mean)
atr_range_on_plot = show_atr_range and not na(vis_atr_high) and not na(vis_atr_low)

// Last-bar only so var constants do not paint a second full-width line in the pane
plot(barstate.islast and atrx_range_on_plot ? vis_ext_high : na, "Max", color=atrx_range_color, display=display.price_scale, editable=false)
plot(barstate.islast and atrx_mean_on_plot ? vis_ext_mean : na, "Mean", color=atr_avg_plot_color, display=display.price_scale, editable=false)
plot(barstate.islast and atrx_range_on_plot ? vis_ext_low : na, "Min", color=atrx_range_color, display=display.price_scale, editable=false)
plot(barstate.islast and atr_range_on_plot ? vis_atr_high : na, "Max%", color=atr_range_color, display=display.price_scale, editable=false)
plot(barstate.islast and atr_range_on_plot ? vis_atr_low : na, "Min%", color=atr_range_color, display=display.price_scale, editable=false)
````
