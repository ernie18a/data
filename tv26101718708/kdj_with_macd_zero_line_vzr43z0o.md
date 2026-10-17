# KDJ with MACD Zero Line

- url: https://www.tradingview.com/script/vZR43Z0o/
- type: indicator
- pine_id: PUB;058b2e1a3ece40879c6db643f888d8c3
- version: 1.0

## Description

哈哈哈

## Source Code

````pine
//@version=6
indicator("KDJ with MACD Zero Line", shorttitle="KDJ", overlay=false)

// KDJ 参数
length = input.int(9, title="KDJ Length")
smoothK = input.int(3, title="K Smoothing")
smoothD = input.int(3, title="D Smoothing")

// KDJ 计算
k = ta.stoch(close, high, low, length)
d = ta.sma(k, smoothK)
j = 3 * k - 2 * d

// MACD 参数（仅用于0轴参考）
fastLength = input.int(12, title="MACD Fast Length")
slowLength = input.int(26, title="MACD Slow Length")
signalLength = input.int(9, title="MACD Signal Length")

// MACD 计算（仅用于获取0轴参考）
[macdLine, signalLine, histLine] = ta.macd(close, fastLength, slowLength, signalLength)

// 将KDJ标准化到MACD的数值范围
// 计算KDJ和MACD的统计特性来建立对应关系
kdj_mean = ta.sma(j, 50)  // KDJ的长期均值
macd_mean = ta.sma(macdLine, 50)  // MACD的长期均值

kdj_std = ta.stdev(j, 50)  // KDJ的标准差
macd_std = ta.stdev(macdLine, 50)  // MACD的标准差

// 标准化KDJ值，使其与MACD具有相似的统计特性
normalized_k = macd_mean + (k - kdj_mean) * (macd_std / kdj_std)
normalized_d = macd_mean + (d - kdj_mean) * (macd_std / kdj_std)
normalized_j = macd_mean + (j - kdj_mean) * (macd_std / kdj_std)

// 绘制标准化后的KDJ线
plot(normalized_k, color=color.yellow, linewidth=2, title="K Line (Normalized)")
plot(normalized_d, color=color.blue, linewidth=2, title="D Line (Normalized)")
plot(normalized_j, color=color.red, linewidth=2, title="J Line (Normalized)")

// 绘制MACD 0轴作为KDJ的0轴
hline(0, "MACD Zero Line", color=color.black, linestyle=hline.style_solid, linewidth=1)

// 可选：绘制MACD参考线（虚线）
macd_zero_level = 0
hline(macd_zero_level, "MACD Zero", color=color.gray, linestyle=hline.style_dashed)

// 填充KDJ线之间的区域（增强可视化）
fill(plot(normalized_k), plot(normalized_d), color=color.new(color.yellow, 90), title="K-D Fill")
fill(plot(normalized_d), plot(normalized_j), color=color.new(color.blue, 90), title="D-J Fill")

// 添加超买超卖区域（基于MACD的统计特性）
upper_band = macd_mean + 2 * macd_std
lower_band = macd_mean - 2 * macd_std

// 显示当前值
plotchar(normalized_k, "Current K", "", location=location.top, color=color.yellow)
plotchar(normalized_d, "Current D", "", location=location.top, color=color.blue)
plotchar(normalized_j, "Current J", "", location=location.top, color=color.red)
````
