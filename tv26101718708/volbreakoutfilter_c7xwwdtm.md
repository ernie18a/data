# Vol_Breakout_Filter

- url: https://www.tradingview.com/script/C7XWWdtm/
- type: indicator
- pine_id: PUB;4025998a9cec4161b766920be520b9cf
- version: 2.0

## Description

Vol_Breakout_Filter ,Vol_Breakout_Filter ,Vol_Breakout_Filter ,Vol_Breakout_Filter ,Vol_Breakout_Filter ,Vol_Breakout_Filter

## Source Code

````pine
//@version=6
// 显式加上 format=format.inherit，明确告知系统这是一个标准数值输出脚本
indicator("20日均线成交量突破20%筛选器", overlay=false, format=format.inherit)

vol_length = input.int(20, title="成交量均线周期")
breakout_pct = input.float(20.0, title="突破百分比 (%)")

vol_ma = ta.sma(volume, vol_length)
is_breakout = volume > vol_ma * (1 + (breakout_pct / 100))

// 确保把 display 属性去掉，让线在底层是逻辑可见的
plot(is_breakout ? 1 : 0, title="信号输出")
````
