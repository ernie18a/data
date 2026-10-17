# CandelaCharts - Killzone VWAP

- url: https://www.tradingview.com/script/1Fv5bSN3-CandelaCharts-Killzone-VWAP/
- type: indicator
- pine_id: PUB;cf70df173011454fb4a7b1eddd66f41a
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - Killzone VWAP[/b] indicator provides a specialized Volume Weighted Average Price (VWAP) calculation for specific intraday sessions (Killzones) and the daily period. It includes advanced features like Standard Deviation bands and Rolling VWAP calculation, making it a powerful tool for volume-based trend analysis.

📦 [b]Features[/b]

[list]
[*] [b]5 Customizable Sessions[/b]: Tracks VWAP across Asia, London, NY AM, NY Lunch, and NY PM sessions.
[*] [b]Daily VWAP Modes[/b]:
[list]
[*] [b]Classic[/b]: Resets at the start of each daily session.
[*] [b]Rolling[/b]: Provides a 24-hour continuous rolling average for a smoother representation of long-term volume-weighted price.
[/list]
[*] [b]Standard Deviation Bands[/b]: Up to two levels of bands (±1, ±2) for volatility analysis and identifying overextended price levels.
[*] [b]Historical Labels[/b]: Automatically marks session-end levels with labels to identify where previous institutional interest concluded.
[*] [b]Session Backgrounds[/b]: Highlights active killzones with distinct background highlights for better visual organization.
[*] [b]Session Dividers[/b]: Clear vertical dividers with customizable line styles and widths.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Source[/b]: Price source for VWAP calculation (default: `hlc3`).
[*] [b]StDev Mult (1 & 2)[/b]: Custom multipliers for the volatility bands.
[*] [b]Timezone[/b]: Supports Exchange, UTC, and America/New_York.
[*] [b]Line Width & Opacity[/b]: Customize the appearance of StDev bands.
[*] [b]Session Name & Time[/b]: Configure exact labels and windows.
[*] [b]Show Std Dev Bands[/b]: Toggle volatility bands for this specific session.
[*] [b]Show Labels[/b]: Toggle current and historical session-end labels.
[*] [b]Show Background & Divider[/b]: Visual organizers for the active period.
[*] [b]Daily VWAP[/b]: Toggle, choose calculation type (Classic/Rolling), and configure bands/labels.
[*] [b]Dividers[/b]: Global style, width, and color settings for vertical lines.
[/list]

⚡️ [b]Showcase[/b]

[i]VWAP Line[/i]
https://www.tradingview.com/x/KvPPxYZE/

[i]VWAP with Standard Deviation Bands[/i]
https://www.tradingview.com/x/ptfEcfDX/

[i]Daily Rolling VWAP[/i]
https://www.tradingview.com/x/RCncFct6/

[i]Session Backgrounds and Session Dividers[/i]
https://www.tradingview.com/x/2Z7p24k3/

🚨 [b]Alerts[/b]

Standard TradingView alerts for session start/end can be configured based on the visualized periods.

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator('CandelaCharts - Killzone VWAP', shorttitle = 'CandelaCharts - Killzone VWAP', overlay = true, max_labels_count = 500, max_lines_count = 500)














// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_white                        = color.white
colors_black                        = color.black
colors_purple                       = color.purple
colors_red                          = color.red
colors_gray                         = color.gray
colors_blue                         = color.blue
colors_orange                       = color.orange
colors_green                        = color.green
colors_aqua                         = color.aqua
colors_yellow                       = color.yellow
color_transparent                   = #ffffff00

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

// # General ----------------------------------------------------------------- #

general_font                            = input.string("Monospace", "Text                      ", inline = "1.0", options = ["Default", "Monospace"], group = "General")
general_text                            = input.string("Tiny", "", inline = "1.0", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = "General", tooltip = "Customize global text size and style")
general_brand_show                      = input.bool(false, "Hide Brand", group = "General")

// # Settings ---------------------------------------------------------------- #

setting_source                          = input.source(hlc3, "VWAP Source", group = "Settings")
setting_stdev_mult_1                    = input.float(1.0, "StDev mult 1", group = "Settings")
setting_stdev_mult_2                    = input.float(2.0, "StDev mult 2", group = "Settings")
setting_off_mult                        = input.int(8, 'Label offset', group = "Settings")
setting_timezone                        = input.string("America/New_York", "Timezone", options = ["America/New_York", "UTC", "Exchange"], group = "Settings")
setting_stdev_width                     = input.int(1, "StDev Line Width", minval = 1, maxval = 5, group = "Settings")
setting_stdev_transp                    = input.int(40, "StDev Opacity", minval = 0, maxval = 100, group = "Settings")

// Derived values
st_transp = 100 - setting_stdev_transp
setting_color_stdev_p2                  = input.color(colors_orange, "+2 StDev Color", group = "Settings")
setting_color_stdev_p1                  = input.color(colors_green, "±1 StDev Color", group = "Settings")
setting_color_stdev_m2                  = input.color(colors_blue, "-2 StDev Color", group = "Settings")

// # Session 1 --------------------------------------------------------------- #

first_session_show                      = input.bool(true, "Show", group = "First Session")
first_session_divider                   = input.bool(false, "Show Divider", group = "First Session")
first_session_name                      = input.string("AS", "Session Name", group = "First Session")
first_session_tf                        = input.session("2000-0000", "Session Time", group = "First Session")
first_session_color                     = input.color(colors_aqua, "Session Color", group = "First Session")
first_session_std_show                  = input.bool(false, "Show Std Dev Bands", group = "First Session")
first_session_lbl_show                  = input.bool(true, "Show Labels", group = "First Session")
first_session_bg_show                   = input.bool(true, "Show Background", group = "First Session")

// # Session 2 --------------------------------------------------------------- #

second_session_show                     = input.bool(true, "Show", group = "Second Session")
second_session_divider                  = input.bool(false, "Show Divider", group = "Second Session")
second_session_name                     = input.string("LO", "Session Name", group = "Second Session")
second_session_tf                       = input.session("0200-0500", "Session Time", group = "Second Session")
second_session_color                    = input.color(colors_blue, "Session Color", group = "Second Session")
second_session_std_show                 = input.bool(false, "Show Std Dev Bands", group = "Second Session")
second_session_lbl_show                 = input.bool(true, "Show Labels", group = "Second Session")
second_session_bg_show                  = input.bool(true, "Show Background", group = "Second Session")

// # Session 3 --------------------------------------------------------------- #

third_session_show                      = input.bool(true, "Show", group = "Third Session")
third_session_divider                   = input.bool(false, "Show Divider", group = "Third Session")
third_session_name                      = input.string("NYAM", "Session Name", group = "Third Session")
third_session_tf                        = input.session("0930-1100", "Session Time", group = "Third Session")
third_session_color                     = input.color(colors_red, "Session Color", group = "Third Session")
third_session_std_show                  = input.bool(false, "Show Std Dev Bands", group = "Third Session")
third_session_lbl_show                  = input.bool(true, "Show Labels", group = "Third Session")
third_session_bg_show                   = input.bool(true, "Show Background", group = "Third Session")

// # Session 4 --------------------------------------------------------------- #

forth_session_show                      = input.bool(true, "Show", group = "Fourth Session")
forth_session_divider                   = input.bool(false, "Show Divider", group = "Fourth Session")
forth_session_name                      = input.string("NYLA", "Session Name", group = "Fourth Session")
forth_session_tf                        = input.session("1200-1300", "Session Time", group = "Fourth Session")
forth_session_color                     = input.color(colors_orange, "Session Color", group = "Fourth Session")
forth_session_std_show                  = input.bool(false, "Show Std Dev Bands", group = "Fourth Session")
forth_session_lbl_show                  = input.bool(true, "Show Labels", group = "Fourth Session")
forth_session_bg_show                   = input.bool(true, "Show Background", group = "Fourth Session")

// # Session 5 --------------------------------------------------------------- #

fifth_session_show                      = input.bool(true, "Show", group = "Fifth Session")
fifth_session_divider                   = input.bool(false, "Show Divider", group = "Fifth Session")
fifth_session_name                      = input.string("NYPM", "Session Name", group = "Fifth Session")
fifth_session_tf                        = input.session("1330-1600", "Session Time", group = "Fifth Session")
fifth_session_color                     = input.color(colors_purple, "Session Color", group = "Fifth Session")
fifth_session_std_show                  = input.bool(false, "Show Std Dev Bands", group = "Fifth Session")
fifth_session_lbl_show                  = input.bool(true, "Show Labels", group = "Fifth Session")
fifth_session_bg_show                   = input.bool(true, "Show Background", group = "Fifth Session")

// # Daily VWAP -------------------------------------------------------------- #

show_vwap_daily                         = input.bool(true, 'Show Daily VWAP', group = "Daily VWAP")
daily_vwap_type                         = input.string("Classic", "Type", options = ["Classic", "Rolling"], group = "Daily VWAP")
show_std_daily                          = input.bool(false, 'Show Daily Std Dev Bands', group = "Daily VWAP")
show_label_daily                        = input.bool(true, 'Show Daily Labels', group = "Daily VWAP")

// # Dividers ---------------------------------------------------------------- #

divider_session_style                   = input.string('····', "Style", options = ['⎯⎯⎯', '----', '····'], group = "Dividers")
divider_session_width                   = input.int(1, "Width", minval = 1, maxval = 4, group = "Dividers")
divider_session_color                   = input.color(colors_gray, "Color", group = "Dividers")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   UDTs   |
// # ========================================================================= #

//#region

type UDT_Killzone
    string  name
    string  session_time
    bool    show
    bool    show_divider
    color   base_color
    bool    show_std
    bool    show_lbl
    bool    show_bg
    
    // Calculated values
    float   v       = na
    float   std     = na
    float   last_v  = na
    float   last_std = na
    bool    allowed = false
    
    // Previous state for new period detection
    bool    allowed_p = false

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Functions   |
// # ========================================================================= #

//#region

method text_size(string size) =>
    out = switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
    out

method line_style(string style) =>
    out = switch style
        '⎯⎯⎯'  => line.style_solid
        '----'   => line.style_dashed
        '····'   => line.style_dotted
    out

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace
    out

// @function            Calculates the cumulative average of `source` values sampled based on the specified `condition`.
avgWhen(series float source, series bool condition) =>
    float result = ta.cum(condition ? source : 0.0) / ta.cum(condition ? 1 : 0)

// @function            Calculates the average `source` value for the most recent `count` bars where the 
//                      specified `condition` is `true` and the `source` is not `na`.
avgWhenLast(series float source, series bool condition, series int count) =>
    float result = ta.sma(condition ? source : na, count)

// @function            Calculates the average `source` value for the bars where the `condition` is `true` across the 
//                      `length` most recent bars with non-na `source` data.
avgWhenInLast(series float source, series bool condition, series int length) =>
    bool  cond   = condition and not na(source)
    float result = math.sum(cond ? source : 0.0, length) / math.sum(cond ? 1 : 0, length)

// @function            Calculates the average `source` value for all bars with non-na `source` data since the latest 
//                      bar where the specified `condition` is `true`.
avgSince(series float source, series bool condition) =>
    var float lastTotal = 0.0
    var int   lastIndex = na
    var float lastNaCt  = na
    float     total     = ta.cum(nz(source))
    float     naBars    = ta.cum(na(source) ? 1 : 0)
    float result = if condition
        lastTotal := nz(total[1])
        lastIndex := bar_index - 1
        lastNaCt  := nz(naBars[1])
        source
    else
        (total - lastTotal) / (bar_index - lastIndex - naBars + lastNaCt)

// @function            Calculates the average of `source` values across bars where the `condition` is `true`
//                      and `source` is not `na` within a moving time window.
avgForTimeWhen(series float source, simple int ms, series bool condition = true, simple int minBars = 1) =>
    var array<float> sources   = array.new<float>()
    var array<int>   times     = array.new<int>()
    var float        result    = na
    var float        numerator = 0.0
    if condition and not na(source)
        sources.push(source)
        times.push(time)
        numerator += source
        while sources.size() > math.max(minBars, 0) and time - times.first() >= ms
            numerator -= sources.shift()
            times.shift()
        result := numerator / sources.size()
    sources.size() < minBars ? na : result

// @function            Calculates the sum of `source` values across bars where the `condition` is `true`
//                      and `source` is not `na` within a moving time window.
totalForTimeWhen(series float source, simple int ms, series bool condition = true, simple int minBars = 1) =>
    var array<float> sources   = array.new<float>(0)
    var array<int>   times     = array.new<int>(0)
    var float        result    = 0.0
    if condition and not na(source)
        sources.push(source)
        times.push(time)
        result += source
        while sources.size() > math.max(minBars, 0) and time - times.first() >= ms
            result -= sources.shift()
            times.shift()
    sources.size() < minBars ? na : result

// TradingView vwap function. Taken out stdev calcs to put in seperate function. 
calculate_vwap_logic(src_val, is_new_period) =>
    var float sum_src_vol = 0.0
    var float sum_vol = 0.0
    var float sum_src_src_vol = 0.0

    is_reset_bar = na(sum_src_vol[1]) or is_new_period

    sum_src_vol := is_reset_bar ? src_val * volume : src_val * volume + sum_src_vol[1]
    sum_vol := is_reset_bar ? volume : volume + sum_vol[1]
    sum_src_src_vol := is_reset_bar ? volume * math.pow(src_val, 2) : volume * math.pow(src_val, 2) + sum_src_src_vol[1]

    vwap_val = sum_src_vol / sum_vol
    variance = sum_src_src_vol / sum_vol - math.pow(vwap_val, 2)
    variance := variance < 0 ? 0 : variance
    st_dev = math.sqrt(variance)

    [vwap_val, st_dev]

// Standard Deviation Band calculation function
calculate_st_dev_bands(vwap_val, st_dev, st_dev_mult_1, st_dev_mult_2) =>
    upper_band_2 = vwap_val + st_dev * st_dev_mult_2
    upper_band_1 = vwap_val + st_dev * st_dev_mult_1
    lower_band_1 = vwap_val - st_dev * st_dev_mult_1
    lower_band_2 = vwap_val - st_dev * st_dev_mult_2
    [upper_band_2, upper_band_1, lower_band_1, lower_band_2]

f_draw_session_label(_x, _y, _text, _textcolor) =>
    var _label = label.new(x=_x, y=_y, text=_text, textcolor=_textcolor, style=label.style_none, size=text_size(general_text), text_font_family = font_style(general_font), xloc = xloc.bar_time)
    label.set_xy(_label, _x, _y)
    label.set_text(_label, _text)
    label.set_textcolor(_label, _textcolor)
    _label

f_create_historical_label(_x, _y, _text, _textcolor) =>
    label.new(x=_x, y=_y, text=_text, textcolor=_textcolor, style=label.style_none, size=text_size(general_text), text_font_family = font_style(general_font), xloc = xloc.bar_time)

// Method to draw historical labels at session end
method draw_session_end_labels(UDT_Killzone kz) =>
    // Trigger on the first bar after session ends
    is_end = not kz.allowed and kz.allowed_p
    if is_end and kz.show and kz.show_lbl
        final_v = kz.last_v
        final_std = kz.last_std
        // Calculate historical offset time using the session's bar width (prevents gap errors)
        int hist_offset = int(time[1] + nz(time[1] - time[2]) * setting_off_mult)
        
        if not na(final_v)
            f_create_historical_label(hist_offset, final_v, '⎯⎯⎯ ' + kz.name, kz.base_color)
            
            if kz.show_std and not na(final_std)
                f_create_historical_label(hist_offset, final_v + final_std * setting_stdev_mult_2, '⎯⎯⎯ ' + kz.name + ' +2', color.new(setting_color_stdev_p2, st_transp))
                f_create_historical_label(hist_offset, final_v + final_std * setting_stdev_mult_1, '⎯⎯⎯ ' + kz.name + ' +1', color.new(setting_color_stdev_p1, st_transp))
                f_create_historical_label(hist_offset, final_v - final_std * setting_stdev_mult_1, '⎯⎯⎯ ' + kz.name + ' -1', color.new(setting_color_stdev_p1, st_transp))
                f_create_historical_label(hist_offset, final_v - final_std * setting_stdev_mult_2, '⎯⎯⎯ ' + kz.name + ' -2', color.new(setting_color_stdev_m2, st_transp))
    kz

// Improved VWAP calculation logic for UDT
method calculate_vwap(UDT_Killzone kz, float src_val) =>
    var float sumSrcVol = 0.0
    var float sumVol = 0.0
    var float sumSrcSrcVol = 0.0
    
    is_new = kz.allowed and not kz.allowed_p
    
    sumSrcVol := is_new ? src_val * volume : (kz.allowed ? src_val * volume + sumSrcVol[1] : sumSrcVol[1])
    sumVol := is_new ? volume : (kz.allowed ? volume + sumVol[1] : sumVol[1])
    sumSrcSrcVol := is_new ? volume * math.pow(src_val, 2) : (kz.allowed ? volume * math.pow(src_val, 2) + sumSrcSrcVol[1] : sumSrcSrcVol[1])
    
    if kz.allowed
        kz.v := sumSrcVol / sumVol
        variance = sumSrcSrcVol / sumVol - math.pow(kz.v, 2)
        variance := variance < 0 ? 0 : variance
        kz.std := math.sqrt(variance)
        // Store for historical labels
        kz.last_v := kz.v
        kz.last_std := kz.std
    else
        kz.v := na
        kz.std := na
    
    kz

// Method to update session settings from inputs
method update_session(UDT_Killzone kz, string name, string tf, bool show, bool div, color c, bool std, bool lbl, bool bg) =>
    kz.name := name
    kz.session_time := tf
    kz.show := show
    kz.show_divider := div
    kz.base_color := c
    kz.show_std := std
    kz.show_lbl := lbl
    kz.show_bg := bg
    kz

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Logic   |
// # ========================================================================= #

//#region

ll_offset = time + math.round(nz(ta.change(time)) * setting_off_mult)

// Initialize Sessions
var s1 = UDT_Killzone.new(first_session_name, first_session_tf, first_session_show, first_session_divider, first_session_color, first_session_std_show, first_session_lbl_show, first_session_bg_show)
var s2 = UDT_Killzone.new(second_session_name, second_session_tf, second_session_show, second_session_divider, second_session_color, second_session_std_show, second_session_lbl_show, second_session_bg_show)
var s3 = UDT_Killzone.new(third_session_name, third_session_tf, third_session_show, third_session_divider, third_session_color, third_session_std_show, third_session_lbl_show, third_session_bg_show)
var s4 = UDT_Killzone.new(forth_session_name, forth_session_tf, forth_session_show, forth_session_divider, forth_session_color, forth_session_std_show, forth_session_lbl_show, forth_session_bg_show)
var s5 = UDT_Killzone.new(fifth_session_name, fifth_session_tf, fifth_session_show, fifth_session_divider, fifth_session_color, fifth_session_std_show, fifth_session_lbl_show, fifth_session_bg_show)

// Update session allowed state
s1.allowed := not na(time(timeframe.period, s1.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s1.show
s2.allowed := not na(time(timeframe.period, s2.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s2.show
s3.allowed := not na(time(timeframe.period, s3.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s3.show
s4.allowed := not na(time(timeframe.period, s4.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s4.show
s5.allowed := not na(time(timeframe.period, s5.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s5.show

// Update session from inputs
s1.update_session(first_session_name, first_session_tf, first_session_show, first_session_divider, first_session_color, first_session_std_show, first_session_lbl_show, first_session_bg_show)
s2.update_session(second_session_name, second_session_tf, second_session_show, second_session_divider, second_session_color, second_session_std_show, second_session_lbl_show, second_session_bg_show)
s3.update_session(third_session_name, third_session_tf, third_session_show, third_session_divider, third_session_color, third_session_std_show, third_session_lbl_show, third_session_bg_show)
s4.update_session(forth_session_name, forth_session_tf, forth_session_show, forth_session_divider, forth_session_color, forth_session_std_show, forth_session_lbl_show, forth_session_bg_show)
s5.update_session(fifth_session_name, fifth_session_tf, fifth_session_show, fifth_session_divider, fifth_session_color, fifth_session_std_show, fifth_session_lbl_show, fifth_session_bg_show)

// Calculate VWAP
s1.calculate_vwap(setting_source)
s2.calculate_vwap(setting_source)
s3.calculate_vwap(setting_source)
s4.calculate_vwap(setting_source)
s5.calculate_vwap(setting_source)

// # Dividers Logic ---------------------------------------------------------- #

// Helper to draw dividers
method draw_divider(UDT_Killzone kz) =>
    if kz.show and kz.show_divider
        is_start = kz.allowed and not kz.allowed_p
        is_end = not kz.allowed and kz.allowed_p
        
        if is_start or is_end
            line.new(x1 = time, y1 = low, x2 = time, y2 = high, xloc = xloc.bar_time, color = divider_session_color, style = line_style(divider_session_style), width = divider_session_width, extend = extend.both)
    kz

s1.draw_divider()
s2.draw_divider()
s3.draw_divider()
s4.draw_divider()
s5.draw_divider()

s1.draw_session_end_labels()
s2.draw_session_end_labels()
s3.draw_session_end_labels()
s4.draw_session_end_labels()
s5.draw_session_end_labels()

// Update state for next bar
s1.allowed_p := s1.allowed
s2.allowed_p := s2.allowed
s3.allowed_p := s3.allowed
s4.allowed_p := s4.allowed
s5.allowed_p := s5.allowed

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Plots   |
// # ========================================================================= #

//#region

// Session 1
bgcolor(s1.allowed and s1.show_bg ? color.new(s1.base_color, 95) : na, title='S1 Background')
plot(s1.v, title='Session 1 VWAP', color=s1.base_color, style=plot.style_linebr, linewidth = 2)
[s2_up_1, s1_up_1, s1_dn_1, s2_dn_1] = calculate_st_dev_bands(s1.v, s1.std, setting_stdev_mult_1, setting_stdev_mult_2)
plot(s1.show_std ? s2_up_1 : na, title='S1 - STDEV +2', color=color.new(setting_color_stdev_p2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s1.show_std ? s1_up_1 : na, title='S1 - STDEV +1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s1.show_std ? s1_dn_1 : na, title='S1 - STDEV -1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s1.show_std ? s2_dn_1 : na, title='S1 - STDEV -2', color=color.new(setting_color_stdev_m2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
f_draw_session_label(ll_offset, s1.show_lbl and not na(s1.v) ? s1.v : na, '⎯⎯⎯ ' + s1.name, s1.base_color)
f_draw_session_label(ll_offset, s1.show_lbl and s1.show_std and not na(s2_up_1) ? s2_up_1 : na, '⎯⎯⎯ ' + s1.name + ' +2', color.new(setting_color_stdev_p2, st_transp))
f_draw_session_label(ll_offset, s1.show_lbl and s1.show_std and not na(s1_up_1) ? s1_up_1 : na, '⎯⎯⎯ ' + s1.name + ' +1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s1.show_lbl and s1.show_std and not na(s1_dn_1) ? s1_dn_1 : na, '⎯⎯⎯ ' + s1.name + ' -1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s1.show_lbl and s1.show_std and not na(s2_dn_1) ? s2_dn_1 : na, '⎯⎯⎯ ' + s1.name + ' -2', color.new(setting_color_stdev_m2, st_transp))

// Session 2
bgcolor(s2.allowed and s2.show_bg ? color.new(s2.base_color, 95) : na, title='S2 Background')
plot(s2.v, title='Session 2 VWAP', color=s2.base_color, style=plot.style_linebr, linewidth = 2)
[s2_up_2, s1_up_2, s1_dn_2, s2_dn_2] = calculate_st_dev_bands(s2.v, s2.std, setting_stdev_mult_1, setting_stdev_mult_2)
plot(s2.show_std ? s2_up_2 : na, title='S2 - STDEV +2', color=color.new(setting_color_stdev_p2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s2.show_std ? s1_up_2 : na, title='S2 - STDEV +1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s2.show_std ? s1_dn_2 : na, title='S2 - STDEV -1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s2.show_std ? s2_dn_2 : na, title='S2 - STDEV -2', color=color.new(setting_color_stdev_m2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
f_draw_session_label(ll_offset, s2.show_lbl and not na(s2.v) ? s2.v : na, '⎯⎯⎯ ' + s2.name, s2.base_color)
f_draw_session_label(ll_offset, s2.show_lbl and s2.show_std and not na(s2_up_2) ? s2_up_2 : na, '⎯⎯⎯ ' + s2.name + ' +2', color.new(setting_color_stdev_p2, st_transp))
f_draw_session_label(ll_offset, s2.show_lbl and s2.show_std and not na(s1_up_2) ? s1_up_2 : na, '⎯⎯⎯ ' + s2.name + ' +1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s2.show_lbl and s2.show_std and not na(s1_dn_2) ? s1_dn_2 : na, '⎯⎯⎯ ' + s2.name + ' -1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s2.show_lbl and s2.show_std and not na(s2_dn_2) ? s2_dn_2 : na, '⎯⎯⎯ ' + s2.name + ' -2', color.new(setting_color_stdev_m2, st_transp))

// Session 3
bgcolor(s3.allowed and s3.show_bg ? color.new(s3.base_color, 95) : na, title='S3 Background')
plot(s3.v, title='Session 3 VWAP', color=s3.base_color, style=plot.style_linebr, linewidth = 2)
[s2_up_3, s1_up_3, s1_dn_3, s2_dn_3] = calculate_st_dev_bands(s3.v, s3.std, setting_stdev_mult_1, setting_stdev_mult_2)
plot(s3.show_std ? s2_up_3 : na, title='S3 - STDEV +2', color=color.new(setting_color_stdev_p2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s3.show_std ? s1_up_3 : na, title='S3 - STDEV +1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s3.show_std ? s1_dn_3 : na, title='S3 - STDEV -1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s3.show_std ? s2_dn_3 : na, title='S3 - STDEV -2', color=color.new(setting_color_stdev_m2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
f_draw_session_label(ll_offset, s3.show_lbl and not na(s3.v) ? s3.v : na, '⎯⎯⎯ ' + s3.name, s3.base_color)
f_draw_session_label(ll_offset, s3.show_lbl and s3.show_std and not na(s2_up_3) ? s2_up_3 : na, '⎯⎯⎯ ' + s3.name + ' +2', color.new(setting_color_stdev_p2, st_transp))
f_draw_session_label(ll_offset, s3.show_lbl and s3.show_std and not na(s1_up_3) ? s1_up_3 : na, '⎯⎯⎯ ' + s3.name + ' +1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s3.show_lbl and s3.show_std and not na(s1_dn_3) ? s1_dn_3 : na, '⎯⎯⎯ ' + s3.name + ' -1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s3.show_lbl and s3.show_std and not na(s2_dn_3) ? s2_dn_3 : na, '⎯⎯⎯ ' + s3.name + ' -2', color.new(setting_color_stdev_m2, st_transp))

// Session 4
bgcolor(s4.allowed and s4.show_bg ? color.new(s4.base_color, 95) : na, title='S4 Background')
plot(s4.v, title='Session 4 VWAP', color=s4.base_color, style=plot.style_linebr, linewidth = 2)
[s2_up_4, s1_up_4, s1_dn_4, s2_dn_4] = calculate_st_dev_bands(s4.v, s4.std, setting_stdev_mult_1, setting_stdev_mult_2)
plot(s4.show_std ? s2_up_4 : na, title='S4 - STDEV +2', color=color.new(setting_color_stdev_p2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s4.show_std ? s1_up_4 : na, title='S4 - STDEV +1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s4.show_std ? s1_dn_4 : na, title='S4 - STDEV -1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s4.show_std ? s2_dn_4 : na, title='S4 - STDEV -2', color=color.new(setting_color_stdev_m2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
f_draw_session_label(ll_offset, s4.show_lbl and not na(s4.v) ? s4.v : na, '⎯⎯⎯ ' + s4.name, s4.base_color)
f_draw_session_label(ll_offset, s4.show_lbl and s4.show_std and not na(s2_up_4) ? s2_up_4 : na, '⎯⎯⎯ ' + s4.name + ' +2', color.new(setting_color_stdev_p2, st_transp))
f_draw_session_label(ll_offset, s4.show_lbl and s4.show_std and not na(s1_up_4) ? s1_up_4 : na, '⎯⎯⎯ ' + s4.name + ' +1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s4.show_lbl and s4.show_std and not na(s1_dn_4) ? s1_dn_4 : na, '⎯⎯⎯ ' + s4.name + ' -1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s4.show_lbl and s4.show_std and not na(s2_dn_4) ? s2_dn_4 : na, '⎯⎯⎯ ' + s4.name + ' -2', color.new(setting_color_stdev_m2, st_transp))

// Session 5
bgcolor(s5.allowed and s5.show_bg ? color.new(s5.base_color, 95) : na, title='S5 Background')
plot(s5.v, title='Session 5 VWAP', color=s5.base_color, style=plot.style_linebr, linewidth = 2)
[s2_up_5, s1_up_5, s1_dn_5, s2_dn_5] = calculate_st_dev_bands(s5.v, s5.std, setting_stdev_mult_1, setting_stdev_mult_2)
plot(s5.show_std ? s2_up_5 : na, title='S5 - STDEV +2', color=color.new(setting_color_stdev_p2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s5.show_std ? s1_up_5 : na, title='S5 - STDEV +1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s5.show_std ? s1_dn_5 : na, title='S5 - STDEV -1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
plot(s5.show_std ? s2_dn_5 : na, title='S5 - STDEV -2', color=color.new(setting_color_stdev_m2, st_transp), style=plot.style_linebr, linewidth=setting_stdev_width)
f_draw_session_label(ll_offset, s5.show_lbl and not na(s5.v) ? s5.v : na, '⎯⎯⎯ ' + s5.name, s5.base_color)
f_draw_session_label(ll_offset, s5.show_lbl and s5.show_std and not na(s2_up_5) ? s2_up_5 : na, '⎯⎯⎯ ' + s5.name + ' +2', color.new(setting_color_stdev_p2, st_transp))
f_draw_session_label(ll_offset, s5.show_lbl and s5.show_std and not na(s1_up_5) ? s1_up_5 : na, '⎯⎯⎯ ' + s5.name + ' +1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s5.show_lbl and s5.show_std and not na(s1_dn_5) ? s1_dn_5 : na, '⎯⎯⎯ ' + s5.name + ' -1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, s5.show_lbl and s5.show_std and not na(s2_dn_5) ? s2_dn_5 : na, '⎯⎯⎯ ' + s5.name + ' -2', color.new(setting_color_stdev_m2, st_transp))

// Daily VWAP
has_time_changed(period) => 
    t = time(period, setting_timezone == "Exchange" ? na : setting_timezone)
    ta.change(t) != 0

is_new_daily_session = has_time_changed("D")

// Classic Daily VWAP Logic
[v_classic, st_dev_classic] = calculate_vwap_logic(setting_source, is_new_daily_session)

// Rolling Daily VWAP Logic (24-hour window)
MS_IN_DAY = 24 * 60 * 60 * 1000
sumSrcVol_r    = totalForTimeWhen(setting_source * volume, MS_IN_DAY, true, 10)
sumVol_r       = totalForTimeWhen(volume, MS_IN_DAY, true, 10)
sumSrcSrcVol_r = totalForTimeWhen(volume * math.pow(setting_source, 2), MS_IN_DAY, true, 10)

v_rolling = sumSrcVol_r / sumVol_r
variance_r = math.max(sumSrcSrcVol_r / sumVol_r - math.pow(v_rolling, 2), 0.0)
st_dev_rolling = math.sqrt(variance_r)

// Final Daily VWAP Selection
v_daily      = daily_vwap_type == "Rolling" ? v_rolling : v_classic
st_dev_daily = daily_vwap_type == "Rolling" ? st_dev_rolling : st_dev_classic

[s2_up_daily, s1_up_daily, s1_dn_daily, s2_dn_daily] = calculate_st_dev_bands(v_daily, st_dev_daily, setting_stdev_mult_1, setting_stdev_mult_2)

// Daily Historical Labels
if is_new_daily_session and show_vwap_daily and show_label_daily
    int day_hist_offset = int(time[1] + nz(time[1] - time[2]) * setting_off_mult)
    f_create_historical_label(day_hist_offset, v_daily[1], '⎯⎯⎯ D', colors_gray)
    if show_std_daily and not na(st_dev_daily[1])
        f_create_historical_label(day_hist_offset, v_daily[1] + st_dev_daily[1] * setting_stdev_mult_2, '⎯⎯⎯ D +2', color.new(setting_color_stdev_p2, st_transp))
        f_create_historical_label(day_hist_offset, v_daily[1] + st_dev_daily[1] * setting_stdev_mult_1, '⎯⎯⎯ D +1', color.new(setting_color_stdev_p1, st_transp))
        f_create_historical_label(day_hist_offset, v_daily[1] - st_dev_daily[1] * setting_stdev_mult_1, '⎯⎯⎯ D -1', color.new(setting_color_stdev_p1, st_transp))
        f_create_historical_label(day_hist_offset, v_daily[1] - st_dev_daily[1] * setting_stdev_mult_2, '⎯⎯⎯ D -2', color.new(setting_color_stdev_m2, st_transp))

// Logic for showing Daily (plots all the time now as is standard)
plot(show_vwap_daily ? v_daily : na, title='VWAP - Daily', color=colors_gray, linewidth=2)
f_draw_session_label(ll_offset, show_label_daily and show_vwap_daily ? v_daily : na, '⎯⎯⎯ D', colors_gray)
f_draw_session_label(ll_offset, show_label_daily and show_vwap_daily and show_std_daily and not na(s2_up_daily) ? s2_up_daily : na, '⎯⎯⎯ D +2', color.new(setting_color_stdev_p2, st_transp))
f_draw_session_label(ll_offset, show_label_daily and show_vwap_daily and show_std_daily and not na(s1_up_daily) ? s1_up_daily : na, '⎯⎯⎯ D +1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, show_label_daily and show_vwap_daily and show_std_daily and not na(s1_dn_daily) ? s1_dn_daily : na, '⎯⎯⎯ D -1', color.new(setting_color_stdev_p1, st_transp))
f_draw_session_label(ll_offset, show_label_daily and show_vwap_daily and show_std_daily and not na(s2_dn_daily) ? s2_dn_daily : na, '⎯⎯⎯ D -2', color.new(setting_color_stdev_m2, st_transp))

plot(show_std_daily ? s1_up_daily : na, title='VWAP Day - STDEV +1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_line, linewidth=setting_stdev_width)
plot(show_std_daily ? s1_dn_daily : na, title='VWAP Day - STDEV -1', color=color.new(setting_color_stdev_p1, st_transp), style=plot.style_line, linewidth=setting_stdev_width)
plot(show_std_daily ? s2_up_daily : na, title='VWAP Day - STDEV +2', color=color.new(setting_color_stdev_p2, st_transp), style=plot.style_line, linewidth=setting_stdev_width)
plot(show_std_daily ? s2_dn_daily : na, title='VWAP Day - STDEV -2', color=color.new(setting_color_stdev_m2, st_transp), style=plot.style_line, linewidth=setting_stdev_width)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Brand   |
// # ========================================================================= #

//#region

if barstate.isfirst and not general_brand_show
    var table brand = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand, 0, 0,  "© CandelaCharts", text_color = colors_gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
