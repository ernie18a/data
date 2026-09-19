<!-- tradingview-pine-id: PUB;896656b133864e018a38d6fbf689584f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PRO TREND BOX

Source: https://www.tradingview.com/script/BYXt4sTy-PRO-TREND-BOX/

## Description

PRO SMC 2 MACD is a multi-confirmation market analysis indicator designed to analyze price action candle by candle. Instead of relying on a single indicator, it combines two MACD systems, EMA trend structure, trend path, market structure, Break of Structure (BOS), support/resistance and supply/demand areas to identify potential bullish and bearish opportunities.

The purpose of the indicator is not simply to display BUY and SELL labels. Every signal is generated from a combination of market conditions, allowing traders to understand why a particular candle receives a bullish, bearish, or neutral interpretation.

---

🟢 BUY SIGNAL — Complete Reason

When a BUY signal appears, the indicator looks for several bullish confirmations.

1. MACD 1 — Short-Term Momentum

The first MACD analyzes shorter-term momentum.

When MACD 1 becomes bullish, it suggests that buying momentum is increasing and buyers are beginning to gain control over the short-term price movement.

2. MACD 2 — Larger Momentum Confirmation

The second MACD uses slower settings and therefore provides a broader momentum confirmation.

When both MACDs point upward at the same time, the probability of the bullish setup being stronger increases compared with relying on only one MACD.

3. EMA 20 Above EMA 50

When the 20 EMA is above the 50 EMA, short-term price momentum is stronger than the medium-term trend.

This supports the idea that the market is developing a bullish structure.

4. EMA 50 Above EMA 200

The 50 EMA and 200 EMA are used as a major trend filter.

When:

EMA 20 > EMA 50 > EMA 200

the overall market structure is considered strongly bullish.

5. Trend Path

The Trend Path follows the underlying price direction and helps visually identify whether the market is moving upward or downward.

A rising Trend Path supports bullish conditions, while a falling Trend Path supports bearish conditions.

6. Market Structure

The indicator observes important swing highs and swing lows.

When price begins creating:

Higher Highs + Higher Lows

it indicates that buyers are gaining structural control.

7. Bullish BOS

A Bullish Break of Structure (BOS) occurs when price breaks above an important previous swing high.

This can indicate that buyers have overcome a previous resistance level and that the market structure may be continuing upward.

8. Support / Demand Area

If bullish momentum develops near an important support or demand area, the setup receives additional structural support.

This is important because the indicator is not only looking at momentum—it is also considering where the price is trading.

9. Final BUY Confirmation

When multiple conditions align:

Bullish Momentum + Bullish Trend + Bullish Structure + Support/Demand + BOS

the candle can receive a BUY confirmation.

---

🔴 SELL SIGNAL — Complete Reason

When a SELL signal appears, the indicator looks for the opposite conditions.

1. MACD 1 — Bearish Momentum

MACD 1 moves below its signal line, indicating that short-term selling momentum is increasing.

2. MACD 2 — Bearish Confirmation

MACD 2 also confirms bearish momentum.

When both MACDs agree, the bearish setup receives stronger momentum confirmation.

3. EMA 20 Below EMA 50

When the 20 EMA moves below the 50 EMA, short-term momentum is weaker than the medium-term trend.

This supports a bearish environment.

4. EMA 50 Below EMA 200

When:

EMA 20 < EMA 50 < EMA 200

the broader trend is considered bearish.

5. Falling Trend Path

A declining Trend Path supports the idea that sellers are controlling the current market direction.

6. Bearish Market Structure

The indicator observes whether price is forming:

Lower Highs + Lower Lows

This structure suggests that sellers are gaining control.

7. Bearish BOS

A Bearish Break of Structure occurs when price breaks below an important previous swing low.

This can indicate that sellers have successfully broken a structural support level.

8. Resistance / Supply Area

When price reaches an important resistance or supply area and bearish momentum develops, the setup receives additional confirmation.

9. Final SELL Confirmation

When multiple bearish conditions align:

Bearish Momentum + Bearish Trend + Bearish Structure + Resistance/Supply + BOS

the candle can receive a SELL confirmation.

---

⚪ NO TRADE — Why Some Candles Have No Signal

A professional system should not force a BUY or SELL signal on every candle.

A candle may remain neutral when:

MACD 1 is bullish but MACD 2 is bearish

MACD 1 and MACD 2 are conflicting

EMA 20 and EMA 50 are moving sideways

Price is trapped between support and resistance

Market structure is unclear

No valid BOS has occurred

Price is moving sideways/choppy

Buyers and sellers have similar strength

The trend is not sufficiently confirmed

In these situations, the safest interpretation is:

NO CLEAR CONFIRMATION → WAIT

---

🧠 Candle-by-Candle Decision Process

The indicator follows a structured process:

1. Price Candle
↓
2. Momentum Analysis
↓
3. MACD 1 Confirmation
↓
4. MACD 2 Confirmation
↓
5. EMA Trend Analysis
↓
6. Trend Path
↓
7. Market Structure
↓
8. BOS / Structural Break
↓
9. Support, Resistance & Zones
↓
10. Final BUY / SELL / NO TRADE Decision

This makes the indicator more than a simple crossover system. It attempts to combine momentum + trend + structure + location into one trading framework.

---

⭐ Signal Strength Concept

🟢 Strong Bullish Environment

2 MACD Bullish + EMA Bullish + Higher High/Higher Low + Bullish BOS + Demand/Support

🔴 Strong Bearish Environment

2 MACD Bearish + EMA Bearish + Lower High/Lower Low + Bearish BOS + Supply/Resistance

🟡 Weak / Uncertain Environment

MACD Conflict + Sideways EMA + No Clear Structure

➡️ Wait for confirmation.

---

⚠️ Important

This indicator provides technical-analysis signals, not guaranteed predictions. A BUY or SELL signal represents a combination of programmed conditions and does not guarantee that price will move in the expected direction. Proper risk management, confirmation and independent analysis are still important.

---

## Source Code

````pine
//@version=6
indicator("PRO TREND BOX", overlay=true)

ema20 = ta.ema(close,20)
ema50 = ta.ema(close,50)

up = ema20 > ema50
dn = ema20 < ema50

plot(ema20, "Trend", color=color.blue, linewidth=3)
plot(ema50, "Base", color=color.orange, linewidth=2)

buy = ta.crossover(ema20,ema50)
sell = ta.crossunder(ema20,ema50)

plotshape(buy, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white)
plotshape(sell, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white)

bgcolor(up ? color.new(color.green,90) : dn ? color.new(color.red,90) : na)
````
