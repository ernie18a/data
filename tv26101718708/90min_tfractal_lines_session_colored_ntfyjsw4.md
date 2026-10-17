# 90-Min T-Fractal Lines (Session Colored)

- url: https://www.tradingview.com/script/NTFYjSW4-90-Min-T-Fractal-Lines-Session-Colored/
- type: indicator
- pine_id: PUB;10b58ee83fd749538218d06d9e849b6c
- version: 1.0

## Description

Simple 90 min time fractals indicator to use as a confluence.

Yellow - Overlapping New York and London session
Orange - London Session
Green - New York Session
Blue - Asia Session

## Source Code

````pine
//@version=6
indicator("90-Min Vertical Lines (Session Colored)", overlay=true, max_lines_count=500)

string tz = "America/New_York"
int stepMs = 90 * 60 * 1000
int dayMs = 24 * 60 * 60 * 1000

// Anchor = 9:30 AM NY
int anchorToday = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 9, 30)
int baseAnchor = time >= anchorToday ? anchorToday : anchorToday - dayMs

// Store lines
var array<line> lines = array.new_line()

f_getSessionColor(int ts) =>
    int h = hour(ts, tz)
    int m = minute(ts, tz)
    int total = h * 60 + m

    // Sessions (NY time)
    bool inAsia = total >= 19 * 60 or total < 3 * 60
    bool inLondon = total >= 3 * 60 and total < 12 * 60
    bool inNY = total >= (9 * 60 + 30) and total < 16 * 60

    bool overlap = inLondon and inNY

    overlap ? color.yellow :
     inNY ? color.green :
     inLondon ? color.orange :
     inAsia ? color.blue :
     color.white

if barstate.islast
    // Only clear if lines exist (prevents runtime error)
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)

    // Draw lines
    for i = -12 to 20
        int t = baseAnchor + i * stepMs
        color c = f_getSessionColor(t)

        line ln = line.new(
            x1 = t,
            y1 = low - 1000000,
            x2 = t,
            y2 = high + 1000000,
            xloc = xloc.bar_time,
            extend = extend.both,
            color = c,
            width = 1
        )

        array.push(lines, ln)
````
