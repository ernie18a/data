# ATR/DTR Improved - JKnappers

- url: https://www.tradingview.com/script/WvpKBhxb-ATR-DTR-Improved-JKnappers/
- type: indicator
- pine_id: PUB;39f4dd9271d44985ba44c12832b55295
- version: 1.0

## Description

This indicator is based on the original **ATR/DTR** script by **TraderCreatorPro**.

The original concept calculates the relationship between the current daily trading range and Average True Range (ATR), and displays:

* ATR
* DTR
* DTR as a percentage of ATR

### Modifications in this version

Modified by **JKnappers — 2026-08-12**

Changes compared with the original script:

* Uses `syminfo.tickerid` instead of `syminfo.ticker` to reference the exact chart symbol/feed.
* Adds a configurable ATR length.
* Default ATR length is 14.
* ATR is calculated  from a selectable higher timeframe, defaulting to 1 day.
* Uses the **previous completed higher-timeframe ATR** as the fixed ATR benchmark.
* Keeps DTR as the **current developing high-low range**.
* Calculates the percentage as:
  **Current DTR / Previous completed ATR × 100**
* Keeps the configurable percentage threshold for changing the table background color.
* Displays ATR, DTR and the current percentage in a compact table.

### Why use the previous completed ATR?

The original script uses the current developing daily candle in the ATR calculation. This means the ATR value can change during the trading session.

This modified version instead uses the ATR value from the previous completed daily candle. That provides a fixed volatility benchmark throughout the current trading day, while DTR continues to update in real time.

This makes the percentage easier to use as an intraday extension reference:

* ATR = fixed reference based on completed data
* DTR = current day's developing range
* Percentage = how much of that reference range has currently been used

### Credits

Original ATR/DTR concept and source code: **TraderCreatorPro**

Modified version: **JKnappers — 2026-08-12**

The original source code is published under the **Mozilla Public License 2.0**. This modified version retains that license and attribution.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// Original concept © TraderCreatorPro
//
// Modified version - Jknappers - 20260812
// uses syminfo.tickerid instead of syminfo.ticker
// lets you choose the ATR length
// defaults to ATR length 14
// calculates ATR from the selected higher timeframe
// uses the PREVIOUS COMPLETED higher-timeframe ATR as the fixed benchmark
// keeps today's DTR as the CURRENT developing high-low range
// calculates DTR percentage as current DTR / previous completed ATR
// shows ATR, DTR and percentage in the table
// keeps the configurable color-change threshold
// purpose: use a stable ATR reference during the trading day instead of a moving live ATR

//@version=6
indicator("ATR/DTR Improved - JKnappers", overlay = true)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
atrTimeFrame = input.timeframe("1D", "ATR / DTR Timeframe")
atrLength = input.int(14, "ATR Length", minval = 1)

percentColorThreshold = input.int(
     100,
     "Percentage the color will change at",
     minval = 1
)

normalColor = input.color(
     color.gray,
     "Color under percentage"
)

overColor = input.color(
     color.white,
     "Color over percentage"
)

boxPlacement = input.string(
     position.bottom_right,
     "Box Placement",
     options = [
         position.bottom_right,
         position.bottom_left,
         position.top_right,
         position.top_center,
         position.bottom_center
     ]
)

// ─────────────────────────────────────────────
// ATR
//
// Uses the exact chart symbol/feed via syminfo.tickerid.
//
// [1] means:
// use the ATR value from the previous COMPLETED
// higher-timeframe candle.
//
// On a 1D timeframe this means:
// today's DTR is compared against YESTERDAY'S
// completed ATR value.
//
// This keeps the ATR benchmark fixed during
// the entire current trading day.
// ─────────────────────────────────────────────
atr = request.security(
     syminfo.tickerid,
     atrTimeFrame,
     ta.atr(atrLength)[1]
)

// ─────────────────────────────────────────────
// DTR
//
// Current developing higher-timeframe high-low.
//
// On a 1D timeframe:
// DTR = today's current High - today's current Low.
//
// This deliberately uses high-low rather than
// Wilder True Range because the purpose is to
// measure how much actual intraday range has
// developed today.
// ─────────────────────────────────────────────
dtr = request.security(
     syminfo.tickerid,
     atrTimeFrame,
     high - low
)

// ─────────────────────────────────────────────
// Percentage of previous completed ATR used
//
// Example:
// Previous daily ATR = 635
// Current DTR        = 104
//
// 104 / 635 * 100 = 16.38%
// Displayed as 16%
// ─────────────────────────────────────────────
atrPercent = atr > 0 ? dtr / atr * 100 : na

// Rounded display values
atrRounded = math.round(atr * 100) / 100
dtrRounded = math.round(dtr * 100) / 100
percentRounded = math.round(atrPercent)

// ─────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────
var table atrDtrTable = table.new(
     boxPlacement,
     3,
     1,
     bgcolor = normalColor,
     border_color = color.teal,
     border_width = 2
)

if barstate.islast
    currentColor = atrPercent >= percentColorThreshold ? overColor : normalColor

    table.set_bgcolor(
         atrDtrTable,
         currentColor
    )

    table.cell(
         atrDtrTable,
         0,
         0,
         text = "ATR(" + str.tostring(atrLength) + "): " + str.tostring(atrRounded)
    )

    table.cell(
         atrDtrTable,
         1,
         0,
         text = "DTR: " + str.tostring(dtrRounded)
    )

    table.cell(
         atrDtrTable,
         2,
         0,
         text = str.tostring(percentRounded) + "%"
    )

plot(na)
````
