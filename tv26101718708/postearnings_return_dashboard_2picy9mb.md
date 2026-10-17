# Post-Earnings Return Dashboard

- url: https://www.tradingview.com/script/2PicY9mb-Post-Earnings-Return-Dashboard/
- type: indicator
- pine_id: PUB;f108a0996b234c96b3eb7fc6129256a3
- version: 1.0

## Description

[b]Post-Earnings Return Dashboard[/b]

Post-Earnings Return Dashboard is designed to show how a stock has historically performed after earnings reports.

The script automatically detects earnings events using TradingView’s built-in earnings data, calculates post-earnings returns over several periods, and displays the results in an on-chart dashboard.

[b]What the indicator measures[/b]

For each detected earnings report, the indicator calculates the stock’s return after:

1 trading session
5 trading sessions
10 trading sessions
20 trading sessions

The return is calculated using:

Return = Future closing price divided by the selected reference price, minus 1, multiplied by 100.

[b]Dashboard statistics[/b]

For each return period, the dashboard displays:

[b]Reports[/b] — the number of completed earnings observations included in the calculation

[b]Average[/b] — the average return across the selected earnings history

[b]Median[/b] — the middle result when all returns are arranged from lowest to highest

[b]Win rate[/b] — the percentage of earnings events that produced a positive return

A return of exactly 0% is not counted as a win.

The number of observations may differ between periods because the latest earnings report may not yet have completed the 10-session or 20-session measurement window.

[b]Latest row[/b]

The Latest row shows the completed returns following the most recently detected earnings report.

[b]1D[/b] — return after 1 trading session

[b]5D[/b] — return after 5 trading sessions

[b]10D[/b] — return after 10 trading sessions

[b]20D[/b] — return after 20 trading sessions

Once a measurement period has completed, its value is stored and does not continue changing.

If the latest earnings event occurred fewer than 20 sessions ago, some longer-period values may remain blank.

[b]Current row[/b]

The Current row shows the live return from the latest earnings reference price to the current closing price.

It also displays:

[b]Sessions[/b] — the number of trading sessions since the latest detected earnings report

[b]Ticker[/b] — the symbol currently displayed on the chart

For example, Current -4.42%, Sessions 17, TSM means the stock is currently trading 4.42% below its selected earnings reference price, 17 trading sessions after the latest report.

[b]EPS row[/b]

The bottom row displays information about the latest detected earnings event.

[b]EPS[/b] — the reported earnings per share

[b]Estimate[/b] — the analyst EPS estimate

[b]Last X[/b] — the maximum number of recent earnings reports included in the historical statistics

For example, EPS 4.221, Estimate 3.81, Last 12 means the company reported EPS of 4.221 against an estimate of 3.81, while the dashboard is configured to use up to the latest 12 earnings reports.

[b]Return starting price[/b]

The indicator provides two reference-price options.

[b]Previous close[/b]

Uses the closing price immediately before the earnings bar.

This is generally the most consistent option for measuring the full market reaction when the exact earnings-release timing is unknown.

[b]Earnings-bar close[/b]

Uses the closing price of the bar on which TradingView registers the earnings event.

This may be more appropriate when the report is known to have been released after that trading session closed.

[b]Historical sample size[/b]

Users can choose how many recent earnings reports are included in the statistics.

For a company reporting quarterly:

4 reports is approximately 1 year
8 reports is approximately 2 years
12 reports is approximately 3 years
20 reports is approximately 5 years

A smaller sample may better reflect recent behaviour, while a larger sample may provide a broader long-term view.

[b]Chart markers and labels[/b]

The indicator can optionally:

Mark earnings dates with an E symbol
Display historical post-earnings return labels
Show the selected 1, 5, 10, or 20-session return directly on the chart
Display reported and estimated EPS where available

These options can be disabled to keep the chart clean.

[b]Recommended timeframe[/b]

This indicator is designed for use on the daily chart.

The script counts chart bars as trading sessions.

On a daily chart:

1 bar equals 1 trading session
5 bars is approximately 1 trading week
20 bars is approximately 1 trading month

Using the indicator on an intraday chart will cause it to count intraday candles rather than trading days, which will produce misleading results.

[b]How to interpret the statistics[/b]

The statistics should be considered together rather than individually.

A positive average, positive median, and high win rate may indicate historically consistent post-earnings strength.

A positive average with a negative median may mean that a small number of large gains are distorting the average.

A high win rate with a low average may indicate frequent small gains but occasional large losses.

A low win rate with a positive average may indicate less frequent but much larger winning reactions.

A negative average and negative median may indicate persistent post-earnings weakness over the selected sample.

[b]Potential uses[/b]

This indicator may be useful for:

Reviewing a stock before an upcoming earnings report
Studying post-earnings announcement drift
Comparing the latest earnings reaction with previous reports
Assessing whether earnings gaps tend to continue or reverse
Identifying stocks with historically consistent earnings reactions
Supporting swing-trade research
Comparing post-earnings behaviour across different stocks
Evaluating whether holding after earnings has historically been favourable

[b]Data source[/b]

The script retrieves earnings information through TradingView’s built-in request.earnings function.

It uses:

Reported EPS
Estimated EPS
The earnings event bar supplied by TradingView

The indicator does not scrape company filings or external websites.

Results depend on the earnings and price history available for the selected symbol on TradingView.

[b]Limitations[/b]

TradingView does not consistently expose the precise release time for every earnings report.

The script may therefore be unable to determine whether an individual report was released before market open, during the trading session, or after market close.

This can affect which closing price most accurately represents the price immediately before the market received the information.

The indicator measures raw stock returns and does not currently adjust for overall market performance, sector performance, index movement, dividends, currency changes, volatility, earnings gap size, revenue surprises, or forward guidance.

A positive return does not necessarily mean the stock outperformed the wider market.

## Source Code

````pine
//@version=6
indicator(
     "Post-Earnings Return Dashboard",
     shorttitle = "Returns",
     overlay = true,
     max_labels_count = 300
)

//────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────

referenceMode = input.string(
     "Previous close",
     "Return starting price",
     options = ["Previous close", "Earnings-bar close"],
     tooltip =
         "Previous close measures the full reaction from the close before " +
         "the earnings date. Earnings-bar close is more suitable when the " +
         "reported earnings event is known to occur after that session."
)

historyLength = input.int(
     12,
     "Earnings reports in statistics",
     minval = 2,
     maxval = 40
)

showMarkers = input.bool(true, "Mark earnings")
showLabels  = input.bool(true, "Show event summaries")
showTable   = input.bool(true, "Show dashboard")

labelPeriod = input.string(
     "20 sessions",
     "Historical label return",
     options = [
         "1 session",
         "5 sessions",
         "10 sessions",
         "20 sessions"
     ]
)

//────────────────────────────────────────────────────
// Earnings data
//────────────────────────────────────────────────────

reportedEPS = request.earnings(
     syminfo.tickerid,
     earnings.actual,
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
)

estimatedEPS = request.earnings(
     syminfo.tickerid,
     earnings.estimate,
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
)

newEarnings = not na(reportedEPS)

//────────────────────────────────────────────────────
// Storage
//────────────────────────────────────────────────────

var array<float> returns1  = array.new_float()
var array<float> returns5  = array.new_float()
var array<float> returns10 = array.new_float()
var array<float> returns20 = array.new_float()

var float eventStartPrice = na
var float eventActualEPS  = na
var float eventEstimate   = na

var int eventBar      = na
var int sessionsAfter = na

var float latest1  = na
var float latest5  = na
var float latest10 = na
var float latest20 = na

//────────────────────────────────────────────────────
// Helper functions
//────────────────────────────────────────────────────

formatPercent(float value) =>
    na(value) ? "—" :
         (value > 0 ? "+" : "") +
         str.tostring(value, "#.##") + "%"

formatNumber(float value) =>
    na(value) ? "—" : str.tostring(value, "#.###")

resultColour(float value) =>
    na(value) ? color.gray :
         value >= 0 ? color.lime : color.red

limitedPush(array<float> values, float newValue, int maximumSize) =>
    array.push(values, newValue)

    if array.size(values) > maximumSize
        array.shift(values)

arrayAverage(array<float> values) =>
    array.size(values) == 0 ? na : array.avg(values)

arrayMedian(array<float> values) =>
    float result = na
    int count = array.size(values)

    if count > 0
        array<float> sortedValues = array.copy(values)
        array.sort(sortedValues, order.ascending)

        int middle = int(math.floor(count / 2))

        if count % 2 == 1
            result := array.get(sortedValues, middle)
        else
            float lower = array.get(sortedValues, middle - 1)
            float upper = array.get(sortedValues, middle)
            result := (lower + upper) / 2

    result

arrayWinRate(array<float> values) =>
    float result = na
    int count = array.size(values)

    if count > 0
        int winners = 0

        for index = 0 to count - 1
            if array.get(values, index) > 0
                winners += 1

        result := winners / count * 100

    result

returnFromStart(float startPrice) =>
    na(startPrice) ? na :
         (close / startPrice - 1) * 100

selectedLabelReturn() =>
    switch labelPeriod
        "1 session"   => latest1
        "5 sessions"  => latest5
        "10 sessions" => latest10
        => latest20

selectedLabelOffset() =>
    switch labelPeriod
        "1 session"   => 1
        "5 sessions"  => 5
        "10 sessions" => 10
        => 20

//────────────────────────────────────────────────────
// Start measuring a new event
//────────────────────────────────────────────────────

if newEarnings
    eventBar := bar_index
    sessionsAfter := 0

    eventActualEPS := reportedEPS
    eventEstimate := estimatedEPS

    eventStartPrice :=
         referenceMode == "Previous close" ?
         close[1] :
         close

    latest1  := na
    latest5  := na
    latest10 := na
    latest20 := na

else if not na(eventBar)
    sessionsAfter += 1

//────────────────────────────────────────────────────
// Calculate forward returns
//────────────────────────────────────────────────────

eventReturn = returnFromStart(eventStartPrice)

if not na(sessionsAfter)
    if sessionsAfter == 1
        latest1 := eventReturn
        limitedPush(returns1, latest1, historyLength)

    if sessionsAfter == 5
        latest5 := eventReturn
        limitedPush(returns5, latest5, historyLength)

    if sessionsAfter == 10
        latest10 := eventReturn
        limitedPush(returns10, latest10, historyLength)

    if sessionsAfter == 20
        latest20 := eventReturn
        limitedPush(returns20, latest20, historyLength)

//────────────────────────────────────────────────────
// Earnings markers
//────────────────────────────────────────────────────

plotshape(
     showMarkers and newEarnings,
     title = "Earnings report",
     style = shape.diamond,
     location = location.abovebar,
     color = color.orange,
     size = size.small,
     text = "E",
     textcolor = color.white
)

//────────────────────────────────────────────────────
// Historical event labels
//────────────────────────────────────────────────────

labelOffset = selectedLabelOffset()
labelValue  = selectedLabelReturn()

if showLabels and sessionsAfter == labelOffset and not na(labelValue)
    string surpriseText =
         not na(eventActualEPS) and not na(eventEstimate) ?
         "\nEPS: " +
         formatNumber(eventActualEPS) +
         " vs " +
         formatNumber(eventEstimate) :
         ""

    label.new(
         bar_index,
         high,
         labelPeriod +
         ": " +
         formatPercent(labelValue) +
         surpriseText,
         style = label.style_label_down,
         color = labelValue >= 0 ?
              color.new(color.green, 15) :
              color.new(color.red, 15),
         textcolor = color.white,
         size = size.small
    )

//────────────────────────────────────────────────────
// Statistics
//────────────────────────────────────────────────────

average1  = arrayAverage(returns1)
average5  = arrayAverage(returns5)
average10 = arrayAverage(returns10)
average20 = arrayAverage(returns20)

median1  = arrayMedian(returns1)
median5  = arrayMedian(returns5)
median10 = arrayMedian(returns10)
median20 = arrayMedian(returns20)

winRate1  = arrayWinRate(returns1)
winRate5  = arrayWinRate(returns5)
winRate10 = arrayWinRate(returns10)
winRate20 = arrayWinRate(returns20)

//────────────────────────────────────────────────────
// Dashboard
//────────────────────────────────────────────────────

var table dashboard = table.new(
     position.top_right,
     5,
     8,
     border_width = 1
)

setHeaderCell(int column, string headerText) =>
    table.cell(
         dashboard,
         column,
         0,
         headerText,
         bgcolor = color.new(color.blue, 65),
         text_color = color.white
    )

setStatisticRow(
     int row,
     string period,
     array<float> observations,
     float averageReturn,
     float medianReturn,
     float winRate
) =>
    table.cell(dashboard, 0, row, period)

    table.cell(
         dashboard,
         1,
         row,
         str.tostring(array.size(observations))
    )

    table.cell(
         dashboard,
         2,
         row,
         formatPercent(averageReturn),
         text_color = resultColour(averageReturn)
    )

    table.cell(
         dashboard,
         3,
         row,
         formatPercent(medianReturn),
         text_color = resultColour(medianReturn)
    )

    table.cell(
         dashboard,
         4,
         row,
         formatPercent(winRate),
         text_color = resultColour(winRate - 50)
    )

if barstate.islast
    if showTable
        setHeaderCell(0, "Period")
        setHeaderCell(1, "Reports")
        setHeaderCell(2, "Average")
        setHeaderCell(3, "Median")
        setHeaderCell(4, "Win rate")

        setStatisticRow(
             1,
             "1 session",
             returns1,
             average1,
             median1,
             winRate1
        )

        setStatisticRow(
             2,
             "5 sessions",
             returns5,
             average5,
             median5,
             winRate5
        )

        setStatisticRow(
             3,
             "10 sessions",
             returns10,
             average10,
             median10,
             winRate10
        )

        setStatisticRow(
             4,
             "20 sessions",
             returns20,
             average20,
             median20,
             winRate20
        )

        table.cell(
             dashboard,
             0,
             5,
             "Latest",
             bgcolor = color.new(color.gray, 75),
             text_color = color.white
        )

        table.cell(
             dashboard,
             1,
             5,
             "1D\n" + formatPercent(latest1),
             text_color = resultColour(latest1)
        )

        table.cell(
             dashboard,
             2,
             5,
             "5D\n" + formatPercent(latest5),
             text_color = resultColour(latest5)
        )

        table.cell(
             dashboard,
             3,
             5,
             "10D\n" + formatPercent(latest10),
             text_color = resultColour(latest10)
        )

        table.cell(
             dashboard,
             4,
             5,
             "20D\n" + formatPercent(latest20),
             text_color = resultColour(latest20)
        )

        table.cell(dashboard, 0, 6, "Current")
        table.cell(
             dashboard,
             1,
             6,
             formatPercent(eventReturn),
             text_color = resultColour(eventReturn)
        )

        table.cell(dashboard, 2, 6, "Sessions")
        table.cell(
             dashboard,
             3,
             6,
             na(sessionsAfter) ? "—" :
             str.tostring(sessionsAfter)
        )

        table.cell(dashboard, 4, 6, syminfo.ticker)

        table.cell(
             dashboard,
             0,
             7,
             "EPS",
             bgcolor = color.new(color.gray, 85)
        )

        table.cell(
             dashboard,
             1,
             7,
             formatNumber(eventActualEPS)
        )

        table.cell(
             dashboard,
             2,
             7,
             "Estimate",
             bgcolor = color.new(color.gray, 85)
        )

        table.cell(
             dashboard,
             3,
             7,
             formatNumber(eventEstimate)
        )

        table.cell(
             dashboard,
             4,
             7,
             "Last " + str.tostring(historyLength)
        )

    else
        table.clear(dashboard, 0, 0, 4, 7)
````
