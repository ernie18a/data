<!-- tradingview-pine-id: PUB;4168a2e190f84c20abde988a563fbbf5 -->
<!-- tradingviewscripts-format: 1 -->
# BUY SELL Indicator v6

Source: https://www.tradingview.com/script/2xpqff5s-BUY-SELL-Indicator/

## Description

BUY & SELL Indicator — EMA + RSI Confirmation

This Pine Script v6 indicator is designed to help traders identify potential BUY and SELL opportunities using a combination of EMA crossover and RSI confirmation.

🔹 How It Works

BUY Signal

- Fast EMA crosses above the Slow EMA
- RSI is above the selected level
- A BUY label appears below the candle

SELL Signal

- Fast EMA crosses below the Slow EMA
- RSI is below the selected level
- A SELL label appears above the candle

⚙️ Features

- Pine Script v6
- Fast and Slow EMA settings
- Adjustable RSI confirmation
- Clear BUY/SELL chart labels
- Built-in alert conditions
- Easy-to-use settings

This indicator can be used across different markets and timeframes. Traders can adjust the EMA and RSI settings according to their trading style and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("BUY SELL Indicator v6", overlay=true)

// === Settings ===
fastLength = input.int(9, "Fast EMA")
slowLength = input.int(21, "Slow EMA")
rsiLength  = input.int(14, "RSI Length")
rsiBuy     = input.int(50, "Minimum RSI for BUY")
rsiSell    = input.int(50, "Maximum RSI for SELL")

// === Indicators ===
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)
rsiValue = ta.rsi(close, rsiLength)

// === BUY / SELL Conditions ===
buySignal  = ta.crossover(fastEMA, slowEMA) and rsiValue > rsiBuy
sellSignal = ta.crossunder(fastEMA, slowEMA) and rsiValue < rsiSell

// === Plot EMAs ===
plot(fastEMA, title="Fast EMA", color=color.green, linewidth=2)
plot(slowEMA, title="Slow EMA", color=color.red, linewidth=2)

// === BUY / SELL Labels ===
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

// === Alerts ===
alertcondition(buySignal, title="BUY Alert", message="BUY signal detected")
alertcondition(sellSignal, title="SELL Alert", message="SELL signal detected")
````
