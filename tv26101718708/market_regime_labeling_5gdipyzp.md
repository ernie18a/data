# Market Regime Labeling

- url: https://www.tradingview.com/script/5GDIPyZP/
- type: indicator
- pine_id: PUB;64bd96bb39e54cfcbe8b64a61f4a5aad
- version: 1.0

## Description

一个手动标记市场状态加ATR计算止损的简单指标.

## Source Code

````pine
// =====================================================
// 市场状态标记指标 v1.7
// 手动勾选市场状态 + ATR止损计算，显示在图表上
//
// v1.7 修正：
// - 回退到 table 方式实现9宫格定位（准确可靠）
// - Y偏移：通过面板上方/下方插入空行实现
// - X偏移：通过文本左缩进实现
// - 默认位置 = 右上角（与设置一致）
// - 极速在买卖前面，买卖始终最后
//
// 用法：
// 1. 添加到图表
// 2. 打开指标设置（齿轮图标）
// 3. 勾选当前市场状态
// 4. 勾选需要显示的ATR止损信息
// 5. 调节 Position 组微调位置
// =====================================================
//@version=6
indicator("市场状态标记 v1.7", overlay=true)

// ============================================================================
// INPUTS - 市场状态勾选
// ============================================================================
group_status = "Market Status"

s_range = input.bool(false, "交易区间", group=group_status, inline="s1")
s_narrow = input.bool(false, "窄幅交易区间", group=group_status, inline="s1")
s_uptrend = input.bool(false, "向上趋势", group=group_status, inline="s2")
s_upchannel = input.bool(false, "向上通道", group=group_status, inline="s2")
s_downtrend = input.bool(false, "向下趋势", group=group_status, inline="s3")
s_downchannel = input.bool(false, "向下通道", group=group_status, inline="s3")
s_converge = input.bool(false, "收敛三角", group=group_status, inline="s4")
s_diverge = input.bool(false, "扩张三角", group=group_status, inline="s4")
s_speed = input.bool(false, "极速", group=group_status, inline="s5")
s_buy = input.bool(false, "买", group=group_status, inline="s6")
s_sell = input.bool(false, "卖", group=group_status, inline="s6")

// ============================================================================
// INPUTS - ATR止损设置
// ============================================================================
group_atr = "ATR Stop Loss"

atr_len = input.int(14, "ATR周期", minval=1, group=group_atr)
show_atr_val = input.bool(false, "显示ATR值", group=group_atr)
show_stop_high = input.bool(false, "显示空止损（最高+ATR倍数）", group=group_atr)
show_stop_low = input.bool(false, "显示多止损（最低-ATR倍数）", group=group_atr)

// ============================================================================
// 样式设置
// ============================================================================
group_style = "Style"

bg_color = input.color(color.new(color.black, 80), "Panel BG", group=group_style)
txt_color = input.color(color.white, "Text Color", group=group_style)
font_size = input.string("normal", "Font Size", options=["tiny", "small", "normal", "large"], group=group_style)

// ============================================================================
// 面板位置调节
// ============================================================================
group_pos = "Position"

pos_x = input.string("right", "Horizontal Position", options=["left", "center", "right"], group=group_pos)
pos_y = input.string("top", "Vertical Position", options=["top", "middle", "bottom"], group=group_pos)
offset_y = input.int(0, "Y Offset (行数,正=下移,负=上移)", minval=-10, maxval=10, group=group_pos)

// ============================================================================
// 字体大小映射
// ============================================================================
mapSize(string s) =>
    if s == "tiny"
        size.tiny
    else if s == "small"
        size.small
    else if s == "normal"
        size.normal
    else
        size.large

// ============================================================================
// 位置映射（table 9宫格）
// ============================================================================
getTablePos() =>
    if pos_y == "top"
        if pos_x == "left"
            position.top_left
        else if pos_x == "center"
            position.top_center
        else
            position.top_right
    else if pos_y == "middle"
        if pos_x == "left"
            position.middle_left
        else if pos_x == "center"
            position.middle_center
        else
            position.middle_right
    else
        if pos_x == "left"
            position.bottom_left
        else if pos_x == "center"
            position.bottom_center
        else
            position.bottom_right

// ============================================================================
// ATR止损计算
// ============================================================================
atr_val = ta.atr(atr_len)
bar_h = high - low
atr_mult = bar_h < atr_val ? 1.0 : bar_h < atr_val * 2 ? 1.5 : 2.0
stop_long = low - atr_val * atr_mult
stop_short = high + atr_val * atr_mult

// ============================================================================
// 收集被勾选的状态（极速在买卖前面）
// ============================================================================
buildStatus() =>
    result = ""
    count = 0
    
    if s_range
        result += "交易区间"
        count += 1
    if s_narrow
        result += (count > 0 ? "\n───\n" : "") + "窄幅交易区间"
        count += 1
    if s_uptrend
        result += (count > 0 ? "\n───\n" : "") + "向上趋势"
        count += 1
    if s_upchannel
        result += (count > 0 ? "\n───\n" : "") + "向上通道"
        count += 1
    if s_downtrend
        result += (count > 0 ? "\n───\n" : "") + "向下趋势"
        count += 1
    if s_downchannel
        result += (count > 0 ? "\n───\n" : "") + "向下通道"
        count += 1
    if s_converge
        result += (count > 0 ? "\n───\n" : "") + "收敛三角"
        count += 1
    if s_diverge
        result += (count > 0 ? "\n───\n" : "") + "扩张三角"
        count += 1
    if s_speed
        result += (count > 0 ? "\n───\n" : "") + "极速"
        count += 1
    if s_buy
        result += (count > 0 ? "\n───\n" : "") + "买"
        count += 1
    if s_sell
        result += (count > 0 ? "\n───\n" : "") + "卖"
        count += 1
    
    result := str.length(result) == 0 ? "(请勾选状态)" : result
    [result, count]

// ============================================================================
// 收集ATR止损信息
// ============================================================================
buildATR() =>
    result = ""
    hasATR = show_atr_val or show_stop_high or show_stop_low
    if hasATR
        if show_atr_val
            result += "ATR(" + str.tostring(atr_len) + "): " + str.tostring(atr_val, format.mintick)
        if show_stop_high
            mult_str = str.tostring(atr_mult, "#.#")
            result += (str.length(result) > 0 ? "\n" : "") + "空止损(H+" + mult_str + "ATR): " + str.tostring(stop_short, format.mintick)
        if show_stop_low
            mult_str = str.tostring(atr_mult, "#.#")
            result += (str.length(result) > 0 ? "\n" : "") + "多止损(L-" + mult_str + "ATR): " + str.tostring(stop_long, format.mintick)
    [result, hasATR]

// ============================================================================
// 生成Y偏移空行（正=在上面加空行→面板下移，负=在下面加空行→面板上移）
// ============================================================================
buildPadding(topLines) =>
    result = ""
    for i = 0 to topLines - 1
        result += "\n"
    result

// ============================================================================
// 显示面板（table 方式，9宫格 + Y偏移）
// ============================================================================
if barstate.islast
    [statusText, statusCount] = buildStatus()
    [atrText, hasATR] = buildATR()
    
    // 拼接内容
    content = statusText
    if hasATR
        content += "\n━━━━━━━━━\n" + atrText
    
    // 应用Y偏移：正值在前面加空行（把内容推下去）
    padding = ""
    if offset_y > 0
        padding := buildPadding(offset_y)
    else if offset_y < 0
        // 负值在后面加空行（不太常用，但支持）
        for i = 0 to math.abs(offset_y) - 1
            content += "\n"
    
    fullText = padding + content
    
    // 行数 = 状态行 + ATR行 + 分隔线 + 偏移行 + 余量
    rowCount = statusCount * 2 + (hasATR ? hasATR ? 4 : 0 : 0) + math.abs(offset_y) + 3
    
    var table panelTable = table.new(getTablePos(), 1, rowCount,
         bgcolor=bg_color,
         frame_color=color.gray,
         frame_width=1,
         border_width=1)
    
    table.cell(panelTable, 0, 0, fullText,
         text_color=txt_color,
         text_size=mapSize(font_size),
         text_halign=text.align_left,
         text_valign=text.align_top)
````
