# Elaris Smart Scalping Indicator

- url: https://www.tradingview.com/script/hZ2V1iv9-Elaris-Smart-Scalping-Indicator/
- type: indicator
- pine_id: PUB;b98a576390f14e85a350484925f0aa6d
- version: 1.0

## Description

Elaris Smart Scalping Indicator is a non-repainting trend and momentum scalping tool designed to help traders identify higher-quality buy and sell conditions using a structured confluence model.

The indicator combines EMA trend direction, RSI momentum, MACD histogram confirmation, volume strength, ATR volatility filtering, optional higher-timeframe bias, and session filtering into a clean signal-scoring system. Signals are confirmed only after candle close, helping reduce intrabar noise and repainting behavior.

It also includes visual TP/SL guide levels, trend background shading, buy/sell labels, alert conditions, and a compact dashboard showing trend state, HTF bias, RSI, ATR percentage, volume filter status, and signal score.

This tool is designed for scalping and short-term trading analysis across crypto, forex, indices, and other liquid markets. It is not financial advice and should be used with proper risk management and additional market context.

Key Features

Non-repainting confirmed buy/sell signals
EMA-based trend engine with adjustable strictness
RSI and MACD momentum confirmation
Optional higher-timeframe trend filter
Volume and ATR volatility quality filters
Optional session filter
Signal score system from 0–100
Visual entry, stop loss, TP1, and TP2 guide levels
Clean dashboard for live market state
Built-in TradingView alert conditions

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ElarisGroup

//@version=5
indicator("Elaris Smart Scalping Indicator", shorttitle="Elaris Smart Scalper", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Elaris Group — Smart Scalping Indicator
// Non-repainting scalping signals with:
// Trend + Momentum + Volume + ATR + MTF confirmation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupTrend = "01. Trend Engine"
fastLen = input.int(21, "Fast EMA", minval=1, group=groupTrend)
slowLen = input.int(55, "Slow EMA", minval=1, group=groupTrend)
trendStrictness = input.string("Balanced", "Trend Strictness", options=["Aggressive", "Balanced", "Strict"], group=groupTrend)

groupMTF = "02. Higher Timeframe Confirmation"
useHTF = input.bool(true, "Use HTF Confirmation", group=groupMTF)
htfTf = input.timeframe("15", "HTF Timeframe", group=groupMTF)
htfEmaLen = input.int(100, "HTF EMA Length", minval=1, group=groupMTF)

groupMomentum = "03. Momentum Engine"
rsiLen = input.int(14, "RSI Length", minval=1, group=groupMomentum)
rsiBull = input.int(55, "Bullish RSI Level", minval=1, maxval=100, group=groupMomentum)
rsiBear = input.int(45, "Bearish RSI Level", minval=1, maxval=100, group=groupMomentum)

macdFast = input.int(12, "MACD Fast", minval=1, group=groupMomentum)
macdSlow = input.int(26, "MACD Slow", minval=1, group=groupMomentum)
macdSignal = input.int(9, "MACD Signal", minval=1, group=groupMomentum)

groupFilters = "04. Quality Filters"
useVolumeFilter = input.bool(true, "Use Volume Filter", group=groupFilters)
volLen = input.int(20, "Volume MA Length", minval=1, group=groupFilters)
volMultiplier = input.float(1.1, "Volume Strength Multiplier", minval=0.1, step=0.1, group=groupFilters)

useAtrFilter = input.bool(true, "Use ATR Volatility Filter", group=groupFilters)
atrLen = input.int(14, "ATR Length", minval=1, group=groupFilters)
minAtrPercent = input.float(0.08, "Minimum ATR %", minval=0.01, step=0.01, group=groupFilters)

useSessionFilter = input.bool(false, "Use Session Filter", group=groupFilters)
tradeSession = input.session("0800-1700", "Trading Session", group=groupFilters)

groupRisk = "05. TP / SL Visual Guide"
showRiskLevels = input.bool(true, "Show TP / SL Levels", group=groupRisk)
slAtrMult = input.float(1.2, "Stop Loss ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)
tp1RR = input.float(1.0, "TP1 Risk Reward", minval=0.1, step=0.1, group=groupRisk)
tp2RR = input.float(2.0, "TP2 Risk Reward", minval=0.1, step=0.1, group=groupRisk)

groupSignals = "06. Signals"
minScore = input.int(70, "Minimum Signal Score", minval=1, maxval=100, group=groupSignals)
showLabels = input.bool(true, "Show Buy/Sell Labels", group=groupSignals)
showBackground = input.bool(true, "Show Trend Background", group=groupSignals)

groupDashboard = "07. Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=groupDashboard)
dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDashboard)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

rsi = ta.rsi(close, rsiLen)
[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)

atr = ta.atr(atrLen)
atrPercent = atr / close * 100

volMa = ta.sma(volume, volLen)
volOk = not useVolumeFilter or volume > volMa * volMultiplier

atrOk = not useAtrFilter or atrPercent >= minAtrPercent

sessionOk = not useSessionFilter or not na(time(timeframe.period, tradeSession))

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)

htfLongOk = not useHTF or htfClose > htfEma
htfShortOk = not useHTF or htfClose < htfEma

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendLongAggressive = close > emaFast
trendShortAggressive = close < emaFast

trendLongBalanced = emaFast > emaSlow and close > emaFast
trendShortBalanced = emaFast < emaSlow and close < emaFast

trendLongStrict = emaFast > emaSlow and close > emaFast and emaFast > emaFast[1] and emaSlow > emaSlow[1]
trendShortStrict = emaFast < emaSlow and close < emaFast and emaFast < emaFast[1] and emaSlow < emaSlow[1]

trendLong =
     trendStrictness == "Aggressive" ? trendLongAggressive :
     trendStrictness == "Balanced" ? trendLongBalanced :
     trendLongStrict

trendShort =
     trendStrictness == "Aggressive" ? trendShortAggressive :
     trendStrictness == "Balanced" ? trendShortBalanced :
     trendShortStrict

momentumLong = rsi > rsiBull and macdHist > 0
momentumShort = rsi < rsiBear and macdHist < 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longScore = 0
longScore += trendLong ? 25 : 0
longScore += rsi > rsiBull ? 20 : 0
longScore += macdHist > 0 ? 20 : 0
longScore += volOk ? 15 : 0
longScore += atrOk ? 10 : 0
longScore += htfLongOk ? 10 : 0

shortScore = 0
shortScore += trendShort ? 25 : 0
shortScore += rsi < rsiBear ? 20 : 0
shortScore += macdHist < 0 ? 20 : 0
shortScore += volOk ? 15 : 0
shortScore += atrOk ? 10 : 0
shortScore += htfShortOk ? 10 : 0

longRaw = trendLong and momentumLong and volOk and atrOk and htfLongOk and sessionOk and longScore >= minScore
shortRaw = trendShort and momentumShort and volOk and atrOk and htfShortOk and sessionOk and shortScore >= minScore

longSignal = barstate.isconfirmed and longRaw and not longRaw[1]
shortSignal = barstate.isconfirmed and shortRaw and not shortRaw[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RISK LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float activeEntry = na
var float activeSL = na
var float activeTP1 = na
var float activeTP2 = na
var int activeDirection = 0

if longSignal
    activeEntry := close
    activeSL := close - atr * slAtrMult
    risk = activeEntry - activeSL
    activeTP1 := activeEntry + risk * tp1RR
    activeTP2 := activeEntry + risk * tp2RR
    activeDirection := 1

if shortSignal
    activeEntry := close
    activeSL := close + atr * slAtrMult
    risk = activeSL - activeEntry
    activeTP1 := activeEntry - risk * tp1RR
    activeTP2 := activeEntry - risk * tp2RR
    activeDirection := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullColor = color.rgb(0, 210, 140)
bearColor = color.rgb(255, 80, 100)
neutralColor = color.rgb(150, 150, 160)

plot(emaFast, "Fast EMA", color=color.new(bullColor, 0), linewidth=2)
plot(emaSlow, "Slow EMA", color=color.new(bearColor, 0), linewidth=2)

bgcolor(showBackground and trendLong ? color.new(bullColor, 90) : na)
bgcolor(showBackground and trendShort ? color.new(bearColor, 90) : na)

plotshape(showLabels and longSignal, title="Buy Signal", style=shape.labelup, text="BUY\nElaris", location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)
plotshape(showLabels and shortSignal, title="Sell Signal", style=shape.labeldown, text="SELL\nElaris", location=location.abovebar, color=bearColor, textcolor=color.white, size=size.small)

plot(showRiskLevels ? activeEntry : na, "Entry", color=color.new(color.white, 0), style=plot.style_linebr, linewidth=1)
plot(showRiskLevels ? activeSL : na, "Stop Loss", color=color.new(bearColor, 0), style=plot.style_linebr, linewidth=2)
plot(showRiskLevels ? activeTP1 : na, "TP1", color=color.new(bullColor, 0), style=plot.style_linebr, linewidth=1)
plot(showRiskLevels ? activeTP2 : na, "TP2", color=color.new(bullColor, 0), style=plot.style_linebr, linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos =
     dashboardPosition == "Top Right" ? position.top_right :
     dashboardPosition == "Top Left" ? position.top_left :
     dashboardPosition == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(pos, 2, 7, border_width=1)

trendText = trendLong ? "Bullish" : trendShort ? "Bearish" : "Neutral"
trendColor = trendLong ? bullColor : trendShort ? bearColor : neutralColor

htfText = useHTF ? htfLongOk ? "Bullish" : htfShortOk ? "Bearish" : "Neutral" : "Disabled"
htfColor = htfLongOk ? bullColor : htfShortOk ? bearColor : neutralColor

currentScore = trendLong ? longScore : trendShort ? shortScore : math.max(longScore, shortScore)
scoreColor = currentScore >= minScore ? bullColor : color.orange

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Elaris Smart Scalper", text_color=color.white, bgcolor=color.rgb(20, 20, 30))
    table.cell(dash, 1, 0, "Live", text_color=color.white, bgcolor=color.rgb(20, 20, 30))

    table.cell(dash, 0, 1, "Trend", text_color=color.white)
    table.cell(dash, 1, 1, trendText, text_color=color.white, bgcolor=trendColor)

    table.cell(dash, 0, 2, "HTF Bias", text_color=color.white)
    table.cell(dash, 1, 2, htfText, text_color=color.white, bgcolor=htfColor)

    table.cell(dash, 0, 3, "RSI", text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(rsi, "#.##"), text_color=color.white)

    table.cell(dash, 0, 4, "ATR %", text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(atrPercent, "#.###") + "%", text_color=color.white)

    table.cell(dash, 0, 5, "Volume Filter", text_color=color.white)
    table.cell(dash, 1, 5, volOk ? "Passed" : "Weak", text_color=color.white, bgcolor=volOk ? bullColor : bearColor)

    table.cell(dash, 0, 6, "Signal Score", text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(currentScore) + "/100", text_color=color.white, bgcolor=scoreColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longSignal, title="Elaris Smart Scalper BUY", message="Elaris Smart Scalper BUY signal on {{ticker}} at {{close}}")
alertcondition(shortSignal, title="Elaris Smart Scalper SELL", message="Elaris Smart Scalper SELL signal on {{ticker}} at {{close}}")

alertcondition(longSignal or shortSignal, title="Elaris Smart Scalper Any Signal", message="Elaris Smart Scalper signal on {{ticker}} at {{close}}")
````
