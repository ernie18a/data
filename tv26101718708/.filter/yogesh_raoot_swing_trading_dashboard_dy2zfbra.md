# Yogesh Raoot Swing Trading Dashboard

- url: https://www.tradingview.com/script/dy2zFbrA-Yogesh-Raoot-Swing-Trading-Dashboard/
- type: indicator
- pine_id: PUB;5ef41e6f2ea44a2fba6e57854293f6b6
- version: 1.0

## Description

Overview
This is a high-probability swing trading dashboard designed to identify stocks capable of achieving 5% to 7% gains within a 7–10 day window. The indicator utilizes a multi-factor "AI-style" scoring system based on trend, momentum, and volatility.

Key Features:

Weighted Scoring: Evaluates EMA Trend, RSI, MACD, Supertrend, and Momentum to provide a total score out of 100.

Probability Matrix: Classifies setups into HIGH, MEDIUM, or LOW probability.

Visual Verdict: Provides a clear "Strong Buy" or "Neutral" signal based on technical confluence.

Expected Move: Estimates the potential percentage gain over the next week.

How to Use:

Best used on Daily (1D) or 4-Hour (4H) timeframes.

Look for a Total Score > 75 for the highest probability of a 5%+ move.

Use the plotted EMA 20 (Blue) and EMA 50 (Orange) for dynamic support and resistance.

Disclaimer: Trading involves risk. This dashboard is a decision-support tool and should be used in conjunction with your own risk management.

## Source Code

````pine
//@version=5
indicator("Yogesh Raoot Swing Dashboard", overlay=true)

// ==========================================
// 1. INPUTS & PARAMETERS
// ==========================================
emaFastLen = input.int(20, "EMA Fast", group="Indicators")
emaSlowLen = input.int(50, "EMA Slow", group="Indicators")
rsiLen     = input.int(14, "RSI Length", group="Indicators")
momLen     = input.int(5,  "Momentum Length", group="Indicators")
stMult     = input.float(3.0, "Supertrend Multiplier", group="Indicators")
stPeriod   = input.int(10, "Supertrend Period", group="Indicators")

// Dashboard UI Settings
dbPos      = input.string("Top Right", "Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"])
dbColor    = input.color(color.new(color.black, 10), "Dashboard BG")

// ==========================================
// 2. CALCULATIONS
// ==========================================
// EMA Trend
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaTrend = close > emaFast and emaFast > emaSlow ? "BULLISH" : "BEARISH"
emaTrendColor = emaTrend == "BULLISH" ? color.green : color.red

// RSI
rsiVal = ta.rsi(close, rsiLen)

// MACD
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
macdStatus = macdLine > signalLine ? "BULLISH" : "BEARISH"
macdColor  = macdStatus == "BULLISH" ? color.green : color.red

// Volume
volAvg = ta.sma(volume, 20)
volStatus = volume > volAvg * 1.5 ? "HIGH" : "NORMAL"
volColor  = volStatus == "HIGH" ? color.green : color.orange

// Supertrend
[stValue, stDirection] = ta.supertrend(stMult, stPeriod)
stStatus = stDirection < 0 ? "BUY" : "SELL"
stColor  = stStatus == "BUY" ? color.green : color.red

// Momentum
mom = ta.mom(close, momLen)
momPerc = (mom / close[momLen]) * 100

// Bollinger Bands Position
[bbUpper, bbMiddle, bbLower] = ta.bb(close, 20, 2)
bbPosStatus = close > bbUpper ? "STRONG" : close < bbLower ? "WEAK" : "NEUTRAL"
bbPosColor  = bbPosStatus == "STRONG" ? color.green : bbPosStatus == "WEAK" ? color.red : color.gray

// ==========================================
// 3. SCORING SYSTEM
// ==========================================
int score = 0
score += (emaTrend == "BULLISH" ? 15 : 0)
score += (rsiVal > 50 and rsiVal < 70 ? 15 : 0)
score += (macdStatus == "BULLISH" ? 15 : 0)
score += (stStatus == "BUY" ? 20 : 0)
score += (momPerc > 0 ? 15 : 0)
score += (bbPosStatus == "STRONG" ? 20 : 0)

string probability = score > 80 ? "HIGH" : score > 50 ? "MEDIUM" : "LOW"
string verdict = score > 75 ? "STRONG BUY" : score > 50 ? "NEUTRAL" : "WEAK SETUP"
string expectedMove = score > 75 ? "5% - 7%" : score > 50 ? "2% - 4%" : "< 2%"

color scoreColor = score > 75 ? color.green : score > 50 ? color.orange : color.red

// ==========================================
// 4. DASHBOARD RENDERING
// ==========================================
var table dash = table.new(position.top_right, 2, 12, bgcolor=dbColor, border_width=1, border_color=color.gray)

if barstate.islast
    // Header - UPDATED AS REQUESTED
    table.cell(dash, 0, 0, "YOGESH RAOOT SWING DASHBOARD", text_color=color.white, bgcolor=color.new(color.blue, 20), text_size=size.small)
    table.merge_cells(dash, 0, 0, 1, 0)
    
    // Probability Row
    table.cell(dash, 0, 1, "PROBABILITY", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 1, probability, bgcolor=scoreColor, text_color=color.white)

    // Indicator Rows
    table.cell(dash, 0, 2, "📈 EMA Trend", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 2, emaTrend, bgcolor=emaTrendColor, text_color=color.white)

    table.cell(dash, 0, 3, "📊 RSI (14)", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(rsiVal, "#.##"), bgcolor=color.gray, text_color=color.white)

    table.cell(dash, 0, 4, "🎯 MACD", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 4, macdStatus, bgcolor=macdColor, text_color=color.white)

    table.cell(dash, 0, 5, "🔊 Volume", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 5, volStatus, bgcolor=volColor, text_color=color.white)

    table.cell(dash, 0, 6, "⬆️ Supertrend", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 6, stStatus, bgcolor=stColor, text_color=color.white)

    table.cell(dash, 0, 7, "⚡ Momentum", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(momPerc, "#.##") + "%", bgcolor=color.gray, text_color=color.white)

    table.cell(dash, 0, 8, "⭕ BB Position", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 8, bbPosStatus, bgcolor=bbPosColor, text_color=color.white)

    // Total Score
    table.cell(dash, 0, 9, "TOTAL SCORE", bgcolor=color.blue, text_color=color.white)
    table.cell(dash, 1, 9, str.tostring(score) + " / 100", bgcolor=color.blue, text_color=color.white)

    // Verdict
    table.cell(dash, 0, 10, "VERDICT", text_color=color.white)
    table.cell(dash, 1, 10, verdict, bgcolor=scoreColor, text_color=color.white)

    // Expected Move
    table.cell(dash, 0, 11, "EXPECTED MOVE (7-10 DAYS)", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 11, expectedMove, bgcolor=color.purple, text_color=color.white)

// Plotting the EMAs
plot(emaFast, color=color.blue, title="EMA 20")
plot(emaSlow, color=color.orange, title="EMA 50")
````
