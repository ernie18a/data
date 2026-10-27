# CandelaCharts - First P.FVG Killzone

- url: https://www.tradingview.com/script/se9LUk6A-CandelaCharts-First-P-FVG-Killzone/
- type: indicator
- pine_id: PUB;b0b63016ec51407cbc643b48a0caea50
- version: 2.0

## Description

📝 [b]Overview[/b]

The First P.FVG Killzone indicator automatically maps out user-defined trading sessions (Killzones) and highlights the First Presented Fair Value Gap (FVG) that forms within them. 

https://www.tradingview.com/x/o7O38Y6a/

Based on ICT concepts, killzones are specific time windows where high probability setups often occur. The first FVG to form in these sessions can act as a crucial reference point for the market's direction. This tool helps traders visualize the session range, the first institutional imbalance, and historical sweep probabilities.

📦 [b]Features[/b]
[list]
[*]Customizable Killzone Sessions (Asia, London, NY AM, NY Launch, NY PM, and Custom sessions)
[*]First Presented FVG Detection within each session
[*]Session Range Visualization (High, Low, and Mean lines with invalidation tracking)
[*]FVG Visibility Filters (All, Bullish, Bearish, None)
[*]Advanced FVG Styling (Midline, Borders, Labels, Extension Modes)
[*]Session Dividers and Timeframe Separators
[*]Historical Sweep Statistics (Probability of session High/Low sweeps)
[/list]

⚙️ [b]Settings[/b]
[list]
[*]General: Adjust global text size and visibility of the brand watermark.
[*]Imbalance Settings: Control the filtering, styling, and extension behavior (Fixed, Session End, Full) of the First P.FVG.
[*]History: Set the total number of historical sessions to display.
[*]Sessions (First to Eighth): Toggle visibility, set timeframes, and customize colors for each killzone.
[*]Styles: Customize the appearance of the session box, borders, labels, and extended High/Low/Mean lines.
[*]Statistics: Enable and configure historical probability tracking for session sweeps (Total Sweep vs. Session Overlap).
[*]Dividers: Manage the style, width, and color of vertical session dividers and timeframe separators.
[/list]

⚡️ [b]Showcase[/b]

[i]Killzone Sessions[/i]
Visualizing the different killzones with their defined ranges.
https://www.tradingview.com/x/y6Z3tBM1/

[i]First Presented FVG[/i]
Highlighting the first FVG that forms inside the session.
https://www.tradingview.com/x/fz99Fjoy/

[i]Sweep Statistics[/i]
Displaying the historical probability of the session high or low being swept.
https://www.tradingview.com/x/tE4OCoMV/

📒 [b]Usage[/b]

The indicator is highly customizable, allowing you to use various session models and automatically detect the first Fair Value Gap (FVG) that forms within each defined session. 

[b]How to use in trading[/b]

The first Fair Value Gap of a specific session often sets the tone for subsequent price action. Price frequently gravitates towards and interacts with these initial imbalances later in the trading day. Because of this, the First Presented FVG can serve as a key intraday reference point, acting as strong dynamic support or resistance (S/R) levels. Traders can watch these extended FVG zones for high-probability continuation setups or potential reversal points when the price retraces back into them.

Below are some common reference times you can use when setting up your sessions:

[b]ICT Killzones:[/b]
[list]
[*]Asia: 2000-0000
[*]London: 0200-0500
[*]NY AM: 0930-1100
[*]NY Launch: 1200-1300
[*]NY PM: 1330-1600
[/list]

[b]Classic Sessions:[/b]
[list]
[*]Sydney: 1700-0200
[*]Tokyo: 1900-0400
[*]London: 0300-1200
[*]New York: 0800-1700
[/list]

[b]Harmonic Series:[/b]
[list]
[*]Origin: 0000-0300
[*]Prime: 0300-0600
[*]Ascent: 0600-0900
[*]Apex: 0900-1200
[*]Meridian: 1200-1500
[*]Entropy: 1500-1800
[*]Vector: 1800-2100
[*]Convergence: 2100-0000
[/list]

🚨 [b]Alerts[/b]

This script provides alert options for when a new First Presented FVG is formed in any of the configured Killzones.

[i]Bearish Signal[/i]

A bearish signal is triggered when the first bearish P.FVG is formed within an active Killzone.

[i]Bullish Signal[/i]

A bullish signal is triggered when the first bullish P.FVG is formed within an active Killzone.

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - First P.FVG Killzone", shorttitle = "CandelaCharts - First P.FVG Killzone", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500)












// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

// ICT Killzones:
// - Asia:      2000-0000
// - London:    0200-0500
// - NY AM:     0930-1100
// - NY Launch: 1200-1300
// - NY PM:     1330-1600
//
// Classic Sessions:
// - Sydney:   1700-0200
// - Tokyo:    1900-0400
// - London:   0300-1200
// - New York: 0800-1700
//
// Harmonic Series:
// - Origin:      0000-0300
// - Prime:       0300-0600
// - Ascent:      0600-0900
// - Apex:        0900-1200
// - Meridian:    1200-1500
// - Entropy:     1500-1800
// - Vector:      1800-2100
// - Convergence: 2100-0000

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











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
colors_teal                         = color.teal
colors_aqua                         = color.aqua
colors_yellow                       = color.yellow
color_transparent                   = #ffffff00

// Removed Presets Reference:
//
// Classic Sessions:
// - Sydney:   1700-0200
// - Tokyo:    1900-0400
// - London:   0300-1200
// - New York: 0800-1700
//
// Harmonic Series:
// - Origin:      0000-0300
// - Prime:       0300-0600
// - Ascent:      0600-0900
// - Apex:        0900-1200
// - Meridian:    1200-1500
// - Entropy:     1500-1800
// - Vector:      1800-2100
// - Convergence: 2100-0000

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

// # General ----------------------------------------------------------------- #

general_font                            = input.string("Monospace", "Text", options = ["Default", "Monospace"], group = "General")
general_text                            = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = "General", tooltip = "Customize global text size and style")
general_brand_show                      = input.bool(false, "Hide Brand", group = "General")

// # Imbalance Settings ------------------------------------------------------ #

first_p_fvg_type_show                   = input.string("All", "Filter", group = "Imbalance Settings", options = ['All', 'Bullish', 'Bearish', 'None'])
first_p_fvg_midline_show                = input.bool(true, "Mean", group = "Imbalance Settings")
first_p_fvg_midline_style               = input.string("⎯⎯⎯", "Mean Line", group = "Imbalance Settings", options = ['⎯⎯⎯', '----', '····'])
first_p_fvg_midline_width               = input.int(2, "Mean Line Width", minval = 1, maxval = 4, group = "Imbalance Settings")
first_p_fvg_border_show                 = input.bool(false, "Border", group = "Imbalance Settings")
first_p_fvg_border_style                = input.string("⎯⎯⎯", "Border Line", group = "Imbalance Settings", options = ['⎯⎯⎯', '----', '····'])
first_p_fvg_border_width                = input.int(1, "Border Line Width", minval = 0, maxval = 4, group = "Imbalance Settings")
first_p_fvg_labels_show                 = input.bool(true, "Labels ", group = "Imbalance Settings", tooltip = "Display 1st P.FVG Labels")
first_p_fvg_labels_color                = input.color(color.new(colors_black, 20), "Labels Color", group = "Imbalance Settings")
first_p_fvg_extend_mode                 = input.string("Full", "Extend", options = ["Fixed", "Session End", "Full"], group = "Imbalance Settings", tooltip = "FVG Extension:\n- Fixed: Defined length\n- Session End: Extends to the end of the Killzone\n- Full: Extends to the right of the chart")
first_p_fvg_first_bar_show              = input.bool(true, "First Session Bar", group = "Imbalance Settings", tooltip = "Detect FVG on the FIRST bar of the session (can complete FVG from previous session candles)")

// # History ----------------------------------------------------------------- #

first_p_fvg_history_lookback            = input.int(1, "History", minval = 1, maxval = 20, group = "History", tooltip = "Total number of sessions to display (includes the current/latest session).")

first_session_show                      = input.bool(true, "Show", group = "First Session")
first_session_divider                   = input.bool(false, "Show Divider", group = "First Session")
first_session_name                      = input.string("AS", "Name", group = "First Session")
first_session_tf                        = input.session("2000-0000", "Time", group = "First Session")
first_session_color                     = input.color(color.new(colors_aqua, 0), "Color", group = "First Session")
first_session_bull_color                = input.color(color.new(colors_green, 90), "Bull Color", group = "First Session")
first_session_bear_color                = input.color(color.new(colors_red, 90), "Bear Color", group = "First Session")

second_session_show                     = input.bool(true, "Show", group = "Second Session")
second_session_divider                  = input.bool(false, "Show Divider", group = "Second Session")
second_session_name                     = input.string("LO", "Name", group = "Second Session")
second_session_tf                       = input.session("0200-0500", "Time", group = "Second Session")
second_session_color                    = input.color(color.new(colors_orange, 0), "Color", group = "Second Session")
second_session_bull_color               = input.color(color.new(colors_green, 90), "Bull Color", group = "Second Session")
second_session_bear_color               = input.color(color.new(colors_red, 90), "Bear Color", group = "Second Session")

third_session_show                      = input.bool(true, "Show", group = "Third Session")
third_session_divider                   = input.bool(false, "Show Divider", group = "Third Session")
third_session_name                      = input.string("NYAM", "Name", group = "Third Session")
third_session_tf                        = input.session("0930-1100", "Time", group = "Third Session")
third_session_color                     = input.color(color.new(colors_teal, 0), "Color", group = "Third Session")
third_session_bull_color                = input.color(color.new(colors_green, 90), "Bull Color", group = "Third Session")
third_session_bear_color                = input.color(color.new(colors_red, 90), "Bear Color", group = "Third Session")

forth_session_show                      = input.bool(true, "Show", group = "Fourth Session")
forth_session_divider                   = input.bool(false, "Show Divider", group = "Fourth Session")
forth_session_name                      = input.string("NYLA", "Name", group = "Fourth Session")
forth_session_tf                        = input.session("1200-1300", "Time", group = "Fourth Session")
forth_session_color                     = input.color(color.new(colors_blue, 0), "Color", group = "Fourth Session")
forth_session_bull_color                = input.color(color.new(colors_green, 90), "Bull Color", group = "Fourth Session")
forth_session_bear_color                = input.color(color.new(colors_red, 90), "Bear Color", group = "Fourth Session")

fifth_session_show                      = input.bool(true, "Show", group = "Fifth Session")
fifth_session_divider                   = input.bool(false, "Show Divider", group = "Fifth Session")
fifth_session_name                      = input.string("NYPM", "Name", group = "Fifth Session")
fifth_session_tf                        = input.session("1330-1600", "Time", group = "Fifth Session")
fifth_session_color                     = input.color(color.new(colors_purple, 0), "Color", group = "Fifth Session")
fifth_session_bull_color                = input.color(color.new(colors_green, 90), "Bull Color", group = "Fifth Session")
fifth_session_bear_color                = input.color(color.new(colors_red, 90), "Bear Color", group = "Fifth Session")

sixth_session_show                      = input.bool(false, "Show", group = "Sixth Session")
sixth_session_divider                   = input.bool(false, "Show Divider", group = "Sixth Session")
sixth_session_name                      = input.string("Custom", "Name", group = "Sixth Session")
sixth_session_tf                        = input.session("0000-0000", "Time", group = "Sixth Session")
sixth_session_color                     = input.color(color.new(colors_white, 0), "Color", group = "Sixth Session")
sixth_session_bull_color                = input.color(color.new(colors_green, 90), "Bull Color", group = "Sixth Session")
sixth_session_bear_color                = input.color(color.new(colors_red, 90), "Bear Color", group = "Sixth Session")

seventh_session_show                    = input.bool(false, "Show", group = "Seventh Session")
seventh_session_divider                 = input.bool(false, "Show Divider", group = "Seventh Session")
seventh_session_name                    = input.string("Custom 2", "Name", group = "Seventh Session")
seventh_session_tf                      = input.session("0000-0000", "Time", group = "Seventh Session")
seventh_session_color                   = input.color(color.new(colors_white, 0), "Color", group = "Seventh Session")
seventh_session_bull_color              = input.color(color.new(colors_green, 90), "Bull Color", group = "Seventh Session")
seventh_session_bear_color              = input.color(color.new(colors_red, 90), "Bear Color", group = "Seventh Session")

eigth_session_show                      = input.bool(false, "Show", group = "Eighth Session")
eigth_session_divider                   = input.bool(false, "Show Divider", group = "Eighth Session")
eigth_session_name                      = input.string("Custom 3", "Name", group = "Eighth Session")
eigth_session_tf                        = input.session("0000-0000", "Time", group = "Eighth Session")
eigth_session_color                     = input.color(color.new(colors_white, 0), "Color", group = "Eighth Session")
eigth_session_bull_color                = input.color(color.new(colors_green, 90), "Bull Color", group = "Eighth Session")
eigth_session_bear_color                = input.color(color.new(colors_red, 90), "Bear Color", group = "Eighth Session")

// # Styles ------------------------------------------------------------------ #

killzone_line_style                     = input.string('⎯⎯⎯', "Lines", options = ['⎯⎯⎯', '----', '····'], group = "Styles")
killzone_line_width                     = input.int(1, "Line Width", minval = 1, maxval = 4, group = "Styles")
killzone_box_show                       = input.bool(true, "Show Box", group = "Styles")
killzone_box_bg_show                    = input.bool(true, "Show Background", group = "Styles")
killzone_highlighter_show               = input.bool(false, "Highlighter", group = "Styles")
killzone_border_show                    = input.bool(true, "Show Border", group = "Styles")
killzone_high_show                      = input.bool(false, "Show High Line", group = "Styles")
killzone_low_show                       = input.bool(false, "Show Low Line", group = "Styles")
killzone_mean_show                      = input.bool(true, "Show Mean Line", group = "Styles")
killzone_labels                         = input.bool(true, "Show Labels", group = "Styles")
killzone_session_name_show              = input.bool(true, "Show Session Name", group = "Styles")

// # Statistics -------------------------------------------------------------- #

killzone_stats_show                     = input.bool(true, "Show Statistics", group = "Statistics", tooltip = "Display probability of High/Low sweep based on history")
killzone_stats_algo                     = input.string("Total Sweep", "Calculation Method", options = ["Total Sweep", "Session Overlap"], group = "Statistics", tooltip = "Total Sweep: Checks if swept at any time (even days later).\nSession Overlap: Checks if swept specifically by another session.")
killzone_stats_lookback                 = input.int(200, "Lookback Length", minval = 5, maxval = 1000, group = "Statistics", tooltip = "Number of past sessions to use for probability calculation")

// # Dividers ---------------------------------------------------------------- #

// Global Style Inputs
divider_session_style                   = input.string('----', "Style", options = ['⎯⎯⎯', '----', '····'], group = "Dividers")
divider_session_width                   = input.int(1, "Width", minval = 1, maxval = 4, group = "Dividers")
divider_timeframe                       = input.timeframe("60", "Timeframe", group = "Dividers", tooltip = "Select the timeframe for dividers (e.g., 15, 60, 240, D)")
divider_session_color                   = input.color(color.gray, "Color", group = "Dividers")
divider_timeframe_show                  = input.bool(false, "Show TF Separators", group = "Dividers")

// Per-Session Divider Toggles (Placed in Session Groups?? No, User might want central control or per session group. 
// "enabled per session" -> implies input in session group.
// But style is shared logic usually.
// Let's keep style central and add toggles to session groups.

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
    polyline [] bin_polyline

type UDT_Block
    int     id          = na
    int     left        = na
    float   top         = na
    int     right       = na
    float   bottom      = na
    float   mid         = na
    bool    bull        = false
    string  block_type
    string  title
    color   bull_color
    color   bear_color

type UDT_Coord_Point
    float o
    float c
    float h
    float l


type UDT_SessionRange
    string  session_id
    float   h
    float   l
    float   o
    float   c
    int     ot
    int     ct
    int     h_idx
    int     l_idx
    color   box_color
    bool    show_divider = false
    
    // Invalidation Data
    bool    invalidated_h = false
    int     invalidated_h_t = na
    int     invalidated_h_idx = na
    bool    invalidated_l = false
    int     invalidated_l_t = na
    int     invalidated_l_idx = na
    bool    invalidated_mid = false
    int     invalidated_mid_t = na
    int     invalidated_mid_idx = na
    
    // Stats
    float   prob_sweep_h = na
    float   prob_sweep_l = na

type UDT_Killzone
    string  name
    string  session_time
    bool    show
    bool    show_divider
    color   box_color
    color   bull_color
    color   bear_color
    bool    is_session = false
    UDT_Block last_fvg = na
    UDT_Block[] fvgs
    
    // History of session ranges for boxes
    UDT_SessionRange[] session_ranges
    // Current active session range
    UDT_SessionRange current_range = na

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Bin   |
// # ========================================================================= #

//#region

var UDT_Store bin = UDT_Store.new(
                   bin_ln = array.new<line>()
                 , bin_box = array.new<box>()
                 , bin_lbl = array.new<label>()
                 , bin_polyline = array.new<polyline>()
                 )

method clean_bin(UDT_Store store) =>
    for obj in store.bin_ln
        obj.delete()
    for obj in store.bin_box
        obj.delete()
    for obj in store.bin_lbl
        obj.delete()
    for obj in store.bin_polyline
        obj.delete()

    store.bin_ln.clear()
    store.bin_box.clear()
    store.bin_lbl.clear()
    store.bin_polyline.clear()

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

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Logic   |
// # ========================================================================= #

//#region

string ny_midnight_tz = "America/New_York"
var string ltf = timeframe.period
const string htf = '1D'
const int imbalance_threshold = 0
const int imbalance_length = 20

gap_hl(string tf) => request.security(syminfo.tickerid, tf, [open[1], close[1], high[2], low[2]])
tf_gap(string tf) => request.security(syminfo.tickerid, tf, [open, close, high, low])

[ltf_prev_open, ltf_prev_close, ltf_prev_high_2, ltf_prev_low_2] = gap_hl(ltf)
[ltf_gap_open, ltf_gap_close, ltf_gap_high, ltf_gap_low]         = tf_gap(ltf)

ltf_prev_coord_point = UDT_Coord_Point.new(o=ltf_prev_open, c=ltf_prev_close, h=ltf_prev_high_2, l=ltf_prev_low_2)
ltf_curr_coord_point = UDT_Coord_Point.new(o=ltf_gap_open,  c=ltf_gap_close,  h=ltf_gap_high,    l=ltf_gap_low)

bool ltf_fvg_timeframe_change = timeframe.change(ltf)

get_imbalance_fvg_threshold()   => ta.atr(14) * imbalance_threshold

shift_to_right(int current, int length, string tf) =>
    current + timeframe.in_seconds(tf) * 1000 * (length + 1)

method limit_buffer(array<UDT_Block> data, int buffer) =>
    if data.size() > buffer
        data.pop()
    data

method limit_buffer(array<UDT_SessionRange> data, int buffer) =>
    if data.size() > buffer
        data.pop()
    data

method session_begins(string tf, string ses, string tz) =>
    t = time(tf, ses, na(tz) ? "" : tz)
    ct = time_close(tf, ses, na(tz) ? "" : tz)
    not na(t) and not na(ct) and (na(t[1]) or t > t[1])
    
method in_session(string tf, string ses, string tz) =>
    t = time(tf, ses, na(tz) ? "" : tz)
    ct = time_close(tf, ses, na(tz) ? "" : tz)
    not na(t) and not na(ct)

get_dayofweek(int d) =>
    switch d
        dayofweek.friday => 'Friday'
        dayofweek.monday => 'Monday'
        dayofweek.saturday => 'Saturday'
        dayofweek.sunday => 'Sunday'
        dayofweek.thursday => 'Thursday'
        dayofweek.tuesday => 'Tuesday'
        dayofweek.wednesday => 'Wednesday'
        => ''

// Invalidation Helpers from Quadratic Killzones
check_level_invalidation(float level_price, int direction, int session_close_time) =>
    bool is_invalidated = false
    if session_close_time < time
        if direction == 0
            // Below only: invalidate when low touches level from below
            is_invalidated := low <= level_price
        else if direction == 1
            // Above only: invalidate when high touches level from above
            is_invalidated := high >= level_price
        else if direction == 2
            // Both directions: invalidate when price touches level from either direction
            is_invalidated := high >= level_price or low <= level_price
    is_invalidated

method invalidate_killzone_level(UDT_SessionRange data, float level_price, int direction, bool is_already_invalidated) =>
    bool was_invalidated = false
    if not is_already_invalidated
        invalidated = check_level_invalidation(level_price, direction, data.ct)
        if invalidated
            was_invalidated := true
    was_invalidated

method invalidate_killzone_high(UDT_SessionRange data) =>
    invalidated_h = data.h < high and data.h > low and data.ct < time
    if invalidated_h
        data.invalidated_h := true
        data.invalidated_h_t := time
        data.invalidated_h_idx := bar_index
    data

method invalidate_killzone_low(UDT_SessionRange data) =>
    invalidated_l = data.l > low and data.l < high and data.ct < time
    if invalidated_l
        data.invalidated_l := true
        data.invalidated_l_t := time
        data.invalidated_l_idx := bar_index
    data

method invalidate_killzone_mid(UDT_SessionRange data) =>
    mid = math.avg(data.h, data.l)
    // Mid level is invalidated when price touches it from either direction (high >= mid or low <= mid)
    if data.invalidate_killzone_level(mid, 2, data.invalidated_mid)
        data.invalidated_mid := true
        data.invalidated_mid_t := time
        data.invalidated_mid_idx := bar_index
    data

detect_fvg(bool bull, string tf, UDT_Coord_Point curr_coord_point, UDT_Coord_Point prev_coord_point, bool fvg_timeframe_change, string extend_mode, int session_end_time, color bull_clr, color bear_clr, string title_prefix) => 
    int id        = bar_index
    float imbalance_atr = get_imbalance_fvg_threshold()
    
    int position    = 1
    int left        = time
    
    int right = na
    if extend_mode == "Full"
        right := last_bar_time
    else if extend_mode == "Session End"
        right := session_end_time
    else
        right := shift_to_right(time, imbalance_length, tf)

    UDT_Block fvg   = na

    switch bull
        true => 
            top     = curr_coord_point.l
            bottom  = prev_coord_point.h
            mid     = math.avg(top,bottom)
            is_fvg_detected = top > bottom and math.abs(top - bottom) > imbalance_atr

            if is_fvg_detected and fvg_timeframe_change
                fvg := UDT_Block.new(id, left, top, right, bottom, mid, bull = true, block_type = "FVG", title = title_prefix, bull_color = bull_clr, bear_color = bear_clr)

        false =>
            top     = prev_coord_point.l
            bottom  = curr_coord_point.h
            mid     = math.avg(top,bottom)
            is_fvg_detected = bottom < top and math.abs(top - bottom) > imbalance_atr

            if is_fvg_detected and fvg_timeframe_change
                fvg := UDT_Block.new(id, left, top, right, bottom, mid, bull = false, block_type = "FVG", title = title_prefix, bull_color = bull_clr, bear_color = bear_clr)

    fvg

method draw_fvg(UDT_Block block, string tf, string extend_mode) =>
    bool show = true
    
    if show
        int right = block.right
        // If extension is "Full", we always want it to point to current last_bar_time (dynamic)
        if extend_mode == "Full"
            right := last_bar_time
        
        block_clr = block.bull ? block.bull_color : block.bear_color
        // Use block colors for borders too
        // block.bull_color and block.bear_color are already set based on the killzone settings
        border_clr_final = first_p_fvg_border_show ? (block.bull ? block.bull_color : block.bear_color) : color_transparent
        
        border_width = first_p_fvg_border_show ? first_p_fvg_border_width : 0
        border_style = line_style(first_p_fvg_border_style)
        
        bx = box.new(left = block.left, top = block.top, right = right, bottom = block.bottom, xloc = xloc.bar_time, bgcolor = block_clr, border_color = border_clr_final, border_style = border_style, border_width = border_width,
             text_color = first_p_fvg_labels_color, text_size = text_size(general_text), text_valign = text.align_top, text_halign = text.align_right, text_font_family = font_style(general_font), text_formatting = text.format_bold)
        bin.bin_box.push(bx)
        
        if first_p_fvg_labels_show
            string prefix = "FVG"
            label_txt = prefix + "-" + block.title
            bx.set_text(label_txt)
        
        if first_p_fvg_midline_show
            line_width = first_p_fvg_midline_width
            line_style = line_style(first_p_fvg_midline_style)
            // Midline color logic: use block color but with full opacity
            base_clr = block.bull ? block.bull_color : block.bear_color
            line_clr = color.rgb(color.r(base_clr), color.g(base_clr), color.b(base_clr), 0)
            // Making it slightly darker or just solid? Source uses specific inputs. 
            // We'll use the block color to keep it consistent with the killzone theme.
            bin.bin_ln.push(line.new(x1 = block.left, y1 = block.mid, x2 = right, y2 = block.mid, xloc = xloc.bar_time, color = line_clr, style = line_style, width = line_width))
    block

method process_killzone(UDT_Killzone kz) =>
    
    // Logic for Boxes
    if kz.show
        // Track OHLC
        if session_begins(htf, kz.session_time, ny_midnight_tz)
            // If there was a previous session, push it to history (if not already pushed? session_begins happens at start of new)
            // But we might need to handle the very first run.
            // Actually, best to push when session ends? Or just keep updating the current one and push when a NEW one starts.
            if not na(kz.current_range)
                kz.session_ranges.unshift(kz.current_range)
                // Limit buffer to max of history lookback and stats lookback
                // We need more history for stats than for drawing boxes usually
                kz.session_ranges.limit_buffer(math.max(first_p_fvg_history_lookback, killzone_stats_lookback))
            
            // Start new range
            kz.current_range := UDT_SessionRange.new(kz.name, high, low, open, close, time, time_close(htf, kz.session_time, ny_midnight_tz), bar_index, bar_index, kz.box_color, show_divider = kz.show_divider)
            
            kz.last_fvg := na
            kz.is_session := true
            
            // Detect FVG on the FIRST bar of the session (can complete FVG from previous session candles)
            UDT_Block bull_fvg = na
            UDT_Block bear_fvg = na
            int sess_end = kz.current_range.ct

            if first_p_fvg_first_bar_show
                if first_p_fvg_type_show == "All"
                    bull_fvg := detect_fvg(true, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)
                    bear_fvg := detect_fvg(false, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)

                if first_p_fvg_type_show == "Bullish"
                    bull_fvg := detect_fvg(true, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)

                if first_p_fvg_type_show == "Bearish"
                    bear_fvg := detect_fvg(false, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)

            if not na(bull_fvg) and na(kz.last_fvg)
                kz.last_fvg := bull_fvg
                kz.fvgs.unshift(bull_fvg)
                kz.fvgs.limit_buffer(first_p_fvg_history_lookback)
            if not na(bear_fvg) and na(kz.last_fvg)
                kz.last_fvg := bear_fvg
                kz.fvgs.unshift(bear_fvg)
                kz.fvgs.limit_buffer(first_p_fvg_history_lookback)
        else 
            if in_session(htf, kz.session_time, ny_midnight_tz)
                kz.is_session := true
                
                // Update current range
                if not na(kz.current_range)
                    if high > kz.current_range.h
                        kz.current_range.h := high
                        kz.current_range.h_idx := bar_index
                    if low < kz.current_range.l
                        kz.current_range.l := low
                        kz.current_range.l_idx := bar_index
                    kz.current_range.c := close
                
                // Run FVG Detection
                if na(kz.last_fvg)
                    UDT_Block bull_fvg = na
                    UDT_Block bear_fvg = na

                    // Pass kz.current_range.ct as session_end_time
                    // Note: kz.current_range might be na if session JUST started but code above sets it.
                    int sess_end = na(kz.current_range) ? na : kz.current_range.ct

                    if first_p_fvg_type_show == "All"
                        bull_fvg := detect_fvg(true, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)
                        bear_fvg := detect_fvg(false, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)

                    if first_p_fvg_type_show == "Bullish"
                        bull_fvg := detect_fvg(true, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)

                    if first_p_fvg_type_show == "Bearish"
                        bear_fvg := detect_fvg(false, ltf, ltf_curr_coord_point, ltf_prev_coord_point, true, first_p_fvg_extend_mode, sess_end, kz.bull_color, kz.bear_color, kz.name)

                    if not na(bull_fvg) and na(kz.last_fvg)
                        kz.last_fvg := bull_fvg
                        kz.fvgs.unshift(bull_fvg)
                        kz.fvgs.limit_buffer(first_p_fvg_history_lookback)
                    if not na(bear_fvg) and na(kz.last_fvg)
                        kz.last_fvg := bear_fvg
                        kz.fvgs.unshift(bear_fvg)
                        kz.fvgs.limit_buffer(first_p_fvg_history_lookback)
            else
                kz.is_session := false
    
    // Invalidation Logic (Run on every bar for all history ranges AND current range)
    if kz.show
        // Invalidate historical session ranges
        for rng in kz.session_ranges
            if not rng.invalidated_h
                rng.invalidate_killzone_high()
            if not rng.invalidated_l
                rng.invalidate_killzone_low()
            if not rng.invalidated_mid
                rng.invalidate_killzone_mid()
        
        // Also invalidate current range (after session closes)
        if not na(kz.current_range)
            if not kz.current_range.invalidated_h
                kz.current_range.invalidate_killzone_high()
            if not kz.current_range.invalidated_l
                kz.current_range.invalidate_killzone_low()
            if not kz.current_range.invalidated_mid
                kz.current_range.invalidate_killzone_mid()
                
    kz

method calculate_stats(UDT_Killzone kz, UDT_Killzone[] all_kzs) =>
    if kz.show and not na(kz.current_range) and killzone_stats_show
        int total_sessions = 0
        int swept_h_count = 0
        int swept_l_count = 0
        
        bool use_algo_cycle = killzone_stats_algo == "Total Sweep"
        
        // Loop through history to calculate sweep probability
        for i = 0 to array.size(kz.session_ranges) - 1
            if total_sessions < killzone_stats_lookback
                UDT_SessionRange rng = kz.session_ranges.get(i)
                
                // Determine start time of the NEXT session to define the cycle window
                // If i == 0, the next session is the current_range
                // If i > 0, the next session is at i-1
                int next_ot = i == 0 ? kz.current_range.ot : kz.session_ranges.get(i-1).ot
                
                if use_algo_cycle
                    // --- Algorithm 1: Total Sweep ---
                    // Check High Sweep
                    if rng.invalidated_h
                        swept_h_count += 1
                    
                    // Check Low Sweep
                    if rng.invalidated_l
                        swept_l_count += 1
                            
                else
                    // --- Algorithm 2: Session Overlap Sweep ---
                    // Check if OTHER sessions swept this level
                    bool h_swept_by_session = false
                    bool l_swept_by_session = false
                    
                    // Iterate all other killzones
                    for other_kz in all_kzs
                        if other_kz.name != kz.name // Skip self
                            // Check other KZ's history + distinct current range
                            // We need to find ranges in other_kz that are within [rng.ct, next_ot]
                            
                            // Check history
                            for other_rng in other_kz.session_ranges
                                // Optimization: valid time window check
                                if other_rng.ot > next_ot 
                                    continue // Too new
                                if other_rng.ct < rng.ct
                                    // Too old, and since arrays are sorted desc (newest first), we can potentially break?
                                    // Actually array has newest at index 0. So as we iterate, time goes back.
                                    // If other_rng.ct < rng.ct, it means this session ended before our target session even closed.
                                    // So we can stop checking older sessions.
                                    break 
                                
                                // Check overlap: Other session started AFTER our session closed AND BEFORE our next cycle started
                                if other_rng.ot >= rng.ct and other_rng.ot < next_ot
                                    if other_rng.h > rng.h
                                        h_swept_by_session := true
                                    if other_rng.l < rng.l
                                        l_swept_by_session := true
                            
                            // Check current range of other KZ
                            if not na(other_kz.current_range)
                                if other_kz.current_range.ot >= rng.ct and other_kz.current_range.ot < next_ot
                                    if other_kz.current_range.h > rng.h
                                        h_swept_by_session := true
                                    if other_kz.current_range.l < rng.l
                                        l_swept_by_session := true

                    if h_swept_by_session
                        swept_h_count += 1
                    if l_swept_by_session
                        swept_l_count += 1

                total_sessions += 1
            else
                break
        
        if total_sessions > 0
            kz.current_range.prob_sweep_h := (swept_h_count / total_sessions) * 100
            kz.current_range.prob_sweep_l := (swept_l_count / total_sessions) * 100
    kz

method draw_killzone_box(UDT_SessionRange rng) =>
    if not na(rng)
        
        // Use the specific box color for background, border, and text
        base_color = rng.box_color
        
        bg_color = killzone_box_bg_show ? color.new(base_color, 90) : color_transparent
        border_color = killzone_border_show ? base_color : color.new(base_color, 100)
        
        // Invalidation Times
        high_x2_time = rng.invalidated_h ? rng.invalidated_h_t : time
        low_x2_time = rng.invalidated_l ? rng.invalidated_l_t : time
        mid_x2_time = rng.invalidated_mid ? rng.invalidated_mid_t : time
        
        // Draw Box
        mid = math.avg(rng.h, rng.l)
        if killzone_box_show
            // Single Box: High to Low
            bin.bin_box.push(box.new(left=rng.ot, top=rng.h, right=rng.ct, bottom=rng.l, border_color = border_color, border_width = killzone_line_width, bgcolor = bg_color, xloc = xloc.bar_time))
            
            // Internal Mean Line (Only if enabled)
            if killzone_mean_show
                bin.bin_ln.push(line.new(x1=rng.ct, y1=mid, x2=rng.ot, y2=mid, xloc = xloc.bar_time, color = border_color, style = line.style_dotted, width = killzone_line_width))
            
            // Session Name Label (Centered)
            if killzone_session_name_show
                // Text color same as box color, no opacity (as requested)
                txt_color = base_color 
                bin.bin_box.push(box.new(left=rng.ot, top=rng.h, right=rng.ct, bottom=rng.l, border_color = color_transparent, border_width = 0, bgcolor = color_transparent, text = rng.session_id, text_color = txt_color, text_size = size.auto, text_halign = text.align_center, text_valign = text.align_center, text_font_family = font_style(general_font), text_formatting = text.format_bold, xloc = xloc.bar_time))
        
        // Extended Lines (High/Low/Mean) with Invalidation
        if killzone_high_show
            // High Line
            bin.bin_ln.push(line.new(x1=rng.ct, y1=rng.h, x2=high_x2_time, y2=rng.h, xloc = xloc.bar_time, color = border_color, style = line_style(killzone_line_style), width = killzone_line_width))
        
        if killzone_low_show
            // Low Line
            bin.bin_ln.push(line.new(x1=rng.ct, y1=rng.l, x2=low_x2_time, y2=rng.l, xloc = xloc.bar_time, color = border_color, style = line_style(killzone_line_style), width = killzone_line_width))
        
        if killzone_mean_show
            bin.bin_ln.push(line.new(x1=rng.ct, y1=mid, x2=mid_x2_time, y2=mid, xloc = xloc.bar_time, color = border_color, style = line.style_dotted, width = killzone_line_width))
        
        
        // Vertical Session Dividers
        if rng.show_divider
            extend_val = extend.both
            
            // Start Divider
            bin.bin_ln.push(line.new(x1=rng.ot, y1=rng.h, x2=rng.ot, y2=rng.l, xloc = xloc.bar_time, color = divider_session_color, style = line_style(divider_session_style), width = divider_session_width, extend = extend_val))
            
            // End Divider
            bin.bin_ln.push(line.new(x1=rng.ct, y1=rng.h, x2=rng.ct, y2=rng.l, xloc = xloc.bar_time, color = divider_session_color, style = line_style(divider_session_style), width = divider_session_width, extend = extend_val))

        // Labels
        if killzone_labels
            // Determine where to place the label (at invalidation point or current time)
            
            // High Label
            if killzone_high_show
                h_label_x = rng.invalidated_h ? rng.invalidated_h_t : time
                h_text = rng.session_id + ".H"
                if killzone_stats_show and not na(rng.prob_sweep_h)
                    h_text := h_text + " (" + str.tostring(rng.prob_sweep_h, "#") + "%)"
                bin.bin_lbl.push(label.new(x=h_label_x, y=rng.h, text=h_text, color=color_transparent, style=label.style_label_left, textcolor=border_color, size=text_size(general_text), text_font_family=font_style(general_font), yloc=yloc.price, xloc=xloc.bar_time))
            else if killzone_box_show and not killzone_high_show
                 // If lines are hidden but box is shown, maybe show labels at box edge?
                h_text = rng.session_id + ".H"
                if killzone_stats_show and not na(rng.prob_sweep_h)
                    h_text := h_text + " (" + str.tostring(rng.prob_sweep_h, "#") + "%)"
                bin.bin_lbl.push(label.new(x=rng.ct, y=rng.h, text=h_text, color=color_transparent, style=label.style_label_left, textcolor=border_color, size=text_size(general_text), text_font_family=font_style(general_font), yloc=yloc.price, xloc=xloc.bar_time))
            
            // Low Label
            if killzone_low_show
                l_label_x = rng.invalidated_l ? rng.invalidated_l_t : time
                l_text = rng.session_id + ".L"
                if killzone_stats_show and not na(rng.prob_sweep_l)
                    l_text := l_text + " (" + str.tostring(rng.prob_sweep_l, "#") + "%)"
                bin.bin_lbl.push(label.new(x=l_label_x, y=rng.l, text=l_text, color=color_transparent, style=label.style_label_left, textcolor=border_color, size=text_size(general_text), text_font_family=font_style(general_font), yloc=yloc.price, xloc=xloc.bar_time))
            else if killzone_box_show and not killzone_low_show
                l_text = rng.session_id + ".L"
                if killzone_stats_show and not na(rng.prob_sweep_l)
                    l_text := l_text + " (" + str.tostring(rng.prob_sweep_l, "#") + "%)"
                bin.bin_lbl.push(label.new(x=rng.ct, y=rng.l, text=l_text, color=color_transparent, style=label.style_label_left, textcolor=border_color, size=text_size(general_text), text_font_family=font_style(general_font), yloc=yloc.price, xloc=xloc.bar_time))
    rng

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Execution   |
// # ========================================================================= #

bin.clean_bin()

// Define Killzones
var s1_kz = UDT_Killzone.new("S1", "0000-0000", true, false, color.blue, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s2_kz = UDT_Killzone.new("S2", "0000-0000", true, false, color.orange, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s3_kz = UDT_Killzone.new("S3", "0000-0000", true, false, color.purple, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s4_kz = UDT_Killzone.new("S4", "0000-0000", true, false, color.gray, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s5_kz = UDT_Killzone.new("S5", "0000-0000", true, false, color.green, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s6_kz = UDT_Killzone.new("S6", "0000-0000", false, false, color.white, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s7_kz = UDT_Killzone.new("S7", "0000-0000", false, false, color.white, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())
var s8_kz = UDT_Killzone.new("S8", "0000-0000", false, false, color.white, color.green, color.red, fvgs = array.new<UDT_Block>(), session_ranges = array.new<UDT_SessionRange>())

// Update killzone properties based on inputs
s1_kz.name := first_session_name, s1_kz.session_time := first_session_tf, s1_kz.show := first_session_show, s1_kz.box_color := first_session_color, s1_kz.show_divider := first_session_divider, s1_kz.bull_color := first_session_bull_color, s1_kz.bear_color := first_session_bear_color
s2_kz.name := second_session_name, s2_kz.session_time := second_session_tf, s2_kz.show := second_session_show, s2_kz.box_color := second_session_color, s2_kz.show_divider := second_session_divider, s2_kz.bull_color := second_session_bull_color, s2_kz.bear_color := second_session_bear_color
s3_kz.name := third_session_name, s3_kz.session_time := third_session_tf, s3_kz.show := third_session_show, s3_kz.box_color := third_session_color, s3_kz.show_divider := third_session_divider, s3_kz.bull_color := third_session_bull_color, s3_kz.bear_color := third_session_bear_color
s4_kz.name := forth_session_name, s4_kz.session_time := forth_session_tf, s4_kz.show := forth_session_show, s4_kz.box_color := forth_session_color, s4_kz.show_divider := forth_session_divider, s4_kz.bull_color := forth_session_bull_color, s4_kz.bear_color := forth_session_bear_color
s5_kz.name := fifth_session_name, s5_kz.session_time := fifth_session_tf, s5_kz.show := fifth_session_show, s5_kz.box_color := fifth_session_color, s5_kz.show_divider := fifth_session_divider, s5_kz.bull_color := fifth_session_bull_color, s5_kz.bear_color := fifth_session_bear_color
s6_kz.name := sixth_session_name, s6_kz.session_time := sixth_session_tf, s6_kz.show := sixth_session_show, s6_kz.box_color := sixth_session_color, s6_kz.show_divider := sixth_session_divider, s6_kz.bull_color := sixth_session_bull_color, s6_kz.bear_color := sixth_session_bear_color
s7_kz.name := seventh_session_name, s7_kz.session_time := seventh_session_tf, s7_kz.show := seventh_session_show, s7_kz.box_color := seventh_session_color, s7_kz.show_divider := seventh_session_divider, s7_kz.bull_color := seventh_session_bull_color, s7_kz.bear_color := seventh_session_bear_color
s8_kz.name := eigth_session_name, s8_kz.session_time := eigth_session_tf, s8_kz.show := eigth_session_show, s8_kz.box_color := eigth_session_color, s8_kz.show_divider := eigth_session_divider, s8_kz.bull_color := eigth_session_bull_color, s8_kz.bear_color := eigth_session_bear_color

if timeframe.in_seconds(ltf) < timeframe.in_seconds('30')
    s1_kz := s1_kz.process_killzone()
    s2_kz := s2_kz.process_killzone()
    s3_kz := s3_kz.process_killzone()
    s4_kz := s4_kz.process_killzone()
    s5_kz := s5_kz.process_killzone()
    s6_kz := s6_kz.process_killzone()
    s7_kz := s7_kz.process_killzone()
    s8_kz := s8_kz.process_killzone()

    if barstate.islast
        // Draw FVG history and Session Boxes
        UDT_Killzone[] all_kzs = array.from(s1_kz, s2_kz, s3_kz, s4_kz, s5_kz, s6_kz, s7_kz, s8_kz)
        for kz in all_kzs
            // Calculate Stats (Sweep Probability)
            kz.calculate_stats(all_kzs)
            
            // Draw FVGs
            for fvg in kz.fvgs
                fvg.draw_fvg(ltf, first_p_fvg_extend_mode)
            
            // Draw Session Boxes (History)
            // Limit drawing to history lookback, even though array might be larger for stats
            int count = 0
            for rng in kz.session_ranges
                if count < first_p_fvg_history_lookback - 1
                    rng.draw_killzone_box()
                count += 1
                
            // Draw Current Range
            if not na(kz.current_range)
                kz.current_range.draw_killzone_box()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Background   |
// # ========================================================================= #

//#region

// Highlighter Logic (Global Scope)
// Use ternary condition to avoid local scope issues.
bgcolor(killzone_highlighter_show and s1_kz.show and s1_kz.is_session ? color.new(s1_kz.box_color, 90) : na, title="Session Highlighter S1")
bgcolor(killzone_highlighter_show and s2_kz.show and s2_kz.is_session ? color.new(s2_kz.box_color, 90) : na, title="Session Highlighter S2")
bgcolor(killzone_highlighter_show and s3_kz.show and s3_kz.is_session ? color.new(s3_kz.box_color, 90) : na, title="Session Highlighter S3")
bgcolor(killzone_highlighter_show and s4_kz.show and s4_kz.is_session ? color.new(s4_kz.box_color, 90) : na, title="Session Highlighter S4")
bgcolor(killzone_highlighter_show and s5_kz.show and s5_kz.is_session ? color.new(s5_kz.box_color, 90) : na, title="Session Highlighter S5")
bgcolor(killzone_highlighter_show and s6_kz.show and s6_kz.is_session ? color.new(s6_kz.box_color, 90) : na, title="Session Highlighter S6")
bgcolor(killzone_highlighter_show and s7_kz.show and s7_kz.is_session ? color.new(s7_kz.box_color, 90) : na, title="Session Highlighter S7")
bgcolor(killzone_highlighter_show and s8_kz.show and s8_kz.is_session ? color.new(s8_kz.box_color, 90) : na, title="Session Highlighter S8")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Dividers   |
// # ========================================================================= #

//#region

var array<line> divider_lines = array.new<line>()

// Detect timeframe change
divider_tf_change = timeframe.change(divider_timeframe)

// Draw dividers
if divider_timeframe_show and divider_tf_change and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds("1D")
    extend_style = extend.both
    divider_ln = line.new(
         x1 = bar_index,
         y1 = high,
         x2 = bar_index,
         y2 = low,
         color = divider_session_color,
         style = line_style(divider_session_style),
         width = divider_session_width,
         extend = extend_style
         )
    divider_lines.push(divider_ln)

// Limit the number of divider lines to prevent memory issues
if divider_lines.size() > 500
    old_line = divider_lines.shift()
    line.delete(old_line)

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
