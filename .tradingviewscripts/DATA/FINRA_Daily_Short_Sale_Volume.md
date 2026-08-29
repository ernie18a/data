<!-- tradingview-pine-id: PUB;404bf27f631f4578a758b92f319f6a9d -->
<!-- tradingviewscripts-format: 1 -->
# FINRA Daily Short Sale Volume

Source: https://www.tradingview.com/script/4KIgeLGo-FINRA-Daily-Short-Sale-Volume/

## Description

█ OVERVIEW

This indicator displays the [Daily Short Sale ​Volume data](https://www.finra.org/finra-data/browse-catalog/short-sale-volume-data) reported by [FINRA](https://www.finra.org/) for US Stocks markets, namely NASDAQ, NYSE and NYSE ARCA.

█ CONCEPTS

Daily Short Sale ​Volume data is different from the bi-monthly [Short Interest](https://www.finra.org/filing-reporting/regulatory-filing-systems/short-interest) data also reported by FINRA. Whereas Short Interest represents open positions, Short Sale ​Volume represents transactions, some of which are executed to offset other trades that will not necessarily result in an open short position reported in Short Interest data. This explains why Short Sale ​Volume values are always greater than Short Interest ones.

Daily Short Sale ​Volume provides aggregated ​volume by security for all short trades executed and reported to FINRA during normal market hours, i.e., media-reported trades. It's important to note that Short Sale ​Volume is not consolidated with exchange data and excludes trading activity that is not publicly disseminated.

█ HOW TO USE IT

Load the indicator on an active chart (see [here](https://www.tradingview.com/u/?solution=43000555216) if you don't know how). 

If the chart's symbol is traded on one of the exchanges for which FINRA provides Daily Short Sale ​Volume, it will be displayed in columns. The columns are a brighter red when their value is above average.

You can display Short Sale ​Volume for another symbol by checking the "Other symbol" checkbox of the script settings' "Inputs" tab and selecting the symbol.

The moving average's length is in days, as Short ​Volume is daily data. You can hide the average in the script's settings "Style" tab.

█ NOTES

You will find more information on the [Short Sale ​Volume Data](https://www.finra.org/finra-data/browse-catalog/short-sale-volume-data) and [Understanding Short Sale ​Volume Data](https://www.finra.org/rules-guidance/notices/information-notice-051019) pages of the FINRA website.

Short Interest data reported by FINRA is not yet available on our platform.

On TradingView, Short Sale ​Volume data is accessible through tickers using special names. For example, NASDAQ:AAPL's Short Sale ​Volume data can be loaded on your chart via the FINRA:AAPL_SHORT_VOLUME ticker. The indicator displays the name of the ticker used to fetch data in the bottom left. It can be hidden by unchecking the "Tables" item in the "Style" tab of the script's settings.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("FINRA Daily Short Sale Volume", "FINRA SVol", format = format.volume)

// FINRA Daily Short Sale Volume
// v2, 2026.04.14

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/


// Tooltips
string OS_TT = (
    "If enabled and not empty, the indicator requests FINRA Short Sale Volume data using " 
    + "the specified symbol. Otherwise, it requests data using the chart's symbol."
)

// Inputs
bool   overwriteSymbolInput = input.bool(false, "Other symbol", inline = "OS", group = "Short Volume")
string tickerInput          = input.symbol("",  "",             inline = "OS", group = "Short Volume", tooltip = OS_TT, active = overwriteSymbolInput)
int    maLengthInput        = input.int(20,     "Length",       group  = "Moving Average", minval = 2, maxval = 4999)


// @variable The symbol of the instrument for which to request Short Sale Volume data.
string userSymbol = overwriteSymbolInput and tickerInput != "" ? tickerInput : syminfo.tickerid
// @variable The ticker ID for the Short Sale Volume request.
string shortVolumeTicker = str.format("FINRA:{0}_SHORT_VOLUME", syminfo.ticker(userSymbol))

// Request the EOD FINRA Short Sale Volume value and its moving average.
[shortVolume, shortVolumeMa] = request.security(
    shortVolumeTicker, timeframe.isintraday ? "1D" : timeframe.period, 
    [close, ta.sma(close, maLengthInput)], ignore_invalid_symbol = true
)

// @variable References an array of supported exchange prefixes.
var array<string> validPrefixes = array.from("BATS", "NASDAQ", "NYSE", "AMEX")
// Raise an error if the symbol's exchange prefix is not supported.
if not array.includes(validPrefixes, syminfo.prefix(userSymbol))
    runtime.error(
        str.format(
            "Short sale volume data is not available for instruments referenced by symbols with the ''{0}'' " + 
            "exchange prefix. Supported prefixes are: ''NASDAQ'', ''NYSE'', ''AMEX'', ''BATS''.", 
            syminfo.prefix(userSymbol)
        )
    )

// Raise an error if Short Sale Volume data is not available for the instrument.
if barstate.islastconfirmedhistory and na(shortVolume)
    runtime.error(str.format("No Short Volume data found for the ''{0}'' symbol.", userSymbol))

// Create a table to display the ticker ID of the request on the first bar.
if barstate.isfirst
    var table symbolTable = table.new(position.bottom_right, 1, 1, bgcolor = color.new(color.gray, 0))
    table.cell(
        symbolTable, 0, 0, text = userSymbol + " Short Sale Volume data: " + shortVolumeTicker, 
        text_color = color.white, text_size = size.small
    )

// @variable The color of the columns. Uses different transparency based on the short volume relative to its MA.
color shortVolumeColor = shortVolume > shortVolumeMa ? color.new(color.red, 20) : color.new(color.red, 60)
// Plot the Short Sale Volume values as color-coded columns, and the moving average as a line. 
plot(shortVolume, "Daily Short Sale Volume", shortVolumeColor, 1, plot.style_columns)
plot(shortVolumeMa, "Volume MA", color.gray)
````
