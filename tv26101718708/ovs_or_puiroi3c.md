# OVS OR

- url: https://www.tradingview.com/script/PuiROI3C-OVS-OR/
- type: indicator
- pine_id: PUB;78131795b75e44708bcd4410ee665f77
- version: 1.0

## Description

Opening Range 
Cash market open first 60mins creates the High / Low and 50% level
These levels have proven to be used time and time again. 

This is not a stand alone strat it needs to be paired with patterns / key levels

Patterns
Double tops
Closes above the level indicating buying
Flag patterns
Stair step patterns

Back test 50 - 100 trades before considering these levels. 
Never use anything that doesn't bring value.

## Source Code

````pine
//@version=6
indicator("OVS OR", overlay=true, max_bars_back=5000)

// inputs
show_table = input.bool(true, "Display Data Panel", group = "options")
opening_session = input.session("0830-0930", "Opening Range Session Time", group = "time")
timeZone = input.string("UTC-5", title="Time Zone", group = "time")
main_color = input.color(color.gray, "Main Color", group = "line settings")
sub_color = input.color(color.new(color.gray,40), "Mid/50% Line Color", group = "line settings")
dh_color = input.color(color.red, "Data High Color", group="line settings")
dl_color = input.color(color.blue, "Data Low Color", group="line settings")
main_width = input.int(1, "Main Plot Width (top & bottom)", group = "line settings")
sub_width = input.int(1, "Mid Plot Width", group = "line settings")

// label settings
label_size        = input.string("Normal", title="Label Size", options=["Auto", "Huge", "Large", "Normal", "Small", "Tiny"], group="label settings")
label_text_color  = input.color(color.white,                    "Label Text Color",       group="label settings")
label_bg_color    = input.color(color.rgb(40, 40, 40, 20),      "Label Background Color", group="label settings")
label_style       = input.string("Background Box", title="Label Style", options=["Background Box", "No Background"], group="label settings")
label_x_offset    = input.int(9,   "Label Horizontal Offset (bars)", minval=-100, maxval=200, group="label settings")
label_y_offset    = input.float(0.0, "Label Vertical Offset (price)",  step=0.01,             group="label settings")

// variables
opening_high = float(-1)
opening_low = float(-1)
opening_range_hour = int(str.tonumber(array.get(str.split(opening_session, "-"), 1))/100)-int(str.tonumber(array.get(str.split(opening_session, "-"), 0))/100)
opening_range_minute = int(str.tonumber(array.get(str.split(opening_session, "-"), 1))%100)-int(str.tonumber(array.get(str.split(opening_session, "-"), 0))%100)
opening_range_in_minutes = opening_range_hour*60+opening_range_minute
current_time = hour(time, timeZone)*100+minute(time, timeZone)
dt = (time-time[1])/60000
bars_till_next_opening_range = (1440-opening_range_in_minutes)/dt
var offset = 0
var int close_above_oh_20days = 0
var int close_below_ol_20days = 0

// float variables
var float rda_sum = na
var float rda_avg = na
var float higher_mid = na
var float lower_mid = na
var float high_avg = na
var float low_avg = na
var float last_week_delta = na
var float this_week_delta = na
var float test = 0

// opening high variables
var float h1 = na
var float h2 = na
var float h3 = na
var float h4 = na
var float h5 = na
var float h6 = na
var float h7 = na
var float h8 = na
var float h9 = na
var float h10 = na

var float oh1 = na
var float oh2 = na
var float oh3 = na
var float oh4 = na
var float oh5 = na
var float oh6 = na
var float oh7 = na
var float oh8 = na
var float oh9 = na
var float oh10 = na
var float oh11 = na
var float oh12 = na
var float oh13 = na
var float oh14 = na
var float oh15 = na
var float oh16 = na
var float oh17 = na
var float oh18 = na
var float oh19 = na
var float oh20 = na

// opening low variables
var float l1 = na
var float l2 = na
var float l3 = na
var float l4 = na
var float l5 = na
var float l6 = na
var float l7 = na
var float l8 = na
var float l9 = na
var float l10 = na

var float ol1 = na
var float ol2 = na
var float ol3 = na
var float ol4 = na
var float ol5 = na
var float ol6 = na
var float ol7 = na
var float ol8 = na
var float ol9 = na
var float ol10 = na
var float ol11 = na
var float ol12 = na
var float ol13 = na
var float ol14 = na
var float ol15 = na
var float ol16 = na
var float ol17 = na
var float ol18 = na
var float ol19 = na
var float ol20 = na

// close variables
var float c1 = na
var float c2 = na
var float c3 = na
var float c4 = na
var float c5 = na
var float c6 = na
var float c7 = na
var float c8 = na
var float c9 = na
var float c10 = na
var float c11 = na
var float c12 = na
var float c13 = na
var float c14 = na
var float c15 = na
var float c16 = na
var float c17 = na
var float c18 = na
var float c19 = na
var float c20 = na

// drawing variables
var label ohl  = na
var label oll  = na
var label midl = na
var table rda_analytics = table.new(position.bottom_left, 2, 6)

labelSize = switch label_size
    "Huge"   => size.huge
    "Large"  => size.large
    "Small"  => size.small
    "Tiny"   => size.tiny
    "Auto"   => size.auto
    => size.normal

labelStyle = label_style == "Background Box" ? label.style_label_left : label.style_none

// functions
InSession(sessionTimes) =>
    not na(time(timeframe.period, sessionTimes, timeZone))

// calculating opening high
if(InSession(opening_session) and not InSession(opening_session)[1])
    opening_high := high
else if(InSession(opening_session) and high > opening_high[1])
    opening_high := high
else
    opening_high := opening_high[1]

// calculating opening low
if(InSession(opening_session) and not InSession(opening_session)[1])
    opening_low := low
else if(InSession(opening_session) and low < opening_low[1])
    opening_low := low
else
    opening_low := opening_low[1]

// updating
if(InSession(opening_session))
    offset += 1

// Opening range
if InSession(opening_session)[1] and not InSession(opening_session)
    h5 := h4
    h4 := h3
    h3 := h2
    h2 := h1
    h1 := opening_high
    l5 := l4
    l4 := l3
    l3 := l2
    l2 := l1
    l1 := opening_low
    this_week_delta := (h5+h4+h3+h2+h1-l5-l4-l3-l2-l1)/(dayofweek(time, timeZone)-1)
    offset := 0

// Updating table stuff
if dayofweek(time, timeZone) == 1 and (hour(time, timeZone) >= 17 and hour(time, timeZone)[1] < 17)
    h6 := h1
    h7 := h2
    h8 := h3
    h9 := h4
    h10 := h5
    l6 := l1
    l7 := l2
    l8 := l3
    l9 := l4
    l10 := l5
    h1 := 0
    h2 := 0
    h3 := 0
    h4 := 0
    h5 := 0
    l1 := 0
    l2 := 0
    l3 := 0
    l4 := 0
    l5 := 0
    last_week_delta := (h6+h7+h8+h9+h10-(l6+l7+l8+l9+l10))/5
    this_week_delta := 0

// Record close above/below OR
if (hour(time, timeZone)==15 and hour(time, timeZone)[1] < 15)
    close_above_oh_20days := 0
    close_below_ol_20days := 0
    test := 1
    oh20 := oh19
    oh19 := oh18
    oh18 := oh17
    oh17 := oh16
    oh16 := oh15
    oh15 := oh14
    oh14 := oh13
    oh13 := oh12
    oh12 := oh11
    oh11 := oh10
    oh10 := oh9
    oh9  := oh8
    oh8  := oh7
    oh7  := oh6
    oh6  := oh5
    oh5  := oh4
    oh4  := oh3
    oh3  := oh2
    oh2  := oh1
    oh1  := opening_high
    ol20 := ol19
    ol19 := ol18
    ol18 := ol17
    ol17 := ol16
    ol16 := ol15
    ol15 := ol14
    ol14 := ol13
    ol13 := ol12
    ol12 := ol11
    ol11 := ol10
    ol10 := ol9
    ol9  := ol8
    ol8  := ol7
    ol7  := ol6
    ol6  := ol5
    ol5  := ol4
    ol4  := ol3
    ol3  := ol2
    ol2  := ol1
    ol1  := opening_low
    c20 := c19
    c19 := c18
    c18 := c17
    c17 := c16
    c16 := c15
    c15 := c14
    c14 := c13
    c13 := c12
    c12 := c11
    c11 := c10
    c10 := c9
    c9  := c8
    c8  := c7
    c7  := c6
    c6  := c5
    c5  := c4
    c4  := c3
    c3  := c2
    c2  := c1
    c1  := close

    if (oh20 < c20)
        close_above_oh_20days += 1
    if (oh19 < c19)
        close_above_oh_20days += 1
    if (oh18 < c18)
        close_above_oh_20days += 1
    if (oh17 < c17)
        close_above_oh_20days += 1
    if (oh16 < c16)
        close_above_oh_20days += 1
    if (oh15 < c15)
        close_above_oh_20days += 1
    if (oh14 < c14)
        close_above_oh_20days += 1
    if (oh13 < c13)
        close_above_oh_20days += 1
    if (oh12 < c12)
        close_above_oh_20days += 1
    if (oh11 < c11)
        close_above_oh_20days += 1
    if (oh10 < c10)
        close_above_oh_20days += 1
    if (oh9 < c9)
        close_above_oh_20days += 1
    if (oh8 < c8)
        close_above_oh_20days += 1
    if (oh7 < c7)
        close_above_oh_20days += 1
    if (oh6 < c6)
        close_above_oh_20days += 1
    if (oh5 < c5)
        close_above_oh_20days += 1
    if (oh4 < c4)
        close_above_oh_20days += 1
    if (oh3 < c3)
        close_above_oh_20days += 1
    if (oh2 < c2)
        close_above_oh_20days += 1
    if (oh1 < c1)
        close_above_oh_20days += 1

    if (ol20 > c20)
        close_below_ol_20days += 1
    if (ol19 > c19)
        close_below_ol_20days += 1
    if (ol18 > c18)
        close_below_ol_20days += 1
    if (ol17 > c17)
        close_below_ol_20days += 1
    if (ol16 > c16)
        close_below_ol_20days += 1
    if (ol15 > c15)
        close_below_ol_20days += 1
    if (ol14 > c14)
        close_below_ol_20days += 1
    if (ol13 > c13)
        close_below_ol_20days += 1
    if (ol12 > c12)
        close_below_ol_20days += 1
    if (ol11 > c11)
        close_below_ol_20days += 1
    if (ol10 > c10)
        close_below_ol_20days += 1
    if (ol9 > c9)
        close_below_ol_20days += 1
    if (ol8 > c8)
        close_below_ol_20days += 1
    if (ol7 > c7)
        close_below_ol_20days += 1
    if (ol6 > c6)
        close_below_ol_20days += 1
    if (ol5 > c5)
        close_below_ol_20days += 1
    if (ol4 > c4)
        close_below_ol_20days += 1
    if (ol3 > c3)
        close_below_ol_20days += 1
    if (ol2 > c2)
        close_below_ol_20days += 1
    if (ol1 > c1)
        close_below_ol_20days += 1

// ═══════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════
bgcolor(InSession(opening_session) and timeframe.isintraday ? color.new(color.gray, 80) : na)

main_color := InSession(opening_session) and not InSession(opening_session)[1] ? na : main_color
sub_color  := InSession(opening_session) and not InSession(opening_session)[1] ? na : sub_color

plot(opening_high,                     "Opening High", color=timeframe.isintraday ? main_color : na, style=plot.style_line, linewidth=main_width)
plot(opening_low,                      "Opening Low",  color=timeframe.isintraday ? main_color : na, style=plot.style_line, linewidth=main_width)
plot((opening_high+opening_low)/2,     "Opening Mid",  color=timeframe.isintraday ? sub_color  : na, style=plot.style_line, linewidth=sub_width)

// ═══════════════════════════════════════
// LABELS
// ═══════════════════════════════════════
label.delete(ohl)
label.delete(oll)
label.delete(midl)

mid_price = (opening_high + opening_low) / 2

ohl  := label.new(bar_index + label_x_offset, opening_high + label_y_offset, "OH: "  + str.tostring(opening_high, "#.##"), style=labelStyle, color=label_bg_color, textcolor=label_text_color, size=labelSize, textalign=text.align_left)
oll  := label.new(bar_index + label_x_offset, opening_low  + label_y_offset, "OL: "  + str.tostring(opening_low,  "#.##"), style=labelStyle, color=label_bg_color, textcolor=label_text_color, size=labelSize, textalign=text.align_left)
midl := label.new(bar_index + label_x_offset, mid_price    + label_y_offset, "Mid: " + str.tostring(mid_price,    "#.##"), style=labelStyle, color=label_bg_color, textcolor=label_text_color, size=labelSize, textalign=text.align_left)

// Force color update on every recalculation
label.set_textcolor(ohl,  label_text_color)
label.set_textcolor(oll,  label_text_color)
label.set_textcolor(midl, label_text_color)
label.set_color(ohl,  label_bg_color)
label.set_color(oll,  label_bg_color)
label.set_color(midl, label_bg_color)

if not timeframe.isintraday
    label.delete(ohl)
    label.delete(oll)
    label.delete(midl)

// ═══════════════════════════════════════
// TABLE
// ═══════════════════════════════════════
if show_table and timeframe.isintraday
    table.cell(rda_analytics, 0, 0, "Today",     bgcolor=color.black, text_color=color.white)
    table.cell(rda_analytics, 1, 0, str.tostring(opening_high - opening_low, "#.##"), bgcolor=color.black, text_color=color.red)
    table.cell(rda_analytics, 0, 2, "W-Avg",     bgcolor=color.black, text_color=color.white)
    table.cell(rda_analytics, 1, 2, str.tostring(this_week_delta, "#.##"),             bgcolor=color.black, text_color=color.blue)
    table.cell(rda_analytics, 0, 3, "20D CA-OH", bgcolor=color.black, text_color=color.white)
    table.cell(rda_analytics, 1, 3, str.tostring(close_above_oh_20days),               bgcolor=color.black, text_color=color.red)
    table.cell(rda_analytics, 0, 4, "20D CB-OL", bgcolor=color.black, text_color=color.white)
    table.cell(rda_analytics, 1, 4, str.tostring(close_below_ol_20days),               bgcolor=color.black, text_color=color.blue)
    table.cell(rda_analytics, 0, 5, " ", bgcolor=chart.bg_color, text_color=color.white)
    table.cell(rda_analytics, 1, 5, " ", bgcolor=chart.bg_color, text_color=color.blue)
````
