# SEITEN - Starfield [Tankyu]

- url: https://www.tradingview.com/script/kSBO2FoA/
- type: indicator
- pine_id: PUB;8e5409dbc13c45a29b1588b6c070d999
- version: 1.0

## Description

A decorative overlay that generates a dynamic starfield across your chart background.

Features:
• Adjustable number of stars
• Configurable refresh interval
• Multiple star sizes and symbols
• Fully customizable star colors
• Procedurally regenerated star patterns

Designed for traders who enjoy a calmer, more atmospheric charting experience.

SEITEN means "Star-lit Heavens" in Japanese.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FX_tankyu

//@version=6
indicator("SEITEN - Starfield [Tankyu]", shorttitle="Starfield", overlay=true, max_labels_count=500)

//====================
// Inputs
//====================
grp = "Starfield Settings"

starCount    = input.int(400, "Number of Stars", minval=10, maxval=450, group=grp, tooltip="min:10\nmax:450")
refreshBars  = input.int(50, "Refresh Interval (Bars)", minval=1, group=grp)
lookbackBars = input.int(2500, "Starfield Width (Bars)", minval=50, maxval=5000, group=grp, tooltip="min:50\nmax:5000")

starColor  = input.color(color.new(#eeeeee, 40), "Main Star Color", group=grp)
starColor2 = input.color(color.new(#fff59d, 55), "Soft Star Color", group=grp)
starColor3 = input.color(color.new(#fbc02d, 70), "Distant Star Color", group=grp)

useMixedColors = input.bool(true, "Use Mixed Star Colors", group=grp)
useEmoji       = input.bool(true, "Use Star Symbols", group=grp)

//====================
// Storage
//====================
var label[] stars = array.new_label()

//====================
// Pseudo Random
//====================
f_rand(seed) =>
    x = math.sin(seed * 12.9898 + 78.233) * 43758.5453
    x - math.floor(x)

f_starText(r, useEmoji) =>
    useEmoji ?
         r < 0.15 ? "✦" :
         r < 0.35 ? "✧" :
         r < 0.60 ? "•"  :
         r < 0.82 ? "∙"  :
         "★"
     :
         r < 0.20 ? "●" :
         r < 0.45 ? "•" :
         r < 0.75 ? "·" :
         "∙"

f_starSize(r) =>
    r < 0.15 ? size.normal :
     r < 0.45 ? size.small :
     size.tiny

f_starColor(r) =>
    useMixedColors ?
         r < 0.60 ? starColor :
         r < 0.82 ? starColor2 :
         starColor3
     : starColor

//====================
// Price Range
//====================
priceHigh = ta.highest(high, lookbackBars)
priceLow  = ta.lowest(low, lookbackBars)
priceSpan = priceHigh - priceLow

//====================
// Refresh Stars
//====================
shouldRefresh = barstate.islast and (bar_index % refreshBars == 0 or array.size(stars) == 0)

if shouldRefresh and priceSpan > 0
    if array.size(stars) > 0
        for i = 0 to array.size(stars) - 1
            label.delete(array.get(stars, i))

    array.clear(stars)

    baseSeed = math.floor(bar_index / refreshBars)

    for i = 0 to starCount - 1
        rx = f_rand(baseSeed * 1000 + i * 17)
        ry = f_rand(baseSeed * 2000 + i * 31)
        rs = f_rand(baseSeed * 3000 + i * 47)
        rc = f_rand(baseSeed * 4000 + i * 61)

        x = bar_index - int(rx * lookbackBars)
        y = priceLow + ry * priceSpan

        lb = label.new(
             x=x,
             y=y,
             text=f_starText(rs, useEmoji),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=f_starColor(rc),
             size=f_starSize(rs)
        )

        array.push(stars, lb)
````
