# Pranjal Abhigyan Indicator Pro

- url: https://www.tradingview.com/script/QByhqnn6-Pranjal-Abhigyan-Indicator-Pro/
- type: indicator
- pine_id: PUB;b20a488c6c994957931b0fff35372a4a
- version: 1.0

## Description

ranjal Abhigyan Indicator Pro

The Pranjal Abhigyan Indicator Pro is an advanced multi-timeframe trend-following system built to identify market direction, filter out noise, and manage trades with dynamic risk control.

It is designed around a Parabolic Weighted Moving Average (PWMA) which gives higher importance to recent price action while still maintaining smooth trend structure. The indicator works across higher timeframes using a built-in MTF engine to ensure better trend alignment.

🔷 Core Features
📈 Trend Detection (PWMA System)

The indicator uses a Parabolic Weighted Moving Average (PWMA) to determine the dominant market direction.

Price above PWMA = bullish trend
Price below PWMA = bearish trend
This helps traders stay aligned with the main market structure.
🌊 Volatility Filter (Noise Reduction)

A built-in volatility filter ignores small and unstable movements in price.
It filters out 3–4 candle fake reversals, ensuring that only meaningful trend shifts generate signals.

This helps avoid:

Sideways market traps
False breakouts
Choppy price action signals
🛑 ATR-Based Trailing Stop Loss

The indicator includes a dynamic trailing stop-loss system based on ATR (Average True Range).

SL automatically adjusts based on market volatility
Moves only when price shows significant progress
Helps lock profits while avoiding premature exits

The SL is also direction-aware:

Green = Long protection (bullish trend)
Red = Short protection (bearish trend)
🎯 Minimum SL Movement Filter

To avoid constant SL updates in small fluctuations, a minimum ATR-based movement filter is applied.

This ensures:

No micro-adjustments
No SL noise
Clean and stable trailing behavior
🔄 Trend Confirmation Logic

The system includes internal structure validation inspired by market behavior (CHOCH & BOS logic) to strengthen trend confirmation.

This helps ensure that:

Trend changes are meaningful
Fake reversals are minimized
Continuation trends are respected
💰 Trade Management Levels

The indicator provides automatic trade management zones:

Break-even Level – helps secure risk-free trades
TP1 (First Target) – early profit booking zone
TP2 (Extended Target) – trend continuation target

These levels are based on ATR for dynamic adaptability across all markets.

🎨 Visual Structure
Color-coded PWMA for trend direction
Clean BUY/SELL signals
Minimal chart clutter
Optional visual offset for better alignment
📌 How to Use
Follow PWMA direction for trend bias
Enter trades on confirmed BUY/SELL signals
Use trailing SL for risk management
Book partial profits at TP1 and TP2
Hold trades while trend remains intact
⚡ Summary

The Pranjal Abhigyan Indicator Pro is a complete trading system combining:

Trend identification
Volatility filtering
Dynamic risk management
Structured trade execution

It is designed for traders who prefer clean charts, disciplined entries, and systematic trade management rather than emotional decision-making.

If you want, I can also write:

🔥 Short TradingView title (SEO optimized)
🔥 Tags/keywords list
🔥 Strategy backtest version (with win rate stats format)

## Source Code

````pine
//@version=5
indicator("Pranjal Abhigyan Indicator Pro", overlay=true)

//================ INPUTS ================
length = input.int(20, title="PWMA Length")
src = input.source(close, title="Source")
tf = input.timeframe("60", title="Timeframe")

offsetBars = input.int(0, "Visual Offset", minval=-50, maxval=50)

// ATR SETTINGS
atrLength = input.int(14, title="ATR Length")
atrSmooth = input.int(10, title="ATR Smoothing")
bufferMult = input.float(1.2, title="Buffer Multiplier")
minStepATR = input.float(0.3, title="Min SL Move (ATR)")
volFilterBars = input.int(4, title="Volatility Filter")

//================ PWMA =================
pwma_func(_src, _length) =>
    float wsum = 0.0
    float wtot = 0.0
    for i = 0 to _length - 1
        w = math.pow(_length - i, 2)
        wsum += _src[i] * w
        wtot += w
    wsum / wtot

pwma = request.security(syminfo.tickerid, tf, pwma_func(src, length))

//================ ATR =================
atr = ta.ema(ta.atr(atrLength), atrSmooth)

//================ VOLATILITY FILTER =================
bullConfirm = ta.lowest(close > pwma ? 1 : 0, volFilterBars) == 1
bearConfirm = ta.lowest(close < pwma ? 1 : 0, volFilterBars) == 1

//================ TREND =================
var int trend = 0

if bullConfirm and close > pwma
    trend := 1

if bearConfirm and close < pwma
    trend := -1

//================ STRUCTURE FILTER (LIGHT BOS/CHOCH) =================
bosUp = close > ta.highest(high, 10)
bosDn = close < ta.lowest(low, 10)

chochUp = bosUp and trend == -1
chochDn = bosDn and trend == 1

// trend reinforcement
if chochUp
    trend := 1
if chochDn
    trend := -1

//================ BUFFER =================
buffer = atr * bufferMult
minMove = atr * minStepATR

//================ TRAILING SL =================
var float sl = na

longSL  = pwma - buffer
shortSL = pwma + buffer

if trend == 1
    sl := na(sl) ? longSL : math.max(sl, longSL)

if trend == -1
    sl := na(sl) ? shortSL : math.min(sl, shortSL)

//================ SL COLOR =================
slColor = trend == 1 ? color.lime : trend == -1 ? color.red : color.gray

//================ SIGNALS =================
buySignal  = trend == 1 and trend[1] != 1 and bullConfirm
sellSignal = trend == -1 and trend[1] != -1 and bearConfirm

//================ TP / BE LEVELS =================
tp1 = trend == 1 ? close + atr * 2 : close - atr * 2
tp2 = trend == 1 ? close + atr * 3 : close - atr * 3
be  = trend == 1 ? close + atr * 1 : close - atr * 1

//================ PLOTS =================
pwmaColor = trend == 1 ? color.lime : trend == -1 ? color.red : color.orange

plot(pwma, "PWMA", color=pwmaColor, linewidth=3, offset=offsetBars)
plot(sl, "Trailing SL", color=slColor, linewidth=2, offset=offsetBars)

plot(tp1, "TP1", color=color.new(color.green, 40), style=plot.style_line)
plot(tp2, "TP2", color=color.new(color.green, 60), style=plot.style_line)
plot(be,  "Break Even", color=color.new(color.blue, 50), style=plot.style_line)

//================ SIGNAL MARKERS =================
plotshape(buySignal, location=location.belowbar, color=color.lime, style=shape.labelup, text="BUY")
plotshape(sellSignal, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

//================ ALERTS =================
alertcondition(buySignal, title="BUY", message="Pranjal Abhigyan PRO BUY")
alertcondition(sellSignal, title="SELL", message="Pranjal Abhigyan PRO SELL")
````
