# COMPLETE AUTO BOT (SANTOSH)

- url: https://www.tradingview.com/script/VR3NvYGL-COMPLETE-AUTO-BOT-SANTOSH/
- type: indicator
- pine_id: PUB;7cce6a25718a42599a9d155ed0260620
- version: 1.0

## Description

यह indicator market trend को identify करके केवल strong confirmation के साथ entry signals देता है, जिससे fake signals कम होते हैं और decision making आसान होती है।

🔥 KEY FEATURES
EMA based trend direction filter
RSI momentum confirmation
MACD crossover validation
Clean BUY / SELL signals
Non-repeating signal system (state control)
Auto risk calculation (ATR based SL/TP logic)
Webhook-ready alerts for auto trading bots
Suitable for Intraday, Swing & Crypto trading
⚙️ HOW IT WORKS

Indicator पहले market trend identify करता है (bullish या bearish).
फिर EMA crossover + RSI + MACD confirmation के बाद ही final BUY या SELL signal generate करता है।

📊 USAGE
BUY signal → Uptrend continuation / breakout entry
SELL signal → Downtrend continuation / breakdown entry
Use with proper risk management for best results
⚠️ DISCLAIMER

यह indicator educational purpose के लिए है।
Financial markets में risk होता है, इसलिए proper risk management जरूरी है।

## Source Code

````pine
//@version=5
indicator("COMPLETE AUTO BOT (SANTOSH)", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━
emaLen = input.int(14, "EMA Length")
rsiLen = input.int(14, "RSI Length")
atrLen = input.int(14, "ATR Length")
rr     = input.float(2.0, "Risk Reward")

//━━━━━━━━━━━━━━━━━━━━━━
// INDICATORS
//━━━━━━━━━━━━━━━━━━━━━━
ema = ta.ema(close, emaLen)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)

[macdLine, macdSignal, _] = ta.macd(close, 12, 26, 9)

//━━━━━━━━━━━━━━━━━━━━━━
// TREND FILTER
//━━━━━━━━━━━━━━━━━━━━━━
bull = close > ema and rsi > 50 and macdLine > macdSignal
bear = close < ema and rsi < 50 and macdLine < macdSignal

//━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LOGIC
//━━━━━━━━━━━━━━━━━━━━━━
buyRaw  = bull and ta.crossover(close, ema)
sellRaw = bear and ta.crossunder(close, ema)

//━━━━━━━━━━━━━━━━━━━━━━
// STATE CONTROL (NO SPAM SIGNALS)
//━━━━━━━━━━━━━━━━━━━━━━
var int state = 0

buySignal  = buyRaw and state <= 0
sellSignal = sellRaw and state >= 0

if buySignal
    state := 1
if sellSignal
    state := -1

//━━━━━━━━━━━━━━━━━━━━━━
// RISK LEVELS
//━━━━━━━━━━━━━━━━━━━━━━
risk = atr * 1.5

longSL = close - risk
longTP = close + (risk * rr)

shortSL = close + risk
shortTP = close - (risk * rr)

//━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━
plot(ema, "EMA", color=color.orange)

plotshape(buySignal, title="BUY", location=location.belowbar,
     style=shape.labelup, text="BUY", color=color.green, textcolor=color.white)

plotshape(sellSignal, title="SELL", location=location.abovebar,
     style=shape.labeldown, text="SELL", color=color.red, textcolor=color.white)

bgcolor(bull ? color.new(color.green, 90) : bear ? color.new(color.red, 90) : na)

//━━━━━━━━━━━━━━━━━━━━━━
// ALERTS (AUTO BOT READY)
//━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="BUY ALERT",
     message='{"action":"BUY","symbol":"{{ticker}}"}')

alertcondition(sellSignal, title="SELL ALERT",
     message='{"action":"SELL","symbol":"{{ticker}}"}')
````
