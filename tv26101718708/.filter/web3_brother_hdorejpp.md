# Web3 Brother

- url: https://www.tradingview.com/script/HdOreJpp/
- type: indicator
- pine_id: PUB;f1c69064d1504e7683bfead9601ebe21
- version: 1.0

## Description

Double moving average dense break, code for Web3 Brother, go go go!

## Source Code

````pine
//@version=5
indicator("双均线密集V10", overlay=true)

// ==========================================
// 1. 参数设置
// ==========================================

// --- A. 均线周期 ---
grp_ma = "1. 均线周期设置"
show_ma = input.bool(true, "显示均线", group=grp_ma)
len1 = input.int(20, "周期 1 (20)", group=grp_ma)
len2 = input.int(60, "周期 2 (60)", group=grp_ma)
len3 = input.int(120, "周期 3 (120)", group=grp_ma)

// --- B. 均线密集设置 ---
grp_sqz = "2. 均线密集阈值"
thresh_20 = input.float(0.2, "20组 内部紧密度 (%)", step=0.1, group=grp_sqz)
thresh_60 = input.float(0.3, "60组 距离 20组 (%)", step=0.1, group=grp_sqz)
thresh_120 = input.float(0.5, "120组 距离 20组 (%)", step=0.1, group=grp_sqz)

// --- C. 监控与报警 ---
grp_alert = "3. 监控与报警条件"
monitor_bars = input.int(24, "密集后监控K线数量", minval=1, group=grp_alert)
vol_lookback = input.int(20, "对比过去N根成交量", minval=1, group=grp_alert)
vol_mult = input.float(2.0, "成交量放大倍数 (x)", step=0.1, group=grp_alert)
vol_min = input.int(5000, "最小绝对成交量", group=grp_alert)

// --- D. 止损设置 (核心修改) ---
grp_sl = "4. 止损设置"
// 增加下拉菜单选择模式
sl_mode = input.string("K线极值+ATR", "止损模式选择", options=["结构性+ATR", "K线极值+ATR", "趋势线(MA120)"], group=grp_sl, tooltip="结构性: 均线带边缘\nK线极值: 信号K线高低点\n趋势线: MA120均线")
sl_atr_len = input.int(14, "ATR 周期", group=grp_sl)
sl_atr_mult = input.float(0.2, "止损缓冲 (ATR倍数)", step=0.1, group=grp_sl, tooltip="在硬止损位基础上增加多少缓冲空间？设为0则为硬止损。")

// --- E. 信号过滤 ---
grp_filter = "5. 信号过滤"
ignore_bars = input.int(2, "忽略后续同向信号", minval=1, group=grp_filter)
body_wick_ratio = input.float(1.2, "实体/影线倍数", minval=0.5, step=0.1, group=grp_filter)
col_sqz_bg = input.color(color.new(color.yellow, 60), "密集背景色", group=grp_filter)

// ==========================================
// 2. 计算核心指标
// ==========================================
ema20 = ta.ema(close, len1), ma20 = ta.sma(close, len1)
ema60 = ta.ema(close, len2), ma60 = ta.sma(close, len2)
ema120 = ta.ema(close, len3), ma120 = ta.sma(close, len3)

// ATR
atr_val = ta.atr(sl_atr_len)
// 计算缓冲距离
sl_buffer = atr_val * sl_atr_mult

// 密集度
center_20 = (ema20 + ma20) / 2
center_60 = (ema60 + ma60) / 2
center_120 = (ema120 + ma120) / 2

diff_20_pct = (math.abs(ema20 - ma20) / nz(center_20, close)) * 100
dist_60_pct = (math.abs(center_60 - center_20) / nz(center_20, close)) * 100
dist_120_pct = (math.abs(center_120 - center_20) / nz(center_20, close)) * 100

is_squeeze = (diff_20_pct <= thresh_20) and (dist_60_pct <= thresh_60) and (dist_120_pct <= thresh_120)

// ==========================================
// 3. 状态监控逻辑
// ==========================================
var int last_sqz_index = -9999

if is_squeeze
    last_sqz_index := bar_index

bars_since_squeeze = bar_index - last_sqz_index
is_in_window = (last_sqz_index != -9999) and (bars_since_squeeze <= monitor_bars)

// ==========================================
// 4. 信号触发逻辑
// ==========================================
vol_avg_prev = ta.sma(volume[1], vol_lookback)
is_vol_spike = (volume >= (vol_avg_prev * vol_mult)) and (volume >= vol_min)

ribbon_high = math.max(ema20, ma20, ema60, ma60, ema120, ma120)
ribbon_low  = math.min(ema20, ma20, ema60, ma60, ema120, ma120)

body_size = math.abs(close - open)
upper_shadow = high - math.max(close, open) 
lower_shadow = math.min(close, open) - low  
is_strong_bull = body_size >= (upper_shadow * body_wick_ratio)
is_strong_bear = body_size >= (lower_shadow * body_wick_ratio)

raw_trigger = is_in_window and is_vol_spike
raw_long = raw_trigger and (close > ribbon_high) and (close > open) and is_strong_bull
raw_short = raw_trigger and (close < ribbon_low) and (close < open) and is_strong_bear

// ==========================================
// 5. 信号去重 & 多模式止损计算
// ==========================================
var int last_long_idx = -9999
var int last_short_idx = -9999

bool final_long = false
bool final_short = false
float plot_sl_price = na

// 封装止损计算逻辑
// 模式1: 结构性 (Ribbon)
// 模式2: 极值 (K线 High/Low)
// 模式3: 趋势线 (MA120)
calc_long_sl() =>
    base_sl = 0.0
    if sl_mode == "结构性+ATR"
        base_sl := ribbon_low
    else if sl_mode == "K线极值+ATR"
        base_sl := low
    else if sl_mode == "趋势线(MA120)"
        base_sl := ma120
    base_sl - sl_buffer

calc_short_sl() =>
    base_sl = 0.0
    if sl_mode == "结构性+ATR"
        base_sl := ribbon_high
    else if sl_mode == "K线极值+ATR"
        base_sl := high
    else if sl_mode == "趋势线(MA120)"
        base_sl := ma120
    base_sl + sl_buffer

if raw_long
    if (bar_index - last_long_idx) > ignore_bars
        final_long := true
        last_long_idx := bar_index
        plot_sl_price := calc_long_sl()

if raw_short
    if (bar_index - last_short_idx) > ignore_bars
        final_short := true
        last_short_idx := bar_index
        plot_sl_price := calc_short_sl()

// ==========================================
// 6. 绘图
// ==========================================
plot(show_ma ? ema20 : na, color=color.new(color.orange, 0), title="EMA 20", linewidth=1)
plot(show_ma ? ma20 : na, color=color.new(color.blue, 0), title="MA 20", linewidth=1)
plot(show_ma ? ema60 : na, color=color.new(color.orange, 30), title="EMA 60")
plot(show_ma ? ma60 : na, color=color.new(color.blue, 30), title="MA 60")
plot(show_ma ? ema120 : na, color=color.new(color.orange, 60), title="EMA 120")
plot(show_ma ? ma120 : na, color=color.new(color.blue, 60), title="MA 120")

bgcolor(is_squeeze ? col_sqz_bg : na, title="密集背景")

// 信号箭头 (N+1 位置)
plotshape(final_long, title="做多入场点", style=shape.labelup, location=location.belowbar, color=color.green, text="多", textcolor=color.white, size=size.small, offset=1)
plotshape(final_short, title="做空入场点", style=shape.labeldown, location=location.abovebar, color=color.red, text="空", textcolor=color.white, size=size.small, offset=1)

// 止损位 (N+1 位置)
plot(final_long ? plot_sl_price : na, title="多单止损位", color=color.blue, style=plot.style_cross, linewidth=2, offset=1)
plot(final_short ? plot_sl_price : na, title="空单止损位", color=color.blue, style=plot.style_cross, linewidth=2, offset=1)

alertcondition(final_long or final_short, title="蓄势突破", message="均线密集后突破信号触发！")
````
