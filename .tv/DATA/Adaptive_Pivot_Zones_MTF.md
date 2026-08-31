<!-- tradingview-pine-id: PUB;f94d5f565da548cda66bfb76f6bbf046 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Pivot Zones MTF

Source: https://www.tradingview.com/script/scbfVrkp-Adaptive-Pivot-Zones-MTF/

## Description

█ OVERVIEW
Adaptive Pivot Zones MTF is a multi-timeframe trend analysis indicator based on dynamic zones calculated using pivot highs and pivot lows.

Instead of representing the trend with a single line, the indicator creates three levels inside the range between the last confirmed pivot low and pivot high. These levels form a dynamic zone whose position and width adapt to the current market structure.

The core of the indicator is the relationship between price and this zone. Depending on the selected mode, a trend change occurs either after price breaks the middle line of the zone or only after price exits the entire zone. This allows the user to choose between earlier direction changes or stronger confirmation of the move.

The indicator is designed as an MTF system. In addition to the current timeframe, two higher timeframes are analyzed. These can be selected automatically in proportion to the current TF or set manually. This helps assess whether a trend change on the lower timeframe is aligned with the broader market direction.

The central element of the signal system is Multi-Timeframe Agreement. Each trend change can be evaluated based on the agreement of 1, 2, or all 3 monitored timeframes. The higher the agreement, the stronger the directional confirmation the user receives.

The indicator also integrates automatic Entry, Stop Loss, and three Take Profit levels based on ATR or a fixed risk percentage. This combines market direction analysis with a visual representation of the potential Risk/Reward setup.

The result is a complete trend analysis system that combines dynamic pivot zones, multi-timeframe analysis, trend agreement confirmation, and automatic position management levels.

█ CONCEPTS
Pivot Zone
Pivot Zone is the foundation of the entire indicator and is used to determine the current market state.
The indicator uses confirmed pivot highs and pivot lows to define the current price range. Then, three levels are calculated inside this range according to the set values of Pivot Level 1, Pivot Level 2, and Pivot Level 3.
These levels form a dynamic zone that can be treated as an equilibrium area between the most recent significant market extremes.
Pivot Zone answers the question:
Where is the current market decision zone located?

Pivot Length
Pivot Length determines how many bars are required on each side to confirm a pivot high or pivot low.
A lower value results in more frequent pivot detection and faster adaptation of the zones to price changes, but it also increases the number of less significant pivots.
A higher value requires a more developed structure to confirm a pivot, so zones appear less often but represent more meaningful market points.
Smoothing Length additionally allows the calculated pivot levels to be smoothed.

Pivot Levels
The three pivot levels define the exact position of the zone inside the range between pivot low and pivot high.
Pivot Level 1 defines the first level of the zone, Pivot Level 2 its middle line, and Pivot Level 3 the third level.
The default setting of 0.3 / 0.5 / 0.7 creates three levels placed symmetrically around the middle of the range, but the user can adjust them freely.
The middle line has a special role because it can be used as the primary level that determines a trend change.

Trend State
Trend State determines whether the market is currently in a bullish or bearish state.
In Full Band mode, price must break above the upper boundary of the entire zone to become bullish, or below the lower boundary to become bearish.
In Mid Line mode, the direction changes as soon as price crosses the middle line of the zone.
This allows the sensitivity of the indicator to be adjusted to the analysis style:
• Mid Line → earlier direction changes
• Full Band → stronger confirmation of a zone breakout
An optional Neutral mode also allows a neutral state to be displayed when price is exactly at the decision level.

Multi-Timeframe Analysis
Adaptive Pivot Zones MTF analyzes not only the current timeframe but also two higher timeframes.
TF1 and TF2 can be selected automatically based on the current timeframe. The system proportionally chooses higher intervals so that the MTF structure can be applied across different market scales without the need to manually set each TF.
Alternatively, the user can switch MTF Mode to Manual and define Higher TF 1 and Higher TF 2 independently.
Multi-Timeframe Analysis answers the question:
Is the direction on my timeframe aligned with the higher market context?

TF1 & TF2 Zones
In addition to the current zone, the indicator can also display pivot channels from TF1 and TF2.
Each higher timeframe has its own zone with an upper and lower boundary and an optional middle line. The channel color changes according to the current trend of that timeframe.
Higher timeframe zones can be used as additional context, showing where the current price is located relative to the broader structure.

MTF Agreement
MTF Agreement determines the number of timeframes that confirm the same trend direction.
The system analyzes three timeframes:
• Current TF → current timeframe
• TF1 → first higher timeframe
• TF2 → second higher timeframe
As a result, a trend change can receive confirmation from 1, 2, or 3 timeframes.
For example:
• 1 TF → change visible only on the current timeframe
• 2 TF → current timeframe + one of the higher timeframes confirms the same direction
• 3 TF → all three timeframes indicate the same direction
It is the number of agreeing timeframes that decides which signals can be displayed.

█ FEATURES
Current TF Settings
• Pivot Length – number of bars required on each side to confirm a pivot high / pivot low.
• Smoothing Length – length of the SMA that smooths the pivot lines. A value of 1 means no smoothing.
• Pivot Level 1 / 2 / 3 – coefficients (0.0–1.0) that determine the position of the three lines inside the pivot low – pivot high range.
• Paint Bars (Mid Pivot) – colors the candles according to the current trend state of the current timeframe.

Current TF Style
• Line Width – thickness of the current timeframe pivot lines.
• Line Transparency – transparency of the pivot lines.
• Gradient Transparency – transparency of the gradient fill between the lines.

Current TF Colors
• Bullish Color / Bearish Color – colors of the lines and fill in bullish / bearish state.
• Use Neutral Color – enables a third, neutral state.
• Neutral Color – color used in the neutral state.

MTF Settings
• MTF Mode – Automatic (automatic selection of TF1 and TF2) or Manual.
• Higher TF 1 / Higher TF 2 – manual selection of higher timeframes (active only in Manual mode).

TF1 Style & Colors
• Show TF1 (lines + channel) – displays the upper and lower TF1 channel lines together with the fill.
• Show TF1 Mid Line – additionally shows the middle line of the TF1 zone.
• TF1 Line Width / Transparency / Gradient Transparency – appearance settings for the TF1 channel.
• TF1 Bullish / Bearish Color – colors of the TF1 channel depending on the trend.

TF2 Style & Colors
• Show TF2 (lines + channel) – displays the upper and lower TF2 channel lines together with the fill.
• Show TF2 Mid Line – additionally shows the middle line of the TF2 zone.
• TF2 Line Width / Transparency / Gradient Transparency – appearance settings for the TF2 channel.
• TF2 Bullish / Bearish Color – colors of the TF2 channel depending on the trend.

Signals
• Trend Change Based On – Mid Line (earlier signals) or Full Band (stronger confirmation).
• Show Buy/Sell Labels – displays signal labels on the chart.
• Show Label When 1 / 2 / 3 TF Agree – controls at what number of agreeing timeframes the signal is shown.
• Buy / Sell Label Color and Label Size – appearance of the signal labels.

TP/SL
• Show TP/SL Levels – draws Entry, Stop Loss, and Take Profit levels on an active signal that meets the TF agreement criteria.
• SL = ATR – when enabled, the SL distance is calculated based on ATR. When disabled, a fixed percentage is used.
• ATR Period for TP/SL – ATR period used for calculations.
• ATR Multiplier for SL / SL % from Entry – parameters that define the Stop Loss distance.
• RR for TP1 / TP2 / TP3 – Risk:Reward ratios for the three Take Profit levels.
• Show SL / TP1 / TP2 / TP3 Level – individual enabling of each level.

MTF Table
• Show Multi-Timeframe Table – displays a table with the trend state on the selected timeframes.
• Table Position / Text Size – position and text size of the table.
• Bull / Bear / Background / Header Colors – table color scheme.
• Show + TF (for each row) – individual enabling and selection of timeframes displayed in the table (5m, 15m, 30m, 1h, 2h, 4h, 8h, 12h, 1D, 1W, 2W).

█ APPLICATIONS
Trend direction analysis with MTF context
The indicator allows you to assess whether a direction change on the current timeframe is supported by higher timeframes. Signals with 2 or 3 TF confirmation have significantly higher informational value than signals visible only on the current chart.

Filtering signals from other indicators
It can be used as a classic trend indicator to filter signals from other indicators.

Risk and potential reward management
Automatic Entry, SL, and three TP levels allow you to immediately see the Risk/Reward setup on every trend change that meets the agreement criteria. This makes it easier to quickly decide on position size and targets.

█ NOTES
• Full Band mode generates fewer signals but with stronger confirmation of a full zone breakout. Mid Line mode reacts faster.
• The Multi-Timeframe table shows the current trend state on the selected timeframes and serves as quick context, not as an independent signal system.
• The indicator works best when combined with market structure analysis, key support/resistance levels, and other indicators such as momentum or volume.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter 

//@version=6
indicator('Adaptive Pivot Zones MTF', overlay = true, max_lines_count = 500, max_labels_count = 500)

// PARAMETERS — Current Timeframe (Current TF)

lenSwing     = input.int(10, 'Pivot Length', minval = 2, group = "Current TF",
     tooltip = "Number of bars required on each side to confirm a swing high / swing low pivot.\nLower value = more frequent, less reliable pivots.\nHigher value = rarer, but more reliable pivots.")
smoothLen    = input.int(1, 'Smoothing Length', minval = 1, group = "Current TF",
     tooltip = "SMA smoothing length applied to the pivot lines.\nValue of 1 = no smoothing (raw pivot values).")
pivotLevel1  = input.float(0.3, 'Pivot Level 1', step = 0.001, minval = 0.0, maxval = 1.0, group = "Current TF",
     tooltip = "Coefficient (0.0–1.0) determining the position of the line within the pivot low – pivot high range.\n0.0 = at the pivot low level, 1.0 = at the pivot high level.")
pivotLevel2  = input.float(0.5, 'Pivot Level 2', step = 0.001, minval = 0.0, maxval = 1.0, group = "Current TF",
     tooltip = "Coefficient (0.0–1.0) determining the mid line of the zone. A value of 0.5 corresponds to exactly the middle of the pivot low – pivot high range.")
pivotLevel3  = input.float(0.7, 'Pivot Level 3', step = 0.001, minval = 0.0, maxval = 1.0, group = "Current TF",
     tooltip = "Coefficient (0.0–1.0) determining the position of the line within the pivot low – pivot high range, analogous to Pivot Level 1.")

paintBars       = input.bool(false, "Paint Bars (Mid Pivot)", group = "Current TF",
     tooltip = "Colors the candles on the chart according to the current trend state of the current timeframe (same logic used to generate Buy/Sell signals).")
paintBullColor  = input.color(color.green, "Bull Candle Color", group = "Current TF",
     tooltip = "Candle color when the current timeframe trend is bullish and Paint Bars is enabled.")
paintBearColor  = input.color(color.red, "Bear Candle Color", group = "Current TF",
     tooltip = "Candle color when the current timeframe trend is bearish and Paint Bars is enabled.")

// Current TF — Style
currLineWidth = input.int(1, 'Line Width', minval = 1, group = "Current TF Style",
     tooltip = "Width of the pivot lines (Pivot Line 1/2/3) on the current timeframe.")
currLineTransp = input.int(70, 'Line Transparency (0-100)', minval = 0, maxval = 100, group = "Current TF Style",
     tooltip = "Transparency of the current timeframe's pivot lines (Pivot Line 1/2/3).\n0 = lines fully visible, 100 = lines completely invisible, leaving only the gradient fill visible.")
fillOpacity   = input.int(75, 'Gradient Transparency (0–100)', minval = 0, maxval = 100, group = "Current TF Style",
     tooltip = "Transparency of the fill between the current timeframe's pivot lines.\n0 = fully opaque color, 100 = fill completely invisible.")

// Current TF — Colors
bullColor    = input.color(color.rgb(22, 193, 67), 'Bullish Color (line)', group = "Current TF Colors",
     tooltip = "Color of the line and zone fill when the current timeframe trend is bullish. Also used as the Entry/TP level color for Buy signals.")
bearColor    = input.color(color.rgb(229, 11, 11), 'Bearish Color (line)', group = "Current TF Colors",
     tooltip = "Color of the line and zone fill when the current timeframe trend is bearish. Also used as the Entry/TP level color for Sell signals.")
useNeutral   = input.bool(false, 'Use Neutral Color?', group = "Current TF Colors",
     tooltip = "Enables a third, neutral trend state instead of maintaining the last known direction, when price sits exactly on the zone's mid line.")
neutralColor = input.color(color.gray, 'Neutral Color', group = "Current TF Colors",
     tooltip = "Color of the line and fill when the neutral state is active (only available when \"Use Neutral Color?\" is enabled).")


// MTF MODE (Automatic / Manual)

mtfMode   = input.string("Automatic", "MTF Mode", options = ["Automatic", "Manual"], group = "MTF",
     tooltip = "Automatic: the indicator automatically selects the higher timeframes TF1 and TF2, proportionally to the current chart timeframe.\nManual: TF1 and TF2 are selected manually below.")
higherTF1 = input.timeframe("120", "Higher TF 1", active = mtfMode == "Manual", group = "MTF",
     tooltip = "Higher timeframe used to calculate the TF1 channel. Active only in Manual mode.")
higherTF2 = input.timeframe("480", "Higher TF 2", active = mtfMode == "Manual", group = "MTF",
     tooltip = "Higher timeframe used to calculate the TF2 channel. Active only in Manual mode.")

// TF1 — Style
showTF1        = input.bool(false, "Show TF1 (lines + channel)", group = "TF1 Style",
     tooltip = "Displays the upper and lower TF1 channel lines along with the gradient fill between them.")
showTF1Mid     = input.bool(false, "Show TF1 Mid Line", group = "TF1 Style",
     tooltip = "Additionally displays the mid line (Pivot Level 2) of the TF1 zone.")
tf1LineWidth   = input.int(1, "TF1 Line Width", minval = 1, group = "TF1 Style",
     tooltip = "Width of the upper and lower TF1 channel lines.")
tf1LineTransp  = input.int(85, "TF1 Line Transparency (0-100)", minval = 0, maxval = 100, group = "TF1 Style",
     tooltip = "Transparency of the upper and lower TF1 channel lines.\n100 = lines completely invisible, leaving only the gradient fill visible.")
tf1FillOpacity = input.int(90, "TF1 Gradient Transparency (0-100)", minval = 0, maxval = 100, group = "TF1 Style",
     tooltip = "Transparency of the gradient fill between the upper and lower TF1 channel lines.")

// TF1 — Colors
tf1BullColor    = input.color(color.rgb(22, 193, 67), 'TF1 Bullish Color', group = "TF1 Colors",
     tooltip = "TF1 channel color when the trend on this timeframe is bullish.")
tf1BearColor    = input.color(color.rgb(229, 11, 11), 'TF1 Bearish Color', group = "TF1 Colors",
     tooltip = "TF1 channel color when the trend on this timeframe is bearish.")

// TF2 — Style
showTF2        = input.bool(false, "Show TF2 (lines + channel)", group = "TF2 Style",
     tooltip = "Displays the upper and lower TF2 channel lines along with the gradient fill between them.")
showTF2Mid     = input.bool(false, "Show TF2 Mid Line", group = "TF2 Style",
     tooltip = "Additionally displays the mid line (Pivot Level 2) of the TF2 zone.")
tf2LineWidth   = input.int(1, "TF2 Line Width", minval = 1, group = "TF2 Style",
     tooltip = "Width of the upper and lower TF2 channel lines.")
tf2LineTransp  = input.int(85, "TF2 Line Transparency (0-100)", minval = 0, maxval = 100, group = "TF2 Style",
     tooltip = "Transparency of the upper and lower TF2 channel lines.\n100 = lines completely invisible, leaving only the gradient fill visible.")
tf2FillOpacity = input.int(90, "TF2 Gradient Transparency (0-100)", minval = 0, maxval = 100, group = "TF2 Style",
     tooltip = "Transparency of the gradient fill between the upper and lower TF2 channel lines.")

// TF2 — Colors
tf2BullColor    = input.color(color.rgb(22, 193, 67), 'TF2 Bullish Color', group = "TF2 Colors",
     tooltip = "TF2 channel color when the trend on this timeframe is bullish.")
tf2BearColor    = input.color(color.rgb(229, 11, 11), 'TF2 Bearish Color', group = "TF2 Colors",
     tooltip = "TF2 channel color when the trend on this timeframe is bearish.")


// BUY/SELL SIGNALS — trigger + TF agreement labels

signalTriggerMode = input.string("Full Band", "Trend Change Based On", options = ["Mid Line", "Full Band"], group = "Signals",
     tooltip = "Mid Line: a signal is generated when price crosses the mid line of the pivot zone (current timeframe).\nFull Band: a signal is generated only when price crosses the upper line (Buy) or lower line (Sell) of the full zone (current timeframe).")
showSignalLabels = input.bool(true, "Show Buy/Sell Labels", group = "Signals",
     tooltip = "Displays Buy/Sell labels on the chart when the current timeframe trend changes, according to the TF agreement criteria set below.")
showLabelWhen1   = input.bool(true, "Show Label When 1 TF Agrees", group = "Signals",
     tooltip = "Displays the signal label when the direction of the trend change is confirmed by only 1 of the 3 monitored timeframes (Current TF, TF1, TF2).")
showLabelWhen2   = input.bool(true, "Show Label When 2 TF Agree", group = "Signals",
     tooltip = "Displays the signal label when the direction of the trend change is confirmed by 2 of the 3 monitored timeframes.")
showLabelWhen3   = input.bool(true, "Show Label When All 3 TF Agree", group = "Signals",
     tooltip = "Displays the signal label when the direction of the trend change is confirmed by all 3 monitored timeframes (Current TF, TF1, TF2).")
buyLabelColor    = input.color(color.rgb(22, 193, 67), "Buy Label Color", group = "Signals",
     tooltip = "Background color of the Buy signal label.")
sellLabelColor   = input.color(color.rgb(229, 11, 11), "Sell Label Color", group = "Signals",
     tooltip = "Background color of the Sell signal label.")
labelTextColor   = input.color(color.white, "Label Text Color", group = "Signals",
     tooltip = "Text color inside the Buy/Sell signal labels.")
labelSize        = input.string(size.small, "Label Size", options = [size.tiny, size.small, size.normal, size.large], group = "Signals",
     tooltip = "Size of the Buy/Sell signal labels displayed on the chart.")


// TP/SL — Take Profit / Stop Loss levels

show_targets  = input.bool(true, 'Show TP/SL Levels', group = 'TP/SL',
     tooltip = 'Draws Entry, Stop Loss and Take Profit levels at every active current timeframe trend change label (i.e. only when the TF agreement count criterion set in the Signals section is met).')
use_atr_sl    = input.bool(true, 'SL = ATR', group = 'TP/SL',
     tooltip = "When enabled, the Stop Loss distance from the entry price is calculated based on ATR (ATR Multiplier for SL).\nWhen disabled, a fixed percentage value is used (SL % from Entry).")
tp_atr_period = input.int(14, 'ATR Period for TP/SL', minval = 1, group = 'TP/SL',
     tooltip = "ATR period used to determine the Stop Loss distance and the Take Profit levels.")
sl_atr_mult   = input.float(1.5, 'ATR Multiplier for SL', step = 0.1, group = 'TP/SL',
     tooltip = "ATR multiplier determining the Stop Loss distance from the entry price, active when SL = ATR is enabled.")
sl_percent    = input.float(1.0, 'SL % from Entry', step = 0.1, group = 'TP/SL',
     tooltip = "Percentage distance of the Stop Loss from the entry price, used when SL = ATR is disabled.")
rr_tp1        = input.float(1.0, 'RR for TP1', step = 0.1, group = 'TP/SL',
     tooltip = "Risk:Reward ratio for Take Profit level 1. A value of 1.0 means TP1 sits at a distance equal to the risk (SL) from the entry price.")
rr_tp2        = input.float(2.0, 'RR for TP2', step = 0.1, group = 'TP/SL',
     tooltip = "Risk:Reward ratio for Take Profit level 2.")
rr_tp3        = input.float(3.0, 'RR for TP3', step = 0.1, group = 'TP/SL',
     tooltip = "Risk:Reward ratio for Take Profit level 3.")

show_sl_level  = input.bool(true, 'Show SL Level',  group = 'TP/SL Display',
     tooltip = "Draws the Stop Loss line and label for the active signal.")
show_tp1_level = input.bool(true, 'Show TP1 Level', group = 'TP/SL Display',
     tooltip = "Draws the Take Profit 1 line and label for the active signal.")
show_tp2_level = input.bool(true, 'Show TP2 Level', group = 'TP/SL Display',
     tooltip = "Draws the Take Profit 2 line and label for the active signal.")
show_tp3_level = input.bool(true, 'Show TP3 Level', group = 'TP/SL Display',
     tooltip = "Draws the Take Profit 3 line and label for the active signal.")


// MULTI-TIMEFRAME TABLE — general settings

showMtfTable      = input.bool(true, "Show Multi-Timeframe Table", group = "MTF Table",
     tooltip = "Displays a table showing the trend direction on the selected timeframes.")
tablePosition     = input.string(position.top_right, "Table Position", options = [position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group = "MTF Table",
     tooltip = "Position of the Multi-Timeframe table on the chart.")
tableTextSize     = input.string(size.small, "Text Size", options = [size.tiny, size.small, size.normal, size.large], group = "MTF Table",
     tooltip = "Size of the text displayed in the Multi-Timeframe table.")
tableBullColor    = input.color(color.rgb(22, 193, 67), "Bull Color in Table", group = "MTF Table",
     tooltip = "Cell background color when the trend on the given timeframe is bullish.")
tableBearColor    = input.color(color.rgb(229, 11, 11), "Bear Color in Table", group = "MTF Table",
     tooltip = "Cell background color when the trend on the given timeframe is bearish.")
tableBgColor      = input.color(color.rgb(30, 30, 30), "Table Background Color", group = "MTF Table",
     tooltip = "Background color of the timeframe name column.")
tableHeaderColor  = input.color(color.rgb(50, 50, 50), "Header Color", group = "MTF Table",
     tooltip = "Background color of the table header row and the table border.")
tableHeaderText   = input.color(color.white, "Header Text Color", group = "MTF Table",
     tooltip = "Text color in the header row and in the timeframe name column.")

// MULTI-TIMEFRAME TABLE — individual timeframes (enable/disable + TF selection)
// The table row label is generated automatically based on the selected timeframe (see f_tfLabel below).
show5m  = input.bool(true,  "Show", inline = "row5m",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf5m    = input.timeframe("5",   "TF", inline = "row5m",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show15m = input.bool(true,  "Show", inline = "row15m", group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf15m   = input.timeframe("15",  "TF", inline = "row15m", group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show30m = input.bool(true,  "Show", inline = "row30m", group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf30m   = input.timeframe("30",  "TF", inline = "row30m", group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show1h  = input.bool(true,  "Show", inline = "row1h",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf1h    = input.timeframe("60",  "TF", inline = "row1h",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show2h  = input.bool(true,  "Show", inline = "row2h",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf2h    = input.timeframe("120", "TF", inline = "row2h",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show4h  = input.bool(true,  "Show", inline = "row4h",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf4h    = input.timeframe("240", "TF", inline = "row4h",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show8h  = input.bool(true,  "Show", inline = "row8h",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf8h    = input.timeframe("480", "TF", inline = "row8h",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show12h = input.bool(true,  "Show", inline = "row12h", group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf12h   = input.timeframe("720", "TF", inline = "row12h", group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show1D  = input.bool(true,  "Show", inline = "row1D",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf1D    = input.timeframe("1D",  "TF", inline = "row1D",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show1W  = input.bool(true,  "Show", inline = "row1W",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf1W    = input.timeframe("1W",  "TF", inline = "row1W",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

show2W  = input.bool(true,  "Show", inline = "row2W",  group = "MTF Table — Timeframes",
     tooltip = "Enables the Multi-Timeframe table row for the timeframe set next to it.")
tf2W    = input.timeframe("2W",  "TF", inline = "row2W",  group = "MTF Table — Timeframes",
     tooltip = "Timeframe assigned to this table row.")

// Converts the timeframe string (e.g. "5", "60", "1D", "1W") into a readable label (e.g. "5m", "1h", "1D", "1W")
f_tfLabel(_tf) =>
    string result = _tf
    if str.contains(_tf, "D") or str.contains(_tf, "W") or str.contains(_tf, "M") or str.contains(_tf, "S")
        result := _tf
    else
        int mins = int(str.tonumber(_tf))
        if mins < 60
            result := str.tostring(mins) + "m"
        else if mins % 60 == 0
            result := str.tostring(mins / 60) + "h"
        else
            result := str.tostring(mins) + "m"
    result


// AUTOMATIC TF1 AND TF2 SELECTION (proportional to the current timeframe)

f_getAutoMTFs() =>
    int tfSec = timeframe.in_seconds()
    string m1 = ""
    string m2 = ""

    if tfSec <= 60          // 1m
        m1 := "60"
        m2 := "240"
    else if tfSec <= 300    // 5m
        m1 := "60"
        m2 := "240"
    else if tfSec <= 900    // 15m
        m1 := "60"
        m2 := "480"
    else if tfSec <= 1800   // 30m
        m1 := "120"
        m2 := "480"
    else if tfSec <= 3600   // 1H
        m1 := "240"
        m2 := "720"
    else if tfSec <= 7200   // 2H
        m1 := "360"
        m2 := "720"
    else if tfSec <= 14400  // 4H
        m1 := "720"
        m2 := "2D"
    else if tfSec <= 28800  // 8H
        m1 := "1D"
        m2 := "2D"
    else if tfSec <= 43200  // 12H
        m1 := "1D"
        m2 := "2D"
    else if tfSec <= 86400  // 1D
        m1 := "2D"
        m2 := "W"
    else if tfSec <= 518400 // 2D–6D
        m1 := "W"
        m2 := "2W"
    else if tfSec <= 604800 // 1W
        m1 := "2W"
        m2 := "M"
    else
        m1 := "W"
        m2 := "M"

    [m1, m2]

[autoTF1, autoTF2] = f_getAutoMTFs()

string finalTF1 = mtfMode == "Automatic" ? autoTF1 : higherTF1
string finalTF2 = mtfMode == "Automatic" ? autoTF2 : higherTF2


// FUNCTION — full pivot zone calculation (lines + trend state)
// Returns: line1 (lower), line2 (mid), line3 (upper), state (1 = bull, -1 = bear, 0 = neutral)

f_calcZone(_allowNeutral) =>
    ph = ta.pivothigh(high, lenSwing, lenSwing)
    pl = ta.pivotlow(low, lenSwing, lenSwing)
    var float drHigh = na
    var float drLow = na
    if not na(ph)
        drHigh := ph
    if not na(pl)
        drLow := pl

    rangeReady = not na(drHigh) and not na(drLow)

    float line1 = na
    float line2 = na
    float line3 = na
    if rangeReady
        float start = drLow
        float endv  = drHigh
        float rng   = endv - start
        line1 := start + rng * pivotLevel1
        line2 := start + rng * pivotLevel2
        line3 := start + rng * pivotLevel3

    sl1 = ta.sma(line1, smoothLen)
    sl2 = ta.sma(line2, smoothLen)
    sl3 = ta.sma(line3, smoothLen)

    float lowerLine = na
    float upperLine = na
    if not na(sl1) and not na(sl2) and not na(sl3)
        lowerLine := math.min(math.min(sl1, sl2), sl3)
        upperLine := math.max(math.max(sl1, sl2), sl3)

    var int state = 1
    if signalTriggerMode == "Full Band"
        if not na(lowerLine) and not na(upperLine)
            if close < lowerLine
                state := -1
            else if close > upperLine
                state := 1
            else if _allowNeutral
                state := 0
    else
        if not na(sl2)
            if close < sl2
                state := -1
            else if close > sl2
                state := 1
            else if _allowNeutral
                state := 0

    [sl1, sl2, sl3, state]


// CALCULATIONS — current timeframe (Current TF)

[smoothedLine1, smoothedLine2, smoothedLine3, currState] = f_calcZone(useNeutral)

var color prevColor = bullColor
calcColor(_state) =>
    _col = prevColor
    if _state == -1
        _col := bearColor
    else if _state == 1
        _col := bullColor
    else if useNeutral
        _col := neutralColor
    _col

combinedColor = calcColor(currState)
prevColor := combinedColor


// MTF — TF1 / TF2 (lines + trend state)

[tf1L1, tf1L2, tf1L3, tf1State] = request.security(syminfo.tickerid, finalTF1, f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[tf2L1, tf2L2, tf2L3, tf2State] = request.security(syminfo.tickerid, finalTF2, f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

f_stateColor(_state, _bull, _bear) =>
    _state == 1 ? _bull : _bear

tf1Color = f_stateColor(tf1State, tf1BullColor, tf1BearColor)
tf2Color = f_stateColor(tf2State, tf2BullColor, tf2BearColor)


// MULTI-TIMEFRAME TABLE — fetching the trend state for each timeframe

[_, _, _, state5m]  = request.security(syminfo.tickerid, tf5m,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state15m] = request.security(syminfo.tickerid, tf15m, f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state30m] = request.security(syminfo.tickerid, tf30m, f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state1h]  = request.security(syminfo.tickerid, tf1h,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state2h]  = request.security(syminfo.tickerid, tf2h,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state4h]  = request.security(syminfo.tickerid, tf4h,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state8h]  = request.security(syminfo.tickerid, tf8h,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state12h] = request.security(syminfo.tickerid, tf12h, f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state1D]  = request.security(syminfo.tickerid, tf1D,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state1W]  = request.security(syminfo.tickerid, tf1W,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[_, _, _, state2W]  = request.security(syminfo.tickerid, tf2W,  f_calcZone(false), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)


// DRAWING — current timeframe (lines and fill)

p1 = plot(smoothedLine1, 'Pivot Line 1', color = color.new(combinedColor, currLineTransp), linewidth = currLineWidth)
p2 = plot(smoothedLine2, 'Pivot Line 2', color = color.new(combinedColor, currLineTransp), linewidth = currLineWidth)
p3 = plot(smoothedLine3, 'Pivot Line 3', color = color.new(combinedColor, currLineTransp), linewidth = currLineWidth)

fillColorEdge = color.new(combinedColor, fillOpacity)
fillColorMid  = color.new(combinedColor, 95)

fill(p1, p2, smoothedLine2, smoothedLine1, fillColorMid, fillColorEdge, title = 'Fill 1-2 Gradient')
fill(p2, p3, smoothedLine3, smoothedLine2, fillColorEdge, fillColorMid, title = 'Fill 2-3 Gradient')


// DRAWING — TF1: upper/lower channel line + gradient inside the channel only

pTF1Upper = plot(showTF1 ? tf1L3 : na, "TF1 Upper", color = color.new(tf1Color, tf1LineTransp), linewidth = tf1LineWidth)
pTF1Lower = plot(showTF1 ? tf1L1 : na, "TF1 Lower", color = color.new(tf1Color, tf1LineTransp), linewidth = tf1LineWidth)
plot(showTF1Mid ? tf1L2 : na, "TF1 Mid", color = color.new(tf1Color, tf1LineTransp), linewidth = tf1LineWidth)

fill(pTF1Upper, pTF1Lower, color = showTF1 ? color.new(tf1Color, tf1FillOpacity) : na, title = "TF1 Channel Fill")


// DRAWING — TF2: upper/lower channel line + gradient inside the channel only

pTF2Upper = plot(showTF2 ? tf2L3 : na, "TF2 Upper", color = color.new(tf2Color, tf2LineTransp), linewidth = tf2LineWidth)
pTF2Lower = plot(showTF2 ? tf2L1 : na, "TF2 Lower", color = color.new(tf2Color, tf2LineTransp), linewidth = tf2LineWidth)
plot(showTF2Mid ? tf2L2 : na, "TF2 Mid", color = color.new(tf2Color, tf2LineTransp), linewidth = tf2LineWidth)

fill(pTF2Upper, pTF2Lower, color = showTF2 ? color.new(tf2Color, tf2FillOpacity) : na, title = "TF2 Channel Fill")


// PAINT BARS (MID PIVOT) — current timeframe

bullCond = currState == 1
bearCond = currState == -1
barcolor(paintBars ? (bullCond ? paintBullColor : bearCond ? paintBearColor : na) : na)


// TREND CHANGE — Buy/Sell signal detection (current timeframe)

bullCross = currState == 1 and currState[1] != 1
bearCross = currState == -1 and currState[1] != -1

alertcondition(bullCross, title = "Bullish Trend Change", message = "Trend changed to Bullish")
alertcondition(bearCross, title = "Bearish Trend Change", message = "Trend changed to Bearish")


// NUMBER OF AGREEING TF (Current + TF1 + TF2) in the signal direction

f_agreeCount(_dir) =>
    (currState == _dir ? 1 : 0) + (tf1State == _dir ? 1 : 0) + (tf2State == _dir ? 1 : 0)

f_labelAllowed(_count) =>
    (_count == 1 and showLabelWhen1) or (_count == 2 and showLabelWhen2) or (_count == 3 and showLabelWhen3)


// SIGNAL CASCADE

var int cascadeDir   = 0
var int cascadeCount = 0

emitDir   = 0
emitCount = 0

if currState != 0
    thisCount = f_agreeCount(currState)
    if currState != cascadeDir
        cascadeDir   := currState
        cascadeCount := thisCount
        emitDir      := currState
        emitCount     := thisCount
    else if thisCount > cascadeCount
        cascadeCount := thisCount
        emitDir      := currState
        emitCount     := thisCount


// TP/SL — STATE AND DRAWING

var int      tpsl_dir         = 0
var float    tpsl_sl          = na
var float    tpsl_extreme     = na
var line     tpsl_entry_ln    = na
var label    tpsl_entry_lb    = na
var line     tpsl_sl_ln       = na
var label    tpsl_sl_lb       = na
var line     tpsl_tp1_ln      = na
var label    tpsl_tp1_lb      = na
var line     tpsl_tp2_ln      = na
var label    tpsl_tp2_lb      = na
var line     tpsl_tp3_ln      = na
var label    tpsl_tp3_lb      = na
var line     tpsl_ext_ln      = na
var linefill tpsl_risk_fill   = na
var linefill tpsl_reward_fill = na
var int      tpsl_entry_bar   = na

atr_val = ta.atr(tp_atr_period)

if show_targets and emitDir != 0 and f_labelAllowed(emitCount)
    bool is_buy_trade = emitDir == 1

    line.delete(tpsl_entry_ln)
    label.delete(tpsl_entry_lb)
    line.delete(tpsl_sl_ln)
    label.delete(tpsl_sl_lb)
    line.delete(tpsl_tp1_ln)
    label.delete(tpsl_tp1_lb)
    line.delete(tpsl_tp2_ln)
    label.delete(tpsl_tp2_lb)
    line.delete(tpsl_tp3_ln)
    label.delete(tpsl_tp3_lb)
    line.delete(tpsl_ext_ln)
    linefill.delete(tpsl_risk_fill)
    linefill.delete(tpsl_reward_fill)

    tpsl_dir       := is_buy_trade ? 1 : -1
    tpsl_entry_bar := bar_index

    float entry_p   = close
    float risk_dist = use_atr_sl ? atr_val * sl_atr_mult : entry_p * (sl_percent / 100.0)

    // Entry, SL, TP1-3 lines/labels: transparency 40
    // Gradient fills (risk/reward fill): transparency 80
    color entry_col     = color.new(is_buy_trade ? bullColor : bearColor, 40)
    color sl_col        = color.new(is_buy_trade ? bearColor : bullColor, 40)
    color tp_col        = color.new(is_buy_trade ? bullColor : bearColor, 40)
    color risk_fill_c   = color.new(is_buy_trade ? bearColor : bullColor, 80)
    color reward_fill_c = color.new(is_buy_trade ? bullColor : bearColor, 80)

    float sl_p  = is_buy_trade ? entry_p - risk_dist : entry_p + risk_dist
    float tp1_p = is_buy_trade ? entry_p + risk_dist * rr_tp1 : entry_p - risk_dist * rr_tp1
    float tp2_p = is_buy_trade ? entry_p + risk_dist * rr_tp2 : entry_p - risk_dist * rr_tp2
    float tp3_p = is_buy_trade ? entry_p + risk_dist * rr_tp3 : entry_p - risk_dist * rr_tp3

    tpsl_sl      := sl_p
    tpsl_extreme := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na

    tpsl_entry_ln := line.new(bar_index, entry_p, bar_index + 1, entry_p,
         color = entry_col, width = 2, extend = extend.none)
    tpsl_entry_lb := label.new(bar_index, entry_p,
         (is_buy_trade ? 'BUY ' : 'SELL ') + str.tostring(entry_p, format.mintick),
         style = label.style_label_left, color = entry_col,
         textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_sl_ln := line.new(bar_index, sl_p, bar_index + 1, sl_p,
             color = sl_col, width = 1, style = line.style_dashed, extend = extend.none)
        tpsl_sl_lb := label.new(bar_index, sl_p,
             'SL ' + str.tostring(sl_p, format.mintick),
             style = label.style_label_left, color = sl_col,
             textcolor = color.white, size = size.small)

    if show_tp1_level
        tpsl_tp1_ln := line.new(bar_index, tp1_p, bar_index + 1, tp1_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp1_lb := label.new(bar_index, tp1_p,
             'TP1 ' + str.tostring(tp1_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp2_level
        tpsl_tp2_ln := line.new(bar_index, tp2_p, bar_index + 1, tp2_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp2_lb := label.new(bar_index, tp2_p,
             'TP2 ' + str.tostring(tp2_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp3_level
        tpsl_tp3_ln := line.new(bar_index, tp3_p, bar_index + 1, tp3_p,
             color = tp_col, width = 1, style = line.style_dotted, extend = extend.none)
        tpsl_tp3_lb := label.new(bar_index, tp3_p,
             'TP3 ' + str.tostring(tp3_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_risk_fill := linefill.new(tpsl_entry_ln, tpsl_sl_ln, risk_fill_c)

    float fill_extreme = entry_p
    if is_buy_trade
        if show_tp1_level
            fill_extreme := math.max(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.max(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.max(fill_extreme, tp3_p)
        if fill_extreme > entry_p
            tpsl_ext_ln      := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color = na, extend = extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)
    else
        if show_tp1_level
            fill_extreme := math.min(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.min(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.min(fill_extreme, tp3_p)
        if fill_extreme < entry_p
            tpsl_ext_ln      := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color = na, extend = extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)

// TP/SL — updating line/label positions and detecting SL/TP hits
if tpsl_dir != 0
    if not na(tpsl_entry_lb)
        label.set_x(tpsl_entry_lb, bar_index)
    if not na(tpsl_sl_lb)
        label.set_x(tpsl_sl_lb, bar_index)
    if not na(tpsl_tp1_lb)
        label.set_x(tpsl_tp1_lb, bar_index)
    if not na(tpsl_tp2_lb)
        label.set_x(tpsl_tp2_lb, bar_index)
    if not na(tpsl_tp3_lb)
        label.set_x(tpsl_tp3_lb, bar_index)

    if not na(tpsl_entry_ln)
        line.set_x2(tpsl_entry_ln, bar_index + 1)
    if not na(tpsl_sl_ln)
        line.set_x2(tpsl_sl_ln, bar_index + 1)
    if not na(tpsl_tp1_ln)
        line.set_x2(tpsl_tp1_ln, bar_index + 1)
    if not na(tpsl_tp2_ln)
        line.set_x2(tpsl_tp2_ln, bar_index + 1)
    if not na(tpsl_tp3_ln)
        line.set_x2(tpsl_tp3_ln, bar_index + 1)
    if not na(tpsl_ext_ln)
        line.set_x2(tpsl_ext_ln, bar_index + 1)

    bool sl_hit = tpsl_dir == 1 ? low <= tpsl_sl : high >= tpsl_sl
    bool tp_hit = not na(tpsl_extreme) and
         (tpsl_dir == 1 ? high >= tpsl_extreme : low <= tpsl_extreme)

    if bar_index > tpsl_entry_bar and (sl_hit or tp_hit)
        if not na(tpsl_entry_ln)
            line.set_x2(tpsl_entry_ln, bar_index)
        if not na(tpsl_sl_ln)
            line.set_x2(tpsl_sl_ln, bar_index)
        if not na(tpsl_tp1_ln)
            line.set_x2(tpsl_tp1_ln, bar_index)
        if not na(tpsl_tp2_ln)
            line.set_x2(tpsl_tp2_ln, bar_index)
        if not na(tpsl_tp3_ln)
            line.set_x2(tpsl_tp3_ln, bar_index)
        if not na(tpsl_ext_ln)
            line.set_x2(tpsl_ext_ln, bar_index)
        tpsl_dir := 0


// DRAWING LABELS — Buy below the candle, Sell above the candle

if showSignalLabels and emitDir == 1 and f_labelAllowed(emitCount)
    label.new(bar_index, low, str.tostring(emitCount), xloc = xloc.bar_index, yloc = yloc.belowbar,
         style = label.style_label_up, color = buyLabelColor, textcolor = labelTextColor, size = labelSize)

if showSignalLabels and emitDir == -1 and f_labelAllowed(emitCount)
    label.new(bar_index, high, str.tostring(emitCount), xloc = xloc.bar_index, yloc = yloc.abovebar,
         style = label.style_label_down, color = sellLabelColor, textcolor = labelTextColor, size = labelSize)


// MTF AGREEMENT ALERTS

allBull = currState == 1 and tf1State == 1 and tf2State == 1
allBear = currState == -1 and tf1State == -1 and tf2State == -1

bullConfirm = allBull and not allBull[1]
bearConfirm = allBear and not allBear[1]

alertcondition(bullConfirm, title = "Strong BUY – 3TF Agreement", message = "All 3 TF Bullish!")
alertcondition(bearConfirm, title = "Strong SELL – 3TF Agreement", message = "All 3 TF Bearish!")


// MULTI-TIMEFRAME TABLE — building and drawing the table

var table mtfTable = table.new(tablePosition, 2, 12, border_width = 1, border_color = tableHeaderColor)

f_mtfRow(_tbl, _row, _show, _label, _state) =>
    if _show
        table.cell(_tbl, 0, _row, _label, text_color = tableHeaderText, bgcolor = tableBgColor, text_size = tableTextSize)
        string txt = _state == 1 ? "BULL" : _state == -1 ? "BEAR" : "—"
        color  col = _state == 1 ? tableBullColor : _state == -1 ? tableBearColor : color.gray
        table.cell(_tbl, 1, _row, txt, text_color = color.white, bgcolor = col, text_size = tableTextSize)
        _row + 1
    else
        _row

if showMtfTable and barstate.islast
    table.cell(mtfTable, 0, 0, "TF", text_color = tableHeaderText, bgcolor = tableHeaderColor, text_size = tableTextSize)
    table.cell(mtfTable, 1, 0, "Trend", text_color = tableHeaderText, bgcolor = tableHeaderColor, text_size = tableTextSize)

    r = 1
    r := f_mtfRow(mtfTable, r, show5m,  f_tfLabel(tf5m),  state5m)
    r := f_mtfRow(mtfTable, r, show15m, f_tfLabel(tf15m), state15m)
    r := f_mtfRow(mtfTable, r, show30m, f_tfLabel(tf30m), state30m)
    r := f_mtfRow(mtfTable, r, show1h,  f_tfLabel(tf1h),  state1h)
    r := f_mtfRow(mtfTable, r, show2h,  f_tfLabel(tf2h),  state2h)
    r := f_mtfRow(mtfTable, r, show4h,  f_tfLabel(tf4h),  state4h)
    r := f_mtfRow(mtfTable, r, show8h,  f_tfLabel(tf8h),  state8h)
    r := f_mtfRow(mtfTable, r, show12h, f_tfLabel(tf12h), state12h)
    r := f_mtfRow(mtfTable, r, show1D,  f_tfLabel(tf1D),  state1D)
    r := f_mtfRow(mtfTable, r, show1W,  f_tfLabel(tf1W),  state1W)
    r := f_mtfRow(mtfTable, r, show2W,  f_tfLabel(tf2W),  state2W)


// BACKTEST PLOTS — separate series for 1 / 2 / 3 agreeing TF

buy1  = emitDir == 1  and emitCount == 1
buy2  = emitDir == 1  and emitCount == 2
buy3  = emitDir == 1  and emitCount == 3

sell1 = emitDir == -1 and emitCount == 1
sell2 = emitDir == -1 and emitCount == 2
sell3 = emitDir == -1 and emitCount == 3

plot(buy1  ? 1 : na, "bt_buy_1",  display = display.none)
plot(buy2  ? 1 : na, "bt_buy_2",  display = display.none)
plot(buy3  ? 1 : na, "bt_buy_3",  display = display.none)

plot(sell1 ? 1 : na, "bt_sell_1", display = display.none)
plot(sell2 ? 1 : na, "bt_sell_2", display = display.none)
plot(sell3 ? 1 : na, "bt_sell_3", display = display.none)

// ALERTS

alertcondition(buy1,  title = "Buy — 1 TF Agreement",  message = "BUY signal (1 of 3 TF agreement)")
alertcondition(buy2,  title = "Buy — 2 TF Agreement",  message = "BUY signal (2 of 3 TF agreement)")
alertcondition(buy3,  title = "Buy — 3 TF Agreement",  message = "BUY signal (full 3 TF agreement)")

alertcondition(sell1, title = "Sell — 1 TF Agreement", message = "SELL signal (1 of 3 TF agreement)")
alertcondition(sell2, title = "Sell — 2 TF Agreement", message = "SELL signal (2 of 3 TF agreement)")
alertcondition(sell3, title = "Sell — 3 TF Agreement", message = "SELL signal (full 3 TF agreement)")
````
