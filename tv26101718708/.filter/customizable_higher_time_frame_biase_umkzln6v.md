# Customizable Higher Time Frame Biase

- url: https://www.tradingview.com/script/umkZln6V-Customizable-Higher-Time-Frame-Biase/
- type: indicator
- pine_id: PUB;aed700ffd3b24f9fb8cff1ea3c27cc1f
- version: 1.0

## Description

💎 Script Description

Customizable Higher Time Frame Bias

This indicator is designed to identify and display higher time frame directional bias using CISD (Change in State of Delivery) logic. It tracks key structural levels in the market and highlights when price transitions from bullish to bearish conditions, or vice versa.

When price breaks a tracked level:

Bullish (+CISD) indicates a shift in momentum to the upside
Bearish (-CISD) indicates a shift in momentum to the downside

The indicator automatically plots these levels on the chart, allowing traders to clearly visualize where market sentiment has changed.

A built-in multi-timeframe bias table displays the current trend direction across multiple timeframes. These timeframes are fully customizable, giving traders flexibility to align the tool with their personal trading strategy.

✨ Features:
Automatic detection of bullish and bearish CISD levels
Visual plotting of key structure levels
Real-time identification of market bias shifts
Customizable higher timeframe bias table
Adjustable visuals (colors, labels, line styles)
Optional display of active CISD level

## Source Code

````pine
//@version=6
indicator("Customizable Higher Time Frame Biase", shorttitle="HTF Biase", overlay=true, max_lines_count=500, max_labels_count=500)

var string vanity_group = "Visual Settings"

magic_wand_toggle = input.bool(false, "Show Active CISD Level (Plot)", group=vanity_group)
drama_filter = input.string("Both", "Triggered CISD Display", options=["Both", "Bullish Only", "Bearish Only", "None"], group=vanity_group)
amnesia_mode = input.bool(false, "Limit Displayed Historical Lines", group=vanity_group)
short_term_memory = input.int(10, "Max Lines to Show", minval=1, group=vanity_group)
elasticity_factor = input.int(0, "Extend Lines (Bars)", minval=0, group=vanity_group)

yell_at_me = input.bool(true, "Show Labels", group=vanity_group)
stage_direction = input.string("Center", "Label Position", options=["Left", "Center", "Right"], group=vanity_group)
girth_units = input.int(2, "Line Width", minval=1, group=vanity_group)
scream_volume = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal, size.large], group=vanity_group)

hipster_font_toggle = input.string("Default", "Font Family", options=["Default", "Monospace"], group=vanity_group)
fashion_choice = input.string("Solid", "Triggered Line Style", options=["Solid", "Dashed", "Dotted"], group=vanity_group)

crayon_box = "Colors"
shrek_mode = input.color(color.new(color.green, 0), "Bullish CISD", group=crayon_box)
blood_bath = input.color(color.new(color.red, 0), "Bearish CISD", group=crayon_box)

nerd_stats = "Debug"
paranoia_switch = input.bool(false, "Debug: Show Extreme Tracking", group=nerd_stats)

gossip_column = "HTF Trend Panel"
stalker_mode = input.bool(true, "Show Multi-Timeframe Table", group=gossip_column)
feng_shui = input.string("Bottom Right", "Table Position", options=["Top Right", "Middle Right", "Bottom Right", "Bottom Left"], group=gossip_column)
eye_test = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=gossip_column)

custom_tf_group = "Custom Table Timeframes"
tf1 = input.timeframe("1", "Timeframe 1", group=custom_tf_group)
tf2 = input.timeframe("3", "Timeframe 2", group=custom_tf_group)
tf3 = input.timeframe("5", "Timeframe 3", group=custom_tf_group)
tf4 = input.timeframe("15", "Timeframe 4", group=custom_tf_group)
tf5 = input.timeframe("60", "Timeframe 5", group=custom_tf_group)
tf6 = input.timeframe("240", "Timeframe 6", group=custom_tf_group)
tf7 = input.timeframe("1D", "Timeframe 7", group=custom_tf_group)
tf8 = input.timeframe("1W", "Timeframe 8", group=custom_tf_group)

var string fancy_typeface = hipster_font_toggle == "Monospace" ? font.family_monospace : font.family_default

decode_fashion_statement(outfit) =>
    switch outfit
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

chosen_style = decode_fashion_statement(fashion_choice)

var int vibes = 0
var float bagholder_entry = na
var int time_machine_setting = na
var float pain_threshold = na

var label sticky_note_of_shame = na
var array<line> graveyard_of_hopes = array.new<line>()
var array<label> choir_of_screams = array.new<label>()

consult_the_crystal_ball(int bias) =>
    int temporal_shift = 0
    float extreme = open[0]
    int candle_attitude = close[0] > open[0] ? 1 : close[0] < open[0] ? -1 : 0
    if candle_attitude == 0 or candle_attitude != bias
        [extreme, bar_index]
    for i = 1 to 500
        candle_attitude := close[i] > open[i] ? 1 : close[i] < open[i] ? -1 : 0
        if candle_attitude == 0
            continue
        bool mood_match = candle_attitude == bias
        if not mood_match
            break
        temporal_shift := i
        if bias == 1
            if open[i] < extreme
                extreme := open[i]
        else
            if open[i] > extreme
                extreme := open[i]
    int extreme_shift = na
    for k = 0 to temporal_shift
        if open[k] == extreme
            extreme_shift := k
            break
    [extreme, bar_index - extreme_shift]

archaeologist_jones(int bias) =>
    int i = 1
    bool artifact_found = false
    int max_shift = na
    float extreme = na
    for j = 1 to 500
        i := j
        int candle_attitude = close[i] > open[i] ? 1 : close[i] < open[i] ? -1 : 0
        if candle_attitude == 0
            continue
        bool is_correct_era = candle_attitude == bias
        if not artifact_found
            if is_correct_era
                artifact_found := true
                max_shift := i
                extreme := open[i]
        else
            if not is_correct_era
                break
            max_shift := i
            if bias == 1
                if open[i] < extreme
                    extreme := open[i]
            else
                if open[i] > extreme
                    extreme := open[i]
    int extreme_shift = na
    for k = 1 to max_shift
        if open[k] == extreme
            extreme_shift := k
            break
    [extreme, bar_index - extreme_shift]

if vibes == 0 and bar_index > 10
    int first_impression = close > open ? 1 : close < open ? -1 : 0
    if first_impression == 0
        for k = 1 to 50
            first_impression := close[k] > open[k] ? 1 : close[k] < open[k] ? -1 : 0
            if first_impression != 0
                break
    if first_impression != 0
        vibes := first_impression
        [origin_price, origin_time] = consult_the_crystal_ball(first_impression)
        bagholder_entry := origin_price
        time_machine_setting := origin_time
        pain_threshold := first_impression == 1 ? high : low

int candle_personality = close > open ? 1 : close < open ? -1 : 0
float fresh_hopium = na
int fresh_timestamp = na

if vibes == 1
    if high > pain_threshold
        pain_threshold := high
        if candle_personality == 1
            [p_price, p_idx] = consult_the_crystal_ball(1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        else
            [p_price, p_idx] = archaeologist_jones(1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        bagholder_entry := fresh_hopium
        time_machine_setting := fresh_timestamp

else if vibes == -1
    if low < pain_threshold
        pain_threshold := low
        if candle_personality == -1
            [p_price, p_idx] = consult_the_crystal_ball(-1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        else
            [p_price, p_idx] = archaeologist_jones(-1)
            fresh_hopium := p_price
            fresh_timestamp := p_idx
        bagholder_entry := fresh_hopium
        time_machine_setting := fresh_timestamp

bool shorts_squeezed = vibes == -1 and close > bagholder_entry
bool longs_rekt = vibes == 1 and close < bagholder_entry

if shorts_squeezed or longs_rekt
    bool should_i_paint_it = false
    
    if drama_filter == "Both"
        should_i_paint_it := true
    else if drama_filter == "Bullish Only"
        should_i_paint_it := shorts_squeezed
    else if drama_filter == "Bearish Only"
        should_i_paint_it := longs_rekt

    if should_i_paint_it
        color mood_ring = shorts_squeezed ? shrek_mode : blood_bath
        line tragedy_line = line.new(time_machine_setting, bagholder_entry, bar_index + elasticity_factor, bagholder_entry, color=mood_ring, width=girth_units, style=chosen_style)
        array.push(graveyard_of_hopes, tragedy_line)

        label loud_noise = na
        if yell_at_me
            int soapbox_location = na
            if stage_direction == "Left"
                soapbox_location := time_machine_setting
            else if stage_direction == "Right"
                soapbox_location := bar_index + elasticity_factor
            else
                soapbox_location := math.round((time_machine_setting + bar_index + elasticity_factor) / 2)

            string gibberish = shorts_squeezed ? "+CISD" : "-CISD"
            color ink_color = shorts_squeezed ? shrek_mode : blood_bath
            loud_noise := label.new(soapbox_location, bagholder_entry, gibberish, style=shorts_squeezed ? label.style_label_down : label.style_label_up, color=color.new(#000000, 100), textcolor=ink_color, size=scream_volume, text_font_family=fancy_typeface)
        
        array.push(choir_of_screams, loud_noise)

    int new_emotional_state = shorts_squeezed ? 1 : -1
    vibes := new_emotional_state
    [reset_price, reset_time] = consult_the_crystal_ball(new_emotional_state)
    bagholder_entry := reset_price
    time_machine_setting := reset_time
    pain_threshold := new_emotional_state == 1 ? high : low

color active_crayon = vibes == 1 ? shrek_mode : blood_bath

plot(magic_wand_toggle ? bagholder_entry : na, "Active CISD", color=active_crayon, linewidth=girth_units, style=plot.style_linebr)

if magic_wand_toggle and not na(bagholder_entry)
    label.delete(sticky_note_of_shame)
    string status_msg = vibes == 1 ? "+Active CISD" : "-Active CISD"
    sticky_note_of_shame := label.new(bar_index, bagholder_entry, status_msg, color=color.new(active_crayon, 100), textcolor=active_crayon, style=label.style_label_left, size=size.small, text_font_family=fancy_typeface)

int hoarding_limit = amnesia_mode ? short_term_memory : 450

if array.size(graveyard_of_hopes) > hoarding_limit
    int trash_accumulation = array.size(graveyard_of_hopes) - hoarding_limit
    for janitor_duty = 0 to trash_accumulation - 1
        line.delete(array.shift(graveyard_of_hopes))
        label.delete(array.shift(choir_of_screams))

plot(paranoia_switch ? pain_threshold : na, "Debug Extreme", color=color.orange, linewidth=2, style=plot.style_circles)

alertcondition(shorts_squeezed, title="Bullish CISD Trigger", message="Bullish CISD (+CISD) Triggered!")
alertcondition(longs_rekt, title="Bearish CISD Trigger", message="Bearish CISD (-CISD) Triggered!")

rumor_1 = request.security(syminfo.tickerid, tf1, vibes)
rumor_2 = request.security(syminfo.tickerid, tf2, vibes)
rumor_3 = request.security(syminfo.tickerid, tf3, vibes)
rumor_4 = request.security(syminfo.tickerid, tf4, vibes)
rumor_5 = request.security(syminfo.tickerid, tf5, vibes)
rumor_6 = request.security(syminfo.tickerid, tf6, vibes)
rumor_7 = request.security(syminfo.tickerid, tf7, vibes)
rumor_8 = request.security(syminfo.tickerid, tf8, vibes)

table_font_size = eye_test == "Tiny" ? size.tiny : eye_test == "Small" ? size.small : eye_test == "Large" ? size.large : size.normal

table_spot = feng_shui == "Top Right" ? position.top_right : 
             feng_shui == "Middle Right" ? position.middle_right : 
             feng_shui == "Bottom Left" ? position.bottom_left : 
             position.bottom_right

var table gossip_rag = table.new(table_spot, 2, 9, border_width=1, border_color=color.gray, frame_color=color.gray, frame_width=1)

judge_the_vibe(mood) => 
    mood == 1 ? shrek_mode : mood == -1 ? blood_bath : color.gray

translate_mood_swings(mood) => 
    mood == 1 ? "Bullish" : mood == -1 ? "Bearish" : "Loading"

if stalker_mode and barstate.islast
    table.cell(gossip_rag, 0, 0, "Timeframe", bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 0, "Trend Status", bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=table_font_size)
    
    table.cell(gossip_rag, 0, 1, tf1, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 1, translate_mood_swings(rumor_1), bgcolor=judge_the_vibe(rumor_1), text_color=color.white, text_size=table_font_size)
    
    table.cell(gossip_rag, 0, 2, tf2, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 2, translate_mood_swings(rumor_2), bgcolor=judge_the_vibe(rumor_2), text_color=color.white, text_size=table_font_size)

    table.cell(gossip_rag, 0, 3, tf3, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 3, translate_mood_swings(rumor_3), bgcolor=judge_the_vibe(rumor_3), text_color=color.white, text_size=table_font_size)

    table.cell(gossip_rag, 0, 4, tf4, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 4, translate_mood_swings(rumor_4), bgcolor=judge_the_vibe(rumor_4), text_color=color.white, text_size=table_font_size)

    table.cell(gossip_rag, 0, 5, tf5, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 5, translate_mood_swings(rumor_5), bgcolor=judge_the_vibe(rumor_5), text_color=color.white, text_size=table_font_size)

    table.cell(gossip_rag, 0, 6, tf6, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 6, translate_mood_swings(rumor_6), bgcolor=judge_the_vibe(rumor_6), text_color=color.white, text_size=table_font_size)

    table.cell(gossip_rag, 0, 7, tf7, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 7, translate_mood_swings(rumor_7), bgcolor=judge_the_vibe(rumor_7), text_color=color.white, text_size=table_font_size)

    table.cell(gossip_rag, 0, 8, tf8, bgcolor=color.new(color.black, 50), text_color=color.white, text_size=table_font_size)
    table.cell(gossip_rag, 1, 8, translate_mood_swings(rumor_8), bgcolor=judge_the_vibe(rumor_8), text_color=color.white, text_size=table_font_size)
````
