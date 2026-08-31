<!-- tradingview-pine-id: PUB;75ae42130401485abc61282469e0d202 -->
<!-- tradingviewscripts-format: 1 -->
# Correlation Heatmap

Source: https://www.tradingview.com/script/Y3PnzG2q-Correlation-Heatmap/

## Description

█ OVERVIEW

This indicator creates a correlation matrix for a user-specified list of symbols based on their time-aligned weekly or monthly price returns. It calculates the [Pearson correlation coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient) for each possible symbol pair, and it displays the results in a symmetric table with heatmap-colored cells. This format provides an intuitive view of the linear relationships between various symbols' price movements over a specific time range.

█ CONCEPTS

Correlation

Correlation typically refers to an observable statistical relationship between two datasets. In a financial time series context, it usually represents the extent to which sampled values from a pair of datasets, such as two series of price returns, vary jointly over time. More specifically, in this context, correlation describes the strength and direction of the relationship between the samples from both series. 

If two separate time series tend to rise and fall together proportionally, they might be highly correlated. Likewise, if the series often vary in opposite directions, they might have a strong anticorrelation. If the two series do not exhibit a clear relationship, they might be uncorrelated. 

Traders frequently analyze asset correlations to help optimize portfolios, assess market behaviors, identify potential risks, and support trading decisions. For instance, correlation often plays a key role in diversification. When two instruments exhibit a strong correlation in their returns, it might indicate that buying or selling both carries elevated [unsystematic risk](https://en.wikipedia.org/wiki/Idiosyncrasy#Economics). Therefore, traders often aim to create balanced portfolios of relatively uncorrelated or anticorrelated assets to help promote investment diversity and potentially offset some of the risks.

When using correlation analysis to support investment decisions, it is crucial to understand the following caveats:

 • [Correlation does not imply causation](https://en.wikipedia.org/wiki/Correlation_does_not_imply_causation). Two assets might vary jointly over an analyzed range, resulting in high correlation or anticorrelation in their returns, but that does not indicate that either instrument directly influences the other. Joint variability between assets might occur because of shared sensitivities to external factors, such as interest rates or global sentiment, or it might be entirely coincidental. In other words, correlation does not provide sufficient information to identify cause-and-effect relationships. 

 • Correlation does not predict the future relationship between two assets. It only reflects the estimated strength and direction of the relationship between the current analyzed samples. Financial time series are ever-changing. A strong trend between two assets can weaken or reverse in the future. 

Correlation coefficient

A correlation coefficient is a numeric measure of correlation. Several coefficients exist, each quantifying different types of relationships between two datasets. The most common and widely known measure is the [Pearson product-moment correlation coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient), also known as the Pearson correlation coefficient or Pearson's r. Usually, when the term "correlation coefficient" is used without context, it refers to this correlation measure. 

The Pearson correlation coefficient quantifies the strength and direction of the linear relationship between two variables. In other words, it indicates how consistently variables' values move together or in opposite directions in a proportional, linear manner. Its formula is as follows:

𝑟(𝑥, 𝑦) = cov(𝑥, 𝑦) / (𝜎𝑥 * 𝜎𝑦)

Where:

 • 𝑥 is the first variable, and 𝑦 is the second variable.
 • cov(𝑥, 𝑦) is the [covariance](https://en.wikipedia.org/wiki/Covariance) between 𝑥 and 𝑦.
 • 𝜎𝑥 is the [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) of 𝑥.
 • 𝜎𝑦 is the standard deviation of 𝑦.

In essence, the correlation coefficient measures the covariance between two variables, normalized by the product of their standard deviations. The coefficient's value ranges from -1 to 1, allowing a more straightforward interpretation of the relationship between two datasets than what covariance alone provides:

 • A value of 1 indicates a perfect positive correlation over the analyzed sample. As one variable's value changes, the other variable's value changes proportionally in the same direction.
 • A value of -1 indicates a perfect negative correlation (anticorrelation). As one variable's value increases, the other variable's value decreases proportionally. 
 • A value of 0 indicates no linear relationship between the variables over the analyzed sample. 

Aligning returns across instruments

In a financial time series, each data point (i.e., bar) in a sample represents information collected in periodic intervals. For instance, on a "1D" chart, bars form at specific times as successive days elapse. 

However, the times of the data points for a symbol's standard dataset depend on its active sessions, and sessions vary across instrument types. For example, the daily session for NYSE stocks is 09:30 - 16:00 UTC-4/-5 on weekdays, Forex instruments have 24-hour sessions that span from 17:00 UTC-4/-5 on one weekday to 17:00 on the next, and new daily sessions for cryptocurrencies start at 00:00 UTC every day because crypto markets are consistently open. 

Therefore, comparing the standard datasets for different asset types to identify correlations presents a challenge. If two symbols' datasets have bars that form at unaligned times, their correlation coefficient does not accurately describe their relationship. When calculating correlations between the returns for two assets, both datasets must maintain consistent time alignment in their values and cover identical ranges for meaningful results.

To address the issue of time alignment across instruments, this indicator requests confirmed weekly or monthly data from [spread tickers](https://www.tradingview.com/support/solutions/43000502298-spread-charts/) constructed from the chart's ticker and another specified ticker. The datasets for spreads are derived from lower-timeframe data to ensure the values from all symbols come from aligned points in time, allowing a fair comparison between different instrument types. Additionally, each spread ticker ID includes necessary modifiers, such as extended hours and adjustments. 

In this indicator, we use the following process to retrieve time-aligned returns for correlation calculations:

 1. Request the current and previous prices from a spread representing the sum of the chart symbol and another symbol ("chartSymbol + anotherSymbol").
 2. Request the prices from another spread representing the difference between the two symbols ("chartSymbol - anotherSymbol").
 3. Calculate half of the difference between the values from both spreads (0.5 * (requestedSum - requestedDifference)). The results represent the symbol's prices at times aligned with the sample points on the current chart.
 4. Calculate the arithmetic return of the retrieved prices: (currentPrice - previousPrice) / previousPrice
 5. Repeat steps 1-4 for each symbol requiring analysis. 

It's crucial to note that because this process retrieves prices for a symbol at times consistent with periodic points on the current chart, the values can represent prices from before or after the closing time of the symbol's usual session.

Additionally, note that the maximum number of weeks or months in the correlation calculations depends on the chart's range and the largest time range common to all the requested symbols. To maximize the amount of data available for the calculations, we recommend setting the chart to use a daily or higher timeframe and specifying a chart symbol that covers a sufficient time range for your needs.

█ FEATURES

This indicator analyzes the correlations between several pairs of user-specified symbols to provide a structured, intuitive view of the relationships in their returns. Below are the indicator's key features:

Requesting a list of securities

The "Symbol list" text box in the indicator's "Settings/Inputs" tab accepts a comma-separated list of symbols or ticker identifiers with optional spaces (e.g., "XOM, MSFT, BITSTAMP:BTCUSD"). The indicator dynamically requests returns for each symbol in the list, then calculates the correlation between each pair of return series for its heatmap display. 

Each item in the list must represent a valid symbol or ticker ID. If the list includes an invalid symbol, the script raises a runtime error. 

To specify a broker/exchange for a symbol, include its name as a prefix with a colon in the "EXCHANGE:SYMBOL" format. If a symbol in the list does not specify an exchange prefix, the indicator selects the most commonly used exchange when requesting the data.

Note that the number of symbols allowed in the list depends on the user's plan. Users with non-professional plans can compare up to 20 symbols with this indicator, and users with professional plans can compare up to 32 symbols. 

Timeframe and data length selection

The "Returns timeframe" input specifies whether the indicator uses weekly or monthly returns in its calculations. By default, its value is "1M", meaning the indicator analyzes monthly returns. Note that this script requires a chart timeframe lower than or equal to "1M". If the chart uses a higher timeframe, it causes a runtime error.  

To customize the length of the data used in the correlation calculations, use the "Max periods" input. When enabled, the indicator limits the calculation window to the number of periods specified in the input field. Otherwise, it uses the chart's time range as the limit. The top-left corner of the table shows the number of confirmed weeks or months used in the calculations. 

It's important to note that the number of confirmed periods in the correlation calculations is limited to the largest time range common to all the requested datasets, because a meaningful correlation matrix requires analyzing each symbol's returns under the same market conditions. Therefore, the correlation matrix can show different results for the same symbol pair if another listed symbol restricts the aligned data to a shorter time range. 

Heatmap display

This indicator displays the correlations for each symbol pair in a heatmap-styled table representing a symmetric correlation matrix. Each row and column corresponds to a specific symbol, and the cells at their intersections correspond to symbol pairs. For example, the cell at the "AAPL" row and "MSFT" column shows the weekly or monthly correlation between those two symbols' returns. Likewise, the cell at the "MSFT" row and "AAPL" column shows the same value. 

Note that the main diagonal cells in the display, where the row and column refer to the same symbol, all show a value of 1 because any series of non-na data is always perfectly correlated with itself. 

The background of each correlation cell uses a gradient color based on the correlation value. By default, the gradient uses blue hues for positive correlation, orange hues for negative correlation, and white for no correlation. The intensity of each blue or orange hue corresponds to the strength of the measured correlation or anticorrelation. Users can customize the gradient's base colors using the inputs in the "Color gradient" section of the "Settings/Inputs" tab. 

█ FOR Pine Script® CODERS

  • This script uses the `getArrayFromString()` function from our [ValueAtTime](https://www.tradingview.com/script/FjIfbP3i-ValueAtTime/) library to process the input list of symbols. The function splits the "string" value by its commas, then constructs an [array](https://www.tradingview.com/pine-script-reference/v6/#type_array) of non-empty strings without leading or trailing whitespaces. Additionally, it uses the [str.upper()](https://www.tradingview.com/pine-script-reference/v6/#fun_str.upper) function to convert each symbol's characters to uppercase. 

  • The script's `getAlignedReturns()` function requests time-aligned prices with two [request.security()](https://www.tradingview.com/pine-script-reference/v6/#fun_request.security) calls that use spread tickers based on the chart's symbol and another symbol. Then, it calculates the arithmetic return using the `changePercent()` function from the [ta](https://www.tradingview.com/script/BICzyhq0-ta/) library. The `collectReturns()` function uses `getAlignedReturns()` within a loop and stores the data from each call within a [matrix](https://www.tradingview.com/pine-script-reference/v6/#type_matrix). The script calls the `arrayCorrelation()` function on pairs of rows from the returned matrix to calculate the correlation values. 

  • For consistency, the `getAlignedReturns()` function includes extended hours and dividend adjustment modifiers in its data requests. Additionally, it includes other settings inherited from the chart's context, such as "settlement-as-close" preferences.

  • A Pine script can execute up to 40 or 64 unique `request.*()` function calls, depending on the user's plan. The maximum number of symbols this script compares is half the plan's limit, because `getAlignedReturns()` uses two [request.security()](https://www.tradingview.com/pine-script-reference/v6/#fun_request.security) calls. 

  • This script can use the [request.security()](https://www.tradingview.com/pine-script-reference/v6/#fun_request.security) function within a loop because all scripts in Pine v6 enable dynamic requests by default. Refer to the [Dynamic requests](https://www.tradingview.com/pine-script-docs/concepts/other-timeframes-and-data/#dynamic-requests) section of the [Other timeframes and data](https://www.tradingview.com/pine-script-docs/concepts/other-timeframes-and-data/) page to learn more about this feature, and see our [v6 migration guide](https://www.tradingview.com/pine-script-docs/migration-guides/to-pine-version-6/) to learn what's new in Pine v6.

  • The script's (https://www.tradingview.com/pine-script-reference/v6/#type_table) uses two distinct [color.from_gradient()](https://www.tradingview.com/pine-script-reference/v6/#fun_color.from_gradient) calls in a [switch](https://www.tradingview.com/pine-script-reference/v6/#kw_switch) structure to determine the cell colors for positive and negative correlation values. One call calculates the color for values from -1 to 0 based on the first and second input colors, and the other calculates the colors for values from 0 to 1 based on the second and third input colors. 

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("Correlation Heatmap")

// Correlation Heatmap
// v2, 2026.01.09

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



import TradingView/ta/12 as TVta
import TradingView/ValueAtTime/2 as TVvt



//#region ———————————————————— Constants and inputs


// Tooltips
string TT_SYM = "A comma-separated list of symbols or ticker IDs with optional spaces."
string TT_COL = (
    "Defines the base colors for the correlation heatmap's color gradient:\n\n "
    + "- The first input sets the color for maximum anticorrelation (corr = -1).\n "
    + "- The second input sets the color for no correlation (corr = 0).\n "
    + "- The third input sets the color for maximum correlation (corr = 1)."
)
string TT_TF = "Timeframe of the sampled returns. Options are '1W' or '1M'."
string TT_MP = (
    "If enabled, the indicator limits the data used in the correlation calculation to the number of "
    + "periods specified in the input field. Otherwise, it uses the maximum number of periods allowed "
    + "by the chart's time span."
)
string TT_PR = "Specifies the number of fractional digits in the displayed correlation values."

// Symbol list, timeframe, and period control inputs
string symbolListInput = input.text_area("AAPL, GOLD, MSFT, BTCUSD, XOM, TLT, DBC, VNQ, SQQQ, VXX, GDX", "Symbol list", TT_SYM)
string tfInput         = input.timeframe("1M", "Returns timeframe", ["1W", "1M"], TT_TF)

// Data limit and precision inputs
bool limitInput      = input.bool(false, "Max periods",        tooltip = TT_MP, inline = "01")
int  maxPeriodsInput = input.int(60,     "         ",   2,     tooltip = TT_MP, inline = "01")
int  precisionInput  = input.int(2,      "Precision",   1, 16, tooltip = TT_PR)

// Gradient color inputs
string GRP1 = "Color gradient"
color negVeryStrongInput = input.color(#fb8c00, "", TT_COL, "01", group = GRP1)
color neutralInput       = input.color(#ffffff, "", TT_COL, "01", group = GRP1)
color posVeryStrongInput = input.color(#00acc1, "", TT_COL, "01", group = GRP1)
//#endregion



//#region ———————————————————— Functions


// @function            Calculates the arithmetic return for the instrument referenced by a specified symbol or ticker
//                      ID based on confirmed prices sampled at aligned periodic points. The function uses spread ticker
//                      IDs formed by the chart's symbol and the specified symbol in its requests to retrieve prices
//                      at times that align with periodic points on the current chart.
// @param symbol        (series string) The symbol of the instrument for which to request aligned price data. For
//                      consistency, the ticker IDs used by the requests include extended hours and dividend adjustment
//                      modifiers, and they inherit additional modifiers from the chart, such as "settlement-as-close"
//                      settings.
// @param timeframe     (series string) The timeframe of the time-aligned data request. The value should represent a
//                      timeframe that is higher than or equal to the chart's timeframe.
// @returns             (float) The arithmetic return of the instrument's prices retrieved at aligned sample points.
getAlignedReturns(series string symbol, series string timeframe) =>
    string chartTicker = ticker.new(syminfo.prefix, syminfo.tickerid)
    string standard1   = ticker.standard(chartTicker)
    string standard2   = ticker.standard(symbol)
    string sumSpread   = ticker.modify(
        ticker.inherit(chartTicker, standard1 + "+" + standard2), session.extended, adjustment.dividends
    )
    string diffSpread = ticker.modify(
        ticker.inherit(chartTicker, standard1 + "-" + standard2), session.extended, adjustment.dividends
    )
    float  currPrice   = close[1]
    float  prevPrice   = nz(close[2], open[1])
    [currSum, prevSum] = request.security(
        sumSpread, timeframe, [currPrice, prevPrice], barmerge.gaps_on, barmerge.lookahead_on
    )
    [currDiff, prevDiff] = request.security(
        diffSpread, timeframe, [currPrice, prevPrice], barmerge.gaps_on, barmerge.lookahead_on
    )
    TVta.changePercent(0.5 * (currSum - currDiff), 0.5 * (prevSum - prevDiff))


// @function            Calculates time-aligned periodic returns for the instruments referenced by an array of symbols,
//                      and stores the results in a matrix. Each row in the matrix corresponds to one of the
//                      specified instruments, and each column corresponds to a successive period where the data for
//                      each instrument is not `na`.
// @param symbols       (array<string>) References an array of symbols representing the instruments for
//                      which to request aligned price data. For consistency, each ticker ID used in the data requests
//                      includes extended hours and dividend adjustment modifiers, and it inherits additional modifiers
//                      from the chart, such as "settlement-as-close" settings.
// @param timeframe     (simple string) The timeframe of the time-aligned data request. The value must represent a
//                      timeframe that is greater than or equal to the chart's timeframe.
// @param maxPeriods    (simple int) Optional. The maximum number of periodic returns to store for each requested
//                      dataset. If the value is `na`, the maximum length of the data is the span of the current chart.
//                      The default is `na`.
// @returns             (matrix<float>) The ID of a matrix containing aligned periodic returns for each requested
//                      dataset.
collectReturns(array<string> symbols, simple string timeframe, simple int maxPeriods = na) =>
    var int           numSymbols   = symbols.size()
    var array<float>  returnsArray = array.new<float>(numSymbols)
    var matrix<float> result       = matrix.new<float>(numSymbols, 0)
    bool exclude = false
    for [i, symbol] in symbols
        float priceReturn = getAlignedReturns(symbol, timeframe)
        if na(priceReturn)
            exclude := true
            break
        returnsArray.set(i, priceReturn)
    int cols = result.columns()
    if not exclude
        result.add_col(cols, returnsArray)
        cols += 1
    if cols > maxPeriods
        result.remove_col(0)
    result


// @function            Calculates the Pearson correlation coefficient between the elements stored in two "float"
//                      arrays. The value represents the linear relationship between the arrays' elements. The
//                      coefficient is a measure of the covariance between the arrays, normalized by the product of
//                      their standard deviaitions.
// @param id1           (array<float>) References the first array to compare in the calculation. The array's size must
//                      match the size of the `id2` array.
// @param id2           (array<float>) References the second array to compare in the calculation. The array's size must
//                      match the size of the `id1` array.
// @returns             (float) The correlation coefficient between the `id1` and `id2` arrays' elements. The
//                      coefficient ranges from -1 to 1. A value of 1 indicates perfect positive correlation, -1
//                      indicates perfect negative correlation (anticorrelation), and 0 indicates no correlation.
arrayCorrelation(array<float> id1, array<float> id2) =>
    float covariance = array.covariance(id1, id2)
    float std1 = id1.stdev()
    float std2 = id2.stdev()
    float result = covariance / (std1 * std2)
//#endregion



//#region ———————————————————— Calculations and display


// @variable References an array of symbol strings representing the instruments for which to calculate correlation.
//           The script converts all letters in the `symbolListInput` to uppercase, splits the input value by its
//           commas, then trims all whitespaces from each item.
var array<string> symbolsArray = TVvt.getArrayFromString(str.upper(symbolListInput))

// @variable The number of symbol strings in the array referenced by `symbolsArray`.
var int numSymbols = symbolsArray.size()
// Calculate the height and width of each table cell, including headers, to evenly distribute cells within the pane.
var float cellWidth  = 95.0 / (numSymbols + 1)
var float cellHeight = 90.0 / (numSymbols + 1)

// @variable References a matrix containing monthly or weekly returns for each specified instrument.
//           Each row corresponds to an instrument (e.g., row 0 stores data for the instrument referenced by the first
//           symbol), and each column corresponds to a period (e.g., column 0 stores the oldest period's returns).
matrix<float> symbolReturns = collectReturns(symbolsArray, tfInput, limitInput ? maxPeriodsInput : na)

// @variable References a table with `numSymbols + 1` rows and columns for the correlation heatmap display.
var table heatmap = table.new(
    position.middle_center, numSymbols + 1, numSymbols + 1, border_color = #8f93a1, border_width = 1
)

// Logic to initialize the table's header cells on the first bar.
if barstate.isfirst
    // Initialize the top-left cell with blank text.
    heatmap.cell(0, 0, "", cellWidth, cellHeight, chart.fg_color, bgcolor = chart.bg_color)
    // Initialize the leftmost and top cell with symbol names.
    for [index, symbol] in symbolsArray
        heatmap.cell(0, index + 1, symbol, cellWidth, cellHeight, chart.fg_color, bgcolor = chart.bg_color)
        heatmap.cell(index + 1, 0, symbol, cellWidth, cellHeight, chart.fg_color, bgcolor = chart.bg_color)

// Logic to display correlation and length data on the last bar.
if barstate.islast
    // @variable The number of periods represented by the `symbolReturns` matrix.
    int numPeriods = symbolReturns.columns()
    // Update the table's first cell to show the number of analyzed periods.
    heatmap.cell_set_text(0, 0, str.format("Length:\n{0} {1}", numPeriods, tfInput == "1M" ? "months" : "weeks"))
    // Nested loops to calculate correlations and set the `heatmap` cells.
    for i = 0 to numSymbols - 1
        for j = 0 to i
            // Initialize the cell with a predefined text and background color if `j` and `i` are the same.
            if j == i
                string cellText = numPeriods < 2 ? "NaN" : "1"
                color  bgColor  = numPeriods < 2 ? color(na) : posVeryStrongInput
                heatmap.cell(i + 1, j + 1, cellText, cellWidth, cellHeight, #000000, bgcolor = bgColor)
                continue
            // @variable References an array of returns for the `i`-th listed instrument.
            array<float> returns1 = symbolReturns.row(i)
            // @variable References an array of returns for the `j`-th listed instrument.
            array<float> returns2 = symbolReturns.row(j)
            // @variable The correlation coefficient between the values in the `returns1` and `returns2` arrays.
            float correlation = arrayCorrelation(returns1, returns2)
            // @variable A string representing the correlation value, rounded to `precisionInput` fractional digits.
            string cellText = str.tostring(correlation, "0." + str.repeat("0", precisionInput))
            // @variable The cell's background color, which uses a polarized gradient based on the correlation's sign.
            color bgColor = switch math.sign(correlation)
                1 => color.from_gradient(correlation,  0, 1, neutralInput, posVeryStrongInput)
                =>   color.from_gradient(correlation, -1, 0, negVeryStrongInput, neutralInput)
            // Initialize the cells at `i + 1, j + 1`, and `j + 1, i + 1` using `cellText` and `bgColor`.
            heatmap.cell(i + 1, j + 1, cellText, cellWidth, cellHeight, #000000, bgcolor = bgColor)
            heatmap.cell(j + 1, i + 1, cellText, cellWidth, cellHeight, #000000, bgcolor = bgColor)

// Raise an error if the `tfInput` represents a timeframe lower than the chart's timeframe.
if timeframe.in_seconds(tfInput) < timeframe.in_seconds()
    runtime.error(
        "For accurate calculations, the requested timeframe must be higher than or equal to the chart's timeframe."
    )
//#endregion
````
