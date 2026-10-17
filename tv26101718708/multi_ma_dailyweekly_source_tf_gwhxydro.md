# Multi MA (Daily/Weekly Source TF)

- url: https://www.tradingview.com/script/GWHXYdRO/
- type: indicator
- pine_id: PUB;fbced64dc36f48d2963ec9055b698753
- version: 4.0

## Description

# Multi MA (Daily/Weekly Source TF)

Multi MA (Daily/Weekly Source TF) is a flexible multi-timeframe moving average indicator built for traders who want one MA system for daily and non-weekly charts, and a different MA system for weekly charts, without constantly changing settings by hand. Each line can be configured independently for type, length, source, source timeframe, visibility, color, and width, making it possible to track daily-based structure on higher timeframes while keeping a separate weekly trend framework inside the same script.

This script is a multi-moving-average indicator designed for traders who want different moving average configurations on daily charts and weekly charts, while still being able to display daily-based moving averages on higher timeframes such as monthly or yearly charts.

Traditional moving average indicators are usually limited to a single chart timeframe context. That creates a common workflow problem: the moving average set that makes sense on a daily chart is often not the same set you want on a weekly chart. As a result, traders end up manually changing inputs every time they switch timeframes.

This script solves that problem by allowing each moving average line to have independent settings for:

- Daily / non-weekly charts
- Weekly charts

In addition, each line can use its own source, moving average type, length, source timeframe, visibility settings, color, and width.

## What This Script Does

The indicator supports up to 10 moving average lines. For each line, you can configure:

- Daily type: `SMA` or `EMA`
- Daily length
- Daily price source
- Daily source timeframe
- Whether to show the line on daily / other non-weekly charts

And separately:

- Weekly type: `SMA` or `EMA`
- Weekly length
- Weekly price source
- Weekly source timeframe
- Whether to show the line on weekly charts

This means the same line can behave differently depending on whether the current chart is weekly or not.

## Core Idea

The script uses two logic layers:

1. Display logic based on the current chart timeframe
2. Calculation logic based on the selected source timeframe

When the current chart is weekly, the script uses the weekly configuration for that line.

When the current chart is anything other than weekly, the script uses the daily configuration for that line.

Because the moving averages are calculated using the selected source timeframe instead of the current chart timeframe alone, you can do things like:

- View a 5-day EMA on a monthly chart
- View a 200-day SMA on a yearly chart
- Use a different weekly structure without changing the daily structure

This is especially useful for traders who anchor their analysis on daily trend structure but still want to inspect that same structure from higher-level chart views.

## Example Use Case

A common setup might look like this:

On daily and other non-weekly charts:

- Line 1 = EMA 5-day
- Line 2 = EMA 9-day
- Line 3 = EMA 21-day
- Line 4 = SMA 50-day
- Line 5 = SMA 150-day
- Line 6 = SMA 200-day

On weekly charts:

- Line 4 = SMA 10-week
- Line 5 = SMA 30-week
- Line 6 = SMA 40-week

In this workflow:

- Daily charts show the shorter-term and long-term daily trend structure
- Weekly charts automatically switch to a cleaner higher-timeframe structure
- Monthly and yearly charts can still display daily-based moving averages if desired

## Why This Script Is Useful

This script is built to address several practical issues that appear in real trading workflows:

- Switching between daily and weekly charts often requires different MA systems
- Standard MA indicators usually force one configuration across all timeframes
- Higher timeframe charts often hide the daily structure traders still want to track
- Multiple indicators or repeated manual adjustments create clutter and inefficiency

By separating daily and weekly configurations per line, this script keeps your charting workflow more consistent and more efficient.

## Key Features

- Up to 10 moving average lines
- Per-line `SMA` / `EMA` selection
- Per-line daily and weekly lengths
- Per-line daily and weekly source price selection
- Per-line daily and weekly source timeframe selection
- Per-line daily and weekly visibility control
- Works on any chart timeframe
- Can display daily-based moving averages on higher timeframe charts
- Useful for multi-timeframe trend analysis

## How To Use

1. Set `Number of lines` to define how many moving average lines you want active.
2. For each active line, configure the daily / non-weekly settings:
   - Daily Type
   - Daily Length
   - Daily Source Timeframe
   - Daily Source
   - Show On Daily/Other Charts
3. Configure the weekly settings for the same line:
   - Weekly Type
   - Weekly Length
   - Weekly Source Timeframe
   - Weekly Source
   - Show On Weekly Charts
4. Adjust line color and width as needed.

## Intended Use

This indicator is best suited for:

- Multi-timeframe traders
- Trend-following systems
- Swing trading workflows
- Market structure analysis
- Traders who want daily and weekly moving average systems inside a single script

## Notes

- Weekly settings are only used when the current chart timeframe is weekly.
- All non-weekly charts use the daily configuration.
- Because the script can request data from a specific source timeframe, a moving average such as `EMA 5D` can still be displayed on monthly or yearly charts.

## Source Code

````pine
//by Ousgnay
//@version=6
indicator(title="Multi MA (Daily/Weekly Source TF)", shorttitle="Multi MA", overlay=true)

maxLines = 10

generalGroup = "General"
lineCountInput = input.string("6", "Number of lines", options=["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], group=generalGroup)
lineCount = int(str.tonumber(lineCountInput))
line2Enabled = lineCount >= 2
line3Enabled = lineCount >= 3
line4Enabled = lineCount >= 4
line5Enabled = lineCount >= 5
line6Enabled = lineCount >= 6
line7Enabled = lineCount >= 7
line8Enabled = lineCount >= 8
line9Enabled = lineCount >= 9
line10Enabled = lineCount >= 10

// Automatic selection changes calculation parameters, not input defaults.
aShareGroup = "A股交易所"
exchangePrefix = syminfo.prefix
exchangeIsAShare = exchangePrefix == "CFFEX" or exchangePrefix == "SSE" or exchangePrefix == "SHFE" or exchangePrefix == "SZSE" or exchangePrefix == "ZCE"
// Some feeds expose an empty/unstable prefix. A six-digit numeric symbol is
// the fallback used for Chinese A-share stocks and ETFs such as SSE:515180.
tickerIsSixDigit = str.length(syminfo.ticker) == 6 and not na(str.tonumber(syminfo.ticker))
detectedAShareExchange = exchangeIsAShare or tickerIsSixDigit
exchangeMode = input.string("自动识别", "配置模式", options=["自动识别", "强制非A股交易所", "强制A股交易所"], group=generalGroup)
aShareExchange = exchangeMode == "强制A股交易所" or (exchangeMode == "自动识别" and detectedAShareExchange)

// Data Window diagnostics only; no table or extra chart line.
plot(detectedAShareExchange ? 1 : 0, title="自动识别：1=A股 / 0=非A股", display=display.data_window, editable=false)
plot(aShareExchange ? 1 : 0, title="实际配置：1=A股 / 0=非A股", display=display.data_window, editable=false)
// Active configuration indicator.
// The selected profile is highlighted; the other profile is dimmed.
var table profileTable = table.new(position.top_right, 2, 1, border_width=1)
if barstate.islast
    table.cell(profileTable, 0, 0, "A股", bgcolor=aShareExchange ? color.new(color.red, 0) : color.new(color.gray, 75), text_color=color.white)
    table.cell(profileTable, 1, 0, "非A股", bgcolor=aShareExchange ? color.new(color.gray, 75) : color.new(color.blue, 0), text_color=color.white)

// A股 profile: only values that differ from the non-A股 profile are exposed.
// Source, visibility and source timeframe continue to inherit the base inputs.
aLine1DailyType = input.string("SMA", "Line 1 · Daily Type", options=["SMA", "EMA"], group=aShareGroup)
aLine1DailyLength = input.int(5, "Line 1 · Daily Length", minval=1, group=aShareGroup)
aLine2DailyType = input.string("SMA", "Line 2 · Daily Type", options=["SMA", "EMA"], group=aShareGroup)
aLine2DailyLength = input.int(10, "Line 2 · Daily Length", minval=1, group=aShareGroup)
aLine3DailyType = input.string("SMA", "Line 3 · Daily Type", options=["SMA", "EMA"], group=aShareGroup)
aLine3DailyLength = input.int(20, "Line 3 · Daily Length", minval=1, group=aShareGroup)
aLine4DailyType = input.string("SMA", "Line 4 · Daily Type", options=["SMA", "EMA"], group=aShareGroup)
aLine4DailyLength = input.int(60, "Line 4 · Daily Length", minval=1, group=aShareGroup)
aLine4WeeklyType = input.string("SMA", "Line 4 · Weekly Type", options=["SMA", "EMA"], group=aShareGroup)
aLine4WeeklyLength = input.int(12, "Line 4 · Weekly Length", minval=1, group=aShareGroup)
aLine5DailyType = input.string("SMA", "Line 5 · Daily Type", options=["SMA", "EMA"], group=aShareGroup)
aLine5DailyLength = input.int(120, "Line 5 · Daily Length", minval=1, group=aShareGroup)
aLine5WeeklyType = input.string("SMA", "Line 5 · Weekly Type", options=["SMA", "EMA"], group=aShareGroup)
aLine5WeeklyLength = input.int(30, "Line 5 · Weekly Length", minval=1, group=aShareGroup)
aLine6DailyType = input.string("SMA", "Line 6 · Daily Type", options=["SMA", "EMA"], group=aShareGroup)
aLine6DailyLength = input.int(250, "Line 6 · Daily Length", minval=1, group=aShareGroup)
aLine6WeeklyType = input.string("SMA", "Line 6 · Weekly Type", options=["SMA", "EMA"], group=aShareGroup)
aLine6WeeklyLength = input.int(60, "Line 6 · Weekly Length", minval=1, group=aShareGroup)

maFromTimeframe(sourceInput, maType, length, sourceTf) =>
    request.security(syminfo.tickerid, sourceTf, maType == "EMA" ? ta.ema(sourceInput, length) : ta.sma(sourceInput, length), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

getActiveType(dailyType, weeklyType) =>
    timeframe.isweekly ? weeklyType : dailyType

getActiveLength(dailyLength, weeklyLength) =>
    timeframe.isweekly ? weeklyLength : dailyLength

getActiveSourceTf(dailySourceTf, weeklySourceTf) =>
    timeframe.isweekly ? weeklySourceTf : dailySourceTf

getActiveSource(dailySource, weeklySource) =>
    timeframe.isweekly ? weeklySource : dailySource

getActiveVisible(dailyVisible, weeklyVisible) =>
    timeframe.isweekly ? weeklyVisible : dailyVisible

getLineValue(dailySource, weeklySource, dailyType, weeklyType, dailyLength, weeklyLength, dailySourceTf, weeklySourceTf) =>
    // Compute each source timeframe independently. Select on the chart afterwards.
    dailyValue = maFromTimeframe(dailySource, dailyType, dailyLength, dailySourceTf)
    weeklyValue = maFromTimeframe(weeklySource, weeklyType, weeklyLength, weeklySourceTf)
    timeframe.isweekly ? weeklyValue : dailyValue

// Line inputs

line1Group = "非A股交易所 · Line 1"
line1DailyVisible = input.bool(true, "Show On Daily/Other Charts", group=line1Group)
line1DailyType = input.string("EMA", "Daily Type", options=["SMA", "EMA"], group=line1Group)
line1DailyLength = input.int(5, "Daily Length", minval=1, group=line1Group)
line1DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line1Group)
line1DailySource = input.source(close, "Daily Source", group=line1Group)
line1WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line1Group)
line1WeeklyType = input.string("EMA", "Weekly Type", options=["SMA", "EMA"], group=line1Group)
line1WeeklyLength = input.int(5, "Weekly Length", minval=1, group=line1Group)
line1WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line1Group)
line1WeeklySource = input.source(close, "Weekly Source", group=line1Group)
line1Color = color.new(#dbdbdb, 0)
line1Visible = getActiveVisible(line1DailyVisible, line1WeeklyVisible)
line1NonA = getLineValue(line1DailySource, line1WeeklySource, line1DailyType, line1WeeklyType, line1DailyLength, line1WeeklyLength, line1DailySourceTf, line1WeeklySourceTf)
line1A = getLineValue(line1DailySource, line1WeeklySource, aLine1DailyType, line1WeeklyType, aLine1DailyLength, line1WeeklyLength, line1DailySourceTf, line1WeeklySourceTf)
line1 = aShareExchange ? line1A : line1NonA
plot(lineCount >= 1 and line1Visible ? line1 : na, title="Line 1", color=line1Color)

line2Group = "非A股交易所 · Line 2"
line2DailyVisible = input.bool(true, "Show On Daily/Other Charts", group=line2Group, active=line2Enabled)
line2DailyType = input.string("EMA", "Daily Type", options=["SMA", "EMA"], group=line2Group, active=line2Enabled)
line2DailyLength = input.int(9, "Daily Length", minval=1, group=line2Group, active=line2Enabled)
line2DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line2Group, active=line2Enabled)
line2DailySource = input.source(close, "Daily Source", group=line2Group, active=line2Enabled)
line2WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line2Group, active=line2Enabled)
line2WeeklyType = input.string("EMA", "Weekly Type", options=["SMA", "EMA"], group=line2Group, active=line2Enabled)
line2WeeklyLength = input.int(9, "Weekly Length", minval=1, group=line2Group, active=line2Enabled)
line2WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line2Group, active=line2Enabled)
line2WeeklySource = input.source(close, "Weekly Source", group=line2Group, active=line2Enabled)
line2Color = color.new(#3179f5, 0)
line2Visible = getActiveVisible(line2DailyVisible, line2WeeklyVisible)
line2NonA = getLineValue(line2DailySource, line2WeeklySource, line2DailyType, line2WeeklyType, line2DailyLength, line2WeeklyLength, line2DailySourceTf, line2WeeklySourceTf)
line2A = getLineValue(line2DailySource, line2WeeklySource, aLine2DailyType, line2WeeklyType, aLine2DailyLength, line2WeeklyLength, line2DailySourceTf, line2WeeklySourceTf)
line2 = aShareExchange ? line2A : line2NonA
plot(lineCount >= 2 and line2Visible ? line2 : na, title="Line 2", color=line2Color)

line3Group = "非A股交易所 · Line 3"
line3DailyVisible = input.bool(true, "Show On Daily/Other Charts", group=line3Group, active=line3Enabled)
line3DailyType = input.string("EMA", "Daily Type", options=["SMA", "EMA"], group=line3Group, active=line3Enabled)
line3DailyLength = input.int(21, "Daily Length", minval=1, group=line3Group, active=line3Enabled)
line3DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line3Group, active=line3Enabled)
line3DailySource = input.source(close, "Daily Source", group=line3Group, active=line3Enabled)
line3WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line3Group, active=line3Enabled)
line3WeeklyType = input.string("EMA", "Weekly Type", options=["SMA", "EMA"], group=line3Group, active=line3Enabled)
line3WeeklyLength = input.int(21, "Weekly Length", minval=1, group=line3Group, active=line3Enabled)
line3WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line3Group, active=line3Enabled)
line3WeeklySource = input.source(close, "Weekly Source", group=line3Group, active=line3Enabled)
line3Color = color.new(#ff9800, 0)
line3Visible = getActiveVisible(line3DailyVisible, line3WeeklyVisible)
line3NonA = getLineValue(line3DailySource, line3WeeklySource, line3DailyType, line3WeeklyType, line3DailyLength, line3WeeklyLength, line3DailySourceTf, line3WeeklySourceTf)
line3A = getLineValue(line3DailySource, line3WeeklySource, aLine3DailyType, line3WeeklyType, aLine3DailyLength, line3WeeklyLength, line3DailySourceTf, line3WeeklySourceTf)
line3 = aShareExchange ? line3A : line3NonA
plot(lineCount >= 3 and line3Visible ? line3 : na, title="Line 3", color=line3Color)

line4Group = "非A股交易所 · Line 4"
line4DailyVisible = input.bool(true, "Show On Daily/Other Charts", group=line4Group, active=line4Enabled)
line4DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line4Group, active=line4Enabled)
line4DailyLength = input.int(50, "Daily Length", minval=1, group=line4Group, active=line4Enabled)
line4DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line4Group, active=line4Enabled)
line4DailySource = input.source(close, "Daily Source", group=line4Group, active=line4Enabled)
line4WeeklyVisible = input.bool(true, "Show On Weekly Charts", group=line4Group, active=line4Enabled)
line4WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line4Group, active=line4Enabled)
line4WeeklyLength = input.int(10, "Weekly Length", minval=1, group=line4Group, active=line4Enabled)
line4WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line4Group, active=line4Enabled)
line4WeeklySource = input.source(close, "Weekly Source", group=line4Group, active=line4Enabled)
line4Color = color.new(#7e57c2, 0)
line4Visible = getActiveVisible(line4DailyVisible, line4WeeklyVisible)
line4NonA = getLineValue(line4DailySource, line4WeeklySource, line4DailyType, line4WeeklyType, line4DailyLength, line4WeeklyLength, line4DailySourceTf, line4WeeklySourceTf)
line4A = getLineValue(line4DailySource, line4WeeklySource, aLine4DailyType, aLine4WeeklyType, aLine4DailyLength, aLine4WeeklyLength, line4DailySourceTf, line4WeeklySourceTf)
line4 = aShareExchange ? line4A : line4NonA
plot(lineCount >= 4 and line4Visible ? line4 : na, title="Line 4", color=line4Color)

line5Group = "非A股交易所 · Line 5"
line5DailyVisible = input.bool(true, "Show On Daily/Other Charts", group=line5Group, active=line5Enabled)
line5DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line5Group, active=line5Enabled)
line5DailyLength = input.int(150, "Daily Length", minval=1, group=line5Group, active=line5Enabled)
line5DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line5Group, active=line5Enabled)
line5DailySource = input.source(close, "Daily Source", group=line5Group, active=line5Enabled)
line5WeeklyVisible = input.bool(true, "Show On Weekly Charts", group=line5Group, active=line5Enabled)
line5WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line5Group, active=line5Enabled)
line5WeeklyLength = input.int(30, "Weekly Length", minval=1, group=line5Group, active=line5Enabled)
line5WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line5Group, active=line5Enabled)
line5WeeklySource = input.source(close, "Weekly Source", group=line5Group, active=line5Enabled)
line5Color = color.new(#4caf50, 0)
line5Visible = getActiveVisible(line5DailyVisible, line5WeeklyVisible)
line5NonA = getLineValue(line5DailySource, line5WeeklySource, line5DailyType, line5WeeklyType, line5DailyLength, line5WeeklyLength, line5DailySourceTf, line5WeeklySourceTf)
line5A = getLineValue(line5DailySource, line5WeeklySource, aLine5DailyType, aLine5WeeklyType, aLine5DailyLength, aLine5WeeklyLength, line5DailySourceTf, line5WeeklySourceTf)
line5 = aShareExchange ? line5A : line5NonA
plot(lineCount >= 5 and line5Visible ? line5 : na, title="Line 5", color=line5Color)

line6Group = "非A股交易所 · Line 6"
line6DailyVisible = input.bool(true, "Show On Daily/Other Charts", group=line6Group, active=line6Enabled)
line6DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line6Group, active=line6Enabled)
line6DailyLength = input.int(200, "Daily Length", minval=1, group=line6Group, active=line6Enabled)
line6DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line6Group, active=line6Enabled)
line6DailySource = input.source(close, "Daily Source", group=line6Group, active=line6Enabled)
line6WeeklyVisible = input.bool(true, "Show On Weekly Charts", group=line6Group, active=line6Enabled)
line6WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line6Group, active=line6Enabled)
line6WeeklyLength = input.int(40, "Weekly Length", minval=1, group=line6Group, active=line6Enabled)
line6WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line6Group, active=line6Enabled)
line6WeeklySource = input.source(close, "Weekly Source", group=line6Group, active=line6Enabled)
line6Color = color.new(#f23645, 0)
line6Visible = getActiveVisible(line6DailyVisible, line6WeeklyVisible)
line6NonA = getLineValue(line6DailySource, line6WeeklySource, line6DailyType, line6WeeklyType, line6DailyLength, line6WeeklyLength, line6DailySourceTf, line6WeeklySourceTf)
line6A = getLineValue(line6DailySource, line6WeeklySource, aLine6DailyType, aLine6WeeklyType, aLine6DailyLength, aLine6WeeklyLength, line6DailySourceTf, line6WeeklySourceTf)
line6 = aShareExchange ? line6A : line6NonA
plot(lineCount >= 6 and line6Visible ? line6 : na, title="Line 6", color=line6Color)

line7Group = "非A股交易所 · Line 7"
line7DailyVisible = input.bool(false, "Show On Daily/Other Charts", group=line7Group, active=line7Enabled)
line7DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line7Group, active=line7Enabled)
line7DailyLength = input.int(144, "Daily Length", minval=1, group=line7Group, active=line7Enabled)
line7DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line7Group, active=line7Enabled)
line7DailySource = input.source(close, "Daily Source", group=line7Group, active=line7Enabled)
line7WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line7Group, active=line7Enabled)
line7WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line7Group, active=line7Enabled)
line7WeeklyLength = input.int(144, "Weekly Length", minval=1, group=line7Group, active=line7Enabled)
line7WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line7Group, active=line7Enabled)
line7WeeklySource = input.source(close, "Weekly Source", group=line7Group, active=line7Enabled)
line7Color = color.new(color.teal, 0)
line7Visible = getActiveVisible(line7DailyVisible, line7WeeklyVisible)
line7 = getLineValue(line7DailySource, line7WeeklySource, line7DailyType, line7WeeklyType, line7DailyLength, line7WeeklyLength, line7DailySourceTf, line7WeeklySourceTf)
plot(lineCount >= 7 and line7Visible ? line7 : na, title="Line 7", color=line7Color, display=display.none)

line8Group = "非A股交易所 · Line 8"
line8DailyVisible = input.bool(false, "Show On Daily/Other Charts", group=line8Group, active=line8Enabled)
line8DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line8Group, active=line8Enabled)
line8DailyLength = input.int(169, "Daily Length", minval=1, group=line8Group, active=line8Enabled)
line8DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line8Group, active=line8Enabled)
line8DailySource = input.source(close, "Daily Source", group=line8Group, active=line8Enabled)
line8WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line8Group, active=line8Enabled)
line8WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line8Group, active=line8Enabled)
line8WeeklyLength = input.int(169, "Weekly Length", minval=1, group=line8Group, active=line8Enabled)
line8WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line8Group, active=line8Enabled)
line8WeeklySource = input.source(close, "Weekly Source", group=line8Group, active=line8Enabled)
line8Color = color.new(color.gray, 0)
line8Visible = getActiveVisible(line8DailyVisible, line8WeeklyVisible)
line8 = getLineValue(line8DailySource, line8WeeklySource, line8DailyType, line8WeeklyType, line8DailyLength, line8WeeklyLength, line8DailySourceTf, line8WeeklySourceTf)
plot(lineCount >= 8 and line8Visible ? line8 : na, title="Line 8", color=line8Color, display=display.none)

line9Group = "非A股交易所 · Line 9"
line9DailyVisible = input.bool(false, "Show On Daily/Other Charts", group=line9Group, active=line9Enabled)
line9DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line9Group, active=line9Enabled)
line9DailyLength = input.int(250, "Daily Length", minval=1, group=line9Group, active=line9Enabled)
line9DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line9Group, active=line9Enabled)
line9DailySource = input.source(close, "Daily Source", group=line9Group, active=line9Enabled)
line9WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line9Group, active=line9Enabled)
line9WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line9Group, active=line9Enabled)
line9WeeklyLength = input.int(250, "Weekly Length", minval=1, group=line9Group, active=line9Enabled)
line9WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line9Group, active=line9Enabled)
line9WeeklySource = input.source(close, "Weekly Source", group=line9Group, active=line9Enabled)
line9Color = color.new(color.navy, 0)
line9Visible = getActiveVisible(line9DailyVisible, line9WeeklyVisible)
line9 = getLineValue(line9DailySource, line9WeeklySource, line9DailyType, line9WeeklyType, line9DailyLength, line9WeeklyLength, line9DailySourceTf, line9WeeklySourceTf)
plot(lineCount >= 9 and line9Visible ? line9 : na, title="Line 9", color=line9Color, display=display.none)

line10Group = "非A股交易所 · Line 10"
line10DailyVisible = input.bool(false, "Show On Daily/Other Charts", group=line10Group, active=line10Enabled)
line10DailyType = input.string("SMA", "Daily Type", options=["SMA", "EMA"], group=line10Group, active=line10Enabled)
line10DailyLength = input.int(300, "Daily Length", minval=1, group=line10Group, active=line10Enabled)
line10DailySourceTf = input.timeframe("D", "Daily Source Timeframe", group=line10Group, active=line10Enabled)
line10DailySource = input.source(close, "Daily Source", group=line10Group, active=line10Enabled)
line10WeeklyVisible = input.bool(false, "Show On Weekly Charts", group=line10Group, active=line10Enabled)
line10WeeklyType = input.string("SMA", "Weekly Type", options=["SMA", "EMA"], group=line10Group, active=line10Enabled)
line10WeeklyLength = input.int(300, "Weekly Length", minval=1, group=line10Group, active=line10Enabled)
line10WeeklySourceTf = input.timeframe("W", "Weekly Source Timeframe", group=line10Group, active=line10Enabled)
line10WeeklySource = input.source(close, "Weekly Source", group=line10Group, active=line10Enabled)
line10Color = color.new(#eb228d, 0)
line10Visible = getActiveVisible(line10DailyVisible, line10WeeklyVisible)
line10 = getLineValue(line10DailySource, line10WeeklySource, line10DailyType, line10WeeklyType, line10DailyLength, line10WeeklyLength, line10DailySourceTf, line10WeeklySourceTf)
plot(lineCount >= 10 and line10Visible ? line10 : na, title="Line 10", color=line10Color, display=display.none)



line1AppliedLength = timeframe.isweekly ? (aShareExchange ? line1WeeklyLength : line1WeeklyLength) : (aShareExchange ? aLine1DailyLength : line1DailyLength)
plot(line1AppliedLength, title="Line 1 实际计算长度", display=display.data_window, editable=false)

line2AppliedLength = timeframe.isweekly ? (aShareExchange ? line2WeeklyLength : line2WeeklyLength) : (aShareExchange ? aLine2DailyLength : line2DailyLength)
plot(line2AppliedLength, title="Line 2 实际计算长度", display=display.data_window, editable=false)

line3AppliedLength = timeframe.isweekly ? (aShareExchange ? line3WeeklyLength : line3WeeklyLength) : (aShareExchange ? aLine3DailyLength : line3DailyLength)
plot(line3AppliedLength, title="Line 3 实际计算长度", display=display.data_window, editable=false)

line4AppliedLength = timeframe.isweekly ? (aShareExchange ? aLine4WeeklyLength : line4WeeklyLength) : (aShareExchange ? aLine4DailyLength : line4DailyLength)
plot(line4AppliedLength, title="Line 4 实际计算长度", display=display.data_window, editable=false)

line5AppliedLength = timeframe.isweekly ? (aShareExchange ? aLine5WeeklyLength : line5WeeklyLength) : (aShareExchange ? aLine5DailyLength : line5DailyLength)
plot(line5AppliedLength, title="Line 5 实际计算长度", display=display.data_window, editable=false)

line6AppliedLength = timeframe.isweekly ? (aShareExchange ? aLine6WeeklyLength : line6WeeklyLength) : (aShareExchange ? aLine6DailyLength : line6DailyLength)
plot(line6AppliedLength, title="Line 6 实际计算长度", display=display.data_window, editable=false)

plot(line4A, title="核对：Line 4 A股均线值", display=display.data_window, editable=false)
plot(line4NonA, title="核对：Line 4 非A股均线值", display=display.data_window, editable=false)
````
