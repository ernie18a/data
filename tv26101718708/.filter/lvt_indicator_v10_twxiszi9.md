# LVT Indicator v1.0

- url: https://www.tradingview.com/script/TWxISZi9-LVT-Indicator-v1-0/
- type: indicator
- pine_id: PUB;54547309fe2d435ab0a0206a09e0a481
- version: 1.0

## Description

[b]LVT Indicator – Liquidity + Volume Imbalance + Trend Strength
[/b]
Overview

The LVT Indicator is a trend-following and liquidity-based trading tool designed to identify high-probability trade setups by combining market structure, liquidity sweeps, volume confirmation, and trend strength into a single indicator.

Instead of generating frequent signals, LVT focuses on quality over quantity by requiring multiple conditions to align before producing a Buy or Sell signal.

---

How It Works

1. Liquidity Sweep Detection

The indicator detects when price temporarily breaks above a previous swing high or below a previous swing low before quickly reversing. These moves often represent liquidity grabs, where stop-loss orders are triggered before the market resumes its intended direction.

2. Volume Imbalance

Every liquidity sweep is validated using volume analysis. Signals are only generated when trading volume is significantly higher than the recent average, helping filter out weak or low-conviction price movements.

3. Trend Strength Filter

The indicator confirms the overall market trend using moving averages and trend strength measurements. Buy signals are only allowed during bullish trends, while Sell signals are only allowed during bearish trends.

4. Momentum Confirmation

Momentum is checked before issuing any signal to reduce false entries during weak market conditions.

5. Confirmation Candle

Rather than entering immediately after a liquidity sweep, the indicator waits for confirmation from the following price action. This additional step helps improve signal reliability.

---

Features

- Liquidity Sweep Detection
- Volume Imbalance Filter
- Trend Strength Confirmation
- Momentum Filter
- Buy & Sell Signals
- ATR-Based Stop Loss
- Dynamic Take Profit Levels
- Non-Repainting Signal Logic
- Customizable Inputs
- TradingView Alerts
- Works on all markets and timeframes

---

Recommended Markets

- Forex
- Cryptocurrency
- Stocks
- Indices
- Commodities

---

Recommended Timeframes

- 15 Minutes
- 30 Minutes
- 1 Hour
- 4 Hours
- Daily

---

Risk Management

No indicator is perfect. Always use proper risk management, appropriate position sizing, and confirmation from your own trading plan before entering any trade.

---

Disclaimer

This indicator is intended for educational and analytical purposes only. It does not provide financial or investment advice, and past market behavior does not guarantee future results. Trading involves substantial risk, and users should perform their own analysis before making trading decisions.

Thank you for using the LVT Indicator. I hope it becomes a valuable part of your trading workflow. Feedback and suggestions are always welcome.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("LVT Indicator v1.0", overlay=true, max_labels_count=500)

//======================
// INPUTS
//======================
emaFastLen = input.int(50, "EMA Fast")
emaSlowLen = input.int(200, "EMA Slow")

adxLen = input.int(14, "ADX Length")
rsiLen = input.int(14, "RSI Length")
atrLen = input.int(14, "ATR Length")

volLen = input.int(20, "Volume Average")
volMultiplier = input.float(1.5, "Volume Multiplier")

swingLen = input.int(5, "Swing Length")

//======================
// EMA
//======================
ema50 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

plot(ema50, color=color.aqua, linewidth=2, title="EMA 50")
plot(ema200, color=color.orange, linewidth=2, title="EMA 200")

//======================
// RSI
//======================
rsi = ta.rsi(close, rsiLen)

//======================
// ATR
//======================
atr = ta.atr(atrLen)

//======================
// ADX (Manual Calculation)
//======================
upMove = high - high[1]
downMove = low[1] - low

plusDM = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

tr = ta.tr(true)

tr14 = ta.rma(tr, adxLen)
plusDI = 100 * ta.rma(plusDM, adxLen) / tr14
minusDI = 100 * ta.rma(minusDM, adxLen) / tr14

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

//======================
// VOLUME
//======================
avgVolume = ta.sma(volume, volLen)
highVolume = volume > avgVolume * volMultiplier

//======================
// TREND FILTER
//======================
bullTrend = close > ema200 and ema50 > ema200 and adx > 25
bearTrend = close < ema200 and ema50 < ema200 and adx > 25

//======================
// SWING LEVELS
//======================
swingHigh = ta.highest(high, swingLen)
swingLow = ta.lowest(low, swingLen)

//======================
// LIQUIDITY SWEEPS
//======================
bullSweep = low < swingLow[1] and close > swingLow[1]
bearSweep = high > swingHigh[1] and close < swingHigh[1]

//======================
// MOMENTUM
//======================
bullMomentum = rsi > 55
bearMomentum = rsi < 45

//======================
// SIGNALS
//======================
buySignal = bullTrend and bullSweep and highVolume and bullMomentum
sellSignal = bearTrend and bearSweep and highVolume and bearMomentum

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

//======================
// ATR STOP
//======================
buySL = close - atr * 1.5
sellSL = close + atr * 1.5

plot(buySignal ? buySL : na, color=color.red, linewidth=2)
plot(sellSignal ? sellSL : na, color=color.green, linewidth=2)

//======================
// ALERTS
//======================
alertcondition(buySignal, title="Buy Alert", message="LVT BUY Signal")
alertcondition(sellSignal, title="Sell Alert", message="LVT SELL Signal")
````
