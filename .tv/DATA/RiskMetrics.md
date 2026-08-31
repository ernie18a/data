<!-- tradingview-pine-id: PUB;92c559802790439b8e74c397f2dd8f21 -->
<!-- tradingviewscripts-format: 1 -->
# RiskMetrics

Source: https://www.tradingview.com/script/oOgZRqiM-RiskMetrics/

## Description

█  OVERVIEW

This library is a tool for Pine programmers that provides functions for calculating risk-adjusted performance metrics on periodic price returns. The calculations used by this library's functions closely mirror those the Broker Emulator uses to calculate strategy performance metrics (e.g., Sharpe and Sortino ratios) without depending on strategy-specific functionality.

█  CONCEPTS

Returns, risk, and volatility

The return on an investment is the relative gain or loss over a period, often expressed as a percentage. Investment returns can originate from several sources, including capital gains, dividends, and interest income. Many investors seek the highest returns possible in the quest for profit. However, prudent investing and trading entails evaluating such returns against the associated risks (i.e., the uncertainty of returns and the potential for financial losses) for a clearer perspective on overall performance and sustainability. 

One way investors and analysts assess the risk of an investment is by analyzing its volatility, i.e., the statistical dispersion of historical returns. Investors often use volatility in risk estimation because it provides a quantifiable way to gauge the expected extent of fluctuation in returns. Elevated volatility implies heightened uncertainty in the market, which suggests higher expected risk. Conversely, low volatility implies relatively stable returns with relatively minimal fluctuations, thus suggesting lower expected risk. Several risk-adjusted performance metrics utilize volatility in their calculations for this reason.

Risk-free rate

The risk-free rate represents the rate of return on a hypothetical investment carrying no risk of financial loss. This theoretical rate provides a benchmark for comparing the returns on a risky investment and evaluating whether its excess returns justify the risks. If an investment's returns are at or below the theoretical risk-free rate or the [risk premium](https://en.wikipedia.org/wiki/Risk_premium) is below a desired amount, it may suggest that the returns do not compensate for the extra risk, which might be a call to reassess the investment.

Since the risk-free rate is a theoretical concept, investors often utilize proxies for the rate in practice, such as Treasury bills and other government bonds. Conventionally, analysts consider such instruments "risk-free" for a domestic holder, as they are a form of government obligation with a low perceived likelihood of default. 

The average yield on short-term Treasury bills, influenced by economic conditions, monetary policies, and inflation expectations, has historically hovered around 2-3% over the long term. This range also aligns with central banks' inflation targets. As such, one may interpret a value within this range as a minimum proxy for the risk-free rate, as it may correspond to the minimum rate required to maintain purchasing power over time.

The built-in [Sharpe](https://www.tradingview.com/support/solutions/43000681694-performance-summary-sharpe-ratio/) and [Sortino](https://www.tradingview.com/support/solutions/43000681697-performance-summary-sortino-ratio/) ratios that [strategies](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Strategies.html#strategies) calculate and display in the [Performance Summary](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Strategies.html#performance-summary) tab use a default risk-free rate of 2%, and the metrics in this library's example code use the same default rate. Users can adjust this value to fit their analysis needs. 

Risk-adjusted performance

Risk-adjusted performance metrics gauge the effectiveness of an investment by considering its returns relative to the perceived risk. They aim to provide a more well-rounded picture of performance by factoring in the level of risk taken to achieve returns. Investors can utilize such metrics to help determine whether the returns from an investment justify the risks and make informed decisions. 

The two most commonly used risk-adjusted performance metrics are the Sharpe ratio and the Sortino ratio.

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

█  CALCULATIONS

Return period detection

Calculating risk-adjusted performance metrics requires collecting returns across several periods of a given size. Analysts may use different period sizes based on the context and their preferences. However, two widely used standards are monthly or daily periods, depending on the available data and the investment's duration. The built-in ratios displayed in the [Strategy Tester](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Strategies.html#strategy-tester) utilize returns from either monthly or daily periods in their calculations based on the following logic:

 • Use monthly returns if the history of closed trades spans at least two months. 
 • Use daily returns if the trades span at least two days but less than two months.
 • Do not calculate the ratios if the trade data spans fewer than two days. 

This library's `detectPeriod()` function applies related logic to available chart data rather than trade data to determine which period is appropriate:

 • It returns [true](https://www.tradingview.com/pine-script-reference/v5/#const_true) if the chart's data spans at least two months, indicating that it's sufficient to use monthly periods.
 • It returns [false](https://www.tradingview.com/pine-script-reference/v5/#const_false) if the chart's data spans at least two days but not two months, suggesting the use of daily periods. 
 • It returns [na](https://www.tradingview.com/pine-script-reference/v5/#var_na) if the length of the chart's data covers less than two days, signifying that the data is insufficient for meaningful ratio calculations. 

It's important to note that programmers should only call `detectPeriod()` from a script's global scope or within the outermost scope of a function called from the global scope, as it requires the [time](https://www.tradingview.com/pine-script-reference/v5/#var_time) value from the first bar to accurately measure the amount of time covered by the chart's data. 

Collecting periodic returns

This library's `getPeriodicReturns()` function tracks price return data within monthly or daily periods and stores the periodic values in an [array](https://www.tradingview.com/pine-script-reference/v5/#type_array). It uses a `detectPeriod()` call as the condition to determine whether each element in the array represents the return over a monthly or daily period.

The `getPeriodicReturns()` function has two overloads. The first overload requires two arguments and outputs an [array](https://www.tradingview.com/pine-script-reference/v5/#type_array) of monthly or daily returns for use in the `sharpe()` and `sortino()` methods. To calculate these returns: 

 1. The `percentChange` argument should be a series that represents percentage gains or losses. The values can be bar-to-bar return percentages on the chart timeframe or percentages requested from a higher timeframe.
 2. The function compounds all non-na `percentChange` values within each monthly or daily period to calculate the period's total return percentage. When the `percentChange` represents returns from a higher timeframe, ensure the requested data includes [gaps](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#gaps) to avoid compounding redundant values. 
 3. After a period ends, the function [queues](https://www.tradingview.com/pine-script-docs/en/v5/language/Arrays.html#using-an-array-as-a-queue) the compounded return into the [array](https://www.tradingview.com/pine-script-reference/v5/#type_array), removing the oldest element from the array when its size exceeds the `maxPeriods` argument. 

The resulting [array](https://www.tradingview.com/pine-script-reference/v5/#type_array) represents the sequence of closed returns over up to `maxPeriods` months or days, depending on the available data. 

The second overload of the function includes an additional `benchmark` parameter. Unlike the first overload, this version tracks and collects differences between the `percentChange` and the specified `benchmark` values. The resulting [array](https://www.tradingview.com/pine-script-reference/v5/#type_array) represents the sequence of excess returns over up to `maxPeriods` months or days. Passing this array to the `sharpe()` and `sortino()` methods calculates generalized [Information ratios](https://en.wikipedia.org/wiki/Information_ratio), which represent the risk-adjustment performance of a sequence of returns compared to a risky benchmark instead of a risk-free rate. For consistency, ensure the non-na times of the `benchmark` values align with the times of the `percentChange` values. 

Ratio methods

This library's `sharpe()` and `sortino()` methods respectively calculate the Sharpe and Sortino ratios based on an [array](https://www.tradingview.com/pine-script-reference/v5/#type_array) of returns compared to a specified annual benchmark. Both methods adjust the annual benchmark based on the number of periods per year to suit the frequency of the returns:

 • If the method call does not include a `periodsPerYear` argument, it uses `detectPeriod()` to determine whether the returns represent monthly or daily values based on the chart's history. If monthly, the method divides the `annualBenchmark` value by 12. If daily, it divides the value by 365.
 • If the method call does specify a `periodsPerYear` argument, the argument's value supersedes the automatic calculation, facilitating custom benchmark adjustments, such as dividing by 252 when analyzing collected daily stock returns.

When the [array](https://www.tradingview.com/pine-script-reference/v5/#type_array) passed to these methods represents a sequence of excess returns, such as the result from the second overload of `getPeriodicReturns()`, use an `annualBenchmark` value of 0 to avoid comparing those excess returns to a separate rate. 

By default, these methods only calculate the ratios on the last available bar to minimize their resource usage. Users can override this behavior with the `forceCalc` parameter. When the value is [true](https://www.tradingview.com/pine-script-reference/v5/#const_true), the method calculates the ratio on each call if sufficient data is available, regardless of the bar index.  

[Look first. Then leap.](https://www.tradingview.com/athletes/) 

█  FUNCTIONS & METHODS

This library contains the following functions:

detectPeriod()
  Determines whether the chart data has sufficient coverage to use monthly or daily returns
for risk metric calculations.
  Returns: (bool) `true` if the period spans more than two months, `false` if it otherwise spans more
than two days, and `na` if the data is insufficient.

getPeriodicReturns(percentChange, maxPeriods)
  (Overload 1 of 2) Tracks periodic return percentages and queues them into an array for ratio
calculations. The span of the chart's historical data determines whether the function uses
daily or monthly periods in its calculations. If the chart spans more than two months,
it uses "1M" periods. Otherwise, if the chart spans more than two days, it uses "1D"
periods. If the chart covers less than two days, it does not store changes.
  Parameters:
    percentChange (float): (series float) The change percentage. The function compounds non-na values from each
chart bar within monthly or daily periods to calculate the periodic changes.
    maxPeriods (simple int): (simple int) The maximum number of periodic returns to store in the returned array.
  Returns: (array<float>) An array containing the overall percentage changes for each period, limited
to the maximum specified by `maxPeriods`.

getPeriodicReturns(percentChange, benchmark, maxPeriods)
  (Overload 2 of 2) Tracks periodic excess return percentages and queues the values into an
array. The span of the chart's historical data determines whether the function uses
daily or monthly periods in its calculations. If the chart spans more than two months,
it uses "1M" periods. Otherwise, if the chart spans more than two days, it uses "1D"
periods. If the chart covers less than two days, it does not store changes.
  Parameters:
    percentChange (float): (series float) The change percentage. The function compounds non-na values from each
chart bar within monthly or daily periods to calculate the periodic changes.
    benchmark (float): (series float) The benchmark percentage to compare against `percentChange` values.
The function compounds non-na values from each bar within monthly or
daily periods and subtracts the results from the compounded `percentChange` values to
calculate the excess returns. For consistency, ensure this series has a similar history
length to the `percentChange` with aligned non-na value times.
    maxPeriods (simple int): (simple int) The maximum number of periodic excess returns to store in the returned array.
  Returns: (array<float>) An array containing monthly or daily excess returns, limited
to the maximum specified by `maxPeriods`.

method sharpeRatio(returnsArray, annualBenchmark, forceCalc, periodsPerYear)
  Calculates the Sharpe ratio for an array of periodic returns.
Callable as a method or a function.
  Namespace types: array<float>
  Parameters:
    returnsArray (array<float>): (array<float>) An array of periodic return percentages, e.g., returns over monthly or
daily periods.
    annualBenchmark (float): (series float) The annual rate of return to compare against `returnsArray` values. When
`periodsPerYear` is `na`, the function divides this value by 12 to calculate a
monthly benchmark if the chart's data spans at least two months or 365 for a daily
benchmark if the data otherwise spans at least two days. If `periodsPerYear`
has a specified value, the function divides the rate by that value instead.
    forceCalc (bool): (series bool) If `true`, calculates the ratio on every call. Otherwise, ratio calculation
only occurs on the last available bar. Optional. The default is `false`.
    periodsPerYear (simple int): (simple int) If specified, divides the annual rate by this value instead of the value
determined by the time span of the chart's data.
  Returns: (float) The Sharpe ratio, which estimates the excess return per unit of total volatility.

method sortinoRatio(returnsArray, annualBenchmark, forceCalc, periodsPerYear)
  Calculates the Sortino ratio for an array of periodic returns.
Callable as a method or a function.
  Namespace types: array<float>
  Parameters:
    returnsArray (array<float>): (array<float>) An array of periodic return percentages, e.g., returns over monthly or
daily periods.
    annualBenchmark (float): (series float) The annual rate of return to compare against `returnsArray` values. When
`periodsPerYear` is `na`, the function divides this value by 12 to calculate a
monthly benchmark if the chart's data spans at least two months or 365 for a daily
benchmark if the data otherwise spans at least two days. If `periodsPerYear`
has a specified value, the function divides the rate by that value instead.
    forceCalc (bool): (series bool) If `true`, calculates the ratio on every call. Otherwise, ratio calculation
only occurs on the last available bar. Optional. The default is `false`.
    periodsPerYear (simple int): (simple int) If specified, divides the annual rate by this value instead of the value
determined by the time span of the chart's data.
  Returns: (float) The Sortino ratio, which estimates the excess return per unit of downside
volatility.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

// @version=6
library("RiskMetrics")

// RiskMetrics Library
// v3, 2025.03.26

// This code was written using the recommendations from the Pine Script® User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



//#region ———————————————————— Library functions


// @function                Adds a new `value` at the end of an `id` array, then removes the array's first element 
//                          if its size exceeds the specified `maxSize`. 
// @param id                (array<any type>) An array of any type to queue a new `value` into.
// @param maxSize           (simple int) The maximum size of the `id` array.
// @param value             (<type of the array's elements>) The value of the element pushed into the `id` array.
// @returns                 (<type of the array's elements>) The de-queued element value.
arrayQueue(id, int maxSize, value) =>
    id.push(value)
    if id.size() > maxSize
        id.shift()


// @function                Converts a UNIX timestamp in milliseconds to the total number of whole months since 
//                          midnight UTC on January 1, 1970.
// @param t                 (series int) The UNIX timestamp to evaluate.
// @returns                 (int) The total number of months elapsed from January 1, 1970 to the `t` timestamp.
months(series int t) =>
    int result = (year(t, "UTC") - 1970) * 12 + month(t, "UTC") - 1


// @function                (Overload 1 of 2) Tracks monthly return percentages and queues them into an array for ratio  
//                          calculations. 
// @param percentChange     (series float) The change percentage. The function compounds non-na values from each 
//                          chart bar within monthly periods to calculate the periodic changes. 
// @param maxPeriods        (simple int) The maximum number of monthly returns to store in the returned array.
// @returns                 (array<float>) An array containing the overall percentage changes for each month, limited 
//                          to the maximum specified by `maxPeriods`.
export getPeriodicReturns(series float percentChange, simple int maxPeriods) =>
    var array<float> result = array.new<float>()
    var bool   chartHasHistory = false
    var float  base         = 100.0
    var bool   isIntramonth = timeframe.in_seconds() <= timeframe.in_seconds("1M")
    bool       isNewPeriod  = ta.change(fixnan(time("1M", session = session.regular))) != 0
    int        monthChanges = na(time[1]) or isIntramonth ? 0 : months(time) - months(time[1])
    if not na(percentChange)
        base *= 1.0 + (percentChange / 100.0)
        chartHasHistory := true
    if isNewPeriod
        if chartHasHistory
            if monthChanges > 1
                for _ = 2 to monthChanges
                    arrayQueue(result, maxPeriods, 0.0)
            float periodicChange = base - 100.0
            arrayQueue(result, maxPeriods, periodicChange)
        base := 100.0
    result


// @function                (Overload 2 of 2) Tracks monthly excess return percentages and queues the values into an 
//                          array. 
// @param percentChange     (series float) The change percentage. The function compounds non-na values from each 
//                          chart bar within monthly periods to calculate the periodic changes. 
// @param benchmark         (series float) The benchmark percentage to compare against `percentChange` values. 
//                          The function compounds non-na values from each bar within monthly 
//                          periods and subtracts the results from the compounded `percentChange` values to 
//                          calculate the excess returns. For consistency, ensure this series has a similar history 
//                          length to the `percentChange` with aligned non-na value times. 
// @param maxPeriods        (simple int) The maximum number of monthly excess returns to store in the returned array.
// @returns                 (array<float>) An array containing monthly excess returns, limited 
//                          to the maximum specified by `maxPeriods`.
export getPeriodicReturns(series float percentChange, series float benchmark, simple int maxPeriods) =>
    var array<float> result = array.new<float>() 
    var bool   benchHasHistory = false
    var bool   chartHasHistory = false
    var float  base1        = 100.0
    var float  base2        = 100.0
    var bool   isIntramonth = timeframe.in_seconds() <= timeframe.in_seconds("1M")
    bool       isNewPeriod  = ta.change(fixnan(time("1M", session = session.regular))) != 0 
    int        monthChanges = na(time[1]) or isIntramonth ? 0 : months(time) - months(time[1])
    if not na(percentChange)
        base1 *= 1.0 + (percentChange / 100.0)
        chartHasHistory := true
    if not na(benchmark)
        base2 *= 1.0 + (benchmark / 100.0)
        benchHasHistory := true
    if isNewPeriod 
        if chartHasHistory and benchHasHistory 
            if monthChanges > 1
                for _ = 2 to monthChanges
                    arrayQueue(result, maxPeriods, 0.0)
            float periodicExcess = base1 - base2
            arrayQueue(result, maxPeriods, periodicExcess)
        base1 := 100.0
        base2 := 100.0
    result


// @function                Calculates the downside deviation of an array of `returns` compared to a `targetReturn`. 
//                          Callable as a method or a function.
// @param returns           (array<float>) An array containing the sequence of returns to analyze. 
// @param targetReturn      (series float) The benchmark return to compare against each value in the `returns` array.
// @returns                 (float) The downside deviation of compared returns, i.e., the volatility of all `returns` 
//                          values below the `targetReturn`.
method downsideDeviation(array<float> returns, series float targetReturn) =>
    float sum = 0.0
    for r in returns
        if r >= targetReturn
            continue
        sum += math.pow(r - targetReturn, 2)
    sum /= returns.size()
    float result = math.sqrt(sum)


// @function                Calculates the Sharpe ratio for an array of periodic returns.  
//                          Callable as a method or a function.
// @param returnsArray      (array<float>) An array of periodic return percentages, e.g., returns over monthly periods. 
// @param annualBenchmark   (series float) The annual rate of return to compare against `returnsArray` values. When 
//                          `periodsPerYear` is `na`, the function divides this value by 12 to calculate a 
//                          monthly benchmark. If `periodsPerYear` has a specified value, the function divides the rate
//                          by that value instead.
// @param forceCalc         (series bool) If `true`, calculates the ratio on every call. Otherwise, ratio calculation 
//                          only occurs on the last available bar. Optional. The default is `false`.
// @param periodsPerYear    (simple int) If specified, divides the annual rate by this value instead of the value  
//                          determined by the time span of the chart's data.
// @returns                 (float) The Sharpe ratio, which estimates the excess return per unit of total volatility. 
export method sharpeRatio( 
     array<float> returnsArray, series float annualBenchmark, series bool forceCalc = false, 
     simple int periodsPerYear = na 
 ) => 
    var int numberOfperiods = nz(periodsPerYear, 12)
    if barstate.islast or forceCalc
        float fixedPeriodReturn = annualBenchmark / numberOfperiods
        float standardDev       = returnsArray.stdev()
        float avgReturn         = returnsArray.avg()
        float result            = (avgReturn - fixedPeriodReturn) / standardDev
        


// @function                Calculates the Sortino ratio for an array of periodic returns.
//                          Callable as a method or a function.
// @param returnsArray      (array<float>) An array of periodic return percentages, e.g., returns over monthly periods. 
// @param annualBenchmark   (series float) The annual rate of return to compare against `returnsArray` values. When 
//                          `periodsPerYear` is `na`, the function divides this value by 12 to calculate a 
//                          monthly benchmark. If `periodsPerYear` has a specified value, the function divides the rate
//                          by that value instead.
// @param forceCalc         (series bool) If `true`, calculates the ratio on every call. Otherwise, ratio calculation 
//                          only occurs on the last available bar. Optional. The default is `false`.
// @param periodsPerYear    (simple int) If specified, divides the annual rate by this value instead of the value  
//                          determined by the time span of the chart's data.
// @returns                 (float) The Sortino ratio, which estimates the excess return per unit of downside 
//                          volatility.
export method sortinoRatio( 
     array<float> returnsArray, series float annualBenchmark, series bool forceCalc = false, 
     simple int periodsPerYear = na 
 ) => 
    var int numberOfperiods = nz(periodsPerYear, 12)
    if barstate.islast or forceCalc
        float fixedPeriodReturn = annualBenchmark / numberOfperiods
        float downsideDev       = returnsArray.downsideDeviation(fixedPeriodReturn)
        float avgReturn         = returnsArray.avg()
        float result            = (avgReturn - fixedPeriodReturn) / downsideDev 
//#endregion



//#region ———————————————————— Example Code


// Specify the timeframe of the returns, the annual benchmark percentage, and the max number of periods to analyze.
string tfInput         = input.timeframe("1M", "Returns timeframe") 
float  percentageInput = input.float(2,        "Benchmark percentage (Annual)", minval = 0) 
int    numOfTFsInput   = input.int(60,         "Max no. of periods used") 

// @variable `true` if the selected timeframe is higher than the current chart's timeframe. 
var bool isHtf = timeframe.in_seconds(tfInput) > timeframe.in_seconds()

// @variable The one-bar arithmetic `close` return. Calculates the return from `open` to `close` on the first bar.
float returnPercent = nz(ta.roc(close, 1), 100.0 * (close - open) / open)
// @variable The last confirmed `returnPercent` value from the `tfInput` timeframe with gaps. 
float htfReturn = request.security(syminfo.tickerid, tfInput, returnPercent[1], barmerge.gaps_on, barmerge.lookahead_on)
// @variable The chart symbol's sampled percent change value.
float changeValue = isHtf ? htfReturn : returnPercent

// @variable An array of periodic returns over up to the specified number of periods.
array<float> periodicReturns = getPeriodicReturns(changeValue, numOfTFsInput)
// @variable The Sharpe ratio of the `periodicReturns` based on the benchmark percentage. 
float sharpe = sharpeRatio(periodicReturns,  percentageInput)
// @variable The Sortino ratio of the `periodicReturns` based on the benchmark percentage. 
float sortino = sortinoRatio(periodicReturns, percentageInput)

// Raise an error if the `tfInput` is smaller than the chart's timeframe.
if timeframe.in_seconds(tfInput) < timeframe.in_seconds()
    runtime.error("For accurate ratios, the requested TF must be greater than or equal to the TF of the chart.")

// Plot the `changeValue` series with masked `na` values and fill the space between it and 0 with the `plotColor`.
float plotValue = fixnan(changeValue)
color plotColor = not na(changeValue) and isHtf ? color(na) : plotValue < 0.0 ? color.orange : color.aqua
changePlot      = plot(plotValue, "Sampled price return",  plotColor, precision = 2, format = format.percent)
zeroPlot        = plot(0,         "Zero level",          color.new(color.gray, 60))
fill(changePlot, zeroPlot, color.new(plotColor, 80), "Price return fill")

// Display the base period, number of periods, returns timeframe, and the calculated ratios in a table on the last bar.
if barstate.islast
    var table tfDisplay = table.new(position.bottom_right, 1, 1)
    string periodStr = "1M" 
    string tableTxt  = str.format(
         "Calculation base period:  {0}
         \n# of calculation periods: {1}
         \nReturns timeframe:        {2}
         \nSharpe ratio:             {3}
         \nSortino ratio:            {4}",
         periodStr, periodicReturns.size(), 
         tfInput == "" ? (timeframe.isdwm and timeframe.multiplier == 1 ? "1" : "") + timeframe.period : tfInput, 
         str.tostring(sharpe, "#.#####"), str.tostring(sortino, "#.#####")
     )
    table.cell(
         tfDisplay, 0, 0, tableTxt, bgcolor = color(na), text_color = chart.fg_color, text_size = size.normal,
         text_halign = text.align_left, text_font_family = font.family_monospace
     )
//#endregion
````
