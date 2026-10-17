# Asia Range / DR / Killzone

- url: https://www.tradingview.com/script/OX2CLUqi-Asia-Range-DR-Killzone/
- type: indicator
- pine_id: PUB;fa302cce25734f02a3b193f26e786b78
- version: 4.0

## Description

Combined Session Hub: Asia Range + DR/IDR + Vertical Markers
This all-in-one session indicator is designed for intraday traders who prioritize precise visual structure and clean charts. It merges three essential trading tools into a single, high-performance script to help identify key liquidity zones and session expansions.

Key Features:
Custom Asia Range: Automatically plots a customizable box for the Asia session (19:00-00:00 (UTC-4)). This allows you to track overnight consolidation and potential "Asia Range" breakouts effortlessly.

DR/IDR Logic: Full implementation of the Defined Range (DR) and Institutional Defined Range (IDR) levels.

Supports both Regular (RDR) and Overnight (ODR) sessions.

Features dynamic directional coloring (Up/Down boxes) and automated line extensions.

Killzone trading session: Includes ultra-fine, white dotted vertical lines to mark the 10:00 and 13:00 (UTC-4) window. These markers help track afternoon volatility shifts or session transitions without cluttering price action.

Fully Customizable: Toggle any session on or off and adjust colors, line styles, and timezones directly from the settings menu.

## Source Code

````pine
//@version=5
indicator('Asia Range / DR / Killzone', overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ==========================================
// SECTION 1: ASIA RANGE (00:00 - 05:00 UTC+1)
// ==========================================
var GRP_ASIA = "Asia Session Settings"
asiashow = input.bool(true, "Display Asia Range", group=GRP_ASIA)
asiacolor = input.color(color.new(#ffcc80, 70), "Asia Range Color", group=GRP_ASIA)
asia_sess_input = input.session("0000-0500:23456", "Asia Session (UTC+1)", group=GRP_ASIA) // Defaulting to your 5am cutoff

// Asia Logic
in_asia = not na(time(timeframe.period, asia_sess_input, "UTC+1"))
asia_new = in_asia and not in_asia[1]

var float asia_high = na
var float asia_low = na
var box asia_box = na
var int asia_start_time = na

if asia_new
    asia_high := high
    asia_low := low
    asia_start_time := time
    if asiashow
        asia_box := box.new(asia_start_time, asia_high, time, asia_low, xloc=xloc.bar_time, bgcolor=asiacolor, border_color=asiacolor)
else if in_asia
    asia_high := math.max(high, asia_high)
    asia_low := math.min(low, asia_low)
    if asiashow
        box.set_top(asia_box, asia_high)
        box.set_bottom(asia_box, asia_low)
        box.set_right(asia_box, time)

// ==========================================
// SECTION 2: DR/IDR (Based on Screenshots)
// ==========================================
var GRP_DR_TIME = "DR/IDR Time Settings"
regularTime    = input.session('0930-1030', 'RDR Time', group=GRP_DR_TIME)
regularExtend  = input.session('1030-1600', 'RDR Lines Time', group=GRP_DR_TIME)
overnightTime  = input.session('0300-0400', 'ODR Time', group=GRP_DR_TIME)
overnightExtend= input.session('0400-0830', 'ODR Lines Time', group=GRP_DR_TIME)
// After sessions are removed/disabled by default as per your preference

var GRP_DR_GEN = "DR/IDR General Settings"
showRegular   = input.bool(true, 'Enable Regular (RDR)', group=GRP_DR_GEN)
showOvernight = input.bool(true, 'Enable Overnight (ODR)', group=GRP_DR_GEN)
drlines       = input.bool(true, 'Show DR Lines', group=GRP_DR_GEN)
idrlines      = input.bool(true, 'Show IDR Lines', group=GRP_DR_GEN)
showBackground = input.bool(true, 'Show DR/IDR Box', group=GRP_DR_GEN)
boxType       = input.string('IDR', 'Box DR or IDR?', options=['DR', 'IDR'], group=GRP_DR_GEN)

var GRP_DR_STYLE = "DR/IDR Styles"
drLineColor   = input.color(color.gray, 'DR Line Color', group=GRP_DR_STYLE)
idrLineColor  = input.color(#ff5252, 'IDR Line Color', group=GRP_DR_STYLE)
idrLineStyle  = input.string('Dashed', 'IDR Line Style', options=['Solid', 'Dashed', 'Dotted'], group=GRP_DR_STYLE)
lineWidth     = input.int(1, 'Line Width', minval=1, group=GRP_DR_STYLE)
upBoxColor    = input.color(color.new(color.green, 85), 'Up Box Fill', group=GRP_DR_STYLE)
downBoxColor  = input.color(color.new(color.red, 85), 'Down Box Fill', group=GRP_DR_STYLE)

// DR/IDR Variables
var float dr_high = na, var float dr_low = na
var float idr_high = na, var float idr_low = na
var int dr_start_time = na
var box dr_box = na
var line l_dr_hi = na, var line l_dr_lo = na
var line l_idr_hi = na, var line l_idr_lo = na

// Session Logic
in_rdr = not na(time(timeframe.period, regularTime, "America/New_York")) and showRegular
in_odr = not na(time(timeframe.period, overnightTime, "America/New_York")) and showOvernight
in_dr_sess = in_rdr or in_odr
dr_new = in_dr_sess and not in_dr_sess[1]

// Line Style Helper
get_style(s) => s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

if dr_new
    dr_start_time := time
    dr_high := high
    dr_low := low
    idr_high := math.max(open, close)
    idr_low := math.min(open, close)
    
    if showBackground
        dr_box := box.new(dr_start_time, na, time, na, xloc=xloc.bar_time, border_width=0)
    if drlines
        l_dr_hi := line.new(dr_start_time, dr_high, time, dr_high, xloc=xloc.bar_time, color=drLineColor, width=lineWidth)
        l_dr_lo := line.new(dr_start_time, dr_low, time, dr_low, xloc=xloc.bar_time, color=drLineColor, width=lineWidth)
    if idrlines
        l_idr_hi := line.new(dr_start_time, idr_high, time, idr_high, xloc=xloc.bar_time, color=idrLineColor, width=lineWidth, style=get_style(idrLineStyle))
        l_idr_lo := line.new(dr_start_time, idr_low, time, idr_low, xloc=xloc.bar_time, color=idrLineColor, width=lineWidth, style=get_style(idrLineStyle))

else if in_dr_sess
    dr_high := math.max(high, dr_high)
    dr_low := math.min(low, dr_low)
    idr_high := math.max(open, close, idr_high)
    idr_low := math.min(open, close, idr_low)
    
    // Update Drawings
    if showBackground
        box.set_top(dr_box, boxType == 'DR' ? dr_high : idr_high)
        box.set_bottom(dr_box, boxType == 'DR' ? dr_low : idr_low)
        box.set_right(dr_box, time)
        box.set_bgcolor(dr_box, close > open ? upBoxColor : downBoxColor)
    
    if drlines
        line.set_xy1(l_dr_hi, dr_start_time, dr_high), line.set_xy2(l_dr_hi, time, dr_high)
        line.set_xy1(l_dr_lo, dr_start_time, dr_low), line.set_xy2(l_dr_lo, time, dr_low)
    if idrlines
        line.set_xy1(l_idr_hi, dr_start_time, idr_high), line.set_xy2(l_idr_hi, time, idr_high)
        line.set_xy1(l_idr_lo, dr_start_time, idr_low), line.set_xy2(l_idr_lo, time, idr_low)

// Extension Logic (RDR/ODR Extension)
in_rdr_ext = not na(time(timeframe.period, regularExtend, "America/New_York")) and showRegular
in_odr_ext = not na(time(timeframe.period, overnightExtend, "America/New_York")) and showOvernight
in_ext = in_rdr_ext or in_odr_ext

if in_ext
    if showBackground
        box.set_right(dr_box, time)
    if drlines
        line.set_x2(l_dr_hi, time)
        line.set_x2(l_dr_lo, time)
    if idrlines
        line.set_x2(l_idr_hi, time)
        line.set_x2(l_idr_lo, time)



// ==========================================
// SECTION 3: VERTICAL POINTED WHITE LINES (3pm - 6pm UTC+1)
// ==========================================
var GRP_V = "Vertical Lines (3pm-6pm UTC+1)"
show_v = input.bool(true, "Show Vertical Lines", group=GRP_V)

// Checking for the 3 PM and 6 PM bars in UTC+1
v_start = not na(time(timeframe.period, "1500-1501", "UTC+1"))
v_end   = not na(time(timeframe.period, "1800-1801", "UTC+1"))

if show_v and timeframe.period == "1"
    if v_start
        line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=color.rgb(0, 0, 0), style=line.style_dotted, width=1)
    if v_end
        line.new(time, low, time, high, xloc=xloc.bar_time, extend=extend.both, color=color.rgb(0, 0, 0), style=line.style_dotted, width=1)


// ==========================================
// ==========================================
````
