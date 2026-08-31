<!-- tradingview-pine-id: PUB;dac6385683a34528b7c81ecb895ba075 -->
<!-- tradingviewscripts-format: 1 -->
# TTrades Daily Bias [TFO]

Source: https://www.tradingview.com/script/xdwgV3Fx-TTrades-Daily-Bias-TFO/

## Description

Inspired by @TTrades_edu video on daily bias, this indicator aims to develop a higher timeframe bias and collect data on its success rate. While a handful of concepts were introduced in said video, this indicator focuses on one specific method that utilizes previous highs and lows. The following description will outline how the indicator works using the daily timeframe as an example, but the weekly timeframe is also an included option that functions in the exact same manner.

On the daily timeframe, there are a handful of possible scenarios that we consider: if price closes above its previous day high (PDH), the following day's bias will target PDH; if price trades above its PDH but closes back below it, the following day's bias will target its previous day low (PDL).

[image]https://www.tradingview.com/x/oqQi6KW2/[/image]

Similarly, if price closes below its PDL, the following day's bias will target PDL. If price trades below its PDL but closes back above it, the following day's bias will target PDH.

[image]https://www.tradingview.com/x/lONT53uM/[/image]

If price trades as an inside bar that doesn't take either PDH or PDL, it will refer to the previous candle for bias. If the previous day closed above its open, it will target PDH and vice versa. If price trades as an outside bar that takes both PDH and PDL, but closes inside that range, no bias is assigned.

[image]https://www.tradingview.com/x/qKM97yHd/[/image]

With a rigid framework in place, we can apply it to the charts and observe the results. 

[image]https://www.tradingview.com/x/vFH72sQ4/[/image]

As shown above, each new day starts by drawing out the PDH and PDL levels. They start out as blue and turn red once traded through (these are the default colors which can be changed in the indicator's settings). The triangles you see are plotted to indicate the time at which PDH or PDL was traded through. This color scheme is also applied to the table in the top right; once a bias is determined, that cell's color starts out as blue and turns red once the level is traded through.

The table indicates the success rate of price hitting the levels provided by each period's bias, followed by the success rate of price closing through said levels after reaching them, as well as the sample size of data collected for each scenario. 

[image]https://www.tradingview.com/x/kpVuE8fk/[/image]

In the above crude oil futures (CL1!) 30m chart, we can glean a lot of information from the table in the top right. First we may note that the "PDH" cell is red, which indicates that the current day's bias was targeting PDH and it has already traded through that level. We might also note that the "PWH" cell is blue, which indicates that the weekly bias is targeting the previous week high (PWH) but price has yet to reach that level. 

As an example of how to read the table's data, we can look at the "PDH" row of the crude oil chart above. The sample size here indicates that there were 279 instances where the daily bias was assigned as PDH. From this sample size, 76.7% of instances did go on to trade through PDH, and only 53.7% of those instances actually went on to close through PDH after hitting that level. 

Of course, greater sample sizes and therefore greater statistical significance may be derived from higher timeframe charts that may go further back in time. The amount of data you can observe may also depend on your TradingView plan.

[image]https://www.tradingview.com/x/VhsL8mjx/[/image]

If we don't want to see the labels describing why bias is assigned a certain way, we can simply turn off the "Show Bias Reasoning" option. Additionally, if we want to see a visual of what the daily and weekly bias currently is, we can plot that along the top and bottom of the chart, as shown above. Here I have daily bias plotted at the top and weekly bias at the bottom, where the default colors of green and red indicate that the bias logic is expecting price to draw towards the given timeframe's previous high or low, respectively.

For a compact table view that doesn't take up much chart space, simply deselect the "Show Statistics" option. This will only show the color-coded bias column for a quick view of what levels are being anticipated (more user-friendly for mobile and other smaller screens).

[image]https://www.tradingview.com/x/GJkK9Bhr/[/image]

Alerts can be configured to indicate the bias for a new period, and/or when price hits its previous highs and lows. Simply enable the alerts you want from the indicator's settings and create a new alert with this indicator as the condition. There will be options to use "Any alert() function call" which will alert whatever is selected from the settings, or you can use more specific alerts for bullish/bearish bias, whether price hit PDH/PDL, etc.

Lastly, while the goal of this indicator was to evaluate the effectiveness of a very specific bias strategy, please understand that past performance does not guarantee future results.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradeforopp

//@version=5
indicator("TTrades Daily Bias [TFO]", "TTrades Daily Bias [TFO]", true, max_lines_count = 500, max_labels_count = 500)

var g_VIS = "Bias"
d_stats = input.bool(true, "Daily Bias", tooltip = "Apply TTrades bias concepts to the 1 Day timeframe", group = g_VIS)
w_stats = input.bool(false, "Weekly Bias", tooltip = "Apply TTrades bias concepts to the 1 Week timeframe", group = g_VIS)
bias_reason = input.bool(true, "Show Bias Reasoning", tooltip = "Show the reason why a given bias is being established", group = g_VIS)

var g_PLT = "Plotting"
bull_color = input.color(color.teal, "Bull / Bear Bias Colors", inline = "COLOR", group = g_PLT)
bear_color = input.color(color.red, "", inline = "COLOR", group = g_PLT)
d_bias_plot = input.bool(true, "Plot Daily Bias", inline = "DBIAS", group = g_PLT)
w_bias_plot = input.bool(true, "Plot Weekly Bias", inline = "WBIAS", group = g_PLT)
d_bias_loc = input.string('Top', "", inline = "DBIAS", options = ['Top','Bottom'], group = g_PLT)
w_bias_loc = input.string('Bottom', "", inline = "WBIAS", options = ['Top','Bottom'], group = g_PLT)

var g_STY = "Style"
before_raid_color = input.color(color.blue, "Before / After Hit Colors", inline = "HIT", tooltip = "All previous high and low lines will start out as this color", group = g_STY)
after_raid_color = input.color(color.red, "", inline = "HIT", tooltip = "Once a previous high or low line is reached, it will become this color", group = g_STY)
stop_ext = input.bool(false, "Stop Extending Lines After Hit", tooltip = "Once a previous high or low line is reached, its line will stop extending", group = g_STY)
use_d_sep = input.bool(true, "Day Separator", inline = "DSEP", group = g_STY)
use_w_sep = input.bool(true, "Week Separator", inline = "WSEP", group = g_STY)
d_sep = input.color(color.new(color.black, 80), "", inline = "DSEP", group = g_STY)
w_sep = input.color(color.new(color.black, 30), "", inline = "WSEP", group = g_STY)
line_width = input.int(1, "Line Width", group = g_STY)

var g_TBL = "Table"
tbl_show_stats = input.bool(true, "Show Statistics", tooltip = "Show statistics on bias accuracy\n\nSuccess Rate: how often has price successfully reached the assigned draw on liquidity?\n\nClose Thru Rate: from the number of times that price reached the assigned draw on liquidity, how often did it close through that level?\n\nSample Size: the total number of times that a given bias was assigned", group = g_TBL)
tbl_loc = input.string('Top Right', "Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_TBL)
tbl_size = input.string('Normal', "Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_TBL)

new_day = timeframe.change("D")
new_week = timeframe.change("W")

can_plot_d = timeframe.in_seconds() < timeframe.in_seconds("D")
can_plot_w = timeframe.in_seconds() < timeframe.in_seconds("W")

if use_d_sep and new_day and can_plot_d
    line.new(bar_index, high*1.000001, bar_index, low, color = d_sep, extend = extend.both, width = line_width)
if use_w_sep and new_week and can_plot_w
    line.new(bar_index, high*1.000001, bar_index, low, color = w_sep, extend = extend.both, width = line_width)

type lines
    line ph_line = na
    line pl_line = na
    bool hit_ph_line = false
    bool hit_pl_line = false

type info
    float ph
    float pl
    float ch
    float cl
    float co

    bool p_up

    int bias = 0
    int bias_ph = 0
    int bias_pl = 0
    int hit_ph = 0
    int hit_pl = 0
    int close_ph = 0
    int close_pl = 0
    
get_table_pos(pos) =>
    switch pos
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Top Right" => position.top_right

get_table_size(size) =>
    switch size
        'Tiny' => size.tiny
        'Small' => size.small
        'Normal' => size.normal
        'Large' => size.large
        'Huge' => size.huge
        'Auto' => size.auto

handle_bias(info n, string tf) =>
    _yloc   = yloc.price
    _style  = tf == "D" ? label.style_label_up : label.style_label_down
    _y      = tf == "D" ? n.cl : n.ch
    can_plot = tf == "D" ? can_plot_d : can_plot_w
    if close[1] > n.ph
        if n.bias == 1
            n.close_ph += 1
        n.bias := 1
        if bias_reason and can_plot
            txt = "Close Above P"+tf+"H\nBias P"+tf+"H"
            label.new(bar_index, _y, txt, textcolor = chart.fg_color, color = chart.bg_color, yloc = _yloc, style = _style)
    else if close[1] < n.pl
        if n.bias == -1
            n.close_pl += 1
        n.bias := -1
        if bias_reason and can_plot
            txt = "Close Below P"+tf+"L\nBias P"+tf+"L"
            label.new(bar_index, _y, txt, textcolor = chart.fg_color, color = chart.bg_color, yloc = _yloc, style = _style)
    else if close[1] < n.ph and close[1] > n.pl and n.ch > n.ph and n.cl > n.pl
        n.bias := -1
        if bias_reason and can_plot
            txt = "Failed to Close Above P"+tf+"H\nBias P"+tf+"L"
            label.new(bar_index, _y, txt, textcolor = chart.fg_color, color = chart.bg_color, yloc = _yloc, style = _style)
    else if close[1] > n.pl and close[1] < n.ph and n.ch < n.ph and n.cl < n.pl
        n.bias := 1
        if bias_reason and can_plot
            txt = "Failed to Close Below P"+tf+"L\nBias P"+tf+"H"
            label.new(bar_index, _y, txt, textcolor = chart.fg_color, color = chart.bg_color, yloc = _yloc, style = _style)
    else if n.ch <= n.ph and n.cl >= n.pl
        if n.p_up 
            n.bias := 1
        else
            n.bias := -1
        if bias_reason and can_plot
            txt = "Close Inside\nBias P"+tf + (n.p_up ? "H" : "L")
            label.new(bar_index, _y, txt, textcolor = chart.fg_color, color = chart.bg_color, yloc = _yloc, style = _style)
    else
        n.bias := 0
        if bias_reason and can_plot
            txt = "Outside Bar but Closed Inside\nNo Bias"
            label.new(bar_index, _y, txt, textcolor = chart.fg_color, color = chart.bg_color, yloc = _yloc, style = _style)

    if n.bias == 1
        n.bias_ph += 1
        alert("Bias P"+tf+"H", alert.freq_once_per_bar)
    else if n.bias == -1
        n.bias_pl += 1
        alert("Bias P"+tf+"L", alert.freq_once_per_bar)


method update_info(info n, string tf) =>
    if (tf == "D" ? new_day : new_week)
        if not na(n.ch)
            handle_bias(n, tf)
            
            if close[1] >= n.co
                n.p_up := true
            else
                n.p_up := false

            n.ph := n.ch
            n.pl := n.cl
            n.ch := high
            n.cl := low
            n.co := open
            
    if na(n.ch)
        n.ch := high
        n.ch := low
    else
        n.ch := math.max(high, n.ch)
        n.cl := math.min(low,  n.cl)
            

method update_lines(lines[] L, info n, string tf) =>
    hit_high = false, hit_low = false
    can_plot = tf == "D" ? can_plot_d : can_plot_w
    if (tf == "D" ? new_day : new_week)
        L.pop()
        _right = time + timeframe.in_seconds(tf)*1000
        _style = tf == "D" ? line.style_solid : line.style_dashed
        L.unshift(lines.new(line.new(time, n.ph, _right, n.ph, xloc = xloc.bar_time, color = can_plot ? before_raid_color : na, style = _style, width = line_width), line.new(time, n.pl, _right, n.pl, xloc = xloc.bar_time, color = can_plot ? before_raid_color : na, style = _style, width = line_width), false, false))
    for i = 0 to L.size() - 1
        x = L.get(i)
        if not na(x.ph_line)
            if high >= x.ph_line.get_y1() and not x.hit_ph_line
                if stop_ext
                    x.ph_line.set_x2(time)
                if n.bias == 1
                    n.hit_ph += 1 
                x.hit_ph_line := true
                if can_plot
                    x.ph_line.set_color(after_raid_color)
                hit_high := true
                alert("Hit P"+tf+"H", alert.freq_once_per_bar)
            if low <= x.pl_line.get_y1() and not x.hit_pl_line
                if stop_ext
                    x.pl_line.set_x2(time)
                if n.bias == -1 
                    n.hit_pl += 1
                x.hit_pl_line := true
                if can_plot
                    x.pl_line.set_color(after_raid_color)
                hit_low := true
                alert("Hit P"+tf+"L", alert.freq_once_per_bar)
    [hit_high, hit_low]

var d_info = info.new()
var w_info = info.new()

var d_lines = array.new<lines>(1, lines.new())
var w_lines = array.new<lines>(1, lines.new())

d_hit_high = false
d_hit_low  = false

w_hit_high = false
w_hit_low  = false

if d_stats and timeframe.in_seconds() <= timeframe.in_seconds("D")
    d_info.update_info("D")
    [hr, lr] = d_lines.update_lines(d_info, "D")
    d_hit_high := hr
    d_hit_low  := lr

if w_stats and timeframe.in_seconds() <= timeframe.in_seconds("W")
    w_info.update_info("W")
    [hr, lr] = w_lines.update_lines(w_info, "W")
    w_hit_high := hr
    w_hit_low  := lr

plotshape(can_plot_d and d_hit_high, "PDH Raid", style = shape.triangleup,   location = location.abovebar, color = after_raid_color, size = size.tiny)
plotshape(can_plot_d and d_hit_low,  "PDL Raid", style = shape.triangledown, location = location.belowbar, color = after_raid_color, size = size.tiny)
plotshape(can_plot_w and w_hit_high, "PWH Raid", style = shape.triangleup,   location = location.abovebar, color = after_raid_color, size = size.tiny)
plotshape(can_plot_w and w_hit_low,  "PWL Raid", style = shape.triangledown, location = location.belowbar, color = after_raid_color, size = size.tiny)

plotshape(d_bias_plot, "Daily Bias", style = shape.square, size = size.tiny, location = d_bias_loc == 'Top' ? location.top : location.bottom, color = d_info.bias == 1 ? bull_color : d_info.bias == -1 ? bear_color : na)
plotshape(w_bias_plot, "Weekly Bias", style = shape.square, size = size.tiny, location = w_bias_loc == 'Top' ? location.top : location.bottom, color = w_info.bias == 1 ? bull_color : w_info.bias == -1 ? bear_color : na)

alertcondition(new_day and d_info.bias ==  1, "Bias PDH", "Bias PDH")
alertcondition(new_day and d_info.bias == -1, "Bias PDL", "Bias PDL")
alertcondition(new_day and d_info.bias ==  0, "No Daily Bias", "No Daily Bias")

alertcondition(new_week and w_info.bias ==  1, "Bias PWH", "Bias PWH")
alertcondition(new_week and w_info.bias == -1, "Bias PWL", "Bias PWL")
alertcondition(new_week and w_info.bias ==  0, "No Weekly Bias", "No Weekly Bias")

alertcondition(d_hit_high, "Hit PDH", "Hit PDH")
alertcondition(d_hit_low,  "Hit PDL", "Hit PDL")

alertcondition(w_hit_high, "Hit PWH", "Hit PWH")
alertcondition(w_hit_low,  "Hit PWL", "Hit PWL")

format_result(int hit, int bias) =>
    result = ""
    if bias > 0
        result := str.tostring(math.floor(hit / bias * 1000) / 10)
    else
        result := "0"
    result += "%"

format_color(bool bull, info n, lines[] L) =>
    color result = na
    if bull ? (n.bias == 1) : (n.bias == -1)
        if bull ? (L.get(0).hit_ph_line) : (L.get(0).hit_pl_line)
            result := color.new(after_raid_color, 50)
        else
            result := color.new(before_raid_color, 50)

var stats = table.new(get_table_pos(tbl_loc), 20, 20, chart.bg_color, chart.fg_color, 2, chart.fg_color, 1)
var text_size = get_table_size(tbl_size)
if barstate.islast
    table.cell(stats, 0, 0, "Bias", text_color = chart.fg_color, text_size = text_size)
    if tbl_show_stats
        table.cell(stats, 1, 0, "Success\nRate", text_color = chart.fg_color, text_size = text_size)
        table.cell(stats, 2, 0, "Close Thru\nRate", text_color = chart.fg_color, text_size = text_size)
        table.cell(stats, 3, 0, "Sample\nSize", text_color = chart.fg_color, text_size = text_size)

    if d_stats
        table.cell(stats, 0, 1, "PDH", text_color = chart.fg_color, bgcolor = format_color(true,  d_info, d_lines), text_size = text_size)
        table.cell(stats, 0, 2, "PDL", text_color = chart.fg_color, bgcolor = format_color(false, d_info, d_lines), text_size = text_size)

        if tbl_show_stats
            table.cell(stats, 1, 1, format_result(d_info.hit_ph, d_info.bias_ph), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 1, 2, format_result(d_info.hit_pl, d_info.bias_pl), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 2, 1, format_result(d_info.close_ph, d_info.hit_ph), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 2, 2, format_result(d_info.close_pl, d_info.hit_pl), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 3, 1, str.tostring(d_info.bias_ph), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 3, 2, str.tostring(d_info.bias_pl), text_color = chart.fg_color, text_size = text_size)
    
    if w_stats
        table.cell(stats, 0, 3, "PWH", text_color = chart.fg_color, bgcolor = format_color(true,  w_info, w_lines), text_size = text_size)
        table.cell(stats, 0, 4, "PWL", text_color = chart.fg_color, bgcolor = format_color(false, w_info, w_lines), text_size = text_size)
    
        if tbl_show_stats
            table.cell(stats, 1, 3, format_result(w_info.hit_ph, w_info.bias_ph), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 1, 4, format_result(w_info.hit_pl, w_info.bias_pl), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 2, 3, format_result(w_info.close_ph, w_info.hit_ph), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 2, 4, format_result(w_info.close_pl, w_info.hit_pl), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 3, 3, str.tostring(w_info.bias_ph), text_color = chart.fg_color, text_size = text_size)
            table.cell(stats, 3, 4, str.tostring(w_info.bias_pl), text_color = chart.fg_color, text_size = text_size)

plot(d_info.bias, "Daily Bias",  color = na, display = display.none)
plot(w_info.bias, "Weekly Bias", color = na, display = display.none)
````
