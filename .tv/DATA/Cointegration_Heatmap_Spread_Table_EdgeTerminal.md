<!-- tradingview-pine-id: PUB;80af7ccf6183453bbd07864e7e8f5947 -->
<!-- tradingviewscripts-format: 1 -->
# Cointegration Heatmap & Spread Table [EdgeTerminal]

Source: https://www.tradingview.com/script/Vt3jBShj-Cointegration-Heatmap-Spread-Table-EdgeTerminal/

## Description

The Cointegration Heatmap is a powerful visual and quantitative tool designed to uncover deep, statistically meaningful relationships between assets. 

Unlike traditional indicators that react to price movement, this tool analyzes the underlying statistical relationship between two time series and tracks when they diverge from their long-term equilibrium — offering actionable signals for mean-reversion trades.

What Is Cointegration?
Most traders are familiar with correlation, which measures how two assets move together in the short term. But correlation is shallow — it doesn’t imply a stable or predictable relationship over time.

Cointegration, however, is a deeper statistical concept: Two assets are cointegrated if a linear combination of their prices or returns is stationary, even if the individual series themselves are non-stationary.

Cointegration is a foundational concept in time series analysis, widely used by hedge funds, proprietary trading firms, and quantitative researchers. This indicator brings that institutional-grade concept into an easy-to-use and fully visual TradingView indicator.

This tool helps answer key questions like:
“Which stocks tend to move in sync over the long term?”
“When are two assets diverging beyond statistical norms?”
“Is now the right time to short one and long the other?”

Using a combination of regression analysis, residual modeling, and Z-score evaluation, this indicator surfaces opportunities where price relationships are stretched and likely to snap back — making it ideal for building low-risk, high-probability trade setups.

In simple terms:
Cointegrated assets drift apart temporarily, but always come back together over time. This behavior is the foundation of successful pairs trading.

How the Indicator Works
Cointegration Heatmap indicator works across any market supported on TradingView — from stocks and ETFs to cryptocurrencies and forex pairs.

You enter your list of symbols, choose a timeframe, and the indicator updates every bar with live cointegration scores, spread signals, and trade-ready insights.

Indicator Settings:
Symbol list: a customizable list of symbols separated by commas
Returns timeframe: time frame selection for return sampling (Weekly or Monthly)
Max periods: max periods to limit the data to a certain time and to control indicator performance

This indicator accomplishes three major goals in one streamlined package:
Identifies stable long-term relationships (cointegration) between assets, using a heatmap visualization.
Tracks the spread — the difference between actual prices and the predicted linear relationship — between each pair.
Generates trade signals based on Z-score deviations from the mean spread, helping traders know when a pair is statistically overextended and likely to mean revert.

The math:
Returns are calculated using spread tickers to ensure alignment in time and adjust for dividends, splits, and other inconsistencies.

For each unique pair of symbols, we perform a linear regression
Yt​=α+βXt​+ε

Then we compute the residuals (errors from the regression):
Spreadt​=Yt​−(α+βXt​)

Calculate the standard deviation of the spread over a moving window (default: 100 samples) and finally, define the Cointegration Score:
S=1/Standard Deviation of Residuals

This means, the lower the deviation, the tighter the relationship, so higher scores indicate stronger cointegration.

Always remember that cointegration can break down so monitor the asset over time and over multiple different timeframes before making a decision.

How to use the indicator

The heatmap table:
The indicator displays 2 very important tables, one in the middle and one on the right side. After entering your symbols, the first table to pay attention to is the middle heatmap table. 

Any assets with a cointegration value of 25% is something to pay attention to and have a strong and stable relationship. Anything below is weak and not tradable.

Additionally, the 40% level is another important line to cross. Assets that have a cointegration score of over 40% will most likely have an extremely strong relationship.

Think about it this way, the higher the percentage, the tighter and more statistically reliable the relationship is.

The spread table:

After finding a good asset pair using heatmap, locate the same pair in the spread table (right side).

Here’s what you’ll see on the table:

Spread: Current difference between the two symbols based on the regression fit
Mean: Historical average of that spread
Z-score: How far current spread is from the mean in standard deviations
Signal: Trade suggestion: Short, Long, or Neutral

Since you’re expecting mean reversion, the idea is that the spread will return to the average. You want to take a trade when the z-score is either over +2 or below -2 and exit when z-score returns to near 0.

You will usually see the trade suggestion on the spread chart but you can make your own decision based on your risk level.

Keep in mind that the Z-score for each pair refers to how off the first asset is from the mean compared to the second one, so for example if you see STOCKA vs STOCKB with a Z-score of -1.55, we are regressing STOCKB (Y) on STOCKA (X).

In this case, STOCKB is the quoted asset and STOCKA is the base asset. 

In this case, this means that STOCKB is much lower than expected relative to STOCKA, so the trade would be a long position on stock B and short position on stock A.

---

## Source Code

````pine
//@version=6
indicator("Cointegration Heatmap & Spread Table [EdgeTerminal]", overlay = false)

import TradingView/ta/9 as TVta
import TradingView/ValueAtTime/1 as TVvt

// Inputs
string symbolListInput = input.text_area("XLC, FDIS, XRT, FXD, RXI, RSPD, CSCO, STE", "Symbol list")
string tfInput         = input.timeframe("1M", "Returns timeframe", ["1W", "1M"])
bool limitInput        = input.bool(false, "Max periods")
int  maxPeriodsInput   = input.int(60, "", minval = 2)

// Parse symbols
var array<string> symbolsArray = TVvt.getArrayFromString(str.upper(symbolListInput))
var int numSymbols = symbolsArray.size()

// Utility: Aligned returns
getAlignedReturns(series string symbol, series string timeframe) =>
    string chartTicker = ticker.new(syminfo.prefix, syminfo.tickerid)
    string standard1   = ticker.standard(chartTicker)
    string standard2   = ticker.standard(symbol)
    string sumSpread = ticker.modify(ticker.inherit(chartTicker, standard1 + "+" + standard2), session.extended, adjustment.dividends)
    string diffSpread = ticker.modify(ticker.inherit(chartTicker, standard1 + "-" + standard2), session.extended, adjustment.dividends)
    float currPrice   = close[1]
    float prevPrice   = nz(close[2], open[1])
    [currSum, prevSum] = request.security(sumSpread, timeframe, [currPrice, prevPrice], barmerge.gaps_on, barmerge.lookahead_on)
    [currDiff, prevDiff] = request.security(diffSpread, timeframe, [currPrice, prevPrice], barmerge.gaps_on, barmerge.lookahead_on)
    TVta.changePercent(0.5 * (currSum - currDiff), 0.5 * (prevSum - prevDiff))

// Collect returns into matrix
collectReturns(array<string> symbols, simple string timeframe, simple int maxPeriods = na) =>
    var int num = symbols.size()
    var array<float> row = array.new<float>(num)
    var matrix<float> result = matrix.new<float>(num, 0)
    bool exclude = false
    for [i, sym] in symbols
        float ret = getAlignedReturns(sym, timeframe)
        if na(ret)
            exclude := true
            break
        row.set(i, ret)
    int cols = result.columns()
    if not exclude
        result.add_col(cols, row)
        cols += 1
    if cols > maxPeriods
        result.remove_col(0)
    result

// Get residual std deviation as cointegration strength proxy
getResidualStd(array<float> x, array<float> y) =>
    int len = math.min(x.size(), y.size())
    if len < 2
        na
    else
        float meanX = x.avg(), meanY = y.avg()
        float covXY = 0.0, varX = 0.0
        for i = 0 to len - 1
            float dx = x.get(i) - meanX
            float dy = y.get(i) - meanY
            covXY += dx * dy
            varX  += dx * dx
        float beta = covXY / varX
        float alpha = meanY - beta * meanX
        array<float> residuals = array.new<float>()
        int maxResiduals = 100
        int start = math.max(0, len - maxResiduals)
        for i = start to len - 1
            float resid = y.get(i) - (alpha + beta * x.get(i))
            array.push(residuals, resid)
        residuals.stdev()

// Build matrix
matrix<float> returnsMatrix = collectReturns(symbolsArray, tfInput, limitInput ? maxPeriodsInput : na)
var table heatmap = table.new(position.middle_center, numSymbols + 1, numSymbols + 1, border_width = 1)

// Draw headers
for i = 0 to numSymbols - 1
    string sym = symbolsArray.get(i)
    table.cell(heatmap, i + 1, 0, sym, text_color=color.white, bgcolor=color.gray)
    table.cell(heatmap, 0, i + 1, sym, text_color=color.white, bgcolor=color.gray)

// Fill heatmap table
for i = 0 to numSymbols - 1
    for j = 0 to numSymbols - 1
        string label = i == j ? "—" : ""
        color bg = color.new(color.black, 0)
        if i < j and returnsMatrix.columns() > 1
            array<float> x = returnsMatrix.row(i)
            array<float> y = returnsMatrix.row(j)
            float std = getResidualStd(x, y)
            float score = 1 / std  // Lower residual std = stronger cointegration
            label := str.tostring(score, format.percent)
            float scale = math.min(score * 1000, 100)
            bg := color.from_gradient(scale, 0, 100, color.rgb(30,30,30), color.rgb(0, 200, 0))
        table.cell(heatmap, j + 1, i + 1, label, text_color=color.white, bgcolor=bg)

// Cointegration spread summary table for all pairs
int maxPairs = numSymbols * (numSymbols - 1) / 2
var table spreadStatsTable = table.new(position.middle_right, 5, maxPairs + 1, border_width = 1)

// Header row
color headerColor = color.rgb(90, 90, 100)
color rowColor    = color.rgb(20, 20, 20)
color textColor   = color.white

table.cell(spreadStatsTable, 0, 0, "Pair",    text_color=textColor, bgcolor=headerColor)
table.cell(spreadStatsTable, 1, 0, "Spread",  text_color=textColor, bgcolor=headerColor)
table.cell(spreadStatsTable, 2, 0, "Mean",    text_color=textColor, bgcolor=headerColor)
table.cell(spreadStatsTable, 3, 0, "Z-score", text_color=textColor, bgcolor=headerColor)
table.cell(spreadStatsTable, 4, 0, "Signal",  text_color=textColor, bgcolor=headerColor)

// Fill rows with stats per unique pair
int row = 1
for i = 0 to numSymbols - 2
    for j = i + 1 to numSymbols - 1
        if returnsMatrix.columns() > 1
            array<float> x = returnsMatrix.row(i)
            array<float> y = returnsMatrix.row(j)
            int len = math.min(x.size(), y.size())
            float meanX = x.avg(), meanY = y.avg()
            float covXY = 0.0, varX = 0.0
            for k = 0 to len - 1
                float dx = x.get(k) - meanX
                float dy = y.get(k) - meanY
                covXY += dx * dy
                varX  += dx * dx
            float beta  = covXY / varX
            float alpha = meanY - beta * meanX
            float latestSpread = y.get(len - 1) - (alpha + beta * x.get(len - 1))
            float spreadSum = 0.0
            float spreadSq  = 0.0
            int maxPoints = 100
            int start = math.max(0, len - maxPoints)
            for k = start to len - 1
                float s = y.get(k) - (alpha + beta * x.get(k))
                spreadSum += s
                spreadSq  += s * s
            float meanSpread = spreadSum / (len - start)
            float variance = (spreadSq / (len - start)) - math.pow(meanSpread, 2)
            float stdevSpread = math.sqrt(variance)
            float zScore = (latestSpread - meanSpread) / stdevSpread
            string signal = zScore > 2 ? "Short" : zScore < -2 ? "Long" : "Neutral"
            string pairName = symbolsArray.get(i) + " vs " + symbolsArray.get(j)
            table.cell(spreadStatsTable, 0, row, pairName, text_color=textColor, bgcolor=rowColor)
            table.cell(spreadStatsTable, 1, row, str.tostring(latestSpread, format.mintick), text_color=textColor, bgcolor=rowColor)
            table.cell(spreadStatsTable, 2, row, str.tostring(meanSpread, format.mintick), text_color=textColor, bgcolor=rowColor)
            
            table.cell(spreadStatsTable,3, row,str.tostring(zScore, format.mintick),text_color = textColor,bgcolor = rowColor,tooltip = "Z > 2: Short quote, Long base\nZ < -2: Long quote, Short base\nZ ~ 0: Exit / No trade")

            table.cell(spreadStatsTable, 4, row, signal, text_color=textColor, bgcolor=rowColor)
            row += 1
````
