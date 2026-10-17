# MACROS NSL

- url: https://www.tradingview.com/script/Se409dRq/
- type: indicator
- pine_id: PUB;8101776546a845e49b5bb31f51848b3d
- version: 1.0

## Description

Son los macros de en donde los precios de las velas se mueven de manera eviciente

## Source Code

````pine
//@version=5
indicator("MACROS NSL", overlay=true, max_boxes_count=500, max_labels_count=500)

is_low_tf = timeframe.in_seconds(timeframe.period) <= 300

label_mode  = input.string("Nombre + Hora", "Modo de Etiqueta", options=["Nombre + Hora", "Solo Nombre", "Solo Hora"])
offset_base = input.int(35, "Distancia velas (Ticks)", minval=0)
stack_step  = input.int(50, "Separación macros", minval=10)
line_color  = input.color(color.rgb(0, 0, 0), "Color")

g_fx = "FOREX"
f1=input.bool(false, "2:33 - 2:45", group=g_fx), f2=input.bool(false, "3:20 - 3:40", group=g_fx)
f3=input.bool(false, "4:03 - 4:30", group=g_fx), f4=input.bool(false, "4:40 - 5:15", group=g_fx)
f5=input.bool(false, "5:20 - 5:40", group=g_fx), f6=input.bool(false, "7:50 - 8:10", group=g_fx)
f7=input.bool(false, "8:20 - 8:45", group=g_fx), f8=input.bool(false, "8:50 - 9:10", group=g_fx)
f9=input.bool(false, "9:20 - 9:40", group=g_fx), f10=input.bool(false, "9:50 - 10:10", group=g_fx)
f11=input.bool(false, "10:20 - 10:40", group=g_fx), f12=input.bool(false, "10:50 - 11:10 (NY Lunch)", group=g_fx)
f13=input.bool(false, "11:20 - 11:40", group=g_fx), f14=input.bool(false, "12:00 - 13:30 (LUNCH HOUR)", group=g_fx)
f15=input.bool(false, "14:20 - 14:40", group=g_fx), f16=input.bool(false, "15:15 - 15:35", group=g_fx)
f17=input.bool(false, "16:15 - 16:45", group=g_fx), f18=input.bool(false, "19:20 - 19:40", group=g_fx)
f19=input.bool(false, "20:15 - 20:50", group=g_fx), f20=input.bool(false, "21:15 - 21:35", group=g_fx)

g_fu = "FUTUROS"
u1=input.bool(true, "Opening Range: 9:30 - 10:30", group=g_fu)
u2=input.bool(true, "Opening Range Bell: 9:30 - 10:00", group=g_fu)
u3=input.bool(false, "2:33 - 3:10", group=g_fu), u4=input.bool(false, "4:03 - 4:30", group=g_fu)
u5=input.bool(false, "5:20 - 5:40", group=g_fu), u6=input.bool(false, "5:50 - 6:10", group=g_fu)
u7=input.bool(false, "7:50 - 8:10", group=g_fu), u8=input.bool(false, "8:20 - 8:40", group=g_fu)
u9=input.bool(false, "8:50 - 9:10", group=g_fu), u10=input.bool(false, "9:20 - 9:40", group=g_fu)
u11=input.bool(true, "9:30 - 9:45", group=g_fu), u12=input.bool(true, "9:50 - 10:10", group=g_fu)
u13=input.bool(true, "10:20 - 10:40", group=g_fu), u14=input.bool(false, "10:50 - 11:10 (NY Lunch)", group=g_fu)
u15=input.bool(false, "11:20 - 11:40", group=g_fu), u16=input.bool(false, "11:30 - 13:30 (PRE NY LUNCH)", group=g_fu)
u17=input.bool(false, "11:50 - 12:10", group=g_fu), u18=input.bool(false, "12:00 - 13:30 (LUNCH HOUR)", group=g_fu)
u19=input.bool(false, "13:10 - 13:40", group=g_fu), u20=input.bool(false, "14:20 - 14:40", group=g_fu)
u21=input.bool(false, "15:15 - 15:45", group=g_fu), u22=input.bool(false, "15:50 - 16:10", group=g_fu)

drawBracket(bool active, string sess, string name, string time_str, int level) =>
    if active and is_low_tf
        in_sess = not na(time(timeframe.period, sess, "America/New_York"))
        var box b_top = na
        var box b_l = na
        var box b_r = na
        var label lb = na
        var float max_h = na

        is_first = in_sess and not in_sess[1]
        is_active_draw = in_sess or (not in_sess and in_sess[1])

        if is_first
            max_h := high
            y_top = max_h + (offset_base * syminfo.mintick) + (level * stack_step * syminfo.mintick)
            y_side = y_top - (12 * syminfo.mintick)

            b_top := box.new(bar_index, y_top, bar_index, y_top, border_color=line_color, bgcolor=color.new(line_color, 100))
            b_l   := box.new(bar_index, y_top, bar_index, y_side, border_color=line_color, bgcolor=color.new(line_color, 100))
            b_r   := box.new(bar_index, y_top, bar_index, y_side, border_color=line_color, bgcolor=color.new(line_color, 100))

            txt = label_mode == "Nombre + Hora" ? name + "\n" + time_str : label_mode == "Solo Nombre" ? name : time_str
            lb := label.new(bar_index, y_top, txt, style=label.style_none, textcolor=line_color, size=size.small, textalign=text.align_center)

        if is_active_draw and not na(b_top)
            max_h := math.max(max_h, high)
            y_top = max_h + (offset_base * syminfo.mintick) + (level * stack_step * syminfo.mintick)
            y_side = y_top - (12 * syminfo.mintick)
            st_bar = box.get_left(b_top)

            box.set_top(b_top, y_top)
            box.set_bottom(b_top, y_top)
            box.set_right(b_top, bar_index)

            box.set_lefttop(b_l, st_bar, y_top)
            box.set_rightbottom(b_l, st_bar, y_side)

            box.set_lefttop(b_r, bar_index, y_top)
            box.set_rightbottom(b_r, bar_index, y_side)

            label.set_xy(lb, math.round(math.avg(st_bar, bar_index)), y_top + (5 * syminfo.mintick))

drawBracket(f1, "0233-0245", "MACRO", "2:33 - 2:45", 0)
drawBracket(f2, "0320-0340", "MACRO", "3:20 - 3:40", 0)
drawBracket(f3, "0403-0430", "MACRO", "4:03 - 4:30", 0)
drawBracket(f4, "0440-0515", "MACRO", "4:40 - 5:15", 0)
drawBracket(f5, "0520-0540", "MACRO", "5:20 - 5:40", 0)
drawBracket(f6, "0750-0810", "MACRO", "7:50 - 8:10", 0)
drawBracket(f7, "0820-0845", "MACRO", "8:20 - 8:45", 0)
drawBracket(f8, "0850-0910", "MACRO", "8:50 - 9:10", 0)
drawBracket(f9, "0920-0940", "MACRO", "9:20 - 9:40", 0)
drawBracket(f10, "0950-1010", "MACRO", "9:50 - 10:10", 0)
drawBracket(f11, "1020-1040", "MACRO", "10:20 - 10:40", 0)
drawBracket(f12, "1050-1110", "NY LUNCH", "10:50 - 11:10", 0)
drawBracket(f13, "1120-1140", "MACRO", "11:20 - 11:40", 0)
drawBracket(f14, "1200-1330", "LUNCH HOUR", "12:00 - 13:30", 0)
drawBracket(f15, "1420-1440", "MACRO", "14:20 - 14:40", 0)
drawBracket(f16, "1515-1535", "MACRO", "15:15 - 15:35", 0)
drawBracket(f17, "1615-1645", "MACRO", "16:15 - 16:45", 0)
drawBracket(f18, "1920-1940", "MACRO", "19:20 - 19:40", 0)
drawBracket(f19, "2015-2050", "MACRO", "20:15 - 20:50", 0)
drawBracket(f20, "2115-2135", "MACRO", "21:15 - 21:35", 0)

drawBracket(u1, "0930-1030", "Opening Range", "9:30 - 10:30", 2)
drawBracket(u2, "0930-1000", "Opening Range Bell", "9:30 - 10:00", 1)
drawBracket(u11, "0930-0945", "MACRO", "9:30 - 9:45", 0)
drawBracket(u3, "0233-0310", "MACRO", "2:33 - 3:10", 0)
drawBracket(u4, "0403-0430", "MACRO", "4:03 - 4:30", 0)
drawBracket(u5, "0520-0540", "MACRO", "5:20 - 5:40", 0)
drawBracket(u6, "0550-0610", "MACRO", "5:50 - 6:10", 0)
drawBracket(u7, "0750-0810", "MACRO", "7:50 - 8:10", 0)
drawBracket(u8, "0820-0840", "MACRO", "8:20 - 8:40", 0)
drawBracket(u9, "0850-0910", "MACRO", "8:50 - 9:10", 0)
drawBracket(u10, "0920-0940", "MACRO", "9:20 - 9:40", 0)
drawBracket(u12, "0950-1010", "MACRO", "9:50 - 10:10", 0)
drawBracket(u13, "1020-1040", "MACRO", "10:20 - 10:40", 0)
drawBracket(u14, "1050-1110", "NY LUNCH", "10:50 - 11:10", 0)
drawBracket(u15, "1120-1140", "MACRO", "11:20 - 11:40", 0)
drawBracket(u16, "1130-1330", "PRE LUNCH", "11:30 - 13:30", 1)
drawBracket(u18, "1200-1330", "LUNCH HOUR", "12:00 - 13:30", 0)
drawBracket(u17, "1150-1210", "MACRO", "11:50 - 12:10", 0)
drawBracket(u19, "1310-1340", "MACRO", "13:10 - 13:40", 0)
drawBracket(u20, "1420-1440", "MACRO", "14:20 - 14:40", 0)
drawBracket(u21, "1515-1545", "MACRO", "15:15 - 15:45", 0)
drawBracket(u22, "1550-1610", "MACRO", "15:50 - 16:10", 0)
````
