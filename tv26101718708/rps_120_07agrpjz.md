# RPS 120

- url: https://www.tradingview.com/script/07aGrPJz-RPS-120/
- type: indicator
- pine_id: PUB;8805e0eb620b44acbf700cc18c1b5b3e
- version: 1.0

## Description

555555533333333333333333333333333333333333333333333333333333333333333333333

## Source Code

````pine
//@version=6
indicator("RPS 120", overlay=false, shorttitle="RPS120")

// 输入设置
length = input.int(120, title="周期")
threshold_low = input.int(72, title="低位分界")
threshold_high = input.int(90, title="高位分界")

// 计算RPS：当前收盘价在过去length根K线中的百分位排名
rps = ta.percentrank(close, length) * 100

// 颜色逻辑：区分强弱（修正了透明度参数）
plot_color = rps >= threshold_high ? color.new(color.green, 0) : 
             rps >= threshold_low ? color.new(color.green, 20) : 
             color.gray

// 绘图
plot(rps, color=plot_color, linewidth=2, title="RPS")
hline(threshold_low, "72分界", color=color.blue, linestyle=hline.style_dashed)
hline(threshold_high, "90强分界", color=color.red, linestyle=hline.style_dashed)
````
