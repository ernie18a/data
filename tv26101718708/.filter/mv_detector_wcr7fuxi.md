# MV Detector

- url: https://www.tradingview.com/script/WCr7Fuxi-MV-Detector/
- type: indicator
- pine_id: PUB;3f31a4ec078c415eb5e79f05ce19b39d
- version: 2.0

## Description

Absolutely 👍 Let’s first understand **each part of the current script** properly. Once you understand this, the **pro version** will make much more sense.

Think of the current script as a **Minervini Trend Template filter** — it does **not** find exact buy points yet. It only tells you:

> “This stock is in a strong enough technical trend to study further.”

***

# 1. Moving Averages: 50, 150, 200 DMA

Your script calculates:

```pinescript
sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)
```

These are:

*   **50 DMA** = short/medium-term trend
*   **150 DMA** = intermediate trend
*   **200 DMA** = long-term trend

In Minervini’s method, a strong stock usually has:

```text
Price > 50 DMA > 150 DMA > 200 DMA
```

This means the stock is in a **clean uptrend**.

***

# 2. Plotting the Moving Averages

```pinescript
plot(sma50, color=color.blue, linewidth=2)
plot(sma150, color=color.orange, linewidth=2)
plot(sma200, color=color.red, linewidth=2)
```

This simply draws the lines on your chart.

Your visual meaning:

| Line   | Meaning |
| ------ | ------- |
| Blue   | 50 DMA  |
| Orange | 150 DMA |
| Red    | 200 DMA |

Ideal Minervini structure:

```text
Blue line above Orange line above Red line
```

That shows strength.

***

# 3. Condition 1: Price Above 150 and 200 DMA

```pinescript
cond1 = close > sma150 and close > sma200
```

This checks whether price is above both:

*   150 DMA
*   200 DMA

Why it matters:

If price is below these, the stock may still be weak or in a downtrend.

Minervini wants stocks already showing strength, not “cheap” stocks.

***

# 4. Condition 2: 150 DMA Above 200 DMA

```pinescript
cond2 = sma150 > sma200
```

This confirms the **intermediate trend is stronger than the long-term trend**.

If 150 DMA is below 200 DMA, the stock may still be recovering.

Good structure:

```text
150 DMA > 200 DMA
```

Bad structure:

```text
150 DMA < 200 DMA
```

***

# 5. Condition 3: 200 DMA Trending Up

```pinescript
cond3 = sma200 > sma200[20]
```

This checks whether the 200 DMA today is higher than it was 20 trading days ago.

In simple terms:

> Is the long-term trend rising?

This is very important because a stock can be above the 200 DMA temporarily, but if the 200 DMA is still falling, the overall structure may not be strong yet.

***

# 6. Condition 4: 50 DMA Above 150 and 200 DMA

```pinescript
cond4 = sma50 > sma150 and sma50 > sma200
```

This confirms short-term momentum is stronger than both intermediate and long-term trends.

Good structure:

```text
50 DMA > 150 DMA > 200 DMA
```

This is one of the most important Minervini-style confirmations.

***

# 7. Condition 5: Price Above 50 DMA

```pinescript
cond5 = close > sma50
```

This means price is currently strong even in the short term.

If price is below 50 DMA, the stock may be correcting or losing momentum.

A strong stock usually stays above or near the 50 DMA during its advance.

***

# 8. Condition 6: Price Within 25% of 52-Week High

```pinescript
hh52 = ta.highest(high, 252)
cond6 = close >= hh52 * 0.75
```

Here:

*   `252` means approximately 252 trading days in a year
*   `hh52` = highest price in the last 252 trading days
*   `hh52 * 0.75` means price should be at least 75% of its 52-week high

Example:

If 52-week high = ₹100

Then:

```text
₹100 × 0.75 = ₹75
```

So the current price must be above ₹75.

Why this matters:

Minervini prefers stocks **near highs**, not stocks lying near lows.

Strong stocks usually stay near their 52-week highs.

***

# 9. Condition 7: Price At Least 30% Above 52-Week Low

```pinescript
ll52 = ta.lowest(low, 252)
cond7 = close >= ll52 * 1.3
```

Here:

*   `ll52` = lowest price in the last 252 trading days
*   `ll52 * 1.3` means price should be at least 30% above its 52-week low

Example:

If 52-week low = ₹100

Then:

```text
₹100 × 1.3 = ₹130
```

So the current price must be above ₹130.

Why this matters:

A strong stock should have moved meaningfully away from its lows.

***

# 10. Final Trend Template Result

```pinescript
trendTemplate = cond1 and cond2 and cond3 and cond4 and cond5 and cond6 and cond7
```

This is the main decision line.

It says:

> Only if all 7 conditions are true, mark the stock as Minervini Trend Template PASS.

If even one condition fails, no PASS.

So this is strict, which is good.

***

# 11. Green Background

```pinescript
bgcolor(trendTemplate ? color.new(color.green, 85) : na)
```

This visually highlights the chart when the stock passes all rules.

Meaning:

*   Green background = stock passes Minervini Trend Template
*   No background = stock fails at least one rule

This helps you scan charts faster.

***

# 12. Triangle Signal

```pinescript
plotshape(trendTemplate == true,
     location=location.abovebar,
     style=shape.triangleup,
     color=color.green,
     size=size.small)
```

This plots a green triangle above the candle when the stock passes.

Important:

This is **not a buy signal**.

It only means:

> “This stock is technically strong enough to study.”

You still need to check for base, VCP, breakout, volume, risk-reward, etc.

***

# 13. Alert Condition

```pinescript
alertcondition(trendTemplate == true, title="PASS", message="Minervini PASS")
```

This allows TradingView to trigger an alert when a stock passes the condition.

You can use it by:

1.  Click **Alert**
2.  Select your indicator
3.  Choose condition: **PASS**
4.  Create alert

But remember: alerts work best when applied to a chart/watchlist, not as a full-market scanner.

***

# What This Script Helps You Do

This script helps you avoid weak stocks.

It filters out:

*   Stocks below major moving averages
*   Stocks far away from highs
*   Stocks near lows
*   Stocks with weak long-term trend
*   Stocks without proper moving average alignment

So your rule becomes:

```text
No Trend Template PASS = No serious study
```

***

# What This Script Does NOT Do Yet

Your current script does **not** detect:

*   VCP pattern
*   Tight consolidation
*   Breakout level
*   Volume dry-up
*   Buy point
*   Stop-loss
*   Relative strength vs Nifty
*   Risk/reward

That is why we need a **pro version**.

***

# How to Use Current Script Properly

When a stock shows PASS, then manually check:

## 1. Is it extended?

Avoid buying if price is too far above 50 DMA.

Example:

```text
Price 20–30% above 50 DMA = risky/extended
```

## 2. Is it forming a base?

Look for sideways movement after a strong uptrend.

Good:

```text
Stock rises → pauses → tightens → breaks out
```

Bad:

```text
Stock rises vertically → you chase at top
```

## 3. Is volume drying up during consolidation?

Good base usually has falling volume during pullback.

This means selling pressure is reducing.

## 4. Is breakout volume strong?

Breakout should ideally happen with higher-than-average volume.

***

# Simple Interpretation

| Signal                    | Meaning               | Action                        |
| ------------------------- | --------------------- | ----------------------------- |
| No PASS                   | Weak/not ready        | Ignore                        |
| PASS but extended         | Strong but risky      | Wait                          |
| PASS + tight base         | Good candidate        | Watch closely                 |
| PASS + breakout on volume | Potential trade setup | Consider entry with stop-loss |

***

# What We’ll Add in Pro Version

Now that your base script works, the pro version can add:

## 1. Relative Strength vs Nifty

This checks whether the stock is outperforming Nifty.

Good stocks should beat the index.

***

## 2. Volume Expansion

This checks whether breakout volume is above average.

Example:

```text
Today volume > 1.5 × 50-day average volume
```

***

## 3. Tightness / VCP Logic

This detects whether volatility is reducing.

A basic version can check:

*   Recent range is smaller than previous range
*   ATR is contracting
*   Price is not swinging wildly

***

## 4. Breakout Level

The script can mark recent resistance/high.

Example:

```text
Breakout above 20-day high or base high
```

***

## 5. Buy Signal

Only when:

```text
Trend Template PASS
+ Breakout
+ Volume confirmation
+ Tight base
```

Then it shows a buy signal.

***

## 6. Stop-Loss Suggestion

It can plot:

*   Recent swing low
*   50 DMA
*   ATR-based stop

***

# Final Understanding

Your current script is a **quality filter**.

The pro version will become a **setup detector**.

Current script:

```text
Is this stock strong?
```

Pro version:

```text
Is this stock strong AND giving a possible entry setup?
```

***

## Source Code

````pine
//@version=6
indicator("Minervini Pro Setup Detector - NSE", overlay=true)

// =====================
// Inputs
// =====================
indexSymbol = input.symbol("NSE:NIFTY", "Relative Strength Index")
breakoutLen = input.int(20, "Breakout Lookback Days", minval=5)
volLen = input.int(50, "Average Volume Length", minval=10)
volMultiplier = input.float(1.5, "Breakout Volume Multiplier", minval=1.0, step=0.1)
atrLen = input.int(14, "ATR Length", minval=5)
tightLookbackShort = input.int(20, "Short Range Lookback", minval=5)
tightLookbackLong = input.int(60, "Long Range Lookback", minval=20)
maxExtensionFrom50 = input.float(15.0, "Max Extension From 50 DMA %", minval=1.0, step=0.5)
stopLookback = input.int(10, "Stop-loss Swing Low Lookback", minval=3)

// =====================
// Moving Averages
// =====================
sma50 = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

// =====================
// Trend Template
// =====================
cond1 = close > sma150 and close > sma200
cond2 = sma150 > sma200
cond3 = sma200 > sma200[20]
cond4 = sma50 > sma150 and sma50 > sma200
cond5 = close > sma50

hh52 = ta.highest(high, 252)
ll52 = ta.lowest(low, 252)

cond6 = close >= hh52 * 0.75
cond7 = close >= ll52 * 1.3

trendTemplate = cond1 and cond2 and cond3 and cond4 and cond5 and cond6 and cond7

// =====================
// Relative Strength vs Nifty
// =====================
indexClose = request.security(indexSymbol, timeframe.period, close)
rsLine = close / indexClose
rsSma = ta.sma(rsLine, 50)
rsStrong = rsLine > rsSma and rsLine > rsLine[20]

// =====================
// Breakout Logic
// =====================
priorHigh = ta.highest(high[1], breakoutLen)
breakout = close > priorHigh

// =====================
// Volume Confirmation
// =====================
avgVol = ta.sma(volume, volLen)
volumeConfirm = volume > avgVol * volMultiplier

// =====================
// Tightness / Contraction
// =====================
rangeShort = ta.highest(high, tightLookbackShort) - ta.lowest(low, tightLookbackShort)
rangeLong = ta.highest(high, tightLookbackLong) - ta.lowest(low, tightLookbackLong)
rangeContracting = rangeShort < rangeLong * 0.55

atr = ta.atr(atrLen)
atrPercent = atr / close * 100
atrAvg = ta.sma(atrPercent, 50)
atrContracting = atrPercent < atrAvg

tightSetup = rangeContracting and atrContracting

// =====================
// Extension Check
// =====================
extensionFrom50 = ((close - sma50) / sma50) * 100
notExtended = extensionFrom50 <= maxExtensionFrom50

// =====================
// Final Setup Conditions
// =====================
proCandidate = trendTemplate and rsStrong and tightSetup and notExtended
buySignal = proCandidate and breakout and volumeConfirm

// =====================
// Stop-loss Reference
// =====================
swingStop = ta.lowest(low, stopLookback)

// =====================
// Plots
// =====================
plot(sma50, color=color.blue, linewidth=2, title="50 DMA")
plot(sma150, color=color.orange, linewidth=2, title="150 DMA")
plot(sma200, color=color.red, linewidth=2, title="200 DMA")
plot(proCandidate ? swingStop : na, color=color.red, linewidth=2, style=plot.style_linebr, title="Suggested Swing Stop")
plot(proCandidate ? priorHigh : na, color=color.green, linewidth=2, style=plot.style_linebr, title="Breakout Level")

bgcolor(trendTemplate ? color.new(color.green, 88) : na)
bgcolor(proCandidate ? color.new(color.blue, 85) : na)

plotshape(trendTemplate, title="Trend Template PASS", location=location.belowbar, style=shape.circle, color=color.green, size=size.tiny)
plotshape(proCandidate, title="Pro Candidate", location=location.belowbar, style=shape.diamond, color=color.blue, size=size.small)
plotshape(buySignal, title="Buy Setup", location=location.abovebar, style=shape.triangleup, color=color.lime, size=size.normal, text="BUY")

// =====================
// Alerts
// =====================
alertcondition(trendTemplate, title="Trend Template PASS", message="Trend Template PASS")
alertcondition(proCandidate, title="Pro Candidate", message="Minervini Pro Candidate")
alertcondition(buySignal, title="Buy Setup", message="Minervini-style breakout setup")
````
