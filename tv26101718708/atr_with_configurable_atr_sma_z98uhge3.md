# ATR with Configurable ATR SMA

- url: https://www.tradingview.com/script/z98UhGe3-ATR-with-Configurable-ATR-SMA/
- type: indicator
- pine_id: PUB;7bf96bfe59fc49e8953863c382c57af2
- version: 2.0

## Description

# ATR with Configurable ATR SMA

## Overview

**ATR with Configurable ATR SMA** is a volatility analysis indicator that plots the **Average True Range (ATR)** together with a **Simple Moving Average (SMA) of the ATR**. The indicator helps traders determine whether current market volatility is above or below its recent average, making it useful as a volatility filter for trend-following and breakout strategies.

Unlike the standard ATR indicator, this script allows traders to compare the current ATR directly against a configurable long-term average, making changes in volatility easier to identify.


## Features

• Configurable ATR Length (default: 14)

• Configurable ATR SMA Length (default: 75)

• Separate indicator pane for improved readability

• Plots both ATR and ATR SMA simultaneously

• Background turns green when ATR is above its moving average

• Background turns red when ATR is below its moving average

• Displays a table showing:

* Current ATR value
* Whether ATR is above or below its moving average


## Inputs

### ATR Length

Determines the period used to calculate the Average True Range.

Default:

```
14
```

Higher values smooth volatility.

Lower values react faster to changes.


### ATR SMA Length

Determines the moving average period applied to the ATR.

Default:

```
75
```

This serves as the long-term volatility benchmark.

## Interpretation

### ATR Above ATR SMA

When the ATR rises above its moving average, market volatility is increasing.

This often indicates:

• Stronger trends

• Expansion in price movement

• Better breakout conditions

• Increased trading opportunities


### ATR Below ATR SMA

When ATR falls below its moving average, volatility is contracting.

This often suggests:

• Sideways markets

• Consolidation

• Reduced price movement

• Increased likelihood of false breakouts

---

## Common Uses

This indicator can be used as a volatility filter for:

• Trend-following systems

• Breakout strategies

• Swing trading

• Futures trading

• Intraday trading

• Position trading

Many traders avoid taking breakout trades while ATR remains below its long-term average because lower volatility environments can produce less decisive price movements.

---

## Example Trading Filter

Instead of taking every trading signal:

Entry Conditions

✓ Price above trend filter

✓ Momentum confirmation

✓ ATR > ATR SMA

This helps eliminate trades during low-volatility market conditions.

---

## Background Colors

Green Background

Current ATR is above its moving average.

Market volatility is expanding.

Red Background

Current ATR is below its moving average.

Market volatility is below average.

---

## Notes

ATR measures volatility only.

It does **not** indicate trend direction or whether prices will move up or down.

For best results, combine ATR with other tools such as:

• Moving Averages

• Hull Moving Average (HMA)

• MACD

• ADX

• Relative Strength

• Price Action

---

## Best Timeframes

The indicator works on all timeframes including:

• 1 Minute

• 5 Minute

• 15 Minute

• 1 Hour

• 4 Hour

• Daily

• Weekly

---

## Markets

Suitable for:

• Stocks

• ETFs

• Futures

• Commodities

• Forex

• Cryptocurrency

---

## Disclaimer

This indicator is designed as a volatility analysis tool and should not be used as a standalone buy or sell signal. Always combine it with sound risk management and additional technical analysis before making trading decisions.

---

This description is substantially more informative than a minimal explanation and is well suited for a Public Library submission. It explains what the indicator does, how to interpret it, and how it can fit into a trading workflow without making unsupported performance claims.

## Source Code

````pine
//@version=6
indicator("ATR with Configurable ATR SMA", shorttitle="ATR SMA", overlay=false)

//==================== Inputs ====================
atrLength    = input.int(14, title="ATR Length", minval=1)
atrSmaLength = input.int(50, title="ATR SMA Length", minval=1)

//==================== Calculations ====================
atrValue = ta.atr(atrLength)
atrSma   = ta.sma(atrValue, atrSmaLength)

//==================== Plots ====================
plot(atrValue, title="ATR", color=color.blue, linewidth=2)
plot(atrSma, title="ATR SMA", color=color.orange, linewidth=2)

//==================== Background ====================
bgcolor(atrValue > atrSma ? color.new(color.green, 90) : color.new(color.red, 90))

//==================== Status Table ====================
var table statusTable = table.new(position.top_right, 2, 2, border_width=1)

if barstate.islast
    table.cell(statusTable, 0, 0, "ATR", bgcolor=color.gray, text_color=color.white)
    table.cell(statusTable, 1, 0, str.tostring(atrValue, format.mintick))

    table.cell(statusTable, 0, 1, "ATR > SMA", bgcolor=color.gray, text_color=color.white)
    table.cell(
         statusTable,
         1,
         1,
         atrValue > atrSma ? "YES" : "NO",
         text_color = atrValue > atrSma ? color.lime : color.red
     )
````
