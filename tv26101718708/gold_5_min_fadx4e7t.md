# gold 5 min 

- url: https://www.tradingview.com/script/fADX4E7t/
- type: indicator
- pine_id: PUB;53235e4ced604adcbf9575d6ef7c2ad9
- version: 1.0

## Description

日内短线

## Source Code

````pine
//@version=6
indicator("黄金5M全天候动能清算系统 [V6.3 零漂移绝对锁定版 - 完美修复]", "XAUUSD 5M 24H Zero-Drift Fixed", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. 实盘输入参数面板
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "🎯 01 - 动态突破与失衡参数"
lookback  = input.int(20, title = "动态极值寻找周期 (K线根数)", minval = 5, group = groupCore)
fvgThresh = input.float(0.5, title = "FVG 最小真空跨度 (美金)", minval = 0.1, step = 0.1, group = groupCore)

groupRisk = "🛑 02 - 实盘可视化风控线面板"
stopLossInput  = input.float(0.3, title = "固定止损百分比 (%, 用于画图表红线)", minval = 0.01, step = 0.05, group = groupRisk)
trailActInput  = input.float(0.5, title = "激活移动止盈所需盈利百分比 (%)", minval = 0.01, step = 0.05, group = groupRisk)
trailStepInput = input.float(0.1, title = "移动止盈回调回撤百分比 (%)", minval = 0.01, step = 0.02, group = groupRisk)

float stopLossPct  = stopLossInput / 100.0
float trailActPct  = trailActInput / 100.0
float trailStepPct = trailStepInput / 100.0

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. 全天候突破通道与 FVG 算法
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float localHigh = ta.highest(high[1], lookback)
float localLow  = ta.lowest(low[1], lookback)

plot(localHigh, "动态多头引爆线", color = color.new(color.orange, 60), style = plot.style_line)
plot(localLow,  "动态空头引爆线", color = color.new(color.blue, 60), style = plot.style_line)

bool isBullishFVG = (low[0] - high[2]) > fvgThresh
bool isBearishFVG = (low[2] - high[0]) > fvgThresh

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. 纯实盘信号开火逻辑
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool entryLongSignal  = (close > localHigh) and isBullishFVG
bool entryShortSignal = (close < localLow) and isBearishFVG

// 全局持仓模拟寄存器
var int   simPosition = 0 
var float entryPrice  = na
var float initialSL   = na
var float trailingTP  = na
var bool  isTrailActivated = false

// 警报触发状态寄存器
bool alertLongEntry  = false
bool alertShortEntry = false
bool alertTrailExit  = false
bool alertStopExit   = false

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. 全局提取函数（利用 nz 防御 na 注入，修复崩溃报错）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool isLongTriggeredBar  = simPosition == 1  and simPosition[1] == 0
bool isShortTriggeredBar = simPosition == -1 and simPosition[1] == 0

// 使用 nz(..., bar_index) 确保在没有信号的历史极早期，计算结果不会沦为 na
int lastLongEntryBar  = ta.valuewhen(isLongTriggeredBar,  bar_index, 0)
int lastShortEntryBar = ta.valuewhen(isShortTriggeredBar, bar_index, 0)

// 动态计算安全的lookback长度：若尚未有持仓信号，默认回溯长度为 1
int safeLongLen  = na(lastLongEntryBar)  ? 1 : math.max(1, math.min(bar_index - lastLongEntryBar + 1, 5000))
int safeShortLen = na(lastShortEntryBar) ? 1 : math.max(1, math.min(bar_index - lastShortEntryBar + 1, 5000))

// 全局连续寻找持仓以来的最高/最低价（参数绝对安全，100%不会传入 na）
float globalMaxPriceSeen = ta.highest(high, safeLongLen)
float globalMinPriceSeen = ta.lowest(low,   safeShortLen)

var string snapExitText  = ""
var color  snapExitColor = color.white
var float  snapExitPrice = na

// 模拟进场逻辑
if entryLongSignal and simPosition == 0
    simPosition := 1
    entryPrice  := close
    isTrailActivated := false
    initialSL   := close * (1.0 - stopLossPct)
    trailingTP  := initialSL
    alertLongEntry := true 

if entryShortSignal and simPosition == 0
    simPosition := -1
    entryPrice  := close
    isTrailActivated := false
    initialSL   := close * (1.0 + stopLossPct)
    trailingTP  := initialSL
    alertShortEntry := true 

// 模拟多头追踪
if simPosition == 1
    if not isTrailActivated and globalMaxPriceSeen >= entryPrice * (1.0 + trailActPct)
        isTrailActivated := true
    if isTrailActivated
        trailingTP := math.max(globalMaxPriceSeen * (1.0 - trailStepPct), nz(trailingTP[1]))
    else
        trailingTP := initialSL
        
    // 判定多头平仓出场
    if close <= trailingTP
        simPosition := 0
        snapExitPrice := trailingTP
        if isTrailActivated
            snapExitText  := "🍏 移动锁利平仓: " + str.tostring(trailingTP, "#.#")
            snapExitColor := color.green
            alertTrailExit := true 
        else
            snapExitText  := "⚠️ 固定止损平仓: " + str.tostring(trailingTP, "#.#")
            snapExitColor := color.red
            alertStopExit  := true 

// 模拟空头追踪
if simPosition == -1
    if not isTrailActivated and globalMinPriceSeen <= entryPrice * (1.0 - trailActPct)
        isTrailActivated := true
    if isTrailActivated
        trailingTP := math.min(globalMinPriceSeen * (1.0 + trailStepPct), nz(trailingTP[1], 999999.0))
    else
        trailingTP := initialSL
        
    // 判定空头平仓出场
    if close >= trailingTP
        simPosition := 0
        snapExitPrice := trailingTP
        if isTrailActivated
            snapExitText  := "🍏 移动锁利平仓: " + str.tostring(trailingTP, "#.#")
            snapExitColor := color.green
            alertTrailExit := true 
        else
            snapExitText  := "⚠️ 固定止损平仓: " + str.tostring(trailingTP, "#.#")
            snapExitColor := color.red
            alertStopExit  := true 

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. 零漂移绝对坐标渲染核心 (通过 time 时间戳强行钉死)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool plotLong  = simPosition == 1  and simPosition[1] == 0
bool plotShort = simPosition == -1 and simPosition[1] == 0
bool plotExit  = simPosition[1] != 0 and simPosition == 0

// 进场标签渲染
if plotLong
    label.new(time, low, "🟢 多头进场: " + str.tostring(entryPrice, "#.#"), xloc=xloc.bar_time, textcolor=color.green, color=color.new(color.white, 100), style=label.style_label_up, size=size.small)
if plotShort
    label.new(time, high, "🔴 空头进场: " + str.tostring(entryPrice, "#.#"), xloc=xloc.bar_time, textcolor=color.red, color=color.new(color.white, 100), style=label.style_label_down, size=size.small)

// 出场标签渲染
if plotExit
    labelStyle = alertTrailExit ? label.style_label_down : label.style_label_up
    label.new(time, snapExitPrice, snapExitText, xloc=xloc.bar_time, textcolor=snapExitColor, color=color.new(color.white, 100), style=labelStyle, size=size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. 辅助精准价格箭头
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(plotLong  ? entryPrice    : na, title="多头进场绝对点", style=shape.triangleup,   location=location.absolute, color=color.new(color.green, 20), size=size.small)
plotshape(plotShort ? entryPrice    : na, title="空头进场绝对点", style=shape.triangledown, location=location.absolute, color=color.new(color.red, 20),   size=size.small)
plotshape(plotExit  ? snapExitPrice : na, title="出场绝对平仓点", style=shape.xcross,       location=location.absolute, color=color.new(color.orange, 20), size=size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. 图表实时风控随动线渲染
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(simPosition != 0 ? initialSL : na, title="⚠️ 固定止损线", color=color.red, linewidth=2, style=plot.style_linebr)
plot(simPosition != 0 ? trailingTP : na, title="🍏 实时移动止盈线", color=isTrailActivated ? color.green : color.orange, linewidth=2, style=plot.style_linebr)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. 实盘多功能集成警报系统
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(alertLongEntry,  title="🟢 [多头进场] 警报", message="【黄金5M能清系统】🟢 多头信号触发！进场价格: {{close}}")
alertcondition(alertShortEntry, title="🔴 [空头进场] 警报", message="【黄金5M能清系统】🔴 空头信号触发！进场价格: {{close}}")
alertcondition(alertTrailExit,  title="🍏 [移动锁利] 平仓警报", message="【黄金5M能清系统】🍏 移动锁利机制触发平仓！平仓价格: {{close}}")
alertcondition(alertStopExit,   title="⚠️ [固定止损] 平仓警报", message="【黄金5M能清系统】⚠️ 价格触及固定风控线，已执行止损平仓！平仓价格: {{close}}")
````
