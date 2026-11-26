# Expected Move Box

- url: https://www.tradingview.com/script/fYWnulM7-Expected-Move-Box/
- type: indicator
- pine_id: PUB;799ff251dd7e47ada3c6781d1449361c
- version: 1.0

## Description

Insert the open price and the expected move in the settings to have a box with the expected move for the day.. Option to visualise past days estimated with ATR.

## Source Code

````pine
//@version=6
indicator("Expected Move Box (Manual + Optional History)", overlay=true, max_boxes_count=100, max_lines_count=100)

// --- Inputs ---
group_today  = "Today's Manual Input"
exp_move     = input.float(33.23, "Expected Move (+/- Points)", step=0.1, group=group_today)
manual_open  = input.float(5100.0, "Manual Open Price", group=group_today)

group_time   = "Time Settings (Berlin Time)"
start_hour   = input.int(15, "Start Hour", minval=0, maxval=23, group=group_time)
start_min    = input.int(30, "Start Minute", minval=0, maxval=59, group=group_time)
end_hour     = input.int(22, "End Hour", minval=0, maxval=23, group=group_time)
end_min      = input.int(0,  "End Minute", minval=0, maxval=59, group=group_time)

group_hist   = "Historical Footprint (Optional)"
show_history = input.bool(false, "Show Estimated History?", tooltip="Toggles the ATR-based historical boxes on/off", group=group_hist)
hist_days    = input.int(10, "History Lookback (Days)", minval=1, maxval=50, group=group_hist)
atr_mult     = input.float(1.5, "History Width (ATR Multiplier)", step=0.1, group=group_hist)

// --- Logic ---
bool is_new_day = ta.change(time("D")) != 0
string tz = "Europe/Berlin"

// Get today's timestamps for the manual box
int today_start = timestamp(tz, year(timenow), month(timenow), dayofmonth(timenow), start_hour, start_min)
int today_end   = timestamp(tz, year(timenow), month(timenow), dayofmonth(timenow), end_hour, end_min)

// Function to draw the set (Box + Center Line)
draw_set(int s_time, int e_time, float op, float move, bool is_today) =>
    color_box    = is_today ? color.new(color.blue, 85) : color.new(color.gray, 90)
    color_border = is_today ? color.blue : color.new(color.gray, 70)
    
    box.new(left = s_time, 
             top = op + move, 
             right = e_time, 
             bottom = op - move, 
             xloc = xloc.bar_time, 
             border_color = color_border, 
             bgcolor = color_box)
    
    line.new(x1 = s_time, 
             y1 = op, 
             x2 = e_time, 
             y2 = op, 
             xloc = xloc.bar_time, 
             color = color_border, 
             style = line.style_solid, 
             width = is_today ? 2 : 1)

// --- Execution ---

// 1. Draw Historical Footprint (Only if enabled in settings)
if show_history and is_new_day
    float hist_op   = open
    float hist_move = ta.atr(14) * atr_mult
    
    int h_start = timestamp(tz, year, month, dayofmonth, start_hour, start_min)
    int h_end   = timestamp(tz, year, month, dayofmonth, end_hour, end_min)
    
    if (timenow - time) < (hist_days * 86400000)
        draw_set(h_start, h_end, hist_op, hist_move, false)

// 2. Draw Today's Manual Box (Updates every tick)
var box today_box = na
var line today_line = na

if barstate.islast
    box.delete(today_box)
    line.delete(today_line)
    
    today_box := box.new(left = today_start, 
                         top = manual_open + exp_move, 
                         right = today_end, 
                         bottom = manual_open - exp_move, 
                         xloc = xloc.bar_time, 
                         border_color = color.blue, 
                         bgcolor = color.new(color.blue, 85))
                         
    today_line := line.new(x1 = today_start, 
                           y1 = manual_open, 
                           x2 = today_end, 
                           y2 = manual_open, 
                           xloc = xloc.bar_time, 
                           color = color.blue, 
                           width = 2)
````
