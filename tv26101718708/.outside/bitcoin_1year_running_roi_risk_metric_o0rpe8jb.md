# Bitcoin 1-Year Running ROI Risk Metric

- url: https://www.tradingview.com/script/o0RPe8Jb-Bitcoin-1-Year-Running-ROI-Risk-Metric/
- type: indicator
- pine_id: PUB;37f7ba0e595547bc96f9ee8b174ec2f1
- version: 1.0

## Description

[b]Overview[/b]

The Bitcoin 1-Year Running ROI Risk Metric is a macro-analysis oscillator designed to evaluate the current stage of Bitcoin's market cycle. By analyzing the 1-year rolling Return on Investment (ROI) and applying regression models to historical peaks and troughs, it translates raw market data into a normalized Risk score ranging from 0 to 1.

[b]How it Works[/b]

Historically, due to the law of diminishing returns, Bitcoin's cycle peaks yield a progressively lower ROI each macro cycle. This indicator accounts for this phenomenon by fitting bounding regression curves to historical cycle extremes. 

The script calculates the natural logarithm of the 1-year ROI. It then normalizes this value between a fitted bottom line (representing historical bear market bottoms) and a fitted top line (representing historical bull market peaks).
[list]
[*]A Risk value near [b]0[/b] (or inside the Buy Zone) indicates historical bear market lows, representing minimal macro risk and potential accumulation zones.
[*]A Risk value near [b]1[/b] (or inside the Sell Zone) suggests the market is approaching the historical limits of diminishing returns, indicating maximum macro risk and potential cycle tops.
[/list]
[b]Settings & Customization[/b]

Users can customize the indicator's behavior and visuals through the settings menu:
[list]
[*][b]Top Line:[/b] Select the mathematical model used for the upper boundary of the market cycle. Choose between a [b]Log Fit[/b] (logarithmic regression, which best captures all historical tops) or a [b]Linear Fit[/b] (a more conservative straight line that excludes the 2011 peak).
[image]https://www.tradingview.com/x/7UkoXfMe/[/image]
[*][b]View:[/b] Switch between the [b]Normalized[/b] mode (displays the Risk metric as a clean 0 to 1 oscillator) and the [b]Fit Lines[/b] mode (displays the raw logarithmic ROI values along with the upper, middle, and lower regression bands).
[image]https://www.tradingview.com/x/ObWPuHw5/[/image]
[*][b]Sell / Buy Zone Levels:[/b] Adjust the thresholds that define the extreme risk areas. By default, the Sell Zone starts at 0.90 and the Buy Zone at 0.10. These values dictate when the oscillator and the main chart price line change colors.
[*][b]Plot on the Main Pane:[/b] A simple toggle to turn the colored price line overlay on your main chart on or off.
[/list]
[b]💡 Visualization Tip[/b]

The script projects a colored price line directly onto your main chart (Green for Buy Zone, Red for Sell Zone). 
[list]
[*]To see this colored indicator line clearly without visual clutter, you can hide the standard Bitcoin price candles using the chart's object tree or settings.
[*]Conversely, if you prefer a clean main chart and only want to view the risk oscillator in the lower pane, simply uncheck the [b]"Plot on the Main Pane"[/b] option in the indicator's settings.
[/list]
[b]Limitations & Disclaimers[/b]

Please keep the following points in mind when using this tool:
[list]
[*][b]Asset Specific:[/b] This indicator is strictly designed for Bitcoin. It internally fetches data using the INDEX:BTCUSD ticker. While you can load it on any other asset's chart, the oscillator in the lower pane will always display Bitcoin's data.
[*][b]Timeframe Dependency:[/b] Although the indicator will calculate on any timeframe, it is highly recommended to use the [b]Weekly (1W)[/b] chart. The regression curve fitting was performed using weekly closes. On other timeframes, the regression boundaries may not align perfectly with the exact global tops and bottoms.
[*][b]Hardcoded Coefficients:[/b] The curve fitting was calculated based on Bitcoin's global tops and bottoms up to the year 2023. The resulting mathematical coefficients are hardcoded into the script. Future macro cycles may require a new approximation and an update to these coefficients.
[*][b]Linear Fit Outlier:[/b] If you select the "Linear Fit" option for the Top Line in the settings, note that this model intentionally ignores the 2011 global top, treating it as a statistical outlier. This linear boundary is guaranteed to be broken by future price action, but it can serve as a "conservative" macro target in the meantime.
[*][b]No Guarantees:[/b] There is no guarantee that Bitcoin's price or ROI will reach the upper or lower boundaries in the future, nor is it guaranteed to remain within them. This indicator is for educational and macro-analysis purposes only and does not constitute financial advice.
[/list]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartNChill

//@version=6
indicator('Bitcoin 1-Year Running ROI Risk Metric', 'RROI Risk', precision = 5)

// =========================================================================
// CONSTANTS
// =========================================================================
const int START_DATE = timestamp("Nov 22 2010")
const int MS_IN_D    = 86400000

// TOPS (Weekly)
const int   TOP_DATE_1      = timestamp("May 30 2011")
const int   TOP_DATE_2      = timestamp("Nov 25 2013")
const int   TOP_DATE_3      = timestamp("Dec 11 2017")
const int   TOP_DATE_4      = timestamp("Mar 08 2021")

const float TOP_LEVEL_1     = 8.4704
const float TOP_LEVEL_2     = 4.38125
const float TOP_LEVEL_3     = 3.18706
const float TOP_LEVEL_4     = 2.4353

// Top line coefficients
const float A_TOP_LOG       = -1.4409299283267392
const float B_TOP_LOG       = 40.65324401414959
const int   TOP_OFFSET_DAYS = -131
// R^2 = 0.9991528338211856

const float K_TOP_LIN       = -8.503429283985268e-12
const float B_TOP_LIN       = 5.155114073624485
// R^2 = 0.9955452228512657

// BOTTOMS (Weekly)
const int   BOTTOM_DATE_1   = timestamp("Jun 04 2012")
const int   BOTTOM_DATE_2   = timestamp("Jan 12 2015")
const int   BOTTOM_DATE_3   = timestamp("Dec 10 2018")
const int   BOTTOM_DATE_4   = timestamp("Nov 07 2022")

const float BOTTOM_LEVEL_1  = -1.23489
const float BOTTOM_LEVEL_2  = -1.34397
const float BOTTOM_LEVEL_3  = -1.80557
const float BOTTOM_LEVEL_4  = -1.3735

// Bottom line coefficients
const float K_BOT_LIN       = -7.354479490208776e-13
const float B_BOT_LIN       = -1.2904748619447786
// R^2 = 0.17755260113877847

const string LINE_INPUT_1  = "Log Fit"
const string LINE_INPUT_2  = "Linear Fit"
const string VIEW_INPUT_1  = "Fit Lines"
const string VIEW_INPUT_2  = "Normalized"
const string TT_ZONE_LEVEL = "Value between 0.01 and 0.99"
const string TT_MAIN_PANE  = "Show or hide plotting on the main pane"

// COLORS
const color RANGE_COLOR   = #87CEEB
const color RROI_COLOR    = color.yellow
const color SELL_COLOR    = color.new(color.red, 30)
const color BUY_COLOR     = color.new(color.green, 30)
const color NEUTRAL_COLOR = color.blue

// =========================================================================
// INPUTS
// =========================================================================
string topLineInput = input.string(LINE_INPUT_1, "Top Line", options = [LINE_INPUT_1, LINE_INPUT_2])
string viewInput    = input.string(VIEW_INPUT_1, "View",     options = [VIEW_INPUT_1, VIEW_INPUT_2])

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

bool mainPaneInput = input.bool(true, "Plot on the Main Pane", tooltip = TT_MAIN_PANE)

// =========================================================================
// CALCULATIONS
// =========================================================================
float dailyClose         = request.security("INDEX:BTCUSD", "D", close)
float dailyCloseYearBack = request.security("INDEX:BTCUSD", "D", close[365])

float rroi   = (dailyClose / dailyCloseYearBack - 1) + 1
float rroiLn = math.log(rroi)

// Chart Lines
float topLineLog = (A_TOP_LOG * math.log((time - START_DATE) + (TOP_OFFSET_DAYS * MS_IN_D))) + B_TOP_LOG
float topLineLin = (K_TOP_LIN * (time - START_DATE)) + B_TOP_LIN
float topLine    = topLineInput == LINE_INPUT_1 ? topLineLog : topLineLin

float botLine = (K_BOT_LIN * (time - START_DATE)) + B_BOT_LIN
float midLine = botLine + ((topLine - botLine) / 2.0)

// Risk
float risk = (rroiLn - botLine) / (topLine - botLine)

// =========================================================================
// VISUALS
// =========================================================================
bool  fitLinesView = viewInput == VIEW_INPUT_1

float topBorder = fitLinesView ? topLine : 1.0
float botBorder = fitLinesView ? botLine : 0.0
float midBorder = fitLinesView ? midLine : 0.5
float plotLine  = fitLinesView ? rroiLn  : risk

// FIT LINES
topPlot = plot(topBorder, "Top Line",    RANGE_COLOR, 2)
plot(midBorder,                "Middle Line", RANGE_COLOR, 1)
botPlot = plot(botBorder, "Bottom Line", RANGE_COLOR, 2)

// Buy & Sell Zones
float sellLevelValue = fitLinesView ? (botLine + ((topLine - botLine) * sellZoneLevelInput)) : sellZoneLevelInput
float buyLevelValue  = fitLinesView ? (botLine + ((topLine - botLine) * buyZoneLevelInput))  : buyZoneLevelInput

sellLevelPlot = plot(sellLevelValue, "Sell Level", SELL_COLOR)
buyLevelPlot  = plot(buyLevelValue,  "Buy Level",  BUY_COLOR)

fill(sellLevelPlot, topPlot,      SELL_COLOR, "Sell Zone")
fill(botPlot,       buyLevelPlot, BUY_COLOR,  "Buy Zone")

// RROI
plot(plotLine, "RROI / Risk", RROI_COLOR, 2)

// RISK DISPLAY
plotchar(risk, 'Risk', display = display.data_window + display.status_line, precision = 2, color = color.white)

var table riskDisplay = table.new(position.top_right, 2, 1)
if barstate.islast
    table.cell(riskDisplay, 0, 0, "Risk", text_color = color.white)
    table.cell(riskDisplay, 1, 0, str.tostring(risk, "#.##"), text_color = color.white)

// CHART VIEW
color chartColor = mainPaneInput ? (risk <= buyZoneLevelInput ? BUY_COLOR : (risk >= sellZoneLevelInput ? SELL_COLOR : NEUTRAL_COLOR)) : na
plot(close, "Chart View", chartColor, 2, precision = 2, force_overlay = true)

// Timestamps in Data Window for future fitting
plotchar(TOP_DATE_1 - START_DATE, "Top 1 W", "", location.top, color.white,  display = display.data_window)
plotchar(TOP_DATE_2 - START_DATE, "Top 2 W", "", location.top, color.white,  display = display.data_window)
plotchar(TOP_DATE_3 - START_DATE, "Top 3 W", "", location.top, color.white,  display = display.data_window)
plotchar(TOP_DATE_4 - START_DATE, "Top 4 W", "", location.top, color.white,  display = display.data_window)

plotchar(BOTTOM_DATE_1 - START_DATE, "Bottom 1 W", "", location.top, color.orange, display = display.data_window)
plotchar(BOTTOM_DATE_2 - START_DATE, "Bottom 2 W", "", location.top, color.orange, display = display.data_window)
plotchar(BOTTOM_DATE_3 - START_DATE, "Bottom 3 W", "", location.top, color.orange, display = display.data_window)
plotchar(BOTTOM_DATE_4 - START_DATE, "Bottom 4 W", "", location.top, color.orange, display = display.data_window)
````
