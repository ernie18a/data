<!-- tradingview-pine-id: PUB;9891cb9dfb3c41739ea14570ce58d81a -->
<!-- tradingviewscripts-format: 1 -->
# Sharpe and Sortino Ratios

Source: https://www.tradingview.com/script/Mi5DL7bi-Sharpe-and-Sortino-Ratios/

## Description

█  OVERVIEW

This indicator calculates the [Sharpe](https://en.wikipedia.org/wiki/Sharpe_ratio) and [Sortino](https://en.wikipedia.org/wiki/Sortino_ratio) ratios using a chart symbol's periodic price returns, offering insights into the symbol's risk-adjusted performance. It features the option to calculate these ratios by comparing the periodic returns to a fixed annual rate of return or the returns from another selected symbol's context. 

█  CONCEPTS

Returns, risk, and volatility

The return on an investment is the relative gain or loss over a period, often expressed as a percentage. Investment returns can originate from several sources, including capital gains, dividends, and interest income. Many investors seek the highest returns possible in the quest for profit. However, prudent investing and trading entails evaluating such returns against the associated risks (i.e., the uncertainty of returns and the potential for financial losses) for a clearer perspective on overall performance and sustainability.

The profitability of an investment typically comes at the cost of enduring market swings, noise, and general uncertainty. To navigate these turbulent waters, investors and portfolio managers often utilize volatility, a measure of the statistical dispersion of historical returns, as a foundational element in their risk assessments because it provides a tangible way to gauge the uncertainty in returns. High volatility suggests increased uncertainty and, consequently, higher risk, whereas low volatility suggests more stable returns with minimal fluctuations, implying lower risk. These concepts are integral components in several risk-adjusted performance metrics, including the Sharpe and Sortino ratios calculated by this indicator. 

Risk-free rate

The risk-free rate represents the rate of return on a hypothetical investment carrying no risk of financial loss. This theoretical rate provides a benchmark for comparing the returns on a risky investment and evaluating whether its excess returns justify the risks. If an investment's returns are at or below the theoretical risk-free rate or the [risk premium](https://en.wikipedia.org/wiki/Risk_premium) is below a desired amount, it may suggest that the returns do not compensate for the extra risk, which might be a call to reassess the investment.

Since the risk-free rate is a theoretical concept, investors often utilize proxies for the rate in practice, such as Treasury bills and other government bonds. Conventionally, analysts consider such instruments "risk-free" for a domestic holder, as they are a form of government obligation with a low perceived likelihood of default. 

The average yield on short-term Treasury bills, influenced by economic conditions, monetary policies, and inflation expectations, has historically hovered around 2-3% over the long term. This range also aligns with central banks' inflation targets. As such, one may interpret a value within this range as a minimum proxy for the risk-free rate, as it may correspond to the minimum rate required to maintain purchasing power over time. This indicator uses a default value of 2% as the risk-free rate in its Sharpe and Sortino ratio calculations. Users can adjust this value from the "Risk-free rate of return" input in the "Settings/Inputs" tab. 

Sharpe and Sortino ratios

The Sharpe and Sortino ratios are two of the most widely used metrics that offer insight into an investment's risk-adjusted performance. They provide a standardized framework to compare the effectiveness of investments relative to their perceived risks. These metrics can help investors determine whether the returns justify the risks taken to achieve them, promoting more informed investment decisions.

Both metrics measure risk-adjusted performance similarly. However, they have some differences in their formulas and their interpretation:

 1. Sharpe ratio
  The [Sharpe ratio](https://en.wikipedia.org/wiki/Sharpe_ratio), developed by Nobel laureate William F. Sharpe, measures the performance of an investment compared to a theoretically risk-free asset, adjusted for the investment risk. The ratio uses the following formula:

  Sharpe Ratio = (𝑅𝑎 − 𝑅𝑓) / 𝜎𝑎

  Where:
   • 𝑅𝑎 = Average return of the investment
   • 𝑅𝑓 = Theoretical risk-free rate of return
   • 𝜎𝑎 = Standard deviation of the investment's returns (volatility) 

  A higher Sharpe ratio indicates a more favorable risk-adjusted return, as it signifies that the investment produced higher excess returns per unit of increase in total perceived risk.

 2. Sortino ratio
  The [Sortino ratio](https://en.wikipedia.org/wiki/Sortino_ratio) is a modified form of the Sharpe ratio that only considers downside volatility, i.e., the volatility of returns below the theoretical risk-free benchmark. Although it shares close similarities with the Sharpe ratio, it can produce very different values, especially when the returns do not have a symmetrical distribution, since it does not penalize upside and downside volatility equally. The ratio uses the following formula:

  Sortino Ratio = (𝑅𝑎 − 𝑅𝑓) / 𝜎𝑑

  Where:
   • 𝑅𝑎 = Average return of the investment
   • 𝑅𝑓 = Theoretical risk-free rate of return
   • 𝜎𝑑 = Downside deviation (standard deviation of negative excess returns, or downside volatility)

  The Sortino ratio offers an alternative perspective on an investment's return-generating efficiency since it does not consider upside volatility in its calculation. A higher Sortino ratio signifies that the investment produced higher excess returns per unit of increase in perceived downside risk.

The risk-free rate (𝑅𝑓) in the numerator of both ratio formulas acts as a baseline for comparing an investment's performance to a theoretical risk-free alternative. By subtracting the risk-free rate from the expected return (𝑅𝑎−𝑅𝑓), the numerator essentially represents the [risk premium](https://en.wikipedia.org/wiki/Risk_premium) of the investment.

Comparison with another symbol

In addition to the conventional Sharpe and Sortino ratios, which compare an instrument's returns to a risk-free rate, this indicator can also compare returns to a user-specified benchmark symbol, allowing the calculation of Information ratios. 

An [Information ratio](https://en.wikipedia.org/wiki/Information_ratio) is a generalized form of the Sharpe ratio that compares an investment's returns to a risky benchmark, such as SPY, rather than a risk-free rate. It measures the investment's active return (the difference between its returns and the benchmark returns) relative to its tracking error (i.e., the volatility of the active return) using the following formula:

𝐼𝑅 = (𝑅𝑝 − 𝑅𝑏) / 𝑇𝐸

Where:
• 𝑅𝑝 = Average return on the portfolio or investment
• 𝑅𝑏 = Average return from the benchmark instrument
• 𝑇𝐸 = Tracking error (volatility of 𝑅𝑝 − 𝑅𝑏)

Comparing returns to a benchmark instrument rather than a theoretical risk-free rate offers unique insights into risk-adjusted performance. Higher Information ratios signify that the investment produced higher active returns per unit of increase in risk relative to the benchmark. Conventional choices for non-risk-free benchmarks include major composite indices like the S&P 500 and DJIA, as the resulting ratios can provide insight into the effectiveness of an investment relative to the broader market. 

Users can enable this generalized calculation for both the Sharpe and Sortino ratios by selecting the "Benchmark symbol returns" option from the "Benchmark type" dropdown in the "Settings/Inputs" tab. 

It's crucial to note that this indicator compares the charts symbol's rate of change (return) to the rate of change in the benchmark symbol. Consequently, not all symbols available on TradingView are suitable for use with these ratios due to the nature of what their values represent. For instance, using a bond as a benchmark will produce distorted results since each bar's values represent yields rather than prices, meaning it compares the rate of change in the yield. To maintain consistency and relevance in the calculated ratios, ensure the values from the compared symbols strictly represent price information.

█  FEATURES

This indicator provides traders with two widely used metrics for assessing risk-adjusted performance, generalized to allow users to compare the chart symbol's price returns to a fixed risk-free rate or the returns from another risky symbol. Below are the key features of this indicator:

Timeframe selection

The "Returns timeframe" input determines the timeframe of the calculated price returns. Users can select any value greater than or equal to the chart's timeframe. The default timeframe is "1M".

Periodic returns tracking

This indicator compounds and collects requested price returns from the selected timeframe over monthly or daily periods, similar to how the Broker Emulator works when calculating strategy performance metrics on trade data. It employs the following logic:

 • Track returns over monthly periods if the chart's data spans at least two months.
 • Track returns over daily periods if the chart's data spans at least two days but not two months.
 • Do not track or collect returns if the data spans less than two days, as the amount of data is insufficient for meaningful ratio calculations. 

The indicator uses the returns collected from up to a specified number of periods to calculate the Sharpe and Sortino ratios, depending on the available historical data. It also uses these periodic returns to calculate the average returns it displays in the Data Window. 

Users can control the maximum number of periods the indicator analyzes with the "Max no. of periods used" input in the "Settings/Inputs" tab. The default value is 60 periods. 

Benchmark specification

The "Benchmark return type" input specifies the benchmark type the indicator compares to the chart symbol's returns in the ratio calculations. It features the following two options:

 • "Risk-free rate of return (%)": Compares the price returns to a user-specified annual rate of return representing a theoretical risk-free rate (e.g., 2%). 
 • "Benchmark symbol return": Compares the price returns to a selected benchmark symbol (e.g., "AMEX:SPY) to calculate Information ratios. 

When comparing a chart symbol's returns to a specified benchmark symbol, this indicator aligns the times of data points from the benchmark with the times of data points from the chart's symbol to facilitate a fair comparison between symbols with different active sessions. 

Visualization and display

 • The indicator displays the periodic returns requested from the specified "Returns timeframe" in a separate pane. The plot includes dynamic colors to signify positive and negative returns. 
 • When the "Returns timeframe" value represents a higher timeframe, the indicator displays background highlights on the main chart pane to signify when a new value is available and whether the return is positive or negative.  
 • When the specified benchmark return type is a benchmark symbol, the indicator displays the requested symbol's returns in the separate pane as a gray line for visual comparison. 
 • Within the separate pane, the indicator displays a single-cell table that shows the base period it uses for periodic returns, the number of periods it uses in the calculation, the timeframe of the requested data, and the calculated Sharpe and Sortino ratios. 
 • The Data Window displays the chart symbol and benchmark returns, their periodic averages, and the Sharpe and Sortino ratios. 

█  FOR Pine Script™ CODERS

 • This script utilizes the functions from our [RiskMetrics](https://www.tradingview.com/script/oOgZRqiM-RiskMetrics/) library to determine the size of the periods, calculate and collect periodic returns, and compute the Sharpe and Sortino ratios.
 • The `getAlignedPrices()` function in this script requests price data for the chart's symbol and a benchmark symbol with consistent time alignment by utilizing spread symbols, which helps facilitate a fair comparison between different symbol types. Retrieving prices from spreads avoids potential information loss and data misalignment that can otherwise occur when using separate requests from each symbol's context when those symbols have different sessions or data times. 
 • For consistency, the `getAlignedPrices()` function includes extended hours and dividend adjustment modifiers in its data requests. Additionally, it includes other settings inherited from the chart's context, such as "settlement-as-close" preferences for fair comparison between futures instruments. 
 • This script uses the `changePercent()` function from our [ta](https://www.tradingview.com/script/BICzyhq0-ta/) library to calculate the percentage changes of the requested data.
 • The [newly released](https://www.tradingview.com/pine-script-docs/en/v5/Release_notes.html#april-2024) `force_overlay` parameter in display-related functions allows indicators to display visuals on the main chart and a separate pane simultaneously. We use the parameter in this script's [bgcolor()](https://www.tradingview.com/pine-script-reference/v5/#fun_bgcolor) call to display background highlights on the main chart. 

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("Sharpe and Sortino Ratios")

// Sharpe and Sortino Ratios
// v3, 2026.01.09

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



import TradingView/RiskMetrics/3 as TVrm
import TradingView/ta/12 as TVta



//#region ———————————————————— Constants and inputs


// Constants
string BM01     = "Fixed rate of return (%)"
string BM02     = "Benchmark instrument returns"
color  WHITE    = color.white
color  GRAY30   = color.new(color.gray, 30)
color  ORANGE80 = color.new(color.orange, 80)
color  AQUA80   = color.new(color.aqua, 80)

// Tooltips
string TT_TF = "Timeframe of the sampled returns."
string TT_NT = "Maximum number of monthly periods to analyze."
string TT_FI = (
    "Type of benchmark to compare against the chart instrument's returns:\n"
    + "- If 'Fixed rate of return (%)', compares chart instrument returns to a fixed annual percentage benchmark.\n"
    + "- If 'Benchmark instrument returns', compares chart instrument returns to the returns from the instrument "
    + "referenced by the 'Benchmark symbol' input to calculate Information ratios."
)
string TT_PT = "Annual fixed rate of return to compare if the benchmark type is 'Fixed rate of return (%)'."
string TT_SY = "Symbol of the instrument to compare if the benchmark type is 'Benchmark instrument returns'."

// Specify the timeframe of the returns, the number of calculation periods to analyze, and the performance benchmark.
string tfInput         = input.timeframe("1M",    "Returns timeframe",                tooltip = TT_TF)
int    numOfTFsInput   = input.int(60,            "Max no. of periods used",          tooltip = TT_NT)
string useFixedInput   = input.string(BM01,       "Benchmark return type",            tooltip = TT_FI, options = [BM01, BM02])
bool   isFixed         = useFixedInput == BM01
bool   isBench         = useFixedInput == BM02
float  percentageInput = input.float(2,           "    Risk-free rate of return (%)", tooltip = TT_PT, active = isFixed, minval = 0)
string symbolInput     = input.symbol("AMEX:SPY", "    Benchmark symbol",             tooltip = TT_SY, active = isBench)

// Group to control the appearance of the info table.
string GRP1                 = "Info table"
bool   showInfoBoxInput     = input.bool(true,       "Show info table",                group = GRP1)
string infoBoxSizeInput     = input.string("normal", "Size ",           inline = "21", group = GRP1, active = showInfoBoxInput, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string infoBoxYPosInput     = input.string("bottom", "↕",               inline = "21", group = GRP1, active = showInfoBoxInput, options = ["top", "middle", "bottom"])
string infoBoxXPosInput     = input.string("right",  "↔",               inline = "21", group = GRP1, active = showInfoBoxInput, options = ["left", "center", "right"])
color  infoBoxColorInput    = input.color(GRAY30,    "",                inline = "21", group = GRP1, active = showInfoBoxInput)
color  infoBoxTxtColorInput = input.color(WHITE,     "",                inline = "21", group = GRP1, active = showInfoBoxInput)
//#endregion



//#region ———————————————————— Functions


// @function            Requests time-aligned prices for the instruments referenced by the chart's symbol and a
//                      specified symbol for statistical comparison. The function uses spread ticker IDs formed by the
//                      two symbols in its requests to retrieve prices at times that align with periodic points on the
//                      current chart.
// @param altSymbol     (simple string) The symbol for the dataset to align with that of the chart's symbol. For
//                      consistency, the ticker IDs used by the requests include extended hours and dividend adjustment
//                      modifiers, and they inherit additional modifiers from the chart, such as "settlement-as-close"
//                      settings.
// @param timeframe     (simple string) The timeframe of the aligned data request. Must be greater than or equal to
//                      the chart's timeframe.
// @param offset        (simple int) The bar offset applied to the requested prices. Use a value greater than or equal
//                      to 1 to prevent lookahead bias in requested HTF historical data.
// @returns             ([series float, series float, series float, series float]) A tuple containing the aligned
//                      current and previous prices of both instruments on the specified timeframe.
getAlignedPrices(simple string altSymbol, simple string timeframe, simple int offset = 0) =>
    var string chartTicker = ticker.new(syminfo.prefix, syminfo.tickerid)
    var string standard1   = ticker.standard(syminfo.tickerid)
    var string standard2   = ticker.standard(altSymbol)
    var string sumSpread   = ticker.modify(
        ticker.inherit(chartTicker, standard1 + "+" + standard2), session.extended, adjustment.dividends
    )
    var string diffSpread = ticker.modify(
        ticker.inherit(chartTicker, standard1 + "-" + standard2), session.extended, adjustment.dividends
    )
    float currPrice = close[offset]
    float prevPrice = nz(close[offset + 1], open[offset])
    [currSum, prevSum] = request.security(
        sumSpread, timeframe, [currPrice, prevPrice], barmerge.gaps_on, barmerge.lookahead_on
    )
    [currDiff, prevDiff] = request.security(
        diffSpread, timeframe, [currPrice, prevPrice], barmerge.gaps_on, barmerge.lookahead_on
    )
    [0.5 * (currSum + currDiff), 0.5 * (currSum - currDiff), 0.5 * (prevSum + prevDiff), 0.5 * (prevSum - prevDiff)]
//#endregion



//#region ———————————————————— Calculations


// @variable `true` if the selected timeframe is higher than the current chart's timeframe, and `false` otherwise.
var bool isHtf = timeframe.in_seconds(tfInput) > timeframe.in_seconds()
// @variable The specified fixed annual rate of return if `isFixed` is `true`, and 0 otherwise.
var float fixedReturn = isFixed ? percentageInput : 0.0
// @variable The estimated fixed rate of return per period.
var float fixedPeriodReturn = fixedReturn / 12

// Request prices for the chart's instrument on the `tfInput` timeframe with full history to compare to `fixedReturn`.
[htfCurrent, htfPrevious] = request.security(
    syminfo.tickerid, tfInput, [close[1], nz(close[2], open[1])], barmerge.gaps_on, barmerge.lookahead_on
)
// Request time-aligned prices for the instruments referenced by the chart's symbol and `symbolInput`, with modifiers,
// for direct comparison.
[chartVal, benchVal, chartVal1, benchVal1] = getAlignedPrices(symbolInput, timeframe.period)
[htfChart, htfBench, htfChart1, htfBench1] = getAlignedPrices(symbolInput, tfInput, 1)

// Determine which price values to use for the returns calculations.
float chartPrice  = isFixed ? (isHtf ? htfCurrent : close) : (isHtf ? htfChart : chartVal)
float chartPrice1 = isFixed ? (isHtf ? htfPrevious : nz(close[1], open)) : (isHtf ? htfChart1 : chartVal1)
float benchPrice  = isHtf ? htfBench : benchVal
float benchPrice1 = isHtf ? htfBench1 : benchVal1

// @variable The sampled percentage change for the instrument represented on the chart.
float chartReturn = TVta.changePercent(chartPrice, chartPrice1)
// @variable The benchmark instrument's percentage change if the `isFixed` value is `false`, and 0 otherwise.
float benchReturn = isFixed ? 0.0 : TVta.changePercent(benchPrice, benchPrice1)

// @variable References an array of monthly returns for the ratio calculations.
array<float> periodicReturns = TVrm.getPeriodicReturns(chartReturn, benchReturn, numOfTFsInput)

// @variable The Sharpe ratio of the collected periodic returns.
float sharpe = TVrm.sharpeRatio(periodicReturns, fixedReturn)
// @variable The Sortino ratio of the collected periodic returns.
float sortino = TVrm.sortinoRatio(periodicReturns, fixedReturn)

// Create arrays of periodic returns from `chartReturn` and `benchReturn` values for display calculations.
array<float> symbolChanges    = TVrm.getPeriodicReturns(chartReturn, numOfTFsInput)
array<float> benchmarkChanges = isFixed ? na : TVrm.getPeriodicReturns(benchReturn, numOfTFsInput)
// @variable The average return value in the `symbolChanges` array.
float avgSymbolChange = symbolChanges.avg()
// @variable The average periodic benchmark return.
float avgBenchmarkChange = isFixed ? fixedPeriodReturn : benchmarkChanges.avg()
// @variable `true` when new data is available if `tfInput` represents a higher timeframe, and `false` otherwise.
bool isNewPeriod = isHtf and not na(chartReturn)
//#endregion



//#region ———————————————————— Errors and outputs


// Raise an error if the `tfInput` is smaller than the chart's timeframe.
if timeframe.in_seconds(tfInput) < timeframe.in_seconds()
    runtime.error("For accurate ratios, the requested TF must be greater than or equal to the TF of the chart.")

// @variable The `chartReturn` series with `na` masking for display purposes.
float chartReturnDisplay = fixnan(chartReturn)
// @variable The `benchReturn` series with `na` masking for display purposes, or `na` if `useFixedInput` is `true`.
float benchReturnDisplay = fixnan(isFixed ? na : benchReturn)
// Calculate main plot, fill, and background colors.
color plotColor = isNewPeriod ? color(na) : chartReturnDisplay < 0.0 ? color.orange : color.aqua
color fillColor = isNewPeriod ? color(na) : chartReturnDisplay < 0.0 ? ORANGE80 : AQUA80
color bgColor   = not isNewPeriod ? color(na) : chartReturnDisplay < 0.0 ? ORANGE80 : AQUA80

// Plot the `chartReturnDisplay` series and 0, then fill the space between them.
symbolChangePlot = plot(chartReturnDisplay, "Chart instrument return", plotColor, precision = 2, format = format.percent)
zeroPlot         = plot(0, "Zero level", color.new(color.gray, 60), display = display.pane)
fill(symbolChangePlot, zeroPlot, fillColor, "Chart instrument return fill")
// Plot the `benchReturnDisplay` value for visual comparison when `useFixedInput` is `false`.
plot(benchReturnDisplay, "Benchmark instrument return", color.gray, 2, precision = 2, format = format.percent)
// Highlight the main chart's background when `isNewPeriod` to signify the direction of `chartReturnDisplay`.
bgcolor(bgColor, title = "Background highlight", force_overlay = true)

// Plot the average chart symbol and benchmark returns alongside the Sharpe and Sortino ratios in the Data Window.
dataWindow = display.data_window
plot(avgSymbolChange,    "Avg. chart instrument return",     color.purple, display = dataWindow, format = format.percent)
plot(avgBenchmarkChange, "Avg. benchmark instrument return", color.blue,   display = dataWindow, format = format.percent)
plot(sharpe,  "Sharpe",  sharpe  > 0 ? color.teal : color.maroon, precision = 5, display = dataWindow)
plot(sortino, "Sortino", sortino > 0 ? color.teal : color.maroon, precision = 5, display = dataWindow)

// Display the base period, number of periods, returns timeframe, and the calculated ratios in a table on the last bar.
if barstate.islast and showInfoBoxInput
    var table tfDisplay = table.new(str.format("{0}_{1}", infoBoxYPosInput, infoBoxXPosInput), 1, 1)
    string tableTxt  = str.format(
        "Calculation base period:  {0}"
        + "\n# of calculation periods: {1}"
        + "\nReturns timeframe:        {2}"
        + "\nSharpe ratio:             {3}"
        + "\nSortino ratio:            {4}",
        "1M", periodicReturns.size(),
        tfInput == "" ? (timeframe.isdwm and timeframe.multiplier == 1 ? "1" : "") + timeframe.period : tfInput,
        str.tostring(sharpe, "#.#####"), str.tostring(sortino, "#.#####")
    )
    table.cell(
        tfDisplay, 0, 0, tableTxt, bgcolor = infoBoxColorInput, text_color = infoBoxTxtColorInput,
        text_size = infoBoxSizeInput, text_halign = text.align_left, text_font_family = font.family_monospace
    )
//#endregion
````
