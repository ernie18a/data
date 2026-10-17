# CandelaCharts - Killzone HTF Candles

- url: https://www.tradingview.com/script/jecnXr4z-CandelaCharts-Killzone-HTF-Candles/
- type: indicator
- pine_id: PUB;736d2b48c7e6487b9717d4d1e3e4aef0
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]Killzone HTF Candles[/b] indicator is a professional visual tool designed for ICT and SMC traders who prioritize session-based price action. It bridges the gap between Lower Timeframe (LTF) execution and Higher Timeframe (HTF) context by projecting session-specific data (Asia, London, New York) directly onto your chart as discrete candles.

This tool allows you to monitor the "Daily Narrative" by seeing how session ranges interact without ever leaving your execution timeframe, helping you identify liquidity sweeps and trend transitions at a glance.

📦 [b]Features[/b]

[list]
[*] [b]Multi-Session Tracking[/b]: Pre-configured with 8 primary Killzones: Asia (AS), London Open (LO), NY AM, NY Lunch (LA), NY PM, and 3 additional custom sessions.
[*] [b]Dual Projection Logic[/b]:
[list]
[*] [b]Mapped to Chart[/b]: Overlays HTF boxes and wicks directly on the price action for historical study and zone identification.
[*] [b]Ghost Display[/b]: Projects the most recent sessions as a "Rolling Dashboard" on the right side of the chart, keeping your current price action clear.
[/list]
[*] [b]Dynamic Chronology[/b]: Ghost candles automatically rotate, ensuring the most recent session is always positioned on the far right.
[*] [b]Premium Aesthetics[/b]: Built with glassmorphism design principles, featuring customizable body opacity, line widths, and font styles.
[*] [b]Timezone Sync[/b]: Integrated timezone support (Default: America/New_York) ensures your sessions align perfectly with global markets.
[/list]

⚙️ [b]Settings[/b]

[b]HTF Candle Mechanics[/b]
[list]
[*] [b]Candle Size[/b]: Adjusts the width of the ghost candles.
[*] [b]Bull/Bear Colors[/b]: Set your preferred color scheme for bullish/bearish closes.
[*] [b]Ghost Offset/Spacing[/b]: Fine-tune the position and gap of the ghost candles on the right side.
[*] [b]Line Width[/b]: Controls the thickness of wicks and candle borders.
[*] [b]Opacity[/b]: Adjust the transparency of the candle body fills.
[/list]

[b]Session Configuration (I - VIII)[/b]
[list]
[*] [b]Show Session[/b]: Enable/Disable tracking for specific Killzones.
[*] [b]Display Name[/b]: Customize labels (e.g., "LO", "NY AM").
[*] [b]Session Time[/b]: Define precise time ranges for each session.
[*] [b]Map to Chart[/b]: Toggle the HTF candle overlay for specific sessions.
[/list]

⚡️ [b]Showcase[/b]

[i]The "Session Transfer" Logic[/i]

https://www.tradingview.com/x/AITXjRKx/

By using the [b]Ghost Candles[/b], you can quickly identify the relationship between different trading periods:
[list]
[*] [b]AS Range[/b]: Often sets the initial consolidation or liquidity pool.
[*] [b]LO Expansion[/b]: Typically creates the high or low of the day.
[*] [b]NY AM Reversal[/b]: Often trades back into the LO or AS ranges to fill gaps or sweep liquidity.
[/list]

[i]Highly customizable, build your own custom killzones[/i]

https://www.tradingview.com/x/4x2IzQbH/

🚨 [b]Alerts[/b]

This version is optimized for visual analysis. While it does not include internal logic alerts, it provides a comprehensive real-time dashboard for manual confluence and bias confirmation.

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator(title = "CandelaCharts - Killzone HTF Candles", shorttitle = "CandelaCharts - Killzone HTF Candles", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)











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
colors_fuchsia                      = color.fuchsia
colors_lime                         = color.lime
colors_olive                        = color.olive
colors_yellow                       = color.yellow
colors_navy                         = color.navy
colors_maroon                       = color.maroon
colors_transparent                  = #ffffff00

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

// # General ----------------------------------------------------------------- #

general_font                        = input.string("Monospace", "Text Style              ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Global text size for labels.")
general_brand_show                  = input.bool(false, "Hide Brand", group = "General")

// # HTF Candles ------------------------------------------------------------- #

hfc_candle_width                    = input.string("Small", "Candle Size           ", inline = "1.0", options = ["Tiny", "Small", "Medium", "Large", "Huge"], group = "HTF Candles", tooltip = "Width of the candles.")
hfc_bull_css                        = input.color(colors_green, "", inline = "1.0", group = "HTF Candles")
hfc_bear_css                        = input.color(colors_red, "", inline = "1.0", group = "HTF Candles", tooltip = "Background color opacity for the")
hfc_offset                          = input.int(20, "Ghost Offset      ", minval = 1, group = "HTF Candles", tooltip = "Distance from the current chart candle for ghost candles.")
hfc_space                           = input.int(5, "Ghost Spacing     ", minval = 1, maxval = 20, group = "HTF Candles", tooltip = "Space between the ghost candles.")
hfc_line_width                      = input.int(2, "Line Width      ", minval = 1, maxval = 4, group = "HTF Candles", tooltip = "Border and wick thickness.")
hfc_fill_opacity                    = input.int(20, "Opacity              ", minval = 0, maxval = 100, group = "HTF Candles")
kz_timezone                         = input.string("America/New_York", "Timezone          ", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], group = "HTF Candles", tooltip = "Timezone for killzone sessions. Default is New York.")

// # Session I --------------------------------------------------------------- #

kz_1_show                           = input.bool(true, "Show Session    ", group = "Session I")
kz_1_name                           = input.string("AS", "Display Name   ", group = "Session I")
kz_1_session                        = input.session("2000-0000", "Session Time  ", group = "Session I")
kz_1_map                            = input.bool(false, "Map to Chart   ", group = "Session I")

// # Session II -------------------------------------------------------------- #

kz_2_show                           = input.bool(true, "Show Session    ", group = "Session II")
kz_2_name                           = input.string("LO", "Display Name   ", group = "Session II")
kz_2_session                        = input.session("0200-0500", "Session Time  ", group = "Session II")
kz_2_map                            = input.bool(false, "Map to Chart   ", group = "Session II")

// # Session III ------------------------------------------------------------- #

kz_3_show                           = input.bool(true, "Show Session    ", group = "Session III")
kz_3_name                           = input.string("NYAM", "Display Name   ", group = "Session III")
kz_3_session                        = input.session("0930-1100", "Session Time  ", group = "Session III")
kz_3_map                            = input.bool(false, "Map to Chart   ", group = "Session III")

// # Session IV -------------------------------------------------------------- #

kz_4_show                           = input.bool(true, "Show Session    ", group = "Session IV")
kz_4_name                           = input.string("NYLA", "Display Name   ", group = "Session IV")
kz_4_session                        = input.session("1200-1300", "Session Time  ", group = "Session IV")
kz_4_map                            = input.bool(false, "Map to Chart   ", group = "Session IV")

// # Session V --------------------------------------------------------------- #

kz_5_show                           = input.bool(true, "Show Session    ", group = "Session V")
kz_5_name                           = input.string("NYPM", "Display Name   ", group = "Session V")
kz_5_session                        = input.session("1330-1600", "Session Time  ", group = "Session V")
kz_5_map                            = input.bool(false, "Map to Chart   ", group = "Session V")

// # Session VI -------------------------------------------------------------- #

kz_6_show                           = input.bool(false, "Show Session    ", group = "Session VI")
kz_6_name                           = input.string("S6", "Display Name   ", group = "Session VI")
kz_6_session                        = input.session("1600-1800", "Session Time  ", group = "Session VI")
kz_6_map                            = input.bool(false, "Map to Chart   ", group = "Session VI")

// # Session VII ------------------------------------------------------------- #

kz_7_show                           = input.bool(false, "Show Session    ", group = "Session VII")
kz_7_name                           = input.string("S7", "Display Name   ", group = "Session VII")
kz_7_session                        = input.session("1800-2000", "Session Time  ", group = "Session VII")
kz_7_map                            = input.bool(false, "Map to Chart   ", group = "Session VII")

// # Session VIII ------------------------------------------------------------ #

kz_8_show                           = input.bool(false, "Show Session    ", group = "Session VIII")
kz_8_name                           = input.string("S8", "Display Name   ", group = "Session VIII")
kz_8_session                        = input.session("2000-2200", "Session Time  ", group = "Session VIII")
kz_8_map                            = input.bool(false, "Map to Chart   ", group = "Session VIII")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   UDTs   |
// # ========================================================================= #

//#region

type UDT_Store
    line     [] bin_ln
    box      [] bin_box
    label    [] bin_lbl

type UDT_HTF_Candle
    string name
    float  o  = na
    float  h  = na
    float  l  = na
    float  c  = na
    bool   bull = false
    bool   active = false
    color  css = na
    int    shift = 0
    int    start_time = na
    int    end_time = na
    int    last_bar = na
    int    first_bar = na
    
    // Ghost render properties
    int    candle_left = na
    int    candle_right = na
    float  candle_top = na
    float  candle_bottom = na
    int    wick_x = na

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

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

method candle_size(string size) =>
    out = switch size
        'Tiny'   => 2
        'Small'  => 4
        'Medium' => 6
        'Large'  => 8
        'Huge'   => 10
    out

is_bullish_candle(float c, float o, float h, float l) =>
    c >= o

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store bin = UDT_Store.new(
                   bin_ln = array.new<line>()
                 , bin_box = array.new<box>()
                 , bin_lbl = array.new<label>()
                 )

method clean_bin(UDT_Store store) =>
    for obj in store.bin_ln
        obj.delete()
    for obj in store.bin_box
        obj.delete()
    for obj in store.bin_lbl
        obj.delete()

    store.bin_ln.clear()
    store.bin_box.clear()
    store.bin_lbl.clear()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

var htf_candle_width = candle_size(hfc_candle_width)

var kz_1 = UDT_HTF_Candle.new(name = kz_1_name)
var kz_2 = UDT_HTF_Candle.new(name = kz_2_name)
var kz_3 = UDT_HTF_Candle.new(name = kz_3_name)
var kz_4 = UDT_HTF_Candle.new(name = kz_4_name)
var kz_5 = UDT_HTF_Candle.new(name = kz_5_name)
var kz_6 = UDT_HTF_Candle.new(name = kz_6_name)
var kz_7 = UDT_HTF_Candle.new(name = kz_7_name)
var kz_8 = UDT_HTF_Candle.new(name = kz_8_name)

var kz_candles = array.from(kz_1, kz_2, kz_3, kz_4, kz_5, kz_6, kz_7, kz_8)
var kz_shows   = array.from(kz_1_show, kz_2_show, kz_3_show, kz_4_show, kz_5_show, kz_6_show, kz_7_show, kz_8_show)
var kz_maps    = array.from(kz_1_map, kz_2_map, kz_3_map, kz_4_map, kz_5_map, kz_6_map, kz_7_map, kz_8_map)
var kz_sessions = array.from(kz_1_session, kz_2_session, kz_3_session, kz_4_session, kz_5_session, kz_6_session, kz_7_session, kz_8_session)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Algorithm   |
// # ========================================================================= #

//#region

for i = 0 to kz_candles.size() - 1
    candle = kz_candles.get(i)
    show   = kz_shows.get(i)
    sess   = kz_sessions.get(i)
    
    // Sync names from inputs
    candle.name := switch i
        0 => kz_1_name
        1 => kz_2_name
        2 => kz_3_name
        3 => kz_4_name
        4 => kz_5_name
        5 => kz_6_name
        6 => kz_7_name
        7 => kz_8_name
        => candle.name
    
    in_sess = not na(time(timeframe.period, sess, kz_timezone))
        
    if show
        if in_sess and not candle.active
            // Session started
            candle.active := true
            candle.o := open
            candle.h := high
            candle.l := low
            candle.c := close
            candle.start_time := time
            candle.first_bar := bar_index
        else if in_sess
            // Session in progress
            if high > candle.h
                candle.h := high
            if low < candle.l
                candle.l := low
            candle.c := close
            
            // Set bias-based color
            candle.css := candle.c >= candle.o ? hfc_bull_css : hfc_bear_css
            
        else if not in_sess and candle.active
            // Session ended
            candle.active := false
            candle.end_time := time[1]
            candle.last_bar := bar_index[1]
            
        candle.bull := is_bullish_candle(candle.c, candle.o, candle.h, candle.l)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Visuals   |
// # ========================================================================= #

//#region

if barstate.islast
    bin.clean_bin()
    
    // Clear stale positions
    for i = 0 to kz_candles.size() - 1
        candle = kz_candles.get(i)
        candle.wick_x := na
        candle.candle_left := na
        candle.candle_right := na
        
    // Rolling Session Dashboard: Find the latest session to place on the far right
    int current_idx = 0
    int max_start_time = 0
    for i = 0 to kz_candles.size() - 1
        if not na(kz_candles.get(i).start_time) and kz_candles.get(i).start_time > max_start_time
            max_start_time := kz_candles.get(i).start_time
            current_idx := i
            
    // Build the display order by rotating the buffer so the latest session is at the end (rightmost)
    sorted_indices = array.new<int>()
    int total_sessions = kz_candles.size()
    for i = 0 to total_sessions - 1
        // Circular shift: (current_idx - (total_sessions - 1) + i) wrap around total_sessions
        idx = (current_idx - (total_sessions - 1) + i)
        while idx < 0
            idx += total_sessions
            
        if kz_shows.get(idx) and not na(kz_candles.get(idx).start_time)
            sorted_indices.push(idx)
    
    // Render Mapped Candles (LTF)
    for i = 0 to kz_candles.size() - 1
        candle = kz_candles.get(i)
        show   = kz_shows.get(i)
        map    = kz_maps.get(i) // Use per-session map toggle
        
        if show and map and not na(candle.o) and not na(candle.start_time)
            left_bar  = candle.first_bar
            right_bar = candle.active ? bar_index : candle.last_bar
            top       = math.max(candle.o, candle.c)
            bottom    = math.min(candle.o, candle.c)
            
            center_bar = math.round((left_bar + right_bar) / 2)
            
            // Draw Body
            bin.bin_box.push(box.new(left = left_bar, top = top, right = right_bar, bottom = bottom, border_color = candle.css, border_width = hfc_line_width, bgcolor = color.new(candle.css, 100 - hfc_fill_opacity)))
            
            // Draw Wicks (in center of session)
            bin.bin_ln.push(line.new(x1 = center_bar, y1 = candle.h, x2 = center_bar, y2 = top, color = candle.css, width = hfc_line_width))
            bin.bin_ln.push(line.new(x1 = center_bar, y1 = bottom, x2 = center_bar, y2 = candle.l, color = candle.css, width = hfc_line_width))
            
            // Centered Label (Using transparent box for perfect auto-size centering)
            bin.bin_box.push(box.new(left = left_bar, top = top, right = right_bar, bottom = bottom, border_color = color.new(color.white, 100), border_width = 0, bgcolor = color.new(color.white, 100), text = candle.name, text_color = candle.css, text_size = size.auto, text_halign = text.align_center, text_valign = text.align_center, text_font_family = font_style(general_font)))
            
            // Sweep Markers and Lines removed from LTF mapping per user request

    // Render Ghost Candles (Right Side)
    int active_count = sorted_indices.size()
            
    for i = 0 to sorted_indices.size() - 1
        idx    = sorted_indices.get(i)
        candle = kz_candles.get(idx)
        
        // Position calculation
        candle.shift := hfc_offset + (htf_candle_width + hfc_space) * i
        candle.candle_left := last_bar_index + candle.shift
        candle.candle_right := candle.candle_left + htf_candle_width
        candle.candle_top := math.max(candle.o, candle.c)
        candle.candle_bottom := math.min(candle.o, candle.c)
        candle.wick_x := candle.candle_left + htf_candle_width / 2
        
        // Draw Body
        bin.bin_box.push(box.new(left = candle.candle_left, top = candle.candle_top, right = candle.candle_right, bottom = candle.candle_bottom, border_color = candle.css, border_width = hfc_line_width, bgcolor = color.new(candle.css, 100 - hfc_fill_opacity)))
        
        // Draw Wicks
        bin.bin_ln.push(line.new(x1 = candle.wick_x, y1 = candle.h, x2 = candle.wick_x, y2 = candle.candle_top, color = candle.css, width = hfc_line_width))
        bin.bin_ln.push(line.new(x1 = candle.wick_x, y1 = candle.candle_bottom, x2 = candle.wick_x, y2 = candle.l, color = candle.css, width = hfc_line_width))
        
        // Draw Label
        label_text = candle.name + "\n" + (candle.bull ? "▲" : "▼")
        bin.bin_lbl.push(label.new(x = candle.wick_x, y = candle.h, text = label_text, color = colors_transparent, textcolor = candle.css, style = label.style_label_down, size = text_size(general_text), text_font_family = font_style(general_font)))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Brand Label   |
// # ========================================================================= #

//#region

if barstate.isfirst and not general_brand_show
    var table brand_table = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand_table, 0, 0, "© CandelaCharts", text_color = color.new(colors_gray, 30), text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
