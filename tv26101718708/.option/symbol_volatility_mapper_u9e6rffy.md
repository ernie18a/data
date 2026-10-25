# Symbol Volatility Mapper

- url: https://www.tradingview.com/script/u9E6rFfY-Symbol-Volatility-Mapper/
- type: indicator
- pine_id: PUB;9389afbb9446411485b9902e6839d8a4
- version: 2.0

## Description

# Symbol Volatility Mapper

## Overview

Symbol Volatility Mapper automatically selects and plots the corresponding volatility index for the active chart symbol.

The script is designed to simplify cross-asset volatility analysis by linking major equity indices and selected commodity futures to their commonly referenced implied volatility benchmarks. This allows traders to monitor the relevant volatility regime directly from the underlying chart without manually switching between symbols.

## Supported Mappings

- **SPX / ES** -> `CBOE:VIX`
- **NDX / NQ** -> `CBOE:VXN`
- **RUT / RTY** -> `CBOE:RVX`
- **DAX / FDAX** -> `EUREX:VDAX-NEW`
- **Gold / GC** -> `CBOE:GVZ`
- **Crude Oil / CL** -> `CBOE:OVX`

## Features

- Automatic symbol recognition using `syminfo.ticker` and `syminfo.root`
- Dynamic mapping of the active chart to its corresponding volatility index
- Clean volatility plot in a separate pane
- On-chart label showing the currently active symbol mapping
- Graceful fallback when no supported mapping is available

## How It Works

The indicator checks the active chart symbol and determines whether it matches one of the supported index or futures roots. Once a valid match is found, the script requests the `close` data of the corresponding volatility index and plots it in real time.

This approach makes it easier to compare price action in the underlying market with its associated implied volatility measure, which can be useful for context, regime identification, and discretionary decision-making.

## Typical Use Cases

- Monitoring implied volatility alongside major equity indices
- Tracking sentiment shifts in SPX, NDX, and RUT through VIX, VXN, and RVX
- Observing volatility conditions in Gold and Crude Oil markets
- Keeping the relevant volatility benchmark visible without manually changing symbols

## Notes

This script is intended for use in a separate pane (`overlay=false`).

Mapped symbols must be available through your TradingView data feed. Depending on the exchange or subscription plan, some volatility indices may not be accessible for all users.

## Release Notes

### Version 1.0.0

Initial public release.

- Added automatic volatility index mapping based on the active chart symbol
- Added support for SPX / VIX
- Added support for NDX / VXN
- Added support for RUT / RVX
- Added support for DAX / VDAX-NEW
- Added support for Gold / GVZ
- Added support for Crude Oil / OVX
- Added an on-chart label displaying the active mapping

## Disclaimer

This indicator is provided for informational and educational purposes only. It does not constitute financial advice, investment guidance, or a recommendation to buy or sell any instrument.

## Source Code

````pine
//@version=6
indicator("Symbol Volatility Mapper", overlay=false)

// === User input: IBKR-style lookback ===
weeksInput = input.int(52, "Lookback (weeks)", options=[13, 26, 52])
lookbackDays = weeksInput * 5  // 13w=65, 26w=130, 52w=260 trading days approximation

// === Fixed 1-year lookback ===
string volSymbol = switch syminfo.root
    "DJI"    => "CBOE:VXD"
    "DJIA"   => "CBOE:VXD"
    "YM"     => "CBOE:VXD"
    "ES"     => "CBOE:VIX"
    "SPX"    => "CBOE:VIX"
    "NQ"     => "CBOE:VXN"
    "NDX"    => "CBOE:VXN"
    "QQQ"    => "CBOE:VXN"
    "RTY"    => "CBOE:RVX"
    "RUT"    => "CBOE:RVX"
    "FDAX"   => "EUREX:VDAX-NEW"
    "GC"     => "CBOE:GVZ"
    "GOLD"   => "CBOE:GVZ"
    "SI"     => "CBOE:VXSLV"
    "SILVER" => "CBOE:VXSLV"
    "CL"     => "CBOE:OVX"
    "VIX"    => "CBOE:VVIX"
    "BITCOIN" => "DERIBIT:DVOL"
    "BTCUSDT.P" => "DERIBIT:DVOL"
    => na

// === Plot series on active chart timeframe ===
float volPlot = na(volSymbol) ? na : request.security(volSymbol, timeframe.period, close)

// === Confirmed daily close series for stable IBKR-like calculations ===
float volDailyConfirmed = na(volSymbol) ? na : request.security(volSymbol, "D", close[1])

// === Daily High / Low based on confirmed daily closes ===
float volDailyLow  = ta.lowest(volDailyConfirmed, lookbackDays)
float volDailyHigh = ta.highest(volDailyConfirmed, lookbackDays)

// === IBKR-style Rank ===
float volRank = (volDailyHigh != volDailyLow) ? ((volDailyConfirmed - volDailyLow) / (volDailyHigh - volDailyLow)) * 100 : na

// === IBKR-style Percentile ===
float volPercentile = ta.percentrank(volDailyConfirmed, lookbackDays)

// === Plots ===
plot(volPlot, title="Volatility Index", color=color.orange, linewidth=2)
plot(volRank, title="Volatility Rank", color=color.lime, linewidth=2)
plot(volPercentile, title="Volatility Percentile", color=color.aqua, linewidth=2)

var table infoTable = table.new(position.bottom_right, 2, 5, border_width=0)
bgHeader = color.new(color.rgb(40, 40, 40), 75)
bgValue  = color.new(color.rgb(25, 25, 25), 85)

if barstate.islast
    table.clear(infoTable, 0, 0, 1, 4)

    table.cell(infoTable, 0, 0, "Vol Index",  text_color=color.new(color.white, 10), bgcolor=bgHeader, text_size=size.tiny)
    table.cell(infoTable, 1, 0, na(volSymbol) ? "N/A" : volSymbol, text_color=color.new(color.orange, 20), bgcolor=bgValue, text_size=size.tiny)

    table.cell(infoTable, 0, 1, "Vola",       text_color=color.new(color.white, 10), bgcolor=bgHeader, text_size=size.tiny)
    table.cell(infoTable, 1, 1, na(volPlot) ? "N/A" : str.tostring(volPlot, "#.##"), text_color=color.new(color.orange, 20), bgcolor=bgValue, text_size=size.tiny)

    table.cell(infoTable, 0, 2, "Rank",       text_color=color.new(color.white, 10), bgcolor=bgHeader, text_size=size.tiny)
    table.cell(infoTable, 1, 2, na(volRank) ? "N/A" : str.tostring(volRank, "#.##"), text_color=color.new(color.lime, 20), bgcolor=bgValue, text_size=size.tiny)

    table.cell(infoTable, 0, 3, "Percentile", text_color=color.new(color.white, 10), bgcolor=bgHeader, text_size=size.tiny)
    table.cell(infoTable, 1, 3, na(volPercentile) ? "N/A" : str.tostring(volPercentile, "#.##"), text_color=color.new(color.aqua, 20), bgcolor=bgValue, text_size=size.tiny)
````
