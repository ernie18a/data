# Cost Basis Levels

- url: https://www.tradingview.com/script/HQIqEcby-Cost-Basis-Levels/
- type: indicator
- pine_id: PUB;da05348a951a443d956a9147eabf4f4d
- version: 1.0

## Description

This is a free chart tool. It is not financial advice. It does not tell you when to buy or sell, and it does not predict where price will go.

You type your own cost basis prices into the settings. The script reads those prices and draws two things:

The range from the lowest cost basis you entered to the highest.
Extra levels set 2 times, 4 times, and 8 times that range’s width away from the range, above it and below it.
The width is the distance between your highest and lowest entered cost basis. If that distance is 10, the 2× levels sit 20 away from the range, the 4× levels sit 40 away, and the 8× levels sit 80 away. The lines update when you change the prices in the settings.

How to use it: add the indicator to the chart, open its settings, and enter each cost basis as a price on that symbol. Use the same units as the chart. Leave unused fields empty. Enter at least two prices so a range and a width exist. Check that each price matches your own records before you rely on the drawing.

These levels are a picture of the prices you typed. They are not a forecast, a target, or a signal. A wider or narrower set of cost basis prices produces a different width, and the 2×, 4×, and 8× levels move with that width. The script does not pull fills from a broker, and it does not compute a cost basis from candles or from orders on the chart.

This script is free. Its purpose is to keep a manual cost basis range, and the 2×, 4×, and 8× widths of that range, on the chart while you study price.

## Source Code

````pine
//@version=6
indicator("Cost Basis Levels!)", overlay=true, max_lines_count=500)

// === Inputs ===
groupBase = "Base Channel Settings"
base_high = input.price(title="Base Channel High", defval=0.026, group=groupBase)
base_low  = input.price(title="Base Channel Low",  defval=0.020, group=groupBase)

// === Colors ===
groupColors = "Colors"
color_base = input.color(title="Base Channel Color", defval=color.rgb(1, 67, 250), group=groupColors)
color_2x   = input.color(title="2x Channel Color",  defval=color.green,   group=groupColors)
color_4x   = input.color(title="4x Channel Color",  defval=color.orange,  group=groupColors)
color_8x   = input.color(title="8x Channel Color",  defval=color.red,     group=groupColors)

// === Derived Levels (auto-update on input change) ===
base_width     = base_high - base_low
level_2x_above = base_high + 2.0 * base_width
level_2x_below = base_low  - 2.0 * base_width
level_4x_above = level_2x_above + 4.0 * base_width
level_4x_below = level_2x_below - 4.0 * base_width
level_8x_above = level_4x_above + 8.0 * base_width
level_8x_below = level_4x_below - 8.0 * base_width

// === Invisible plots for region fills (need plot handles for fill()) ===
p_base_high = plot(base_high, title="Base High (for fill)",  display=display.none)
p_base_low  = plot(base_low,  title="Base Low (for fill)",   display=display.none)
p_2x_high   = plot(level_2x_above, title="2x Above (for fill)", display=display.none)
p_2x_low    = plot(level_2x_below, title="2x Below (for fill)", display=display.none)
p_4x_high   = plot(level_4x_above, title="4x Above (for fill)", display=display.none)
p_4x_low    = plot(level_4x_below, title="4x Below (for fill)", display=display.none)
p_8x_high   = plot(level_8x_above, title="8x Above (for fill)", display=display.none)
p_8x_low    = plot(level_8x_below, title="8x Below (for fill)", display=display.none)

// === Fills ===
fill(p_base_high, p_base_low, color=color.new(color_base, 90))
fill(p_2x_high, p_base_high,  color=color.new(color_2x, 95))
fill(p_base_low, p_2x_low,    color=color.new(color_2x, 95))
fill(p_4x_high, p_2x_high,    color=color.new(color_4x, 95))
fill(p_2x_low,  p_4x_low,     color=color.new(color_4x, 95))
fill(p_8x_high, p_4x_high,    color=color.new(color_8x, 95))
fill(p_4x_low,  p_8x_low,     color=color.new(color_8x, 95))

// === Price-scale labels only (no lines drawn) ===
plot(base_high,      title="Base High Label", color=color_base, linewidth=1, display=display.price_scale)
plot(base_low,       title="Base Low Label",  color=color_base, linewidth=1, display=display.price_scale)
plot(level_2x_above, title="2x High Label",   color=color_2x, linewidth=1, display=display.price_scale)
plot(level_2x_below, title="2x Low Label",    color=color_2x, linewidth=1, display=display.price_scale)
plot(level_4x_above, title="4x High Label",   color=color_4x, linewidth=1, display=display.price_scale)
plot(level_4x_below, title="4x Low Label",    color=color_4x, linewidth=1, display=display.price_scale)
plot(level_8x_above, title="8x High Label",   color=color_8x, linewidth=1, display=display.price_scale)
plot(level_8x_below, title="8x Low Label",    color=color_8x, linewidth=1, display=display.price_scale)


// =======================================
// === 1× Step Lines as DRAWING OBJECTS ===
// =======================================
groupSteps  = "1× Step Lines"
show_steps  = input.bool(true,  "Show 1× Steps", group=groupSteps)
steps_color = input.color(color.gray, "1× Step Color", group=groupSteps)
steps_width = input.int(1, "1× Step Width", minval=1, maxval=5, group=groupSteps)
max_steps   = input.int(13, "Max 1× Steps per side", minval=1, maxval=50, group=groupSteps)

// Persistent arrays to hold line objects
var line[] stepAbove = array.new_line()
var line[] stepBelow = array.new_line()

// Create lines once (extend both directions so they span the whole chart)
if barstate.isfirst
    for k = 1 to max_steps
        // Above: base_high + k*base_width
        lA = line.new(x1=bar_index-1, y1=base_high + base_width * k,
                      x2=bar_index,   y2=base_high + base_width * k,
                      xloc=xloc.bar_index, extend=extend.both, color=steps_color, width=steps_width)
        array.push(stepAbove, lA)
        // Below: base_low - k*base_width
        lB = line.new(x1=bar_index-1, y1=base_low - base_width * k,
                      x2=bar_index,   y2=base_low - base_width * k,
                      xloc=xloc.bar_index, extend=extend.both, color=steps_color, width=steps_width)
        array.push(stepBelow, lB)

// Update positions + style every bar so they follow input changes
f_update_lines(linesArr, baseY, dir) =>
    // dir = 1 for above (use base_high), -1 for below (use base_low)
    for i = 0 to array.size(linesArr) - 1
        k  = i + 1
        bw = base_width * k * dir
        y  = baseY + bw
        ln = array.get(linesArr, i)
        // Move line to the new Y level
        line.set_xy1(ln, bar_index-1, y)
        line.set_xy2(ln, bar_index,   y)
        // Show/hide by transparency (visible property is not exposed for lines)
        line.set_color(ln, show_steps ? steps_color : color.new(steps_color, 100))
        line.set_width(ln, steps_width)
        line.set_extend(ln, extend.both)

f_update_lines(stepAbove, base_high,  1)
f_update_lines(stepBelow, base_low,  -1)
````
