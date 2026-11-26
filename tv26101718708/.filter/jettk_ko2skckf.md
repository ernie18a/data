# jett-k

- url: https://www.tradingview.com/script/KO2SkcKF/
- type: indicator
- pine_id: PUB;08effd06c0804ab39ae0e33e1b690923
- version: 1.0

## Description

jett制作的k线分析指标

## Source Code

````pine
//@version=5
indicator("多周期超买超卖信号", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// MA20（保持原样）
ma20 = ta.ema(close, 20)
plot(ma20, color=color.blue, linewidth=1, title="MA20")

// ======================================================================
// ★ 显示设置（所有开关和颜色都在此组，用户可在设置面板统一管理）
// ======================================================================
grp_display = "显示设置"

show_gray_box              = input.bool(true,  title="显示当前周期收敛直线", group=grp_display, tooltip="控制当前周期超买/超卖收敛时的直线是否显示（超买用黑色，超卖用红色）")
show_blue_box_5min         = input.bool(true,  title="显示蓝色框（5分钟HTF收敛，仅1分钟图）", group=grp_display, tooltip="仅在1分钟周期有效，控制5分钟收线后的蓝色矩形框")
show_blue_box_30min_on5min = input.bool(true,  title="显示30分钟灰色在5分钟图（蓝色呈现）", group=grp_display, tooltip="仅在5分钟周期有效，把30分钟周期的收敛信号用蓝色框显示在5分钟图上")

// 颜色配置（当前周期收敛直线已区分颜色）
c_overbought_line = input.color(color.black, title="超买收敛 - 黑色直线颜色", group=grp_display)
c_oversold_line   = input.color(color.red,   title="超卖收敛 - 红色直线颜色", group=grp_display)
c_blue_5min_input  = input.color(color.new(color.blue, 70), title="5分钟蓝色框颜色", group=grp_display)
c_blue_30min_input = input.color(color.new(color.blue, 70), title="30分钟蓝色框颜色（在5分钟图）", group=grp_display)
// ======================================================================
// 核心计算函数（保持不变）
// ======================================================================
f_calc(src_close, src_hlc3) =>
    var1     = ta.sma(src_hlc3, 5)
    var2     = ta.highest(var1, 10)
    buy_sell = ta.lowest(var1, 10)
    cond_dmai = src_close < buy_sell
    dmai_val  = math.sum(cond_dmai ? 1 : 0, 5) == 5 ? 15 : 0
    cond_dm   = src_close < var2
    dm_exist  = ta.highest(cond_dm ? 1 : 0, 5) == 1
    dm_val    = dm_exist ? 0 : 85
    [dm_val, dmai_val]

[dm_val, dmai_val] = f_calc(close, hlc3)

overbought_converge = (dm_val[1]   == 85 and dm_val   == 0)
oversold_converge   = (dmai_val[1] == 15 and dmai_val == 0)

// 多周期 higher_tf
higher_tf =
     timeframe.period == "1"  ? "5"  :
     timeframe.period == "5"  ? "30" :
     timeframe.period == "15" ? "60" : ""

[dm_val_h, dmai_val_h] = request.security(syminfo.tickerid, higher_tf, f_calc(close, hlc3), lookahead = barmerge.lookahead_on)
higher_bar_time = request.security(syminfo.tickerid, higher_tf, time, lookahead = barmerge.lookahead_on)

overbought_h_state    = (dm_val_h   == 85)
overbought_h_converge = (dm_val_h[1]   == 85 and dm_val_h   == 0)
oversold_h_state      = (dmai_val_h == 15)
oversold_h_converge   = (dmai_val_h[1] == 15 and dmai_val_h == 0)

tf_supported = higher_tf != ""

// ======================================================================
// 多周期背景色（红绿区间）——完整代码（保持不变）
// ======================================================================
c_oversold_light   = color.new(color.green, 100)
c_oversold_deep    = color.new(color.green, 100)
c_overbought_light = color.new(color.red,   100)
c_overbought_deep  = color.new(color.red,   100)

var bool locked_oversold_converge   = false
var bool locked_overbought_converge = false
var int  last_htf_time              = na

bar_ms = timeframe.in_seconds() * 1000
htf_bar_changed = higher_bar_time != last_htf_time

if htf_bar_changed
    locked_oversold_converge   := false
    locked_overbought_converge := false

if oversold_h_converge
    locked_oversold_converge   := true
if overbought_h_converge
    locked_overbought_converge := true

cur_state_color =
     tf_supported and locked_oversold_converge   ? c_oversold_deep    :
     tf_supported and oversold_h_state           ? c_oversold_light   :
     tf_supported and locked_overbought_converge ? c_overbought_deep  :
     tf_supported and overbought_h_state         ? c_overbought_light :
     na

in_any_zone = not na(cur_state_color)

var box   cur_box   = na
var float zone_high = na
var float zone_low  = na
var bool  in_zone   = false

if tf_supported
    if htf_bar_changed
        if in_zone and not na(cur_box)
            box.set_right(cur_box, time[1] + bar_ms)
        in_zone := false
        cur_box := na

    if in_any_zone
        if not in_zone
            zone_high := high
            zone_low  := low
            cur_box   := box.new(
                 left         = time,
                 top          = zone_high,
                 right        = time + bar_ms,
                 bottom       = zone_low,
                 xloc         = xloc.bar_time,
                 border_color = na,
                 bgcolor      = cur_state_color)
            in_zone := true
        else
            zone_high := math.max(zone_high, high)
            zone_low  := math.min(zone_low,  low)
            box.set_top(cur_box,    zone_high)
            box.set_bottom(cur_box, zone_low)
            box.set_right(cur_box,  time + bar_ms)
            box.set_bgcolor(cur_box, cur_state_color)
    else
        if in_zone and not na(cur_box)
            zone_high := math.max(zone_high, high)
            zone_low  := math.min(zone_low,  low)
            box.set_top(cur_box,    zone_high)
            box.set_bottom(cur_box, zone_low)
            box.set_right(cur_box,  time + bar_ms)
        in_zone := false
        cur_box := na

last_htf_time := higher_bar_time

// ======================================================================
// 当前周期收敛直线 —— 超买用黑色、超卖用红色，长度不变，宽度2
// ======================================================================
min_h = syminfo.mintick * 10
min_hh = syminfo.mintick * 20

if show_gray_box
    if overbought_converge
        line.new(x1=time, y1=low, x2=time + bar_ms * 30, y2=low,
             xloc=xloc.bar_time, color=c_overbought_line, width=2)

    if oversold_converge
        line.new(x1=time, y1=high, x2=time + bar_ms * 30, y2=high,
             xloc=xloc.bar_time, color=c_oversold_line, width=2)

// ======================================================================



// === 参数 ===
fvgLength = input.int(50, "每个 FVG 显示长度", minval=1)
maxActiveFVG = input.int(120, "最多保留FVG数量", minval=10, maxval=500)

showBullishFVG = input.bool(true, "显示上涨 FVG")
showBearishFVG = input.bool(true, "显示下跌 FVG")

mitigationMode = input.string("Full Fill", "FVG失效方式", options=["Touch", "Full Fill"])
deleteMitigated = input.bool(false, "被回补后删除FVG")
grayMitigated = input.bool(true, "被回补后变灰")
minGapPercent = input.float(0.0, "最小FVG幅度百分比", step=0.01)

// === 颜色 ===
bullColor = input.color(color.new(color.lime, 78), "上涨FVG颜色")
bearColor = input.color(color.new(color.red, 78), "下跌FVG颜色")
bullTextColor = input.color(color.lime, "上涨FVG文字颜色")
bearTextColor = input.color(color.red, "下跌FVG文字颜色")

// === 储存数组 ===
var box[] fvgBoxes = array.new_box()
var float[] fvgTop = array.new_float()
var float[] fvgBottom = array.new_float()
var int[] fvgDir = array.new_int()

// === FVG 条件 ===
// Bullish FVG：当前K线 low > 两根前K线 high
// Bearish FVG：当前K线 high < 两根前K线 low
bullishGap = low > high[2]
bearishGap = high < low[2]

// === Gap 百分比过滤 ===
bullGapSize = bullishGap ? (low - high[2]) / close * 100 : 0
bearGapSize = bearishGap ? (low[2] - high) / close * 100 : 0

validBullGap = bullishGap and bullGapSize >= minGapPercent
validBearGap = bearishGap and bearGapSize >= minGapPercent

// === 新建 Bullish FVG ===
if showBullishFVG and validBullGap
    topPrice = low
    bottomPrice = high[2]

    b = box.new(left=bar_index - 2, top=topPrice, right=bar_index - 2 + fvgLength, bottom=bottomPrice, bgcolor=bullColor, border_color=color.new(color.lime, 100), text="FVG", text_color=bullTextColor, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)

    array.push(fvgBoxes, b)
    array.push(fvgTop, topPrice)
    array.push(fvgBottom, bottomPrice)
    array.push(fvgDir, 1)

// === 新建 Bearish FVG ===
if showBearishFVG and validBearGap
    topPrice = low[2]
    bottomPrice = high

    b = box.new(left=bar_index - 2, top=topPrice, right=bar_index - 2 + fvgLength, bottom=bottomPrice, bgcolor=bearColor, border_color=color.new(color.red, 100), text="FVG", text_color=bearTextColor, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)

    array.push(fvgBoxes, b)
    array.push(fvgTop, topPrice)
    array.push(fvgBottom, bottomPrice)
    array.push(fvgDir, -1)

// === 回补 / 失效逻辑 ===
if array.size(fvgBoxes) > 0
    i = array.size(fvgBoxes) - 1

    while i >= 0
        b = array.get(fvgBoxes, i)
        topP = array.get(fvgTop, i)
        bottomP = array.get(fvgBottom, i)
        dir = array.get(fvgDir, i)

        bullTouched = dir == 1 and low <= topP
        bullFilled = dir == 1 and low <= bottomP

        bearTouched = dir == -1 and high >= bottomP
        bearFilled = dir == -1 and high >= topP

        mitigated = mitigationMode == "Touch" ? bullTouched or bearTouched : bullFilled or bearFilled

        if mitigated
            if deleteMitigated
                box.delete(b)
            else
                if grayMitigated
                    box.set_bgcolor(b, color.new(color.gray, 88))
                    box.set_text_color(b, color.gray)

            array.remove(fvgBoxes, i)
            array.remove(fvgTop, i)
            array.remove(fvgBottom, i)
            array.remove(fvgDir, i)

        i -= 1

// === 控制最大数量 ===
if array.size(fvgBoxes) > maxActiveFVG
    oldBox = array.shift(fvgBoxes)
    box.delete(oldBox)
    array.shift(fvgTop)
    array.shift(fvgBottom)
    array.shift(fvgDir)
````
