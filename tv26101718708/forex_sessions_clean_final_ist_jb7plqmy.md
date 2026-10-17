# Forex Sessions Clean Final (IST)

- url: https://www.tradingview.com/script/JB7PLqmY-Forex-Sessions-Clean-Final-IST/
- type: indicator
- pine_id: PUB;9a86c063a3af4223bb482ae814b63a7e
- version: 1.0

## Description

clean ist sessions timings as per indian time use it and tell me

## Source Code

````pine
//@version=5
indicator("Forex Sessions Clean Final (IST)", overlay=true)

// IST timezone
tz = "Asia/Kolkata"

// Time
h = hour(time, tz)
m = minute(time, tz)
t = h * 60 + m

// Session times (SUMMER)
tokyo_start  = 5 * 60 + 30
tokyo_end    = 14 * 60 + 30

london_start = 12 * 60 + 30
london_end   = 21 * 60 + 30

ny_start     = 17 * 60 + 30
ny_end       = 2 * 60 + 30

// Conditions
inTokyo  = (t >= tokyo_start and t <= tokyo_end)
inLondon = (t >= london_start and t <= london_end)
inNY     = (t >= ny_start or t <= ny_end)

// Variables
var box tokyoBox  = na
var box londonBox = na
var box nyBox     = na

// TOKYO (RED dotted)
if (inTokyo and not inTokyo[1])
    tokyoBox := box.new(bar_index, high, bar_index, low,
         border_color=color.new(color.red, 40),
         border_style=line.style_dotted,
         bgcolor=na)
    label.new(bar_index, high, "TOKYO",
         textcolor=color.black,
         color=color.white,
         style=label.style_label_down,
         size=size.small)

if (inTokyo)
    box.set_right(tokyoBox, bar_index)
    box.set_top(tokyoBox, math.max(box.get_top(tokyoBox), high))
    box.set_bottom(tokyoBox, math.min(box.get_bottom(tokyoBox), low))

// LONDON (Purple)
if (inLondon and not inLondon[1])
    londonBox := box.new(bar_index, high, bar_index, low,
         border_color=color.new(color.purple, 40),
         bgcolor=na)
    label.new(bar_index, high, "LONDON",
         textcolor=color.black,
         color=color.white,
         style=label.style_label_down,
         size=size.small)

if (inLondon)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, math.max(box.get_top(londonBox), high))
    box.set_bottom(londonBox, math.min(box.get_bottom(londonBox), low))

// NEW YORK (Green)
if (inNY and not inNY[1])
    nyBox := box.new(bar_index, high, bar_index, low,
         border_color=color.new(color.green, 40),
         bgcolor=na)
    label.new(bar_index, high, "NEW YORK",
         textcolor=color.black,
         color=color.white,
         style=label.style_label_down,
         size=size.small)

if (inNY)
    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, math.max(box.get_top(nyBox), high))
    box.set_bottom(nyBox, math.min(box.get_bottom(nyBox), low))
````
