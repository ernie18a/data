# Mr Balwants ADR (Previous 14 Days)

- url: https://www.tradingview.com/script/J89oUALf-Mr-Balwants-ADR-Previous-14-Days/
- type: indicator
- pine_id: PUB;a7cc57a020024d318faae8a4ca0f8812
- version: 1.0

## Description

# ADR (Previous 14 Days)

This indicator calculates the Average Daily Range (ADR) using the previous 14 completed trading days.

The ADR is determined by taking the daily range (High - Low) of each completed day and calculating the average over the selected lookback period. The current day's incomplete range is excluded to ensure that the value is based only on confirmed market data.

Features:
• Uses completed daily candles only.
• Calculates ADR from the previous 14 trading days.
• Displays the current ADR value in a clean table.
• Works on any market, including Forex, Indices, Commodities, Crypto, and Stocks.
• Lightweight and easy to read.

How to Use:
• Compare the current day's range with the ADR to understand whether the market has already completed most of its typical daily movement.
• Use ADR as a reference for profit targets, volatility analysis, and trade management.
• Particularly useful for day traders and swing traders who want a quick estimate of expected daily movement.

Note:
ADR is a volatility measurement tool and should not be used as a standalone trading signal. It is intended to complement an existing trading strategy.

## Source Code

````pine
//@version=6
indicator("Mr Balwants ADR (Previous 14 Days)", overlay=true)

// Input
length = input.int(14, "ADR Length", minval=1)

// Calculate ADR using previous completed daily candles
adr = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(high - low, length)[1],
     lookahead = barmerge.lookahead_off)

// Create table
var table t = table.new(
     position.top_right,
     2,
     2,
     bgcolor=color.black,
     frame_color=color.white,
     frame_width=1)

// Display table
if barstate.islast
    table.cell(
         t, 0, 0,
         "ADR Length",
         text_color=color.white,
         bgcolor=color.rgb(40, 40, 40))

    table.cell(
         t, 1, 0,
         str.tostring(length),
         text_color=color.white)

    table.cell(
         t, 0, 1,
         "ADR",
         text_color=color.white,
         bgcolor=color.rgb(40, 40, 40))

    table.cell(
         t, 1, 1,
         str.tostring(adr, "#.0"),
         text_color=color.white)
````
