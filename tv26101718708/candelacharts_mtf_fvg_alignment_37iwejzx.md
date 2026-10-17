# CandelaCharts - MTF FVG Alignment

- url: https://www.tradingview.com/script/37IwejZx-CandelaCharts-MTF-FVG-Alignment/
- type: indicator
- pine_id: PUB;3e61887c064c4d6d814a21cc0240cafd
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - MTF FVG Alignment[/b] indicator detects Fair Value Gaps (FVGs) across up to four customizable timeframes and visualises them directly on the chart. A Fair Value Gap is a three-candle pattern where price moved so rapidly that an unfilled area remains between the high of the first candle and the low of the third candle, representing a price imbalance the market often returns to fill.

The core strength of this indicator is [b]Confluence[/b]. An alignment signal is generated only when every enabled timeframe shows FVGs in the same direction (all Bullish or all Bearish), giving traders a powerful multi-timeframe confirmation before taking a position.

📦 [b]Features[/b]

[list]
[*] [b]Four-Timeframe Analysis[/b]: Track up to four independent timeframes simultaneously with per-TF toggle and FVG count.
[*] [b]Confluence Alignment[/b]: Automatic detection of Bullish or Bearish alignment across all enabled timeframes.
[*] [b]Bias Filter[/b]: Filter displayed FVGs to show only Bullish, only Bearish, or both (Neutral).
[*] [b]FVG Mitigation[/b]: FVGs are automatically invalidated and removed from the chart once they are fully filled by price action.
[*] [b]Hide Overlapped[/b]: Clean up chart clutter by automatically hiding lower-timeframe or older FVGs that overlap with others.
[*] [b]Fibonacci Levels[/b]: Optional Fibonacci retracement levels (0.236, 0.382, 0.5, 0.618, 0.65, 0.705, 0.786) drawn inside each FVG with a highlighted Golden Pocket zone (0.705–0.786).
[*] [b]FVG Visuals[/b]: Semi-transparent boxes showing active FVGs for each timeframe, with configurable borders and midlines.
[*] [b]Status Dashboard[/b]: A clean table showing the current directional status (Bullish / Bearish / None) for each enabled timeframe.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Timeframes[/b]
[*] TF 1–4: Each timeframe row has a toggle (show/hide), a timeframe selector, and an FVG count (1–10) controlling how many recent FVGs are displayed for that timeframe. Defaults are 1D, 4H, 1H, and 15m.
[/list]

[list]
[*] [b]Settings[/b]
[*] Bias Filter: Filter displayed FVGs by direction — Neutral (show all), Bullish (show only bullish FVGs), or Bearish (show only bearish FVGs).
[*] Bull / Bear Colors: Customise the colours used for bullish and bearish FVG zones.
[*] Border: Toggle the FVG box border and configure its style (Solid, Dotted, Dashed) and width (1–5).
[*] Midline: Toggle the Consequent Encroachment midline inside each FVG and configure its style and width. When enabled, the timeframe label moves outside the box.
[*] Fibonacci: Toggle the drawing of Fibonacci retracement levels inside each FVG, including the highlighted Golden Pocket (0.705–0.786).
[*] Hide Overlapped: Toggle whether to hide overlapping FVGs across different timeframes to keep the chart clean (prioritising higher timeframes).
[/list]

[list]
[*] [b]Dashboard[/b]
[*] Show: Toggle the multi-timeframe status dashboard.
[*] Position: Choose the dashboard corner — Top Right, Top Left, Bottom Right, or Bottom Left.
[/list]

⚡️ [b]Showcase[/b]

[i]Multi-Timeframe FVG Boxes[/i]
https://www.tradingview.com/x/5tts3nfd/

[i]Fibonacci Levels & Golden Pocket[/i]
https://www.tradingview.com/x/ebQd6TBy/

[i]Status Dashboard[/i]
https://www.tradingview.com/x/HirmQe13/

🔎 [b]Usage[/b]

[list]
[*] [b]Trend Identification[/b]: Glance at the dashboard to see the current bias of each higher timeframe at a glance.
[*] [b]Confluence[/b]: When all enabled timeframes align in the same direction, it provides strong multi-timeframe confluence for a directional trade.
[*] [b]Fibonacci Entries[/b]: Use the Fibonacci levels inside each FVG — particularly the Golden Pocket (0.705–0.786) — for precise entries when price retraces into the gap.
[*] [b]Bias Filtering[/b]: Set the Bias Filter to Bullish or Bearish to remove counter-trend FVGs and keep the chart focused on your directional thesis.
[*] [b]Execution[/b]: Use the alignment as confirmation for your existing strategy. Bullish alignment suggests upward momentum; Bearish alignment suggests downward momentum.
[/list]

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - MTF FVG Alignment", shorttitle = "CandelaCharts - MTF FVG Alignment", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)












// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_white                        = color.white
colors_black                        = color.black
colors_gray                         = color.gray
colors_silver                       = color.silver
colors_transparent                  = color.new(color.white, 100)

// Colors moved to Visuals group in Inputs

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                        = input.string("Monospace", "Text             ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                  = input.bool(false, "Hide Brand", group = "General")

tf1_show                            = input.bool(true, "TF 1     ", group = "Timeframes", inline = "1.0")
tf1_val                             = input.timeframe("1D", "", group = "Timeframes", inline = "1.0")
tf1_count                           = input.int(1, "", minval = 1, maxval = 10, group = "Timeframes", inline = "1.0")
tf2_show                            = input.bool(true, "TF 2     ", group = "Timeframes", inline = "2.0")
tf2_val                             = input.timeframe("240", "", group = "Timeframes", inline = "2.0")
tf2_count                           = input.int(1, "", minval = 1, maxval = 10, group = "Timeframes", inline = "2.0")
tf3_show                            = input.bool(true, "TF 3     ", group = "Timeframes", inline = "3.0")
tf3_val                             = input.timeframe("60", "", group = "Timeframes", inline = "3.0")
tf3_count                           = input.int(1, "", minval = 1, maxval = 10, group = "Timeframes", inline = "3.0")
tf4_show                            = input.bool(true, "TF 4     ", group = "Timeframes", inline = "4.0")
tf4_val                             = input.timeframe("15", "", group = "Timeframes", inline = "4.0")
tf4_count                           = input.int(1, "", minval = 1, maxval = 10, group = "Timeframes", inline = "4.0")

bias_filter                         = input.string("Neutral", "Bias Filter     ", inline = "1.0", options = ["Neutral", "Bullish", "Bearish"], group = "Settings")
colors_bull                         = input.color(#089981, "", inline = "1.0", group = "Settings")
colors_bear                         = input.color(#f23645, "", inline = "1.0", group = "Settings")
show_border                         = input.bool(true, "Border  ", group = "Settings", inline = "2.0")
border_style                        = input.string("Solid", "", options = ["Solid", "Dotted", "Dashed"], group = "Settings", inline = "2.0")
border_width                        = input.int(1, "", minval = 1, maxval = 5, group = "Settings", inline = "2.0")
show_midline                        = input.bool(false, "Midline ", group = "Settings", inline = "3.0")
midline_style                       = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "Settings", inline = "3.0")
midline_width                       = input.int(1, "", minval = 1, maxval = 5, group = "Settings", inline = "3.0")
show_fib                            = input.bool(true, "Show Fibonacci", group = "Settings")
hide_overlapped                     = input.bool(false, "Hide Overlapped", group = "Settings")

show_dashboard                      = input.bool(true, "Show    ", inline = "1.0", group = "Dashboard")
dashboard_pos                       = input.string("Top Right", "", inline = "1.0", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Dashboard")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type UDT_FVG
    float top
    float bottom
    int   direction // 1 for bull, -1 for bear, 0 for none
    int   time

type UDT_Store
    box[]   boxes
    line[]  lines
    label[] labels
    table   dash

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

colors_bull_glass = color.new(colors_bull, 85)
colors_bear_glass = color.new(colors_bear, 85)

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

method table_position(string position) =>
    out = switch position
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
    out

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace
    out

f_get_line_style(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

f_format_tf(string tf) =>
    string res = tf
    if tf == ""
        res := "Chart"
    else if tf == "1D" or tf == "D"
        res := "1D"
    else if tf == "1W" or tf == "W"
        res := "1W"
    else if tf == "1M" or tf == "M"
        res := "1M"
    else
        float minutes = str.tonumber(tf)
        if not na(minutes)
            if minutes >= 1440
                res := str.tostring(math.floor(minutes / 1440)) + "D"
            else if minutes >= 60
                res := str.tostring(math.floor(minutes / 60)) + "H"
            else
                res := str.tostring(minutes) + "m"
    res

// FVG Detection Logic for Multiple Gaps
f_detect_fvgs(int max_count) =>
    var fvgs = array.new<UDT_FVG>()
    var int last_fvg_time = 0
    
    // Invalidation
    if fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            UDT_FVG fvg = fvgs.get(i)
            bool is_invalid = false
            if fvg.direction == 1 and low <= fvg.bottom
                is_invalid := true
            else if fvg.direction == -1 and high >= fvg.top
                is_invalid := true
            
            if is_invalid
                fvgs.remove(i)

    // Detection
    bool is_bull = low[0] > high[2]
    bool is_bear = high[0] < low[2]
    
    if (is_bull or is_bear) and time[2] != last_fvg_time
        last_fvg_time := time[2]
        
        float new_top = is_bull ? low[0] : low[2]
        float new_bottom = is_bull ? high[2] : high[0]
        int new_dir = is_bull ? 1 : -1
        
        if hide_overlapped and fvgs.size() > 0
            for i = fvgs.size() - 1 to 0
                UDT_FVG fvg = fvgs.get(i)
                bool overlap = math.max(new_bottom, fvg.bottom) < math.min(new_top, fvg.top)
                if overlap
                    fvgs.remove(i)

        fvgs.unshift(UDT_FVG.new(new_top, new_bottom, new_dir, time[2]))
        
        
        // Trim to max_count
        while fvgs.size() > max_count
            fvgs.pop()
            
    fvgs

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store store = UDT_Store.new(array.new<box>(), array.new<line>(), array.new<label>(), na)

method clean(UDT_Store self) =>
    if self.boxes.size() > 0
        for b in self.boxes
            b.delete()
        self.boxes.clear()
    if self.lines.size() > 0
        for l in self.lines
            l.delete()
        self.lines.clear()
    if self.labels.size() > 0
        for l in self.labels
            l.delete()
        self.labels.clear()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

// Request FVG data from each timeframe
// We use f_detect_fvg_confirmed() to avoid repainting and get the last confirmed HTF bar's FVG
// Request FVG data from each timeframe
tf1_fvgs = request.security(syminfo.tickerid, tf1_val, f_detect_fvgs(tf1_count))
tf2_fvgs = request.security(syminfo.tickerid, tf2_val, f_detect_fvgs(tf2_count))
tf3_fvgs = request.security(syminfo.tickerid, tf3_val, f_detect_fvgs(tf3_count))
tf4_fvgs = request.security(syminfo.tickerid, tf4_val, f_detect_fvgs(tf4_count))

// Extract latest FVG for alignment/dashboard
tf1_latest = not na(tf1_fvgs) and tf1_fvgs.size() > 0 ? tf1_fvgs.get(0) : UDT_FVG.new(na, na, 0, 0)
tf2_latest = not na(tf2_fvgs) and tf2_fvgs.size() > 0 ? tf2_fvgs.get(0) : UDT_FVG.new(na, na, 0, 0)
tf3_latest = not na(tf3_fvgs) and tf3_fvgs.size() > 0 ? tf3_fvgs.get(0) : UDT_FVG.new(na, na, 0, 0)
tf4_latest = not na(tf4_fvgs) and tf4_fvgs.size() > 0 ? tf4_fvgs.get(0) : UDT_FVG.new(na, na, 0, 0)

// Alignment Logic
is_aligned_bull = (not tf1_show or tf1_latest.direction == 1) and (not tf2_show or tf2_latest.direction == 1) and (not tf3_show or tf3_latest.direction == 1) and (not tf4_show or tf4_latest.direction == 1) and (tf1_show or tf2_show or tf3_show or tf4_show)
is_aligned_bear = (not tf1_show or tf1_latest.direction == -1) and (not tf2_show or tf2_latest.direction == -1) and (not tf3_show or tf3_latest.direction == -1) and (not tf4_show or tf4_latest.direction == -1) and (tf1_show or tf2_show or tf3_show or tf4_show)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Visuals   |
// # ========================================================================= #

//#region

// Clean up drawings
store.clean()

f_draw_fib(float top, float bottom, int dir, int t, color base_c) =>
    if show_fib
        float diff = math.abs(top - bottom)
        float l_236 = dir == 1 ? top - diff * 0.236 : bottom + diff * 0.236
        float l_382 = dir == 1 ? top - diff * 0.382 : bottom + diff * 0.382
        float l_500 = dir == 1 ? top - diff * 0.500 : bottom + diff * 0.500
        float l_618 = dir == 1 ? top - diff * 0.618 : bottom + diff * 0.618
        float l_650 = dir == 1 ? top - diff * 0.650 : bottom + diff * 0.650
        float l_705 = dir == 1 ? top - diff * 0.705 : bottom + diff * 0.705
        float l_786 = dir == 1 ? top - diff * 0.786 : bottom + diff * 0.786
        
        color line_c = color.new(base_c, 50)
        color gp_bg  = color.new(base_c, 80)
        
        store.lines.push(line.new(t, l_236, last_bar_time, l_236, xloc=xloc.bar_time, color=line_c, style=line.style_dotted))
        store.labels.push(label.new(last_bar_time, l_236, text="0.236", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.lines.push(line.new(t, l_382, last_bar_time, l_382, xloc=xloc.bar_time, color=line_c, style=line.style_dotted))
        store.labels.push(label.new(last_bar_time, l_382, text="0.382", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.lines.push(line.new(t, l_500, last_bar_time, l_500, xloc=xloc.bar_time, color=line_c, style=line.style_dashed))
        store.labels.push(label.new(last_bar_time, l_500, text="0.5", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.lines.push(line.new(t, l_618, last_bar_time, l_618, xloc=xloc.bar_time, color=line_c, style=line.style_dotted))
        store.labels.push(label.new(last_bar_time, l_618, text="0.618", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.lines.push(line.new(t, l_650, last_bar_time, l_650, xloc=xloc.bar_time, color=line_c, style=line.style_dotted))
        store.labels.push(label.new(last_bar_time, l_650, text="0.65", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.lines.push(line.new(t, l_705, last_bar_time, l_705, xloc=xloc.bar_time, color=line_c, style=line.style_solid))
        store.labels.push(label.new(last_bar_time, l_705, text="0.705", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.lines.push(line.new(t, l_786, last_bar_time, l_786, xloc=xloc.bar_time, color=line_c, style=line.style_solid))
        store.labels.push(label.new(last_bar_time, l_786, text="0.786", xloc=xloc.bar_time, yloc=yloc.price, color=colors_transparent, textcolor=line_c, style=label.style_label_left, size=general_text.text_size()))
        
        store.boxes.push(box.new(t, math.max(l_705, l_786), last_bar_time, math.min(l_705, l_786), xloc=xloc.bar_time, bgcolor=gp_bg, border_color=na))

// Helper to draw FVG box
f_draw_fvg(float top, float bottom, int dir, int t, color c, string tf) =>
    if not na(top) and t > 0
        if bias_filter == "Neutral" or (bias_filter == "Bullish" and dir == 1) or (bias_filter == "Bearish" and dir == -1)
            // Determine colors (inherited with 0 transparency)
            base_c    = dir == 1 ? colors_bull : colors_bear
            border_c  = show_border ? base_c : na
            midline_c = dir == 1 ? color.new(colors_bull, 0) : color.new(colors_bear, 0)
            
            // Box (Hide internal text if midline is enabled to move it outside)
            box_text = show_midline ? "" : tf
            box b = box.new(t, top, last_bar_time, bottom, xloc = xloc.bar_time, bgcolor = c, border_color = border_c, border_width = border_width, border_style = f_get_line_style(border_style), text = box_text, text_size = size.auto, text_color = base_c, text_halign = text.align_center, text_valign = text.align_center, text_formatting = text.format_bold)
            store.boxes.push(b)
            
            // Midline & External Label
            float mid = (top + bottom) / 2
            if show_midline
                line l = line.new(t, mid, last_bar_time, mid, xloc = xloc.bar_time, color = midline_c, width = midline_width, style = f_get_line_style(midline_style))
                store.lines.push(l)
                
                // Label placed outside to the right
                label lbl = label.new(last_bar_time, mid, text = " " + tf, xloc = xloc.bar_time, yloc = yloc.price, color = colors_transparent, textcolor = base_c, style = label.style_label_left, size = general_text.text_size())
                store.labels.push(lbl)
            
            // Draw Fib
            f_draw_fib(top, bottom, dir, t, base_c)

method is_overlapping(array<UDT_FVG> arr, UDT_FVG f, bool hide) =>
    bool overlap = false
    if hide and arr.size() > 0
        for a in arr
            if math.max(f.bottom, a.bottom) < math.min(f.top, a.top)
                overlap := true
                break
    overlap

if barstate.islast
    var drawn_fvgs = array.new<UDT_FVG>()
    drawn_fvgs.clear()
    
    if tf1_show and not na(tf1_fvgs) and tf1_fvgs.size() > 0
        for f in tf1_fvgs
            if not drawn_fvgs.is_overlapping(f, hide_overlapped)
                drawn_fvgs.push(f)
                f_draw_fvg(f.top, f.bottom, f.direction, f.time, f.direction == 1 ? colors_bull_glass : colors_bear_glass, f_format_tf(tf1_val))
    if tf2_show and not na(tf2_fvgs) and tf2_fvgs.size() > 0
        for f in tf2_fvgs
            if not drawn_fvgs.is_overlapping(f, hide_overlapped)
                drawn_fvgs.push(f)
                f_draw_fvg(f.top, f.bottom, f.direction, f.time, f.direction == 1 ? colors_bull_glass : colors_bear_glass, f_format_tf(tf2_val))
    if tf3_show and not na(tf3_fvgs) and tf3_fvgs.size() > 0
        for f in tf3_fvgs
            if not drawn_fvgs.is_overlapping(f, hide_overlapped)
                drawn_fvgs.push(f)
                f_draw_fvg(f.top, f.bottom, f.direction, f.time, f.direction == 1 ? colors_bull_glass : colors_bear_glass, f_format_tf(tf3_val))
    if tf4_show and not na(tf4_fvgs) and tf4_fvgs.size() > 0
        for f in tf4_fvgs
            if not drawn_fvgs.is_overlapping(f, hide_overlapped)
                drawn_fvgs.push(f)
                f_draw_fvg(f.top, f.bottom, f.direction, f.time, f.direction == 1 ? colors_bull_glass : colors_bear_glass, f_format_tf(tf4_val))

// Dashboard
if show_dashboard and barstate.islast
    int rows = (tf1_show ? 1 : 0) + (tf2_show ? 1 : 0) + (tf3_show ? 1 : 0) + (tf4_show ? 1 : 0) + 1
    
    if rows > 1
        // Modern Light Palette
        color dash_bg      = color.new(colors_white, 10)
        color dash_border  = color.new(colors_gray, 80)
        color dash_header  = color.new(colors_silver, 50)
        color dash_text    = colors_black
        
        table dash = table.new(dashboard_pos.table_position(), 2, rows, bgcolor = dash_bg, frame_color = dash_border, frame_width = 1, border_color = dash_border, border_width = 1)
        
        // Header
        table.cell(dash, 0, 0, "TF", width = 3, height = 0, text_color = dash_text, text_size = general_text.text_size(), text_font_family = general_font.font_style(), bgcolor = dash_header, text_halign = text.align_center)
        table.cell(dash, 1, 0, "Status", width = 5, height = 0, text_color = dash_text, text_size = general_text.text_size(), text_font_family = general_font.font_style(), bgcolor = dash_header, text_halign = text.align_center)
        
        int current_row = 1
        
        // TF1
        if tf1_show
            table.cell(dash, 0, current_row, f_format_tf(tf1_val), height = 0, text_color = dash_text, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            table.cell(dash, 1, current_row, tf1_latest.direction == 1 ? "BULLISH" : tf1_latest.direction == -1 ? "BEARISH" : "NONE", height = 2.0, text_color = tf1_latest.direction == 1 ? #00897b : tf1_latest.direction == -1 ? #d81b60 : colors_gray, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            current_row += 1
        
        // TF2
        if tf2_show
            table.cell(dash, 0, current_row, f_format_tf(tf2_val), height = 0, text_color = dash_text, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            table.cell(dash, 1, current_row, tf2_latest.direction == 1 ? "BULLISH" : tf2_latest.direction == -1 ? "BEARISH" : "NONE", height = 2.0, text_color = tf2_latest.direction == 1 ? #00897b : tf2_latest.direction == -1 ? #d81b60 : colors_gray, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            current_row += 1
        
        // TF3
        if tf3_show
            table.cell(dash, 0, current_row, f_format_tf(tf3_val), height = 0, text_color = dash_text, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            table.cell(dash, 1, current_row, tf3_latest.direction == 1 ? "BULLISH" : tf3_latest.direction == -1 ? "BEARISH" : "NONE", height = 2.0, text_color = tf3_latest.direction == 1 ? #00897b : tf3_latest.direction == -1 ? #d81b60 : colors_gray, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            current_row += 1
        
        // TF4
        if tf4_show
            table.cell(dash, 0, current_row, f_format_tf(tf4_val), height = 0, text_color = dash_text, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            table.cell(dash, 1, current_row, tf4_latest.direction == 1 ? "BULLISH" : tf4_latest.direction == -1 ? "BEARISH" : "NONE", height = 2.0, text_color = tf4_latest.direction == 1 ? #00897b : tf4_latest.direction == -1 ? #d81b60 : colors_gray, text_size = general_text.text_size(), text_font_family = general_font.font_style(), text_halign = text.align_center)
            current_row += 1

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
    table.cell(brand, 0, 0,  "© CandelaCharts", text_color = colors_gray, text_halign = text.align_center, text_size = general_text.text_size(), text_font_family = general_font.font_style())

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
