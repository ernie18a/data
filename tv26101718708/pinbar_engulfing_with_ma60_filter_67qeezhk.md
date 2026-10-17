# PinBar & Engulfing with MA60 Filter

- url: https://www.tradingview.com/script/67QeeZHK/
- type: indicator
- pine_id: PUB;56790b53b004432aac04c81c4198b2e0
- version: 1.0

## Description

结合60均线，只在60线上给出看涨信号，60线下给出看跌信号，结合趋势、支撑阻力可以大幅提高胜率

## Source Code

````pine
//@version=6
// Pin Bar9/14+自定义吞没+60日均线趋势过滤
indicator(title="PinBar+吞没 60均线趋势过滤", shorttitle="趋势Pin吞没", overlay=true, precision=2)

//———自定义参数———
shadow_ratio = input.float(9.0/14.0, title="PinBar影线占比", minval=0.1, maxval=0.99, step=0.01)
show_pin_markers = input.bool(true, title="显示PinBar标记")
show_pin_color = input.bool(true, title="PinBarK线染色")
show_engulf_markers = input.bool(true, title="显示吞没标记")
show_engulf_color = input.bool(true, title="吞没K线染色")
show_ma60 = input.bool(true, title="显示60日均线")

//———计算60日均线———
ma60 = ta.sma(close, 60)
above_ma = close > ma60    // 收线在均线上方
below_ma = close < ma60    // 收线在均线下方

//———K线基础数据———
kline_range = high - low
lower_shadow = math.min(open, close) - low
upper_shadow = high - math.max(open, close)

//———PinBar原始判定———
valid_kline = kline_range > 0
raw_bull_pin = valid_kline and (lower_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed
raw_bear_pin = valid_kline and (upper_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed

//———加入均线趋势过滤———
bullish_pinbar = raw_bull_pin and above_ma
bearish_pinbar = raw_bear_pin and below_ma

//———自定义吞没原始判定———
prev_bear_candle = close[1] < open[1]
curr_bull_candle = close > open
raw_bull_eng = prev_bear_candle and curr_bull_candle and high > high[1] and low < low[1] and open <= close[1] and close >= open[1] and barstate.isconfirmed

prev_bull_candle = close[1] > open[1]
curr_bear_candle = close < open
raw_bear_eng = prev_bull_candle and curr_bear_candle and high > high[1] and low < low[1] and open >= close[1] and close <= open[1] and barstate.isconfirmed

//———吞没加入均线趋势过滤———
bull_engulf = raw_bull_eng and above_ma
bear_engulf = raw_bear_eng and below_ma

//———绘制60日均线———
plot(show_ma60 ? ma60 : na, color=color.blue, linewidth=2, title="60日均线")

//———K线染色———
barcolor(show_pin_color and bullish_pinbar ? color.green : na)
barcolor(show_pin_color and bearish_pinbar ? color.red : na)
barcolor(show_engulf_color and bull_engulf ? color.teal : na)
barcolor(show_engulf_color and bear_engulf ? color.purple : na)

//———小尺寸标记显示———
plotshape(show_pin_markers and bullish_pinbar, title="看涨PinBar", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(show_pin_markers and bearish_pinbar, title="看跌PinBar", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

plotshape(show_engulf_markers and bull_engulf, title="看涨吞没", style=shape.triangleup, location=location.belowbar, color=color.teal, size=size.small)
plotshape(show_engulf_markers and bear_engulf, title="看跌吞没", style=shape.triangledown, location=location.abovebar, color=color.purple, size=size.small)

//———报警提示———
alertcondition(bullish_pinbar, title="均线上方-看涨PinBar", message="60日均线上方出现看涨长影线PinBar")
alertcondition(bearish_pinbar, title="均线下方-看跌PinBar", message="60日均线下方出现看跌长影线PinBar")
alertcondition(bull_engulf, title="均线上方-看涨吞没", message="60日均线上方出现看涨吞没形态")
alertcondition(bear_engulf, title="均线下方-看跌吞没", message="60日均线下方出现看跌吞没形态")
````
