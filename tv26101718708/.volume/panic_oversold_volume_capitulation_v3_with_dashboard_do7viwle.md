# Panic Oversold & Volume Capitulation v3 (With Dashboard)

- url: https://www.tradingview.com/script/do7vIwle-Panic-Oversold-Volume-Capitulation-v3-With-Dashboard/
- type: indicator
- pine_id: PUB;b0cfd41cfc054c31b6ab4d2834138f90
- version: 1.0

## Description

Based on this chart

RSI(14) < 30
RSI(6) < 25
ATH回撤 >-30%
Stoch K < 15
成交量 >中位数
成交量比 > 1.2
VIX > 25

## Source Code

````pine
//@version=5
indicator("Panic Oversold & Volume Capitulation v3 (With Dashboard)", overlay=true)

// ================= 1. 输入参数设置 =================
// 超卖指标组
grp_oversold = "超卖与恐慌指标 (Oversold & Panic)"
rsi14_thresh = input.float(30, title="RSI(14) 极度超卖线", group=grp_oversold)
rsi6_thresh  = input.float(25, title="RSI(6) 极度超卖线", group=grp_oversold)
stoch_thresh = input.float(15, title="Stoch K 极度超卖线", group=grp_oversold)
vix_thresh   = input.float(25, title="VIX 恐慌区间阈值", group=grp_oversold)
dd_thresh    = input.float(30, title="从ATH回撤幅度 (%)", group=grp_oversold)

// 量能确认组
grp_vol = "量能确认指标 (Volume Confirmation)"
vol_median_len = input.int(50, title="成交量中位数计算周期", group=grp_vol)
vol_ratio_thresh = input.float(1.2, title="成交量比 (相对20均量)", step=0.1, group=grp_vol)
vol_length = input.int(20, title="均量计算周期", group=grp_vol)

// 可视化组
grp_vis = "可视化与面板 (Visualization & Dashboard)"
waiting_bg_color = input.color(color.new(color.fuchsia, 70), title="超卖缩量警示背景色", group=grp_vis)
table_pos = input.string("Bottom Right", title="面板位置", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grp_vis)

// ================= 2. 核心数据计算 =================
rsi14 = ta.rsi(close, 14)
rsi6  = ta.rsi(close, 6)
stoch_k = ta.sma(ta.stoch(close, high, low, 14), 3)

var float ath = high
ath := math.max(ath, high)
drawdown_pct = ((close - ath) / ath) * 100

vol_sma = ta.sma(volume, vol_length)
vol_ratio = volume / vol_sma
vol_median = ta.median(volume, vol_median_len)

vix_close = request.security("CBOE:VIX", "D", close)

// ================= 3. 独立逻辑条件判断 =================
c_rsi14 = (rsi14 < rsi14_thresh)
c_rsi6  = (rsi6 < rsi6_thresh)
c_dd    = (drawdown_pct <= -math.abs(dd_thresh))
c_stoch = (stoch_k < stoch_thresh)
c_vol   = (volume > vol_median)
c_ratio = (vol_ratio > vol_ratio_thresh)
c_vix   = (vix_close > vix_thresh)

// 组合信号
cond_oversold = c_rsi14 and c_rsi6 and c_stoch and c_vix and c_dd
cond_volume   = c_vol and c_ratio

signal_waiting = cond_oversold and not cond_volume
signal_confirmed = cond_oversold and cond_volume

// ================= 4. 图表可视化与报警 =================
bgcolor(signal_waiting ? waiting_bg_color : na, title="超卖但缩量(等待确认)")
plotshape(signal_confirmed, style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small, title="放量确认抄底信号")

alertcondition(signal_confirmed, title="极度超卖且巨量承接", message="检测到 {{ticker}} 发生极端超卖与巨量筹码交换！")
alertcondition(signal_waiting, title="进入超卖区间(待放量)", message="{{ticker}} 已进入极度超卖区间，等待量能确认。")

// ================= 5. 动态数据面板 (Table Dashboard) =================
// 确定面板位置
pos = position.bottom_right
if table_pos == "Top Right"
    pos := position.top_right
else if table_pos == "Top Left"
    pos := position.top_left
else if table_pos == "Bottom Left"
    pos := position.bottom_left

// 初始化 Table
var table dash = table.new(pos, 3, 8, border_width=1, border_color=color.new(color.gray, 50), frame_color=color.new(color.gray, 50), frame_width=1)

// 辅助函数：快速填充表格行
f_fill_row(tbl, row, title, val_str, condition) =>
    bg_color = condition ? color.new(color.green, 70) : color.new(color.red, 70)
    status_str = condition ? "✅ 满足" : "❌ 不满足"
    
    // 单元格: 条件名称
    table.cell(tbl, 0, row, title, text_color=color.white, bgcolor=color.new(color.black, 40), text_size=size.small)
    // 单元格: 当前值
    table.cell(tbl, 1, row, val_str, text_color=color.white, bgcolor=color.new(color.black, 40), text_size=size.small)
    // 单元格: 状态 (绿/红)
    table.cell(tbl, 2, row, status_str, text_color=color.white, bgcolor=bg_color, text_size=size.small)

// 只在最后一根K线更新面板（节省性能，且符合实时看盘需求）
if barstate.islast
    // 表头
    table.cell(dash, 0, 0, "条件", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(dash, 1, 0, "当前值", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(dash, 2, 0, "状态", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    
    // 填充数据行
    f_fill_row(dash, 1, "RSI(14)", str.tostring(rsi14, "#.##"), c_rsi14)
    f_fill_row(dash, 2, "RSI(6)", str.tostring(rsi6, "#.##"), c_rsi6)
    f_fill_row(dash, 3, "从ATH回撤", str.tostring(drawdown_pct, "#.##") + "%", c_dd)
    f_fill_row(dash, 4, "Stoch K", str.tostring(stoch_k, "#.##"), c_stoch)
    f_fill_row(dash, 5, "成交量", str.tostring(volume / 1000000, "#.##") + "M", c_vol)
    f_fill_row(dash, 6, "成交量比", str.tostring(vol_ratio, "#.##") + "x", c_ratio)
    f_fill_row(dash, 7, "VIX", str.tostring(vix_close, "#.##"), c_vix)
````
