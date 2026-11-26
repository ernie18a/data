# CandelaCharts - HTF Mappings

- url: https://www.tradingview.com/script/arDayOwS-CandelaCharts-HTF-Mappings/
- type: indicator
- pine_id: PUB;3d10f240bbcc4ed1b499d030e04799af
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - HTF Mappings[/b] indicator seamlessly overlays higher timeframe (HTF) candles directly onto your current chart. It allows traders to visualize the broader market context without switching timeframes, making it easier to spot macro trends, support/resistance, and price action dynamics.

📦 [b]Features[/b]

[list]
[*] [b]Dual HTF Overlays[/b]: Display up to two distinct higher timeframe candles simultaneously.
[*] [b]Right-Side Panel[/b]: View the current state of your selected HTFs elegantly displayed on the right margin.
[*] [b]Volatility-Adjusted Opacity[/b]: Candle bodies dynamically adjust their opacity based on the Average True Range (ATR), giving you a visual representation of market volatility.
[*] [b]Historical Candles[/b]: Project a defined number of past HTF candles to analyze previous price action on a macro level.
[*] [b]HTF Sweeps[/b]: Automatically detect and project liquidity sweep lines from mapped HTF candles. Sweeps precisely anchor to the HTF high/low wicks and persist until crossed by current price action.
[*] [b]Trend Lines[/b]: Optionally draw a trend line connecting the open and close prices within each mapped HTF candle to track internal momentum.
[*] [b]Customizable Visuals[/b]: Full control over colors, wick widths, vertical separators, and timeframe/time labels.
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Timezone[/b]: Set the timezone used for displaying candle timestamps.
[*] [b]HTF I & II[/b]: Configure the timeframes, historical count, colors (bull/bear, body/border), wicks, separators, trend lines, and label visibilities for each HTF.
[*] [b]Sweeps[/b]: Customize sweep line colors, width, styling, and selectively display or hide invalidated (crossed) sweeps.
[*] [b]HTF Settings[/b]: Adjust the position, spacing, margin, and size of the right-side HTF panel.
[/list]

⚡️ [b]Showcase[/b]

[i]Mapped HTF Candles[/i]
https://www.tradingview.com/x/ynD8wA4K/

[i]HTF Sweeps[/i]
https://www.tradingview.com/x/eKDFp7RZ/

[i]HTF Overlays with Trend Lines[/i]
https://www.tradingview.com/x/mTs8wfJX/

[i]Dual HTF Overlays[/i]
https://www.tradingview.com/x/32K1qrMK/

🚨 [b]Alerts[/b]

[list]
[*] [b]New HTF Candle[/b]: Triggers an alert whenever a new higher timeframe candle opens, keeping you updated on macro shifts without having to constantly monitor the chart.
[/list]

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - HTF Mappings", shorttitle = "CandelaCharts - HTF Mappings", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000, max_polylines_count = 100)













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

general_font         = input.string("Monospace", "Text                      ", inline = "1.0", options = ["Default", "Monospace"], group = "General")
general_text         = input.string("Tiny", "", inline = "1.0", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = "General", tooltip = "Customize global text size and style")
general_brand_show   = input.bool(false, "Hide Brand", group = "General")

hm_timezone           = input.string("America/New_York", "Timezone", group = "Timezone", options = ["Exchange", "UTC", "America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo"], tooltip = "Timezone to display candle timestamps in.")

hm_show_candle        = input.bool(false,  "Show HTF Candle", group = "HTF I")
hm_htf                = input.timeframe("240", "Higher Timeframe  ", group = "HTF I", tooltip = "The higher timeframe to map onto your current chart.")
hm_htf_history        = input.int(6, "History Count  ", group = "HTF I", minval = 1, maxval = 50, tooltip = "Number of historical HTF candles to display.")
hm_bull_body_css      = input.color(color.new(colors_teal, 70), "HTF Candle Colors   ", inline = "1.0", group = "HTF I")
hm_bear_body_css      = input.color(color.new(colors_red, 70), "", inline = "1.0", group = "HTF I")
hm_bull_border_css    = input.color(color.new(colors_teal, 30), "", inline = "1.0", group = "HTF I")
hm_bear_border_css    = input.color(color.new(colors_red, 30), "", inline = "1.0", group = "HTF I")
hm_wick_width         = input.int(1, "Wick Width  ", group = "HTF I", minval = 1, maxval = 4)
hm_show_sep           = input.bool(true,  "Show Separator", inline = "2.0", group = "HTF I")
hm_sep_style          = input.string("····", "", inline = "2.0", group = "HTF I", options = ["⎯⎯⎯", "----", "····"])
hm_sep_width          = input.int(1, "", inline = "2.0", group = "HTF I", minval = 1, maxval = 4)
hm_sep_css            = input.color(color.new(colors_gray, 70), "", inline = "2.0", group = "HTF I")
hm_show_tf_label      = input.bool(true,  "Show TF Label  ", inline = "3.0", group = "HTF I")
hm_lbl_size           = input.string("Small", "", inline = "3.0", group = "HTF I", options = ["Tiny", "Small", "Normal", "Large"])
hm_show_time_lbl      = input.bool(true,  "Show Time Label", group = "HTF I", tooltip = "Show start and end time inside the HTF candle.")
hm_show_trend         = input.bool(false,  "Show Trend Line", group = "HTF I")

hm_show_candle2       = input.bool(true,  "Show HTF Candle", group = "HTF II")
hm_htf2               = input.timeframe("D", "Higher Timeframe  ", group = "HTF II", tooltip = "The second higher timeframe to map onto your current chart.")
hm_htf2_history       = input.int(2, "History Count  ", group = "HTF II", minval = 1, maxval = 50, tooltip = "Number of historical HTF 2 candles to display.")
hm_bull2_body_css     = input.color(color.new(colors_silver, 70), "HTF Candle Colors   ", inline = "1.0", group = "HTF II")
hm_bear2_body_css     = input.color(color.new(colors_silver, 70), "", inline = "1.0", group = "HTF II")
hm_bull2_border_css   = input.color(color.new(colors_silver, 30), "", inline = "1.0", group = "HTF II")
hm_bear2_border_css   = input.color(color.new(colors_silver, 30), "", inline = "1.0", group = "HTF II")
hm_wick2_width        = input.int(1, "Wick Width  ", group = "HTF II", minval = 1, maxval = 4)
hm_show_sep2          = input.bool(true,  "Show Separator", inline = "2.0", group = "HTF II")
hm_sep2_style         = input.string("····", "", inline = "2.0", group = "HTF II", options = ["⎯⎯⎯", "----", "····"])
hm_sep2_width         = input.int(1, "", inline = "2.0", group = "HTF II", minval = 1, maxval = 4)
hm_sep2_css           = input.color(color.new(colors_gray, 70), "", inline = "2.0", group = "HTF II")
hm_show_tf_label2     = input.bool(true,  "Show TF Label  ", inline = "3.0", group = "HTF II")
hm_lbl_size2          = input.string("Small", "", inline = "3.0", group = "HTF II", options = ["Tiny", "Small", "Normal", "Large"])
hm_show_time_lbl2     = input.bool(true,  "Show Time Label", group = "HTF II", tooltip = "Show start and end time inside the HTF 2 candle.")
hm_show_trend2        = input.bool(true,  "Show Trend Line", group = "HTF II")

hm_sweep_show         = input.bool(true, "Show Sweeps   ", inline = "1.0", group = "Sweeps")
hm_sweep_style        = input.string('⎯⎯⎯', "", inline = "1.0", options = ['⎯⎯⎯', '----', '····'], group = "Sweeps")
hm_sweep_width        = input.int(1, '', inline = "1.0", group = "Sweeps")
hm_sweep_color        = input.color(colors_black, "", inline = "1.0", group = "Sweeps")
hm_isweep_show        = input.bool(false, "Show I-Sweeps ", inline = "2.0", group = "Sweeps", tooltip = "Show invalidated sweeps")
hm_isweep_style       = input.string('----', "", options = ['⎯⎯⎯', '----', '····'], inline = "2.0", group = "Sweeps")
hm_isweep_width       = input.int(1, '', inline = "2.0", group = "Sweeps")
hm_isweep_color       = input.color(colors_gray, "", inline = "2.0", group = "Sweeps")

hm_right_offset       = input.int(20, "Offset                      ", minval = 1, inline = "1.0", group = "HTF Settings")
hm_right_space        = input.int(1, "Space                      ", minval = 1, maxval = 4, inline = "2.0", group = "HTF Settings")
hm_right_margin       = input.int(10, "Margin                     ", minval = 1, inline = "3.0", group = "HTF Settings")
hm_right_candle_width = input.string("Small", "Size                         ", inline = "4.0", group = "HTF Settings", options = ["Tiny", "Small", "Medium", "Large", "Huge"])

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type UDT_Sweep
    int x1
    float y
    int x2
    bool bull
    bool invalidated = false
    int invalidated_on
    bool removed = false
    bool formed = false

type UDT_HTF_Candle
    float   o
    float   h
    float   l
    float   c
    int     start_idx
    int     end_idx
    int     start_time
    int     end_time
    bool    is_bull
    bool    is_closed
    float   atr
    int     h_idx
    int     l_idx
    bool    bull_sweep
    bool    bear_sweep
    array<UDT_Sweep> sweeps
    array<UDT_Sweep> mapped_sweeps

type UDT_Store
    array<UDT_HTF_Candle> candles
    array<box>            boxes
    array<line>           lines
    array<label>          labels

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Variables / Constants   |
// # ========================================================================= #

//#region

const int MAX_HTF_CANDLES = 50

// HTF data via request.security
[htf_o, htf_h, htf_l, htf_c, htf_t, htf_tc, htf_atr] = request.security(syminfo.tickerid, hm_htf, [open, high, low, close, time, time_close, ta.atr(14)], lookahead = barmerge.lookahead_on)
[htf2_o, htf2_h, htf2_l, htf2_c, htf2_t, htf2_tc, htf2_atr] = request.security(syminfo.tickerid, hm_htf2, [open, high, low, close, time, time_close, ta.atr(14)], lookahead = barmerge.lookahead_on)

// Detect new HTF candle
bool is_new_htf = ta.change(htf_t) != 0
bool is_new_htf2 = ta.change(htf2_t) != 0

// Storage
var array<UDT_HTF_Candle> g_htf_candles = array.new<UDT_HTF_Candle>(0)
var array<UDT_HTF_Candle> g_htf2_candles = array.new<UDT_HTF_Candle>(0)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store g_store = UDT_Store.new(
     array.new<UDT_HTF_Candle>(0),
     array.new<box>(0),
     array.new<line>(0),
     array.new<label>(0)
 )

method clean_drawings(UDT_Store store) =>
    for obj in store.boxes
        obj.delete()
    for obj in store.lines
        obj.delete()
    for obj in store.labels
        obj.delete()
    store.boxes.clear()
    store.lines.clear()
    store.labels.clear()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Functions / Utils  |
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
        =>          size.small
    out

method candle_size(string size) =>
    out = switch size
        'Tiny'   => 2
        'Small'  => 4
        'Medium' => 6
        'Large'  => 8
        'Huge'   => 10
    out

method line_style(string line) =>
    out = switch line
        '⎯⎯⎯'  => line.style_solid
        '----'   => line.style_dashed
        '····'   => line.style_dotted
        =>          line.style_dashed
    out

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace
        =>             font.family_monospace
    out

method set_opacity(color css, int opacity) =>
    blue  = color.b(css)
    red   = color.r(css)
    green = color.g(css)
    color.rgb(red, green, blue, opacity)

format_tf(string tf) =>
    string res = tf
    if tf == "D" or tf == "1D"
        res := "1D"
    else if tf == "W" or tf == "1W"
        res := "1W"
    else if tf == "M" or tf == "1M"
        res := "1M"
    else
        float min_f = str.tonumber(tf)
        if not na(min_f)
            int mins = int(min_f)
            if mins < 60
                res := str.tostring(mins) + "m"
            else if mins >= 60 and mins % 60 == 0
                res := str.tostring(mins / 60) + "H"
            else
                res := str.tostring(mins) + "m"
    res

get_shift(int c_index, int offset, int buffer, int width, int c_amount) =>
    offset + (width + buffer) * (c_amount - c_index - 1)

method invalidate_sweep(UDT_Sweep sweep, UDT_HTF_Candle c2) =>
    c2_bull = c2.is_bull
    invalidated = not na(sweep.y) and (sweep.bull ? (c2_bull ? sweep.y < c2.c : sweep.y < c2.o) : (c2_bull ? sweep.y > c2.o : sweep.y > c2.c))
    invalidated

method invalidate_sweeps(array<UDT_HTF_Candle> htf_candles) =>
    count = htf_candles.size()
    if count > 1
        for i = count - 1 to 1
            c1 = htf_candles.get(i)
            for [j, sweep] in c1.mapped_sweeps
                if not sweep.removed and na(sweep.invalidated_on)
                    sweep.invalidated := false
                    htf_sweep = c1.sweeps.get(j)
                    htf_sweep.invalidated := false
                    for k = i - 1 to 0
                        c2 = htf_candles.get(k)
                        invalidated = sweep.invalidate_sweep(c2)
                        if invalidated
                            if not c2.is_closed
                                sweep.invalidated := true
                                htf_sweep.invalidated := true
                            else
                                sweep.invalidated := true
                                sweep.invalidated_on := c2.start_idx
                                htf_sweep.invalidated := true
                                htf_sweep.invalidated_on := c2.start_idx
                                break
                c2 = htf_candles.get(i - 1)     
                if not sweep.formed and not sweep.removed
                    if c2.is_closed
                        htf_sweep = c1.sweeps.get(j)
                        if sweep.invalidated and not na(sweep.invalidated_on)
                            if not sweep.formed
                                sweep.removed := true
                                htf_sweep.removed := true
                        else
                            if not sweep.formed
                                sweep.formed := true
                                htf_sweep.formed := true
    htf_candles

method detect_sweep(UDT_HTF_Candle c1, UDT_HTF_Candle c2) =>
    c1_bull = c1.is_bull
    c2_bull = c2.is_bull
    
    bull_sweep_in_range = c2_bull ? (c1_bull ? (c2.c < c1.h) : (c2.c < c1.h)) : (c1_bull ? (c2.o < c1.h) : (c2.o < c1.h))
    is_bull_sweep = c2.h > c1.h and bull_sweep_in_range
    
    bear_sweep_in_range = c2_bull ? (c1_bull ? (c2.o > c1.l) : (c2.o > c1.l)) : (c1_bull ? (c2.c > c1.l) : (c2.c > c1.l))
    is_bear_sweep = c2.l < c1.l and bear_sweep_in_range
    
    if is_bull_sweep 
        if not c1.bull_sweep
            htf_sweep = UDT_Sweep.new(x1=c1.h_idx, x2=c2.end_idx, y=c1.h, bull=true)
            mid_x = math.round(math.avg(c1.start_idx, c1.end_idx))
            mapped_sweep = UDT_Sweep.new(x1=mid_x, x2=c2.end_idx, y=c1.h, bull=true)
            c1.sweeps.push(htf_sweep)
            c1.mapped_sweeps.push(mapped_sweep)
            c1.bull_sweep := true

    else if is_bear_sweep 
        if not c1.bear_sweep
            htf_sweep = UDT_Sweep.new(x1=c1.l_idx, x2=c2.end_idx, y=c1.l, bull=false)
            mid_x = math.round(math.avg(c1.start_idx, c1.end_idx))
            mapped_sweep = UDT_Sweep.new(x1=mid_x, x2=c2.end_idx, y=c1.l, bull=false)
            c1.sweeps.push(htf_sweep)
            c1.mapped_sweeps.push(mapped_sweep)
            c1.bear_sweep := true

method detect_sweeps(array<UDT_HTF_Candle> htf_candles) =>
    count = htf_candles.size()
    if count > 1
        size = count - 1
        for i = size to 1
            c1 = htf_candles.get(i)
            c2 = htf_candles.get(i - 1)
            if c1.sweeps.size() <= 2
                detect_sweep(c1, c2)
    htf_candles.invalidate_sweeps()
    htf_candles

method position_mapped_sweeps(array<UDT_HTF_Candle> htf_candles) =>
    for [i, candle] in htf_candles
        for [j, sweep] in candle.mapped_sweeps
            if not sweep.invalidated
                sweep.x2 := bar_index
    htf_candles

method position_htf_sweeps(array<UDT_HTF_Candle> htf_candles, int c_amount, int current_offset, int space, int width) => 
    count = htf_candles.size()
    if count > 1
        c_last = htf_candles.get(0)
        c_last_shift = get_shift(0, current_offset, space, width, c_amount)
        c_last_right = last_bar_index + c_last_shift + width
        for [i, candle] in htf_candles
            shift = get_shift(i, current_offset, space, width, c_amount)
            wick_x = last_bar_index + shift + math.round(width / 2)
            for [j, sweep] in candle.sweeps
                sweep.x2 := c_last_right + space
                sweep.x1 := wick_x
    htf_candles

method draw_sweep(UDT_Store store, UDT_Sweep sweep) =>
    if sweep.invalidated
        if hm_isweep_show
            if not sweep.removed and not na(sweep.invalidated_on)
                store.lines.push(line.new(x1=sweep.x1, y1=sweep.y, x2=sweep.x2, y2=sweep.y, xloc = xloc.bar_index, color = hm_isweep_color, style = line_style(hm_isweep_style), width = hm_isweep_width))
    else
        if hm_sweep_show
            store.lines.push(line.new(x1=sweep.x1, y1=sweep.y, x2=sweep.x2, y2=sweep.y, xloc = xloc.bar_index, color = hm_sweep_color, style = line_style(hm_sweep_style), width = hm_sweep_width))
    sweep

method draw_htf_sweep(UDT_Store store, UDT_Sweep sweep, color sweep_css, int w) =>
    if sweep.invalidated
        if hm_isweep_show
            if not sweep.removed and not na(sweep.invalidated_on)
                store.lines.push(line.new(x1=sweep.x1, y1=sweep.y, x2=sweep.x2, y2=sweep.y, xloc = xloc.bar_index, color = color.new(sweep_css, 50), style = line_style(hm_isweep_style), width = w))
    else
        if hm_sweep_show
            store.lines.push(line.new(x1=sweep.x1, y1=sweep.y, x2=sweep.x2, y2=sweep.y, xloc = xloc.bar_index, color = sweep_css, style = line_style(hm_sweep_style), width = w))
    sweep

draw_right_panel(UDT_Store store, array<UDT_HTF_Candle> candles, color bull_css, color bear_css, color bull_border, color bear_border, int wick_w, bool show_tf, string tf_lbl, string lbl_size, int current_offset, int space, int width, int margin, string gen_font) =>
    int c_amount = candles.size()
    if c_amount > 0
        for [idx, candle] in candles
            if na(candle.o) or na(candle.h) or na(candle.l) or na(candle.c)
                continue
            
            bool is_bull = candle.is_bull
            color body_css   = is_bull ? bull_css   : bear_css
            color border_css = is_bull ? bull_border : bear_border
            float body_top   = math.max(candle.o, candle.c)
            float body_bot   = math.min(candle.o, candle.c)

            int shift = get_shift(idx, current_offset, space, width, c_amount)
            int x_left = last_bar_index + shift
            int x_right = x_left + width
            int wick_x = x_left + math.round(width / 2)

            color box_bg_css = body_css
            if not na(candle.atr) and candle.atr > 0
                float base_transp = color.t(body_css)
                float ratio = (candle.h - candle.l) / candle.atr
                float target_transp = base_transp + (100.0 - base_transp) * (1.0 - ratio)
                target_transp := math.max(20.0, math.min(98.0, target_transp))
                box_bg_css := color.new(body_css, target_transp)

            bx = box.new(x_left, body_top, x_right, body_bot, bgcolor = box_bg_css, border_color = border_css, border_width = 1)
            store.boxes.push(bx)

            if candle.h > body_top
                wk_top = line.new(wick_x, body_top, wick_x, candle.h, color = border_css, width = wick_w)
                store.lines.push(wk_top)
            if candle.l < body_bot
                wk_bot = line.new(wick_x, body_bot, wick_x, candle.l, color = border_css, width = wick_w)
                store.lines.push(wk_bot)

        if show_tf
            int min_shift = get_shift(c_amount - 1, current_offset, space, width, c_amount)
            int max_shift = get_shift(0, current_offset, space, width, c_amount)
            int x_min = last_bar_index + min_shift + math.round(width / 2)
            int x_max = last_bar_index + max_shift + math.round(width / 2)
            int mid_x = math.round(math.avg(x_min, x_max))
            float y_top = na
            for candle in candles
                if not na(candle.h)
                    y_top := na(y_top) ? candle.h : math.max(y_top, candle.h)
            if not na(y_top)
                lbl_tf = label.new(mid_x, y_top, format_tf(tf_lbl) + "\n", color = colors_transparent, textcolor = bull_border, style = label.style_label_down, size = text_size(lbl_size), text_font_family = font_style(gen_font))
                store.labels.push(lbl_tf)

        candles.position_htf_sweeps(c_amount, current_offset, space, width)
        for candle in candles
            for [j, sweep] in candle.sweeps
                store.draw_htf_sweep(sweep, candle.is_bull ? bull_border : bear_border, wick_w)

        current_offset + (width + space) * c_amount + margin
    else
        current_offset

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

// ── HTF Candle Accumulation ─────────────────────────────────
if is_new_htf
    // Close the previous candle
    if g_htf_candles.size() > 0
        prev = g_htf_candles.get(0)
        prev.is_closed := true
        prev.end_idx   := bar_index - 1

    // Create new HTF candle
    new_candle = UDT_HTF_Candle.new(
         o          = htf_o,
         h          = htf_h,
         l          = htf_l,
         c          = htf_c,
         start_idx  = bar_index,
         end_idx    = bar_index,
         start_time = htf_t,
         end_time   = htf_tc,
         is_bull    = htf_c >= htf_o,
         is_closed  = false,
         atr        = htf_atr,
         h_idx      = bar_index,
         l_idx      = bar_index,
         bull_sweep = false,
         bear_sweep = false,
         sweeps     = array.new<UDT_Sweep>(),
         mapped_sweeps = array.new<UDT_Sweep>()
     )
    g_htf_candles.unshift(new_candle)

    // Prune old candles
    while g_htf_candles.size() > hm_htf_history
        g_htf_candles.pop()

// Update active (current) HTF candle
if g_htf_candles.size() > 0 and not is_new_htf
    active = g_htf_candles.get(0)
    if high > active.h
        active.h_idx := bar_index
    if low < active.l
        active.l_idx := bar_index
    active.h       := htf_h
    active.l       := htf_l
    active.c       := htf_c
    active.end_idx := bar_index
    active.is_bull := htf_c >= htf_o
    active.atr     := htf_atr

// ── HTF 2 Candle Accumulation ───────────────────────────────
if is_new_htf2
    // Close the previous candle
    if g_htf2_candles.size() > 0
        prev = g_htf2_candles.get(0)
        prev.is_closed := true
        prev.end_idx   := bar_index - 1

    // Create new HTF 2 candle
    new_candle2 = UDT_HTF_Candle.new(
         o          = htf2_o,
         h          = htf2_h,
         l          = htf2_l,
         c          = htf2_c,
         start_idx  = bar_index,
         end_idx    = bar_index,
         start_time = htf2_t,
         end_time   = htf2_tc,
         is_bull    = htf2_c >= htf2_o,
         is_closed  = false,
         atr        = htf2_atr,
         h_idx      = bar_index,
         l_idx      = bar_index,
         bull_sweep = false,
         bear_sweep = false,
         sweeps     = array.new<UDT_Sweep>(),
         mapped_sweeps = array.new<UDT_Sweep>()
     )
    g_htf2_candles.unshift(new_candle2)

    // Prune old candles
    while g_htf2_candles.size() > hm_htf2_history
        g_htf2_candles.pop()

// Update active (current) HTF 2 candle
if g_htf2_candles.size() > 0 and not is_new_htf2
    active2 = g_htf2_candles.get(0)
    if high > active2.h
        active2.h_idx := bar_index
    if low < active2.l
        active2.l_idx := bar_index
    active2.h       := htf2_h
    active2.l       := htf2_l
    active2.c       := htf2_c
    active2.end_idx := bar_index
    active2.is_bull := htf2_c >= htf2_o
    active2.atr     := htf2_atr

g_htf_candles.detect_sweeps()
g_htf2_candles.detect_sweeps()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Visuals / UI   |
// # ========================================================================= #

//#region

// Redraw every bar on last confirmed history or realtime
if barstate.islast or barstate.islastconfirmedhistory
    g_store.clean_drawings()

    string tz = hm_timezone == "Exchange" ? syminfo.timezone : hm_timezone

    g_htf_candles.position_mapped_sweeps()
    for [idx, candle] in g_htf_candles
        if na(candle.o) or na(candle.h) or na(candle.l) or na(candle.c)
            continue

        int x1 = candle.start_idx
        int x2 = candle.end_idx
        bool is_bull = candle.is_bull
        color body_css   = is_bull ? hm_bull_body_css   : hm_bear_body_css
        color border_css = is_bull ? hm_bull_border_css : hm_bear_border_css
        float body_top   = math.max(candle.o, candle.c)
        float body_bot   = math.min(candle.o, candle.c)

        // ── HTF Candle Body ────────────────────────────────
        string time_str = ""
        if hm_show_time_lbl and not na(candle.start_time) and not na(candle.end_time)
            tf_start = str.format_time(candle.start_time, "HH:mm", tz)
            tf_end = str.format_time(candle.end_time, "HH:mm", tz)
            time_str := tf_start + "-" + tf_end

        if hm_show_candle
            color box_bg_css = body_css
            if not na(candle.atr) and candle.atr > 0
                float base_transp = color.t(body_css)
                float ratio = (candle.h - candle.l) / candle.atr
                float target_transp = base_transp + (100.0 - base_transp) * (1.0 - ratio)
                target_transp := math.max(20.0, math.min(98.0, target_transp))
                box_bg_css := color.new(body_css, target_transp)

            bx = box.new(x1, body_top, x2, body_bot, bgcolor = box_bg_css, border_color = border_css, border_width = 1,
                         text = "", text_size = size.auto, text_color = border_css, text_valign = text.align_center, text_halign = text.align_center, text_font_family = general_font.font_style())
            g_store.boxes.push(bx)

            // Upper wick
            if candle.h > body_top
                int wick_x = math.round(math.avg(x1, x2))
                wk_top = line.new(wick_x, body_top, wick_x, candle.h, color = border_css, width = hm_wick_width)
                g_store.lines.push(wk_top)
            // Lower wick
            if candle.l < body_bot
                int wick_x = math.round(math.avg(x1, x2))
                wk_bot = line.new(wick_x, body_bot, wick_x, candle.l, color = border_css, width = hm_wick_width)
                g_store.lines.push(wk_bot)

            if hm_show_trend
                tl = line.new(x1, candle.o, x2, candle.c, color = border_css, width = 1)
                g_store.lines.push(tl)


        // ── HTF Separator ──────────────────────────────────
        if hm_show_candle and hm_show_sep and x1 > 0
            sep = line.new(x1, candle.h, x1, candle.l, color = hm_sep_css, style = hm_sep_style.line_style(), width = hm_sep_width, extend = extend.both)
            g_store.lines.push(sep)

        // ── TF Labels at Top ────────────────────────────────
        int mid_x = math.round(math.avg(x1, x2))
        if hm_show_tf_label and hm_show_candle
            lbl_tf = label.new(mid_x, candle.h, format_tf(hm_htf) + "\n", color = colors_transparent, textcolor = border_css, style = label.style_label_down, size = text_size(hm_lbl_size), text_font_family = general_font.font_style())
            g_store.labels.push(lbl_tf)
            
        if hm_show_time_lbl and time_str != "" and hm_show_candle
            lbl_time = label.new(mid_x, candle.h, time_str, color = colors_transparent, textcolor = border_css, style = label.style_label_down, size = size.tiny, text_font_family = general_font.font_style())
            g_store.labels.push(lbl_time)

        if hm_show_candle
            for [j, sweep] in candle.mapped_sweeps
                g_store.draw_htf_sweep(sweep, border_css, hm_wick_width)

    g_htf2_candles.position_mapped_sweeps()
    for [idx, candle] in g_htf2_candles
        if na(candle.o) or na(candle.h) or na(candle.l) or na(candle.c)
            continue

        int x1 = candle.start_idx
        int x2 = candle.end_idx
        bool is_bull = candle.is_bull
        color body_css   = is_bull ? hm_bull2_body_css   : hm_bear2_body_css
        color border_css = is_bull ? hm_bull2_border_css : hm_bear2_border_css
        float body_top   = math.max(candle.o, candle.c)
        float body_bot   = math.min(candle.o, candle.c)

        string time_str = ""
        if hm_show_time_lbl2 and not na(candle.start_time) and not na(candle.end_time)
            tf_start = str.format_time(candle.start_time, "HH:mm", tz)
            tf_end = str.format_time(candle.end_time, "HH:mm", tz)
            time_str := tf_start + "-" + tf_end

        if hm_show_candle2
            color box_bg_css = body_css
            if not na(candle.atr) and candle.atr > 0
                float base_transp = color.t(body_css)
                float ratio = (candle.h - candle.l) / candle.atr
                float target_transp = base_transp + (100.0 - base_transp) * (1.0 - ratio)
                target_transp := math.max(20.0, math.min(98.0, target_transp))
                box_bg_css := color.new(body_css, target_transp)

            bx = box.new(x1, body_top, x2, body_bot, bgcolor = box_bg_css, border_color = border_css, border_width = 1,
                         text = "", text_size = size.auto, text_color = border_css, text_valign = text.align_center, text_halign = text.align_center, text_font_family = general_font.font_style())
            g_store.boxes.push(bx)

            // Upper wick
            if candle.h > body_top
                int wick_x = math.round(math.avg(x1, x2))
                wk_top = line.new(wick_x, body_top, wick_x, candle.h, color = border_css, width = hm_wick2_width)
                g_store.lines.push(wk_top)
            // Lower wick
            if candle.l < body_bot
                int wick_x = math.round(math.avg(x1, x2))
                wk_bot = line.new(wick_x, body_bot, wick_x, candle.l, color = border_css, width = hm_wick2_width)
                g_store.lines.push(wk_bot)

            if hm_show_trend2
                tl = line.new(x1, candle.o, x2, candle.c, color = border_css, width = 1)
                g_store.lines.push(tl)


        // ── HTF Separator ──────────────────────────────────
        if hm_show_candle2 and hm_show_sep2 and x1 > 0
            sep2 = line.new(x1, candle.h, x1, candle.l, color = hm_sep2_css, style = hm_sep2_style.line_style(), width = hm_sep2_width, extend = extend.both)
            g_store.lines.push(sep2)

        // ── TF Labels at Top ────────────────────────────────
        int mid_x = math.round(math.avg(x1, x2))
        if hm_show_tf_label2 and hm_show_candle2
            lbl_tf2 = label.new(mid_x, candle.h, format_tf(hm_htf2) + "\n \n ", color = colors_transparent, textcolor = border_css, style = label.style_label_down, size = text_size(hm_lbl_size2), text_font_family = general_font.font_style())
            g_store.labels.push(lbl_tf2)
            
        if hm_show_time_lbl2 and time_str != "" and hm_show_candle2
            lbl_time2 = label.new(mid_x, candle.h, time_str, color = colors_transparent, textcolor = border_css, style = label.style_label_down, size = size.tiny, text_font_family = general_font.font_style())
            g_store.labels.push(lbl_time2)

        if hm_show_candle2
            for [j, sweep] in candle.mapped_sweeps
                g_store.draw_htf_sweep(sweep, border_css, hm_wick2_width)

    int right_offset = hm_right_offset
    int c_width = candle_size(hm_right_candle_width)

    if hm_show_candle
        right_offset := draw_right_panel(g_store, g_htf_candles, hm_bull_body_css, hm_bear_body_css, hm_bull_border_css, hm_bear_border_css, hm_wick_width, hm_show_tf_label, hm_htf, hm_lbl_size, right_offset, hm_right_space, c_width, hm_right_margin, general_font)
    
    if hm_show_candle2
        right_offset := draw_right_panel(g_store, g_htf2_candles, hm_bull2_body_css, hm_bear2_body_css, hm_bull2_border_css, hm_bear2_border_css, hm_wick2_width, hm_show_tf_label2, hm_htf2, hm_lbl_size2, right_offset, hm_right_space, c_width, hm_right_margin, general_font)


//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Alerts   |
// # ========================================================================= #

//#region

alertcondition(is_new_htf, "New HTF Candle", "HTF Mappings · New HTF candle opened on {{ticker}} {{interval}}")

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
