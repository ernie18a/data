# MA + FVG + Candle Body Size + Engulfing

- url: https://www.tradingview.com/script/6sjcw4dd-MA-FVG-Candle-Body-Size-Engulfing/
- type: indicator
- pine_id: PUB;19183204dfc741b6830664b48f46463c
- version: 1.0

## Description

MA + FVG + Candle Body Size + Engulfing Super Indicator combines trend, momentum, and price action into a single overlay system for TradingView.

It features a configurable Moving Average Ribbon for trend direction, Engulfing Candlestick detection for reversal signals, a Candle Body Size tool to measure strong momentum candles in ticks, and Fair Value Gaps (FVGs) displayed as shaded imbalance zones.

All components are fully integrated on the price chart with customizable inputs and real-time alerts, allowing traders to quickly identify trend structure, momentum spikes, reversals, and liquidity inefficiencies in one streamlined tool.

## Source Code

````pine
//@version=6
indicator("MA + FVG + Candle Body Size + Engulfing)", shorttitle="MA + FVG + Candle Body Size + Engulfing", overlay=true)

// =====================================================
// === "MA RIBBON SETTINGS" ============================
// =====================================================

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)
        => na

show_ma1   = input(true, "MA #1", inline="MA #1", display=display.none)
ma1_type   = input.string("SMA", "", inline="MA #1", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma1_source = input(close, "", inline="MA #1", display=display.none)
ma1_length = input.int(20, "", inline="MA #1", minval=1)
ma1_color  = input.color(#f6c309, "", inline="MA #1", display=display.none)

show_ma2   = input(true, "MA #2", inline="MA #2", display=display.none)
ma2_type   = input.string("SMA", "", inline="MA #2", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma2_source = input(close, "", inline="MA #2", display=display.none)
ma2_length = input.int(50, "", inline="MA #2", minval=1)
ma2_color  = input.color(#fb9800, "", inline="MA #2", display=display.none)

show_ma3   = input(true, "MA #3", inline="MA #3", display=display.none)
ma3_type   = input.string("SMA", "", inline="MA #3", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma3_source = input(close, "", inline="MA #3", display=display.none)
ma3_length = input.int(100, "", inline="MA #3", minval=1)
ma3_color  = input.color(#fb6500, "", inline="MA #3", display=display.none)

show_ma4   = input(true, "MA #4", inline="MA #4", display=display.none)
ma4_type   = input.string("SMA", "", inline="MA #4", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma4_source = input(close, "", inline="MA #4", display=display.none)
ma4_length = input.int(200, "", inline="MA #4", minval=1)
ma4_color  = input.color(#f60c0c, "", inline="MA #4", display=display.none)

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

plot(ma1, "MA #1", ma1_color, display=show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display=show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display=show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display=show_ma4 ? display.all : display.none)


// =====================================================
// === "ENGULFING CANDLE SETTINGS" ====================
// =====================================================

bullishEngulfing = (open <= close[1]) and (open < open[1]) and (close > open[1])
bearishEngulfing = (open >= close[1]) and (open > open[1]) and (close < open[1])

plotshape(bullishEngulfing, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny, title="Bullish Engulfing")
plotshape(bearishEngulfing, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, title="Bearish Engulfing")

alertcondition(bullishEngulfing, title="Bullish Engulfing", message="Bullish engulfing detected")
alertcondition(bearishEngulfing, title="Bearish Engulfing", message="Bearish engulfing detected")


// =====================================================
// === "CANDLE BODY SIZE SETTINGS" =====================
// =====================================================

thresholdTicks = input.int(4000, "Threshold (ticks)", minval=1)
tf_body = input.timeframe("", "Timeframe (Body Size)")

[o_body, c_body] = request.security(syminfo.tickerid, tf_body == "" ? timeframe.period : tf_body, [open, close], lookahead=barmerge.lookahead_off)

bodySizeTicks = math.abs(c_body - o_body) / syminfo.mintick
bigCandle = barstate.isconfirmed and bodySizeTicks > thresholdTicks

alertcondition(bigCandle, title="Big Candle Alert", message="Candle body exceeded threshold ticks!")


// =====================================================
// === "FAIR VALUE GAP SETTINGS" =======================
// =====================================================

show_fvg   = input(true, "Show FVG")
tf_fvg     = input.timeframe("", "FVG Timeframe")
fvg_extend = input.int(20, "FVG Extension (bars)", minval=1)
fvg_opacity = input.int(85, "FVG Shade Transparency", minval=0, maxval=100)

fvg_high2 = request.security(syminfo.tickerid, tf_fvg == "" ? timeframe.period : tf_fvg, high[2], lookahead=barmerge.lookahead_off)
fvg_low2  = request.security(syminfo.tickerid, tf_fvg == "" ? timeframe.period : tf_fvg, low[2], lookahead=barmerge.lookahead_off)
fvg_high  = request.security(syminfo.tickerid, tf_fvg == "" ? timeframe.period : tf_fvg, high, lookahead=barmerge.lookahead_off)
fvg_low   = request.security(syminfo.tickerid, tf_fvg == "" ? timeframe.period : tf_fvg, low, lookahead=barmerge.lookahead_off)

bull_fvg = show_fvg and not na(fvg_high2) and fvg_low > fvg_high2
bear_fvg = show_fvg and not na(fvg_low2) and fvg_high < fvg_low2

if bull_fvg
    box.new(
        left=bar_index-2,
        right=bar_index + fvg_extend,
        top=fvg_low,
        bottom=fvg_high2,
        bgcolor=color.new(color.green, fvg_opacity),
        border_width=0
    )

if bear_fvg
    box.new(
        left=bar_index-2,
        right=bar_index + fvg_extend,
        top=fvg_low2,
        bottom=fvg_high,
        bgcolor=color.new(color.red, fvg_opacity),
        border_width=0
    )


// =====================================================
// === END SUPER INDICATOR =============================
// =====================================================
````
