# K analysis

- url: https://www.tradingview.com/script/oPYJ7RpJ/
- type: indicator
- pine_id: PUB;820e785381154ab3a653f5c26d721865
- version: 1.0

## Description

提示

## Source Code

````pine
//@version=6
indicator("1分钟长K线选股器 - 声音提醒", overlay=true)

// ========== 参数设置 ==========
length = input.int(15, "比较窗口长度（包含当前K线）", minval=5)   // 周围K线参考窗口，实际用 length-1 根周围
threshold = input.float(2.2, "长K线倍数阈值", step=0.1, minval=1.2)
useAlert = input.bool(true, "启用声音/警报提醒")

// 计算当前K线实体长度（绝对值）
currentBody = math.abs(close - open)

// 计算过去 length-1 根K线的平均实体（排除当前K线，用于对比）
sumBody = 0.0
count = 0
for i = 1 to length-1
    body = math.abs(close[i] - open[i])
    sumBody += body
    count += 1

avgBody = sumBody / count

// 判断是否为长K线（当前实体 > 阈值 * 平均实体）
isLongCandle = currentBody > avgBody * threshold and avgBody > 0

// ========== 视觉标记 ==========
// 在长K线下方画紫色箭头
plotshape(isLongCandle, title="长K线信号", location=location.belowbar, 
         color=color.new(color.purple, 0), style=shape.triangleup, size=size.small)

// 在长K线实体上方加标签（可选）
if isLongCandle
    label.new(bar_index, high, "🔥 长K线", color=color.new(color.red, 80), 
              textcolor=color.white, style=label.style_label_up, size=size.small)

// ========== 警报条件（用于声音提醒）==========
alertcondition(isLongCandle, title="1分钟长K线警报", message="长K线触发！实体远超周围K线")

// 在图表上显示当前实体倍数（调试用）
plot(currentBody / avgBody, "当前倍数", color=color.new(color.orange, 50), style=plot.style_line, display=display.data_window)
````
