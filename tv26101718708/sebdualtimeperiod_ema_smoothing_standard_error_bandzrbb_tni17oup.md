# SEB-Dual-time-period EMA smoothing standard error band-zrbb-

- url: https://www.tradingview.com/script/TNi17oup/
- type: indicator
- pine_id: PUB;bc7a69cc462641fb99456768745a1522
- version: 1.0

## Description

1. Gauging Trend Strength
The width of Standard Error Bands directly reflects the health of a trend:
Contracting Bands: When price is trending and the Standard Error Bands continue to narrow, it indicates that price is closely following the regression trendline, suggesting strong trend momentum and a likely continuation in the same direction.
Expanding Bands: When the Standard Error Bands begin to expand, it means price is deviating further from the regression trendline, signaling that the trend may be nearing its end and the market could enter consolidation or reverse.
2. Identifying Low-Volatility Conditions and Breakout Precursors
Similar to the "Squeeze" logic of Bollinger Bands, when Standard Error Bands narrow significantly, it often foreshadows an imminent expansion in volatility. Traders can treat this as an early warning signal for a potential breakout or the start of a significant price move.
3. Warning of Trend Reversals and Consolidation
The expansion of Standard Error Bands itself does not directly provide buy or sell signals, but it offers a statistical indication of trend exhaustion:
Band Expansion → Decreasing "cohesion" of the existing trend
Combined with price patterns, volume, or other momentum indicators (such as RSI, MACD), it can help determine whether a reversal or sideways consolidation is likely.
4. Comparative Application with Other Channel Indicators
Within the technical analysis framework, Standard Error Bands are often used in conjunction with Bollinger Bands, Keltner Channels, Donchian Channels, and others. Compared to Bollinger Bands, which are more sensitive to short-term price spikes, Standard Error Bands—being based on linear regression—provide a more robust depiction of trend direction and tend to generate fewer false signals in clearly trending markets.

1. 判断趋势强度
标准误差带的宽窄变化直接反映趋势的健康程度：
带收窄（Contracting）：当价格处于趋势中，而标准误差带持续收窄，说明价格紧密跟随回归趋势线，趋势动能较强，可能继续沿原方向运行。
带扩张（Expanding）：当标准误差带开始扩张，意味着价格偏离回归趋势线的程度加大，趋势可能即将结束，市场可能进入盘整或发生反转。
2. 识别低波动与突破前兆
与布林带的"挤压"（Squeeze）逻辑类似，标准误差带在极度收窄时，往往预示着波动性即将放大。交易者可将其视为潜在突破或大幅行情启动的早期预警信号。
3. 趋势反转与盘整预警
标准误差带扩张本身并不直接给出买卖方向，但它提供了一个趋势衰竭的统计信号：
带扩张 → 原有趋势的"凝聚力"下降
结合价格形态、成交量或其他动量指标（如 RSI、MACD），可辅助判断是反转还是横盘整理
4. 与其他通道指标的对比应用
在技术分析体系中，标准误差带常与布林带、凯尔特纳通道（Keltner Channels）、唐奇安通道（Donchian Channels）等配合使用。相比布林带对短期价格尖峰更敏感，标准误差带由于基于线性回归，对趋势方向的刻画更为稳健，在趋势明确的市场中假信号相对较少。

## Source Code

````pine
//@version=6
indicator("ZRBB双周期指标", overlay=true, max_lines_count=500, max_labels_count=500)

// ========== ZRBB 计算函数 ==========
zrbb(length, smoothPeriod, stdDevMult, decay) =>
    float sumX = 0.0
    float sumY = 0.0
    float sumXSq = 0.0
    float sumXY = 0.0
    float sumW = 0.0
    for i = 0 to length - 1
        weight = math.pow(decay, i)
        x = i + 1
        sumX += x * weight
        sumY += close[i] * weight
        sumXSq += (x * x) * weight
        sumXY += (x * close[i]) * weight
        sumW += weight
    slope = (sumW * sumXY - sumX * sumY) / (sumW * sumXSq - sumX * sumX)
    intercept = (sumY - slope * sumX) / sumW
    linreg = intercept + slope * (length + 1) / 2
    linregSmooth = ta.ema(linreg, smoothPeriod)
    float errorSum = 0.0
    for i = 0 to length - 1
        predicted = intercept + slope * (i + 1)
        errorSum += math.pow(close[i] - predicted, 2)
    stdError = math.sqrt(errorSum / (length - 2))
    stdErrorSmooth = ta.ema(stdError, smoothPeriod)
    upperBand  = linregSmooth + stdDevMult * stdErrorSmooth
    lowerBand  = linregSmooth - stdDevMult * stdErrorSmooth
    upperBand2 = linregSmooth + (stdDevMult + 5) * stdErrorSmooth
    lowerBand2 = linregSmooth - (stdDevMult + 5) * stdErrorSmooth
    [linregSmooth, upperBand, lowerBand, upperBand2, lowerBand2]

// ========== 输入参数(可调，默认按你的既定参数) ==========
grp1 = "ZRBB1 参数"
len1    = input.int(5,    "计算周期",     minval=1, group=grp1)
smooth1 = input.int(60,   "EMA平滑周期",  minval=1, group=grp1)
mult1   = input.float(5,  "标准误差倍数", minval=0.1, group=grp1)
decay1  = input.float(0.6,"衰减因子", minval=0.1, maxval=1.0, step=0.01, group=grp1)
showMid1 = input.bool(true, "显示中线", group=grp1)

grp2 = "ZRBB2 参数"
len2    = input.int(10,   "计算周期",     minval=1, group=grp2)
smooth2 = input.int(60,   "EMA平滑周期",  minval=1, group=grp2)
mult2   = input.float(5,  "标准误差倍数", minval=0.1, group=grp2)
decay2  = input.float(0.33,"衰减因子", minval=0.1, maxval=1.0, step=0.01, group=grp2)
showMid2 = input.bool(false, "显示中线", group=grp2)

// ========== 计算 ==========
// ZRBB1: 周期5, EMA平滑60, 标准误差倍数5, 衰减0.6
[mid1, upperBand1_1, lowerBand1_1, upperBand1_2, lowerBand1_2] = zrbb(len1, smooth1, mult1, decay1)
// ZRBB2: 周期10, EMA平滑60, 标准误差倍数5, 衰减0.33
[mid2, upperBand2_1, lowerBand2_1, upperBand2_2, lowerBand2_2] = zrbb(len2, smooth2, mult2, decay2)

// ========== 绘图 ==========
// ZRBB1: 上/下轨1为蓝线，上/下轨2为黄线
plot(showMid1 ? mid1 : na, "ZRBB1中线",   color=color.new(color.blue, 60), linewidth=1)
plot(upperBand1_1, "ZRBB1上轨1(蓝)", color=color.blue,   linewidth=1)
plot(lowerBand1_1, "ZRBB1下轨1(蓝)", color=color.blue,   linewidth=1)
plot(upperBand1_2, "ZRBB1上轨2(黄)", color=color.yellow, linewidth=1)
plot(lowerBand1_2, "ZRBB1下轨2(黄)", color=color.yellow, linewidth=1)

// ZRBB2: 上/下轨1为橙线(上轨2/下轨2不要求，默认不绘制，可按需打开)
plot(showMid2 ? mid2 : na, "ZRBB2中线",   color=color.new(color.orange, 60), linewidth=1)
plot(upperBand2_1, "ZRBB2上轨1(橙)", color=color.orange, linewidth=1)
plot(lowerBand2_1, "ZRBB2下轨1(橙)", color=color.orange, linewidth=1)
````
