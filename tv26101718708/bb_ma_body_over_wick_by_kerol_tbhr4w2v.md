# BB + MA + Body Over Wick by KEROL

- url: https://www.tradingview.com/script/tbhr4w2v-BB-MA-Body-Over-Wick-by-KEROL/
- type: indicator
- pine_id: PUB;9f58b69a57a4408fa63500b78cfb6eda
- version: 1.0

## Description

This indicator combines 3 technical analysis tools into one TradingView Pine Script:

---

# 1. Moving Average (MA 9 & MA 21)

It plots:

* **MA 9 (Blue)** → short-term trend
* **MA 21 (Red)** → medium-term trend

### How traders use it

* **MA9 above MA21** → bullish momentum
* **MA9 below MA21** → bearish momentum
* Crossovers can indicate trend changes.

### Example

* Blue crosses above Red → possible BUY momentum
* Blue crosses below Red → possible SELL momentum

---

# 2. Bollinger Bands (BB)

The script also plots:

* Upper Band
* Middle Band (20 SMA)
* Lower Band

Using:

* Length = 20
* Multiplier = 2

### What Bollinger Bands show

They measure:

* volatility
* overbought/oversold zones
* breakout potential

### Interpretation

* Price near **Upper BB** → market may be overbought
* Price near **Lower BB** → market may be oversold
* Bands expanding → high volatility
* Bands squeezing → possible breakout coming

---

# 3. Body Over Wick Signal

This is the custom signal logic.

## Bullish Signal (BULL label)

A bullish label appears when:

* current candle closes bullish (`close > open`)
* candle body breaks above previous candle high

Meaning:

* buyers are strong
* bullish momentum continuation

The script shows:

* green “BULL” label below candle

---

## Bearish Signal (BEAR label)

A bearish label appears when:

* current candle closes bearish (`close < open`)
* candle body breaks below previous candle low

Meaning:

* sellers are strong
* bearish momentum continuation

The script shows:

* red “BEAR” label above candle

---

# 4. Latest Signal Only

The script deletes old labels and keeps:

* only the latest BULL or BEAR signal visible

This keeps the chart clean.

---

# 5. Alerts

TradingView alerts can be created for:

* Bullish signal
* Bearish signal

Useful for:

* gold trading
* forex scalping
* breakout trading
* trend continuation setups

---

# Best Use Case

This indicator works best for:

* XAUUSD / Gold
* Forex
* Index scalping
* Intraday trend trading

Especially when:

* MA trend aligns
* price reacts at Bollinger Bands
* body-over-wick breakout appears

---

# Example Trading Idea

## BUY Setup

* MA9 above MA21
* Price near middle or lower BB
* BULL signal appears

→ Potential continuation upward.

## SELL Setup

* MA9 below MA21
* Price near middle or upper BB
* BEAR signal appears

→ Potential continuation downward.

## Source Code

````pine
//@version=6
indicator("BB + MA + Body Over Wick", overlay=true)

// ======================================================
// MOVING AVERAGE
// ======================================================

ma9 = ta.sma(close, 9)
ma21 = ta.sma(close, 21)

plot(ma9, title="MA 9", color=color.blue, linewidth=2)
plot(ma21, title="MA 21", color=color.red, linewidth=2)

// ======================================================
// BOLLINGER BAND
// ======================================================

bbLength = input.int(20, "BB Length")
bbMult = input.float(2.0, "BB Multiplier")

basis = ta.sma(close, bbLength)
dev = ta.stdev(close, bbLength) * bbMult

upperBB = basis + dev
lowerBB = basis - dev

plot(upperBB, title="Upper BB", color=color.red, linewidth=1)
plot(basis, title="Middle BB", color=color.gray, linewidth=1)
plot(lowerBB, title="Lower BB", color=color.lime, linewidth=1)

// ======================================================
// BODY OVER WICK SIGNAL
// ======================================================

// Previous candle
prevHigh = high[1]
prevLow = low[1]

// Current candle body
bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)

// Signals
bullSignal = close > open and bodyHigh > prevHigh
bearSignal = close < open and bodyLow < prevLow

// ======================================================
// SHOW ONLY LATEST SIGNAL
// ======================================================

var label latestLabel = na

if bullSignal
    label.delete(latestLabel)

    latestLabel := label.new(
         bar_index,
         low,
         "BULL",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.white,
         size=size.small
     )

if bearSignal
    label.delete(latestLabel)

    latestLabel := label.new(
         bar_index,
         high,
         "BEAR",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )

// ======================================================
// ALERTS
// ======================================================

alertcondition(bullSignal, title="Bullish", message="Bullish body over wick")

alertcondition(bearSignal, title="Bearish", message="Bearish body over wick")
````
