# Time Cycle Model 2.0

- url: https://www.tradingview.com/script/I0XfUetV-Time-Cycle-Model-2-0/
- type: indicator
- pine_id: PUB;0dc62a66467e45f4931ea11f7a314211
- version: 1.0

## Description

Time Cycle Model 2.0 highlights key intraday market time windows and upcoming events directly on your chart.

[list]
[*]Background shading marks important periods like lunch hours and bond settlement.
[*]Colored highlights identify key moments such as market open, news times, euro close, oil close, and more.
[*]Forward-looking dashed lines project upcoming events (up to 60 minutes ahead by default), so you can anticipate important times before price reaches them.
[*]Labels clearly show what each upcoming event is, keeping everything easy to read at a glance.
[/list]

This script is designed to help traders stay aware of time-based market behavior and prepare for potential volatility or shifts before they happen.

## Source Code

````pine
//@version=6
indicator("Time Cycle Model 2.0", overlay=true, max_lines_count=50, max_labels_count=50)

// --- COLORS ---
colorMarker = input.color(color.new(color.blue, 80), "Instant Events (Open/News/Close)")
colorLunch  = input.color(color.new(color.gray, 92), "Lunch Block (12:00-13:30)")
colorBond   = input.color(color.new(color.purple, 85), "Bond Settlement (15:00-15:15)")
colorEuro   = input.color(color.new(color.orange, 85), "Euro Close (11:30)")

futureLineColor = input.color(color.new(color.yellow, 0), "Future Event Lines")
futureLabelColor = input.color(color.new(color.black, 0), "Future Label Text")
lookaheadMinutes = input.int(60, "Future lookahead minutes", minval=1, maxval=240)

// --- TIME LOGIC (Exchange Time / ET) ---
is_open   = not na(time(timeframe.period, "0930-0931", syminfo.timezone))
is_news   = not na(time(timeframe.period, "1000-1001", syminfo.timezone))
is_euro   = not na(time(timeframe.period, "1130-1131", syminfo.timezone))
is_lunch  = not na(time(timeframe.period, "1200-1330", syminfo.timezone))
is_oil    = not na(time(timeframe.period, "1400-1401", syminfo.timezone))
is_bond   = not na(time(timeframe.period, "1500-1515", syminfo.timezone))

// --- RENDER EXISTING / CURRENT BACKGROUNDS ---
bgcolor(is_lunch ? colorLunch : na)
bgcolor(is_bond  ? colorBond  : na)

bgcolor(is_open or is_news ? colorMarker : na)
bgcolor(is_euro ? colorEuro : na)
bgcolor(is_oil  ? colorMarker : na)

// =====================================================
// FUTURE EVENT LINES
// =====================================================

// Store lines/labels so we can delete and redraw them cleanly
var line[] futureLines = array.new_line()
var label[] futureLabels = array.new_label()

// Helper: delete old projected lines/labels
f_clearFutureObjects() =>
    while array.size(futureLines) > 0
        line.delete(array.pop(futureLines))
    while array.size(futureLabels) > 0
        label.delete(array.pop(futureLabels))

// Helper: timestamp for today's event in exchange timezone
f_eventTime(_hour, _minute) =>
    timestamp(syminfo.timezone, year, month, dayofmonth, _hour, _minute)

// Helper: draw vertical future line if inside lookahead window
f_drawFutureEvent(_eventTime, _name, _color) =>
    int lookaheadMs = lookaheadMinutes * 60 * 1000

    // Use the current bar's opening time as the reference.
    // On live charts, this updates as new bars form.
    bool isUpcoming = _eventTime > time and _eventTime <= time + lookaheadMs

    if isUpcoming
        line ln = line.new(
             x1 = _eventTime,
             y1 = low,
             x2 = _eventTime,
             y2 = high,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = _color,
             style = line.style_dashed,
             width = 1
        )

        label lb = label.new(
             x = _eventTime,
             y = high,
             text = _name,
             xloc = xloc.bar_time,
             style = label.style_label_down,
             textcolor = futureLabelColor,
             color = color.new(_color, 80),
             size = size.small
        )

        array.push(futureLines, ln)
        array.push(futureLabels, lb)

// Only redraw projections on the latest bar, so we don't spam lines historically
if barstate.islast
    f_clearFutureObjects()

    // Today's scheduled moments
    int tOpen  = f_eventTime(9, 30)
    int tNews  = f_eventTime(10, 0)
    int tEuro  = f_eventTime(11, 30)
    int tLunch = f_eventTime(12, 0)
    int tLunchend = f_eventTime(13, 30)
    int tOil   = f_eventTime(14, 0)
    int tBond  = f_eventTime(15, 0)
    int tClose = f_eventTime(16, 0)

    f_drawFutureEvent(tOpen,  "Open 09:30", futureLineColor)
    f_drawFutureEvent(tNews,  "News 10:00", futureLineColor)
    f_drawFutureEvent(tEuro,  "Euro Close 11:30", color.orange)
    f_drawFutureEvent(tLunch, "Lunch Start 12:00", color.gray)
    f_drawFutureEvent(tLunchend, "Lunch Ends 13:30", futureLineColor)
    f_drawFutureEvent(tOil,   "Oil Pits Close 14:00", futureLineColor)
    f_drawFutureEvent(tBond,  "Bonds Close 15:00", color.purple)
    f_drawFutureEvent(tClose, "Close 16:00", futureLineColor)
````
