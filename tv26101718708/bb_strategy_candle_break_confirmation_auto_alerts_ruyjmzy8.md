# BB Strategy - Candle Break Confirmation (Auto Alerts)

- url: https://www.tradingview.com/script/ruYjMZy8-BB-Strategy-Candle-Break-Confirmation-Auto-Alerts/
- type: indicator
- pine_id: PUB;5998d48cdef6490b89eef1df6a84bee1
- version: 1.0

## Description

This indicator is a mean-reversion trading tool that identifies potential price exhaustion and trend reversals by combining Bollinger Bands with strict price action confirmation.

Instead of triggering a signal the moment price touches a band, it waits for extreme overextension followed by a structural break, filtering out false signals during strong trends.

### How the Logic Works

The strategy requires a two-step confirmation for both buying and selling:

* **Buy Signal (Bullish Reversal):**
1. **Overextension:** The *entire* previous candle (including its high) must close completely below the Lower Bollinger Band.
2. **Confirmation:** The current candle must break above the high of that previous candle.


* **Sell Signal (Bearish Reversal):**
1. **Overextension:** The *entire* previous candle (including its low) must close completely above the Upper Bollinger Band.
2. **Confirmation:** The current candle must break below the low of that previous candle.



### Key Features & Settings

* **Customizable Bollinger Bands:** Defaults to a Length of 20 and a Standard Deviation of 1.5. *Note: A 1.5 deviation is tighter than the standard 2.0, allowing it to catch more frequent breakouts. You can adjust this in the settings to filter for more extreme moves.*
* **Visual Chart Markers:** Clearly displays "BUY" (green, below bar) and "SELL" (red, above bar) labels precisely where the price action confirmation occurs.
* **Unified Auto-Alerts:** Uses a single, combined alert condition for both buy and sell signals. The dynamic alert message automatically populates the ticker, current price, and direction (🟢 BUY or 🔴 SELL), making it easy to link to automated trading bots or webhook services.

### Best Use Cases

This indicator performs best in **ranging or consolidating markets** where price consistently returns to the mean (the moving average). It is highly effective on intraday timeframes (like 5m or 15m) for scalping pullbacks, but should be used cautiously during strong, runaway trends where price can "ride the bands" for extended periods.

## Source Code

````pine
//@version=6
indicator("BB Strategy - Candle Break Confirmation (Auto Alerts)", overlay=true)

// ─────────────────────────────
// Bollinger Band settings
length = input.int(20, title="BB Length")
stdDev = input.float(1.5, title="BB Std Dev")

basis = ta.sma(close, length)
dev = stdDev * ta.stdev(close, length)
upperBB = basis + dev
lowerBB = basis - dev

// ─────────────────────────────
// Conditions for previous candle (strict close above/below)
// Note: In v6, if history is insufficient on the first few bars, 
// these safely evaluate to 'false' instead of returning 'na' errors.
prevAboveUpper = low[1] > upperBB[1]   // Previous candle fully above upper BB
prevBelowLower = high[1] < lowerBB[1]  // Previous candle fully below lower BB

// Current candle break confirmation
sellSignal = prevAboveUpper and low < low[1]   // Break previous candle low → Sell
buySignal  = prevBelowLower and high > high[1] // Break previous candle high → Buy

// ─────────────────────────────
// Plot Bollinger Bands
plot(basis, title="Basis", color=color.gray)
plot(upperBB, title="Upper BB", color=color.red)
plot(lowerBB, title="Lower BB", color=color.green)

// ─────────────────────────────
// Plot signals
plotshape(sellSignal, title="Sell Signal", location=location.abovebar,
     color=color.red, style=shape.labeldown, text="SELL", size=size.tiny)

plotshape(buySignal, title="Buy Signal", location=location.belowbar,
     color=color.lime, style=shape.labelup, text="BUY", size=size.tiny)

// ─────────────────────────────
// Combine alerts — single alert triggers for both
alertSignal = buySignal or sellSignal

// When alert triggers, message tells if it's BUY or SELL
alertcondition(alertSignal, title="BB Auto Buy/Sell Alert", 
     message="BB Strategy Signal — {{ticker}}: {{close}} → " +
              "🟢 BUY" + " if candle broke above previous low below lower BB, " +
              "🔴 SELL" + " if candle broke below previous high above upper BB. Check chart for confirmation.")
````
