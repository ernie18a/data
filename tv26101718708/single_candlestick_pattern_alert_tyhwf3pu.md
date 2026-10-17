# Single Candlestick Pattern Alert

- url: https://www.tradingview.com/script/TyHWF3pU/
- type: indicator
- pine_id: PUB;8c52bb73c95f42a3ad7c4ebcd28cb1e2
- version: 1.0

## Description

单 K 线类型报警九大类。

## Source Code

````pine
//@version=6
indicator(title="单K线类型报警", overlay=true)

// ========== 分组定义 ==========
group_up = "【上涨类】"
group_down = "【下跌类】"
group_special = "【特殊类】"

// ========== 上涨开关 ==========
enable_up_type1 = input.bool(true, "↑ 第1类：实体突破非趋势", group=group_up)
enable_up_type2 = input.bool(true, "↑ 第2类：实体突破清扫", group=group_up)
enable_up_type3 = input.bool(true, "↑ 第3类：实体突破非清扫", group=group_up)
enable_up_type4 = input.bool(true, "↑ 第4类：影线突破", group=group_up)

// ========== 下跌开关 ==========
enable_down_type1 = input.bool(true, "↓ 第1类：实体突破非趋势", group=group_down)
enable_down_type2 = input.bool(true, "↓ 第2类：实体突破清扫", group=group_down)
enable_down_type3 = input.bool(true, "↓ 第3类：实体突破非清扫", group=group_down)
enable_down_type4 = input.bool(true, "↓ 第4类：影线突破", group=group_down)

// ========== 第9类开关 ==========
enable_type9 = input.bool(true, "※ 第9类：实体外包（白色）", group=group_special)

// ========== 参数 ==========
wick_ratio = input.float(1.5, "影线/实体倍数", minval=0.5, maxval=10, step=0.5, group=group_special)

// ========== 颜色自定义 ==========
up_color_123 = input.color(color.new(#008000, 0), "↑ 上涨第1-3类颜色", group=group_up)
up_color_4 = input.color(color.new(#90EE90, 0), "↑ 上涨第4类颜色", group=group_up)
down_color_123 = input.color(color.new(#FF0000, 0), "↓ 下跌第1-3类颜色", group=group_down)
down_color_4 = input.color(color.new(#FF9999, 0), "↓ 下跌第4类颜色", group=group_down)
type9_color = input.color(color.new(#FFFFFF, 0), "※ 第9类颜色", group=group_special)

// ========== 调试开关 ==========
debug = input.bool(false, "显示调试标签", group=group_special)

// ========== 新增：实体突破标记开关 ==========
show_break_dot = input.bool(true, "◆ 显示实体突破标记（绿色/红色圆点）", group=group_special)

// ========== 数据 ==========
leftHigh = high[1]
leftLow = low[1]

currentBodyHigh = math.max(open, close)
currentBodyLow = math.min(open, close)
currentHigh = high
currentLow = low
currentUpperWick = currentHigh - currentBodyHigh
currentLowerWick = currentBodyLow - currentLow
currentBodyLength = currentBodyHigh - currentBodyLow

// ========== 上涨类 ==========
// 实体突破：实体高点 > 左侧影线高点
isUpBreak = currentBodyHigh > leftHigh
// 影线突破：影线高点 > 左侧影线高点 且 实体高点 <= 左侧影线高点
isUpWickBreak = currentHigh > leftHigh and currentBodyHigh <= leftHigh

// ========== 下跌类 ==========
// 实体跌破：实体低点 < 左侧影线低点
isDownBreak = currentBodyLow < leftLow
// 影线跌破：影线低点 < 左侧影线低点 且 实体低点 >= 左侧影线低点
isDownWickBreak = currentLow < leftLow and currentBodyLow >= leftLow

// ========== 第1类：影线过长 ==========
totalWick = currentUpperWick + currentLowerWick
type1_condition = totalWick >= currentBodyLength * wick_ratio

// ========== 第2类：清扫 ==========
up_type2 = isUpBreak and not type1_condition and currentLow < leftLow
up_type3 = isUpBreak and not type1_condition and currentLow > leftLow

down_type2 = isDownBreak and not type1_condition and currentHigh > leftHigh
down_type3 = isDownBreak and not type1_condition and currentHigh < leftHigh

// ========== 第4类：影线突破 ==========
up_type4 = isUpWickBreak and currentLow > leftLow
down_type4 = isDownWickBreak and currentHigh < leftHigh

// ========== 第9类：实体外包 ==========
type9_condition = currentBodyHigh > leftHigh and currentBodyLow < leftLow

// 内保和双向只有影线突破。
insideBar = high < high[1] and low > low[1]
dualWick = (high > high[1] and low < low[1] and math.max(open, close) <= high[1] and math.min(open, close) >= low[1])
// ========== 应用颜色 ==========
finalColor = 
   // 第9类（最高优先级）
   enable_type9 and type9_condition ? type9_color :
   // 上涨方向
   enable_up_type1 and isUpBreak and type1_condition ? up_color_123 :
   enable_up_type2 and up_type2 ? up_color_123 :
   enable_up_type3 and up_type3 ? up_color_123 :
   enable_up_type4 and up_type4 ? up_color_4 :
   // 下跌方向
   enable_down_type1 and isDownBreak and type1_condition ? down_color_123 :
   enable_down_type2 and down_type2 ? down_color_123 :
   enable_down_type3 and down_type3 ? down_color_123 :
   enable_down_type4 and down_type4 ? down_color_4 :
   na

barcolor(finalColor)

// ========== 调试标签 ==========
if debug
    if enable_type9 and type9_condition
        label.new(bar_index, high, "※9实体外包", color=color.new(color.white, 70))
    else if enable_up_type1 and isUpBreak and type1_condition
        label.new(bar_index, high, "↑1实体突破但非趋势", color=color.new(color.green, 70))
    else if enable_up_type2 and up_type2
        label.new(bar_index, high, "↑2清扫后实体突破", color=color.new(color.green, 70))
    else if enable_up_type3 and up_type3
        label.new(bar_index, high, "↑3没清扫后实体突破", color=color.new(color.green, 70))
    else if enable_up_type4 and up_type4
        label.new(bar_index, high, "↑4影线突破无清扫", color=color.new(color.green, 70))
    else if enable_down_type1 and isDownBreak and type1_condition
        label.new(bar_index, low, "↓1实体突破但非趋势", color=color.new(color.red, 70), style=label.style_label_down)
    else if enable_down_type2 and down_type2
        label.new(bar_index, low, "↓2清扫后实体突破", color=color.new(color.red, 70), style=label.style_label_down)
    else if enable_down_type3 and down_type3
        label.new(bar_index, low, "↓3没清扫后实体突破", color=color.new(color.red, 70), style=label.style_label_down)
    else if enable_down_type4 and down_type4
        label.new(bar_index, low, "↓4影线突破无清扫", color=color.new(color.red, 70), style=label.style_label_down)




message="" +
         (enable_type9 and type9_condition? "↑↓双向实体突破" :"")+
         (enable_up_type1 and isUpBreak and type1_condition? "↑实体上破+非趋势" :"")+
         (enable_up_type2 and up_type2? "↑实体上破+清扫" :"")+         
         (enable_up_type3 and up_type3? "↑实体上破+无清扫" :"")+
         (enable_up_type4 and up_type4? "↑影线上破+无清扫" :"")+
         (enable_down_type1 and isDownBreak and type1_condition? "↓实体下破+非趋势" :"") +
         (enable_down_type2 and down_type2? "↓实体下破+清扫" :"")+         
         (enable_down_type3 and down_type3? "↓实体下破+无清扫" :"")+
         (enable_down_type4 and down_type4? "↓影线下破+无清扫" :"")+
         (insideBar ? "完全内包" :"")+
         (dualWick? "↑↓双向只影线突破" :"")
alert(message,alert.freq_once_per_bar_close)
// // 向上实体突破标记（在下影线位置标绿色圆点）
// plot(show_break_dot and isUpBreak ? currentLow : na, title="向上实体突破", 
//      style=plot.style_circles, color=color.new(color.green, 0), linewidth=2, offset=0)

// // 向下实体突破标记（在上影线位置标红色圆点）
// plot(show_break_dot and isDownBreak ? currentHigh : na, title="向下实体突破", 
//      style=plot.style_circles, color=color.new(color.red, 0), linewidth=2, offset=0)

// plot(show_break_dot and type1_condition ? currentHigh : na, title="非趋势k", 
//      style=plot.style_circles, color=color.new(#52ff61, 0), linewidth=2, offset=0)

// plot(show_break_dot and type1_condition ? currentHigh : na, title="非趋势k", 
//      style=plot.style_circles, color=color.new(#52ff61, 0), linewidth=2, offset=0)    

// alertcondition(show_break_dot and (isUpBreak or isDownBreak or type1_condition), title="实体突破报警", 
//                message="向上实体突破{{plot(\"向上实体突破\")}}，向下实体突破{{plot(\"向下实体突破\")}},非趋势k{{plot(\"非趋势k\")}}")
````
