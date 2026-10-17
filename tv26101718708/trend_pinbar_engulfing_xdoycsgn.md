# Trend PinBar & Engulfing

- url: https://www.tradingview.com/script/XdOyCSgN/
- type: indicator
- pine_id: PUB;a74bb2b752ee407b9c6f27f2d87d40c0
- version: 3.0

## Description

结合macd、ma均线，做趋势确认形成调整后的反转K线

## Source Code

````pine
//@version=6
// Trend PinBar & Engulf Multi Filter
indicator(title="Trend PinBar & Engulf Multi Filter", shorttitle="PinEngulf-MultiFilter", overlay=true, precision=2)

//———自定义参数———
shadow_ratio = input.float(9.0/14.0, title="PinBar影线占比", minval=0.1, maxval=0.99, step=0.01)
eng_shadow_limit = input.float(0.5, title="吞没K线最大影线占比", tooltip="吞没形态K线影线不能超过整根K线50%")
show_pin_markers = input.bool(true, title="显示PinBar标记")
show_pin_color = input.bool(true, title="PinBarK线染色")
show_engulf_markers = input.bool(true, title="显示吞没标记")
show_engulf_color = input.bool(true, title="吞没K线染色")
show_ma_line = input.bool(true, title="显示13/20/60均线")

//———计算三条均线———
ma13 = ta.sma(close,13)
ma20 = ta.sma(close,20)
ma60 = ta.sma(close,60)

// 均线排列条件
ma_bull_arrange = ma13 > ma20 and ma20 > ma60  // 多头排列
ma_bear_arrange = ma13 < ma20 and ma20 < ma60  // 空头排列

// 价格相对60日线位置
above_ma60 = close > ma60
below_ma60 = close < ma60

//———双MACD后台计算(不绘图)———
// 标准MACD(12,26,9)
[diff1, dea1, _] = ta.macd(close,12,26,9)
// 快速MACD(6,13,5)
[diff2, dea2, _] = ta.macd(close,6,13,5)

// 仅两组MACD慢线DEA零轴同侧
macd_bull_all = dea1 > 0 and dea2 > 0
macd_bear_all = dea1 < 0 and dea2 < 0

//———最终共振过滤条件———
long_condition = ma_bull_arrange and above_ma60 and macd_bull_all
short_condition = ma_bear_arrange and below_ma60 and macd_bear_all

//———K线基础数据———
kline_range = high - low
lower_shadow = math.min(open, close) - low
upper_shadow = high - math.max(open, close)

// 吞没专用：当前K线影线占比不超50%
eng_shadow_ok = (lower_shadow <= kline_range * eng_shadow_limit) and (upper_shadow <= kline_range * eng_shadow_limit)

//———PinBar原始形态判定———
valid_kline = kline_range > 0
raw_bull_pin = valid_kline and (lower_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed
raw_bear_pin = valid_kline and (upper_shadow >= kline_range * shadow_ratio) and barstate.isconfirmed

// 叠加过滤
bullish_pinbar = raw_bull_pin and long_condition
bearish_pinbar = raw_bear_pin and short_condition

//———自定义吞没原始形态判定 + 新增影线限制———
prev_bear_candle = close[1] < open[1]
curr_bull_candle = close > open
raw_bull_eng = prev_bear_candle and curr_bull_candle and high>high[1] and low<low[1] and open<=close[1] and close>=open[1] and barstate.isconfirmed and eng_shadow_ok

prev_bull_candle = close[1] > open[1]
curr_bear_candle = close < open
raw_bear_eng = prev_bull_candle and curr_bear_candle and high>high[1] and low<low[1] and open>=close[1] and close<=open[1] and barstate.isconfirmed and eng_shadow_ok

// 叠加过滤
bull_engulf = raw_bull_eng and long_condition
bear_engulf = raw_bear_eng and short_condition

//———绘制三条均线———
plot(show_ma_line ? ma13 : na, color=color.yellow, linewidth=1, title="MA13")
plot(show_ma_line ? ma20 : na, color=color.orange, linewidth=1, title="MA20")
plot(show_ma_line ? ma60 : na, color=color.blue, linewidth=2, title="MA60")

//———K线染色———
barcolor(show_pin_color and bullish_pinbar ? color.green : na)
barcolor(show_pin_color and bearish_pinbar ? color.red : na)
barcolor(show_engulf_color and bull_engulf ? color.teal : na)
barcolor(show_engulf_color and bear_engulf ? color.purple : na)

//———小巧迷你标记———
plotshape(show_pin_markers and bullish_pinbar, title="看涨PinBar", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(show_pin_markers and bearish_pinbar, title="看跌PinBar", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

plotshape(show_engulf_markers and bull_engulf, title="看涨吞没", style=shape.triangleup, location=location.belowbar, color=color.teal, size=size.small)
plotshape(show_engulf_markers and bear_engulf, title="看跌吞没", style=shape.triangledown, location=location.abovebar, color=color.purple, size=size.small)

//———精准报警———
alertcondition(bullish_pinbar, title="多头共振-看涨PinBar", message="三线多头排列+站上60日线+双MACD慢线零轴上 看涨长影PinBar")
alertcondition(bearish_pinbar, title="空头共振-看跌PinBar", message="三线空头排列+跌破60日线+双MACD慢线零轴下 看跌长影PinBar")
alertcondition(bull_engulf, title="多头共振-看涨吞没", message="三线多头排列+站上60日线+双MACD慢线零轴上 标准实体看涨吞没")
alertcondition(bear_engulf, title="空头共振-看跌吞没", message="三线空头排列+跌破60日线+双MACD慢线零轴下 标准实体看跌吞没")
````
