# 90-Min Vertical Lines (24h, Anchor 7:00 NY)

- url: https://www.tradingview.com/script/n2I7xEvY-90-Min-Vertical-Lines-24h-Anchor-7-00-NY/
- type: indicator
- pine_id: PUB;83c764c66fa04d0cb1efdccd7a91a243
- version: 1.0

## Description

for fren backtesting

tradingview wants me to add more

reeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

## Source Code

````pine
//@version=6
indicator("90-Min Vertical Lines (24h, Anchor 7:00 NY)", overlay=true, max_lines_count=500)

// === Inputs ===
startHour   = input.int(7,  "Anchor Hour (NY time)", minval=0, maxval=23)
startMinute = input.int(0,  "Anchor Minute",        minval=0, maxval=59)
stepMinutes = input.int(90, "Step (minutes)",       minval=1)

lineColor   = input.color(color.red, "Line Color")
lineWidth   = input.int(1, "Line Width", minval=1, maxval=4)
lineStyleIn = input.string("Solid", "Line Style", options=["Solid","Dotted","Dashed"])

// Map style input -> line.style_*
ls = lineStyleIn == "Dotted" ? line.style_dotted :
     lineStyleIn == "Dashed" ? line.style_dashed :
                               line.style_solid

// === Time handling ===
// New York time (handles EST/EDT automatically)
tz = "America/New_York"

// Bar's calendar date in NY
y = year(time, tz)
m = month(time, tz)
d = dayofmonth(time, tz)

// Today's 7:00 AM NY timestamp
todayAnchor = timestamp(tz, y, m, d, startHour, startMinute)

// If current bar is before today's 7:00 AM, use yesterday's 7:00 AM as anchor
anchor = time >= todayAnchor ? todayAnchor : (todayAnchor - 24 * 60 * 60 * 1000)

// Minutes since anchor (now always >= 0, covering midnight -> 6:59 AM too)
minsSinceAnchor = (time - anchor) / 60000.0

// Bucket increments every stepMinutes; draw when bucket changes
bucketNow  = math.floor(minsSinceAnchor / stepMinutes)
bucketPrev = math.floor(minsSinceAnchor[1] / stepMinutes)

isNewStep = bucketNow != bucketPrev

// === Draw vertical line ===
if isNewStep
    line.new(
        x1=bar_index, y1=low,
        x2=bar_index, y2=high,
        xloc=xloc.bar_index,
        extend=extend.both,
        color=lineColor,
        width=lineWidth,
        style=ls
    )
````
