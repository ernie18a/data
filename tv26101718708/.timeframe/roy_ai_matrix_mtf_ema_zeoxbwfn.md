# Roy AI Matrix MTF EMA

- url: https://www.tradingview.com/script/zEoxbWFn-Roy-AI-Matrix-MTF-EMA/
- type: indicator
- pine_id: PUB;4d90fb00e64c4cf5bb8e1b950e8f009c
- version: 1.0

## Description

ROY AI MATRIX MTF EMA – MOBILE FIX

Roy AI Matrix MTF EMA is an advanced multi-timeframe trend analysis indicator designed to combine EMA structure, timeframe strength, and market direction into a single mathematical trend engine.

This indicator was specially optimized for TradingView mobile users with a lightweight and cleaner matrix dashboard that remains responsive even on lower-powered devices.

Unlike traditional EMA indicators that only analyze one timeframe, Roy AI Matrix MTF EMA combines multiple timeframes and multiple EMA layers simultaneously to calculate overall market bias and trend pressure.

The indicator transforms market structure into a weighted mathematical score system where:

• Higher timeframes carry stronger influence
• Larger EMAs represent stronger market structure
• Bullish conditions generate positive values
• Bearish conditions generate negative values

The final score helps traders quickly identify whether the market is dominated by buyers or sellers.

FEATURES

• Multi-Timeframe EMA Matrix
• EMA 10 / 20 / 50 / 100 / 200 Analysis
• Bullish & Bearish Matrix Heatmap
• AI Trend Score Calculation
• Market Bias Detection
• Buy & Sell Signal Detection
• Mobile-Friendly Compact Table
• Lightweight Optimized Version
• M15 Intraday Trading Optimization
• Trend Gravity Concept

TIMEFRAMES INCLUDED

• M1
• M5
• M15
• M30
• H1
• H4
• Daily

HOW IT WORKS

Each timeframe and EMA combination is converted into a weighted mathematical score.

Bullish conditions produce positive values.
Bearish conditions produce negative values.

Higher timeframes such as H4 and Daily carry significantly stronger weight compared to lower timeframes like M1 and M5.

This allows traders to identify:

• True dominant trend direction
• Pullbacks against major trend
• Momentum continuation
• Trend strength
• Market phase

SIGNAL LOGIC

BUY Signal:
• Overall score is bullish
• M15 EMA momentum turns bullish
• M5 confirms momentum continuation

SELL Signal:
• Overall score is bearish
• M15 EMA momentum turns bearish
• M5 confirms downside continuation

BEST USED FOR

• Intraday Trading
• Scalping
• Trend Following
• Momentum Trading
• Multi-Timeframe Analysis
• Gold (XAUUSD)
• Forex
• Crypto
• Indices

This indicator is designed to help traders visualize market structure and trend alignment in a cleaner and more mathematical way.

Optimized especially for traders who trade primarily on the M15 timeframe while still respecting higher timeframe market gravity.

## Source Code

````pine
//@version=6
indicator("Roy AI Matrix MTF EMA - Mobile Fix", overlay=true, max_labels_count=50)

// ================= INPUT =================
showTable  = input.bool(true, "Show Matrix Table")
showEMA    = input.bool(true, "Show EMA Current Chart")
showSignal = input.bool(true, "Show Signal")

tablePosInp = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Bottom Right"])
tablePos = tablePosInp == "Top Center" ? position.top_center : tablePosInp == "Bottom Right" ? position.bottom_right : position.top_right

// ================= CURRENT EMA =================
plot(showEMA ? ta.ema(close, 10) : na, "EMA 10", color=color.aqua)
plot(showEMA ? ta.ema(close, 20) : na, "EMA 20", color=color.orange)
plot(showEMA ? ta.ema(close, 50) : na, "EMA 50", color=color.yellow)
plot(showEMA ? ta.ema(close, 100) : na, "EMA 100", color=color.blue)
plot(showEMA ? ta.ema(close, 200) : na, "EMA 200", color=color.purple)

// ================= FUNCTION =================
f_dir(tf, len) =>
    request.security(syminfo.tickerid, tf, close > ta.ema(close, len) ? 1 : -1)

f_bg(x) =>
    x == 1 ? color.new(color.lime, 0) : color.new(color.red, 0)

f_dot() =>
    "●"

// ================= MATRIX =================
// M1
m1_10 = f_dir("1", 10)
m1_20 = f_dir("1", 20)
m1_50 = f_dir("1", 50)
m1_100 = f_dir("1", 100)
m1_200 = f_dir("1", 200)

// M5
m5_10 = f_dir("5", 10)
m5_20 = f_dir("5", 20)
m5_50 = f_dir("5", 50)
m5_100 = f_dir("5", 100)
m5_200 = f_dir("5", 200)

// M15
m15_10 = f_dir("15", 10)
m15_20 = f_dir("15", 20)
m15_50 = f_dir("15", 50)
m15_100 = f_dir("15", 100)
m15_200 = f_dir("15", 200)

// M30
m30_10 = f_dir("30", 10)
m30_20 = f_dir("30", 20)
m30_50 = f_dir("30", 50)
m30_100 = f_dir("30", 100)
m30_200 = f_dir("30", 200)

// H1
h1_10 = f_dir("60", 10)
h1_20 = f_dir("60", 20)
h1_50 = f_dir("60", 50)
h1_100 = f_dir("60", 100)
h1_200 = f_dir("60", 200)

// H4
h4_10 = f_dir("240", 10)
h4_20 = f_dir("240", 20)
h4_50 = f_dir("240", 50)
h4_100 = f_dir("240", 100)
h4_200 = f_dir("240", 200)

// D
d_10 = f_dir("D", 10)
d_20 = f_dir("D", 20)
d_50 = f_dir("D", 50)
d_100 = f_dir("D", 100)
d_200 = f_dir("D", 200)

// ================= SCORE =================
score =
     m1_10*0.5 + m1_20*1 + m1_50*2.5 + m1_100*5 + m1_200*10 +
     m5_10*1 + m5_20*2 + m5_50*5 + m5_100*10 + m5_200*20 +
     m15_10*3 + m15_20*6 + m15_50*15 + m15_100*30 + m15_200*60 +
     m30_10*6 + m30_20*12 + m30_50*30 + m30_100*60 + m30_200*120 +
     h1_10*12 + h1_20*24 + h1_50*60 + h1_100*120 + h1_200*240 +
     h4_10*48 + h4_20*96 + h4_50*240 + h4_100*480 + h4_200*960 +
     d_10*1440 + d_20*2880 + d_50*7200 + d_100*14400 + d_200*28800

bias = score > 0 ? "BULL" : score < 0 ? "BEAR" : "SIDE"
biasColor = score > 0 ? color.lime : score < 0 ? color.red : color.orange

buySignal = score > 0 and m15_20 == 1 and m15_50 == 1 and m5_20 == 1
sellSignal = score < 0 and m15_20 == -1 and m15_50 == -1 and m5_20 == -1

plotshape(showSignal and buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.lime)
plotshape(showSignal and sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.red)

// ================= TABLE =================
var table t = table.new(tablePos, 6, 9, border_width=1)

f_row(row, tfName, a, b, c, d, e) =>
    table.cell(t, 0, row, tfName, text_color=color.white, bgcolor=color.rgb(45,45,55), text_size=size.tiny)
    table.cell(t, 1, row, f_dot(), text_color=color.rgb(40,40,40), bgcolor=f_bg(a), text_size=size.tiny)
    table.cell(t, 2, row, f_dot(), text_color=color.rgb(40,40,40), bgcolor=f_bg(b), text_size=size.tiny)
    table.cell(t, 3, row, f_dot(), text_color=color.rgb(40,40,40), bgcolor=f_bg(c), text_size=size.tiny)
    table.cell(t, 4, row, f_dot(), text_color=color.rgb(40,40,40), bgcolor=f_bg(d), text_size=size.tiny)
    table.cell(t, 5, row, f_dot(), text_color=color.rgb(40,40,40), bgcolor=f_bg(e), text_size=size.tiny)

if barstate.islast and showTable
    table.cell(t, 0, 0, "TF", text_color=color.aqua, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 1, 0, "10", text_color=color.aqua, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 2, 0, "20", text_color=color.aqua, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 3, 0, "50", text_color=color.aqua, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 4, 0, "100", text_color=color.aqua, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 5, 0, "200", text_color=color.aqua, bgcolor=color.rgb(35,35,45), text_size=size.tiny)

    f_row(1, "M1", m1_10, m1_20, m1_50, m1_100, m1_200)
    f_row(2, "M5", m5_10, m5_20, m5_50, m5_100, m5_200)
    f_row(3, "M15", m15_10, m15_20, m15_50, m15_100, m15_200)
    f_row(4, "M30", m30_10, m30_20, m30_50, m30_100, m30_200)
    f_row(5, "H1", h1_10, h1_20, h1_50, h1_100, h1_200)
    f_row(6, "H4", h4_10, h4_20, h4_50, h4_100, h4_200)
    f_row(7, "D", d_10, d_20, d_50, d_100, d_200)

    table.cell(t, 0, 8, "SCORE", text_color=color.white, bgcolor=color.rgb(30,30,40), text_size=size.tiny)
    table.cell(t, 1, 8, str.tostring(score, "#"), text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
    table.cell(t, 2, 8, "BIAS", text_color=color.white, bgcolor=color.rgb(30,30,40), text_size=size.tiny)
    table.cell(t, 3, 8, bias, text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
    table.cell(t, 4, 8, "M15", text_color=color.white, bgcolor=color.rgb(30,30,40), text_size=size.tiny)
    table.cell(t, 5, 8, buySignal ? "BUY" : sellSignal ? "SELL" : "WAIT", text_color=color.white, bgcolor=buySignal ? color.lime : sellSignal ? color.red : color.orange, text_size=size.tiny)
````
