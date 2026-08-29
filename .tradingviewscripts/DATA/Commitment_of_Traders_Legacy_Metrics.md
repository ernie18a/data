<!-- tradingview-pine-id: PUB;064fa165fa574f79b1ee770cd55c364c -->
<!-- tradingviewscripts-format: 1 -->
# Commitment of Traders: Legacy Metrics

Source: https://www.tradingview.com/script/195p3YlK-Commitment-of-Traders-Legacy-Metrics/

## Description

█ OVERVIEW

This indicator displays the Commitment of Traders (​COT) legacy data for futures markets.

█ CONCEPTS

[Commitment of Traders ​(​COT) data](https://www.cftc.gov/MarketReports/CommitmentsofTraders/index.htm) is tallied by the [Commodity ​Futures Trading Commission (CFTC)](https://www.cftc.gov/), a US federal agency that oversees the trading of derivative markets such as futures in the US. It is weekly data that provides traders with information about [open interest](https://www.investopedia.com/terms/o/openinterest.asp) for an asset. The CFTC oversees derivative markets traded on different exchanges, so ​COT data is available for assets that can be traded on CBOT, ​CME, NYMEX, COMEX, and ICEUS.

A detailed description of the COT report can be found on the [CFTC's website](https://www.cftc.gov/MarketReports/CommitmentsofTraders/index.htm).

COT data is separated into three notable reports: Legacy, Disaggregated, and Financial. This indicator presents data from the legacy report, which is broken down by exchange. Legacy reports break down the reportable open interest positions into two classifications: non-commercial and commercial traders.

Our other COT indicators are:
 • [Commitment of Traders: Disaggregated Metrics](https://www.tradingview.com/script/QmIAaONl-Commitment-of-Traders-Disaggregated-Metrics/)
 • [Commitment of Traders: Financial Metrics](https://www.tradingview.com/script/9wP2dU52-Commitment-of-Traders-Financial-Metrics/)
 • [Commitment of Traders: Total](https://www.tradingview.com/script/CQBbeOHQ-Commitment-of-Traders-Total/)

█ HOW TO USE IT

Load the indicator on an active chart (see [here](https://www.tradingview.com/u/?solution=43000555216) if you don't know how).

By default, the indicator uses the chart's symbol to derive the COT data it displays. You can also specify a CFTC code in the "CFTC code" field of the script's inputs to display COT data from a symbol different than the chart's.

The rest of this section documents the script's input fields.

Metric
Each metric represents a different column of the Commitment of Traders report. Details are available in the [explanatory notes on the CFTC's website](https://www.cftc.gov/MarketReports/CommitmentsofTraders/ExplanatoryNotes/index.htm). 
Here is a summary of the metrics:
 • "Open Interest" is the total of all futures and/or option contracts entered into and not yet offset by a transaction, by delivery, by exercise, etc.
  The aggregate of all long open interest is equal to the aggregate of all short open interest.
 • "Traders Total" is the number of all unique reportable traders, regardless of the trading direction.
 • "Traders Total Reportable/Traders Noncommercial/Traders Commercial" are the quantities of traders reported to hold any position with the specified direction. 
  All of a trader's reported futures positions in a commodity are classified as commercial if the trader uses futures contracts in that particular commodity for hedging. 
  To determine the total number of reportable traders in a market, a trader is counted only once, whether or not the trader appears in more than one category.
 • "Total Reportable/Noncommercial/Commercial Positions" are all positions held by all reportable/non-commercial/commercial traders.
 • "Non-reportable Positions" is derived by subtracting total long and short "Reportable Positions" from the total open interest. 
  Accordingly, the number of traders involved and the commercial/non-commercial classification of each trader are unknown.
 • "Concentration Gross/Net LT 4/8 TDR" is the percentage of open interest held by 4/8 of the largest traders, by gross/net positions, 
  without regard to whether they are classified as commercial or non-commercial. The Net position ratios are computed after offsetting each trader’s equal long and short positions. 
  A reportable trader with relatively large, balanced long and short positions in a single market, therefore, 
  may be among the four and eight largest traders in both the gross long and gross short categories, but will probably not be included among the four and eight largest traders on a net basis.

Direction
Each metric is available for a particular set of directions. Valid directions for each metric are specified with its name in the "Metric" field's dropdown menu.

Type
Possible values are: All, Old, Other. When commodities have a well-defined marketing season or crop year (e.g. Wheat or Lean Hogs futures), this determines how the data is aggregated. Detailed explanation can be found in the "Old and Other Futures" section of the CTFC Explanatory Notes linked above. The "Major Markets for Which the COT Data Is Shown by Crop Year" table in the Explanatory Notes specifies the commodities that this distinction applies to; selecting "Old" for any of the commodities not in that list will return the same data as in "All", while selecting "Other" will return 0.

COT Selection Mode
This field's value determines how the script determines which COT data to return from the chart's symbol:
- "Root" uses the root of a futures symbol ("ES" for "ESH2020").
- "Base currency" uses the base currency in a forex pair ("EUR" for "EURUSD").
- "Currency" uses the quote currency, i.e., the currency the symbol is traded in ("JPY" for "TSE:9984" or "USDJPY").
- "Auto" tries all modes, in turn.
If no COT data can be found, a runtime error is generated.
Note that if the "CTFC Code" input field contains a code, it will override this input.

Futures/Options
Specifies the type of Commitment of Traders data to display: data concerning only Futures, only Options, or both.

CTFC Code
Instead of letting the script generate the CFTC COT code from the chart and the "COT Selection Mode" input when this field is empty, you can specify an unrelated CFTC COT code here, e.g., 001602 for wheat futures.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("Commitment of Traders: Legacy Metrics", "COT Legacy", format = format.volume)

// "Commitment of Traders: Legacy Metrics"
// v6, 2026.03.26

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



// +-----------------------------------+------------------------+
// |  Legacy (COT) Metric Names        |       Directions       |
// +-----------------------------------+------------------------+
// | Open Interest                     | No direction           |
// | Noncommercial Positions           | Long, Short, Spreading |
// | Commercial Positions              | Long, Short            |
// | Total Reportable Positions        | Long, Short            |
// | Nonreportable Positions           | Long, Short            |
// | Traders Total                     | No direction           |
// | Traders Noncommercial             | Long, Short, Spreading |
// | Traders Commercial                | Long, Short            |
// | Traders Total Reportable          | Long, Short            |
// | Concentration Gross LT 4 TDR      | Long, Short            |
// | Concentration Gross LT 8 TDR      | Long, Short            |
// | Concentration Net LT 4 TDR        | Long, Short            |
// | Concentration Net LT 8 TDR        | Long, Short            |
// +-----------------------------------+------------------------+



import TradingView/LibraryCOT/6 as cot



//#region ———————————————————— Constants and inputs


// Allowed directions
string ND  = " [ND]"
string LS  = " [L|Sh]"
string LSS = " [L|Sh|Sp]"

// Metric information types
string IO01 = "Futures"
string IO02 = "Options"
string IO03 = "Futures + Options"

// CFTC code selection
string US01 = "Symbol"
string US02 = "Custom CFTC code"

// Metric names
string MB01 = "Open Interest"
string MB02 = "Noncommercial Positions"
string MB03 = "Commercial Positions"
string MB04 = "Total Reportable Positions"
string MB05 = "Nonreportable Positions"
string MB06 = "Traders Total"
string MB07 = "Traders Noncommercial"
string MB08 = "Traders Commercial"
string MB09 = "Traders Total Reportable"
string MB10 = "Concentration Gross LT 4 TDR"
string MB11 = "Concentration Gross LT 8 TDR"
string MB12 = "Concentration Net LT 4 TDR"
string MB13 = "Concentration Net LT 8 TDR"

// "Metric" input options
string M01 = MB01 + ND
string M02 = MB02 + LSS
string M03 = MB03 + LS
string M04 = MB04 + LS
string M05 = MB05 + LS
string M06 = MB06 + ND
string M07 = MB07 + LSS
string M08 = MB08 + LS
string M09 = MB09 + LS
string M10 = MB10 + LS
string M11 = MB11 + LS
string M12 = MB12 + LS
string M13 = MB13 + LS

// Tooltips
string TT_METRIC = (
    "Specifies the metric to request, and indicates the available directions in square brackets:\n"
    + " [ND] 🠆 No direction\n [L] 🠆 Long\n [Sh] 🠆 Short\n [Sp] 🠆 Spreading"
)
string TT_DIR = (
    "Specifies the direction for the metric. "
    + "The items in the dropdown menu above show which direction options apply to each metric."
)
string TT_TYPE = (
    "Specifies the metric's type. "
    + "See the 'Old and Other Futures' section of the CFTC's Explanatory Notes for details on types."
)
string TT_OPTIONS = "Determines whether the data includes information for futures, options, or both."
string TT_SYMBOL = (
      "If the selected 'CFTC source' option is 'Symbol', this field specifies the futures instrument for which to "
      + "request COT data. If not empty, the indicator retrieves data using the CFTC code for the instrument referenced "
      + "by the specified symbol. Otherwise, it uses the code for the instrument referenced by the chart's symbol."
)
string TT_OVERRIDE = (
      "If the selected 'CFTC source' option is 'Custom CFTC code' and this field is not empty, the indicator retrieves "
      + "COT data using the specified CFTC code. If the field is empty, it retrieves data using the CFTC code " 
      + "for the instrument referenced by the chart's symbol."
)

// Inputs
string metricNameInput      = input.string(M01,            "Metric",          options = [M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, M13], tooltip = TT_METRIC)
string metricDirectionInput = input.string("No direction", "Direction",       options = ["No direction", "Long", "Short", "Spreading"], tooltip = TT_DIR)
string metricTypeInput      = input.string("All",          "Type",            options = ["All", "Old", "Other"], tooltip = TT_TYPE)
string includeOptionsInput  = input.string(IO01,           "Futures/Options", options = [IO01, IO02, IO03], tooltip = TT_OPTIONS)
bool   useSymbolInput       = input.string(US01,           "CFTC source",     options = [US01, US02]) == US01
string userCFTCSymInput     = input.symbol("",             "Symbol",          tooltip = TT_SYMBOL,   active = useSymbolInput)
string userCFTCCodeInput    = input.string("",             "CFTC code",       tooltip = TT_OVERRIDE, active = not useSymbolInput)
//#endregion



//#region ———————————————————— Calculations


// @variable A string containing the CFTC code for the COT data requests.
var string cftcCode = switch 
    useSymbolInput          => cot.getCFTCCode(userCFTCSymInput)
    userCFTCCodeInput != "" => str.upper(userCFTCCodeInput)
    => cot.getCFTCCode("")

// @variable A string containing the metric name.
var string metricName = str.substring(metricNameInput, 0, str.pos(metricNameInput, "[") - 1)

// @variable The COT ticker ID that specifies futures-only information.
var string futuresOnlyTickerID = cot.COTTickerid(
    "Legacy", cftcCode, false, metricName, metricDirectionInput, metricTypeInput
)
// @variable The COT ticker ID that specifies futures and options information.
var string futuresWithOptionsTickerID = cot.COTTickerid(
    "Legacy", cftcCode, true, metricName, metricDirectionInput, metricTypeInput
)

// @variable The requested Legacy metric for futures data.
float futuresOnly = cot.requestCommitmentOfTraders(
    "Legacy", cftcCode, false, metricName, metricDirectionInput, metricTypeInput
)
// @variable The requested Legacy metric for futures and options data.
float futuresWithOptions = cot.requestCommitmentOfTraders(
    "Legacy", cftcCode, true, metricName, metricDirectionInput, metricTypeInput
)

// @variable COT series for futures, options, or futures and options data, depending on `includeOptionsInput`.
float COTSeries = switch includeOptionsInput
    IO01 => futuresOnly
    IO02 => futuresWithOptions - futuresOnly
    IO03 => futuresWithOptions
    => na
//#endregion



//#region ———————————————————— Display


// Plot `COTSeries` as a step line with diamonds.
plot(COTSeries, "COT", style = plot.style_stepline_diamond)

// @variable References a `table` instance that displays symbol and COT ticker ID information in the bottom-right corner.
var table symbolDisplay = table.new(position.bottom_right, 1, 1)
// Populate the `symbolDisplay` table on the first bar.
if barstate.isfirst
    color TEXT_COLOR = color.white
    color BG_COLOR   = color.new(color.blue, 50)
    int    pos       = str.pos(userCFTCSymInput, ":")
    string ticker    = str.substring(userCFTCSymInput, pos + 1)
    string symbol     = userCFTCSymInput != "" and useSymbolInput ? ticker : syminfo.ticker
    string tickerID  = switch includeOptionsInput
        IO01 => futuresOnlyTickerID
        IO02 => futuresWithOptionsTickerID + "-" + futuresOnlyTickerID
        IO03 => futuresWithOptionsTickerID
    string txt = switch 
        useSymbolInput or userCFTCCodeInput == "" => str.format(
            "COT {0} data for {1}\nCOT ticker ID: {2}", includeOptionsInput, symbol, tickerID
        )
        => str.format("COT {0} data for CFTC code {1}\nCOT ticker ID: {2}", includeOptionsInput, cftcCode, tickerID)
    table.cell(symbolDisplay, 0, 0, txt, text_halign = text.align_left, text_color = TEXT_COLOR, bgcolor = BG_COLOR)
//#endregion
````
