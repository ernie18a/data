# 8AM & 12PM London

- url: https://www.tradingview.com/script/x0Qzk2oA-8AM-12PM-London/
- type: indicator
- pine_id: PUB;96cab51f052e427eafc5e6168bf5666d
- version: 1.0

## Description

8am and 12pm for Supply and Demand, Basically London Session. This is where I start and end trading

## Source Code

````pine
//@version=5
indicator("8AM & 12PM Vertical Lines (All Days)", overlay=true, max_lines_count=500)

// === SETTINGS ===
show8am  = input.bool(true, "Show 8AM Line")
show12pm = input.bool(true, "Show 12PM Line")

color8am  = input.color(color.white, "8AM Color")
color12pm = input.color(color.white, "12PM Color")

tz = input.string("Europe/London", "Timezone")

// === TIME COMPONENTS ===
y = year(time, tz)
mo = month(time, tz)
d = dayofmonth(time, tz)

// === TARGET TIMES FOR EACH BAR'S DAY ===
t8  = timestamp(tz, y, mo, d, 8, 0)
t12 = timestamp(tz, y, mo, d, 12, 0)

// === DRAW ONCE PER BAR WHEN TIME MATCHES ===
is8am  = time == t8
is12pm = time == t12

if show8am and is8am
    line.new(
         x1=t8, x2=t8,
         y1=low, y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=color8am,
         width=1,
         style=line.style_solid)

if show12pm and is12pm
    line.new(
         x1=t12, x2=t12,
         y1=low, y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=color12pm,
         width=1,
         style=line.style_solid)
````
