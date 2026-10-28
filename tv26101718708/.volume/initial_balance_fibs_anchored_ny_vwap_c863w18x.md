# Initial Balance Fibs & Anchored NY VWAP

- url: https://www.tradingview.com/script/C863W18X-Initial-Balance-Fibs-Anchored-NY-VWAP/
- type: indicator
- pine_id: PUB;f1bd60742daa4417a48f010cb878533f
- version: 1.0

## Description

custom indicator for those who uses Initial Balance trading strategy. IB25/75% and 50% strategy & Anchored VWAP

## Source Code

````pine
//@version=5
indicator("Initial Balance Fibs & Anchored VWAP (Strict Cutoff)", overlay=true)

// --- Inputs ---
ib_session    = input.session("0930-1030", "Initial Balance Period (1 Hour)")
trade_session = input.session("1030-1600", "Trading Period (Post-IB)")
tz            = input.string("America/New_York", "Exchange Timezone")
lbl_padding   = input.int(30, "Label Vertical Padding (Ticks/Points)", minval=0)
show_vwap     = input.bool(true, "Show 9:30 AM Anchored VWAP")

// --- Color Customization Inputs ---
color_100_0   = input.color(color.blue, "100% & 0% Color")
color_50      = input.color(color.purple, "50% Mid-Line Color")
color_75_25   = input.color(color.orange, "75% & 25% Color")

// --- Session Logic ---
in_ib      = not na(time(timeframe.period, ib_session, tz))
in_trading = not na(time(timeframe.period, trade_session, tz))
is_new_day = ta.change(time("D", tz)) != 0

// --- Track Extremes Natively ---
var float ib_high = na
var float ib_low  = na

// Capture the exact time anchors for the day
var int ib_start_time = na
var int rth_end_time  = na

if is_new_day
    ib_high := na
    ib_low  := na
    ib_start_time := na
    rth_end_time  := na

if in_ib
    // Log the exact opening time of the 09:30 session
    if na(ib_start_time)
        ib_start_time := time
        
    ib_high := na(ib_high) ? high : math.max(ib_high, high)
    ib_low  := na(ib_low) ? low  : math.min(ib_low, low)

// Dynamically compute the exact 16:00 timestamp for the current day
if (in_trading or in_ib) and na(rth_end_time)
    int year_val  = year(time, tz)
    int month_val = month(time, tz)
    int day_val   = dayofmonth(time, tz)
    rth_end_time := timestamp(tz, year_val, month_val, day_val, 16, 0, 0)

// --- Anchored VWAP Calculation Engine ---
is_vwap_anchor = in_ib and not in_ib[1] or (in_ib and na(ib_start_time[1]))

var float vwap_sum_pv = na
var float vwap_sum_v  = na

if is_vwap_anchor or is_new_day
    vwap_sum_pv := hlcc4 * volume
    vwap_sum_v  := volume
else if in_ib or in_trading
    vwap_sum_pv := vwap_sum_pv + (hlcc4 * volume)
    vwap_sum_v  := vwap_sum_v + volume

anchored_vwap = (vwap_sum_v > 0) ? (vwap_sum_pv / vwap_sum_v) : na

// --- Precise Hour/Minute Visual Gatekeeper ---
bar_hour   = hour(time, tz)
bar_minute = minute(time, tz)
time_value = bar_hour * 100 + bar_minute

is_rth_hours = (time_value >= 0930) and (time_value <= 1600)
display_vwap = show_vwap and is_rth_hours ? anchored_vwap : na

// Plot the filtered VWAP line smoothly across the active RTH block
plot(display_vwap, title="Anchored VWAP (9:30)", color=color.teal, linewidth=2, style=plot.style_line)

// --- Calculate Fibonacci Retracements ---
ib_range = ib_high - ib_low
lvl_100  = ib_high
lvl_75   = ib_high - (ib_range * 0.25)
lvl_50   = ib_high - (ib_range * 0.50)
lvl_25   = ib_high - (ib_range * 0.75)
lvl_0    = ib_low

// --- Persistent Lines & Inline Text Labels ---
var line ln_100 = na, var label lbl_100 = na
var line ln_75  = na, var label lbl_75  = na
var line ln_50  = na, var label lbl_50  = na
var line ln_25  = na, var label lbl_25  = na
var line ln_0   = na, var label lbl_0   = na

if is_new_day
    ln_100 := na, lbl_100 := na
    ln_75  := na, lbl_75  := na
    ln_50  := na, lbl_50  := na
    ln_25  := na, lbl_25  := na
    ln_0   := na, lbl_0   := na

// Execute placements when the initial balance values have resolved
if (in_trading or not in_ib) and not na(lvl_100) and not na(ib_start_time) and not na(rth_end_time)
    str_100 = "100% (" + str.tostring(lvl_100, "#.##") + ")"
    str_75  = "75% ("  + str.tostring(lvl_75,  "#.##") + ")"
    str_50  = "50% ("  + str.tostring(lvl_50,  "#.##") + ")"
    str_25  = "25% ("  + str.tostring(lvl_25,  "#.##") + ")"
    str_0   = "0% ("   + str.tostring(lvl_0,   "#.##") + ")"

    label_offset = syminfo.mintick * lbl_padding

    if na(ln_100)
        // Draw lines using custom inputs
        ln_100 := line.new(ib_start_time, lvl_100, rth_end_time, lvl_100, xloc=xloc.bar_time, color=color_100_0, width=2, extend=extend.none)
        ln_75  := line.new(ib_start_time, lvl_75,  rth_end_time, lvl_75,  xloc=xloc.bar_time, color=color_75_25, width=1, extend=extend.none)
        ln_50  := line.new(ib_start_time, lvl_50,  rth_end_time, lvl_50,  xloc=xloc.bar_time, color=color_50,    width=2, extend=extend.none)
        ln_25  := line.new(ib_start_time, lvl_25,  rth_end_time, lvl_25,  xloc=xloc.bar_time, color=color_75_25, width=1, extend=extend.none)
        ln_0   := line.new(ib_start_time, lvl_0,   rth_end_time, lvl_0,   xloc=xloc.bar_time, color=color_100_0, width=2, extend=extend.none)

        // Lock text labels and match colors cleanly
        lbl_100 := label.new(ib_start_time, lvl_100 + label_offset, str_100, xloc=xloc.bar_time, style=label.style_label_left, color=#00000000, textcolor=color_100_0, size=size.small)
        lbl_75  := label.new(ib_start_time, lvl_75 + label_offset,  str_75,  xloc=xloc.bar_time, style=label.style_label_left, color=#00000000, textcolor=color_75_25, size=size.small)
        lbl_50  := label.new(ib_start_time, lvl_50 + label_offset,  str_50,  xloc=xloc.bar_time, style=label.style_label_left, color=#00000000, textcolor=color_50,    size=size.small)
        lbl_25  := label.new(ib_start_time, lvl_25 + label_offset,  str_25,  xloc=xloc.bar_time, style=label.style_label_left, color=#00000000, textcolor=color_75_25, size=size.small)
        lbl_0   := label.new(ib_start_time, lvl_0 + label_offset,   str_0,   xloc=xloc.bar_time, style=label.style_label_left, color=#00000000, textcolor=color_100_0, size=size.small)
````
