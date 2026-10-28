# ADR 5 DAY 

- url: https://www.tradingview.com/script/I8Vst0Xz-ADR-5-DAY/
- type: indicator
- pine_id: PUB;8a4676e2931846edabddde5195b348ec
- version: 1.0

## Description

Calculates ADR using the previous 5 or 10 completed trading days.
Automatically detects Forex instruments and displays values in pips.
Displays Futures, Indices, and Stocks in points.
Clean table display directly on the chart.
Useful for setting realistic profit targets and managing trade expectations.
Helps identify whether an instrument has already reached or exceeded its typical daily movement.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SATORI1OF1

//@version=6
indicator("ADR")
// === INPUTS ===
adrPeriod = input.int(5, "ADR Period", options=[5, 10])

// === DAILY DATA ===
dailyHigh = request.security(syminfo.tickerid, "D", high[1])
dailyLow  = request.security(syminfo.tickerid, "D", low[1])

// Daily Range
dailyRange = dailyHigh - dailyLow

// ADR Calculation
adr = ta.sma(dailyRange, adrPeriod)

// === FOREX OR OTHER MARKET ===
isForex = syminfo.type == "forex"

// Calculate value in pips or points
value =
     isForex
     ? adr / (str.contains(syminfo.ticker, "JPY") ? 0.01 : 0.0001)
     : adr / syminfo.mintick

unit = isForex ? " Pips" : " Points"

// === TABLE DISPLAY ===
var table adrTable = table.new(position.top_right, 1, 2)

if barstate.islast
    table.cell(adrTable, 0, 0, "ADR (" + str.tostring(adrPeriod) + " Day)")
    table.cell(adrTable, 0, 1, str.tostring(math.round(value)) + unit)
plot(close)
plot(value, title="ADR", color=color.blue, linewidth=2, display=display.data_window)
````
