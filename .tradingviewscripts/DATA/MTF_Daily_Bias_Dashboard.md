<!-- tradingview-pine-id: PUB;d5396f7343554f6fb5c873449500f626 -->
<!-- tradingviewscripts-format: 1 -->
# MTF Daily Bias Dashboard

Source: https://www.tradingview.com/script/psq6MJ8J-MTF-Daily-Bias-Dashboard/

## Description

Overview
The "MTF Daily Bias Dashboard" is a streamlined, non-intrusive utility designed specifically for Smart Money Concepts (SMC) and Inner Circle Trader (ICT) methodologies. Multi-timeframe analysis is the backbone of finding high-probability setups, but constantly switching between charts to check the higher-timeframe narrative can lead to missed lower-timeframe entries.

This indicator solves that problem by providing a clean, customizable on-chart dashboard that displays real-time, objective market bias across three different timeframes simultaneously.

Core Features

[*]Objective Bias Detection: Bias is determined mechanically using a customizable Exponential Moving Average (EMA) and price action closes, removing emotion and guesswork from your directional bias.

[*]Multi-Timeframe Synchronization: By default, it tracks the Daily (1D), 4-Hour (4H), and 15-Minute (15m) timeframes, giving you a complete top-down narrative at a glance.

[*]Non-Repainting Logic: The multi-timeframe data is pulled securely, ensuring that historical signals remain accurate and current data does not repaint past the current candle formation.

[*]Dynamic Visual Dashboard: A color-coded table (Green for Bullish, Red for Bearish) provides immediate visual confirmation of market alignment.

How It Works
The indicator evaluates the current price action against your chosen baseline (EMA).

[*]Bullish (Green):Price closes above the EMA, and the current candle closes higher than the previous candle.

[*]Bearish (Red): Price closes below the EMA, and the current candle closes lower than the previous candle.

[*]Confluence: When all three timeframes show the same color, you have high-probability directional alignment, perfect for looking for lower-timeframe sweeps, order blocks, or fair value gaps in the direction of the trend.

Customization & Settings

[*]Timeframes: Fully adjustable inputs allow you to change the three monitored timeframes to fit your specific trading model (e.g., Weekly/Daily/1H or 4H/1H/5m).
[*]Dashboard Positioning: You can move the dashboard to any corner of your chart to ensure it never obstructs current price action.
[*]Trend Logic: Adjust the EMA length used to calculate the bias to make the indicator more or less sensitive to recent price action.

Who is this for?
This tool is ideal for SMC, ICT, and pure price action traders who rely on the daily narrative but execute on intraday timeframes. It keeps you aligned with the macro trend while you focus on micro executions.

---

## Source Code

````pine
//// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("MTF Daily Bias Dashboard", "MTF Bias", overlay = true)

// --- Constants ---
const string GROUP_TIMEFRAMES = "Timeframe Settings"
const string GROUP_BIAS = "Bias Logic Settings"
const string GROUP_UI = "UI Settings"
const string TOOLTIP_TIMEFRAME = "Timeframe used to calculate this bias."
const string TOOLTIP_EMA = "EMA period used as the trend filter for all selected timeframes."
const string TOOLTIP_POSITION = "Select where the dashboard is displayed on the chart."

// --- Inputs ---
dailyTimeframeInput = input.timeframe("D", "Daily timeframe", group = GROUP_TIMEFRAMES, tooltip = TOOLTIP_TIMEFRAME)
fourHourTimeframeInput = input.timeframe("240", "4-hour timeframe", group = GROUP_TIMEFRAMES, tooltip = TOOLTIP_TIMEFRAME)
fifteenMinuteTimeframeInput = input.timeframe("15", "15-minute timeframe", group = GROUP_TIMEFRAMES, tooltip = TOOLTIP_TIMEFRAME)

emaPeriodInput = input.int(20, "EMA period", minval = 1, group = GROUP_BIAS, tooltip = TOOLTIP_EMA)

tablePositionInput = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_UI, tooltip = TOOLTIP_POSITION)

// --- User-defined functions ---
// Returns 1 for bullish, -1 for bearish, and 0 for neutral/consolidating.
f_getBias(string timeframe) =>
    [confirmedClose, previousClose, confirmedEma] = request.security(
         syminfo.tickerid,
         timeframe,
         [close[1], close[2], ta.ema(close, emaPeriodInput)[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on)
    confirmedClose > confirmedEma and confirmedClose > previousClose ? 1 : confirmedClose < confirmedEma and confirmedClose < previousClose ? -1 : 0

f_getTimeframeLabel(string timeframe) =>
    timeframe == "D" ? "1D" : timeframe == "240" ? "4H" : timeframe == "15" ? "15m" : timeframe

f_getBiasText(int bias) =>
    bias == 1 ? "Bullish" : bias == -1 ? "Bearish" : "Neutral"

f_getBiasColor(int bias) =>
    bias == 1 ? color.new(#089981, 15) : bias == -1 ? color.new(#f23645, 15) : color.new(color.gray, 20)

// --- Core logic ---
dailyBias = f_getBias(dailyTimeframeInput)
fourHourBias = f_getBias(fourHourTimeframeInput)
fifteenMinuteBias = f_getBias(fifteenMinuteTimeframeInput)

// --- Dashboard position ---
tablePosition = switch tablePositionInput
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

// --- Dashboard table ---
var table dashboardTable = table.new(
     tablePosition,
     2,
     4,
     bgcolor = color.new(color.black, 80),
     frame_color = color.new(color.white, 65),
     frame_width = 1,
     border_color = color.new(color.white, 80),
     border_width = 1)

if barstate.islast
    // Header row.
    table.cell(dashboardTable, 0, 0, "Timeframe", text_color = color.white, text_halign = text.align_left, bgcolor = color.new(color.black, 20))
    table.cell(dashboardTable, 1, 0, "Bias", text_color = color.white, text_halign = text.align_center, bgcolor = color.new(color.black, 20))

    // Daily row.
    table.cell(dashboardTable, 0, 1, f_getTimeframeLabel(dailyTimeframeInput), text_color = color.white, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(dashboardTable, 1, 1, f_getBiasText(dailyBias), text_color = color.white, text_halign = text.align_center, bgcolor = f_getBiasColor(dailyBias))

    // Four-hour row.
    table.cell(dashboardTable, 0, 2, f_getTimeframeLabel(fourHourTimeframeInput), text_color = color.white, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(dashboardTable, 1, 2, f_getBiasText(fourHourBias), text_color = color.white, text_halign = text.align_center, bgcolor = f_getBiasColor(fourHourBias))

    // Fifteen-minute row.
    table.cell(dashboardTable, 0, 3, f_getTimeframeLabel(fifteenMinuteTimeframeInput), text_color = color.white, text_halign = text.align_left, bgcolor = color.new(color.black, 80))
    table.cell(dashboardTable, 1, 3, f_getBiasText(fifteenMinuteBias), text_color = color.white, text_halign = text.align_center, bgcolor = f_getBiasColor(fifteenMinuteBias))
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Rahulb1997
````
