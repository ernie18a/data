# ASDQWE123 2.0 [ATP]

- url: https://www.tradingview.com/script/wqLijNbF/
- type: indicator
- pine_id: PUB;ab096102f1a449f69af1f1ddf283bc71
- version: 1.0

## Description

盈利日好用，梭哈后果自负。## 指标简介 (Introduction)ASDQWE123 是一款深度融合了**成交量分布（Volume Distribution）与动态波动率（Volatility Dynamics）**的高级分析工具。它通过复杂的 VWMA（成交量加权移动平均）算法构建价格中枢，并结合 ATR（平均真实波幅）生成自适应的“紫色云带”通道。该系统的核心逻辑在于识别价格偏离成交量共识的极端状态，捕捉趋势运行过程中的高胜率回调入场点。ASDQWE123 is a premium analytical tool that integrates Volume Distribution with Volatility Dynamics. By utilizing complex VWMA algorithms to construct a price pivot and combining it with ATR-based adaptive envelopes, it creates the signature "Purple Cloud" bands. The system is engineered to identify price deviations from volume consensus, capturing high-probability entry points during trend retracements.## 核心功能 (Core Features)非线性均线系统 (Non-linear Core)：核心信号线采用双重 VWMA 平滑，相比传统 SMA 或 EMA，能更敏锐地察觉大资金入场引起的价格重心偏移。动态极值通道 (Dynamic Extremum Envelopes)：通过 $\alpha$ 参数调节的 ATR 轨道，实时定义市场的超买与超卖边界。趋势过滤逻辑 (Trend Filtering)：内置基于 b1 变量的趋势识别机制，自动过滤逆势信号，确保交易者始终站在概率更高的一侧。全自动化视觉反馈 (Automated Visuals)：集成 K 线变色逻辑与直观的 BUY/SELL 信号标签，支持实时推送到手机或邮箱的 Alert 警报。## 交易策略建议 (Trading Strategy)做多 (Long)：当价格处于长期均线上方（多头环境），ASDQWE123 的核心线跌破下轨 xl 触发超卖，随后价格企稳回升出现 BUY 标签时入场。做空 (Short)：当价格处于长期均线下方（空头环境），核心线突破上轨 xh 触发超买，随后价格受阻回落出现 SELL 标签时入场。出场方案 (Exit)：建议以自带的红色/绿色 ATR 边界线作为初始止损或第一止盈位。## 技术参数 (Technical Settings)ATR Period: 建议 10-14（平衡灵敏度与稳定性）。Alpha: 默认为 0.9（数值越小，通道越窄，信号越频繁）。Period (x1): 建议 40（适用于日内波段）。## 免责声明 (Disclaimer)ASDQWE123 仅作为技术分析辅助工具，不保证任何未来收益。交易者应结合自身风险承受能力，并在不同市场环境下对参数进行优化调整。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// algotradepro

//@version=6
indicator('Purple Cloud 2.0 [ATP]', overlay = true, timeframe = '', timeframe_gaps = true)

atrPeriod = input(10, 'Supertrend ATR Length', group='Purple Cloud')
factor = input.float(3.0, 'Supertrend Factor', step = 0.01, group='Purple Cloud')
x1 = input(40, 'Period', group='Purple Cloud')
alpha = input.float(0.9, 'Alpha', step = 0.1, group='Purple Cloud')

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

x2 = ta.atr(x1) * alpha
xh = close + x2
xl = close - x2

a1 = ta.vwma(hl2 * volume, math.ceil(x1 / 4)) / ta.vwma(volume, math.ceil(x1 / 4))
a2 = ta.vwma(hl2 * volume, math.ceil(x1 / 2)) / ta.vwma(volume, math.ceil(x1 / 2))
a3 = 2 * a1 - a2
a4 = ta.vwma(a3, x1)

b1 = 0.0
b1 := na(b1[1]) ? ta.sma(close, x1) : (b1[1] * (x1 - 1) + close) / x1

buy = a4 <= xl and close > b1
sell = a4 >= xh and close < b1

xs = 0
xs := buy ? 1 : sell ? -1 : xs[1]

barcolor(color = xs == 1 ? color.green : xs == -1 ? color.red : na)
plotshape(buy and xs != xs[1], title = 'BUY', text = 'BUY', style = shape.labelup, location = location.belowbar, color = color.green, textcolor = color.white, size = size.tiny)
plotshape(sell and xs != xs[1], title = 'SELL', text = 'SELL', style = shape.labeldown, location = location.abovebar, color = color.red, textcolor = color.white, size = size.tiny)
alertcondition(buy and xs != xs[1], 'PC Long', 'PC Long')
alertcondition(sell and xs != xs[1], 'PC Short', 'PC Short')

//ATR BANDS
// Inputs
ATRPeriod = input.int(title = "ATR Period", defval = 14, minval = 1, group='ATR Bands')
srcUpper = close
srcLower = close
atrMultiplierUpper = input.float(title = "ATR Multiplier Upper", defval = 1.5, group='ATR Bands')
atrMultiplierLower = input.float(title = "ATR Multiplier Lower", defval = 1.5, group='ATR Bands')

// ATR
atr = ta.atr(ATRPeriod)

// Plotting
plot(srcUpper + atr * atrMultiplierUpper, color = color.green)
plot(srcLower - atr * atrMultiplierLower, color = color.red)

//End
````
