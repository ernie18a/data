# Charles 4 HOUR LOOP

- url: https://www.tradingview.com/script/qP5AVgOX-Charles-4-HOUR-LOOP/
- type: indicator
- pine_id: PUB;e3b8765447154056bd006ec21aabdcd7
- version: 1.0

## Description

This indicator is strictly useful for Charles's students

## Source Code

````pine
//@version=5
indicator("每4小时竖线 (0,4,8,12,16,20点) - 无限长", shorttitle="4H 竖线", overlay=true, max_lines_count=500)

// ==================== 输入设置 ====================
line_color       = input.color(color.new(#FF5252, 0), "竖线颜色", group="设置")
line_style_input = input.string("solid", "线条样式", options=["solid", "dashed", "dotted"], group="设置")
line_width       = input.int(1, "线条宽度", minval=1, maxval=4, group="设置")
show_label       = input.bool(true, "在竖线上方显示时间标签", group="设置")

// ==================== 转换线条样式 ====================
line_style = line_style_input == "dashed" ? line.style_dashed :
             line_style_input == "dotted" ? line.style_dotted :
             line.style_solid

// ==================== 核心逻辑 ====================
h = hour(time, syminfo.timezone)

// 判断是否为 0,4,8,12,16,20 整点
is_target_hour = h == 0 or h == 4 or h == 8 or h == 12 or h == 16 or h == 20

// 检测新整点小时的第一根K线
new_target_bar = is_target_hour and (h != h[1] or barstate.isfirst)

// 画无限长竖线
if new_target_bar
    line.new(x1 = bar_index,y1 = low,x2 = bar_index,y2 = high,color = line_color,width = line_width,style = line_style,extend = extend.both)

    
    // 显示时间标签
    if show_label
        label.new(x = bar_index,y = high * 1.005,text = str.tostring(h) + ":00",style = label.style_label_down,color = color.new(line_color, 80),textcolor = color.white,size = size.small,yloc = yloc.abovebar)
````
