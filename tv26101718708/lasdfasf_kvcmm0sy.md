# lasdfasf

- url: https://www.tradingview.com/script/KvcmM0SY/
- type: indicator
- pine_id: PUB;08e743c396ed4883b1ad318c8c88c017
- version: 1.0

## Description

红跌绿涨

## Source Code

````pine
//@version=6
indicator("二连跌后二连涨区域", overlay=true)

// 判断阴线/阳线
isBearish = close < open   // 下跌K线
isBullish = close > open   // 上涨K线

// 连续2根下跌（第1、2根为阴线）
twoBears = isBearish and isBearish[1]

// 紧接着连续2根上涨（第3、4根为阳线）
twoBullsAfter = isBullish and isBullish[1]

// 信号：满足“阴-阴-阳-阳”四根K线序列
// 标记位置：第3根K线（两连涨的起始位置）和第4根K线（两连涨结束位置）
signalStart = twoBears[2] and twoBullsAfter   // 第3根（两连涨的第1根）开始
signalEnd   = twoBears[3] and twoBullsAfter[1] // 第4根（两连涨的第2根）

// 绘制背景（覆盖第3、4根K线）
bgcolor(signalStart ? color.new(color.green, 85) : na)
bgcolor(signalEnd   ? color.new(color.green, 85) : na)
````
