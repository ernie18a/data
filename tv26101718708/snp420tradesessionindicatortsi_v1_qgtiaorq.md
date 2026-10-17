# SNP420:Trade_Session_Indicator(TSI) v1

- url: https://www.tradingview.com/script/QGtIaORq-SNP420-Trade-Session-Indicator-TSI-v1/
- type: indicator
- pine_id: PUB;f22d172dc155442c83dae0e314c217ef
- version: 2.0

## Description

ENG
Trade only when it makes sense.

This indicator highlights your trading window right on the chart. At a glance you know when you're "on the clock" and when to keep your hands off the button.

Why use it:
- The simplest way to avoid mistimed entries.
- No more entries outside the session, in a dead market, or out of boredom.
- Default setting: 08:00-16:00 Prague time, Mon-Fri. Daylight saving time switches automatically.
- Works on all intraday timeframes.

Make it fit your strategy:
Change the trading hours and color with one click in the indicator settings. Trading London, New York, or just the first two hours? Just set your time and the indicator keeps you disciplined.

Simple. Clean. Discipline at a glance.

Author: SNP420 | Finexus s.r.o.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) SNP420
// Author: SNP420
// Company: Finexus s.r.o.

//@version=6
indicator("SNP420:Trade_session_indicator", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

sess    = input.session("0800-1600:23456", "Session (Prague time, Mon-Fri)")
col     = input.color(color.rgb(136, 255, 0), "Color")
txt     = input.string("Trade_Session", "Label")
history = input.int(10, "History", minval = 1)

TZ   = "Europe/Prague"
NONE = color.new(color.black, 100)

// Session end time (handles sessions crossing midnight)
f_end_time() =>
    eH = int(str.tonumber(str.substring(sess, 5, 7)))
    eM = int(str.tonumber(str.substring(sess, 7, 9)))
    t  = timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), eH, eM)
    t <= time ? t + 86400000 : t

var box   sBox   = na
var line  lOpen  = na
var line  lClose = na
var label lName  = na
var float top    = na
var float bot    = na
var float sOpen  = na
var int   x1     = na
var int   x2     = na

var boxes  = array.new<box>()
var lines  = array.new<line>()
var labels = array.new<label>()

inSess  = timeframe.isintraday and not na(time(timeframe.period, sess, TZ))
newSess = inSess and (not inSess[1] or time >= x2)
endSess = inSess[1] and (not inSess or time >= x2)

// Session end: open/close dots
if endSess
    labels.push(label.new(x1, sOpen,    "●", xloc = xloc.bar_time, color = NONE, textcolor = col, style = label.style_label_center, size = size.small))
    labels.push(label.new(x2, close[1], "◉", xloc = xloc.bar_time, color = NONE, textcolor = col, style = label.style_label_center, size = size.small))

// Session start: box, open/close band, name
if newSess
    x1    := time
    x2    := f_end_time()
    top   := high
    bot   := low
    sOpen := open

    sBox   := box.new(x1, top, x2, bot, border_color = col, border_width = 1, border_style = line.style_dashed, xloc = xloc.bar_time, bgcolor = color.new(col, 94))
    lOpen  := line.new(x1, open,  x2, open,  xloc = xloc.bar_time, color = color.new(col, 70), style = line.style_dotted)
    lClose := line.new(x1, close, x2, close, xloc = xloc.bar_time, color = color.new(col, 70), style = line.style_dotted)
    linefill.new(lOpen, lClose, color.new(col, 90))
    lName  := label.new(x1, top, txt, xloc = xloc.bar_time, color = NONE, textcolor = col, style = label.style_label_lower_left, size = size.small)

    boxes.push(sBox)
    lines.push(lOpen)
    lines.push(lClose)
    labels.push(lName)

    while boxes.size() > history
        boxes.shift().delete()
    while lines.size() > history * 2
        lines.shift().delete()
    while labels.size() > (history - 1) * 3 + 1
        labels.shift().delete()

// Inside session: grow box with high/low, track close
else if inSess
    top := math.max(top, high)
    bot := math.min(bot, low)
    sBox.set_top(top)
    sBox.set_bottom(bot)
    lClose.set_y1(close)
    lClose.set_y2(close)
    lName.set_y(top)
````
