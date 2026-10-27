# Hero Dashboard Information Table

- url: https://www.tradingview.com/script/guGet1wg-Hero-Dashboard-Information-Table/
- type: indicator
- pine_id: PUB;19917d740e5a43b3833ccb67e2f3a846
- version: 1.0

## Description

# HERO DASHBOARD PRO - USER GUIDE

## Purpose

Hero Dashboard PRO is an intraday momentum scanner designed for index traders. It combines trend, volatility, breakout, and volume analysis into a compact dashboard that helps identify high-probability directional opportunities.

The indicator is optimized for:

* NIFTY
* BANKNIFTY
* FINNIFTY
* MIDCPNIFTY
* SENSEX
* BANKEX

---

# Dashboard Overview

```text
INDEX HERO DASH

Spot
ATM Strike
Hero CE
Hero PE

Hero Score
Trend Day %

Direction

PDH / ORB

Move / Confidence

Trade
```

---

# Dashboard Components

## Spot

Current market price of the selected index.

Example:

```text
25120
```

---

## ATM Strike

Nearest tradable strike based on the current index value.

Example:

```text
Spot = 25120

ATM = 25100
```

---

## Hero CE

Suggested Call Option strike based on current volatility.

Example:

```text
25300 CE
```

---

## Hero PE

Suggested Put Option strike based on current volatility.

Example:

```text
24900 PE
```

---

# Hero Score

Measures momentum strength.

The score is derived from:

* VWAP Position
* Volume Expansion
* Previous Day Breakout
* Opening Range Breakout
* ATR Expansion

### Interpretation

| Score    | Meaning           |
| -------- | ----------------- |
| 80 - 100 | Strong Momentum   |
| 60 - 79  | Moderate Momentum |
| Below 60 | Weak Momentum     |

---

# Trend Day %

Estimates the probability of a trend day.

### Interpretation

| Value     | Market Condition   |
| --------- | ------------------ |
| Above 75% | Strong Trend Day   |
| 50% - 75% | Moderate Trend     |
| Below 50% | Possible Range Day |

---

# Direction

Determines current market bias.

### Bullish

Conditions:

* Price above EMA20
* Price above VWAP

Output:

```text
BULLISH
```

### Bearish

Conditions:

* Price below EMA20
* Price below VWAP

Output:

```text
BEARISH
```

### Neutral

Conditions:

* Mixed trend structure

Output:

```text
NEUTRAL
```

---

# PDH / ORB

## PDH

Previous Day High Breakout

Output:

```text
PDH BREAK
```

Indicates bullish continuation potential.

---

## PDL

Previous Day Low Breakout

Output:

```text
PDL BREAK
```

Indicates bearish continuation potential.

---

## ORB

Opening Range Breakout

Default Opening Range:

```text
09:15 AM to 09:30 AM
```

Possible Outputs:

```text
UP
DOWN
INSIDE
```

### Example

```text
PDH BREAK | UP
```

This is one of the strongest bullish combinations.

---

# Expected Move

Expected movement based on current volatility.

Formula:

```text
ATR(14) × 2
```

Example:

```text
120 Points
```

This helps estimate realistic intraday targets.

---

# Confidence

Confidence level derived from Hero Score.

### HIGH

Hero Score ≥ 80

### MEDIUM

Hero Score 60–79

### LOW

Hero Score < 60

---

# Trade Recommendation

The dashboard provides a directional suggestion.

Possible outputs:

```text
BUY CE
BUY PE
WAIT
```

### BUY CE

Requirements:

* Bullish Direction
* High Hero Score
* Bullish ORB Structure

### BUY PE

Requirements:

* Bearish Direction
* High Hero Score
* Bearish ORB Structure

### WAIT

Requirements:

* No strong directional setup
* Low confidence
* Mixed market conditions

---

# Color Guide

## Green

Bullish Conditions

Examples:

* BUY CE
* HIGH Confidence
* BULLISH Direction

---

## Red

Bearish Conditions

Examples:

* BUY PE
* BEARISH Direction

---

## Yellow

Neutral or caution conditions

Examples:

* MEDIUM Confidence
* NEUTRAL Direction

---

## Aqua

Reference information

Examples:

* ATM Strike
* PDH/ORB Status

---

# Best Usage

Recommended Timeframes:

* 3 Minute
* 5 Minute
* 15 Minute

Most effective:

```text
5 Minute
```

---

# High-Quality Setup Checklist

Look for:

✅ Hero Score > 80

✅ Trend Day > 75%

✅ Direction = BULLISH or BEARISH

✅ Confidence = HIGH

✅ PDH/PDL Breakout

✅ ORB Breakout

When these align, the probability of a strong directional move is typically higher.

---

# Risk Management

Suggested guidelines:

* Risk a fixed amount per trade.
* Do not trade solely based on Hero CE/PE recommendations.
* Always use stop losses.
* Avoid overtrading during low-confidence conditions.
* Confirm signals with price action and market context.

---

# Disclaimer

This indicator is a decision-support tool. It does not predict future prices, calculate actual option Greeks, or guarantee profitable trades.

All trading involves risk. Use proper risk management and independent judgment before entering any position.

## Source Code

````pine
//@version=6



indicator("Hero Dashboard Information Table", overlay=true)

//=====================================================
// INPUTS
//=====================================================

emaLen = input.int(20, "EMA Length")
volLen = input.int(20, "Volume Average Length")
atrLen = input.int(14, "ATR Length")

//=====================================================
// CORE CALCULATIONS
//=====================================================

ema20 = ta.ema(close, emaLen)
vwapVal = ta.vwap(close)

avgVol = ta.sma(volume, volLen)

atr14 = ta.atr(atrLen)
atrAvg = ta.sma(atr14, 20)

//=====================================================
// PREVIOUS DAY LEVELS
//=====================================================

prevHigh = request.security(syminfo.tickerid, "D", high[1])
prevLow  = request.security(syminfo.tickerid, "D", low[1])

pdhBreak = close > prevHigh
pdlBreak = close < prevLow

//=====================================================
// 15 MIN ORB (09:15 - 09:30)
//=====================================================

var float orbHigh = na
var float orbLow  = na

newDay = ta.change(time("D")) != 0

if newDay
    orbHigh := na
    orbLow := na

isORB = (hour == 9 and minute < 30)

if isORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow, low)

orbBull = not na(orbHigh) and close > orbHigh
orbBear = not na(orbLow) and close < orbLow

//=====================================================
// HERO SCORE
//=====================================================

heroScore = 0

heroScore += close > vwapVal ? 30 : 0
heroScore += volume > avgVol * 1.5 ? 15 : 0
heroScore += (pdhBreak or pdlBreak) ? 20 : 0
heroScore += (orbBull or orbBear) ? 25 : 0
heroScore += atr14 > atrAvg ? 10 : 0

//=====================================================
// TREND DAY PROBABILITY
//=====================================================

trendDay = 0

trendDay += close > vwapVal ? 25 : 0
trendDay += volume > avgVol * 1.5 ? 25 : 0
trendDay += atr14 > atrAvg ? 25 : 0
trendDay += heroScore >= 80 ? 25 : 0

//=====================================================
// DIRECTION
//=====================================================

bullTrend = close > ema20 and close > vwapVal
bearTrend = close < ema20 and close < vwapVal

direction =
     bullTrend ? "BULLISH" :
     bearTrend ? "BEARISH" :
     "NEUTRAL"

//=====================================================
// STRIKE CALCULATOR
//=====================================================

atmStrike = math.round(close / 50) * 50

expectedMove = math.round(atr14 * 2)

steps = math.max(1, math.round(expectedMove / 50))

heroCE = atmStrike + (steps * 50)
heroPE = atmStrike - (steps * 50)

//=====================================================
// CONFIDENCE
//=====================================================

confidence =
     heroScore >= 80 ? "HIGH" :
     heroScore >= 60 ? "MEDIUM" :
     "LOW"

//=====================================================
// HERO SIGNALS
//=====================================================

bullHero = heroScore >= 80 and bullTrend
bearHero = heroScore >= 80 and bearTrend

//=====================================================
// SUGGESTED TRADE
//=====================================================

suggestedTrade =
     bullHero and orbBull ? "BUY CE" :
     bearHero and orbBear ? "BUY PE" :
     bullHero ? "BUY CE" :
     bearHero ? "BUY PE" :
     "WAIT"

plotshape(
     bullHero,
     title="Bull Hero",
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="HERO")

plotshape(
     bearHero,
     title="Bear Hero",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="HERO")


//=====================================================
// PLOTS
//=====================================================

plot(ema20, title="EMA20", color=color.orange, linewidth=2)
plot(vwapVal, title="VWAP", color=color.blue, linewidth=2)

//=====================================================
// DASHBOARD
//=====================================================

var table dash = table.new(position.top_right, 2, 11, border_width=2, frame_width=2, frame_color=color.white, border_color=color.gray)

if barstate.islast

    pdStatus =
         pdhBreak ? "PDH BREAK" :
         pdlBreak ? "PDL BREAK" :
         "INSIDE"

    orbStatus =
         orbBull ? "UP" :
         orbBear ? "DOWN" :
         "INSIDE"
         

    headerText = syminfo.ticker + " HERO"

    table.cell(dash, 0, 0, headerText,
         bgcolor=color.rgb(25,25,25),
         text_color=color.yellow)

    table.cell(dash, 1, 0, "",
         bgcolor=color.rgb(25,25,25))

    table.cell(dash, 0, 1, "Spot",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 1, str.tostring(math.round(close)),
         bgcolor=color.black,
         text_color=color.lime)

    table.cell(dash, 0, 2, "ATM",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 2, str.tostring(atmStrike),
         bgcolor=color.black,
         text_color=color.aqua)

    table.cell(dash, 0, 3, "Hero CE",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 3, str.tostring(heroCE),
         bgcolor=color.black,
         text_color=color.lime)

    table.cell(dash, 0, 4, "Hero PE",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 4, str.tostring(heroPE),
         bgcolor=color.black,
         text_color=color.red)

    table.cell(dash, 0, 5, "Hero Score",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 5, str.tostring(heroScore),
         bgcolor=color.black,
         text_color=
             heroScore >= 80 ? color.lime :
             heroScore >= 60 ? color.yellow :
             color.red)

    table.cell(dash, 0, 6, "Trend Day %",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 6, str.tostring(trendDay) + "%",
         bgcolor=color.black,
         text_color=
             trendDay >= 75 ? color.lime :
             trendDay >= 50 ? color.yellow :
             color.red)

    table.cell(dash, 0, 7, "Direction",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 7, direction,
         bgcolor=color.black,
         text_color=
             direction == "BULLISH" ? color.lime :
             direction == "BEARISH" ? color.red :
             color.yellow)

    table.cell(dash, 0, 8, "PDH / ORB",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 8, pdStatus + " | " + orbStatus,
         bgcolor=color.black,
         text_color=color.aqua)

    table.cell(dash, 0, 9, "Move / Conf",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 9,
         str.tostring(expectedMove) + " | " + confidence,
         bgcolor=color.black,
         text_color=
             confidence == "HIGH" ? color.lime :
             confidence == "MEDIUM" ? color.yellow :
             color.red)

    table.cell(dash, 0, 10, "Trade",
         bgcolor=color.rgb(40,40,40),
         text_color=color.white)

    table.cell(dash, 1, 10,
         suggestedTrade,
         bgcolor=color.black,
         text_color=
             suggestedTrade == "BUY CE" ? color.lime :
             suggestedTrade == "BUY PE" ? color.red :
             color.yellow)

//=====================================================
// ALERTS
//=====================================================

alertcondition(
     bullHero,
     title="Bull Hero Setup",
     message="Bull Hero Setup Detected")

alertcondition(
     bearHero,
     title="Bear Hero Setup",
     message="Bear Hero Setup Detected")
````
