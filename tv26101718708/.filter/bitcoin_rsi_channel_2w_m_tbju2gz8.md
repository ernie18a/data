# Bitcoin RSI Channel (2W, M)

- url: https://www.tradingview.com/script/tbjU2Gz8-Bitcoin-RSI-Channel-2W-M/
- type: indicator
- pine_id: PUB;389c1481265543d6a50615d67187ddfa
- version: 1.0

## Description

[b]Bitcoin RSI Channel (2W, M)[/b]

The [b]Bitcoin RSI Channel[/b] is a macro-analytical tool designed to identify long-term cyclical tops and bottoms of Bitcoin by applying linear regression modeling to the Relative Strength Index (RSI).

Traditionally, RSI levels like 70 and 30 are used as static markers for overbought and oversold conditions. However, as Bitcoin matures and its volatility dampens, its cyclical RSI peaks and troughs have historically followed a descending trajectory. This script accounts for that "fading" volatility by using mathematically fitted trendlines that track the actual historical extremes of Bitcoin’s momentum.

[b]Main Objectives[/b]
[list]
[*] [b]Curve Fitting:[/b] Plots mathematically modeled linear regression lines through historical RSI peaks and bottoms, ensuring the channel remains as close as possible to the actual turning points of previous cycles.
[*] [b]Normalized View:[/b] Provides an optional "Normalized" mode where the dynamic channel is flattened into a 0-1 "Risk Metric" for easier comparison between cycles.
[image]https://www.tradingview.com/x/iFsCBkUC/[/image]
[*] [b]Main Chart Visualization:[/b] Directly projects overbought and oversold zones onto the price chart via plot coloring, allowing for a seamless confluence of price action and momentum analysis.
[*] [b]Cycle Forecasting:[/b] Designed as a high-timeframe tool to assist in predicting global market tops and generational buying opportunities.
[/list]
[b]IMPORTANT: Timeframe & Methodology[/b]
[i]Please note that the regression lines in this script are specifically modeled for the [b]2-Week (2W)[/b] and [b]Monthly (1M)[/b] timeframes.[/i]
These high timeframes were chosen because they significantly reduce market noise, making them superior for identifying global cycle shifts. The coefficients used in the code were derived from an approximation (fitting) of data points from 2011 through 2023.
[image]https://www.tradingview.com/x/ZukELNG6/[/image]
[b]Recommendation:[/b] Always wait for the candle to [b]close[/b] on the 2W or Monthly timeframe to confirm a signal. Intra-candle fluctuations can be volatile and may provide premature signals before the period is finalized.

[b]How to Use[/b]
[list]
[*] [b]Identifying Extremes:[/b] When the RSI enters the green "Buy Zone" or the red "Sell Zone," it historically indicates that Bitcoin has reached extreme oversold or overbought levels. These periods suggest the proximity of a potential cyclical bottom or top.
[*] [b]Visualizing on Price:[/b] These macro shifts are intuitively reflected through the price overlay on the main chart, providing immediate visual feedback on the current stage of the market cycle.
[*] [b]Strategic Caution:[/b] These zones have [i]not[/i] been infallible in the past, and this indicator should [i]not[/i] be used in isolation. Always seek confluence with other technical or fundamental analysis before making trading decisions.
[/list]
[b]User Tips[/b]
[list]
[*] [b]Clean View:[/b] You can hide the Bitcoin price bars on your main chart (via the Chart Settings) to focus entirely on the risk-based coloring provided by the indicator overlay.
[*] [b]Overlay Toggle:[/b] If you prefer to keep the indicator purely in its own pane, you can disable the "Plot on Main Pane" option in the script settings.
[/list]
[b]Settings & Parameters[/b]
[list]
[*] [b]View Mode:[/b] Switch between "Fit Lines" (standard RSI inside a diagonal channel) and "Normalized" (RSI converted into a Risk Metric).
[*] [b]Sell/Buy Zone Levels:[/b] Adjustable thresholds (default 0.90 and 0.10) to define your personal risk appetite for overbought and oversold conditions.
[*] [b]Plot on Main Pane:[/b] Toggle to enable/disable price bar colorization based on the current Risk Metric.
[/list]
[b]Limitations & Disclaimer[/b]
[list]
[*] [b]BTC Specificity:[/b] This indicator is purpose-built for Bitcoin. While you can load it on other symbols, the indicator pane will [i]always[/i] calculate based on [b]INDEX:BTCUSD[/b] data to maintain its cyclical logic. The main chart overlay, however, will color the plot of whatever instrument you are currently viewing.
[*] [b]Fixed RSI Optimization:[/b] The regression model is strictly optimized using the default RSI settings (14-period, Source: Close). The linear regression lines were fitted specifically to these values; therefore, the ability to modify the RSI length or source has been intentionally omitted from the settings. Changing these parameters would render the channel irrelevant, as the trendlines would no longer align with historical market extremes.
[*] [b]Static Modeling:[/b] The regression coefficients are "hardcoded" based on historical peaks and troughs up to 2023. As the market evolves, future cycles may require new approximations to account for shifting volatility.
[*] [b]No Guarantees:[/b] Mathematical models describe the past but do not guarantee the future. There is no guarantee that Bitcoin will reach the upper or lower boundaries in any given cycle, or that it will stay within them. Use this tool as one part of a comprehensive trading strategy.
[/list]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartNChill

//@version=6
indicator(title="Bitcoin RSI Channel (2W, M)", shorttitle="BRSI Ch.", precision=5)

// =========================================================================
// CONSTANTS
// =========================================================================
// Base start dates for regression
const int START_DATE_2W = timestamp("May 10 2010")
const int START_DATE_M  = timestamp("Dec 01 2010")

// TOPS 
// 2W
const int TOP_DATE_2W_1 = timestamp("Jun 06 2011")
const int TOP_DATE_2W_2 = timestamp("Mar 18 2013")
const int TOP_DATE_2W_3 = timestamp("Nov 25 2013")
const int TOP_DATE_2W_4 = timestamp("Dec 04 2017")
const int TOP_DATE_2W_5 = timestamp("Jan 04 2021")
const float TOP_LEVEL_2W_1 = 98.41617
const float TOP_LEVEL_2W_2 = 97.63297
const float TOP_LEVEL_2W_3 = 94.54417
const float TOP_LEVEL_2W_4 = 95.20138
const float TOP_LEVEL_2W_5 = 90.1375
// Top line coefficients
const float K_TOP_2W = -2.378715469903773e-11
const float B_TOP_2W = 99.04488956564249
// R^2 = 0.8072543227260401

// Monthly
const int TOP_DATE_M_1 = timestamp("Jun 01 2011")
const int TOP_DATE_M_2 = timestamp("Apr 01 2013")
const int TOP_DATE_M_3 = timestamp("Nov 01 2013")
const int TOP_DATE_M_4 = timestamp("Dec 01 2017")
const int TOP_DATE_M_5 = timestamp("Mar 01 2021")
const float TOP_LEVEL_M_1 = 99.55807
const float TOP_LEVEL_M_2 = 96.90487
const float TOP_LEVEL_M_3 = 97.44215
const float TOP_LEVEL_M_4 = 96.05951
const float TOP_LEVEL_M_5 = 91.72708
// Top line coefficients
const float K_TOP_M = -2.1848141941695998e-11
const float B_TOP_M = 99.50963749912107
// R^2 = 0.8929568387123011

// BOTTOMS
// 2W
const int BOTTOM_DATE_2W_1 = timestamp("Nov 07 2011")
const int BOTTOM_DATE_2W_2 = timestamp("Jan 05 2015")
const int BOTTOM_DATE_2W_3 = timestamp("Dec 03 2018")
const int BOTTOM_DATE_2W_4 = timestamp("Jun 20 2022")
const float BOTTOM_LEVEL_2W_1 = 40.48696
const float BOTTOM_LEVEL_2W_2 = 34.23634
const float BOTTOM_LEVEL_2W_3 = 36.54433
const float BOTTOM_LEVEL_2W_4 = 34.17704
// Bottom line coefficients
const float K_BOT_2W = -1.4157642306030596e-11
const float B_BOT_2W = 39.358057223340545
// R^2 = 0.48532727715237556

// Monthly
const int BOTTOM_DATE_M_1 = timestamp("Nov 01 2011")
const int BOTTOM_DATE_M_2 = timestamp("Jan 01 2015")
const int BOTTOM_DATE_M_3 = timestamp("Jan 01 2019")
const int BOTTOM_DATE_M_4 = timestamp("Dec 01 2022")
const float BOTTOM_LEVEL_M_1 = 49.02653
const float BOTTOM_LEVEL_M_2 = 44.59187
const float BOTTOM_LEVEL_M_3 = 43.84313
const float BOTTOM_LEVEL_M_4 = 40.34022
// Bottom line coefficients
const float K_BOT_M = -2.2532419572911676e-11
const float B_BOT_M = 48.91007200780633
// R^2 = 0.9200635486082351

const string VIEW_INPUT_1  = "Fit Lines"
const string VIEW_INPUT_2  = "Normalized"
const string TT_ZONE_LEVEL = "Value between 0.01 and 0.99"
const string TT_MAIN_PANE  = "Show or hide plotting on the main pane"

// COLLORS
const color RSI_COLOR   = #7E57C2
const color RANGE_COLOR = #87CEEB
const color SELL_COLOR  = color.new(color.red, 70)
const color BUY_COLOR   = color.new(color.green, 70)

// RSI
const int RSI_LENGTH = 14
float RSI_SOURCE     = close

// =========================================================================
// INPUTS
// =========================================================================
string viewInput = input.string(VIEW_INPUT_1, "View Mode", [VIEW_INPUT_1, VIEW_INPUT_2])

float sellZoneLevelInput = input.float(
  0.90, 
  "Sell Zone Level", 
  minval  = 0.01, 
  maxval  = 0.99, 
  step    = 0.01, 
  tooltip = TT_ZONE_LEVEL
  )

float buyZoneLevelInput = input.float(
  0.10, 
  "Buy Zone Level", 
  minval  = 0.01, 
  maxval  = 0.99, 
  step    = 0.01, 
  tooltip = TT_ZONE_LEVEL
  )

bool showOnMainInput = input.bool(true, "Plot on Main Pane", tooltip = TT_MAIN_PANE)

// =========================================================================
// CALCULATIONS
// =========================================================================
// Fetch BTC Index price for consistency across different symbols
float btcPrice = request.security("INDEX:BTCUSD", timeframe.period, RSI_SOURCE)

// RSI
float rsiValue = ta.rsi(btcPrice, RSI_LENGTH)

// Fit Lines (Work only on 2W and M timeframes)
float topLine = switch timeframe.period 
    "2W" => K_TOP_2W * (time - START_DATE_2W) + B_TOP_2W
    "1M" => K_TOP_M  * (time - START_DATE_M)  + B_TOP_M
    => na

float botLine = switch timeframe.period
    "2W" => K_BOT_2W * (time - START_DATE_2W) + B_BOT_2W
    "1M" => K_BOT_M  * (time - START_DATE_M)  + B_BOT_M
    => na

float midLine = botLine + (topLine - botLine) / 2

// Risk Metric (Normalized 0 to 1)
float riskMetric = (rsiValue - botLine) / (topLine - botLine)

// =========================================================================
// VISUALS
// =========================================================================
// Adjust plotting values based on View Mode
bool fitLinesView = viewInput == VIEW_INPUT_1

float topBorder = fitLinesView ? topLine  : 1
float botBorder = fitLinesView ? botLine  : 0
float midBorder = fitLinesView ? midLine  : 0.5
float plotLine  = fitLinesView ? rsiValue : riskMetric

// Plot Channel
topPlot = plot(topBorder, "Top Line", RANGE_COLOR, 2)
plot(midBorder, "Middle Line", RANGE_COLOR, 1)
botPlot = plot(botBorder, "Bottom Line", RANGE_COLOR, 2)

// Buy & Sell Zones
float sellLevelValue = fitLinesView ? (botLine + (topLine - botLine) * sellZoneLevelInput) : sellZoneLevelInput
float buyLevelValue  = fitLinesView ? (botLine + (topLine - botLine) * buyZoneLevelInput)  : buyZoneLevelInput

sellLevelPlot = plot(sellLevelValue, "Sell Level", SELL_COLOR)
buyLevelPlot  = plot(buyLevelValue, "Buy Level", BUY_COLOR)

fill(sellLevelPlot, topPlot, SELL_COLOR, "Sell Zone")
fill(botPlot, buyLevelPlot, BUY_COLOR, "Buy Zone")

// Plot RSI/Risk Line
plot(plotLine, "RSI / Risk", RSI_COLOR, 3)

// Risk Table
plotchar(riskMetric, "Risk", display = display.data_window + display.status_line, precision = 2, color = color.white)

var table riskDisplay = table.new(position.top_right, 2, 1)
if barstate.islast
    table.cell(riskDisplay, 0, 0, "Risk", text_color = color.white)
    table.cell(riskDisplay, 1, 0, str.tostring(riskMetric, "#.##"), text_color = color.white)

// Main Chart Overlay
color chartColor = showOnMainInput ? (riskMetric <= buyZoneLevelInput ? color.green : (riskMetric >= sellZoneLevelInput ? color.red : color.blue)) : na
plot(close, "Price Overlay", chartColor, 2, precision = 2, force_overlay = true)

// Timestamps in Data Window for future fitting
plotchar(TOP_DATE_2W_1 - START_DATE_2W, "Top 1 2W", display = display.data_window, precision = 0)
plotchar(TOP_DATE_2W_2 - START_DATE_2W, "Top 2 2W", display = display.data_window, precision = 0)
plotchar(TOP_DATE_2W_3 - START_DATE_2W, "Top 3 2W", display = display.data_window, precision = 0)
plotchar(TOP_DATE_2W_4 - START_DATE_2W, "Top 4 2W", display = display.data_window, precision = 0)
plotchar(TOP_DATE_2W_5 - START_DATE_2W, "Top 5 2W", display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_1 - START_DATE_M, "Top 1 M", display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_2 - START_DATE_M, "Top 2 M", display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_3 - START_DATE_M, "Top 3 M", display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_4 - START_DATE_M, "Top 4 M", display = display.data_window, precision = 0)
plotchar(TOP_DATE_M_5 - START_DATE_M, "Top 5 M", display = display.data_window, precision = 0)

plotchar(BOTTOM_DATE_2W_1 - START_DATE_2W, "Bottom 1 2W", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_2W_2 - START_DATE_2W, "Bottom 2 2W", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_2W_3 - START_DATE_2W, "Bottom 3 2W", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_2W_4 - START_DATE_2W, "Bottom 4 2W", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_1 - START_DATE_M, "Bottom 1 M", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_2 - START_DATE_M, "Bottom 2 M", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_3 - START_DATE_M, "Bottom 3 M", display = display.data_window, precision = 0, color = color.orange)
plotchar(BOTTOM_DATE_M_4 - START_DATE_M, "Bottom 4 M", display = display.data_window, precision = 0, color = color.orange)
````
