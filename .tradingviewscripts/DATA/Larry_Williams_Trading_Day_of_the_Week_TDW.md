<!-- tradingview-pine-id: PUB;94aa08ac442f45b5b5cb2648d685d915 -->
<!-- tradingviewscripts-format: 1 -->
# Larry Williams: Trading Day of the Week( TDW )

Source: https://www.tradingview.com/script/ZaZNqrKn-Larry-Williams-Trading-Day-of-the-Week-TDW/

## Description

Want to know which days of the week have historically been the best days to buy or trade a market? Are Mondays really bullish, are Fridays different, or are these just trading myths that disappear when tested against decades of data?

This indicator is based on Larry Williams’ Trading Day of the Week (TDW) concept described in Long-Term Secrets to Short-Term Trading. Williams observed that different weekdays can exhibit persistent statistical tendencies and argued that the day of the week can influence future price behavior. Rather than assuming that every trading day is statistically identical, he analyzed each weekday independently and looked for recurring bullish or bearish biases.

For his core TDW research, Williams specifically focused on the price movement from the Open of the trading day to the Close of the same day, rather than simply measuring Close-to-Close returns. He explained that, for a short-term or intraday trader, the trading day effectively begins at the Open and ends at the Close.

The basic test is therefore straightforward:

[*]Monday: buy Monday Open → exit Monday Close
[*]Tuesday: buy Tuesday Open → exit Tuesday Close
[*]Wednesday: buy Wednesday Open → exit Wednesday Close
[*]…and so on.

Williams used this type of analysis to identify the strongest and weakest weekdays and then incorporated those tendencies into more selective trading models. His key point was not that TDW should be traded blindly, but that it can provide a useful market bias or filter. In his words, different periods are better than others, and his preferred approach was to combine a TDW bias with another independent market condition in order to shift the probabilities further in his favor.

His historical research also demonstrated that these effects were not necessarily extreme. For example, in his S&P 500 study, Mondays closed above their Open approximately 57% of the time. The value of TDW therefore comes from identifying a persistent statistical tendency rather than searching for unrealistic win rates.

How this indicator works

The indicator reproduces the basic TDW research process directly on a TradingView Daily chart.
For every weekday, it independently calculates the hypothetical result of buying at that day's Open and exiting at the same day's Close. Each weekday is treated as its own historical test, allowing Monday, Tuesday, Wednesday, Thursday, Friday — and, where applicable, Saturday and Sunday — to be compared separately.

The statistics table provides:

[*]Net Profit
[*]Gross Profit
[*]Gross Loss
[*]Total Trades
[*]Percentage Profitable
[*]Winning Trades
[*]Losing Trades
[*]Maximum Winning Trade
[*]Maximum Losing Trade

Profit and loss are converted using the instrument's point value and the selected number of contracts or units, making the results easier to interpret on futures and other supported markets.

Weekday Equity Curves

A final profit number alone can be misleading. A weekday may look profitable because of a short exceptional period while performing poorly during most of its history.
For this reason, the indicator also plots an independent cumulative equity curve for every weekday.

This allows you to see whether a weekday tendency:

[*]has persisted for many years,
[*]has recently strengthened or weakened,
[*]has experienced long periods of deterioration,
[*]or depends on only a few unusually large moves.

Each weekday curve can be enabled or disabled independently and has its own customizable color.

Settings

The indicator allows you to:

[*]select the historical testing period,
[*]choose the number of contracts or units,
[*]analyze Monday–Friday markets or full 7-day markets,
[*]independently show or hide each weekday equity curve,
[*]customize weekday colors,
[*]and show or hide the statistics table.

The script is designed specifically for the Daily timeframe, consistent with the TDW research methodology.

How to use it

TDW should not be interpreted as a prediction that a particular weekday must rise or fall. Williams himself treated weekday tendencies primarily as a way to establish a statistical bias and improve trade selection rather than as a reason to enter every possible trade. He repeatedly emphasized combining TDW with additional market information and being selective about when to trade.

Add the indicator to a Daily chart, test your market over a meaningful historical period, compare the weekday statistics and equity curves, and find out which days have actually provided an edge — and which ones only have a reputation.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Smollet

//@version=6
indicator("Larry Williams: Trading Day of the Week( TDW )", overlay = false)

// ==================== INPUTS ====================
showtable = input.bool(true, "Show Statistics Table")
yearsBack = input.int(25, "Statistics Period, Years", minval = 1, maxval = 100)
tradeDirection = input.string("Buy", "Trade Direction", options = ["Buy", "Sell"])
weekMode = input.string("7 Days", "Days", options = ["Monday-Friday", "7 Days"])
positionSize = input.float(1.0, "Contracts / Units", minval = 0.00000001)

// ==================== CURVE INPUTS & CURVE COLORS====================
mondayColor = input.color(color.blue, "", inline = "10", group = "Equity Curves")
showMonday = input.bool(true, "Monday", inline = "10", group = "Equity Curves")
tuesdayColor = input.color(color.orange, "", inline = "20", group = "Equity Curves")
showTuesday = input.bool(true, "Tuesday", inline = "20", group = "Equity Curves")
wednesdayColor = input.color(color.green, "", inline = "30", group = "Equity Curves")
showWednesday = input.bool(true, "Wednesday", inline = "30", group = "Equity Curves")
thursdayColor = input.color(color.purple, "", inline = "40", group = "Equity Curves")
showThursday = input.bool(true, "Thursday", inline = "40", group = "Equity Curves")
fridayColor = input.color(color.red, "", inline = "50", group = "Equity Curves")
showFriday = input.bool(true, "Friday", inline = "50", group = "Equity Curves")
saturdayColor = input.color(color.aqua, "", inline = "60", group = "Equity Curves")
showSaturday = input.bool(true, "Saturday", inline = "60", group = "Equity Curves")
sundayColor = input.color(color.fuchsia, "", inline = "70", group = "Equity Curves")
showSunday = input.bool(true, "Sunday", inline = "70", group = "Equity Curves")



// ==================== DAILY TIMEFRAME ONLY ====================
if barstate.isfirst and not timeframe.isdaily
    runtime.error("This indicator works only on the Daily timeframe.")

// ==================== DATE RANGE ====================
int startTime = timestamp("UTC", year(timenow, "UTC") - yearsBack, month(timenow, "UTC"), dayofmonth(timenow, "UTC"), 0, 0)

// ==================== ARRAYS ====================
var array<float> netProfit = array.new_float(7, 0.0)
var array<float> grossProfit = array.new_float(7, 0.0)
var array<float> grossLoss = array.new_float(7, 0.0)
var array<int> totalTrades = array.new_int(7, 0)
var array<int> winningTrades = array.new_int(7, 0)
var array<int> losingTrades = array.new_int(7, 0)
var array<float> maxWinningTrade = array.new_float(7, na)
var array<float> maxLosingTrade = array.new_float(7, na)

// ==================== FUNCTIONS ====================
f_day_index(int d) =>
    d == dayofweek.monday ? 0 : d == dayofweek.tuesday ? 1 : d == dayofweek.wednesday ? 2 : d == dayofweek.thursday ? 3 : d == dayofweek.friday ? 4 : d == dayofweek.saturday ? 5 : d == dayofweek.sunday ? 6 : -1

f_day_name(int idx) =>
    idx == 0 ? "Monday" : idx == 1 ? "Tuesday" : idx == 2 ? "Wednesday" : idx == 3 ? "Thursday" : idx == 4 ? "Friday" : idx == 5 ? "Saturday" : "Sunday"

f_money(float value) =>
    str.format("{0,number,#,###.00}", value)

f_percent(float value) =>
    str.format("{0,number,#.00}", value)

// ==================== STATISTICS ====================
if barstate.isconfirmed and time_tradingday >= startTime
    int entryDay = dayofweek(time_tradingday, "UTC")
    int idx = f_day_index(entryDay)
    bool dayAllowed = idx >= 0 and (weekMode == "7 Days" or idx <= 4)
    if dayAllowed
        float priceMove = tradeDirection == "Buy" ? close - open : open - close
        float tradePnL = priceMove * syminfo.pointvalue * positionSize
        array.set(netProfit, idx, array.get(netProfit, idx) + tradePnL)
        array.set(totalTrades, idx, array.get(totalTrades, idx) + 1)
        if tradePnL > 0
            array.set(grossProfit, idx, array.get(grossProfit, idx) + tradePnL)
            array.set(winningTrades, idx, array.get(winningTrades, idx) + 1)
            float currentMaxWin = array.get(maxWinningTrade, idx)
            array.set(maxWinningTrade, idx, na(currentMaxWin) ? tradePnL : math.max(currentMaxWin, tradePnL))
        else if tradePnL < 0
            array.set(grossLoss, idx, array.get(grossLoss, idx) + tradePnL)
            array.set(losingTrades, idx, array.get(losingTrades, idx) + 1)
            float currentMaxLoss = array.get(maxLosingTrade, idx)
            array.set(maxLosingTrade, idx, na(currentMaxLoss) ? tradePnL : math.min(currentMaxLoss, tradePnL))

// ==================== EQUITY CURVES ====================
bool curvePeriod = time_tradingday >= startTime

float mondayCurve = curvePeriod and showMonday ? array.get(netProfit, 0) : na
float tuesdayCurve = curvePeriod and showTuesday ? array.get(netProfit, 1) : na
float wednesdayCurve = curvePeriod and showWednesday ? array.get(netProfit, 2) : na
float thursdayCurve = curvePeriod and showThursday ? array.get(netProfit, 3) : na
float fridayCurve = curvePeriod and showFriday ? array.get(netProfit, 4) : na
float saturdayCurve = curvePeriod and weekMode == "7 Days" and showSaturday ? array.get(netProfit, 5) : na
float sundayCurve = curvePeriod and weekMode == "7 Days" and showSunday ? array.get(netProfit, 6) : na

plot(mondayCurve, "Monday", color = mondayColor, linewidth = 2)
plot(tuesdayCurve, "Tuesday", color = tuesdayColor, linewidth = 2)
plot(wednesdayCurve, "Wednesday", color = wednesdayColor, linewidth = 2)
plot(thursdayCurve, "Thursday", color = thursdayColor, linewidth = 2)
plot(fridayCurve, "Friday", color = fridayColor, linewidth = 2)
plot(saturdayCurve, "Saturday", color = saturdayColor, linewidth = 2)
plot(sundayCurve, "Sunday", color = sundayColor, linewidth = 2)

hline(0, "Zero", linestyle = hline.style_solid)

// ==================== CURVE LABELS ====================
var label mondayLabel = na
var label tuesdayLabel = na
var label wednesdayLabel = na
var label thursdayLabel = na
var label fridayLabel = na
var label saturdayLabel = na
var label sundayLabel = na

if barstate.islast
    label.delete(mondayLabel)
    label.delete(tuesdayLabel)
    label.delete(wednesdayLabel)
    label.delete(thursdayLabel)
    label.delete(fridayLabel)
    label.delete(saturdayLabel)
    label.delete(sundayLabel)

    if showMonday
        mondayLabel := label.new(bar_index, array.get(netProfit, 0), "Monday", style = label.style_label_left, color = mondayColor, textcolor = color.white, size = size.small)
    if showTuesday
        tuesdayLabel := label.new(bar_index, array.get(netProfit, 1), "Tuesday", style = label.style_label_left, color = tuesdayColor, textcolor = color.white, size = size.small)
    if showWednesday
        wednesdayLabel := label.new(bar_index, array.get(netProfit, 2), "Wednesday", style = label.style_label_left, color = wednesdayColor, textcolor = color.white, size = size.small)
    if showThursday
        thursdayLabel := label.new(bar_index, array.get(netProfit, 3), "Thursday", style = label.style_label_left, color = thursdayColor, textcolor = color.white, size = size.small)
    if showFriday
        fridayLabel := label.new(bar_index, array.get(netProfit, 4), "Friday", style = label.style_label_left, color = fridayColor, textcolor = color.white, size = size.small)
    if weekMode == "7 Days" and showSaturday
        saturdayLabel := label.new(bar_index, array.get(netProfit, 5), "Saturday", style = label.style_label_left, color = saturdayColor, textcolor = color.white, size = size.small)
    if weekMode == "7 Days" and showSunday
        sundayLabel := label.new(bar_index, array.get(netProfit, 6), "Sunday", style = label.style_label_left, color = sundayColor, textcolor = color.white, size = size.small)

// ==================== TABLE ====================
var table statsTable = table.new(position.top_center, 11, 9, border_width = 1, frame_width = 1)

if barstate.isfirst
    table.merge_cells(statsTable, 0, 0, 10, 0)

if barstate.islast and showtable
    color headerColor = color.rgb(229, 224, 205)
    color rowColor = color.rgb(235, 235, 235)
    color titleColor = color.rgb(245, 245, 245)
    color positiveColor = color.rgb(0, 140, 0)
    color negativeColor = color.rgb(200, 0, 0)
    color normalColor = color.black

    string titleText = "Trading Day of the Week | " + tradeDirection + " | " + str.tostring(yearsBack) + " Years | " + str.tostring(positionSize) + " Contracts / Units"

    table.cell(statsTable, 0, 0, titleText, bgcolor = titleColor, text_color = normalColor, text_size = size.small)

    table.cell(statsTable, 0, 1, "WeekDay", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 1, 1, "Test", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 2, 1, "Net Profit", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 3, 1, "Gross Profit", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 4, 1, "Gross Loss", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 5, 1, "Total Trades", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 6, 1, "% Profitable", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 7, 1, "Winning Trades", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 8, 1, "Losing Trades", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 9, 1, "Max Winning Trade", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)
    table.cell(statsTable, 10, 1, "Max Losing Trade", bgcolor = headerColor, text_color = normalColor, text_size = size.auto)

    for idx = 0 to 6
        int row = idx + 2
        bool showDay = weekMode == "7 Days" or idx <= 4

        if showDay
            float np = array.get(netProfit, idx)
            float gp = array.get(grossProfit, idx)
            float gl = array.get(grossLoss, idx)
            int tt = array.get(totalTrades, idx)
            int wt = array.get(winningTrades, idx)
            int lt = array.get(losingTrades, idx)
            float winRate = tt > 0 ? wt * 100.0 / tt : 0.0
            float maxWin = array.get(maxWinningTrade, idx)
            float maxLoss = array.get(maxLosingTrade, idx)

            table.cell(statsTable, 0, row, f_day_name(idx), bgcolor = rowColor, text_color = normalColor, text_size = size.auto)
            table.cell(statsTable, 1, row, str.tostring(idx + 1), bgcolor = rowColor, text_color = normalColor, text_size = size.auto)
            table.cell(statsTable, 2, row, f_money(np), bgcolor = rowColor, text_color = np >= 0 ? positiveColor : negativeColor, text_size = size.auto)
            table.cell(statsTable, 3, row, f_money(gp), bgcolor = rowColor, text_color = positiveColor, text_size = size.auto)
            table.cell(statsTable, 4, row, f_money(gl), bgcolor = rowColor, text_color = negativeColor, text_size = size.auto)
            table.cell(statsTable, 5, row, str.tostring(tt), bgcolor = rowColor, text_color = normalColor, text_size = size.auto)
            table.cell(statsTable, 6, row, f_percent(winRate), bgcolor = rowColor, text_color = normalColor, text_size = size.auto)
            table.cell(statsTable, 7, row, str.tostring(wt), bgcolor = rowColor, text_color = positiveColor, text_size = size.auto)
            table.cell(statsTable, 8, row, str.tostring(lt), bgcolor = rowColor, text_color = negativeColor, text_size = size.auto)
            table.cell(statsTable, 9, row, na(maxWin) ? "0.00" : f_money(maxWin), bgcolor = rowColor, text_color = positiveColor, text_size = size.auto)
            table.cell(statsTable, 10, row, na(maxLoss) ? "0.00" : f_money(maxLoss), bgcolor = rowColor, text_color = negativeColor, text_size = size.auto)
        else
            for col = 0 to 10
                table.cell(statsTable, col, row, "", bgcolor = color.new(color.white, 100))
````
