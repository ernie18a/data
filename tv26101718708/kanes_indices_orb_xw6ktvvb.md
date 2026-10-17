# Kane's Indices ORB

- url: https://www.tradingview.com/script/xW6KtVVb-Kane-s-Indices-ORB/
- type: indicator
- pine_id: PUB;bb1d4947ea774d48972a234267374d2a
- version: 1.0

## Description

Kane’s Indices ORB plots key intraday opening range levels for index futures using clean session boxes and midpoint structure.

Includes:

8:00 AM EST Premarket ORB (15m)
9:30 AM EST Opening ORB (30m)
9:30 AM EST 15-Minute ORB Level
Midpoint lines
Session box extensions
Custom colors & visibility toggles
Ultra-light default ORB opacity (3%) for reduced chart clutter

Designed for:

ES / MES
NQ / MNQ
YM / MYM
RTY / M2K

Best used on intraday timeframes for:

Opening range breakouts
Liquidity sweeps
Trend continuation entries
Reversal reactions around key session ranges

Built with a clean institutional-style layout focused on visibility without obstructing price action.

## Source Code

````pine
//@version=6
indicator("Kane's Indices ORB", overlay=true, max_boxes_count=50, max_lines_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

show8am      = input.bool(true,  "8:00am EST (15 min)")
show930_30   = input.bool(true,  "9:30am EST (30 min)")
show930_15   = input.bool(true,  "9:30am EST (15 min level)")

showBoxes     = input.bool(true, "Show ORB Session Boxes")
showMidpoints = input.bool(true, "Show ORB Midpoints")

fillOpacity  = input.int(3, "ORB Body Opacity %", minval=0, maxval=100)

color8am     = input.color(color.gray, "8:00am EST Color")
color930     = input.color(color.fuchsia, "9:30am EST Color")
color930_15  = input.color(color.purple, "9:30am EST 15min Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_inSession(_session) =>
    not na(time(timeframe.period, _session, tz))

f_newSession(_session) =>
    f_inSession(_session) and not f_inSession(_session)[1]

f_transp(_opacityPercent) =>
    100 - _opacityPercent

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Session Definitions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
session8am    = "0800-0815"
session930_15 = "0930-0945"
session930_30 = "0930-1000"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8:00am ORB
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float hi8 = na
var float lo8 = na
var box box8 = na
var line mid8 = na

if show8am

    if f_newSession(session8am)
        hi8 := high
        lo8 := low

        box8 := box.new(
             bar_index,
             hi8,
             bar_index,
             lo8,
             bgcolor = color.new(color8am, f_transp(fillOpacity)),
             border_color = color8am)

        mid8 := line.new(
             bar_index,
             (hi8 + lo8) / 2,
             bar_index,
             (hi8 + lo8) / 2,
             color = color8am,
             style = line.style_dashed)

    if f_inSession(session8am)

        hi8 := math.max(hi8, high)
        lo8 := math.min(lo8, low)

        if showBoxes and not na(box8)
            box.set_top(box8, hi8)
            box.set_bottom(box8, lo8)
            box.set_right(box8, bar_index)

        if showMidpoints and not na(mid8)
            line.set_y1(mid8, (hi8 + lo8) / 2)
            line.set_y2(mid8, (hi8 + lo8) / 2)
            line.set_x2(mid8, bar_index)

    if not f_inSession(session8am) and not na(box8)
        box.set_right(box8, bar_index)

        if not na(mid8)
            line.set_x2(mid8, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9:30am 30 Minute ORB
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float hi930 = na
var float lo930 = na
var box box930 = na
var line mid930 = na

if show930_30

    if f_newSession(session930_30)

        hi930 := high
        lo930 := low

        box930 := box.new(
             bar_index,
             hi930,
             bar_index,
             lo930,
             bgcolor = color.new(color930, f_transp(fillOpacity)),
             border_color = color930)

        mid930 := line.new(
             bar_index,
             (hi930 + lo930) / 2,
             bar_index,
             (hi930 + lo930) / 2,
             color = color930,
             style = line.style_dashed)

    if f_inSession(session930_30)

        hi930 := math.max(hi930, high)
        lo930 := math.min(lo930, low)

        if showBoxes and not na(box930)
            box.set_top(box930, hi930)
            box.set_bottom(box930, lo930)
            box.set_right(box930, bar_index)

        if showMidpoints and not na(mid930)
            line.set_y1(mid930, (hi930 + lo930) / 2)
            line.set_y2(mid930, (hi930 + lo930) / 2)
            line.set_x2(mid930, bar_index)

    if not f_inSession(session930_30) and not na(box930)

        box.set_right(box930, bar_index)

        if not na(mid930)
            line.set_x2(mid930, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9:30am 15 Minute Level
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float hi15 = na
var float lo15 = na
var box box15 = na
var line mid15 = na

if show930_15

    if f_newSession(session930_15)

        hi15 := high
        lo15 := low

        box15 := box.new(
             bar_index,
             hi15,
             bar_index,
             lo15,
             bgcolor = color.new(color930_15, f_transp(fillOpacity)),
             border_color = color930_15)

        mid15 := line.new(
             bar_index,
             (hi15 + lo15) / 2,
             bar_index,
             (hi15 + lo15) / 2,
             color = color930_15,
             style = line.style_dashed)

    if f_inSession(session930_15)

        hi15 := math.max(hi15, high)
        lo15 := math.min(lo15, low)

        if showBoxes and not na(box15)
            box.set_top(box15, hi15)
            box.set_bottom(box15, lo15)
            box.set_right(box15, bar_index)

        if showMidpoints and not na(mid15)
            line.set_y1(mid15, (hi15 + lo15) / 2)
            line.set_y2(mid15, (hi15 + lo15) / 2)
            line.set_x2(mid15, bar_index)

    if not f_inSession(session930_15) and not na(box15)

        box.set_right(box15, bar_index)

        if not na(mid15)
            line.set_x2(mid15, bar_index)
````
