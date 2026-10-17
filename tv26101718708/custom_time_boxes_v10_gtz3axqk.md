# Custom Time Boxes v1.0

- url: https://www.tradingview.com/script/Gtz3AXQk/
- type: indicator
- pine_id: PUB;05edfdd5418b43a09df2e9175e99e6b3
- version: 1.0

## Description

Custom Time Boxes is a simple and flexible tool for highlighting custom time ranges directly on the chart.
Define up to four independent time boxes with your own start and end times, colors, and transparency. Each box automatically tracks the high and low reached during the selected period.
The indicator works on any instrument and can be used to visualize market sessions, opening ranges, overlaps, or any custom trading window you want to study.
Features:
- 4 independent customizable time boxes
- Custom start and end times
- Individual colors and transparency
- Selectable timezone
- Automatic High/Low range visualization
- Works on any instrument

Created by Mockmoon Lab

## Source Code

````pine
//@version=6
indicator("Custom Time Boxes v1.0", overlay=true, max_boxes_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS
// All times are interpreted in the selected timezone.
// Boxes use each day's high/low made inside the selected time window.
// ─────────────────────────────────────────────────────────────────────────────
string TZ = input.string("America/New_York", "Timezone", options=["America/New_York", "Europe/London", "Europe/Vienna", "Etc/UTC"], display=display.none)

// BOX 1
bool show1 = input.bool(true, "Show Box 1", group="BOX 1", display=display.none)
int h1s = input.int(8,  "Start hour",   minval=0, maxval=23, group="BOX 1", inline="s1", display=display.none)
int m1s = input.int(15, "Start minute", minval=0, maxval=59, group="BOX 1", inline="s1", display=display.none)
int h1e = input.int(9,  "End hour",     minval=0, maxval=23, group="BOX 1", inline="e1", display=display.none)
int m1e = input.int(45, "End minute",   minval=0, maxval=59, group="BOX 1", inline="e1", display=display.none)
color c1 = input.color(color.blue, "Color", group="BOX 1", display=display.none)
int tr1 = input.int(82, "Fill transparency", minval=0, maxval=100, group="BOX 1", display=display.none)

// BOX 2
bool show2 = input.bool(true, "Show Box 2", group="BOX 2", display=display.none)
int h2s = input.int(10, "Start hour",   minval=0, maxval=23, group="BOX 2", inline="s2", display=display.none)
int m2s = input.int(0,  "Start minute", minval=0, maxval=59, group="BOX 2", inline="s2", display=display.none)
int h2e = input.int(11, "End hour",     minval=0, maxval=23, group="BOX 2", inline="e2", display=display.none)
int m2e = input.int(0,  "End minute",   minval=0, maxval=59, group="BOX 2", inline="e2", display=display.none)
color c2 = input.color(color.orange, "Color", group="BOX 2", display=display.none)
int tr2 = input.int(82, "Fill transparency", minval=0, maxval=100, group="BOX 2", display=display.none)

// BOX 3
bool show3 = input.bool(false, "Show Box 3", group="BOX 3", display=display.none)
int h3s = input.int(12, "Start hour",   minval=0, maxval=23, group="BOX 3", inline="s3", display=display.none)
int m3s = input.int(0,  "Start minute", minval=0, maxval=59, group="BOX 3", inline="s3", display=display.none)
int h3e = input.int(13, "End hour",     minval=0, maxval=23, group="BOX 3", inline="e3", display=display.none)
int m3e = input.int(0,  "End minute",   minval=0, maxval=59, group="BOX 3", inline="e3", display=display.none)
color c3 = input.color(color.green, "Color", group="BOX 3", display=display.none)
int tr3 = input.int(82, "Fill transparency", minval=0, maxval=100, group="BOX 3", display=display.none)

// BOX 4
bool show4 = input.bool(false, "Show Box 4", group="BOX 4", display=display.none)
int h4s = input.int(14, "Start hour",   minval=0, maxval=23, group="BOX 4", inline="s4", display=display.none)
int m4s = input.int(0,  "Start minute", minval=0, maxval=59, group="BOX 4", inline="s4", display=display.none)
int h4e = input.int(15, "End hour",     minval=0, maxval=23, group="BOX 4", inline="e4", display=display.none)
int m4e = input.int(0,  "End minute",   minval=0, maxval=59, group="BOX 4", inline="e4", display=display.none)
color c4 = input.color(color.purple, "Color", group="BOX 4", display=display.none)
int tr4 = input.int(82, "Fill transparency", minval=0, maxval=100, group="BOX 4", display=display.none)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// Supports windows inside one day and windows crossing midnight.
// ─────────────────────────────────────────────────────────────────────────────
f_inWindow(int sh, int sm, int eh, int em) =>
    int nowMin = hour(time, TZ) * 60 + minute(time, TZ)
    int startMin = sh * 60 + sm
    int endMin = eh * 60 + em
    startMin < endMin ? (nowMin >= startMin and nowMin < endMin) :
     startMin > endMin ? (nowMin >= startMin or nowMin < endMin) :
     false

// ─────────────────────────────────────────────────────────────────────────────
// BOX 1
// ─────────────────────────────────────────────────────────────────────────────
bool in1 = show1 and f_inWindow(h1s, m1s, h1e, m1e)
bool start1 = in1 and not in1[1]
var box b1 = na
if start1
    b1 := box.new(left=bar_index, top=high, right=bar_index, bottom=low, xloc=xloc.bar_index, border_color=c1, border_width=1, bgcolor=color.new(c1, tr1))
else if in1 and not na(b1)
    box.set_right(b1, bar_index)
    box.set_top(b1, math.max(box.get_top(b1), high))
    box.set_bottom(b1, math.min(box.get_bottom(b1), low))

// ─────────────────────────────────────────────────────────────────────────────
// BOX 2
// ─────────────────────────────────────────────────────────────────────────────
bool in2 = show2 and f_inWindow(h2s, m2s, h2e, m2e)
bool start2 = in2 and not in2[1]
var box b2 = na
if start2
    b2 := box.new(left=bar_index, top=high, right=bar_index, bottom=low, xloc=xloc.bar_index, border_color=c2, border_width=1, bgcolor=color.new(c2, tr2))
else if in2 and not na(b2)
    box.set_right(b2, bar_index)
    box.set_top(b2, math.max(box.get_top(b2), high))
    box.set_bottom(b2, math.min(box.get_bottom(b2), low))

// ─────────────────────────────────────────────────────────────────────────────
// BOX 3
// ─────────────────────────────────────────────────────────────────────────────
bool in3 = show3 and f_inWindow(h3s, m3s, h3e, m3e)
bool start3 = in3 and not in3[1]
var box b3 = na
if start3
    b3 := box.new(left=bar_index, top=high, right=bar_index, bottom=low, xloc=xloc.bar_index, border_color=c3, border_width=1, bgcolor=color.new(c3, tr3))
else if in3 and not na(b3)
    box.set_right(b3, bar_index)
    box.set_top(b3, math.max(box.get_top(b3), high))
    box.set_bottom(b3, math.min(box.get_bottom(b3), low))

// ─────────────────────────────────────────────────────────────────────────────
// BOX 4
// ─────────────────────────────────────────────────────────────────────────────
bool in4 = show4 and f_inWindow(h4s, m4s, h4e, m4e)
bool start4 = in4 and not in4[1]
var box b4 = na
if start4
    b4 := box.new(left=bar_index, top=high, right=bar_index, bottom=low, xloc=xloc.bar_index, border_color=c4, border_width=1, bgcolor=color.new(c4, tr4))
else if in4 and not na(b4)
    box.set_right(b4, bar_index)
    box.set_top(b4, math.max(box.get_top(b4), high))
    box.set_bottom(b4, math.min(box.get_bottom(b4), low))
````
