# MGC Wyckoff Second Breakout V3 Candle RR

- url: https://www.tradingview.com/script/nLpE66zG/
- type: strategy
- pine_id: PUB;09792c1e9d784dab89fe49ea2c42d507
- version: 1.0

## Description

**Gold 15-Minute Wyckoff Second Breakout Strategy V3**

## Core Idea

This strategy is based on a Wyckoff-style breakout confirmation concept.

The strategy does **not** enter on the first breakout. Instead, it waits for the market to:

1. Break an isolated high or low.
2. Form a new breakout extreme.
3. Pull back or pause.
4. Break that new extreme again.

The second breakout is treated as the higher-quality confirmation signal.

---

## Timeframe

```text
Chart timeframe: 15 minutes
Market: Gold, preferably XAUUSD or MGC
Trade type: short-term breakout / intraday-to-swing
```

---

## Long Setup

### Step 1: Identify an isolated high

An isolated high is defined as a pivot high.

Default setting:

```text
Pivot Left Bars = 4
Pivot Right Bars = 2
```

This means the high must be higher than the highs of the previous 4 candles and confirmed by the following 2 candles.

This pivot high is called:

```text
H = isolated high
```

---

### Step 2: First breakout above H

A first breakout occurs when price closes above the isolated high:

```text
Close > H
```

The strategy does **not** enter here.

This first breakout only activates the setup.

---

### Step 3: Track the post-breakout high

After the first breakout, the strategy tracks the highest high made after that breakout.

This level is called:

```text
H2 = high formed after the first breakout
```

---

### Step 4: Wait for a pullback or pause

The strategy then waits for price to stop pushing higher.

A pullback/pause is detected when price closes below H2:

```text
Close < H2
```

At this point, the strategy starts waiting for a second breakout.

---

### Step 5: Second breakout above H2

If price closes above H2 within the maximum waiting window, the strategy enters long:

```text
Close > H2
```

Default waiting window:

```text
Max Bars After First Breakout = 20 bars
```

On a 15-minute chart, this is about 5 hours.

---

## Short Setup

The short setup is the mirror image of the long setup.

### Step 1: Identify an isolated low

An isolated low is defined as a pivot low:

```text
Pivot Left Bars = 4
Pivot Right Bars = 2
```

This pivot low is called:

```text
L = isolated low
```

---

### Step 2: First breakdown below L

A first breakdown occurs when price closes below the isolated low:

```text
Close < L
```

The strategy does **not** enter here.

---

### Step 3: Track the post-breakdown low

After the first breakdown, the strategy tracks the lowest low made after that breakdown.

This level is called:

```text
L2 = low formed after the first breakdown
```

---

### Step 4: Wait for a bounce or pause

The strategy waits for price to stop pushing lower.

A bounce/pause is detected when price closes above L2:

```text
Close > L2
```

---

### Step 5: Second breakdown below L2

If price closes below L2 within the maximum waiting window, the strategy enters short:

```text
Close < L2
```

---

## Stop-Loss Logic

The strategy uses a **structure-based stop-loss**.

### Long stop-loss

For long trades:

```text
Stop-loss = lowest low between the first breakout and the second breakout - 0.2 ATR
```

This means the stop is placed below the pullback structure.

---

### Short stop-loss

For short trades:

```text
Stop-loss = highest high between the first breakdown and the second breakdown + 0.2 ATR
```

This means the stop is placed above the bounce structure.

---

## Reward-to-Risk Logic

V3 uses a dynamic reward-to-risk model:

```text
Low-liquidity environment: 1R target
Normal environment: 2R target
Trend expansion environment: 3R target
```

---

## Low-Liquidity Condition

Low liquidity is approximated using small candles and narrow ranges.

The strategy checks whether recent candles are smaller than normal:

```text
Recent average candle body < long-term average candle body × 0.75
AND
Recent average candle range < long-term average candle range × 0.75
```

Default lookback:

```text
Recent lookback = 10 bars
Body average length = 50 bars
Range average length = 100 bars
```

If this condition is true, the strategy uses:

```text
Reward/Risk = 1:1
```

---

## Normal Market Condition

If the market is neither low-liquidity nor trend-expansion, the strategy uses:

```text
Reward/Risk = 2:1
```

---

## Trend Expansion Condition

Trend expansion is based on the breakout candle.

A long trade is considered trend expansion if the second breakout candle:

```text
1. Is a bullish candle
2. Has a body larger than 1.5 × average body
3. Has a total range larger than 1.0 × ATR
4. Closes near the high of the candle
```

A short trade is considered trend expansion if the second breakdown candle:

```text
1. Is a bearish candle
2. Has a body larger than 1.5 × average body
3. Has a total range larger than 1.0 × ATR
4. Closes near the low of the candle
```

If trend expansion is detected, the strategy uses:

```text
Reward/Risk = 3:1
```

---

## Trade Management

Once a trade is entered:

```text
The stop-loss is fixed at the structure stop.
The take-profit is fixed based on the selected R multiple.
The strategy does not trail the stop.
The strategy does not scale in.
The strategy does not scale out.
Only one position is allowed at a time.
```

---

## Default Parameters

```text
Pivot Left Bars: 4
Pivot Right Bars: 2
Max Bars After First Breakout: 20
ATR Length: 14
Structure Stop Buffer: 0.2 ATR

Body Average Length: 50
Range Average Length: 100
Low Liquidity Lookback: 10
Low Liquidity Multiplier: 0.75

Trend Body Expansion Multiplier: 1.5
Trend Range ATR Multiplier: 1.0
Strong Close Position: 0.30

Low Liquidity RR: 1.0
Normal RR: 2.0
Trend Expansion RR: 3.0
```

---

## Summary

In simple terms:

```text
The strategy waits for a breakout, ignores the first breakout, then trades the second breakout after a pause or pullback.

It uses structure-based stops and adjusts the profit target based on candle strength:

Small/narrow market = 1R
Normal market = 2R
Strong breakout candle = 3R
```

This makes it a **Wyckoff-inspired second-breakout momentum strategy with adaptive risk-reward targets**.

## Source Code

````pine
//@version=5
strategy("XAUUSD Wyckoff Second Breakout V3 Candle RR", overlay=true, initial_capital=100000, pyramiding=0, commission_type=strategy.commission.percent, commission_value=0.02, slippage=2)

// =====================
// Inputs
// =====================
leftBars = input.int(4, "Pivot Left Bars", minval=1)
rightBars = input.int(2, "Pivot Right Bars", minval=1)
maxWaitBars = input.int(20, "Max Bars After First Breakout", minval=1)

atrLen = input.int(14, "ATR Length", minval=1)
stopBufferAtr = input.float(0.2, "Structure Stop Buffer ATR", step=0.1)

bodyAvgLen = input.int(50, "Body Average Length", minval=1)
rangeAvgLen = input.int(100, "Range Average Length", minval=1)

lowLiquidityLookback = input.int(10, "Low Liquidity Lookback", minval=1)
lowLiquidityMult = input.float(0.75, "Low Liquidity Multiplier", step=0.05)

trendBodyMult = input.float(1.5, "Trend Body Expansion Multiplier", step=0.1)
trendRangeAtrMult = input.float(1.0, "Trend Range ATR Multiplier", step=0.1)
strongClosePct = input.float(0.30, "Strong Close Position", step=0.05)

rrLowLiquidity = input.float(1.0, "RR Low Liquidity", step=0.1)
rrNormal = input.float(2.0, "RR Normal", step=0.1)
rrTrend = input.float(3.0, "RR Trend Expansion", step=0.1)

useLong = input.bool(true, "Enable Long")
useShort = input.bool(true, "Enable Short")

// =====================
// Candle metrics
// =====================
atr = ta.atr(atrLen)

body = math.abs(close - open)
barRange = high - low

avgBody = ta.sma(body, bodyAvgLen)
avgRange = ta.sma(barRange, rangeAvgLen)

recentBody = ta.sma(body, lowLiquidityLookback)
recentRange = ta.sma(barRange, lowLiquidityLookback)

// 流动性不充分：最近K线实体小、波动窄
lowLiquidity = recentBody < avgBody * lowLiquidityMult and recentRange < avgRange * lowLiquidityMult

// 强势收盘位置
longStrongClose = barRange > 0 ? close >= high - barRange * strongClosePct : false
shortStrongClose = barRange > 0 ? close <= low + barRange * strongClosePct : false

// 趋势放大：突破K线实体明显放大，且收盘强
longTrendExpansion = close > open and body > avgBody * trendBodyMult and barRange > atr * trendRangeAtrMult and longStrongClose
shortTrendExpansion = close < open and body > avgBody * trendBodyMult and barRange > atr * trendRangeAtrMult and shortStrongClose

// =====================
// Pivot High / Low
// =====================
pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow = ta.pivotlow(low, leftBars, rightBars)

var float lastPivotHigh = na
var float lastPivotLow = na

if not na(pivotHigh)
    lastPivotHigh := pivotHigh

if not na(pivotLow)
    lastPivotLow := pivotLow

// =====================
// Long state variables
// =====================
var int longStage = 0
var float longH = na
var float longH2 = na
var float longPullbackLow = na
var int longBarsAfterBreak = 0

// =====================
// Short state variables
// =====================
var int shortStage = 0
var float shortL = na
var float shortL2 = na
var float shortBounceHigh = na
var int shortBarsAfterBreak = 0

// =====================
// Long logic
// =====================
firstLongBreak = useLong and longStage == 0 and not na(lastPivotHigh) and close > lastPivotHigh

if firstLongBreak
    longStage := 1
    longH := lastPivotHigh
    longH2 := high
    longPullbackLow := low
    longBarsAfterBreak := 0

if longStage == 1
    longBarsAfterBreak += 1
    longH2 := math.max(longH2, high)
    longPullbackLow := math.min(longPullbackLow, low)

    // 第一次突破后出现停顿/回撤
    if close < longH2
        longStage := 2

    if longBarsAfterBreak > maxWaitBars
        longStage := 0
        longH := na
        longH2 := na
        longPullbackLow := na

if longStage == 2
    longBarsAfterBreak += 1
    longPullbackLow := math.min(longPullbackLow, low)

longSecondBreak = useLong and longStage == 2 and close > longH2 and strategy.position_size == 0

if longSecondBreak
    longStop = longPullbackLow - stopBufferAtr * atr
    longRisk = close - longStop

    longRR = longTrendExpansion ? rrTrend : lowLiquidity ? rrLowLiquidity : rrNormal
    longTarget = close + longRR * longRisk

    if longRisk > 0
        strategy.entry("Long", strategy.long)
        strategy.exit("Long Exit", "Long", stop=longStop, limit=longTarget)

    longStage := 0
    longH := na
    longH2 := na
    longPullbackLow := na

if longStage == 2 and longBarsAfterBreak > maxWaitBars
    longStage := 0
    longH := na
    longH2 := na
    longPullbackLow := na

// =====================
// Short logic
// =====================
firstShortBreak = useShort and shortStage == 0 and not na(lastPivotLow) and close < lastPivotLow

if firstShortBreak
    shortStage := 1
    shortL := lastPivotLow
    shortL2 := low
    shortBounceHigh := high
    shortBarsAfterBreak := 0

if shortStage == 1
    shortBarsAfterBreak += 1
    shortL2 := math.min(shortL2, low)
    shortBounceHigh := math.max(shortBounceHigh, high)

    // 第一次跌破后出现停顿/反弹
    if close > shortL2
        shortStage := 2

    if shortBarsAfterBreak > maxWaitBars
        shortStage := 0
        shortL := na
        shortL2 := na
        shortBounceHigh := na

if shortStage == 2
    shortBarsAfterBreak += 1
    shortBounceHigh := math.max(shortBounceHigh, high)

shortSecondBreak = useShort and shortStage == 2 and close < shortL2 and strategy.position_size == 0

if shortSecondBreak
    shortStop = shortBounceHigh + stopBufferAtr * atr
    shortRisk = shortStop - close

    shortRR = shortTrendExpansion ? rrTrend : lowLiquidity ? rrLowLiquidity : rrNormal
    shortTarget = close - shortRR * shortRisk

    if shortRisk > 0
        strategy.entry("Short", strategy.short)
        strategy.exit("Short Exit", "Short", stop=shortStop, limit=shortTarget)

    shortStage := 0
    shortL := na
    shortL2 := na
    shortBounceHigh := na

if shortStage == 2 and shortBarsAfterBreak > maxWaitBars
    shortStage := 0
    shortL := na
    shortL2 := na
    shortBounceHigh := na

// =====================
// Visuals
// =====================
plot(lastPivotHigh, title="Last Isolated High", style=plot.style_linebr)
plot(lastPivotLow, title="Last Isolated Low", style=plot.style_linebr)

plotshape(firstLongBreak, title="First Long Break", style=shape.circle, location=location.abovebar, size=size.tiny, text="1B")
plotshape(longSecondBreak, title="Second Long Break", style=shape.triangleup, location=location.belowbar, size=size.small, text="2B")

plotshape(firstShortBreak, title="First Short Break", style=shape.circle, location=location.belowbar, size=size.tiny, text="1S")
plotshape(shortSecondBreak, title="Second Short Break", style=shape.triangledown, location=location.abovebar, size=size.small, text="2S")

bgcolor(lowLiquidity ? color.new(color.gray, 88) : na)
bgcolor(longTrendExpansion or shortTrendExpansion ? color.new(color.yellow, 88) : na)
````
