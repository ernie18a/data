# Bollinger Squeeze Alert - NY Open Window

- url: https://www.tradingview.com/script/onRhLOiq-Bollinger-Squeeze-Alert-NY-Open-Window/
- type: indicator
- pine_id: PUB;6b6f6e20341342e5b35ef28c308b5f59
- version: 2.0

## Description

This indicator identifies a **Bollinger Squeeze** condition where the Bollinger Bands contract inside the Keltner Channel.

A squeeze usually means the market is in a low-volatility compression phase. This can sometimes happen before a larger volatility expansion or breakout move.

This script is designed especially for traders who want to monitor squeeze conditions around the **New York market open**.

### What this indicator does

The indicator checks whether:

**Bollinger Upper Band is below Keltner Upper Channel**
and
**Bollinger Lower Band is above Keltner Lower Channel**

When both conditions are true, the Bollinger Bands are fully inside the Keltner Channel, meaning a squeeze is active.

The script also includes a time filter so alerts only trigger during the selected New York open window.

Default alert window:

**8:30 AM to 10:30 AM New York time**

### Main features

* Detects active Bollinger Squeeze conditions
* Uses Bollinger Bands and Keltner Channels together
* Includes a New York time-based alert window
* Highlights the chart background when a valid squeeze is active
* Provides alert options for:

  * Squeeze active during the NY open window
  * New squeeze starting during the NY open window
* Works on futures, indices, stocks, ETFs, and other instruments

### Suggested use

This indicator can be useful for traders who monitor compression before volatility expansion, especially near the US market open.

For example, on ES futures, a trader may use this to identify when the market is compressed between **8:30 AM and 10:30 AM New York time** and then watch for a possible breakout or volatility expansion.

### Important note

This indicator does not predict direction.
It only identifies volatility compression.

A squeeze can break upward, downward, or fail completely. It should be combined with price action, volume, market context, trend, support/resistance, and proper risk management.

### Disclaimer

This script is for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or option. Trading involves risk, and past performance does not guarantee future results. Always do your own research and manage risk carefully.

## Source Code

````pine
//@version=6
indicator("Bollinger Squeeze Alert - NY Open Window", overlay=true)

// Inputs
bbLength = input.int(20, "Bollinger Length")
bbMult   = input.float(2.0, "Bollinger Multiplier")

kcLength = input.int(20, "Keltner Length")
kcMult   = input.float(1.5, "Keltner Multiplier")

// Time window: 8:30 AM to 10:30 AM New York time
sessionWindow = input.session("0830-1030", "NY Open Alert Window")
timezoneInput = input.string("America/New_York", "Timezone")

// Bollinger Bands
basis = ta.sma(close, bbLength)
dev   = bbMult * ta.stdev(close, bbLength)
bbUpper = basis + dev
bbLower = basis - dev

// Keltner Channel
kcBasis = ta.ema(close, kcLength)
atrVal  = ta.atr(kcLength)
kcUpper = kcBasis + kcMult * atrVal
kcLower = kcBasis - kcMult * atrVal

// Squeeze condition: Bollinger Bands inside Keltner Channel
squeezeOn = bbUpper < kcUpper and bbLower > kcLower

// Time filter
inNYOpenWindow = not na(time(timeframe.period, sessionWindow, timezoneInput))

// Final conditions
squeezeInWindow = squeezeOn and inNYOpenWindow
squeezeStartedInWindow = squeezeInWindow and not squeezeInWindow[1]

// Plot bands
plot(bbUpper, "BB Upper", color=color.red)
plot(bbLower, "BB Lower", color=color.green)

plot(kcUpper, "KC Upper", color=color.blue)
plot(kcLower, "KC Lower", color=color.blue)

// Highlight background only when squeeze is active inside the time window
bgcolor(squeezeInWindow ? color.new(color.green, 55) : na)

// Alerts - keep these on one line
alertcondition(squeezeInWindow, title="Squeeze Active in NY Open Window", message="ES Bollinger Squeeze is active between 8:30 AM and 10:30 AM New York time.")
alertcondition(squeezeStartedInWindow, title="Squeeze Started in NY Open Window", message="New ES Bollinger Squeeze has started during the NY open window.")
````
