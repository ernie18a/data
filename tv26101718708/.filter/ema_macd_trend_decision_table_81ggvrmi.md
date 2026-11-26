# EMA MACD Trend Decision Table

- url: https://www.tradingview.com/script/81gGVrMi-EMA-MACD-Trend-Decision-Table/
- type: indicator
- pine_id: PUB;12c766f46d8240449ffa6eaf82d04f76
- version: 2.0

## Description

EMA MACD Decision Table v6

This Pine Script v6 overlay indicator summarizes trend, momentum, volume, higher-timeframe context, and ATR-based planning levels into one decision table.

The indicator uses EMA 9, EMA 21, EMA 50, EMA 100, EMA 200, MACD, RSI, ADX / DMI, volume confirmation, optional higher-timeframe EMA trend, and ATR risk planning.

It produces a numeric decision score on every bar. Bullish confirmations add points, bearish confirmations subtract points, and the final score is converted into Strong Buy, Buy, Neutral, Sell, or Strong Sell.

BUY labels appear only when the score first reaches Strong Buy territory. SELL labels appear only when the score first reaches Strong Sell territory.

This tool is designed for chart context and planning. It is not financial advice and does not guarantee trade results.

Scoring Logic

Condition | Score
--- | ---
EMA 9 above EMA 21 and price above EMA 50 | +2
EMA 9 below EMA 21 and price below EMA 50 | -2
Price above EMA 200 | +1
Price below EMA 200 | -1
MACD above signal and histogram above 0 | +2
MACD below signal and histogram below 0 | -2
MACD bullish crossover | +1
MACD bearish crossover | -1
RSI above 55 | +1
RSI below 45 | -1
ADX above threshold and +DI above -DI | +1
ADX above threshold and -DI above +DI | -1
Volume above average and candle closes above open | +1
Volume above average and candle closes below open | -1
Higher-timeframe close above its EMA when enabled | +1
Higher-timeframe close below its EMA when enabled | -1

Decision Output

Score Range | Decision
--- | ---
>= 5 | Strong Buy
2 to 4 | Buy
-1 to 1 | Neutral
-2 to -4 | Sell
<= -5 | Strong Sell

Decision Table Rows

Row | What It Shows | How To Read It
--- | --- | ---
Decision | Final decision and total score | Main summary of bullish, bearish, or mixed confirmation
Last Price | Latest close and price direction | Shows current price context
Bar Change | Close-to-close change and percent change | Positive is above prior close, negative is below prior close
O / H / L | Current open, high, and low | Shows current candle range
EMA 9 / EMA 21 | Short-term EMA relationship | EMA 9 above EMA 21 is bullish, below is bearish
EMA 50 / EMA 200 | Medium and long trend context | Price above EMA 200 supports bullish trend, below supports bearish trend
MACD | MACD state and histogram | Bullish when MACD is above signal and histogram is positive
RSI | RSI state and value | Above 55 bullish, below 45 bearish, above 70 overbought, below 30 oversold
ADX / DMI | Trend strength and direction | Strong +DI lead is bullish, strong -DI lead is bearish
Volume | Volume confirmation | Above-average bullish candle confirms buyers; bearish candle confirms sellers
HTF Trend | Optional higher-timeframe EMA trend | Bullish above HTF EMA, bearish below, Off when disabled
ATR | Current Average True Range | Risk planning unit
Long Plan | ATR-based long stop and target | Reference levels only
Short Plan | ATR-based short stop and target | Reference levels only

Candle Color Meaning

Score Range | Meaning | Candle Color
--- | --- | ---
>= 5 | Strong Buy | Lime
2 to 4 | Buy | Green
-1 to 1 | Neutral | Normal chart color
-2 to -4 | Sell | Maroon
<= -5 | Strong Sell | Red

ATR Planning Formulas

Plan | Formula
--- | ---
Long stop | close - ATR * stop multiplier
Long target | close + (close - long stop) * reward/risk
Short stop | close + ATR * stop multiplier
Short target | close - (short stop - close) * reward/risk

Data Window Values

Code | Meaning
--- | ---
2 | Strong Buy
1 | Buy
0 | Neutral
-1 | Sell
-2 | Strong Sell

Alert Logic

The script includes alerts for Strong Buy Decision, Strong Sell Decision, MACD Bullish Cross, and MACD Bearish Cross.

Strong decision alerts trigger when the score enters strong buy or strong sell territory. MACD alerts are based only on MACD line and signal line crossovers.

Reading The Output

Green output means bullish confirmations are stronger.
Red output means bearish confirmations are stronger.
Gray output means conditions are mixed or neutral.

The decision score is strongest when trend, momentum, volume, and higher-timeframe direction all agree.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Standalone Pine Script v6 trading decision indicator.

//@version=6
indicator("EMA MACD Decision Table v6", shorttitle="EMA MACD v6", overlay=true, max_labels_count=500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------

var string GP_EMA = "EMA Lines"
src = input.source(close, "Source", group=GP_EMA)
showEma = input.bool(true, "Show EMA Lines", group=GP_EMA)
ema1On = input.bool(true, "EMA 1 On/Off", inline="ema1", group=GP_EMA)
ema1Len = input.int(9, "Length", minval=1, inline="ema1", group=GP_EMA)
ema1Color = input.color(#FF3C33, "Color", inline="ema1", group=GP_EMA)
ema2On = input.bool(true, "EMA 2 On/Off", inline="ema2", group=GP_EMA)
ema2Len = input.int(21, "Length", minval=1, inline="ema2", group=GP_EMA)
ema2Color = input.color(#33FF4A, "Color", inline="ema2", group=GP_EMA)
ema3On = input.bool(true, "EMA 3 On/Off", inline="ema3", group=GP_EMA)
ema3Len = input.int(50, "Length", minval=1, inline="ema3", group=GP_EMA)
ema3Color = input.color(#F7FF33, "Color", inline="ema3", group=GP_EMA)
ema4On = input.bool(true, "EMA 4 On/Off", inline="ema4", group=GP_EMA)
ema4Len = input.int(100, "Length", minval=1, inline="ema4", group=GP_EMA)
ema4Color = input.color(#8B80EE, "Color", inline="ema4", group=GP_EMA)
ema5On = input.bool(true, "EMA 5 On/Off", inline="ema5", group=GP_EMA)
ema5Len = input.int(200, "Length", minval=1, inline="ema5", group=GP_EMA)
ema5Color = input.color(#FF33F6, "Color", inline="ema5", group=GP_EMA)

var string GP_MACD = "MACD"
macdFastLen = input.int(12, "Fast Length", minval=1, group=GP_MACD)
macdSlowLen = input.int(26, "Slow Length", minval=1, group=GP_MACD)
macdSignalLen = input.int(9, "Signal Smoothing", minval=1, group=GP_MACD)

var string GP_FILTERS = "Decision Filters"
rsiLen = input.int(14, "RSI Length", minval=1, group=GP_FILTERS)
adxLen = input.int(14, "ADX Length", minval=1, group=GP_FILTERS)
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=GP_FILTERS)
adxTrendMin = input.float(20.0, "Minimum ADX Trend", minval=1.0, step=0.5, group=GP_FILTERS)
volLen = input.int(20, "Volume Average Length", minval=1, group=GP_FILTERS)
useHtfTrend = input.bool(true, "Use Higher Timeframe Trend", group=GP_FILTERS)
htf = input.timeframe("D", "Higher Timeframe", group=GP_FILTERS)
htfEmaLen = input.int(50, "HTF EMA Length", minval=1, group=GP_FILTERS)

var string GP_RISK = "Risk Hints"
atrLen = input.int(14, "ATR Length", minval=1, group=GP_RISK)
atrStopMult = input.float(1.5, "ATR Stop Multiplier", minval=0.1, step=0.1, group=GP_RISK)
rewardRisk = input.float(2.0, "Reward/Risk Target", minval=0.1, step=0.1, group=GP_RISK)

var string GP_DISPLAY = "Display"
showSignals = input.bool(true, "Show Buy/Sell Labels", group=GP_DISPLAY)
paintBars = input.bool(true, "Paint Bars By Decision", group=GP_DISPLAY)
showTable = input.bool(true, "Show Decision Table", group=GP_DISPLAY)
showDataWindow = input.bool(true, "Show Hover Values In Data Window", group=GP_DISPLAY)
tableY = input.string("bottom", "Table Vertical", options=["top", "middle", "bottom"], inline="pos", group=GP_DISPLAY)
tableX = input.string("right", "Horizontal", options=["left", "center", "right"], inline="pos", group=GP_DISPLAY)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
roundToTick(value) =>
    str.tostring(value, format.mintick)

tablePosition(x, y) =>
    x == "left" and y == "top" ? position.top_left :
     x == "left" and y == "middle" ? position.middle_left :
     x == "left" and y == "bottom" ? position.bottom_left :
     x == "center" and y == "top" ? position.top_center :
     x == "center" and y == "middle" ? position.middle_center :
     x == "center" and y == "bottom" ? position.bottom_center :
     x == "right" and y == "middle" ? position.middle_right :
     x == "right" and y == "bottom" ? position.bottom_right :
     position.top_right

stateColor(state) =>
    state > 0 ? color.new(color.lime, 15) : state < 0 ? color.new(color.red, 15) : color.new(color.gray, 20)

decisionText(score) =>
    score >= 5 ? "STRONG BUY" : score >= 2 ? "BUY" : score <= -5 ? "STRONG SELL" : score <= -2 ? "SELL" : "NEUTRAL"

decisionColor(score) =>
    score >= 5 ? color.new(color.lime, 0) : score >= 2 ? color.new(color.green, 10) : score <= -5 ? color.new(color.red, 0) : score <= -2 ? color.new(color.maroon, 5) : color.new(color.gray, 20)

//------------------------------------------------------------------------------
// Indicator calculations
//------------------------------------------------------------------------------
ema1 = ta.ema(src, ema1Len)
ema2 = ta.ema(src, ema2Len)
ema3 = ta.ema(src, ema3Len)
ema4 = ta.ema(src, ema4Len)
ema5 = ta.ema(src, ema5Len)

[macdLine, macdSignal, macdHist] = ta.macd(src, macdFastLen, macdSlowLen, macdSignalLen)

rsi = ta.rsi(src, rsiLen)
[plusDi, minusDi, adx] = ta.dmi(adxLen, adxSmooth)
atr = ta.atr(atrLen)
volMa = ta.sma(volume, volLen)
volumeBull = volume > volMa and close > open
volumeBear = volume > volMa and close < open

htfClose = request.security(syminfo.tickerid, htf, close)
htfEma = request.security(syminfo.tickerid, htf, ta.ema(close, htfEmaLen))
htfBull = htfClose > htfEma
htfBear = htfClose < htfEma

//------------------------------------------------------------------------------
// Decision model
//------------------------------------------------------------------------------
emaBull = ema1 > ema2 and close > ema3
emaBear = ema1 < ema2 and close < ema3
longBull = close > ema5
longBear = close < ema5

macdBull = macdLine > macdSignal and macdHist > 0
macdBear = macdLine < macdSignal and macdHist < 0
macdBuyCross = ta.crossover(macdLine, macdSignal)
macdSellCross = ta.crossunder(macdLine, macdSignal)

rsiBull = rsi > 55
rsiBear = rsi < 45
adxBull = adx >= adxTrendMin and plusDi > minusDi
adxBear = adx >= adxTrendMin and minusDi > plusDi

score = 0
score += emaBull ? 2 : emaBear ? -2 : 0
score += longBull ? 1 : longBear ? -1 : 0
score += macdBull ? 2 : macdBear ? -2 : 0
score += macdBuyCross ? 1 : macdSellCross ? -1 : 0
score += rsiBull ? 1 : rsiBear ? -1 : 0
score += adxBull ? 1 : adxBear ? -1 : 0
score += volumeBull ? 1 : volumeBear ? -1 : 0
score += useHtfTrend ? htfBull ? 1 : htfBear ? -1 : 0 : 0

decision = decisionText(score)
decisionBg = decisionColor(score)
decisionCode = score >= 5 ? 2 : score >= 2 ? 1 : score <= -5 ? -2 : score <= -2 ? -1 : 0
candleColor = score >= 5 ? color.new(color.lime, 0) : score >= 2 ? color.new(color.green, 45) : score <= -5 ? color.new(color.red, 0) : score <= -2 ? color.new(color.maroon, 35) : na
barChange = close - close[1]
barChangePct = close[1] != 0.0 ? barChange / close[1] * 100.0 : na
priceState = barChange > 0 ? "Up" : barChange < 0 ? "Down" : "Flat"
priceStateColor = barChange > 0 ? color.new(color.green, 20) : barChange < 0 ? color.new(color.red, 20) : color.new(color.gray, 25)
buySignal = showSignals and score >= 5 and score[1] < 5
sellSignal = showSignals and score <= -5 and score[1] > -5

longStop = close - atr * atrStopMult
longTarget = close + (close - longStop) * rewardRisk
shortStop = close + atr * atrStopMult
shortTarget = close - (shortStop - close) * rewardRisk

//------------------------------------------------------------------------------
// EMA chart lines
//------------------------------------------------------------------------------
plot(showEma and ema1On ? ema1 : na, "EMA 1", color=ema1Color, linewidth=1)
plot(showEma and ema2On ? ema2 : na, "EMA 2", color=ema2Color, linewidth=1)
plot(showEma and ema3On ? ema3 : na, "EMA 3", color=ema3Color, linewidth=2)
plot(showEma and ema4On ? ema4 : na, "EMA 4", color=ema4Color, linewidth=2)
plot(showEma and ema5On ? ema5 : na, "EMA 5", color=ema5Color, linewidth=2)

if buySignal
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.small, tooltip="Strong BUY\nScore: " + str.tostring(score) + "\nEMA: Bullish\nMACD: " + (macdBull ? "Bullish" : "Mixed") + "\nRSI: " + str.tostring(rsi, "#.##") + "\nADX: " + str.tostring(adx, "#.##"))

if sellSignal
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small, tooltip="Strong SELL\nScore: " + str.tostring(score) + "\nEMA: Bearish\nMACD: " + (macdBear ? "Bearish" : "Mixed") + "\nRSI: " + str.tostring(rsi, "#.##") + "\nADX: " + str.tostring(adx, "#.##"))

barcolor(paintBars ? candleColor : na)

// Hover any candle and check TradingView's Data Window for these per-bar values.
plot(showDataWindow ? score : na, "Decision Score", display=display.data_window)
plot(showDataWindow ? decisionCode : na, "Decision Code: 2 Strong Buy, 1 Buy, 0 Neutral, -1 Sell, -2 Strong Sell", display=display.data_window)
plot(showDataWindow ? rsi : na, "RSI", display=display.data_window)
plot(showDataWindow ? adx : na, "ADX", display=display.data_window)
plot(showDataWindow ? macdHist : na, "MACD Histogram", display=display.data_window)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(buySignal, title="Strong Buy Decision", message="Strong BUY decision on {{ticker}} at {{close}}")
alertcondition(sellSignal, title="Strong Sell Decision", message="Strong SELL decision on {{ticker}} at {{close}}")
alertcondition(macdBuyCross, title="MACD Bullish Cross", message="MACD crossed above signal on {{ticker}}")
alertcondition(macdSellCross, title="MACD Bearish Cross", message="MACD crossed below signal on {{ticker}}")

//------------------------------------------------------------------------------
// Decision table
//------------------------------------------------------------------------------
var table decisionPanel = table.new(tablePosition(tableX, tableY), 3, 15, bgcolor=color.new(color.black, 12), frame_color=color.new(color.white, 60), frame_width=1, border_color=color.new(color.white, 80), border_width=1)

setCell(int col, int row, string txt, color bgColor, color txtColor) =>
    table.cell(decisionPanel, col, row, txt, text_color=txtColor, bgcolor=bgColor, text_size=size.normal)

if barstate.islast and showTable
    table.clear(decisionPanel, 0, 0, 2, 14)
    setCell(0, 0, "Metric", color.new(color.gray, 45), color.white)
    setCell(1, 0, "State", color.new(color.gray, 45), color.white)
    setCell(2, 0, "Value", color.new(color.gray, 45), color.white)

    setCell(0, 1, "Decision", color.new(color.black, 100), color.white)
    setCell(1, 1, decision, decisionBg, color.white)
    setCell(2, 1, str.tostring(score), decisionBg, color.white)

    setCell(0, 2, "Last Price", color.new(color.black, 100), color.white)
    setCell(1, 2, priceState, priceStateColor, color.white)
    setCell(2, 2, roundToTick(close), color.new(color.black, 100), color.white)

    setCell(0, 3, "Bar Change", color.new(color.black, 100), color.white)
    setCell(1, 3, priceState, priceStateColor, color.white)
    setCell(2, 3, roundToTick(barChange) + "\n" + str.tostring(barChangePct, "#.##") + "%", color.new(color.black, 100), color.white)

    setCell(0, 4, "O\nH\nL", color.new(color.black, 100), color.white)
    setCell(1, 4, "Live Bar", color.new(color.gray, 30), color.white)
    setCell(2, 4, roundToTick(open) + "\n" + roundToTick(high) + "\n" + roundToTick(low), color.new(color.black, 100), color.white)

    setCell(0, 5, "EMA 9\nEMA 21", color.new(color.black, 100), color.white)
    setCell(1, 5, ema1 > ema2 ? "EMA 9 > EMA 21" : ema1 < ema2 ? "EMA 9 < EMA 21" : "EMA 9 = EMA 21", stateColor(emaBull ? 1 : emaBear ? -1 : 0), color.white)
    setCell(2, 5, roundToTick(ema1) + "\n" + roundToTick(ema2), color.new(color.black, 100), color.white)

    setCell(0, 6, "EMA 50\nEMA 200", color.new(color.black, 100), color.white)
    setCell(1, 6, longBull ? "Above 200 EMA" : longBear ? "Below 200 EMA" : "At 200 EMA", stateColor(longBull ? 1 : longBear ? -1 : 0), color.white)
    setCell(2, 6, roundToTick(ema3) + "\n" + roundToTick(ema5), color.new(color.black, 100), color.white)

    setCell(0, 7, "MACD", color.new(color.black, 100), color.white)
    setCell(1, 7, macdBull ? "Bullish" : macdBear ? "Bearish" : "Flat", stateColor(macdBull ? 1 : macdBear ? -1 : 0), color.white)
    setCell(2, 7, str.tostring(macdHist, "#.####"), color.new(color.black, 100), color.white)

    setCell(0, 8, "RSI", color.new(color.black, 100), color.white)
    setCell(1, 8, rsi > 70 ? "Overbought" : rsi < 30 ? "Oversold" : rsiBull ? "Bullish" : rsiBear ? "Bearish" : "Neutral", stateColor(rsiBull ? 1 : rsiBear ? -1 : 0), color.white)
    setCell(2, 8, str.tostring(rsi, "#.##"), color.new(color.black, 100), color.white)

    setCell(0, 9, "ADX / DMI", color.new(color.black, 100), color.white)
    setCell(1, 9, adxBull ? "Trend Up" : adxBear ? "Trend Down" : "Weak", stateColor(adxBull ? 1 : adxBear ? -1 : 0), color.white)
    setCell(2, 9, str.tostring(adx, "#.##"), color.new(color.black, 100), color.white)

    setCell(0, 10, "Volume", color.new(color.black, 100), color.white)
    setCell(1, 10, volumeBull ? "Bull Confirm" : volumeBear ? "Bear Confirm" : "Normal", stateColor(volumeBull ? 1 : volumeBear ? -1 : 0), color.white)
    setCell(2, 10, str.tostring(volume / volMa, "#.##") + "x", color.new(color.black, 100), color.white)

    setCell(0, 11, "HTF Trend", color.new(color.black, 100), color.white)
    setCell(1, 11, useHtfTrend ? htfBull ? "Bullish" : htfBear ? "Bearish" : "Flat" : "Off", useHtfTrend ? stateColor(htfBull ? 1 : htfBear ? -1 : 0) : color.new(color.gray, 30), color.white)
    setCell(2, 11, useHtfTrend ? htf + " EMA " + str.tostring(htfEmaLen) : "-", color.new(color.black, 100), color.white)

    setCell(0, 12, "ATR", color.new(color.black, 100), color.white)
    setCell(1, 12, "Risk Unit", color.new(color.gray, 30), color.white)
    setCell(2, 12, roundToTick(atr), color.new(color.black, 100), color.white)

    setCell(0, 13, "Long Plan", color.new(color.black, 100), color.white)
    setCell(1, 13, "Stop / Target", color.new(color.green, 35), color.white)
    setCell(2, 13, roundToTick(longStop) + "\n" + roundToTick(longTarget), color.new(color.black, 100), color.white)

    setCell(0, 14, "Short Plan", color.new(color.black, 100), color.white)
    setCell(1, 14, "Stop / Target", color.new(color.red, 35), color.white)
    setCell(2, 14, roundToTick(shortStop) + "\n" + roundToTick(shortTarget), color.new(color.black, 100), color.white)

if barstate.islast and not showTable
    table.clear(decisionPanel, 0, 0, 2, 14)
````
