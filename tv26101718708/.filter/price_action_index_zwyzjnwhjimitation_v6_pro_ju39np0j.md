# Price Action Index (ZWYZJNWHJ)[Imitation v6 Pro]

- url: https://www.tradingview.com/script/JU39Np0j/
- type: indicator
- pine_id: PUB;9c2329298f06432daedc8a7da3d9ea87
- version: 1.0

## Description

Imitation Price Action Index [v6 Pro]
这是一个基于 TradingView Pine Script v6 编写的自定义振荡器指标，名为 "Price Action Index" (PAI，价格行为指数)。它融合了多时间周期 (MTF) 框架、离散度计算 (Dispersion) 以及随机指标 (Stochastic)，并自带了底背离/顶背离自动检测和警报系统。

## Source Code

````pine
// © Copyleft - 这是一个由 Pine Script v6 仿写并优化的 Price Action Index 指标
//@version=6
indicator("Price Action Index [v6 规范版]", shorttitle="PAI_v6", overlay=false)

// ==========================
// 1. 输入参数与提示信息 (Inputs & Tooltips)
// ==========================
string tt_stoch    = "第一个值是传统随机指标的追溯长度。第二个是平滑长度。"
string tt_disp     = "下拉菜单选择离散度计算方法。后面的数字是测量的追溯长度。"
string tt_straddle = "该值定义了'跨式箱体'的大小，即价格在巩固期内的限制以及突破的界限。"
string tt_barcolor = "勾选此框可使K线颜色与价格行为指数的颜色保持一致。"

// --- 时间周期设置 ---
string TF0 = "无 (当前周期)"
string TF1 = "自动阶梯 (15m, 60m, 4H, 1D, 3D, 1W, 1M)"
string TF2 = "当前周期的倍数"
string TF3 = "固定时间周期"

string i_htfType   = input.string(TF0, "更高时间周期选择", options=[TF0, TF1, TF2, TF3], group="⌚ 时间周期 ⌚")
float  i_htfMult   = input.float(3.0, "当前周期的倍数", minval=1.0, group="⌚ 时间周期 ⌚")
string i_htfFixed  = input.timeframe("D", "固定时间周期", group="⌚ 时间周期 ⌚")
bool   i_htfRepaint= input.bool(false, "允许重绘 (不推荐)", group="⌚ 时间周期 ⌚")

// --- 核心参数 ---
int    stoch_len   = input.int(20, "随机指标长度 (Stoch)", inline="Stoch", group="⌨️ 核心输入 🖱")
int    smooth_len  = input.int(3, "平滑长度", inline="Stoch", tooltip=tt_stoch, group="⌨️ 核心输入 🖱")

string dis0 = "标准差 (Standard Deviation)"
string dis1 = "方差 (Variance)"
string dis2 = "变异系数 (Coefficient of Variation)"
string dis3 = "信噪比 (Signal-to-Noise)"
string dis4 = "信噪比平方 (Signal-to-Noise²)"
string dis5 = "离散指数 (Index of Dispersion)"
string dis6 = "效率比 (Efficiency)"
string dis7 = "高低价差范围 (High-Low Range)"

string dis_method  = input.string(dis0, "离散度方法", options=[dis0, dis1, dis2, dis3, dis4, dis5, dis6, dis7], inline="Disp", group="⌨️ 核心输入 🖱")
int    dis_len     = input.int(20, "离散度长度", inline="Disp", tooltip=tt_disp, group="⌨️ 核心输入 🖱")

// --- 输出与视觉 ---
float  straddle_area  = input.float(5.0, "跨式区间大小 (Straddle)", tooltip=tt_straddle, group="Outputs & Alerts")
bool   use_bar_colors = input.bool(false, "启用K线变色", tooltip=tt_barcolor, group="Outputs & Alerts")
bool   use_alerts     = input.bool(false, "启用弹出警报", group="Outputs & Alerts")

// --- 背离设置 ---
int  lbR             = input.int(2, "枢轴右侧回溯 (Pivot Right)", group="Divergence")
int  lbL             = input.int(2, "枢轴左侧回溯 (Pivot Left)", group="Divergence")
int  rangeUpper      = input.int(10, "最大背离回溯范围", group="Divergence")
int  rangeLower      = input.int(2, "最小背离回溯范围", group="Divergence")
bool plotBull        = input.bool(true, "显示常规牛市背离", group="Divergence")
bool plotHiddenBull  = input.bool(false, "显示隐藏牛市背离", group="Divergence")
bool plotBear        = input.bool(true, "显示常规熊市背离", group="Divergence")
bool plotHiddenBear  = input.bool(false, "显示隐藏熊市背离", group="Divergence")

// ==========================
// 2. 核心函数定义 (Functions)
// ==========================

// 离散度计算方法集合
f_calc_disp(int t_len, string method) =>
    switch method
        dis1 => ta.variance(close, t_len)
        dis2 => ta.stdev(close, t_len) / ta.sma(close, t_len)
        dis3 => -(ta.sma(close, t_len) / ta.stdev(close, t_len))
        dis4 => -(math.pow(ta.sma(close, t_len), 2) / math.pow(ta.stdev(close, t_len), 2))
        dis5 => math.pow(ta.variance(close, t_len), 2) / ta.sma(close, t_len)
        dis6 => math.pow(ta.stdev(close, t_len), 2) / math.pow(ta.sma(close, t_len), 2)
        dis7 => ta.highest(high, t_len) - ta.lowest(low, t_len)
        => ta.stdev(close, t_len) // 默认标准差

// PAI 核心算法
f_pai(int p_dis_len, int p_stoch_len, int p_smooth, string p_method) =>
    _disp = f_calc_disp(p_dis_len, p_method)
    _stoch_raw = ta.stoch(close, high, low, p_stoch_len)
    
    P = (ta.sma(_stoch_raw, p_smooth) - 50) / 50
    V = ta.stoch(_disp, _disp, _disp, p_stoch_len)
    P * V

// MTF 阶梯处理
f_resInMinutes() => 
    timeframe.isseconds ? timeframe.multiplier / 60. :
     timeframe.isminutes ? timeframe.multiplier * 1. :
     timeframe.isdaily   ? 1440. :
     timeframe.isweekly  ? 10080. :
     timeframe.ismonthly ? 43800. : na

f_resNextStep(float _res) =>
    _res <= 1    ? "15"  :
     _res <= 5   ? "60"  :
     _res <= 30  ? "240" :
     _res <= 60  ? "1D"  :
     _res <= 360 ? "3D"  :
     _res <= 1440? "1W"  :
     _res <= 10080? "1M" : "12M"

f_multipleOfRes(float _res, float _mult) => 
    _target = _res * math.max(_mult, 1.0)
    _target <= 1440 ? str.tostring(math.round(_target)) :
     _target <= 43800 ? str.tostring(math.round(math.min(_target / 1440, 365))) + "D" :
     str.tostring(math.round(math.min(_target / 43800, 12))) + "M"

// ==========================
// 3. 逻辑计算 (Calculations)
// ==========================
float resInMinutes = f_resInMinutes()
string htf = switch i_htfType
    TF1 => f_resNextStep(resInMinutes)
    TF2 => f_multipleOfRes(resInMinutes, i_htfMult)
    TF3 => i_htfFixed
    => timeframe.period

bool htfOn = i_htfType != TF0
float raw_pai = f_pai(dis_len, stoch_len, smooth_len, dis_method)

// v6 推荐的 request.security 防重绘数据读取方式
float rep_src = raw_pai
float no_rep_src = raw_pai[1]
float target_src = (not i_htfRepaint and barstate.isrealtime) ? no_rep_src : rep_src
float sec_data = request.security(syminfo.tickerid, htf, target_src)
float Z = not htfOn ? raw_pai : (i_htfRepaint or barstate.isrealtime ? sec_data : sec_data[1])

// 状态条件划分
bool straddle = Z < straddle_area and Z > -straddle_area
bool rally    = Z > 40.0
bool draw     = Z < -40.0

color col = straddle ? color.fuchsia : (Z > straddle_area ? color.lime : color.red)

// ==========================
// 4. 图表绘制与填充 (v6 兼容型)
// ==========================
plot(Z, color=col, linewidth=2, title="Price Action Index")

// 利用 plot() 输出来做 v6 的区间填充
p_straddle_top = plot(straddle_area, color=color.new(color.fuchsia, 50), title="跨式上限")
p_straddle_btm = plot(-straddle_area, color=color.new(color.fuchsia, 50), title="跨式下限")
fill(p_straddle_top, p_straddle_btm, color=straddle ? color.new(color.fuchsia, 85) : na, title="跨式区间填充")

p_ob1 = plot(80, color=color.new(color.gray, 70), title="超买边界下线")
p_ob2 = plot(100, color=color.new(color.gray, 70), title="超买边界上线")
fill(p_ob1, p_ob2, color=rally ? color.new(color.red, 80) : na, title="超买区填充")

p_os1 = plot(-80, color=color.new(color.gray, 70), title="超卖边界上线")
p_os2 = plot(-100, color=color.new(color.gray, 70), title="超卖边界下线")
fill(p_os1, p_os2, color=draw ? color.new(color.lime, 80) : na, title="超卖区填充")

// K线变色
barcolor(use_bar_colors ? col : na, title="PAI K线变色")

// 右上角静态信息看板 
var table infoTable = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(infoTable, 0, 0, text="计算周期: " + htf, bgcolor=color.new(color.blue, 30), text_color=color.white, text_size=size.small)

// ==========================
// 5. 背离检测逻辑 (Divergences)
// ==========================
float osc = Z
bool plFound = not na(ta.pivotlow(osc, lbL, lbR))
bool phFound = not na(ta.pivothigh(osc, lbL, lbR))

f_inRange(bool cond, int low_r, int up_r) =>
    int bars = ta.barssince(cond)
    low_r <= bars and bars <= up_r

// 常规牛市背离
bool oscHL   = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and f_inRange(plFound[1], rangeLower, rangeUpper)
bool priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bool bullCond = plotBull and priceLL and oscHL and plFound

plotshape(bullCond ? osc[lbR] : na, offset=-lbR, title="常规牛背离", text="Bull", style=shape.labelup, location=location.absolute, color=color.green, textcolor=color.white)

// 隐藏牛市背离
bool oscLL   = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and f_inRange(plFound[1], rangeLower, rangeUpper)
bool priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
bool hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound

plotshape(hiddenBullCond ? osc[lbR] : na, offset=-lbR, title="隐藏牛背离", text="H-Bull", style=shape.labelup, location=location.absolute, color=color.new(color.green, 40), textcolor=color.white)

// 常规熊市背离
bool oscLH   = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and f_inRange(phFound[1], rangeLower, rangeUpper)
bool priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bool bearCond = plotBear and priceHH and oscLH and phFound

plotshape(bearCond ? osc[lbR] : na, offset=-lbR, title="常规熊背离", text="Bear", style=shape.labeldown, location=location.absolute, color=color.red, textcolor=color.white)

// 隐藏熊市背离
bool oscHH   = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and f_inRange(phFound[1], rangeLower, rangeUpper)
bool priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
bool hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound

plotshape(hiddenBearCond ? osc[lbR] : na, offset=-lbR, title="隐藏熊背离", text="H-Bear", style=shape.labeldown, location=location.absolute, color=color.new(color.red, 40), textcolor=color.white)

// ==========================
// 6. 警报系统 (Alerts)
// ==========================
bool cond_bull_breakout = ta.crossover(Z, straddle_area)
bool cond_bear_breakout = ta.crossunder(Z, -straddle_area)

alertcondition(straddle, "处于跨式震荡区", "PAI指数当前处于粉色震荡蓄势区")
alertcondition(cond_bull_breakout, "多头爆发突破", "PAI向上突破跨式区间！")
alertcondition(cond_bear_breakout, "空头爆发突破", "PAI向下突破跨式区间！")

if use_alerts
    if cond_bull_breakout
        alert(syminfo.tickerid + " 多头爆发突破", alert.freq_once_per_bar_close)
    if cond_bear_breakout
        alert(syminfo.tickerid + " 空头爆发突破", alert.freq_once_per_bar_close)
````
