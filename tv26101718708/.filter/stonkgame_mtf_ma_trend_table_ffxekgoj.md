# StonkGame MTF MA Trend Table

- url: https://www.tradingview.com/script/fFXeKGOJ-StonkGame-MTF-MA-Trend-Table/
- type: indicator
- pine_id: PUB;dc29110f1bae46bab6786be74b2c74ae
- version: 4.0

## Description

Overview

StonkGame MTF MAs & Trend Table is designed to provide objective market context across multiple trading horizons, regardless of the timeframe you're trading.

Rather than trying to predict future price, it measures where price sits relative to trend, whether that trend is strengthening or weakening, how well different horizons agree with one another, and whether today's move is typical or historically unusual.

The goal is to keep the bigger picture in view, whether you're trading a 1-minute chart or managing a long-term position.

How It Works

Each horizon (Hourly, Daily, Weekly, Monthly, Quarterly, Half-Year, Yearly and Multi-Year) can use its own timeframe and moving average length. Every horizon evaluates:

Price relative to its moving average
Trend direction and momentum
Historical Z-score
Historical percentile
Adaptive normalization

Those measurements are combined into an objective view of trend quality, momentum and cross-horizon alignment.

Adaptive Normalization

Markets don't all behave the same. A 2% move in SPY doesn't carry the same meaning as a 2% move in Bitcoin, crude oil or gold.

Instead of comparing raw price movement, each horizon compares today's reading against that market's own history using up to 1,000 valid observations. If less history exists, the script automatically uses the largest reliable sample available. If there isn't enough data to produce meaningful statistics, it displays N/A rather than potentially misleading values.

Reading the Dashboard

The dashboard is designed to answer four questions:

Trend: Is the market structurally bullish, bearish or mixed?
Momentum: Is that trend strengthening or weakening?
Context: How unusual is the current move relative to its own history?
Alignment: Are different trading horizons telling the same story?

The Setup Score summarizes overall trend quality, consistency and market structure. Higher scores generally reflect cleaner, more aligned conditions, while lower scores suggest greater conflict or uncertainty.

Notes

This indicator is descriptive, not predictive. Strong trends can stay extended, and statistically extreme readings are not automatic buy or sell signals. They are intended to provide context alongside price action, risk management and your own trading process.

Changing the moving average type, timeframe, horizon lengths or normalization settings changes how the market is evaluated. There is no universally correct configuration—choose settings that match your trading horizon and objectives.

## Source Code

````pine
//@version=6

// StonkGame MTF MA State Table

//

// Copyright (C) 2026 StonkGame

//

// Educational purposes only. Not financial advice.

//

// Multi-timeframe moving averages whose colors directly represent the historical

// state of each trading horizon, with an optional dashboard for cross-horizon context.

//

// State combines:

// • Standardized price location relative to each moving average

// • Standardized moving-average slope

// • Optional path-efficiency adjustment to discount choppy trends

//

// Extreme readings describe state intensity, not automatic reversals.

indicator("StonkGame MTF MA State Table", overlay=true, max_bars_back=5000, max_labels_count=100)

// ============================================================================

// Groups

// ============================================================================

string GROUP_DISPLAY = "2. MA Lines & Colors"

string GROUP_STATE = "3. State Calculation"

string GROUP_CONTEXT = "4. Optional Chart Context"

string GROUP_DASHBOARD = "1. Market Readout & Table"

string GROUP_WEIGHTS = "5. Composite Weights"

string GROUP_ALERTS = "6. Readout Thresholds"

string GROUP_HOURLY = "7A. Hourly MA"

string GROUP_DAILY = "7B. Daily MA"

string GROUP_WEEKLY = "7C. Weekly MA"

string GROUP_MONTHLY = "7D. Monthly MA"

string GROUP_QUARTERLY = "7E. Quarterly MA"

string GROUP_HALF_YEAR = "7F. Half-Year MA"

string GROUP_YEARLY = "7G. Yearly MA"

string GROUP_MULTI_YEAR = "7H. Multi-Year MA"

// ============================================================================

// Market readout and table

// ============================================================================

bool showDashboard = input.bool(

     true,

     "Show Trend Table",

     tooltip="Master switch for the dashboard table.",

     group=GROUP_DASHBOARD)

string dashboardPosition = input.string(

     "Top Right",

     "Dashboard Position",

     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"],

     group=GROUP_DASHBOARD, tooltip="Anchor position of the table on the chart. Use the spacer rows to clear chart controls.")

int panelTransparency = input.int(5, "Table Transparency", minval=0, maxval=100, step=5, tooltip="0 makes the entire table opaque so candles and indicators cannot show through it. 100 makes the panel invisible. State cells keep a subtle tint; labels remain neutral.", group=GROUP_DASHBOARD)

string dashboardTextSize = input.string(

     "Small",

     "Text Size",

     options=["Tiny", "Small", "Normal"],

     group=GROUP_DASHBOARD, tooltip="Text size of the dashboard. Smaller sizes fit more information on mobile.")

int blankSpacerRows = input.int(

     3,

     "Blank Spacer Rows Above Table",

     minval=0,

     maxval=10,

     tooltip="Offsets visible dashboard content below TradingView mobile overlays.",

     group=GROUP_DASHBOARD)

bool showReadoutDetails = input.bool(true, "Show Readout Details", group=GROUP_DASHBOARD, tooltip="Show the five rows below the ticker: ST/MT/LT direction, lead, path, annualized realized volatility over 5, 20 and 200 daily returns, and horizon alignment. Volatility uses the standard deviation of daily log returns, annualized with 252 sessions (365 for crypto). Values are displayed as volatility points: 20.0 means 20% annualized realized volatility. This is historical return volatility, not VIX implied volatility or MOVE yield volatility. Compare the three levels to see whether recent price movement is larger or smaller than its medium and long-term history. The 20D window is roughly one trading month. VIX is a forward-looking 30 calendar-day implied measure, so methods and horizons still differ. Turn this off with the horizon section off for a one-line table.")

string rvColorMode = input.string("Neutral", "RV Row Colors", options=["Neutral", "Equity Risk"], group=GROUP_DASHBOARD, tooltip="Neutral uses normal text. Equity Risk colors 5D versus 20D and 20D versus 200D: red when the shorter realized-volatility window is higher, green when lower. The 200D baseline stays neutral. Use Equity Risk for equities only; rising volatility can occur in rallies and is not itself a bearish signal. This setting changes display only.")

bool showHorizonTrendMomentum = input.bool(

     true,

     "Show Horizon Rows",

     tooltip="Show the horizon table. Select individual rows below; hiding rows does not remove them from the market readout or composite.",

     group=GROUP_DASHBOARD)

bool showChartTimeframe = input.bool(

     true,

     "Show Current Chart Timeframe Row",

     tooltip="Adds a local chart-timeframe reading. It is excluded from the fixed composite.",

     group=GROUP_DASHBOARD)

int chartLen = input.int(50, "Current Chart MA Length", minval=2, maxval=1000, group=GROUP_DASHBOARD, tooltip="Moving-average length on the current chart for its optional context row; 2 to 1000 chart bars. It is excluded from the composite.")

bool tableHourly = input.bool(true, "Hourly Row", group=GROUP_DASHBOARD, tooltip="Show the hourly horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableDaily = input.bool(true, "Daily Row", group=GROUP_DASHBOARD, tooltip="Show the daily horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableWeekly = input.bool(true, "Weekly Row", group=GROUP_DASHBOARD, tooltip="Show the weekly horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableMonthly = input.bool(true, "Monthly Row", group=GROUP_DASHBOARD, tooltip="Show the monthly horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableQuarterly = input.bool(true, "Quarterly Row", group=GROUP_DASHBOARD, tooltip="Show the quarterly horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableHalfYear = input.bool(true, "Half-Year Row", group=GROUP_DASHBOARD, tooltip="Show the half-year horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableYearly = input.bool(true, "Yearly Row", group=GROUP_DASHBOARD, tooltip="Show the yearly horizon row in the table. The horizon still contributes to the readout and composite when hidden.")
bool tableMultiYear = input.bool(true, "Multi-Year Row", group=GROUP_DASHBOARD, tooltip="Show the multi-year horizon row in the table. The horizon still contributes to the readout and composite when hidden.")

bool showMethodLabels = input.bool(true, "Show MA / Timeframe Labels", group=GROUP_DASHBOARD, tooltip="Include MA method, length and source timeframe in horizon row names.")

bool showHorizonState = input.bool(

     true,

     "Show Directional State",

     tooltip="Shows Bull, Bear or Neutral from the same state that colors the corresponding MA.",

     group=GROUP_DASHBOARD)

bool showHorizonZScore = input.bool(

     true,

     "Show Z-Score",

     tooltip="Shows standardized price location relative to the selected horizon moving average.",

     group=GROUP_DASHBOARD)

bool showHorizonMomentum = input.bool(

     true,

     "Show Momentum",

     tooltip="Shows efficiency-adjusted standardized moving-average slope.",

     group=GROUP_DASHBOARD)

bool showHorizonPercentile = input.bool(

     true,

     "Show Percentile",

     tooltip="Shows the empirical percentile of price location in the normalization sample.",

     group=GROUP_DASHBOARD)

bool showHorizonSample = input.bool(

     false,

     "Show Sample Size",

     tooltip="Adds the actual adaptive sample size used by each horizon.",

     group=GROUP_DASHBOARD)

bool showSamplingNotice = input.bool(

     true,

     "Show Lower-Timeframe Sampling Notice",

     group=GROUP_DASHBOARD, tooltip="Warn when a requested timeframe is below the chart timeframe; TradingView samples lower timeframe history in that case.")

// ============================================================================

// Display

// ============================================================================

bool showHorizonMAs = input.bool(true, "Show MA Lines", group=GROUP_DISPLAY, tooltip="Show or hide all horizon MA lines. The dashboard can remain visible independently.")

string gradientMode = input.string(

     "Heat",

     "Color Style",

     options=["Heat", "Two-Color", "Classic Horizons"],

     tooltip="Heat maps state from deep red through orange/yellow, grey, cyan/green to lime. Two-Color blends your Bear and Bull colors through neutral grey. Classic Horizons restores the original fixed color for each MA; line color then identifies horizon, not trend. Palette changes never change calculations or signals.",

     group=GROUP_DISPLAY)

color bearishPaletteColor = input.color(color.rgb(220, 50, 65), "Bear Color", tooltip="Two-Color only. Color reached when state is strongly negative. Choose any color; the gradient blends through neutral grey to Bull Color.", group=GROUP_DISPLAY)
color bullishPaletteColor = input.color(color.rgb(0, 190, 120), "Bull Color", tooltip="Two-Color only. Color reached when state is strongly positive. Choose any color; the gradient blends through neutral grey from Bear Color.", group=GROUP_DISPLAY)

color classicHourlyColor = input.color(color.new(color.aqua, 70), "Classic Hourly", tooltip="Classic Horizons only. Fixed color for the hourly MA, matching the original release. Transparency is preserved.", group=GROUP_DISPLAY)
color classicDailyColor = input.color(color.new(color.blue, 50), "Classic Daily", tooltip="Classic Horizons only. Fixed color for the daily MA, matching the original release.", group=GROUP_DISPLAY)
color classicWeeklyColor = input.color(color.new(color.purple, 30), "Classic Weekly", tooltip="Classic Horizons only. Fixed color for the weekly MA, matching the original release.", group=GROUP_DISPLAY)
color classicMonthlyColor = input.color(color.yellow, "Classic Monthly", tooltip="Classic Horizons only. Fixed color for the monthly MA, matching the original release.", group=GROUP_DISPLAY)
color classicQuarterlyColor = input.color(color.orange, "Classic Quarterly", tooltip="Classic Horizons only. Fixed color for the quarterly MA, matching the original release.", group=GROUP_DISPLAY)
color classicHalfYearColor = input.color(color.rgb(238, 107, 1), "Classic Half-Year", tooltip="Classic Horizons only. Fixed color for the half-year MA, matching the original release.", group=GROUP_DISPLAY)
color classicYearlyColor = input.color(color.lime, "Classic Yearly", tooltip="Classic Horizons only. Fixed color for the yearly MA, matching the original release.", group=GROUP_DISPLAY)
color classicStructuralColor = input.color(color.white, "Classic Multi-Year", tooltip="Classic Horizons only. Fixed color for the multi-year MA, matching the original release.", group=GROUP_DISPLAY)

bool showMALabels = input.bool(

     true,

     "Show MA Labels",

     tooltip="Shows compact horizon labels beside the latest value of each enabled MA.",

     group=GROUP_DISPLAY)

int maLabelOffset = input.int(2, "Label Offset", minval=1, maxval=20, group=GROUP_DISPLAY, tooltip="Horizontal distance in chart bars from the latest bar to the MA labels. Larger values move labels farther right; 1 to 20.")

string maLabelSize = input.string(

     "Small",

     "Label Size",

     options=["Tiny", "Small", "Normal"],

     group=GROUP_DISPLAY, tooltip="Text size of labels beside MA lines. This does not alter calculations.")

// ============================================================================

// State calculation

// ============================================================================

string statePreset = input.string("Balanced", "State Model", options=["Balanced", "Trend", "Responsive", "Custom"], tooltip="Balanced combines price location and MA slope equally. Trend favors slope and cleaner paths. Responsive favors price location and reacts faster. Custom uses the expert controls below.", group=GROUP_STATE)
string colorSensitivity = input.string("Normal", "Color Sensitivity", options=["Low", "Normal", "High"], tooltip="High saturates dynamic palettes at smaller state readings; Low needs stronger readings. This changes colors only, not states or notices. Custom state model uses its Full-Color State Level; Classic Horizons uses fixed line colors.", group=GROUP_STATE)
string smoothingPreset = input.string("Balanced", "Response Speed", options=["Fast", "Balanced", "Smooth", "Custom"], tooltip="Fast follows changes sooner; Smooth filters more noise. Custom uses the expert smoothing value below.", group=GROUP_STATE)

string movingAverageType = input.string(

     "EMA",

     "Moving Average Type",

     options=["EMA", "SMA", "WMA", "VWMA"],

     tooltip="Uses the same moving-average method across all horizons.",

     group=GROUP_STATE)

int normalizationLength = input.int(

     1000,

     "Maximum Normalization Sample",

     minval=100,

     maxval=5000,

     group=GROUP_STATE, tooltip="Maximum source-timeframe observations used for each Z-score and percentile. More history gives a broader reference but responds more slowly. The script needs available history.")

int minimumNormalizationSample = input.int(

     30,

     "Minimum Normalization Sample",

     minval=10,

     maxval=250,

     group=GROUP_STATE, tooltip="Minimum valid source-timeframe observations before state and percentile appear. Lower values start sooner with less reliable context.")

float customDisplacementWeight = input.float(

     0.50,

     "Price Location Weight",

     minval=0.0,

     maxval=1.0,

     step=0.05,

     group=GROUP_STATE, tooltip="Custom model only. Relative influence of standardized price distance from its MA. 0 to 1; weights are normalized against the trend weight.")

float customSlopeWeight = input.float(

     0.50,

     "MA Trend Weight",

     minval=0.0,

     maxval=1.0,

     step=0.05,

     group=GROUP_STATE, tooltip="Custom model only. Relative influence of standardized MA slope after path-quality adjustment. 0 to 1; if both weights are zero the model uses 50/50.")

float customSlopeWindowFraction = input.float(

     0.02,

     "Slope Window Fraction",

     minval=0.02,

     maxval=0.50,

     step=0.01,

     group=GROUP_STATE, tooltip="Custom model only. Slope comparison interval as a fraction of each MA length; minimum two source bars. Larger values smooth slope changes.")

bool customUseTrendEfficiency = input.bool(

     true,

     "Adjust Trend by Path Efficiency",

     group=GROUP_STATE, tooltip="Custom model only. Reduce slope contribution when the MA travelled a choppy path. Does not alter price-location contribution.")

float customEfficiencyFloor = input.float(

     0.20,

     "Minimum Trend Efficiency",

     minval=0.0,

     maxval=1.0,

     step=0.05,

     group=GROUP_STATE, tooltip="Custom model only. Minimum fraction of slope retained on a fully choppy path. 0 can suppress it; 1 disables the discount.")

float zLimit = input.float(

     3.0,

     "Calculation Z-Score Limit",

     minval=1.5,

     maxval=5.0,

     step=0.25,

     group=GROUP_STATE, tooltip="Maximum absolute standardized location and slope used in the state calculation. Higher values preserve more extreme observations before clipping.")

float customGradientRange = input.float(

     1.50,

     "Full-Color State Level",

     minval=0.50,

     maxval=3.00,

     step=0.10,

     tooltip="Custom state model only. Absolute state level that receives full dynamic color, 0.5 to 3.0. Smaller values saturate sooner. Classic Horizons lines ignore state colors.",

     group=GROUP_STATE)

int customStateSmoothing = input.int(

     10,

     "State Smoothing",

     minval=1,

     maxval=100,

     tooltip="Custom Response Speed only. EMA length of state, 1 to 100. 1 disables smoothing; larger values filter more noise but respond later.",

     group=GROUP_STATE)

bool completedSourceBars = input.bool(

     true,

     "Use Completed Source Bars Only",

     tooltip="More stable but adds one source-timeframe bar of delay.",

     group=GROUP_STATE)

float displacementWeight = statePreset == "Custom" ? customDisplacementWeight : statePreset == "Trend" ? 0.30 : statePreset == "Responsive" ? 0.70 : 0.50
float slopeWeight = statePreset == "Custom" ? customSlopeWeight : statePreset == "Trend" ? 0.70 : statePreset == "Responsive" ? 0.30 : 0.50
float slopeWindowFraction = statePreset == "Custom" ? customSlopeWindowFraction : statePreset == "Responsive" ? 0.02 : 0.02
bool useTrendEfficiency = statePreset == "Custom" ? customUseTrendEfficiency : true
float efficiencyFloor = statePreset == "Custom" ? customEfficiencyFloor : statePreset == "Trend" ? 0.10 : statePreset == "Responsive" ? 0.35 : 0.20
float gradientRange = statePreset == "Custom" ? customGradientRange : colorSensitivity == "Low" ? 2.00 : colorSensitivity == "High" ? 1.00 : 1.50
int stateSmoothing = smoothingPreset == "Custom" ? customStateSmoothing : smoothingPreset == "Fast" ? 3 : smoothingPreset == "Smooth" ? 18 : 10

// ============================================================================

// Optional context

// ============================================================================

bool showBackground = input.bool(false, "Background State", inline="background", group=GROUP_CONTEXT, tooltip="Shade the chart according to one selected horizon state. This does not change the composite or the Market Readout.")

string backgroundSource = input.string(

     "Monthly",

     "Source",

     options=["Hourly", "Daily", "Weekly", "Monthly", "Quarterly", "Half-Year", "Yearly", "Multi-Year"],

     inline="background",

     group=GROUP_CONTEXT, tooltip="Horizon used for optional chart shading only; dashboard composite and Market Readout use all available weighted horizons.")

int backgroundTransparency = input.int(

     85,

     "Background Transparency",

     minval=75,

     maxval=100,

     tooltip="Higher values are subtler.",

     group=GROUP_CONTEXT)

bool showDirectionMarkers = input.bool(false, "Direction Shift Triangles", tooltip="Optional filled triangles. A bullish marker needs the selected state to first reach the negative reset zone, then cross above the positive shift threshold; bearish is the reverse. A threshold recross alone does not trigger another marker. Confirmed chart bars only. Observed state, not a price forecast.", group=GROUP_CONTEXT)
float directionMarkerThreshold = input.float(1.55, "Direction Shift Level", minval=0.10, maxval=3.00, step=0.05, tooltip="Absolute state level confirming a direction shift, 0.10 to 3.00. Higher levels give fewer, later triangles. Re-arming requires an opposite excursion of half this level (capped at 0.25).", group=GROUP_CONTEXT)
bool showRecoveryMarkers = input.bool(false, "Extreme Recovery Dots", tooltip="Optional blue/orange dots. They appear only after the selected state reaches beyond an extreme and then crosses back toward neutral. This describes a loss of extreme pressure, not a predicted reversal.", group=GROUP_CONTEXT)
float recoveryMarkerThreshold = input.float(2.30, "Recovery Extreme Level", minval=0.50, maxval=4.00, step=0.10, tooltip="Absolute extreme state level, 0.50 to 4.00. The state must first travel at least 5% beyond the level to arm, then cross back through it. Higher levels produce fewer dots.", group=GROUP_CONTEXT)
string markerSource = input.string("Weekly", "Marker Horizon", options=["Hourly", "Daily", "Weekly", "Monthly", "Quarterly", "Half-Year", "Yearly", "Multi-Year"], tooltip="Both optional marker types follow this one horizon state. Choose a slower horizon for fewer, more structural events. This does not change the dashboard or MA colors.", group=GROUP_CONTEXT)

// ============================================================================

// Dashboard

// ============================================================================

// ============================================================================

// Dashboard composite weights

// ============================================================================

float hourlyWeight = input.float(0.05, "Hourly Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the hourly state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float dailyWeight = input.float(0.05, "Daily Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the daily state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float weekWeight = input.float(0.10, "Weekly Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the weekly state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float monthWeight = input.float(0.15, "Monthly Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the monthly state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float quarterWeight = input.float(0.15, "Quarterly Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the quarter state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float intermediateWeight = input.float(0.15, "Half-Year Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the half-year state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float annualWeight = input.float(0.20, "Yearly Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the yearly state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

float structuralWeight = input.float(0.15, "Multi-Year Weight", minval=0.0, maxval=1.0, step=0.05, group=GROUP_WEIGHTS, tooltip="Composite weight of the multi-year state, 0 to 1. Available positive weights are normalized; larger weights give this horizon more influence.")

// ============================================================================

// Dashboard thresholds

// ============================================================================

float broadAlignmentThreshold = input.float(

     70.0,

     "Broad Alignment Threshold",

     minval=50.0,

     maxval=95.0,

     step=5.0,

     group=GROUP_ALERTS, tooltip="Minimum weighted percentage of horizon states pointing the same direction for broad alignment; 0 to 100 percent.")

float extensionThreshold = input.float(

     2.0,

     "Extension Warning",

     minval=1.0,

     maxval=4.0,

     step=0.1,

     group=GROUP_ALERTS, tooltip="Absolute price-location Z-score that flags unusually extended horizons. Higher values warn less often.")

// ============================================================================

// Horizon inputs

// ============================================================================

bool showHourlyMA = input.bool(true, "Show", inline="hourlyMain", group=GROUP_HOURLY, tooltip="Show the hourly horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string hourlyTF = input.timeframe("5", "Timeframe", inline="hourlyMain", group=GROUP_HOURLY, tooltip="Hourly horizon proxy: default 21 MA bars on 5-minute data. Periods and normalization count source bars; lower-than-chart requests may be sampled.")

int hourlyLen = input.int(21, "Period", minval=2, maxval=2000, inline="hourlySettings", group=GROUP_HOURLY, tooltip="Length of the hourly MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int hourlyLineWidth = input.int(1, "Width", minval=1, maxval=4, inline="hourlySettings", group=GROUP_HOURLY, tooltip="Width of the hourly MA plot, 1 to 4 pixels. Visual only.")

bool showDailyMA = input.bool(true, "Show", inline="dailyMain", group=GROUP_DAILY, tooltip="Show the daily horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string dailyTF = input.timeframe("30", "Timeframe", inline="dailyMain", group=GROUP_DAILY, tooltip="Daily horizon proxy: default 21 MA bars on 30-minute data. Periods and normalization count source bars; lower-than-chart requests may be sampled.")

int dailyLen = input.int(21, "Period", minval=2, maxval=2000, inline="dailySettings", group=GROUP_DAILY, tooltip="Length of the daily MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int dailyLineWidth = input.int(1, "Width", minval=1, maxval=4, inline="dailySettings", group=GROUP_DAILY, tooltip="Width of the daily MA plot, 1 to 4 pixels. Visual only.")

bool showWeekMA = input.bool(true, "Show", inline="weekMain", group=GROUP_WEEKLY, tooltip="Show the weekly horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string weekTF = input.timeframe("60", "Timeframe", inline="weekMain", group=GROUP_WEEKLY, tooltip="Weekly horizon proxy: default 40 MA bars on hourly data. Periods and normalization count source bars; lower-than-chart requests may be sampled.")

int weekLen = input.int(40, "Period", minval=2, maxval=2000, inline="weekSettings", group=GROUP_WEEKLY, tooltip="Length of the weekly MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int weekLineWidth = input.int(1, "Width", minval=1, maxval=4, inline="weekSettings", group=GROUP_WEEKLY, tooltip="Width of the weekly MA plot, 1 to 4 pixels. Visual only.")

bool showMonthMA = input.bool(true, "Show", inline="monthMain", group=GROUP_MONTHLY, tooltip="Show the monthly horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string monthTF = input.timeframe("D", "Timeframe", inline="monthMain", group=GROUP_MONTHLY, tooltip="Monthly horizon proxy. Periods and normalization count bars in this source timeframe; lower-than-chart requests may be sampled.")

int monthLen = input.int(20, "Period", minval=2, maxval=2000, inline="monthSettings", group=GROUP_MONTHLY, tooltip="Length of the monthly MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int monthLineWidth = input.int(1, "Width", minval=1, maxval=4, inline="monthSettings", group=GROUP_MONTHLY, tooltip="Width of the monthly MA plot, 1 to 4 pixels. Visual only.")

bool showQuarterMA = input.bool(true, "Show", inline="quarterMain", group=GROUP_QUARTERLY, tooltip="Show the quarter horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string quarterTF = input.timeframe("D", "Timeframe", inline="quarterMain", group=GROUP_QUARTERLY, tooltip="Quarter horizon proxy. Periods and normalization count bars in this source timeframe; lower-than-chart requests may be sampled.")

int quarterLen = input.int(60, "Period", minval=2, maxval=2000, inline="quarterSettings", group=GROUP_QUARTERLY, tooltip="Length of the quarter MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int quarterLineWidth = input.int(2, "Width", minval=1, maxval=4, inline="quarterSettings", group=GROUP_QUARTERLY, tooltip="Width of the quarter MA plot, 1 to 4 pixels. Visual only.")

bool showIntermediateMA = input.bool(true, "Show", inline="halfMain", group=GROUP_HALF_YEAR, tooltip="Show the half-year horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string intermediateTF = input.timeframe("D", "Timeframe", inline="halfMain", group=GROUP_HALF_YEAR, tooltip="Half-year horizon proxy. Periods and normalization count bars in this source timeframe; lower-than-chart requests may be sampled.")

int intermediateLen = input.int(100, "Period", minval=2, maxval=2000, inline="halfSettings", group=GROUP_HALF_YEAR, tooltip="Length of the half-year MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int intermediateLineWidth = input.int(2, "Width", minval=1, maxval=4, inline="halfSettings", group=GROUP_HALF_YEAR, tooltip="Width of the half-year MA plot, 1 to 4 pixels. Visual only.")

bool showAnnualMA = input.bool(true, "Show", inline="annualMain", group=GROUP_YEARLY, tooltip="Show the yearly horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string annualTF = input.timeframe("D", "Timeframe", inline="annualMain", group=GROUP_YEARLY, tooltip="Yearly horizon proxy. Periods and normalization count bars in this source timeframe; lower-than-chart requests may be sampled.")

int annualLen = input.int(200, "Period", minval=2, maxval=2000, inline="annualSettings", group=GROUP_YEARLY, tooltip="Length of the yearly MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int annualLineWidth = input.int(3, "Width", minval=1, maxval=4, inline="annualSettings", group=GROUP_YEARLY, tooltip="Width of the yearly MA plot, 1 to 4 pixels. Visual only.")

bool showStructuralMA = input.bool(true, "Show", inline="structuralMain", group=GROUP_MULTI_YEAR, tooltip="Show the multi-year horizon MA line and its label; the horizon still contributes to the dashboard when hidden.")

string structuralTF = input.timeframe("W", "Timeframe", inline="structuralMain", group=GROUP_MULTI_YEAR, tooltip="Multi-year horizon proxy. Periods and normalization count bars in this source timeframe; lower-than-chart requests may be sampled.")

int structuralLen = input.int(200, "Period", minval=2, maxval=3000, inline="structuralSettings", group=GROUP_MULTI_YEAR, tooltip="Length of the multi-year MA in source-timeframe bars. Larger lengths react more slowly; very long lengths need sufficient chart history.")

int structuralLineWidth = input.int(4, "Width", minval=1, maxval=4, inline="structuralSettings", group=GROUP_MULTI_YEAR, tooltip="Width of the multi-year MA plot, 1 to 4 pixels. Visual only.")

// ============================================================================

// General helpers

// ============================================================================

f_clip(float value, float lower, float upper) =>

    float result = na

    if not na(value)

        result := math.max(lower, math.min(upper, value))

    result

f_safeDiv(float numerator, float denominator) =>

    float result = na

    if not na(numerator) and not na(denominator) and math.abs(denominator) > 0.0000001

        result := numerator / denominator

    result

f_maxAvailable(float firstValue, float secondValue) =>

    float result = na

    if not na(firstValue) and not na(secondValue)

        result := math.max(firstValue, secondValue)

    else if not na(firstValue)

        result := firstValue

    else if not na(secondValue)

        result := secondValue

    result

f_ma(float source, int length) =>

    float emaValue = ta.ema(source, length)

    float smaValue = ta.sma(source, length)

    float wmaValue = ta.wma(source, length)

    float vwmaValue = ta.vwma(source, length)

    float safeVWMA = not na(vwmaValue) ? vwmaValue : emaValue

    float result = emaValue

    if movingAverageType == "SMA"

        result := smaValue

    else if movingAverageType == "WMA"

        result := wmaValue

    else if movingAverageType == "VWMA"

        result := safeVWMA

    result

f_effectiveSample(float source, int maximumLength) =>

    float validObservation = not na(source) ? 1.0 : 0.0

    float cumulativeObservations = ta.cum(validObservation)

    int validCount = int(cumulativeObservations)

    math.min(maximumLength, validCount)

f_adaptiveZScore(float source, int maximumLength, int minimumLength) =>

    int effectiveLength = f_effectiveSample(source, maximumLength)

    int calculationLength = math.max(effectiveLength, 1)

    float meanValue = ta.sma(source, calculationLength)

    float deviationValue = ta.stdev(source, calculationLength)

    float calculatedZ = f_safeDiv(source - meanValue, deviationValue)

    float result = na

    if effectiveLength >= minimumLength

        result := calculatedZ

    result

f_adaptivePercentile(float source, int maximumLength, int minimumLength) =>

    int effectiveLength = f_effectiveSample(source, maximumLength)

    int calculationLength = math.max(effectiveLength, 1)

    float calculatedPercentile = ta.percentrank(source, calculationLength)

    float result = na

    if effectiveLength >= minimumLength

        result := calculatedPercentile

    result

f_classicColor(float stateValue) =>

    color strongBear = color.rgb(220, 50, 65)

    color neutral = color.rgb(145, 145, 145)

    color strongBull = color.rgb(0, 190, 120)

    color result = neutral

    if not na(stateValue)

        float clippedState = f_clip(stateValue, -gradientRange, gradientRange)

        if clippedState >= 0.0

            result := color.from_gradient(clippedState, 0.0, gradientRange, neutral, strongBull)

        else

            result := color.from_gradient(clippedState, -gradientRange, 0.0, strongBear, neutral)

    result

f_heatColor(float stateValue) =>

    color extremeBear = color.rgb(215, 35, 55)

    color bear = color.rgb(235, 95, 35)

    color weakBear = color.rgb(235, 190, 45)

    color neutral = color.rgb(185, 185, 185)

    color weakBull = color.rgb(95, 205, 210)

    color bull = color.rgb(0, 175, 120)

    color extremeBull = color.rgb(125, 220, 60)

    color result = neutral

    if not na(stateValue)

        float x = f_clip(stateValue / gradientRange, -1.0, 1.0)

        if x <= -0.66

            result := color.from_gradient(x, -1.0, -0.66, extremeBear, bear)

        else if x <= -0.20

            result := color.from_gradient(x, -0.66, -0.20, bear, weakBear)

        else if x < 0.0

            result := color.from_gradient(x, -0.20, 0.0, weakBear, neutral)

        else if x < 0.20

            result := color.from_gradient(x, 0.0, 0.20, neutral, weakBull)

        else if x < 0.66

            result := color.from_gradient(x, 0.20, 0.66, weakBull, bull)

        else

            result := color.from_gradient(x, 0.66, 1.0, bull, extremeBull)

    result

f_twoColor(float stateValue) =>
    color result = color.rgb(145, 145, 145)
    if not na(stateValue)
        float clippedState = f_clip(stateValue, -gradientRange, gradientRange)
        if clippedState >= 0.0
            result := color.from_gradient(clippedState, 0.0, gradientRange, color.rgb(145, 145, 145), bullishPaletteColor)
        else
            result := color.from_gradient(clippedState, -gradientRange, 0.0, bearishPaletteColor, color.rgb(145, 145, 145))
    result

f_lineColor(float stateValue, color classicColor) =>
    color result = f_heatColor(stateValue)
    if gradientMode == "Two-Color"
        result := f_twoColor(stateValue)
    else if gradientMode == "Classic Horizons"
        result := classicColor
    result

f_stateColor(float stateValue) =>

    color result = f_classicColor(stateValue)

    if gradientMode == "Heat"

        result := f_heatColor(stateValue)

    else if gradientMode == "Two-Color"

        result := f_twoColor(stateValue)

    result

f_shortTF(string tf) =>

    string result = tf

    if tf == "1"

        result := "1m"

    else if tf == "3"

        result := "3m"

    else if tf == "5"

        result := "5m"

    else if tf == "10"

        result := "10m"

    else if tf == "15"

        result := "15m"

    else if tf == "30"

        result := "30m"

    else if tf == "60"

        result := "1H"

    else if tf == "120"

        result := "2H"

    else if tf == "180"

        result := "3H"

    else if tf == "240"

        result := "4H"

    else if tf == "D" or tf == "1D"

        result := "1D"

    else if tf == "W" or tf == "1W"

        result := "1W"

    else if tf == "M" or tf == "1M"

        result := "1M"

    result

f_labelSize() =>

    string result = size.tiny

    if maLabelSize == "Small"

        result := size.small

    else if maLabelSize == "Normal"

        result := size.normal

    result

f_textSize(string selectedSize) =>

    string result = size.small

    if selectedSize == "Tiny"

        result := size.tiny

    else if selectedSize == "Normal"

        result := size.normal

    result

f_position(string selectedPosition) =>

    string result = position.top_right

    if selectedPosition == "Top Left"

        result := position.top_left

    else if selectedPosition == "Middle Left"

        result := position.middle_left

    else if selectedPosition == "Bottom Left"

        result := position.bottom_left

    else if selectedPosition == "Middle Right"

        result := position.middle_right

    else if selectedPosition == "Bottom Right"

        result := position.bottom_right

    result

f_signedNumber(float value, string numberFormat) =>

    string result = "n/a"

    if not na(value)

        result := str.tostring(value, numberFormat)

        if value > 0.0

            result := "+" + result

    result

f_zText(float value) =>

    string result = "n/a"

    if not na(value)

        result := f_signedNumber(value, "#.0") + "σ"

    result

f_percentileText(float value) =>

    string result = "n/a"

    if not na(value)

        result := str.tostring(math.round(value), "#") + "%ile"

    result

f_stateText(float stateValue) =>

    string result = "Neutral"

    if not na(stateValue)

        if stateValue >= gradientRange

            result := "Strong Bull"

        else if stateValue >= 0.50

            result := "Bull"

        else if stateValue <= -gradientRange

            result := "Strong Bear"

        else if stateValue <= -0.50

            result := "Bear"

    result

f_momentumText(float momentumValue) =>

    string result = "→"

    if not na(momentumValue)

        if momentumValue >= 0.50

            result := "↑"

        else if momentumValue <= -0.50

            result := "↓"

        result := result + " " + f_zText(momentumValue)

    result

f_appendPart(string baseText, string partText) =>

    string result = baseText

    if str.length(partText) > 0

        if str.length(result) > 0

            result := result + " · " + partText

        else

            result := partText

    result

f_horizonContextText(float zValue, float percentileValue, int sampleSize) =>

    string result = ""

    if showHorizonZScore

        result := f_appendPart(result, f_zText(zValue))

    if showHorizonPercentile

        result := f_appendPart(result, f_percentileText(percentileValue))

    if showHorizonSample

        result := f_appendPart(result, "n=" + str.tostring(sampleSize))

    if str.length(result) == 0

        result := "—"

    result

f_horizonLabel(string shortName, int maLength, string tf, bool includeMethod) =>

    string result = shortName

    if includeMethod

        result := shortName + " · " + str.tostring(maLength) + " " + movingAverageType + " / " + f_shortTF(tf)

    result

f_chartLabel(int maLength, bool includeMethod) =>

    string result = "CHART"

    if includeMethod

        result := "CHART · " + str.tostring(maLength) + " " + movingAverageType + " / " + f_shortTF(timeframe.period)

    result

f_availableWeightedValue(float value, float weight) =>

    float result = 0.0

    if not na(value)

        result := value * weight

    result

f_availableWeight(float value, float weight) =>

    float result = 0.0

    if not na(value)

        result := weight

    result

f_alignmentContribution(float stateValue, float stateWeight, float directionSign) =>

    float result = 0.0

    if not na(stateValue)

        bool sameDirection = directionSign >= 0.0 ? stateValue > 0.0 : stateValue < 0.0

        if sameDirection

            float participation = f_clip(math.abs(stateValue) / 0.75, 0.0, 1.0)

            result := stateWeight * participation

    result

// ============================================================================

// Horizon state engine

// ============================================================================

f_horizonPack(int maLength, bool completedOnly) =>

    float sourceValue = close

    float basis = f_ma(sourceValue, maLength)

    float displacement = na

    if not na(basis) and basis > 0.0 and sourceValue > 0.0

        displacement := math.log(sourceValue / basis)

    int displacementSample = f_effectiveSample(displacement, normalizationLength)

    float displacementZ = f_adaptiveZScore(displacement, normalizationLength, minimumNormalizationSample)

    float displacementPercentile = f_adaptivePercentile(displacement, normalizationLength, minimumNormalizationSample)

    int slopeBars = math.max(2, int(math.round(maLength * slopeWindowFraction)))

    float basisPast = basis[slopeBars]

    float slopePerBar = na

    if not na(basis) and not na(basisPast) and basis > 0.0 and basisPast > 0.0

        slopePerBar := math.log(basis / basisPast) / slopeBars

    int slopeSample = f_effectiveSample(slopePerBar, normalizationLength)

    float slopeZ = f_adaptiveZScore(slopePerBar, normalizationLength, minimumNormalizationSample)

    float netPath = na

    if not na(basis) and not na(basisPast)

        netPath := math.abs(basis - basisPast)

    float absoluteBasisChange = math.abs(ta.change(basis))

    float averageBasisChange = ta.sma(absoluteBasisChange, slopeBars)

    float pathMovement = averageBasisChange * slopeBars

    float efficiency = f_safeDiv(netPath, pathMovement)

    efficiency := f_clip(efficiency, 0.0, 1.0)

    float efficiencyMultiplier = 1.0

    if useTrendEfficiency and not na(efficiency)

        efficiencyMultiplier := efficiencyFloor + efficiency * (1.0 - efficiencyFloor)

    float adjustedSlopeZ = na

    if not na(slopeZ)

        adjustedSlopeZ := slopeZ * efficiencyMultiplier

    float componentWeightTotal = displacementWeight + slopeWeight

    float normalizedDisplacementWeight = 0.50

    float normalizedSlopeWeight = 0.50

    if componentWeightTotal > 0.0

        normalizedDisplacementWeight := displacementWeight / componentWeightTotal

        normalizedSlopeWeight := slopeWeight / componentWeightTotal

    float clippedDisplacement = f_clip(displacementZ, -zLimit, zLimit)

    float clippedSlope = f_clip(adjustedSlopeZ, -zLimit, zLimit)

    float rawState = na

    if displacementSample >= minimumNormalizationSample and slopeSample >= minimumNormalizationSample and not na(clippedDisplacement) and not na(clippedSlope)

        rawState := clippedDisplacement * normalizedDisplacementWeight + clippedSlope * normalizedSlopeWeight

    float smoothedState = ta.ema(rawState, stateSmoothing)

    float finalState = rawState

    if stateSmoothing > 1

        finalState := smoothedState

    int commonSample = math.min(displacementSample, slopeSample)

    float outputBasis = basis

    float outputZ = displacementZ

    float outputPct = displacementPercentile

    float outputState = finalState

    float outputMomentum = adjustedSlopeZ

    int outputSample = commonSample

    float outputEfficiency = efficiency

    if completedOnly

        outputBasis := basis[1]

        outputZ := displacementZ[1]

        outputPct := displacementPercentile[1]

        outputState := finalState[1]

        outputMomentum := adjustedSlopeZ[1]

        outputSample := commonSample[1]

        outputEfficiency := efficiency[1]

    [outputBasis, outputZ, outputPct, outputState, outputMomentum, outputSample, outputEfficiency]

// ============================================================================

// Multi-timeframe calculations

// ============================================================================

[hourlyMA, hourlyZ, hourlyPct, hourlyState, hourlyMomentum, hourlySample, hourlyEfficiency] = request.security(syminfo.tickerid, hourlyTF, f_horizonPack(hourlyLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[dailyMA, dailyZ, dailyPct, dailyState, dailyMomentum, dailySample, dailyEfficiency] = request.security(syminfo.tickerid, dailyTF, f_horizonPack(dailyLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[weekMA, weekZ, weekPct, weekState, weekMomentum, weekSample, weekEfficiency] = request.security(syminfo.tickerid, weekTF, f_horizonPack(weekLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[monthMA, monthZ, monthPct, monthState, monthMomentum, monthSample, monthEfficiency] = request.security(syminfo.tickerid, monthTF, f_horizonPack(monthLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[quarterMA, quarterZ, quarterPct, quarterState, quarterMomentum, quarterSample, quarterEfficiency] = request.security(syminfo.tickerid, quarterTF, f_horizonPack(quarterLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[intermediateMA, intermediateZ, intermediatePct, intermediateState, intermediateMomentum, intermediateSample, intermediateEfficiency] = request.security(syminfo.tickerid, intermediateTF, f_horizonPack(intermediateLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[annualMA, annualZ, annualPct, annualState, annualMomentum, annualSample, annualEfficiency] = request.security(syminfo.tickerid, annualTF, f_horizonPack(annualLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[structuralMA, structuralZ, structuralPct, structuralState, structuralMomentum, structuralSample, structuralEfficiency] = request.security(syminfo.tickerid, structuralTF, f_horizonPack(structuralLen, completedSourceBars), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[chartMA, chartZ, chartPct, chartState, chartMomentum, chartSample, chartEfficiency] = f_horizonPack(chartLen, false)

// ============================================================================

// Colors and plots

// ============================================================================

color hourlyColor = f_lineColor(hourlyState, classicHourlyColor)

color dailyColor = f_lineColor(dailyState, classicDailyColor)

color weekColor = f_lineColor(weekState, classicWeeklyColor)

color monthColor = f_lineColor(monthState, classicMonthlyColor)

color quarterColor = f_lineColor(quarterState, classicQuarterlyColor)

color intermediateColor = f_lineColor(intermediateState, classicHalfYearColor)

color annualColor = f_lineColor(annualState, classicYearlyColor)

color structuralColor = f_lineColor(structuralState, classicStructuralColor)

plot(showHorizonMAs and showHourlyMA ? hourlyMA : na, "Hourly State MA", color=hourlyColor, linewidth=hourlyLineWidth)

plot(showHorizonMAs and showDailyMA ? dailyMA : na, "Daily State MA", color=dailyColor, linewidth=dailyLineWidth)

plot(showHorizonMAs and showWeekMA ? weekMA : na, "Weekly State MA", color=weekColor, linewidth=weekLineWidth)

plot(showHorizonMAs and showMonthMA ? monthMA : na, "Monthly State MA", color=monthColor, linewidth=monthLineWidth)

plot(showHorizonMAs and showQuarterMA ? quarterMA : na, "Quarterly State MA", color=quarterColor, linewidth=quarterLineWidth)

plot(showHorizonMAs and showIntermediateMA ? intermediateMA : na, "Half-Year State MA", color=intermediateColor, linewidth=intermediateLineWidth)

plot(showHorizonMAs and showAnnualMA ? annualMA : na, "Yearly State MA", color=annualColor, linewidth=annualLineWidth)

plot(showHorizonMAs and showStructuralMA ? structuralMA : na, "Multi-Year State MA", color=structuralColor, linewidth=structuralLineWidth)

// ============================================================================

// Selected context state

// ============================================================================

float backgroundState = quarterState

if backgroundSource == "Hourly"

    backgroundState := hourlyState

else if backgroundSource == "Daily"

    backgroundState := dailyState

else if backgroundSource == "Weekly"

    backgroundState := weekState

else if backgroundSource == "Monthly"

    backgroundState := monthState

else if backgroundSource == "Half-Year"

    backgroundState := intermediateState

else if backgroundSource == "Yearly"

    backgroundState := annualState

else if backgroundSource == "Multi-Year"

    backgroundState := structuralState

float markerState = monthState

if markerSource == "Hourly"

    markerState := hourlyState

else if markerSource == "Daily"

    markerState := dailyState

else if markerSource == "Weekly"

    markerState := weekState

else if markerSource == "Quarterly"

    markerState := quarterState

else if markerSource == "Half-Year"

    markerState := intermediateState

else if markerSource == "Yearly"

    markerState := annualState

else if markerSource == "Multi-Year"

    markerState := structuralState

color selectedBackgroundColor = f_stateColor(backgroundState)

bgcolor(showBackground ? color.new(selectedBackgroundColor, backgroundTransparency) : na, title="Selected Horizon State Background")

float directionResetLevel = math.min(0.25, directionMarkerThreshold * 0.50)
bool bullishDirectionCross = ta.crossover(markerState, directionMarkerThreshold)
bool bearishDirectionCross = ta.crossunder(markerState, -directionMarkerThreshold)
bool bullishRecoveryCross = ta.crossover(markerState, -recoveryMarkerThreshold)
bool bearishRecoveryCross = ta.crossunder(markerState, recoveryMarkerThreshold)

var bool bullishDirectionArmed = false
var bool bearishDirectionArmed = false
var bool bullishRecoveryArmed = false
var bool bearishRecoveryArmed = false

if barstate.isconfirmed and not na(markerState)
    if markerState <= -directionResetLevel
        bullishDirectionArmed := true
    if markerState >= directionResetLevel
        bearishDirectionArmed := true
    if markerState <= -recoveryMarkerThreshold * 1.05
        bullishRecoveryArmed := true
    if markerState >= recoveryMarkerThreshold * 1.05
        bearishRecoveryArmed := true

bool bullishDirectionEvent = bullishDirectionCross and bullishDirectionArmed and barstate.isconfirmed
bool bearishDirectionEvent = bearishDirectionCross and bearishDirectionArmed and barstate.isconfirmed
bool bullishRecoveryEvent = bullishRecoveryCross and bullishRecoveryArmed and barstate.isconfirmed
bool bearishRecoveryEvent = bearishRecoveryCross and bearishRecoveryArmed and barstate.isconfirmed

if bullishDirectionEvent
    bullishDirectionArmed := false
if bearishDirectionEvent
    bearishDirectionArmed := false
if bullishRecoveryEvent
    bullishRecoveryArmed := false
if bearishRecoveryEvent
    bearishRecoveryArmed := false

plotshape(showDirectionMarkers and bullishDirectionEvent, title="Bullish Direction Shift", style=shape.triangleup, location=location.belowbar, color=color.rgb(0, 190, 120), size=size.tiny)
plotshape(showDirectionMarkers and bearishDirectionEvent, title="Bearish Direction Shift", style=shape.triangledown, location=location.abovebar, color=color.rgb(220, 50, 65), size=size.tiny)
plotshape(showRecoveryMarkers and bullishRecoveryEvent and not bullishDirectionEvent, title="Bullish Extreme Recovery", style=shape.circle, location=location.belowbar, color=color.rgb(0, 185, 255), size=size.tiny)
plotshape(showRecoveryMarkers and bearishRecoveryEvent and not bearishDirectionEvent, title="Bearish Extreme Recovery", style=shape.circle, location=location.abovebar, color=color.rgb(255, 150, 0), size=size.tiny)

// ============================================================================

// Endpoint labels

// ============================================================================

f_updateLabel(label existingLabel, bool enabled, float value, string labelText, color labelColor) =>

    label result = existingLabel

    if not enabled or na(value)

        if not na(result)

            label.delete(result)

            result := na

    else

        if na(result)

            result := label.new(bar_index + maLabelOffset, value, labelText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=labelColor, size=f_labelSize())

        else

            label.set_x(result, bar_index + maLabelOffset)

            label.set_y(result, value)

            label.set_text(result, labelText)

            label.set_textcolor(result, labelColor)

            label.set_size(result, f_labelSize())

    result

var label hourlyLabel = na

var label dailyLabel = na

var label weekLabel = na

var label monthLabel = na

var label quarterLabel = na

var label intermediateLabel = na

var label annualLabel = na

var label structuralLabel = na

if barstate.islast

    bool labelsEnabled = showHorizonMAs and showMALabels

    hourlyLabel := f_updateLabel(hourlyLabel, labelsEnabled and showHourlyMA, hourlyMA, "H · " + str.tostring(hourlyLen) + " " + movingAverageType + " / " + f_shortTF(hourlyTF), hourlyColor)

    dailyLabel := f_updateLabel(dailyLabel, labelsEnabled and showDailyMA, dailyMA, "D · " + str.tostring(dailyLen) + " " + movingAverageType + " / " + f_shortTF(dailyTF), dailyColor)

    weekLabel := f_updateLabel(weekLabel, labelsEnabled and showWeekMA, weekMA, "W · " + str.tostring(weekLen) + " " + movingAverageType + " / " + f_shortTF(weekTF), weekColor)

    monthLabel := f_updateLabel(monthLabel, labelsEnabled and showMonthMA, monthMA, "M · " + str.tostring(monthLen) + " " + movingAverageType + " / " + f_shortTF(monthTF), monthColor)

    quarterLabel := f_updateLabel(quarterLabel, labelsEnabled and showQuarterMA, quarterMA, "Q · " + str.tostring(quarterLen) + " " + movingAverageType + " / " + f_shortTF(quarterTF), quarterColor)

    intermediateLabel := f_updateLabel(intermediateLabel, labelsEnabled and showIntermediateMA, intermediateMA, "6M · " + str.tostring(intermediateLen) + " " + movingAverageType + " / " + f_shortTF(intermediateTF), intermediateColor)

    annualLabel := f_updateLabel(annualLabel, labelsEnabled and showAnnualMA, annualMA, "Y · " + str.tostring(annualLen) + " " + movingAverageType + " / " + f_shortTF(annualTF), annualColor)

    structuralLabel := f_updateLabel(structuralLabel, labelsEnabled and showStructuralMA, structuralMA, "STRUCT · " + str.tostring(structuralLen) + " " + movingAverageType + " / " + f_shortTF(structuralTF), structuralColor)

// ============================================================================

// Dashboard calculations

// ============================================================================

float availableWeightTotal =

     f_availableWeight(hourlyState, hourlyWeight) +

     f_availableWeight(dailyState, dailyWeight) +

     f_availableWeight(weekState, weekWeight) +

     f_availableWeight(monthState, monthWeight) +

     f_availableWeight(quarterState, quarterWeight) +

     f_availableWeight(intermediateState, intermediateWeight) +

     f_availableWeight(annualState, annualWeight) +

     f_availableWeight(structuralState, structuralWeight)

float weightedStateNumerator =

     f_availableWeightedValue(hourlyState, hourlyWeight) +

     f_availableWeightedValue(dailyState, dailyWeight) +

     f_availableWeightedValue(weekState, weekWeight) +

     f_availableWeightedValue(monthState, monthWeight) +

     f_availableWeightedValue(quarterState, quarterWeight) +

     f_availableWeightedValue(intermediateState, intermediateWeight) +

     f_availableWeightedValue(annualState, annualWeight) +

     f_availableWeightedValue(structuralState, structuralWeight)

float weightedState = f_safeDiv(weightedStateNumerator, availableWeightTotal)

float directionSign = not na(weightedState) and weightedState < 0.0 ? -1.0 : 1.0

float alignedWeight =

     f_alignmentContribution(hourlyState, hourlyWeight, directionSign) +

     f_alignmentContribution(dailyState, dailyWeight, directionSign) +

     f_alignmentContribution(weekState, weekWeight, directionSign) +

     f_alignmentContribution(monthState, monthWeight, directionSign) +

     f_alignmentContribution(quarterState, quarterWeight, directionSign) +

     f_alignmentContribution(intermediateState, intermediateWeight, directionSign) +

     f_alignmentContribution(annualState, annualWeight, directionSign) +

     f_alignmentContribution(structuralState, structuralWeight, directionSign)

float alignmentPercent = f_safeDiv(alignedWeight, availableWeightTotal) * 100.0

array<float> horizonStateList = array.from(hourlyState, dailyState, weekState, monthState, quarterState, intermediateState, annualState, structuralState)
int availableHorizonCount = 0
int bullishHorizonCount = 0
int bearishHorizonCount = 0
for horizonValue in horizonStateList
    if not na(horizonValue)
        availableHorizonCount += 1
        if horizonValue >= 0.50
            bullishHorizonCount += 1
        else if horizonValue <= -0.50
            bearishHorizonCount += 1
int neutralHorizonCount = availableHorizonCount - bullishHorizonCount - bearishHorizonCount
string horizonCountText = availableHorizonCount > 0 ? str.tostring(bullishHorizonCount) + "/" + str.tostring(availableHorizonCount) + " Bull" : "n/a"
string horizonRemainderText = availableHorizonCount > 0 ? str.tostring(bearishHorizonCount) + " Bear · " + str.tostring(neutralHorizonCount) + " Flat" : "n/a"



float weightedVarianceNumerator = 0.0

if not na(hourlyState) and not na(weightedState)

    weightedVarianceNumerator += hourlyWeight * math.pow(hourlyState - weightedState, 2)

if not na(dailyState) and not na(weightedState)

    weightedVarianceNumerator += dailyWeight * math.pow(dailyState - weightedState, 2)

if not na(weekState) and not na(weightedState)

    weightedVarianceNumerator += weekWeight * math.pow(weekState - weightedState, 2)

if not na(monthState) and not na(weightedState)

    weightedVarianceNumerator += monthWeight * math.pow(monthState - weightedState, 2)

if not na(quarterState) and not na(weightedState)

    weightedVarianceNumerator += quarterWeight * math.pow(quarterState - weightedState, 2)

if not na(intermediateState) and not na(weightedState)

    weightedVarianceNumerator += intermediateWeight * math.pow(intermediateState - weightedState, 2)

if not na(annualState) and not na(weightedState)

    weightedVarianceNumerator += annualWeight * math.pow(annualState - weightedState, 2)

if not na(structuralState) and not na(weightedState)

    weightedVarianceNumerator += structuralWeight * math.pow(structuralState - weightedState, 2)

float horizonDispersion = math.sqrt(f_safeDiv(weightedVarianceNumerator, availableWeightTotal))

float nearWeightTotal =

     f_availableWeight(hourlyState, hourlyWeight) +

     f_availableWeight(dailyState, dailyWeight) +

     f_availableWeight(weekState, weekWeight) +

     f_availableWeight(monthState, monthWeight) +

     f_availableWeight(quarterState, quarterWeight)

float nearNumerator =

     f_availableWeightedValue(hourlyState, hourlyWeight) +

     f_availableWeightedValue(dailyState, dailyWeight) +

     f_availableWeightedValue(weekState, weekWeight) +

     f_availableWeightedValue(monthState, monthWeight) +

     f_availableWeightedValue(quarterState, quarterWeight)

float nearTermState = f_safeDiv(nearNumerator, nearWeightTotal)

float coreWeightTotal =

     f_availableWeight(intermediateState, intermediateWeight) +

     f_availableWeight(annualState, annualWeight) +

     f_availableWeight(structuralState, structuralWeight)

float coreNumerator =

     f_availableWeightedValue(intermediateState, intermediateWeight) +

     f_availableWeightedValue(annualState, annualWeight) +

     f_availableWeightedValue(structuralState, structuralWeight)

float coreTrendState = f_safeDiv(coreNumerator, coreWeightTotal)

float shortWeight = f_availableWeight(hourlyState, hourlyWeight) + f_availableWeight(dailyState, dailyWeight) + f_availableWeight(weekState, weekWeight)
float shortState = f_safeDiv(f_availableWeightedValue(hourlyState, hourlyWeight) + f_availableWeightedValue(dailyState, dailyWeight) + f_availableWeightedValue(weekState, weekWeight), shortWeight)
float middleWeight = f_availableWeight(monthState, monthWeight) + f_availableWeight(quarterState, quarterWeight)
float middleState = f_safeDiv(f_availableWeightedValue(monthState, monthWeight) + f_availableWeightedValue(quarterState, quarterWeight), middleWeight)
float longState = coreTrendState
float shortEfficiency = f_safeDiv(f_availableWeightedValue(hourlyEfficiency, hourlyWeight) + f_availableWeightedValue(dailyEfficiency, dailyWeight) + f_availableWeightedValue(weekEfficiency, weekWeight), f_availableWeight(hourlyEfficiency, hourlyWeight) + f_availableWeight(dailyEfficiency, dailyWeight) + f_availableWeight(weekEfficiency, weekWeight))
float middleEfficiency = f_safeDiv(f_availableWeightedValue(monthEfficiency, monthWeight) + f_availableWeightedValue(quarterEfficiency, quarterWeight), f_availableWeight(monthEfficiency, monthWeight) + f_availableWeight(quarterEfficiency, quarterWeight))
float longEfficiency = f_safeDiv(f_availableWeightedValue(intermediateEfficiency, intermediateWeight) + f_availableWeightedValue(annualEfficiency, annualWeight) + f_availableWeightedValue(structuralEfficiency, structuralWeight), f_availableWeight(intermediateEfficiency, intermediateWeight) + f_availableWeight(annualEfficiency, annualWeight) + f_availableWeight(structuralEfficiency, structuralWeight))

float momentumStructureSpread = nearTermState - coreTrendState

float hourlyAbsZ = not na(hourlyZ) ? math.abs(hourlyZ) : na

float dailyAbsZ = not na(dailyZ) ? math.abs(dailyZ) : na

float weekAbsZ = not na(weekZ) ? math.abs(weekZ) : na

float monthAbsZ = not na(monthZ) ? math.abs(monthZ) : na

float quarterAbsZ = not na(quarterZ) ? math.abs(quarterZ) : na

float nearTermExtension = f_maxAvailable(hourlyAbsZ, f_maxAvailable(dailyAbsZ, f_maxAvailable(weekAbsZ, f_maxAvailable(monthAbsZ, quarterAbsZ))))

f_dailyVolatilityZ() =>

    float dailyATR = ta.atr(14)

    float atrPercent = na

    if close != 0.0

        atrPercent := dailyATR / close * 100.0

    float meanATRPercent = ta.sma(atrPercent, 252)

    float devATRPercent = ta.stdev(atrPercent, 252)

    f_safeDiv(atrPercent - meanATRPercent, devATRPercent)

float volatilityZ = request.security(syminfo.tickerid, "D", f_dailyVolatilityZ(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_realizedVolatility() =>
    float dailyReturn = math.log(close / close[1])
    float annualDays = syminfo.type == "crypto" ? 365.0 : 252.0
    float fiveDayVol = ta.stdev(dailyReturn, 5) * math.sqrt(annualDays) * 100.0
    float twentyDayVol = ta.stdev(dailyReturn, 20) * math.sqrt(annualDays) * 100.0
    float twoHundredDayVol = ta.stdev(dailyReturn, 200) * math.sqrt(annualDays) * 100.0
    [fiveDayVol, twentyDayVol, twoHundredDayVol]

[fiveDayRealizedVol, twentyDayRealizedVol, twoHundredDayRealizedVol] = request.security(syminfo.tickerid, "D", f_realizedVolatility(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_volPoints(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0")

f_rvComparisonColor(float shorter, float longer) =>
    color result = chart.fg_color
    if rvColorMode == "Equity Risk" and not na(shorter) and not na(longer)
        result := shorter > longer ? color.rgb(220, 80, 85) : shorter < longer ? color.rgb(0, 190, 120) : chart.fg_color
    result

f_directionWord(float value) =>
    string result = na(value) ? "n/a" : value >= 0.25 ? "Bull" : value <= -0.25 ? "Bear" : "Mixed"
    result

f_pathWord(float value) =>
    string result = na(value) ? "n/a" : value >= 0.65 ? "Clean" : value <= 0.35 ? "Choppy" : "Uneven"
    result

int chartSeconds = timeframe.in_seconds()

bool hasLowerTimeframeRequests =

     timeframe.in_seconds(hourlyTF) < chartSeconds or

     timeframe.in_seconds(dailyTF) < chartSeconds or

     timeframe.in_seconds(weekTF) < chartSeconds or

     timeframe.in_seconds(monthTF) < chartSeconds or

     timeframe.in_seconds(quarterTF) < chartSeconds or

     timeframe.in_seconds(intermediateTF) < chartSeconds or

     timeframe.in_seconds(annualTF) < chartSeconds or

     timeframe.in_seconds(structuralTF) < chartSeconds

bool nearTermExtended = not na(nearTermExtension) and nearTermExtension >= extensionThreshold
bool nearUpExtended = (not na(hourlyZ) and hourlyZ >= extensionThreshold) or (not na(dailyZ) and dailyZ >= extensionThreshold) or (not na(weekZ) and weekZ >= extensionThreshold) or (not na(monthZ) and monthZ >= extensionThreshold) or (not na(quarterZ) and quarterZ >= extensionThreshold)
bool nearDownExtended = (not na(hourlyZ) and hourlyZ <= -extensionThreshold) or (not na(dailyZ) and dailyZ <= -extensionThreshold) or (not na(weekZ) and weekZ <= -extensionThreshold) or (not na(monthZ) and monthZ <= -extensionThreshold) or (not na(quarterZ) and quarterZ <= -extensionThreshold)
bool highDisagreement = not na(horizonDispersion) and horizonDispersion >= 1.0
bool moderateDisagreement = not na(horizonDispersion) and horizonDispersion >= 0.65
bool broadAligned = not na(alignmentPercent) and alignmentPercent >= broadAlignmentThreshold and availableHorizonCount > 0 and math.max(bullishHorizonCount, bearishHorizonCount) * 100.0 / availableHorizonCount >= broadAlignmentThreshold
bool primaryBull = not na(coreTrendState) and coreTrendState >= 0.50
bool primaryBear = not na(coreTrendState) and coreTrendState <= -0.50
bool nearBear = not na(nearTermState) and nearTermState <= -0.25
bool nearBull = not na(nearTermState) and nearTermState >= 0.25
bool nearFading = not na(nearTermState) and not na(nearTermState[5]) and nearTermState - nearTermState[5] <= -0.35
bool nearImproving = not na(nearTermState) and not na(nearTermState[5]) and nearTermState - nearTermState[5] >= 0.35
bool volatilityExtreme = not na(volatilityZ) and volatilityZ >= 2.0
bool volatilityElevated = not na(volatilityZ) and volatilityZ >= 1.0
bool volatilityCompressed = not na(volatilityZ) and volatilityZ <= -1.0

string primaryNoticeText = "Mixed horizons limit directional conviction"
string primaryNoticeDisplayText = "MIXED HORIZONS · LOW CONVICTION"
color primaryNoticeColor = color.rgb(225, 165, 45)

if volatilityExtreme and primaryBear
    primaryNoticeText := "Bearish trend coincides with an unusually high daily ATR relative to price"
    primaryNoticeDisplayText := "BEAR TREND · ATR EXTREME"
    primaryNoticeColor := f_stateColor(coreTrendState)
else if volatilityExtreme and primaryBull
    primaryNoticeText := "Bullish trend coincides with an unusually high daily ATR relative to price"
    primaryNoticeDisplayText := "BULL TREND · ATR EXTREME"
else if not na(longState) and longState >= 0.25 and not na(shortState) and shortState <= -0.25
    primaryNoticeText := "Short-term weakness is developing against a positive longer horizon"
    primaryNoticeDisplayText := "LT POSITIVE · ST WEAKNESS"
    primaryNoticeColor := color.rgb(225, 165, 45)
else if not na(longState) and longState <= -0.25 and not na(shortState) and shortState >= 0.25
    primaryNoticeText := "Short-term strength is developing against a negative longer horizon"
    primaryNoticeDisplayText := "LT NEGATIVE · ST BOUNCE"
    primaryNoticeColor := color.rgb(225, 165, 45)
else if primaryBull and nearBear and nearFading
    primaryNoticeText := "Short-term weakness is developing within a bullish primary trend"
    primaryNoticeDisplayText := "BULL TREND · EARLY DETERIORATION"
else if primaryBear and nearBull and nearImproving
    primaryNoticeText := "Short-term strength is improving before primary-trend confirmation"
    primaryNoticeDisplayText := "BEAR TREND · RECOVERY ATTEMPT"
else if primaryBear and nearBull
    primaryNoticeText := "Short-term bounce remains counter to the bearish primary trend"
    primaryNoticeDisplayText := "BEAR TREND · COUNTERTREND BOUNCE"
else if primaryBull and nearBear
    primaryNoticeText := "Short-term weakness remains inside a bullish primary trend"
    primaryNoticeDisplayText := "BULL TREND · PULLBACK"
else if highDisagreement
    primaryNoticeText := "High cross-horizon conflict limits directional conviction"
    primaryNoticeDisplayText := "HIGH CROSS-HORIZON CONFLICT"
else if nearUpExtended and primaryBull
    primaryNoticeText := "Bullish structure remains intact, but near-term price is extended"
    primaryNoticeDisplayText := "BULL TREND · NEAR-TERM EXTENDED"
else if nearDownExtended and primaryBear
    primaryNoticeText := "Bearish structure remains intact, but near-term price is oversold"
    primaryNoticeDisplayText := "BEAR TREND · NEAR-TERM OVERSOLD"
else if nearUpExtended
    primaryNoticeText := "Near-term rally is extended without broad trend confirmation"
    primaryNoticeDisplayText := "RALLY EXTENDED · UNCONFIRMED"
else if nearDownExtended
    primaryNoticeText := "Near-term selloff is extended without broad trend confirmation"
    primaryNoticeDisplayText := "SELLOFF EXTENDED · UNCONFIRMED"
else if primaryBull and nearFading
    primaryNoticeText := "Bullish primary structure remains intact as short-term momentum fades"
    primaryNoticeDisplayText := "BULL TREND · MOMENTUM FADING"
else if primaryBear and nearImproving
    primaryNoticeText := "Bearish primary structure remains intact as short-term momentum improves"
    primaryNoticeDisplayText := "BEAR TREND · MOMENTUM IMPROVING"
else if moderateDisagreement
    primaryNoticeText := "Trend horizons disagree; directional conviction is limited"
    primaryNoticeDisplayText := "MIXED HORIZON ALIGNMENT"
else if volatilityElevated and primaryBear
    primaryNoticeText := "Bearish trend coincides with elevated daily ATR relative to price"
    primaryNoticeDisplayText := "BEAR TREND · ATR ELEVATED"
else if volatilityElevated and primaryBull
    primaryNoticeText := "Bullish trend coincides with elevated daily ATR relative to price"
    primaryNoticeDisplayText := "BULL TREND · ATR ELEVATED"
else if volatilityCompressed and not primaryBull and not primaryBear
    primaryNoticeText := "Daily ATR relative to price is low while trend direction remains unresolved"
    primaryNoticeDisplayText := "NEUTRAL · ATR COMPRESSED"
    primaryNoticeColor := f_stateColor(weightedState)
else if broadAligned and primaryBull and nearBull
    primaryNoticeText := "Bullish structure is broadly aligned across trading horizons"
    primaryNoticeDisplayText := "BROAD BULL ALIGNMENT"
    primaryNoticeColor := f_stateColor(weightedState)
else if broadAligned and primaryBear and nearBear
    primaryNoticeText := "Bearish structure is broadly aligned across trading horizons"
    primaryNoticeDisplayText := "BROAD BEAR ALIGNMENT"
    primaryNoticeColor := f_stateColor(weightedState)
else if not na(weightedState) and weightedState >= 0.50
    primaryNoticeText := "Bullish structure leads, but confirmation is not yet broad"
    primaryNoticeDisplayText := "BULLISH · PARTIAL CONFIRMATION"
    primaryNoticeColor := f_stateColor(weightedState)
else if not na(weightedState) and weightedState <= -0.50
    primaryNoticeText := "Bearish structure leads, but confirmation is not yet broad"
    primaryNoticeDisplayText := "BEARISH · PARTIAL CONFIRMATION"
    primaryNoticeColor := f_stateColor(weightedState)

else if not na(weightedState) and weightedState >= 0.12
    primaryNoticeText := "Direction is mixed, with a weak positive composite lean"
    primaryNoticeDisplayText := "MIXED · WEAK POSITIVE LEAN"
    primaryNoticeColor := color.rgb(225, 165, 45)
else if not na(weightedState) and weightedState <= -0.12
    primaryNoticeText := "Direction is mixed, with a weak negative composite lean"
    primaryNoticeDisplayText := "MIXED · WEAK NEGATIVE LEAN"
    primaryNoticeColor := color.rgb(225, 165, 45)

float shortContribution = na(shortState) ? na : math.abs(shortState) * shortWeight
float middleContribution = na(middleState) ? na : math.abs(middleState) * middleWeight
float longContribution = na(longState) ? na : math.abs(longState) * coreWeightTotal
string leadingGroup = "n/a"
if not na(shortContribution) or not na(middleContribution) or not na(longContribution)
    float strongestContribution = math.max(nz(shortContribution), math.max(nz(middleContribution), nz(longContribution)))
    leadingGroup := strongestContribution == nz(shortContribution) ? "ST" : strongestContribution == nz(middleContribution) ? "MT" : "LT"
string relationshipText = "Limited history"
if not na(shortState) and not na(longState)
    relationshipText := shortState >= 0.25 and longState <= -0.25 ? "Countertrend" : shortState <= -0.25 and longState >= 0.25 ? "Pullback" : shortState >= 0.25 and longState >= 0.25 ? "Bull aligned" : shortState <= -0.25 and longState <= -0.25 ? "Bear aligned" : "Mixed"
string alignmentReadout = availableHorizonCount == 0 ? "n/a" : highDisagreement ? "High conflict" : broadAligned ? "Broad" : "Mixed"

// ============================================================================

// Dashboard table

// ============================================================================

int TABLE_COLUMNS = 4

int TABLE_ROWS = 48

var table dashboard = table.new(

     f_position(dashboardPosition),

     TABLE_COLUMNS,

     TABLE_ROWS,

     frame_color=color.new(chart.fg_color, 100),

     frame_width=0,

     border_color=color.new(chart.fg_color, 100),

     border_width=0)

var bool tableLayoutInitialized = false

color panelBackground = color.new(chart.bg_color, panelTransparency)

f_panelTint(color tintColor, float tintShare) =>
    int redComponent = int(math.round(color.r(chart.bg_color) * (1.0 - tintShare) + color.r(tintColor) * tintShare))
    int greenComponent = int(math.round(color.g(chart.bg_color) * (1.0 - tintShare) + color.g(tintColor) * tintShare))
    int blueComponent = int(math.round(color.b(chart.bg_color) * (1.0 - tintShare) + color.b(tintColor) * tintShare))
    color.new(color.rgb(redComponent, greenComponent, blueComponent), panelTransparency)

color sectionBackground = f_panelTint(chart.fg_color, 0.07)

color mutedText = color.new(chart.fg_color, 38)

color transparentBackground = color.new(chart.bg_color, 100)

string selectedTextSize = f_textSize(dashboardTextSize)

f_cell(int column, int row, string cellText, color textColor, color backgroundColor, string alignment) =>

    string horizontalAlignment = text.align_center

    if alignment == "Left"

        horizontalAlignment := text.align_left

    else if alignment == "Right"

        horizontalAlignment := text.align_right

    table.cell(dashboard, column, row, cellText, text_color=textColor, bgcolor=backgroundColor, text_size=selectedTextSize, text_halign=horizontalAlignment)

f_blankRow(int row) =>

    f_cell(0, row, "", color.new(chart.fg_color, 100), transparentBackground, "Left")

    f_cell(1, row, "", color.new(chart.fg_color, 100), transparentBackground, "Left")

    f_cell(2, row, "", color.new(chart.fg_color, 100), transparentBackground, "Left")

    f_cell(3, row, "", color.new(chart.fg_color, 100), transparentBackground, "Left")

f_mergedRow(int row, string rowText, color textColor, color backgroundColor) =>

    f_cell(0, row, rowText, textColor, backgroundColor, "Left")

f_horizonHeaderRow(int row) =>

    f_cell(0, row, "HORIZON", mutedText, sectionBackground, "Left")

    f_cell(1, row, "TREND", mutedText, sectionBackground, "Left")

    f_cell(2, row, "CONTEXT", mutedText, sectionBackground, "Left")

    f_cell(3, row, "MOMENTUM", mutedText, sectionBackground, "Right")

f_horizonRow(int row, string rowLabel, float stateValue, float zValue, float percentileValue, float momentumValue, int sampleSize) =>

    color rowColor = f_stateColor(stateValue)

    color rowBackground = f_panelTint(rowColor, 0.10)

    string directionText = showHorizonState ? f_stateText(stateValue) : ""

    string contextText = f_horizonContextText(zValue, percentileValue, sampleSize)

    string momentumText = showHorizonMomentum ? f_momentumText(momentumValue) : ""

    f_cell(0, row, rowLabel, rowColor, rowBackground, "Left")

    f_cell(1, row, directionText, rowColor, rowBackground, "Left")

    f_cell(2, row, contextText, rowColor, rowBackground, "Left")

    f_cell(3, row, momentumText, rowColor, rowBackground, "Right")

if barstate.islast

    table.clear(dashboard, 0, 0, TABLE_COLUMNS - 1, TABLE_ROWS - 1)

    int row = 0

    if showDashboard

        if blankSpacerRows > 0

            for spacerRow = 0 to blankSpacerRows - 1

                f_blankRow(row)

                row += 1

        int noticeRow = row

        if not tableLayoutInitialized

            table.merge_cells(dashboard, 0, noticeRow, 3, noticeRow)

        f_mergedRow(noticeRow, syminfo.ticker + " - " + primaryNoticeDisplayText, primaryNoticeColor, f_panelTint(primaryNoticeColor, 0.16))

        row += 1

        if showReadoutDetails
            color readoutBackground = panelBackground
            f_cell(0, row, "HORIZONS", mutedText, panelBackground, "Left")
            f_cell(1, row, "ST " + f_directionWord(shortState), f_stateColor(shortState), readoutBackground, "Left")
            f_cell(2, row, "MT " + f_directionWord(middleState), f_stateColor(middleState), readoutBackground, "Left")
            f_cell(3, row, "LT " + f_directionWord(longState), f_stateColor(longState), readoutBackground, "Right")
            row += 1
            f_cell(0, row, "LEAD", mutedText, panelBackground, "Left")
            f_cell(1, row, leadingGroup + " leads", chart.fg_color, readoutBackground, "Left")
            f_cell(2, row, relationshipText, chart.fg_color, readoutBackground, "Left")
            f_cell(3, row, "", chart.fg_color, readoutBackground, "Right")
            row += 1
            f_cell(0, row, "PATH", mutedText, panelBackground, "Left")
            f_cell(1, row, "ST " + f_pathWord(shortEfficiency), chart.fg_color, readoutBackground, "Left")
            f_cell(2, row, "MT " + f_pathWord(middleEfficiency), chart.fg_color, readoutBackground, "Left")
            f_cell(3, row, "LT " + f_pathWord(longEfficiency), chart.fg_color, readoutBackground, "Right")
            row += 1
            f_cell(0, row, "RV (ANN.)", mutedText, panelBackground, "Left")
            f_cell(1, row, "5D " + f_volPoints(fiveDayRealizedVol), f_rvComparisonColor(fiveDayRealizedVol, twentyDayRealizedVol), readoutBackground, "Left")
            f_cell(2, row, "20D " + f_volPoints(twentyDayRealizedVol), f_rvComparisonColor(twentyDayRealizedVol, twoHundredDayRealizedVol), readoutBackground, "Left")
            f_cell(3, row, "200D " + f_volPoints(twoHundredDayRealizedVol), chart.fg_color, readoutBackground, "Right")
            row += 1
            f_cell(0, row, "ALIGNMENT", mutedText, panelBackground, "Left")
            f_cell(1, row, horizonCountText, f_stateColor(weightedState), readoutBackground, "Left")
            f_cell(2, row, horizonRemainderText, chart.fg_color, readoutBackground, "Left")
            f_cell(3, row, alignmentReadout, highDisagreement ? primaryNoticeColor : chart.fg_color, readoutBackground, "Right")
            row += 1

        if showHorizonTrendMomentum

            if showChartTimeframe

                int chartHeaderRow = row

                if not tableLayoutInitialized

                    table.merge_cells(dashboard, 0, chartHeaderRow, 3, chartHeaderRow)

                f_mergedRow(chartHeaderRow, "CURRENT CHART · EXCLUDED FROM COMPOSITE", mutedText, sectionBackground)

                row += 1

                f_horizonRow(row, f_chartLabel(chartLen, showMethodLabels), chartState, chartZ, chartPct, chartMomentum, chartSample)

                row += 1

            if tableHourly or tableDaily or tableWeekly or tableMonthly or tableQuarterly or tableHalfYear or tableYearly or tableMultiYear
                f_horizonHeaderRow(row)
                row += 1

            if tableHourly
                f_horizonRow(row, f_horizonLabel("HOURLY", hourlyLen, hourlyTF, showMethodLabels), hourlyState, hourlyZ, hourlyPct, hourlyMomentum, hourlySample)

                row += 1

            if tableDaily
                f_horizonRow(row, f_horizonLabel("DAILY", dailyLen, dailyTF, showMethodLabels), dailyState, dailyZ, dailyPct, dailyMomentum, dailySample)

                row += 1

            if tableWeekly
                f_horizonRow(row, f_horizonLabel("WEEKLY", weekLen, weekTF, showMethodLabels), weekState, weekZ, weekPct, weekMomentum, weekSample)

                row += 1

            if tableMonthly
                f_horizonRow(row, f_horizonLabel("MONTHLY", monthLen, monthTF, showMethodLabels), monthState, monthZ, monthPct, monthMomentum, monthSample)

                row += 1

            if tableQuarterly
                f_horizonRow(row, f_horizonLabel("QUARTERLY", quarterLen, quarterTF, showMethodLabels), quarterState, quarterZ, quarterPct, quarterMomentum, quarterSample)

                row += 1

            if tableHalfYear
                f_horizonRow(row, f_horizonLabel("HALF-YEAR", intermediateLen, intermediateTF, showMethodLabels), intermediateState, intermediateZ, intermediatePct, intermediateMomentum, intermediateSample)

                row += 1

            if tableYearly
                f_horizonRow(row, f_horizonLabel("YEARLY", annualLen, annualTF, showMethodLabels), annualState, annualZ, annualPct, annualMomentum, annualSample)

                row += 1

            if tableMultiYear
                f_horizonRow(row, f_horizonLabel("MULTI-YEAR", structuralLen, structuralTF, showMethodLabels), structuralState, structuralZ, structuralPct, structuralMomentum, structuralSample)
                row += 1

        if showSamplingNotice and hasLowerTimeframeRequests and (showReadoutDetails or showHorizonTrendMomentum)
            int samplingRow = row
            if not tableLayoutInitialized
                table.merge_cells(dashboard, 0, samplingRow, 3, samplingRow)
            f_mergedRow(samplingRow, "LOWER-TIMEFRAME HISTORY IS SAMPLED ON THIS CHART", color.rgb(225, 165, 45), f_panelTint(color.rgb(225, 165, 45), 0.16))
            row += 1

        tableLayoutInitialized := true
````
