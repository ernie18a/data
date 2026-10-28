# Daily NQ Gamma Levels

- url: https://www.tradingview.com/script/4E7etSxH-Daily-NQ-Gamma-Levels/
- type: indicator
- pine_id: PUB;b84e298aa5a64f24a7406a16b1eef8d3
- version: 1.0

## Description

NQ GAMMA LEVELS template to use if you have the data

## Source Code

````pine
//@version=5
indicator("Daily NQ Gamma Levels", overlay=true, max_lines_count=100, max_labels_count=100)

showOnlyToday = input.bool(true, "Show only current day")
extendRight   = input.bool(true, "Extend lines right")
lineWidth     = input.int(2, "Line width", minval=1, maxval=4)
labelOffset   = input.int(15, "Right label offset (bars)", minval=1, maxval=200)
labelSizeOpt  = input.string("small", "Label size", options=["tiny", "small", "normal"])

levelsYear  = input.int(2026, "Levels year")
levelsMonth = input.int(5, "Levels month")
levelsDay   = input.int(31, "Levels day")

lvl1_price  = input.float(30500.0,  "1 Call Resistance")
lvl1_text   = input.string("Call Resistance", "1 Label")
lvl1_color  = input.color(color.red, "1 Color")

lvl2_price  = input.float(29400.0,  "2 Put Support")
lvl2_text   = input.string("Put Support", "2 Label")
lvl2_color  = input.color(color.lime, "2 Color")

lvl3_price  = input.float(29225.0,  "3 HVL")
lvl3_text   = input.string("HVL", "3 Label")
lvl3_color  = input.color(color.blue, "3 Color")

lvl4_price  = input.float(30035.72, "4 1D Min")
lvl4_text   = input.string("1D Min", "4 Label")
lvl4_color  = input.color(color.orange, "4 Color")

lvl5_price  = input.float(30774.78, "5 1D Max")
lvl5_text   = input.string("1D Max", "5 Label")
lvl5_color  = input.color(color.orange, "5 Color")

lvl6_price  = input.float(30300.0,  "6 Call Resistance 0DTE / Gamma Wall 0DTE")
lvl6_text   = input.string("Call Resistance 0DTE / Gamma Wall 0DTE", "6 Label")
lvl6_color  = input.color(color.red, "6 Color")

lvl7_price  = input.float(29720.0,  "7 Put Support 0DTE")
lvl7_text   = input.string("Put Support 0DTE", "7 Label")
lvl7_color  = input.color(color.lime, "7 Color")

lvl8_price  = input.float(29960.0,  "8 HVL 0DTE")
lvl8_text   = input.string("HVL 0DTE", "8 Label")
lvl8_color  = input.color(color.blue, "8 Color")

lvl9_price  = input.float(30200.0,  "9 GEX 1")
lvl9_text   = input.string("GEX 1", "9 Label")
lvl9_color  = input.color(color.teal, "9 Color")

lvl10_price = input.float(30600.0,  "10 GEX 2")
lvl10_text  = input.string("GEX 2", "10 Label")
lvl10_color = input.color(color.teal, "10 Color")

lvl11_price = input.float(30250.0,  "11 GEX 3")
lvl11_text  = input.string("GEX 3", "11 Label")
lvl11_color = input.color(color.teal, "11 Color")

labelSize = labelSizeOpt == "tiny" ? size.tiny : labelSizeOpt == "small" ? size.small : size.normal

isLevelDay = year(time) == levelsYear and month(time) == levelsMonth and dayofmonth(time) == levelsDay
shouldPlot = showOnlyToday ? isLevelDay : true
newSession = ta.change(time("D")) != 0

var line[]  lines  = array.new_line()
var label[] labels = array.new_label()

f_clear() =>
    int lineCount = array.size(lines)
    if lineCount > 0
        for i = lineCount - 1 to 0
            line.delete(array.get(lines, i))
        array.clear(lines)

    int labelCount = array.size(labels)
    if labelCount > 0
        for i = labelCount - 1 to 0
            label.delete(array.get(labels, i))
        array.clear(labels)

f_draw_level(_price, _text, _color) =>
    if not na(_price) and str.length(str.trim(_text)) > 0
        l = line.new(
             x1=bar_index,
             y1=_price,
             x2=bar_index + 1,
             y2=_price,
             extend=extendRight ? extend.right : extend.none,
             color=_color,
             width=lineWidth,
             style=line.style_solid)
        array.push(lines, l)

        lab = label.new(
             x=bar_index + labelOffset,
             y=_price,
             text=_text + "  " + str.tostring(_price),
             style=label.style_label_left,
             textcolor=color.white,
             color=_color,
             size=labelSize)
        array.push(labels, lab)

if barstate.isfirst or newSession
    f_clear()

    if shouldPlot
        f_draw_level(lvl1_price,  lvl1_text,  lvl1_color)
        f_draw_level(lvl2_price,  lvl2_text,  lvl2_color)
        f_draw_level(lvl3_price,  lvl3_text,  lvl3_color)
        f_draw_level(lvl4_price,  lvl4_text,  lvl4_color)
        f_draw_level(lvl5_price,  lvl5_text,  lvl5_color)
        f_draw_level(lvl6_price,  lvl6_text,  lvl6_color)
        f_draw_level(lvl7_price,  lvl7_text,  lvl7_color)
        f_draw_level(lvl8_price,  lvl8_text,  lvl8_color)
        f_draw_level(lvl9_price,  lvl9_text,  lvl9_color)
        f_draw_level(lvl10_price, lvl10_text, lvl10_color)
        f_draw_level(lvl11_price, lvl11_text, lvl11_color)
````
