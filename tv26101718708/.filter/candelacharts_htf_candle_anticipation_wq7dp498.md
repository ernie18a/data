# CandelaCharts - HTF Candle Anticipation

- url: https://www.tradingview.com/script/Wq7dP498-CandelaCharts-HTF-Candle-Anticipation/
- type: indicator
- pine_id: PUB;f7cf9221a172478fb20e0b19f8144839
- version: 2.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - HTF Candle Anticipation[/b] indicator provides a multi-timeframe analysis view by rendering higher timeframe (HTF) candles directly on your current chart, offset to the right. Not only does it show historical HTF candles, but it also generates an Anticipated Candle representing the expected future price action based on liquidity sweeps, structure breaks (BOS), and lower timeframe Changes of Character (CHoCH).

The indicator analyzes the relationship between the two most recently closed HTF candles. Based on how the current candle interacts with the high and low of the previous candle, the indicator projects the next candle's bias:
[list]
[*] [b]Sweep:[/b] Piercing the previous candle's extreme (high or low) but closing back in range signals a liquidity grab (targeting the opposite side).
https://www.tradingview.com/x/TpQQQ5Fp/
[*] [b]BOS:[/b] Closing beyond the previous candle's extreme (high or low) signals continuation.
https://www.tradingview.com/x/Jixanbvn/
[*] [b]CHoCH:[/b] If no sweep or BOS occurs, the script relies on a specified Lower Timeframe (LTF). A bearish CHoCH in the top 50% of the HTF candle anticipates a bearish move, while a bullish CHoCH in the bottom 50% anticipates a bullish move.
https://www.tradingview.com/x/MoVu21yS/
[*] [b]Respect:[/b] The current candle's body respects the previous candle's equilibrium (50% level), signaling continuation.
https://www.tradingview.com/x/12VuFkRE/
[*] [b]Disrespect:[/b] The current candle's body disrespects the previous candle's equilibrium (50% level), signaling reversal.
https://www.tradingview.com/x/ml9enArx/
[/list]

📦 [b]Features[/b]

[list]
[*] [b]Multi-Group Display:[/b] Supports up to 4 different HTF groups simultaneously (e.g., 1H, 4H, 1D, 1W), allowing top-down analysis without switching charts.
[*] [b]Customizable LTF CHoCH:[/b] Explicitly define the Lower Timeframe and pivot length to use for CHoCH detection for each HTF group.
[*] [b]Interactive Dashboard:[/b] An on-chart dashboard tracks the current Anticipation Stage for all active groups, including the progression of stages (e.g., Sweep ↓ → CHoCH ↑).
[*] [b]Clean Visuals:[/b] Highly customizable visuals including offsets, spacing, label sizes, and colors. The anticipated candle is drawn with a customizable opacity to distinguish it from historical candles.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]General:[/b] Global settings for text size, font, and the CHoCH Swing Length used for detecting LTF pivots.
[*] [b]HTF Groups (1-4):[/b] Toggle visibility, set the timeframe, the number of historical candles to show, and the specific LTF used for CHoCH.
[*] [b]Styling & Labels:[/b] Customize colors for bullish/bearish anticipated candles, spacing, margins, label display, and rendering offsets.
[*] [b]Dashboard:[/b] Toggle the stage tracking dashboard and set its position on the chart.
[/list]

⚡️ [b]Showcase[/b]

[i]Next Candle[/i]
https://www.tradingview.com/x/gYt10gir/

[i]HTF Dividers[/i]
https://www.tradingview.com/x/iICDK7jV/

[i]Dashboard[/i]
https://www.tradingview.com/x/UWHls8X2/

🚨 [b]Alerts[/b]

[list]
[*] [b]Anticipation Formed:[/b] Triggered when a new anticipated scenario is confirmed on any active HTF group.
[/list]

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - HTF Candle Anticipation", shorttitle = "CandelaCharts - HTF Candle Anticipation", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 2000, max_polylines_count = 100)




 


 


 

// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

// # Core -------------------------------------------------------------------- #

colors_white                        = color.white
colors_black                        = color.black
colors_purple                       = color.purple
colors_red                          = color.red
colors_gray                         = color.gray
colors_blue                         = color.blue
colors_orange                       = color.orange
colors_green                        = color.green
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

general_font                                = input.string("Monospace", "Text                         ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                                = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General")
general_brand_show                          = input.bool(false, "Hide Brand", group = "General")

// # HTF Group 1 ------------------------------------------------------------- #

htf1_show                                   = input.bool(true, "Show Group 1", group = "HTF Group 1")
htf1_tf                                     = input.timeframe("15", "Timeframe", group = "HTF Group 1")
htf1_number                                 = input.int(2, "Candles", group = "HTF Group 1", minval = 2, maxval = 30)
htf1_choch_tf                               = input.timeframe("1", "CHoCH TF", group = "HTF Group 1")
htf1_divider                                = input.bool(false, "Divider", group = "HTF Group 1")

// # HTF Group 2 ------------------------------------------------------------- #

htf2_show                                   = input.bool(false, "Show Group 2", group = "HTF Group 2")
htf2_tf                                     = input.timeframe("60", "Timeframe", group = "HTF Group 2")
htf2_number                                 = input.int(2, "Candles", group = "HTF Group 2", minval = 2, maxval = 30)
htf2_choch_tf                               = input.timeframe("5", "CHoCH TF", group = "HTF Group 2")
htf2_divider                                = input.bool(false, "Divider", group = "HTF Group 2")

// # HTF Group 3 ------------------------------------------------------------- #

htf3_show                                   = input.bool(false, "Show Group 3", group = "HTF Group 3")
htf3_tf                                     = input.timeframe("240", "Timeframe", group = "HTF Group 3")
htf3_number                                 = input.int(2, "Candles", group = "HTF Group 3", minval = 2, maxval = 30)
htf3_choch_tf                               = input.timeframe("5", "CHoCH TF", group = "HTF Group 3")
htf3_divider                                = input.bool(false, "Divider", group = "HTF Group 3")

// # HTF Group 4 ------------------------------------------------------------- #

htf4_show                                   = input.bool(false, "Show Group 4", group = "HTF Group 4")
htf4_tf                                     = input.timeframe("1D", "Timeframe", group = "HTF Group 4")
htf4_number                                 = input.int(2, "Candles", group = "HTF Group 4", minval = 2, maxval = 30)
htf4_choch_tf                               = input.timeframe("15", "CHoCH TF", group = "HTF Group 4")
htf4_divider                                = input.bool(false, "Divider", group = "HTF Group 4")

// # Styling (Applied to all Groups) ----------------------------------------- #

htf_anticipation_bull_color                 = input.color(colors_green, "Coloring            ", inline = "1.0", group = "Styling")
htf_anticipation_bear_color                 = input.color(colors_black, "", inline = "1.0", group = "Styling")
htf_anticipation_wick_border_color          = input.color(colors_black, "", inline = "1.0", group = "Styling")
htf_anticipation_offset                     = input.int(10, "Offset", minval = 1, group = "Styling", tooltip = "Distance from the current chart candles.")
htf_anticipation_space                      = input.int(2, "Space", minval = 1, maxval = 4, group = "Styling", tooltip = "Space between candles")
htf_anticipation_group_margin               = input.int(5, "Margin", minval = 1, maxval = 20, group = "Styling", tooltip = "Margin between HTF groups")
htf_anticipation_candle_width               = input.string("Small", "Size", group = "Styling", options = ["Tiny", "Small", "Medium", "Large", "Huge"], tooltip = "Candle size")
htf_anticipation_choch_length               = input.int(1, "CHoCH Length", minval = 1, maxval = 50, group = "Styling", tooltip = "Length used for LTF swing detection across all groups")
htf_anticipation_label_show                 = input.bool(true, "Pane Labels", inline = "2.0", group = "Styling")
htf_anticipation_label_size                 = input.string("Large", "", inline = "2.0", group = "Styling", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"])
htf_anticipation_label_color                = input.color(colors_black, "", inline = "2.0", group = "Styling")
htf_anticipation_divider_color              = input.color(color.new(colors_gray, 50), "Divider Color", group = "Styling")

// # Anticipated Candle ------------------------------------------------------ #

htf_anticipation_antic_show                 = input.bool(true, "Anticipated ", inline = "1.0", group = "Anticipated Candle")
htf_anticipation_antic_opacity              = input.int(70, "", inline = "1.0", group = "Anticipated Candle", minval = 10, maxval = 90, tooltip = "Supported Conditions:\n• Sweep H→L ↑: Swept high then low (Outside Bar) → Bullish Anticipation\n• Sweep L→H ↓: Swept low then high (Outside Bar) → Bearish Anticipation\n• Sweep ↓: Swept prev high, closed in range → Bearish Anticipation\n• Sweep ↑: Swept prev low, closed in range → Bullish Anticipation\n• CHoCH ↓: CHoCH in 50-100% zone → Bearish Anticipation\n• CHoCH ↑: CHoCH in 0-50% zone → Bullish Anticipation\n• BOS ↑: Closed beyond prev high → Bullish Anticipation\n• BOS ↓: Closed beyond prev low → Bearish Anticipation\n• Respect ↑: Body respects prev bullish equilibrium → Bullish Continuation\n• Respect ↓: Body respects prev bearish equilibrium → Bearish Continuation\n• Disrespect ↓: Body disrespects prev bullish equilibrium → Bearish Reversal\n• Disrespect ↑: Body disrespects prev bearish equilibrium → Bullish Reversal")
htf_anticipation_antic_label_show           = input.bool(true, "Label", inline = "1.0", group = "Anticipated Candle")

// # Dashboard --------------------------------------------------------------- #

htf_anticipation_dash_show                  = input.bool(true, "Dashboard  ", inline = "1.0", group = "Dashboard")
htf_anticipation_dash_pos                   = input.string("Bottom Center", "", options = ["Bottom Center", "Bottom Right", "Middle Center", "Middle Left", "Middle Right", "Top Center", "Top Left", "Top Right"], inline = "1.0", group = "Dashboard")

// # Alerts ------------------------------------------------------------------ #

htf_anticipation_alert_formed               = input.bool(false, "Anticipation Formed", inline = "1.0", group = "Alerts")

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

type UDT_Quadrant
    float q0     // 0%   — candle low
    float q25    // 25%
    float q50    // 50%  — midpoint
    float q75    // 75%
    float q100   // 100% — candle high

type UDT_Anticipation
    bool  bull             // anticipated direction
    string reason          // human-readable reason
    string scenario        // scenario identifier
    bool  valid = false    // whether an anticipation was detected

type UDT_HTF_Candle
    int    num
    int    index
    string tf
    // real OHLC of HTF candle
    float  o
    float  c
    float  h
    float  l
    int    o_idx
    int    c_idx
    int    h_idx
    int    l_idx
    int    ot              // open time
    int    ct              // close time
    // positioned candle coordinates (for drawing)
    int    candle_left
    int    candle_right
    float  candle_top
    float  candle_bottom
    int    wick_x
    int    shift
    // candle state
    bool   is_closed
    bool   bull
    // quadrant levels
    UDT_Quadrant quadrant
    // CHoCH tracking (LTF swing structure inside this candle)
    float  ltf_swing_high
    float  ltf_swing_low
    bool   choch_bull      // bullish CHoCH detected
    bool   choch_bear      // bearish CHoCH detected
    float  choch_price     // price where CHoCH occurred

type UDT_HTF_Group
    int    id
    bool   show
    string tf
    int    number
    bool   divider
    array<UDT_HTF_Candle> candles
    float  ltf_swing_high
    float  ltf_swing_low
    UDT_Anticipation antic

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

method format_tf(string tf) =>
    string out = tf
    if not str.contains(tf, "D") and not str.contains(tf, "W") and not str.contains(tf, "M")
        float float_tf = str.tonumber(tf)
        if not na(float_tf)
            int int_tf = int(float_tf)
            if int_tf >= 60 and int_tf % 60 == 0
                out := str.tostring(int_tf / 60) + "H"
            else
                out := str.tostring(int_tf) + "m"
    out

method table_position(string pos) =>
    out = switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        => position.bottom_left
    out

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

method candle_size(string size) =>
    out = switch size
        'Tiny'   => 2
        'Small'  => 4
        'Medium' => 6
        'Large'  => 8
        'Huge'   => 10
    out

method set_opacity(color css, int opacity) =>
    blue  = color.b(css)
    red   = color.r(css)
    green = color.g(css)
    color.rgb(red, green, blue, opacity)

method tf_label(string tf) =>
    tfl = tf
    if tfl == ''
        tfl := timeframe.period
    out = switch tfl
        '1'     => '1m'
        '2'     => '2m'
        '3'     => '3m'
        '5'     => '5m'
        '10'    => '10m'
        '15'    => '15m'
        '20'    => '20m'
        '30'    => '30m'
        '45'    => '45m'
        '60'    => '1H'
        '90'    => '90m'
        '120'   => '2H'
        '180'   => '3H'
        '240'   => '4H'
        '480'   => '8H'
        '540'   => '9H'
        '720'   => '12H'
        => tfl
    out

const string default_tz = "America/New_York"
var string anticipation_tz = default_tz

is_bullish_candle(float c, float o, float h, float l) =>
    if c == o
        math.abs(o - h) < math.abs(o - l)
    else
        c > o

get_short_dayofweek(int d) =>
    switch d
        dayofweek.monday => 'MON'
        dayofweek.tuesday => 'TUE'
        dayofweek.wednesday => 'WED'
        dayofweek.thursday => 'THU'
        dayofweek.friday => 'FRI'
        dayofweek.saturday => 'SAT'
        dayofweek.sunday => 'SUN'
        => ''

get_week_of_month(int t) =>
    d  = dayofmonth(t)
    dayIndex = d - 1
    weekIndex = int(dayIndex / 7)
    str.tostring(weekIndex + 1)

get_short_month(int t) =>
    var string[] months = array.from(
         "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
         "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")
    m = month(t)
    m >= 1 and m <= array.size(months) ? array.get(months, m - 1) : ""

method candle_time_label(UDT_HTF_Candle candle) =>
    string lbl = ""
    
    if timeframe.in_seconds(candle.tf) >= timeframe.in_seconds("12M")
        lbl := str.format_time(candle.ot, "yyyy", anticipation_tz)
    else if timeframe.in_seconds(candle.tf) >= timeframe.in_seconds("1M")
        lbl := get_short_month(candle.ot)
    else if timeframe.in_seconds(candle.tf) >= timeframe.in_seconds("1W")
        lbl := get_week_of_month(candle.ot)
    else if timeframe.in_seconds(candle.tf) >= timeframe.in_seconds("1D")
        y = year(candle.ot, anticipation_tz)
        m = month(candle.ot, anticipation_tz)
        d = dayofmonth(candle.ot, anticipation_tz)
        date_ts = timestamp(anticipation_tz, y, m, d, 12, 0, 0)
        date_ts := date_ts + 86400000
        lbl := get_short_dayofweek(dayofweek(date_ts, anticipation_tz))
    else
        lbl := str.format_time(candle.ot, "HH:mm", anticipation_tz)
    
    lbl

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Variables   |
// # ========================================================================= #

//#region

var ltf = timeframe.period
var array<UDT_HTF_Group> htf_groups = array.new<UDT_HTF_Group>()
if barstate.isfirst
    htf_groups.push(UDT_HTF_Group.new(id = 1, show = htf1_show, tf = htf1_tf, number = htf1_number, divider = htf1_divider, candles = array.new<UDT_HTF_Candle>(), ltf_swing_high = na, ltf_swing_low = na, antic = UDT_Anticipation.new()))
    htf_groups.push(UDT_HTF_Group.new(id = 2, show = htf2_show, tf = htf2_tf, number = htf2_number, divider = htf2_divider, candles = array.new<UDT_HTF_Candle>(), ltf_swing_high = na, ltf_swing_low = na, antic = UDT_Anticipation.new()))
    htf_groups.push(UDT_HTF_Group.new(id = 3, show = htf3_show, tf = htf3_tf, number = htf3_number, divider = htf3_divider, candles = array.new<UDT_HTF_Candle>(), ltf_swing_high = na, ltf_swing_low = na, antic = UDT_Anticipation.new()))
    htf_groups.push(UDT_HTF_Group.new(id = 4, show = htf4_show, tf = htf4_tf, number = htf4_number, divider = htf4_divider, candles = array.new<UDT_HTF_Candle>(), ltf_swing_high = na, ltf_swing_low = na, antic = UDT_Anticipation.new()))
var htf_candle_width_val = candle_size(htf_anticipation_candle_width)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Constants   |
// # ========================================================================= #

//#region

// Scenario identifiers
SCENARIO_SWEEP_HL_BULL  = "Sweep H→L ↑"
SCENARIO_SWEEP_LH_BEAR  = "Sweep L→H ↓"
SCENARIO_SWEEP_HIGH     = "Sweep ↓"
SCENARIO_SWEEP_LOW      = "Sweep ↑"
SCENARIO_CHOCH_BEAR     = "CHoCH ↓"
SCENARIO_CHOCH_BULL     = "CHoCH ↑"
SCENARIO_BOS_BULL       = "BOS ↑"
SCENARIO_BOS_LOW        = "BOS ↓"
SCENARIO_RESPECT_BULL   = "Respect ↑"
SCENARIO_RESPECT_BEAR   = "Respect ↓"
SCENARIO_DISRESPECT_BULL = "Disrespect ↓"
SCENARIO_DISRESPECT_BEAR = "Disrespect ↑"

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

// # Session Detection ------------------------------------------------------- #

method session_begins(string tf, string ses, string tz) =>
    ta.change(time(tf, ses, na(tz) ? "" : tz)) != 0

method in_session(string tf, string ses, string tz) =>
    t = time(tf, ses, na(tz) ? "" : tz)
    ct = time_close(tf, ses, na(tz) ? "" : tz)
    not na(t) and not na(ct)

// # Quadrant Calculation ---------------------------------------------------- #

method calculate_quadrants(UDT_HTF_Candle candle) =>
    range_val = candle.h - candle.l
    candle.quadrant := UDT_Quadrant.new(
         q0   = candle.l,
         q25  = candle.l + range_val * 0.25,
         q50  = candle.l + range_val * 0.50,
         q75  = candle.l + range_val * 0.75,
         q100 = candle.h
         )
    candle

// # LTF Swing / CHoCH Detection -------------------------------------------- #

// Detect simple LTF swing points using pivot length
detect_ltf_swing(int len) =>
    float ph = ta.pivothigh(high, len, len)
    float pl = ta.pivotlow(low, len, len)
    
    swing_high = not na(ph)
    swing_low  = not na(pl)
    
    [swing_high, swing_low, ph, pl, close]

// # HTF Candle Detection ---------------------------------------------------- #

method detect_htf_candle(array<UDT_HTF_Candle> candles, string tf, bool sess_begins, bool in_sess) =>
    UDT_HTF_Candle htf_candle = na
    if sess_begins or candles.size() == 0
        UDT_HTF_Candle candle = UDT_HTF_Candle.new(tf = tf, choch_bull = false, choch_bear = false)
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_idx := bar_index
        candle.c_idx := bar_index
        candle.h_idx := bar_index
        candle.l_idx := bar_index
        candle.ot := time
        candle.bull := is_bullish_candle(candle.c, candle.o, candle.h, candle.l)
        candle.calculate_quadrants()
        
        if candles.size() > 0
            last_candle = candles.get(0)
            last_candle.is_closed := true
            last_candle.ct := time
        htf_candle := candle
    else if in_sess and candles.size() > 0
        candle = candles.first()
        candle.c := close
        candle.c_idx := bar_index + 1
        candle.ct := time
        if high > candle.h
            candle.h := high
            candle.h_idx := bar_index
        if low < candle.l
            candle.l := low
            candle.l_idx := bar_index
        candle.bull := is_bullish_candle(candle.c, candle.o, candle.h, candle.l)
        candle.calculate_quadrants()
        // CHoCH detection is done in global scope (Plotting section)
    
    htf_candle

method add_htf_candle(array<UDT_HTF_Candle> candles, UDT_HTF_Candle candle, int total_number) =>
    if not na(candle)
        if candles.size() >= total_number
            candles.pop()
        candles.unshift(candle)
    candles

// # Anticipation Detection -------------------------------------------------- #

method detect_anticipation_between(UDT_HTF_Candle c2, UDT_HTF_Candle c1) =>
    UDT_Anticipation antic = UDT_Anticipation.new()
    
    if not na(c2) and not na(c1)
        // Sweep detection
        sweeps_high     = c2.h > c1.h
        sweeps_low      = c2.l < c1.l
        body_in_range   = c2.c <= c1.h and c2.c >= c1.l and c2.o <= c1.h and c2.o >= c1.l
        sweeps_both     = sweeps_high and sweeps_low and body_in_range
        closes_in_range = c2.c <= c1.h and c2.c >= c1.l
        closes_above    = c2.c > c1.h
        closes_below    = c2.c < c1.l
        
        // Scenario: Outside Bar (Sweeps both)
        if sweeps_both
            if c2.c <= c2.o // Swept high then low (or doji)
                antic.bull     := true
                antic.reason   := "Swept high then low"
                antic.scenario := SCENARIO_SWEEP_HL_BULL
                antic.valid    := true
            else // c2.c > c2.o: Swept low then high
                antic.bull     := false
                antic.reason   := "Swept low then high"
                antic.scenario := SCENARIO_SWEEP_LH_BEAR
                antic.valid    := true
                
        // Scenario 1: Sweep high + close back in range → Bearish
        else if sweeps_high and closes_in_range
            antic.bull     := false
            antic.reason   := "Swept prev high, closed in range"
            antic.scenario := SCENARIO_SWEEP_HIGH
            antic.valid    := true
        
        // Scenario 2: Sweep low + close back in range → Bullish
        else if sweeps_low and closes_in_range
            antic.bull     := true
            antic.reason   := "Swept prev low, closed in range"
            antic.scenario := SCENARIO_SWEEP_LOW
            antic.valid    := true
        
        // Scenario 5: Close beyond prev high → Bullish
        else if closes_above
            antic.bull     := true
            antic.reason   := "Closed beyond prev high"
            antic.scenario := SCENARIO_BOS_BULL
            antic.valid    := true
        
        // Scenario 6: Close beyond prev low → Bearish
        else if closes_below
            antic.bull     := false
            antic.reason   := "Closed beyond prev low"
            antic.scenario := SCENARIO_BOS_LOW
            antic.valid    := true
        
        // Scenarios 3 & 4: No sweep, check CHoCH
        else if not sweeps_high and not sweeps_low
            // Scenario 3: CHoCH in 50-100% zone → Bearish (target PDL)
            if c2.choch_bear
                antic.bull     := false
                antic.reason   := "CHoCH in 50-100% zone → target PDL"
                antic.scenario := SCENARIO_CHOCH_BEAR
                antic.valid    := true
            
            // Scenario 4: CHoCH in 0-50% zone → Bullish (target PDH)
            else if c2.choch_bull
                antic.bull     := true
                antic.reason   := "CHoCH in 0-50% zone → target PDH"
                antic.scenario := SCENARIO_CHOCH_BULL
                antic.valid    := true
        
        // Scenario: Body Respect (lowest priority fallback)
        // Current candle body respects prev candle equilibrium → continuation
        if not antic.valid and not na(c1.quadrant)
            float eq = c1.quadrant.q50
            if c1.bull
                // Prev was bullish: if current close is above equilibrium → bullish continuation
                if c2.c >= eq
                    antic.bull     := true
                    antic.reason   := "Body respects prev bullish equilibrium"
                    antic.scenario := SCENARIO_RESPECT_BULL
                    antic.valid    := true
                else
                    antic.bull     := false
                    antic.reason   := "Body disrespects prev bullish equilibrium"
                    antic.scenario := SCENARIO_DISRESPECT_BULL
                    antic.valid    := true
            else
                // Prev was bearish: if current close is below equilibrium → bearish continuation
                if c2.c <= eq
                    antic.bull     := false
                    antic.reason   := "Body respects prev bearish equilibrium"
                    antic.scenario := SCENARIO_RESPECT_BEAR
                    antic.valid    := true
                else
                    antic.bull     := true
                    antic.reason   := "Body disrespects prev bearish equilibrium"
                    antic.scenario := SCENARIO_DISRESPECT_BEAR
                    antic.valid    := true
    
    antic

method detect_anticipation(array<UDT_HTF_Candle> candles) =>
    UDT_Anticipation antic = UDT_Anticipation.new()
    
    if candles.size() >= 2
        antic := detect_anticipation_between(candles.get(0), candles.get(1))
        
    antic

// # Positioning ------------------------------------------------------------- #

get_htf_candle_shift(int candle_index, int offset, int buffer, int width, int candles_amount) =>
    offset + (width + buffer) * (candles_amount - candle_index - 1)

method position_htf_candle(UDT_HTF_Candle candle, int candle_index, int offset, int buffer, int width, int candles_amount) =>
    candle.shift := get_htf_candle_shift(candle_index, offset, buffer, width, candles_amount)
    candle.candle_left := last_bar_index + candle.shift
    candle.candle_right := candle.candle_left + width
    candle.candle_top := math.max(candle.o, candle.c)
    candle.candle_bottom := math.min(candle.o, candle.c)
    candle.wick_x := candle.candle_left + width / 2
    candle

method position_htf_candles(array<UDT_HTF_Candle> candles, int shift) =>
    candles_amount = candles.size()
    for [index, candle] in candles
        candle.position_htf_candle(index, shift, htf_anticipation_space, htf_candle_width_val, candles_amount)

// # Build Anticipated Candle ------------------------------------------------ #

method build_anticipated_candle(array<UDT_HTF_Candle> candles, UDT_Anticipation antic) =>
    UDT_HTF_Candle antic_candle = na
    
    if antic.valid and candles.size() >= 2
        // Calculate average body size from last 3 candles (or fewer)
        float body_sum = 0.0
        int count = 0
        int limit = math.min(3, candles.size())
        for i = 0 to limit - 1
            c = candles.get(i)
            body_sum += math.abs(c.c - c.o)
            count += 1
        
        float avg_body = count > 0 ? body_sum / count : 0.0
        // Calculate average wick size from last 3 candles
        float wick_sum = 0.0
        for i = 0 to limit - 1
            c = candles.get(i)
            wick_sum += (c.h - c.l) - math.abs(c.c - c.o)
        float avg_wick = count > 0 ? wick_sum / count / 2 : 0.0
        
        c_last = candles.get(0)
        
        float antic_open = c_last.c  // anticipated candle opens at current close
        float antic_close = antic.bull ? antic_open + avg_body : antic_open - avg_body
        float antic_high = math.max(antic_open, antic_close) + avg_wick
        float antic_low  = math.min(antic_open, antic_close) - avg_wick
        
        antic_candle := UDT_HTF_Candle.new(tf = c_last.tf, o = antic_open, c = antic_close, h = antic_high, l = antic_low, bull = antic.bull, is_closed = false, ot = na, ct = na)
        
        // Position the anticipated candle 1 slot to the right of the newest real candle
        // The newest real candle (index 0) already has its position set by position_htf_candles
        antic_candle.candle_left  := c_last.candle_right + htf_anticipation_space
        antic_candle.candle_right := antic_candle.candle_left + htf_candle_width_val
        antic_candle.candle_top   := math.max(antic_open, antic_close)
        antic_candle.candle_bottom := math.min(antic_open, antic_close)
        antic_candle.wick_x       := antic_candle.candle_left + htf_candle_width_val / 2
        antic_candle.shift        := c_last.shift + htf_candle_width_val + htf_anticipation_space
    
    antic_candle

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Drawing Methods   |
// # ========================================================================= #

//#region

// # Draw HTF Candle --------------------------------------------------------- #

method draw_htf_candle(UDT_HTF_Candle candle) =>
    candle_color = candle.bull ? htf_anticipation_bull_color : htf_anticipation_bear_color
    bin.bin_box.push(box.new(left = candle.candle_left, top = candle.candle_top, right = candle.candle_right, bottom = candle.candle_bottom, border_color = htf_anticipation_wick_border_color, border_width = 1, bgcolor = candle_color))
    bin.bin_ln.push(line.new(x1 = candle.wick_x, y1 = candle.h, x2 = candle.wick_x, y2 = candle.candle_top, color = htf_anticipation_wick_border_color))
    bin.bin_ln.push(line.new(x1 = candle.wick_x, y1 = candle.candle_bottom, x2 = candle.wick_x, y2 = candle.l, color = htf_anticipation_wick_border_color))
    
    bin.bin_ln.push(line.new(x1 = candle.wick_x, y1 = candle.quadrant.q50, x2 = candle.candle_right + htf_anticipation_space + htf_candle_width_val, y2 = candle.quadrant.q50, color = colors_gray, style = line.style_dotted, width = 1))
    candle

// # Draw Anticipated Candle ------------------------------------------------- #

method draw_anticipated_candle(UDT_HTF_Candle antic_candle, UDT_Anticipation antic) =>
    if htf_anticipation_antic_show and not na(antic_candle) and antic.valid
        candle_color = antic_candle.bull ? htf_anticipation_bull_color : htf_anticipation_bear_color
        transparent_color = set_opacity(candle_color, htf_anticipation_antic_opacity)
        border_color = set_opacity(htf_anticipation_wick_border_color, htf_anticipation_antic_opacity)
        
        // Body
        bin.bin_box.push(box.new(left = antic_candle.candle_left, top = antic_candle.candle_top, right = antic_candle.candle_right, bottom = antic_candle.candle_bottom, border_color = border_color, border_width = 1, bgcolor = transparent_color))
        // Wick top
        bin.bin_ln.push(line.new(x1 = antic_candle.wick_x, y1 = antic_candle.h, x2 = antic_candle.wick_x, y2 = antic_candle.candle_top, color = border_color))
        // Wick bottom
        bin.bin_ln.push(line.new(x1 = antic_candle.wick_x, y1 = antic_candle.candle_bottom, x2 = antic_candle.wick_x, y2 = antic_candle.l, color = border_color))
        
        // Label
        if htf_anticipation_antic_label_show
            label_y = antic_candle.bull ? antic_candle.l : antic_candle.h
            label_style = antic_candle.bull ? label.style_label_up : label.style_label_down
            bin.bin_lbl.push(label.new(x = antic_candle.wick_x, y = label_y, text = antic.scenario, xloc = xloc.bar_index, color = color_transparent, style = label_style, textcolor = set_opacity(htf_anticipation_label_color, htf_anticipation_antic_opacity / 2), size = text_size("Tiny"), text_font_family = font_style(general_font), tooltip = antic.reason))
    antic_candle

// # Draw HTF Sweeps / BOS --------------------------------------------------- #

method draw_htf_sweeps(array<UDT_HTF_Candle> candles) =>
    if candles.size() >= 2
        for i = 0 to candles.size() - 2
            c_curr = candles.get(i)
            c_prev = candles.get(i + 1)
            
            sweeps_high     = c_curr.h > c_prev.h
            sweeps_low      = c_curr.l < c_prev.l
            is_closed       = c_curr.is_closed
            closes_in_range = c_curr.c <= c_prev.h and c_curr.c >= c_prev.l
            
            valid_sweep_high = sweeps_high and (not is_closed or closes_in_range)
            valid_sweep_low  = sweeps_low  and (not is_closed or closes_in_range)
            
            closes_above    = c_curr.c > c_prev.h and is_closed
            closes_below    = c_curr.c < c_prev.l and is_closed
            
            if valid_sweep_high
                bin.bin_ln.push(line.new(x1 = c_prev.wick_x, y1 = c_prev.h, x2 = c_curr.wick_x, y2 = c_prev.h, color = htf_anticipation_wick_border_color, style = line.style_solid))
            else if closes_above
                bin.bin_ln.push(line.new(x1 = c_prev.wick_x, y1 = c_prev.h, x2 = c_curr.wick_x, y2 = c_prev.h, color = htf_anticipation_wick_border_color, style = line.style_dashed))
                
            if valid_sweep_low
                bin.bin_ln.push(line.new(x1 = c_prev.wick_x, y1 = c_prev.l, x2 = c_curr.wick_x, y2 = c_prev.l, color = htf_anticipation_wick_border_color, style = line.style_solid))
            else if closes_below
                bin.bin_ln.push(line.new(x1 = c_prev.wick_x, y1 = c_prev.l, x2 = c_curr.wick_x, y2 = c_prev.l, color = htf_anticipation_wick_border_color, style = line.style_dashed))
    candles

// # Draw HTF Labels --------------------------------------------------------- #

method format_duration(int ms) =>
    int s = math.max(0, math.floor(ms / 1000))
    int m = math.floor(s / 60)
    int h = math.floor(m / 60)
    int d = math.floor(h / 24)
    string res = ""
    if d > 0
        res += str.tostring(d) + "d "
    if h % 24 > 0
        res += str.tostring(h % 24) + "h "
    if m % 60 > 0 or (d == 0 and h == 0)
        res += str.tostring(m % 60) + "m"
    res

method draw_htf_labels(array<UDT_HTF_Candle> candles, string tf, UDT_HTF_Candle antic_candle) =>
    float y_top = na
    float y_bottom = na
    int x_min = na
    int x_max = na
    
    for [index, candle] in candles
        y_top := na(y_top) ? candle.h : math.max(y_top, candle.h)
        y_bottom := na(y_bottom) ? candle.l : math.min(y_bottom, candle.l)
        x_min := na(x_min) ? candle.wick_x : math.min(x_min, candle.wick_x)
        x_max := na(x_max) ? candle.wick_x : math.max(x_max, candle.wick_x)
        // Time label below each candle
        txt = candle.candle_time_label()
        bin.bin_lbl.push(label.new(x = candle.wick_x, y = candle.l, text = txt, tooltip = str.format("HTF candle open\n{0}", str.format_time(candle.ot, "yyyy-MM-dd HH:mm Z", anticipation_tz)), xloc = xloc.bar_index, color = color_transparent, style = label.style_label_up, textcolor = htf_anticipation_label_color, size = text_size("Tiny"), text_font_family = font_style(general_font)))
    
    // Include anticipated candle in positioning
    if htf_anticipation_antic_show and not na(antic_candle)
        y_top := na(y_top) ? antic_candle.h : math.max(y_top, antic_candle.h)
        y_bottom := na(y_bottom) ? antic_candle.l : math.min(y_bottom, antic_candle.l)
        x_min := na(x_min) ? antic_candle.wick_x : math.min(x_min, antic_candle.wick_x)
        x_max := na(x_max) ? antic_candle.wick_x : math.max(x_max, antic_candle.wick_x)

    x = math.round(math.avg(x_min, x_max))
    txt = tf_label(tf)
    
    if not na(y_top)
        string time_txt = ""
        if barstate.isrealtime
            int close_time = time_close(tf)
            if not na(close_time)
                int remaining_ms = close_time - timenow
                if remaining_ms > 0
                    time_txt := format_duration(remaining_ms)
        
        if time_txt != ""
            // Layer 1: Timeframe (Top)
            bin.bin_lbl.push(label.new(x = x, y = y_top, text = txt + "\n ", tooltip = str.format("HTF {0}", txt), xloc = xloc.bar_index, color = color_transparent, style = label.style_label_down, textcolor = htf_anticipation_label_color, size = text_size(htf_anticipation_label_size), text_font_family = font_style(general_font)))
            // Layer 2: Time Remaining (Bottom)
            bin.bin_lbl.push(label.new(x = x, y = y_top, text = time_txt + "\n ", xloc = xloc.bar_index, color = color_transparent, style = label.style_label_down, textcolor = set_opacity(htf_anticipation_label_color, 40), size = text_size("Tiny"), text_font_family = font_style(general_font)))
        else
            // Just timeframe
            bin.bin_lbl.push(label.new(x = x, y = y_top, text = txt + "\n ", tooltip = str.format("HTF {0}", txt), xloc = xloc.bar_index, color = color_transparent, style = label.style_label_down, textcolor = htf_anticipation_label_color, size = text_size(htf_anticipation_label_size), text_font_family = font_style(general_font)))
    
    candles

// # Draw All HTF Candles ---------------------------------------------------- #

method plot_htf(array<UDT_HTF_Candle> candles, string tf, UDT_Anticipation antic) =>
    // Build anticipated candle first (needed for positioning)
    antic_candle = candles.build_anticipated_candle(antic)
    
    // Draw all candles
    for [index, candle] in candles
        candle.draw_htf_candle()
    
    // Draw sweeps and BOS lines
    candles.draw_htf_sweeps()
    
    // Draw anticipated candle
    antic_candle.draw_anticipated_candle(antic)
    
    // Draw labels
    if htf_anticipation_label_show
        candles.draw_htf_labels(tf, antic_candle)
    
    candles

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Alert Methods   |
// # ========================================================================= #

//#region

method enable_anticipation_alert(UDT_Anticipation antic) =>
    if antic.valid and htf_anticipation_alert_formed
        direction = antic.bull ? "Bullish" : "Bearish"
        alert(str.format("{0} anticipation on {1}: {2} ({3})", direction, syminfo.ticker, antic.scenario, antic.reason))
    antic

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Plotting   |
// # ========================================================================= #

//#region

bin.clean_bin()

// Pre-evaluate session states to ensure Pine allocates separate buffers for each timeframe!
bool htf1_sess_begins = session_begins(htf1_tf, "", na)
bool htf1_in_sess     = in_session(htf1_tf, "", na)

bool htf2_sess_begins = session_begins(htf2_tf, "", na)
bool htf2_in_sess     = in_session(htf2_tf, "", na)

bool htf3_sess_begins = session_begins(htf3_tf, "", na)
bool htf3_in_sess     = in_session(htf3_tf, "", na)

bool htf4_sess_begins = session_begins(htf4_tf, "", na)
bool htf4_in_sess     = in_session(htf4_tf, "", na)

// Detect LTF swings from the requested CHoCH timeframes
[htf1_sh, htf1_sl, htf1_shp, htf1_slp, htf1_c] = request.security(syminfo.tickerid, htf1_choch_tf, detect_ltf_swing(htf_anticipation_choch_length))
[htf2_sh, htf2_sl, htf2_shp, htf2_slp, htf2_c] = request.security(syminfo.tickerid, htf2_choch_tf, detect_ltf_swing(htf_anticipation_choch_length))
[htf3_sh, htf3_sl, htf3_shp, htf3_slp, htf3_c] = request.security(syminfo.tickerid, htf3_choch_tf, detect_ltf_swing(htf_anticipation_choch_length))
[htf4_sh, htf4_sl, htf4_shp, htf4_slp, htf4_c] = request.security(syminfo.tickerid, htf4_choch_tf, detect_ltf_swing(htf_anticipation_choch_length))

int current_offset = htf_anticipation_offset

for i = 0 to htf_groups.size() - 1
    group = htf_groups.get(i)
    
    bool sess_begins = i == 0 ? htf1_sess_begins : i == 1 ? htf2_sess_begins : i == 2 ? htf3_sess_begins : htf4_sess_begins
    bool in_sess     = i == 0 ? htf1_in_sess : i == 1 ? htf2_in_sess : i == 2 ? htf3_in_sess : htf4_in_sess
    
    bool is_swing_high = i == 0 ? htf1_sh : i == 1 ? htf2_sh : i == 2 ? htf3_sh : htf4_sh
    bool is_swing_low  = i == 0 ? htf1_sl : i == 1 ? htf2_sl : i == 2 ? htf3_sl : htf4_sl
    float sh_price     = i == 0 ? htf1_shp : i == 1 ? htf2_shp : i == 2 ? htf3_shp : htf4_shp
    float sl_price     = i == 0 ? htf1_slp : i == 1 ? htf2_slp : i == 2 ? htf3_slp : htf4_slp
    float choch_close  = i == 0 ? htf1_c : i == 1 ? htf2_c : i == 2 ? htf3_c : htf4_c
    
    if group.show and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(group.tf)
        if sess_begins and group.divider
            line.new(bar_index, low, bar_index, math.max(high, low + syminfo.mintick), extend = extend.both, color = htf_anticipation_divider_color, style = line.style_solid)
            
        htf_candle = group.candles.detect_htf_candle(group.tf, sess_begins, in_sess)
        group.candles.add_htf_candle(htf_candle, group.number)
        
        if group.candles.size() > 0
            active_candle = group.candles.first()
            if not na(active_candle) and not active_candle.is_closed
                // Reset swings on new HTF candle
                if not na(htf_candle)
                    group.ltf_swing_high := na
                    group.ltf_swing_low  := na
                
                // Update swings for this group
                if is_swing_high
                    group.ltf_swing_high := sh_price
                if is_swing_low
                    group.ltf_swing_low := sl_price
                
                // Bearish CHoCH: price breaks below the last LTF swing low (in 50-100% zone)
                if not na(group.ltf_swing_low) and not active_candle.choch_bear
                    if choch_close < group.ltf_swing_low
                        q = active_candle.quadrant
                        if not na(q) and group.ltf_swing_low >= q.q50 and group.ltf_swing_low <= q.q100
                            active_candle.choch_bear := true
                            active_candle.choch_price := group.ltf_swing_low
                
                // Bullish CHoCH: price breaks above the last LTF swing high (in 0-50% zone)
                if not na(group.ltf_swing_high) and not active_candle.choch_bull
                    if choch_close > group.ltf_swing_high
                        q = active_candle.quadrant
                        if not na(q) and group.ltf_swing_high >= q.q0 and group.ltf_swing_high <= q.q50
                            active_candle.choch_bull := true
                            active_candle.choch_price := group.ltf_swing_high
        
        // Detect anticipation on every bar
        group.antic := group.candles.detect_anticipation()
        
        // Alert on HTF candle close
        if barstate.isconfirmed
            if sess_begins
                group.antic.enable_anticipation_alert()
        
        // Draw
        if barstate.islast
            group.candles.position_htf_candles(current_offset)
            group.candles.plot_htf(group.tf, group.antic)
            
            // Advance offset dynamically for the next group
            // We shift by the total width of all candles + 1 (the anticipated candle) + margins
            current_offset += (group.number + 1) * (htf_candle_width_val + htf_anticipation_space) + htf_anticipation_group_margin

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #




 


 


 

// # ========================================================================= #
// # |   Dashboard   |
// # ========================================================================= #

//#region

if barstate.islast and htf_anticipation_dash_show
    string dash_pos = table_position(htf_anticipation_dash_pos)
    
    var table dash = table.new(dash_pos, 2, 5, bgcolor = color.new(chart.bg_color, 20), border_width = 1, border_color = color.new(colors_gray, 80))
    table.clear(dash, 0, 0, 1, 4)
    
    // Header
    table.cell(dash, 0, 0, "HTF", text_color = htf_anticipation_label_color, text_size = size.small, text_halign = text.align_center)
    table.cell(dash, 1, 0, "Anticipation Stage", text_color = htf_anticipation_label_color, text_size = size.small, text_halign = text.align_center)
    
    int row = 1
    for group in htf_groups
        if group.show
            string stage = "Waiting"
            color stage_color = colors_gray
            
            if not na(group.antic) and group.antic.valid
                stage := group.antic.scenario
                stage_color := group.antic.bull ? htf_anticipation_bull_color : htf_anticipation_bear_color
                
                // Prepend previous stage if available
                if group.candles.size() >= 3
                    UDT_Anticipation prev_antic = detect_anticipation_between(group.candles.get(1), group.candles.get(2))
                    if not na(prev_antic) and prev_antic.valid
                        stage := prev_antic.scenario + " → " + stage
            
            table.cell(dash, 0, row, group.tf.format_tf(), text_color = htf_anticipation_label_color, text_size = size.small, text_halign = text.align_center)
            table.cell(dash, 1, row, stage, text_color = stage_color, text_size = size.small, text_halign = text.align_center)
            row += 1

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
