# rango

- url: https://www.tradingview.com/script/7ueU03Rr/
- type: indicator
- pine_id: PUB;ea239e45bdc543edbabccb0fd0e645a1
- version: 1.0

## Description

发现了一套智能交易系统，发布做一个记录

## Source Code

````pine
//@version=6
indicator("肥猫智能交易系统", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//==================================================================================
// 📊 参数设置
//==================================================================================

// 🎯 核心功能开关
group_main = "🎯 核心功能"
enable_regression = input.bool(true, "线性回归通道", group=group_main)
enable_range_detection = input.bool(true, "范围检测器", group=group_main)
enable_sr_analysis = input.bool(true, "支撑阻力识别", group=group_main)
enable_signals = input.bool(true, "交易信号", group=group_main)

// 📈 线性回归通道设置
group_regression = "📈 线性回归通道"
src = input.source(close, "数据源", group=group_regression)
len_main = input.int(100, "主通道长度", minval=10, maxval=200, group=group_regression)
len_short = input.int(50, "短期通道长度", minval=10, maxval=100, group=group_regression)
len_long = input.int(200, "长期通道长度", minval=100, maxval=500, group=group_regression)
devlen = input.float(2.0, "标准差倍数", minval=0.1, step=0.1, group=group_regression)
extendit = input.bool(true, "延长线条", group=group_regression)
show_fibo_levels = input.bool(true, "显示斐波那契水平", group=group_regression)

// 📦 范围检测设置
group_range = "📦 范围检测"
range_length = input.int(50, "范围长度", minval=10, maxval=200, group=group_range)
base_mult = input.float(2.0, "基础宽度倍数", minval=0.5, maxval=5.0, step=0.1, group=group_range)
atr_length = input.int(200, "ATR周期", minval=20, maxval=500, group=group_range)
adaptive_mode = input.bool(true, "自适应参数", group=group_range)

// 🛡️ 信号过滤设置
group_filter = "🛡️ 信号过滤"
volume_confirm = input.bool(true, "成交量确认", group=group_filter)
volume_multiplier = input.float(1.5, "成交量倍数", minval=1.0, maxval=5.0, step=0.1, group=group_filter)
confirmation_bars = input.int(3, "确认K线数", minval=1, maxval=10, group=group_filter)
signal_cooldown = input.int(10, "信号冷却期", minval=3, maxval=50, group=group_filter)

// 🎯 支撑阻力设置
group_sr = "🎯 支撑阻力"
sr_lookback = input.int(100, "支撑阻力回看", minval=50, maxval=500, group=group_sr)
pivot_left = input.int(5, "摆动点左侧", minval=1, maxval=20, group=group_sr)
pivot_right = input.int(5, "摆动点右侧", minval=1, maxval=20, group=group_sr)

// 🎨 显示设置
group_display = "🎨 显示设置"
show_levels = input.bool(true, "显示关键位", group=group_display)
show_signals = input.bool(true, "显示信号", group=group_display)
show_dashboard = input.bool(true, "显示仪表盘", group=group_display)
show_debug = input.bool(false, "显示调试信息", group=group_display)
upcol = input.color(color.lime, "上涨颜色", group=group_display)
dncol = input.color(color.red, "下跌颜色", group=group_display)
widt = input.int(2, "线条宽度", minval=1, maxval=5, group=group_display)

//==================================================================================
// 🧮 数据结构
//==================================================================================

// 支撑阻力位矩阵
var matrix<float> mtx_levels = matrix.new<float>(0, 6)  // [价格, 强度, 类型, 时间框架, 确认数, 最后测试]
LEVEL_PRICE = 0, LEVEL_STRENGTH = 1, LEVEL_TYPE = 2, LEVEL_TF = 3, LEVEL_CONFIRMS = 4, LEVEL_LAST_TEST = 5

// 存储线条和其他元素的数组
var array<line> level_lines = array.new<line>()
var array<line> reg_lines = array.new<line>()

//==================================================================================
// 🔧 核心计算函数
//==================================================================================

// 线性回归通道计算（保持原版精髓）
get_channel(source, length) =>
    mid = math.sum(source, length) / length
    slope = ta.linreg(source, length, 0) - ta.linreg(source, length, 1)
    intercept = mid - slope * math.floor(length / 2) + ((1 - (length % 2)) / 2) * slope
    endy = intercept + slope * (length - 1)
    dev = 0.0
    for x = 0 to length - 1
        dev := dev + math.pow(source[x] - (slope * (length - x) + intercept), 2)
    dev := math.sqrt(dev / length)
    [intercept, endy, dev, slope]

// 加权移动平均计算（用于范围检测）
f_weighted_ma(source, length) =>
    sum_weighted = 0.0
    sum_weights = 0.0
    for i = 0 to length - 1
        if not na(source[i]) and not na(source[i+1]) and source[i+1] != 0
            delta = math.abs(source[i] - source[i+1])
            weight = delta / source[i+1]
            sum_weighted += source[i] * weight
            sum_weights += weight
    sum_weights != 0 ? sum_weighted / sum_weights : source

// 支撑阻力强度计算
f_sr_strength(price, lookback) =>
    touches = 0
    for i = 1 to lookback
        if math.abs(close[i] - price) / price < 0.005  // 0.5%容差
            touches += 1
    touches

// 添加关键位到矩阵
f_add_level(price, strength, level_type, timeframe_idx, confirms = 1) =>
    if barstate.islast and enable_sr_analysis
        // 检查是否已存在相似价位
        existing_idx = -1
        if matrix.rows(mtx_levels) > 0
            for i = 0 to matrix.rows(mtx_levels) - 1
                existing_price = matrix.get(mtx_levels, i, LEVEL_PRICE)
                if math.abs(existing_price - price) / price < 0.002  // 0.2%容差
                    existing_idx := i
                    break
        
        if existing_idx >= 0
            // 更新现有关键位
            old_strength = matrix.get(mtx_levels, existing_idx, LEVEL_STRENGTH)
            new_strength = math.max(old_strength, strength)
            matrix.set(mtx_levels, existing_idx, LEVEL_STRENGTH, new_strength)
            matrix.set(mtx_levels, existing_idx, LEVEL_CONFIRMS, confirms)
            matrix.set(mtx_levels, existing_idx, LEVEL_LAST_TEST, bar_index)
        else
            // 添加新关键位
            matrix.add_row(mtx_levels, matrix.rows(mtx_levels))
            row_idx = matrix.rows(mtx_levels) - 1
            matrix.set(mtx_levels, row_idx, LEVEL_PRICE, price)
            matrix.set(mtx_levels, row_idx, LEVEL_STRENGTH, strength)
            matrix.set(mtx_levels, row_idx, LEVEL_TYPE, level_type)
            matrix.set(mtx_levels, row_idx, LEVEL_TF, timeframe_idx)
            matrix.set(mtx_levels, row_idx, LEVEL_CONFIRMS, confirms)
            matrix.set(mtx_levels, row_idx, LEVEL_LAST_TEST, bar_index)

//==================================================================================
// 📈 线性回归通道计算
//==================================================================================

// 计算ATR值（提前声明供多处使用）
current_atr = ta.atr(atr_length)

// 计算三个周期的线性回归通道
[y1_main, y2_main, dev_main, slope_main] = get_channel(src, len_main)
[y1_short, y2_short, dev_short, slope_short] = get_channel(src, len_short)
[y1_long, y2_long, dev_long, slope_long] = get_channel(src, len_long)

// 主通道的上中下轨
upper_main = y2_main + dev_main * devlen
mid_main = y2_main
lower_main = y2_main - dev_main * devlen

// 短期通道的上中下轨
upper_short = y2_short + dev_short * devlen
mid_short = y2_short
lower_short = y2_short - dev_short * devlen

// 长期通道的上中下轨
upper_long = y2_long + dev_long * devlen
mid_long = y2_long
lower_long = y2_long - dev_long * devlen

// 计算到各关键位的距离百分比
pct_to_upper_short = ((upper_short - close) / close) * 100
pct_to_mid_short = ((mid_short - close) / close) * 100
pct_to_lower_short = ((lower_short - close) / close) * 100
pct_to_upper_long = ((upper_long - close) / close) * 100
pct_to_mid_long = ((mid_long - close) / close) * 100
pct_to_lower_long = ((lower_long - close) / close) * 100

// 趋势判断
trend_text = slope_main > 0 ? slope_main > slope_main[1] ? "强势上涨" : "上涨" : slope_main < 0 ? slope_main < slope_main[1] ? "强势下跌" : "下跌" : "震荡行情"
trend_style = slope_main > 0 ? slope_main > slope_main[1] ? label.style_label_up : label.style_label_upper_right : slope_main < 0 ? slope_main < slope_main[1] ? label.style_label_down : label.style_label_lower_right : label.style_label_right
trend_color = slope_main > 0 ? upcol : slope_main < 0 ? dncol : color.blue

// 通道突破检测
outofchannel = (slope_main > 0 and close < lower_main) ? 0 : (slope_main < 0 and close > upper_main) ? 2 : -1
channel_broken = outofchannel != -1

//==================================================================================
// 📦 范围检测算法
//==================================================================================

var bool in_range = false
var float range_top = na
var float range_bottom = na
var int range_start = na
var box range_box = na

if enable_range_detection
    // 计算加权MA和自适应ATR
    weighted_ma = f_weighted_ma(close, range_length)
    
    // 自适应波动性调整
    recent_volatility = ta.stdev(ta.change(close), 100)
    avg_volatility = ta.sma(recent_volatility, 100)
    volatility_ratio = avg_volatility != 0 ? recent_volatility / avg_volatility : 1.0
    adaptive_multiplier = adaptive_mode ? base_mult * math.max(0.5, math.min(2.0, volatility_ratio)) : base_mult
    atr_value = current_atr * adaptive_multiplier
    
    // 范围检测逻辑
    max_dist = 0.0
    for i = 0 to range_length - 1
        if not na(close[i]) and not na(weighted_ma)
            dist = math.abs(close[i] - weighted_ma)
            if dist > max_dist
                max_dist := dist
    
    current_in_range = max_dist <= atr_value and not na(atr_value) and atr_value > 0 and bar_index >= range_length
    
    // 范围状态变化
    if current_in_range and not current_in_range[1]
        in_range := true
        range_top := weighted_ma + atr_value
        range_bottom := weighted_ma - atr_value
        range_start := bar_index - range_length
        
        // 创建范围框
        if not na(range_box)
            box.delete(range_box)
        range_box := box.new(range_start, range_top, bar_index + 10, range_bottom, border_color=color.new(color.blue, 0), bgcolor=color.new(color.blue, 85), border_width=2, border_style=line.style_dashed)
        
        // 添加范围边界到支撑阻力矩阵
        f_add_level(range_top, 3, 1, 0, 3)      // 范围上沿
        f_add_level(range_bottom, 3, 2, 0, 3)   // 范围下沿
    
    if current_in_range and in_range and not na(range_box)
        // 扩展范围框
        box.set_right(range_box, bar_index + 10)
    
    if not current_in_range and current_in_range[1]
        in_range := false

//==================================================================================
// 🎯 支撑阻力位识别
//==================================================================================

// 识别摆动高低点
pivot_high = ta.pivothigh(high, pivot_left, pivot_right)
pivot_low = ta.pivotlow(low, pivot_left, pivot_right)

// 添加摆动点到矩阵
if not na(pivot_high) and enable_sr_analysis
    strength = f_sr_strength(pivot_high, sr_lookback)
    f_add_level(pivot_high, math.max(1, strength), 1, 0)

if not na(pivot_low) and enable_sr_analysis
    strength = f_sr_strength(pivot_low, sr_lookback)
    f_add_level(pivot_low, math.max(1, strength), 2, 0)

// 添加线性回归通道轨道作为关键位
if enable_regression and enable_sr_analysis
    f_add_level(upper_main, 2, 1, 0)  // 主通道上轨
    f_add_level(lower_main, 2, 2, 0)  // 主通道下轨
    f_add_level(upper_short, 1, 1, 1) // 短期通道上轨
    f_add_level(lower_short, 1, 2, 1) // 短期通道下轨
    
    // 斐波那契回调水平
    if show_fibo_levels
        channel_range = upper_main - lower_main
        fib_236 = lower_main + channel_range * 0.236
        fib_382 = lower_main + channel_range * 0.382
        fib_618 = lower_main + channel_range * 0.618
        fib_786 = lower_main + channel_range * 0.786
        
        f_add_level(fib_236, 1, 3, 0)
        f_add_level(fib_382, 1, 3, 0)
        f_add_level(fib_618, 2, 3, 0)
        f_add_level(fib_786, 1, 3, 0)

//==================================================================================
// 📊 信号生成系统
//==================================================================================

var bool bull_signal = false
var bool bear_signal = false
var bool pullback_buy = false
var bool pullback_sell = false
var int last_signal_bar = 0

// 成交量确认
avg_volume = ta.sma(volume, 50)
volume_ratio = avg_volume > 0 ? volume / avg_volume : 1.0
significant_volume = volume_ratio >= volume_multiplier

// 信号冷却检查
cooldown_ok = bar_index - last_signal_bar >= signal_cooldown

// 线性回归通道突破信号
reg_break_up = close > upper_main and close[1] <= upper_main
reg_break_down = close < lower_main and close[1] >= lower_main

// 范围突破信号
range_break_up = in_range and not na(range_top) and close > range_top and close[1] <= range_top
range_break_down = in_range and not na(range_bottom) and close < range_bottom and close[1] >= range_bottom

// 支撑阻力突破信号
sr_break_up = false
sr_break_down = false

if matrix.rows(mtx_levels) > 0 and enable_signals
    for i = 0 to matrix.rows(mtx_levels) - 1
        if i < matrix.rows(mtx_levels)
            level_price = matrix.get(mtx_levels, i, LEVEL_PRICE)
            level_strength = matrix.get(mtx_levels, i, LEVEL_STRENGTH)
            level_type = matrix.get(mtx_levels, i, LEVEL_TYPE)
            
            // 向上突破阻力
            if level_type == 1 and close > level_price and close[1] <= level_price and level_strength >= 2
                sr_break_up := true
            
            // 向下突破支撑
            if level_type == 2 and close < level_price and close[1] >= level_price and level_strength >= 2
                sr_break_down := true

// 综合信号判断
signal_up = (reg_break_up or range_break_up or sr_break_up) and cooldown_ok
signal_down = (reg_break_down or range_break_down or sr_break_down) and cooldown_ok

// 成交量过滤
if signal_up and (not volume_confirm or significant_volume)
    bull_signal := true
    last_signal_bar := bar_index

if signal_down and (not volume_confirm or significant_volume)
    bear_signal := true
    last_signal_bar := bar_index

// 回踩信号
if bull_signal and close <= mid_main and close > lower_main
    pullback_buy := true

if bear_signal and close >= mid_main and close < upper_main
    pullback_sell := true

// 重置信号
if not in_range and bull_signal and (close <= lower_main or close >= upper_main * 1.05)
    bull_signal := false
    pullback_buy := false

if not in_range and bear_signal and (close >= upper_main or close <= lower_main * 0.95)
    bear_signal := false
    pullback_sell := false

//==================================================================================
// 🎨 可视化绘制
//==================================================================================

// 清理旧的线条
if array.size(reg_lines) > 0
    for i = 0 to array.size(reg_lines) - 1
        line.delete(array.get(reg_lines, i))
    array.clear(reg_lines)

// 绘制线性回归通道（保持原版角度）
if enable_regression
    // 主通道线条（带角度）
    start_bar = bar_index - (len_main - 1)
    
    // 确定颜色
    trend_up = slope_main >= 0
    line_color = trend_up ? upcol : dncol
    
    // 上轨（实线）
    upper_line = line.new(start_bar, y1_main + dev_main * devlen, bar_index, upper_main, color=line_color, style=line.style_solid, width=widt, extend=extendit ? extend.right : extend.none)
    array.push(reg_lines, upper_line)
    
    // 中轨（虚线）
    mid_line = line.new(start_bar, y1_main, bar_index, mid_main, color=line_color, style=line.style_dashed, width=widt, extend=extendit ? extend.right : extend.none)
    array.push(reg_lines, mid_line)
    
    // 下轨（实线）
    lower_line = line.new(start_bar, y1_main - dev_main * devlen, bar_index, lower_main, color=line_color, style=line.style_solid, width=widt, extend=extendit ? extend.right : extend.none)
    array.push(reg_lines, lower_line)
    
    // 斐波那契水平线
    if show_fibo_levels
        channel_range = (y1_main + dev_main * devlen) - (y1_main - dev_main * devlen)
        
        // 0.236水平
        fibo_y1_236 = y1_main - dev_main * devlen + channel_range * 0.236
        fibo_y2_236 = y2_main - dev_main * devlen + channel_range * 0.236
        fibo_line_236 = line.new(start_bar, fibo_y1_236, bar_index, fibo_y2_236, color=line_color, style=line.style_dotted, width=1, extend=extendit ? extend.right : extend.none)
        array.push(reg_lines, fibo_line_236)
        
        // 0.382水平
        fibo_y1_382 = y1_main - dev_main * devlen + channel_range * 0.382
        fibo_y2_382 = y2_main - dev_main * devlen + channel_range * 0.382
        fibo_line_382 = line.new(start_bar, fibo_y1_382, bar_index, fibo_y2_382, color=line_color, style=line.style_dotted, width=1, extend=extendit ? extend.right : extend.none)
        array.push(reg_lines, fibo_line_382)
        
        // 0.618水平
        fibo_y1_618 = y1_main - dev_main * devlen + channel_range * 0.618
        fibo_y2_618 = y2_main - dev_main * devlen + channel_range * 0.618
        fibo_line_618 = line.new(start_bar, fibo_y1_618, bar_index, fibo_y2_618, color=line_color, style=line.style_dotted, width=1, extend=extendit ? extend.right : extend.none)
        array.push(reg_lines, fibo_line_618)
        
        // 0.786水平
        fibo_y1_786 = y1_main - dev_main * devlen + channel_range * 0.786
        fibo_y2_786 = y2_main - dev_main * devlen + channel_range * 0.786
        fibo_line_786 = line.new(start_bar, fibo_y1_786, bar_index, fibo_y2_786, color=line_color, style=line.style_dotted, width=1, extend=extendit ? extend.right : extend.none)
        array.push(reg_lines, fibo_line_786)

// 趋势标签
var label trend_label = na
if enable_regression
    if not na(trend_label)
        label.delete(trend_label)
    
    label_y = slope_main > 0 ? y1_main - dev_main * devlen : slope_main < 0 ? y1_main + dev_main * devlen : y1_main
    trend_label := label.new(bar_index - (len_main - 1), label_y, trend_text, style=trend_style, color=trend_color, textcolor=color.white, size=size.normal)

// 绘制支撑阻力位线条
if show_levels and matrix.rows(mtx_levels) > 0 and barstate.islast
    // 清理旧线条
    if array.size(level_lines) > 0
        for i = 0 to array.size(level_lines) - 1
            line.delete(array.get(level_lines, i))
        array.clear(level_lines)
    
    // 绘制关键位（选择最重要的）
    max_levels = math.min(matrix.rows(mtx_levels), 15)
    for i = 0 to max_levels - 1
        level_price = matrix.get(mtx_levels, i, LEVEL_PRICE)
        level_strength = matrix.get(mtx_levels, i, LEVEL_STRENGTH)
        level_type = matrix.get(mtx_levels, i, LEVEL_TYPE)
        
        if level_strength >= 1
            line_color = level_type == 1 ? color.new(color.red, 40) : level_type == 2 ? color.new(color.green, 40) : color.new(color.orange, 40)
            line_style = level_type == 3 ? line.style_dotted : line.style_solid
            line_width = math.max(1, math.min(3, int(level_strength)))
            
            level_line = line.new(bar_index - 50, level_price, bar_index + 20, level_price, color=line_color, width=line_width, style=line_style, extend=extend.right)
            array.push(level_lines, level_line)
            
            // 添加标签
            if level_strength >= 2 and i < 8  // 只为最强的8个关键位添加标签
                label_text = ""
                if level_type == 1  // 阻力位
                    if level_strength >= 3
                        label_text := "强阻力" + str.tostring(int(level_strength))
                    else
                        label_text := "阻力" + str.tostring(int(level_strength))
                else if level_type == 2  // 支撑位
                    if level_strength >= 3
                        label_text := "强支撑" + str.tostring(int(level_strength))
                    else
                        label_text := "支撑" + str.tostring(int(level_strength))
                else if level_type == 3  // 斐波那契水平
                    if level_strength >= 2
                        label_text := "黄金分割" + str.tostring(int(level_strength))
                    else
                        label_text := "斐波" + str.tostring(int(level_strength))
                
                label_style = level_type == 1 ? label.style_label_down : label.style_label_up
                label.new(bar_index + 5, level_price, label_text, style=label_style, color=line_color, textcolor=color.white, size=size.small)

// 范围框颜色管理
if not na(range_box) and enable_range_detection
    box_color = color.new(color.blue, 85)
    border_color = color.new(color.blue, 0)
    
    // 突破变色
    if range_break_up
        box_color := color.new(color.green, 70)
        border_color := color.new(color.green, 0)
    else if range_break_down
        box_color := color.new(color.red, 70)
        border_color := color.new(color.red, 0)
    
    box.set_bgcolor(range_box, box_color)
    box.set_border_color(range_box, border_color)

//==================================================================================
// 📊 信号显示
//==================================================================================

// 主要突破信号
plotshape(show_signals and bull_signal and not bull_signal[1], "多头信号", shape.triangleup, location.belowbar, color.new(color.green, 0), size=size.normal, text="多")
plotshape(show_signals and bear_signal and not bear_signal[1], "空头信号", shape.triangledown, location.abovebar, color.new(color.red, 0), size=size.normal, text="空")

// 回踩信号
plotshape(show_signals and pullback_buy and not pullback_buy[1], "回踩买入", shape.circle, location.belowbar, color.new(color.lime, 0), size=size.small, text="回踩")
plotshape(show_signals and pullback_sell and not pullback_sell[1], "回踩卖出", shape.circle, location.abovebar, color.new(color.orange, 0), size=size.small, text="回踩")

// 背景颜色
bgcolor(in_range ? color.new(color.blue, 98) : na, title="范围状态")

//==================================================================================
// 📊 智能仪表盘
//==================================================================================

if show_dashboard
    var table dashboard = table.new(position.top_right, 3, 16, bgcolor=color.new(color.black, 20), border_width=1)
    
    if barstate.islast
        // 标题行
        table.cell(dashboard, 0, 0, "🤖 智能交易系统", text_color=color.white, bgcolor=color.blue, text_size=size.normal)
        table.cell(dashboard, 1, 0, "数值", text_color=color.white, bgcolor=color.blue)
        table.cell(dashboard, 2, 0, "距离%", text_color=color.white, bgcolor=color.blue)
        
        // 短期通道数据
        table.cell(dashboard, 0, 1, "📈 " + str.tostring(len_short) + "期上轨", text_color=color.white)
        table.cell(dashboard, 1, 1, str.tostring(upper_short, "#.####"), text_color=color.red)
        table.cell(dashboard, 2, 1, str.tostring(pct_to_upper_short, "#.##") + "%", text_color=color.red)
        
        table.cell(dashboard, 0, 2, "📊 " + str.tostring(len_short) + "期中轨", text_color=color.white)
        table.cell(dashboard, 1, 2, str.tostring(mid_short, "#.####"), text_color=color.yellow)
        table.cell(dashboard, 2, 2, str.tostring(pct_to_mid_short, "#.##") + "%", text_color=color.yellow)
        
        table.cell(dashboard, 0, 3, "📉 " + str.tostring(len_short) + "期下轨", text_color=color.white)
        table.cell(dashboard, 1, 3, str.tostring(lower_short, "#.####"), text_color=color.green)
        table.cell(dashboard, 2, 3, str.tostring(pct_to_lower_short, "#.##") + "%", text_color=color.green)
        
        // 长期通道数据
        table.cell(dashboard, 0, 4, "📈 " + str.tostring(len_long) + "期上轨", text_color=color.white)
        table.cell(dashboard, 1, 4, str.tostring(upper_long, "#.####"), text_color=color.red)
        table.cell(dashboard, 2, 4, str.tostring(pct_to_upper_long, "#.##") + "%", text_color=color.red)
        
        table.cell(dashboard, 0, 5, "📊 " + str.tostring(len_long) + "期中轨", text_color=color.white)
        table.cell(dashboard, 1, 5, str.tostring(mid_long, "#.####"), text_color=color.yellow)
        table.cell(dashboard, 2, 5, str.tostring(pct_to_mid_long, "#.##") + "%", text_color=color.yellow)
        
        table.cell(dashboard, 0, 6, "📉 " + str.tostring(len_long) + "期下轨", text_color=color.white)
        table.cell(dashboard, 1, 6, str.tostring(lower_long, "#.####"), text_color=color.green)
        table.cell(dashboard, 2, 6, str.tostring(pct_to_lower_long, "#.##") + "%", text_color=color.green)
        
        // 分隔线
        table.cell(dashboard, 0, 7, "━━━━━━━━━━━━━━━━", text_color=color.gray)
        table.cell(dashboard, 1, 7, "━━━━━━━━━━", text_color=color.gray)
        table.cell(dashboard, 2, 7, "━━━━━━━━", text_color=color.gray)
        
        // 趋势分析
        table.cell(dashboard, 0, 8, "🎯 主趋势", text_color=color.white)
        table.cell(dashboard, 1, 8, trend_text, text_color=trend_color)
        table.cell(dashboard, 2, 8, str.tostring(slope_main * 1000, "#.#"), text_color=trend_color)
        
        // 范围状态
        range_status = in_range ? "📦 范围内" : "🔄 趋势中"
        range_color = in_range ? color.blue : color.gray
        table.cell(dashboard, 0, 9, "📦 范围检测", text_color=color.white)
        table.cell(dashboard, 1, 9, range_status, text_color=range_color)
        table.cell(dashboard, 2, 9, in_range ? "✅" : "❌", text_color=range_color)
        
        // 支撑阻力统计
        support_count = 0
        resistance_count = 0
        if matrix.rows(mtx_levels) > 0
            for i = 0 to matrix.rows(mtx_levels) - 1
                if i < matrix.rows(mtx_levels)
                    level_type = matrix.get(mtx_levels, i, LEVEL_TYPE)
                    if level_type == 1
                        resistance_count += 1
                    else if level_type == 2
                        support_count += 1
        
        table.cell(dashboard, 0, 10, "🟢 支撑位", text_color=color.white)
        table.cell(dashboard, 1, 10, str.tostring(support_count), text_color=color.green)
        table.cell(dashboard, 2, 10, support_count >= 3 ? "强" : "弱", text_color=color.white)
        
        table.cell(dashboard, 0, 11, "🔴 阻力位", text_color=color.white)
        table.cell(dashboard, 1, 11, str.tostring(resistance_count), text_color=color.red)
        table.cell(dashboard, 2, 11, resistance_count >= 3 ? "强" : "弱", text_color=color.white)
        
        // 信号状态
        signal_status = bull_signal ? "📈 多头" : bear_signal ? "📉 空头" : "⏳ 等待"
        signal_color = bull_signal ? color.green : bear_signal ? color.red : color.gray
        table.cell(dashboard, 0, 12, "🎯 当前信号", text_color=color.white)
        table.cell(dashboard, 1, 12, signal_status, text_color=signal_color)
        table.cell(dashboard, 2, 12, cooldown_ok ? "✅" : "❄️", text_color=color.white)
        
        // 成交量状态
        volume_status = significant_volume ? "🔊 放量" : "🔇 缩量"
        volume_color = significant_volume ? color.green : color.gray
        table.cell(dashboard, 0, 13, "📊 成交量", text_color=color.white)
        table.cell(dashboard, 1, 13, str.tostring(volume_ratio, "#.#") + "x", text_color=volume_color)
        table.cell(dashboard, 2, 13, volume_status, text_color=volume_color)
        
        // 通道突破状态
        channel_status = outofchannel == 0 ? "📉 跌破通道" : outofchannel == 2 ? "📈 突破通道" : "📊 通道内"
        channel_color = outofchannel == 0 ? color.red : outofchannel == 2 ? color.green : color.blue
        table.cell(dashboard, 0, 14, "📊 通道状态", text_color=color.white)
        table.cell(dashboard, 1, 14, channel_status, text_color=channel_color)
        table.cell(dashboard, 2, 14, outofchannel != -1 ? "⚠️" : "✅", text_color=color.white)
        
        // 当前价格
        table.cell(dashboard, 0, 15, "💰 当前价格", text_color=color.white)
        table.cell(dashboard, 1, 15, str.tostring(close, "#.####"), text_color=color.white)
        table.cell(dashboard, 2, 15, "📍", text_color=color.white)

// 调试信息面板
if show_debug
    var table debug_table = table.new(position.bottom_left, 2, 8, bgcolor=color.new(color.black, 20), border_width=1)
    if barstate.islast
        table.cell(debug_table, 0, 0, "🔍 调试信息", text_color=color.white, bgcolor=color.purple)
        table.cell(debug_table, 1, 0, "数值", text_color=color.white, bgcolor=color.purple)
        
        table.cell(debug_table, 0, 1, "关键位数量", text_color=color.white)
        table.cell(debug_table, 1, 1, str.tostring(matrix.rows(mtx_levels)), text_color=color.yellow)
        
        table.cell(debug_table, 0, 2, "主通道斜率", text_color=color.white)
        table.cell(debug_table, 1, 2, str.tostring(slope_main * 1000, "#.##"), text_color=color.yellow)
        
        table.cell(debug_table, 0, 3, "ATR值", text_color=color.white)
        table.cell(debug_table, 1, 3, str.tostring(current_atr, "#.##"), text_color=color.yellow)
        
        table.cell(debug_table, 0, 4, "范围状态", text_color=color.white)
        table.cell(debug_table, 1, 4, in_range ? "范围内" : "趋势中", text_color=in_range ? color.blue : color.gray)
        
        table.cell(debug_table, 0, 5, "信号冷却", text_color=color.white)
        table.cell(debug_table, 1, 5, str.tostring(bar_index - last_signal_bar), text_color=color.yellow)
        
        table.cell(debug_table, 0, 6, "成交量比率", text_color=color.white)
        table.cell(debug_table, 1, 6, str.tostring(volume_ratio, "#.##"), text_color=color.yellow)
        
        table.cell(debug_table, 0, 7, "当前K线", text_color=color.white)
        table.cell(debug_table, 1, 7, str.tostring(bar_index), text_color=color.yellow)

//==================================================================================
// 📢 警报设置
//==================================================================================

// 突破警报
alertcondition(bull_signal and not bull_signal[1], "多头突破", "价格突破关键阻力，可关注做多机会")
alertcondition(bear_signal and not bear_signal[1], "空头突破", "价格跌破关键支撑，可关注做空机会")

// 回踩警报
alertcondition(pullback_buy and not pullback_buy[1], "回踩买入机会", "多头突破后回踩，可关注加仓机会")
alertcondition(pullback_sell and not pullback_sell[1], "回踩卖出机会", "空头突破后回踩，可关注加仓机会")

// 范围突破警报
alertcondition(range_break_up, "突破范围上沿", "价格突破横盘整理上沿")
alertcondition(range_break_down, "跌破范围下沿", "价格跌破横盘整理下沿")

// 通道突破警报
alertcondition(channel_broken, "通道突破", "价格突破线性回归通道")

// 关键位触及警报
alertcondition(not na(pivot_high), "发现新阻力位", "识别到新的摆动高点")
alertcondition(not na(pivot_low), "发现新支撑位", "识别到新的摆动低点")

//==================================================================================
// 📈 价格线绘制
//==================================================================================

// 当前价格线
plot(close, "当前价格", color.new(color.white, 0), linewidth=1)

// 市场状态背景
trend_bg = slope_main > 0.001 ? color.new(color.green, 98) : slope_main < -0.001 ? color.new(color.red, 98) : na
bgcolor(trend_bg, title="趋势背景")
````
