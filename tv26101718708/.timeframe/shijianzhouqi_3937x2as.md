# shijianzhouqi

- url: https://www.tradingview.com/script/3937x2As/
- type: indicator
- pine_id: PUB;baf5e321eda8473fa438d95804c992f9
- version: 1.0

## Description

时间周期指标,技术小组

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xushijie131452

//@version=5
indicator("多重时间周期", overlay=true, max_boxes_count=500, max_lines_count=500)

// ==========================================
// 1. 周期框设置 (Timeframe Settings)
// ==========================================
GRP_TF = "周期框设置"
in_auto_tf   = input.bool(false, "自动时间周期", tooltip="开启后根据当前图表自动选择周期", group=GRP_TF)
in_mtf       = input.timeframe("240", "时间周期", group=GRP_TF)
in_calc_type = input.string("按高低点", "计算方式", options=["按高低点", "按收盘价"], group=GRP_TF)
in_show_ha   = input.bool(false, "显示Heikin Ashi值", group=GRP_TF)
in_use_daily = input.bool(false, "使用基于日线的值", tooltip="强制使用日线数据为基准", group=GRP_TF)

// ==========================================
// 2. 颜色设置 (Color Settings)
// ==========================================
GRP_COL = "颜色设置"
col_up_fill   = input.color(color.new(color.gray, 100), "上涨K线填充色", inline="up_k", group=GRP_COL)
col_up_border = input.color(#ff9800, "上涨K线边框色", tooltip="边框颜色", inline="up_k", group=GRP_COL)

col_dn_fill   = input.color(color.new(color.gray, 100), "下跌K线填充色", inline="dn_k", group=GRP_COL)
col_dn_border = input.color(#795548, "下跌K线边框色", tooltip="边框颜色", inline="dn_k", group=GRP_COL)

show_body     = input.bool(true, "显示K线实体填充", tooltip="是否显示内部实体区域", group=GRP_COL)
col_up_body   = input.color(color.new(color.gray, 100), "上涨实体填充色", group=GRP_COL)
col_dn_body   = input.color(color.new(color.gray, 100), "下跌实体填充色", group=GRP_COL)

// ==========================================
// 3. 进场位线设置 (Entry Line Settings)
// ==========================================
GRP_ENT = "进场位线设置"
in_ent_calc = input.string("按高低点", "进场位计算方式", options=["按高低点", "按收盘价"], group=GRP_ENT)

// 1号进场位
show_e1 = input.bool(true, "1号进场位", inline="e1", group=GRP_ENT)
col_e1  = input.color(color.black, "颜色", inline="e1", group=GRP_ENT)
wid_e1  = input.int(1, "宽度", minval=1, inline="e1", group=GRP_ENT)
sty_e1  = input.string("dotted", "样式", options=["solid", "dotted", "dashed"], inline="e1", group=GRP_ENT)
val_e1  = input.float(0.5, "位置", step=0.01, group=GRP_ENT)

// 2号进场位
show_e2 = input.bool(true, "2号进场位", inline="e2", group=GRP_ENT)
col_e2  = input.color(color.black, "颜色", inline="e2", group=GRP_ENT)
wid_e2  = input.int(1, "宽度", minval=1, inline="e2", group=GRP_ENT)
sty_e2  = input.string("dotted", "样式", options=["solid", "dotted", "dashed"], inline="e2", group=GRP_ENT)
val_e2  = input.float(0.62, "位置", step=0.01, group=GRP_ENT)

// 3号进场位
show_e3 = input.bool(true, "3号进场位", inline="e3", group=GRP_ENT)
col_e3  = input.color(color.black, "颜色", inline="e3", group=GRP_ENT)
wid_e3  = input.int(1, "宽度", minval=1, inline="e3", group=GRP_ENT)
sty_e3  = input.string("dotted", "样式", options=["solid", "dotted", "dashed"], inline="e3", group=GRP_ENT)
val_e3  = input.float(0.72, "位置", step=0.01, group=GRP_ENT)

// ==========================================
// 4. 止盈位设置 (Take Profit Settings)
// ==========================================
GRP_TP = "止盈位设置"
show_tp = input.bool(true, "显示止盈位", inline="tp1", group=GRP_TP)
val_tp  = input.float(1.272, "倍数", step=0.001, inline="tp1", group=GRP_TP)
col_tp  = input.color(color.blue, "颜色", inline="tp1", group=GRP_TP)

wid_tp  = input.int(1, "线宽", minval=1, inline="tp2", group=GRP_TP)
sty_tp  = input.string("dotted", "样式", options=["solid", "dotted", "dashed"], inline="tp2", group=GRP_TP)


// ==========================================
// 逻辑与计算 (Logic & Calculation)
// ==========================================
// 解析线条样式
get_style(s) =>
    s == "dotted" ? line.style_dotted : s == "dashed" ? line.style_dashed : line.style_solid

// 获取实际使用的时间周期
current_tf = in_auto_tf ? timeframe.period : in_use_daily ? "D" : in_mtf

// 请求多重时间周期(MTF)数据
[htf_o, htf_h, htf_l, htf_c] = request.security(syminfo.tickerid, current_tf, [open, high, low, close], lookahead=barmerge.lookahead_on)

// 判断趋势和范围
is_bull = htf_c > htf_o
htf_range = htf_h - htf_l

// 计算进场和止盈位置 (按斐波那契回撤计算逻辑)
// 如果是阳线，回撤位从高点向下计算；如果是阴线，从低点向上计算。
calc_level(val) =>
    is_bull ? (htf_h - htf_range * val) : (htf_l + htf_range * val)

calc_tp(val) =>
    is_bull ? (htf_h + htf_range * (val - 1)) : (htf_l - htf_range * (val - 1))

// ==========================================
// 绘图核心逻辑 (Drawing Logic)
// ==========================================
var box mtf_box = na
var box mtf_body = na
var line l_e1 = na
var line l_e2 = na
var line l_e3 = na
var line l_tp = na

// 判断MTF周期是否发生切换
is_new_tf = ta.change(time(current_tf)) != 0

if is_new_tf
    // 绘制外层K线边框(影线范围)
    mtf_box := box.new(left=bar_index, top=htf_h, right=bar_index, bottom=htf_l, 
                       border_color=is_bull ? col_up_border : col_dn_border, 
                       border_width=1, 
                       bgcolor=is_bull ? col_up_fill : col_dn_fill)
    
    // 绘制K线实体
    if show_body
        mtf_body := box.new(left=bar_index, top=math.max(htf_o, htf_c), right=bar_index, bottom=math.min(htf_o, htf_c), 
                           border_color=na, 
                           bgcolor=is_bull ? col_up_body : col_dn_body)

    // 绘制1号进场位
    if show_e1
        l_e1 := line.new(bar_index, calc_level(val_e1), bar_index, calc_level(val_e1), color=col_e1, width=wid_e1, style=get_style(sty_e1))
    
    // 绘制2号进场位
    if show_e2
        l_e2 := line.new(bar_index, calc_level(val_e2), bar_index, calc_level(val_e2), color=col_e2, width=wid_e2, style=get_style(sty_e2))
    
    // 绘制3号进场位
    if show_e3
        l_e3 := line.new(bar_index, calc_level(val_e3), bar_index, calc_level(val_e3), color=col_e3, width=wid_e3, style=get_style(sty_e3))

    // 绘制止盈位
    if show_tp
        l_tp := line.new(bar_index, calc_tp(val_tp), bar_index, calc_tp(val_tp), color=col_tp, width=wid_tp, style=get_style(sty_tp))

else
    // 延续当前周期的框和线到最新的一根K线
    box.set_right(mtf_box, bar_index)
    box.set_right(mtf_body, bar_index)
    
    // 动态更新线条的右端点和水平值 (确保实时波动下线条高度准确)
    line.set_xy1(l_e1, line.get_x1(l_e1), calc_level(val_e1))
    line.set_xy2(l_e1, bar_index, calc_level(val_e1))
    
    line.set_xy1(l_e2, line.get_x1(l_e2), calc_level(val_e2))
    line.set_xy2(l_e2, bar_index, calc_level(val_e2))
    
    line.set_xy1(l_e3, line.get_x1(l_e3), calc_level(val_e3))
    line.set_xy2(l_e3, bar_index, calc_level(val_e3))
    
    line.set_xy1(l_tp, line.get_x1(l_tp), calc_tp(val_tp))
    line.set_xy2(l_tp, bar_index, calc_tp(val_tp))

    // 动态更新K线框的高度(应对未收盘时的高低点刷新)
    box.set_top(mtf_box, htf_h)
    box.set_bottom(mtf_box, htf_l)
    box.set_top(mtf_body, math.max(htf_o, htf_c))
    box.set_bottom(mtf_body, math.min(htf_o, htf_c))
````
