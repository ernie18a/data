<!-- tradingview-pine-id: PUB;032f14db165243ddba9aec31f156ab08 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CandelaCharts - RTH Gap

Source: https://www.tradingview.com/script/gw0PZIf7-CandelaCharts-RTH-Gap/

## Description

📝 Overview

The CandelaCharts - RTH Gap indicator is a professional technical tool designed to automatically identify, track, and visualize Regular Trading Hours (RTH) gaps. By targeting the exact NY close (4:00 PM for equities/ETFs like SPY, or 4:15 PM for futures) and open (9:30 AM), this indicator precisely maps out the untraded price voids between sessions, providing crucial intraday support and resistance levels.

https://www.tradingview.com/x/rddjG9xC/

Unlike standard gap indicators that fail on RTH-only charts, this script uses robust day-change logic to detect session transitions flawlessly. Unfilled gaps extend indefinitely across the chart, while filled gaps can be kept on the chart to serve as historical support/resistance.

📦 Features

[*] Exact RTH Logic: Automatically anchors session closings (16:00/16:15 NY time) and openings (09:30 NY time) to measure the exact RTH gap size, regardless of whether you have Extended Trading Hours (ETH) turned on or off.
[*] Customizable Inner Levels: Break down gap zones into mathematically significant price levels:
    
    [*] Midline (50% Mean): Plots the exact middle of the gap, a highly respected level for intraday rejections.
    [*] Quadrants: Divides the gap into 25%, 50%, and 75% retracement levels.
    [*] OTE (Optimal Trade Entry): Plots the 0.618, 0.705, and 0.786 Fibonacci levels to find high-probability reversal zones.
    
[*] Dynamic Labels: Displays dynamic price labels on the chart axis. When Inner Levels (OTE or Quadrants) are enabled, the top, bottom, and midline labels automatically update to show percentages/ratios (e.g. 100%, 50%, 0% or 0.0, 0.5, 1.0) rather than raw prices to keep the charts clean.
[*] Post-Fill Extensions: When a gap is filled, the main box stops extending to mark where the mitigation happened. However, if enabled, the levels (Top, Bottom, Midline, and Inner Levels) will convert to dashed lines and continue to extend to the current candle as historical support/resistance.
[*] Filter by Bias: Clean up your chart layout by choosing to display only Bullish gaps, Bearish gaps, or Both.
[*] Historical Tracking: Keep the last N gaps visible on the chart for history and context.

⚙️ Settings

[*] Session: Define the exact RTH Session hours (default is 09:30-16:00).
[*] History: Define how many historical gaps to keep on the chart.
[*] Gap Up / Gap Down: Toggle visibility and customize colors, fill transparency, and border styles.
[*] Midline: Toggle the visibility of the gap's 50% midline, and customize its style and color.
[*] Inner Levels: Toggle Quadrants or OTE subdivisions, and customize their styles and colors.
[*] Show Labels: Toggle price/ratio axis labels.
[*] Show Filled Gaps: When enabled, filled gaps turn gray and extend as dashed lines to the current candle. When disabled, filled gaps are completely removed from the chart.
[*] Alerts: Toggle the ability for the indicator to fire programmatic alerts.

⚡️ Showcase

RTH Gap - Default View
https://www.tradingview.com/x/LKHizjth/

RTH Gap - OTE Levels
https://www.tradingview.com/x/8EwWH5uv/

RTH Gap - Quadrant Levels
https://www.tradingview.com/x/sm4wUiSX/

🚨 Alerts

This indicator includes built-in alert conditions ensuring you never miss a critical gap test. Once "Enable Alerts" is checked in the settings, you can configure TradingView to notify you when:

[*] An RTH Gap Up is fully filled.
[*] An RTH Gap Down is fully filled.

⚠️ Disclaimer

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - RTH Gap", shorttitle="CandelaCharts - RTH Gap", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)










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

general_font                        = input.string("Monospace", "Text                         ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                  = input.bool(false, "Hide Brand", group = "General")
 
session_string                      = input.session("0930-1600:1234567", "RTH Session             ", inline="1.0", group="Session", tooltip="Define the Regular Trading Hours session.")
extend_right                        = input.bool(false, title="Extend Indefinitely             ", inline="2.0", group="Session")
 
max_visible_gaps                    = input.int(2, title="Latest Gaps              ", inline="1.0", group = "History", minval=1, maxval=500)
 
filter_bias                         = input.string("Both", title="Filter Bias               ", options=["Bullish", "Bearish", "Both"], group="Settings")

guc                                 = input.bool(true, title="Gap Up             ", inline="2.0", group = "Settings")
gap_up_style                        = input.string('⎯⎯⎯', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="2.0")
gap_up_css                          = input.color(colors_teal, title="", group = "Settings", inline="2.0")
gap_up_fill_css                     = input.color(color.new(colors_teal, 85), title="", group = "Settings", inline="2.0")
 
gdc                                 = input.bool(true, title="Gap Down         ", inline="3.0", group = "Settings")
gap_dn_style                        = input.string('⎯⎯⎯', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="3.0")
gap_dn_css                          = input.color(colors_red, title="", group = "Settings", inline="3.0")
gap_dn_fill_css                     = input.color(color.new(colors_red, 85), title="", group = "Settings", inline="3.0")
 
gap_mid_show                        = input.bool(true, title="Midline              ", inline="4.0", group = "Settings")
gap_mid_style                       = input.string('----', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="4.0")
gap_mid_css                         = input.color(colors_gray, title="", group = "Settings", inline="4.0")
 
gap_sub_show                        = input.bool(false, title="Inner Levels       ", inline="4.1", group="Settings")
gap_subdivisions                    = input.string("OTE", title="", options=["OTE", "Quadrants"], inline="4.1", group="Settings")
gap_sub_style                       = input.string('····', title="", options=['⎯⎯⎯', '----', '····'], group = "Settings", inline="4.1")
gap_sub_css                         = input.color(colors_gray, title="", group = "Settings", inline="4.1")

gap_labels                          = input.bool(true, title="Show Labels", inline="4.2", group="Settings")

alerts_enable                       = input.bool(true, title="Enable Alerts", group = "Alerts")

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

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   UDT & Variables   |
// # ========================================================================= #

//#region

type Gap
    box b
    line l_top
    line l_bot
    line l_mid
    line l_sub1
    line l_sub2
    line l_sub3
    line l_sub4
    line l_sub5
    box b_gz
    label lbl_top
    label lbl_bot
    label lbl_mid
    label lbl_sub1
    label lbl_sub2
    label lbl_sub3
    label lbl_sub4
    label lbl_sub5
    float top
    float bot
    int start_time
    bool is_up

var gaps = array.new<Gap>()
var float prev_rth_close = na
var int prev_rth_close_time = na
var float curr_rth_open = na

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

// Time anchors (New York)
int ny_year = year(time, 'America/New_York')
int ny_month = month(time, 'America/New_York')
int ny_day = dayofmonth(time, 'America/New_York')

int _16_00 = timestamp('America/New_York', ny_year, ny_month, ny_day, 16,  0, 0)
int _16_15 = timestamp('America/New_York', ny_year, ny_month, ny_day, 16, 15, 0)
int _9_30  = timestamp('America/New_York', ny_year, ny_month, ny_day,  9, 30, 0)
int MINUTE_MS = 1000 * 60
bool isEquity = syminfo.type == "stock"

rthClose = isEquity
     ? ta.valuewhen(time_close == _16_00, close, 0)
     : ta.valuewhen(time_close == _16_15, close, 0)

rthCloseTime = isEquity
     ? ta.valuewhen(time_close == _16_00, time_close, 0)
     : ta.valuewhen(time_close == _16_15, time_close, 0)

new_session = time == _9_30

if new_session
    curr_rth_open := open
    prev_rth_close := rthClose
    prev_rth_close_time := rthCloseTime

    if not na(prev_rth_close)
        is_gap_up = (filter_bias == "Both" or filter_bias == "Bullish") and (curr_rth_open > prev_rth_close)
        is_gap_dn = (filter_bias == "Both" or filter_bias == "Bearish") and (curr_rth_open < prev_rth_close)
        
        if (is_gap_up and guc) or (is_gap_dn and gdc)
            top = math.max(curr_rth_open, prev_rth_close)
            bot = math.min(curr_rth_open, prev_rth_close)
            mid = bot + (top - bot) / 2
            
            c_css = is_gap_up ? gap_up_css : gap_dn_css
            f_css = is_gap_up ? gap_up_fill_css : gap_dn_fill_css
            l_style = is_gap_up ? gap_up_style : gap_dn_style
            
            left_time = time
            int end_time = isEquity ? _16_00 : _16_15
            
            ext = extend_right ? extend.right : extend.none
            
            b = box.new(left_time, top, end_time, bot, xloc=xloc.bar_time, border_color=na, bgcolor=f_css, extend=ext)
            lt = line.new(left_time, top, end_time, top, xloc=xloc.bar_time, color=c_css, width=2, style=line_style(l_style), extend=ext)
            lb = line.new(left_time, bot, end_time, bot, xloc=xloc.bar_time, color=c_css, width=2, style=line_style(l_style), extend=ext)
            lm = gap_mid_show ? line.new(left_time, mid, end_time, mid, xloc=xloc.bar_time, color=gap_mid_css, width=1, style=line_style(gap_mid_style), extend=ext) : na
            
            string txt_t = "RTH High: " + str.tostring(top, format.mintick)
            string txt_b = "RTH Low: " + str.tostring(bot, format.mintick)
            string txt_m = "RTH Mid: " + str.tostring(mid, format.mintick)
            
            if gap_sub_show
                if gap_subdivisions == "Quadrants"
                    txt_t := "100%"
                    txt_b := "0%"
                    txt_m := "50%"
                else if gap_subdivisions == "OTE"
                    if is_gap_up
                        txt_t := "0.0"
                        txt_b := "1.0"
                        txt_m := "0.5"
                    else
                        txt_t := "1.0"
                        txt_b := "0.0"
                        txt_m := "0.5"

            lbl_t = gap_labels ? label.new(end_time, top, txt_t, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text)) : na
            lbl_b = gap_labels ? label.new(end_time, bot, txt_b, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text)) : na
            lbl_m = (gap_labels and gap_mid_show) ? label.new(end_time, mid, txt_m, xloc=xloc.bar_time, color=colors_transparent, textcolor=gap_mid_css, style=label.style_label_left, size=text_size(general_text)) : na
            
            float s1 = na
            float s2 = na
            float s3 = na
            float s4 = na
            float s5 = na
            string t1 = ""
            string t2 = ""
            string t3 = ""
            string t4 = ""
            string t5 = ""
            rng = top - bot
            
            if gap_sub_show
                if gap_subdivisions == "Quadrants"
                    s1 := bot + rng * 0.25
                    s2 := bot + rng * 0.50
                    s3 := bot + rng * 0.75
                    t1 := "25%"
                    t2 := "50%"
                    t3 := "75%"
                else if gap_subdivisions == "OTE"
                    t1 := "0.382"
                    t2 := "0.618"
                    t3 := "0.65"
                    t4 := "0.705"
                    t5 := "0.786"
                    if is_gap_up
                        s1 := top - rng * 0.382
                        s2 := top - rng * 0.618
                        s3 := top - rng * 0.65
                        s4 := top - rng * 0.705
                        s5 := top - rng * 0.786
                    else
                        s1 := bot + rng * 0.382
                        s2 := bot + rng * 0.618
                        s3 := bot + rng * 0.65
                        s4 := bot + rng * 0.705
                        s5 := bot + rng * 0.786
            
            ls1 = not na(s1) ? line.new(left_time, s1, end_time, s1, xloc=xloc.bar_time, color=c_css, width=1, style=line.style_solid, extend=ext) : na
            ls2 = not na(s2) ? line.new(left_time, s2, end_time, s2, xloc=xloc.bar_time, color=c_css, width=1, style=line.style_solid, extend=ext) : na
            ls3 = not na(s3) ? line.new(left_time, s3, end_time, s3, xloc=xloc.bar_time, color=c_css, width=1, style=line.style_solid, extend=ext) : na
            ls4 = not na(s4) ? line.new(left_time, s4, end_time, s4, xloc=xloc.bar_time, color=c_css, width=1, style=line.style_solid, extend=ext) : na
            ls5 = not na(s5) ? line.new(left_time, s5, end_time, s5, xloc=xloc.bar_time, color=c_css, width=1, style=line.style_solid, extend=ext) : na
            
            box b_gz = na
            if gap_sub_show and gap_subdivisions == "OTE"
                float gz_top = is_gap_up ? top - rng * 0.618 : bot + rng * 0.65
                float gz_bot = is_gap_up ? top - rng * 0.65 : bot + rng * 0.618
                b_gz := box.new(left_time, gz_top, end_time, gz_bot, xloc=xloc.bar_time, border_color=na, bgcolor=color.new(c_css, 70), extend=ext)
            
            label lbl_s1 = na
            label lbl_s2 = na
            label lbl_s3 = na
            label lbl_s4 = na
            label lbl_s5 = na
            
            if gap_labels and gap_sub_show
                lbl_s1 := label.new(end_time, s1, t1, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text))
                lbl_s2 := label.new(end_time, s2, t2, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text))
                lbl_s3 := label.new(end_time, s3, t3, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text))
                lbl_s4 := not na(s4) ? label.new(end_time, s4, t4, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text)) : na
                lbl_s5 := not na(s5) ? label.new(end_time, s5, t5, xloc=xloc.bar_time, color=colors_transparent, textcolor=c_css, style=label.style_label_left, size=text_size(general_text)) : na
            
            gaps.push(Gap.new(b, lt, lb, lm, ls1, ls2, ls3, ls4, ls5, b_gz, lbl_t, lbl_b, lbl_m, lbl_s1, lbl_s2, lbl_s3, lbl_s4, lbl_s5, top, bot, time, is_gap_up))
            
            if gaps.size() > max_visible_gaps
                old_gap = gaps.shift()
                old_gap.b.delete()
                old_gap.l_top.delete()
                old_gap.l_bot.delete()
                if not na(old_gap.l_mid)
                    old_gap.l_mid.delete()
                if not na(old_gap.l_sub1)
                    old_gap.l_sub1.delete()
                if not na(old_gap.l_sub2)
                    old_gap.l_sub2.delete()
                if not na(old_gap.l_sub3)
                    old_gap.l_sub3.delete()
                if not na(old_gap.l_sub4)
                    old_gap.l_sub4.delete()
                if not na(old_gap.l_sub5)
                    old_gap.l_sub5.delete()
                if not na(old_gap.b_gz)
                    old_gap.b_gz.delete()
                if not na(old_gap.lbl_top)
                    old_gap.lbl_top.delete()
                if not na(old_gap.lbl_bot)
                    old_gap.lbl_bot.delete()
                if not na(old_gap.lbl_mid)
                    old_gap.lbl_mid.delete()
                if not na(old_gap.lbl_sub1)
                    old_gap.lbl_sub1.delete()
                if not na(old_gap.lbl_sub2)
                    old_gap.lbl_sub2.delete()
                if not na(old_gap.lbl_sub3)
                    old_gap.lbl_sub3.delete()
                if not na(old_gap.lbl_sub4)
                    old_gap.lbl_sub4.delete()
                if not na(old_gap.lbl_sub5)
                    old_gap.lbl_sub5.delete()

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
