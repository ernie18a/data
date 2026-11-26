# CandelaCharts - Order Blocks

- url: https://www.tradingview.com/script/GSEzHIcI-CandelaCharts-Order-Blocks/
- type: indicator
- pine_id: PUB;7a85a1a3fb774f948b1a7d914444c020
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - Order Blocks[/b] indicator identifies high-probability supply and demand zones based on [b]ICT (Inner Circle Trader)[/b] and [b]Smart Money Concepts (SMC)[/b]. An ICT Order Block represents the specific candle where institutional liquidity was injected to reverse the market, acting as a magnet for future price action. This indicator not only highlights these crucial institutional footprints but dynamically tracks how deeply they have been mitigated by future price action.

📦 [b]Features[/b]

[list]
[*] [b]Precision Detection[/b]: Identifies both Bullish and Bearish Order Blocks using advanced pivot tracking and multi-timeframe logic.
[*] [b]Dynamic Mitigation Tracking[/b]: Displays the precise percentage of the unmitigated zone remaining. The block visually updates as price pierces deeper into the zone, leaving a solid background on the unmitigated portion and a faded background where price has already traded.
[*] [b]Wick vs Close Logic[/b]: Customize exactly how mitigation is calculated. Choose to invalidate and measure mitigation depth using candle wicks or strict candle closes.
[*] [b]Clean Chart Mechanics[/b]: Built-in filtering removes overlapping blocks, keeping your chart tidy and focusing on the most relevant levels.
[*] [b]Customizable Aesthetics[/b]: Full control over block borders, mean lines (mid-lines), text formatting, and alignment settings (Full, Middle, Accurate, Precise, Sequence).
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Show[/b]: Toggles the visibility of the entire indicator.
[*] [b]History[/b]: Adjust the maximum number of historical Order Blocks to display simultaneously.
[*] [b]Alignment[/b]: Controls how the top and bottom bounds of the block are calculated (e.g., Full Candle, Accurate, Precise, Sequence).
[*] [b]Mitigation Toggle & Mode[/b]: Enable or disable the visual percentage display. Choose [b]Wick[/b] or [b]Close[/b] to determine how mitigation depth and block invalidation are calculated.
[*] [b]Timeframe[/b]: Lock the Order Blocks to a specific timeframe, or leave it dynamic.
[*] [b]Show Border[/b]: Toggle borders and customize their style/width.
[*] [b]Show Mean[/b]: Toggle the mean line (midline) of the blocks and customize its style/width.
[*] [b]Text Size[/b]: Toggle the text display and choose the desired text size. When toggled off, the block type label is hidden, but the mitigation percentage cleanly aligns to the right.
[*] [b]Hide Overlap[/b]: When enabled, removes redundant order blocks that share the same price region.
[/list]

⚡️ [b]Showcase[/b]

[i]Order Blocks[/i]
https://www.tradingview.com/x/XQ3nwvzz/

[i]Mitigation[/i]
https://www.tradingview.com/x/vZlFv9dQ/

[i]Mean Line[/i]
https://www.tradingview.com/x/l2Am7DL7/

🚨 [b]Alerts[/b]

The indicator includes fully integrated dynamic alerts that can be captured using the [b]"Any alert() function call"[/b] condition, as well as standard alert conditions:
[list]
[*] [b]New Bullish/Bearish Order Block[/b]: Triggers the moment a new valid order block is confirmed.
[*] [b]Order Block Touch[/b]: Triggers when a candle pierces or enters an active, unmitigated order block.
[/list]

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator("CandelaCharts - Order Blocks", shorttitle = "CandelaCharts - Order Blocks", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500, max_polylines_count = 100)











// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

// # Core -------------------------------------------------------------------- #

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
colors_gray_90                      = color.new(color.gray, 90)
colors_silver                       = color.silver
colors_transparent                  = color.new(color.white,100)

// # Custom ------------------------------------------------------------------ #

colors_cyan_dark                    = #089981
colors_red_bright                   = #f23645

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                         = input.string("Monospace", "Text Style                  ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                         = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                   = input.bool(false, "Hide Brand", group = "General")

ob_show                              = input.bool(true, "Show                ", inline = "1.0", group = "Settings", tooltip = "Display Blocks")
ob_internal_lookback                 = input.int(7, "", inline = "1.0", group = "Settings", minval = 1)
ob_bull_css                          = input.color(color.new(colors_cyan_dark , 90), "", inline = "1.0", group = "Settings")
ob_bear_css                          = input.color(color.new(colors_red_bright , 90), "", inline = "1.0", group = "Settings")
ob_num                               = input.int(4, "History                      ", inline = "2.0", group = "Settings", minval = 1, maxval = 10, tooltip = "Adjust how many Blocks you want to see")
ob_position                          = input.string("Accurate", "Alignment                 ", inline = "3.0", group = "Settings", tooltip = "Position of the Order Block\n[Full] Cover the whole candle\n[Middle] Cover half candle\n[Accurate] Adjust to volatility\n[Precise] Same as Accurate but more precise\n[Sequence] Entire sequence of candles", options = ["Full", "Middle", "Accurate", "Precise", "Sequence"])
ob_mitigation_show                   = input.bool(false, "Mitigation          ", inline = "4.0", group = "Settings")
ob_mitigation                        = input.string("Close", "", options=["Wick", "Close"], inline = "4.0", group = "Settings")
ob_timeframe                         = input.timeframe("", "Timeframe                ", inline = "5.0", group = "Settings", tooltip = "Timeframe of the block")
ob_use_border                        = input.bool(true, "Show Border      ", inline = "6.0", group = "Settings")
ob_use_border_type                   = input.string("⎯⎯⎯", "", inline = "6.0", group = "Settings", options = ['⎯⎯⎯', '----', '····'], tooltip = "Show border")
ob_use_border_width                  = input.int(1, "", inline = "6.0", group = "Settings", minval = 0, maxval = 10)
ob_use_mean                          = input.bool(false, "Show Mean        ", inline = "7.0", group = "Settings")
ob_use_mean_type                     = input.string("⎯⎯⎯", "", inline = "7.0", group = "Settings", options = ['⎯⎯⎯', '----', '····'], tooltip = "Show mean line")
ob_use_mean_width                    = input.int(1, "", inline = "7.0", group = "Settings", minval = 0, maxval = 10)
ob_show_text                         = input.bool(true, "Text Size            ", inline = "8.0", group = "Settings")
ob_text_size                         = input.string("Auto", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "8.0", group = "Settings")
ob_use_overlap                       = input.bool(true, "Hide Overlap", group = "Settings")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type UDT_Bar
    float   o = open
    float   c = close
    float   h = high
    float   l = low
    float   v = volume
    int     n = bar_index
    int     t = time

type UDT_MS_PNL
	float[] p
	int  [] n
    float[] l

type UDT_MS
    int    trend
    bool   is_bull_ob
    bool   is_bear_ob
	int    x1
    int    x2
	float  p
    int    xloc
	color  css
	string ms_type
	bool   bull
    bool   swing
    bool   sweep

type UDT_Alerts
    // Order Blocks
    bool ob             = false
    bool obtouch        = false

type UDT_Store
    box     [] ob_box
    line    [] ob_line
    
type UDT_Pivot_Point
    float highest_high
    float lowest_low
    int   lowest_low_n
    int   highest_high_n
    int   i_highest_high
    int   i_lowest_low

type UDT_Block
    int     id          = na
    int     left        = na
    float   top         = na
    int     right       = na
    float   bottom      = na
    float   mid         = na
    bool    bull        = false
    int     state       = na
    bool    breaker     = false
    int     x_inv_point = na
    bool    invalidated = false
    bool    alert_fired = false
    float   mitigated_percent = 0.0



//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store bin = UDT_Store.new(ob_box = array.new<box>(), ob_line = array.new<line>())

method clean_ob(UDT_Store store) =>
    for obj in store.ob_box
        obj.delete()
    for obj in store.ob_line
        obj.delete()
        
    store.ob_box.clear()
    store.ob_line.clear()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Alerts   |
// # ========================================================================= #

//#region

method enable_ob_alerts(UDT_Alerts alerts, UDT_Block block) =>
    if not na(block)
        if not block.invalidated
            alerts.ob := true
            if block.bull ? ta.crossunder(low, block.top) : ta.crossover (high, block.bottom)
                alerts.obtouch := true
            block.alert_fired := true
    alerts

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Functions   |
// # ========================================================================= #

//#region

UDT_Bar b                   = UDT_Bar.new()

b_h = b.h
b_l = b.l
b_t = b.t
b_c = b.c
b_o = b.o
b_v = b.v
b_n = b.n

UDT_Alerts bull_alert       = UDT_Alerts.new()
UDT_Alerts bear_alert       = UDT_Alerts.new()

var int i_ms_length = ob_internal_lookback

iH = ta.pivothigh(high, i_ms_length, i_ms_length)
iL = ta.pivotlow (low , i_ms_length, i_ms_length)

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

method set_opacity(color css, int opacity) =>

    blue  = color.b(css)
    red   = color.r(css)
    green = color.g(css)

    color.rgb(red, green, blue, opacity)

method darkcss(color css, float factor, bool bull) =>

    blue  = color.b(css) * (1 - factor)
    red   = color.r(css) * (1 - factor)
    green = color.g(css) * (1 - factor)

    color.rgb(red, green, blue, 0)

method label_style(string label) =>

    out = switch label

        'None'      => label.style_none
        'Circle'    => label.style_circle
        'Square'    => label.style_square
        'Diamond'   => label.style_diamond
        'Cross'     => label.style_cross
        'xCross'    => label.style_xcross

method text_align(string align) =>

    out = switch align

        'Center'    => text.align_center
        'Top'       => text.align_top
        'Bottom'    => text.align_bottom
        'Left'      => text.align_left
        'Right'     => text.align_right

swings(len)=>    

    upper = ta.highest(len)
    lower = ta.lowest(len)

    var float out = 0
    out := b_h[len] > upper ? 0 : b_l[len] < lower ? 1 : out[1]

    top = out == 0 and out[1] != 0 ? b_h[len] : 0
    btm = out == 1 and out[1] != 1 ? b_l[len] : 0

    [top, btm]

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Market Structure   |
// # ========================================================================= #

//#region

method detect_ms_structure(UDT_MS drw, bool bull, UDT_MS_PNL top, UDT_MS_PNL btm, map<string, bool > ms_types, UDT_Alerts alerts) => 
	swing = drw.swing

    if top.p.size() > 0 and btm.l.size() > 1

		if bull ? ta.crossover(b.c, top.p.first()) : ta.crossunder(b.c, top.p.first())

            color clr = bull ? (swing ? colors_cyan_dark : colors_cyan_dark) :  (swing ? colors_red_bright : colors_red_bright)

			if bull ? drw.trend < 0 : drw.trend > 0
                // CHoCH/CHoCH+ detected
				is_CHoCH_plus = bull ? btm.l.first() > btm.l.get(1) : btm.l.first() < btm.l.get(1)
                ms_type = is_CHoCH_plus ? "CHoCH+" : "CHoCH"
                drw.css := clr.darkcss(0.25, true)

                if ms_types.get(ms_type) and na(drw.x1)
                    drw.bull    := bull
                    drw.ms_type := ms_type
                    drw.x1      := top.n.first()
                    drw.x2      := b.n
                    drw.p       := top.p.first()
                    drw.xloc    := bar_index

            else
                // BOS detected
                ms_type = "BOS"
                drw.css := clr

                if ms_types.get(ms_type) and na(drw.x1)
                    drw.bull    := bull
                    drw.ms_type := ms_type
                    drw.x1      := top.n.first()
                    drw.x2      := b.n
                    drw.p       := top.p.first()
                    drw.xloc    := b.n

            is_ob = true
            if bull
                drw.is_bull_ob := is_ob
            else
                drw.is_bear_ob := is_ob

			drw.trend := bull ? 1 : -1
            top.n.clear()
            top.p.clear()

    drw

map_ms_structure(string filter_type) =>
    ms_types = map.new<string, bool >()
    switch filter_type

        "All"      =>  ms_types.put("BOS" , true ),  ms_types.put("CHoCH", true ) , ms_types.put("CHoCH+", true  )
        "CHoCH"    =>  ms_types.put("BOS" , false),  ms_types.put("CHoCH", true ) , ms_types.put("CHoCH+", false )
        "CHoCH+"   =>  ms_types.put("BOS" , false),  ms_types.put("CHoCH", false) , ms_types.put("CHoCH+", true  )
        "BOS"      =>  ms_types.put("BOS" , true ),  ms_types.put("CHoCH", false) , ms_types.put("CHoCH+", false )
        "None"     =>  ms_types.put("BOS" , false),  ms_types.put("CHoCH", false) , ms_types.put("CHoCH+", false )  
        => na

    ms_types

var swing_ms_types    = map_ms_structure("All")
var internal_ms_types = map_ms_structure("All")
        
i_ms_structure() =>

    var UDT_MS ms     = UDT_MS.new(trend = 0, x1 = na, x2 = na, p = na, swing = false)
	var UDT_MS_PNL up = UDT_MS_PNL.new(array.new<float>(), array.new< int >(), array.new<float>())
	var UDT_MS_PNL dn = UDT_MS_PNL.new(array.new<float>(), array.new< int >(), array.new<float>())

    switch
        not na(iH) =>

            up.p.unshift(b_h      [i_ms_length])
            up.l.unshift(b_h      [i_ms_length])
            up.n.unshift(bar_index[i_ms_length])

        not na(iL) =>

            dn.p.unshift(b_l      [i_ms_length])
            dn.l.unshift(b_l      [i_ms_length])
            dn.n.unshift(bar_index[i_ms_length])

    ms.x1         := na
    ms.x2         := na
    ms.xloc       := na
    ms.p          := na
    ms.ms_type    := na
    ms.is_bear_ob := false
    ms.is_bull_ob := false
    ms.sweep      := false

	// Internal Bullish Strucure
    ms.detect_ms_structure(true , up, dn, internal_ms_types, bull_alert)

	// Internal Bearish Strucure
    ms.detect_ms_structure(false, dn, up, internal_ms_types, bear_alert)

    [ms.trend, ms]

[i_trend, i_ms] = i_ms_structure()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Blocks   |
// # ========================================================================= #

//#region

detect_pivot_points(int len) =>
    [hH, lL] = request.security(syminfo.tickerid, ob_timeframe, [high, low], lookahead = barmerge.lookahead_off)

    h = array.new<float>()
    l = array.new<float>()
    n = array.new< int >()

    if len > 1
        for i = 0 to len - 1
            h.push(hH[i])
            l.push(lL[i])
            n.push(b_t[i])
    
        float highest_high = h.max()
        float lowest_low   = l.min()
        int i_highest_high = h.indexof(highest_high) + 1
        int i_lowest_low   = l.indexof(lowest_low) + 1
        int highest_high_n = n.get(i_highest_high - 1)
        int lowest_low_n   = n.get(i_lowest_low - 1) 
        UDT_Pivot_Point pivot_point = UDT_Pivot_Point.new(
               highest_high = highest_high
             , lowest_low = lowest_low
             , highest_high_n = highest_high_n
             , lowest_low_n = lowest_low_n
             , i_highest_high = i_highest_high
             , i_lowest_low = i_lowest_low
             )

        pivot_point

method style_order_block(UDT_Block order_block, box figure, bool swing, bool inversion) =>
    bull      = inversion ? not order_block.bull : order_block.bull
    breaker   = order_block.breaker

    bgcolor = bull 
                 ? swing ? ob_bull_css : breaker ? ob_bull_css.set_opacity(90) : ob_bull_css 
                 : swing ? ob_bear_css : breaker ? ob_bear_css.set_opacity(90) : ob_bear_css
    figure.set_bgcolor(bgcolor)
    
    use_border = swing or ob_use_border
    figure.set_border_color(use_border ? color.new(bgcolor, 0) : colors_transparent)
    figure.set_border_style(line_style(ob_use_border_type))
    figure.set_border_width(use_border ? ob_use_border_width : 0)
    figure

get_block_position(bool bull) =>
    pos = switch ob_position
        "Full"      => bull ? high : low
        "Middle"    => ohlc4
        "Accurate"  => hl2
        "Precise"   => hl2
        => hl2
    pos

method detect_order_block(array<UDT_Block> order_blocks, UDT_Pivot_Point pivot_point, bool cdn, bool bull) =>
    UDT_Block ob = na

    position = get_block_position(bull)

    if cdn and not na(pivot_point)
        id        = b.n
        bar_close = bull ? b_c[pivot_point.i_lowest_low]   : b_c[pivot_point.i_highest_high]
        bar_open  = bull ? b_o[pivot_point.i_lowest_low]   : b_o[pivot_point.i_highest_high]
        pos       = bull ? position[pivot_point.i_lowest_low]   : position[pivot_point.i_highest_high] 
        prev_high = bull ? hlcc4[pivot_point.i_lowest_low] : hlcc4[pivot_point.i_highest_high]

        switch bull
            true =>
                left    = pivot_point.lowest_low_n
                top     = pos
                right   = last_bar_time
                bottom  = pivot_point.lowest_low
                mid     = math.avg(top, bottom)

                switch ob_position
                    "Precise" => 
                        if mid < (bar_close < bar_open ? bar_close : bar_open) and top > prev_high
                            top := mid
                            mid := math.avg(top, bottom)
                    "Sequence" =>
                        idx = pivot_point.i_lowest_low
                        max_top = top
                        earliest_time = left
                        while idx < 500 and b_c[idx] > b_o[idx] and idx < pivot_point.i_lowest_low + 2
                            idx += 1
                        while idx < 500 and b_c[idx] <= b_o[idx]
                            max_top := math.max(max_top, high[idx])
                            earliest_time := time[idx]
                            idx += 1
                        top := max_top
                        left := earliest_time
                        mid := math.avg(top, bottom)
                ob := UDT_Block.new(id, left, top, right, bottom, mid, bull = bull, state = 0)

            false =>
                left    = pivot_point.highest_high_n
                top     = pivot_point.highest_high
                right   = last_bar_time
                bottom  = pos
                mid     = math.avg(top, bottom)

                switch ob_position
                    "Precise" => 
                        if mid > (bar_close < bar_open ? bar_open : bar_close) and bottom < prev_high
                            bottom := mid
                            mid := math.avg(top, bottom)
                    "Sequence" =>
                        idx = pivot_point.i_highest_high
                        min_bottom = bottom
                        earliest_time = left
                        while idx < 500 and b_c[idx] < b_o[idx] and idx < pivot_point.i_highest_high + 2
                            idx += 1
                        while idx < 500 and b_c[idx] >= b_o[idx]
                            min_bottom := math.min(min_bottom, low[idx])
                            earliest_time := time[idx]
                            idx += 1
                        bottom := min_bottom
                        left := earliest_time
                        mid := math.avg(top, bottom)

                ob := UDT_Block.new(id, left, top, right, bottom, mid, bull = bull, state = 0)
        
        order_blocks.unshift(ob)

    ob

method limit_filter_bull_or_bear(array<UDT_Block> order_blocks, bool only_bull, int limit) =>
    filter_blocks       = array.new<UDT_Block>()
    len   = math.min(limit, order_blocks.size())
    i = 0
    count = 0
    while i < order_blocks.size() and count < len
        ob = order_blocks.get(i)
        if ob.bull == only_bull
            filter_blocks.unshift(ob)
            count += 1
        i += 1
    filter_blocks

method invalidate_blocks(array<UDT_Block> order_blocks, float close_price, float high_price, float low_price, string mitigation_type) =>
    if order_blocks.size() > 0
        for i = order_blocks.size()-1 to 0
            ob = order_blocks.get(i)
            
            float current_price = 0.0
            if mitigation_type == "Wick"
                current_price := ob.bull ? low_price : high_price
            else
                current_price := close_price
                
            float percent = ob.mitigated_percent
            if ob.bull
                if current_price < ob.top
                    float p = ((ob.top - current_price) / (ob.top - ob.bottom)) * 100
                    if p > percent
                        percent := math.min(100, math.max(0, p))
            else
                if current_price > ob.bottom
                    float p = ((current_price - ob.bottom) / (ob.top - ob.bottom)) * 100
                    if p > percent
                        percent := math.min(100, math.max(0, p))
            
            ob.mitigated_percent := percent

            bool is_invalid = false
            if mitigation_type == "Wick"
                is_invalid := ob.bull ? low_price < ob.bottom : high_price > ob.top
            else
                is_invalid := ob.bull ? close_price < ob.bottom : close_price > ob.top
                
            if is_invalid
                ob.invalidated := true
                order_blocks.remove(i)
    order_blocks

method remove_overlaped_blocks(array<UDT_Block> order_blocks) =>
    int size = array.size(order_blocks)
    int i = 0
    while i < size
        int j = i + 1
        while j < size
            // Get the blocks
            bl_1 = array.get(order_blocks, i)
            bl_2 = array.get(order_blocks, j)

            // Check for overlap between bl_1 and bl_2
            if bl_1.bull == bl_2.bull // Only compare blocks of the same type (bull or bear)
                // Check if the blocks overlap
                if (bl_1.top > bl_2.bottom and bl_1.bottom < bl_2.top)
                    // Remove the more recent block (higher index) and adjust size
                    order_blocks.remove(j)
                    size := size - 1  // Update the size after removal
                    j := j - 1  // Adjust j since we removed an element
            j := j + 1
        i := i + 1

    // Return the updated array without overlapped blocks
    order_blocks

method draw_order_blocks(array<UDT_Block> order_blocks, int cur_time, int prev_time, bool swing) => 
    for [i, ob] in order_blocks
        time_frame = cur_time - prev_time
        top     = ob.top
        bottom  = ob.bottom
        left    = ob.left
        rightShift = cur_time + time_frame * 100
        bull    = ob.bull

        // Extended block with text
        bx = box.new(left = left, top = top, right = rightShift, bottom = bottom, xloc = xloc.bar_time, extend = extend.right)
        bx := ob.style_order_block(bx, swing, false)
        
        // Unmitigated zone stronger background
        if ob_mitigation_show and ob.mitigated_percent < 100
            float unmitigated_top = top
            float unmitigated_bottom = bottom
            if bull
                unmitigated_top := top - ((top - bottom) * (ob.mitigated_percent / 100))
            else
                unmitigated_bottom := bottom + ((top - bottom) * (ob.mitigated_percent / 100))
                
            color bg_color = bull ? ob_bull_css : ob_bear_css
            color unmitigated_bg = color.new(bg_color, math.max(0, color.t(bg_color) - 40)) // Stronger background
            
            box unmitigated_bx = box.new(left = left, top = unmitigated_top, right = rightShift, bottom = unmitigated_bottom, xloc = xloc.bar_time, extend = extend.right)
            unmitigated_bx.set_bgcolor(unmitigated_bg)
            unmitigated_bx.set_border_color(colors_transparent)
            bin.ob_box.push(unmitigated_bx)
        
        if ob_show_text or ob_mitigation_show
            text_color = bull ? ob_bull_css : ob_bear_css
            text_color := color.new(text_color, 0) // Solid color for text
            
            string block_text = ""
            if ob_show_text
                block_text := "Order Block"
                
            if ob_mitigation_show
                float unmitigated_pct = 100 - ob.mitigated_percent
                block_text += (ob_show_text ? " (" : "") + str.tostring(math.round(unmitigated_pct)) + "%" + (ob_show_text ? ")" : "")
                
            bx.set_text(block_text)
            bx.set_text_size(text_size(ob_text_size))
            bx.set_text_color(text_color)
            bx.set_text_halign(ob_show_text ? text.align_left : text.align_right)
            bx.set_text_valign(text.align_center)
            bx.set_text_font_family(font_style(general_font))
            bx.set_text_formatting(text.format_bold)

        bin.ob_box.push(bx)
        
        if ob_use_mean
            ln_color = bull ? ob_bull_css : ob_bear_css
            ln_color := color.new(ln_color, 0)
            ln = line.new(x1 = left, y1 = ob.mid, x2 = rightShift, y2 = ob.mid, xloc = xloc.bar_time, extend = extend.right, color = ln_color, style = line_style(ob_use_mean_type), width = ob_use_mean_width)
            bin.ob_line.push(ln)

    order_blocks

var hN = b.n
var lN = b.n
var hS = b.n
var lS = b.n

if not na(iH)

    hN:=int(b_n[i_ms_length])

if not na(iL)

    lN:=int(b_n[i_ms_length])

bin.clean_ob()

order_ob_indicator() => 
    
    var all_order_blocks = array.new<UDT_Block>(na) // order blocks

    bull_pivot_point = detect_pivot_points(math.abs((hN - b.n)))
    bull_vob = all_order_blocks.detect_order_block(bull_pivot_point, i_ms.is_bull_ob, true)

    bear_pivot_point = detect_pivot_points(math.abs((lN - b.n)))
    bear_vob = all_order_blocks.detect_order_block(bear_pivot_point, i_ms.is_bear_ob, false)

    if barstate.isconfirmed
            
        all_order_blocks.invalidate_blocks(close, high, low, ob_mitigation) // invalidate order blocks

    if barstate.islast
        
        if ob_use_overlap
            all_order_blocks.remove_overlaped_blocks() // remove overlaped

        bull_order_blocks = all_order_blocks.limit_filter_bull_or_bear(true , ob_num)  // filter out bullish order blocks
        bear_order_blocks = all_order_blocks.limit_filter_bull_or_bear(false, ob_num) // filter out bearish order blocks
    
        // add drawings
        bull_order_blocks.draw_order_blocks(b.t, b_t[1], false)
        bear_order_blocks.draw_order_blocks(b.t, b_t[1], false)

    // alerts
    bull_alert.enable_ob_alerts(bull_vob)
    bear_alert.enable_ob_alerts(bear_vob)

    [bull_vob, bear_vob]

if ob_show

    order_ob_indicator()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Alerts   |
// # ========================================================================= #

//#region

alertcondition(bull_alert.ob               , "Bullish Order Block", "Bullish Order Block")
alertcondition(bull_alert.obtouch          , "Candle Entering in a Bullish Order Block", "Candle Entering in a Bullish Order Block")

alertcondition(bear_alert.ob               , "Bearish Order Block", "Bearish Order Block")
alertcondition(bear_alert.obtouch          , "Candle Entering in a Bearish Order Block", "Candle Entering in a Bearish Order Block")

if bull_alert.ob
    alert("Bullish Order Block", alert.freq_once_per_bar)
if bull_alert.obtouch
    alert("Candle Entering in a Bullish Order Block", alert.freq_once_per_bar)

if bear_alert.ob
    alert("Bearish Order Block", alert.freq_once_per_bar)
if bear_alert.obtouch
    alert("Candle Entering in a Bearish Order Block", alert.freq_once_per_bar)

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
