# R3D Jackofxc RTP Strategy

- url: https://www.tradingview.com/script/cDlbEBF7-R3D-Jackofxc-RTP-Strategy/
- type: indicator
- pine_id: PUB;1a1b7cd0d6c64527ba7a8dfd5f267d7e
- version: 5.0

## Description

This tool strictly automates the Jackofxc strategy based on the range of the 3-hour candle starting at 12:00, looking for a liquidity sweep reversal (Turtle Soup) towards the equilibrium level.

[b]Exact Operating Mechanics[/b]
[list=1]
[*]Reference Range (3H Candle): The indicator encloses the high and low specifically formed by the 3-hour candle that opens at 12:00 (ends at 15:00). This range defines the key liquidity of the day.
[*]Liquidity Hunt (Turtle Soup): Upon the opening of the next time window (15:00), a price manipulation is expected. If the price sweeps the previous high, it sets up a bearish Turtle Soup; if it sweeps the low, it sets up a bullish Turtle Soup.
[*]Dynamic Expansion: As long as the price continues to expand and create new highs or lows during the breakout, the indicator updates the 50% level in real-time.
[*]Equilibrium Entry (50%): The entry is executed on the pullback, exactly when the price mitigates the 50% level measured between the newly generated extreme (the peak of the liquidity sweep) and the opposite end of the 12:00 candle.
[*]Risk Management (1:1): Upon touching the 50% level, a symmetrical order is automatically projected. The Stop Loss is placed at the extreme of the manipulation wick and the Take Profit at the same distance (1:1 Ratio).
[/list=1]

## Source Code

````pine
//@version=6
indicator("R3D Jackofxc RTP Strategy", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// --- INPUTS: SCHEDULES ---
grp_time      = "Session Schedule"
session_time  = input.session("1200-1500", title="1. Initial Range Session", group=grp_time)
breakout_time = input.session("1500-1700", title="2. Breakout Window (Hunt)", group=grp_time)
entry_time    = input.session("1500-1700", title="3. Entry Window (Retracement)", group=grp_time)
tz            = input.string("Europe/Madrid", title="Timezone", group=grp_time)

// --- INPUTS: POSITION ---
grp_pos       = "Position Settings"
rr_target     = input.float(1.0, title="Risk/Reward Target", step=0.5, minval=0.1, group=grp_pos)
trade_len     = input.int(5, title="Visual Box Width (Bars)", minval=1, group=grp_pos)
show_pos      = input.bool(true, title="Show Position Boxes & Labels", group=grp_pos)
show_prices   = input.bool(true, title="Show EP / SL / TP Prices", group=grp_pos)

// --- INPUTS: INITIAL RANGE PROJECTIONS ---
grp_proj_lines  = "Initial Range Lines (High / Low)"
show_range_lines= input.bool(true, title="Project High/Low Lines", group=grp_proj_lines)
col_line_high   = input.color(color.new(color.red, 30), title="High Line Color", group=grp_proj_lines)
col_line_low    = input.color(color.new(color.green, 30), title="Low Line Color", group=grp_proj_lines)
width_range_line= input.int(1, title="Line Width", minval=1, maxval=4, group=grp_proj_lines)
style_range_str = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_proj_lines)

// --- INPUTS: RETRACEMENT LEVEL ---
grp_entry_lvl = "Retracement Level (Entry)"
retrace_pct   = input.float(50.0, title="Retracement Level (%)", minval=0.0, maxval=100.0, step=5.0, group=grp_entry_lvl)
col_entry_bear= input.color(color.red, title="Short Entry Line Color", group=grp_entry_lvl)
col_entry_bull= input.color(color.green, title="Long Entry Line Color", group=grp_entry_lvl)
width_eq_line = input.int(2, title="Retracement Line Width", minval=1, maxval=4, group=grp_entry_lvl)
style_eq_str  = input.string("Solid", title="Retracement Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_entry_lvl)

// --- INPUTS: INITIAL BOX STYLE ---
grp_init_box      = "Initial Box Style"
col_init_bg       = input.color(color.new(color.blue, 92), title="Background Color", group=grp_init_box)
col_init_border   = input.color(color.new(color.blue, 30), title="Border Color", group=grp_init_box)
width_init_border = input.int(1, title="Border Width", minval=1, maxval=4, group=grp_init_box)
style_init_str    = input.string("Solid", title="Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_init_box)

// --- INPUTS: HUNT BOX STYLE ---
grp_hunt_box      = "Hunt Box Style (Breakout)"
col_hunt_bg       = input.color(color.new(color.purple, 95), title="Background Color", group=grp_hunt_box)
col_hunt_border   = input.color(color.new(color.gray, 40), title="Border Color", group=grp_hunt_box)
width_hunt_border = input.int(1, title="Border Width", minval=1, maxval=4, group=grp_hunt_box)
style_hunt_str    = input.string("Dashed", title="Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_hunt_box)

// --- INPUTS: POSITION COLORS ---
grp_colors = "Position Colors"
col_tp     = input.color(color.blue, title="TP Color", group=grp_colors)
col_sl     = input.color(color.gray, title="SL Color", group=grp_colors)

// --- INPUTS: ALERTS ---
grp_alerts        = "Alert Settings"
alert_on_breakout = input.bool(true, title="Enable Breakout Alert (Hunt)", group=grp_alerts)
alert_on_entry    = input.bool(true, title="Enable Entry Alert (Setup Trigger)", group=grp_alerts)

// --- LINE STYLE PARSER ---
get_line_style(style_str) =>
    switch style_str
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

style_init_border  = get_line_style(style_init_str)
style_hunt_border  = get_line_style(style_hunt_str)
style_eq_line      = get_line_style(style_eq_str)
style_range_line   = get_line_style(style_range_str)

pct_factor = retrace_pct / 100.0

// --- STATE VARIABLES ---
var float box_high    = na
var float box_low     = na
var int box_start_bar = na
var box current_box   = na

var line line_high    = na
var line line_low     = na

var bool broke_up     = false
var bool broke_down   = false
var float swing_high  = na
var float swing_low   = na
var int swing_bar     = na 
var box second_box    = na
var line eq_line      = na
var bool touched_entry= false 

// --- SESSION TIMING ---
in_session    = not na(time(timeframe.period, session_time, tz))
in_breakout   = not na(time(timeframe.period, breakout_time, tz))
in_entry      = not na(time(timeframe.period, entry_time, tz))
session_start = in_session and not in_session[1]

// --- INITIAL RANGE LOGIC ---
if session_start
    box_high      := high
    box_low       := low
    box_start_bar := bar_index
    broke_up      := false
    broke_down    := false
    swing_high    := na
    swing_low     := na
    swing_bar     := na
    touched_entry := false
    
    current_box   := box.new(left=bar_index, top=box_high, right=bar_index, bottom=box_low, 
                             border_color=col_init_border, border_width=width_init_border, 
                             border_style=style_init_border, bgcolor=col_init_bg)
    
    if show_range_lines
        line_high := line.new(x1=bar_index, y1=box_high, x2=bar_index, y2=box_high, 
                              color=col_line_high, width=width_range_line, style=style_range_line)
        line_low  := line.new(x1=bar_index, y1=box_low, x2=bar_index, y2=box_low, 
                              color=col_line_low, width=width_range_line, style=style_range_line)

if in_session and not session_start
    box_high := math.max(box_high, high)
    box_low  := math.min(box_low, low)
    box.set_top(current_box, box_high)
    box.set_bottom(current_box, box_low)
    box.set_right(current_box, bar_index)
    
    if show_range_lines and not na(line_high) and not na(line_low)
        line.set_y1(line_high, box_high)
        line.set_y2(line_high, box_high)
        line.set_x2(line_high, bar_index)
        
        line.set_y1(line_low, box_low)
        line.set_y2(line_low, box_low)
        line.set_x2(line_low, bar_index)

// Extend range lines into post-session window prior to breakout
if not broke_up and not broke_down and not in_session
    if show_range_lines
        if not na(line_high)
            line.set_x2(line_high, bar_index)
        if not na(line_low)
            line.set_x2(line_low, bar_index)

// --- BREAKOUT LOGIC (HUNT) ---
if in_breakout and not broke_up and not broke_down
    // Bullish Breakout (Hunt High -> Anticipating Short)
    if high > box_high 
        broke_up   := true
        swing_high := high
        swing_bar  := bar_index 
        
        // Terminate High line at cross bar; remove opposing Low line
        if show_range_lines
            if not na(line_high)
                line.set_x2(line_high, bar_index)
            if not na(line_low)
                line.delete(line_low)
                line_low := na
        
        second_box := box.new(left=bar_index, top=swing_high, right=bar_index, bottom=box_low, 
                              border_color=col_hunt_border, border_width=width_hunt_border, 
                              border_style=style_hunt_border, bgcolor=col_hunt_bg)
        float level_target = swing_high - ((swing_high - box_low) * pct_factor)
        eq_line := line.new(x1=bar_index, y1=level_target, x2=bar_index, y2=level_target, 
                            color=col_entry_bear, width=width_eq_line, style=style_eq_line)
        
        if alert_on_breakout
            alert("Bullish Hunt Breakout detected - Waiting for Short entry | " + syminfo.ticker, alert.freq_once_per_bar)
        
    // Bearish Breakout (Hunt Low -> Anticipating Long)
    else if low < box_low 
        broke_down := true
        swing_low  := low
        swing_bar  := bar_index 
        
        // Terminate Low line at cross bar; remove opposing High line
        if show_range_lines
            if not na(line_low)
                line.set_x2(line_low, bar_index)
            if not na(line_high)
                line.delete(line_high)
                line_high := na
        
        second_box := box.new(left=bar_index, top=box_high, right=bar_index, bottom=swing_low, 
                              border_color=col_hunt_border, border_width=width_hunt_border, 
                              border_style=style_hunt_border, bgcolor=col_hunt_bg)
        float level_target = swing_low + ((box_high - swing_low) * pct_factor)
        eq_line := line.new(x1=bar_index, y1=level_target, x2=bar_index, y2=level_target, 
                            color=col_entry_bull, width=width_eq_line, style=style_eq_line)
        
        if alert_on_breakout
            alert("Bearish Hunt Breakout detected - Waiting for Long entry | " + syminfo.ticker, alert.freq_once_per_bar)

// --- DYNAMIC TRACKING & ENTRY EXECUTION ---
if broke_up and not touched_entry
    float level_target = swing_high - ((swing_high - box_low) * pct_factor)
    
    if high > swing_high
        swing_high := high
        swing_bar  := bar_index 
        box.set_top(second_box, swing_high)
        level_target := swing_high - ((swing_high - box_low) * pct_factor)
        line.set_y1(eq_line, level_target)
        line.set_y2(eq_line, level_target)
        
    if bar_index > swing_bar and low <= level_target
        touched_entry := true
        if in_entry
            float risk     = swing_high - level_target
            float tp_price = level_target - (risk * rr_target)
            
            if show_pos
                box.new(left=bar_index, top=level_target, right=bar_index + trade_len, bottom=tp_price, bgcolor=color.new(col_tp, 85), border_color=col_tp)
                box.new(left=bar_index, top=swing_high, right=bar_index + trade_len, bottom=level_target, bgcolor=color.new(col_sl, 85), border_color=col_sl)
                
                string txt = "SELL 1:" + str.tostring(rr_target)
                if show_prices
                    txt += "\nEP: " + str.tostring(level_target, "#.##") + "\nSL: " + str.tostring(swing_high, "#.##") + "\nTP: " + str.tostring(tp_price, "#.##")
                
                label.new(x=bar_index, y=swing_high, text=txt, style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.small)
            
            if alert_on_entry
                alert("SELL Entry @ " + str.tostring(level_target, "#.##") + " | SL: " + str.tostring(swing_high, "#.##") + " | TP: " + str.tostring(tp_price, "#.##"), alert.freq_once_per_bar)

if broke_down and not touched_entry
    float level_target = swing_low + ((box_high - swing_low) * pct_factor)
    
    if low < swing_low
        swing_low := low
        swing_bar := bar_index 
        box.set_bottom(second_box, swing_low)
        level_target := swing_low + ((box_high - swing_low) * pct_factor)
        line.set_y1(eq_line, level_target)
        line.set_y2(eq_line, level_target)
        
    if bar_index > swing_bar and high >= level_target
        touched_entry := true
        if in_entry
            float risk     = level_target - swing_low
            float tp_price = level_target + (risk * rr_target)
            
            if show_pos
                box.new(left=bar_index, top=tp_price, right=bar_index + trade_len, bottom=level_target, bgcolor=color.new(col_tp, 85), border_color=col_tp)
                box.new(left=bar_index, top=level_target, right=bar_index + trade_len, bottom=swing_low, bgcolor=color.new(col_sl, 85), border_color=col_sl)
                
                string txt = "BUY 1:" + str.tostring(rr_target)
                if show_prices
                    txt += "\nEP: " + str.tostring(level_target, "#.##") + "\nSL: " + str.tostring(swing_low, "#.##") + "\nTP: " + str.tostring(tp_price, "#.##")
                
                label.new(x=bar_index, y=swing_low, text=txt, style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=size.small)
            
            if alert_on_entry
                alert("BUY Entry @ " + str.tostring(level_target, "#.##") + " | SL: " + str.tostring(swing_low, "#.##") + " | TP: " + str.tostring(tp_price, "#.##"), alert.freq_once_per_bar)

// --- VISUAL EXTENSION ---
if (broke_up or broke_down) and in_breakout
    box.set_right(second_box, bar_index)
    line.set_x2(eq_line, bar_index)
````
