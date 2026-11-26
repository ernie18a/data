# Infinity Signal MACD Consensus Table

- url: https://www.tradingview.com/script/6bANUCmB-Infinity-Signal-MACD-Consensus-Table/
- type: indicator
- pine_id: PUB;3cbb4ab5339e48328371dba518adb276
- version: 1.0

## Description

The Infinity Signal — MACD Consensus Table is a multi-timeframe momentum confirmation tool designed to answer a simple question:

How much agreement exists across the market before taking a trade?

Instead of relying on a single MACD reading, this indicator evaluates MACD direction across five timeframes and combines them into a weighted consensus score.

Timeframe Weights
1 Hour = 10%
4 Hour = 25%
Daily = 40%
Weekly = 20%
Monthly = 5%
What the Indicator Does
Calculates MACD direction for five timeframes simultaneously.
Displays Bullish and Bearish consensus percentages.
Assigns signal grades from A+ through F based on timeframe alignment.
Generates Buy and Sell consensus balloons when the consensus threshold is reached.
Optionally shades bullish and bearish market zones directly on the chart.
Displays each timeframe's MACD status, signal status, and zero-line position in a compact dashboard.
Signal Logic

A bullish signal is generated when bullish consensus reaches the selected threshold and exceeds bearish consensus.

A bearish signal is generated when bearish consensus reaches the selected threshold and exceeds bullish consensus.

Grade System
A+ = Strong High-Timeframe Agreement
A = High and Low Timeframe Agreement
B = Moderate Agreement
C = Primarily Low-Timeframe Agreement
D = Weak Agreement
F = Very Weak Agreement
How It Is Intended To Be Used

This indicator was designed as a confirmation tool rather than a standalone trading system.

Many traders use it alongside:

MACD
Moving Averages
Stochastic RSI
Trend Analysis
Support and Resistance
Price Action

The strongest signals typically occur when consensus agreement aligns with a separate trading methodology.

Why This Indicator Exists

Traditional MACD indicators only evaluate a single timeframe.

The MACD Consensus Table was created to provide a quick visual representation of whether momentum is aligned across multiple timeframes before a trade decision is made.

Notes
Background shading is optional.
Buy and Sell balloons are optional.
Threshold levels are user configurable.
Designed for use on all markets and timeframes supported by TradingView.

This script is provided for educational and informational purposes only. It is not financial advice. Always do your own research before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Infinity Signal — MACD Consensus Table", overlay=true, max_labels_count=500, max_bars_back=5000)

// ====================== INPUTS ======================
fastLen   = input.int(12, "MACD Fast Length", minval=1)
slowLen   = input.int(26, "MACD Slow Length", minval=1)
signalLen = input.int(9,  "MACD Signal Length", minval=1)

bullThreshold = input.float(70.0, "Bullish Consensus Threshold", minval=0, maxval=100)
bearThreshold = input.float(70.0, "Bearish Consensus Threshold", minval=0, maxval=100)

showTable = input.bool(true, "Show MACD Consensus Table")
showBalloons = input.bool(true, "Show Buy / Sell Balloons")
showShading = input.bool(true, "Show Bull / Bear Background Shading")

balloonOffsetATR = input.float(1.5, "Balloon Vertical Offset ATR", minval=0.1, step=0.1)
atrLen = input.int(14, "ATR Length", minval=1)

bullShadeColor = input.color(color.new(color.green, 85), "Bullish Zone Shading")
bearShadeColor = input.color(color.new(color.red, 85), "Bearish Zone Shading")

buyBalloonColor = input.color(color.new(color.green, 0), "Buy Balloon Color")
sellBalloonColor = input.color(color.new(color.red, 0), "Sell Balloon Color")
balloonTextColor = input.color(color.white, "Balloon Text Color")

// ====================== WEIGHTS ======================
w1H = 10.0
w4H = 25.0
w1D = 40.0
w1W = 20.0
w1M = 5.0

// ====================== MACD FUNCTIONS ======================
macdLine(src) =>
    ta.ema(src, fastLen) - ta.ema(src, slowLen)

signalLine(src) =>
    ta.ema(macdLine(src), signalLen)

getTF(tf) =>
    m = request.security(syminfo.tickerid, tf, macdLine(close), barmerge.gaps_off, barmerge.lookahead_off)
    s = request.security(syminfo.tickerid, tf, signalLine(close), barmerge.gaps_off, barmerge.lookahead_off)
    [m, s]

// ====================== TIMEFRAMES ======================
[M_1H, S_1H] = getTF("60")
[M_4H, S_4H] = getTF("240")
[M_1D, S_1D] = getTF("D")
[M_1W, S_1W] = getTF("W")
[M_1M, S_1M] = getTF("M")

// ====================== HELPERS ======================
dirFromMACD(m, s) =>
    m > s ? "Bull" : m < s ? "Bear" : "Mix"

zoneFromMACD(m) =>
    m > 0 ? "Above Zero" : m < 0 ? "Below Zero" : "Zero"

bgFromDir(dir) =>
    dir == "Bull" ? color.new(color.green, 0) : dir == "Bear" ? color.new(color.red, 0) : color.new(color.gray, 75)

getBullWeight(dir, w) =>
    dir == "Bull" ? w : dir == "Mix" ? w * 0.5 : 0.0

getBearWeight(dir, w) =>
    dir == "Bear" ? w : dir == "Mix" ? w * 0.5 : 0.0

// ====================== CONSENSUS LOGIC ======================
dir1H = dirFromMACD(M_1H, S_1H)
dir4H = dirFromMACD(M_4H, S_4H)
dir1D = dirFromMACD(M_1D, S_1D)
dir1W = dirFromMACD(M_1W, S_1W)
dir1M = dirFromMACD(M_1M, S_1M)

zone1H = zoneFromMACD(M_1H)
zone4H = zoneFromMACD(M_4H)
zone1D = zoneFromMACD(M_1D)
zone1W = zoneFromMACD(M_1W)
zone1M = zoneFromMACD(M_1M)

bullWeight =
     getBullWeight(dir1H, w1H) +
     getBullWeight(dir4H, w4H) +
     getBullWeight(dir1D, w1D) +
     getBullWeight(dir1W, w1W) +
     getBullWeight(dir1M, w1M)

bearWeight =
     getBearWeight(dir1H, w1H) +
     getBearWeight(dir4H, w4H) +
     getBearWeight(dir1D, w1D) +
     getBearWeight(dir1W, w1W) +
     getBearWeight(dir1M, w1M)

bullSignal = bullWeight >= bullThreshold and bullWeight > bearWeight
bearSignal = bearWeight >= bearThreshold and bearWeight > bullWeight

bullStart = bullSignal and not bullSignal[1]
bearStart = bearSignal and not bearSignal[1]

// ====================== GRADE ======================
signalDir = bullSignal ? "Bull" : bearSignal ? "Bear" : "None"

alignedHigh = 0
if signalDir != "None"
    alignedHigh += dir1D == signalDir ? 1 : 0
    alignedHigh += dir1W == signalDir ? 1 : 0
    alignedHigh += dir1M == signalDir ? 1 : 0

alignedLow = 0
if signalDir != "None"
    alignedLow += dir1H == signalDir ? 1 : 0
    alignedLow += dir4H == signalDir ? 1 : 0

grade = "N/A"
if signalDir != "None"
    grade := alignedHigh >= 2 ? "A+" :
             alignedHigh == 1 and alignedLow >= 1 ? "A" :
             alignedHigh == 1 ? "B" :
             alignedLow >= 2 ? "C" :
             alignedLow == 1 ? "D" : "F"

signalText = bullSignal ? "Bull Signal ≥70%" :
             bearSignal ? "Bear Signal ≥70%" :
             "No Signal"

interp = bullSignal ? "Bull " + grade + " — Strong High-TF" :
         bearSignal ? "Bear " + grade + " — Strong High-TF" :
         "Neutral — No Signal"

// ====================== BACKGROUND SHADING ======================
bgcolor(showShading and bullSignal ? bullShadeColor : na)
bgcolor(showShading and bearSignal ? bearShadeColor : na)

// ====================== BALLOONS ======================
atr = ta.atr(atrLen)

if showBalloons and bullStart
    label.new(
         bar_index,
         low - atr * balloonOffsetATR,
         "BUY\nConsensus Bullish\n" + str.tostring(bullWeight, "#") + "% Bullish\nGrade: " + grade,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=buyBalloonColor,
         textcolor=balloonTextColor,
         size=size.normal
    )

if showBalloons and bearStart
    label.new(
         bar_index,
         high + atr * balloonOffsetATR,
         "SELL\nConsensus Bearish\n" + str.tostring(bearWeight, "#") + "% Bearish\nGrade: " + grade,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=sellBalloonColor,
         textcolor=balloonTextColor,
         size=size.normal
    )

// ====================== ALERTS ======================
alertcondition(bullStart, "MACD Consensus Buy", "MACD Consensus turned bullish.")
alertcondition(bearStart, "MACD Consensus Sell", "MACD Consensus turned bearish.")

// ====================== TABLE ======================
var table t = table.new(position.top_right, 6, 9, border_width=1, frame_color=color.new(color.white, 70))

makeRow(row, tf, m, s, dir, zone, w) =>
    bg = bgFromDir(dir)
    table.cell(t, 0, row, tf, text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, row, str.tostring(m, "#.0000"), text_color=color.white, bgcolor=bg)
    table.cell(t, 2, row, str.tostring(s, "#.0000"), text_color=color.white, bgcolor=bg)
    table.cell(t, 3, row, dir, text_color=color.white, bgcolor=bg)
    table.cell(t, 4, row, zone, text_color=color.white, bgcolor=bg)
    table.cell(t, 5, row, str.tostring(w, "#") + "%", text_color=color.white, bgcolor=color.black)

if showTable
    table.cell(t, 0, 0, "TF", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, "MACD", text_color=color.white, bgcolor=color.black)
    table.cell(t, 2, 0, "Signal", text_color=color.white, bgcolor=color.black)
    table.cell(t, 3, 0, "Dir", text_color=color.white, bgcolor=color.black)
    table.cell(t, 4, 0, "Zone", text_color=color.white, bgcolor=color.black)
    table.cell(t, 5, 0, "Wgt%", text_color=color.white, bgcolor=color.black)

    makeRow(1, "1H", M_1H, S_1H, dir1H, zone1H, w1H)
    makeRow(2, "4H", M_4H, S_4H, dir4H, zone4H, w4H)
    makeRow(3, "1D", M_1D, S_1D, dir1D, zone1D, w1D)
    makeRow(4, "1W", M_1W, S_1W, dir1W, zone1W, w1W)
    makeRow(5, "1M", M_1M, S_1M, dir1M, zone1M, w1M)

    sigBg = bullSignal ? color.green : bearSignal ? color.red : color.gray

    table.cell(t, 0, 6, "Weights", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 6, "Bull: " + str.tostring(bullWeight, "#") + "% / Bear: " + str.tostring(bearWeight, "#") + "%", text_color=color.white, bgcolor=color.black)
    table.merge_cells(t, 1, 6, 5, 6)

    table.cell(t, 0, 7, "Signal", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 7, signalText, text_color=color.white, bgcolor=sigBg)
    table.merge_cells(t, 1, 7, 3, 7)

    table.cell(t, 4, 7, "Grade: " + grade, text_color=color.white, bgcolor=sigBg)
    table.merge_cells(t, 4, 7, 5, 7)

    table.cell(t, 0, 8, "Interp", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 8, interp, text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.merge_cells(t, 1, 8, 5, 8)
````
