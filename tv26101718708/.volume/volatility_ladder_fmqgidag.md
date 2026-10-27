# Volatility Ladder

- url: https://www.tradingview.com/script/FmQGiDag-Volatility-Ladder/
- type: indicator
- pine_id: PUB;f6600d72307a42afa1ccdb5771b7dbc4
- version: 1.0

## Description

[b]INTRODUCTION[/b]

The Volatility Ladder is a momentum-based oscillator designed to provide a structured view of short-term market dynamics.
It combines price, volume, and relative positioning to highlight shifts in momentum, identify price swings, and detect areas where the market may be approaching exhaustion.
By operating within a bounded range, the indicator helps standardize the interpretation of market conditions, making it easier to compare relative strength and weakness across different instruments and timeframes.
The Volatility Ladder is intended as a complementary tool for traders seeking a clearer view of momentum behavior and potential turning points, especially when used alongside price action and broader market context.

[b]OVERVIEW[/b]

The Volatility Ladder is a momentum-based oscillator that represents market direction within a bounded range.
It plots values between 0 and 100, where:
 ➡️ Lime bars indicate increasing bullish momentum
 ➡️ Red bars indicate increasing bearish momentum
The oscillator is designed to be both:
 ➡️ smooth, to reduce noise
 ➡️ responsive, to capture shifts in price direction

[b]KEY CHARACTERISTICS[/b]

 ➡️ Oscillates within a fixed range (0–100)
 ➡️ Highlights momentum shifts through color changes
 ➡️ Identifies potential exhaustion zones near extreme levels
When values approach or exceed the boundaries:
 ➡️ Levels near 0 may indicate oversold conditions
 ➡️ Levels near 100 may indicate overbought conditions
In some cases, values may briefly move outside the range, which can signal potential exhaustion and increased likelihood of a reversal, especially when combined with price action.

[b]HOW IT WORKS[/b]

The Volatility Ladder is based on a volume-weighted price approach, combined with normalization and smoothing to produce a bounded momentum oscillator.
First, price is weighted by volume and averaged over a rolling window (Length), creating a proxy for volume-adjusted price (PA). This gives more importance to price movements occurring with higher trading activity.
The resulting series is then normalized over a lookback period (Period) using a stochastic-style calculation, scaling values between 0 and 100. This allows the indicator to highlight relative extremes in a consistent way across different market conditions.
To reduce noise while maintaining responsiveness, the normalized values are smoothed twice using a Linear Weighted Moving Average. This produces two components:
 ➡️ a faster line (pak)
 ➡️ a slower line (pad)
Momentum direction is derived from their relationship:
 ➡️ Bullish momentum when the faster component is above the slower one
 ➡️ Bearish momentum when the faster component is below
Overall, the indicator combines volume participation, relative positioning, and smoothed momentum to provide a stable view of short-term market direction within a bounded range.

[b]INPUTS[/b]

 ➡️ Period: defines the number of bars used in the LWMA calculation.
 ➡️ Length: adjusts the sensitivity of the oscillator, affecting how quickly it reacts to changes in price.

[b]USAGE[/b]

The Volatility Ladder Indicator is typically used to identify potential reversal zones and momentum shifts, rather than as a standalone signal generator.

 🅰️ [b]Bullish Context[/b]
  ➡️ Look for values approaching the lower bound (near 0)
  ➡️ A transition to lime bars may indicate strengthening bullish momentum
  ➡️ Confirmation with price action or structure is recommended

 🅱️ [b]Bearish Context[/b]
  ➡️ Look for values approaching the upper bound (near 100)
  ➡️ A transition to red bars may indicate strengthening bearish momentum
  ➡️ Confirmation with price action or structure is recommended

[b]NOTES[/b]

This indicator is best used in conjunction with:
 ➡️ higher timeframe trend analysis
 ➡️ support and resistance levels
 ➡️ price action confirmation
It is not intended to provide standalone trading signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SaxaCapital

//@version=6
indicator('Volatility Ladder', shorttitle = 'Ladder', precision = 2, overlay = false)

Period  = input.int(title = 'Period', defval = 10, minval = 1, maxval = 20)
Length  = input.int(title = 'Length', defval = 5, minval = 1, maxval = 10)
colorUp = input.color(defval = color.rgb(0, 255, 123, 0), title = 'Color Up')
colorDn = input.color(defval = color.rgb(255, 64, 0,  0), title = 'Color Down')

Cost   = hlcc4 * volume

sumCost = math.sum(Cost, Length)
sumVol  = math.sum(volume, Length)
PA      = sumCost / sumVol

rsv = (PA-ta.lowest(PA, Period)) / (ta.highest(PA, Period) - ta.lowest(PA, Period)) * 100

pak = ta.wma(rsv, Length)
pad = ta.wma(pak, Length)

// --- PLOTTING SECTION ---

plotcandle( pad, pak, pad, pak, color = pad <= pak ? colorUp : colorDn, display = display.pane )
band1 = hline(100)
band0 = hline(0)
````
