# CandelaCharts - Killzone Supertrend

- url: https://www.tradingview.com/script/HeXAODIF-CandelaCharts-Killzone-Supertrend/
- type: indicator
- pine_id: PUB;4aa3f0ea10804e5983950717758fcd0d
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - Killzone Supertrend[/b] indicator integrates professional, noise-filtered Supertrend volatility-based trend-following logic within specific intraday sessions. By isolating trend analysis to key Killzones and providing advanced smoothing tools, traders can effectively filter out market noise and identify high-probability trend shifts during periods of peak institutional activity.

📦 [b]Features[/b]

[list]
[*] [b]5 Customizable Sessions[/b]: Tracks trends across Asia, London, NY AM, NY Lunch, and NY PM sessions.
[*] [b]Continuous Detection[/b]: Unlike standard session indicators that reset, this logic runs continuously in the background. This ensures that the trend state is established accurately before the session begins, eliminating "initialization lag."
[*] [b]Full Session Backgrounds[/b]: Highlight the entire vertical pane for each session with customizable colors and transparency for maximum focus.
[*] [b]Source Smoothing[/b]: Smooth the price source (hl2) before calculation to filter out minor whipsaws and reduce false signals in choppy markets.
[*] [b]Multi-Method ATR[/b]: Choose between RMA, SMA, EMA, or WMA for volatility calculations based on your preferred responsiveness.
[*] [b]Visual Signal Markers[/b]: Clear Triangle Up/Down markers appear instantly when a trend flip occurs within an active session.
[*] [b]Trend Fill[/b]: Shaded backgrounds between the Supertrend line and price provide a visual "cushion" to assess trend strength.
[*] [b]Dynamic Session Labels[/b]: Centered labels that automatically adjust their position based on the session's price range.
[*] [b]Session Dividers[/b]: Clear vertical dividers to signal the transition between trading periods.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]ATR Period[/b]: Lookback period for the Average True Range calculation (default: 10).
[*] [b]Multiplier[/b]: Volatility multiplier for the trailing stop (default: 3.0).
[*] [b]Source Smoothing[/b]: EMA period to smooth price before detection (0 = off).
[*] [b]ATR Method[/b]: Choose the smoothing method (RMA, SMA, EMA, WMA).
[*] [b]Show Signals[/b]: Toggle Triangle Up/Down markers for trend changes.
[*] [b]Show Trend Fill[/b]: Toggle the shaded background between price and Supertrend.
[*] [b]Label Size[/b]: Customize the text size of session labels.
[*] [b]Timezone[/b]: Supports America/New_York, UTC, and Exchange time.
[*] [b]Divider Style[/b]: Style and color settings for vertical lines.
[*] [b]Show Session[/b]: Toggle the Supertrend logic and markers.
[*] [b]Background[/b]: Toggle the full vertical pane background color.
[*] [b]Session Name & Time[/b]: Define labels and time windows.
[*] [b]Session Color[/b]: Sets the theme for the labels and dividers.
[*] [b]Show Labels[/b]: Toggle the centered session identifiers.
[*] [b]Show Divider[/b]: Toggle vertical start/end lines.
[/list]

⚡️ [b]Showcase[/b]

[i]Supertrend Lines & Signals[/i]
https://www.tradingview.com/x/BNesGJvt/

[i]Session Boxes & Full Backgrounds[/i]
https://www.tradingview.com/x/1vadayJ0/

🚨 [b]Alerts[/b]

Trend changes are visually indicated by line color shifts and Triangle markers (Buy/Sell) within each active session.

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator('CandelaCharts - Killzone Supertrend', shorttitle = 'CandelaCharts - Killzone Supertrend', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)













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
colors_teal                         = color.teal
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

general_font                            = input.string("Monospace", "Text                     ", inline = "1.0", options = ["Default", "Monospace"], group = "General")
general_text                            = input.string("Tiny", "", inline = "1.0", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = "General", tooltip = "Customize global text size and style")
general_brand_show                      = input.bool(false, "Hide Brand", group = "General")

// # Settings ---------------------------------------------------------------- #

setting_st_period                       = input.int(10, "ATR Period       ", group = "Settings")
setting_st_mult                         = input.float(3.0, "Multiplier", step = 0.1, group = "Settings")
setting_st_smooth                       = input.int(0, "Smoothing", minval = 0, group = "Settings", tooltip = "Smooth the price source (hl2) before calculation to reduce noise. 0 = off.")
setting_st_atr_type                     = input.string("RMA", "ATR Method       ", options = ["RMA", "SMA", "EMA", "WMA"], group = "Settings")
setting_lbl_size                        = input.string("Huge", "Label Size       ", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = "Settings")
setting_timezone                        = input.string("America/New_York", "Timezone", options = ["America/New_York", "UTC", "Exchange"], group = "Settings")
divider_session_style                   = input.string('····', "Divider Style", options = ['⎯⎯⎯', '----', '····'], group = "Settings")
divider_session_width                   = input.int(1, "Divider Width", minval = 1, maxval = 4, group = "Settings")
divider_session_color                   = input.color(colors_gray, "Divider Color", group = "Settings")
setting_st_show_signals                 = input.bool(true, "Show Signals", group = "Settings")
setting_st_show_fill                    = input.bool(true, "Show Trend Fill", group = "Settings")

// # Session 1 --------------------------------------------------------------- #

first_session_bg_show                   = input.bool(true, "Show Session", group = "First Session")
first_session_full_bg_show              = input.bool(false, "Background  ", inline = "1.1", group = "First Session")
first_session_full_bg_css               = input.color(color.new(colors_gray, 95), "", inline = "1.1", group = "First Session")
first_session_divider                   = input.bool(false, "Show Divider", group = "First Session")
first_session_name                      = input.string("AS", "Session Name", group = "First Session")
first_session_tf                        = input.session("2000-0000", "Session Time", group = "First Session")
first_session_color                     = input.color(colors_gray, "Session Color", group = "First Session")
first_session_lbl_show                  = input.bool(true, "Show Labels", group = "First Session")

// # Session 2 --------------------------------------------------------------- #

second_session_bg_show                  = input.bool(true, "Show Session", group = "Second Session")
second_session_full_bg_show             = input.bool(false, "Background  ", inline = "2.1", group = "Second Session")
second_session_full_bg_css              = input.color(color.new(colors_red, 95), "", inline = "2.1", group = "Second Session")
second_session_divider                  = input.bool(false, "Show Divider", group = "Second Session")
second_session_name                     = input.string("LO", "Session Name", group = "Second Session")
second_session_tf                       = input.session("0200-0500", "Session Time", group = "Second Session")
second_session_color                    = input.color(colors_red, "Session Color", group = "Second Session")
second_session_lbl_show                 = input.bool(true, "Show Labels", group = "Second Session")

// # Session 3 --------------------------------------------------------------- #

third_session_bg_show                   = input.bool(true, "Show Session", group = "Third Session")
third_session_full_bg_show              = input.bool(false, "Background  ", inline = "3.1", group = "Third Session")
third_session_full_bg_css               = input.color(color.new(colors_purple, 95), "", inline = "3.1", group = "Third Session")
third_session_divider                   = input.bool(false, "Show Divider", group = "Third Session")
third_session_name                      = input.string("NYAM", "Session Name", group = "Third Session")
third_session_tf                        = input.session("0930-1100", "Session Time", group = "Third Session")
third_session_color                     = input.color(colors_purple, "Session Color", group = "Third Session")
third_session_lbl_show                  = input.bool(true, "Show Labels", group = "Third Session")

// # Session 4 --------------------------------------------------------------- #

forth_session_bg_show                   = input.bool(true, "Show Session", group = "Fourth Session")
forth_session_full_bg_show              = input.bool(false, "Background  ", inline = "4.1", group = "Fourth Session")
forth_session_full_bg_css               = input.color(color.new(colors_teal, 95), "", inline = "4.1", group = "Fourth Session")
forth_session_divider                   = input.bool(false, "Show Divider", group = "Fourth Session")
forth_session_name                      = input.string("NYLA", "Session Name", group = "Fourth Session")
forth_session_tf                        = input.session("1200-1300", "Session Time", group = "Fourth Session")
forth_session_color                     = input.color(colors_teal, "Session Color", group = "Fourth Session")
forth_session_lbl_show                  = input.bool(true, "Show Labels", group = "Fourth Session")

// # Session 5 --------------------------------------------------------------- #

fifth_session_bg_show                   = input.bool(true, "Show Session", group = "Fifth Session")
fifth_session_full_bg_show              = input.bool(false, "Background  ", inline = "5.1", group = "Fifth Session")
fifth_session_full_bg_css               = input.color(color.new(colors_blue, 95), "", inline = "5.1", group = "Fifth Session")
fifth_session_divider                   = input.bool(false, "Show Divider", group = "Fifth Session")
fifth_session_name                      = input.string("NYPM", "Session Name", group = "Fifth Session")
fifth_session_tf                        = input.session("1330-1600", "Session Time", group = "Fifth Session")
fifth_session_color                     = input.color(colors_blue, "Session Color", group = "Fifth Session")
fifth_session_lbl_show                  = input.bool(true, "Show Labels", group = "Fifth Session")

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
    color   base_color
    bool    show_lbl
    bool    show_bg
    bool    show_full_bg
    color   full_bg_color
    bool    show_divider
    
    // Bounds for label centering
    int     start_time = 0
    float   high_price = -1.0e10
    float   low_price  = 1.0e10
    
    // Supertrend state
    float   st_val = na
    int     st_trend = 1
    float   st_up = na
    float   st_dn = na
    bool    st_buy = false
    bool    st_sell = false
    
    // Allowed state
    bool    allowed = false
    bool    allowed_p = false
    
    // Persistent artifacts for the current session instance
    label   l = na
    box     b = na

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

// Method to calculate supertrend logic for UDT
method calculate_supertrend(UDT_Killzone kz, int period, float mult, int smooth_len, string atr_type) =>
    // Source smoothing
    raw_src = hl2
    src = smooth_len > 0 ? ta.ema(raw_src, smooth_len) : raw_src
    
    // Custom ATR calculation
    tr = ta.tr(true)
    atr = switch atr_type
        "RMA" => ta.rma(tr, period)
        "SMA" => ta.sma(tr, period)
        "EMA" => ta.ema(tr, period)
        "WMA" => ta.wma(tr, period)
        => ta.rma(tr, period)

    // Calculate bands
    up_val = src - (mult * atr)
    dn_val = src + (mult * atr)
    
    // Previous state
    float prev_up = nz(kz.st_up, up_val)
    float prev_dn = nz(kz.st_dn, dn_val)
    int prev_trend = nz(kz.st_trend, close > dn_val ? 1 : -1)
    
    // Trailing Stop logic
    kz.st_up := close[1] > prev_up ? math.max(up_val, prev_up) : up_val
    kz.st_dn := close[1] < prev_dn ? math.min(dn_val, prev_dn) : dn_val
    
    // Trend logic
    kz.st_trend := prev_trend == -1 and close > prev_dn ? 1 : prev_trend == 1 and close < prev_up ? -1 : prev_trend
    
    // Signal logic
    kz.st_val := kz.st_trend == 1 ? kz.st_up : kz.st_dn
    kz.st_buy := kz.st_trend == 1 and prev_trend == -1
    kz.st_sell := kz.st_trend == -1 and prev_trend == 1
    
    kz

// Method to update session settings from inputs
method update_session(UDT_Killzone kz, string name, string tf, color c, bool lbl, bool bg, bool full_bg, color full_bg_css, bool div) =>
    kz.name := name
    kz.session_time := tf
    kz.base_color := c
    kz.show_lbl := lbl
    kz.show_bg := bg
    kz.show_full_bg := full_bg
    kz.full_bg_color := full_bg_css
    kz.show_divider := div
    kz

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #













// # ========================================================================= #
// # |   Logic   |
// # ========================================================================= #

//#region

// Initialize Sessions
var s1 = UDT_Killzone.new(first_session_name, first_session_tf, first_session_color, first_session_lbl_show, first_session_bg_show, first_session_full_bg_show, first_session_full_bg_css, first_session_divider)
var s2 = UDT_Killzone.new(second_session_name, second_session_tf, second_session_color, second_session_lbl_show, second_session_bg_show, second_session_full_bg_show, second_session_full_bg_css, second_session_divider)
var s3 = UDT_Killzone.new(third_session_name, third_session_tf, third_session_color, third_session_lbl_show, third_session_bg_show, third_session_full_bg_show, third_session_full_bg_css, third_session_divider)
var s4 = UDT_Killzone.new(forth_session_name, forth_session_tf, forth_session_color, forth_session_lbl_show, forth_session_bg_show, forth_session_full_bg_show, forth_session_full_bg_css, forth_session_divider)
var s5 = UDT_Killzone.new(fifth_session_name, fifth_session_tf, fifth_session_color, fifth_session_lbl_show, fifth_session_bg_show, fifth_session_full_bg_show, fifth_session_full_bg_css, fifth_session_divider)

// Update session from inputs
s1.update_session(first_session_name, first_session_tf, first_session_color, first_session_lbl_show, first_session_bg_show, first_session_full_bg_show, first_session_full_bg_css, first_session_divider)
s2.update_session(second_session_name, second_session_tf, second_session_color, second_session_lbl_show, second_session_bg_show, second_session_full_bg_show, second_session_full_bg_css, second_session_divider)
s3.update_session(third_session_name, third_session_tf, third_session_color, third_session_lbl_show, third_session_bg_show, third_session_full_bg_show, third_session_full_bg_css, third_session_divider)
s4.update_session(forth_session_name, forth_session_tf, forth_session_color, forth_session_lbl_show, forth_session_bg_show, forth_session_full_bg_show, forth_session_full_bg_css, forth_session_divider)
s5.update_session(fifth_session_name, fifth_session_tf, fifth_session_color, fifth_session_lbl_show, fifth_session_bg_show, fifth_session_full_bg_show, fifth_session_full_bg_css, fifth_session_divider)

// Update session allowed state
s1.allowed := not na(time(timeframe.period, s1.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s1.show_bg
s2.allowed := not na(time(timeframe.period, s2.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s2.show_bg
s3.allowed := not na(time(timeframe.period, s3.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s3.show_bg
s4.allowed := not na(time(timeframe.period, s4.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s4.show_bg
s5.allowed := not na(time(timeframe.period, s5.session_time + ':1234567', setting_timezone == "Exchange" ? na : setting_timezone)) and s5.show_bg

// Track Bounds and Draw Centered Labels
method update_session_bounds(UDT_Killzone kz) =>
    is_start = kz.allowed and not kz.allowed_p
    is_end = not kz.allowed and kz.allowed_p
    
    if is_start
        kz.start_time := time
        kz.high_price := high
        kz.low_price  := low
        
        if kz.show_lbl
            kz.l := label.new(x=time, y=hl2, text=kz.name, textcolor=kz.base_color, style=label.style_none, size=text_size(setting_lbl_size), text_font_family = font_style(general_font), text_formatting = text.format_bold, xloc = xloc.bar_time)
        
        if kz.show_bg
            kz.b := box.new(left=time, top=low + (high - low) * 0.1, right=time, bottom=low, bgcolor=color.new(kz.base_color, 85), border_color=color_transparent, xloc=xloc.bar_time)
    
    if kz.allowed
        kz.high_price := math.max(kz.high_price, high)
        kz.low_price := math.min(kz.low_price, low)
        
        if not na(kz.l)
            mid_time = (kz.start_time + time) / 2
            mid_price = (kz.high_price + kz.low_price) / 2
            label.set_xy(kz.l, mid_time, mid_price)
            label.set_text(kz.l, kz.name)
            label.set_textcolor(kz.l, kz.base_color)
        
        if not na(kz.b)
            box.set_left(kz.b, kz.start_time)
            box.set_right(kz.b, time)
            box.set_bottom(kz.b, kz.low_price)
            box.set_top(kz.b, kz.low_price + (kz.high_price - kz.low_price) * 0.1)
            box.set_bgcolor(kz.b, color.new(kz.base_color, 85))
    
    if is_end
        kz.l := na
        kz.b := na
    kz

s1.update_session_bounds()
s2.update_session_bounds()
s3.update_session_bounds()
s4.update_session_bounds()
s5.update_session_bounds()

// Calculate Supertrend
s1.calculate_supertrend(setting_st_period, setting_st_mult, setting_st_smooth, setting_st_atr_type)
s2.calculate_supertrend(setting_st_period, setting_st_mult, setting_st_smooth, setting_st_atr_type)
s3.calculate_supertrend(setting_st_period, setting_st_mult, setting_st_smooth, setting_st_atr_type)
s4.calculate_supertrend(setting_st_period, setting_st_mult, setting_st_smooth, setting_st_atr_type)
s5.calculate_supertrend(setting_st_period, setting_st_mult, setting_st_smooth, setting_st_atr_type)

// Helper to draw dividers
method draw_divider(UDT_Killzone kz) =>
    if kz.show_bg and kz.show_divider
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

// Update state for next bar
s1.allowed_p := s1.allowed
s2.allowed_p := s2.allowed
s3.allowed_p := s3.allowed
s4.allowed_p := s4.allowed
s5.allowed_p := s5.allowed

bgcolor(s1.allowed and s1.show_full_bg ? s1.full_bg_color : na, title = "S1 Background")
bgcolor(s2.allowed and s2.show_full_bg ? s2.full_bg_color : na, title = "S2 Background")
bgcolor(s3.allowed and s3.show_full_bg ? s3.full_bg_color : na, title = "S3 Background")
bgcolor(s4.allowed and s4.show_full_bg ? s4.full_bg_color : na, title = "S4 Background")
bgcolor(s5.allowed and s5.show_full_bg ? s5.full_bg_color : na, title = "S5 Background")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #













// # ========================================================================= #
// # |   Plots   |
// # ========================================================================= #

//#region

// Session 1
p1 = plot(s1.allowed and not s1.st_buy and not s1.st_sell ? s1.st_val : na, title='S1 Supertrend', color=s1.st_trend == 1 ? color.green : color.red, style=plot.style_linebr, linewidth=2)
fill(plot(s1.allowed ? hl2 : na, display = display.none), p1, s1.allowed and setting_st_show_fill ? (s1.st_trend == 1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na, title = "S1 Trend Fill")
plotshape(s1.allowed and s1.st_buy and setting_st_show_signals, title = "S1 Buy", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(s1.allowed and s1.st_sell and setting_st_show_signals, title = "S1 Sell", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)

// Session 2
p2 = plot(s2.allowed and not s2.st_buy and not s2.st_sell ? s2.st_val : na, title='S2 Supertrend', color=s2.st_trend == 1 ? color.green : color.red, style=plot.style_linebr, linewidth=2)
fill(plot(s2.allowed ? hl2 : na, display = display.none), p2, s2.allowed and setting_st_show_fill ? (s2.st_trend == 1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na, title = "S2 Trend Fill")
plotshape(s2.allowed and s2.st_buy and setting_st_show_signals, title = "S2 Buy", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(s2.allowed and s2.st_sell and setting_st_show_signals, title = "S2 Sell", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)

// Session 3
p3 = plot(s3.allowed and not s3.st_buy and not s3.st_sell ? s3.st_val : na, title='S3 Supertrend', color=s3.st_trend == 1 ? color.green : color.red, style=plot.style_linebr, linewidth=2)
fill(plot(s3.allowed ? hl2 : na, display = display.none), p3, s3.allowed and setting_st_show_fill ? (s3.st_trend == 1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na, title = "S3 Trend Fill")
plotshape(s3.allowed and s3.st_buy and setting_st_show_signals, title = "S3 Buy", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(s3.allowed and s3.st_sell and setting_st_show_signals, title = "S3 Sell", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)

// Session 4
p4 = plot(s4.allowed and not s4.st_buy and not s4.st_sell ? s4.st_val : na, title='S4 Supertrend', color=s4.st_trend == 1 ? color.green : color.red, style=plot.style_linebr, linewidth=2)
fill(plot(s4.allowed ? hl2 : na, display = display.none), p4, s4.allowed and setting_st_show_fill ? (s4.st_trend == 1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na, title = "S4 Trend Fill")
plotshape(s4.allowed and s4.st_buy and setting_st_show_signals, title = "S4 Buy", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(s4.allowed and s4.st_sell and setting_st_show_signals, title = "S4 Sell", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)

// Session 5
p5 = plot(s5.allowed and not s5.st_buy and not s5.st_sell ? s5.st_val : na, title='S5 Supertrend', color=s5.st_trend == 1 ? color.green : color.red, style=plot.style_linebr, linewidth=2)
fill(plot(s5.allowed ? hl2 : na, display = display.none), p5, s5.allowed and setting_st_show_fill ? (s5.st_trend == 1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na, title = "S5 Trend Fill")
plotshape(s5.allowed and s5.st_buy and setting_st_show_signals, title = "S5 Buy", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny)
plotshape(s5.allowed and s5.st_sell and setting_st_show_signals, title = "S5 Sell", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny)

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
