# [CT] Relative Trend Index Advanced Coloring

- url: https://www.tradingview.com/script/67232fk7-CT-Relative-Trend-Index-Advanced-Coloring/
- type: indicator
- pine_id: PUB;9e9d904f80594359ac3630bbad955824
- version: 2.0

## Description

The [b][CT] Relative Trend Index Advanced Coloring[/b] is an enhanced visual version of the original Relative Trend Index, RTI, created by Zeiierman. Full credit and respect go to Zeiierman for the original RTI concept, calculation logic, and foundation of this indicator. This ChaosTrader63 version preserves the original RTI calculation while adding visual upgrades designed to make bullish pressure, bearish pressure, and momentum shifts easier to read in real time.

The Relative Trend Index helps traders evaluate where price is positioned within a dynamic trend range. Instead of only reacting to raw price movement, RTI gives traders a smoother view of whether price is showing strength, weakness, or a possible directional shift. This can help traders recognize developing trend pressure before the move becomes obvious on the price chart.

[b]Updates Added by ChaosTrader63[/b]

[b]Automatic Bullish and Bearish RTI Line Coloring[/b]
The RTI line now changes color based on the selected condition. When the RTI condition is bullish, the line turns green. When the RTI condition is bearish, the line turns red. This makes the indicator easier to read quickly, especially during fast-moving markets.

[b]Selectable RTI Color Mode[/b]
This version includes two different coloring modes, RTI vs MA and RTI vs 50. The RTI vs MA mode colors the RTI based on whether it is above or below its signal line, which can help identify earlier momentum shifts. The RTI vs 50 mode colors the RTI based on whether it is above or below the 50 midline, which can help provide broader trend confirmation.

[b]Optional Price Bar Coloring[/b]
A price bar coloring option has been added so the chart candles can match the RTI condition. When enabled, bullish RTI conditions color the price bars green, and bearish RTI conditions color the price bars red. This helps connect the lower indicator directly to the price chart so traders can see when price action and RTI pressure are aligned.

[b]User-Selectable Bullish and Bearish Colors[/b]
Traders can now choose their own bullish and bearish colors. This allows the indicator to better match each trader’s chart theme, visual preference, or existing trading system.

[b]User-Selectable Moving Average Color[/b]
The RTI signal line color can also be customized. This makes it easier to separate the RTI line from the signal line visually and helps improve chart readability.

[b]Cleaner Input Organization[/b]
The settings have been organized into cleaner groups, including RTI settings, signal line settings, overbought and oversold settings, color settings, and price bar settings. This makes the indicator easier to adjust and understand.

[b]Original RTI Calculation Preserved[/b]
The core Zeiierman RTI calculation has not been changed. This update focuses on visualization and usability, not replacing the original logic.
Original Levels and Alert Conditions Preserved
The 50 midline, overbought level, oversold level, background fill, gradient fills, and alert conditions remain included so traders still have access to the original RTI structure and key reference zones.

This indicator can be used as a trend pressure tool, a momentum confirmation tool, or a visual filter when combined with price action, moving averages, market structure, support and resistance, volume, or ATR-based targets. The goal of this version is to make RTI easier to interpret at a glance while respecting and preserving the original work created by Zeiierman.

The Relative Trend Index is a trend pressure and momentum tool designed to show where price is trading within a dynamic trend range. Instead of simply looking at whether price is moving up or down, the RTI evaluates price in relation to upper and lower trend boundaries. This helps traders see whether the market is showing bullish strength, bearish weakness, or a possible shift in directional pressure.

When the RTI is rising, it can suggest that bullish pressure is building. When the RTI is falling, it can suggest that bearish pressure is increasing. When the RTI moves above its signal line, momentum may be shifting in favor of the bulls. When the RTI moves below its signal line, momentum may be shifting in favor of the bears. The 50 midline can also be used as a broader trend reference. Readings above 50 generally show stronger bullish pressure, while readings below 50 generally show stronger bearish pressure.

The overbought and oversold zones provide additional context. When the RTI moves into the upper zone, it may show strong bullish pressure or an extended move. When it moves into the lower zone, it may show strong bearish pressure or an extended downside move. These areas should not be treated as automatic buy or sell signals, because strong trends can remain elevated or depressed for long periods. The real value of the RTI is in helping traders read pressure, momentum, and possible trend shifts before the move becomes obvious on the price chart.

This tool can be used as a trend pressure indicator, a momentum confirmation tool, or a visual trade filter. Traders may use it with moving averages, price action, market structure, support and resistance, volume, or ATR targets. For example, if the RTI turns bearish, moves below the signal line, and price also breaks below a key moving average, that may confirm stronger downside pressure. If the RTI turns bullish, moves above the signal line, and price reclaims trend structure, that may confirm improving upside pressure.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// © Zeiierman
// Original Script: Relative Trend Index (RTI) by Zeiierman
//
// Updated by: ChaosTrader63
//
// Updates Added by ChaosTrader63:
// 1. Added automatic bullish and bearish RTI line coloring.
// 2. Added selectable RTI color mode using either RTI vs MA or RTI vs 50.
// 3. Added user-selectable bullish and bearish colors.
// 4. Added user-selectable moving average color.
// 5. Added optional price bar coloring to match the RTI condition.
// 6. Reorganized input groups for cleaner settings.
// 7. Preserved the original Zeiierman RTI calculation logic.
// 8. Preserved the original overbought, oversold, midline, background fill, gradient fills, and alert conditions.
// 9. Added Multi-Timeframe RTI capability.
// 10. Added selectable RTI source timeframe so higher-timeframe RTI can be viewed on lower-timeframe charts.
//
//@version=5
indicator("[CT] Relative Trend Index Advanced Coloring MTF", shorttitle="[CT] RTI Advanced MTF", overlay=false, precision=0)

//──────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────
groupMTF = "Multi-Timeframe Settings"
rtiTimeframe = input.timeframe("", "RTI Timeframe", group=groupMTF, tooltip="Leave blank to use the chart timeframe. Select a higher timeframe to view HTF RTI on a lower timeframe chart.")

groupRTI = "Relative Trend Index [RTI]"
trend_data_count             = input.int(100, step=4, minval=10, title="Trend Length", inline="RT", group=groupRTI)
trend_sensitivity_percentage = input.int(95, step=1, minval=50, maxval=98, title="Sensitivity", group=groupRTI)

groupSig = "Signal Line"
signal_length = input.int(20, step=1, minval=1, maxval=200, title="Signal Length (EMA)", group=groupSig)

groupOBOS = "Overbought/Oversold"
ob = input.float(80, step=1, minval=0, maxval=100, title="Overbought", inline="obos", group=groupOBOS)
os = input.float(20, step=1, minval=0, maxval=100, title="Oversold", inline="obos", group=groupOBOS)

groupColors = "Colors"
colorMode = input.string("RTI vs MA", "RTI Color Mode", options=["RTI vs MA", "RTI vs 50"], group=groupColors, tooltip="RTI vs MA: green when RTI > its MA, red when RTI < its MA.\nRTI vs 50: green when RTI >= 50, red when RTI < 50.")

colBull = input.color(#00C853, "Bull Color", group=groupColors)
colBear = input.color(#D50000, "Bear Color", group=groupColors)
maColor = input.color(#00bcd4, "MA Color", group=groupColors)

groupBars = "Price Bars"
colorBars = input.bool(true, "Color Price Bars to Match RTI", group=groupBars)

//──────────────────────────────────────────────────────────────
// RTI Function
// Original Zeiierman RTI calculation logic preserved
//──────────────────────────────────────────────────────────────
f_rti(_trendLen, _sensitivity, _signalLen) =>
    upper_trend = close + ta.stdev(close, 2)
    lower_trend = close - ta.stdev(close, 2)

    upper_array = array.new<float>(0)
    lower_array = array.new<float>(0)

    for i = 0 to _trendLen - 1
        array.push(upper_array, upper_trend[i])
        array.push(lower_array, lower_trend[i])

    array.sort(upper_array)
    array.sort(lower_array)

    upper_index = math.round(_sensitivity / 100 * _trendLen) - 1
    lower_index = math.round((100 - _sensitivity) / 100 * _trendLen) - 1

    upper_index := math.max(0, math.min(upper_index, _trendLen - 1))
    lower_index := math.max(0, math.min(lower_index, _trendLen - 1))

    UpperTrend = array.get(upper_array, upper_index)
    LowerTrend = array.get(lower_array, lower_index)

    rangeRTI = UpperTrend - LowerTrend
    RelativeTrendIndex = rangeRTI != 0 ? ((close - LowerTrend) / rangeRTI) * 100 : 50

    MA_RelativeTrendIndex = ta.ema(RelativeTrendIndex, _signalLen)

    [RelativeTrendIndex, MA_RelativeTrendIndex]

//──────────────────────────────────────────────────────────────
// MTF Calculation
//──────────────────────────────────────────────────────────────
selectedTf = rtiTimeframe == "" ? timeframe.period : rtiTimeframe

[RelativeTrendIndex, MA_RelativeTrendIndex] = request.security(
     syminfo.tickerid,
     selectedTf,
     f_rti(trend_data_count, trend_sensitivity_percentage, signal_length),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────
// Coloring Modes
//──────────────────────────────────────────────────────────────
bool isBull = colorMode == "RTI vs MA" ? RelativeTrendIndex > MA_RelativeTrendIndex : RelativeTrendIndex >= 50
rtiColor = isBull ? colBull : colBear

//──────────────────────────────────────────────────────────────
// Plots
//──────────────────────────────────────────────────────────────
RT = plot(RelativeTrendIndex, "MTF Relative Trend Index (RTI)", color=rtiColor, linewidth=2)
plot(MA_RelativeTrendIndex, "MTF MA of RTI", color=color.new(maColor, 0), linewidth=2)

//──────────────────────────────────────────────────────────────
// Lines
//──────────────────────────────────────────────────────────────
mid        = hline(50, "Mid", color=#606060, linestyle=hline.style_dashed)
overbought = hline(ob, "Overbought", color=#606060, linestyle=hline.style_dashed)
oversold   = hline(os, "Oversold", color=#606060, linestyle=hline.style_dashed)

//──────────────────────────────────────────────────────────────
// BG Fill
// Original background fill preserved
//──────────────────────────────────────────────────────────────
fill(overbought, oversold, color=color.new(color.teal, 90), title="Background")

//──────────────────────────────────────────────────────────────
// Overbought/Oversold Gradient Fill
// Original gradient fills preserved
//──────────────────────────────────────────────────────────────
midLinePlot = plot(50, color=na, editable=false, display=display.none)

fill(RT, midLinePlot, 100, ob, top_color=color.new(color.green, 0), bottom_color=color.new(color.green, 100), title="Overbought Gradient Fill")
fill(RT, midLinePlot, os, 0, top_color=color.new(color.red, 100), bottom_color=color.new(color.red, 0), title="Oversold Gradient Fill")

//──────────────────────────────────────────────────────────────
// Price Bar Coloring
//──────────────────────────────────────────────────────────────
barcolor(colorBars ? rtiColor : na)

//──────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────
alertcondition(ta.crossover(RelativeTrendIndex, MA_RelativeTrendIndex), title="RTI Bullish Cross", message="MTF RTI crossed above its MA.")
alertcondition(ta.crossunder(RelativeTrendIndex, MA_RelativeTrendIndex), title="RTI Bearish Cross", message="MTF RTI crossed below its MA.")

alertcondition(ta.crossover(RelativeTrendIndex, 50), title="RTI Cross Above 50", message="MTF RTI crossed above the 50 midline.")
alertcondition(ta.crossunder(RelativeTrendIndex, 50), title="RTI Cross Below 50", message="MTF RTI crossed below the 50 midline.")

alertcondition(ta.crossover(RelativeTrendIndex, ob), title="RTI Cross Above Overbought", message="MTF RTI crossed above the overbought level.")
alertcondition(ta.crossunder(RelativeTrendIndex, os), title="RTI Cross Below Oversold", message="MTF RTI crossed below the oversold level.")
````
