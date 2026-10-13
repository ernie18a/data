<!-- tradingview-pine-id: PUB;c218cdfaa80c4c74ae5b6608cc0de973 -->
<!-- tradingviewscripts-format: 1 -->
# BB vs EMA 9 Gap Signals

Source: https://www.tradingview.com/script/6tCtEfuw-BB-vs-EMA-9-Gap-Signals/

## Description

### Bollinger Band EMA Gap Signal

This indicator identifies potential **BUY and SELL opportunities** by comparing the distance between the **9-period EMA** and the upper/lower Bollinger Bands.

#### How It Works

The indicator calculates two distances:

* **X** = Upper Bollinger Band − 9 EMA
* **Y** = 9 EMA − Lower Bollinger Band

### 🟢 BUY Signal

A BUY signal is generated when:

1. **Y > X**, meaning the Lower Bollinger Band is farther from the 9 EMA than the Upper Bollinger Band.
2. Price **touches or crosses the Lower Bollinger Band**.

This identifies situations where downside volatility has expanded significantly relative to upside volatility.

### 🔴 SELL Signal

A SELL signal is generated when:

1. **X > Y**, meaning the Upper Bollinger Band is farther from the 9 EMA than the Lower Bollinger Band.
2. Price **touches or crosses the Upper Bollinger Band**.

This identifies situations where upside volatility has expanded significantly relative to downside volatility.

### Key Features

* Uses a **9-period EMA**.
* Uses standard **20-period Bollinger Bands with 2 standard deviations** by default.
* Requires price to touch or cross the relevant Bollinger Band.
* Generates BUY and SELL signals immediately when the conditions are satisfied.
* Includes alert conditions for TradingView alerts.

**Note:** The signals are based on technical conditions and should not be considered guaranteed entry or exit points. Always combine the indicator with proper risk management and market context.

---

## Source Code

````pine
//@version=6
indicator("BB vs EMA 9 Gap Signals", overlay=true)

// ───── Inputs ─────
emaLength = input.int(9, "EMA Length")
bbLength  = input.int(20, "BB Length")
bbMult    = input.float(2.0, "BB Std Dev")

// ───── EMA 9 ─────
ema9 = ta.ema(close, emaLength)

// ───── Bollinger Bands ─────
bbBasis = ta.sma(close, bbLength)
bbDev   = bbMult * ta.stdev(close, bbLength)

upperBB = bbBasis + bbDev
lowerBB = bbBasis - bbDev

// ───── Distance Calculations ─────
// X = distance between Upper BB and EMA 9
X = upperBB - ema9

// Y = distance between EMA 9 and Lower BB
Y = ema9 - lowerBB

// ───── BB Touch / Cross ─────
touchedLowerBB = low <= lowerBB
touchedUpperBB = high >= upperBB

// ───── BUY CONDITION ─────
// Lower BB is farther from EMA than Upper BB
// AND price touches/crosses Lower BB
buySignal = Y > X and touchedLowerBB

// ───── SELL CONDITION ─────
// Upper BB is farther from EMA than Lower BB
// AND price touches/crosses Upper BB
sellSignal = X > Y and touchedUpperBB

// ───── Plot EMA ─────
plot(ema9, "EMA 9", color=color.orange, linewidth=2)

// ───── Plot Bollinger Bands ─────
upperPlot = plot(upperBB, "Upper BB", color=color.blue)
lowerPlot = plot(lowerBB, "Lower BB", color=color.blue)
plot(bbBasis, "BB Basis", color=color.gray)

fill(upperPlot, lowerPlot, color=color.new(color.blue, 90))

// ───── BUY Signal ─────
plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
)

// ───── SELL Signal ─────
plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
)

// ───── Alerts ─────
alertcondition(
     buySignal,
     title="BUY Signal",
     message="BUY: Price touched/crossed Lower BB and Y > X."
)

alertcondition(
     sellSignal,
     title="SELL Signal",
     message="SELL: Price touched/crossed Upper BB and X > Y."
)
````
