<!-- tradingview-pine-id: PUB;fcc890b26f8e4a29bf26f2f17eee5ad2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Weekday Return Distribution [Pineify]

Source: https://www.tradingview.com/script/eKgzrEPP-Weekday-Return-Distribution-Pineify/

## Description

Weekday Return Distribution [Pineify]

Overview
This day-of-week seasonality indicator keeps bounded samples for all seven days on 1D-1W charts. It reports median return, interquartile range (IQR), positive-return rate, and sample count.

Problem Definition
A weekday mean can be raised by one extreme gap even when most observations are negative. The same mean can describe a tight cluster or a wide distribution, and it does not reveal whether the sample has six cases or sixty. This creates false precision. This script separates robust location, middle spread, sign balance, and evidence quantity. It describes historical conditioning, not the next return.

Design Rationale
Median replaces the mean because rank location is less sensitive to outliers. Q1 and Q3 describe the middle half without assuming a Gaussian sample. Positive-return rate tests whether direction is broadly shared, while N stops thin samples from receiving full authority. A lifetime sample can preserve obsolete regimes, while a short one makes quantiles jump. Bounded memory trades stability for adaptation. A requested daily context lets weekly charts inherit weekday statistics instead of calling a weekly return Monday data.

Key Features

[*]Seven bounded weekday buckets with optional weekend exclusion.
[*]Median, interpolated Q1/Q3, positive-return rate, and N.
[*]Rotating IQR band, median track, reliability opacity, and table.
[*]Joint bias gates, three alerts, and switchable layers.

How It Works
The engine runs in a requested 1D context. At a new daily bar, it calculates the previous completed log return as 100 x ln(previous close / earlier close) and assigns it to the weekday where that return ended. The live return is excluded; weekends are optional.

Each bucket keeps at most the chosen limit, removing its oldest excess value. A copied bucket is sorted. Q1, median, and Q3 are linearly interpolated at 25%, 50%, and 75%. Positive rate is the share strictly above zero, and N is the actual count.

The latest daily weekday selects the pane row. Gold bounds show Q1-Q3 and the thick line shows median percent return. Interpretation begins when N reaches the minimum. Positive bias requires median and positive rate to pass both positive thresholds; negative bias applies symmetric gates. Disagreement is Mixed; insufficient evidence is Wait. Teal, coral, and gray encode state, and opacity shows maturity.

How Multiple Indicators Work Together
All components measure one distribution. Median supplies location, Q1/Q3 supplies spread, positive rate checks sign participation, and N governs eligibility. The state is conjunctive: without spread uncertainty is hidden; without sign balance a few large returns can dominate; without N a sparse day looks mature. Band, line, color, and table share the same samples.

Trading Ideas and Insights
Use this as scheduling context, not an entry command. A positive median inside a narrow IQR with a high positive rate is more consistent than the same median inside a wide band. Compare days within one symbol and sample policy because assets have different scales. No state estimates profit or next-bar probability.

Unique Aspects
Common weekday tools show one mean or static rank. Here each day owns a bounded queue, the pane rotates through robust location and IQR, and sign participation plus N controls a separate state. Returns stay in percentage units. Only a previous completed daily return is inserted. Weekly charts reuse the daily engine, preserving the definition across 1D-1W.

How to Use
Start on a standard 1D chart and load enough history for each active day to reach minimum N. Read the thick line as median and the gold band as the middle 50% for the highlighted weekday. In the table, Pos or Neg means both gates pass; Mix means mature disagreement; Wait means insufficient evidence. Alerts report state entry or lost reliability, not orders.

Customization
Maximum samples sets memory from 12 to 104 observations per day. Larger values are smoother but slower; smaller values adapt faster. Minimum samples controls readiness. Median magnitude filters effects near zero, and Positive-return threshold sets sign participation with a symmetric negative rule. IQR, halo, background, marker, and table can be hidden without changing calculations. Defaults are not universal optima.

Assumptions and Limitations
This is descriptive seasonality, not causal evidence. Returns include sessions, gaps, feed adjustments, and chart construction. Holidays, missing bars, and calendar changes make buckets unequal; revisions can alter history. Quantiles lag regimes and depend on window settings. Positive rate ignores magnitude; IQR omits tails. On weekly charts, TradingView maps the latest daily context into each bar, so coverage and live timing depend on loaded history and access. Weekday and alerts advance with daily context. Use standard 1D-1W charts; other timeframes are invalid. No future access, backtest, costs, or execution model is included.

Conclusion
Weekday Return Distribution replaces a fragile average with a bounded distribution view. Median shows location, IQR shows middle spread, positive rate shows participation, and N controls readiness, keeping uncertainty and data boundaries visible.

---

## Source Code

````pine
//@version=6
indicator("Weekday Return Distribution [Pineify]", overlay = false, max_bars_back = 5000, precision = 3)

// Independent implementation. Every bucket receives only the previous completed daily return.
// The requested daily context lets 1D-1W charts share one weekday sample engine.
int samplesPerDay = input.int(52, "Maximum samples per weekday", minval = 12, maxval = 104, group = "Distribution")
int minimumSamples = input.int(16, "Minimum samples for bias", minval = 5, maxval = 52, group = "Distribution")
bool includeWeekends = input.bool(true, "Include Saturday and Sunday", group = "Distribution")
float medianThreshold = input.float(0.05, "Minimum median magnitude (%)", minval = 0.0, maxval = 2.0, step = 0.01, group = "Bias condition")
float positiveRateThreshold = input.float(60.0, "Positive-return threshold (%)", minval = 50.0, maxval = 90.0, step = 1.0, group = "Bias condition")
bool showIqrBand = input.bool(true, "Show interquartile band", group = "Visuals")
bool showHalo = input.bool(true, "Show median reliability halo", group = "Visuals")
bool showBackground = input.bool(true, "Show bias background", group = "Visuals")
bool showCurrentMarker = input.bool(true, "Show current weekday marker", group = "Visuals")
bool showTable = input.bool(true, "Show seven-day distribution table", group = "Visuals")
color positiveColor = input.color(#008C86, "Positive-bias color", group = "Colors")
color negativeColor = input.color(#D35E4B, "Negative-bias color", group = "Colors")
color neutralColor = input.color(#7B8495, "Neutral color", group = "Colors")
color quartileColor = input.color(#B58A26, "Interquartile color", group = "Colors")

f_clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

f_quantile(array<float> sortedValues, float probability) =>
    int count = array.size(sortedValues)
    float result = na
    if count > 0
        float position = (count - 1) * probability
        int lowerIndex = int(math.floor(position))
        int upperIndex = int(math.ceil(position))
        float lowerValue = array.get(sortedValues, lowerIndex)
        float upperValue = array.get(sortedValues, upperIndex)
        float weight = position - lowerIndex
        result := lowerValue + (upperValue - lowerValue) * weight
    result

f_stats(array<float> values) =>
    int count = array.size(values)
    float median = na
    float firstQuartile = na
    float thirdQuartile = na
    float positiveRate = na
    if count > 0
        array<float> sortedValues = array.copy(values)
        array.sort(sortedValues, order.ascending)
        median := f_quantile(sortedValues, 0.50)
        firstQuartile := f_quantile(sortedValues, 0.25)
        thirdQuartile := f_quantile(sortedValues, 0.75)
        int positiveCount = 0
        for index = 0 to count - 1
            positiveCount += array.get(values, index) > 0.0 ? 1 : 0
        positiveRate := 100.0 * positiveCount / count
    [median, firstQuartile, thirdQuartile, positiveRate, float(count)]

f_addSample(array<float> values, float newValue, int sampleLimit) =>
    array.push(values, newValue)
    if array.size(values) > sampleLimit
        array.shift(values)

f_dailyEngine(int sampleLimit, bool keepWeekends) =>
    var array<float> sundayValues = array.new<float>()
    var array<float> mondayValues = array.new<float>()
    var array<float> tuesdayValues = array.new<float>()
    var array<float> wednesdayValues = array.new<float>()
    var array<float> thursdayValues = array.new<float>()
    var array<float> fridayValues = array.new<float>()
    var array<float> saturdayValues = array.new<float>()
    var int lastDailyOpen = na
    if na(lastDailyOpen) or time != lastDailyOpen
        bool priorPriceValid = not na(close[1]) and not na(close[2]) and close[1] > 0.0 and close[2] > 0.0
        int priorWeekday = dayofweek[1]
        bool priorDayAllowed = keepWeekends or (priorWeekday >= dayofweek.monday and priorWeekday <= dayofweek.friday)
        if priorPriceValid and priorDayAllowed
            float priorReturn = 100.0 * math.log(close[1] / close[2])
            if priorWeekday == dayofweek.sunday
                f_addSample(sundayValues, priorReturn, sampleLimit)
            else if priorWeekday == dayofweek.monday
                f_addSample(mondayValues, priorReturn, sampleLimit)
            else if priorWeekday == dayofweek.tuesday
                f_addSample(tuesdayValues, priorReturn, sampleLimit)
            else if priorWeekday == dayofweek.wednesday
                f_addSample(wednesdayValues, priorReturn, sampleLimit)
            else if priorWeekday == dayofweek.thursday
                f_addSample(thursdayValues, priorReturn, sampleLimit)
            else if priorWeekday == dayofweek.friday
                f_addSample(fridayValues, priorReturn, sampleLimit)
            else if priorWeekday == dayofweek.saturday
                f_addSample(saturdayValues, priorReturn, sampleLimit)
        lastDailyOpen := time

    [sunMedian, sunQ1, sunQ3, sunPositive, sunCount] = f_stats(sundayValues)
    [monMedian, monQ1, monQ3, monPositive, monCount] = f_stats(mondayValues)
    [tueMedian, tueQ1, tueQ3, tuePositive, tueCount] = f_stats(tuesdayValues)
    [wedMedian, wedQ1, wedQ3, wedPositive, wedCount] = f_stats(wednesdayValues)
    [thuMedian, thuQ1, thuQ3, thuPositive, thuCount] = f_stats(thursdayValues)
    [friMedian, friQ1, friQ3, friPositive, friCount] = f_stats(fridayValues)
    [satMedian, satQ1, satQ3, satPositive, satCount] = f_stats(saturdayValues)

    [sunMedian, sunQ1, sunQ3, sunPositive, sunCount,
     monMedian, monQ1, monQ3, monPositive, monCount,
     tueMedian, tueQ1, tueQ3, tuePositive, tueCount,
     wedMedian, wedQ1, wedQ3, wedPositive, wedCount,
     thuMedian, thuQ1, thuQ3, thuPositive, thuCount,
     friMedian, friQ1, friQ3, friPositive, friCount,
     satMedian, satQ1, satQ3, satPositive, satCount,
     dayofweek]

[sunMedian, sunQ1, sunQ3, sunPositive, sunCount,
 monMedian, monQ1, monQ3, monPositive, monCount,
 tueMedian, tueQ1, tueQ3, tuePositive, tueCount,
 wedMedian, wedQ1, wedQ3, wedPositive, wedCount,
 thuMedian, thuQ1, thuQ3, thuPositive, thuCount,
 friMedian, friQ1, friQ3, friPositive, friCount,
 satMedian, satQ1, satQ3, satPositive, satCount,
 dailyWeekday] = request.security(syminfo.tickerid, "1D", f_dailyEngine(samplesPerDay, includeWeekends), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

f_pick(int weekday, float sundayValue, float mondayValue, float tuesdayValue, float wednesdayValue, float thursdayValue, float fridayValue, float saturdayValue) =>
    switch weekday
        dayofweek.sunday => sundayValue
        dayofweek.monday => mondayValue
        dayofweek.tuesday => tuesdayValue
        dayofweek.wednesday => wednesdayValue
        dayofweek.thursday => thursdayValue
        dayofweek.friday => fridayValue
        dayofweek.saturday => saturdayValue
        => na

f_number(float value, string pattern) =>
    na(value) ? "--" : str.tostring(value, pattern)

f_dayName(int weekday) =>
    switch weekday
        dayofweek.sunday => "SUN"
        dayofweek.monday => "MON"
        dayofweek.tuesday => "TUE"
        dayofweek.wednesday => "WED"
        dayofweek.thursday => "THU"
        dayofweek.friday => "FRI"
        dayofweek.saturday => "SAT"
        => "--"

f_biasState(float median, float positiveRate, float count) =>
    bool reliable = count >= minimumSamples and not na(median) and not na(positiveRate)
    int state = not reliable ? 0 : median >= medianThreshold and positiveRate >= positiveRateThreshold ? 1 : median <= -medianThreshold and positiveRate <= 100.0 - positiveRateThreshold ? -1 : 2
    state

int currentWeekday = int(dailyWeekday)
float currentMedian = f_pick(currentWeekday, sunMedian, monMedian, tueMedian, wedMedian, thuMedian, friMedian, satMedian)
float currentQ1 = f_pick(currentWeekday, sunQ1, monQ1, tueQ1, wedQ1, thuQ1, friQ1, satQ1)
float currentQ3 = f_pick(currentWeekday, sunQ3, monQ3, tueQ3, wedQ3, thuQ3, friQ3, satQ3)
float currentPositive = f_pick(currentWeekday, sunPositive, monPositive, tuePositive, wedPositive, thuPositive, friPositive, satPositive)
float currentCount = f_pick(currentWeekday, sunCount, monCount, tueCount, wedCount, thuCount, friCount, satCount)

int chartSeconds = timeframe.in_seconds()
bool validTimeframe = chartSeconds >= timeframe.in_seconds("1D") and chartSeconds <= timeframe.in_seconds("1W")
int biasState = f_biasState(currentMedian, currentPositive, currentCount)
bool ready = validTimeframe and biasState != 0
bool bullishBias = ready and biasState == 1
bool bearishBias = ready and biasState == -1
float reliability = currentCount > 0 ? f_clamp(currentCount / minimumSamples, 0.0, 1.0) : 0.0
color stateColor = bullishBias ? positiveColor : bearishBias ? negativeColor : neutralColor
int haloTransparency = int(math.round(86.0 - 28.0 * reliability))
int bandTransparency = int(math.round(96.0 - 28.0 * reliability))

hline(0.0, "Zero return", color.new(chart.fg_color, 62), hline.style_dashed)
quartileLow = plot(validTimeframe and showIqrBand ? currentQ1 : na, "Current weekday Q1", color.new(quartileColor, 52), 1, plot.style_stepline, display = display.pane)
quartileHigh = plot(validTimeframe and showIqrBand ? currentQ3 : na, "Current weekday Q3", color.new(quartileColor, 52), 1, plot.style_stepline, display = display.pane)
fill(quartileLow, quartileHigh, validTimeframe and showIqrBand ? color.new(quartileColor, bandTransparency) : na, title = "Current weekday interquartile band")
plot(validTimeframe and showHalo ? currentMedian : na, "Median reliability halo", color.new(stateColor, haloTransparency), 9, plot.style_stepline, display = display.pane)
plot(validTimeframe ? currentMedian : na, "Current weekday median return (%)", color.new(stateColor, ready ? 0 : 55), 3, plot.style_stepline, display = display.pane)
bgcolor(validTimeframe and showBackground and ready ? color.new(stateColor, bullishBias or bearishBias ? 91 : 97) : na, title = "Historical bias background")
plotshape(validTimeframe and showCurrentMarker and barstate.islast and not na(currentMedian) ? currentMedian : na, "Current weekday marker", shape.diamond, location.absolute, stateColor, size = size.small, display = display.pane)

plot(validTimeframe ? currentPositive : na, "Current weekday positive-return rate (%)", display = display.data_window)
plot(validTimeframe ? currentCount : na, "Current weekday sample count", display = display.data_window)
plot(validTimeframe ? biasState : na, "Bias state: -1 negative, 0 insufficient, 1 positive, 2 mixed", display = display.data_window)

f_row(table panel, int row, int weekday, float median, float q1, float q3, float positiveRate, float count) =>
    int rowState = f_biasState(median, positiveRate, count)
    bool current = weekday == currentWeekday
    color rowColor = rowState == 1 ? positiveColor : rowState == -1 ? negativeColor : chart.fg_color
    color rowBackground = current ? color.new(rowState == 1 ? positiveColor : rowState == -1 ? negativeColor : neutralColor, 84) : color.new(chart.bg_color, 5)
    string stateText = rowState == 1 ? "POS" : rowState == -1 ? "NEG" : rowState == 2 ? "MIX" : "WAIT"
    table.cell(panel, 0, row, f_dayName(weekday), text_color = rowColor, bgcolor = rowBackground, text_size = size.small)
    table.cell(panel, 1, row, f_number(median, "#.000") + "%", text_color = rowColor, bgcolor = rowBackground, text_size = size.small)
    table.cell(panel, 2, row, f_number(q1, "#.000") + " / " + f_number(q3, "#.000"), text_color = chart.fg_color, bgcolor = rowBackground, text_size = size.small)
    table.cell(panel, 3, row, f_number(positiveRate, "#.0") + "%", text_color = rowColor, bgcolor = rowBackground, text_size = size.small)
    table.cell(panel, 4, row, str.tostring(count, "#"), text_color = chart.fg_color, bgcolor = rowBackground, text_size = size.small)
    table.cell(panel, 5, row, stateText, text_color = rowColor, bgcolor = rowBackground, text_size = size.small)

var table panel = table.new(position.top_right, 6, 9, bgcolor = color.new(chart.bg_color, 5), frame_color = color.new(chart.fg_color, 70), frame_width = 1, border_color = color.new(chart.fg_color, 84), border_width = 1)
if barstate.islast
    if showTable
        table.clear(panel, 0, 0, 5, 8)
        table.cell(panel, 0, 0, "DAY", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 0, "MEDIAN", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 2, 0, "Q1 / Q3", text_color = quartileColor, text_size = size.small)
        table.cell(panel, 3, 0, "POS", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 4, 0, "N", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 5, 0, "BIAS", text_color = chart.fg_color, text_size = size.small)
        f_row(panel, 1, dayofweek.monday, monMedian, monQ1, monQ3, monPositive, monCount)
        f_row(panel, 2, dayofweek.tuesday, tueMedian, tueQ1, tueQ3, tuePositive, tueCount)
        f_row(panel, 3, dayofweek.wednesday, wedMedian, wedQ1, wedQ3, wedPositive, wedCount)
        f_row(panel, 4, dayofweek.thursday, thuMedian, thuQ1, thuQ3, thuPositive, thuCount)
        f_row(panel, 5, dayofweek.friday, friMedian, friQ1, friQ3, friPositive, friCount)
        f_row(panel, 6, dayofweek.saturday, satMedian, satQ1, satQ3, satPositive, satCount)
        f_row(panel, 7, dayofweek.sunday, sunMedian, sunQ1, sunQ3, sunPositive, sunCount)
        string footer = validTimeframe ? "DAILY ENGINE" : "USE 1D-1W"
        table.cell(panel, 0, 8, footer, text_color = validTimeframe ? chart.fg_color : negativeColor, text_size = size.small)
        table.cell(panel, 1, 8, "CURRENT " + f_dayName(currentWeekday), text_color = stateColor, text_size = size.small)
        table.cell(panel, 2, 8, "CLOSE-TO-CLOSE", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 3, 8, "LIMIT " + str.tostring(samplesPerDay), text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 4, 8, "MIN " + str.tostring(minimumSamples), text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 5, 8, includeWeekends ? "7 DAYS" : "WEEKDAYS", text_color = chart.fg_color, text_size = size.small)
    else
        table.clear(panel, 0, 0, 5, 8)

bool positiveBiasEntered = validTimeframe and bullishBias and not bullishBias[1]
bool negativeBiasEntered = validTimeframe and bearishBias and not bearishBias[1]
bool sampleReliabilityLost = validTimeframe and not ready and ready[1]
alertcondition(positiveBiasEntered, "Positive weekday bias entered", "Weekday Return Distribution: the current weekday entered the user-defined positive historical bias on {{ticker}} {{interval}}.")
alertcondition(negativeBiasEntered, "Negative weekday bias entered", "Weekday Return Distribution: the current weekday entered the user-defined negative historical bias on {{ticker}} {{interval}}.")
alertcondition(sampleReliabilityLost, "Weekday sample reliability lost", "Weekday Return Distribution: the current weekday no longer meets the minimum completed-sample gate on {{ticker}} {{interval}}.")
````
