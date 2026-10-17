# Pin Bar K

- url: https://www.tradingview.com/script/YTaXLVMJ/
- type: indicator
- pine_id: PUB;4657e9cb36f84a929ad257ad031a97de
- version: 1.0

## Description

Pin Bar K，反转信号，锤子线，结合趋势、支撑阻力等提高胜率

## Source Code

````pine
//@version=6
// Pin Bar (9/14 长影线标准) - TradingView 发布版
indicator(title="Pin Bar (9/14 长影线标准)", shorttitle="PinBar9/14", overlay=true, precision=2)

// ———— 用户自定义参数 ————
shadow_ratio = input.float(9.0/14.0, title="影线占比阈值", minval=0.1, maxval=0.99, step=0.01, tooltip="判定Pin Bar的影线长度占K线总长度的比例")
show_markers = input.bool(true, title="显示形态标记")
show_bar_color = input.bool(true, title="染色K线")

// ———— 核心K线计算 ————
kline_range = high - low
lower_shadow = math.min(open, close) - low
upper_shadow = high - math.max(open, close)

// ———— Pin Bar 信号判定（收线确认，无假信号）————
valid_kline = kline_range > 0
bullish_pinbar = valid_kline and (lower_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed
bearish_pinbar = valid_kline and (upper_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed
pinbar_signal = bullish_pinbar or bearish_pinbar

// ———— K线染色（全局作用域，无报错）————
barcolor(show_bar_color and bullish_pinbar ? color.new(color.green, 0) : na)
barcolor(show_bar_color and bearish_pinbar ? color.new(color.red, 0) : na)

// ———— 形态标记（全局作用域，无报错）————
plotshape(show_markers and bullish_pinbar, title="看涨Pin Bar", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(show_markers and bearish_pinbar, title="看跌Pin Bar", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ———— 信号报警 ————
alertcondition(pinbar_signal, title="Pin Bar 信号", message="出现符合9/14标准的Pin Bar形态！")
````
