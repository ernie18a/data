# MACD RSI Stochastic Buy/Sell Timing Table

- url: https://www.tradingview.com/script/YiLLCBqm-MACD-RSI-Stochastic-Buy-Sell-Timing-Table/
- type: indicator
- pine_id: PUB;96c750fcaa0b45ef9fbc9209d515e2f8
- version: 1.0

## Description

Buy/Sell MACD RSI Stochastics v6

This Pine Script v6 oscillator-pane indicator focuses on timing signals using RSI, Stochastic, MACD, optional EMA trend confirmation, and optional volume confirmation.

The script combines RSI levels and threshold crosses, Stochastic %K / %D relationships and crosses, MACD line / signal / histogram logic, buy and sell setup markers, strong buy and strong sell markers, a compact oscillator decision table, alerts, and Data Window values.

It calculates a numeric oscillator score on every bar. Bullish confirmations add points, bearish confirmations subtract points, and the final score is converted into Strong Buy, Buy / Watch Long, Neutral / Wait, Sell / Watch Short, or Strong Sell.

Strong BUY markers appear when the score first reaches Strong Buy territory. Strong SELL markers appear when the score first reaches Strong Sell territory. Smaller Buy and Sell setup markers appear when the score first reaches watch-long or watch-short territory.

This tool is designed for timing context and trade planning. It is not financial advice and does not guarantee trade results.

Scoring Logic

Condition | Score
--- | ---
RSI is at or above the bull bias level | +2
RSI is at or below the bear bias level | -2
RSI crosses above the buy level | +1
RSI crosses below the sell level | -1
Stochastic K is above D and K is above 50 | +2
Stochastic K is below D and K is below 50 | -2
Stochastic K crosses above D before the sell level | +1
Stochastic K crosses below D after the buy level | -1
Stochastic crosses above the buy level | +1
Stochastic crosses below the sell level | -1
MACD is above signal and histogram is above 0 | +2
MACD is below signal and histogram is below 0 | -2
MACD bullish crossover | +1
MACD bearish crossover | -1
EMA trend filter is bullish when enabled | +1
EMA trend filter is bearish when enabled | -1
Volume confirmation is bullish when enabled | +1
Volume confirmation is bearish when enabled | -1

Decision Output

Score Range | Decision | Pane Background | Decision Table Background
--- | --- | --- | ---
>= 6 | Strong Buy | Bright green | Bright lime
3 to 5 | Buy / Watch Long | Light green | Green
-2 to 2 | Neutral / Wait | No background | Gray
-3 to -5 | Sell / Watch Short | Light maroon/red | Maroon
<= -6 | Strong Sell | Bright red | Bright red

The pane background and decision table background use the same oscillator score ranges. The pane background is more transparent so the oscillator lines remain readable.

RSI Logic

RSI Level | Meaning
--- | ---
30 | Buy threshold
45 | Bear bias threshold
55 | Bull bias threshold
70 | Sell threshold

RSI contributes bullish score when it is above the bull bias level and bearish score when it is below the bear bias level.

An RSI cross above the buy level adds a smaller bullish timing point. An RSI cross below the sell level adds a smaller bearish timing point.

Stochastic Logic

Stochastic is bullish when %K is above %D and %K is above 50.

Stochastic is bearish when %K is below %D and %K is below 50.

Stochastic Event | Meaning
--- | ---
%K crosses above %D before the sell level | Bullish timing confirmation
%K crosses below %D after the buy level | Bearish timing confirmation
Stochastic crosses above the buy level | Bullish threshold confirmation
Stochastic crosses below the sell level | Bearish threshold confirmation

MACD Logic

MACD is bullish when the MACD line is above the signal line and the histogram is positive.

MACD is bearish when the MACD line is below the signal line and the histogram is negative.

A MACD line crossover above the signal line adds a bullish timing point. A cross below the signal line adds a bearish timing point.

MACD can be normalized for display so it fits in the same oscillator pane as RSI and Stochastic. The raw MACD values remain available in the Data Window.

EMA Trend Filter Logic

When enabled, the EMA trend filter checks the fast EMA, slow EMA, and long trend EMA.

Filter State | Condition
--- | ---
Bullish | Fast EMA above slow EMA and price above long trend EMA
Bearish | Fast EMA below slow EMA and price below long trend EMA
Disabled | Does not affect the score

Volume Logic

When enabled, volume confirmation compares current volume against average volume.

Volume State | Condition
--- | ---
Bullish confirmation | Above-average volume with a bullish candle
Bearish confirmation | Above-average volume with a bearish candle
No confirmation | Normal or low-volume candle
Disabled | Does not affect the score

Visual Output

The oscillator pane can show RSI, Stochastic %K, Stochastic %D, optional normalized MACD line and signal line, optional normalized MACD histogram, green or red background based on the decision score, Buy / Sell setup markers, and Strong BUY / SELL markers.

Green background means the oscillator score is bullish. Red background means the oscillator score is bearish. Stronger color appears when the score reaches strong buy or strong sell territory.

Decision Table Rows

Row | What It Shows | How To Read It
--- | --- | ---
Osc Decision | Final oscillator decision and oscillator score | Main timing summary. Strong Buy / Buy means momentum confirmations are bullish. Strong Sell / Sell means momentum confirmations are bearish. Neutral means timing is mixed.
Stoch K/D | Current Stochastic %K and %D relationship, plus both values | Bullish means %K is above %D and %K is above 50. Bearish means %K is below %D and %K is below 50. Mixed means the condition is not directional enough.
Stoch Signal | Whether Stochastic created a buy cross, sell cross, or no fresh cross | Buy Cross appears when %K crosses above %D or above the buy level. Sell Cross appears when %K crosses below %D or below the sell level. None means no fresh Stochastic cross is active.
RSI Signal | Whether RSI crossed the configured buy or sell threshold | Buy Cross appears when RSI crosses above the buy level. Sell Cross appears when RSI crosses below the sell level. None means no fresh RSI threshold cross is active.
MACD Cross | Whether MACD crossed its signal line, plus raw MACD and signal values | Bull Cross means MACD crossed above signal. Bear Cross means MACD crossed below signal. None means no fresh MACD crossover is active.
Setup | Trade-watch state produced by the oscillator score | Strong Buy and Strong Sell are the strongest timing states. Buy Watch and Sell Watch are earlier setup states. Wait means there is not enough directional agreement.

Use the table as a timing tool. It is strongest when the oscillator decision agrees with broader chart-level trend context.

Data Window Values

When enabled, the script exposes Decision Score, Decision Code, MACD Raw, MACD Signal Raw, and MACD Histogram Raw.

Code | Meaning
--- | ---
2 | Strong Buy
1 | Buy
0 | Neutral
-1 | Sell
-2 | Strong Sell

Alert Logic

The script includes alerts for Strong Buy Decision, Strong Sell Decision, Buy Setup, Sell Setup, RSI Buy Cross, RSI Sell Cross, Stochastic Buy Cross, Stochastic Sell Cross, MACD Bullish Cross, and MACD Bearish Cross.

Strong decision alerts come from the oscillator score entering strong buy or strong sell territory. Setup alerts come from the score entering watch-long or watch-short territory. Indicator cross alerts are based on their individual RSI, Stochastic, or MACD crossover conditions.

Reading The Output

This script is mainly a timing tool. Bullish output is strongest when RSI, Stochastic, MACD, trend filter, and volume all align. Bearish output is strongest when those same components align to the downside.

When used with the EMA MACD Decision Table script, the chart-level table gives broader trend context and this oscillator gives timing confirmation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Combined Pine Script v6 indicator using MACD, RSI, and Stochastic decision logic.

//@version=6
indicator("Buy/Sell MACD RSI Stochastics v6", shorttitle="BuySell MACD RSI Stoch v6", overlay=false, precision=2, max_labels_count=500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
var string GP_GENERAL = "General"
src = input.source(close, "Source", group=GP_GENERAL)
showBuySell = input.bool(true, "Show Buy/Sell Markers", group=GP_GENERAL)
showTable = input.bool(true, "Show Decision Table", group=GP_GENERAL)
showDataWindow = input.bool(true, "Show Data Window Values", group=GP_GENERAL)
paintBackground = input.bool(true, "Paint Background By Decision", group=GP_GENERAL)
minimalView = input.bool(false, "Minimal View: Stoch + Signals Only", group=GP_GENERAL)
tableY = input.string("bottom", "Table Vertical", options=["top", "middle", "bottom"], inline="pos", group=GP_GENERAL)
tableX = input.string("right", "Horizontal", options=["left", "center", "right"], inline="pos", group=GP_GENERAL)

var string GP_RSI = "RSI"
showRsi = input.bool(true, "Show RSI", group=GP_RSI)
rsiLen = input.int(14, "RSI Length", minval=1, group=GP_RSI)
rsiBuyLevel = input.float(30.0, "RSI Buy Level", minval=1, maxval=99, step=0.5, group=GP_RSI)
rsiSellLevel = input.float(70.0, "RSI Sell Level", minval=1, maxval=99, step=0.5, group=GP_RSI)
rsiBullLevel = input.float(55.0, "RSI Bull Bias", minval=1, maxval=99, step=0.5, group=GP_RSI)
rsiBearLevel = input.float(45.0, "RSI Bear Bias", minval=1, maxval=99, step=0.5, group=GP_RSI)

var string GP_STOCH = "Stochastic"
showStoch = input.bool(true, "Show Stochastic", group=GP_STOCH)
kPeriod = input.int(14, "K Period", minval=1, group=GP_STOCH)
kSmooth = input.int(3, "K Smoothing", minval=1, group=GP_STOCH)
dPeriod = input.int(3, "D Period", minval=1, group=GP_STOCH)
stochBuyLevel = input.float(20.0, "Stochastic Buy Level", minval=1, maxval=99, step=0.5, group=GP_STOCH)
stochSellLevel = input.float(80.0, "Stochastic Sell Level", minval=1, maxval=99, step=0.5, group=GP_STOCH)

var string GP_MACD = "MACD"
showMacd = input.bool(false, "Show MACD Normalized", group=GP_MACD)
showMacdHist = input.bool(false, "Show MACD Histogram", group=GP_MACD)
macdFastLen = input.int(12, "Fast Length", minval=1, group=GP_MACD)
macdSlowLen = input.int(26, "Slow Length", minval=1, group=GP_MACD)
macdSignalLen = input.int(9, "Signal Smoothing", minval=1, maxval=50, group=GP_MACD)
macdNormalizeLen = input.int(100, "MACD Normalize Lookback", minval=10, group=GP_MACD)
useSmaOscillator = input.bool(false, "Simple MA Oscillator", group=GP_MACD)
useSmaSignal = input.bool(false, "Simple MA Signal", group=GP_MACD)

var string GP_FILTERS = "Extra Confirmation"
useTrendFilter = input.bool(true, "Use EMA Trend Filter", group=GP_FILTERS)
fastEmaLen = input.int(9, "Fast EMA", minval=1, group=GP_FILTERS)
slowEmaLen = input.int(21, "Slow EMA", minval=1, group=GP_FILTERS)
trendEmaLen = input.int(200, "Trend EMA", minval=1, group=GP_FILTERS)
useVolumeFilter = input.bool(true, "Use Volume Confirmation", group=GP_FILTERS)
volLen = input.int(20, "Volume Average Length", minval=1, group=GP_FILTERS)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
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
    state > 0 ? color.new(color.lime, 15) : state < 0 ? color.new(color.red, 15) : color.new(color.gray, 25)

decisionText(score) =>
    score >= 6 ? "STRONG BUY" : score >= 3 ? "BUY" : score <= -6 ? "STRONG SELL" : score <= -3 ? "SELL" : "NEUTRAL"

decisionColor(score) =>
    score >= 6 ? color.new(color.lime, 0) : score >= 3 ? color.new(color.green, 10) : score <= -6 ? color.new(color.red, 0) : score <= -3 ? color.new(color.maroon, 5) : color.new(color.gray, 25)

normalizeToRange(value, length) =>
    lowValue = ta.lowest(value, length)
    highValue = ta.highest(value, length)
    spread = highValue - lowValue
    spread != 0.0 ? 100.0 * (value - lowValue) / spread : 50.0

//------------------------------------------------------------------------------
// Calculations
//------------------------------------------------------------------------------
rsi = ta.rsi(src, rsiLen)
rsiBull = rsi >= rsiBullLevel
rsiBear = rsi <= rsiBearLevel
rsiBuyCross = ta.crossover(rsi, rsiBuyLevel)
rsiSellCross = ta.crossunder(rsi, rsiSellLevel)

stochK = ta.sma(ta.stoch(close, high, low, kPeriod), kSmooth)
stochD = ta.sma(stochK, dPeriod)
stochBull = stochK > stochD and stochK > 50
stochBear = stochK < stochD and stochK < 50
stochBuyCross = ta.crossover(stochK, stochBuyLevel)
stochSellCross = ta.crossunder(stochK, stochSellLevel)
stochKDCrossBuy = ta.crossover(stochK, stochD)
stochKDCrossSell = ta.crossunder(stochK, stochD)

fastMa = useSmaOscillator ? ta.sma(src, macdFastLen) : ta.ema(src, macdFastLen)
slowMa = useSmaOscillator ? ta.sma(src, macdSlowLen) : ta.ema(src, macdSlowLen)
macdLine = fastMa - slowMa
macdSignal = useSmaSignal ? ta.sma(macdLine, macdSignalLen) : ta.ema(macdLine, macdSignalLen)
macdHist = macdLine - macdSignal
macdBull = macdLine > macdSignal and macdHist > 0
macdBear = macdLine < macdSignal and macdHist < 0
macdBuyCross = ta.crossover(macdLine, macdSignal)
macdSellCross = ta.crossunder(macdLine, macdSignal)
macdNorm = normalizeToRange(macdLine, macdNormalizeLen)
macdSignalNorm = normalizeToRange(macdSignal, macdNormalizeLen)
macdHistStdev = ta.stdev(macdHist, macdNormalizeLen)
macdHistNorm = macdHistStdev != 0.0 ? math.max(math.min(macdHist / macdHistStdev * 10.0, 40.0), -40.0) : 0.0

emaFast = ta.ema(src, fastEmaLen)
emaSlow = ta.ema(src, slowEmaLen)
emaTrend = ta.ema(src, trendEmaLen)
trendBull = emaFast > emaSlow and close > emaTrend
trendBear = emaFast < emaSlow and close < emaTrend

volAvg = ta.sma(volume, volLen)
volBull = volume > volAvg and close > open
volBear = volume > volAvg and close < open

//------------------------------------------------------------------------------
// Decision model
//------------------------------------------------------------------------------
score = 0
score += rsiBull ? 2 : rsiBear ? -2 : 0
score += rsiBuyCross ? 1 : rsiSellCross ? -1 : 0
score += stochBull ? 2 : stochBear ? -2 : 0
score += stochKDCrossBuy and stochK < stochSellLevel ? 1 : stochKDCrossSell and stochK > stochBuyLevel ? -1 : 0
score += stochBuyCross ? 1 : stochSellCross ? -1 : 0
score += macdBull ? 2 : macdBear ? -2 : 0
score += macdBuyCross ? 1 : macdSellCross ? -1 : 0
score += useTrendFilter ? trendBull ? 1 : trendBear ? -1 : 0 : 0
score += useVolumeFilter ? volBull ? 1 : volBear ? -1 : 0 : 0

decision = decisionText(score)
decisionBg = decisionColor(score)
decisionCode = score >= 6 ? 2 : score >= 3 ? 1 : score <= -6 ? -2 : score <= -3 ? -1 : 0

buySignal = showBuySell and score >= 6 and score[1] < 6
sellSignal = showBuySell and score <= -6 and score[1] > -6
earlyBuy = showBuySell and score >= 3 and score[1] < 3
earlySell = showBuySell and score <= -3 and score[1] > -3

//------------------------------------------------------------------------------
// Visual levels
//------------------------------------------------------------------------------
h80 = hline(80, "Overbought 80", color=color.new(color.red, 30))
h70 = hline(70, "RSI Sell 70", color=color.new(color.red, 55))
h55 = hline(55, "Bull Bias 55", color=color.new(color.green, 70))
h50 = hline(50, "Middle 50", color=color.new(color.gray, 45))
h45 = hline(45, "Bear Bias 45", color=color.new(color.red, 70))
h30 = hline(30, "RSI Buy 30", color=color.new(color.green, 55))
h20 = hline(20, "Oversold 20", color=color.new(color.green, 30))
fill(h80, h20, color=color.new(color.purple, 95), title="Oscillator Background")
fill(h55, h45, color=color.new(color.yellow, 88), title="Neutral Bias Zone")

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------
rsiColor = rsiBull ? color.lime : rsiBear ? color.red : color.gray
stochColor = stochK > stochD ? color.lime : color.red
macdColor = macdBull ? color.aqua : macdBear ? color.orange : color.gray
histColor = macdHist >= 0 ? color.new(color.lime, 45) : color.new(color.red, 45)

plot(showRsi and not minimalView ? rsi : na, "RSI", color=rsiColor, linewidth=2)
plot(showStoch ? stochK : na, "%K Stochastic", color=stochColor, linewidth=2)
plot(showStoch ? stochD : na, "%D Stochastic", color=color.new(color.white, 0), linewidth=1)
plot(showMacd and not minimalView ? macdNorm : na, "MACD Normalized", color=macdColor, linewidth=2)
plot(showMacd and not minimalView ? macdSignalNorm : na, "MACD Signal Normalized", color=color.new(color.blue, 0), linewidth=1)
plot(showMacdHist and not minimalView ? 50 + macdHistNorm : na, "MACD Histogram Normalized Around 50", color=histColor, style=plot.style_columns, histbase=50)

plotshape(earlyBuy and not buySignal, title="Buy Setup", text="Buy", style=shape.circle, color=color.new(color.green, 0), textcolor=color.white, location=location.bottom, size=size.tiny)
plotshape(earlySell and not sellSignal, title="Sell Setup", text="Sell", style=shape.circle, color=color.new(color.maroon, 0), textcolor=color.white, location=location.top, size=size.tiny)
plotshape(buySignal, title="Strong Buy", text="BUY", style=shape.labelup, color=color.new(color.lime, 0), textcolor=color.black, location=location.bottom, size=size.small)
plotshape(sellSignal, title="Strong Sell", text="SELL", style=shape.labeldown, color=color.new(color.red, 0), textcolor=color.white, location=location.top, size=size.small)

bgcolor(paintBackground ? score >= 6 ? color.new(color.lime, 88) : score >= 3 ? color.new(color.green, 93) : score <= -6 ? color.new(color.red, 88) : score <= -3 ? color.new(color.maroon, 93) : na : na)

// Data Window values for candle hover.
plot(showDataWindow ? score : na, "Decision Score", display=display.data_window)
plot(showDataWindow ? decisionCode : na, "Decision Code: 2 Strong Buy, 1 Buy, 0 Neutral, -1 Sell, -2 Strong Sell", display=display.data_window)
plot(showDataWindow ? macdLine : na, "MACD Raw", display=display.data_window)
plot(showDataWindow ? macdSignal : na, "MACD Signal Raw", display=display.data_window)
plot(showDataWindow ? macdHist : na, "MACD Histogram Raw", display=display.data_window)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(buySignal, title="Strong Buy Decision", message="Strong BUY decision on {{ticker}}")
alertcondition(sellSignal, title="Strong Sell Decision", message="Strong SELL decision on {{ticker}}")
alertcondition(earlyBuy, title="Buy Setup", message="BUY setup on {{ticker}}")
alertcondition(earlySell, title="Sell Setup", message="SELL setup on {{ticker}}")
alertcondition(rsiBuyCross, title="RSI Buy Cross", message="RSI crossed above buy level on {{ticker}}")
alertcondition(rsiSellCross, title="RSI Sell Cross", message="RSI crossed below sell level on {{ticker}}")
alertcondition(stochBuyCross, title="Stochastic Buy Cross", message="Stochastic crossed above buy level on {{ticker}}")
alertcondition(stochSellCross, title="Stochastic Sell Cross", message="Stochastic crossed below sell level on {{ticker}}")
alertcondition(macdBuyCross, title="MACD Bullish Cross", message="MACD crossed above signal on {{ticker}}")
alertcondition(macdSellCross, title="MACD Bearish Cross", message="MACD crossed below signal on {{ticker}}")

//------------------------------------------------------------------------------
// Decision table
//------------------------------------------------------------------------------
var table decisionPanel = table.new(tablePosition(tableX, tableY), 3, 7, bgcolor=color.new(color.black, 12), frame_color=color.new(color.white, 60), frame_width=1, border_color=color.new(color.white, 80), border_width=1)

setCell(int col, int row, string txt, color bgColor, color txtColor) =>
    table.cell(decisionPanel, col, row, txt, text_color=txtColor, bgcolor=bgColor, text_size=size.small)

if barstate.islast and showTable
    table.clear(decisionPanel, 0, 0, 2, 6)
    setCell(0, 0, "Metric", color.new(color.gray, 45), color.white)
    setCell(1, 0, "State", color.new(color.gray, 45), color.white)
    setCell(2, 0, "Value", color.new(color.gray, 45), color.white)

    setCell(0, 1, "Osc Decision", color.new(color.black, 100), color.white)
    setCell(1, 1, decision, decisionBg, color.white)
    setCell(2, 1, str.tostring(score), decisionBg, color.white)

    setCell(0, 2, "Stoch K/D", color.new(color.black, 100), color.white)
    setCell(1, 2, stochBull ? "Bullish" : stochBear ? "Bearish" : "Mixed", stateColor(stochBull ? 1 : stochBear ? -1 : 0), color.white)
    setCell(2, 2, str.tostring(stochK, "#.##") + " / " + str.tostring(stochD, "#.##"), color.new(color.black, 100), color.white)

    setCell(0, 3, "Stoch Signal", color.new(color.black, 100), color.white)
    setCell(1, 3, stochBuyCross or stochKDCrossBuy ? "Buy Cross" : stochSellCross or stochKDCrossSell ? "Sell Cross" : "None", stateColor(stochBuyCross or stochKDCrossBuy ? 1 : stochSellCross or stochKDCrossSell ? -1 : 0), color.white)
    setCell(2, 3, str.tostring(stochBuyLevel, "#.#") + " / " + str.tostring(stochSellLevel, "#.#"), color.new(color.black, 100), color.white)

    setCell(0, 4, "RSI Signal", color.new(color.black, 100), color.white)
    setCell(1, 4, rsiBuyCross ? "Buy Cross" : rsiSellCross ? "Sell Cross" : "None", stateColor(rsiBuyCross ? 1 : rsiSellCross ? -1 : 0), color.white)
    setCell(2, 4, str.tostring(rsiBuyLevel, "#.#") + " / " + str.tostring(rsiSellLevel, "#.#"), color.new(color.black, 100), color.white)

    setCell(0, 5, "MACD Cross", color.new(color.black, 100), color.white)
    setCell(1, 5, macdBuyCross ? "Bull Cross" : macdSellCross ? "Bear Cross" : "None", stateColor(macdBuyCross ? 1 : macdSellCross ? -1 : 0), color.white)
    setCell(2, 5, str.tostring(macdLine, "#.####") + " / " + str.tostring(macdSignal, "#.####"), color.new(color.black, 100), color.white)

    setCell(0, 6, "Setup", color.new(color.black, 100), color.white)
    setCell(1, 6, buySignal ? "Strong Buy" : earlyBuy ? "Buy Watch" : sellSignal ? "Strong Sell" : earlySell ? "Sell Watch" : "Wait", decisionBg, color.white)
    setCell(2, 6, "Osc only", color.new(color.black, 100), color.white)

if barstate.islast and not showTable
    table.clear(decisionPanel, 0, 0, 2, 6)
````
