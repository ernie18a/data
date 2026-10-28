# SteveFi Trade Cockpit

- url: https://www.tradingview.com/script/Id5hXEBp-SteveFi-Trade-Cockpit/
- type: indicator
- pine_id: PUB;e6601503517946fe8fd6cd0a6d44d8ca
- version: 1.0

## Description

The dashboard has 15 rows:

| Row         | Purpose                                              |
| ----------- | ---------------------------------------------------- |
| **ACTION**  | Final decision output                                |
| **AGG**     | Weighted overall score using all 13 major attributes |
| **EWave**   | Elliott/Wolfe/Stoch/RSI-style timing score           |
| **CANSLIM** | CANSLIM-style technical quality score                |
| **RS**      | Relative strength vs QQQ                             |
| **52W**     | Distance from 52-week high                           |
| **Vol**     | Current volume vs average volume                     |
| **Accum**   | Accumulation vs distribution pressure                |
| **Pivot**   | Whether price is near a breakout/pivot area          |
| **MR**      | Mean reversion / extension risk                      |
| **Trend**   | Overall trend structure                              |
| **Stoch**   | Momentum reset/exhaustion                            |
| **Price**   | Price action confirmation                            |
| **INV**     | Invalidation level                                   |
| **Target**  | Potential upside target                              |

The color coding is:

| Color         | Meaning                                        |
| ------------- | ---------------------------------------------- |
| **Green**     | Positive / bullish                             |
| **Orange**    | Watch / caution / constructive but not perfect |
| **Dark gray** | Neutral / waiting                              |
| **Red**       | Negative / risk / failure                      |

---

# 1. ACTION

This is the **main output**.

Possible values:

| ACTION             | Meaning                                                                           |
| ------------------ | --------------------------------------------------------------------------------- |
| **BUY TRIGGER**    | Aggregate score is strong, price confirms, not invalidated, and not too stretched |
| **BUY WATCH**      | Setup is building, but not fully confirmed                                        |
| **TRIM / CAUTION** | Momentum may be rolling over or price is stretched                                |
| **WAIT**           | Some positives exist, but not enough for action                                   |
| **NO TRADE**       | Weak overall setup                                                                |
| **INV**            | Invalidation level broke. Setup failed.                                           |

The action row is based mostly on **AGG**, not just EWave.

Current logic:

```text
BUY TRIGGER =
AGG >= 80
AND Price is Confirmed
AND not invalidated
AND MR is not Stretched
```

If you turn on:

```text
Require CANSLIM Filter for BUY TRIGGER
```

Then BUY TRIGGER also requires a minimum CANSLIM-quality pass.

That is the stricter version.

---

# 2. AGG

**AGG** is the most important score now.

It is the weighted aggregate score based on all major dashboard factors. This is the “whole chart quality” score.

Current weighting:

| Attribute   | Weight |
| ----------- | -----: |
| **CANSLIM** |    21% |
| **RS**      |    13% |
| **Price**   |    12% |
| **Trend**   |    10% |
| **Pivot**   |    10% |
| **52W**     |     8% |
| **EWave**   |     8% |
| **Vol**     |     6% |
| **MR**      |     5% |
| **Accum**   |     3% |
| **Stoch**   |     2% |
| **INV**     |     1% |
| **Target**  |     1% |

This weighting intentionally makes the dashboard **less wave-heavy**.

The thinking is:

> Great stocks with strong RS and confirmed price action matter more than a possible wave count.

AGG grades:

|    AGG Score | Grade | Meaning                            |
| -----------: | ----- | ---------------------------------- |
|      **85+** | A+    | Excellent                          |
|    **80–84** | A     | Strong / trigger zone if confirmed |
|    **70–79** | B     | Good watchlist setup               |
|    **60–69** | C     | Developing but not there yet       |
|    **50–59** | D     | Weak / wait                        |
| **Under 50** | Weak  | No trade                           |

How I’d use it:

|          AGG | Interpretation                                    |
| -----------: | ------------------------------------------------- |
|      **80+** | Potential action zone                             |
|    **70–79** | Watch closely                                     |
|    **60–69** | Setup forming, still early                        |
| **Under 60** | Probably ignore unless you have a separate thesis |

---

# 3. EWave

**EWave** is the Elliott/Wolfe-style timing score.

It uses:

| EWave Component                               | Points |
| --------------------------------------------- | -----: |
| Bullish trend context                         |     20 |
| Fib pullback / possible Wave 2 or Wave 4 zone |     20 |
| RSI bullish divergence                        |     20 |
| Stoch reset                                   |     15 |
| Wolfe-like structure                          |     10 |
| Price action confirmation                     |     10 |

Maximum is **95**.

Dashboard examples:

| EWave                   | Meaning                  |
| ----------------------- | ------------------------ |
| **75+ / A**             | Strong wave/timing setup |
| **60–74 / B Watch**     | Setup is building        |
| **40–59 / C Early**     | Early or incomplete      |
| **Under 40 / No Trade** | Weak timing setup        |

Important: **EWave is only 8% of AGG now.**

That means it helps with timing, but it does not dominate the decision.

Best interpretation:

> EWave tells you whether the pullback/structure/timing looks constructive.

It does **not** mean “this is definitely Wave 3.”

---

# 4. CANSLIM

**CANSLIM** is a technical approximation of CANSLIM-style stock quality.

It does not use IBD’s proprietary EPS, sales, or fund ownership data. TradingView cannot reliably recreate that from Pine.

Instead, it uses technical leadership proxies:

| CANSLIM Component            | Points |
| ---------------------------- | -----: |
| RS vs benchmark              |     20 |
| RS line near/new high        |     15 |
| Distance from 52-week high   |     15 |
| Volume vs average            |     15 |
| Accumulation vs distribution |     15 |
| Pivot/base status            |     20 |

Maximum is **100**.

Grades:

| CANSLIM Score | Grade | Meaning                                |
| ------------: | ----- | -------------------------------------- |
|       **80+** | A     | Strong CANSLIM-style technical profile |
|     **65–79** | B     | Good                                   |
|     **50–64** | C     | Mixed                                  |
|  **Under 50** | Weak  | Not acting like a leader               |

This is now the **largest weight in AGG** at **21%**.

That’s intentional.

The dashboard is saying:

> Stock quality and leadership come first. Timing comes second.

---

# 5. RS

**RS** means relative strength versus the benchmark, currently defaulted to **QQQ**.

It compares the stock’s performance to QQQ over the selected lookback period.

Possible values:

| RS         | Meaning                                                                   |
| ---------- | ------------------------------------------------------------------------- |
| **Strong** | Stock is outperforming QQQ and its RS line is above its RS moving average |
| **OK**     | Stock is outperforming QQQ, but not as strongly                           |
| **Weak**   | Stock is underperforming QQQ                                              |

Why this matters:

CANSLIM-style trading wants **leaders**, not laggards.

A stock with **RS Strong** is showing better demand than the market.

Best read:

| RS                 | Interpretation           |
| ------------------ | ------------------------ |
| **Strong / green** | Good leader behavior     |
| **OK / orange**    | Acceptable but not elite |
| **Weak / red**     | Caution                  |

---

# 6. 52W

**52W** shows how far the stock is from its 52-week high.

Example:

```text
-6.1%
```

Means the stock is 6.1% below its 52-week high.

Interpretation:

|     52W Distance | Meaning           |
| ---------------: | ----------------- |
|    **0% to -5%** | Very strong       |
|  **-5% to -15%** | Good / acceptable |
| **-15% to -25%** | Caution           |
|   **Below -25%** | Weak / damaged    |

Why it matters:

CANSLIM usually prefers stocks near highs, not stocks buried far below highs.

A stock near highs is often showing institutional demand.

---

# 7. Vol

**Vol** shows current volume as a percentage of average volume.

Example:

```text
89%
```

Means current volume is 89% of the average volume.

Interpretation:

| Vol            | Meaning                                 |
| -------------- | --------------------------------------- |
| **140%+**      | Strong demand / breakout-quality volume |
| **100–139%**   | Decent                                  |
| **Under 100%** | Light / not confirmed                   |

Why it matters:

A breakout or strong move is more convincing when volume expands.

For CANSLIM-style buying, strong volume gives confirmation that bigger buyers may be involved.

One note: on intraday bars or during the trading day, volume can look low until the day completes. On daily charts, interpret it best near/after the close.

---

# 8. Accum

**Accum** tries to detect whether the stock has more accumulation or distribution pressure.

It compares:

* Up days on above-average volume
* Down days on above-average volume

Possible values:

| Accum       | Meaning                                               |
| ----------- | ----------------------------------------------------- |
| **Accum**   | More heavy-volume up days than heavy-volume down days |
| **Neutral** | No clear edge                                         |
| **Distrib** | More heavy-volume down days than up days              |

Why it matters:

CANSLIM cares about institutional accumulation.

A stock can look okay on price, but if it is under distribution, the setup is lower quality.

---

# 9. Pivot

**Pivot** tells you where price is relative to a recent breakout/base area.

It uses the recent high over the base lookback period as a rough pivot reference.

Possible values:

| Pivot           | Meaning                                        |
| --------------- | ---------------------------------------------- |
| **Breakout**    | Price broke above pivot with strong volume     |
| **Near Pivot**  | Price is within about 5% below the pivot       |
| **Above Pivot** | Price is above pivot, but volume is not strong |
| **Extended**    | Price is more than about 5% above pivot        |
| **Base Low**    | Price is not near a useful pivot area          |

Why it matters:

The best setups are often near proper buy areas.

For your dashboard:

| Pivot                   | Interpretation     |
| ----------------------- | ------------------ |
| **Breakout / green**    | Strong             |
| **Near Pivot / orange** | Watch closely      |
| **Extended / red**      | Be careful chasing |
| **Base Low / gray**     | Not actionable yet |

---

# 10. MR

**MR** means mean reversion / extension risk.

It measures how far price is from the fast EMA using ATR.

Example:

```text
Extended 1.73x ATR
```

Means price is 1.73 ATR above the fast EMA.

Possible values:

| MR            | Meaning                                                    |
| ------------- | ---------------------------------------------------------- |
| **Discount**  | Price pulled back below fast EMA but remains above mid EMA |
| **Normal**    | Price is within normal range of fast EMA                   |
| **Extended**  | Price is above normal range                                |
| **Stretched** | Price is too far extended                                  |
| **Weak**      | Price is below mid EMA                                     |
| **n/a**       | Not enough data                                            |

Why this matters:

This row helps prevent chasing.

A stock can be strong but too extended for a fresh entry.

Important trigger rule:

```text
BUY TRIGGER cannot fire if MR = Stretched
```

That’s a guardrail.

Best read:

| MR                    | Interpretation           |
| --------------------- | ------------------------ |
| **Discount / green**  | Pullback zone            |
| **Normal / neutral**  | Healthy                  |
| **Extended / orange** | Be careful               |
| **Stretched / red**   | Probably not a fresh buy |
| **Weak / red**        | Structure may be broken  |

---

# 11. Trend

**Trend** gives the broader moving-average structure.

Possible values:

| Trend           | Meaning                                                             |
| --------------- | ------------------------------------------------------------------- |
| **Bull Strong** | Price above mid EMA, fast EMA above mid EMA, mid EMA above long SMA |
| **Bull Basic**  | Price and fast trend are above mid EMA                              |
| **Neutral**     | Mixed                                                               |
| **Bear**        | Price and averages are bearish                                      |

This row is important because you generally want to buy pullbacks in strong trends, not fight broken charts.

Best setup:

```text
Trend = Bull Strong
```

---

# 12. Stoch

**Stoch** shows Stochastic momentum condition.

Possible values:

| Stoch         | Meaning                                                      |
| ------------- | ------------------------------------------------------------ |
| **Reset**     | Stoch recently got oversold/reset and is turning back up     |
| **K>D**       | Momentum is positive, but not necessarily from a fresh reset |
| **Roll Over** | Stoch was overbought and crossed down                        |
| **No Reset**  | No useful signal                                             |

Why this matters:

This came from the original HeidingOut-style method:

> Price action leads, Stoch/RSI confirm.

Best entry setup:

```text
Stoch = Reset
```

Caution setup:

```text
Stoch = Roll Over
```

But Stoch is only **2% of AGG** now because oscillators can be noisy.

---

# 13. Price

**Price** is one of the most important rows.

It checks whether price action has actually confirmed.

It requires:

* Higher-low structure
* Close above fast EMA
* Bullish candle
* Close above prior bar high

Possible values:

| Price         | Meaning                                      |
| ------------- | -------------------------------------------- |
| **Confirmed** | Price action supports the setup              |
| **Waiting**   | Setup may exist, but price has not confirmed |

This is weighted **12%** in AGG, which is high.

Why?

Because a setup without price confirmation is still just a possibility.

A BUY TRIGGER requires:

```text
Price = Confirmed
```

---

# 14. INV

**INV** is the invalidation level.

This is the key structural low from the detected impulse/pullback logic.

Plain English:

> If price closes below this level, the setup is probably broken.

Possible values:

| INV         | Meaning                           |
| ----------- | --------------------------------- |
| Price level | Key invalidation reference        |
| n/a         | Not enough structure detected yet |

Important:

If price breaks below INV, ACTION becomes:

```text
INV
```

Invalidation overrides everything.

Even if RS is strong and CANSLIM is good, a broken structure means the setup has failed.

---

# 15. Target

**Target** shows the projected upside target and upside percentage.

It uses a **1.618 Fib extension** from the detected impulse.

Example:

```text
145.20 / +12.4%
```

Means:

* Potential target: 145.20
* Upside from current price: +12.4%

This is intentionally weighted only **1%** in AGG.

Why so low?

Because targets are estimates. Useful, but not reliable enough to drive the decision.

Use Target as:

> “Is there enough upside to justify the risk?”

Not as:

> “This will definitely go there.”

---

# How the AGG score thinks

The new AGG is intentionally biased toward objective leadership and confirmation.

Current hierarchy:

## Most important

* CANSLIM
* RS
* Price
* Trend
* Pivot

These answer:

> Is this a quality leader acting correctly?

## Middle importance

* 52W
* EWave
* Vol
* MR

These answer:

> Is it near highs, reasonably timed, supported by volume, and not too stretched?

## Lower importance

* Accum
* Stoch
* INV
* Target

These help, but do not dominate.

---

# How to read a good setup

A very good setup would look like:

| Row     | Ideal                      |
| ------- | -------------------------- |
| ACTION  | BUY TRIGGER                |
| AGG     | 80+                        |
| EWave   | 60+                        |
| CANSLIM | 65+                        |
| RS      | Strong                     |
| 52W     | Better than -15%           |
| Vol     | 100%+ or 140%+ on breakout |
| Accum   | Accum                      |
| Pivot   | Near Pivot or Breakout     |
| MR      | Normal or Discount         |
| Trend   | Bull Strong                |
| Stoch   | Reset or K>D               |
| Price   | Confirmed                  |
| INV     | Below nearby structure     |
| Target  | Positive upside            |

That is the kind of dashboard that says:

> This is worth real attention.

---

# How to read your ALAB screenshot

From your screenshot, the dashboard looked roughly like:

| Row     | Reading            |
| ------- | ------------------ |
| ACTION  | WAIT               |
| EWave   | 40 / C Early       |
| CANSLIM | 57 / C             |
| RS      | Strong             |
| 52W     | -6.1%              |
| Vol     | 89%                |
| Accum   | Accum              |
| Pivot   | Near Pivot         |
| MR      | Extended 1.73x ATR |
| Trend   | Bull Strong        |
| Stoch   | K>D                |
| Price   | Waiting            |
| Target  | n/a                |

That says:

**Good stock. Strong RS. Near highs. In a bullish trend. But not confirmed yet, volume is light, and price is a little extended.**

So **WAIT** makes sense.

It is not saying “bad stock.”

It is saying:

> Good candidate, but not a clean entry yet.

---

# The key dashboard philosophy

This is now the right structure:

## CANSLIM finds the leader

Rows:

* CANSLIM
* RS
* 52W
* Vol
* Accum
* Pivot

## EWave helps timing

Rows:

* EWave
* Stoch
* Price
* MR

## Risk/reward controls the trade

Rows:

* INV
* Target
* MR

## AGG combines it all

AGG answers:

> Overall, is this setup strong enough to act on?

---

# My simple decision rules

Use it like this:

## BUY TRIGGER

Only consider buying when:

* ACTION = BUY TRIGGER
* AGG is 80+
* Price is Confirmed
* MR is not Stretched
* INV is clear
* Target gives enough upside

## BUY WATCH

Put on watchlist when:

* ACTION = BUY WATCH
* RS is Strong
* CANSLIM is at least C/B
* Pivot is Near Pivot
* Price is Waiting

## WAIT

Do nothing when:

* Stock is good, but price is not confirmed
* MR is extended
* Volume is not there
* EWave is early

## TRIM / CAUTION

Consider trimming when:

* Stoch rolls over
* MR becomes Stretched
* Price action weakens after a run

## INV

Respect it.

If INV triggers, the setup is broken. Reassess from scratch.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Solana_Sphyr

//@version=6
indicator("SteveFi EWave + CANSLIM Dashboard BALANCED v2.2", overlay=true, max_labels_count=50, max_lines_count=20, max_boxes_count=10)

//---------------------------------------------------------
// INPUTS
//---------------------------------------------------------
pivotLeft      = input.int(5, "Pivot Left Bars", minval=2, maxval=20)
pivotRight     = input.int(5, "Pivot Right Bars", minval=2, maxval=20)

emaFastLen     = input.int(21, "Fast EMA", minval=5)
emaMidLen      = input.int(50, "Mid EMA", minval=10)
smaLongLen     = input.int(200, "Long SMA", minval=50)

rsiLen         = input.int(14, "RSI Length", minval=5)
stochLen       = input.int(14, "Stoch Length", minval=5)
stochSmoothK   = input.int(3, "Stoch K Smooth", minval=1)
stochSmoothD   = input.int(3, "Stoch D Smooth", minval=1)

stochOversold   = input.float(25.0, "Stoch Oversold", minval=5, maxval=40)
stochResetMax   = input.float(45.0, "Stoch Reset Max", minval=20, maxval=60)
stochOverbought = input.float(80.0, "Stoch Overbought", minval=60, maxval=95)

divWindow      = input.int(25, "Divergence Active Window", minval=5, maxval=100)

fibMin         = input.float(0.382, "Fib Pullback Min", minval=0.1, maxval=0.9)
fibMax         = input.float(0.786, "Fib Pullback Max", minval=0.2, maxval=1.0)

// Aggregate action thresholds
aggWatchScore   = input.int(65, "AGG Buy Watch Score", minval=40, maxval=90)
aggTriggerScore = input.int(80, "AGG Buy Trigger Score", minval=50, maxval=100)

// CANSLIM technical inputs
benchmarkSymbol = input.symbol("NASDAQ:QQQ", "RS Benchmark")
rsLookback      = input.int(50, "RS Lookback Bars", minval=10, maxval=200)
rsNewHighLen    = input.int(50, "RS New High Lookback", minval=10, maxval=200)
volAvgLen       = input.int(50, "Volume Average Length", minval=10, maxval=100)
accumLen        = input.int(20, "Accum/Distrib Lookback", minval=5, maxval=50)
baseLookback    = input.int(50, "Pivot/Base Lookback", minval=20, maxval=150)
breakoutVolPct  = input.float(140.0, "Breakout Volume %", minval=100, maxval=300)
requireCanFilter = input.bool(false, "Require CANSLIM Filter for BUY TRIGGER")

// Mean reversion / risk
atrLen          = input.int(14, "ATR Length", minval=5, maxval=50)
mrNormalAtr     = input.float(1.0, "MR Normal ATR Limit", minval=0.5, maxval=3.0)
mrExtendedAtr   = input.float(2.0, "MR Extended ATR Limit", minval=1.0, maxval=5.0)

// Dashboard settings
dashboardPos   = input.string("Bottom Left", "Dashboard Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"])
showDashboard  = input.bool(true, "Show Dashboard")
showBuyZoneBox = input.bool(false, "Show Buy Zone Box")

//---------------------------------------------------------
// DASHBOARD POSITION FUNCTION
//---------------------------------------------------------
f_dashboard_position(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Top Right" ? position.top_right :
     _pos == "Bottom Left" ? position.bottom_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Middle Left" ? position.middle_left :
     position.middle_right

//---------------------------------------------------------
// CORE INDICATORS
//---------------------------------------------------------
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
smaLong = ta.sma(close, smaLongLen)

rsi = ta.rsi(close, rsiLen)

rawK = ta.stoch(close, high, low, stochLen)
k = ta.sma(rawK, stochSmoothK)
d = ta.sma(k, stochSmoothD)

//---------------------------------------------------------
// TREND CONTEXT
//---------------------------------------------------------
bullTrendStrong = close > emaMid and emaMid > smaLong and emaFast > emaMid
bullTrendBasic  = close > emaMid and emaFast > emaMid
bearTrend       = close < emaMid and emaMid < smaLong

trendScore = bullTrendStrong ? 20 : bullTrendBasic ? 12 : 0

trendText =
     bullTrendStrong ? "Bull Strong" :
     bullTrendBasic ? "Bull Basic" :
     bearTrend ? "Bear" :
     "Neutral"

//---------------------------------------------------------
// CONFIRMED PIVOTS
//---------------------------------------------------------
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

newPivotHigh = not na(ph)
newPivotLow  = not na(pl)

pivotHighIndex = bar_index - pivotRight
pivotLowIndex  = bar_index - pivotRight

//---------------------------------------------------------
// STORE RECENT PIVOTS
//---------------------------------------------------------
var float lastPivotLowPrice  = na
var float prevPivotLowPrice  = na
var float lastPivotLowRSI    = na
var float prevPivotLowRSI    = na
var int   lastPivotLowIndex  = na

var float lastPivotHighPrice = na
var int   lastPivotHighIndex = na

if newPivotLow
    prevPivotLowPrice := lastPivotLowPrice
    prevPivotLowRSI   := lastPivotLowRSI
    lastPivotLowPrice := pl
    lastPivotLowRSI   := rsi[pivotRight]
    lastPivotLowIndex := pivotLowIndex

if newPivotHigh
    lastPivotHighPrice := ph
    lastPivotHighIndex := pivotHighIndex

//---------------------------------------------------------
// RSI DIVERGENCE
//---------------------------------------------------------
hiddenBullDiv = newPivotLow and not na(prevPivotLowPrice) and lastPivotLowPrice > prevPivotLowPrice and lastPivotLowRSI < prevPivotLowRSI
regularBullDiv = newPivotLow and not na(prevPivotLowPrice) and lastPivotLowPrice < prevPivotLowPrice and lastPivotLowRSI > prevPivotLowRSI

barsSinceHidden  = ta.barssince(hiddenBullDiv)
barsSinceRegular = ta.barssince(regularBullDiv)

hiddenBullActive  = not na(barsSinceHidden) and barsSinceHidden <= divWindow
regularBullActive = not na(barsSinceRegular) and barsSinceRegular <= divWindow

divScore = hiddenBullActive ? 20 : regularBullActive ? 15 : 0

//---------------------------------------------------------
// STOCH RESET / EXHAUSTION
//---------------------------------------------------------
stochWasOversold = ta.lowest(k, 8) < stochOversold
stochCrossUp     = ta.crossover(k, d)
stochCurlUp      = k > k[1] and d > d[1]

stochReset = stochWasOversold and (stochCrossUp or stochCurlUp) and k < stochResetMax

barsSinceStochReset = ta.barssince(stochReset)
stochResetActive = not na(barsSinceStochReset) and barsSinceStochReset <= 10

stochScore = stochResetActive ? 15 : 0

stochOverheated = k > stochOverbought and d > stochOverbought
stochRollingOver = stochOverheated and ta.crossunder(k, d)

stochText =
     stochResetActive ? "Reset" :
     stochRollingOver ? "Roll Over" :
     k > d ? "K>D" :
     "No Reset"

//---------------------------------------------------------
// IMPULSE + FIB PULLBACK ZONE
//---------------------------------------------------------
var float impulseLow = na
var float impulseHigh = na
var int   impulseLowIndex = na
var int   impulseHighIndex = na

if newPivotHigh and not na(lastPivotLowPrice) and lastPivotLowIndex < pivotHighIndex
    impulseLow := lastPivotLowPrice
    impulseHigh := ph
    impulseLowIndex := lastPivotLowIndex
    impulseHighIndex := pivotHighIndex

impulseRange = impulseHigh - impulseLow

fibTop = not na(impulseHigh) and impulseRange > 0 ? impulseHigh - impulseRange * fibMin : na
fibBottom = not na(impulseHigh) and impulseRange > 0 ? impulseHigh - impulseRange * fibMax : na

inFibPullbackZone = not na(fibTop) and not na(fibBottom) and close <= fibTop and close >= fibBottom
pullbackHoldingStructure = not na(impulseLow) and close > impulseLow
possibleWave2or4 = inFibPullbackZone and pullbackHoldingStructure and bullTrendBasic

fibScore = possibleWave2or4 ? 20 : 0

//---------------------------------------------------------
// PRICE ACTION CONFIRMATION
//---------------------------------------------------------
higherLowStructure = not na(prevPivotLowPrice) and not na(lastPivotLowPrice) and lastPivotLowPrice > prevPivotLowPrice
closeAboveFastEMA  = close > emaFast
breakPriorHigh     = close > high[1]
bullCandle         = close > open

priceActionConfirm = higherLowStructure and closeAboveFastEMA and breakPriorHigh and bullCandle
priceScore = priceActionConfirm ? 10 : 0

//---------------------------------------------------------
// SIMPLE WOLFE-LIKE BONUS
//---------------------------------------------------------
wolfeLikeSetup = not na(prevPivotLowPrice) and not na(lastPivotLowPrice) and not na(lastPivotHighPrice) and lastPivotLowPrice < prevPivotLowPrice and close > lastPivotLowPrice and bullTrendBasic
wolfeScore = wolfeLikeSetup ? 10 : 0

//---------------------------------------------------------
// EWAVE SCORE
//---------------------------------------------------------
setupScore = trendScore + fibScore + divScore + stochScore + wolfeScore + priceScore

setupGrade =
     setupScore >= 85 ? "A+" :
     setupScore >= 75 ? "A" :
     setupScore >= 60 ? "B / Watch" :
     setupScore >= 40 ? "C / Early" :
     "No Trade"

ewavePct = math.min(math.max(setupScore / 95.0 * 100.0, 0.0), 100.0)

//---------------------------------------------------------
// CANSLIM TECHNICAL CALCULATIONS
//---------------------------------------------------------
benchClose = request.security(benchmarkSymbol, timeframe.period, close)

rsLine = not na(benchClose) and benchClose > 0 ? close / benchClose : na
rsLineSma = ta.sma(rsLine, rsLookback)
rsLineHigh = ta.highest(rsLine, rsNewHighLen)

stockPerf = not na(close[rsLookback]) and close[rsLookback] > 0 ? (close / close[rsLookback] - 1.0) * 100.0 : na
benchPerf = not na(benchClose[rsLookback]) and benchClose[rsLookback] > 0 ? (benchClose / benchClose[rsLookback] - 1.0) * 100.0 : na

outperformingBenchmark = not na(stockPerf) and not na(benchPerf) and stockPerf > benchPerf
rsStrong = not na(rsLine) and not na(rsLineSma) and rsLine > rsLineSma and outperformingBenchmark
rsNewHigh = not na(rsLine) and not na(rsLineHigh) and rsLine >= rsLineHigh * 0.995

rsText = rsStrong ? "Strong" : outperformingBenchmark ? "OK" : "Weak"

// 52-week high distance
daily52High = request.security(syminfo.tickerid, "D", ta.highest(high, 252))
distFrom52High = not na(daily52High) and daily52High > 0 ? (close / daily52High - 1.0) * 100.0 : na

dist52Text = not na(distFrom52High) ? str.tostring(distFrom52High, "#.##") + "%" : "n/a"
nearHighGood = not na(distFrom52High) and distFrom52High >= -15.0
nearHighCaution = not na(distFrom52High) and distFrom52High < -15.0 and distFrom52High >= -25.0
nearHighBad = not na(distFrom52High) and distFrom52High < -25.0

// Volume
volAvg = ta.sma(volume, volAvgLen)
volPct = not na(volAvg) and volAvg > 0 ? volume / volAvg * 100.0 : na

volText = not na(volPct) ? str.tostring(volPct, "#") + "%" : "n/a"
volStrong = not na(volPct) and volPct >= breakoutVolPct
volDecent = not na(volPct) and volPct >= 100.0

// Accumulation / distribution
upVolSignal = close > close[1] and volume > volAvg
downVolSignal = close < close[1] and volume > volAvg

accumCount = ta.sma(upVolSignal ? 1.0 : 0.0, accumLen) * accumLen
distribCount = ta.sma(downVolSignal ? 1.0 : 0.0, accumLen) * accumLen

accumPositive = accumCount > distribCount + 1
distribNegative = distribCount > accumCount + 1

accumText =
     accumPositive ? "Accum" :
     distribNegative ? "Distrib" :
     "Neutral"

// Pivot / base status
pivotLevel = ta.highest(high, baseLookback)[1]

nearPivot = not na(pivotLevel) and close <= pivotLevel and close >= pivotLevel * 0.95
breakout = not na(pivotLevel) and close > pivotLevel and volStrong
abovePivotQuiet = not na(pivotLevel) and close > pivotLevel and not volStrong
extended = not na(pivotLevel) and close > pivotLevel * 1.05

pivotText =
     breakout ? "Breakout" :
     extended ? "Extended" :
     abovePivotQuiet ? "Above Pivot" :
     nearPivot ? "Near Pivot" :
     "Base Low"

// CANSLIM technical score
canRsScore = rsStrong ? 20 : outperformingBenchmark ? 10 : 0
canRsNhScore = rsNewHigh ? 15 : 0
can52Score = not na(distFrom52High) and distFrom52High >= -5 ? 15 : not na(distFrom52High) and distFrom52High >= -15 ? 10 : not na(distFrom52High) and distFrom52High >= -25 ? 5 : 0
canVolScore = volStrong ? 15 : volDecent ? 8 : 0
canAccumScore = accumPositive ? 15 : not distribNegative ? 5 : 0
canPivotScore = breakout ? 20 : nearPivot ? 12 : abovePivotQuiet ? 8 : extended ? 3 : 0

canScore = canRsScore + canRsNhScore + can52Score + canVolScore + canAccumScore + canPivotScore

canGrade =
     canScore >= 80 ? "A" :
     canScore >= 65 ? "B" :
     canScore >= 50 ? "C" :
     "Weak"

canFilterPass = canScore >= 60 and nearHighGood and (rsStrong or rsNewHigh)

//---------------------------------------------------------
// MEAN REVERSION / ATR STRETCH
//---------------------------------------------------------
atr = ta.atr(atrLen)
atrStretch = not na(atr) and atr > 0 ? (close - emaFast) / atr : na

mrDiscount = not na(atrStretch) and atrStretch < 0 and close > emaMid
mrNormal = not na(atrStretch) and math.abs(atrStretch) <= mrNormalAtr
mrExtended = not na(atrStretch) and atrStretch > mrNormalAtr and atrStretch <= mrExtendedAtr
mrStretched = not na(atrStretch) and atrStretch > mrExtendedAtr
mrBroken = not na(atrStretch) and close < emaMid

mrText =
     mrStretched ? "Stretched" :
     mrExtended ? "Extended" :
     mrDiscount ? "Discount" :
     mrBroken ? "Weak" :
     mrNormal ? "Normal" :
     "n/a"

mrDetail = not na(atrStretch) ? str.tostring(atrStretch, "#.##") + "x ATR" : "n/a"

//---------------------------------------------------------
// INVALIDATION / TARGET
//---------------------------------------------------------
invalidationLevel = not na(impulseLow) ? impulseLow : na
invalidated = not na(invalidationLevel) and close < invalidationLevel

targetFib1618 = not na(impulseLow) and not na(impulseHigh) and impulseRange > 0 ? impulseLow + impulseRange * 1.618 : na

activeTarget = setupScore >= 40 and not invalidated ? targetFib1618 : na
upsidePct = not na(activeTarget) and close > 0 ? ((activeTarget - close) / close) * 100 : na

//---------------------------------------------------------
// AGGREGATE SCORE - ALL 13 INDICATORS
//---------------------------------------------------------
// Best-in-class weighting philosophy:
// Leadership / quality first, price confirmation second, buy location/risk third,
// EWave as supporting timing factor at 8%.

ewaveComponent = ewavePct
canslimComponent = canScore
rsComponent = rsStrong ? 100.0 : outperformingBenchmark ? 60.0 : 0.0
high52Component = nearHighGood ? 100.0 : nearHighCaution ? 50.0 : nearHighBad ? 0.0 : 50.0
volComponent = volStrong ? 100.0 : volDecent ? 60.0 : 40.0
accumComponent = accumPositive ? 100.0 : distribNegative ? 0.0 : 50.0
pivotComponent = breakout ? 100.0 : nearPivot ? 75.0 : abovePivotQuiet ? 60.0 : extended ? 25.0 : 40.0
mrComponent = mrDiscount ? 100.0 : mrNormal ? 80.0 : mrExtended ? 45.0 : mrStretched ? 10.0 : mrBroken ? 0.0 : 50.0
trendComponent = bullTrendStrong ? 100.0 : bullTrendBasic ? 75.0 : bearTrend ? 0.0 : 50.0
stochComponent = stochResetActive ? 100.0 : k > d ? 70.0 : stochRollingOver ? 0.0 : 40.0
priceComponent = priceActionConfirm ? 100.0 : 40.0
invComponent = invalidated ? 0.0 : 100.0
targetComponent = not na(activeTarget) and not na(upsidePct) and upsidePct > 0 ? 100.0 : 40.0

aggScore =
     canslimComponent * 0.21 +
     rsComponent * 0.13 +
     priceComponent * 0.12 +
     trendComponent * 0.10 +
     pivotComponent * 0.10 +
     high52Component * 0.08 +
     ewaveComponent * 0.08 +
     volComponent * 0.06 +
     mrComponent * 0.05 +
     accumComponent * 0.03 +
     stochComponent * 0.02 +
     invComponent * 0.01 +
     targetComponent * 0.01

aggGrade =
     aggScore >= 85 ? "A+" :
     aggScore >= 80 ? "A" :
     aggScore >= 70 ? "B" :
     aggScore >= 60 ? "C" :
     aggScore >= 50 ? "D" :
     "Weak"

//---------------------------------------------------------
// ACTION STATES BASED ON AGGREGATE SCORE
//---------------------------------------------------------
rawBuyTrigger = aggScore >= aggTriggerScore and priceActionConfirm and not invalidated and not mrStretched
buyTrigger = requireCanFilter ? rawBuyTrigger and canFilterPass : rawBuyTrigger

buyWatch = aggScore >= aggWatchScore and aggScore < aggTriggerScore and not invalidated
trimCaution = aggScore >= 60 and (stochRollingOver or mrStretched)

newBuyWatch = buyWatch and not buyWatch[1]
newBuyTrigger = buyTrigger and not buyTrigger[1]
newTrimCaution = trimCaution and not trimCaution[1]
newInvalidation = invalidated and not invalidated[1]

//---------------------------------------------------------
// NO CHART PLOTTING EXCEPT OPTIONAL BUY ZONE BOX
//---------------------------------------------------------
var box buyZoneBox = na

if showBuyZoneBox and possibleWave2or4 and not na(fibTop) and not na(fibBottom)
    if na(buyZoneBox)
        buyZoneBox := box.new(left=bar_index, top=fibTop, right=bar_index + 15, bottom=fibBottom, bgcolor=color.new(color.green, 92), border_color=color.new(color.green, 70))
    else
        box.set_left(buyZoneBox, bar_index)
        box.set_right(buyZoneBox, bar_index + 15)
        box.set_top(buyZoneBox, fibTop)
        box.set_bottom(buyZoneBox, fibBottom)
else
    if not na(buyZoneBox)
        box.delete(buyZoneBox)
        buyZoneBox := na

//---------------------------------------------------------
// DASHBOARD - BALANCED
//---------------------------------------------------------
var table dash = table.new(f_dashboard_position(dashboardPos), 2, 15, border_width=2, border_color=color.new(color.white, 20), frame_width=2, frame_color=color.new(color.white, 0), bgcolor=color.new(color.black, 10))

if showDashboard and barstate.islast
    actionText =
         invalidated ? "INV" :
         buyTrigger ? "BUY TRIGGER" :
         buyWatch ? "BUY WATCH" :
         trimCaution ? "TRIM / CAUTION" :
         aggScore >= 50 ? "WAIT" :
         "NO TRADE"

    neutralCell  = color.new(color.black, 45)
    positiveCell = color.new(color.green, 0)
    negativeCell = color.new(color.red, 10)
    cautionCell  = color.new(color.orange, 0)

    labelBg = color.new(color.black, 30)

    actionColor =
         invalidated ? negativeCell :
         buyTrigger ? positiveCell :
         buyWatch ? cautionCell :
         trimCaution ? negativeCell :
         aggScore >= 50 ? neutralCell :
         negativeCell

    aggColor =
         aggScore >= 80 ? positiveCell :
         aggScore >= 65 ? cautionCell :
         aggScore >= 50 ? neutralCell :
         negativeCell

    ewaveColor =
         setupScore >= 75 ? positiveCell :
         setupScore >= 60 ? cautionCell :
         setupScore >= 40 ? neutralCell :
         negativeCell

    canslimColor =
         canScore >= 65 ? positiveCell :
         canScore >= 50 ? cautionCell :
         negativeCell

    rsColor = rsStrong ? positiveCell : outperformingBenchmark ? cautionCell : negativeCell
    highColor = nearHighGood ? positiveCell : nearHighCaution ? cautionCell : nearHighBad ? negativeCell : neutralCell
    volColor = volStrong ? positiveCell : volDecent ? cautionCell : neutralCell
    accumColor = accumPositive ? positiveCell : distribNegative ? negativeCell : neutralCell
    pivotColor = breakout ? positiveCell : nearPivot ? cautionCell : extended ? negativeCell : abovePivotQuiet ? neutralCell : neutralCell
    mrColor = mrStretched or mrBroken ? negativeCell : mrExtended ? cautionCell : mrDiscount ? positiveCell : neutralCell
    trendColor = bullTrendStrong or bullTrendBasic ? positiveCell : bearTrend ? negativeCell : neutralCell
    stochColor = stochRollingOver ? negativeCell : stochResetActive or k > d ? positiveCell : neutralCell
    priceColor = priceActionConfirm ? positiveCell : neutralCell
    invColor = invalidated ? negativeCell : neutralCell
    targetColor = not na(activeTarget) and not na(upsidePct) and upsidePct > 0 ? positiveCell : neutralCell

    priceText = priceActionConfirm ? "Confirmed" : "Waiting"
    invalidText = not na(invalidationLevel) ? str.tostring(invalidationLevel, format.mintick) : "n/a"
    targetText = not na(activeTarget) and not na(upsidePct) ? str.tostring(activeTarget, format.mintick) + " / +" + str.tostring(upsidePct, "#.##") + "%" : "n/a"

    table.cell(dash, 0, 0, "ACTION", text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=size.small)
    table.cell(dash, 1, 0, actionText, text_color=color.white, bgcolor=actionColor, text_size=size.small)

    table.cell(dash, 0, 1, "AGG", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(aggScore, "#") + " / " + aggGrade, text_color=color.white, bgcolor=aggColor, text_size=size.small)

    table.cell(dash, 0, 2, "EWave", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(setupScore) + " / " + setupGrade, text_color=color.white, bgcolor=ewaveColor, text_size=size.small)

    table.cell(dash, 0, 3, "CANSLIM", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(canScore) + " / " + canGrade, text_color=color.white, bgcolor=canslimColor, text_size=size.small)

    table.cell(dash, 0, 4, "RS", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 4, rsText, text_color=color.white, bgcolor=rsColor, text_size=size.small)

    table.cell(dash, 0, 5, "52W", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 5, dist52Text, text_color=color.white, bgcolor=highColor, text_size=size.small)

    table.cell(dash, 0, 6, "Vol", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 6, volText, text_color=color.white, bgcolor=volColor, text_size=size.small)

    table.cell(dash, 0, 7, "Accum", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 7, accumText, text_color=color.white, bgcolor=accumColor, text_size=size.small)

    table.cell(dash, 0, 8, "Pivot", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 8, pivotText, text_color=color.white, bgcolor=pivotColor, text_size=size.small)

    table.cell(dash, 0, 9, "MR", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 9, mrText + " " + mrDetail, text_color=color.white, bgcolor=mrColor, text_size=size.small)

    table.cell(dash, 0, 10, "Trend", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 10, trendText, text_color=color.white, bgcolor=trendColor, text_size=size.small)

    table.cell(dash, 0, 11, "Stoch", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 11, stochText, text_color=color.white, bgcolor=stochColor, text_size=size.small)

    table.cell(dash, 0, 12, "Price", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 12, priceText, text_color=color.white, bgcolor=priceColor, text_size=size.small)

    table.cell(dash, 0, 13, "INV", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 13, invalidText, text_color=color.white, bgcolor=invColor, text_size=size.small)

    table.cell(dash, 0, 14, "Target", text_color=color.white, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 14, targetText, text_color=color.white, bgcolor=targetColor, text_size=size.small)

if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 14)

//---------------------------------------------------------
// ALERTS
//---------------------------------------------------------
alertcondition(newBuyWatch, title="BUY WATCH", message="BUY WATCH: Aggregate setup is building.")
alertcondition(newBuyTrigger, title="BUY TRIGGER", message="BUY TRIGGER: Aggregate setup confirmed.")
alertcondition(newTrimCaution, title="TRIM / CAUTION", message="TRIM / CAUTION: Momentum may be rolling over or price is stretched.")
alertcondition(newInvalidation, title="INV", message="INV: Price broke the key structure low.")
````
