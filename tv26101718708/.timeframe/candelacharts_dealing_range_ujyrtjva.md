# CandelaCharts - Dealing Range

- url: https://www.tradingview.com/script/uJyRtjva-CandelaCharts-Dealing-Range/
- type: indicator
- pine_id: PUB;aaa5ac50b6c6432ebf779c76cf759b38
- version: 1.0

## Description

📝 [b]Overview[/b]

[b]Dealing Range[/b] is a precision tool designed to identify and measure the internal and external ranges that define institutional market structure. By mapping out specific high and low boundaries across different timeframes and sessions, it provides traders with clear Premium, Discount, and Equilibrium zones. This context is essential for recognizing where smart money is likely to accumulate or distribute relative to a specific Dealing Range.

 📦 [b]Features[/b]

Modular visualization for multi-timeframe analysis. Toggle three independent ranges to see nested structure and overlapping PD Arrays at a glance.
[list]
[*] [b]Projected & Overlay Modes[/b]: View ranges forward in time (Projected) to anticipate levels, or anchored to historical data (Overlay) for structural context.
[*] [b]Multiple Measurement Modes[/b]: Switch between Premium/Discount, OTE (Optimal Trade Entry), Quadrants, 8ths, and 16ths.
[*] [b]Session Tracking[/b]: Define specific sessions (e.g., London, New York) to automatically capture the relevant high and low boundaries.
[*] [b]Multi-Timeframe Support[/b]: Overlay ranges from Higher Timeframes (HTF) onto your current execution chart.
[*] [b]Dynamic Zones[/b]: Visual boxes highlighting Premium, Discount, and the specific OTE (61.8% - 78.6%) range.
[/list]

 ⚙️ [b]Settings[/b]

[b]Global Settings[/b]
[list]
[*] [b]Start Offset[/b]: Gap (in bars or time) for projected ranges.
[*] [b]Range Width[/b]: Horizontal length of the range visualization.
[*] [b]Gap Width[/b]: Horizontal space between multiple projected ranges.
[*] [b]Timezone[/b]: Set your local or market timezone for session accuracy.
[/list]

[b]Range Slots (1, 2, 3)[/b]
[list]
[*] [b]Enabled[/b]: Toggle individual ranges on or off.
[*] [b]Reverse[/b]: Flip the range (useful for identifying bearish equivalents of bullish setups).
[*] [b]UI Mode[/b]: [i]Projected[/i] (future bars) or [i]Overlay[/i] (historical data).
[*] [b]Range Mode[/b]: Select measurement logic (OTE, Quadrants, etc.).
[*] [b]Session / Timeframe[/b]: Input a specific session string (e.g., "0830-1100") or select a timeframe (e.g., "1H", "4H", "D").
[*] [b]Colors[/b]: Customize Premium, Discount, and OTE upper/lower zone colors.
[/list]

 ⚡️ [b]Showcase[/b]

[i]Projected Dealing Range (Premium/Discount Mode)[/i]
https://www.tradingview.com/x/Sb1Uoyto/

[i]Projected Dealing Range (OTE Mode)[/i]
https://www.tradingview.com/x/mMP9KP4F/

[i]Overlay Dealing Range (Quadrants Mode)[/i]
https://www.tradingview.com/x/Rf3aobFp/

[i]Overlay Dealing Range (8ths Mode)[/i]
https://www.tradingview.com/x/N1cv9Sy8/

[i]Overlay Dealing Range (16ths Mode)[/i]
https://www.tradingview.com/x/afCGyosW/

[i]Projected & Overlay Dealing Range[/i]
https://www.tradingview.com/x/O1z24ATO/

 📒 [b]Usage[/b]

[list]
[*] [b]Identifying OTE (Optimal Trade Entry)[/b]: Set Range Mode to "OTE" to highlight the 62% and 79% retracement levels. These are high-confluence zones for entries within a directional bias.
[*] [b]Premium vs. Discount[/b]: Institutional buys typically occur in the Discount zone (below 0.5 Equilibrium), while sells occur in Premium (above 0.5 Equilibrium).
[*] [b]Multi-Timeframe Context[/b]: Enable Range 1 for the Daily timeframe and Range 2 for the 4-Hour timeframe. Look for entries where a Lower Timeframe OTE aligns with a Higher Timeframe Discount zone.
[*] [b]Session Highs/Lows[/b]: Use the Session input to automatically measure the London session range and project it into the New York session for potential distribution shifts.
[/list]

🚨 [b]Alerts[/b]

This indicator does not currently support automated alerts. All range detections and zone entries are visual-only. Users who require notifications can manually set alerts using standard TradingView horizontal levels at the Equilibrium (0.5) or OTE boundaries.


 ⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator(title = "CandelaCharts - Dealing Range", shorttitle = "CandelaCharts - Dealing Range", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)











// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

color_purple  = #9C27B0
color_red     = #EF5350
color_green   = #4CAF50
color_blue    = #2196F3
color_black   = #212121
color_gray    = color.gray

color_transparent  = color.new(color.white, 100)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font       = input.string("Monospace", "Text Style              ", options = ["Default", "Monospace"], inline = "5", group = "General")
general_text       = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "5", group = "General", tooltip = "Customize global text size and style")
general_brand_show = input.bool(false, "Hide Brand", group = "General")

i_proj_offset       = input.int(10, "Start Offset", minval = 0, group = "Settings", tooltip = "Initial gap in bars (Projected) or time (Overlay).")
i_width             = input.int(10, "Range Width", minval = 1, group = "Settings", tooltip = "Width in bars (Projected) or time (Overlay).")
i_gap               = input.int(10, "Gap Width", minval = 0, group = "Settings", tooltip = "Gap in bars between projected ranges.")
i_timezone          = input.string("UTC-4", "Timezone", group = "Settings", tooltip = "Timezone for Session calculations (e.g. UTC-4, America/New_York).")

i_show_1            = input.bool(true, "Enabled", group = "Range 1")
i_reverse_1         = input.bool(false, "Reverse", group = "Range 1")
i_ui_mode_1         = input.string("Projected", "UI Mode", options = ["Projected", "Overlay"], group = "Range 1", tooltip = "Projected: Forward into the future using Bar Indexes.\nOverlay: Directly on historical bars using Time.")
i_mode_1            = input.string("OTE", "Range Mode", options = ["Premium/Discount", "OTE", "Quadrants", "8ths", "16ths"], group = "Range 1")
i_sess_1            = input.session("", "Session", group = "Range 1", tooltip = "Specific time window. Overrides timeframe if specified.")
i_tf_1              = input.timeframe("60", "Timeframe           ", group = "Range 1", inline = "tf1")
i_mult_1            = input.int(1, "x", minval = 1, group = "Range 1", inline = "tf1", tooltip = "Multiplier of the current timeframe. If > 1, it overrides the Timeframe selection.")
i_c_prem_1          = input.color(color.new(color_purple, 90), "Premium Color", group = "Range 1")
i_c_ote_1           = input.color(color.new(color_purple, 95), "OTE Upper Color", group = "Range 1")
i_c_ote_l_1         = input.color(color.new(color_red, 92), "OTE Lower Color", group = "Range 1")
i_c_disc_1          = input.color(color.new(color_green, 90), "Discount Color", group = "Range 1")

i_show_2            = input.bool(true, "Enabled", group = "Range 2")
i_reverse_2         = input.bool(false, "Reverse", group = "Range 2")
i_ui_mode_2         = input.string("Projected", "UI Mode", options = ["Projected", "Overlay"], group = "Range 2")
i_mode_2            = input.string("OTE", "Range Mode", options = ["Premium/Discount", "OTE", "Quadrants", "8ths", "16ths"], group = "Range 2")
i_sess_2            = input.session("", "Session", group = "Range 2")
i_tf_2              = input.timeframe("240", "Timeframe           ", group = "Range 2", inline = "tf2")
i_mult_2            = input.int(1, "x", minval = 1, group = "Range 2", inline = "tf2", tooltip = "Multiplier of the current timeframe. If > 1, it overrides the Timeframe selection.")
i_c_prem_2          = input.color(color.new(color_purple, 90), "Premium Color", group = "Range 2")
i_c_ote_2           = input.color(color.new(color_purple, 95), "OTE Upper Color", group = "Range 2")
i_c_ote_l_2         = input.color(color.new(color_red, 92), "OTE Lower Color", group = "Range 2")
i_c_disc_2          = input.color(color.new(color_green, 90), "Discount Color", group = "Range 2")

i_show_3            = input.bool(false, "Enabled", group = "Range 3")
i_reverse_3         = input.bool(false, "Reverse", group = "Range 3")
i_ui_mode_3         = input.string("Projected", "UI Mode", options = ["Projected", "Overlay"], group = "Range 3")
i_mode_3            = input.string("OTE", "Range Mode", options = ["Premium/Discount", "OTE", "Quadrants", "8ths", "16ths"], group = "Range 3")
i_sess_3            = input.session("", "Session", group = "Range 3")
i_tf_3              = input.timeframe("D", "Timeframe           ", group = "Range 3", inline = "tf3")
i_mult_3            = input.int(1, "x", minval = 1, group = "Range 3", inline = "tf3", tooltip = "Multiplier of the current timeframe. If > 1, it overrides the Timeframe selection.")
i_c_prem_3          = input.color(color.new(color_purple, 90), "Premium Color", group = "Range 3")
i_c_ote_3           = input.color(color.new(color_purple, 95), "OTE Upper Color", group = "Range 3")
i_c_ote_l_3         = input.color(color.new(color_red, 92), "OTE Lower Color", group = "Range 3")
i_c_disc_3          = input.color(color.new(color_green, 90), "Discount Color", group = "Range 3")

i_show_labels       = input.bool(true, "Show Labels", group = "Visuals")
i_thickness         = input.int(1, "Line Thickness", minval = 1, maxval = 5, group = "Visuals")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   UDTs   |
// # ========================================================================= #

//#region

type UDT_Level
    line   ln
    label  lbl

type UDT_RangeVisuals
    UDT_Level[] levels
    box         box_premium
    box         box_ote_upper
    box         box_ote_lower
    box         box_discount

type UDT_SessionState
    float h = na
    float l = na
    int   t1 = na
    int   t2 = na
    float last_h = na
    float last_l = na
    int   last_t1 = na
    int   last_t2 = na

type UDT_Store
    UDT_RangeVisuals r1
    UDT_RangeVisuals r2
    UDT_RangeVisuals r3

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Functions  |
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

method line_style(string line) =>
    out = switch line
        '⎯⎯⎯'  => line.style_solid
        '----'   => line.style_dashed
        '····'   => line.style_dotted

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Utils  |
// # ========================================================================= #

//#region

method update_session(UDT_SessionState this, string sess) =>
    if sess != ""
        bool in_session = not na(time(timeframe.period, sess, i_timezone))
        if in_session
            if not in_session[1]
                this.h := high
                this.l := low
                this.t1 := time
            else
                this.h := math.max(this.h, high)
                this.l := math.min(this.l, low)
            this.t2 := time_close
        else if in_session[1]
            this.last_h := this.h
            this.last_l := this.l
            this.last_t1 := this.t1
            this.last_t2 := this.t2

method update_level(UDT_Level this, bool active, int x1, int x2, float price, color c, string style, string txt, bool show_label, string x_type) =>
    if active
        if na(this.ln)
            this.ln  := line.new(x1, price, x2, price, x_type, extend.none, c, style == "dotted" ? line.style_dotted : line.style_solid, i_thickness)
            if show_label
                this.lbl := label.new(x2, price, txt, x_type, yloc.price, color_transparent, label.style_label_left, c, size.tiny, text.align_left)
        else
            line.set_xy1(this.ln, x1, price)
            line.set_xy2(this.ln, x2, price)
            line.set_color(this.ln, c)
            line.set_width(this.ln, i_thickness)
            line.set_style(this.ln, style == "dotted" ? line.style_dotted : line.style_solid)
            if not na(this.lbl)
                label.set_xy(this.lbl, x2, price)
                label.set_text(this.lbl, txt)
                label.set_textcolor(this.lbl, c)
            else if show_label
                this.lbl := label.new(x2, price, txt, x_type, yloc.price, color_transparent, label.style_label_left, c, size.tiny, text.align_left)
    else
        line.delete(this.ln), this.ln := na
        label.delete(this.lbl), this.lbl := na
    this

method update_box(box b, bool active, int x1, float y1, int x2, float y2, color bg, string x_type) =>
    box out = b
    if active
        if na(b)
            out := box.new(x1, y1, x2, y2, color_transparent, 0, line.style_solid, extend.none, x_type, bg)
        else
            box.set_lefttop(out, x1, y1)
            box.set_rightbottom(out, x2, y2)
            box.set_bgcolor(out, bg)
    else
        box.delete(b)
        out := na
    out

method update_range_visuals(UDT_RangeVisuals this, bool active, string mode, bool reverse, int x1, int x2, float top, float bottom, string tf_label, color c_prem, color c_ote, color c_ote_l, color c_disc, string x_type) =>
    if active
        float rng = top - bottom
        float[] ratios = array.new_float(0)
        color[] colors = array.new_color(0)
        string[] labels = array.new_string(0)
        string[] styles = array.new_string(0)
        
        // Mode logic
        if mode == "Premium/Discount"
            ratios := array.from(1.0, 0.5, 0.0)
            colors := array.from(color_black, color_red, color_black)
            labels := array.from("1.0 (100)", "0.5 (EQ)", "0.0 (0)")
            styles := array.from("solid", "solid", "solid")
            
        else if mode == "OTE"
            ratios := array.from(1.0, 0.786, 0.618, 0.5, 0.0)
            colors := array.from(color_black, color_purple, color_red, color_red, color_black)
            labels := array.from("1.0 (100)", "0.786", "0.618", "0.5 (50)", "0.0 (0)")
            styles := array.from("solid", "dotted", "dotted", "solid", "solid")
            
        else if mode == "Quadrants"
            ratios := array.from(1.0, 0.75, 0.5, 0.25, 0.0)
            colors := array.from(color_black, color_black, color_red, color_black, color_black)
            labels := array.from("1 (100)", "0.75 (Q3)", "0.5 (EQ)", "0.25 (Q1)", "0 (0)")
            styles := array.from("solid", "solid", "solid", "solid", "solid")
            
        else if mode == "8ths"
            for i = 0 to 8
                float r = 1.0 - (i * 0.125)
                array.push(ratios, r)
                color c = (r == 0.5) ? color_red : (math.abs(r - math.round(r * 4) / 4) > 0.01 ? color_blue : color_black)
                array.push(colors, c)
                array.push(labels, str.tostring(r))
                array.push(styles, "solid")
                
        else if mode == "16ths"
            for i = 0 to 16
                float r = 1.0 - (i * 0.0625)
                array.push(ratios, r)
                color c = (r == 0.5 or r == 0.25) ? color_red : (math.abs(r - math.round(r * 8) / 8) > 0.01 ? color_blue : color_black)
                array.push(colors, c)
                string lbl = str.tostring(r)
                if r == 0.5
                    lbl += " (EQ)"
                if r == 0.75
                    lbl += " (Q3)"
                if r == 0.25
                    lbl += " (Q1)"
                array.push(labels, lbl)
                array.push(styles, "solid")

        // Draw levels
        for i = 0 to 16
            if i < array.size(ratios)
                float r = array.get(ratios, i)
                float r_final = reverse ? 1.0 - r : r
                float p = bottom + r_final * rng
                
                string tag = (reverse ? str.tostring(1.0 - r) : str.tostring(r))
                if not (mode == "8ths" or mode == "16ths")
                    tag := array.get(labels, i)

                array.get(this.levels, i).update_level(true, x1, x2, p, array.get(colors, i), array.get(styles, i), (tf_label != "" ? tf_label + " " : "") + tag, i_show_labels, x_type)
            else
                array.get(this.levels, i).update_level(false, 0, 0, 0, na, "", "", false, x_type)
        
        // Dynamic Boxes
        bool is_ote = mode == "OTE"
        bool is_any_range = true
        
        float p_100 = bottom + (reverse ? 0.0 : 1.0) * rng
        float p_786 = bottom + (reverse ? 1.0 - 0.786 : 0.786) * rng
        float p_618 = bottom + (reverse ? 1.0 - 0.618 : 0.618) * rng
        float p_50  = bottom + 0.500 * rng
        float p_0   = bottom + (reverse ? 1.0 : 0.0) * rng
        
        this.box_premium   := update_box(this.box_premium,   is_any_range,  x1, p_100, x2, is_ote ? p_786 : p_50, reverse ? c_disc : c_prem, x_type)
        this.box_ote_upper := update_box(this.box_ote_upper, is_ote,  x1, p_786, x2, p_618, c_ote, x_type)
        this.box_ote_lower := update_box(this.box_ote_lower, is_ote,  x1, p_618, x2, p_50,  c_ote_l, x_type)
        this.box_discount  := update_box(this.box_discount,  is_any_range,  x1, p_50,  x2, p_0,   reverse ? c_prem : c_disc, x_type)

    else
        for i = 0 to 16
            array.get(this.levels, i).update_level(false, 0, 0, 0, na, "", "", false, x_type)
        box.delete(this.box_premium),   this.box_premium := na
        box.delete(this.box_ote_upper), this.box_ote_upper := na
        box.delete(this.box_ote_lower), this.box_ote_lower := na
        box.delete(this.box_discount),  this.box_discount := na

f_new_visuals() =>
    UDT_Level[] lvls = array.new<UDT_Level>(17)
    for i = 0 to 16
        array.set(lvls, i, UDT_Level.new())
    UDT_RangeVisuals.new(lvls)

f_get_tf_label(string input_tf, string sess_tf) =>
    if sess_tf != ""
        sess_tf
    else
        string tf = input_tf == "" ? timeframe.period : input_tf
        string out = ""
        float mins_f = str.tonumber(tf)
        int mins = int(mins_f)
        
        if not na(mins)
            out := str.tostring(mins) + "m"
            if mins % 60 == 0
                out := str.tostring(mins / 60) + "H"
        else
            out := tf
        
        out

f_target_tf(string fixed_tf, int mult) =>
    if mult > 1
        string unit = ""
        float num = na
        int len = str.length(fixed_tf)
        string last_char = str.substring(fixed_tf, len - 1)
        
        if last_char == "D" or last_char == "W" or last_char == "M" or last_char == "S"
            unit := last_char
            string prefix = str.substring(fixed_tf, 0, len - 1)
            num := prefix == "" ? 1.0 : str.tonumber(prefix)
        else
            unit := ""
            num := str.tonumber(fixed_tf)
            
        str.tostring(int(num * mult)) + unit
    else
        fixed_tf


f_combine(float a, float b, bool high_val) =>
    na(a) ? b : na(b) ? a : (high_val ? math.max(a, b) : math.min(a, b))

f_fetch_range(string tf) =>
    string target_tf = tf == "" ? timeframe.period : tf
    [h0, l0, t0, tc0, h1, l1, t1, tc1] = request.security(syminfo.tickerid, target_tf, [high, low, time, time_close, high[1], low[1], time[1], time_close[1]], lookahead = barmerge.lookahead_on)
    [math.max(h0, h1), math.min(l0, l1), t1, tc0]

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #










// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

var UDT_Store store = UDT_Store.new(f_new_visuals(), f_new_visuals(), f_new_visuals())

// Separate State Tracking for each Session Group
var UDT_SessionState sess_state_1 = UDT_SessionState.new()
var UDT_SessionState sess_state_2 = UDT_SessionState.new()
var UDT_SessionState sess_state_3 = UDT_SessionState.new()

sess_state_1.update_session(i_sess_1)
sess_state_2.update_session(i_sess_2)
sess_state_3.update_session(i_sess_3)

// Mode Change Trackers
var string last_xtype_1 = ""
var string last_xtype_2 = ""
var string last_xtype_3 = ""

if barstate.islast
    bool is_proj_1 = i_ui_mode_1 == "Projected"
    bool is_proj_2 = i_ui_mode_2 == "Projected"
    bool is_proj_3 = i_ui_mode_3 == "Projected"

    string xtype_1 = is_proj_1 ? xloc.bar_index : xloc.bar_time
    string xtype_2 = is_proj_2 ? xloc.bar_index : xloc.bar_time
    string xtype_3 = is_proj_3 ? xloc.bar_index : xloc.bar_time
    
    // Force cleanup on xtype mismatch
    if xtype_1 != last_xtype_1
        store.r1.update_range_visuals(false, "", false, 0, 0, 0, 0, "", na, na, na, na, xtype_1)
        last_xtype_1 := xtype_1

    if xtype_2 != last_xtype_2
        store.r2.update_range_visuals(false, "", false, 0, 0, 0, 0, "", na, na, na, na, xtype_2)
        last_xtype_2 := xtype_2

    if xtype_3 != last_xtype_3
        store.r3.update_range_visuals(false, "", false, 0, 0, 0, 0, "", na, na, na, na, xtype_3)
        last_xtype_3 := xtype_3
    
    // Initial start offset
    int offset_accum = i_proj_offset
    
    // Range 1
    float t1 = i_sess_1 != "" ? f_combine(sess_state_1.last_h, sess_state_1.h, true) : na
    float b1 = i_sess_1 != "" ? f_combine(sess_state_1.last_l, sess_state_1.l, false) : na
    int s1   = i_sess_1 != "" ? int(nz(sess_state_1.last_t1, sess_state_1.t1)) : na
    int e1   = i_sess_1 != "" ? int(nz(sess_state_1.t2, sess_state_1.last_t2)) : na
    
    if i_sess_1 == ""
        string target_tf_1 = f_target_tf(i_tf_1, i_mult_1)
        [rt1, rb1, rs1, re1] = f_fetch_range(target_tf_1)
        t1 := rt1, b1 := rb1, s1 := rs1, e1 := re1
        
    if not na(t1)    
        int x1_1 = is_proj_1 ? bar_index + offset_accum : s1
        int x2_1 = is_proj_1 ? bar_index + offset_accum + i_width : e1
        store.r1.update_range_visuals(i_show_1, i_mode_1, i_reverse_1, x1_1, x2_1, t1, b1, f_get_tf_label(f_target_tf(i_tf_1, i_mult_1), i_sess_1), i_c_prem_1, i_c_ote_1, i_c_ote_l_1, i_c_disc_1, xtype_1)

    else
        store.r1.update_range_visuals(false, "", false, 0, 0, 0, 0, "", na, na, na, na, xtype_1)
    
    if i_show_1 and is_proj_1
        offset_accum += i_width + i_gap

    // Range 2
    float t2 = i_sess_2 != "" ? f_combine(sess_state_2.last_h, sess_state_2.h, true) : na
    float b2 = i_sess_2 != "" ? f_combine(sess_state_2.last_l, sess_state_2.l, false) : na
    int s2   = i_sess_2 != "" ? int(nz(sess_state_2.last_t1, sess_state_2.t1)) : na
    int e2   = i_sess_2 != "" ? int(nz(sess_state_2.t2, sess_state_2.last_t2)) : na
    
    if i_sess_2 == ""
        string target_tf_2 = f_target_tf(i_tf_2, i_mult_2)
        [rt2, rb2, rs2, re2] = f_fetch_range(target_tf_2)
        t2 := rt2, b2 := rb2, s2 := rs2, e2 := re2
        
    if not na(t2)
        int x1_2 = is_proj_2 ? bar_index + offset_accum : s2
        int x2_2 = is_proj_2 ? bar_index + offset_accum + i_width : e2
        store.r2.update_range_visuals(i_show_2, i_mode_2, i_reverse_2, x1_2, x2_2, t2, b2, f_get_tf_label(f_target_tf(i_tf_2, i_mult_2), i_sess_2), i_c_prem_2, i_c_ote_2, i_c_ote_l_2, i_c_disc_2, xtype_2)

    else
        store.r2.update_range_visuals(false, "", false, 0, 0, 0, 0, "", na, na, na, na, xtype_2)
    
    if i_show_2 and is_proj_2
        offset_accum += i_width + i_gap

    // Range 3
    float t3 = i_sess_3 != "" ? f_combine(sess_state_3.last_h, sess_state_3.h, true) : na
    float b3 = i_sess_3 != "" ? f_combine(sess_state_3.last_l, sess_state_3.l, false) : na
    int s3   = i_sess_3 != "" ? int(nz(sess_state_3.last_t1, sess_state_3.t1)) : na
    int e3   = i_sess_3 != "" ? int(nz(sess_state_3.t2, sess_state_3.last_t2)) : na
    
    if i_sess_3 == ""
        string target_tf_3 = f_target_tf(i_tf_3, i_mult_3)
        [rt3, rb3, rs3, re3] = f_fetch_range(target_tf_3)
        t3 := rt3, b3 := rb3, s3 := rs3, e3 := re3
        
    if not na(t3)
        int x1_3 = is_proj_3 ? bar_index + offset_accum : s3
        int x2_3 = is_proj_3 ? bar_index + offset_accum + i_width : e3
        store.r3.update_range_visuals(i_show_3, i_mode_3, i_reverse_3, x1_3, x2_3, t3, b3, f_get_tf_label(f_target_tf(i_tf_3, i_mult_3), i_sess_3), i_c_prem_3, i_c_ote_3, i_c_ote_l_3, i_c_disc_3, xtype_3)

    else
        store.r3.update_range_visuals(false, "", false, 0, 0, 0, 0, "", na, na, na, na, xtype_3)

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
    table.cell(brand, 0, 0,  "© CandelaCharts", text_color = color_gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
