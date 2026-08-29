<!-- tradingview-pine-id: PUB;a4e34cf7e17d45beb9019b578af8b515 -->
<!-- tradingviewscripts-format: 1 -->
# LibraryCOT

Source: https://www.tradingview.com/script/ysFf2OTq-LibraryCOT/

## Description

█ OVERVIEW

This library is a Pine programmer's tool that provides functions to access Commitment of Traders (​COT) data for futures. Four of our scripts use it:
 • [Commitment of Traders: Legacy Metrics](https://www.tradingview.com/script/195p3YlK-Commitment-of-Traders-Legacy-Metrics/)
 • [Commitment of Traders: Disaggregated Metrics](https://www.tradingview.com/script/QmIAaONl-Commitment-of-Traders-Disaggregated-Metrics/)
 • [Commitment of Traders: Financial Metrics](https://www.tradingview.com/script/9wP2dU52-Commitment-of-Traders-Financial-Metrics/)
 • [Commitment of Traders: Total](https://www.tradingview.com/script/CQBbeOHQ-Commitment-of-Traders-Total/)

If you do not program in Pine and want to use ​COT data, please see the indicators linked above.

█ CONCEPTS

[Commitment of Traders ​(​COT) data](https://www.cftc.gov/MarketReports/CommitmentsofTraders/index.htm) is tallied by the [Commodity ​Futures Trading Commission (CFTC)](https://www.cftc.gov/), a US federal agency that oversees the trading of derivative markets such as futures in the US. It is weekly data that provides traders with information about [open interest](https://www.investopedia.com/terms/o/openinterest.asp) for an asset. The CFTC oversees derivative markets traded on different exchanges, so ​COT data is available for assets that can be traded on CBOT, ​CME, NYMEX, COMEX, and ICEUS.

Accessing ​COT data from a Pine script requires the generation of a ticker ID string for use with [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security). The ticker string must be encoded in a special format that includes both CFTC and TradingView-specific content. The format of the ticker IDs is somewhat complex; this library's functions make their generation easier. Note that if you know the ​COT ticker ID string for specific data, you can enter it from the chart's "Symbol Search" dialog box.

A ticker for ​COT data in Pine has the following structure:
[pine]COT<COTType>:<CFTCCode>_<indludeOptions>_<metricCode><_metricDirection><_metricType>[/pine]
where an underscore prefixing a component name inside <> is only included if the component is not a null string, and:
  <COTType>
    Is a digit representing the type of the COT report the data comes from: "" for legacy COT data, "2" for disaggregated data and "3" for financial data.
  <CFTCCode>
    Is a six digit code that represents a commodity. Example: wheat futures (root "ZW") have the code "001602".
  <includeOptions>
    Is either "F" if the report data should exclude Options data, or "FO" if such data is included.
  <metricCode>
    Is the TradingView code of the metric. This library's `metricNameAndDirectionToTicker()` function creates both 
    the <metricCode> and <metricDirection> components of a ​COT ticker from the metric names and directions listed in the above chart.
    The different metrics are explained in the CFTC's [Explanatory Notes](https://www.cftc.gov/MarketReports/CommitmentsofTraders/ExplanatoryNotes/index.htm).
  <metricDirection>
    Is the direction of the metric: "Long", "Short", "Spreading" or "No direction". 
    Not all directions are applicable to all metrics. The valid ones are listed next to each metric in the above chart.
  <metricType>
    Is the type of the metric, possible values are "All", "Old" and "Other". 
    The difference between the types is explained in the "Old and Other Futures" section of the CFTC's [Explanatory Notes](https://www.cftc.gov/MarketReports/CommitmentsofTraders/ExplanatoryNotes/index.htm).

As an example, the Legacy report Open Interest data for ZW futures (options included) in the old standard has the ticker "COT:001602_FO_OI_OLD". The same data using the current standard without futures has the ticker "COT:001602_F_OI".

█ USING THE LIBRARY

The first functions in the library are helper functions that generate components of a ​COT ticker ID. The last function, `COTTickerid()`, is the one that generates the full ticker ID string by calling some of the helper functions. We use it like this in our example:
[pine]exampleTicker = COTTickerid(
                     COTType = "Legacy",
                     CFTCCode = convertRootToCOTCode("Auto"),
                     includeOptions = false, 
                     metricName = "Open Interest",
                     metricDirection = "No direction",
                     metricType = "All")
[/pine]

This library's chart displays the valid values for the `metricName` and `metricDirection` arguments. They vary for each of the three types of ​COT data (the `COTType` argument). The chart also displays the ​COT ticker ID string in the `exampleTicker` variable.

[Look first. Then leap.](https://www.tradingview.com/athletes/) 

The library's functions are:

rootToCFTCCode(root) 
  Accepts a futures root and returns the relevant CFTC code.
  Parameters:
    root: Root prefix of the future's symbol, e.g. "ZC" for "ZC1!"" or "ZCU2021".
  Returns: The <CFTCCode> part of a COT ticker corresponding to `root`, or "" if no CFTC code exists for the `root`.

currencyToCFTCCode(curr) 
  Converts a currency string to its corresponding CFTC code.
  Parameters:
    curr: Currency code, e.g., "USD" for US Dollar.
  Returns: The <CFTCCode> corresponding to the currency, if one exists.

optionsToTicker(includeOptions) 
  Returns the <includeOptions> part of a COT ticker using the `includeOptions` value supplied, which determines whether options data is to be included.
  Parameters:
    includeOptions: A "bool" value: 'true' if the symbol should include options and 'false' otherwise.
  Returns: The <includeOptions> part of a COT ticker: "FO" for data that includes options and "F" for data that doesn't.

metricNameAndDirectionToTicker(metricName, metricDirection) 
  Returns a string corresponding to a metric name and direction, which is one component required to build a valid COT ticker ID.
  Parameters:
    metricName: One of the metric names listed in this library's chart. Invalid values will cause a runtime error.
    metricDirection: Metric direction. Possible values are: "Long", "Short", "Spreading", and "No direction".
      Valid values vary with metrics. Invalid values will cause a runtime error.
  Returns: The <metricCode><metricDirection> part of a COT ticker ID string, e.g., "OI_OLD" for "Open Interest" and "No direction", 
    or "TC_L" for "Traders Commercial" and "Long".

typeToTicker(metricType) 
  Converts a metric type into one component required to build a valid COT ticker ID. 
  See the "Old and Other Futures" section of the CFTC's Explanatory Notes for details on types.
  Parameters:
    metricType: Metric type. Accepted values are: "All", "Old", "Other".
  Returns: The <metricType> part of a COT ticker.

convertRootToCOTCode(mode, convertToCOT) 
  Depending on the `mode`, returns a CFTC code using the chart's symbol or its currency information when `convertToCOT = true`. 
  Otherwise, returns the symbol's root or currency information. If no COT data exists, a runtime error is generated.
  Parameters:
    mode: A string determining how the function will work. Valid values are:
      "Root": the function extracts the futures symbol root (e.g. "ES" in "ESH2020") and looks for its CFTC code.
      "Base currency": the function extracts the first currency in a pair (e.g. "EUR" in "EURUSD") and looks for its CFTC code.
      "Currency": the function extracts the quote currency ("JPY" for "TSE:9984" or "USDJPY") and looks for its CFTC code.
      "Auto": the function tries the first three modes (Root -> Base Currency -> Currency) until a match is found.
    convertToCOT: "bool" value that, when `true`, causes the function to return a CFTC code. 
      Otherwise, the root or currency information is returned. Optional. The default is `true`.
  Returns: If `convertToCOT` is `true`, the <CFTCCode> part of a COT ticker ID string. 
    If `convertToCOT` is `false`, the root or currency extracted from the current symbol.

COTTickerid(COTType, CTFCCode, includeOptions, metricName, metricDirection, metricType) 
  Returns a valid TradingView ticker for the COT symbol with specified parameters.
  Parameters:
    COTType: A string with the type of the report requested with the ticker, one of the following: "Legacy", "Disaggregated", "Financial".
    CTFCCode: The <CFTCCode> for the asset, e.g., wheat futures (root "ZW") have the code "001602".
    includeOptions: A boolean value. 'true' if the symbol should include options and 'false' otherwise.
    metricName: One of the metric names listed in this library's chart.
    metricDirection: Direction of the metric, one of the following: "Long", "Short", "Spreading", "No direction". 
    metricType: Type of the metric. Possible values: "All", "Old", and "Other".
  Returns: A ticker ID string usable with `request.security()` to fetch the specified Commitment of Traders data.

█ AVAILABLE METRICS

Different COT types provide different metrics. The table of all metrics available for each of the types can be found below.

[pine]
+------------------------------+------------------------+
|  Legacy (​COT) Metric Names   |       Directions       |
+------------------------------+------------------------+
| Open Interest                | No direction           |
| Noncommercial Positions      | Long, Short, Spreading |
| Commercial Positions         | Long, Short            |
| Total Reportable Positions   | Long, Short            |
| Nonreportable Positions      | Long, Short            |
| Traders Total                | No direction           |
| Traders Noncommercial        | Long, Short, Spreading |
| Traders Commercial           | Long, Short            |
| Traders Total Reportable     | Long, Short            |
| Concentration Gross ​LT 4 TDR | Long, Short            |
| Concentration Gross ​LT 8 TDR | Long, Short            |
| Concentration Net ​LT 4 TDR   | Long, Short            |
| Concentration Net ​LT 8 TDR   | Long, Short            |
+------------------------------+------------------------+

+-----------------------------------+------------------------+
| Disaggregated (COT2) Metric Names |       Directions       |
+-----------------------------------+------------------------+
| Open Interest                     | No Direction           |
| Producer Merchant Positions       | Long, Short            |
| Swap Positions                    | Long, Short, Spreading |
| Managed Money Positions           | Long, Short, Spreading |
| Other Reportable Positions        | Long, Short, Spreading |
| Total Reportable Positions        | Long, Short            |
| Nonreportable Positions           | Long, Short            |
| Traders Total                     | No Direction           |
| Traders Producer Merchant         | Long, Short            |
| Traders Swap                      | Long, Short, Spreading |
| Traders Managed Money             | Long, Short, Spreading |
| Traders Other Reportable          | Long, Short, Spreading |
| Traders Total Reportable          | Long, Short            |
| Concentration Gross LE 4 TDR      | Long, Short            |
| Concentration Gross LE 8 TDR      | Long, Short            |
| Concentration Net LE 4 TDR        | Long, Short            |
| Concentration Net LE 8 TDR        | Long, Short            |
+-----------------------------------+------------------------+

+-------------------------------+------------------------+
| Financial (COT3) Metric Names |       Directions       |
+-------------------------------+------------------------+
| Open Interest                 | No Direction           |
| Dealer Positions              | Long, Short, Spreading |
| Asset Manager Positions       | Long, Short, Spreading |
| Leveraged Funds Positions     | Long, Short, Spreading |
| Other Reportable Positions    | Long, Short, Spreading |
| Total Reportable Positions    | Long, Short            |
| Nonreportable Positions       | Long, Short            |
| Traders Total                 | No Direction           |
| Traders Dealer                | Long, Short, Spreading |
| Traders Asset Manager         | Long, Short, Spreading |
| Traders Leveraged Funds       | Long, Short, Spreading |
| Traders Other Reportable      | Long, Short, Spreading |
| Traders Total Reportable      | Long, Short            |
| Concentration Gross LE 4 TDR  | Long, Short            |
| Concentration Gross LE 8 TDR  | Long, Short            |
| Concentration Net LE 4 TDR    | Long, Short            |
| Concentration Net LE 8 TDR    | Long, Short            |
+-------------------------------+------------------------+

[/pine]

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
library("LibraryCOT")

// LibraryCOT Library
// v6, 2026.03.26

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



//#region ———————————————————— Metric names and valid directions


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

// +-----------------------------------+------------------------+
// | Disaggregated (COT2) Metric Names |       Directions       |
// +-----------------------------------+------------------------+
// | Open Interest                     | No direction           |
// | Producer Merchant Positions       | Long, Short            |
// | Swap Positions                    | Long, Short, Spreading |
// | Managed Money Positions           | Long, Short, Spreading |
// | Other Reportable Positions        | Long, Short, Spreading |
// | Total Reportable Positions        | Long, Short            |
// | Nonreportable Positions           | Long, Short            |
// | Traders Total                     | No direction           |
// | Traders Producer Merchant         | Long, Short            |
// | Traders Swap                      | Long, Short, Spreading |
// | Traders Managed Money             | Long, Short, Spreading |
// | Traders Other Reportable          | Long, Short, Spreading |
// | Traders Total Reportable          | Long, Short            |
// | Concentration Gross LE 4 TDR      | Long, Short            |
// | Concentration Gross LE 8 TDR      | Long, Short            |
// | Concentration Net LE 4 TDR        | Long, Short            |
// | Concentration Net LE 8 TDR        | Long, Short            |
// +-----------------------------------+------------------------+

// +-----------------------------------+------------------------+
// | Financial (COT3) Metric Names     |       Directions       |
// +-----------------------------------+------------------------+
// | Open Interest                     | No direction           |
// | Dealer Positions                  | Long, Short, Spreading |
// | Asset Manager Positions           | Long, Short, Spreading |
// | Leveraged Funds Positions         | Long, Short, Spreading |
// | Other Reportable Positions        | Long, Short, Spreading |
// | Total Reportable Positions        | Long, Short            |
// | Nonreportable Positions           | Long, Short            |
// | Traders Total                     | No direction           |
// | Traders Dealer                    | Long, Short, Spreading |
// | Traders Asset Manager             | Long, Short, Spreading |
// | Traders Leveraged Funds           | Long, Short, Spreading |
// | Traders Other Reportable          | Long, Short, Spreading |
// | Traders Total Reportable          | Long, Short            |
// | Concentration Gross LE 4 TDR      | Long, Short            |
// | Concentration Gross LE 8 TDR      | Long, Short            |
// | Concentration Net LE 4 TDR        | Long, Short            |
// | Concentration Net LE 8 TDR        | Long, Short            |
// +-----------------------------------+------------------------+
//#endregion



//#region ———————————————————— Library functions


// @function                Returns the part of the COT ticker ID that specifies whether the report includes options
//                          data.
// @param includeOptions    (bool) `true` to specify that the data should include options and futures information, 
//                          and `false` to specify futures only.
// @returns                 (string) The <includeOptions> part of a COT ticker ID: `"FO"` specifies data that includes
//                          options and futures information, and `"F"` specifies data that includes futures only.
optionsToTicker(bool includeOptions) =>
    includeOptions ? "FO" : "F"


// @function                Constructs a string representing the metric name and direction parts of a COT ticker ID.
// @param metricName        (string) One of the valid metric names listed in the library's documentation and source code.
// @param metricDirection   (string) Metric direction. Possible values are: `"Long"`, `"Short"`, `"Spreading"`, and
//                          `"No direction"`.
// @returns                 (string) The <metricCode><metricDirection> portion of a COT ticker ID, e.g., `"OI"` for
//                          `"Open Interest"` and `"No direction"`, or `"TC_L"` for `"Traders Commercial"` and `"Long"`.
metricNameAndDirectionToTicker(string metricName, string metricDirection) =>
    string metricCode = switch metricName
        "Asset Manager Positions"      => "AMP"
        "Commercial Positions"         => "CP"
        "Concentration Gross LE 4 TDR" => "CON_GROSS_LE_4"
        "Concentration Gross LE 8 TDR" => "CON_GROSS_LE_8"
        "Concentration Gross LT 4 TDR" => "CON_GROSS_LT_4"
        "Concentration Gross LT 8 TDR" => "CON_GROSS_LT_8"
        "Concentration Net LE 4 TDR"   => "CON_NET_LE_4"
        "Concentration Net LE 8 TDR"   => "CON_NET_LE_8"
        "Concentration Net LT 4 TDR"   => "CON_NET_LT_4"
        "Concentration Net LT 8 TDR"   => "CON_NET_LT_8"
        "Dealer Positions"             => "DP"
        "Leveraged Funds Positions"    => "LMP"
        "Managed Money Positions"      => "MMP"
        "Noncommercial Positions"      => "NCP"
        "Nonreportable Positions"      => "NRP"
        "Open Interest"                => "OI"
        "Other Reportable Positions"   => "ORP"
        "Producer Merchant Positions"  => "PMR"
        "Swap Positions"               => "SP"
        "Total Reportable Positions"   => "TRP"
        "Traders Asset Manager"        => "TAM"
        "Traders Commercial"           => "TC"
        "Traders Dealer"               => "TD"
        "Traders Leveraged Funds"      => "TLM"
        "Traders Managed Money"        => "TMM"
        "Traders Noncommercial"        => "TNC"
        "Traders Other Reportable"     => "TOR"
        "Traders Producer Merchant"    => "TPM"
        "Traders Swap"                 => "TS"
        "Traders Total"                => "TT"
        "Traders Total Reportable"     => "TTR"
        => runtime.error(
            str.format(
                "Invalid metric name: ''{0}''. See the library''s documentation or source code for all valid "
                + "metric names.", metricName
            )
        ), na
    string directionCode = switch metricDirection
        "Long"         => "_L"
        "Short"        => "_S"
        "Spreading"    => "_SPREAD"
        "No direction" => ""
        => runtime.error(
            str.format(
                "''{0}'' is not a valid `metricDirection` argument. Possible values: "
                + "''Long'', ''Short'', ''Spreading'', ''No direction''", metricDirection
            )
        ), na
    if metricDirection == "No direction"
        if metricName != "Open Interest" and metricName != "Traders Total"
            runtime.error(
                str.format(
                    "''{0}'' does not apply to the ''{1}'' metric.", metricDirection, metricName
                )
            )
    else if metricDirection == "Spreading"
        isIncorrect = switch metricName
            "Commercial Positions"         => true
            "Total Reportable Positions"   => true
            "Nonreportable Positions"      => true
            "Traders Commercial"           => true
            "Traders Total Reportable"     => true
            "Concentration Gross LT 4 TDR" => true
            "Concentration Gross LT 8 TDR" => true
            "Concentration Net LT 4 TDR"   => true
            "Concentration Net LT 8 TDR"   => true
            "Concentration Gross LE 4 TDR" => true
            "Concentration Gross LE 8 TDR" => true
            "Concentration Net LE 4 TDR"   => true
            "Concentration Net LE 8 TDR"   => true
            "Producer Merchant Positions"  => true
            "Traders Producer Merchant"    => true
            => false
        if isIncorrect
            runtime.error(
                str.format(
                    "The ''{0}'' direction does not apply to the ''{1}'' metric.", metricDirection, metricName
                )
            )
    else if metricName == "Open Interest" or metricName == "Traders Total"
        runtime.error(
            str.format(
                "The ''{0}'' direction does not apply to the ''{1}'' metric.", metricDirection, metricName
            )
        )
    metricCode + directionCode


// @function                Converts a specified metric type into a required COT ticker ID component.
//                          See the "Old and Other Futures" section of the CFTC's Explanatory Notes for details on
//                          metric types.
// @param metricType        (string) The metric type. Possible values are: `"All"`, `"Old"`, `"Other"`.
// @returns                 (string) The <metricType> part of a COT ticker ID.
typeToTicker(string metricType) =>
    string result = switch metricType
        "All"   => ""
        "Old"   => "_OLD"
        "Other" => "_OTHER"
        => runtime.error(
            str.format(
                "''{0}'' is not a valid `metricType` argument. Possible values: ''All'', ''Old'', ''Other''", metricType
            )
        ), na


// @function                Retrieves a string containing the Commodity Futures Trading Commission (CFTC) code for the
//                          futures instrument referenced by the specified symbol. Scripts can use this function's
//                          result as the `CFTCCode` argument in calls to this library's `COTTickerid()` and
//                          `requestCommitmentOfTraders()` functions.
//                          Calls to this function count toward a script's `request.*()` call limit.
// @param symbol            (string) The symbol or ticker ID of the futures instrument for which to retrieve the CFTC
//                          code. If the value is an empty string, the function retrieves the code for the instrument
//                          referenced by the chart's symbol.
// @returns                 (string) A string representing a CFTC code if one is associated with the symbol. 
//                          If the symbol is unsupported or no valid CFTC code is available, the function raises a
//                          runtime error.
export getCFTCCode(string symbol) =>
    // This logic relies on the variable `syminfo.cftc_code`, which automatically stores an available CFTC code.
    // This variable is usable in scripts, but is not shown in the manual because its use cases outside this library's
    // purpose are extremely limited.
    string result = switch
        symbol == "" => syminfo.cftc_code
        => request.security(symbol, "", syminfo.cftc_code, ignore_invalid_symbol = true)
    if na(result)
        runtime.error(
            str.format(
                "Unsupported symbol: ''{0}''. Use the symbol for a futures instrument that has a valid CFTC code.",
                ticker.standard(symbol == "" ? syminfo.tickerid : symbol)
            )
        )
    result


// @function                Creates a valid ticker ID representing a CFTC Commitment of Traders (COT) symbol with
//                          specified parameters.
// @param COTType           (string) Specifies the report type that the symbol represents. Possible values are:
//                          `"Legacy"`, `"Disaggregated"`, `"Financial"`.
// @param CFTCCode          (string) The CFTC code for the futures instrument. For example, wheat futures (root "ZW")
//                          have the code `"001602"`. Use this library's `getCFTCCode()` function to retrieve the code
//                          for the instrument referenced by a specific symbol.
// @param includeOptions    (bool) If `true`, the COT symbol specifies futures and options information. Otherwise, it
//                          specifies futures only.
// @param metricName        (string) One of the valid metric names listed in the library's documentation and source code.
// @param metricDirection   (string) Metric direction. Possible values are: `"Long"`, `"Short"`, `"Spreading"`, and
//                          `"No direction"`. Consult this library's documentation or code to see which direction values
//                          apply to the specified metric.
// @param metricType        (string) The metric type. Possible values are: `"All"`, `"Old"`, `"Other"`.
// @returns                 (string) A COT ticker identifier, which `request.security()` calls can use to request
//                          Commitment of Traders data.
export COTTickerid(
    string COTType, string CFTCCode, bool includeOptions, string metricName, string metricDirection, string metricType
) =>
	if na(CFTCCode)
		runtime.error("The specified CFTC code cannot be an empty string or `na`.")
    string typeCode = switch COTType
        "Legacy"        => ""
        "Disaggregated" => "2"
        "Financial"     => "3"
        => runtime.error(
            str.format(
                "''{0}'' is not a valid `COTType` argument. Possible values: "
                + "''Legacy'', ''Disaggregated'', ''Financial''", COTType
            )
        ), na
    bool invalidType = if COTType == "Legacy"
        switch metricName
            "Open Interest"                 => false
            "Noncommercial Positions"       => false
            "Commercial Positions"          => false
            "Total Reportable Positions"    => false
            "Nonreportable Positions"       => false
            "Traders Total"                 => false
            "Traders Noncommercial"         => false
            "Traders Commercial"            => false
            "Traders Total Reportable"      => false
            "Concentration Gross LT 4 TDR"  => false
            "Concentration Gross LT 8 TDR"  => false
            "Concentration Net LT 4 TDR"    => false
            "Concentration Net LT 8 TDR"    => false
            => true
    else if COTType == "Disaggregated"
        switch metricName
            "Open Interest"                 => false
            "Producer Merchant Positions"   => false
            "Swap Positions"                => false
            "Managed Money Positions"       => false
            "Other Reportable Positions"    => false
            "Total Reportable Positions"    => false
            "Nonreportable Positions"       => false
            "Traders Total"                 => false
            "Traders Producer Merchant"     => false
            "Traders Swap"                  => false
            "Traders Managed Money"         => false
            "Traders Other Reportable"      => false
            "Traders Total Reportable"      => false
            "Concentration Gross LE 4 TDR"  => false
            "Concentration Gross LE 8 TDR"  => false
            "Concentration Net LE 4 TDR"    => false
            "Concentration Net LE 8 TDR"    => false
            => true
    else if COTType == "Financial"
        switch metricName
            "Open Interest"                 => false
            "Dealer Positions"              => false
            "Asset Manager Positions"       => false
            "Leveraged Funds Positions"     => false
            "Other Reportable Positions"    => false
            "Total Reportable Positions"    => false
            "Nonreportable Positions"       => false
            "Traders Total"                 => false
            "Traders Dealer"                => false
            "Traders Asset Manager"         => false
            "Traders Leveraged Funds"       => false
            "Traders Other Reportable"      => false
            "Traders Total Reportable"      => false
            "Concentration Gross LE 4 TDR"  => false
            "Concentration Gross LE 8 TDR"  => false
            "Concentration Net LE 4 TDR"    => false
            "Concentration Net LE 8 TDR"    => false
            => true
    if invalidType
        runtime.error(
            str.format(
                "''{0}'' is not a valid {1} COT metric. See the libary''s documentation or code for all valid {1} "
                + "metric names.", metricName, COTType
            )
        )
    string result = str.format(
        "COT{0}:{1}_{2}_{3}{4}", typeCode, CFTCCode, optionsToTicker(includeOptions),
        metricNameAndDirectionToTicker(metricName, metricDirection), typeToTicker(metricType)
    )


// @function                Requests CFTC Commitment of Traders (COT) data with specified parameters.
//                          Calls to this function count toward a script's `request.*()` call limit.
// @param COTType           (string) The type of report to request. Possible values are:
//                          `"Legacy"`, `"Disaggregated"`, `"Financial"`.
// @param CFTCCode          (string) The CFTC code for the futures instrument. For example, wheat futures (root "ZW")
//                          have the code `"001602"`. Use this library's `getCFTCCode()` function to retrieve the code
//                          for the instrument referenced by a specific symbol.
// @param includeOptions    (bool) If `true`, the COT request includes options information. Otherwise, it includes only
//                          futures.
// @param metricName        (string) One of the valid metric names listed in the library's documentation and source code.
// @param metricDirection   (string) Metric direction. Possible values are: `"Long"`, `"Short"`, `"Spreading"`, and
//                          `"No direction"`. Consult the library's documentation or code to see which direction values
//                          apply to the specified metric.
// @param metricType        (string) The metric type. Possible values are: `"All"`, `"Old"`, `"Other"`.
// @returns                 (float) The specified Commitment of Traders data series. If no data is available,
//                          the function raises a runtime error.
export requestCommitmentOfTraders(
    string COTType, string CFTCCode, bool includeOptions, string metricName, string metricDirection, string metricType
) =>
    string t    = COTTickerid(COTType, CFTCCode, includeOptions, metricName, metricDirection, metricType)
    string tf   = timeframe.isdwm ? timeframe.period : "1D"
    float  data = request.security(t, tf, close, ignore_invalid_symbol = true)
    if ta.cum(nz(data)) == 0 and barstate.islastconfirmedhistory
        runtime.error(
            str.format(
                "The requested {0} COT metric is not available for the CFTC code ''{1}''. "
                + "Ensure the COT report type, CFTC code, and other settings represent a valid metric request.",
                COTType, CFTCCode
            )
        )
    data
//#endregion



// ————— Example code


float COTdataseries = requestCommitmentOfTraders(
    COTType         = "Legacy",
    CFTCCode        = getCFTCCode(""),
    includeOptions  = false,
    metricName      = "Open Interest",
    metricDirection = "No direction",
    metricType      = "All"
)

plot(COTdataseries, style = plot.style_stepline_diamond)
````
