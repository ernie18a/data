# bulindaidefengkuang

- url: https://www.tradingview.com/script/kQHznRQq/
- type: indicator
- pine_id: PUB;967c2a1fc1bc4a31a5e3fa9fe16abebc
- version: 1.0

## Description

6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

## Source Code

````pine
//@version=6
indicator("BB Reversal Strict System v2", overlay=true)

// ======================
// 📊 布林带
// ======================
length = input.int(20)
mult = input.float(2.0)

basis = ta.sma(close, length)
dev = mult * ta.stdev(close, length)

upper = basis + dev
lower = basis - dev

plot(basis, color=color.gray)
plot(upper, color=color.red)
plot(lower, color=color.green)

// ======================
// 📏 K线结构
// ======================
body = math.abs(close - open)
upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

// ======================
// 🔴 做空形态（严格）
// ======================

// 流星线
shooting_star = (
    upper_wick >= body * 2 and
    lower_wick <= body * 0.3 and
    close < open
)

// 看跌吞没（标准）
bearish_engulfing = (
    close < open and
    close[1] > open[1] and
    open >= close[1] and
    close <= open[1]
)

// ======================
// 🟢 做多形态（加强版）
// ======================

// 🔧 新增：接近下轨的容差（核心优化点）
tolerance = input.float(0.2, "接近下轨容差(%)")

near_lower = (
    low <= lower * (1 + tolerance / 100)
)

// 锤子线（必须接近或触及下轨）
hammer = (
    lower_wick >= body * 1.5 and
    upper_wick <= body and
    near_lower
)

// 看涨吞没（严格标准版）
bullish_engulfing = (
    close > open and
    close[1] < open[1] and
    open <= close[1] and     // 必须包住前一根实体
    close >= open[1]
)

// ======================
// 📍 布林带触碰
// ======================

touch_upper = (
    high >= upper or
    math.max(open, close) >= upper
)

touch_lower = (
    low <= lower or
    math.min(open, close) <= lower
)

// ======================
// 🎯 最终信号
// ======================

short_signal = (
    touch_upper and
    (shooting_star or bearish_engulfing)
)

// 🔧 多头逻辑分开（更清晰控制）
long_signal = (
    (touch_lower and bullish_engulfing) or
    hammer   // hammer 已经内置“接近下轨”
)

// ======================
// 🔔 信号显示
// ======================
plotshape(
    short_signal,
    title="做空",
    location=location.abovebar,
    color=color.red,
    style=shape.labeldown,
    text="SHORT"
)

plotshape(
    long_signal,
    title="做多",
    location=location.belowbar,
    color=color.green,
    style=shape.labelup,
    text="LONG"
)

// ======================
// 🚨 警报
// ======================
alertcondition(
    short_signal,
    title="做空信号",
    message="BB 上轨反转做空信号"
)

alertcondition(
    long_signal,
    title="做多信号",
    message="BB 下轨反转做多信号"
)
````
