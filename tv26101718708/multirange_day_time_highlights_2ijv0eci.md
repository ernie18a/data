# Multi-Range Day & Time Highlights

- url: https://www.tradingview.com/script/2iJV0eci-Multi-Range-Day-Time-Highlights/
- type: indicator
- pine_id: PUB;3b0c88f87f8142a3a6d7f7433be1eb90
- version: 1.0

## Description

Here is a short, professional description you can use when publishing or sharing your indicator on TradingView:

### Multi-Range Session Highlights & Dynamic Dashboard

This advanced time-highlighting indicator is designed for traders who rely on specific trading sessions, killzones, or custom time windows. It allows you to visualize up to 15 independent time ranges on your chart while keeping track of their real-time status via a sleek, auto-scaling dashboard.

**Key Features:**

* **15 Customizable Ranges:** Define up to 15 unique time blocks with custom colors, borders, and text labels.
* **Smart DST Handling:** Unlike standard session indicators, you can set a specific Time Zone (e.g., `America/New_York` or `Europe/London`) for *each individual range*. This ensures your boxes automatically adjust for global Daylight Saving Time shifts, keeping your charts accurate year-round without manual updates.
* **Dynamic Dashboard:** A built-in, scalable table displays your active and inactive sessions in real-time. It dynamically resizes to show only the ranges you have enabled, keeping your screen clutter-free.
* **Declutter Mode (Hide Boxes):** Want a clean chart? You can hide the visual boxes on the chart for specific ranges while still tracking their Active/Inactive status in the dashboard.
* **Day-of-the-Week Filters:** Choose exactly which days each session should be active (e.g., enable a specific pre-market highlight only on Mondays and Wednesdays).

**Who is this for?**
Perfect for ICT/SMC traders, day traders managing overlaps between London and New York, or anyone who needs to clearly track global market open/close times effortlessly.

## Source Code

````pine
//@version=6
indicator("Multi-Range Day & Time Highlights (15 Ranges, DST & Scalable Dash)", overlay=true, max_boxes_count=500)

// ==========================================
// 1. GLOBAL SETTINGS & DASHBOARD SETUP
// ==========================================
g_global = "Global Settings"
showBoxLabels = input.bool(true, title="Show Labels Inside Boxes", group=g_global)

g_dash = "Dashboard Settings"
showDash = input.bool(true, title="Show Dashboard", group=g_dash)
dashPos  = input.string("Top Right", title="Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=g_dash)
dashSizeIn = input.string("Small", title="Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group=g_dash)

getDashPos(pos) =>
    pos == "Top Right" ? position.top_right : pos == "Bottom Right" ? position.bottom_right : pos == "Top Left" ? position.top_left : position.bottom_left

getTblSize(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.auto

dashSize = getTblSize(dashSizeIn)

// FUNCTION TO GENERATE DAY STRING
getDayString(su, mo, tu, we, th, fr, sa) =>
    str = ""
    if su
        str := str + "1"
    if mo
        str := str + "2"
    if tu
        str := str + "3"
    if we
        str := str + "4"
    if th
        str := str + "5"
    if fr
        str := str + "6"
    if sa
        str := str + "7"
    str

// FUNCTION TO MANAGE BOX DRAWING
manageBox(inSession, bgClr, borderClr, boxText, txtClr, showText) =>
    var box activeBox = na
    string displayText = showText ? boxText : "" 
    if inSession
        if ta.change(inSession) or na(activeBox)
            activeBox := box.new(left=bar_index, top=high, right=bar_index, bottom=low, 
                                 bgcolor=bgClr, border_color=borderClr, border_style=line.style_solid,
                                 text=displayText, text_color=txtClr, text_size=size.small, 
                                 text_halign=text.align_center, text_valign=text.align_bottom)
        else
            box.set_right(activeBox, bar_index)
            box.set_top(activeBox, math.max(box.get_top(activeBox), high))
            box.set_bottom(activeBox, math.min(box.get_bottom(activeBox), low))
    else
        activeBox := na
    activeBox

// ==========================================
// RANGE 1 (London)
// ==========================================
g1 = "Range 1 Settings"
r1_active  = input.bool(true, title="Enable Range 1", group=g1)
r1_showBox = input.bool(true, title="Show Box on Chart", group=g1)
r1_tz_in   = input.string("Europe/London", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g1)
r1_tz      = r1_tz_in == "Exchange" ? syminfo.timezone : r1_tz_in
r1_text    = input.string("London", title="Box Label 1", group=g1)
r1_text2   = input.string("10:00-18:30", title="Box Label 2 (Dashboard)", group=g1)
r1_txtClr  = input.color(color.white, title="Box Text Color", group=g1)
r1_time    = input.session("0800-1630", title="Time (Local to TZ)", group=g1)
r1_su      = input.bool(false, title="Sun", inline="r1_days", group=g1)
r1_mo      = input.bool(true, title="Mon", inline="r1_days", group=g1)
r1_tu      = input.bool(true, title="Tue", inline="r1_days", group=g1)
r1_we      = input.bool(true, title="Wed", inline="r1_days", group=g1)
r1_th      = input.bool(true, title="Thu", inline="r1_days", group=g1)
r1_fr      = input.bool(true, title="Fri", inline="r1_days", group=g1)
r1_sa      = input.bool(false, title="Sat", inline="r1_days", group=g1)
r1_bg      = input.color(color.new(color.blue, 90), title="Highlight Color", group=g1)
r1_border  = input.color(color.new(color.blue, 40), title="Border Color", group=g1)

r1_spec    = r1_time + ":" + getDayString(r1_su, r1_mo, r1_tu, r1_we, r1_th, r1_fr, r1_sa)
r1_inSess  = r1_active and not na(time(timeframe.period, r1_spec, r1_tz))
var box r1_box = na
r1_box := manageBox(r1_inSess and r1_showBox, r1_bg, r1_border, r1_text, r1_txtClr, showBoxLabels)

// ==========================================
// RANGE 2 (New York)
// ==========================================
g2 = "Range 2 Settings"
r2_active  = input.bool(true, title="Enable Range 2", group=g2)
r2_showBox = input.bool(true, title="Show Box on Chart", group=g2)
r2_tz_in   = input.string("America/New_York", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g2)
r2_tz      = r2_tz_in == "Exchange" ? syminfo.timezone : r2_tz_in
r2_text    = input.string("New York", title="Box Label 1", group=g2)
r2_text2   = input.string("16:30-23:00", title="Box Label 2 (Dashboard)", group=g2)
r2_txtClr  = input.color(color.white, title="Box Text Color", group=g2)
r2_time    = input.session("0930-1600", title="Time (Local to TZ)", group=g2)
r2_su      = input.bool(false, title="Sun", inline="r2_days", group=g2)
r2_mo      = input.bool(true, title="Mon", inline="r2_days", group=g2)
r2_tu      = input.bool(true, title="Tue", inline="r2_days", group=g2)
r2_we      = input.bool(true, title="Wed", inline="r2_days", group=g2)
r2_th      = input.bool(true, title="Thu", inline="r2_days", group=g2)
r2_fr      = input.bool(true, title="Fri", inline="r2_days", group=g2)
r2_sa      = input.bool(false, title="Sat", inline="r2_days", group=g2)
r2_bg      = input.color(color.new(color.orange, 90), title="Highlight Color", group=g2)
r2_border  = input.color(color.new(color.orange, 40), title="Border Color", group=g2)

r2_spec    = r2_time + ":" + getDayString(r2_su, r2_mo, r2_tu, r2_we, r2_th, r2_fr, r2_sa)
r2_inSess  = r2_active and not na(time(timeframe.period, r2_spec, r2_tz))
var box r2_box = na
r2_box := manageBox(r2_inSess and r2_showBox, r2_bg, r2_border, r2_text, r2_txtClr, showBoxLabels)

// ==========================================
// RANGE 3 (Tokyo)
// ==========================================
g3 = "Range 3 Settings"
r3_active  = input.bool(true, title="Enable Range 3", group=g3)
r3_showBox = input.bool(true, title="Show Box on Chart", group=g3)
r3_tz_in   = input.string("Asia/Tokyo", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g3)
r3_tz      = r3_tz_in == "Exchange" ? syminfo.timezone : r3_tz_in
r3_text    = input.string("Tokyo", title="Box Label 1", group=g3)
r3_text2   = input.string("03:00-09:00", title="Box Label 2 (Dashboard)", group=g3)
r3_txtClr  = input.color(color.white, title="Box Text Color", group=g3)
r3_time    = input.session("0900-1500", title="Time (Local to TZ)", group=g3)
r3_su      = input.bool(false, title="Sun", inline="r3_days", group=g3)
r3_mo      = input.bool(true, title="Mon", inline="r3_days", group=g3)
r3_tu      = input.bool(true, title="Tue", inline="r3_days", group=g3)
r3_we      = input.bool(true, title="Wed", inline="r3_days", group=g3)
r3_th      = input.bool(true, title="Thu", inline="r3_days", group=g3)
r3_fr      = input.bool(true, title="Fri", inline="r3_days", group=g3)
r3_sa      = input.bool(false, title="Sat", inline="r3_days", group=g3)
r3_bg      = input.color(color.new(color.green, 90), title="Highlight Color", group=g3)
r3_border  = input.color(color.new(color.green, 40), title="Border Color", group=g3)

r3_spec    = r3_time + ":" + getDayString(r3_su, r3_mo, r3_tu, r3_we, r3_th, r3_fr, r3_sa)
r3_inSess  = r3_active and not na(time(timeframe.period, r3_spec, r3_tz))
var box r3_box = na
r3_box := manageBox(r3_inSess and r3_showBox, r3_bg, r3_border, r3_text, r3_txtClr, showBoxLabels)

// ==========================================
// RANGE 4 (Sydney)
// ==========================================
g4 = "Range 4 Settings"
r4_active  = input.bool(true, title="Enable Range 4", group=g4)
r4_showBox = input.bool(true, title="Show Box on Chart", group=g4)
r4_tz_in   = input.string("Australia/Sydney", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g4)
r4_tz      = r4_tz_in == "Exchange" ? syminfo.timezone : r4_tz_in
r4_text    = input.string("Sydney", title="Box Label 1", group=g4)
r4_text2   = input.string("01:00-07:00", title="Box Label 2 (Dashboard)", group=g4)
r4_txtClr  = input.color(color.white, title="Box Text Color", group=g4)
r4_time    = input.session("1000-1600", title="Time (Local to TZ)", group=g4)
r4_su      = input.bool(false, title="Sun", inline="r4_days", group=g4)
r4_mo      = input.bool(true, title="Mon", inline="r4_days", group=g4)
r4_tu      = input.bool(true, title="Tue", inline="r4_days", group=g4)
r4_we      = input.bool(true, title="Wed", inline="r4_days", group=g4)
r4_th      = input.bool(true, title="Thu", inline="r4_days", group=g4)
r4_fr      = input.bool(true, title="Fri", inline="r4_days", group=g4)
r4_sa      = input.bool(false, title="Sat", inline="r4_days", group=g4)
r4_bg      = input.color(color.new(color.purple, 90), title="Highlight Color", group=g4)
r4_border  = input.color(color.new(color.purple, 40), title="Border Color", group=g4)

r4_spec    = r4_time + ":" + getDayString(r4_su, r4_mo, r4_tu, r4_we, r4_th, r4_fr, r4_sa)
r4_inSess  = r4_active and not na(time(timeframe.period, r4_spec, r4_tz))
var box r4_box = na
r4_box := manageBox(r4_inSess and r4_showBox, r4_bg, r4_border, r4_text, r4_txtClr, showBoxLabels)

// ==========================================
// RANGE 5 (Pre-Market NY)
// ==========================================
g5 = "Range 5 Settings"
r5_active  = input.bool(true, title="Enable Range 5", group=g5)
r5_showBox = input.bool(true, title="Show Box on Chart", group=g5)
r5_tz_in   = input.string("America/New_York", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g5)
r5_tz      = r5_tz_in == "Exchange" ? syminfo.timezone : r5_tz_in
r5_text    = input.string("Pre-Market", title="Box Label 1", group=g5)
r5_text2   = input.string("11:00-16:30", title="Box Label 2 (Dashboard)", group=g5)
r5_txtClr  = input.color(color.white, title="Box Text Color", group=g5)
r5_time    = input.session("0400-0930", title="Time (Local to TZ)", group=g5)
r5_su      = input.bool(false, title="Sun", inline="r5_days", group=g5)
r5_mo      = input.bool(true, title="Mon", inline="r5_days", group=g5)
r5_tu      = input.bool(true, title="Tue", inline="r5_days", group=g5)
r5_we      = input.bool(true, title="Wed", inline="r5_days", group=g5)
r5_th      = input.bool(true, title="Thu", inline="r5_days", group=g5)
r5_fr      = input.bool(true, title="Fri", inline="r5_days", group=g5)
r5_sa      = input.bool(false, title="Sat", inline="r5_days", group=g5)
r5_bg      = input.color(color.new(color.red, 90), title="Highlight Color", group=g5)
r5_border  = input.color(color.new(color.red, 40), title="Border Color", group=g5)

r5_spec    = r5_time + ":" + getDayString(r5_su, r5_mo, r5_tu, r5_we, r5_th, r5_fr, r5_sa)
r5_inSess  = r5_active and not na(time(timeframe.period, r5_spec, r5_tz))
var box r5_box = na
r5_box := manageBox(r5_inSess and r5_showBox, r5_bg, r5_border, r5_text, r5_txtClr, showBoxLabels)

// ==========================================
// RANGE 6 (Custom)
// ==========================================
g6 = "Range 6 Settings"
r6_active  = input.bool(false, title="Enable Range 6", group=g6)
r6_showBox = input.bool(true, title="Show Box on Chart", group=g6)
r6_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g6)
r6_tz      = r6_tz_in == "Exchange" ? syminfo.timezone : r6_tz_in
r6_text    = input.string("Custom 6", title="Box Label 1", group=g6)
r6_text2   = input.string("10:00-11:00", title="Box Label 2 (Dashboard)", group=g6)
r6_txtClr  = input.color(color.white, title="Box Text Color", group=g6)
r6_time    = input.session("1000-1100", title="Time (Local to TZ)", group=g6)
r6_su      = input.bool(true, title="Sun", inline="r6_days", group=g6)
r6_mo      = input.bool(true, title="Mon", inline="r6_days", group=g6)
r6_tu      = input.bool(true, title="Tue", inline="r6_days", group=g6)
r6_we      = input.bool(true, title="Wed", inline="r6_days", group=g6)
r6_th      = input.bool(true, title="Thu", inline="r6_days", group=g6)
r6_fr      = input.bool(true, title="Fri", inline="r6_days", group=g6)
r6_sa      = input.bool(false, title="Sat", inline="r6_days", group=g6)
r6_bg      = input.color(color.new(color.teal, 90), title="Highlight Color", group=g6)
r6_border  = input.color(color.new(color.teal, 40), title="Border Color", group=g6)

r6_spec    = r6_time + ":" + getDayString(r6_su, r6_mo, r6_tu, r6_we, r6_th, r6_fr, r6_sa)
r6_inSess  = r6_active and not na(time(timeframe.period, r6_spec, r6_tz))
var box r6_box = na
r6_box := manageBox(r6_inSess and r6_showBox, r6_bg, r6_border, r6_text, r6_txtClr, showBoxLabels)

// ==========================================
// RANGE 7 (Custom)
// ==========================================
g7 = "Range 7 Settings"
r7_active  = input.bool(false, title="Enable Range 7", group=g7)
r7_showBox = input.bool(true, title="Show Box on Chart", group=g7)
r7_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g7)
r7_tz      = r7_tz_in == "Exchange" ? syminfo.timezone : r7_tz_in
r7_text    = input.string("Custom 7", title="Box Label 1", group=g7)
r7_text2   = input.string("11:00-12:00", title="Box Label 2 (Dashboard)", group=g7)
r7_txtClr  = input.color(color.white, title="Box Text Color", group=g7)
r7_time    = input.session("1100-1200", title="Time (Local to TZ)", group=g7)
r7_su      = input.bool(true, title="Sun", inline="r7_days", group=g7)
r7_mo      = input.bool(true, title="Mon", inline="r7_days", group=g7)
r7_tu      = input.bool(true, title="Tue", inline="r7_days", group=g7)
r7_we      = input.bool(true, title="Wed", inline="r7_days", group=g7)
r7_th      = input.bool(true, title="Thu", inline="r7_days", group=g7)
r7_fr      = input.bool(true, title="Fri", inline="r7_days", group=g7)
r7_sa      = input.bool(false, title="Sat", inline="r7_days", group=g7)
r7_bg      = input.color(color.new(color.fuchsia, 90), title="Highlight Color", group=g7)
r7_border  = input.color(color.new(color.fuchsia, 40), title="Border Color", group=g7)

r7_spec    = r7_time + ":" + getDayString(r7_su, r7_mo, r7_tu, r7_we, r7_th, r7_fr, r7_sa)
r7_inSess  = r7_active and not na(time(timeframe.period, r7_spec, r7_tz))
var box r7_box = na
r7_box := manageBox(r7_inSess and r7_showBox, r7_bg, r7_border, r7_text, r7_txtClr, showBoxLabels)

// ==========================================
// RANGE 8 (Custom)
// ==========================================
g8 = "Range 8 Settings"
r8_active  = input.bool(false, title="Enable Range 8", group=g8)
r8_showBox = input.bool(true, title="Show Box on Chart", group=g8)
r8_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g8)
r8_tz      = r8_tz_in == "Exchange" ? syminfo.timezone : r8_tz_in
r8_text    = input.string("Custom 8", title="Box Label 1", group=g8)
r8_text2   = input.string("12:00-13:00", title="Box Label 2 (Dashboard)", group=g8)
r8_txtClr  = input.color(color.white, title="Box Text Color", group=g8)
r8_time    = input.session("1200-1300", title="Time (Local to TZ)", group=g8)
r8_su      = input.bool(true, title="Sun", inline="r8_days", group=g8)
r8_mo      = input.bool(true, title="Mon", inline="r8_days", group=g8)
r8_tu      = input.bool(true, title="Tue", inline="r8_days", group=g8)
r8_we      = input.bool(true, title="Wed", inline="r8_days", group=g8)
r8_th      = input.bool(true, title="Thu", inline="r8_days", group=g8)
r8_fr      = input.bool(true, title="Fri", inline="r8_days", group=g8)
r8_sa      = input.bool(false, title="Sat", inline="r8_days", group=g8)
r8_bg      = input.color(color.new(color.yellow, 90), title="Highlight Color", group=g8)
r8_border  = input.color(color.new(color.yellow, 40), title="Border Color", group=g8)

r8_spec    = r8_time + ":" + getDayString(r8_su, r8_mo, r8_tu, r8_we, r8_th, r8_fr, r8_sa)
r8_inSess  = r8_active and not na(time(timeframe.period, r8_spec, r8_tz))
var box r8_box = na
r8_box := manageBox(r8_inSess and r8_showBox, r8_bg, r8_border, r8_text, r8_txtClr, showBoxLabels)

// ==========================================
// RANGE 9 (Custom)
// ==========================================
g9 = "Range 9 Settings"
r9_active  = input.bool(false, title="Enable Range 9", group=g9)
r9_showBox = input.bool(true, title="Show Box on Chart", group=g9)
r9_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g9)
r9_tz      = r9_tz_in == "Exchange" ? syminfo.timezone : r9_tz_in
r9_text    = input.string("Custom 9", title="Box Label 1", group=g9)
r9_text2   = input.string("13:00-14:00", title="Box Label 2 (Dashboard)", group=g9)
r9_txtClr  = input.color(color.white, title="Box Text Color", group=g9)
r9_time    = input.session("1300-1400", title="Time (Local to TZ)", group=g9)
r9_su      = input.bool(true, title="Sun", inline="r9_days", group=g9)
r9_mo      = input.bool(true, title="Mon", inline="r9_days", group=g9)
r9_tu      = input.bool(true, title="Tue", inline="r9_days", group=g9)
r9_we      = input.bool(true, title="Wed", inline="r9_days", group=g9)
r9_th      = input.bool(true, title="Thu", inline="r9_days", group=g9)
r9_fr      = input.bool(true, title="Fri", inline="r9_days", group=g9)
r9_sa      = input.bool(false, title="Sat", inline="r9_days", group=g9)
r9_bg      = input.color(color.new(color.gray, 90), title="Highlight Color", group=g9)
r9_border  = input.color(color.new(color.gray, 40), title="Border Color", group=g9)

r9_spec    = r9_time + ":" + getDayString(r9_su, r9_mo, r9_tu, r9_we, r9_th, r9_fr, r9_sa)
r9_inSess  = r9_active and not na(time(timeframe.period, r9_spec, r9_tz))
var box r9_box = na
r9_box := manageBox(r9_inSess and r9_showBox, r9_bg, r9_border, r9_text, r9_txtClr, showBoxLabels)

// ==========================================
// RANGE 10 (Custom)
// ==========================================
g10 = "Range 10 Settings"
r10_active  = input.bool(false, title="Enable Range 10", group=g10)
r10_showBox = input.bool(true, title="Show Box on Chart", group=g10)
r10_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g10)
r10_tz      = r10_tz_in == "Exchange" ? syminfo.timezone : r10_tz_in
r10_text    = input.string("Custom 10", title="Box Label 1", group=g10)
r10_text2   = input.string("14:00-15:00", title="Box Label 2 (Dashboard)", group=g10)
r10_txtClr  = input.color(color.white, title="Box Text Color", group=g10)
r10_time    = input.session("1400-1500", title="Time (Local to TZ)", group=g10)
r10_su      = input.bool(true, title="Sun", inline="r10_days", group=g10)
r10_mo      = input.bool(true, title="Mon", inline="r10_days", group=g10)
r10_tu      = input.bool(true, title="Tue", inline="r10_days", group=g10)
r10_we      = input.bool(true, title="Wed", inline="r10_days", group=g10)
r10_th      = input.bool(true, title="Thu", inline="r10_days", group=g10)
r10_fr      = input.bool(true, title="Fri", inline="r10_days", group=g10)
r10_sa      = input.bool(false, title="Sat", inline="r10_days", group=g10)
r10_bg      = input.color(color.new(color.maroon, 90), title="Highlight Color", group=g10)
r10_border  = input.color(color.new(color.maroon, 40), title="Border Color", group=g10)

r10_spec    = r10_time + ":" + getDayString(r10_su, r10_mo, r10_tu, r10_we, r10_th, r10_fr, r10_sa)
r10_inSess  = r10_active and not na(time(timeframe.period, r10_spec, r10_tz))
var box r10_box = na
r10_box := manageBox(r10_inSess and r10_showBox, r10_bg, r10_border, r10_text, r10_txtClr, showBoxLabels)

// ==========================================
// RANGE 11 (Custom)
// ==========================================
g11 = "Range 11 Settings"
r11_active  = input.bool(false, title="Enable Range 11", group=g11)
r11_showBox = input.bool(true, title="Show Box on Chart", group=g11)
r11_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g11)
r11_tz      = r11_tz_in == "Exchange" ? syminfo.timezone : r11_tz_in
r11_text    = input.string("Custom 11", title="Box Label 1", group=g11)
r11_text2   = input.string("15:00-16:00", title="Box Label 2 (Dashboard)", group=g11)
r11_txtClr  = input.color(color.white, title="Box Text Color", group=g11)
r11_time    = input.session("1500-1600", title="Time (Local to TZ)", group=g11)
r11_su      = input.bool(true, title="Sun", inline="r11_days", group=g11)
r11_mo      = input.bool(true, title="Mon", inline="r11_days", group=g11)
r11_tu      = input.bool(true, title="Tue", inline="r11_days", group=g11)
r11_we      = input.bool(true, title="Wed", inline="r11_days", group=g11)
r11_th      = input.bool(true, title="Thu", inline="r11_days", group=g11)
r11_fr      = input.bool(true, title="Fri", inline="r11_days", group=g11)
r11_sa      = input.bool(false, title="Sat", inline="r11_days", group=g11)
r11_bg      = input.color(color.new(color.aqua, 90), title="Highlight Color", group=g11)
r11_border  = input.color(color.new(color.aqua, 40), title="Border Color", group=g11)

r11_spec    = r11_time + ":" + getDayString(r11_su, r11_mo, r11_tu, r11_we, r11_th, r11_fr, r11_sa)
r11_inSess  = r11_active and not na(time(timeframe.period, r11_spec, r11_tz))
var box r11_box = na
r11_box := manageBox(r11_inSess and r11_showBox, r11_bg, r11_border, r11_text, r11_txtClr, showBoxLabels)

// ==========================================
// RANGE 12 (Custom)
// ==========================================
g12 = "Range 12 Settings"
r12_active  = input.bool(false, title="Enable Range 12", group=g12)
r12_showBox = input.bool(true, title="Show Box on Chart", group=g12)
r12_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g12)
r12_tz      = r12_tz_in == "Exchange" ? syminfo.timezone : r12_tz_in
r12_text    = input.string("Custom 12", title="Box Label 1", group=g12)
r12_text2   = input.string("16:00-17:00", title="Box Label 2 (Dashboard)", group=g12)
r12_txtClr  = input.color(color.white, title="Box Text Color", group=g12)
r12_time    = input.session("1600-1700", title="Time (Local to TZ)", group=g12)
r12_su      = input.bool(true, title="Sun", inline="r12_days", group=g12)
r12_mo      = input.bool(true, title="Mon", inline="r12_days", group=g12)
r12_tu      = input.bool(true, title="Tue", inline="r12_days", group=g12)
r12_we      = input.bool(true, title="Wed", inline="r12_days", group=g12)
r12_th      = input.bool(true, title="Thu", inline="r12_days", group=g12)
r12_fr      = input.bool(true, title="Fri", inline="r12_days", group=g12)
r12_sa      = input.bool(false, title="Sat", inline="r12_days", group=g12)
r12_bg      = input.color(color.new(color.navy, 90), title="Highlight Color", group=g12)
r12_border  = input.color(color.new(color.navy, 40), title="Border Color", group=g12)

r12_spec    = r12_time + ":" + getDayString(r12_su, r12_mo, r12_tu, r12_we, r12_th, r12_fr, r12_sa)
r12_inSess  = r12_active and not na(time(timeframe.period, r12_spec, r12_tz))
var box r12_box = na
r12_box := manageBox(r12_inSess and r12_showBox, r12_bg, r12_border, r12_text, r12_txtClr, showBoxLabels)

// ==========================================
// RANGE 13 (Custom)
// ==========================================
g13 = "Range 13 Settings"
r13_active  = input.bool(false, title="Enable Range 13", group=g13)
r13_showBox = input.bool(true, title="Show Box on Chart", group=g13)
r13_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g13)
r13_tz      = r13_tz_in == "Exchange" ? syminfo.timezone : r13_tz_in
r13_text    = input.string("Custom 13", title="Box Label 1", group=g13)
r13_text2   = input.string("17:00-18:00", title="Box Label 2 (Dashboard)", group=g13)
r13_txtClr  = input.color(color.white, title="Box Text Color", group=g13)
r13_time    = input.session("1700-1800", title="Time (Local to TZ)", group=g13)
r13_su      = input.bool(true, title="Sun", inline="r13_days", group=g13)
r13_mo      = input.bool(true, title="Mon", inline="r13_days", group=g13)
r13_tu      = input.bool(true, title="Tue", inline="r13_days", group=g13)
r13_we      = input.bool(true, title="Wed", inline="r13_days", group=g13)
r13_th      = input.bool(true, title="Thu", inline="r13_days", group=g13)
r13_fr      = input.bool(true, title="Fri", inline="r13_days", group=g13)
r13_sa      = input.bool(false, title="Sat", inline="r13_days", group=g13)
r13_bg      = input.color(color.new(color.olive, 90), title="Highlight Color", group=g13)
r13_border  = input.color(color.new(color.olive, 40), title="Border Color", group=g13)

r13_spec    = r13_time + ":" + getDayString(r13_su, r13_mo, r13_tu, r13_we, r13_th, r13_fr, r13_sa)
r13_inSess  = r13_active and not na(time(timeframe.period, r13_spec, r13_tz))
var box r13_box = na
r13_box := manageBox(r13_inSess and r13_showBox, r13_bg, r13_border, r13_text, r13_txtClr, showBoxLabels)

// ==========================================
// RANGE 14 (Custom)
// ==========================================
g14 = "Range 14 Settings"
r14_active  = input.bool(false, title="Enable Range 14", group=g14)
r14_showBox = input.bool(true, title="Show Box on Chart", group=g14)
r14_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g14)
r14_tz      = r14_tz_in == "Exchange" ? syminfo.timezone : r14_tz_in
r14_text    = input.string("Custom 14", title="Box Label 1", group=g14)
r14_text2   = input.string("18:00-19:00", title="Box Label 2 (Dashboard)", group=g14)
r14_txtClr  = input.color(color.white, title="Box Text Color", group=g14)
r14_time    = input.session("1800-1900", title="Time (Local to TZ)", group=g14)
r14_su      = input.bool(true, title="Sun", inline="r14_days", group=g14)
r14_mo      = input.bool(true, title="Mon", inline="r14_days", group=g14)
r14_tu      = input.bool(true, title="Tue", inline="r14_days", group=g14)
r14_we      = input.bool(true, title="Wed", inline="r14_days", group=g14)
r14_th      = input.bool(true, title="Thu", inline="r14_days", group=g14)
r14_fr      = input.bool(true, title="Fri", inline="r14_days", group=g14)
r14_sa      = input.bool(false, title="Sat", inline="r14_days", group=g14)
r14_bg      = input.color(color.new(color.lime, 90), title="Highlight Color", group=g14)
r14_border  = input.color(color.new(color.lime, 40), title="Border Color", group=g14)

r14_spec    = r14_time + ":" + getDayString(r14_su, r14_mo, r14_tu, r14_we, r14_th, r14_fr, r14_sa)
r14_inSess  = r14_active and not na(time(timeframe.period, r14_spec, r14_tz))
var box r14_box = na
r14_box := manageBox(r14_inSess and r14_showBox, r14_bg, r14_border, r14_text, r14_txtClr, showBoxLabels)

// ==========================================
// RANGE 15 (Custom)
// ==========================================
g15 = "Range 15 Settings"
r15_active  = input.bool(false, title="Enable Range 15", group=g15)
r15_showBox = input.bool(true, title="Show Box on Chart", group=g15)
r15_tz_in   = input.string("Asia/Jerusalem", title="Time Zone", options=["Exchange", "UTC", "Asia/Jerusalem", "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney"], group=g15)
r15_tz      = r15_tz_in == "Exchange" ? syminfo.timezone : r15_tz_in
r15_text    = input.string("Custom 15", title="Box Label 1", group=g15)
r15_text2   = input.string("19:00-20:00", title="Box Label 2 (Dashboard)", group=g15)
r15_txtClr  = input.color(color.white, title="Box Text Color", group=g15)
r15_time    = input.session("1900-2000", title="Time (Local to TZ)", group=g15)
r15_su      = input.bool(true, title="Sun", inline="r15_days", group=g15)
r15_mo      = input.bool(true, title="Mon", inline="r15_days", group=g15)
r15_tu      = input.bool(true, title="Tue", inline="r15_days", group=g15)
r15_we      = input.bool(true, title="Wed", inline="r15_days", group=g15)
r15_th      = input.bool(true, title="Thu", inline="r15_days", group=g15)
r15_fr      = input.bool(true, title="Fri", inline="r15_days", group=g15)
r15_sa      = input.bool(false, title="Sat", inline="r15_days", group=g15)
r15_bg      = input.color(color.new(color.silver, 90), title="Highlight Color", group=g15)
r15_border  = input.color(color.new(color.silver, 40), title="Border Color", group=g15)

r15_spec    = r15_time + ":" + getDayString(r15_su, r15_mo, r15_tu, r15_we, r15_th, r15_fr, r15_sa)
r15_inSess  = r15_active and not na(time(timeframe.period, r15_spec, r15_tz))
var box r15_box = na
r15_box := manageBox(r15_inSess and r15_showBox, r15_bg, r15_border, r15_text, r15_txtClr, showBoxLabels)

// ==========================================
// DASHBOARD LOGIC
// ==========================================
// Function to populate a row
populateRow(t, c_row, r_active, r_text1, r_text2, r_inSess, r_bgClr, dSize) =>
    next_row = c_row
    if r_active
        // Convert highlight background color to solid for text
        solidTxtClr = color.new(r_bgClr, 0)
        
        // Set Active/Inactive status and background colors
        statusText = r_inSess ? "Active" : "Inactive"
        statusBg   = r_inSess ? color.new(#089981, 10) : color.new(#ef5350, 10) 
        
        // Draw cells (Column 0: Label 1 | Column 1: Label 2 | Column 2: Status)
        table.cell(t, 0, next_row, r_text1, text_color=solidTxtClr, text_halign=text.align_center, text_size=dSize)
        table.cell(t, 1, next_row, r_text2, text_color=solidTxtClr, text_halign=text.align_center, text_size=dSize)
        table.cell(t, 2, next_row, statusText, text_color=color.white, bgcolor=statusBg, text_halign=text.align_center, text_size=dSize)
        
        next_row += 1
    next_row // Return the updated row count

if showDash and barstate.islast
    // Count active ranges first to perfectly size the table and avoid ghost borders
    int activeCount = 0
    if r1_active
        activeCount += 1
    if r2_active
        activeCount += 1
    if r3_active
        activeCount += 1
    if r4_active
        activeCount += 1
    if r5_active
        activeCount += 1
    if r6_active
        activeCount += 1
    if r7_active
        activeCount += 1
    if r8_active
        activeCount += 1
    if r9_active
        activeCount += 1
    if r10_active
        activeCount += 1
    if r11_active
        activeCount += 1
    if r12_active
        activeCount += 1
    if r13_active
        activeCount += 1
    if r14_active
        activeCount += 1
    if r15_active
        activeCount += 1

    if activeCount > 0
        // Create table dynamically based ONLY on active ranges
        table dash = table.new(getDashPos(dashPos), columns=3, rows=activeCount, bgcolor=color.new(#1e222d, 10), border_width=1, border_color=color.new(#434651, 50))
        int curr_row = 0
        
        curr_row := populateRow(dash, curr_row, r1_active, r1_text, r1_text2, r1_inSess, r1_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r2_active, r2_text, r2_text2, r2_inSess, r2_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r3_active, r3_text, r3_text2, r3_inSess, r3_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r4_active, r4_text, r4_text2, r4_inSess, r4_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r5_active, r5_text, r5_text2, r5_inSess, r5_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r6_active, r6_text, r6_text2, r6_inSess, r6_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r7_active, r7_text, r7_text2, r7_inSess, r7_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r8_active, r8_text, r8_text2, r8_inSess, r8_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r9_active, r9_text, r9_text2, r9_inSess, r9_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r10_active, r10_text, r10_text2, r10_inSess, r10_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r11_active, r11_text, r11_text2, r11_inSess, r11_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r12_active, r12_text, r12_text2, r12_inSess, r12_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r13_active, r13_text, r13_text2, r13_inSess, r13_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r14_active, r14_text, r14_text2, r14_inSess, r14_bg, dashSize)
        curr_row := populateRow(dash, curr_row, r15_active, r15_text, r15_text2, r15_inSess, r15_bg, dashSize)
````
