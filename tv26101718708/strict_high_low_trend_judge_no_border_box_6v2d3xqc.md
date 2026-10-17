# Strict High Low Trend Judge - No Border Box

- url: https://www.tradingview.com/script/6v2D3xqc/
- type: indicator
- pine_id: PUB;b6bd620b2d4844cabc491c1cf75edeed
- version: 2.0

## Description

判断上涨下跌趋势，还在测试

## Source Code

````pine
//@version=6
indicator("Strict High Low Trend Judge - Merge Boxes One Label", overlay = true, max_boxes_count = 500)

// === 参数 ===
confirmBars = input.int(3, "确认趋势所需K线数量", minval = 2)

maxKeepBox  = input.int(300, "最多保留趋势框数量", minval = 50, maxval = 500)

upBoxColor   = input.color(color.blue, "上涨趋势框颜色")
downBoxColor = input.color(color.green, "下跌趋势框颜色")

boxTransp = input.int(82, "趋势框透明度", minval = 0, maxval = 100)
boxPadATR = input.float(0.08, "趋势框上下留白ATR倍数", minval = 0.0, step = 0.01)

mergeGapBars = input.int(1, "同方向趋势允许连接的间隔K线数", minval = 0, maxval = 20)

showLabel = input.bool(true, "是否显示趋势文字")

// === ATR 留白 ===
atr = ta.atr(14)
pad = atr * boxPadATR

// === 结构判断 ===
// 上涨：当前K线高点和低点都高于前一根
isHigherHL = high > high[1] and low > low[1]

// 下跌：当前K线高点和低点都低于前一根
isLowerHL = high < high[1] and low < low[1]

// === 连续关系计数 ===
needRelations = confirmBars - 1

var int upRelCount = 0
var int downRelCount = 0

upRelCount := isHigherHL ? nz(upRelCount[1]) + 1 : 0
downRelCount := isLowerHL ? nz(downRelCount[1]) + 1 : 0

// === 严格趋势状态 ===
int trend = 0

if upRelCount >= needRelations
    trend := 1
else if downRelCount >= needRelations
    trend := -1
else
    trend := 0

// === 最近 confirmBars 根K线最高最低 ===
startTop = ta.highest(high, confirmBars)
startBottom = ta.lowest(low, confirmBars)

// === 趋势框管理 ===
var array<box> trendBoxes = array.new_box()

var box activeBox = na
var int activeTrend = 0
var float activeTop = na
var float activeBottom = na

// === 记录最近一个趋势框，用于同方向合并 ===
var box lastBox = na
var int lastTrend = 0
var int lastRightIndex = na
var float lastTop = na
var float lastBottom = na

// === 当前K线是否显示标签 ===
// 只有新建趋势框时才显示；合并趋势框时不显示
bool showUpStartLabel = false
bool showDownStartLabel = false

// === 创建无边框趋势框 ===
f_createBox(int leftIndex, int rightIndex, float topPrice, float bottomPrice, color boxColor) =>
    box newBox = box.new(
         left = leftIndex,
         top = topPrice + pad,
         right = rightIndex,
         bottom = bottomPrice - pad,
         xloc = xloc.bar_index,
         border_color = color.new(boxColor, 100),
         border_width = 1,
         bgcolor = color.new(boxColor, boxTransp)
    )

    array.push(trendBoxes, newBox)

    if array.size(trendBoxes) > maxKeepBox
        box oldBox = array.shift(trendBoxes)
        box.delete(oldBox)

    newBox

// === 新趋势确认：上涨 ===
if trend == 1 and trend[1] != 1
    int leftIndex = bar_index - needRelations
    int rightIndex = bar_index

    bool canMerge = lastTrend == 1 and not na(lastBox) and not na(lastRightIndex) and leftIndex <= lastRightIndex + mergeGapBars

    if canMerge
        activeBox := lastBox
        activeTrend := 1

        activeTop := math.max(lastTop, startTop)
        activeBottom := math.min(lastBottom, startBottom)

        box.set_right(activeBox, rightIndex)
        box.set_top(activeBox, activeTop + pad)
        box.set_bottom(activeBox, activeBottom - pad)

        showUpStartLabel := false
    else
        activeTop := startTop
        activeBottom := startBottom

        activeBox := f_createBox(leftIndex, rightIndex, activeTop, activeBottom, upBoxColor)
        activeTrend := 1

        showUpStartLabel := true

    lastBox := activeBox
    lastTrend := 1
    lastRightIndex := rightIndex
    lastTop := activeTop
    lastBottom := activeBottom

// === 新趋势确认：下跌 ===
if trend == -1 and trend[1] != -1
    int leftIndex = bar_index - needRelations
    int rightIndex = bar_index

    bool canMerge = lastTrend == -1 and not na(lastBox) and not na(lastRightIndex) and leftIndex <= lastRightIndex + mergeGapBars

    if canMerge
        activeBox := lastBox
        activeTrend := -1

        activeTop := math.max(lastTop, startTop)
        activeBottom := math.min(lastBottom, startBottom)

        box.set_right(activeBox, rightIndex)
        box.set_top(activeBox, activeTop + pad)
        box.set_bottom(activeBox, activeBottom - pad)

        showDownStartLabel := false
    else
        activeTop := startTop
        activeBottom := startBottom

        activeBox := f_createBox(leftIndex, rightIndex, activeTop, activeBottom, downBoxColor)
        activeTrend := -1

        showDownStartLabel := true

    lastBox := activeBox
    lastTrend := -1
    lastRightIndex := rightIndex
    lastTop := activeTop
    lastBottom := activeBottom

// === 上涨趋势延续 ===
if trend == 1 and activeTrend == 1 and not na(activeBox)
    activeTop := math.max(activeTop, high)
    activeBottom := math.min(activeBottom, low)

    box.set_right(activeBox, bar_index)
    box.set_top(activeBox, activeTop + pad)
    box.set_bottom(activeBox, activeBottom - pad)

    lastBox := activeBox
    lastTrend := 1
    lastRightIndex := bar_index
    lastTop := activeTop
    lastBottom := activeBottom

// === 下跌趋势延续 ===
if trend == -1 and activeTrend == -1 and not na(activeBox)
    activeTop := math.max(activeTop, high)
    activeBottom := math.min(activeBottom, low)

    box.set_right(activeBox, bar_index)
    box.set_top(activeBox, activeTop + pad)
    box.set_bottom(activeBox, activeBottom - pad)

    lastBox := activeBox
    lastTrend := -1
    lastRightIndex := bar_index
    lastTop := activeTop
    lastBottom := activeBottom

// === 趋势断开 ===
// 不清空 lastBox，因为后续同方向趋势可能继续合并
if trend == 0
    activeBox := na
    activeTrend := 0
    activeTop := na
    activeBottom := na

// === 趋势文字 ===
// 合并到同一个趋势框里的上涨/下跌，只显示第一个标签
plotshape(
     showLabel and showUpStartLabel,
     title = "上涨趋势开始",
     text = "上涨",
     style = shape.labelup,
     location = location.belowbar,
     color = upBoxColor,
     textcolor = color.white,
     size = size.small
)

plotshape(
     showLabel and showDownStartLabel,
     title = "下跌趋势开始",
     text = "下跌",
     style = shape.labeldown,
     location = location.abovebar,
     color = downBoxColor,
     textcolor = color.white,
     size = size.small
)

// === 警报 ===
// 警报也只在新建趋势框时触发
alertcondition(
     showUpStartLabel,
     title = "上涨趋势开始",
     message = "连续K线高点和低点抬高，上涨趋势开始"
)

alertcondition(
     showDownStartLabel,
     title = "下跌趋势开始",
     message = "连续K线高点和低点下降，下跌趋势开始"
)
````
