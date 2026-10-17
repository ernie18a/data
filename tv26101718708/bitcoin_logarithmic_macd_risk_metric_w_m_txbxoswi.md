# Bitcoin Logarithmic MACD Risk Metric (W, M)

- url: https://www.tradingview.com/script/TXbxoSWi-Bitcoin-Logarithmic-MACD-Risk-Metric-W-M/
- type: indicator
- pine_id: PUB;c425a6cb0ccb4fe1806a1885ec8cd27a
- version: 1.0

## Description

[b]Description[/b]
The [b]Bitcoin Logarithmic MACD Risk Metric (W, M)[/b] is a long-term macro analysis tool designed to identify generational buying and selling opportunities for Bitcoin. By applying logarithmic and linear regression models to the Logarithmic MACD (LMACD), this indicator normalizes price momentum relative to historical market cycle extremes.

Unlike standard MACD, the logarithmic version used here accounts for Bitcoin's exponential growth over time, allowing for a consistent comparison of momentum across different cycles.

[b]IMPORTANT: Timeframe Compatibility[/b]
[b]Note:[/b] This indicator is strictly designed for [b]Weekly (W)[/b] and [b]Monthly (M)[/b] timeframes. The regression lines [b]won't show[/b] on other timeframes.
[image]https://www.tradingview.com/x/AThAP7La/[/image]
[list]
[*] The regression lines (Log and Linear fits) were calculated using data points from these high-level timeframes because they contain less "noise" and are far more reliable for predicting global cyclical tops and bottoms.
[*] It is highly recommended to wait for the [b]candle close[/b] on the respective timeframe to confirm any signal, as mid-candle fluctuations can significantly alter the Risk Metric value.
[/list]
[b]How to Use It[/b]
The metric provides a "Risk" score between 0 and 1, visualizing where Bitcoin sits within its historical growth channel.
[list]
[*] [b]Sell Zone (Red):[/b] When the LMACD line enters the red zone, it indicates that Bitcoin is overbought and potentially nearing a cyclical peak.
[*] [b]Buy Zone (Green):[/b] When the LMACD drops into the green zone, it suggests the asset is oversold and approaching a cyclical bottom.
[*] [b]Confluence:[/b] While these zones have historically marked major reversals, this indicator should [i]not[/i] be used in isolation. Always seek confluence with other technical or fundamental indicators.
[/list]
[b]Customizable Settings[/b]
[list]
[*] [b]Line Fits:[/b] You can choose between "Log Fit" and "Linear Fit" for both Top and Bottom lines to see which model best aligns with your current analysis.
[image]https://www.tradingview.com/x/FTpyzuB7/[/image]
[*] [b]View Mode:[/b] Switch between [i]Fit Lines[/i] (seeing the MACD inside the channel) or [i]Normalized[/i] (viewing the risk as a 0-1 oscillator).
[image]https://www.tradingview.com/x/OByefjJh/[/image]
[*] [b]Risk Levels:[/b] Adjust the thresholds for the Buy and Sell zones to fit your risk tolerance.
[*] [b]Price Overlay:[/b] Toggle the candle coloring on the main chart to see risk levels directly on the price action.
[/list]
[b]VIsualization Tip[/b]
If the price overlay makes the chart look too cluttered, you can hide the Bitcoin price bars in the main chart settings to focus purely on the colored risk overlay. Alternatively, you can disable the "Plot on Main Pane" option in the indicator settings if you only want to see the metric in its own separate pane below.

[b]Limitations[/b]
[list]
[*] [b]Asset Focus:[/b] This indicator is specifically calibrated for Bitcoin. While you can apply it to other charts, the indicator pane will [b]always[/b] display Bitcoin's MACD risk, whereas the price overlay will color the candles of the currently selected instrument.
[*] [b]Fixed Parameters:[/b] The LMACD settings (12, 26, Close) are hardcoded. This is intentional, as the regression fitting was performed specifically using these values; changing them would make the historical bands irrelevant.
[*] [b]Hardcoded Coefficients:[/b] The regression lines are based on historical tops and bottoms up to 2023. Future market cycles may require new approximations if Bitcoin's volatility profile shifts significantly.
[*] [b]Regression Specifics:[/b] The Linear Fit model treats the early 2011 peaks/bottoms as outliers. On the Monthly timeframe, the bottom line is available only as a linear fit due to the limited number of historical macro data points. The upper linear boundary is guaranteed to be broken by future price action, but it can serve as a "conservative" macro target in the meantime.
[*] [b]No Guarantees:[/b] Past performance does not guarantee future results. There is no certainty that the metric will reach the boundaries in every cycle or remain within them indefinitely.
[/list]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartNChill

//@version=6
indicator(title="Bitcoin Logarithmic MACD Risk Metric (W, M)", shorttitle="LMACD Risk Metric", precision = 5)

// =========================================================================
// CONSTANTS
// =========================================================================
// Base start dates for regression
START_DATE_W = timestamp('May 10 2010')
START_DATE_M = timestamp('Nov 01 2011')
MS_IN_D = 86400000

// TOPS 
// Weekly
TOP_DATE_W_1 = timestamp('Jun 06 2011')
TOP_DATE_W_2 = timestamp('Apr 01 2013')
TOP_DATE_W_3 = timestamp('Nov 25 2013')
TOP_DATE_W_4 = timestamp('Dec 11 2017')
TOP_DATE_W_5 = timestamp('Feb 15 2021')
TOP_LEVEL_W_1 = 0.54278
TOP_LEVEL_W_2 = 0.45042
TOP_LEVEL_W_3 = 0.43195
TOP_LEVEL_W_4 = 0.35543
TOP_LEVEL_W_5 = 0.29303
// Top line coefficients
A_TOP_LOG_W = -0.14190625628569345
B_TOP_LOG_W = 4.081576907649693
TOP_OFFSET_DAYS_W = 399
// R^2 = 0.9946276862218513
K_TOP_LIN_W = -6.232001766208892e-13
B_TOP_LIN_W = 0.5046383595163714
// R^2 = 0.9989824268009576

// Monthly
TOP_DATE_M_1 = timestamp('Nov 01 2013')
TOP_DATE_M_2 = timestamp('Dec 01 2017')
TOP_DATE_M_3 = timestamp('Apr 01 2021')
TOP_LEVEL_M_1 = 0.6
TOP_LEVEL_M_2 = 0.51004
TOP_LEVEL_M_3 = 0.41199
// Top line coefficients
A_TOP_LOG_M = -0.47841512038266065
B_TOP_LOG_M = 13.488762278731878
TOP_OFFSET_DAYS_M = 5000
// R^2 = 0.9813418812487472
K_TOP_LIN_M = -7.996653349393959e-13
B_TOP_LIN_M = 0.6545534049761929
// R^2 = 0.9930955372319149

// BOTTOMS
// Weekly
BOTTOM_DATE_W_1 = timestamp('Dec 05 2011')
BOTTOM_DATE_W_2 = timestamp('Feb 09 2015')
BOTTOM_DATE_W_3 = timestamp('Jan 28 2019')
BOTTOM_DATE_W_4 = timestamp('Jul 11 2022')
BOTTOM_LEVEL_W_1 = -0.28951
BOTTOM_LEVEL_W_2 = -0.20989
BOTTOM_LEVEL_W_3 = -0.21104
BOTTOM_LEVEL_W_4 = -0.21505
// Bottom line coefficients
A_BOT_LOG_W = 0.009799507090053724
B_BOT_LOG_W = -0.46726170001456513
BOTTOM_OFFSET_DAYS_W = -573
// R^2 = 0.9676656358081172
K_BOT_LIN_W = -2.1726436488255256e-14
B_BOT_LIN_W = -0.20613282697384214
// R^2 = 0.8824434733234925

// Monthly
BOTTOM_DATE_M_1 = timestamp('Sep 01 2015')
BOTTOM_DATE_M_2 = timestamp('Apr 01 2019')
BOTTOM_DATE_M_3 = timestamp('Feb 01 2023')
BOTTOM_LEVEL_M_1 = -0.05905
BOTTOM_LEVEL_M_2 = 0.02877
BOTTOM_LEVEL_M_3 = -0.10052
// Bottom line coefficients
K_BOT_LIN_M = -1.7711322946562795e-13
B_BOT_LIN_M = -0.03762638376383766
// R^2 = 1.0

LINE_INPUT_1 = 'Log Fit'
LINE_INPUT_2 = 'Linear Fit'
VIEW_INPUT_1 = 'Fit Lines'
VIEW_INPUT_2 = 'Normalized'
TT_ZONE_LEVEL = "Value between 0.01 and 0.99"
TT_MAIN_PANE  = "Show or hide plotting on the main pane"
TT_BOT_LINE  = "On the Monthly timeframe, the bottom line always uses linear fit due to data limitations."

// COLLORS
RANGE_COLOR = #87CEEB
SELL_COLOR = color.new(color.red, 70)
BUY_COLOR = color.new(color.green, 70)

// MACD
FAST_LENGTH = 12
SLOW_LENGTH = 26
SRC = close

// =========================================================================
// INPUTS
// =========================================================================
topLineInput = input.string(LINE_INPUT_1, 'Top Line', [LINE_INPUT_1, LINE_INPUT_2], group="Calculation Settings")
botLineInput = input.string(LINE_INPUT_1, 'Bottom Line', [LINE_INPUT_1, LINE_INPUT_2], group="Calculation Settings", tooltip = TT_BOT_LINE)

viewModeInput = input.string(VIEW_INPUT_1, "View Mode", [VIEW_INPUT_1, VIEW_INPUT_2], group="Display Settings")
showOnMainInput = input.bool(true, "Plot on Main Pane", group="Display Settings", tooltip = TT_MAIN_PANE)

sellLevelInput = input.float(0.90, "Sell Zone Level", 0.01, 0.99, 0.01, group="Risk Levels", tooltip=TT_ZONE_LEVEL)
buyLevelInput = input.float(0.10, "Buy Zone Level", 0.01, 0.99, 0.01, group="Risk Levels", tooltip=TT_ZONE_LEVEL)

// =========================================================================
// CALCULATIONS
// =========================================================================
// Fetch BTC Index price for consistency across different symbols
float btcPrice = request.security("INDEX:BTCUSD", timeframe.period, SRC)

// MACD
fast_ma = ta.ema(btcPrice, FAST_LENGTH)
slow_ma = ta.ema(btcPrice, SLOW_LENGTH)
lmacd = math.log(fast_ma) - math.log(slow_ma)

// Fit Lines (Work only on W and M timeframes)
topLineLogW = A_TOP_LOG_W * math.log(time - START_DATE_W + TOP_OFFSET_DAYS_W * MS_IN_D) + B_TOP_LOG_W
topLineLinW = K_TOP_LIN_W * (time - START_DATE_W) + B_TOP_LIN_W
topLineLogM = A_TOP_LOG_M * math.log(time - START_DATE_M + TOP_OFFSET_DAYS_M * MS_IN_D) + B_TOP_LOG_M
topLineLinM = K_TOP_LIN_M * (time - START_DATE_M) + B_TOP_LIN_M
topLine = switch topLineInput
    LINE_INPUT_1 => timeframe.isweekly ? topLineLogW : timeframe.ismonthly ? topLineLogM : na
    LINE_INPUT_2 => timeframe.isweekly ? topLineLinW : timeframe.ismonthly ? topLineLinM : na

botLineLogW = A_BOT_LOG_W * math.log(time - START_DATE_W + BOTTOM_OFFSET_DAYS_W * MS_IN_D) + B_BOT_LOG_W
botLineLinW = K_BOT_LIN_W * (time - START_DATE_W) + B_BOT_LIN_W
botLineLinM = K_BOT_LIN_M * (time - START_DATE_M) + B_BOT_LIN_M 
botLine = switch botLineInput
    LINE_INPUT_1 => timeframe.isweekly ? botLineLogW : timeframe.ismonthly ? botLineLinM : na // For M timeframe only a linear line made with two data points available
    LINE_INPUT_2 => timeframe.isweekly ? botLineLinW : timeframe.ismonthly ? botLineLinM : na

midLine = botLine + (topLine - botLine) / 2

// Risk Metric (Normalized 0 to 1)
risk = (lmacd - botLine) / (topLine - botLine)

// =========================================================================
// VISUALS
// =========================================================================
// Adjust plotting values based on View Mode
isFitLines = viewModeInput == VIEW_INPUT_1

topBorder = isFitLines ? topLine : 1
botBorder = isFitLines ? botLine : 0
midBorder = isFitLines ? midLine : 0.5
plotLine = isFitLines ? lmacd : risk

// Plot Channel
topPlot = plot(topBorder, 'Top Line', RANGE_COLOR, 2)
plot(midBorder, 'Middle Line', RANGE_COLOR, 1)
botPlot = plot(botBorder, 'Bottom Line', RANGE_COLOR, 2)

// Buy & Sell Zones
sellLevelValue = isFitLines ? (botLine + (topLine - botLine) * sellLevelInput) : sellLevelInput
buyLevelValue = isFitLines ? (botLine + (topLine - botLine) * buyLevelInput) : buyLevelInput
sellLevelPlot = plot(sellLevelValue, 'Sell Level', SELL_COLOR)
buyLevelPlot = plot(buyLevelValue, 'Buy Level', BUY_COLOR)
fill(sellLevelPlot, topPlot, SELL_COLOR, 'Sell zone')
fill(botPlot, buyLevelPlot, BUY_COLOR, 'Buy zone')

// Plot MACD/Risk Line
plot(plotLine, "LMACD / Risk", color.blue, 2)

// Risk Table
plotchar(risk, 'Risk', display = display.data_window + display.status_line, precision = 2, color = color.white)

var riskDisplay = table.new(position.top_right, 2, 1)
if barstate.islast
    table.cell(riskDisplay, 0, 0, 'Risk', text_color = color.white)
    table.cell(riskDisplay, 1, 0, str.tostring(risk, '#.##'), text_color = color.white)

// Main Chart Overlay
chartColor = showOnMainInput ? (risk <= buyLevelInput) ? color.green : (risk >= sellLevelInput) ? color.red : color.blue : na
plot(close, "Price Overlay", chartColor, 2, precision = 2, force_overlay = true)

// Timestamps in Data Window for future fitting
plotchar(TOP_DATE_W_1 - START_DATE_W, 'Top 1 W', display = display.data_window, precision = 0)
plotchar(TOP_DATE_W_2 - START_DATE_W, 'Top 2 W', display = display.data_window, precision = 0)
plotchar(TOP_DATE_W_3 - START_DATE_W, 'Top 3 W', display = display.data_window, precision = 0)
plotchar(TOP_DATE_W_4 - START_DATE_W, 'Top 4 W', display = display.data_window, precision = 0)
plotchar(TOP_DATE_W_5 - START_DATE_W, 'Top 5 W', display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_1 - START_DATE_M, 'Top 1 M', display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_2 - START_DATE_M, 'Top 2 M', display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_3 - START_DATE_M, 'Top 3 M', display = display.data_window, precision = 0)

plotchar(BOTTOM_DATE_W_1 - START_DATE_W, 'Bottom 1 W', display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_W_2 - START_DATE_W, 'Bottom 2 W', display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_W_3 - START_DATE_W, 'Bottom 3 W', display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_W_4 - START_DATE_W, 'Bottom 4 W', display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_1 - START_DATE_M, 'Bottom 1 M', display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_2 - START_DATE_M, 'Bottom 2 M', display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_3 - START_DATE_M, 'Bottom 3 M', display = display.data_window, precision = 0, color = color.orange)
````
