# Roy Gravity Matrix AI V2

- url: https://www.tradingview.com/script/wiEd5pdk-Roy-Gravity-Matrix-AI-V2/
- type: indicator
- pine_id: PUB;849cbf1b29ae43b99ae6f9030f1e1556
- version: 1.0

## Description

ROY GRAVITY MATRIX AI V2

Roy Gravity Matrix AI V2 is an advanced adaptive multi-timeframe trading engine designed to analyze market gravity, trend structure, momentum transition, and EMA alignment using a mathematical matrix-based system.

This indicator combines:

• Multi-Timeframe EMA Analysis
• Adaptive Main Timeframe Logic
• Trend Gravity Detection
• Momentum Transition Matrix
• EMA Cross Heat Alerts
• AI Market Phase Detection
• Mathematical Trend Scoring

into a single smart trading dashboard optimized for both desktop and mobile TradingView users.

━━━━━━━━━━━━━━━━━━
CORE CONCEPT
━━━━━━━━━━━━━━━━━━

Roy Gravity Matrix AI V2 is built around the concept that:

“Higher timeframe trend acts like gravity and influences lower timeframe movement.”

Higher timeframe structure such as H4 and Daily carries stronger influence over lower timeframes like M1 and M5.

The indicator transforms bullish and bearish market conditions into weighted mathematical scores to help traders identify:

• Dominant Trend Direction
• Pullbacks Against Trend
• Momentum Expansion
• Market Transition
• Early Reversal Pressure
• Smart Entry Timing

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Adaptive Main Timeframe System
• EMA 10 / 20 / 50 / 100 / 200 Matrix
• Multi-Timeframe Heatmap
• Gravity Trend Engine
• AI Trend Score
• AI Confidence Level
• Market Phase Detection
• Smart Buy & Sell Signals
• EMA Cross Heat Alert System
• Momentum Transition Detection
• Mobile-Friendly Dashboard

━━━━━━━━━━━━━━━━━━
EMA CROSS HEAT ALERT SYSTEM
━━━━━━━━━━━━━━━━━━

The indicator introduces a dynamic EMA Cross Heat Alert system directly inside the matrix.

Each EMA box can change color individually when fresh EMA cross momentum occurs.

COLORS:

🟩 Green
= Normal Bullish Condition

🟥 Red
= Normal Bearish Condition

🟨 Yellow
= Fresh Bullish EMA Cross

🟧 Orange
= Fresh Bearish EMA Cross

This allows traders to instantly detect:

• Fresh momentum shifts
• New bullish expansion
• New bearish expansion
• EMA transition zones
• Early reversal signals

without cluttering the chart with excessive labels.

━━━━━━━━━━━━━━━━━━
ADAPTIVE MAIN TIMEFRAME
━━━━━━━━━━━━━━━━━━

Users can select their preferred trading timeframe:

• M1
• M5
• M15
• M30
• H1
• H4
• Daily

The AI engine automatically adjusts:

• Gravity Timeframes
• Momentum Structure
• Trigger Logic
• Signal Timing

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
MARKET PHASES
━━━━━━━━━━━━━━━━━━

BULL EXP
= Strong bullish expansion

BULL PULL
= Bullish pullback inside bullish gravity

BEAR EXP
= Strong bearish expansion

BEAR PULL
= Bearish pullback inside bearish gravity

MIXED
= Mixed or conflicting market structure

━━━━━━━━━━━━━━━━━━
HOW TO READ THE MATRIX
━━━━━━━━━━━━━━━━━━

The matrix displays EMA structure across multiple timeframes.

Each row represents timeframe.

Each column represents EMA level.

• EMA10 = Fast Momentum
• EMA20 = Short Momentum
• EMA50 = Medium Trend
• EMA100 = Strong Trend Structure
• EMA200 = Institutional Trend

━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━

BUY SETUP

Look for:

• Score positive
• Bias bullish
• Gravity aligned bullish
• Main timeframe bullish
• Multiple yellow boxes appearing from lower TF upward

This often indicates momentum expansion is spreading upward.

━━━━━━━━━━━━━━━━━━

SELL SETUP

Look for:

• Score negative
• Bias bearish
• Gravity aligned bearish
• Main timeframe bearish
• Multiple orange boxes appearing from lower TF upward

This often indicates bearish pressure spreading downward.

━━━━━━━━━━━━━━━━━━
MOMENTUM TRANSITION CONCEPT
━━━━━━━━━━━━━━━━━━

One of the most powerful concepts in this indicator is momentum spreading.

Example:

M1 yellow → M5 yellow → M15 yellow

This may indicate bullish momentum is expanding through multiple timeframes.

The same concept applies for bearish momentum using orange heat boxes.

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
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━

This indicator is designed as a trend and momentum analysis engine.

It should be used together with:

• Market structure
• Support & resistance
• Risk management
• Proper trade confirmation

for best trading performance.

## Source Code

````pine
//@version=6
indicator("Roy Gravity Matrix AI V2", overlay=true, max_labels_count=100)

// ================= INPUT =================
mainTFInput = input.string("15", "Main Timeframe", options=["1", "5", "15", "30", "60", "240", "D"])
showTable   = input.bool(true, "Show Gravity Matrix")
showEMA     = input.bool(true, "Show EMA Current Chart")
showSignal  = input.bool(true, "Show Buy/Sell Signal")
crossLookback = input.int(3, "EMA Cross Highlight Bars", minval=1, maxval=20)

tablePosInp = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Bottom Right"])
tablePos = tablePosInp == "Top Center" ? position.top_center : tablePosInp == "Bottom Right" ? position.bottom_right : position.top_right

// ================= EMA CURRENT CHART =================
plot(showEMA ? ta.ema(close, 10) : na, "EMA 10", color=color.aqua)
plot(showEMA ? ta.ema(close, 20) : na, "EMA 20", color=color.orange)
plot(showEMA ? ta.ema(close, 50) : na, "EMA 50", color=color.yellow)
plot(showEMA ? ta.ema(close, 100) : na, "EMA 100", color=color.blue)
plot(showEMA ? ta.ema(close, 200) : na, "EMA 200", color=color.purple)

// ================= FUNCTIONS =================
f_recent(cond) =>
    not na(ta.barssince(cond)) and ta.barssince(cond) <= crossLookback

f_pack() =>
    e10 = ta.ema(close, 10)
    e20 = ta.ema(close, 20)
    e50 = ta.ema(close, 50)
    e100 = ta.ema(close, 100)
    e200 = ta.ema(close, 200)

    d10 = close > e10 ? 1 : -1
    d20 = close > e20 ? 1 : -1
    d50 = close > e50 ? 1 : -1
    d100 = close > e100 ? 1 : -1
    d200 = close > e200 ? 1 : -1

    bull10 = f_recent(ta.crossover(e10, e20) or ta.crossover(e10, e50) or ta.crossover(e10, e100) or ta.crossover(e10, e200))
    bear10 = f_recent(ta.crossunder(e10, e20) or ta.crossunder(e10, e50) or ta.crossunder(e10, e100) or ta.crossunder(e10, e200))

    bull20 = f_recent(ta.crossover(e20, e10) or ta.crossover(e20, e50) or ta.crossover(e20, e100) or ta.crossover(e20, e200))
    bear20 = f_recent(ta.crossunder(e20, e10) or ta.crossunder(e20, e50) or ta.crossunder(e20, e100) or ta.crossunder(e20, e200))

    bull50 = f_recent(ta.crossover(e50, e10) or ta.crossover(e50, e20) or ta.crossover(e50, e100) or ta.crossover(e50, e200))
    bear50 = f_recent(ta.crossunder(e50, e10) or ta.crossunder(e50, e20) or ta.crossunder(e50, e100) or ta.crossunder(e50, e200))

    bull100 = f_recent(ta.crossover(e100, e10) or ta.crossover(e100, e20) or ta.crossover(e100, e50) or ta.crossover(e100, e200))
    bear100 = f_recent(ta.crossunder(e100, e10) or ta.crossunder(e100, e20) or ta.crossunder(e100, e50) or ta.crossunder(e100, e200))

    bull200 = f_recent(ta.crossover(e200, e10) or ta.crossover(e200, e20) or ta.crossover(e200, e50) or ta.crossover(e200, e100))
    bear200 = f_recent(ta.crossunder(e200, e10) or ta.crossunder(e200, e20) or ta.crossunder(e200, e50) or ta.crossunder(e200, e100))

    c10 = bull10 ? 1 : bear10 ? -1 : 0
    c20 = bull20 ? 1 : bear20 ? -1 : 0
    c50 = bull50 ? 1 : bear50 ? -1 : 0
    c100 = bull100 ? 1 : bear100 ? -1 : 0
    c200 = bull200 ? 1 : bear200 ? -1 : 0

    [d10, d20, d50, d100, d200, c10, c20, c50, c100, c200]

f_bg(dir, cross) =>
    cross == 1 ? color.yellow :
     cross == -1 ? color.orange :
     dir == 1 ? color.lime :
     color.red

f_tfName(tf) =>
    tf == "1" ? "M1" :
     tf == "5" ? "M5" :
     tf == "15" ? "M15" :
     tf == "30" ? "M30" :
     tf == "60" ? "H1" :
     tf == "240" ? "H4" : "D"

// ================= MTF DATA =================
[m1_10, m1_20, m1_50, m1_100, m1_200, m1c10, m1c20, m1c50, m1c100, m1c200] = request.security(syminfo.tickerid, "1", f_pack())
[m5_10, m5_20, m5_50, m5_100, m5_200, m5c10, m5c20, m5c50, m5c100, m5c200] = request.security(syminfo.tickerid, "5", f_pack())
[m15_10, m15_20, m15_50, m15_100, m15_200, m15c10, m15c20, m15c50, m15c100, m15c200] = request.security(syminfo.tickerid, "15", f_pack())
[m30_10, m30_20, m30_50, m30_100, m30_200, m30c10, m30c20, m30c50, m30c100, m30c200] = request.security(syminfo.tickerid, "30", f_pack())
[h1_10, h1_20, h1_50, h1_100, h1_200, h1c10, h1c20, h1c50, h1c100, h1c200] = request.security(syminfo.tickerid, "60", f_pack())
[h4_10, h4_20, h4_50, h4_100, h4_200, h4c10, h4c20, h4c50, h4c100, h4c200] = request.security(syminfo.tickerid, "240", f_pack())
[d_10, d_20, d_50, d_100, d_200, dc10, dc20, dc50, dc100, dc200] = request.security(syminfo.tickerid, "D", f_pack())

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
main20 = mainTFInput == "1" ? m1_20 : mainTFInput == "5" ? m5_20 : mainTFInput == "15" ? m15_20 : mainTFInput == "30" ? m30_20 : mainTFInput == "60" ? h1_20 : mainTFInput == "240" ? h4_20 : d_20
main50 = mainTFInput == "1" ? m1_50 : mainTFInput == "5" ? m5_50 : mainTFInput == "15" ? m15_50 : mainTFInput == "30" ? m30_50 : mainTFInput == "60" ? h1_50 : mainTFInput == "240" ? h4_50 : d_50

triggerBull = mainTFInput == "1" ? m1_20 == 1 : mainTFInput == "5" ? m1_20 == 1 : mainTFInput == "15" ? m5_20 == 1 : mainTFInput == "30" ? m15_20 == 1 : mainTFInput == "60" ? m30_20 == 1 : mainTFInput == "240" ? h1_20 == 1 : h4_20 == 1
triggerBear = mainTFInput == "1" ? m1_20 == -1 : mainTFInput == "5" ? m1_20 == -1 : mainTFInput == "15" ? m5_20 == -1 : mainTFInput == "30" ? m15_20 == -1 : mainTFInput == "60" ? m30_20 == -1 : mainTFInput == "240" ? h1_20 == -1 : h4_20 == -1

gravityBull = h4_50 == 1 and d_50 == 1
gravityBear = h4_50 == -1 and d_50 == -1

bias = score > 1000 ? "SUPER BULL" : score > 0 ? "BULL" : score < -1000 ? "SUPER BEAR" : score < 0 ? "BEAR" : "SIDEWAY"

phase =
     gravityBull and main20 == 1 and triggerBull ? "BULL EXP" :
     gravityBull and main20 == -1 ? "BULL PULL" :
     gravityBear and main20 == -1 and triggerBear ? "BEAR EXP" :
     gravityBear and main20 == 1 ? "BEAR PULL" :
     "MIXED"

biasColor = score > 0 ? color.lime : score < 0 ? color.red : color.orange

buySignal = score > 0 and main20 == 1 and main50 == 1 and triggerBull
sellSignal = score < 0 and main20 == -1 and main50 == -1 and triggerBear

plotshape(showSignal and buySignal, title="Matrix BUY", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.lime, text="BUY")
plotshape(showSignal and sellSignal, title="Matrix SELL", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.red, text="SELL")

alertcondition(buySignal, title="Roy Matrix BUY", message="Roy Gravity Matrix AI V2: BUY Signal")
alertcondition(sellSignal, title="Roy Matrix SELL", message="Roy Gravity Matrix AI V2: SELL Signal")

// ================= TABLE =================
var table t = table.new(tablePos, 6, 10, border_width=1)

f_row(row, tfName, a, b, c, d, e, ca, cb, cc, cd, ce) =>
    table.cell(t, 0, row, tfName, text_color=color.white, bgcolor=color.rgb(35,35,45), text_size=size.tiny)
    table.cell(t, 1, row, "●", text_color=color.rgb(30,30,30), bgcolor=f_bg(a, ca), text_size=size.tiny)
    table.cell(t, 2, row, "●", text_color=color.rgb(30,30,30), bgcolor=f_bg(b, cb), text_size=size.tiny)
    table.cell(t, 3, row, "●", text_color=color.rgb(30,30,30), bgcolor=f_bg(c, cc), text_size=size.tiny)
    table.cell(t, 4, row, "●", text_color=color.rgb(30,30,30), bgcolor=f_bg(d, cd), text_size=size.tiny)
    table.cell(t, 5, row, "●", text_color=color.rgb(30,30,30), bgcolor=f_bg(e, ce), text_size=size.tiny)

if barstate.islast and showTable
    table.cell(t, 0, 0, "TF", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 1, 0, "10", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 2, 0, "20", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 3, 0, "50", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 4, 0, "100", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)
    table.cell(t, 5, 0, "200", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=size.tiny)

    f_row(1, "M1", m1_10, m1_20, m1_50, m1_100, m1_200, m1c10, m1c20, m1c50, m1c100, m1c200)
    f_row(2, "M5", m5_10, m5_20, m5_50, m5_100, m5_200, m5c10, m5c20, m5c50, m5c100, m5c200)
    f_row(3, "M15", m15_10, m15_20, m15_50, m15_100, m15_200, m15c10, m15c20, m15c50, m15c100, m15c200)
    f_row(4, "M30", m30_10, m30_20, m30_50, m30_100, m30_200, m30c10, m30c20, m30c50, m30c100, m30c200)
    f_row(5, "H1", h1_10, h1_20, h1_50, h1_100, h1_200, h1c10, h1c20, h1c50, h1c100, h1c200)
    f_row(6, "H4", h4_10, h4_20, h4_50, h4_100, h4_200, h4c10, h4c20, h4c50, h4c100, h4c200)
    f_row(7, "D", d_10, d_20, d_50, d_100, d_200, dc10, dc20, dc50, dc100, dc200)

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
