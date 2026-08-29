<!-- tradingview-pine-id: PUB;48349c2f01fd4ba6b39a6289d881c1c8 -->
<!-- tradingviewscripts-format: 1 -->
# Horizontal Lines Grid (Claudia)

Source: https://www.tradingview.com/script/6rmUgCHS-Horizontal-Lines-Grid-Claudia/

## Description

A simple and clean overlay indicator designed specifically for futures traders (ES, NQ, YM, RTY, CL, GC, etc.).
It automatically plots green horizontal lines at every x-point interval around the current price. These round-number levels often act as psychological support and resistance zones and are widely watched by institutional and retail traders alike.

---

## Source Code

````pine
//@version=6
indicator('Horizontal Lines Grid (Claudia)', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ===== Settings =====
step          = input.float(25.0, 'Line Spacing (points)', minval = 0.1, step = 0.1)
linesAbove    = input.int(20, 'Lines Above', minval = 1, maxval = 50)
linesBelow    = input.int(20, 'Lines Below', minval = 1, maxval = 50)
lineColor     = input.color(color.green, 'Line Color')
lineWidth     = input.int(1, 'Line Width', minval = 1, maxval = 4)
lineStyle     = input.string('Solid', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'])
showLabels    = input.bool(true, 'Show Price Labels')

// Mid-lines
showMidLines  = input.bool(false, 'Show Mid-Lines', group = 'Mid-Lines')
midLineColor  = input.color(color.gray, 'Mid-Line Color', group = 'Mid-Lines')
midLineWidth  = input.int(1, 'Mid-Line Width', minval = 1, maxval = 4, group = 'Mid-Lines')
midLineStyle  = input.string('Dashed', 'Mid-Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Mid-Lines')

// Convert styles
style    = lineStyle == 'Dashed' ? line.style_dashed : lineStyle == 'Dotted' ? line.style_dotted : line.style_solid
midStyle = midLineStyle == 'Dashed' ? line.style_dashed : midLineStyle == 'Dotted' ? line.style_dotted : line.style_solid

// Calculate nearest lower level
base = math.floor(close / step) * step

// Delete old lines every bar
var array<line> lines = array.new_line()
if barstate.islast
    for l in lines
        line.delete(l)
    array.clear(lines)

    // Draw main lines
    for i = -linesBelow to linesAbove by 1
        level = base + i * step
        if level > 0
            ln = line.new(x1 = bar_index - 1, y1 = level, x2 = bar_index, y2 = level, 
                          xloc = xloc.bar_index, extend = extend.both, 
                          color = lineColor, width = lineWidth, style = style)
            array.push(lines, ln)

            if showLabels
                label.new(x = bar_index, y = level, text = str.tostring(level, '#.##'), 
                          style = label.style_label_left, color = color.new(lineColor, 80), 
                          textcolor = lineColor, size = size.small)

    // Draw mid-lines (halfway between each main level)
    if showMidLines
        for i = -linesBelow to linesAbove - 1 by 1
            midLevel = base + i * step + step / 2
            if midLevel > 0
                ln = line.new(x1 = bar_index - 1, y1 = midLevel, x2 = bar_index, y2 = midLevel, 
                              xloc = xloc.bar_index, extend = extend.both, 
                              color = midLineColor, width = midLineWidth, style = midStyle)
                array.push(lines, ln)
````
