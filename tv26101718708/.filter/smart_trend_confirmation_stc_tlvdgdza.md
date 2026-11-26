# Smart Trend Confirmation (STC)

- url: https://www.tradingview.com/script/tLVDgDza-Smart-Trend-Confirmation-STC/
- type: indicator
- pine_id: PUB;3207bed1f2f341c79b666abb7c92ba55
- version: 1.0

## Description

[b]🚀 Introducing Smart Trend Confirmation (STC)[/b]

Tired of taking trades against the trend? The Smart Trend Confirmation (STC) indicator is designed to help traders identify high-probability setups by combining trend, momentum, and volume into one simple system.

🔍[b] How It Works[/b]

✅ Trend Filter (EMA 200)

- Price above the 200 EMA = Only look for Buy opportunities.
- Price below the 200 EMA = Only look for Sell opportunities.

✅ Pullback Detection (EMA 20)
Instead of chasing price, STC waits for a healthy pullback toward the 20 EMA before looking for an entry.

✅ Momentum Confirmation (RSI)

- RSI above 55 confirms bullish momentum.
- RSI below 45 confirms bearish momentum.

✅ Volume Confirmation
Signals are generated only when trading volume is above its average, helping filter out weak market moves.

✅ ATR-Based Risk Management
The indicator automatically calculates dynamic Stop Loss and Take Profit levels using ATR, adapting to current market volatility.

📈 Buy Conditions

• Price above the 200 EMA
• Pullback near the 20 EMA
• RSI above 55
• Volume above average
• Bullish candle closes

📉 Sell Conditions

• Price below the 200 EMA
• Pullback near the 20 EMA
• RSI below 45
• Volume above average
• Bearish candle closes

⭐ Key Features

✔ Trend-following strategy
✔ Non-repainting signals (generated after candle close)
✔ Dynamic Stop Loss & Take Profit
✔ Buy/Sell alerts
✔ Works on Forex, Crypto, Stocks, and Indices

Best Timeframes: 15M, 1H, and 4H.

⚠️ No indicator is 100% accurate. Always use proper risk management and combine signals with your own market analysis before entering a trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Smart Trend Confirmation (STC)", overlay=true, max_labels_count=500)

//=========================
// Inputs
//=========================
emaFastLen = input.int(20, "Fast EMA", minval=1)
emaTrendLen = input.int(200, "Trend EMA", minval=1)
rsiLen = input.int(14, "RSI Length", minval=2)
volLen = input.int(20, "Volume SMA Length", minval=1)
atrLen = input.int(14, "ATR Length", minval=1)
atrSL = input.float(1.5, "Stop Loss ATR Multiplier", step=0.1)
atrTP = input.float(3.0, "Take Profit ATR Multiplier", step=0.1)
pullbackPct = input.float(0.5, "Pullback Distance (%)", step=0.1)

//=========================
// Calculations
//=========================
ema20 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaTrendLen)

rsi = ta.rsi(close, rsiLen)

volAvg = ta.sma(volume, volLen)

atr = ta.atr(atrLen)

bullTrend = close > ema200
bearTrend = close < ema200

pullbackLong = math.abs(close - ema20) / ema20 * 100 <= pullbackPct
pullbackShort = math.abs(close - ema20) / ema20 * 100 <= pullbackPct

bullMomentum = rsi > 55
bearMomentum = rsi < 45

highVolume = volume > volAvg

bullCandle = close > open
bearCandle = close < open

buySignal = bullTrend and pullbackLong and bullMomentum and highVolume and bullCandle
sellSignal = bearTrend and pullbackShort and bearMomentum and highVolume and bearCandle

//=========================
// Plot EMAs
//=========================
plot(ema20, color=color.orange, linewidth=2, title="EMA 20")
plot(ema200, color=color.blue, linewidth=2, title="EMA 200")

//=========================
// Background Trend
//=========================
bgcolor(bullTrend ? color.new(color.green, 92) :
       bearTrend ? color.new(color.red, 92) : na)

//=========================
// Buy/Sell Signals
//=========================
plotshape(buySignal,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small,
     text="BUY")

plotshape(sellSignal,
     title="SELL",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="SELL")

//=========================
// ATR Stop Loss & Take Profit
//=========================
var line slLine = na
var line tpLine = na

if buySignal
    line.delete(slLine)
    line.delete(tpLine)

    sl = close - atr * atrSL
    tp = close + atr * atrTP

    slLine := line.new(bar_index, sl, bar_index + 20, sl,
         color=color.red, width=2)

    tpLine := line.new(bar_index, tp, bar_index + 20, tp,
         color=color.green, width=2)

if sellSignal
    line.delete(slLine)
    line.delete(tpLine)

    sl = close + atr * atrSL
    tp = close - atr * atrTP

    slLine := line.new(bar_index, sl, bar_index + 20, sl,
         color=color.red, width=2)

    tpLine := line.new(bar_index, tp, bar_index + 20, tp,
         color=color.green, width=2)

//=========================
// Alerts
//=========================
alertcondition(buySignal, title="STC Buy", message="Smart Trend Confirmation BUY")
alertcondition(sellSignal, title="STC Sell", message="Smart Trend Confirmation SELL")
````
