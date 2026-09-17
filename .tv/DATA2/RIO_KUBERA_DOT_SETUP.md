<!-- tradingview-pine-id: PUB;0926220cef5e431288bf496dad45f7ba -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RIO KUBERA DOT SETUP

Source: https://www.tradingview.com/script/MPOs6QQ2-RIO-KUBERA-DOT-SETUP/

## Description

# RIO KUBERA DOT SETUP

### EMA & MA Crossover with Impulse, Correction & Volume Confirmation

**RIO KUBERA DOT SETUP** is a simple crossover tool designed to identify potential **continuation and reversal setups**.

### Default Setup

* 🟡 EMA = 5
* 🔵 MA = 9
* ⚪ White Dot = Crossover
* 🟢 Green Arrow = Bullish crossover
* 🔴 Red Arrow = Bearish crossover

EMA and MA values can be changed manually in the settings.

---

## 1. IMPULSE / CONTINUATION

### BUY

Use when the market is in an **uptrend**.

**Conditions:**

* Trend is bullish
* Price makes a pullback
* Price comes near EMA/MA
* ⚪ White Dot appears
* 🟢 Green Arrow appears
* Volume supports the move

**Entry:** Above the confirmation candle.

**Stop Loss:** Below the recent swing low.

**Target:** Minimum 1:2 Risk/Reward.

### SELL

Use the opposite conditions in a downtrend.

**Entry:** Below the confirmation candle.

**Stop Loss:** Above the recent swing high.

**Target:** Minimum 1:2 Risk/Reward.

---

## 2. CORRECTION SETUP

A correction is a temporary move against the main trend.

### Bullish Trend

**UP → CORRECTION DOWN → SUPPORT → GREEN DOT/ARROW → CONTINUATION UP**

Look for the bullish crossover near support or the EMA/MA area.

**SL:** Below correction low.

### Bearish Trend

**DOWN → CORRECTION UP → RESISTANCE → RED DOT/ARROW → CONTINUATION DOWN**

**SL:** Above correction high.

---

## 3. REVERSAL SETUP

Do not treat every crossover as a reversal.

### Bullish Reversal

**Downtrend → Support → Bullish crossover → Break of previous high → Volume confirmation**

### Bearish Reversal

**Uptrend → Resistance → Bearish crossover → Break of previous low → Volume confirmation**

For reversal trades, wait for **market-structure confirmation**.

---

## 4. SIDEWAYS MARKET

⚠️ **Avoid trading every crossover in a sideways market.**

If EMA and MA keep crossing repeatedly:

**WAIT.**

Trade only after:

**Breakout + Candle Confirmation + Volume**

---

## 5. VOLUME CONFIRMATION

Volume should support the move.

### BUY

**Bullish crossover + bullish candle + increasing volume**

### SELL

**Bearish crossover + bearish candle + increasing volume**

For a breakout, prefer **higher-than-recent-average volume**.

---

# RIO KUBERA ENTRY RULE

Don't enter because of the dot alone.

Use:

**TREND + LOCATION + DOT + VOLUME + RISK**

If these align → **Trade Candidate**

If they don't align → **WAIT**

---

# SIMPLE CHECKLIST

### Before BUY

* [ ] Trend bullish
* [ ] Pullback/support identified
* [ ] White Dot appears
* [ ] Green Arrow appears
* [ ] Volume confirms
* [ ] Stop Loss defined
* [ ] Minimum 1:2 R:R

### Before SELL

* [ ] Trend bearish
* [ ] Pullback/resistance identified
* [ ] White Dot appears
* [ ] Red Arrow appears
* [ ] Volume confirms
* [ ] Stop Loss defined
* [ ] Minimum 1:2 R:R

### DON'T TRADE

* [ ] ❌ Choppy sideways market
* [ ] ❌ No volume confirmation
* [ ] ❌ No clear stop loss
* [ ] ❌ Poor Risk/Reward
* [ ] ❌ FOMO entry

---

## RIO KUBERA PRINCIPLE

**The Dot is a signal — not a guarantee.**

**Trend + Structure + Volume + Risk = Better Decisions**

**Protect Capital • Wait for Quality • Execute with Discipline**

*RIO KUBERA DOT SETUP is an educational/analytical tool and does not guarantee trading results. Always manage your own risk.*

---

## Source Code

````pine
//@version=6
indicator("RIO KUBERA DOT SETUP", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaLength = input.int(5, title="EMA Length", minval=1)
maLength  = input.int(9, title="MA Length", minval=1)

maType = input.string(
     "SMA",
     title="MA Type",
     options=["SMA", "EMA"]
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaLine = ta.ema(close, emaLength)

maLine = maType == "SMA" ? ta.sma(close, maLength) : ta.ema(close, maLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CROSSOVER CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullishCross = ta.crossover(emaLine, maLine)
bearishCross = ta.crossunder(emaLine, maLine)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA — YELLOW
// DEFAULT: VISIBLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     emaLine,
     title="EMA",
     color=color.yellow,
     linewidth=2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA — TEAL
// DEFAULT: HIDDEN
// CAN BE ENABLED FROM STYLE TAB
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     maLine,
     title="MA",
     color=color.rgb(50, 130, 145),
     linewidth=2,
     display=display.none
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CROSSOVER DOT — WHITE
// DEFAULT: VISIBLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     bullishCross or bearishCross ? emaLine : na,
     title="Crossover Dot",
     color=color.white,
     style=plot.style_circles,
     linewidth=4
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULLISH ARROW — GREEN
// DEFAULT: VISIBLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     bullishCross,
     title="Bullish Arrow",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BEARISH ARROW — RED
// DEFAULT: VISIBLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     bearishCross,
     title="Bearish Arrow",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     bullishCross,
     title="RIO KUBERA Bullish Crossover",
     message="RIO KUBERA DOT SETUP: Bullish EMA/MA crossover"
)

alertcondition(
     bearishCross,
     title="RIO KUBERA Bearish Crossover",
     message="RIO KUBERA DOT SETUP: Bearish EMA/MA crossover"
)
````
