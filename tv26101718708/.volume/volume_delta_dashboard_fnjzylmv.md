# Volume Delta Dashboard

- url: https://www.tradingview.com/script/FnjZylMV-Volume-Delta-Dashboard/
- type: indicator
- pine_id: PUB;839e522dfe5b40b79ae4e4218feb2c58
- version: 4.0

## Description

A clean, real-time intrabar + lookback volume flow monitor that helps you quickly understand buying and selling pressure as it develops.The dashboard appears to the right of the forming candle and gives you an instant view of current candle aggression versus recent momentum.

[b]Key Features[/b]

Intrabar Volume — Live buy/sell split with percentages, delta, and progress bars for the forming candle.

Lookback Volume — Buy, Sell, and Delta totals from the last X bars (default 5, adjustable).

Lookback Bias — Clear text showing whether recent volume supports an uptrend, downtrend, or no clear bias.

Divergence Detection — Always-visible row that shows “Detected” (green/red) or “None” (grey).

High Participation (POC) — Highlights the price level with the highest volume in the current candle (Premium mode).

Size Presets — Small, Medium, or Large for perfect readability on any setup.

Essential + Premium Compatible — Full footprint data on Premium, smart approximation on Essential/Free.

[b]How It Works[/b]

Intrabar uses real buy/sell volume from the forming candle.
Lookback sums volume and classifies it as mostly buy or sell based on each bar’s direction.
Divergence flags when the current candle’s bias strongly opposes the recent lookback period (classic momentum exhaustion signal).

Best Use Cases
-Quick confirmation before entering or exiting trades
-Spotting absorption, aggressive buying/selling, or momentum shifts in real time
-Identifying when the current candle is fighting recent flow (high-probability reversal zones)
-Reducing screen clutter — one clean dashboard replaces multiple volume tools

Recommended Settings
-Timeframes: 1m to 15m (works on any timeframe ≥ 1m)
-Lookback Bars: 5 (default) — increase for swing context, decrease for scalping
-Dashboard Size: Medium for most users

A practical quality-of-life tool for traders who want fast, clear volume context without clutter.

## Source Code

````pine
//@version=6
indicator("Volume Delta Dashboard", shorttitle="VOLΔ DASHBOARD", overlay=true, max_bars_back=500)

// ── INPUTS ───────────────────────────────────────────────────────────────
group_display = "Display Settings"
size_preset          = input.string("Default", "Dashboard Size", options=["Smaller", "Default"], group=group_display)
dashboard_pos        = input.string("Near Price", "Dashboard Position", 
     options=["Upper Right", "Bottom Right", "Near Price"], group=group_display)
near_spacing_method  = input.string("ATR (Stable)", "Near Price Spacing Method", 
     options=["ATR (Stable)", "Original (% of Price)"], group=group_display)

group_calc = "Calculation Settings"
use_footprint = input.bool(true, "Use Premium Footprint (Premium/Ultimate only)", group=group_calc)
lower_tf      = input.timeframe("1", "Lower TF for Fallback", group=group_calc)
ticks_per_row = input.int(10, "Ticks per Footprint Row", minval=1, group=group_calc)
va_percent    = input.int(70, "Value Area %", minval=50, maxval=95, group=group_calc)

group_poc = "POC Settings"
show_poc_line  = input.bool(true, "Show POC Marker Line", group=group_poc)
poc_line_color = input.color(color.new(#FFD700, 0), "POC Line Color", group=group_poc)

group_bias = "Bias Logic"
recent_lookback = input.int(5, "Lookback Bars", minval=1, maxval=50, group=group_bias)
up_threshold   = input.float(15.0, "Uptrend Threshold (%)", minval=5, group=group_bias)
down_threshold = input.float(-15.0, "Downtrend Threshold (%)", maxval=-5, group=group_bias)

group_cvd = "CVD Settings"
cvd_period = input.string("Daily", "CVD Period", options=["Daily", "New York", "London", "Asia"], group=group_cvd)

group_style = "Style & Colors"
buy_color  = input.color(color.new(#00FFAA, 0), "Buy Color", group=group_style)
sell_color = input.color(color.new(#FF3366, 0), "Sell Color", group=group_style)

// ── SIZE ─────────────────────────────────────────────────────────────────
scale     = size_preset == "Default" ? 1.6 : 1.0
text_size = size_preset == "Default" ? size.normal : size.small

atr14 = ta.atr(14)
atr_spacing  = atr14 * (size_preset == "Default" ? 0.38 : 0.26) * scale
orig_spacing = close * (size_preset == "Default" ? 0.0022 : 0.0016) * scale

// ── CVD Session Setup (must be global) ───────────────────────────────────
string cvd_sess = switch cvd_period
    "New York" => "1300-2200"
    "London"   => "0700-1600"
    "Asia"     => "0000-0900"
    => ""

is_new_day  = ta.change(time("D")) != 0
is_new_sess = cvd_period != "Daily" ? ta.change(time(timeframe.period, cvd_sess)) != 0 : false

// ── FUNCTIONS ────────────────────────────────────────────────────────────
f_progress_bar(percent, width=10) =>
    filled = math.round(math.max(0, math.min(100, percent)) / 100.0 * width)
    str.repeat("█", filled) + str.repeat("░", width - filled)

f_get_bias(delta_pct) =>
    delta_pct > up_threshold ? "supports an uptrend" : delta_pct < down_threshold ? "supports a downtrend" : "no clear bias"

// ── VARIABLES ────────────────────────────────────────────────────────────
var box dash_box = na
var array<label> dash_labels = array.new<label>()
var table dash_table = na

var float buy_vol     = na
var float sell_vol    = na
var float total_vol   = na
var float delta_val   = na
var float delta_pct   = na
var float poc_price   = na
var float poc_vol_pct = na
var float poc_delta   = na

// ── MAIN LOGIC ───────────────────────────────────────────────────────────
if barstate.islast
    // Intrabar Volume Delta
    if use_footprint
        fp = request.footprint(ticks_per_row, va_percent)
        if not na(fp)
            buy_vol    := fp.buy_volume()
            sell_vol   := fp.sell_volume()
            total_vol  := buy_vol + sell_vol
            delta_val  := fp.delta()
            delta_pct  := total_vol > 0 ? delta_val / total_vol * 100 : 0.0

            poc_row = fp.poc()
            if not na(poc_row)
                poc_price   := (poc_row.up_price() + poc_row.down_price()) / 2.0
                poc_vol_pct := total_vol > 0 ? poc_row.total_volume() / total_vol * 100 : 0.0
                poc_delta   := poc_row.delta()
    else
        [ltf_vol, ltf_close, ltf_open] = request.security_lower_tf(syminfo.tickerid, lower_tf, [volume, close, open])
        if array.size(ltf_vol) > 0
            buy_v = 0.0
            sell_v = 0.0
            for i = 0 to array.size(ltf_vol) - 1
                v = array.get(ltf_vol, i)
                c = array.get(ltf_close, i)
                o = array.get(ltf_open, i)
                if c > o
                    buy_v += v
                else if c < o
                    sell_v += v
                else
                    buy_v += v * 0.5
                    sell_v += v * 0.5
            buy_vol    := buy_v
            sell_vol   := sell_v
            total_vol  := buy_v + sell_v
            delta_val  := buy_v - sell_v
            delta_pct  := total_vol > 0 ? delta_val / total_vol * 100 : 0.0

    // Lookback Bias
    float lb_buy = 0.0, lb_sell = 0.0, lb_delta = 0.0, lb_total = 0.0
    for i = 0 to recent_lookback - 1
        v = volume[i]
        lb_total += v
        if close[i] > open[i]
            lb_buy += v
            lb_delta += v * 0.6
        else if close[i] < open[i]
            lb_sell += v
            lb_delta -= v * 0.6
        else
            lb_buy += v * 0.5
            lb_sell += v * 0.5
    lb_delta_pct = lb_total > 0 ? lb_delta / lb_total * 100 : 0.0
    bias_text = f_get_bias(lb_delta_pct)

    divergence_bullish = delta_pct > up_threshold and lb_delta_pct < down_threshold
    divergence_bearish = delta_pct < down_threshold and lb_delta_pct > up_threshold
    divergence_text = (divergence_bullish or divergence_bearish) ? "Detected" : "None"

    // ── CVD CALCULATION ──────────────────────────────────────────────────
    float cvd_buy = 0.0
    float cvd_sell = 0.0
    float cvd_buy_prev = 0.0
    float cvd_sell_prev = 0.0

    int max_look = 1000
    int start_i = max_look

    for i = 0 to max_look - 1
        bool is_start = cvd_period == "Daily" ? is_new_day[i] : is_new_sess[i]
        if is_start
            start_i := i
            break

    for i = 0 to start_i
        v = volume[i]
        if close[i] > open[i]
            cvd_buy += v
            if i > 0
                cvd_buy_prev += v
        else if close[i] < open[i]
            cvd_sell += v
            if i > 0
                cvd_sell_prev += v
        else
            cvd_buy += v * 0.5
            cvd_sell += v * 0.5
            if i > 0
                cvd_buy_prev += v * 0.5
                cvd_sell_prev += v * 0.5

    float cvd_total = cvd_buy + cvd_sell
    float cvd_delta = cvd_buy - cvd_sell
    float cvd_pct   = cvd_total > 0 ? cvd_delta / cvd_total * 100 : 0.0
    float cvd_delta_prev = cvd_buy_prev - cvd_sell_prev

    string cvd_status = "Stable"
    if cvd_delta > 0 and cvd_delta_prev <= 0
        cvd_status := "Flipped Bullish"
    else if cvd_delta < 0 and cvd_delta_prev >= 0
        cvd_status := "Flipped Bearish"
    else if math.abs(cvd_delta) < math.abs(cvd_delta_prev) * 0.97
        cvd_status := "Thinning"
    else if cvd_delta > cvd_delta_prev
        cvd_status := "Building Up"
    else if cvd_delta < cvd_delta_prev
        cvd_status := "Building Down"

    // Display Strings
    buy_pct  = total_vol > 0 ? buy_vol / total_vol * 100 : 0
    sell_pct = total_vol > 0 ? sell_vol / total_vol * 100 : 0

    buy_str   = str.tostring(buy_vol, format.volume) + " (" + str.tostring(buy_pct, "#") + "%)"
    sell_str  = str.tostring(sell_vol, format.volume) + " (" + str.tostring(sell_pct, "#") + "%)"
    delta_str = (delta_val >= 0 ? "+" : "") + str.tostring(delta_val, format.volume)

    lb_buy_str   = str.tostring(lb_buy, format.volume)
    lb_sell_str  = str.tostring(lb_sell, format.volume)
    lb_delta_str = (lb_delta >= 0 ? "+" : "") + str.tostring(lb_delta, format.volume)

    poc_str = not na(poc_price) 
         ? str.tostring(poc_price, format.price) + " | " + str.tostring(poc_vol_pct, "#.##") + "% (" + (poc_delta >= 0 ? "+" : "") + str.tostring(poc_delta, format.volume) + " Δ)"
         : "Premium mode only for detailed POC"

    buy_bar  = f_progress_bar(buy_pct)
    sell_bar = f_progress_bar(sell_pct)

    // CVD strings
    cvd_buy_str  = str.tostring(cvd_buy, format.volume) + " (" + str.tostring(cvd_total > 0 ? cvd_buy / cvd_total * 100 : 0, "#") + "%)"
    cvd_sell_str = str.tostring(cvd_sell, format.volume) + " (" + str.tostring(cvd_total > 0 ? cvd_sell / cvd_total * 100 : 0, "#") + "%)"
    cvd_delta_str = (cvd_delta >= 0 ? "+" : "") + str.tostring(cvd_delta, format.volume) + " (" + str.tostring(cvd_pct, "#.#") + "%)"

    // ── CLEAN PREVIOUS OBJECTS ───────────────────────────────────────────
    if not na(dash_box)
        box.delete(dash_box)
    for lbl in dash_labels
        label.delete(lbl)
    array.clear(dash_labels)
    if not na(dash_table)
        table.delete(dash_table)

    // ── DRAW DASHBOARD ───────────────────────────────────────────────────
    if dashboard_pos == "Near Price"
        float row_height = near_spacing_method == "ATR (Stable)" ? atr_spacing : orig_spacing
        int x_pos = bar_index + 3

        float y_top = na
        float y_bot = na

        if near_spacing_method == "ATR (Stable)"
            y_top := close + row_height * (size_preset == "Default" ? 12.0 : 10.0)
            y_bot := close - row_height * 2.2
        else
            y_top := close + row_height * (size_preset == "Default" ? 16 : 13)
            y_bot := close - row_height * 1.8

        dash_box := box.new(x_pos - 1, y_top, x_pos + math.round(12 * scale), y_bot,
             border_color = color.new(color.gray, 70), bgcolor = color.new(color.black, 85), border_width = 1)

        float y = y_top - row_height * (near_spacing_method == "ATR (Stable)" ? 0.9 : 1.2)

        // Original rows
        array.push(dash_labels, label.new(x_pos, y, "Intrabar Total   " + str.tostring(total_vol, format.volume), style=label.style_label_left, color=color.new(color.gray, 80), textcolor=color.white, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "Buy     " + buy_str + "  " + buy_bar, style=label.style_label_left, color=color.new(buy_color, 70), textcolor=buy_color, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "Sell    " + sell_str + "  " + sell_bar, style=label.style_label_left, color=color.new(sell_color, 70), textcolor=sell_color, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "Delta   " + delta_str, style=label.style_label_left, color=color.new(delta_val >= 0 ? buy_color : sell_color, 70), textcolor=delta_val >= 0 ? buy_color : sell_color, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "Lookback Bias (" + str.tostring(recent_lookback) + ")  " + bias_text, style=label.style_label_left, color=color.new(lb_delta >= 0 ? buy_color : (lb_delta <= 0 ? sell_color : color.gray), 70), textcolor=lb_delta >= 0 ? buy_color : (lb_delta <= 0 ? sell_color : color.gray), size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "LB Buy  " + lb_buy_str + "   LB Sell  " + lb_sell_str + "   LB Δ " + lb_delta_str, style=label.style_label_left, color=color.new(color.gray, 80), textcolor=color.white, size=text_size, xloc=xloc.bar_index))
        y -= row_height

        div_color = divergence_bullish ? color.new(color.green, 70) : divergence_bearish ? color.new(color.red, 70) : color.new(color.gray, 70)
        array.push(dash_labels, label.new(x_pos, y, "Divergence  " + divergence_text, style=label.style_label_left, color=div_color, textcolor=divergence_bullish or divergence_bearish ? color.white : color.gray, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "High P. " + poc_str, style=label.style_label_left, color=color.new(#FFD700, 60), textcolor=#FFD700, size=text_size, xloc=xloc.bar_index))
        y -= row_height

        // CVD Section
        array.push(dash_labels, label.new(x_pos, y, "CVD (" + cvd_period + ")", style=label.style_label_left, color=color.new(color.blue, 70), textcolor=color.white, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "CVD Buy  " + cvd_buy_str, style=label.style_label_left, color=color.new(buy_color, 70), textcolor=buy_color, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "CVD Sell " + cvd_sell_str, style=label.style_label_left, color=color.new(sell_color, 70), textcolor=sell_color, size=text_size, xloc=xloc.bar_index))
        y -= row_height
        array.push(dash_labels, label.new(x_pos, y, "CVD Δ    " + cvd_delta_str, style=label.style_label_left, color=color.new(cvd_delta >= 0 ? buy_color : sell_color, 70), textcolor=cvd_delta >= 0 ? buy_color : sell_color, size=text_size, xloc=xloc.bar_index))
        y -= row_height

        status_col = cvd_status == "Flipped Bullish" or cvd_status == "Building Up" ? color.new(buy_color, 70) : cvd_status == "Flipped Bearish" or cvd_status == "Building Down" ? color.new(sell_color, 70) : cvd_status == "Thinning" ? color.new(color.orange, 70) : color.new(color.gray, 70)
        array.push(dash_labels, label.new(x_pos, y, "CVD Status  " + cvd_status, style=label.style_label_left, color=status_col, textcolor=color.white, size=text_size, xloc=xloc.bar_index))

    else
        // Fixed corner version (table)
        table_pos = dashboard_pos == "Upper Right" ? position.top_right : position.bottom_right

        dash_table := table.new(table_pos, 1, 13,
             bgcolor = color.new(color.black, 85),
             border_width = 1,
             border_color = color.new(color.gray, 70),
             frame_width = 1,
             frame_color = color.new(color.gray, 50))

        table.cell(dash_table, 0, 0, "Intrabar Total   " + str.tostring(total_vol, format.volume), text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 1, "Buy     " + buy_str + "  " + buy_bar, text_color=buy_color, bgcolor=color.new(buy_color, 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 2, "Sell    " + sell_str + "  " + sell_bar, text_color=sell_color, bgcolor=color.new(sell_color, 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 3, "Delta   " + delta_str, text_color=delta_val >= 0 ? buy_color : sell_color, bgcolor=color.new(delta_val >= 0 ? buy_color : sell_color, 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 4, "Lookback Bias (" + str.tostring(recent_lookback) + ")  " + bias_text, text_color=lb_delta >= 0 ? buy_color : (lb_delta <= 0 ? sell_color : color.gray), bgcolor=color.new(lb_delta >= 0 ? buy_color : (lb_delta <= 0 ? sell_color : color.gray), 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 5, "LB Buy  " + lb_buy_str + "   LB Sell  " + lb_sell_str + "   LB Δ " + lb_delta_str, text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=text_size, text_halign=text.align_left)

        div_color = divergence_bullish ? color.new(color.green, 70) : divergence_bearish ? color.new(color.red, 70) : color.new(color.gray, 70)
        table.cell(dash_table, 0, 6, "Divergence  " + divergence_text, text_color=divergence_bullish or divergence_bearish ? color.white : color.gray, bgcolor=div_color, text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 7, "High P. " + poc_str, text_color=#FFD700, bgcolor=color.new(#FFD700, 60), text_size=text_size, text_halign=text.align_left)

        table.cell(dash_table, 0, 8, "CVD (" + cvd_period + ")", text_color=color.white, bgcolor=color.new(color.blue, 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 9, "CVD Buy  " + cvd_buy_str, text_color=buy_color, bgcolor=color.new(buy_color, 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 10, "CVD Sell " + cvd_sell_str, text_color=sell_color, bgcolor=color.new(sell_color, 70), text_size=text_size, text_halign=text.align_left)
        table.cell(dash_table, 0, 11, "CVD Δ    " + cvd_delta_str, text_color=cvd_delta >= 0 ? buy_color : sell_color, bgcolor=color.new(cvd_delta >= 0 ? buy_color : sell_color, 70), text_size=text_size, text_halign=text.align_left)

        status_col = cvd_status == "Flipped Bullish" or cvd_status == "Building Up" ? color.new(buy_color, 70) : cvd_status == "Flipped Bearish" or cvd_status == "Building Down" ? color.new(sell_color, 70) : cvd_status == "Thinning" ? color.new(color.orange, 70) : color.new(color.gray, 70)
        table.cell(dash_table, 0, 12, "CVD Status  " + cvd_status, text_color=color.white, bgcolor=status_col, text_size=text_size, text_halign=text.align_left)

// ── POC MARKER ───────────────────────────────────────────────────────────
var line poc_line = na
var label poc_lbl = na

if barstate.islast and show_poc_line and not na(poc_price) and use_footprint
    line.delete(poc_line)
    label.delete(poc_lbl)
    poc_line := line.new(bar_index, poc_price, bar_index + 2, poc_price, color=poc_line_color, width=2, style=line.style_dashed, xloc=xloc.bar_index)
    poc_lbl  := label.new(bar_index + 2, poc_price, "High Vol POC", style=label.style_label_left, color=color.new(poc_line_color, 0), textcolor=color.black, size=size.small, xloc=xloc.bar_index)
````
