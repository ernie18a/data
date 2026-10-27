# Daily Bias with Linear Regression

- url: https://www.tradingview.com/script/jSbmRzvq/
- type: indicator
- pine_id: PUB;6688553261144c54934e947d5398721e
- version: 2.0

## Description

[b]Overview[/b]

The [b]Daily Bias with Linear Regression[/b] is a trend-following tool designed to help traders identify the prevailing market direction by aligning the momentum of two critical timeframes: the Daily (D1) and the 4-Hour (H4). By using Linear Regression slopes, this indicator filters out market noise and provides a clear "Bullish," "Bearish," or "Neutral" signal.

[b]How It Works[/b]

The indicator calculates the slope of price action using Linear Regression over two specific periods:
[list]
[*]Daily (D1): 20-period lookback.
[*]4-Hour (H4): 18-period lookback.
[/list]

The Daily Bias is determined as follows:
[list]
[*]🟢 BULLISH: When both the D1 and H4 slopes are positive.
[*]🔴 BEARISH: When both the D1 and H4 slopes are negative.
[*]⚪ NEUTRAL: When the slopes are conflicting (e.g., D1 is up, but H4 is down).
[/list]

Key Features

[list]
[*]Multi-Timeframe Analysis: Automatically fetches data from higher timeframes (D1 and H4) to provide a macro perspective even if you are on a lower timeframe.
[*]Anti-Repaint Logic: The script is coded to fetch the slope of the *previous* closed bar, ensuring that the signals remain stable and do not repaint.
[*]Real-time Dashboard: A clean table in the top-right corner displays the current ticker and the live bias status.
[*]Visual Labels: Direct "Bullish" or "Bearish" labels are plotted on the chart for immediate visual confirmation.
[*]Timeframe Guard: Includes a built-in warning if the chart timeframe is set below 1-Hour (H1), as the indicator is optimized for higher timeframe confluence.
[/list]

How to Use

[list=1]
[*]Trend Confirmation: Use the "BULLISH" or "BEARISH" status to align your trades with the higher timeframe momentum.
[*]Filter: Avoid taking long positions when the bias is "BEARISH" or short positions when it is "BULLISH."
[*]Wait for Alignment: A "NEUTRAL" bias suggests a ranging market or a potential trend change; waiting for both timeframes to align can increase trade probability.
[/list]

[quote]Disclaimer:
Trading involves significant risk. This indicator is for [b]educational and informational purposes only[/b] and does not constitute financial advice.[/quote]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © Aideelyst

//@version=6
indicator("Daily Bias with Linear Regression Channel", overlay = true, max_bars_back = 1000, max_lines_count = 20, max_labels_count = 10)

// ─── TIMEFRAME GUARD ─────────────────────────────────────────────────────────
is_below_h1 = timeframe.in_seconds() < 3600

// ─── INPUTS ──────────────────────────────────────────────────────────────────
src         = input.source(close, "Source")
len_d1      = input.int(20, "D1 Length", minval = 2)
len_h4      = input.int(18, "H4 Length", minval = 2)
dev_mult_d1 = input.float(2.0, "D1 Upper/Lower", minval = 0.1, step = 0.1)
dev_mult_h4 = input.float(2.0, "H4 Upper/Lower", minval = 0.1, step = 0.1)

show_d1_line    = input.bool(true, "Show D1 Line")
show_h4_line    = input.bool(true, "Show H4 Line")
show_d1_channel = input.bool(true, "Show D1 Upper/Lower")
show_h4_channel = input.bool(true, "Show H4 Upper/Lower")

extend_opt = input.string("Right", "Horizontal Extension", options = ["None", "Right", "Left", "Both"])
line_ext = switch extend_opt
    "Left"  => extend.left
    "Both"  => extend.both
    "Right" => extend.right
    => extend.none

// ─── HELPER: REGRESSION DEVIATION ────────────────────────────────────────────
f_reg_dev(_src, _len) =>
    float _y2    = ta.linreg(_src, _len, 0)
    float _y1    = ta.linreg(_src, _len, _len - 1)
    float _slope = (_y2 - _y1) / (_len - 1)
    float _dev   = 0.0

    for x = 0 to _len - 1
        float _fit = _y2 - _slope * x
        _dev += math.pow(_src[x] - _fit, 2)

    math.sqrt(_dev / _len)

// ─── FETCH D1 DATA (ANTI-REPAINT) ────────────────────────────────────────────
[d1_y1, d1_y2, d1_dev, slope_d1] = request.security(
     syminfo.tickerid, "D",
     [ta.linreg(src, len_d1, len_d1 - 1)[1],
      ta.linreg(src, len_d1, 0)[1],
      f_reg_dev(src, len_d1)[1],
      (ta.linreg(src, len_d1, 0) - ta.linreg(src, len_d1, 1))[1]],
     lookahead = barmerge.lookahead_on)

// ─── FETCH H4 DATA (ANTI-REPAINT) ────────────────────────────────────────────
[h4_y1, h4_y2, h4_dev, slope_h4] = request.security(
     syminfo.tickerid, "240",
     [ta.linreg(src, len_h4, len_h4 - 1)[1],
      ta.linreg(src, len_h4, 0)[1],
      f_reg_dev(src, len_h4)[1],
      (ta.linreg(src, len_h4, 0) - ta.linreg(src, len_h4, 1))[1]],
     lookahead = barmerge.lookahead_on)

// ─── COLORS ──────────────────────────────────────────────────────────────────
d1_col    = slope_d1 > 0 ? color.blue : color.red
h4_col    = slope_h4 > 0 ? color.blue : color.red
d1_ch_col = color.new(d1_col, 45)
h4_ch_col = color.new(h4_col, 60)

// ─── SCALE HTF LENGTH TO CURRENT CHART TF ───────────────────────────────────
tf_secs = timeframe.in_seconds()
bars_d1 = math.max(2, math.round(86400 * len_d1 / tf_secs))
bars_h4 = math.max(2, math.round(14400 * len_h4 / tf_secs))

// ─── CHANNEL VALUES ──────────────────────────────────────────────────────────
d1_upper_y1 = d1_y1 + d1_dev * dev_mult_d1
d1_upper_y2 = d1_y2 + d1_dev * dev_mult_d1
d1_lower_y1 = d1_y1 - d1_dev * dev_mult_d1
d1_lower_y2 = d1_y2 - d1_dev * dev_mult_d1

h4_upper_y1 = h4_y1 + h4_dev * dev_mult_h4
h4_upper_y2 = h4_y2 + h4_dev * dev_mult_h4
h4_lower_y1 = h4_y1 - h4_dev * dev_mult_h4
h4_lower_y2 = h4_y2 - h4_dev * dev_mult_h4

// ─── BIAS ────────────────────────────────────────────────────────────────────
bias = slope_d1 > 0 and slope_h4 > 0 ? "BULLISH" :
       slope_d1 < 0 and slope_h4 < 0 ? "BEARISH" :
       "NEUTRAL"

bias_col = bias == "BULLISH" ? color.new(color.blue, 20) :
           bias == "BEARISH" ? color.new(color.red, 20) :
           color.new(color.gray, 20)

lbl_style = bias == "BULLISH" ? label.style_label_up :
             bias == "BEARISH" ? label.style_label_down :
             label.style_label_left

lbl_yloc = bias == "BULLISH" ? yloc.belowbar :
           bias == "BEARISH" ? yloc.abovebar :
           yloc.price

// ─── PERSISTENT OBJECTS ──────────────────────────────────────────────────────
var line d1_line       = na
var line d1_upper_line = na
var line d1_lower_line = na

var line h4_line       = na
var line h4_upper_line = na
var line h4_lower_line = na

var label info_lbl = na

// ─── DRAW ────────────────────────────────────────────────────────────────────
if barstate.islast
    if is_below_h1
        if na(info_lbl)
            info_lbl := label.new(
                 bar_index, high, "⚠ H1 minimum",
                 style = label.style_label_left,
                 color = color.new(color.orange, 10),
                 textcolor = color.white,
                 size = size.small,
                 yloc = yloc.price)
        else
            label.set_xy(info_lbl, bar_index, high)
            label.set_text(info_lbl, "⚠ H1 minimum")
            label.set_style(info_lbl, label.style_label_left)
            label.set_color(info_lbl, color.new(color.orange, 10))
            label.set_textcolor(info_lbl, color.white)
            label.set_size(info_lbl, size.small)
            label.set_yloc(info_lbl, yloc.price)

        if not na(d1_line)
            line.delete(d1_line)
            d1_line := na
        if not na(d1_upper_line)
            line.delete(d1_upper_line)
            d1_upper_line := na
        if not na(d1_lower_line)
            line.delete(d1_lower_line)
            d1_lower_line := na

        if not na(h4_line)
            line.delete(h4_line)
            h4_line := na
        if not na(h4_upper_line)
            line.delete(h4_upper_line)
            h4_upper_line := na
        if not na(h4_lower_line)
            line.delete(h4_lower_line)
            h4_lower_line := na

    else
        if na(info_lbl)
            info_lbl := label.new(
                 bar_index, close, bias,
                 style = lbl_style,
                 color = bias_col,
                 textcolor = color.white,
                 size = size.small,
                 yloc = lbl_yloc)
        else
            label.set_xy(info_lbl, bar_index, close)
            label.set_text(info_lbl, bias)
            label.set_style(info_lbl, lbl_style)
            label.set_color(info_lbl, bias_col)
            label.set_textcolor(info_lbl, color.white)
            label.set_size(info_lbl, size.small)
            label.set_yloc(info_lbl, lbl_yloc)

        // D1 center line
        if show_d1_line
            if na(d1_line)
                d1_line := line.new(
                     bar_index - (bars_d1 - 1), d1_y1,
                     bar_index, d1_y2,
                     color = d1_col, width = 2, style = line.style_solid, extend = line_ext)
            else
                line.set_xy1(d1_line, bar_index - (bars_d1 - 1), d1_y1)
                line.set_xy2(d1_line, bar_index, d1_y2)
                line.set_color(d1_line, d1_col)
                line.set_width(d1_line, 2)
                line.set_style(d1_line, line.style_solid)
                line.set_extend(d1_line, line_ext)
        else
            if not na(d1_line)
                line.delete(d1_line)
                d1_line := na

        // D1 upper/lower
        if show_d1_channel
            if na(d1_upper_line)
                d1_upper_line := line.new(
                     bar_index - (bars_d1 - 1), d1_upper_y1,
                     bar_index, d1_upper_y2,
                     color = d1_ch_col, width = 1, style = line.style_dashed, extend = line_ext)
            else
                line.set_xy1(d1_upper_line, bar_index - (bars_d1 - 1), d1_upper_y1)
                line.set_xy2(d1_upper_line, bar_index, d1_upper_y2)
                line.set_color(d1_upper_line, d1_ch_col)
                line.set_width(d1_upper_line, 1)
                line.set_style(d1_upper_line, line.style_dashed)
                line.set_extend(d1_upper_line, line_ext)

            if na(d1_lower_line)
                d1_lower_line := line.new(
                     bar_index - (bars_d1 - 1), d1_lower_y1,
                     bar_index, d1_lower_y2,
                     color = d1_ch_col, width = 1, style = line.style_dashed, extend = line_ext)
            else
                line.set_xy1(d1_lower_line, bar_index - (bars_d1 - 1), d1_lower_y1)
                line.set_xy2(d1_lower_line, bar_index, d1_lower_y2)
                line.set_color(d1_lower_line, d1_ch_col)
                line.set_width(d1_lower_line, 1)
                line.set_style(d1_lower_line, line.style_dashed)
                line.set_extend(d1_lower_line, line_ext)
        else
            if not na(d1_upper_line)
                line.delete(d1_upper_line)
                d1_upper_line := na
            if not na(d1_lower_line)
                line.delete(d1_lower_line)
                d1_lower_line := na

        // H4 center line
        if show_h4_line
            if na(h4_line)
                h4_line := line.new(
                     bar_index - (bars_h4 - 1), h4_y1,
                     bar_index, h4_y2,
                     color = h4_col, width = 1, style = line.style_solid, extend = line_ext)
            else
                line.set_xy1(h4_line, bar_index - (bars_h4 - 1), h4_y1)
                line.set_xy2(h4_line, bar_index, h4_y2)
                line.set_color(h4_line, h4_col)
                line.set_width(h4_line, 1)
                line.set_style(h4_line, line.style_solid)
                line.set_extend(h4_line, line_ext)
        else
            if not na(h4_line)
                line.delete(h4_line)
                h4_line := na

        // H4 upper/lower
        if show_h4_channel
            if na(h4_upper_line)
                h4_upper_line := line.new(
                     bar_index - (bars_h4 - 1), h4_upper_y1,
                     bar_index, h4_upper_y2,
                     color = h4_ch_col, width = 1, style = line.style_dotted, extend = line_ext)
            else
                line.set_xy1(h4_upper_line, bar_index - (bars_h4 - 1), h4_upper_y1)
                line.set_xy2(h4_upper_line, bar_index, h4_upper_y2)
                line.set_color(h4_upper_line, h4_ch_col)
                line.set_width(h4_upper_line, 1)
                line.set_style(h4_upper_line, line.style_dotted)
                line.set_extend(h4_upper_line, line_ext)

            if na(h4_lower_line)
                h4_lower_line := line.new(
                     bar_index - (bars_h4 - 1), h4_lower_y1,
                     bar_index, h4_lower_y2,
                     color = h4_ch_col, width = 1, style = line.style_dotted, extend = line_ext)
            else
                line.set_xy1(h4_lower_line, bar_index - (bars_h4 - 1), h4_lower_y1)
                line.set_xy2(h4_lower_line, bar_index, h4_lower_y2)
                line.set_color(h4_lower_line, h4_ch_col)
                line.set_width(h4_lower_line, 1)
                line.set_style(h4_lower_line, line.style_dotted)
                line.set_extend(h4_lower_line, line_ext)
        else
            if not na(h4_upper_line)
                line.delete(h4_upper_line)
                h4_upper_line := na
            if not na(h4_lower_line)
                line.delete(h4_lower_line)
                h4_lower_line := na

// ─── TABLE ───────────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 5,
     border_color = color.new(color.white, 70),
     border_width = 1,
     frame_color  = color.new(color.white, 60),
     frame_width  = 1)

if barstate.islast
    if is_below_h1
        table.cell(t, 0, 0, syminfo.ticker,
             text_color = color.white, bgcolor = color.new(color.black, 40), text_size = size.small)
        table.cell(t, 1, 0, "⚠ H1 min",
             text_color = color.white, bgcolor = color.new(color.orange, 20), text_size = size.small)

        table.cell(t, 0, 1, "D1",
             text_color = color.new(color.white, 60), bgcolor = color.new(color.black, 60), text_size = size.small)
        table.cell(t, 1, 1, "—",
             text_color = color.new(color.white, 60), bgcolor = color.new(color.black, 60), text_size = size.small)

        table.cell(t, 0, 2, "H4",
             text_color = color.new(color.white, 60), bgcolor = color.new(color.black, 60), text_size = size.small)
        table.cell(t, 1, 2, "—",
             text_color = color.new(color.white, 60), bgcolor = color.new(color.black, 60), text_size = size.small)

        table.cell(t, 0, 3, "Source",
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)
        table.cell(t, 1, 3, "—",
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)

        table.cell(t, 0, 4, "Ext",
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)
        table.cell(t, 1, 4, extend_opt,
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)
    else
        table.cell(t, 0, 0, syminfo.ticker,
             text_color = color.white, bgcolor = color.new(color.black, 40), text_size = size.small)
        table.cell(t, 1, 0, bias,
             text_color = color.white, bgcolor = bias_col, text_size = size.small)

        table.cell(t, 0, 1, "D1",
             text_color = d1_col, bgcolor = color.new(color.black, 60), text_size = size.small)
        table.cell(t, 1, 1, slope_d1 > 0 ? "▲" : "▼",
             text_color = d1_col, bgcolor = color.new(color.black, 60), text_size = size.small)

        table.cell(t, 0, 2, "H4",
             text_color = h4_col, bgcolor = color.new(color.black, 60), text_size = size.small)
        table.cell(t, 1, 2, slope_h4 > 0 ? "▲" : "▼",
             text_color = h4_col, bgcolor = color.new(color.black, 60), text_size = size.small)

        table.cell(t, 0, 3, "Slope",
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)
        table.cell(t, 1, 3,
             str.tostring(math.round(slope_d1, 4)) + " / " + str.tostring(math.round(slope_h4, 4)),
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)

        table.cell(t, 0, 4, "Dev",
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)
        table.cell(t, 1, 4,
             str.tostring(dev_mult_d1) + " / " + str.tostring(dev_mult_h4),
             text_color = color.new(color.white, 50), bgcolor = color.new(color.black, 70), text_size = size.tiny)
````
