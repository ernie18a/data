# Roy Gravity Matrix AI

- url: https://www.tradingview.com/script/QvbyYvgN/
- type: indicator
- pine_id: PUB;ddc640c915504722b1d34aa1ec6a128a
- version: 1.0

## Description

ROY GRAVITY MATRIX AI

Roy Gravity Matrix AI is an advanced multi-timeframe mathematical trading engine designed to analyze market gravity, trend structure, momentum alignment, and directional pressure using adaptive EMA matrix calculations.

Unlike traditional EMA indicators that focus only on a single timeframe, Roy Gravity Matrix AI combines multiple timeframes and multiple EMA layers into one adaptive AI-driven matrix system.

The indicator is built around the concept of:

“Higher timeframe gravity controls lower timeframe movement.”

This means larger market structure from higher timeframes such as H4 and Daily carries stronger influence over smaller timeframes like M1 and M5.

The system transforms bullish and bearish market conditions into weighted mathematical scores to detect:

• Market Gravity
• Trend Alignment
• Momentum Strength
• Pullback Conditions
• Expansion Phases
• Smart Entry Timing

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Adaptive Main Timeframe System
• Multi-Timeframe EMA Matrix
• EMA 10 / 20 / 50 / 100 / 200 Analysis
• Gravity Trend Engine
• Mathematical Trend Scoring
• AI Market Bias Detection
• AI Market Phase Detection
• Smart Buy & Sell Signals
• Confidence Percentage System
• Bullish & Bearish Heatmap
• Mobile-Friendly Compact Dashboard
• Lightweight Optimized Performance

━━━━━━━━━━━━━━━━━━
ADAPTIVE MAIN TIMEFRAME
━━━━━━━━━━━━━━━━━━

Traders can select their preferred main trading timeframe:

• M1
• M5
• M15
• M30
• H1
• H4
• Daily

The AI engine automatically adjusts:

• Gravity Timeframes
• Trigger Timeframes
• Momentum Structure
• Entry Logic

based on the selected trading style.

Example:

If Main TF = M15:
• Gravity = H1 + H4
• Momentum = M15
• Trigger = M5 + M1

If Main TF = H1:
• Gravity = H4 + Daily
• Momentum = H1
• Trigger = M15 + M30

━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━

Each EMA and timeframe combination is converted into a weighted mathematical value.

Bullish conditions produce positive values.
Bearish conditions produce negative values.

Higher EMAs and higher timeframes carry stronger weight in the final score calculation.

This creates a market gravity system capable of identifying:

• True dominant trend
• Pullbacks against trend
• Trend continuation
• Weak trend conditions
• Expansion momentum
• Reversal pressure

━━━━━━━━━━━━━━━━━━
MARKET PHASES
━━━━━━━━━━━━━━━━━━

• BULL EXP → Strong bullish expansion
• BULL PULL → Bullish pullback
• BEAR EXP → Strong bearish expansion
• BEAR PULL → Bearish pullback
• MIXED → Sideway or conflicting structure

━━━━━━━━━━━━━━━━━━
SIGNAL LOGIC
━━━━━━━━━━━━━━━━━━

BUY Signal:
• Overall score bullish
• Main timeframe bullish
• Trigger timeframe confirms momentum
• Gravity trend aligned bullish

SELL Signal:
• Overall score bearish
• Main timeframe bearish
• Trigger timeframe confirms downside momentum
• Gravity trend aligned bearish

━━━━━━━━━━━━━━━━━━
BEST USED FOR
━━━━━━━━━━━━━━━━━━

• Scalping
• Intraday Trading
• Swing Trading
• Trend Following
• Momentum Trading
• Gold (XAUUSD)
• Forex
• Crypto
• Indices

━━━━━━━━━━━━━━━━━━
CORE CONCEPT
━━━━━━━━━━━━━━━━━━

Roy Gravity Matrix AI is designed around the idea that market movement behaves similarly to gravity.

Higher timeframe trends pull lower timeframe movement toward the dominant market direction.

This creates a smarter way to analyze market structure beyond traditional EMA crossover systems.

The indicator combines:

• Trend Gravity
• Momentum Structure
• Adaptive Timeframe Logic
• Mathematical Scoring
• Multi-Timeframe Alignment
• AI Market Interpretation

into a single professional trading engine.

## Source Code

````pine
//@version=6
indicator("Roy Gravity Matrix AI", overlay=true, max_labels_count=50)

// ================= INPUT =================
mainTFInput = input.string("15", "Main Timeframe", options=["1", "5", "15", "30", "60", "240", "D"])
showTable   = input.bool(true, "Show Gravity Matrix")
showEMA     = input.bool(true, "Show EMA Current Chart")
showSignal  = input.bool(true, "Show Buy/Sell Signal")

tablePosInp = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Bottom Right"])
tablePos = tablePosInp == "Top Center" ? position.top_center : tablePosInp == "Bottom Right" ? position.bottom_right : position.top_right

// ================= EMA CURRENT CHART =================
plot(showEMA ? ta.ema(close, 10) : na, "EMA 10", color=color.aqua)
plot(showEMA ? ta.ema(close, 20) : na, "EMA 20", color=color.orange)
plot(showEMA ? ta.ema(close, 50) : na, "EMA 50", color=color.yellow)
plot(showEMA ? ta.ema(close, 100) : na, "EMA 100", color=color.blue)
plot(showEMA ? ta.ema(close, 200) : na, "EMA 200", color=color.purple)

// ================= FUNCTIONS =================
f_dir(tf, len) =>
    request.security(syminfo.tickerid, tf, close > ta.ema(close, len) ? 1 : -1)

f_bg(x) =>
    x == 1 ? color.new(color.lime, 0) : color.new(color.red, 0)

f_dot() =>
    "●"

f_tfName(tf) =>
    tf == "1" ? "M1" :
     tf == "5" ? "M5" :
     tf == "15" ? "M15" :
     tf == "30" ? "M30" :
     tf == "60" ? "H1" :
     tf == "240" ? "H4" : "D"

// ================= MATRIX DIRECTIONS =================
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

maxScore = 56928.5
confidence = math.abs(score) / maxScore * 100

// ================= DYNAMIC MAIN TF =================
main20 =
     mainTFInput == "1" ? m1_20 :
     mainTFInput == "5" ? m5_20 :
     mainTFInput == "15" ? m15_20 :
     mainTFInput == "30" ? m30_20 :
     mainTFInput == "60" ? h1_20 :
     mainTFInput == "240" ? h4_20 : d_20

main50 =
     mainTFInput == "1" ? m1_50 :
     mainTFInput == "5" ? m5_50 :
     mainTFInput == "15" ? m15_50 :
     mainTFInput == "30" ? m30_50 :
     mainTFInput == "60" ? h1_50 :
     mainTFInput == "240" ? h4_50 : d_50

// ================= SMART TRIGGER BY MAIN TF =================
triggerBull =
     mainTFInput == "1" ? m1_20 == 1 :
     mainTFInput == "5" ? m1_20 == 1 :
     mainTFInput == "15" ? m5_20 == 1 :
     mainTFInput == "30" ? m15_20 == 1 :
     mainTFInput == "60" ? m30_20 == 1 :
     mainTFInput == "240" ? h1_20 == 1 : h4_20 == 1

triggerBear =
     mainTFInput == "1" ? m1_20 == -1 :
     mainTFInput == "5" ? m1_20 == -1 :
     mainTFInput == "15" ? m5_20 == -1 :
     mainTFInput == "30" ? m15_20 == -1 :
     mainTFInput == "60" ? m30_20 == -1 :
     mainTFInput == "240" ? h1_20 == -1 : h4_20 == -1

// ================= GRAVITY LOGIC =================
gravityBull = h4_50 == 1 and d_50 == 1
gravityBear = h4_50 == -1 and d_50 == -1

bias =
     score > 1000 ? "SUPER BULL" :
     score > 0 ? "BULL" :
     score < -1000 ? "SUPER BEAR" :
     score < 0 ? "BEAR" : "SIDEWAY"

phase =
     gravityBull and main20 == 1 and triggerBull ? "BULL EXP" :
     gravityBull and main20 == -1 ? "BULL PULL" :
     gravityBear and main20 == -1 and triggerBear ? "BEAR EXP" :
     gravityBear and main20 == 1 ? "BEAR PULL" :
     "MIXED"

biasColor = score > 0 ? color.lime : score < 0 ? color.red : color.orange

buySignal = score > 0 and main20 == 1 and main50 == 1 and triggerBull
sellSignal = score < 0 and main20 == -1 and main50 == -1 and triggerBear

plotshape(showSignal and buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.lime)
plotshape(showSignal and sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.red)

// ================= TABLE =================
var table t = table.new(tablePos, 6, 10, border_width=1)

f_row(row, tfName, a, b, c, d, e) =>
    table.cell(t, 0, row, tfName, text_color=color.white, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 1, row, f_dot(), text_color=color.rgb(30,30,30), bgcolor=f_bg(a), text_size=size.tiny)
    table.cell(t, 2, row, f_dot(), text_color=color.rgb(30,30,30), bgcolor=f_bg(b), text_size=size.tiny)
    table.cell(t, 3, row, f_dot(), text_color=color.rgb(30,30,30), bgcolor=f_bg(c), text_size=size.tiny)
    table.cell(t, 4, row, f_dot(), text_color=color.rgb(30,30,30), bgcolor=f_bg(d), text_size=size.tiny)
    table.cell(t, 5, row, f_dot(), text_color=color.rgb(30,30,30), bgcolor=f_bg(e), text_size=size.tiny)

if barstate.islast and showTable
    table.cell(t, 0, 0, "TF", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 1, 0, "10", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 2, 0, "20", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 3, 0, "50", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 4, 0, "100", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 5, 0, "200", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)

    f_row(1, "M1", m1_10, m1_20, m1_50, m1_100, m1_200)
    f_row(2, "M5", m5_10, m5_20, m5_50, m5_100, m5_200)
    f_row(3, "M15", m15_10, m15_20, m15_50, m15_100, m15_200)
    f_row(4, "M30", m30_10, m30_20, m30_50, m30_100, m30_200)
    f_row(5, "H1", h1_10, h1_20, h1_50, h1_100, h1_200)
    f_row(6, "H4", h4_10, h4_20, h4_50, h4_100, h4_200)
    f_row(7, "D", d_10, d_20, d_50, d_100, d_200)

    table.cell(t, 0, 8, "SCORE", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 1, 8, str.tostring(score, "#"), text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
    table.cell(t, 2, 8, "BIAS", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 3, 8, bias, text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
    table.cell(t, 4, 8, "CONF", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 5, 8, str.tostring(confidence, "#") + "%", text_color=color.white, bgcolor=biasColor, text_size=size.tiny)

    table.cell(t, 0, 9, "MAIN", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 1, 9, f_tfName(mainTFInput), text_color=color.white, bgcolor=color.rgb(40,40,60), text_size=size.tiny)
    table.cell(t, 2, 9, "PHASE", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 3, 9, phase, text_color=color.white, bgcolor=biasColor, text_size=size.tiny)
    table.cell(t, 4, 9, "SIGNAL", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 5, 9, buySignal ? "BUY" : sellSignal ? "SELL" : "WAIT", text_color=color.white, bgcolor=buySignal ? color.lime : sellSignal ? color.red : color.orange, text_size=size.tiny)
````
