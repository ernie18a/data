# Sector Rotation & Market Breadth by Stocks above MA [AnyMinute]

- url: https://www.tradingview.com/script/b4WtjLJ8-Sector-Rotation-Market-Breadth-by-Stocks-above-MA-AnyMinute/
- type: indicator
- pine_id: PUB;36d3b98be6d34158ac5c84ef86a66b9f
- version: 1.0

## Description

This sector rotation indicator displays participation across the eleven S&P 500 sectors, alongside the S&P 500, Value and Growth groups. Compare the percentage of stocks above a selected moving average to spot broadening strength, weakness and changes in sector leadership — all in one chart panel.

[b]CHART SETUP[/b]

Use this indicator on a [b]1-day chart[/b]. All eleven sectors and three index groups appear together in one separate pane.

For the clearest view, [b]stretch the indicator pane vertically to use as much chart height as possible[/b], or maximize the pane. The layout works best when the breadth panel occupies most of the chart area.

[b]HOW IT WORKS[/b]

The indicator retrieves participation readings from TradingView’s INDEX symbols, which provide the percentage of stocks trading above the corresponding daily moving average. The script brings those readings together in one panel.

Each sector or index group occupies a separate horizontal row. Its bars show the percentage of constituent stocks that trade above the selected daily moving average, measured against a 50% center line.

With the default colors:

[list]
[*] [b]Green bars:[/b] more than half the stocks are above their moving average.
[*] [b]Red bars:[/b] fewer than half are above their moving average.
[*] [b]Longer bars:[/b] participation is further from 50%.
[*] [b]Labels on the right:[/b] show each group’s latest displayed percentage.
[/list]

At exactly 50%, the bar has no height.

The colors and bar heights represent participation — follow the changing bar heights to see whether participation is expanding or contracting. Changes in participation can support an assessment of rotation, particularly when considered alongside price trends and relative strength.

The eleven sector rows help reveal where strength and weakness are concentrated. The S&P 500, Value and Growth rows provide broader context for those differences.

The 10-day option uses an equal-weight average of the same group’s 5-day and 20-day INDEX readings, as explained further below.

[b]FEATURES[/b]

[list]
[*] [b]Eleven sectors in one panel:[/b] Communication Services, Consumer Discretionary, Consumer Staples, Energy, Financials, Health Care, Industrials, Materials, Technology, Real Estate and Utilities.
[*] [b]Three broader comparisons:[/b] S&P 500 Core, S&P 500 Value and S&P 500 Growth.
[*] [b]Seven lookback choices:[/b] 5, 10, 20, 50, 100, 150 and 200 days.
[*] [b]Auto switch period:[/b] change the lookback directly from your watchlist, without reopening the indicator’s settings.
[*] [b]Historical participation:[/b] compare current readings with earlier periods of strength, weakness and transition.
[*] [b]Customizable colors:[/b] adjust positive and negative bars, text and center lines.
[*] [b]Daily-chart layout:[/b] designed exclusively for the 1-day timeframe.
[/list]

To use the auto switch:

[list]
[*] Create a watchlist with the ticker names 5, 10, 20, 50, 100, 150, and 200 (tickers HKEX:5, HKEX:10, HKEX:20, HKEX:50, HKEX:100, HKEX:150, and HKEX:200).
[*] Enable [b]Auto switch period[/b].
[*] Click through those watchlist entries. Selecting ticker 5 displays 5-day breadth, 20 displays 20-day breadth, and so on. Ticker 10 selects the estimated 10-day reading.
[/list]

The numeric symbols act only as period selectors. Their prices are not used in the breadth calculations, which continue to use the relevant TradingView INDEX feeds.

[b]Why use the HKEX tickers?[/b]

Beyond the period selection convenience, it is also helps remove duplications. 

The breadth panel follows the dates and updates of the chart on which it runs. On a US chart, today’s live bar can repeat the previous day’s breadth readings until new readings become available.

The suggested HKEX symbols offer a convenient viewing layout: their trading session has already finished when the US market opens, so the chart does not add a new bar for the live US session. This avoids the extra repeated bar that can appear on a US chart.


[b]THE 10-DAY ESTIMATE[/b]

The 5-, 20-, 50-, 100-, 150- and 200-day options use the corresponding breadth ticker readings.

The 10-day option is an estimate, calculated from the available 5-day and 20-day percentages:

[b]Estimated 10-day breadth = (5-day breadth + 20-day breadth) / 2[/b]

This provides an intermediate participation reading, but it is not a count of stocks above their actual 10-day moving averages. Treat it as an approximate breadth measure.

[b]USE CASES[/b]

[list]
[*] [b]Watch for changes in leadership.[/b] Look for sectors recovering towards or above 50% while previously stronger sectors lose participation.
[*] [b]Check how broadly strength is shared.[/b] If several sectors develop larger green bars together, participation is broadening. If only a few remain strong while others weaken, strength is becoming more concentrated.
[*] [b]Compare shorter- and longer-term conditions.[/b] Shorter lookbacks highlight faster changes in participation. Longer lookbacks provide a view of more persistent strength or weakness.
[*] [b]Compare Value and Growth.[/b] Observe whether participation is strengthening in both groups or diverging between them.
[/list]

[b]SETTINGS[/b]

[list]
[*] [b]Moving Average period:[/b] selects the daily lookback. The default is 20 days. The 10-day option uses the estimate described above.
[*] [b]Auto switch period:[/b] an optional watchlist shortcut. When checked, and the chart ticker’s name is 5, 10, 20, 50, 100, 150, or 200, that number selects the period. Any other ticker names use the manually selected Moving Average period. Disabled by default.
[*] [b]Above 50% bar color:[/b] color for participation above the center line.
[*] [b]Below 50% bar color:[/b] color for participation below the center line.
[*] [b]Text color:[/b] applies to all sector labels, index labels and the panel title.
[*] [b]50% baseline color:[/b] adjusts the horizontal center lines.
[/list]

[b]DATA AND TIMEFRAME[/b]

The indicator uses TradingView’s INDEX breadth feeds and requires a [b]1-day chart[/b]. Other timeframes display an explanatory error.

The indicator displays the latest daily readings available from the underlying breadth feeds. The host chart’s trading session also affects when the panel refreshes. Availability and update timing depend on the underlying feeds and chart updates. Missing readings are displayed as [b]N/A[/b].

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AnyMinute
//@version=6
indicator("Sector Rotation by Percentage of Stocks above Moving Averages [AnyMinute]", shorttitle = "Sector Rotation", overlay = false, precision = 1, max_labels_count = 15)

// Calculation
i_MAPeriod_int = input.int(20, "Moving Average Period", options = [5, 10, 20, 50, 100, 150, 200], group = "Calculation", tooltip = "Select the period for which you want to see participation data. All periods use daily breadth data, but the 10-day values are estimated.")
i_AutoPeriod_bl = input.bool(false, "Auto switch period", group = "Calculation", tooltip = "With this checked, you can use the chart's ticker name for period selection.\n\nIf you have tickers 5, 10, 20, 50, 100, 150 and 200 in a watchlist, you can easily change periods by clicking the ticker name. \n\nOther tickers will not be recognized, clicking those will make the script use the Moving Average period. ")

// Display
i_AboveHalfColor_cl = input.color(color.green, "Above 50% bar color", group = "Display")
i_BelowHalfColor_cl = input.color(color.red, "Below 50% bar color", group = "Display")
i_TextColor_cl = input.color(color.gray, "Text color", group = "Display")
i_BaselineColor_cl = input.color(color.new(color.gray, 50), "50% baseline color", group = "Display")


f_PeriodSuffix(Period_int) =>
    switch Period_int
        5 => "FD"
        20 => "TW"
        50 => "FI"
        100 => "OH"
        150 => "OF"
        200 => "TH"
        => ""

f_ReadBreadth(Prefix_str, PrimarySuffix_str, Estimate_bl) =>
    [PrimaryBreadth_fl_rq, PrimaryTime_int_rq] = request.security("INDEX:" + Prefix_str + PrimarySuffix_str, "1D", [close, time], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    float Breadth_fl = PrimaryBreadth_fl_rq

    if Estimate_bl
        [TwentyDayBreadth_fl_rq, TwentyDayTime_int_rq] = request.security("INDEX:" + Prefix_str + "TW", "1D", [close, time], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
        // Equal weighting provides a transparent proxy; mismatched source days must not be blended.
        Breadth_fl := PrimaryTime_int_rq == TwentyDayTime_int_rq ? (PrimaryBreadth_fl_rq + TwentyDayBreadth_fl_rq) / 2.0 : na

    Breadth_fl


if not timeframe.isdaily or timeframe.multiplier != 1
    runtime.error("This indicator requires a 1-day (1D) chart. Intraday and higher timeframes are not supported.")

AutoPeriod_int = switch syminfo.ticker
    "5" => 5
    "10" => 10
    "20" => 20
    "50" => 50
    "100" => 100
    "150" => 150
    "200" => 200
    => i_MAPeriod_int

SelectedPeriod_int = i_AutoPeriod_bl ? AutoPeriod_int : i_MAPeriod_int
Estimate_bl = SelectedPeriod_int == 10
PrimarySuffix_str = f_PeriodSuffix(Estimate_bl ? 5 : SelectedPeriod_int)

CommunicationBreadth_fl = f_ReadBreadth("SL", PrimarySuffix_str, Estimate_bl)
ConsumerDiscretionaryBreadth_fl = f_ReadBreadth("SY", PrimarySuffix_str, Estimate_bl)
ConsumerStaplesBreadth_fl = f_ReadBreadth("SP", PrimarySuffix_str, Estimate_bl)
EnergyBreadth_fl = f_ReadBreadth("SE", PrimarySuffix_str, Estimate_bl)
FinancialsBreadth_fl = f_ReadBreadth("SF", PrimarySuffix_str, Estimate_bl)
HealthCareBreadth_fl = f_ReadBreadth("SV", PrimarySuffix_str, Estimate_bl)
IndustrialsBreadth_fl = f_ReadBreadth("SI", PrimarySuffix_str, Estimate_bl)
MaterialsBreadth_fl = f_ReadBreadth("SB", PrimarySuffix_str, Estimate_bl)
TechnologyBreadth_fl = f_ReadBreadth("SK", PrimarySuffix_str, Estimate_bl)
RealEstateBreadth_fl = f_ReadBreadth("SS", PrimarySuffix_str, Estimate_bl)
UtilitiesBreadth_fl = f_ReadBreadth("SU", PrimarySuffix_str, Estimate_bl)
SPXCoreBreadth_fl = f_ReadBreadth("S5", PrimarySuffix_str, Estimate_bl)
SPXValueBreadth_fl = f_ReadBreadth("SW", PrimarySuffix_str, Estimate_bl)
SPXGrowthBreadth_fl = f_ReadBreadth("SZ", PrimarySuffix_str, Estimate_bl)

MethodCaption_str = Estimate_bl ? " (estimated)" : ""
TitleText_str = "% of Stocks Above the " + str.tostring(SelectedPeriod_int) + "-Day Average" + MethodCaption_str

var RowNames_str_ar = array.from("Communication", "Cons. Discr.", "Cons. Staples", "Energy", "Financials", "Health Care", "Industrials", "Materials", "Technology", "Real Estate", "Utilities", "S&P 500", "S&P 500 value", "S&P 500 growth")
var RowBaselines_fl_ar = array.from(50.0, 150.0, 250.0, 350.0, 450.0, 550.0, 650.0, 750.0, 850.0, 950.0, 1050.0, 1250.0, 1350.0, 1450.0)
var RowLabels_ar = array.new<label>()
var label TitleLabel = label.new(na, na, "", style = label.style_label_left, color = color.new(color.gray, 100), textalign = text.align_center, size = size.huge)
BreadthValues_fl_ar = array.from(CommunicationBreadth_fl, ConsumerDiscretionaryBreadth_fl, ConsumerStaplesBreadth_fl, EnergyBreadth_fl, FinancialsBreadth_fl, HealthCareBreadth_fl, IndustrialsBreadth_fl, MaterialsBreadth_fl, TechnologyBreadth_fl, RealEstateBreadth_fl, UtilitiesBreadth_fl, SPXCoreBreadth_fl, SPXValueBreadth_fl, SPXGrowthBreadth_fl)


// Visuals
plot(CommunicationBreadth_fl + 0.0, title = "Communication bars", color = CommunicationBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 50.0, display = display.pane)
plot(ConsumerDiscretionaryBreadth_fl + 100.0, title = "Cons. Discr. bars", color = ConsumerDiscretionaryBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 150.0, display = display.pane)
plot(ConsumerStaplesBreadth_fl + 200.0, title = "Cons. Staples bars", color = ConsumerStaplesBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 250.0, display = display.pane)
plot(EnergyBreadth_fl + 300.0, title = "Energy bars", color = EnergyBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 350.0, display = display.pane)
plot(FinancialsBreadth_fl + 400.0, title = "Financials bars", color = FinancialsBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 450.0, display = display.pane)
plot(HealthCareBreadth_fl + 500.0, title = "Health Care bars", color = HealthCareBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 550.0, display = display.pane)
plot(IndustrialsBreadth_fl + 600.0, title = "Industrials bars", color = IndustrialsBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 650.0, display = display.pane)
plot(MaterialsBreadth_fl + 700.0, title = "Materials bars", color = MaterialsBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 750.0, display = display.pane)
plot(TechnologyBreadth_fl + 800.0, title = "Technology bars", color = TechnologyBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 850.0, display = display.pane)
plot(RealEstateBreadth_fl + 900.0, title = "Real Estate bars", color = RealEstateBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 950.0, display = display.pane)
plot(UtilitiesBreadth_fl + 1000.0, title = "Utilities bars", color = UtilitiesBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 1050.0, display = display.pane)
plot(SPXCoreBreadth_fl + 1200.0, title = "S&P 500 bars", color = SPXCoreBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 1250.0, display = display.pane)
plot(SPXValueBreadth_fl + 1300.0, title = "S&P 500 value bars", color = SPXValueBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 1350.0, display = display.pane)
plot(SPXGrowthBreadth_fl + 1400.0, title = "S&P 500 growth bars", color = SPXGrowthBreadth_fl >= 50.0 ? i_AboveHalfColor_cl : i_BelowHalfColor_cl, style = plot.style_columns, histbase = 1450.0, display = display.pane)

// Unshifted percentages remain available for historical inspection (without showing artificial row offsets)
plot(CommunicationBreadth_fl, title = "Communication breadth %", display = display.data_window, editable = false)
plot(ConsumerDiscretionaryBreadth_fl, title = "Cons. Discr. breadth %", display = display.data_window, editable = false)
plot(ConsumerStaplesBreadth_fl, title = "Cons. Staples breadth %", display = display.data_window, editable = false)
plot(EnergyBreadth_fl, title = "Energy breadth %", display = display.data_window, editable = false)
plot(FinancialsBreadth_fl, title = "Financials breadth %", display = display.data_window, editable = false)
plot(HealthCareBreadth_fl, title = "Health Care breadth %", display = display.data_window, editable = false)
plot(IndustrialsBreadth_fl, title = "Industrials breadth %", display = display.data_window, editable = false)
plot(MaterialsBreadth_fl, title = "Materials breadth %", display = display.data_window, editable = false)
plot(TechnologyBreadth_fl, title = "Technology breadth %", display = display.data_window, editable = false)
plot(RealEstateBreadth_fl, title = "Real Estate breadth %", display = display.data_window, editable = false)
plot(UtilitiesBreadth_fl, title = "Utilities breadth %", display = display.data_window, editable = false)
plot(SPXCoreBreadth_fl, title = "S&P 500 breadth %", display = display.data_window, editable = false)
plot(SPXValueBreadth_fl, title = "S&P 500 value breadth %", display = display.data_window, editable = false)
plot(SPXGrowthBreadth_fl, title = "S&P 500 growth breadth %", display = display.data_window, editable = false)

hline(50.0, title = "Communication 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(150.0, title = "Cons. Discr. 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(250.0, title = "Cons. Staples 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(350.0, title = "Energy 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(450.0, title = "Financials 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(550.0, title = "Health Care 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(650.0, title = "Industrials 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(750.0, title = "Materials 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(850.0, title = "Technology 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(950.0, title = "Real Estate 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(1050.0, title = "Utilities 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(1250.0, title = "S&P 500 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(1350.0, title = "S&P 500 value 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)
hline(1450.0, title = "S&P 500 growth 50%", color = i_BaselineColor_cl, linestyle = hline.style_dotted)

if barstate.isfirst
    for RowIndex_int = 0 to array.size(RowNames_str_ar) - 1
        array.push(RowLabels_ar, label.new(na, na, "", style = label.style_label_left, color = color.new(color.gray, 100), textalign = text.align_center, size = size.large))

if barstate.islast
    for RowIndex_int = 0 to array.size(RowNames_str_ar) - 1
        RowLabel = array.get(RowLabels_ar, RowIndex_int)
        RowBreadth_fl = array.get(BreadthValues_fl_ar, RowIndex_int)
        RowValueText_str = na(RowBreadth_fl) ? "N/A" : str.tostring(RowBreadth_fl, "#.0") + "%"
        label.set_xy(RowLabel, bar_index, array.get(RowBaselines_fl_ar, RowIndex_int))
        label.set_text(RowLabel, array.get(RowNames_str_ar, RowIndex_int) + "\n" + RowValueText_str)
        label.set_textcolor(RowLabel, i_TextColor_cl)

    label.set_xy(TitleLabel, bar_index - 60, 1150)
    label.set_text(TitleLabel, TitleText_str)
    label.set_textcolor(TitleLabel, i_TextColor_cl)
````
