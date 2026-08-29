<!-- tradingview-pine-id: PUB;ff3a69b9ceb04cb9be1d6711c45bc5a9 -->
<!-- tradingviewscripts-format: 1 -->
# CandelaCharts - Intraday Gaps

Source: https://www.tradingview.com/script/U9jLBL0H-CandelaCharts-Intraday-Gaps/

## Description

📝 Overview

The CandelaCharts - Intraday Gaps indicator is a precise technical tool designed to automatically identify, visualize, and track market gaps between daily trading sessions. By highlighting the hidden zones between the Previous Day's Close (or High/Low) and Today's Open, this indicator provides traders with actionable support and resistance levels right from the market open.

https://www.tradingview.com/x/oCgKMGyh/

Gaps are powerful price action phenomena. A "Gap Up" occurs when the market opens higher than the previous session's close, leaving a void that often acts as support. Conversely, a "Gap Down" occurs when the market opens lower, leaving a void that often acts as resistance. This indicator eliminates the need to manually draw these zones every day.

📦 Features

[*] Dynamic Gap Detection: Automatically detects Gap Ups (Bullish) and Gap Downs (Bearish) at the start of every new daily session.
[*] Customizable Gap Logic: Choose whether gaps are calculated based on the Previous Day's Close (standard) or the Previous Day's High/Low (traditional breakaway gaps).
[*] Filter by Bias: Easily unclutter your chart by filtering the display to only show Bullish gaps, Bearish gaps, or Both.
[*] Midline Tracking: Automatically calculates and plots the exact 50% mean (midline) of the gap zone, a highly respected level for intraday rejections. The midline can be easily toggled on or off.
[*] Precision Price Labels: Displays dynamic price labels for the top, bottom, and midline of the active gap directly on the chart axis.

⚙️ Settings

[*] Filter Bias: Select which gap types to display (Bullish, Bearish, or Both).
[*] Gap Up / Gap Down Toggles: Enable or disable gap detection. If the tooltip checkbox is checked, the gap is calculated from the previous day's close. If unchecked, it calculates from the previous day's high/low.
[*] Midline: Toggle the visibility of the gap's 50% mean level.
[*] Enable Alerts: Toggle the ability for the indicator to fire programmatic alerts.

⚡️ Showcase

Bullish Gap
https://www.tradingview.com/x/vodcPAJX/

Bearish Gap
https://www.tradingview.com/x/oa5n6Iru/

Both
https://www.tradingview.com/x/HuSXayig/

1H Range
https://www.tradingview.com/x/kG5ewUEO/

📒 Usage

[*] Opening Range Strategies: Use the gap zones as immediate support and resistance for the first few hours of trading. Price will often test the edges of the gap before reversing or accelerating.
https://www.tradingview.com/x/78MnaMZe/
[*] The "Gap Fill" Trade: If price enters the gap and gains momentum, it will often gravitate toward the opposite side of the gap (the "fill").
https://www.tradingview.com/x/ipHzKggu/
[*] Midline Rejections: Watch price action closely as it approaches the gap's midline. The 50% level of a gap is a classic hidden barrier where intraday reversals frequently occur.
https://www.tradingview.com/x/3e92Vv5w/

🚨 Alerts

This indicator includes built-in alert conditions ensuring you never miss a critical gap test. Once "Enable Alerts" is checked in the settings, you can configure TradingView to notify you when:

[*] Price reaches the boundary of an active gap.
[*] Price fully fills the gap zone.

⚠️ Disclaimer

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator(title = "CandelaCharts - Intraday Gaps", shorttitle = "CandelaCharts - Intraday Gaps", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)











// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_white                        = color.white
colors_black                        = color.black
colors_green                        = color.green
colors_orange                       = color.orange
colors_blue                         = color.blue
colors_aqua                         = color.aqua
colors_fuchsia                      = color.fuchsia
colors_lime                         = color.lime
colors_maroon                       = color.maroon
colors_navy                         = color.navy
colors_olive                        = color.olive
colors_purple                       = color.purple
colors_teal                         = color.teal
colors_yellow                       = color.yellow
colors_red                          = color.red
colors_gray                         = color.gray
colors_silver                       = color.silver
colors_transparent                  = color.new(color.white, 100)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                        = input.string("Monospace", "Text                  ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                  = input.bool(false, "Hide Brand", group = "General")

filter_bias                         = input.string("Both", title="Filter Bias       ", options=["Bullish", "Bearish", "Both"], group="Settings")

guc                                 = input.bool(true, title="Gap Up      ", inline="1.0", group = "Settings", tooltip="IF CHECKED = Open is > Than Previous Days CLOSE, If NOT CHECKED = Open is > than Previous Days HIGH")
gap_up_style                        = input.string('⎯⎯⎯', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="1.0")
gap_up_css                          = input.color(colors_teal, title="", group = "Settings", inline="1.0")
gap_up_fill_css                     = input.color(color.new(colors_teal, 85), title="", group = "Settings", inline="1.0")

gdc                                 = input.bool(true, title="Gap Down  ", inline="2.0", group = "Settings", tooltip="IF CHECKED = Open is < Than Previous Days CLOSE, If NOT CHECKED = Open is < than Previous Days LOW")
gap_dn_style                        = input.string('⎯⎯⎯', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="2.0")
gap_dn_css                          = input.color(colors_red, title="", group = "Settings", inline="2.0")
gap_dn_fill_css                     = input.color(color.new(colors_red, 85), title="", group = "Settings", inline="2.0")
gap_mid_show                        = input.bool(true, title="Midline       ", inline="3.0", group = "Settings")
gap_mid_style                       = input.string('----', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="3.0")
gap_mid_css                         = input.color(colors_gray, title="", group = "Settings", inline="3.0")

gap_sub_show                        = input.bool(false, title="Inner Levels", inline="3.1", group="Settings")
gap_subdivisions                    = input.string("OTE", title="", options=["OTE", "Quadrants"], inline="3.1", group="Settings")
gap_sub_style                       = input.string('····', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="3.1")
gap_sub_css                         = input.color(colors_gray, title="", group = "Settings", inline="3.1")

gap_labels                          = input.bool(true, title="Show Labels", inline="3.2", group="Settings")

alerts_enable                       = input.bool(true, title="Enable Alerts", group = "Alerts")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type UDT_Store
    array<line> lines
    array<box> boxes

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Functions  |
// # ========================================================================= #

//#region

method text_size(string s) =>
    out = switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
    out

method line_style(string l) =>
    out = switch l
        '⎯⎯⎯'  => line.style_solid
        '----'   => line.style_dashed
        '····'   => line.style_dotted

method font_style(string f) =>
    out = switch f
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

method set_opacity(color css, int opacity) =>
    blue  = color.b(css)
    red   = color.r(css)
    green = color.g(css)

    color.rgb(red, green, blue, opacity)

method label_style(string l) =>
    out = switch l
        'None'      => label.style_none
        'Circle'    => label.style_circle
        'Square'    => label.style_square
        'Diamond'   => label.style_diamond
        'Cross'     => label.style_cross
        'xCross'    => label.style_xcross
        
method table_position(string p) =>
    out = switch p
        "Bottom Center"     => position.bottom_center
        "Bottom Left"       => position.bottom_left
        "Bottom Right"      => position.bottom_right
        "Middle Center"     => position.middle_center
        "Middle Left"       => position.middle_left
        "Middle Right"      => position.middle_right
        "Top Center"        => position.top_center
        "Top Left"          => position.top_left
        "Top Right"         => position.top_right

method text_align(string align) =>
    out = switch align
        'Center'    => text.align_center
        'Top'       => text.align_top
        'Bottom'    => text.align_bottom
        'Left'      => text.align_left
        'Right'     => text.align_right

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store store = UDT_Store.new(array.new<line>(), array.new<box>())

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

var line gap_up_line1 = na
var line gap_up_line2 = na
var line gap_up_line_mid = na
var box gap_up_box = na
var label gap_up_lbl_top = na
var label gap_up_lbl_bot = na
var label gap_up_lbl_mid = na
var line gap_up_line_sub1 = na
var line gap_up_line_sub2 = na
var line gap_up_line_sub3 = na
var label gap_up_lbl_sub1 = na
var label gap_up_lbl_sub2 = na
var label gap_up_lbl_sub3 = na

var line gap_dn_line1 = na
var line gap_dn_line2 = na
var line gap_dn_line_mid = na
var box gap_dn_box = na
var label gap_dn_lbl_top = na
var label gap_dn_lbl_bot = na
var label gap_dn_lbl_mid = na
var line gap_dn_line_sub1 = na
var line gap_dn_line_sub2 = na
var line gap_dn_line_sub3 = na
var label gap_dn_lbl_sub1 = na
var label gap_dn_lbl_sub2 = na
var label gap_dn_lbl_sub3 = na

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Constants   |
// # ========================================================================= #

//#region

//

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #

// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

[tdo, pdc, pdh, pdl] = request.security(syminfo.tickerid, 'D', [open, close[1], high[1], low[1]], lookahead=barmerge.lookahead_on)
mid_line = math.abs((pdc + tdo) * 0.5)
gap_up_pct = (filter_bias == "Both" or filter_bias == "Bullish") and (guc ? (tdo > pdc) : (tdo > pdh))
gap_dn_pct = (filter_bias == "Both" or filter_bias == "Bearish") and (gdc ? (tdo < pdc) : (tdo < pdl))

is_new_day = ta.change(time('D')) != 0

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #

// # ========================================================================= #
// # |   Visuals   |
// # ========================================================================= #

//#region

daily_close_time = time_close('D')
show_1h_elements = timeframe.isseconds or timeframe.isticks or (timeframe.isintraday and timeframe.multiplier <= 60)

if is_new_day
    if gap_up_pct
        float top = tdo
        float bot = guc ? pdc : pdh
        float rng = top - bot
        
        gap_up_line1 := line.new(time, top, daily_close_time, top, xloc=xloc.bar_time, color=gap_up_css, width=2, style=line_style(gap_up_style))
        gap_up_line2 := line.new(time, bot, daily_close_time, bot, xloc=xloc.bar_time, color=gap_up_css, width=2, style=line_style(gap_up_style))
        gap_up_line_mid := line.new(time, mid_line, daily_close_time, mid_line, xloc=xloc.bar_time, color=gap_mid_show ? gap_mid_css : na, width=1, style=line_style(gap_mid_style))
        gap_up_box := box.new(time, top, daily_close_time, bot, xloc=xloc.bar_time, border_color=na, bgcolor=gap_up_fill_css)
        
        if show_1h_elements
            gap_up_box_1h = box.new(time, top, time + 3600000, bot, xloc=xloc.bar_time, border_color=na, bgcolor=color.new(gap_up_css, 70))
            gap_up_vline = line.new(time + 3600000, math.max(top, bot) + (2 * syminfo.mintick), time + 3600000, math.min(top, bot) - (2 * syminfo.mintick), xloc=xloc.bar_time, color=gap_up_css, width=2, style=line_style(gap_up_style))
        
        string txt_t = str.tostring(top, format.mintick)
        string txt_b = str.tostring(bot, format.mintick)
        string txt_m = str.tostring(mid_line, format.mintick)
        
        float s1 = na
        float s2 = na
        float s3 = na
        string t1 = ""
        string t2 = ""
        string t3 = ""
        
        if gap_sub_show
            if gap_subdivisions == "Quadrants"
                s1 := bot + rng * 0.25
                s2 := bot + rng * 0.50
                s3 := bot + rng * 0.75
                t1 := "25%"
                t2 := "50%"
                t3 := "75%"
                txt_t := "100%"
                txt_b := "0%"
                txt_m := "50%"
            else if gap_subdivisions == "OTE"
                t1 := "0.618"
                t2 := "0.705"
                t3 := "0.786"
                s1 := top - rng * 0.618
                s2 := top - rng * 0.705
                s3 := top - rng * 0.786
                txt_t := "0.0"
                txt_b := "1.0"
                txt_m := "0.5"
                
            gap_up_line_sub1 := line.new(time, s1, daily_close_time, s1, xloc=xloc.bar_time, color=gap_sub_css, width=1, style=line_style(gap_sub_style))
            gap_up_line_sub2 := line.new(time, s2, daily_close_time, s2, xloc=xloc.bar_time, color=gap_sub_css, width=1, style=line_style(gap_sub_style))
            gap_up_line_sub3 := line.new(time, s3, daily_close_time, s3, xloc=xloc.bar_time, color=gap_sub_css, width=1, style=line_style(gap_sub_style))
            
            if gap_labels
                gap_up_lbl_sub1 := label.new(daily_close_time, s1, t1, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_sub_css, style=label.style_label_left, size=text_size(general_text))
                gap_up_lbl_sub2 := label.new(daily_close_time, s2, t2, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_sub_css, style=label.style_label_left, size=text_size(general_text))
                gap_up_lbl_sub3 := label.new(daily_close_time, s3, t3, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_sub_css, style=label.style_label_left, size=text_size(general_text))
                
        gap_up_lbl_top := gap_labels ? label.new(daily_close_time, top, txt_t, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_up_css, style=label.style_label_left, size=text_size(general_text)) : na
        gap_up_lbl_bot := gap_labels ? label.new(daily_close_time, bot, txt_b, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_up_css, style=label.style_label_left, size=text_size(general_text)) : na
        gap_up_lbl_mid := (gap_labels and gap_mid_show) ? label.new(daily_close_time, mid_line, txt_m, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_mid_css, style=label.style_label_left, size=text_size(general_text)) : na
        
    if gap_dn_pct
        float top = gdc ? pdc : pdl
        float bot = tdo
        float rng = top - bot
        
        gap_dn_line1 := line.new(time, top, daily_close_time, top, xloc=xloc.bar_time, color=gap_dn_css, width=2, style=line_style(gap_dn_style))
        gap_dn_line2 := line.new(time, bot, daily_close_time, bot, xloc=xloc.bar_time, color=gap_dn_css, width=2, style=line_style(gap_dn_style))
        gap_dn_line_mid := line.new(time, mid_line, daily_close_time, mid_line, xloc=xloc.bar_time, color=gap_mid_show ? gap_mid_css : na, width=1, style=line_style(gap_mid_style))
        gap_dn_box := box.new(time, top, daily_close_time, bot, xloc=xloc.bar_time, border_color=na, bgcolor=gap_dn_fill_css)
        
        if show_1h_elements
            gap_dn_box_1h = box.new(time, top, time + 3600000, bot, xloc=xloc.bar_time, border_color=na, bgcolor=color.new(gap_dn_css, 70))
            gap_dn_vline = line.new(time + 3600000, math.max(top, bot) + (2 * syminfo.mintick), time + 3600000, math.min(top, bot) - (2 * syminfo.mintick), xloc=xloc.bar_time, color=gap_dn_css, width=2, style=line_style(gap_dn_style))
        
        string txt_t = str.tostring(top, format.mintick)
        string txt_b = str.tostring(bot, format.mintick)
        string txt_m = str.tostring(mid_line, format.mintick)
        
        float s1 = na
        float s2 = na
        float s3 = na
        string t1 = ""
        string t2 = ""
        string t3 = ""
        
        if gap_sub_show
            if gap_subdivisions == "Quadrants"
                s1 := bot + rng * 0.25
                s2 := bot + rng * 0.50
                s3 := bot + rng * 0.75
                t1 := "25%"
                t2 := "50%"
                t3 := "75%"
                txt_t := "100%"
                txt_b := "0%"
                txt_m := "50%"
            else if gap_subdivisions == "OTE"
                t1 := "0.618"
                t2 := "0.705"
                t3 := "0.786"
                s1 := bot + rng * 0.618
                s2 := bot + rng * 0.705
                s3 := bot + rng * 0.786
                txt_t := "1.0"
                txt_b := "0.0"
                txt_m := "0.5"
                
            gap_dn_line_sub1 := line.new(time, s1, daily_close_time, s1, xloc=xloc.bar_time, color=gap_sub_css, width=1, style=line_style(gap_sub_style))
            gap_dn_line_sub2 := line.new(time, s2, daily_close_time, s2, xloc=xloc.bar_time, color=gap_sub_css, width=1, style=line_style(gap_sub_style))
            gap_dn_line_sub3 := line.new(time, s3, daily_close_time, s3, xloc=xloc.bar_time, color=gap_sub_css, width=1, style=line_style(gap_sub_style))
            
            if gap_labels
                gap_dn_lbl_sub1 := label.new(daily_close_time, s1, t1, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_sub_css, style=label.style_label_left, size=text_size(general_text))
                gap_dn_lbl_sub2 := label.new(daily_close_time, s2, t2, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_sub_css, style=label.style_label_left, size=text_size(general_text))
                gap_dn_lbl_sub3 := label.new(daily_close_time, s3, t3, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_sub_css, style=label.style_label_left, size=text_size(general_text))
                
        gap_dn_lbl_top := gap_labels ? label.new(daily_close_time, top, txt_t, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_dn_css, style=label.style_label_left, size=text_size(general_text)) : na
        gap_dn_lbl_bot := gap_labels ? label.new(daily_close_time, bot, txt_b, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_dn_css, style=label.style_label_left, size=text_size(general_text)) : na
        gap_dn_lbl_mid := (gap_labels and gap_mid_show) ? label.new(daily_close_time, mid_line, txt_m, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_mid_css, style=label.style_label_left, size=text_size(general_text)) : na

//#endregion








































//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




















// # ========================================================================= #
// # |   Alerts   |
// # ========================================================================= #

//#region

bool gu_reach = gap_up_pct and low < tdo and (is_new_day or low[1] >= tdo)
bool gu_fill  = gap_up_pct and low <= pdc and (is_new_day or low[1] > pdc)

bool gd_reach = gap_dn_pct and high > tdo and (is_new_day or high[1] <= tdo)
bool gd_fill  = gap_dn_pct and high >= pdc and (is_new_day or high[1] < pdc)

if alerts_enable
    if gu_reach
        alert("Price has reached the Gap Up zone", alert.freq_once_per_bar)
    if gu_fill
        alert("Price has filled the Gap Up zone", alert.freq_once_per_bar)
    if gd_reach
        alert("Price has reached the Gap Down zone", alert.freq_once_per_bar)
    if gd_fill
        alert("Price has filled the Gap Down zone", alert.freq_once_per_bar)

alertcondition(gu_reach, title="Gap Up Reached", message="Price has reached the Gap Up zone")
alertcondition(gu_fill,  title="Gap Up Filled",  message="Price has filled the Gap Up zone")
alertcondition(gd_reach, title="Gap Down Reached", message="Price has reached the Gap Down zone")
alertcondition(gd_fill,  title="Gap Down Filled",  message="Price has filled the Gap Down zone")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Brand   |
// # ========================================================================= #

//#region

if barstate.isfirst and general_brand_show == false
    var table brand = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand, 0, 0,  "© CandelaCharts", text_color = colors_gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
