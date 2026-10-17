# Pin Bar and Engulfing Pattern

- url: https://www.tradingview.com/script/ZRWtVKAa/
- type: indicator
- pine_id: PUB;d3c38a40adb64bea9d7f7ac4e873de9d
- version: 2.0

## Description

吞没和pinbar（锤子线），结合趋势、支撑阻力，可以大幅度提高胜率的K线交易方法

## Source Code

````pine
//@version=6
// Pin Bar (9/14 长影线) + 自定义吞没形态 组合指标
indicator(title="Pin Bar + 吞没形态 (9/14标准)", shorttitle="PinBar+吞没", overlay=true, precision=2)

// ———— 全局自定义参数 ————
// Pin Bar 参数
shadow_ratio = input.float(9.0/14.0, title="Pin Bar 影线占比阈值", minval=0.1, maxval=0.99, step=0.01)
show_pin_markers = input.bool(true, title="显示 Pin Bar 标记")
show_pin_color = input.bool(true, title="染色 Pin Bar K线")

// 吞没形态 参数
show_engulf_markers = input.bool(true, title="显示 吞没形态 标记")
show_engulf_color = input.bool(true, title="染色 吞没形态 K线")

// ———— 核心K线数据计算 ————
kline_range = high - low
lower_shadow = math.min(open, close) - low
upper_shadow = high - math.max(open, close)

// ———— 1. Pin Bar 信号判定（收线确认）————
valid_kline = kline_range > 0
bullish_pinbar = valid_kline and (lower_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed
bearish_pinbar = valid_kline and (upper_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed
pinbar_signal = bullish_pinbar or bearish_pinbar

// ———— 2. 自定义吞没形态 信号判定（严格按你的规则+收线确认）————
// 看涨吞没：上根阴K + 当前阳K + 完全包裹 + 价格规则
prev_bear_candle = close[1] < open[1]
curr_bull_candle = close > open
bull_engulf = prev_bear_candle and curr_bull_candle and high > high[1] and low < low[1] and open <= close[1] and close >= open[1] and barstate.isconfirmed

// 看跌吞没：上根阳K + 当前阴K + 完全包裹 + 价格规则
prev_bull_candle = close[1] > open[1]
curr_bear_candle = close < open
bear_engulf = prev_bull_candle and curr_bear_candle and high > high[1] and low < low[1] and open >= close[1] and close <= open[1] and barstate.isconfirmed
engulf_signal = bull_engulf or bear_engulf

// 总信号
total_signal = pinbar_signal or engulf_signal

// ———— 可视化：K线染色 ————
barcolor(show_pin_color and bullish_pinbar ? color.green : na)
barcolor(show_pin_color and bearish_pinbar ? color.red : na)
barcolor(show_engulf_color and bull_engulf ? color.teal : na)
barcolor(show_engulf_color and bear_engulf ? color.purple : na)

// ———— 全部标识统一改为最小尺寸 ————
plotshape(show_pin_markers and bullish_pinbar, title="看涨Pin Bar", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(show_pin_markers and bearish_pinbar, title="看跌Pin Bar", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

plotshape(show_engulf_markers and bull_engulf, title="看涨吞没", style=shape.triangleup, location=location.belowbar, color=color.teal, size=size.small)
plotshape(show_engulf_markers and bear_engulf, title="看跌吞没", style=shape.triangledown, location=location.abovebar, color=color.purple, size=size.small)

// ———— 信号报警 ————
alertcondition(pinbar_signal, title="Pin Bar 信号", message="出现符合9/14标准的Pin Bar！")
alertcondition(engulf_signal, title="吞没形态 信号", message="出现自定义规则的吞没形态！")
alertcondition(total_signal, title="总信号", message="Pin Bar / 吞没形态 信号已触发！")
````
