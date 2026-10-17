# XAUUSD Major Levels

- url: https://www.tradingview.com/script/2sdSZ04O-XAUUSD-Major-Levels/
- type: indicator
- pine_id: PUB;48d130345f7b4bdf91fe8428b1f0273d
- version: 1.0

## Description

Major round and quarter levels on gold showing the lines on historical dtata

## Source Code

````pine
//@version=5
indicator("XAUUSD Round Levels", overlay=true, max_lines_count=500)

dark_red = color.new(color.rgb(180, 30, 30), 0)
light_blue = color.new(color.rgb(100, 200, 255), 0)
line_width = input.int(1, "Line Width", minval=1, maxval=4)

hi = ta.highest(high, 500)
lo = ta.lowest(low, 500)

range_top = math.ceil(hi / 25) * 25
range_bot = math.floor(lo / 25) * 25

var line[] level_lines = array.new_line()

if barstate.islast
    for l in level_lines
        line.delete(l)
    array.clear(level_lines)

    lvl = range_bot
    while lvl <= range_top
        is_00 = lvl % 100 == 0
        is_50 = math.abs(lvl % 100) == 50
        is_25 = math.abs(lvl % 25) == 0 and not is_00 and not is_50

        if is_00
            array.push(level_lines, line.new(bar_index - 10000, lvl, bar_index, lvl, extend=extend.right, color=dark_red, width=line_width, style=line.style_solid))
        else if is_50
            array.push(level_lines, line.new(bar_index - 10000, lvl, bar_index, lvl, extend=extend.right, color=light_blue, width=line_width, style=line.style_dotted))
        else if is_25
            array.push(level_lines, line.new(bar_index - 10000, lvl, bar_index, lvl, extend=extend.right, color=light_blue, width=line_width, style=line.style_dotted))

        lvl := lvl + 25
````
