# Digital Root Grid Levels [Sam]

- url: https://www.tradingview.com/script/KLmaH44N-Digital-Root-Grid-Levels-Sam/
- type: indicator
- pine_id: PUB;df5a3c8f53554f5ca8922386035ce7a0
- version: 2.0

## Description

Grid levels of numbers .

So input Lower Low number + Higher High and the script will update levels according to mathematical solution

## Source Code

````pine
//@version=5
indicator("Grid Levels [Sam]", overlay=true, max_lines_count=500, max_labels_count=500)

grp1 = "📐 Price Settings"
i_basePrice = input.float(4502.0, "Floor Price",   group=grp1)
i_topPrice  = input.float(4800.0, "Ceiling Price", group=grp1)
i_step      = input.float(10.0,   "Step ($ between levels)", group=grp1, minval=0.1, step=0.5)

grp2 = "🎨 Style"
i_lineColor  = input.color(color.new(#FF8C00, 0), "Line Color",                 group=grp2)
i_labelColor = input.color(color.new(#FFD700, 0), "Label Color",                group=grp2)
i_lineWidth  = input.int(1,  "Line Width",  minval=1, maxval=4,                 group=grp2)
i_lineStyle  = input.string("Dashed", "Line Style",                             group=grp2, options=["Solid","Dashed","Dotted"])
i_lblOffset  = input.int(10, "Label Offset (bars right)", minval=0, maxval=200, group=grp2)
i_showInfo   = input.bool(true, "Show Info Panel",                              group=grp2)

lStyle = i_lineStyle == "Solid" ? line.style_solid : i_lineStyle == "Dotted" ? line.style_dotted : line.style_dashed

var line[]  _lines  = array.new_line()
var label[] _labels = array.new_label()
var label   _info   = na

if barstate.islast
    if array.size(_lines) > 0
        for i = 0 to array.size(_lines) - 1
            line.delete(array.get(_lines, i))
    array.clear(_lines)
    if array.size(_labels) > 0
        for i = 0 to array.size(_labels) - 1
            label.delete(array.get(_labels, i))
    array.clear(_labels)
    if not na(_info)
        label.delete(_info)

    float lvl = i_basePrice
    int   count = 0
    while lvl <= i_topPrice + i_step * 0.01 and count < 500
        l = line.new(x1=bar_index, y1=lvl, x2=bar_index+1, y2=lvl, color=i_lineColor, width=i_lineWidth, style=lStyle, extend=extend.both)
        array.push(_lines, l)
        lb = label.new(x=bar_index+i_lblOffset, y=lvl, text=str.tostring(lvl, "#.##"), color=color.new(color.black, 100), textcolor=i_labelColor, style=label.style_label_left, size=size.small)
        array.push(_labels, lb)
        lvl   := lvl + i_step
        count += 1

    if i_showInfo
        int totalLevels = count - 1
        string t1 = "Floor: " + str.tostring(i_basePrice, "#.##")
        string t2 = "Ceil:  " + str.tostring(i_topPrice,  "#.##")
        string t3 = "Step:  $" + str.tostring(i_step, "#.##")
        string t4 = "Levels: " + str.tostring(totalLevels)
        string inf = t1 + "\n" + t2 + "\n" + t3 + "\n" + t4
        _info := label.new(x=bar_index+i_lblOffset, y=i_topPrice, text=inf, color=color.new(color.black, 0), textcolor=color.new(#FFD700, 0), style=label.style_label_lower_left, size=size.small)
````
