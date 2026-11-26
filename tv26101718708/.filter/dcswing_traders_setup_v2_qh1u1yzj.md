# dc_Swing Traders Setup v2

- url: https://www.tradingview.com/script/QH1u1yzj-dc-Swing-Traders-Setup-v2/
- type: indicator
- pine_id: PUB;8df73ca4b3b94dfe9653ddb1b5ea60a9
- version: 3.0

## Description

This script/indicator allows the swing trader to easily setup multiple moving averages on their chart that are timeframe specific. The MA's automatically changes the underlying periods for you the MA's are smoothed and calculated on the intraday, ala Brian Shannon setup and others.

It shows the daily vwap intraday as well for entry tactics.

The tool also has a convenient info box to give the user a quick read on ADR, 50d extension, last earning and volume traded. Basically it is all you need for most swing trading systems, in one indicator.

## Source Code

````pine
//@version=6
indicator("dc_Swing Traders Setup", "", overlay=true, max_lines_count=500, max_labels_count=50, explicit_plot_zorder=true)

// ============================================================================
// GROUPS
// ============================================================================
g_ma     = "Moving Averages"
g_ma_lbl = "MA Labels"
g_vwap   = "VWAP (intraday only)"
g_info   = "Info Box"
g_pad    = "Info Box Padding"
g_calc   = "Info Box Calculations"
g_disp   = "Plot Display"

// ============================================================================
// INPUTS — MA
// ============================================================================
show_ma1 = input.bool(true, "Show 5d equivalent", group=g_ma, inline="ma1")
col_ma1  = input.color(color.new(#006B30, 0), "", group=g_ma, inline="ma1")
show_ma2 = input.bool(true, "Show 10d equivalent", group=g_ma, inline="ma2")
col_ma2  = input.color(color.new(#2C5AA0, 0), "", group=g_ma, inline="ma2")
show_ma3 = input.bool(true, "Show 20d equivalent", group=g_ma, inline="ma3")
col_ma3  = input.color(color.new(#B07AB0, 0), "", group=g_ma, inline="ma3")
show_ma4 = input.bool(true, "Show 50d equivalent", group=g_ma, inline="ma4")
col_ma4  = input.color(color.new(#FF0000, 0), "", group=g_ma, inline="ma4")
show_ma5 = input.bool(true, "Show 200d equivalent", group=g_ma, inline="ma5")
col_ma5  = input.color(color.new(#000000, 0), "", group=g_ma, inline="ma5")

// ============================================================================
// DISPLAY — TV DEFAULT LABEL CLUTTER OFF
// ============================================================================
show_price_scale_labels = input.bool(false, "Show values on price scale", group=g_disp)
show_status_line_values = input.bool(false, "Show values in chart header/status line", group=g_disp)
show_data_window_values = input.bool(false, "Show values in Data Window", group=g_disp)

plot_display = display.pane + (show_price_scale_labels ? display.price_scale : display.none) + (show_status_line_values ? display.status_line : display.none) + (show_data_window_values ? display.data_window : display.none)

// ============================================================================
// MA END LABELS — ON BY DEFAULT
// ============================================================================
show_labels = input.bool(true, "Show MA labels on last bar", group=g_ma_lbl)
ma_lbl_txt = input.color(color.white, "Label text color", group=g_ma_lbl)
ma_lbl_bg_mode = input.string("MA color (semi-transparent)", "Label background", options=["MA color (semi-transparent)", "Custom color", "Transparent"], group=g_ma_lbl)
ma_lbl_bg = input.color(color.new(#202020, 30), "Custom background color", group=g_ma_lbl)
ma_lbl_bg_alpha = input.int(15, "MA-color background transparency", minval=0, maxval=100, group=g_ma_lbl)
ma_lbl_size = input.string("Small", "Label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_ma_lbl)
ma_lbl_offset = input.int(2, "MA label distance from last bar", minval=0, maxval=50, group=g_ma_lbl)

// ============================================================================
// VWAP
// ============================================================================
show_vwap = input.bool(true, "Show VWAP on intraday charts", group=g_vwap)
col_vwap = input.color(color.orange, "VWAP color", group=g_vwap)
vwap_width = input.int(1, "VWAP dot width", minval=1, maxval=4, group=g_vwap)

// ============================================================================
// INFO BOX
// ============================================================================
show_info = input.bool(true, "Show info box", group=g_info)
info_pos = input.string("Bottom Left", "Position", options=["Top Left", "Top Right", "Top Center", "Middle Left", "Middle Right", "Middle Center", "Bottom Left", "Bottom Right", "Bottom Center"], group=g_info)
info_align = input.string("Right", "Text alignment", options=["Left", "Center", "Right"], group=g_info)
info_bg = input.color(color.new(#0057D9, 0), "Background color", group=g_info)
info_txt = input.color(color.white, "Text color", group=g_info)
info_size = input.string("Normal", "Text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_info)
show_eps_row = input.bool(true, "Show last EPS row", group=g_info)
col_beat = input.color(color.new(#00C853, 0), "EPS beat color", group=g_info)
col_miss = input.color(color.new(#FF1744, 0), "EPS miss color", group=g_info)
col_atrs_pos = input.color(color.new(#B8F7B8, 0), "ATRs from 50d positive color", group=g_info)
col_atrs_neg = input.color(color.new(#FFB08A, 0), "ATRs from 50d negative color", group=g_info)

// ============================================================================
// PADDING
// ============================================================================
pad_left = input.int(1, "Padding left", minval=0, maxval=20, group=g_pad)
pad_right = input.int(1, "Padding right", minval=0, maxval=20, group=g_pad)
pad_top = input.int(0, "Padding top", minval=0, maxval=10, group=g_pad)
pad_bottom = input.int(2, "Padding bottom", minval=0, maxval=10, group=g_pad)

// ============================================================================
// CALCULATIONS
// ============================================================================
atr_len = input.int(14, "ATR length (days)", minval=1, group=g_calc)
vol_len = input.int(20, "Avg volume length (days)", minval=1, group=g_calc)

// ============================================================================
// TIMEFRAME
// ============================================================================
tf_mins = timeframe.in_seconds(timeframe.period) / 60
is_daily_or_higher = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
is_5m_bucket = not is_daily_or_higher and tf_mins <= 14
is_30m_bucket = not is_daily_or_higher and tf_mins >= 15 and tf_mins <= 60

len1 = is_daily_or_higher ? 5 : is_30m_bucket ? 65 : is_5m_bucket ? 390 : 65
len2 = is_daily_or_higher ? 10 : is_30m_bucket ? 130 : is_5m_bucket ? 780 : 130
len3 = is_daily_or_higher ? 20 : is_30m_bucket ? 260 : is_5m_bucket ? 1560 : 260
len4 = is_daily_or_higher ? 50 : is_30m_bucket ? 650 : is_5m_bucket ? 3900 : 650
len5 = is_daily_or_higher ? 200 : is_30m_bucket ? 2600 : is_5m_bucket ? 15600 : 2600

MAX_LEN = 5000

nat_ma1 = len1 <= MAX_LEN ? ta.sma(close, len1) : na
nat_ma2 = len2 <= MAX_LEN ? ta.sma(close, len2) : na
nat_ma3 = len3 <= MAX_LEN ? ta.sma(close, len3) : na
nat_ma4 = len4 <= MAX_LEN ? ta.sma(close, len4) : na
nat_ma5 = len5 <= MAX_LEN ? ta.sma(close, len5) : na

sec_ma1 = request.security(syminfo.tickerid, "D", ta.sma(close, 5))
sec_ma2 = request.security(syminfo.tickerid, "D", ta.sma(close, 10))
sec_ma3 = request.security(syminfo.tickerid, "D", ta.sma(close, 20))
sec_ma4 = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
sec_ma5 = request.security(syminfo.tickerid, "D", ta.sma(close, 200))

ma1 = len1 <= MAX_LEN ? nat_ma1 : sec_ma1
ma2 = len2 <= MAX_LEN ? nat_ma2 : sec_ma2
ma3 = len3 <= MAX_LEN ? nat_ma3 : sec_ma3
ma4 = len4 <= MAX_LEN ? nat_ma4 : sec_ma4
ma5 = len5 <= MAX_LEN ? nat_ma5 : sec_ma5

plot(show_ma1 ? ma1 : na, "5d", color=col_ma1, linewidth=1, display=plot_display)
plot(show_ma2 ? ma2 : na, "10d", color=col_ma2, linewidth=2, display=plot_display)
plot(show_ma3 ? ma3 : na, "20d", color=col_ma3, linewidth=3, display=plot_display)
plot(show_ma4 ? ma4 : na, "50d", color=col_ma4, linewidth=3, display=plot_display)
plot(show_ma5 ? ma5 : na, "200d", color=col_ma5, linewidth=3, display=plot_display)

// ============================================================================
// LABEL HELPERS
// ============================================================================
f_lbl_size(s) =>
    r = size.normal
    if s == "Tiny"
        r := size.tiny
    else if s == "Small"
        r := size.small
    else if s == "Large"
        r := size.large
    else if s == "Huge"
        r := size.huge
    r

f_lbl_bg(ma_color) =>
    r = ma_lbl_bg
    if ma_lbl_bg_mode == "MA color (semi-transparent)"
        r := color.new(ma_color, ma_lbl_bg_alpha)
    else if ma_lbl_bg_mode == "Transparent"
        r := color.new(color.black, 100)
    r

ma_lbl_sz = f_lbl_size(ma_lbl_size)

var array<label> ma_labels = array.new<label>()

f_clear_ma_labels() =>
    if array.size(ma_labels) > 0
        for i = 0 to array.size(ma_labels) - 1
            label.delete(array.get(ma_labels, i))
        array.clear(ma_labels)

if show_labels and barstate.islast
    f_clear_ma_labels()
    x_ma_lbl = bar_index + ma_lbl_offset

    if show_ma1 and not na(ma1)
        l = label.new(x_ma_lbl, ma1, "5d", color=f_lbl_bg(col_ma1), textcolor=ma_lbl_txt, style=label.style_label_left, size=ma_lbl_sz)
        array.push(ma_labels, l)

    if show_ma2 and not na(ma2)
        l = label.new(x_ma_lbl, ma2, "10d", color=f_lbl_bg(col_ma2), textcolor=ma_lbl_txt, style=label.style_label_left, size=ma_lbl_sz)
        array.push(ma_labels, l)

    if show_ma3 and not na(ma3)
        l = label.new(x_ma_lbl, ma3, "20d", color=f_lbl_bg(col_ma3), textcolor=ma_lbl_txt, style=label.style_label_left, size=ma_lbl_sz)
        array.push(ma_labels, l)

    if show_ma4 and not na(ma4)
        l = label.new(x_ma_lbl, ma4, "50d", color=f_lbl_bg(col_ma4), textcolor=ma_lbl_txt, style=label.style_label_left, size=ma_lbl_sz)
        array.push(ma_labels, l)

    if show_ma5 and not na(ma5)
        l = label.new(x_ma_lbl, ma5, "200d", color=f_lbl_bg(col_ma5), textcolor=ma_lbl_txt, style=label.style_label_left, size=ma_lbl_sz)
        array.push(ma_labels, l)

if not show_labels and barstate.islast
    f_clear_ma_labels()

// ============================================================================
// VWAP
// ============================================================================
is_intraday = not is_daily_or_higher
vwap_val = is_intraday and show_vwap ? ta.vwap(hlc3) : na
plot(vwap_val, "VWAP", color=col_vwap, linewidth=vwap_width, style=plot.style_circles, display=plot_display)

// ============================================================================
// INFO BOX DATA
// ============================================================================
d_atr = request.security(syminfo.tickerid, "D", ta.atr(atr_len))
d_close = request.security(syminfo.tickerid, "D", close)
d_sma50 = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
d_atr_pct = d_close != 0 ? 100 * d_atr / d_close : na
atrs_from_50 = d_atr > 0 ? (d_close - d_sma50) / d_atr : na
d_avgvol = request.security(syminfo.tickerid, "D", ta.sma(volume, vol_len))

eps_actual = request.earnings(syminfo.tickerid, earnings.actual, ignore_invalid_symbol=true)
eps_estimate = request.earnings(syminfo.tickerid, earnings.estimate, ignore_invalid_symbol=true)
eps_surprise_pct = na(eps_estimate) or eps_estimate == 0 ? na : (eps_actual - eps_estimate) / math.abs(eps_estimate) * 100

// ============================================================================
// INFO HELPERS
// ============================================================================
f_pos(s) =>
    s == "Top Left" ? position.top_left :
     s == "Top Right" ? position.top_right :
     s == "Top Center" ? position.top_center :
     s == "Middle Left" ? position.middle_left :
     s == "Middle Right" ? position.middle_right :
     s == "Middle Center" ? position.middle_center :
     s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Center" ? position.bottom_center :
     position.bottom_left

f_align(s) =>
    s == "Left" ? text.align_left :
     s == "Center" ? text.align_center :
     text.align_right

f_size(s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     s == "Huge" ? size.huge :
     size.normal

f_volfmt(v) =>
    na(v) ? "n/a" :
     v >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" :
     v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" :
     v >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" :
     str.tostring(v, "#")

f_spaces(n) =>
    s = ""
    if n > 0
        for i = 0 to n - 1
            s := s + " "
    s

f_pad(txt) =>
    f_spaces(pad_left) + txt + f_spaces(pad_right)

f_atrs_text(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.##") + "x"

f_atrs_color(v) =>
    na(v) ? info_txt : v >= 0 ? col_atrs_pos : col_atrs_neg

// ============================================================================
// INFO TABLE
// ============================================================================
transparent = color.new(color.black, 100)

var table info_tbl = na

data_rows = show_eps_row ? 5 : 4
total_rows = pad_top + data_rows + pad_bottom

if show_info and barstate.islast
    if not na(info_tbl)
        table.delete(info_tbl)

    info_tbl := table.new(f_pos(info_pos), 2, total_rows, bgcolor=transparent, border_width=0)

    r0 = pad_top

    table.cell(info_tbl, 0, r0, f_pad("ATR $ (" + str.tostring(atr_len) + "d)"), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))
    table.cell(info_tbl, 1, r0, f_pad(na(d_atr) ? "n/a" : "$" + str.tostring(d_atr, "#.##")), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))

    table.cell(info_tbl, 0, r0 + 1, f_pad("ATRs from 50d"), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))
    table.cell(info_tbl, 1, r0 + 1, f_pad(f_atrs_text(atrs_from_50)), bgcolor=info_bg, text_color=f_atrs_color(atrs_from_50), text_size=f_size(info_size), text_halign=f_align(info_align))

    table.cell(info_tbl, 0, r0 + 2, f_pad("ATR% (" + str.tostring(atr_len) + "d)"), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))
    table.cell(info_tbl, 1, r0 + 2, f_pad(na(d_atr_pct) ? "n/a" : str.tostring(d_atr_pct, "#.##") + "%"), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))

    table.cell(info_tbl, 0, r0 + 3, f_pad("Avg Vol (" + str.tostring(vol_len) + "d)"), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))
    table.cell(info_tbl, 1, r0 + 3, f_pad(f_volfmt(d_avgvol)), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))

    if show_eps_row
        eps_label = "Last EPS"
        eps_text = "n/a"
        eps_color = info_txt

        if not na(eps_actual)
            arrow = ""
            pct = ""

            if not na(eps_surprise_pct)
                if eps_surprise_pct > 0.05
                    arrow := " ▲ "
                    eps_color := col_beat
                else if eps_surprise_pct < -0.05
                    arrow := " ▼ "
                    eps_color := col_miss
                else
                    arrow := " = "

                pct := str.tostring(eps_surprise_pct, "+#.#;-#.#") + "%"

            eps_text := "$" + str.tostring(eps_actual, "#.##") + arrow + pct

        table.cell(info_tbl, 0, r0 + 4, f_pad(eps_label), bgcolor=info_bg, text_color=info_txt, text_size=f_size(info_size), text_halign=f_align(info_align))
        table.cell(info_tbl, 1, r0 + 4, f_pad(eps_text), bgcolor=info_bg, text_color=eps_color, text_size=f_size(info_size), text_halign=f_align(info_align))

    if pad_bottom > 0
        for r = r0 + data_rows to total_rows - 1
            table.cell(info_tbl, 0, r, " ", bgcolor=transparent, text_color=transparent, text_size=f_size(info_size))
            table.cell(info_tbl, 1, r, " ", bgcolor=transparent, text_color=transparent, text_size=f_size(info_size))
````
