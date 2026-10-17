# Fibonacci Pinball (Interactive)

- url: https://www.tradingview.com/script/mlEmsUEk-Fibonacci-Pinball-Interactive/
- type: indicator
- pine_id: PUB;923250062e8c4ab3879959e25c8c067e
- version: 1.0

## Description

Fibonacci Pinball Interactive is a visual trading tool that transforms traditional Fibonacci levels into a dynamic experience, showing how price moves and reacts like a bouncing ball between key zones. Instead of static lines, it helps you see momentum, support, and resistance in a more intuitive way, making it easier to understand market structure and anticipate potential reactions as price flows through these levels.

## Source Code

````pine
//@version=5
indicator("Fibonacci Pinball (Interactive)", overlay=true, max_lines_count=500)

// Create inputs for the points so you can move them by clicking/dragging
p1 = input.time(0, "Wave 1 Start (Click to Set)", confirm=true)
v1 = input.price(0, "Wave 1 Price", confirm=true)

p2 = input.time(0, "Wave 1 Peak (Click to Set)", confirm=true)
v2 = input.price(0, "Wave 1 Peak Price", confirm=true)

p3 = input.time(0, "Wave 2 Low (Click to Set)", confirm=true)
v3 = input.price(0, "Wave 2 Low Price", confirm=true)

// Math
w1_dist = v2 - v1

// Helper function for levels
get_lvl(r) => v3 + (w1_dist * r)

if barstate.islast
    // Levels from the Article
    float target_100  = get_lvl(1.000)
    float target_1236 = get_lvl(1.236)
    float support_618 = get_lvl(0.618)
    float support_764 = get_lvl(0.764)
    float major_iii   = get_lvl(1.618)
    float final_v     = get_lvl(2.000)

    // Drawing the Pinball Grid
    var line l100 = line.new(p3, target_100,  time + 86400000, target_100,  xloc=xloc.bar_time, color=color.orange, width=2)
    var line l123 = line.new(p3, target_1236, time + 86400000, target_1236, xloc=xloc.bar_time, color=color.orange, width=1)
    var line l618 = line.new(p3, support_618, time + 86400000, support_618, xloc=xloc.bar_time, color=color.blue,   width=2)
    var line l764 = line.new(p3, support_764, time + 86400000, support_764, xloc=xloc.bar_time, color=color.blue,   width=1)
    var line l161 = line.new(p3, major_iii,   time + 86400000, major_iii,   xloc=xloc.bar_time, color=color.green,  width=3)
    var line l200 = line.new(p3, final_v,     time + 86400000, final_v,     xloc=xloc.bar_time, color=color.red,    width=2)

    // Labels for the Rules
    label.new(time, target_1236, "Wave 3 of iii Target", xloc=xloc.bar_time, textcolor=color.orange, style=label.style_none)
    label.new(time, support_618, "CRITICAL SUPPORT (.618)", xloc=xloc.bar_time, textcolor=color.blue, style=label.style_none)
    label.new(time, major_iii,   "Wave iii Target (TP/Move Stop)", xloc=xloc.bar_time, textcolor=color.green, style=label.style_none)
    label.new(time, final_v,     "Wave v Final Target", xloc=xloc.bar_time, textcolor=color.red, style=label.style_none)
````
