# Customize Trend Candle Colors-td

- url: https://www.tradingview.com/script/NqX2ikk6/
- type: indicator
- pine_id: PUB;b3bc1699218c4dd49c1096856b844cb3
- version: 3.0

## Description

标记了趋势 K 和非趋势 K 的颜色，对于趋势 K 的判断有一些细节的调整。具体的详情看代码内部的备注。

## Source Code

````pine
//@version=6
indicator("自定义趋势K线颜色-td", overlay=true)

// ========== 开关输入 ==========
enableColoring = input.bool(true, "启用K线颜色标记", group="颜色设置")

// ========== 容差比例输入 ==========
tolerancePercent = input.float(10.0, "包裹容差比例(%)", minval=0, maxval=50, group="颜色设置")

// ========== 长影线阈值输入 ==========
longWickThreshold = input.float(10.0, "长影线阈值(%)", minval=0, maxval=50, group="颜色设置", tooltip="实体长度小于上下影线总长度的百分比时，标记为白色")

// ========== 获取影线数据 ==========
currentHigh = high
currentLow  = low
prevHigh    = high[1]
prevLow     = low[1]

// ========== 获取实体数据 ==========
currentBodyHigh = math.max(open, close)
currentBodyLow  = math.min(open, close)
prevBodyHigh    = math.max(open[1], close[1])
prevBodyLow     = math.min(open[1], close[1])

// ========== 计算当前K线的实体长度和影线长度 ==========
currentBodyLength = currentBodyHigh - currentBodyLow
currentUpperShadow = currentHigh - currentBodyHigh   // 上影线长度
currentLowerShadow = currentBodyLow - currentLow     // 下影线长度
currentTotalWickLength = currentUpperShadow + currentLowerShadow  // 上下影线总长度

// ========== 白色条件3：影线特别长（实体小于上下影线总和的阈值百分比）==========
// 注意：需要避免分母为0的情况（当上下影线总长度为0时，不满足条件）
isLongWick = currentTotalWickLength > 0 and currentBodyLength < currentTotalWickLength * longWickThreshold / 100

// ========== 计算左侧实体高度和容差值 ==========
prevBodyHeight = prevBodyHigh - prevBodyLow
toleranceValue = prevBodyHeight * tolerancePercent / 100

// ========== 白色条件1：实体被包裹（带容差）==========
isBodyHighInside = currentBodyHigh <= prevBodyHigh + toleranceValue
isBodyLowInside = currentBodyLow >= prevBodyLow - toleranceValue
isBodyWrapped = isBodyHighInside and isBodyLowInside

// ========== 白色条件2：影线被完全包裹 ==========
isShadowWrapped = currentHigh <= prevHigh and currentLow >= prevLow

// ========== 白色条件：满足任意一条即为白色 ==========
isWhiteCondition = isBodyWrapped or isShadowWrapped or isLongWick

// ========== 影线外包条件（用于其他颜色判断）==========
isWrap = currentHigh >= prevHigh and currentLow <= prevLow

// 普通涨跌（影线规则）
isNormalDown = currentLow < prevLow
isNormalUp = currentHigh > prevHigh

// 实体变化（用于黑色情况下的方向判断）
isBodyDown = currentBodyLow < prevBodyLow
isBodyUp = currentBodyHigh > prevBodyHigh
isBodyWrap = currentBodyHigh >= prevBodyHigh and currentBodyLow <= prevBodyLow

// 突破量
highBreakAmount = currentBodyHigh - prevBodyHigh
lowBreakAmount = prevBodyLow - currentBodyLow

// ========== 确定K线颜色 ==========
var color klineColor = na

if enableColoring
    // 优先判断：白色条件
    if isWhiteCondition
        klineColor := color.white
    // 影线外包且实体也外包 → 根据突破量判断黑/红/绿
    else if isWrap and isBodyWrap
        if highBreakAmount > lowBreakAmount
            klineColor := color.green
        else if lowBreakAmount > highBreakAmount
            klineColor := color.red
        else
            klineColor := color.black
    // 影线外包但实体未完全外包 → 根据实体变化判断红/绿
    else if isWrap
        if isBodyDown
            klineColor := color.red
        else if isBodyUp
            klineColor := color.green
        else
            klineColor := na
    // 普通情况：根据影线判断红/绿
    else
        if isNormalDown
            klineColor := color.red
        else if isNormalUp
            klineColor := color.green
        else
            klineColor := na
else
    klineColor := na

// ========== 应用绘图 ==========
barcolor(klineColor)



// K线颜色条件总结
// 一、白色（优先级最高，满足任意一条即白色）白色是无趋势的。
// 编号	条件名称	判断逻辑
// 1	实体包裹（带容差）	当前实体高点 ≤ 左侧实体高点 + (左侧实体高度 × 容差%)
// 且 当前实体低点 ≥ 左侧实体低点 - (左侧实体高度 × 容差%)
// 2	影线完全包裹	当前高点 ≤ 左侧高点  
// 且 当前低点 ≥ 左侧低点
// 3	长影线（十字星）	实体长度 < 上下影线总长度 × 长影线阈值%
// 二、黑色/红色/绿色（影线外包 + 实体外包时）黑色是相对于左侧 K 线，多空都有趋势的。绿色和红色是单向趋势的。
// 前提条件：当前K线影线外包左侧K线（high ≥ high[1] 且 low ≤ low[1]）
// 且 当前K线实体外包左侧K线（实体高点 ≥ 左侧实体高点 且 实体低点 ≤ 左侧实体低点）

// 条件	颜色
// 高点突破量 > 低点突破量	🟢 绿色
// 低点突破量 > 高点突破量	🔴 红色
// 高点突破量 = 低点突破量	⚫ 黑色
// 突破量计算：

// 高点突破量 = 当前实体高点 - 左侧实体高点

// 低点突破量 = 左侧实体低点 - 当前实体低点

// 三、红色/绿色（影线外包 + 实体未完全外包）
// 前提条件：当前K线影线外包左侧K线（high ≥ high[1] 且 low ≤ low[1]）
// 但 实体未完全外包

// 条件	颜色
// 当前实体低点 < 左侧实体低点	🔴 红色
// 当前实体高点 > 左侧实体高点	🟢 绿色
// 四、红色/绿色（普通情况，无外包）
// 前提条件：当前K线既不影线外包，也不满足白色条件

// 条件	颜色
// 当前低点 < 前一根低点（影线）	🔴 红色
// 当前高点 > 前一根高点（影线）	🟢 绿色
// 完整优先级顺序
// 优先级	条件	颜色
// 1（最高）	实体包裹（带容差）	⚪ 白色
// 2	影线完全包裹	⚪ 白色
// 3	长影线（十字星）	⚪ 白色
// 4	影线外包 + 实体外包 + 高点突破量 > 低点突破量	🟢 绿色
// 5	影线外包 + 实体外包 + 低点突破量 > 高点突破量	🔴 红色
// 6	影线外包 + 实体外包 + 突破量相等	⚫ 黑色
// 7	影线外包 + 实体低点降低	🔴 红色
// 8	影线外包 + 实体高点升高	🟢 绿色
// 9	普通 + 影线低点降低	🔴 红色
// 10	普通 + 影线高点升高	🟢 绿色
// 可调参数
// 参数	默认值	作用
// 容差比例	10%	实体包裹条件的允许偏差范围
// 长影线阈值	10%	实体长度小于上下影线总长度的百分比时标记白色
````
