# Multi-Timeframe MA 10 EMA SMA WMA HMA RMA

- url: https://www.tradingview.com/script/yKDgk06h/
- type: indicator
- pine_id: PUB;aacfe20acf634fa78d44af17eb248f46
- version: 1.0

## Description

█ OVERVIEW

This indicator displays up to 10 moving average lines, each on its own independently configurable timeframe.

The core idea is simple: instead of recalculating periods manually when switching chart timeframes, you set each line to a specific timeframe once and it stays there regardless of what timeframe you are viewing.

For example, set MA1 to the Daily 200 EMA and it will always show the Daily 200 EMA — whether you are looking at a 1-minute chart or a 4-hour chart.

█ FEATURES

• Up to 10 MA lines, each with independent timeframe, period, type, and color settings
• MA types: EMA, SMA, WMA, HMA, RMA
• Lines 7 to 10 are hidden by default — enable only what you need
• Each line has a Show toggle so you can turn individual lines on and off without losing your settings

█ MA TYPES

• EMA — Exponential Moving Average. Weights recent bars more heavily. The most widely used MA among traders.
• SMA — Simple Moving Average. Treats all bars equally. Often watched by institutional traders.
• WMA — Weighted Moving Average. Similar to EMA but with a more straightforward weighting curve.
• HMA — Hull Moving Average. Designed to minimize lag while staying smooth. Reacts faster than EMA.
• RMA — Wilder's Moving Average. The same MA used inside RSI calculations. Smoother and slower than EMA.

█ HOW TO USE

Set each line to a timeframe and period that matches your trading approach. A few common setups:

Upper timeframe confluence — Set MA1, MA2, MA3 to the Daily, 4H, and 1H 200 EMA respectively. Keeps key support and resistance levels visible on any chart.

MA ribbon — Set multiple lines to the same timeframe with different periods (e.g. 20, 50, 100, 200). The order and spacing of the lines reflects trend strength.

Cross-timeframe comparison — Set the same period (e.g. 50 EMA) across multiple timeframes to see whether they are aligned in the same direction.

█ NOTES

• Lines set to a higher timeframe than the current chart may repaint on the forming bar — this is normal behavior for request.security() in Pine Script
• If a line appears flat or missing, check that the selected timeframe is higher than or equal to your current chart timeframe

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe MA 10 EMA SMA WMA HMA RMA", shorttitle="MTF MA", overlay=true)

// MA1
ma1_show   = input.bool(true,  "Show", group="MA1")
ma1_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA1")
ma1_tf     = input.timeframe("D",   "Timeframe", group="MA1")
ma1_length = input.int(20,  "Length", minval=1, group="MA1")
ma1_color  = input.color(color.blue,   "Color", group="MA1")

// MA2
ma2_show   = input.bool(true,  "Show", group="MA2")
ma2_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA2")
ma2_tf     = input.timeframe("240", "Timeframe", group="MA2")
ma2_length = input.int(50,  "Length", minval=1, group="MA2")
ma2_color  = input.color(color.red,    "Color", group="MA2")

// MA3
ma3_show   = input.bool(true,  "Show", group="MA3")
ma3_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA3")
ma3_tf     = input.timeframe("60",  "Timeframe", group="MA3")
ma3_length = input.int(100, "Length", minval=1, group="MA3")
ma3_color  = input.color(color.green,  "Color", group="MA3")

// MA4
ma4_show   = input.bool(true,  "Show", group="MA4")
ma4_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA4")
ma4_tf     = input.timeframe("15",  "Timeframe", group="MA4")
ma4_length = input.int(200, "Length", minval=1, group="MA4")
ma4_color  = input.color(color.orange, "Color", group="MA4")

// MA5
ma5_show   = input.bool(true,  "Show", group="MA5")
ma5_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA5")
ma5_tf     = input.timeframe("5",   "Timeframe", group="MA5")
ma5_length = input.int(10,  "Length", minval=1, group="MA5")
ma5_color  = input.color(color.purple, "Color", group="MA5")

// MA6
ma6_show   = input.bool(true,  "Show", group="MA6")
ma6_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA6")
ma6_tf     = input.timeframe("1",   "Timeframe", group="MA6")
ma6_length = input.int(5,   "Length", minval=1, group="MA6")
ma6_color  = input.color(color.yellow, "Color", group="MA6")

// MA7 (hidden by default)
ma7_show   = input.bool(false, "Show", group="MA7")
ma7_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA7")
ma7_tf     = input.timeframe("W",   "Timeframe", group="MA7")
ma7_length = input.int(20,  "Length", minval=1, group="MA7")
ma7_color  = input.color(color.teal,   "Color", group="MA7")

// MA8 (hidden by default)
ma8_show   = input.bool(false, "Show", group="MA8")
ma8_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA8")
ma8_tf     = input.timeframe("W",   "Timeframe", group="MA8")
ma8_length = input.int(50,  "Length", minval=1, group="MA8")
ma8_color  = input.color(color.maroon, "Color", group="MA8")

// MA9 (hidden by default)
ma9_show   = input.bool(false, "Show", group="MA9")
ma9_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA9")
ma9_tf     = input.timeframe("M",   "Timeframe", group="MA9")
ma9_length = input.int(20,  "Length", minval=1, group="MA9")
ma9_color  = input.color(color.aqua,   "Color", group="MA9")

// MA10 (hidden by default)
ma10_show   = input.bool(false, "Show", group="MA10")
ma10_type   = input.string("EMA", "Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group="MA10")
ma10_tf     = input.timeframe("M",   "Timeframe", group="MA10")
ma10_length = input.int(50,  "Length", minval=1, group="MA10")
ma10_color  = input.color(color.lime,  "Color", group="MA10")

// Calculate MA by type
calc_ma(src, length, ma_type) =>
    half = math.round(length / 2)
    sq   = math.round(math.sqrt(length))
    switch ma_type
        "SMA" => ta.sma(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        "HMA" => ta.wma(2 * ta.wma(src, half) - ta.wma(src, length), sq)
        =>       ta.ema(src, length)

// Fetch MA on specified timeframe
get_ma(src, length, tf, ma_type) =>
    request.security(syminfo.tickerid, tf, calc_ma(src, length, ma_type), gaps=barmerge.gaps_on)

// Calculate each MA (returns na when hidden)
ma1  = ma1_show  ? get_ma(close, ma1_length,  ma1_tf,  ma1_type)  : na
ma2  = ma2_show  ? get_ma(close, ma2_length,  ma2_tf,  ma2_type)  : na
ma3  = ma3_show  ? get_ma(close, ma3_length,  ma3_tf,  ma3_type)  : na
ma4  = ma4_show  ? get_ma(close, ma4_length,  ma4_tf,  ma4_type)  : na
ma5  = ma5_show  ? get_ma(close, ma5_length,  ma5_tf,  ma5_type)  : na
ma6  = ma6_show  ? get_ma(close, ma6_length,  ma6_tf,  ma6_type)  : na
ma7  = ma7_show  ? get_ma(close, ma7_length,  ma7_tf,  ma7_type)  : na
ma8  = ma8_show  ? get_ma(close, ma8_length,  ma8_tf,  ma8_type)  : na
ma9  = ma9_show  ? get_ma(close, ma9_length,  ma9_tf,  ma9_type)  : na
ma10 = ma10_show ? get_ma(close, ma10_length, ma10_tf, ma10_type) : na

// Plot
plot(ma1,  title="MA 1",  color=ma1_color,  linewidth=2)
plot(ma2,  title="MA 2",  color=ma2_color,  linewidth=2)
plot(ma3,  title="MA 3",  color=ma3_color,  linewidth=2)
plot(ma4,  title="MA 4",  color=ma4_color,  linewidth=2)
plot(ma5,  title="MA 5",  color=ma5_color,  linewidth=2)
plot(ma6,  title="MA 6",  color=ma6_color,  linewidth=2)
plot(ma7,  title="MA 7",  color=ma7_color,  linewidth=2)
plot(ma8,  title="MA 8",  color=ma8_color,  linewidth=2)
plot(ma9,  title="MA 9",  color=ma9_color,  linewidth=2)
plot(ma10, title="MA 10", color=ma10_color, linewidth=2)
````
