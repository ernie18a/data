# Elaris Fast Scalp Pro

- url: https://www.tradingview.com/script/D783LfUe-Elaris-Fast-Scalp-Pro/
- type: indicator
- pine_id: PUB;a4c2b88c9fb8401584a1fcf198c4ca3e
- version: 1.0

## Description

Elaris Fast Scalp Pro is a professional lower-timeframe scalping indicator designed for fast-moving markets such as crypto, forex, and indices. The indicator combines trend alignment, momentum confirmation, volatility filtering, VWAP positioning, volume strength, and higher-timeframe confirmation into a clean non-repainting scalping system.

Built specifically for aggressive intraday traders, the script focuses on identifying high-quality momentum continuation opportunities while filtering out weak or choppy conditions that commonly generate false signals on lower timeframes.

The signal engine uses:

Fast EMA reclaim logic
Trend structure filtering
RSI momentum confirmation
ADX trend-strength filtering
VWAP positioning
Volume expansion validation
ATR-based volatility quality checks
Optional higher-timeframe directional confirmation
Cooldown logic to reduce over-signaling

The indicator also includes:

Professional dashboard panel
Real-time market condition overview
Risk/reward visualization
Dynamic stop loss and take profit levels
Configurable session filtering
Long and short signal alerts
Dark and light mode compatibility

Elaris Fast Scalp Pro is optimized for:

1m / 3m / 5m / 15m charts
Crypto scalping
Fast intraday momentum trading
Session breakout continuation moves
Trend-following scalp setups

Unlike many repainting scalping systems, all signals are confirmed only after candle close, making the indicator suitable for live trading and alert automation.

Features
Non-repainting confirmed signals
Fast scalp continuation engine
Smart trend filtering
Built-in volatility protection
Volume confirmation system
Optional HTF bias filter
VWAP institutional bias filter
Risk/reward plotting
Signal quality scoring
Professional dashboard UI
Fully customizable inputs
Best Usage

The indicator performs best during active market sessions with strong momentum and healthy volatility conditions. Lower-timeframe traders may combine it with market structure, liquidity zones, or session trading concepts for additional confirmation.

## Source Code

````pine
//@version=6
indicator("Elaris Fast Scalp Pro", shorttitle="Elaris FSP", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// Inputs
//====================================================
groupCore = "Core Signal Engine"
fastLen   = input.int(9, "Fast EMA", minval=1, group=groupCore)
slowLen   = input.int(21, "Slow EMA", minval=1, group=groupCore)
trendLen  = input.int(50, "Trend EMA", minval=1, group=groupCore)
rsiLen    = input.int(14, "RSI Length", minval=2, group=groupCore)
cooldown  = input.int(5, "Signal Cooldown Bars", minval=0, group=groupCore)

groupFilters = "Filters"
useVWAP   = input.bool(true, "Use VWAP Filter", group=groupFilters)
useVolume = input.bool(true, "Use Volume Filter", group=groupFilters)
volLen    = input.int(20, "Volume MA Length", minval=1, group=groupFilters)
volMult   = input.float(1.1, "Volume Strength Multiplier", minval=0.1, step=0.1, group=groupFilters)
useADX    = input.bool(true, "Use ADX Chop Filter", group=groupFilters)
adxLen    = input.int(14, "ADX Length", minval=2, group=groupFilters)
adxMin    = input.float(16.0, "Minimum ADX", minval=1, step=0.5, group=groupFilters)

groupVolatility = "Volatility Quality"
atrLen      = input.int(14, "ATR Length", minval=1, group=groupVolatility)
minAtrPct   = input.float(0.05, "Minimum ATR %", minval=0.0, step=0.01, group=groupVolatility)
maxRangeATR = input.float(2.2, "Avoid Exhaustion Candle Above ATR x", minval=0.5, step=0.1, group=groupVolatility)

groupHTF = "Higher Timeframe Confirmation"
useHTF   = input.bool(true, "Use HTF Confirmation", group=groupHTF)
htfTf    = input.timeframe("15", "HTF Timeframe", group=groupHTF)
htfLen   = input.int(50, "HTF EMA Length", minval=1, group=groupHTF)

groupSession = "Session Filter"
useSession = input.bool(false, "Use Trading Session Filter", group=groupSession)
sessionInp = input.session("0700-2200", "Allowed Session", group=groupSession)

groupRisk = "Risk Visuals"
showRisk = input.bool(true, "Show SL / TP Levels", group=groupRisk)
slMode   = input.string("ATR", "Stop Mode", options=["ATR", "Swing"], group=groupRisk)
slAtr    = input.float(1.2, "ATR Stop Multiplier", minval=0.1, step=0.1, group=groupRisk)
rr       = input.float(1.8, "Risk Reward", minval=0.2, step=0.1, group=groupRisk)
swingLen = input.int(5, "Swing Stop Lookback", minval=1, group=groupRisk)

groupVisual = "Visual Design"
theme      = input.string("Dark", "Theme", options=["Dark", "Light"], group=groupVisual)
showLabels = input.bool(true, "Show Signal Labels", group=groupVisual)
showDash   = input.bool(true, "Show Dashboard", group=groupVisual)
dashPos    = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupVisual)

groupAlerts = "Alerts"
minScore = input.int(70, "Minimum Signal Quality Score", minval=1, maxval=100, group=groupAlerts)

//====================================================
// Colors
//====================================================
isDark = theme == "Dark"

bullColor = color.rgb(0, 220, 140)
bearColor = color.rgb(255, 80, 100)
neutralColor = isDark ? color.rgb(150, 160, 175) : color.rgb(90, 95, 105)
dashBg = isDark ? color.rgb(18, 22, 30) : color.rgb(245, 247, 250)
dashText = isDark ? color.white : color.black

//====================================================
// Core Calculations
//====================================================
emaFast  = ta.ema(close, fastLen)
emaSlow  = ta.ema(close, slowLen)
emaTrend = ta.ema(close, trendLen)
vwapVal  = ta.vwap(hlc3)

atr = ta.atr(atrLen)
atrPct = atr / close * 100.0

rsi = ta.rsi(close, rsiLen)
volMA = ta.sma(volume, volLen)

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

htfBull = request.security(syminfo.tickerid, htfTf, close > ta.ema(close, htfLen), barmerge.gaps_off, barmerge.lookahead_off)
htfBear = request.security(syminfo.tickerid, htfTf, close < ta.ema(close, htfLen), barmerge.gaps_off, barmerge.lookahead_off)

inSession = not useSession or not na(time(timeframe.period, sessionInp))

//====================================================
// Market State
//====================================================
bullTrend = emaFast > emaSlow and close > emaTrend
bearTrend = emaFast < emaSlow and close < emaTrend

bullVWAP = not useVWAP or close > vwapVal
bearVWAP = not useVWAP or close < vwapVal

volumeOK = not useVolume or volume > volMA * volMult
adxOK = not useADX or adx >= adxMin
volatilityOK = atrPct >= minAtrPct

barRange = high - low
exhaustionOK = barRange <= atr * maxRangeATR

htfOKLong = not useHTF or htfBull
htfOKShort = not useHTF or htfBear

//====================================================
// Fast Scalp Trigger Logic
//====================================================
bullPullback = low <= emaFast and close > emaFast
bearPullback = high >= emaFast and close < emaFast

bullCandle = close > open and close > close[1]
bearCandle = close < open and close < close[1]

bullMomentum = rsi > 50 and rsi > rsi[1]
bearMomentum = rsi < 50 and rsi < rsi[1]

microBreakLong = close > high[1]
microBreakShort = close < low[1]

//====================================================
// Scoring System
//====================================================
longScore = 0
longScore += bullTrend ? 25 : 0
longScore += bullMomentum ? 20 : 0
longScore += bullVWAP ? 15 : 0
longScore += volumeOK ? 15 : 0
longScore += volatilityOK and exhaustionOK ? 15 : 0
longScore += htfOKLong ? 10 : 0

shortScore = 0
shortScore += bearTrend ? 25 : 0
shortScore += bearMomentum ? 20 : 0
shortScore += bearVWAP ? 15 : 0
shortScore += volumeOK ? 15 : 0
shortScore += volatilityOK and exhaustionOK ? 15 : 0
shortScore += htfOKShort ? 10 : 0

//====================================================
// Cooldown
//====================================================
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar > cooldown

longSignal = barstate.isconfirmed and canSignal and inSession and bullPullback and bullCandle and microBreakLong and adxOK and longScore >= minScore
shortSignal = barstate.isconfirmed and canSignal and inSession and bearPullback and bearCandle and microBreakShort and adxOK and shortScore >= minScore

if longSignal or shortSignal
    lastSignalBar := bar_index

//====================================================
// Risk Levels
//====================================================
longSL = slMode == "ATR" ? close - atr * slAtr : ta.lowest(low, swingLen)
shortSL = slMode == "ATR" ? close + atr * slAtr : ta.highest(high, swingLen)

longTP = close + (close - longSL) * rr
shortTP = close - (shortSL - close) * rr

var float activeEntry = na
var float activeSL = na
var float activeTP = na
var int activeDir = 0

if longSignal
    activeEntry := close
    activeSL := longSL
    activeTP := longTP
    activeDir := 1

if shortSignal
    activeEntry := close
    activeSL := shortSL
    activeTP := shortTP
    activeDir := -1

//====================================================
// Plots
//====================================================
plot(emaFast, "Fast EMA", color=color.new(bullColor, 0), linewidth=1)
plot(emaSlow, "Slow EMA", color=color.new(neutralColor, 10), linewidth=1)
plot(emaTrend, "Trend EMA", color=color.new(color.orange, 0), linewidth=2)
plot(useVWAP ? vwapVal : na, "VWAP", color=color.new(color.blue, 20), linewidth=1)

barcolor(bullTrend ? color.new(bullColor, 80) : bearTrend ? color.new(bearColor, 80) : na)

plotshape(longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small, text="BUY")
plotshape(shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="SELL")

plot(showRisk ? activeEntry : na, "Active Entry", color=color.new(color.white, 0), style=plot.style_linebr)
plot(showRisk ? activeSL : na, "Active Stop Loss", color=color.new(bearColor, 0), style=plot.style_linebr)
plot(showRisk ? activeTP : na, "Active Take Profit", color=color.new(bullColor, 0), style=plot.style_linebr)

//====================================================
// Labels
//====================================================
if showLabels and longSignal
    label.new(bar_index, low, "FAST LONG\nScore: " + str.tostring(longScore) + "\nRR: " + str.tostring(rr), style=label.style_label_up, textcolor=color.white, color=color.new(bullColor, 0), size=size.small)

if showLabels and shortSignal
    label.new(bar_index, high, "FAST SHORT\nScore: " + str.tostring(shortScore) + "\nRR: " + str.tostring(rr), style=label.style_label_down, textcolor=color.white, color=color.new(bearColor, 0), size=size.small)

//====================================================
// Dashboard
//====================================================
f_pos(_p) =>
    switch _p
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

var table dash = table.new(f_pos(dashPos), 2, 8, border_width=1)

if showDash and barstate.islast
    biasTxt = bullTrend ? "Bullish" : bearTrend ? "Bearish" : "Neutral"
    biasCol = bullTrend ? bullColor : bearTrend ? bearColor : neutralColor

    table.cell(dash, 0, 0, "Elaris Fast Scalp Pro", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 0, "LTF Engine", text_color=dashText, bgcolor=dashBg)

    table.cell(dash, 0, 1, "Trend", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 1, biasTxt, text_color=color.white, bgcolor=color.new(biasCol, 15))

    table.cell(dash, 0, 2, "RSI", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 2, str.tostring(rsi, "#.0"), text_color=dashText, bgcolor=dashBg)

    table.cell(dash, 0, 3, "ADX", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 3, str.tostring(adx, "#.0"), text_color=adxOK ? bullColor : bearColor, bgcolor=dashBg)

    table.cell(dash, 0, 4, "ATR %", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 4, str.tostring(atrPct, "#.00") + "%", text_color=volatilityOK ? bullColor : bearColor, bgcolor=dashBg)

    table.cell(dash, 0, 5, "Volume", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 5, volumeOK ? "Strong" : "Weak", text_color=volumeOK ? bullColor : bearColor, bgcolor=dashBg)

    table.cell(dash, 0, 6, "HTF", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 6, htfBull ? "Bull" : htfBear ? "Bear" : "Mixed", text_color=htfBull ? bullColor : htfBear ? bearColor : neutralColor, bgcolor=dashBg)

    table.cell(dash, 0, 7, "Last Score", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 7, "L " + str.tostring(longScore) + " / S " + str.tostring(shortScore), text_color=dashText, bgcolor=dashBg)

//====================================================
// Alerts
//====================================================
alertcondition(longSignal, title="Elaris Fast Scalp Long", message="Elaris Fast Scalp Pro: LONG signal confirmed.")
alertcondition(shortSignal, title="Elaris Fast Scalp Short", message="Elaris Fast Scalp Pro: SHORT signal confirmed.")
alertcondition(longSignal or shortSignal, title="Elaris Fast Scalp Any Signal", message="Elaris Fast Scalp Pro: New scalp signal confirmed.")
````
