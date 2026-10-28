# VWMA ATR Adaptive Channel

- url: https://www.tradingview.com/script/ieH1ucXw/
- type: indicator
- pine_id: PUB;a9f8e54fb43940fe82831f366efd0f15
- version: 1.0

## Description

VWMA ATR Adaptive Channel / VWMA ATR 自适应通道

This indicator builds dynamic upper and lower bands using VWMA and ATR. It is designed to help traders observe price range, dynamic support/resistance areas, trend extension zones, and changing volatility conditions.

该指标基于 VWMA（成交量加权移动平均）与 ATR（平均真实波幅）构建动态上下轨，用于辅助观察价格运行区间、动态支撑压力、趋势延展区域以及市场波动状态。

Core Logic / 核心逻辑

- Uses VWMA as the volume-weighted price reference.
- 使用 VWMA 作为成交量加权后的价格中枢参考。

- Uses ATR to calculate the distance between the upper and lower bands.
- 使用 ATR 计算上下轨与中枢之间的距离。

- Supports fixed-timeframe calculation, allowing higher-timeframe bands to be displayed on the current chart.
- 支持固定周期计算，可在当前图表上显示指定高周期的通道。

- Includes a volatility-adaptive mechanism that adjusts band width based on ATR/Close.
- 内置波动率自适应机制，可根据 ATR/Close 自动调整通道宽度。

Main Inputs / 主要参数

- Band Timeframe: The timeframe used for band calculation.
- Band Timeframe：用于计算通道的固定周期。

- VWMA Length: The length of the VWMA calculation.
- VWMA Length：VWMA 计算长度。

- ATR Period: The period used for ATR calculation.
- ATR Period：ATR 计算周期。

- ATR Multiplier: The base ATR multiplier used to define band distance.
- ATR Multiplier：用于计算通道距离的 ATR 基础倍数。

- Use Volatility-Adaptive Band: Enables or disables the volatility-adaptive mechanism.
- Use Volatility-Adaptive Band：是否启用波动率自适应机制。

- Vol Reference ATR/Close: The reference volatility level used for adaptive adjustment.
- Vol Reference ATR/Close：用于自适应调整的参考波动率水平。

- Vol Clamp Low / High: The lower and upper limits for the adaptive volatility multiplier.
- Vol Clamp Low / High：自适应波动率倍数的下限与上限。

How to Use / 使用方式

- The upper band may be used as a dynamic resistance or price extension reference.
- 上轨可作为动态压力区域或价格延展区域参考。

- The lower band may be used as a dynamic support or pullback reference.
- 下轨可作为动态支撑区域或价格回撤区域参考。

- A widening channel usually indicates increasing volatility.
- 通道变宽通常表示市场波动率上升。

- A narrowing channel usually indicates decreasing volatility.
- 通道变窄通常表示市场波动率下降。

- The indicator can be used together with trend structure, volume, candlestick patterns, or other trading systems.
- 该指标可结合趋势结构、成交量、K线形态或其他交易系统一起使用。


For technical analysis only. Not financial advice.

本指标仅用于技术分析辅助，不构成任何投资建议。

## Source Code

````pine
//@version=5
indicator("VWMA ATR Adaptive Channel", shorttitle="VWMA ATR Channel", overlay=true)

//==================== 参数 / Inputs ====================
baseTF = input.timeframe("15", "带线周期 / Band Timeframe")

longlen = input.int(50, "VWMA 长度 / VWMA Length", minval=1)

atrPeriod   = input.int(14, "ATR 周期 / ATR Period", minval=1)
atrMultBand = input.float(3.0, "ATR 倍数 / ATR Multiplier", step=0.1)

// 波动率自适应 / Volatility Adaptive
useVolAdaptive = input.bool(true, "启用波动率自适应带 / Use Volatility-Adaptive Band")
volRef     = input.float(0.010, "波动率参考 ATR/Close / Vol Reference ATR/Close", step=0.001)
volClampLo = input.float(0.70, "波动率下限 / Vol Clamp Low", step=0.05)
volClampHi = input.float(1.50, "波动率上限 / Vol Clamp High", step=0.05)

//==================== 计算函数 / Calculation Function ====================
f_bands() =>
    basis = ta.vwma(close, longlen)
    atr = ta.atr(atrPeriod)
    atrPct = atr / close
    volRatio = volRef == 0 or na(volRef) ? 1.0 : atrPct / volRef
    volRatioClamped = math.max(volClampLo, math.min(volRatio, volClampHi))
    dynMult = useVolAdaptive ? atrMultBand * volRatioClamped : atrMultBand
    upper = basis + atr * dynMult
    lower = basis - atr * dynMult
    [upper, lower]

//==================== 固定周期上下带 / Fixed-Timeframe Upper-Lower Bands ====================
[upperBand, lowerBand] = request.security(syminfo.tickerid, baseTF, f_bands(), barmerge.gaps_off, barmerge.lookahead_off)

//==================== 绘图 / Plots ====================
plot(upperBand, title="上轨 ATR 带 / Upper ATR Band", color=color.red, linewidth=1, style=plot.style_stepline)
plot(lowerBand, title="下轨 ATR 带 / Lower ATR Band", color=color.green, linewidth=1, style=plot.style_stepline)
````
