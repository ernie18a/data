# Liquidity Rejection Auto Target

- url: https://www.tradingview.com/script/p5VYiUET-Liquidity-Rejection-Auto-Target/
- type: indicator
- pine_id: PUB;aa273dcb6db34431991a9ac29ef6998d
- version: 3.0

## Description

[b]Overview[/b]

[b]Liquidity Rejection Auto Target[/b] is a price action indicator designed to identify potential liquidity sweeps followed by rejection candles. The indicator automatically highlights possible long and short trading opportunities based on swing high and swing low liquidity concepts while plotting an entry level, stop loss, and a risk-reward based take-profit target.

This tool is intended to assist traders in identifying areas where price briefly moves beyond a recent swing level before returning back inside the range, which may indicate a rejection of that liquidity level.

How It Works

Bullish Setup

- Detects the most recent confirmed swing low.
- Waits for price to move below that swing low (liquidity sweep).
- Confirms the setup when the candle closes back above the swing low.
- Plots a BUY signal.
- Uses the rejection candle low as the Stop Loss.
- Calculates the Take Profit automatically using the selected Risk:Reward ratio.

Bearish Setup

- Detects the most recent confirmed swing high.
- Waits for price to move above that swing high (liquidity sweep).
- Confirms the setup when the candle closes back below the swing high.
- Plots a SELL signal.
- Uses the rejection candle high as the Stop Loss.
- Calculates the Take Profit automatically using the selected Risk:Reward ratio.

Features

• Automatic liquidity sweep detection

• Bullish and bearish rejection confirmation

• Automatic BUY and SELL signals

• Entry, Stop Loss, and Take Profit plotting

• Adjustable swing detection settings

• Configurable Risk:Reward ratio

• TradingView alert support

• Overlay display directly on the price chart

Inputs

Pivot Left / Right
Adjusts how swing highs and swing lows are identified. Larger values produce stronger but less frequent signals, while smaller values react more quickly to price changes.

Risk:Reward
Defines the automatic take-profit distance relative to the calculated stop-loss distance.

Best Practices

This indicator works best on liquid markets where swing highs and swing lows are clearly formed. Many traders use it together with higher-timeframe market structure, trend analysis, support and resistance, or volume confirmation to help filter potential trade setups.

Alerts

TradingView alert conditions are included for both BUY and SELL signals, allowing users to create notifications whenever a new setup is detected.

Disclaimer

This indicator is an analytical tool and should not be considered financial or investment advice. Market conditions vary, and no indicator can guarantee profitable trades. Always perform your own analysis, apply sound risk management, and test any trading strategy before using it in live markets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("Liquidity Rejection Auto Target", overlay=true, max_lines_count=500, max_labels_count=500)

leftBars  = input.int(5, "Pivot Left")
rightBars = input.int(5, "Pivot Right")
rr         = input.float(2.0, "Risk Reward", minval=1)

ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

buySignal = not na(lastLow) and low < lastLow and close > lastLow

sellSignal = not na(lastHigh) and high > lastHigh and close < lastHigh

buySL = low
buyEntry = close
buyTP = buyEntry + (buyEntry - buySL) * rr

sellSL = high
sellEntry = close
sellTP = sellEntry - (sellSL - sellEntry) * rr

plotshape(buySignal, title="BUY", style=shape.triangleup,
     color=color.lime, location=location.belowbar,
     size=size.small, text="BUY")

plotshape(sellSignal, title="SELL", style=shape.triangledown,
     color=color.red, location=location.abovebar,
     size=size.small, text="SELL")

if buySignal
    line.new(bar_index, buyEntry, bar_index + 20, buyEntry,
         color=color.blue)
    line.new(bar_index, buySL, bar_index + 20, buySL,
         color=color.red)
    line.new(bar_index, buyTP, bar_index + 20, buyTP,
         color=color.green)

if sellSignal
    line.new(bar_index, sellEntry, bar_index + 20, sellEntry,
         color=color.blue)
    line.new(bar_index, sellSL, bar_index + 20, sellSL,
         color=color.red)
    line.new(bar_index, sellTP, bar_index + 20, sellTP,
         color=color.green)

alertcondition(buySignal, title="Buy Alert",
     message="Liquidity Rejection BUY")

alertcondition(sellSignal, title="Sell Alert",
     message="Liquidity Rejection SELL")
````
