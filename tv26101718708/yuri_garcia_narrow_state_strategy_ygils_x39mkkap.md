# Yuri Garcia Narrow State Strategy (YGILS)

- url: https://www.tradingview.com/script/x39mKkAp-Yuri-Garcia-Narrow-State-Strategy-YGILS/
- type: strategy
- pine_id: PUB;eebb7ecfc179447794ebe41e84971579
- version: 1.0

## Description

Overview

The Yuri Garcia Institutional Liquidity Strategy (YGILS) is a trend-following and volatility-expansion methodology designed to identify high-probability trading opportunities during periods of market compression and directional momentum.

The strategy combines trend analysis, volatility measurements, momentum confirmation, and risk management into a structured framework that helps traders identify potential institutional participation while maintaining disciplined execution.

The primary objective is not to predict every market move, but rather to participate when multiple conditions align in favor of a directional expansion.

---

Strategy Philosophy

Markets alternate between periods of compression and expansion.

During compression, price contracts, volatility decreases, and market participants become indecisive.

During expansion, volatility increases, momentum accelerates, and directional opportunities emerge.

The strategy is specifically designed to identify the transition from low-volatility environments to high-volatility environments.

The Narrow State identifies compression.

The Elephant Bar identifies expansion.

The highest-quality opportunities typically occur when an Elephant Bar appears shortly after a period of compression and in the direction of the prevailing trend.

---

Core Components

Trend Identification

The strategy uses:

• 20 EMA (Short-Term Momentum)

• 200 SMA (Long-Term Trend)

Bullish Environment

✓ Price above 200 SMA

✓ 20 EMA above 200 SMA

Bearish Environment

✓ Price below 200 SMA

✓ 20 EMA below 200 SMA

This trend filter prevents traders from taking long positions against a bearish market and short positions against a bullish market.

---

Narrow State

A Narrow State occurs when the distance between the EMA 20 and SMA 200 contracts below a user-defined percentage threshold.

Formula:

Distance % = |EMA20 − SMA200| ÷ SMA200 × 100

The Narrow State represents a market compression phase.

Historically, significant market moves frequently begin after periods of compression.

The strategy seeks to participate during the transition from compression into expansion.

Important

The optimal Narrow State threshold depends on the instrument, timeframe, and market volatility.

Lower values produce stricter setups and fewer signals.

Higher values produce more signals but may increase market noise.

Traders are encouraged to optimize this setting based on the specific market being traded.

---

Elephant Bars

An Elephant Bar represents a significant expansion in volatility and directional conviction.

The candle body must exceed the Average True Range (ATR) multiplied by the Elephant Bar Multiplier selected by the user.

Formula:

Candle Body Size > ATR × Elephant Multiplier

Example

ATR = 20 points

Elephant Multiplier = 1.5

Required Body Size = 30 points

Any candle whose body exceeds 30 points is classified as an Elephant Bar.

---

Bullish Elephant Bar

Requirements:

✓ Bullish Candle

✓ Body exceeds ATR threshold

✓ Bullish Trend Active

Bullish Elephant Bars suggest aggressive buying pressure and potential institutional participation.

---

Bearish Elephant Bar

Requirements:

✓ Bearish Candle

✓ Body exceeds ATR threshold

✓ Bearish Trend Active

Bearish Elephant Bars suggest aggressive selling pressure and potential institutional participation.

---

Why Elephant Bars Matter

Institutional traders typically enter positions using significant volume and liquidity.

This often creates unusually large candles relative to recent market activity.

Elephant Bars help identify those moments where participation increases dramatically and may signal the beginning of a directional expansion phase.

---

RBI and GBI Confirmation Patterns

The strategy includes continuation confirmations.

RBI (Red Bar Ignored)

Bullish Continuation Pattern

Requirements:

• Previous candle closes bearish

• Current candle closes bullish

• Current candle closes above previous high

• Bullish trend remains active

This pattern suggests buyers have regained control.

---

GBI (Green Bar Ignored)

Bearish Continuation Pattern

Requirements:

• Previous candle closes bullish

• Current candle closes bearish

• Current candle closes below previous low

• Bearish trend remains active

This pattern suggests sellers have regained control.

---

Entry Conditions

Long Positions

A BUY signal occurs when:

✓ Bullish Trend Active

✓ Narrow State Active

✓ Bullish Elephant Bar OR RBI Pattern

✓ No Existing Long Position

---

Short Positions

A SELL signal occurs when:

✓ Bearish Trend Active

✓ Narrow State Active

✓ Bearish Elephant Bar OR GBI Pattern

✓ No Existing Short Position

---

Risk Management

The strategy uses ATR-based stop loss calculations that automatically adapt to changing market volatility.

Formula:

Stop Loss = Entry ± ATR × Multiplier

This helps maintain consistent risk management across different instruments and market conditions.

---

Take Profit Logic

The strategy uses configurable Risk-to-Reward ratios.

Formula:

Target = ATR × Multiplier × Risk Reward Ratio

Example:

Risk = 50 points

Target = 100 points

Reward Ratio = 2:1

This allows traders to maintain a structured and repeatable approach to position management.

---

Inputs and Customization

ATR Length

Controls volatility calculations.

Higher values create smoother signals.

Lower values create faster reactions.

---

ATR Multiplier

Controls stop-loss distance.

Higher values provide more room for volatility.

Lower values create tighter risk control.

---

Risk Reward Ratio (RRR)

Controls profit target distance relative to stop-loss distance.

Common values:

• 2.0

• 3.0

• 4.0

---

Elephant Bar Multiplier

Controls how large a candle must be before being classified as an Elephant Bar.

Higher values:

• Fewer signals

• Stronger momentum requirements

Lower values:

• More signals

• Faster entries

---

Narrow State Percentage

Controls how close the EMA 20 and SMA 200 must be before a compression phase is recognized.

Smaller values:

• Stricter setups

• Higher selectivity

Larger values:

• More opportunities

• Increased signal frequency

---

Best Practice

The strategy performs best when used as a confirmation tool rather than a prediction tool.

Wait for trend alignment.

Wait for compression.

Wait for volatility expansion.

Then execute according to the rules.

Patience and discipline are often more important than prediction.

The market rewards consistency more than excitement.

---

Disclaimer

This strategy is intended for educational and research purposes only.

Past performance does not guarantee future results.

Always perform your own testing, validation, and risk management before trading live capital.

## Source Code

````pine
//@version=6
strategy("Yuri Garcia Narrow State Strategy", overlay=true, pyramiding=0, default_qty_type=strategy.percent_of_equity, default_qty_value=2)

atrLen = input.int(14, "ATR Length")
atrMult = input.float(2.0, "Stop Mult xATR")
rrr = input.float(2.0, "RRR")
tradeDirection = input.string("Both", "Trade Direction", options=["Both", "Buy Only", "Sell Only"])

emaFastLen = input.int(20, "Fast EMA Length")
smaSlowLen = input.int(200, "Slow SMA Length")
multElephant = input.float(1.5, "Elephant Bar Multiplier")
maxDistancePct = input.float(1.5, "Narrow State Max Distance Percent")

canBuy = tradeDirection == "Both" or tradeDirection == "Buy Only"
canSell = tradeDirection == "Both" or tradeDirection == "Sell Only"

atr = ta.atr(atrLen)
tick = syminfo.mintick

roundPrice(p) =>
    math.round(p / tick) * tick

ema20 = ta.ema(close, emaFastLen)
sma200 = ta.sma(close, smaSlowLen)

maDistancePct = math.abs(ema20 - sma200) / sma200 * 100
isNarrowState = maDistancePct <= maxDistancePct

bullishTrend = close > sma200 and ema20 > sma200
bearishTrend = close < sma200 and ema20 < sma200

candleBody = math.abs(close - open)
isElephant = candleBody > atr * multElephant

bullishElephant = isElephant and close > open and bullishTrend
bearishElephant = isElephant and close < open and bearishTrend

rbiBuy = bullishTrend and close[1] < open[1] and close > open and close > high[1]
gbiSell = bearishTrend and close[1] > open[1] and close < open and close < low[1]

condLong = (bullishElephant or rbiBuy) and isNarrowState
condShort = (bearishElephant or gbiSell) and isNarrowState

newLong = condLong and canBuy and strategy.position_size <= 0
newShort = condShort and canSell and strategy.position_size >= 0

longSL = roundPrice(close - atr * atrMult)
shortSL = roundPrice(close + atr * atrMult)

longTP = roundPrice(close + atr * atrMult * rrr)
shortTP = roundPrice(close - atr * atrMult * rrr)

if newLong
    strategy.entry("LONG", strategy.long)

if newShort
    strategy.entry("SHORT", strategy.short)

strategy.exit("TP SL LONG", from_entry="LONG", stop=longSL, limit=longTP)
strategy.exit("TP SL SHORT", from_entry="SHORT", stop=shortSL, limit=shortTP)

emaColor = ema20 > sma200 ? color.lime : color.red

plot(ema20, title="20 EMA", color=emaColor, linewidth=2)
plot(sma200, title="200 SMA", color=color.white, linewidth=3)

bgcolor(isNarrowState ? color.new(color.green, 92) : na)

plotshape(newLong, title="BUY", text="BUY", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(newShort, title="SELL", text="SELL", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

alertcondition(newLong, title="BUY Signal", message="BUY")
alertcondition(newShort, title="SELL Signal", message="SELL")

if newLong
    alert('{"user_id":"35,57,59,78,79,80,81,83,88,90,91,93,95,96,97,98,99,100,101,102,103,104,105,106,107,108","secret":"YGCLOUD2025","symbol":"' + syminfo.ticker + '","side":"BUY","signal":"OPEN","entry_price":' + str.tostring(close) + ',"tp_price":' + str.tostring(longTP) + ',"sl_price":' + str.tostring(longSL) + '}', alert.freq_once_per_bar_close)

if newShort
    alert('{"user_id":"35,57,59,78,79,80,81,83,88,90,91,93,95,96,97,98,99,100,101,102,103,104,105,106,107,108","secret":"YGCLOUD2025","symbol":"' + syminfo.ticker + '","side":"SELL","signal":"OPEN","entry_price":' + str.tostring(close) + ',"tp_price":' + str.tostring(shortTP) + ',"sl_price":' + str.tostring(shortSL) + '}', alert.freq_once_per_bar_close)
````
