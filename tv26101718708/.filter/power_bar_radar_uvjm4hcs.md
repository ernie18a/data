# Power Bar Radar

- url: https://www.tradingview.com/script/UVJm4HCs-Power-Bar-Radar/
- type: indicator
- pine_id: PUB;9ecdd147baf24688b47ae4bc0f1b315b
- version: 3.0

## Description

1. Overview

Power Bar Radar is a visual candle-analysis indicator designed to highlight candles with unusually strong directional behavior.

The indicator uses only the current chart symbol's own data. It does not use any external benchmark, comparison symbol, or market index.

The purpose of the indicator is to help traders identify candles that may deserve extra attention because they show a statistically large move, strong close location, and range expansion.

This is an indicator, not a strategy. It does not place trades, does not execute orders, and does not produce TradingView Strategy Tester results.

2. Core Idea

Not every green candle is strong.

Not every red candle is important.

Power Bar Radar attempts to separate ordinary candles from candles that show unusual directional pressure.

A candle is marked as a Power Bar only when several conditions align on the same bar.

The indicator is designed to answer this question:

Is this candle normal, or is it showing unusually strong directional behavior?

3. Power Bar Conditions

A candle is classified as a Power Bar only when the following conditions are met:

1. Significant move

The candle's net move must be statistically large compared with recent bars.

The script uses a z-score style calculation to compare the current candle's net change with recent price changes.

2. Strong close location

A bullish Power Bar must close near the upper part of its candle range.

A bearish Power Bar must close near the lower part of its candle range.

This helps avoid marking candles that moved strongly during the bar but failed to hold that move into the close.

3. Range expansion

The candle range must be wider than the recent average range.

This helps filter out small or quiet candles that do not show meaningful expansion.

4. Optional volume confirmation

The script includes an optional volume filter.

When enabled, the candle must also have volume above its recent average by a selected factor.

This can help add an additional confirmation layer on markets with reliable volume data.

4. Bull Power Bar

A Bull Power Bar appears when the candle shows strong upward behavior.

The default bull power color is yellow.

A Bull Power Bar may indicate that buyers showed strong control during that candle.

However, a Bull Power Bar is not a buy signal by itself.

It should be treated as an alert that a strong bullish candle appeared and should be reviewed in context.

5. Bear Power Bar

A Bear Power Bar appears when the candle shows strong downward behavior.

The default bear power color is light blue.

A Bear Power Bar may indicate that sellers showed strong control during that candle.

However, a Bear Power Bar is not a sell signal by itself.

It should be treated as an alert that a strong bearish candle appeared and should be reviewed in context.

6. Important Usage Note

A Power Bar candle is not enough by itself to enter or exit a trade.

The candle only alerts the user that unusual directional strength appeared on the chart.

A strong candle can appear:

* Near the beginning of a move
* In the middle of a move
* Near the end of an extended move
* Around support or resistance
* During a breakout
* During a rejection
* During a volatile market reaction

Because of this, users should not treat Power Bars as automatic buy or sell signals.

The correct use is to combine them with broader analysis.

7. Best Way to Use the Indicator

The best way to use Power Bar Radar is as a confirmation and attention tool.

A practical workflow:

1. Identify the overall market direction.

2. Mark key support and resistance levels.

3. Watch for Power Bars near important areas.

4. Use Bull Power Bars to identify candles with unusually strong bullish behavior.

5. Use Bear Power Bars to identify candles with unusually strong bearish behavior.

6. Check whether the Power Bar appears during a breakout, breakdown, pullback, rejection, or continuation move.

7. Confirm with market structure, trend, volume, higher timeframe context, and risk management.

8. Avoid entering trades based only on the candle color.

9. Example Uses

Breakout confirmation

If price breaks above resistance and a Bull Power Bar appears, it may suggest that the breakout candle had unusually strong bullish behavior.

This does not guarantee continuation, but it can help the user identify a stronger breakout candle compared with normal candles.

Support reaction

If price reacts from a support area and a Bull Power Bar appears, it may suggest that buyers responded strongly at that area.

The user should still check trend, structure, and risk before making any decision.

Resistance rejection

If price reaches resistance and a Bear Power Bar appears, it may suggest that sellers showed strong pressure at that area.

This should be reviewed with structure and confirmation. It is not an automatic sell signal.

Breakdown confirmation

If price breaks below support and a Bear Power Bar appears, it may suggest that the breakdown candle had unusually strong bearish behavior.

This can be useful as a visual warning of strong downside pressure.

9. Optional Volume Filter

The volume filter is OFF by default.

This is intentional because not all markets have reliable volume data.

For stocks and some crypto markets, users may enable the volume filter to require above-average volume before a candle is marked as a Power Bar.

For forex, indices, or symbols with unreliable volume, users may prefer to keep the volume filter OFF.

10. Display Options

The indicator includes simple display options:

* Show or hide Power Bar markers
* Tint Power Bar candles
* Change Bull Power Bar color
* Change Bear Power Bar color

The default colors are designed to avoid confusion with standard green and red candles:

* Bull Power Bar: yellow
* Bear Power Bar: light blue

Users can change these colors from the settings.

11. Alerts

The script includes alert conditions for:

* Bull Power Bar
* Bear Power Bar

Alerts notify users when a bullish or bearish Power Bar appears.

Alerts are notifications only. They do not place trades, do not execute orders, and do not confirm broker execution.

12. Suggested Use Cases

Power Bar Radar can be useful for:

* Identifying unusually strong candles
* Breakout review
* Breakdown review
* Support and resistance reaction analysis
* Trend continuation review
* Rejection candle review
* Momentum candle detection
* Visual candle-strength filtering
* Reducing focus on ordinary candles
* Highlighting candles that deserve further analysis

13. What This Indicator Does Not Do

This indicator does not predict future price movement.

It does not guarantee continuation.

It does not guarantee reversal.

It does not provide buy or sell recommendations.

It does not replace a complete trading plan.

It does not manage risk.

It does not set stop losses or take profits.

It does not confirm that a trade should be taken.

It only highlights candles that meet the selected Power Bar conditions.

14. Limitations

Power Bars can appear late in a move.

Power Bars can appear during volatile market reactions.

A Bull Power Bar can appear before a pullback.

A Bear Power Bar can appear before a bounce.

Markets can reverse after strong candles.

The optional volume filter may not be useful on symbols with unreliable volume data.

Users should always analyze the broader chart context before making any decision.

15. Recommended Confirmation

For better use, consider combining Power Bar Radar with:

* Support and resistance
* Trend direction
* Market structure
* Volume analysis
* Higher timeframe analysis
* Moving averages
* Breakout or pullback setups
* Risk management rules

The Power Bar should be treated as a visual alert, not as a complete trading signal.

16. Originality and Purpose

Power Bar Radar combines statistical move detection, candle close-location analysis, range expansion, optional volume confirmation, and clean visual candle marking.

The purpose is to help traders identify candles that show unusual strength or pressure without adding unnecessary lines, oscillators, or external comparisons.

The indicator is designed to be simple, visual, and focused on candle behavior.

17. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users are responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Power Bar Radar
// ============================================================================
// Power Bar Radar highlights candles with unusually strong directional behavior
// using only the chart symbol's own data.
//
// A bar is marked as a Power Bar only when several conditions align:
// 1. Significant move:
//    The candle's net change is statistically large compared with recent bars.
// 2. Strong close location:
//    Bull bars close near the upper part of the candle range.
//    Bear bars close near the lower part of the candle range.
// 3. Range expansion:
//    The candle range is wider than its recent average.
// 4. Optional volume confirmation:
//    When enabled, volume must be above its recent average by a selected factor.
//
// This version preserves the original detection logic.
// Optional additions: marker-size control and a prior high / low structural filter.
//
// This is an indicator, not a strategy.
// It does not place orders and does not provide guaranteed buy or sell signals.
// ============================================================================

indicator(
     title            = "Power Bar Radar",
     shorttitle       = "Power Bars",
     overlay          = true,
     max_labels_count = 300
)

// ============================================================================
// Inputs
// ============================================================================

string grpPower = "1) Power Bar Test"

int statLen = input.int(
     defval  = 50,
     title   = "Stats lookback",
     minval  = 5,
     group   = grpPower,
     tooltip = "Window used for move z-score and average range calculations."
)

float zThresh = input.float(
     defval  = 2.0,
     title   = "Move z-score threshold",
     minval  = 0.5,
     step    = 0.1,
     group   = grpPower,
     tooltip = "How statistically large the candle's net move must be compared with recent bars."
)

float locThresh = input.float(
     defval  = 0.70,
     title   = "Close-location threshold",
     minval  = 0.5,
     maxval  = 1.0,
     step    = 0.05,
     group   = grpPower,
     tooltip = "Bull candles must close near the upper part of their range. Bear candles must close near the lower part of their range."
)

float rngFactor = input.float(
     defval  = 1.30,
     title   = "Range expansion x avg",
     minval  = 1.0,
     step    = 0.1,
     group   = grpPower,
     tooltip = "The candle range must be greater than the average range multiplied by this factor."
)

bool useStructureFilter = input.bool(
     defval  = false,
     title   = "Require prior high / low break",
     group   = grpPower,
     tooltip = "Optional structural filter. Bull Power Bars must trade above the highest high of the previous X bars. Bear Power Bars must trade below the lowest low of the previous X bars."
)

int structureLookback = input.int(
     defval  = 1,
     title   = "Prior high / low lookback",
     minval  = 1,
     maxval  = 100,
     group   = grpPower,
     tooltip = "Number of previous candles used by the optional prior high / low break filter."
)

string grpVolume = "2) Optional Volume Filter"

bool useVolFilter = input.bool(
     defval  = false,
     title   = "Use volume filter",
     group   = grpVolume,
     tooltip = "When ON, a power bar also requires volume to be above its recent average. Keep OFF for symbols with unreliable or missing volume."
)

int volLen = input.int(
     defval = 50,
     title  = "Volume average length",
     minval = 5,
     group  = grpVolume
)

float volFactor = input.float(
     defval  = 1.50,
     title   = "Volume expansion x avg",
     minval  = 1.0,
     step    = 0.1,
     group   = grpVolume,
     tooltip = "Volume must be greater than average volume multiplied by this factor when the volume filter is enabled."
)

string grpDisplay = "3) Display"

bool showMarkers = input.bool(
     defval = true,
     title  = "Show power bar markers",
     group  = grpDisplay
)

string markerSizeInput = input.string(
     defval  = "Tiny",
     title   = "Power bar marker size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = grpDisplay,
     tooltip = "Controls only the size of the diamond marker. It does not change the Power Bar detection logic."
)

bool tintBars = input.bool(
     defval = true,
     title  = "Tint power bars",
     group  = grpDisplay
)

color bullBarColor = input.color(
     defval = color.rgb(255, 213, 79),
     title  = "Bull power bar color",
     group  = grpDisplay
)

color bearBarColor = input.color(
     defval = color.rgb(41, 182, 246),
     title  = "Bear power bar color",
     group  = grpDisplay
)

// ============================================================================
// Original Power Bar calculation — unchanged
// ============================================================================

float move = close - close[1]

float sd = ta.stdev(move, statLen)

float z = sd > 0.0 ? move / sd : 0.0

float rng = high - low

float closeLoc = rng > 0.0 ? (close - low) / rng : 0.5

float avgRng = ta.sma(rng, statLen)

bool rangeExp = rng > avgRng * rngFactor

float avgVol = ta.sma(volume, volLen)

bool validVol =
     not na(volume) and
     volume > 0.0 and
     not na(avgVol) and
     avgVol > 0.0

bool volumeExp =
     validVol and
     volume > avgVol * volFactor

bool volumeOK =
     not useVolFilter or
     volumeExp

float priorHigh = ta.highest(high[1], structureLookback)
float priorLow  = ta.lowest(low[1], structureLookback)

bool bullStructureOK =
     not useStructureFilter or
     (not na(priorHigh) and high > priorHigh)

bool bearStructureOK =
     not useStructureFilter or
     (not na(priorLow) and low < priorLow)

bool powerBull =
     z >= zThresh and
     closeLoc >= locThresh and
     rangeExp and
     volumeOK and
     bullStructureOK

bool powerBear =
     z <= -zThresh and
     closeLoc <= 1.0 - locThresh and
     rangeExp and
     volumeOK and
     bearStructureOK

// ============================================================================
// Marker-size selection
// plotshape() requires a constant size, so each size uses its own fixed call.
// The detection conditions remain exactly the same.
// ============================================================================

bool bullTiny =
     showMarkers and powerBull and markerSizeInput == "Tiny"

bool bullSmall =
     showMarkers and powerBull and markerSizeInput == "Small"

bool bullNormal =
     showMarkers and powerBull and markerSizeInput == "Normal"

bool bullLarge =
     showMarkers and powerBull and markerSizeInput == "Large"

bool bullHuge =
     showMarkers and powerBull and markerSizeInput == "Huge"

bool bearTiny =
     showMarkers and powerBear and markerSizeInput == "Tiny"

bool bearSmall =
     showMarkers and powerBear and markerSizeInput == "Small"

bool bearNormal =
     showMarkers and powerBear and markerSizeInput == "Normal"

bool bearLarge =
     showMarkers and powerBear and markerSizeInput == "Large"

bool bearHuge =
     showMarkers and powerBear and markerSizeInput == "Huge"

// Keep markers visible on the chart while hiding their numeric series from the
// status line, Data Window, and price scale.

// ============================================================================
// Bull markers
// ============================================================================

plotshape(
     series   = bullTiny,
     title    = "Bull Power Bar Tiny",
     style    = shape.diamond,
     location = location.belowbar,
     color    = bullBarColor,
     size     = size.tiny,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bullSmall,
     title    = "Bull Power Bar Small",
     style    = shape.diamond,
     location = location.belowbar,
     color    = bullBarColor,
     size     = size.small,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bullNormal,
     title    = "Bull Power Bar Normal",
     style    = shape.diamond,
     location = location.belowbar,
     color    = bullBarColor,
     size     = size.normal,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bullLarge,
     title    = "Bull Power Bar Large",
     style    = shape.diamond,
     location = location.belowbar,
     color    = bullBarColor,
     size     = size.large,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bullHuge,
     title    = "Bull Power Bar Huge",
     style    = shape.diamond,
     location = location.belowbar,
     color    = bullBarColor,
     size     = size.huge,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

// ============================================================================
// Bear markers
// ============================================================================

plotshape(
     series   = bearTiny,
     title    = "Bear Power Bar Tiny",
     style    = shape.diamond,
     location = location.abovebar,
     color    = bearBarColor,
     size     = size.tiny,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bearSmall,
     title    = "Bear Power Bar Small",
     style    = shape.diamond,
     location = location.abovebar,
     color    = bearBarColor,
     size     = size.small,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bearNormal,
     title    = "Bear Power Bar Normal",
     style    = shape.diamond,
     location = location.abovebar,
     color    = bearBarColor,
     size     = size.normal,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bearLarge,
     title    = "Bear Power Bar Large",
     style    = shape.diamond,
     location = location.abovebar,
     color    = bearBarColor,
     size     = size.large,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

plotshape(
     series   = bearHuge,
     title    = "Bear Power Bar Huge",
     style    = shape.diamond,
     location = location.abovebar,
     color    = bearBarColor,
     size     = size.huge,
     editable = false,
     display  = display.all - display.status_line - display.data_window - display.price_scale
)

// ============================================================================
// Original candle tint — unchanged
// ============================================================================

barcolor(
     tintBars ?
     powerBull ? bullBarColor :
     powerBear ? bearBarColor :
     na :
     na,
     title    = "Power Bar Tint",
     editable = false
)

// ============================================================================
// Alerts
// ============================================================================

alertcondition(
     condition = powerBull,
     title     = "Bull Power Bar",
     message   = "Power Bar Radar: bullish power bar detected"
)

alertcondition(
     condition = powerBear,
     title     = "Bear Power Bar",
     message   = "Power Bar Radar: bearish power bar detected"
)

// ============================================================================
// End of file
// ============================================================================
````
